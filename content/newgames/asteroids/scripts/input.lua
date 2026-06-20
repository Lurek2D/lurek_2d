local M = {}

function M.bind()
    lurek.input.bind("rotate_left", { "a", "left" })
    lurek.input.bind("rotate_right", { "d", "right" })
    lurek.input.bind("thrust", { "w", "up" })
    lurek.input.bind("fire", { "space" })
    lurek.input.bind("confirm", { "return", "kp_enter" })
    lurek.input.bind("restart", { "r" })
    lurek.input.bind("quit", { "escape" })
end

function M.update(game, state, audio, dt)
    if lurek.input.wasActionPressed("quit") then lurek.event.quit(); return end
    if game.status == state.STATUS.TITLE and lurek.input.wasActionPressed("confirm") then state.start(game); return end
    if game.status == state.STATUS.GAME_OVER and lurek.input.wasActionPressed("restart") then state.start(game); return end
    if game.status ~= state.STATUS.PLAYING then return end
    if lurek.input.isActionDown("rotate_left") then state.rotate(game, -1, dt) end
    if lurek.input.isActionDown("rotate_right") then state.rotate(game, 1, dt) end
    if lurek.input.isActionDown("thrust") then state.thrust(game, dt, require("effects")) end
    if lurek.input.wasActionPressed("fire") then state.fire(game, audio) end
end

return M
