--- Visibility (Fog-of-War) Example
--- Demonstrates the universal visibility system.

-- Create a visibility grid for 100 regions, 4 players
--@api-stub: lurek.visibility.new
do
    local vg = lurek.visibility.new({ regions = 20 * 15, players = 4 })
    print("lurek.visibility.new type=" .. type(vg))
    print("players=" .. vg:playerCount())
end

--@api-stub: LVisibilityGrid:reveal
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 5, 3)
    print("LVisibilityGrid:reveal state=" .. vg:getState(0, 5))
end

--@api-stub: LVisibilityGrid:hide
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:revealAll(0)
    vg:hide(0, 3)
    print("LVisibilityGrid:hide state=" .. vg:getState(0, 3))
end

--@api-stub: LVisibilityGrid:getState
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(1, 42, 2)
    print("LVisibilityGrid:getState=" .. vg:getState(1, 42))
end

--@api-stub: LVisibilityGrid:getFogIntensity
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local fog = vg:getFogIntensity(0, 0)
    print("LVisibilityGrid:getFogIntensity=" .. fog)
end

--@api-stub: LVisibilityGrid:setCost
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(5, 2.0)
    print("LVisibilityGrid:setCost=" .. vg:getCost(5))
end

--@api-stub: LVisibilityGrid:getCost
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(7, 3.5)
    print("LVisibilityGrid:getCost=" .. vg:getCost(7))
end

--@api-stub: LVisibilityGrid:setFlag
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(8, 6, true)
    print("LVisibilityGrid:setFlag=" .. tostring(vg:hasFlag(8, 6)))
end

--@api-stub: LVisibilityGrid:hasFlag
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(4, 4, true)
    print("LVisibilityGrid:hasFlag=" .. tostring(vg:hasFlag(4, 4)))
end

--@api-stub: LVisibilityGrid:setGroup
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local groupId = vg:setGroup({ 0, 1 })
    print("LVisibilityGrid:setGroup id=" .. groupId)
end

--@api-stub: LVisibilityGrid:sharesVisibility
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setGroup({ 1, 2 })
    local shared = vg:sharesVisibility(1, 2)
    print("LVisibilityGrid:sharesVisibility=" .. tostring(shared))
end

--@api-stub: LVisibilityGrid:revealAll
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    print("LVisibilityGrid:revealAll state=" .. vg:getState(0, 5))
end

--@api-stub: LVisibilityGrid:reset
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    vg:reset(0)
    print("LVisibilityGrid:reset state=" .. vg:getState(0, 5))
end

--@api-stub: LVisibilityGrid:drainEvents
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:reveal(0, 3, 2)
    local events = vg:drainEvents()
    print("LVisibilityGrid:drainEvents count=" .. #events)
end

--@api-stub: LVisibilityGrid:regionCount
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    print("LVisibilityGrid:regionCount=" .. vg:regionCount())
end

--@api-stub: LVisibilityGrid:playerCount
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:setGroup({ 0, 1 })
    print("LVisibilityGrid:playerCount=" .. vg:playerCount())
end
