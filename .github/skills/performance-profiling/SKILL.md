---
name: performance-profiling
description: "Load this skill when analyzing or optimizing frame time, allocations, hot paths, rendering throughput, or Lua-Rust overhead. Skip it for correctness bugs or feature work."
---
# performance-profiling

## Mission
- Own measurement-first performance analysis for frame time and hot paths.

## When To Load
- Measure a slowdown.
- Analyze allocations.
- Find a hot path.
- Compare performance across scenarios.

## When To Skip
- Correctness bugs.
- Feature implementation.

## Domain Knowledge
- Target is 60 FPS at 1080p on integrated GPUs. A change that drops an Intel UHD 620 from 62 FPS to 58 FPS is a regression.
- Measure in `--release` only. Dev build frame times are 3-10× slower and will point to allocator overhead, debug assertions, or unoptimized bounds checks that disappear in release.
- Frame budget split for integrated GPU at 1080p: Lua tick ≤ 2 ms, Rust physics/audio ≤ 4 ms, render command build ≤ 1 ms, GPU submission ≤ 8 ms. When total exceeds 16.7 ms, identify which bucket is over budget first — `lurek.debug.frame_stats()` returns `cpu_ms`, `gpu_ms`, `lua_ms`, `physics_ms` for this purpose.
- Common CPU hot paths in order of observed frequency: Lua GC pressure from per-frame table allocation, `Vec::push` without pre-allocation in render command buffers, `RefCell::borrow_mut()` in dense physics loops, redundant sprite state reads per draw call. Check these before reaching for flamegraph.
- Common GPU hot paths: excessive bind-group switches per render pass, uploading unchanged CPU buffers to GPU every frame, overdraw from layered sprites without batching. Use RenderDoc captures to confirm — GPU-side guesses without a capture are unreliable.
- Required measurement format: `baseline metric / proposed change / expected improvement / measured result after`. All four values must appear in the commit message or session note.
- `tools/audit/stress_report.py` runs existing stress scenarios and outputs per-module timing breakdowns. Run this before ad hoc profiling — it often pinpoints the budget problem in 30 seconds.
- Memory allocation budget: per-frame heap allocations should trend toward zero for hot paths. Use `cargo build --features profiling` with dhat integration to count allocations per frame.
- Profiling is one phase: Verifier owns the baseline capture, delta measurement, and gating decision. Developer implements the fix.
- Do not interleave correctness fixes and performance optimizations in one commit — attribution becomes impossible when both change together.
## Companion File Index
- None.

## References
- src/render/
- src/physics/
- tools/audit/stress_report.py
- tools/audit/quality_report.py