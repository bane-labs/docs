# Threshold Encryption and DKG

## Decentralized Key Generation (DKG)

The DKG mechanism in Neo X enables a fully decentralized key generation process among consensus members. Before each epoch change, the upcoming consensus group must successfully complete a DKG round to establish a new threshold public-private key pair. This process ensures that no single participant controls the decryption or signing capabilities.

### DKG Process

Each DKG round consists of three key steps:

1. **Share Phase**: The new consensus group generates secret shares and a global public key.
2. **Reshare Phase**: The current consensus group (if any) passes its secret shares to the next group.
3. **Recovery Phase** (optional): If some secret shares are lost, the remaining shares can reconstruct the missing values using Lagrange interpolation.

Once the DKG process is completed, the new consensus group is ready to securely process transactions using threshold encryption and signing.

## Threshold Public Key Encryption (TPKE)

Neo X's DKG enables a **Threshold Public Key Encryption (TPKE)** scheme, ensuring that encrypted transactions can only be decrypted if at least **2f+1** consensus nodes cooperate. This mechanism is crucial for preventing premature exposure of transaction details.

### Encryption Process

1. A transaction payload is encrypted using an ephemeral AES key.
2. The AES key is encrypted using the threshold public key and embedded into the transaction.
3. The encrypted transaction (Envelope) is submitted to the network.

### Decryption Process

1. During block finalization, consensus nodes collectively contribute decryption shares.
2. Once at least **2f+1** shares are available, the transaction payload is decrypted and executed.
3. This ensures transactions remain confidential until they are irreversibly ordered in the block.
