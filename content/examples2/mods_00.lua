--- Mods Module Part 1: LMod creation, metadata, hooks, config, registry

--@api-stub: lurek.mods.newMod
-- Creates a mod from a metadata table.
do
    ---@type LMod
    local m = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        version = "1.0.0",
        author = "Dev",
        description = "A test mod",
        priority = 10,
    })
    print("id=" .. m:getId() .. " name=" .. m:getName())
    print("version=" .. m:getVersion() .. " author=" .. m:getAuthor())
    print("desc=" .. m:getDescription())
    print("priority=" .. m:getPriority())
end

--@api-stub: LMod:setEnabled / isEnabled / isLoaded
-- Enable state and loaded flag.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "toggle", name = "Toggle", version = "1.0", author = "A", description = "d"})
    m:setEnabled(true)
    print("enabled=" .. tostring(m:isEnabled()) .. " loaded=" .. tostring(m:isLoaded()))
    m:setEnabled(false)
    print("enabled=" .. tostring(m:isEnabled()))
end

--@api-stub: LMod:setHook / getHook / hasHook / getHookNames
-- Registering and querying hooks.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "hooks", name = "Hooks", version = "1.0", author = "A", description = "d"})
    m:setHook("onLoad", function() print("loaded!") end)
    m:setHook("onUnload", function() print("unloaded!") end)
    print("has onLoad = " .. tostring(m:hasHook("onLoad")))
    print("has onSave = " .. tostring(m:hasHook("onSave")))
    local names = m:getHookNames()
    print("hooks = " .. table.concat(names, ", "))
    local fn = m:getHook("onLoad")
    if fn then fn() end
end

--@api-stub: LMod:setConfig / getConfig
-- Storing and retrieving mod config.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "cfg", name = "Cfg", version = "1.0", author = "A", description = "d"})
    m:setConfig({difficulty = "hard", volume = 0.8})
    local cfg = m:getConfig()
    if cfg then
        print("config stored")
    end
end

--@api-stub: LMod:setConfigSchema / getConfigSchema
-- Config schema for UI/validation.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "schema", name = "Schema", version = "1.0", author = "A", description = "d"})
    m:setConfigSchema({
        {key = "volume", type = "number", default = "0.5"},
        {key = "language", type = "string", default = "en"},
    })
    local schema = m:getConfigSchema()
    for _, entry in ipairs(schema) do
        print(entry.key .. " (" .. entry.type .. ") = " .. entry.default)
    end
end

--@api-stub: LMod:setApiVersion / getApiVersion
-- API version compatibility.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "ver", name = "Ver", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("2.0.0")
    print("api version = " .. m:getApiVersion())
end

--@api-stub: LMod:setCapabilities / getCapabilities
-- Declaring capabilities.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "caps", name = "Caps", version = "1.0", author = "A", description = "d"})
    m:setCapabilities({"renderer", "audio", "physics"})
    local caps = m:getCapabilities()
    print("capabilities = " .. table.concat(caps, ", "))
end

--@api-stub: LMod:getDependencies
-- Mod dependencies.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "deps", name = "Deps", version = "1.0", author = "A", description = "d"})
    local deps = m:getDependencies()
    print("dependencies = " .. #deps)
end

--@api-stub: LMod:releaseRefs
-- Release stored references.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "release", name = "R", version = "1.0", author = "A", description = "d"})
    m:setHook("test", function() end)
    m:setConfig({x = 1})
    m:releaseRefs()
    print("refs released")
end

--@api-stub: lurek.mods.newRegistry
-- Creates a content registry.
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    reg:registerType("weapon")
    reg:registerType("armor")
    local types = reg:getTypes()
    print("types = " .. table.concat(types, ", "))
end

--@api-stub: LContentRegistry:register / get / getAll
-- Storing and retrieving content.
do
    ---@type LContentRegistry
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", {name = "Sword", damage = 10})
    reg:register("item", "shield", {name = "Shield", armor = 5})
    local sword = reg:get("item", "sword")
    if sword then
        print("got: " .. (sword --[[@as table]]).name)
    end
    local all = reg:getAll("item")
    print("all items = " .. #all)
end

--@api-stub: lurek.mods.checkApiVersion
-- Checks mod/host API compatibility.
do
    ---@type LMod
    local m = lurek.mods.newMod({id = "compat", name = "C", version = "1.0", author = "A", description = "d"})
    m:setApiVersion("1.0.0")
    local ok, err = lurek.mods.checkApiVersion(m, "1.5.0")
    print("compatible = " .. tostring(ok))
    if err then print("error = " .. err) end
end

print("mods_00.lua")
