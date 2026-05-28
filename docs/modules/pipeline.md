# Pipeline

- The `pipeline` module is an Edge/Integration tier component that provides a robust Directed Acyclic Graph (DAG) workflow orchestration engine for Lurek2D.

It is designed to sequence complex, multi-step operations—such as asset processing, test orchestration, analytics batching, or mod build workflows—by strictly enforcing dependency ordering. At the core of the module is the `Pipeline` struct, which stores named `PipelineStep`s and their dependencies. Using Kahn's algorithm, it performs topological sorting to determine the correct execution order and detects cycles before a workflow can run. It also groups independent steps into parallel execution tiers, allowing unrelated tasks to be scheduled concurrently.

Each `PipelineStep` is highly configurable, acting as a discrete unit of work. Steps support conditional execution (via run-if predicates), configurable delayed starts, and maximum timeout limits. To handle transient failures robustly, steps can be configured with automatic retries and custom retry-delay backoffs. A step's error policy (`ErrorMode`) can be explicitly set to either abort the entire pipeline upon failure or allow execution to continue (treating the failure as optional). Pipelines themselves can be nested, with `add_sub_pipeline` allowing complex workflows to be merged under namespace prefixes while automatically wiring outer dependencies into the sub-pipeline's entry points.

Execution of the pipeline is driven by the `PipelineScheduler`, a frame-driven async engine that tracks elapsed wall-clock time, manages countdown timers for delayed steps, and seamlessly handles step progression (from `Pending` to `Waiting`, `Running`, and finally `Completed`, `Failed`, or `Skipped`). The scheduler supports both synchronous blocking runs and asynchronous, coroutine-based execution that yields between frames, ensuring the game loop is never stalled by long-running background pipelines. Upon completion or cancellation, the module generates a detailed `PipelineResult` object, summarizing the outcomes, durations, and error messages for all steps. The entire workflow definition and execution API is cleanly exposed to Lua via the `lurek.pipeline.*` namespace, offering script developers a powerful tool for asynchronous task orchestration.

## Functions

### `lurek.pipeline.fromTable`

Creates a pipeline pre-populated with steps from a declarative table definition. Each step entry can specify name, deps, delay, optional, retryCount, retryDelay, async, tag, and fn.

```lua
-- signature
lurek.pipeline.fromTable(definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `definition` | `table` | A table with optional name, errorMode, and a steps array. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipeline` | The constructed pipeline. |

**Example**

```lua
do
    local pipe = lurek.pipeline.fromTable({
        name = "from-table",
        errorMode = "abort",
        steps = {
            {
                name = "x",
                fn = function(ctx)
                    ctx.x = "ran"
                end,
            },
            {
                name = "y",
                deps = { "x" },
                fn = function(ctx)
                    ctx.y = ctx.x .. " again"
                end,
            },
        },
    })

    local result = pipe:run({})

    print("steps = " .. pipe:getStepCount())
    print("success = " .. tostring(result.success))
end
```

---

### `lurek.pipeline.newPipeline`

Creates a new empty pipeline with an optional name. Add steps via addStep() or addConditional().

```lua
-- signature
lurek.pipeline.newPipeline(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | `string` | Pipeline name (defaults to "pipeline"). |

**Returns**

| Type | Description |
|------|-------------|
| `LPipeline` | The new pipeline object. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("build")

    print("name = " .. pipe:getName())
    print("step count = " .. pipe:getStepCount())
end
```

---

### `lurek.pipeline.newStep`

Creates a new pipeline step with the given name and an optional callback function.

```lua
-- signature
lurek.pipeline.newStep(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique step name. |
| `callback?` | `function` | Optional callback executed when this step runs. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineStep` | The new step object. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    print("step name = " .. step:getName())
    print("type = " .. step:type())
end
```

---

## LPipeline

### `LPipeline:addBranch`

Adds a branching construct: evaluates a predicate, then runs either the "then" or "else" callback based on the result.

```lua
-- signature
LPipeline:addBranch(name, deps, when, thenFn, elseFn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Base name for the branch (generates internal guard/then/else sub-steps). |
| `deps` | `table` | Array of dependency step names that must complete before the branch evaluates. |
| `when` | `function` | Predicate function receiving context; returns true for the "then" path. |
| `thenFn` | `function` | Callback executed if the predicate returns true. |
| `elseFn?` | `function` | Callback executed if the predicate returns false. Defaults to a no-op. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipeline` | Returns self for method chaining. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("branch")

    pipe:addStep(lurek.pipeline.newStep("load", function(ctx)
        ctx.format = "json"
    end))
    pipe:addBranch(
        "route",
        { "load" },
        function(ctx)
            return ctx.format == "json"
        end,
        function(ctx)
            ctx.parser = "json_parser"
        end,
        function(ctx)
            ctx.parser = "xml_parser"
        end
    )

    local context = {}

    pipe:run(context)

    print("parser = " .. tostring(context.parser))
end
```

---

### `LPipeline:addConditional`

Convenience method to create and add a step with dependencies and a condition in one call.

```lua
-- signature
LPipeline:addConditional(name, deps, callback, condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique step name. |
| `deps` | `table` | Array of dependency step names. |
| `callback` | `function` | The step callback function. |
| `condition` | `function` | Predicate function; step runs only if it returns true. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipeline` | Returns self for method chaining. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("conditional")

    pipe:addStep(lurek.pipeline.newStep("check", function(ctx)
        ctx.needsUpgrade = true
    end))
    pipe:addConditional(
        "upgrade",
        { "check" },
        function(ctx)
            ctx.upgraded = true
        end,
        function(ctx)
            return ctx.needsUpgrade == true
        end
    )

    local context = {}

    pipe:run(context)

    print("upgraded = " .. tostring(context.upgraded == true))
end
```

---

### `LPipeline:addStep`

Adds an existing step object to this pipeline. The step will be scheduled according to its declared dependencies.

```lua
-- signature
LPipeline:addStep(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | `LPipelineStep` | The step to add. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipeline` | Returns self for method chaining. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("hello")
    local greet = lurek.pipeline.newStep("greet", function(ctx)
        ctx.message = "hello world"
    end)
    local show = lurek.pipeline.newStep("show", function(ctx)
        ctx.displayed = ctx.message
    end)

    show:dependsOn("greet")
    pipe:addStep(greet)
    pipe:addStep(show)

    local result = pipe:run({})

    print("success = " .. tostring(result.success))
    print("completed = " .. #result.completed)
end
```

---

### `LPipeline:addSubPipeline`

Embeds another pipeline's steps into this pipeline under an alias prefix, with optional outer dependencies.

```lua
-- signature
LPipeline:addSubPipeline(subPipeline, alias, deps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `subPipeline` | `LPipeline` | The pipeline whose steps will be merged in. |
| `alias` | `string` | A prefix applied to all merged step names to avoid collisions. |
| `deps?` | `table` | Optional array of step names that all merged steps depend on. |

**Example**

```lua
do
    local sub = lurek.pipeline.newPipeline("sub")

    sub:addStep(lurek.pipeline.newStep("fetch", function(ctx)
        ctx.fetched = true
    end))
    sub:addStep(lurek.pipeline.newStep("parse", function(ctx)
        ctx.parsed = true
    end))

    local main = lurek.pipeline.newPipeline("main")

    main:addStep(lurek.pipeline.newStep("init", function(ctx)
        ctx.started = true
    end))
    main:addSubPipeline(sub, "data", { "init" })

    local order, err = main:getExecutionOrder()

    print("steps = " .. main:getStepCount())
    print(order and ("order = " .. table.concat(order, " -> ")) or ("error = " .. tostring(err)))
end
```

---

### `LPipeline:cancel`

Cancels all pending and waiting steps. Steps already running or completed are unaffected.

```lua
-- signature
LPipeline:cancel()
```

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("cancel")
    local hold = lurek.pipeline.newStep("hold", function()
        coroutine.yield()
    end)
    local later = lurek.pipeline.newStep("later", function() end)

    hold:setAsync(true)
    later:dependsOn("hold")

    pipe:addStep(hold)
    pipe:addStep(later)

    pipe:runAsync({})
    pipe:update(1 / 60)
    pipe:cancel()

    local result = pipe:getResult()

    print("cancelled = " .. #result.cancelled)
    print("hold status = " .. hold:getStatus())
end
```

---

### `LPipeline:clear`

Removes all steps from the pipeline, resetting it to an empty state.

```lua
-- signature
LPipeline:clear()
```

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:clear()

    print("after clear = " .. pipe:getStepCount())
end
```

---

### `LPipeline:getContext`

Returns the shared context table used by the current or most recent pipeline execution, or nil if none exists.

```lua
-- signature
LPipeline:getContext()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | a The pipeline context table. |
| `nil` | b If no context has been set. |

**Example**

```lua
do
    local pl = lurek.pipeline.newPipeline("my_pipeline")
    local context = { debug = false }

    pl:addStep(lurek.pipeline.newStep("load", function(ctx)
        ctx.loaded = true
    end))
    pl:addStep(lurek.pipeline.newStep("process", function(ctx)
        ctx.result = 42
    end))

    pl:runAsync(context)
    pl:update(1 / 60)
    pl:update(1 / 60)

    local stored = pl:getContext()

    print("loaded = " .. tostring(stored.loaded == true))
    print("result = " .. tostring(stored.result))
end
```

---

### `LPipeline:getErrorMode`

Returns the current error mode of the pipeline as a string.

```lua
-- signature
LPipeline:getErrorMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | "abort" or "continue". |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("error-mode")

    pipe:setErrorMode("continue")

    print("mode = " .. pipe:getErrorMode())
end
```

---

### `LPipeline:getExecutionOrder`

Computes the topologically sorted execution order of all steps, respecting dependencies.

```lua
-- signature
LPipeline:getExecutionOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | a Step names in execution order, or nil on error. |
| `string` | b Error message if ordering failed (e.g., circular dependency), or nil on success. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("order")
    local load = lurek.pipeline.newStep("load", function() end)
    local transform = lurek.pipeline.newStep("transform", function() end)
    local save = lurek.pipeline.newStep("save", function() end)

    transform:dependsOn("load")
    save:dependsOn("transform")

    pipe:addStep(load)
    pipe:addStep(transform)
    pipe:addStep(save)

    local order, err = pipe:getExecutionOrder()

    print(order and ("order = " .. table.concat(order, " -> ")) or ("error = " .. tostring(err)))
end
```

---

### `LPipeline:getName`

Returns the name of this pipeline. This method is available to Lua scripts.

```lua
-- signature
LPipeline:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Pipeline name. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setName("deploy")

    print("name = " .. pipe:getName())
end
```

---

### `LPipeline:getParallelGroups`

Groups steps into parallel execution tiers. Steps within the same group have no mutual dependencies and can run concurrently.

```lua
-- signature
LPipeline:getParallelGroups()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | a Array of arrays, each inner array is a group of step names. Nil on error. |
| `string` | b Error message if grouping failed, or nil on success. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("parallel")
    local fetchUsers = lurek.pipeline.newStep("fetch_users", function() end)
    local fetchItems = lurek.pipeline.newStep("fetch_items", function() end)
    local merge = lurek.pipeline.newStep("merge", function() end)

    merge:dependsOn("fetch_users")
    merge:dependsOn("fetch_items")

    pipe:addStep(fetchUsers)
    pipe:addStep(fetchItems)
    pipe:addStep(merge)

    local groups, err = pipe:getParallelGroups()
    local firstGroupSize = groups and groups[1] and #groups[1] or 0

    print(err and ("error = " .. err) or ("tiers = " .. #groups))
    print("first tier size = " .. firstGroupSize)
end
```

---

### `LPipeline:getResult`

Returns the current pipeline result summary table, or nil if no steps exist. Useful for inspecting state after run or during async execution.

```lua
-- signature
LPipeline:getResult()
```

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineGetResultResult` | Result table with success, completed, failed, skipped, cancelled, totalDuration, errors fields, or nil if no steps exist. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("results")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:run({})

    local result = pipe:getResult()

    print("success = " .. tostring(result.success))
    print("completed = " .. table.concat(result.completed, ", "))
end
```

---

### `LPipeline:getStep`

Retrieves a step object by name, or nil if no step with that name exists in this pipeline.

```lua
-- signature
LPipeline:getStep(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the step to find. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineStep` | The step object, or nil if no step with that name exists. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local found = pipe:getStep("beta")

    print("found = " .. (found and found:getName() or "nil"))
end
```

---

### `LPipeline:getStepCount`

Returns the total number of steps in this pipeline.

```lua
-- signature
LPipeline:getStepCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Step count. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    print("step count = " .. pipe:getStepCount())
end
```

---

### `LPipeline:getSteps`

Returns a table containing all step objects currently in this pipeline.

```lua
-- signature
LPipeline:getSteps()
```

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineStep[]` | LPipelineStep objects. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    local steps = pipe:getSteps()
    local seen = {}

    for i = 1, #steps do
        seen[steps[i]:getName()] = true
    end

    print("step count = " .. #steps)
    print("has alpha = " .. tostring(seen.alpha == true))
    print("has beta = " .. tostring(seen.beta == true))
end
```

---

### `LPipeline:getStepsByTag`

Returns all steps that have the specified tag assigned.

```lua
-- signature
LPipeline:getStepsByTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | The tag to filter by. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineStep[]` | Matching LPipelineStep objects. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("tags")
    local loadA = lurek.pipeline.newStep("load_a", function() end)
    local loadB = lurek.pipeline.newStep("load_b", function() end)
    local compute = lurek.pipeline.newStep("compute", function() end)

    loadA:setTag("io")
    loadB:setTag("io")
    compute:setTag("cpu")

    pipe:addStep(loadA)
    pipe:addStep(loadB)
    pipe:addStep(compute)

    print("io steps = " .. #pipe:getStepsByTag("io"))
    print("cpu steps = " .. #pipe:getStepsByTag("cpu"))
end
```

---

### `LPipeline:isComplete`

Returns whether all steps have reached a terminal state (completed, failed, skipped, or cancelled).

```lua
-- signature
LPipeline:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if no steps are still pending or running. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function(ctx)
        ctx.done = true
    end)

    step:setAsync(true)
    pipe:addStep(step)

    pipe:runAsync({})
    pipe:update(1 / 60)

    print("complete = " .. tostring(pipe:isComplete()))
end
```

---

### `LPipeline:isRunning`

Returns whether the pipeline is currently in async execution mode (started via runAsync and not yet finished).

```lua
-- signature
LPipeline:isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the pipeline is actively running. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function()
        coroutine.yield()
    end)

    step:setAsync(true)
    pipe:addStep(step)

    pipe:runAsync({})

    print("running = " .. tostring(pipe:isRunning()))
end
```

---

### `LPipeline:onEvent`

Registers a low-level event callback for all pipeline lifecycle events. Receives (eventName, stepName, status, detail).

```lua
-- signature
LPipeline:onEvent(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | A function receiving (eventName, stepName, status, detail). |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("callbacks")
    local eventCount = 0
    local lastEvent = ""

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:onEvent(function(eventName, stepName, status)
        eventCount = eventCount + 1
        lastEvent = eventName .. ":" .. stepName .. ":" .. status
    end)
    pipe:run({})

    print("event count = " .. eventCount)
    print("last event = " .. lastEvent)
end
```

---

### `LPipeline:onProgress`

Registers a progress callback invoked after each step finishes (regardless of outcome). Receives (stepName, statusString).

```lua
-- signature
LPipeline:onProgress(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | A function receiving (stepName, status). |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("callbacks")
    local progressLog = {}
    local first = lurek.pipeline.newStep("a", function() end)
    local second = lurek.pipeline.newStep("b", function() end)

    second:dependsOn("a")

    pipe:addStep(first)
    pipe:addStep(second)
    pipe:onProgress(function(stepName, status)
        progressLog[#progressLog + 1] = stepName .. "=" .. status
    end)
    pipe:run({})

    print("progress count = " .. #progressLog)
    print("progress = " .. table.concat(progressLog, ", "))
end
```

---

### `LPipeline:removeStep`

Removes a step from the pipeline by name. Any other steps that depend on it may fail or be skipped.

```lua
-- signature
LPipeline:removeStep(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Name of the step to remove. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:removeStep("b")

    print("after remove = " .. pipe:getStepCount())
    print("has b = " .. tostring(pipe:getStep("b") ~= nil))
end
```

---

### `LPipeline:reset`

Resets the pipeline and all steps back to their initial pending state, clearing context and async state.

```lua
-- signature
LPipeline:reset()
```

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("rerun")

    pipe:addStep(lurek.pipeline.newStep("count", function(ctx)
        ctx.n = (ctx.n or 0) + 1
    end))

    local firstContext = {}
    local secondContext = {}

    pipe:run(firstContext)
    pipe:reset()
    pipe:run(secondContext)

    print("first = " .. tostring(firstContext.n))
    print("second = " .. tostring(secondContext.n))
end
```

---

### `LPipeline:run`

Executes all pipeline steps synchronously in dependency order. Blocks until all steps complete, fail, or are cancelled.

```lua
-- signature
LPipeline:run(context)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `context?` | `table` | An optional shared context table passed to every step callback. A fresh table is created if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineRunResult` | A result table with fields: success (boolean), completed, failed, skipped, cancelled (arrays of names), totalDuration (number), errors (array of {name, msg}). |

**Example**

```lua
do
    local pl = lurek.pipeline.newPipeline("my_pipeline")
    local context = { debug = false }

    pl:addStep(lurek.pipeline.newStep("load", function(ctx)
        ctx.loaded = true
    end))
    pl:addStep(lurek.pipeline.newStep("process", function(ctx)
        ctx.result = 42
    end))

    local result = pl:run(context)

    print("success = " .. tostring(result.success))
    print("result = " .. tostring(context.result))
end
```

---

### `LPipeline:runAsync`

Starts asynchronous (coroutine-based) execution of the pipeline. Call update(dt) each frame to advance steps.

```lua
-- signature
LPipeline:runAsync(context)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `context?` | `table` | An optional shared context table. A fresh table is created if omitted. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local phase1 = lurek.pipeline.newStep("phase1", function(ctx)
        ctx.phase = 1
    end)
    local phase2 = lurek.pipeline.newStep("phase2", function(ctx)
        ctx.phase = 2
    end)
    local context = {}

    phase1:setAsync(true)
    phase2:setAsync(true)
    phase2:dependsOn("phase1")

    pipe:addStep(phase1)
    pipe:addStep(phase2)

    pipe:runAsync(context)
    pipe:update(1 / 60)
    pipe:update(1 / 60)

    local stored = pipe:getContext()

    print("phase = " .. tostring(stored.phase))
    print("complete = " .. tostring(pipe:isComplete()))
end
```

---

### `LPipeline:setErrorMode`

Sets how the pipeline handles step failures. "abort" stops on first failure; "continue" runs remaining steps.

```lua
-- signature
LPipeline:setErrorMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | `string` | Either "abort" or "continue". |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("error-mode")

    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("fail", function()
        error("oops")
    end))
    pipe:addStep(lurek.pipeline.newStep("after", function(ctx)
        ctx.reached = true
    end))

    local result = pipe:run({})

    print("mode = " .. pipe:getErrorMode())
    print("failed = " .. #result.failed)
    print("completed = " .. #result.completed)
end
```

---

### `LPipeline:setName`

Changes the name of this pipeline. This method is available to Lua scripts.

```lua
-- signature
LPipeline:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | New pipeline name. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setName("deploy")

    print("renamed = " .. pipe:getName())
end
```

---

### `LPipeline:setOnComplete`

Registers a callback invoked when the entire pipeline finishes execution. Receives the result table.

```lua
-- signature
LPipeline:setOnComplete(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | A function receiving the result table. Pass nil to remove. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("lifecycle")
    local summary = ""

    pipe:addStep(lurek.pipeline.newStep("ok", function() end))
    pipe:setOnComplete(function(result)
        summary = tostring(result.success)
    end)
    pipe:run({})

    print("complete = " .. summary)
end
```

---

### `LPipeline:setOnStepComplete`

Registers a callback invoked each time any step completes successfully. Receives (stepName, context).

```lua
-- signature
LPipeline:setOnStepComplete(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | A function receiving (stepName, context). Pass nil to remove. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("lifecycle")
    local completedSteps = {}

    pipe:addStep(lurek.pipeline.newStep("ok", function() end))
    pipe:setOnStepComplete(function(stepName)
        completedSteps[#completedSteps + 1] = stepName
    end)
    pipe:run({})

    print("completed count = " .. #completedSteps)
    print("completed = " .. table.concat(completedSteps, ", "))
end
```

---

### `LPipeline:setOnStepError`

Registers a callback invoked each time any step fails. Receives (stepName, errorMessage).

```lua
-- signature
LPipeline:setOnStepError(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | A function receiving (stepName, errorMessage). Pass nil to remove. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("lifecycle")
    local failedSteps = {}

    pipe:addStep(lurek.pipeline.newStep("fail", function()
        error("bad")
    end))
    pipe:setErrorMode("continue")
    pipe:setOnStepError(function(stepName)
        failedSteps[#failedSteps + 1] = stepName
    end)
    pipe:run({})

    print("failed count = " .. #failedSteps)
    print("failed = " .. table.concat(failedSteps, ", "))
end
```

---

### `LPipeline:toAscii`

Returns an ASCII art diagram of the pipeline's dependency graph for debugging and visualization.

```lua
-- signature
LPipeline:toAscii()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Multi-line ASCII diagram. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("graph")
    local init = lurek.pipeline.newStep("init", function() end)
    local process = lurek.pipeline.newStep("process", function() end)
    local finish = lurek.pipeline.newStep("finish", function() end)

    process:dependsOn("init")
    finish:dependsOn("process")

    pipe:addStep(init)
    pipe:addStep(process)
    pipe:addStep(finish)

    print(pipe:toAscii())
end
```

---

### `LPipeline:toTable`

Serializes the pipeline configuration into a plain Lua table for inspection or persistence.

```lua
-- signature
LPipeline:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineToTableResult` | A table with name, errorMode, and steps array fields. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("serialize")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local tbl = pipe:toTable()

    print("table name = " .. tbl.name)
    print("error mode = " .. tbl.errorMode)
    print("step count = " .. #tbl.steps)
end
```

---

### `LPipeline:type`

Returns the type name of this object ("LPipeline").

```lua
-- signature
LPipeline:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Type identifier. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("typed")

    print("type = " .. pipe:type())
end
```

---

### `LPipeline:typeOf`

Checks whether this object is of a given type name. Accepts "LPipeline", "Pipeline", or "Object".

```lua
-- signature
LPipeline:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the type matches. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("typed")

    print("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")))
    print("is Object = " .. tostring(pipe:typeOf("LObject")))
end
```

---

### `LPipeline:update`

Advances an async pipeline by one frame tick. Resumes coroutines, checks dependencies, and fires callbacks. Call every frame after runAsync().

```lua
-- signature
LPipeline:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds since last frame. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the entire pipeline has finished (all steps done); false if still running. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function()
        coroutine.yield()
    end)

    step:setAsync(true)
    pipe:addStep(step)

    pipe:runAsync({})
    pipe:update(1 / 60)

    print("running = " .. tostring(pipe:isRunning()))
    print("status = " .. step:getStatus())
end
```

---

### `LPipeline:validate`

Validates the pipeline structure, checking for missing dependencies and circular references.

```lua
-- signature
LPipeline:validate()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True if the pipeline is valid. |
| `string[]` | b Error message strings (empty if valid). |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("validate")
    local a = lurek.pipeline.newStep("a", function() end)
    local b = lurek.pipeline.newStep("b", function() end)

    b:dependsOn("missing_step")

    pipe:addStep(a)
    pipe:addStep(b)

    local valid, errors = pipe:validate()

    print("valid = " .. tostring(valid))
    print("error count = " .. #errors)
end
```

---

## LPipelineStep

### `LPipelineStep:dependsOn`

Declares that this step depends on another step (by name or reference). The dependency must complete before this step runs.

```lua
-- signature
LPipelineStep:dependsOn(dep)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dep` | `string|LPipelineStep` | The dependency step name or step object. |

**Returns**

| Type | Description |
|------|-------------|
| `LPipelineStep` | Returns self for method chaining. |

**Example**

```lua
do
    local fetch = lurek.pipeline.newStep("fetch", function(ctx)
        ctx.data = { 1, 2, 3 }
    end)
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        local data = ctx.data or {}
        ctx.total = (data[1] or 0) + (data[2] or 0) + (data[3] or 0)
    end)

    parse:dependsOn("fetch")

    print("parse deps = " .. parse:getDependencyCount())
    print("first dep = " .. parse:getDependencies()[1])
end
```

---

### `LPipelineStep:getAttempt`

Returns the current attempt number (1-based). Increases with each retry.

```lua
-- signature
LPipelineStep:getAttempt()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Attempt number. |

**Example**

```lua
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function()
        attempts = attempts + 1
        if attempts < 3 then
            error("failed attempt " .. attempts)
        end
    end)
    local pipe = lurek.pipeline.newPipeline("retry")

    step:setRetryCount(5)
    step:setRetryDelay(0.01)
    pipe:addStep(step)
    pipe:run({})

    print("attempt = " .. step:getAttempt())
end
```

---

### `LPipelineStep:getData`

Retrieves a metadata value previously stored with setData.

```lua
-- signature
LPipelineStep:getData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Metadata key to look up. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The stored value, or nil if the key does not exist. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    print("author = " .. step:getData("author"))
end
```

---

### `LPipelineStep:getDelay`

Returns the configured delay for this step.

```lua
-- signature
LPipelineStep:getDelay()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Delay in seconds. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    print("delay = " .. step:getDelay())
end
```

---

### `LPipelineStep:getDependencies`

Returns a list of step names that this step depends on.

```lua
-- signature
LPipelineStep:getDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Dependency step name strings. |

**Example**

```lua
do
    local report = lurek.pipeline.newStep("report", function(ctx)
        ctx.reported = ctx.total
    end)

    report:dependsOn("parse")

    local deps = report:getDependencies()

    print("dependency count = " .. #deps)
    print("depends on = " .. deps[1])
end
```

---

### `LPipelineStep:getDependencyCount`

Returns the number of dependencies this step has.

```lua
-- signature
LPipelineStep:getDependencyCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Dependency count. |

**Example**

```lua
do
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 6
    end)

    parse:dependsOn("fetch")

    print("parse deps = " .. parse:getDependencyCount())
end
```

---

### `LPipelineStep:getDuration`

Returns how long this step took to execute in seconds (measured from start to completion or failure).

```lua
-- signature
LPipelineStep:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Duration in seconds. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)
    pipe:run({})

    print("duration = " .. tostring(step:getDuration()))
end
```

---

### `LPipelineStep:getError`

Returns the error message if this step failed, or nil if it has not failed.

```lua
-- signature
LPipelineStep:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Error message, or nil if the step has not failed. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("risky", function()
        error("something broke")
    end)
    local pipe = lurek.pipeline.newPipeline("errors")

    step:setOnError(function() end)
    pipe:setErrorMode("continue")
    pipe:addStep(step)
    pipe:run({})

    print("step error = " .. tostring(step:getError()))
end
```

---

### `LPipelineStep:getName`

Returns the unique name of this pipeline step.

```lua
-- signature
LPipelineStep:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The step name. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    print("step name = " .. step:getName())
end
```

---

### `LPipelineStep:getRetryCount`

Returns the configured retry count for this step.

```lua
-- signature
LPipelineStep:getRetryCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of retry attempts. |

**Example**

```lua
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function()
        attempts = attempts + 1
        if attempts < 3 then
            error("failed attempt " .. attempts)
        end
    end)
    local pipe = lurek.pipeline.newPipeline("retry")

    step:setRetryCount(5)
    step:setRetryDelay(0.01)
    pipe:addStep(step)
    pipe:run({})

    print("retry count = " .. step:getRetryCount())
end
```

---

### `LPipelineStep:getStatus`

Returns the current execution status of this step as a string ("pending", "waiting", "running", "completed", "failed", "skipped", "cancelled").

```lua
-- signature
LPipelineStep:getStatus()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current step status. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)

    print("before run = " .. step:getStatus())
    pipe:run({})
    print("after run = " .. step:getStatus())
end
```

---

### `LPipelineStep:getTag`

Returns the tag assigned to this step, or nil if none is set.

```lua
-- signature
LPipelineStep:getTag()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The step tag, or nil if no tag is assigned. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("load_a", function() end)

    step:setTag("io")

    print("tag = " .. step:getTag())
end
```

---

### `LPipelineStep:getTimeout`

Returns the configured timeout for this step, or 0 if none is set.

```lua
-- signature
LPipelineStep:getTimeout()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Timeout in seconds. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    print("timeout = " .. step:getTimeout())
end
```

---

### `LPipelineStep:isAsync`

Returns whether this step is configured for asynchronous coroutine execution.

```lua
-- signature
LPipelineStep:isAsync()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the step runs as a coroutine. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    print("is async = " .. tostring(step:isAsync()))
end
```

---

### `LPipelineStep:isOptional`

Returns whether this step is marked as optional.

```lua
-- signature
LPipelineStep:isOptional()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the step is optional. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)

    step:setOptional(true)

    print("optional = " .. tostring(step:isOptional()))
end
```

---

### `LPipelineStep:setAsync`

Marks this step as asynchronous. Async steps run as coroutines and can yield between frames.

```lua
-- signature
LPipelineStep:setAsync(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | True to enable coroutine-based async execution. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    print("is async = " .. tostring(step:isAsync()))
end
```

---

### `LPipelineStep:setCallback`

Sets the main execution function for this step. Called when the step runs.

```lua
-- signature
LPipelineStep:setCallback(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | `function` | A function receiving the pipeline context table and optionally returning a result value. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("conditional")

    step:setCallback(function(ctx)
        ctx.ran = true
    end)
    step:setCondition(function(ctx)
        return ctx.shouldRun == true
    end)

    local pipe = lurek.pipeline.newPipeline("cond-test")
    local context = { shouldRun = true }

    pipe:addStep(step)

    local result = pipe:run(context)

    print("completed = " .. #result.completed)
    print("ran = " .. tostring(context.ran == true))
end
```

---

### `LPipelineStep:setCondition`

Sets a predicate function that determines whether this step should execute. If the predicate returns false, the step is skipped.

```lua
-- signature
LPipelineStep:setCondition(condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `condition?` | `function` | A function receiving the context table and returning a boolean. Pass nil to remove the condition. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("conditional")

    step:setCallback(function(ctx)
        ctx.ran = true
    end)
    step:setCondition(function(ctx)
        return ctx.shouldRun == true
    end)

    local pipe = lurek.pipeline.newPipeline("cond-test")
    local context = { shouldRun = false }

    pipe:addStep(step)

    local result = pipe:run(context)

    print("skipped = " .. #result.skipped)
    print("ran = " .. tostring(context.ran == true))
end
```

---

### `LPipelineStep:setData`

Stores a key-value metadata pair on this step. Useful for passing configuration between steps.

```lua
-- signature
LPipelineStep:setData(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Metadata key. |
| `value` | `string` | Metadata value. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    print("version = " .. step:getData("version"))
    print("author = " .. step:getData("author"))
end
```

---

### `LPipelineStep:setDelay`

Sets a delay in seconds before this step begins execution after its dependencies are satisfied.

```lua
-- signature
LPipelineStep:setDelay(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Delay duration in seconds. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    print("delay = " .. step:getDelay())
end
```

---

### `LPipelineStep:setOnError`

Sets an error handler callback invoked when this step fails after all retries are exhausted.

```lua
-- signature
LPipelineStep:setOnError(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | `function` | A function receiving (stepName, errorMessage). Pass nil to remove. |

**Example**

```lua
do
    local errorMsg = ""
    local step = lurek.pipeline.newStep("risky", function()
        error("something broke")
    end)
    local pipe = lurek.pipeline.newPipeline("errors")

    step:setOnError(function(name, msg)
        errorMsg = name .. ":" .. msg
    end)
    pipe:setErrorMode("continue")
    pipe:addStep(step)
    pipe:run({})

    print("error = " .. tostring(step:getError()))
    print("callback = " .. errorMsg)
end
```

---

### `LPipelineStep:setOptional`

Marks this step as optional. Optional steps do not cause pipeline failure if they fail.

```lua
-- signature
LPipelineStep:setOptional(optional)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `optional` | `boolean` | True to mark the step as optional. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("optional")
    local optionalStep = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)
    local required = lurek.pipeline.newStep("required", function(ctx)
        ctx.done = true
    end)

    pipe:setErrorMode("continue")
    optionalStep:setOptional(true)
    required:dependsOn("optional-step")

    pipe:addStep(optionalStep)
    pipe:addStep(required)

    local result = pipe:run({})

    print("optional = " .. tostring(optionalStep:isOptional()))
    print("failed = " .. #result.failed)
    print("completed = " .. #result.completed)
end
```

---

### `LPipelineStep:setRetryCount`

Sets how many times this step should be retried after a failure before being marked as failed.

```lua
-- signature
LPipelineStep:setRetryCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | `number` | Number of retry attempts (0 means no retries). |

**Example**

```lua
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function()
        attempts = attempts + 1
        if attempts < 3 then
            error("failed attempt " .. attempts)
        end
    end)
    local pipe = lurek.pipeline.newPipeline("retry")

    step:setRetryCount(5)
    step:setRetryDelay(0.01)
    pipe:addStep(step)
    pipe:run({})

    print("retry count = " .. step:getRetryCount())
    print("attempt = " .. step:getAttempt())
end
```

---

### `LPipelineStep:setRetryDelay`

Sets the delay in seconds between retry attempts for this step.

```lua
-- signature
LPipelineStep:setRetryDelay(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Delay between retries. |

**Example**

```lua
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function()
        attempts = attempts + 1
        if attempts < 3 then
            error("failed attempt " .. attempts)
        end
    end)
    local pipe = lurek.pipeline.newPipeline("retry")

    step:setRetryCount(5)
    step:setRetryDelay(0.01)
    pipe:addStep(step)
    pipe:run({})

    print("attempt = " .. step:getAttempt())
    print("retry count = " .. step:getRetryCount())
end
```

---

### `LPipelineStep:setTag`

Assigns a tag string to this step for grouping and filtering purposes.

```lua
-- signature
LPipelineStep:setTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | `string` | A category tag for this step. |

**Example**

```lua
do
    local pipe = lurek.pipeline.newPipeline("tags")
    local loadA = lurek.pipeline.newStep("load_a", function() end)
    local loadB = lurek.pipeline.newStep("load_b", function() end)
    local compute = lurek.pipeline.newStep("compute", function() end)

    loadA:setTag("io")
    loadB:setTag("io")
    compute:setTag("cpu")

    pipe:addStep(loadA)
    pipe:addStep(loadB)
    pipe:addStep(compute)

    print("s1 tag = " .. loadA:getTag())
    print("io steps = " .. #pipe:getStepsByTag("io"))
end
```

---

### `LPipelineStep:setTimeout`

Sets a maximum execution time for this step. If exceeded in async mode, the step may be considered failed.

```lua
-- signature
LPipelineStep:setTimeout(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | `number` | Timeout duration in seconds. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    print("timeout = " .. step:getTimeout())
end
```

---

### `LPipelineStep:type`

Returns the type name of this object ("LPipelineStep").

```lua
-- signature
LPipelineStep:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Type identifier. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("typed", function() end)

    print("type = " .. step:type())
end
```

---

### `LPipelineStep:typeOf`

Checks whether this object is of a given type name. Accepts "LPipelineStep", "PipelineStep", or "Object".

```lua
-- signature
LPipelineStep:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the type matches. |

**Example**

```lua
do
    local step = lurek.pipeline.newStep("typed", function() end)

    print("is LPipelineStep = " .. tostring(step:typeOf("LPipelineStep")))
    print("is Object = " .. tostring(step:typeOf("LObject")))
end
```

---
