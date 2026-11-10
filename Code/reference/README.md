# Reference design

The complete approved design, exported from the design canvas.

| File | Screen |
|---|---|
| `Splash.dc.html` | 1 · Sign in and projects |
| `Kickoff.dc.html` | 2 · Project kickoff |
| `Main.dc.html` | 3 · Workbench |
| `Settings.dc.html` | 4 · Settings: model providers |
| `canvas.json` | Layout of the four screens on the canvas |
| `assets/ermias-logo.png` | Logo |
| `screenshots/` | Rendered screenshots of every screen and key state |

How to read these files:
- Markup sits inside `<x-dc>`. The `<script type="text/x-dc">` block at the bottom holds the screen's state and the theme table.
- `{{name}}` is a value supplied by that script, for example `{{t.accent}}` from `Code/shared/themes.json`.
- `<sc-if>` shows its content when the value is true. `<sc-for>` repeats its content for each item.
- `support.js` is the design tool's runtime and is not included. These files are a visual spec; rebuild them in the chosen stack.
- The logo appears in the design as `/_blob/...`, a design-tool asset address. Use `assets/ermias-logo.png`.
- Fonts load from Google Fonts in the design only. The app must bundle Inter and JetBrains Mono locally.
- All numbers, names and log entries are mock data.
