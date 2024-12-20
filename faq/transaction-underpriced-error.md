# Transaction Underpriced Error

This error usually happens when the transaction's specified fee does not satisfy the minimum network requirements for execution.

On **Neo X**, transaction fees are composed of two parts: the **base fee**, which is burned, and the **gas tip**, which serves as an incentive distributed to governance nodes and voters. The **base fee** is fixed and independent of transaction volume. The **gas tip** is user-defined and can be adjusted. However, the Neo X network policy mandates a minimum value (20 gwei) for the gas tip. Transactions that do not meet the minimum gas tip requirement will be rejected.

According to **EIP-1559**, users determine their desired gas tip (**gasTipCap**) and the total fee they are willing to pay (**gasFeeCap**). The gas fee cap must cover both the **base fee** and the **gas tip**.

If the **gasTipCap** is too low, the transaction will be flagged as underpriced. Similarly, if the **gasFeeCap** is insufficient, the transaction will fail.

#### Error Context

```
- server returned an error response: error code 
-32000: transaction underpriced: policy minGasTipCap needed 20000000000, baseFee needed 20000000000, gasTipCap 1, gasFeeCap 40000000001
```

* **minGasTipCap**: The minimum gas tip (priority fee) required by the network.
* **baseFee**: The network base fee. Currently it is 20 gwei for Neo X.
* **gasTipCap**: The user-specified priority fee offered to incentivize miners or validators.
* **gasFeeCap**: The total fee the user is willing to pay, which covers both the base fee and gas tip.

#### Solution

To resolve this issue, ensure that the transaction fees meet the following conditions:

* gasTipCap >= minGasTipCap (e.g., 20 gwei for Neo X).
* gasFeeCap >= baseFee (e.g., 20 gwei) + minGasTipCap.
