# Compute Module Contract

## Mission & Scope
- Own dense arrays, shape logic, reductions, and numeric transforms.
- Keep array operations deterministic and allocation-aware.

## Files
- `array.rs`, `linalg.rs`: Core numeric data and matrix helpers.
- `mod.rs`: Public module surface.

## Rules
- Validate shape, dtype, and axis inputs before touching buffers.
- In-place operations must document mutation and aliasing expectations.
- Reject silent truncation when converting Lua numbers to indexes or sizes.

## Workflow
- Validate with `cargo test --test compute_tests`.
