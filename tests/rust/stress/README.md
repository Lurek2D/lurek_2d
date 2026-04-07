# tests/rust/stress — Rust Stress Tests

Throughput and allocation tests for engine subsystems.

## Naming

`<module>_stress_tests.rs` — e.g. `physics_stress_tests.rs`

## Purpose

- High-volume operations (body creation, draw command floods, etc.)
- Verify no panics or heap exhaustion under load
- Headless — no GPU/audio/window

## Registration

Every file here must have a corresponding `[[test]]` entry in `Cargo.toml`.
