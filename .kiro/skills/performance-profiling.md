---
inclusion: manual
---

# performance-profiling

## Mission
Own measurement-first performance analysis for frame time and hot paths.

## When To Use
- Measuring a slowdown.
- Analyzing allocations.
- Finding a hot path.
- Comparing performance across scenarios.

## When To Skip
- Correctness bugs, feature implementation.

## Rules

### Target Platform
- 60 FPS at 1080p on integrated GPUs (binding constraint B-03). Test on Intel UHD 620 baseline, not the development machine. A drop from 62 FPS to 58 FPS on integrated is a regression. A drop from 400 to 350 FPS on discrete GPU is irrelevant.

### Profile in Release Only
- Dev build frame times are 3–10× slower due to allocator overhead, debug assertions, and unoptimized bounds checks. Never profile in debug.

### Frame Budget (integrated GPU at 1080p)
- Lua tick: ≤ 2 ms
- Rust physics/audio: ≤ 4 ms
- Render command build: ≤ 1 ms
- GPU submission: ≤ 8 ms
- Total: ≤ 16.7 ms

Use `lurek.debug.frame_stats()` which returns `cpu_ms`, `gpu_ms`, `lua_ms`, `physics_ms` to identify the over-budget bucket first.

### Common CPU Hot Paths (in order of frequency)
1. Lua GC pressure from per-frame table allocation.
2. `Vec::push` without pre-allocation in render command buffers.
3. `RefCell::borrow_mut()` in dense physics loops.
4. Redundant sprite state reads per draw call.

### Common GPU Hot Paths
1. Excessive bind-group switches per render pass.
2. Uploading unchanged CPU buffers to GPU every frame.
3. Overdraw from layered sprites without batching.

Use RenderDoc captures to confirm GPU issues — guesses without a capture are unreliable.

### Required Measurement Format
Every optimization must include all four values in the commit message or session note:
`baseline metric / proposed change / expected improvement / measured result after`

An optimization without a measured result is not verified.

### Tooling
- Run `tools/audit/stress_report.py` before ad hoc profiling — it often pinpoints the budget problem in 30 seconds.
- Use `cargo build --features profiling` with dhat integration to count allocations per frame.
- `alloc_per_frame` counter in `frame_stats()` gives a quick per-frame allocation signal.
- Per-frame heap allocations should trend toward zero for hot paths.

### Roles
- Verifier owns the baseline capture, delta measurement, and gating decision.
- Developer implements the fix.
- Tester validates that correctness is preserved after the optimization.
- Do not interleave correctness fixes and performance optimizations in one commit.

## References
- `src/render/`
- `src/physics/`
- `tools/audit/stress_report.py`
- `tools/audit/quality_report.py`
