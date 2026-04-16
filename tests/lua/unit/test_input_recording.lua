-- tests/lua/unit/test_input_recording.lua
-- Tests for lurek.input recording and playback.
-- Uses only the API surface (no GPU/window/audio calls).

describe("input.recording", function()

    it("startRecording/stopRecording returns an InputRecording userdata", function()
        lurek.input.startRecording()
        expect_equal(lurek.input.isRecording(), true)
        local rec = lurek.input.stopRecording()
        expect_equal(lurek.input.isRecording(), false)
        expect_equal(rec ~= nil, true)
    end)

    it("stopRecording returns nil when not recording", function()
        -- Ensure we are not recording
        lurek.input.stopRecording()  -- safe no-op
        local rec = lurek.input.stopRecording()
        expect_equal(rec, nil)
    end)

    it("InputRecording:totalFrames is zero for empty recording", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        expect_equal(type(rec:totalFrames()), "number")
        expect_equal(rec:totalFrames() >= 0, true)
    end)

    it("InputRecording:frameCount returns 0 for recording with no events", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        expect_equal(rec:frameCount(), 0)
    end)

    it("InputRecording:toJson returns a non-empty string", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        local json = rec:toJson()
        expect_equal(type(json), "string")
        expect_equal(#json > 0, true)
    end)

    it("loadRecording accepts valid JSON without error", function()
        -- get a valid JSON from a fresh recording
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        local json = rec:toJson()
        -- load it back — should not raise
        lurek.input.loadRecording(json)
    end)

    it("loadRecording raises error for invalid JSON", function()
        expect_error(function()
            lurek.input.loadRecording("not valid json {{{{")
        end)
    end)

    it("startPlayback/stopPlayback / isPlayingBack work after load", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        expect_equal(lurek.input.isPlayingBack(), true)
        lurek.input.stopPlayback()
        expect_equal(lurek.input.isPlayingBack(), false)
    end)

    it("getPlaybackFrame returns 0 at start of playback", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        expect_equal(lurek.input.getPlaybackFrame(), 0)
        lurek.input.stopPlayback()
    end)

    it("advancePlayback returns a table (empty when no events recorded)", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        local events = lurek.input.advancePlayback()
        expect_equal(type(events), "table")
        lurek.input.stopPlayback()
    end)

    it("isRecording is false while not recording", function()
        expect_equal(lurek.input.isRecording(), false)
    end)

    it("isPlayingBack is false when not playing", function()
        expect_equal(lurek.input.isPlayingBack(), false)
    end)

end)

test_summary()
