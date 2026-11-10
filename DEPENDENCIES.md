# Dependencies

Every dependency, pinned to an exact version, with the reason it exists. Adding, upgrading or replacing one needs the owner's approval (`CLAUDE.md`), recorded in `DECISION_LOG.md`.

## Toolchains

| Tool | Version | Why |
|---|---|---|
| Flutter SDK | 3.47.5 | Desktop UI (macOS, Windows, Linux). Pinned in `app/pubspec.yaml`. |
| Dart SDK | 3.13.4 | Ships with Flutter 3.47.5. Pinned in `app/pubspec.yaml`. |
| Rust | 1.98.1 | Core library (`core/`). |

## Dart packages

| Package | Version | Kind | Why | Decision |
|---|---|---|---|---|
| `flutter`, `flutter_test` | SDK | SDK | UI framework and tests; versions fixed by the Flutter SDK. | D-001 |

No third-party Dart packages yet. The Flutter template's `cupertino_icons` and `flutter_lints` were removed (D-030).

## Rust crates

_Added in PR 3 (section 02): `flutter_rust_bridge` 2.13.0, `sysinfo` 0.40.1, `sha2` 0.11.1 (D-021, D-029)._

## Fonts and assets

| Asset | Source | Why |
|---|---|---|
| Monaco | Operating system (macOS); fallbacks Menlo, Consolas, DejaVu Sans Mono | Owner choice (D-015). Not bundled: license forbids redistribution (D-016). |
| Material icons font | Bundled by the Flutter SDK | Not yet used; interface icons are drawn from the reference SVG paths. |
