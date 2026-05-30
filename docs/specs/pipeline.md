# pipeline

## TL;DR

- The `pipeline` module is an Edge/Integration tier component that provides a robust Directed Acyclic Graph (DAG) workflow orchestration engine for Lurek2D.

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

- `lurek.pipeline.fromTable`: Creates a pipeline pre-populated with steps from a declarative table definition. Each step entry can specify name, deps, delay, optional, retryCount, retryDelay, async, tag, and fn.
- `lurek.pipeline.newPipeline`: Creates a new empty pipeline with an optional name. Add steps via addStep() or addConditional().
- `lurek.pipeline.newStep`: Creates a new pipeline step with the given name and an optional callback function.

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

- `LPipeline:addBranch`: Adds a branching construct: evaluates a predicate, then runs either the "then" or "else" callback based on the result.
- `LPipeline:addConditional`: Convenience method to create and add a step with dependencies and a condition in one call.
- `LPipeline:addStep`: Adds an existing step object to this pipeline. The step will be scheduled according to its declared dependencies.
- `LPipeline:addSubPipeline`: Embeds another pipeline's steps into this pipeline under an alias prefix, with optional outer dependencies.
- `LPipeline:cancel`: Cancels all pending and waiting steps. Steps already running or completed are unaffected.
- `LPipeline:clear`: Removes all steps from the pipeline, resetting it to an empty state.
- `LPipeline:getContext`: Returns the shared context table used by the current or most recent pipeline execution, or nil if none exists.
- `LPipeline:getErrorMode`: Returns the current error mode of the pipeline as a string.
- `LPipeline:getExecutionOrder`: Computes the topologically sorted execution order of all steps, respecting dependencies.
- `LPipeline:getName`: Returns the name of this pipeline. This method is available to Lua scripts.
- `LPipeline:getParallelGroups`: Groups steps into parallel execution tiers. Steps within the same group have no mutual dependencies and can run concurrently.
- `LPipeline:getResult`: Returns the current pipeline result summary table, or nil if no steps exist. Useful for inspecting state after run or during async execution.
- `LPipeline:getStep`: Retrieves a step object by name, or nil if no step with that name exists in this pipeline.
- `LPipeline:getStepCount`: Returns the total number of steps in this pipeline.
- `LPipeline:getSteps`: Returns a table containing all step objects currently in this pipeline.
- `LPipeline:getStepsByTag`: Returns all steps that have the specified tag assigned.
- `LPipeline:isComplete`: Returns whether all steps have reached a terminal state (completed, failed, skipped, or cancelled).
- `LPipeline:isRunning`: Returns whether the pipeline is currently in async execution mode (started via runAsync and not yet finished).
- `LPipeline:onEvent`: Registers a low-level event callback for all pipeline lifecycle events. Receives (eventName, stepName, status, detail).
- `LPipeline:onProgress`: Registers a progress callback invoked after each step finishes (regardless of outcome). Receives (stepName, statusString).
- `LPipeline:removeStep`: Removes a step from the pipeline by name. Any other steps that depend on it may fail or be skipped.
- `LPipeline:reset`: Resets the pipeline and all steps back to their initial pending state, clearing context and async state.
- `LPipeline:run`: Executes all pipeline steps synchronously in dependency order. Blocks until all steps complete, fail, or are cancelled.
- `LPipeline:runAsync`: Starts asynchronous (coroutine-based) execution of the pipeline. Call update(dt) each frame to advance steps.
- `LPipeline:setErrorMode`: Sets how the pipeline handles step failures. "abort" stops on first failure; "continue" runs remaining steps.
- `LPipeline:setName`: Changes the name of this pipeline. This method is available to Lua scripts.
- `LPipeline:setOnComplete`: Registers a callback invoked when the entire pipeline finishes execution. Receives the result table.
- `LPipeline:setOnStepComplete`: Registers a callback invoked each time any step completes successfully. Receives (stepName, context).
- `LPipeline:setOnStepError`: Registers a callback invoked each time any step fails. Receives (stepName, errorMessage).
- `LPipeline:toAscii`: Returns an ASCII art diagram of the pipeline's dependency graph for debugging and visualization.
- `LPipeline:toTable`: Serializes the pipeline configuration into a plain Lua table for inspection or persistence.
- `LPipeline:type`: Returns the type name of this object ("LPipeline").
- `LPipeline:typeOf`: Checks whether this object is of a given type name. Accepts "LPipeline", "Pipeline", or "Object".
- `LPipeline:update`: Advances an async pipeline by one frame tick. Resumes coroutines, checks dependencies, and fires callbacks. Call every frame after runAsync().
- `LPipeline:validate`: Validates the pipeline structure, checking for missing dependencies and circular references.

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

- `LPipelineStep:dependsOn`: Declares that this step depends on another step (by name or reference). The dependency must complete before this step runs.
- `LPipelineStep:getAttempt`: Returns the current attempt number (1-based). Increases with each retry.
- `LPipelineStep:getData`: Retrieves a metadata value previously stored with setData.
- `LPipelineStep:getDelay`: Returns the configured delay for this step.
- `LPipelineStep:getDependencies`: Returns a list of step names that this step depends on.
- `LPipelineStep:getDependencyCount`: Returns the number of dependencies this step has.
- `LPipelineStep:getDuration`: Returns how long this step took to execute in seconds (measured from start to completion or failure).
- `LPipelineStep:getError`: Returns the error message if this step failed, or nil if it has not failed.
- `LPipelineStep:getName`: Returns the unique name of this pipeline step.
- `LPipelineStep:getRetryCount`: Returns the configured retry count for this step.
- `LPipelineStep:getStatus`: Returns the current execution status of this step as a string ("pending", "waiting", "running", "completed", "failed", "skipped", "cancelled").
- `LPipelineStep:getTag`: Returns the tag assigned to this step, or nil if none is set.
- `LPipelineStep:getTimeout`: Returns the configured timeout for this step, or 0 if none is set.
- `LPipelineStep:isAsync`: Returns whether this step is configured for asynchronous coroutine execution.
- `LPipelineStep:isOptional`: Returns whether this step is marked as optional.
- `LPipelineStep:setAsync`: Marks this step as asynchronous. Async steps run as coroutines and can yield between frames.
- `LPipelineStep:setCallback`: Sets the main execution function for this step. Called when the step runs.
- `LPipelineStep:setCondition`: Sets a predicate function that determines whether this step should execute. If the predicate returns false, the step is skipped.
- `LPipelineStep:setData`: Stores a key-value metadata pair on this step. Useful for passing configuration between steps.
- `LPipelineStep:setDelay`: Sets a delay in seconds before this step begins execution after its dependencies are satisfied.
- `LPipelineStep:setOnError`: Sets an error handler callback invoked when this step fails after all retries are exhausted.
- `LPipelineStep:setOptional`: Marks this step as optional. Optional steps do not cause pipeline failure if they fail.
- `LPipelineStep:setRetryCount`: Sets how many times this step should be retried after a failure before being marked as failed.
- `LPipelineStep:setRetryDelay`: Sets the delay in seconds between retry attempts for this step.
- `LPipelineStep:setTag`: Assigns a tag string to this step for grouping and filtering purposes.
- `LPipelineStep:setTimeout`: Sets a maximum execution time for this step. If exceeded in async mode, the step may be considered failed.
- `LPipelineStep:type`: Returns the type name of this object ("LPipelineStep").
- `LPipelineStep:typeOf`: Checks whether this object is of a given type name. Accepts "LPipelineStep", "PipelineStep", or "Object".

#### LPipelineToTableResult Type

- Generated result shape from @field tags.

##### Fields

- `errorMode` (`string`): Error handling mode.
- `name` (`string`): Pipeline name.
- `steps` (`table`): Array of step tables.

##### Methods

- No documented methods.
