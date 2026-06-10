-- test_agent_core_unit.lua
-- Unit tests for lurek.agent: one test per public API method.

local DEAD_AGENT_BASE_URL = "http://127.0.0.1:9"
local DEAD_AGENT_MODEL = "offline-test-model"
local AGENT_MEMORY_PATH = "save/test_agent_memory_bundle.json"

local function configure_dead_agent_backend()
    lurek.agent.configure({
        provider = "ollama",
        base_url = DEAD_AGENT_BASE_URL,
        model = DEAD_AGENT_MODEL,
        timeout_ms = 1000,
        api_key = nil,
    })
end

-- @describe lurek.agent module
describe("lurek.agent module", function()

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ Module constructors Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers lurek.agent
    it("lurek.agent is a table", function()
        expect_type("table", lurek.agent)
    end)

    -- @covers lurek.agent
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

    -- @covers lurek.agent
    it("lurek.agent.new with empty config uses defaults", function()
        local agent = lurek.agent.new({})
        expect_not_nil(agent)
    end)

    -- @covers lurek.agent
    it("lurek.agent.newManager creates a LAgentManager", function()
        local manager = lurek.agent.newManager()
        expect_not_nil(manager)
        expect_type("function", manager.runAll)
        expect_type("function", manager.update)
    end)

    -- @covers lurek.agent
    it("lurek.agent.newSystem creates a LAISystem", function()
        local sys = lurek.agent.newSystem({ system_prompt = "shared context" })
        expect_not_nil(sys)
        expect_type("function", sys.addAgent)
        expect_type("function", sys.prompt)
    end)

    -- @covers lurek.agent
    it("lurek.agent.newOllama creates a LOllamaManager with default URL", function()
        local ollama = lurek.agent.newOllama()
        expect_not_nil(ollama)
        expect_type("function", ollama.isRunning)
    end)

    -- @covers lurek.agent
    it("lurek.agent.newOllama accepts a config table with url", function()
        local ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
        expect_not_nil(ollama)
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LAgent methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers lurek.agent
    it("LAgent:addSkill appends a named skill", function()
        local agent = lurek.agent.new({})
        agent:addSkill("math", "You are good at mathematics.")
        agent:addSkill("logic", "You are good at logic.")

        expect_equal(2, agent:skillCount())
        expect_true(agent:hasSkill("math"))
        expect_true(agent:hasSkill("logic"))

        local skills = agent:listSkills()
        expect_type("table", skills)
        expect_equal("math", skills[1])
        expect_equal("logic", skills[2])
    end)

    -- @covers lurek.agent
    it("LAgent:clearSkills removes all skills", function()
        local agent = lurek.agent.new({})
        agent:addSkill("s1", "Skill one.")
        agent:addSkill("s2", "Skill two.")
        agent:clearSkills()
    end)

    -- @covers lurek.agent
    it("LAgent:setOption sets a model option", function()
        local agent = lurek.agent.new({})
        agent:setOption("seed", 42)
        agent:setOption("temperature", 0.9)
    end)

    -- @covers lurek.agent
    it("LAgent:setFormat changes the response format", function()
        local agent = lurek.agent.new({ format = "json" })
        agent:setFormat("text")
    end)

    -- @covers lurek.agent
    it("LAgent:setMaxRetries sets the retry count", function()
        local agent = lurek.agent.new({})
        agent:setMaxRetries(3)
    end)

    -- @covers lurek.agent
    it("LAgent:setContextSize sets num_ctx option", function()
        local agent = lurek.agent.new({})
        agent:setContextSize(8192)
    end)

    -- @covers lurek.agent
    it("LAgent:setTemperature sets temperature option", function()
        local agent = lurek.agent.new({})
        agent:setTemperature(0.5)
    end)

    -- @covers lurek.agent
    it("LAgent:setName sets the agent name", function()
        local agent = lurek.agent.new({})
        agent:setName("analyst")
    end)

    -- @covers lurek.agent
    it("LAgent:setDescription sets the role description", function()
        local agent = lurek.agent.new({})
        agent:setDescription("Analyses financial data.")
    end)

    -- @covers lurek.agent
    it("LAgent:setModel changes the model identifier", function()
        local agent = lurek.agent.new({ model = "llama3" })
        agent:setModel("mistral")
    end)

    -- @covers lurek.agent
    it("LAgent:setUrl changes the endpoint URL", function()
        local agent = lurek.agent.new({})
        agent:setUrl("http://10.0.0.1:11434/api/generate")
    end)

    -- @covers lurek.agent
    it("LAgent:setTimeout sets the per-request timeout", function()
        local agent = lurek.agent.new({})
        agent:setTimeout(120)
    end)

    -- @covers lurek.agent
    it("LAgent:getName returns the agent name string", function()
        local agent = lurek.agent.new({})
        agent:setName("planner")
        local name = agent:getName()
        expect_type("string", name)
        expect_equal("planner", name)
    end)

    -- @covers lurek.agent
    it("LAgent:getDescription returns the role description string", function()
        local agent = lurek.agent.new({})
        agent:setDescription("Plans tasks.")
        local desc = agent:getDescription()
        expect_type("string", desc)
        expect_equal("Plans tasks.", desc)
    end)

    -- @covers lurek.agent
    it("LAgent:getModel returns the model identifier string", function()
        local agent = lurek.agent.new({ model = "llama3" })
        local m = agent:getModel()
        expect_type("string", m)
        expect_equal("llama3", m)
    end)

    -- @covers lurek.agent
    it("LAgent:getUrl returns the endpoint URL string", function()
        local url   = "http://127.0.0.1:11434/api/generate"
        local agent = lurek.agent.new({ url = url })
        local got   = agent:getUrl()
        expect_type("string", got)
        expect_equal(url, got)
    end)

    -- @covers lurek.agent
    it("LAgent:getFormat returns the response format string", function()
        local agent = lurek.agent.new({ format = "csv" })
        local fmt   = agent:getFormat()
        expect_type("string", fmt)
        expect_equal("csv", fmt)
    end)

    -- @covers lurek.agent
    it("LAgent:hasSkill returns false when no skills added", function()
        local agent = lurek.agent.new({})
        expect_false(agent:hasSkill("math"), "no skills should be registered yet")
    end)

    -- @covers lurek.agent
    it("LAgent:hasSkill returns true after addSkill", function()
        local agent = lurek.agent.new({})
        agent:addSkill("math", "You are great at math.")
        expect_true(agent:hasSkill("math"))
    end)

    -- @covers lurek.agent
    it("LAgent:skillCount returns 0 for new agent", function()
        local agent = lurek.agent.new({})
        expect_equal(0, agent:skillCount())
    end)

    -- @covers lurek.agent
    it("LAgent:skillCount returns correct count after adding skills", function()
        local agent = lurek.agent.new({})
        agent:addSkill("s1", "text1")
        agent:addSkill("s2", "text2")
        expect_equal(2, agent:skillCount())
    end)

    -- @covers lurek.agent
    it("LAgent:listSkills returns a table of skill names", function()
        local agent = lurek.agent.new({})
        agent:addSkill("alpha", "text")
        agent:addSkill("beta", "text")
        local names = agent:listSkills()
        expect_type("table", names)
        expect_equal("alpha", names[1])
        expect_equal("beta", names[2])
    end)

    -- @covers lurek.agent
    it("LAgent:prompt returns a positive integer callback ID", function()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = agent:prompt("Hello", function(ok, data, err) end)
        expect_type("number", id)
        expect_true(id > 0, "callback ID must be positive")
    end)

    -- @covers lurek.agent
    it("LAgent:promptBatch returns a positive integer batch ID", function()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = agent:promptBatch({ "Q1", "Q2" }, function(results) end)
        expect_type("number", id)
        expect_true(id > 0, "batch ID must be positive")
    end)

    -- @covers lurek.agent
    it("LAgent:cancel accepts a callback ID without error", function()
        local agent = lurek.agent.new({})
        local id = agent:prompt("test", function() end)
        agent:cancel(id)
    end)

    -- @covers lurek.agent
    it("LAgent:pendingCount returns a non-negative integer", function()
        local agent = lurek.agent.new({})
        local n = agent:pendingCount()
        expect_type("number", n)
        expect_true(n >= 0, "pendingCount must be non-negative")
    end)

    -- @covers lurek.agent
    it("LAgent:update runs without error when no responses are pending", function()
        local agent = lurek.agent.new({})
        agent:update()
    end)

    -- @covers lurek.agent
    it("LAgent:evalCode executes Lua code in the active VM", function()
        local agent = lurek.agent.new({})
        local ok = agent:evalCode("local x = 1 + 1")
        expect_true(ok, "evalCode should return true on success")
    end)

    -- @covers lurek.agent
    it("LAgent:evalCode raises on bad syntax", function()
        local agent = lurek.agent.new({})
        local ok, _ = pcall(function()
            agent:evalCode("not valid lua !@#$%")
        end)
        expect_false(ok, "evalCode should raise on syntax error")
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LAgentManager methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers lurek.agent
    it("LAgentManager:runAll returns 0 for empty task list", function()
        local manager = lurek.agent.newManager()
        local id = manager:runAll({}, function(results) end)
        expect_equal(0, id, "empty runAll should return 0")
    end)

    -- @covers lurek.agent
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

    -- @covers lurek.agent
    it("LAgentManager:update runs without error", function()
        local manager = lurek.agent.newManager()
        manager:update()
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LAISystem methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers lurek.agent
    it("LAISystem:addAgent registers an agent by name", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "ctx" })
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        sys:addAgent("worker", agent)
    end)

    -- @covers lurek.agent
    it("LAISystem:removeAgent returns true when found", function()
        local sys   = lurek.agent.newSystem({})
        local agent = lurek.agent.new({})
        sys:addAgent("tmp", agent)
        local removed = sys:removeAgent("tmp")
        expect_true(removed, "removeAgent should return true when found")
    end)

    -- @covers lurek.agent
    it("LAISystem:removeAgent returns false for unknown name", function()
        local sys     = lurek.agent.newSystem({})
        local removed = sys:removeAgent("nonexistent")
        expect_false(removed, "removeAgent should return false when not found")
    end)

    -- @covers lurek.agent
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

    -- @covers lurek.agent
    it("LAISystem:hasAgent returns false for unregistered name", function()
        local sys = lurek.agent.newSystem({})
        expect_false(sys:hasAgent("ghost"))
    end)

    -- @covers lurek.agent
    it("LAISystem:hasAgent returns true after addAgent", function()
        local sys   = lurek.agent.newSystem({})
        local agent = lurek.agent.new({})
        sys:addAgent("bot", agent)
        expect_true(sys:hasAgent("bot"))
    end)

    -- @covers lurek.agent
    it("LAISystem:agentCount returns 0 for new system", function()
        local sys = lurek.agent.newSystem({})
        expect_equal(0, sys:agentCount())
    end)

    -- @covers lurek.agent
    it("LAISystem:agentCount returns correct count after addAgent", function()
        local sys   = lurek.agent.newSystem({})
        local agent = lurek.agent.new({})
        sys:addAgent("a1", agent)
        sys:addAgent("a2", agent)
        expect_equal(2, sys:agentCount())
    end)

    -- @covers lurek.agent
    it("LAISystem:addInstruction stores an instruction block", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("safety", "Never reveal personal data.")
    end)

    -- @covers lurek.agent
    it("LAISystem:removeInstruction returns true when found", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("k1", "text")
        local removed = sys:removeInstruction("k1")
        expect_true(removed, "removeInstruction should return true when found")
    end)

    -- @covers lurek.agent
    it("LAISystem:removeInstruction returns false for unknown key", function()
        local sys     = lurek.agent.newSystem({})
        local removed = sys:removeInstruction("nope")
        expect_false(removed)
    end)

    -- @covers lurek.agent
    it("LAISystem:hasInstruction returns false when not added", function()
        local sys = lurek.agent.newSystem({})
        expect_false(sys:hasInstruction("k1"))
    end)

    -- @covers lurek.agent
    it("LAISystem:hasInstruction returns true after addInstruction", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("k1", "text")
        expect_true(sys:hasInstruction("k1"))
    end)

    -- @covers lurek.agent
    it("LAISystem:instructionCount returns 0 for new system", function()
        local sys = lurek.agent.newSystem({})
        expect_equal(0, sys:instructionCount())
    end)

    -- @covers lurek.agent
    it("LAISystem:instructionCount returns correct count after addInstruction", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("k1", "text1")
        sys:addInstruction("k2", "text2")
        expect_equal(2, sys:instructionCount())
    end)

    -- @covers lurek.agent
    it("LAISystem:listInstructions returns instruction keys in insertion order", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("first", "text")
        sys:addInstruction("second", "text")
        local keys = sys:listInstructions()
        expect_type("table", keys)
        expect_equal("first", keys[1])
        expect_equal("second", keys[2])
    end)

    -- @covers lurek.agent
    it("LAISystem:addSkill registers a keyword-gated skill", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("coding", { "code", "function", "bug" }, "You write clean code.")
    end)

    -- @covers lurek.agent
    it("LAISystem:removeSkill returns true when found", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("s", { "kw" }, "text")
        local removed = sys:removeSkill("s")
        expect_true(removed)
    end)

    -- @covers lurek.agent
    it("LAISystem:removeSkill returns false for unknown name", function()
        local sys     = lurek.agent.newSystem({})
        local removed = sys:removeSkill("nope")
        expect_false(removed)
    end)

    -- @covers lurek.agent
    it("LAISystem:hasSkill returns false when not added", function()
        local sys = lurek.agent.newSystem({})
        expect_false(sys:hasSkill("coding"))
    end)

    -- @covers lurek.agent
    it("LAISystem:hasSkill returns true after addSkill", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("coding", { "code", "bug" }, "You write clean code.")
        expect_true(sys:hasSkill("coding"))
    end)

    -- @covers lurek.agent
    it("LAISystem:skillCount returns 0 for new system", function()
        local sys = lurek.agent.newSystem({})
        expect_equal(0, sys:skillCount())
    end)

    -- @covers lurek.agent
    it("LAISystem:skillCount returns correct count after addSkill", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("s1", { "kw1" }, "text1")
        sys:addSkill("s2", { "kw2" }, "text2")
        expect_equal(2, sys:skillCount())
    end)

    -- @covers lurek.agent
    it("LAISystem:buildContext returns a non-empty string", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "base context" })
        local agent = lurek.agent.new({})
        sys:addAgent("bot", agent)
        local ctx = sys:buildContext("what is code?", { agent = "bot" })
        expect_type("string", ctx)
        expect_true(#ctx > 0, "context should not be empty")
    end)

    -- @covers lurek.agent
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

    -- @covers lurek.agent
    it("LAISystem:prompt errors for unregistered agent name", function()
        local sys = lurek.agent.newSystem({})
        local ok, _ = pcall(function()
            sys:prompt("ghost", "hello", function() end, {})
        end)
        expect_false(ok, "prompt should error for unknown agent")
    end)

    -- @covers lurek.agent
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

    -- @covers lurek.agent
    it("LAISystem:update runs without error", function()
        local sys = lurek.agent.newSystem({})
        sys:update()
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LOllamaManager methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers lurek.agent
    it("LOllamaManager:isRunning returns a boolean", function()
        local ollama  = lurek.agent.newOllama()
        local running = ollama:isRunning()
        expect_type("boolean", running)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:version returns a string", function()
        local ollama = lurek.agent.newOllama()
        local v      = ollama:version()
        expect_type("string", v)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:baseUrl returns the configured base URL string", function()
        local url    = "http://127.0.0.1:11434"
        local ollama = lurek.agent.newOllama({ url = url })
        local got    = ollama:baseUrl()
        expect_type("string", got)
        expect_equal(url, got)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:listModels returns a table", function()
        local ollama = lurek.agent.newOllama()
        local models = ollama:listModels()
        expect_type("table", models)
    end)
    -- @covers lurek.agent
    it("LOllamaManager:modelNames returns a string-array table", function()
        local ollama = lurek.agent.newOllama()
        local names  = ollama:modelNames()
        expect_type("table", names)
    end)
    -- @covers lurek.agent
    it("LOllamaManager:hasModel returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local found  = ollama:hasModel("llama3")
        expect_type("boolean", found)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:start returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:start()
        expect_type("boolean", ok)
        if ok then ollama:stop() end
    end)

    -- @covers lurek.agent
    it("LOllamaManager:stop returns a boolean", function()
        local ollama  = lurek.agent.newOllama()
        local stopped = ollama:stop()
        expect_type("boolean", stopped)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:restart returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:restart()
        expect_type("boolean", ok)
        if ok then ollama:stop() end
    end)

    -- @covers lurek.agent
    it("LOllamaManager:pullModel returns a positive integer callback ID", function()
        local ollama = lurek.agent.newOllama()
        local id     = ollama:pullModel("llama3", function(ok, err) end)
        expect_type("number", id)
        expect_true(id > 0, "pullModel should return a positive callback ID")
    end)

    -- @covers lurek.agent
    it("LOllamaManager:deleteModel returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:deleteModel("nonexistent_model_xyz")
        expect_type("boolean", ok)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:pendingCount returns a non-negative integer", function()
        local ollama = lurek.agent.newOllama()
        local n      = ollama:pendingCount()
        expect_type("number", n)
        expect_true(n >= 0)
    end)

    -- @covers lurek.agent
    it("LOllamaManager:update runs without error", function()
        local ollama = lurek.agent.newOllama()
        ollama:update()
    end)

    -- @describe lurek.agent direct LLM helpers
    it("lurek.agent.configure updates the global provider config", function()
        configure_dead_agent_backend()
        expect_type("function", lurek.agent.complete)
        expect_type("function", lurek.agent.completeAsync)
    end)
    it("lurek.agent.complete raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local ok, err = pcall(lurek.agent.complete, "hello from unreachable backend")
        expect_false(ok)
        expect_not_nil(err)
    end)
    it("lurek.agent.completeAsync reports an error through the callback when the backend is unreachable", function()
        configure_dead_agent_backend()
        local seen_text = nil
        local seen_err = nil
        lurek.agent.completeAsync("what is lua?", function(text, err)
            seen_text = text
            seen_err = err
        end)
        expect_true(seen_text == nil, "unreachable backend should not produce text")
        expect_type("string", seen_err)
    end)
    it("lurek.agent.completeJson raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local ok, err = pcall(lurek.agent.completeJson, "return json")
        expect_false(ok)
        expect_not_nil(err)
    end)
    it("lurek.agent.embed raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local ok, err = pcall(lurek.agent.embed, "embedding request")
        expect_false(ok)
        expect_not_nil(err)
    end)
    it("lurek.agent.isAvailable returns a boolean", function()
        configure_dead_agent_backend()
        expect_type("boolean", lurek.agent.isAvailable())
    end)
    it("lurek.agent.listModels returns a table even when the backend is unreachable", function()
        configure_dead_agent_backend()
        local models = lurek.agent.listModels()
        expect_type("table", models)
    end)
    it("lurek.agent.newChat creates a chat handle", function()
        local chat = lurek.agent.newChat()
        expect_not_nil(chat)
        expect_type("function", chat.getHistory)
    end)
    it("LAgentChat stores system and user messages in history", function()
        local chat = lurek.agent.newChat()
        chat:setSystemPrompt("You are a careful assistant.")
        chat:addMessage("user", "Hello")
        local history = chat:getHistory()
        expect_equal(1, #history)
        expect_equal("user", history[1].role)
        expect_equal("Hello", history[1].content)
    end)
    it("LAgentChat:complete raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local chat = lurek.agent.newChat()
        chat:addMessage("user", "Ping")
        local ok, err = pcall(function()
            chat:complete()
        end)
        expect_false(ok)
        expect_not_nil(err)
    end)
    it("LAgentChat:clear removes all history entries", function()
        local chat = lurek.agent.newChat()
        chat:addMessage("user", "first")
        chat:addMessage("assistant", "second")
        chat:clear()
        expect_equal(0, #chat:getHistory())
    end)
    it("lurek.agent.newTemplate creates a renderable template", function()
        local template = lurek.agent.newTemplate("Hello, {name}!")
        expect_not_nil(template)
        expect_type("function", template.render)
    end)
    it("LAgentTemplate:render substitutes string and numeric placeholders", function()
        local template = lurek.agent.newTemplate("Hello, {name}! Level {level}.")
        local rendered = template:render({ name = "Alice", level = 3 })
        expect_equal("Hello, Alice! Level 3.", rendered)
    end)
    it("LAgentTemplate:render raises when a placeholder is missing", function()
        local template = lurek.agent.newTemplate("Hello, {name}!")
        local ok, err = pcall(function()
            template:render({})
        end)
        expect_false(ok)
        expect_not_nil(err)
    end)
    it("lurek.agent.newWorkingMemory creates a bounded working memory", function()
        local memory = lurek.agent.newWorkingMemory(16)
        expect_not_nil(memory)
        expect_equal(16, memory:capacity())
    end)
    it("LWorkingMemory stores and returns scalar values", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("hp", 100)
        expect_equal(100, memory:get("hp"))
    end)
    it("LWorkingMemory:forget returns true for an existing key", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("temp", "value")
        expect_true(memory:forget("temp"))
        expect_true(memory:get("temp") == nil)
    end)
    it("LWorkingMemory:getRecent returns the newest inserted entries", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("a", 1)
        memory:push("b", 2)
        memory:push("c", 3)
        local recent = memory:getRecent(2)
        expect_equal(3, memory:len())
        expect_equal(2, #recent)
        expect_equal("b", recent[1].key)
        expect_equal("c", recent[2].key)
    end)
    it("lurek.agent.newEpisodicMemory creates an episodic memory handle", function()
        local memory = lurek.agent.newEpisodicMemory()
        expect_not_nil(memory)
        expect_type("function", memory.record)
    end)
    it("LEpisodicMemory records and filters episodes by payload", function()
        local memory = lurek.agent.newEpisodicMemory()
        memory:record(1, { type = "kill", target = "slime" })
        memory:record(2, { type = "heal", amount = 5 })
        local kills = memory:query({ type = "kill" })
        expect_equal(2, memory:len())
        expect_equal(1, #kills)
        expect_equal(1, kills[1].tick)
        expect_equal("slime", kills[1].data.target)
    end)
    it("LEpisodicMemory:forgetBefore prunes older episodes", function()
        local memory = lurek.agent.newEpisodicMemory()
        memory:record(10, { note = "old" })
        memory:record(20, { note = "new" })
        memory:forgetBefore(15)
        expect_equal(1, memory:len())
        expect_equal(20, memory:query({})[1].tick)
    end)
    it("lurek.agent.newSemanticMemory creates a semantic memory handle", function()
        local memory = lurek.agent.newSemanticMemory()
        expect_not_nil(memory)
        expect_type("function", memory.learn)
    end)
    it("LSemanticMemory stores and recalls named facts", function()
        local memory = lurek.agent.newSemanticMemory()
        memory:learn("capital", { value = "Paris", category = "geo" })
        local fact = memory:recall("capital")
        expect_equal(1, memory:len())
        expect_equal("Paris", fact.value)
        expect_equal("geo", fact.category)
    end)
    it("LSemanticMemory can query and remove stored facts", function()
        local memory = lurek.agent.newSemanticMemory()
        memory:learn("fact_a", { category = "geo" })
        memory:learn("fact_b", { category = "combat" })
        local geo = memory:query({ category = "geo" })
        expect_equal(1, #geo)
        expect_equal("fact_a", geo[1].key)
        expect_true(memory:forget("fact_a"))
        expect_true(memory:recall("fact_a") == nil)
    end)
    it("lurek.agent.newAgentMemory creates a bundled memory handle", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 12 })
        expect_not_nil(memory)
        expect_type("function", memory.working)
    end)
    it("LAgentMemory exposes working, episodic, and semantic components", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 6 })
        local working = memory:working()
        local episodic = memory:episodic()
        local semantic = memory:semantic()
        expect_equal(6, working:capacity())
        expect_type("function", episodic.record)
        expect_type("function", semantic.learn)
    end)
    it("LAgentMemory saves and loads from disk when persist_path is configured", function()
        local memory = lurek.agent.newAgentMemory({ persist_path = AGENT_MEMORY_PATH })
        expect_true(memory:save())
        expect_true(memory:load())
    end)
    it("lurek.agent.new creates a LAgent", function()
        local agent = lurek.agent.new({
            url = "http://localhost:11434",
            model = "test",
        })
        expect_not_nil(agent)
        expect_type("function", agent.update)
    end)
    it("LWorkingMemory:get retrieves stored values", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("key1", 42)
        memory:push("key2", "value")
        expect_equal(42, memory:get("key1"))
        expect_equal("value", memory:get("key2"))
    end)
    it("LWorkingMemory:len returns count of stored items", function()
        local memory = lurek.agent.newWorkingMemory(5)
        expect_equal(0, memory:len())
        memory:push("a", 1)
        expect_equal(1, memory:len())
        memory:push("b", 2)
        expect_equal(2, memory:len())
    end)
    it("LEpisodicMemory:len returns total episodes recorded", function()
        local memory = lurek.agent.newEpisodicMemory()
        expect_equal(0, memory:len())
        memory:record(1, { event = "start" })
        expect_equal(1, memory:len())
        memory:record(2, { event = "action" })
        expect_equal(2, memory:len())
    end)
    it("LSemanticMemory:len returns count of stored facts", function()
        local memory = lurek.agent.newSemanticMemory()
        expect_equal(0, memory:len())
        memory:learn("fact1", "The sky is blue")
        expect_equal(1, memory:len())
        memory:learn("fact2", "Water is wet")
        expect_equal(2, memory:len())
    end)
end)
test_summary()