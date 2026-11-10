# 10 · Project kickoff

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The guided start of every new project: a short series of questions that turns an idea into a goal and agreed benchmarks.

## Impact on the build
Grading (09) and the task chain (08) are built from what is agreed here.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Five steps: Goal, Deliverable, Sources, Benchmarks, Confirm.
- Each step asks one question, offers recommended answers, and allows a free-text answer.
- A live **AI synthesis** panel shows the draft goal, deliverable, draft benchmarks (marked recommended) and assumptions to confirm.
- The person approves every benchmark before grading starts.
- Save and exit at any point.

## Behavior and states
- Answered steps show as a summary with an Edit link.
- The synthesis panel updates after each answer.

## Data
`kickoff.schema.json`

## Security rules
- Kickoff runs on the default local model unless the person chooses otherwise.

## Acceptance tests
- [ ] A project cannot reach grading without approved benchmarks.
- [ ] Editing an earlier answer updates the synthesis.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.

## Reference code
- `../../reference/Kickoff.dc.html`
