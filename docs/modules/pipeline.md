# Pipeline

## Purpose

Orchestrates steps using validated dependency graphs. - Supports parallel groups, branch conditions, delays, retries, and output-slot routing. - Runs synchronously or asynchronously with step reports.

## Summary

- The `pipeline` module is the engine's workflow-orchestration surface for users who want multi-step processing to behave like explicit directed workflows instead of loosely nested call sequences.
- Its core value is that staged work becomes data. Steps, dependencies, scheduler policy, inputs, outputs, and result handling can be represented and advanced as pipeline state rather than hidden inside bespoke control flow.
- DAG structure matters because many real workflows are dependency-aware rather than purely linear: some work can run only after prerequisites complete, while other work may branch, fan out, or proceed in parallel.
- That makes the module useful for asset processing, validation chains, analytics jobs, build-like tasks, scripted tool workflows, content transforms, and other domains where several operations must be coordinated explicitly.
- Scheduler logic is important because a pipeline must decide when steps are eligible, blocked, complete, retried, or failed instead of merely storing a list of actions.
- Result handling matters for the same reason. Multi-step workflows usually need explicit output capture, pass-through state, intermediate artifacts, and error-aware progression rather than simple immediate returns.
- Each step is a process block, not a logistics node. A callback can receive arbitrary Lua input data, keep local Lua state, return up to five output slots, and let configured output links forward data to later blocks.
- Signal routing and data routing are separate. A completed block can signal another block without meaningful payload data, forward payload data without being the only structural dependency, or gate either behavior with Lua conditions.
- Output links make branching and fan-out explicit: one source can send slot 1 to one target, slot 2 to another target, and suppress a target entirely when a predicate rejects the payload.
- Tool-facing workflows benefit when those stages stay inspectable instead of becoming a black box.
- The module therefore gives users a stable vocabulary for reasoning about staged work, dependency flow, and execution state instead of accidental nested control structure.
- Read `pipeline` as the engine feature for explicit staged workflows with clear execution semantics.
- Do not read `pipeline` as the resource-network simulation owner. `flownet` owns graph logistics, capacities, queues, routing, and item movement; `pipeline` owns flexible process execution and block orchestration that may optionally be driven by data from a graph.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.pipeline.fromTable`

Creates a pipeline pre-populated with steps from a declarative table definition. Each step entry can specify name, deps, delay, optional, retryCount, retryDelay, async, tag, and fn.

```lua
lurek.pipeline.fromTable(definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `definition` | table | A table with optional name, errorMode, and a steps array. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipeline](#lpipeline) | The constructed pipeline. |

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

    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
    lurek.log.info(tostring("success = " .. tostring(result.success)))
end
```

---

### `lurek.pipeline.newPipeline`

Creates a new empty pipeline with an optional name. Add steps via addStep() or addConditional().

```lua
lurek.pipeline.newPipeline(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Pipeline name (defaults to "pipeline"). |

**Returns**

| Type | Description |
|------|-------------|
| [LPipeline](#lpipeline) | The new pipeline object. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("compile", function(ctx) ctx.compiled = true end))
    lurek.log.info(tostring("name = " .. pipe:getName()))
    lurek.log.info(tostring("step count = " .. pipe:getStepCount()))
    lurek.log.info(tostring("mode = " .. pipe:getErrorMode()))
end
```

---

### `lurek.pipeline.newStep`

Creates a new pipeline step with the given name and an optional callback function.

```lua
lurek.pipeline.newStep(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique step name. |
| `callback?` | function | Optional callback executed when this step runs. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipelineStep](#lpipelinestep) | The new step object. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    lurek.log.info(tostring("step name = " .. step:getName()))
    lurek.log.info(tostring("type = " .. step:type()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.pipeline.newStep` param `callback?` (`function`): Optional callback executed when this step runs.

## Enums

*No module-specific enums documented.*

## Types

- [LPipeline](#lpipeline)
- [LPipelineStep](#lpipelinestep)

## LPipeline

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPipeline:addBranch`

Adds a branching construct: evaluates a predicate, then runs either the "then" or "else" callback based on the result.

```lua
LPipeline:addBranch(name, deps, when, thenFn, elseFn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Base name for the branch (generates internal guard/then/else sub-steps). |
| `deps` | table | Array of dependency step names that must complete before the branch evaluates. |
| `when` | function | Predicate function receiving context; returns true for the "then" path. |
| `thenFn` | function | Callback executed if the predicate returns true. |
| `elseFn?` | function | Callback executed if the predicate returns false. Defaults to a no-op. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipeline](#lpipeline) | Returns self for method chaining. |

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

    lurek.log.info(tostring("parser = " .. tostring(context.parser)))
end
```

---

#### `LPipeline:addConditional`

Convenience method to create and add a step with dependencies and a condition in one call.

```lua
LPipeline:addConditional(name, deps, callback, condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique step name. |
| `deps` | table | Array of dependency step names. |
| `callback` | function | The step callback function. |
| `condition` | function | Predicate function; step runs only if it returns true. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipeline](#lpipeline) | Returns self for method chaining. |

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

    lurek.log.info(tostring("upgraded = " .. tostring(context.upgraded == true)))
end
```

---

#### `LPipeline:addStep`

Adds an existing step object to this pipeline. The step will be scheduled according to its declared dependencies.

```lua
LPipeline:addStep(step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `step` | [LPipelineStep](#lpipelinestep) | The step to add. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipeline](#lpipeline) | Returns self for method chaining. |

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

    lurek.log.info(tostring("success = " .. tostring(result.success)))
    lurek.log.info(tostring("completed = " .. #result.completed))
end
```

---

#### `LPipeline:addSubPipeline`

Embeds another pipeline's steps into this pipeline under an alias prefix, with optional outer dependencies.

```lua
LPipeline:addSubPipeline(subPipeline, alias, deps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `subPipeline` | [LPipeline](#lpipeline) | The pipeline whose steps will be merged in. |
| `alias` | string | A prefix applied to all merged step names to avoid collisions. |
| `deps?` | table | Optional array of step names that all merged steps depend on. |

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

    lurek.log.info(tostring("steps = " .. main:getStepCount()))
    lurek.log.info(tostring(order and ("order = " .. table.concat(order, " -> ")) or ("error = " .. tostring(err))))
end
```

---

#### `LPipeline:cancel`

Cancels all pending and waiting steps. Steps already running or completed are unaffected.

```lua
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

    lurek.log.info(tostring("cancelled = " .. #result.cancelled))
    lurek.log.info(tostring("hold status = " .. hold:getStatus()))
end
```

---

#### `LPipeline:clear`

Removes all steps from the pipeline, resetting it to an empty state.

```lua
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

    lurek.log.info(tostring("after clear = " .. pipe:getStepCount()))
end
```

---

#### `LPipeline:getContext`

Returns the shared context table used by the current or most recent pipeline execution, or nil if none exists.

```lua
LPipeline:getContext()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The pipeline context table. |
| nil | If no context has been set. |

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

    lurek.log.info(tostring("loaded = " .. tostring(stored.loaded == true)))
    lurek.log.info(tostring("result = " .. tostring(stored.result)))
end
```

---

#### `LPipeline:getErrorMode`

Returns the current error mode of the pipeline as a string.

```lua
LPipeline:getErrorMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "abort" or "continue". |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("error-mode")

    lurek.log.info(tostring("default mode = " .. pipe:getErrorMode()))
    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("noop", function() end))

    lurek.log.info(tostring("mode = " .. pipe:getErrorMode()))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end
```

---

#### `LPipeline:getExecutionOrder`

Computes the topologically sorted execution order of all steps, respecting dependencies.

```lua
LPipeline:getExecutionOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Step names in execution order; or nil on error. |
| string | Error message if ordering failed (e.g.; circular dependency); or nil on success. |

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

    lurek.log.info(tostring(order and ("order = " .. table.concat(order, " -> ")) or ("error = " .. tostring(err))))
end
```

---

#### `LPipeline:getName`

Returns the name of this pipeline. This method is available to Lua scripts.

```lua
LPipeline:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Pipeline name. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("build")

    local before = pipe:getName()
    pipe:setName("deploy")

    lurek.log.info(tostring("before = " .. before))
    lurek.log.info(tostring("name = " .. pipe:getName()))
    lurek.log.info(tostring("type = " .. pipe:type()))
end
```

---

#### `LPipeline:getParallelGroups`

Groups steps into parallel execution tiers. Steps within the same group have no mutual dependencies and can run concurrently.

```lua
LPipeline:getParallelGroups()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Array of arrays; each inner array is a group of step names. Nil on error. |
| string | Error message if grouping failed; or nil on success. |

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

    lurek.log.info(tostring(err and ("error = " .. err) or ("tiers = " .. #groups)))
    lurek.log.info(tostring("first tier size = " .. firstGroupSize))
end
```

---

#### `LPipeline:getResult`

Returns the current pipeline result summary table, or nil if no steps exist. Useful for inspecting state after run or during async execution.

```lua
LPipeline:getResult()
```

**Returns**

| Type | Description |
|------|-------------|
| LPipelineGetResultResult | Result table with success, completed, failed, skipped, cancelled, totalDuration, errors fields, or nil if no steps exist. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("results")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:run({})

    local result = pipe:getResult()

    lurek.log.info(tostring("success = " .. tostring(result.success)))
    lurek.log.info(tostring("completed = " .. table.concat(result.completed, ", ")))
end
```

---

#### `LPipeline:getStep`

Retrieves a step object by name, or nil if no step with that name exists in this pipeline.

```lua
LPipeline:getStep(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the step to find. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipelineStep](#lpipelinestep) | The step object, or nil if no step with that name exists. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local found = pipe:getStep("beta")

    lurek.log.info(tostring("found = " .. (found and found:getName() or "nil")))
end
```

---

#### `LPipeline:getStepCount`

Returns the total number of steps in this pipeline.

```lua
LPipeline:getStepCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Step count. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    lurek.log.info(tostring("step count = " .. pipe:getStepCount()))
end
```

---

#### `LPipeline:getSteps`

Returns a table containing all step objects currently in this pipeline.

```lua
LPipeline:getSteps()
```

**Returns**

| Type | Description |
|------|-------------|
| [LPipelineStep](#lpipelinestep)[] | [LPipelineStep](#lpipelinestep) objects. |

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

    lurek.log.info(tostring("step count = " .. #steps))
    lurek.log.info(tostring("has alpha = " .. tostring(seen.alpha == true)))
    lurek.log.info(tostring("has beta = " .. tostring(seen.beta == true)))
end
```

---

#### `LPipeline:getStepsByTag`

Returns all steps that have the specified tag assigned.

```lua
LPipeline:getStepsByTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | The tag to filter by. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipelineStep](#lpipelinestep)[] | Matching [LPipelineStep](#lpipelinestep) objects. |

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

    lurek.log.info(tostring("io steps = " .. #pipe:getStepsByTag("io")))
    lurek.log.info(tostring("cpu steps = " .. #pipe:getStepsByTag("cpu")))
end
```

---

#### `LPipeline:isComplete`

Returns whether all steps have reached a terminal state (completed, failed, skipped, or cancelled).

```lua
LPipeline:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if no steps are still pending or running. |

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

    lurek.log.info(tostring("complete = " .. tostring(pipe:isComplete())))
end
```

---

#### `LPipeline:isRunning`

Returns whether the pipeline is currently in async execution mode (started via runAsync and not yet finished).

```lua
LPipeline:isRunning()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the pipeline is actively running. |

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

    lurek.log.info(tostring("running = " .. tostring(pipe:isRunning())))
end
```

---

#### `LPipeline:onEvent`

Registers a low-level event callback for all pipeline lifecycle events. Receives (eventName, stepName, status, detail).

```lua
LPipeline:onEvent(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | A function receiving (eventName, stepName, status, detail). |

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

    lurek.log.info(tostring("event count = " .. eventCount))
    lurek.log.info(tostring("last event = " .. lastEvent))
end
```

---

#### `LPipeline:onProgress`

Registers a progress callback invoked after each step finishes (regardless of outcome). Receives (stepName, statusString).

```lua
LPipeline:onProgress(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | A function receiving (stepName, status). |

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

    lurek.log.info(tostring("progress count = " .. #progressLog))
    lurek.log.info(tostring("progress = " .. table.concat(progressLog, ", ")))
end
```

---

#### `LPipeline:removeStep`

Removes a step from the pipeline by name. Any other steps that depend on it may fail or be skipped.

```lua
LPipeline:removeStep(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the step to remove. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:removeStep("b")

    lurek.log.info(tostring("after remove = " .. pipe:getStepCount()))
    lurek.log.info(tostring("has b = " .. tostring(pipe:getStep("b") ~= nil)))
end
```

---

#### `LPipeline:reset`

Resets the pipeline and all steps back to their initial pending state, clearing context and async state.

```lua
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

    lurek.log.info(tostring("first = " .. tostring(firstContext.n)))
    lurek.log.info(tostring("second = " .. tostring(secondContext.n)))
end
```

---

#### `LPipeline:run`

Executes all pipeline steps synchronously in dependency order. Blocks until all steps complete, fail, or are cancelled.

```lua
LPipeline:run(context)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `context?` | table | An optional shared context table passed to every step callback. A fresh table is created if omitted. |

**Returns**

| Type | Description |
|------|-------------|
| LPipelineRunResult | A result table with fields: success (boolean), completed, failed, skipped, cancelled (arrays of names), totalDuration (number), errors (array of {name, msg}). |

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

    lurek.log.info(tostring("success = " .. tostring(result.success)))
    lurek.log.info(tostring("result = " .. tostring(context.result)))
end
```

---

#### `LPipeline:runAsync`

Starts asynchronous (coroutine-based) execution of the pipeline. Call update(dt) each frame to advance steps.

```lua
LPipeline:runAsync(context)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `context?` | table | An optional shared context table. A fresh table is created if omitted. |

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

    lurek.log.info(tostring("phase = " .. tostring(stored.phase)))
    lurek.log.info(tostring("complete = " .. tostring(pipe:isComplete())))
end
```

---

#### `LPipeline:setErrorMode`

Sets how the pipeline handles step failures. "abort" stops on first failure; "continue" runs remaining steps.

```lua
LPipeline:setErrorMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Either "abort" or "continue". |

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

    lurek.log.info(tostring("mode = " .. pipe:getErrorMode()))
    lurek.log.info(tostring("failed = " .. #result.failed))
    lurek.log.info(tostring("completed = " .. #result.completed))
end
```

---

#### `LPipeline:setName`

Changes the name of this pipeline. This method is available to Lua scripts.

```lua
LPipeline:setName(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | New pipeline name. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("build")

    lurek.log.info(tostring("before rename = " .. pipe:getName()))
    pipe:setName("deploy")
    pipe:addStep(lurek.pipeline.newStep("publish", function(ctx) ctx.published = true end))

    lurek.log.info(tostring("renamed = " .. pipe:getName()))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end
```

---

#### `LPipeline:setOnComplete`

Registers a callback invoked when the entire pipeline finishes execution. Receives the result table.

```lua
LPipeline:setOnComplete(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | A function receiving the result table. Pass nil to remove. |

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

    lurek.log.info(tostring("complete = " .. summary))
end
```

---

#### `LPipeline:setOnStepComplete`

Registers a callback invoked each time any step completes successfully. Receives (stepName, context).

```lua
LPipeline:setOnStepComplete(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | A function receiving (stepName, context). Pass nil to remove. |

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

    lurek.log.info(tostring("completed count = " .. #completedSteps))
    lurek.log.info(tostring("completed = " .. table.concat(completedSteps, ", ")))
end
```

---

#### `LPipeline:setOnStepError`

Registers a callback invoked each time any step fails. Receives (stepName, errorMessage).

```lua
LPipeline:setOnStepError(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | A function receiving (stepName, errorMessage). Pass nil to remove. |

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

    lurek.log.info(tostring("failed count = " .. #failedSteps))
    lurek.log.info(tostring("failed = " .. table.concat(failedSteps, ", ")))
end
```

---

#### `LPipeline:toAscii`

Returns an ASCII art diagram of the pipeline's dependency graph for debugging and visualization.

```lua
LPipeline:toAscii()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Multi-line ASCII diagram. |

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

    lurek.log.info(tostring(pipe:toAscii()))
end
```

---

#### `LPipeline:toTable`

Serializes the pipeline configuration into a plain Lua table for inspection or persistence.

```lua
LPipeline:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| LPipelineToTableResult | A table with name, errorMode, and steps array fields. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("serialize")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local tbl = pipe:toTable()

    lurek.log.info(tostring("table name = " .. tbl.name))
    lurek.log.info(tostring("error mode = " .. tbl.errorMode))
    lurek.log.info(tostring("step count = " .. #tbl.steps))
end
```

---

#### `LPipeline:type`

Returns the type name of this object ("[LPipeline](#lpipeline)").

```lua
LPipeline:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Type identifier. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("typed")

    pipe:addStep(lurek.pipeline.newStep("inspect", function(ctx) ctx.typed = true end))
    lurek.log.info(tostring("type = " .. pipe:type()))
    lurek.log.info(tostring("is LPipeline = " .. tostring(pipe:typeOf("LPipeline"))))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end
```

---

#### `LPipeline:typeOf`

Checks whether this object is of a given type name. Accepts "[LPipeline](#lpipeline)", "Pipeline", or "Object".

```lua
LPipeline:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the type matches. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("typed")

    local is_pipeline = pipe:typeOf("LPipeline")
    local is_object = pipe:typeOf("LObject")
    lurek.log.info(tostring("is LPipeline = " .. tostring(is_pipeline)))
    lurek.log.info(tostring("is Object = " .. tostring(is_object)))
    lurek.log.info(tostring("type = " .. pipe:type()))
end
```

---

#### `LPipeline:update`

Advances an async pipeline by one frame tick. Resumes coroutines, checks dependencies, and fires callbacks. Call every frame after runAsync().

```lua
LPipeline:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since last frame. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the entire pipeline has finished (all steps done); false if still running. |

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

    lurek.log.info(tostring("running = " .. tostring(pipe:isRunning())))
    lurek.log.info(tostring("status = " .. step:getStatus()))
end
```

---

#### `LPipeline:validate`

Validates the pipeline structure, checking for missing dependencies and circular references.

```lua
LPipeline:validate()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the pipeline is valid. |
| string[] | Error message strings (empty if valid). |

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

    lurek.log.info(tostring("valid = " .. tostring(valid)))
    lurek.log.info(tostring("error count = " .. #errors))
end
```

---

## LPipelineStep

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPipelineStep:connectOutput`

Connects one output slot (1..5) to a target step input slot (1..5), optionally gated by a Lua predicate.

```lua
LPipelineStep:connectOutput(outputSlot, target, inputSlot, condition, signal)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `outputSlot` | number | Source output slot, clamped to 1..5. |
| `target` | string|[LPipelineStep](#lpipelinestep) | Target step name or step object. |
| `inputSlot?` | number | Target input slot, defaults to the output slot. |
| `condition?` | function | Predicate receiving (ctx, payload, sourceName, targetName); false blocks signal and data. |
| `signal?` | boolean | Whether this link triggers target eligibility; defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipelineStep](#lpipelinestep) | Returns self for method chaining. |

**Example**

```lua
do

    local source = lurek.pipeline.newStep("score", function()
        return { output1 = { value = 9 } }
    end)
    local target = lurek.pipeline.newStep("reward", function(ctx, input)
        ctx.reward = input[1].value * 10
    end)
    source:connectOutput(1, target, 1, function(ctx, payload)
        return payload.value > 5
    end)

    local pipe = lurek.pipeline.newPipeline("slot-routing")
    pipe:addStep(source):addStep(target)
    pipe:run({})
    lurek.log.info(tostring("links = " .. #source:getOutputLinks()))
    lurek.log.info(tostring("target status = " .. target:getStatus()))
end
```

---

#### `LPipelineStep:dependsOn`

Declares that this step depends on another step (by name or reference). The dependency must complete before this step runs.

```lua
LPipelineStep:dependsOn(dep)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dep` | string|[LPipelineStep](#lpipelinestep) | The dependency step name or step object. |

**Returns**

| Type | Description |
|------|-------------|
| [LPipelineStep](#lpipelinestep) | Returns self for method chaining. |

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

    lurek.log.info(tostring("parse deps = " .. parse:getDependencyCount()))
    lurek.log.info(tostring("first dep = " .. parse:getDependencies()[1]))
end
```

---

#### `LPipelineStep:getAttempt`

Returns the current attempt number (1-based). Increases with each retry.

```lua
LPipelineStep:getAttempt()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Attempt number. |

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

    lurek.log.info(tostring("attempt = " .. step:getAttempt()))
end
```

---

#### `LPipelineStep:getData`

Retrieves a metadata value previously stored with setData.

```lua
LPipelineStep:getData(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Metadata key to look up. |

**Returns**

| Type | Description |
|------|-------------|
| string | The stored value, or nil if the key does not exist. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    local pipe = lurek.pipeline.newPipeline("meta")
    pipe:addStep(step)
    lurek.log.info(tostring("version = " .. step:getData("version")))
    lurek.log.info(tostring("author = " .. step:getData("author")))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end
```

---

#### `LPipelineStep:getDelay`

Returns the configured delay for this step.

```lua
LPipelineStep:getDelay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Delay in seconds. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    lurek.log.info(tostring("delay = " .. step:getDelay()))
end
```

---

#### `LPipelineStep:getDependencies`

Returns a list of step names that this step depends on.

```lua
LPipelineStep:getDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Dependency step name strings. |

**Example**

```lua
do

    local report = lurek.pipeline.newStep("report", function(ctx)
        ctx.reported = ctx.total
    end)

    report:dependsOn("parse")

    local deps = report:getDependencies()

    lurek.log.info(tostring("dependency count = " .. #deps))
    lurek.log.info(tostring("depends on = " .. deps[1]))
end
```

---

#### `LPipelineStep:getDependencyCount`

Returns the number of dependencies this step has.

```lua
LPipelineStep:getDependencyCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Dependency count. |

**Example**

```lua
do

    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 6
    end)

    parse:dependsOn("fetch")

    lurek.log.info(tostring("parse deps = " .. parse:getDependencyCount()))
end
```

---

#### `LPipelineStep:getDuration`

Returns how long this step took to execute in seconds (measured from start to completion or failure).

```lua
LPipelineStep:getDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Duration in seconds. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)
    pipe:run({})

    lurek.log.info(tostring("duration = " .. tostring(step:getDuration())))
end
```

---

#### `LPipelineStep:getError`

Returns the error message if this step failed, or nil if it has not failed.

```lua
LPipelineStep:getError()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Error message, or nil if the step has not failed. |

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

    lurek.log.info(tostring("step error = " .. tostring(step:getError())))
end
```

---

#### `LPipelineStep:getName`

Returns the unique name of this pipeline step.

```lua
LPipelineStep:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The step name. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    step:setTag("build")
    lurek.log.info(tostring("step name = " .. step:getName()))
    lurek.log.info(tostring("tag = " .. step:getTag()))
end
```

---

#### `LPipelineStep:getOutputLinks`

Returns configured output links for this step.

```lua
LPipelineStep:getOutputLinks()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of link tables with output, target, input, and signal fields. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("source")
    step:connectOutput(2, "target", 4, nil, false)
    local links = step:getOutputLinks()
    lurek.log.info(tostring("output = " .. tostring(links[1].output)))
    lurek.log.info(tostring("target = " .. tostring(links[1].target)))
end
```

---

#### `LPipelineStep:getRetryCount`

Returns the configured retry count for this step.

```lua
LPipelineStep:getRetryCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of retry attempts. |

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

    lurek.log.info(tostring("retry count = " .. step:getRetryCount()))
end
```

---

#### `LPipelineStep:getState`

Returns this step's local state table, creating an empty one when none exists.

```lua
LPipelineStep:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Local step state table. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("stateful")
    local state = step:getState()
    state.visits = (state.visits or 0) + 1
    local status = step:getStatus()
    lurek.log.info("status = " .. status)
    lurek.log.info(tostring("state visits = " .. tostring(step:getState().visits)))
end
```

---

#### `LPipelineStep:getStatus`

Returns the current execution status of this step as a string ("pending", "waiting", "running", "completed", "failed", "skipped", "cancelled").

```lua
LPipelineStep:getStatus()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current step status. |

**Example**

```lua
do

    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)

    lurek.log.info(tostring("before run = " .. step:getStatus()))
    pipe:run({})
    lurek.log.info(tostring("after run = " .. step:getStatus()))
end
```

---

#### `LPipelineStep:getTag`

Returns the tag assigned to this step, or nil if none is set.

```lua
LPipelineStep:getTag()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The step tag, or nil if no tag is assigned. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("load_a", function() end)

    step:setTag("io")

    local pipe = lurek.pipeline.newPipeline("tags")
    pipe:addStep(step)
    lurek.log.info(tostring("tag = " .. step:getTag()))
    lurek.log.info(tostring("io steps = " .. #pipe:getStepsByTag("io")))
end
```

---

#### `LPipelineStep:getTimeout`

Returns the configured timeout for this step, or 0 if none is set.

```lua
LPipelineStep:getTimeout()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Timeout in seconds. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    lurek.log.info(tostring("timeout = " .. step:getTimeout()))
end
```

---

#### `LPipelineStep:isAsync`

Returns whether this step is configured for asynchronous coroutine execution.

```lua
LPipelineStep:isAsync()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the step runs as a coroutine. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    lurek.log.info(tostring("is async = " .. tostring(step:isAsync())))
end
```

---

#### `LPipelineStep:isOptional`

Returns whether this step is marked as optional.

```lua
LPipelineStep:isOptional()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the step is optional. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)

    step:setOptional(true)

    lurek.log.info(tostring("optional = " .. tostring(step:isOptional())))
end
```

---

#### `LPipelineStep:setAsync`

Marks this step as asynchronous. Async steps run as coroutines and can yield between frames.

```lua
LPipelineStep:setAsync(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable coroutine-based async execution. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    lurek.log.info(tostring("is async = " .. tostring(step:isAsync())))
end
```

---

#### `LPipelineStep:setCallback`

Sets the main execution function for this step. Called when the step runs.

```lua
LPipelineStep:setCallback(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | A function receiving the pipeline context table and optionally returning a result value. |

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

    lurek.log.info(tostring("completed = " .. #result.completed))
    lurek.log.info(tostring("ran = " .. tostring(context.ran == true)))
end
```

---

#### `LPipelineStep:setCondition`

Sets a predicate function that determines whether this step should execute. If the predicate returns false, the step is skipped.

```lua
LPipelineStep:setCondition(condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `condition?` | function | A function receiving the context table and returning a boolean. Pass nil to remove the condition. |

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

    lurek.log.info(tostring("skipped = " .. #result.skipped))
    lurek.log.info(tostring("ran = " .. tostring(context.ran == true)))
end
```

---

#### `LPipelineStep:setData`

Stores a key-value metadata pair on this step. Useful for passing configuration between steps.

```lua
LPipelineStep:setData(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Metadata key. |
| `value` | string | Metadata value. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    lurek.log.info(tostring("version = " .. step:getData("version")))
    lurek.log.info(tostring("author = " .. step:getData("author")))
end
```

---

#### `LPipelineStep:setDelay`

Sets a delay in seconds before this step begins execution after its dependencies are satisfied.

```lua
LPipelineStep:setDelay(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Delay duration in seconds. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    lurek.log.info(tostring("delay = " .. step:getDelay()))
end
```

---

#### `LPipelineStep:setOnError`

Sets an error handler callback invoked when this step fails after all retries are exhausted.

```lua
LPipelineStep:setOnError(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback?` | function | A function receiving (stepName, errorMessage). Pass nil to remove. |

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

    lurek.log.info(tostring("error = " .. tostring(step:getError())))
    lurek.log.info(tostring("callback = " .. errorMsg))
end
```

---

#### `LPipelineStep:setOptional`

Marks this step as optional. Optional steps do not cause pipeline failure if they fail.

```lua
LPipelineStep:setOptional(optional)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `optional` | boolean | True to mark the step as optional. |

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

    lurek.log.info(tostring("optional = " .. tostring(optionalStep:isOptional())))
    lurek.log.info(tostring("failed = " .. #result.failed))
    lurek.log.info(tostring("completed = " .. #result.completed))
end
```

---

#### `LPipelineStep:setRetryCount`

Sets how many times this step should be retried after a failure before being marked as failed.

```lua
LPipelineStep:setRetryCount(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of retry attempts (0 means no retries). |

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

    lurek.log.info(tostring("retry count = " .. step:getRetryCount()))
    lurek.log.info(tostring("attempt = " .. step:getAttempt()))
end
```

---

#### `LPipelineStep:setRetryDelay`

Sets the delay in seconds between retry attempts for this step.

```lua
LPipelineStep:setRetryDelay(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Delay between retries. |

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

    lurek.log.info(tostring("attempt = " .. step:getAttempt()))
    lurek.log.info(tostring("retry count = " .. step:getRetryCount()))
end
```

---

#### `LPipelineStep:setState`

Stores a Lua table as local state for this step. The table is retained by registry reference.

```lua
LPipelineStep:setState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state?` | table | Local step state table; pass nil to clear. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("stateful")
    step:setState({ visits = 1 })
    local name = step:getName()
    lurek.log.info("step = " .. name)
    lurek.log.info(tostring("state visits = " .. tostring(step:getState().visits)))
end
```

---

#### `LPipelineStep:setTag`

Assigns a tag string to this step for grouping and filtering purposes.

```lua
LPipelineStep:setTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | A category tag for this step. |

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

    lurek.log.info(tostring("s1 tag = " .. loadA:getTag()))
    lurek.log.info(tostring("io steps = " .. #pipe:getStepsByTag("io")))
end
```

---

#### `LPipelineStep:setTimeout`

Sets a maximum execution time for this step. If exceeded in async mode, the step may be considered failed.

```lua
LPipelineStep:setTimeout(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Timeout duration in seconds. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    lurek.log.info(tostring("timeout = " .. step:getTimeout()))
end
```

---

#### `LPipelineStep:type`

Returns the type name of this object ("[LPipelineStep](#lpipelinestep)").

```lua
LPipelineStep:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Type identifier. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("typed", function() end)
    step:setTag("introspection")
    step:setData("owner", "debug_tools")
    local type_name = step:type()
    local tag = step:getTag()
    local owner = step:getData("owner")
    lurek.log.info("pipeline step type=" .. tostring(type_name))
    lurek.log.info("pipeline step tag=" .. tostring(tag))
    lurek.log.info("pipeline step owner=" .. tostring(owner))
end
```

---

#### `LPipelineStep:typeOf`

Checks whether this object is of a given type name. Accepts "[LPipelineStep](#lpipelinestep)", "PipelineStep", or "Object".

```lua
LPipelineStep:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check against. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the type matches. |

**Example**

```lua
do

    local step = lurek.pipeline.newStep("typed", function() end)
    step:setTag("introspection")
    local is_step = step:typeOf("LPipelineStep")
    local is_object = step:typeOf("LObject")
    local is_pipeline = step:typeOf("LPipeline")
    lurek.log.info("matches LPipelineStep=" .. tostring(is_step))
    lurek.log.info("matches LObject=" .. tostring(is_object))
    lurek.log.info("matches LPipeline=" .. tostring(is_pipeline))
end
```

---
