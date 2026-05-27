--- Example usage for library.audio_manager.
-- Demonstrates music playback, crossfade, SFX pooling, volume groups,
-- mute/unmute, and pause/resume.
-- @module example.audio_manager

package.path = "library/?.lua;library/?/init.lua;" .. package.path
local AudioManager = require("library.audio_manager")

print("[example.audio_manager] === Setup: create manager with groups ===")

local audio = AudioManager.new({
    groups = {
        music   = { volume = 0.7 },
        sfx     = { volume = 1.0 },
        ui      = { volume = 0.8 },
        ambient = { volume = 0.5 },
    }
})

print(string.format("  master=%.1f, music=%.1f, sfx=%.1f, ui=%.1f, ambient=%.1f",
    audio:getMasterVolume(),
    audio:getGroupVolume("music"),
    audio:getGroupVolume("sfx"),
    audio:getGroupVolume("ui"),
    audio:getGroupVolume("ambient")))

print("[example.audio_manager] === Scenario 1: play music with fade-in ===")

local handle = audio:playMusic("assets/music/battle.ogg", {
    group  = "music",
    fadeIn = 1.0,
})
print(string.format("  music handle: %s", tostring(handle)))

-- Simulate 5 frames at 0.25s each to show fade progress
for i = 1, 4 do
    audio:update(0.25)
end
print("  fade-in complete after 1.0s of updates")

print("[example.audio_manager] === Scenario 2: crossfade to new track ===")

audio:crossfade("assets/music/explore.ogg", { duration = 1.5 })
-- Simulate crossfade over 6 frames at 0.25s
for i = 1, 6 do
    audio:update(0.25)
end
print("  crossfade complete: now playing explore.ogg")

print("[example.audio_manager] === Scenario 3: SFX with pooling ===")

-- Play the same sound multiple times with maxInstances = 3
local sfx1 = audio:playSfx("assets/sfx/hit.wav", { group = "sfx", maxInstances = 3 })
local sfx2 = audio:playSfx("assets/sfx/hit.wav", { group = "sfx", maxInstances = 3 })
local sfx3 = audio:playSfx("assets/sfx/hit.wav", { group = "sfx", maxInstances = 3 })
print(string.format("  3 hit sounds playing: %s, %s, %s",
    tostring(sfx1), tostring(sfx2), tostring(sfx3)))

-- Fourth play replaces the oldest
local sfx4 = audio:playSfx("assets/sfx/hit.wav", { group = "sfx", maxInstances = 3 })
print(string.format("  4th hit sound (replaced oldest): %s", tostring(sfx4)))

-- Different sound, no pool limit
local coin = audio:playSfx("assets/sfx/coin.wav", { group = "sfx" })
print(string.format("  coin sound: %s", tostring(coin)))

print("[example.audio_manager] === Scenario 4: volume control ===")

audio:setGroupVolume("music", 0.5)
print(string.format("  music volume set to %.1f", audio:getGroupVolume("music")))

audio:setMasterVolume(0.8)
print(string.format("  master volume set to %.1f", audio:getMasterVolume()))

print("[example.audio_manager] === Scenario 5: mute/unmute ===")

audio:mute("sfx")
print(string.format("  sfx muted, effective sfx volume: silent"))

audio:unmute("sfx")
print(string.format("  sfx unmuted, group volume: %.1f", audio:getGroupVolume("sfx")))

audio:muteAll()
print("  all muted (master mute)")

audio:unmuteAll()
print("  all unmuted")

print("[example.audio_manager] === Scenario 6: pause/resume ===")

audio:pauseAll()
print("  all audio paused")

audio:resumeAll()
print("  all audio resumed")

print("[example.audio_manager] === Scenario 7: stop music with fade-out ===")

audio:playMusic("assets/music/menu.ogg", { group = "music" })
audio:stopMusic({ fadeOut = 2.0 })
-- Simulate fade-out over 8 frames at 0.25s
for i = 1, 8 do
    audio:update(0.25)
end
print("  music stopped after 2.0s fade-out")

print("[example.audio_manager] === Done ===")
