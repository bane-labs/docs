# x402 Integration

## Overview

x402 enables agent-driven, authorization-based payments on Neo X.

Instead of requiring users to submit and fund transactions directly, x402 allows agents to:

- obtain payment requirements from a service
- collect payment authorizations from users
- submit settlement transactions on-chain

This enables machine-native payment flows where authorization and execution are separated.

## Why x402 on Neo X

Neo X is well-suited for agent-driven payment flows:

- fast finality enables predictable settlement
- EVM compatibility allows reuse of established standards such as Permit2
- native asset support enables efficient value transfer
- low-latency execution fits automated agent systems well

x402 builds on these properties to support:

- off-chain authorization and on-chain settlement
- gas abstraction, where agents submit transactions and pay gas
- programmable payment flows with explicit settlement constraints

## Contracts

The x402 integration relies on the following contracts:

- **Permit2**
  A signature-based token authorization primitive used for delegated transfers.

- **x402ExactPermit2Proxy**
  An x402 settlement contract that acts as the authorized spender in Permit2 signatures and enforces x402-specific payment constraints.

See: [Contracts](./contracts.md)

## Quick Start

A typical x402 flow looks like this:

1. A service defines payment requirements
2. The user signs an authorization
3. An agent submits settlement on-chain
4. The payment is executed through the x402 contract using Permit2

See: [Quick Start](./quick-start.md)

## Network Addresses

Deployed contract addresses are listed in: [Networks](../../development/networks.md)

This page focuses on integration and usage rather than deployment details.
