# 05 · Chat input

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The message area under PRIMARY FOCUS.

## Impact on the build
It is where tasks start and where model and tool choices are made for each message.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- **+ button** to attach a one-off document for this session only.
- Message box; Model select (local default; external marked data only); Tools select; Send.
- The chat area keeps its size when the layout grows.

## Behavior and states
- Choosing a cloud model triggers the per-call approval set in Settings (on by default).
- Tools offered are only those on the gate's allowlist.

## Data
`model_provider.schema.json`, `gate_action.schema.json`

## Security rules
- One-off documents are never added to a ranked database.

## Acceptance tests
- [ ] An attached document appears in Files in context as one-off.
- [ ] With **Ask me before every call** on, choosing a cloud model asks for approval before sending.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.

## Reference code
- `chat_input.reference.html`
