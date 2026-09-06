-- content/examples/pipeline.lua
-- Auto-generated from content/examples2/pipeline_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pipeline.lua
-- Note: scheduler/dependency clone reductions are internal; Lua usage in this example is unchanged.

--- Pipeline Module Part 1: creating pipelines, steps, dependencies, running, results


--@api: lurek.pipeline.newPipeline
do

    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("compile", function(ctx) ctx.compiled = true end))
    lurek.log.info(tostring("name = " .. pipe:getName()))
    lurek.log.info(tostring("step count = " .. pipe:getStepCount()))
    lurek.log.info(tostring("mode = " .. pipe:getErrorMode()))
end

--@api: LPipeline:getName
do

    local pipe = lurek.pipeline.newPipeline("build")

    local before = pipe:getName()
    pipe:setName("deploy")

    lurek.log.info(tostring("before = " .. before))
    lurek.log.info(tostring("name = " .. pipe:getName()))
    lurek.log.info(tostring("type = " .. pipe:type()))
end

--@api: LPipeline:setName
do

    local pipe = lurek.pipeline.newPipeline("build")

    lurek.log.info(tostring("before rename = " .. pipe:getName()))
    pipe:setName("deploy")
    pipe:addStep(lurek.pipeline.newStep("publish", function(ctx) ctx.published = true end))

    lurek.log.info(tostring("renamed = " .. pipe:getName()))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end

--@api: lurek.pipeline.newStep
do

    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    lurek.log.info(tostring("step name = " .. step:getName()))
    lurek.log.info(tostring("type = " .. step:type()))
end

--@api: LPipelineStep:getName
do

    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    step:setTag("build")
    lurek.log.info(tostring("step name = " .. step:getName()))
    lurek.log.info(tostring("tag = " .. step:getTag()))
end

--@api: LPipeline:addStep
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

--@api: LPipelineStep:dependsOn
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

--@api: LPipelineStep:getDependencies
do

    local report = lurek.pipeline.newStep("report", function(ctx)
        ctx.reported = ctx.total
    end)

    report:dependsOn("parse")

    local deps = report:getDependencies()

    lurek.log.info(tostring("dependency count = " .. #deps))
    lurek.log.info(tostring("depends on = " .. deps[1]))
end

--@api: LPipelineStep:getDependencyCount
do

    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 6
    end)

    parse:dependsOn("fetch")

    lurek.log.info(tostring("parse deps = " .. parse:getDependencyCount()))
end

--@api: LPipeline:getResult
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

--@api: LPipeline:getStepCount
do

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    lurek.log.info(tostring("step count = " .. pipe:getStepCount()))
end

--@api: LPipeline:getSteps
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

--@api: LPipeline:getStep
do

    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local found = pipe:getStep("beta")

    lurek.log.info(tostring("found = " .. (found and found:getName() or "nil")))
end

--@api: LPipeline:removeStep
do

    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:removeStep("b")

    lurek.log.info(tostring("after remove = " .. pipe:getStepCount()))
    lurek.log.info(tostring("has b = " .. tostring(pipe:getStep("b") ~= nil)))
end

--@api: LPipeline:clear
do

    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:clear()

    lurek.log.info(tostring("after clear = " .. pipe:getStepCount()))
end

--@api: LPipeline:getExecutionOrder
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

--@api: LPipeline:getParallelGroups
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

--@api: LPipeline:validate
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

--@api: LPipeline:setErrorMode
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

--@api: LPipeline:getErrorMode
do

    local pipe = lurek.pipeline.newPipeline("error-mode")

    lurek.log.info(tostring("default mode = " .. pipe:getErrorMode()))
    pipe:setErrorMode("continue")
    pipe:addStep(lurek.pipeline.newStep("noop", function() end))

    lurek.log.info(tostring("mode = " .. pipe:getErrorMode()))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end

--@api: LPipeline:toAscii
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

--@api: LPipeline:toTable
do

    local pipe = lurek.pipeline.newPipeline("serialize")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local tbl = pipe:toTable()

    lurek.log.info(tostring("table name = " .. tbl.name))
    lurek.log.info(tostring("error mode = " .. tbl.errorMode))
    lurek.log.info(tostring("step count = " .. #tbl.steps))
end

--@api: lurek.pipeline.fromTable
do
    local example_ok = true
    local example_label = "lurek.pipeline.fromTable"
    lurek.log.info(example_label .. " ok=" .. tostring(example_ok))
    local example_value = example_ok and 1 or 0
    lurek.log.info(example_label .. " value=" .. tostring(example_value))
end

--@api: LPipeline:reset
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

--@api: LPipeline:type
do

    local pipe = lurek.pipeline.newPipeline("typed")

    pipe:addStep(lurek.pipeline.newStep("inspect", function(ctx) ctx.typed = true end))
    lurek.log.info(tostring("type = " .. pipe:type()))
    lurek.log.info(tostring("is LPipeline = " .. tostring(pipe:typeOf("LPipeline"))))
    lurek.log.info(tostring("steps = " .. pipe:getStepCount()))
end

--@api: LPipeline:typeOf
do

    local pipe = lurek.pipeline.newPipeline("typed")

    local is_pipeline = pipe:typeOf("LPipeline")
    local is_object = pipe:typeOf("LObject")
    lurek.log.info(tostring("is LPipeline = " .. tostring(is_pipeline)))
    lurek.log.info(tostring("is Object = " .. tostring(is_object)))
    lurek.log.info(tostring("type = " .. pipe:type()))
end

--- Pipeline Module Part 2: step config, async execution, callbacks, sub-pipelines, branching, tags

--@api: LPipelineStep:setCallback
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

--@api: LPipelineStep:setCondition
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

--@api: LPipelineStep:setRetryCount
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

--@api: LPipelineStep:getRetryCount
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

--@api: LPipelineStep:setRetryDelay
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

--@api: LPipelineStep:getAttempt
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

--@api: LPipelineStep:setDelay
do

    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    lurek.log.info(tostring("delay = " .. step:getDelay()))
end

--@api: LPipelineStep:getDelay
do

    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    lurek.log.info(tostring("delay = " .. step:getDelay()))
end

--@api: LPipelineStep:setTimeout
do

    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    lurek.log.info(tostring("timeout = " .. step:getTimeout()))
end

--@api: LPipelineStep:getTimeout
do

    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    lurek.log.info(tostring("timeout = " .. step:getTimeout()))
end

--@api: LPipelineStep:setOptional
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

--@api: LPipelineStep:isOptional
do

    local step = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)

    step:setOptional(true)

    lurek.log.info(tostring("optional = " .. tostring(step:isOptional())))
end

--@api: LPipelineStep:setTag
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

--@api: LPipelineStep:getTag
do

    local step = lurek.pipeline.newStep("load_a", function() end)

    step:setTag("io")

    local pipe = lurek.pipeline.newPipeline("tags")
    pipe:addStep(step)
    lurek.log.info(tostring("tag = " .. step:getTag()))
    lurek.log.info(tostring("io steps = " .. #pipe:getStepsByTag("io")))
end

--@api: LPipeline:getStepsByTag
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

--@api: LPipelineStep:setData
do

    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    lurek.log.info(tostring("version = " .. step:getData("version")))
    lurek.log.info(tostring("author = " .. step:getData("author")))
end

--@api: LPipelineStep:getData
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

--@api: LPipelineStep:setState
do

    local step = lurek.pipeline.newStep("stateful")
    step:setState({ visits = 1 })
    local name = step:getName()
    lurek.log.info("step = " .. name)
    lurek.log.info(tostring("state visits = " .. tostring(step:getState().visits)))
end

--@api: LPipelineStep:getState
do

    local step = lurek.pipeline.newStep("stateful")
    local state = step:getState()
    state.visits = (state.visits or 0) + 1
    local status = step:getStatus()
    lurek.log.info("status = " .. status)
    lurek.log.info(tostring("state visits = " .. tostring(step:getState().visits)))
end

--@api: LPipelineStep:connectOutput
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

--@api: LPipelineStep:getOutputLinks
do

    local step = lurek.pipeline.newStep("source")
    step:connectOutput(2, "target", 4, nil, false)
    local links = step:getOutputLinks()
    lurek.log.info(tostring("output = " .. tostring(links[1].output)))
    lurek.log.info(tostring("target = " .. tostring(links[1].target)))
end

--@api: LPipelineStep:setAsync
do

    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    lurek.log.info(tostring("is async = " .. tostring(step:isAsync())))
end

--@api: LPipelineStep:isAsync
do

    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    lurek.log.info(tostring("is async = " .. tostring(step:isAsync())))
end

--@api: LPipelineStep:setOnError
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

--@api: LPipelineStep:getError
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

--@api: LPipelineStep:getStatus
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

--@api: LPipelineStep:getDuration
do

    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)
    pipe:run({})

    lurek.log.info(tostring("duration = " .. tostring(step:getDuration())))
end

--@api: LPipeline:runAsync
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
end

--@api: LPipeline:update
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

--@api: LPipeline:isRunning
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

--@api: LPipeline:isComplete
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

--@api: LPipeline:cancel
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

--@api: LPipeline:onProgress
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

--@api: LPipeline:onEvent
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

--@api: LPipeline:setOnComplete
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

--@api: LPipeline:setOnStepComplete
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

--@api: LPipeline:setOnStepError
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

--@api: LPipeline:addSubPipeline
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

--@api: LPipeline:addConditional
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
end

--@api: LPipeline:addBranch
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
end

--@api: LPipelineStep:type
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

--@api: LPipelineStep:typeOf
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

--- Pipeline Module Part 2: pipeline run, getContext, fromTable

--@api: LPipeline:getContext
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

--@api: LPipeline:run
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
