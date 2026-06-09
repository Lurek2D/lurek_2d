# Log Contract

Covers work under `src/log/`.

## Mission
- Own engine log routing, sink setup, target naming, and structured log compatibility.

## Scope
- `src/log/` logging code and sink setup.

## Local map
- `src/main.rs` wires startup logging.
- `tools/audit/parse_test_log.py` consumes log output.
- `logs/` holds log data.

## Rules
- Use `lurek2d::<module>` targets for engine modules and `lurek2d::lua_api::<module>` for binding logs.
- Keep `error!` for unrecoverable failures and `warn!` for recovered or fallback paths.
- Guard hot-path debug or trace logging with `log::log_enabled!`.
- Do not use `println!` or `eprintln!` in engine modules or shared-sink setup.
- Include module, key or path, and the underlying error in log context.
- Keep the log line shape stable for tooling and parsers.
- Startup or headless sink changes must not suppress CI error output.

## Workflow
- Check runtime output and the downstream parser or harness when log plumbing changes.
- Keep Lua-side logging aligned with the shared sink.

## References
- `src/main.rs`
- `tools/audit/parse_test_log.py`
- `logs/`
