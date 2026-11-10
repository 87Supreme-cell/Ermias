# Shared

- `themes.json`: every color for the four themes. Reference code writes these as `{{t.<key>}}`. Key groups:
  - `bg`, `ink`, `muted`: page background and text.
  - `glass`, `glassBorder`, `flyout`, `shadow`: translucent surfaces and overlay panels.
  - `solid`, `subtle`, `line`, `track`, `bubble`: solid surfaces, rows, dividers, bars.
  - `accent`, `onAccent`, `accentSoft`, `accentText`: verified or active.
  - `warn`, `onWarn`, `warnSoft`, `warnText`, `dashed`: needs a human.
  - `btnBg`, `btnBorder`: buttons and inputs.
  - `inv*`: inverted colors for the connections box and its windows.
  - `riskLocal`, `riskHybrid`, `riskExposed`: connection tiers (always paired with a shape).
  - `swatch`: the theme's preview dot.
- `contracts/`: draft data formats. **Status: draft, owner approval required.** They are written as JSON Schema so the same file can validate data and define what the gate accepts.
