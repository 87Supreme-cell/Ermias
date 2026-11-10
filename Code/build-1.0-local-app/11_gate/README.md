# 11 · The gate

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
A small deterministic program, with no model inside it, that sits between the model and everything the model can touch. The model may only propose actions in a fixed format; the gate checks each one against an allowlist and rejects everything else.

## Impact on the build
It is what makes hidden instructions in a document harmless: the model can be fooled, the gate cannot. It is built before any real data or connection is attached.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Deterministic: no model decides what is allowed.
- Reject by default.
- Build 1.0 allowlist: `search(database, query)` and `get_source(chunk_id)`. Format in `gate_action.schema.json`.
- Every cloud call requires the person's approval, unless they have turned off **Ask me before every call** for that provider in Settings (it is on by default).
- Built to be replaced easily: other sections talk to it only through the contract.

## Behavior and states
- Each proposed action is validated against the schema, then against the allowlist and active databases.
- A rejection is logged in full and the person sees a short message.
- Tool outputs and file contents are checked too, not only the opening request.

## Data
`gate_action.schema.json`

## Security rules
- The allowlist lives in a file the model cannot write to.

## Acceptance tests
- [ ] A malformed or unlisted action is rejected and logged.
- [ ] A search against an inactive database is rejected.
- [ ] A document containing instructions cannot cause any action outside the allowlist.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Any change to the allowlist.

## Reference code
- Spec only; no visual design.
