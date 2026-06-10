-- tests/lua/unit/test_dialog_sequencer_unit.lua
-- @describe Dialog Sequencer
local it = IT
local expect_equal = EXPECT_EQUAL
local expect_true = EXPECT_TRUE
local expect_false = EXPECT_FALSE

local function test_sequencer_creation()
  -- @covers lurek.dialog.newSequencer
  it("creates a new sequencer", function()
    local seq = lurek.dialog.newSequencer()
    expect_true(seq:typeOf("LDialogSequencer"))
  end)

  -- @covers LDialogSequencer:getState
  it("has idle state on creation", function()
    local seq = lurek.dialog.newSequencer()
    expect_equal(seq:getState(), "idle")
  end)

  -- @covers LDialogSequencer:isActive
  it("is not active on creation", function()
    local seq = lurek.dialog.newSequencer()
    expect_false(seq:isActive())
  end)

  -- @covers LDialogSequencer:type
  it("returns the sequencer type name", function()
    local seq = lurek.dialog.newSequencer()
    expect_equal(seq:type(), "LDialogSequencer")
  end)

  -- @covers LDialogSequencer:typeOf
  it("recognizes the sequencer type", function()
    local seq = lurek.dialog.newSequencer()
    expect_true(seq:typeOf("LDialogSequencer"))
    expect_true(seq:typeOf("Object"))
  end)
end

local function test_say_nodes()
  -- @covers lurek.dialog.say
  it("creates a say node with optional duration", function()
    local node = lurek.dialog.say("Hero", "Hello!", { duration = 2.0 })
    expect_equal(node.type, "say")
    expect_equal(node.actor, "Hero")
    expect_equal(node.text, "Hello!")
    expect_equal(node.duration, 2.0)
  end)

  -- @covers LDialogSequencer:load
  it("loads a single say node", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.say("Hero", "Hello!")
    })
    seq:start()
    expect_equal(seq:currentSpeaker(), "Hero")
    expect_equal(seq:currentText(), "Hello!")
  end)

  -- @covers LDialogSequencer:update
  it("typewriter reveals text over time", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0)
    seq:load({
      lurek.dialog.say("Hero", "Hello world!")
    })
    seq:start()
    seq:update(0.1)
    expect_equal(string.len(seq:revealedText()), 1)
    seq:update(0.1)
    expect_equal(string.len(seq:revealedText()), 2)
  end)

  -- @covers LDialogSequencer:start
  it("starts playback and reaches waiting state after typing completes", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(100.0)
    seq:load({
      lurek.dialog.say("Hero", "Hi")
    })
    seq:start()
    seq:update(1.0)
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

  -- @covers LDialogSequencer:choose
  it("can select a choice option", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("Pick:", {"A", "B"}),
      lurek.dialog.say("Hero", "You chose B!")
    })
    seq:start()
    seq:choose(2)
    expect_equal(seq:getState(), "typing")
    expect_equal(seq:currentText(), "You chose B!")
  end)

  -- @covers LDialogSequencer:getChoiceLabels
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

  -- @covers LDialogSequencer:getChoiceText
  it("getChoiceText returns prompt", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.choice("What now?", {"Yes", "No"})
    })
    seq:start()
    expect_equal(seq:getChoiceText(), "What now?")
  end)

  -- @covers LDialogSequencer:isWaitingForChoice
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
  -- @covers LDialogSequencer:advance
  it("advance skips typing and moves to the next node", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({
      lurek.dialog.say("Hero", "Long sentence."),
      lurek.dialog.say("Hero", "Next line.")
    })
    seq:start()
    expect_equal(seq:getState(), "typing")
    seq:advance()
    expect_equal(seq:getState(), "waiting")
    seq:advance()
    expect_equal(seq:currentSpeaker(), "Hero")
    expect_equal(seq:currentText(), "Next line.")
  end)

  -- @covers LDialogSequencer:skip
  it("skip instantly reveals text", function()
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
  -- @covers LDialogSequencer:setSpeed
  it("setSpeed changes reveal speed", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(20.0)
    seq:load({
      lurek.dialog.say("Hero", "Hello world")
    })
    seq:start()
    seq:update(0.1)
    expect_true(string.len(seq:revealedText()) >= 2)
  end)

  -- @covers LDialogSequencer:getSpeed
  it("getSpeed returns the configured reveal speed", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(20.0)
    expect_equal(seq:getSpeed(), 20.0)
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

local function test_speaker_and_text_queries()
  -- @covers LDialogSequencer:currentSpeaker
  it("currentSpeaker returns actor name", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.say("Villain", "Mwahahaha!")
    })
    seq:start()
    expect_equal(seq:currentSpeaker(), "Villain")
  end)

  -- @covers LDialogSequencer:currentText
  it("currentText returns full line", function()
    local seq = lurek.dialog.newSequencer()
    seq:load({
      lurek.dialog.say("Hero", "The complete sentence")
    })
    seq:start()
    expect_equal(seq:currentText(), "The complete sentence")
  end)

  -- @covers LDialogSequencer:revealedText
  it("revealedText reflects typewriter progress", function()
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0)
    seq:load({
      lurek.dialog.say("Hero", "Test")
    })
    seq:start()
    seq:update(0.2)
    expect_equal(seq:revealedText(), "Te")
  end)
end

test_sequencer_creation()
test_say_nodes()
test_choice_nodes()
test_advance_and_skip()
test_speed_control()
test_node_helpers()
test_speaker_and_text_queries()
test_summary()
