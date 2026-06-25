local M = {}

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

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function relation_color(state, owner)
    if owner == "SEA" then
        return { 0.20, 0.42, 0.64, 1.0 }
    end
    if owner == state.player_tag then
        return { 0.20, 0.70, 0.25, 1.0 }
    end
    if owner == "LIT" then
        return { 0.45, 0.55, 0.95, 1.0 }
    end
    if owner == "TEU" or owner == "MOS" or owner == "OTT" then
        return { 0.85, 0.20, 0.18, 1.0 }
    end
    return { 0.58, 0.58, 0.52, 1.0 }
end

local function economy_color(province)
    if province.owner == "SEA" then
        return { 0.18, 0.38, 0.60, 1.0 }
    end
    local t = clamp((province.income or 0) / 10, 0, 1)
    return color_mix({ 0.25, 0.20, 0.12, 1.0 }, { 1.0, 0.82, 0.25, 1.0 }, t)
end

local function unrest_color(province)
    if province.owner == "SEA" then
        return { 0.18, 0.38, 0.60, 1.0 }
    end
    local t = clamp((province.unrest or 0) / 10, 0, 1)
    return color_mix({ 0.22, 0.45, 0.23, 1.0 }, { 0.88, 0.08, 0.05, 1.0 }, t)
end

local function terrain_color(province)
    local terrain = tostring(province and province.terrain or ""):lower()
    if province and province.owner == "SEA" then
        return { 0.18, 0.38, 0.60, 1.0 }
    end
    if terrain == "forest" then
        return { 0.30, 0.55, 0.34, 1.0 }
    end
    if terrain == "mountain" then
        return { 0.48, 0.46, 0.42, 1.0 }
    end
    if terrain == "desert" then
        return { 0.78, 0.64, 0.36, 1.0 }
    end
    if terrain == "marsh" then
        return { 0.35, 0.56, 0.52, 1.0 }
    end
    return { 0.42, 0.62, 0.35, 1.0 }
end

local function political_base_color(state, province)
    local country = state.countries[province.owner]
    if country and country.color then
        return country.color
    end
    local neutral = state.countries.NEU
    return neutral and neutral.color or { 126 / 255, 126 / 255, 118 / 255, 1.0 }
end

local function province_color(state, province, mode)
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
                    thickness = 1.0,
                    flags = {},
                })
            elseif a.owner ~= b.owner and not a_sea and not b_sea then
                reg:setBorderPairStyle(pair.province_a, pair.province_b, {
                    thickness = 1.5,
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
    return "political", apply_mode_colors(reg, state, mode)
end

return M
