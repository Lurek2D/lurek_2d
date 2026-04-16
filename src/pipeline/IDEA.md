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
