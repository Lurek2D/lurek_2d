---
name: error-handling
description: "Load this skill when designing Result flows, EngineError variants, Lua error propagation, or panic prevention. Skip it for general Rust coding or test work."
---
# error-handling

## Use when
- Add or change EngineError variants.
- Convert errors across Rust and Lua boundaries.
- Prevent panics in normal runtime paths.
- Review recoverable versus fatal behavior.

## Avoid when
- General Rust implementation.
- Test writing.

## Repo rules
- `src/runtime/error.rs` defines `EngineError` with distinct variants â€” never collapse distinct failure classes into a generic `String` variant. Each variant enables targeted recovery logic.
- Lua-visible error messages follow this pattern: `map_err(|e| mlua::Error::RuntimeError(format!("lurek.audio.play: {}", e)))`. Include the module and function in the message so content authors can locate the failing call without a Rust stack trace.
- Recoverable vs. fatal classification: `asset_not_found` is recoverable â€” log at warn, return `nil` or a fallback.
- The `src/lua_api/` and app startup paths are the highest-risk panic sites. Every boundary function must return `mlua::Result<T>` and propagate with `?`, never `unwrap()` or `expect()` unless the invariant is truly unbreakable and commented.
- Do not log and re-wrap the same error at every layer. One `error!()` at the origination site plus one `map_err()` for context at the boundary is the pattern.
- Leak no internals in outward messages: no absolute filesystem paths, no raw Rust type names, no memory addresses or internal handle IDs. Content authors see a stable error surface, not implementation detail.
- Callback and thread-crossing errors: preserve the error category and a human-readable string across channel sends. Receivers need to decide retry-vs-abort, so the error type must survive the send without losing its intent.
- Five distinct failure classes to treat separately: invalid content, missing required resource, unsupported runtime state, unavailable external resource, and engine defect. Each implies a different response â€” reject input, fallback, reject call, retry, and panic respectively.
- When converting from `std::io::Error`, `image::ImageError`, or similar external errors into `EngineError`, choose the variant by semantic meaning not by the source type. An IO error reading a .png is an asset error, not a generic IO error.
- `panic!` is acceptable only for internal invariant violations that indicate a programmer error, not for any user-input-triggered path. All `unwrap()` on user-facing paths must be replaced with explicit error propagation.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `src/runtime/error.rs`
- `src/lua_api/`
- `src/app/app.rs`
- `docs/specs/lua-api-file-standard.md`

