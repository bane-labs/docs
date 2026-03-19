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
- `oracle-proxy-evm`: [https://github.com/bane-labs/oracle-proxy-evm](https://github.com/bane-labs/oracle-proxy-evm)

## Deployments

Mainnet and testnet deployment addresses for Neo Oracle Gateway:

| Network | `oracle-proxy-neo` (Neo N3) | `oracle-proxy-evm` (Neo X) |
| --- | --- | --- |
| Mainnet | `0x5a0a0f188f2582ad60c1970267df30ec5428100d` | `0xce6138E61e5727a318D0DebEaD99Aff24B929131` |
| Testnet | `0x5a0a0f188f2582ad60c1970267df30ec5428100d` | `0xce6138E61e5727a318D0DebEaD99Aff24B929131` |

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
- `_serializedOracleCall`: Serialized Neo method call bytes for the Oracle request. It must include exactly `url`, `filter`, and `callbackMethod`. The gateway appends `gasForOracle`, `gasOracleRequestExec`, `gasOracleResponseReturn`, `nonce`, and `requestId` automatically. See how to construct the `_serializedOracleCall` [here](#3a-constructing-_serializedoraclecall) [and here](#3b-constructing-_serializedoraclecall).
- `_gasForOracle`: GAS allocated to the Oracle node. Must be `> 0.1 GAS` and `<= _gasOracleRequestExec`.
- `_gasOracleRequestExec`: GAS for Oracle request execution on Neo N3 (includes `_gasForOracle`).
- `_gasOracleResponseReturn`: GAS for returning the Oracle response to Neo X.
- `_maxMessageFee`: Maximum fee you accept for sending the bridge message.
- `_storeResult`: Whether to persist the Oracle execution result on-chain.

Returns:

- `messageNonce`: Nonce of the message sent through the bridge.
- `requestId`: Oracle request ID assigned by `oracle-proxy-evm`.

### 3a) Constructing `_serializedOracleCall` off-chain (TypeScript)

To build the `_serializedOracleCall` parameter, you must serialize a Neo N3 contract call.
In other words, `_serializedOracleCall` should be the serialized bytes for of the call:

```text
oracleProxyContractN3.requestOracleData(url, filter, callbackMethod)
```

Only the three "request" arguments are included here. The gateway contract (`oracle-proxy-evm`) appends the remaining execution arguments (gas values, withdrawal nonce, and requestId) automatically inside `initiateOracleCall()`.

Serialize using the required fields below:

- `url`: The full request URL as a string.
- `filter`: A JSONPath expression to filter the Oracle response data.
- `callbackMethod`: The Neo contract method name to call when the Oracle call completes (commonly `onOracleResponse`, depending on your Neo contract).

#### How `_serializedOracleCall` is constructed (using `bridge-sdk`)

Serialization is done off-chain using the bridge SDK for Neo N3 call serialization:

- `@bane-labs/bridge-sdk-ts`: https://www.npmjs.com/package/@bane-labs/bridge-sdk-ts

You can install in your project:

```shell
npm install @bane-labs/bridge-sdk-ts
```

The goal is to serialize a Neo N3 contract call to the OracleProxy method `requestOracleData(url, filter, callbackMethod)`.

Off-chain steps:

1. Provide the Neo N3 parameters used for serialization:
   - `neo3RpcUrl`: Neo N3 RPC endpoint
   - `executionManagerHash`: ExecutionManager contract hash on Neo N3
   - `oracleProxyContractN3`: OracleProxy contract hash on Neo N3 (target of the call)
2. Create the 3 method arguments in the exact order:
   - `methodArgs[0]`: `{ type: 'String', value: url }`
   - `methodArgs[1]`: `{ type: 'String', value: filter }` (empty string is allowed)
   - `methodArgs[2]`: `{ type: 'String', value: callbackMethod }`
3. Use a throwaway/dummy account for *read-only* serialization:
   - The SDK serializer requires an account object, but this step does not broadcast a transaction.
4. Serialize the call via the ExecutionManager:
   - Target contract: `oracleProxyContractN3`
   - Method: `'requestOracleData'` (mandatory)
   - CallFlags: `15` (`CallFlags.All`) (mandatory hardcoded value)
   - Args: `methodArgs`
5. Pass the returned `hex` string (ensure `0x` prefix) as `_serializedOracleCall` to `oracleProxy.initiateOracleCall(...)`.

Example (TypeScript):

```ts
import { NeoExecutionManager, neonAdapter } from '@bane-labs/bridge-sdk-ts';
import type { ContractParamJson } from '@cityofzion/neon-core/lib/sc/ContractParam';

export async function buildSerializedOracleCall(
  neo3RpcUrl: string,
  executionManagerHash: string,
  oracleProxyContractN3: string,
  url: string,
  filter: string,
  callbackMethod: string
): Promise<string> {

  // Set the method arguments
  const methodArgs: ContractParamJson[] = [
    { type: 'String', value: url || '' },
    { type: 'String', value: (filter || '').toString() },
    { type: 'String', value: callbackMethod || '' },
  ];

  // Dummy account is used only to satisfy the SDK serializer.
  const dummyPrivateKey = neonAdapter.create.privateKey();
  const account = neonAdapter.create.account(dummyPrivateKey);

  const executionManager = new NeoExecutionManager({
    rpcUrl: neo3RpcUrl,
    contractHash: executionManagerHash.replace(/^0x/i, ''),
    account,
  });

  // Call target: OracleProxy (N3), method: requestOracleData, flags: CallFlags.All (15).
  const serialized = await executionManager.serializeCall(
    oracleProxyContractN3.replace(/^0x/i, ''),
    'requestOracleData', // mandatory and cannot be changed, this is the method on the N3 Oracle Gateway contract that is being called
    15, // CallFlags.All (mandatory)
    methodArgs
  );

  return serialized.startsWith('0x') ? serialized : `0x${serialized}`;
}
```

#### Important note: what *must not* be manually appended

Do **not** include these values in `_serializedOracleCall` yourself:

- `gasForOracle`
- `gasOracleRequestExec`
- `gasOracleResponseReturn`
- `nonce` / `withdrawalNonce`
- `requestId`

These are appended automatically on-chain by `oracle-proxy-evm` during `initiateOracleCall()` via `NeoSerializerLib.appendArgToCall(...)`.

### 3b) Constructing `_serializedOracleCall` on-chain (Solidity)

As an alternative to building `_serializedOracleCall` off-chain (section 3a), you can construct it entirely on-chain inside your own smart contract using the [`neo-serializer-evm`](https://github.com/AxLabs/neo-serializer-evm) Solidity library.

Install `neo-serializer-evm` and import `NeoSerializerLib`:

```solidity
import {NeoSerializerLib} from "neo-serializer-evm/contracts/libraries/NeoSerializerLib.sol";
```

Then build the serialized call in your contract:

```solidity
function buildSerializedOracleCall(
    bytes20 oracleProxyN3,
    string calldata url,
    string calldata filter,
    string calldata callbackMethod
) public pure returns (bytes memory) {
    bytes[] memory args = new bytes[](3);
    args[0] = NeoSerializerLib.serialize(url);
    args[1] = NeoSerializerLib.serialize(filter);
    args[2] = NeoSerializerLib.serialize(callbackMethod);

    return NeoSerializerLib.serializeCall(
        oracleProxyN3,                       // Neo N3 OracleProxy contract hash
        "requestOracleData",                 // mandatory: fixed method name
        NeoSerializerLib.CALL_FLAGS_ALL,     // mandatory: CallFlags.All (15)
        args
    );
}
```

Parameter reference:

| Parameter | Description |
| --- | --- |
| `oracleProxyN3` | The Neo N3 OracleProxy contract hash (`bytes20`). This is the target contract on N3 that will execute the oracle request. Use the hash from the [Deployments](#deployments) table. |
| `"requestOracleData"` | **Mandatory hardcoded value.** The method name on the N3 OracleProxy contract. Must always be exactly `"requestOracleData"`. |
| `CALL_FLAGS_ALL` (`15`) | **Mandatory hardcoded value.** Maps to Neo's `CallFlags.All` (`ReadStates \| WriteStates \| AllowCall \| AllowNotify`). The library exposes this constant as `NeoSerializerLib.CALL_FLAGS_ALL`. |
| `args` | Array of exactly 3 serialized arguments: `url`, `filter`, `callbackMethod` -- each serialized via `NeoSerializerLib.serialize(string)`. |

The returned `bytes` is a valid `_serializedOracleCall` that can be passed directly to `oracleProxy.initiateOracleCall(...)`.

> **Note:** `serializeCall` internally handles byte-order conversion for the target hash (reverses bytes to match Neo's `UInt160` format via `serializeHash160`), serializes the method name and call flags, wraps the args into a Neo Array, and combines everything into the outer serialized structure.

### 4) Check or fetch the result

Check if a result exists:

```solidity
oracleProxy.hasOracleResult(_requestId);
```

Get the result directly:

```solidity
oracleProxy.getOracleResult(_requestId);
```
