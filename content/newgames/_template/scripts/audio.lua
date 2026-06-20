local M = {}

local function try_source(path)
    if not lurek.audio or not lurek.audio.newSource then
        return nil
    end
    local ok, source = pcall(lurek.audio.newSource, path, "static")
    if ok then
        return source
    end
    return nil
end

function M.new(cfg)
    local audio = { sources = {} }
    for name, path in pairs(cfg.SOUNDS) do
        audio.sources[name] = try_source(path)
    end
    return audio
end

function M.play(audio, name)
    local source = audio and audio.sources and audio.sources[name]
    if not source then
        return
    end
    local ok = pcall(function()
        if source.stop then source:stop() end
        if source.play then source:play() end
    end)
    if not ok and lurek.audio and lurek.audio.play then
        pcall(lurek.audio.play, source)
    end
end

return M
