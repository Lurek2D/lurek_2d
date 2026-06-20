local M = {}

local function rect(mode, x, y, w, h)
    lurek.render.rectangle(mode, x, y, w, h)
end

function M.draw(config, game, effects)
    local cell = config.grid.cell
    local hud = config.grid.hud_h
    lurek.render.setColor(config.colors.board[1], config.colors.board[2], config.colors.board[3], 1)
    rect("fill", 0, hud, config.grid.cols * cell, config.grid.rows * cell)

    lurek.render.setColor(config.colors.grid[1], config.colors.grid[2], config.colors.grid[3], 1)
    for x = 0, config.grid.cols do lurek.render.line(x * cell, hud, x * cell, hud + config.grid.rows * cell) end
    for y = 0, config.grid.rows do lurek.render.line(0, hud + y * cell, config.grid.cols * cell, hud + y * cell) end

    for _, food in ipairs(game.food) do
        local cx = food.x * cell + cell / 2
        local cy = hud + food.y * cell + cell / 2
        lurek.render.setColor(config.colors.food[1], config.colors.food[2], config.colors.food[3], 1)
        lurek.render.circle("fill", cx, cy, cell / 2 - 3)
        lurek.render.setColor(config.colors.stem[1], config.colors.stem[2], config.colors.stem[3], 1)
        rect("fill", cx - 1, hud + food.y * cell + 2, 3, 5)
    end

    for i, seg in ipairs(game.snake) do
        local x = seg.x * cell
        local y = hud + seg.y * cell
        if i == #game.snake then
            lurek.render.setColor(config.colors.head[1], config.colors.head[2], config.colors.head[3], 1)
            rect("fill", x + 1, y + 1, cell - 2, cell - 2)
            lurek.render.setColor(0, 0, 0, 1)
            local ex, ey = x + cell / 2, y + cell / 2
            if game.dir.x == 1 then ex = x + cell - 5 elseif game.dir.x == -1 then ex = x + 4 end
            if game.dir.y == 1 then ey = y + cell - 5 elseif game.dir.y == -1 then ey = y + 4 end
            lurek.render.circle("fill", ex, ey, 2)
            if game.dir.x ~= 0 then lurek.render.circle("fill", ex, ey + 6, 2) else lurek.render.circle("fill", ex + 6, ey, 2) end
        else
            local t = i / math.max(1, #game.snake)
            lurek.render.setColor(config.colors.tail[1] + t * 0.25, config.colors.tail[2] + t * 0.25, config.colors.tail[3], 1)
            rect("fill", x + 2, y + 2, cell - 4, cell - 4)
        end
    end

    if effects.food and effects.food.render then effects.food:render() end
end

return M
