# Envelope Transaction

To prevent MEV attacks, Neo X users can submit transactions within Envelope Transactions, ensuring their transactions remain encrypted until confirmed within the consensus process.

We've deployed a [LIVE Demo](https://neox-tpke-examples.pages.dev/examples/transfer) for Neo X Testnet T4. Have a try to send GAS or ERC-20 tokens with Envelope transactions and your Metamask.

## Envelope Structure

A valid Envelope transaction must meet the following criteria:

* The recipient address `to` must be `Neo X GovReward Contract (0x1212000000000000000000000000000000000003)`.
* The sender address `from` must match the inner secret transaction sender.
* The `nonce` must be identical to that of the inner secret transactions.
* The `gas tip` must exceed the network's `minGasTipCap` plus `envelopeFee`.
* The `data` field of the Envelope transaction must be formatted as follows:
  * A 4-byte prefix (`0xffffffff`).
  * A 4-byte DKG epoch index (big-endian).
  * A 4-byte inner secret transaction `gaslimit` (big-endian).
  * A 32-byte hash of the inner secret transaction.
  * A TPKE-encrypted ciphertext.

Here is an example of the `data` field of an Envelope transaction:

```
|  prefix  | epoch  | gaslimit |  inner secret transaction hash  |   TPKE ciphertext   |
|  4-byte  | 4-byte |  4-byte  |             32-byte             |        bytes        |
|0xffffffff|00000001| 00005208 |    777bbe0bb1e4c3...eff6fd15a   | 80f8c8c2...fa6a1810 |
```

In a nutshell, Envelopes are always calling the `fallback()` method of the Neo X GovReward contract. This method burns gas based on the declared `gaslimit` in `data` to allocate block space in Envelope execution, and it works with `eth_estimateGas` automatically.

## Steps to Send an Envelope Transaction

To send a secret transaction wrapped with an Envelope, we recommend the following steps which should be compatible with most of popular wallets (e.g. Metamask):

1. Construct a secret transaction;
2. Request the wallet to sign this transaction and send it to nodes configured with `--txpool.amevcache`;
3. Request the wallet to sign the `nonce` of the secret transaction as a message;
4. Use this signature to fetch the signed transaction through `eth_getCachedTransaction`;
5. Encrypt the signed transaction with Neo X TPKE;
6. Construct an Envelope transaction with the encrypted data and send it through wallet with the same `nonce`.

> **Note**: The node in step 2 always returns an RPC error to prevent the wallet nonce from increasing, so that we keep compatible with popular wallets e.g. Metamask. This is the expected behavior, so please follow steps 3 and 4 to verify the final result.

## **Envelope Transaction Verification**

In Neo X, Envelope transactions must first pass mempool, otherwise they cannot be decrypted or executed in the dBFT consensus process.

### **Verification Criteria**

* The sender has sufficient balance to cover the required gas fees.
* The `nonce` used in both the Envelope and its enclosed transaction is valid.
* The Envelope `gaslimit` does not exceed the `maxEnvelopeGasLimit` policy.

### **Execution Behavior**

* If the Envelope transaction passes verification, its encrypted contents will be decrypted and executed. Regardless of success or failure, the inner transaction will replace the Envelope transaction in the block space.
* If the Envelope transaction is invalid, fails decryption, or contains an invalid inner transaction:
  * It will either be rejected by the mempool or included in the next block without execution.
  * If included in a block, the designated gas for execution will be **burned**, ensuring users pay for the allocated block space even if the transaction is not processed.

### **Network Constraints**

Neo X enforces limits on both the number of Envelope transactions per block and their total gas consumption, as defined by the `maxEnvelopesPerBlock` and `maxEnvelopeGasLimit` policies. During periods of high network traffic, Envelope transactions may experience delays.

## RPC APIs

Neo X provides several new RPC APIs to facilitate the Envelpe construction. For more details, refer to [JSON-RPC API](../../development/json-rpc-api.md).
