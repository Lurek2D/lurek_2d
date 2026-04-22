-- content/examples/audio.lua
-- love2d-style usage snippets for the lurek.audio API (212 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/audio.lua

-- ── lurek.audio.* functions ──

--@api-stub: lurek.audio.newSource
-- Loads an audio file and returns a Source handle.
-- Build once at startup; reuse across frames.
local jump = lurek.audio.newSource("sfx/jump.ogg")
jump:setVolume(0.7)
jump:play()

--@api-stub: lurek.audio.play
-- Plays a source, with optional bus routing via options table.
-- Trigger from input, timers, or game events.
local music = lurek.audio.newSource("music/theme.ogg")
music:setLooping(true)
lurek.audio.play(music)

--@api-stub: lurek.audio.stop
-- Stops playback and resets seek position.
-- Trigger from input, timers, or game events.
local sfx = lurek.audio.newSource("sfx/loop.ogg")
sfx:play()
lurek.audio.stop(sfx)

--@api-stub: lurek.audio.setVolume
-- Sets source playback volume.
-- Apply at startup or in response to user input.
lurek.audio.setVolume(0.5)
local v = lurek.audio.getVolume and lurek.audio.getVolume() or 0.5
print("master volume:", v)

--@api-stub: lurek.audio.getVolume
-- Returns the source volume.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getVolume(id_val)
print("getVolume:", value)
return value

--@api-stub: lurek.audio.pause
-- Pauses playback at the current position.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.pause(id_val)
print("pause fired")
print("ok")

--@api-stub: lurek.audio.resume
-- Resumes playback from pause.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.resume(id_val)
print("resume fired")
print("ok")

--@api-stub: lurek.audio.setPitch
-- Sets source pitch multiplier.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setPitch(id_val, pitch)
print("setPitch applied")
print("ok")

--@api-stub: lurek.audio.getPitch
-- Returns the source pitch multiplier.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getPitch(id_val)
print("getPitch:", value)
return value

--@api-stub: lurek.audio.isPlaying
-- Returns true if the source is playing.
-- Use as a guard inside lurek.update or event handlers.
if lurek.audio.isPlaying(id_val) then
  print("isPlaying -> true")
end

--@api-stub: lurek.audio.isPaused
-- Returns true if the source is paused.
-- Use as a guard inside lurek.update or event handlers.
if lurek.audio.isPaused(id_val) then
  print("isPaused -> true")
end

--@api-stub: lurek.audio.isStopped
-- Returns true if the source is stopped.
-- Use as a guard inside lurek.update or event handlers.
if lurek.audio.isStopped(id_val) then
  print("isStopped -> true")
end

--@api-stub: lurek.audio.setLooping
-- Enables or disables looping.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setLooping(id_val, looping)
print("setLooping applied")
print("ok")

--@api-stub: lurek.audio.isLooping
-- Returns true if looping is enabled.
-- Use as a guard inside lurek.update or event handlers.
if lurek.audio.isLooping(id_val) then
  print("isLooping -> true")
end

--@api-stub: lurek.audio.playLooping
-- Plays the source in a continuous loop.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.playLooping(id_val)
print("playLooping fired")
print("ok")

--@api-stub: lurek.audio.setPan
-- Sets stereo panning (-1.0 left to 1.0 right).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setPan(id_val, pan)
print("setPan applied")
print("ok")

--@api-stub: lurek.audio.getPan
-- Returns the source stereo panning.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getPan(id_val)
print("getPan:", value)
return value

--@api-stub: lurek.audio.setMasterVolume
-- Sets the global master volume.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setMasterVolume(vol)
print("setMasterVolume applied")
print("ok")

--@api-stub: lurek.audio.getMasterVolume
-- Returns the global master volume.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getMasterVolume()
print("getMasterVolume:", value)
return value

--@api-stub: lurek.audio.getActiveSourceCount
-- Returns the number of currently playing sources.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getActiveSourceCount()
print("getActiveSourceCount:", value)
return value

--@api-stub: lurek.audio.getSourceCount
-- Returns the total number of registered sources.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getSourceCount()
print("getSourceCount:", value)
return value

--@api-stub: lurek.audio.getSourceType
-- Returns the type string ("static" or "stream") of a source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getSourceType(id_val)
print("getSourceType:", value)
return value

--@api-stub: lurek.audio.clone
-- Creates an independent copy of a source.
-- See the module spec for detailed semantics.
local result = lurek.audio.clone(id_val)
print("clone:", result)
return result

--@api-stub: lurek.audio.pauseAll
-- Pauses all currently playing sources.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.pauseAll()
print("pauseAll fired")
print("ok")

--@api-stub: lurek.audio.stopAll
-- Stops all currently playing sources.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.stopAll()
print("stopAll fired")
print("ok")

--@api-stub: lurek.audio.resumeAll
-- Resumes all paused sources.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.resumeAll()
print("resumeAll fired")
print("ok")

--@api-stub: lurek.audio.release
-- Releases a source and frees its memory.
-- See the module spec for detailed semantics.
local result = lurek.audio.release(id_val)
print("release:", result)
return result

--@api-stub: lurek.audio.newBus
-- Creates a named audio bus for grouping sources.
-- Build once at startup; reuse across frames.
local bus = lurek.audio.newBus("sfx/click.ogg")
print("created", bus)
return bus

--@api-stub: lurek.audio.setSourceBus
-- Assigns a source to a bus.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setSourceBus(id_val, bus_val)
print("setSourceBus applied")
print("ok")

--@api-stub: lurek.audio.getSourceBus
-- Returns the bus a source is assigned to, or nil.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getSourceBus(id_val)
print("getSourceBus:", value)
return value

--@api-stub: lurek.audio.getMaxSources
-- Returns the maximum number of simultaneous sources.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getMaxSources()
print("getMaxSources:", value)
return value

--@api-stub: lurek.audio.getDuration
-- Returns the total duration of a source in seconds.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getDuration(id_val)
print("getDuration:", value)
return value

--@api-stub: lurek.audio.tell
-- Returns the current playback position in seconds.
-- See the module spec for detailed semantics.
local result = lurek.audio.tell(id_val)
print("tell:", result)
return result

--@api-stub: lurek.audio.seek
-- Seeks to a time position in seconds.
-- See the module spec for detailed semantics.
local result = lurek.audio.seek(id_val, pos)
print("seek:", result)
return result

--@api-stub: lurek.audio.setLowpass
-- Applies a low-pass filter to a source.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setLowpass(id_val, cutoff_hz)
print("setLowpass applied")
print("ok")

--@api-stub: lurek.audio.setHighpass
-- Applies a high-pass filter to a source.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setHighpass(id_val, cutoff_hz)
print("setHighpass applied")
print("ok")

--@api-stub: lurek.audio.getLowpass
-- Returns the low-pass filter cutoff of a source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getLowpass(id_val)
print("getLowpass:", value)
return value

--@api-stub: lurek.audio.getHighpass
-- Returns the high-pass filter cutoff of a source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getHighpass(id_val)
print("getHighpass:", value)
return value

--@api-stub: lurek.audio.clearFilter
-- Removes any active filter from a source.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.audio.clearFilter(id_val)
print("clearFilter done")
print("ok")

--@api-stub: lurek.audio.fadeIn
-- Fades a source in from silence over the given duration.
-- See the module spec for detailed semantics.
local result = lurek.audio.fadeIn(id_val, dur)
print("fadeIn:", result)
return result

--@api-stub: lurek.audio.getFadeIn
-- Returns the fade-in duration of a source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getFadeIn(id_val)
print("getFadeIn:", value)
return value

--@api-stub: lurek.audio.setListener2D
-- Sets the 2D listener position for spatial audio.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setListener2D(100, 100)
print("setListener2D applied")
print("ok")

--@api-stub: lurek.audio.getListener2D
-- Returns the 2D listener position (x, y).
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getListener2D()
print("getListener2D:", value)
return value

--@api-stub: lurek.audio.setListener
-- Sets the 3D listener position.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setListener(100, 100, 0)
print("setListener applied")
print("ok")

--@api-stub: lurek.audio.getListener
-- Returns the 3D listener position (x, y, z).
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getListener()
print("getListener:", value)
return value

--@api-stub: lurek.audio.setPosition
-- Sets the 3D position of a source.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setPosition(id_val, 100, 100, 0)
print("setPosition applied")
print("ok")

--@api-stub: lurek.audio.getPosition
-- Returns the 3D position of a source (x, y, z).
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getPosition(id_val)
print("getPosition:", value)
return value

--@api-stub: lurek.audio.setVelocity
-- Sets the velocity of a source for Doppler.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setVelocity(id_val, 100, 100, 0)
print("setVelocity applied")
print("ok")

--@api-stub: lurek.audio.getVelocity
-- Returns the velocity of a source (x, y, z).
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getVelocity(id_val)
print("getVelocity:", value)
return value

--@api-stub: lurek.audio.setOrientation
-- Sets the 6-component orientation of a source.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setOrientation(id_val, fx, fy, fz, ux, uy, uz)
print("setOrientation applied")
print("ok")

--@api-stub: lurek.audio.getOrientation
-- Returns the 6-component orientation of a source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getOrientation(id_val)
print("getOrientation:", value)
return value

--@api-stub: lurek.audio.setDopplerScale
-- Sets the global Doppler effect scale.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setDopplerScale(1.0)
print("setDopplerScale applied")
print("ok")

--@api-stub: lurek.audio.getDopplerScale
-- Returns the current Doppler scale.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getDopplerScale()
print("getDopplerScale:", value)
return value

--@api-stub: lurek.audio.setDistanceModel
-- Sets the distance attenuation model.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setDistanceModel(model)
print("setDistanceModel applied")
print("ok")

--@api-stub: lurek.audio.getDistanceModel
-- Returns the current distance model name.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getDistanceModel()
print("getDistanceModel:", value)
return value

--@api-stub: lurek.audio.setMeter
-- Sets the master peak meter level (0.0â€“1.0).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setMeter(level)
print("setMeter applied")
print("ok")

--@api-stub: lurek.audio.getMeter
-- Returns the stored master peak meter level.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getMeter()
print("getMeter:", value)
return value

--@api-stub: lurek.audio.newMidiPlayer
-- Creates a MIDI player, optionally loading a file.
-- Build once at startup; reuse across frames.
local midiplayer = lurek.audio.newMidiPlayer("sfx/click.ogg")
print("created", midiplayer)
return midiplayer

--@api-stub: lurek.audio.newSoundData
-- Creates a SoundData from a file or as a silent buffer.
-- Build once at startup; reuse across frames.
local sounddata = lurek.audio.newSoundData({ x = 0, y = 0 })
print("created", sounddata)
return sounddata

--@api-stub: lurek.audio.setMidiSoundFont
-- Sets the global SoundFont for MIDI synthesis.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setMidiSoundFont("sfx/click.ogg")
print("setMidiSoundFont applied")
print("ok")

--@api-stub: lurek.audio.hasMidiSoundFont
-- Returns true if a SoundFont is loaded.
-- Use as a guard inside lurek.update or event handlers.
if lurek.audio.hasMidiSoundFont() then
  print("hasMidiSoundFont -> true")
end

--@api-stub: lurek.audio.clearMidiSoundFont
-- Unloads the active SoundFont.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.audio.clearMidiSoundFont()
print("clearMidiSoundFont done")
print("ok")

--@api-stub: lurek.audio.newDecoder
-- Creates a streaming audio decoder.
-- Build once at startup; reuse across frames.
local decoder = lurek.audio.newDecoder(source, buffersize)
print("created", decoder)
return decoder

--@api-stub: lurek.audio.newQueueableSource
-- Creates a queueable source for manual PCM buffering.
-- Build once at startup; reuse across frames.
local queueablesource = lurek.audio.newQueueableSource()
print("created", queueablesource)
return queueablesource

--@api-stub: lurek.audio.queueSource
-- Pushes a SoundData buffer into a queueable source.
-- See the module spec for detailed semantics.
local result = lurek.audio.queueSource(1, sd)
print("queueSource:", result)
return result

--@api-stub: lurek.audio.getFreeBufferCount
-- Returns the free buffer slots in a queueable source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getFreeBufferCount(1)
print("getFreeBufferCount:", value)
return value

--@api-stub: lurek.audio.playQueueable
-- Starts playback of a queueable source.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.playQueueable(1)
print("playQueueable fired")
print("ok")

--@api-stub: lurek.audio.stopQueueable
-- Stops a queueable source and drains its buffers.
-- Trigger from input, timers, or game events.
-- trigger from input or timer
lurek.audio.stopQueueable(1)
print("stopQueueable fired")
print("ok")

--@api-stub: lurek.audio.getPlaybackDevices
-- Returns a table of available audio output device names.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getPlaybackDevices()
print("getPlaybackDevices:", value)
return value

--@api-stub: lurek.audio.getPlaybackDevice
-- Returns the current audio output device name.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getPlaybackDevice()
print("getPlaybackDevice:", value)
return value

--@api-stub: lurek.audio.setPlaybackDevice
-- Selects an audio output device by name.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setPlaybackDevice("sfx/click.ogg")
print("setPlaybackDevice applied")
print("ok")

--@api-stub: lurek.audio.create_bus
-- Creates a bus by name (functional style).
-- Build once at startup; reuse across frames.
local create_bus = lurek.audio.create_bus("sfx/click.ogg", "sfx/click.ogg")
print("created", create_bus)
return create_bus

--@api-stub: lurek.audio.set_bus_volume
-- Sets a bus volume by name.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.set_bus_volume("sfx/click.ogg", volume)
print("set_bus_volume applied")
print("ok")

--@api-stub: lurek.audio.add_effect
-- Adds a DSP effect to a bus.
-- Side-effecting; safe to call any time after init.
lurek.audio.add_effect("sfx/click.ogg", "hello", { x = 0, y = 0 })
-- mutator; side effect applied
print("add_effect done")
print("ok")

--@api-stub: lurek.audio.remove_effect
-- Removes a DSP effect from a bus.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.audio.remove_effect("sfx/click.ogg", 1)
print("remove_effect done")
print("ok")

--@api-stub: lurek.audio.set_effect_param
-- Sets a parameter on a DSP effect.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.set_effect_param("sfx/click.ogg", 1, "sfx/click.ogg", value)
print("set_effect_param applied")
print("ok")

--@api-stub: lurek.audio.newSineWave
-- Generate a mono sine-wave SoundData buffer.
-- Build once at startup; reuse across frames.
local sinewave = lurek.audio.newSineWave(freq, 1.0, sample_rate, amplitude)
print("created", sinewave)
return sinewave

--@api-stub: lurek.audio.newSquareWave
-- Generate a mono square-wave SoundData buffer.
-- Build once at startup; reuse across frames.
local squarewave = lurek.audio.newSquareWave(freq, 1.0, sample_rate, amplitude)
print("created", squarewave)
return squarewave

--@api-stub: lurek.audio.newSawtoothWave
-- Generate a mono sawtooth-wave SoundData buffer.
-- Build once at startup; reuse across frames.
local sawtoothwave = lurek.audio.newSawtoothWave(freq, 1.0, sample_rate, amplitude)
print("created", sawtoothwave)
return sawtoothwave

--@api-stub: lurek.audio.newTriangleWave
-- Generate a mono triangle-wave SoundData buffer.
-- Build once at startup; reuse across frames.
local trianglewave = lurek.audio.newTriangleWave(freq, 1.0, sample_rate, amplitude)
print("created", trianglewave)
return trianglewave

--@api-stub: lurek.audio.newWhiteNoise
-- Generate a reproducible white-noise SoundData buffer.
-- Build once at startup; reuse across frames.
local whitenoise = lurek.audio.newWhiteNoise(1.0, sample_rate, amplitude, seed)
print("created", whitenoise)
return whitenoise

--@api-stub: lurek.audio.applyLowpass
-- Applies a first-order IIR low-pass filter to a SoundData in-place.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.applyLowpass(sd_ud, cutoff_hz)
print("applyLowpass applied")
print("ok")

--@api-stub: lurek.audio.applyHighpass
-- Applies a first-order IIR high-pass filter to a SoundData in-place.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.applyHighpass(sd_ud, cutoff_hz)
print("applyHighpass applied")
print("ok")

--@api-stub: lurek.audio.applyBandpass
-- Applies a bandpass filter (high-pass then low-pass) to a SoundData in-place.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.applyBandpass(sd_ud, low_hz, high_hz)
print("applyBandpass applied")
print("ok")

--@api-stub: lurek.audio.applyGain
-- Scales every sample by gain (clamped to [-1, 1]).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.applyGain(sd_ud, gain)
print("applyGain applied")
print("ok")

--@api-stub: lurek.audio.mixInto
-- Additively mixes another SoundData into the destination in-place.
-- See the module spec for detailed semantics.
local result = lurek.audio.mixInto(dest_ud, src_ud)
print("mixInto:", result)
return result

--@api-stub: lurek.audio.saveWAV
-- Saves a SoundData as a 16-bit PCM WAV file at the given path.
-- May block — call from a worker thread for large payloads.
local result = lurek.audio.saveWAV(sd_ud, "sfx/click.ogg")
-- may block; consider lurek.thread for large payloads
print("saveWAV:", result)
print("ok")

--@api-stub: lurek.audio.setStereoWidth
-- Sets the stereo width multiplier for a source (1.0 = normal, 0.0 = mono).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setStereoWidth(src_ud, 64)
print("setStereoWidth applied")
print("ok")

--@api-stub: lurek.audio.getStereoWidth
-- Returns the current stereo width for a source.
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getStereoWidth(src_ud)
print("getStereoWidth:", value)
return value

--@api-stub: lurek.audio.setRandomPitch
-- Sets a random pitch range applied each time the source is played.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.audio.setRandomPitch(src_ud, 0, 100)
print("setRandomPitch applied")
print("ok")

--@api-stub: lurek.audio.clearRandomPitch
-- Clears any random pitch range on a source, restoring fixed pitch.
-- Pair with the matching constructor to free resources.
-- release the resource and forget the handle
lurek.audio.clearRandomPitch(src_ud)
print("clearRandomPitch done")
print("ok")

--@api-stub: lurek.audio.crossfade
-- Crossfades from one source to another over a duration.
-- See the module spec for detailed semantics.
local result = lurek.audio.crossfade(from_ud, to_ud, 1.0)
print("crossfade:", result)
return result

--@api-stub: lurek.audio.getBusPeak
-- Returns the peak signal level of the named bus (stub: always 0.0).
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getBusPeak("sfx/click.ogg")
print("getBusPeak:", value)
return value

--@api-stub: lurek.audio.getBusRms
-- Returns the RMS signal level of the named bus (stub: always 0.0).
-- Cheap to call; safe inside callbacks.
local value = lurek.audio.getBusRms("sfx/click.ogg")
print("getBusRms:", value)
return value

--@api-stub: lurek.audio.newPool
-- Creates a polyphonic sound pool for the given file with N simultaneous voices.
-- Build once at startup; reuse across frames.
local pool = lurek.audio.newPool("sfx/click.ogg", 10)
print("created", pool)
return pool

--@api-stub: lurek.audio.processOffline
-- Applies a DSP effect chain to a WAV file and writes output.
-- See the module spec for detailed semantics.
local result = lurek.audio.processOffline(input, output, effects_tbl)
print("processOffline:", result)
return result

--@api-stub: lurek.audio.normalizeFile
-- Normalizes a WAV file peak amplitude to target_level and writes output.
-- See the module spec for detailed semantics.
local result = lurek.audio.normalizeFile(input, output, target)
print("normalizeFile:", result)
return result

--@api-stub: lurek.audio.waveformToPng
-- Renders the waveform of a WAV file to a PNG image.
-- See the module spec for detailed semantics.
local result = lurek.audio.waveformToPng(input, output, 64, 64)
print("waveformToPng:", result)
return result

--@api-stub: lurek.audio.spectrogramToPng
-- Renders a time-frequency spectrogram of a WAV file to a PNG image.
-- See the module spec for detailed semantics.
local result = lurek.audio.spectrogramToPng(input, output, 64, 64)
print("spectrogramToPng:", result)
return result

-- ── Source methods ──

--@api-stub: Source:play
-- Starts or resumes playback.
-- Trigger from input, timers, or game events.
local source = lurek.audio.newSource()
source:play()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Source:stop
-- Stops playback and resets seek position.
-- Trigger from input, timers, or game events.
local source = lurek.audio.newSource()
source:stop()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Source:pause
-- Pauses playback at the current position.
-- Trigger from input, timers, or game events.
local source = lurek.audio.newSource()
source:pause()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Source:resume
-- Resumes playback from the paused position.
-- Trigger from input, timers, or game events.
local source = lurek.audio.newSource()
source:resume()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Source:setVolume
-- Sets playback volume (0.0 = silent, 1.0 = full).
-- Apply at startup or in response to user input.
local source = lurek.audio.newSource()
source:setVolume(vol)
print("Source:setVolume applied")

--@api-stub: Source:getVolume
-- Returns the current volume multiplier.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getVolume()
print("Source:getVolume ->", value)

--@api-stub: Source:setPitch
-- Sets the pitch multiplier (1.0 = normal).
-- Apply at startup or in response to user input.
local source = lurek.audio.newSource()
source:setPitch(pitch)
print("Source:setPitch applied")

--@api-stub: Source:getPitch
-- Returns the current pitch multiplier.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getPitch()
print("Source:getPitch ->", value)

--@api-stub: Source:setLooping
-- Enables or disables looping playback.
-- Apply at startup or in response to user input.
local source = lurek.audio.newSource()
source:setLooping(looping)
print("Source:setLooping applied")

--@api-stub: Source:isLooping
-- Returns true if looping is enabled.
-- Use as a guard inside lurek.update or event handlers.
local source = lurek.audio.newSource()
if source:isLooping() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Source:isPlaying
-- Returns true if currently playing.
-- Use as a guard inside lurek.update or event handlers.
local source = lurek.audio.newSource()
if source:isPlaying() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Source:isPaused
-- Returns true if playback is paused.
-- Use as a guard inside lurek.update or event handlers.
local source = lurek.audio.newSource()
if source:isPaused() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Source:isStopped
-- Returns true if playback has stopped.
-- Use as a guard inside lurek.update or event handlers.
local source = lurek.audio.newSource()
if source:isStopped() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Source:setPan
-- Sets stereo panning (-1.0 left to 1.0 right).
-- Apply at startup or in response to user input.
local source = lurek.audio.newSource()
source:setPan(pan)
print("Source:setPan applied")

--@api-stub: Source:getPan
-- Returns the current stereo panning value.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getPan()
print("Source:getPan ->", value)

--@api-stub: Source:clone
-- Creates an independent copy of this source.
-- See the module spec for detailed semantics.
local source = lurek.audio.newSource()
source:clone()
print("Source:clone done")

--@api-stub: Source:getType
-- Returns the source type ("static" or "stream").
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getType()
print("Source:getType ->", value)

--@api-stub: Source:getDuration
-- Returns the total duration in seconds.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getDuration()
print("Source:getDuration ->", value)

--@api-stub: Source:tell
-- Returns the current playback position in seconds.
-- See the module spec for detailed semantics.
local source = lurek.audio.newSource()
source:tell()
print("Source:tell done")

--@api-stub: Source:seek
-- Seeks to a time position in seconds.
-- See the module spec for detailed semantics.
local source = lurek.audio.newSource()
source:seek(pos)
print("Source:seek done")

--@api-stub: Source:setLowpass
-- Applies a low-pass filter at the given cutoff frequency.
-- Apply at startup or in response to user input.
local source = lurek.audio.newSource()
source:setLowpass(cutoff_hz)
print("Source:setLowpass applied")

--@api-stub: Source:setHighpass
-- Applies a high-pass filter at the given cutoff frequency.
-- Apply at startup or in response to user input.
local source = lurek.audio.newSource()
source:setHighpass(cutoff_hz)
print("Source:setHighpass applied")

--@api-stub: Source:getLowpass
-- Returns the low-pass filter cutoff frequency.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getLowpass()
print("Source:getLowpass ->", value)

--@api-stub: Source:getHighpass
-- Returns the high-pass filter cutoff frequency.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getHighpass()
print("Source:getHighpass ->", value)

--@api-stub: Source:clearFilter
-- Removes any active filter from this source.
-- Pair with the matching constructor to free resources.
local source = lurek.audio.newSource()
source:clearFilter()
-- source is now released
print("ok")

--@api-stub: Source:fadeIn
-- Fades in from silence over the given duration in seconds.
-- See the module spec for detailed semantics.
local source = lurek.audio.newSource()
source:fadeIn(dur)
print("Source:fadeIn done")

--@api-stub: Source:getFadeIn
-- Returns the current fade-in duration in seconds.
-- Cheap to call; safe inside callbacks.
local source = lurek.audio.newSource()  -- or your existing handle
local value = source:getFadeIn()
print("Source:getFadeIn ->", value)

-- ── Bus methods ──

--@api-stub: Bus:getName
-- Returns the unique name string assigned to this audio bus.
-- Cheap to call; safe inside callbacks.
local bus = lurek.audio.newBus()  -- or your existing handle
local value = bus:getName()
print("Bus:getName ->", value)

--@api-stub: Bus:setVolume
-- Sets the volume for all sources on this bus.
-- Apply at startup or in response to user input.
local bus = lurek.audio.newBus()
bus:setVolume(vol)
print("Bus:setVolume applied")

--@api-stub: Bus:getVolume
-- Returns the current volume multiplier applied to all sources on this bus.
-- Cheap to call; safe inside callbacks.
local bus = lurek.audio.newBus()  -- or your existing handle
local value = bus:getVolume()
print("Bus:getVolume ->", value)

--@api-stub: Bus:setPitch
-- Sets the pitch multiplier for all sources on this bus.
-- Apply at startup or in response to user input.
local bus = lurek.audio.newBus()
bus:setPitch(pitch)
print("Bus:setPitch applied")

--@api-stub: Bus:getPitch
-- Returns the bus pitch multiplier.
-- Cheap to call; safe inside callbacks.
local bus = lurek.audio.newBus()  -- or your existing handle
local value = bus:getPitch()
print("Bus:getPitch ->", value)

--@api-stub: Bus:pause
-- Pauses all sources on this bus.
-- Trigger from input, timers, or game events.
local bus = lurek.audio.newBus()
bus:pause()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Bus:resume
-- Resumes all sources on this bus.
-- Trigger from input, timers, or game events.
local bus = lurek.audio.newBus()
bus:resume()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Bus:isPaused
-- Returns true if this bus is paused.
-- Use as a guard inside lurek.update or event handlers.
local bus = lurek.audio.newBus()
if bus:isPaused() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Bus:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local bus = lurek.audio.newBus()
bus:type()
print("Bus:type done")

--@api-stub: Bus:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local bus = lurek.audio.newBus()
bus:typeOf("sfx/click.ogg")
print("Bus:typeOf done")

--@api-stub: Bus:clearDuck
-- Removes the ducking target from this bus, restoring the target bus.
-- Pair with the matching constructor to free resources.
local bus = lurek.audio.newBus()
bus:clearDuck()
-- bus is now released
print("ok")

--@api-stub: Bus:getPeak
-- Returns the average peak amplitude of all sources currently on this bus.
-- Cheap to call; safe inside callbacks.
local bus = lurek.audio.newBus()  -- or your existing handle
local value = bus:getPeak()
print("Bus:getPeak ->", value)

-- ── MidiPlayer methods ──

--@api-stub: MidiPlayer:load
-- Loads a MIDI file from the given path.
-- May block — call from a worker thread for large payloads.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:load("sfx/click.ogg")
print("MidiPlayer:load done")

--@api-stub: MidiPlayer:loadData
-- Loads MIDI data from a Lua string.
-- May block — call from a worker thread for large payloads.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:loadData()
print("MidiPlayer:loadData done")

--@api-stub: MidiPlayer:isLoaded
-- Returns true if a MIDI sequence is loaded.
-- Use as a guard inside lurek.update or event handlers.
local midiPlayer = lurek.audio.newMidiPlayer()
if midiPlayer:isLoaded() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: MidiPlayer:getFilePath
-- Returns the file path of the loaded MIDI, or nil.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getFilePath()
print("MidiPlayer:getFilePath ->", value)

--@api-stub: MidiPlayer:setSoundFont
-- Loads a SoundFont file into this player (stub).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setSoundFont("sfx/click.ogg")
print("MidiPlayer:setSoundFont applied")

--@api-stub: MidiPlayer:getSoundFontPath
-- Returns the SoundFont file path, or nil (stub).
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getSoundFontPath()
print("MidiPlayer:getSoundFontPath ->", value)

--@api-stub: MidiPlayer:useDefaultSoundFont
-- Reverts to the built-in default SoundFont (stub).
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:useDefaultSoundFont()
print("MidiPlayer:useDefaultSoundFont done")

--@api-stub: MidiPlayer:play
-- Starts or resumes MIDI sequence playback from the current position.
-- Trigger from input, timers, or game events.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:play()
-- trigger from input, timer, or event
print("ok")

--@api-stub: MidiPlayer:pause
-- Pauses the MIDI sequence at the current position; resume with `play()`.
-- Trigger from input, timers, or game events.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:pause()
-- trigger from input, timer, or event
print("ok")

--@api-stub: MidiPlayer:stop
-- Stops MIDI playback and resets the playhead to the beginning.
-- Trigger from input, timers, or game events.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:stop()
-- trigger from input, timer, or event
print("ok")

--@api-stub: MidiPlayer:isPlaying
-- Returns true if MIDI is currently playing.
-- Use as a guard inside lurek.update or event handlers.
local midiPlayer = lurek.audio.newMidiPlayer()
if midiPlayer:isPlaying() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: MidiPlayer:isPaused
-- Returns true if MIDI playback is paused.
-- Use as a guard inside lurek.update or event handlers.
local midiPlayer = lurek.audio.newMidiPlayer()
if midiPlayer:isPaused() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: MidiPlayer:seek
-- Seeks to a time position in seconds.
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:seek(secs)
print("MidiPlayer:seek done")

--@api-stub: MidiPlayer:tell
-- Returns the current playback position in seconds.
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:tell()
print("MidiPlayer:tell done")

--@api-stub: MidiPlayer:getDuration
-- Returns the total MIDI duration in seconds.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getDuration()
print("MidiPlayer:getDuration ->", value)

--@api-stub: MidiPlayer:setLooping
-- Enables or disables looping.
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setLooping(looping)
print("MidiPlayer:setLooping applied")

--@api-stub: MidiPlayer:isLooping
-- Returns true if looping is enabled.
-- Use as a guard inside lurek.update or event handlers.
local midiPlayer = lurek.audio.newMidiPlayer()
if midiPlayer:isLooping() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: MidiPlayer:setVolume
-- Sets MIDI playback volume.
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setVolume(vol)
print("MidiPlayer:setVolume applied")

--@api-stub: MidiPlayer:getVolume
-- Returns the current MIDI volume.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getVolume()
print("MidiPlayer:getVolume ->", value)

--@api-stub: MidiPlayer:setBus
-- Routes MIDI output through a bus (or nil to clear).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setBus(bus_val)
print("MidiPlayer:setBus applied")

--@api-stub: MidiPlayer:getBus
-- Returns the assigned bus, or nil.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getBus()
print("MidiPlayer:getBus ->", value)

--@api-stub: MidiPlayer:setTempo
-- Sets playback tempo in BPM.
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setTempo(bpm)
print("MidiPlayer:setTempo applied")

--@api-stub: MidiPlayer:getTempo
-- Returns the current tempo in BPM.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getTempo()
print("MidiPlayer:getTempo ->", value)

--@api-stub: MidiPlayer:getOriginalTempo
-- Returns the original MIDI file tempo in BPM.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getOriginalTempo()
print("MidiPlayer:getOriginalTempo ->", value)

--@api-stub: MidiPlayer:setTempoScale
-- Sets the tempo scale factor (1.0 = original speed).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setTempoScale(1.0)
print("MidiPlayer:setTempoScale applied")

--@api-stub: MidiPlayer:getTempoScale
-- Returns the current tempo scale factor.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getTempoScale()
print("MidiPlayer:getTempoScale ->", value)

--@api-stub: MidiPlayer:getTicksPerBeat
-- Returns the PPQ resolution from the MIDI header.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getTicksPerBeat()
print("MidiPlayer:getTicksPerBeat ->", value)

--@api-stub: MidiPlayer:setChannelVolume
-- Sets volume for a MIDI channel (1-indexed).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setChannelVolume(ch, vol)
print("MidiPlayer:setChannelVolume applied")

--@api-stub: MidiPlayer:getChannelVolume
-- Returns the volume for a MIDI channel (1-indexed).
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getChannelVolume(ch)
print("MidiPlayer:getChannelVolume ->", value)

--@api-stub: MidiPlayer:setChannelMuted
-- Mutes or unmutes a MIDI channel (1-indexed).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setChannelMuted(ch, muted)
print("MidiPlayer:setChannelMuted applied")

--@api-stub: MidiPlayer:isChannelMuted
-- Returns true if a MIDI channel is muted (1-indexed).
-- Use as a guard inside lurek.update or event handlers.
local midiPlayer = lurek.audio.newMidiPlayer()
if midiPlayer:isChannelMuted(ch) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: MidiPlayer:getChannelInstrument
-- Returns the GM instrument for a MIDI channel (1-indexed).
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getChannelInstrument(ch)
print("MidiPlayer:getChannelInstrument ->", value)

--@api-stub: MidiPlayer:getChannelCount
-- Returns the number of MIDI channels.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getChannelCount()
print("MidiPlayer:getChannelCount ->", value)

--@api-stub: MidiPlayer:soloChannel
-- Solos a MIDI channel (1-indexed).
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:soloChannel(ch)
print("MidiPlayer:soloChannel done")

--@api-stub: MidiPlayer:unsoloAll
-- Clears solo on all channels.
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:unsoloAll()
print("MidiPlayer:unsoloAll done")

--@api-stub: MidiPlayer:getTrackCount
-- Returns the number of tracks in the MIDI sequence.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getTrackCount()
print("MidiPlayer:getTrackCount ->", value)

--@api-stub: MidiPlayer:getTrackName
-- Returns the name of a MIDI track (1-indexed), or nil.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getTrackName(1)
print("MidiPlayer:getTrackName ->", value)

--@api-stub: MidiPlayer:setTrackMuted
-- Mutes or unmutes a track (1-indexed).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setTrackMuted(1, muted)
print("MidiPlayer:setTrackMuted applied")

--@api-stub: MidiPlayer:isTrackMuted
-- Returns true if a track is muted (1-indexed).
-- Use as a guard inside lurek.update or event handlers.
local midiPlayer = lurek.audio.newMidiPlayer()
if midiPlayer:isTrackMuted(1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: MidiPlayer:getNoteCount
-- Returns the total note count in the MIDI sequence.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getNoteCount()
print("MidiPlayer:getNoteCount ->", value)

--@api-stub: MidiPlayer:setOnNoteOn
-- Registers a note-on callback (stub).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setOnNoteOn(function() print("setOnNoteOn fired") end)
print("MidiPlayer:setOnNoteOn applied")

--@api-stub: MidiPlayer:setOnNoteOff
-- Registers a note-off callback (stub).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setOnNoteOff(function() print("setOnNoteOff fired") end)
print("MidiPlayer:setOnNoteOff applied")

--@api-stub: MidiPlayer:setOnEnd
-- Registers a playback-end callback (stub).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setOnEnd(function() print("setOnEnd fired") end)
print("MidiPlayer:setOnEnd applied")

--@api-stub: MidiPlayer:getSampleRate
-- Returns the PCM output sample rate in Hz.
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getSampleRate()
print("MidiPlayer:getSampleRate ->", value)

--@api-stub: MidiPlayer:setSampleRate
-- Sets the PCM output sample rate in Hz (clamped 8000â€“192000).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setSampleRate(rate)
print("MidiPlayer:setSampleRate applied")

--@api-stub: MidiPlayer:getChannels
-- Returns the PCM output channel count (1 = mono, 2 = stereo).
-- Cheap to call; safe inside callbacks.
local midiPlayer = lurek.audio.newMidiPlayer()  -- or your existing handle
local value = midiPlayer:getChannels()
print("MidiPlayer:getChannels ->", value)

--@api-stub: MidiPlayer:setChannels
-- Sets the PCM output channel count (clamped 1â€“2).
-- Apply at startup or in response to user input.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:setChannels(channels)
print("MidiPlayer:setChannels applied")

--@api-stub: MidiPlayer:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:type()
print("MidiPlayer:type done")

--@api-stub: MidiPlayer:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local midiPlayer = lurek.audio.newMidiPlayer()
midiPlayer:typeOf("sfx/click.ogg")
print("MidiPlayer:typeOf done")

-- ── SoundPool methods ──

--@api-stub: SoundPool:play
-- Plays the next available voice and returns its SoundKey as an integer.
-- Trigger from input, timers, or game events.
local soundPool = lurek.audio.newSoundPool()
soundPool:play()
-- trigger from input, timer, or event
print("ok")

--@api-stub: SoundPool:stopAll
-- Stops all voices in this pool.
-- Trigger from input, timers, or game events.
local soundPool = lurek.audio.newSoundPool()
soundPool:stopAll()
-- trigger from input, timer, or event
print("ok")

--@api-stub: SoundPool:setVolume
-- Sets the volume for all voices in this pool.
-- Apply at startup or in response to user input.
local soundPool = lurek.audio.newSoundPool()
soundPool:setVolume(vol)
print("SoundPool:setVolume applied")

--@api-stub: SoundPool:setBus
-- Routes all voices through the named bus.
-- Apply at startup or in response to user input.
local soundPool = lurek.audio.newSoundPool()
soundPool:setBus("sfx/click.ogg")
print("SoundPool:setBus applied")

--@api-stub: SoundPool:release
-- Releases all voices from the mixer and invalidates this pool.
-- See the module spec for detailed semantics.
local soundPool = lurek.audio.newSoundPool()
soundPool:release()
print("SoundPool:release done")

--@api-stub: SoundPool:getVoiceCount
-- Returns the total number of voices in this pool.
-- Cheap to call; safe inside callbacks.
local soundPool = lurek.audio.newSoundPool()  -- or your existing handle
local value = soundPool:getVoiceCount()
print("SoundPool:getVoiceCount ->", value)

--@api-stub: SoundPool:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local soundPool = lurek.audio.newSoundPool()
soundPool:type()
print("SoundPool:type done")

--@api-stub: SoundPool:typeOf
-- Returns true if the type name matches.
-- See the module spec for detailed semantics.
local soundPool = lurek.audio.newSoundPool()
soundPool:typeOf("sfx/click.ogg")
print("SoundPool:typeOf done")

-- ── Decoder methods ──

--@api-stub: Decoder:decode
-- Decodes the next chunk of samples, or nil at EOF.
-- May block — call from a worker thread for large payloads.
local decoder = lurek.audio.newDecoder()
decoder:decode()
print("Decoder:decode done")

--@api-stub: Decoder:getChannelCount
-- Returns the number of audio channels.
-- Cheap to call; safe inside callbacks.
local decoder = lurek.audio.newDecoder()  -- or your existing handle
local value = decoder:getChannelCount()
print("Decoder:getChannelCount ->", value)

--@api-stub: Decoder:getBitDepth
-- Returns the per-sample bit depth of this decoded audio stream.
-- Cheap to call; safe inside callbacks.
local decoder = lurek.audio.newDecoder()  -- or your existing handle
local value = decoder:getBitDepth()
print("Decoder:getBitDepth ->", value)

--@api-stub: Decoder:getSampleRate
-- Returns the sample rate in Hz.
-- Cheap to call; safe inside callbacks.
local decoder = lurek.audio.newDecoder()  -- or your existing handle
local value = decoder:getSampleRate()
print("Decoder:getSampleRate ->", value)

--@api-stub: Decoder:getDuration
-- Returns the total duration in seconds.
-- Cheap to call; safe inside callbacks.
local decoder = lurek.audio.newDecoder()  -- or your existing handle
local value = decoder:getDuration()
print("Decoder:getDuration ->", value)

--@api-stub: Decoder:seek
-- Seeks to a time offset in seconds.
-- See the module spec for detailed semantics.
local decoder = lurek.audio.newDecoder()
decoder:seek(offset)
print("Decoder:seek done")

--@api-stub: Decoder:rewind
-- Rewinds to the beginning.
-- See the module spec for detailed semantics.
local decoder = lurek.audio.newDecoder()
decoder:rewind()
print("Decoder:rewind done")

--@api-stub: Decoder:tell
-- Returns the current position in seconds.
-- See the module spec for detailed semantics.
local decoder = lurek.audio.newDecoder()
decoder:tell()
print("Decoder:tell done")

--@api-stub: Decoder:isSeekable
-- Returns true if seeking is supported.
-- Use as a guard inside lurek.update or event handlers.
local decoder = lurek.audio.newDecoder()
if decoder:isSeekable() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Decoder:release
-- Releases the decoder (no-op).
-- See the module spec for detailed semantics.
local decoder = lurek.audio.newDecoder()
decoder:release()
print("Decoder:release done")

-- ── mlua methods ──

--@api-stub: mlua:getSampleCount
-- Get the total number of samples.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.audio.newmlua()  -- or your existing handle
local value = mlua:getSampleCount()
print("mlua:getSampleCount ->", value)

--@api-stub: mlua:getSampleRate
-- Get the sample rate.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.audio.newmlua()  -- or your existing handle
local value = mlua:getSampleRate()
print("mlua:getSampleRate ->", value)

--@api-stub: mlua:getChannelCount
-- Get the number of channels.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.audio.newmlua()  -- or your existing handle
local value = mlua:getChannelCount()
print("mlua:getChannelCount ->", value)

--@api-stub: mlua:getDuration
-- Get the audio duration in seconds.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.audio.newmlua()  -- or your existing handle
local value = mlua:getDuration()
print("mlua:getDuration ->", value)

--@api-stub: mlua:getBitDepth
-- Get the bit depth.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.audio.newmlua()  -- or your existing handle
local value = mlua:getBitDepth()
print("mlua:getBitDepth ->", value)

--@api-stub: mlua:getSample
-- Get a specific sample by index.
-- Cheap to call; safe inside callbacks.
local mlua = lurek.audio.newmlua()  -- or your existing handle
local value = mlua:getSample(1)
print("mlua:getSample ->", value)

--@api-stub: mlua:setSample
-- Set a specific sample by index.
-- Apply at startup or in response to user input.
local mlua = lurek.audio.newmlua()
mlua:setSample(1, value)
print("mlua:setSample applied")

