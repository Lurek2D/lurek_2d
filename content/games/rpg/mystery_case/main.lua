local app = {
    title = "Mystery Case",
    genre = "game / narrative investigation RPG",
    modules = { "dialog", "i18n", "scene", "save", "html" },
    notes = {
        "Merge target for visual novel, courtroom, dialog demo, and point-and-click adventure ideas.",
        "This skeleton covers dialog state, i18n table, scene setup, save manager, and HTML evidence panel.",
        "Next step: add testimony flow, evidence board, branching outcomes, and language switching.",
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
    lurek.render.setBackgroundColor(0.05, 0.04, 0.03)
    record("dialog state", function() app.dialog = lurek.dialog.newState(); return "ready" end)
    record("i18n table", function() lurek.i18n.loadTable("en", { title = "Mystery Case" }); return lurek.i18n.t("title") end)
    record("scene", function() app.scene = lurek.scene.new({ name = "case" }); return "ready" end)
    record("save", function() app.save = lurek.save.newSaveManager(); return "ready" end)
    record("html doc", function() app.doc = lurek.html.newDocument("<body><h1>Evidence</h1></body>", { width = 320, height = 180 }); return "ready" end)
end

function lurek.process(dt)
    app.t = app.t + dt
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
end

function lurek.draw()
    local w, h = lurek.render.getDimensions()
    lurek.render.clear(0.05, 0.04, 0.03, 1)
    for i = 1, 6 do
        lurek.render.setColor(0.18 + i * 0.02, 0.14 + i * 0.01, 0.08 + i * 0.01, 1)
        lurek.render.rectangle("fill", 30 + i * 126, 88 + math.sin(app.t + i) * 10, 82, h - 166)
    end
    lurek.render.setColor(0.96, 0.94, 0.90, 1)
    lurek.render.print(app.title, 32, 24)
    lurek.render.setColor(0.92, 0.74, 0.58, 1)
    lurek.render.print(app.genre, 32, 50)
    draw_text(app.notes, 42, 96, 0.90, 0.86, 0.82)
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
