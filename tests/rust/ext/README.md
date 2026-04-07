# tests/rust/ext — Extension / Smoke Tests

Runtime smoke tests that require a compiled binary or real asset loading. Tests here may use saved screenshots as evidence.

## Contents

- `graphics_ext_tests.rs` — runtime graphics path smoke tests
- `math_ext_tests.rs` — math module smoke tests
- `terminal_demo_smoke_tests.rs` — end-to-end demo smoke test
- `graphics_runtime_smoke_tests.rs` — screenshot-backed GPU renderer evidence
- `smoke_support.rs` — shared helpers for screenshot capture

## Policy

- Prefer `tests/rust/unit/` for headless logic tests
- Use ext tests only when you need file I/O, a screenshot, or an asset loader
- Screenshot outputs go to `tests/rust/golden/screenshots/`
