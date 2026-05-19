-- content/examples/pipeline.lua
-- Auto-generated from content/examples2/pipeline_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pipeline.lua

--- Pipeline Module Part 1: creating pipelines, steps, dependencies, running, results


--@api-stub: lurek.pipeline.newPipeline
-- Create a named pipeline. Focus: newPipeline.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("build")
    print("name = " .. pipe:getName())
    pipe:setName("deploy")
    print("renamed = " .. pipe:getName())

    -- Running a pipeline with an initial context. Focus: newPipeline.
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("ctx-demo")
    pipe:addStep(lurek.pipeline.newStep("init", function(ctx)
        ctx.count = ctx.count + 1
    end))
    pipe:addStep(lurek.pipeline.newStep("double", function(ctx)
        ctx.count = ctx.count * 2
    end))
    local result = pipe:run({ count = 5 })
    print("success = " .. tostring(result.success))
    local ctx = pipe:getContext()
    print("final count = " .. ctx.count)
end

--@api-stub: LPipeline:getName
-- Create a named pipeline. Focus: getName.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("build")
    print("name = " .. pipe:getName())
    pipe:setName("deploy")
    print("renamed = " .. pipe:getName())
end

--@api-stub: LPipeline:setName
-- Create a named pipeline. Focus: setName.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("build")
    print("name = " .. pipe:getName())
    pipe:setName("deploy")
    print("renamed = " .. pipe:getName())
end

--@api-stub: lurek.pipeline.newStep
-- Create standalone steps. Focus: newStep.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
        print("compiling...")
    end)
    print("step name = " .. step:getName())
    print("status = " .. step:getStatus())

    -- Running a pipeline with an initial context. Focus: newStep.
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("ctx-demo")
    pipe:addStep(lurek.pipeline.newStep("init", function(ctx)
        ctx.count = ctx.count + 1
    end))
    pipe:addStep(lurek.pipeline.newStep("double", function(ctx)
        ctx.count = ctx.count * 2
    end))
    local result = pipe:run({ count = 5 })
    print("success = " .. tostring(result.success))
    local ctx = pipe:getContext()
    print("final count = " .. ctx.count)
end

--@api-stub: LPipelineStep:getName
-- Create standalone steps. Focus: getName.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("compile", function(ctx)
        ctx.compiled = true
        print("compiling...")
    end)
    print("step name = " .. step:getName())
    print("status = " .. step:getStatus())
end

--@api-stub: LPipeline:addStep
-- Add steps and run the pipeline synchronously.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("hello")
    local s1 = lurek.pipeline.newStep("greet", function(ctx)
        ctx.message = "hello world"
    end)
    local s2 = lurek.pipeline.newStep("print", function(ctx)
        print(ctx.message)
    end)
    s2:dependsOn("greet")
    pipe:addStep(s1)
    pipe:addStep(s2)
    local result = pipe:run({})
    print("success = " .. tostring(result.success))
    print("completed = " .. #result.completed)
end

--@api-stub: LPipelineStep:dependsOn
-- Step dependencies. Focus: dependsOn.
do
    ---@type LPipelineStep
    local fetch = lurek.pipeline.newStep("fetch", function(ctx)
        ctx.data = { 1, 2, 3 }
    end)
    ---@type LPipelineStep
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 0
        for _, v in ipairs(ctx.data) do
            ctx.total = ctx.total + v
        end
    end)
    ---@type LPipelineStep
    local report = lurek.pipeline.newStep("report", function(ctx)
        print("total = " .. ctx.total)
    end)
    parse:dependsOn("fetch")
    report:dependsOn("parse")
    print("parse deps = " .. parse:getDependencyCount())
    local deps = report:getDependencies()
    print("report depends on: " .. deps[1])
end

--@api-stub: LPipelineStep:getDependencies
-- Step dependencies. Focus: getDependencies.
do
    ---@type LPipelineStep
    local fetch = lurek.pipeline.newStep("fetch", function(ctx)
        ctx.data = { 1, 2, 3 }
    end)
    ---@type LPipelineStep
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 0
        for _, v in ipairs(ctx.data) do
            ctx.total = ctx.total + v
        end
    end)
    ---@type LPipelineStep
    local report = lurek.pipeline.newStep("report", function(ctx)
        print("total = " .. ctx.total)
    end)
    parse:dependsOn("fetch")
    report:dependsOn("parse")
    print("parse deps = " .. parse:getDependencyCount())
    local deps = report:getDependencies()
    print("report depends on: " .. deps[1])
end

--@api-stub: LPipelineStep:getDependencyCount
-- Step dependencies. Focus: getDependencyCount.
do
    ---@type LPipelineStep
    local fetch = lurek.pipeline.newStep("fetch", function(ctx)
        ctx.data = { 1, 2, 3 }
    end)
    ---@type LPipelineStep
    local parse = lurek.pipeline.newStep("parse", function(ctx)
        ctx.total = 0
        for _, v in ipairs(ctx.data) do
            ctx.total = ctx.total + v
        end
    end)
    ---@type LPipelineStep
    local report = lurek.pipeline.newStep("report", function(ctx)
        print("total = " .. ctx.total)
    end)
    parse:dependsOn("fetch")
    report:dependsOn("parse")
    print("parse deps = " .. parse:getDependencyCount())
    local deps = report:getDependencies()
    print("report depends on: " .. deps[1])
end

--@api-stub: LPipeline:getResult
-- Inspecting detailed results.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("results")
    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))
    pipe:run()
    local r = pipe:getResult()
    print("success = " .. tostring(r.success))
    print("completed = " .. table.concat(r.completed, ", "))
    print("failed count = " .. #r.failed)
    print("duration = " .. r.totalDuration)
end

--@api-stub: LPipeline:getStepCount
-- Querying steps. Focus: getStepCount.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("query")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))
    print("step count = " .. pipe:getStepCount())
    local steps = pipe:getSteps()
    for _, s in ipairs(steps) do
        print("  " .. s:getName())
    end
    local found = pipe:getStep("beta")
    print("found = " .. found:getName())
end

--@api-stub: LPipeline:getSteps
-- Querying steps. Focus: getSteps.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("query")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))
    print("step count = " .. pipe:getStepCount())
    local steps = pipe:getSteps()
    for _, s in ipairs(steps) do
        print("  " .. s:getName())
    end
    local found = pipe:getStep("beta")
    print("found = " .. found:getName())
end

--@api-stub: LPipeline:getStep
-- Querying steps. Focus: getStep.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("query")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    pipe:addStep(lurek.pipeline.newStep("gamma", function() end))
    print("step count = " .. pipe:getStepCount())
    local steps = pipe:getSteps()
    for _, s in ipairs(steps) do
        print("  " .. s:getName())
    end
    local found = pipe:getStep("beta")
    print("found = " .. found:getName())
end

--@api-stub: LPipeline:removeStep
-- Removing steps. Focus: removeStep.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("remove")
    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))
    print("before = " .. pipe:getStepCount())
    pipe:removeStep("b")
    print("after remove = " .. pipe:getStepCount())
    pipe:clear()
    print("after clear = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:clear
-- Removing steps. Focus: clear.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("remove")
    pipe:addStep(lurek.pipeline.newStep("a", function() end))
    pipe:addStep(lurek.pipeline.newStep("b", function() end))
    pipe:addStep(lurek.pipeline.newStep("c", function() end))
    print("before = " .. pipe:getStepCount())
    pipe:removeStep("b")
    print("after remove = " .. pipe:getStepCount())
    pipe:clear()
    print("after clear = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:getExecutionOrder
-- Get topological execution order.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("order")
    local s1 = lurek.pipeline.newStep("load", function() end)
    local s2 = lurek.pipeline.newStep("transform", function() end)
    local s3 = lurek.pipeline.newStep("save", function() end)
    s2:dependsOn("load")
    s3:dependsOn("transform")
    pipe:addStep(s1)
    pipe:addStep(s2)
    pipe:addStep(s3)
    local order, err = pipe:getExecutionOrder()
    if order then
        print("order: " .. table.concat(order, " -> "))
    else
        print("error: " .. err)
    end
end

--@api-stub: LPipeline:getParallelGroups
-- Group steps by execution tier.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("parallel")
    local fetch1 = lurek.pipeline.newStep("fetch_users", function() end)
    local fetch2 = lurek.pipeline.newStep("fetch_items", function() end)
    local merge = lurek.pipeline.newStep("merge", function() end)
    merge:dependsOn("fetch_users")
    merge:dependsOn("fetch_items")
    pipe:addStep(fetch1)
    pipe:addStep(fetch2)
    pipe:addStep(merge)
    local groups, err = pipe:getParallelGroups()
    if groups then
        print("tiers = " .. #groups)
        for i, group in ipairs(groups) do
            print("tier " .. i .. ": " .. tostring(group))
        end
    end
end

--@api-stub: LPipeline:validate
-- Validate pipeline structure.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("validate")
    local a = lurek.pipeline.newStep("a", function() end)
    local b = lurek.pipeline.newStep("b", function() end)
    b:dependsOn("missing_step")
    pipe:addStep(a)
    pipe:addStep(b)
    local valid, errors = pipe:validate()
    print("valid = " .. tostring(valid))
    if #errors > 0 then
        for _, e in ipairs(errors) do
            print("  error: " .. e)
        end
    end
end

--@api-stub: LPipeline:setErrorMode
-- Error modes: abort vs continue. Focus: setErrorMode.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("error-mode")
    pipe:setErrorMode("continue")
    print("mode = " .. pipe:getErrorMode())
    pipe:addStep(lurek.pipeline.newStep("fail", function()
        error("oops")
    end))
    pipe:addStep(lurek.pipeline.newStep("after", function(ctx)
        ctx.reached = true
    end))
    local result = pipe:run()
    print("success = " .. tostring(result.success))
    print("failed = " .. #result.failed)
    print("completed = " .. #result.completed)
end

--@api-stub: LPipeline:getErrorMode
-- Error modes: abort vs continue. Focus: getErrorMode.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("error-mode")
    pipe:setErrorMode("continue")
    print("mode = " .. pipe:getErrorMode())
    pipe:addStep(lurek.pipeline.newStep("fail", function()
        error("oops")
    end))
    pipe:addStep(lurek.pipeline.newStep("after", function(ctx)
        ctx.reached = true
    end))
    local result = pipe:run()
    print("success = " .. tostring(result.success))
    print("failed = " .. #result.failed)
    print("completed = " .. #result.completed)
end

--@api-stub: LPipeline:toAscii
-- ASCII visualization of the pipeline graph.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("graph")
    local a = lurek.pipeline.newStep("init", function() end)
    local b = lurek.pipeline.newStep("process", function() end)
    local c = lurek.pipeline.newStep("finish", function() end)
    b:dependsOn("init")
    c:dependsOn("process")
    pipe:addStep(a)
    pipe:addStep(b)
    pipe:addStep(c)
    print(pipe:toAscii())
end

--@api-stub: LPipeline:toTable
-- Serialize and deserialize pipelines. Focus: toTable.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("serialize")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    local tbl = pipe:toTable()
    print("table name = " .. tbl.name)
    print("steps = " .. #tbl.steps)
    ---@type LPipeline
    local pipe2 = lurek.pipeline.fromTable({
        name = "from-table",
        errorMode = "abort",
        steps = {
            { name = "x", fn = function() print("x runs") end },
            { name = "y", deps = { "x" }, fn = function() print("y runs") end },
        }
    })
    pipe2:run()
end

--@api-stub: LPipeline:fromTable
-- Serialize and deserialize pipelines. Focus: fromTable.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("serialize")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end))
    pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    local tbl = pipe:toTable()
    print("table name = " .. tbl.name)
    print("steps = " .. #tbl.steps)
    ---@type LPipeline
    local pipe2 = lurek.pipeline.fromTable({
        name = "from-table",
        errorMode = "abort",
        steps = {
            { name = "x", fn = function() print("x runs") end },
            { name = "y", deps = { "x" }, fn = function() print("y runs") end },
        }
    })
    pipe2:run()
end

--@api-stub: LPipeline:reset
-- Reset pipeline for re-run.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("rerun")
    pipe:addStep(lurek.pipeline.newStep("count", function(ctx)
        ctx.n = (ctx.n or 0) + 1
    end))
    pipe:run()
    local ctx1 = pipe:getContext()
    print("first run n = " .. ctx1.n)
    pipe:reset()
    pipe:run()
    local ctx2 = pipe:getContext()
    print("second run n = " .. ctx2.n)
end

--@api-stub: LPipeline:type
-- Type checking. Focus: type.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("typed")
    print("type = " .. pipe:type())
    print("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")))
    print("is Object = " .. tostring(pipe:typeOf("Object")))
end

--@api-stub: LPipeline:typeOf
-- Type checking. Focus: typeOf.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("typed")
    print("type = " .. pipe:type())
    print("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")))
    print("is Object = " .. tostring(pipe:typeOf("Object")))
end

--- Pipeline Module Part 2: step config, async execution, callbacks, sub-pipelines, branching, tags


--@api-stub: LPipelineStep:setCallback
-- Step callback and conditions. Focus: setCallback.
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

--@api-stub: LPipelineStep:setCondition
-- Step callback and conditions. Focus: setCondition.
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
-- Retry configuration. Focus: setRetryCount.
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

--@api-stub: LPipelineStep:getRetryCount
-- Retry configuration. Focus: getRetryCount.
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

--@api-stub: LPipelineStep:setRetryDelay
-- Retry configuration. Focus: setRetryDelay.
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

--@api-stub: LPipelineStep:getAttempt
-- Retry configuration. Focus: getAttempt.
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
-- Step delay. Focus: setDelay.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)
    step:setDelay(0.5)
    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:getDelay
-- Step delay. Focus: getDelay.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("delayed", function(ctx)
        ctx.time = "after delay"
    end)
    step:setDelay(0.5)
    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:setTimeout
-- Step timeout. Focus: setTimeout.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("slow", function()
        print("running slow task")
    end)
    step:setTimeout(5.0)
    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:getTimeout
-- Step timeout. Focus: getTimeout.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("slow", function()
        print("running slow task")
    end)
    step:setTimeout(5.0)
    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:setOptional
-- Optional steps (don't fail the pipeline). Focus: setOptional.
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

--@api-stub: LPipelineStep:isOptional
-- Optional steps (don't fail the pipeline). Focus: isOptional.
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
-- Step tagging and filtering. Focus: setTag.
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

--@api-stub: LPipelineStep:getTag
-- Step tagging and filtering. Focus: getTag.
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

--@api-stub: LPipeline:getStepsByTag
-- Step tagging and filtering. Focus: getStepsByTag.
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
-- Step metadata. Focus: setData.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("meta", function() end)
    step:setData("version", "1.2.0")
    step:setData("author", "engine")
    print("version = " .. step:getData("version"))
    print("author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:getData
-- Step metadata. Focus: getData.
do
    ---@type LPipelineStep
    local step = lurek.pipeline.newStep("meta", function() end)
    step:setData("version", "1.2.0")
    step:setData("author", "engine")
    print("version = " .. step:getData("version"))
    print("author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:setAsync
-- Async step configuration. Focus: setAsync.
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

--@api-stub: LPipelineStep:isAsync
-- Async step configuration. Focus: isAsync.
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
-- Step error handling. Focus: setOnError.
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

--@api-stub: LPipelineStep:getError
-- Step error handling. Focus: getError.
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
-- Step status and timing. Focus: getStatus.
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

--@api-stub: LPipelineStep:getDuration
-- Step status and timing. Focus: getDuration.
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
-- Async pipeline execution (coroutine-driven). Focus: runAsync.
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

--@api-stub: LPipeline:update
-- Async pipeline execution (coroutine-driven). Focus: update.
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

--@api-stub: LPipeline:isRunning
-- Async pipeline execution (coroutine-driven). Focus: isRunning.
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

--@api-stub: LPipeline:isComplete
-- Async pipeline execution (coroutine-driven). Focus: isComplete.
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
-- Progress and event callbacks. Focus: onProgress.
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

--@api-stub: LPipeline:onEvent
-- Progress and event callbacks. Focus: onEvent.
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
-- Pipeline lifecycle callbacks. Focus: setOnComplete.
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

--@api-stub: LPipeline:setOnStepComplete
-- Pipeline lifecycle callbacks. Focus: setOnStepComplete.
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

--@api-stub: LPipeline:setOnStepError
-- Pipeline lifecycle callbacks. Focus: setOnStepError.
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

--- Pipeline Module Part 2: pipeline run, getContext, fromTable


--@api-stub: LPipeline:getContext
-- Pipeline execution and context retrieval. Focus: getContext.
do
    local pl = lurek.pipeline.newPipeline("my_pipeline")
    local step1 = lurek.pipeline.newStep("load", function(ctx) ctx.loaded = true end)
    local step2 = lurek.pipeline.newStep("process", function(ctx)
        ctx.result = 42
    end)
    pl:addStep(step1)
    pl:addStep(step2)
    pl:run({ debug = false })
    local ctx = pl:getContext()
    print("result=" .. tostring(ctx.result))
end

--@api-stub: LPipeline:run
-- Pipeline execution and context retrieval. Focus: run.
do
    local pl = lurek.pipeline.newPipeline("my_pipeline")
    local step1 = lurek.pipeline.newStep("load", function(ctx) ctx.loaded = true end)
    local step2 = lurek.pipeline.newStep("process", function(ctx)
        ctx.result = 42
    end)
    pl:addStep(step1)
    pl:addStep(step2)
    pl:run({ debug = false })
    local ctx = pl:getContext()
    print("result=" .. tostring(ctx.result))
end

--@api-stub: lurek.pipeline.fromTable
-- Build a pipeline from a table definition.
do
    local pl = lurek.pipeline.fromTable({
        name = "test_pipeline",
        steps = {
            { name = "init", fn = function(ctx) ctx.x = 1 end },
            { name = "done", fn = function(ctx) ctx.y = 2 end },
        }
    })
    pl:run({})
    local ctx = pl:getContext()
    print("ctx=" .. tostring(ctx ~= nil))
end

print("content/examples/pipeline.lua")
