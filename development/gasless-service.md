# Governance-Sponsored Gasless Transactions

Neo X has deployed a native, governance-funded Paymaster (`GovPaymaster`) to sponsor eligible [ERC-4337](https://docs.erc4337.io/) UserOperations and documents a Bundler service known as the **Altpool**.

This is a governance-sponsored Account Abstraction flow. A UserOperation is not a normal transaction: the user signs a structured operation, a Bundler accepts it through the ERC-7769 JSON-RPC API, and the Bundler submits one or more accepted operations to EntryPoint in a normal on-chain transaction.

GovPaymaster is a Neo X system contract exposed through the native-contract proxy infrastructure. Its address is listed in the Mainnet and Testnet tables below.

### What "gasless" means

"Gasless" describes the user experience, not a specific transaction type or a guarantee that no one pays gas. In this service:

- the user signs a UserOperation instead of submitting a normal transaction;
- Altpool submits the resulting on-chain bundle;
- GovPaymaster pays the eligible operation's gas through its EntryPoint deposit;
- the user does not need to hold native GAS for that sponsored operation.

Sponsorship is conditional:

- GovPaymaster may reject an operation, and sponsorship is unavailable when its balance is insufficient;
- ERC-4337 EntryPoint provides and enforces the common on-chain validation, execution, and fee-accounting flow;
- The Bundler may not submit an operation, if the local simulation fails due to the GovPaymaster or EntryPoint validation.

Other Bundlers and Paymasters can implement different gas-abstraction models, including sponsorship policies or payment through a tokenized gas asset, without using GovPaymaster. For example, another Bundler could support a Paymaster that charges users in xGAS, wrapped GAS (wGAS), a stablecoin, or another supported token while still submitting the UserOperation bundle through EntryPoint; the Paymaster would handle the token-based payment while EntryPoint accounts for the underlying network gas.

### Deployments

#### Mainnet

<table>
    <thead>
        <tr>
            <th width="200">Property</th>
            <th width="550">Value</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>GovPaymaster</td>
            <td><code>0x121200000000000000000000000000000000000A</code></td>
        </tr>
        <tr>
            <td>EntryPoint v0.9</td>
            <td><code>0x433709009B8330FDa32311DF1C2AFA402eD8D009</code></td>
        </tr>
        <tr>
            <td>Bundler RPC</td>
            <td><a href="https://mainnet.bundler.banelabs.org">https://mainnet.bundler.banelabs.org</a></td>
        </tr>
    </tbody>
</table>

#### Testnet

<table>
    <thead>
        <tr>
            <th width="200">Property</th>
            <th width="550">Value</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>GovPaymaster</td>
            <td><code>0x121200000000000000000000000000000000000A</code></td>
        </tr>
        <tr>
            <td>EntryPoint v0.9</td>
            <td><code>0x433709009B8330FDa32311DF1C2AFA402eD8D009</code></td>
        </tr>
        <tr>
            <td>Bundler RPC</td>
            <td><a href="https://neoxt4bundler.banelabs.org">https://neoxt4bundler.banelabs.org</a></td>
        </tr>
    </tbody>
</table>

### Pay By Governance

For every block in the network, Neo X distributes a fixed ratio of the network reward to the GovPaymaster contract (10% at the time of writing – August 2026).

This contract releases up to 0.4 GAS per block to sponsor UserOperations via EntryPoint v0.9. However, sponsorship is not guaranteed if the balance is insufficient.

GovPaymaster maintains a native-token deposit with EntryPoint. For an accepted sponsored UserOperation, EntryPoint charges the gas cost to that deposit instead of requiring the smart account to pay. The Bundler submits the on-chain bundle and receives the collected UserOperation fees through EntryPoint.

For users, the important point is that the operation is sponsored only when GovPaymaster accepts it and has sufficient funds available.

### Paymaster Rules

GovPaymaster is restricted by the [network policy](../governance/neo-x-system-contracts.md#policy). It permits a priority fee up to 20% above the network minimum so that Bundlers can be compensated for submitting sponsored operations. This is a fee limit for sponsorship eligibility, not a separate fee that users pay and not a guaranteed Bundler profit.

The contract only sponsors UserOperations that meet the following requirements:

1. The sender is not blacklisted; otherwise it returns a custom error `SenderBlacklisted`;
2. `maxPriorityFeePerGas` is not higher than _`1.2 * minGasTipCap`_ according to the network policy; otherwise it returns a custom error `GasTipTooHigh`;
3. `maxFeePerGas` is not higher than _`baseFee + (1.2 * minGasTipCap)`_ according to the network policy, otherwise it returns a custom error `MaxFeeTooHigh`.

GovPaymaster sponsorship is not automatic. A sponsored UserOperation must explicitly identify GovPaymaster in its Paymaster field or fields. If no Paymaster is included, the `sender` smart account must provide the required EntryPoint deposit or prefund during account validation. If GovPaymaster has insufficient balance or rejects the operation, the Bundler should reject it before submitting a bundle.

### Bundler Rules

The Altpool Bundler service provides a quick start for using governance sponsorship, but you may also set up your own Bundler with different strategies.

This Bundler operates as follows:

1. Support [ERC-7769](https://eips.ethereum.org/EIPS/eip-7769) standard APIs;
2. Processes UserOperations in FIFO (First-In-First-Out) order, regardless of gas tip priority;
3. Accepts only UserOperations that will not cause a deficit.

### Altpool and other Bundlers

Altpool is the name of the Bundler service documented for Neo X. It accepts UserOperations through the ERC-7769 API and submits accepted bundles to EntryPoint.

GovPaymaster sponsorship is not restricted to Altpool. Any Bundler that supports the required EntryPoint version and UserOperation format can submit an operation that explicitly identifies GovPaymaster, provided the operation passes GovPaymaster's policy checks and sufficient Paymaster funds are available. The Bundler supplies the `beneficiary` address when it calls `EntryPoint.handleOps(...)`; EntryPoint uses that address when transferring the collected fees. Running an independent Bundler still requires the operator to provide the Bundler infrastructure and initially fund the outer on-chain transaction.

The relevant UserOperation RPC methods include:

- `eth_sendUserOperation` — submit a signed UserOperation and EntryPoint address;
- `eth_estimateUserOperationGas` — estimate the operation's gas requirements;
- `eth_getUserOperationByHash` — retrieve a pending or included UserOperation;
- `eth_getUserOperationReceipt` — retrieve the operation result and the underlying bundle transaction receipt;
- `eth_supportedEntryPoints` — list the EntryPoint addresses supported by the Bundler.

These methods are sent to the Bundler RPC endpoint, not to the ordinary chain RPC endpoint. The ordinary chain RPC remains useful for reading chain state and inspecting the resulting transaction.

### Sending a Sponsored UserOperation

It's recommended to start with Altpool and make full use of GovPaymaster's sponsorship. The result is sponsored rather than intrinsically free: execution consumes gas, and GovPaymaster covers the accepted operation's gas through its EntryPoint deposit.

1. Choose a deployed ERC-4337 smart-account implementation and wallet factory, or an EIP-7702 wallet implementation. A traditional ERC-4337 flow uses a smart-contract account; EIP-7702 provides an alternative account-authorization flow;
2. Calculate the account's deterministic `sender` address. For a new account, prepare `initCode` using the selected factory and its initialization calldata. EntryPoint calls that factory during the first UserOperation and deploys the account before validating and executing the operation. The client constructing the UserOperation controls `initCode`; for an account that already exists, it should set `initCode` to `0x`. A Bundler may reject an existing `sender` paired with non-empty account-creation data;
3. Obtain the UserOperation nonce from EntryPoint, normally with `getNonce(sender, key)`;
4. Include GovPaymaster information in `paymasterAndData` (or the equivalent v0.9 RPC fields), and configure `gasFees` within the maximum values it allows;
5. Sign the complete UserOperation using the smart account's authorization scheme and send it to the Altpool Bundler RPC using `eth_sendUserOperation`, together with the supported EntryPoint v0.9 address;
6. Poll `eth_getUserOperationReceipt` until the operation is included or rejected.

If the smart wallet is successfully deployed and initialized, you can begin your gasless Account Abstraction journey.

### UserOperation structure and v0.9 encoding

The UserOperation is a structured object. Its core fields include:

- `sender` and `nonce`;
- account creation data (`factory` and `factoryData` in the RPC representation, or packed into `initCode` for EntryPoint);
- `callData` for the smart account's requested action;
- `callGasLimit`, `verificationGasLimit`, and `preVerificationGas`;
- `maxFeePerGas` and `maxPriorityFeePerGas` (packed as `gasFees` for EntryPoint);
- Paymaster data and Paymaster gas limits, when sponsorship is requested;
- `signature`.

For EntryPoint v0.9, the on-chain interface uses `PackedUserOperation`. The ERC-7769 RPC representation may expose the factory and Paymaster fields separately, while the on-chain `handleOps(...)` call receives packed fields. Client implementations must use the exact schema accepted by the Bundler endpoint.

For the complete RPC schema and request/response examples, see [ERC-7769: JSON-RPC API for ERC-4337](https://eips.ethereum.org/EIPS/eip-7769), especially `eth_estimateUserOperationGas` and `eth_sendUserOperation`. For the protocol-level fields and packed v0.9 representation, see the [ERC-4337 UserOperation specification](https://eips.ethereum.org/EIPS/eip-4337#the-useroperation-structure).

### EntryPoint execution flow

The Bundler does not execute the application call directly. It simulates UserOperations off-chain, groups accepted operations, and submits a normal transaction calling `EntryPoint.handleOps(...)`.

EntryPoint then:

1. deploys the account from `initCode` when necessary;
2. validates the smart account's signature and nonce;
3. validates and prefunds the Paymaster when one is specified;
4. executes the smart account's `callData`;
5. charges the account or Paymaster for the actual gas used; and
6. pays the collected fees to the Bundler's beneficiary.

If the application call reverts, EntryPoint records the UserOperation as unsuccessful and can continue with other operations in the bundle. Gas already consumed is still charged. Validation or sponsorship failures should be caught by Bundler simulation and rejected before submission; an unexpected validation failure can cause the bundle transaction to fail.

### Deposits without a Paymaster

Without a Paymaster, the smart account must fund its EntryPoint deposit, for example through `EntryPoint.depositTo(sender)`, or provide missing funds during `validateUserOp`. A Bundler does not permanently subsidize an operation merely because it submitted the outer transaction.

### EntryPoint versions

Neo X provides the canonical ERC-4337 EntryPoint deployments v0.6, v0.7, v0.8, and v0.9 at the deterministic addresses specified by their corresponding upstream releases. The documented GovPaymaster contract is coupled to EntryPoint v0.9, and the Altpool endpoints described on this page advertise EntryPoint v0.9. Therefore, the native governance-sponsored flow uses EntryPoint v0.9. The other EntryPoint versions remain available for compatible wallets and independently operated Bundlers, but are not covered by the GovPaymaster flow described here.

### Decentralization

The EntryPoint v0.9 is a publicly verifiable contract, while GovPaymaster is managed by Neo X Governance. Both are reliable services to depend on.

Additionally, you are free to set up your own Bundlers or Paymasters for your users. GovPaymaster is fully public, allowing any user or Bundler to request sponsorship.
