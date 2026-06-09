# Log Contract

This file adds local rules for work under `src/log/`.

## Mission
- Own engine log routing, sink setup, target naming, and structured log compatibility.

## Local rules
- Use `lurek2d::<module>` targets for engine modules and `lurek2d::lua_api::<module>` for binding-layer logs.
- Keep level meaning stable: `error!` means the operation cannot continue safely; `warn!` means the engine recovered or fell back.
- Guard verbose logging in hot paths with `log::log_enabled!` before building trace or debug messages.
- `println!` and `eprintln!` do not belong in engine modules or log configuration paths that should use the shared sink.
- Log messages should carry enough context to identify the module, the relevant key or path, and the underlying error.
- Preserve the standard log line shape expected by test tooling and parsers.
- Startup or headless-mode sink changes must not suppress error output that CI and harness tooling rely on.

## Workflow
- When changing log plumbing, check both runtime output and the downstream parser or harness that consumes it.
- Keep Lua-side logging aligned with the shared sink so script logs remain filterable beside engine logs.

## References
- `src/main.rs`
- `tools/audit/parse_test_log.py`
- `logs/`
