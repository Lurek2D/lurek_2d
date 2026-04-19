# IDEA — `src/log/`

> **This file is forward-looking.** It records ideas, not commitments.
>
> See [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md) for filling instructions.

---

## 1. Header

- **Module**: `log`
- **Owner module path**: `src/log/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~480 · **Public Lua surface**: `lurek.log` — 18 fns / 0 userdata
- **Inbound non-`lua_api` callers**: `none`
- **Heavy dependencies**: `none`

## 2. Mission Summary

The `log` module provides Lurek2D's structured logging façade and configurable sink system. It serves EngDev (engine diagnostics), GameDev (script-level debug output), and GameTest (log-based assertions). Global level management delegates to `crate::runtime::log_messages`; per-VM sink routing is handled by `SinkRegistry`. It is NOT a telemetry or analytics pipeline.

## 3. Existing Strengths

- Clean separation between `log` crate façade (global) and per-VM `SinkRegistry` (local fan-out) in `sinks.rs`.
- Three sink backends (file, memory ring, rotating file) cover common game-dev log destinations.
- Structured logging with key-value fields (`log_structured`) enables machine-parseable output.
- `SinkLevel` per-sink filtering gives fine-grained output control without touching `RUST_LOG`.
- Rotation logic handles Windows file-lock constraints (drops handle before rename).
- Monotonically increasing sink ids — simple, no reuse ambiguity.

## 4. Gap List

1. **[P1][GAP]** No timestamp in sink output — file and rotating-file entries are `[LEVEL] tag: msg` with no wall-clock time. Only the default `env_logger` channel adds timestamps.
2. **[P2][GAP]** `NO_COLOR` / ANSI toggle — no way to disable ANSI codes for CI or file sinks.
3. **[P2][GAP]** No JSON / structured file format — file sinks always write plain text; no NDJSON option for log aggregation tools.
4. **[P2][GAP]** `SinkLevel` has no `Trace` variant — the Rust `log` crate supports Trace but sinks bottom out at Debug.
5. **[P2][GAP]** `flush()` on `SinkKind::File` only drops the `MutexGuard` — does not call `File::flush()` explicitly.
6. **[P3][GAP]** No per-category / per-tag filtering — sinks accept all tags; cannot route e.g. only "Physics" messages to a specific file.
7. **[P3][GAP]** No log-to-callback sink — cannot push entries to an in-game console widget without polling `readMemory` every frame.
8. **[P3][GAP]** No async / buffered file writes — every `write()` hits the OS synchronously, which can stall the game loop on slow storage.
9. **[P3][GAP]** `SinkLevel::from_str` shadows `std::str::FromStr` — inherent method instead of standard trait makes generic conversions awkward.

## 5. Feature Ideas

1. **[P1][FEAT]** Timestamped sink format — LÖVE 2D's logging helpers and Godot's `print_rich` prepend wall-clock timestamps. Adding an optional timestamp prefix to file sinks would close Gap #1. Effort: S · Risk: low.
2. **[P2][FEAT]** Per-tag sink routing — Defold's `sys.set_error_handler` and Bevy's `LogPlugin` allow per-module / per-label filtering. A `SinkFilter { tags: HashSet<String> }` on each `Sink` would close Gap #6. Effort: M · Risk: low.
3. **[P2][FEAT]** NDJSON file sink option — Solar2D logs to JSON for Corona Debugger integration. A `SinkFormat::Json` variant on file sinks would close Gap #3. Effort: S · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P2][QUAL]** Buffered writes: wrap `File` in `BufWriter` with periodic flush to reduce per-message syscall overhead (Gap #8).
- **[P2][QUAL]** Explicit flush: replace the guard-drop pattern in `Sink::flush()` for `SinkKind::File` with `f.flush()` to guarantee OS buffer flush (Gap #5).
- **[P3][QUAL]** Lock-free memory sink: consider `crossbeam::ArrayQueue` instead of `Mutex<VecDeque>` for the hot path in memory sinks.

## 7. Test Coverage Gaps

- **[P2][TEST-RUST]** `RotatingFileSink::rotate` — no test exercises the rename/delete cycle (requires temp-dir fixture).
- **[P2][TEST-RUST]** `Sink::file()` and `Sink::rotating_file()` constructors — error paths (invalid path) untested.
- **[P2][TEST-RUST]** `Sink::flush()` on all three sink kinds — no assertions beyond "does not panic".
- **[P2][TEST-RUST]** `SinkRegistry::dispatch` with mixed sink levels — verify low-level message reaches Debug sink but not Error sink.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.log.struct` under `tests/lua/unit/test_log.lua`.

## 8. TODO(dedup): Cross-Module Overlap

TODO(dedup): `log_structured` in `mod.rs` duplicates the key-value formatting logic of `Sink::write_structured` in `sinks.rs`. Consider extracting a shared `format_structured(msg, fields) -> String` helper.

TODO(dedup): `data::RingBuffer` — `MemorySink` uses `VecDeque` as a bounded ring; `data::RingBuffer` provides the same abstraction. Consider unifying.

TODO(dedup): `runtime::log_messages` owns `set_log_level` / `get_log_level` globals; `log::set_level` / `log::get_level` are trivial pass-throughs that could be inlined at the Lua bridge.

## 9. TODO(helper): Engine-Level Helper Candidates

TODO(helper): A `format_log_line(level, tag, msg, timestamp) -> String` utility would unify the formatting across `Sink::write`, `Sink::write_structured`, and any future JSON sink.

TODO(helper): A `parse_level(s: &str) -> Option<SinkLevel>` that implements `FromStr` properly (returning `None` instead of defaulting to Debug) would be safer for validation.

## 10. TODO(plugin): Plugin Candidacy Proposal

TODO(plugin): CORE-KEEP — logging is a foundational service required by every module; extraction provides no binary savings.
- **Extraction blockers**: every module imports `log` macros; `SinkRegistry` in `SharedState`.
- **Heavy dep impact if extracted**: n/a.
- **Lua surface stability**: stable.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/log.md](../../docs/specs/log.md)
- Lua API reference: [docs/API/lua-api.md#log](../../docs/API/lua-api.md)
- Plugin doc tier table: [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)

---

## Features

### 🔇 LOW — Color Output Toggle
**Source**: CI/CD compatibility

ANSI color in log output is always on. `NO_COLOR` env var or `conf.toml` toggle
would improve CI log readability.
