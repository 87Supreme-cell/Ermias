# 07 · Audit log

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
A local record of everything the system did, opened from the left strip.

## Impact on the build
It makes every gate decision, retrieval, approval and external call traceable.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Saved locally. Each row can be opened for detail.
- Gate rejections and anything that left the machine are shown in the warning color.
- Open full log for the complete record.

## Behavior and states
- New events appear at the top of the panel.
- Opening a row shows its full detail.

## Data
`audit_event.schema.json`

## Security rules
- The log is never sent off the machine.

## Acceptance tests
- [ ] Every gate decision, retrieval, approval and external call produces an entry.
- [ ] Entries survive a restart.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Choosing a tamper-evidence method (open question 9).

## Reference code
- `audit_log_panel.reference.html`
