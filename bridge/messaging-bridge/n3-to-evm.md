# N3 to EVM Message Bridge Flow

This document details the complete flow for sending messages from N3 to Neo X (EVM blockchain) using the example scenario of querying a Neo token's balance on EVM from N3 and receiving the result back.

## Overview

The message bridge allows N3 applications to execute operations on EVM-based blockchains and receive results back.

This is accomplished by encoding an `AMBTypes.Call` struct and sending the encoded bytes to the N3 message bridge contract. The [decoupled relayer](/bridge/general/bridging-transparency-and-verifiable-relaying.md#decoupled-validator--relayer-architecture-summary) then ensures safe transfer of the data to the EVM chain. Once the data has been bridged, the message can be executed on the EVM chain and its result may be returned.

> Currently, BaneLabs does not provide a service to execute messages. In future versions execution rewards might be added to messages, so that users can attach an incentive for anyone active on the destination network to execute a message for them.

## Complete Flow Steps

In the following we'll use an example call to elaborate on the flow. For simplicity, let's assume we want to get the Neo balance of an account on Neo X.

> As the bridging process is an asynchronous process, fetching a value that can be fluctuent like a Neo balance might not be the most intuitive use case. However, for the purpose of this example it should sufficiently elaborate on the steps required to use the message bridge.

### Step 1: Prepare the EVM Call Structure

First, prepare the EVM call by creating an `AMBTypes.Call` structure on the N3 side using the ethers library for proper ABI encoding:

```javascript
const { ethers } = require('ethers');

// Define the Neo token contract address on EVM and target address
const neoTokenContractAddress = "0xc28736dc83f4fd43d6fb832Fd93c3eE7bB26828f"; // Neo token address on Neo X Testnet
const targetAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"; // Address to check the balance for

// Create the interface for ERC20 balanceOf function
const erc20Interface = new ethers.Interface([
    "function balanceOf(address account) view returns (uint256)"
]);

// Encode the balanceOf function call
const callData = erc20Interface.encodeFunctionData("balanceOf", [targetAddress]);
console.log("Encoded balanceOf callData:", callData);
// Output: 0x70a08231000000000000000000000000abcdefabcdefabcdefabcdefabcdefabcdefabcd

// Create the EVM Call structure (equivalent to AMBTypes.Call)
const evmCall = {
    target: neoTokenContractAddress,    // Target EVM Neo token contract
    allowFailure: false,                // Don't allow failure
    value: 0,                           // No gas value needed for the call
    callData: callData                  // Encoded balanceOf(address) call data
};

// Serialize the entire Call structure using ethers ABI encoder
const callStructAbi = [
    "tuple(address target, bool allowFailure, uint256 value, bytes callData)"
];
const abiCoder = new ethers.AbiCoder();
const serializedMessage = abiCoder.encode(callStructAbi, [evmCall]);

console.log("Serialized Call message:", serializedMessage);
```

### Step 2: Send Executable Message from N3

Send the EVM call as an executable message from N3 (Java example code):

```java
// Get the fee for sending a message across the bridge.
BigInteger sendingFee = n3MessageBridge.callFunctionReturningInt("sendingFee");
// Build the transaction to send the executable message to Neo X using the sendingFee as maximal allowed fee and your account as bridge fee payer.
TransactionBuilder b = n3MessageBridge.invokeFunction("sendExecutableMessage", byteArray(rawMessage), bool(storeResult), hash160(myAccount), integer(sendingFee));
Transaction transaction = b.signers(AccountSigner.calledByEntry(myAccount)).sign();
NeoSendRawTransaction response = transaction.send();
Await.waitUntilTransactionIsExecuted(response.getSendRawTransaction().getHash(), neow3j);
```

**Parameters:**

- `rawMessage`: The encoded EVM contract call data, i.e., the output `serializedMessage` above.
- `true`: Once the message is executed, the result of the execution should be stored on-chain, so that it can be returned to N3 if needed. If set to `false`, the result will not be stored. The result will be included in an event that is fired when executing regardless of this value.

This creates an **EXECUTABLE** type message with:

- **Message Type**: `0` (EXECUTABLE)
- **Timestamp**: Current N3 block time
- **Sender**: The N3 contract/account sending the message
- **Store Result Flag**: `true` (result should be stored on-chain on Neo X)
- **Payload**: The EVM contract call data

The message will be assigned a number (a `nonce`). You can get it by either reading the remaining stack item of the transaction (the nonce is returned by the `sendExecutableMessage()` function), or you can check the events of the transaction for the event `MessageSend`.

```java
ApplicationLog log = transaction.getApplicationLog();
BigInteger messageNonce = log.getFirstExecution().getFirstStackItem().getInteger();
```

### Step 3: Message Relay to the EVM Chain

In this step, you need to wait until the decoupled relayer has transferred the message to the EVM chain. This should only take a couple of seconds.

You can listen to the `MessageDeposit` event emitted by the MessageBridge contract. The first argument in the event is the message nonce. Once the event appears, your message has been transferred to the EVM chain and is now ready to be executed.

### Step 4: Message Execution on EVM

Once the message has been stored on the EVM chain, the message can be executed by anyone calling `executeMessage(uint256)` with the message nonce as parameter:

```javascript
// Anyone can execute a stored message by providing its nonce
await evmMessageBridge.executeMessage(nonce);
```

### Step 5: Verify Execution Results

After execution, you can verify the execution results on EVM:

```javascript
const { success, returnData } = await messageBridge.getResult(nonce);
```

> If the message's `storeResult` was set to `false` when sending it, the result is only accessible in the `MessageExecuted` event emitted when the message was executed.

### Step 6: Return Result back to N3

> This and the following steps are only needed if you want to return the result to N3.

In order to send a result back, you can call the `sendResultMessage(uint256)` function:

```javascript
await evmMessageBridge.sendResultMessage(nonce);
```

This will send the result back to N3 in form of a normal message sent from EVM to N3. It will get a new nonce. You can check the `MessageSent` event of the transaction to get this message nonce.

### Step 7: Message Relay back to N3

Now, the decoupled relayer transferres the response message back to N3. Take the message nonce from the returning message (i.e., the one from the `MessageSent` event in Step 6) and wait for the `Store` event on the MessageBridge contract on N3 that has this nonce.

In this step, the message bridge is used in the reverse direction from the EVM chain to the N3 chain. As in Step 3, you now need to wait until the decoupled relayer has transferred the message to N3. The event emitted when messages are transferred is `Store` and its first state entry is the nonce.

Once the result is transferred, it can be read on-chain on N3.

## Example Implementation (JavaScript)

```javascript
const {ethers} = require('ethers');

// Define the Neo token contract address on EVM and target address
const neoTokenContractAddress = "0xc28736dc83f4fd43d6fb832Fd93c3eE7bB26828f"; // Neo token address on Neo X Testnet
const targetAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"; // Address to check the balance for

// Create the interface for ERC20 balanceOf function
const erc20Interface = new ethers.Interface([
  "function balanceOf(address account) view returns (uint256)"
]);

async function exampleFunc() {
  const encodedMessage = getEncodedBalanceOfCall("0xc28736dc83f4fd43d6fb832Fd93c3eE7bB26828f",
      "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd");

  // Send message on N3 using Javascript
  const sendingFee = await messageBridge.sendingFee();
  const params: SendExecutableMessageParams = {
    encodedMessage,
    true, // storeResult
    maxFee: sendingFee
  };
  await messageBridge.sendExecutableMessage(params)

  // Wait until the message arrives on the EVM chain...

  // Once the message has been bridged over to the EVM chain, you can execute it
  await evmMessageBridge.connect(sender).executeMessage(nonce, {maxFeePerGas, maxPriorityFeePerGas});

  // If the result should be stored on-chain, you can return the result now.
  await evmMessageBridge.connect(sender).
      sendResultMessage(nonce, {value: sendingFee, maxFeePerGas, maxPriorityFeePerGas});
}

function getEncodedBalanceOfCall(tokenAddress, targetAddress) {
  // Encode the balanceOf call using ethers
  const erc20Interface = new ethers.Interface(["function balanceOf(address account) view returns (uint256)"]);
  const callData = erc20Interface.encodeFunctionData("balanceOf", [targetAddress]);

  // Create the Call structure
  const evmCall = {
    target: tokenAddress,
    allowFailure: false,
    value: 0,
    callData: callData
  };

  // Serialize the Call structure
  const callStructAbi = ["tuple(address target, bool allowFailure, uint256 value, bytes callData)"];
  const abiCoder = new ethers.AbiCoder();
  const serializedMessage = abiCoder.encode(callStructAbi, [evmCall]);

  return {
    serializedMessage: serializedMessage,
    callData: callData,
    evmCall: evmCall
  };
}

function decodeBalanceResult(resultData) {
  // Decode the uint256 balance result
  const abiCoder = new ethers.AbiCoder();
  const balance = abiCoder.decode(["uint256"], resultData)[0];
  return balance;
}
```

## Visualization

```markdown
JavaScript + ethers for building the EVM call
┌─────────────────────────────────────────────────────────┐
│ const evmCall = {                                       │
│   target: "0x1234...7890",  // Neo token contract       │
│   allowFailure: false,                                  │
│   value: 0,                                             │
│   callData: "0x70a08231000...abcdef"  // balanceOf()    │
│ };                                                      │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼ ethers.AbiCoder.encode()
┌─────────────────────────────────────────────────────────┐
│ Serialized Message (hex string)                         │
│ 0x0000002000000000000000001234...7890000000000000...    │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼ Send the message on N3
┌─────────────────────────────────────────────────────────┐
│ messageBridge.sendExecutableMessage(bytes, bool)        │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼ Cross-chain relay - then execute on EVM
┌─────────────────────────────────────────────────────────┐
│ messageBridge.executeMessage(nonce)                     │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼ Return the result to N3
┌─────────────────────────────────────────────────────────┐
│ messageBridge.sendResultMessage(nonce)                  │
└─────────────────────────────────────────────────────────┘
```

This completes the full N3 to EVM flow showing how to properly prepare the call data using the ethers library for encoding the `AMBTypes.Call` structure and `balanceOf` method call, serializing it, sending it, executing it, and then sending the results back to N3.
