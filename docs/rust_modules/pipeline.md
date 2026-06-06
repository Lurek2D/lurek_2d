# pipeline

## General Info

- Module group: `Edge/Integration`
- Source path: `src/pipeline/`
- Feature gate: `pipeline`
- Binding: `src/lua_api/pipeline_api.rs`
- Namespace: `lurek.pipeline`
- Lua API surface: `3` functions, `5` types, `63` methods
- Rust test path(s): tests/rust/unit/pipeline_tests.rs
- Lua test path(s): tests/lua/unit/test_pipeline_core_unit.lua

## Summary

This module provides a dependency-aware workflow orchestration system that manages execution flows as directed acyclic graphs. Rather than using rigid call sequences, work is modeled as distinct steps linked by explicit prerequisites. This dependency-oriented design ensures that complex tasks execute in a safe and logical order, keeping code modular and allowing developers to assemble dynamic workflows from scripts and data-driven configuration tables.

Before execution, the system validates the graph using topological sorting and cycle detection, automatically catching invalid or circular arrangements. It groups independent steps into concurrent bands so unrelated tasks can run in parallel without sacrificing safety. Callers can also fold smaller pipelines into larger ones using namespaced aliases, and output readable ASCII diagrams to visualize the entire dependency structure for easy debugging.

Individual steps carry granular configuration rules that govern their execution lifetime. Each task can define timing parameters such as pre-execution delays, timeouts, and automatic retry counts with separate intervals. Steps can also carry custom metadata, select optional or critical status, and evaluate predicate conditions dynamically. This lets pipelines skip unnecessary steps or recover from transient failures without aborting the entire sequence.

Finally, the module supports both synchronous blocking execution and frame-driven asynchronous scheduling. Asynchronous pipelines run as lightweight coroutines that yield control, advancing step by step via update ticks. Execution tracks chronological progress, recording step durations, retry attempts, and detailed errors. Developers can customize the error mode to either abort on first failure or continue executing unaffected tasks.

The runtime surface is feature-gated behind `pipeline`.

Integration note: overlap with `automation` remains intentionally limited to composition at a higher level. This module still owns dependency-graph orchestration, while automation sequences remain a separate concern rather than being merged into the pipeline contract.

Internal runtime note: hot-path dependency checks and async scheduler readiness now use borrowed step-name paths (`&str`) to reduce transient `String` cloning during per-frame updates. The public contract for parallel grouping and delayed-step readiness remains unchanged.

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
- The entry points are compiled only when the `pipeline` feature is enabled, matching the opt-in nature of the orchestration stack.
- Functionally this file is the high-level entry point for pipeline execution, dependency management, retry-aware progress, and summarized completion state.

### [result.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/result.rs)

- Pipeline outcome model for turning many individual step endings into one readable picture of how a workflow actually finished.
- The file records lifecycle state, per-step timing, errors, and completion data so callers can inspect success, failure, skips, and duration after a run.
- Convenience queries keep common result questions cheap and direct instead of forcing every user to re-interpret raw status fields.
- Functionally this delivers the post-run memory and reporting surface for pipeline execution.

### [scheduler.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/scheduler.rs)

- Frame-driven scheduler for pipeline steps whose readiness depends on elapsed time as well as graph dependencies.
- The file counts down configured delays, tracks overall runtime progress, and reports which waiting steps are now allowed to begin.
- Readiness reporting uses borrowed step-name references internally so async updates keep compatibility with existing scheduling semantics without cloning step identifiers each frame.
- Keeping this timing logic separate from the graph keeps execution pacing explicit without diluting structural dependency rules.
- Functionally this delivers the temporal gatekeeper for delayed and frame-advanced pipeline work.

### [step.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/pipeline/step.rs)

- Pipeline step model for expressing one unit of work together with the policy that controls when and how it should run.
- The file combines identity, dependencies, delays, retries, timeout-like settings, metadata, and callback hooks into a single authored execution record.
- Status tracking gives each step a visible lifecycle from pending through terminal outcomes, which keeps orchestration state legible during async progress.
- Error policy at step level lets important and optional work coexist inside the same pipeline without flattening all failures into one rule.
- Functionally this file delivers the configurable work atom from which larger dependency graphs are assembled.
