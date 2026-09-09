# MessageBridge

The MessageBridge enables the secure relay of arbitrary data between Neo N3 and Neo X. Instead of transferring tokens, it transports raw message payloads submitted by contracts or users, while preserving ordering, authenticity, and verifiability.

As with the TokenBridge, each message direction (N3 → Neo X and Neo X → N3) maintains its own independent hash chain. Every message extends this chain, producing a new `(nonce, root)` commitment that validators reconstruct and sign. These signed commitments allow the relayer to submit authenticated message batches to the destination chain, where they are verified and persisted.

Through its hash-chain mechanism and validator-attested batches, the MessageBridge provides the same security guarantees for arbitrary data as the TokenBridge provides for token transfers. This ensures that cross-chain messaging remains transparent, ordered, and cryptographically verifiable.

The following sections and [Neo X's bridge SDK](https://github.com/bane-labs/bridge-sdk-ts) will help you to understand and build with this unique infrastructure step by step.
For more detailed examples, please refer to the [MessageBridge Examples Repository](https://github.com/AxLabs/bridge-examples-ts).
