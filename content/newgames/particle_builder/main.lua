local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

local config = load_module("scripts/config.lua")
local state = load_module("scripts/state.lua")
local input = load_module("scripts/input.lua")
local ui = load_module("scripts/ui.lua")
local renderer = load_module("scripts/renderer.lua")

local app

function lurek.init()
    lurek.window.setTitle(config.title)
    lurek.render.setBackgroundColor(0.035, 0.04, 0.055)
    app = state.new(config)
    input.bind(config)
    ui.load(config, app)
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    input.update(app, dt)
    state.update(app, dt)
    ui.update(config, app)
end

function lurek.draw()
    renderer.draw(config, app)
end

function lurek.draw_ui()
    ui.draw_fallback(config, app)
end

function lurek.keypressed(key)
    if app and input.keypressed then
        input.keypressed(app, key)
    end
end
