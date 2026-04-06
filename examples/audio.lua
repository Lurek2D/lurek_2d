-- examples/audio.lua
-- Luna2D luna.audio API Reference
-- This file is documentation code, not a runnable game.
-- Covers Sources, Buses, MIDI Player, and SoundData.

-- ─────────────────────────────────────────────────────────────────────────────
-- Creating Audio Sources
-- ─────────────────────────────────────────────────────────────────────────────

-- Source types:
--   "static"  — fully decoded into RAM, low latency, best for short SFX
--   "stream"  — decoded on the fly, lower RAM usage, best for music/ambience

local sfx_jump  = luna.audio.newSource("sounds/jump.wav",     "static")
local sfx_coin  = luna.audio.newSource("sounds/coin.ogg",     "static")
local music     = luna.audio.newSource("music/theme.ogg",     "stream")
local ambience  = luna.audio.newSource("ambient/forest.ogg",  "stream")

-- ─────────────────────────────────────────────────────────────────────────────
-- Playback Control
-- ─────────────────────────────────────────────────────────────────────────────

music:play()
music:pause()
music:resume()
music:stop()   -- rewinds to start

-- Query playback state
local playing  = music:isPlaying()
local paused   = music:isPaused()
local stopped  = music:isStopped()

-- Duration in seconds (may be nil for streams before they start)
local duration = music:getDuration()

-- Current playback position in seconds
local pos = music:tell()

-- Seek to a position (static sources only; streams may not support exact seek)
music:seek(30.5)  -- jump to 30.5 seconds

-- ─────────────────────────────────────────────────────────────────────────────
-- Volume, Pitch, Pan
-- ─────────────────────────────────────────────────────────────────────────────

-- Volume: 0.0 (silent) to 1.0 (full) and beyond (amplify)
music:setVolume(0.75)
local vol = music:getVolume()

-- Pitch: 1.0 = normal, 2.0 = one octave up, 0.5 = one octave down
music:setPitch(1.05)  -- slight pitch shift
local pitch = music:getPitch()

-- Stereo pan: -1.0 = full left, 0.0 = centre, +1.0 = full right
sfx_jump:setPan(-0.3)  -- slightly to the left
local pan = sfx_jump:getPan()

-- ─────────────────────────────────────────────────────────────────────────────
-- Looping
-- ─────────────────────────────────────────────────────────────────────────────

music:setLooping(true)     -- loop indefinitely
music:setLooping(false)    -- play once and stop
local loops = music:isLooping()

-- ─────────────────────────────────────────────────────────────────────────────
-- Filters (EQ / tone shaping)
-- ─────────────────────────────────────────────────────────────────────────────

-- Low-pass filter: attenuates frequencies above the cutoff (muffled sound)
music:setLowpass(800)   -- 800 Hz cutoff (good for underwater or behind walls)
local lp = music:getLowpass()

-- High-pass filter: attenuates frequencies below the cutoff (thin sound)
music:setHighpass(200)  -- 200 Hz cutoff (removes bass rumble)
local hp = music:getHighpass()

-- Remove all filters
music:clearFilter()

-- ─────────────────────────────────────────────────────────────────────────────
-- Fade In
-- ─────────────────────────────────────────────────────────────────────────────

-- Begin playback with a fade-in over N seconds
music:fadeIn(2.0)         -- fade in over 2 s
local fade_dur = music:getFadeIn()

-- ─────────────────────────────────────────────────────────────────────────────
-- Clone (for polyphonic playback of the same sound)
-- ─────────────────────────────────────────────────────────────────────────────

-- Clone creates a second source referencing the same underlying audio data.
-- Use this to play the same sound effect multiple times simultaneously.
local sfx2 = sfx_coin:clone()
sfx2:play()   -- plays at the same time as sfx_coin

-- Source type query
local t = sfx_jump:getType()   -- → "static" or "stream"

-- ─────────────────────────────────────────────────────────────────────────────
-- Master Volume
-- ─────────────────────────────────────────────────────────────────────────────

luna.audio.setMasterVolume(0.9)
local master = luna.audio.getMasterVolume()

-- Get a list of all currently playing/paused Sources
local active = luna.audio.getActiveSources()  -- → {Source, Source, ...}

-- ─────────────────────────────────────────────────────────────────────────────
-- Buses (mixer channels for category-level volume control)
-- ─────────────────────────────────────────────────────────────────────────────

-- Get or create a named bus (buses are global singletons by name)
local sfx_bus   = luna.audio.newBus("sfx")
local music_bus = luna.audio.newBus("music")
local ui_bus    = luna.audio.newBus("ui")

-- Retrieve an already-created bus by name
local mb = luna.audio.getBus("music")

-- Bus controls (affect all sources routed through this bus)
music_bus:setVolume(0.8)
local bvol = music_bus:getVolume()

music_bus:setPitch(1.0)
local bpitch = music_bus:getPitch()

sfx_bus:pause()
sfx_bus:resume()
local is_paused = sfx_bus:isPaused()

local bus_name = music_bus:getName()  -- → "music"

-- Route a source to a bus (platform dependent / future-facing)
-- Currently sources play through the default mixer channel.
-- Bus routing may be extended in future versions.

-- ─────────────────────────────────────────────────────────────────────────────
-- SoundData — Raw PCM Audio Representation
-- ─────────────────────────────────────────────────────────────────────────────

-- Load compressed audio into a decoded PCM buffer.
-- Unlike "static" Sources, SoundData gives you sample-level access.
-- This is useful for: procedural audio, oscilloscope visualisers, custom pitch shifting.

local sd = luna.audio.newSource("sounds/beep.ogg", "static")
local sound_data = sd:getSoundData and sd:getSoundData()  -- retrieve from source if available
-- Or load SoundData directly:
-- local sound_data = luna.sound.newSoundData("sounds/beep.ogg")

-- Metadata
local channels    = sound_data:getChannelCount()   -- 1 (mono) or 2 (stereo)
local bit_depth   = sound_data:getBitDepth()       -- 8 or 16
local sample_rate = sound_data:getSampleRate()     -- e.g. 44100
local dur         = sound_data:getDuration()       -- seconds

-- Seek / tell (by sample offset)
sound_data:seek(0)     -- rewind
local s = sound_data:tell()
local can_seek = sound_data:isSeekable()

-- Decode to a new independent buffer (creates a copy)
local decoded = sound_data:decode()

-- Release memory when finished
sound_data:release()

-- ─────────────────────────────────────────────────────────────────────────────
-- MIDI Playback  (midi_decoder + midi_player)
-- ─────────────────────────────────────────────────────────────────────────────

-- Step 1: Create a decoder and load a SoundFont (SF2 instrument bank)
local decoder = luna.audio.newMidiDecoder()
decoder:setSoundFont("instruments/gm.sf2")  -- standard General MIDI font
decoder:load("music/overworld.mid")

-- Optionally load from in-memory data
-- decoder:loadData(bytes)

local is_loaded   = decoder:isLoaded()

-- Step 2: Create a player wrapping the decoder
local player = luna.audio.newMidiPlayer(decoder)

-- Basic transport
player:play()
player:pause()
player:stop()

local playing_midi = player:isPlaying()
local paused_midi  = player:isPaused()

-- Seek / tell in seconds
player:seek(60.0)
local t2 = player:tell()

local total = player:getDuration()

-- Looping
player:setLooping(true)
local looping = player:isLooping()

-- Volume
player:setVolume(1.0)

-- Tempo
local orig_bpm = player:getOriginalTempo()  -- BPM from the MIDI file
player:setTempo(140)                         -- override BPM
player:setTempoScale(1.25)                   -- scale relative to file tempo

-- Per-MIDI-channel control (channels 0–15; channel 9 = drums)
player:setChannelVolume(0, 0.8)   -- channel 0 at 80%
local ch_vol = player:getChannelVolume(0)

player:setChannelMuted(9, true)   -- silence drums
local muted = player:isChannelMuted(9)

player:soloChannel(0)   -- play only channel 0
player:unsoloAll()      -- restore all channels

-- Per-track control
local tracks = player:getTrackCount()
player:setTrackMuted(2, true)    -- mute track 2 (0-based)
local track_muted = player:isTrackMuted(2)
