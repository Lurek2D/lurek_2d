local app = {
    title = "Raycaster Dungeon",
    genre = "game / first-person dungeon RPG",
    modules = { "raycaster", "light", "dialog", "save", "audio" },
    notes = {
        "Merge target for dungeon_eye, dungeon_crawler, and raycaster_fps.",
        "This skeleton covers raycaster, light, dialog state, save manager, and audio clock.",
        "Next step: add compact dungeon maps, doors, loot, and NPC events.",
    },
    report = {},
    t = 0,
}

local function record(label, fn)
    local ok, value = pcall(fn)
    app.report[#app.report + 1] = { label = label, ok = ok, text = ok and tostring(value or "ok") or tostring(value) }
end

local function draw_text(lines, x, y, r, g, b)
    lurek.render.setColor(r, g, b, 1)
    for i = 1, #lines do lurek.render.print(lines[i], x, y + (i - 1) * 18) end
end

function lurek.init()
    lurek.window.setTitle(app.title .. " - Lurek2D")
    lurek.window.windowConfig({ width = 960, height = 540, scaleMode = "none", vsync = 1 })
    lurek.render.setBackgroundColor(0.03, 0.02, 0.03)
    record("raycaster", function() app.ray = lurek.raycaster.new(12, 12); return "ready" end)
    record("light", function() lurek.light.setEnabled(true); app.light = lurek.light.newLight(180, 160, 220); return "ready" end)
    record("dialog", function() app.dialog = lurek.dialog.newState(); return "ready" end)
    record("save", function() app.save = lurek.save.newSaveManager(); return "ready" end)
    record("audio", function() app.clock = lurek.audio.newBeatClock(80, 4); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.03, 0.02, 0.03, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.12 + i * 0.02, 0.08 + i * 0.01, 0.14 + i * 0.02, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 88 + math.sin(app.t + i) * 11, 82, h - 166)
    end
    lurek.render.setColor(0.95, 0.94, 0.96, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.80, 0.68, 0.90, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.86, 0.84, 0.88)
    draw_text(app.modules, 42, h - 88, 0.92, 0.82, 0.42)
    for i = 1, #app.report do
        local item = app.report[i]
        local c = item.ok and { 0.38, 0.90, 0.55 } or { 0.95, 0.42, 0.38 }
        lurek.render.setColor(c[1], c[2], c[3], 1)
        lurek.render.print((item.ok and "OK " or "ERR ") .. item.label, w - 280, 118 + (i - 1) * 18)
    end
end

function lurek.draw_ui()
end
