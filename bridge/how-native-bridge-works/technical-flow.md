# Technical Flow

Here is a breakdown of the technical steps involved in transferring GAS between Neo N3 and Neo X.

## **Bridge GAS from Neo N3 to Neo X**

**Neo N3：**

1. Send GAS to Bridge Contract including valid data (recipient address on Neo X).
2. Bridge Contract on-chain:
   1. Validate the data.
   2. Increment nonce.
   3. Calculate the new deposit hash (including `nonce, recipient, amount`).
   4. Calculate the new root of the Hash Chain.
   5. Set the new root.
   6. (Send GAS to treasury)
   7. Emit the event with `nonce, recipient, amount, from, deposit hash, new root.`

**Validators:**

1. Listen and notice new deposit event.
2. Sign new root and send signature to relayer node.

**Relayer:**

1. Receive the transaction hash and signature from validators.
2. Validate the signatures with event data, based on application log of transaction.
3. Collect 5 signatures for this event (5 = threshold of validator multi-sig).
4. Invoke Neo X Bridge Contract with provided validator signatures, deposit data, and root.

**Neo X** (Bridge Contract):

1. Check that relayer is sender.
2. Hash the deposit data and validate the validator signatures.
3. Calculate the new deposit hash.
4. Calculate the new root (based on the current root).
5. Verify with provided root.
6. Transfer GAS for recipient address.
7. Emit a transfer event.

## **Bridge GAS from Neo X to Neo N3**

**Neo X:**

1. Send GAS to Bridge Contract including valid data (recipient address on N3).
2. Bridge Contract on-chain:
   1. Validate the data. (incl. verifying that the provided amount is greater or equal to the sent msg.value)
   2. Increment nonce.
   3. Calculate the new withdrawal hash (including `nonce, recipient, amount`).
   4. Calculate the new root.
   5. Set the new root.
   7. Emit the event with `nonce, recipient, amount, from, withdrawal hash, new root`

**Validators:**

1. Listen and notice new withdrawal event.
2. Sign the new root and send the signature to relayer node.\*

**Relayer:**

1. Receive the transaction hash and signature from validators.
2. Validate the signatures with event data, based on application log of transaction.
3. Collect 5 signatures for this event (5 = threshold of validator multi-sig).
4. Invoke N3 Bridge Contract with provided validator signatures, withdrawal data and root.

**Neo N3** (Bridge Contract):

1. Check that relayer is sender.
2. Hash deposit data and validate validator signatures OR check witness of validator multi-sig (probably unfeasible with current responsibilities).
3. Calculate new withdrawal hash.
4. Calculate new root.
5. Verify with provided root.
6. Transfer GAS to recipient address.

\* The validator node needs a specific rule for when to sign and send signatures to the relay node. The contract will support multiple deposits/withdrawals in a single transaction. If multiple bridge interactions (deposits or withdrawals) occur within a single block, the validator can concatenate their roots (in nonces order) and sign this concatenated value (i.e., the top root). Since a "batched" transaction cannot hold an unlimited size, the configuration on-chain holds a value `maxDeposits` (or `maxWithdrawals`, respectively) that define how many deposits can be sent in a batch. This leads to the current consensus of when and what to sign across validators:

Whenever there's a bridge operation in a block, the validators will create a signature of it. If there are multiple operations in a block, the validators will sign the root of the operation with the highest nonce (the top root). If there are more than the specified `maxDeposits` in a single block, the validators will sign the root of each `maxDeposits`' deposit. That way the validators "reach" consensus and provide signatures of the same root to the relayer.
