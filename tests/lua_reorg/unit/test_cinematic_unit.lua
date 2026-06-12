-- Canonical unit coverage for lurek.cinematic.

local function new_timeline()
    return lurek.cinematic.newTimeline()
end

local function new_cinematic()
    return lurek.cinematic.new()
end

local function timeline_with_clip()
    local tl = new_timeline()
    tl:addTrack("main")
    tl:addClip("main", 0.5, 1.5, {
        type = "camera",
        x = 32,
        y = 64,
        zoom = 1.25,
    })
    return tl
end

-- @describe lurek.cinematic module
describe("lurek.cinematic module", function()
    -- @covers lurek.cinematic.new
    it("new creates a cinematic handle", function()
        local cinematic = new_cinematic()
        expect_equal("userdata", type(cinematic))
        expect_true(cinematic:typeOf("LCinematic"))
    end)

    -- @covers lurek.cinematic.newTimeline
    it("newTimeline creates a timeline handle", function()
        local timeline = new_timeline()
        expect_equal("userdata", type(timeline))
        expect_true(timeline:typeOf("LCinematicTimeline"))
    end)
end)

-- @describe timeline methods
describe("cinematic timeline methods", function()
    -- @covers LCinematicTimeline:addTrack
    it("addTrack accepts a new named track", function()
        local timeline = new_timeline()
        expect_no_error(function()
            timeline:addTrack("camera")
        end)
    end)

    -- @covers LCinematicTimeline:addClip
    it("addClip contributes to timeline duration", function()
        local timeline = new_timeline()
        timeline:addTrack("camera")
        timeline:addClip("camera", 0.5, 1.5, {
            type = "camera",
            x = 10,
            y = 20,
            zoom = 1.1,
        })
        expect_near(2.0, timeline:getDuration(), 0.0001)
    end)

    -- @covers LCinematicTimeline:play
    it("play moves the timeline into playing state", function()
        local timeline = timeline_with_clip()
        timeline:play()
        expect_equal("playing", timeline:getState())
    end)

    -- @covers LCinematicTimeline:pause
    it("pause moves the timeline into paused state", function()
        local timeline = timeline_with_clip()
        timeline:play()
        timeline:pause()
        expect_equal("paused", timeline:getState())
    end)

    -- @covers LCinematicTimeline:stop
    it("stop resets time and state", function()
        local timeline = timeline_with_clip()
        timeline:play()
        timeline:seek(1.0)
        timeline:stop()
        expect_equal("stopped", timeline:getState())
        expect_near(0.0, timeline:getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:seek
    it("seek updates the playback time", function()
        local timeline = timeline_with_clip()
        timeline:seek(1.25)
        expect_near(1.25, timeline:getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:update
    it("update advances time while playing", function()
        local timeline = timeline_with_clip()
        timeline:play()
        timeline:update(0.75)
        expect_near(0.75, timeline:getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:skipToEnd
    it("skipToEnd jumps to the full duration", function()
        local timeline = timeline_with_clip()
        timeline:skipToEnd()
        expect_near(timeline:getDuration(), timeline:getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:getTime
    it("getTime starts at zero", function()
        expect_near(0.0, new_timeline():getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:getDuration
    it("getDuration reports the latest clip end time", function()
        local timeline = timeline_with_clip()
        expect_near(2.0, timeline:getDuration(), 0.0001)
    end)

    -- @covers LCinematicTimeline:getState
    it("getState defaults to stopped", function()
        expect_equal("stopped", new_timeline():getState())
    end)

    -- @covers LCinematicTimeline:isPlaying
    it("isPlaying reflects playback state", function()
        local timeline = timeline_with_clip()
        timeline:play()
        expect_true(timeline:isPlaying())
    end)

    -- @covers LCinematicTimeline:isComplete
    it("isComplete becomes true after the end is reached", function()
        local timeline = timeline_with_clip()
        timeline:skipToEnd()
        expect_true(timeline:isComplete())
    end)

    -- @covers LCinematicTimeline:addLabel
    it("addLabel registers a branch target", function()
        local timeline = timeline_with_clip()
        timeline:addLabel("middle", 1.0)
        expect_true(timeline:branch("middle"))
        expect_near(1.0, timeline:getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:branch
    it("branch jumps to a named label", function()
        local timeline = timeline_with_clip()
        timeline:addLabel("end", 2.0)
        expect_true(timeline:branch("end"))
        expect_near(2.0, timeline:getTime(), 0.0001)
    end)

    -- @covers LCinematicTimeline:type
    it("type returns LCinematicTimeline", function()
        expect_equal("LCinematicTimeline", new_timeline():type())
    end)

    -- @covers LCinematicTimeline:typeOf
    it("typeOf recognizes timeline and Object", function()
        local timeline = new_timeline()
        expect_true(timeline:typeOf("LCinematicTimeline"))
        expect_true(timeline:typeOf("Object"))
    end)
end)

-- @describe legacy cinematic methods
describe("legacy cinematic methods", function()
    -- @covers LCinematic:addCut
    it("addCut appends a cut entry", function()
        local cinematic = new_cinematic()
        cinematic:addCut(0.25, "intro")
        expect_equal(1, cinematic:cutCount())
    end)

    -- @covers LCinematic:play
    it("play accepts a populated cut list", function()
        local cinematic = new_cinematic()
        cinematic:addCut(0.25, "intro")
        expect_no_error(function()
            cinematic:play()
        end)
    end)

    -- @covers LCinematic:clear
    it("clear removes all cuts", function()
        local cinematic = new_cinematic()
        cinematic:addCut(0.25, "intro")
        cinematic:addCut(0.5, "pan")
        cinematic:clear()
        expect_equal(0, cinematic:cutCount())
    end)

    -- @covers LCinematic:cutCount
    it("cutCount reports the number of queued cuts", function()
        local cinematic = new_cinematic()
        cinematic:addCut(0.25, "intro")
        cinematic:addCut(0.5, "pan")
        expect_equal(2, cinematic:cutCount())
    end)

    -- @covers LCinematic:type
    it("type returns LCinematic", function()
        expect_equal("LCinematic", new_cinematic():type())
    end)

    -- @covers LCinematic:typeOf
    it("typeOf recognizes cinematic and Object", function()
        local cinematic = new_cinematic()
        expect_true(cinematic:typeOf("LCinematic"))
        expect_true(cinematic:typeOf("Object"))
    end)
end)

test_summary()
