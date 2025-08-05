# N3 to EVM Message Bridge Flow

This document details the complete flow for sending messages from Neo N3 to EVM blockchain, using the example scenario of querying a Neo token's balance on EVM from N3 and receiving the result back.

## Overview

The N3 to EVM flow allows Neo N3 applications to execute operations on EVM-based blockchains and receive results back. This is accomplished through a message bridge system that creates `AMBTypes.Call` structures on N3, serializes them using ethers library encoding, sends them across chains, executes them on EVM, and returns results.

## Complete Flow Steps

### Step 1: Prepare the EVM Call Structure (N3 Side using ethers)

First, you prepare the EVM call by creating an `AMBTypes.Call` structure on the N3 side using the ethers library for proper ABI encoding:

```javascript
const { ethers } = require('ethers');

// Define the Neo token contract address on EVM and target address
const neoTokenContractAddress = "0x1234567890123456789012345678901234567890"; // EVM Neo token address
const targetAddress = "0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef"; // Address to check balance for

// Create the interface for ERC20 balanceOf function
const erc20Interface = new ethers.Interface([
    "function balanceOf(address account) view returns (uint256)"
]);

// Encode the balanceOf function call
const callData = erc20Interface.encodeFunctionData("balanceOf", [targetAddress]);
console.log("Encoded balanceOf callData:", callData);
// Output: 0x70a08231000000000000000000000000abcdefabcdefabcdefabcdefabcdefabcdefabcdef

// Create the EVM Call structure (equivalent to AMBTypes.Call)
const evmCall = {
    target: neoTokenContractAddress,    // Target EVM Neo token contract
    allowFailure: false,                // Don't allow failure
    value: 0,                          // No ETH value needed for view call
    callData: callData                 // Encoded balanceOf(address) call
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

Send the EVM call as an executable message from N3:

```java
Hash256 tx = testMessageSender.sendExecutableMessage(rawMessage, true);
```

**Parameters:**
- `rawMessage`: The encoded EVM contract call data
- `true`: Store the execution result for later retrieval
- Automatically includes fee sponsor and gas fee

This creates an **EXECUTABLE** type message with:
- **Message Type**: `0` (EXECUTABLE)
- **Timestamp**: Current N3 block time
- **Sender**: The N3 contract/account sending the message
- **Store Result Flag**: `true` (result should be stored and sent back)
- **Payload**: The EVM contract call data

### Step 3: Message Relay to EVM

The message is picked up by relayers who monitor the N3 blockchain:

1. **Relayer Detection**: Off-chain relayers listen for `MessageSent` events on N3
2. **Message Validation**: Relayers validate the message format and collect validator signatures
3. **EVM Submission**: Relayers submit the message to the EVM MessageBridge contract

### Step 4: Message Storage on EVM

The message is stored on the EVM side through the `storeMessage()` function:

```solidity
// Relayers call this function with validator signatures and message data
messageBridge.storeMessage(depositRoot, signatures, messageData);
```

**Validation errors and events during storage:**

1. **Signature Verification**: The EVM MessageBridge verifies that enough validators have signed the message
   ```solidity
   if (!management.verifyValidatorSignatures(depositRoot, signatures)) {
       revert InvalidValidatorSignatures();
   }
   ```

2. **Nonce Validation**: Ensures messages are processed in sequential order
   ```solidity
   if (messageData[i].nonce != state.nonce + i + 1) {
       revert InvalidNonceSequence();
   }
   ```

3. **Root Verification**: Validates the provided deposit root matches the computed root
   ```solidity
   if (MessageBridgeLib._computeNewTopRoot(state.root, messages) != depositRoot) {
       revert InvalidRoot();
   }
   ```

4. **Events Emitted**: Storage events are emitted for monitoring
   ```solidity
   emit MessageDepositRootUpdate(nonce, depositRoot);
   emit MessageDeposit(nonce, messageData.message);
   ```

### Step 5: : Message Execution on EVM

Once stored, the message can be executed by anyone calling `executeMessage()`:

```solidity
// Anyone can execute a stored message by providing its nonce
AMBTypes.Result memory result = messageBridge.executeMessage(nonce);
```

**EVM Execution Process:**
1. **Message Retrieval**: The EVM execution system retrieves the stored message by nonce
   ```solidity
   StoredMessage memory storedMessage = evmMessages[nonce];
   bytes memory rawMessage = storedMessage.rawMessage;
   ```

2. **Call Deserialization**: The serialized `AMBTypes.Call` struct is deserialized
   ```solidity
   AMBTypes.Call memory call = abi.decode(rawMessage, (AMBTypes.Call));
   ```

3. **Execution Validation**: Check if message hasn't expired and wasn't already executed
   ```solidity
   ExecutableState memory execState = evmExecutableStates[nonce];
   require(!execState.executed, "MessageAlreadyExecuted");
   require(block.timestamp <= execState.expirationTimestamp, "ExecutionWindowExpired");
   ```

4. **Contract Execution**: The ExecutionManager executes the call
   ```solidity
   // 3. The Call structure is executed:
   //    - Target: 0x1234567890123456789012345678901234567890 (Neo token contract)
   //    - Value: 0 (no ETH sent)
   //    - CallData: 0x70a08231000000000000000000000000abcdefabcdefabcdefabcdefabcdefabcdefabcdef
   //    - AllowFailure: false

   // 4. This results in calling:
   uint256 balance = IERC20(call.target).balanceOf(targetAddress);
   // Result: balance in Wei (e.g., 1000000000000000000 for 1 NEO with 18 decimals)
   ```

5. **Result Storage**: If `storeResult` was true, the execution result is stored
   ```solidity
   if (metadata.storeResult) {
       evmExecutionResults[nonce] = abi.encode(result);
   }
   ```

### Step 6: Verify Execution Results

After execution, you can verify the execution results on EVM:

```solidity
// Check if the execution was successful and verify the result
AMBTypes.Result memory executionResult = messageBridge.getExecutableState(nonce);

// If storeResult was true, the result is automatically stored in evmExecutionResults
if (metadata.storeResult) {
    // The result is now available in storage and can be retrieved later
    // The encoded result contains both success status and return data
    bytes memory storedResult = ambStorage.evmExecutionResults[nonce];
    AMBTypes.Result memory result = abi.decode(storedResult, (AMBTypes.Result));
    
    if (result.success) {
        // Decode the balance result from the return data
        uint256 balance = abi.decode(result.returnData, (uint256));
        // Balance is now available for use or further processing
    }
}

// Event is emitted for monitoring and verification
emit MessageExecuted(nonce, result);
```

### Step 7: Result Message Relay to N3

Relayers monitor EVM for result messages and relay them back to N3:

1. **EVM Event Monitoring**: Relayers watch for result message events on EVM
2. **Signature Collection**: Multiple validator signatures are collected
3. **N3 Submission**: The result message is submitted to the N3 MessageBridge

### Step 8: Result Storage on N3

The result message is stored on N3:

```java
// Relayers call this method with validator signatures
messageBridge.storeMessage(depositRoot, signatures, resultMessages);
```

**What happens on N3:**
1. Validator signatures are verified
2. The result message is stored in N3 storage
3. The message is marked as available for retrieval

### Step 8: Result Retrieval on N3 (Currently not implemented)

Finally, you can retrieve the result on the N3 side:

```java
// Get the result of the original message execution
uint originalMessageNonce = nonce; // The nonce from step 2
AMBTypes.Result result = messageBridge.getResult(originalMessageNonce);

if (result.success) {
    // Decode the balance result using ethers-compatible decoding
    // The returnData contains the encoded uint256 balance
    BigInteger neoBalance = DecodeUint256(result.returnData);
    
    // Convert from Wei to NEO (divide by 10^18 if NEO token uses 18 decimals)
    decimal neoBalanceInTokens = (decimal)neoBalance / (decimal)Math.Pow(10, 18);
    
    // Now you have the Neo token balance from EVM!
    System.Console.WriteLine($"Neo token balance on EVM: {neoBalanceInTokens} NEO");
}
```

Helper method for decoding uint256 (compatible with ethers encoding):
```java
private static BigInteger DecodeUint256(byte[] encodedData)
{
    // EVM ABI encoding for uint256 is 32 bytes, big-endian (ethers standard)
    if (encodedData.Length != 32) 
        throw new ArgumentException("Invalid encoded uint256 data");
    
    // Convert from big-endian bytes to BigInteger
    Array.Reverse(encodedData); // Convert to little-endian for .NET
    return new BigInteger(encodedData);
}
```

## Example Implementation (JavaScript + N3)

```javascript
// JavaScript side for encoding
const { ethers } = require('ethers');

class NeoTokenBalanceQuery {
    constructor(messageBridge, neoTokenAddress) {
        this.messageBridge = messageBridge;
        this.neoTokenAddress = neoTokenAddress;
        this.erc20Interface = new ethers.Interface([
            "function balanceOf(address account) view returns (uint256)"
        ]);
    }

    queryBalance(targetAddress) {
        // Encode the balanceOf call using ethers
        const callData = this.erc20Interface.encodeFunctionData("balanceOf", [targetAddress]);
        
        // Create the Call structure
        const evmCall = {
            target: this.neoTokenAddress,
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

    decodeBalanceResult(resultData) {
        // Decode the uint256 balance result
        const abiCoder = new ethers.AbiCoder();
        const balance = abiCoder.decode(["uint256"], resultData)[0];
        return balance;
    }
}

// Usage example
const query = new NeoTokenBalanceQuery(messageBridge, "0x1234567890123456789012345678901234567890");
const { serializedMessage } = query.queryBalance("0xabcdefabcdefabcdefabcdefabcdefabcdefabcdef");

// Convert to N3 byte array and send
const messageBytes = hexStringToByteArray(serializedMessage);
const nonce = messageBridge.sendExecutableMessage(messageBytes, true, messageFee);
```

```java
// N3 side for sending and receiving
public class NeoTokenBalanceQuery
{
    private readonly MessageBridge messageBridge;
    private readonly UInt160 evmNeoTokenAddress;
    
    public NeoTokenBalanceQuery(MessageBridge bridge, UInt160 tokenAddress)
    {
        messageBridge = bridge;
        evmNeoTokenAddress = tokenAddress;
    }
    
    public uint QueryBalance(string serializedMessage)
    {
        // Convert the ethers-encoded message to byte array
        byte[] messageBytes = hexStringToByteArray(serializedMessage);
        long fee = messageBridge.getMessageFee();
        
        uint nonce = messageBridge.sendExecutableMessage(messageBytes, true, fee);
        return nonce; // Return nonce to track the request
    }
    
    public BigInteger GetBalance(uint messageNonce)
    {
        var result = messageBridge.getResult(messageNonce);
        if (!result.success)
            throw new Exception("Balance query failed");
            
        return DecodeUint256(result.returnData);
    }
    
    private byte[] hexStringToByteArray(string hexString)
    {
        if (hexString.startsWith("0x"))
            hexString = hexString.substring(2);
            
        int len = hexString.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hexString.charAt(i), 16) << 4)
                                 + Character.digit(hexString.charAt(i+1), 16));
        }
        return data;
    }
}
```

## Example Message Flow Visualization

```
N3 Side (JavaScript + ethers):
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
                              ▼ hexStringToByteArray() → N3
┌─────────────────────────────────────────────────────────┐
│ N3 MessageBridge.sendExecutableMessage(bytes, bool)     │
└─────────────────────────────────────────────────────────┘
                              │
                              ▼ Cross-chain relay
EVM Side:
┌─────────────────────────────────────────────────────────┐
│ abi.decode(message, (AMBTypes.Call))                    │
│ ↓                                                       │
│ ExecutionManager.executeCall(call.target, call.value,   │
│                              call.callData)             │
│ ↓                                                       │
│ IERC20(0x1234...7890).balanceOf(0xabcd...cdef)          │
│ → Returns: 1000000000000000000 (1 NEO with 18 decimals) │
└─────────────────────────────────────────────────────────┘
```

This completes the full N3 to EVM flow showing how to properly prepare the call data using the ethers library for encoding the `AMBTypes.Call` structure and `balanceOf` method call, serialize it, and execute it on EVM.
