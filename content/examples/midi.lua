--- MIDI Playback Example
--- Demonstrates MIDI file playback with per-channel control using lurek.midi.


--@api: lurek.midi.newPlayer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_midi.mid"
    local player = lurek.midi.newPlayer(path)
    example_print_log("type = " .. player:type())
    example_print_log("loaded = " .. tostring(player:isLoaded()))
    example_print_log("path = " .. tostring(player:getFilePath()))
end

--@api: lurek.midi.loadSoundFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok, err = pcall(function()
        local loaded = lurek.midi.loadSoundFont(path)
        example_print_log("loaded = " .. tostring(loaded))
        example_print_log("has soundfont = " .. tostring(lurek.midi.hasSoundFont()))
    end)
    if not ok then example_print_log("loadSoundFont skipped: " .. tostring(err)) end
end

--@api: lurek.midi.hasSoundFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    lurek.midi.clearSoundFont()
    example_print_log("before load = " .. tostring(lurek.midi.hasSoundFont()))
    local ok, err = pcall(function()
        lurek.midi.loadSoundFont(path)
    end)
    example_print_log("load ok = " .. tostring(ok))
    if not ok then example_print_log("loadSoundFont skipped: " .. tostring(err)) end
    example_print_log("after load = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
end

--@api: lurek.midi.clearSoundFont
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local path = "content/examples/assets/audio/sample_soundfont.sf2"
    local ok, err = pcall(function()
        lurek.midi.loadSoundFont(path)
    end)
    if not ok then example_print_log("loadSoundFont skipped: " .. tostring(err)) end
    example_print_log("before clear = " .. tostring(lurek.midi.hasSoundFont()))
    lurek.midi.clearSoundFont()
    example_print_log("after clear = " .. tostring(lurek.midi.hasSoundFont()))
end
