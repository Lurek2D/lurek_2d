local assets = {
    audio_wav = "content/examples/assets/audio/sample_click.wav",
    audio_mid = "content/examples/assets/audio/sample_midi.mid",
    audio_sf2 = "content/examples/assets/audio/sample_soundfont.sf2",
    image_png = "content/examples/assets/images/sample_icon.png",
    image_dds = "content/examples/assets/images/sample_texture.dds",
    font_ttf = "content/examples/assets/fonts/sample_font.ttf",
    data_toml = "content/examples/assets/data/sample_config.toml",
    data_zip = "content/examples/assets/data/sample_data.zip",
    model_obj = "content/examples/assets/models/sample_tank.obj"
}

print("--- Asset Load Test ---")
for k, v in pairs(assets) do
    local ok, res = pcall(function() return lurek.resource.load(v) end)
    if ok then
        print("OK: " .. k .. " (" .. v .. ")")
    else
        print("FAIL: " .. k .. " (" .. v .. ") -> " .. tostring(res))
    end
end
