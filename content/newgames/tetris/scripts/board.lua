local M = {}

function M.new(config)
    local board = { cols = config.board.cols, rows = config.board.rows, cells = {} }
    for y = 1, board.rows do
        board.cells[y] = {}
    end
    return board
end

function M.collides(board, piece, ox, oy)
    for _, cell in ipairs(piece.cells) do
        local x = cell[1] + ox
        local y = cell[2] + oy
        if x < 0 or x >= board.cols or y >= board.rows then return true end
        if y >= 0 and board.cells[y + 1][x + 1] then return true end
    end
    return false
end

function M.ghost_y(board, piece, x, y)
    local gy = y
    while not M.collides(board, piece, x, gy + 1) do
        gy = gy + 1
    end
    return gy
end

function M.lock(board, piece, ox, oy)
    local overflow = false
    for _, cell in ipairs(piece.cells) do
        local x = cell[1] + ox
        local y = cell[2] + oy
        if y < 0 then
            overflow = true
        elseif y < board.rows then
            board.cells[y + 1][x + 1] = piece.color
        end
    end
    return not overflow
end

function M.clear_lines(board)
    local cleared = {}
    local y = board.rows
    while y >= 1 do
        local full = true
        for x = 1, board.cols do
            if not board.cells[y][x] then full = false; break end
        end
        if full then
            cleared[#cleared + 1] = y
            table.remove(board.cells, y)
            table.insert(board.cells, 1, {})
        else
            y = y - 1
        end
    end
    return cleared
end

return M
