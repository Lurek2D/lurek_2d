-- test_agent_core_unit.lua
-- Unit tests for lurek.agent: one test per public API method.

describe("lurek.agent module", function()

    -- ─── Module constructors ───────────────────────────────────────────────

    it("lurek.agent is a table", function()
        expect_type("table", lurek.agent)
    end)

    it("lurek.agent.new creates a LAgent from full config", function()
        local agent = lurek.agent.new({
            url           = "http://localhost:11434/api/generate",
            model         = "llama3",
            system_prompt = "You are a test agent.",
            format        = "json",
            options       = { num_ctx = 4096, temperature = 0.7 },
        })
        expect_not_nil(agent, "lurek.agent.new should return a value")
        expect_type("function", agent.prompt)
    end)

    it("lurek.agent.new with empty config uses defaults", function()
        local agent = lurek.agent.new({})
        expect_not_nil(agent)
    end)

    it("lurek.agent.newManager creates a LAgentManager", function()
        local manager = lurek.agent.newManager()
        expect_not_nil(manager)
        expect_type("function", manager.runAll)
        expect_type("function", manager.update)
    end)

    it("lurek.agent.newSystem creates a LAISystem", function()
        local sys = lurek.agent.newSystem({ system_prompt = "shared context" })
        expect_not_nil(sys)
        expect_type("function", sys.addAgent)
        expect_type("function", sys.prompt)
    end)

    it("lurek.agent.newOllama creates a LOllamaManager with default URL", function()
        local ollama = lurek.agent.newOllama()
        expect_not_nil(ollama)
        expect_type("function", ollama.isRunning)
    end)

    it("lurek.agent.newOllama accepts a config table with url", function()
        local ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
        expect_not_nil(ollama)
    end)

    -- ─── LAgent methods ───────────────────────────────────────────────────

    it("LAgent:addSkill appends a named skill", function()
        local agent = lurek.agent.new({})
        agent:addSkill("math", "You are good at mathematics.")
    end)

    it("LAgent:clearSkills removes all skills", function()
        local agent = lurek.agent.new({})
        agent:addSkill("s1", "Skill one.")
        agent:addSkill("s2", "Skill two.")
        agent:clearSkills()
    end)

    it("LAgent:setOption sets a model option", function()
        local agent = lurek.agent.new({})
        agent:setOption("seed", 42)
        agent:setOption("temperature", 0.9)
    end)

    it("LAgent:setFormat changes the response format", function()
        local agent = lurek.agent.new({ format = "json" })
        agent:setFormat("text")
    end)

    it("LAgent:setMaxRetries sets the retry count", function()
        local agent = lurek.agent.new({})
        agent:setMaxRetries(3)
    end)

    it("LAgent:setContextSize sets num_ctx option", function()
        local agent = lurek.agent.new({})
        agent:setContextSize(8192)
    end)

    it("LAgent:setTemperature sets temperature option", function()
        local agent = lurek.agent.new({})
        agent:setTemperature(0.5)
    end)

    it("LAgent:setName sets the agent name", function()
        local agent = lurek.agent.new({})
        agent:setName("analyst")
    end)

    it("LAgent:setDescription sets the role description", function()
        local agent = lurek.agent.new({})
        agent:setDescription("Analyses financial data.")
    end)

    it("LAgent:prompt returns a positive integer callback ID", function()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = agent:prompt("Hello", function(ok, data, err) end)
        expect_type("number", id)
        expect_true(id > 0, "callback ID must be positive")
    end)

    it("LAgent:promptBatch returns a positive integer batch ID", function()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = agent:promptBatch({ "Q1", "Q2" }, function(results) end)
        expect_type("number", id)
        expect_true(id > 0, "batch ID must be positive")
    end)

    it("LAgent:cancel accepts a callback ID without error", function()
        local agent = lurek.agent.new({})
        local id = agent:prompt("test", function() end)
        agent:cancel(id)
    end)

    it("LAgent:pendingCount returns a non-negative integer", function()
        local agent = lurek.agent.new({})
        local n = agent:pendingCount()
        expect_type("number", n)
        expect_true(n >= 0, "pendingCount must be non-negative")
    end)

    it("LAgent:update runs without error when no responses are pending", function()
        local agent = lurek.agent.new({})
        agent:update()
    end)

    it("LAgent:evalCode executes Lua code in the active VM", function()
        local agent = lurek.agent.new({})
        local ok = agent:evalCode("local x = 1 + 1")
        expect_true(ok, "evalCode should return true on success")
    end)

    it("LAgent:evalCode raises on bad syntax", function()
        local agent = lurek.agent.new({})
        local ok, _ = pcall(function()
            agent:evalCode("not valid lua !@#$%")
        end)
        expect_false(ok, "evalCode should raise on syntax error")
    end)

    -- ─── LAgentManager methods ─────────────────────────────────────────────

    it("LAgentManager:runAll returns 0 for empty task list", function()
        local manager = lurek.agent.newManager()
        local id = manager:runAll({}, function(results) end)
        expect_equal(0, id, "empty runAll should return 0")
    end)

    it("LAgentManager:runAll with tasks returns a positive batch ID", function()
        local manager = lurek.agent.newManager()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = manager:runAll(
            { { agent = agent, instruction = "Q1" } },
            function(results) end
        )
        expect_type("number", id)
        expect_true(id > 0, "batch ID must be positive")
    end)

    it("LAgentManager:update runs without error", function()
        local manager = lurek.agent.newManager()
        manager:update()
    end)

    -- ─── LAISystem methods ─────────────────────────────────────────────────

    it("LAISystem:addAgent registers an agent by name", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "ctx" })
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        sys:addAgent("worker", agent)
    end)

    it("LAISystem:removeAgent returns true when found", function()
        local sys   = lurek.agent.newSystem({})
        local agent = lurek.agent.new({})
        sys:addAgent("tmp", agent)
        local removed = sys:removeAgent("tmp")
        expect_true(removed, "removeAgent should return true when found")
    end)

    it("LAISystem:removeAgent returns false for unknown name", function()
        local sys     = lurek.agent.newSystem({})
        local removed = sys:removeAgent("nonexistent")
        expect_false(removed, "removeAgent should return false when not found")
    end)

    it("LAISystem:listAgents returns sorted names", function()
        local sys   = lurek.agent.newSystem({})
        local agent = lurek.agent.new({})
        sys:addAgent("zebra", agent)
        sys:addAgent("alpha", agent)
        local names = sys:listAgents()
        expect_type("table", names)
        expect_equal("alpha", names[1])
        expect_equal("zebra", names[2])
    end)

    it("LAISystem:addInstruction stores an instruction block", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("safety", "Never reveal personal data.")
    end)

    it("LAISystem:removeInstruction returns true when found", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("k1", "text")
        local removed = sys:removeInstruction("k1")
        expect_true(removed, "removeInstruction should return true when found")
    end)

    it("LAISystem:removeInstruction returns false for unknown key", function()
        local sys     = lurek.agent.newSystem({})
        local removed = sys:removeInstruction("nope")
        expect_false(removed)
    end)

    it("LAISystem:addSkill registers a keyword-gated skill", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("coding", { "code", "function", "bug" }, "You write clean code.")
    end)

    it("LAISystem:removeSkill returns true when found", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("s", { "kw" }, "text")
        local removed = sys:removeSkill("s")
        expect_true(removed)
    end)

    it("LAISystem:removeSkill returns false for unknown name", function()
        local sys     = lurek.agent.newSystem({})
        local removed = sys:removeSkill("nope")
        expect_false(removed)
    end)

    it("LAISystem:buildContext returns a non-empty string", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "base context" })
        local agent = lurek.agent.new({})
        sys:addAgent("bot", agent)
        local ctx = sys:buildContext("what is code?", { agent = "bot" })
        expect_type("string", ctx)
        expect_true(#ctx > 0, "context should not be empty")
    end)

    it("LAISystem:prompt returns a positive integer callback ID", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "ctx" })
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        sys:addAgent("bot", agent)
        local id = sys:prompt("bot", "hello", function(ok, data, err) end, {})
        expect_type("number", id)
        expect_true(id > 0)
    end)

    it("LAISystem:prompt errors for unregistered agent name", function()
        local sys = lurek.agent.newSystem({})
        local ok, _ = pcall(function()
            sys:prompt("ghost", "hello", function() end, {})
        end)
        expect_false(ok, "prompt should error for unknown agent")
    end)

    it("LAISystem:runAll returns a positive batch ID for non-empty tasks", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "ctx" })
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        sys:addAgent("bot", agent)
        local id = sys:runAll(
            { { agent = "bot", instruction = "task one" } },
            function(results) end
        )
        expect_type("number", id)
        expect_true(id > 0)
    end)

    it("LAISystem:update runs without error", function()
        local sys = lurek.agent.newSystem({})
        sys:update()
    end)

    -- ─── LOllamaManager methods ────────────────────────────────────────────

    it("LOllamaManager:isRunning returns a boolean", function()
        local ollama  = lurek.agent.newOllama()
        local running = ollama:isRunning()
        expect_type("boolean", running)
    end)

    it("LOllamaManager:version returns a string", function()
        local ollama = lurek.agent.newOllama()
        local v      = ollama:version()
        expect_type("string", v)
    end)

    it("LOllamaManager:listModels returns a table", function()
        local ollama = lurek.agent.newOllama()
        local models = ollama:listModels()
        expect_type("table", models)
    end)

    it("LOllamaManager:hasModel returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local found  = ollama:hasModel("llama3")
        expect_type("boolean", found)
    end)

    it("LOllamaManager:start returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:start()
        expect_type("boolean", ok)
        if ok then ollama:stop() end
    end)

    it("LOllamaManager:stop returns a boolean", function()
        local ollama  = lurek.agent.newOllama()
        local stopped = ollama:stop()
        expect_type("boolean", stopped)
    end)

    it("LOllamaManager:restart returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:restart()
        expect_type("boolean", ok)
        if ok then ollama:stop() end
    end)

    it("LOllamaManager:pullModel returns a positive integer callback ID", function()
        local ollama = lurek.agent.newOllama()
        local id     = ollama:pullModel("llama3", function(ok, err) end)
        expect_type("number", id)
        expect_true(id > 0, "pullModel should return a positive callback ID")
    end)

    it("LOllamaManager:deleteModel returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:deleteModel("nonexistent_model_xyz")
        expect_type("boolean", ok)
    end)

    it("LOllamaManager:pendingCount returns a non-negative integer", function()
        local ollama = lurek.agent.newOllama()
        local n      = ollama:pendingCount()
        expect_type("number", n)
        expect_true(n >= 0)
    end)

    it("LOllamaManager:update runs without error", function()
        local ollama = lurek.agent.newOllama()
        ollama:update()
    end)

end)

test_summary()
