local M = {}

local function selected_id(state)
    return state.hangar and state.hangar.selected or "f1"
end

local function set_color(c, alpha)
    c = c or {1, 1, 1, 1}
    lurek.render.setColor(c[1], c[2], c[3], alpha or c[4] or 1)
end

function M.enter(state)
    state.hangar = state.hangar or {selected = "f1", budget = state.content.game.battle_budget or 200}
end

function M.process(state)
    M.enter(state)
    for i = 1, 12 do
        if state.modules.Movement.pressed(state, "preset_" .. tostring(i)) then state.hangar.selected = "f" .. tostring(i) end
    end
    if state.modules.Movement.pressed(state, "confirm") then
        state.modules.Battle.start(state, selected_id(state))
    elseif state.modules.Movement.pressed(state, "pause") then
        state.phase = "hangar"
    end
end

local function stat_bar(x, y, label, value, maximum, c)
    lurek.render.setColor(0.72, 0.75, 0.78, 1)
    lurek.render.print(label, x, y)
    lurek.render.setColor(0.10, 0.11, 0.13, 1)
    lurek.render.rectangle("fill", x + 92, y, 190, 10)
    set_color(c)
    lurek.render.rectangle("fill", x + 92, y, 190 * math.min(1, value / maximum), 10)
end

local function draw_preview(build, cx, cy)
    local radius = math.max(34, build.corpus.radius * 2.1)
    lurek.render.setColor(0.07, 0.08, 0.10, 1)
    lurek.render.circle("fill", cx, cy, 130)
    lurek.render.setColor(0.19, 0.23, 0.27, 1)
    lurek.render.circle("line", cx, cy, 130)
    lurek.render.circle("line", cx, cy, 92)

    lurek.render.push()
    lurek.render.translate(cx, cy)
    lurek.render.rotate(-0.2)
    if build.backpack_id ~= "none" then
        set_color(build.backpack.color)
        lurek.render.rectangle("fill", -radius - 30, -34, 30, 68)
    end
    local left_size = tonumber(build.left.size) or 2
    local right_size = tonumber(build.right.size) or 2
    set_color(build.left.color)
    lurek.render.rectangle("fill", -8, -radius - 24, 52 + left_size * 7, 14 + left_size * 2)
    set_color(build.right.color)
    lurek.render.rectangle("fill", -8, radius + 8, 52 + right_size * 7, 14 + right_size * 2)
    set_color(build.corpus.color)
    lurek.render.circle("fill", 0, 0, radius)
    lurek.render.setLineWidth(3)
    lurek.render.setColor(0.92, 0.94, 0.95, 1)
    lurek.render.circle("line", 0, 0, radius)
    lurek.render.setLineWidth(1)
    lurek.render.rectangle("fill", radius - 12, -8, 15, 16)
    lurek.render.pop()
end

function M.draw(state)
    M.enter(state)
    lurek.render.setBackgroundColor(0.015, 0.018, 0.024)
    local w, h = lurek.window.getWidth(), lurek.window.getHeight()
    lurek.render.setColor(0.025, 0.030, 0.040, 1)
    lurek.render.rectangle("fill", 0, 0, w, h)
    lurek.render.setColor(0.12, 0.15, 0.18, 0.7)
    for x = 0, w, 64 do lurek.render.line(x, 0, x, h) end
    for y = 0, h, 64 do lurek.render.line(0, y, w, y) end

    lurek.render.setColor(0.30, 0.90, 0.48, 1)
    lurek.render.print("HANGAR // WYBOR KONFIGURACJI", 34, 28)
    lurek.render.setColor(0.62, 0.68, 0.74, 1)
    lurek.render.print(string.format("POZIOM %d   GWIAZDY %d   ZWYCIESTWA %d   BUDZET %d", state.campaign.level, state.campaign.stars, state.campaign.wins, state.content.game.battle_budget or 200), 34, 48)

    for i = 1, 12 do
        local id = "f" .. tostring(i)
        local preset = state.content.content.presets[id]
        local build = state.modules.Build.from_preset(state.content, id)
        local column = math.floor((i - 1) / 6)
        local row = (i - 1) % 6
        local x = 34 + column * 260
        local y = 92 + row * 57
        local active = id == selected_id(state)
        lurek.render.setColor(active and 0.15 or 0.045, active and 0.34 or 0.055, active and 0.24 or 0.07, 1)
        lurek.render.rectangle("fill", x, y, 244, 45)
        lurek.render.setColor(active and 0.30 or 0.18, active and 0.92 or 0.22, active and 0.50 or 0.28, 1)
        lurek.render.rectangle("fill", x, y, active and 7 or 3, 45)
        lurek.render.setColor(0.94, 0.95, 0.96, 1)
        lurek.render.print(string.format("F%d  %s", i, tostring(preset.name):upper()), x + 18, y + 8)
        lurek.render.setColor(0.56, 0.62, 0.68, 1)
        lurek.render.print(string.format("%s  //  %d CR", preset.corpus, build.cost), x + 18, y + 25)
    end

    local build = state.modules.Build.from_preset(state.content, selected_id(state))
    lurek.render.setColor(0.03, 0.035, 0.045, 0.96)
    lurek.render.rectangle("fill", 590, 92, w - 624, 468)
    lurek.render.setColor(0.18, 0.22, 0.27, 1)
    lurek.render.rectangle("line", 590, 92, w - 624, 468)
    lurek.render.setColor(0.94, 0.95, 0.96, 1)
    lurek.render.print(tostring(build.name):upper(), 622, 116)
    lurek.render.setColor(0.48, 0.58, 0.66, 1)
    lurek.render.print(build.corpus.name .. " // " .. build.backpack.name, 622, 136)
    draw_preview(build, 930, 285)
    stat_bar(622, 444, "PANCERZ", build.max_health, 600, {0.92, 0.20, 0.18, 1})
    stat_bar(622, 466, "ENERGIA", build.max_energy, 300, {0.18, 0.50, 0.95, 1})
    stat_bar(622, 488, "PREDKOSC", build.move_speed, 160, {0.25, 0.85, 0.48, 1})
    lurek.render.setColor(0.76, 0.78, 0.82, 1)
    lurek.render.print("LEWA:  " .. build.left.name .. "  [LMB]", 622, 520)
    lurek.render.print("PRAWA: " .. build.right.name .. "  [RMB]", 622, 538)

    lurek.render.setColor(0.30, 0.90, 0.48, 1)
    lurek.render.rectangle("line", 590, 586, w - 624, 54)
    lurek.render.printf("ENTER / SPACE / LMB  //  ROZPOCZNIJ MISJE", 590, 607, w - 624, "center")
    lurek.render.setColor(0.55, 0.60, 0.66, 1)
    lurek.render.print("F1-F12 WYBOR MECHA", 34, h - 30)
    lurek.render.setColor(1, 1, 1, 1)
end

return M
