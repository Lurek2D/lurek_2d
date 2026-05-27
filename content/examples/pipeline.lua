-- content/examples/pipeline.lua
-- Auto-generated from content/examples2/pipeline_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pipeline.lua

--- Pipeline Module Part 1: creating pipelines, steps, dependencies, running, results

--@api-stub: lurek.pipeline.newPipeline
do
    local pipe = lurek.pipeline.newPipeline("build")

    print("name = " .. pipe:getName())
    print("step count = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:getName
do
    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setName("deploy")

    print("name = " .. pipe:getName())
end

--@api-stub: LPipeline:setName
do
    local pipe = lurek.pipeline.newPipeline("build")

    pipe:setName("deploy")

    print("renamed = " .. pipe:getName())
end

--@api-stub: lurek.pipeline.newStep
do
    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    print("step name = " .. step:getName())
    print("type = " .. step:type())
end

--@api-stub: LPipelineStep:getName
do
    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
    end)

    print("step name = " .. step:getName())
end

--@api-stub: LPipeline:addStep
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

--@api-stub: LPipelineStep:dependsOn
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

--@api-stub: LPipelineStep:getDependencies
do
    local report = lurek.pipeline.newStep("report", function(ctx)
        ctx.reported = ctx.total
    end)

    report:dependsOn("parse")

    local deps = report:getDependencies()

    print("dependency count = " .. #deps)
    print("depends on = " .. deps[1])
end

--@api-stub: LPipelineStep:getDependencyCount
do
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 6
    end)

    parse:dependsOn("fetch")

    print("parse deps = " .. parse:getDependencyCount())
end

--@api-stub: LPipeline:getResult
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

--@api-stub: LPipeline:getStepCount
do
    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))

    print("step count = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:getSteps
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

--@api-stub: LPipeline:getStep
do
    local pipe = lurek.pipeline.newPipeline("query")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local found = pipe:getStep("beta")

    print("found = " .. (found and found:getName() or "nil"))
end

--@api-stub: LPipeline:removeStep
do
    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:removeStep("b")

    print("after remove = " .. pipe:getStepCount())
    print("has b = " .. tostring(pipe:getStep("b") ~= nil))
end

--@api-stub: LPipeline:clear
do
    local pipe = lurek.pipeline.newPipeline("remove")

    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))

    pipe:clear()

    print("after clear = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:getExecutionOrder
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

--@api-stub: LPipeline:getParallelGroups
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

--@api-stub: LPipeline:validate
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

--@api-stub: LPipeline:setErrorMode
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

--@api-stub: LPipeline:getErrorMode
do
    local pipe = lurek.pipeline.newPipeline("error-mode")

    pipe:setErrorMode("continue")

    print("mode = " .. pipe:getErrorMode())
end

--@api-stub: LPipeline:toAscii
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

--@api-stub: LPipeline:toTable
do
    local pipe = lurek.pipeline.newPipeline("serialize")

    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))

    local tbl = pipe:toTable()

    print("table name = " .. tbl.name)
    print("error mode = " .. tbl.errorMode)
    print("step count = " .. #tbl.steps)
end

--@api-stub: lurek.pipeline.fromTable
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

--@api-stub: LPipeline:reset
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

--@api-stub: LPipeline:type
do
    local pipe = lurek.pipeline.newPipeline("typed")

    print("type = " .. pipe:type())
end

--@api-stub: LPipeline:typeOf
do
    local pipe = lurek.pipeline.newPipeline("typed")

    print("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")))
    print("is Object = " .. tostring(pipe:typeOf("LObject")))
end

--- Pipeline Module Part 2: step config, async execution, callbacks, sub-pipelines, branching, tags

--@api-stub: LPipelineStep:setCallback
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

--@api-stub: LPipelineStep:setCondition
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

--@api-stub: LPipelineStep:setRetryCount
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

--@api-stub: LPipelineStep:getRetryCount
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

--@api-stub: LPipelineStep:setRetryDelay
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

--@api-stub: LPipelineStep:getAttempt
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

--@api-stub: LPipelineStep:setDelay
do
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:getDelay
do
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)

    step:setDelay(0.5)

    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:setTimeout
do
    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:getTimeout
do
    local step = lurek.pipeline.newStep("slow", function()
        return "done"
    end)

    step:setTimeout(5.0)

    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:setOptional
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

--@api-stub: LPipelineStep:isOptional
do
    local step = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)

    step:setOptional(true)

    print("optional = " .. tostring(step:isOptional()))
end

--@api-stub: LPipelineStep:setTag
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

--@api-stub: LPipelineStep:getTag
do
    local step = lurek.pipeline.newStep("load_a", function() end)

    step:setTag("io")

    print("tag = " .. step:getTag())
end

--@api-stub: LPipeline:getStepsByTag
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

--@api-stub: LPipelineStep:setData
do
    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    print("version = " .. step:getData("version"))
    print("author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:getData
do
    local step = lurek.pipeline.newStep("meta", function() end)

    step:setData("version", "1.2.0")
    step:setData("author", "engine")

    print("author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:setAsync
do
    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    print("is async = " .. tostring(step:isAsync()))
end

--@api-stub: LPipelineStep:isAsync
do
    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 1
    end)

    step:setAsync(true)

    print("is async = " .. tostring(step:isAsync()))
end

--@api-stub: LPipelineStep:setOnError
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

--@api-stub: LPipelineStep:getError
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

--@api-stub: LPipelineStep:getStatus
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

--@api-stub: LPipelineStep:getDuration
do
    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx)
        ctx.done = true
    end)

    pipe:addStep(step)
    pipe:run({})

    print("duration = " .. tostring(step:getDuration()))
end

--@api-stub: LPipeline:runAsync
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

--@api-stub: LPipeline:update
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

--@api-stub: LPipeline:isRunning
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

--@api-stub: LPipeline:isComplete
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

--@api-stub: LPipeline:cancel
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

--@api-stub: LPipeline:onProgress
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

--@api-stub: LPipeline:onEvent
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

--@api-stub: LPipeline:setOnComplete
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

--@api-stub: LPipeline:setOnStepComplete
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

--@api-stub: LPipeline:setOnStepError
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

--@api-stub: LPipeline:addSubPipeline
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

--@api-stub: LPipeline:addConditional
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

--@api-stub: LPipeline:addBranch
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

--@api-stub: LPipelineStep:type
do
    local step = lurek.pipeline.newStep("typed", function() end)

    print("type = " .. step:type())
end

--@api-stub: LPipelineStep:typeOf
do
    local step = lurek.pipeline.newStep("typed", function() end)

    print("is LPipelineStep = " .. tostring(step:typeOf("LPipelineStep")))
    print("is Object = " .. tostring(step:typeOf("LObject")))
end

--- Pipeline Module Part 2: pipeline run, getContext, fromTable

--@api-stub: LPipeline:getContext
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

--@api-stub: LPipeline:run
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
