# WO-1 · Shell, themes and header — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Status:** Complete, smoke test passed 2026-11-10 · **Branches (stacked):** `wo-1/01-themes` → `wo-1/00-shell` → `wo-1/02-header` · **PRs:** one per section; docs and smoke results ride with 02

**Goal:** A running Ermias desktop window showing the workbench frame (header, both edge tool strips, overlay panels, center placeholder) in all four themes, with live clock, memory and CPU from a Rust core, and a real SHA-256 model hash check. Everything not yet built is labeled `MOCK`.

**Architecture:** Flutter desktop app in `app/` renders all UI. A Rust crate in `core/` does system work (memory, CPU, file hashing) and is called through `flutter_rust_bridge`. UI state is held in small immutable Dart value classes; widgets read state and emit intents. Themes are read from `Code/shared/themes.json`, the single source of truth, by a Dart parser for the CSS subset the file uses.

**Tech Stack:** Flutter 3.47.5 / Dart 3.13.4 (SDK only, no pub packages besides the bridge) · Rust 1.98.1 · `flutter_rust_bridge` 2.13.0 · `sysinfo` 0.40.1 · `sha2` 0.11.1

**Spec:** `Code/build-1.0-local-app/01_themes/README.md`, `00_shell/README.md`, `02_header_status/README.md`; visual reference `Code/reference/Main.dc.html` and `Code/reference/screenshots/04–11`.

## Global Constraints

- Local first: no network access at runtime, no telemetry, no update checks. (`CLAUDE.md`)
- Every dependency pinned exactly and recorded in `DEPENDENCIES.md` with its reason. (`CLAUDE.md`)
- Mock data is labeled `MOCK` in the interface and in code, behind an interface the real source will implement. (`CLAUDE.md`)
- No color is hard-coded outside `themes.json`. (01_themes)
- Font: Monaco, fallbacks Menlo, Consolas, DejaVu Sans Mono; requested from the OS, never bundled or fetched. (D-015, D-016)
- Weights: 400/500 text, 600 headings and buttons, 700 PRIMARY FOCUS title. (01_themes)
- Glass: `blur(18px) saturate(150%)` for header and strips; overlay panels `flyout` + `blur(22px) saturate(160%)` + `shadow`. (01_themes)
- Strips 56 px wide; panels 400 px wide, 96 px in from their side, top aligned with the strips (D-026). Touch targets ≥ 44 px. (00_shell)
- Immutable state; functions < 50 lines; files < 400 lines. (owner's coding rules)

## File structure

```
app/                                   Flutter desktop app (macOS first; Windows/Linux targets created)
  pubspec.yaml
  assets/themes.json                   byte-identical copy of Code/shared/themes.json (test-enforced)
  lib/main.dart                        entry: loads themes, starts ErmiasApp
  lib/src/app.dart                     ErmiasApp: theme state, routes (workbench, settings placeholder)
  lib/src/theme/css_color.dart         parse hex / rgba() / 'transparent' → Color
  lib/src/theme/css_background.dart    parse radial-/linear-gradient layers
  lib/src/theme/css_shadow.dart        parse box-shadow lists → List<BoxShadow>
  lib/src/theme/ermias_theme.dart      ErmiasTheme value class: every key in themes.json, typed
  lib/src/theme/theme_catalog.dart     ThemeCatalog: names in order, lookup, default 'Blues'
  lib/src/theme/theme_scope.dart       InheritedWidget exposing the active ErmiasTheme
  lib/src/theme/typography.dart        Monaco text styles
  lib/src/theme/glass.dart             GlassSurface widget (blur + saturate + border)
  lib/src/theme/background_painter.dart CustomPainter for the multi-glow background
  lib/src/shell/shell_state.dart       ShellState (left/right panel), pure Dart
  lib/src/shell/workbench.dart         layout: header, strips, center, overlay panels
  lib/src/shell/edge_strip.dart        one strip + its tabs + needs-you badge
  lib/src/shell/strip_tab.dart         one tab (icon, vertical label, status figure)
  lib/src/shell/overlay_panel.dart     panel chrome: title, close button, MOCK body slot
  lib/src/shell/center_placeholder.dart PRIMARY FOCUS + chat placeholders (MOCK; built in WO-2)
  lib/src/shell/icons.dart             thin-outline icons drawn from the reference SVG paths
  lib/src/header/header_bar.dart       two-row header
  lib/src/header/resource_strip.dart   model · memory · CPU · network · clock
  lib/src/header/connections_box.dart  inverted box, tier counts (MOCK until WO-6)
  lib/src/header/theme_switch.dart     swatch row
  lib/src/header/resource_source.dart  ResourceSource interface + Rust-backed implementation
  lib/src/mock/mock_data.dart          every MOCK value in one file, each tagged
  lib/src/rust/                        flutter_rust_bridge generated bindings (not hand-edited)
  test/theme/…  test/shell/…  test/header/…
  integration_test/smoke_test.dart     WO-1 smoke test + screenshots
core/                                  Rust crate `ermias_core`
  Cargo.toml  Cargo.lock
  src/lib.rs
  src/api/mod.rs
  src/api/system.rs                    memory_snapshot(), cpu_percent()
  src/api/hash.rs                      sha256_file(path), verify_pinned(path, expected)
docs/work-orders/WO-1.md               this file (plan, drift flags, smoke results)
DEPENDENCIES.md                        every dependency, exact version, reason
DECISION_LOG.md                        HUMAN / CLAUDE decisions
```

---

## PR 1 · Section 01 · Themes

### Task 1: Scaffold the app and lock the theme source

**Files:**
- Create: `app/` via `flutter create --org dev.ermias --project-name ermias --platforms=macos,windows,linux app`
- Create: `app/assets/themes.json` (copy), `DEPENDENCIES.md`
- Modify: `Code/shared/themes.json` (D-013 yellow values), `DESIGN_DECISIONS.md` (D-013, D-015)
- Test: `app/test/theme/theme_source_test.dart`

**Interfaces:** Produces `app/assets/themes.json`, registered as an asset in `pubspec.yaml`.

- [x] **Step 1: Write the failing test**

```dart
// app/test/theme/theme_source_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app theme asset is byte-identical to Code/shared/themes.json', () {
    final source = File('../Code/shared/themes.json').readAsBytesSync();
    final copy = File('assets/themes.json').readAsBytesSync();
    expect(copy, equals(source),
        reason: 'Edit Code/shared/themes.json, then copy it to app/assets/.');
  });
}
```

- [x] **Step 2:** `cd app && flutter test test/theme/theme_source_test.dart` → FAIL (asset missing).
- [x] **Step 3:** Apply D-013 to `Code/shared/themes.json`:

| Theme | warn | onWarn | warnText | warnSoft | dashed |
|---|---|---|---|---|---|
| Blues | `#EAB308` | `#0F1A2E` | `#713F12` | `#FEF7D6` | `#CA8A04` |
| Earth tones | `#D9A62E` | `#2B2A22` | `#6B4A0E` | `#F8EDCF` | `#B8891F` |

  Record D-013 and D-015 in `DESIGN_DECISIONS.md` with date and reason. Copy the file to `app/assets/themes.json`; add the asset to `pubspec.yaml`; delete the counter-app sample and its test.
- [x] **Step 4:** Re-run → PASS. `flutter analyze` → no issues.
- [x] **Step 5:** Commit `feat(themes): scaffold Flutter app and yellow warning colors (D-013)`.

### Task 2: CSS color and shadow parsing

**Files:** Create `lib/src/theme/css_color.dart`, `lib/src/theme/css_shadow.dart`; Test `test/theme/css_color_test.dart`, `test/theme/css_shadow_test.dart`

**Interfaces:** Produces `Color parseCssColor(String input)` (throws `FormatException` for anything outside hex6, `rgba(r,g,b,a)`, `transparent`); `List<BoxShadow> parseCssShadow(String input)` (comma-separated layers; `x y blur [spread] color`).

- [x] **Step 1: Write the failing tests**

```dart
test('parses hex', () => expect(parseCssColor('#1E4FD8'), const Color(0xFF1E4FD8)));
test('parses rgba with alpha', () =>
    expect(parseCssColor('rgba(255,255,255,0.55)'), const Color.fromRGBO(255, 255, 255, 0.55)));
test('parses transparent', () => expect(parseCssColor('transparent'), const Color(0x00000000)));
test('rejects unknown syntax', () =>
    expect(() => parseCssColor('hsl(1,2%,3%)'), throwsFormatException));
test('parses a two-layer shadow', () {
  final s = parseCssShadow('0 24px 60px rgba(0,0,0,0.55), 0 0 0 1px rgba(0,229,255,0.15)');
  expect(s, hasLength(2));
  expect(s[0].offset, const Offset(0, 24));
  expect(s[0].blurRadius, 60);
  expect(s[1].spreadRadius, 1);
});
```

- [x] **Step 2:** Run → FAIL (undefined). **Step 3:** Implement with anchored regexes; reject rather than guess. **Step 4:** Run → PASS. **Step 5:** Commit `feat(themes): parse CSS colors and shadows`.

### Task 3: CSS backgrounds (glow gradients and swatches)

**Files:** Create `lib/src/theme/css_background.dart`, `lib/src/theme/background_painter.dart`; Test `test/theme/css_background_test.dart`

**Interfaces:** Produces `CssBackground parseCssBackground(String input)` → `CssBackground(List<RadialGlow> glows, Color base)` with `RadialGlow(Size radii, FractionalOffset center, Color color, double stop)`; `LinearGradient parseCssLinearGradient(String input)` for swatches (`135deg`). `ThemeBackgroundPainter(CssBackground)` paints the base color, then each glow as an ellipse-scaled `RadialGradient`.

- [x] **Step 1: Failing test:** parse the Blues `bg`; expect 3 glows, the first at `FractionalOffset(0, 0)`, radii `Size(900, 600)`, alpha 0.38, stop 0.60, base `#EEF3FB`. Every theme's `bg` and `swatch` parses without throwing.
- [x] **Steps 2–4:** FAIL → implement (split on top-level commas outside parentheses) → PASS.
- [x] **Step 5:** Commit `feat(themes): parse glow backgrounds and swatch gradients`.

### Task 4: Typed theme catalog and acceptance tests

**Files:** Create `lib/src/theme/ermias_theme.dart`, `theme_catalog.dart`, `theme_scope.dart`, `typography.dart`, `glass.dart`; Test `test/theme/theme_catalog_test.dart`, `test/theme/theme_contrast_test.dart`

**Interfaces:**
- `class ErmiasTheme`: one final field per `themes.json` key (`bg` → `CssBackground`, `swatch` → `LinearGradient`, `shadow` → `List<BoxShadow>`, the rest `Color`). `ErmiasTheme.fromJson(Map<String, Object?>)` throws `FormatException` on a missing or unknown key.
- `class ThemeCatalog { List<String> get names; ErmiasTheme operator [](String name); static const defaultName = 'Blues'; static ThemeCatalog fromJsonString(String json); }`, names in file order.
- `double contrastRatio(Color a, Color b)`, `Color composite(Color over, Color base)` (pure functions, WCAG relative luminance).
- `ThemeScope.of(context) → ErmiasTheme`; `ErmiasType.text(...)` and `ErmiasType.data(...)` (Monaco + fallbacks); `GlassSurface({required Widget child, bool flyout = false})`.

- [x] **Step 1: Failing tests**

```dart
test('loads the four locked themes in order, Blues first', () {
  final c = ThemeCatalog.fromJsonString(File('assets/themes.json').readAsStringSync());
  expect(c.names, ['Blues', 'Cyberpunk', 'Sunburst', 'Earth tones']);
  expect(ThemeCatalog.defaultName, 'Blues');
});

// theme_contrast_test.dart: the spec's acceptance tests, automated
for (final name in catalog.names) {
  test('$name: text pairs meet 4.5:1', () {
    final t = catalog[name];
    final base = t.bg.base;
    for (final (fg, bg) in [
      (t.ink, base), (t.muted, base), (t.accentText, t.accentSoft), (t.warnText, t.warnSoft),
      (t.onAccent, t.accent), (t.onWarn, t.warn), (t.invInk, t.invBg), (t.invMuted, t.invBg),
    ]) {
      expect(contrastRatio(fg, composite(bg, base)), greaterThanOrEqualTo(4.5));
    }
  });
  test('$name: accent and warning differ in grayscale (>= 1.5, D-024)', () {
    final t = catalog[name];
    expect(contrastRatio(t.accent, t.warn), greaterThanOrEqualTo(1.5));
  });
}
```

Plus: removing `warn` from a theme makes `fromJson` throw.

- [x] **Step 2:** Run → FAIL. **Step 3:** Implement. **Step 4:** All PASS for all four themes. If any pair fails, stop and log a drift flag below; colors change only with the owner.
- [x] **Step 5:** Commit `feat(themes): typed theme catalog with automated contrast checks`. Open PR "01 · Themes".

---

## PR 2 · Section 00 · Shell and edge tool strips

### Task 5: Shell state

**Files:** Create `lib/src/shell/shell_state.dart`; Test `test/shell/shell_state_test.dart`

**Interfaces:**

```dart
enum PanelSide { left, right }
enum PanelId { databases, auditLog, taskChain, projectGrade }
extension PanelSideOf on PanelId { PanelSide get side; }

@immutable
class ShellState {
  const ShellState({this.left, this.right});
  final PanelId? left;
  final PanelId? right;
  ShellState toggle(PanelId id);   // opens id, or closes it if open; replaces the same-side panel
  ShellState close(PanelSide side);
  bool isOpen(PanelId id);
}
```

- [x] **Step 1: Failing tests** (the 00_shell acceptance tests)

```dart
test('opening Audit log replaces Databases on the left', () {
  final s = const ShellState().toggle(PanelId.databases).toggle(PanelId.auditLog);
  expect(s.left, PanelId.auditLog);
});
test('Databases and Project grade can be open together', () {
  final s = const ShellState().toggle(PanelId.databases).toggle(PanelId.projectGrade);
  expect([s.left, s.right], [PanelId.databases, PanelId.projectGrade]);
});
test('toggling an open tab closes it', () =>
    expect(const ShellState().toggle(PanelId.taskChain).toggle(PanelId.taskChain).right, isNull));
test('close(side) closes only that side', () {
  final s = const ShellState(left: PanelId.auditLog, right: PanelId.projectGrade).close(PanelSide.left);
  expect([s.left, s.right], [null, PanelId.projectGrade]);
});
test('toggle never mutates the original', () {
  const a = ShellState();
  final b = a.toggle(PanelId.databases);
  expect(a.left, isNull);
  expect(identical(a, b), isFalse);
});
```

- [x] **Steps 2–5:** FAIL → implement → PASS → commit `feat(shell): immutable panel state`.

### Task 6: Strips, tabs, overlay panels, center placeholder

**Files:** Create `edge_strip.dart`, `strip_tab.dart`, `overlay_panel.dart`, `center_placeholder.dart`, `icons.dart`, `workbench.dart`, `lib/src/mock/mock_data.dart`; Test `test/shell/workbench_test.dart`

**Interfaces:** Consumes `ShellState`, `ThemeScope`, `GlassSurface`. Produces `Workbench({required ShellState state, required ValueChanged<ShellState> onChanged, required Widget header})`. Tab figures (`4/5`, `5`, `4/5`, `8.1`) and needs-you counts come from `MockData` and display a visible `MOCK` tag.

- [x] **Step 1: Failing widget tests** (1440×1040 surface, Blues):
  - tap Databases then Audit log → only the Audit log panel is present;
  - tap Databases and Project grade → both panels present;
  - each panel closes from its tab and from its close button (semantics label `Close <panel>`);
  - all closed → the center placeholder spans exactly the gap between the strips;
  - each tab is a semantic button with `expanded` state, reachable by Tab, toggled by Enter;
  - every tab hit area ≥ 44×44;
  - panel top equals the strips' top (D-026); panel width 400, 96 px from its side; opening a panel does not change the center's size.
- [x] **Step 2:** FAIL. **Step 3:** Implement: panels in a `Stack` over the center; strips are `GlassSurface`; icons from the reference SVG paths at stroke 1.8. **Step 4:** PASS. **Step 5:** Commit `feat(shell): edge strips and overlay panels on mock data`. Open PR "00 · Shell".

---

## PR 3 · Section 02 · Header and status

### Task 7: Rust core with bridge

**Files:** Create `core/Cargo.toml`, `core/src/lib.rs`, `core/src/api/{mod,system,hash}.rs`; FRB-generated `app/lib/src/rust/` and `app/rust_builder/`. Modify `DEPENDENCIES.md`.

**Interfaces** (Rust, exposed to Dart by FRB):

```rust
pub struct MemorySnapshot { pub used_bytes: u64, pub total_bytes: u64 }
pub fn memory_snapshot() -> MemorySnapshot;
pub fn cpu_percent() -> f32;                                  // global usage since the previous call
pub fn sha256_file(path: String) -> Result<String, String>;   // lowercase hex
pub fn verify_pinned(path: String, expected_hex: String) -> Result<bool, String>;
```

- [x] **Step 1: Failing Rust tests**

```rust
#[test]
fn sha256_of_known_bytes() {
    let p = test_file("abc.bin", b"abc");
    assert_eq!(sha256_file(p).unwrap(),
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
}
#[test]
fn changed_file_fails_pinned_check() {
    let p = test_file("model.bin", b"abc");
    let pinned = sha256_file(p.clone()).unwrap();
    std::fs::write(&p, b"abd").unwrap();
    assert_eq!(verify_pinned(p, pinned), Ok(false));
}
#[test]
fn missing_file_is_an_error_not_a_pass() {
    assert!(verify_pinned("/no/such/file".into(), "00".into()).is_err());
}
#[test]
fn memory_snapshot_is_sane() {
    let m = memory_snapshot();
    assert!(m.total_bytes > 0 && m.used_bytes <= m.total_bytes);
}
```

- [x] **Step 2:** `~/.cargo/bin/cargo test --manifest-path core/Cargo.toml` → FAIL. **Step 3:** Implement; hash with a streaming 64 KiB buffer (model files are several GB). **Step 4:** PASS. Install `flutter_rust_bridge_codegen@2.13.0`, generate bindings, `flutter build macos --debug` succeeds.
- [x] **Step 5:** Commit `feat(core): Rust system and hashing core over flutter_rust_bridge`.

### Task 8: Header

**Files:** Create `lib/src/header/{header_bar,resource_strip,connections_box,theme_switch,resource_source}.dart`; Modify `lib/src/app.dart`; Test `test/header/header_test.dart`

**Interfaces:**

```dart
abstract interface class ResourceSource {
  Stream<ResourceReading> readings(Duration every);   // memory, cpu, now
  Future<ModelCheck> checkModel(ModelIdentity model);  // ok | mismatch | missing
}
class RustResourceSource implements ResourceSource { /* calls core via FRB */ }
abstract interface class AuditSink { void record(String kind, String summary, {required bool needsHuman}); }
class MockAuditSink implements AuditSink { /* MOCK until section 07 */ }
```

Model identity (name, quantization, path, pinned hash), session pill text, network summary and connection counts come from `MockData` and are tagged `MOCK` on screen. Tests use a `FakeResourceSource`.

- [x] **Step 1: Failing widget tests** (the 02_header_status acceptance tests):
  - two readings from the fake source → memory, CPU and clock text update;
  - `checkModel` → mismatch shows warning color + "hash mismatch" text + triangle symbol, and `MockAuditSink` received one entry with `needsHuman: true`;
  - the gear opens the Settings route (placeholder "Settings · built in WO-3");
  - tapping a swatch re-themes every surface without restarting (01 acceptance test);
  - the connections box is centered in row 2 and uses `inv*` colors; Local is not a button, Hybrid and Exposed are.
- [x] **Steps 2–4:** FAIL → implement → PASS. **Step 5:** Commit `feat(header): live resources, model hash check, theme switch`. Open PR "02 · Header".

---

## PR 4 · Docs and smoke test

### Task 9: Smoke test, screenshots, README

**Files:** Create `app/integration_test/smoke_test.dart`, `docs/screenshots/wo-1-*.png`, `docs/ARCHITECTURE.md`; Modify `README.md`, this file.

- [x] **Step 1:** `smoke_test.dart` launches the real app (Rust-backed source), waits 3 s and asserts clock and CPU changed, opens each panel pair, switches through all four themes, alters the mock model file and asserts the mismatch state, capturing a screenshot at each step.
- [x] **Step 2:** `flutter test integration_test -d macos` PASS; `flutter test`, `cargo test`, `flutter analyze`, `cargo clippy -- -D warnings` all clean.
- [x] **Step 3:** Compare screenshots with `Code/reference/screenshots/04–11`; log every visible difference as a drift flag.
- [x] **Step 4:** Rewrite `README.md`: what Ermias is and why (first screen), screenshot, status by work order, architecture, security model, build and test commands, reviewer index.
- [x] **Step 5:** Record results below; commit `docs: WO-1 smoke test, screenshots and README`. Open PR "WO-1 · Docs".

---

## Drift flags

| ID | Found | Drift | Status |
|---|---|---|---|
| F-1 | 2026-11-10 | Raised: `00_shell` README says 104 px, reference says 164 px. | **Withdrawn (D-028).** The README already said 164 px; my diff output was truncated. |
| F-2 | 2026-11-10 | 01_themes grayscale acceptance test failed for Earth tones and was weak for Blues. | Resolved by D-013 (yellow); verified by Task 4. |
| F-3 | 2026-11-10 | Locked fonts Inter + JetBrains Mono replaced by Monaco. | Owner decision D-015; recorded in `DESIGN_DECISIONS.md` in Task 1. |
| F-4 | 2026-11-10 | Header session pill text predates password sign-in. | Shown as `MOCK` until sign-in exists (WO-3). |
| F-5 | 2026-11-10 | `audit_event` contract has no HUMAN/CLAUDE actor or hash chain. | Deferred to WO-4 (D-006); WO-1 uses `MockAuditSink`. |
| F-6 | 2026-11-10 | **Monaco has a single weight.** The locked type scale (600 headings, 700 PRIMARY FOCUS) renders at regular weight, so hierarchy is flatter than the reference. Monaco is also ~30% wider than Inter. | **Owner to decide:** keep Monaco everywhere, or Monaco for data and a bold-capable system font for headings. |
| F-7 | 2026-11-10 | Execution deviated from plan: build backend changed to native assets (D-036); `Workbench.onChanged` takes an update function (D-032); Rust readings return `Result` because `sysinfo` 0.40 can fail to initialise. | Recorded; plan interfaces superseded by the code. |
| F-8 | 2026-11-10 | Windows and Linux targets are scaffolded but **not built or tested**; their minimum window size is not set. | macOS only in WO-1. Cross-platform build is a later work order. |
| F-9 | 2026-11-10 | Hybrid/Exposed connection windows, Briefing room behavior and theme persistence are not built. | Section 03 (WO-2), open questions 6 and 8. Shown as MOCK or "not yet available". |

## Smoke test results

**2026-11-10 · PASS** · macOS (Apple silicon), Flutter 3.47.5, Rust 1.98.1 · `flutter test integration_test -d macos`

| Check | Spec | Result |
|---|---|---|
| Memory, CPU and clock update live from the Rust core | 02 | PASS · 6 readings in ~10 s |
| Model SHA-256 matches its pin and shows ✓ | 02 | PASS |
| Changing the model file fails visibly and logs a needs-human entry | 02 | PASS · `model_hash_mismatch` recorded |
| Gear opens Settings; Back returns | 02 | PASS |
| One panel per side; both sides open together; tabs and close buttons close | 00 | PASS |
| All four themes switch without a restart | 01 | PASS |
| Screenshots | — | `docs/screenshots/01–07` |

Automated suites at the same commit: `flutter test` 101 passing · `cargo test` 8 passing · `flutter analyze` and `cargo clippy -D warnings` clean.

Compared with `Code/reference/screenshots/04–11`: layout, glass, strips, panel positions and the connections box match. Differences are logged above (F-6 type weight, F-9 not-yet-built controls).
