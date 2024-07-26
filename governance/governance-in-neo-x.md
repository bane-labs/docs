# Governance in Neo X

This document covers the process of becoming a candidate node, the election process for candidate nodes to become consensus nodes, and the distribution of GAS token rewards in these processes.&#x20;

## How to Become a Candidate Node on Neo X?

To qualify as a candidate node on Neo X, the applicant should adhere to the following criteria:

* Hardware Requirements: The applicant’s infrastructure must meet the specified [hardware requirements](../development/running-a-node-in-testnet-1.md#hardware-requirements) for Neo X nodes. This includes ensuring compliance with machine maintenance standards and the establishment of a robust technical setup.
* Institutional Recognition: The applicant should represent an established organization or institution recognized within the market ecosystem.

Suitable applicants can proceed with the registration process by staking 1,000 GAS tokens through the Neo X governance interface. This deposit serves as a commitment to participation in the governance process.

Upon a normal node exit, the staked GAS tokens will be refunded to the applicant. A tentative locking period of approximately two weeks (equivalent to two Epochs, 120,960 blocks) is enforced to ensure the stability of the governance ecosystem.

## How to Become a Voter on Neo X?

All GAS token holders are eligible to vote on Neo X.

## The Consensus Node Election Process

Each election period, equivalent to an Epoch, spans approximately one week. From all candidate nodes, a total of seven nodes are elected as consensus nodes.

Any individual possessing GAS tokens on Neo X can participate in the election process by voting for their preferred consensus nodes. Votes are cast by staking any amount of GAS tokens (no less than 1 GAS) for only one candidate. The quantity of GAS tokens staked determines the voting power and influence in the reward amount this voter will receive if the candidate is elected.

Once the voting period concludes, the result will be settled immediately.

## Rewards and Penalties for Nodes

All transaction fees accrued during each Epoch will be evenly split among the seven consensus nodes hosting the period.

<figure><img src="https://miro.medium.com/v2/resize:fit:1225/0*iVSA4MrcuEXWbJXk" alt=""><figcaption></figcaption></figure>

Additionally, rewards obtained by the consensus nodes are distributed between the nodes themselves and the voters who have supported them. The distribution ratio (for instance, 50%) is determined at node registration as a candidate and remains fixed until its node exits.

Furthermore, the portion of rewards allocated to the voters is distributed based on their voting weight, which is determined by the amount of GAS tokens they have staked for voting.

_voterReward=(totalNetworkGasTip/7)\*distributionRatio\*(voteAmount/totalVote)_

The penalties for non-performing consensus nodes are yet to be determined. Wrongdoings may include but are not limited to, being unable to meet dBFT block production conditions or complete the Anti-MEV decryption key distribution. Penalties may include, but are not limited to, being prohibited from becoming a block-producing or witness node for a certain period, or the deduction of deposits upon node exit. Additionally, they may be prohibited from becoming a candidate node again. These measures will be specified in the Neo X governance contract in the future.

In the early stages of multi-node governance on Neo X, we anticipate a potential shortage of candidate nodes on the Neo X. To ensure network operation, we have designated seven standby consensus nodes to operate during this kick-off phase. Once there are at least seven qualified candidate nodes and the total voted GAS token number exceeds 3 million within one Epoch, the seven standby consensus nodes will be replaced by the seven elected nodes at the conclusion of the Epoch. This transition marks the beginning of full decentralized governance.

If either the number of candidate nodes or the voted GAS token drops below the criteria specified above, or if the result of the governance vote is invalid, the seven standby nodes will temporarily take over to maintain governance stability and network safety.
