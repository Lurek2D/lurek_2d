--!lua
-- tests/lua/unit/audio_manager_test.lua
-- Lua‑first unit test for the high‑level audio manager API.

local lurk = require('lurek')
local audio = lurk.audio.manager

-- Test playing a music track with a fade‑in of 0.0 seconds.
local ok, err = pcall(function()
    audio.playMusic('test_music.ogg', { group = 'music', fadeIn = 0 })
    -- Immediately stop it.
    audio.stopMusic({ fadeOut = 0 })
end)
assert(ok, err)

-- Test cross‑fade between two tracks.
ok, err = pcall(function()
    audio.playMusic('track_a.ogg', { group = 'music', fadeIn = 0 })
    audio.crossfade('track_b.ogg', { duration = 1.0, group = 'music' })
end)
assert(ok, err)

-- Test group volume control.
ok, err = pcall(function()
    audio.setGroupVolume('music', 0.5)
    audio.muteGroup('music')
    audio.unmuteGroup('music')
end)
assert(ok, err)

-- Test global pause/resume.
ok, err = pcall(function()
    audio.pauseAll()
    audio.resumeAll()
end)
assert(ok, err)

print('audio_manager_test passed')
test_summary()
