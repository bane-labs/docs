# EVM to N3 Message Bridge Flow

This document details the complete flow for sending messages from Neo X (an EVM blockchain) to N3 using the example scenario of querying a Neo token's balance on N3 from the EVM chain and receiving the result back.

## Overview

The message bridge allows EVM applications to execute operations on N3 and receive results backa.

This is accomplished by serializing a function call and sending the encoded bytes to the EVM message bridge contract. The [decoupled relayer](/bridge/general/bridging-transparency-and-verifiable-relaying.md#decoupled-validator--relayer-architecture-summary) then ensures safe transfer of the data to N3. Once the data has been bridged, the message can be executed on N3 and its result may be returned.

The EVM to N3 flow allows EVM-based applications to execute operations on the N3 blockchain and optionally receive results back. This is accomplished through a message bridge system that serializes calls, sends them across chains, executes them on the N3 chain, and returns the results.

## Complete Flow Steps

### Step 1: Prepare the Serialized N3 Method Call

First, you prepare the serialized method call on the N3 side using the N3 MessageBridge contract:

```java
Hash160 targetAccount = new Hash160("0xabcdefabcdefabcdefabcdefabcdefabcdefabcd");
// This encodes a call to the NEO token contract's "balanceOf" method for a target contract.
byte[] serializedN3MethodCall = n3MessageBridge.getSerializedN3MethodCall(
    NeoToken.SCRIPT_HASH,          // Target contract (NEO token)
    "balanceOf",                   // Method to call
    CallFlags.READ_ONLY,           // Call flags (read-only)
    List.of(targetAccount)         // Arguments (the account whose balance you want)
);
```

This method returns a serialized byte array that represents the N3 method call.

### Step 2: Send Executable Message from EVM

On the EVM side, you send the serialized method call as an executable message:

```javascript
const storeResult = true;
const sendingFee = ethers.parseEther("0.1"); // The sending fee
evmMessageBridge.sendExecutableMessage{value: sendingFee}(rawMessage, storeResult);
```

- `rawMessage`: The serialized N3 method call, i.e., the output `serializedN3MethodCall` above.
- `storeResult`: Once the message is executed, the result of the execution should be stored on-chain, so that it can be returned to the EVM chain if needed. If set to `false`, the result will not be stored. The result will be included in an event that is fired when executing regardless of this value.
- `sendingFee`: The fee required for sending a message to N3.

This creates an **EXECUTABLE** type message with:

- **Message Type**: `0` (EXECUTABLE)
- **Timestamp**: Current EVM block time
- **Sender**: The message sender (i.e., `msg.sender`) sending the message
- **Store Result Flag**: `true` (result should be stored on-chain on N3)
- **Payload**: The N3 method call data

The message will be assigned a number (a `nonce`). You can get it by checking the events of the transaction for the event `MessageSent`.

### Step 3: Message Relay to N3

In this step, you need to wait until the decoupled relayer has transferred the message to the EVM chain. This should only take a couple of seconds.

You can listen to the `Store` event emitted by the N3 MessageBridge contract. The first argument in the event is the message nonce. Once the event appears, your message has been transferred to N3 and is now ready to be executed.

### Step 4: Message Execution on N3

Once the message has been stored on the EVM chain, the message can be executed by anyone calling `executeMessage(int)` with the message nonce as paramter:

```java
TransactionBuilder b = n3MessageBridge.invokeFunction("executeMessage", integer(nonce));
Transaction transaction = b.signers(AccountSigner.calledByEntry(myAccount)).sign();
NeoSendRawTransaction response = transaction.send();
Await.waitUntilTransactionIsExecuted(response.getSendRawTransaction().getHash(), neow3j);
```

Executing a message will emit the following:

1. `Execute` with parameters `Nonce` and `Metadata` emitted by the MessageBridge contract.
2. Potential events based on the N3 method call. In this example, there's no events emitted as the `balanceOf` method call is a read-only invocation.
3. `ExecutionResult` with parameters `Nonce` and `Result` emitted by the MessageBridge contract.

The result is emitted in deserialized form as it was returned from the method call.

### Step 5: Verify Execution Results

After execution, you can verify the execution results on N3:

```java
List<StackItem> items = n3MessageBridge.callInvokeFunction("getExecutableState", asList(integer(nonce))).getInvocationResult()
                .getFirstStackItem().getList();

boolean executed = items.get(0).getBoolean();
BigInteger expirationTime = items.get(1).getInteger();

// Get the actual result
byte[] serializedResult = n3MessageBridge.callInvokeFunction("getResult", asList(integer(nonce))).getInvocationResult()
                .getFirstStackItem().getByteArray();
```

Note that the result returned from `getResult` is serialized using the native `StdLib` contract's `serialize()` function. You can use its function `deserialize()` to get the deserialized stack items. It is up to the caller to interpret the result accordingly.

### Step 6: Return Result back to EVM

> This and the following steps are only needed if you want to return the result to the EVM chain.

In order to send a result back, you can call the `sendResultMessage(nonce)` function:

```java
TransactionBuilder b = n3MessageBridge.invokeFunction("sendResultMessage", integer(messageNonce), hash160(feePayer), integer(maxFee));
Transaction transaction = b.signers(AccountSigner.calledByEntry(myAccount)).sign();
NeoSendRawTransaction response = transaction.send();
Await.waitUntilTransactionIsExecuted(response.getSendRawTransaction().getHash(), neow3j);
```

This will send the result back to the EVM chain in form of a normal message sent from N3 to EVM. It will get a new nonce. You can check the `MessageSend` event of the transaction to get this message nonce.

### Step 7: Message Relay back to EVM

Now, the decoupled relayer transferres the response message back to the EVM chain. Take the message nonce from the returning message (i.e., the one from the `MessageSend` event in Step 6) and wait for the `MessageDeposit` event on the MessageBridge contract on EVM that has this nonce.

In this step, the message bridge is used in the reverse direction from N3 to the EVM chain. As in Step 3, you will need to wait until the decoupled relayer has transferred the message to the EVM chain.

Once the result is transferred, it can be read on the EVM chain.

## Example Implementation (JavaScript)

```javascript
const { ethers } = require('ethers');

// Define the target contract address and the account address to check the balance for.
const neoTokenContractAddress = "0xef4073a0f2b305a38ec4050e4d3d28bc40ea63f5"; // Neo token address on N3
const targetAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd"; // Address to check the balance for

function exampleFunc() {
    // TBD: Serialize an N3 method call using Javascript
    // Invoke the N3 MessageBridge contract's function serializeN3MethodCall() to get the bytes needed.
    // const rawMessage = n3MessageBridge.serializeN3MethodCall(target, method, callFlags, args);
    const rawMessage = "0x400428141418e358c565207768eae8d237241e85d3e9f1cb280573746f72652101024002210101210440a87c68";

    const storeResult = true;
    const sendingFee = ethers.parseEther("0.1");
    await evmMessageBridge.connect(sender).sendExecutableMessage(rawMessage, storeResult, {value: sendingFee, maxFeePerGas, maxPriorityFeePerGas});

    // Wait until the message arrives on N3...

    // TBD: Execute message on N3 using Javascript
    // Invoke the method executeMessage() on the MessageBridge contract on N3 using the assigned message nonce when the message was sent.

    // TBD: Send the result back from N3 to EVM
    // Invoke the method sendResultMessage() on the MessageBridge contract on N3 using the assigned message nonce when the message was sent initially.
}
```

## Visualization

```markdown
Java (or other N3 SDK) for building the N3 method call
┌────────────────────────────────────────────────────────────────┐
│ Hash160 target = NeoToken.SCRIPT_HASH;                         │
│ String method = "balanceOf";                                   │
│ CallFlags callFlags = CallFlags.READ_ONLY                      │
│ Hash160 account = new Hash160("");                             │
│ ContractParameter args = array(hash160(account));              │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼ n3MessageBridge.serializeN3MethodCall(target, method, callFlags, args)
┌────────────────────────────────────────────────────────────────┐
│ Serialized N3 Message                                          │
│ 0x400428141418e358c565207768ea...0101210440a87c68...           │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼ Send the message on EVM
┌────────────────────────────────────────────────────────────────┐
│ evmMessageBridge.sendExecutableMessage(bytes, bool)            │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼ Cross-chain relay - then execute on N3
┌────────────────────────────────────────────────────────────────┐
│ n3MessageBridge.executeMessage(nonce)                          │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼ Return the result to EVM
┌────────────────────────────────────────────────────────────────┐
│ n3MessageBridge.sendResultMessage(nonce, feePayer, sendingFee) │
└────────────────────────────────────────────────────────────────┘
```

This completes the full EVM to N3 flow showing how to properly prepare the method call data using the message bridge contract, sending it, executing it on N3 and then sending the results back.
