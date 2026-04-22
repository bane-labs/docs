# x402 Contracts

## Overview

The x402 integration on Neo X supports authorization-based payments.

Depending on the capabilities of the underlying token, x402 can follow different settlement paths:

- **Permit2-based settlement** for broad ERC-20 compatibility
- **EIP-3009-based settlement** for tokens that natively support authorization-based transfers

This allows Neo X to support both:

- a universal path for existing ERC-20 assets
- a more direct path for tokens designed for agent-driven payments

## Authorization Models

x402 supports multiple authorization models depending on the token standard implemented by the asset being used.

### Permit2-based model

Permit2 provides a general-purpose authorization layer for ERC-20 tokens.

This path:

- works with any ERC-20 token once it has been approved to Permit2
- allows off-chain authorization of transfers
- enables x402 settlement even when the token does not natively support authorization-based transfers

This is the broadest compatibility path and is useful for existing assets such as stablecoins and other standard ERC-20 tokens.

### EIP-3009-based model

If a token implements EIP-3009, x402 can use the token's native authorization flow directly.

This path:

- does not require Permit2
- does not require a prior approval to an external authorization contract
- more closely matches direct authorization-based payment semantics

Compared to Permit2, this model has fewer moving parts because the authorization and transfer model is implemented directly by the token itself.

### Choosing between the models

In practice:

- use **Permit2** for tokens that do not implement EIP-3009
- use **EIP-3009** for tokens that natively support authorization-based transfers

Permit2 provides broad compatibility across existing ERC-20 tokens.
EIP-3009 provides a more direct authorization-based model when supported by the token.

## Permit2

Permit2 is the signature-based transfer primitive used by the Permit2 integration path.

It allows users to authorize token transfers off-chain under explicit constraints, such as:

- token
- amount
- nonce
- deadline

In the x402 flow, Permit2 is responsible for validating the signed transfer authorization and executing the token transfer.

Permit2 itself does not enforce x402 payment semantics. It only enforces the signed authorization it receives.

## x402ExactPermit2Proxy

Despite its name, `x402ExactPermit2Proxy` is **not** an upgradeability proxy and does not rely on delegatecall-based forwarding.

It is a standalone settlement contract built on top of Permit2.

### Role

`x402ExactPermit2Proxy` acts as the authorized spender in Permit2 signatures and executes x402 payments using additional contract-level validation.

Its responsibilities include:

- validating settlement inputs
- enforcing non-zero owner, destination, and amount
- enforcing `validAfter`
- binding the destination address into the signed authorization via a witness
- submitting the Permit2 witness transfer
- optionally attempting an EIP-2612 permit before settlement

### Exact-amount settlement

This contract always settles the exact permitted amount.

That makes its behavior closer to `transferWithAuthorization`-style flows, where the signed authorization corresponds directly to the transferred amount, rather than allowing partial settlement.

### Witness-bound destination

A key property of this design is the use of a witness structure containing:

- `to`
- `validAfter`

The witness hash is signed together with the Permit2 authorization and binds the destination address cryptographically.

This prevents a facilitator or relayer from redirecting funds to a different recipient after the user has signed.

## Settlement Paths

### `settle(...)`

This is the standard settlement path.

It assumes Permit2 is already authorized and:

- computes the witness hash
- validates the settlement conditions
- executes the Permit2 witness transfer
- transfers the exact permitted amount

### `settleWithPermit(...)`

This path supports a more gasless integration flow for tokens that support EIP-2612.

It:

- first attempts an EIP-2612 `permit()` call to approve Permit2
- then performs the same Permit2-based settlement flow

Important behavior:

- the EIP-2612 permit attempt does not need to succeed if the required Permit2 approval already exists
- failure of the token `permit()` call is emitted via events rather than forcing settlement failure
- the EIP-2612 amount must exactly match the Permit2 permitted amount

## Trust Model

### What is trustless here

The payment destination is bound into the signed witness data.

This means the settlement contract cannot redirect funds to an arbitrary address without invalidating the signature.

The contract also:

- uses an immutable Permit2 address
- performs direct validation of core settlement fields
- does not expose admin-controlled settlement behavior in the provided implementation

### What integrators should still verify

Integrators should still review:

- the exact witness structure being signed
- which fields are and are not cryptographically bound
- whether exact-amount settlement is appropriate for their use case
- whether the token supports EIP-2612 if using `settleWithPermit(...)`

### Upgradeability clarification

`x402ExactPermit2Proxy` is not an upgradeability proxy.

It is a regular deployed contract that integrates with Permit2 and adds x402-specific settlement logic.

## Canonical Permit2 Address

The base contract stores the Permit2 address as an immutable constructor argument.

Using the same canonical Permit2 address on each EVM chain preserves identical init code and supports deterministic CREATE2 deployment of the x402 settlement contracts across chains.

## Network Addresses

For deployed addresses, see: [Networks](../../development/networks.md)
