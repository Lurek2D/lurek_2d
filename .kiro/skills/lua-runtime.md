---
inclusion: manual
---

# lua-runtime

## Mission
Own Lua runtime behavior, backend differences, and runtime tuning concerns.

## When To Use
- Compare LuaJIT and Lua 5.4 behavior.
- Tune GC or runtime hot paths.
- Review lua-jit or lua54 feature use.
- Diagnose runtime-only scripting differences.

## When To Skip
- Lua-Rust binding work, general game scripts, API naming.

## Rules

### Backend Rule
LuaJIT is the shipping runtime (binding constraint B-01). `lua54` is a non-shipping CI fallback. Any behavior change acceptable only on lua54 must be guarded with `#[cfg(feature = "lua54")]` in Rust and documented explicitly.

### GC Pressure
Per-frame table creation is the most common GC pressure source: `{}` inside `on_process` allocates every frame and triggers GC pauses. Reuse pre-allocated tables via `table.clear()` (LuaJIT extension) or pre-build state tables during `on_init`.

### JIT Compilation
LuaJIT JIT compilation is per-trace, not per-function. A hot loop with a polymorphic function call (different metatable types per iteration) disables JIT for that trace. Profile with `jit.dump()` or `luajit -jdump` to confirm whether a hot path is compiled.

### FFI Warning
LuaJIT `ffi` is available and useful for tight numerical loops, but ffi types must not cross the Lua-Rust boundary through mlua — they are LuaJIT internal types and cause crashes on the Rust side.

### Cross-Backend Differences
- `table.pack` and `table.unpack`: LuaJIT follows Lua 5.1 semantics, lua54 uses 5.4 semantics. Use explicit tables instead of these for vararg packing.
- `string.format` with `%d` on a float: truncates silently in LuaJIT (5.1 behavior), raises an error in lua54 (5.4 behavior). Test format strings against both backends in CI if they handle numbers.

### Worker VM Isolation
Each worker thread runs an independent Lua VM. `lurek.thread.channel` is the only safe communication path between VMs. The `require` cache (`package.loaded`) is per-VM — each worker must `require` its dependencies explicitly.

### GC Tuning
`collectgarbage("setpause", n)` and `collectgarbage("setstepmul", n)`. Only tune when `lurek.debug.frame_stats()` shows `lua_gc_ms` above 1 ms consistently.

### Filing a Lua Runtime Bug
Always state: feature flag used (`luaJIT` or `lua54`), reproduction script (minimal, deterministic), observed vs expected behavior, and whether the issue is LuaJIT-only, lua54-only, or both.

## References
- `Cargo.toml`
- `src/runtime/`
- `src/thread/`
- `docs/specs/thread.md`
