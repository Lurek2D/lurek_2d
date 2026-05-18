--- Audio Examples Part 5: LDecoder methods, LSoundData methods

--@api-stub: LDecoder:getChannelCount
-- Returns the number of audio channels in the source file.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    local ch = dec:getChannelCount()
    print("channels = " .. ch)
end

--@api-stub: LDecoder:getBitDepth
-- Returns the bit depth of the source audio file.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    local bits = dec:getBitDepth()
    print("bit depth = " .. bits)
end

--@api-stub: LDecoder:getSampleRate
-- Returns the sample rate of the source file.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    local rate = dec:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LDecoder:getDuration
-- Returns the total duration of the source file.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    local dur = dec:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LDecoder:seek
-- Seeks to a specific position in the audio stream.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(2.5)
    print("seeked to " .. dec:tell())
end

--@api-stub: LDecoder:rewind
-- Rewinds the decoder back to the beginning.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(5.0)
    dec:rewind()
    print("rewound to " .. dec:tell())
end

--@api-stub: LDecoder:tell
-- Returns the current read position in seconds.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    dec:seek(3.0)
    local pos = dec:tell()
    print("position = " .. pos)
end

--@api-stub: LDecoder:isSeekable
-- Returns whether this decoder supports seeking.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    print("seekable = " .. tostring(dec:isSeekable()))
end

--@api-stub: LDecoder:release
-- Releases decoder resources.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    dec:release()
    print("decoder released")
end

--@api-stub: LDecoder:type
-- Returns the type name ("LDecoder").
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    print("type = " .. dec:type())
end

--@api-stub: LDecoder:typeOf
-- Checks whether this object matches a given type name.
do
    local path = "sounds/song.ogg"
    local dec = lurek.audio.newDecoder(path)
    print("is LDecoder = " .. tostring(dec:typeOf("LDecoder")))
end

--@api-stub: LSoundData:getSampleCount
-- Returns the total number of samples in the buffer.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local count = sd:getSampleCount()
    print("samples = " .. count)
end

--@api-stub: LSoundData:getSampleRate
-- Returns the sample rate of the sound data.
do
    local sd = lurek.audio.newSoundData(22050, 22050, 1)
    local rate = sd:getSampleRate()
    print("sample rate = " .. rate)
end

--@api-stub: LSoundData:getChannelCount
-- Returns the number of audio channels.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 2)
    local ch = sd:getChannelCount()
    print("channels = " .. ch)
end

--@api-stub: LSoundData:getDuration
-- Returns the approximate playback duration.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local dur = sd:getDuration()
    print("duration = " .. dur .. "s")
end

--@api-stub: LSoundData:getBitDepth
-- Returns the bit depth per sample.
do
    local sd = lurek.audio.newSoundData(44100, 44100, 1)
    local bits = sd:getBitDepth()
    print("bit depth = " .. bits)
end

--@api-stub: LSoundData:getSample
-- Returns the sample value at a zero-based index.
do
    local sd = lurek.audio.newSineWave(440, 0.1, 44100, 1.0)
    local val = sd:getSample(0)
    print("sample[0] = " .. val)
end

--@api-stub: LSoundData:drawWaveform
-- Draws the waveform into an image buffer.
do
    local sd = lurek.audio.newSineWave(440, 1.0, 44100, 0.8)
    local img = lurek.image.newImageData(400, 100)
    sd:drawWaveform(img, 0, 0, 400, 100, 0, 255, 0, 255)
    print("waveform drawn to image")
end

--@api-stub: LSoundData:setSample
-- Overwrites a sample value at a zero-based index.
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    sd:setSample(0, 0.5)
    sd:setSample(50, -0.3)
    print("sample[0] = " .. sd:getSample(0) .. " sample[50] = " .. sd:getSample(50))
end

--@api-stub: LSoundData:type
-- Returns the type name ("LSoundData").
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("type = " .. sd:type())
end

--@api-stub: LSoundData:typeOf
-- Checks whether this object matches a given type name.
do
    local sd = lurek.audio.newSoundData(100, 44100, 1)
    print("is LSoundData = " .. tostring(sd:typeOf("LSoundData")))
end

print("audio_04.lua")
