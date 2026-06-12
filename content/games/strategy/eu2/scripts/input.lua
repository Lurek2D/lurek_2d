local M = {}

local modes = {
    ["1"] = "political",
    ["2"] = "terrain",
    ["3"] = "economy",
    ["4"] = "diplomacy",
    ["5"] = "unrest",
}

function M.handle_key(state, view, key)
    if modes[key] then
        view.map_mode = modes[key]
        return true
    end
    if key == "l" then
        view.draw_labels = not view.draw_labels
        return true
    end
    if key == "f12" or key == "F12" then
        view.debug_mode = not view.debug_mode
        view.map_dirty = true
        return true
    end
    if key == "space" then
        state.paused = not state.paused
        return true
    end
    if key == "+" or key == "=" then
        state.speed_index = math.min(4, state.speed_index + 1)
        return true
    end
    if key == "-" then
        state.speed_index = math.max(1, state.speed_index - 1)
        return true
    end
    if key == "tab" then
        local player = {}
        for _, army in ipairs(state.armies) do
            if army.tag == state.player_tag then
                table.insert(player, army)
            end
        end
        if #player == 0 then
            return true
        end
        local current = 0
        for i, army in ipairs(player) do
            if army.id == state.selected_army_id then
                current = i
            end
        end
        local army = player[(current % #player) + 1]
        state.selected_army_id = army.id
        for _, candidate in ipairs(state.armies) do
            candidate.selected = candidate.id == army.id
        end
        if army then
            view.selected_gid = army.province_id
            state.selected_province_id = army.province_id
        end
        return true
    end
    return false
end

return M
