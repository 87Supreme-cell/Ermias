# 03 · Connections monitor (beta)

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
A high-contrast box centered in the header that shows every external connection, grouped by risk, with a drill-down window for the ones that matter.

## Impact on the build
It is how the app keeps external connections allowed but monitored.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Tiers: **Green, Local** (loopback or local processes; not openable). **Orange, Hybrid** (internet allowed but not active, or metadata-only calls such as update checks; openable). **Red, Exposed** (active connection sending content; openable).
- Each tier has its own shape: circle, diamond, triangle.
- The box uses the theme's inverted colors.
- Only Hybrid and Exposed open a window.

## Behavior and states
- The box shows counts per tier.
- Clicking Hybrid or Exposed opens a centered window listing each connection: name, destination, process, what was sent and received, who approved it and when, and whether it is encrypted.
- Actions: Revoke (hybrid), End connection (exposed), Open in audit log.
- Every tier change is written to the audit log.
- Labeled beta in Build 1.0.

## Data
`Code/shared/contracts/connection.schema.json`

## Security rules
- Monitored: pings from the app and connected folders, plus API and MCP connections.
- Ending or revoking a connection takes effect immediately and is logged.

## Acceptance tests
- [ ] A cloud call with a prompt shows as Exposed while active, then drops to Hybrid.
- [ ] The Local tier cannot be opened.
- [ ] Revoke and End connection work and appear in the audit log.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Choosing how to observe per-process network traffic on an OS (open question 5).

## Reference code
- `connections_hybrid.reference.html`, `connections_exposed.reference.html`: the drill windows
- The box itself is in `../02_header_status/header.reference.html`
