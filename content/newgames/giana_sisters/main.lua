local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

package.path = package.path .. ';content/newgames/giana_sisters/scripts/?.lua;content/newgames/giana_sisters/scripts/?/init.lua'

load_module("scripts/project.lua")
load_module("scripts/game.lua")
