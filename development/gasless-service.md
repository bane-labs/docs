# Gasless Service

Neo X has set up an official Paymaster to sponsor ERC-4337 UserOperations and an official Bundler known as the Altpool.

### Information

<table>
    <thead>
        <tr>
            <th width="200">Property</th>
            <th width="550" colspan="2">Value</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Official Paymaster</td>
            <td colspan="2"><code>0x121200000000000000000000000000000000000A</code></td>
        </tr>
        <tr>
            <td>EntryPoint v0.9</td>
            <td colspan="2"><code>0x433709009B8330FDa32311DF1C2AFA402eD8D009</code></td>
        </tr>
        <tr>
            <td rowspan="2">Bunder RPC</td>
            <td width="75">Mainnet</td>
            <td><a href="https://mainnet.bundler.banelabs.org">https://mainnet.bundler.banelabs.org</a></td>
        </tr>
        <tr>
            <td width="75">Testnet</td>
            <td><a href="https://neoxt4bundler.banelabs.org">https://neoxt4bundler.banelabs.org</a></td>
        </tr>
    </tbody>
</table>

### Pay By Governance

For every block in the network, Neo X distributes a fixed ratio (currently 10%) of the network reward to the official Paymaster contract.

This contract releases up to 0.4 GAS per block to sponsor UserOperations via EntryPoint v0.9. However, sponsorship is not guaranteed if the balance is insufficient.

### Paymaster Rules

The official Paymaster of Neo X is restricted by the [network policy](../governance/neo-x-system-contracts.md#policy). It also aims to keep bundlers break-even by allowing a 20% extra gas tip as a reward.

The contract only sponsors UserOperations that meet the following requirements:

1. The sender is not blacklisted; otherwise it returns a custom error `SenderBlacklisted`;
2. `maxPriorityFeePerGas` is not higher than _120%*minGasTipCap_ according to the network policy; otherwise it returns a custom error `GasTipTooHigh`;
3. `maxFeePerGas` is not higher than _120%*minGasTipCap+baseFee_ according to the network policy, otherwise it returns a custom error `MaxFeeTooHigh`.

### Bundler Rules

The official Bundler of Neo X provides a quick start for enjoying governance sponsorship, but you may also set up your own Bundler with different strategies.

This Bundler operates as follows:

1. Support [ERC-7769](https://eips.ethereum.org/EIPS/eip-7769) standard APIs;
2. Processes UserOperations in FIFO (First-In-First-Out) order, regardless of gas tip priority;
3. Accepts only UserOperations that will not cause a deficit.

### Sending a Free Transaction

It's recommended to start with the official Bundler, and make full use of the Paymaster's sponsorship.

1. Choose a deployed ERC-4337 wallet factory and prepare the `initCode`;
2. Include the `initCode` in your UserOperation and set the Neo X official Paymaster in `paymasterAndData`;
3. Configure `gasFees` within the maximum values allowed by the Neo X Paymaster;
4. Sign and send the UserOperation to the official Bundler, then wait for execution.

If the smart wallet is successfully deployed and initialized, you can begin your gasless Account Abstraction journey.

### Decentralization

The EntryPoint v0.9 is a publicly verifiable contract, while the Neo X GovPaymaster is managed by Neo X Governance. Both are reliable services to depend on.

Additionally, you are free to set up your own Bundlers or Paymasters for your users. The Neo X official Paymaster is fully public, allowing any user or Bundler to request sponsorship.
