# IDEA.md — `log` module

> No `ideas/features/` file. Assembled from `src/log/` directory listing.
> This is a Foundations-tier module — log facade and sink implementations.
> Lua namespace: via `lurek.devtools` log controls (see `src/devtools/IDEA.md`).

---

## Purpose

Logging infrastructure for the engine. Provides the `log` crate facade registration
and custom sink implementations (`sinks.rs`).

---

## Implemented

| File       | Contents                                                      |
| ---------- | ------------------------------------------------------------- |
| `mod.rs`   | Logger initialization, `init_logger()`, log level from config |
| `sinks.rs` | Custom sinks: file sink, in-game console pipeline             |

---

## Features

### 🔇 LOW — Color Output Toggle
**Source**: CI/CD compatibility

ANSI color in log output is always on. `NO_COLOR` env var or `conf.toml` toggle
would improve CI log readability.
