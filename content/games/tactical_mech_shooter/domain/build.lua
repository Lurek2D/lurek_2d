local M = {}

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function n(v, fallback)
    return tonumber(v) or fallback or 0
end

local function compatible(corpus, item)
    local corpus_flags = corpus and corpus.race_flags or {}
    local item_flags = item and item.race_flags or {}
    for _, corpus_flag in ipairs(corpus_flags) do
        for _, item_flag in ipairs(item_flags) do
            if corpus_flag == item_flag or corpus_flag == "universal" or item_flag == "universal" then return true end
        end
    end
    return false
end

function M.can_equip(corpus, item)
    return compatible(corpus, item)
end

function M.compose(content, spec)
    local corpora = content.content.corpora
    local weapons = content.content.weapons
    local backpacks = content.content.backpacks
    local corpus = corpora[spec.corpus]
    local left = weapons[spec.left]
    local right = weapons[spec.right]
    local backpack = backpacks[spec.backpack or "none"]
    if not corpus or not left or not right or not backpack then
        return nil, "build references missing content"
    end
    if not compatible(corpus, left) then return nil, "left weapon is not compatible with corpus race" end
    if not compatible(corpus, right) then return nil, "right weapon is not compatible with corpus race" end
    if not compatible(corpus, backpack) then return nil, "backpack is not compatible with corpus race" end
    local cargo = left.size + right.size + backpack.size
    if cargo > corpus.cargo + n(backpack.cargo_bonus) then
        return nil, "build exceeds cargo capacity"
    end

    local speed = 1 + n(backpack.speed_mod) + n(left.speed_mod) + n(right.speed_mod)
    local rotation = 1 + n(backpack.rotation_mod) + n(left.rotation_mod) + n(right.rotation_mod)
    local jump = 1 + n(backpack.jump_mod) + n(left.jump_mod) + n(right.jump_mod)
    speed = clamp(speed, 0.25, 2.0)
    rotation = clamp(rotation, 0.25, 2.0)
    jump = clamp(jump, 0.25, 2.0)

    return {
        name = spec.name or corpus.name,
        corpus_id = corpus.id,
        left_id = left.id,
        right_id = right.id,
        backpack_id = backpack.id,
        corpus = corpus,
        left = left,
        right = right,
        backpack = backpack,
        cargo_used = cargo,
        cargo = corpus.cargo + n(backpack.cargo_bonus),
        cost = n(corpus.cost) + n(left.cost) + n(right.cost) + n(backpack.cost),
        max_health = n(corpus.health) + n(backpack.health_bonus),
        health_regen = n(corpus.health_regen) + n(backpack.health_regen_mod),
        max_energy = n(corpus.energy) + n(backpack.energy_bonus),
        energy_regen = math.max(0, n(corpus.energy_regen) + n(backpack.energy_regen_mod)),
        energy_regen_penalty = n(left.energy_regen_penalty) + n(right.energy_regen_penalty),
        move_speed = n(corpus.move_speed) * speed,
        rotation_speed = n(corpus.rotation_speed) * rotation,
        jump_power = n(corpus.jump_power, 220) * jump,
        jump_gravity = n(corpus.jump_gravity, 700),
        sight = n(corpus.sight, 8) + n(backpack.sight_bonus),
        vision_arc = clamp(n(corpus.vision_arc, 360) + n(backpack.vision_arc_bonus), 60, 360),
        darkvision = n(backpack.darkvision),
        smoke_resist = n(backpack.smoke_resist),
        signature = clamp(1 + n(backpack.signature_mod), 0.15, 2.0),
        aim_multiplier = math.max(0.25, n(backpack.aim_mod, 1)),
        shield = n(backpack.shield),
    }
end

function M.from_preset(content, preset_id)
    local preset = content.content.presets[preset_id]
    if not preset then return nil, "unknown preset " .. tostring(preset_id) end
    return M.compose(content, preset)
end

return M
