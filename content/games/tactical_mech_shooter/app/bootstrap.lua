local M = {}

local function load_module(path, root)
    local full_path = (root or "") .. path
    local chunk = lurek.filesystem.load(full_path)
    assert(type(chunk) == "function", "cannot load " .. full_path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

function M.load(root)
    root = root or ""
    local ContentLoader = load_module("app/content_loader.lua", root)
    local Validator = load_module("app/content_validator.lua", root)
    local State = load_module("app/state.lua", root)
    local Save = load_module("app/save.lua", root)
    local content = ContentLoader.load(root)
    Validator.validate(content)
    local state = State.new(content)
    state.campaign = Save.load(root)
    state.game_root = root

    state.modules = {
        Save = Save,
        Build = load_module("domain/build.lua", root),
        Economy = load_module("domain/economy.lua", root),
        World = load_module("systems/world.lua", root),
        Physics = load_module("systems/physics.lua", root),
        Camera = load_module("systems/camera.lua", root),
        Movement = load_module("systems/movement.lua", root),
        Assets = load_module("systems/assets.lua", root),
        Teams = load_module("systems/teams.lua", root),
        Awareness = load_module("systems/awareness.lua", root),
        Lighting = load_module("systems/lighting.lua", root),
        Navigation = load_module("systems/navigation.lua", root),
        AI = load_module("systems/ai.lua", root),
        Combat = load_module("systems/combat.lua", root),
        Effects = load_module("systems/effects.lua", root),
        Minimap = load_module("systems/minimap.lua", root),
        Render = load_module("systems/render.lua", root),
        UI = load_module("systems/ui.lua", root),
        Battle = load_module("scenes/battle.lua", root),
        Title = load_module("scenes/title.lua", root),
        Hangar = load_module("scenes/hangar.lua", root),
        Results = load_module("scenes/results.lua", root),
        Pause = load_module("scenes/pause.lua", root),
    }
    return state
end

return M
