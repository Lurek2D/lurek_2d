---
name: performance-profiling
description: "Load this skill when analyzing or optimizing Lurek2D performance: frame time, allocations, hot paths, rendering throughput, or Lua/Rust boundary overhead. Skip it for correctness bugs or feature implementation."
---
# performance-profiling

## Mission

Own the performance budget, measurement techniques, hot-path identification, and optimization decision rules for the 60fps target.

## When To Load

- Frame time exceeds 16.6ms budget
- Identifying which phase (input, update, draw, render, physics) is slow
- Reducing draw calls or GPU overhead
- Optimizing Lua GC pressure or per-frame allocations
- Profiling the Lua-Rust boundary overhead

## When To Skip

- Correctness bugs -> use dev-debugging skill
- Feature implementation -> use rust-coding skill

## Domain Knowledge

**Frame budget at 60fps (16.6ms total):**

| Phase | Budget | Notes |
|-------|--------|-------|
| Input | <0.5ms | Polling only |
| Update | <4ms | Game logic, AI, timers |
| Draw | <1ms | Lua draw() callback, queues RenderCommands |
| Render | <8ms | GPU work, draw call dispatch |
| Physics | <3ms | Rapier2d step |

**Draw call budget:** max 200 draw calls/frame on integrated GPU (Intel UHD, AMD APU). Use SpriteBatch for batching many sprites. Each individual draw call has overhead from pipeline state changes.

**Zero-alloc hot path rule:** no Vec::new(), String::from(), .clone(), Box::new() in per-frame code paths. Pre-allocate and reuse. Use SmallVec or stack arrays for small collections in hot paths.

**Lua GC optimization:** pre-allocate tables, reuse across frames. collectgarbage("count") before/after to measure. Never collectgarbage("collect") in update/draw. String concatenation per frame is a major GC source.

**Physics scaling:** 50+ bodies = broadphase bottleneck. Circle colliders 3-5x faster than polygon colliders. Use collision groups to reduce pair checks.

**Measurement tools:** std::time::Instant for Rust (before/after around suspect code), lurek.timer.getTime() for Lua, cargo flamegraph for call-graph profiling, RUST_LOG=lurek2d::render=debug for draw call count.

## Companion File Index

None - all guidance is inline.

## References

- src/render/gpu_renderer.rs - render loop (main GPU overhead source)
- src/physics/ - rapier2d step timing
- tools/audit/quality_report.py - quality dashboard with perf metrics
