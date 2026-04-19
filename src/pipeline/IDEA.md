# IDEA — `src/pipeline/`

> **This file is forward-looking.** It records ideas, not commitments. Nothing here is
> implemented in the same session that produces it. Implementation is gated by a separate
> roadmap decision.

---

## 1. Header

- **Module**: `pipeline`
- **Owner module path**: `src/pipeline/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy** (per [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)):
  `TIER-2-PLUGIN`
- **LOC (rust only)**: `1316` · **Public Lua surface**: `lurek.pipeline` — `3` fns / `2` userdata (Pipeline, Step)
- **Inbound non-`lua_api` callers**: `none`
- **Heavy dependencies**: `none` (only `crate::runtime::log_messages`)

## 2. Mission Summary

The pipeline module provides a DAG-based workflow orchestrator for composing multi-step
sequences. It serves EngDev (build/boot pipelines), GameDev (quest chains, cinematic
sequences), and Modder (mod-loading dependency graphs). It is deliberately NOT an ECS
scheduler or a render pipeline — it orchestrates named Lua callback steps with declared
dependency ordering and error handling.

## 3. Existing Strengths

- Clean Kahn's-algorithm topological sort with cycle detection and actionable error messages (`dag.rs`).
- Sub-pipeline composition via `add_sub_pipeline` with name-prefixed merging — enables modular workflow definition.
- Flexible error handling at two levels: pipeline-global `ErrorMode` and per-step `ErrorPolicy` with retry support.
- Parallel-group computation (`get_parallel_groups`) enables future multi-thread dispatch without API changes.
- ASCII diagram visualisation (`to_ascii_diagram`) aids debugging complex pipelines from Lua.
- Rich Lua surface: 40+ methods covering creation, execution, introspection, and serialisation.

## 4. Gap List

1. **[P1][GAP]** `Parallel stage execution` — all stages run sequentially even when the DAG permits concurrency.
   - Why: CPU-heavy game-init and mod-loading pipelines block the main thread longer than necessary.
2. **[P1][GAP]** `Async / non-blocking stages` — no way to yield a stage back to the scheduler while waiting for I/O.
   - Why: stages that load assets or network data freeze the entire pipeline until completion.
3. **[P2][GAP]** `Conditional branching` — no runtime if/else within the DAG beyond the `addConditional` skip guard.
   - Why: quest-chain and dialogue-tree pipelines need data-dependent forking.

## 5. Feature Ideas

1. **[P1][FEAT]** `Thread-pool parallel dispatch` — execute independent groups via `lurek.thread` workers.
   - Rationale: the strongest justification for keeping pipeline in Rust rather than pure Lua. Parallel groups are already computed; dispatch is the missing piece.
   - Effort: M · Risk: med (cross-VM callback serialisation).
   - Competitor inspiration: Bevy `SystemSet` parallel scheduling — https://bevyengine.org/learn/book/next-steps/system-scheduling/
2. **[P2][FEAT]** `Coroutine-based async stages` — allow stages to `coroutine.yield()` and resume next frame.
   - Rationale: enables non-blocking asset loads and network fetches within a pipeline without threading complexity.
   - Effort: M · Risk: low.
   - Competitor inspiration: Defold uses Lua coroutines for async game-object lifecycle — https://defold.com/manuals/script/
3. **[P3][FEAT]** `Pipeline event hooks` — emit `lurek.event` signals on stage start/complete/fail for decoupled observers.
   - Rationale: analytics and debug overlays can monitor pipeline progress without callback coupling.
   - Effort: S · Risk: low.

## 6. Performance / Reliability / Quality Ideas

- **[P3][PERF]** `Reduce String cloning in topo sort` — `get_execution_order` and `get_parallel_groups` clone step names into new Vecs. For large pipelines (50+ steps), use borrowed `&str` slices and return owned only at the boundary.
  - Hot path: `dag.rs:210-280`.
  - Verification: criterion bench with 100-step pipeline.
- **[P2][QUAL]** `Consider Lunasome migration` — if parallel dispatch is NOT planned, the module has zero Rust-specific dependencies and could be a pure-Lua library under `content/library/pipeline/`. Requires Architect decision.
  - File / type: entire module.
  - Reason: reduced engine surface area, easier community contribution.

## 7. Test Coverage Gaps

- **[P1][TEST-RUST]** Added inline Rust unit tests for `dag.rs`, `result.rs`, `scheduler.rs`, `step.rs` (this session).
- **[P2][TEST-LUA]** Expand Lua BDD tests for `lurek.pipeline.run` error-mode edge cases under `tests/lua/unit/test_pipeline.lua`.
- **[P2][TEST-LUA]** Add Lua test for `Pipeline:runAsync` + `Pipeline:update` multi-frame progression.
- **[P3][TEST-FUZZ]** Fuzz target candidate: `Pipeline::add_step` with random dep graphs (cycle / dup detection).

## 8. TODO(dedup): Cross-Module Overlap

```text
TODO(dedup): render::pipeline — "pipeline" naming collides with the GPU render pipeline concept in src/render/; clarify naming or namespace to avoid confusion
TODO(dedup): automation::Sequence — automation module has sequential-step execution that partially overlaps with pipeline's linear-chain use case
```

## 9. TODO(helper): Engine-Level Helper Candidates

```text
TODO(helper): pipeline_builder — declarative table-driven pipeline construction is already in fromTable but game authors still manually wire deps; a fluent builder helper in content/library/ would reduce boilerplate
```

## 10. TODO(plugin): Plugin Candidacy Proposal

```text
TODO(plugin): TIER-2-PLUGIN — pipeline has no Rust-specific dependencies beyond log_messages; it is a pure algorithm module. If parallel dispatch via lurek.thread is not implemented, the module could migrate to a pure-Lua Lunasome library under content/library/pipeline/. If parallel dispatch IS implemented, it should remain Rust but as a TIER-2-PLUGIN extractable behind a Cargo feature.
```

- **Extraction blockers**: only `crate::runtime::log_messages` import; no SharedState pool entries; no inbound callers outside lua_api.
- **Heavy dep impact if extracted**: n/a (no heavy deps).
- **Lua surface stability**: stable.
- **Migration step**: M2 (feature-gate the Cargo module, keep Lua API unchanged).

## 11. References

- Module spec: [docs/specs/pipeline.md](../../../docs/specs/pipeline.md)
- Lua API reference: [docs/API/lua-api.md#pipeline](../../../docs/API/lua-api.md)
- Philosophy constraints touched: `A-01` (no visual editor for pipeline design), `B-04` (LuaJIT VMs cannot share state — pipeline parallel dispatch must use Channel)
- Plugin doc tier table: [plugins.md §5](../../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: Bevy SystemSet, Defold coroutines
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
- Session plan: [PLAN.md](../../work/src-module-review-20260418/reports/PLAN.md) · Session decisions: [DECISIONS.md](../../work/src-module-review-20260418/reports/DECISIONS.md)
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

### ❌ TODO — Async / Non-Blocking Stages
**Source**: features/pipeline.md — Feature Gaps #2

No async stages. All stage functions are synchronous Lua. Combining with `lurek.thread`
workers would unlock stages that wait for I/O without blocking.

---
