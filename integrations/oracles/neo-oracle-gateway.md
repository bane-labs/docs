# Neo Oracle Gateway

Neo Oracle Gateway is the integration layer that gives Neo X smart contracts access to the native Oracle infrastructure on Neo N3.

Neo X currently relies mainly on price feeds, which do not cover broader data needs such as external event outcomes, off-chain metrics, and other general-purpose inputs required by many dApps.

With Neo Oracle Gateway, contracts on Neo X send requests through the message bridge, Neo N3 Oracles fetch the external data, and verifiable responses return on-chain to Neo X.

## Why It Matters and Use Cases

Decentralized applications require different kinds of off-chain data, including:

- Event outcomes
- Off-chain metrics
- Public APIs and external data providers

This requires a general-purpose oracle path on Neo X. Neo Oracle Gateway provides that path and supports use cases such as:

- Prediction markets
- Cross-ecosystem data verification
- Governance triggers based on external conditions
- Any dApp that depends on trusted off-chain information

## How It Works

Neo Oracle Gateway is powered by the [Message Bridge](../../bridge/messaging-bridge/).

The message bridge enables a request-response flow between Neo X and Neo N3:

1. A Neo X smart contract sends an oracle request through the Message Bridge.
2. The request is executed on Neo N3, where the native Oracle fetches external data.
3. The oracle result is returned through the Message Bridge.
4. The Neo X contract receives the response and continues execution.

## Watchtower Operation

The Watchtower is an off-chain service that monitors bridge-related transactions on both Neo N3 and Neo X chains.

It tracks nonces from bridge events, filters events by recipient address, and can execute transactions automatically in nonce order or run in watch-only mode.

### Features

- **Dual chain monitoring**: Monitors both Neo N3 and Neo X chains for bridge events.
- **Event types**: Monitors native deposits and withdrawals, token deposits and withdrawals, and message sends.
- **Recipient filtering**: Processes events only for configured recipient addresses.
- **Nonce tracking**: Tracks nonces per operation type and enforces sequential execution.
- **Watch-only mode**: Monitors events without executing on-chain transactions.
- **Execution mode**: Automatically executes transactions in nonce order.

While the Watchtower infrastructure can operate for any bridged message type, it currently only executes transactions triggered by Neo Oracle Gateway usage.

Watchtower on-chain operations (execution of bridged messages), are subsidized.

While the Neo Oracle Gateway can function independently, the Watchtower adds convenience and agility by handling message executions automatically, so users do not need to execute messages themselves.

## Repositories

- `oracle-proxy-neo`: [https://github.com/bane-labs/oracle-proxy-neo](https://github.com/bane-labs/oracle-proxy-neo)
- `oracle-proxy-evm`: [https://github.com/AxLabs/oracle-proxy-evm](https://github.com/AxLabs/oracle-proxy-evm)

## Deployments

Mainnet and testnet deployment addresses for Neo Oracle Gateway:

| Network | `oracle-proxy-neo` (Neo N3) | `oracle-proxy-evm` (Neo X) |
| --- | --- | --- |
| Mainnet | `0xMAINNET_NEO_CONTRACT_HASH_PLACEHOLDER` | `0xMainnetEvmAddressPlaceholder000000000000` |
| Testnet | `0xTESTNET_NEO_CONTRACT_HASH_PLACEHOLDER` | `0xTestnetEvmAddressPlaceholder000000000000` |

## Integration Guide (How to Use)

Assuming you are building a Neo X smart contract and want to fetch API JSON data through Neo Oracle Gateway, use the flow below.

### 1) Add the EVM interface

```solidity
interface IOracleProxy {
    function initiateOracleCall(
        uint256 _maxBridgeFee,
        bytes calldata _serializedOracleCall,
        uint256 _gasForOracle,
        uint256 _gasOracleRequestExec,
        uint256 _gasOracleResponseReturn,
        uint256 _maxMessageFee,
        bool _storeResult
    ) external payable returns (uint256 messageNonce, uint256 requestId);

    function getOracleResult(uint256 _requestId)
        external
        view
        returns (string memory result, uint256 responseCode, bool exists);

    function hasOracleResult(uint256 _requestId) external view returns (bool);
}
```

### 2) Instantiate the proxy contract

Use the `oracle-proxy-evm` address from the [`Deployments`](#deployments) table (`Mainnet` or `Testnet`, depending on your environment):

```solidity
oracleProxy = IOracleProxy(0xADDRESS);
```

### 3) Initiate an oracle call

```solidity
(messageNonce, requestId) = oracleProxy.initiateOracleCall{value: totalValue}(
    _maxBridgeFee,
    _serializedOracleCall,
    _gasForOracle,
    _gasOracleRequestExec,
    _gasOracleResponseReturn,
    _maxMessageFee,
    _storeResult
);
```

Parameter reference for `initiateOracleCall()`:

- `_maxBridgeFee`: Maximum fee you accept for bridge withdrawal.
- `_serializedOracleCall`: Serialized Neo method call bytes for the Oracle request. It must include exactly `url`, `filter`, and `callbackMethod`. The gateway appends `gasForOracle`, `gasOracleRequestExec`, `gasOracleResponseReturn`, `nonce`, and `requestId` automatically. See how to construct the `_serializedOracleCall` [here](#3a-constructing-_serializedoraclecall).
- `_gasForOracle`: GAS allocated to the Oracle node. Must be `> 0.1 GAS` and `<= _gasOracleRequestExec`.
- `_gasOracleRequestExec`: GAS for Oracle request execution on Neo N3 (includes `_gasForOracle`).
- `_gasOracleResponseReturn`: GAS for returning the Oracle response to Neo X.
- `_maxMessageFee`: Maximum fee you accept for sending the bridge message.
- `_storeResult`: Whether to persist the Oracle execution result on-chain.

Returns:

- `messageNonce`: Nonce of the message sent through the bridge.
- `requestId`: Oracle request ID assigned by `oracle-proxy-evm`.

### 3a) Constructing `_serializedOracleCall`

To build the `_serializedOracleCall` parameter, serialize the Neo Oracle request using the following required fields:

- `url`: The full request URL as a string.
- `filter`: A JSONPath expression to filter the Oracle response data.
- `callbackMethod`: The Neo contract method name to call when the Oracle call completes.

Serialization is handled off-chain. TO BE DESCRIBED HOW, IN DETAIL.

> **Tip:** TO BE DESCRIBED HOW, IN DETAIL

### 4) Check or fetch the result

Check if a result exists:

```solidity
oracleProxy.hasOracleResult(_requestId);
```

Get the result directly:

```solidity
oracleProxy.getOracleResult(_requestId);
```
