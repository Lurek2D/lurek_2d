# Runtime Contract

This file adds local rules for work under `src/runtime/`.

## Mission
- Own Lua backend selection, runtime behavior differences, and VM-level performance expectations.

## Local rules
- LuaJIT is the shipping runtime. `lua54` is a compatibility and CI fallback, not the primary target surface.
- Treat per-frame table allocation as a hot-path smell. Reuse tables or initialize stable state earlier when the same structure repeats every frame.
- Remember that LuaJIT optimizes traces, not whole functions. Polymorphic hot loops can drop out of JIT unexpectedly.
- Do not let LuaJIT FFI values cross the Rust binding boundary through `mlua`.
- Be conservative around backend-sensitive helpers such as vararg packing and numeric formatting; cross-backend behavior can differ in edge cases.
- Runtime bug reports or fixes should state whether the behavior is LuaJIT-only, `lua54`-only, or shared.

## Workflow
- Check both runtime backends when a bug or semantic change plausibly depends on Lua version behavior.
- Keep runtime-facing behavior aligned with the matching spec and with thread-worker isolation rules.

## References
- `Cargo.toml`
- `src/thread/`
- `docs/specs/thread.md`
