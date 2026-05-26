--- @module library.window_config
--- @status full
--- Fluent configuration builder for window setup and common window management
--- patterns. Wraps lurek.window.* API with chainable setters, preset configs,
--- and serialize/deserialize for settings persistence.
---
--- ## Engine integrations
---
--- @see lurek.window.setTitle
--- @see lurek.window.setSize
--- @see lurek.window.setResizable
--- @see lurek.window.setVsync
--- @see lurek.window.setFullscreen
--- @see lurek.window.setIcon
--- @see lurek.window.getSize

local window_config = {}

-- ── Optional logging ──────────────────────────────────────────────────────────

--- @local
local log_ok, _log = pcall(function()
    return lurek and lurek.log
end)
if not log_ok or not _log then
    _log = {
        debug = function() end,
        warn  = function() end,
    }
end

local function log_debug(msg)
    if _log and _log.debug then
        pcall(_log.debug, "[window_config] " .. msg)
    end
end

local function log_warn(msg)
    if _log and _log.warn then
        pcall(_log.warn, "[window_config] " .. msg)
    end
end

-- ── Engine bindings (safe for headless) ───────────────────────────────────────

local _win = (type(lurek) == "table") and lurek.window or nil
local _json = (type(lurek) == "table") and lurek.data or nil

-- ── WindowConfig class ────────────────────────────────────────────────────────

local WindowConfig = {}
WindowConfig.__index = WindowConfig

--- Create a new window configuration builder.
--- @treturn WindowConfig A new builder instance with sensible defaults.
function window_config.new()
    local self = setmetatable({}, WindowConfig)

    self._title         = "Lurek2D Game"
    self._width         = 1280
    self._height        = 720
    self._min_width     = nil
    self._min_height    = nil
    self._resizable     = true
    self._vsync         = true
    self._fullscreen    = false
    self._centered      = true
    self._icon_path     = nil
    self._scaling_mode  = "letterbox"
    self._game_width    = nil
    self._game_height   = nil

    return self
end

-- ── Fluent setters ────────────────────────────────────────────────────────────

--- Set the window title.
--- @tparam string t Window title string.
--- @treturn WindowConfig self for chaining.
function WindowConfig:title(t)
    self._title = t
    return self
end

--- Set the window size in pixels.
--- @tparam number w Width in pixels.
--- @tparam number h Height in pixels.
--- @treturn WindowConfig self for chaining.
function WindowConfig:size(w, h)
    self._width = w
    self._height = h
    return self
end

--- Set the minimum window size in pixels.
--- @tparam number w Minimum width in pixels.
--- @tparam number h Minimum height in pixels.
--- @treturn WindowConfig self for chaining.
function WindowConfig:minSize(w, h)
    self._min_width = w
    self._min_height = h
    return self
end

--- Set whether the window is resizable.
--- @tparam boolean flag True to allow resizing.
--- @treturn WindowConfig self for chaining.
function WindowConfig:resizable(flag)
    self._resizable = flag
    return self
end

--- Set whether vsync is enabled.
--- @tparam boolean flag True to enable vsync.
--- @treturn WindowConfig self for chaining.
function WindowConfig:vsync(flag)
    self._vsync = flag
    return self
end

--- Set fullscreen mode.
--- @tparam boolean flag True for fullscreen, false for windowed.
--- @treturn WindowConfig self for chaining.
function WindowConfig:fullscreen(flag)
    self._fullscreen = flag
    return self
end

--- Set whether the window should be centered on screen.
--- @tparam boolean flag True to center on creation.
--- @treturn WindowConfig self for chaining.
function WindowConfig:centered(flag)
    self._centered = flag
    return self
end

--- Set the window icon from an image file path.
--- @tparam string path Path to the icon image (PNG recommended).
--- @treturn WindowConfig self for chaining.
function WindowConfig:icon(path)
    self._icon_path = path
    return self
end

--- Set the scaling mode for rendering.
--- @tparam string mode One of "pixel_perfect", "stretch", or "letterbox".
--- @treturn WindowConfig self for chaining.
function WindowConfig:scalingMode(mode)
    local valid = { pixel_perfect = true, stretch = true, letterbox = true }
    if not valid[mode] then
        log_warn("unknown scaling mode: " .. tostring(mode) .. "; using letterbox")
        mode = "letterbox"
    end
    self._scaling_mode = mode
    return self
end

--- Set the internal game resolution (for pixel_perfect and letterbox modes).
--- @tparam number w Internal width in pixels.
--- @tparam number h Internal height in pixels.
--- @treturn WindowConfig self for chaining.
function WindowConfig:gameSize(w, h)
    self._game_width = w
    self._game_height = h
    return self
end

-- ── Apply ─────────────────────────────────────────────────────────────────────

--- Apply the configuration to the actual window via lurek.window.* calls.
--- Safe to call headlessly; will log warnings if the engine is unavailable.
function WindowConfig:apply()
    if not _win then
        log_warn("lurek.window not available; skipping apply")
        return
    end

    log_debug("applying window config: " .. self._title
              .. " (" .. self._width .. "x" .. self._height .. ")")

    if _win.setTitle then
        _win.setTitle(self._title)
    end

    if _win.setSize then
        _win.setSize(self._width, self._height)
    end

    if self._min_width and self._min_height and _win.setMinSize then
        _win.setMinSize(self._min_width, self._min_height)
    end

    if _win.setResizable then
        _win.setResizable(self._resizable)
    end

    if _win.setVsync then
        _win.setVsync(self._vsync)
    end

    if _win.setFullscreen then
        _win.setFullscreen(self._fullscreen)
    end

    if self._centered and _win.center then
        _win.center()
    end

    if self._icon_path and _win.setIcon then
        _win.setIcon(self._icon_path)
    end

    if _win.setScalingMode then
        _win.setScalingMode(self._scaling_mode)
    end

    if self._game_width and self._game_height and _win.setGameSize then
        _win.setGameSize(self._game_width, self._game_height)
    end
end

-- ── Presets ───────────────────────────────────────────────────────────────────

local PRESETS = {
    retro = function()
        return window_config.new()
            :title("Retro Game")
            :size(960, 720)
            :minSize(320, 240)
            :gameSize(320, 240)
            :scalingMode("pixel_perfect")
            :resizable(true)
            :vsync(true)
            :fullscreen(false)
            :centered(true)
    end,

    hd = function()
        return window_config.new()
            :title("HD Game")
            :size(1280, 720)
            :minSize(640, 360)
            :gameSize(1280, 720)
            :scalingMode("letterbox")
            :resizable(true)
            :vsync(true)
            :fullscreen(false)
            :centered(true)
    end,

    fullhd = function()
        return window_config.new()
            :title("Full HD Game")
            :size(1920, 1080)
            :minSize(960, 540)
            :gameSize(1920, 1080)
            :scalingMode("stretch")
            :resizable(true)
            :vsync(true)
            :fullscreen(false)
            :centered(true)
    end,
}

--- Create a WindowConfig from a named preset.
--- @tparam string name Preset name: "retro", "hd", or "fullhd".
--- @treturn WindowConfig A pre-filled builder that can be further customized.
function window_config.preset(name)
    local factory = PRESETS[name]
    if not factory then
        log_warn("unknown preset: " .. tostring(name) .. "; falling back to hd")
        factory = PRESETS.hd
    end
    return factory()
end

-- ── Runtime helpers ───────────────────────────────────────────────────────────

--- Toggle fullscreen mode on the live window.
function WindowConfig:toggleFullscreen()
    self._fullscreen = not self._fullscreen
    if _win and _win.setFullscreen then
        _win.setFullscreen(self._fullscreen)
        log_debug("fullscreen toggled to " .. tostring(self._fullscreen))
    end
end

--- Get the actual current window size from the engine.
--- @treturn number width Current window width, or configured width if headless.
--- @treturn number height Current window height, or configured height if headless.
function WindowConfig:getActualSize()
    if _win and _win.getSize then
        return _win.getSize()
    end
    return self._width, self._height
end

--- Get the current scale factor (actual size / game size).
--- @treturn number scale Scale multiplier (1.0 if game size is not set).
function WindowConfig:getScaleFactor()
    if not self._game_width or not self._game_height then
        return 1.0
    end
    local w, h = self:getActualSize()
    local sx = w / self._game_width
    local sy = h / self._game_height
    if self._scaling_mode == "pixel_perfect" then
        return math.floor(math.min(sx, sy))
    elseif self._scaling_mode == "letterbox" then
        return math.min(sx, sy)
    else -- stretch
        return sx  -- non-uniform; return horizontal scale
    end
end

-- ── Serialization ─────────────────────────────────────────────────────────────

--- Serialize the configuration to a plain table for persistence.
--- @treturn table A table containing all configuration fields.
function WindowConfig:serialize()
    return {
        title        = self._title,
        width        = self._width,
        height       = self._height,
        min_width    = self._min_width,
        min_height   = self._min_height,
        resizable    = self._resizable,
        vsync        = self._vsync,
        fullscreen   = self._fullscreen,
        centered     = self._centered,
        icon_path    = self._icon_path,
        scaling_mode = self._scaling_mode,
        game_width   = self._game_width,
        game_height  = self._game_height,
    }
end

--- Restore configuration from a previously serialized table.
--- @tparam table data Table produced by serialize().
--- @treturn WindowConfig self for chaining.
function WindowConfig:deserialize(data)
    if type(data) ~= "table" then
        log_warn("deserialize: expected table, got " .. type(data))
        return self
    end

    if data.title        then self._title        = data.title end
    if data.width        then self._width        = data.width end
    if data.height       then self._height       = data.height end
    if data.min_width    then self._min_width    = data.min_width end
    if data.min_height   then self._min_height   = data.min_height end
    if data.resizable ~= nil then self._resizable = data.resizable end
    if data.vsync ~= nil     then self._vsync     = data.vsync end
    if data.fullscreen ~= nil then self._fullscreen = data.fullscreen end
    if data.centered ~= nil   then self._centered   = data.centered end
    if data.icon_path    then self._icon_path    = data.icon_path end
    if data.scaling_mode then self._scaling_mode = data.scaling_mode end
    if data.game_width   then self._game_width   = data.game_width end
    if data.game_height  then self._game_height  = data.game_height end

    return self
end

--- Serialize configuration to a JSON string.
--- Uses lurek.data.toJson if available; otherwise falls back to a simple encoder.
--- @treturn string JSON representation of the configuration.
function WindowConfig:toJson()
    local data = self:serialize()

    if _json and _json.toJson then
        return _json.toJson(data)
    end

    -- Minimal fallback JSON encoder for headless environments
    local parts = {}
    for k, v in pairs(data) do
        local val
        if type(v) == "string" then
            val = '"' .. v:gsub('"', '\\"') .. '"'
        elseif type(v) == "boolean" then
            val = tostring(v)
        elseif type(v) == "number" then
            val = tostring(v)
        else
            val = "null"
        end
        parts[#parts + 1] = '"' .. k .. '":' .. val
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

--- Create a WindowConfig from a JSON string.
--- @tparam string json_str JSON string produced by toJson().
--- @treturn WindowConfig A new builder populated from the JSON data.
function window_config.fromJson(json_str)
    local data

    if _json and _json.fromJson then
        data = _json.fromJson(json_str)
    else
        -- Minimal fallback JSON decoder for headless environments
        -- Handles flat objects with string, number, boolean, null values
        data = {}
        for k, v in json_str:gmatch('"([^"]+)"%s*:%s*([^,}]+)') do
            v = v:match("^%s*(.-)%s*$")  -- trim
            if v == "true" then
                data[k] = true
            elseif v == "false" then
                data[k] = false
            elseif v == "null" then
                data[k] = nil
            elseif v:sub(1, 1) == '"' then
                data[k] = v:sub(2, -2):gsub('\\"', '"')
            else
                data[k] = tonumber(v)
            end
        end
    end

    local cfg = window_config.new()
    if data then
        cfg:deserialize(data)
    end
    return cfg
end

return window_config
