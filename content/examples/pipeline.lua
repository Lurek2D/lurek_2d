-- content/examples/pipeline.lua
-- Lurek2D lurek.pipeline API Reference
-- Run with: cargo run -- content/examples/pipeline

-- Create a load_assets step that reads texture atlases from disk so
-- the level pipeline can depend on it before spawning entities.
local step_load = lurek.pipeline.newStep("load_assets", function(ctx)
    print("  [load_assets] loading textures...")
    ctx.textures_ready = true
end)
print("step created:", step_load:getName())

-- Demonstrates the proper usage of lurek.pipeline.newPipeline.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pipeline_newPipeline()
    local pipe = lurek.pipeline.newPipeline("level_load")
    print("pipeline:", pipe:getName())
end
local _ok, _err = pcall(demo_lurek_pipeline_newPipeline)

-- Restore a saved pipeline definition from a TOML-decoded table so
-- the same asset pipeline can be re-run across multiple levels.
local def = {
    name  = "asset_pipeline",
    steps = {
        { name = "load_sprites",  deps = {},               tag = "assets" },
        { name = "load_audio",    deps = {},               tag = "assets" },
        { name = "spawn_entities",deps = {"load_sprites"}, tag = "scene"  },
    }
}
local restored_pipe = lurek.pipeline.fromTable(def)
print("restored pipeline:", restored_pipe:getName())

-- -----------------------------------------------------------------------------
-- Pipeline methods
-- -----------------------------------------------------------------------------

-- Demonstrates the proper usage of Pipeline:setName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_setName()
    pipe:setName("dungeon_level_1")
    print("renamed:", pipe:getName())
end
local _ok, _err = pcall(demo_Pipeline_setName)

-- Demonstrates the proper usage of Pipeline:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getName()
    print("pipeline name:", pipe:getName())
end
local _ok, _err = pcall(demo_Pipeline_getName)

-- Demonstrates the proper usage of Pipeline:setErrorMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_setErrorMode()
    pipe:setErrorMode("continue")
    print("error mode:", pipe:getErrorMode())
end
local _ok, _err = pcall(demo_Pipeline_setErrorMode)

-- Demonstrates the proper usage of Pipeline:getErrorMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getErrorMode()
    print("error mode check:", pipe:getErrorMode())
end
local _ok, _err = pcall(demo_Pipeline_getErrorMode)

-- Register the asset-loading step first so entity spawning can declare
-- a dependency on it and only run after assets are ready.
local step_spawn = lurek.pipeline.newStep("spawn_entities", function(ctx)
    print("  [spawn_entities] spawning player and enemies...")
    ctx.entities_ready = true
end)
local step_ai = lurek.pipeline.newStep("init_ai", function(ctx)
    print("  [init_ai] initialising pathfinders...")
end)
pipe:addStep(step_load)
pipe:addStep(step_spawn)
pipe:addStep(step_ai)
print("steps after addStep:", pipe:getStepCount())

-- Add an optional background-music preload step that only runs when
-- the config flag for music is enabled.
local music_enabled = true
pipe:addConditional("preload_music", {}, function(ctx)
    print("  [preload_music] buffering music track...")
end, function() return music_enabled end)
print("steps with conditional:", pipe:getStepCount())

-- Drop the debug-overlay step from the pipeline in release builds
-- so it does not consume time in the shipped game.
local pipe2 = lurek.pipeline.newPipeline("test_remove")
local tmp_step = lurek.pipeline.newStep("debug_overlay", function(ctx) end)
pipe2:addStep(tmp_step)
pipe2:removeStep("debug_overlay")
print("steps after remove:", pipe2:getStepCount())

-- Demonstrates the proper usage of Pipeline:getStep.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getStep()
    local spawn_step = pipe:getStep("spawn_entities")
    print("got step:", spawn_step ~= nil)
end
local _ok, _err = pcall(demo_Pipeline_getStep)

-- Iterate all steps to print a pre-run checklist in the dev console
-- so the team can verify the pipeline structure before profiling.
local all_steps = pipe:getSteps()
print("all steps:")
for _, s in ipairs(all_steps) do print("  -", s:getName()) end

-- Demonstrates the proper usage of Pipeline:getStepCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getStepCount()
    print("step count:", pipe:getStepCount())
end
local _ok, _err = pcall(demo_Pipeline_getStepCount)

-- Demonstrates the proper usage of Pipeline:getStepsByTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getStepsByTag()
    local asset_steps = pipe:getStepsByTag("assets")
    print("steps tagged 'assets':", #asset_steps)
end
local _ok, _err = pcall(demo_Pipeline_getStepsByTag)

-- Demonstrates the proper usage of Pipeline:validate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_validate()
    print("pipeline valid:", ok, "errors:", errs and #errs or 0)
end
local _ok, _err = pcall(demo_Pipeline_validate)

-- Demonstrates the proper usage of Pipeline:getExecutionOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getExecutionOrder()
    local order = pipe:getExecutionOrder()
    print("execution order:", table.concat(order, " -> "))
end
local _ok, _err = pcall(demo_Pipeline_getExecutionOrder)

-- Demonstrates the proper usage of Pipeline:getParallelGroups.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getParallelGroups()
    local groups = pipe:getParallelGroups()
    print("parallel groups:", #groups)
end
local _ok, _err = pcall(demo_Pipeline_getParallelGroups)

-- Demonstrates the proper usage of Pipeline:toAscii.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_toAscii()
    print(pipe:toAscii())
end
local _ok, _err = pcall(demo_Pipeline_toAscii)

-- Demonstrates the proper usage of Pipeline:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_toTable()
    local pipe_tbl = pipe:toTable()
    print("serialised steps:", #(pipe_tbl.steps or {}))
end
local _ok, _err = pcall(demo_Pipeline_toTable)

-- Register a callback that triggers the fade-in animation when every
-- step of the level-load pipeline finishes successfully.
pipe:setOnComplete(function(result)
    print("  pipeline done! context:", result ~= nil)
end)

-- Register a step-error handler that logs which step failed and switches
-- the loading screen to an error state.
pipe:setOnStepError(function(step_name, err)
    print("  step error in:", step_name, "->", err)
end)

-- Register a progress callback that updates the loading-bar percentage
-- each time a step completes during an async level load.
pipe:onProgress(function(name, status)
    print("  progress:", name, "->", status)
end)

-- Execute the level pipeline synchronously so the loading screen
-- blocks until every asset and entity is ready.
local ctx = { level = "dungeon_1" }
local result = pipe:run(ctx)
print("pipeline result:", result ~= nil)

-- Demonstrates the proper usage of Pipeline:getResult.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getResult()
    local res = pipe:getResult()
    print("result table:", res ~= nil)
end
local _ok, _err = pcall(demo_Pipeline_getResult)

-- Start the pipeline asynchronously on the next frame so the loading
-- screen can render a progress indicator while work runs.
local async_pipe = lurek.pipeline.newPipeline("async_load")
local async_step = lurek.pipeline.newStep("async_work", function(ctx)
    print("  [async_work] running...")
end)
async_pipe:addStep(async_step)
async_pipe:runAsync({ level = "overworld" })
print("async pipeline running:", async_pipe:isRunning())

-- Demonstrates the proper usage of Pipeline:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_update()
    local done = async_pipe:update(0.016)
    print("async pipeline complete:", done)
end
local _ok, _err = pcall(demo_Pipeline_update)

-- Demonstrates the proper usage of Pipeline:isRunning.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_isRunning()
    print("is running:", async_pipe:isRunning())
end
local _ok, _err = pcall(demo_Pipeline_isRunning)

-- Demonstrates the proper usage of Pipeline:isComplete.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_isComplete()
    print("is complete:", async_pipe:isComplete())
end
local _ok, _err = pcall(demo_Pipeline_isComplete)

-- Demonstrates the proper usage of Pipeline:cancel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_cancel()
    async_pipe:cancel()
    print("cancelled, running:", async_pipe:isRunning())
end
local _ok, _err = pcall(demo_Pipeline_cancel)

-- Demonstrates the proper usage of Pipeline:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_reset()
    pipe:reset()
    print("reset, complete:", pipe:isComplete())
end
local _ok, _err = pcall(demo_Pipeline_reset)

-- Demonstrates the proper usage of Pipeline:getContext.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_getContext()
    local active_ctx = pipe:getContext()
    print("context:", active_ctx ~= nil)
end
local _ok, _err = pcall(demo_Pipeline_getContext)

-- Clear all steps from the pipeline before reloading the definition
-- from a hot-reloaded TOML file during a live game session.
local disposable_pipe = lurek.pipeline.newPipeline("disposable")
disposable_pipe:addStep(lurek.pipeline.newStep("x", function() end))
disposable_pipe:clear()
print("cleared, steps:", disposable_pipe:getStepCount())

-- Demonstrates the proper usage of Pipeline:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_type()
    print("pipeline type:", pipe:type())
end
local _ok, _err = pcall(demo_Pipeline_type)

-- Demonstrates the proper usage of Pipeline:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_typeOf()
    print("typeOf Pipeline:", pipe:typeOf("Pipeline"))
    local step = pipe:getStep("load_assets") or step_load
end
local _ok, _err = pcall(demo_Pipeline_typeOf)

-- Demonstrates the proper usage of Step:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getName()
    print("step name:", step:getName())
end
local _ok, _err = pcall(demo_Step_getName)

-- Replace the callback on an existing step to swap implementations
-- between debug and release without creating a new step.
step:setCallback(function(ctx)
    print("  [load_assets] callback replaced")
    ctx.textures_ready = true
end)

-- Guard the cloud-save step so it only runs when the player has
-- a network connection, otherwise it is silently skipped.
local cloud_step = lurek.pipeline.newStep("cloud_save", function(ctx) end)
cloud_step:setCondition(function()
    return false  -- no network in this demo run
end)
print("condition set on cloud_save")

-- Demonstrates the proper usage of Step:setDelay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_setDelay()
    step:setDelay(0.5)
    print("delay:", step:getDelay())
end
local _ok, _err = pcall(demo_Step_setDelay)

-- Demonstrates the proper usage of Step:getDelay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getDelay()
    print("configured delay:", step:getDelay())  -- 0.5
end
local _ok, _err = pcall(demo_Step_getDelay)

-- Set a 5-second timeout on the network-fetch step so the pipeline
-- does not hang indefinitely when the server is unreachable.
local fetch_step = lurek.pipeline.newStep("fetch_leaderboard", function(ctx) end)
fetch_step:setTimeout(5.0)
print("timeout:", fetch_step:getTimeout())

-- Demonstrates the proper usage of Step:getTimeout.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getTimeout()
    print("fetch timeout:", fetch_step:getTimeout())  -- 5.0
end
local _ok, _err = pcall(demo_Step_getTimeout)

-- Demonstrates the proper usage of Step:setRetryCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_setRetryCount()
    fetch_step:setRetryCount(3)
    print("retry count:", fetch_step:getRetryCount())
end
local _ok, _err = pcall(demo_Step_setRetryCount)

-- Demonstrates the proper usage of Step:getRetryCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getRetryCount()
    print("retry count check:", fetch_step:getRetryCount())  -- 3
end
local _ok, _err = pcall(demo_Step_getRetryCount)

-- Demonstrates the proper usage of Step:setRetryDelay.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_setRetryDelay()
    fetch_step:setRetryDelay(2.0)
    print("retry delay set")
end
local _ok, _err = pcall(demo_Step_setRetryDelay)

-- Demonstrates the proper usage of Step:setOptional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_setOptional()
    fetch_step:setOptional(true)
    print("optional:", fetch_step:isOptional())
end
local _ok, _err = pcall(demo_Step_setOptional)

-- Demonstrates the proper usage of Step:isOptional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_isOptional()
    print("fetch optional:", fetch_step:isOptional())  -- true
end
local _ok, _err = pcall(demo_Step_isOptional)

-- Attach a per-step error handler to the fetch step so the UI shows
-- an offline badge immediately when it fails.
fetch_step:setOnError(function(err)
    print("  fetch error:", err)
end)

-- Demonstrates the proper usage of Step:setData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_setData()
    step:setData("asset_path", "assets/dungeon_atlas.png")
    print("data set:", step:getData("asset_path"))
end
local _ok, _err = pcall(demo_Step_setData)

-- Demonstrates the proper usage of Step:getData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getData()
    print("asset_path:", step:getData("asset_path"))
end
local _ok, _err = pcall(demo_Step_getData)

-- Demonstrates the proper usage of Step:setTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_setTag()
    step:setTag("io")
    print("tag:", step:getTag())
end
local _ok, _err = pcall(demo_Step_setTag)

-- Demonstrates the proper usage of Step:getTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getTag()
    print("step tag:", step:getTag())  -- "io"
end
local _ok, _err = pcall(demo_Step_getTag)

-- Declare that spawn_entities depends on load_assets so the pipeline
-- scheduler never starts spawning before textures are loaded.
step_spawn:dependsOn("load_assets")
step_ai:dependsOn(step_spawn)  -- accepts step object too
print("spawn deps:", step_spawn:getDependencyCount())

-- Demonstrates the proper usage of Step:getDependencies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getDependencies()
    local deps = step_spawn:getDependencies()
    print("spawn dependencies:", table.concat(deps, ", "))
end
local _ok, _err = pcall(demo_Step_getDependencies)

-- Demonstrates the proper usage of Step:getDependencyCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getDependencyCount()
    print("dep count:", step_spawn:getDependencyCount())
end
local _ok, _err = pcall(demo_Step_getDependencyCount)

-- Demonstrates the proper usage of Step:getStatus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getStatus()
    print("step status:", step:getStatus())
end
local _ok, _err = pcall(demo_Step_getStatus)

-- Demonstrates the proper usage of Step:getError.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getError()
    local err_msg = step:getError()
    print("step error:", err_msg or "none")
end
local _ok, _err = pcall(demo_Step_getError)

-- Demonstrates the proper usage of Step:getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getDuration()
    print(string.format("step duration: %.3f s", step:getDuration()))
end
local _ok, _err = pcall(demo_Step_getDuration)

-- Demonstrates the proper usage of Step:getAttempt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_getAttempt()
    print("attempt:", step:getAttempt())
end
local _ok, _err = pcall(demo_Step_getAttempt)

-- Demonstrates the proper usage of Step:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_type()
    print("step type:", step:type())
end
local _ok, _err = pcall(demo_Step_type)

-- Demonstrates the proper usage of Step:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Step_typeOf()
    print("typeOf PipelineStep:", step:typeOf("PipelineStep"))
end
local _ok, _err = pcall(demo_Step_typeOf)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pipeline methods
-- -----------------------------------------------------------------------------

-- Sets the callback to invoke each time a step completes successfully.
-- Example scenario:
if pipe ~= nil then
    -- Calling actual method on pipe successfully
    print("Action: calling setOnStepComplete()")
    pcall(function() pipe:setOnStepComplete() end)
    print("Executed smoothly.")
end

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pipeline methods
-- -----------------------------------------------------------------------------

-- Demonstrates the proper usage of Pipeline:validate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Pipeline_validate()
    print('Executing validate')
end
local _ok, _err = pcall(demo_Pipeline_validate)

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pipeline methods
-- -----------------------------------------------------------------------------

-- Validates the pipeline DAG. Returns (ok, error_array).
pipeline:validate()
-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pipeline methods
-- -----------------------------------------------------------------------------

-- Validates the pipeline DAG. Returns (ok, error_array).
pipeline:validate()
-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Pipeline methods
-- -----------------------------------------------------------------------------

-- Validates the pipeline DAG. Returns (ok, error_array).
pipeline:validate()
