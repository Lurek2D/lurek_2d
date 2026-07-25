# RFC: Optional Module Packaging

- Status: Proposed
- Owner: runtime and build maintainers
- Canonical current boundary: [Modularity And Plugins](../modularity-plugins.md)

## Goal

Measure whether optional compile-time module packaging can reduce selected builds without fragmenting registration, state ownership, testing, or support.

## Proposed Work

1. Generate a dependency/coupling report from the current module registry and Rust graph.
2. Select one low-coupling proof module and define its absent-surface behavior.
3. Prototype Cargo feature gating while keeping the default all-in binary.
4. Add CI/test matrix coverage and reproducible size measurements.
5. Evaluate dynamic loading only after compile-time boundaries are proven.

## Acceptance Gates

- Runtime and `SharedState` build cleanly with the proof module disabled.
- Lua registration is deterministic and missing optional APIs have documented behavior.
- Default builds remain backward compatible.
- Tests cover enabled and disabled configurations.
- Size/compile-time gains are measured on controlled hosts.
- The all-in binary remains a one-step rollback.

## Retirement

Delete this RFC after acceptance is incorporated into current architecture or after rejection. Unmeasured size targets and unimplemented ABI promises must not survive as system facts.
