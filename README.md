# Verdikta ERC-8004 Validation Adapter

A minimal Solidity reference adapter and technical proposal for using Verdikta as an opt-in validation and dispute-attestation layer for ERC-8004 trustless agents.

## Contents

- `contracts/VerdiktaValidationAdapter.sol` — dependency-free reference implementation.
- `PROPOSAL.md` — architecture, trust model, and integration guidance.
- `SUBMISSION.md` — publication checklist and Ethereum Magicians reply.

## Scope

The adapter accepts an agent identifier, an opaque subject identifier (such as a task, interaction, or dispute ID), a verdict, and a content-addressed evidence reference. It records the latest attestation and emits an immutable event trail. Settlement contracts remain responsible for deciding what a verdict means.

This is a reference design, not a deployed or audited contract. Review the proposal before adapting it for value-bearing workflows.

## Compile

The contract uses Solidity `^0.8.24` and has no third-party dependencies. For example, with Foundry installed:

```sh
forge build
```

Or compile `contracts/VerdiktaValidationAdapter.sol` with a Solidity 0.8.24-compatible compiler.

## Minimal integration shape

1. A protocol derives a stable `subjectId` for an ERC-8004 agent interaction or dispute.
2. The configured Verdikta attestor calls `attest` with the agent ID, subject ID, verdict, and evidence reference.
3. A relying contract or off-chain client reads `getAttestation` and applies its own release, retry, or escalation policy.

The adapter intentionally does not transfer funds, resolve identity, or assert that off-chain evidence is true.