# 04 · PRIMARY FOCUS

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The center of the workbench: the conversation with cited answers, and a narrow column showing exactly what the model can see.

## Impact on the build
This is where auditing happens. The person can trace every sentence to its source.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Title **PRIMARY FOCUS** in bold capitals.
- Context usage bar (tokens used of the model's window).
- Every answer sentence carries a citation chip: `database · chunk id`.
- A sentence whose repeated samples disagreed is highlighted in the warning color with the result (for example `samples disagreed 2 of 5`).
- Side column, 250 px: Files in context (with weights; one-off documents labeled `one-off · unranked`), Drift flags, Steps (Select databases, Retrieve and rank, Gate check, Draft answer, Human review).

## Behavior and states
- Files in context lists exactly the chunks sent to the model, nothing more.
- Steps update as the work moves through each stage.
- An uncited claim raises a Sources drift flag.

## Data
`citation.schema.json` for chunks and chips.

## Security rules
- What is listed in Files in context must match what was sent to the model, byte for byte.

## Acceptance tests
- [ ] Every sentence in an answer has a chip that opens its source.
- [ ] An uncited sentence raises a drift flag.
- [ ] Attaching a one-off document adds it to Files in context as one-off.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Defining drift flags or the number of samples (open question 3).

## Reference code
- `primary_focus.reference.html`
