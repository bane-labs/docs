# Audits

Independent security reviews help validate the design and implementation of Neo X before it handles user funds or consensus-critical operations. This page lists **publicly released audit reports** for Neo X–related codebases.

Reports are listed below in reverse chronological order. Each link opens the full PDF stored in this repository.

| Title | Scope | Finalized | Report |
| --- | --- | --- | --- |
| [xGAS — Security Audit (Red4Sec)](reports/red4sec-xgas-audit-report.pdf) | Wrapped native asset on Neo X: ERC-20 deposit/withdraw, ERC-2612 permits, and EIP-3009 transfer authorizations (EOA and ERC-1271 paths). Repository: [bane-labs/xgas](https://github.com/bane-labs/xgas). | 2026-05-20 | [PDF](reports/red4sec-xgas-audit-report.pdf) |
| [Arbitrary Message Bridge — Security Audit (Red4Sec)](reports/red4sec-arbitrary-message-bridge-audit-report.pdf) | N3↔Neo X message bridge smart contracts: NeoVM and Solidity contracts for arbitrary data messages, cross-chain contract calls, and execution result propagation. Repositories: [bane-labs/bridge-neo-contracts](https://github.com/bane-labs/bridge-neo-contracts) and [bane-labs/bridge-evm-contracts](https://github.com/bane-labs/bridge-evm-contracts). | 2025-10-13 | [PDF](reports/red4sec-arbitrary-message-bridge-audit-report.pdf) |
| [Neo X zk-DKG — Blockchain Protocol Security Analysis (Hacken)](reports/hacken-zk-dkg-audit-report.pdf) | Zero-knowledge Distributed Key Generation for Anti-MEV: multi-curve threshold key generation, Gnark circuits, and related Go implementation. Repository: [bane-labs/zk-dkg](https://github.com/bane-labs/zk-dkg). | 2025-08-04 | [PDF](reports/hacken-zk-dkg-audit-report.pdf) |
| [NeoX Bridge Contract — Competitive Security Assessment (Secure3)](reports/secure3-bridge-evm-contracts-audit-report.pdf) | Solidity bridge on Neo X: deposit/withdraw flows, token registration, validator signature verification, and bridge management contracts. Repository: [bane-labs/bridge-evm-contracts](https://github.com/bane-labs/bridge-evm-contracts). | 2024-08-08 | [PDF](reports/secure3-bridge-evm-contracts-audit-report.pdf) |
| [NeoX NeoVM Bridge Contracts — Security Audit (Red4Sec)](reports/red4sec-neovm-bridge-audit-report.pdf) | Neo N3 (NeoVM) side of the N3↔Neo X bridge: native contracts for deposits, fees, and bridge management (Neow3j). Repository: [bane-labs/bridge-neo-contracts](https://github.com/bane-labs/bridge-neo-contracts). | 2024-08-07 | [PDF](reports/red4sec-neovm-bridge-audit-report.pdf) |
| [NeoX EVM Bridge Contracts — Security Audit (Red4Sec)](reports/red4sec-evm-bridge-audit-report.pdf) | EVM-side N3↔Neo X bridge smart contracts (Solidity): asset transfer logic, configuration, and validator deposit verification. Includes follow-up re-audit of remediated scope. Repository: [bane-labs/bridge-evm-contracts](https://github.com/bane-labs/bridge-evm-contracts). | 2024-07-22 | [PDF](reports/red4sec-evm-bridge-audit-report.pdf) |
| [Neo X — Security Assessment (BlockSec)](reports/blocksec-neo-x-core-audit-report.pdf) | Neo X full-node fork vs. Geth: validator/governance Solidity contracts and selected Go changes (dBFT-related consensus code explicitly out of scope). Repository: [bane-labs/go-ethereum](https://github.com/bane-labs/go-ethereum). | 2024-07-09 | [PDF](reports/blocksec-neo-x-core-audit-report.pdf) |
| [NeoX Governance — Security Audit (Red4Sec)](reports/red4sec-governance-audit-report.pdf) | Built-in governance system contracts: consensus node election, voting, rewards, and candidate registration (genesis-allocated Solidity). Repository: [bane-labs/go-ethereum](https://github.com/bane-labs/go-ethereum/tree/bane-main/contracts). | 2024-06-07 | [PDF](reports/red4sec-governance-audit-report.pdf) |

## Notes

* **Scope vs. calendar date** — Some Red4Sec reports list both an engagement window (e.g. April–June 2024) and a report publication date on the cover. The **Finalized** column uses the date printed on the published report.
* **Follow-up work** — Several reports document remediation or re-audit cycles (for example, Secure3 contest findings and Red4Sec re-reviews). Refer to each PDF for finding severity and resolution status.
* **Missing reports** — If you believe a Neo X audit is absent from this list, please open an issue or contact the maintainers with the report title and auditor so it can be added.

Maintainers: see [Adding audit reports](ADDING-AUDITS.md) for filename conventions and how to update this page.
