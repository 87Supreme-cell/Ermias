# 08 · Task chain

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The stages of the current project, opened from the right strip.

## Impact on the build
Shows where the work stands and what is waiting on the person.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Stages shown as done, current or waiting. Current stage highlighted in the accent color.
- The tab shows current progress (for example `4/5`).

## Behavior and states
- Stages come from the project's kickoff.

## Data
`task.schema.json`

## Security rules
None beyond the app-wide rules in `CLAUDE.md`.

## Acceptance tests
- [ ] Completing a step advances the stage and updates the tab figure.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.

## Reference code
- `task_chain_panel.reference.html`
