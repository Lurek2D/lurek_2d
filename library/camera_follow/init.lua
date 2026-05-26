-- @module library.camera_follow
--- @status full
--- Configurable camera follow behaviors for 2D games: smooth follow, deadzone,
--- lookahead, world bounds clamping, screen shake, and cutscene override.
--- Wraps lurek.camera.setPosition / lurek.camera.setZoom internally.
---
--- ## Engine integrations
---
--- @see lurek.camera.setPosition
--- @see lurek.camera.setZoom
--- @see lurek.math.clamp

local M = {}

-- Cache engine helpers when available; fall back to local impls for headless
-- test VMs that don't load the engine.
local _cam = (type(lurek) == 'table') and lurek.camera or nil

local function clamp(v, lo, hi)
    if lo and v < lo then return lo end
    if hi and v > hi then return hi end
    return v
end

--- Log a debug message if lurek.log is available.
local function log_debug(msg)
    local ok, _ = pcall(function()
        if lurek and lurek.log and lurek.log.debug then
            lurek.log.debug("[camera_follow] " .. msg)
        end
    end)
    -- Silently ignore if lurek.log is not present.
    local _ = ok
end

-- ── CameraFollow ──────────────────────────────────────────────────────────────

local CameraFollow = {}
CameraFollow.__index = CameraFollow

--- Create a new camera follow controller.
--- @tparam table opts Configuration table.
--- @tparam[opt=5.0] number opts.smoothing Lerp speed (higher = snappier).
--- @tparam[opt={x=0,y=0}] table opts.deadzone Deadzone in pixels {x, y}.
--- @tparam[opt={x=0,y=0}] table opts.offset Static offset from target {x, y}.
--- @tparam[opt={x=0,y=0}] table opts.lookahead Lookahead in movement dir {x, y}.
--- @tparam[opt=nil] table opts.bounds World bounds {minX, minY, maxX, maxY}.
--- @tparam[opt=1.0] number opts.zoom Initial zoom level.
--- @treturn CameraFollow
function M.new(opts)
    opts = opts or {}
    local self = setmetatable({}, CameraFollow)

    -- Config
    self._smoothing = opts.smoothing or 5.0
    self._deadzone  = { x = (opts.deadzone and opts.deadzone.x) or 0,
                        y = (opts.deadzone and opts.deadzone.y) or 0 }
    self._offset    = { x = (opts.offset and opts.offset.x) or 0,
                        y = (opts.offset and opts.offset.y) or 0 }
    self._lookahead = { x = (opts.lookahead and opts.lookahead.x) or 0,
                        y = (opts.lookahead and opts.lookahead.y) or 0 }
    self._bounds    = opts.bounds  -- nil means unbounded
    self._zoom      = opts.zoom or 1.0

    -- State
    self._posX = 0
    self._posY = 0
    self._targetX = 0
    self._targetY = 0
    self._prevTargetX = 0
    self._prevTargetY = 0
    self._velocityX = 0
    self._velocityY = 0
    self._first_frame = true

    -- Shake state
    self._shake_intensity = 0
    self._shake_duration  = 0
    self._shake_elapsed   = 0
    self._shake_ox = 0
    self._shake_oy = 0

    -- Override state (cutscene)
    self._override        = false
    self._override_x      = 0
    self._override_y      = 0
    self._override_dur    = 0
    self._override_elapsed = 0
    self._override_startX = 0
    self._override_startY = 0

    log_debug("created with smoothing=" .. tostring(self._smoothing))
    return self
end

--- Set the target position the camera should follow.
--- @tparam number x Target X in world coordinates.
--- @tparam number y Target Y in world coordinates.
function CameraFollow:setTarget(x, y)
    self._prevTargetX = self._targetX
    self._prevTargetY = self._targetY
    self._targetX = x
    self._targetY = y
end

--- Update the camera position. Call once per frame.
--- @tparam number dt Delta time in seconds.
function CameraFollow:update(dt)
    if dt <= 0 then return end

    -- Compute target velocity for lookahead
    self._velocityX = (self._targetX - self._prevTargetX) / dt
    self._velocityY = (self._targetY - self._prevTargetY) / dt

    -- Effective target = target + offset + lookahead
    local look_x = 0
    local look_y = 0
    if self._lookahead.x ~= 0 or self._lookahead.y ~= 0 then
        -- Normalize velocity direction
        local vlen = math.sqrt(self._velocityX * self._velocityX + self._velocityY * self._velocityY)
        if vlen > 0.001 then
            look_x = (self._velocityX / vlen) * self._lookahead.x
            look_y = (self._velocityY / vlen) * self._lookahead.y
        end
    end

    local goal_x = self._targetX + self._offset.x + look_x
    local goal_y = self._targetY + self._offset.y + look_y

    -- Handle override (cutscene)
    if self._override then
        self._override_elapsed = self._override_elapsed + dt
        if self._override_elapsed >= self._override_dur then
            self._posX = self._override_x
            self._posY = self._override_y
        else
            local t = self._override_elapsed / self._override_dur
            -- Smooth step
            t = t * t * (3 - 2 * t)
            self._posX = self._override_startX + (self._override_x - self._override_startX) * t
            self._posY = self._override_startY + (self._override_y - self._override_startY) * t
        end
    else
        -- Deadzone check
        local dx = goal_x - self._posX
        local dy = goal_y - self._posY

        local move_x = dx
        local move_y = dy

        if self._deadzone.x > 0 then
            if math.abs(dx) < self._deadzone.x then
                move_x = 0
            else
                move_x = dx - self._deadzone.x * (dx > 0 and 1 or -1)
            end
        end

        if self._deadzone.y > 0 then
            if math.abs(dy) < self._deadzone.y then
                move_y = 0
            else
                move_y = dy - self._deadzone.y * (dy > 0 and 1 or -1)
            end
        end

        -- Snap on first frame to avoid lerping from origin
        if self._first_frame then
            self._posX = goal_x
            self._posY = goal_y
            self._first_frame = false
        else
            -- Exponential smoothing (frame-rate independent)
            local factor = 1 - math.exp(-self._smoothing * dt)
            self._posX = self._posX + move_x * factor
            self._posY = self._posY + move_y * factor
        end
    end

    -- Clamp to bounds
    if self._bounds then
        self._posX = clamp(self._posX, self._bounds.minX, self._bounds.maxX)
        self._posY = clamp(self._posY, self._bounds.minY, self._bounds.maxY)
    end

    -- Update shake
    self._shake_ox = 0
    self._shake_oy = 0
    if self._shake_duration > 0 then
        self._shake_elapsed = self._shake_elapsed + dt
        if self._shake_elapsed >= self._shake_duration then
            self._shake_duration = 0
            self._shake_intensity = 0
            self._shake_elapsed = 0
        else
            local remaining = 1 - (self._shake_elapsed / self._shake_duration)
            local intensity = self._shake_intensity * remaining
            self._shake_ox = (math.random() * 2 - 1) * intensity
            self._shake_oy = (math.random() * 2 - 1) * intensity
        end
    end
end

--- Get the current camera position (including shake offset).
--- @treturn number x
--- @treturn number y
function CameraFollow:getPosition()
    return self._posX + self._shake_ox, self._posY + self._shake_oy
end

--- Apply the camera position and zoom to lurek.camera.
--- Calls lurek.camera.setPosition and lurek.camera.setZoom.
function CameraFollow:apply()
    local x, y = self:getPosition()
    if _cam and _cam.setPosition then
        _cam.setPosition(x, y)
    end
    if _cam and _cam.setZoom then
        _cam.setZoom(self._zoom)
    end
end

--- Start a screen shake effect.
--- @tparam number intensity Maximum pixel displacement.
--- @tparam number duration Duration in seconds.
function CameraFollow:shake(intensity, duration)
    self._shake_intensity = intensity or 8
    self._shake_duration  = duration or 0.3
    self._shake_elapsed   = 0
    log_debug("shake intensity=" .. tostring(intensity) .. " duration=" .. tostring(duration))
end

--- Set the zoom level.
--- @tparam number z Zoom factor (1.0 = default).
function CameraFollow:setZoom(z)
    self._zoom = z
end

--- Get the current zoom level.
--- @treturn number zoom
function CameraFollow:getZoom()
    return self._zoom
end

--- Snap the camera immediately to the current target (no smoothing).
function CameraFollow:snap()
    self._posX = self._targetX + self._offset.x
    self._posY = self._targetY + self._offset.y
    if self._bounds then
        self._posX = clamp(self._posX, self._bounds.minX, self._bounds.maxX)
        self._posY = clamp(self._posY, self._bounds.minY, self._bounds.maxY)
    end
    self._first_frame = false
end

--- Override the camera to a fixed point over a duration (cutscene).
--- @tparam number x Target X.
--- @tparam number y Target Y.
--- @tparam number duration Transition time in seconds.
function CameraFollow:override(x, y, duration)
    self._override = true
    self._override_x = x
    self._override_y = y
    self._override_dur = duration or 1.0
    self._override_elapsed = 0
    self._override_startX = self._posX
    self._override_startY = self._posY
    log_debug("override to " .. tostring(x) .. "," .. tostring(y))
end

--- Clear the cutscene override and resume following the target.
function CameraFollow:clearOverride()
    self._override = false
end

--- Get the current world bounds.
--- @treturn table|nil bounds {minX, minY, maxX, maxY} or nil if unbounded.
function CameraFollow:getBounds()
    return self._bounds
end

--- Set new world bounds.
--- @tparam number minX
--- @tparam number minY
--- @tparam number maxX
--- @tparam number maxY
function CameraFollow:setBounds(minX, minY, maxX, maxY)
    self._bounds = { minX = minX, minY = minY, maxX = maxX, maxY = maxY }
end

return M
