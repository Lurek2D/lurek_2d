local M = {}

function M.bind()
    lurek.input.bind("left", { "a", "left" })
    lurek.input.bind("right", { "d", "right" })
    lurek.input.bind("up", { "w", "up" })
    lurek.input.bind("down", { "s", "down" })
    lurek.input.bind("confirm", { "space", "return" })
    lurek.input.bind("restart", { "r" })
    lurek.input.bind("quit", { "escape" })
end

function M.new_intent()
    return {
        x = 0,
        y = 0,
        confirm = false,
        restart = false,
        quit = false,
    }
end

function M.update_intent(intent)
    local x, y = 0, 0
    if lurek.input.isActionDown("left") then x = x - 1 end
    if lurek.input.isActionDown("right") then x = x + 1 end
    if lurek.input.isActionDown("up") then y = y - 1 end
    if lurek.input.isActionDown("down") then y = y + 1 end

    if x ~= 0 and y ~= 0 then
        x = x * 0.7071
        y = y * 0.7071
    end

    intent.x = x
    intent.y = y
    intent.confirm = lurek.input.wasActionPressed("confirm")
    intent.restart = lurek.input.wasActionPressed("restart")
    intent.quit = lurek.input.wasActionPressed("quit")
end

return M
