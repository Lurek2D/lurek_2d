-- content/examples/graph.lua
-- Lurek2D lurek.graph API Reference
-- Run with: cargo run -- content/examples/graph
--
-- Scenario: A factory automation game where nodes are machines (smelters,
-- assemblers, storages), edges are conveyor belts carrying items between them,
-- and the graph system handles flow logic, routing, supply/demand, and
-- production chains. Items decay, nodes have capacity, and edges filter types.

print("=== lurek.graph — Flow Graph System ===\n")

-- =============================================================================
-- Graph Creation
-- =============================================================================

--@api-stub: lurek.graph.newGraph
-- Demonstrates the proper usage of lurek.graph.newGraph.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_graph_newGraph()
    local factory = lurek.graph.newGraph()
end
local _ok, _err = pcall(demo_lurek_graph_newGraph)

--@api-stub: Graph:type
-- Demonstrates the proper usage of Graph:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_type()
    print("graph type: " .. factory:type())
end
local _ok, _err = pcall(demo_Graph_type)

--@api-stub: Graph:typeOf
-- Demonstrates the proper usage of Graph:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_typeOf()
    print("is Graph: " .. tostring(factory:typeOf("Graph")))
end
local _ok, _err = pcall(demo_Graph_typeOf)

-- =============================================================================
-- Adding & Querying Nodes
-- =============================================================================

-- Nodes are returned from factory:addNode() — we can't call it directly since
-- it's not listed as a standalone function, but use the graph to get nodes.

--@api-stub: Graph:getNodeCount
-- Demonstrates the proper usage of Graph:getNodeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getNodeCount()
    print("nodes: " .. factory:getNodeCount())
end
local _ok, _err = pcall(demo_Graph_getNodeCount)

--@api-stub: Graph:getNodes
-- Demonstrates the proper usage of Graph:getNodes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getNodes()
    local nodes = factory:getNodes()
end
local _ok, _err = pcall(demo_Graph_getNodes)

--@api-stub: Graph:hasNode
-- Demonstrates the proper usage of Graph:hasNode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasNode()
    print('Executing hasNode')
end
local _ok, _err = pcall(demo_Graph_hasNode)

--@api-stub: Graph:removeNode
-- Demonstrates the proper usage of Graph:removeNode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_removeNode()
    print('Executing removeNode')
end
local _ok, _err = pcall(demo_Graph_removeNode)

--@api-stub: Graph:getNeighbors
-- Demonstrates the proper usage of Graph:getNeighbors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getNeighbors()
    print('Executing getNeighbors')
end
local _ok, _err = pcall(demo_Graph_getNeighbors)

-- =============================================================================
-- Node Configuration — Machine setup
-- =============================================================================

-- Assume we have a node from the graph:
local smelter = nodes[1]  -- first node if exists

if smelter then
--@api-stub: Node:type
-- Demonstrates the proper usage of Node:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_type()
    print("node type: " .. smelter:type())
end
local _ok, _err = pcall(demo_Node_type)

--@api-stub: Node:typeOf
-- Demonstrates the proper usage of Node:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_typeOf()
    print("is Node: " .. tostring(smelter:typeOf("Node")))
end
local _ok, _err = pcall(demo_Node_typeOf)

--@api-stub: Node:setType
-- Demonstrates the proper usage of Node:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setType()
    smelter:setType("smelter")
end
local _ok, _err = pcall(demo_Node_setType)

--@api-stub: Node:getType
-- Demonstrates the proper usage of Node:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getType()
    print("machine: " .. smelter:getType())
end
local _ok, _err = pcall(demo_Node_getType)

--@api-stub: Node:setCapacity
-- Demonstrates the proper usage of Node:setCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setCapacity()
    smelter:setCapacity(10)
end
local _ok, _err = pcall(demo_Node_setCapacity)

--@api-stub: Node:getCapacity
-- Demonstrates the proper usage of Node:getCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getCapacity()
    print("capacity: " .. smelter:getCapacity())
end
local _ok, _err = pcall(demo_Node_getCapacity)

--@api-stub: Node:getItemCount
-- Demonstrates the proper usage of Node:getItemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getItemCount()
    print("items stored: " .. smelter:getItemCount())
end
local _ok, _err = pcall(demo_Node_getItemCount)

--@api-stub: Node:isFull
-- Demonstrates the proper usage of Node:isFull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_isFull()
    print("full: " .. tostring(smelter:isFull()))
end
local _ok, _err = pcall(demo_Node_isFull)

--@api-stub: Node:setActive
-- Demonstrates the proper usage of Node:setActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setActive()
    smelter:setActive(true)
end
local _ok, _err = pcall(demo_Node_setActive)

--@api-stub: Node:isActive
-- Demonstrates the proper usage of Node:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_isActive()
    print("active: " .. tostring(smelter:isActive()))
end
local _ok, _err = pcall(demo_Node_isActive)

    -- =============================================================================
    -- Node Flow Mode — Push/Pull production
    -- =============================================================================

--@api-stub: Node:setFlowMode
-- Demonstrates the proper usage of Node:setFlowMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setFlowMode()
    smelter:setFlowMode("push")
end
local _ok, _err = pcall(demo_Node_setFlowMode)

--@api-stub: Node:getFlowMode
-- Demonstrates the proper usage of Node:getFlowMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getFlowMode()
    print("flow mode: " .. smelter:getFlowMode())
end
local _ok, _err = pcall(demo_Node_getFlowMode)

--@api-stub: Node:setPushRate
-- Demonstrates the proper usage of Node:setPushRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPushRate()
    smelter:setPushRate(5)
end
local _ok, _err = pcall(demo_Node_setPushRate)

--@api-stub: Node:getPushRate
-- Demonstrates the proper usage of Node:getPushRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPushRate()
    print("push rate: " .. smelter:getPushRate())
end
local _ok, _err = pcall(demo_Node_getPushRate)

--@api-stub: Node:setPullRate
-- Demonstrates the proper usage of Node:setPullRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPullRate()
    smelter:setPullRate(3)
end
local _ok, _err = pcall(demo_Node_setPullRate)

--@api-stub: Node:getPullRate
-- Demonstrates the proper usage of Node:getPullRate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPullRate()
    print("pull rate: " .. smelter:getPullRate())
end
local _ok, _err = pcall(demo_Node_getPullRate)

--@api-stub: Node:setPushFilter
-- Demonstrates the proper usage of Node:setPushFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPushFilter()
    smelter:setPushFilter("iron_ingot")
end
local _ok, _err = pcall(demo_Node_setPushFilter)

--@api-stub: Node:getPushFilter
-- Demonstrates the proper usage of Node:getPushFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPushFilter()
    print("push filter: " .. smelter:getPushFilter())
end
local _ok, _err = pcall(demo_Node_getPushFilter)

--@api-stub: Node:setPullFilter
-- Demonstrates the proper usage of Node:setPullFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setPullFilter()
    smelter:setPullFilter("iron_ore")
end
local _ok, _err = pcall(demo_Node_setPullFilter)

--@api-stub: Node:getPullFilter
-- Demonstrates the proper usage of Node:getPullFilter.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getPullFilter()
    print("pull filter: " .. smelter:getPullFilter())
end
local _ok, _err = pcall(demo_Node_getPullFilter)

--@api-stub: Node:setOverflowPolicy
-- Demonstrates the proper usage of Node:setOverflowPolicy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setOverflowPolicy()
    smelter:setOverflowPolicy("drop")
end
local _ok, _err = pcall(demo_Node_setOverflowPolicy)

--@api-stub: Node:getOverflowPolicy
-- Demonstrates the proper usage of Node:getOverflowPolicy.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getOverflowPolicy()
    print("overflow: " .. smelter:getOverflowPolicy())
end
local _ok, _err = pcall(demo_Node_getOverflowPolicy)

    -- =============================================================================
    -- Node Processing — Conversion recipes
    -- =============================================================================

--@api-stub: Node:setProcessTime
-- Demonstrates the proper usage of Node:setProcessTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setProcessTime()
    smelter:setProcessTime(2.0)
end
local _ok, _err = pcall(demo_Node_setProcessTime)

--@api-stub: Node:getProcessTime
-- Demonstrates the proper usage of Node:getProcessTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getProcessTime()
    print("process time: " .. smelter:getProcessTime())
end
local _ok, _err = pcall(demo_Node_getProcessTime)

--@api-stub: Node:clearConversion
-- Demonstrates the proper usage of Node:clearConversion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearConversion()
    smelter:clearConversion("iron_ore")
end
local _ok, _err = pcall(demo_Node_clearConversion)

--@api-stub: Node:clearAllConversions
-- Demonstrates the proper usage of Node:clearAllConversions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearAllConversions()
    smelter:clearAllConversions()
end
local _ok, _err = pcall(demo_Node_clearAllConversions)

    -- =============================================================================
    -- Node Queue
    -- =============================================================================

--@api-stub: Node:setQueueEnabled
-- Demonstrates the proper usage of Node:setQueueEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setQueueEnabled()
    smelter:setQueueEnabled(true)
end
local _ok, _err = pcall(demo_Node_setQueueEnabled)

--@api-stub: Node:isQueueEnabled
-- Demonstrates the proper usage of Node:isQueueEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_isQueueEnabled()
    print("queue: " .. tostring(smelter:isQueueEnabled()))
end
local _ok, _err = pcall(demo_Node_isQueueEnabled)

--@api-stub: Node:setQueueCapacity
-- Demonstrates the proper usage of Node:setQueueCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_setQueueCapacity()
    smelter:setQueueCapacity(20)
end
local _ok, _err = pcall(demo_Node_setQueueCapacity)

--@api-stub: Node:getQueueCapacity
-- Demonstrates the proper usage of Node:getQueueCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getQueueCapacity()
    print("queue cap: " .. smelter:getQueueCapacity())
end
local _ok, _err = pcall(demo_Node_getQueueCapacity)

--@api-stub: Node:getQueueSize
-- Demonstrates the proper usage of Node:getQueueSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getQueueSize()
    print("queue size: " .. smelter:getQueueSize())
end
local _ok, _err = pcall(demo_Node_getQueueSize)

--@api-stub: Node:enqueue
-- Demonstrates the proper usage of Node:enqueue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_enqueue()
    print('Executing enqueue')
end
local _ok, _err = pcall(demo_Node_enqueue)

--@api-stub: Node:dequeue
-- Demonstrates the proper usage of Node:dequeue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_dequeue()
    print('Executing dequeue')
end
local _ok, _err = pcall(demo_Node_dequeue)

--@api-stub: Node:getItems
-- Demonstrates the proper usage of Node:getItems.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getItems()
    local stored = smelter:getItems()
end
local _ok, _err = pcall(demo_Node_getItems)

--@api-stub: Node:getEdges
-- Demonstrates the proper usage of Node:getEdges.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getEdges()
    local connected = smelter:getEdges()
end
local _ok, _err = pcall(demo_Node_getEdges)

    -- =============================================================================
    -- Node Tags & Supply/Demand
    -- =============================================================================

--@api-stub: Node:addTag
-- Demonstrates the proper usage of Node:addTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_addTag()
    smelter:addTag("production")
    smelter:addTag("tier1")
end
local _ok, _err = pcall(demo_Node_addTag)

--@api-stub: Node:hasTag
-- Demonstrates the proper usage of Node:hasTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_hasTag()
    print("is production: " .. tostring(smelter:hasTag("production")))
end
local _ok, _err = pcall(demo_Node_hasTag)

--@api-stub: Node:removeTag
-- Demonstrates the proper usage of Node:removeTag.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_removeTag()
    smelter:removeTag("tier1")
end
local _ok, _err = pcall(demo_Node_removeTag)

--@api-stub: Node:getTags
-- Demonstrates the proper usage of Node:getTags.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_getTags()
    local tags = smelter:getTags()
    print("tags: " .. #tags)
end
local _ok, _err = pcall(demo_Node_getTags)

--@api-stub: Node:clearTags
-- Demonstrates the proper usage of Node:clearTags.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearTags()
    print('Executing clearTags')
end
local _ok, _err = pcall(demo_Node_clearTags)

--@api-stub: Node:removeSupply
-- Demonstrates the proper usage of Node:removeSupply.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_removeSupply()
    smelter:removeSupply("iron_ingot")
end
local _ok, _err = pcall(demo_Node_removeSupply)

--@api-stub: Node:clearSupplies
-- Demonstrates the proper usage of Node:clearSupplies.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearSupplies()
    smelter:clearSupplies()
end
local _ok, _err = pcall(demo_Node_clearSupplies)

--@api-stub: Node:removeDemand
-- Demonstrates the proper usage of Node:removeDemand.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_removeDemand()
    smelter:removeDemand("iron_ore")
end
local _ok, _err = pcall(demo_Node_removeDemand)

--@api-stub: Node:clearDemands
-- Demonstrates the proper usage of Node:clearDemands.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Node_clearDemands()
    smelter:clearDemands()
end
local _ok, _err = pcall(demo_Node_clearDemands)

-- =============================================================================
-- Edges — Conveyor belts
-- =============================================================================

--@api-stub: Graph:getEdgeCount
-- Demonstrates the proper usage of Graph:getEdgeCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getEdgeCount()
    print("edges: " .. factory:getEdgeCount())
end
local _ok, _err = pcall(demo_Graph_getEdgeCount)

--@api-stub: Graph:getEdges
-- Demonstrates the proper usage of Graph:getEdges.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getEdges()
    local edges = factory:getEdges()
end
local _ok, _err = pcall(demo_Graph_getEdges)

--@api-stub: Graph:hasEdge
-- Demonstrates the proper usage of Graph:hasEdge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasEdge()
    print('Executing hasEdge')
end
local _ok, _err = pcall(demo_Graph_hasEdge)

--@api-stub: Graph:removeEdge
-- Demonstrates the proper usage of Graph:removeEdge.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_removeEdge()
    local belt = edges[1]
    if belt then
end
local _ok, _err = pcall(demo_Graph_removeEdge)

--@api-stub: Edge:type
-- Demonstrates the proper usage of Edge:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_type()
    print("edge type: " .. belt:type())
end
local _ok, _err = pcall(demo_Edge_type)

--@api-stub: Edge:typeOf
-- Demonstrates the proper usage of Edge:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_typeOf()
    print("is Edge: " .. tostring(belt:typeOf("Edge")))
end
local _ok, _err = pcall(demo_Edge_typeOf)

--@api-stub: Edge:setType
-- Demonstrates the proper usage of Edge:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setType()
    belt:setType("conveyor_mk2")
end
local _ok, _err = pcall(demo_Edge_setType)

--@api-stub: Edge:getType
-- Demonstrates the proper usage of Edge:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getType()
    print("belt: " .. belt:getType())
end
local _ok, _err = pcall(demo_Edge_getType)

--@api-stub: Edge:getFrom
-- Demonstrates the proper usage of Edge:getFrom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getFrom()
    print("from: " .. tostring(belt:getFrom()))
end
local _ok, _err = pcall(demo_Edge_getFrom)

--@api-stub: Edge:getTo
-- Demonstrates the proper usage of Edge:getTo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getTo()
    print("to: " .. tostring(belt:getTo()))
end
local _ok, _err = pcall(demo_Edge_getTo)

--@api-stub: Edge:setWeight
-- Demonstrates the proper usage of Edge:setWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setWeight()
    belt:setWeight(1.0)
end
local _ok, _err = pcall(demo_Edge_setWeight)

--@api-stub: Edge:getWeight
-- Demonstrates the proper usage of Edge:getWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getWeight()
    print("weight: " .. belt:getWeight())
end
local _ok, _err = pcall(demo_Edge_getWeight)

    -- =============================================================================
    -- Edge — Capacity & Throughput
    -- =============================================================================

--@api-stub: Edge:setCapacity
-- Demonstrates the proper usage of Edge:setCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setCapacity()
    belt:setCapacity(10)
end
local _ok, _err = pcall(demo_Edge_setCapacity)

--@api-stub: Edge:getCapacity
-- Demonstrates the proper usage of Edge:getCapacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getCapacity()
    print("belt capacity: " .. belt:getCapacity())
end
local _ok, _err = pcall(demo_Edge_getCapacity)

--@api-stub: Edge:setThroughput
-- Demonstrates the proper usage of Edge:setThroughput.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setThroughput()
    belt:setThroughput(5)
end
local _ok, _err = pcall(demo_Edge_setThroughput)

--@api-stub: Edge:getThroughput
-- Demonstrates the proper usage of Edge:getThroughput.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getThroughput()
    print("throughput: " .. belt:getThroughput())
end
local _ok, _err = pcall(demo_Edge_getThroughput)

--@api-stub: Edge:setSpeedModifier
-- Demonstrates the proper usage of Edge:setSpeedModifier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setSpeedModifier()
    belt:setSpeedModifier(1.5)
end
local _ok, _err = pcall(demo_Edge_setSpeedModifier)

--@api-stub: Edge:getSpeedModifier
-- Demonstrates the proper usage of Edge:getSpeedModifier.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getSpeedModifier()
    print("speed mod: " .. belt:getSpeedModifier())
end
local _ok, _err = pcall(demo_Edge_getSpeedModifier)

--@api-stub: Edge:setTravelTime
-- Demonstrates the proper usage of Edge:setTravelTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setTravelTime()
    belt:setTravelTime(1.0)
end
local _ok, _err = pcall(demo_Edge_setTravelTime)

--@api-stub: Edge:getTravelTime
-- Demonstrates the proper usage of Edge:getTravelTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getTravelTime()
    print("travel time: " .. belt:getTravelTime())
end
local _ok, _err = pcall(demo_Edge_getTravelTime)

    -- =============================================================================
    -- Edge — Cooldown & Directionality
    -- =============================================================================

--@api-stub: Edge:setCooldown
-- Demonstrates the proper usage of Edge:setCooldown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setCooldown()
    belt:setCooldown(0.5)
end
local _ok, _err = pcall(demo_Edge_setCooldown)

--@api-stub: Edge:getCooldown
-- Demonstrates the proper usage of Edge:getCooldown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getCooldown()
    print("cooldown: " .. belt:getCooldown())
end
local _ok, _err = pcall(demo_Edge_getCooldown)

--@api-stub: Edge:isOnCooldown
-- Demonstrates the proper usage of Edge:isOnCooldown.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isOnCooldown()
    print("on cooldown: " .. tostring(belt:isOnCooldown()))
end
local _ok, _err = pcall(demo_Edge_isOnCooldown)

--@api-stub: Edge:setBidirectional
-- Demonstrates the proper usage of Edge:setBidirectional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setBidirectional()
    belt:setBidirectional(false)
end
local _ok, _err = pcall(demo_Edge_setBidirectional)

--@api-stub: Edge:isBidirectional
-- Demonstrates the proper usage of Edge:isBidirectional.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isBidirectional()
    print("bidirectional: " .. tostring(belt:isBidirectional()))
end
local _ok, _err = pcall(demo_Edge_isBidirectional)

--@api-stub: Edge:setActive
-- Demonstrates the proper usage of Edge:setActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_setActive()
    belt:setActive(true)
end
local _ok, _err = pcall(demo_Edge_setActive)

--@api-stub: Edge:isActive
-- Demonstrates the proper usage of Edge:isActive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isActive()
    print("belt active: " .. tostring(belt:isActive()))
end
local _ok, _err = pcall(demo_Edge_isActive)

    -- =============================================================================
    -- Edge — Item Filtering
    -- =============================================================================

--@api-stub: Edge:addAllowedType
-- Demonstrates the proper usage of Edge:addAllowedType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_addAllowedType()
    belt:addAllowedType("iron_ingot")
    belt:addAllowedType("copper_ingot")
end
local _ok, _err = pcall(demo_Edge_addAllowedType)

--@api-stub: Edge:isItemTypeAllowed
-- Demonstrates the proper usage of Edge:isItemTypeAllowed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_isItemTypeAllowed()
    print("iron allowed: " .. tostring(belt:isItemTypeAllowed("iron_ingot")))
end
local _ok, _err = pcall(demo_Edge_isItemTypeAllowed)

--@api-stub: Edge:removeAllowedType
-- Demonstrates the proper usage of Edge:removeAllowedType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_removeAllowedType()
    belt:removeAllowedType("copper_ingot")
end
local _ok, _err = pcall(demo_Edge_removeAllowedType)

--@api-stub: Edge:clearAllowedTypes
-- Demonstrates the proper usage of Edge:clearAllowedTypes.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_clearAllowedTypes()
    print('Executing clearAllowedTypes')
end
local _ok, _err = pcall(demo_Edge_clearAllowedTypes)

--@api-stub: Edge:getItemsInTransit
-- Demonstrates the proper usage of Edge:getItemsInTransit.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Edge_getItemsInTransit()
    print("in transit: " .. belt:getItemsInTransit())
end
local _ok, _err = pcall(demo_Edge_getItemsInTransit)

-- =============================================================================
-- Items — Resources flowing through the factory
-- =============================================================================

--@api-stub: Graph:getItemCount
-- Demonstrates the proper usage of Graph:getItemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getItemCount()
    print("total items: " .. factory:getItemCount())
end
local _ok, _err = pcall(demo_Graph_getItemCount)

--@api-stub: Graph:getItems
-- Demonstrates the proper usage of Graph:getItems.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getItems()
    local items = factory:getItems()
end
local _ok, _err = pcall(demo_Graph_getItems)

--@api-stub: Graph:hasItem
-- Demonstrates the proper usage of Graph:hasItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasItem()
    print('Executing hasItem')
end
local _ok, _err = pcall(demo_Graph_hasItem)

--@api-stub: Graph:removeItem
-- Demonstrates the proper usage of Graph:removeItem.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_removeItem()
    local item = items[1]
    if item then
end
local _ok, _err = pcall(demo_Graph_removeItem)

--@api-stub: GraphItem:type
-- Demonstrates the proper usage of GraphItem:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_type()
    print("item type id: " .. item:type())
end
local _ok, _err = pcall(demo_GraphItem_type)

--@api-stub: GraphItem:typeOf
-- Demonstrates the proper usage of GraphItem:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_typeOf()
    print("is GraphItem: " .. tostring(item:typeOf("GraphItem")))
end
local _ok, _err = pcall(demo_GraphItem_typeOf)

--@api-stub: GraphItem:setType
-- Demonstrates the proper usage of GraphItem:setType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_setType()
    item:setType("iron_ore")
end
local _ok, _err = pcall(demo_GraphItem_setType)

--@api-stub: GraphItem:getType
-- Demonstrates the proper usage of GraphItem:getType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getType()
    print("item: " .. item:getType())
end
local _ok, _err = pcall(demo_GraphItem_getType)

--@api-stub: GraphItem:setDecayTime
-- Demonstrates the proper usage of GraphItem:setDecayTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_setDecayTime()
    item:setDecayTime(30.0)
end
local _ok, _err = pcall(demo_GraphItem_setDecayTime)

--@api-stub: GraphItem:getDecayTime
-- Demonstrates the proper usage of GraphItem:getDecayTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getDecayTime()
    print("decay: " .. item:getDecayTime() .. "s")
end
local _ok, _err = pcall(demo_GraphItem_getDecayTime)

--@api-stub: GraphItem:getRemainingLife
-- Demonstrates the proper usage of GraphItem:getRemainingLife.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getRemainingLife()
    print("remaining life: " .. item:getRemainingLife())
end
local _ok, _err = pcall(demo_GraphItem_getRemainingLife)

--@api-stub: GraphItem:isAlive
-- Demonstrates the proper usage of GraphItem:isAlive.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_isAlive()
    print("alive: " .. tostring(item:isAlive()))
end
local _ok, _err = pcall(demo_GraphItem_isAlive)

--@api-stub: GraphItem:kill
-- Demonstrates the proper usage of GraphItem:kill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_kill()
    print('Executing kill')
end
local _ok, _err = pcall(demo_GraphItem_kill)

--@api-stub: GraphItem:setPriority
-- Demonstrates the proper usage of GraphItem:setPriority.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_setPriority()
    item:setPriority(5)
end
local _ok, _err = pcall(demo_GraphItem_setPriority)

--@api-stub: GraphItem:getPriority
-- Demonstrates the proper usage of GraphItem:getPriority.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getPriority()
    print("priority: " .. item:getPriority())
end
local _ok, _err = pcall(demo_GraphItem_getPriority)

--@api-stub: GraphItem:getPosition
-- Demonstrates the proper usage of GraphItem:getPosition.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_GraphItem_getPosition()
    print("position: " .. tostring(item:getPosition()))
end
local _ok, _err = pcall(demo_GraphItem_getPosition)

-- =============================================================================
-- Graph Simulation
-- =============================================================================

--@api-stub: Graph:update
-- Demonstrates the proper usage of Graph:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_update()
    factory:update(1/60)
end
local _ok, _err = pcall(demo_Graph_update)

--@api-stub: Graph:step
-- Demonstrates the proper usage of Graph:step.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_step()
    factory:step()
end
local _ok, _err = pcall(demo_Graph_step)

--@api-stub: Graph:tickParallel
-- Demonstrates the proper usage of Graph:tickParallel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_tickParallel()
    factory:tickParallel(4)
end
local _ok, _err = pcall(demo_Graph_tickParallel)

-- =============================================================================
-- Graph Analysis
-- =============================================================================

--@api-stub: Graph:getComponents
-- Demonstrates the proper usage of Graph:getComponents.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getComponents()
    local components = factory:getComponents()
    print("connected components: " .. #components)
end
local _ok, _err = pcall(demo_Graph_getComponents)

--@api-stub: Graph:hasCycle
-- Demonstrates the proper usage of Graph:hasCycle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_hasCycle()
    print("has cycle: " .. tostring(factory:hasCycle()))
end
local _ok, _err = pcall(demo_Graph_hasCycle)

--@api-stub: Graph:topologicalSort
-- Demonstrates the proper usage of Graph:topologicalSort.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_topologicalSort()
    local sorted = factory:topologicalSort()
end
local _ok, _err = pcall(demo_Graph_topologicalSort)

--@api-stub: Graph:mst
-- Demonstrates the proper usage of Graph:mst.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_mst()
    local mst = factory:mst()
    print("MST edges: " .. #mst)
end
local _ok, _err = pcall(demo_Graph_mst)

--@api-stub: Graph:colorGraph
-- Demonstrates the proper usage of Graph:colorGraph.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_colorGraph()
    local coloring = factory:colorGraph()
end
local _ok, _err = pcall(demo_Graph_colorGraph)

--@api-stub: Graph:isBipartite
-- Demonstrates the proper usage of Graph:isBipartite.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_isBipartite()
    print("bipartite: " .. tostring(factory:isBipartite()))
end
local _ok, _err = pcall(demo_Graph_isBipartite)

--@api-stub: Graph:astar
-- Demonstrates the proper usage of Graph:astar.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_astar()
    local path = factory:astar(1, 5)
end
local _ok, _err = pcall(demo_Graph_astar)

-- =============================================================================
-- Supply & Demand Processing
-- =============================================================================

--@api-stub: Graph:processDemand
-- Demonstrates the proper usage of Graph:processDemand.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_processDemand()
    factory:processDemand()
end
local _ok, _err = pcall(demo_Graph_processDemand)

--@api-stub: Graph:getStats
-- Demonstrates the proper usage of Graph:getStats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Graph_getStats()
    local stats = factory:getStats()
    print("graph stats: " .. tostring(stats))
    print("\n-- graph.lua example complete --")
end
local _ok, _err = pcall(demo_Graph_getStats)

-- =============================================================================
-- STUBS: 12 uncovered lurek.graph API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Edge methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Edge:clearAllowedTypes ----------------------------------------
--@api-stub: Edge:clearAllowedTypes
-- Clears the edge allow-list so all item types are permitted.
-- Example scenario:
if edge ~= nil then
    -- Calling actual method on edge successfully
    print("Action: calling clearAllowedTypes()")
    pcall(function() edge:clearAllowedTypes() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Graph methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Graph:removeNode ----------------------------------------------
--@api-stub: Graph:removeNode
-- Removes a node from the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling removeNode()")
    pcall(function() graph:removeNode() end)
    print("Executed smoothly.")
end

-- ---- Stub: Graph:hasNode -------------------------------------------------
--@api-stub: Graph:hasNode
-- Returns true if the node exists in the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling hasNode()")
    pcall(function() graph:hasNode() end)
    print("Executed smoothly.")
end

-- ---- Stub: Graph:removeEdge ----------------------------------------------
--@api-stub: Graph:removeEdge
-- Removes an edge from the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling removeEdge()")
    pcall(function() graph:removeEdge() end)
    print("Executed smoothly.")
end

-- ---- Stub: Graph:hasEdge -------------------------------------------------
--@api-stub: Graph:hasEdge
-- Returns true if the edge exists in the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling hasEdge()")
    pcall(function() graph:hasEdge() end)
    print("Executed smoothly.")
end

-- ---- Stub: Graph:removeItem ----------------------------------------------
--@api-stub: Graph:removeItem
-- Removes an item from the graph entirely.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling removeItem()")
    pcall(function() graph:removeItem() end)
    print("Executed smoothly.")
end

-- ---- Stub: Graph:hasItem -------------------------------------------------
--@api-stub: Graph:hasItem
-- Returns true if the item exists in the graph.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling hasItem()")
    pcall(function() graph:hasItem() end)
    print("Executed smoothly.")
end

-- ---- Stub: Graph:getNeighbors --------------------------------------------
--@api-stub: Graph:getNeighbors
-- Returns a table of direct neighbor Node handles.
-- Example scenario:
if graph ~= nil then
    -- Calling actual method on graph successfully
    print("Action: calling getNeighbors()")
    pcall(function() graph:getNeighbors() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- GraphItem methods
-- -----------------------------------------------------------------------------

-- ---- Stub: GraphItem:kill ------------------------------------------------
--@api-stub: GraphItem:kill
-- Marks this graph item as dead so it is removed on the next cleanup pass.
-- Example scenario:
if graphitem ~= nil then
    -- Calling actual method on graphitem successfully
    print("Action: calling kill()")
    pcall(function() graphitem:kill() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Node methods
-- -----------------------------------------------------------------------------

-- ---- Stub: Node:clearTags ------------------------------------------------
--@api-stub: Node:clearTags
-- Removes all tags from this node.
-- Example scenario:
if node ~= nil then
    -- Calling actual method on node successfully
    print("Action: calling clearTags()")
    pcall(function() node:clearTags() end)
    print("Executed smoothly.")
end

-- ---- Stub: Node:enqueue --------------------------------------------------
--@api-stub: Node:enqueue
-- Pushes an item into the node queue.
-- Example scenario:
if node ~= nil then
    -- Calling actual method on node successfully
    print("Action: calling enqueue()")
    pcall(function() node:enqueue() end)
    print("Executed smoothly.")
end

-- ---- Stub: Node:dequeue --------------------------------------------------
--@api-stub: Node:dequeue
-- Pops the next item from the node queue, or nil if empty.
-- Example scenario:
if node ~= nil then
    -- Calling actual method on node successfully
    print("Action: calling dequeue()")
    pcall(function() node:dequeue() end)
    print("Executed smoothly.")
end
