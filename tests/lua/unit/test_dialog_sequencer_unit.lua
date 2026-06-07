-- tests/lua/unit/test_dialog_sequencer_unit.lua
-- @describe Dialog Sequencer

local it = IT
local expect_equal = EXPECT_EQUAL
local expect_true = EXPECT_TRUE
local expect_false = EXPECT_FALSE
local assert_error = ASSERT_ERROR

local function test_sequencer_creation()
  -- @covers lurek.dialog.newSequencer
  it("creates a new sequencer", function()
    local seq = lurek.dialog.newSequencer()
    expect_true(seq:typeOf("LDialogSequencer"))
  end)

  -- @covers lurek.dialog.newSequencer
  it("has idle state on creation", function()
    local seq = lurek.dialog.newSequencer()
    expect_equal(seq:getState(), "idle")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.newSequencer
  it("is not active on creation", function()
    local seq = lurek.dialog.newSequencer()
    expect_false(seq:isActive())
  end)
end

local function test_say_nodes()
  -- @covers lurek.dialog.say
  it("creates a say node", function()
    local node = lurek.dialog.say("Hero", "Hello!")
    expect_equal(node.type, "say")
    expect_equal(node.actor, "Hero")
    expect_equal(node.text, "Hello!")
  end)

  -- @covers lurek.dialog.say
  it("say node accepts optional duration", function()
    local node = lurek.dialog.say("Hero", "Hello!", { duration = 2.0 })
    expect_equal(node.duration, 2.0)
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.say
  it("loads a single say node", function()
    local seq = lurek.dialog.newSequencer()
    local nodes = {
      lurek.dialog.say("Hero", "Hello!")
    }
    seq:load(nodes)
    seq:start()
    expect_equal(seq:getState(), "typing")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.say
  it("typewriter reveals text over time", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0) -- 10 chars/sec
    seq:load({
      lurek.dialog.say("Hero", "Hello world!")
    })
    seq:start()
    seq:update(0.1) -- 1 character
    expect_equal(string.len(seq:revealedText()), 1)
    seq:update(0.1) -- 1 more character
    expect_equal(string.len(seq:revealedText()), 2)
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.say
  it("transition to waiting when typing complete", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(100.0) -- very fast
    seq:load({
      lurek.dialog.say("Hero", "Hi")
    })
    seq:start()
    seq:update(1.0) -- plenty of time
    expect_equal(seq:getState(), "waiting")
  end)
end

local function test_choice_nodes()
  -- @covers lurek.dialog.choice
  it("creates a choice node", function()
    local node = lurek.dialog.choice("Pick one:", {"Option A", "Option B"})
    expect_equal(node.type, "choice")
    expect_equal(node.prompt, "Pick one:")
    expect_equal(#node.options, 2)
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.choice
  it("transitions to choice state when loading choice", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("Pick:", {"A", "B"})
    })
    seq:start()
    expect_equal(seq:getState(), "choice")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.choice
  it("can select a choice option", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("Pick:", {"A", "B"}),
      lurek.dialog.say("Hero", "You chose B!")
    })
    seq:start()
    seq:choose(2) -- select option 2 (1-based)
    expect_equal(seq:getState(), "typing")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.choice
  it("getChoiceLabels returns options", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("Pick:", {"Option A", "Option B", "Option C"})
    })
    seq:start()
    local labels = seq:getChoiceLabels()
    expect_equal(#labels, 3)
    expect_equal(labels[1], "Option A")
    expect_equal(labels[2], "Option B")
    expect_equal(labels[3], "Option C")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.choice
  it("getChoiceText returns prompt", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("What now?", {"Yes", "No"})
    })
    seq:start()
    expect_equal(seq:getChoiceText(), "What now?")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.choice
  it("isWaitingForChoice returns true in choice state", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("Pick:", {"A", "B"})
    })
    seq:start()
    expect_true(seq:isWaitingForChoice())
  end)
end

local function test_advance_and_skip()
  -- @covers lurek.dialog.newSequencer lurek.dialog.advance
  it("advance() skips typing to next node", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0) -- slow reveal
    seq:load({
      lurek.dialog.say("Hero", "Long sentence."),
      lurek.dialog.say("Hero", "Next line.")
    })
    seq:start()
    expect_equal(seq:getState(), "typing")
    seq:advance() -- skip typing, go to waiting
    expect_equal(seq:getState(), "waiting")
    seq:advance() -- advance to next node
    expect_equal(seq:currentSpeaker(), "Hero")
    expect_equal(seq:currentText(), "Next line.")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.say lurek.dialog.skip
  it("skip() instantly reveals text", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({
      lurek.dialog.say("Hero", "Full text")
    })
    seq:start()
    seq:skip()
    expect_equal(seq:revealedText(), "Full text")
    expect_equal(seq:currentText(), "Full text")
  end)
end

local function test_speed_control()
  -- @covers lurek.dialog.newSequencer lurek.dialog.setSpeed
  it("setSpeed changes reveal speed", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(20.0) -- 20 chars/sec
    expect_equal(seq:getSpeed(), 20.0)
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.setSpeed
  it("faster speed reveals more chars per update", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(100.0) -- very fast
    seq:load({
      lurek.dialog.say("Hero", "Hello world")
    })
    seq:start()
    seq:update(0.1)
    local fast_reveal = string.len(seq:revealedText())

    seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0) -- slower
    seq:load({
      lurek.dialog.say("Hero", "Hello world")
    })
    seq:start()
    seq:update(0.1)
    local slow_reveal = string.len(seq:revealedText())

    expect_true(fast_reveal > slow_reveal)
  end)
end

local function test_node_helpers()
  -- @covers lurek.dialog.wait
  it("creates a wait node", function()
    local node = lurek.dialog.wait(2.5)
    expect_equal(node.type, "wait")
    expect_equal(node.seconds, 2.5)
  end)

  -- @covers lurek.dialog.event
  it("creates an event node", function()
    local node = lurek.dialog.event("combat_start", "goblin")
    expect_equal(node.type, "event")
    expect_equal(node.name, "combat_start")
    expect_equal(node.data, "goblin")
  end)

  -- @covers lurek.dialog.call
  it("creates a call node", function()
    local node = lurek.dialog.call("on_dialog_end")
    expect_equal(node.type, "call")
    expect_equal(node.name, "on_dialog_end")
  end)

  -- @covers lurek.dialog.jump
  it("creates a jump node", function()
    local node = lurek.dialog.jump("ending_a")
    expect_equal(node.type, "jump")
    expect_equal(node.target, "ending_a")
  end)
end

local function test_sequence_flow()
  -- @covers lurek.dialog.newSequencer lurek.dialog.say lurek.dialog.choice
  it("flows through say -> choice -> say", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(100.0)
    seq:load({
      lurek.dialog.say("Hero", "Choose wisely."),
      lurek.dialog.choice("What do you do?", {"Fight", "Flee"}),
      lurek.dialog.say("Narrator", "You chose flee.")
    })

    seq:start()
    expect_equal(seq:getState(), "typing")

    seq:update(1.0) -- reveal complete
    expect_equal(seq:getState(), "waiting")

    seq:advance()
    expect_equal(seq:getState(), "choice")

    seq:choose(1)
    expect_equal(seq:getState(), "typing")
    expect_equal(seq:currentText(), "You chose flee.")
  end)
end

local function test_speaker_and_text_queries()
  -- @covers lurek.dialog.newSequencer lurek.dialog.say lurek.dialog.currentSpeaker
  it("currentSpeaker returns actor name", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.say("Villain", "Mwahahaha!")
    })
    seq:start()
    expect_equal(seq:currentSpeaker(), "Villain")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.say lurek.dialog.currentText
  it("currentText returns full line", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.say("Hero", "The complete sentence")
    })
    seq:start()
    expect_equal(seq:currentText(), "The complete sentence")
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.say lurek.dialog.revealedText
  it("revealedText reflects typewriter progress", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0) -- 10 chars/sec
    seq:load({
      lurek.dialog.say("Hero", "Test")
    })
    seq:start()
    seq:update(0.2) -- 2 chars
    expect_equal(seq:revealedText(), "Te")
  end)
end

local function test_state_tracking()
  -- @covers lurek.dialog.newSequencer lurek.dialog.isActive
  it("isActive false when idle", function()
    local seq = lurek.dialog.newSequencer()
    expect_false(seq:isActive())
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.isActive
  it("isActive true when typing", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.say("Hero", "Text")
    })
    seq:start()
    expect_true(seq:isActive())
  end)

  -- @covers lurek.dialog.newSequencer lurek.dialog.getState
  it("getState returns current state string", function()
    local seq = lurek.dialog.newSequencer()
    expect_equal(seq:getState(), "idle")
    seq:load({ lurek.dialog.say("Hero", "Hi") })
    seq:start()
    expect_true(seq:getState() == "typing" or seq:getState() == "waiting")
  end)
end

test_sequencer_creation()
test_say_nodes()
test_choice_nodes()
test_advance_and_skip()
test_speed_control()
test_node_helpers()
test_sequence_flow()
test_speaker_and_text_queries()
test_state_tracking()

test_summary()
