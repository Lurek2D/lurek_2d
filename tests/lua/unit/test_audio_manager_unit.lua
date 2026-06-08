--!lua
-- tests/lua/unit/test_audio_manager_unit.lua
-- Lua-first unit test for the high-level audio manager API.

-- @describe High-level audio manager API
describe("High-level audio manager API", function()
    -- @covers lurek.audio.manager.playMusic
    -- @covers lurek.audio.manager.stopMusic
    it("plays and stops music", function()
        expect_no_error(function()
            lurek.audio.manager.playMusic('test_music.ogg', { group = 'music', fadeIn = 0 })
            lurek.audio.manager.stopMusic({ fadeOut = 0 })
        end)
    end)

    -- @covers lurek.audio.manager.crossfade
    it("crossfades between two tracks", function()
        expect_no_error(function()
            lurek.audio.manager.playMusic('track_a.ogg', { group = 'music', fadeIn = 0 })
            lurek.audio.manager.crossfade('track_b.ogg', { duration = 1.0, group = 'music' })
        end)
    end)

    -- @covers lurek.audio.manager.setGroupVolume
    -- @covers lurek.audio.manager.muteGroup
    -- @covers lurek.audio.manager.unmuteGroup
    it("controls group volume and mute state", function()
        expect_no_error(function()
            lurek.audio.manager.setGroupVolume('music', 0.5)
            lurek.audio.manager.muteGroup('music')
            lurek.audio.manager.unmuteGroup('music')
        end)
    end)

    -- @covers lurek.audio.manager.pauseAll
    -- @covers lurek.audio.manager.resumeAll
    it("pauses and resumes all audio globally", function()
        expect_no_error(function()
            lurek.audio.manager.pauseAll()
            lurek.audio.manager.resumeAll()
        end)
    end)
end)
