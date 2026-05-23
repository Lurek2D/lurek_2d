-- content/examples/pipeline.lua
-- Auto-generated from content/examples2/pipeline_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/pipeline.lua

--- Pipeline Module Part 1: creating pipelines, steps, dependencies, running, results

--@api-stub: lurek.pipeline.newPipeline
do
    local pipe = lurek.pipeline.newPipeline("build")
    print("name = " .. pipe:getName())
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
    local step = lurek.pipeline.newStep("compile", function(ctx) ctx.compiled = true end)
    print("step name = " .. step:getName())
end

--@api-stub: LPipelineStep:getName
do
    local step = lurek.pipeline.newStep("compile", function(ctx) ctx.compiled = true end)
    print("step name = " .. step:getName())
end

--@api-stub: LPipeline:addStep
do
    local pipe = lurek.pipeline.newPipeline("hello")
    local s1, s2 = lurek.pipeline.newStep("greet", function(ctx) ctx.message = "hello world" end), lurek.pipeline.newStep("print", function(ctx) print(ctx.message) end)
    s2:dependsOn("greet"); pipe:addStep(s1); pipe:addStep(s2)
    local result = pipe:run({})
    print("success = " .. tostring(result.success) .. ", completed = " .. #result.completed)
end

--@api-stub: LPipelineStep:dependsOn
do
    local fetch = lurek.pipeline.newStep("fetch", function(ctx) ctx.data = { 1, 2, 3 } end)
    local parse = lurek.pipeline.newStep("parse", function(ctx) ctx.total = (ctx.data and ctx.data[1] or 0) + (ctx.data and ctx.data[2] or 0) + (ctx.data and ctx.data[3] or 0) end)
    parse:dependsOn("fetch")
    print("parse deps = " .. parse:getDependencyCount())
end

--@api-stub: LPipelineStep:getDependencies
do
    local report = lurek.pipeline.newStep("report", function(ctx) ctx.reported = ctx.total end)
    report:dependsOn("parse")
    local deps = report:getDependencies()
    print("report depends on: " .. deps[1])
end

--@api-stub: LPipelineStep:getDependencyCount
do
    local parse = lurek.pipeline.newStep("parse", function(ctx) ctx.total = 6 end)
    parse:dependsOn("fetch")
    print("parse deps = " .. parse:getDependencyCount())
end

--@api-stub: LPipeline:getResult
do
    local pipe = lurek.pipeline.newPipeline("results")
    pipe:addStep(lurek.pipeline.newStep("a", function() end)); pipe:addStep(lurek.pipeline.newStep("b", function() end)); pipe:addStep(lurek.pipeline.newStep("c", function() end))
    pipe:run()
    local r = pipe:getResult()
    print("success = " .. tostring(r.success) .. ", completed = " .. table.concat(r.completed, ", "))
end

--@api-stub: LPipeline:getStepCount
do
    local pipe = lurek.pipeline.newPipeline("query")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end)); pipe:addStep(lurek.pipeline.newStep("beta", function() end)); pipe:addStep(lurek.pipeline.newStep("gamma", function() end))
    print("step count = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:getSteps
do
    local pipe = lurek.pipeline.newPipeline("query")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end)); pipe:addStep(lurek.pipeline.newStep("beta", function() end)); pipe:addStep(lurek.pipeline.newStep("gamma", function() end))
    local steps = pipe:getSteps()
    print("steps = " .. steps[1]:getName() .. ", " .. steps[2]:getName() .. ", " .. steps[3]:getName())
end

--@api-stub: LPipeline:getStep
do
    local pipe = lurek.pipeline.newPipeline("query")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end)); pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    local found = pipe:getStep("beta")
    print("found = " .. (found and found:getName() or "nil"))
end

--@api-stub: LPipeline:removeStep
do
    local pipe = lurek.pipeline.newPipeline("remove")
    pipe:addStep(lurek.pipeline.newStep("a", function() end)); pipe:addStep(lurek.pipeline.newStep("b", function() end)); pipe:addStep(lurek.pipeline.newStep("c", function() end))
    pipe:removeStep("b")
    print("after remove = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:clear
do
    local pipe = lurek.pipeline.newPipeline("remove")
    pipe:addStep(lurek.pipeline.newStep("a", function() end)); pipe:addStep(lurek.pipeline.newStep("b", function() end)); pipe:addStep(lurek.pipeline.newStep("c", function() end))
    pipe:clear()
    print("after clear = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:getExecutionOrder
do
    local pipe = lurek.pipeline.newPipeline("order")
    local s1, s2, s3 = lurek.pipeline.newStep("load", function() end), lurek.pipeline.newStep("transform", function() end), lurek.pipeline.newStep("save", function() end)
    s2:dependsOn("load"); s3:dependsOn("transform"); pipe:addStep(s1); pipe:addStep(s2); pipe:addStep(s3)
    local order, err = pipe:getExecutionOrder()
    print(order and ("order: " .. table.concat(order, " -> ")) or ("error: " .. tostring(err)))
end

--@api-stub: LPipeline:getParallelGroups
do
    local pipe = lurek.pipeline.newPipeline("parallel")
    local fetch1, fetch2, merge = lurek.pipeline.newStep("fetch_users", function() end), lurek.pipeline.newStep("fetch_items", function() end), lurek.pipeline.newStep("merge", function() end)
    merge:dependsOn("fetch_users"); merge:dependsOn("fetch_items"); pipe:addStep(fetch1); pipe:addStep(fetch2); pipe:addStep(merge)
    local groups = pipe:getParallelGroups()
    print("tiers = " .. #(groups or {}))
end

--@api-stub: LPipeline:validate
do
    local pipe = lurek.pipeline.newPipeline("validate")
    local a, b = lurek.pipeline.newStep("a", function() end), lurek.pipeline.newStep("b", function() end)
    b:dependsOn("missing_step"); pipe:addStep(a); pipe:addStep(b)
    local valid, errors = pipe:validate()
    print("valid = " .. tostring(valid) .. ", errors = " .. #(errors or {}))
end

--@api-stub: LPipeline:setErrorMode
do
    local pipe = lurek.pipeline.newPipeline("error-mode")
    pipe:setErrorMode("continue"); pipe:addStep(lurek.pipeline.newStep("fail", function() error("oops") end)); pipe:addStep(lurek.pipeline.newStep("after", function(ctx) ctx.reached = true end))
    local result = pipe:run()
    print("mode = " .. pipe:getErrorMode() .. ", failed = " .. #result.failed)
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
    local a, b, c = lurek.pipeline.newStep("init", function() end), lurek.pipeline.newStep("process", function() end), lurek.pipeline.newStep("finish", function() end)
    b:dependsOn("init"); c:dependsOn("process"); pipe:addStep(a); pipe:addStep(b); pipe:addStep(c)
    print(pipe:toAscii())
end

--@api-stub: LPipeline:toTable
do
    local pipe = lurek.pipeline.newPipeline("serialize")
    pipe:addStep(lurek.pipeline.newStep("alpha", function() end)); pipe:addStep(lurek.pipeline.newStep("beta", function() end))
    local tbl = pipe:toTable()
    print("table name = " .. tbl.name .. ", steps = " .. #tbl.steps)
end

--@api-stub: LPipeline:fromTable
do
    local pipe = lurek.pipeline.fromTable({ name = "from-table", errorMode = "abort", steps = { { name = "x", fn = function() print("x runs") end }, { name = "y", deps = { "x" }, fn = function() print("y runs") end } } })
    pipe:run()
    print("steps = " .. pipe:getStepCount())
end

--@api-stub: LPipeline:reset
do
    local pipe = lurek.pipeline.newPipeline("rerun")
    pipe:addStep(lurek.pipeline.newStep("count", function(ctx) ctx.n = (ctx.n or 0) + 1 end))
    local ctx1 = {}; pipe:run(ctx1); pipe:reset(); local ctx2 = {}; pipe:run(ctx2)
    print("first = " .. tostring(ctx1.n) .. ", second = " .. tostring(ctx2.n))
end

--@api-stub: LPipeline:type
do
    local pipe = lurek.pipeline.newPipeline("typed")
    print("type = " .. pipe:type())
end

--@api-stub: LPipeline:typeOf
do
    local pipe = lurek.pipeline.newPipeline("typed")
    print("is LPipeline = " .. tostring(pipe:typeOf("LPipeline")) .. ", is Object = " .. tostring(pipe:typeOf("LObject")))
end

--- Pipeline Module Part 2: step config, async execution, callbacks, sub-pipelines, branching, tags

--@api-stub: LPipelineStep:setCallback
do
    local step = lurek.pipeline.newStep("conditional")
    step:setCallback(function(ctx) ctx.ran = true end); step:setCondition(function(ctx) return ctx.shouldRun == true end)
    local pipe = lurek.pipeline.newPipeline("cond-test"); pipe:addStep(step)
    local result = pipe:run({ shouldRun = true })
    print("completed = " .. #result.completed)
end

--@api-stub: LPipelineStep:setCondition
do
    local step = lurek.pipeline.newStep("conditional")
    step:setCallback(function(ctx) ctx.ran = true end); step:setCondition(function(ctx) return ctx.shouldRun == true end)
    local pipe = lurek.pipeline.newPipeline("cond-test"); pipe:addStep(step)
    local result = pipe:run({ shouldRun = false })
    print("skipped = " .. #result.skipped)
end

--@api-stub: LPipelineStep:setRetryCount
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function() attempts = attempts + 1; if attempts < 3 then error("failed attempt " .. attempts) end end)
    step:setRetryCount(5); step:setRetryDelay(0.01); local pipe = lurek.pipeline.newPipeline("retry"); pipe:addStep(step); pipe:run()
    print("retry count = " .. step:getRetryCount() .. ", attempt = " .. step:getAttempt())
end

--@api-stub: LPipelineStep:getRetryCount
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function() attempts = attempts + 1; if attempts < 3 then error("failed attempt " .. attempts) end end)
    step:setRetryCount(5); step:setRetryDelay(0.01); local pipe = lurek.pipeline.newPipeline("retry"); pipe:addStep(step); pipe:run()
    print("retry count = " .. step:getRetryCount())
end

--@api-stub: LPipelineStep:setRetryDelay
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function() attempts = attempts + 1; if attempts < 3 then error("failed attempt " .. attempts) end end)
    step:setRetryCount(5); step:setRetryDelay(0.01); local pipe = lurek.pipeline.newPipeline("retry"); pipe:addStep(step); pipe:run()
    print("retry delay set, attempt = " .. step:getAttempt())
end

--@api-stub: LPipelineStep:getAttempt
do
    local attempts = 0
    local step = lurek.pipeline.newStep("flaky", function() attempts = attempts + 1; if attempts < 3 then error("failed attempt " .. attempts) end end)
    step:setRetryCount(5); step:setRetryDelay(0.01); local pipe = lurek.pipeline.newPipeline("retry"); pipe:addStep(step); pipe:run()
    print("attempt = " .. step:getAttempt())
end

--@api-stub: LPipelineStep:setDelay
do
    local step = lurek.pipeline.newStep("delayed", function(ctx) ctx.time = "after delay" end)
    step:setDelay(0.5)
    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:getDelay
do
    local step = lurek.pipeline.newStep("delayed", function(ctx) ctx.time = "after delay" end)
    step:setDelay(0.5)
    print("delay = " .. step:getDelay())
end

--@api-stub: LPipelineStep:setTimeout
do
    local step = lurek.pipeline.newStep("slow", function() print("running slow task") end)
    step:setTimeout(5.0)
    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:getTimeout
do
    local step = lurek.pipeline.newStep("slow", function() print("running slow task") end)
    step:setTimeout(5.0)
    print("timeout = " .. step:getTimeout())
end

--@api-stub: LPipelineStep:setOptional
do
    local pipe = lurek.pipeline.newPipeline("optional")
    local opt, required = lurek.pipeline.newStep("optional-step", function() error("this is fine") end), lurek.pipeline.newStep("required", function(ctx) ctx.done = true end)
    opt:setOptional(true); pipe:addStep(opt); pipe:addStep(required)
    local result = pipe:run()
    print("optional = " .. tostring(opt:isOptional()) .. ", completed = " .. #result.completed)
end

--@api-stub: LPipelineStep:isOptional
do
    local step = lurek.pipeline.newStep("optional-step", function() error("this is fine") end)
    step:setOptional(true)
    print("optional = " .. tostring(step:isOptional()))
end

--@api-stub: LPipelineStep:setTag
do
    local pipe = lurek.pipeline.newPipeline("tags")
    local s1, s2, s3 = lurek.pipeline.newStep("load_a", function() end), lurek.pipeline.newStep("load_b", function() end), lurek.pipeline.newStep("compute", function() end)
    s1:setTag("io"); s2:setTag("io"); s3:setTag("cpu"); pipe:addStep(s1); pipe:addStep(s2); pipe:addStep(s3)
    print("s1 tag = " .. s1:getTag() .. ", io steps = " .. #pipe:getStepsByTag("io"))
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
    local s1, s2, s3 = lurek.pipeline.newStep("load_a", function() end), lurek.pipeline.newStep("load_b", function() end), lurek.pipeline.newStep("compute", function() end)
    s1:setTag("io"); s2:setTag("io"); s3:setTag("cpu"); pipe:addStep(s1); pipe:addStep(s2); pipe:addStep(s3)
    print("io steps = " .. #pipe:getStepsByTag("io") .. ", cpu steps = " .. #pipe:getStepsByTag("cpu"))
end

--@api-stub: LPipelineStep:setData
do
    local step = lurek.pipeline.newStep("meta", function() end)
    step:setData("version", "1.2.0"); step:setData("author", "engine")
    print("version = " .. step:getData("version") .. ", author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:getData
do
    local step = lurek.pipeline.newStep("meta", function() end)
    step:setData("version", "1.2.0"); step:setData("author", "engine")
    print("author = " .. step:getData("author"))
end

--@api-stub: LPipelineStep:setAsync
do
    local step = lurek.pipeline.newStep("async-step", function(ctx) ctx.progress = 1 end)
    step:setAsync(true)
    print("is async = " .. tostring(step:isAsync()))
end

--@api-stub: LPipelineStep:isAsync
do
    local step = lurek.pipeline.newStep("async-step", function(ctx) ctx.progress = 1 end)
    step:setAsync(true)
    print("is async = " .. tostring(step:isAsync()))
end

--@api-stub: LPipelineStep:setOnError
do
    local errorMsg = ""
    local step = lurek.pipeline.newStep("risky", function() error("something broke") end)
    step:setOnError(function(name, msg) errorMsg = name .. ":" .. msg end); local pipe = lurek.pipeline.newPipeline("errors"); pipe:setErrorMode("continue"); pipe:addStep(step); pipe:run()
    print("error = " .. tostring(step:getError() or errorMsg))
end

--@api-stub: LPipelineStep:getError
do
    local step = lurek.pipeline.newStep("risky", function() error("something broke") end)
    step:setOnError(function() end); local pipe = lurek.pipeline.newPipeline("errors"); pipe:setErrorMode("continue"); pipe:addStep(step); pipe:run()
    print("step error = " .. tostring(step:getError()))
end

--@api-stub: LPipelineStep:getStatus
do
    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx) ctx.done = true end)
    pipe:addStep(step); print("before run: " .. step:getStatus()); pipe:run()
    print("after run: " .. step:getStatus())
end

--@api-stub: LPipelineStep:getDuration
do
    local pipe = lurek.pipeline.newPipeline("status")
    local step = lurek.pipeline.newStep("work", function(ctx) ctx.done = true end)
    pipe:addStep(step); pipe:run()
    print("duration = " .. tostring(step:getDuration()))
end

--@api-stub: LPipeline:runAsync
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local s1, s2 = lurek.pipeline.newStep("phase1", function(ctx) ctx.phase = 1 end), lurek.pipeline.newStep("phase2", function(ctx) ctx.phase = 2 end)
    s1:setAsync(true); s2:setAsync(true); s2:dependsOn("phase1"); pipe:addStep(s1); pipe:addStep(s2); pipe:runAsync(); pipe:update(1 / 60)
    print("phase = " .. tostring(pipe:getContext().phase))
end

--@api-stub: LPipeline:update
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local s1, s2 = lurek.pipeline.newStep("phase1", function(ctx) ctx.phase = 1 end), lurek.pipeline.newStep("phase2", function(ctx) ctx.phase = 2 end)
    s1:setAsync(true); s2:setAsync(true); s2:dependsOn("phase1"); pipe:addStep(s1); pipe:addStep(s2); pipe:runAsync(); pipe:update(1 / 60)
    print("running = " .. tostring(pipe:isRunning()))
end

--@api-stub: LPipeline:isRunning
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function() coroutine.yield() end)
    step:setAsync(true); pipe:addStep(step); pipe:runAsync()
    print("running = " .. tostring(pipe:isRunning()))
end

--@api-stub: LPipeline:isComplete
do
    local pipe = lurek.pipeline.newPipeline("async-pipe")
    local step = lurek.pipeline.newStep("phase1", function(ctx) ctx.done = true end)
    step:setAsync(true); pipe:addStep(step); pipe:runAsync(); pipe:update(1 / 60)
    print("complete = " .. tostring(pipe:isComplete()))
end

--@api-stub: LPipeline:cancel
do
    local pipe = lurek.pipeline.newPipeline("cancel")
    local step = lurek.pipeline.newStep("a", function() coroutine.yield() end)
    step:setAsync(true); pipe:addStep(step); pipe:runAsync(); pipe:update(1 / 60); pipe:cancel()
    print("cancelled = " .. #pipe:getResult().cancelled)
end

--@api-stub: LPipeline:onProgress
do
    local pipe, progressLog = lurek.pipeline.newPipeline("callbacks"), {}
    pipe:addStep(lurek.pipeline.newStep("a", function() end)); pipe:addStep(lurek.pipeline.newStep("b", function() end)); pipe:onProgress(function(stepName, status) progressLog[#progressLog + 1] = stepName .. "=" .. status end)
    pipe:run()
    print("progress: " .. table.concat(progressLog, ", "))
end

--@api-stub: LPipeline:onEvent
do
    local pipe, eventCount = lurek.pipeline.newPipeline("callbacks"), 0
    pipe:addStep(lurek.pipeline.newStep("a", function() end)); pipe:onEvent(function() eventCount = eventCount + 1 end)
    pipe:run()
    print("events = " .. tostring(eventCount > 0))
end

--@api-stub: LPipeline:setOnComplete
do
    local pipe, summary = lurek.pipeline.newPipeline("lifecycle"), ""
    pipe:addStep(lurek.pipeline.newStep("ok", function() end)); pipe:setOnComplete(function(result) summary = tostring(result.success) end)
    pipe:run()
    print("complete = " .. summary)
end

--@api-stub: LPipeline:setOnStepComplete
do
    local pipe, completedSteps = lurek.pipeline.newPipeline("lifecycle"), {}
    pipe:addStep(lurek.pipeline.newStep("ok", function() end)); pipe:setOnStepComplete(function(stepName) completedSteps[#completedSteps + 1] = stepName end)
    pipe:run()
    print("completed: " .. table.concat(completedSteps, ", "))
end

--@api-stub: LPipeline:setOnStepError
do
    local pipe, failedSteps = lurek.pipeline.newPipeline("lifecycle"), {}
    pipe:addStep(lurek.pipeline.newStep("fail", function() error("bad") end)); pipe:setErrorMode("continue"); pipe:setOnStepError(function(stepName) failedSteps[#failedSteps + 1] = stepName end)
    pipe:run()
    print("failed: " .. table.concat(failedSteps, ", "))
end

--@api-stub: LPipeline:addSubPipeline
do
    local sub = lurek.pipeline.newPipeline("sub")
    sub:addStep(lurek.pipeline.newStep("fetch", function(ctx) ctx.fetched = true end)); sub:addStep(lurek.pipeline.newStep("parse", function(ctx) ctx.parsed = true end))
    local main = lurek.pipeline.newPipeline("main")
    main:addStep(lurek.pipeline.newStep("init", function(ctx) ctx.started = true end)); main:addSubPipeline(sub, "data", { "init" }); main:addStep(lurek.pipeline.newStep("done", function(ctx) ctx.finished = true end))
    print("steps = " .. main:getStepCount() .. ", success = " .. tostring(main:run().success))
end

--@api-stub: LPipeline:addConditional
do
    local pipe = lurek.pipeline.newPipeline("conditional")
    pipe:addStep(lurek.pipeline.newStep("check", function(ctx) ctx.needsUpgrade = true end))
    pipe:addConditional("upgrade", { "check" }, function(ctx) ctx.upgraded = true end, function(ctx) return ctx.needsUpgrade == true end)
    pipe:run()
    print("upgraded = " .. tostring(pipe:getContext().upgraded))
end

--@api-stub: LPipeline:addBranch
do
    local pipe = lurek.pipeline.newPipeline("branch")
    pipe:addStep(lurek.pipeline.newStep("load", function(ctx) ctx.format = "json" end))
    pipe:addBranch("route", { "load" }, function(ctx) return ctx.format == "json" end, function(ctx) ctx.parser = "json_parser" end, function(ctx) ctx.parser = "xml_parser" end)
    pipe:run()
    print("parser = " .. tostring(pipe:getContext().parser))
end

--@api-stub: LPipelineStep:type
do
    local step = lurek.pipeline.newStep("typed", function() end)
    print("type = " .. step:type())
end

--@api-stub: LPipelineStep:typeOf
do
    local step = lurek.pipeline.newStep("typed", function() end)
    print("is LPipelineStep = " .. tostring(step:typeOf("LPipelineStep")) .. ", is Object = " .. tostring(step:typeOf("LObject")))
end

--- Pipeline Module Part 2: pipeline run, getContext, fromTable

--@api-stub: LPipeline:getContext
do
    local pl = lurek.pipeline.newPipeline("my_pipeline")
    pl:addStep(lurek.pipeline.newStep("load", function(ctx) ctx.loaded = true end)); pl:addStep(lurek.pipeline.newStep("process", function(ctx) ctx.result = 42 end))
    pl:run({ debug = false })
    print("result=" .. tostring(pl:getContext().result))
end

--@api-stub: LPipeline:run
do
    local pl = lurek.pipeline.newPipeline("my_pipeline")
    pl:addStep(lurek.pipeline.newStep("load", function(ctx) ctx.loaded = true end)); pl:addStep(lurek.pipeline.newStep("process", function(ctx) ctx.result = 42 end))
    print("success=" .. tostring(pl:run({ debug = false }).success))
end

--@api-stub: lurek.pipeline.fromTable
do
    local pl = lurek.pipeline.fromTable({ name = "test_pipeline", steps = { { name = "init", fn = function(ctx) ctx.x = 1 end }, { name = "done", fn = function(ctx) ctx.y = 2 end } } })
    pl:run({})
    print("ctx=" .. tostring(pl:getContext() ~= nil))
end

print("content/examples/pipeline.lua")
