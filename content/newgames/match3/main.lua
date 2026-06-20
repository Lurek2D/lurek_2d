local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

package.path = package.path .. ';content/newgames/match3/scripts/?.lua;content/newgames/match3/scripts/?/init.lua'

load_module("scripts/project.lua")
load_module("scripts/game.lua")
