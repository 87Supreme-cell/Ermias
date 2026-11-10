# 00 · Shell and edge tool strips

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The frame of the workbench: header across the top, an edge tool strip on each side, PRIMARY FOCUS and chat in the center, and overlay panels that open from the strips. This is the app's core layout principle (progressive disclosure, focus + context).

## Impact on the build
Every other workbench section lives inside this frame. Build it first so sections can be dropped in on mock data.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Edge tool strips on **both** sides, 56 px wide. Left: Databases, Audit log. Right: Task chain, Project grade.
- Each tab: icon on top, vertical label reading bottom to top, short status figure below (for example `4/5`, `8.1`). A warning-colored count of items that need the person sits under the tabs.
- **One panel open per side.** Both sides can be open at once.
- Panels **overlay** the center (they do not push it): 400 px wide, opening just below the header (164 px from the top in the reference), 96 px in from their side. They never cover the header.
- A panel closes from its tab or its close button.
- The center column takes all remaining width; the layout fills the window height.
- New panels are added as tabs, never as new columns.
- Touch targets are at least 44 px.

## Behavior and states
- Click a tab: its panel opens and the tab switches to the accent color; click again to close.
- Opening another tab on the same side replaces the open panel.
- State: `left` is `null`, `db` or `log`; `right` is `null`, `tasks` or `grade`.

## Data
Panel contents come from sections 06–09. Status figures on tabs are read from the same data.

## Security rules
- No layout element may load anything from the network.

## Acceptance tests
- [ ] Open Databases, then Audit log: Databases closes, Audit log opens.
- [ ] Open Databases and Project grade together: both stay open.
- [ ] Each panel closes from its tab and from its close button.
- [ ] With all panels closed, PRIMARY FOCUS spans the full width between the strips.
- [ ] Tabs are reachable by keyboard and announce expanded or collapsed.
- [ ] An open panel never covers the header or the connections box.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- A new panel seems to need its own column.

## Reference code
- `shell_skeleton.reference.html`: frame structure
- `left_strip.reference.html`, `right_strip.reference.html`: the strips
- `logic.reference.js`: state for strips, connections and theme
