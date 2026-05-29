-- Agent Pipeline Demo
-- Run: cargo run -- content/games/showcase/agent_pipeline_demo

local MODEL_NAME = "llama3"
local BASE_URL = "http://127.0.0.1:11434"
local GENERATE_URL = BASE_URL .. "/api/generate"

local fallback_dispatch_after = 10.0
local elapsed = 0.0
local model_ready = false
local prompts_dispatched = false

---@type LOllamaManager?
local ollama = nil
---@type LAgent?
local planner = nil
---@type LAgent?
local designer = nil
---@type LAgent?
local critic = nil
---@type LAgentManager?
local manager = nil
---@type LAISystem?
local system = nil

---@type LWorkingMemory?
local wm = nil
---@type LEpisodicMemory?
local em = nil
---@type LSemanticMemory?
local sm = nil
---@type LAgentMemory?
local all_mem = nil

local logs = {}
local max_logs = 16

local function log_line(msg)
    local line = string.format("[agent-demo] %s", msg)
    print(line)
    logs[#logs + 1] = line
    if #logs > max_logs then
        table.remove(logs, 1)
    end
end

local function safe_len(v)
    if type(v) == "string" then return #v end
    if type(v) == "table" then
        local n = 0
        for _ in pairs(v) do
            n = n + 1
        end
        return n
    end
    return 0
end

local function summarize_payload(data)
    if type(data) == "table" then
        if data.response then return tostring(data.response) end
        if data.description then return tostring(data.description) end
        if data.text then return tostring(data.text) end
        return "<table payload>"
    end
    return tostring(data)
end

local function setup_global_config()
    lurek.agent.configure({
        provider = "ollama",
        base_url = BASE_URL,
        model = MODEL_NAME,
        timeout_ms = 30000,
        api_key = nil,
    })
    log_line("Global config set: provider=ollama model=" .. MODEL_NAME)
end

local function setup_ollama()
    ollama = lurek.agent.newOllama({ url = BASE_URL })
    log_line("Ollama base URL: " .. ollama:baseUrl())

    local running = ollama:isRunning()
    log_line("Ollama running before start: " .. tostring(running))
    if not running then
        local started = ollama:start()
        log_line("ollama:start() -> " .. tostring(started))
    end

    local has = ollama:hasModel(MODEL_NAME)
    log_line("Model present ('" .. MODEL_NAME .. "'): " .. tostring(has))
    if has then
        model_ready = true
        return
    end

    local pull_id = ollama:pullModel(MODEL_NAME, function(success, err_msg)
        if success then
            model_ready = true
            log_line("pullModel success for " .. MODEL_NAME)
        else
            log_line("pullModel failed: " .. tostring(err_msg))
        end
    end)
    log_line("pullModel dispatched id=" .. tostring(pull_id))
end

local function setup_agents()
    planner = lurek.agent.new({
        url = GENERATE_URL,
        model = MODEL_NAME,
        format = "json",
        system_prompt = "You plan short RPG encounters in bullet points.",
        max_retries = 2,
        timeout = 30,
    })
    planner:setName("planner")
    planner:setDescription("Breaks goals into clear implementation steps.")
    planner:addSkill("budget", "Keep scope under one screen and one scene.")
    planner:setTemperature(0.3)
    planner:setContextSize(4096)

    designer = lurek.agent.new({
        url = GENERATE_URL,
        model = MODEL_NAME,
        format = "json",
        system_prompt = "You design readable UI and combat pacing.",
        max_retries = 2,
        timeout = 30,
    })
    designer:setName("designer")
    designer:setDescription("Designs HUD, scene flow, and player clarity.")
    designer:addSkill("style", "Use concise, practical structure.")
    designer:setOption("seed", 42)

    critic = lurek.agent.new({
        url = GENERATE_URL,
        model = MODEL_NAME,
        format = "json",
        system_prompt = "You review risk, regressions, and missing tests.",
        max_retries = 2,
        timeout = 30,
    })
    critic:setName("critic")
    critic:setDescription("Finds reliability and testing gaps.")
    critic:addSkill("risk", "Prioritize severe user-facing failures.")
    critic:setTemperature(0.2)

    manager = lurek.agent.newManager()

    system = lurek.agent.newSystem({
        system_prompt = "You are a multi-agent game content coordinator.",
    })
    system:addAgent("planner", planner)
    system:addAgent("designer", designer)
    system:addAgent("critic", critic)
    system:addInstruction("output_shape", "Return concise structured JSON where possible.")
    system:addInstruction("demo_scope", "Focus on one small Lua demo scene.")
    system:addSkill("combat_skill", { "combat", "enemy", "damage", "boss" }, "Prefer deterministic and testable combat loops.")
    system:addSkill("ui_skill", { "ui", "hud", "menu", "panel" }, "Keep layout simple and readable at 960x540.")

    log_line("Agents ready: " .. tostring(system:agentCount()))
    log_line("Instructions ready: " .. tostring(system:instructionCount()))
    log_line("System skills ready: " .. tostring(system:skillCount()))

    local listed = planner:listSkills()
    log_line("Planner skills: " .. table.concat(listed, ", "))

    local ctx = system:buildContext(
        "Design combat HUD and enemy warning markers.",
        { agent = "designer", instructions = { "output_shape", "demo_scope" } }
    )
    log_line("Context preview length: " .. tostring(#ctx))
end

local function setup_memory_and_template()
    local p = planner
    if not p then
        log_line("Planner missing. Skipping evalCode demo.")
        return
    end

    wm = lurek.agent.newWorkingMemory(8)
    wm:push("phase", "boot")
    wm:push("target_model", MODEL_NAME)

    em = lurek.agent.newEpisodicMemory()
    em:record(1, { event = "init", module = "agent_demo" })

    sm = lurek.agent.newSemanticMemory()
    sm:learn("goal", { value = "show full agent pipeline" })

    all_mem = lurek.agent.newAgentMemory({
        working_capacity = 12,
        persist_path = "save/agent_pipeline_demo_memory.json",
    })
    all_mem:working():push("startup", true)

    local tmpl = lurek.agent.newTemplate("[TASK] {task} | [OWNER] {owner}")
    local rendered = tmpl:render({ task = "Prepare prompt sequence", owner = "system" })
    log_line("Template render: " .. rendered)

    local eval_ok = p:evalCode("print('[agent-demo] evalCode executed inside Lua VM')")
    log_line("planner:evalCode -> " .. tostring(eval_ok))
end

local function dispatch_prompts()
    if prompts_dispatched then return end

    local p_planner = planner
    local p_designer = designer
    local p_critic = critic
    local p_manager = manager
    local p_system = system
    if not p_planner or not p_designer or not p_critic or not p_manager or not p_system then
        log_line("Agent stack is incomplete. Prompt dispatch skipped.")
        return
    end

    prompts_dispatched = true
    log_line("Dispatching async prompt sequence...")

    local p1 = p_planner:prompt("Create 3 combat loop steps for a tiny arena demo.", function(success, data, err_info)
        if success then
            log_line("planner:prompt success len=" .. tostring(safe_len(data)))
            log_line("planner: " .. summarize_payload(data))
        else
            log_line("planner:prompt error " .. tostring(err_info.code) .. " - " .. tostring(err_info.message))
        end
    end)
    log_line("planner:prompt id=" .. tostring(p1))

    local p2 = p_designer:promptBatch({
        "Propose HUD labels for health and stamina.",
        "Propose one warning color scheme for low HP.",
        "Propose one minimal inventory panel layout.",
    }, function(results)
        log_line("designer:promptBatch results=" .. tostring(#results))
        for i, res in ipairs(results) do
            if res.success then
                log_line("designer batch " .. i .. " ok")
            else
                log_line("designer batch " .. i .. " error=" .. tostring(res.error.code))
            end
        end
    end)
    log_line("designer:promptBatch id=" .. tostring(p2))

    local p3 = p_manager:runAll({
        { agent = p_planner, instruction = "List 4 implementation tasks for this demo." },
        { agent = p_designer, instruction = "List 4 visual polish ideas for this demo." },
        { agent = p_critic, instruction = "List 4 failure risks and matching test checks." },
    }, function(results)
        log_line("manager:runAll finished tasks=" .. tostring(#results))
        for i, res in ipairs(results) do
            if res.success then
                log_line("manager task " .. i .. " ok")
            else
                log_line("manager task " .. i .. " error=" .. tostring(res.error.code))
            end
        end
    end)
    log_line("manager:runAll id=" .. tostring(p3))

    local p4 = p_system:prompt(
        "designer",
        "Design a compact combat HUD with low-HP warning and clear resource bars.",
        function(success, data, err_info)
            if success then
                log_line("system:prompt success")
                log_line("system designer: " .. summarize_payload(data))
            else
                log_line("system:prompt error " .. tostring(err_info.code) .. " - " .. tostring(err_info.message))
            end
        end,
        { instructions = { "output_shape", "demo_scope" } }
    )
    log_line("system:prompt id=" .. tostring(p4))

    local p5 = p_system:runAll({
        { agent = "planner", instruction = "Plan tutorial flow for first 30 seconds.", instructions = { "demo_scope" } },
        { agent = "critic", instruction = "Review this plan for regressions and missing tests.", instructions = { "output_shape" } },
    }, function(results)
        log_line("system:runAll finished tasks=" .. tostring(#results))
        for i, res in ipairs(results) do
            if res.success then
                log_line("system task " .. i .. " ok")
            else
                log_line("system task " .. i .. " error=" .. tostring(res.error.code))
            end
        end
    end)
    log_line("system:runAll id=" .. tostring(p5))

    lurek.agent.completeAsync("Give one short tip for stable Lua gameplay loops.", function(text, err)
        if err then
            log_line("completeAsync error: " .. tostring(err))
        else
            log_line("completeAsync: " .. tostring(text))
        end
    end)

    if wm then
        wm:push("phase", "dispatched")
    end
    if em then
        em:record(2, { event = "prompts_dispatched" })
    end
end

function lurek.init()
    lurek.render.setBackgroundColor(0.08, 0.1, 0.14)
    log_line("Init started")
    setup_global_config()
    setup_ollama()
    setup_agents()
    setup_memory_and_template()
    log_line("Init completed")
end

function lurek.process(dt)
    elapsed = elapsed + dt

    if lurek.input.keyboard.isDown("escape") then
        lurek.event.quit()
    end

    if ollama then ollama:update() end
    if planner then planner:update() end
    if designer then designer:update() end
    if critic then critic:update() end
    if manager then manager:update() end
    if system then system:update() end

    if not prompts_dispatched then
        if model_ready then
            dispatch_prompts()
        elseif elapsed >= fallback_dispatch_after then
            log_line("Fallback timeout reached. Dispatching prompts before model pull completes.")
            dispatch_prompts()
        end
    end
end

function lurek.draw()
    lurek.render.setColor(0.14, 0.18, 0.24, 1.0)
    lurek.render.rectangle("fill", 24, 24, 912, 492)

    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("Agent Pipeline Demo", 40, 42)
    lurek.render.print("MODEL: " .. MODEL_NAME, 40, 66)
    lurek.render.print("Ollama ready: " .. tostring(model_ready), 40, 88)
    lurek.render.print("Prompts dispatched: " .. tostring(prompts_dispatched), 40, 110)
    lurek.render.print("Pending pulls: " .. tostring(ollama and ollama:pendingCount() or 0), 40, 132)
    lurek.render.print("Planner pending: " .. tostring(planner and planner:pendingCount() or 0), 40, 154)
    lurek.render.print("Time: " .. string.format("%.1fs", elapsed), 40, 176)
    lurek.render.print("ESC = quit", 40, 198)

    lurek.render.setColor(0.84, 0.92, 1.0, 1.0)
    lurek.render.print("Recent logs (also in console):", 40, 232)
    local y = 254
    for i = math.max(1, #logs - 11), #logs do
        lurek.render.print(logs[i], 40, y)
        y = y + 20
    end
end
