local app = {
    title = "Frontier Tactics",
    genre = "game / hex-grid squad tactics",
    modules = { "tilemap", "pathfind", "ai", "visibility", "minimap" },
    notes = {
        "One strong tactics demo instead of many similar grid prototypes.",
        "This skeleton covers tilemap, hex pathfinding, AI world, visibility, and minimap.",
        "Next step: add units, turn order, cover, fog-of-war, and enemy turns.",
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
    lurek.render.setBackgroundColor(0.04, 0.04, 0.03)
    record("tilemap", function() app.map = lurek.tilemap.newTileMap(28, 28); return "ready" end)
    record("pathfind", function() app.hex = lurek.pathfind.newHexGrid(14, 10); return "ready" end)
    record("ai", function() app.ai = lurek.ai.newWorld(); return "ready" end)
    record("visibility", function() app.vis = lurek.visibility.new({ regions = 140, players = 2 }); return "ready" end)
    record("minimap", function() app.minimap = lurek.minimap.newMinimap(14, 10); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.04, 0.04, 0.03, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.16 + i * 0.02, 0.16 + i * 0.02, 0.08 + i * 0.01, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 88 + math.sin(app.t + i) * 10, 82, h - 166)
    end
    lurek.render.setColor(0.96, 0.95, 0.92, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.92, 0.84, 0.56, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.88, 0.88, 0.82)
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
