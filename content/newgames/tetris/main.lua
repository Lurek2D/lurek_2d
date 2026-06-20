local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

package.path = package.path .. ';content/newgames/tetris/scripts/?.lua;content/newgames/tetris/scripts/?/init.lua'

local config = load_module("scripts/config.lua")
local input = load_module("scripts/input.lua")
local audio = load_module("scripts/audio.lua")
local effects = load_module("scripts/effects.lua")
local state = load_module("scripts/state.lua")
local renderer = load_module("scripts/renderer.lua")
local ui = load_module("scripts/ui.lua")

local game
local screenshot_started = false

local function wants_screenshot()
    if not lurek.runtime or not lurek.runtime.getArgs then return false end
    for _, arg in ipairs(lurek.runtime.getArgs()) do
        if tostring(arg):find("--screenshot", 1, true) then return true end
    end
    return false
end

function lurek.init()
    lurek.window.setTitle(config.title)
    lurek.render.setBackgroundColor(config.colors.background[1], config.colors.background[2], config.colors.background[3])
    input.bind()
    audio.init(config)
    effects.init(config)
    game = state.new(config)
    ui.load(config, game, function() state.start(game) end)
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    if not screenshot_started and wants_screenshot() then
        screenshot_started = true
        state.start(game)
    end
    input.update(game, state, audio)
    state.update(game, dt, effects, audio)
    effects.update(dt)
    ui.sync(game)
end

function lurek.draw()
    renderer.draw(config, game, effects)
end

function lurek.draw_ui()
    renderer.draw_ui(config, game)
end
