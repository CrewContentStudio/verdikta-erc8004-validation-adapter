# Verdikta as an ERC-8004 Validator

## Objective

ERC-8004 agent systems need a way to consume independent validation without forcing every protocol to implement dispute evidence storage, reviewer operations, and validator key management. Verdikta can provide that role as an opt-in attestation service: it evaluates a defined agent interaction or dispute off-chain, publishes a signed on-chain outcome, and supplies a hash-bound evidence reference.

## Design

`VerdiktaValidationAdapter` is a small on-chain registry with one authorized attestor address. The attestor writes:

- `agentId`: the canonical agent ID chosen by the ERC-8004 integration;
- `subjectId`: a `bytes32` identifier for a task, interaction, claim, or dispute;
- `verdict`: `Approved`, `Rejected`, or `Unresolved`;
- `evidenceHash` and `evidenceURI`: a tamper-evident reference to the evidence bundle.

Each write emits `ValidationAttested`. The registry retains the latest result for inexpensive consumption; historical event logs preserve prior results and attestor rotations.

The adapter deliberately does not prescribe the ERC-8004 registry ABI. That avoids hard-coding an evolving interface and allows an integration to use its authoritative identifiers. A concrete deployment should document exactly how it derives `subjectId`, for example `keccak256(abi.encode(chainId, protocol, agentId, interactionId))`.

## Relying-party policy

A payment, reputation, or workflow contract should treat the adapter as an input, not as an automatic settlement engine. It can require an `Approved` result before releasing funds, route `Rejected` results to a refund path, and hold or escalate `Unresolved` results. The consuming protocol must additionally verify that the returned attestor is its expected adapter attestor and that the subject binding matches its own interaction.

## Disputes and evidence

Disputes begin off-chain or in a protocol-specific contract. Parties submit the agreed evidence to Verdikta's process. Verdikta produces a canonical evidence manifest, hashes it, and attests the outcome. Evidence should be content-addressed where possible and must not include secrets, private prompts, access tokens, or personal data. If sensitive material is unavoidable, publish only a commitment and keep access-controlled material under the process rules.

## Trust and security boundaries

This adapter proves only that its configured attestor published a statement at a given block time. It does not prove an off-chain fact, provide censorship resistance, arbitrate appeals, or custody assets.

Production deployments should:

1. Put `owner` behind a multisig or protocol governance process and make attestor rotation observable before it takes effect.
2. Define verdict finality, challenge periods, appeal authority, and evidence retention outside this minimal contract.
3. Bind `subjectId` unambiguously to one chain, protocol, agent, and interaction.
4. Require a dispute bond, slashing system, or other economic recourse only if the wider protocol has specified and audited it.
5. Audit any integration that uses an attestation to move funds.

## Why this separation is useful

The adapter keeps validator operations and evidence publication interoperable while leaving ERC-8004 protocols free to choose their own settlement rules. That supports multiple dispute policies without giving the validator implicit control over agent funds.