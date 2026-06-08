---
name: rust-coding
description: "Load this skill when writing or reviewing Rust engine code. It owns safe Rust conventions, error patterns, module structure, and idiomatic style. Skip it for Lua scripts, CAG files, or docs."
---
# rust-coding

## Use when
- Write Rust code.
- Review Rust code.
- Refactor Rust modules.

## Avoid when
- Lua scripts.
- CAG files.
- Docs-only work.

## Repo rules
- mod.rs in src/ must contain only `pub mod`, `pub use`, doc comments, and `#[allow]` attributes. Definitions belong in sibling files.
- No `#[cfg(test)]` blocks in src/. Unit tests for private code go in `tests/rust/unit/<module>_tests.rs`, named `<module>_tests.rs` not `<module>_test.rs`.
- When external tests need a private seam, prefer `pub(crate)` over `pub` and keep the exposed item narrow. Treat it as a testability boundary, not a public API expansion.
- If a `pub(crate)` seam exists only for tests, keep its doc comment explicit about that intent so future refactors do not promote it accidentally.
- `src/lua_api/*_api.rs` must stay thin: `LuaUserData` impls, `add_methods`, registration, and type conversions only. Business logic belongs in `src/<module>/`.
- Never hold `borrow_mut()` or `RefCell::borrow_mut()` across a Lua callback invocation. The pattern is: extract all needed values while holding the borrow, release it, then invoke Lua.
- SharedState access rule: `{ let guard = state.borrow(); let val = guard.field.clone(); } /* borrow released */ call_lua(val)`. The guard must be dropped before any call that might re-enter Rust.
- Pinned library versions: mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9. Do not bump without explicit authorization; each bump needs wgpu/winit API adjustments.
- When a Rust change touches public types or functions visible through `lurek.*`, run `python tools/validate/validate_lua_api.py` to catch shape drift in generated docs.
- Public changes must update `docs/specs/<module>.md` in the same commit. Compiler green does not mean the task is done.
- Use `?` for propagation but never let it cross a callback boundary silently. Closures passed to mlua must return `mlua::Result`; inner `?` should map errors before they reach Lua with a clear message.
- Keep `unsafe` blocks small, one-purpose, and accompanied by a `// SAFETY:` comment that explains the invariant. No `unsafe` for convenience when a safe alternative exists.
- Prefer explicit module imports over glob imports. Glob imports make it impossible to grep what the file actually depends on during refactors.
- Tests in `tests/rust/unit/` name their test functions `test_<behavior>_<condition>`. Keep each test assertion to one failure mode so failing tests name the problem immediately.

## Checks
- `python tools/validate/validate_lua_api.py`

## References
- `src/`
- `docs/specs/`
- `tests/rust/unit/`
- `tests/lua/`

