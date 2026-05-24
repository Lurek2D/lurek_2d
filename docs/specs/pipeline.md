# pipeline

## TL;DR

- The `pipeline` module is an Edge/Integration tier component that provides a robust Directed Acyclic Graph (DAG) workflow orchestration engine for Lurek2D.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/pipeline/`
- Lua API path(s): `src/lua_api/pipeline_api.rs`
- Primary Lua namespace: `lurek.pipeline`
- Rust test path(s): tests/rust/unit/pipeline_tests.rs
- Lua test path(s): tests/lua/unit/test_pipeline_core_unit.lua

## Summary

 It is designed to sequence complex, multi-step operations—such as asset processing, test orchestration, analytics batching, or mod build workflows—by strictly enforcing dependency ordering. At the core of the module is the `Pipeline` struct, which stores named `PipelineStep`s and their dependencies. Using Kahn's algorithm, it performs topological sorting to determine the correct execution order and detects cycles before a workflow can run. It also groups independent steps into parallel execution tiers, allowing unrelated tasks to be scheduled concurrently.

Each `PipelineStep` is highly configurable, acting as a discrete unit of work. Steps support conditional execution (via run-if predicates), configurable delayed starts, and maximum timeout limits. To handle transient failures robustly, steps can be configured with automatic retries and custom retry-delay backoffs. A step's error policy (`ErrorMode`) can be explicitly set to either abort the entire pipeline upon failure or allow execution to continue (treating the failure as optional). Pipelines themselves can be nested, with `add_sub_pipeline` allowing complex workflows to be merged under namespace prefixes while automatically wiring outer dependencies into the sub-pipeline's entry points.

Execution of the pipeline is driven by the `PipelineScheduler`, a frame-driven async engine that tracks elapsed wall-clock time, manages countdown timers for delayed steps, and seamlessly handles step progression (from `Pending` to `Waiting`, `Running`, and finally `Completed`, `Failed`, or `Skipped`). The scheduler supports both synchronous blocking runs and asynchronous, coroutine-based execution that yields between frames, ensuring the game loop is never stalled by long-running background pipelines. Upon completion or cancellation, the module generates a detailed `PipelineResult` object, summarizing the outcomes, durations, and error messages for all steps. The entire workflow definition and execution API is cleanly exposed to Lua via the `lurek.pipeline.*` namespace, offering script developers a powerful tool for asynchronous task orchestration.

## Source Documentation

### `dag.rs`
- DAG-based pipeline representing named steps with explicit dependency edges.
- Topological ordering via Kahn's algorithm with cycle detection.
- Parallel-level grouping for concurrent scheduling of independent steps.
- Sub-pipeline merging under a namespace prefix with outer dependency wiring.
- Validation of dependency references, execution-order queries, and ASCII diagram rendering.
- Result collection from final step statuses into a typed `PipelineResult`.

### `mod.rs`
- DAG-based pipeline for dependency-ordered step execution.
- Frame-driven scheduler ticks steps when delay timers expire.
- Per-step error policies with abort-on-failure or continue modes.
- Result types report completed, skipped, and failed steps after a run.

### `result.rs`
- Lifecycle status enum tracking pipeline progression from pending through completion or failure.
- Aggregated result struct collecting per-step outcomes, durations, and error messages.
- Convenience queries for success checks and human-readable summaries.

### `scheduler.rs`
- Frame-driven delay scheduler that counts down per-step timers each update.
- Report which pipeline steps become ready once their configured delay expires.
- Track wall-clock elapsed time and running state for the owning pipeline.

### `step.rs`
- Pipeline step definition: named unit of work with dependency, timing, and retry config.
- Execution lifecycle via `StepStatus` (pending → waiting → running → terminal).
- Per-step error policy overriding pipeline-level failure behavior.

## Types

- `ErrorMode` (`enum`, `dag.rs`): Pipeline-level policy for whether a failing step aborts the whole pipeline or allows execution to continue. It sets the graph-wide failure posture.
- `Pipeline` (`struct`, `dag.rs`): The top-level DAG container keyed by step name. It is the primary object to inspect when workflow validation, dependency ordering, or parallel grouping changes.
- `PipelineStatus` (`enum`, `result.rs`): Overall run-status enum for a full pipeline. It is the coarse-grained answer to whether the workflow is still running, completed, failed, or cancelled.
- `PipelineResult` (`struct`, `result.rs`): Structured summary of completed, failed, skipped, or cancelled work after execution. It is the main post-run artifact for tooling, diagnostics, and Lua-side introspection.
- `PipelineScheduler` (`struct`, `scheduler.rs`): Helper that tracks elapsed time and per-step delays to decide when steps become ready. It exists so delayed async execution does not have to be hand-managed elsewhere.
- `StepStatus` (`enum`, `step.rs`): Enum that represents the lifecycle of one step from pending through running to a terminal state. It is the status vocabulary shared by scheduling, execution, and results.
- `ErrorPolicy` (`enum`, `step.rs`): Step-level failure policy used when a single step needs behavior that differs from the pipeline default. It is the fine-grained override for retry or continue behavior.
- `PipelineStep` (`struct`, `step.rs`): One named node in a workflow with dependency, delay, retry, metadata, and runtime-status fields. It is the most important per-step contract in the module.

## Functions

- `ErrorMode::as_str` (`dag.rs`): Return the canonical lowercase string token for this mode.
- `ErrorMode::from_str_lua` (`dag.rs`): Parse a Lua-supplied string into `ErrorMode`; returns an error on unknown tokens.
- `Pipeline::new` (`dag.rs`): Create an empty pipeline with `ErrorMode::Abort`; logs `PL01_PIPELINE_INIT`.
- `Pipeline::add_step` (`dag.rs`): Register a step; return error if a step with the same name already exists.
- `Pipeline::remove_step` (`dag.rs`): Remove step by name and scrub it from all other steps' dependency lists; returns `false` if not found.
- `Pipeline::get_step` (`dag.rs`): Return a shared reference to a step by name, or `None` if absent.
- `Pipeline::get_step_mut` (`dag.rs`): Return a mutable reference to a step by name, or `None` if absent.
- `Pipeline::get_steps` (`dag.rs`): Return an iterator over all registered steps in unspecified order.
- `Pipeline::get_step_count` (`dag.rs`): Return the count of registered steps.
- `Pipeline::clear` (`dag.rs`): Remove all steps from the pipeline.
- `Pipeline::validate` (`dag.rs`): Validate dependency references and absence of cycles; return `(valid, error_list)`.
- `Pipeline::get_execution_order` (`dag.rs`): Return step names in topological order; return error string if a cycle is detected.
- `Pipeline::get_parallel_groups` (`dag.rs`): Return steps grouped into parallel levels where all steps in a group have no mutual dependencies.
- `Pipeline::reset` (`dag.rs`): Reset all step statuses to `Pending` without clearing step registrations.
- `Pipeline::are_deps_satisfied` (`dag.rs`): Return whether all dependencies of `step_name` have reached `Completed` or are optional-failed; returns error if step is unknown or a dep is still in-flight.
- `Pipeline::collect_result` (`dag.rs`): Build a `PipelineResult` from final step statuses and elapsed `duration` seconds.
- `Pipeline::to_ascii_diagram` (`dag.rs`): Render the pipeline as a multi-line ASCII diagram with parallel levels and dep arrows.
- `Pipeline::add_sub_pipeline` (`dag.rs`): Merge all steps from `sub` into this pipeline under a `alias/` prefix, wiring `outer_deps` to sub entry-points; returns error if any outer dep is missing.
- `PipelineResult::new` (`result.rs`): Create a blank result in `Pending` state with no recorded steps.
- `PipelineResult::is_success` (`result.rs`): Return `true` if no steps failed (skipped and cancelled do not count as failure).
- `PipelineResult::summary` (`result.rs`): Return a single-line human-readable summary of counts and duration.
- `PipelineScheduler::new` (`scheduler.rs`): Create a stopped scheduler with no active timers.
- `PipelineScheduler::start` (`scheduler.rs`): Initialize delay timers from `pipeline` step definitions and begin execution.
- `PipelineScheduler::update` (`scheduler.rs`): Advance timers by `dt` seconds and return names of steps whose delay has expired and are still `Waiting`.
- `PipelineScheduler::mark_step_waiting` (`scheduler.rs`): Reset and arm the delay timer for `name` using its configured delay from `pipeline`.
- `PipelineScheduler::reset` (`scheduler.rs`): Clear all timers and stop execution; does not reset step statuses in the pipeline.
- `StepStatus::as_str` (`step.rs`): Return the canonical lowercase token string for this status.
- `PipelineStep::new` (`step.rs`): Create a step with default settings: no deps, no delay, no retries, `ErrorPolicy::Abort`.
- `PipelineStep::reset` (`step.rs`): Reset runtime state to `Pending`; clears attempt count, duration, and error message.

## Lua API Reference

- Binding path(s): `src/lua_api/pipeline_api.rs`
- Namespace: `lurek.pipeline`

### Module Functions
- `lurek.pipeline.newStep`: Creates a new pipeline step with the given name and an optional callback function.
- `lurek.pipeline.newPipeline`: Creates a new empty pipeline with an optional name. Add steps via addStep() or addConditional().
- `lurek.pipeline.fromTable`: Creates a pipeline pre-populated with steps from a declarative table definition. Each step entry can specify name, deps, delay, optional, retryCount, retryDelay, async, tag, and fn.

### `LPipeline` Methods
- `LPipeline:addStep`: Adds an existing step object to this pipeline. The step will be scheduled according to its declared dependencies.
- `LPipeline:removeStep`: Removes a step from the pipeline by name. Any other steps that depend on it may fail or be skipped.
- `LPipeline:getStep`: Retrieves a step object by name, or nil if no step with that name exists in this pipeline.
- `LPipeline:getSteps`: Returns a table containing all step objects currently in this pipeline.
- `LPipeline:getStepCount`: Returns the total number of steps in this pipeline.
- `LPipeline:getStepsByTag`: Returns all steps that have the specified tag assigned.
- `LPipeline:clear`: Removes all steps from the pipeline, resetting it to an empty state.
- `LPipeline:validate`: Validates the pipeline structure, checking for missing dependencies and circular references.
- `LPipeline:getExecutionOrder`: Computes the topologically sorted execution order of all steps, respecting dependencies.
- `LPipeline:getParallelGroups`: Groups steps into parallel execution tiers. Steps within the same group have no mutual dependencies and can run concurrently.
- `LPipeline:run`: Executes all pipeline steps synchronously in dependency order. Blocks until all steps complete, fail, or are cancelled.
- `LPipeline:runAsync`: Starts asynchronous (coroutine-based) execution of the pipeline. Call update(dt) each frame to advance steps.
- `LPipeline:update`: Advances an async pipeline by one frame tick. Resumes coroutines, checks dependencies, and fires callbacks. Call every frame after runAsync().
- `LPipeline:cancel`: Cancels all pending and waiting steps. Steps already running or completed are unaffected.
- `LPipeline:reset`: Resets the pipeline and all steps back to their initial pending state, clearing context and async state.
- `LPipeline:isRunning`: Returns whether the pipeline is currently in async execution mode (started via runAsync and not yet finished).
- `LPipeline:isComplete`: Returns whether all steps have reached a terminal state (completed, failed, skipped, or cancelled).
- `LPipeline:setErrorMode`: Sets how the pipeline handles step failures. "abort" stops on first failure; "continue" runs remaining steps.
- `LPipeline:getErrorMode`: Returns the current error mode of the pipeline as a string.
- `LPipeline:getResult`: Returns the current pipeline result summary table, or nil if no steps exist. Useful for inspecting state after run or during async execution.
- `LPipeline:getContext`: Returns the shared context table used by the current or most recent pipeline execution, or nil if none exists.
- `LPipeline:setOnComplete`: Registers a callback invoked when the entire pipeline finishes execution. Receives the result table.
- `LPipeline:setOnStepComplete`: Registers a callback invoked each time any step completes successfully. Receives (stepName, context).
- `LPipeline:setOnStepError`: Registers a callback invoked each time any step fails. Receives (stepName, errorMessage).
- `LPipeline:getName`: Returns the name of this pipeline. This method is available to Lua scripts.
- `LPipeline:setName`: Changes the name of this pipeline. This method is available to Lua scripts.
- `LPipeline:toTable`: Serializes the pipeline configuration into a plain Lua table for inspection or persistence.
- `LPipeline:type`: Returns the type name of this object ("LPipeline").
- `LPipeline:addConditional`: Convenience method to create and add a step with dependencies and a condition in one call.
- `LPipeline:addBranch`: Adds a branching construct: evaluates a predicate, then runs either the "then" or "else" callback based on the result.
- `LPipeline:onProgress`: Registers a progress callback invoked after each step finishes (regardless of outcome). Receives (stepName, statusString).
- `LPipeline:onEvent`: Registers a low-level event callback for all pipeline lifecycle events. Receives (eventName, stepName, status, detail).
- `LPipeline:toAscii`: Returns an ASCII art diagram of the pipeline's dependency graph for debugging and visualization.
- `LPipeline:addSubPipeline`: Embeds another pipeline's steps into this pipeline under an alias prefix, with optional outer dependencies.
- `LPipeline:typeOf`: Checks whether this object is of a given type name. Accepts "LPipeline", "Pipeline", or "Object".

### `LPipelineStep` Methods
- `LPipelineStep:getName`: Returns the unique name of this pipeline step.
- `LPipelineStep:setCallback`: Sets the main execution function for this step. Called when the step runs.
- `LPipelineStep:setCondition`: Sets a predicate function that determines whether this step should execute. If the predicate returns false, the step is skipped.
- `LPipelineStep:setDelay`: Sets a delay in seconds before this step begins execution after its dependencies are satisfied.
- `LPipelineStep:getDelay`: Returns the configured delay for this step.
- `LPipelineStep:setTimeout`: Sets a maximum execution time for this step. If exceeded in async mode, the step may be considered failed.
- `LPipelineStep:getTimeout`: Returns the configured timeout for this step, or 0 if none is set.
- `LPipelineStep:setRetryCount`: Sets how many times this step should be retried after a failure before being marked as failed.
- `LPipelineStep:getRetryCount`: Returns the configured retry count for this step.
- `LPipelineStep:setRetryDelay`: Sets the delay in seconds between retry attempts for this step.
- `LPipelineStep:setAsync`: Marks this step as asynchronous. Async steps run as coroutines and can yield between frames.
- `LPipelineStep:isAsync`: Returns whether this step is configured for asynchronous coroutine execution.
- `LPipelineStep:setOptional`: Marks this step as optional. Optional steps do not cause pipeline failure if they fail.
- `LPipelineStep:isOptional`: Returns whether this step is marked as optional.
- `LPipelineStep:setOnError`: Sets an error handler callback invoked when this step fails after all retries are exhausted.
- `LPipelineStep:setData`: Stores a key-value metadata pair on this step. Useful for passing configuration between steps.
- `LPipelineStep:getData`: Retrieves a metadata value previously stored with setData.
- `LPipelineStep:setTag`: Assigns a tag string to this step for grouping and filtering purposes.
- `LPipelineStep:getTag`: Returns the tag assigned to this step, or nil if none is set.
- `LPipelineStep:dependsOn`: Declares that this step depends on another step (by name or reference). The dependency must complete before this step runs.
- `LPipelineStep:getDependencies`: Returns a list of step names that this step depends on.
- `LPipelineStep:getDependencyCount`: Returns the number of dependencies this step has.
- `LPipelineStep:getStatus`: Returns the current execution status of this step as a string ("pending", "waiting", "running", "completed", "failed", "skipped", "cancelled").
- `LPipelineStep:getError`: Returns the error message if this step failed, or nil if it has not failed.
- `LPipelineStep:getDuration`: Returns how long this step took to execute in seconds (measured from start to completion or failure).
- `LPipelineStep:getAttempt`: Returns the current attempt number (1-based). Increases with each retry.
- `LPipelineStep:type`: Returns the type name of this object ("LPipelineStep").
- `LPipelineStep:typeOf`: Checks whether this object is of a given type name. Accepts "LPipelineStep", "PipelineStep", or "Object".

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/pipeline/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
