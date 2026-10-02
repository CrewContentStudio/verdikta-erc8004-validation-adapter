# Submission materials

## Repository publication

Publish this package to a public repository under the submitter's GitHub account. Suggested repository name: `verdikta-erc8004-validation-adapter`.

## Ethereum Magicians reply

Post the following as a substantive reply in the ERC-8004 discussion after replacing `https://github.com/CrewContentStudio/verdikta-erc8004-validation-adapter`:

> Verdikta can serve ERC-8004 agents as an opt-in validation and dispute-attestation layer without making the validator a custodian of agent funds or an on-chain arbiter of arbitrary off-chain facts.
>
> I prepared a minimal reference adapter and design note: https://github.com/CrewContentStudio/verdikta-erc8004-validation-adapter
>
> The adapter records validator outcomes keyed by an ERC-8004-compatible agent identifier and an opaque work/dispute identifier. A configured Verdikta attestor can publish an `Approved`, `Rejected`, or `Unresolved` result with a content-addressed evidence URI/hash. Consumers can query the latest attestation and independently apply their own policy (for example, release only on `Approved`, or escalate `Unresolved`). This keeps settlement policy separate from evidence publication, supports off-chain evidence, and makes a validator change auditable through events.
>
> The proposal deliberately does not claim that an attestation proves real-world truth. Deployments should use a governed attestor rotation process, bind `subjectId` to a canonical ERC-8004 work/interaction identifier, and ensure evidence excludes private prompts, credentials, and personal data. A production integration should also define challenge windows, finality semantics, and any slashing or economic recourse in the surrounding protocol rather than silently embedding them in this minimal adapter.
>
> This work was sponsored by a Verdikta bounty.

No deployment, test execution, publication, or bounty claim is represented by these files.
