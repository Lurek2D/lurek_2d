local M = {}

function M.bind()
    lurek.input.bind("confirm", { "return", "kp_enter" })
    lurek.input.bind("quit", { "escape" })
end

function M.update(game, state)
    if lurek.input.wasActionPressed("quit") then lurek.event.quit(); return end
    if game.status ~= state.STATUS.PLAYING and lurek.input.wasActionPressed("confirm") then
        state.start(game)
    end
end

function M.keypressed(game, state, key)
    if key == "w" or key == "up" then state.set_dir(game, 0, -1)
    elseif key == "s" or key == "down" then state.set_dir(game, 0, 1)
    elseif key == "a" or key == "left" then state.set_dir(game, -1, 0)
    elseif key == "d" or key == "right" then state.set_dir(game, 1, 0) end
end

return M
