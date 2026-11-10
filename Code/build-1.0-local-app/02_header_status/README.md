# 02 · Header and status

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The top bar: identity, session state, live resource tracking, theme switch, Briefing room, Settings, and the connections box.

## Impact on the build
This is where the person sees at a glance what is running and whether anything is leaving the machine.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Row 1: name, session pill, resource strip (model name, quantization and hash check, memory, CPU, network summary, date and time).
- Row 2: theme swatches, Briefing room button, Settings gear (opens `13_settings`), and the connections box (`03_connections`) **centered**.
- Monospace for the resource strip.

## Behavior and states
- The session pill shows the real session state. The reference text is mock and predates the switch to password sign-in.
- The model hash check compares the loaded model file's SHA-256 with the pinned value and shows ✓ or a warning.
- Network summary reads from the connections monitor.
- Briefing room is a button only; its behavior is open question 6.

## Data
Model identity from `model_provider`; network summary from `connection`.

## Security rules
- A failed hash check is shown in the warning color and logged to the audit log.

## Acceptance tests
- [ ] Memory, CPU and clock update live.
- [ ] Changing the model file makes the hash check fail visibly.
- [ ] The gear opens Settings.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Defining what Briefing room does.

## Reference code
- `header.reference.html`
