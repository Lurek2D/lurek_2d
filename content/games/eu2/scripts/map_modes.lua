local M = {}
local SEA_COLOR = { 0.23, 0.36, 0.55, 1.0 }
local STRIPE_EFFECT_FLAG = 0x20

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function color_mix(a, b, t)
    return {
        lerp(a[1], b[1], t),
        lerp(a[2], b[2], t),
        lerp(a[3], b[3], t),
        1.0,
    }
end

local function desaturate(color, amount)
    local gray = color[1] * 0.299 + color[2] * 0.587 + color[3] * 0.114
    return {
        lerp(color[1], gray, amount),
        lerp(color[2], gray, amount),
        lerp(color[3], gray, amount),
        1.0,
    }
end

local function warm_wash(color, amount)
    local t = amount or 0
    if t < 0 then t = 0 end
    if t > 1 then t = 1 end
    local muted = desaturate(color, 0.24)
    return color_mix(muted, { 0.90, 0.84, 0.72, 1.0 }, t)
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function relation_color(state, owner)
    if owner == "SEA" then
        return SEA_COLOR
    end
    if owner == state.player_tag then
        return { 0.45, 0.66, 0.39, 1.0 }
    end
    if owner == "LIT" then
        return { 0.67, 0.57, 0.78, 1.0 }
    end
    if owner == "TEU" or owner == "MOS" or owner == "OTT" then
        return { 0.76, 0.38, 0.32, 1.0 }
    end
    return { 0.69, 0.64, 0.58, 1.0 }
end

local function economy_color(province)
    if province.owner == "SEA" then
        return SEA_COLOR
    end
    local t = clamp((province.income or 0) / 10, 0, 1)
    return color_mix({ 0.54, 0.45, 0.28, 1.0 }, { 0.90, 0.76, 0.41, 1.0 }, t)
end

local function unrest_color(province)
    if province.owner == "SEA" then
        return SEA_COLOR
    end
    local t = clamp((province.unrest or 0) / 10, 0, 1)
    return color_mix({ 0.48, 0.62, 0.39, 1.0 }, { 0.86, 0.28, 0.24, 1.0 }, t)
end

local function terrain_color(province)
    local terrain = tostring(province and province.terrain or ""):lower()
    if province and province.owner == "SEA" then
        return SEA_COLOR
    end
    if terrain == "forest" then
        return { 0.50, 0.62, 0.45, 1.0 }
    end
    if terrain == "mountain" then
        return { 0.63, 0.60, 0.56, 1.0 }
    end
    if terrain == "desert" then
        return { 0.79, 0.69, 0.48, 1.0 }
    end
    if terrain == "marsh" then
        return { 0.52, 0.63, 0.57, 1.0 }
    end
    return { 0.66, 0.72, 0.50, 1.0 }
end

local function political_base_color(state, province)
    if province and province.owner == "SEA" then
        return SEA_COLOR
    end
    local country = state.countries[province.owner]
    if country and country.color then
        return warm_wash(country.color, 0.18)
    end
    local neutral = state.countries.NEU
    return warm_wash(neutral and neutral.color or { 186 / 255, 181 / 255, 169 / 255, 1.0 }, 0.12)
end

local function province_color(state, province, mode)
    if province and province.owner == "SEA" then
        return SEA_COLOR
    end
    if mode == "terrain" then
        return terrain_color(province)
    end
    if mode == "economy" then
        return economy_color(province)
    end
    if mode == "diplomacy" then
        return relation_color(state, province.owner)
    end
    if mode == "unrest" then
        return unrest_color(province)
    end
    return political_base_color(state, province)
end

function M.province_color(state, province, mode)
    if not province then
        return relation_color(state, "SEA")
    end
    return province_color(state, province, mode or state.map_mode or "political")
end

local function apply_country_borders(reg, state)
    if not reg.adjacencies or not reg.setBorderPairStyle then
        return
    end
    if state.applied_border_revision == state.border_revision then
        return
    end
    local pairs = reg:adjacencies() or {}
    for _, pair in ipairs(pairs) do
        local a = state.provinces[pair.province_a]
        local b = state.provinces[pair.province_b]
        if a and b then
            local a_sea = a.owner == "SEA"
            local b_sea = b.owner == "SEA"
            if a_sea ~= b_sea then
                reg:setBorderPairStyle(pair.province_a, pair.province_b, {
                    thickness = 4.0,
                    flags = {},
                })
            elseif a.owner ~= b.owner and not a_sea and not b_sea then
                reg:setBorderPairStyle(pair.province_a, pair.province_b, {
                    thickness = 4.8,
                    flags = { "country" },
                })
            elseif a_sea and b_sea then
                reg:setBorderPairStyle(pair.province_a, pair.province_b, {
                    thickness = 1.0,
                    flags = {},
                })
            else
                reg:setBorderPairStyle(pair.province_a, pair.province_b, {
                    thickness = 1.0,
                    flags = {},
                })
            end
        end
    end
    state.applied_border_revision = state.border_revision
end

local function terrain_style_id(terrain)
    terrain = tostring(terrain or ""):lower()
    if terrain == "sea" or terrain == "river" or terrain == "ocean" then
        return 0
    end
    if terrain == "forest" or terrain == "woods" then
        return 2
    end
    if terrain == "mountain" or terrain == "hills" then
        return 3
    end
    if terrain == "desert" then
        return 4
    end
    if terrain == "marsh" or terrain == "swamp" then
        return 5
    end
    return 1
end

local function apply_visual_states(reg, state)
    if not reg.setVisualState then
        return
    end
    if state.applied_visual_revision == state.style_revision then
        return
    end
    local striped = state.striped_province_ids or {}
    for id in pairs(state.provinces) do
        local flagged = striped[id] == true
        reg:setVisualState(id, {
            weather_strength = 0,
            effect_flags = flagged and STRIPE_EFFECT_FLAG or 0,
            seed = flagged and ((id * 1103515245) % 2147483647) or 0,
        })
    end
    state.applied_visual_revision = state.style_revision
end

local function apply_terrain_types(reg, state)
    if not reg.setTerrainType then
        return
    end
    if state.applied_terrain_revision == state.style_revision then
        return
    end
    for id, province in pairs(state.provinces) do
        reg:setTerrainType(id, terrain_style_id(province.terrain))
    end
    state.applied_terrain_revision = state.style_revision
end

local function mode_cache(state, mode, revision_key)
    revision_key = revision_key or tostring(state.style_revision or 0)
    if state.mode_color_cache_revision ~= revision_key then
        state.mode_color_cache = {}
        state.mode_color_cache_revision = revision_key
    end
    state.mode_color_cache[mode] = state.mode_color_cache[mode] or {}
    return state.mode_color_cache[mode]
end

local function apply_visibility(reg, state)
    if not reg.setVisibilityState then
        return
    end
    if state.applied_visibility_revision == state.style_revision then
        return
    end
    for id, province in pairs(state.provinces) do
        local terrain = tostring(province.terrain or ""):lower()
        if terrain == "terra_incognita" then
            reg:setVisibilityState(id, 0)
        else
            reg:setVisibilityState(id, province.owner == "SEA" and 2 or 255)
        end
    end
    state.applied_visibility_revision = state.style_revision
end

local function color_key(state, mode)
    return table.concat({
        mode,
        tostring(state.style_revision or 0),
        tostring(state.revision or 0),
    }, ":")
end

local function apply_mode_colors(reg, state, mode)
    local key = color_key(state, mode)
    local colors = mode_cache(state, mode, key)
    for id, province in pairs(state.provinces) do
        if not colors[id] then
            colors[id] = province_color(state, province, mode)
        end
    end
    if not reg.setPoliticalColor then
        return colors
    end
    if state.applied_map_color_key == key then
        return nil
    end
    for id, color in pairs(colors) do
        reg:setPoliticalColor(id, color[1], color[2], color[3], color[4])
    end
    state.applied_map_color_key = key
    return nil
end

function M.apply(reg, state, mode)
    state.map_mode = mode
    apply_country_borders(reg, state)
    apply_visibility(reg, state)
    apply_terrain_types(reg, state)
    apply_visual_states(reg, state)
    return "political", apply_mode_colors(reg, state, mode)
end

M.sea_color = SEA_COLOR
M.stripe_effect_flag = STRIPE_EFFECT_FLAG

return M
