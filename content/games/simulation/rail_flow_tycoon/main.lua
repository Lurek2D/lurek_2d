local app = {
    title = "Rail Flow Tycoon",
    genre = "game / logistics simulation",
    modules = { "graph", "pathfind", "charts", "save", "ui" },
    notes = {
        "Foundation for stations that push and pull resources through a network.",
        "This skeleton already creates graph, route grid, chart, save manager, and UI panel.",
        "Next step: add track placement, schedules, bottleneck charts, and campaign rules.",
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
    lurek.render.setBackgroundColor(0.04, 0.05, 0.05)

    record("graph network", function()
        app.graph = lurek.graph.newGraph()
        app.a = app.graph:addNode("Mine")
        app.b = app.graph:addNode("Foundry")
        app.graph:addEdge(app.a, app.b, 4)
        return "ready"
    end)
    record("route grid", function() app.nav = lurek.pathfind.newNavGrid(20, 12); app.finder = lurek.pathfind.newPathfinder(app.nav); return "ready" end)
    record("chart surface", function() app.chart = lurek.charts.newLine({ width = 220, height = 100 }); return "ready" end)
    record("save manager", function() app.save = lurek.save.newSaveManager(); return "ready" end)
    record("ui panel", function() app.panel = lurek.ui.newPanel("rail_panel", 24, 84, 220, 120); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then
        lurek.event.quit()
    end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.04, 0.05, 0.05, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.10 + i * 0.03, 0.10 + i * 0.03, 0.08 + i * 0.02, 1)
        lurek.render.rectangle("fill", 30 + i * 128, 88 + math.sin(app.t * 0.7 + i) * 12, 80, h - 168)
    end
    lurek.render.setColor(0.95, 0.95, 0.92, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.74, 0.86, 0.62, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.82, 0.88, 0.84)
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
