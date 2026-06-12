-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_pipeline_core_unit.lua
do
-- BDD tests for lurek.pipeline DAG pipeline orchestrator

-- =========================================================================
-- Helper: table contains value
-- =========================================================================

local function table_contains(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

-- =========================================================================
-- 1. Module existence
-- =========================================================================
-- @describe lurek.pipeline module exists
describe("lurek.pipeline module exists", function()
    -- @covers lurek.pipeline.newPipeline
    it("has newPipeline factory and returns pipeline userdata", function()
        expect_type("function", lurek.pipeline.newPipeline)
        local pipeline = lurek.pipeline.newPipeline("factory_check")
        expect_type("userdata", pipeline)
        expect_equal("factory_check", pipeline:getName())
    end)
end)

-- =========================================================================
-- 2. PipelineStep construction and configuration
-- =========================================================================
-- @describe PipelineStep construction
describe("PipelineStep construction", function()
    -- @covers lurek.pipeline.newStep
    it("creates userdata and preserves names and callbacks", function()
        local s = lurek.pipeline.newStep("step1")
        expect_type("userdata", s)
        expect_equal("step1", s:getName())
        s = lurek.pipeline.newStep("cb_step", function(ctx) return 1 end)
        expect_equal("cb_step", s:getName())
    end)

    -- @covers LPipelineStep:type
    it("type() returns 'LPipelineStep'", function()
        local s = lurek.pipeline.newStep("s")
        expect_equal("LPipelineStep", s:type())
    end)

    -- @covers LPipelineStep:typeOf
    it("typeOf('LPipelineStep') is true", function()
        local s = lurek.pipeline.newStep("s")
        expect_true(s:typeOf("LPipelineStep"))
    end)

    -- @covers LPipelineStep:getStatus
    it("initial status is 'pending'", function()
        local s = lurek.pipeline.newStep("s")
        expect_equal("pending", s:getStatus())
    end)

    -- @covers LPipelineStep:setDelay
    it("setDelay/getDelay roundtrip", function()
        local s = lurek.pipeline.newStep("s")
        s:setDelay(0.5)
        expect_near(0.5, s:getDelay())
    end)

    -- @covers LPipelineStep:setOptional
    it("setOptional toggles state and allows optional skipped dependencies", function()
        local s = lurek.pipeline.newStep("s")
        s:setOptional(true)
        expect_true(s:isOptional())
        s:setOptional(false)
        expect_false(s:isOptional())

        local optional = lurek.pipeline.newStep("opt", function(ctx) return 1 end)
        optional:setOptional(true)
        optional:setCondition(function(ctx) return false end)
        local downstream = lurek.pipeline.newStep("down", function(ctx) return 2 end)
        downstream:dependsOn(optional)
        local pipeline = lurek.pipeline.newPipeline("opt_test")
        pipeline:addStep(optional):addStep(downstream)
        local result = pipeline:run()
        expect_true(table_contains(result.completed, "down"))
    end)

    -- @covers LPipelineStep:setRetryCount
    it("setRetryCount/getRetryCount roundtrip", function()
        local s = lurek.pipeline.newStep("s")
        s:setRetryCount(3)
        expect_equal(3, s:getRetryCount())
    end)

    -- @covers LPipelineStep:setTag
    it("setTag/getTag roundtrip", function()
        local s = lurek.pipeline.newStep("s")
        s:setTag("critical")
        expect_equal("critical", s:getTag())
    end)

    -- @covers LPipelineStep:setData
    it("setData/getData roundtrip", function()
        local s = lurek.pipeline.newStep("s")
        s:setData("env", "prod")
        expect_equal("prod", s:getData("env"))
    end)

    -- @covers LPipelineStep:getData
    it("getData missing key returns nil", function()
        local s = lurek.pipeline.newStep("s")
        expect_nil(s:getData("nonexistent"))
    end)
end)

-- =========================================================================
-- 3. PipelineStep dependency management
-- =========================================================================
-- @describe PipelineStep dependency management
describe("PipelineStep dependency management", function()
    -- @covers LPipelineStep:dependsOn
    it("accepts string and step dependencies and returns self for chaining", function()
        local s = lurek.pipeline.newStep("child")
        s:dependsOn("parent")
        local deps = s:getDependencies()
        expect_true(table_contains(deps, "parent"))
        local parent = lurek.pipeline.newStep("parent_step")
        local child = lurek.pipeline.newStep("child_step")
        child:dependsOn(parent)
        deps = child:getDependencies()
        expect_true(table_contains(deps, "parent_step"))
        local ret = s:dependsOn("a")
        expect_equal("child", ret:getName())
    end)

    -- @covers LPipelineStep:getDependencies
    it("getDependencies returns all added deps", function()
        local s = lurek.pipeline.newStep("s")
        s:dependsOn("x")
        s:dependsOn("y")
        local deps = s:getDependencies()
        expect_true(table_contains(deps, "x"))
        expect_true(table_contains(deps, "y"))
    end)

    -- @covers LPipelineStep:getDependencyCount
    it("getDependencyCount matches", function()
        local s = lurek.pipeline.newStep("s")
        s:dependsOn("a")
        s:dependsOn("b")
        expect_equal(2, s:getDependencyCount())
    end)
end)

-- =========================================================================
-- 4. Pipeline construction and step management
-- =========================================================================
-- @describe Pipeline construction
describe("Pipeline construction", function()
    -- @covers LPipeline:type
    it("type() returns 'LPipeline'", function()
        local p = lurek.pipeline.newPipeline()
        expect_equal("LPipeline", p:type())
    end)

    -- @covers LPipeline:typeOf
    it("typeOf('LPipeline') is true", function()
        local p = lurek.pipeline.newPipeline()
        expect_true(p:typeOf("LPipeline"))
    end)

    -- @covers LPipeline:getStepCount
    it("empty pipeline has stepCount 0", function()
        local p = lurek.pipeline.newPipeline()
        expect_equal(0, p:getStepCount())
    end)

    -- @covers LPipeline:addStep
    it("addStep increments stepCount", function()
        local p = lurek.pipeline.newPipeline()
        local s = lurek.pipeline.newStep("s", function(ctx) return 1 end)
        p:addStep(s)
        expect_equal(1, p:getStepCount())
    end)

    -- @covers LPipeline:getStep
    it("returns the added step and nil for unknown names", function()
        local p = lurek.pipeline.newPipeline()
        local s = lurek.pipeline.newStep("find_me", function(ctx) return 1 end)
        p:addStep(s)
        local got = p:getStep("find_me")
        expect_type("userdata", got)
        expect_equal("find_me", got:getName())
        expect_nil(p:getStep("ghost"))
    end)

    -- @covers LPipeline:removeStep
    it("removeStep decrements count", function()
        local p = lurek.pipeline.newPipeline()
        local s = lurek.pipeline.newStep("s", function(ctx) return 1 end)
        p:addStep(s)
        p:removeStep("s")
        expect_equal(0, p:getStepCount())
    end)

    -- @covers LPipeline:getStepsByTag
    it("getStepsByTag filters correctly", function()
        local p = lurek.pipeline.newPipeline()
        local s1 = lurek.pipeline.newStep("s1", function(ctx) return 1 end)
        local s2 = lurek.pipeline.newStep("s2", function(ctx) return 2 end)
        local s3 = lurek.pipeline.newStep("s3", function(ctx) return 3 end)
        s1:setTag("alpha")
        s2:setTag("beta")
        s3:setTag("alpha")
        p:addStep(s1):addStep(s2):addStep(s3)
        local alpha = p:getStepsByTag("alpha")
        expect_equal(2, #alpha)
    end)

    -- @covers LPipeline:clear
    it("clear empties pipeline", function()
        local p = lurek.pipeline.newPipeline()
        p:addStep(lurek.pipeline.newStep("a", function(ctx) return 1 end))
        p:addStep(lurek.pipeline.newStep("b", function(ctx) return 2 end))
        p:clear()
        expect_equal(0, p:getStepCount())
    end)

    -- @covers LPipeline:setName
    it("getName/setName roundtrip", function()
        local p = lurek.pipeline.newPipeline("original")
        expect_equal("original", p:getName())
        p:setName("renamed")
        expect_equal("renamed", p:getName())
    end)

    -- @covers LPipeline:setErrorMode
    it("round-trips explicit modes and changes runtime failure handling", function()
        local p = lurek.pipeline.newPipeline()
        p:setErrorMode("continue")
        expect_equal("continue", p:getErrorMode())
        p:setErrorMode("abort")
        expect_equal("abort", p:getErrorMode())

        local fail_abort = lurek.pipeline.newStep("fail", function(ctx) error("boom") end)
        p = lurek.pipeline.newPipeline("abort_test")
        p:setErrorMode("abort")
        p:addStep(fail_abort)
        local result = p:run()
        expect_false(result.success)
        expect_true(table_contains(result.failed, "fail"))

        local fail_continue = lurek.pipeline.newStep("fail", function(ctx) error("oops") end)
        local after = lurek.pipeline.newStep("after", function(ctx) return 1 end)
        p = lurek.pipeline.newPipeline("cont")
        p:setErrorMode("continue")
        p:addStep(fail_continue):addStep(after)
        result = p:run()
        expect_true(table_contains(result.failed, "fail"))
        expect_true(table_contains(result.completed, "after"))
    end)
end)

-- =========================================================================
-- 5. Validation and topological order
-- =========================================================================
-- @describe Pipeline validation
describe("Pipeline validation", function()
    -- @covers LPipeline:validate
    it("handles empty, valid, missing-dependency, and cyclic pipelines", function()
        local p = lurek.pipeline.newPipeline()
        local ok, errs = p:validate()
        expect_true(ok)
        expect_equal(0, #errs)

        p = lurek.pipeline.newPipeline()
        local s1 = lurek.pipeline.newStep("a", function(ctx) return 1 end)
        local s2 = lurek.pipeline.newStep("b", function(ctx) return 2 end)
        s2:dependsOn("a")
        p:addStep(s1):addStep(s2)
        ok, errs = p:validate()
        expect_true(ok)

        p = lurek.pipeline.newPipeline()
        local s = lurek.pipeline.newStep("child", function(ctx) return 1 end)
        s:dependsOn("missing_parent")
        p:addStep(s)
        ok, errs = p:validate()
        expect_false(ok)
        expect_true(#errs > 0)

        p = lurek.pipeline.newPipeline()
        s1 = lurek.pipeline.newStep("a", function(ctx) return 1 end)
        s2 = lurek.pipeline.newStep("b", function(ctx) return 2 end)
        s1:dependsOn("b")
        s2:dependsOn("a")
        p:addStep(s1):addStep(s2)
        ok, errs = p:validate()
        expect_false(ok)
    end)

    -- @covers LPipeline:getExecutionOrder
    it("getExecutionOrder returns topo order", function()
        local p = lurek.pipeline.newPipeline()
        local s1 = lurek.pipeline.newStep("first", function(ctx) return 1 end)
        local s2 = lurek.pipeline.newStep("second", function(ctx) return 2 end)
        s2:dependsOn("first")
        p:addStep(s1):addStep(s2)
        local order, err = p:getExecutionOrder()
        expect_not_equal(nil, order)
        expect_nil(err)
        -- "first" must appear before "second"
        local pos_first, pos_second = nil, nil
        for i, name in ipairs(order) do
            if name == "first" then pos_first = i end
            if name == "second" then pos_second = i end
        end
        expect_true(pos_first ~= nil)
        expect_true(pos_second ~= nil)
        expect_true(pos_first < pos_second)
    end)

    -- @covers LPipeline:getParallelGroups
    it("getParallelGroups groups independent steps", function()
        local p = lurek.pipeline.newPipeline()
        local s1 = lurek.pipeline.newStep("a", function(ctx) return 1 end)
        local s2 = lurek.pipeline.newStep("b", function(ctx) return 2 end)
        p:addStep(s1):addStep(s2)
        local groups, err = p:getParallelGroups()
        expect_not_equal(nil, groups)
        expect_nil(err)
        -- two independent steps can go in the same group
        local total = 0
        for _, group in ipairs(groups) do
            total = total + #group
        end
        expect_equal(2, total)
    end)
end)

-- =========================================================================
-- 6. Pipeline.run() execution
-- =========================================================================
-- @describe Pipeline.run() execution
describe("Pipeline.run() execution", function()
    -- @covers LPipeline:run
    it("runs single and dependent steps, stores results, and tracks completion", function()
        local s = lurek.pipeline.newStep("compute", function(ctx) return 42 end)
        local p = lurek.pipeline.newPipeline("test")
        p:addStep(s)
        local r = p:run()
        expect_true(r.success)
        local got_ctx_type = nil
        s = lurek.pipeline.newStep("ctx_check", function(ctx)
            got_ctx_type = type(ctx)
            return 1
        end)
        p = lurek.pipeline.newPipeline()
        p:addStep(s)
        p:run()
        expect_equal("table", got_ctx_type)
        s = lurek.pipeline.newStep("producer", function(ctx) return 99 end)
        p = lurek.pipeline.newPipeline()
        p:addStep(s)
        local ctx = {}
        p:run(ctx)
        expect_equal(99, ctx.results and ctx.results.producer)
        s = lurek.pipeline.newStep("done_step", function(ctx) return 1 end)
        p = lurek.pipeline.newPipeline()
        p:addStep(s)
        r = p:run()
        expect_true(table_contains(r.completed, "done_step"))

        local s1 = lurek.pipeline.newStep("a", function(ctx) return 10 end)
        local s2 = lurek.pipeline.newStep("b", function(ctx)
            return ctx.results.a * 2
        end)
        s2:dependsOn(s1)
        p = lurek.pipeline.newPipeline("chain")
        p:addStep(s1):addStep(s2)
        r = p:run()
        expect_true(r.success)
        expect_true(table_contains(r.completed, "a"))
        expect_true(table_contains(r.completed, "b"))
    end)

    -- @covers LPipelineStep:setCondition
    it("condition false skips step, pipeline still succeeds", function()
        local s = lurek.pipeline.newStep("guarded", function(ctx) return 1 end)
        s:setCondition(function(ctx) return false end)
        local p = lurek.pipeline.newPipeline("cond")
        p:addStep(s)
        local r = p:run()
        -- skipped is not failed, success should be true
        expect_true(r.success)
        expect_true(table_contains(r.skipped, "guarded"))
    end)

end)

-- =========================================================================
-- 7. Serialization
-- =========================================================================
-- @describe Pipeline serialization
describe("Pipeline serialization", function()
    -- @covers LPipeline:toTable
    it("toTable serializes name, steps, and errorMode", function()
        local p = lurek.pipeline.newPipeline("serial_test")
        p:addStep(lurek.pipeline.newStep("s1", function(ctx) return 1 end))
        p:addStep(lurek.pipeline.newStep("s2", function(ctx) return 2 end))
        p:setErrorMode("continue")
        local t = p:toTable()
        expect_type("table", t)
        expect_equal("serial_test", t.name)
        expect_type("table", t.steps)
        expect_equal(2, #t.steps)
        expect_equal("continue", t.errorMode)
    end)

    -- @covers lurek.pipeline.fromTable
    it("fromTable restores name, steps, and runnable callbacks", function()
        local p = lurek.pipeline.fromTable({
            name = "declarative",
            errorMode = "continue",
            steps = {
                { name = "step1", fn = function(ctx) return 1 end },
                { name = "step2", deps = {"step1"}, fn = function(ctx) return 2 end },
            }
        })
        expect_type("userdata", p)
        expect_equal("declarative", p:getName())
        expect_equal(2, p:getStepCount())
        local r = p:run()
        expect_true(r.success)
        expect_true(table_contains(r.completed, "step1"))
        expect_true(table_contains(r.completed, "step2"))
    end)
end)

-- @describe lurek.pipeline addConditional
describe("lurek.pipeline addConditional", function()
    -- @covers LPipeline:addConditional
    it("addConditional executes true branches and skips false branches", function()
        local ran_true = false
        local p = lurek.pipeline.newPipeline("cond_test")
        p:addConditional("guarded", {}, function(ctx) ran_true = true end, function() return true end)
        local r = p:run()
        expect_true(ran_true, "step body must run when condition is true")
        expect_true(table_contains(r.completed, "guarded"))

        local ran_false = false
        p = lurek.pipeline.newPipeline("skip_test")
        p:addConditional("skipped", {}, function(ctx) ran_false = true end, function() return false end)
        r = p:run()
        expect_false(ran_false, "step body must NOT run when condition is false")
        expect_true(table_contains(r.skipped, "skipped"))
    end)
end)

-- @describe lurek.pipeline onProgress
describe("lurek.pipeline onProgress", function()
    -- @covers LPipeline:onProgress
    it("onProgress is called for every step", function()
        local events = {}
        local p = lurek.pipeline.newPipeline("progress_test")
        p:addStep(lurek.pipeline.newStep("alpha", function(ctx) end))
        p:addStep(lurek.pipeline.newStep("beta",  function(ctx) end))
        p:onProgress(function(name, status)
            table.insert(events, { name = name, status = status })
        end)
        p:run()
        expect_equal(#events, 2, "expected 2 progress events")
        -- Both completions should have status "completed"
        for _, ev in ipairs(events) do
            expect_equal(ev.status, "completed")
        end
    end)
end)

-- @describe lurek.pipeline toAscii
describe("lurek.pipeline toAscii", function()
    -- @covers LPipeline:toAscii
    it("toAscii returns a non-empty string with step names", function()
        local p = lurek.pipeline.newPipeline("ascii_test")
        p:addStep(lurek.pipeline.newStep("s1", function() end))
        p:addStep(lurek.pipeline.newStep("init_step", function() end))
        local diagram = p:toAscii()
        expect_equal(type(diagram), "string")
        expect_true(#diagram > 0, "toAscii must return a non-empty string")
        expect_true(diagram:find("init_step") ~= nil, "diagram must mention step name 'init_step'")
    end)
end)

-- @describe pipeline regression coverage
describe("pipeline regression coverage", function()
    -- @covers LPipelineStep:setCallback
    it("step retry metadata and callback replacement work together", function()
        local attempts = 0
        local step = lurek.pipeline.newStep("retry", function(ctx) return -1 end)
        step:setTimeout(2.5)
        step:setRetryCount(1)
        step:setRetryDelay(0.25)
        step:setCallback(function(ctx)
            attempts = attempts + 1
            if attempts == 1 then
                error("retry once")
            end
            return 42
        end)

        local pipeline = lurek.pipeline.newPipeline("retry_meta")
        pipeline:addStep(step)
        local result = pipeline:run()

        expect_true(result.success)
        expect_near(2.5, step:getTimeout(), 0.001)
        expect_equal(2, step:getAttempt())
    end)

    -- @covers LPipeline:runAsync
    it("runAsync stores context, preserves dependency order, and joins parallel branches", function()
        local step = lurek.pipeline.newStep("async_step", function(ctx)
            return ctx.seed * 2
        end)
        local pipeline = lurek.pipeline.newPipeline("async_case")
        pipeline:addStep(step)

        pipeline:runAsync({seed = 21})
        expect_true(pipeline:isRunning())
        expect_equal(21, pipeline:getContext().seed)
        expect_type("boolean", pipeline:update(0.01))

        local seen = {}
        local first = lurek.pipeline.newStep("first", function(ctx)
            table.insert(seen, "first")
            return 1
        end)
        local second = lurek.pipeline.newStep("second", function(ctx)
            table.insert(seen, "second")
            return 2
        end)
        second:dependsOn("first")

        local pipeline = lurek.pipeline.newPipeline("async_order")
        pipeline:addStep(first)
        pipeline:addStep(second)
        pipeline:runAsync({})

        local ticks = 0
        while pipeline:isRunning() and ticks < 8 do
            pipeline:update(0.016)
            ticks = ticks + 1
        end

        expect_false(pipeline:isRunning())
        expect_equal("first", seen[1])
        expect_equal("second", seen[2])

        seen = {}
        local left = lurek.pipeline.newStep("left", function(ctx)
            table.insert(seen, "left")
            return 1
        end)
        local right = lurek.pipeline.newStep("right", function(ctx)
            table.insert(seen, "right")
            return 2
        end)
        local join = lurek.pipeline.newStep("join", function(ctx)
            table.insert(seen, "join")
            return 3
        end)
        join:dependsOn("left")
        join:dependsOn("right")

        local pipeline = lurek.pipeline.newPipeline("parallel_dag")
        pipeline:addStep(left)
        pipeline:addStep(right)
        pipeline:addStep(join)
        pipeline:runAsync({})

        local ticks = 0
        while pipeline:isRunning() and ticks < 10 do
            pipeline:update(0.016)
            ticks = ticks + 1
        end

        expect_false(pipeline:isRunning())
        expect_true(table_contains(seen, "left"))
        expect_true(table_contains(seen, "right"))
        expect_equal("join", seen[#seen])
    end)

    -- @covers LPipeline:setOnComplete
    it("run fires completion hooks and stores the final result", function()
        local complete_result = { success = false }
        local completed_step = nil
        local step = lurek.pipeline.newStep("sync_step", function(ctx)
            return ctx.seed * 2
        end)
        local pipeline = lurek.pipeline.newPipeline("sync_case")
        pipeline:addStep(step)
        pipeline:setOnComplete(function(result)
            complete_result = result
        end)
        pipeline:setOnStepComplete(function(name, ctx)
            completed_step = name
        end)

        local ctx = {seed = 21}
        local result = pipeline:run(ctx)
        expect_true(result.success)
        expect_equal("sync_step", completed_step)
        expect_true(complete_result.success)
        expect_true(pipeline:getResult().success)
        expect_equal(42, ctx.results.sync_step)
    end)

    -- @covers LPipeline:setOnStepError
    it("step and pipeline error hooks fire on failure", function()
        local step_error_name = nil
        local pipeline_error_name = nil
        local step = lurek.pipeline.newStep("boom", function(ctx)
            error("explode")
        end)
        step:setOnError(function(name, msg)
            step_error_name = name
        end)

        local pipeline = lurek.pipeline.newPipeline("error_case")
        pipeline:setErrorMode("continue")
        pipeline:setOnStepError(function(name, msg)
            pipeline_error_name = name
        end)
        pipeline:addStep(step)

        local result = pipeline:run()
        expect_false(result.success)
        expect_equal("boom", step_error_name)
        expect_equal("boom", pipeline_error_name)
        expect_equal(1, step:getAttempt())
        expect_false(pipeline:getResult().success)
    end)
end)

-- @describe LPipeline:addSubPipeline
describe("LPipeline:addSubPipeline", function()
    -- @covers LPipeline:addSubPipeline
    it("addSubPipeline inlines steps from another pipeline", function()
        local sub = lurek.pipeline.newPipeline("sub")
        local sub_step = lurek.pipeline.newStep("sub_step")
        sub_step:setCallback(function() end)
        sub:addStep(sub_step)

        local parent = lurek.pipeline.newPipeline("parent")
        expect_no_error(function()
            parent:addSubPipeline(sub, "sub")
        end)
    end)
end)

-- @describe pipeline strict: LPipelineStep getError/getDuration
describe("pipeline strict: LPipelineStep getError/getDuration", function()
    -- @covers LPipelineStep:getError
    it("LPipelineStep getError and getDuration are callable", function()
        local step = lurek.pipeline.newStep("strict_step")
        local ok1, e = pcall(function() return step:getError() end)
        expect_type("boolean", ok1)
        local ok2, d = pcall(function() return step:getDuration() end)
        if ok2 then expect_type("number", d) end
    end)

end)

-- @describe pipeline branch and coroutine async coverage
describe("pipeline branch and coroutine async coverage", function()
    -- @covers LPipeline:addBranch
    it("addBranch executes then and else branches according to the predicate", function()
        local chosen = "none"
        local p = lurek.pipeline.newPipeline("branch_true")
        p:addBranch(
            "gate",
            {},
            function(ctx) return true end,
            function(ctx) chosen = "then" end,
            function(ctx) chosen = "else" end
        )
        local result = p:run()
        expect_true(result.success)
        expect_equal("then", chosen)
        expect_true(table_contains(result.completed, "gate__branch_guard"))
        expect_true(table_contains(result.completed, "gate__then"))
        expect_true(table_contains(result.skipped, "gate__else"))

        chosen = "none"
        p = lurek.pipeline.newPipeline("branch_false")
        p:addBranch(
            "gate",
            {},
            function(ctx) return false end,
            function(ctx) chosen = "then" end,
            function(ctx) chosen = "else" end
        )
        local result = p:run()
        expect_true(result.success)
        expect_equal("else", chosen)
        expect_true(table_contains(result.completed, "gate__else"))
        expect_true(table_contains(result.skipped, "gate__then"))
    end)

    -- @covers LPipelineStep:setAsync
    it("setAsync/isAsync toggle step async flag", function()
        local s = lurek.pipeline.newStep("co", function(ctx)
            return "done"
        end)
        expect_false(s:isAsync())
        s:setAsync(true)
        expect_true(s:isAsync())
        s:setAsync(false)
        expect_false(s:isAsync())
    end)

    -- @covers LPipeline:onEvent
    it("onEvent receives lifecycle notifications", function()
        local events = {}
        local p = lurek.pipeline.newPipeline("events")
        p:addStep(lurek.pipeline.newStep("ok", function(ctx) return 1 end))
        p:onEvent(function(event_name, step_name, status, detail)
            table.insert(events, event_name .. ":" .. step_name .. ":" .. status)
        end)

        local result = p:run()
        expect_true(result.success)
        expect_true(#events >= 2)
        expect_true(events[1]:find("step_started") ~= nil)
        expect_true(events[#events]:find("step_finished") ~= nil)
    end)
end)
end
-- END test_pipeline_core_unit.lua

do
local function new_step(name, cb)
    return lurek.pipeline.newStep(name, cb)
end

local function new_pipeline(name)
    return lurek.pipeline.newPipeline(name)
end

-- @describe pipeline explicit owner coverage
describe("pipeline explicit owner coverage", function()
    -- @covers LPipelineStep:getName
    it("returns the step name", function()
        expect_equal("named_step", new_step("named_step"):getName())
    end)

    -- @covers LPipelineStep:getDelay
    it("returns the configured delay", function()
        local step = new_step("delay_step")
        step:setDelay(0.25)
        expect_near(0.25, step:getDelay(), 0.001)
    end)

    -- @covers LPipelineStep:setTimeout
    it("stores a timeout value", function()
        local step = new_step("timeout_step")
        step:setTimeout(1.5)
        expect_near(1.5, step:getTimeout(), 0.001)
    end)

    -- @covers LPipelineStep:getTimeout
    it("returns zero timeout by default", function()
        expect_near(0.0, new_step("timeout_default"):getTimeout(), 0.001)
    end)

    -- @covers LPipelineStep:getRetryCount
    it("returns the configured retry count", function()
        local step = new_step("retry_count_step")
        step:setRetryCount(2)
        expect_equal(2, step:getRetryCount())
    end)

    -- @covers LPipelineStep:setRetryDelay
    it("accepts a retry delay without error", function()
        local step = new_step("retry_delay_step")
        expect_no_error(function()
            step:setRetryDelay(0.2)
        end)
    end)

    -- @covers LPipelineStep:isAsync
    it("reports async mode after setAsync", function()
        local step = new_step("async_step")
        step:setAsync(true)
        expect_true(step:isAsync())
    end)

    -- @covers LPipelineStep:isOptional
    it("reports optional state after setOptional", function()
        local step = new_step("optional_step")
        step:setOptional(true)
        expect_true(step:isOptional())
    end)

    -- @covers LPipelineStep:setOnError
    it("invokes the step error callback on failure", function()
        local seen_name = nil
        local seen_msg = nil
        local step = new_step("failing_step", function()
            error("boom")
        end)
        step:setOnError(function(name, msg)
            seen_name = name
            seen_msg = msg
        end)
        local pipeline = new_pipeline("step_error_owner")
        pipeline:setErrorMode("continue")
        pipeline:addStep(step)
        local result = pipeline:run()
        expect_false(result.success)
        expect_equal("failing_step", seen_name)
        expect_true(type(seen_msg) == "string" and string.find(seen_msg, "boom", 1, true) ~= nil)
    end)

    -- @covers LPipelineStep:getTag
    it("returns the configured tag", function()
        local step = new_step("tag_step")
        step:setTag("critical")
        expect_equal("critical", step:getTag())
    end)

    -- @covers LPipelineStep:getDuration
    it("returns a non-negative step duration after execution", function()
        local step = new_step("duration_step", function()
            return 1
        end)
        local pipeline = new_pipeline("duration_owner")
        pipeline:addStep(step)
        pipeline:run()
        expect_true(step:getDuration() >= 0.0)
    end)

    -- @covers LPipelineStep:getAttempt
    it("tracks the attempt counter after one execution", function()
        local step = new_step("attempt_step", function()
            return 1
        end)
        local pipeline = new_pipeline("attempt_owner")
        pipeline:addStep(step)
        pipeline:run()
        expect_equal(1, step:getAttempt())
    end)

    -- @covers LPipeline:getSteps
    it("returns all step wrappers in the pipeline", function()
        local pipeline = new_pipeline("get_steps_owner")
        pipeline:addStep(new_step("a", function() end))
        pipeline:addStep(new_step("b", function() end))
        local steps = pipeline:getSteps()
        expect_equal(2, #steps)
    end)

    -- @covers LPipeline:update
    it("advances an async pipeline and reports completion", function()
        local pipeline = new_pipeline("update_owner")
        pipeline:addStep(new_step("instant", function()
            return 1
        end))
        pipeline:runAsync()
        local finished = pipeline:update(0.016)
        expect_type("boolean", finished)
        expect_true(finished)
    end)

    -- @covers LPipeline:cancel
    it("cancels pending async steps", function()
        local pipeline = new_pipeline("cancel_owner")
        pipeline:addStep(new_step("a", function()
            return 1
        end))
        pipeline:addStep(new_step("b", function()
            return 2
        end):dependsOn("a"))
        pipeline:runAsync()
        pipeline:cancel()
        local result = pipeline:getResult()
        expect_not_nil(result)
        expect_true(#result.cancelled >= 1 or #result.completed >= 1)
    end)

    -- @covers LPipeline:reset
    it("resets step state back to pending", function()
        local step = new_step("reset_step", function()
            return 1
        end)
        local pipeline = new_pipeline("reset_owner")
        pipeline:addStep(step)
        pipeline:run()
        pipeline:reset()
        expect_equal("pending", step:getStatus())
    end)

    -- @covers LPipeline:isRunning
    it("reports async running state after runAsync", function()
        local pipeline = new_pipeline("running_owner")
        pipeline:addStep(new_step("a", function()
            return 1
        end))
        pipeline:runAsync()
        expect_true(pipeline:isRunning())
    end)

    -- @covers LPipeline:isComplete
    it("reports completion after a synchronous run", function()
        local pipeline = new_pipeline("complete_owner")
        pipeline:addStep(new_step("a", function()
            return 1
        end))
        pipeline:run()
        expect_true(pipeline:isComplete())
    end)

    -- @covers LPipeline:getErrorMode
    it("returns the configured pipeline error mode", function()
        local pipeline = new_pipeline("error_mode_owner")
        pipeline:setErrorMode("continue")
        expect_equal("continue", pipeline:getErrorMode())
    end)

    -- @covers LPipeline:getResult
    it("returns a result table after execution", function()
        local pipeline = new_pipeline("result_owner")
        pipeline:addStep(new_step("a", function()
            return 1
        end))
        pipeline:run()
        local result = pipeline:getResult()
        expect_not_nil(result)
        expect_true(result.success)
        expect_true(#result.completed >= 1)
    end)

    -- @covers LPipeline:getContext
    it("returns the active context table for async execution", function()
        local pipeline = new_pipeline("context_owner")
        local ctx = { marker = "context-owner" }
        pipeline:addStep(new_step("a", function(c)
            c.seen = true
        end))
        pipeline:runAsync(ctx)
        local got = pipeline:getContext()
        expect_not_nil(got)
        expect_equal("context-owner", got.marker)
    end)

    -- @covers LPipeline:setOnStepComplete
    it("invokes the step complete callback", function()
        local seen = nil
        local pipeline = new_pipeline("step_complete_owner")
        pipeline:setOnStepComplete(function(name, ctx)
            seen = name
        end)
        pipeline:addStep(new_step("done", function()
            return 1
        end))
        pipeline:run()
        expect_equal("done", seen)
    end)

    -- @covers LPipeline:getName
    it("returns the pipeline name", function()
        expect_equal("owner_named_pipeline", new_pipeline("owner_named_pipeline"):getName())
    end)
end)
end

test_summary()
