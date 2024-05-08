# Merkle Tree and Decoupled Relayer

## Merkle Tree

The bridging mechanism includes a Merkle Tree. In the following paragraphs, we will explain how it works.

When a GAS deposit is made to the origin chain's bridge smart contract, the received deposit data is hashed and appended as a new leaf to the Merkle Tree, resulting in updating of the Merkle Tree and recalculation of the Merkle Root. The deposit event that includes deposit data is then emitted by the bridge smart contract.

> **Note**:
>
> If the origin chain is N3, the GAS received will be locked in the contract. In contrast, if the origin chain is NeoX, the received GAS will be burned.

The Decoupled Relayer is responsible for taking the deposit data along with the Merkle Root and invoking the bridge smart contract on the destination chain. Upon invocation, the destination chain's bridge smart contract verifies the Merkle Tree based on the provided deposit data, Merkle Root, and proof (which is a list of existing hashes in the Merkle Tree that the Decoupled Relayer submits). If the verification is successful, the bridge smart contract updates the Merkle Root in storage and then executes either the minting or unlocking of GAS, based on the provided deposit data.

With this process, users and third parties can easily verify the authenticity of the bridging process by comparing the Merkle Root on the origin chain with the one on the destination chain.

## Decoupled Relayer

The process of computing the Merkle Tree, along with its root, takes place openly in the code on the originating chain, while the verification process is transparently executed on the receiving chain. Despite the reliability of these computations, transferring the correct Merkle Root from the origin chain to the destination chain requires actions to be taken outside the blockchain. To minimize risks and reduce potential avenues for malicious interference that could jeopardize the entire cross-chain system by compromising one part, the entity transferring the Merkle Root will be split into two distinct parts.

These two entities are a set of validators and a single relayer. Their responsibilities are as follows:

1. Validator
   * Listens for deposit events in the bridge smart contracts.
   * Hashes the deposit data and Merkle Root together.
   * Signs the hashed data.
   * Sends the deposit data, Merkle Root, transaction hash, and signature to the relayer.
2. Relayer
   * Receives the deposit data, Merkle Root, and signatures from the validators.
   * Verifies the deposit data and Merkle Root provided by the validators with the on-chain event data.
   * Validates the signatures using the deposit data and Merkle Root.
   * Triggers the mint/unlock function on the destination chain using the provided data and signatures.

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
   * Access to the mint/unlock function should be restricted to the relayer.
   * The mint/unlock function should only accept data that has been signed by at least five of the seven validators (5/7 multi-sig).







\
