---
name: lua-runtime
description: "Load this skill when working with the Lua scripting runtime in Lurek2D: LuaJIT vs Lua 5.4 behavioral differences, the lua-jit and lua54 Cargo feature flags, mlua 0.9 specifics, garbage collector tuning, LuaJIT bitwise ops, upvalue and stack limits, string interning, or Lua performance patterns. Use for: LuaJIT FFI, GC pressure, per-frame Lua optimisation, Lua 5.4 compat testing. Skip it for the Rust binding layer (use lua-rust-bridge), general Lua game scripting (use lua-scripting), or Lua API design (use lua-api-design)."
---
# lua-runtime

## Mission

Own LuaJIT vs Lua 5.4 differences, mlua 0.9 specifics, GC tuning, upvalue/stack limits, string interning, and per-frame Lua performance patterns.

## When To Load

- Choosing between lua-jit and lua54 Cargo features
- Diagnosing LuaJIT-specific limitations (upvalues, stack depth)
- Tuning garbage collector for frame-rate stability
- Optimising Lua code for hot paths (per-frame update/draw)
- Handling cross-compatibility between LuaJIT and Lua 5.4

## When To Skip

- Rust binding layer mechanics -> use lua-rust-bridge skill
- General game scripting patterns -> use lua-scripting skill
- API surface design -> use lua-api-design skill

## Domain Knowledge

**Feature flags:** lua-jit is the shipping runtime (default). lua54 is a non-shipping CI fallback only. Never ship with lua54. Both are mlua 0.9 features in Cargo.toml.

**LuaJIT limits:** max 60 upvalues per closure (Lua 5.4 allows 255). C stack depth approx 800 frames before overflow. JIT trace max 4096 IR instructions. If a hot loop exceeds trace limits, LuaJIT falls back to interpreter silently.

**GC tuning:** never call collectgarbage("collect") in update() or draw() - causes frame spikes. Use collectgarbage("step", N) with small N between scenes. Default GC stepmul/pause are fine for most games. Monitor with collectgarbage("count") to detect leaks (>50MB is suspicious for a 2D game).

**Per-frame optimization:** cache globals in locals (local floor = math.floor); avoid creating tables per frame - pre-allocate and reuse; avoid string concatenation per frame - pre-build lookup tables; avoid metatables on hot paths (metamethod dispatch is slower than direct calls).

**Cross-compatibility patterns:** local unpack = table.unpack or unpack; local bit = bit or {} (bit ops); use math.floor(a/b) for integer division (no // in LuaJIT); avoid goto (LuaJIT supports it but behavior differs subtly).

**String interning:** LuaJIT interns all strings up to 47 bytes. Prefer short string keys for table lookups. Long strings (>47 bytes) are not interned and create GC pressure if created per frame.

## Companion File Index

None - all guidance is inline.

## References

- Cargo.toml - lua-jit and lua54 feature flag definitions
- src/runtime/ - Lua VM initialization and lifecycle
- docs/specs/thread.md - multi-VM threading constraints
