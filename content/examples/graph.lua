-- content/examples/graph.lua
-- love2d-style usage snippets for the lurek.graph API (111 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/graph.lua

-- ── lurek.graph.* functions ──

--@api-stub: lurek.graph.newGraph
-- Creates a new empty directed graph for item flow simulation.
-- Build once at startup; reuse across frames.
local graph = lurek.graph.newGraph()
print("created", graph)
return graph

-- ── GraphItem methods ──

--@api-stub: GraphItem:getType
-- Returns the item type string.
-- Cheap to call; safe inside callbacks.
local graphItem = lurek.graph.newGraphItem()  -- or your existing handle
local value = graphItem:getType()
print("GraphItem:getType ->", value)

--@api-stub: GraphItem:setType
-- Sets the item type string.
-- Apply at startup or in response to user input.
local graphItem = lurek.graph.newGraphItem()
graphItem:setType(t)
print("GraphItem:setType applied")

--@api-stub: GraphItem:getDecayTime
-- Returns the decay time in seconds (-1 = immortal).
-- Cheap to call; safe inside callbacks.
local graphItem = lurek.graph.newGraphItem()  -- or your existing handle
local value = graphItem:getDecayTime()
print("GraphItem:getDecayTime ->", value)

--@api-stub: GraphItem:setDecayTime
-- Sets the decay time in seconds (-1 = immortal).
-- Apply at startup or in response to user input.
local graphItem = lurek.graph.newGraphItem()
graphItem:setDecayTime(t)
print("GraphItem:setDecayTime applied")

--@api-stub: GraphItem:getRemainingLife
-- Returns the remaining life in seconds.
-- Cheap to call; safe inside callbacks.
local graphItem = lurek.graph.newGraphItem()  -- or your existing handle
local value = graphItem:getRemainingLife()
print("GraphItem:getRemainingLife ->", value)

--@api-stub: GraphItem:isAlive
-- Returns true if the item is alive.
-- Use as a guard inside lurek.update or event handlers.
local graphItem = lurek.graph.newGraphItem()
if graphItem:isAlive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: GraphItem:kill
-- Marks this graph item as dead so it is removed on the next cleanup pass.
-- See the module spec for detailed semantics.
local graphItem = lurek.graph.newGraphItem()
graphItem:kill()
print("GraphItem:kill done")

--@api-stub: GraphItem:getPriority
-- Returns the item priority.
-- Cheap to call; safe inside callbacks.
local graphItem = lurek.graph.newGraphItem()  -- or your existing handle
local value = graphItem:getPriority()
print("GraphItem:getPriority ->", value)

--@api-stub: GraphItem:setPriority
-- Sets the scheduling priority; higher values are processed before lower ones.
-- Apply at startup or in response to user input.
local graphItem = lurek.graph.newGraphItem()
graphItem:setPriority(p)
print("GraphItem:setPriority applied")

--@api-stub: GraphItem:getPosition
-- Returns the item position: node userdata if at a node, (edge, progress).
-- Cheap to call; safe inside callbacks.
local graphItem = lurek.graph.newGraphItem()  -- or your existing handle
local value = graphItem:getPosition()
print("GraphItem:getPosition ->", value)

--@api-stub: GraphItem:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local graphItem = lurek.graph.newGraphItem()
graphItem:type()
print("GraphItem:type done")

--@api-stub: GraphItem:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local graphItem = lurek.graph.newGraphItem()
graphItem:typeOf("main")
print("GraphItem:typeOf done")

-- ── Edge methods ──

--@api-stub: Edge:getType
-- Returns the edge type string.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getType()
print("Edge:getType ->", value)

--@api-stub: Edge:setType
-- Sets the edge type string.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setType(t)
print("Edge:setType applied")

--@api-stub: Edge:getFrom
-- Returns the source node handle.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getFrom()
print("Edge:getFrom ->", value)

--@api-stub: Edge:getTo
-- Returns the destination node handle.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getTo()
print("Edge:getTo ->", value)

--@api-stub: Edge:getCapacity
-- Returns the edge capacity (-1 = unlimited).
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getCapacity()
print("Edge:getCapacity ->", value)

--@api-stub: Edge:setCapacity
-- Sets the edge capacity (-1 = unlimited).
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setCapacity(c)
print("Edge:setCapacity applied")

--@api-stub: Edge:getThroughput
-- Returns items per second this edge can transfer.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getThroughput()
print("Edge:getThroughput ->", value)

--@api-stub: Edge:setThroughput
-- Sets items per second this edge can transfer.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setThroughput(t)
print("Edge:setThroughput applied")

--@api-stub: Edge:getTravelTime
-- Returns the travel time in seconds for items on this edge.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getTravelTime()
print("Edge:getTravelTime ->", value)

--@api-stub: Edge:setTravelTime
-- Sets the travel time in seconds for items on this edge.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setTravelTime(t)
print("Edge:setTravelTime applied")

--@api-stub: Edge:getWeight
-- Returns the pathfinding weight of this edge.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getWeight()
print("Edge:getWeight ->", value)

--@api-stub: Edge:setWeight
-- Sets the pathfinding weight of this edge.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setWeight(64)
print("Edge:setWeight applied")

--@api-stub: Edge:getSpeedModifier
-- Returns the speed modifier applied to items in transit.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getSpeedModifier()
print("Edge:getSpeedModifier ->", value)

--@api-stub: Edge:setSpeedModifier
-- Sets the speed modifier applied to items in transit.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setSpeedModifier(m)
print("Edge:setSpeedModifier applied")

--@api-stub: Edge:getCooldown
-- Returns the cooldown duration in seconds.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getCooldown()
print("Edge:getCooldown ->", value)

--@api-stub: Edge:setCooldown
-- Sets the cooldown duration in seconds.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setCooldown(c)
print("Edge:setCooldown applied")

--@api-stub: Edge:isOnCooldown
-- Returns true if the edge is currently on cooldown.
-- Use as a guard inside lurek.update or event handlers.
local edge = lurek.graph.newEdge()
if edge:isOnCooldown() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Edge:isBidirectional
-- Returns true if items can travel the edge in either direction.
-- Use as a guard inside lurek.update or event handlers.
local edge = lurek.graph.newEdge()
if edge:isBidirectional() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Edge:setBidirectional
-- Sets whether items can travel the edge in either direction.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setBidirectional(0)
print("Edge:setBidirectional applied")

--@api-stub: Edge:isActive
-- Returns true if the edge is active.
-- Use as a guard inside lurek.update or event handlers.
local edge = lurek.graph.newEdge()
if edge:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Edge:setActive
-- Sets the active state of this edge.
-- Apply at startup or in response to user input.
local edge = lurek.graph.newEdge()
edge:setActive(1)
print("Edge:setActive applied")

--@api-stub: Edge:getItemsInTransit
-- Returns a table of GraphItem handles currently in transit on this edge.
-- Cheap to call; safe inside callbacks.
local edge = lurek.graph.newEdge()  -- or your existing handle
local value = edge:getItemsInTransit()
print("Edge:getItemsInTransit ->", value)

--@api-stub: Edge:addAllowedType
-- Adds an item type to the edge allow-list.
-- Side-effecting; safe to call any time after init.
local edge = lurek.graph.newEdge()
edge:addAllowedType(t)
print("Edge:addAllowedType done")

--@api-stub: Edge:removeAllowedType
-- Removes an item type from the edge allow-list.
-- Pair with the matching constructor to free resources.
local edge = lurek.graph.newEdge()
edge:removeAllowedType(t)
-- edge is now released
print("ok")

--@api-stub: Edge:clearAllowedTypes
-- Clears the edge allow-list so all item types are permitted.
-- Pair with the matching constructor to free resources.
local edge = lurek.graph.newEdge()
edge:clearAllowedTypes()
-- edge is now released
print("ok")

--@api-stub: Edge:isItemTypeAllowed
-- Returns true if the given item type is allowed on this edge.
-- Use as a guard inside lurek.update or event handlers.
local edge = lurek.graph.newEdge()
if edge:isItemTypeAllowed(t) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Edge:type
-- Returns the type name "GraphEdge".
-- See the module spec for detailed semantics.
local edge = lurek.graph.newEdge()
edge:type()
print("Edge:type done")

--@api-stub: Edge:typeOf
-- Returns true when the given name matches "GraphEdge" or a parent type.
-- See the module spec for detailed semantics.
local edge = lurek.graph.newEdge()
edge:typeOf("main")
print("Edge:typeOf done")

-- ── Node methods ──

--@api-stub: Node:getType
-- Returns the node type string.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getType()
print("Node:getType ->", value)

--@api-stub: Node:setType
-- Sets the node type string.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setType(t)
print("Node:setType applied")

--@api-stub: Node:getCapacity
-- Returns the node capacity (-1 = unlimited).
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getCapacity()
print("Node:getCapacity ->", value)

--@api-stub: Node:setCapacity
-- Sets the node capacity (-1 = unlimited).
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setCapacity(c)
print("Node:setCapacity applied")

--@api-stub: Node:getItemCount
-- Returns the number of items currently at this node.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getItemCount()
print("Node:getItemCount ->", value)

--@api-stub: Node:isFull
-- Returns true if the node has reached its capacity.
-- Use as a guard inside lurek.update or event handlers.
local node = lurek.graph.newNode()
if node:isFull() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Node:isActive
-- Returns true if the node is active.
-- Use as a guard inside lurek.update or event handlers.
local node = lurek.graph.newNode()
if node:isActive() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Node:setActive
-- Sets the active state of this node.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setActive(1)
print("Node:setActive applied")

--@api-stub: Node:getOverflowPolicy
-- Returns the overflow policy as a string.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getOverflowPolicy()
print("Node:getOverflowPolicy ->", value)

--@api-stub: Node:setOverflowPolicy
-- Sets the overflow policy from a string.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setOverflowPolicy(p)
print("Node:setOverflowPolicy applied")

--@api-stub: Node:getFlowMode
-- Returns the flow mode as a string.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getFlowMode()
print("Node:getFlowMode ->", value)

--@api-stub: Node:setFlowMode
-- Sets the flow mode from a string.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setFlowMode(m)
print("Node:setFlowMode applied")

--@api-stub: Node:getPushRate
-- Returns items per second this node pushes.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getPushRate()
print("Node:getPushRate ->", value)

--@api-stub: Node:setPushRate
-- Sets items per second this node pushes.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setPushRate(1)
print("Node:setPushRate applied")

--@api-stub: Node:getPullRate
-- Returns items per second this node pulls.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getPullRate()
print("Node:getPullRate ->", value)

--@api-stub: Node:setPullRate
-- Sets items per second this node pulls.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setPullRate(1)
print("Node:setPullRate applied")

--@api-stub: Node:getPushFilter
-- Returns the push filter string, or nil if unset.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getPushFilter()
print("Node:getPushFilter ->", value)

--@api-stub: Node:setPushFilter
-- Sets the push filter string, or nil to clear.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setPushFilter(f)
print("Node:setPushFilter applied")

--@api-stub: Node:getPullFilter
-- Returns the pull filter string, or nil if unset.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getPullFilter()
print("Node:getPullFilter ->", value)

--@api-stub: Node:setPullFilter
-- Sets the pull filter string, or nil to clear.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setPullFilter(f)
print("Node:setPullFilter applied")

--@api-stub: Node:getProcessTime
-- Returns the processing time in seconds.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getProcessTime()
print("Node:getProcessTime ->", value)

--@api-stub: Node:setProcessTime
-- Sets the processing time in seconds.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setProcessTime(t)
print("Node:setProcessTime applied")

--@api-stub: Node:isQueueEnabled
-- Returns true if the node queue is enabled.
-- Use as a guard inside lurek.update or event handlers.
local node = lurek.graph.newNode()
if node:isQueueEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Node:setQueueEnabled
-- Enables or disables the node queue.
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setQueueEnabled(e)
print("Node:setQueueEnabled applied")

--@api-stub: Node:getQueueCapacity
-- Returns the queue capacity (-1 = unlimited).
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getQueueCapacity()
print("Node:getQueueCapacity ->", value)

--@api-stub: Node:setQueueCapacity
-- Sets the queue capacity (-1 = unlimited).
-- Apply at startup or in response to user input.
local node = lurek.graph.newNode()
node:setQueueCapacity(c)
print("Node:setQueueCapacity applied")

--@api-stub: Node:getQueueSize
-- Returns the number of items currently in the queue.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getQueueSize()
print("Node:getQueueSize ->", value)

--@api-stub: Node:getItems
-- Returns a table of GraphItem handles at this node.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getItems()
print("Node:getItems ->", value)

--@api-stub: Node:getEdges
-- Returns a table of Edge handles connected to this node.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getEdges("data/file.txt")
print("Node:getEdges ->", value)

--@api-stub: Node:clearConversion
-- Removes the conversion rule for the given input type.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:clearConversion(in_type)
-- node is now released
print("ok")

--@api-stub: Node:clearAllConversions
-- Removes all conversion rules from this node.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:clearAllConversions()
-- node is now released
print("ok")

--@api-stub: Node:addTag
-- Attaches a string tag to this node for fast group queries.
-- Side-effecting; safe to call any time after init.
local node = lurek.graph.newNode()
node:addTag("main")
print("Node:addTag done")

--@api-stub: Node:removeTag
-- Removes a tag from this node.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:removeTag("main")
-- node is now released
print("ok")

--@api-stub: Node:hasTag
-- Returns true if this node has the given tag.
-- Use as a guard inside lurek.update or event handlers.
local node = lurek.graph.newNode()
if node:hasTag("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Node:clearTags
-- Removes all tags from this node.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:clearTags()
-- node is now released
print("ok")

--@api-stub: Node:getTags
-- Returns a table of tag strings on this node.
-- Cheap to call; safe inside callbacks.
local node = lurek.graph.newNode()  -- or your existing handle
local value = node:getTags()
print("Node:getTags ->", value)

--@api-stub: Node:removeSupply
-- Removes the supply declaration for the given item type.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:removeSupply(item_type)
-- node is now released
print("ok")

--@api-stub: Node:clearSupplies
-- Removes all supply declarations from this node.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:clearSupplies()
-- node is now released
print("ok")

--@api-stub: Node:removeDemand
-- Removes the demand declaration for the given item type.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:removeDemand(item_type)
-- node is now released
print("ok")

--@api-stub: Node:clearDemands
-- Removes all demand declarations from this node.
-- Pair with the matching constructor to free resources.
local node = lurek.graph.newNode()
node:clearDemands()
-- node is now released
print("ok")

--@api-stub: Node:enqueue
-- Pushes an item into the node queue.
-- See the module spec for detailed semantics.
local node = lurek.graph.newNode()
node:enqueue(item_ud)
print("Node:enqueue done")

--@api-stub: Node:dequeue
-- Pops the next item from the node queue, or nil if empty.
-- See the module spec for detailed semantics.
local node = lurek.graph.newNode()
node:dequeue()
print("Node:dequeue done")

--@api-stub: Node:type
-- Returns the type name "GraphNode".
-- See the module spec for detailed semantics.
local node = lurek.graph.newNode()
node:type()
print("Node:type done")

--@api-stub: Node:typeOf
-- Returns true when the given name matches "GraphNode" or a parent type.
-- See the module spec for detailed semantics.
local node = lurek.graph.newNode()
node:typeOf("main")
print("Node:typeOf done")

-- ── Graph methods ──

--@api-stub: Graph:removeNode
-- Removes a node from the graph.
-- Pair with the matching constructor to free resources.
local graph = lurek.graph.newGraph()
graph:removeNode(node_ud)
-- graph is now released
print("ok")

--@api-stub: Graph:hasNode
-- Returns true if the node exists in the graph.
-- Use as a guard inside lurek.update or event handlers.
local graph = lurek.graph.newGraph()
if graph:hasNode(node_ud) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Graph:getNodes
-- Returns a table of all Node handles.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getNodes()
print("Graph:getNodes ->", value)

--@api-stub: Graph:getNodeCount
-- Returns the number of nodes in the graph.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getNodeCount()
print("Graph:getNodeCount ->", value)

--@api-stub: Graph:removeEdge
-- Removes an edge from the graph.
-- Pair with the matching constructor to free resources.
local graph = lurek.graph.newGraph()
graph:removeEdge(edge_ud)
-- graph is now released
print("ok")

--@api-stub: Graph:hasEdge
-- Returns true if the edge exists in the graph.
-- Use as a guard inside lurek.update or event handlers.
local graph = lurek.graph.newGraph()
if graph:hasEdge(edge_ud) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Graph:getEdges
-- Returns a table of all Edge handles.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getEdges()
print("Graph:getEdges ->", value)

--@api-stub: Graph:getEdgeCount
-- Returns the number of edges in the graph.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getEdgeCount()
print("Graph:getEdgeCount ->", value)

--@api-stub: Graph:removeItem
-- Removes an item from the graph entirely.
-- Pair with the matching constructor to free resources.
local graph = lurek.graph.newGraph()
graph:removeItem(item_ud)
-- graph is now released
print("ok")

--@api-stub: Graph:hasItem
-- Returns true if the item exists in the graph.
-- Use as a guard inside lurek.update or event handlers.
local graph = lurek.graph.newGraph()
if graph:hasItem(item_ud) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Graph:getItems
-- Returns a table of all GraphItem handles.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getItems()
print("Graph:getItems ->", value)

--@api-stub: Graph:getItemCount
-- Returns the number of items in the graph.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getItemCount()
print("Graph:getItemCount ->", value)

--@api-stub: Graph:update
-- Advances simulation by dt seconds and fires event callbacks.
-- Apply at startup or in response to user input.
local graph = lurek.graph.newGraph()
graph:update(dt)
print("Graph:update applied")

--@api-stub: Graph:step
-- Runs one discrete simulation step and fires event callbacks.
-- Trigger from input, timers, or game events.
local graph = lurek.graph.newGraph()
graph:step()
-- trigger from input, timer, or event
print("ok")

--@api-stub: Graph:tickParallel
-- Advances simulation by dt seconds using a parallelised decay phase.
-- Trigger from input, timers, or game events.
local graph = lurek.graph.newGraph()
graph:tickParallel(dt)
-- trigger from input, timer, or event
print("ok")

--@api-stub: Graph:getNeighbors
-- Returns a table of direct neighbor Node handles.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getNeighbors(node_ud)
print("Graph:getNeighbors ->", value)

--@api-stub: Graph:getComponents
-- Returns weakly connected components as a table of tables of Node handles.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getComponents()
print("Graph:getComponents ->", value)

--@api-stub: Graph:hasCycle
-- Returns true if the graph contains a directed cycle.
-- Use as a guard inside lurek.update or event handlers.
local graph = lurek.graph.newGraph()
if graph:hasCycle() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Graph:topologicalSort
-- Returns a topologically sorted table of Node handles, or nil if a cycle exists.
-- See the module spec for detailed semantics.
local graph = lurek.graph.newGraph()
graph:topologicalSort()
print("Graph:topologicalSort done")

--@api-stub: Graph:mst
-- Returns edge IDs forming a minimum spanning tree (Kruskal, undirected view).
-- See the module spec for detailed semantics.
local graph = lurek.graph.newGraph()
graph:mst()
print("Graph:mst done")

--@api-stub: Graph:colorGraph
-- Assigns each node the smallest non-negative integer colour not shared with any.
-- See the module spec for detailed semantics.
local graph = lurek.graph.newGraph()
graph:colorGraph()
print("Graph:colorGraph done")

--@api-stub: Graph:isBipartite
-- Returns `true` when the graph can be 2-coloured (bipartite check via BFS).
-- Use as a guard inside lurek.update or event handlers.
local graph = lurek.graph.newGraph()
if graph:isBipartite() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Graph:processDemand
-- Processes all supply/demand declarations and fires event callbacks.
-- See the module spec for detailed semantics.
local graph = lurek.graph.newGraph()
graph:processDemand()
print("Graph:processDemand done")

--@api-stub: Graph:getStats
-- Returns a statistics snapshot table.
-- Cheap to call; safe inside callbacks.
local graph = lurek.graph.newGraph()  -- or your existing handle
local value = graph:getStats()
print("Graph:getStats ->", value)

--@api-stub: Graph:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local graph = lurek.graph.newGraph()
graph:type()
print("Graph:type done")

--@api-stub: Graph:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local graph = lurek.graph.newGraph()
graph:typeOf("main")
print("Graph:typeOf done")

