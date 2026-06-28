local M = {}

function M.compute(model)
    model.nav = lurek.pathfind.newNavGridFromField(model.field, {
        level = model.active_level,
        channel = "move",
        costChannel = "move",
    })
    model.ranges = {}
    for id, unit in pairs(model.units) do
        model.ranges[id] = lurek.pathfind.rangeMapFromField(model.field, {
            origin = { x = unit.x, y = unit.y, z = unit.z },
            budget = unit.range,
            channel = "move",
            costChannel = "move",
        })
    end
end

return M
