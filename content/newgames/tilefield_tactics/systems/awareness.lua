local M = {}

function M.compute(model)
    local players = {}
    for id in pairs(model.units) do players[#players + 1] = id end
    model.visibility = lurek.awareness.newTileAwareness(model.field, {
        players = players,
        rememberExplored = true,
    })
    for id, unit in pairs(model.units) do
        local origin = { x = unit.x, y = unit.y, z = unit.z }
        model.visibility:computeVisible(id, {
            origin = origin,
            range = unit.action + 2,
            channel = "vision",
        })
        model.visibility:computeAction(id, {
            origin = origin,
            range = unit.action,
            channel = "action",
        })
    end
end

return M
