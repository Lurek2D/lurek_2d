---
inclusion: manual
---

# logging

## Mission
Own runtime log output, level choice, and filter strategy.

## When To Use
- Adding new log lines.
- Changing log levels.
- Tuning `RUST_LOG` usage.
- Diagnosing behavior through logs.

## When To Skip
- General debugging strategy, analytics from saved logs.

## Rules

### Target Naming Convention
- Engine modules: `lurek2d::<module>` (e.g., `lurek2d::render`, `lurek2d::physics`).
- Binding layer: `lurek2d::lua_api::<module>`.
- Filter example: `RUST_LOG=lurek2d::render=trace,lurek2d::lua_api=debug cargo run`.

### Level Assignment
- `error!` — operation failed and the engine cannot continue safely (fatal, developer must act).
- `warn!` — operation failed but the engine recovered or fell back (developer should investigate).
- `info!` — significant lifecycle event only (startup, shutdown, scene load). Never for anything firing more than once per second.
- `debug!` — developer-relevant decision point.
- `trace!` — per-frame or high-frequency detail.

### Hot Path Guard
Every `trace!` or `debug!` call inside `on_process`, render loop, physics step, or audio callback must be guarded by:
```rust
if log::log_enabled!(log::Level::Trace) { ... }
```
Unguarded log calls in hot paths add Rust string allocation overhead even when output is suppressed.

### println! Rule
- `println!` in `src/<module>/` is a defect flagged by the module-audit scanner.
- All engine output goes through `log::*`.
- `eprintln!` is acceptable in `src/bin/` and `tools/` only.

### Context Format
```
warn!("lurek2d::audio: failed to load source '{}': {}", normalized_path, err)
```
Include: module path, key identifiers (path, handle, config key), and the error. Use GameFS-normalized path, never absolute host paths.

### CI Log Parser Compatibility
- `parse_test_log.py` expects standard `[LEVEL target] message` format. Do not change this format or redirect logs in ways that break the CI parser.
- When modifying startup log configuration, ensure `LUREK_HEADLESS=1` mode does not suppress error-level output needed by CI.

### Lua-Side Logging
- Game authors use `lurek.log.debug(msg)`, `lurek.log.warn(msg)`, `lurek.log.error(msg)` — these route through the same sink with target `lurek2d::lua_script`.
- Use `lurek.log.event(name, data_table)` for structured game events (score, death, level complete). Produces JSON lines in `logs/data/` for analytics tools.

## References
- `src/log/`
- `src/main.rs`
- `logs/`
- `tools/audit/parse_test_log.py`
