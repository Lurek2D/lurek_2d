local assets = {
    audio_wav = "content/examples/assets/audio/sample_click.wav",
    audio_mid = "content/examples/assets/audio/sample_midi.mid",
    audio_sf2 = "content/examples/assets/audio/sample_soundfont.sf2",
    image_png = "content/examples/assets/images/sample_icon.png",
    image_dds = "content/examples/assets/images/sample_normal.dds",
    font_ttf = "content/examples/assets/fonts/sample_font.ttf",
    data_toml = "content/examples/assets/data/sample_config.toml",
    data_zip = "content/examples/assets/data/sample_data.zip",
    model_obj = "content/examples/assets/models/sample_tank.obj"
}

local loaders = {
    audio_wav = function(path)
        return lurek.audio.newSource(path, "static")
    end,
    audio_mid = function(path)
        return lurek.audio.newMidiPlayer(path)
    end,
    audio_sf2 = function(path)
        lurek.audio.setMidiSoundFont(path)
        local ok = lurek.audio.hasMidiSoundFont()
        lurek.audio.clearMidiSoundFont()
        return ok
    end,
    image_png = function(path)
        return lurek.render.newImage(path)
    end,
    image_dds = function(path)
        return lurek.image.newCompressedData(path)
    end,
    font_ttf = function(path)
        return lurek.render.newFont(path, 16)
    end,
    data_toml = function(path)
        return lurek.data.parseToml(lurek.filesystem.read(path))
    end,
    data_zip = function(path)
        return lurek.filesystem.mountZip(path, "data")
    end,
    model_obj = function(path)
        return lurek.render.loadObj(path)
    end,
}

print("--- Asset Load Test ---")
for k, v in pairs(assets) do
    local ok, res = pcall(function() return loaders[k](v) end)
    if ok then
        print("OK: " .. k .. " (" .. v .. ")")
    else
        print("FAIL: " .. k .. " (" .. v .. ") -> " .. tostring(res))
    end
end
