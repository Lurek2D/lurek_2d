-- content/examples/flownet.lua
-- Auto-generated from content/examples2/graph_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/flownet.lua


--- Graph Module Part 1: factory, LGraph core (nodes, edges, items, pathfinding, stats)


--@api: lurek.graph.newGraph
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 24)
    local depot = g:addNode("depot", 48)
    g:addEdge(mine, depot, "belt")
    flownet_log("fresh network nodes=" .. g:getNodeCount() .. " edges=" .. g:getEdgeCount())
end

--@api: LGraph:addNode
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local source = g:addNode("warehouse", 100)
    local sink = g:addNode("factory", 40)
    local edge = g:addEdge(source, sink, "road")
    local source_type = source:getType()
    flownet_log("added " .. source_type .. " linked by " .. edge:getType() .. " to " .. sink:getType())
end

--@api: LGraph:addEdge
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode("src")
    local b = g:addNode("dst")
    local e = g:addEdge(a, b, "road")
    example_print_log("edge type = " .. e:type())
end

--@api: LGraph:createItem
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local store = g:addNode("storage", 8)
    local item = g:createItem("ore", 10.0)
    g:addItem(item, store)
    local kind = item:getType()
    flownet_log("created " .. kind .. " for " .. store:getType())
end

--@api: LGraph:addItem
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("storage")
    local item = g:createItem("wood")
    g:addItem(item, n)
    example_print_log("item placed on node")
end

--@api: LGraph:removeNode
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer", 4)
    g:addNode("sink", 4)
    local ok = g:removeNode(n)
    local remaining = g:getNodeCount()
    flownet_log("removed buffer=" .. tostring(ok) .. " remaining=" .. remaining)
end

--@api: LGraph:removeEdge
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local ok = g:removeEdge(e)
    example_print_log("removed edge = " .. tostring(ok))
end

--@api: LGraph:removeItem
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local junkyard = g:addNode("junkyard", 8)
    local item = g:createItem("scrap")
    g:addItem(item, junkyard)
    local ok = g:removeItem(item)
    local remaining = g:getItemCount()
    flownet_log("removed scrap=" .. tostring(ok) .. " items=" .. remaining)
end

--@api: LGraph:hasNode
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("source", 8)
    g:addNode("sink", 8)
    local present = g:hasNode(n)
    local count = g:getNodeCount()
    flownet_log("source present=" .. tostring(present) .. " node count=" .. count)
end

--@api: LGraph:hasEdge
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("has edge = " .. tostring(g:hasEdge(e)))
end

--@api: LGraph:hasItem
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local store = g:addNode("store", 4)
    local item = g:createItem("parcel")
    g:addItem(item, store)
    local present = g:hasItem(item)
    flownet_log("parcel tracked=" .. tostring(present) .. " items=" .. g:getItemCount())
end

--@api: LGraph:getNodeCount
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    g:addNode("mine", 8)
    g:addNode("smelter", 8)
    g:addNode("warehouse", 16)
    local count = g:getNodeCount()
    flownet_log("factory line nodes=" .. count)
end

--@api: LGraph:getEdgeCount
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    example_print_log("edges = " .. g:getEdgeCount())
end

--@api: LGraph:getItemCount
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local storage = g:addNode("storage", 12)
    g:addItem(g:createItem("iron"), storage)
    g:addItem(g:createItem("coal"), storage)
    local count = g:getItemCount()
    flownet_log("inventory items=" .. count)
end

--@api: LGraph:getNodes
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    g:addNode("x")
    g:addNode("y")
    local nodes = g:getNodes()
    example_print_log("node list = " .. #nodes)
end

--@api: LGraph:getEdges
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = g:getEdges()
    example_print_log("edge list = " .. #edges)
end

--@api: LGraph:getItems
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local storage = g:addNode("storage", 12)
    g:addItem(g:createItem("iron"), storage)
    g:addItem(g:createItem("copper"), storage)
    local items = g:getItems()
    local first_type = items[1] and items[1]:getType() or "none"
    flownet_log("item list=" .. #items .. " first=" .. first_type)
end

--@api: LGraph:getNeighbors
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(a, c)
    local neighbors = g:getNeighbors(a)
    example_print_log("neighbors of a = " .. #neighbors)
end

--@api: LGraph:getEdgeBetween
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b, "pipe")
    local e = g:getEdgeBetween(a, b)
    example_print_log("edge between a-b exists = " .. tostring(e ~= nil))
end

--@api: LGraph:findPath
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local result = g:findPath(a, c)
    example_print_log("path found = " .. tostring(result ~= nil))
end

--@api: LGraph:findPathForItem
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local item = g:createItem("cargo")
    local result = g:findPathForItem(item, a, b)
    example_print_log("item path found = " .. tostring(result ~= nil))
end

--@api: LGraph:astar
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local path = g:astar(a, b)
    example_print_log("astar path = " .. tostring(path ~= nil))
end

--@api: LGraph:getDistance
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local d = g:getDistance(a, b)
    example_print_log("distance = " .. tostring(d))
end

--@api: LGraph:getReachable
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local reachable = g:getReachable(a, 5.0)
    example_print_log("reachable = " .. #reachable)
end

--@api: LGraph:getStats
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local stats = g:getStats()
    example_print_log("nodes=" .. stats.nodes .. " edges=" .. stats.edges .. " items=" .. stats.items)
end

--@api: LGraph:hasCycle
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, a)
    example_print_log("has cycle = " .. tostring(g:hasCycle()))
end

--@api: LGraph:isBipartite
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    g:addEdge(a, b)
    example_print_log("bipartite = " .. tostring(g:isBipartite()))
end

--@api: LGraph:topologicalSort
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    local sorted = g:topologicalSort()
    example_print_log("topo sort = " .. tostring(sorted ~= nil))
end

--@api: LGraph:mst
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b, c = g:addNode(), g:addNode(), g:addNode()
    g:addEdge(a, b)
    g:addEdge(b, c)
    g:addEdge(a, c)
    local tree = g:mst()
    example_print_log("MST edges = " .. #tree)
end

--@api: LGraph:colorGraph
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local colors = g:colorGraph()
    example_print_log("coloring type = " .. type(colors))
end

--@api: LGraph:getComponents
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    g:addNode()
    g:addNode()
    local comps = g:getComponents()
    example_print_log("components = " .. #comps)
end

--@api: LGraph:subgraph
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addNode()
    local sub = g:subgraph({a, b})
    example_print_log("subgraph nodes = " .. sub:getNodeCount())
end

--@api: LGraph:sendItem
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e, item = g:addEdge(a, b), g:createItem("package")
    g:addItem(item, a)
    g:sendItem(item, e)
    example_print_log("item sent along edge")
end

--@api: LGraph:on
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    g:on("itemEnter", function(item, node)
        example_print_log("item arrived at node")
    end)
    example_print_log("callback registered")
end

--@api: LGraph:step
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:step()
    flownet_log("step processed " .. g:getNodeCount() .. " nodes")
end

--@api: LGraph:update
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:update(0.016)
    flownet_log("update advanced " .. g:getEdgeCount() .. " edge(s)")
end

--@api: LGraph:tickParallel
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:tickParallel(0.016)
    flownet_log("parallel tick ran on " .. g:getNodeCount() .. " nodes")
end

--@api: LGraph:processDemand
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local factory = g:addNode("factory", 8)
    g:addEdge(mine, factory, "belt")
    g:processDemand()
    flownet_log("demand pass scanned " .. g:getEdgeCount() .. " edge(s)")
end

--@api: LGraph:type
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    g:addNode("depot", 8)
    local type_name = g:type()
    local present = g:hasNode(mine)
    flownet_log(type_name .. " tracks source=" .. tostring(present))
end

--@api: LGraph:typeOf
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local mine = g:addNode("mine", 8)
    local is_graph = g:typeOf("LGraph")
    local is_object = g:typeOf("LObject")
    local node_count = g:getNodeCount()
    flownet_log("typeOf graph=" .. tostring(is_graph) .. " object=" .. tostring(is_object) .. " nodes=" .. node_count)
end

--- Graph Module Part 2: LGraphNode methods

--@api: LGraphNode:getType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addTag("smelting")
    local node_type = n:getType()
    local tags = n:getTags()
    flownet_log("node type=" .. node_type .. " tags=" .. #tags)
end

--@api: LGraphNode:setType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("warehouse")
    n:setCapacity(24)
    local node_type = n:getType()
    flownet_log("retagged node=" .. node_type .. " capacity=" .. n:getCapacity())
end

--@api: LGraphNode:getCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("store", 50)
    n:addTag("buffer")
    local capacity = n:getCapacity()
    local node_type = n:getType()
    flownet_log(node_type .. " capacity=" .. capacity)
end

--@api: LGraphNode:setCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setCapacity(200)
    n:setType("depot")
    local capacity = n:getCapacity()
    flownet_log(n:getType() .. " capacity=" .. capacity)
end

--@api: LGraphNode:getReservedCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local reserved = n:getReservedCapacity()
    local free = n:getAvailableCapacity()
    flownet_log("reserved=" .. reserved .. " free=" .. free)
end

--@api: LGraphNode:getAvailableCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local free = n:getAvailableCapacity()
    local reserved = n:getReservedCapacity()
    flownet_log("warehouse free=" .. free .. " reserved=" .. reserved)
end

--@api: LGraphNode:reserveCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    local ok = n:reserveCapacity("planner-a", 2)
    local reserved = n:getReservedCapacity()
    local free = n:getAvailableCapacity()
    flownet_log("reservation ok=" .. tostring(ok) .. " reserved=" .. reserved .. " free=" .. free)
end

--@api: LGraphNode:releaseCapacityReservation
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    local released = n:releaseCapacityReservation("planner-a", 1)
    example_print_log("released slots = " .. released)
end

--@api: LGraphNode:clearCapacityReservations
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("warehouse", 5)
    n:reserveCapacity("planner-a", 2)
    n:clearCapacityReservations()
    example_print_log("reserved capacity = " .. n:getReservedCapacity())
end

--@api: LGraphNode:isActive
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("router")
    local active = n:isActive()
    local node_type = n:getType()
    flownet_log(node_type .. " active=" .. tostring(active))
end

--@api: LGraphNode:setActive
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setActive(false)
    n:setType("router")
    local active = n:isActive()
    flownet_log(n:getType() .. " active=" .. tostring(active))
end

--@api: LGraphNode:isFull
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("bin", 1)
    local item = g:createItem("crate")
    g:addItem(item, n)
    local full = n:isFull()
    flownet_log("bin full=" .. tostring(full) .. " items=" .. n:getItemCount())
end

--@api: LGraphNode:getItemCount
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("stockpile", 4)
    g:addItem(g:createItem("ore"), n)
    g:addItem(g:createItem("coal"), n)
    local items = n:getItemCount()
    flownet_log("stockpile items=" .. items)
end

--@api: LGraphNode:getItems
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    g:addItem(g:createItem("ore"), n)
    local items = n:getItems()
    example_print_log("node items = " .. #items)
end

--@api: LGraphNode:getEdges
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    g:addEdge(a, b)
    local edges = a:getEdges("both")
    example_print_log("edges = " .. #edges)
end

--@api: LGraphNode:addSupply
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:addSupply("iron", 10)
    n:setPushRate(4)
    local stats = g:getStats()
    flownet_log("mine supply registered on " .. n:getType() .. " nodes=" .. stats.nodes)
end

--@api: LGraphNode:removeSupply
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("wood", 5)
    local ok = n:removeSupply("wood")
    example_print_log("removed supply = " .. tostring(ok))
end

--@api: LGraphNode:clearSupplies
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addSupply("a", 1)
    n:addSupply("b", 2)
    n:clearSupplies()
    example_print_log("supplies cleared")
end

--@api: LGraphNode:addDemand
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:addDemand("iron", 5, 1)
    n:setPullRate(3)
    local stats = g:getStats()
    flownet_log("factory demand registered nodes=" .. stats.nodes .. " edges=" .. stats.edges)
end

--@api: LGraphNode:removeDemand
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("coal", 3)
    local ok = n:removeDemand("coal")
    example_print_log("removed demand = " .. tostring(ok))
end

--@api: LGraphNode:clearDemands
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addDemand("x", 1)
    n:clearDemands()
    example_print_log("demands cleared")
end

--@api: LGraphNode:setConversion
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("smelter")
    n:setConversion("iron_ore", "iron_bar", 2, 1)
    n:setProcessTime(2.5)
    local process_time = n:getProcessTime()
    flownet_log("smelter converts ore -> bar in " .. process_time .. "s")
end

--@api: LGraphNode:clearConversion
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    local ok = n:clearConversion("a")
    example_print_log("cleared conversion = " .. tostring(ok))
end

--@api: LGraphNode:clearAllConversions
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setConversion("a", "b")
    n:setConversion("c", "d")
    n:clearAllConversions()
    example_print_log("all conversions cleared")
end

--@api: LGraphNode:getProcessTime
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("assembler")
    n:setConversion("plate", "gear", 2, 1)
    local process_time = n:getProcessTime()
    flownet_log("assembler process time=" .. process_time)
end

--@api: LGraphNode:setProcessTime
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setProcessTime(2.5)
    n:setConversion("ore", "ingot", 1, 1)
    local process_time = n:getProcessTime()
    flownet_log("custom process time=" .. process_time)
end

--@api: LGraphNode:getFlowMode
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("router")
    n:setPushRate(2)
    local mode = n:getFlowMode()
    flownet_log("router flow mode=" .. mode)
end

--@api: LGraphNode:setFlowMode
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setFlowMode("push")
    n:setPushRate(5)
    local mode = n:getFlowMode()
    flownet_log("node flow mode=" .. mode .. " push=" .. n:getPushRate())
end

--@api: LGraphNode:getPushRate
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("mine")
    n:setFlowMode("push")
    local push_rate = n:getPushRate()
    flownet_log("push rate=" .. push_rate)
end

--@api: LGraphNode:setPushRate
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushRate(5)
    n:setFlowMode("push")
    local push_rate = n:getPushRate()
    flownet_log("configured push rate=" .. push_rate)
end

--@api: LGraphNode:getPullRate
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("factory")
    n:setFlowMode("pull")
    local pull_rate = n:getPullRate()
    flownet_log("pull rate=" .. pull_rate)
end

--@api: LGraphNode:setPullRate
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullRate(3)
    n:setFlowMode("pull")
    local pull_rate = n:getPullRate()
    flownet_log("configured pull rate=" .. pull_rate)
end

--@api: LGraphNode:getPushFilter
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPushFilter()
    n:setType("mine")
    local node_type = n:getType()
    flownet_log(node_type .. " push filter=" .. tostring(f))
end

--@api: LGraphNode:setPushFilter
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPushFilter("iron")
    n:setPushRate(4)
    local filter = n:getPushFilter()
    flownet_log("push filter=" .. tostring(filter) .. " rate=" .. n:getPushRate())
end

--@api: LGraphNode:getPullFilter
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local f = n:getPullFilter()
    n:setType("assembler")
    local node_type = n:getType()
    flownet_log(node_type .. " pull filter=" .. tostring(f))
end

--@api: LGraphNode:setPullFilter
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setPullFilter("wood")
    n:setPullRate(2)
    local filter = n:getPullFilter()
    flownet_log("pull filter=" .. tostring(filter) .. " rate=" .. n:getPullRate())
end

--@api: LGraphNode:getOverflowPolicy
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer", 2)
    n:setQueueEnabled(true)
    local policy = n:getOverflowPolicy() or "reject"
    flownet_log("overflow policy=" .. tostring(policy))
end

--@api: LGraphNode:setOverflowPolicy
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setOverflowPolicy("destroy")
    n:setCapacity(1)
    local policy = n:getOverflowPolicy() or "destroy"
    flownet_log("overflow policy=" .. tostring(policy) .. " cap=" .. n:getCapacity())
end

--@api: LGraphNode:isQueueEnabled
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueCapacity(4)
    local enabled = n:isQueueEnabled()
    flownet_log("queue enabled=" .. tostring(enabled) .. " cap=" .. n:getQueueCapacity())
end

--@api: LGraphNode:setQueueEnabled
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueEnabled(true)
    n:setQueueCapacity(4)
    local enabled = n:isQueueEnabled()
    flownet_log("queue enabled=" .. tostring(enabled) .. " cap=" .. n:getQueueCapacity())
end

--@api: LGraphNode:getQueueCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    local cap = n:getQueueCapacity()
    flownet_log("queue capacity=" .. cap)
end

--@api: LGraphNode:setQueueCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setQueueCapacity(10)
    n:setQueueEnabled(true)
    local cap = n:getQueueCapacity()
    flownet_log("queue capacity=" .. cap)
end

--@api: LGraphNode:getQueueSize
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    local queue_size = n:getQueueSize()
    flownet_log("queue size=" .. queue_size)
end

--@api: LGraphNode:enqueue
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    n:setQueueCapacity(5)
    local item = g:createItem("parcel")
    g:addItem(item, n)
    local queued = n:enqueue(item)
    example_print_log("queue size = " .. n:getQueueSize())
    example_print_log("enqueued = " .. tostring(queued))
end

--@api: LGraphNode:dequeue
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode("buffer")
    n:setQueueEnabled(true)
    n:setQueueCapacity(5)
    local item = g:createItem("box")
    g:addItem(item, n)
    n:enqueue(item)
    local out = n:dequeue()
    example_print_log("queue size = " .. n:getQueueSize())
    example_print_log("dequeued = " .. tostring(out ~= nil))
end

--@api: LGraphNode:addTag
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("important")
    n:setType("hub")
    local tags = n:getTags()
    flownet_log(n:getType() .. " tags=" .. #tags)
end

--@api: LGraphNode:hasTag
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("vip")
    n:addTag("priority")
    local has_vip = n:hasTag("vip")
    flownet_log("has vip=" .. tostring(has_vip) .. " tags=" .. #n:getTags())
end

--@api: LGraphNode:getTags
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("a")
    n:addTag("b")
    local tags = n:getTags()
    example_print_log("tags = " .. #tags)
end

--@api: LGraphNode:removeTag
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("temp")
    local ok = n:removeTag("temp")
    example_print_log("removed = " .. tostring(ok))
end

--@api: LGraphNode:clearTags
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:addTag("x")
    n:addTag("y")
    n:clearTags()
    example_print_log("tags cleared")
end

--@api: LGraphNode:type
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("terminal")
    local type_name = n:type()
    local node_type = n:getType()
    flownet_log(type_name .. " node_type=" .. node_type)
end

--@api: LGraphNode:typeOf
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    n:setType("terminal")
    local is_node = n:typeOf("LGraphNode")
    local is_object = n:typeOf("LObject")
    flownet_log("node typeOf=" .. tostring(is_node) .. " object=" .. tostring(is_object))
end

--- Graph Module Part 3: LGraphEdge and LGraphItem methods

--@api: LGraphEdge:getFrom
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode("src"), g:addNode("dst")
    local e = g:addEdge(a, b)
    local from = e:getFrom()
    example_print_log("from type = " .. from:getType())
end

--@api: LGraphEdge:getTo
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode("target")
    local e = g:addEdge(a, b)
    local to = e:getTo()
    example_print_log("to type = " .. to:getType())
end

--@api: LGraphEdge:getType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b, "conveyor")
    example_print_log("edge type = " .. e:getType())
end

--@api: LGraphEdge:setType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setType("rail")
    example_print_log("edge type = " .. e:getType())
end

--@api: LGraphEdge:getWeight
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("weight = " .. e:getWeight())
end

--@api: LGraphEdge:setWeight
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setWeight(3.5)
    example_print_log("weight = " .. e:getWeight())
end

--@api: LGraphEdge:getTravelTime
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("travel time = " .. e:getTravelTime())
end

--@api: LGraphEdge:setTravelTime
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setTravelTime(5.0)
    example_print_log("travel time = " .. e:getTravelTime())
end

--@api: LGraphEdge:getCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("capacity = " .. e:getCapacity())
end

--@api: LGraphEdge:setCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(10)
    example_print_log("capacity = " .. e:getCapacity())
end

--@api: LGraphEdge:getReservedCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    example_print_log("reserved capacity = " .. e:getReservedCapacity())
end

--@api: LGraphEdge:getAvailableCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    example_print_log("available capacity = " .. e:getAvailableCapacity())
end

--@api: LGraphEdge:reserveCapacity
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    local ok = e:reserveCapacity("planner-a", 2)
    example_print_log("reservation accepted = " .. tostring(ok))
end

--@api: LGraphEdge:releaseCapacityReservation
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    local released = e:releaseCapacityReservation("planner-a", 1)
    example_print_log("released slots = " .. released)
end

--@api: LGraphEdge:clearCapacityReservations
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    e:setCapacity(4)
    e:reserveCapacity("planner-a", 2)
    e:clearCapacityReservations()
    example_print_log("reserved capacity = " .. e:getReservedCapacity())
end

--@api: LGraphEdge:getSpeedModifier
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("speed mod = " .. e:getSpeedModifier())
end

--@api: LGraphEdge:setSpeedModifier
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setSpeedModifier(2.0)
    example_print_log("speed mod = " .. e:getSpeedModifier())
end

--@api: LGraphEdge:getThroughput
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("throughput = " .. e:getThroughput())
end

--@api: LGraphEdge:setThroughput
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setThroughput(100)
    example_print_log("throughput = " .. e:getThroughput())
end

--@api: LGraphEdge:getCooldown
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("cooldown = " .. e:getCooldown())
end

--@api: LGraphEdge:setCooldown
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setCooldown(1.0)
    example_print_log("cooldown = " .. e:getCooldown())
end

--@api: LGraphEdge:isOnCooldown
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("on cooldown = " .. tostring(e:isOnCooldown()))
end

--@api: LGraphEdge:isActive
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("active = " .. tostring(e:isActive()))
end

--@api: LGraphEdge:setActive
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setActive(false)
    example_print_log("active = " .. tostring(e:isActive()))
end

--@api: LGraphEdge:isBidirectional
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("bidi = " .. tostring(e:isBidirectional()))
end

--@api: LGraphEdge:setBidirectional
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:setBidirectional(true)
    example_print_log("bidi = " .. tostring(e:isBidirectional()))
end

--@api: LGraphEdge:addAllowedType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("iron")
    example_print_log("iron allowed")
end

--@api: LGraphEdge:isItemTypeAllowed
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("gold")
    example_print_log("gold allowed = " .. tostring(e:isItemTypeAllowed("gold")))
end

--@api: LGraphEdge:removeAllowedType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("coal")
    local ok = e:removeAllowedType("coal")
    example_print_log("removed = " .. tostring(ok))
end

--@api: LGraphEdge:clearAllowedTypes
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    e:addAllowedType("x")
    e:clearAllowedTypes()
    example_print_log("allow list cleared")
end

--@api: LGraphEdge:getItemsInTransit
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a, b = g:addNode(), g:addNode()
    local e = g:addEdge(a, b)
    local items = e:getItemsInTransit()
    example_print_log("in transit = " .. #items)
end

--@api: LGraphEdge:type
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("type = " .. e:type())
end

--@api: LGraphEdge:typeOf
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode()
    local b = g:addNode()
    local e = g:addEdge(a, b)
    example_print_log("is GraphEdge = " .. tostring(e:typeOf("LGraphEdge")))
end

--@api: LGraphItem:getType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("ore")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local item_type = item:getType()
    flownet_log("item type=" .. item_type .. " on " .. storage:getType())
end

--@api: LGraphItem:setType
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("raw")
    item:setType("processed")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local item_type = item:getType()
    flownet_log("retagged item=" .. item_type)
end

--@api: LGraphItem:getPriority
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("parcel")
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local priority = item:getPriority()
    flownet_log("parcel priority=" .. priority)
end

--@api: LGraphItem:setPriority
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("parcel")
    item:setPriority(5)
    local storage = g:addNode("storage", 4)
    g:addItem(item, storage)
    local priority = item:getPriority()
    flownet_log("rush order priority=" .. priority)
end

--@api: LGraphItem:getDecayTime
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("food", 30.0)
    local pantry = g:addNode("pantry", 6)
    g:addItem(item, pantry)
    local decay = item:getDecayTime()
    flownet_log("food decay=" .. decay)
end

--@api: LGraphItem:setDecayTime
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("fruit")
    item:setDecayTime(60.0)
    local pantry = g:addNode("pantry", 6)
    g:addItem(item, pantry)
    local decay = item:getDecayTime()
    flownet_log("fruit decay=" .. decay)
end

--@api: LGraphItem:getRemainingLife
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("milk", 10.0)
    local cooler = g:addNode("cooler", 6)
    g:addItem(item, cooler)
    local remaining = item:getRemainingLife()
    flownet_log("milk remaining=" .. remaining)
end

--@api: LGraphItem:isAlive
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("drone_part")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local alive = item:isAlive()
    flownet_log("drone part alive=" .. tostring(alive))
end

--@api: LGraphItem:kill
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("waste")
    local dump = g:addNode("dump", 4)
    g:addItem(item, dump)
    item:kill()
    local alive = item:isAlive()
    flownet_log("waste alive after kill=" .. tostring(alive))
end

--@api: LGraphItem:getPosition
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local n = g:addNode()
    local item = g:createItem("box")
    g:addItem(item, n)
    example_print_log("item is on a node = " .. tostring(item:getPosition() ~= nil))
end

--@api: LGraphItem:type
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("box")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local type_name = item:type()
    flownet_log(type_name .. " item_type=" .. item:getType())
end

--@api: LGraphItem:typeOf
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local item = g:createItem("box")
    local store = g:addNode("store", 4)
    g:addItem(item, store)
    local is_item = item:typeOf("LGraphItem")
    flownet_log("item typeOf=" .. tostring(is_item) .. " alive=" .. tostring(item:isAlive()))
end

--@api: LGraph:addEdgeUnchecked
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local a = g:addNode("hub")
    local b = g:addNode("sink")
    local edge = g:addEdgeUnchecked(a, b, "belt")
    example_print_log("edge type = " .. edge:getType())
    example_print_log("edge count = " .. g:getEdgeCount())
end

--@api: LGraph:batchAddNodes
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router", capacity = 4 })
    local nodes = g:getNodes()
    example_print_log("created ids = " .. #ids)
    example_print_log("node count = " .. g:getNodeCount())
    example_print_log("first node type = " .. nodes[1]:getType())
end

--@api: LGraph:batchAddEdges
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(3, { node_type = "router" })
    local edge_ids = g:batchAddEdges({
        { ids[1], ids[2], "lane" },
        { ids[2], ids[3], "lane" },
    })
    example_print_log("created edges = " .. #edge_ids)
    example_print_log("edge count = " .. g:getEdgeCount())
end

--@api: LGraph:batchStep
do
    local function flownet_log(message)
        lurek.log.info("[flownet.example] " .. tostring(message))
    end
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local g = lurek.graph.newGraph()
    local ids = g:batchAddNodes(2, { node_type = "router" })
    g:batchAddEdges({
        { ids[1], ids[2], "lane" },
    })
    g:batchStep(0.25, 4)
    example_print_log("node count = " .. g:getNodeCount())
    example_print_log("edge count = " .. g:getEdgeCount())
end
