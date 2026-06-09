# Runtime Contract

Covers work under `src/runtime/`.

## Mission
- Own Lua backend selection, runtime behavior differences, and VM-level performance expectations.

## Scope
- `src/runtime/` backend selection and runtime behavior.

## Local map
- `Cargo.toml` records backend wiring.
- `src/thread/` and `docs/specs/thread.md` cover worker isolation rules.

## Rules
- LuaJIT is the shipping runtime; `lua54` is a compatibility and CI fallback.
- Treat per-frame table allocation as a hot-path smell.
- LuaJIT optimizes traces, not whole functions.
- Do not let LuaJIT FFI values cross the Rust binding boundary through `mlua`.
- Be conservative around backend-sensitive helpers such as vararg packing and numeric formatting.
- Runtime bug reports or fixes should state whether the behavior is LuaJIT-only, `lua54`-only, or shared.

## Workflow
- Check both runtime backends when a bug or semantic change depends on Lua version behavior.
- Keep runtime-facing behavior aligned with the matching spec and thread-worker isolation rules.

## References
- `Cargo.toml`
- `src/thread/`
- `docs/specs/thread.md`
