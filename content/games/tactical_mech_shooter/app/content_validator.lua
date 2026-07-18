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
    assert(count(c.corpora) == 30, "expected 30 corpora")
    assert(count(c.weapons) == 50, "expected 50 weapons")
    assert(count(c.backpacks) == 31, "expected 30 backpacks plus none")
    assert(count(c.presets) == 12, "expected 12 presets")

    for id, corpus in pairs(c.corpora) do
        assert(corpus.cargo >= 6 and corpus.cargo <= 72, "cargo out of range: " .. id)
        assert(corpus.radius > 0 and corpus.move_speed > 0, "invalid corpus: " .. id)
    end
    for id, weapon in pairs(c.weapons) do
        assert(weapon.size >= 1 and weapon.size <= 21, "weapon size out of range: " .. id)
        assert(weapon.reload > 0 and weapon.range > 0, "invalid weapon timing: " .. id)
    end
    for id, backpack in pairs(c.backpacks) do
        assert(backpack.size >= 0 and backpack.size <= 21, "backpack size out of range: " .. id)
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
        assert(left.size + right.size + backpack.size <= corpus.cargo + (tonumber(backpack.cargo_bonus) or 0), "preset exceeds cargo: " .. id)
    end
    return true
end

return M
