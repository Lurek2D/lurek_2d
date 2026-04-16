# IDEA.md — `ecs` module

> Migrated from `ideas/features/entity.md` and `ideas/performance/18-entity-ecs-queries.md`.
> Status checked against `src/ecs/` and `src/lua_api/ecs_api.rs`.
> Lua API lives under `lurek.ecs` (Universe userdata).

---

## Features

### 🔇 LOW — Sparse Set / Archetype Iteration
**Source**: features/entity.md — Feature Gaps #8 / performance/18-entity-ecs-queries.md

Lua-table-oriented components mean no memory layout optimization. For the target audience
(indie / <10k entities) this is acceptable. If profiling reveals iteration as a bottleneck,
investigate archetype groups or sparse-set iteration. Do not optimize prematurely.
