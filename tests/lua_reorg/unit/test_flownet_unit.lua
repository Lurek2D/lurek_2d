-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_flownet_core_unit.lua
do
-- Canonical unit coverage for lurek.flownet / lurek.graph.

local function make_simple_graph()
    local g = lurek.graph.newGraph()
    local n1 = g:addNode("source", -1)
    local n2 = g:addNode("sink", -1)
    local e = g:addEdge(n1, n2)
    return g, n1, n2, e
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
        expect_type("userdata", lurek.graph.newGraph():addNode("factory", 10))
    end)

    -- @covers LGraph:addEdge
    it("addEdge returns an edge handle", function()
        local _, _, _, e = make_simple_graph()
        expect_type("userdata", e)
    end)

    -- @covers LGraph:hasNode
    it("hasNode returns true for an inserted node", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        expect_true(g:hasNode(n))
    end)

    -- @covers LGraph:removeNode
    it("removeNode removes an inserted node", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        expect_true(g:removeNode(n))
    end)

    -- @covers LGraph:getNodeCount
    it("getNodeCount tracks inserted nodes", function()
        local g = lurek.graph.newGraph()
        g:addNode()
        g:addNode()
        expect_equal(2, g:getNodeCount())
    end)

    -- @covers LGraph:getNodes
    it("getNodes returns node handles", function()
        local g = lurek.graph.newGraph()
        g:addNode()
        g:addNode()
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
        expect_equal("LGraph", lurek.graph.newGraph():type())
    end)

    -- @covers LGraph:typeOf
    it("typeOf reports graph inheritance", function()
        expect_true(lurek.graph.newGraph():typeOf("LGraph"))
    end)
end)

-- @describe node handles
describe("node handles", function()
    -- @covers LGraphNode:getType
    it("getType returns the node type", function()
        local n = lurek.graph.newGraph():addNode("factory", 10)
        expect_equal("factory", n:getType())
    end)

    -- @covers LGraphNode:setType
    it("setType updates the node type", function()
        local n = lurek.graph.newGraph():addNode("alpha", 10)
        n:setType("beta")
        expect_equal("beta", n:getType())
    end)

    -- @covers LGraphNode:getCapacity
    it("getCapacity returns node capacity", function()
        local n = lurek.graph.newGraph():addNode("factory", 10)
        expect_equal(10, n:getCapacity())
    end)

    -- @covers LGraphNode:setCapacity
    it("setCapacity updates node capacity", function()
        local n = lurek.graph.newGraph():addNode("factory", 10)
        n:setCapacity(20)
        expect_equal(20, n:getCapacity())
    end)

    -- @covers LGraphNode:getItemCount
    it("getItemCount tracks items on the node", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        local item = g:createItem("ore")
        g:addItem(item, n)
        expect_equal(1, n:getItemCount())
    end)

    -- @covers LGraphNode:isFull
    it("isFull reflects node capacity", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode("factory", 1)
        g:addItem(g:createItem("ore"), n)
        expect_true(n:isFull())
    end)

    -- @covers LGraphNode:isActive
    it("isActive returns the active flag", function()
        expect_true(lurek.graph.newGraph():addNode():isActive())
    end)

    -- @covers LGraphNode:setActive
    it("setActive updates the active flag", function()
        local n = lurek.graph.newGraph():addNode()
        n:setActive(false)
        expect_false(n:isActive())
    end)

    -- @covers LGraphNode:getItems
    it("getItems returns node items as a table", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        g:addItem(g:createItem("ore"), n)
        expect_equal(1, #n:getItems())
    end)

    -- @covers LGraphNode:getOverflowPolicy
    it("getOverflowPolicy returns the default node overflow policy", function()
        expect_equal("reject", lurek.graph.newGraph():addNode():getOverflowPolicy())
    end)

    -- @covers LGraphNode:setOverflowPolicy
    it("setOverflowPolicy updates the node overflow policy", function()
        local n = lurek.graph.newGraph():addNode()
        n:setOverflowPolicy("destroy")
        expect_equal("destroy", n:getOverflowPolicy())
    end)

    -- @covers LGraphNode:getFlowMode
    it("getFlowMode returns the default node flow mode", function()
        expect_equal("passive", lurek.graph.newGraph():addNode():getFlowMode())
    end)

    -- @covers LGraphNode:setFlowMode
    it("setFlowMode updates the node flow mode", function()
        local n = lurek.graph.newGraph():addNode()
        n:setFlowMode("push")
        expect_equal("push", n:getFlowMode())
    end)

    -- @covers LGraphNode:getPushRate
    it("getPushRate returns the default node push rate", function()
        expect_near(1.0, lurek.graph.newGraph():addNode():getPushRate(), 0.001)
    end)

    -- @covers LGraphNode:setPushRate
    it("setPushRate updates the node push rate", function()
        local n = lurek.graph.newGraph():addNode()
        n:setPushRate(5.0)
        expect_near(5.0, n:getPushRate(), 0.001)
    end)

    -- @covers LGraphNode:getPullRate
    it("getPullRate returns the default node pull rate", function()
        expect_near(1.0, lurek.graph.newGraph():addNode():getPullRate(), 0.001)
    end)

    -- @covers LGraphNode:setPullRate
    it("setPullRate updates the node pull rate", function()
        local n = lurek.graph.newGraph():addNode()
        n:setPullRate(3.0)
        expect_near(3.0, n:getPullRate(), 0.001)
    end)

    -- @covers LGraphNode:getPushFilter
    it("getPushFilter returns nil by default and a string after assignment", function()
        local n = lurek.graph.newGraph():addNode()
        expect_nil(n:getPushFilter())
        n:setPushFilter("ore")
        expect_equal("ore", n:getPushFilter())
    end)

    -- @covers LGraphNode:setPushFilter
    it("setPushFilter stores and clears the node push filter", function()
        local n = lurek.graph.newGraph():addNode()
        n:setPushFilter("iron")
        expect_equal("iron", n:getPushFilter())
        n:setPushFilter(nil)
        expect_nil(n:getPushFilter())
    end)

    -- @covers LGraphNode:getPullFilter
    it("getPullFilter returns nil by default and a string after assignment", function()
        local n = lurek.graph.newGraph():addNode()
        expect_nil(n:getPullFilter())
        n:setPullFilter("wood")
        expect_equal("wood", n:getPullFilter())
    end)

    -- @covers LGraphNode:setPullFilter
    it("setPullFilter stores and clears the node pull filter", function()
        local n = lurek.graph.newGraph():addNode()
        n:setPullFilter("coal")
        expect_equal("coal", n:getPullFilter())
        n:setPullFilter(nil)
        expect_nil(n:getPullFilter())
    end)

    -- @covers LGraphNode:getProcessTime
    it("getProcessTime returns the default node processing time", function()
        expect_near(0.0, lurek.graph.newGraph():addNode():getProcessTime(), 0.001)
    end)

    -- @covers LGraphNode:setProcessTime
    it("setProcessTime updates the node processing time", function()
        local n = lurek.graph.newGraph():addNode()
        n:setProcessTime(2.5)
        expect_near(2.5, n:getProcessTime(), 0.001)
    end)

    -- @covers LGraphNode:isQueueEnabled
    it("isQueueEnabled reports the default disabled queue state", function()
        expect_false(lurek.graph.newGraph():addNode():isQueueEnabled())
    end)

    -- @covers LGraphNode:setQueueEnabled
    it("setQueueEnabled updates the node queue toggle", function()
        local n = lurek.graph.newGraph():addNode()
        n:setQueueEnabled(true)
        expect_true(n:isQueueEnabled())
    end)

    -- @covers LGraphNode:getQueueCapacity
    it("getQueueCapacity returns the default unlimited queue sentinel", function()
        expect_equal(-1, lurek.graph.newGraph():addNode():getQueueCapacity())
    end)

    -- @covers LGraphNode:setQueueCapacity
    it("setQueueCapacity updates the queue capacity", function()
        local n = lurek.graph.newGraph():addNode()
        n:setQueueCapacity(4)
        expect_equal(4, n:getQueueCapacity())
    end)

    -- @covers LGraphNode:getQueueSize
    it("getQueueSize tracks queued items", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:setQueueEnabled(true)
        n:enqueue(g:createItem("ore"))
        expect_equal(1, n:getQueueSize())
    end)

    -- @covers LGraphNode:setConversion
    it("setConversion allows update to transform matching node items", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:setConversion("ore", "bar", 1, 1)
        local item = g:createItem("ore")
        g:addItem(item, n)
        g:update(0.0)
        local items = n:getItems()
        expect_equal(1, #items)
        expect_equal("bar", items[1]:getType())
    end)

    -- @covers LGraphNode:clearConversion
    it("clearConversion removes a conversion rule by input type", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:setConversion("ore", "bar", 1, 1)
        expect_true(n:clearConversion("ore"))
        local item = g:createItem("ore")
        g:addItem(item, n)
        g:update(0.0)
        expect_equal("ore", n:getItems()[1]:getType())
    end)

    -- @covers LGraphNode:clearAllConversions
    it("clearAllConversions removes every configured conversion rule", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:setConversion("ore", "bar", 1, 1)
        n:setConversion("wood", "plank", 1, 1)
        n:clearAllConversions()
        local item = g:createItem("ore")
        g:addItem(item, n)
        g:update(0.0)
        expect_equal("ore", n:getItems()[1]:getType())
    end)

    -- @covers LGraphNode:addSupply
    it("addSupply contributes to graph total supply statistics", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:addSupply("iron", 10)
        expect_equal(10, g:getStats().totalSupply)
    end)

    -- @covers LGraphNode:removeSupply
    it("removeSupply removes stored supply from graph statistics", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:addSupply("wood", 5)
        expect_true(n:removeSupply("wood"))
        expect_equal(0, g:getStats().totalSupply)
    end)

    -- @covers LGraphNode:clearSupplies
    it("clearSupplies removes every stored supply entry", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:addSupply("a", 1)
        n:addSupply("b", 2)
        n:clearSupplies()
        expect_equal(0, g:getStats().totalSupply)
    end)

    -- @covers LGraphNode:addDemand
    it("addDemand contributes to graph total demand statistics", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:addDemand("iron", 5, 1)
        expect_equal(5, g:getStats().totalDemand)
    end)

    -- @covers LGraphNode:removeDemand
    it("removeDemand removes stored demand from graph statistics", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:addDemand("coal", 3, 0)
        expect_true(n:removeDemand("coal"))
        expect_equal(0, g:getStats().totalDemand)
    end)

    -- @covers LGraphNode:clearDemands
    it("clearDemands removes every stored demand entry", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:addDemand("x", 1, 0)
        n:addDemand("y", 2, 0)
        n:clearDemands()
        expect_equal(0, g:getStats().totalDemand)
    end)

    -- @covers LGraphNode:addTag
    it("addTag stores a node tag", function()
        local n = lurek.graph.newGraph():addNode()
        n:addTag("hub")
        expect_true(n:hasTag("hub"))
    end)

    -- @covers LGraphNode:hasTag
    it("hasTag reports stored tags", function()
        local n = lurek.graph.newGraph():addNode()
        n:addTag("hub")
        expect_true(n:hasTag("hub"))
    end)

    -- @covers LGraphNode:removeTag
    it("removeTag deletes stored tags", function()
        local n = lurek.graph.newGraph():addNode()
        n:addTag("hub")
        n:removeTag("hub")
        expect_false(n:hasTag("hub"))
    end)

    -- @covers LGraphNode:getTags
    it("getTags returns all node tags", function()
        local n = lurek.graph.newGraph():addNode()
        n:addTag("a")
        n:addTag("b")
        expect_equal(2, #n:getTags())
    end)

    -- @covers LGraphNode:clearTags
    it("clearTags removes all node tags", function()
        local n = lurek.graph.newGraph():addNode()
        n:addTag("a")
        n:clearTags()
        expect_equal(0, #n:getTags())
    end)

    -- @covers LGraphNode:enqueue
    it("enqueue accepts an item for the node queue", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        expect_no_error(function()
            n:enqueue(g:createItem("ore"))
        end)
    end)

    -- @covers LGraphNode:dequeue
    it("dequeue is callable on a node queue", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        n:enqueue(g:createItem("ore"))
        expect_no_error(function()
            n:dequeue()
        end)
    end)

    -- @covers LGraphNode:type
    it("type returns LGraphNode", function()
        expect_equal("LGraphNode", lurek.graph.newGraph():addNode():type())
    end)

    -- @covers LGraphNode:typeOf
    it("typeOf reports node inheritance", function()
        expect_true(lurek.graph.newGraph():addNode():typeOf("LGraphNode"))
    end)
end)

-- @describe edge handles
describe("edge handles", function()
    -- @covers LGraphEdge:getType
    it("getType returns the edge type", function()
        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        local e = g:addEdge(a, b, "pipe")
        expect_equal("pipe", e:getType())
    end)

    -- @covers LGraphEdge:setType
    it("setType updates the edge type", function()
        local g, _, _, e = make_simple_graph()
        e:setType("road")
        expect_equal("road", e:getType())
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
        expect_near(5.0, e:getCapacity(), 0.001)
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
        expect_near(2.0, e:getThroughput(), 0.001)
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
        expect_near(3.0, e:getTravelTime(), 0.001)
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
        expect_near(10.5, e:getWeight(), 0.001)
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
        expect_near(0.5, e:getSpeedModifier(), 0.001)
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
        expect_near(2.0, e:getCooldown(), 0.001)
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
        expect_true(e:isBidirectional())
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
        expect_false(e:isActive())
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
        expect_true(e:isItemTypeAllowed("ore"))
    end)

    -- @covers LGraphEdge:isItemTypeAllowed
    it("isItemTypeAllowed checks the allowed types list", function()
        local _, _, _, e = make_simple_graph()
        e:addAllowedType("ore")
        expect_false(e:isItemTypeAllowed("wood"))
    end)

    -- @covers LGraphEdge:removeAllowedType
    it("removeAllowedType deletes one allowed type", function()
        local _, _, _, e = make_simple_graph()
        e:addAllowedType("ore")
        expect_true(e:removeAllowedType("ore"))
    end)

    -- @covers LGraphEdge:clearAllowedTypes
    it("clearAllowedTypes removes all type restrictions", function()
        local _, _, _, e = make_simple_graph()
        e:addAllowedType("ore")
        e:clearAllowedTypes()
        expect_true(e:isItemTypeAllowed("anything"))
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
        expect_type("userdata", lurek.graph.newGraph():createItem("ore", 5.0))
    end)

    -- @covers LGraphItem:getDecayTime
    it("getDecayTime returns the configured decay time", function()
        expect_near(5.0, lurek.graph.newGraph():createItem("ore", 5.0):getDecayTime(), 0.001)
    end)

    -- @covers LGraphItem:setDecayTime
    it("setDecayTime updates the item decay lifetime", function()
        local item = lurek.graph.newGraph():createItem("ore")
        item:setDecayTime(60.0)
        expect_near(60.0, item:getDecayTime(), 0.001)
    end)

    -- @covers LGraph:addItem
    it("addItem attaches an item to a node", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        local item = g:createItem("ore")
        g:addItem(item, n)
        expect_equal(1, n:getItemCount())
    end)

    -- @covers LGraph:hasItem
    it("hasItem reports whether an item exists in the graph", function()
        local g = lurek.graph.newGraph()
        local item = g:createItem("ore")
        expect_true(g:hasItem(item))
    end)

    -- @covers LGraph:removeItem
    it("removeItem removes an item from the graph", function()
        local g = lurek.graph.newGraph()
        local item = g:createItem("ore")
        g:removeItem(item)
        expect_false(g:hasItem(item))
    end)

    -- @covers LGraph:getItems
    it("getItems returns graph items as a table", function()
        local g = lurek.graph.newGraph()
        g:createItem("a")
        g:createItem("b")
        expect_equal(2, #g:getItems())
    end)

    -- @covers LGraph:getItemCount
    it("getItemCount returns graph item count", function()
        local g = lurek.graph.newGraph()
        g:createItem("a")
        g:createItem("b")
        expect_equal(2, g:getItemCount())
    end)

    -- @covers LGraphItem:getType
    it("item getType returns the item type", function()
        expect_equal("ore", lurek.graph.newGraph():createItem("ore"):getType())
    end)

    -- @covers LGraphItem:setType
    it("item setType updates the item type", function()
        local item = lurek.graph.newGraph():createItem("ore")
        item:setType("refined_ore")
        expect_equal("refined_ore", item:getType())
    end)

    -- @covers LGraphItem:getRemainingLife
    it("getRemainingLife returns decay remaining", function()
        expect_near(5.0, lurek.graph.newGraph():createItem("ore", 5.0):getRemainingLife(), 0.001)
    end)

    -- @covers LGraphItem:isAlive
    it("isAlive returns whether the item is alive", function()
        expect_true(lurek.graph.newGraph():createItem("ore"):isAlive())
    end)

    -- @covers LGraphItem:kill
    it("kill marks an item as dead", function()
        local item = lurek.graph.newGraph():createItem("ore")
        item:kill()
        expect_false(item:isAlive())
    end)

    -- @covers LGraphItem:getPriority
    it("getPriority returns item priority", function()
        expect_type("number", lurek.graph.newGraph():createItem("ore"):getPriority())
    end)

    -- @covers LGraphItem:setPriority
    it("setPriority updates the item priority", function()
        local item = lurek.graph.newGraph():createItem("ore")
        item:setPriority(5)
        expect_equal(5, item:getPriority())
    end)

    -- @covers LGraphItem:getPosition
    it("getPosition returns node-or-edge position data", function()
        local g = lurek.graph.newGraph()
        local n = g:addNode()
        local item = g:createItem("ore")
        g:addItem(item, n)
        expect_not_nil(item:getPosition())
    end)

    -- @covers LGraphItem:type
    it("type returns LGraphItem", function()
        expect_equal("LGraphItem", lurek.graph.newGraph():createItem("ore"):type())
    end)

    -- @covers LGraphItem:typeOf
    it("typeOf reports item inheritance", function()
        expect_true(lurek.graph.newGraph():createItem("ore"):typeOf("LGraphItem"))
    end)

    -- @covers LGraph:sendItem
    it("sendItem moves an item onto an edge", function()
        local g, n1, _, e = make_simple_graph()
        e:setTravelTime(5.0)
        local item = g:createItem("ore")
        g:addItem(item, n1)
        g:sendItem(item, e)
        expect_equal(1, #e:getItemsInTransit())
    end)

    -- @covers LGraph:processDemand
    it("processDemand is callable on a graph", function()
        expect_no_error(function()
            lurek.graph.newGraph():processDemand()
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
        local item = g:createItem("ore")
        g:addItem(item, n1)
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
        expect_no_error(function()
            lurek.graph.newGraph():update(1.0)
        end)
    end)

    -- @covers LGraph:step
    it("step advances graph simulation without error", function()
        expect_no_error(function()
            lurek.graph.newGraph():step()
        end)
    end)

    -- @covers LGraph:on
    it("on registers a graph event callback", function()
        local g = lurek.graph.newGraph()
        expect_no_error(function()
            g:on("itemEnter", function() end)
        end)
    end)

    -- @covers LGraph:getStats
    it("getStats returns graph statistics", function()
        local stats = lurek.graph.newGraph():getStats()
        expect_type("table", stats)
        expect_type("number", stats.nodes)
    end)

    -- @covers LGraph:tickParallel
    it("tickParallel is callable", function()
        expect_no_error(function()
            lurek.graph.newGraph():tickParallel(0.02)
        end)
    end)

    -- @covers LGraph:mst
    it("mst returns a table of spanning tree edges", function()
        local g = lurek.graph.newGraph(true)
        local a = g:addNode()
        local b = g:addNode()
        local c = g:addNode()
        g:addEdge(a, b):setWeight(1.0)
        g:addEdge(b, c):setWeight(2.0)
        g:addEdge(a, c):setWeight(10.0)
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
        local g = lurek.graph.newGraph()
        local ids = g:batchAddNodes(3)
        expect_equal(3, #ids)
    end)

    -- @covers LGraph:batchAddEdges
    it("batchAddEdges inserts multiple edges at once", function()
        local g = lurek.graph.newGraph()
        local ids = g:batchAddNodes(3)
        local edges = g:batchAddEdges({
            { ids[1], ids[2] },
            { ids[2], ids[3] },
        })
        expect_equal(2, #edges)
    end)

    -- @covers LGraph:batchStep
    it("batchStep is callable", function()
        expect_no_error(function()
            lurek.graph.newGraph():batchStep(0.016, 10)
        end)
    end)

    -- @covers LGraph:addEdgeUnchecked
    it("addEdgeUnchecked creates an edge without validation", function()
        local g = lurek.graph.newGraph()
        local a = g:addNode()
        local b = g:addNode()
        expect_type("userdata", g:addEdgeUnchecked(a, b, "pipe"))
    end)
end)
end
-- END test_flownet_core_unit.lua

test_summary()
