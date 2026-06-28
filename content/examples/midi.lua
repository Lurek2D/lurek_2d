--- MIDI Playback Example
--- Demonstrates MIDI file playback with per-channel control using lurek.midi.


--@api: lurek.midi.newPlayer
do

    if type(lurek.midi) ~= "table" or type(lurek.midi.newPlayer) ~= "function" then
        lurek.log.info("midi API unavailable in this runtime")
        lurek.log.info("skipping lurek.midi.newPlayer")
    else
        local path = "content/examples/assets/audio/sample_midi.mid"
        local player = lurek.midi.newPlayer(path)
        lurek.log.info(tostring("type = " .. player:type()))
        lurek.log.info(tostring("loaded = " .. tostring(player:isLoaded())))
        lurek.log.info(tostring("path = " .. tostring(player:getFilePath())))
    end
end

--@api: lurek.midi.loadSoundFont
do

    if type(lurek.midi) ~= "table" or type(lurek.midi.loadSoundFont) ~= "function" then
        lurek.log.info("midi API unavailable in this runtime")
        lurek.log.info("skipping lurek.midi.loadSoundFont")
    else
        local path = "content/examples/assets/audio/sample_soundfont.sf2"
        local ok, err = pcall(function()
            local loaded = lurek.midi.loadSoundFont(path)
            lurek.log.info(tostring("loaded = " .. tostring(loaded)))
            lurek.log.info(tostring("has soundfont = " .. tostring(lurek.midi.hasSoundFont())))
        end)
        if not ok then lurek.log.info(tostring("loadSoundFont skipped: " .. tostring(err))) end
    end
end

--@api: lurek.midi.hasSoundFont
do

    if type(lurek.midi) ~= "table" or type(lurek.midi.hasSoundFont) ~= "function" then
        lurek.log.info("midi API unavailable in this runtime")
        lurek.log.info("skipping lurek.midi.hasSoundFont")
    else
        local path = "content/examples/assets/audio/sample_soundfont.sf2"
        lurek.midi.clearSoundFont()
        lurek.log.info(tostring("before load = " .. tostring(lurek.midi.hasSoundFont())))
        local ok, err = pcall(function()
            lurek.midi.loadSoundFont(path)
        end)
        lurek.log.info(tostring("load ok = " .. tostring(ok)))
        if not ok then lurek.log.info(tostring("loadSoundFont skipped: " .. tostring(err))) end
        lurek.log.info(tostring("after load = " .. tostring(lurek.midi.hasSoundFont())))
        lurek.midi.clearSoundFont()
    end
end

--@api: lurek.midi.clearSoundFont
do

    if type(lurek.midi) ~= "table" or type(lurek.midi.clearSoundFont) ~= "function" then
        lurek.log.info("midi API unavailable in this runtime")
        lurek.log.info("skipping lurek.midi.clearSoundFont")
    else
        local path = "content/examples/assets/audio/sample_soundfont.sf2"
        local ok, err = pcall(function()
            lurek.midi.loadSoundFont(path)
        end)
        if not ok then lurek.log.info(tostring("loadSoundFont skipped: " .. tostring(err))) end
        lurek.log.info(tostring("before clear = " .. tostring(lurek.midi.hasSoundFont())))
        lurek.midi.clearSoundFont()
        lurek.log.info(tostring("after clear = " .. tostring(lurek.midi.hasSoundFont())))
    end
end
