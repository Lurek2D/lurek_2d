local M = {}

local function map_of(model)
    return model and model.active_map or {}
end

function M.team_count(model)
    return math.max(1, tonumber(map_of(model).team_count) or 4)
end

function M.list(model)
    local teams = {}
    for index = 1, M.team_count(model) do teams[index] = "team" .. tostring(index) end
    return teams
end

function M.is_ally(model, first, second)
    if not first or not second then return false end
    if first == second then return true end
    for _, group in ipairs(map_of(model).alliances or {}) do
        local has_first, has_second = false, false
        for _, team in ipairs(group or {}) do
            has_first = has_first or team == first
            has_second = has_second or team == second
        end
        if has_first and has_second then return true end
    end
    return false
end

function M.is_enemy(model, first, second)
    return first ~= nil and second ~= nil and not M.is_ally(model, first, second)
end

function M.is_player_side(model, team)
    return M.is_ally(model, "team1", team)
end

return M
