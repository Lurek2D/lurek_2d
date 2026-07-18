local M = {}

local ROOT = ""
local MOD_ROOT = "mods"
local CORE = MOD_ROOT .. "/core/"

local function parse_file(path)
    local ok_asset, handle = pcall(lurek.asset.load, path, "toml", { group = "tactical_mech_shooter" })
    local raw
    if ok_asset and handle then
        local ok_get, value = pcall(lurek.asset.get, handle)
        if ok_get then raw = value end
        pcall(lurek.asset.unload, handle)
    end
    if type(raw) ~= "string" then
        raw = lurek.filesystem.read(path)
    end
    local ok, value = pcall(lurek.serialize.fromToml, raw)
    assert(ok and type(value) == "table", "invalid TOML: " .. path .. " " .. tostring(value))
    return value
end

local function register_group(registry, destination, entries, type_name)
    for _, entry in ipairs(entries or {}) do
        assert(type(entry.id) == "string" and entry.id ~= "", "missing " .. type_name .. " id")
        destination[entry.id] = entry
        registry:register(type_name, entry.id, entry)
    end
end

function M.load(root)
    ROOT = root or ""
    MOD_ROOT = ROOT .. "mods"
    CORE = MOD_ROOT .. "/core/"
    local manager = lurek.mods.newModManager()
    local scan_ok, scan_report = pcall(manager.scanFolder, manager, MOD_ROOT)
    local mods_ok, mods = pcall(manager.getAllMods, manager)
    local order_ok, load_order = pcall(manager.getLoadOrder, manager)

    local registry = lurek.mods.newRegistry()
    local schema = parse_file(CORE .. "schemas.toml")
    local types = { "corpus", "weapon", "backpack", "preset", "ai_profile", "tile", "map" }
    for _, type_name in ipairs(types) do
        local schema_type = schema.types and schema.types[type_name]
        if schema_type and schema_type.required then
            local fields = {}
            for _, field_name in ipairs(schema_type.required) do fields[field_name] = {required = true} end
            -- TOML keeps the required-field contract, while the schema explicitly
            -- opts into gameplay-specific extension fields (colors, jump tuning,
            -- deployable limits, etc.) without making the registry reject them.
            local allow_unknown = schema_type.allowUnknown
            if allow_unknown == nil then allow_unknown = schema_type.allow_unknown end
            registry:defineType(type_name, {fields = fields, allowUnknown = allow_unknown == true})
        else
            registry:registerType(type_name)
        end
    end
    local game_doc = parse_file(CORE .. "game.toml")
    local ai_doc = parse_file(CORE .. "ai.toml")
    local tiles_doc = parse_file(CORE .. "tiles.toml")
    local map_doc = parse_file(CORE .. "maps/arena_01.toml")

    local content = {
        corpora = {},
        weapons = {},
        backpacks = {},
        presets = {},
        ai_profiles = {},
        tiles = {},
        maps = {},
    }

    register_group(registry, content.corpora, parse_file(CORE .. "corpora.toml").corpus, "corpus")
    register_group(registry, content.weapons, parse_file(CORE .. "weapons.toml").weapon, "weapon")
    register_group(registry, content.backpacks, parse_file(CORE .. "backpacks.toml").backpack, "backpack")
    register_group(registry, content.presets, parse_file(CORE .. "presets.toml").preset, "preset")
    register_group(registry, content.ai_profiles, ai_doc.ai and ai_doc.ai.profile, "ai_profile")
    register_group(registry, content.tiles, tiles_doc.tile, "tile")
    map_doc.map.id = map_doc.map.id or "arena_01"
    content.maps[map_doc.map.id] = map_doc.map
    registry:register("map", map_doc.map.id, map_doc.map)
    registry:freeze()

    return {
        root = ROOT,
        core = CORE,
        manager = manager,
        mod_scan = scan_ok and scan_report or {},
        mods = mods_ok and mods or {},
        load_order = order_ok and load_order or {},
        registry = registry,
        schema = schema,
        game = game_doc.game or {},
        economy = game_doc.economy or {},
        movement = game_doc.movement or {},
        map = game_doc.map or {},
        active_map = map_doc.map,
        ai = ai_doc.ai or {},
        content = content,
    }
end

return M
