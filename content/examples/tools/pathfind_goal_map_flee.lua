-- content/examples/tools/pathfind_goal_map_flee.lua
--
-- Demonstrates: lurek.pathfind.newGoalMap — flee AI pattern.
--
-- A player wanders the map. Four NPC guards each use a GoalMap baked around
-- the player position to move away when the player comes within 5 cells.
-- The GoalMap is rebaked whenever the player moves to a new cell.
--
-- Expected output (visual): guards scatter outward from the player.
-- Run with: lurek content/examples/tools/pathfind_goal_map_flee.lua

local W, H = 30, 20
local TILE = 24

-- Simple open map (no walls for this demo)
local gm = lurek.pathfind.newGoalMap(W, H)
gm:setBlocker(function(_, _) return false end)

-- Player starts at centre
local player = { x = 15.5, y = 10.5, cx = 15, cy = 10 }

-- Guards start at various positions
local guards = {
    { x =  4.5, y =  4.5 },
    { x = 25.5, y =  4.5 },
    { x =  4.5, y = 15.5 },
    { x = 25.5, y = 15.5 },
}

gm:clearSources()
gm:addSource(player.cx, player.cy)
gm:bake()

lurek.process(function(dt)
    -- Move player with arrow keys
    local moved = false
    if lurek.input.keyboard.isDown("right") then player.x = math.min(player.x + 5 * dt, W) moved = true end
    if lurek.input.keyboard.isDown("left")  then player.x = math.max(player.x - 5 * dt, 1) moved = true end
    if lurek.input.keyboard.isDown("down")  then player.y = math.min(player.y + 5 * dt, H) moved = true end
    if lurek.input.keyboard.isDown("up")    then player.y = math.max(player.y - 5 * dt, 1) moved = true end

    -- Rebake when player moves to a new cell
    local ncx = math.floor(player.x)
    local ncy = math.floor(player.y)
    if ncx ~= player.cx or ncy ~= player.cy then
        player.cx = ncx
        player.cy = ncy
        gm:clearSources()
        gm:addSource(player.cx, player.cy)
        gm:bake()
    end

    -- Update guards: flee when close, idle otherwise
    for _, g in ipairs(guards) do
        local gx = math.floor(g.x)
        local gy = math.floor(g.y)
        local d = gm:distanceAt(math.max(1, math.min(W, gx)),
                                 math.max(1, math.min(H, gy)))
        if d < 6 then
            local dx, dy = gm:flee(gx, gy, 1.0)
            g.x = math.max(1, math.min(W, g.x + dx * 4 * dt))
            g.y = math.max(1, math.min(H, g.y + dy * 4 * dt))
        end
    end

    -- Render
    lurek.render.setBackgroundColor(0.05, 0.05, 0.1)
    lurek.render.clear()

    for y = 1, H do
        for x = 1, W do
            local d = gm:distanceAt(x, y)
            local t = math.min(d, 10)
            local shade = math.floor(255 * (1 - t / 10))
            lurek.render.setColor(shade / 255, 0, (255 - shade) / 255, 0.25)
            lurek.render.rectangle("fill", (x - 1) * TILE, (y - 1) * TILE, TILE, TILE)
        end
    end

    lurek.render.setColor(1, 1, 0, 1)
    lurek.render.circle("fill",
        (player.x - 1) * TILE + TILE / 2,
        (player.y - 1) * TILE + TILE / 2,
        TILE / 2 - 2
    )

    for _, g in ipairs(guards) do
        lurek.render.setColor(1, 0.2, 0.2, 1)
        lurek.render.circle("fill",
            (g.x - 1) * TILE + TILE / 2,
            (g.y - 1) * TILE + TILE / 2,
            TILE / 2 - 4
        )
    end

    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print(string.format("Player: (%d,%d)  Arrows to move", player.cx, player.cy), 4, 4)
end)
