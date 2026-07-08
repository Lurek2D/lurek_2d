-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_dialog_core_unit.lua
do
-- Unit tests for lurek.dialog conversation AI module.

local function new_ai()
    return lurek.dialog.newAI()
end

local function new_state()
    return lurek.dialog.newState()
end

local function new_registry()
    return lurek.dialog.newSpeakerRegistry()
end

local function new_sequencer()
    return lurek.dialog.newSequencer()
end

-- @describe lurek.dialog module unit tests
describe("lurek.dialog", function()
    -- @covers lurek.dialog.newAI
    it("creates a dialogue AI handle", function()
        local ai = new_ai()
        expect_not_nil(ai)
    end)

    -- @covers lurek.dialog.newState
    it("creates a dialogue state handle", function()
        local state = new_state()
        expect_not_nil(state)
        expect_false(state:isActive())
    end)

    -- @covers lurek.dialog.newSpeakerRegistry
    it("creates a speaker registry handle", function()
        local registry = new_registry()
        expect_not_nil(registry)
        expect_equal(0, registry:count())
    end)

    -- @covers lurek.dialog.newSequencer
    it("creates a dialog sequencer handle", function()
        local seq = new_sequencer()
        expect_not_nil(seq)
        expect_equal("idle", seq:getState())
    end)

    -- @covers lurek.dialog.say
    it("builds say nodes with actor and text", function()
        local node = lurek.dialog.say("npc", "Hello there.", {
            duration = 0.25,
            id = "npc.hello",
            voice = "npc_voice_1",
            route = "intro",
            tags = { "intro", "npc" },
        })
        expect_type("table", node)
        expect_equal("say", node.type)
        expect_equal("npc", node.actor)
        expect_equal("Hello there.", node.text)
        expect_equal(0.25, node.duration)
        expect_equal("npc.hello", node.id)
        expect_equal("npc_voice_1", node.voice)
        expect_equal("intro", node.route)
        expect_equal("intro", node.tags[1])
        expect_equal("npc", node.tags[2])
    end)

    -- @covers lurek.dialog.choice
    it("builds choice nodes with prompt and options", function()
        local node = lurek.dialog.choice("Pick one:", {"A", "B"})
        expect_equal("choice", node.type)
        expect_equal("Pick one:", node.prompt)
        expect_equal(2, #node.options)
        expect_equal("A", node.options[1])
        expect_equal("B", node.options[2])
    end)

    -- @covers lurek.dialog.wait
    it("builds wait nodes with seconds", function()
        local node = lurek.dialog.wait(2.5)
        expect_equal("wait", node.type)
        expect_equal(2.5, node.seconds)
    end)

    -- @covers lurek.dialog.event
    it("builds event nodes with name and payload", function()
        local node = lurek.dialog.event("combat_start", "goblin")
        expect_equal("event", node.type)
        expect_equal("combat_start", node.name)
        expect_equal("goblin", node.data)
    end)

    -- @covers lurek.dialog.call
    it("builds call nodes with callback name", function()
        local node = lurek.dialog.call("on_dialog_end")
        expect_equal("call", node.type)
        expect_equal("on_dialog_end", node.name)
    end)

    -- @covers lurek.dialog.jump
    it("builds jump nodes with target label", function()
        local node = lurek.dialog.jump("ending_a")
        expect_equal("jump", node.type)
        expect_equal("ending_a", node.target)
    end)

    -- @covers lurek.dialog.label
    it("builds label nodes with name", function()
        local node = lurek.dialog.label("ending_a")
        expect_equal("label", node.type)
        expect_equal("ending_a", node.name)
    end)

    -- @covers LDialogueAI:type
    it("returns the dialogue AI type name", function()
        local ai = new_ai()
        expect_equal("LDialogueAI", ai:type())
    end)

    -- @covers LDialogueAI:addTopic
    it("adds topics", function()
        local ai = new_ai()
        ai:addTopic("greet", 1.0)
        ai:addTopic("quest", 2.0)
        expect_equal(2, ai:getTopicCount())
    end)

    -- @covers LDialogueAI:addBranch
    it("adds branches to an existing topic and rejects missing topics", function()
        local ai = new_ai()
        ai:addTopic("greet", 1.0)
        local added = ai:addBranch("greet", "friendly", 1.5)
        local missing = ai:addBranch("missing", "b1", 1.0)
        expect_true(added)
        expect_false(missing)
    end)

    -- @covers LDialogueAI:selectTopic
    it("selects the highest utility topic", function()
        local ai = new_ai()
        ai:addTopic("rumors", 0.7)
        ai:addTopic("trade", 1.0, nil, nil, "trade_score")
        ai:setUtilityScore("trade_score", 2.5)
        expect_equal("trade", ai:selectTopic())
    end)

    -- @covers LDialogueAI:selectBranch
    it("selects a branch from the requested topic", function()
        local ai = new_ai()
        ai:addTopic("friendly", 1.0)
        ai:addBranch("friendly", "weather_smalltalk", 1.0)
        ai:addBranch("friendly", "quest_hint", 0.5)
        expect_equal("weather_smalltalk", ai:selectBranch("friendly"))
    end)

    -- @covers LDialogueAI:setFSMState
    it("filters topics by FSM state", function()
        local ai = new_ai()
        ai:addTopic("town_only", 1.0, "in_town")
        ai:addTopic("anywhere", 1.0)
        ai:setFSMState("exploring")
        expect_equal("anywhere", ai:selectTopic())
    end)

    -- @covers LDialogueAI:setBTStatus
    it("filters topics by behavior tree status", function()
        local ai = new_ai()
        ai:addTopic("combat_bark", 1.0, nil, "running")
        ai:addTopic("fallback", 0.5)
        ai:setBTStatus("running")
        expect_equal("combat_bark", ai:selectTopic())
    end)

    -- @covers LDialogueAI:setUtilityScore
    it("uses utility scores to influence selection", function()
        local ai = new_ai()
        ai:addTopic("a", 1.0, nil, nil, "score_a")
        ai:addTopic("b", 1.0, nil, nil, "score_b")
        ai:setUtilityScore("score_a", 10.0)
        ai:setUtilityScore("score_b", 1.0)
        expect_equal("a", ai:selectTopic())
    end)

    -- @covers LDialogueAI:clearUtilityScores
    it("clears stored utility bias without breaking selection", function()
        local ai = new_ai()
        ai:addTopic("a", 1.0, nil, nil, "score_a")
        ai:addTopic("b", 1.0, nil, nil, "score_b")
        ai:setUtilityScore("score_a", 10.0)
        ai:clearUtilityScores()
        local topic = ai:selectTopic()
        expect_true(topic == "a" or topic == "b")
    end)

    -- @covers LDialogueAI:getTopicCount
    it("reports the number of registered topics", function()
        local ai = new_ai()
        ai:addTopic("weather", 0.5)
        ai:addTopic("quest", 0.8)
        expect_equal(2, ai:getTopicCount())
    end)

    -- @covers LDialogueAI:typeOf
    it("recognizes dialogue AI type and base object type", function()
        local ai = new_ai()
        expect_true(ai:typeOf("LDialogueAI"))
        expect_true(ai:typeOf("LObject"))
        expect_false(ai:typeOf("LDialogSequencer"))
    end)

    -- @covers LDialogueState:isActive
    it("starts inactive", function()
        local state = new_state()
        expect_false(state:isActive())
    end)

    -- @covers LDialogueState:start
    it("starts a conversation at a node", function()
        local state = new_state()
        state:start("opening")
        expect_true(state:isActive())
    end)

    -- @covers LDialogueState:end_
    it("ends an active conversation", function()
        local state = new_state()
        state:start("farewell")
        state:end_()
        expect_false(state:isActive())
    end)

    -- @covers LDialogueState:current
    it("returns the current node id", function()
        local state = new_state()
        state:start("opening")
        expect_equal("opening", state:current())
    end)

    -- @covers LDialogueState:advance
    it("advances to the next node", function()
        local state = new_state()
        state:start("n1")
        state:advance("n2")
        expect_equal("n2", state:current())
    end)

    -- @covers LDialogueState:hasVisited
    it("tracks visited nodes", function()
        local state = new_state()
        state:start("n1")
        state:advance("n2")
        expect_true(state:hasVisited("n1"))
        expect_true(state:hasVisited("n2"))
    end)

    -- @covers LDialogueState:visitCount
    it("counts visited nodes", function()
        local state = new_state()
        state:start("a")
        state:advance("b")
        state:advance("c")
        expect_equal(3, state:visitCount())
    end)

    -- @covers LDialogueState:setVariable
    it("stores dialogue variables", function()
        local state = new_state()
        state:setVariable("mood", "happy")
        expect_equal("happy", state:getVariable("mood"))
    end)

    -- @covers LDialogueState:getVariable
    it("retrieves dialogue variables", function()
        local state = new_state()
        state:setVariable("coins", "50")
        expect_equal("50", state:getVariable("coins"))
    end)

    -- @covers LDialogueState:reset
    it("clears state history and variables", function()
        local state = new_state()
        state:start("x")
        state:setVariable("k", "v")
        state:reset()
        expect_false(state:isActive())
        expect_equal(0, state:visitCount())
        expect_nil(state:getVariable("k"))
    end)

    -- @covers LDialogueState:type
    it("returns the dialogue state type name", function()
        local state = new_state()
        expect_equal("LDialogueState", state:type())
    end)

    -- @covers LDialogueState:typeOf
    it("recognizes dialogue state and base object types", function()
        local state = new_state()
        expect_true(state:typeOf("LDialogueState"))
        expect_true(state:typeOf("LObject"))
        expect_false(state:typeOf("LSpeakerRegistry"))
    end)

    -- @covers LSpeakerRegistry:count
    it("starts empty", function()
        local registry = new_registry()
        expect_equal(0, registry:count())
    end)

    -- @covers LSpeakerRegistry:add
    it("registers speakers", function()
        local registry = new_registry()
        registry:add("npc1", "Guard", "guard.png", "voice_1", { tags = { "town", "merchant" } })
        expect_equal(1, registry:count())
    end)

    -- @covers LSpeakerRegistry:get
    it("retrieves speakers by id", function()
        local registry = new_registry()
        registry:add("npc1", "Guard", "guard.png", "voice_1", { tags = { "town", "merchant" } })
        local speaker = registry:get("npc1")
        expect_equal("Guard", speaker.name)
        expect_equal("guard.png", speaker.portrait)
        expect_equal("merchant", speaker.tags[2])
    end)

    -- @covers LSpeakerRegistry:contains
    it("checks speaker membership", function()
        local registry = new_registry()
        registry:add("merchant", "Henri")
        expect_true(registry:contains("merchant"))
    end)

    -- @covers LSpeakerRegistry:remove
    it("removes speakers by id", function()
        local registry = new_registry()
        registry:add("npc1", "Guard")
        expect_true(registry:remove("npc1"))
        expect_false(registry:contains("npc1"))
    end)

    -- @covers LSpeakerRegistry:type
    it("returns the speaker registry type name", function()
        local registry = new_registry()
        expect_equal("LSpeakerRegistry", registry:type())
    end)

    -- @covers LSpeakerRegistry:typeOf
    it("recognizes speaker registry and base object types", function()
        local registry = new_registry()
        expect_true(registry:typeOf("LSpeakerRegistry"))
        expect_true(registry:typeOf("LObject"))
        expect_false(registry:typeOf("LDialogueAI"))
    end)

    -- @covers LDialogSequencer:load
    it("loads nodes for playback", function()
        local seq = new_sequencer()
        seq:load({
            lurek.dialog.say("Hero", "Hello!"),
        })
        seq:start()
        expect_equal("Hero", seq:currentSpeaker())
        expect_equal("Hello!", seq:currentText())
    end)

    -- @covers LDialogSequencer:start
    it("starts playback and enters typing state", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "Beginning...") })
        seq:start()
        expect_equal("typing", seq:getState())
    end)

    -- @covers LDialogSequencer:update
    it("reveals text over time", function()
        local seq = new_sequencer()
        seq:setSpeed(10.0)
        seq:load({
            lurek.dialog.say("Hero", "Hello", { duration = 0.2 }),
            lurek.dialog.wait(0.3),
            lurek.dialog.say("Hero", "After wait"),
        })
        seq:start()
        seq:update(0.1)
        expect_equal(1, string.len(seq:revealedText()))
        seq:update(0.1)
        expect_equal(2, string.len(seq:revealedText()))
        seq:skip()
        expect_equal("waiting", seq:getState())
        seq:update(0.19)
        expect_equal("Hello", seq:currentText())
        seq:update(0.02)
        expect_equal("waiting", seq:getState())
        expect_equal("", seq:currentText())
        seq:update(0.29)
        expect_equal("waiting", seq:getState())
        seq:update(0.02)
        expect_equal("After wait", seq:currentText())
    end)

    -- @covers LDialogSequencer:advance
    it("advances from waiting to the next node", function()
        local seq = new_sequencer()
        seq:setSpeed(1.0)
        seq:load({
            lurek.dialog.say("Hero", "Long sentence."),
            lurek.dialog.say("Hero", "Next line."),
        })
        seq:start()
        seq:advance()
        expect_equal("waiting", seq:getState())
        seq:advance()
        expect_equal("Next line.", seq:currentText())
    end)

    -- @covers LDialogSequencer:skip
    it("instantly reveals the current line", function()
        local seq = new_sequencer()
        seq:setSpeed(1.0)
        seq:load({ lurek.dialog.say("Hero", "Full text") })
        seq:start()
        seq:skip()
        expect_equal("Full text", seq:revealedText())
        expect_equal("Full text", seq:currentText())
    end)

    -- @covers LDialogSequencer:choose
    it("selects a choice and continues playback", function()
        local seq = new_sequencer()
        seq:load({
            lurek.dialog.choice("Pick:", {"A", "B"}),
            lurek.dialog.say("Hero", "You chose B!"),
        })
        seq:start()
        seq:choose(2)
        expect_equal("typing", seq:getState())
        expect_equal("You chose B!", seq:currentText())
    end)

    -- @covers LDialogSequencer:setSpeed
    it("changes text reveal speed", function()
        local seq = new_sequencer()
        seq:setSpeed(20.0)
        seq:load({ lurek.dialog.say("Hero", "Hello world") })
        seq:start()
        seq:update(0.1)
        expect_true(string.len(seq:revealedText()) >= 2)
    end)

    -- @covers LDialogSequencer:getSpeed
    it("returns the configured reveal speed", function()
        local seq = new_sequencer()
        seq:setSpeed(25.0)
        expect_equal(25.0, seq:getSpeed())
    end)

    -- @covers LDialogSequencer:getState
    it("reports idle state before playback starts", function()
        local seq = new_sequencer()
        expect_equal("idle", seq:getState())
    end)

    -- @covers LDialogSequencer:isActive
    it("tracks whether playback is active", function()
        local seq = new_sequencer()
        expect_false(seq:isActive())
        seq:load({ lurek.dialog.say("NPC", "Started") })
        seq:start()
        expect_true(seq:isActive())
    end)

    -- @covers LDialogSequencer:isWaitingForChoice
    it("reports when the sequencer is waiting for a choice", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.choice("Pick:", {"Yes", "No"}) })
        seq:start()
        expect_true(seq:isWaitingForChoice())
    end)

    -- @covers LDialogSequencer:currentSpeaker
    it("returns the current actor name", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("Warrior", "At last!") })
        seq:start()
        expect_equal("Warrior", seq:currentSpeaker())
    end)

    -- @covers LDialogSequencer:currentText
    it("returns the full current line", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "The full line here") })
        seq:start()
        expect_equal("The full line here", seq:currentText())
    end)

    -- @covers LDialogSequencer:currentId
    it("returns the current line id", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "Tagged", { id = "line.tagged" }) })
        seq:start()
        expect_equal("line.tagged", seq:currentId())
    end)

    -- @covers LDialogSequencer:currentVoice
    it("returns the current voice id", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "Tagged", { voice = "voice_1" }) })
        seq:start()
        expect_equal("voice_1", seq:currentVoice())
    end)

    -- @covers LDialogSequencer:currentRoute
    it("returns the current route marker", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "Tagged", { route = "branch_a" }) })
        seq:start()
        expect_equal("branch_a", seq:currentRoute())
    end)

    -- @covers LDialogSequencer:currentTags
    it("returns current line tags", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "Tagged", { tags = { "quest", "optional" } }) })
        seq:start()
        local tags = seq:currentTags()
        expect_equal(2, #tags)
        expect_equal("quest", tags[1])
        expect_equal("optional", tags[2])
    end)

    -- @covers LDialogSequencer:revealedText
    it("returns the partially revealed text", function()
        local seq = new_sequencer()
        seq:setSpeed(5.0)
        seq:load({ lurek.dialog.say("NPC", "Slowly revealed") })
        seq:start()
        seq:update(0.2)
        expect_equal("S", seq:revealedText())
    end)

    -- @covers LDialogSequencer:getChoiceText
    it("returns the active choice prompt", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.choice("Your move?", {"Attack", "Defend"}) })
        seq:start()
        expect_equal("Your move?", seq:getChoiceText())
    end)

    -- @covers LDialogSequencer:getChoiceLabels
    it("returns active choice labels", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.choice("Pick:", {"Option A", "Option B", "Option C"}) })
        seq:start()
        local labels = seq:getChoiceLabels()
        expect_equal(3, #labels)
        expect_equal("Option A", labels[1])
        expect_equal("Option B", labels[2])
        expect_equal("Option C", labels[3])
    end)

    -- @covers LDialogSequencer:getHistory
    it("stores spoken lines in history", function()
        local seq = new_sequencer()
        seq:setSpeed(100.0)
        seq:load({
            lurek.dialog.say("NPC", "First", { id = "line.one" }),
            lurek.dialog.say("NPC", "Second"),
        })
        seq:start()
        local history = seq:getHistory()
        expect_equal(1, #history)
        expect_equal("line.one", history[1].id)
        expect_equal("First", history[1].text)
    end)

    -- @covers LDialogSequencer:clearHistory
    it("clears spoken line history", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "First") })
        seq:start()
        expect_equal(1, #seq:getHistory())
        seq:clearHistory()
        expect_equal(0, #seq:getHistory())
    end)

    -- @covers LDialogSequencer:peekSignal
    it("peeks pending event signals without removing them", function()
        local seq = new_sequencer()
        seq:load({
            lurek.dialog.event("door_open", "north"),
            lurek.dialog.say("NPC", "Opened"),
        })
        seq:start()
        local signal = seq:peekSignal()
        expect_equal("event", signal.kind)
        expect_equal("door_open", signal.name)
        expect_equal("north", signal.data)
        expect_not_nil(seq:peekSignal())
    end)

    -- @covers LDialogSequencer:popSignal
    it("pops pending signals in order", function()
        local seq = new_sequencer()
        seq:load({
            lurek.dialog.call("onReward"),
            lurek.dialog.event("reward_done", "ok"),
            lurek.dialog.say("NPC", "Done"),
        })
        seq:start()
        local first = seq:popSignal()
        local second = seq:popSignal()
        expect_equal("call", first.kind)
        expect_equal("onReward", first.name)
        expect_equal("event", second.kind)
        expect_equal("reward_done", second.name)
        expect_nil(seq:popSignal())
    end)

    -- @covers LDialogSequencer:snapshot
    it("captures runtime progress, history, and pending signals", function()
        local seq = new_sequencer()
        seq:load({
            lurek.dialog.say("NPC", "Snapshot line", { id = "snapshot.line" }),
            lurek.dialog.event("snapshot_event", "ok"),
        })
        seq:start()
        seq:update(0.2)
        local snapshot = seq:snapshot()
        expect_equal("typing", snapshot.state)
        expect_equal(2, #snapshot.nodes)
        expect_equal("snapshot.line", snapshot.history[1].id)
        expect_equal("NPC", snapshot.currentSpeaker)
    end)

    -- @covers LDialogSequencer:restore
    it("restores runtime progress from a snapshot", function()
        local seq = new_sequencer()
        seq:load({ lurek.dialog.say("NPC", "Restore line", { id = "restore.line" }) })
        seq:start()
        local snapshot = seq:snapshot()
        seq:load({ lurek.dialog.say("NPC", "Other line") })
        seq:start()
        seq:restore(snapshot)
        expect_equal("Restore line", seq:currentText())
        expect_equal("restore.line", seq:currentId())
    end)

    -- @covers LDialogSequencer:type
    it("returns the dialog sequencer type name", function()
        local seq = new_sequencer()
        expect_equal("LDialogSequencer", seq:type())
    end)

    -- @covers LDialogSequencer:typeOf
    it("recognizes dialog sequencer and base object types", function()
        local seq = new_sequencer()
        expect_true(seq:typeOf("LDialogSequencer"))
        expect_true(seq:typeOf("LObject"))
        expect_false(seq:typeOf("LDialogueAI"))
    end)
end)

-- @describe dialog story compiler
describe("dialog story compiler", function()
    local function branch_story()
        return lurek.dialog.compileStory([[
            VAR hero = "Ada"
            === START ===
            Hello, {hero}. #greeting
            * Continue | -> NEXT
            === NEXT ===
            Done.
            -> END
        ]])
    end

    local function variable_story()
        return lurek.dialog.compileStory([[
            === START ===
            {flag}
        ]])
    end

    local function multi_line_story()
        return lurek.dialog.compileStory([[
            === START ===
            One.
            Two.
            === LATER ===
            Later.
        ]])
    end

    -- @covers lurek.dialog.compileStory
    it("compiles safe Ink-subset stories", function()
        local story = branch_story()
        expect_equal("LDialogStory", story:type())
    end)

    -- @covers LDialogStory:start
    it("starts compiled stories", function()
        local story = branch_story()
        story:start()
        expect_true(story:canContinue())
    end)

    -- @covers LDialogStory:canContinue
    it("reports whether compiled stories can continue", function()
        local story = branch_story()
        story:start()
        expect_true(story:canContinue())
    end)

    -- @covers LDialogStory:continue
    it("continues compiled stories one line at a time", function()
        local story = branch_story()
        story:start()
        local line, tags = story:continue()
        expect_equal("Hello, Ada.", line)
        expect_equal("greeting", tags[1])
    end)

    -- @covers LDialogStory:getChoices
    it("returns visible compiled story choices", function()
        local story = branch_story()
        story:start()
        story:continue()
        local choices = story:getChoices()
        expect_equal(1, #choices)
        expect_equal("Continue", choices[1].text)
    end)

    -- @covers LDialogStory:choose
    it("selects compiled story choices", function()
        local story = branch_story()
        story:start()
        story:continue()
        story:choose(1)
        expect_equal("Done.", story:continue())
    end)

    -- @covers LDialogStory:setVariable
    it("stores compiled story variables", function()
        local story = variable_story()
        story:setVariable("flag", "before")
        expect_equal("before", story:getVariable("flag"))
    end)

    -- @covers LDialogStory:getVariable
    it("retrieves compiled story variables", function()
        local story = variable_story()
        story:setVariable("flag", "before")
        expect_equal("before", story:getVariable("flag"))
    end)

    -- @covers LDialogStory:listVariables
    it("lists compiled story variables", function()
        local story = variable_story()
        story:setVariable("flag", "before")
        expect_true(#story:listVariables() >= 1)
    end)

    -- @covers LDialogStory:visitCount
    it("tracks compiled story visits", function()
        local story = variable_story()
        story:start()
        expect_equal(1, story:visitCount("START"))
    end)

    -- @covers LDialogStory:snapshot
    it("captures compiled story snapshots", function()
        local story = variable_story()
        story:setVariable("flag", "before")
        story:start()
        expect_type("table", story:snapshot())
    end)

    -- @covers LDialogStory:restore
    it("restores compiled story snapshots", function()
        local story = variable_story()
        story:setVariable("flag", "before")
        story:start()
        local snapshot = story:snapshot()
        story:setVariable("flag", "after")
        story:restore(snapshot)
        expect_equal("before", story:getVariable("flag"))
    end)

    -- @covers LDialogStory:continueAll
    it("drains compiled story lines", function()
        local story = multi_line_story()
        story:start()
        expect_equal("One.\nTwo.", story:continueAll())
    end)

    -- @covers LDialogStory:gotoKnot
    it("jumps compiled stories to knots", function()
        local story = multi_line_story()
        story:start()
        story:gotoKnot("LATER")
        expect_equal("Later.", story:continueAll())
    end)

    -- @covers LDialogStory:type
    it("returns compiled story type names", function()
        local story = multi_line_story()
        expect_equal("LDialogStory", story:type())
    end)

    -- @covers LDialogStory:typeOf
    it("recognizes compiled story types", function()
        local story = multi_line_story()
        expect_true(story:typeOf("LDialogStory"))
        expect_true(story:typeOf("LObject"))
        expect_false(story:typeOf("LDialogSequencer"))
    end)
end)
end
-- END test_dialog_core_unit.lua

test_summary()
