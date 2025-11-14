# Bridging Transparency and Verifiable Relaying

Our bridge uses per-token, per-direction hash chains to make all validator and relayer actions transparent and independently verifiable. This applies to both token bridging and arbitrary message bridging:

* Each registered token pair maintains its own hash chain for:
  * Deposits (N3 → Neo X)
  * Withdrawals (Neo X → N3)
* The message bridge maintains a separate hash chain for each direction.

This means there is _not_ a single global hash chain — there are many independent chains, each proving the ordered history of operations of that individual bridge.

> For example, if there are 2 tokens registered, then there are 4 independent hash chains maintained in the TokenBridge contract: token #1 deposits, token #1 withdrawals, token #2 deposits, and token #2 withdrawals. Meanwhile, the MessageBridge maintains 2 hash chains — 1 hash chain per direction.

## How the Hash Chains Work

Each hash chain begins with a fixed root (`0x00...00`, 32 bytes). For every incoming bridge operation — whether token or message — the corresponding bridge contract constructs an operation hash from:

* the operation's nonce
* the operation's context
  * for tokens: token identifiers
  * for messages: message-specific metadata (i.e., type, timestamp, sender)
* the operation's request data:
  * for tokens: amount, recipient
  * for messages: the provided raw bytes

> The token bridge for native GAS on Neo X is managed as a special case as it does not involve any contract address on Neo X. Therefore, the hash chain for this token bridge omits the token identifiers.

The new hash-chain root is then computed as:

`newRoot = keccak256(currentRoot || operationHash)`

where `||` denotes concatenation.

The contract then emits an event containing:

* the operation data: nonce, payload (and metadata),
* the operation hash,
* the new root.

## Source-Chain Processing: The Smart Contract as the Truth-Teller

For each bridge identity (token A, B, message, etc.) the corresponding bridge contract (TokenBridge or MessageBridge) maintains the **authoritative state** for that direction:

* the **current nonce**, and
* the **current hash-chain root**.

### Token Deposit and Withdrawal Handling on the Source Chain

For token operations, the bridge contract applies the underlying token transfer logic **before** updating the hash-chain state:

* **Token deposits (N3 → Neo X)**:
  The user pays the required **GAS fee**, and the requested tokens are **transferred into and locked within** the TokenBridge contract on Neo N3.
* **Token withdrawals (Neo X → N3)**:
  The user pays the required **GAS fee** (attached as _`msg.value`_), and the requested tokens are **transferred into and locked within** the TokenBridge contract on Neo X as part of initiating the withdrawal request.

Only after these transfer steps succeed does the contract proceed with:

1. **Incrementing the nonce**,
2. **Computing the new hash-chain root** using the previous root and the operation hash,
3. **Overwriting the stored state** with the new `(nonce, root)` pair,
4. **Emitting an event** containing the operation data, the operation hash, and the new root.

This on-chain computation is the **canonical source of truth**.

Validators do not invent or interpret roots — they only read and verify what the contract already computed.

## Validator Reconstruction and Attestation

Validator nodes monitor the source chain for these events. For each observed operation, a validator:

1. **Reads** the event emitted by the smart contract.
2. **Reconstructs** the operation hash and new root locally using the same deterministic hashing rules.
3. **Compares** its reconstructed root with the value produced by the contract.

Only if the reconstructed root **exactly matches** the on-chain root does the validator proceed.

### Decoupled Validator & Relayer Architecture (Summary)

The bridging system separates responsibilities between **validators** and **a relayer** to minimize trust assumptions, reduce attack surface, and ensure that validators never need to submit transactions on-chain.

* **Validators** independently observe source-chain events, reconstruct the hash-chain state, and sign the new top root only if it matches the value computed by the source-chain contract. They operate autonomously, do not coordinate with one another, and — critically — **never broadcast transactions or interact with blockchains beyond reading events**. Their sole responsibility is to attest to what they have observed.
* The **relayer** collects these signed batches from validators, aggregates enough signatures to meet the threshold, and submits a relay transaction to the destination chain. The relayer does not verify correctness itself; all verification and enforcement happen inside the bridge contracts via deterministic hash-chain reconstruction and threshold signature validation.

This separation ensures that validators cannot influence on-chain execution, and the relayer cannot forge or alter cross-chain state. Together, these roles create a robust, trust-minimized architecture where correctness is guaranteed by the smart contracts, not by assumptions about the behavior of off-chain actors.

### Signed Batches and What Validators Actually Sign

Once a validator has confirmed that its locally reconstructed root matches the root computed and stored by the contract, it does **not** sign each individual operation. Instead, the validator:

1. Continues processing all new bridge operations in order, updating its local view of:
  a. the current nonce, and
  b. the current hash-chain root.
2. When it is time to produce a signature (e.g., at the end of a block or after some fixed number of operations), it **signs only the latest/top root**.

Along with this signature, the validator provides the relayer with a **batch of payloads** that led to this top root. This is referred to as a **signed batch**:

* the **signature** is over the top root value
* the **batch** contains all bridge operations that were applied to reach that root (e.g., all 10 deposits in a block, with their nonces and payloads).

In other words, the validators sign the **final state commitment** (top root), and accompany it with the **full ordered list of operations** that explain how they got there.

If at any point a validator's reconstructed root does not match the on-chain root, the validator:

* detects this as a critical inconsistency,
* **stops processing any new incoming bridge events** for that specific bridge direction, and
* refrains from producing any further signatures for that instance to avoid propagating incorrect state.

## Relayer Aggregation and Submission

The relayer receives these signed batches from multiple validators. For a specific token direction or message direction, it:

1. Collects signatures over the same top root (and corresponding nonce),
2. Ensures that it has enough signatures to meet the threshold required by the **BridgeManagement** contract on the destination chain,
3. Constructs a **relay transaction** that includes:
  
    * the signed top root,
    * the list of all operations in the batch (their nonces, payloads, and any metadata),
    * the aggregated validator signatures.

The relayer's job is strictly for transport and aggregation. It does not need to trust or interpret state — correctness will be fully enforced on-chain.

## What Happens on the Destination Chain

When the relayer submits a signed batch to the destination chain, the bridge contract must determine whether the batch represents a valid continuation of the hash chain for that specific bridge direction. To do this, the contract performs a series of strict checks that ensure ordering, integrity, and validator consensus before any state is updated or any token or message effects are applied.

### 1. Verify Sequential Nonces

the bridge contract reads its currently stored last nonce for the given token direction or message direction and checks that all payloads in the batch are **strictly consecutive**:

```text
payload[0].nonce == lastNonce + 1
payload[1].nonce == lastNonce + 2
...
payload[n-1].nonce == lastNonce + n
```

If there is any gap, duplicate, or non-monotonic increment, the entire batch is rejected.

### 2. Recompute the New Top Root

Using the contract's current stored `lastRoot`, the bridge contract iterates through the batch and reconstructs the next root:

```text
currentRoot = lastRoot
for each payload:
  operationHash = keccak256(payload)
  currentRoot = keccak256(currentRoot || operationHash)
```

The final `currentRoot` is the expected **new top root**.

### 3. Compare the Recomputed Root With the Provided Top Root

The bridge contract checks:

```text
reconstructedRoot == providedRoot
```

If these differ, the batch is rejected immediately.

This ensures the batch exactly reflects the state that validators attested to.

### 4. Verify Validator Signatures (via BridgeManagement)

Only after verifying:

* nonce progression
* root reconstruction
* root consistency

does the bridge contract invoke **BridgeManagement** to verify validator signatures.

The BridgeManagement performs a simple threshold signature check. It does not inspect payloads, roots, or nonces — it only verifies whether enough validators signed the provided message.

The bridge contract defines the exact message that must be signed (the new root). Validators sign this message only after confirming it matches the source-chain contract's result. The relayer forwards these signatures, and the BridgeManagement simply checks whether a sufficient number of validators have signed the expected message. If the threshold is met, signature validation succeeds; otherwise, the batch is rejected.

## Verifying Authenticity Across Chains

This design makes the entire bridging process transparent and independently verifiable. Because each token direction and message direction maintains its own strictly ordered hash chain, an external observer only needs two pieces of information to validate the full bridging history:

* the **top nonce** for that bridge direction, and
* the **top root** stored on each chain.

For any bridge identity (token A deposits, token B withdrawals, message N3 → Neo X, etc.), the source-chain contract emits and stores the definitive (nonce, root) after every operation. The destination-chain bridge contract will only update its own (nonce, root) to match this value if:

* all intermediate payloads were provided,
* nonces progressed strictly one-by-one,
* the reconstructed root matches exactly the validator-signed root, and
* enough validators signed that root according to the threshold.

The result is simple but powerful:

> **If the top nonce and top root for a given bridge direction match on both chains, the entire bridging history is guaranteed to match as well.**
> Any deviation at any point — skipped operation, tampered payload, reordered event, faulty signature — would cause the roots to diverge permanently.

No trusted off-chain audit is required. Anyone can independently reconstruct the hash chain from on-chain events, recompute the sequence, and verify that both chains reflect the same authenticated history.

This property ensures that correctness, transparency, and integrity are not assumptions — they are cryptographically enforced guarantees rooted in the smart contracts themselves.

### Note on Historical Hash-Chain Changes

Earlier versions of the bridge contracts used **SHA-256** for computing operation hashes and hash-chain roots, because **keccak256 was not yet available on Neo N3** at the time the initial TokenBridge contract was deployed. Since both chains must always use the same hashing algorithm to reproduce the hash chain deterministically, the Neo X contracts used SHA-256 as well.

Once keccak256 became available on N3, the bridge contracts on **both chains** were upgraded and the hashing algorithm was unified to **keccak256**.

This means:

* hash-chain roots before the upgrade were derived using SHA-256,
* and all roots produced after the upgrade use keccak256.

The transition was performed as part of a contract upgrade. From that point onward, both chains have used the same keccak256-based hashing logic. The verification process described in this document is identical for both versions; the only difference is which hash function is applied for a given historical range.
