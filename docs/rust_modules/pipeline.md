# pipeline

## General Info

- Module group: `Edge/Integration`
- Source path: `src/pipeline/`
- Binding: `src/lua_api/pipeline_api.rs`
- Namespace: `lurek.pipeline`
- Lua API surface: `3` functions, `5` types, `63` methods
- Rust test path(s): tests/rust/unit/pipeline_tests.rs
- Lua test path(s): tests/lua/unit/test_pipeline_core_unit.lua

## Summary

It is designed to sequence complex, multi-step operations—such as asset processing, test orchestration, analytics batching, or mod build workflows—by strictly enforcing dependency ordering. At the core of the module is the `Pipeline` struct, which stores named `PipelineStep`s and their dependencies. Using Kahn's algorithm, it performs topological sorting to determine the correct execution order and detects cycles before a workflow can run. It also groups independent steps into parallel execution tiers, allowing unrelated tasks to be scheduled concurrently.

Each `PipelineStep` is highly configurable, acting as a discrete unit of work. Steps support conditional execution (via run-if predicates), configurable delayed starts, and maximum timeout limits. To handle transient failures robustly, steps can be configured with automatic retries and custom retry-delay backoffs. A step's error policy (`ErrorMode`) can be explicitly set to either abort the entire pipeline upon failure or allow execution to continue (treating the failure as optional). Pipelines themselves can be nested, with `add_sub_pipeline` allowing complex workflows to be merged under namespace prefixes while automatically wiring outer dependencies into the sub-pipeline's entry points.

Execution of the pipeline is driven by the `PipelineScheduler`, a frame-driven async engine that tracks elapsed wall-clock time, manages countdown timers for delayed steps, and seamlessly handles step progression (from `Pending` to `Waiting`, `Running`, and finally `Completed`, `Failed`, or `Skipped`). The scheduler supports both synchronous blocking runs and asynchronous, coroutine-based execution that yields between frames, ensuring the game loop is never stalled by long-running background pipelines. Upon completion or cancellation, the module generates a detailed `PipelineResult` object, summarizing the outcomes, durations, and error messages for all steps. The entire workflow definition and execution API is cleanly exposed to Lua via the `lurek.pipeline.*` namespace, offering script developers a powerful tool for asynchronous task orchestration.

## Files

### [dag.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/dag.rs)

- Dependency-ordered pipeline graph that models work as named steps linked by explicit prerequisites instead of implicit call ordering.
- The file gives the module its structural brain by storing step topology, validating references, and determining which work can safely happen before or beside other work.
- Topological sorting and cycle detection keep invalid orchestration from reaching runtime execution, which matters when workflows are composed dynamically from scripts or tools.
- Parallel grouping exposes natural concurrency boundaries without abandoning dependency correctness, letting unrelated branches advance together when the graph permits it.
- Sub-pipeline merging makes larger workflows composable by folding one graph into another under namespaced identities and inherited outer dependencies.
- ASCII visualization and execution-order queries turn the graph into something inspectable, not just executable, which is important for debugging author intent.
- Functionally this file delivers the orchestration map that every pipeline run relies on to know what can start, what must wait, and how the whole workflow hangs together.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/mod.rs)

- Workflow orchestration module for building dependency-aware task graphs, advancing them over time, and collecting explicit run outcomes.
- It ties together graph structure, per-step policy, frame-driven scheduling, and result reporting into one coherent surface for asynchronous or staged work.
- Functionally this file is the high-level entry point for pipeline execution, dependency management, retry-aware progress, and summarized completion state.

### [result.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/result.rs)

- Pipeline outcome model for turning many individual step endings into one readable picture of how a workflow actually finished.
- The file records lifecycle state, per-step timing, errors, and completion data so callers can inspect success, failure, skips, and duration after a run.
- Convenience queries keep common result questions cheap and direct instead of forcing every user to re-interpret raw status fields.
- Functionally this delivers the post-run memory and reporting surface for pipeline execution.

### [scheduler.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/scheduler.rs)

- Frame-driven scheduler for pipeline steps whose readiness depends on elapsed time as well as graph dependencies.
- The file counts down configured delays, tracks overall runtime progress, and reports which waiting steps are now allowed to begin.
- Keeping this timing logic separate from the graph keeps execution pacing explicit without diluting structural dependency rules.
- Functionally this delivers the temporal gatekeeper for delayed and frame-advanced pipeline work.

### [step.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/step.rs)

- Pipeline step model for expressing one unit of work together with the policy that controls when and how it should run.
- The file combines identity, dependencies, delays, retries, timeout-like settings, metadata, and callback hooks into a single authored execution record.
- Status tracking gives each step a visible lifecycle from pending through terminal outcomes, which keeps orchestration state legible during async progress.
- Error policy at step level lets important and optional work coexist inside the same pipeline without flattening all failures into one rule.
- Functionally this file delivers the configurable work atom from which larger dependency graphs are assembled.
