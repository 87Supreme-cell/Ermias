# Dependencies

Every dependency, pinned to an exact version, with the reason it exists. Adding, upgrading or replacing one needs the owner's approval (`CLAUDE.md`), recorded in `DECISION_LOG.md`.

## Toolchains

| Tool | Version | Why |
|---|---|---|
| Flutter SDK | 3.47.5 | Desktop UI (macOS, Windows, Linux). Pinned in `app/pubspec.yaml`. |
| Dart SDK | 3.13.4 | Ships with Flutter 3.47.5. Pinned in `app/pubspec.yaml`. |
| Rust | 1.98.1 | Core library (`core/`). Pinned in `core/rust-toolchain.toml` with `rustfmt` and `clippy`; desktop targets only. |
| `flutter_rust_bridge_codegen` | 2.13.0 | Build-time: generates the Dart bindings for `core/src/api`. `cargo install flutter_rust_bridge_codegen@2.13.0 --locked`. (D-010) |
| `cargo-expand` | 1.0.127 | Build-time: used by the codegen to read macro output. Installed by the codegen; kept by owner decision (D-037). |

## Dart packages

| Package | Version | Kind | Why | Decision |
|---|---|---|---|---|
| `flutter`, `flutter_test` | SDK | SDK | UI framework and tests; versions fixed by the Flutter SDK. | D-001 |
| `flutter_rust_bridge` | 2.13.0 | runtime | Calls the Rust core from Dart. | D-010 |
| `flutter_rust_bridge_hooks` | 2.13.0 | build hook (`app/hook/build.dart`) | Compiles `core/` with the pinned toolchain and bundles it (Flutter native assets). | D-036 |

Transitive packages of the two above, locked in `app/pubspec.lock`: `args` 2.7.0, `build_cli_annotations` 2.1.1, `code_assets` 1.2.1, `crypto` 3.0.8, `hooks` 2.0.2, `logging` 1.3.0, `native_toolchain_rust` 1.0.4+0, `petitparser` 7.0.2, `pub_semver` 2.2.1, `record_use` 0.6.0, `toml` 0.18.0, `web` 1.1.2, `yaml` 3.1.4.

The Flutter template's `cupertino_icons` and `flutter_lints` were removed (D-030).

## Rust crates

| Crate | Version | Why | Decision |
|---|---|---|---|
| `flutter_rust_bridge` | =2.13.0 | Rust side of the Dart bridge. | D-010 |
| `sha2` | =0.11.1 | SHA-256 for the model hash check. | D-021, D-029 |
| `sysinfo` | =0.40.1 (`system` feature only) | Live memory and CPU readings. | D-021, D-029 |

Transitive crates are locked in `core/Cargo.lock`.

## Removed or not used

- Cargokit + CocoaPods: replaced by native assets (D-036); nothing from Cargokit remains in the repo.

## Fonts and assets

| Asset | Source | Why |
|---|---|---|
| Monaco | Operating system (macOS); fallbacks Menlo, Consolas, DejaVu Sans Mono | Owner choice (D-015). Not bundled: license forbids redistribution (D-016). |
| Material icons font | Bundled by the Flutter SDK | Not yet used; interface icons are drawn from the reference SVG paths. |
