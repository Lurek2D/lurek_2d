local app = {
    title = "Learning Lab",
    genre = "app / machine learning visual lab",
    modules = { "learning", "charts", "dataframe", "compute" },
    notes = {
        "Merge target for route attention and sales forecast learning demos.",
        "This skeleton covers tensor setup, chart surface, dataframe rows, and compute array state.",
        "Next step: add tabs for attention, forecast, and small RL experiments.",
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
    lurek.render.setBackgroundColor(0.03, 0.05, 0.04)
    record("tensor", function() app.tensor = lurek.learning.newTensor({ 2, 2 }, { 1, 2, 3, 4 }); return "ready" end)
    record("chart", function() app.chart = lurek.charts.newLine({ width = 220, height = 100 }); return "ready" end)
    record("dataframe", function() app.df = lurek.dataframe.fromRows({ "x", "y" }, { { 1, 2 }, { 2, 4 } }); return "ready" end)
    record("compute", function() app.arr = lurek.compute.ones({ 4 }); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.03, 0.05, 0.04, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.08 + i * 0.02, 0.18 + i * 0.02, 0.14 + i * 0.02, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 88 + math.sin(app.t + i) * 11, 82, h - 166)
    end
    lurek.render.setColor(0.94, 0.96, 0.94, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.60, 0.90, 0.76, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.84, 0.90, 0.86)
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
