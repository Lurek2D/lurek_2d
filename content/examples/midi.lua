--- MIDI Playback Example
--- Demonstrates MIDI file playback with per-channel control using lurek.midi.

--@api-stub: lurek.midi.newPlayer
do
    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.midi.newPlayer(path)
    print("type = " .. player:type())
    print("loaded = " .. tostring(player:isLoaded()))
    print("path = " .. tostring(player:getFilePath()))
end

--@api-stub: lurek.midi.loadSoundFont
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok, err = pcall(function()
        local loaded = lurek.midi.loadSoundFont(path)
        print("loaded = " .. tostring(loaded))
        print("has soundfont = " .. tostring(lurek.midi.hasSoundFont()))
    end)
    if not ok then print("loadSoundFont skipped: " .. tostring(err)) end
end

--@api-stub: lurek.midi.hasSoundFont
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    lurek.midi.clearSoundFont()
    print("before load = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.loadSoundFont(path)
    print("after load = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
end

--@api-stub: lurek.midi.clearSoundFont
do
    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    lurek.midi.loadSoundFont(path)
    print("before clear = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
    print("after clear = " .. tostring(lurek.midi.hasSoundFont()))
end
