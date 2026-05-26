-- Unit tests for lurek.dialog conversation AI module.

-- @describe lurek.dialog module unit tests
describe("lurek.dialog", function()
    -- @covers lurek.dialog.newAI
    it("creates DialogueAI", function()
        local ai = lurek.dialog.newAI()
        expect_true(ai ~= nil, "ai should be created")
    end)

    -- @covers DialogueAI:addTopic
    it("adds topics", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        ai:addTopic("quest", 2.0)
        expect_equal(2, ai:getTopicCount())
    end)

    -- @covers DialogueAI:addBranch
    it("adds branches to topic", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        local ok = ai:addBranch("greet", "friendly", 1.5)
        expect_true(ok, "branch add should succeed")
    end)

    -- @covers DialogueAI:addBranch
    it("fails to add branch to nonexistent topic", function()
        local ai = lurek.dialog.newAI()
        local ok = ai:addBranch("missing", "b1", 1.0)
        expect_true(not ok, "should fail for missing topic")
    end)

    -- @covers DialogueAI:selectTopic
    it("selects a topic", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        local t = ai:selectTopic()
        expect_equal("greet", t)
    end)

    -- @covers DialogueAI:selectBranch
    it("selects a branch", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        ai:addBranch("greet", "friendly", 1.0)
        local b = ai:selectBranch("greet")
        expect_equal("friendly", b)
    end)

    -- @covers DialogueAI:setFSMState
    it("FSM gate filters topics", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("town_only", 1.0, "in_town")
        ai:addTopic("anywhere", 1.0)
        ai:setFSMState("exploring")
        -- town_only should be filtered, select anywhere
        local t = ai:selectTopic()
        expect_equal("anywhere", t)
    end)

    -- @covers DialogueAI:setUtilityScore
    -- @covers DialogueAI:clearUtilityScores
    it("utility scores affect selection", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("a", 1.0, nil, nil, "score_a")
        ai:addTopic("b", 1.0, nil, nil, "score_b")
        ai:setUtilityScore("score_a", 10.0)
        ai:setUtilityScore("score_b", 1.0)
        -- "a" should have much higher weight
        local t = ai:selectTopic()
        expect_equal("a", t)
        ai:clearUtilityScores()
    end)

    -- @covers lurek.dialog.newState
    it("creates DialogueState", function()
        local state = lurek.dialog.newState()
        expect_true(state ~= nil, "state should be created")
        expect_true(not state:isActive(), "should start inactive")
    end)

    -- @covers DialogueState:start
    -- @covers DialogueState:current
    it("starts conversation at node", function()
        local state = lurek.dialog.newState()
        state:start("opening")
        expect_true(state:isActive())
        expect_equal("opening", state:current())
    end)

    -- @covers DialogueState:advance
    -- @covers DialogueState:hasVisited
    it("advances and tracks visits", function()
        local state = lurek.dialog.newState()
        state:start("n1")
        state:advance("n2")
        expect_equal("n2", state:current())
        expect_true(state:hasVisited("n1"))
        expect_true(state:hasVisited("n2"))
    end)

    -- @covers DialogueState:visitCount
    it("counts visited nodes", function()
        local state = lurek.dialog.newState()
        state:start("a")
        state:advance("b")
        state:advance("c")
        expect_equal(3, state:visitCount())
    end)

    -- @covers DialogueState:setVariable
    -- @covers DialogueState:getVariable
    it("stores and retrieves variables", function()
        local state = lurek.dialog.newState()
        state:setVariable("mood", "happy")
        expect_equal("happy", state:getVariable("mood"))
    end)

    -- @covers DialogueState:reset
    it("reset clears all state", function()
        local state = lurek.dialog.newState()
        state:start("x")
        state:setVariable("k", "v")
        state:reset()
        expect_true(not state:isActive())
        expect_equal(0, state:visitCount())
    end)

    -- @covers lurek.dialog.newSpeakerRegistry
    it("creates SpeakerRegistry", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        expect_true(reg ~= nil)
        expect_equal(0, reg:count())
    end)

    -- @covers SpeakerRegistry:add
    -- @covers SpeakerRegistry:get
    it("registers and retrieves speakers", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        reg:add("npc1", "Guard", "guard.png", "voice_1")
        expect_equal(1, reg:count())
        local s = reg:get("npc1")
        expect_equal("Guard", s.name)
        expect_equal("guard.png", s.portrait)
    end)

    -- @covers SpeakerRegistry:contains
    -- @covers SpeakerRegistry:remove
    it("checks and removes speakers", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        reg:add("npc1", "Guard")
        expect_true(reg:contains("npc1"))
        local removed = reg:remove("npc1")
        expect_true(removed)
        expect_true(not reg:contains("npc1"))
    end)
end)


test_summary()
