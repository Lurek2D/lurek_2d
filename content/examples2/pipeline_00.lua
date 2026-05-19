--- Pipeline Module Part 1: creating pipelines, steps, dependencies, running, results

--@api-stub: lurek.pipeline.newPipeline
--@api-stub: LPipeline:getName
--@api-stub: LPipeline:setName
-- Create a named pipeline.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("build")
    print("name = " .. pipe:getName())
    pipe:setName("deploy")
    print("renamed = " .. pipe:getName())
end

--@api-stub: lurek.pipeline.newStep
--@api-stub: LPipelineStep:getName
-- Create standalone steps.
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
--@api-stub: LPipeline:run (basic)
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
    local result = pipe:run()
    print("success = " .. tostring(result.success))
    print("completed = " .. #result.completed)
end

--@api-stub: LPipelineStep:dependsOn
--@api-stub: LPipelineStep:getDependencies
--@api-stub: LPipelineStep:getDependencyCount
-- Step dependencies.
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

--@api-stub: LPipeline:run with context
-- Running a pipeline with an initial context.
do
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

--@api-stub: LPipeline:getResult
--@api-stub: LPipeline:result fields
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
--@api-stub: LPipeline:getSteps
--@api-stub: LPipeline:getStep
-- Querying steps.
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
--@api-stub: LPipeline:clear
-- Removing steps.
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
--@api-stub: LPipeline:getErrorMode
-- Error modes: abort vs continue.
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
--@api-stub: LPipeline:fromTable
-- Serialize and deserialize pipelines.
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
--@api-stub: LPipeline:typeOf
-- Type checking.
do
    ---@type LPipeline
    local pipe = lurek.pipeline.newPipeline("typed")
    print("type = " .. pipe:type())
    print("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")))
    print("is Object = " .. tostring(pipe:typeOf("Object")))
end

print("pipeline_00.lua")
