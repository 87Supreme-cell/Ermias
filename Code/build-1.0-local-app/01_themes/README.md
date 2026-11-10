# 01 · Themes

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
Four color themes and the rules for glass and solid surfaces.

## Impact on the build
Every screen reads its colors from `Code/shared/themes.json`. No color is hard-coded anywhere else.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Themes: **Blues** (default), **Cyberpunk**, **Sunburst**, **Earth tones**.
- Glass (translucent with `blur(18px) saturate(150%)`): header, edge strips, side panels. Overlay panels use the more opaque `flyout` color, `blur(22px) saturate(160%)`, and `shadow`.
- Solid: PRIMARY FOCUS and chat, so text stays readable.
- Each theme has a soft multi-glow background (`bg`) so the glass reads as glass.
- Accent = verified or active. Warning = needs a human. Warnings always carry text or a symbol as well as color.
- Connections box and its windows use the inverted `inv*` colors.
- Type: Inter for text, JetBrains Mono for data. Weights used: 400 and 500 for text, 600 for headings and buttons, 700 for the PRIMARY FOCUS title in capitals.

## Behavior and states
- The theme switch is a row of swatch buttons in the header. Switching applies instantly to every screen.

## Data
`Code/shared/themes.json`. Adding a custom theme means adding one entry with every key.

## Security rules
- Fonts and icons are bundled with the app.

## Acceptance tests
- [ ] Every color on every screen comes from `themes.json`.
- [ ] Text meets 4.5:1 contrast in all four themes.
- [ ] Accent and warning can be told apart in a grayscale screenshot of every theme.
- [ ] Switching theme changes every screen without a restart.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Where the chosen theme is saved (open question 8).

## Reference code
- `../../shared/themes.json`
