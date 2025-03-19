# Threshold Encryption and DKG

## Decentralized Key Generation (DKG)

The DKG mechanism in Neo X enables a fully decentralized key generation process among consensus members. Before each epoch change, the upcoming consensus group must successfully complete a DKG round to establish a new threshold public-private key pair. This process ensures that no single participant controls the decryption or signing capabilities.

### DKG Process

Each DKG round consists of three key steps:

1. **Share** – The next consensus group generates $$n$$ distributed secret shares and a global public key, where $$n$$ is the number of Neo X consensus nodes.
2. **Reshare** – The current consensus group (if available) transfers the previous round’s secret to the next group.
3. **Recover (Optional)** – If up to $$f$$ secret shares are lost, the remaining $$2f+1$$ shares reconstruct the secret to complete the transition.

Starting from [**v0.3.0**](https://github.com/bane-labs/go-ethereum/releases/tag/v0.3.0), the DKG module automates the entire process, except for setting up the initial Anti-MEV keystore with a secret passphrase.

#### Share **Phase**

Each participant executes the following steps:

1.  Take a random polynomial $$f(x) = a_0 + a_1x + a_2x^2 + \dots + a_{t-1}x^{t-1}$$ as their local secret, where $$t = 2f+1$$ (the threshold for consensus).
2. Compute $$f_1,f_2,...,f_n$$ where $$f_i=f(i)$$ and share them with corresponding participants, where $$i$$ is the index of different participants of `Share`.
3. Accept all $$f_i$$ from other participants as $$f_1(i),f_2(i),...,f_n(i)$$, where $$i$$ is the index of receiver, and compute $$s_i=\sum f_i$$ to get the final secret key.

#### **Generating the Global Public Key**

The global public key is generated using Publicly Verifiable Secret Sharing (PVSS):

1. Each participant uploads $$F(x)=f(x)G_1$$ within his PVSS to the [KeyManagement](../../governance/neo-x-system-contracts.md#keymanagement) contract.
2. The contract verifies each PVSS and computes $$S=\sum_{i=1}^n F_i(0)$$ as the global public key.

A well-constructed PVSS includes:

* $$F(x)=f(x)G_1$$ as the sender’s local secret commitment.
* $$rG_1,rG_2$$ as a pair of commitments for a random scalar $$r$$.
* $$F=(F(1),F(2),...,F(n))$$ as the commitment share messages.

The KeyManagement contract validates $$F(1),F(2),...,F(n)$$, and verifies scalar $$r$$. Recipients validate their received shares using $$e(r_1f(i),g_2)=e(F(i),r_2)$$.

{% hint style="info" %}
**Future Enhancement:** Zero-Knowledge Proofs (ZKPs) will be integrated to enhance encryption verification.
{% endhint %}

#### **Reshare Phase**

Each participant executes the following steps:

1.  Regenerate his local secret $$f'(x)=a_0+a'_1 x+a'_2 x^2+ \dots +a'_{t-1}x^{t-1}$$ while preserving the constant term $$a_0$$.
2. Follow the step 2 and 3 in the **Share** phase, but send the shares to the next consensus group.

The KeyManagement contract ensures $$F(0)=F'(0)$$, preserving the global public key unchanged and preventing leakage of the original secret shares.

#### **Recover Phase (Optional)**

If some secret shares are lost, the remaining consensus members help restore them:

1. The current consensus group forwards all received shares $$f_i$$ from the lost index $$i$$ to its successor.
2. The recipient reconstructs the original local secrets using [**Lagrange interpolation**](https://en.wikipedia.org/wiki/Lagrange_polynomial).

> **Security Note**: `Recover` exposes at most $$f$$ of the original secrets, so it is only allowed when the index $$i$$ is confirmed absent from `Reshare`.

## Threshold Public Key Encryption (TPKE)

Neo X's DKG enables a Threshold Public Key Encryption (TPKE) scheme, ensuring that encrypted transactions can only be decrypted if at least $$2f+1$$ consensus nodes cooperate. This mechanism is crucial for preventing premature exposure of transaction details.

Neo X TPKE utilizes the BLS12-381 curve, encoding any secret to $$G_1$$ for encryption and any message to $$G_2$$ for signature generation.

### Encryption

For a given secret message $$msg$$, the encryption process follows these steps:

1.  A random point $$G_1$$ point $$P$$ is chosen as a seed to generate an AES key. The encrypted ciphertext is computed as $$C_1=AES(Hash(P), msg)$$.
2.  To ensure security, a random scalar $$r$$ is selected to encrypt $$P$$ as $$C_2=P+rS$$

    where:

    * $$r$$ is a random scalar,
    * $$S$$ is the global public key.
3. The final encrypted message $$C$$, which is broadcasted across the network, consists of $$C=(C_1,C_2)$$.

### **Decryption**

To recover the original $$msg$$, the Neo X consensus network must decrypt $$C_1$$ to recover $$P$$. The decryption process follows:

1. Each CN computes and shares $$s_iR$$, where:
   * $$R$$ is the commitment of the random scalar $$r$$,
   * $$s_i$$ is the local secret key.
2. Since validator indices (DKG indices) are publicly known within Neo X Governance, these shares can be aggregated and solved using a [**Vandermonde matrix**](https://en.wikipedia.org/wiki/Vandermonde_matrix).
3. Once the seed $$P$$ is recovered, the original message $$msg$$ can be decrypted using AES.

### Signature

For a given message $$msg$$, Neo X generates a signature through the following process:

1. The message is encoded to $$G_2$$ as $$Q=HashToG2(msg)$$
2. A signature share is computed as $$s_iH$$ where $$s_i$$ is the local secret key.
3. After collecting enough broadcasted shares, CNs aggregate and get the final signature with [Vandermonde matrix](https://en.wikipedia.org/wiki/Vandermonde_matrix) in the same way as TPKE decryption.
