# dBFT Enhancements Against MEV

Neo X's enhanced Delegated Byzantine Fault Tolerance (dBFT) introduces a `PreCommit` phase to enforce fair transaction ordering and eliminate MEV risks.

## Consensus Flow with Envelopes

1. Proposal and ordering phase
   * Envelope transactions are proposed as same as normal transactions in  `PrepareRequest`.
   * Transactions are ordered based on their gas price, thus Envelope transactions often be placed at the front due to additional decryption fees.
   * By the end of `PrepareResponse`, a `PreBlock` for the next block height is confirmed, finalizing the transaction order before decryption occurs. This prevents malicious reordering based on MEV insights.
2. Decryption phase
   * During the new `PreCommit` period, consensus nodes (CNs) identify Envelope transactions and broadcast decryption shares for them.
   * Once at least **2f+1** decryption shares are collected, the Envelope transactions are replaced with their decrypted inner transactions in the proposed block.
   * No view changes occur after this stage, ensuring decrypted transactions remain protected from MEV-based manipulation.
3. Commitment phase
   * CNs compute and broadcast signature shares for the finalized block proposal.
   * The block is committed and acknowledged by the network only when at least **2f+1** signature shares are collected.
   * The final block includes decrypted transactions instead of Envelopes, ensuring a transparent and MEV-resistant execution.

## Conclusion

Neo X's Anti-MEV solution provides a robust mechanism to protect users from MEV attacks. By integrating threshold encryption, decentralized key generation, and enhanced dBFT consensus, it ensures fair transaction ordering and confidentiality.

