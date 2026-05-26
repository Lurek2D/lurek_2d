--- Example usage for library.camera_follow.
-- Demonstrates smooth camera follow with deadzone, lookahead, bounds,
-- screen shake, zoom control, and cutscene override.
-- @module example.camera_follow

local CameraFollow = require("library.camera_follow")

-- ── 1. Create a camera follow controller ──────────────────────────────────────
local cam = CameraFollow.new({
    smoothing = 5.0,
    deadzone  = { x = 50, y = 30 },
    offset    = { x = 0, y = -20 },
    lookahead = { x = 40, y = 0 },
    bounds    = { minX = 0, minY = 0, maxX = 3200, maxY = 1800 },
    zoom      = 1.0,
})

-- ── 2. Simulate a player moving right ────────────────────────────────────────
local player = { x = 400, y = 300 }
cam:setTarget(player.x, player.y)
cam:update(0.016)  -- first frame snaps

local cx, cy = cam:getPosition()
print(string.format("[camera_follow] initial pos: %.1f, %.1f", cx, cy))

-- Move player over several frames
for i = 1, 10 do
    player.x = player.x + 5
    player.y = player.y + 2
    cam:setTarget(player.x, player.y)
    cam:update(0.016)
end

cx, cy = cam:getPosition()
print(string.format("[camera_follow] after movement: %.1f, %.1f", cx, cy))

-- ── 3. Snap camera to target immediately ──────────────────────────────────────
player.x = 1600
player.y = 900
cam:setTarget(player.x, player.y)
cam:snap()

cx, cy = cam:getPosition()
print(string.format("[camera_follow] after snap: %.1f, %.1f", cx, cy))

-- ── 4. Screen shake ───────────────────────────────────────────────────────────
cam:shake(8, 0.3)
cam:update(0.016)
cx, cy = cam:getPosition()
print(string.format("[camera_follow] during shake: %.1f, %.1f (offset varies)", cx, cy))

-- Let shake expire
for i = 1, 30 do
    cam:update(0.016)
end
cx, cy = cam:getPosition()
print(string.format("[camera_follow] shake expired: %.1f, %.1f", cx, cy))

-- ── 5. Zoom ───────────────────────────────────────────────────────────────────
cam:setZoom(2.0)
print(string.format("[camera_follow] zoom: %.1f", cam:getZoom()))
cam:setZoom(1.0)

-- ── 6. Cutscene override ──────────────────────────────────────────────────────
cam:override(2400, 1200, 1.0)  -- pan to a point over 1 second

-- Simulate time passing during override
for i = 1, 60 do
    cam:update(0.016)
end
cx, cy = cam:getPosition()
print(string.format("[camera_follow] during override: %.1f, %.1f", cx, cy))

-- Complete the override
for i = 1, 10 do
    cam:update(0.016)
end
cx, cy = cam:getPosition()
print(string.format("[camera_follow] override done: %.1f, %.1f", cx, cy))

cam:clearOverride()

-- ── 7. Bounds clamping ────────────────────────────────────────────────────────
cam:setTarget(5000, 5000)  -- way outside bounds
cam:snap()
cx, cy = cam:getPosition()
print(string.format("[camera_follow] clamped to bounds: %.1f, %.1f", cx, cy))

-- ── 8. Change bounds at runtime ───────────────────────────────────────────────
cam:setBounds(0, 0, 6400, 3600)
local bounds = cam:getBounds()
print(string.format("[camera_follow] new bounds: %d,%d to %d,%d",
    bounds.minX, bounds.minY, bounds.maxX, bounds.maxY))

-- ── 9. Apply to lurek camera (no-op in headless) ──────────────────────────────
cam:apply()
print("[camera_follow] apply() called (sets lurek.camera position + zoom)")
