# EVM to N3 Message Bridge Flow

This document details the complete flow for sending messages from EVM to Neo N3 blockchain, using the example scenario of querying a smart contract's GAS token balance on N3.

## Overview

The EVM to N3 flow allows EVM-based applications to execute operations on the Neo N3 blockchain and optionally receive results back. This is accomplished through a message bridge system that serializes calls, sends them across chains, executes them on N3, and returns results.

## Complete Flow Steps

### Step 1: Prepare the Serialized Method Call (N3 Side)

First, you prepare the serialized method call on the N3 side using the N3 MessageBridge contract:

```java
// This encodes a call to the GAS token contract's "balanceOf" method for a target contract.
byte[] getMessageBridgeGasBalance = messageBridge.getSerializedN3MethodCall(
    gasToken.getScriptHash(),      // Target contract (GAS token)
    "balanceOf",                   // Method to call
    CallFlags.READ_ONLY,           // Call flags (read-only)
    List.of(targetContractHash)    // Arguments (the contract whose balance you want)
);
```

This method returns a serialized byte array that represents the N3 method call.

### Step 2: Send Executable Message from EVM

On the EVM side, you send the serialized method call as an executable message:

```solidity
// Send the serialized N3 method call as an executable message
// Set storeResult to true to receive the result back
bytes memory serializedCall = getMessageBridgeGasBalance; // From step 1
bool storeResult = true; // We want the result back

messageBridge.sendExecutableMessage{value: messageFee}(serializedCall, storeResult);
```

**What happens internally:**
1. The message is validated (size, fee payment)
2. Metadata is created with `MessageType.EXECUTABLE`
3. A new nonce is assigned and the message hash is computed
4. The N3 state root is updated
5. A `MessageSent` event is emitted

### Step 3: Message Relay to N3

The message is picked up by relayers who monitor the EVM blockchain:

1. **Relayer Detection**: Off-chain relayers listen for `MessageSent` events
2. **Message Validation**: Relayers validate the message format and signature
3. **N3 Submission**: Relayers submit the message to the N3 MessageBridge contract

### Step 4: Store the Message for Execution

Store the serialized method call in the message bridge contract:

```java
BigInteger executableMessageNonce = messageBridge.storeMessage(getMessageBridgeGasBalance);
```

**Validation errors and events during storage:**

1. **Contract State Validation**: The N3 MessageBridge verifies the contract is not paused
   ```java
   if (isPaused()) {
       throw new Exception("Contract is paused");
   }
   ```
2. **Signature Verification: Validates that enough validators have signed the message root:**
    ```java
    if (!management.verifyValidatorSignatures(root, signatures)) {
        throw new Exception("Invalid validator signatures");
    }
    ```
3. **Root Verification: Ensures the provided root matches the computed message root**
    ```java
    Hash256 computedRoot = computeMessageRoot(messageEnvelopes);
    if (!computedRoot.equals(root)) {
        throw new Exception("Invalid root");
    }
    ```
4. **Nonce Validation: Ensures messages are processed in sequential order**
    ```java
    if (messageEnvelope.nonce != expectedNonce) {
        throw new Exception("Invalid nonce sequence");
    }
    ```
5. **Events Emitted: Storage events are emitted for monitoring and indexing**
```java
    fire("MessageStore", nonce, metadataSerializedHex);
    fire("MessageStoreRoot", root);
```

### Step 5: Message Execution on N3

Execute the stored message on N3:

```java
Hash256 tx = messageBridge.executeMessage(AccountSigner.global(executorAccount), executableMessageNonce);
```

This triggers:
1. **Execute Event**: Emitted when execution starts
2. **Target Contract Execution**: The actual `balanceOf` call to the GAS token contract
3. **ExecutionResult Event**: Emitted with the execution result

**Event Structure:**
```java
// Execute event
event Execute(BigInteger nonce);

// ExecutionResult event  
event ExecutionResult(BigInteger nonce, ByteString result);
```
The method `balanceOf` is called on the GAS token contract, as it was defined at step 1.
```java
// N3 execution (conceptual)
// The serialized call is executed against the GAS token contract
UInt256 balance = gasToken.balanceOf(targetContractHash);
// Result is serialized and stored for return
```

### Step 6: Verify Execution Results

After execution, verify the state has changed:

```java
ExecutableStateDto execStateAfterExec = messageBridge.getExecutableState(executableMessageNonce);
// Should be: execStateAfterExec.executed == true

// Get the actual result
byte[] resultBytes = messageBridge.getResult(executableMessageNonce);
// Contains the serialized return value from the N3 method call
```

### Step 7: Send Result Back to EVM

Send the execution result as a message back to EVM:

```java
BigInteger nextEvmNonce = getNextEvmNonce();
Hash256 resultSendTx = testMessageSender.sendResultMessage(
    AccountSigner.global(senderAccount), 
    executableMessageNonce  // Reference to the original message
);
```

This creates a **RESULT** type message with:
- **Message Type**: `2` (RESULT)
- **Timestamp**: Current N3 block time
- **Sender**: The contract/account sending the result
- **Related Message Nonce**: Reference to the original executable message
- **Payload**: The actual result bytes from the N3 execution

The result message triggers a `MessageSend` event:

```java
event MessageSend(
    BigInteger nonce,           // New EVM-bound message nonce
    ByteString rawMessage,      // The result payload
    ByteString metadata,        // Serialized message metadata
    ByteString prevMessageHash, // Hash of previous message in chain
    ByteString newMessageHash   // Hash of this message
);
```

**Metadata Structure for RESULT messages:**
```java
[
    msgType,              // 2 (RESULT)
    timestamp,            // N3 block timestamp
    sender,               // Hash160 of sending contract
    relatedMessageNonce   // Original message nonce being responded to
]
```

### Step 8: Result Storage on EVM

The result message is stored on EVM:

```solidity
// Relayers call this function with validator signatures
messageBridge.storeMessage(depositRoot, signatures, resultMessages);
```

**What happens:**
1. Validator signatures are verified
2. The result message is stored in EVM storage
3. The message is marked as available for retrieval

### Step 9: Result Retrieval on EVM - (Currently not implemented)

Finally, you can retrieve the result on the EVM side:

```solidity
// Get the result of the original message execution
uint256 originalMessageNonce = 1; // The nonce from step 2
AMBTypes.Result memory result = messageBridge.getResult(originalMessageNonce);

if (result.success) {
    // Decode the balance result
    uint256 gasBalance = abi.decode(result.returnData, (uint256));
    // Now you have the GAS token balance from N3!
}
```
