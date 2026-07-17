-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_audio_core_unit.lua
do
-- Canonical unit coverage for lurek.audio.

local FIXTURE = "tests/fixtures/sine_mono_44100.wav"
local GENERATED_WAV = "work/audio_unit/generated.wav"

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

-- @describe source helper functions
describe("audio source helper functions", function()
    -- @covers lurek.audio.setLooping
    it("setLooping updates a source looping flag", function()
        local source = new_source()
        lurek.audio.setLooping(source, true)
        expect_true(source:isLooping())
    end)

    -- @covers lurek.audio.isLooping
    it("isLooping reads the source looping flag", function()
        local source = new_source()
        source:setLooping(true)
        expect_true(lurek.audio.isLooping(source))
    end)

    -- @covers lurek.audio.playLooping
    it("playLooping enables looping while starting playback", function()
        local source = new_source()
        expect_no_error(function()
            lurek.audio.playLooping(source)
        end)
        expect_true(source:isLooping())
    end)

    -- @covers lurek.audio.setPan
    it("setPan updates stereo pan through the global helper", function()
        local source = new_source()
        lurek.audio.setPan(source, -0.25)
        expect_near(-0.25, source:getPan(), 0.001)
    end)

    -- @covers lurek.audio.getPan
    it("getPan returns the current stereo pan", function()
        local source = new_source()
        source:setPan(0.4)
        expect_near(0.4, lurek.audio.getPan(source), 0.001)
    end)

    -- @covers lurek.audio.getSourceType
    it("getSourceType reports the underlying source kind", function()
        expect_equal("static", lurek.audio.getSourceType(new_source()))
    end)

    -- @covers lurek.audio.clone
    it("clone creates a second source handle", function()
        local clone = lurek.audio.clone(new_source())
        expect_equal("LSource", clone:type())
    end)

    -- @covers lurek.audio.pauseAll
    it("pauseAll pauses active sources", function()
        local source = new_source()
        source:play()
        lurek.audio.pauseAll()
        expect_true(source:isPaused())
    end)

    -- @covers lurek.audio.stopAll
    it("stopAll stops active sources", function()
        local source = new_source()
        source:play()
        lurek.audio.stopAll()
        expect_true(source:isStopped())
    end)

    -- @covers lurek.audio.resumeAll
    it("resumeAll resumes paused sources", function()
        local source = new_source()
        source:play()
        source:pause()
        lurek.audio.resumeAll()
        expect_false(source:isPaused())
    end)

    -- @covers lurek.audio.release
    it("release frees a live source handle", function()
        expect_true(lurek.audio.release(new_source()))
    end)

    -- @covers lurek.audio.setSourceBus
    it("setSourceBus routes a source through a named bus", function()
        local source = new_source()
        local bus = lurek.audio.newBus("music")
        lurek.audio.setSourceBus(source, bus)
        expect_equal("music", lurek.audio.getSourceBus(source):getName())
    end)

    -- @covers lurek.audio.getSourceBus
    it("getSourceBus returns the bus assigned to a source", function()
        local source = new_source()
        local bus = lurek.audio.newBus("sfx")
        lurek.audio.setSourceBus(source, bus)
        expect_equal("sfx", lurek.audio.getSourceBus(source):getName())
    end)

    -- @covers lurek.audio.getDuration
    it("getDuration returns a duration for a loaded source", function()
        local duration = lurek.audio.getDuration(new_source())
        expect_true(duration == nil or duration > 0)
    end)

    -- @covers lurek.audio.tell
    it("tell reads the current source playback position", function()
        expect_equal(0, lurek.audio.tell(new_source()))
    end)

    -- @covers lurek.audio.seek
    it("seek updates the source playback position", function()
        local source = new_source()
        lurek.audio.seek(source, 0.01)
        expect_true(source:tell() >= 0)
    end)

    -- @covers lurek.audio.setLowpass
    it("setLowpass updates the source lowpass filter", function()
        local source = new_source()
        lurek.audio.setLowpass(source, 2400)
        expect_type("number", source:getLowpass())
    end)

    -- @covers lurek.audio.setHighpass
    it("setHighpass updates the source highpass filter", function()
        local source = new_source()
        lurek.audio.setHighpass(source, 800)
        expect_type("number", source:getHighpass())
    end)

    -- @covers lurek.audio.getLowpass
    it("getLowpass returns the source lowpass cutoff", function()
        local source = new_source()
        source:setLowpass(1500)
        expect_equal(1500, lurek.audio.getLowpass(source))
    end)

    -- @covers lurek.audio.getHighpass
    it("getHighpass returns the source highpass cutoff", function()
        local source = new_source()
        source:setHighpass(300)
        expect_equal(300, lurek.audio.getHighpass(source))
    end)

    -- @covers lurek.audio.clearFilter
    it("clearFilter removes source filters through the global helper", function()
        local source = new_source()
        source:setLowpass(1200)
        lurek.audio.clearFilter(source)
        expect_nil(source:getLowpass())
    end)

    -- @covers lurek.audio.fadeIn
    it("fadeIn stores the source fade-in duration", function()
        local source = new_source()
        lurek.audio.fadeIn(source, 0.2)
        expect_near(0.2, source:getFadeIn(), 0.001)
    end)

    -- @covers lurek.audio.getFadeIn
    it("getFadeIn returns the source fade-in duration", function()
        local source = new_source()
        source:fadeIn(0.35)
        expect_near(0.35, lurek.audio.getFadeIn(source), 0.001)
    end)
end)

-- @describe spatial and helper state
describe("audio spatial and helper state", function()
    -- @covers lurek.audio.setPosition
    it("setPosition updates the 3d position of a source", function()
        local source = new_source()
        lurek.audio.setPosition(source, 1, 2, 3)
        local x, y, z = lurek.audio.getPosition(source)
        expect_near(1, x, 0.001)
        expect_near(2, y, 0.001)
        expect_near(3, z, 0.001)
    end)

    -- @covers lurek.audio.getPosition
    it("getPosition returns the current source position", function()
        local source = new_source()
        lurek.audio.setPosition(source, 4, 5, 6)
        local x, y, z = lurek.audio.getPosition(source)
        expect_near(4, x, 0.001)
        expect_near(5, y, 0.001)
        expect_near(6, z, 0.001)
    end)

    -- @covers lurek.audio.setVelocity
    it("setVelocity updates the source velocity vector", function()
        local source = new_source()
        lurek.audio.setVelocity(source, 7, 8, 9)
        local x, y, z = lurek.audio.getVelocity(source)
        expect_near(7, x, 0.001)
        expect_near(8, y, 0.001)
        expect_near(9, z, 0.001)
    end)

    -- @covers lurek.audio.getVelocity
    it("getVelocity returns the current source velocity", function()
        local source = new_source()
        lurek.audio.setVelocity(source, 2, 3, 4)
        local x, y, z = lurek.audio.getVelocity(source)
        expect_near(2, x, 0.001)
        expect_near(3, y, 0.001)
        expect_near(4, z, 0.001)
    end)

    -- @covers lurek.audio.setOrientation
    it("setOrientation updates the source orientation vectors", function()
        local source = new_source()
        lurek.audio.setOrientation(source, 1, 0, 0, 0, 1, 0)
        local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(source)
        expect_near(1, fx, 0.001)
        expect_near(0, fy, 0.001)
        expect_near(0, fz, 0.001)
        expect_near(0, ux, 0.001)
        expect_near(1, uy, 0.001)
        expect_near(0, uz, 0.001)
    end)

    -- @covers lurek.audio.getOrientation
    it("getOrientation returns the current source orientation", function()
        local source = new_source()
        lurek.audio.setOrientation(source, 0, 1, 0, 0, 0, 1)
        local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation(source)
        expect_near(0, fx, 0.001)
        expect_near(1, fy, 0.001)
        expect_near(0, fz, 0.001)
        expect_near(0, ux, 0.001)
        expect_near(0, uy, 0.001)
        expect_near(1, uz, 0.001)
    end)

    -- @covers lurek.audio.create_bus
    it("create_bus creates a named bus that can be configured later", function()
        expect_no_error(function()
            lurek.audio.create_bus("dialog")
            lurek.audio.set_bus_volume("dialog", 0.7)
        end)
    end)

    -- @covers lurek.audio.set_bus_volume
    it("set_bus_volume updates a named bus without error", function()
        lurek.audio.create_bus("ambience")
        expect_no_error(function()
            lurek.audio.set_bus_volume("ambience", 0.5)
        end)
    end)

    -- @covers lurek.audio.saveWAV
    it("saveWAV writes wav bytes for a sound buffer", function()
        lurek.audio.saveWAV(new_sound_data(), GENERATED_WAV)
        expect_true(lurek.audio.newSoundData(GENERATED_WAV, 44100, 1):getSampleCount() > 0)
    end)

    -- @covers lurek.audio.getStereoWidth
    it("getStereoWidth returns the configured stereo width", function()
        local source = new_source()
        lurek.audio.setStereoWidth(source, 0.5)
        expect_near(0.5, lurek.audio.getStereoWidth(source), 0.001)
    end)

    -- @covers lurek.audio.setRandomPitch
    it("setRandomPitch accepts a valid pitch range", function()
        expect_no_error(function()
            lurek.audio.setRandomPitch(new_source(), 0.9, 1.1)
        end)
    end)

    -- @covers lurek.audio.clearRandomPitch
    it("clearRandomPitch removes a configured pitch range", function()
        local source = new_source()
        lurek.audio.setRandomPitch(source, 0.8, 1.2)
        expect_no_error(function()
            lurek.audio.clearRandomPitch(source)
        end)
    end)

    -- @covers lurek.audio.getBusPeak
    it("getBusPeak returns a numeric peak meter value", function()
        lurek.audio.create_bus("ui")
        expect_type("number", lurek.audio.getBusPeak("ui"))
    end)

    -- @covers lurek.audio.getBusRms
    it("getBusRms returns a numeric rms meter value", function()
        lurek.audio.create_bus("voice")
        expect_type("number", lurek.audio.getBusRms("voice"))
    end)

    -- @covers lurek.audio.newPool
    it("newPool creates a sound pool with the requested voice count", function()
        expect_equal(3, lurek.audio.newPool(FIXTURE, 3):getVoiceCount())
    end)

    -- @covers lurek.audio.setJudgementWindows
    it("setJudgementWindows updates the shared beat-clock windows", function()
        lurek.audio.setJudgementWindows({ perfect = 0.01, great = 0.02, good = 0.05 })
        local windows = lurek.audio.getJudgementWindows()
        expect_near(0.01, windows.perfect, 0.0001)
        expect_near(0.02, windows.great, 0.0001)
        expect_near(0.05, windows.good, 0.0001)
    end)

    -- @covers lurek.audio.getJudgementWindows
    it("getJudgementWindows returns the active beat-clock windows", function()
        local windows = lurek.audio.getJudgementWindows()
        expect_type("number", windows.perfect)
        expect_type("number", windows.great)
        expect_type("number", windows.good)
    end)

    -- @covers lurek.audio.setMuted
    it("setMuted pauses active audio globally", function()
        local source = new_source()
        source:play()
        lurek.audio.setMuted(true)
        expect_true(lurek.audio.isMuted())
    end)

    -- @covers lurek.audio.isMuted
    it("isMuted reflects the current global audio activity", function()
        expect_true(lurek.audio.isMuted())
    end)

    -- @covers lurek.audio.stopMusic
    it("stopMusic stops active sources through the music helper", function()
        local source = new_source()
        source:play()
        lurek.audio.stopMusic(0.0)
        expect_true(source:isStopped())
    end)

    -- @covers lurek.audio.playSfx
    it("playSfx creates and returns a source handle", function()
        local source = lurek.audio.playSfx(FIXTURE, { volume = 0.4, loop = false })
        expect_equal("LSource", source:type())
    end)

    -- @covers lurek.audio.manager.pauseAll
    it("manager.pauseAll pauses active sources", function()
        local source = new_source()
        source:play()
        lurek.audio.manager.pauseAll()
        expect_true(source:isPaused())
    end)

    -- @covers lurek.audio.manager.resumeAll
    it("manager.resumeAll resumes paused sources", function()
        local source = new_source()
        source:play()
        source:pause()
        lurek.audio.manager.resumeAll()
        expect_false(source:isPaused())
    end)

    -- @covers lurek.audio.manager.playMusic
    it("manager.playMusic creates a looping grouped source", function()
        local source = lurek.audio.manager.playMusic(FIXTURE, {
            group = "unit-music",
            fadeIn = 0.2,
            volume = 0.6,
        })
        expect_equal("LSource", source:type())
        expect_true(source:isLooping())
        expect_near(0.2, source:getFadeIn(), 0.001)
        source:stop()
    end)

    -- @covers lurek.audio.manager.setGroupVolume
    it("manager.setGroupVolume updates a named group", function()
        lurek.audio.manager.setGroupVolume("unit-group", 0.45)
        local source = lurek.audio.manager.playMusic(FIXTURE, { group = "unit-group" })
        expect_near(0.45, lurek.audio.getSourceBus(source):getVolume(), 0.001)
        source:stop()
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

    -- @covers LSource:isPlaying
    it("isPlaying returns true while a source is active", function()
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

    -- @covers LSource:isPaused
    it("isPaused returns true for a paused source", function()
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

    -- @covers LSource:isStopped
    it("isStopped returns true after stopping a source", function()
        local source = new_source()
        source:play()
        source:stop()
        expect_true(source:isStopped())
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

    -- @covers LBus:setDuckTarget
    it("setDuckTarget configures ducking without error", function()
        local bus = lurek.audio.newBus("voice")
        lurek.audio.newBus("music")
        expect_no_error(function()
            bus:setDuckTarget("music", 0.5)
        end)
    end)

    -- @covers LBus:clearDuck
    it("clearDuck removes ducking without error", function()
        local bus = lurek.audio.newBus("voice")
        lurek.audio.newBus("music")
        bus:setDuckTarget("music", 0.5)
        expect_no_error(function()
            bus:clearDuck()
        end)
    end)

    -- @covers LBus:getPeak
    it("getPeak returns a numeric bus meter value", function()
        expect_type("number", lurek.audio.newBus("mix"):getPeak())
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

    -- @covers LSoundData:drawWaveform
    it("drawWaveform paints waveform pixels into an image buffer", function()
        local data = new_sound_data()
        data:setSample(0, 1.0)
        local img = lurek.image.newImageData(16, 16)
        data:drawWaveform(img, 0, 0, 16, 16, 255, 0, 0, 255)
        local r, g, b, a = img:getPixel(0, 8)
        expect_true(r > 0 or a > 0)
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

-- @describe sound pool
describe("audio sound pool", function()
    -- @covers LSoundPool:play
    it("play returns a numeric source id from the pool", function()
        expect_type("number", lurek.audio.newPool(FIXTURE, 2):play())
    end)

    -- @covers LSoundPool:stopAll
    it("stopAll is callable for an allocated pool", function()
        expect_no_error(function()
            lurek.audio.newPool(FIXTURE, 2):stopAll()
        end)
    end)

    -- @covers LSoundPool:setVolume
    it("setVolume is callable for an allocated pool", function()
        expect_no_error(function()
            lurek.audio.newPool(FIXTURE, 2):setVolume(0.4)
        end)
    end)

    -- @covers LSoundPool:setBus
    it("setBus routes pool voices through a named bus", function()
        lurek.audio.create_bus("pool-bus")
        expect_no_error(function()
            lurek.audio.newPool(FIXTURE, 2):setBus("pool-bus")
        end)
    end)

    -- @covers LSoundPool:release
    it("release frees all pool voices without error", function()
        expect_no_error(function()
            lurek.audio.newPool(FIXTURE, 2):release()
        end)
    end)

    -- @covers LSoundPool:getVoiceCount
    it("getVoiceCount returns the configured pool size", function()
        expect_equal(2, lurek.audio.newPool(FIXTURE, 2):getVoiceCount())
    end)

    -- @covers LSoundPool:type
    it("type returns LSoundPool", function()
        expect_equal("LSoundPool", lurek.audio.newPool(FIXTURE, 2):type())
    end)

    -- @covers LSoundPool:typeOf
    it("typeOf reports sound pool inheritance", function()
        expect_true(lurek.audio.newPool(FIXTURE, 2):typeOf("LSoundPool"))
    end)
end)

-- @describe beat clock helpers
describe("audio beat clock helpers", function()
    -- @covers LBeatClock:bpm
    it("bpm returns the configured tempo", function()
        expect_near(120.0, lurek.audio.newBeatClock(120.0, 4):bpm(), 0.0001)
    end)

    -- @covers LBeatClock:getBar
    it("getBar returns a numeric bar index", function()
        local clock = lurek.audio.newBeatClock(60.0, 4)
        clock:start()
        clock:update(4.1)
        expect_type("number", clock:getBar())
    end)

    -- @covers LBeatClock:getPhase
    it("getPhase returns a numeric subdivision phase", function()
        local clock = lurek.audio.newBeatClock(120.0, 4)
        clock:start()
        clock:update(0.2)
        expect_type("number", clock:getPhase(8))
    end)

    -- @covers LBeatClock:beatTimeRemaining
    it("beatTimeRemaining returns a numeric countdown", function()
        local clock = lurek.audio.newBeatClock(120.0, 4)
        clock:start()
        expect_type("number", clock:beatTimeRemaining(8))
    end)

    -- @covers LBeatClock:nearestBeat
    it("nearestBeat returns the nearest subdivision and timing error", function()
        local clock = lurek.audio.newBeatClock(120.0, 4)
        clock:start()
        local nearest, err = clock:nearestBeat(8)
        expect_type("number", nearest)
        expect_type("number", err)
    end)
end)
end
-- END test_audio_core_unit.lua

test_summary()
