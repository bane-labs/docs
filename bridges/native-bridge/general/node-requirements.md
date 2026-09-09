# Node Requirements for Relayer and Validator

The validator–relayer setup is intentionally decoupled to minimize trust assumptions and reduce attack surface.  
Validators are isolated entities that observe events and produce signed state commitments, while the relayer aggregates these signatures and submits relay transactions to the destination chain.

This document specifies the **software architecture** and the **infrastructure requirements** for running validator and relayer nodes.

---

## 1. Software Architecture Overview

### 1.1 Validator Backend

Validators operate as isolated, non-interactive observers. They:

- listen to bridge smart contract events on the source chain,
- reconstruct the hash-chain state and confirm correctness,
- sign the resulting top root using a locally stored private key,
- forward the signed batch (root + payloads) to the relayer through an internal message broker.

**Validators MUST NOT:**

- broadcast transactions on any blockchain,
- expose signing keys or accept inbound external connections,
- coordinate with other validators.

Each validator acts independently and does not communicate with other validators.

---

### 1.2 Relayer Backend

The relayer aggregates validator signatures and constructs the relay transaction. It:

- listens for incoming signed batches from validators,
- collects enough signatures to satisfy the threshold enforced by BridgeManagement on the destination chain,
- assembles a relay transaction containing:
  - the signed top root,
  - all associated batch payloads,
  - the validator signatures,
- submits the transaction to the destination-chain bridge contract.

The relayer **does not verify correctness** of the batch. All verification is performed on-chain through:

- sequential nonce checks,
- hash-chain reconstruction,
- top-root comparison,
- and threshold signature verification via BridgeManagement.

A single relayer instance is sufficient, but redundant failover instances are recommended for availability.

---

## 2. Infrastructure Requirements

### 2.1 Compute Infrastructure

The recommended baseline infrastructure is:

#### Message Broker

- 1 internal message broker (e.g., RabbitMQ, ZeroMQ, Redis Streams)
- Runs on-premise or within a protected network segment
- Serves as the communication channel between validators and relayer

#### Relayer Nodes

- 1 active relayer backend
- 1 optional failover relayer backend
- Each with:
  - 4 GB RAM
  - 2 CPU cores
- Nodes must reside inside the protected VLAN

#### Validator Nodes

- 7 validator backends (or parameterized by governance)
- Each with:
  - minimum 1 GB RAM
  - 1 CPU core
- Each validator must run on an independently controlled machine or VM  
  (no shared IPs, providers, infrastructure)

Validators must be isolated from one another to prevent correlated failures.

---

### 2.2 Network Infrastructure

#### Internal Network

- 1 dedicated VLAN containing:
  - all validator nodes,
  - relayer nodes,
  - the message broker.

#### Security Constraints

- Private IP addresses across the VLAN
- **Deny-all inbound firewall rule** from external networks
- Only outbound access to blockchain RPC endpoints is permitted
- No inbound connectivity allowed to validator nodes
- Validator keys must never be exposed through RPC or remote signing services

This network design ensures validators cannot be externally reached or probed, while allowing only the relayer and message broker to communicate internally.

---

## 3. Summary of Requirements

### Validators

- Observe chain events
- Reconstruct hash-chain state
- Sign the top root only
- Never send transactions on-chain
- Must operate in isolated, secure environments

### Relayer

- Aggregates validator signatures
- Submits relay transactions
- Runs in a protected internal network
- May be deployed with failover redundancy

### Infrastructure

- Dedicated VLAN
- On-premise or protected message broker
- Strict firewall isolation
- Distributed validator nodes on separate machines/providers
