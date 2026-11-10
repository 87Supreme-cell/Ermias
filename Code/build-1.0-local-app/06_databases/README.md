# 06 · Databases

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The ranked list of sources, opened from the left strip.

## Impact on the build
Retrieval combines relevance with these ranks, so the person, not the model, decides which sources carry the most authority.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Each entry: rank, name, grade out of 10, weight bar (0–1), on/off.
- External answers sit last as `external.db`, labeled data only, off by default, shown with a dashed warning border.
- Grade uses the five-part rubric, 0–2 each: provenance, license, PII handling, reproducibility, independent audit.
- Retrieval score = relevance × authority weight.
- Build 1.0 databases are **local folders**.

## Behavior and states
- Adjust ranks and weights from the panel.
- Turning a database off removes it from retrieval immediately.

## Data
`database_entry.schema.json`

## Security rules
- Each folder's contents are hashed; a changed hash is flagged before use.

## Acceptance tests
- [ ] Reordering ranks changes which chunks are retrieved first.
- [ ] A turned-off database contributes no chunks.
- [ ] A changed folder is flagged before its next use.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Choosing a retrieval method or embedding model (open question 4).

## Reference code
- `databases_panel.reference.html`
