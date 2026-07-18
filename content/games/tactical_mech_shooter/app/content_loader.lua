local M = {}

local ROOT = ""
local MOD_ROOT = "mods"
local CORE = MOD_ROOT .. "/core/"
local RACE_ROOT = CORE .. "races/"

local function channel(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function color_key(r, g, b)
    return channel(r) .. ":" .. channel(g) .. ":" .. channel(b)
end

local function color_key_from_definition(color)
    return color_key((color[1] or 0) * 255, (color[2] or 0) * 255, (color[3] or 0) * 255)
end

local function copy_array(values)
    local copy = {}
    for i, value in ipairs(values or {}) do copy[i] = value end
    return copy
end

-- The PNG is a data map, not a texture. Each special RGB value is decoded into
-- a tile plus optional spawn/light metadata before the shared world systems run.
local MAP_SPECIAL_COLORS = {
    ["51:230:97"] = {
        tile = "grass",
        spawn = {team = 1, name = "GREEN BASE", radius = 12, color = {0.20, 0.90, 0.38, 1}},
        light = {radius = 24, intensity = 1.15, color = {0.20, 1.00, 0.42}},
    },
    ["242:46:36"] = {
        tile = "sand",
        spawn = {team = 2, name = "RED BASE", radius = 12, color = {0.95, 0.18, 0.14, 1}},
        light = {radius = 24, intensity = 1.15, color = {1.00, 0.20, 0.14}},
    },
    ["46:122:255"] = {
        tile = "grass",
        spawn = {team = 3, name = "BLUE BASE", radius = 12, color = {0.18, 0.48, 1.00, 1}},
        light = {radius = 24, intensity = 1.15, color = {0.18, 0.48, 1.00}},
    },
    ["255:184:31"] = {
        tile = "grass",
        spawn = {team = 4, name = "GOLD BASE", radius = 12, color = {1.00, 0.72, 0.12, 1}},
        light = {radius = 24, intensity = 1.15, color = {1.00, 0.72, 0.12}},
    },
    ["255:255:255"] = {
        tile = "floor",
        objective = {kind = "flag", id = "central_flag", name = "CENTRAL FLAG"},
        light = {radius = 18, intensity = 1.00, color = {0.90, 0.95, 1.00}},
    },
    ["209:219:255"] = {tile = "floor", light = {radius = 20, intensity = 1.10, color = {0.82, 0.86, 1.00}}},
    ["140:184:255"] = {tile = "floor", light = {radius = 13, intensity = 0.78, color = {0.55, 0.72, 1.00}}},
    ["255:148:77"] = {tile = "floor", light = {radius = 13, intensity = 0.78, color = {1.00, 0.58, 0.30}}},
    ["102:255:148"] = {tile = "floor", light = {radius = 13, intensity = 0.78, color = {0.40, 1.00, 0.58}}},
    ["255:89:97"] = {tile = "floor", light = {radius = 13, intensity = 0.78, color = {1.00, 0.35, 0.38}}},
    ["89:191:255"] = {tile = "grass", light = {radius = 10, intensity = 0.62, color = {0.35, 0.75, 1.00}}},
    ["77:166:255"] = {tile = "water", light = {radius = 10, intensity = 0.62, color = {0.30, 0.65, 1.00}}},
    ["166:255:107"] = {tile = "grass", light = {radius = 9, intensity = 0.55, color = {0.65, 1.00, 0.42}}},
    ["255:184:82"] = {tile = "sand", light = {radius = 9, intensity = 0.55, color = {1.00, 0.72, 0.32}}},
    ["255:97:71"] = {tile = "sand", light = {radius = 9, intensity = 0.55, color = {1.00, 0.38, 0.28}}},
    ["255:194:71"] = {tile = "sand", light = {radius = 9, intensity = 0.55, color = {1.00, 0.76, 0.28}}},
    ["255:168:64"] = {tile = "sand", light = {radius = 9, intensity = 0.55, color = {1.00, 0.66, 0.25}}},
    ["77:148:255"] = {tile = "grass", light = {radius = 9, intensity = 0.55, color = {0.30, 0.58, 1.00}}},
    ["128:255:173"] = {tile = "grass", light = {radius = 9, intensity = 0.55, color = {0.50, 1.00, 0.68}}},
    ["122:194:255"] = {tile = "grass", light = {radius = 9, intensity = 0.55, color = {0.48, 0.76, 1.00}}},
}

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

local function register_group(registry, destination, entries, type_name, race)
    for _, entry in ipairs(entries or {}) do
        assert(type(entry.id) == "string" and entry.id ~= "", "missing " .. type_name .. " id")
        if race then
            entry.race_id = race.id
            entry.race = entry.race or race.id
            entry.race_flags = type(entry.race_flags) == "table" and entry.race_flags or copy_array(race.flags)
        end
        destination[entry.id] = entry
        registry:register(type_name, entry.id, entry)
    end
end

local function load_sprite(path)
    assert(type(path) == "string" and path ~= "", "missing raster asset path")
    local full_path = ROOT .. path
    local ok, image = pcall(lurek.render.newImage, full_path)
    assert(ok and image, "cannot load raster asset: " .. full_path .. " " .. tostring(image))
    return image, full_path
end

local function attach_sprite(entry, field)
    if entry[field] then
        entry[field .. "_image"], entry[field .. "_path"] = load_sprite(entry[field])
    end
end

local function load_raster_assets(content)
    for _, race in pairs(content.races) do attach_sprite(race, "icon") end
    for _, corpus in pairs(content.corpora) do attach_sprite(corpus, "sprite") end
    for _, weapon in pairs(content.weapons) do attach_sprite(weapon, "sprite") end
    for _, backpack in pairs(content.backpacks) do attach_sprite(backpack, "sprite") end
    for _, effect in pairs(content.effects) do attach_sprite(effect, "sprite") end

    -- Weapons refer to shared effect records from TOML, so combat never needs
    -- to invent a primitive fallback for a projectile or impact.
    for _, weapon in pairs(content.weapons) do
        local projectile_effect = content.effects[weapon.projectile_effect or "projectile"]
        local impact_effect = content.effects[weapon.impact_effect or "explosion"]
        assert(projectile_effect and impact_effect, "weapon effect references are incomplete: " .. tostring(weapon.id))
        weapon.projectile_image = projectile_effect.sprite_image
        weapon.impact_image = impact_effect.sprite_image
        weapon.flame_image = content.effects.flame and content.effects.flame.sprite_image
        weapon.beam_image = content.effects.beam and content.effects.beam.sprite_image
    end
end

local function load_race_bundles(registry, content)
    local manifests = {}
    for _, path in ipairs(lurek.filesystem.listRecursive(RACE_ROOT) or {}) do
        path = tostring(path)
        if path:match("race%.toml$") then
            if path:sub(1, #RACE_ROOT) ~= RACE_ROOT then path = RACE_ROOT .. path end
            manifests[#manifests + 1] = path
        end
    end
    table.sort(manifests)
    assert(#manifests > 0, "no race bundles found under " .. RACE_ROOT)
    for _, manifest_path in ipairs(manifests) do
        local race_doc = parse_file(manifest_path)
        local race = race_doc.race or {}
        assert(type(race.id) == "string" and race.id ~= "", "race manifest is missing id: " .. manifest_path)
        assert(type(race.flags) == "table" and #race.flags > 0, "race has no flags: " .. race.id)
        content.races[race.id] = race
        registry:register("race", race.id, race)

        local race_dir = manifest_path:gsub("race%.toml$", "")
        local corpus_doc = parse_file(race_dir .. "corpora.toml")
        local backpack_doc = parse_file(race_dir .. "backpacks.toml")
        local weapon_doc = parse_file(race_dir .. "weapons.toml")
        register_group(registry, content.corpora, corpus_doc.corpus, "corpus", race)
        register_group(registry, content.backpacks, backpack_doc.backpack, "backpack", race)
        register_group(registry, content.weapons, weapon_doc.weapon, "weapon", race)
    end
end

local function load_png_map(path, content, spec)
    -- newImageData decodes PNG-backed GameFS files; loadImage is reserved for
    -- the engine's serialized LIMG image format on this runtime.
    local ok, image = pcall(lurek.image.newImageData, path)
    assert(ok and image, "cannot load PNG map: " .. path .. " " .. tostring(image))
    local width, height = image:getWidth(), image:getHeight()
    assert(width > 2 and height > 2, "PNG map is too small: " .. path)

    local palette = {}
    for id, tile in pairs(content.tiles) do
        if type(tile.color) == "table" then palette[color_key_from_definition(tile.color)] = id end
    end

    local map = {
        id = spec.id,
        name = spec.name,
        description = spec.description,
        mode = spec.mode or "elimination",
        team_count = tonumber(spec.team_count) or 4,
        teams = copy_array(spec.teams),
        alliances = copy_array(spec.alliances),
        objective = {
            kind = spec.objective_kind or "elimination",
            target_team = tonumber(spec.objective_target_team),
            base_health = tonumber(spec.objective_base_health),
            capture_limit = tonumber(spec.objective_capture_limit),
        },
        width = width,
        height = height,
        tile_size = tonumber(content.game.tile_size) or 32,
        seed = tonumber(content.game.seed) or 271828,
        obstacle_count = 0,
        source_image = path,
        tiles = {},
        spawn = {},
        light = {},
        objectives = {},
    }
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local r, g, b = image:getPixel(x, y)
            local key = color_key(r, g, b)
            local special = MAP_SPECIAL_COLORS[key]
            local tile = special and special.tile or palette[key]
            assert(tile, "unknown map color " .. key .. " at " .. x .. "," .. y)
            local index = y * width + x + 1
            map.tiles[index] = tile
            if special and special.spawn then
                local spawn = {}
                for field, value in pairs(special.spawn) do spawn[field] = value end
                spawn.x, spawn.y = x + 1, y + 1
                map.spawn[#map.spawn + 1] = spawn
            end
            if special and special.objective then
                local objective = {}
                for field, value in pairs(special.objective) do objective[field] = value end
                objective.x, objective.y = x + 1, y + 1
                map.objectives[#map.objectives + 1] = objective
            end
            if special and special.light then
                local light = {}
                for field, value in pairs(special.light) do light[field] = value end
                light.x, light.y = x + 1, y + 1
                map.light[#map.light + 1] = light
            end
        end
    end
    assert(#map.spawn == map.team_count, string.format("PNG map %s must contain %d team spawn markers", map.id, map.team_count))
    return map
end

function M.load(root)
    ROOT = root or ""
    MOD_ROOT = ROOT .. "mods"
    CORE = MOD_ROOT .. "/core/"
    RACE_ROOT = CORE .. "races/"
    local manager = lurek.mods.newModManager()
    local scan_ok, scan_report = pcall(manager.scanFolder, manager, MOD_ROOT)
    local mods_ok, mods = pcall(manager.getAllMods, manager)
    local order_ok, load_order = pcall(manager.getLoadOrder, manager)

    local registry = lurek.mods.newRegistry()
    local schema = parse_file(CORE .. "schemas.toml")
    local types = { "race", "corpus", "weapon", "backpack", "effect", "preset", "ai_profile", "tile", "map" }
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
    local content = {
        races = {},
        corpora = {},
        weapons = {},
        backpacks = {},
        presets = {},
        ai_profiles = {},
        effects = {},
        tiles = {},
        maps = {},
        map_order = {},
    }

    content.game = game_doc.game or {}
    load_race_bundles(registry, content)
    register_group(registry, content.effects, parse_file(CORE .. "effects.toml").effect, "effect")
    register_group(registry, content.presets, parse_file(CORE .. "presets.toml").preset, "preset")
    register_group(registry, content.ai_profiles, ai_doc.ai and ai_doc.ai.profile, "ai_profile")
    register_group(registry, content.tiles, tiles_doc.tile, "tile")
    local maps_doc = parse_file(CORE .. "maps/maps.toml")
    for _, spec in ipairs(maps_doc.map or {}) do
        assert(type(spec.id) == "string" and spec.id ~= "", "map catalog entry is missing id")
        assert(type(spec.image) == "string" and spec.image ~= "", "map catalog entry is missing image: " .. spec.id)
        local map_doc = load_png_map(ROOT .. spec.image, content, spec)
        content.maps[map_doc.id] = map_doc
        content.map_order[#content.map_order + 1] = map_doc.id
        registry:register("map", map_doc.id, map_doc)
    end
    assert(#content.map_order > 0, "map catalog is empty")
    load_raster_assets(content)
    registry:freeze()

    local default_map_id = content.game.default_map or content.map_order[1]
    assert(content.maps[default_map_id], "unknown default map: " .. tostring(default_map_id))
    local function select_map(map_id)
        local selected = content.maps[map_id]
        assert(selected, "unknown map: " .. tostring(map_id))
        content.active_map = selected
        content.selected_map_id = selected.id
        return selected
    end
    select_map(default_map_id)

    local runtime = {
        root = ROOT,
        core = CORE,
        manager = manager,
        mod_scan = scan_ok and scan_report or {},
        mods = mods_ok and mods or {},
        load_order = order_ok and load_order or {},
        registry = registry,
        schema = schema,
        game = content.game,
        economy = game_doc.economy or {},
        movement = game_doc.movement or {},
        map = game_doc.map or {},
        active_map = content.active_map,
        maps = content.maps,
        map_order = content.map_order,
        selected_map_id = content.selected_map_id,
        effects = content.effects,
        ai = ai_doc.ai or {},
        content = content,
    }
    function runtime.select_map(map_id)
        local selected = select_map(map_id)
        runtime.active_map = selected
        runtime.selected_map_id = selected.id
        return selected
    end
    return runtime
end

return M
