# JSON-RPC API

Neo X is in sync with most [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/) methods, but there are some differences to note:

* `eth_chainId` — returns the chain ID of Neo X.
* `eth_hashrate` — returns `0x0` by default.
* `eth_coinbase` — returns the `GovReward` contract address.
* `eth_gasPrice` — returns the maximum value of the current network GAS price and the lowest allowed GAS price by Neo X Policy.
* `eth_maxPriorityFeePerGas` — returns an estimated value of priority fee to get a transaction allowed by Neo X Policy and in the current block.
* `eth_getUncleByBlockHashAndIndex` — returns `null` by default.
* `eth_getUncleByBlockNumberAndIndex` — returns `null` by default.
* `eth_getUncleCountByBlockHash` — returns `0` by default.
* `eth_getUncleCountByBlockNumber` — returns `0` by default.
