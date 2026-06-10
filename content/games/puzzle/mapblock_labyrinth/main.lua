local app = {
    title = "Mapblock Labyrinth",
    genre = "game / procedural puzzle labyrinth",
    modules = { "mapblock", "tilemap", "procgen", "pathfind", "visibility" },
    notes = {
        "Generated labyrinth puzzles assembled from reusable room blocks.",
        "This skeleton covers block config, tilemap shell, procgen layout, route grid, and fog-of-war.",
        "Next step: add sockets, lock/key rules, and readable puzzle progression.",
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
    lurek.render.setBackgroundColor(0.04, 0.03, 0.05)
    record("mapblock config", function() app.config = lurek.mapblock.newEmptyConfig(); return "ready" end)
    record("tilemap shell", function() app.map = lurek.tilemap.newTileMap(24, 24); return "ready" end)
    record("procgen dungeon", function() app.rooms = lurek.procgen.roomsDungeon(32, 20, 7); return "ready" end)
    record("pathfind grid", function() app.nav = lurek.pathfind.newNavGrid(32, 20); return "ready" end)
    record("visibility", function() app.fov = lurek.visibility.newFov({ width = 32, height = 20, range = 6 }); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.04, 0.03, 0.05, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.16 + i * 0.02, 0.10 + i * 0.02, 0.20 + i * 0.02, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 86 + math.sin(app.t + i) * 14, 84, h - 164)
    end
    lurek.render.setColor(0.95, 0.94, 0.96, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.78, 0.68, 0.94, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.84, 0.84, 0.88)
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
