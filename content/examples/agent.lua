-- content/examples/agent.lua
-- Run: cargo run -- content/examples/agent.lua

--- Agent Module: LLM AI interaction — lurek.agent

-- ─── lurek.agent.new ─────────────────────────────────────────────────────────

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.agent.new
do
    local agent = lurek.agent.new({
        url          = "http://localhost:11434/api/generate",
        model        = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        system_prompt = "You are a helpful game AI.",
        format       = "json",
        name         = "helper",
        description  = "Provides general assistance to the player.",
        max_retries  = 2,
        timeout      = 30,
        options      = {
            num_ctx     = 4096,
            temperature = 0.7,
            seed        = 42,
        },
    })
    example_print_log("Agent created:", agent)
end

-- ─── lurek.agent.newManager ──────────────────────────────────────────────────

--@api: lurek.agent.newManager
do
    local manager = lurek.agent.newManager()
    local writer = lurek.agent.new({ name = "writer" })
    local designer = lurek.agent.new({ name = "designer" })
    manager:update()
    lurek.log.info("shared manager ready for agents=" .. tostring(writer:getName()) .. "," .. tostring(designer:getName()))
    lurek.log.info("manager poll ran before any batch dispatch")
end

-- ─── lurek.agent.newSystem ───────────────────────────────────────────────────

--@api: lurek.agent.newSystem
do
    local system = lurek.agent.newSystem({
        system_prompt = "You are a multi-agent game orchestrator. Respond concisely.",
    })
    system:addInstruction("tone", "Keep every response short and actionable.")
    system:addSkill("sprite_rules", { "sprite", "tile", "palette" }, "Sprites use at most 16 colours.")
    local instructionCount = system:instructionCount()
    local skillCount = system:skillCount()
    lurek.log.info("ai system instructions=" .. tostring(instructionCount))
    lurek.log.info("ai system skills=" .. tostring(skillCount))
end

-- ─── LAgent:setName ──────────────────────────────────────────────────────────

--@api: LAgent:setName
do
    local agent = lurek.agent.new({})
    agent:setName("npc_writer")
    agent:setDescription("Writes short ambient barks for townsfolk.")
    local name = agent:getName()
    local description = agent:getDescription()
    lurek.log.info("agent name=" .. tostring(name))
    lurek.log.info("agent role=" .. tostring(description))
end

-- ─── LAgent:setDescription ───────────────────────────────────────────────────

--@api: LAgent:setDescription
do
    local agent = lurek.agent.new({})
    agent:setDescription("Specialises in writing NPC dialogue with emotional depth.")
    agent:setName("dialogue_director")
    local name = agent:getName()
    local description = agent:getDescription()
    lurek.log.info("dialogue agent=" .. tostring(name))
    lurek.log.info("dialogue brief=" .. tostring(description))
end

-- ─── LAgent:setModel ─────────────────────────────────────────────────────────

--@api: LAgent:setModel
do
    local agent = lurek.agent.new({ model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M" })
    agent:setModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M")
    agent:setFormat("json")
    local model = agent:getModel()
    local format = agent:getFormat()
    lurek.log.info("agent model=" .. tostring(model))
    lurek.log.info("agent output format=" .. tostring(format))
end

-- ─── LAgent:setUrl ───────────────────────────────────────────────────────────

--@api: LAgent:setUrl
do
    local agent = lurek.agent.new({})
    agent:setUrl("http://10.0.0.5:11434/api/generate")
    agent:setName("remote_writer")
    local url = agent:getUrl()
    local name = agent:getName()
    lurek.log.info("remote agent name=" .. tostring(name))
    lurek.log.info("remote agent url=" .. tostring(url))
end

-- ─── LAgent:setTimeout ───────────────────────────────────────────────────────

--@api: LAgent:setTimeout
do
    local agent = lurek.agent.new({})
    agent:setTimeout(90)
    agent:setName("long_form_writer")
    agent:setDescription("Drafts long quest logs without timing out early.")
    local name = agent:getName()
    local description = agent:getDescription()
    lurek.log.info("timeout tuned for agent=" .. tostring(name))
    lurek.log.info("timeout use case=" .. tostring(description))
end

-- ─── LAgent:getName ──────────────────────────────────────────────────────────

--@api: LAgent:getName
do
    local agent = lurek.agent.new({})
    agent:setName("planner")
    local name = agent:getName()
    agent:setDescription("Plans quest steps from player goals.")
    local description = agent:getDescription()
    lurek.log.info("planner agent name=" .. tostring(name))
    lurek.log.info("planner brief=" .. tostring(description))
end

-- ─── LAgent:getDescription ───────────────────────────────────────────────────

--@api: LAgent:getDescription
do
    local agent = lurek.agent.new({})
    agent:setDescription("Plans tasks.")
    local desc = agent:getDescription()
    agent:setName("task_router")
    local name = agent:getName()
    lurek.log.info("task router name=" .. tostring(name))
    lurek.log.info("task router description=" .. tostring(desc))
end

-- ─── LAgent:getModel ─────────────────────────────────────────────────────────

--@api: LAgent:getModel
do
    local agent = lurek.agent.new({ model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M" })
    agent:setFormat("json")
    local model = agent:getModel()
    local format = agent:getFormat()
    lurek.log.info("quest model=" .. tostring(model))
    lurek.log.info("quest format=" .. tostring(format))
end

-- ─── LAgent:getUrl ───────────────────────────────────────────────────────────

--@api: LAgent:getUrl
do
    local agent = lurek.agent.new({ url = "http://127.0.0.1:11434/api/generate" })
    agent:setName("local_preview")
    local url = agent:getUrl()
    local name = agent:getName()
    lurek.log.info("preview agent name=" .. tostring(name))
    lurek.log.info("preview agent url=" .. tostring(url))
end

-- ─── LAgent:getFormat ────────────────────────────────────────────────────────

--@api: LAgent:getFormat
do
    local agent = lurek.agent.new({ format = "json" })
    agent:setName("schema_writer")
    local format = agent:getFormat()
    local name = agent:getName()
    lurek.log.info("schema writer=" .. tostring(name))
    lurek.log.info("schema writer format=" .. tostring(format))
end

-- ─── LAgent:hasSkill ─────────────────────────────────────────────────────────

--@api: LAgent:hasSkill
do
    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is in the Darkwood forest.")
    agent:addSkill("weather", "Rain muffles footsteps and darkens the trail.")
    local hasLocation = agent:hasSkill("location")
    local hasWeather = agent:hasSkill("weather")
    lurek.log.info("location skill present=" .. tostring(hasLocation))
    lurek.log.info("weather skill present=" .. tostring(hasWeather))
end

-- ─── LAgent:skillCount ───────────────────────────────────────────────────────

--@api: LAgent:skillCount
do
    local agent = lurek.agent.new({})
    agent:addSkill("s1", "Context A.")
    agent:addSkill("s2", "Context B.")
    local count = agent:skillCount()
    local hasFirst = agent:hasSkill("s1")
    lurek.log.info("agent skill count=" .. tostring(count))
    lurek.log.info("first context skill present=" .. tostring(hasFirst))
end

-- ─── LAgent:listSkills ───────────────────────────────────────────────────────

--@api: LAgent:listSkills
do
    local agent = lurek.agent.new({})
    agent:addSkill("combat",    "Turn-based combat.")
    agent:addSkill("inventory", "Inventory management.")
    local names = agent:listSkills()
    for _, name in ipairs(names) do
        example_print_log("Skill:", name)
    end
end

-- ─── LAgent:addSkill ─────────────────────────────────────────────────────────

--@api: LAgent:addSkill
do
    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is currently in the Darkwood forest.")
    agent:addSkill("time",     "It is midnight in the game world.")
    local count = agent:skillCount()
    local hasTime = agent:hasSkill("time")
    lurek.log.info("context skills added=" .. tostring(count))
    lurek.log.info("time skill present=" .. tostring(hasTime))
end

-- ─── LAgent:clearSkills ──────────────────────────────────────────────────────

--@api: LAgent:clearSkills
do
    local agent = lurek.agent.new({})
    agent:addSkill("temp", "Some context.")
    local before = agent:skillCount()
    agent:clearSkills()
    local after = agent:skillCount()
    local stillHasTemp = agent:hasSkill("temp")
    lurek.log.info("skills before clear=" .. tostring(before))
    lurek.log.info("skills after clear=" .. tostring(after) .. " temp present=" .. tostring(stillHasTemp))
end

-- ─── LAgent:setOption ────────────────────────────────────────────────────────

--@api: LAgent:setOption
do
    local agent = lurek.agent.new({})
    agent:setOption("temperature", 0.4)
    agent:setOption("seed", 1234)
    agent:setName("deterministic_writer")
    local name = agent:getName()
    local format = agent:getFormat()
    lurek.log.info("custom options set for=" .. tostring(name))
    lurek.log.info("current response format=" .. tostring(format))
end

-- ─── LAgent:setFormat ────────────────────────────────────────────────────────

--@api: LAgent:setFormat
do
    local agent = lurek.agent.new({})
    agent:setFormat("text")
    agent:setName("narration_writer")
    local format = agent:getFormat()
    local name = agent:getName()
    lurek.log.info("narration writer=" .. tostring(name))
    lurek.log.info("narration format=" .. tostring(format))
end

-- ─── LAgent:setMaxRetries ────────────────────────────────────────────────────

--@api: LAgent:setMaxRetries
do
    local agent = lurek.agent.new({})
    agent:setMaxRetries(3)
    agent:setName("resilient_writer")
    agent:setTimeout(45)
    local name = agent:getName()
    local url = agent:getUrl()
    lurek.log.info("retry policy updated for=" .. tostring(name))
    lurek.log.info("writer endpoint=" .. tostring(url))
end

-- ─── LAgent:setContextSize ───────────────────────────────────────────────────

--@api: LAgent:setContextSize
do
    local agent = lurek.agent.new({})
    agent:setContextSize(8192)
    agent:setName("lore_keeper")
    agent:addSkill("history", "Keeps settlement, faction, and boss lore in context.")
    local name = agent:getName()
    local skillCount = agent:skillCount()
    lurek.log.info("context window expanded for=" .. tostring(name))
    lurek.log.info("lore keeper skill count=" .. tostring(skillCount))
end

-- ─── LAgent:setTemperature ───────────────────────────────────────────────────

--@api: LAgent:setTemperature
do
    local agent = lurek.agent.new({})
    agent:setTemperature(0.9)
    agent:setName("bark_writer")
    agent:setFormat("text")
    local name = agent:getName()
    local format = agent:getFormat()
    lurek.log.info("creative temperature set for=" .. tostring(name))
    lurek.log.info("creative output format=" .. tostring(format))
end

-- ─── LAgent:prompt ───────────────────────────────────────────────────────────

--@api: LAgent:prompt
do
    local agent = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        format = "json",
    })

    -- Async — must call agent:update() in the game loop to receive callbacks.
    local id = agent:prompt("Describe what the player sees when entering the forest.", function(success, data, err_info)
        if success then
            example_print_log("Response:", data.description or data.response)
        else
            example_print_log("Error [" .. err_info.code .. "]:", err_info.message)
        end
    end)
    example_print_log("Prompt dispatched, id =", id)
end

-- ─── LAgent:promptBatch ──────────────────────────────────────────────────────

--@api: LAgent:promptBatch
do
    local agent = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        format = "json",
    })

    local id = agent:promptBatch({
        "Describe the bridge.",
        "Describe the engine room.",
        "Describe the dungeon entrance.",
    }, function(results)
        for i, res in ipairs(results) do
            if res.success then
                example_print_log("Result " .. i .. ":", res.data.description)
            else
                example_print_log("Task " .. i .. " failed [" .. res.error.code .. "]:", res.error.message)
            end
        end
    end)
    example_print_log("Batch dispatched, id =", id)
end

-- ─── LAgent:cancel ───────────────────────────────────────────────────────────

--@api: LAgent:cancel
do
    local agent = lurek.agent.new({
        url = "http://localhost:11434/api/generate",
        model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
    })
    local id = agent:prompt("Long-running request.", function() end)
    agent:cancel(id)
    example_print_log("Request cancelled, id =", id)
end

-- ─── LAgent:pendingCount ─────────────────────────────────────────────────────

--@api: LAgent:pendingCount
do
    local agent = lurek.agent.new({})
    agent:setName("quest_writer")
    local beforeUpdate = agent:pendingCount()
    agent:update()
    local afterUpdate = agent:pendingCount()
    lurek.log.info("pending prompts before poll=" .. tostring(beforeUpdate))
    lurek.log.info("pending prompts after poll=" .. tostring(afterUpdate))
end

--@api: LAgent:getDiagnostics
do
    local agent = lurek.agent.new({})
    local diagnostics = agent:getDiagnostics()
    lurek.log.info("agent in_flight=" .. tostring(diagnostics.in_flight))
    lurek.log.info("agent queued=" .. tostring(diagnostics.queued))
    lurek.log.info("agent backend_failures=" .. tostring(diagnostics.backend_failures))
end

-- ─── LAgent:update ───────────────────────────────────────────────────────────

--@api: LAgent:update
do
    local agent = lurek.agent.new({})
    agent:setName("ambient_writer")
    local before = agent:pendingCount()
    agent:update()
    local after = agent:pendingCount()
    lurek.log.info("ambient writer pending before update=" .. tostring(before))
    lurek.log.info("ambient writer pending after update=" .. tostring(after))
end

-- ─── LAgent:evalCode ─────────────────────────────────────────────────────────

--@api: LAgent:evalCode
do
    local agent = lurek.agent.new({})
    local ok = agent:evalCode("local hp = 12 + 8; _G.agent_eval_hp = hp")
    local queueDepth = agent:pendingCount()
    local format = agent:getFormat()
    lurek.log.info("evalCode success=" .. tostring(ok))
    lurek.log.info("queue depth=" .. tostring(queueDepth) .. " format=" .. tostring(format))
end

-- ─── LAgentManager:runAll ────────────────────────────────────────────────────

--@api: LAgentManager:runAll
do
    local manager = lurek.agent.newManager()

    local writer   = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    local designer = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })

    local id = manager:runAll({
        { agent = writer,   instruction = "Write a boss intro monologue." },
        { agent = designer, instruction = "Design the boss arena layout."  },
    }, function(results)
        for i, res in ipairs(results) do
            example_print_log("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    example_print_log("Manager batch dispatched, id =", id)
end

-- ─── LAgentManager:update ────────────────────────────────────────────────────

--@api: LAgentManager:update
do
    local manager = lurek.agent.newManager()
    local writer = lurek.agent.new({ name = "writer" })
    local critic = lurek.agent.new({ name = "critic" })
    manager:update()
    lurek.log.info("manager polled shared queue for=" .. tostring(writer:getName()))
    lurek.log.info("manager also tracks=" .. tostring(critic:getName()))
end

-- ─── LAISystem:addAgent ──────────────────────────────────────────────────────

--@api: LAISystem:addAgent
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })

    local npc = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    npc:setDescription("Writes NPC dialogue with emotional depth and regional accents.")

    system:addAgent("npc_writer", npc)
    example_print_log("Agent 'npc_writer' added to system.")
end

-- ─── LAISystem:removeAgent ───────────────────────────────────────────────────

--@api: LAISystem:removeAgent
do
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("temp_agent", agent)
    local removed = system:removeAgent("temp_agent")
    example_print_log("Agent removed:", removed)
end

-- ─── LAISystem:listAgents ────────────────────────────────────────────────────

--@api: LAISystem:listAgents
do
    local system = lurek.agent.newSystem({})
    local a = lurek.agent.new({})
    system:addAgent("writer",   a)
    system:addAgent("designer", a)
    local names = system:listAgents()
    for _, name in ipairs(names) do
        example_print_log("Registered agent:", name)
    end
end

-- ─── LAISystem:hasAgent ──────────────────────────────────────────────────────

--@api: LAISystem:hasAgent
do
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("planner", agent)
    example_print_log("Has 'planner':", system:hasAgent("planner"))
    example_print_log("Has 'ghost':",   system:hasAgent("ghost"))
end

-- ─── LAISystem:agentCount ────────────────────────────────────────────────────

--@api: LAISystem:agentCount
do
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("a1", agent)
    system:addAgent("a2", agent)
    example_print_log("Agent count:", system:agentCount())
end

-- ─── LAISystem:addInstruction ────────────────────────────────────────────────

--@api: LAISystem:addInstruction
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("art_style", "Use a 16-bit pixel art visual style. Palettes are limited to 16 colours per sprite.")
    system:addInstruction("tone",      "Keep all responses concise and in present tense.")
    local count = system:instructionCount()
    local hasTone = system:hasInstruction("tone")
    lurek.log.info("system instruction count=" .. tostring(count))
    lurek.log.info("tone instruction present=" .. tostring(hasTone))
end

-- ─── LAISystem:removeInstruction ─────────────────────────────────────────────

--@api: LAISystem:removeInstruction
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("debug_hint", "Temporary debug context.")
    local removed = system:removeInstruction("debug_hint")
    local stillPresent = system:hasInstruction("debug_hint")
    local count = system:instructionCount()
    lurek.log.info("instruction removed=" .. tostring(removed))
    lurek.log.info("debug hint still present=" .. tostring(stillPresent) .. " count=" .. tostring(count))
end

-- ─── LAISystem:hasInstruction ────────────────────────────────────────────────

--@api: LAISystem:hasInstruction
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone", "Be concise.")
    system:addInstruction("art_style", "Use pixel art silhouettes.")
    local hasTone = system:hasInstruction("tone")
    local hasMissing = system:hasInstruction("missing")
    lurek.log.info("tone instruction present=" .. tostring(hasTone))
    lurek.log.info("missing instruction present=" .. tostring(hasMissing))
end

-- ─── LAISystem:instructionCount ──────────────────────────────────────────────

--@api: LAISystem:instructionCount
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    local count = system:instructionCount()
    local hasArtStyle = system:hasInstruction("art_style")
    lurek.log.info("instruction count=" .. tostring(count))
    lurek.log.info("art_style instruction present=" .. tostring(hasArtStyle))
end

-- ─── LAISystem:listInstructions ──────────────────────────────────────────────

--@api: LAISystem:listInstructions
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    local keys = system:listInstructions()
    for _, key in ipairs(keys) do
        example_print_log("Instruction key:", key)
    end
end

-- ─── LAISystem:addSkill ──────────────────────────────────────────────────────

--@api: LAISystem:addSkill
do
    local system = lurek.agent.newSystem({})
    -- Lurek auto-injects this skill when the user prompt contains any listed keyword.
    system:addSkill(
        "pixel_art_rules",
        { "pixel art", "sprite", "texture", "tileset", "palette" },
        "Pixel art must use orthographic projection and a maximum of 16 colours per tile."
    )
    system:addSkill(
        "combat_rules",
        { "combat", "attack", "damage", "enemy", "boss" },
        "Combat uses turn-based resolution with action points (AP) per entity."
    )
    example_print_log("System skills added.")
end

-- ─── LAISystem:removeSkill ───────────────────────────────────────────────────

--@api: LAISystem:removeSkill
do
    local system = lurek.agent.newSystem({})
    system:addSkill("temp_skill", { "test" }, "Temporary.")
    local removed = system:removeSkill("temp_skill")
    local stillPresent = system:hasSkill("temp_skill")
    local count = system:skillCount()
    lurek.log.info("system skill removed=" .. tostring(removed))
    lurek.log.info("temp skill still present=" .. tostring(stillPresent) .. " count=" .. tostring(count))
end

-- ─── LAISystem:hasSkill ──────────────────────────────────────────────────────

--@api: LAISystem:hasSkill
do
    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules", { "combat", "attack" }, "Turn-based combat.")
    system:addSkill("stealth_rules", { "stealth", "noise" }, "Noise raises patrol suspicion.")
    local hasCombatRules = system:hasSkill("combat_rules")
    local hasMissing = system:hasSkill("no_such_skill")
    lurek.log.info("combat rules present=" .. tostring(hasCombatRules))
    lurek.log.info("missing rules present=" .. tostring(hasMissing))
end

-- ─── LAISystem:skillCount ────────────────────────────────────────────────────

--@api: LAISystem:skillCount
do
    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules",   { "combat" },        "Turn-based combat.")
    system:addSkill("pixel_art_rules", { "sprite", "tile" }, "16 colours max.")
    local count = system:skillCount()
    local hasPixelArt = system:hasSkill("pixel_art_rules")
    lurek.log.info("system skill count=" .. tostring(count))
    lurek.log.info("pixel art rules present=" .. tostring(hasPixelArt))
end

-- ─── LAISystem:buildContext ──────────────────────────────────────────────────

--@api: LAISystem:buildContext
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game AI." })
    system:addInstruction("art_style", "Use pixel art, 16 colours max.")
    system:addSkill("combat_rules", { "combat", "attack" }, "Turn-based combat with AP.")

    local npc = lurek.agent.new({})
    npc:setDescription("NPC dialogue specialist.")
    system:addAgent("npc_writer", npc)

    -- Preview the full context that would be sent for this instruction.
    local ctx = system:buildContext(
        "Design an attack animation for the boss.",
        { agent = "npc_writer", instructions = { "art_style" } }
    )
    example_print_log("Context preview:\n", ctx)
end

--@api: LAISystem:buildContextReport
do
    local system = lurek.agent.newSystem({ system_prompt = "base context" })
    system:addInstruction("safety", "be safe")
    system:addSkill("math", { "matrix" }, "help with math")
    local report = system:buildContextReport("solve matrix problem", {
        instructions = { "safety" },
    })
    lurek.log.info("context report text length=" .. tostring(#report.text))
    lurek.log.info("context provenance count=" .. tostring(#report.provenance))
    lurek.log.info("first provenance kind=" .. tostring(report.provenance[1] and report.provenance[1].kind))
end

-- ─── LAISystem:prompt ────────────────────────────────────────────────────────

--@api: LAISystem:prompt
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })
    system:addInstruction("art_style", "Use 16-bit pixel art.")
    system:addSkill("pixel_art_rules", { "sprite", "texture" }, "Max 16 colours per tile.")

    local designer = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        format = "json",
    })
    designer:setDescription("Visual design specialist focusing on sprites and environments.")
    system:addAgent("designer", designer)

    -- Keyword "sprite" triggers auto-injection of "pixel_art_rules".
    -- "art_style" is explicitly included via opts.instructions.
    local id = system:prompt(
        "designer",
        "Design a player sprite for the main character.",
        function(success, data, err_info)
            if success then
                example_print_log("Design:", data.description)
            else
                example_print_log("Error:", err_info.message)
            end
        end,
        { instructions = { "art_style" } }
    )
    example_print_log("System prompt dispatched, id =", id)
end

-- ─── LAISystem:runAll ────────────────────────────────────────────────────────

--@api: LAISystem:runAll
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game AI team." })
    system:addInstruction("art_style", "16-bit pixel art.")

    local writer   = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    local designer = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", format = "json" })
    writer:setDescription("Writes story and NPC dialogue.")
    designer:setDescription("Designs levels and visual assets.")

    system:addAgent("writer",   writer)
    system:addAgent("designer", designer)

    -- Each task specifies which agent to route to and which instructions to include.
    local id = system:runAll({
        { agent = "writer",   instruction = "Write boss intro text.", instructions = {} },
        { agent = "designer", instruction = "Design the boss arena.", instructions = { "art_style" } },
    }, function(results)
        for i, res in ipairs(results) do
            example_print_log("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    example_print_log("System runAll dispatched, id =", id)
end

-- ─── LAISystem:update ────────────────────────────────────────────────────────

--@api: LAISystem:update
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("combat", "Prioritise concise combat advice.")
    system:addSkill("boss_phase", { "boss", "phase" }, "Mention boss phase changes explicitly.")
    local instruction_count = system:instructionCount()
    local skill_count = system:skillCount()
    system:update()
    lurek.log.info("system update polled background requests")
    lurek.log.info("system instructions=" .. tostring(instruction_count))
    lurek.log.info("system skills=" .. tostring(skill_count))
end

--@api: LAISystem:getDiagnostics
do
    local system = lurek.agent.newSystem({})
    local diagnostics = system:getDiagnostics()
    lurek.log.info("system in_flight=" .. tostring(diagnostics.in_flight))
    lurek.log.info("system queued=" .. tostring(diagnostics.queued))
    lurek.log.info("system network_failures=" .. tostring(diagnostics.network_failures))
end

-- ─── lurek.agent.newOllama ───────────────────────────────────────────────────

--@api: lurek.agent.newOllama
do
    local ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
    local base_url = ollama:baseUrl()
    local running = ollama:isRunning()
    local pending = ollama:pendingCount()
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("ollama reachable=" .. tostring(running))
    lurek.log.info("pull jobs pending=" .. tostring(pending))
end

-- ─── LOllamaManager:isRunning ────────────────────────────────────────────────

--@api: LOllamaManager:isRunning
do
    local ollama  = lurek.agent.newOllama()
    local running = ollama:isRunning()
    local base_url = ollama:baseUrl()
    local version = ollama:version()
    lurek.log.info("ollama running=" .. tostring(running))
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("ollama version probe=" .. tostring(version))
end

-- ─── LOllamaManager:version ──────────────────────────────────────────────────

--@api: LOllamaManager:version
do
    local ollama = lurek.agent.newOllama()
    local version = ollama:version()
    local base_url = ollama:baseUrl()
    local running = ollama:isRunning()
    lurek.log.info("ollama version=" .. tostring(version))
    lurek.log.info("ollama base url=" .. tostring(base_url))
    lurek.log.info("ollama running=" .. tostring(running))
end

-- ─── LOllamaManager:baseUrl ──────────────────────────────────────────────────

--@api: LOllamaManager:baseUrl
do
    local ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
    local url = ollama:baseUrl()
    local running = ollama:isRunning()
    local pending = ollama:pendingCount()
    lurek.log.info("ollama base url=" .. tostring(url))
    lurek.log.info("ollama running=" .. tostring(running))
    lurek.log.info("ollama pull queue=" .. tostring(pending))
end

-- ─── LOllamaManager:listModels ───────────────────────────────────────────────

--@api: LOllamaManager:listModels
do
    local ollama = lurek.agent.newOllama()
    local models = ollama:listModels()
    for _, m in ipairs(models) do
        example_print_log(m.name, string.format("%.1f GB", m.size_gb))
    end
end

-- ─── LOllamaManager:modelNames ───────────────────────────────────────────────

--@api: LOllamaManager:modelNames
do
    local ollama = lurek.agent.newOllama()
    local names  = ollama:modelNames()
    for _, name in ipairs(names) do
        example_print_log("Available model:", name)
    end
end

-- ─── LOllamaManager:hasModel ─────────────────────────────────────────────────

--@api: LOllamaManager:hasModel
do
    local ollama = lurek.agent.newOllama()
    local target_model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M"
    local found = ollama:hasModel(target_model)
    local running = ollama:isRunning()
    local base_url = ollama:baseUrl()
    lurek.log.info("model available=" .. tostring(found))
    lurek.log.info("model probe target=" .. target_model)
    lurek.log.info("ollama at " .. tostring(base_url) .. " running=" .. tostring(running))
end

-- ─── LOllamaManager:start ────────────────────────────────────────────────────

--@api: LOllamaManager:start
do
    local ollama = lurek.agent.newOllama()
    local started = ollama:start()
    local running = ollama:isRunning()
    local base_url = ollama:baseUrl()
    lurek.log.info("ollama start requested=" .. tostring(started))
    lurek.log.info("ollama running after start=" .. tostring(running))
    lurek.log.info("ollama base url=" .. tostring(base_url))
end

-- ─── LOllamaManager:stop ─────────────────────────────────────────────────────

--@api: LOllamaManager:stop
do
    local ollama = lurek.agent.newOllama()
    local running_before = ollama:isRunning()
    local stopped = ollama:stop()
    local running_after = ollama:isRunning()
    lurek.log.info("ollama running before stop=" .. tostring(running_before))
    lurek.log.info("ollama stop requested=" .. tostring(stopped))
    lurek.log.info("ollama running after stop=" .. tostring(running_after))
end

-- ─── LOllamaManager:restart ──────────────────────────────────────────────────

--@api: LOllamaManager:restart
do
    local ollama = lurek.agent.newOllama()
    local running_before = ollama:isRunning()
    local restarted = ollama:restart()
    local running_after = ollama:isRunning()
    lurek.log.info("ollama running before restart=" .. tostring(running_before))
    lurek.log.info("ollama restart requested=" .. tostring(restarted))
    lurek.log.info("ollama running after restart=" .. tostring(running_after))
end

-- ─── LOllamaManager:pullModel ────────────────────────────────────────────────

--@api: LOllamaManager:pullModel
do
    local ollama = lurek.agent.newOllama()
    local id     = ollama:pullModel("SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M", function(success, err_msg)
        if success then
            example_print_log("Model downloaded successfully.")
        else
            example_print_log("Pull failed:", err_msg)
        end
    end)
    example_print_log("Pull started, callback id =", id)
end

--@api: LOllamaManager:cancelPull
do
    local ollama = lurek.agent.newOllama()
    local id = ollama:pullModel("llama3", function(success, err_msg)
        example_print_log("cancelPull callback", tostring(success), tostring(err_msg))
    end)
    local ok = ollama:cancelPull(id)
    lurek.log.info("cancel pull id=" .. tostring(id))
    lurek.log.info("cancel pull accepted=" .. tostring(ok))
end

-- ─── LOllamaManager:deleteModel ──────────────────────────────────────────────

--@api: LOllamaManager:deleteModel
do
    local ollama = lurek.agent.newOllama()
    local target_model = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M"
    local existed_before = ollama:hasModel(target_model)
    local deleted = ollama:deleteModel(target_model)
    local pending = ollama:pendingCount()
    lurek.log.info("model existed before delete=" .. tostring(existed_before))
    lurek.log.info("delete request accepted=" .. tostring(deleted))
    lurek.log.info("pending pull jobs=" .. tostring(pending))
end

-- ─── LOllamaManager:pendingCount ─────────────────────────────────────────────

--@api: LOllamaManager:pendingCount
do
    local ollama = lurek.agent.newOllama()
    local pending = ollama:pendingCount()
    local running = ollama:isRunning()
    local version = ollama:version()
    lurek.log.info("in-flight pulls=" .. tostring(pending))
    lurek.log.info("ollama running=" .. tostring(running))
    lurek.log.info("ollama version probe=" .. tostring(version))
end

--@api: LOllamaManager:getDiagnostics
do
    local ollama = lurek.agent.newOllama()
    local diagnostics = ollama:getDiagnostics()
    lurek.log.info("ollama in_flight_pulls=" .. tostring(diagnostics.in_flight_pulls))
    lurek.log.info("ollama queued_pulls=" .. tostring(diagnostics.queued_pulls))
    lurek.log.info("ollama last_error=" .. tostring(diagnostics.last_error))
end

-- ─── LOllamaManager:update ───────────────────────────────────────────────────

--@api: LOllamaManager:update
do
    local ollama = lurek.agent.newOllama()
    local pending_before = ollama:pendingCount()
    ollama:update()
    local pending_after = ollama:pendingCount()
    lurek.log.info("ollama update flushed callbacks")
    lurek.log.info("pending before update=" .. tostring(pending_before))
    lurek.log.info("pending after update=" .. tostring(pending_after))
end

-- ─── lurek.agent.configure ───────────────────────────────────────────────────

--@api: lurek.agent.configure
do
    lurek.agent.configure({
        provider    = "ollama",
        base_url    = "http://127.0.0.1:11434",
        model       = "SpeakLeash/bielik-11b-v3.0-instruct:Q4_K_M",
        timeout_ms  = 30000,
        api_key     = nil,
    })
end

-- ─── lurek.agent.complete ────────────────────────────────────────────────────

--@api: lurek.agent.complete
do
    local ok, reply = pcall(function()
        return lurek.agent.complete("Hello, world!")
    end)
    example_print_log("complete ok:", ok)
    example_print_log("Reply:", reply)
end

-- ─── lurek.agent.completeAsync ───────────────────────────────────────────────

--@api: lurek.agent.completeAsync
do
    local ok, err = pcall(function()
        local id = lurek.agent.completeAsync("What is Lua?", function(text, async_err)
            if async_err then
                example_print_log("Error:", async_err)
            else
                example_print_log("Async reply:", text)
            end
        end)
        example_print_log("completeAsync id:", id)
        lurek.agent.update()
    end)
    example_print_log("completeAsync ok:", ok)
    if not ok then example_print_log("completeAsync error:", err) end
end

--@api: lurek.agent.update
do
    local pending_before = lurek.agent.pendingCount()
    lurek.agent.update()
    local pending_after = lurek.agent.pendingCount()
    lurek.log.info("module update polled background agent work")
    lurek.log.info("pending before=" .. tostring(pending_before))
    lurek.log.info("pending after=" .. tostring(pending_after))
end

--@api: lurek.agent.pendingCount
do
    local pending = lurek.agent.pendingCount()
    lurek.agent.update()
    local pending_after_update = lurek.agent.pendingCount()
    lurek.log.info("module pending count=" .. tostring(pending))
    lurek.log.info("pending after poll=" .. tostring(pending_after_update))
    lurek.log.info("queue idle=" .. tostring(pending_after_update == 0))
end

--@api: lurek.agent.getDiagnostics
do
    local diagnostics = lurek.agent.getDiagnostics()
    lurek.log.info("module in_flight=" .. tostring(diagnostics.in_flight))
    lurek.log.info("module queued=" .. tostring(diagnostics.queued))
    lurek.log.info("module timeout_failures=" .. tostring(diagnostics.timeout_failures))
    lurek.log.info("module backend_failures=" .. tostring(diagnostics.backend_failures))
end

--@api: lurek.agent.cancel
do
    local pending_before = lurek.agent.pendingCount()
    lurek.agent.cancel(999999)
    local pending_after = lurek.agent.pendingCount()
    lurek.log.info("cancel issued for unknown callback id")
    lurek.log.info("pending before cancel=" .. tostring(pending_before))
    lurek.log.info("pending after cancel=" .. tostring(pending_after))
end

-- ─── lurek.agent.newChat ─────────────────────────────────────────────────────

--@api: lurek.agent.newChat
do
    local chat = lurek.agent.newChat()
    chat:setSystemPrompt("You are a quest hint assistant.")
    chat:addMessage("user", "Summarise the current quest in one sentence.")
    local history = chat:getHistory()
    lurek.log.info("chat history count=" .. tostring(#history))
    lurek.log.info("chat first role=" .. tostring(history[1] and history[1].role or "nil"))
    lurek.log.info("chat first content=" .. tostring(history[1] and history[1].content or "nil"))
end

-- ─── LAgentChat:setSystemPrompt ──────────────────────────────────────────────

--@api: LAgentChat:setSystemPrompt
do
    local chat = lurek.agent.newChat()
    chat:setSystemPrompt("You are a helpful assistant.")
    chat:addMessage("user", "Explain the stamina system.")
    local history = chat:getHistory()
    local last_role = history[#history] and history[#history].role or "nil"
    lurek.log.info("chat system prompt configured")
    lurek.log.info("chat history count=" .. tostring(#history))
    lurek.log.info("chat last role=" .. tostring(last_role))
end

-- ─── LAgentChat:addMessage ───────────────────────────────────────────────────

--@api: LAgentChat:addMessage
do
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Tell me a joke.")
    chat:addMessage("assistant", "Parries are no laughing matter.")
    local history = chat:getHistory()
    lurek.log.info("chat history count=" .. tostring(#history))
    lurek.log.info("first role=" .. tostring(history[1] and history[1].role or "nil"))
    lurek.log.info("last role=" .. tostring(history[#history] and history[#history].role or "nil"))
end

-- ─── LAgentChat:complete ─────────────────────────────────────────────────────

--@api: LAgentChat:complete
do
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hi!")
    local ok, reply = pcall(function()
        return chat:complete()
    end)
    example_print_log("chat complete ok:", ok)
    example_print_log("Chat reply:", reply)
end

-- ─── LAgentChat:clear ────────────────────────────────────────────────────────

--@api: LAgentChat:clear
do
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hello")
    chat:addMessage("assistant", "Hi there.")
    local before = #chat:getHistory()
    chat:clear()
    local after = #chat:getHistory()
    lurek.log.info("chat messages before clear=" .. tostring(before))
    lurek.log.info("chat messages after clear=" .. tostring(after))
    lurek.log.info("chat cleared=" .. tostring(after == 0))
end

-- ─── LAgentChat:getHistory ───────────────────────────────────────────────────

--@api: LAgentChat:getHistory
do
    local chat = lurek.agent.newChat()
    chat:addMessage("system", "You are a merchant helper.")
    chat:addMessage("user", "What does this potion do?")
    local history = chat:getHistory()
    local first_role = history[1] and history[1].role or "nil"
    local last_role = history[#history] and history[#history].role or "nil"
    lurek.log.info("history entries=" .. tostring(#history))
    lurek.log.info("first role=" .. tostring(first_role))
    lurek.log.info("last role=" .. tostring(last_role))
end

-- ─── lurek.agent.newTemplate ─────────────────────────────────────────────────

--@api: lurek.agent.newTemplate
do
    local tmpl = lurek.agent.newTemplate("Hello, {name}!")
    local rendered = tmpl:render({ name = "Rhea" })
    local rendered_again = tmpl:render({ name = "Milo" })
    lurek.log.info("template rendered once=" .. tostring(rendered))
    lurek.log.info("template rendered twice=" .. tostring(rendered_again))
    lurek.log.info("template swaps placeholders for NPC names")
end

-- ─── LAgentTemplate:render ───────────────────────────────────────────────────

--@api: LAgentTemplate:render
do
    local tmpl = lurek.agent.newTemplate("Hello, {name}! You are {age} years old.")
    local first = tmpl:render({ name = "Alice", age = "30" })
    local second = tmpl:render({ name = "Borin", age = "52" })
    local has_alice = first:find("Alice", 1, true) ~= nil
    lurek.log.info("first render=" .. tostring(first))
    lurek.log.info("second render=" .. tostring(second))
    lurek.log.info("alice placeholder resolved=" .. tostring(has_alice))
end

-- ─── lurek.agent.completeJson ────────────────────────────────────────────────

--@api: lurek.agent.completeJson
do
    local ok, result = pcall(function()
        return lurek.agent.completeJson("List three colors as JSON.")
    end)
    example_print_log("completeJson ok:", ok)
    example_print_log("JSON result:", result)
end

-- ─── lurek.agent.embed ───────────────────────────────────────────────────────

--@api: lurek.agent.embed
do
    local ok, vec = pcall(function()
        return lurek.agent.embed("Semantic embedding test.")
    end)
    example_print_log("embed ok:", ok)
    example_print_log("Embedding dimensions:", ok and #vec or 0)
end

-- ─── lurek.agent.isAvailable ─────────────────────────────────────────────────

--@api: lurek.agent.isAvailable
do
    local available = lurek.agent.isAvailable()
    local pending = lurek.agent.pendingCount()
    lurek.agent.update()
    lurek.log.info("llm available=" .. tostring(available))
    lurek.log.info("pending async completions=" .. tostring(pending))
    lurek.log.info("availability probe finished")
end

-- ─── lurek.agent.listModels ──────────────────────────────────────────────────

--@api: lurek.agent.listModels
do
    local models = lurek.agent.listModels()
    local first_model = models[1] or "none"
    local model_count = #models
    local available = lurek.agent.isAvailable()
    lurek.log.info("available model count=" .. tostring(model_count))
    lurek.log.info("first model=" .. tostring(first_model))
    lurek.log.info("backend reachable=" .. tostring(available))
end

-- ─── lurek.agent.newWorkingMemory ────────────────────────────────────────────

--@api: lurek.agent.newWorkingMemory
do
    local wm = lurek.agent.newWorkingMemory(16)
    wm:push("quest", "Find the moon shard")
    local capacity = wm:capacity()
    local size = wm:len()
    lurek.log.info("working memory capacity=" .. tostring(capacity))
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("quest memory=" .. tostring(wm:get("quest")))
end

-- ─── LWorkingMemory:push ─────────────────────────────────────────────────────

--@api: LWorkingMemory:push
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("last_action", "jump")
    wm:push("last_room", "tower_top")
    local action = wm:get("last_action")
    local size = wm:len()
    lurek.log.info("last action=" .. tostring(action))
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("last room=" .. tostring(wm:get("last_room")))
end

-- ─── LWorkingMemory:get ──────────────────────────────────────────────────────

--@api: LWorkingMemory:get
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("hp", 100)
    wm:push("mana", 35)
    local hp = wm:get("hp")
    local mana = wm:get("mana")
    local size = wm:len()
    lurek.log.info("hp=" .. tostring(hp))
    lurek.log.info("mana=" .. tostring(mana))
    lurek.log.info("working memory size=" .. tostring(size))
end

-- ─── LWorkingMemory:forget ───────────────────────────────────────────────────

--@api: LWorkingMemory:forget
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("temp", "value")
    wm:push("stable", "keep")
    local before = wm:len()
    local removed = wm:forget("temp")
    local after = wm:len()
    local stable = wm:get("stable")
    lurek.log.info("removed temp entry=" .. tostring(removed))
    lurek.log.info("size before forget=" .. tostring(before))
    lurek.log.info("size after forget=" .. tostring(after) .. " stable=" .. tostring(stable))
end

-- ─── LWorkingMemory:getRecent ────────────────────────────────────────────────

--@api: LWorkingMemory:getRecent
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("a", 1)
    wm:push("b", 2)
    local recent = wm:getRecent(2)
    example_print_log("Recent entries:", #recent)
end

-- ─── LWorkingMemory:len ──────────────────────────────────────────────────────

--@api: LWorkingMemory:len
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("x", 42)
    wm:push("y", 84)
    local size = wm:len()
    local recent = wm:getRecent(2)
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("recent entries=" .. tostring(#recent))
    lurek.log.info("latest key=" .. tostring(recent[1] and recent[1].key or "nil"))
end

-- ─── LWorkingMemory:capacity ─────────────────────────────────────────────────

--@api: LWorkingMemory:capacity
do
    local wm = lurek.agent.newWorkingMemory(32)
    wm:push("objective", "Escort the caravan")
    local capacity = wm:capacity()
    local size = wm:len()
    lurek.log.info("working memory capacity=" .. tostring(capacity))
    lurek.log.info("working memory size=" .. tostring(size))
    lurek.log.info("objective=" .. tostring(wm:get("objective")))
end

-- ─── lurek.agent.newEpisodicMemory ───────────────────────────────────────────

--@api: lurek.agent.newEpisodicMemory
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { event = "spawn", zone = "village" })
    local results = em:query({ event = "spawn" })
    local size = em:len()
    lurek.log.info("episodic memory entries=" .. tostring(size))
    lurek.log.info("spawn matches=" .. tostring(#results))
    lurek.log.info("episodic memory ready for event playback")
end

-- ─── LEpisodicMemory:record ──────────────────────────────────────────────────

--@api: LEpisodicMemory:record
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(100, { event = "player_hit", damage = 10 })
    em:record(140, { event = "player_heal", amount = 6 })
    local hit_events = em:query({ event = "player_hit" })
    local total = em:len()
    lurek.log.info("episodic entries=" .. tostring(total))
    lurek.log.info("player_hit matches=" .. tostring(#hit_events))
    lurek.log.info("latest combat memory recorded")
end

-- ─── LEpisodicMemory:query ───────────────────────────────────────────────────

--@api: LEpisodicMemory:query
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { type = "kill" })
    em:record(2, { type = "kill" })
    em:record(3, { type = "loot" })
    local results = em:query({ type = "kill" })
    local total = em:len()
    local loot_results = em:query({ type = "loot" })
    lurek.log.info("kill events=" .. tostring(#results))
    lurek.log.info("loot events=" .. tostring(#loot_results))
    lurek.log.info("episodic total=" .. tostring(total))
end

-- ─── LEpisodicMemory:forgetBefore ────────────────────────────────────────────

--@api: LEpisodicMemory:forgetBefore
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(10, { note = "old" })
    em:record(200, { note = "new" })
    em:forgetBefore(100)
    example_print_log("Episodes after prune:", em:len())
end

-- ─── LEpisodicMemory:len ─────────────────────────────────────────────────────

--@api: LEpisodicMemory:len
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { x = 1 })
    em:record(2, { x = 2 })
    local length = em:len()
    local recent = em:query({ x = 2 })
    lurek.log.info("episode count=" .. tostring(length))
    lurek.log.info("query for x=2=" .. tostring(#recent))
    lurek.log.info("episodic memory stores ordered snapshots")
end

-- ─── lurek.agent.newSemanticMemory ───────────────────────────────────────────

--@api: lurek.agent.newSemanticMemory
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("capital_of_france", { value = "Paris" })
    local fact = sm:recall("capital_of_france")
    local count = sm:len()
    lurek.log.info("semantic memory facts=" .. tostring(count))
    lurek.log.info("capital_of_france=" .. tostring(fact and fact.value or "nil"))
    lurek.log.info("semantic memory ready for durable lore facts")
end

-- ─── LSemanticMemory:learn ───────────────────────────────────────────────────

--@api: LSemanticMemory:learn
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("capital_of_france", { value = "Paris" })
    sm:learn("capital_of_poland", { value = "Warsaw" })
    local france = sm:recall("capital_of_france")
    local poland = sm:recall("capital_of_poland")
    local count = sm:len()
    lurek.log.info("france capital=" .. tostring(france and france.value or "nil"))
    lurek.log.info("poland capital=" .. tostring(poland and poland.value or "nil"))
    lurek.log.info("semantic fact count=" .. tostring(count))
end

-- ─── LSemanticMemory:recall ──────────────────────────────────────────────────

--@api: LSemanticMemory:recall
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("color", { hex = "#FF0000" })
    local fact = sm:recall("color")
    local missing = sm:recall("missing")
    local count = sm:len()
    lurek.log.info("recalled color hex=" .. tostring(fact and fact.hex or "nil"))
    lurek.log.info("missing fact=" .. tostring(missing))
    lurek.log.info("semantic fact count=" .. tostring(count))
end

-- ─── LSemanticMemory:forget ──────────────────────────────────────────────────

--@api: LSemanticMemory:forget
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("temp_fact", { value = 42 })
    sm:learn("keep_fact", { value = 7 })
    local removed = sm:forget("temp_fact")
    local remaining = sm:recall("keep_fact")
    local count = sm:len()
    lurek.log.info("temp fact removed=" .. tostring(removed))
    lurek.log.info("remaining fact=" .. tostring(remaining and remaining.value or "nil"))
    lurek.log.info("semantic fact count=" .. tostring(count))
end

-- ─── LSemanticMemory:query ───────────────────────────────────────────────────

--@api: LSemanticMemory:query
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("fact_a", { category = "geo" })
    sm:learn("fact_b", { category = "geo" })
    local geo_facts = sm:query({ category = "geo" })
    example_print_log("Geo facts:", #geo_facts)
end

-- ─── LSemanticMemory:len ─────────────────────────────────────────────────────

--@api: LSemanticMemory:len
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("k", { v = 1 })
    sm:learn("m", { v = 2 })
    local count = sm:len()
    local matches = sm:query({ v = 2 })
    lurek.log.info("semantic fact count=" .. tostring(count))
    lurek.log.info("facts matching v=2=" .. tostring(#matches))
    lurek.log.info("semantic memory can be queried by fields")
end

-- ─── lurek.agent.newAgentMemory ──────────────────────────────────────────────

--@api: lurek.agent.newAgentMemory
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 32, persist_path = nil })
    local working = mem:working()
    local episodic = mem:episodic()
    local semantic = mem:semantic()
    lurek.log.info("working capacity=" .. tostring(working:capacity()))
    lurek.log.info("episodic entries=" .. tostring(episodic:len()))
    lurek.log.info("semantic facts=" .. tostring(semantic:len()))
end

-- ─── LAgentMemory:working ────────────────────────────────────────────────────

--@api: LAgentMemory:working
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local wm = mem:working()
    wm:push("stance", "defensive")
    local stance = wm:get("stance")
    local size = wm:len()
    lurek.log.info("working stance=" .. tostring(stance))
    lurek.log.info("working entries=" .. tostring(size))
    lurek.log.info("working capacity=" .. tostring(wm:capacity()))
end

-- ─── LAgentMemory:episodic ───────────────────────────────────────────────────

--@api: LAgentMemory:episodic
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local em = mem:episodic()
    em:record(10, { event = "quest_started" })
    local matches = em:query({ event = "quest_started" })
    local size = em:len()
    lurek.log.info("episodic bundle entries=" .. tostring(size))
    lurek.log.info("quest_started matches=" .. tostring(#matches))
    lurek.log.info("episodic bundle ready=" .. tostring(size > 0))
end

-- ─── LAgentMemory:semantic ───────────────────────────────────────────────────

--@api: LAgentMemory:semantic
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local sm = mem:semantic()
    sm:learn("faction", { name = "Wardens" })
    local fact = sm:recall("faction")
    local count = sm:len()
    lurek.log.info("semantic bundle facts=" .. tostring(count))
    lurek.log.info("faction name=" .. tostring(fact and fact.name or "nil"))
    lurek.log.info("semantic bundle ready for lore lookups")
end

-- ─── LAgentMemory:save ───────────────────────────────────────────────────────

--@api: LAgentMemory:save
do
    local mem = lurek.agent.newAgentMemory({ persist_path = "work/agent_mem_example.json" })
    mem:working():push("checkpoint", "harbor_gate")
    mem:semantic():learn("region", { name = "Salt Coast" })
    local saved = mem:save()
    local working_size = mem:working():len()
    lurek.log.info("memory saved=" .. tostring(saved))
    lurek.log.info("working entries persisted=" .. tostring(working_size))
    lurek.log.info("semantic facts persisted=" .. tostring(mem:semantic():len()))
end

-- ─── LAgentMemory:load ───────────────────────────────────────────────────────

--@api: LAgentMemory:load
do
    local source = lurek.agent.newAgentMemory({ persist_path = "work/agent_mem_example.json" })
    source:working():push("checkpoint", "harbor_gate")
    source:semantic():learn("region", { name = "Salt Coast" })
    source:save()
    local mem = lurek.agent.newAgentMemory({ persist_path = "work/agent_mem_example.json" })
    local loaded = mem:load()
    local checkpoint = mem:working():get("checkpoint")
    lurek.log.info("memory loaded=" .. tostring(loaded))
    lurek.log.info("loaded checkpoint=" .. tostring(checkpoint))
    lurek.log.info("loaded semantic facts=" .. tostring(mem:semantic():len()))
end

--@api: LAgentMemory:getDiagnostics
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 6 })
    local diagnostics = mem:getDiagnostics()
    lurek.log.info("memory working_entries=" .. tostring(diagnostics.working_entries))
    lurek.log.info("memory max_bytes=" .. tostring(diagnostics.max_bytes))
    lurek.log.info("memory sandbox_root=" .. tostring(diagnostics.sandbox_root))
end
