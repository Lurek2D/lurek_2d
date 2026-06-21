--- Visibility (Fog-of-War) Example
--- Demonstrates the universal visibility system.

-- Create a visibility grid for 100 regions, 4 players
--@api: lurek.visibility.new
do
    local vg = lurek.visibility.new({ regions = 20 * 15, players = 4 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local first_state = vg:getState(0, 0)
    lurek.log.info("visibility grid created for dungeon floor")
    lurek.log.info("regions=" .. regions .. " players=" .. players .. " state=" .. first_state)
end

--@api: LVisibilityGrid:reveal
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 5, 3)
    local state = vg:getState(0, 5)
    local fog = vg:getFogIntensity(0, 5)
    local events = vg:drainEvents()
    lurek.log.info("revealed corridor region 5 for player 0")
    lurek.log.info("state=" .. state .. " fog=" .. fog .. " events=" .. #events)
end

--@api: LVisibilityGrid:hide
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:revealAll(0)
    vg:hide(0, 3)
    local state = vg:getState(0, 3)
    local fog = vg:getFogIntensity(0, 3)
    local still_visible = state == "visible"
    lurek.log.info("hiding room 3 after player leaves vision")
    lurek.log.info("state=" .. state .. " fog=" .. fog .. " visible=" .. tostring(still_visible))
end

--@api: LVisibilityGrid:getState
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(1, 42, 2)
    local player_state = vg:getState(1, 42)
    local other_state = vg:getState(0, 42)
    local fog = vg:getFogIntensity(1, 42)
    lurek.log.info("scout player state at region 42 = " .. player_state)
    lurek.log.info("other player sees " .. other_state .. " with fog=" .. fog)
end

--@api: LVisibilityGrid:getFogIntensity
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 0)
    vg:hide(0, 0)
    local fog = vg:getFogIntensity(0, 0)
    local state = vg:getState(0, 0)
    local hidden_fog = vg:getFogIntensity(1, 0)
    lurek.log.info("fog for discovered room = " .. fog)
    lurek.log.info("state=" .. state .. " hidden-player fog=" .. hidden_fog)
end

--@api: LVisibilityGrid:setCost
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(5, 2.0)
    vg:setCost(6, 4.5)
    local room_cost = vg:getCost(5)
    local boss_cost = vg:getCost(6)
    lurek.log.info("pathing cost for room 5 = " .. room_cost)
    lurek.log.info("boss wing cost = " .. boss_cost)
end

--@api: LVisibilityGrid:getCost
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(7, 3.5)
    vg:setCost(8, 1.0)
    local trapped = vg:getCost(7)
    local hallway = vg:getCost(8)
    lurek.log.info("trapped room cost = " .. trapped)
    lurek.log.info("hallway cost = " .. hallway)
end

--@api: LVisibilityGrid:setFlag
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(8, 6, true)
    local has_secret = vg:hasFlag(8, 6)
    vg:setFlag(8, 1, true)
    local has_loot = vg:hasFlag(8, 1)
    lurek.log.info("secret-door flag set = " .. tostring(has_secret))
    lurek.log.info("loot flag set = " .. tostring(has_loot))
end

--@api: LVisibilityGrid:hasFlag
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(4, 4, true)
    local trap = vg:hasFlag(4, 4)
    local beacon = vg:hasFlag(4, 7)
    local region = 4
    lurek.log.info("region " .. region .. " trap flag = " .. tostring(trap))
    lurek.log.info("region " .. region .. " beacon flag = " .. tostring(beacon))
end

--@api: LVisibilityGrid:setGroup
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local groupId = vg:setGroup({ 0, 1 })
    local shared = vg:sharesVisibility(0, 1)
    local not_shared = vg:sharesVisibility(0, 2)
    lurek.log.info("alliance group id = " .. groupId)
    lurek.log.info("0<->1 shared=" .. tostring(shared) .. " 0<->2 shared=" .. tostring(not_shared))
end

--@api: LVisibilityGrid:sharesVisibility
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setGroup({ 1, 2 })
    local shared = vg:sharesVisibility(1, 2)
    local enemy_shared = vg:sharesVisibility(1, 3)
    vg:reveal(1, 20)
    local ally_state = vg:getState(2, 20)
    lurek.log.info("allied scouts share vision = " .. tostring(shared))
    lurek.log.info("enemy shared=" .. tostring(enemy_shared) .. " ally sees " .. ally_state)
end

--@api: LVisibilityGrid:revealAll
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    local region_state = vg:getState(0, 5)
    local last_state = vg:getState(0, 99)
    local fog = vg:getFogIntensity(0, 99)
    lurek.log.info("debug reveal all enabled for player 0")
    lurek.log.info("region5=" .. region_state .. " region99=" .. last_state .. " fog=" .. fog)
end

--@api: LVisibilityGrid:reset
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    vg:reset(0)
    local region_state = vg:getState(0, 5)
    local fog = vg:getFogIntensity(0, 5)
    local hidden = region_state == "hidden"
    lurek.log.info("reset visibility for player 0")
    lurek.log.info("state=" .. region_state .. " fog=" .. fog .. " hidden=" .. tostring(hidden))
end

--@api: LVisibilityGrid:drainEvents
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:reveal(0, 3, 2)
    local events = vg:drainEvents()
    local drained_again = vg:drainEvents()
    local first = events[1]
    lurek.log.info("visibility events drained = " .. #events)
    lurek.log.info("first event exists=" .. tostring(first ~= nil) .. " second drain=" .. #drained_again)
end

--@api: LVisibilityGrid:regionCount
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local last_state = vg:getState(0, regions - 1)
    lurek.log.info("region count = " .. regions)
    lurek.log.info("players=" .. players .. " last region state=" .. last_state)
end

--@api: LVisibilityGrid:playerCount
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:setGroup({ 0, 1 })
    local players = vg:playerCount()
    local shared = vg:sharesVisibility(0, 1)
    local regions = vg:regionCount()
    lurek.log.info("player count = " .. players)
    lurek.log.info("shared party vision=" .. tostring(shared) .. " across " .. regions .. " regions")
end

--@api: lurek.visibility.newFov
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    local type_name = fov:type()
    fov:compute(10, 10)
    local visible_origin = fov:isVisible(10, 10)
    lurek.log.info("new FOV handle type = " .. type_name)
    lurek.log.info("origin visible after compute = " .. tostring(visible_origin))
end

--@api: LFov:setBlocker
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:setBlocker(function(x, y)
        return x == 10 and y >= 6 and y <= 14
    end)
    fov:compute(5, 10)
    lurek.log.info("LFov:setBlocker visible_12_10=" .. tostring(fov:isVisible(12, 10)))
end

--@api: LFov:setRange
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 4 })
    fov:setRange(10)
    fov:compute(10, 10)
    local far_visible = fov:isVisible(18, 10)
    local near_visible = fov:isVisible(14, 10)
    local explored = fov:isExplored(18, 10)
    lurek.log.info("range extended to 10 tiles")
    lurek.log.info("far=" .. tostring(far_visible) .. " near=" .. tostring(near_visible) .. " explored=" .. tostring(explored))
end

--@api: LFov:compute
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    local origin = fov:isVisible(10, 10)
    local east = fov:isVisible(12, 10)
    local cells = fov:visibleCells()
    lurek.log.info("computed FOV from player position")
    lurek.log.info("origin=" .. tostring(origin) .. " east=" .. tostring(east) .. " cells=" .. #cells)
end

--@api: LFov:isVisible
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    local target = fov:isVisible(12, 10)
    local far = fov:isVisible(19, 10)
    local explored = fov:isExplored(12, 10)
    lurek.log.info("target tile visible = " .. tostring(target))
    lurek.log.info("far tile visible = " .. tostring(far) .. " explored=" .. tostring(explored))
end

--@api: LFov:isExplored
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    local explored_before = fov:isExplored(10, 10)
    fov:resetExplored()
    local explored_after = fov:isExplored(10, 10)
    lurek.log.info("explored before reset = " .. tostring(explored_before))
    lurek.log.info("explored after reset = " .. tostring(explored_after))
end

--@api: LFov:resetExplored
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    fov:resetExplored()
    local explored_origin = fov:isExplored(10, 10)
    local visible_origin = fov:isVisible(10, 10)
    local cells = fov:visibleCells()
    lurek.log.info("explored mask cleared = " .. tostring(explored_origin))
    lurek.log.info("current frame still sees origin=" .. tostring(visible_origin) .. " cells=" .. #cells)
end

--@api: LFov:eachVisible
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local count = 0
    fov:eachVisible(function(_x, _y)
        count = count + 1
    end)
    lurek.log.info("LFov:eachVisible count=" .. count)
end

--@api: LFov:visibleCells
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local cells = fov:visibleCells()
    local first = cells[1]
    local first_label = first and (first.x .. "," .. first.y) or "none"
    lurek.log.info("visible cell count = " .. #cells)
    lurek.log.info("first visible cell = " .. first_label)
end

--@api: LFov:export
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()
    local cells = fov:visibleCells()
    local explored = fov:isExplored(10, 10)
    lurek.log.info("export blob bytes = " .. #blob)
    lurek.log.info("saved " .. #cells .. " visible cells, explored=" .. tostring(explored))
end

--@api: LFov:import
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()

    local fov2 = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov2:import(blob)
    lurek.log.info("LFov:import explored_10_10=" .. tostring(fov2:isExplored(10, 10)))
end

--@api: LFov:type
do
    local fov = lurek.visibility.newFov({ width = 8, height = 8, range = 4 })
    fov:compute(4, 4)
    local type_name = fov:type()
    local visible = fov:isVisible(4, 4)
    lurek.log.info("FOV type = " .. type_name)
    lurek.log.info("origin visible = " .. tostring(visible))
end

--@api: LFov:typeOf
do
    local fov = lurek.visibility.newFov({ width = 8, height = 8, range = 4 })
    local is_fov = fov:typeOf("LFov")
    local is_object = fov:typeOf("LObject")
    local is_grid = fov:typeOf("LVisibilityGrid")
    lurek.log.info("typeOf LFov = " .. tostring(is_fov))
    lurek.log.info("is object = " .. tostring(is_object) .. " grid=" .. tostring(is_grid))
end
