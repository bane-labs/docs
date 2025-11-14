# General Bridge Mechanism

A cross-chain bridge is a software protocol that allows for the smooth transfer of data and/or assets between different blockchain networks. The transfer of data can be regarded as messages moving from one chain to another. These messages may include specific actions that facilitate the transfer of crypto assets, the invocation of contracts or simply writing data to the other chain.

In the context of Neo X, this project aims to bridge:

* From **Neo N3** to **Neo X** (_N3->NeoX_);
* From **Neo X** to **Neo N3** (_NeoX->N3_);

For both directions it supports bridging tokens and arbitrary messages.

In the following sections we will elaborate on the approach to bridging, the architecture, the roles with their responsibilities, and the involved smart contracts.
