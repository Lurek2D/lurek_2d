--- Province color and renderer-style policy for EU2 map modes.
--- Public functions return colors or apply cached visual state to the province registry.
local M = {}
--- Shared sea color used by every map mode.
local SEA_COLOR = { 0.23, 0.36, 0.55, 1.0 }
--- Renderer bit flag used for the striped contested-province effect.
local STRIPE_EFFECT_FLAG = 0x20

---@param a number First scalar.
---@param b number Second scalar.
---@param t number Interpolation amount, normally 0..1.
---@return number interpolated Linear interpolation result.
local function lerp(a, b, t)
    return a + (b - a) * t
end

---@param a number[] First RGBA color.
---@param b number[] Second RGBA color.
---@param t number Interpolation amount.
---@return number[] color Mixed opaque RGBA color.
local function color_mix(a, b, t)
    return {
        lerp(a[1], b[1], t),
        lerp(a[2], b[2], t),
        lerp(a[3], b[3], t),
        1.0,
    }
end

---@param color number[] RGBA color.
---@param amount number Desaturation amount, where 0 preserves color and 1 is grayscale.
---@return number[] color Desaturated opaque RGBA color.
local function desaturate(color, amount)
    local gray = color[1] * 0.299 + color[2] * 0.587 + color[3] * 0.114
    return {
        lerp(color[1], gray, amount),
        lerp(color[2], gray, amount),
        lerp(color[3], gray, amount),
        1.0,
    }
end

---@param color number[] Source RGBA color.
---@param amount number|nil Warm-paper wash amount.
---@return number[] color Warmed opaque RGBA color.
local function warm_wash(color, amount)
    local t = amount or 0
    if t < 0 then t = 0 end
    if t > 1 then t = 1 end
    local muted = desaturate(color, 0.24)
    return color_mix(muted, { 0.90, 0.84, 0.72, 1.0 }, t)
end

---@param v number Value to clamp.
---@param lo number Minimum.
---@param hi number Maximum.
---@return number value Clamped value.
local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

---@param state table Campaign state.
---@param owner string Country tag.
---@return number[] color Diplomatic color for the owner relationship.
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

---@param province table Province record.
---@return number[] color Income-scaled color.
local function economy_color(province)
    if province.owner == "SEA" then
        return SEA_COLOR
    end
    local t = clamp((province.income or 0) / 10, 0, 1)
    return color_mix({ 0.54, 0.45, 0.28, 1.0 }, { 0.90, 0.76, 0.41, 1.0 }, t)
end

---@param province table Province record.
---@return number[] color Unrest-scaled color.
local function unrest_color(province)
    if province.owner == "SEA" then
        return SEA_COLOR
    end
    local t = clamp((province.unrest or 0) / 10, 0, 1)
    return color_mix({ 0.48, 0.62, 0.39, 1.0 }, { 0.86, 0.28, 0.24, 1.0 }, t)
end

---@param province table|nil Province record.
---@return number[] color Terrain color, or sea color for water.
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

---@param state table Campaign state.
---@param province table Province record.
---@return number[] color Washed country color.
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

---@param state table Campaign state.
---@param province table Province record.
---@param mode string|nil Map mode name.
---@return number[] color Mode-specific province color.
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

--- Return the public color for one province.
---@param state table Campaign state.
---@param province table|nil Province record.
---@param mode string|nil Map mode; defaults to `state.map_mode`.
---@return number[] color RGBA color.
function M.province_color(state, province, mode)
    if not province then
        return relation_color(state, "SEA")
    end
    return province_color(state, province, mode or state.map_mode or "political")
end

--- Apply country/sea border styles when ownership revision changes.
---@param reg userdata Province registry.
---@param state table Campaign state.
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
                    thickness = 2.0,
                    flags = {},
                })
            elseif a.owner ~= b.owner and not a_sea and not b_sea then
                reg:setBorderPairStyle(pair.province_a, pair.province_b, {
                    thickness = 3.0,
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

---@param color number[] RGBA color.
---@param factor number Brightness multiplier.
---@return number[] color Scaled clamped color.
local function scale_color(color, factor)
    return {
        clamp(color[1] * factor, 0, 1),
        clamp(color[2] * factor, 0, 1),
        clamp(color[3] * factor, 0, 1),
        color[4] or 1.0,
    }
end

-- GPU province highlights have a shared engine appearance. EU2 needs exact
-- fill changes, so prepare transient render-only tints from the active mode.
--- Build transient brightness tints for selected and hovered provinces.
---@param state table Campaign state.
---@param mode string Active map mode.
---@param hovered_id number|nil Hovered province id.
---@param selected_id number|nil Selected province id.
---@return table|nil tints Province-id to RGBA tint map, or nil when empty.
function M.highlight_tints(state, mode, hovered_id, selected_id)
    local tints = {}
    if selected_id and state.provinces[selected_id] then
        tints[selected_id] = scale_color(province_color(state, state.provinces[selected_id], mode), 0.9)
    end
    if hovered_id and hovered_id ~= selected_id and state.provinces[hovered_id] then
        tints[hovered_id] = scale_color(province_color(state, state.provinces[hovered_id], mode), 1.1)
    end
    return next(tints) and tints or nil
end

--- Map terrain names to renderer terrain-style ids.
---@param terrain any Terrain name.
---@return integer style Renderer style id.
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

--- Apply contested-province visual flags when style revision changes.
---@param reg userdata Province registry.
---@param state table Campaign state.
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

--- Apply renderer terrain ids when style revision changes.
---@param reg userdata Province registry.
---@param state table Campaign state.
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

--- Return the cache for a mode and invalidate it when its revision changes.
---@param state table Campaign state.
---@param mode string Map mode.
---@param revision_key string|nil Cache revision key.
---@return table colors Mutable mode color cache.
local function mode_cache(state, mode, revision_key)
    revision_key = revision_key or tostring(state.style_revision or 0)
    if state.mode_color_cache_revision ~= revision_key then
        state.mode_color_cache = {}
        state.mode_color_cache_revision = revision_key
    end
    state.mode_color_cache[mode] = state.mode_color_cache[mode] or {}
    return state.mode_color_cache[mode]
end

--- Update visibility based on terra incognita and water ownership.
---@param reg userdata Province registry.
---@param state table Campaign state.
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

--- Build the cache key for one mode's colors.
---@param state table Campaign state.
---@param mode string Map mode.
---@return string key Revision-aware cache key.
local function color_key(state, mode)
    return table.concat({
        mode,
        tostring(state.style_revision or 0),
        tostring(state.revision or 0),
    }, ":")
end

--- Compute and, when supported, upload all colors for a map mode.
---@param reg userdata Province registry.
---@param state table Campaign state.
---@param mode string Active map mode.
---@return nil|table colors Cached colors only when the registry cannot upload them.
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

--- Apply all renderer-facing state for a map mode.
---@param reg userdata Province registry.
---@param state table Campaign state.
---@param mode string Map mode name.
---@return string renderer_mode Always `political` for the GPU province renderer.
---@return table|nil tints Optional color data for callers that render manually.
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
