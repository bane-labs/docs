# Hash Chain and Decoupled Relayer

## Hash Chain

The bridging mechanism includes a Hash Chain. For each token and both directions (deposits `Neo N3 -> Neo X`, and withdrawals `Neo X -> Neo N3`) a separate hash chain is maintained that is extended with every `bridge operation` (deposit/withdrawal).

Each hash chain starts with an initial root of `0x00...` (32 bytes). A hash chain is extended by hashing together the current root with the hash of the next incoming deposit data. Whenever a token is deposited on the bridge contract on Neo N3 (or withdrawn on Neo X), the sender needs to provide an amount and a recipient on the destination chain. This data is then hashed together with the incremented nonce and the token hashes of both chains. This is referred to as the `deposit hash`. The new root of the hash chain is then computed by hashing the deposit hash with the current root of the hash chain. Once these computations are done, an event is emitted that contains the deposit data, its hash and the new root.

> The hash chain of the native Gas token is slightly different. Instead of including token hashes in its deposit data, a deposit hash for Gas is just computed with its nonce, the amount and the recipient.

By invoking such a bridge operation, the hash chain is updated as explained and the received tokens are locked in the bridge contract.

The Decoupled Relayer is responsible for taking the deposit data along with the root and invoking the bridge smart contract on the destination chain. Upon invocation, the destination chain's bridge smart contract verifies the new root based on the provided deposit data and the current root. If the verification is successful, the bridge smart contract updates the root in storage and then executes the transfer of the tokens based on the provided deposit data.

With this process, users and third parties can easily verify the authenticity of the bridging process by comparing the root on the origin chain with the one on the destination chain.

## Decoupled Relayer

The process of computing the Hash Chain, along with its root, takes place openly in the code on the originating chain, while the verification process is transparently executed on the receiving chain. Despite the reliability of these computations, transferring the correct root from the origin chain to the destination chain requires actions to be taken outside the blockchain. To minimize risks and reduce potential avenues for malicious interference that could jeopardize the entire cross-chain system by compromising one part, the entity transferring the root will be split into two distinct parts.

These two entities are a set of validators and a single relayer. Their responsibilities are as follows:

1. Validator
   * Listens for deposit events in the bridge smart contracts.
   * Computes the new root of the hash chain on the basis of the current root.
   * Signs the new root.
   * Sends the deposit data, the new root, and its signature to the relayer.
2. Relayer
   * Receives the deposit data, the new root, and the signatures from the validators.
   * Verifies the deposit data and the new root provided by the validators with the on-chain event data.
   * Validates the signatures using the deposit data and the new root.
   * Triggers the corresponding distribution function on the bridge contract on the destination chain using the provided data and signatures.

Further properties of the parties involved are as follows:

1. Validator
   * Operates autonomously, with no interaction or knowledge of other validators' info.
     * No shared IP addresses.
     * No shared blockchain addresses.
     * No shared locations.
   * Under no circumstances should a validator submit transactions on-chain through the peer-to-peer network.
2. Relayer
   * Functions as a load balancer with at least two relayers to ensure continuous availability.
3. Smart Contract
   * Access to the distribution functions should be restricted to the relayer.
   * The distribution functions should only accept data that has been signed by at least five of the seven validators (5/7 multi-sig).
