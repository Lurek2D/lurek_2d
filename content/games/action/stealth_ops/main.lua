local app = {
    title = "Stealth Ops",
    genre = "game / tactical stealth",
    modules = { "visibility", "ai", "pathfind", "light", "tilemap" },
    notes = {
        "Foundation for guard patrols, line of sight, alarm states, and light cones.",
        "This skeleton wires tilemap navigation, FOV, AI world, and runtime lights.",
        "Next step: add patrol routes, player noise, hackable doors, and extraction.",
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
    for i = 1, #lines do
        lurek.render.print(lines[i], x, y + (i - 1) * 18)
    end
end

function lurek.init()
    lurek.window.setTitle(app.title .. " - Lurek2D")
    lurek.window.windowConfig({ width = 960, height = 540, scaleMode = "none", vsync = 1 })
    lurek.render.setBackgroundColor(0.03, 0.05, 0.05)

    record("tilemap grid", function() app.map = lurek.tilemap.newTileMap(24, 24); app.layer = app.map:addLayer("stealth", 18, 12); return "ready" end)
    record("pathfind grid", function() app.nav = lurek.pathfind.newNavGrid(18, 12); app.finder = lurek.pathfind.newPathfinder(app.nav); return "ready" end)
    record("visibility fov", function() app.fov = lurek.visibility.newFov({ width = 18, height = 12, range = 7 }); return "ready" end)
    record("ai world", function() app.ai = lurek.ai.newWorld(); app.blackboard = app.ai:getGlobalBlackboard(); return "ready" end)
    record("light", function() lurek.light.setEnabled(true); lurek.light.setAmbient(0.06, 0.07, 0.09, 1); app.light = lurek.light.newLight(240, 160, 180); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    pcall(lurek.light.advanceFlickers, dt)
    if lurek.input.keyboard.isDown("escape") then
        lurek.event.quit()
    end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.03, 0.05, 0.05, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.04, 0.12 + i * 0.02, 0.10 + i * 0.02, 1)
        lurek.render.rectangle("fill", 40 + i * 120, 90 + math.sin(app.t * 0.8 + i) * 10, 72, h - 170)
    end
    lurek.render.setColor(0.92, 0.95, 0.95, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.55, 0.84, 0.76, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.80, 0.88, 0.84)
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
