--- Pipeline Module Part 2: pipeline run, getContext, fromTable

--@api-stub: LPipeline:getContext
--@api-stub: LPipeline:run
-- Pipeline execution and context retrieval.
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

print("pipeline_02.lua")
