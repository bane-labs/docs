# Anti-MEV Protection

**Maximal Extractable Value (MEV)** refers to the strategies employed by miners or validators to manipulate transaction order—by adding, removing, or reordering transactions—when producing new blocks. This practice has led to significant financial losses across the industry.

To address the adverse effects of malicious MEV on transaction fairness and network efficiency, **Neo X** introduces an advanced **Anti-MEV** mechanism. This solution is designed to mitigate malicious transaction reordering and front-running attacks, ensuring a more secure and equitable transaction process.

The Anti-MEV mechanism in Neo X is built upon:

* **Decentralized Key Generation (DKG)**: Ensures a trustless and distributed key generation process.
* **Threshold Encryption (TPKE)**: Enables secure transaction confidentiality.
* **Enhanced dBFT Consensus Algorithm**: Implements a new pre-commit phase to maintain fair transaction ordering.

By leveraging **Envelope Transactions**, users can encrypt their transactions, ensuring that they are not exposed to MEV attacks during the consensus process.

The following sections and [Neo X's TPKE library](https://github.com/bane-labs/neox-tpke-lib) will help you to understand and build with this unique infrastructure.
