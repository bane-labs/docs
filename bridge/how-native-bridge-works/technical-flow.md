# Technical Flow

Here is a breakdown of the technical steps involved in transferring GAS between Neo N3 and Neo X.

## **Bridge GAS from Neo N3 to Neo X**

**Neo N3：**

1. Send GAS to Bridge Contract including valid data (recipient address on Neo X).
2. Bridge Contract on-chain:
   1. Validate the data.
   2. Increment nonce.
   3. Calculate the new leaf hash (including `nonce, recipient, amount`).
   4. Calculate the new Merkle Root (and update complete subtrees in storage in the process).
   5. Set the new Merkle Root.
   6. Send GAS to treasury.
   7. Emit the event with `nonce, from, recipient, amount, Deposit Hash, Merkle Root.`

**Validators:**

1. Listen and notice new deposit event.
2. Sign Merkle Root and send signature to relayer node.

**Relayer:**

1. Receive the transaction hash and signature from validators.
2. Validate the signatures with event data, based on application log of transaction.
3. Collect 5 signatures for this event (5 = threshold of validator multi-sig).
4. Invoke Neo X Bridge Contract with provided validator signatures, deposit data, and Merkle Root.

**Neo X** (Bridge Contract):

1. Check that relayer is sender.
2. Hash the deposit data and validate the validator signatures.
3. Calculate the new leaf hash.
4. Calculate the new Merkle Root (and update complete subtrees in storage in the process).
5. Verify with provided Merkle Root.
6. Mint GAS(erc20) for recipient address.
7. Emit the mint event.

## **Bridge GAS from Neo X to Neo N3**

**Neo X:**

1. Send GAS(erc20) to Bridge Contract including valid data (recipient address on N3).
2. Bridge Contract on-chain:
   1. Validate the data.
   2. Increment nonce.
   3. Calculate the new leaf hash (including `nonce, recipient, amount`).
   4. Calculate the new Merkle Root (and update complete subtrees in storage in the process).
   5. Set the new Merkle Root.
   6. Burn GAS(erc20).
   7. Emit the event with `nonce, from, amount, Withdrawal Hash, Merkle Root`

**Validators:**

1. Listen and notice new withdrawal event.
2. Sign Merkle Root and send the signature to relayer node.\*

**Relayer:**

1. Receive the transaction hash and signature from validators.
2. Validate the signatures with event data, based on application log of transaction.
3. Collect 5 signatures for this event (5 = threshold of validator multi-sig).
4. Invoke N3 Bridge Contract with provided validator signatures, withdrawal data and Merkle Root.

**Neo N3** (Bridge Contract):

1. Check that relayer is sender.
2. Hash deposit data and validate validator signatures OR check witness of validator multi-sig (probably unfeasible with current responsibilities).
3. Calculate new leaf hash.
4. Calculate new Merkle Root (and update complete subtrees in storage in the process).
5. Verify with provided Merkle Root.
6. Transfer GAS to recipient address.

\* The validator node will need to set specific rules for when to sign and send signatures to the relay node. The contract will support multiple deposits/withdrawals in a single transaction. If multiple bridge interactions (deposits or withdrawals) occur within a short period of time, the validator can concatenate their roots (in nonces order) and sign this concatenated value. In order to support this with the decoupled relayer, some limits need to be set for the verifier nodes, such as how many blocks need to wait for further deposits (e.g., all n blocks) before creating a signature, or how many deposits/withdrawals need to be signed at once - a limit will be set in the contract on the number of certificates that can be provided per transaction.
