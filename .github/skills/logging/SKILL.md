---
name: logging
description: "Load this skill when adding, tuning, or analysing log output in Lurek2D: setting up the log crate facade, choosing the right log level, controlling output with RUST_LOG, writing structured log messages, logging from Lua scripts, or using log output to debug engine and game behaviour. Use for: engine log instrumentation, RUST_LOG syntax, per-crate/per-module filtering, log-to-file patterns. Skip it for general debugging strategy (use dev-debugging skill) or analytics from collected log files (use analytics skill)."
---
# logging

## Mission

Own the log crate facade, RUST_LOG filtering, log level policy, message content conventions, and Lua-side logging patterns.

## When To Load

- Deciding which log level to use for a new message
- Configuring RUST_LOG to filter log output to a module
- Adding structured diagnostic output to a Rust engine module
- Writing Lua-side logging helpers
- Diagnosing why expected log output is not appearing

## When To Skip

- General debugging strategy → use dev-debugging skill
- Analytics from collected log files → use analytics skill

## Domain Knowledge

**Rust log facade:** log crate (log = "0.4") with env_logger backend, initialised at startup in main.rs. All engine code MUST use log::* macros. Never println! — it bypasses the log system and cannot be filtered.

**Log level policy:**

| Level | When to use | Volume |
|-------|------------|--------|
| error! | Cannot continue — frame/session will abort | Once per failure |
| warn! | Continuing but something is wrong | Rare |
| info! | Engine lifecycle: init, load, shutdown | <20/session |
| debug! | Per-call detail: draw flush, resource alloc | Frequent |
| trace! | Per-frame hot path detail | Very frequent |

Defaults: env_logger defaults to warn level unless RUST_LOG is set. Never per-frame info!/warn! — use debug!/trace! for hot paths.

**RUST_LOG syntax:** RUST_LOG=lurek2d=debug (all engine), luna2d::graphics=debug (single module), luna2d::physics=trace,luna2d::audio=debug (multiple modules). Module paths follow luna2d::<module> pattern.

**Message content conventions:** format as "module: what happened values" — include the module name prefix when log target is lurek2d (makes grep filtering easy). Include relevant numeric values (counts, sizes, durations).

**Lua-side logging:** print() for stdout (standard output). For persistent logging use lurek.filesystem.append(path, message) to write to a log file. For conditional verbose mode check a debug flag before logging.

**During tests:** set RUST_LOG=lurek2d=debug before running cargo test to see engine debug output. Test output is captured by default — use --nocapture to see it live.

## Companion File Index

None — all guidance is inline.

## References

- src/main.rs — env_logger initialisation
- src/log/ — logging module internals
