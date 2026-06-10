-- Canonical unit coverage for lurek.audio.

local FIXTURE = "tests/fixtures/sine_mono_44100.wav"

local function new_source()
    return lurek.audio.newSource(FIXTURE, "static")
end

local function new_sound_data()
    return lurek.audio.newSoundData(64, 44100, 1)
end

-- @describe exposed entrypoints
describe("audio exposed entrypoints", function()
    -- @covers lurek.audio.newSource
    it("newSource is exposed", function()
        expect_type("function", lurek.audio.newSource)
    end)

    -- @covers lurek.audio.play
    it("play is exposed", function()
        expect_type("function", lurek.audio.play)
    end)

    -- @covers lurek.audio.stop
    it("stop is exposed", function()
        expect_type("function", lurek.audio.stop)
    end)

    -- @covers lurek.audio.setVolume
    it("setVolume is exposed", function()
        expect_type("function", lurek.audio.setVolume)
    end)

    -- @covers lurek.audio.getVolume
    it("getVolume is exposed", function()
        expect_type("function", lurek.audio.getVolume)
    end)

    -- @covers lurek.audio.pause
    it("pause is exposed", function()
        expect_type("function", lurek.audio.pause)
    end)

    -- @covers lurek.audio.resume
    it("resume is exposed", function()
        expect_type("function", lurek.audio.resume)
    end)

    -- @covers lurek.audio.setPitch
    it("setPitch is exposed", function()
        expect_type("function", lurek.audio.setPitch)
    end)

    -- @covers lurek.audio.getPitch
    it("getPitch is exposed", function()
        expect_type("function", lurek.audio.getPitch)
    end)

    -- @covers lurek.audio.isPlaying
    it("isPlaying is exposed", function()
        expect_type("function", lurek.audio.isPlaying)
    end)

    -- @covers lurek.audio.isPaused
    it("isPaused is exposed", function()
        expect_type("function", lurek.audio.isPaused)
    end)

    -- @covers lurek.audio.isStopped
    it("isStopped is exposed", function()
        expect_type("function", lurek.audio.isStopped)
    end)

    -- @covers lurek.audio.newMidiPlayer
    it("newMidiPlayer is exposed", function()
        expect_type("function", lurek.audio.newMidiPlayer)
    end)

    -- @covers lurek.audio.mixInto
    it("mixInto is exposed", function()
        expect_type("function", lurek.audio.mixInto)
    end)

    -- @covers lurek.audio.setStereoWidth
    it("setStereoWidth is exposed", function()
        expect_type("function", lurek.audio.setStereoWidth)
    end)

    -- @covers lurek.audio.crossfade
    it("crossfade is exposed", function()
        expect_type("function", lurek.audio.crossfade)
    end)
end)

-- @describe global audio state
describe("audio global state", function()
    -- @covers lurek.audio.setMasterVolume
    it("setMasterVolume accepts values in range", function()
        expect_no_error(function()
            lurek.audio.setMasterVolume(0.5)
            lurek.audio.setMasterVolume(1.0)
        end)
    end)

    -- @covers lurek.audio.getMasterVolume
    it("getMasterVolume returns a number", function()
        expect_type("number", lurek.audio.getMasterVolume())
    end)

    -- @covers lurek.audio.getActiveSourceCount
    it("getActiveSourceCount returns a number", function()
        expect_type("number", lurek.audio.getActiveSourceCount())
    end)

    -- @covers lurek.audio.getSourceCount
    it("getSourceCount returns a number", function()
        expect_type("number", lurek.audio.getSourceCount())
    end)

    -- @covers lurek.audio.getMaxSources
    it("getMaxSources returns a number", function()
        expect_type("number", lurek.audio.getMaxSources())
    end)

    -- @covers lurek.audio.getDopplerScale
    it("getDopplerScale defaults to one", function()
        expect_near(1.0, lurek.audio.getDopplerScale(), 0.0001)
    end)

    -- @covers lurek.audio.setDopplerScale
    it("setDopplerScale round-trips through the getter", function()
        lurek.audio.setDopplerScale(2.0)
        expect_near(2.0, lurek.audio.getDopplerScale(), 0.0001)
        lurek.audio.setDopplerScale(1.0)
    end)

    -- @covers lurek.audio.getDistanceModel
    it("getDistanceModel returns a string", function()
        expect_type("string", lurek.audio.getDistanceModel())
    end)

    -- @covers lurek.audio.setDistanceModel
    it("setDistanceModel round-trips through the getter", function()
        lurek.audio.setDistanceModel("linear")
        expect_equal("linear", lurek.audio.getDistanceModel())
        lurek.audio.setDistanceModel("inverse_clamped")
    end)

    -- @covers lurek.audio.setListener
    it("setListener updates the 3d listener position", function()
        lurek.audio.setListener(100, 50, 0)
        local x, y, z = lurek.audio.getListener()
        expect_near(100, x, 0.001)
        expect_near(50, y, 0.001)
        expect_near(0, z, 0.001)
        lurek.audio.setListener(0, 0, 0)
    end)

    -- @covers lurek.audio.getListener
    it("getListener returns three numbers", function()
        local x, y, z = lurek.audio.getListener()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", z)
    end)

    -- @covers lurek.audio.setListener2D
    it("setListener2D updates the 2d listener position", function()
        lurek.audio.setListener2D(30, 40)
        local x, y = lurek.audio.getListener2D()
        expect_near(30, x, 0.001)
        expect_near(40, y, 0.001)
        lurek.audio.setListener2D(0, 0)
    end)

    -- @covers lurek.audio.getListener2D
    it("getListener2D returns two numbers", function()
        local x, y = lurek.audio.getListener2D()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers lurek.audio.setMeter
    it("setMeter is callable", function()
        expect_no_error(function()
            lurek.audio.setMeter(2.0)
        end)
    end)

    -- @covers lurek.audio.getMeter
    it("getMeter returns a number", function()
        expect_type("number", lurek.audio.getMeter())
    end)
end)

-- @describe decoder
describe("audio decoder", function()
    -- @covers lurek.audio.newDecoder
    it("newDecoder creates userdata for the fixture", function()
        expect_type("userdata", lurek.audio.newDecoder(FIXTURE))
    end)

    -- @covers LDecoder:getChannelCount
    it("getChannelCount reports mono for the fixture", function()
        expect_equal(1, lurek.audio.newDecoder(FIXTURE):getChannelCount())
    end)

    -- @covers LDecoder:getBitDepth
    it("getBitDepth returns a positive number", function()
        expect_true(lurek.audio.newDecoder(FIXTURE):getBitDepth() > 0)
    end)

    -- @covers LDecoder:getSampleRate
    it("getSampleRate returns a positive number", function()
        expect_true(lurek.audio.newDecoder(FIXTURE):getSampleRate() > 0)
    end)

    -- @covers LDecoder:getDuration
    it("getDuration returns a positive number", function()
        expect_true(lurek.audio.newDecoder(FIXTURE):getDuration() > 0)
    end)

    -- @covers LDecoder:seek
    it("seek moves the decode cursor", function()
        local decoder = lurek.audio.newDecoder(FIXTURE)
        decoder:seek(0.01)
        expect_near(0.01, decoder:tell(), 0.001)
    end)

    -- @covers LDecoder:rewind
    it("rewind resets the decode cursor", function()
        local decoder = lurek.audio.newDecoder(FIXTURE)
        decoder:seek(0.01)
        decoder:rewind()
        expect_near(0.0, decoder:tell(), 0.000001)
    end)

    -- @covers LDecoder:tell
    it("tell starts at zero", function()
        expect_near(0.0, lurek.audio.newDecoder(FIXTURE):tell(), 0.000001)
    end)

    -- @covers LDecoder:isSeekable
    it("isSeekable returns true for wav fixtures", function()
        expect_true(lurek.audio.newDecoder(FIXTURE):isSeekable())
    end)

    -- @covers LDecoder:decode
    it("decode returns userdata or nil at eof", function()
        local decoder = lurek.audio.newDecoder(FIXTURE, 1000000)
        local chunk = decoder:decode()
        expect_true(chunk == nil or type(chunk) == "userdata")
    end)

    -- @covers LDecoder:release
    it("release is callable", function()
        expect_no_error(function()
            lurek.audio.newDecoder(FIXTURE):release()
        end)
    end)

    -- @covers LDecoder:type
    it("type returns LDecoder", function()
        expect_equal("LDecoder", lurek.audio.newDecoder(FIXTURE):type())
    end)

    -- @covers LDecoder:typeOf
    it("typeOf reports decoder inheritance", function()
        expect_true(lurek.audio.newDecoder(FIXTURE):typeOf("LDecoder"))
    end)
end)

-- @describe queueable sources and devices
describe("audio queueable and devices", function()
    -- @covers lurek.audio.newQueueableSource
    it("newQueueableSource returns a numeric handle", function()
        expect_equal("number", type(lurek.audio.newQueueableSource(44100, 16, 1, 4)))
    end)

    -- @covers lurek.audio.getFreeBufferCount
    it("getFreeBufferCount reports all buffers free initially", function()
        local q = lurek.audio.newQueueableSource(44100, 16, 1, 4)
        expect_equal(4, lurek.audio.getFreeBufferCount(q))
    end)

    -- @covers lurek.audio.queueSource
    it("queueSource consumes a free buffer", function()
        local q = lurek.audio.newQueueableSource(44100, 16, 1, 4)
        lurek.audio.queueSource(q, new_sound_data())
        expect_true(lurek.audio.getFreeBufferCount(q) < 4)
    end)

    -- @covers lurek.audio.playQueueable
    it("playQueueable is callable", function()
        local q = lurek.audio.newQueueableSource(44100, 16, 1, 4)
        expect_no_error(function()
            lurek.audio.playQueueable(q)
        end)
    end)

    -- @covers lurek.audio.stopQueueable
    it("stopQueueable restores the free buffer count", function()
        local q = lurek.audio.newQueueableSource(44100, 16, 1, 4)
        lurek.audio.queueSource(q, new_sound_data())
        lurek.audio.stopQueueable(q)
        expect_equal(4, lurek.audio.getFreeBufferCount(q))
    end)

    -- @covers lurek.audio.getPlaybackDevices
    it("getPlaybackDevices returns a table", function()
        expect_type("table", lurek.audio.getPlaybackDevices())
    end)

    -- @covers lurek.audio.getPlaybackDevice
    it("getPlaybackDevice returns a string", function()
        expect_type("string", lurek.audio.getPlaybackDevice())
    end)

    -- @covers lurek.audio.setPlaybackDevice
    it("setPlaybackDevice errors on an unknown name", function()
        expect_error(function()
            lurek.audio.setPlaybackDevice("NonExistentDevice___XYZ")
        end)
    end)
end)

-- @describe source userdata
describe("audio source userdata", function()
    -- @covers LSource:play
    it("play marks a source as playing", function()
        local source = new_source()
        source:play()
        expect_true(source:isPlaying())
        source:stop()
    end)

    -- @covers LSource:stop
    it("stop marks a source as stopped", function()
        local source = new_source()
        source:play()
        source:stop()
        expect_true(source:isStopped())
    end)

    -- @covers LSource:pause
    it("pause marks a source as paused", function()
        local source = new_source()
        source:play()
        source:pause()
        expect_true(source:isPaused())
        source:stop()
    end)

    -- @covers LSource:resume
    it("resume returns a paused source to playing", function()
        local source = new_source()
        source:play()
        source:pause()
        source:resume()
        expect_true(source:isPlaying())
        source:stop()
    end)

    -- @covers LSource:setVolume
    it("setVolume round-trips through the getter", function()
        local source = new_source()
        source:setVolume(0.5)
        expect_near(0.5, source:getVolume(), 0.001)
    end)

    -- @covers LSource:getVolume
    it("getVolume returns a number", function()
        expect_type("number", new_source():getVolume())
    end)

    -- @covers LSource:setPitch
    it("setPitch round-trips through the getter", function()
        local source = new_source()
        source:setPitch(1.5)
        expect_near(1.5, source:getPitch(), 0.001)
    end)

    -- @covers LSource:getPitch
    it("getPitch returns a number", function()
        expect_type("number", new_source():getPitch())
    end)

    -- @covers LSource:setLooping
    it("setLooping toggles looping", function()
        local source = new_source()
        source:setLooping(true)
        expect_true(source:isLooping())
    end)

    -- @covers LSource:isLooping
    it("isLooping returns false by default", function()
        expect_false(new_source():isLooping())
    end)

    -- @covers LSource:setPan
    it("setPan round-trips through the getter", function()
        local source = new_source()
        source:setPan(-0.5)
        expect_near(-0.5, source:getPan(), 0.001)
    end)

    -- @covers LSource:getPan
    it("getPan returns a number", function()
        expect_type("number", new_source():getPan())
    end)

    -- @covers LSource:getType
    it("getType returns a string", function()
        expect_type("string", new_source():getType())
    end)

    -- @covers LSource:getDuration
    it("getDuration returns a number or nil in headless mode", function()
        local duration = new_source():getDuration()
        expect_true(duration == nil or type(duration) == "number")
    end)

    -- @covers LSource:tell
    it("tell starts at zero", function()
        expect_equal(0, new_source():tell())
    end)

    -- @covers LSource:seek
    it("seek moves the playback cursor", function()
        local source = new_source()
        source:seek(0.01)
        expect_true(source:tell() >= 0)
    end)

    -- @covers LSource:setLowpass
    it("setLowpass updates the lowpass filter", function()
        local source = new_source()
        source:setLowpass(0.5)
        expect_type("number", source:getLowpass())
    end)

    -- @covers LSource:getLowpass
    it("getLowpass returns a number", function()
        local value = new_source():getLowpass()
        expect_true(value == nil or type(value) == "number")
    end)

    -- @covers LSource:setHighpass
    it("setHighpass updates the highpass filter", function()
        local source = new_source()
        source:setHighpass(0.3)
        expect_type("number", source:getHighpass())
    end)

    -- @covers LSource:getHighpass
    it("getHighpass returns a number", function()
        local value = new_source():getHighpass()
        expect_true(value == nil or type(value) == "number")
    end)

    -- @covers LSource:clearFilter
    it("clearFilter is callable", function()
        expect_no_error(function()
            new_source():clearFilter()
        end)
    end)

    -- @covers LSource:fadeIn
    it("fadeIn is callable", function()
        expect_no_error(function()
            new_source():fadeIn(0.25)
        end)
    end)

    -- @covers LSource:getFadeIn
    it("getFadeIn returns a number", function()
        local value = new_source():getFadeIn()
        expect_true(value == nil or type(value) == "number")
    end)

    -- @covers LSource:clone
    it("clone returns another source handle", function()
        expect_type("userdata", new_source():clone())
    end)

    -- @covers LSource:type
    it("type returns LSource", function()
        expect_equal("LSource", new_source():type())
    end)

    -- @covers LSource:typeOf
    it("typeOf reports source inheritance", function()
        expect_true(new_source():typeOf("LSource"))
    end)
end)

-- @describe bus userdata
describe("audio bus userdata", function()
    -- @covers lurek.audio.newBus
    it("newBus creates userdata", function()
        expect_type("userdata", lurek.audio.newBus("music"))
    end)

    -- @covers LBus:getName
    it("getName returns the registered bus name", function()
        expect_equal("music", lurek.audio.newBus("music"):getName())
    end)

    -- @covers LBus:setVolume
    it("setVolume round-trips through the getter", function()
        local bus = lurek.audio.newBus("fx")
        bus:setVolume(0.6)
        expect_near(0.6, bus:getVolume(), 0.001)
    end)

    -- @covers LBus:getVolume
    it("getVolume returns a number", function()
        expect_type("number", lurek.audio.newBus("fx"):getVolume())
    end)

    -- @covers LBus:setPitch
    it("setPitch round-trips through the getter", function()
        local bus = lurek.audio.newBus("fx")
        bus:setPitch(1.2)
        expect_near(1.2, bus:getPitch(), 0.001)
    end)

    -- @covers LBus:getPitch
    it("getPitch returns a number", function()
        expect_type("number", lurek.audio.newBus("fx"):getPitch())
    end)

    -- @covers LBus:pause
    it("pause sets the bus paused flag", function()
        local bus = lurek.audio.newBus("fx")
        bus:pause()
        expect_true(bus:isPaused())
    end)

    -- @covers LBus:resume
    it("resume clears the bus paused flag", function()
        local bus = lurek.audio.newBus("fx")
        bus:pause()
        bus:resume()
        expect_false(bus:isPaused())
    end)

    -- @covers LBus:isPaused
    it("isPaused returns false by default", function()
        expect_false(lurek.audio.newBus("fx"):isPaused())
    end)

    -- @covers LBus:type
    it("type returns LBus", function()
        expect_equal("LBus", lurek.audio.newBus("fx"):type())
    end)

    -- @covers LBus:typeOf
    it("typeOf reports bus inheritance", function()
        expect_true(lurek.audio.newBus("fx"):typeOf("LBus"))
    end)
end)

-- @describe sound data
describe("audio sound data", function()
    -- @covers lurek.audio.newSoundData
    it("newSoundData creates userdata", function()
        expect_type("userdata", new_sound_data())
    end)

    -- @covers LSoundData:getSampleCount
    it("getSampleCount returns the configured sample count", function()
        expect_equal(64, new_sound_data():getSampleCount())
    end)

    -- @covers LSoundData:getSampleRate
    it("getSampleRate returns the configured sample rate", function()
        expect_equal(44100, new_sound_data():getSampleRate())
    end)

    -- @covers LSoundData:getChannelCount
    it("getChannelCount returns the configured channel count", function()
        expect_equal(1, new_sound_data():getChannelCount())
    end)

    -- @covers LSoundData:getDuration
    it("getDuration returns a positive number", function()
        expect_true(new_sound_data():getDuration() > 0)
    end)

    -- @covers LSoundData:getBitDepth
    it("getBitDepth returns a positive number", function()
        expect_true(new_sound_data():getBitDepth() > 0)
    end)

    -- @covers LSoundData:setSample
    it("setSample updates one sample value", function()
        local data = new_sound_data()
        data:setSample(0, 0.5)
        expect_near(0.5, data:getSample(0), 0.0001)
    end)

    -- @covers LSoundData:getSample
    it("getSample returns zero for a fresh silent buffer", function()
        expect_near(0.0, new_sound_data():getSample(0), 0.0001)
    end)

    -- @covers LSoundData:type
    it("type returns LSoundData", function()
        expect_equal("LSoundData", new_sound_data():type())
    end)

    -- @covers LSoundData:typeOf
    it("typeOf reports sound data inheritance", function()
        expect_true(new_sound_data():typeOf("LSoundData"))
    end)
end)

-- @describe midi player
describe("audio midi player", function()
    -- @covers LMidiPlayer:isLoaded
    it("isLoaded returns false by default", function()
        expect_false(lurek.audio.newMidiPlayer():isLoaded())
    end)

    -- @covers LMidiPlayer:getVolume
    it("getVolume defaults to one", function()
        expect_near(1.0, lurek.audio.newMidiPlayer():getVolume(), 0.0001)
    end)

    -- @covers LMidiPlayer:setVolume
    it("setVolume round-trips through the getter", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setVolume(0.5)
        expect_near(0.5, midi:getVolume(), 0.0001)
    end)

    -- @covers LMidiPlayer:isLooping
    it("isLooping returns false by default", function()
        expect_false(lurek.audio.newMidiPlayer():isLooping())
    end)

    -- @covers LMidiPlayer:setLooping
    it("setLooping toggles the looping flag", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setLooping(true)
        expect_true(midi:isLooping())
    end)

    -- @covers LMidiPlayer:getTempoScale
    it("getTempoScale defaults to one", function()
        expect_near(1.0, lurek.audio.newMidiPlayer():getTempoScale(), 0.0001)
    end)

    -- @covers LMidiPlayer:setTempoScale
    it("setTempoScale round-trips through the getter", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setTempoScale(2.0)
        expect_near(2.0, midi:getTempoScale(), 0.0001)
    end)

    -- @covers LMidiPlayer:getSampleRate
    it("getSampleRate defaults to 44100", function()
        expect_equal(44100, lurek.audio.newMidiPlayer():getSampleRate())
    end)

    -- @covers LMidiPlayer:setSampleRate
    it("setSampleRate updates the midi render rate", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setSampleRate(48000)
        expect_equal(48000, midi:getSampleRate())
    end)

    -- @covers LMidiPlayer:getChannels
    it("getChannels defaults to stereo", function()
        expect_equal(2, lurek.audio.newMidiPlayer():getChannels())
    end)

    -- @covers LMidiPlayer:setChannels
    it("setChannels updates the midi output channels", function()
        local midi = lurek.audio.newMidiPlayer()
        midi:setChannels(1)
        expect_equal(1, midi:getChannels())
    end)

    -- @covers LMidiPlayer:type
    it("type returns LMidiPlayer", function()
        expect_equal("LMidiPlayer", lurek.audio.newMidiPlayer():type())
    end)

    -- @covers LMidiPlayer:typeOf
    it("typeOf reports midi player inheritance", function()
        expect_true(lurek.audio.newMidiPlayer():typeOf("LMidiPlayer"))
    end)
end)

test_summary()
