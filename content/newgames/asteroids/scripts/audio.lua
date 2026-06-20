local M = { sounds = {} }

function M.init(config)
    M.sounds = config.sounds or {}
    if lurek.audio and lurek.audio.newBus then pcall(lurek.audio.newBus, "asteroids_sfx") end
end

function M.play(name)
    local path = M.sounds[name]
    if path and lurek.audio and lurek.audio.playSfx then
        pcall(lurek.audio.playSfx, path, { bus = "asteroids_sfx", volume = 0.4 })
    end
end

return M
