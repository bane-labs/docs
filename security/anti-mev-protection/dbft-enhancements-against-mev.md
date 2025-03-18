# dBFT Enhancements Against MEV

Neo X's enhanced **Delegated Byzantine Fault Tolerance (dBFT)** introduces a **PreCommit** phase to enforce fair transaction ordering and eliminate MEV risks.

## Consensus Flow with Envelopes

1. **PrepareRequest** and **PrepareResponse**: Consensus nodes propose and confirm a preliminary block structure containing Envelope transactions.
2. **PreCommit Phase**: Consensus nodes collaboratively decrypt the encrypted transactions before finalizing the block.
3. **Commit Phase**: The decrypted transactions replace the Envelopes, ensuring they are executed fairly and securely.

This ensures that:

* Transactions are ordered before they are decrypted.
* Malicious actors cannot front-run or reorder transactions.
* The block signature is only applied after transactions are finalized.

## Conclusion

Neo X's Anti-MEV solution provides a robust mechanism to protect users from MEV attacks. By integrating **threshold encryption**, **decentralized key generation**, and **enhanced dBFT consensus**, it ensures fair transaction ordering and confidentiality.

