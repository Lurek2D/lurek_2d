# pipeline

## TL;DR

- Orchestrates steps using validated dependency graphs.
- Supports parallel groups, branch conditions, delays, and retries.
- Runs synchronously or asynchronously with step reports.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/pipeline/`
- Binding: `src/lua_api/pipeline_api.rs`
- Namespace: `lurek.pipeline`
- Lua API surface: `3` functions, `5` types, `63` methods
- Rust test path(s): tests/rust/unit/pipeline_tests.rs
- Lua test path(s): tests/lua/unit/test_pipeline_core_unit.lua

## Summary

- The `pipeline` module is the engine's workflow-orchestration surface for users who want multi-step processing to behave like explicit directed workflows instead of loosely nested call sequences.
- Its core value is that staged work becomes data. Steps, dependencies, scheduler policy, inputs, outputs, and result handling can be represented and advanced as pipeline state rather than hidden inside bespoke control flow.
- DAG structure matters because many real workflows are dependency-aware rather than purely linear: some work can run only after prerequisites complete, while other work may branch, fan out, or proceed in parallel.
- That makes the module useful for asset processing, validation chains, analytics jobs, build-like tasks, scripted tool workflows, content transforms, and other domains where several operations must be coordinated explicitly.
- Scheduler logic is important because a pipeline must decide when steps are eligible, blocked, complete, retried, or failed instead of merely storing a list of actions.
- Result handling matters for the same reason. Multi-step workflows usually need explicit output capture, pass-through state, intermediate artifacts, and error-aware progression rather than simple immediate returns.
- Tool-facing workflows benefit when those stages stay inspectable instead of becoming a black box.
- The module therefore gives users a stable vocabulary for reasoning about staged work, dependency flow, and execution state instead of accidental nested control structure.
- Read `pipeline` as the engine feature for explicit staged workflows with clear execution semantics.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### dag.rs

- `src/pipeline/dag.rs` owns the dependency graph that stores steps, validates references, and computes run order.
- It defines `ErrorMode` and `Pipeline`, keeping registration, dependency checks, cycle detection, and queries together.
- Topological ordering and parallel-group discovery live here, so structural execution rules stay separate from timing.
- This file resolves dependency satisfaction, sub-pipeline merging, reset behavior, and final result collection logic.
- ASCII diagram rendering also lives here, making graph inspection and tooling-friendly pipeline introspection explicit.
- It is the structural boundary for workflow orchestration; step metadata, timers, and result summaries depend on it.
- Read this file when dependency semantics, cycle handling, merge behavior, or execution-order rules must change.

### mod.rs

- `src/pipeline/mod.rs` is the module index that exposes graph structure, step contracts, scheduling, and run results.
- It reexports `Pipeline`, `ErrorMode`, `PipelineStep`, `StepStatus`, `PipelineScheduler`, and result types together.
- No live pipeline graph or timers live here; this file only declares child modules and defines public visibility.
- Read this index when wiring workflows, because it shows where structure, timing, step policy, and outcomes split.
- Changes here reshape the pipeline boundary, since reexports decide which orchestration tools other systems import.
- This module keeps dependency graphs, step schemas, scheduler timers, and outcome reporting separated by responsibility.

### result.rs

- `src/pipeline/result.rs` owns the aggregated outcome model used to summarize how a pipeline run finished overall.
- It defines `PipelineStatus` and `PipelineResult`, keeping final lifecycle state, per-step buckets, and errors together.
- Success checks and summary formatting also live here, so caller-facing run interpretation stays out of graph code.
- Read this file when result-state semantics, summary text, or outcome aggregation behavior for completed runs changes.

### scheduler.rs

- `src/pipeline/scheduler.rs` owns frame-driven delay timers that decide when waiting pipeline steps become ready to run.
- `PipelineScheduler` tracks elapsed time, running state, and per-step countdowns without duplicating graph rules.
- Waiting-step synchronization and ready-step reporting live here, keeping pacing policy distinct from validation.
- This file keeps timer state separate from pipeline definitions, which preserves cleaner orchestration data.
- Read this file when delay countdowns, readiness emission, or scheduler reset behavior for pipeline execution changes.

### step.rs

- `src/pipeline/step.rs` owns the schema for one pipeline step, including lifecycle state and per-step failure policy.
- It defines `StepStatus`, `ErrorPolicy`, and `PipelineStep`, keeping authored work-unit metadata under one owner.
- Dependency names, delays, retry settings, optionality, tags, metadata, and runtime status fields all live in this file.
- Read it when step contract fields, status vocabulary, reset behavior, or per-step error handling semantics need changes.
- This file is the step-schema boundary for pipelines, while graph structure and delay scheduling stay in sibling files.



## Lua API Ref

### Functions

- `lurek.pipeline.fromTable(definition) -> LPipeline`: Creates a pipeline pre-populated with steps from a declarative table definition. Each step entry can specify name, deps, delay, optional, retryCount, retryDelay, async, tag, and fn.
- `lurek.pipeline.newPipeline(name?) -> LPipeline`: Creates a new empty pipeline with an optional name. Add steps via addStep() or addConditional().
- `lurek.pipeline.newStep(name, callback?) -> LPipelineStep`: Creates a new pipeline step with the given name and an optional callback function.

### Callbacks

- `LPipeline:addBranch` param `elseFn` (`function?`): Callback executed if the predicate returns false. Defaults to a no-op.
- `LPipeline:addBranch` param `thenFn` (`function`): Callback executed if the predicate returns true.
- `LPipeline:addBranch` param `when` (`function`): Predicate function receiving context; returns true for the "then" path.
- `LPipeline:addConditional` param `callback` (`function`): The step callback function.
- `LPipeline:addConditional` param `condition` (`function`): Predicate function; step runs only if it returns true.
- `LPipeline:onEvent` param `callback` (`function`): A function receiving (eventName, stepName, status, detail).
- `LPipeline:onProgress` param `callback` (`function`): A function receiving (stepName, status).
- `LPipeline:setOnComplete` param `callback` (`function?`): A function receiving the result table. Pass nil to remove.
- `LPipeline:setOnStepComplete` param `callback` (`function?`): A function receiving (stepName, context). Pass nil to remove.
- `LPipeline:setOnStepError` param `callback` (`function?`): A function receiving (stepName, errorMessage). Pass nil to remove.
- `LPipelineStep:setCallback` param `callback` (`function`): A function receiving the pipeline context table and optionally returning a result value.
- `LPipelineStep:setCondition` param `condition` (`function?`): A function receiving the context table and returning a boolean. Pass nil to remove the condition.
- `LPipelineStep:setOnError` param `callback` (`function?`): A function receiving (stepName, errorMessage). Pass nil to remove.
- `lurek.pipeline.newStep` param `callback` (`function?`): Optional callback executed when this step runs.

### Enums

- No documented module-level enums/constants.

### Types

#### LPipeline Type

- A full pipeline that orchestrates multiple steps with dependency resolution, error modes, and async scheduling.

##### Fields

- No documented fields.

##### Methods

- `LPipeline:addBranch(name, deps, when, thenFn, elseFn?) -> LPipeline`: Adds a branching construct: evaluates a predicate, then runs either the "then" or "else" callback based on the result.
- `LPipeline:addConditional(name, deps, callback, condition) -> LPipeline`: Convenience method to create and add a step with dependencies and a condition in one call.
- `LPipeline:addStep(step) -> LPipeline`: Adds an existing step object to this pipeline. The step will be scheduled according to its declared dependencies.
- `LPipeline:addSubPipeline(subPipeline, alias, deps?) -> nil`: Embeds another pipeline's steps into this pipeline under an alias prefix, with optional outer dependencies.
- `LPipeline:cancel() -> nil`: Cancels all pending and waiting steps. Steps already running or completed are unaffected.
- `LPipeline:clear() -> nil`: Removes all steps from the pipeline, resetting it to an empty state.
- `LPipeline:getContext() -> table`: Returns the shared context table used by the current or most recent pipeline execution, or nil if none exists.
- `LPipeline:getErrorMode() -> string`: Returns the current error mode of the pipeline as a string.
- `LPipeline:getExecutionOrder() -> string[]`: Computes the topologically sorted execution order of all steps, respecting dependencies.
- `LPipeline:getName() -> string`: Returns the name of this pipeline. This method is available to Lua scripts.
- `LPipeline:getParallelGroups() -> string[]`: Groups steps into parallel execution tiers. Steps within the same group have no mutual dependencies and can run concurrently.
- `LPipeline:getResult() -> table`: Returns the current pipeline result summary table, or nil if no steps exist. Useful for inspecting state after run or during async execution.
- `LPipeline:getStep(name) -> LPipelineStep`: Retrieves a step object by name, or nil if no step with that name exists in this pipeline.
- `LPipeline:getStepCount() -> integer`: Returns the total number of steps in this pipeline.
- `LPipeline:getSteps() -> LPipelineStep[]`: Returns a table containing all step objects currently in this pipeline.
- `LPipeline:getStepsByTag(tag) -> LPipelineStep[]`: Returns all steps that have the specified tag assigned.
- `LPipeline:isComplete() -> boolean`: Returns whether all steps have reached a terminal state (completed, failed, skipped, or cancelled).
- `LPipeline:isRunning() -> boolean`: Returns whether the pipeline is currently in async execution mode (started via runAsync and not yet finished).
- `LPipeline:onEvent(callback) -> nil`: Registers a low-level event callback for all pipeline lifecycle events. Receives (eventName, stepName, status, detail).
- `LPipeline:onProgress(callback) -> nil`: Registers a progress callback invoked after each step finishes (regardless of outcome). Receives (stepName, statusString).
- `LPipeline:removeStep(name) -> nil`: Removes a step from the pipeline by name. Any other steps that depend on it may fail or be skipped.
- `LPipeline:reset() -> nil`: Resets the pipeline and all steps back to their initial pending state, clearing context and async state.
- `LPipeline:run(context?) -> table`: Executes all pipeline steps synchronously in dependency order. Blocks until all steps complete, fail, or are cancelled.
- `LPipeline:runAsync(context?) -> nil`: Starts asynchronous (coroutine-based) execution of the pipeline. Call update(dt) each frame to advance steps.
- `LPipeline:setErrorMode(mode) -> nil`: Sets how the pipeline handles step failures. "abort" stops on first failure; "continue" runs remaining steps.
- `LPipeline:setName(name) -> nil`: Changes the name of this pipeline. This method is available to Lua scripts.
- `LPipeline:setOnComplete(callback?) -> nil`: Registers a callback invoked when the entire pipeline finishes execution. Receives the result table.
- `LPipeline:setOnStepComplete(callback?) -> nil`: Registers a callback invoked each time any step completes successfully. Receives (stepName, context).
- `LPipeline:setOnStepError(callback?) -> nil`: Registers a callback invoked each time any step fails. Receives (stepName, errorMessage).
- `LPipeline:toAscii() -> string`: Returns an ASCII art diagram of the pipeline's dependency graph for debugging and visualization.
- `LPipeline:toTable() -> table`: Serializes the pipeline configuration into a plain Lua table for inspection or persistence.
- `LPipeline:type() -> string`: Returns the type name of this object ("LPipeline").
- `LPipeline:typeOf(name) -> boolean`: Checks whether this object is of a given type name. Accepts "LPipeline", "Pipeline", or "Object".
- `LPipeline:update(dt) -> boolean`: Advances an async pipeline by one frame tick. Resumes coroutines, checks dependencies, and fires callbacks. Call every frame after runAsync().
- `LPipeline:validate() -> boolean`: Validates the pipeline structure, checking for missing dependencies and circular references.

#### LPipelineGetResultResult Type

- Generated result shape from @field tags.

##### Fields

- `cancelled` (`string[]`): Cancelled step names.
- `completed` (`string[]`): Completed step names.
- `errors` (`table`): Array of error entries.
- `failed` (`string[]`): Failed step names.
- `skipped` (`string[]`): Skipped step names.
- `success` (`boolean`): Success flag.
- `totalDuration` (`number`): Total duration in seconds.

##### Methods

- No documented methods.

#### LPipelineRunResult Type

- Generated result shape from @field tags.

##### Fields

- `cancelled` (`string[]`): Cancelled step names.
- `completed` (`string[]`): Completed step names.
- `errors` (`table`): Array of error entries.
- `failed` (`string[]`): Failed step names.
- `skipped` (`string[]`): Skipped step names.
- `success` (`boolean`): Success flag.
- `totalDuration` (`number`): Total duration in seconds.

##### Methods

- No documented methods.

#### LPipelineStep Type

- A single executable step within a pipeline, wrapping callback, condition, retry, and error hooks.

##### Fields

- No documented fields.

##### Methods

- `LPipelineStep:dependsOn(dep) -> LPipelineStep`: Declares that this step depends on another step (by name or reference). The dependency must complete before this step runs.
- `LPipelineStep:getAttempt() -> integer`: Returns the current attempt number (1-based). Increases with each retry.
- `LPipelineStep:getData(key) -> string`: Retrieves a metadata value previously stored with setData.
- `LPipelineStep:getDelay() -> number`: Returns the configured delay for this step.
- `LPipelineStep:getDependencies() -> string[]`: Returns a list of step names that this step depends on.
- `LPipelineStep:getDependencyCount() -> integer`: Returns the number of dependencies this step has.
- `LPipelineStep:getDuration() -> number`: Returns how long this step took to execute in seconds (measured from start to completion or failure).
- `LPipelineStep:getError() -> string`: Returns the error message if this step failed, or nil if it has not failed.
- `LPipelineStep:getName() -> string`: Returns the unique name of this pipeline step.
- `LPipelineStep:getRetryCount() -> integer`: Returns the configured retry count for this step.
- `LPipelineStep:getStatus() -> string`: Returns the current execution status of this step as a string ("pending", "waiting", "running", "completed", "failed", "skipped", "cancelled").
- `LPipelineStep:getTag() -> string`: Returns the tag assigned to this step, or nil if none is set.
- `LPipelineStep:getTimeout() -> number`: Returns the configured timeout for this step, or 0 if none is set.
- `LPipelineStep:isAsync() -> boolean`: Returns whether this step is configured for asynchronous coroutine execution.
- `LPipelineStep:isOptional() -> boolean`: Returns whether this step is marked as optional.
- `LPipelineStep:setAsync(enabled) -> nil`: Marks this step as asynchronous. Async steps run as coroutines and can yield between frames.
- `LPipelineStep:setCallback(callback) -> nil`: Sets the main execution function for this step. Called when the step runs.
- `LPipelineStep:setCondition(condition?) -> nil`: Sets a predicate function that determines whether this step should execute. If the predicate returns false, the step is skipped.
- `LPipelineStep:setData(key, value) -> nil`: Stores a key-value metadata pair on this step. Useful for passing configuration between steps.
- `LPipelineStep:setDelay(seconds) -> nil`: Sets a delay in seconds before this step begins execution after its dependencies are satisfied.
- `LPipelineStep:setOnError(callback?) -> nil`: Sets an error handler callback invoked when this step fails after all retries are exhausted.
- `LPipelineStep:setOptional(optional) -> nil`: Marks this step as optional. Optional steps do not cause pipeline failure if they fail.
- `LPipelineStep:setRetryCount(count) -> nil`: Sets how many times this step should be retried after a failure before being marked as failed.
- `LPipelineStep:setRetryDelay(seconds) -> nil`: Sets the delay in seconds between retry attempts for this step.
- `LPipelineStep:setTag(tag) -> nil`: Assigns a tag string to this step for grouping and filtering purposes.
- `LPipelineStep:setTimeout(seconds) -> nil`: Sets a maximum execution time for this step. If exceeded in async mode, the step may be considered failed.
- `LPipelineStep:type() -> string`: Returns the type name of this object ("LPipelineStep").
- `LPipelineStep:typeOf(name) -> boolean`: Checks whether this object is of a given type name. Accepts "LPipelineStep", "PipelineStep", or "Object".

#### LPipelineToTableResult Type

- Generated result shape from @field tags.

##### Fields

- `errorMode` (`string`): Error handling mode.
- `name` (`string`): Pipeline name.
- `steps` (`table`): Array of step tables.

##### Methods

- No documented methods.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
