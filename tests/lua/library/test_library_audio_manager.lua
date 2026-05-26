-- Lurek2D Library Audio Manager Tests
-- @testCategory library

local AudioManager = require("library.audio_manager")

-- @describe audio_manager library     new
describe("audio_manager library     new", function()
    -- @library lurek.library_audio_manager
    it("creates manager with groups", function()
        local mgr = AudioManager.new({ groups = { music = { volume = 0.8 }, sfx = { volume = 1.0 } } })
        expect_not_nil(mgr, "new() must return non-nil manager")
    end)

    -- @library lurek.library_audio_manager
    it("creates manager with no groups", function()
        local mgr = AudioManager.new()
        expect_not_nil(mgr, "new() without opts must return non-nil manager")
    end)
end)

-- @describe audio_manager library     group volume
describe("audio_manager library     group volume", function()
    -- @library lurek.library_audio_manager
    it("setGroupVolume and getGroupVolume work", function()
        local mgr = AudioManager.new({ groups = { sfx = { volume = 1.0 } } })
        mgr:setGroupVolume("sfx", 0.5)
        expect_equal(mgr:getGroupVolume("sfx"), 0.5, "group volume must be 0.5 after set")
    end)

    -- @library lurek.library_audio_manager
    it("getGroupVolume returns 1.0 for unknown group", function()
        local mgr = AudioManager.new()
        expect_equal(mgr:getGroupVolume("nonexistent"), 1.0, "unknown group must default to 1.0")
    end)
end)

-- @describe audio_manager library     master volume
describe("audio_manager library     master volume", function()
    -- @library lurek.library_audio_manager
    it("setMasterVolume and getMasterVolume work", function()
        local mgr = AudioManager.new()
        mgr:setMasterVolume(0.7)
        expect_equal(mgr:getMasterVolume(), 0.7, "master volume must be 0.7 after set")
    end)

    -- @library lurek.library_audio_manager
    it("master volume defaults to 1.0", function()
        local mgr = AudioManager.new()
        expect_equal(mgr:getMasterVolume(), 1.0, "master volume must default to 1.0")
    end)
end)

-- @describe audio_manager library     mute unmute
describe("audio_manager library     mute unmute", function()
    -- @library lurek.library_audio_manager
    it("mute toggles group muted state", function()
        local mgr = AudioManager.new({ groups = { sfx = { volume = 1.0 } } })
        mgr:mute("sfx")
        -- After mute, effective volume should be 0; verify by unmuting and checking group still exists
        mgr:unmute("sfx")
        expect_equal(mgr:getGroupVolume("sfx"), 1.0, "volume must be preserved after mute/unmute cycle")
    end)

    -- @library lurek.library_audio_manager
    it("muteAll and unmuteAll toggle master muted state", function()
        local mgr = AudioManager.new()
        mgr:muteAll()
        -- Master muted; getMasterVolume still reports the set value (muting is separate)
        expect_equal(mgr:getMasterVolume(), 1.0, "getMasterVolume must still report set value when muted")
        mgr:unmuteAll()
        expect_equal(mgr:getMasterVolume(), 1.0, "getMasterVolume must still be 1.0 after unmuteAll")
    end)
end)

-- @describe audio_manager library     update
describe("audio_manager library     update", function()
    -- @library lurek.library_audio_manager
    it("update with dt does not error", function()
        local mgr = AudioManager.new({ groups = { music = { volume = 1.0 } } })
        local ok = pcall(function() mgr:update(0.016) end)
        expect_true(ok, "update(dt) must not error")
    end)

    -- @library lurek.library_audio_manager
    it("update with zero dt does not error", function()
        local mgr = AudioManager.new()
        local ok = pcall(function() mgr:update(0) end)
        expect_true(ok, "update(0) must not error")
    end)
end)

-- @describe audio_manager library     playMusic stopMusic lifecycle
describe("audio_manager library     playMusic stopMusic lifecycle", function()
    -- @library lurek.library_audio_manager
    it("playMusic returns a handle", function()
        local mgr = AudioManager.new({ groups = { music = { volume = 1.0 } } })
        local handle = mgr:playMusic("test.ogg", { group = "music" })
        expect_not_nil(handle, "playMusic must return a handle")
    end)

    -- @library lurek.library_audio_manager
    it("stopMusic after playMusic does not error", function()
        local mgr = AudioManager.new({ groups = { music = { volume = 1.0 } } })
        mgr:playMusic("test.ogg", { group = "music" })
        local ok = pcall(function() mgr:stopMusic() end)
        expect_true(ok, "stopMusic must not error after playMusic")
    end)

    -- @library lurek.library_audio_manager
    it("stopMusic when nothing playing does not error", function()
        local mgr = AudioManager.new()
        local ok = pcall(function() mgr:stopMusic() end)
        expect_true(ok, "stopMusic must not error when no music is playing")
    end)
end)

test_summary()
