---
name: dev-debugging
description: "Load this skill when diagnosing runtime bugs, crashes, or unexpected behavior in Lurek2D. It owns diagnostic techniques, error tracing, and root cause analysis patterns. Skip it for feature implementation or test writing."
---
# dev-debugging

## Mission

Own diagnostic techniques, error tracing, and root cause analysis patterns for runtime bugs in Lurek2D.

## When To Load

- Investigating a crash or panic in the engine
- Tracing unexpected behavior in game scripts or engine code
- Analyzing error messages or stack traces
- Debugging RefCell borrow panics or type errors

## When To Skip

- Writing fixes → route to Developer agent
- Performance analysis → use performance-profiling skill
- Test writing → use testing-rust skill

## Domain Knowledge

**First steps — always:** read the panic message first (file:line:message). Follow the code path, never guess the cause.

**Environment variables for diagnosis:** RUST_LOG=lurek2d=debug (engine debug output), RUST_BACKTRACE=full (full stack traces), WGPU_BACKEND=vulkan (force Vulkan for GPU debugging).

**Common error patterns:**

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| already borrowed: BorrowMutError | Two closures both borrow_mut() SharedState | Restructure: drop borrow before callback |
| already borrowed: BorrowError | SharedState borrowed immutably when mutable borrow requested | End immutable borrow first |
| LuaError: expected table, got nil | lurek.someModule not registered | Check lua_api/mod.rs register() chain |
| LuaError: attempt to index nil | Lua variable not initialised before use | Trace where the variable should have been set |
| SlotMap: key used after removal | Stale TextureKey/FontKey used after release() | Check resource lifecycle; never cache beyond lifetime |
| wgpu ERROR: validation error | Invalid GPU state (bind group mismatch, buffer size) | Set RUST_LOG=wgpu_core=warn and read full message |
| C stack overflow | LuaJIT stack depth exceeded ~800 frames | Flatten recursion or increase stack size |
| Blank window, no errors | lurek.draw() never called or draw calls outside canvas scope | Confirm callback fires with diagnostic logging |

**Lua error debugging:** lurek.errorhandler(msg) for custom crash handling; pcall() for recoverable errors. When LuaError originates in Rust, the error message includes the Rust source location if LuaError::external(e) was used — the prefix luna2d::<module>: points to src/<module>/.

**RefCell borrow diagnosis:** "already borrowed" always means two closures both borrow SharedState. Fix: clone the Rc BEFORE moving into the closure, drop the immutable borrow before requesting a mutable one, never hold a borrow across a Lua callback invocation.

**Decision rules:** read panic message first; minimal reproduction (reduce to smallest triggering state); log strategically with log::debug!/trace! for temporary diagnostics; check callback order (state mutation during lurek.draw() should be read-only); most bugs occur at Lua-Rust type conversion boundaries.

## Companion File Index

None — all guidance is inline.

## References

- src/lua_api/mod.rs — SharedState borrow patterns (common source of bugs)
- src/app/app.rs — main loop where errors surface
- src/runtime/error.rs — EngineError types for error classification
- tools/dev/test_fix_loop.py — test-run/fix/re-run loop for fast iteration
