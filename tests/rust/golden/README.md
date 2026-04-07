# tests/rust/golden — Rust Golden Tests

Deterministic binary output tests. Known inputs produce expected output compared byte-for-byte against baselines.

## Directories

| Dir | Purpose |
|---|---|
| `expected/` | Committed baseline files — used for diff comparison |
| `actual/` | Generated on each test run — gitignored |
| `screenshots/` | CPU-rendered PNG evidence — committed to repo |

## How it works

1. Test calls `assert_golden("name", &bytes)`
2. If `expected/name` does not exist → baseline is created automatically on first run
3. On subsequent runs → output is compared byte-for-byte
4. On mismatch → test fails; see `actual/name` for the generated output

## Harness

`tests/rust/golden/harness.rs` — single `[[test]]` entry in `Cargo.toml` as `golden_tests`.
