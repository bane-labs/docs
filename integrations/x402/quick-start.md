# x402 Quick Start

## Prerequisites

To use x402 on Neo X, you need:

- access to a Neo X RPC endpoint
- a wallet capable of signing the required authorization payloads
- a token supported by the settlement flow
- an agent, relayer, or backend that can submit transactions on-chain

If you want to use `settleWithPermit(...)`, the token must also support EIP-2612.

## Payment Flow

A typical x402 flow consists of four steps.

### 1. Obtain payment requirements

A service defines the payment requirements, such as:

- token
- amount
- recipient
- timing constraints

These parameters are used to construct the authorization payload the user will sign.

### 2. Sign the authorization

The user signs a Permit2-based authorization.

In the exact settlement flow, the signed payload is bound to:

- the token and amount
- the destination address through the witness
- the `validAfter` constraint

This ensures the payment can only be settled under the agreed conditions.

### 3. Submit settlement

An agent or backend submits the settlement transaction to:

- `x402ExactPermit2Proxy`

Depending on the flow, this is either:

- `settle(...)`
- `settleWithPermit(...)`

The submitter pays gas for execution.

### 4. Execute on-chain

The contract:

- validates the settlement inputs
- checks timing constraints
- uses Permit2 to execute the witness-bound transfer
- emits a settlement event on success

Once confirmed, the payment is settled on-chain.

## When to use `settleWithPermit(...)`

Use `settleWithPermit(...)` when:

- the token supports EIP-2612
- you want to combine approval and settlement into a single on-chain transaction path

This can improve UX by avoiding a separate prior approval step.

However:

- the EIP-2612 amount must match the Permit2 permitted amount exactly
- token-side `permit()` failure does not necessarily prevent settlement if Permit2 approval already exists

## Notes

- users do not need to submit the transaction themselves
- agents can handle execution and gas payment
- the destination is cryptographically bound through the witness
- this contract settles the exact permitted amount, not a partial amount

## Next Steps

- Review [Contracts](./contracts.md) for implementation details and trust assumptions
- Check [Networks](../../development/networks.md) for deployed addresses
