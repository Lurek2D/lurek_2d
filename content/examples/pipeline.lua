-- content/examples/pipeline.lua
-- Auto-generated from content/examples2/pipeline_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pipeline.lua
-- Note: scheduler/dependency clone reductions are internal; Lua usage in this example is unchanged.

--- Pipeline Module Part 1: creating pipelines, steps, dependencies, running, results


--@api: lurek.pipeline.newPipeline
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("compile", function(ctx) ctx.compiled = true end))
    example_print_log("name = " .. pipe:getName())
    example_print_log("step count = " .. pipe:getStepCount())
    example_print_log("mode = " .. pipe:getErrorMode())
end

--@api: LPipeline:getName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("build")

    local before = pipe:getName()
    pipe:setName("deploy")

    example_print_log("before = " .. before)
    example_print_log("name = " .. pipe:getName())
    example_print_log("type = " .. pipe:type())
end

--@api: LPipeline:setName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("build")

    example_print_log("before rename = " .. pipe:getName())
    pipe:setName("deploy")
    pipe:addStep(lurek.pipeline.newStep("publish", function(ctx) ctx.published = true end))

    example_print_log("renamed = " .. pipe:getName())
    example_print_log("steps = " .. pipe:getStepCount())
end

--@api: lurek.pipeline.newStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    example_print_log("step name = " .. step:getName())
    example_print_log("type = " .. step:type())
end

--@api: LPipelineStep:getName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    step:setTag("build")
    example_print_log("step name = " .. step:getName())
    example_print_log("tag = " .. step:getTag())
end

--@api: LPipeline:addStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("success = " .. tostring(result.success))
    example_print_log("completed = " .. #result.completed)
end

--@api: LPipelineStep:dependsOn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fetch = lurek.pipeline.newStep("fetch", function(ctx)
        ctx.data = { 1, 2, 3 }
    end)
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        local data = ctx.data or {}
        ctx.total = (data[1] or 0) + (data[2] or 0) + (data[3] or 0)
    end)

    parse:dependsOn("fetch")

    example_print_log("parse deps = " .. parse:getDependencyCount())
    example_print_log("first dep = " .. parse:getDependencies()[1])
end

--@api: LPipelineStep:getDependencies
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local report = lurek.pipeline.newStep("report", function(ctx)
        ctx.reported = ctx.total
    end)

    report:dependsOn("parse")

    local deps = report:getDependencies()

    example_print_log("dependency count = " .. #deps)
    example_print_log("depends on = " .. deps[1])
end

--@api: LPipelineStep:getDependencyCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 6
    end)

    parse:dependsOn("fetch")

    example_print_log("parse deps = " .. parse:getDependencyCount())
end

--@api: LPipeline:getResult
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("results")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:run({})

    local result = pipe:getResult()

    example_print_log("success = " .. tostring(result.success))
    example_print_log("completed = " .. table.concat(result.completed, ", "))
end

--@api: LPipeline:getStepCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    example_print_log("step count = " .. pipe:getStepCount())
end

--@api: LPipeline:getSteps
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    local steps = pipe:getSteps()
    local seen = {}

    for i = 1, #steps do
        seen[steps[i]:getName()] = true
    end

    example_print_log("step count = " .. #steps)
    example_print_log("has alpha = " .. tostring(seen.alpha == true))
    example_print_log("has beta = " .. tostring(seen.beta == true))
end

--@api: LPipeline:getStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local found = pipe:getStep("beta")

    example_print_log("found = " .. (found and found:getName() or "nil"))
end

--@api: LPipeline:removeStep
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:removeStep("b")

    example_print_log("after remove = " .. pipe:getStepCount())
    example_print_log("has b = " .. tostring(pipe:getStep("b") ~= nil))
end

--@api: LPipeline:clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:clear()

    example_print_log("after clear = " .. pipe:getStepCount())
end

--@api: LPipeline:getExecutionOrder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log(order and ("order = " .. table.concat(order, " -> ")) or ("error = " .. tostring(err)))
end

--@api: LPipeline:getParallelGroups
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log(err and ("error = " .. err) or ("tiers = " .. #groups))
    example_print_log("first tier size = " .. firstGroupSize)
end

--@api: LPipeline:validate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("validate")
    local a = lurek.pipeline.newStep("a", function() end)
    local b = lurek.pipeline.newStep("b", function() end)

    b:dependsOn("missing_step")

    pipe:addStep(a)
    pipe:addStep(b)

    local valid, errors = pipe:validate()

    example_print_log("valid = " .. tostring(valid))
    example_print_log("error count = " .. #errors)
end

--@api: LPipeline:setErrorMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("error-mode")

    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("fail", function()
        error("oops")
    end))
    pipe:addStep(lurek.pipeline.newStep("after", function(ctx)
        ctx.reached = true
    end))

    local result = pipe:run({})

    example_print_log("mode = " .. pipe:getErrorMode())
    example_print_log("failed = " .. #result.failed)
    example_print_log("completed = " .. #result.completed)
end

--@api: LPipeline:getErrorMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("error-mode")

    example_print_log("default mode = " .. pipe:getErrorMode())
    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("noop", function() end))

    example_print_log("mode = " .. pipe:getErrorMode())
    example_print_log("steps = " .. pipe:getStepCount())
end

--@api: LPipeline:toAscii
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("graph")
    local init = lurek.pipeline.newStep("init", function() end)
    local process = lurek.pipeline.newStep("process", function() end)
    local finish = lurek.pipeline.newStep("finish", function() end)

    process:dependsOn("init")
    finish:dependsOn("process")

    pipe:addStep(init)
    pipe:addStep(process)
    pipe:addStep(finish)

    example_print_log(pipe:toAscii())
end

--@api: LPipeline:toTable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("serialize")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local tbl = pipe:toTable()

    example_print_log("table name = " .. tbl.name)
    example_print_log("error mode = " .. tbl.errorMode)
    example_print_log("step count = " .. #tbl.steps)
end

--@api: lurek.pipeline.fromTable
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("steps = " .. pipe:getStepCount())
    example_print_log("success = " .. tostring(result.success))
end

--@api: LPipeline:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("rerun")

    pipe:addStep(lurek.pipeline.newStep("count", function(ctx)
        ctx.n = (ctx.n or 0) + 1
    end))

    local firstContext = {}
    local secondContext = {}

    pipe:run(firstContext)
    pipe:reset()
    pipe:run(secondContext)

    example_print_log("first = " .. tostring(firstContext.n))
    example_print_log("second = " .. tostring(secondContext.n))
end

--@api: LPipeline:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("typed")

    pipe:addStep(lurek.pipeline.newStep("inspect", function(ctx) ctx.typed = true end))
    example_print_log("type = " .. pipe:type())
    example_print_log("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")))
    example_print_log("steps = " .. pipe:getStepCount())
end

--@api: LPipeline:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("typed")

    local is_pipeline = pipe:typeOf("LPipeline")
    local is_object = pipe:typeOf("LObject")
    example_print_log("is LPipeline = " .. tostring(is_pipeline))
    example_print_log("is Object = " .. tostring(is_object))
    example_print_log("type = " .. pipe:type())
end

--- Pipeline Module Part 2: step config, async execution, callbacks, sub-pipelines, branching, tags

--@api: LPipelineStep:setCallback
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("completed = " .. #result.completed)
    example_print_log("ran = " .. tostring(context.ran == true))
end

--@api: LPipelineStep:setCondition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("skipped = " .. #result.skipped)
    example_print_log("ran = " .. tostring(context.ran == true))
end

--@api: LPipelineStep:setRetryCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("retry count = " .. step:getRetryCount())
    example_print_log("attempt = " .. step:getAttempt())
end

--@api: LPipelineStep:getRetryCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("retry count = " .. step:getRetryCount())
end

--@api: LPipelineStep:setRetryDelay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("attempt = " .. step:getAttempt())
    example_print_log("retry count = " .. step:getRetryCount())
end

--@api: LPipelineStep:getAttempt
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("attempt = " .. step:getAttempt())
end

--@api: LPipelineStep:setDelay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    example_print_log("delay = " .. step:getDelay())
end

--@api: LPipelineStep:getDelay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    example_print_log("delay = " .. step:getDelay())
end

--@api: LPipelineStep:setTimeout
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    example_print_log("timeout = " .. step:getTimeout())
end

--@api: LPipelineStep:getTimeout
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    example_print_log("timeout = " .. step:getTimeout())
end

--@api: LPipelineStep:setOptional
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("optional = " .. tostring(optionalStep:isOptional()))
    example_print_log("failed = " .. #result.failed)
    example_print_log("completed = " .. #result.completed)
end

--@api: LPipelineStep:isOptional
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)

    step:setOptional(true)

    example_print_log("optional = " .. tostring(step:isOptional()))
end

--@api: LPipelineStep:setTag
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("s1 tag = " .. loadA:getTag())
    example_print_log("io steps = " .. #pipe:getStepsByTag("io"))
end

--@api: LPipelineStep:getTag
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("load_a", function() end)

    step:setTag("io")

    local pipe = lurek.pipeline.newPipeline("tags")
    pipe:addStep(step)
    example_print_log("tag = " .. step:getTag())
    example_print_log("io steps = " .. #pipe:getStepsByTag("io"))
end

--@api: LPipeline:getStepsByTag
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("io steps = " .. #pipe:getStepsByTag("io"))
    example_print_log("cpu steps = " .. #pipe:getStepsByTag("cpu"))
end

--@api: LPipelineStep:setData
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    example_print_log("version = " .. step:getData("version"))
    example_print_log("author = " .. step:getData("author"))
end

--@api: LPipelineStep:getData
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    local pipe = lurek.pipeline.newPipeline("meta")
    pipe:addStep(step)
    example_print_log("version = " .. step:getData("version"))
    example_print_log("author = " .. step:getData("author"))
    example_print_log("steps = " .. pipe:getStepCount())
end

--@api: LPipelineStep:setAsync
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    example_print_log("is async = " .. tostring(step:isAsync()))
end

--@api: LPipelineStep:isAsync
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    example_print_log("is async = " .. tostring(step:isAsync()))
end

--@api: LPipelineStep:setOnError
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("error = " .. tostring(step:getError()))
    example_print_log("callback = " .. errorMsg)
end

--@api: LPipelineStep:getError
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("risky", function()
        error("something broke")
    end)
    local pipe = lurek.pipeline.newPipeline("errors")

    step:setOnError(function() end)
    pipe:setErrorMode("continue")
    pipe:addStep(step)
    pipe:run({})

    example_print_log("step error = " .. tostring(step:getError()))
end

--@api: LPipelineStep:getStatus
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)

    example_print_log("before run = " .. step:getStatus())
    pipe:run({})
    example_print_log("after run = " .. step:getStatus())
end

--@api: LPipelineStep:getDuration
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)
    pipe:run({})

    example_print_log("duration = " .. tostring(step:getDuration()))
end

--@api: LPipeline:runAsync
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("phase = " .. tostring(stored.phase))
    example_print_log("complete = " .. tostring(pipe:isComplete()))
end

--@api: LPipeline:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function()
        coroutine.yield()
    end)

    step:setAsync(true)
    pipe:addStep(step)

    pipe:runAsync({})
    pipe:update(1 / 60)

    example_print_log("running = " .. tostring(pipe:isRunning()))
    example_print_log("status = " .. step:getStatus())
end

--@api: LPipeline:isRunning
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function()
        coroutine.yield()
    end)

    step:setAsync(true)
    pipe:addStep(step)

    pipe:runAsync({})

    example_print_log("running = " .. tostring(pipe:isRunning()))
end

--@api: LPipeline:isComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function(ctx)
        ctx.done = true
    end)

    step:setAsync(true)
    pipe:addStep(step)

    pipe:runAsync({})
    pipe:update(1 / 60)

    example_print_log("complete = " .. tostring(pipe:isComplete()))
end

--@api: LPipeline:cancel
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("cancelled = " .. #result.cancelled)
    example_print_log("hold status = " .. hold:getStatus())
end

--@api: LPipeline:onProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("progress count = " .. #progressLog)
    example_print_log("progress = " .. table.concat(progressLog, ", "))
end

--@api: LPipeline:onEvent
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("callbacks")
    local eventCount = 0
    local lastEvent = ""

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:onEvent(function(eventName, stepName, status)
        eventCount = eventCount + 1
        lastEvent = eventName .. ":" .. stepName .. ":" .. status
    end)
    pipe:run({})

    example_print_log("event count = " .. eventCount)
    example_print_log("last event = " .. lastEvent)
end

--@api: LPipeline:setOnComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("lifecycle")
    local summary = ""

    pipe:addStep(lurek.pipeline.newStep("ok", function() end))
    pipe:setOnComplete(function(result)
        summary = tostring(result.success)
    end)
    pipe:run({})

    example_print_log("complete = " .. summary)
end

--@api: LPipeline:setOnStepComplete
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pipe = lurek.pipeline.newPipeline("lifecycle")
    local completedSteps = {}

    pipe:addStep(lurek.pipeline.newStep("ok", function() end))
    pipe:setOnStepComplete(function(stepName)
        completedSteps[#completedSteps + 1] = stepName
    end)
    pipe:run({})

    example_print_log("completed count = " .. #completedSteps)
    example_print_log("completed = " .. table.concat(completedSteps, ", "))
end

--@api: LPipeline:setOnStepError
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("failed count = " .. #failedSteps)
    example_print_log("failed = " .. table.concat(failedSteps, ", "))
end

--@api: LPipeline:addSubPipeline
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("steps = " .. main:getStepCount())
    example_print_log(order and ("order = " .. table.concat(order, " -> ")) or ("error = " .. tostring(err)))
end

--@api: LPipeline:addConditional
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("upgraded = " .. tostring(context.upgraded == true))
end

--@api: LPipeline:addBranch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("parser = " .. tostring(context.parser))
end

--@api: LPipelineStep:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LPipelineStep:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local step = lurek.pipeline.newStep("typed", function() end)
    step:setTag("introspection")
    local is_step = step:typeOf("LPipelineStep")
    local is_object = step:typeOf("LObject")
    local is_pipeline = step:typeOf("LPipeline")
    lurek.log.info("matches LPipelineStep=" .. tostring(is_step))
    lurek.log.info("matches LObject=" .. tostring(is_object))
    lurek.log.info("matches LPipeline=" .. tostring(is_pipeline))
end

--- Pipeline Module Part 2: pipeline run, getContext, fromTable

--@api: LPipeline:getContext
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

    example_print_log("loaded = " .. tostring(stored.loaded == true))
    example_print_log("result = " .. tostring(stored.result))
end

--@api: LPipeline:run
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pl = lurek.pipeline.newPipeline("my_pipeline")
    local context = { debug = false }

    pl:addStep(lurek.pipeline.newStep("load", function(ctx)
        ctx.loaded = true
    end))
    pl:addStep(lurek.pipeline.newStep("process", function(ctx)
        ctx.result = 42
    end))

    local result = pl:run(context)

    example_print_log("success = " .. tostring(result.success))
    example_print_log("result = " .. tostring(context.result))
end
