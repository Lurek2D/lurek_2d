-- @module library.awareness_minimap
--- @status full
--- Helper for syncing visibility masks into minimap fog and raw data layers.

local awareness_minimap = {}

local AwarenessMinimap = {}
AwarenessMinimap.__index = AwarenessMinimap

local function new_fallback_minimap(grid_w, grid_h, display_w, display_h)
    local mm = {
        _grid_w = grid_w,
        _grid_h = grid_h,
        _display_w = display_w or grid_w,
        _display_h = display_h or grid_h,
        _fog = {},
        _fog_enabled = false,
        _layers = {},
        _styles = {},
    }

    --- @local
    function mm:setFogData(data)
        local copy = {}
        for i = 1, #data do
            copy[i] = data[i]
        end
        self._fog = copy
    end

    --- @local
    function mm:getFogData()
        return self._fog
    end

    --- @local
    function mm:setFogEnabled(enabled)
        self._fog_enabled = enabled
    end

    --- @local
    function mm:isFogEnabled()
        return self._fog_enabled
    end

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

local function index_of(width, x, y)
    return (y - 1) * width + x
end

local function mark_cells(data, width, cells, value)
    for i = 1, #cells do
        local cell = cells[i]
        local x = cell.x
        local y = cell.y
        if x and y then
            data[index_of(width, x, y)] = value
        end
    end
end

local function full_grid(width, height, value)
    local data = {}
    for i = 1, width * height do
        data[i] = value
    end
    return data
end

--- Create a visibility->minimap sync helper.
--- @param opts table
--- @return table
function awareness_minimap.new(opts)
    opts = opts or {}

    local visibility = opts.visibility
    if not visibility then
        error("awareness_minimap.new requires opts.visibility")
    end

    local width = opts.width
    local height = opts.height
    if not width or not height then
        error("awareness_minimap.new requires opts.width and opts.height")
    end

    local self = setmetatable({}, AwarenessMinimap)
    self.visibility = visibility
    self.width = width
    self.height = height
    self.z = opts.z or 1
    self.minimap = opts.minimap or create_minimap(width, height, opts.display_w, opts.display_h)

    return self
end

--- Copy visible and explored tile visibility state into minimap fog data.
--- @param player string
--- @param opts table?
--- @return table
function AwarenessMinimap:syncFog(player, opts)
    opts = opts or {}
    local hidden_value = opts.hidden_value or 0
    local explored_value = opts.explored_value or 1
    local visible_value = opts.visible_value or 2
    local z = opts.z or self.z
    local data = full_grid(self.width, self.height, hidden_value)

    if opts.include_explored ~= false then
        for y = 1, self.height do
            for x = 1, self.width do
                if self.visibility:isExplored(player, x, y, z) then
                    data[index_of(self.width, x, y)] = explored_value
                end
            end
        end
    end

    mark_cells(data, self.width, self.visibility:visibleCells(player, z), visible_value)
    self.minimap:setFogData(data)
    if opts.enable ~= false and self.minimap.setFogEnabled then
        self.minimap:setFogEnabled(true)
    end
    return data
end

--- Copy current visible cells into a minimap raw data layer.
--- @param player string
--- @param layer integer
--- @param opts table?
--- @return table
function AwarenessMinimap:syncVisibleLayer(player, layer, opts)
    opts = opts or {}
    local hidden_value = opts.hidden_value or 0
    local visible_value = opts.visible_value or 1
    local z = opts.z or self.z
    local data = full_grid(self.width, self.height, hidden_value)
    mark_cells(data, self.width, self.visibility:visibleCells(player, z), visible_value)
    self.minimap:setLayerData(layer, data)
    apply_style(self.minimap, layer, opts.style)
    return data
end

--- Copy current actionable cells into a minimap raw data layer.
--- @param player string
--- @param layer integer
--- @param opts table?
--- @return table
function AwarenessMinimap:syncActionLayer(player, layer, opts)
    opts = opts or {}
    local hidden_value = opts.hidden_value or 0
    local action_value = opts.action_value or 1
    local z = opts.z or self.z
    local data = full_grid(self.width, self.height, hidden_value)
    mark_cells(data, self.width, self.visibility:actionCells(player, z), action_value)
    self.minimap:setLayerData(layer, data)
    apply_style(self.minimap, layer, opts.style)
    return data
end

--- Expose the underlying minimap handle.
--- @return table
function AwarenessMinimap:getMinimap()
    return self.minimap
end

return awareness_minimap
