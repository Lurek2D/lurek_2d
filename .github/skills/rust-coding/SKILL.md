---
name: rust-coding
description: "Load this skill when writing or reviewing Rust code in the Lurek2D engine. It owns safe Rust conventions, error handling patterns, module structure, and idiomatic Rust for game engine development. Skip it for Lua scripting, CAG files, or documentation."
---
# rust-coding

## Mission

Own safe Rust conventions, error handling patterns, module structure, the 5-layer architecture, and code quality rules for the Lurek2D engine.

## When To Load

- Writing new Rust code in src/
- Reviewing Rust code for convention compliance
- Structuring a new module or refactoring an existing one
- Choosing between error handling approaches

## When To Skip

- Lua scripting -> use lua-scripting skill
- CAG files -> use cag-workflow skill
- Documentation -> use documentation skill

## Domain Knowledge

**Error handling:** use Result with EngineError. Never .unwrap() in production code — use .map_err(...)? or .unwrap_or_default(). Panic-free engine: only panic in main() entry point if unrecoverable.

**Visibility rules:** default to pub(crate) for internal types. Use pub only for types that must cross crate boundaries. Private by default for helper functions.

**Import style:** absolute paths: use crate::module::Type. Group imports: std first, external crates second, crate-internal third, separated by blank lines.

**Banned patterns:** #[cfg(test)] in src/ (TST-02: tests go in tests/rust/unit/), println!/eprintln! in engine code (use log::info!/warn!/error!), .clone() in hot loops without justification, unsafe without // SAFETY: comment.

**5-layer module groups (bottom to top):** (1) Foundations: math, data, serial, log, event. (2) Core Runtime: runtime, window, input, timer, filesystem, save. (3) Platform Services: render, audio, physics, compute. (4) Feature Systems: sprite, tilemap, animation, tween, particle, camera, scene, ui, ecs. (5) Edge/Integration: lua_api, mods, devtools, terminal, automation.

**Layer import rule:** a module may import from its own layer or any lower layer. Never import upward. Edge/Integration (layer 5) may import anything. Domain modules must never import from lua_api.

**mod.rs rules (TST-04):** only pub mod, pub use, attributes, and doc comments. No definitions, no impl blocks.

**Final gate before commit:** cargo test; cargo clippy -- -D warnings

## Companion File Index

None - all guidance is inline.

## References

- src/README.md - module inventory
- docs/architecture/philosophy.md - binding constraints
