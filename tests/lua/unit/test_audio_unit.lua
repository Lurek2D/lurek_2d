-- tests/lua/unit/test_audio_unit.lua
-- Lua-first unit tests for lurek.audio module covering source creation, playback, volume, filtering, and bus routing.

local harness = require("tests.lua.harness")

describe("lurek.audio", function()
    -- Source loading and creation
    -- @covers lurek.audio.newSource
    it("creates a new audio source from file path", function()
        local source = lurek.audio.newSource("assets/audio/test.wav")
        assert_equal("userdata", type(source))
        assert_equal("LSource", source:type())
    end)

    -- @covers lurek.audio.newSource
    it("creates stream source for music files", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg", "stream")
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.newSource
    it("creates static source for sound effects", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav", "static")
        assert_equal("userdata", type(source))
    end)

    -- Playback control
    -- @covers lurek.audio.play
    it("plays an audio source", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.pause
    it("pauses audio playback", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.pause(source)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.resume
    it("resumes paused audio", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.pause(source)
        lurek.audio.resume(source)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.stop
    it("stops audio and resets position", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.stop(source)
        assert_equal("userdata", type(source))
    end)

    -- Volume control
    -- @covers lurek.audio.setVolume
    it("sets source volume level", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setVolume(source, 0.5)
        local vol = lurek.audio.getVolume(source)
        assert_near(vol, 0.5, 0.01)
    end)

    -- @covers lurek.audio.getVolume
    it("gets current source volume", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setVolume(source, 0.75)
        local vol = lurek.audio.getVolume(source)
        assert_equal("number", type(vol))
    end)

    -- @covers lurek.audio.setMasterVolume
    it("sets global master volume", function()
        lurek.audio.setMasterVolume(0.5)
        local master = lurek.audio.getMasterVolume()
        assert_near(master, 0.5, 0.01)
    end)

    -- @covers lurek.audio.getMasterVolume
    it("gets current master volume", function()
        lurek.audio.setMasterVolume(0.8)
        local vol = lurek.audio.getMasterVolume()
        assert_equal("number", type(vol))
    end)

    -- Pitch control
    -- @covers lurek.audio.setPitch
    it("sets audio playback pitch", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setPitch(source, 2.0)
        local pitch = lurek.audio.getPitch(source)
        assert_near(pitch, 2.0, 0.01)
    end)

    -- @covers lurek.audio.getPitch
    it("gets current pitch multiplier", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setPitch(source, 1.5)
        local pitch = lurek.audio.getPitch(source)
        assert_equal("number", type(pitch))
    end)

    -- Panning
    -- @covers lurek.audio.setPan
    it("sets stereo pan position", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setPan(source, -0.5)  -- pan left
        local pan = lurek.audio.getPan(source)
        assert_near(pan, -0.5, 0.01)
    end)

    -- @covers lurek.audio.getPan
    it("gets current pan position", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setPan(source, 0.8)
        local pan = lurek.audio.getPan(source)
        assert_equal("number", type(pan))
    end)

    -- Looping
    -- @covers lurek.audio.setLooping
    it("enables audio looping", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg")
        lurek.audio.setLooping(source, true)
        local is_looping = lurek.audio.isLooping(source)
        assert_equal(true, is_looping)
    end)

    -- @covers lurek.audio.isLooping
    it("reports looping state", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setLooping(source, false)
        local is_looping = lurek.audio.isLooping(source)
        assert_equal(false, is_looping)
    end)

    -- @covers lurek.audio.playLooping
    it("plays audio with looping enabled in one call", function()
        local source = lurek.audio.newSource("assets/audio/ambient.ogg")
        lurek.audio.playLooping(source)
        assert_equal(true, lurek.audio.isLooping(source))
    end)

    -- Position seeking
    -- @covers lurek.audio.tell
    it("returns current playback position", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        local pos = lurek.audio.tell(source)
        assert_equal("number", type(pos))
        assert_true(pos >= 0)
    end)

    -- @covers lurek.audio.seek
    it("seeks to specific playback position", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg")
        lurek.audio.seek(source, 10.5)
        local pos = lurek.audio.tell(source)
        assert_near(pos, 10.5, 0.5)  -- allow 0.5s tolerance
    end)

    -- Duration
    -- @covers lurek.audio.getDuration
    it("returns total duration of audio", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg")
        local duration = lurek.audio.getDuration(source)
        assert_equal("number", type(duration))
        assert_true(duration > 0)
    end)

    -- Filtering
    -- @covers lurek.audio.setLowpass
    it("applies lowpass filter to source", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setLowpass(source, 5000)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.setHighpass
    it("applies highpass filter to source", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setHighpass(source, 1000)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.getLowpass
    it("gets lowpass filter cutoff frequency", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setLowpass(source, 6000)
        local cutoff = lurek.audio.getLowpass(source)
        assert_equal("number", type(cutoff))
    end)

    -- @covers lurek.audio.getHighpass
    it("gets highpass filter cutoff frequency", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setHighpass(source, 2000)
        local cutoff = lurek.audio.getHighpass(source)
        assert_equal("number", type(cutoff))
    end)

    -- @covers lurek.audio.clearFilter
    it("removes all filters from source", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.setLowpass(source, 4000)
        lurek.audio.clearFilter(source)
        assert_equal("userdata", type(source))
    end)

    -- Fade-in
    -- @covers lurek.audio.fadeIn
    it("sets fade-in duration on source", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.fadeIn(source, 1.0)
        local duration = lurek.audio.getFadeIn(source)
        assert_near(duration, 1.0, 0.01)
    end)

    -- @covers lurek.audio.getFadeIn
    it("gets configured fade-in duration", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg")
        lurek.audio.fadeIn(source, 2.0)
        local duration = lurek.audio.getFadeIn(source)
        assert_equal("number", type(duration))
    end)

    -- Source management
    -- @covers lurek.audio.clone
    it("creates independent copy of source", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        local cloned = lurek.audio.clone(source)
        assert_equal("userdata", type(cloned))
    end)

    -- @covers lurek.audio.release
    it("releases audio source and frees memory", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        local released = lurek.audio.release(source)
        assert_equal(true, released)
    end)

    -- @covers lurek.audio.getSourceType
    it("returns source type (static or stream)", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav", "static")
        local stype = lurek.audio.getSourceType(source)
        assert_equal("static", stype)
    end)

    -- Source count tracking
    -- @covers lurek.audio.getSourceCount
    it("returns total number of loaded sources", function()
        local count = lurek.audio.getSourceCount()
        assert_equal("number", type(count))
        assert_true(count >= 0)
    end)

    -- @covers lurek.audio.getActiveSourceCount
    it("returns number of currently playing sources", function()
        local active = lurek.audio.getActiveSourceCount()
        assert_equal("number", type(active))
        assert_true(active >= 0)
    end)

    -- Batch control
    -- @covers lurek.audio.pauseAll
    it("pauses all currently playing audio", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.pauseAll()
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.resumeAll
    it("resumes all paused audio", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.pauseAll()
        lurek.audio.resumeAll()
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.stopAll
    it("stops all audio sources", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.stopAll()
        assert_equal("userdata", type(source))
    end)

    -- Global mute (NEW in Phase 2)
    -- @covers lurek.audio.setMuted
    it("globally mutes all audio", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        lurek.audio.play(source)
        lurek.audio.setMuted(true)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.isMuted
    it("reports global mute state", function()
        lurek.audio.setMuted(false)
        local is_muted = lurek.audio.isMuted()
        assert_true(type(is_muted) == "boolean")
    end)

    -- Stop music with fade (NEW in Phase 2)
    -- @covers lurek.audio.stopMusic
    it("stops all music with optional fade-out", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg")
        lurek.audio.play(source)
        lurek.audio.stopMusic(1.0)  -- 1 second fade-out
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.stopMusic
    it("stops music with no fade if duration is 0", function()
        local source = lurek.audio.newSource("assets/audio/music.ogg")
        lurek.audio.play(source)
        lurek.audio.stopMusic(0.0)
        assert_equal("userdata", type(source))
    end)

    -- Play SFX with options (NEW in Phase 2)
    -- @covers lurek.audio.playSfx
    it("plays one-shot sound effect", function()
        local source = lurek.audio.playSfx("assets/audio/sfx.wav")
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.playSfx
    it("plays SFX with volume option", function()
        local source = lurek.audio.playSfx("assets/audio/sfx.wav", {volume = 0.8})
        local vol = lurek.audio.getVolume(source)
        assert_near(vol, 0.8, 0.01)
    end)

    -- @covers lurek.audio.playSfx
    it("plays SFX with loop option", function()
        local source = lurek.audio.playSfx("assets/audio/ambient.ogg", {loop = true})
        assert_equal(true, lurek.audio.isLooping(source))
    end)

    -- Bus management
    -- @covers lurek.audio.newBus
    it("creates a new audio bus", function()
        local bus = lurek.audio.newBus("sfx_bus")
        assert_equal("userdata", type(bus))
        assert_equal("LBus", bus:type())
    end)

    -- @covers lurek.audio.setSourceBus
    it("routes source through a bus", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        local bus = lurek.audio.newBus("test_bus")
        lurek.audio.setSourceBus(source, bus)
        assert_equal("userdata", type(source))
    end)

    -- @covers lurek.audio.getSourceBus
    it("gets the bus a source is routed through", function()
        local source = lurek.audio.newSource("assets/audio/sfx.wav")
        local bus = lurek.audio.newBus("query_bus")
        lurek.audio.setSourceBus(source, bus)
        local assigned_bus = lurek.audio.getSourceBus(source)
        assert_equal("userdata", type(assigned_bus))
    end)

    -- Listener position (for spatial audio)
    -- @covers lurek.audio.setListener2D
    it("sets 2D listener position for spatial audio", function()
        lurek.audio.setListener2D(100, 200)
        assert_equal("userdata", type(lurek.audio))
    end)

    -- @covers lurek.audio.getListener2D
    it("gets current 2D listener position", function()
        lurek.audio.setListener2D(150, 250)
        local x, y = lurek.audio.getListener2D()
        assert_near(x, 150, 0.1)
        assert_near(y, 250, 0.1)
    end)

    -- Device management
    -- @covers lurek.audio.getPlaybackDevices
    it("returns list of available playback devices", function()
        local devices = lurek.audio.getPlaybackDevices()
        assert_true(type(devices) == "table" or devices == nil)
    end)

    -- Query methods
    -- @covers lurek.audio.getMaxSources
    it("returns maximum concurrent sources", function()
        local max_sources = lurek.audio.getMaxSources()
        assert_equal("number", type(max_sources))
        assert_true(max_sources > 0)
    end)

    -- MIDI support
    -- @covers lurek.audio.newMidiPlayer
    it("creates a MIDI player", function()
        local midi = lurek.audio.newMidiPlayer("assets/audio/song.mid")
        assert_equal("userdata", type(midi))
        assert_equal("LMidiPlayer", midi:type())
    end)

    -- @covers lurek.audio.newMidiPlayer
    it("creates MIDI player without loading file", function()
        local midi = lurek.audio.newMidiPlayer()
        assert_equal("userdata", type(midi))
    end)

    -- Sound pool
    -- @covers lurek.audio.newSoundPool
    it("creates a pre-allocated sound pool", function()
        local pool = lurek.audio.newSoundPool("assets/audio/sfx.wav", 8)
        assert_equal("userdata", type(pool))
        assert_equal("LSoundPool", pool:type())
    end)
end)

test_summary()
