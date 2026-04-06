# `pipeline` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `luna.pipeline` |
| **Source** | `src/pipeline/` |
| **Rust Tests** | `tests/unit/pipeline_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_pipeline.lua` |
| **Architecture** | — |

## Summary

The `pipeline` module provides a DAG-based pipeline orchestrator for composing multi-step
sequential and parallel workflows. It is a Tier 2 Engine Extension.

`Pipeline` holds a directed acyclic graph of `PipelineStep` nodes. Each step carries a name,
a list of upstream dependency names, and a callback reference. `PipelineScheduler` performs a
topological sort and drives execution: independent steps may run in parallel via Rust threads;
dependent steps wait for all predecessors to complete. `PipelineResult` accumulates per-step
status (Pending, Running, Ok, Err) and final output values.

The Lua binding (`luna.pipeline.*`) lets scripts define data-processing pipelines — e.g.
image transforms, batch asset loading, or multi-stage world generation — without manually
managing dependency ordering or thread synchronisation.

**Scope boundary**: `pipeline` is a pure orchestration module; it does not perform I/O,
rendering, or audio. Step implementations live in user Lua scripts or separate Rust modules.
It depends only on `crate::math` and `crate::engine`.
## Architecture

```
pipeline (module root)
  ├── dag.rs — DAG container for pipeline steps: topological sort, cycle detection, parallel grouping. Key types: `Pipeline`, `ErrorMode`. Primary functions: `add_step`, `validate`, `get_execution_order`, `get_parallel_groups`. Part of the `pipeline` Tier 2 subsystem.
  ├── result.rs — Pipeline execution result: `PipelineResult` and `PipelineStatus`. Key types: `PipelineResult`, `PipelineStatus`. Part of the `pipeline` Tier 2 subsystem.
  ├── scheduler.rs — Delay countdown and dispatch state for pipeline execution. Key types: `PipelineScheduler`. Primary functions: `start`, `update`, `mark_step_waiting`. Part of the `pipeline` Tier 2 subsystem.
  ├── step.rs — Pipeline step definition: `PipelineStep`, `StepStatus`, and `ErrorPolicy`. Key types: `PipelineStep`, `StepStatus`, `ErrorPolicy`. Part of the `pipeline` Tier 2 subsystem.
```

## Source Files

| File | Purpose |
|------|---------|
| `dag.rs` | DAG container for pipeline steps: topological sort, cycle detection, parallel grouping. Key types: `Pipeline`, `ErrorMode`. Primary functions: `add_step`, `validate`, `get_execution_order`, `get_parallel_groups`. Part of the `pipeline` Tier 2 subsystem. |
| `result.rs` | Pipeline execution result: `PipelineResult` and `PipelineStatus`. Key types: `PipelineResult`, `PipelineStatus`. Part of the `pipeline` Tier 2 subsystem. |
| `scheduler.rs` | Delay countdown and dispatch state for pipeline execution. Key types: `PipelineScheduler`. Primary functions: `start`, `update`, `mark_step_waiting`. Part of the `pipeline` Tier 2 subsystem. |
| `step.rs` | Pipeline step definition: `PipelineStep`, `StepStatus`, and `ErrorPolicy`. Key types: `PipelineStep`, `StepStatus`, `ErrorPolicy`. Part of the `pipeline` Tier 2 subsystem. |

## Submodules

### `pipeline::dag`

DAG container for pipeline steps: topological sort, cycle detection, parallel grouping. Key types: `Pipeline`, `ErrorMode`. Primary functions: `add_step`, `validate`, `get_execution_order`, `get_parallel_groups`. Part of the `pipeline` Tier 2 subsystem.

- **`Pipeline`** (struct): TODO: one-line description.
- **`ErrorMode`** (enum): TODO: one-line description.

### `pipeline::result`

Pipeline execution result: `PipelineResult` and `PipelineStatus`. Key types: `PipelineResult`, `PipelineStatus`. Part of the `pipeline` Tier 2 subsystem.

- **`PipelineResult`** (struct): TODO: one-line description.
- **`PipelineStatus`** (enum): TODO: one-line description.

### `pipeline::scheduler`

Delay countdown and dispatch state for pipeline execution. Key types: `PipelineScheduler`. Primary functions: `start`, `update`, `mark_step_waiting`. Part of the `pipeline` Tier 2 subsystem.

- **`PipelineScheduler`** (struct): TODO: one-line description.

### `pipeline::step`

Pipeline step definition: `PipelineStep`, `StepStatus`, and `ErrorPolicy`. Key types: `PipelineStep`, `StepStatus`, `ErrorPolicy`. Part of the `pipeline` Tier 2 subsystem.

- **`PipelineStep`** (struct): TODO: one-line description.
- **`StepStatus`** (enum): TODO: one-line description.
- **`ErrorPolicy`** (enum): TODO: one-line description.

## Key Types

### Structs

#### `pipeline::dag::Pipeline`

TODO: description from `///` doc comment.

#### `pipeline::result::PipelineResult`

TODO: description from `///` doc comment.

#### `pipeline::scheduler::PipelineScheduler`

TODO: description from `///` doc comment.

#### `pipeline::step::PipelineStep`

TODO: description from `///` doc comment.

### Enums

#### `pipeline::dag::ErrorMode`

TODO: description from `///` doc comment.

#### `pipeline::result::PipelineStatus`

TODO: description from `///` doc comment.

#### `pipeline::step::StepStatus`

TODO: description from `///` doc comment.

#### `pipeline::step::ErrorPolicy`

TODO: description from `///` doc comment.

## Lua API

Exposed under `luna.pipeline.*` by `src\lua_api\pipeline_api.rs`.

TODO: Describe the overall API surface. List the major categories of functions.

Exposed functions include: `pipeline`.

## Lua Examples

```lua
-- Example: Basic pipeline usage
function luna.load()
    -- TODO: replace with real pipeline setup
    local obj = luna.pipeline.pipeline()
end

function luna.update(dt)
    -- TODO: update logic
end
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 4 |
| `enum`   | 4 |
| `fn`     | 0 |
| **Total** | **8** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
