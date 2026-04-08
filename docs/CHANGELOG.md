# Luna2D Changelog

All notable changes to Luna2D are recorded here.

## Versioning scheme

```
MAJOR.MINOR.PATCH
```

| Segment | Increment when… |
|---|---|
| **MAJOR** | Breaking API changes — Lua scripts or engine configuration must be ported |
| **MINOR** | New backwards-compatible features — new `luna.*` APIs, new modules, new default configs |
| **PATCH** | Bug fixes, internal refactors, documentation and tooling changes that do not affect the public API |

Always update this file **in the same commit** as the change. Use the commit type as the section label.

---

## [0.5.2] — 2026-04-14

### Added
- **`devtools` module** (`src/devtools/`) — New domain module providing: structured logger (`Logger`/`LogEntry`/`LogLevel`) with min-level filtering and category tagging; hierarchical profiler (`Profiler`/`ProfileZone`) with per-frame zone tracking; rolling frame-time stats (`FrameStats`/`FrameSnapshot`) with FPS, P50/P95/P99 percentiles; and file watcher (`FileWatcher`) for hot-reload polling. Exposed via `luna.devtools.*` (gated by `modules.debug`). Spec: `specs/devtools.md`. Tests: `tests/rust/unit/devtools_tests.rs` (25 tests).
- **`localization` module** (`src/localization/`) — New domain module providing: multi-locale string catalog (`Catalog`) with load/unload/translate/fallback/export; `{var}` and `{var:fmt}` interpolation (`interpolate`/`interpolate_pairs`); CLDR-based plural forms (`PluralForm`/`pluralize`/`pluralize_slavic`) for English and Slavic rulesets. Exposed via `luna.localization.*` (gated by `modules.localization`). Spec: `specs/localization.md`. Tests: `tests/rust/unit/localization_tests.rs` (26 tests).
- **`patterns` module** (`src/patterns/`) — New domain module implementing six game-programming design patterns as pure-Rust types: `EventBus` (subscribe/drain-once/priority sort), `ObjectPool` (acquire/release/prewarm/capacity), `CommandStack` (push/undo/redo/batch), `ServiceLocator` (name→any register/unregister/has), `Factory` (type registry + aliases), `StateMachine` (states/transitions/guards/history/reachable). Exposed via `luna.patterns.*` (gated by `modules.pipeline`). Spec: `specs/patterns.md`. Tests: `tests/rust/unit/patterns_tests.rs` (34 tests).
- `src/devtools/AGENT.md`, `src/localization/AGENT.md`, `src/patterns/AGENT.md` — module overview files.

## [0.5.1] — 2026-04-08

### Added
- Added `LICENSE_INVENTORY.md` at the repository root with explicit first-party Rust module and Lua library lists, direct Cargo dependency license tables, the direct VS Code extension runtime dependency license, and a no-models-found audit summary.

## [0.5.0] — 2026-04-08

### Changed
- Version bumped to 0.5.0 — first tracked release.
- **Distribution build** switched from fat-LTO `--profile dist` to `--release` (thin LTO); balanced binary size vs. link time.
- **Windows installer** (`tools/dist/installer.nsi`): now bundles `examples/`, `library/`, `demos/`, and the full `docs/API/` folder. Registers `.lua` file association so double-clicking any Lua script launches it in Luna2D.
- **dist.ps1**: updated to use `cargo build --release` and `build/release/luna2d.exe`; adds `demos/` to the portable package.
- **Icons**: Windows binary now embeds `assets/favicon.ico` (user-supplied). Removed auto-generated icon/splash Python scripts (`gen_icon.py`, `gen_splash.py`, `gen_branding.py`, `gen_svg_assets.py`) — all artwork is now maintained manually in `assets/`.
- **Build.rs**: icon embed path updated to `assets/favicon.ico`.

### Added
- `docs/CHANGELOG.md` — this file; version history starting at 0.5.0.

---

<!-- Template for future entries:

## [X.Y.Z] — YYYY-MM-DD

### Added
-

### Changed
-

### Fixed
-

### Removed
-

-->
