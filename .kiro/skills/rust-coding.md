---
inclusion: manual
---

# rust-coding

## Mission
Own safe, idiomatic Rust patterns for the engine codebase.

## When To Use
- Writing or reviewing Rust engine code.
- Refactoring Rust modules.

## When To Skip
- Lua scripts, CAG files, docs-only work.

## Rules

### Module Structure
- `mod.rs` in `src/` must contain only `pub mod`, `pub use`, doc comments, and `#[allow]` attributes. No function or struct bodies — those belong in sibling files.
- No `#[cfg(test)]` blocks in `src/`. Unit tests go in `tests/rust/unit/<module>_tests.rs`.
- `src/lua_api/*_api.rs` must stay thin: `LuaUserData` impls, `add_methods`, registration, and type conversions only. Business logic belongs in `src/<module>/`.

### Borrow Safety
- Never hold `borrow_mut()` or `RefCell::borrow_mut()` across a Lua callback invocation.
- Pattern: extract all needed values while holding the borrow, release it, then invoke Lua.
- SharedState access: `{ let guard = state.borrow(); let val = guard.field.clone(); } /* borrow released */ call_lua(val)`.

### Dependencies
- Pinned library versions: mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9. Do not bump without explicit authorization.
- Prefer explicit module imports over glob imports (`use module::*`).

### Error Propagation
- Use `?` for propagation but never let it cross a callback boundary silently.
- Closures passed to mlua must return `mlua::Result`; inner `?` should map errors before reaching Lua with a clear message.
- Keep `unsafe` blocks small, one-purpose, with a `// SAFETY:` comment. No `unsafe` for convenience.

### Validation
- When a Rust change touches public types visible through `lurek.*`, run `python tools/validate/validate_lua_api.py`.
- Public changes must update `docs/specs/<module>.md` and `docs/CHANGELOG.md` in the same commit.

### Test Naming
- Test functions: `test_<behavior>_<condition>`. One failure mode per test.

## Rustdoc Standards

### Regular Files (`src/` excluding `src/lua_api/`)
Every `pub fn`, `fn`, `pub struct`, `struct`, `pub enum`, `enum`, `pub mod`, `pub type`, `pub const`, `impl Trait for Type`, every struct field, and every enum variant requires a `///` comment.

**File-level (`//!`)** — bullet-point format, proportional to file size:
- Small (<3000 chars): ~300 chars, 3–4 bullets.
- Medium (3000–10000 chars): ~600 chars, 5–7 bullets.
- Large (>10000 chars): ~1200 chars, 8–12 bullets.

Describe capabilities and behaviors, not individual symbol names.

**Methods/functions** — one line: what it does AND what it returns, including edge cases. No `# Arguments`, `# Returns`, `# Errors` sections.

**Forbidden phrases**: "returns a fully initialised instance", "alias for", "shorthand for", "convenience wrapper", "incurs no allocation", "O(1)", "amortised". Open with imperative verb ("Return", "Read", "Parse"), not "Returns".

### Lua API Files (`src/lua_api/`)
File-level header: `` //! `lurek.<module>` -- <concrete description> ``

Registered Lua calls only (via `add_method`, `add_function`, etc.) require:
```
/// Summary line.
/// @param | <lua_name> | <lua_type> | <description>
/// @return | <lua_type> | <description>
```
Every registered call must have at least one `@return` marker.

**Forbidden in `src/lua_api/`**: `/// # Parameters`, `/// # Returns`, `@return | any | ...`, optional/union return types.

## References
- `src/`
- `docs/specs/`
- `tests/rust/unit/`
- `tools/validate/validate_lua_api.py`
