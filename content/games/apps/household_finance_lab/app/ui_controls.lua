local Controls = {}

local function inside(hb, x, y)
    return x >= hb.x and x <= hb.x + hb.w and y >= hb.y and y <= hb.y + hb.h
end

local function add(ctx, id, kind, label, x, y, w, h, action, value)
    local hb = { id = id, kind = kind, label = label, x = x, y = y, w = w, h = h, action = action, value = value }
    ctx.hitboxes[#ctx.hitboxes + 1] = hb
    return hb
end

function Controls.add_hitbox(ctx, id, kind, label, x, y, w, h, action, value)
    return add(ctx, id, kind, label, x, y, w, h, action, value)
end

local function add_button(ctx, id, label, x, y, w, action, value)
    return add(ctx, id, "button", label, x, y, w, 22, action, value)
end

function Controls.layout(ctx)
    ctx.hitboxes = {}
    local x = 16
    for index, label in ipairs(ctx.C.TABS) do
        local w = ({ 86, 86, 98, 82, 88, 98, 112, 64 })[index] or 90
        add(ctx, "tab_" .. tostring(index), "tab", label, x, 46, w, 24, "tab", index)
        x = x + w + 6
    end

    add_button(ctx, "member_prev", "<", 16, 78, 24, "member", -1)
    add(ctx, "member_value", "value", ctx.UIState.member(ctx.C, ctx.state), 42, 78, 92, 22, "member", 1)
    add_button(ctx, "member_next", ">", 136, 78, 24, "member", 1)

    add_button(ctx, "category_prev", "<", 172, 78, 24, "category", -1)
    add(ctx, "category_value", "value", ctx.UIState.category(ctx.C, ctx.state), 198, 78, 128, 22, "category", 1)
    add_button(ctx, "category_next", ">", 328, 78, 24, "category", 1)

    add_button(ctx, "start_down", "-", 366, 78, 24, "start_year", -1)
    add(ctx, "years", "value", tostring(ctx.state.start_year) .. "-" .. tostring(ctx.state.end_year), 392, 78, 86, 22, "noop")
    add_button(ctx, "start_up", "+", 480, 78, 24, "start_year", 1)
    add_button(ctx, "end_down", "-", 510, 78, 24, "end_year", -1)
    add_button(ctx, "end_up", "+", 536, 78, 24, "end_year", 1)

    add_button(ctx, "clean_toggle", ctx.state.use_cleaned and "Clean" or "Raw", 574, 78, 70, "toggle_cleaned")
    add_button(ctx, "threshold_down", "-", 656, 78, 24, "threshold", -5)
    add(ctx, "threshold", "value", "Anom " .. tostring(ctx.state.anomaly_threshold), 682, 78, 74, 22, "noop")
    add_button(ctx, "threshold_up", "+", 758, 78, 24, "threshold", 5)

    add_button(ctx, "regen", "Regenerate", 804, 78, 92, "regenerate")
    add_button(ctx, "cache", "Reload", 902, 78, 70, "reload_cache")
    add_button(ctx, "shot", "Shot", 978, 78, 58, "screenshot")
    add_button(ctx, "save", "Save", 1042, 78, 58, "save_state")

    if ctx.state.active_tab == 6 then
        for index = 1, math.min(18, #(ctx.view.anomalies or {})) do
            add(ctx, "anomaly_" .. tostring(index), "row", "", 620, 142 + index * 24, 590, 22, "select_anomaly", index)
        end
    elseif ctx.state.active_tab == 7 then
        for index = 1, math.min(24, #(ctx.view.recent or {})) do
            add(ctx, "transaction_" .. tostring(index), "row", "", 24, 132 + index * 20, 1196, 18, "select_transaction", index)
        end
    end
end

local function invoke(ctx, hb)
    local s = ctx.state
    local action = hb.action
    if action == "tab" then
        ctx.UIState.set_tab(ctx.C, s, hb.value)
    elseif action == "member" then
        ctx.UIState.bump_member(ctx.C, s, hb.value)
    elseif action == "category" then
        ctx.UIState.bump_category(ctx.C, s, hb.value)
    elseif action == "start_year" then
        ctx.UIState.bump_start_year(ctx.C, s, hb.value)
    elseif action == "end_year" then
        ctx.UIState.bump_end_year(ctx.C, s, hb.value)
    elseif action == "toggle_cleaned" then
        ctx.UIState.toggle_cleaned(s)
    elseif action == "threshold" then
        ctx.UIState.bump_threshold(s, hb.value)
    elseif action == "select_anomaly" then
        s.selected_anomaly = hb.value
        s.last_action = "selected anomaly"
    elseif action == "select_transaction" then
        s.selected_transaction = hb.value
        s.last_action = "selected transaction"
    elseif ctx.actions and ctx.actions[action] then
        ctx.actions[action]()
    end
end

function Controls.mousepressed(ctx, x, y, button)
    if button ~= nil and button ~= 1 then return false end
    for index = #ctx.hitboxes, 1, -1 do
        local hb = ctx.hitboxes[index]
        if inside(hb, x, y) then
            ctx.pressed_id = hb.id
            invoke(ctx, hb)
            return true
        end
    end
    return false
end

function Controls.mousereleased(ctx)
    ctx.pressed_id = nil
    return false
end

function Controls.mousemoved(ctx, x, y)
    ctx.state.hover_id = nil
    for _, hb in ipairs(ctx.hitboxes) do
        if inside(hb, x, y) then
            ctx.state.hover_id = hb.id
            return true
        end
    end
    return false
end

function Controls.wheelmoved(ctx, _x, y)
    if ctx.state.active_tab == 7 then
        ctx.state.table_scroll = math.max(0, ctx.state.table_scroll - y)
        return true
    elseif ctx.state.active_tab == 8 then
        ctx.state.log_scroll = math.max(0, ctx.state.log_scroll - y)
        return true
    end
    return false
end

function Controls.keypressed(ctx, key)
    local n = tonumber(key)
    if n and n >= 1 and n <= #ctx.C.TABS then
        ctx.UIState.set_tab(ctx.C, ctx.state, n)
        return true
    end
    if key == "left" then ctx.UIState.bump_start_year(ctx.C, ctx.state, -1); return true end
    if key == "right" then ctx.UIState.bump_end_year(ctx.C, ctx.state, 1); return true end
    if key == "c" then ctx.UIState.toggle_cleaned(ctx.state); return true end
    if key == "r" and ctx.actions.regenerate then ctx.actions.regenerate(); return true end
    if key == "p" and ctx.actions.screenshot then ctx.actions.screenshot(); return true end
    if key == "s" and ctx.actions.save_state then ctx.actions.save_state(); return true end
    return false
end

return Controls