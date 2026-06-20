local M = { enabled = true, sounds = {} }

function M.init(config)
    M.sounds = config.sounds or {}
    if lurek.audio and lurek.audio.newBus then
        pcall(lurek.audio.newBus, "tetris_sfx")
    end
end

function M.play(name)
    local path = M.sounds[name]
    if not path or not M.enabled or not lurek.audio or not lurek.audio.playSfx then return end
    pcall(lurek.audio.playSfx, path, { bus = "tetris_sfx", volume = 0.45 })
end

return M
