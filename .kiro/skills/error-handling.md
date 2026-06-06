---
inclusion: manual
---

# error-handling

## Mission
Own Result flow, EngineError shape, and Lua-visible error behavior.

## When To Use
- Adding or changing `EngineError` variants.
- Converting errors across Rust and Lua boundaries.
- Preventing panics in normal runtime paths.
- Reviewing recoverable vs. fatal behavior.

## When To Skip
- General Rust implementation, test writing.

## Rules

### EngineError Shape
- `src/runtime/error.rs` defines `EngineError` with distinct variants — never collapse distinct failure classes into a generic `String` variant.
- Five distinct failure classes: invalid content, missing required resource, unsupported runtime state, unavailable external resource, engine defect. Each implies a different response.
- When converting from `std::io::Error`, `image::ImageError`, etc. into `EngineError`, choose the variant by semantic meaning, not source type. An IO error reading a `.png` is an asset error.

### Recoverable vs. Fatal
- `asset_not_found` → recoverable: log at `warn!`, return `nil` or a fallback.
- `shader_compile_failed` → fatal: abort render pipeline, surface a developer-visible message.
- Config parse errors at startup → fatal.
- Missing optional asset at runtime → recoverable.

### Lua Boundary
- Lua-visible error messages: `map_err(|e| mlua::Error::RuntimeError(format!("lurek.audio.play: {}", e)))`. Include module and function name.
- `src/lua_api/` and app startup paths are highest-risk panic sites. Every boundary function must return `mlua::Result<T>` and propagate with `?`. Never `unwrap()` or `expect()` unless the invariant is truly unbreakable and commented.

### Logging
- One `error!()` at the origination site plus one `map_err()` for context at the boundary. Do not log and re-wrap the same error at every layer.
- Leak no internals in outward messages: no absolute filesystem paths, no raw Rust type names, no memory addresses. Use GameFS-normalized path.

### Thread/Callback Crossing
- Preserve error category and human-readable string across channel sends. Receivers need retry-vs-abort context.

### panic! Usage
- `panic!` is acceptable only for internal invariant violations that indicate a programmer error, never for any user-input-triggered path.
- All `unwrap()` on user-facing paths must be replaced with explicit error propagation.

## References
- `src/runtime/error.rs`
- `src/lua_api/`
- `src/app/app.rs`
- `docs/specs/lua-api-file-standard.md`
