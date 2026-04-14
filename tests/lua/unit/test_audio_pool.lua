-- Tests for SoundPool — polyphonic sound source management.
-- No audio hardware required; the pool manages source allocation.

-- Helper: path to the standard test WAV fixture
local WAVE = "tests/fixtures/sine_mono_44100.wav"

-- @description Covers suite: lurek.audio.newPool.
describe("lurek.audio.newPool", function()
    -- @covers lurek.audio.newPool
    it("creates a sound pool and returns a Pool object", function()
        local pool = lurek.audio.newPool(WAVE, 4)
        expect_not_nil(pool)
    end)

    -- @covers lurek.audio.newPool
    it("errors on empty path", function()
        expect_error(function()
            lurek.audio.newPool("", 4)
        end, "invalid path")
    end)

    -- @covers lurek.audio.newPool
    it("errors on zero voice count", function()
        expect_error(function()
            lurek.audio.newPool(WAVE, 0)
        end, "invalid voice count")
    end)
end)

-- @description Covers suite: Pool:play.
describe("Pool:play", function()
    -- @covers lurek.audio.newPool
    it("play returns a numeric source id", function()
        local pool = lurek.audio.newPool(WAVE, 2)
        local id = pool:play()
        expect_type("number", id)
    end)

    -- @covers lurek.audio.newPool
    it("play can be called multiple times up to voice count", function()
        local pool = lurek.audio.newPool(WAVE, 3)
        local id1 = pool:play()
        local id2 = pool:play()
        local id3 = pool:play()
        expect_type("number", id1)
        expect_type("number", id2)
        expect_type("number", id3)
    end)
end)

-- @description Covers suite: Pool:stopAll.
describe("Pool:stopAll", function()
    -- @covers lurek.audio.newPool
    it("stopAll does not error when pool has playing sources", function()
        local pool = lurek.audio.newPool(WAVE, 2)
        pool:play()
        pool:play()
        pool:stopAll()  -- should not raise
    end)

    -- @covers lurek.audio.newPool
    it("stopAll does not error on an idle pool", function()
        local pool = lurek.audio.newPool(WAVE, 2)
        pool:stopAll()
    end)
end)

-- @description Covers suite: Pool:setVolume.
describe("Pool:setVolume", function()
    -- @covers lurek.audio.newPool
    it("setVolume sets volume for all pool sources", function()
        local pool = lurek.audio.newPool(WAVE, 2)
        pool:setVolume(0.5)  -- should not raise
    end)
end)

-- @description Covers suite: Pool:setBus.
describe("Pool:setBus", function()
    -- @covers lurek.audio.newPool
    it("setBus routes all pool sources to a named bus", function()
        lurek.audio.create_bus("pool_test_bus")
        local pool = lurek.audio.newPool(WAVE, 2)
        pool:setBus("pool_test_bus")  -- should not raise
    end)

    -- @covers lurek.audio.newPool
    it("setBus errors if bus does not exist", function()
        local pool = lurek.audio.newPool(WAVE, 2)
        expect_error(function()
            pool:setBus("nonexistent_pool_bus")
        end, "bus not found")
    end)
end)

-- @description Covers suite: Pool:release.
describe("Pool:release", function()
    -- @covers lurek.audio.newPool
    it("release frees all sources without error", function()
        local pool = lurek.audio.newPool(WAVE, 2)
        pool:play()
        pool:release()  -- should not raise
    end)
end)

-- @description Covers suite: Pool:getVoiceCount.
describe("Pool:getVoiceCount", function()
    -- @covers lurek.audio.newPool
    it("returns the configured voice count", function()
        local pool = lurek.audio.newPool(WAVE, 6)
        expect_equal(6, pool:getVoiceCount())
    end)
end)

test_summary()
