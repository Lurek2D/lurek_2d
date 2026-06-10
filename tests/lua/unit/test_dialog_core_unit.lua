-- Unit tests for lurek.dialog conversation AI module.

-- @describe lurek.dialog module unit tests
describe("lurek.dialog", function()
    -- @covers LDialogueAI:type
    it("creates DialogueAI", function()
        local ai = lurek.dialog.newAI()
        expect_equal("LDialogueAI", ai:type())
    end)

    -- @covers LDialogueAI:addTopic
    it("adds topics", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        ai:addTopic("quest", 2.0)
        expect_equal(2, ai:getTopicCount())
    end)

    -- @covers LDialogueAI:addBranch
    it("adds branches to an existing topic and rejects missing topics", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        local added = ai:addBranch("greet", "friendly", 1.5)
        local missing = ai:addBranch("missing", "b1", 1.0)
        expect_true(added, "branch add should succeed")
        expect_false(missing, "should fail for missing topic")
    end)

    -- @covers LDialogueAI:selectTopic
    it("selects a topic", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        local t = ai:selectTopic()
        expect_equal("greet", t)
    end)

    -- @covers LDialogueAI:selectBranch
    it("selects a branch", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("greet", 1.0)
        ai:addBranch("greet", "friendly", 1.0)
        local b = ai:selectBranch("greet")
        expect_equal("friendly", b)
    end)

    -- @covers LDialogueAI:setFSMState
    it("FSM gate filters topics", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("town_only", 1.0, "in_town")
        ai:addTopic("anywhere", 1.0)
        ai:setFSMState("exploring")
        -- town_only should be filtered, select anywhere
        local t = ai:selectTopic()
        expect_equal("anywhere", t)
    end)

    -- @covers LDialogueAI:setUtilityScore
    it("utility scores affect selection", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("a", 1.0, nil, nil, "score_a")
        ai:addTopic("b", 1.0, nil, nil, "score_b")
        ai:setUtilityScore("score_a", 10.0)
        ai:setUtilityScore("score_b", 1.0)
        local t = ai:selectTopic()
        expect_equal("a", t)
    end)

    -- @covers LDialogueAI:clearUtilityScores
    it("clearUtilityScores removes stored score bias without breaking selection", function()
        local ai = lurek.dialog.newAI()
        ai:addTopic("a", 1.0, nil, nil, "score_a")
        ai:addTopic("b", 1.0, nil, nil, "score_b")
        ai:setUtilityScore("score_a", 10.0)
        ai:clearUtilityScores()
        local t = ai:selectTopic()
        expect_true(t == "a" or t == "b", "selection should still return a valid topic")
    end)

    -- @covers LDialogueState:isActive
    it("creates DialogueState", function()
        local state = lurek.dialog.newState()
        expect_not_nil(state, "state should be created")
        expect_false(state:isActive(), "should start inactive")
    end)

    -- @covers LDialogueState:start
    it("starts conversation at node", function()
        local state = lurek.dialog.newState()
        state:start("opening")
        expect_true(state:isActive())
    end)

    -- @covers LDialogueState:current
    it("current returns the active node", function()
        local state = lurek.dialog.newState()
        state:start("opening")
        expect_equal("opening", state:current())
    end)

    -- @covers LDialogueState:advance
    it("advance moves the current node forward", function()
        local state = lurek.dialog.newState()
        state:start("n1")
        state:advance("n2")
        expect_equal("n2", state:current())
    end)

    -- @covers LDialogueState:hasVisited
    it("hasVisited tracks visited nodes", function()
        local state = lurek.dialog.newState()
        state:start("n1")
        state:advance("n2")
        expect_true(state:hasVisited("n1"))
        expect_true(state:hasVisited("n2"))
    end)

    -- @covers LDialogueState:visitCount
    it("counts visited nodes", function()
        local state = lurek.dialog.newState()
        state:start("a")
        state:advance("b")
        state:advance("c")
        expect_equal(3, state:visitCount())
    end)

    -- @covers LDialogueState:setVariable
    it("stores variables", function()
        local state = lurek.dialog.newState()
        state:setVariable("mood", "happy")
        expect_equal("happy", state:getVariable("mood"))
    end)

    -- @covers LDialogueState:getVariable
    it("retrieves variables", function()
        local state = lurek.dialog.newState()
        state:setVariable("mood", "happy")
        expect_equal("happy", state:getVariable("mood"))
    end)

    -- @covers LDialogueState:reset
    it("reset clears all state", function()
        local state = lurek.dialog.newState()
        state:start("x")
        state:setVariable("k", "v")
        state:reset()
        expect_true(not state:isActive())
        expect_equal(0, state:visitCount())
    end)

    -- @covers LSpeakerRegistry:count
    it("creates SpeakerRegistry", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        expect_not_nil(reg)
        expect_equal(0, reg:count())
    end)

    -- @covers LSpeakerRegistry:add
    it("registers speakers", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        reg:add("npc1", "Guard", "guard.png", "voice_1")
        expect_equal(1, reg:count())
    end)

    -- @covers LSpeakerRegistry:get
    it("retrieves speakers by id", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        reg:add("npc1", "Guard", "guard.png", "voice_1")
        local s = reg:get("npc1")
        expect_equal("Guard", s.name)
        expect_equal("guard.png", s.portrait)
    end)

    -- @covers LSpeakerRegistry:contains
    it("checks speaker membership", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        reg:add("npc1", "Guard")
        expect_true(reg:contains("npc1"))
    end)

    -- @covers LSpeakerRegistry:remove
    it("removes speakers by id", function()
        local reg = lurek.dialog.newSpeakerRegistry()
        reg:add("npc1", "Guard")
        local removed = reg:remove("npc1")
        expect_true(removed)
        expect_false(reg:contains("npc1"))
    end)

    -- @covers lurek.dialog.say
    it("dialog.say displays dialog", function()
        local node = lurek.dialog.say("npc", "Hello there.")
        expect_type("table", node)
    end)
end)

test_summary()
