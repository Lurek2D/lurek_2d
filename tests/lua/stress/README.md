# tests/lua/stress — Lua Stress Tests

Throughput and allocation tests that run many iterations from Lua scripts.

## Naming

`test_<module>_stress.lua` — e.g. `test_math_stress.lua`, `test_physics_stress.lua`

## Purpose

- Volume operations (thousands of entity spawns, math iterations, etc.)
- Verify no OOM panics or performance cliffs
- Headless — no GPU/audio/window calls

## Harness

Dispatched by `tests/lua/harness.rs` — one `#[test]` per file.
