-- content/examples/pipeline.lua
-- love2d-style usage snippets for the lurek.pipeline API (60 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/pipeline.lua

-- ── lurek.pipeline.* functions ──

--@api-stub: lurek.pipeline.newStep
-- Creates a new pipeline step with the given name and optional callback.
-- Build once at startup; reuse across frames.
local step = lurek.pipeline.newStep("main", function() print("newStep fired") end)
print("created", step)
return step

--@api-stub: lurek.pipeline.newPipeline
-- Creates a new empty pipeline with the given name (defaults to "pipeline").
-- Build once at startup; reuse across frames.
local pipeline = lurek.pipeline.newPipeline("main")
print("created", pipeline)
return pipeline

--@api-stub: lurek.pipeline.fromTable
-- Deserialises a pipeline from a definition table.
-- Build once at startup; reuse across frames.
local fromtable = lurek.pipeline.fromTable(def)
print("created", fromtable)
return fromtable

-- ── Step methods ──

--@api-stub: Step:getName
-- Returns the unique name of this step.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getName()
print("Step:getName ->", value)

--@api-stub: Step:setCallback
-- Stores a Lua function as the execute callback for this step.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setCallback(function() print("setCallback fired") end)
print("Step:setCallback applied")

--@api-stub: Step:setCondition
-- Stores a Lua function (or nil) as the run-condition for this step.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setCondition(cond)
print("Step:setCondition applied")

--@api-stub: Step:setDelay
-- Sets the delay in seconds to wait after dependencies finish.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setDelay(1.0)
print("Step:setDelay applied")

--@api-stub: Step:getDelay
-- Returns the configured delay in seconds.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getDelay()
print("Step:getDelay ->", value)

--@api-stub: Step:setTimeout
-- Stores a timeout in seconds in the step's metadata.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setTimeout(1.0)
print("Step:setTimeout applied")

--@api-stub: Step:getTimeout
-- Returns the timeout stored in metadata, or 0.0 if unset.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getTimeout()
print("Step:getTimeout ->", value)

--@api-stub: Step:setRetryCount
-- Sets the maximum number of retry attempts on failure.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setRetryCount(10)
print("Step:setRetryCount applied")

--@api-stub: Step:getRetryCount
-- Returns the configured retry count.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getRetryCount()
print("Step:getRetryCount ->", value)

--@api-stub: Step:setRetryDelay
-- Sets the delay in seconds between retry attempts.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setRetryDelay(1.0)
print("Step:setRetryDelay applied")

--@api-stub: Step:setOptional
-- Marks whether this step is optional (downstream steps continue on failure).
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setOptional(optional)
print("Step:setOptional applied")

--@api-stub: Step:isOptional
-- Returns whether this step is marked as optional.
-- Use as a guard inside lurek.update or event handlers.
local step = lurek.pipeline.newStep()
if step:isOptional() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Step:setOnError
-- Stores a Lua function (or nil) to call if this step fails.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setOnError(function() print("setOnError fired") end)
print("Step:setOnError applied")

--@api-stub: Step:setData
-- Stores an arbitrary string value under the given key in step metadata.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setData("space", value)
print("Step:setData applied")

--@api-stub: Step:getData
-- Retrieves a metadata value by key, returning nil if not found.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getData("space")
print("Step:getData ->", value)

--@api-stub: Step:setTag
-- Sets the tag on this step for grouping and filtering.
-- Apply at startup or in response to user input.
local step = lurek.pipeline.newStep()
step:setTag("main")
print("Step:setTag applied")

--@api-stub: Step:getTag
-- Returns the tag on this step, or nil if unset.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getTag()
print("Step:getTag ->", value)

--@api-stub: Step:dependsOn
-- Adds a dependency on another step by name or PipelineStep.
-- See the module spec for detailed semantics.
local step = lurek.pipeline.newStep()
step:dependsOn(dep)
print("Step:dependsOn done")

--@api-stub: Step:getDependencies
-- Returns the list of dependency step names.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getDependencies()
print("Step:getDependencies ->", value)

--@api-stub: Step:getDependencyCount
-- Returns the number of declared dependencies.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getDependencyCount()
print("Step:getDependencyCount ->", value)

--@api-stub: Step:getStatus
-- Returns the current execution status as a string.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getStatus()
print("Step:getStatus ->", value)

--@api-stub: Step:getError
-- Returns the error message from the last failed attempt, or nil.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getError()
print("Step:getError ->", value)

--@api-stub: Step:getDuration
-- Returns total seconds spent executing this step.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getDuration()
print("Step:getDuration ->", value)

--@api-stub: Step:getAttempt
-- Returns the number of execution attempts so far.
-- Cheap to call; safe inside callbacks.
local step = lurek.pipeline.newStep()  -- or your existing handle
local value = step:getAttempt()
print("Step:getAttempt ->", value)

--@api-stub: Step:type
-- Returns the type name "PipelineStep".
-- See the module spec for detailed semantics.
local step = lurek.pipeline.newStep()
step:type()
print("Step:type done")

--@api-stub: Step:typeOf
-- Returns true when the given name matches "PipelineStep" or a parent type.
-- See the module spec for detailed semantics.
local step = lurek.pipeline.newStep()
step:typeOf("main")
print("Step:typeOf done")

-- ── Pipeline methods ──

--@api-stub: Pipeline:addStep
-- Adds a step to the pipeline.
-- Side-effecting; safe to call any time after init.
local pipeline = lurek.pipeline.newPipeline()
pipeline:addStep(step_ud)
print("Pipeline:addStep done")

--@api-stub: Pipeline:removeStep
-- Removes a step from the pipeline by name.
-- Pair with the matching constructor to free resources.
local pipeline = lurek.pipeline.newPipeline()
pipeline:removeStep("main")
-- pipeline is now released
print("ok")

--@api-stub: Pipeline:getStep
-- Returns the LuaStep wrapper for the named step, or nil.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getStep("main")
print("Pipeline:getStep ->", value)

--@api-stub: Pipeline:getSteps
-- Returns a Lua array of all step wrappers in the pipeline.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getSteps()
print("Pipeline:getSteps ->", value)

--@api-stub: Pipeline:getStepCount
-- Returns the total number of steps.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getStepCount()
print("Pipeline:getStepCount ->", value)

--@api-stub: Pipeline:getStepsByTag
-- Returns a Lua array of all steps whose tag matches the given string.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getStepsByTag("main")
print("Pipeline:getStepsByTag ->", value)

--@api-stub: Pipeline:clear
-- Clears all steps from the pipeline.
-- Pair with the matching constructor to free resources.
local pipeline = lurek.pipeline.newPipeline()
pipeline:clear()
-- pipeline is now released
print("ok")

--@api-stub: Pipeline:validate
-- Validates the pipeline DAG.
-- See the module spec for detailed semantics.
local pipeline = lurek.pipeline.newPipeline()
pipeline:validate()
print("Pipeline:validate done")

--@api-stub: Pipeline:getExecutionOrder
-- Returns the topological execution order as an array of step names.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getExecutionOrder()
print("Pipeline:getExecutionOrder ->", value)

--@api-stub: Pipeline:getParallelGroups
-- Returns parallel execution groups as a nested array of step name arrays.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getParallelGroups()
print("Pipeline:getParallelGroups ->", value)

--@api-stub: Pipeline:run
-- Executes the pipeline synchronously in topological order.
-- Trigger from input, timers, or game events.
local pipeline = lurek.pipeline.newPipeline()
pipeline:run("hello")
-- trigger from input, timer, or event
print("ok")

--@api-stub: Pipeline:runAsync
-- Starts an async pipeline run.
-- Trigger from input, timers, or game events.
local pipeline = lurek.pipeline.newPipeline()
pipeline:runAsync("hello")
-- trigger from input, timer, or event
print("ok")

--@api-stub: Pipeline:update
-- Advances the async pipeline by one tick.
-- Apply at startup or in response to user input.
local pipeline = lurek.pipeline.newPipeline()
pipeline:update(dt)
print("Pipeline:update applied")

--@api-stub: Pipeline:cancel
-- Cancels all pending and waiting steps.
-- Pair with the matching constructor to free resources.
local pipeline = lurek.pipeline.newPipeline()
pipeline:cancel()
-- pipeline is now released
print("ok")

--@api-stub: Pipeline:reset
-- Resets all step states and clears the async context.
-- Pair with the matching constructor to free resources.
local pipeline = lurek.pipeline.newPipeline()
pipeline:reset()
-- pipeline is now released
print("ok")

--@api-stub: Pipeline:isRunning
-- Returns true if the pipeline is currently running asynchronously.
-- Use as a guard inside lurek.update or event handlers.
local pipeline = lurek.pipeline.newPipeline()
if pipeline:isRunning() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Pipeline:isComplete
-- Returns true if all steps have reached a terminal state.
-- Use as a guard inside lurek.update or event handlers.
local pipeline = lurek.pipeline.newPipeline()
if pipeline:isComplete() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Pipeline:setErrorMode
-- Sets the pipeline error mode: "abort" or "continue".
-- Apply at startup or in response to user input.
local pipeline = lurek.pipeline.newPipeline()
pipeline:setErrorMode(mode)
print("Pipeline:setErrorMode applied")

--@api-stub: Pipeline:getErrorMode
-- Returns the current error mode as a string.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getErrorMode()
print("Pipeline:getErrorMode ->", value)

--@api-stub: Pipeline:getResult
-- Returns the current result table built from step states, or nil.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getResult()
print("Pipeline:getResult ->", value)

--@api-stub: Pipeline:getContext
-- Returns the stored async context table, or nil.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getContext()
print("Pipeline:getContext ->", value)

--@api-stub: Pipeline:setOnComplete
-- Sets the callback to invoke when the pipeline completes.
-- Apply at startup or in response to user input.
local pipeline = lurek.pipeline.newPipeline()
pipeline:setOnComplete(function() print("setOnComplete fired") end)
print("Pipeline:setOnComplete applied")

--@api-stub: Pipeline:setOnStepComplete
-- Sets the callback to invoke each time a step completes successfully.
-- Apply at startup or in response to user input.
local pipeline = lurek.pipeline.newPipeline()
pipeline:setOnStepComplete(function() print("setOnStepComplete fired") end)
print("Pipeline:setOnStepComplete applied")

--@api-stub: Pipeline:setOnStepError
-- Sets the callback to invoke each time a step fails.
-- Apply at startup or in response to user input.
local pipeline = lurek.pipeline.newPipeline()
pipeline:setOnStepError(function() print("setOnStepError fired") end)
print("Pipeline:setOnStepError applied")

--@api-stub: Pipeline:getName
-- Returns the pipeline's name.
-- Cheap to call; safe inside callbacks.
local pipeline = lurek.pipeline.newPipeline()  -- or your existing handle
local value = pipeline:getName()
print("Pipeline:getName ->", value)

--@api-stub: Pipeline:setName
-- Sets the pipeline's name.
-- Apply at startup or in response to user input.
local pipeline = lurek.pipeline.newPipeline()
pipeline:setName("main")
print("Pipeline:setName applied")

--@api-stub: Pipeline:toTable
-- Serialises the pipeline definition to a Lua table (no callbacks).
-- See the module spec for detailed semantics.
local pipeline = lurek.pipeline.newPipeline()
pipeline:toTable()
print("Pipeline:toTable done")

--@api-stub: Pipeline:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local pipeline = lurek.pipeline.newPipeline()
pipeline:type()
print("Pipeline:type done")

--@api-stub: Pipeline:onProgress
-- Registers a callback invoked after every step with `(step_name, status)`.
-- See the module spec for detailed semantics.
local pipeline = lurek.pipeline.newPipeline()
pipeline:onProgress(function() print("onProgress fired") end)
print("Pipeline:onProgress done")

--@api-stub: Pipeline:toAscii
-- Returns a multi-line ASCII string visualising the pipeline DAG.
-- See the module spec for detailed semantics.
local pipeline = lurek.pipeline.newPipeline()
pipeline:toAscii()
print("Pipeline:toAscii done")

--@api-stub: Pipeline:typeOf
-- Returns the type identifier string of this pipeline stage object.
-- See the module spec for detailed semantics.
local pipeline = lurek.pipeline.newPipeline()
pipeline:typeOf("main")
print("Pipeline:typeOf done")

