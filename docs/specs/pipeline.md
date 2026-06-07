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

This module provides a dependency-aware workflow orchestration system that manages execution flows as directed acyclic graphs. Rather than using rigid call sequences, work is modeled as distinct steps linked by explicit prerequisites. This dependency-oriented design ensures that complex tasks execute in a safe and logical order, keeping code modular and allowing developers to assemble dynamic workflows from scripts and data-driven configuration tables.

Before execution, the system validates the graph using topological sorting and cycle detection, automatically catching invalid or circular arrangements. It groups independent steps into concurrent bands so unrelated tasks can run in parallel without sacrificing safety. Callers can also fold smaller pipelines into larger ones using namespaced aliases, and output readable ASCII diagrams to visualize the entire dependency structure for easy debugging.

Individual steps carry granular configuration rules that govern their execution lifetime. Each task can define timing parameters such as pre-execution delays, timeouts, and automatic retry counts with separate intervals. Steps can also carry custom metadata, select optional or critical status, and evaluate predicate conditions dynamically. This lets pipelines skip unnecessary steps or recover from transient failures without aborting the entire sequence.

Finally, the module supports both synchronous blocking execution and frame-driven asynchronous scheduling. Asynchronous pipelines run as lightweight coroutines that yield control, advancing step by step via update ticks. Execution tracks chronological progress, recording step durations, retry attempts, and detailed errors. Developers can customize the error mode to either abort on first failure or continue executing unaffected tasks.

The runtime surface is feature-gated behind `pipeline`.

Integration note: overlap with `automation` remains intentionally limited to composition at a higher level. This module still owns dependency-graph orchestration, while automation sequences remain a separate concern rather than being merged into the pipeline contract.

Internal runtime note: hot-path dependency checks and async scheduler readiness now use borrowed step-name paths (`&str`) to reduce transient `String` cloning during per-frame updates. The public contract for parallel grouping and delayed-step readiness remains unchanged.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### dag.rs

- Dependency-ordered pipeline graph that models work as named steps linked by explicit prerequisites instead of implicit call ordering.
- The file gives the module its structural brain by storing step topology, validating references, and determining which work can safely happen before or beside other work.
- Topological sorting and cycle detection keep invalid orchestration from reaching runtime execution, which matters when workflows are composed dynamically from scripts or tools.
- Parallel grouping exposes natural concurrency boundaries without abandoning dependency correctness, letting unrelated branches advance together when the graph permits it.
- Sub-pipeline merging makes larger workflows composable by folding one graph into another under namespaced identities and inherited outer dependencies.
- ASCII visualization and execution-order queries turn the graph into something inspectable, not just executable, which is important for debugging author intent.
- Functionally this file delivers the orchestration map that every pipeline run relies on to know what can start, what must wait, and how the whole workflow hangs together.

### mod.rs

- Workflow orchestration module for building dependency-aware task graphs, advancing them over time, and collecting explicit run outcomes.
- It ties together graph structure, per-step policy, frame-driven scheduling, and result reporting into one coherent surface for asynchronous or staged work.
- Functionally this file is the high-level entry point for pipeline execution, dependency management, retry-aware progress, and summarized completion state.

### result.rs

- Pipeline outcome model for turning many individual step endings into one readable picture of how a workflow actually finished.
- The file records lifecycle state, per-step timing, errors, and completion data so callers can inspect success, failure, skips, and duration after a run.
- Convenience queries keep common result questions cheap and direct instead of forcing every user to re-interpret raw status fields.
- Functionally this delivers the post-run memory and reporting surface for pipeline execution.

### scheduler.rs

- Frame-driven scheduler for pipeline steps whose readiness depends on elapsed time as well as graph dependencies.
- The file counts down configured delays, tracks overall runtime progress, and reports which waiting steps are now allowed to begin.
- Waiting membership is tracked explicitly in scheduler-owned timers, so async readiness does not depend on mutating pipeline definition structs at runtime.
- Keeping this timing logic separate from the graph keeps execution pacing explicit without diluting structural dependency rules.
- Functionally this delivers the temporal gatekeeper for delayed and frame-advanced pipeline work.

### step.rs

- Pipeline step model for expressing one unit of work together with the policy that controls when and how it should run.
- The file combines identity, dependencies, delays, retries, timeout-like settings, metadata, and callback hooks into a single authored execution record.
- Status tracking gives each step a visible lifecycle from pending through terminal outcomes, which keeps orchestration state legible during async progress.
- Error policy at step level lets important and optional work coexist inside the same pipeline without flattening all failures into one rule.
- Functionally this file delivers the configurable work atom from which larger dependency graphs are assembled.

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
