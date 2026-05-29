-- content/examples/tools/visibility_fov_stealth.lua
--
-- Demonstrates: lurek.visibility.newFov — stealth NPC patrol pattern.
--
-- A guard patrols along a fixed path on a tile grid.
-- The player is hidden inside its FOV cone and must not enter the guard's
-- visible area to avoid detection.
-- The FOV is recomputed every frame as the guard moves.
--
-- Expected output: green tiles = explored, yellow = visible this frame,
-- red flash = player detected.
-- Run with: lurek content/examples/tools/visibility_fov_stealth.lua

local W, H   = 30, 20
local TILE   = 24
local RANGE  = 7

-- Wall layout (true = solid)
local walls = {}
for y = 1, H do
    walls[y] = {}
    for x = 1, W do
        -- Border walls
        walls[y][x] = (x == 1 or x == W or y == 1 or y == H)
            -- Room walls
            or (x == 10 and y >= 5 and y <= 14)
            or (x == 20 and y >= 7 and y <= 16)
    end
end

local function is_wall(x, y)
    if x < 1 or y < 1 or x > W or y > H then return true end
    return walls[y][x]
end

-- FOV — dimensions must match map
local fov = lurek.visibility.newFov({
    width  = W,
    height = H,
    range  = RANGE,
    light_walls = true,
})
fov:setBlocker(is_wall)

-- Guard patrol waypoints
local patrol = { {5,5},{5,15},{25,15},{25,5} }
local guard = { x=5, y=5, wx=5.0, wy=5.0, wp=1, speed=4.0, facing_x=1, facing_y=0 }

-- Player
local player = { x=15, y=10 }
local detected = false
local detect_timer = 0.0

local function move_guard(dt)
    local target = patrol[guard.wp]
    local dx = target[1] - guard.wx
    local dy = target[2] - guard.wy
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist < 0.1 then
        guard.wp = guard.wp % #patrol + 1
        return
    end
    guard.facing_x = dx / dist
    guard.facing_y = dy / dist
    guard.wx = guard.wx + (dx/dist) * guard.speed * dt
    guard.wy = guard.wy + (dy/dist) * guard.speed * dt
    guard.x = math.floor(guard.wx + 0.5)
    guard.y = math.floor(guard.wy + 0.5)
end

local function color_for_tile(x, y)
    if is_wall(x, y) then
        return { r=0.3, g=0.3, b=0.3, a=1 }
    end
    if fov:isVisible(x, y) then
        return { r=0.9, g=0.9, b=0.4, a=0.6 }
    end
    if fov:isExplored(x, y) then
        return { r=0.2, g=0.5, b=0.2, a=0.5 }
    end
    return { r=0.05, g=0.05, b=0.05, a=1 }
end

lurek.process(function(dt)
    -- Move player
    if lurek.input.keyboard.isDown("right") then player.x = math.min(player.x+1, W-1) end
    if lurek.input.keyboard.isDown("left")  then player.x = math.max(player.x-1, 2)   end
    if lurek.input.keyboard.isDown("down")  then player.y = math.min(player.y+1, H-1) end
    if lurek.input.keyboard.isDown("up")    then player.y = math.max(player.y-1, 2)   end

    move_guard(dt)

    -- Recompute FOV from guard position
    fov:compute(guard.x, guard.y)

    -- Detection check
    if fov:isVisible(player.x, player.y) then
        detected = true
        detect_timer = 1.5
    end
    if detect_timer > 0 then
        detect_timer = detect_timer - dt
        if detect_timer <= 0 then detected = false end
    end

    -- Render tiles
    lurek.render.setBackgroundColor(0.05, 0.05, 0.08)
    lurek.render.clear()
    for y = 1, H do
        for x = 1, W do
            local c = color_for_tile(x, y)
            lurek.render.setColor(c.r, c.g, c.b, c.a)
            lurek.render.rectangle("fill", (x-1)*TILE, (y-1)*TILE, TILE, TILE)
        end
    end

    -- Draw player
    local pc = detected and {r=1,g=0,b=0,a=1} or {r=0.2,g=0.8,b=1,a=1}
    lurek.render.setColor(pc.r, pc.g, pc.b, pc.a)
    lurek.render.circle("fill", (player.x-1)*TILE+TILE/2, (player.y-1)*TILE+TILE/2, TILE/2-3)

    -- Draw guard
    lurek.render.setColor(1, 0.5, 0, 1)
    lurek.render.circle("fill", (guard.x-1)*TILE+TILE/2, (guard.y-1)*TILE+TILE/2, TILE/2-2)

    -- HUD
    local msg = detected and "! DETECTED !" or "Stay out of the light"
    local hc  = detected and {r=1,g=0.2,b=0.2,a=1} or {r=0.8,g=0.8,b=0.8,a=1}
    lurek.render.setColor(hc.r, hc.g, hc.b, hc.a)
    lurek.render.print(msg, 4, 4)
    lurek.render.setColor(0.5, 0.5, 0.5, 1)
    lurek.render.print("Arrows to move  |  Guard range: " .. RANGE, 4, 20)
end)
