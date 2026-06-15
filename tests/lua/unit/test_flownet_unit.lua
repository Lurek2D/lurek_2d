-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_flownet_core_unit.lua
do
-- Canonical unit coverage for lurek.flownet / lurek.graph.

local function call_method(obj, name, ...)
    return obj[name](obj, ...)
end

local function make_graph()
    return lurek.graph.newGraph()
end

local function make_simple_graph(edge_type)
    local g = make_graph()
    local n1 = call_method(g, "addNode", "source", -1)
    local n2 = call_method(g, "addNode", "sink", -1)
    local e = call_method(g, "addEdge", n1, n2, edge_type)
    return g, n1, n2, e
end

local function graph_with_node(node_type, capacity)
    local g = make_graph()
    local n = call_method(g, "addNode", node_type, capacity)
    return g, n
end

local function graph_with_two_nodes()
    local g = make_graph()
    local a = call_method(g, "addNode", "a", -1)
    local b = call_method(g, "addNode", "b", -1)
    return g, a, b
end

local function graph_with_nodes(count)
    local g = make_graph()
    local nodes = {}
    for i = 1, count do
        nodes[i] = call_method(g, "addNode", "node" .. i, -1)
    end
    return g, nodes
end

local function graph_with_item(item_type, decay_time)
    local g = make_graph()
    local item = call_method(g, "createItem", item_type or "ore", decay_time)
    return g, item
end

local function node_with_item()
    local g, n = graph_with_node()
    local item = call_method(g, "createItem", "ore")
    call_method(g, "addItem", item, n)
    return g, n, item
end

local function full_node()
    local g, n = graph_with_node("factory", 1)
    call_method(g, "addItem", call_method(g, "createItem", "ore"), n)
    return g, n
end

local function queued_node_with_item()
    local g, n = graph_with_node()
    call_method(n, "setQueueEnabled", true)
    call_method(n, "enqueue", call_method(g, "createItem", "ore"))
    return g, n
end

local function node_item_types_after_update(g, n)
    call_method(g, "update", 0.0)
    local items = call_method(n, "getItems")
    local types = {}
    for i = 1, #items do
        types[i] = call_method(items[i], "getType")
    end
    return types
end

local function graph_total_supply(g)
    return call_method(g, "getStats").totalSupply
end

local function graph_total_demand(g)
    return call_method(g, "getStats").totalDemand
end

local function node_has_tag(n, tag)
    return call_method(n, "hasTag", tag)
end

local function graph_with_items(count)
    local g = make_graph()
    local items = {}
    for i = 1, count do
        items[i] = call_method(g, "createItem", "item" .. i)
    end
    return g, items
end

local function edge_with_allowed_type()
    local _, _, _, e = make_simple_graph()
    call_method(e, "addAllowedType", "ore")
    return e
end

local function item_with_decay(decay_time)
    local _, item = graph_with_item("ore", decay_time)
    return item
end

local function placed_item_graph()
    local g, n = graph_with_node()
    local item = call_method(g, "createItem", "ore")
    call_method(g, "addItem", item, n)
    return g, n, item
end

local function edge_with_transit_item()
    local g, n1, _, e = make_simple_graph()
    local item = call_method(g, "createItem", "ore")
    call_method(e, "setTravelTime", 5.0)
    call_method(g, "addItem", item, n1)
    call_method(g, "sendItem", item, e)
    return g, e, item
end

-- @describe module entrypoints
describe("module entrypoints", function()
    -- @covers lurek.graph.newGraph
    it("newGraph creates a graph userdata", function()
        expect_type("userdata", lurek.graph.newGraph())
    end)
end)

-- @describe graph core
describe("graph core", function()
    -- @covers LGraph:addNode
    it("addNode returns a node handle", function()
        local g = make_graph()
        expect_type("userdata", g:addNode("factory", 10))
    end)

    -- @covers LGraph:addEdge
    it("addEdge returns an edge handle", function()
        local _, _, _, e = make_simple_graph()
        expect_type("userdata", e)
    end)

    -- @covers LGraph:hasNode
    it("hasNode returns true for an inserted node", function()
        local g, n = graph_with_node()
        expect_true(g:hasNode(n))
    end)

    -- @covers LGraph:removeNode
    it("removeNode removes an inserted node", function()
        local g, n = graph_with_node()
        expect_true(g:removeNode(n))
    end)

    -- @covers LGraph:getNodeCount
    it("getNodeCount tracks inserted nodes", function()
        local g = graph_with_nodes(2)
        expect_equal(2, g:getNodeCount())
    end)

    -- @covers LGraph:getNodes
    it("getNodes returns node handles", function()
        local g = graph_with_nodes(2)
        expect_equal(2, #g:getNodes())
    end)

    -- @covers LGraph:hasEdge
    it("hasEdge returns true for an inserted edge", function()
        local g, _, _, e = make_simple_graph()
        expect_true(g:hasEdge(e))
    end)

    -- @covers LGraph:removeEdge
    it("removeEdge removes an inserted edge", function()
        local g, _, _, e = make_simple_graph()
        expect_true(g:removeEdge(e))
    end)

    -- @covers LGraph:getEdgeCount
    it("getEdgeCount tracks inserted edges", function()
        local g, _, _, _ = make_simple_graph()
        expect_equal(1, g:getEdgeCount())
    end)

    -- @covers LGraph:getEdges
    it("getEdges returns edge handles", function()
        local g, _, _, _ = make_simple_graph()
        expect_equal(1, #g:getEdges())
    end)

    -- @covers LGraphNode:getEdges
    it("node getEdges returns incident edges", function()
        local _, n1, _, _ = make_simple_graph()
        expect_equal(1, #n1:getEdges())
    end)

    -- @covers LGraph:getEdgeBetween
    it("getEdgeBetween returns an existing connection", function()
        local g, n1, n2, _ = make_simple_graph()
        expect_not_nil(g:getEdgeBetween(n1, n2))
    end)

    -- @covers LGraph:getNeighbors
    it("getNeighbors returns neighboring nodes", function()
        local g, n1, _, _ = make_simple_graph()
        expect_true(#g:getNeighbors(n1) >= 1)
    end)

    -- @covers LGraph:type
    it("type returns LGraph", function()
        local g = make_graph()
        expect_equal("LGraph", g:type())
    end)

    -- @covers LGraph:typeOf
    it("typeOf reports graph inheritance", function()
        local g = make_graph()
        expect_true(g:typeOf("LGraph"))
    end)
end)

-- @describe node handles
describe("node handles", function()
    -- @covers LGraphNode:getType
    it("getType returns the node type", function()
        local _, n = graph_with_node("factory", 10)
        expect_equal("factory", n:getType())
    end)

    -- @covers LGraphNode:setType
    it("setType updates the node type", function()
        local _, n = graph_with_node("alpha", 10)
        n:setType("beta")
        expect_equal("beta", call_method(n, "getType"))
    end)

    -- @covers LGraphNode:getCapacity
    it("getCapacity returns node capacity", function()
        local _, n = graph_with_node("factory", 10)
        expect_equal(10, n:getCapacity())
    end)

    -- @covers LGraphNode:setCapacity
    it("setCapacity updates node capacity", function()
        local _, n = graph_with_node("factory", 10)
        n:setCapacity(20)
        expect_equal(20, call_method(n, "getCapacity"))
    end)

    -- @covers LGraphNode:getReservedCapacity
    it("getReservedCapacity reports node planner holds", function()
        local _, n = graph_with_node("factory", 4)
        call_method(n, "reserveCapacity", "planner-a", 2)
        expect_equal(2, n:getReservedCapacity())
    end)

    -- @covers LGraphNode:getAvailableCapacity
    it("getAvailableCapacity subtracts node reservations from free slots", function()
        local g, n = graph_with_node("factory", 4)
        call_method(g, "addItem", call_method(g, "createItem", "ore"), n)
        call_method(n, "reserveCapacity", "planner-a", 2)
        expect_equal(1, n:getAvailableCapacity())
    end)

    -- @covers LGraphNode:reserveCapacity
    it("reserveCapacity records node planner capacity holds", function()
        local _, n = graph_with_node("factory", 3)
        expect_true(n:reserveCapacity("planner-a", 2))
    end)

    -- @covers LGraphNode:releaseCapacityReservation
    it("releaseCapacityReservation frees node planner holds", function()
        local _, n = graph_with_node("factory", 3)
        call_method(n, "reserveCapacity", "planner-a", 2)
        expect_equal(1, n:releaseCapacityReservation("planner-a", 1))
    end)

    -- @covers LGraphNode:clearCapacityReservations
    it("clearCapacityReservations removes all node planner holds", function()
        local _, n = graph_with_node("factory", 3)
        call_method(n, "reserveCapacity", "planner-a", 1)
        call_method(n, "reserveCapacity", "planner-b", 1)
        n:clearCapacityReservations()
        expect_equal(0, call_method(n, "getReservedCapacity"))
    end)

    -- @covers LGraphNode:getItemCount
    it("getItemCount tracks items on the node", function()
        local _, n = node_with_item()
        expect_equal(1, n:getItemCount())
    end)

    -- @covers LGraphNode:isFull
    it("isFull reflects node capacity", function()
        local _, n = full_node()
        expect_true(n:isFull())
    end)

    -- @covers LGraphNode:isActive
    it("isActive returns the active flag", function()
        local _, n = graph_with_node()
        expect_true(n:isActive())
    end)

    -- @covers LGraphNode:setActive
    it("setActive updates the active flag", function()
        local _, n = graph_with_node()
        n:setActive(false)
        expect_false(call_method(n, "isActive"))
    end)

    -- @covers LGraphNode:getItems
    it("getItems returns node items as a table", function()
        local _, n = node_with_item()
        expect_equal(1, #n:getItems())
    end)

    -- @covers LGraphNode:getOverflowPolicy
    it("getOverflowPolicy returns the default node overflow policy", function()
        local _, n = graph_with_node()
        expect_equal("reject", n:getOverflowPolicy())
    end)

    -- @covers LGraphNode:setOverflowPolicy
    it("setOverflowPolicy updates the node overflow policy", function()
        local _, n = graph_with_node()
        n:setOverflowPolicy("destroy")
        expect_equal("destroy", call_method(n, "getOverflowPolicy"))
    end)

    -- @covers LGraphNode:getFlowMode
    it("getFlowMode returns the default node flow mode", function()
        local _, n = graph_with_node()
        expect_equal("passive", n:getFlowMode())
    end)

    -- @covers LGraphNode:setFlowMode
    it("setFlowMode updates the node flow mode", function()
        local _, n = graph_with_node()
        n:setFlowMode("push")
        expect_equal("push", call_method(n, "getFlowMode"))
    end)

    -- @covers LGraphNode:getPushRate
    it("getPushRate returns the default node push rate", function()
        local _, n = graph_with_node()
        expect_near(1.0, n:getPushRate(), 0.001)
    end)

    -- @covers LGraphNode:setPushRate
    it("setPushRate updates the node push rate", function()
        local _, n = graph_with_node()
        n:setPushRate(5.0)
        expect_near(5.0, call_method(n, "getPushRate"), 0.001)
    end)

    -- @covers LGraphNode:getPullRate
    it("getPullRate returns the default node pull rate", function()
        local _, n = graph_with_node()
        expect_near(1.0, n:getPullRate(), 0.001)
    end)

    -- @covers LGraphNode:setPullRate
    it("setPullRate updates the node pull rate", function()
        local _, n = graph_with_node()
        n:setPullRate(3.0)
        expect_near(3.0, call_method(n, "getPullRate"), 0.001)
    end)

    -- @covers LGraphNode:getPushFilter
    it("getPushFilter returns nil by default and a string after assignment", function()
        local _, default_node = graph_with_node()
        local _, filtered_node = graph_with_node()
        call_method(filtered_node, "setPushFilter", "ore")
        expect_nil(default_node:getPushFilter())
        expect_equal("ore", filtered_node:getPushFilter())
    end)

    -- @covers LGraphNode:setPushFilter
    it("setPushFilter stores and clears the node push filter", function()
        local _, n = graph_with_node()
        n:setPushFilter("iron")
        expect_equal("iron", call_method(n, "getPushFilter"))
        n:setPushFilter(nil)
        expect_nil(call_method(n, "getPushFilter"))
    end)

    -- @covers LGraphNode:getPullFilter
    it("getPullFilter returns nil by default and a string after assignment", function()
        local _, default_node = graph_with_node()
        local _, filtered_node = graph_with_node()
        call_method(filtered_node, "setPullFilter", "wood")
        expect_nil(default_node:getPullFilter())
        expect_equal("wood", filtered_node:getPullFilter())
    end)

    -- @covers LGraphNode:setPullFilter
    it("setPullFilter stores and clears the node pull filter", function()
        local _, n = graph_with_node()
        n:setPullFilter("coal")
        expect_equal("coal", call_method(n, "getPullFilter"))
        n:setPullFilter(nil)
        expect_nil(call_method(n, "getPullFilter"))
    end)

    -- @covers LGraphNode:getProcessTime
    it("getProcessTime returns the default node processing time", function()
        local _, n = graph_with_node()
        expect_near(0.0, n:getProcessTime(), 0.001)
    end)

    -- @covers LGraphNode:setProcessTime
    it("setProcessTime updates the node processing time", function()
        local _, n = graph_with_node()
        n:setProcessTime(2.5)
        expect_near(2.5, call_method(n, "getProcessTime"), 0.001)
    end)

    -- @covers LGraphNode:isQueueEnabled
    it("isQueueEnabled reports the default disabled queue state", function()
        local _, n = graph_with_node()
        expect_false(n:isQueueEnabled())
    end)

    -- @covers LGraphNode:setQueueEnabled
    it("setQueueEnabled updates the node queue toggle", function()
        local _, n = graph_with_node()
        n:setQueueEnabled(true)
        expect_true(call_method(n, "isQueueEnabled"))
    end)

    -- @covers LGraphNode:getQueueCapacity
    it("getQueueCapacity returns the default unlimited queue sentinel", function()
        local _, n = graph_with_node()
        expect_equal(-1, n:getQueueCapacity())
    end)

    -- @covers LGraphNode:setQueueCapacity
    it("setQueueCapacity updates the queue capacity", function()
        local _, n = graph_with_node()
        n:setQueueCapacity(4)
        expect_equal(4, call_method(n, "getQueueCapacity"))
    end)

    -- @covers LGraphNode:getQueueSize
    it("getQueueSize tracks queued items", function()
        local _, n = queued_node_with_item()
        expect_equal(1, n:getQueueSize())
    end)

    -- @covers LGraphNode:setConversion
    it("setConversion allows update to transform matching node items", function()
        local g, n = graph_with_node()
        n:setConversion("ore", "bar", 1, 1)
        call_method(g, "addItem", call_method(g, "createItem", "ore"), n)
        local item_types = node_item_types_after_update(g, n)
        expect_equal(1, #item_types)
        expect_equal("bar", item_types[1])
    end)

    -- @covers LGraphNode:clearConversion
    it("clearConversion removes a conversion rule by input type", function()
        local g, n = graph_with_node()
        call_method(n, "setConversion", "ore", "bar", 1, 1)
        expect_true(n:clearConversion("ore"))
        call_method(g, "addItem", call_method(g, "createItem", "ore"), n)
        expect_equal("ore", node_item_types_after_update(g, n)[1])
    end)

    -- @covers LGraphNode:clearAllConversions
    it("clearAllConversions removes every configured conversion rule", function()
        local g, n = graph_with_node()
        call_method(n, "setConversion", "ore", "bar", 1, 1)
        call_method(n, "setConversion", "wood", "plank", 1, 1)
        n:clearAllConversions()
        call_method(g, "addItem", call_method(g, "createItem", "ore"), n)
        expect_equal("ore", node_item_types_after_update(g, n)[1])
    end)

    -- @covers LGraphNode:addSupply
    it("addSupply contributes to graph total supply statistics", function()
        local g, n = graph_with_node()
        n:addSupply("iron", 10)
        expect_equal(10, graph_total_supply(g))
    end)

    -- @covers LGraphNode:removeSupply
    it("removeSupply removes stored supply from graph statistics", function()
        local g, n = graph_with_node()
        call_method(n, "addSupply", "wood", 5)
        expect_true(n:removeSupply("wood"))
        expect_equal(0, graph_total_supply(g))
    end)

    -- @covers LGraphNode:clearSupplies
    it("clearSupplies removes every stored supply entry", function()
        local g, n = graph_with_node()
        call_method(n, "addSupply", "a", 1)
        call_method(n, "addSupply", "b", 2)
        n:clearSupplies()
        expect_equal(0, graph_total_supply(g))
    end)

    -- @covers LGraphNode:addDemand
    it("addDemand contributes to graph total demand statistics", function()
        local g, n = graph_with_node()
        n:addDemand("iron", 5, 1)
        expect_equal(5, graph_total_demand(g))
    end)

    -- @covers LGraphNode:removeDemand
    it("removeDemand removes stored demand from graph statistics", function()
        local g, n = graph_with_node()
        call_method(n, "addDemand", "coal", 3, 0)
        expect_true(n:removeDemand("coal"))
        expect_equal(0, graph_total_demand(g))
    end)

    -- @covers LGraphNode:clearDemands
    it("clearDemands removes every stored demand entry", function()
        local g, n = graph_with_node()
        call_method(n, "addDemand", "x", 1, 0)
        call_method(n, "addDemand", "y", 2, 0)
        n:clearDemands()
        expect_equal(0, graph_total_demand(g))
    end)

    -- @covers LGraphNode:addTag
    it("addTag stores a node tag", function()
        local _, n = graph_with_node()
        n:addTag("hub")
        expect_true(node_has_tag(n, "hub"))
    end)

    -- @covers LGraphNode:hasTag
    it("hasTag reports stored tags", function()
        local _, n = graph_with_node()
        call_method(n, "addTag", "hub")
        expect_true(n:hasTag("hub"))
    end)

    -- @covers LGraphNode:removeTag
    it("removeTag deletes stored tags", function()
        local _, n = graph_with_node()
        call_method(n, "addTag", "hub")
        n:removeTag("hub")
        expect_false(node_has_tag(n, "hub"))
    end)

    -- @covers LGraphNode:getTags
    it("getTags returns all node tags", function()
        local _, n = graph_with_node()
        call_method(n, "addTag", "a")
        call_method(n, "addTag", "b")
        expect_equal(2, #n:getTags())
    end)

    -- @covers LGraphNode:clearTags
    it("clearTags removes all node tags", function()
        local _, n = graph_with_node()
        call_method(n, "addTag", "a")
        n:clearTags()
        expect_equal(0, #call_method(n, "getTags"))
    end)

    -- @covers LGraphNode:enqueue
    it("enqueue accepts an item for the node queue", function()
        local g, n = graph_with_node()
        expect_no_error(function()
            n:enqueue(call_method(g, "createItem", "ore"))
        end)
    end)

    -- @covers LGraphNode:dequeue
    it("dequeue is callable on a node queue", function()
        local _, n = queued_node_with_item()
        expect_no_error(function()
            n:dequeue()
        end)
    end)

    -- @covers LGraphNode:type
    it("type returns LGraphNode", function()
        local _, n = graph_with_node()
        expect_equal("LGraphNode", n:type())
    end)

    -- @covers LGraphNode:typeOf
    it("typeOf reports node inheritance", function()
        local _, n = graph_with_node()
        expect_true(n:typeOf("LGraphNode"))
    end)
end)

-- @describe edge handles
describe("edge handles", function()
    -- @covers LGraphEdge:getType
    it("getType returns the edge type", function()
        local _, _, _, e = make_simple_graph("pipe")
        expect_equal("pipe", e:getType())
    end)

    -- @covers LGraphEdge:setType
    it("setType updates the edge type", function()
        local g, _, _, e = make_simple_graph()
        e:setType("road")
        expect_equal("road", call_method(e, "getType"))
    end)

    -- @covers LGraphEdge:getFrom
    it("getFrom returns the source node", function()
        local _, n1, _, e = make_simple_graph()
        expect_not_nil(e:getFrom())
    end)

    -- @covers LGraphEdge:getTo
    it("getTo returns the destination node", function()
        local _, _, n2, e = make_simple_graph()
        expect_not_nil(e:getTo())
    end)

    -- @covers LGraphEdge:getCapacity
    it("getCapacity returns edge capacity", function()
        local _, _, _, e = make_simple_graph()
        expect_type("number", e:getCapacity())
    end)

    -- @covers LGraphEdge:setCapacity
    it("setCapacity updates edge capacity", function()
        local _, _, _, e = make_simple_graph()
        e:setCapacity(5.0)
        expect_near(5.0, call_method(e, "getCapacity"), 0.001)
    end)

    -- @covers LGraphEdge:getReservedCapacity
    it("getReservedCapacity reports edge planner holds", function()
        local _, _, _, e = make_simple_graph()
        call_method(e, "setCapacity", 4)
        call_method(e, "reserveCapacity", "planner-a", 2)
        expect_equal(2, e:getReservedCapacity())
    end)

    -- @covers LGraphEdge:getAvailableCapacity
    it("getAvailableCapacity subtracts edge reservations from free slots", function()
        local _, _, _, e = make_simple_graph()
        call_method(e, "setCapacity", 4)
        call_method(e, "reserveCapacity", "planner-a", 3)
        expect_equal(1, e:getAvailableCapacity())
    end)

    -- @covers LGraphEdge:reserveCapacity
    it("reserveCapacity records edge planner capacity holds", function()
        local _, _, _, e = make_simple_graph()
        call_method(e, "setCapacity", 3)
        expect_true(e:reserveCapacity("planner-a", 2))
    end)

    -- @covers LGraphEdge:releaseCapacityReservation
    it("releaseCapacityReservation frees edge planner holds", function()
        local _, _, _, e = make_simple_graph()
        call_method(e, "setCapacity", 3)
        call_method(e, "reserveCapacity", "planner-a", 2)
        expect_equal(1, e:releaseCapacityReservation("planner-a", 1))
    end)

    -- @covers LGraphEdge:clearCapacityReservations
    it("clearCapacityReservations removes all edge planner holds", function()
        local _, _, _, e = make_simple_graph()
        call_method(e, "setCapacity", 3)
        call_method(e, "reserveCapacity", "planner-a", 1)
        call_method(e, "reserveCapacity", "planner-b", 1)
        e:clearCapacityReservations()
        expect_equal(0, call_method(e, "getReservedCapacity"))
    end)

    -- @covers LGraphEdge:getThroughput
    it("getThroughput returns throughput", function()
        local _, _, _, e = make_simple_graph()
        expect_type("number", e:getThroughput())
    end)

    -- @covers LGraphEdge:setThroughput
    it("setThroughput updates throughput", function()
        local _, _, _, e = make_simple_graph()
        e:setThroughput(2.0)
        expect_near(2.0, call_method(e, "getThroughput"), 0.001)
    end)

    -- @covers LGraphEdge:getTravelTime
    it("getTravelTime returns edge travel time", function()
        local _, _, _, e = make_simple_graph()
        expect_type("number", e:getTravelTime())
    end)

    -- @covers LGraphEdge:setTravelTime
    it("setTravelTime updates edge travel time", function()
        local _, _, _, e = make_simple_graph()
        e:setTravelTime(3.0)
        expect_near(3.0, call_method(e, "getTravelTime"), 0.001)
    end)

    -- @covers LGraphEdge:getWeight
    it("getWeight returns edge weight", function()
        local _, _, _, e = make_simple_graph()
        expect_type("number", e:getWeight())
    end)

    -- @covers LGraphEdge:setWeight
    it("setWeight updates edge weight", function()
        local _, _, _, e = make_simple_graph()
        e:setWeight(10.5)
        expect_near(10.5, call_method(e, "getWeight"), 0.001)
    end)

    -- @covers LGraphEdge:getSpeedModifier
    it("getSpeedModifier returns edge speed modifier", function()
        local _, _, _, e = make_simple_graph()
        expect_type("number", e:getSpeedModifier())
    end)

    -- @covers LGraphEdge:setSpeedModifier
    it("setSpeedModifier updates speed modifier", function()
        local _, _, _, e = make_simple_graph()
        e:setSpeedModifier(0.5)
        expect_near(0.5, call_method(e, "getSpeedModifier"), 0.001)
    end)

    -- @covers LGraphEdge:getCooldown
    it("getCooldown returns edge cooldown", function()
        local _, _, _, e = make_simple_graph()
        expect_type("number", e:getCooldown())
    end)

    -- @covers LGraphEdge:setCooldown
    it("setCooldown updates edge cooldown", function()
        local _, _, _, e = make_simple_graph()
        e:setCooldown(2.0)
        expect_near(2.0, call_method(e, "getCooldown"), 0.001)
    end)

    -- @covers LGraphEdge:isBidirectional
    it("isBidirectional returns whether the edge is bidirectional", function()
        local _, _, _, e = make_simple_graph()
        expect_type("boolean", e:isBidirectional())
    end)

    -- @covers LGraphEdge:setBidirectional
    it("setBidirectional updates the bidirectional flag", function()
        local _, _, _, e = make_simple_graph()
        e:setBidirectional(true)
        expect_true(call_method(e, "isBidirectional"))
    end)

    -- @covers LGraphEdge:isActive
    it("isActive returns the edge active flag", function()
        local _, _, _, e = make_simple_graph()
        expect_type("boolean", e:isActive())
    end)

    -- @covers LGraphEdge:setActive
    it("setActive updates the edge active flag", function()
        local _, _, _, e = make_simple_graph()
        e:setActive(false)
        expect_false(call_method(e, "isActive"))
    end)

    -- @covers LGraphEdge:getItemsInTransit
    it("getItemsInTransit returns a table of in-flight items", function()
        local _, _, _, e = make_simple_graph()
        expect_type("table", e:getItemsInTransit())
    end)

    -- @covers LGraphEdge:addAllowedType
    it("addAllowedType stores an allowed item type", function()
        local _, _, _, e = make_simple_graph()
        e:addAllowedType("ore")
        expect_true(call_method(e, "isItemTypeAllowed", "ore"))
    end)

    -- @covers LGraphEdge:isItemTypeAllowed
    it("isItemTypeAllowed checks the allowed types list", function()
        local e = edge_with_allowed_type()
        expect_false(e:isItemTypeAllowed("wood"))
    end)

    -- @covers LGraphEdge:removeAllowedType
    it("removeAllowedType deletes one allowed type", function()
        local e = edge_with_allowed_type()
        expect_true(e:removeAllowedType("ore"))
    end)

    -- @covers LGraphEdge:clearAllowedTypes
    it("clearAllowedTypes removes all type restrictions", function()
        local e = edge_with_allowed_type()
        e:clearAllowedTypes()
        expect_true(call_method(e, "isItemTypeAllowed", "anything"))
    end)

    -- @covers LGraphEdge:isOnCooldown
    it("isOnCooldown returns whether the edge is cooling down", function()
        local _, _, _, e = make_simple_graph()
        expect_type("boolean", e:isOnCooldown())
    end)

    -- @covers LGraphEdge:type
    it("type returns LGraphEdge", function()
        local _, _, _, e = make_simple_graph()
        expect_equal("LGraphEdge", e:type())
    end)

    -- @covers LGraphEdge:typeOf
    it("typeOf reports edge inheritance", function()
        local _, _, _, e = make_simple_graph()
        expect_true(e:typeOf("LGraphEdge"))
    end)
end)

-- @describe items and algorithms
describe("items and algorithms", function()
    -- @covers LGraph:createItem
    it("createItem returns an item handle", function()
        local g = make_graph()
        expect_type("userdata", g:createItem("ore", 5.0))
    end)

    -- @covers LGraphItem:getDecayTime
    it("getDecayTime returns the configured decay time", function()
        local item = item_with_decay(5.0)
        expect_near(5.0, item:getDecayTime(), 0.001)
    end)

    -- @covers LGraphItem:setDecayTime
    it("setDecayTime updates the item decay lifetime", function()
        local item = item_with_decay()
        item:setDecayTime(60.0)
        expect_near(60.0, call_method(item, "getDecayTime"), 0.001)
    end)

    -- @covers LGraph:addItem
    it("addItem attaches an item to a node", function()
        local g, n = graph_with_node()
        local item = call_method(g, "createItem", "ore")
        g:addItem(item, n)
        expect_equal(1, call_method(n, "getItemCount"))
    end)

    -- @covers LGraph:hasItem
    it("hasItem reports whether an item exists in the graph", function()
        local g, item = graph_with_item("ore")
        expect_true(g:hasItem(item))
    end)

    -- @covers LGraph:removeItem
    it("removeItem removes an item from the graph", function()
        local g, item = graph_with_item("ore")
        g:removeItem(item)
        expect_false(call_method(g, "hasItem", item))
    end)

    -- @covers LGraph:getItems
    it("getItems returns graph items as a table", function()
        local g = graph_with_items(2)
        expect_equal(2, #g:getItems())
    end)

    -- @covers LGraph:getItemCount
    it("getItemCount returns graph item count", function()
        local g = graph_with_items(2)
        expect_equal(2, g:getItemCount())
    end)

    -- @covers LGraphItem:getType
    it("item getType returns the item type", function()
        local _, item = graph_with_item("ore")
        expect_equal("ore", item:getType())
    end)

    -- @covers LGraphItem:setType
    it("item setType updates the item type", function()
        local _, item = graph_with_item("ore")
        item:setType("refined_ore")
        expect_equal("refined_ore", call_method(item, "getType"))
    end)

    -- @covers LGraphItem:getRemainingLife
    it("getRemainingLife returns decay remaining", function()
        local item = item_with_decay(5.0)
        expect_near(5.0, item:getRemainingLife(), 0.001)
    end)

    -- @covers LGraphItem:isAlive
    it("isAlive returns whether the item is alive", function()
        local _, item = graph_with_item("ore")
        expect_true(item:isAlive())
    end)

    -- @covers LGraphItem:kill
    it("kill marks an item as dead", function()
        local _, item = graph_with_item("ore")
        item:kill()
        expect_false(call_method(item, "isAlive"))
    end)

    -- @covers LGraphItem:getPriority
    it("getPriority returns item priority", function()
        local _, item = graph_with_item("ore")
        expect_type("number", item:getPriority())
    end)

    -- @covers LGraphItem:setPriority
    it("setPriority updates the item priority", function()
        local _, item = graph_with_item("ore")
        item:setPriority(5)
        expect_equal(5, call_method(item, "getPriority"))
    end)

    -- @covers LGraphItem:getPosition
    it("getPosition returns node-or-edge position data", function()
        local _, _, item = placed_item_graph()
        expect_not_nil(item:getPosition())
    end)

    -- @covers LGraphItem:type
    it("type returns LGraphItem", function()
        local _, item = graph_with_item("ore")
        expect_equal("LGraphItem", item:type())
    end)

    -- @covers LGraphItem:typeOf
    it("typeOf reports item inheritance", function()
        local _, item = graph_with_item("ore")
        expect_true(item:typeOf("LGraphItem"))
    end)

    -- @covers LGraph:sendItem
    it("sendItem moves an item onto an edge", function()
        local g, n1, _, e = make_simple_graph()
        local item = call_method(g, "createItem", "ore")
        call_method(e, "setTravelTime", 5.0)
        call_method(g, "addItem", item, n1)
        g:sendItem(item, e)
        expect_equal(1, #call_method(e, "getItemsInTransit"))
    end)

    -- @covers LGraph:processDemand
    it("processDemand is callable on a graph", function()
        local g = make_graph()
        expect_no_error(function()
            g:processDemand()
        end)
    end)

    -- @covers LGraph:findPath
    it("findPath returns a path between connected nodes", function()
        local g, n1, n2, _ = make_simple_graph()
        local path = g:findPath(n1, n2)
        expect_not_nil(path)
    end)

    -- @covers LGraph:findPathForItem
    it("findPathForItem returns a path for an item", function()
        local g, n1, n2, _ = make_simple_graph()
        local item = call_method(g, "createItem", "ore")
        call_method(g, "addItem", item, n1)
        expect_not_nil(g:findPathForItem(item, n1, n2))
    end)

    -- @covers LGraph:getDistance
    it("getDistance returns a number for connected nodes", function()
        local g, n1, n2, _ = make_simple_graph()
        expect_type("number", g:getDistance(n1, n2))
    end)

    -- @covers LGraph:getReachable
    it("getReachable returns reachable nodes", function()
        local g, n1, _, _ = make_simple_graph()
        expect_true(#g:getReachable(n1) >= 1)
    end)

    -- @covers LGraph:hasCycle
    it("hasCycle returns false for a simple acyclic graph", function()
        local g, _, _, _ = make_simple_graph()
        expect_false(g:hasCycle())
    end)

    -- @covers LGraph:topologicalSort
    it("topologicalSort returns node order for an acyclic graph", function()
        local g, _, _, _ = make_simple_graph()
        local sorted = g:topologicalSort()
        expect_not_nil(sorted)
        expect_true(#sorted >= 2)
    end)

    -- @covers LGraph:getComponents
    it("getComponents returns connected components", function()
        local g, _, _, _ = make_simple_graph()
        expect_equal(1, #g:getComponents())
    end)

    -- @covers LGraph:subgraph
    it("subgraph returns a graph with selected nodes", function()
        local g, n1, n2, _ = make_simple_graph()
        local sub = g:subgraph({ n1, n2 })
        expect_equal(2, sub:getNodeCount())
    end)

    -- @covers LGraph:update
    it("update advances graph simulation without error", function()
        local g = make_graph()
        expect_no_error(function()
            g:update(1.0)
        end)
    end)

    -- @covers LGraph:step
    it("step advances graph simulation without error", function()
        local g = make_graph()
        expect_no_error(function()
            g:step()
        end)
    end)

    -- @covers LGraph:on
    it("on registers a graph event callback", function()
        local g = make_graph()
        expect_no_error(function()
            g:on("itemEnter", function() end)
        end)
    end)

    -- @covers LGraph:getStats
    it("getStats returns graph statistics", function()
        local g = make_graph()
        local stats = g:getStats()
        expect_type("table", stats)
        expect_type("number", stats.nodes)
    end)

    -- @covers LGraph:tickParallel
    it("tickParallel is callable", function()
        local g = make_graph()
        expect_no_error(function()
            g:tickParallel(0.02)
        end)
    end)

    -- @covers LGraph:mst
    it("mst returns a table of spanning tree edges", function()
        local g, nodes = graph_with_nodes(3)
        call_method(call_method(g, "addEdge", nodes[1], nodes[2]), "setWeight", 1.0)
        call_method(call_method(g, "addEdge", nodes[2], nodes[3]), "setWeight", 2.0)
        call_method(call_method(g, "addEdge", nodes[1], nodes[3]), "setWeight", 10.0)
        expect_type("table", g:mst())
    end)

    -- @covers LGraph:colorGraph
    it("colorGraph returns node colors", function()
        local g, _, _, _ = make_simple_graph()
        expect_type("table", g:colorGraph())
    end)

    -- @covers LGraph:isBipartite
    it("isBipartite returns a boolean", function()
        local g, _, _, _ = make_simple_graph()
        expect_type("boolean", g:isBipartite())
    end)

    -- @covers LGraph:astar
    it("astar returns a path table or nil", function()
        local g, n1, n2, _ = make_simple_graph()
        local path = g:astar(n1, n2)
        expect_true(path == nil or type(path) == "table")
    end)

    -- @covers LGraph:batchAddNodes
    it("batchAddNodes inserts multiple nodes at once", function()
        local g = make_graph()
        local ids = g:batchAddNodes(3)
        expect_equal(3, #ids)
    end)

    -- @covers LGraph:batchAddEdges
    it("batchAddEdges inserts multiple edges at once", function()
        local g = make_graph()
        local ids = call_method(g, "batchAddNodes", 3)
        local edges = g:batchAddEdges({
            { ids[1], ids[2] },
            { ids[2], ids[3] },
        })
        expect_equal(2, #edges)
    end)

    -- @covers LGraph:batchStep
    it("batchStep is callable", function()
        local g = make_graph()
        expect_no_error(function()
            g:batchStep(0.016, 10)
        end)
    end)

    -- @covers LGraph:addEdgeUnchecked
    it("addEdgeUnchecked creates an edge without validation", function()
        local g, a, b = graph_with_two_nodes()
        expect_type("userdata", g:addEdgeUnchecked(a, b, "pipe"))
    end)
end)
end
-- END test_flownet_core_unit.lua

test_summary()
