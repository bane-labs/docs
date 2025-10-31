# Development Environment Information

### Networks

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
    </tbody>
</table>

\* RPC nodes that enable Anti-MEV support will not broadcast any normal transaction. Please refer [Envelope Transaction](../security/anti-mev-protection/constructing-envelope-transactions.md) for their proper usage.

### Development Environment Recommendations

<table>
    <thead>
        <tr>
            <th width="200">Name</th>
            <th width="550">Recommendation</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Geth Compatibility</td>
            <td>v1.13.15</td>
        </tr>
        <tr>
            <td>Solidity Compiler</td>
            <td>Latest</td>
        </tr>
        <tr>
            <td>EVM Version</td>
            <td>Support up to <code>shanghai</code></td>
        </tr>
    </tbody>
</table>

### Deployed Contracts

<table>
    <thead>
        <tr>
            <th width="100">Name</th>
            <th width="100">Network</th>
            <th width="550">Address</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>WGAS10</td>
            <td>Mainnet</td>
            <td>0xdE41591ED1f8ED1484aC2CD8ca0876428de60EfF</td>
        </tr>
        <tr>
            <td></td>
            <td>Testnet</td>
            <td>0x1CE16390FD09040486221e912B87551E4e44Ab17</td>
        </tr>
        <tr>
            <td>Multicall3</td>
            <td>Mainnet</td>
            <td>0xD6010D102015fEa9cB3a9AbFBB51994c0Fd6E672</td>
        </tr>
        <tr>
            <td></td>
            <td>Testnet</td>
            <td>0x82096F92248dF7afDdef72E545F06e5be0cf0F99</td>
        </tr>
    </tbody>
</table>
