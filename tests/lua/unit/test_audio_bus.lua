-- Audio Bus and MidiPlayer integration tests (headless-safe)

-- @description Covers suite: lurek.audio.newBus.
describe("lurek.audio.newBus", function()
    -- @covers lurek.audio.newBus
    -- @covers Bus.getName
    -- @covers lurek.audio.getListener2D
    -- @covers lurek.audio.getMaxSources
    -- @covers lurek.audio.getMeter
    -- @covers lurek.audio.newMidiPlayer
    -- @covers lurek.audio.setListener2D
    -- @covers lurek.audio.setMeter
    -- @description Verifies bus construction preserves the provided bus name.
    it("creates a bus with the given name", function()
        local bus = lurek.audio.newBus("music")
        expect_equal(bus:getName(), "music")
    end)

    -- @covers lurek.audio.newBus
    -- @covers Bus.getVolume
    -- @description Verifies newly created buses start at unity volume.
    it("has default volume 1.0", function()
        local bus = lurek.audio.newBus("test")
        expect_near(bus:getVolume(), 1.0, 1e-5)
    end)

    -- @covers lurek.audio.newBus
    -- @covers Bus.getPitch
    -- @description Verifies newly created buses start at neutral pitch.
    it("has default pitch 1.0", function()
        local bus = lurek.audio.newBus("test")
        expect_near(bus:getPitch(), 1.0, 1e-5)
    end)

    -- @covers lurek.audio.newBus
    -- @covers Bus.isPaused
    -- @description Verifies new buses begin unpaused.
    it("is not paused by default", function()
        local bus = lurek.audio.newBus("test")
        expect_false(bus:isPaused())
    end)
end)

-- @description Covers suite: Bus:setVolume / getVolume.
describe("Bus:setVolume / getVolume", function()
    -- @covers Bus.setVolume
    -- @covers Bus.getVolume
    -- @description Verifies bus volume changes round-trip for an in-range scalar.
    it("sets and gets volume", function()
        local bus = lurek.audio.newBus("test")
        bus:setVolume(0.7)
        expect_near(bus:getVolume(), 0.7, 1e-5)
    end)

    -- @covers Bus.setVolume
    -- @covers Bus.getVolume
    -- @description Verifies negative bus volume inputs clamp to silence instead of going below zero.
    it("clamps negative volume to 0", function()
        local bus = lurek.audio.newBus("test")
        bus:setVolume(-1.0)
        expect_near(bus:getVolume(), 0.0, 1e-5)
    end)
end)

-- @description Covers suite: Bus:setPitch / getPitch.
describe("Bus:setPitch / getPitch", function()
    -- @covers Bus.setPitch
    -- @covers Bus.getPitch
    -- @description Verifies bus pitch changes round-trip for a positive factor.
    it("sets and gets pitch", function()
        local bus = lurek.audio.newBus("test")
        bus:setPitch(1.5)
        expect_near(bus:getPitch(), 1.5, 1e-5)
    end)

    -- @covers Bus.setPitch
    -- @covers Bus.getPitch
    -- @description Verifies negative pitch values clamp to zero rather than producing invalid playback factors.
    it("clamps negative pitch to 0", function()
        local bus = lurek.audio.newBus("test")
        bus:setPitch(-0.5)
        expect_near(bus:getPitch(), 0.0, 1e-5)
    end)
end)

-- @description Covers suite: Bus:pause / resume / isPaused.
describe("Bus:pause / resume / isPaused", function()
    -- @covers Bus.pause
    -- @covers Bus.resume
    -- @covers Bus.isPaused
    -- @description Verifies pause state flips on and off through the lifecycle methods.
    it("pauses and resumes", function()
        local bus = lurek.audio.newBus("test")
        bus:pause()
        expect_true(bus:isPaused())
        bus:resume()
        expect_false(bus:isPaused())
    end)
end)

-- @description Covers suite: Bus type system.
describe("Bus type system", function()
    -- @covers Bus.type
    -- @description Verifies bus userdata reports its concrete runtime type string.
    it("reports type as Bus", function()
        local bus = lurek.audio.newBus("test")
        expect_equal(bus:type(), "Bus")
    end)

    -- @covers Bus.typeOf
    -- @description Verifies bus userdata advertises both its concrete type and Object base type.
    it("typeOf returns true for Bus and Object", function()
        local bus = lurek.audio.newBus("test")
        expect_true(bus:typeOf("Bus"))
        expect_true(bus:typeOf("Object"))
    end)
end)

-- @description Covers suite: lurek.audio.getMaxSources.
describe("lurek.audio.getMaxSources", function()
    -- @covers lurek.audio.getMaxSources
    -- @description Verifies the engine reports the expected global static max-source limit.
    it("returns 64", function()
        expect_equal(lurek.audio.getMaxSources(), 64)
    end)
end)

-- @description Covers suite: lurek.audio.setListener2D / getListener2D stubs.
describe("lurek.audio.setListener2D / getListener2D stubs", function()
    -- @covers lurek.audio.setListener2D
    -- @description Verifies the 2D listener setter accepts valid coordinates without error.
    it("setListener2D does not error", function()
        lurek.audio.setListener2D(1.0, 2.0)
    end)

    -- @covers lurek.audio.setListener2D
    -- @covers lurek.audio.getListener2D
    -- @description Verifies the 2D listener compatibility helpers round-trip the last set position.
    it("getListener2D returns the position set by setListener2D", function()
        lurek.audio.setListener2D(1.0, 2.0)
        local x, y = lurek.audio.getListener2D()
        expect_near(x, 1.0, 1e-5)
        expect_near(y, 2.0, 1e-5)
        -- reset for other tests
        lurek.audio.setListener2D(0.0, 0.0)
    end)
end)

-- @description Covers suite: lurek.audio.setMeter / getMeter stubs.
describe("lurek.audio.setMeter / getMeter stubs", function()
    -- @covers lurek.audio.setMeter
    -- @description Verifies the meter setter accepts a numeric value without error even in stubbed form.
    it("setMeter does not error", function()
        lurek.audio.setMeter(2.0)
    end)

    -- @covers lurek.audio.getMeter
    -- @description Verifies the stub meter getter returns the fixed default meter scalar.
    it("getMeter returns 1.0", function()
        expect_near(lurek.audio.getMeter(), 1.0, 1e-5)
    end)
end)

-- @description Covers suite: lurek.audio.newMidiPlayer.
describe("lurek.audio.newMidiPlayer", function()
    -- @covers lurek.audio.newMidiPlayer
    -- @covers MidiPlayer.isLoaded
    -- @description Verifies creating a MIDI player yields an unloaded player object.
    it("creates a MidiPlayer", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_false(midi:isLoaded())
    end)

    -- @covers lurek.audio.newMidiPlayer
    -- @covers MidiPlayer.isPlaying
    -- @description Verifies unloaded MIDI players start stopped.
    it("is not playing by default", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_false(midi:isPlaying())
    end)

    -- @covers lurek.audio.newMidiPlayer
    -- @covers MidiPlayer.getVolume
    -- @description Verifies new MIDI players default to full volume.
    it("has default volume 1.0", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_near(midi:getVolume(), 1.0, 1e-5)
    end)

    -- @covers lurek.audio.newMidiPlayer
    -- @covers MidiPlayer.getTempoScale
    -- @description Verifies tempo scaling starts at neutral speed.
    it("has default tempo scale 1.0", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_near(midi:getTempoScale(), 1.0, 1e-5)
    end)

    -- @covers lurek.audio.newMidiPlayer
    -- @covers MidiPlayer.getTrackCount
    -- @description Verifies unloaded MIDI players report zero tracks.
    it("has 0 tracks when unloaded", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_equal(midi:getTrackCount(), 0)
    end)

    -- @covers lurek.audio.newMidiPlayer
    -- @covers MidiPlayer.getNoteCount
    -- @description Verifies unloaded MIDI players report zero note events.
    it("has 0 note count when unloaded", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_equal(midi:getNoteCount(), 0)
    end)
end)

-- @description Covers suite: MidiPlayer volume.
describe("MidiPlayer volume", function()
    -- @covers MidiPlayer.setVolume
    -- @covers MidiPlayer.getVolume
    -- @description Verifies MIDI player volume round-trips through its accessor pair.
    it("sets and gets volume", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setVolume(0.5)
        expect_near(midi:getVolume(), 0.5, 1e-5)
    end)
end)

-- @description Covers suite: MidiPlayer tempo.
describe("MidiPlayer tempo", function()
    -- @covers MidiPlayer.setTempoScale
    -- @covers MidiPlayer.getTempoScale
    -- @description Verifies MIDI tempo scaling round-trips through the setter/getter pair.
    it("sets and gets tempo scale", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setTempoScale(2.0)
        expect_near(midi:getTempoScale(), 2.0, 1e-5)
    end)

    -- @covers MidiPlayer.getOriginalTempo
    -- @description Verifies unloaded MIDI players expose the default original tempo metadata.
    it("getOriginalTempo returns 120 when unloaded", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_near(midi:getOriginalTempo(), 120.0, 1e-5)
    end)
end)

-- @description Covers suite: MidiPlayer looping.
describe("MidiPlayer looping", function()
    -- @covers MidiPlayer.setLooping
    -- @covers MidiPlayer.isLooping
    -- @description Verifies looping can be toggled on and off and reflected immediately.
    it("toggles looping", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_false(midi:isLooping())
        midi:setLooping(true)
        expect_true(midi:isLooping())
        midi:setLooping(false)
        expect_false(midi:isLooping())
    end)
end)

-- @description Covers suite: MidiPlayer channel control.
describe("MidiPlayer channel control", function()
    -- @covers MidiPlayer.setChannelVolume
    -- @covers MidiPlayer.getChannelVolume
    -- @description Verifies per-channel volume uses 1-based indexing and round-trips the stored value.
    it("sets and gets channel volume (1-indexed)", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setChannelVolume(1, 0.5)
        expect_near(midi:getChannelVolume(1), 0.5, 1e-5)
    end)

    -- @covers MidiPlayer.setChannelMuted
    -- @covers MidiPlayer.isChannelMuted
    -- @description Verifies per-channel mute state can be toggled on and off.
    it("mutes and unmutes channel", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_false(midi:isChannelMuted(1))
        midi:setChannelMuted(1, true)
        expect_true(midi:isChannelMuted(1))
        midi:setChannelMuted(1, false)
        expect_false(midi:isChannelMuted(1))
    end)

    -- @covers MidiPlayer.setChannelInstrument
    -- @covers MidiPlayer.getChannelInstrument
    -- @description Verifies channel instrument program numbers round-trip.
    it("sets and gets channel instrument", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setChannelInstrument(1, 42)
        expect_equal(midi:getChannelInstrument(1), 42)
    end)

    -- @covers MidiPlayer.soloChannel
    -- @covers MidiPlayer.isChannelMuted
    -- @description Verifies soloChannel leaves the target channel audible while muting the others.
    it("soloChannel mutes all others", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:soloChannel(5)
        expect_false(midi:isChannelMuted(5))
        expect_true(midi:isChannelMuted(1))
        expect_true(midi:isChannelMuted(16))
    end)

    -- @covers MidiPlayer.unsoloAll
    -- @covers MidiPlayer.soloChannel
    -- @covers MidiPlayer.isChannelMuted
    -- @description Verifies unsoloAll clears solo-side muting across every channel.
    it("unsoloAll unmutes all", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:soloChannel(5)
        midi:unsoloAll()
        expect_false(midi:isChannelMuted(1))
        expect_false(midi:isChannelMuted(5))
        expect_false(midi:isChannelMuted(16))
    end)
end)

-- @description Covers suite: MidiPlayer stubs.
describe("MidiPlayer stubs", function()
    -- @description Verifies case: setSoundFont does not error.
    it("setSoundFont does not error", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setSoundFont("path/to/sf2")
    end)

    -- @description Verifies case: useDefaultSoundFont does not error.
    it("useDefaultSoundFont does not error", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:useDefaultSoundFont()
    end)

    -- @description Verifies case: getSoundFontPath returns nil.
    it("getSoundFontPath returns nil", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_equal(midi:getSoundFontPath(), nil)
    end)

    -- @description Verifies case: setOnNoteOn does not error.
    it("setOnNoteOn does not error", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setOnNoteOn(function() end)
    end)

    -- @description Verifies case: setOnNoteOff does not error.
    it("setOnNoteOff does not error", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setOnNoteOff(function() end)
    end)

    -- @description Verifies case: setOnEnd does not error.
    it("setOnEnd does not error", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setOnEnd(function() end)
    end)
end)

-- @description Covers suite: MidiPlayer type system.
describe("MidiPlayer type system", function()
    -- @description Verifies case: reports type as MidiPlayer.
    it("reports type as MidiPlayer", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_equal(midi:type(), "MidiPlayer")
    end)

    -- @description Verifies case: typeOf returns true for MidiPlayer and Object.
    it("typeOf returns true for MidiPlayer and Object", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_true(midi:typeOf("MidiPlayer"))
        expect_true(midi:typeOf("Object"))
    end)
end)

-- @description Covers suite: MidiPlayer seek/tell.
describe("MidiPlayer seek/tell", function()
    -- @description Verifies case: seek and tell work.
    it("seek and tell work", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:seek(5.0)
        expect_near(midi:tell(), 5.0, 1e-5)
    end)

    -- @description Verifies case: seek clamps negative to 0.
    it("seek clamps negative to 0", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:seek(-1.0)
        expect_near(midi:tell(), 0.0, 1e-5)
    end)
end)

-- @description Covers suite: MidiPlayer getDuration.
describe("MidiPlayer getDuration", function()
    -- @description Verifies case: returns 0 when unloaded.
    it("returns 0 when unloaded", function()
        local midi = lurek.audio.newMidiPlayer()
        expect_near(midi:getDuration(), 0.0, 1e-5)
    end)
end)
test_summary()
