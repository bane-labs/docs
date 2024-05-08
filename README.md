# Overview

## About the Document

This document provides the information based on the beta version of Neo X TestNet. It will be updated continuously to align with the evolving development version of Neo X.

## What is Neo X?

Neo X is an EVM-compatible sidechain incorporating Neo's distinctive dBFT consensus mechanism. Serving as a bridge between Neo N3 and the widely used EVM network, Neo X will play a crucial role in expanding the Neo ecosystem and offering developers more opportunities for innovation.

## Main Features

### **Early Stage of Multi-Node Governance in Neo X**

Leveraging the dBFT consensus mechanism, Neo X employs a multi-node governance system. Seven consensus nodes collaboratively process transactions on-chain and participate in voting to determine parameters on the Neo X blockchain, such as blacklisted addresses and minimum required GAS tip.

The decision-making process for consensus nodes to manage on-chain parameters through voting will be incorporated in future versions or updates. For more information about the complete Neo X governance system, see [Governance](broken-reference).

### **Bridge Between Neo X TestNet and Neo N3 TestNet**

Neo X supports for bidirectional token transfers between Neo X (EVM) and Neo N3 (NeoVM). Key features include:

* **Bidirectional Bridging of Assets**: Seamless movement of $GAS between networks, improving liquidity and flexibility.
* **Enhanced Stability and Security**: Upgrades to bridge validators and relayers, along with the introduction of a new role management model to fortify security measures in the bridge smart contracts. For example, the “Security Guard” role can pause bridge operations as needed, while the “Governor” role is empowered to resume operations, as well as propose and update bridge parameters.
* **Bridge Upgradability**: Consensus nodes on the Neo X chain can now propose and implement bridge upgrades, ensuring that the bridge evolves in alignment with the community’s needs.
* **Token Support**: We have laid the groundwork to include NEP-17 and ERC-20 tokens, such as NEO token, in future versions of the bridge.

\
