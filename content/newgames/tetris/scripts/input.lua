local M = {}

function M.bind()
    lurek.input.bind("left", { "a", "left" })
    lurek.input.bind("right", { "d", "right" })
    lurek.input.bind("rotate", { "w", "up" })
    lurek.input.bind("soft_drop", { "s", "down" })
    lurek.input.bind("hard_drop", { "space" })
    lurek.input.bind("hold", { "c" })
    lurek.input.bind("confirm", { "return", "kp_enter" })
    lurek.input.bind("restart", { "r" })
    lurek.input.bind("quit", { "escape" })
end

function M.update(game, state, audio)
    if lurek.input.wasActionPressed("quit") then lurek.event.quit(); return end
    if game.status == state.STATUS.TITLE and lurek.input.wasActionPressed("confirm") then state.start(game); return end
    if game.status == state.STATUS.GAME_OVER and lurek.input.wasActionPressed("restart") then state.start(game); return end
    if game.status ~= state.STATUS.PLAYING then return end

    if lurek.input.wasActionPressed("left") then state.move(game, -1, audio) end
    if lurek.input.wasActionPressed("right") then state.move(game, 1, audio) end
    if lurek.input.wasActionPressed("rotate") then state.rotate(game, audio) end
    if lurek.input.wasActionPressed("hard_drop") then state.hard_drop(game, require("effects"), audio) end
    if lurek.input.wasActionPressed("hold") then state.hold(game) end
end

return M
