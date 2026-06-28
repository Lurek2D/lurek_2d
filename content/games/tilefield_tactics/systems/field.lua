local M = {}

local function apply_border(field, width, height, z)
    for x = 1, width do
        field:applyProfile(x, 1, z, "wall")
        field:applyProfile(x, height, z, "wall")
    end
    for y = 1, height do
        field:applyProfile(1, y, z, "wall")
        field:applyProfile(width, y, z, "wall")
    end
end

function M.create()
    local model = {
        width = 12,
        height = 12,
        levels = 3,
        active_level = 1,
        door_x = 6,
        door_y = 6,
        door_profile = "door_closed",
        units = {
            p1 = { x = 3, y = 4, z = 1, range = 5, action = 6 },
            p2 = { x = 9, y = 8, z = 1, range = 4, action = 5 },
        },
    }
    local field = lurek.tilefield.new({
        width = model.width,
        height = model.height,
        levels = model.levels,
        topology = "square",
    })
    model.field = field

    for z = 1, model.levels do
        apply_border(field, model.width, model.height, z)
    end
    for y = 3, 10 do
        if y ~= model.door_y then
            field:applyProfile(6, y, 1, "wall")
        end
    end
    field:applyProfile(model.door_x, model.door_y, 1, model.door_profile)
    field:applyProfile(6, 4, 1, "window")
    field:applyProfile(8, 5, 1, "half_wall")
    field:applyProfile(4, 8, 2, "half_wall")
    field:applyProfile(5, 8, 3, "wall")
    field:applyProfile(5, 9, 3, "wall")
    field:setCost(4, 5, 1, "move", 3.0)
    field:setCost(4, 6, 1, "move", 3.0)
    field:setCost(7, 8, 1, "move", 2.0)

    return model
end

function M.toggle_door(model)
    model.door_profile = model.door_profile == "door_closed" and "door_open" or "door_closed"
    model.field:applyProfile(model.door_x, model.door_y, 1, model.door_profile)
end

return M
