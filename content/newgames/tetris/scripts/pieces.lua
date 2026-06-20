local M = {}

M.definitions = {
    { name = "I", cells = {{0,0},{1,0},{2,0},{3,0}}, color = {0.0, 0.9, 0.9} },
    { name = "J", cells = {{0,0},{1,0},{2,0},{2,1}}, color = {0.0, 0.4, 0.9} },
    { name = "L", cells = {{0,0},{1,0},{2,0},{0,1}}, color = {1.0, 0.6, 0.0} },
    { name = "O", cells = {{0,0},{1,0},{0,1},{1,1}}, color = {0.9, 0.9, 0.0} },
    { name = "S", cells = {{1,0},{2,0},{0,1},{1,1}}, color = {0.0, 0.9, 0.3} },
    { name = "T", cells = {{0,0},{1,0},{2,0},{1,1}}, color = {0.6, 0.0, 0.9} },
    { name = "Z", cells = {{0,0},{1,0},{1,1},{2,1}}, color = {0.9, 0.1, 0.1} },
}

function M.copy(piece)
    local cells = {}
    for i, cell in ipairs(piece.cells) do
        cells[i] = { cell[1], cell[2] }
    end
    return {
        name = piece.name,
        cells = cells,
        color = { piece.color[1], piece.color[2], piece.color[3] },
    }
end

function M.random()
    return M.copy(M.definitions[math.random(#M.definitions)])
end

function M.rotate(piece)
    if piece.name == "O" then return M.copy(piece) end
    local max_y = 0
    for _, cell in ipairs(piece.cells) do
        max_y = math.max(max_y, cell[2])
    end
    local rotated = M.copy(piece)
    rotated.cells = {}
    for _, cell in ipairs(piece.cells) do
        rotated.cells[#rotated.cells + 1] = { max_y - cell[2], cell[1] }
    end
    return rotated
end

return M
