# Network Information

### Mainnet

<table>
    <thead>
        <tr>
            <th width="200">Property</th>
            <th width="550">Value</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Network Name</td>
            <td>Neo X Mainnet</td>
        </tr>
        <tr>
            <td>Chain ID</td>
            <td>47763</td>
        </tr>
        <tr>
            <td>RPC Endpoint</td>
            <td><a href="https://mainnet-1.rpc.banelabs.org">https://mainnet-1.rpc.banelabs.org</a><br><a href="https://mainnet-2.rpc.banelabs.org">https://mainnet-2.rpc.banelabs.org</a><br><a href="https://mainnet-3.rpc.banelabs.org">https://mainnet-3.rpc.banelabs.org</a><br><a href="https://mainnet-5.rpc.banelabs.org">https://mainnet-5.rpc.banelabs.org</a> (Only for Anti-MEV usage*)</td>
        </tr>
        <tr>
            <td>WSS Endpoint</td>
            <td>wss://mainnet.wss1.banelabs.org<br>wss://mainnet.wss2.banelabs.org<br>wss://mainnet.wss3.banelabs.org</td>
        </tr>
        <tr>
            <td>Block Explorer</td>
            <td><a href="https://neoxscan.ngd.network">https://neoxscan.ngd.network</a><br><a href="https://xexplorer.neo.org">https://xexplorer.neo.org</a></td>
        </tr>
        <tr>
            <td>Currency Symbol</td>
            <td>GAS</td>
        </tr>
        <tr>
            <td>Governance</td>
            <td><a href="https://xgovernance.neo.org">https://xgovernance.neo.org</a></td>
        </tr>
        <tr>
            <td>Bridge</td>
            <td><a href="https://xbridge.neo.org">https://xbridge.neo.org</td>
        </tr>
    </tbody>
</table>

### Testnet

<table>
    <thead>
        <tr>
            <th width="200">Property</th>
            <th width="550">Value</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Network Name</td>
            <td>Neo X Testnet T4</td>
        </tr>
        <tr>
            <td>Chain ID</td>
            <td>12227332</td>
        </tr>
        <tr>
            <td>RPC Endpoint</td>
            <td><a href="https://neoxt4seed1.ngd.network">https://neoxt4seed1.ngd.network</a><br><a href="https://neoxt4seed2.ngd.network">https://neoxt4seed2.ngd.network</a><br><a href="https://neoxt4seed3.ngd.network">https://neoxt4seed3.ngd.network</a><br><a href="https://neoxt4seed5.ngd.network">https://neoxt4seed5.ngd.network</a> (Only for Anti-MEV usage*)</td>
        </tr>
        <tr>
            <td>WSS Endpoint</td>
            <td>wss://neoxt4wss1.ngd.network<br>wss://neoxt4wss2.ngd.network<br>wss://neoxt4wss3.ngd.network</td>
        </tr>
        <tr>
            <td>Block Explorer</td>
            <td><a href="https://neoxt4scan.ngd.network">https://neoxt4scan.ngd.network</a><br><a href="https://xt4scan.ngd.network">https://xt4scan.ngd.network</a></td>
        </tr>
        <tr>
            <td>Currency Symbol</td>
            <td>GAS</td>
        </tr>
        <tr>
            <td>Governance</td>
            <td><a href="https://testnet.governance.banelabs.org">https://testnet.governance.banelabs.org</a></td>
        </tr>
        <tr>
            <td>Bridge</td>
            <td><a href="https://testnet.bridge.banelabs.org">https://testnet.bridge.banelabs.org</a></td>
        </tr>
    </tbody>
</table>

\* RPC nodes that enable Anti-MEV support will not broadcast any normal transaction. Please refer [Envelope Transaction](../security/anti-mev-protection/constructing-envelope-transactions.md) for their proper usage.

### Environment Compatibility

<table>
    <thead>
        <tr>
            <th width="200">Name</th>
            <th width="550">Supported Version</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Geth RPC</td>
            <td>v1.16.9</td>
        </tr>
        <tr>
            <td>Solidity Compiler</td>
            <td>Latest</td>
        </tr>
        <tr>
            <td>EVM Version</td>
            <td>Support up to <code>osaka</code></td>
        </tr>
    </tbody>
</table>

### Deployed Contracts

#### Core Infrastructure

<table>
    <thead>
        <tr>
            <th width="170">Name</th>
            <th width="100">Network</th>
            <th width="480">Address</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>CREATE2 Deployer</td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0x4e59b44847b379578588920ca78fbf26c0b4956c">
                    <code>0x4e59b44847b379578588920cA78FbF26c0B4956C</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x4e59b44847b379578588920ca78fbf26c0b4956c">
                    <code>0x4e59b44847b379578588920cA78FbF26c0B4956C</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

Core infrastructure contracts provide fundamental primitives used across the ecosystem.
The CREATE2 Deployer enables deterministic contract deployments via CREATE2 and matches the canonical Ethereum deployer at the same address.

#### Account Abstraction

<table>
    <thead>
        <tr>
            <th width="150">Name</th>
            <th width="100">Network</th>
            <th width="500">Address</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><a href="https://github.com/eth-infinitism/account-abstraction/releases/tag/v0.6.0">EntryPoint v0.6</a></td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789">
                    <code>0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789">
                    <code>0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789</code>
                </a>
            </td>
        </tr>
        <tr>
            <td>
                <a href="https://github.com/eth-infinitism/account-abstraction/releases/tag/v0.7.0">EntryPoint v0.7</a>
            </td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0x0000000071727De22E5E9d8BAf0edAc6f37da032">
                    <code>0x0000000071727De22E5E9d8BAf0edAc6f37da032</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x0000000071727De22E5E9d8BAf0edAc6f37da032">
                    <code>0x0000000071727De22E5E9d8BAf0edAc6f37da032</code>
                </a>
            </td>
        </tr>
        <tr>
            <td>
                <a href="https://github.com/eth-infinitism/account-abstraction/releases/tag/v0.8.0">EntryPoint v0.8</a>
            </td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108">
                    <code>0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108">
                    <code>0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108</code>
                </a>
            </td>
        </tr>
        <tr>
            <td>
                <a href="https://github.com/eth-infinitism/account-abstraction/releases/tag/v0.9.0">EntryPoint v0.9</a>
            </td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0x433709009B8330FDa32311DF1C2AFA402eD8D009">
                    <code>0x433709009B8330FDa32311DF1C2AFA402eD8D009</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x433709009B8330FDa32311DF1C2AFA402eD8D009">
                    <code>0x433709009B8330FDa32311DF1C2AFA402eD8D009</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

Account abstraction infrastructure provides the canonical ERC-4337 EntryPoint contracts used by smart accounts, bundlers, paymasters, and related account abstraction tooling.

The EntryPoint is a critical singleton contract for ERC-4337. Different wallets and bundlers may depend on different EntryPoint versions, so Neo X provides deployments for v0.6, v0.7, v0.8, and v0.9. The contracts are deployed at the same deterministic addresses as on other EVM networks using CREATE2.

#### Utilities

<table>
    <thead>
        <tr>
            <th width="150">Name</th>
            <th width="100">Network</th>
            <th width="500">Address</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Multicall3</td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0xD6010D102015fEa9cB3a9AbFBB51994c0Fd6E672">
                    <code>0xD6010D102015fEa9cB3a9AbFBB51994c0Fd6E672</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x82096F92248dF7afDdef72E545F06e5be0cf0F99">
                    <code>0x82096F92248dF7afDdef72E545F06e5be0cf0F99</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

Utility contracts provide reusable functionality for interacting with the network.
Multicall3 enables batching multiple contract calls into a single request.

#### Assets

<table>
    <thead>
        <tr>
            <th width="150">Name</th>
            <th width="100">Network</th>
            <th width="500">Address</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>WGAS10</td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0xdE41591ED1f8ED1484aC2CD8ca0876428de60EfF">
                    <code>0xdE41591ED1f8ED1484aC2CD8ca0876428de60EfF</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x1CE16390FD09040486221e912B87551E4e44Ab17">
                    <code>0x1CE16390FD09040486221e912B87551E4e44Ab17</code>
                </a>
            </td>
        </tr>
        <tr>
            <td><a href="https://github.com/bane-labs/xgas">xGAS</a></td>
            <td align="center">Mainnet</td>
            <td align="center">
                <a href="https://xexplorer.neo.org/address/0x9a50C8804dC885F118835cD96d3Ea4D4A5131A01">
                    <code>0x9a50C8804dC885F118835cD96d3Ea4D4A5131A01</code>
                </a>
            </td>
        </tr>
        <tr>
            <td></td>
            <td align="center">Testnet</td>
            <td align="center">
                <a href="https://xt4scan.ngd.network/address/0x3eE9da67D85475a250423138cBf56aF511277958">
                    <code>0x3eE9da67D85475a250423138cBf56aF511277958</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

Asset contracts represent tokenized value on Neo X.

- WGAS10 wraps native GAS with a WETH9-compatible design and implements ERC-3156 flash loans.
- xGAS is an immutable wrapped native GAS asset that extends standard ERC-20 behavior with explicit permit and transfer-authorization support (EIP-2612, EIP-3009, EIP-712), plus ERC-1271-compatible encoded-signature extensions.
