-- tests/lua/unit/test_cinematic_timeline_unit.lua
-- @describe Cinematic Timeline
local it = IT
local expect_equal = EXPECT_EQUAL
local expect_true = EXPECT_TRUE
local expect_false = EXPECT_FALSE

local function test_timeline_creation()
  -- @covers lurek.cinematic.newTimeline
  it("creates a new timeline", function()
    local tl = lurek.cinematic.newTimeline()
    expect_true(tl:typeOf("LCinematicTimeline"))
  end)

  -- @covers LCinematicTimeline:getState
  it("starts in stopped state", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getState(), "stopped")
  end)

  -- @covers LCinematicTimeline:getDuration
  it("has zero duration on creation", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getDuration(), 0.0)
  end)

  -- @covers LCinematicTimeline:getTime
  it("starts at time zero", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getTime(), 0.0)
  end)
end

local function test_track_management()
  -- @covers LCinematicTimeline:addTrack
  it("can add tracks", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addTrack("camera")
    tl:addTrack("audio")
    expect_equal(tl:getDuration(), 0.0)
  end)
end

local function test_clip_addition()
  -- @covers LCinematicTimeline:addClip
  it("adds different clip types and extends timeline duration", function()
    local tl = lurek.cinematic.newTimeline()

    tl:addClip("camera", 0.0, 1.0, {
      type = "camera",
      x = 100.0,
      y = 50.0,
      zoom = 2.0
    })
    expect_equal(tl:getDuration(), 1.0)

    tl:addClip("signals", 2.0, 0.1, {
      type = "signal",
      name = "combat_start",
      data = "goblin"
    })
    expect_equal(tl:getDuration(), 2.1)

    tl:addClip("sfx", 5.0, 2.0, {
      type = "audio",
      path = "sfx/explosion.wav"
    })
    expect_equal(tl:getDuration(), 7.0)

    tl:addClip("tweens", 1.0, 3.0, {
      type = "tween",
      target = "sprite1",
      properties = { x = 100.0, y = 200.0, alpha = 0.5 },
      easing = "ease_in_quad"
    })
    expect_equal(tl:getDuration(), 7.0)
  end)
end

local function test_playback_control()
  -- @covers LCinematicTimeline:play
  it("transitions to playing state", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 1.0, { type = "signal", name = "test" })
    tl:play()
    expect_equal(tl:getState(), "playing")
  end)

  -- @covers LCinematicTimeline:pause
  it("pauses playback", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 1.0, { type = "signal", name = "test" })
    tl:play()
    tl:pause()
    expect_equal(tl:getState(), "paused")
  end)

  -- @covers LCinematicTimeline:stop
  it("stops and resets to zero", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(2.0)
    tl:stop()
    expect_equal(tl:getState(), "stopped")
    expect_equal(tl:getTime(), 0.0)
  end)

  -- @covers LCinematicTimeline:isPlaying
  it("isPlaying returns correct state", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 1.0, { type = "signal", name = "test" })
    expect_false(tl:isPlaying())
    tl:play()
    expect_true(tl:isPlaying())
  end)
end

local function test_time_control()
  -- @covers LCinematicTimeline:seek
  it("seeks to specified time", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:seek(5.5)
    expect_equal(tl:getTime(), 5.5)
  end)

  -- @covers LCinematicTimeline:update
  it("advances time when playing", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(2.5)
    expect_equal(tl:getTime(), 2.5)
  end)

  -- @covers LCinematicTimeline:skipToEnd
  it("instantly jumps to end", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:skipToEnd()
    expect_equal(tl:getTime(), 10.0)
  end)

  -- @covers LCinematicTimeline:isComplete
  it("detects completion", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 3.0, { type = "signal", name = "test" })
    expect_false(tl:isComplete())
    tl:seek(5.0)
    expect_true(tl:isComplete())
  end)
end

local function test_labels_and_branching()
  -- @covers LCinematicTimeline:addLabel
  it("can add labeled positions", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addLabel("scene_start", 0.0)
    tl:addLabel("midpoint", 5.0)
    tl:addLabel("ending", 10.0)
    expect_equal(tl:getTime(), 0.0)
  end)

  -- @covers LCinematicTimeline:branch
  it("branches to known labels and rejects missing ones", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 15.0, { type = "signal", name = "test" })
    tl:addLabel("checkpoint", 7.5)
    local ok = tl:branch("checkpoint")
    expect_true(ok)
    expect_equal(tl:getTime(), 7.5)
    expect_false(tl:branch("nonexistent"))
  end)
end

local function test_cinematic_methods()
  -- @covers LCinematic:play
  it("plays a cinematic without mutating cut count", function()
    local cin = lurek.cinematic.new()
    cin:addCut(0.0, "scene_start")
    cin:addCut(1.0, "scene_end")
    expect_equal(cin:cutCount(), 2)
    cin:play()
    expect_equal(cin:cutCount(), 2)
  end)

  -- @covers LCinematic:clear
  it("clears all cuts from a cinematic", function()
    local cin = lurek.cinematic.new()
    cin:addCut(0.0, "intro")
    cin:addCut(2.0, "outro")
    expect_equal(cin:cutCount(), 2)
    cin:clear()
    expect_equal(cin:cutCount(), 0)
  end)

  -- @covers LCinematic:type
  it("type returns LCinematic", function()
    local cin = lurek.cinematic.new()
    expect_equal(cin:type(), "LCinematic")
  end)

  -- @covers LCinematic:typeOf
  it("typeOf recognizes cinematic handles", function()
    local cin = lurek.cinematic.new()
    expect_true(cin:typeOf("LCinematic"))
    expect_true(cin:typeOf("Object"))
  end)
end

local function test_timeline_type_methods()
  -- @covers LCinematicTimeline:type
  it("type returns LCinematicTimeline", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:type(), "LCinematicTimeline")
  end)

  -- @covers LCinematicTimeline:typeOf
  it("typeOf recognizes type name", function()
    local tl = lurek.cinematic.newTimeline()
    expect_true(tl:typeOf("LCinematicTimeline"))
    expect_true(tl:typeOf("Object"))
  end)
end

local function test_cinematic_creation()
  -- @covers lurek.cinematic.new
  it("creates a new cinematic", function()
    local cin = lurek.cinematic.new()
    expect_true(cin:typeOf("LCinematic"))
  end)
end

local function test_cinematic_cuts()
  -- @covers LCinematic:addCut
  it("adds a cut to cinematic", function()
    local cin = lurek.cinematic.new()
    cin:addCut(0.0, "scene_start")
    expect_equal(cin:cutCount(), 1)
  end)

  -- @covers LCinematic:cutCount
  it("returns cut count", function()
    local cin = lurek.cinematic.new()
    expect_equal(cin:cutCount(), 0)
    cin:addCut(0.0, "intro")
    expect_equal(cin:cutCount(), 1)
    cin:addCut(2.0, "action_start")
    expect_equal(cin:cutCount(), 2)
  end)
end

test_timeline_creation()
test_track_management()
test_clip_addition()
test_playback_control()
test_time_control()
test_labels_and_branching()
test_cinematic_methods()
test_timeline_type_methods()
test_cinematic_creation()
test_cinematic_cuts()
test_summary()
