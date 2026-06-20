local state = require("state")

local M = {}

local function set_color(color, alpha)
    lurek.render.setColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function cell_rect(config, x, y, ox, oy)
    return config.board.x + x * config.board.cell + ox, config.board.y + y * config.board.cell + oy
end

local function draw_cell(config, x, y, color, alpha, ox, oy)
    local px, py = cell_rect(config, x, y, ox or 0, oy or 0)
    set_color(color, alpha)
    lurek.render.rectangle("fill", px + 1, py + 1, config.board.cell - 2, config.board.cell - 2)
    lurek.render.setColor(math.min(1, color[1] * 1.35), math.min(1, color[2] * 1.35), math.min(1, color[3] * 1.35), alpha or 1)
    lurek.render.rectangle("line", px + 1, py + 1, config.board.cell - 2, config.board.cell - 2)
end

local function draw_piece(config, piece, x, y, alpha, ox, oy)
    if not piece then return end
    for _, cell in ipairs(piece.cells) do
        local cx, cy = cell[1] + x, cell[2] + y
        if cy >= 0 then draw_cell(config, cx, cy, piece.color, alpha, ox or 0, oy or 0) end
    end
end

local function draw_preview(config, piece, px, py)
    if not piece then return end
    local old_x, old_y = config.board.x, config.board.y
    config.board.x, config.board.y = px, py
    draw_piece(config, piece, 0, 0, 1, 0, 0)
    config.board.x, config.board.y = old_x, old_y
end

function M.draw(config, game, effects)
    local ox, oy = effects.offset()
    lurek.render.setColor(config.colors.border[1], config.colors.border[2], config.colors.border[3], 1)
    lurek.render.rectangle("line", config.board.x - 1 + ox, config.board.y - 1 + oy, config.board.cols * config.board.cell + 2, config.board.rows * config.board.cell + 2)

    lurek.render.setColor(config.colors.grid[1], config.colors.grid[2], config.colors.grid[3], 1)
    for y = 0, config.board.rows - 1 do
        for x = 0, config.board.cols - 1 do
            local px, py = cell_rect(config, x, y, ox, oy)
            lurek.render.rectangle("line", px + 1, py + 1, config.board.cell - 2, config.board.cell - 2)
        end
    end

    for y = 1, game.board.rows do
        for x = 1, game.board.cols do
            local color = game.board.cells[y][x]
            if color then draw_cell(config, x - 1, y - 1, color, 1, ox, oy) end
        end
    end

    if game.status == state.STATUS.PLAYING then
        draw_piece(config, game.current, game.x, state.ghost_y(game), config.colors.ghost_alpha, ox, oy)
        draw_piece(config, game.current, game.x, game.y, 1, ox, oy)
    end

    if effects.sparks and effects.sparks.render then effects.sparks:render() end
    if effects.flash > 0.01 then
        lurek.render.setColor(1, 1, 1, effects.flash)
        lurek.render.rectangle("fill", config.board.x, config.board.y, config.board.cols * config.board.cell, config.board.rows * config.board.cell)
    end
end

function M.draw_ui(config, game)
    if game.status == state.STATUS.TITLE then return end
    local side_x = config.board.x + config.board.cols * config.board.cell + 34
    draw_preview(config, game.next, side_x, config.board.y + 255)
    if game.hold then draw_preview(config, game.hold, side_x, config.board.y + 360) end
end

return M
