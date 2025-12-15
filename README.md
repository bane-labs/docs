# Overview

## What is Neo X?

Neo X is an EVM-compatible sidechain incorporating Neo's distinctive dBFT consensus mechanism. Serving as a bridge between Neo N3 and the widely used EVM network, Neo X will play a crucial role in expanding the Neo ecosystem and offering developers more opportunities for innovation.

## Main Features

### dBFT Governance

Leveraging the dBFT consensus mechanism, Neo X employs a multi-node governance system. Seven consensus nodes collaboratively process transactions on-chain and participate in voting to determine parameters on the Neo X blockchain, such as blacklisted addresses and minimum required `GAS` tip.

For the initial period following Mainnet launch, the Neo X network is going to be driven by StandBy validators to ensure consensus process stability and proper network connectivity. StandBy nodes are implemented to participate in the consensus process when there are not enough candidates elected by the network users, or there are not enough votes collected to start the elected governance management. For more information about the complete Neo X governance system, see [Governance](/governance/governance-in-neo-x.md).

### Ethereum Virtual Machine compatibility

The Neo X Mainnet node version is based on the v1.15.11 Geth node implementation with the Prague hardfork supported as the latest one from the list of newly-added Ethereum forks. In other words, Neo X node is fully compatible with all Ethereum VM features up to the [Prague](https://github.com/ethereum/execution-specs?tab=readme-ov-file#ethereum-execution-client-specifications) fork.

### **Bridge Between Neo X and Neo N3**

Neo X supports for bidirectional token transfers between Neo X (EVM) and Neo N3 (NeoVM). Key features include:

* **Bidirectional Bridging of Assets**: Seamless movement of `GAS`between networks, improving liquidity and flexibility.
* **Enhanced Stability and Security**: Upgrades to bridge validators and relayers, along with the introduction of a new role management model to fortify security measures in the bridge smart contracts. For example, the “Security Guard” role can pause bridge operations as needed, while the “Governor” role is empowered to resume operations, as well as propose and update bridge parameters.
* **Bridge Upgradability**: Consensus nodes on the Neo X chain can now propose and implement bridge upgrades, ensuring that the bridge evolves in alignment with the community’s needs.
* **Token Support**: We have laid the groundwork to include NEP-17 and ERC-20 tokens, such as `NEO` token, in future versions of the bridge.
