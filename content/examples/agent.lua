-- content/examples/agent.lua
-- Run: cargo run -- content/examples/agent.lua

--- Agent Module: LLM AI interaction — lurek.agent

-- ─── lurek.agent.new ─────────────────────────────────────────────────────────

--@api-stub: lurek.agent.new
do
    local agent = lurek.agent.new({
        url          = "http://localhost:11434/api/generate",
        model        = "llama3",
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
    print("Agent created:", agent)
end

-- ─── lurek.agent.newManager ──────────────────────────────────────────────────

--@api-stub: lurek.agent.newManager
do
    local manager = lurek.agent.newManager()
    print("Manager created:", manager)
end

-- ─── lurek.agent.newSystem ───────────────────────────────────────────────────

--@api-stub: lurek.agent.newSystem
do
    local system = lurek.agent.newSystem({
        system_prompt = "You are a multi-agent game orchestrator. Respond concisely.",
    })
    print("AISystem created:", system)
end

-- ─── LAgent:setName ──────────────────────────────────────────────────────────

--@api-stub: LAgent:setName
do
    local agent = lurek.agent.new({})
    agent:setName("npc_writer")
    print("Agent name set.")
end

-- ─── LAgent:setDescription ───────────────────────────────────────────────────

--@api-stub: LAgent:setDescription
do
    local agent = lurek.agent.new({})
    agent:setDescription("Specialises in writing NPC dialogue with emotional depth.")
    print("Agent description set.")
end

-- ─── LAgent:setModel ─────────────────────────────────────────────────────────

--@api-stub: LAgent:setModel
do
    local agent = lurek.agent.new({ model = "llama3" })
    agent:setModel("mistral")
    print("Agent model changed to mistral.")
end

-- ─── LAgent:setUrl ───────────────────────────────────────────────────────────

--@api-stub: LAgent:setUrl
do
    local agent = lurek.agent.new({})
    agent:setUrl("http://10.0.0.5:11434/api/generate")
    print("Agent URL updated.")
end

-- ─── LAgent:setTimeout ───────────────────────────────────────────────────────

--@api-stub: LAgent:setTimeout
do
    local agent = lurek.agent.new({})
    agent:setTimeout(90)
    print("Agent timeout set to 90 s.")
end

-- ─── LAgent:getName ──────────────────────────────────────────────────────────

--@api-stub: LAgent:getName
do
    local agent = lurek.agent.new({})
    agent:setName("planner")
    local name = agent:getName()
    print("Agent name:", name)
end

-- ─── LAgent:getDescription ───────────────────────────────────────────────────

--@api-stub: LAgent:getDescription
do
    local agent = lurek.agent.new({})
    agent:setDescription("Plans tasks.")
    local desc = agent:getDescription()
    print("Agent description:", desc)
end

-- ─── LAgent:getModel ─────────────────────────────────────────────────────────

--@api-stub: LAgent:getModel
do
    local agent = lurek.agent.new({ model = "llama3" })
    local m     = agent:getModel()
    print("Agent model:", m)
end

-- ─── LAgent:getUrl ───────────────────────────────────────────────────────────

--@api-stub: LAgent:getUrl
do
    local agent = lurek.agent.new({ url = "http://127.0.0.1:11434/api/generate" })
    local url   = agent:getUrl()
    print("Agent URL:", url)
end

-- ─── LAgent:getFormat ────────────────────────────────────────────────────────

--@api-stub: LAgent:getFormat
do
    local agent = lurek.agent.new({ format = "json" })
    local fmt   = agent:getFormat()
    print("Agent format:", fmt)
end

-- ─── LAgent:hasSkill ─────────────────────────────────────────────────────────

--@api-stub: LAgent:hasSkill
do
    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is in the Darkwood forest.")
    print("Has 'location' skill:", agent:hasSkill("location"))
    print("Has 'weather' skill:", agent:hasSkill("weather"))
end

-- ─── LAgent:skillCount ───────────────────────────────────────────────────────

--@api-stub: LAgent:skillCount
do
    local agent = lurek.agent.new({})
    agent:addSkill("s1", "Context A.")
    agent:addSkill("s2", "Context B.")
    print("Skill count:", agent:skillCount())
end

-- ─── LAgent:listSkills ───────────────────────────────────────────────────────

--@api-stub: LAgent:listSkills
do
    local agent = lurek.agent.new({})
    agent:addSkill("combat",    "Turn-based combat.")
    agent:addSkill("inventory", "Inventory management.")
    local names = agent:listSkills()
    for _, name in ipairs(names) do
        print("Skill:", name)
    end
end

-- ─── LAgent:addSkill ─────────────────────────────────────────────────────────

--@api-stub: LAgent:addSkill
do
    local agent = lurek.agent.new({})
    agent:addSkill("location", "The player is currently in the Darkwood forest.")
    agent:addSkill("time",     "It is midnight in the game world.")
    print("Skills added to agent context.")
end

-- ─── LAgent:clearSkills ──────────────────────────────────────────────────────

--@api-stub: LAgent:clearSkills
do
    local agent = lurek.agent.new({})
    agent:addSkill("temp", "Some context.")
    agent:clearSkills()
    print("Agent skills cleared.")
end

-- ─── LAgent:setOption ────────────────────────────────────────────────────────

--@api-stub: LAgent:setOption
do
    local agent = lurek.agent.new({})
    agent:setOption("temperature", 0.4)
    agent:setOption("seed", 1234)
    print("Agent options set.")
end

-- ─── LAgent:setFormat ────────────────────────────────────────────────────────

--@api-stub: LAgent:setFormat
do
    local agent = lurek.agent.new({})
    agent:setFormat("text")
    print("Agent format changed to text.")
end

-- ─── LAgent:setMaxRetries ────────────────────────────────────────────────────

--@api-stub: LAgent:setMaxRetries
do
    local agent = lurek.agent.new({})
    agent:setMaxRetries(3)
    print("Agent max retries set to 3.")
end

-- ─── LAgent:setContextSize ───────────────────────────────────────────────────

--@api-stub: LAgent:setContextSize
do
    local agent = lurek.agent.new({})
    agent:setContextSize(8192)
    print("Agent context window set to 8192 tokens.")
end

-- ─── LAgent:setTemperature ───────────────────────────────────────────────────

--@api-stub: LAgent:setTemperature
do
    local agent = lurek.agent.new({})
    agent:setTemperature(0.9)
    print("Agent temperature set to 0.9.")
end

-- ─── LAgent:prompt ───────────────────────────────────────────────────────────

--@api-stub: LAgent:prompt
do
    local agent = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "llama3",
        format = "json",
    })

    -- Async — must call agent:update() in the game loop to receive callbacks.
    local id = agent:prompt("Describe what the player sees when entering the forest.", function(success, data, err_info)
        if success then
            print("Response:", data.description or data.response)
        else
            print("Error [" .. err_info.code .. "]:", err_info.message)
        end
    end)
    print("Prompt dispatched, id =", id)
end

-- ─── LAgent:promptBatch ──────────────────────────────────────────────────────

--@api-stub: LAgent:promptBatch
do
    local agent = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "llama3",
        format = "json",
    })

    local id = agent:promptBatch({
        "Describe the bridge.",
        "Describe the engine room.",
        "Describe the dungeon entrance.",
    }, function(results)
        for i, res in ipairs(results) do
            if res.success then
                print("Result " .. i .. ":", res.data.description)
            else
                print("Task " .. i .. " failed [" .. res.error.code .. "]:", res.error.message)
            end
        end
    end)
    print("Batch dispatched, id =", id)
end

-- ─── LAgent:cancel ───────────────────────────────────────────────────────────

--@api-stub: LAgent:cancel
do
    local agent = lurek.agent.new({
        url = "http://localhost:11434/api/generate",
        model = "llama3",
    })
    local id = agent:prompt("Long-running request.", function() end)
    agent:cancel(id)
    print("Request cancelled, id =", id)
end

-- ─── LAgent:pendingCount ─────────────────────────────────────────────────────

--@api-stub: LAgent:pendingCount
do
    local agent = lurek.agent.new({})
    local n = agent:pendingCount()
    print("Pending in-flight requests:", n)
end

-- ─── LAgent:update ───────────────────────────────────────────────────────────

--@api-stub: LAgent:update
do
    local agent = lurek.agent.new({})
    -- Called every frame in the game loop to deliver completed LLM responses.
    agent:update()
    print("Agent polled for responses.")
end

-- ─── LAgent:evalCode ─────────────────────────────────────────────────────────

--@api-stub: LAgent:evalCode
do
    local agent = lurek.agent.new({})
    local ok = agent:evalCode("local x = 1 + 1; print('eval result:', x)")
    print("evalCode ok:", ok)
end

-- ─── LAgentManager:runAll ────────────────────────────────────────────────────

--@api-stub: LAgentManager:runAll
do
    local manager = lurek.agent.newManager()

    local writer   = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "llama3", format = "json" })
    local designer = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "llama3", format = "json" })

    local id = manager:runAll({
        { agent = writer,   instruction = "Write a boss intro monologue." },
        { agent = designer, instruction = "Design the boss arena layout."  },
    }, function(results)
        for i, res in ipairs(results) do
            print("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    print("Manager batch dispatched, id =", id)
end

-- ─── LAgentManager:update ────────────────────────────────────────────────────

--@api-stub: LAgentManager:update
do
    local manager = lurek.agent.newManager()
    -- Called every frame in the game loop.
    manager:update()
    print("Manager polled for batch responses.")
end

-- ─── LAISystem:addAgent ──────────────────────────────────────────────────────

--@api-stub: LAISystem:addAgent
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })

    local npc = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "llama3", format = "json" })
    npc:setDescription("Writes NPC dialogue with emotional depth and regional accents.")

    system:addAgent("npc_writer", npc)
    print("Agent 'npc_writer' added to system.")
end

-- ─── LAISystem:removeAgent ───────────────────────────────────────────────────

--@api-stub: LAISystem:removeAgent
do
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("temp_agent", agent)
    local removed = system:removeAgent("temp_agent")
    print("Agent removed:", removed)
end

-- ─── LAISystem:listAgents ────────────────────────────────────────────────────

--@api-stub: LAISystem:listAgents
do
    local system = lurek.agent.newSystem({})
    local a = lurek.agent.new({})
    system:addAgent("writer",   a)
    system:addAgent("designer", a)
    local names = system:listAgents()
    for _, name in ipairs(names) do
        print("Registered agent:", name)
    end
end

-- ─── LAISystem:hasAgent ──────────────────────────────────────────────────────

--@api-stub: LAISystem:hasAgent
do
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("planner", agent)
    print("Has 'planner':", system:hasAgent("planner"))
    print("Has 'ghost':",   system:hasAgent("ghost"))
end

-- ─── LAISystem:agentCount ────────────────────────────────────────────────────

--@api-stub: LAISystem:agentCount
do
    local system = lurek.agent.newSystem({})
    local agent  = lurek.agent.new({})
    system:addAgent("a1", agent)
    system:addAgent("a2", agent)
    print("Agent count:", system:agentCount())
end

-- ─── LAISystem:addInstruction ────────────────────────────────────────────────

--@api-stub: LAISystem:addInstruction
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("art_style", "Use a 16-bit pixel art visual style. Palettes are limited to 16 colours per sprite.")
    system:addInstruction("tone",      "Keep all responses concise and in present tense.")
    print("Instructions added to system.")
end

-- ─── LAISystem:removeInstruction ─────────────────────────────────────────────

--@api-stub: LAISystem:removeInstruction
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("debug_hint", "Temporary debug context.")
    local removed = system:removeInstruction("debug_hint")
    print("Instruction removed:", removed)
end

-- ─── LAISystem:hasInstruction ────────────────────────────────────────────────

--@api-stub: LAISystem:hasInstruction
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone", "Be concise.")
    print("Has 'tone':",    system:hasInstruction("tone"))
    print("Has 'missing':", system:hasInstruction("missing"))
end

-- ─── LAISystem:instructionCount ──────────────────────────────────────────────

--@api-stub: LAISystem:instructionCount
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    print("Instruction count:", system:instructionCount())
end

-- ─── LAISystem:listInstructions ──────────────────────────────────────────────

--@api-stub: LAISystem:listInstructions
do
    local system = lurek.agent.newSystem({})
    system:addInstruction("tone",      "Be concise.")
    system:addInstruction("art_style", "Use pixel art.")
    local keys = system:listInstructions()
    for _, key in ipairs(keys) do
        print("Instruction key:", key)
    end
end

-- ─── LAISystem:addSkill ──────────────────────────────────────────────────────

--@api-stub: LAISystem:addSkill
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
    print("System skills added.")
end

-- ─── LAISystem:removeSkill ───────────────────────────────────────────────────

--@api-stub: LAISystem:removeSkill
do
    local system = lurek.agent.newSystem({})
    system:addSkill("temp_skill", { "test" }, "Temporary.")
    local removed = system:removeSkill("temp_skill")
    print("Skill removed:", removed)
end

-- ─── LAISystem:hasSkill ──────────────────────────────────────────────────────

--@api-stub: LAISystem:hasSkill
do
    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules", { "combat", "attack" }, "Turn-based combat.")
    print("Has 'combat_rules':",  system:hasSkill("combat_rules"))
    print("Has 'no_such_skill':", system:hasSkill("no_such_skill"))
end

-- ─── LAISystem:skillCount ────────────────────────────────────────────────────

--@api-stub: LAISystem:skillCount
do
    local system = lurek.agent.newSystem({})
    system:addSkill("combat_rules",   { "combat" },        "Turn-based combat.")
    system:addSkill("pixel_art_rules", { "sprite", "tile" }, "16 colours max.")
    print("Skill count:", system:skillCount())
end

-- ─── LAISystem:buildContext ──────────────────────────────────────────────────

--@api-stub: LAISystem:buildContext
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
    print("Context preview:\n", ctx)
end

-- ─── LAISystem:prompt ────────────────────────────────────────────────────────

--@api-stub: LAISystem:prompt
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game design AI." })
    system:addInstruction("art_style", "Use 16-bit pixel art.")
    system:addSkill("pixel_art_rules", { "sprite", "texture" }, "Max 16 colours per tile.")

    local designer = lurek.agent.new({
        url    = "http://localhost:11434/api/generate",
        model  = "llama3",
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
                print("Design:", data.description)
            else
                print("Error:", err_info.message)
            end
        end,
        { instructions = { "art_style" } }
    )
    print("System prompt dispatched, id =", id)
end

-- ─── LAISystem:runAll ────────────────────────────────────────────────────────

--@api-stub: LAISystem:runAll
do
    local system = lurek.agent.newSystem({ system_prompt = "You are a game AI team." })
    system:addInstruction("art_style", "16-bit pixel art.")

    local writer   = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "llama3", format = "json" })
    local designer = lurek.agent.new({ url = "http://localhost:11434/api/generate", model = "llama3", format = "json" })
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
            print("Task " .. i, res.success and tostring(res.data) or res.error.message)
        end
    end)
    print("System runAll dispatched, id =", id)
end

-- ─── LAISystem:update ────────────────────────────────────────────────────────

--@api-stub: LAISystem:update
do
    local system = lurek.agent.newSystem({})
    -- Called every frame in the game loop.
    system:update()
    print("AISystem polled for responses.")
end

-- ─── lurek.agent.newOllama ───────────────────────────────────────────────────

--@api-stub: lurek.agent.newOllama
do
    local ollama = lurek.agent.newOllama()
    print("OllamaManager created, default URL http://127.0.0.1:11434")
end

-- ─── LOllamaManager:isRunning ────────────────────────────────────────────────

--@api-stub: LOllamaManager:isRunning
do
    local ollama  = lurek.agent.newOllama()
    local running = ollama:isRunning()
    print("Ollama running:", running)
end

-- ─── LOllamaManager:version ──────────────────────────────────────────────────

--@api-stub: LOllamaManager:version
do
    local ollama = lurek.agent.newOllama()
    local v      = ollama:version()
    print("Ollama version:", v)
end

-- ─── LOllamaManager:baseUrl ──────────────────────────────────────────────────

--@api-stub: LOllamaManager:baseUrl
do
    local ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
    local url    = ollama:baseUrl()
    print("Ollama base URL:", url)
end

-- ─── LOllamaManager:listModels ───────────────────────────────────────────────

--@api-stub: LOllamaManager:listModels
do
    local ollama = lurek.agent.newOllama()
    local models = ollama:listModels()
    for _, m in ipairs(models) do
        print(m.name, string.format("%.1f GB", m.size_gb))
    end
end

-- ─── LOllamaManager:modelNames ───────────────────────────────────────────────

--@api-stub: LOllamaManager:modelNames
do
    local ollama = lurek.agent.newOllama()
    local names  = ollama:modelNames()
    for _, name in ipairs(names) do
        print("Available model:", name)
    end
end

-- ─── LOllamaManager:hasModel ─────────────────────────────────────────────────

--@api-stub: LOllamaManager:hasModel
do
    local ollama = lurek.agent.newOllama()
    local found  = ollama:hasModel("llama3")
    print("llama3 available:", found)
end

-- ─── LOllamaManager:start ────────────────────────────────────────────────────

--@api-stub: LOllamaManager:start
do
    local ollama = lurek.agent.newOllama()
    local ok     = ollama:start()
    print("Ollama started:", ok)
end

-- ─── LOllamaManager:stop ─────────────────────────────────────────────────────

--@api-stub: LOllamaManager:stop
do
    local ollama  = lurek.agent.newOllama()
    local stopped = ollama:stop()
    print("Ollama stopped:", stopped)
end

-- ─── LOllamaManager:restart ──────────────────────────────────────────────────

--@api-stub: LOllamaManager:restart
do
    local ollama = lurek.agent.newOllama()
    local ok     = ollama:restart()
    print("Ollama restarted:", ok)
end

-- ─── LOllamaManager:pullModel ────────────────────────────────────────────────

--@api-stub: LOllamaManager:pullModel
do
    local ollama = lurek.agent.newOllama()
    local id     = ollama:pullModel("llama3", function(success, err_msg)
        if success then
            print("Model downloaded successfully.")
        else
            print("Pull failed:", err_msg)
        end
    end)
    print("Pull started, callback id =", id)
end

-- ─── LOllamaManager:deleteModel ──────────────────────────────────────────────

--@api-stub: LOllamaManager:deleteModel
do
    local ollama = lurek.agent.newOllama()
    local ok     = ollama:deleteModel("llama3:latest")
    print("Model deleted:", ok)
end

-- ─── LOllamaManager:pendingCount ─────────────────────────────────────────────

--@api-stub: LOllamaManager:pendingCount
do
    local ollama = lurek.agent.newOllama()
    local n      = ollama:pendingCount()
    print("In-flight pulls:", n)
end

-- ─── LOllamaManager:update ───────────────────────────────────────────────────

--@api-stub: LOllamaManager:update
do
    local ollama = lurek.agent.newOllama()
    -- Dispatch pull callbacks that completed since the last frame.
    ollama:update()
end

-- ─── lurek.agent.configure ───────────────────────────────────────────────────

--@api-stub: lurek.agent.configure
do
    lurek.agent.configure({
        provider    = "ollama",
        base_url    = "http://127.0.0.1:11434",
        model       = "llama3",
        timeout_ms  = 30000,
        api_key     = nil,
    })
end

-- ─── lurek.agent.complete ────────────────────────────────────────────────────

--@api-stub: lurek.agent.complete
do
    local reply = lurek.agent.complete("Hello, world!")
    print("Reply:", reply)
end

-- ─── lurek.agent.completeAsync ───────────────────────────────────────────────

--@api-stub: lurek.agent.completeAsync
do
    lurek.agent.completeAsync("What is Lua?", function(text, err)
        if err then
            print("Error:", err)
        else
            print("Async reply:", text)
        end
    end)
end

-- ─── lurek.agent.newChat ─────────────────────────────────────────────────────

--@api-stub: lurek.agent.newChat
do
    ---@type LAgentChat
    local chat = lurek.agent.newChat()
    print("Chat created:", chat)
end

-- ─── LAgentChat:setSystemPrompt ──────────────────────────────────────────────

--@api-stub: LAgentChat:setSystemPrompt
do
    local chat = lurek.agent.newChat()
    chat:setSystemPrompt("You are a helpful assistant.")
end

-- ─── LAgentChat:addMessage ───────────────────────────────────────────────────

--@api-stub: LAgentChat:addMessage
do
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Tell me a joke.")
end

-- ─── LAgentChat:complete ─────────────────────────────────────────────────────

--@api-stub: LAgentChat:complete
do
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hi!")
    local reply = chat:complete()
    print("Chat reply:", reply)
end

-- ─── LAgentChat:clear ────────────────────────────────────────────────────────

--@api-stub: LAgentChat:clear
do
    local chat = lurek.agent.newChat()
    chat:addMessage("user", "Hello")
    chat:clear()
end

-- ─── LAgentChat:getHistory ───────────────────────────────────────────────────

--@api-stub: LAgentChat:getHistory
do
    local chat = lurek.agent.newChat()
    local history = chat:getHistory()
    print("History entries:", #history)
end

-- ─── lurek.agent.newTemplate ─────────────────────────────────────────────────

--@api-stub: lurek.agent.newTemplate
do
    ---@type LAgentTemplate
    local tmpl = lurek.agent.newTemplate("Hello, {name}!")
    print("Template created:", tmpl)
end

-- ─── LAgentTemplate:render ───────────────────────────────────────────────────

--@api-stub: LAgentTemplate:render
do
    local tmpl = lurek.agent.newTemplate("Hello, {name}! You are {age} years old.")
    local out  = tmpl:render({ name = "Alice", age = "30" })
    print("Rendered:", out)
end

-- ─── lurek.agent.completeJson ────────────────────────────────────────────────

--@api-stub: lurek.agent.completeJson
do
    local result = lurek.agent.completeJson("List three colors as JSON.")
    print("JSON result:", result)
end

-- ─── lurek.agent.embed ───────────────────────────────────────────────────────

--@api-stub: lurek.agent.embed
do
    local vec = lurek.agent.embed("Semantic embedding test.")
    print("Embedding dimensions:", #vec)
end

-- ─── lurek.agent.isAvailable ─────────────────────────────────────────────────

--@api-stub: lurek.agent.isAvailable
do
    local ok = lurek.agent.isAvailable()
    print("LLM available:", ok)
end

-- ─── lurek.agent.listModels ──────────────────────────────────────────────────

--@api-stub: lurek.agent.listModels
do
    local models = lurek.agent.listModels()
    print("Available models:", #models)
end

-- ─── lurek.agent.newWorkingMemory ────────────────────────────────────────────

--@api-stub: lurek.agent.newWorkingMemory
do
    ---@type LWorkingMemory
    local wm = lurek.agent.newWorkingMemory(16)
    print("Working memory capacity:", wm:capacity())
end

-- ─── LWorkingMemory:push ─────────────────────────────────────────────────────

--@api-stub: LWorkingMemory:push
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("last_action", "jump")
end

-- ─── LWorkingMemory:get ──────────────────────────────────────────────────────

--@api-stub: LWorkingMemory:get
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("hp", 100)
    local hp = wm:get("hp")
    print("HP:", hp)
end

-- ─── LWorkingMemory:forget ───────────────────────────────────────────────────

--@api-stub: LWorkingMemory:forget
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("temp", "value")
    local removed = wm:forget("temp")
    print("Removed:", removed)
end

-- ─── LWorkingMemory:getRecent ────────────────────────────────────────────────

--@api-stub: LWorkingMemory:getRecent
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("a", 1)
    wm:push("b", 2)
    local recent = wm:getRecent(2)
    print("Recent entries:", #recent)
end

-- ─── LWorkingMemory:len ──────────────────────────────────────────────────────

--@api-stub: LWorkingMemory:len
do
    local wm = lurek.agent.newWorkingMemory(8)
    wm:push("x", 42)
    print("WM size:", wm:len())
end

-- ─── LWorkingMemory:capacity ─────────────────────────────────────────────────

--@api-stub: LWorkingMemory:capacity
do
    local wm = lurek.agent.newWorkingMemory(32)
    print("WM capacity:", wm:capacity())
end

-- ─── lurek.agent.newEpisodicMemory ───────────────────────────────────────────

--@api-stub: lurek.agent.newEpisodicMemory
do
    ---@type LEpisodicMemory
    local em = lurek.agent.newEpisodicMemory()
    print("Episodic memory created:", em)
end

-- ─── LEpisodicMemory:record ──────────────────────────────────────────────────

--@api-stub: LEpisodicMemory:record
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(100, { event = "player_hit", damage = 10 })
end

-- ─── LEpisodicMemory:query ───────────────────────────────────────────────────

--@api-stub: LEpisodicMemory:query
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { type = "kill" })
    local results = em:query({ type = "kill" })
    print("Kill events:", #results)
end

-- ─── LEpisodicMemory:forgetBefore ────────────────────────────────────────────

--@api-stub: LEpisodicMemory:forgetBefore
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(10, { note = "old" })
    em:record(200, { note = "new" })
    em:forgetBefore(100)
    print("Episodes after prune:", em:len())
end

-- ─── LEpisodicMemory:len ─────────────────────────────────────────────────────

--@api-stub: LEpisodicMemory:len
do
    local em = lurek.agent.newEpisodicMemory()
    em:record(1, { x = 1 })
    print("Episode count:", em:len())
end

-- ─── lurek.agent.newSemanticMemory ───────────────────────────────────────────

--@api-stub: lurek.agent.newSemanticMemory
do
    ---@type LSemanticMemory
    local sm = lurek.agent.newSemanticMemory()
    print("Semantic memory created:", sm)
end

-- ─── LSemanticMemory:learn ───────────────────────────────────────────────────

--@api-stub: LSemanticMemory:learn
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("capital_of_france", { value = "Paris" })
end

-- ─── LSemanticMemory:recall ──────────────────────────────────────────────────

--@api-stub: LSemanticMemory:recall
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("color", { hex = "#FF0000" })
    local fact = sm:recall("color")
    print("Recalled:", fact)
end

-- ─── LSemanticMemory:forget ──────────────────────────────────────────────────

--@api-stub: LSemanticMemory:forget
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("temp_fact", { value = 42 })
    local removed = sm:forget("temp_fact")
    print("Removed:", removed)
end

-- ─── LSemanticMemory:query ───────────────────────────────────────────────────

--@api-stub: LSemanticMemory:query
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("fact_a", { category = "geo" })
    sm:learn("fact_b", { category = "geo" })
    local geo_facts = sm:query({ category = "geo" })
    print("Geo facts:", #geo_facts)
end

-- ─── LSemanticMemory:len ─────────────────────────────────────────────────────

--@api-stub: LSemanticMemory:len
do
    local sm = lurek.agent.newSemanticMemory()
    sm:learn("k", { v = 1 })
    print("Facts:", sm:len())
end

-- ─── lurek.agent.newAgentMemory ──────────────────────────────────────────────

--@api-stub: lurek.agent.newAgentMemory
do
    ---@type LAgentMemory
    local mem = lurek.agent.newAgentMemory({ working_capacity = 32, persist_path = nil })
    print("Agent memory created:", mem)
end

-- ─── LAgentMemory:working ────────────────────────────────────────────────────

--@api-stub: LAgentMemory:working
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local wm = mem:working()
    print("Working memory from bundle:", wm)
end

-- ─── LAgentMemory:episodic ───────────────────────────────────────────────────

--@api-stub: LAgentMemory:episodic
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local em = mem:episodic()
    print("Episodic memory from bundle:", em)
end

-- ─── LAgentMemory:semantic ───────────────────────────────────────────────────

--@api-stub: LAgentMemory:semantic
do
    local mem = lurek.agent.newAgentMemory({ working_capacity = 8 })
    local sm = mem:semantic()
    print("Semantic memory from bundle:", sm)
end

-- ─── LAgentMemory:save ───────────────────────────────────────────────────────

--@api-stub: LAgentMemory:save
do
    local mem = lurek.agent.newAgentMemory({ persist_path = "save/agent_mem.json" })
    local ok  = mem:save()
    print("Memory saved:", ok)
end

-- ─── LAgentMemory:load ───────────────────────────────────────────────────────

--@api-stub: LAgentMemory:load
do
    local mem = lurek.agent.newAgentMemory({ persist_path = "save/agent_mem.json" })
    local ok  = mem:load()
    print("Memory loaded:", ok)
end
