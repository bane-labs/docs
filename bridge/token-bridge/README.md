# TokenBridge

The TokenBridge is the on-chain component responsible for securely transferring tokens between Neo N3 and Neo X. It processes token deposits and withdrawals, locks or releases assets accordingly, and maintains a per-token, per-direction hash chain that records the ordered history of all token-bridging operations.

Each token direction (N3 → Neo X and Neo X → N3) has its own independent `(nonce, root)` state. This state provides a verifiable cryptographic commitment to all operations processed in that direction. Validators observe these events, reconstruct the hash-chain state, and attest to the new top root, enabling the relayer to submit authenticated batches to the destination chain.

By enforcing deterministic hash-chain reconstruction and requiring validator threshold signatures, the TokenBridge ensures that all token transfers across chains occur transparently, securely, and without relying on any trusted off-chain party.
