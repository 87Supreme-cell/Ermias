# 09 · Project grade

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
A score for the project's progress against its agreed benchmarks, opened from the right strip.

## Impact on the build
Grading is a core function. It keeps the work tied to the goal and catches drift.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Grading is derived from the benchmarks approved at kickoff and worked backward from them.
- Shows the total out of 10, change since the last milestone, its components, and a **Needs you** box with a Review now action.

## Behavior and states
- Updates after each step.
- Needs you lists rejected gate calls and claims whose samples disagreed.

## Data
`grade.schema.json`, `kickoff.schema.json`

## Security rules
- Grades are computed locally from logged events.

## Acceptance tests
- [ ] Each number traces back to logged events.
- [ ] Changing an approved benchmark recalculates the grade and logs the change.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Choosing components or weights (open question 2).

## Reference code
- `project_grade_panel.reference.html`
