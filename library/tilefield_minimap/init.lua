-- @module library.tilefield_minimap
--- @status full
--- Helper for syncing tilefield exported layers into minimap raw data layers.

local tilefield_minimap = {}

local TilefieldMinimap = {}
TilefieldMinimap.__index = TilefieldMinimap

local function clamp_byte(value)
    value = tonumber(value) or 0
    if value < 0 then
        return 0
    end
    if value > 255 then
        return 255
    end
    return math.floor(value + 0.5)
end

local function new_fallback_minimap(grid_w, grid_h, display_w, display_h)
    local mm = {
        _grid_w = grid_w,
        _grid_h = grid_h,
        _display_w = display_w or grid_w,
        _display_h = display_h or grid_h,
        _layers = {},
        _styles = {},
    }

    --- @local
    function mm:setLayerData(layer, data)
        local copy = {}
        for i = 1, #data do
            copy[i] = data[i]
        end
        self._layers[layer] = copy
    end

    --- @local
    function mm:getLayerData(layer)
        return self._layers[layer]
    end

    --- @local
    function mm:setLayerVisible(layer, visible)
        self._styles[layer] = self._styles[layer] or {}
        self._styles[layer].visible = visible
    end

    --- @local
    function mm:isLayerVisible(layer)
        return self._styles[layer] and self._styles[layer].visible or false
    end

    --- @local
    function mm:setLayerAlpha(layer, alpha)
        self._styles[layer] = self._styles[layer] or {}
        self._styles[layer].alpha = alpha
    end

    --- @local
    function mm:getLayerAlpha(layer)
        return self._styles[layer] and self._styles[layer].alpha
    end

    --- @local
    function mm:setLayerBlendMode(layer, mode)
        self._styles[layer] = self._styles[layer] or {}
        self._styles[layer].blend = mode
    end

    --- @local
    function mm:getLayerBlendMode(layer)
        return self._styles[layer] and self._styles[layer].blend
    end

    --- @local
    function mm:setLayerColor(layer, value, r, g, b, a)
        self._styles[layer] = self._styles[layer] or {}
        self._styles[layer].palette = self._styles[layer].palette or {}
        self._styles[layer].palette[value] = { r, g, b, a or 1.0 }
    end

    --- @local
    function mm:getLayerColor(layer, value)
        local color = self._styles[layer] and self._styles[layer].palette and self._styles[layer].palette[value]
        if not color then
            return nil, nil, nil, nil
        end
        return color[1], color[2], color[3], color[4]
    end

    return mm
end

local function create_minimap(grid_w, grid_h, display_w, display_h)
    if lurek and lurek.minimap and lurek.minimap.newMinimap then
        return lurek.minimap.newMinimap(grid_w, grid_h, display_w, display_h)
    end

    return new_fallback_minimap(grid_w, grid_h, display_w, display_h)
end

local function apply_style(minimap, layer, style)
    if not style then
        return
    end
    if style.visible ~= nil and minimap.setLayerVisible then
        minimap:setLayerVisible(layer, style.visible)
    end
    if style.alpha ~= nil and minimap.setLayerAlpha then
        minimap:setLayerAlpha(layer, style.alpha)
    end
    if style.blend ~= nil and minimap.setLayerBlendMode then
        minimap:setLayerBlendMode(layer, style.blend)
    end
    if style.colors and minimap.setLayerColor then
        for value, color in pairs(style.colors) do
            minimap:setLayerColor(layer, value, color[1], color[2], color[3], color[4])
        end
    end
end

--- Create a tilefield->minimap sync helper.
--- @param opts table
--- @return table
function tilefield_minimap.new(opts)
    opts = opts or {}

    local field = opts.field
    if not field then
        error("tilefield_minimap.new requires opts.field")
    end

    local width = opts.width
    local height = opts.height
    if not width or not height then
        error("tilefield_minimap.new requires opts.width and opts.height")
    end

    local self = setmetatable({}, TilefieldMinimap)
    self.field = field
    self.lightMap = opts.lightMap
    self.width = width
    self.height = height
    self.z = opts.z or 1
    self.minimap = opts.minimap or create_minimap(width, height, opts.display_w, opts.display_h)

    return self
end

--- Convert a tilefield boolean blocker layer into a minimap raw data layer.
--- @param channel string
--- @param layer integer
--- @param opts table?
--- @return table
function TilefieldMinimap:syncBlockLayer(channel, layer, opts)
    opts = opts or {}
    local blocked_value = opts.blocked_value or 1
    local open_value = opts.open_value or 0
    local source = self.field:exportBlockLayer(channel, opts.z or self.z)
    local data = {}
    for i = 1, #source do
        data[i] = source[i] and blocked_value or open_value
    end
    self.minimap:setLayerData(layer, data)
    apply_style(self.minimap, layer, opts.style)
    return data
end

--- Convert a tilefield numeric cost layer into a minimap raw data layer.
--- @param channel string
--- @param layer integer
--- @param opts table?
--- @return table
function TilefieldMinimap:syncCostLayer(channel, layer, opts)
    opts = opts or {}
    local scale = opts.scale or 1
    local source = self.field:exportCostLayer(channel, opts.z or self.z)
    local data = {}
    for i = 1, #source do
        data[i] = clamp_byte(source[i] * scale)
    end
    self.minimap:setLayerData(layer, data)
    apply_style(self.minimap, layer, opts.style)
    return data
end

--- Convert a tilelight computed layer into a minimap raw data layer.
--- @param layer integer
--- @param opts table?
--- @return table
function TilefieldMinimap:syncLightLayer(layer, opts)
    opts = opts or {}
    local channel = opts.channel or "luma"
    local scale = opts.scale or 9
    local light_map = opts.lightMap or self.lightMap
    if not light_map then
        error("TilefieldMinimap:syncLightLayer requires opts.lightMap or constructor opts.lightMap")
    end
    local source = light_map:exportLayer(opts.z or self.z)
    local data = {}
    for i = 1, #source do
        data[i] = clamp_byte((source[i][channel] or 0) * scale)
    end
    self.minimap:setLayerData(layer, data)
    apply_style(self.minimap, layer, opts.style)
    return data
end

--- Expose the underlying minimap handle.
--- @return table
function TilefieldMinimap:getMinimap()
    return self.minimap
end

return tilefield_minimap
