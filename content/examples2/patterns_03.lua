--- Patterns Module Part 4: graph, collections (list, map, set, stack, queue, ring, priority queue, weighted random, relationships)

--@api-stub: lurek.patterns.newGraph
--@api-stub: LPatternGraph:addNode
--@api-stub: LPatternGraph:addEdge
--@api-stub: LPatternGraph:nodeCount
--@api-stub: LPatternGraph:edgeCount
-- Directed graph creation.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(false)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    local c = g:addNode("C")
    local e1 = g:addEdge(a, b, 1.0, "road")
    local e2 = g:addEdge(b, c, 2.5)
    print("nodes = " .. g:nodeCount() .. " edges = " .. g:edgeCount())
end

--@api-stub: LPatternGraph:bfs
--@api-stub: LPatternGraph:dfs
--@api-stub: LPatternGraph:isConnected
--@api-stub: LPatternGraph:neighbors
--@api-stub: LPatternGraph:hasNode
-- Graph traversal and queries.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph(true)
    local n1 = g:addNode("start")
    local n2 = g:addNode("mid")
    local n3 = g:addNode("end")
    local n4 = g:addNode("isolated")
    g:addEdge(n1, n2)
    g:addEdge(n2, n3)
    local bfs_order = g:bfs(n1)
    print("BFS from start = " .. #bfs_order .. " nodes")
    local dfs_order = g:dfs(n1)
    print("DFS from start = " .. #dfs_order .. " nodes")
    print("start→end connected = " .. tostring(g:isConnected(n1, n3)))
    print("start→isolated connected = " .. tostring(g:isConnected(n1, n4)))
    local neighbors = g:neighbors(n2)
    print("mid neighbors = " .. #neighbors)
    print("has n1 = " .. tostring(g:hasNode(n1)))
end

--@api-stub: LPatternGraph:getNodeValue
--@api-stub: LPatternGraph:removeNode
--@api-stub: LPatternGraph:removeEdge
--@api-stub: LPatternGraph:clearAll
-- Graph modification.
do
    ---@type LPatternGraph
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local e = g:addEdge(a, b, 1.0)
    local val = g:getNodeValue(a)
    if val then print("room size = " .. val.size) end
    g:removeEdge(e)
    print("after edge remove: edges = " .. g:edgeCount())
    g:removeNode(b)
    print("after node remove: nodes = " .. g:nodeCount())
    g:clearAll()
    print("after clear: nodes = " .. g:nodeCount())
end

--@api-stub: lurek.patterns.newList
--@api-stub: LList:add
--@api-stub: LList:get
--@api-stub: LList:len
--@api-stub: LList:remove
--@api-stub: LList:indexOf
-- Dynamic list.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("get(2) = " .. list:get(2))
    print("indexOf beta = " .. list:indexOf("beta"))
    list:remove(2)
    print("after remove: len = " .. list:len())
end

--@api-stub: LList:push
--@api-stub: LList:pop
--@api-stub: LList:insert
--@api-stub: LList:set
--@api-stub: LList:shift
--@api-stub: LList:unshift
--@api-stub: LList:contains
--@api-stub: LList:reverse
--@api-stub: LList:toArray
--@api-stub: LList:isEmpty
-- List operations.
do
    ---@type LList
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:insert(2, "x")
    list:set(1, "A")
    print("contains x = " .. tostring(list:contains("x")))
    list:unshift("first")
    local shifted = list:shift()
    print("shifted = " .. shifted)
    local popped = list:pop()
    print("popped = " .. popped)
    list:reverse()
    local arr = list:toArray()
    print("array len = " .. #arr)
    list:clear()
    print("empty = " .. tostring(list:isEmpty()))
end

--@api-stub: lurek.patterns.newMap
--@api-stub: LMap:set
--@api-stub: LMap:get
--@api-stub: LMap:has
--@api-stub: LMap:remove
--@api-stub: LMap:keys
--@api-stub: LMap:values
--@api-stub: LMap:len
-- String-keyed map.
do
    ---@type LMap
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    map:set("class", "warrior")
    print("name = " .. map:get("name"))
    print("has level = " .. tostring(map:has("level")))
    print("len = " .. map:len())
    map:remove("class")
    print("keys = " .. #map:keys())
    print("values = " .. #map:values())
end

--@api-stub: LMap:entries
--@api-stub: LMap:merge
--@api-stub: LMap:isEmpty
--@api-stub: LMap:clear
-- Map merge and entries.
do
    ---@type LMap
    local m1 = lurek.patterns.newMap()
    m1:set("a", 1)
    m1:set("b", 2)
    ---@type LMap
    local m2 = lurek.patterns.newMap()
    m2:set("b", 99)
    m2:set("c", 3)
    m1:merge(m2)
    print("after merge: b = " .. m1:get("b"))
    local entries = m1:entries()
    print("entries = " .. #entries)
    print("empty = " .. tostring(m1:isEmpty()))
    m1:clear()
    print("after clear: empty = " .. tostring(m1:isEmpty()))
end

--@api-stub: lurek.patterns.newSet
--@api-stub: LSet:add
--@api-stub: LSet:has
--@api-stub: LSet:remove
--@api-stub: LSet:len
--@api-stub: LSet:toArray
-- String set.
do
    ---@type LSet
    local s = lurek.patterns.newSet()
    print("added = " .. tostring(s:add("fire")))
    print("dup = " .. tostring(s:add("fire")))
    s:add("ice")
    s:add("wind")
    print("has fire = " .. tostring(s:has("fire")))
    print("len = " .. s:len())
    s:remove("ice")
    local arr = s:toArray()
    print("array = " .. #arr)
end

--@api-stub: LSet:union
--@api-stub: LSet:intersection
--@api-stub: LSet:isEmpty
--@api-stub: LSet:clear
-- Set algebra.
do
    ---@type LSet
    local a = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    a:add("z")
    ---@type LSet
    local b = lurek.patterns.newSet()
    b:add("y")
    b:add("z")
    b:add("w")
    local u = a:union(b)
    print("union = " .. u:len())
    local i = a:intersection(b)
    print("intersection = " .. i:len())
    a:clear()
    print("empty = " .. tostring(a:isEmpty()))
end

--@api-stub: lurek.patterns.newStack
--@api-stub: LStack:push
--@api-stub: LStack:pop
--@api-stub: LStack:peek
--@api-stub: LStack:len
--@api-stub: LStack:isEmpty
-- LIFO stack.
do
    ---@type LStack
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    st:push("third")
    print("peek = " .. st:peek())
    print("len = " .. st:len())
    local v = st:pop()
    print("popped = " .. v)
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: LStack:pushBottom
--@api-stub: LStack:popBottom
--@api-stub: LStack:peekBottom
--@api-stub: LStack:peekAt
--@api-stub: LStack:insertAt
--@api-stub: LStack:removeAt
--@api-stub: LStack:popMany
--@api-stub: LStack:moveWithin
--@api-stub: LStack:isFull
--@api-stub: LStack:clear
--@api-stub: LStack:toArray
-- Advanced stack operations.
do
    ---@type LStack
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:pushBottom("z")
    print("bottom = " .. st:peekBottom())
    print("at 2 = " .. st:peekAt(2))
    st:insertAt(2, "x")
    local removed = st:removeAt(2)
    print("removed = " .. removed)
    local many = st:popMany(2)
    print("popped many = " .. #many)
    st:push("p")
    st:push("q")
    st:moveWithin(1, 2)
    print("full = " .. tostring(st:isFull()))
    local arr = st:toArray()
    print("array = " .. #arr)
    st:clear()
    print("empty = " .. tostring(st:isEmpty()))
end

--@api-stub: lurek.patterns.newQueue
--@api-stub: LQueue:enqueue
--@api-stub: LQueue:dequeue
--@api-stub: LQueue:front
--@api-stub: LQueue:back
--@api-stub: LQueue:len
--@api-stub: LQueue:isEmpty
-- FIFO queue.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    q:enqueue("msg3")
    print("front = " .. q:front())
    print("back = " .. q:back())
    print("len = " .. q:len())
    local v = q:dequeue()
    print("dequeued = " .. v)
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: LQueue:enqueueFront
--@api-stub: LQueue:dequeueBack
--@api-stub: LQueue:insertAt
--@api-stub: LQueue:removeAt
--@api-stub: LQueue:peekAt
--@api-stub: LQueue:isFull
--@api-stub: LQueue:clear
--@api-stub: LQueue:toArray
-- Advanced queue operations.
do
    ---@type LQueue
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    q:enqueueFront("priority")
    print("front = " .. q:front())
    local back = q:dequeueBack()
    print("dequeued back = " .. back)
    q:insertAt(2, "inserted")
    print("at 2 = " .. q:peekAt(2))
    local rem = q:removeAt(2)
    print("removed = " .. rem)
    print("full = " .. tostring(q:isFull()))
    local arr = q:toArray()
    print("array = " .. #arr)
    q:clear()
    print("empty = " .. tostring(q:isEmpty()))
end

--@api-stub: lurek.patterns.newPriorityQueue
--@api-stub: LPriorityQueue:push
--@api-stub: LPriorityQueue:pop
--@api-stub: LPriorityQueue:peek
--@api-stub: LPriorityQueue:len
--@api-stub: LPriorityQueue:isEmpty
--@api-stub: LPriorityQueue:clearAll
-- Priority queue (highest priority first).
do
    ---@type LPriorityQueue
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    pq:push(5, "mid_task", "mid")
    print("len = " .. pq:len())
    local top = pq:peek()
    if top then print("peek = " .. tostring(top)) end
    local item = pq:pop()
    if item then print("popped = " .. tostring(item)) end
    print("after pop: len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
    pq:clearAll()
    print("after clear: empty = " .. tostring(pq:isEmpty()))
end

--@api-stub: lurek.patterns.newRing
--@api-stub: LRing:push
--@api-stub: LRing:len
--@api-stub: LRing:latest
--@api-stub: LRing:isFull
--@api-stub: LRing:sum
--@api-stub: LRing:average
--@api-stub: LRing:toArray
--@api-stub: LRing:clear
-- Ring buffer.
do
    ---@type LRing
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    ring:push(59)
    ring:push(61)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
    local entry = ring:latest()
    if entry then print("latest value = " .. entry.value) end
    print("sum = " .. ring:sum())
    print("average = " .. ring:average())
    ring:push(55)
    print("overwrote oldest, len = " .. ring:len())
    local arr = ring:toArray()
    print("array entries = " .. #arr)
    ring:clear()
    print("after clear: len = " .. ring:len())
end

--@api-stub: lurek.patterns.newWeightedRandom
--@api-stub: LWeightedRandom:add
--@api-stub: LWeightedRandom:pick
--@api-stub: LWeightedRandom:pickN
--@api-stub: LWeightedRandom:len
--@api-stub: LWeightedRandom:totalWeight
-- Weighted random selection.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id1 = wr:add(10, "common", "common_loot")
    local id2 = wr:add(3, "rare", "rare_loot")
    local id3 = wr:add(1, "legendary", "legendary_loot")
    print("items = " .. wr:len())
    print("total weight = " .. wr:totalWeight())
    local picked = wr:pick(0.5)
    print("picked = " .. tostring(picked))
    local multi = wr:pickN(2, {0.1, 0.9})
    print("multi picks = " .. #multi)
end

--@api-stub: LWeightedRandom:remove
--@api-stub: LWeightedRandom:setWeight
--@api-stub: LWeightedRandom:getRevision
--@api-stub: LWeightedRandom:isEmpty
--@api-stub: LWeightedRandom:clearAll
-- Weighted random management.
do
    ---@type LWeightedRandom
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    wr:remove(id)
    print("after remove: len = " .. wr:len())
    print("empty = " .. tostring(wr:isEmpty()))
    wr:clearAll()
    print("after clear: empty = " .. tostring(wr:isEmpty()))
end

--@api-stub: lurek.patterns.newRelationshipManager
--@api-stub: LRelationshipManager:setValue
--@api-stub: LRelationshipManager:getValue
--@api-stub: LRelationshipManager:adjustValue
-- Relationship tracking between entities.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1→2 = " .. rm:getValue(1, 2))
    print("1→3 = " .. rm:getValue(1, 3))
    rm:adjustValue(1, 2, 10)
    print("adjusted 1→2 = " .. rm:getValue(1, 2))
end

--@api-stub: LRelationshipManager:defineType
--@api-stub: LRelationshipManager:setLevel
--@api-stub: LRelationshipManager:getLevel
--@api-stub: LRelationshipManager:typeNames
--@api-stub: LRelationshipManager:pairCount
--@api-stub: LRelationshipManager:removePair
--@api-stub: LRelationshipManager:removeType
-- Named relationship levels.
do
    ---@type LRelationshipManager
    local rm = lurek.patterns.newRelationshipManager()
    rm:defineType("friendship", {"hostile", "unfriendly", "neutral", "friendly", "allied"}, "neutral")
    rm:setLevel(1, 2, "friendship", "friendly")
    rm:setLevel(1, 3, "friendship", "hostile")
    print("1→2 friendship = " .. rm:getLevel(1, 2, "friendship"))
    print("1→3 friendship = " .. rm:getLevel(1, 3, "friendship"))
    print("types = " .. #rm:typeNames())
    print("pairs = " .. rm:pairCount())
    rm:removePair(1, 3)
    print("after remove: pairs = " .. rm:pairCount())
    rm:removeType("friendship")
    print("after removeType: types = " .. #rm:typeNames())
end

print("patterns_03.lua")
