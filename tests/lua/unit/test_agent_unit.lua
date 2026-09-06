-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_agent_core_unit.lua
do
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

local function poll_module_agent_until(predicate)
    for _ = 1, 80 do
        lurek.agent.update()
        if predicate() then
            return true
        end
        if lurek.timer and lurek.timer.sleep then
            lurek.timer.sleep(0.02)
        end
    end
    return predicate()
end

-- @describe lurek.agent module
describe("lurek.agent module", function()

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ Module constructors Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers lurek.agent.new
    it("lurek.agent.new creates agents from full and default config", function()
        local configured = lurek.agent.new({
            url           = "http://localhost:11434/api/generate",
            model         = "llama3",
            system_prompt = "You are a test agent.",
            format        = "json",
            options       = { num_ctx = 4096, temperature = 0.7 },
        })
        local defaults = lurek.agent.new({})
        expect_not_nil(configured, "lurek.agent.new should return a value")
        expect_type("function", configured.prompt)
        expect_not_nil(defaults)
    end)

    -- @covers lurek.agent.newManager
    it("lurek.agent.newManager creates a LAgentManager", function()
        local manager = lurek.agent.newManager()
        expect_not_nil(manager)
        expect_type("function", manager.runAll)
        expect_type("function", manager.update)
    end)

    -- @covers lurek.agent.newSystem
    it("lurek.agent.newSystem creates a LAISystem", function()
        local sys = lurek.agent.newSystem({ system_prompt = "shared context" })
        expect_not_nil(sys)
        expect_type("function", sys.addAgent)
        expect_type("function", sys.prompt)
    end)

    -- @covers lurek.agent.newOllama
    it("lurek.agent.newOllama creates managers with default and configured urls", function()
        local default_ollama = lurek.agent.newOllama()
        local configured_ollama = lurek.agent.newOllama({ url = "http://127.0.0.1:11434" })
        expect_not_nil(default_ollama)
        expect_type("function", default_ollama.isRunning)
        expect_not_nil(configured_ollama)
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LAgent methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers LAgent:addSkill
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

    -- @covers LAgent:clearSkills
    it("LAgent:clearSkills removes all skills", function()
        local agent = lurek.agent.new({})
        agent:addSkill("s1", "Skill one.")
        agent:addSkill("s2", "Skill two.")
        agent:clearSkills()
    end)

    -- @covers LAgent:setOption
    it("LAgent:setOption sets a model option", function()
        local agent = lurek.agent.new({})
        agent:setOption("seed", 42)
        agent:setOption("temperature", 0.9)
    end)

    -- @covers LAgent:setFormat
    it("LAgent:setFormat changes the response format", function()
        local agent = lurek.agent.new({ format = "json" })
        agent:setFormat("text")
    end)

    -- @covers LAgent:setMaxRetries
    it("LAgent:setMaxRetries sets the retry count", function()
        local agent = lurek.agent.new({})
        agent:setMaxRetries(3)
    end)

    -- @covers LAgent:setContextSize
    it("LAgent:setContextSize sets num_ctx option", function()
        local agent = lurek.agent.new({})
        agent:setContextSize(8192)
    end)

    -- @covers LAgent:setTemperature
    it("LAgent:setTemperature sets temperature option", function()
        local agent = lurek.agent.new({})
        agent:setTemperature(0.5)
    end)

    -- @covers LAgent:setName
    it("LAgent:setName sets the agent name", function()
        local agent = lurek.agent.new({})
        agent:setName("analyst")
    end)

    -- @covers LAgent:setDescription
    it("LAgent:setDescription sets the role description", function()
        local agent = lurek.agent.new({})
        agent:setDescription("Analyses financial data.")
    end)

    -- @covers LAgent:setModel
    it("LAgent:setModel changes the model identifier", function()
        local agent = lurek.agent.new({ model = "llama3" })
        agent:setModel("mistral")
    end)

    -- @covers LAgent:setUrl
    it("LAgent:setUrl rejects external hosts in safe mode", function()
        local agent = lurek.agent.new({})
        local ok, err = pcall(function()
            agent:setUrl("http://10.0.0.1:11434/api/generate")
        end)
        expect_false(ok)
        expect_not_nil(err)
    end)

    -- @covers LAgent:setTimeout
    it("LAgent:setTimeout sets the per-request timeout", function()
        local agent = lurek.agent.new({})
        agent:setTimeout(120)
    end)

    -- @covers LAgent:getName
    it("LAgent:getName returns the agent name string", function()
        local agent = lurek.agent.new({})
        agent:setName("planner")
        local name = agent:getName()
        expect_type("string", name)
        expect_equal("planner", name)
    end)

    -- @covers LAgent:getDescription
    it("LAgent:getDescription returns the role description string", function()
        local agent = lurek.agent.new({})
        agent:setDescription("Plans tasks.")
        local desc = agent:getDescription()
        expect_type("string", desc)
        expect_equal("Plans tasks.", desc)
    end)

    -- @covers LAgent:getModel
    it("LAgent:getModel returns the model identifier string", function()
        local agent = lurek.agent.new({ model = "llama3" })
        local m = agent:getModel()
        expect_type("string", m)
        expect_equal("llama3", m)
    end)

    -- @covers LAgent:getUrl
    it("LAgent:getUrl returns the endpoint URL string", function()
        local url   = "http://127.0.0.1:11434/api/generate"
        local agent = lurek.agent.new({ url = url })
        local got   = agent:getUrl()
        expect_type("string", got)
        expect_equal(url, got)
    end)

    -- @covers LAgent:getFormat
    it("LAgent:getFormat returns the response format string", function()
        local agent = lurek.agent.new({ format = "csv" })
        local fmt   = agent:getFormat()
        expect_type("string", fmt)
        expect_equal("csv", fmt)
    end)

    -- @covers LAgent:hasSkill
    it("LAgent:hasSkill reflects whether a skill exists", function()
        local agent = lurek.agent.new({})
        expect_false(agent:hasSkill("math"), "no skills should be registered yet")
        agent:addSkill("math", "You are great at math.")
        expect_true(agent:hasSkill("math"))
    end)

    -- @covers LAgent:skillCount
    it("LAgent:skillCount reflects the current number of skills", function()
        local agent = lurek.agent.new({})
        expect_equal(0, agent:skillCount())
        agent:addSkill("s1", "text1")
        agent:addSkill("s2", "text2")
        expect_equal(2, agent:skillCount())
    end)

    -- @covers LAgent:listSkills
    it("LAgent:listSkills returns a table of skill names", function()
        local agent = lurek.agent.new({})
        agent:addSkill("alpha", "text")
        agent:addSkill("beta", "text")
        local names = agent:listSkills()
        expect_type("table", names)
        expect_equal("alpha", names[1])
        expect_equal("beta", names[2])
    end)

    -- @covers LAgent:prompt
    it("LAgent:prompt returns a positive integer callback ID", function()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = agent:prompt("Hello", function(ok, data, err) end)
        expect_type("number", id)
        expect_true(id > 0, "callback ID must be positive")
    end)

    -- @covers LAgent:promptBatch
    it("LAgent:promptBatch returns a positive integer batch ID", function()
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        local id = agent:promptBatch({ "Q1", "Q2" }, function(results) end)
        expect_type("number", id)
        expect_true(id > 0, "batch ID must be positive")
    end)

    -- @covers LAgent:cancel
    it("LAgent:cancel accepts a callback ID without error", function()
        local agent = lurek.agent.new({})
        local id = agent:prompt("test", function() end)
        agent:cancel(id)
    end)

    -- @covers LAgent:pendingCount
    it("LAgent:pendingCount returns a non-negative integer", function()
        local agent = lurek.agent.new({})
        local n = agent:pendingCount()
        expect_type("number", n)
        expect_true(n >= 0, "pendingCount must be non-negative")
    end)

    -- @covers LAgent:getDiagnostics
    it("LAgent:getDiagnostics exposes transport counters", function()
        local agent = lurek.agent.new({})
        local diagnostics = agent:getDiagnostics()
        expect_type("table", diagnostics)
        expect_type("number", diagnostics.in_flight)
        expect_type("number", diagnostics.queued)
    end)

    -- @covers LAgent:update
    it("LAgent:update runs without error when no responses are pending", function()
        local agent = lurek.agent.new({})
        agent:update()
    end)

    -- @covers LAgent:evalCode
    it("LAgent:evalCode succeeds for valid Lua and errors for bad syntax", function()
        local agent = lurek.agent.new({})
        local ok = agent:evalCode("local x = 1 + 1")
        expect_true(ok, "evalCode should return true on success")
        local syntax_ok, _ = pcall(function()
            agent:evalCode("not valid lua !@#$%")
        end)
        expect_false(syntax_ok, "evalCode should raise on syntax error")
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LAgentManager methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers LAgentManager:runAll
    it("LAgentManager:runAll handles empty and non-empty task lists", function()
        local manager = lurek.agent.newManager()
        local empty_id = manager:runAll({}, function(results) end)
        expect_equal(0, empty_id, "empty runAll should return 0")
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

    -- @covers LAgentManager:update
    it("LAgentManager:update runs without error", function()
        local manager = lurek.agent.newManager()
        manager:update()
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LAISystem methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers LAISystem:addAgent
    it("LAISystem:addAgent registers an agent by name", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "ctx" })
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        sys:addAgent("worker", agent)
    end)

    -- @covers LAISystem:removeAgent
    it("LAISystem:removeAgent returns true for existing names and false otherwise", function()
        local sys   = lurek.agent.newSystem({})
        local agent = lurek.agent.new({})
        sys:addAgent("tmp", agent)
        local removed = sys:removeAgent("tmp")
        expect_true(removed, "removeAgent should return true when found")
        expect_false(sys:removeAgent("nonexistent"), "removeAgent should return false when not found")
    end)

    -- @covers LAISystem:listAgents
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

    -- @covers LAISystem:hasAgent
    it("LAISystem:hasAgent reflects whether an agent is registered", function()
        local sys = lurek.agent.newSystem({})
        expect_false(sys:hasAgent("ghost"))
        local agent = lurek.agent.new({})
        sys:addAgent("bot", agent)
        expect_true(sys:hasAgent("bot"))
    end)

    -- @covers LAISystem:agentCount
    it("LAISystem:agentCount reflects the current number of agents", function()
        local sys = lurek.agent.newSystem({})
        expect_equal(0, sys:agentCount())
        local agent = lurek.agent.new({})
        sys:addAgent("a1", agent)
        sys:addAgent("a2", agent)
        expect_equal(2, sys:agentCount())
    end)

    -- @covers LAISystem:addInstruction
    it("LAISystem:addInstruction stores an instruction block", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("safety", "Never reveal personal data.")
    end)

    -- @covers LAISystem:removeInstruction
    it("LAISystem:removeInstruction returns true for existing keys and false otherwise", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("k1", "text")
        local removed = sys:removeInstruction("k1")
        expect_true(removed, "removeInstruction should return true when found")
        expect_false(sys:removeInstruction("nope"))
    end)

    -- @covers LAISystem:hasInstruction
    it("LAISystem:hasInstruction reflects whether a key was added", function()
        local sys = lurek.agent.newSystem({})
        expect_false(sys:hasInstruction("k1"))
        sys:addInstruction("k1", "text")
        expect_true(sys:hasInstruction("k1"))
    end)

    -- @covers LAISystem:instructionCount
    it("LAISystem:instructionCount reflects the current number of instructions", function()
        local sys = lurek.agent.newSystem({})
        expect_equal(0, sys:instructionCount())
        sys:addInstruction("k1", "text1")
        sys:addInstruction("k2", "text2")
        expect_equal(2, sys:instructionCount())
    end)

    -- @covers LAISystem:listInstructions
    it("LAISystem:listInstructions returns instruction keys in insertion order", function()
        local sys = lurek.agent.newSystem({})
        sys:addInstruction("first", "text")
        sys:addInstruction("second", "text")
        local keys = sys:listInstructions()
        expect_type("table", keys)
        expect_equal("first", keys[1])
        expect_equal("second", keys[2])
    end)

    -- @covers LAISystem:addSkill
    it("LAISystem:addSkill registers a keyword-gated skill", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("coding", { "code", "function", "bug" }, "You write clean code.")
    end)

    -- @covers LAISystem:removeSkill
    it("LAISystem:removeSkill returns true for existing skills and false otherwise", function()
        local sys = lurek.agent.newSystem({})
        sys:addSkill("s", { "kw" }, "text")
        local removed = sys:removeSkill("s")
        expect_true(removed)
        expect_false(sys:removeSkill("nope"))
    end)

    -- @covers LAISystem:hasSkill
    it("LAISystem:hasSkill reflects whether a system skill exists", function()
        local sys = lurek.agent.newSystem({})
        expect_false(sys:hasSkill("coding"))
        sys:addSkill("coding", { "code", "bug" }, "You write clean code.")
        expect_true(sys:hasSkill("coding"))
    end)

    -- @covers LAISystem:skillCount
    it("LAISystem:skillCount reflects the current number of system skills", function()
        local sys = lurek.agent.newSystem({})
        expect_equal(0, sys:skillCount())
        sys:addSkill("s1", { "kw1" }, "text1")
        sys:addSkill("s2", { "kw2" }, "text2")
        expect_equal(2, sys:skillCount())
    end)

    -- @covers LAISystem:buildContext
    it("LAISystem:buildContext returns a non-empty string", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "base context" })
        local agent = lurek.agent.new({})
        sys:addAgent("bot", agent)
        local ctx = sys:buildContext("what is code?", { agent = "bot" })
        expect_type("string", ctx)
        expect_true(#ctx > 0, "context should not be empty")
    end)

    -- @covers LAISystem:buildContextReport
    it("LAISystem:buildContextReport reports provenance for instructions and matched skills", function()
        local sys = lurek.agent.newSystem({ system_prompt = "base context" })
        sys:addInstruction("safety", "be safe")
        sys:addSkill("math", { "matrix" }, "help with math")
        local report = sys:buildContextReport("solve matrix problem", {
            instructions = { "safety" },
        })
        expect_type("table", report)
        expect_type("string", report.text)
        expect_type("table", report.provenance)
        expect_true(#report.provenance >= 2)
        expect_equal("instruction", report.provenance[1].kind)
    end)

    -- @covers LAISystem:prompt
    it("LAISystem:prompt returns a callback id for known agents and errors for unknown ones", function()
        local sys   = lurek.agent.newSystem({ system_prompt = "ctx" })
        local agent = lurek.agent.new({
            url   = "http://127.0.0.1:11434/api/generate",
            model = "llama3",
        })
        sys:addAgent("bot", agent)
        local id = sys:prompt("bot", "hello", function(ok, data, err) end, {})
        expect_type("number", id)
        expect_true(id > 0)
        local ok, _ = pcall(function()
            sys:prompt("ghost", "hello", function() end, {})
        end)
        expect_false(ok, "prompt should error for unknown agent")
    end)

    -- @covers LAISystem:runAll
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

    -- @covers LAISystem:update
    it("LAISystem:update runs without error", function()
        local sys = lurek.agent.newSystem({})
        sys:update()
    end)

    -- @covers LAISystem:getDiagnostics
    it("LAISystem:getDiagnostics returns queue and latency counters", function()
        local sys = lurek.agent.newSystem({})
        local diagnostics = sys:getDiagnostics()
        expect_type("table", diagnostics)
        expect_type("number", diagnostics.in_flight)
        expect_type("number", diagnostics.completed)
        expect_type("number", diagnostics.avg_latency_ms)
    end)

    -- Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ LOllamaManager methods Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

    -- @covers LOllamaManager:isRunning
    it("LOllamaManager:isRunning returns a boolean", function()
        local ollama  = lurek.agent.newOllama()
        local running = ollama:isRunning()
        expect_type("boolean", running)
    end)

    -- @covers LOllamaManager:version
    it("LOllamaManager:version returns a string", function()
        local ollama = lurek.agent.newOllama()
        local v      = ollama:version()
        expect_type("string", v)
    end)

    -- @covers LOllamaManager:baseUrl
    it("LOllamaManager:baseUrl returns the configured base URL string", function()
        local url    = "http://127.0.0.1:11434"
        local ollama = lurek.agent.newOllama({ url = url })
        local got    = ollama:baseUrl()
        expect_type("string", got)
        expect_equal(url, got)
    end)

    -- @covers LOllamaManager:listModels
    it("LOllamaManager:listModels returns a table", function()
        local ollama = lurek.agent.newOllama()
        local models = ollama:listModels()
        expect_type("table", models)
    end)
    -- @covers LOllamaManager:modelNames
    it("LOllamaManager:modelNames returns a string-array table", function()
        local ollama = lurek.agent.newOllama()
        local names  = ollama:modelNames()
        expect_type("table", names)
    end)
    -- @covers LOllamaManager:hasModel
    it("LOllamaManager:hasModel returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local found  = ollama:hasModel("llama3")
        expect_type("boolean", found)
    end)

    -- @covers LOllamaManager:start
    it("LOllamaManager:start returns a boolean or raises a descriptive error", function()
        local ollama = lurek.agent.newOllama()
        local ok, result = pcall(function()
            return ollama:start()
        end)
        if ok then
            expect_type("boolean", result)
            if result then ollama:stop() end
        else
            expect_not_nil(result)
        end
    end)

    -- @covers LOllamaManager:stop
    it("LOllamaManager:stop returns a boolean", function()
        local ollama  = lurek.agent.newOllama()
        local stopped = ollama:stop()
        expect_type("boolean", stopped)
    end)

    -- @covers LOllamaManager:restart
    it("LOllamaManager:restart returns a boolean", function()
        local ollama = lurek.agent.newOllama()
        local ok     = ollama:restart()
        expect_type("boolean", ok)
        if ok then ollama:stop() end
    end)

    -- @covers LOllamaManager:pullModel
    it("LOllamaManager:pullModel returns a positive integer callback ID", function()
        local ollama = lurek.agent.newOllama()
        local id     = ollama:pullModel("llama3", function(ok, err) end)
        expect_type("number", id)
        expect_true(id > 0, "pullModel should return a positive callback ID")
    end)

    -- @covers LOllamaManager:cancelPull
    it("LOllamaManager:cancelPull accepts a callback ID", function()
        local ollama = lurek.agent.newOllama()
        local id     = ollama:pullModel("llama3", function(ok, err) end)
        local ok     = ollama:cancelPull(id)
        expect_type("boolean", ok)
    end)

    -- @covers LOllamaManager:deleteModel
    it("LOllamaManager:deleteModel returns a boolean or raises a descriptive error", function()
        local ollama = lurek.agent.newOllama()
        local ok, result = pcall(function()
            return ollama:deleteModel("nonexistent_model_xyz")
        end)
        if ok then
            expect_type("boolean", result)
        else
            expect_not_nil(result)
        end
    end)

    -- @covers LOllamaManager:pendingCount
    it("LOllamaManager:pendingCount returns a non-negative integer", function()
        local ollama = lurek.agent.newOllama()
        local n      = ollama:pendingCount()
        expect_type("number", n)
        expect_true(n >= 0)
    end)

    -- @covers LOllamaManager:getDiagnostics
    it("LOllamaManager:getDiagnostics returns a diagnostics table", function()
        local ollama = lurek.agent.newOllama()
        local diagnostics = ollama:getDiagnostics()
        expect_type("table", diagnostics)
        expect_type("number", diagnostics.in_flight_pulls)
        expect_type("number", diagnostics.queued_pulls)
    end)

    -- @covers LOllamaManager:update
    it("LOllamaManager:update runs without error", function()
        local ollama = lurek.agent.newOllama()
        ollama:update()
    end)

    -- @describe lurek.agent direct LLM helpers
    -- @covers lurek.agent.configure
    it("lurek.agent.configure updates the global provider config", function()
        configure_dead_agent_backend()
        expect_type("function", lurek.agent.complete)
        expect_type("function", lurek.agent.completeAsync)
    end)
    -- @covers lurek.agent.getDiagnostics
    it("lurek.agent.getDiagnostics exposes module-level async counters", function()
        local diagnostics = lurek.agent.getDiagnostics()
        expect_type("table", diagnostics)
        expect_type("number", diagnostics.in_flight)
        expect_type("number", diagnostics.queued)
    end)
    -- @covers lurek.agent.complete
    it("lurek.agent.complete raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local ok, err = pcall(lurek.agent.complete, "hello from unreachable backend")
        expect_false(ok)
        expect_not_nil(err)
    end)
    -- @covers lurek.agent.completeAsync
    it("lurek.agent.completeAsync returns immediately and reports through polling", function()
        configure_dead_agent_backend()
        local seen_text = nil
        local seen_err = nil
        local id = lurek.agent.completeAsync("what is lua?", function(text, err)
            seen_text = text
            seen_err = err
        end)
        expect_type("number", id)
        expect_true(seen_text == nil, "unreachable backend should not produce text")
        local delivered = poll_module_agent_until(function()
            return seen_err ~= nil
        end)
        expect_true(delivered, "async callback should be delivered by update")
        expect_type("string", seen_err)
    end)
    -- @covers lurek.agent.update
    it("lurek.agent.update polls module-level async completions", function()
        expect_no_error(function()
            lurek.agent.update()
        end)
    end)
    -- @covers lurek.agent.pendingCount
    it("lurek.agent.pendingCount returns a non-negative integer", function()
        local n = lurek.agent.pendingCount()
        expect_type("number", n)
        expect_true(n >= 0, "pendingCount must be non-negative")
    end)
    -- @covers lurek.agent.cancel
    it("lurek.agent.cancel accepts a module-level callback ID", function()
        expect_no_error(function()
            lurek.agent.cancel(999999)
        end)
    end)
    -- @covers lurek.agent.completeJson
    it("lurek.agent.completeJson raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local ok, err = pcall(lurek.agent.completeJson, "return json")
        expect_false(ok)
        expect_not_nil(err)
    end)
    -- @covers lurek.agent.embed
    it("lurek.agent.embed raises a Lua error when the backend is unreachable", function()
        configure_dead_agent_backend()
        local ok, err = pcall(lurek.agent.embed, "embedding request")
        expect_false(ok)
        expect_not_nil(err)
    end)
    -- @covers lurek.agent.isAvailable
    it("lurek.agent.isAvailable returns a boolean", function()
        configure_dead_agent_backend()
        expect_type("boolean", lurek.agent.isAvailable())
    end)
    -- @covers lurek.agent.listModels
    it("lurek.agent.listModels returns a table even when the backend is unreachable", function()
        configure_dead_agent_backend()
        local models = lurek.agent.listModels()
        expect_type("table", models)
    end)
    -- @covers lurek.agent.newChat
    it("lurek.agent.newChat creates a chat handle", function()
        local chat = lurek.agent.newChat()
        expect_not_nil(chat)
        expect_type("function", chat.getHistory)
    end)
    -- @covers LAgentChat:addMessage
    it("LAgentChat stores system and user messages in history", function()
        local chat = lurek.agent.newChat()
        chat:setSystemPrompt("You are a careful assistant.")
        chat:addMessage("user", "Hello")
        local history = chat:getHistory()
        expect_equal(1, #history)
        expect_equal("user", history[1].role)
        expect_equal("Hello", history[1].content)
    end)
    -- @covers LAgentChat:setSystemPrompt
    it("LAgentChat:setSystemPrompt keeps later user history entries intact", function()
        local chat = lurek.agent.newChat()
        chat:setSystemPrompt("You are a careful assistant.")
        chat:addMessage("user", "Hello")
        local history = chat:getHistory()
        expect_equal(1, #history)
        expect_equal("user", history[1].role)
    end)
    -- @covers LAgentChat:getHistory
    it("LAgentChat:getHistory returns role and content tables", function()
        local chat = lurek.agent.newChat()
        chat:addMessage("assistant", "Ready")
        local history = chat:getHistory()
        expect_type("table", history)
        expect_equal("assistant", history[1].role)
        expect_equal("Ready", history[1].content)
    end)
    -- @covers LAgentChat:complete
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
    -- @covers LAgentChat:clear
    it("LAgentChat:clear removes all history entries", function()
        local chat = lurek.agent.newChat()
        chat:addMessage("user", "first")
        chat:addMessage("assistant", "second")
        chat:clear()
        expect_equal(0, #chat:getHistory())
    end)
    -- @covers lurek.agent.newTemplate
    it("lurek.agent.newTemplate creates a renderable template", function()
        local template = lurek.agent.newTemplate("Hello, {name}!")
        expect_not_nil(template)
        expect_type("function", template.render)
    end)
    -- @covers LAgentTemplate:render
    it("LAgentTemplate:render substitutes placeholders and errors when a value is missing", function()
        local template = lurek.agent.newTemplate("Hello, {name}! Level {level}.")
        local rendered = template:render({ name = "Alice", level = 3 })
        expect_equal("Hello, Alice! Level 3.", rendered)
        local missing_template = lurek.agent.newTemplate("Hello, {name}!")
        local ok, err = pcall(function()
            missing_template:render({})
        end)
        expect_false(ok)
        expect_not_nil(err)
    end)
    -- @covers lurek.agent.newWorkingMemory
    it("lurek.agent.newWorkingMemory creates a bounded working memory", function()
        local memory = lurek.agent.newWorkingMemory(16)
        expect_not_nil(memory)
        expect_equal(16, memory:capacity())
    end)
    -- @covers LWorkingMemory:capacity
    it("LWorkingMemory:capacity returns the configured limit", function()
        local memory = lurek.agent.newWorkingMemory(16)
        expect_equal(16, memory:capacity())
    end)
    -- @covers LWorkingMemory:push
    it("LWorkingMemory stores and returns scalar values", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("hp", 100)
        expect_equal(100, memory:get("hp"))
    end)
    -- @covers LWorkingMemory:forget
    it("LWorkingMemory:forget returns true for an existing key", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("temp", "value")
        expect_true(memory:forget("temp"))
        expect_true(memory:get("temp") == nil)
    end)
    -- @covers LWorkingMemory:getRecent
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
    -- @covers lurek.agent.newEpisodicMemory
    it("lurek.agent.newEpisodicMemory creates an episodic memory handle", function()
        local memory = lurek.agent.newEpisodicMemory()
        expect_not_nil(memory)
        expect_type("function", memory.record)
    end)
    -- @covers LEpisodicMemory:record
    it("LEpisodicMemory:record appends episodes that can be queried back", function()
        local memory = lurek.agent.newEpisodicMemory()
        memory:record(100, { event = "player_hit", damage = 10 })
        local events = memory:query({ event = "player_hit" })
        expect_equal(1, #events)
        expect_equal(100, events[1].tick)
        expect_equal(10, events[1].data.damage)
    end)
    -- @covers LEpisodicMemory:query
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
    -- @covers LEpisodicMemory:forgetBefore
    it("LEpisodicMemory:forgetBefore prunes older episodes", function()
        local memory = lurek.agent.newEpisodicMemory()
        memory:record(10, { note = "old" })
        memory:record(20, { note = "new" })
        memory:forgetBefore(15)
        expect_equal(1, memory:len())
        expect_equal(20, memory:query({})[1].tick)
    end)
    -- @covers lurek.agent.newSemanticMemory
    it("lurek.agent.newSemanticMemory creates a semantic memory handle", function()
        local memory = lurek.agent.newSemanticMemory()
        expect_not_nil(memory)
        expect_type("function", memory.learn)
    end)
    -- @covers LSemanticMemory:learn
    it("LSemanticMemory:learn stores a fact under its key", function()
        local memory = lurek.agent.newSemanticMemory()
        memory:learn("capital", { value = "Paris" })
        local fact = memory:recall("capital")
        expect_equal("Paris", fact.value)
    end)
    -- @covers LSemanticMemory:recall
    it("LSemanticMemory stores and recalls named facts", function()
        local memory = lurek.agent.newSemanticMemory()
        memory:learn("capital", { value = "Paris", category = "geo" })
        local fact = memory:recall("capital")
        expect_equal(1, memory:len())
        expect_equal("Paris", fact.value)
        expect_equal("geo", fact.category)
    end)
    -- @covers LSemanticMemory:query
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
    -- @covers LSemanticMemory:forget
    it("LSemanticMemory:forget removes a stored fact by key", function()
        local memory = lurek.agent.newSemanticMemory()
        memory:learn("fact_a", { category = "geo" })
        expect_true(memory:forget("fact_a"))
        expect_nil(memory:recall("fact_a"))
    end)
    -- @covers lurek.agent.newAgentMemory
    it("lurek.agent.newAgentMemory creates a bundled memory handle", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 12 })
        expect_not_nil(memory)
        expect_type("function", memory.working)
    end)
    -- @covers LAgentMemory:working
    it("LAgentMemory exposes working, episodic, and semantic components", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 6 })
        local working = memory:working()
        local episodic = memory:episodic()
        local semantic = memory:semantic()
        expect_equal(6, working:capacity())
        expect_type("function", episodic.record)
        expect_type("function", semantic.learn)
    end)
    -- @covers LAgentMemory:episodic
    it("LAgentMemory:episodic returns an episodic memory handle", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 6 })
        local episodic = memory:episodic()
        expect_type("function", episodic.record)
        expect_equal(0, episodic:len())
    end)
    -- @covers LAgentMemory:semantic
    it("LAgentMemory:semantic returns a semantic memory handle", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 6 })
        local semantic = memory:semantic()
        expect_type("function", semantic.learn)
        expect_equal(0, semantic:len())
    end)
    -- @covers LAgentMemory:save
    it("LAgentMemory saves and loads from disk when persist_path is configured", function()
        local memory = lurek.agent.newAgentMemory({ persist_path = AGENT_MEMORY_PATH })
        expect_true(memory:save())
        expect_true(memory:load())
    end)
    -- @covers LAgentMemory:load
    it("LAgentMemory:load restores a persisted bundle", function()
        local memory = lurek.agent.newAgentMemory({ persist_path = AGENT_MEMORY_PATH })
        expect_true(memory:save())
        expect_true(memory:load())
    end)
    -- @covers LAgentMemory:getDiagnostics
    it("LAgentMemory:getDiagnostics reports counts and storage policy", function()
        local memory = lurek.agent.newAgentMemory({ working_capacity = 6 })
        local diagnostics = memory:getDiagnostics()
        expect_type("table", diagnostics)
        expect_type("number", diagnostics.working_entries)
        expect_type("number", diagnostics.max_bytes)
        expect_type("string", diagnostics.sandbox_root)
    end)
    -- @covers LWorkingMemory:get
    it("LWorkingMemory:get retrieves stored values", function()
        local memory = lurek.agent.newWorkingMemory(4)
        memory:push("key1", 42)
        memory:push("key2", "value")
        expect_equal(42, memory:get("key1"))
        expect_equal("value", memory:get("key2"))
    end)
    -- @covers LWorkingMemory:len
    it("LWorkingMemory:len returns count of stored items", function()
        local memory = lurek.agent.newWorkingMemory(5)
        expect_equal(0, memory:len())
        memory:push("a", 1)
        expect_equal(1, memory:len())
        memory:push("b", 2)
        expect_equal(2, memory:len())
    end)
    -- @covers LEpisodicMemory:len
    it("LEpisodicMemory:len returns total episodes recorded", function()
        local memory = lurek.agent.newEpisodicMemory()
        expect_equal(0, memory:len())
        memory:record(1, { event = "start" })
        expect_equal(1, memory:len())
        memory:record(2, { event = "action" })
        expect_equal(2, memory:len())
    end)
    -- @covers LSemanticMemory:len
    it("LSemanticMemory:len returns count of stored facts", function()
        local memory = lurek.agent.newSemanticMemory()
        expect_equal(0, memory:len())
        memory:learn("fact1", "The sky is blue")
        expect_equal(1, memory:len())
        memory:learn("fact2", "Water is wet")
        expect_equal(2, memory:len())
    end)
end)
end
-- END test_agent_core_unit.lua
test_summary()
