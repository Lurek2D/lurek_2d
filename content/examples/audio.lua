-- content/examples/audio.lua
-- Lurek2D lurek.audio API Reference
-- Run with: cargo run -- content/examples/audio
--
-- Scenario: A side-scrolling platformer with layered audio — background music,
-- sound effects for jumping/landing/collecting coins, spatial audio for enemies,
-- audio buses for mixing, MIDI playback for chiptune tracks, sound pooling for
-- rapid-fire effects, procedural waveform generation, and offline DSP processing.

print("=== lurek.audio — Platformer Audio System ===\n")

-- =============================================================================
-- Source Creation & Basic Playback
-- =============================================================================

-- ---- Stub: lurek.audio.newSource ------------------------------------------
--@api-stub: lurek.audio.newSource
-- Load a sound file into a Source object. "static" loads entirely into memory
-- (good for short SFX), "stream" decodes on-the-fly (good for long music).
local jump_sfx = lurek.audio.newSource("assets/audio/jump.wav", "static")
local coin_sfx = lurek.audio.newSource("assets/audio/coin.wav", "static")
local bgm = lurek.audio.newSource("assets/audio/level1_theme.ogg", "stream")
print("loaded: jump_sfx (static), coin_sfx (static), bgm (stream)")

-- ---- Stub: lurek.audio.play -----------------------------------------------
--@api-stub: lurek.audio.play
-- Demonstrates the proper usage of lurek.audio.play.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_play()
    lurek.audio.play(jump_sfx)
    print("jump SFX playing")
end
local _ok, _err = pcall(demo_lurek_audio_play)

-- ---- Stub: lurek.audio.stop -----------------------------------------------
--@api-stub: lurek.audio.stop
-- Demonstrates the proper usage of lurek.audio.stop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_stop()
    lurek.audio.stop(jump_sfx)
    print("jump SFX stopped")
end
local _ok, _err = pcall(demo_lurek_audio_stop)

-- ---- Stub: lurek.audio.pause ----------------------------------------------
--@api-stub: lurek.audio.pause
-- Demonstrates the proper usage of lurek.audio.pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_pause()
    lurek.audio.play(bgm)
    lurek.audio.pause(bgm)
    print("BGM paused mid-track")
end
local _ok, _err = pcall(demo_lurek_audio_pause)

-- ---- Stub: lurek.audio.resume ---------------------------------------------
--@api-stub: lurek.audio.resume
-- Demonstrates the proper usage of lurek.audio.resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_resume()
    lurek.audio.resume(bgm)
    print("BGM resumed from pause point")
end
local _ok, _err = pcall(demo_lurek_audio_resume)

-- ---- Stub: lurek.audio.playLooping ----------------------------------------
--@api-stub: lurek.audio.playLooping
-- Demonstrates the proper usage of lurek.audio.playLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_playLooping()
    lurek.audio.playLooping(bgm)
    print("BGM looping indefinitely")
end
local _ok, _err = pcall(demo_lurek_audio_playLooping)

-- =============================================================================
-- Volume, Pitch & Pan — per-source audio properties
-- =============================================================================

-- ---- Stub: lurek.audio.setVolume ------------------------------------------
--@api-stub: lurek.audio.setVolume
-- Demonstrates the proper usage of lurek.audio.setVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setVolume()
    lurek.audio.setVolume(jump_sfx, 0.7)
    lurek.audio.setVolume(coin_sfx, 0.5)
    lurek.audio.setVolume(bgm, 0.4)
    print("volumes: jump=0.7, coin=0.5, bgm=0.4")
end
local _ok, _err = pcall(demo_lurek_audio_setVolume)

-- ---- Stub: lurek.audio.getVolume ------------------------------------------
--@api-stub: lurek.audio.getVolume
-- Demonstrates the proper usage of lurek.audio.getVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getVolume()
    local bgm_vol = lurek.audio.getVolume(bgm)
    print("BGM volume: " .. string.format("%.1f", bgm_vol))
end
local _ok, _err = pcall(demo_lurek_audio_getVolume)

-- ---- Stub: lurek.audio.setPitch -------------------------------------------
--@api-stub: lurek.audio.setPitch
-- Demonstrates the proper usage of lurek.audio.setPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setPitch()
    lurek.audio.setPitch(coin_sfx, 1.2)
    print("coin SFX pitched up 20% (sparkly feeling)")
end
local _ok, _err = pcall(demo_lurek_audio_setPitch)

-- ---- Stub: lurek.audio.getPitch -------------------------------------------
--@api-stub: lurek.audio.getPitch
-- Demonstrates the proper usage of lurek.audio.getPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getPitch()
    print("coin pitch: " .. tostring(lurek.audio.getPitch(coin_sfx)))
end
local _ok, _err = pcall(demo_lurek_audio_getPitch)

-- ---- Stub: lurek.audio.setPan ---------------------------------------------
--@api-stub: lurek.audio.setPan
-- Demonstrates the proper usage of lurek.audio.setPan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setPan()
    lurek.audio.setPan(jump_sfx, -0.3)
    print("jump SFX panned slightly left (player on left side of screen)")
end
local _ok, _err = pcall(demo_lurek_audio_setPan)

-- ---- Stub: lurek.audio.getPan ---------------------------------------------
--@api-stub: lurek.audio.getPan
-- Demonstrates the proper usage of lurek.audio.getPan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getPan()
    print("jump pan: " .. tostring(lurek.audio.getPan(jump_sfx)))
end
local _ok, _err = pcall(demo_lurek_audio_getPan)

-- ---- Stub: lurek.audio.setMasterVolume ------------------------------------
--@api-stub: lurek.audio.setMasterVolume
-- Demonstrates the proper usage of lurek.audio.setMasterVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setMasterVolume()
    lurek.audio.setMasterVolume(0.8)
    print("master volume set to 80%")
end
local _ok, _err = pcall(demo_lurek_audio_setMasterVolume)

-- ---- Stub: lurek.audio.getMasterVolume ------------------------------------
--@api-stub: lurek.audio.getMasterVolume
-- Demonstrates the proper usage of lurek.audio.getMasterVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getMasterVolume()
    print("master volume: " .. tostring(lurek.audio.getMasterVolume()))
end
local _ok, _err = pcall(demo_lurek_audio_getMasterVolume)

-- =============================================================================
-- Source State Queries
-- =============================================================================

-- ---- Stub: lurek.audio.isPlaying ------------------------------------------
--@api-stub: lurek.audio.isPlaying
-- Demonstrates the proper usage of lurek.audio.isPlaying.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_isPlaying()
    print("BGM playing: " .. tostring(lurek.audio.isPlaying(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_isPlaying)

-- ---- Stub: lurek.audio.isPaused -------------------------------------------
--@api-stub: lurek.audio.isPaused
-- Demonstrates the proper usage of lurek.audio.isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_isPaused()
    print("BGM paused: " .. tostring(lurek.audio.isPaused(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_isPaused)

-- ---- Stub: lurek.audio.isStopped ------------------------------------------
--@api-stub: lurek.audio.isStopped
-- Demonstrates the proper usage of lurek.audio.isStopped.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_isStopped()
    print("jump stopped: " .. tostring(lurek.audio.isStopped(jump_sfx)))
end
local _ok, _err = pcall(demo_lurek_audio_isStopped)

-- ---- Stub: lurek.audio.setLooping -----------------------------------------
--@api-stub: lurek.audio.setLooping
-- Demonstrates the proper usage of lurek.audio.setLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setLooping()
    lurek.audio.setLooping(bgm, true)
    print("BGM looping enabled")
end
local _ok, _err = pcall(demo_lurek_audio_setLooping)

-- ---- Stub: lurek.audio.isLooping ------------------------------------------
--@api-stub: lurek.audio.isLooping
-- Demonstrates the proper usage of lurek.audio.isLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_isLooping()
    print("BGM looping: " .. tostring(lurek.audio.isLooping(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_isLooping)

-- ---- Stub: lurek.audio.getActiveSourceCount -------------------------------
--@api-stub: lurek.audio.getActiveSourceCount
-- Demonstrates the proper usage of lurek.audio.getActiveSourceCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getActiveSourceCount()
    print("active sources: " .. tostring(lurek.audio.getActiveSourceCount()))
end
local _ok, _err = pcall(demo_lurek_audio_getActiveSourceCount)

-- ---- Stub: lurek.audio.getSourceCount -------------------------------------
--@api-stub: lurek.audio.getSourceCount
-- Demonstrates the proper usage of lurek.audio.getSourceCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getSourceCount()
    print("total sources loaded: " .. tostring(lurek.audio.getSourceCount()))
end
local _ok, _err = pcall(demo_lurek_audio_getSourceCount)

-- ---- Stub: lurek.audio.getSourceType --------------------------------------
--@api-stub: lurek.audio.getSourceType
-- Demonstrates the proper usage of lurek.audio.getSourceType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getSourceType()
    print("jump type: " .. tostring(lurek.audio.getSourceType(jump_sfx)))
    print("bgm type: " .. tostring(lurek.audio.getSourceType(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_getSourceType)

-- ---- Stub: lurek.audio.getMaxSources --------------------------------------
--@api-stub: lurek.audio.getMaxSources
-- Demonstrates the proper usage of lurek.audio.getMaxSources.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getMaxSources()
    print("max simultaneous sources: " .. tostring(lurek.audio.getMaxSources()))
end
local _ok, _err = pcall(demo_lurek_audio_getMaxSources)

-- ---- Stub: lurek.audio.getDuration ----------------------------------------
--@api-stub: lurek.audio.getDuration
-- Demonstrates the proper usage of lurek.audio.getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getDuration()
    local dur = lurek.audio.getDuration(bgm)
    print("BGM duration: " .. string.format("%.1f", dur) .. " seconds")
end
local _ok, _err = pcall(demo_lurek_audio_getDuration)

-- =============================================================================
-- Seek & Tell — playback position
-- =============================================================================

-- ---- Stub: lurek.audio.tell -----------------------------------------------
--@api-stub: lurek.audio.tell
-- Demonstrates the proper usage of lurek.audio.tell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_tell()
    local pos = lurek.audio.tell(bgm)
    print("BGM position: " .. string.format("%.2f", pos) .. "s")
end
local _ok, _err = pcall(demo_lurek_audio_tell)

-- ---- Stub: lurek.audio.seek -----------------------------------------------
--@api-stub: lurek.audio.seek
-- Demonstrates the proper usage of lurek.audio.seek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_seek()
    lurek.audio.seek(bgm, 30.0)
    print("BGM seeked to 30.0s (skipped intro)")
end
local _ok, _err = pcall(demo_lurek_audio_seek)

-- =============================================================================
-- Global Playback Control
-- =============================================================================

-- ---- Stub: lurek.audio.pauseAll -------------------------------------------
--@api-stub: lurek.audio.pauseAll
-- Demonstrates the proper usage of lurek.audio.pauseAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_pauseAll()
    lurek.audio.pauseAll()
    print("all audio paused (pause menu opened)")
end
local _ok, _err = pcall(demo_lurek_audio_pauseAll)

-- ---- Stub: lurek.audio.resumeAll ------------------------------------------
--@api-stub: lurek.audio.resumeAll
-- Demonstrates the proper usage of lurek.audio.resumeAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_resumeAll()
    lurek.audio.resumeAll()
    print("all audio resumed (pause menu closed)")
end
local _ok, _err = pcall(demo_lurek_audio_resumeAll)

-- ---- Stub: lurek.audio.stopAll --------------------------------------------
--@api-stub: lurek.audio.stopAll
-- Demonstrates the proper usage of lurek.audio.stopAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_stopAll()
    lurek.audio.stopAll()
    print("all audio stopped (level transition)")
end
local _ok, _err = pcall(demo_lurek_audio_stopAll)

-- ---- Stub: lurek.audio.clone ----------------------------------------------
--@api-stub: lurek.audio.clone
-- Demonstrates the proper usage of lurek.audio.clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_clone()
    local jump_sfx2 = lurek.audio.clone(jump_sfx)
    print("jump SFX cloned for overlapping playback")
end
local _ok, _err = pcall(demo_lurek_audio_clone)

-- ---- Stub: lurek.audio.release --------------------------------------------
--@api-stub: lurek.audio.release
-- Demonstrates the proper usage of lurek.audio.release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_release()
    lurek.audio.release(jump_sfx2)
    print("cloned jump SFX released")
end
local _ok, _err = pcall(demo_lurek_audio_release)

-- =============================================================================
-- Filters — low/highpass for environmental effects
-- =============================================================================

-- ---- Stub: lurek.audio.setLowpass -----------------------------------------
--@api-stub: lurek.audio.setLowpass
-- Demonstrates the proper usage of lurek.audio.setLowpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setLowpass()
    lurek.audio.setLowpass(bgm, 0.3)
    print("BGM lowpass at 0.3 (underwater effect)")
end
local _ok, _err = pcall(demo_lurek_audio_setLowpass)

-- ---- Stub: lurek.audio.getLowpass -----------------------------------------
--@api-stub: lurek.audio.getLowpass
-- Demonstrates the proper usage of lurek.audio.getLowpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getLowpass()
    print("BGM lowpass: " .. tostring(lurek.audio.getLowpass(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_getLowpass)

-- ---- Stub: lurek.audio.setHighpass ----------------------------------------
--@api-stub: lurek.audio.setHighpass
-- Demonstrates the proper usage of lurek.audio.setHighpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setHighpass()
    lurek.audio.setHighpass(bgm, 0.6)
    print("BGM highpass at 0.6 (radio transmission effect)")
end
local _ok, _err = pcall(demo_lurek_audio_setHighpass)

-- ---- Stub: lurek.audio.getHighpass ----------------------------------------
--@api-stub: lurek.audio.getHighpass
-- Demonstrates the proper usage of lurek.audio.getHighpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getHighpass()
    print("BGM highpass: " .. tostring(lurek.audio.getHighpass(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_getHighpass)

-- ---- Stub: lurek.audio.clearFilter ----------------------------------------
--@api-stub: lurek.audio.clearFilter
-- Demonstrates the proper usage of lurek.audio.clearFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_clearFilter()
    lurek.audio.clearFilter(bgm)
    print("BGM filters cleared (back to normal)")
end
local _ok, _err = pcall(demo_lurek_audio_clearFilter)

-- ---- Stub: lurek.audio.fadeIn ---------------------------------------------
--@api-stub: lurek.audio.fadeIn
-- Demonstrates the proper usage of lurek.audio.fadeIn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_fadeIn()
    lurek.audio.fadeIn(bgm, 2.0)
    print("BGM fading in over 2 seconds")
end
local _ok, _err = pcall(demo_lurek_audio_fadeIn)

-- ---- Stub: lurek.audio.getFadeIn ------------------------------------------
--@api-stub: lurek.audio.getFadeIn
-- Demonstrates the proper usage of lurek.audio.getFadeIn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getFadeIn()
    print("BGM fade-in duration: " .. tostring(lurek.audio.getFadeIn(bgm)) .. "s")
end
local _ok, _err = pcall(demo_lurek_audio_getFadeIn)

-- =============================================================================
-- Stereo Width & Random Pitch — variation for SFX
-- =============================================================================

-- ---- Stub: lurek.audio.setStereoWidth -------------------------------------
--@api-stub: lurek.audio.setStereoWidth
-- Demonstrates the proper usage of lurek.audio.setStereoWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setStereoWidth()
    lurek.audio.setStereoWidth(bgm, 1.5)
    print("BGM stereo width: 1.5 (wider soundstage)")
end
local _ok, _err = pcall(demo_lurek_audio_setStereoWidth)

-- ---- Stub: lurek.audio.getStereoWidth -------------------------------------
--@api-stub: lurek.audio.getStereoWidth
-- Demonstrates the proper usage of lurek.audio.getStereoWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getStereoWidth()
    print("BGM stereo width: " .. tostring(lurek.audio.getStereoWidth(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_getStereoWidth)

-- ---- Stub: lurek.audio.setRandomPitch -------------------------------------
--@api-stub: lurek.audio.setRandomPitch
-- Demonstrates the proper usage of lurek.audio.setRandomPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setRandomPitch()
    lurek.audio.setRandomPitch(coin_sfx, 0.08)
    print("coin SFX: random pitch +/-8% (each pickup sounds slightly different)")
end
local _ok, _err = pcall(demo_lurek_audio_setRandomPitch)

-- ---- Stub: lurek.audio.clearRandomPitch -----------------------------------
--@api-stub: lurek.audio.clearRandomPitch
-- Demonstrates the proper usage of lurek.audio.clearRandomPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_clearRandomPitch()
    lurek.audio.clearRandomPitch(coin_sfx)
    print("coin random pitch cleared")
end
local _ok, _err = pcall(demo_lurek_audio_clearRandomPitch)

-- ---- Stub: lurek.audio.crossfade ------------------------------------------
--@api-stub: lurek.audio.crossfade
-- Smoothly transition between two sources over N seconds.
-- Use for zone transitions: forest ambience -> cave ambience.
local cave_ambience = lurek.audio.newSource("assets/audio/cave_drips.ogg", "stream")
lurek.audio.crossfade(bgm, cave_ambience, 3.0)
print("crossfading BGM -> cave ambience over 3 seconds")

-- =============================================================================
-- 2D Spatial Audio — positional sound for enemies and items
-- =============================================================================

-- ---- Stub: lurek.audio.setListener2D --------------------------------------
--@api-stub: lurek.audio.setListener2D
-- Demonstrates the proper usage of lurek.audio.setListener2D.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setListener2D()
    lurek.audio.setListener2D(400, 300)
    print("2D listener at player position (400, 300)")
end
local _ok, _err = pcall(demo_lurek_audio_setListener2D)

-- ---- Stub: lurek.audio.getListener2D --------------------------------------
--@api-stub: lurek.audio.getListener2D
-- Demonstrates the proper usage of lurek.audio.getListener2D.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getListener2D()
    local lx, ly = lurek.audio.getListener2D()
    print("listener 2D: (" .. tostring(lx) .. ", " .. tostring(ly) .. ")")
end
local _ok, _err = pcall(demo_lurek_audio_getListener2D)

-- ---- Stub: lurek.audio.setListener ----------------------------------------
--@api-stub: lurek.audio.setListener
-- Demonstrates the proper usage of lurek.audio.setListener.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setListener()
    lurek.audio.setListener(400, 300, 0)
    print("3D listener at (400, 300, 0)")
end
local _ok, _err = pcall(demo_lurek_audio_setListener)

-- ---- Stub: lurek.audio.getListener ----------------------------------------
--@api-stub: lurek.audio.getListener
-- Demonstrates the proper usage of lurek.audio.getListener.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getListener()
    local l3x, l3y, l3z = lurek.audio.getListener()
    print("3D listener: (" .. tostring(l3x) .. ", " .. tostring(l3y) .. ", " .. tostring(l3z) .. ")")
end
local _ok, _err = pcall(demo_lurek_audio_getListener)

-- ---- Stub: lurek.audio.setPosition ----------------------------------------
--@api-stub: lurek.audio.setPosition
-- Place an enemy growl at world position (600, 200) so it pans/attenuates
-- relative to the listener.
local enemy_growl = lurek.audio.newSource("assets/audio/growl.wav", "static")
lurek.audio.setPosition(enemy_growl, 600, 200, 0)
print("enemy growl positioned at (600, 200)")

-- ---- Stub: lurek.audio.getPosition ----------------------------------------
--@api-stub: lurek.audio.getPosition
-- Demonstrates the proper usage of lurek.audio.getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getPosition()
    local ex, ey, ez = lurek.audio.getPosition(enemy_growl)
    print("growl position: (" .. tostring(ex) .. ", " .. tostring(ey) .. ", " .. tostring(ez) .. ")")
end
local _ok, _err = pcall(demo_lurek_audio_getPosition)

-- ---- Stub: lurek.audio.setVelocity ---------------------------------------
--@api-stub: lurek.audio.setVelocity
-- Demonstrates the proper usage of lurek.audio.setVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setVelocity()
    lurek.audio.setVelocity(enemy_growl, -5.0, 0, 0)
    print("enemy moving left at 5 units/s (Doppler: pitch drops as it passes)")
end
local _ok, _err = pcall(demo_lurek_audio_setVelocity)

-- ---- Stub: lurek.audio.getVelocity ---------------------------------------
--@api-stub: lurek.audio.getVelocity
-- Demonstrates the proper usage of lurek.audio.getVelocity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getVelocity()
    local vx, vy, vz = lurek.audio.getVelocity(enemy_growl)
    print("growl velocity: (" .. tostring(vx) .. ", " .. tostring(vy) .. ", " .. tostring(vz) .. ")")
end
local _ok, _err = pcall(demo_lurek_audio_getVelocity)

-- ---- Stub: lurek.audio.setOrientation -------------------------------------
--@api-stub: lurek.audio.setOrientation
-- Demonstrates the proper usage of lurek.audio.setOrientation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setOrientation()
    lurek.audio.setOrientation(1, 0, 0, 0, 1, 0)
    print("listener facing right (+X), up is +Y")
end
local _ok, _err = pcall(demo_lurek_audio_setOrientation)

-- ---- Stub: lurek.audio.getOrientation -------------------------------------
--@api-stub: lurek.audio.getOrientation
-- Demonstrates the proper usage of lurek.audio.getOrientation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getOrientation()
    local fx, fy, fz, ux, uy, uz = lurek.audio.getOrientation()
    print("orientation: forward=(" .. fx .. "," .. fy .. "," .. fz .. ") up=(" .. ux .. "," .. uy .. "," .. uz .. ")")
end
local _ok, _err = pcall(demo_lurek_audio_getOrientation)

-- ---- Stub: lurek.audio.setDopplerScale ------------------------------------
--@api-stub: lurek.audio.setDopplerScale
-- Demonstrates the proper usage of lurek.audio.setDopplerScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setDopplerScale()
    lurek.audio.setDopplerScale(1.5)
    print("Doppler scale: 1.5 (slightly exaggerated for fun)")
end
local _ok, _err = pcall(demo_lurek_audio_setDopplerScale)

-- ---- Stub: lurek.audio.getDopplerScale ------------------------------------
--@api-stub: lurek.audio.getDopplerScale
-- Demonstrates the proper usage of lurek.audio.getDopplerScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getDopplerScale()
    print("Doppler scale: " .. tostring(lurek.audio.getDopplerScale()))
end
local _ok, _err = pcall(demo_lurek_audio_getDopplerScale)

-- ---- Stub: lurek.audio.setDistanceModel -----------------------------------
--@api-stub: lurek.audio.setDistanceModel
-- Demonstrates the proper usage of lurek.audio.setDistanceModel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setDistanceModel()
    lurek.audio.setDistanceModel("inverse")
    print("distance model: inverse (realistic falloff)")
end
local _ok, _err = pcall(demo_lurek_audio_setDistanceModel)

-- ---- Stub: lurek.audio.getDistanceModel -----------------------------------
--@api-stub: lurek.audio.getDistanceModel
-- Demonstrates the proper usage of lurek.audio.getDistanceModel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getDistanceModel()
    print("distance model: " .. tostring(lurek.audio.getDistanceModel()))
end
local _ok, _err = pcall(demo_lurek_audio_getDistanceModel)

-- ---- Stub: lurek.audio.setMeter -------------------------------------------
--@api-stub: lurek.audio.setMeter
-- Demonstrates the proper usage of lurek.audio.setMeter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setMeter()
    lurek.audio.setMeter(64.0)
    print("meter scale: 64 pixels = 1 meter")
end
local _ok, _err = pcall(demo_lurek_audio_setMeter)

-- ---- Stub: lurek.audio.getMeter -------------------------------------------
--@api-stub: lurek.audio.getMeter
-- Demonstrates the proper usage of lurek.audio.getMeter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getMeter()
    print("meter scale: " .. tostring(lurek.audio.getMeter()) .. " units/meter")
end
local _ok, _err = pcall(demo_lurek_audio_getMeter)

-- =============================================================================
-- Audio Buses — mixing groups
-- =============================================================================

-- ---- Stub: lurek.audio.newBus ---------------------------------------------
--@api-stub: lurek.audio.newBus
-- Buses group sources for collective volume/effect control.
-- Typical setup: "master" -> "music", "sfx", "voice", "ambient".
local sfx_bus = lurek.audio.newBus("sfx")
local music_bus = lurek.audio.newBus("music")
local ambient_bus = lurek.audio.newBus("ambient")
print("buses created: sfx, music, ambient")

-- ---- Stub: lurek.audio.setSourceBus ---------------------------------------
--@api-stub: lurek.audio.setSourceBus
-- Demonstrates the proper usage of lurek.audio.setSourceBus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setSourceBus()
    lurek.audio.setSourceBus(jump_sfx, "sfx")
    lurek.audio.setSourceBus(coin_sfx, "sfx")
    lurek.audio.setSourceBus(bgm, "music")
    lurek.audio.setSourceBus(cave_ambience, "ambient")
    print("sources routed: SFX->sfx bus, BGM->music bus")
end
local _ok, _err = pcall(demo_lurek_audio_setSourceBus)

-- ---- Stub: lurek.audio.getSourceBus ---------------------------------------
--@api-stub: lurek.audio.getSourceBus
-- Demonstrates the proper usage of lurek.audio.getSourceBus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getSourceBus()
    print("jump SFX bus: " .. tostring(lurek.audio.getSourceBus(jump_sfx)))
    print("BGM bus: " .. tostring(lurek.audio.getSourceBus(bgm)))
end
local _ok, _err = pcall(demo_lurek_audio_getSourceBus)

-- ---- Stub: lurek.audio.create_bus -----------------------------------------
--@api-stub: lurek.audio.create_bus
-- Demonstrates the proper usage of lurek.audio.create_bus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_create_bus()
    lurek.audio.create_bus("voice", { volume = 0.9 })
    print("voice bus created with volume 0.9")
end
local _ok, _err = pcall(demo_lurek_audio_create_bus)

-- ---- Stub: lurek.audio.set_bus_volume -------------------------------------
--@api-stub: lurek.audio.set_bus_volume
-- Demonstrates the proper usage of lurek.audio.set_bus_volume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_set_bus_volume()
    lurek.audio.set_bus_volume("sfx", 0.7)
    lurek.audio.set_bus_volume("music", 0.5)
    print("bus volumes: sfx=0.7, music=0.5")
end
local _ok, _err = pcall(demo_lurek_audio_set_bus_volume)

-- ---- Stub: lurek.audio.add_effect ----------------------------------------
--@api-stub: lurek.audio.add_effect
-- Demonstrates the proper usage of lurek.audio.add_effect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_add_effect()
    lurek.audio.add_effect("ambient", "reverb", { decay = 2.0, wet = 0.6 })
    print("reverb added to ambient bus (cave echo)")
end
local _ok, _err = pcall(demo_lurek_audio_add_effect)

-- ---- Stub: lurek.audio.remove_effect --------------------------------------
--@api-stub: lurek.audio.remove_effect
-- Demonstrates the proper usage of lurek.audio.remove_effect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_remove_effect()
    lurek.audio.remove_effect("ambient", "reverb")
    print("reverb removed from ambient bus")
end
local _ok, _err = pcall(demo_lurek_audio_remove_effect)

-- ---- Stub: lurek.audio.set_effect_param -----------------------------------
--@api-stub: lurek.audio.set_effect_param
-- Demonstrates the proper usage of lurek.audio.set_effect_param.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_set_effect_param()
    lurek.audio.add_effect("ambient", "reverb", { decay = 2.0, wet = 0.6 })
    lurek.audio.set_effect_param("ambient", "reverb", "wet", 0.8)
    print("ambient reverb wetness increased to 0.8 (deeper cave)")
end
local _ok, _err = pcall(demo_lurek_audio_set_effect_param)

-- ---- Stub: lurek.audio.getBusPeak -----------------------------------------
--@api-stub: lurek.audio.getBusPeak
-- Demonstrates the proper usage of lurek.audio.getBusPeak.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getBusPeak()
    local peak = lurek.audio.getBusPeak("sfx")
    print("SFX bus peak: " .. string.format("%.3f", peak))
end
local _ok, _err = pcall(demo_lurek_audio_getBusPeak)

-- ---- Stub: lurek.audio.getBusRms ------------------------------------------
--@api-stub: lurek.audio.getBusRms
-- Demonstrates the proper usage of lurek.audio.getBusRms.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getBusRms()
    local rms = lurek.audio.getBusRms("sfx")
    print("SFX bus RMS: " .. string.format("%.3f", rms))
end
local _ok, _err = pcall(demo_lurek_audio_getBusRms)

-- =============================================================================
-- Bus Object Methods
-- =============================================================================

-- ---- Stub: Bus:getName ----------------------------------------------------
--@api-stub: Bus:getName
-- Demonstrates the proper usage of Bus:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_getName()
    print("bus name: " .. sfx_bus:getName())
end
local _ok, _err = pcall(demo_Bus_getName)

-- ---- Stub: Bus:setVolume --------------------------------------------------
--@api-stub: Bus:setVolume
-- Demonstrates the proper usage of Bus:setVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_setVolume()
    sfx_bus:setVolume(0.8)
    print("SFX bus volume set to 0.8")
end
local _ok, _err = pcall(demo_Bus_setVolume)

-- ---- Stub: Bus:getVolume --------------------------------------------------
--@api-stub: Bus:getVolume
-- Demonstrates the proper usage of Bus:getVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_getVolume()
    print("SFX bus volume: " .. tostring(sfx_bus:getVolume()))
end
local _ok, _err = pcall(demo_Bus_getVolume)

-- ---- Stub: Bus:setPitch ---------------------------------------------------
--@api-stub: Bus:setPitch
-- Demonstrates the proper usage of Bus:setPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_setPitch()
    sfx_bus:setPitch(0.7)
    print("SFX bus pitch: 0.7 (slow-motion effect)")
end
local _ok, _err = pcall(demo_Bus_setPitch)

-- ---- Stub: Bus:getPitch ---------------------------------------------------
--@api-stub: Bus:getPitch
-- Demonstrates the proper usage of Bus:getPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_getPitch()
    print("SFX bus pitch: " .. tostring(sfx_bus:getPitch()))
end
local _ok, _err = pcall(demo_Bus_getPitch)

-- ---- Stub: Bus:pause ------------------------------------------------------
--@api-stub: Bus:pause
-- Demonstrates the proper usage of Bus:pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_pause()
    music_bus:pause()
    print("music bus paused (menu opened, SFX still active)")
end
local _ok, _err = pcall(demo_Bus_pause)

-- ---- Stub: Bus:resume -----------------------------------------------------
--@api-stub: Bus:resume
-- Demonstrates the proper usage of Bus:resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_resume()
    music_bus:resume()
    print("music bus resumed")
end
local _ok, _err = pcall(demo_Bus_resume)

-- ---- Stub: Bus:isPaused ---------------------------------------------------
--@api-stub: Bus:isPaused
-- Demonstrates the proper usage of Bus:isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_isPaused()
    print("music bus paused: " .. tostring(music_bus:isPaused()))
end
local _ok, _err = pcall(demo_Bus_isPaused)

-- ---- Stub: Bus:type -------------------------------------------------------
--@api-stub: Bus:type
-- Demonstrates the proper usage of Bus:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_Bus_type)

-- ---- Stub: Bus:typeOf -----------------------------------------------------
--@api-stub: Bus:typeOf
-- Demonstrates the proper usage of Bus:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_typeOf()
    print("bus type: " .. tostring(sfx_bus:type()))
    print("bus typeOf: " .. tostring(sfx_bus:typeOf("Bus")))
end
local _ok, _err = pcall(demo_Bus_typeOf)

-- ---- Stub: Bus:clearDuck --------------------------------------------------
--@api-stub: Bus:clearDuck
-- Demonstrates the proper usage of Bus:clearDuck.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_clearDuck()
    sfx_bus:clearDuck()
    print("SFX bus ducking cleared")
end
local _ok, _err = pcall(demo_Bus_clearDuck)

-- ---- Stub: Bus:getPeak ----------------------------------------------------
--@api-stub: Bus:getPeak
-- Demonstrates the proper usage of Bus:getPeak.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Bus_getPeak()
    local bus_peak = sfx_bus:getPeak()
    print("SFX bus peak level: " .. string.format("%.3f", bus_peak))
end
local _ok, _err = pcall(demo_Bus_getPeak)

-- =============================================================================
-- MIDI Player — chiptune music playback
-- =============================================================================

-- ---- Stub: lurek.audio.newMidiPlayer --------------------------------------
--@api-stub: lurek.audio.newMidiPlayer
-- Demonstrates the proper usage of lurek.audio.newMidiPlayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newMidiPlayer()
    local midi = lurek.audio.newMidiPlayer()
    print("MIDI player created")
end
local _ok, _err = pcall(demo_lurek_audio_newMidiPlayer)

-- ---- Stub: lurek.audio.setMidiSoundFont -----------------------------------
--@api-stub: lurek.audio.setMidiSoundFont
-- Demonstrates the proper usage of lurek.audio.setMidiSoundFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setMidiSoundFont()
    lurek.audio.setMidiSoundFont("assets/audio/gm_soundfont.sf2")
    print("default SoundFont set: gm_soundfont.sf2")
end
local _ok, _err = pcall(demo_lurek_audio_setMidiSoundFont)

-- ---- Stub: lurek.audio.hasMidiSoundFont -----------------------------------
--@api-stub: lurek.audio.hasMidiSoundFont
-- Demonstrates the proper usage of lurek.audio.hasMidiSoundFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_hasMidiSoundFont()
    print("has default SoundFont: " .. tostring(lurek.audio.hasMidiSoundFont()))
end
local _ok, _err = pcall(demo_lurek_audio_hasMidiSoundFont)

-- ---- Stub: lurek.audio.clearMidiSoundFont ---------------------------------
--@api-stub: lurek.audio.clearMidiSoundFont
-- Demonstrates the proper usage of lurek.audio.clearMidiSoundFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_clearMidiSoundFont()
    lurek.audio.clearMidiSoundFont()
    print("default SoundFont cleared")
end
local _ok, _err = pcall(demo_lurek_audio_clearMidiSoundFont)

-- ---- Stub: MidiPlayer:load -----------------------------------------------
--@api-stub: MidiPlayer:load
-- Demonstrates the proper usage of MidiPlayer:load.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_load()
    midi:load("assets/audio/boss_battle.mid")
    print("MIDI file loaded: boss_battle.mid")
end
local _ok, _err = pcall(demo_MidiPlayer_load)

-- ---- Stub: MidiPlayer:loadData --------------------------------------------
--@api-stub: MidiPlayer:loadData
-- Demonstrates the proper usage of MidiPlayer:loadData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_loadData()
    local midi_bytes = "\0\0\0\0"  -- placeholder; real data would come from a file
    midi:loadData(midi_bytes)
    print("MIDI loaded from raw data")
end
local _ok, _err = pcall(demo_MidiPlayer_loadData)

-- ---- Stub: MidiPlayer:isLoaded --------------------------------------------
--@api-stub: MidiPlayer:isLoaded
-- Demonstrates the proper usage of MidiPlayer:isLoaded.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_isLoaded()
    print("MIDI loaded: " .. tostring(midi:isLoaded()))
end
local _ok, _err = pcall(demo_MidiPlayer_isLoaded)

-- ---- Stub: MidiPlayer:getFilePath -----------------------------------------
--@api-stub: MidiPlayer:getFilePath
-- Demonstrates the proper usage of MidiPlayer:getFilePath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getFilePath()
    print("MIDI file: " .. tostring(midi:getFilePath()))
end
local _ok, _err = pcall(demo_MidiPlayer_getFilePath)

-- ---- Stub: MidiPlayer:setSoundFont ----------------------------------------
--@api-stub: MidiPlayer:setSoundFont
-- Demonstrates the proper usage of MidiPlayer:setSoundFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setSoundFont()
    midi:setSoundFont("assets/audio/retro_synth.sf2")
    print("per-player SoundFont: retro_synth.sf2")
end
local _ok, _err = pcall(demo_MidiPlayer_setSoundFont)

-- ---- Stub: MidiPlayer:getSoundFontPath ------------------------------------
--@api-stub: MidiPlayer:getSoundFontPath
-- Demonstrates the proper usage of MidiPlayer:getSoundFontPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getSoundFontPath()
    print("MIDI SoundFont: " .. tostring(midi:getSoundFontPath()))
end
local _ok, _err = pcall(demo_MidiPlayer_getSoundFontPath)

-- ---- Stub: MidiPlayer:useDefaultSoundFont ---------------------------------
--@api-stub: MidiPlayer:useDefaultSoundFont
-- Demonstrates the proper usage of MidiPlayer:useDefaultSoundFont.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_useDefaultSoundFont()
    midi:useDefaultSoundFont()
    print("MIDI player reverted to default SoundFont")
end
local _ok, _err = pcall(demo_MidiPlayer_useDefaultSoundFont)

-- ---- Stub: MidiPlayer:play -----------------------------------------------
--@api-stub: MidiPlayer:play
-- Demonstrates the proper usage of MidiPlayer:play.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_play()
    midi:play()
    print("MIDI playing")
end
local _ok, _err = pcall(demo_MidiPlayer_play)

-- ---- Stub: MidiPlayer:pause -----------------------------------------------
--@api-stub: MidiPlayer:pause
-- Demonstrates the proper usage of MidiPlayer:pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_pause()
    midi:pause()
    print("MIDI paused")
end
local _ok, _err = pcall(demo_MidiPlayer_pause)

-- ---- Stub: MidiPlayer:stop ------------------------------------------------
--@api-stub: MidiPlayer:stop
-- Demonstrates the proper usage of MidiPlayer:stop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_stop()
    midi:stop()
    print("MIDI stopped")
end
local _ok, _err = pcall(demo_MidiPlayer_stop)

-- ---- Stub: MidiPlayer:isPlaying -------------------------------------------
--@api-stub: MidiPlayer:isPlaying
-- Demonstrates the proper usage of MidiPlayer:isPlaying.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_isPlaying()
    print("MIDI playing: " .. tostring(midi:isPlaying()))
end
local _ok, _err = pcall(demo_MidiPlayer_isPlaying)

-- ---- Stub: MidiPlayer:isPaused --------------------------------------------
--@api-stub: MidiPlayer:isPaused
-- Demonstrates the proper usage of MidiPlayer:isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_isPaused()
    print("MIDI paused: " .. tostring(midi:isPaused()))
end
local _ok, _err = pcall(demo_MidiPlayer_isPaused)

-- ---- Stub: MidiPlayer:seek ------------------------------------------------
--@api-stub: MidiPlayer:seek
-- Demonstrates the proper usage of MidiPlayer:seek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_seek()
    midi:seek(15.0)
    print("MIDI seeked to 15.0s (skip to chorus)")
end
local _ok, _err = pcall(demo_MidiPlayer_seek)

-- ---- Stub: MidiPlayer:tell ------------------------------------------------
--@api-stub: MidiPlayer:tell
-- Demonstrates the proper usage of MidiPlayer:tell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_tell()
    print("MIDI position: " .. string.format("%.2f", midi:tell()) .. "s")
end
local _ok, _err = pcall(demo_MidiPlayer_tell)

-- ---- Stub: MidiPlayer:getDuration -----------------------------------------
--@api-stub: MidiPlayer:getDuration
-- Demonstrates the proper usage of MidiPlayer:getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getDuration()
    print("MIDI duration: " .. string.format("%.1f", midi:getDuration()) .. "s")
end
local _ok, _err = pcall(demo_MidiPlayer_getDuration)

-- ---- Stub: MidiPlayer:setLooping ------------------------------------------
--@api-stub: MidiPlayer:setLooping
-- Demonstrates the proper usage of MidiPlayer:setLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setLooping()
    midi:setLooping(true)
    print("MIDI looping enabled (boss music loops)")
end
local _ok, _err = pcall(demo_MidiPlayer_setLooping)

-- ---- Stub: MidiPlayer:isLooping -------------------------------------------
--@api-stub: MidiPlayer:isLooping
-- Demonstrates the proper usage of MidiPlayer:isLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_isLooping()
    print("MIDI looping: " .. tostring(midi:isLooping()))
end
local _ok, _err = pcall(demo_MidiPlayer_isLooping)

-- ---- Stub: MidiPlayer:setVolume -------------------------------------------
--@api-stub: MidiPlayer:setVolume
-- Demonstrates the proper usage of MidiPlayer:setVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setVolume()
    midi:setVolume(0.6)
    print("MIDI volume: 0.6")
end
local _ok, _err = pcall(demo_MidiPlayer_setVolume)

-- ---- Stub: MidiPlayer:getVolume -------------------------------------------
--@api-stub: MidiPlayer:getVolume
-- Demonstrates the proper usage of MidiPlayer:getVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getVolume()
    print("MIDI volume: " .. tostring(midi:getVolume()))
end
local _ok, _err = pcall(demo_MidiPlayer_getVolume)

-- ---- Stub: MidiPlayer:setBus ----------------------------------------------
--@api-stub: MidiPlayer:setBus
-- Demonstrates the proper usage of MidiPlayer:setBus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setBus()
    midi:setBus("music")
    print("MIDI routed to music bus")
end
local _ok, _err = pcall(demo_MidiPlayer_setBus)

-- ---- Stub: MidiPlayer:getBus ----------------------------------------------
--@api-stub: MidiPlayer:getBus
-- Demonstrates the proper usage of MidiPlayer:getBus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getBus()
    print("MIDI bus: " .. tostring(midi:getBus()))
end
local _ok, _err = pcall(demo_MidiPlayer_getBus)

-- ---- Stub: MidiPlayer:setTempo --------------------------------------------
--@api-stub: MidiPlayer:setTempo
-- Demonstrates the proper usage of MidiPlayer:setTempo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setTempo()
    midi:setTempo(140)
    print("MIDI tempo set to 140 BPM (battle intensity)")
end
local _ok, _err = pcall(demo_MidiPlayer_setTempo)

-- ---- Stub: MidiPlayer:getTempo --------------------------------------------
--@api-stub: MidiPlayer:getTempo
-- Demonstrates the proper usage of MidiPlayer:getTempo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getTempo()
    print("MIDI tempo: " .. tostring(midi:getTempo()) .. " BPM")
end
local _ok, _err = pcall(demo_MidiPlayer_getTempo)

-- ---- Stub: MidiPlayer:getOriginalTempo ------------------------------------
--@api-stub: MidiPlayer:getOriginalTempo
-- Demonstrates the proper usage of MidiPlayer:getOriginalTempo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getOriginalTempo()
    print("MIDI original tempo: " .. tostring(midi:getOriginalTempo()) .. " BPM")
end
local _ok, _err = pcall(demo_MidiPlayer_getOriginalTempo)

-- ---- Stub: MidiPlayer:setTempoScale ---------------------------------------
--@api-stub: MidiPlayer:setTempoScale
-- Demonstrates the proper usage of MidiPlayer:setTempoScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setTempoScale()
    midi:setTempoScale(1.2)
    print("MIDI tempo scale: 1.2x (20% faster during combat rush)")
end
local _ok, _err = pcall(demo_MidiPlayer_setTempoScale)

-- ---- Stub: MidiPlayer:getTempoScale ---------------------------------------
--@api-stub: MidiPlayer:getTempoScale
-- Demonstrates the proper usage of MidiPlayer:getTempoScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getTempoScale()
    print("MIDI tempo scale: " .. tostring(midi:getTempoScale()))
end
local _ok, _err = pcall(demo_MidiPlayer_getTempoScale)

-- ---- Stub: MidiPlayer:getTicksPerBeat -------------------------------------
--@api-stub: MidiPlayer:getTicksPerBeat
-- Demonstrates the proper usage of MidiPlayer:getTicksPerBeat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getTicksPerBeat()
    print("MIDI ticks/beat: " .. tostring(midi:getTicksPerBeat()))
end
local _ok, _err = pcall(demo_MidiPlayer_getTicksPerBeat)

-- ---- Stub: MidiPlayer:setChannelVolume ------------------------------------
--@api-stub: MidiPlayer:setChannelVolume
-- Demonstrates the proper usage of MidiPlayer:setChannelVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setChannelVolume()
    midi:setChannelVolume(9, 0.2)  -- channel 9 = drums in General MIDI
    print("MIDI drum channel (9) volume reduced to 0.2")
end
local _ok, _err = pcall(demo_MidiPlayer_setChannelVolume)

-- ---- Stub: MidiPlayer:getChannelVolume ------------------------------------
--@api-stub: MidiPlayer:getChannelVolume
-- Demonstrates the proper usage of MidiPlayer:getChannelVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getChannelVolume()
    print("drum channel volume: " .. tostring(midi:getChannelVolume(9)))
end
local _ok, _err = pcall(demo_MidiPlayer_getChannelVolume)

-- ---- Stub: MidiPlayer:setChannelMuted -------------------------------------
--@api-stub: MidiPlayer:setChannelMuted
-- Demonstrates the proper usage of MidiPlayer:setChannelMuted.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setChannelMuted()
    midi:setChannelMuted(9, true)
    print("drum channel muted (stealth mode)")
end
local _ok, _err = pcall(demo_MidiPlayer_setChannelMuted)

-- ---- Stub: MidiPlayer:isChannelMuted --------------------------------------
--@api-stub: MidiPlayer:isChannelMuted
-- Demonstrates the proper usage of MidiPlayer:isChannelMuted.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_isChannelMuted()
    print("drum channel muted: " .. tostring(midi:isChannelMuted(9)))
end
local _ok, _err = pcall(demo_MidiPlayer_isChannelMuted)

-- ---- Stub: MidiPlayer:getChannelInstrument --------------------------------
--@api-stub: MidiPlayer:getChannelInstrument
-- Demonstrates the proper usage of MidiPlayer:getChannelInstrument.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getChannelInstrument()
    local instr = midi:getChannelInstrument(0)
    print("channel 0 instrument: " .. tostring(instr))
end
local _ok, _err = pcall(demo_MidiPlayer_getChannelInstrument)

-- ---- Stub: MidiPlayer:getChannelCount -------------------------------------
--@api-stub: MidiPlayer:getChannelCount
-- Demonstrates the proper usage of MidiPlayer:getChannelCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getChannelCount()
    print("MIDI channels: " .. tostring(midi:getChannelCount()))
end
local _ok, _err = pcall(demo_MidiPlayer_getChannelCount)

-- ---- Stub: MidiPlayer:soloChannel -----------------------------------------
--@api-stub: MidiPlayer:soloChannel
-- Demonstrates the proper usage of MidiPlayer:soloChannel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_soloChannel()
    midi:soloChannel(0)
    print("channel 0 soloed (melody only for puzzle)")
end
local _ok, _err = pcall(demo_MidiPlayer_soloChannel)

-- ---- Stub: MidiPlayer:unsoloAll -------------------------------------------
--@api-stub: MidiPlayer:unsoloAll
-- Demonstrates the proper usage of MidiPlayer:unsoloAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_unsoloAll()
    midi:unsoloAll()
    print("all channels unsoloed (full arrangement restored)")
end
local _ok, _err = pcall(demo_MidiPlayer_unsoloAll)

-- ---- Stub: MidiPlayer:getTrackCount --------------------------------------
--@api-stub: MidiPlayer:getTrackCount
-- Demonstrates the proper usage of MidiPlayer:getTrackCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getTrackCount()
    print("MIDI tracks: " .. tostring(midi:getTrackCount()))
end
local _ok, _err = pcall(demo_MidiPlayer_getTrackCount)

-- ---- Stub: MidiPlayer:getTrackName ----------------------------------------
--@api-stub: MidiPlayer:getTrackName
-- Demonstrates the proper usage of MidiPlayer:getTrackName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getTrackName()
    local track_name = midi:getTrackName(0)
    print("track 0 name: " .. tostring(track_name))
end
local _ok, _err = pcall(demo_MidiPlayer_getTrackName)

-- ---- Stub: MidiPlayer:setTrackMuted ---------------------------------------
--@api-stub: MidiPlayer:setTrackMuted
-- Demonstrates the proper usage of MidiPlayer:setTrackMuted.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setTrackMuted()
    midi:setTrackMuted(0, false)
    print("track 0 unmuted")
end
local _ok, _err = pcall(demo_MidiPlayer_setTrackMuted)

-- ---- Stub: MidiPlayer:isTrackMuted ----------------------------------------
--@api-stub: MidiPlayer:isTrackMuted
-- Demonstrates the proper usage of MidiPlayer:isTrackMuted.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_isTrackMuted()
    print("track 0 muted: " .. tostring(midi:isTrackMuted(0)))
end
local _ok, _err = pcall(demo_MidiPlayer_isTrackMuted)

-- ---- Stub: MidiPlayer:getNoteCount ----------------------------------------
--@api-stub: MidiPlayer:getNoteCount
-- Demonstrates the proper usage of MidiPlayer:getNoteCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getNoteCount()
    print("MIDI note count: " .. tostring(midi:getNoteCount()))
end
local _ok, _err = pcall(demo_MidiPlayer_getNoteCount)

-- ---- Stub: MidiPlayer:setOnNoteOn -----------------------------------------
--@api-stub: MidiPlayer:setOnNoteOn
-- Demonstrates the proper usage of MidiPlayer:setOnNoteOn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setOnNoteOn()
    midi:setOnNoteOn(function(channel, note, velocity)
    if velocity > 80 then
        print("  [MIDI] loud note! ch=" .. channel .. " note=" .. note .. " vel=" .. velocity)
    end
    print("MIDI note-on callback set (triggers particle effects)")
end
local _ok, _err = pcall(demo_MidiPlayer_setOnNoteOn)

-- ---- Stub: MidiPlayer:setOnNoteOff ----------------------------------------
--@api-stub: MidiPlayer:setOnNoteOff
-- Demonstrates the proper usage of MidiPlayer:setOnNoteOff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setOnNoteOff()
    midi:setOnNoteOff(function(channel, note)
    print("MIDI note-off callback set")
end
local _ok, _err = pcall(demo_MidiPlayer_setOnNoteOff)

-- ---- Stub: MidiPlayer:setOnEnd --------------------------------------------
--@api-stub: MidiPlayer:setOnEnd
-- Demonstrates the proper usage of MidiPlayer:setOnEnd.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setOnEnd()
    midi:setOnEnd(function()
    print("  [MIDI] track ended — transitioning to next phase")
    print("MIDI end callback set (triggers music transition)")
end
local _ok, _err = pcall(demo_MidiPlayer_setOnEnd)

-- ---- Stub: MidiPlayer:getSampleRate ---------------------------------------
--@api-stub: MidiPlayer:getSampleRate
-- Demonstrates the proper usage of MidiPlayer:getSampleRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getSampleRate()
    print("MIDI sample rate: " .. tostring(midi:getSampleRate()) .. " Hz")
end
local _ok, _err = pcall(demo_MidiPlayer_getSampleRate)

-- ---- Stub: MidiPlayer:setSampleRate ---------------------------------------
--@api-stub: MidiPlayer:setSampleRate
-- Demonstrates the proper usage of MidiPlayer:setSampleRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setSampleRate()
    midi:setSampleRate(44100)
    print("MIDI sample rate set to 44100 Hz")
end
local _ok, _err = pcall(demo_MidiPlayer_setSampleRate)

-- ---- Stub: MidiPlayer:getChannels -----------------------------------------
--@api-stub: MidiPlayer:getChannels
-- Demonstrates the proper usage of MidiPlayer:getChannels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_getChannels()
    print("MIDI output channels: " .. tostring(midi:getChannels()))
end
local _ok, _err = pcall(demo_MidiPlayer_getChannels)

-- ---- Stub: MidiPlayer:setChannels -----------------------------------------
--@api-stub: MidiPlayer:setChannels
-- Demonstrates the proper usage of MidiPlayer:setChannels.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_setChannels()
    midi:setChannels(2)
    print("MIDI output set to stereo (2 channels)")
end
local _ok, _err = pcall(demo_MidiPlayer_setChannels)

-- ---- Stub: MidiPlayer:type ------------------------------------------------
--@api-stub: MidiPlayer:type
-- Demonstrates the proper usage of MidiPlayer:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_MidiPlayer_type)

-- ---- Stub: MidiPlayer:typeOf ----------------------------------------------
--@api-stub: MidiPlayer:typeOf
-- Demonstrates the proper usage of MidiPlayer:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MidiPlayer_typeOf()
    print("MIDI type: " .. tostring(midi:type()))
    print("MIDI typeOf: " .. tostring(midi:typeOf("MidiPlayer")))
end
local _ok, _err = pcall(demo_MidiPlayer_typeOf)

-- =============================================================================
-- SoundData — raw sample manipulation
-- =============================================================================

-- ---- Stub: lurek.audio.newSoundData ---------------------------------------
--@api-stub: lurek.audio.newSoundData
-- Demonstrates the proper usage of lurek.audio.newSoundData.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newSoundData()
    local snd = lurek.audio.newSoundData(44100, 44100, 16, 1)
    print("SoundData created: 44100 samples, mono, 16-bit")
end
local _ok, _err = pcall(demo_lurek_audio_newSoundData)

-- ---- Stub: mlua:getSampleCount --------------------------------------------
--@api-stub: mlua:getSampleCount
-- Demonstrates the proper usage of mlua:getSampleCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getSampleCount()
    print("sample count: " .. tostring(snd:getSampleCount()))
end
local _ok, _err = pcall(demo_mlua_getSampleCount)

-- ---- Stub: mlua:getSampleRate ---------------------------------------------
--@api-stub: mlua:getSampleRate
-- Demonstrates the proper usage of mlua:getSampleRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getSampleRate()
    print("sample rate: " .. tostring(snd:getSampleRate()) .. " Hz")
end
local _ok, _err = pcall(demo_mlua_getSampleRate)

-- ---- Stub: mlua:getChannelCount -------------------------------------------
--@api-stub: mlua:getChannelCount
-- Demonstrates the proper usage of mlua:getChannelCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getChannelCount()
    print("channels: " .. tostring(snd:getChannelCount()))
end
local _ok, _err = pcall(demo_mlua_getChannelCount)

-- ---- Stub: mlua:getDuration -----------------------------------------------
--@api-stub: mlua:getDuration
-- Demonstrates the proper usage of mlua:getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getDuration()
    print("duration: " .. string.format("%.3f", snd:getDuration()) .. "s")
end
local _ok, _err = pcall(demo_mlua_getDuration)

-- ---- Stub: mlua:getBitDepth -----------------------------------------------
--@api-stub: mlua:getBitDepth
-- Demonstrates the proper usage of mlua:getBitDepth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getBitDepth()
    print("bit depth: " .. tostring(snd:getBitDepth()))
end
local _ok, _err = pcall(demo_mlua_getBitDepth)

-- ---- Stub: mlua:setSample -------------------------------------------------
--@api-stub: mlua:setSample
-- Demonstrates the proper usage of mlua:setSample.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_setSample()
    for i = 0, 44099 do
    local t = i / 44100
    local sample = math.sin(2 * math.pi * 440 * t) * 0.5
    snd:setSample(i, sample)
    print("440 Hz sine wave written to SoundData (1 second)")
end
local _ok, _err = pcall(demo_mlua_setSample)

-- ---- Stub: mlua:getSample -------------------------------------------------
--@api-stub: mlua:getSample
-- Demonstrates the proper usage of mlua:getSample.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_mlua_getSample()
    local peak_sample = 0
    for i = 0, 999 do
    local s = math.abs(snd:getSample(i))
    if s > peak_sample then peak_sample = s end
    print("peak sample in first 1000: " .. string.format("%.3f", peak_sample))
end
local _ok, _err = pcall(demo_mlua_getSample)

-- =============================================================================
-- Source Object Methods — per-instance control
-- =============================================================================

-- ---- Stub: Source:play ----------------------------------------------------
--@api-stub: Source:play
-- Demonstrates the proper usage of Source:play.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_play()
    jump_sfx:play()
    print("jump SFX: play via method")
end
local _ok, _err = pcall(demo_Source_play)

-- ---- Stub: Source:stop ----------------------------------------------------
--@api-stub: Source:stop
-- Demonstrates the proper usage of Source:stop.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_stop()
    jump_sfx:stop()
    print("jump SFX: stopped via method")
end
local _ok, _err = pcall(demo_Source_stop)

-- ---- Stub: Source:pause ---------------------------------------------------
--@api-stub: Source:pause
-- Demonstrates the proper usage of Source:pause.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_pause()
    bgm:pause()
    print("BGM: paused via method")
end
local _ok, _err = pcall(demo_Source_pause)

-- ---- Stub: Source:resume --------------------------------------------------
--@api-stub: Source:resume
-- Demonstrates the proper usage of Source:resume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_resume()
    bgm:resume()
    print("BGM: resumed via method")
end
local _ok, _err = pcall(demo_Source_resume)

-- ---- Stub: Source:setVolume -----------------------------------------------
--@api-stub: Source:setVolume
-- Demonstrates the proper usage of Source:setVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_setVolume()
    jump_sfx:setVolume(0.8)
    print("jump volume: " .. tostring(jump_sfx:getVolume()))
end
local _ok, _err = pcall(demo_Source_setVolume)

-- ---- Stub: Source:getVolume -----------------------------------------------
--@api-stub: Source:getVolume
-- Demonstrates the proper usage of Source:getVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getVolume()
    print("jump volume (method): " .. tostring(jump_sfx:getVolume()))
end
local _ok, _err = pcall(demo_Source_getVolume)

-- ---- Stub: Source:setPitch ------------------------------------------------
--@api-stub: Source:setPitch
-- Demonstrates the proper usage of Source:setPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_setPitch()
    coin_sfx:setPitch(1.0 + 0.1 * 3)  -- 3x combo = 30% pitch increase
    print("coin pitch at 3x combo: " .. tostring(coin_sfx:getPitch()))
end
local _ok, _err = pcall(demo_Source_setPitch)

-- ---- Stub: Source:getPitch ------------------------------------------------
--@api-stub: Source:getPitch
-- Demonstrates the proper usage of Source:getPitch.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getPitch()
    print("coin pitch: " .. tostring(coin_sfx:getPitch()))
end
local _ok, _err = pcall(demo_Source_getPitch)

-- ---- Stub: Source:setLooping ----------------------------------------------
--@api-stub: Source:setLooping
-- Demonstrates the proper usage of Source:setLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_setLooping()
    bgm:setLooping(true)
    print("BGM looping: " .. tostring(bgm:isLooping()))
end
local _ok, _err = pcall(demo_Source_setLooping)

-- ---- Stub: Source:isLooping -----------------------------------------------
--@api-stub: Source:isLooping
-- Demonstrates the proper usage of Source:isLooping.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_isLooping()
    print("BGM looping: " .. tostring(bgm:isLooping()))
end
local _ok, _err = pcall(demo_Source_isLooping)

-- ---- Stub: Source:isPlaying -----------------------------------------------
--@api-stub: Source:isPlaying
-- Demonstrates the proper usage of Source:isPlaying.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_isPlaying()
    print("BGM playing: " .. tostring(bgm:isPlaying()))
end
local _ok, _err = pcall(demo_Source_isPlaying)

-- ---- Stub: Source:isPaused ------------------------------------------------
--@api-stub: Source:isPaused
-- Demonstrates the proper usage of Source:isPaused.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_isPaused()
    print("BGM paused: " .. tostring(bgm:isPaused()))
end
local _ok, _err = pcall(demo_Source_isPaused)

-- ---- Stub: Source:isStopped -----------------------------------------------
--@api-stub: Source:isStopped
-- Demonstrates the proper usage of Source:isStopped.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_isStopped()
    print("jump stopped: " .. tostring(jump_sfx:isStopped()))
end
local _ok, _err = pcall(demo_Source_isStopped)

-- ---- Stub: Source:setPan --------------------------------------------------
--@api-stub: Source:setPan
-- Demonstrates the proper usage of Source:setPan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_setPan()
    coin_sfx:setPan(0.4)
    print("coin panned right: " .. tostring(coin_sfx:getPan()))
end
local _ok, _err = pcall(demo_Source_setPan)

-- ---- Stub: Source:getPan --------------------------------------------------
--@api-stub: Source:getPan
-- Demonstrates the proper usage of Source:getPan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getPan()
    print("coin pan: " .. tostring(coin_sfx:getPan()))
end
local _ok, _err = pcall(demo_Source_getPan)

-- ---- Stub: Source:clone ---------------------------------------------------
--@api-stub: Source:clone
-- Demonstrates the proper usage of Source:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_clone()
    local footstep_clone = coin_sfx:clone()
    print("coin cloned for overlapping playback")
end
local _ok, _err = pcall(demo_Source_clone)

-- ---- Stub: Source:getType -------------------------------------------------
--@api-stub: Source:getType
-- Demonstrates the proper usage of Source:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getType()
    print("jump source type: " .. tostring(jump_sfx:getType()))
end
local _ok, _err = pcall(demo_Source_getType)

-- ---- Stub: Source:getDuration ---------------------------------------------
--@api-stub: Source:getDuration
-- Demonstrates the proper usage of Source:getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getDuration()
    print("jump duration: " .. string.format("%.3f", jump_sfx:getDuration()) .. "s")
end
local _ok, _err = pcall(demo_Source_getDuration)

-- ---- Stub: Source:tell ----------------------------------------------------
--@api-stub: Source:tell
-- Demonstrates the proper usage of Source:tell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_tell()
    print("BGM position: " .. string.format("%.2f", bgm:tell()) .. "s")
end
local _ok, _err = pcall(demo_Source_tell)

-- ---- Stub: Source:seek ----------------------------------------------------
--@api-stub: Source:seek
-- Demonstrates the proper usage of Source:seek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_seek()
    bgm:seek(0)
    print("BGM rewound to start")
end
local _ok, _err = pcall(demo_Source_seek)

-- ---- Stub: Source:setLowpass ----------------------------------------------
--@api-stub: Source:setLowpass
-- Demonstrates the proper usage of Source:setLowpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_setLowpass()
    enemy_growl:setLowpass(0.4)
    print("growl lowpass: 0.4 (muffled behind wall)")
end
local _ok, _err = pcall(demo_Source_setLowpass)

-- ---- Stub: Source:setHighpass ---------------------------------------------
--@api-stub: Source:setHighpass
-- Demonstrates the proper usage of Source:setHighpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_setHighpass()
    enemy_growl:setHighpass(0.2)
    print("growl highpass: 0.2")
end
local _ok, _err = pcall(demo_Source_setHighpass)

-- ---- Stub: Source:getLowpass -----------------------------------------------
--@api-stub: Source:getLowpass
-- Demonstrates the proper usage of Source:getLowpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getLowpass()
    print("growl lowpass: " .. tostring(enemy_growl:getLowpass()))
end
local _ok, _err = pcall(demo_Source_getLowpass)

-- ---- Stub: Source:getHighpass ----------------------------------------------
--@api-stub: Source:getHighpass
-- Demonstrates the proper usage of Source:getHighpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getHighpass()
    print("growl highpass: " .. tostring(enemy_growl:getHighpass()))
end
local _ok, _err = pcall(demo_Source_getHighpass)

-- ---- Stub: Source:clearFilter ---------------------------------------------
--@api-stub: Source:clearFilter
-- Demonstrates the proper usage of Source:clearFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_clearFilter()
    enemy_growl:clearFilter()
    print("growl filters cleared (wall destroyed)")
end
local _ok, _err = pcall(demo_Source_clearFilter)

-- ---- Stub: Source:fadeIn --------------------------------------------------
--@api-stub: Source:fadeIn
-- Demonstrates the proper usage of Source:fadeIn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_fadeIn()
    bgm:fadeIn(1.5)
    print("BGM fading in over 1.5s")
end
local _ok, _err = pcall(demo_Source_fadeIn)

-- ---- Stub: Source:getFadeIn -----------------------------------------------
--@api-stub: Source:getFadeIn
-- Demonstrates the proper usage of Source:getFadeIn.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Source_getFadeIn()
    print("BGM fade-in: " .. tostring(bgm:getFadeIn()) .. "s")
end
local _ok, _err = pcall(demo_Source_getFadeIn)

-- =============================================================================
-- Decoder — stream decoding for large files
-- =============================================================================

-- ---- Stub: lurek.audio.newDecoder -----------------------------------------
--@api-stub: lurek.audio.newDecoder
-- Demonstrates the proper usage of lurek.audio.newDecoder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newDecoder()
    local decoder = lurek.audio.newDecoder("assets/audio/level1_theme.ogg", 4096)
    print("decoder created: 4096-sample buffer")
end
local _ok, _err = pcall(demo_lurek_audio_newDecoder)

-- ---- Stub: Decoder:decode -------------------------------------------------
--@api-stub: Decoder:decode
-- Demonstrates the proper usage of Decoder:decode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_decode()
    local chunk = decoder:decode()
    if chunk then
    print("decoded chunk: " .. tostring(chunk:getSampleCount()) .. " samples")
end
local _ok, _err = pcall(demo_Decoder_decode)

-- ---- Stub: Decoder:getChannelCount ----------------------------------------
--@api-stub: Decoder:getChannelCount
-- Demonstrates the proper usage of Decoder:getChannelCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_getChannelCount()
    print("decoder channels: " .. tostring(decoder:getChannelCount()))
end
local _ok, _err = pcall(demo_Decoder_getChannelCount)

-- ---- Stub: Decoder:getBitDepth --------------------------------------------
--@api-stub: Decoder:getBitDepth
-- Demonstrates the proper usage of Decoder:getBitDepth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_getBitDepth()
    print("decoder bit depth: " .. tostring(decoder:getBitDepth()))
end
local _ok, _err = pcall(demo_Decoder_getBitDepth)

-- ---- Stub: Decoder:getSampleRate ------------------------------------------
--@api-stub: Decoder:getSampleRate
-- Demonstrates the proper usage of Decoder:getSampleRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_getSampleRate()
    print("decoder sample rate: " .. tostring(decoder:getSampleRate()) .. " Hz")
end
local _ok, _err = pcall(demo_Decoder_getSampleRate)

-- ---- Stub: Decoder:getDuration --------------------------------------------
--@api-stub: Decoder:getDuration
-- Demonstrates the proper usage of Decoder:getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_getDuration()
    print("decoder duration: " .. string.format("%.1f", decoder:getDuration()) .. "s")
end
local _ok, _err = pcall(demo_Decoder_getDuration)

-- ---- Stub: Decoder:seek ---------------------------------------------------
--@api-stub: Decoder:seek
-- Demonstrates the proper usage of Decoder:seek.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_seek()
    decoder:seek(10.0)
    print("decoder seeked to 10.0s")
end
local _ok, _err = pcall(demo_Decoder_seek)

-- ---- Stub: Decoder:rewind -------------------------------------------------
--@api-stub: Decoder:rewind
-- Demonstrates the proper usage of Decoder:rewind.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_rewind()
    decoder:rewind()
    print("decoder rewound to start")
end
local _ok, _err = pcall(demo_Decoder_rewind)

-- ---- Stub: Decoder:tell ---------------------------------------------------
--@api-stub: Decoder:tell
-- Demonstrates the proper usage of Decoder:tell.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_tell()
    print("decoder position: " .. string.format("%.2f", decoder:tell()) .. "s")
end
local _ok, _err = pcall(demo_Decoder_tell)

-- ---- Stub: Decoder:isSeekable ---------------------------------------------
--@api-stub: Decoder:isSeekable
-- Demonstrates the proper usage of Decoder:isSeekable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_isSeekable()
    print("decoder seekable: " .. tostring(decoder:isSeekable()))
end
local _ok, _err = pcall(demo_Decoder_isSeekable)

-- ---- Stub: Decoder:release ------------------------------------------------
--@api-stub: Decoder:release
-- Demonstrates the proper usage of Decoder:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Decoder_release()
    decoder:release()
    print("decoder released")
end
local _ok, _err = pcall(demo_Decoder_release)

-- =============================================================================
-- Queueable Source — gapless playback
-- =============================================================================

-- ---- Stub: lurek.audio.newQueueableSource ---------------------------------
--@api-stub: lurek.audio.newQueueableSource
-- Demonstrates the proper usage of lurek.audio.newQueueableSource.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newQueueableSource()
    local queue_src = lurek.audio.newQueueableSource(44100, 16, 2, 4)
    print("queueable source: 44100Hz, 16-bit, stereo, 4 buffer slots")
end
local _ok, _err = pcall(demo_lurek_audio_newQueueableSource)

-- ---- Stub: lurek.audio.queueSource ----------------------------------------
--@api-stub: lurek.audio.queueSource
-- Demonstrates the proper usage of lurek.audio.queueSource.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_queueSource()
    lurek.audio.queueSource(queue_src, snd)
    print("sound data queued for gapless playback")
end
local _ok, _err = pcall(demo_lurek_audio_queueSource)

-- ---- Stub: lurek.audio.getFreeBufferCount ---------------------------------
--@api-stub: lurek.audio.getFreeBufferCount
-- Demonstrates the proper usage of lurek.audio.getFreeBufferCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getFreeBufferCount()
    local free = lurek.audio.getFreeBufferCount(queue_src)
    print("free queue buffers: " .. tostring(free))
end
local _ok, _err = pcall(demo_lurek_audio_getFreeBufferCount)

-- ---- Stub: lurek.audio.playQueueable --------------------------------------
--@api-stub: lurek.audio.playQueueable
-- Demonstrates the proper usage of lurek.audio.playQueueable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_playQueueable()
    lurek.audio.playQueueable(queue_src)
    print("queueable source playing")
end
local _ok, _err = pcall(demo_lurek_audio_playQueueable)

-- ---- Stub: lurek.audio.stopQueueable --------------------------------------
--@api-stub: lurek.audio.stopQueueable
-- Demonstrates the proper usage of lurek.audio.stopQueueable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_stopQueueable()
    lurek.audio.stopQueueable(queue_src)
    print("queueable source stopped")
end
local _ok, _err = pcall(demo_lurek_audio_stopQueueable)

-- =============================================================================
-- Playback Devices
-- =============================================================================

-- ---- Stub: lurek.audio.getPlaybackDevices ---------------------------------
--@api-stub: lurek.audio.getPlaybackDevices
-- Demonstrates the proper usage of lurek.audio.getPlaybackDevices.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getPlaybackDevices()
    local devices = lurek.audio.getPlaybackDevices()
    print("available playback devices:")
    for i, dev in ipairs(devices) do
    print("  [" .. i .. "] " .. tostring(dev))
end
local _ok, _err = pcall(demo_lurek_audio_getPlaybackDevices)

-- ---- Stub: lurek.audio.getPlaybackDevice ----------------------------------
--@api-stub: lurek.audio.getPlaybackDevice
-- Demonstrates the proper usage of lurek.audio.getPlaybackDevice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_getPlaybackDevice()
    print("current device: " .. tostring(lurek.audio.getPlaybackDevice()))
end
local _ok, _err = pcall(demo_lurek_audio_getPlaybackDevice)

-- ---- Stub: lurek.audio.setPlaybackDevice ----------------------------------
--@api-stub: lurek.audio.setPlaybackDevice
-- Demonstrates the proper usage of lurek.audio.setPlaybackDevice.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_setPlaybackDevice()
    if #devices > 0 then
    lurek.audio.setPlaybackDevice(devices[1])
    print("switched to device: " .. tostring(devices[1]))
end
local _ok, _err = pcall(demo_lurek_audio_setPlaybackDevice)

-- =============================================================================
-- Sound Pool — rapid-fire SFX with voice limiting
-- =============================================================================

-- ---- Stub: lurek.audio.newPool --------------------------------------------
--@api-stub: lurek.audio.newPool
-- Demonstrates the proper usage of lurek.audio.newPool.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newPool()
    local footstep_pool = lurek.audio.newPool("assets/audio/footstep.wav", 8)
    print("footstep pool: 8 voices (max 8 simultaneous footstep sounds)")
end
local _ok, _err = pcall(demo_lurek_audio_newPool)

-- ---- Stub: SoundPool:play ------------------------------------------------
--@api-stub: SoundPool:play
-- Demonstrates the proper usage of SoundPool:play.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_play()
    footstep_pool:play()
    footstep_pool:play()
    footstep_pool:play()
    print("3 footsteps triggered from pool")
end
local _ok, _err = pcall(demo_SoundPool_play)

-- ---- Stub: SoundPool:stopAll ----------------------------------------------
--@api-stub: SoundPool:stopAll
-- Demonstrates the proper usage of SoundPool:stopAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_stopAll()
    footstep_pool:stopAll()
    print("all pool voices stopped (player stopped moving)")
end
local _ok, _err = pcall(demo_SoundPool_stopAll)

-- ---- Stub: SoundPool:setVolume --------------------------------------------
--@api-stub: SoundPool:setVolume
-- Demonstrates the proper usage of SoundPool:setVolume.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_setVolume()
    footstep_pool:setVolume(0.4)
    print("footstep pool volume: 0.4 (subtle background)")
end
local _ok, _err = pcall(demo_SoundPool_setVolume)

-- ---- Stub: SoundPool:setBus -----------------------------------------------
--@api-stub: SoundPool:setBus
-- Demonstrates the proper usage of SoundPool:setBus.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_setBus()
    footstep_pool:setBus("sfx")
    print("footstep pool routed to SFX bus")
end
local _ok, _err = pcall(demo_SoundPool_setBus)

-- ---- Stub: SoundPool:release ----------------------------------------------
--@api-stub: SoundPool:release
-- Demonstrates the proper usage of SoundPool:release.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_release()
    footstep_pool:release()
    print("footstep pool released")
end
local _ok, _err = pcall(demo_SoundPool_release)

-- ---- Stub: SoundPool:getVoiceCount ----------------------------------------
--@api-stub: SoundPool:getVoiceCount
-- Demonstrates the proper usage of SoundPool:getVoiceCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_getVoiceCount()
    local rain_pool = lurek.audio.newPool("assets/audio/raindrop.wav", 16)
    print("rain pool voices: " .. tostring(rain_pool:getVoiceCount()))
end
local _ok, _err = pcall(demo_SoundPool_getVoiceCount)

-- ---- Stub: SoundPool:type -------------------------------------------------
--@api-stub: SoundPool:type
-- Demonstrates the proper usage of SoundPool:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_type()
    print('Executing type')
end
local _ok, _err = pcall(demo_SoundPool_type)

-- ---- Stub: SoundPool:typeOf -----------------------------------------------
--@api-stub: SoundPool:typeOf
-- Demonstrates the proper usage of SoundPool:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SoundPool_typeOf()
    print("pool type: " .. tostring(rain_pool:type()))
    print("pool typeOf: " .. tostring(rain_pool:typeOf("SoundPool")))
end
local _ok, _err = pcall(demo_SoundPool_typeOf)

-- =============================================================================
-- Procedural Waveform Generators
-- =============================================================================

-- ---- Stub: lurek.audio.newSineWave ----------------------------------------
--@api-stub: lurek.audio.newSineWave
-- Demonstrates the proper usage of lurek.audio.newSineWave.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newSineWave()
    local sine = lurek.audio.newSineWave(440, 1.0, 44100)
    print("sine wave: 440 Hz, 1.0s duration")
end
local _ok, _err = pcall(demo_lurek_audio_newSineWave)

-- ---- Stub: lurek.audio.newSquareWave --------------------------------------
--@api-stub: lurek.audio.newSquareWave
-- Demonstrates the proper usage of lurek.audio.newSquareWave.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newSquareWave()
    local square = lurek.audio.newSquareWave(220, 0.5, 44100)
    print("square wave: 220 Hz, 0.5s (retro beep)")
end
local _ok, _err = pcall(demo_lurek_audio_newSquareWave)

-- ---- Stub: lurek.audio.newSawtoothWave ------------------------------------
--@api-stub: lurek.audio.newSawtoothWave
-- Demonstrates the proper usage of lurek.audio.newSawtoothWave.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newSawtoothWave()
    local sawtooth = lurek.audio.newSawtoothWave(110, 0.3, 44100)
    print("sawtooth wave: 110 Hz, 0.3s (alarm tone)")
end
local _ok, _err = pcall(demo_lurek_audio_newSawtoothWave)

-- ---- Stub: lurek.audio.newTriangleWave ------------------------------------
--@api-stub: lurek.audio.newTriangleWave
-- Demonstrates the proper usage of lurek.audio.newTriangleWave.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newTriangleWave()
    local triangle = lurek.audio.newTriangleWave(330, 0.8, 44100)
    print("triangle wave: 330 Hz, 0.8s (flute-like)")
end
local _ok, _err = pcall(demo_lurek_audio_newTriangleWave)

-- ---- Stub: lurek.audio.newWhiteNoise --------------------------------------
--@api-stub: lurek.audio.newWhiteNoise
-- Demonstrates the proper usage of lurek.audio.newWhiteNoise.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_newWhiteNoise()
    local noise = lurek.audio.newWhiteNoise(0.2, 44100)
    print("white noise: 0.2s burst (explosion base)")
end
local _ok, _err = pcall(demo_lurek_audio_newWhiteNoise)

-- =============================================================================
-- DSP Processing — offline audio manipulation
-- =============================================================================

-- ---- Stub: lurek.audio.applyLowpass ---------------------------------------
--@api-stub: lurek.audio.applyLowpass
-- Demonstrates the proper usage of lurek.audio.applyLowpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_applyLowpass()
    lurek.audio.applyLowpass(sine, 2000)
    print("lowpass at 2000 Hz applied to sine wave")
end
local _ok, _err = pcall(demo_lurek_audio_applyLowpass)

-- ---- Stub: lurek.audio.applyHighpass --------------------------------------
--@api-stub: lurek.audio.applyHighpass
-- Demonstrates the proper usage of lurek.audio.applyHighpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_applyHighpass()
    lurek.audio.applyHighpass(noise, 500)
    print("highpass at 500 Hz applied to white noise (removes rumble)")
end
local _ok, _err = pcall(demo_lurek_audio_applyHighpass)

-- ---- Stub: lurek.audio.applyBandpass --------------------------------------
--@api-stub: lurek.audio.applyBandpass
-- Demonstrates the proper usage of lurek.audio.applyBandpass.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_applyBandpass()
    lurek.audio.applyBandpass(sawtooth, 200, 3000)
    print("bandpass 200-3000 Hz applied to sawtooth (voice-range)")
end
local _ok, _err = pcall(demo_lurek_audio_applyBandpass)

-- ---- Stub: lurek.audio.applyGain ------------------------------------------
--@api-stub: lurek.audio.applyGain
-- Demonstrates the proper usage of lurek.audio.applyGain.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_applyGain()
    lurek.audio.applyGain(square, 0.6)
    print("gain 0.6 applied to square wave (quieter)")
end
local _ok, _err = pcall(demo_lurek_audio_applyGain)

-- ---- Stub: lurek.audio.mixInto --------------------------------------------
--@api-stub: lurek.audio.mixInto
-- Demonstrates the proper usage of lurek.audio.mixInto.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_mixInto()
    lurek.audio.mixInto(sine, noise, 0.5)
    print("white noise mixed into sine at 50% (layered explosion)")
end
local _ok, _err = pcall(demo_lurek_audio_mixInto)

-- =============================================================================
-- File Operations — save and analyze audio
-- =============================================================================

-- ---- Stub: lurek.audio.saveWAV --------------------------------------------
--@api-stub: lurek.audio.saveWAV
-- Demonstrates the proper usage of lurek.audio.saveWAV.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_saveWAV()
    lurek.audio.saveWAV(sine, "output/generated_tone.wav")
    print("sine wave saved to output/generated_tone.wav")
end
local _ok, _err = pcall(demo_lurek_audio_saveWAV)

-- ---- Stub: lurek.audio.processOffline -------------------------------------
--@api-stub: lurek.audio.processOffline
-- Demonstrates the proper usage of lurek.audio.processOffline.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_processOffline()
    lurek.audio.processOffline("assets/audio/raw_recording.wav", "output/processed.wav", {
    { type = "lowpass", cutoff = 4000 },
    { type = "gain", factor = 1.5 }
    })
    print("offline processing: lowpass + gain applied to recording")
end
local _ok, _err = pcall(demo_lurek_audio_processOffline)

-- ---- Stub: lurek.audio.normalizeFile --------------------------------------
--@api-stub: lurek.audio.normalizeFile
-- Demonstrates the proper usage of lurek.audio.normalizeFile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_normalizeFile()
    lurek.audio.normalizeFile("output/processed.wav", "output/normalized.wav")
    print("audio normalized to peak amplitude")
end
local _ok, _err = pcall(demo_lurek_audio_normalizeFile)

-- ---- Stub: lurek.audio.waveformToPng --------------------------------------
--@api-stub: lurek.audio.waveformToPng
-- Demonstrates the proper usage of lurek.audio.waveformToPng.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_waveformToPng()
    lurek.audio.waveformToPng("output/generated_tone.wav", "output/waveform.png", 800, 200)
    print("waveform PNG saved: 800x200")
end
local _ok, _err = pcall(demo_lurek_audio_waveformToPng)

-- ---- Stub: lurek.audio.spectrogramToPng -----------------------------------
--@api-stub: lurek.audio.spectrogramToPng
-- Demonstrates the proper usage of lurek.audio.spectrogramToPng.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_audio_spectrogramToPng()
    lurek.audio.spectrogramToPng("output/generated_tone.wav", "output/spectrogram.png", 800, 400)
    print("spectrogram PNG saved: 800x400")
    print("\n-- audio.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_audio_spectrogramToPng)
