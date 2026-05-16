-- content/examples/graph.lua
-- lurek.graph API examples.
-- Run: cargo run -- content/examples/graph.lua

--@api-stub: lurek.graph.newGraph -- Creates an empty logistics graph with no nodes, edges, items, or callbacks
do -- lurek.graph.newGraph
  local belts = lurek.graph.newGraph()
  local depot = belts:addNode("depot", 32)
  local sink  = belts:addNode("sink", -1)
  belts:addEdge(depot, sink, "belt")
  lurek.log.info("belt graph: " .. tostring(belts), "factory")
end

-- â”€â”€ GraphItem methods â”€â”€

--@api-stub: GraphItem:getType
do -- GraphItem:getType
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  if ore:getType() == "ore" then lurek.log.info("crate holds raw ore", "factory") end
end

--@api-stub: GraphItem:setType
do -- GraphItem:setType
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  ore:setType("iron_ingot")
  lurek.log.info("ore promoted to " .. ore:getType(), "factory")
end

--@api-stub: GraphItem:getDecayTime
do -- GraphItem:getDecayTime
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  local total = ore:getDecayTime()
  local frac = ore:getRemainingLife() / total
  lurek.log.debug("ore freshness " .. math.floor(frac * 100) .. "%", "factory")
end

--@api-stub: GraphItem:setDecayTime
do -- GraphItem:setDecayTime
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  ore:setDecayTime(-1)
  lurek.log.debug("ore is now immortal: decay=" .. ore:getDecayTime(), "factory")
end

--@api-stub: GraphItem:getRemainingLife
do -- GraphItem:getRemainingLife
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  if ore:getRemainingLife() < 5.0 then
    lurek.log.warn("ore about to spoil!", "factory")
  end
end

--@api-stub: GraphItem:isAlive
do -- GraphItem:isAlive
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  if not ore:isAlive() then
    lurek.log.warn("ore decayed before reaching the smelter", "factory")
  end
end

--@api-stub: GraphItem:kill
do -- GraphItem:kill
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  ore:kill()
  lurek.log.info("ore manually destroyed, alive=" .. tostring(ore:isAlive()), "factory")
end

--@api-stub: GraphItem:getPriority
do -- GraphItem:getPriority
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  ore:setPriority(5)
  lurek.log.debug("ore priority " .. ore:getPriority(), "factory")
end

--@api-stub: GraphItem:setPriority
do -- GraphItem:setPriority
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  ore:setPriority(10)
  local rock = g:createItem("rock", 30.0)
  rock:setPriority(1)  -- ore (10) beats rock (1) at the next bottleneck
end

--@api-stub: GraphItem:getPosition
do -- GraphItem:getPosition
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  local first, second = ore:getPosition()
  if second then
    lurek.log.info("ore in transit progress=" .. tostring(second), "factory")
  elseif first then
    lurek.log.info("ore parked at node", "factory")
  end
end

--@api-stub: GraphItem:type
do -- GraphItem:type
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  if ore:type() == "GraphItem" then
    lurek.log.debug("inspecting graph item", "factory")
  end
end

--@api-stub: GraphItem:typeOf
do -- GraphItem:typeOf
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 16)
  local ore = g:createItem("ore", 30.0)
  g:addItem(ore, store)
  if ore:typeOf("Object") then
    lurek.log.debug("ore is a tracked Lurek object", "factory")
  end
end

-- â”€â”€ Edge methods â”€â”€

--@api-stub: Edge:getType
do -- Edge:getType
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  if belt:getType() == "conveyor" then
    lurek.log.debug("rendering conveyor segment", "render")
  end
end

--@api-stub: Edge:setType
do -- Edge:setType
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setType("highway")
  lurek.log.info("belt is now a " .. belt:getType(), "factory")
end

--@api-stub: Edge:getFrom
do -- Edge:getFrom
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  local src = belt:getFrom()
  lurek.log.debug("belt comes from " .. src:getType() .. " node", "factory")
end

--@api-stub: Edge:getTo
do -- Edge:getTo
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  local dst = belt:getTo()
  lurek.log.debug("belt feeds into " .. dst:getType() .. " node", "factory")
end

--@api-stub: Edge:getCapacity
do -- Edge:getCapacity
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setCapacity(8)
  local cap = belt:getCapacity()
  if cap > 0 then lurek.log.debug("belt cap " .. cap, "factory") end
end

--@api-stub: Edge:setCapacity
do -- Edge:setCapacity
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setCapacity(8)  -- tier-2 belt holds 8 items
end

--@api-stub: Edge:getThroughput
do -- Edge:getThroughput
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setThroughput(2.0)
  local per_sec = belt:getThroughput()
  lurek.log.info("belt moves " .. per_sec .. " items/s", "factory")
end

--@api-stub: Edge:setThroughput
do -- Edge:setThroughput
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setThroughput(4.0)
end

--@api-stub: Edge:getTravelTime
do -- Edge:getTravelTime
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setTravelTime(1.5)
  local t = belt:getTravelTime()
  lurek.log.debug("items take " .. t .. "s to cross belt", "factory")
end

--@api-stub: Edge:setTravelTime
do -- Edge:setTravelTime
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setTravelTime(2.0)  -- longer belt for slower planet level
end

--@api-stub: Edge:getWeight
do -- Edge:getWeight
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setWeight(3.0)
  lurek.log.debug("edge weight=" .. belt:getWeight(), "pathfind")
end

--@api-stub: Edge:setWeight
do -- Edge:setWeight
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setWeight(10.0)  -- toll road, prefer alternatives
end

--@api-stub: Edge:getSpeedModifier
do -- Edge:getSpeedModifier
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setSpeedModifier(1.5)
  lurek.log.debug("speed boost " .. belt:getSpeedModifier() .. "x", "factory")
end

--@api-stub: Edge:setSpeedModifier
do -- Edge:setSpeedModifier
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setSpeedModifier(2.0)  -- accelerator belt
end

--@api-stub: Edge:getCooldown
do -- Edge:getCooldown
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setCooldown(0.25)
  lurek.log.debug("edge cooldown " .. belt:getCooldown() .. "s", "factory")
end

--@api-stub: Edge:setCooldown
do -- Edge:setCooldown
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setCooldown(2.0)  -- catapult, fires every 2s
end

--@api-stub: Edge:isOnCooldown
do -- Edge:isOnCooldown
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setCooldown(1.0)
  if belt:isOnCooldown() then
    lurek.log.debug("belt charging", "factory")
  end
end

--@api-stub: Edge:isBidirectional
do -- Edge:isBidirectional
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setBidirectional(true)
  if belt:isBidirectional() then
    lurek.log.debug("belt accepts reverse traffic", "factory")
  end
end

--@api-stub: Edge:setBidirectional
do -- Edge:setBidirectional
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setBidirectional(true)  -- two-way road
end

--@api-stub: Edge:isActive
do -- Edge:isActive
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  if belt:isActive() then
    lurek.log.debug("belt is online", "factory")
  end
end

--@api-stub: Edge:setActive
do -- Edge:setActive
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:setActive(false)  -- power outage; routes will avoid this edge
end

--@api-stub: Edge:getItemsInTransit
do -- Edge:getItemsInTransit
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  local items = belt:getItemsInTransit()
  lurek.log.debug(#items .. " items currently riding the belt", "factory")
  for _, it in ipairs(items) do lurek.log.debug("  " .. it:getType(), "factory") end
end

--@api-stub: Edge:addAllowedType
do -- Edge:addAllowedType
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:addAllowedType("ore")
  belt:addAllowedType("coal")
  lurek.log.info("belt accepts ore and coal", "factory")
end

--@api-stub: Edge:removeAllowedType
do -- Edge:removeAllowedType
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:addAllowedType("ore")
  belt:addAllowedType("coal")
  belt:removeAllowedType("coal")
end

--@api-stub: Edge:clearAllowedTypes
do -- Edge:clearAllowedTypes
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:addAllowedType("ore")
  belt:clearAllowedTypes()  -- back to permissive
end

--@api-stub: Edge:isItemTypeAllowed
do -- Edge:isItemTypeAllowed
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  belt:addAllowedType("ore")
  if not belt:isItemTypeAllowed("water") then
    lurek.log.warn("belt rejects water", "factory")
  end
end

--@api-stub: Edge:type
do -- Edge:type
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  if belt:type() == "GraphEdge" then
    lurek.log.debug("inspecting an edge", "factory")
  end
end

--@api-stub: Edge:typeOf
do -- Edge:typeOf
  local g = lurek.graph.newGraph()
  local a = g:addNode("source")
  local b = g:addNode("sink")
  local belt = g:addEdge(a, b, "conveyor")
  if belt:typeOf("GraphEdge") then
    lurek.log.debug("yes, this is an edge", "factory")
  end
end

-- â”€â”€ Node methods â”€â”€

--@api-stub: Node:getType
do -- Node:getType
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  if depot:getType() == "depot" then
    lurek.log.debug("rendering depot pad", "render")
  end
end

--@api-stub: Node:setType
do -- Node:setType
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setType("automated_depot")
end

--@api-stub: Node:getCapacity
do -- Node:getCapacity
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  local cap = depot:getCapacity()
  if cap > 0 then lurek.log.debug("depot holds up to " .. cap, "factory") end
end

--@api-stub: Node:setCapacity
do -- Node:setCapacity
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setCapacity(32)  -- silo upgraded to mk-II
end

--@api-stub: Node:getItemCount
do -- Node:getItemCount
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  local item = g:createItem("ore", -1)
  g:addItem(item, depot)
  lurek.log.debug("depot now holds " .. depot:getItemCount(), "factory")
end

--@api-stub: Node:isFull
do -- Node:isFull
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setCapacity(1)
  g:addItem(g:createItem("ore", -1), depot)
  if depot:isFull() then lurek.log.warn("depot full!", "factory") end
end

--@api-stub: Node:isActive
do -- Node:isActive
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  if depot:isActive() then
    lurek.log.debug("depot is online", "factory")
  end
end

--@api-stub: Node:setActive
do -- Node:setActive
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setActive(false)  -- mothballed for the level
end

--@api-stub: Node:getOverflowPolicy
do -- Node:getOverflowPolicy
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setOverflowPolicy("reject")
  lurek.log.debug("overflow policy=" .. depot:getOverflowPolicy(), "factory")
end

--@api-stub: Node:setOverflowPolicy
do -- Node:setOverflowPolicy
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setOverflowPolicy("queue")  -- buffer excess items rather than rejecting them
end

--@api-stub: Node:getFlowMode
do -- Node:getFlowMode
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setFlowMode("push")
  lurek.log.debug("flow mode=" .. depot:getFlowMode(), "factory")
end

--@api-stub: Node:setFlowMode
do -- Node:setFlowMode
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setFlowMode("both")
end

--@api-stub: Node:getPushRate
do -- Node:getPushRate
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPushRate(2.5)
  lurek.log.debug("push rate=" .. depot:getPushRate() .. "/s", "factory")
end

--@api-stub: Node:setPushRate
do -- Node:setPushRate
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPushRate(5.0)  -- tier-3 pump
end

--@api-stub: Node:getPullRate
do -- Node:getPullRate
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPullRate(1.5)
  lurek.log.debug("pull rate=" .. depot:getPullRate() .. "/s", "factory")
end

--@api-stub: Node:setPullRate
do -- Node:setPullRate
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPullRate(3.0)  -- consumer accepts up to 3 items/s
end

--@api-stub: Node:getPushFilter
do -- Node:getPushFilter
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPushFilter("ore")
  local f = depot:getPushFilter()
  if f then lurek.log.debug("pushes only " .. f, "factory") end
end

--@api-stub: Node:setPushFilter
do -- Node:setPushFilter
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPushFilter("iron_ingot")  -- splitter routes ingots only
end

--@api-stub: Node:getPullFilter
do -- Node:getPullFilter
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPullFilter("coal")
  local f = depot:getPullFilter()
  if f then lurek.log.debug("pulls only " .. f, "factory") end
end

--@api-stub: Node:setPullFilter
do -- Node:setPullFilter
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setPullFilter("coal")
end

--@api-stub: Node:getProcessTime
do -- Node:getProcessTime
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setProcessTime(2.0)
  lurek.log.debug("process time " .. depot:getProcessTime() .. "s", "factory")
end

--@api-stub: Node:setProcessTime
do -- Node:setProcessTime
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setProcessTime(1.5)  -- furnace bakes 1.5s per item
end

--@api-stub: Node:isQueueEnabled
do -- Node:isQueueEnabled
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
  if depot:isQueueEnabled() then
    lurek.log.debug("depot has FIFO buffer", "factory")
  end
end

--@api-stub: Node:setQueueEnabled
do -- Node:setQueueEnabled
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
end

--@api-stub: Node:getQueueCapacity
do -- Node:getQueueCapacity
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
  depot:setQueueCapacity(64)
  lurek.log.debug("queue cap=" .. depot:getQueueCapacity(), "factory")
end

--@api-stub: Node:setQueueCapacity
do -- Node:setQueueCapacity
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
  depot:setQueueCapacity(128)
end

--@api-stub: Node:getQueueSize
do -- Node:getQueueSize
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
  local qsize = depot:getQueueSize()
  if qsize > 32 then lurek.log.warn("backlog at depot: " .. qsize, "factory") end
end

--@api-stub: Node:getItems
do -- Node:getItems
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  g:addItem(g:createItem("ore", -1), depot)
  g:addItem(g:createItem("coal", -1), depot)
  for _, it in ipairs(depot:getItems()) do lurek.log.debug("at depot: " .. it:getType(), "factory") end
end

--@api-stub: Node:getEdges
do -- Node:getEdges
  local g = lurek.graph.newGraph()
  local a = g:addNode("hub")
  local b = g:addNode("leaf")
  g:addEdge(a, b)
  lurek.log.debug("hub has " .. #a:getEdges("out") .. " outgoing edges", "factory")
end

--@api-stub: Node:clearConversion
do -- Node:clearConversion
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setConversion("ore", "iron_ingot", 2, 1)
  depot:clearConversion("ore")
end

--@api-stub: Node:clearAllConversions
do -- Node:clearAllConversions
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setConversion("ore", "iron_ingot", 2, 1)
  depot:setConversion("coal", "ash", 1, 1)
  depot:clearAllConversions()
end

--@api-stub: Node:addTag
do -- Node:addTag
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addTag("fuel")
  depot:addTag("priority")
end

--@api-stub: Node:removeTag
do -- Node:removeTag
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addTag("sale")
  depot:removeTag("sale")
end

--@api-stub: Node:hasTag
do -- Node:hasTag
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addTag("safe_zone")
  if depot:hasTag("safe_zone") then
    lurek.log.debug("no enemies will spawn here", "ai")
  end
end

--@api-stub: Node:clearTags
do -- Node:clearTags
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addTag("flagged")
  depot:addTag("sale")
  depot:clearTags()
end

--@api-stub: Node:getTags
do -- Node:getTags
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addTag("fuel")
  depot:addTag("priority")
  for _, t in ipairs(depot:getTags()) do lurek.log.debug("tag: " .. t, "factory") end
end

--@api-stub: Node:removeSupply
do -- Node:removeSupply
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addSupply("ore", 100)
  depot:removeSupply("ore")
end

--@api-stub: Node:clearSupplies
do -- Node:clearSupplies
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addSupply("ore", 100)
  depot:addSupply("coal", 50)
  depot:clearSupplies()
end

--@api-stub: Node:removeDemand
do -- Node:removeDemand
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addDemand("coal", 10, 1)
  depot:removeDemand("coal")
end

--@api-stub: Node:clearDemands
do -- Node:clearDemands
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:addDemand("ore", 5, 1)
  depot:addDemand("coal", 5, 1)
  depot:clearDemands()
end

--@api-stub: Node:enqueue
do -- Node:enqueue
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
  local item = g:createItem("ore", -1)
  depot:enqueue(item)
end

--@api-stub: Node:dequeue
do -- Node:dequeue
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  depot:setQueueEnabled(true)
  depot:enqueue(g:createItem("ore", -1))
  local out = depot:dequeue()
  if out then lurek.log.debug("dequeued " .. out:getType(), "factory") end
end

--@api-stub: Node:type
do -- Node:type
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  if depot:type() == "GraphNode" then
    lurek.log.debug("inspecting a node", "factory")
  end
end

--@api-stub: Node:typeOf
do -- Node:typeOf
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot", 16)
  if depot:typeOf("GraphNode") then
    lurek.log.debug("yes, this is a node", "factory")
  end
end

-- â”€â”€ Graph methods â”€â”€

--@api-stub: Graph:removeNode
do -- Graph:removeNode
  local g = lurek.graph.newGraph()
  local n = g:addNode("temp")
  g:removeNode(n)
  lurek.log.debug("temp node still here? " .. tostring(g:hasNode(n)), "factory")
end

--@api-stub: Graph:hasNode
do -- Graph:hasNode
  local g = lurek.graph.newGraph()
  local n = g:addNode("checkpoint")
  if g:hasNode(n) then
    lurek.log.debug("checkpoint registered", "factory")
  end
end

--@api-stub: Graph:getNodes
do -- Graph:getNodes
  local g = lurek.graph.newGraph()
  g:addNode("start")
  g:addNode("end")
  for _, n in ipairs(g:getNodes()) do lurek.log.debug("node " .. n:getType(), "factory") end
end

--@api-stub: Graph:getNodeCount
do -- Graph:getNodeCount
  local g = lurek.graph.newGraph()
  g:addNode("start")
  g:addNode("end")
  lurek.log.info("graph has " .. g:getNodeCount() .. " nodes", "factory")
end

--@api-stub: Graph:removeEdge
do -- Graph:removeEdge
  local g = lurek.graph.newGraph()
  local a, b = g:addNode("a"), g:addNode("b")
  local e = g:addEdge(a, b)
  g:removeEdge(e)
end

--@api-stub: Graph:hasEdge
do -- Graph:hasEdge
  local g = lurek.graph.newGraph()
  local a, b = g:addNode("a"), g:addNode("b")
  local e = g:addEdge(a, b)
  if g:hasEdge(e) then
    lurek.log.debug("edge a->b is wired", "factory")
  end
end

--@api-stub: Graph:getEdges
do -- Graph:getEdges
  local g = lurek.graph.newGraph()
  local a, b = g:addNode("a"), g:addNode("b")
  g:addEdge(a, b)
  for _, e in ipairs(g:getEdges()) do lurek.log.debug("edge type " .. e:getType(), "factory") end
end

--@api-stub: Graph:getEdgeCount
do -- Graph:getEdgeCount
  local g = lurek.graph.newGraph()
  g:addEdge(g:addNode("a"), g:addNode("b"))
  lurek.log.info("graph has " .. g:getEdgeCount() .. " edges", "factory")
end

--@api-stub: Graph:removeItem
do -- Graph:removeItem
  local g = lurek.graph.newGraph()
  local store = g:addNode("store", 8)
  local item = g:createItem("ore", -1)
  g:addItem(item, store)
  g:removeItem(item)
end

--@api-stub: Graph:hasItem
do -- Graph:hasItem
  local g = lurek.graph.newGraph()
  local store = g:addNode("store")
  local item = g:createItem("ore", -1)
  g:addItem(item, store)
  if g:hasItem(item) then lurek.log.debug("item still tracked", "factory") end
end

--@api-stub: Graph:getItems
do -- Graph:getItems
  local g = lurek.graph.newGraph()
  local store = g:addNode("store")
  g:addItem(g:createItem("ore", -1), store)
  g:addItem(g:createItem("coal", -1), store)
  lurek.log.debug("graph holds " .. #g:getItems() .. " items", "factory")
end

--@api-stub: Graph:getItemCount
do -- Graph:getItemCount
  local g = lurek.graph.newGraph()
  g:addItem(g:createItem("ore", -1), g:addNode("store"))
  lurek.log.info("items in flight: " .. g:getItemCount(), "factory")
end

--@api-stub: Graph:update
do -- Graph:update
  local g = lurek.graph.newGraph()
  g:addNode("hub")
  function lurek.process(dt)
    g:update(dt)
  end
end

--@api-stub: Graph:step
do -- Graph:step
  local g = lurek.graph.newGraph()
  g:addNode("hub")
  g:step()  -- one deterministic tick
end

--@api-stub: Graph:tickParallel
do -- Graph:tickParallel
  local g = lurek.graph.newGraph()
  function lurek.process(dt)
    g:tickParallel(dt)
  end
end

--@api-stub: Graph:getNeighbors
do -- Graph:getNeighbors
  local g = lurek.graph.newGraph()
  local a = g:addNode("a")
  g:addEdge(a, g:addNode("b"))
  g:addEdge(a, g:addNode("c"))
  lurek.log.debug("a has " .. #g:getNeighbors(a) .. " neighbours", "factory")
end

--@api-stub: Graph:getComponents
do -- Graph:getComponents
  local g = lurek.graph.newGraph()
  g:addNode("island_a")
  g:addNode("island_b")
  lurek.log.info("disconnected components: " .. #g:getComponents(), "factory")
end

--@api-stub: Graph:subgraph
do -- Graph:subgraph
  local g = lurek.graph.newGraph()
  local a = g:addNode("a")
  local b = g:addNode("b")
  local c = g:addNode("c")
  g:addEdge(a, b)
  g:addEdge(b, c)
  local slice = g:subgraph({ a, b })
  lurek.log.info("slice nodes=" .. slice:getNodeCount() .. " edges=" .. slice:getEdgeCount(), "factory")
end

--@api-stub: Graph:hasCycle
do -- Graph:hasCycle
  local g = lurek.graph.newGraph()
  local a, b = g:addNode("a"), g:addNode("b")
  g:addEdge(a, b)
  g:addEdge(b, a)  -- creates a cycle
  if g:hasCycle() then lurek.log.warn("graph has a cycle!", "factory") end
end

--@api-stub: Graph:topologicalSort
do -- Graph:topologicalSort
  local g = lurek.graph.newGraph()
  local a, b = g:addNode("raw"), g:addNode("ingot")
  g:addEdge(a, b)
  local order = g:topologicalSort()
  if order then lurek.log.info("processing order: " .. #order .. " nodes", "factory") end
end

--@api-stub: Graph:mst
do -- Graph:mst
  local g = lurek.graph.newGraph()
  g:addEdge(g:addNode("a"), g:addNode("b"))
  local tree = g:mst()
  lurek.log.info("MST contains " .. #tree .. " edges", "pathfind")
end

--@api-stub: Graph:colorGraph
do -- Graph:colorGraph
  local g = lurek.graph.newGraph()
  local a, b = g:addNode("a"), g:addNode("b")
  g:addEdge(a, b)
  local colors = g:colorGraph()
  for node_id, c in pairs(colors) do lurek.log.debug("node " .. node_id .. " => colour " .. c, "pathfind") end
end

--@api-stub: Graph:isBipartite
do -- Graph:isBipartite
  local g = lurek.graph.newGraph()
  g:addEdge(g:addNode("left"), g:addNode("right"))
  if g:isBipartite() then
    lurek.log.debug("graph splits cleanly into two halves", "pathfind")
  end
end

--@api-stub: Graph:processDemand
do -- Graph:processDemand
  local g = lurek.graph.newGraph()
  local src = g:addNode("mine")
  src:addSupply("ore", 50)
  g:processDemand()
end

--@api-stub: Graph:getStats
do -- Graph:getStats
  local g = lurek.graph.newGraph()
  g:addNode("hub")
  local s = g:getStats()
  lurek.log.info("nodes=" .. s.nodes .. " edges=" .. s.edges .. " items=" .. s.items, "factory")
end

--@api-stub: Graph:type
do -- Graph:type
  local g = lurek.graph.newGraph()
  if g:type() == "Graph" then
    lurek.log.debug("inspecting a graph root", "factory")
  end
end

--@api-stub: Graph:typeOf
do -- Graph:typeOf
  local g = lurek.graph.newGraph()
  if g:typeOf("Graph") then
    lurek.log.debug("yes, this is a graph", "factory")
  end
end


--@api-stub: Node:addDemand
do -- Node:addDemand
  local g = lurek.graph.newGraph()
  local n = g:addNode("warehouse")
  n:addDemand("food", 50)
  lurek.log.info("demand added", "graph")
end

--@api-stub: Graph:addEdge
do -- Graph:addEdge
  local g = lurek.graph.newGraph()
  local a = g:addNode("city_a")
  local b = g:addNode("city_b")
  local e = g:addEdge(a, b, "road")
  lurek.log.info("edges: " .. g:getEdgeCount(), "graph")
end

--@api-stub: Graph:addItem
do -- Graph:addItem
  local g = lurek.graph.newGraph()
  local depot = g:addNode("depot")
  local item = g:createItem("wood", -1)
  g:addItem(item, depot)
  lurek.log.info("item count: " .. g:getItemCount(), "graph")
end

--@api-stub: Graph:addNode
do -- Graph:addNode
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine")
  n:setCapacity(200)
  lurek.log.info("nodes: " .. g:getNodeCount(), "graph")
end

--@api-stub: Node:addSupply
do -- Node:addSupply
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine")
  n:addSupply("ore", 100)
  lurek.log.info("supply added", "graph")
end

--@api-stub: Graph:astar
do -- Graph:astar
  local g = lurek.graph.newGraph()
  local na = g:addNode("A") ; local nb = g:addNode("B") ; local nc = g:addNode("C")
  g:addEdge(na, nb) ; g:addEdge(nb, nc)
  local path = g:astar(na, nc)
  lurek.log.info("path length: " .. (path and #path or 0), "graph")
end

--@api-stub: Graph:createItem
do -- Graph:createItem
  local g = lurek.graph.newGraph()
  local factory = g:addNode("factory")
  local item = g:createItem("widget", -1)
  lurek.log.info("item alive: " .. tostring(item:isAlive()), "graph")
end

--@api-stub: Graph:findPath
do -- Graph:findPath
  local g = lurek.graph.newGraph()
  local na = g:addNode("A") ; local nb = g:addNode("B")
  g:addEdge(na, nb)
  local p = g:findPath(na, nb)
  lurek.log.info("found path: " .. (p and #p or 0) .. " nodes", "graph")
end

--@api-stub: Graph:findPathForItem
do -- Graph:findPathForItem
  local g = lurek.graph.newGraph()
  local ns = g:addNode("source") ; local nk = g:addNode("sink")
  g:addEdge(ns, nk)
  local item = g:createItem("ore", -1)
  local p = g:findPathForItem(item, ns, nk)
  lurek.log.info("item path: " .. (p and #p or 0), "graph")
end

--@api-stub: Graph:getDistance
do -- Graph:getDistance
  local g = lurek.graph.newGraph()
  local nx = g:addNode("X") ; local ny = g:addNode("Y")
  g:addEdge(nx, ny)
  local d = g:getDistance(nx, ny)
  lurek.log.info("distance X->Y: " .. tostring(d), "graph")
end

--@api-stub: Graph:getEdgeBetween
do -- Graph:getEdgeBetween
  local g = lurek.graph.newGraph()
  local na = g:addNode("A") ; local nb = g:addNode("B")
  g:addEdge(na, nb)
  local e = g:getEdgeBetween(na, nb)
  lurek.log.info("edge capacity: " .. tostring(e and e:getCapacity() or 0), "graph")
end

--@api-stub: Graph:getReachable
do -- Graph:getReachable
  local g = lurek.graph.newGraph()
  local na = g:addNode("A") ; local nb = g:addNode("B") ; local nc = g:addNode("C")
  g:addEdge(na, nb) ; g:addEdge(nb, nc)
  local reachable = g:getReachable(na, 5)
  lurek.log.info("reachable: " .. (reachable and #reachable or 0), "graph")
end

--@api-stub: Graph:on
do -- Graph:on
  local g = lurek.graph.newGraph()
  g:on("itemEnter", function(item, node)
    lurek.log.info("item arrived at " .. tostring(node), "graph")
  end)
  lurek.log.info("listener registered", "graph")
end

--@api-stub: Graph:sendItem
do -- Graph:sendItem
  local g = lurek.graph.newGraph()
  local na = g:addNode("A") ; local nb = g:addNode("B")
  local edge = g:addEdge(na, nb)
  local item = g:createItem("gold", -1)
  g:sendItem(item, edge)
  lurek.log.info("item dispatched", "graph")
end

--@api-stub: Node:setConversion
do -- Node:setConversion
  local g = lurek.graph.newGraph()
  local n = g:addNode("smelter")
  n:setConversion("ore", "ingot", 2, 1)
  lurek.log.info("conversion set", "graph")
end

-- =============================================================================
-- COVERAGE: 125 uncovered lurek.graph API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- LGraphEdge methods
-- -----------------------------------------------------------------------------

--@api-stub: LGraphEdge:getType -- Returns the edge type string used by routing and filters
do -- LGraphEdge:getType
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  lurek.log.info("edge type=" .. edge:getType(), "graph")
end
--@api-stub: LGraphEdge:setType -- Sets the edge type string used by routing and filters
do -- LGraphEdge:setType
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "dirt_road")
  edge:setType("paved_road")
  lurek.log.info("edge type=" .. edge:getType(), "graph")
end
--@api-stub: LGraphEdge:getFrom -- Returns the source node for this edge
do -- LGraphEdge:getFrom
  local g = lurek.graph.newGraph()
  local na = g:addNode("source", 8); local nb = g:addNode("sink", 8)
  local edge = g:addEdge(na, nb, "pipe")
  local from = edge:getFrom()
  lurek.log.info("from type=" .. from:getType(), "graph")
end
--@api-stub: LGraphEdge:getTo -- Returns the destination node for this edge
do -- LGraphEdge:getTo
  local g = lurek.graph.newGraph()
  local na = g:addNode("source", 8); local nb = g:addNode("sink", 8)
  local edge = g:addEdge(na, nb, "pipe")
  local to = edge:getTo()
  lurek.log.info("to type=" .. to:getType(), "graph")
end
--@api-stub: LGraphEdge:getCapacity -- Returns this edge's maximum concurrent item capacity
do -- LGraphEdge:getCapacity
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  edge:setCapacity(50)
  lurek.log.info("capacity=" .. edge:getCapacity(), "graph")
end
--@api-stub: LGraphEdge:setCapacity -- Sets this edge's maximum concurrent item capacity
do -- LGraphEdge:setCapacity
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  edge:setCapacity(100)
  lurek.log.info("capacity=" .. edge:getCapacity(), "graph")
end
--@api-stub: LGraphEdge:getThroughput -- Returns this edge's throughput value
do -- LGraphEdge:getThroughput
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  edge:setThroughput(5.0)
  lurek.log.info("throughput=" .. edge:getThroughput(), "graph")
end
--@api-stub: LGraphEdge:setThroughput -- Sets this edge's throughput value
do -- LGraphEdge:setThroughput
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  edge:setThroughput(15.0)
  lurek.log.info("throughput=" .. edge:getThroughput(), "graph")
end
--@api-stub: LGraphEdge:getTravelTime -- Returns the travel time for items moving across this edge
do -- LGraphEdge:getTravelTime
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "road")
  edge:setTravelTime(3.5)
  lurek.log.info("travel_time=" .. edge:getTravelTime(), "graph")
end
--@api-stub: LGraphEdge:setTravelTime -- Sets the travel time for items moving across this edge
do -- LGraphEdge:setTravelTime
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "road")
  edge:setTravelTime(2.0)
  lurek.log.info("travel_time=" .. edge:getTravelTime(), "graph")
end
--@api-stub: LGraphEdge:getWeight -- Returns the pathfinding weight for this edge
do -- LGraphEdge:getWeight
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "road")
  edge:setWeight(1.5)
  lurek.log.info("weight=" .. edge:getWeight(), "graph")
end
--@api-stub: LGraphEdge:setWeight -- Sets the pathfinding weight for this edge
do -- LGraphEdge:setWeight
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "road")
  edge:setWeight(5.0)
  lurek.log.info("weight=" .. edge:getWeight(), "graph")
end
--@api-stub: LGraphEdge:getSpeedModifier -- Returns this edge's speed modifier
do -- LGraphEdge:getSpeedModifier
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "uphill_road")
  edge:setSpeedModifier(0.6)
  lurek.log.info("speed_modifier=" .. edge:getSpeedModifier(), "graph")
end
--@api-stub: LGraphEdge:setSpeedModifier -- Sets this edge's speed modifier
do -- LGraphEdge:setSpeedModifier
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "boost_belt")
  edge:setSpeedModifier(2.0)
  lurek.log.info("speed_modifier=" .. edge:getSpeedModifier(), "graph")
end
--@api-stub: LGraphEdge:getCooldown -- Returns this edge's cooldown timer value
do -- LGraphEdge:getCooldown
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "warp_gate")
  edge:setCooldown(5.0)
  lurek.log.info("cooldown=" .. edge:getCooldown(), "graph")
end
--@api-stub: LGraphEdge:setCooldown -- Sets this edge's cooldown timer value
do -- LGraphEdge:setCooldown
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "express_belt")
  edge:setCooldown(2.0)
  lurek.log.info("cooldown=" .. edge:getCooldown(), "graph")
end
--@api-stub: LGraphEdge:isOnCooldown -- Returns whether this edge is currently on cooldown
do -- LGraphEdge:isOnCooldown
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  lurek.log.info("on_cooldown=" .. tostring(edge:isOnCooldown()), "graph")
end
--@api-stub: LGraphEdge:isBidirectional -- Returns whether this edge allows travel in both directions
do -- LGraphEdge:isBidirectional
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "road")
  edge:setBidirectional(true)
  lurek.log.info("bidirectional=" .. tostring(edge:isBidirectional()), "graph")
end
--@api-stub: LGraphEdge:setBidirectional -- Sets whether this edge allows travel in both directions
do -- LGraphEdge:setBidirectional
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "road")
  edge:setBidirectional(false)
  lurek.log.info("bidirectional=" .. tostring(edge:isBidirectional()), "graph")
end
--@api-stub: LGraphEdge:isActive -- Returns whether this edge is active for routing and simulation
do -- LGraphEdge:isActive
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  lurek.log.info("active=" .. tostring(edge:isActive()), "graph")
end
--@api-stub: LGraphEdge:setActive -- Enables or disables this edge for routing and simulation
do -- LGraphEdge:setActive
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "bridge")
  edge:setActive(false)
  lurek.log.info("active=" .. tostring(edge:isActive()), "graph")
end
--@api-stub: LGraphEdge:getItemsInTransit -- Returns graph items currently traveling along this edge
do -- LGraphEdge:getItemsInTransit
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  local items = edge:getItemsInTransit()
  lurek.log.info("items_in_transit=" .. #items, "graph")
end
--@api-stub: LGraphEdge:addAllowedType -- Allows an item type to traverse this edge
do -- LGraphEdge:addAllowedType
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "pipe")
  edge:addAllowedType("water")
  lurek.log.info("water allowed=" .. tostring(edge:isItemTypeAllowed("water")), "graph")
end
--@api-stub: LGraphEdge:removeAllowedType -- Removes an item type from this edge's allow-list
do -- LGraphEdge:removeAllowedType
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "pipe")
  edge:addAllowedType("acid")
  edge:removeAllowedType("acid")
  lurek.log.info("acid allowed after remove=" .. tostring(edge:isItemTypeAllowed("acid")), "graph")
end
--@api-stub: LGraphEdge:clearAllowedTypes -- Clears this edge's item type allow-list
do -- LGraphEdge:clearAllowedTypes
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  edge:addAllowedType("iron")
  edge:clearAllowedTypes()
  lurek.log.info("iron allowed after clear=" .. tostring(edge:isItemTypeAllowed("iron")), "graph")
end
--@api-stub: LGraphEdge:isItemTypeAllowed -- Returns whether an item type may traverse this edge
do -- LGraphEdge:isItemTypeAllowed
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "pipe")
  edge:addAllowedType("gas")
  lurek.log.info("gas allowed=" .. tostring(edge:isItemTypeAllowed("gas")), "graph")
  lurek.log.info("water allowed=" .. tostring(edge:isItemTypeAllowed("water")), "graph")
end
--@api-stub: LGraphEdge:type -- Returns the Lua-visible type name for this graph edge handle
do -- LGraphEdge:type
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  lurek.log.info("type=" .. edge:type(), "graph")
end
--@api-stub: LGraphEdge:typeOf -- Returns whether this graph edge handle matches a supported type name
do -- LGraphEdge:typeOf
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  local edge = g:addEdge(na, nb, "belt")
  lurek.log.info("is GraphEdge=" .. tostring(edge:typeOf("GraphEdge")), "graph")
  lurek.log.info("is Other=" .. tostring(edge:typeOf("Other")), "graph")
end
--@api-stub: LGraphNode:getType -- Returns this node's type string
do -- LGraphNode:getType
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  lurek.log.info("node type=" .. n:getType(), "graph")
end
--@api-stub: LGraphNode:setType -- Sets this node's type string
do -- LGraphNode:setType
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  n:setType("blast_furnace")
  lurek.log.info("node type=" .. n:getType(), "graph")
end
--@api-stub: LGraphNode:getCapacity -- Returns this node's item capacity
do -- LGraphNode:getCapacity
  local g = lurek.graph.newGraph()
  local n = g:addNode("warehouse", 100)
  lurek.log.info("capacity=" .. n:getCapacity(), "graph")
end
--@api-stub: LGraphNode:setCapacity -- Sets this node's item capacity
do -- LGraphNode:setCapacity
  local g = lurek.graph.newGraph()
  local n = g:addNode("warehouse", 50)
  n:setCapacity(200)
  lurek.log.info("capacity=" .. n:getCapacity(), "graph")
end
--@api-stub: LGraphNode:getItemCount -- Returns the number of items currently stored on this node
do -- LGraphNode:getItemCount
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 32)
  lurek.log.info("items=" .. n:getItemCount(), "graph")
end
--@api-stub: LGraphNode:isFull -- Returns whether this node has reached its item capacity
do -- LGraphNode:isFull
  local g = lurek.graph.newGraph()
  local n = g:addNode("buffer", 4)
  lurek.log.info("full=" .. tostring(n:isFull()), "graph")
end
--@api-stub: LGraphNode:isActive -- Returns whether this node is active for graph simulation
do -- LGraphNode:isActive
  local g = lurek.graph.newGraph()
  local n = g:addNode("reactor", 8)
  lurek.log.info("active=" .. tostring(n:isActive()), "graph")
end
--@api-stub: LGraphNode:setActive -- Enables or disables this node for graph simulation
do -- LGraphNode:setActive
  local g = lurek.graph.newGraph()
  local n = g:addNode("reactor", 8)
  n:setActive(false)
  lurek.log.info("active=" .. tostring(n:isActive()), "graph")
end
--@api-stub: LGraphNode:getOverflowPolicy -- Returns this node's overflow policy name
do -- LGraphNode:getOverflowPolicy
  local g = lurek.graph.newGraph()
  local n = g:addNode("silo", 50)
  n:setOverflowPolicy("destroy")
  lurek.log.info("overflow_policy=" .. n:getOverflowPolicy(), "graph")
end
--@api-stub: LGraphNode:setOverflowPolicy -- Sets this node's overflow policy from a policy name
do -- LGraphNode:setOverflowPolicy
  local g = lurek.graph.newGraph()
  local n = g:addNode("silo", 50)
  n:setOverflowPolicy("reject")
  lurek.log.info("overflow_policy=" .. n:getOverflowPolicy(), "graph")
end
--@api-stub: LGraphNode:getFlowMode -- Returns this node's flow mode name
do -- LGraphNode:getFlowMode
  local g = lurek.graph.newGraph()
  local n = g:addNode("distributor", 16)
  n:setFlowMode("both")
  lurek.log.info("flow_mode=" .. n:getFlowMode(), "graph")
end
--@api-stub: LGraphNode:setFlowMode -- Sets this node's flow mode from a mode name
do -- LGraphNode:setFlowMode
  local g = lurek.graph.newGraph()
  local n = g:addNode("factory", 16)
  n:setFlowMode("pull")
  lurek.log.info("flow_mode=" .. n:getFlowMode(), "graph")
end
--@api-stub: LGraphNode:getPushRate -- Returns this node's push rate
do -- LGraphNode:getPushRate
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine", 32)
  n:setPushRate(2.5)
  lurek.log.info("push_rate=" .. n:getPushRate(), "graph")
end
--@api-stub: LGraphNode:setPushRate -- Sets this node's push rate
do -- LGraphNode:setPushRate
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine", 32)
  n:setPushRate(5.0)
  lurek.log.info("push_rate=" .. n:getPushRate(), "graph")
end
--@api-stub: LGraphNode:getPullRate -- Returns this node's pull rate
do -- LGraphNode:getPullRate
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  n:setPullRate(3.0)
  lurek.log.info("pull_rate=" .. n:getPullRate(), "graph")
end
--@api-stub: LGraphNode:setPullRate -- Sets this node's pull rate
do -- LGraphNode:setPullRate
  local g = lurek.graph.newGraph()
  local n = g:addNode("assembler", 16)
  n:setPullRate(1.5)
  lurek.log.info("pull_rate=" .. n:getPullRate(), "graph")
end
--@api-stub: LGraphNode:getPushFilter -- Returns this node's optional push item-type filter
do -- LGraphNode:getPushFilter
  local g = lurek.graph.newGraph()
  local n = g:addNode("sorter", 8)
  n:setPushFilter("iron_ore")
  lurek.log.info("push_filter=" .. tostring(n:getPushFilter()), "graph")
end
--@api-stub: LGraphNode:setPushFilter -- Sets or clears this node's push item-type filter
do -- LGraphNode:setPushFilter
  local g = lurek.graph.newGraph()
  local n = g:addNode("sorter", 8)
  n:setPushFilter("copper_ore")
  lurek.log.info("push_filter=" .. tostring(n:getPushFilter()), "graph")
end
--@api-stub: LGraphNode:getPullFilter -- Returns this node's optional pull item-type filter
do -- LGraphNode:getPullFilter
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  n:setPullFilter("coal")
  lurek.log.info("pull_filter=" .. tostring(n:getPullFilter()), "graph")
end
--@api-stub: LGraphNode:setPullFilter -- Sets or clears this node's pull item-type filter
do -- LGraphNode:setPullFilter
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  n:setPullFilter("iron_ore")
  lurek.log.info("pull_filter=" .. tostring(n:getPullFilter()), "graph")
end
--@api-stub: LGraphNode:getProcessTime -- Returns the processing time used by this node's conversions
do -- LGraphNode:getProcessTime
  local g = lurek.graph.newGraph()
  local n = g:addNode("assembler", 8)
  n:setProcessTime(4.0)
  lurek.log.info("process_time=" .. n:getProcessTime(), "graph")
end
--@api-stub: LGraphNode:setProcessTime -- Sets the processing time used by this node's conversions
do -- LGraphNode:setProcessTime
  local g = lurek.graph.newGraph()
  local n = g:addNode("assembler", 8)
  n:setProcessTime(2.0)
  lurek.log.info("process_time=" .. n:getProcessTime(), "graph")
end
--@api-stub: LGraphNode:isQueueEnabled -- Returns whether this node's explicit queue is enabled
do -- LGraphNode:isQueueEnabled
  local g = lurek.graph.newGraph()
  local n = g:addNode("buffer", 32)
  n:setQueueEnabled(true)
  lurek.log.info("queue_enabled=" .. tostring(n:isQueueEnabled()), "graph")
end
--@api-stub: LGraphNode:setQueueEnabled -- Enables or disables this node's explicit queue
do -- LGraphNode:setQueueEnabled
  local g = lurek.graph.newGraph()
  local n = g:addNode("splitter", 8)
  n:setQueueEnabled(false)
  lurek.log.info("queue_enabled=" .. tostring(n:isQueueEnabled()), "graph")
end
--@api-stub: LGraphNode:getQueueCapacity -- Returns this node's queue capacity
do -- LGraphNode:getQueueCapacity
  local g = lurek.graph.newGraph()
  local n = g:addNode("buffer", 32)
  n:setQueueEnabled(true); n:setQueueCapacity(10)
  lurek.log.info("queue_capacity=" .. n:getQueueCapacity(), "graph")
end
--@api-stub: LGraphNode:setQueueCapacity -- Sets this node's queue capacity
do -- LGraphNode:setQueueCapacity
  local g = lurek.graph.newGraph()
  local n = g:addNode("buffer", 32)
  n:setQueueEnabled(true); n:setQueueCapacity(20)
  lurek.log.info("queue_capacity=" .. n:getQueueCapacity(), "graph")
end
--@api-stub: LGraphNode:getQueueSize -- Returns the number of item ids currently queued at this node
do -- LGraphNode:getQueueSize
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 32)
  n:setQueueEnabled(true)
  lurek.log.info("queue_size=" .. n:getQueueSize(), "graph")
end
--@api-stub: LGraphNode:getItems -- Returns item handles currently stored on this node
do -- LGraphNode:getItems
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 32)
  local items = n:getItems()
  lurek.log.info("item_count=" .. #items, "graph")
end
--@api-stub: LGraphNode:getEdges -- Returns edge handles connected to this node in the requested direction
do -- LGraphNode:getEdges
  local g = lurek.graph.newGraph()
  local na = g:addNode("a", 8); local nb = g:addNode("b", 8)
  g:addEdge(na, nb, "belt")
  local edges = na:getEdges()
  lurek.log.info("edge_count=" .. #edges, "graph")
end
--@api-stub: LGraphNode:setConversion -- Configures an item conversion rule on this node
do -- LGraphNode:setConversion
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  n:setConversion("iron_ore", "iron_ingot", 1)
  lurek.log.info("conversion added to furnace", "graph")
end
--@api-stub: LGraphNode:clearConversion -- Removes a conversion rule by input item type
do -- LGraphNode:clearConversion
  local g = lurek.graph.newGraph()
  local n = g:addNode("furnace", 16)
  n:setConversion("iron_ore", "iron_ingot", 1)
  n:clearConversion("iron_ore")
  lurek.log.info("conversion cleared", "graph")
end
--@api-stub: LGraphNode:clearAllConversions -- Removes every conversion rule from this node
do -- LGraphNode:clearAllConversions
  local g = lurek.graph.newGraph()
  local n = g:addNode("multi_furnace", 32)
  n:setConversion("iron_ore", "iron_ingot", 1)
  n:setConversion("copper_ore", "copper_ingot", 1)
  n:clearAllConversions()
  lurek.log.info("all conversions cleared", "graph")
end
--@api-stub: LGraphNode:addTag -- Adds a tag to this node
do -- LGraphNode:addTag
  local g = lurek.graph.newGraph()
  local n = g:addNode("warehouse", 100)
  n:addTag("storage"); n:addTag("secure")
  lurek.log.info("has storage=" .. tostring(n:hasTag("storage")), "graph")
end
--@api-stub: LGraphNode:removeTag -- Removes a tag from this node
do -- LGraphNode:removeTag
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 32)
  n:addTag("available"); n:removeTag("available")
  lurek.log.info("has available=" .. tostring(n:hasTag("available")), "graph")
end
--@api-stub: LGraphNode:hasTag -- Returns whether this node has a tag
do -- LGraphNode:hasTag
  local g = lurek.graph.newGraph()
  local n = g:addNode("station", 64)
  n:addTag("train_stop")
  lurek.log.info("has train_stop=" .. tostring(n:hasTag("train_stop")), "graph")
end
--@api-stub: LGraphNode:clearTags -- Removes every tag from this node
do -- LGraphNode:clearTags
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 32)
  n:addTag("a"); n:addTag("b"); n:clearTags()
  lurek.log.info("tags after clear=" .. #n:getTags(), "graph")
end
--@api-stub: LGraphNode:getTags -- Returns all tags assigned to this node
do -- LGraphNode:getTags
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 32)
  n:addTag("port"); n:addTag("western")
  local tags = n:getTags()
  lurek.log.info("tag count=" .. #tags, "graph")
end
--@api-stub: LGraphNode:addSupply -- Adds supply quantity for an item type on this node
do -- LGraphNode:addSupply
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine", 100)
  n:addSupply("iron_ore", 500)
  lurek.log.info("supply added", "graph")
end
--@api-stub: LGraphNode:removeSupply -- Removes supply entry for an item type from this node
do -- LGraphNode:removeSupply
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine", 100)
  n:addSupply("iron_ore", 500)
  n:removeSupply("iron_ore")
  lurek.log.info("supply removed", "graph")
end
--@api-stub: LGraphNode:clearSupplies -- Removes every supply entry from this node
do -- LGraphNode:clearSupplies
  local g = lurek.graph.newGraph()
  local n = g:addNode("mine", 100)
  n:addSupply("gold_ore", 200)
  n:clearSupplies()
  lurek.log.info("all supplies cleared", "graph")
end
--@api-stub: LGraphNode:addDemand -- Adds demand quantity and optional priority for an item type on this node
do -- LGraphNode:addDemand
  local g = lurek.graph.newGraph()
  local n = g:addNode("factory", 32)
  n:addDemand("steel", 100, 1)   -- priority 1 (high)
  lurek.log.info("demand declared for steel", "graph")
end
--@api-stub: LGraphNode:removeDemand -- Removes demand entry for an item type from this node
do -- LGraphNode:removeDemand
  local g = lurek.graph.newGraph()
  local n = g:addNode("factory", 32)
  n:addDemand("steel", 100, 1)
  n:removeDemand("steel")
  lurek.log.info("demand removed", "graph")
end
--@api-stub: LGraphNode:clearDemands -- Removes every demand entry from this node
do -- LGraphNode:clearDemands
  local g = lurek.graph.newGraph()
  local n = g:addNode("factory", 32)
  n:addDemand("wood", 50, 2); n:addDemand("stone", 50, 2)
  n:clearDemands()
  lurek.log.info("all demands cleared", "graph")
end
--@api-stub: LGraphNode:enqueue -- Adds an item handle to this node's explicit queue
do -- LGraphNode:enqueue
  local g = lurek.graph.newGraph()
  local n = g:addNode("buffer", 32)
  n:setQueueEnabled(true)
  n:enqueue(g:createItem("iron_ingot", 1))
  lurek.log.info("queue_size=" .. n:getQueueSize(), "graph")
end
--@api-stub: LGraphNode:dequeue -- Removes and returns the next item from this node's explicit queue
do -- LGraphNode:dequeue
  local g = lurek.graph.newGraph()
  local n = g:addNode("buffer", 32)
  n:setQueueEnabled(true)
  n:enqueue(g:createItem("coal", 1))
  local item = n:dequeue()
  lurek.log.info("dequeued=" .. tostring(item), "graph")
end
--@api-stub: LGraphNode:type -- Returns the Lua-visible type name for this graph node handle
do -- LGraphNode:type
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 8)
  lurek.log.info("type=" .. n:type(), "graph")
end
--@api-stub: LGraphNode:typeOf -- Returns whether this graph node handle matches a supported type name
do -- LGraphNode:typeOf
  local g = lurek.graph.newGraph()
  local n = g:addNode("depot", 8)
  lurek.log.info("is GraphNode=" .. tostring(n:typeOf("GraphNode")), "graph")
  lurek.log.info("is Other=" .. tostring(n:typeOf("Other")), "graph")
end
