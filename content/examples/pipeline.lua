-- content/examples/pipeline.lua
-- lurek.pipeline API examples.
-- Run: cargo run -- content/examples/pipeline.lua

--@api-stub: lurek.pipeline.newStep -- Creates a new pipeline step with the given name and an optional callback function
do -- lurek.pipeline.newStep
  local step = lurek.pipeline.newStep("load_audio", function(ctx)
    ctx.audio_loaded = true
  end)
  step:setTag("boot")
end

--@api-stub: lurek.pipeline.newPipeline -- Creates a new empty pipeline with an optional name
do -- lurek.pipeline.newPipeline
  local boot = lurek.pipeline.newPipeline("boot")
  boot:addStep(lurek.pipeline.newStep("init", function() end))
  lurek.log.info("pipeline '" .. boot:getName() .. "' built", "boot")
end

--@api-stub: lurek.pipeline.fromTable -- Creates a pipeline pre-populated with steps from a declarative table definition
do -- lurek.pipeline.fromTable
  local def = { name = "save", steps = {
    { name = "snapshot",   deps = {} },
    { name = "write_disk", deps = { "snapshot" } },
  } }
  local pl = lurek.pipeline.fromTable(def)
  pl:getStep("snapshot"):setCallback(function(ctx) ctx.snap = "ok" end)
end

-- â”€â”€ Step methods â”€â”€

--@api-stub: Step:getName
do -- Step:getName
  local step = lurek.pipeline.newStep("hydrate_world")
  lurek.log.info("registering step: " .. step:getName(), "boot")
end

--@api-stub: Step:setCallback
do -- Step:setCallback
  local step = lurek.pipeline.newStep("warm_caches")
  step:setCallback(function(ctx)
    ctx.caches = { sprites = 64, audio = 16 }
  end)
end

--@api-stub: Step:setCondition
do -- Step:setCondition
  local step = lurek.pipeline.newStep("seed_demo_data", function(ctx) ctx.seeded = true end)
  step:setCondition(function() return lurek.log.getLevel() == "debug" end)
end

--@api-stub: Step:setDelay
do -- Step:setDelay
  local step = lurek.pipeline.newStep("show_logo")
  step:setDelay(0.5)
end

--@api-stub: Step:getDelay
do -- Step:getDelay
  local step = lurek.pipeline.newStep("fade_in")
  step:setDelay(1.25)
  lurek.log.debug("fade_in waits " .. step:getDelay() .. "s", "boot")
end

--@api-stub: Step:setTimeout
do -- Step:setTimeout
  local step = lurek.pipeline.newStep("fetch_remote_config")
  step:setTimeout(5.0)
end

--@api-stub: Step:getTimeout
do -- Step:getTimeout
  local step = lurek.pipeline.newStep("download_dlc")
  step:setTimeout(30.0)
  if step:getTimeout() > 0 then
    lurek.log.info("download bounded to " .. step:getTimeout() .. "s", "net")
  end
end

--@api-stub: Step:setRetryCount
do -- Step:setRetryCount
  local step = lurek.pipeline.newStep("connect_server", function(ctx) ctx.online = true end)
  step:setRetryCount(3)
  step:setRetryDelay(0.5)
end

--@api-stub: Step:getRetryCount
do -- Step:getRetryCount
  local step = lurek.pipeline.newStep("publish_score")
  step:setRetryCount(2)
  lurek.log.info("retries=" .. step:getRetryCount(), "net")
end

--@api-stub: Step:setRetryDelay
do -- Step:setRetryDelay
  local step = lurek.pipeline.newStep("login")
  step:setRetryCount(4)
  step:setRetryDelay(2.0)
end

--@api-stub: Step:setAsync
do -- Step:setAsync
  local step = lurek.pipeline.newStep("stream_chunks", function(ctx)
    coroutine.yield("waiting")
    return "done"
  end)
  step:setAsync(true)
end

--@api-stub: Step:isAsync
do -- Step:isAsync
  local step = lurek.pipeline.newStep("stream_chunks")
  step:setAsync(true)
  lurek.log.info("async=" .. tostring(step:isAsync()), "pipeline")
end

--@api-stub: Step:setOptional
do -- Step:setOptional
  local step = lurek.pipeline.newStep("preload_credits", function() end)
  step:setOptional(true)
end

--@api-stub: Step:isOptional
do -- Step:isOptional
  local step = lurek.pipeline.newStep("achievements_sync")
  step:setOptional(true)
  if step:isOptional() then
    lurek.log.debug(step:getName() .. " will not abort the pipeline", "boot")
  end
end

--@api-stub: Step:setOnError
do -- Step:setOnError
  local step = lurek.pipeline.newStep("load_save", function() error("missing slot") end)
  step:setOnError(function(err)
    lurek.log.warn("save load failed: " .. err, "save")
  end)
end

--@api-stub: Step:setData
do -- Step:setData
  local step = lurek.pipeline.newStep("load_level")
  step:setData("scene", "forest_01")
  step:setData("difficulty", "normal")
end

--@api-stub: Step:getData
do -- Step:getData
  local step = lurek.pipeline.newStep("load_level")
  step:setData("scene", "forest_01")
  local scene = step:getData("scene") or "title"
  lurek.log.info("loading scene: " .. scene, "scene")
end

--@api-stub: Step:setTag
do -- Step:setTag
  local step = lurek.pipeline.newStep("compile_shaders")
  step:setTag("gpu")
end

--@api-stub: Step:getTag
do -- Step:getTag
  local step = lurek.pipeline.newStep("warm_audio")
  step:setTag("audio")
  local tag = step:getTag() or "untagged"
  lurek.log.debug(step:getName() .. " tag=" .. tag, "boot")
end

--@api-stub: Step:dependsOn
do -- Step:dependsOn
  local boot = lurek.pipeline.newStep("boot")
  local load = lurek.pipeline.newStep("load_assets")
  load:dependsOn(boot)
  load:dependsOn("network_ready")
end

--@api-stub: Step:getDependencies
do -- Step:getDependencies
  local step = lurek.pipeline.newStep("present")
  step:dependsOn("draw_world")
  step:dependsOn("draw_ui")
  for _, name in ipairs(step:getDependencies()) do
    lurek.log.debug("present depends on " .. name, "boot")
  end
end

--@api-stub: Step:getDependencyCount
do -- Step:getDependencyCount
  local step = lurek.pipeline.newStep("commit_save")
  step:dependsOn("snapshot_state")
  if step:getDependencyCount() == 0 then
    lurek.log.warn("commit_save has no deps; will run immediately", "save")
  end
end

--@api-stub: Step:getStatus
do -- Step:getStatus
  local pl = lurek.pipeline.newPipeline("audit")
  local s = lurek.pipeline.newStep("noop", function() end)
  pl:addStep(s); pl:run()
  lurek.log.info("noop status: " .. s:getStatus(), "boot")
end

--@api-stub: Step:getError
do -- Step:getError
  local step = lurek.pipeline.newStep("touchy", function() error("disk full") end)
  local pl = lurek.pipeline.newPipeline("io"); pl:addStep(step); pl:run()
  if step:getError() then
    lurek.log.error(step:getName() .. ": " .. step:getError(), "io")
  end
end

--@api-stub: Step:getDuration
do -- Step:getDuration
  local step = lurek.pipeline.newStep("compute", function() end)
  local pl = lurek.pipeline.newPipeline("bench"); pl:addStep(step); pl:run()
  lurek.log.info(string.format("compute took %.3fs", step:getDuration()), "perf")
end

--@api-stub: Step:getAttempt
do -- Step:getAttempt
  local step = lurek.pipeline.newStep("flaky", function() end)
  step:setRetryCount(2)
  local pl = lurek.pipeline.newPipeline("net"); pl:addStep(step); pl:run()
  lurek.log.debug("flaky attempts: " .. step:getAttempt(), "net")
end

--@api-stub: Step:type
do -- Step:type
  local step = lurek.pipeline.newStep("init")
  if step:type() == "LPipelineStep" then
    lurek.log.debug("got a real step", "boot")
  end
end

--@api-stub: Step:typeOf
do -- Step:typeOf
  local step = lurek.pipeline.newStep("init")
  if step:typeOf("Object") then
    lurek.log.debug("step inherits from Object", "boot")
  end
end

-- â”€â”€ Pipeline methods â”€â”€

--@api-stub: Pipeline:addStep
do -- Pipeline:addStep
  local pl = lurek.pipeline.newPipeline("boot")
  pl:addStep(lurek.pipeline.newStep("read_config", function(ctx) ctx.cfg = {} end))
    :addStep(lurek.pipeline.newStep("warm_cache",  function() end))
end

--@api-stub: Pipeline:removeStep
do -- Pipeline:removeStep
  local pl = lurek.pipeline.newPipeline("boot")
  pl:addStep(lurek.pipeline.newStep("legacy_check", function() end))
  pl:removeStep("legacy_check")
end

--@api-stub: Pipeline:getStep
do -- Pipeline:getStep
  local pl = lurek.pipeline.fromTable({ steps = { { name = "boot", deps = {} } } })
  local boot = pl:getStep("boot")
  if boot then boot:setCallback(function(ctx) ctx.booted = true end) end
end

--@api-stub: Pipeline:getSteps
do -- Pipeline:getSteps
  local pl = lurek.pipeline.newPipeline("scan")
  pl:addStep(lurek.pipeline.newStep("a"))
  pl:addStep(lurek.pipeline.newStep("b"))
  for _, s in ipairs(pl:getSteps()) do
    lurek.log.debug("found step " .. s:getName(), "boot")
  end
end

--@api-stub: Pipeline:getStepCount
do -- Pipeline:getStepCount
  local pl = lurek.pipeline.newPipeline("dynamic")
  if pl:getStepCount() == 0 then
    lurek.log.warn("nothing to do; skipping run", "boot")
  end
end

--@api-stub: Pipeline:getStepsByTag
do -- Pipeline:getStepsByTag
  local pl = lurek.pipeline.newPipeline("boot")
  local s = lurek.pipeline.newStep("upload_metric"); s:setTag("net"); pl:addStep(s)
  for _, n in ipairs(pl:getStepsByTag("net")) do
    lurek.log.info("net step: " .. n:getName(), "net")
  end
end

--@api-stub: Pipeline:clear
do -- Pipeline:clear
  local pl = lurek.pipeline.newPipeline("hot")
  pl:addStep(lurek.pipeline.newStep("old"))
  pl:clear()
end

--@api-stub: Pipeline:validate
do -- Pipeline:validate
  local pl = lurek.pipeline.newPipeline("check")
  local s = lurek.pipeline.newStep("orphan"); s:dependsOn("missing"); pl:addStep(s)
  local ok, errs = pl:validate()
  if not ok then
    for _, e in ipairs(errs or {}) do lurek.log.error(e, "pipeline") end
  end
end

--@api-stub: Pipeline:getExecutionOrder
do -- Pipeline:getExecutionOrder
  local pl = lurek.pipeline.newPipeline("plan")
  pl:addStep(lurek.pipeline.newStep("a"))
  local order, err = pl:getExecutionOrder()
  if err then lurek.log.error(err, "pipeline")
  else lurek.log.info("first step: " .. ((order and order[1]) or "?"), "pipeline") end
end

--@api-stub: Pipeline:getParallelGroups
do -- Pipeline:getParallelGroups
  local pl = lurek.pipeline.newPipeline("parallel")
  pl:addStep(lurek.pipeline.newStep("a"))
  pl:addStep(lurek.pipeline.newStep("b"))
  local groups = pl:getParallelGroups()
  lurek.log.info("group count: " .. #groups, "pipeline")
end

--@api-stub: Pipeline:run
do -- Pipeline:run
  local pl = lurek.pipeline.newPipeline("boot")
  pl:addStep(lurek.pipeline.newStep("load", function(ctx) ctx.assets = 12 end))
  local result = pl:run({ user = "p1" })
  lurek.log.info("ok=" .. tostring(result.success), "boot")
end

--@api-stub: Pipeline:runAsync
do -- Pipeline:runAsync
  local pl = lurek.pipeline.newPipeline("loading")
  pl:addStep(lurek.pipeline.newStep("a", function() end))
  pl:runAsync({ progress = 0 })
  function lurek.process(dt) pl:update(dt) end
end

--@api-stub: Pipeline:update
do -- Pipeline:update
  local pl = lurek.pipeline.newPipeline("loader")
  pl:addStep(lurek.pipeline.newStep("scan", function() end))
  pl:runAsync()
  function lurek.process(dt)
    if pl:update(dt) then lurek.log.info("loader done", "boot") end
  end
end

--@api-stub: Pipeline:cancel
do -- Pipeline:cancel
  local pl = lurek.pipeline.newPipeline("net")
  pl:addStep(lurek.pipeline.newStep("ping", function() end))
  pl:runAsync()
  pl:cancel()
end

--@api-stub: Pipeline:reset
do -- Pipeline:reset
  local pl = lurek.pipeline.newPipeline("retry")
  pl:addStep(lurek.pipeline.newStep("once", function() end))
  pl:run(); pl:reset(); pl:run()
end

--@api-stub: Pipeline:isRunning
do -- Pipeline:isRunning
  local pl = lurek.pipeline.newPipeline("loader")
  pl:addStep(lurek.pipeline.newStep("a", function() end))
  pl:runAsync()
  if pl:isRunning() then lurek.log.debug("loader in flight", "boot") end
end

--@api-stub: Pipeline:isComplete
do -- Pipeline:isComplete
  local pl = lurek.pipeline.newPipeline("boot")
  pl:addStep(lurek.pipeline.newStep("noop", function() end))
  pl:run()
  if pl:isComplete() then lurek.log.info("boot finished", "boot") end
end

--@api-stub: Pipeline:setErrorMode
do -- Pipeline:setErrorMode
  local pl = lurek.pipeline.newPipeline("scan")
  pl:setErrorMode("continue")
  pl:addStep(lurek.pipeline.newStep("a", function() end))
end

--@api-stub: Pipeline:getErrorMode
do -- Pipeline:getErrorMode
  local pl = lurek.pipeline.newPipeline("boot")
  pl:setErrorMode("continue")
  lurek.log.info("error mode: " .. pl:getErrorMode(), "boot")
end

--@api-stub: Pipeline:getResult
do -- Pipeline:getResult
  local pl = lurek.pipeline.newPipeline("boot")
  pl:addStep(lurek.pipeline.newStep("noop", function() end))
  pl:run()
  local r = pl:getResult()
  if r then lurek.log.info("completed=" .. #r.completed, "boot") end
end

--@api-stub: Pipeline:getContext
do -- Pipeline:getContext
  local pl = lurek.pipeline.newPipeline("loader")
  pl:addStep(lurek.pipeline.newStep("a", function() end))
  pl:runAsync({ progress = 0 })
  local ctx = pl:getContext()
  if ctx then lurek.log.debug("progress=" .. tostring(ctx.progress), "boot") end
end

--@api-stub: Pipeline:setOnComplete
do -- Pipeline:setOnComplete
  local pl = lurek.pipeline.newPipeline("boot")
  pl:setOnComplete(function(r)
    lurek.log.info("pipeline done: success=" .. tostring(r.success), "boot")
  end)
  pl:addStep(lurek.pipeline.newStep("noop", function() end)); pl:run()
end

--@api-stub: Pipeline:setOnStepComplete
do -- Pipeline:setOnStepComplete
  local pl = lurek.pipeline.newPipeline("loader")
  pl:setOnStepComplete(function(name, _ctx)
    lurek.log.info("loaded: " .. name, "loader")
  end)
  pl:addStep(lurek.pipeline.newStep("textures", function() end)); pl:run()
end

--@api-stub: Pipeline:setOnStepError
do -- Pipeline:setOnStepError
  local pl = lurek.pipeline.newPipeline("net")
  pl:setOnStepError(function(name, err)
    lurek.log.warn(name .. " failed: " .. err, "net")
  end)
  pl:addStep(lurek.pipeline.newStep("ping", function() error("timeout") end)); pl:run()
end

--@api-stub: Pipeline:getName
do -- Pipeline:getName
  local pl = lurek.pipeline.newPipeline("save_routine")
  lurek.log.info("running pipeline " .. pl:getName(), "save")
end

--@api-stub: Pipeline:setName
do -- Pipeline:setName
  local pl = lurek.pipeline.newPipeline("temp")
  pl:setName("scene_" .. "forest_01")
  lurek.log.debug("pipeline renamed to " .. pl:getName(), "scene")
end

--@api-stub: Pipeline:toTable
do -- Pipeline:toTable
  local pl = lurek.pipeline.newPipeline("dump")
  pl:addStep(lurek.pipeline.newStep("a"))
  local t = pl:toTable()
  lurek.log.info("serialised name=" .. t.name .. " steps=" .. #t.steps, "boot")
end

--@api-stub: Pipeline:type
do -- Pipeline:type
  local pl = lurek.pipeline.newPipeline("boot")
  if pl:type() == "LPipeline" then
    lurek.log.debug("got a pipeline userdata", "boot")
  end
end

--@api-stub: Pipeline:onProgress
do -- Pipeline:onProgress
  local pl = lurek.pipeline.newPipeline("loader")
  pl:onProgress(function(name, status)
    lurek.log.debug(name .. " -> " .. status, "loader")
  end)
  pl:addStep(lurek.pipeline.newStep("a", function() end)); pl:run()
end

--@api-stub: Pipeline:onEvent
do -- Pipeline:onEvent
  local pl = lurek.pipeline.newPipeline("loader")
  pl:onEvent(function(event_name, step_name, status, detail)
    lurek.log.debug(event_name .. ":" .. step_name .. ":" .. status, "loader")
  end)
end

--@api-stub: Pipeline:toAscii
do -- Pipeline:toAscii
  local pl = lurek.pipeline.newPipeline("plan")
  pl:addStep(lurek.pipeline.newStep("a"))
  pl:addStep(lurek.pipeline.newStep("b"))
  lurek.log.info("\n" .. pl:toAscii(), "pipeline")
end

--@api-stub: Pipeline:typeOf
do -- Pipeline:typeOf
  local pl = lurek.pipeline.newPipeline("boot")
  if pl:typeOf("Object") then
    lurek.log.debug("pipeline inherits from Object", "boot")
  end
end


--@api-stub: Pipeline:addConditional
do -- Pipeline:addConditional
  local pipe = lurek.pipeline.newPipeline("build")
  pipe:addConditional(
    "embed_symbols",
    {},
    function(ctx) end,
    function(ctx) return ctx.debugBuild == true end
  )
  lurek.log.info("conditional step added", "pipeline")
end

--@api-stub: Pipeline:addBranch
do -- Pipeline:addBranch
  local pipe = lurek.pipeline.newPipeline("build")
  pipe:addBranch(
    "build_mode",
    {},
    function(ctx) return ctx.debugBuild == true end,
    function(ctx) ctx.mode = "debug" end,
    function(ctx) ctx.mode = "release" end
  )
end

--@api-stub: Pipeline:addSubPipeline
do -- Pipeline:addSubPipeline
  local parent = lurek.pipeline.newPipeline("full_build")
  local tests  = lurek.pipeline.newPipeline("test_suite")
  tests:addStep(lurek.pipeline.newStep("unit_tests", function() end))
  parent:addSubPipeline(tests, "tests", {})
  lurek.log.info("sub-pipeline embedded", "pipeline")
end

-- =============================================================================
-- COVERAGE: 59 uncovered lurek.pipeline API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LPipelineStep methods
-- -----------------------------------------------------------------------------

--@api-stub: LPipelineStep:getName -- Returns the unique name of this pipeline step
do -- LPipelineStep:getName
  local step = lurek.pipeline.newStep("load_assets", function() end)
  lurek.log.info("step name=" .. step:getName(), "pipeline")
end
--@api-stub: LPipelineStep:setCallback -- Sets the main execution function for this step
do -- LPipelineStep:setCallback
  local step = lurek.pipeline.newStep("process", function() end)
  step:setCallback(function()
    lurek.log.info("step executing: process", "pipeline")
  end)
  lurek.log.info("callback updated for: " .. step:getName(), "pipeline")
end
--@api-stub: LPipelineStep:setCondition -- Sets a predicate function that determines whether this step should execute
do -- LPipelineStep:setCondition
  local step = lurek.pipeline.newStep("optional_step", function() end)
  step:setCondition(function()
    return true  -- always run in this example
  end)
  lurek.log.info("condition set for: " .. step:getName(), "pipeline")
end
--@api-stub: LPipelineStep:setDelay -- Sets a delay in seconds before this step begins execution after its dependencies are satisfied
do -- LPipelineStep:setDelay
  local step = lurek.pipeline.newStep("delayed_step", function() end)
  step:setDelay(0.5)
  lurek.log.info("delay=" .. step:getDelay(), "pipeline")
end
--@api-stub: LPipelineStep:getDelay -- Returns the configured delay for this step
do -- LPipelineStep:getDelay
  local step = lurek.pipeline.newStep("fetch_data", function() end)
  step:setDelay(1.0)
  lurek.log.info("delay=" .. step:getDelay(), "pipeline")
end
--@api-stub: LPipelineStep:setTimeout -- Sets a maximum execution time for this step
do -- LPipelineStep:setTimeout
  local step = lurek.pipeline.newStep("network_call", function() end)
  step:setTimeout(5.0)
  lurek.log.info("timeout=" .. step:getTimeout(), "pipeline")
end
--@api-stub: LPipelineStep:getTimeout -- Returns the configured timeout for this step, or 0 if none is set
do -- LPipelineStep:getTimeout
  local step = lurek.pipeline.newStep("upload", function() end)
  step:setTimeout(10.0)
  lurek.log.info("timeout=" .. step:getTimeout() .. "s", "pipeline")
end
--@api-stub: LPipelineStep:setRetryCount -- Sets how many times this step should be retried after a failure before being marked as failed
do -- LPipelineStep:setRetryCount
  local step = lurek.pipeline.newStep("fetch_leaderboard", function() end)
  step:setRetryCount(3)
  lurek.log.info("retry_count=" .. step:getRetryCount(), "pipeline")
end
--@api-stub: LPipelineStep:getRetryCount -- Returns the configured retry count for this step
do -- LPipelineStep:getRetryCount
  local step = lurek.pipeline.newStep("save_progress", function() end)
  step:setRetryCount(2)
  lurek.log.info("retry_count=" .. step:getRetryCount(), "pipeline")
end
--@api-stub: LPipelineStep:setRetryDelay -- Sets the delay in seconds between retry attempts for this step
do -- LPipelineStep:setRetryDelay
  local step = lurek.pipeline.newStep("send_score", function() end)
  step:setRetryCount(3)
  step:setRetryDelay(0.5)   -- wait 0.5s before each retry
  lurek.log.info("retry delay configured for: " .. step:getName(), "pipeline")
end
--@api-stub: LPipelineStep:setOptional -- Marks this step as optional
do -- LPipelineStep:setOptional
  local step = lurek.pipeline.newStep("telemetry", function() end)
  step:setOptional(true)
  lurek.log.info("optional=" .. tostring(step:isOptional()), "pipeline")
end
--@api-stub: LPipelineStep:isOptional -- Returns whether this step is marked as optional
do -- LPipelineStep:isOptional
  local step = lurek.pipeline.newStep("analytics", function() end)
  step:setOptional(true)
  lurek.log.info("is optional=" .. tostring(step:isOptional()), "pipeline")
end
--@api-stub: LPipelineStep:setOnError -- Sets an error handler callback invoked when this step fails after all retries are exhausted
do -- LPipelineStep:setOnError
  local step = lurek.pipeline.newStep("critical_step", function() end)
  step:setOnError(function(err)
    lurek.log.info("step failed: " .. tostring(err), "pipeline")
  end)
  lurek.log.info("error handler registered for: " .. step:getName(), "pipeline")
end
--@api-stub: LPipelineStep:setData -- Stores a key-value metadata pair on this step
do -- LPipelineStep:setData
  local step = lurek.pipeline.newStep("load_level", function() end)
  step:setData("level_id", "dungeon_2")
  step:setData("difficulty", "hard")
  lurek.log.info("level_id=" .. step:getData("level_id"), "pipeline")
end
--@api-stub: LPipelineStep:getData -- Retrieves a metadata value previously stored with setData
do -- LPipelineStep:getData
  local step = lurek.pipeline.newStep("init_renderer", function() end)
  step:setData("resolution", "1920x1080")
  local res = step:getData("resolution")
  lurek.log.info("resolution=" .. tostring(res), "pipeline")
end
--@api-stub: LPipelineStep:setTag -- Assigns a tag string to this step for grouping and filtering purposes
do -- LPipelineStep:setTag
  local step = lurek.pipeline.newStep("warmup_shader", function() end)
  step:setTag("graphics")
  lurek.log.info("tag=" .. tostring(step:getTag()), "pipeline")
end
--@api-stub: LPipelineStep:getTag -- Returns the tag assigned to this step, or nil if none is set
do -- LPipelineStep:getTag
  local step = lurek.pipeline.newStep("load_audio", function() end)
  step:setTag("audio")
  lurek.log.info("tag=" .. tostring(step:getTag()), "pipeline")
end
--@api-stub: LPipelineStep:dependsOn -- Declares that this step depends on another step (by name or reference)
do -- LPipelineStep:dependsOn
  local a = lurek.pipeline.newStep("load_assets", function() end)
  local b = lurek.pipeline.newStep("init_scene", function() end)
  b:dependsOn(a)   -- init_scene waits for load_assets
  lurek.log.info("dep count=" .. b:getDependencyCount(), "pipeline")
end
--@api-stub: LPipelineStep:getDependencies -- Returns a list of step names that this step depends on
do -- LPipelineStep:getDependencies
  local a = lurek.pipeline.newStep("fetch", function() end)
  local b = lurek.pipeline.newStep("parse", function() end)
  b:dependsOn(a)
  local deps = b:getDependencies()
  lurek.log.info("dep[1]=" .. tostring(deps[1]), "pipeline")
end
--@api-stub: LPipelineStep:getDependencyCount -- Returns the number of dependencies this step has
do -- LPipelineStep:getDependencyCount
  local a = lurek.pipeline.newStep("step_a", function() end)
  local b = lurek.pipeline.newStep("step_b", function() end)
  local c = lurek.pipeline.newStep("step_c", function() end)
  c:dependsOn(a):dependsOn(b)
  lurek.log.info("dep count=" .. c:getDependencyCount(), "pipeline")
end
--@api-stub: LPipelineStep:getStatus -- Returns the current execution status of this step as a string ("pending", "waiting", "running", "completed", "failed", "skipped", "cancelled")
do -- LPipelineStep:getStatus
  local step = lurek.pipeline.newStep("build_nav", function() end)
  lurek.log.info("initial status=" .. step:getStatus(), "pipeline")
end
--@api-stub: LPipelineStep:getError -- Returns the error message if this step failed, or nil if it has not failed
do -- LPipelineStep:getError
  local step = lurek.pipeline.newStep("connect", function() end)
  local err = step:getError()
  lurek.log.info("error=" .. tostring(err), "pipeline")
end
--@api-stub: LPipelineStep:getDuration -- Returns how long this step took to execute in seconds (measured from start to completion or failure)
do -- LPipelineStep:getDuration
  local step = lurek.pipeline.newStep("gen_terrain", function() end)
  lurek.log.info("duration=" .. step:getDuration() .. "s", "pipeline")
end
--@api-stub: LPipelineStep:getAttempt -- Returns the current attempt number (1-based)
do -- LPipelineStep:getAttempt
  local step = lurek.pipeline.newStep("login", function() end)
  lurek.log.info("attempt=" .. step:getAttempt(), "pipeline")
end
--@api-stub: LPipelineStep:type -- Returns the type name of this object ("LPipelineStep")
do -- LPipelineStep:type
  local step = lurek.pipeline.newStep("test_step", function() end)
  local t = step:type()
  lurek.log.info("LPipelineStep:type=" .. t, "pipeline")
end
--@api-stub: LPipelineStep:typeOf -- Checks whether this object is of a given type name
do -- LPipelineStep:typeOf
  local step = lurek.pipeline.newStep("check_step", function() end)
  lurek.log.info("is PipelineStep: " .. tostring(step:typeOf("PipelineStep")), "pipeline")
  lurek.log.info("is wrong: " .. tostring(step:typeOf("Unknown")), "pipeline")
end

--@api-stub: LPipelineStep:setAsync -- Marks this step as asynchronous
do -- LPipelineStep:setAsync
  local p = lurek.pipeline.newPipeline()
  local step = lurek.pipeline.newStep("fetch", function(ctx) return ctx end)
  p:addStep(step)
  step:setAsync(true)
end

--@api-stub: LPipelineStep:isAsync -- Returns whether this step is configured for asynchronous coroutine execution
do -- LPipelineStep:isAsync
  local p = lurek.pipeline.newPipeline()
  local step = lurek.pipeline.newStep("transform", function(ctx) return ctx end)
  p:addStep(step)
  local async = step:isAsync()
end
