--- Visibility (Fog-of-War) Example
--- Demonstrates the universal visibility system.

-- Create a visibility grid for 100 regions, 4 players
--@api: lurek.visibility.new
do
    local vg = lurek.visibility.new({ regions = 20 * 15, players = 4 })
    print("lurek.visibility.new type=" .. type(vg))
    print("players=" .. vg:playerCount())
end

--@api: LVisibilityGrid:reveal
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 5, 3)
    print("LVisibilityGrid:reveal state=" .. vg:getState(0, 5))
end

--@api: LVisibilityGrid:hide
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:revealAll(0)
    vg:hide(0, 3)
    print("LVisibilityGrid:hide state=" .. vg:getState(0, 3))
end

--@api: LVisibilityGrid:getState
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(1, 42, 2)
    print("LVisibilityGrid:getState=" .. vg:getState(1, 42))
end

--@api: LVisibilityGrid:getFogIntensity
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local fog = vg:getFogIntensity(0, 0)
    print("LVisibilityGrid:getFogIntensity=" .. fog)
end

--@api: LVisibilityGrid:setCost
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(5, 2.0)
    print("LVisibilityGrid:setCost=" .. vg:getCost(5))
end

--@api: LVisibilityGrid:getCost
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(7, 3.5)
    print("LVisibilityGrid:getCost=" .. vg:getCost(7))
end

--@api: LVisibilityGrid:setFlag
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(8, 6, true)
    print("LVisibilityGrid:setFlag=" .. tostring(vg:hasFlag(8, 6)))
end

--@api: LVisibilityGrid:hasFlag
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(4, 4, true)
    print("LVisibilityGrid:hasFlag=" .. tostring(vg:hasFlag(4, 4)))
end

--@api: LVisibilityGrid:setGroup
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local groupId = vg:setGroup({ 0, 1 })
    print("LVisibilityGrid:setGroup id=" .. groupId)
end

--@api: LVisibilityGrid:sharesVisibility
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setGroup({ 1, 2 })
    local shared = vg:sharesVisibility(1, 2)
    print("LVisibilityGrid:sharesVisibility=" .. tostring(shared))
end

--@api: LVisibilityGrid:revealAll
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    print("LVisibilityGrid:revealAll state=" .. vg:getState(0, 5))
end

--@api: LVisibilityGrid:reset
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    vg:reset(0)
    print("LVisibilityGrid:reset state=" .. vg:getState(0, 5))
end

--@api: LVisibilityGrid:drainEvents
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:reveal(0, 3, 2)
    local events = vg:drainEvents()
    print("LVisibilityGrid:drainEvents count=" .. #events)
end

--@api: LVisibilityGrid:regionCount
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    print("LVisibilityGrid:regionCount=" .. vg:regionCount())
end

--@api: LVisibilityGrid:playerCount
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:setGroup({ 0, 1 })
    print("LVisibilityGrid:playerCount=" .. vg:playerCount())
end

--@api: lurek.visibility.newFov
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    print("newFov type=" .. fov:type())
end

--@api: LFov:setBlocker
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:setBlocker(function(x, y)
        return x == 10 and y >= 6 and y <= 14
    end)
    fov:compute(5, 10)
    print("LFov:setBlocker visible_12_10=" .. tostring(fov:isVisible(12, 10)))
end

--@api: LFov:setRange
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 4 })
    fov:setRange(10)
    fov:compute(10, 10)
    print("LFov:setRange visible_18_10=" .. tostring(fov:isVisible(18, 10)))
end

--@api: LFov:compute
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    print("LFov:compute visible_10_10=" .. tostring(fov:isVisible(10, 10)))
end

--@api: LFov:isVisible
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    print("LFov:isVisible=" .. tostring(fov:isVisible(12, 10)))
end

--@api: LFov:isExplored
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    print("LFov:isExplored_before_reset=" .. tostring(fov:isExplored(10, 10)))
end

--@api: LFov:resetExplored
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    fov:resetExplored()
    print("LFov:resetExplored=" .. tostring(fov:isExplored(10, 10)))
end

--@api: LFov:eachVisible
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local count = 0
    fov:eachVisible(function(_x, _y)
        count = count + 1
    end)
    print("LFov:eachVisible count=" .. count)
end

--@api: LFov:visibleCells
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local cells = fov:visibleCells()
    print("LFov:visibleCells count=" .. #cells)
end

--@api: LFov:export
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()
    print("LFov:export bytes=" .. #blob)
end

--@api: LFov:import
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()

    local fov2 = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov2:import(blob)
    print("LFov:import explored_10_10=" .. tostring(fov2:isExplored(10, 10)))
end

--@api: LFov:type
do
    local fov = lurek.visibility.newFov({ width = 8, height = 8, range = 4 })
    print("LFov:type=" .. fov:type())
end

--@api: LFov:typeOf
do
    local fov = lurek.visibility.newFov({ width = 8, height = 8, range = 4 })
    print("LFov:typeOf_Fov=" .. tostring(fov:typeOf("LFov")))
    print("LFov:typeOf_Object=" .. tostring(fov:typeOf("LObject")))
end
