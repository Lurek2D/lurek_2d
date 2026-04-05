# Luna2D — Test Framework Architecture

> **Source of truth** for the test suite structure, naming conventions, BDD framework, and CI quality gates.
> Companion documents: [engine-architecture.md](engine-architecture.md) (runtime module structure) · [philosophy.md](philosophy.md) (principles + design assumptions).

---

## Table of Contents

1. [Overview](#overview)
2. [Two-Layer Test Model](#two-layer-test-model)
3. [Directory Layout](#directory-layout)
4. [Rust Test Suites](#rust-test-suites)
5. [Lua BDD Test Framework](#lua-bdd-test-framework)
6. [Golden Tests](#golden-tests)
7. [VM Helpers](#vm-helpers)
8. [Naming Conventions](#naming-conventions)
9. [Float Comparison Rules](#float-comparison-rules)
10. [Test Constraints](#test-constraints)
11. [Adding a New Rust Test](#adding-a-new-rust-test)
12. [Adding a New Lua Test](#adding-a-new-lua-test)
13. [Running Tests](#running-tests)
14. [Quality Gates](#quality-gates)
15. [Test Coverage Tooling](#test-coverage-tooling)
16. [Test-Driven Development Workflow](#test-driven-development-workflow)
17. [Problem Areas and Known Issues](#problem-areas-and-known-issues)

---

## Overview

Luna2D uses a **two-layer test system** executed entirely through `cargo test`:

1. **Rust integration tests** — compiled Rust test binaries that exercise engine modules directly via crate imports.
2. **Lua BDD tests** — `.lua` scripts using a custom `describe`/`it`/`expect_*` framework, dispatched by a Rust harness.

Both layers run headless — no window, no GPU, no audio device required. This enables CI/CD and parallel execution without display servers.

---

## Two-Layer Test Model

```
cargo test
  │
  ├── Rust Test Binaries ──────────────────────────────────────────┐
  │   ├── tests/unit/math_tests.rs          (27+ unit test files)  │
  │   ├── tests/unit/graphics_tests.rs                             │
  │   ├── tests/unit/physics_tests.rs                              │
  │   ├── tests/ext/graphics_ext_tests.rs   (extension tests)      │
  │   ├── tests/game/cardgame_tests.rs      (gameplay system tests)│
  │   ├── tests/stress/physics_stress.rs    (stress tests)         │
  │   └── ...                                                      │
  │                                                                │
  ├── Golden Test Harness ─────────────────────────────────────────┤
  │   └── tests/golden/harness.rs           (16 golden tests)      │
  │       └── compares actual output against tests/golden/expected/ │
  │                                                                │
  └── Lua BDD Harness ────────────────────────────────────────────┘
      └── tests/lua/harness.rs
          ├── tests/lua/unit/test_math.lua        (30+ unit files)
          ├── tests/lua/integration/test_cross.lua (10+ files)
          ├── tests/lua/stress/test_perf.lua       (12+ files)
          ├── tests/lua/validation/test_edge.lua   (3+ files)
          └── tests/lua/golden/test_golden.lua     (1+ files)
```

### Why Two Layers?

- **Rust tests** verify internal engine contracts: struct invariants, error handling, resource lifecycle, mathematical correctness. They have direct access to Rust types and can test private-via-crate internals.
- **Lua tests** verify the public `luna.*` API surface: function signatures, return types, error messages, and end-to-end workflows. They run in the same VM that game scripts use, catching API regressions from the user's perspective.

---

## Directory Layout

```
tests/
├── unit/                            Rust unit tests (1 file per module)
│   ├── math_tests.rs
│   ├── graphics_tests.rs
│   ├── audio_tests.rs
│   ├── physics_tests.rs
│   ├── input_tests.rs
│   ├── timer_tests.rs
│   ├── filesystem_tests.rs
│   ├── compute_tests.rs
│   ├── data_tests.rs
│   ├── image_tests.rs
│   ├── sound_tests.rs
│   ├── event_tests.rs
│   ├── entity_tests.rs
│   ├── window_tests.rs
│   ├── thread_tests.rs
│   ├── animation_tests.rs
│   ├── camera_tests.rs
│   ├── particle_tests.rs
│   ├── tilemap_tests.rs
│   ├── scene_tests.rs
│   ├── savegame_tests.rs
│   ├── modding_tests.rs
│   ├── graph_tests.rs
│   ├── pathfinding_tests.rs
│   ├── ai_tests.rs
│   ├── terminal_tests.rs
│   └── ...
│
├── ext/                             Extension / cross-module Rust tests
│   ├── graphics_ext_tests.rs
│   └── math_ext_tests.rs
│
├── game/                            Gameplay system Rust tests
│   ├── cardgame_tests.rs
│   ├── combat_tests.rs
│   ├── crafting_tests.rs
│   ├── inventory_tests.rs
│   ├── minimap_tests.rs
│   ├── province_tests.rs
│   ├── quest_tests.rs
│   ├── resource_tests.rs
│   └── stats_tests.rs
│
├── stress/                          Rust stress and performance tests
│   ├── compute_stress.rs
│   ├── data_stress.rs
│   ├── image_stress.rs
│   └── physics_stress.rs
│
├── golden/                          Golden (snapshot) tests
│   ├── harness.rs                   Rust harness dispatching golden tests
│   ├── expected/                    Expected output files (committed to git)
│   │   ├── image/
│   │   ├── hash/
│   │   ├── encode/
│   │   ├── compress/
│   │   └── data/
│   └── actual/                      Actual output files (git-ignored)
│
└── lua/                             Lua BDD tests
    ├── harness.rs                   Rust harness dispatching Lua tests
    ├── init.lua                     BDD framework (describe/it/expect_*)
    │
    ├── unit/                        One-module Lua tests
    │   ├── test_math.lua
    │   ├── test_graphics.lua
    │   ├── test_audio.lua
    │   ├── test_physics.lua
    │   ├── test_input.lua
    │   ├── test_timer.lua
    │   ├── test_filesystem.lua
    │   ├── test_data.lua
    │   ├── test_image.lua
    │   ├── test_sound.lua
    │   ├── test_event.lua
    │   ├── test_particle.lua
    │   ├── test_scene.lua
    │   ├── test_tilemap.lua
    │   ├── test_pathfinding.lua
    │   ├── test_ai.lua
    │   ├── test_terminal.lua
    │   └── ...
    │
    ├── integration/                 Cross-module Lua tests
    │   ├── test_graphics_integration.lua
    │   ├── test_data_roundtrip.lua
    │   └── ...
    │
    ├── stress/                      Performance Lua tests
    │   ├── test_math_perf.lua
    │   ├── test_data_perf.lua
    │   └── ...
    │
    ├── validation/                  Negative-path / edge case Lua tests
    │   ├── test_error_handling.lua
    │   └── ...
    │
    └── golden/                      Deterministic output Lua tests
        └── test_math_golden.lua
```

### Cargo.toml Registration

All test binaries are **explicitly registered** in `Cargo.toml` under `[[test]]` sections. An unregistered `.rs` file in `tests/` will not be discovered by `cargo test`.

```toml
# Example entries
[[test]]
name = "math_tests"
path = "tests/unit/math_tests.rs"

[[test]]
name = "golden_tests"
path = "tests/golden/harness.rs"

[[test]]
name = "lua_tests"
path = "tests/lua/harness.rs"
```

---

## Rust Test Suites

### Suite Categories

| Category | Path | Scope | Example |
|---|---|---|---|
| **Unit** | `tests/unit/` | One module, Rust-side invariants | `math_tests.rs`: Vec2 arithmetic |
| **Extension** | `tests/ext/` | Cross-module integration, Rust | `graphics_ext_tests.rs`: mesh + texture |
| **Game** | `tests/game/` | Gameplay system correctness | `crafting_tests.rs`: recipe resolution |
| **Stress** | `tests/stress/` | Throughput and allocation pressure | `physics_stress.rs`: 10K body world |

### Test Structure Pattern

```rust
// tests/unit/math_tests.rs

use luna2d::math::{Vec2, Mat3, Rect, Color};
use luna2d::math::noise::Noise;
use luna2d::math::random::RandomGenerator;

// ============================================================
// Vec2 Tests
// ============================================================

#[test]
fn vec2_add_returns_component_wise_sum() {
    let a = Vec2::new(1.0, 2.0);
    let b = Vec2::new(3.0, 4.0);
    let result = a + b;
    assert!((result.x - 4.0).abs() < 1e-5);
    assert!((result.y - 6.0).abs() < 1e-5);
}

#[test]
fn vec2_length_of_unit_vector_is_one() {
    let v = Vec2::new(1.0, 0.0);
    assert!((v.length() - 1.0).abs() < 1e-5);
}

// ============================================================
// Color Tests
// ============================================================

#[test]
fn color_new_clamps_to_0_1() {
    let c = Color::new(2.0, -1.0, 0.5, 1.0);
    assert!((c.r - 1.0).abs() < 1e-5);
    assert!((c.g - 0.0).abs() < 1e-5);
}
```

---

## Lua BDD Test Framework

All Lua tests use a custom BDD framework defined in `tests/lua/init.lua`. This framework is loaded automatically by `create_test_vm()`.

### Framework API

| Function | Purpose |
|---|---|
| `describe(name, fn)` | Group related tests under a named section |
| `it(name, fn)` | Define a single test case |
| `expect_equal(expected, actual)` | Assert strict equality |
| `expect_near(expected, actual, tolerance)` | Assert float proximity |
| `expect_type(value, type_name)` | Assert Lua type (`"number"`, `"table"`, etc.) |
| `expect_error(fn)` | Assert fn throws an error |
| `expect_not_nil(value)` | Assert value is not nil |
| `expect_true(value)` | Assert truthy |
| `expect_false(value)` | Assert falsy |
| `expect_gt(a, b)` | Assert `a > b` |
| `expect_lt(a, b)` | Assert `a < b` |
| `expect_gte(a, b)` | Assert `a >= b` |
| `expect_lte(a, b)` | Assert `a <= b` |
| `expect_contains(table, value)` | Assert value in table |
| `expect_match(string, pattern)` | Assert Lua pattern match |
| `test_summary()` | **MANDATORY** — must be the last call in every file |

### Lua Test File Template

```lua
-- tests/lua/unit/test_modulename.lua
-- Tests for luna.modulename API

describe("luna.modulename", function()
    describe("someFunction", function()
        it("should return expected result", function()
            local result = luna.modulename.someFunction(42)
            expect_equal(84, result)
        end)

        it("should handle edge cases", function()
            expect_error(function()
                luna.modulename.someFunction(nil)
            end)
        end)
    end)

    describe("anotherFunction", function()
        it("should accept default params", function()
            local val = luna.modulename.anotherFunction()
            expect_not_nil(val)
            expect_type(val, "number")
        end)
    end)
end)

test_summary()
```

### Harness Dispatch

The Lua harness (`tests/lua/harness.rs`) maps each `#[test]` function to a `.lua` file:

```rust
// tests/lua/harness.rs
use luna2d::lua_api::create_test_vm;

fn run_lua_test(path: &str) {
    let vm = create_test_vm();
    // Load init.lua (BDD framework)
    // Execute test file
    // Check _test_results global for failures
    // Assert all tests passed
}

#[test]
fn lua_test_math() { run_lua_test("unit/test_math.lua"); }

#[test]
fn lua_test_graphics() { run_lua_test("unit/test_graphics.lua"); }

#[test]
fn lua_test_physics() { run_lua_test("unit/test_physics.lua"); }

// ... one entry per Lua test file
```

---

## Golden Tests

Golden tests verify deterministic output by comparing actual results against committed expected files.

### Structure

```
tests/golden/
├── harness.rs                 Rust harness
├── expected/                  Committed reference files
│   ├── image/                 Expected PNG snapshots
│   ├── hash/                  Expected hash digests
│   ├── encode/                Expected encoded strings
│   ├── compress/              Expected compressed bytes
│   └── data/                  Expected binary data
└── actual/                    Generated during test run (git-ignored)
```

### Flow

1. Test generates output (hash, image, encoded data)
2. Output saved to `tests/golden/actual/`
3. Compared byte-for-byte against `tests/golden/expected/`
4. Pass if identical; fail with diff report if different

### Updating Golden Files

When output intentionally changes (e.g., algorithm improvement), manually copy `actual/` to `expected/` and commit. Always review diffs before committing updated golden files.

---

## VM Helpers

Two Rust-side helpers create test Lua VMs:

### `create_test_vm()`

Returns a fully-initialized Lua VM with:
- BDD framework (`init.lua`) loaded
- `_test_results` global table ready
- All `luna.*` API modules registered
- **Headless**: no window, GPU, or audio device

Used by: Lua BDD harness.

### `make_vm()`

Returns `(Rc<RefCell<SharedState>>, Lua)` — a SharedState + Lua VM pair for stateful Rust-side tests that need to:
- Inspect SharedState after Lua calls
- Pre-populate resources before running Lua
- Test resource lifecycle through the Lua boundary

---

## Naming Conventions

### Rust Tests

- **No `test_` prefix** on `#[test]` functions (Rust already knows they are tests).
- Format: `<subject>_<scenario>_<expected_outcome>`
- Section separators: `// ============================================================`

```rust
// GOOD
#[test] fn vec2_normalize_returns_unit_length() { }
#[test] fn world_step_applies_gravity() { }
#[test] fn color_from_hex_parses_6_digit() { }

// BAD
#[test] fn test_vec2_normalize() { }       // has test_ prefix
#[test] fn test1() { }                       // meaningless name
```

### Lua Tests

- File naming: `test_<module>.lua`
- `describe()` blocks named after the API namespace: `"luna.math"`, `"luna.graphics"`
- `it()` blocks use natural language: `"should return zero for empty input"`

---

## Float Comparison Rules

**NEVER use `assert_eq!` on `f32` or `f64` values.** Floating-point arithmetic produces representation errors.

### Rust

```rust
// CORRECT
assert!((result - expected).abs() < 1e-5);

// ALSO CORRECT — helper macro
macro_rules! assert_float_eq {
    ($a:expr, $b:expr) => {
        assert!(($a - $b).abs() < 1e-5, "Expected {} ≈ {}", $a, $b);
    };
}

// WRONG — will fail with representation errors
assert_eq!(result, expected);
```

### Lua

```lua
-- CORRECT
expect_near(expected, actual, 0.001)

-- WRONG
expect_equal(1.0, some_float_calc())
```

Default tolerance for `expect_near` is `1e-5` if the third argument is omitted.

---

## Test Constraints

These constraints are **mandatory** and enforced by CI:

| Constraint | Rationale |
|---|---|
| Tests must NOT create a window | CI runners have no display server |
| Tests must NOT use the GPU | CI runners may lack GPU devices |
| Tests must NOT play audio | CI runners may lack audio devices |
| Tests must NOT write outside `build/` | Prevent pollution of working tree |
| Tests must NOT use network I/O | Tests must be reproducible offline |
| New `luna.*` API functions require ≥1 Lua test | Prevent untested API surface growth |
| Bug fixes require a regression test first | Red → green → refactor cycle |
| Every Lua test file ends with `test_summary()` | Framework validation gate |

---

## Adding a New Rust Test

### For an existing module

Add `#[test]` functions to the existing `tests/unit/<module>_tests.rs` file.

### For a new module

1. Create `tests/unit/<module>_tests.rs`
2. Register it in `Cargo.toml`:
   ```toml
   [[test]]
   name = "<module>_tests"
   path = "tests/unit/<module>_tests.rs"
   ```
3. Add imports: `use luna2d::<module>::TypeName;`
4. Write tests following the naming convention
5. Run: `cargo test --test <module>_tests`

---

## Adding a New Lua Test

1. Create `tests/lua/unit/test_<module>.lua` using the template above
2. End the file with `test_summary()`
3. Add a dispatch entry in `tests/lua/harness.rs`:
   ```rust
   #[test]
   fn lua_test_<module>() { run_lua_test("unit/test_<module>.lua"); }
   ```
4. Run: `cargo test lua_test_<module>`

---

## Running Tests

### During Development (scoped — fast)

```powershell
# Type-check only — no compilation, ~2-5s incremental
cargo check

# Test one Rust module
cargo test --test math_tests -- --nocapture

# Test one Lua module
cargo test lua_test_math -- --nocapture

# Lint library only
cargo clippy --lib
```

### Final Gate (full — before commit)

```powershell
cargo test && cargo clippy -- -D warnings
```

### Diagnostic Commands

| What | Command |
|---|---|
| Type-check only | `cargo check` |
| One Rust test suite | `cargo test --test <name>` |
| One Lua test suite | `cargo test lua_test_<module>` |
| See stdout from tests | `cargo test --test <name> -- --nocapture` |
| Debug logging in tests | `$env:RUST_LOG = "debug"; cargo test --test <name> -- --nocapture` |
| Lint library only | `cargo clippy --lib` |
| All tests | `cargo test` |
| Pretty format | `cargo test -- --format pretty` |

**Key rule**: Never run `cargo test` (full) during development. Use scoped `--test <name>` commands. Full suite runs only at commit time.

---

## Quality Gates

Every commit must pass all of these:

| Gate | Command | Must Exit |
|---|---|---|
| All tests pass | `cargo test` | 0 |
| No clippy warnings | `cargo clippy -- -D warnings` | 0 |
| Format check | `cargo fmt --check` | 0 |
| Doc coverage | `python tools/collect_docs.py --report-missing` | 0 |

---

## Test Coverage Tooling

| Tool | Purpose | Output |
|---|---|---|
| `python tools/test_coverage.py` | Test coverage analytics | `docs/logs/test_coverage.json` |
| `python tools/test_coverage.py --suggest` | Generate stubs for uncovered items | stdout |
| `python tools/module_audit.py` | Full module audit (includes test status) | stdout |
| `python tools/audit_module.py <name>` | Single module quality audit | PASS/WARN/ERROR |

---

## Test-Driven Development Workflow

### Rust (Red → Green → Refactor)

1. **Red**: Write a failing test in `tests/unit/<module>_tests.rs` that names the expected behaviour
2. **Run**: `cargo test --test <module>_tests` — confirm it fails with the expected error
3. **Green**: Implement the minimum code in `src/<module>/` to make it pass
4. **Refactor**: Clean up, keeping tests green
5. **Gate**: `cargo clippy --lib` — fix any warnings

### Lua (Describe → Script → Run)

1. **Describe**: Write a `test_<module>.lua` file with `describe`/`it`/`expect_*` blocks
2. **Script**: Write a `main.lua` in `examples/` that exercises the new API
3. **Run**: `cargo test lua_test_<module>` — confirm failures
4. **Implement**: Add the Lua binding in `src/lua_api/`
5. **Verify**: Re-run both the test and the example

### Bug Fix Workflow

1. **Reproduce**: Write a test that triggers the bug
2. **Confirm red**: Run the test, verify it fails
3. **Fix**: Apply the minimal fix
4. **Confirm green**: Run the test, verify it passes
5. **Regression**: The test stays in the suite permanently

---

## Problem Areas and Known Issues

These are documented issues in the test suite that should be addressed over time:

| Issue | Description | Impact |
|---|---|---|
| Legacy flat test files | Some old `tests/*.rs` files may exist from before the `unit/ext/game/stress` restructuring | Low — they compile but may be stale |
| Framework consistency | A few Lua test files define local helpers instead of using global `init.lua` | Low — tests pass, but framework is duplicated |
| Missing `test_summary()` | Some older Lua test files may lack the mandatory `test_summary()` call | Medium — framework can't report totals |
| Unregistered test files | `.rs` files in `tests/` not listed in `Cargo.toml` are silently ignored | Medium — tests exist but never run |
| Coverage gaps | Some `luna.*` API functions have Rust tests but no Lua tests | Medium — API surface not fully verified from user perspective |
