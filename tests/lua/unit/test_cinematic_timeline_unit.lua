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

  -- @covers lurek.cinematic.newTimeline
  it("starts in stopped state", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getState(), "stopped")
  end)

  -- @covers lurek.cinematic.newTimeline
  it("has zero duration on creation", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getDuration(), 0.0)
  end)

  -- @covers lurek.cinematic.newTimeline
  it("starts at time zero", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getTime(), 0.0)
  end)
end

local function test_track_management()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:addTrack
  it("can add tracks", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addTrack("camera")
    tl:addTrack("audio")
    expect_equal(tl:getDuration(), 0.0) -- no clips yet
  end)
end

local function test_clip_addition()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:addClip
  it("adds camera clip to track", function()
    local tl = lurek.cinematic.newTimeline()
    local clip = {
      type = "camera",
      x = 100.0,
      y = 50.0,
      zoom = 2.0
    }
    tl:addClip("camera", 0.0, 1.0, clip)
    expect_equal(tl:getDuration(), 1.0)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:addClip
  it("adds signal clip", function()
    local tl = lurek.cinematic.newTimeline()
    local clip = {
      type = "signal",
      name = "combat_start",
      data = "goblin"
    }
    tl:addClip("signals", 2.0, 0.1, clip)
    expect_equal(tl:getDuration(), 2.1)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:addClip
  it("adds audio clip", function()
    local tl = lurek.cinematic.newTimeline()
    local clip = {
      type = "audio",
      path = "sfx/explosion.wav"
    }
    tl:addClip("sfx", 5.0, 2.0, clip)
    expect_equal(tl:getDuration(), 7.0)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:addClip
  it("adds tween clip with properties", function()
    local tl = lurek.cinematic.newTimeline()
    local clip = {
      type = "tween",
      target = "sprite1",
      properties = { x = 100.0, y = 200.0, alpha = 0.5 },
      easing = "ease_in_quad"
    }
    tl:addClip("tweens", 1.0, 3.0, clip)
    expect_equal(tl:getDuration(), 4.0)
  end)
end

local function test_playback_control()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:play
  it("transitions to playing state", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 1.0, { type = "signal", name = "test" })
    tl:play()
    expect_equal(tl:getState(), "playing")
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:pause
  it("pauses playback", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 1.0, { type = "signal", name = "test" })
    tl:play()
    tl:pause()
    expect_equal(tl:getState(), "paused")
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:stop
  it("stops and resets to zero", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(2.0)
    tl:stop()
    expect_equal(tl:getState(), "stopped")
    expect_equal(tl:getTime(), 0.0)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:isPlaying
  it("isPlaying returns correct state", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 1.0, { type = "signal", name = "test" })
    expect_false(tl:isPlaying())
    tl:play()
    expect_true(tl:isPlaying())
  end)
end

local function test_time_control()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:seek
  it("seeks to specified time", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:seek(5.5)
    expect_equal(tl:getTime(), 5.5)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:update
  it("advances time when playing", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:play()
    tl:update(2.5)
    expect_equal(tl:getTime(), 2.5)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:skipToEnd
  it("instantly jumps to end", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 10.0, { type = "signal", name = "test" })
    tl:skipToEnd()
    expect_equal(tl:getTime(), 10.0)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:isComplete
  it("detects completion", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 3.0, { type = "signal", name = "test" })
    expect_false(tl:isComplete())
    tl:seek(5.0)
    expect_true(tl:isComplete())
  end)
end

local function test_labels_and_branching()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:addLabel
  it("can add labeled positions", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addLabel("scene_start", 0.0)
    tl:addLabel("midpoint", 5.0)
    tl:addLabel("ending", 10.0)
    expect_equal(tl:getTime(), 0.0)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:branch
  it("branches to label", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 15.0, { type = "signal", name = "test" })
    tl:addLabel("checkpoint", 7.5)
    local ok = tl:branch("checkpoint")
    expect_true(ok)
    expect_equal(tl:getTime(), 7.5)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:branch
  it("branch fails for missing label", function()
    local tl = lurek.cinematic.newTimeline()
    local ok = tl:branch("nonexistent")
    expect_false(ok)
  end)
end

local function test_timeline_queries()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:getState
  it("getState returns current state", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getState(), "stopped")
    tl:play()
    expect_true(tl:getState() == "playing")
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:getDuration
  it("getDuration reflects clip lengths", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:getDuration(), 0.0)
    tl:addClip("track1", 0.0, 5.0, { type = "signal", name = "a" })
    expect_equal(tl:getDuration(), 5.0)
    tl:addClip("track2", 2.0, 8.0, { type = "signal", name = "b" })
    expect_equal(tl:getDuration(), 10.0)
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:getTime
  it("getTime reflects current playback position", function()
    local tl = lurek.cinematic.newTimeline()
    tl:addClip("test", 0.0, 5.0, { type = "signal", name = "test" })
    expect_equal(tl:getTime(), 0.0)
    tl:seek(3.2)
    expect_equal(tl:getTime(), 3.2)
  end)
end

local function test_type_methods()
  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:type
  it("type returns LCinematicTimeline", function()
    local tl = lurek.cinematic.newTimeline()
    expect_equal(tl:type(), "LCinematicTimeline")
  end)

  -- @covers lurek.cinematic.newTimeline lurek.cinematic.newTimeline:typeOf
  it("typeOf recognizes type name", function()
    local tl = lurek.cinematic.newTimeline()
    expect_true(tl:typeOf("LCinematicTimeline"))
    expect_true(tl:typeOf("Object"))
  end)
end

test_timeline_creation()
test_track_management()
test_clip_addition()
test_playback_control()
test_time_control()
test_labels_and_branching()
test_timeline_queries()
test_type_methods()

test_summary()
