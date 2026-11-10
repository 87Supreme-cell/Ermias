# Decision log

Append-only. Every decision made while building Ermias, and who made it.

- **HUMAN**: decided by the project owner.
- **CLAUDE**: decided by Claude Code within the owner's rules (`CLAUDE.md`). Any CLAUDE decision can be overturned by the owner; the reversal is logged as a new entry, never by editing an old one.

Locked design changes are also recorded in `DESIGN_DECISIONS.md`, as that file requires. Drift (a gap between the spec and the code, or within the spec) is tracked per work order in `docs/work-orders/`.

| ID | Date | By | Decision | Why | Ref |
|---|---|---|---|---|---|
| D-001 | 2026-11-10 | HUMAN | Stack: Flutter (Dart) desktop UI + Rust core. No Python; ingestion is Rust too. Closes open question 1. | Fewest runtimes and dependencies; one memory-safe core. | OQ1 |
| D-002 | 2026-11-10 | HUMAN | Merge the spec PR to `main`; one branch per work order, one PR per section. | Matches `CLAUDE.md` build rules; reviewable history. | PR #1 |
| D-003 | 2026-11-10 | HUMAN | Audit trail: this file + `docs/work-orders/WO-n.md` (scope, drift flags, smoke-test results). | Every decision traceable to a person or to Claude. | — |
| D-004 | 2026-11-10 | HUMAN | Seven milestone work orders (WO-1 shell/themes/header … WO-7 grading). Each closes with a smoke test. | Visible milestones with proof they work. | README → Build order |
| D-005 | 2026-11-10 | HUMAN | Fix themes that fail the grayscale accent-vs-warning test by changing the warning color. | Spec acceptance test (01_themes) failed for Earth tones (ratio 1.00) and was weak for Blues (1.28). | 01_themes |
| D-006 | 2026-11-10 | HUMAN | Tighten only `gate_action.schema.json` now; `audit_event` and `grade` gaps stay open until WO-4 and WO-7. | Keep WO-1 focused. | contracts |
| D-007 | 2026-11-10 | HUMAN | README rewritten to a professional engineering standard: what and why up front, screenshots, a reviewer link index. | The repo must be quick to evaluate. | README |
| D-008 | 2026-11-10 | CLAUDE | README describes only what is built; planned work is labeled planned. | Accuracy over impression. | README |
| D-009 | 2026-11-10 | HUMAN | Working clone at `~/Ermias`. | Owner's choice. | — |
| D-010 | 2026-11-10 | HUMAN | Rust core with `flutter_rust_bridge` from WO-1, versions pinned. | Live memory/CPU and hashing from day one. | 02_header_status |
| D-011 | 2026-11-10 | CLAUDE | Kept the designed warning colors until the owner chose replacement values. | Locked values change only with owner approval. | D-005 |
| D-012 | 2026-11-10 | CLAUDE | Did not change or route around sandbox settings; escalated to the owner. | Permissions are the owner's decision. | — |
| D-013 | 2026-11-10 | HUMAN | Warning color is **yellow** (not the proposed dark brown) in Blues and Earth tones. | Brown lost the warning feel; yellow passes the grayscale test (3.46 and 2.71). | D-005 |
| D-014 | 2026-11-10 | CLAUDE | Text on a yellow warning fill uses the theme's dark ink, not white; warning chips get a dark-amber border. | White on yellow fails 4.5:1; a yellow fill alone is faint on light backgrounds (≈1.8:1). | D-013 |
| D-015 | 2026-11-10 | HUMAN | Font is **Monaco**, replacing Inter and JetBrains Mono. Changes a locked decision. | Owner preference. | 01_themes |
| D-016 | 2026-11-10 | CLAUDE | Monaco is requested from the OS, not bundled; fallbacks Menlo (older macOS), Consolas (Windows), DejaVu Sans Mono (Linux). | Monaco's license does not allow redistribution and it exists only on macOS. Nothing is fetched at runtime. | D-015 |
| D-017 | 2026-11-10 | HUMAN | README opens with what Ermias is and why within the first screen; includes screenshots and a reviewer link index. | Fast review. | D-007 |
| D-018 | 2026-11-10 | CLAUDE | The reviewer link index lives in the repo (README + `docs/`), not the GitHub Wiki. | The Wiki is a separate repo that PRs don't review or version with the code. | D-017 |
| D-019 | 2026-11-10 | HUMAN | `allowUnsandboxedCommands: true`; git, flutter and cargo excluded from the sandbox. | Builds need to write `.git`, the Flutter cache and the Cargo registry. | — |
| D-020 | 2026-11-10 | CLAUDE | Paused WO-1 until PR #1 was actually merged and the panel-offset conflict was raised. | `main` had no spec; the spec contradicted itself (104 px vs 164 px). | WO-1 drift F-1 |
| D-021 | 2026-11-10 | CLAUDE | Pinned: Flutter 3.47.5 (Dart 3.13.4), `flutter_rust_bridge` 2.13.0 (latest stable; 2.14 is beta), `sysinfo` 0.40.1, `sha2` 0.11.1. | Exact pins per `CLAUDE.md`. Versions checked against crates.io on 2026-11-10. | DEPENDENCIES.md |
| D-022 | 2026-11-10 | CLAUDE | Repo layout: Flutter app in `app/`, Rust core in `core/`; specs stay in `Code/`. | Keeps spec and product separate; one obvious place for each. | — |
| D-023 | 2026-11-10 | CLAUDE | `Code/shared/themes.json` stays the single source; the app parses its CSS color/gradient/shadow strings in Dart. A test fails if the app's copy differs from the source byte for byte. | Avoids rewriting the shared file into a second format (drift item in the kickoff review). | 01_themes |
| D-024 | 2026-11-10 | CLAUDE | Grayscale test threshold: accent vs warning relative-luminance ratio ≥ 1.5. | The spec gives no number; 1.5 is clearly visible and all four themes pass after D-013. | 01_themes |
| D-025 | 2026-11-10 | CLAUDE | WO-1 section order: 01 themes, then 00 shell, then 02 header. | The shell cannot be built without the theme layer. | README → Build order |
| D-026 | 2026-11-10 | CLAUDE | Overlay panels anchor to the top of the edge strips (164 px at the 1440 px reference width) instead of a fixed pixel offset. Owner to confirm the locked README line. | Reference code and screenshots moved to 164 px in `da17c0d`; anchoring stays correct when the header wraps. | WO-1 drift F-1 |
| D-027 | 2026-11-10 | CLAUDE | Turned off the Flutter tool's analytics on this machine (`flutter config --no-analytics`). Reversible with `flutter config --analytics`. | "No telemetry" rule; the dev tool reported usage by default. | CLAUDE.md |
| D-028 | 2026-11-10 | CLAUDE | **Correction:** drift flag F-1 was raised in error. Commit `da17c0d` had already updated `00_shell/README.md` to "just below the header (164 px in the reference)"; my diff output was truncated. Spec was consistent. D-026 matches it. | Audit trail records mistakes rather than erasing them. | WO-1 F-1 |
| D-029 | 2026-11-10 | HUMAN | Approved inline execution of WO-1, the "aligned with strips" panel position, and the `sysinfo` and `sha2` crates. Asked for all dependency issues to be fixed. | — | WO-1 |
| D-030 | 2026-11-10 | CLAUDE | Removed the Flutter template's `cupertino_icons` (unused) and `flutter_lints` (floating `^6.0.0`); lint rules are listed directly in `app/analysis_options.yaml`. Dart and Flutter SDK versions pinned exactly in `pubspec.yaml`. | No unapproved or floating dependencies (D-029). | DEPENDENCIES.md |
| D-031 | 2026-11-10 | CLAUDE | Each edge strip shows a small vertical `MOCK` label while its figures are mock data. | `CLAUDE.md` requires mock data to be labeled in the interface; a 44 px tab has no room for a per-figure tag. | 00_shell |
| D-032 | 2026-11-10 | CLAUDE | `Workbench.onChanged` passes an update function (`ShellUpdate`), not a finished state. Deviates from the plan's interface. | A widget test showed two taps inside one frame lost the first panel; applying updates to the owner's latest state fixes it. | WO-1 Task 6 |
| D-033 | 2026-11-10 | CLAUDE | Icons drawn from the reference SVG path data by a small in-house parser (M L H V C S A Z) instead of an SVG package. | Avoids a new dependency; only the approved reference icons are needed. | WO-1 Task 6 |
| D-034 | 2026-11-10 | CLAUDE | Chat area fixed at 172 px. | The spec fixes the chat size but not the number; 172 px is measured from `Code/reference/screenshots/04-workbench.png`. | 05_chat_input |
| D-035 | 2026-11-10 | CLAUDE | PR 1 review outcome. **Fixed:** glow layers painted in CSS order (first layer on top); CSS shadow blur converted so Flutter's sigma equals CSS's (blur ÷ 2); pixel tests added for layer order and ellipse geometry. **Rejected:** "glass blur sigma is 2× the spec" (CSS `blur()` takes the standard deviation, so sigma 18 is correct); "first gradient stop may carry N%" (already rejected by the parser). | Each finding verified against the CSS Filter Effects and Backgrounds specs before acting. | PR 1 review |
| D-040 | 2026-11-10 | CLAUDE | PR 2 review outcome (verdict: approve, no CRITICAL/HIGH). **Fixed:** SVG arc flags may be packed ("0010"), parser rewritten as a scanner that reads flags as single characters; panel width clamped at zero; edge-strip tabs scroll when the window is short; macOS window minimum 1024×720, opening size 1440×960. **Added tests:** keyboard reaches right-strip tabs and close buttons; smallest window lays out both panels. | All three findings verified valid; the narrow-window one also exposed the strip overflow at minimum height. | PR 2 review |
