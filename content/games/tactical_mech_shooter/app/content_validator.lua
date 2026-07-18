local M = {}

local function count(tbl)
    local n = 0
    for _ in pairs(tbl or {}) do n = n + 1 end
    return n
end

local function require_ref(tbl, id, label)
    assert(tbl[id], "unknown " .. label .. " '" .. tostring(id) .. "'")
end

function M.validate(content)
    local c = content.content
    assert(count(c.races) >= 4, "expected modern_light, modern_heavy, organic, and alien races")
    assert(count(c.corpora) >= 32, "expected the standard set plus race chassis")
    assert(count(c.weapons) >= 52, "expected the standard set plus race weapons")
    assert(count(c.backpacks) >= 33, "expected the standard set plus race backpacks")
    assert(count(c.effects) == 8, "expected the shared PNG combat effect set")
    assert(count(c.presets) == 12, "expected 12 presets")
    assert(count(c.maps) == 6 and #content.map_order == 6, "expected six catalogued PNG maps")

    local expected_maps = {
        arena_01 = {mode = "free_for_all", teams = 4},
        twin_bastion = {mode = "balanced_2v2", teams = 4},
        crossfire_quads = {mode = "free_for_all", teams = 4},
        assault_northline = {mode = "assault", teams = 2},
        assault_reactor = {mode = "assault", teams = 2},
        tri_flag_rift = {mode = "capture_the_flag", teams = 3},
    }
    for id, expected in pairs(expected_maps) do
        local map = c.maps[id]
        assert(map and map.source_image:match("%.png$"), "missing PNG map: " .. id)
        assert(map.mode == expected.mode and map.team_count == expected.teams, "invalid map scenario: " .. id)
        assert(#map.spawn == expected.teams and #map.tiles == map.width * map.height, "invalid PNG map data: " .. id)
    end
    assert(#c.maps.tri_flag_rift.objectives >= 1, "CTF map is missing its neutral flag marker")
    assert(#(c.maps.twin_bastion.alliances or {}) == 2, "2v2 map is missing its two alliances")

    for id, race in pairs(c.races) do
        assert(race.id == id and type(race.flags) == "table" and #race.flags > 0, "invalid race manifest: " .. id)
        assert(type(race.description) == "string" and #race.description >= 80 and race.description:lower():find("top-down", 1, true), "race visual description is missing: " .. id)
        assert(type(race.icon) == "string" and race.icon:match("%.png$") and race.icon_image, "race icon is not loaded: " .. id)
    end

    local function compatible(corpus, item)
        for _, corpus_flag in ipairs(corpus.race_flags or {}) do
            for _, item_flag in ipairs(item.race_flags or {}) do
                if corpus_flag == item_flag or corpus_flag == "universal" or item_flag == "universal" then return true end
            end
        end
        return false
    end

    for id, corpus in pairs(c.corpora) do
        assert(c.races[corpus.race_id] and corpus.race == corpus.race_id, "corpus has unknown race: " .. id)
        assert(type(corpus.race_flags) == "table" and #corpus.race_flags > 0, "corpus has no race flags: " .. id)
        assert(type(corpus.description) == "string" and #corpus.description >= 80 and corpus.description:lower():find("top-down", 1, true), "corpus visual description is missing: " .. id)
        assert(type(corpus.sprite) == "string" and corpus.sprite:match("%.png$") and corpus.sprite_image, "corpus sprite is not loaded: " .. id)
        assert(corpus.cargo >= 6 and corpus.cargo <= 72, "cargo out of range: " .. id)
        assert(corpus.radius > 0 and corpus.move_speed > 0, "invalid corpus: " .. id)
    end
    for id, weapon in pairs(c.weapons) do
        assert(c.races[weapon.race_id] and weapon.race == weapon.race_id, "weapon has unknown race: " .. id)
        assert(type(weapon.race_flags) == "table" and #weapon.race_flags > 0, "weapon has no race flags: " .. id)
        assert(type(weapon.description) == "string" and #weapon.description >= 80 and weapon.description:lower():find("top-down", 1, true), "weapon visual description is missing: " .. id)
        assert(type(weapon.sprite) == "string" and weapon.sprite:match("%.png$") and weapon.sprite_image, "weapon sprite is not loaded: " .. id)
        assert(c.effects[weapon.projectile_effect or "projectile"] and c.effects[weapon.impact_effect or "explosion"], "weapon PNG effect references are invalid: " .. id)
        assert(weapon.size >= 1 and weapon.size <= 21, "weapon size out of range: " .. id)
        assert(weapon.reload > 0 and weapon.range > 0, "invalid weapon timing: " .. id)
    end
    for id, backpack in pairs(c.backpacks) do
        assert(c.races[backpack.race_id] and backpack.race == backpack.race_id, "backpack has unknown race: " .. id)
        assert(type(backpack.race_flags) == "table" and #backpack.race_flags > 0, "backpack has no race flags: " .. id)
        assert(type(backpack.description) == "string" and #backpack.description >= 80 and backpack.description:lower():find("top-down", 1, true), "backpack visual description is missing: " .. id)
        assert(type(backpack.sprite) == "string" and backpack.sprite:match("%.png$") and backpack.sprite_image, "backpack sprite is not loaded: " .. id)
        assert(backpack.size >= 0 and backpack.size <= 21, "backpack size out of range: " .. id)
    end
    for id, effect in pairs(c.effects) do
        assert(type(effect.sprite) == "string" and effect.sprite:match("%.png$") and effect.sprite_image, "effect sprite is not loaded: " .. id)
    end
    for id, preset in pairs(c.presets) do
        require_ref(c.corpora, preset.corpus, "corpus in preset " .. id)
        require_ref(c.weapons, preset.left, "left weapon in preset " .. id)
        require_ref(c.weapons, preset.right, "right weapon in preset " .. id)
        require_ref(c.backpacks, preset.backpack, "backpack in preset " .. id)
        local corpus = c.corpora[preset.corpus]
        local left = c.weapons[preset.left]
        local right = c.weapons[preset.right]
        local backpack = c.backpacks[preset.backpack]
        assert(compatible(corpus, left), "left weapon race mismatch: " .. id)
        assert(compatible(corpus, right), "right weapon race mismatch: " .. id)
        assert(compatible(corpus, backpack), "backpack race mismatch: " .. id)
        assert(left.size + right.size + backpack.size <= corpus.cargo + (tonumber(backpack.cargo_bonus) or 0), "preset exceeds cargo: " .. id)
    end
    return true
end

return M
