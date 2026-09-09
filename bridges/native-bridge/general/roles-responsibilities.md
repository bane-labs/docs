# Roles and Responsibilities

The bridge involves several distinct roles that are managed in the BridgeManagement contract. Besides the already elaborated Validator and Relayer role, there exist the following additional roles:

* Owner
* Governor
* SecurityGuard

The owner is a multi-sig account consisting of keys stored in cold wallets. Its main responsibility is assigning roles as well as performing contract updates. On Neo X exclusively, the responsibility of updating the contracts lies with the Neo X committee, ultimately reducing the owner's responsibility on the bridge contracts on Neo X to role assigning only.

The governor is responsible for pausing/unpausing, updating parameters, and registering tokens.

Finally, the security guard is allowed to pause contracts with the intention of using this role for emergency intervention.

The table below provides an overview of the main functionalities of the smart contracts and who is allowed to use them.

<table>
    <thead>
        <tr>
            <th width="220">Functionality</th>
            <th width="230">Management</th>
            <th width="150">TokenBridge</th>
            <th width="150">MessageBridge</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Update Contract (N3/Neo X)</td>
            <td>Owner/Committee</td>
            <td>Owner/Committee</td>
            <td>Owner/Committee</td>
        </tr>
        <tr>
            <td>Assign Roles</td>
            <td>Owner</td>
            <td>-</td>
            <td>-</td>
        </tr>
        <tr>
            <td>Pause</td>
            <td>-</td>
            <td>Governor and SecurityGuard</td>
            <td>Governor and SecurityGuard</td>
        </tr>
        <tr>
            <td>Unpause</td>
            <td>-</td>
            <td>Governor</td>
            <td>Governor</td>
        </tr>
        <tr>
            <td>Update a Parameter (e.g., fee)</td>
            <td>-</td>
            <td>Governor</td>
            <td>Governor</td>
        </tr>
        <tr>
            <td>Register a Token</td>
            <td>-</td>
            <td>Governor</td>
            <td>Governor</td>
        </tr>
        <tr>
            <td>Request Bridging Tokens/Messages</td>
            <td>-</td>
            <td>Anyone</td>
            <td>Anyone</td>
        </tr>
        <tr>
            <td>Relaying Requests</td>
            <td>-</td>
            <td>Relayer (incl. enough Validator signatures)</td>
            <td>Relayer (incl. enough Validator signatures)</td>
        </tr>
    </tbody>
</table>

> **IMPORTANT:**
>
> Although only the relayer is authorized to use the distribution/relaying functionality, it requires sufficiently enough signatures of validators. The required threshold of validator signatures is set in the BridgeManagement contract.
