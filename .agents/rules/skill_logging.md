---
trigger: model_decision
description: "Load this skill when adding or tuning log output, log levels, RUST_LOG filters, or log-based diagnosis. Skip it for general debugging strategy or log analytics."
---
# logging

## Mission
- Own runtime log output, level choice, and filter strategy.

## When To Load
- Add new log lines.
- Change log levels.
- Tune RUST_LOG usage.
- Diagnose behavior through logs.

## When To Skip
- General debugging strategy.
- Analytics from saved logs.

## Domain Knowledge
- Log crate target naming convention: `lurek2d::<module>` for engine modules, `lurek2d::lua_api::<module>` for binding layer. RUST_LOG filters work on these targets: `RUST_LOG=lurek2d::render=trace,lurek2d::lua_api=debug cargo run`.
- Level assignment rules: `error!` = operation failed and the engine cannot continue safely. `warn!` = operation failed but the engine recovered or fell back.
- Hot path log guard: every `trace!` or `debug!` call inside `on_process`, render loop, physics step, or audio callback must be guarded by `if log::log_enabled!(log::Level::Trace)`. Unguarded log calls in hot paths disable the JIT for surrounding Lua code and add Rust string allocation overhead even when output is suppressed.
- `println!` in `src/<module>/` is a defect — the `module-audit` scanner flags it. All engine output goes through `log::*`.
- Context format rule: `warn!("lurek2d::audio: failed to load source '{}': {}", normalized_path, err)`. The message must include the module path, the key identifiers, and the error.
- `parse_test_log.py` expects log lines in the standard `[LEVEL target] message` format. Custom log formats or log redirection that changes this format will break the CI log parser.
- `src/log/` configures the log sink. When modifying startup log configuration, check that headless test mode does not suppress error-level output needed by CI.
- For Lua-side logging: `lurek.log.debug(msg)`, `lurek.log.warn(msg)`, `lurek.log.error(msg)` route through the same sink with target `lurek2d::lua_script`. Game authors should use these instead of `print()` for structured, filterable output.
- Structured event logging for analytics: game events should use `lurek.log.event(name, data_table)` rather than plain log messages. This produces JSON lines in `logs/data/` that analytics tools can query.
## Companion File Index
- None.

## References
- src/log/
- src/main.rs
- logs/
- tools/audit/parse_test_log.py