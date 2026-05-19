--- Pipeline Module Part 2: step config, async execution, callbacks, sub-pipelines, branching, tags

--@api-stub: LPipelineStep:setCallback
--@api-stub: LPipelineStep:setCondition
-- Step callback and conditions.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("conditional")
    step:setCallback(function(ctx)
        ctx.ran = true
        print("step executed")
    end)
    step:setCondition(function(ctx)
        return ctx.shouldRun == true
    end)
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("cond-test")
    pipe:addStep(step)
    local result = pipe:run({ shouldRun = false })
    print("skipped = " .. #result.skipped)
    pipe:reset()
    local result2 = pipe:run({ shouldRun = true })
    print("completed = " .. #result2.completed)
end

--@api-stub: LPipelineStep:setRetryCount
--@api-stub: LPipelineStep:getRetryCount
--@api-stub: LPipelineStep:setRetryDelay
--@api-stub: LPipelineStep:getAttempt
-- Retry configuration.
do
    local attempts = 0
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("flaky", function()
        attempts = attempts + 1
        if attempts < 3 then
            error("failed attempt " .. attempts)
        end
        print("succeeded on attempt " .. attempts)
    end)
    step:setRetryCount(5)
    step:setRetryDelay(0.01)
    print("retry count = " .. step:getRetryCount())
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("retry")
    pipe:addStep(step)
    local result = pipe:run()
    print("success = " .. tostring(result.success))
    print("attempt = " .. step:getAttempt())
end

--@api-stub: LPipelineStep:setDelay
--@api-stub: LPipelineStep:getDelay
-- Step delay.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)
    step:setDelay(0.5)
    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:setTimeout
--@api-stub: LPipelineStep:getTimeout
-- Step timeout.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("slow", function()
        print("running slow task")
    end)
    step:setTimeout(5.0)
    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:setOptional
--@api-stub: LPipelineStep:isOptional
-- Optional steps (don't fail the pipeline).
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("optional")
    local opt = lurek.pipeline.newStep("optional-step", function()
        error("this is fine")
    end)
    opt:setOptional(true)
    print("optional = " .. tostring(opt:isOptional()))
    local required = lurek.pipeline.newStep("required", function(ctx)
        ctx.done = true
    end)
    pipe:addStep(opt)
    pipe:addStep(required)
    local result = pipe:run()
    print("success = " .. tostring(result.success))
    print("failed = " .. #result.failed)
    print("completed = " .. #result.completed)
end

--@api-stub: LPipelineStep:setTag
--@api-stub: LPipelineStep:getTag
--@api-stub: LPipeline:getStepsByTag
-- Step tagging and filtering.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("tags")
    local s1 = lurek.pipeline.newStep("load_a", function() end)
    s1:setTag("io")
    local s2 = lurek.pipeline.newStep("load_b", function() end)
    s2:setTag("io")
    local s3 = lurek.pipeline.newStep("compute", function() end)
    s3:setTag("cpu")
    pipe:addStep(s1)
    pipe:addStep(s2)
    pipe:addStep(s3)
    print("s1 tag = " .. s1:getTag())
    local ioSteps = pipe:getStepsByTag("io")
    print("io steps = " .. #ioSteps)
    local cpuSteps = pipe:getStepsByTag("cpu")
    print("cpu steps = " .. #cpuSteps)
end

--@api-stub: LPipelineStep:setData
--@api-stub: LPipelineStep:getData
-- Step metadata.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("meta", function() end)
    step:setData("version", "1.2.0")
    step:setData("author", "engine")
    print("version = " .. step:getData("version"))
    print("author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:setAsync
--@api-stub: LPipelineStep:isAsync
-- Async step configuration.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("async-step", function(ctx)
        ctx.progress = 0
        for i = 1, 5 do
            ctx.progress = i
            coroutine.yield()
        end
    end)
    step:setAsync(true)
    print("is async = " .. tostring(step:isAsync()))
end

--@api-stub: LPipelineStep:setOnError
--@api-stub: LPipelineStep:getError
-- Step error handling.
do
    local errorMsg = ""
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("risky", function()
        error("something broke")
    end)
    step:setOnError(function(name, msg)
        errorMsg = msg
        print("error in " .. name .. ": " .. msg)
    end)
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("errors")
    pipe:setErrorMode("continue")
    pipe:addStep(step)
    pipe:run()
    print("step error = " .. tostring(step:getError()))
end

--@api-stub: LPipelineStep:getStatus
--@api-stub: LPipelineStep:getDuration
-- Step status and timing.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function()
        local sum = 0
        for i = 1, 1000 do sum = sum + i end
    end)
    pipe:addStep(step)
    print("before run: " .. step:getStatus())
    pipe:run()
    print("after run: " .. step:getStatus())
    print("duration = " .. step:getDuration())
end

--@api-stub: LPipeline:runAsync
--@api-stub: LPipeline:update
--@api-stub: LPipeline:isRunning
--@api-stub: LPipeline:isComplete
-- Async pipeline execution (coroutine-driven).
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local s1 = lurek.pipeline.newStep("phase1", function(ctx)
        ctx.phase = 1
    end)
    s1:setAsync(true)
    local s2 = lurek.pipeline.newStep("phase2", function(ctx)
        ctx.phase = 2
    end)
    s2:setAsync(true)
    s2:dependsOn("phase1")
    pipe:addStep(s1)
    pipe:addStep(s2)
    pipe:runAsync()
    print("running = " .. tostring(pipe:isRunning()))
    local frames = 0
    while not pipe:isComplete() and frames < 100 do
        local done = pipe:update(1 / 60)
        frames = frames + 1
        if done then break end
    end
    print("complete after " .. frames .. " frames")
    print("phase = " .. pipe:getContext().phase)
end

--@api-stub: LPipeline:cancel
-- Cancelling a running pipeline.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("cancel")
    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))
    pipe:runAsync()
    pipe:update(1 / 60)
    pipe:cancel()
    local result = pipe:getResult()
    print("cancelled = " .. #result.cancelled)
end

--@api-stub: LPipeline:onProgress
--@api-stub: LPipeline:onEvent
-- Progress and event callbacks.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("callbacks")
    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))
    local progressLog = {}
    pipe:onProgress(function(stepName, status)
        progressLog[#progressLog + 1] = stepName .. "=" .. status
    end)
    pipe:onEvent(function(eventName, stepName, status, detail)
        -- low-level events
    end)
    pipe:run()
    print("progress: " .. table.concat(progressLog, ", "))
end

--@api-stub: LPipeline:setOnComplete
--@api-stub: LPipeline:setOnStepComplete
--@api-stub: LPipeline:setOnStepError
-- Pipeline lifecycle callbacks.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("lifecycle")
    pipe:addStep(lurek.pipeline.newStep("ok", function() end))
    pipe:addStep(lurek.pipeline.newStep("fail", function() error("bad") end))
    pipe:setErrorMode("continue")
    local completedSteps = {}
    local failedSteps = {}
    pipe:setOnStepComplete(function(stepName, ctx)
        completedSteps[#completedSteps + 1] = stepName
    end)
    pipe:setOnStepError(function(stepName, errMsg)
        failedSteps[#failedSteps + 1] = stepName
    end)
    pipe:setOnComplete(function(result)
        print("pipeline done: success=" .. tostring(result.success))
    end)
    pipe:run()
    print("completed: " .. table.concat(completedSteps, ", "))
    print("failed: " .. table.concat(failedSteps, ", "))
end

--@api-stub: LPipeline:addSubPipeline
-- Composing pipelines with sub-pipelines.
do
    ---@type LPipeline
    local sub = lurek.pipeline.newPipeline("sub")
    sub:addStep(lurek.pipeline.newStep("fetch", function(ctx)
        ctx.fetched = true
    end))
    sub:addStep(lurek.pipeline.newStep("parse", function(ctx)
        ctx.parsed = true
    end))
    ---@type LPipeline
    local main = lurek.pipeline.newPipeline("main")
    main:addStep(lurek.pipeline.newStep("init", function(ctx)
        ctx.started = true
    end))
    main:addSubPipeline(sub, "data", { "init" })
    main:addStep(lurek.pipeline.newStep("done", function(ctx)
        print("all done")
    end))
    print("steps = " .. main:getStepCount())
    local result = main:run()
    print("success = " .. tostring(result.success))
end

--@api-stub: LPipeline:addConditional
-- Conditional step shorthand.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("conditional")
    pipe:addStep(lurek.pipeline.newStep("check", function(ctx)
        ctx.needsUpgrade = true
    end))
    pipe:addConditional("upgrade", { "check" }, function(ctx)
        ctx.upgraded = true
        print("upgrading...")
    end, function(ctx)
        return ctx.needsUpgrade == true
    end)
    pipe:run()
    print("upgraded = " .. tostring(pipe:getContext().upgraded))
end

--@api-stub: LPipeline:addBranch
-- Branching: if/then/else in the pipeline.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("branch")
    pipe:addStep(lurek.pipeline.newStep("load", function(ctx)
        ctx.format = "json"
    end))
    pipe:addBranch("route", { "load" },
        function(ctx) return ctx.format == "json" end,
        function(ctx)
            ctx.parser = "json_parser"
            print("using JSON parser")
        end,
        function(ctx)
            ctx.parser = "xml_parser"
            print("using XML parser")
        end
    )
    pipe:run()
    print("parser = " .. pipe:getContext().parser)
end

--@api-stub: LPipelineStep:type
-- Step type checking.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("typed", function() end)
    print("type = " .. step:type())
    print("is LPipelineStep = " .. tostring(step:typeOf("LPipelineStep")))
    print("is Object = " .. tostring(step:typeOf("Object")))
end

--@api-stub: LPipelineStep:typeOf
-- Step type checking.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("typed", function() end)
    print("type = " .. step:type())
    print("is LPipelineStep = " .. tostring(step:typeOf("LPipelineStep")))
    print("is Object = " .. tostring(step:typeOf("Object")))
end

print("pipeline_01.lua")
