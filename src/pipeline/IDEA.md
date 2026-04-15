# IDEA.md — `pipeline` module

> Migrated from `ideas/features/pipeline.md`.
> Status checked against `src/pipeline/` and `src/lua_api/pipeline_api.rs`.
> Lua namespace: `lurek.pipeline`.

---

## Features

### 🤔 CONSIDER — Move to Lunasome Tier-3 Library
**Source**: features/pipeline.md — Structural Issues / Suggestions #1

The pipeline module has NO Rust-specific dependencies — it is a pure DAG orchestration
algorithm. A pure-Lua implementation in `content/library/pipeline/` would serve the same
use cases with less engine surface area. Requires Architect decision.

The ONLY justification for remaining as Rust: parallel stage execution via `lurek.thread`
workers. If this is not planned, migrate to Lunasome.

---

### ❌ TODO — Parallel Stage Execution
**Source**: features/pipeline.md — Feature Gaps #1 / Suggestions #6

No parallel execution of independent stages. All stages run sequentially even when multiple
independent stages exist. This is the strongest argument for keeping the module in Rust
(via `lurek.thread` workers). Without this, the module belongs in Lunasome.

---

### ✅ DONE — Conditional Stages
**Source**: features/pipeline.md — Feature Gaps #5 / Suggestions #2

`pipeline:addConditional(name, deps, fn, when_fn)` added to `pipeline_api.rs`. When `when_fn()`
returns false the step is skipped (status `Skipped`). Equivalent to `addStep` + `:setCondition`
but in one call. Handles debug-only stages, optional processing, and mod hooks.

---

### ❌ TODO — Async / Non-Blocking Stages
**Source**: features/pipeline.md — Feature Gaps #2

No async stages. All stage functions are synchronous Lua. Combining with `lurek.thread`
workers would unlock stages that wait for I/O without blocking.

---

### ❌ TODO — Pipeline Composition (Nested / Merge)
**Source**: features/pipeline.md — Feature Gaps #7

No pipeline nesting. Can't reuse a pipeline as a single stage in another pipeline.

---

### ✅ DONE — Progress Callbacks
**Source**: features/pipeline.md — Feature Gaps #8 / Suggestions #3

`pipeline:onProgress(fn)` added to `pipeline_api.rs`. The callback receives `(step_name, status)`
after every step, where `status` is a lowercase string (`"completed"`, `"failed"`, `"skipped"`).
Fired from `fire_step_callbacks` after both the Completed and Failed branches.

---

### ✅ DONE — ASCII Visualization (Debug)
**Source**: features/pipeline.md — Suggestions #4

`pipeline:toAscii()` added to `pipeline_api.rs`; calls `Pipeline::to_ascii_diagram()` in
`dag.rs`. Returns a multi-line string showing parallel execution levels, e.g.:
`L0: [init] || [setup]`
`L1: [load <-- init] || [validate <-- setup]`

---

### ❌ TODO — Documented Use Cases and Examples
**Source**: features/pipeline.md — Suggestions #5

No examples demonstrating real game use cases: asset loading pipeline, mod loading
order, game initialization order. Without examples, users won't discover the module.
