# Patterns

## Summary

- The patterns module is a Foundations toolbox for coordination, control flow, and reusable architecture primitives.
- It focuses on decoupling systems and making game logic easier to compose and test.
- Behavior trees provide deterministic reactive decision flow with explicit node semantics.
- Trees support sequence, selector, inverter, repeater, and parallel execution patterns.
- Runtime tree state is preserved across ticks for long-running action continuity.
- Simple state tracking supports lightweight single-mode workflows.
- Full state machines provide guarded transitions and bounded transition history.
- Transition history enables debugging and analytics of behavior progression.
- Event buses provide publish-subscribe routing with priorities and wildcard listeners.
- One-shot listeners reduce boilerplate for temporary event reactions.
- Mediator routing supports broker-style communication channels between decoupled systems.
- Blackboard storage supports shared facts with revision-aware reads.
- Hierarchical blackboards allow local override with parent fallback.
- Observer primitives provide key-based reactive notifications.
- Wildcard observers support broad state-change monitoring.
- Relationship-manager construction remains available here as a compatibility alias, but new ownership lives under `lurek.ecs`.
- Command stacks implement undo and redo with bounded history policies.
- Batch commands support atomic rollback of multi-step operations.
- Throttle and debounce utilities control cadence for noisy inputs and triggers.
- Object pools support stable identity reuse in allocation-sensitive loops.
- Priority queues support deterministic ordering for equal-priority entries.
- Ring buffers retain rolling windows of recent values or events.
- Bi-directional maps support reversible key-value lookup.
- Tries support efficient prefix search for command palettes and filters.
- Factory registries support data-driven construction by symbolic names.
- Strategy registries support runtime algorithm swapping without callsite rewrites.
- Service locators expose shared capability lookup for loosely-coupled modules.
- Graph primitives support node-edge modeling with traversal helpers.
- Weighted random selection supports repeat-aware probabilistic choice.
- Funnel buffering supports time-windowed accumulation and controlled flush behavior.
- Collection capacity helpers keep bounded/unbounded semantics consistent.
- The module favors explicit IDs and stable iteration order.
- That design improves reproducibility across runs and test environments.
- Primitives are intentionally small and orthogonal for composability.
- The module does not own gameplay domain rules.
- It does not own rendering, audio, filesystem, or host runtime concerns.
- It is intended to be reused by many higher-level feature modules.
- Typical AI stacks combine behavior trees, blackboards, and event buses.
- Typical tooling stacks combine command stacks with observers.
- Typical input pipelines combine debounce/throttle with ring diagnostics.
- Contracts are script-friendly while keeping behavior deterministic.
- APIs are designed for incremental adoption in existing systems.
- Cross-module dependencies remain acyclic at the Foundations level.
- The module improves maintainability by reducing orchestration duplication.
- It improves testability by making side effects and transitions explicit.
- It improves readability by encoding common control patterns directly.
- The toolbox is broad but consistently structured.
- It scales from small prototypes to production systems.
- It remains architecture-focused rather than feature-domain specific.
- Overall, patterns is the reusable orchestration layer beneath gameplay features.
- It exists to help teams ship complex behavior with less structural debt.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.patterns.newBehaviorTree`

Create a new behavior tree for AI decision-making with sequences, selectors, parallels, and leaf actions.

```lua
lurek.patterns.newBehaviorTree()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBehaviorTree](#lbehaviortree) | A new behavior tree instance. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(root, check)
    bt:addChild(root, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

### `lurek.patterns.newBlackboard`

Create a new shared key-value blackboard supporting reactive watchers for game logic variables.

```lua
lurek.patterns.newBlackboard(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional name for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| [LBlackboard](#lblackboard) | A new blackboard instance. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("mode", "idle")
    print("health = " .. tostring(bb:get("health")))
    print("keys = " .. #bb:keys())
end
```

---

### `lurek.patterns.newCommandStack`

Create a new undo/redo command stack for recording and reversing player or editor actions.

```lua
lurek.patterns.newCommandStack(maxSize)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `maxSize?` | number | Maximum history depth (0 = unlimited). |

**Returns**

| Type | Description |
|------|-------------|
| [LCommandStack](#lcommandstack) | A new command stack instance. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    print("value = " .. value)
    print("history = " .. cmds:getHistorySize())
end
```

---

### `lurek.patterns.newDebounce`

Create a new debounce that delays firing until input stops for a specified wait period.

```lua
lurek.patterns.newDebounce(wait)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `wait` | number | Seconds of inactivity before firing. |

**Returns**

| Type | Description |
|------|-------------|
| [LDebounce](#ldebounce) | A new debounce instance. |

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    print("fires = " .. db:getFireCount())
end
```

---

### `lurek.patterns.newEventBus`

Create a new publish/subscribe event bus for decoupled communication between game systems.

```lua
lurek.patterns.newEventBus(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional name for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| [LEventBus](#leventbus) | A new event bus instance. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        print("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 25, "fire")
    print("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end
```

---

### `lurek.patterns.newFactory`

Create a new factory for producing typed game objects from registered constructor functions.

```lua
lurek.patterns.newFactory()
```

**Returns**

| Type | Description |
|------|-------------|
| [LFactory](#lfactory) | A new factory instance. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    local enemy = factory:create("enemy", 120)
    print("enemy hp = " .. tostring(enemy and enemy.hp))
    print("types = " .. #factory:getTypes())
end
```

---

### `lurek.patterns.newFunnel`

Create a new batching funnel that collects events over a time window and flushes them together.

```lua
lurek.patterns.newFunnel(window, maxEntries, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `window` | number | Time window in seconds before auto-flush. |
| `maxEntries?` | number | Maximum entries before forced flush (0 = no limit). |
| `name?` | string | Optional name for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| [LFunnel](#lfunnel) | A new funnel instance. |

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end
```

---

### `lurek.patterns.newGraph`

Create a new graph data structure with directed or undirected edges, BFS, DFS, and connectivity queries.

```lua
lurek.patterns.newGraph(undirected)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `undirected?` | boolean | If true, edges are bidirectional (default false). |

**Returns**

| Type | Description |
|------|-------------|
| [LPatternGraph](#lpatterngraph) | A new graph instance. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.5, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end
```

---

### `lurek.patterns.newList`

Create a new dynamic array list with indexed access, insertion, removal, and search.

```lua
lurek.patterns.newList()
```

**Returns**

| Type | Description |
|------|-------------|
| [LList](#llist) | A new list instance. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("second = " .. tostring(list:get(2)))
end
```

---

### `lurek.patterns.newMap`

Create a new string-keyed dictionary (map) with keys/values/entries access and merge support.

```lua
lurek.patterns.newMap()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMap](#lmap) | A new map instance. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("name = " .. tostring(map:get("name")))
    print("len = " .. map:len())
end
```

---

### `lurek.patterns.newMediator`

Create a new mediator for channel-based message passing between decoupled game systems.

```lua
lurek.patterns.newMediator()
```

**Returns**

| Type | Description |
|------|-------------|
| [LMediator](#lmediator) | A new mediator instance. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    print("channels = " .. #med:channels())
    med:off("ui", id)
end
```

---

### `lurek.patterns.newObjectPool`

Create a new object pool for reusing pre-allocated game objects to reduce allocation overhead.

```lua
lurek.patterns.newObjectPool()
```

**Returns**

| Type | Description |
|------|-------------|
| [LObjectPool](#lobjectpool) | A new object pool instance. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
end
```

---

### `lurek.patterns.newObserver`

Create a new reactive observer that stores values and notifies subscribers when they change.

```lua
lurek.patterns.newObserver(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional name for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| [LObserver](#lobserver) | A new observer instance. |

**Example**

```lua
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    print("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end
```

---

### `lurek.patterns.newPriorityQueue`

Create a new priority queue that orders elements by numeric priority (highest first).

```lua
lurek.patterns.newPriorityQueue(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name?` | string | Optional name for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| [LPriorityQueue](#lpriorityqueue) | A new priority queue instance. |

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("peek = " .. tostring(pq:peek()))
    print("len = " .. pq:len())
end
```

---

### `lurek.patterns.newQueue`

Create a new FIFO queue with optional capacity limit.

```lua
lurek.patterns.newQueue(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity?` | number | Maximum items (0 = unlimited). |

**Returns**

| Type | Description |
|------|-------------|
| [LQueue](#lqueue) | A new queue instance. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("front = " .. tostring(q:front()))
    print("len = " .. q:len())
end
```

---

### `lurek.patterns.newRelationshipManager`

Create a new relationship manager for tracking numeric values and named levels between entity pairs.

```lua
lurek.patterns.newRelationshipManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LRelationshipManager](#lrelationshipmanager) | A new relationship manager instance. |

**Example**

```lua
do
    -- Deprecated alias kept for compatibility. Prefer lurek.ecs.newRelationshipManager().
    local rm = lurek.patterns.newRelationshipManager()
    rm:setValue(1, 2, 50)
    rm:setValue(1, 3, -20)
    print("1->2 = " .. rm:getValue(1, 2))
    print("1->3 = " .. rm:getValue(1, 3))
end
```

---

### `lurek.patterns.newRing`

Create a new fixed-size ring buffer for numeric or string values. Oldest entries are overwritten when full.

```lua
lurek.patterns.newRing(capacity, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity` | number | Maximum number of entries the ring can hold. |
| `name?` | string | Optional name for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| [LRing](#lring) | A new ring buffer instance. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("len = " .. ring:len())
    print("average = " .. ring:average())
end
```

---

### `lurek.patterns.newServiceLocator`

Create a new service locator for registering and retrieving shared services by name at runtime.

```lua
lurek.patterns.newServiceLocator()
```

**Returns**

| Type | Description |
|------|-------------|
| [LServiceLocator](#lservicelocator) | A new service locator instance. |

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8})
    print("has audio = " .. tostring(services:has("audio")))
    print("services = " .. #services:getServices())
end
```

---

### `lurek.patterns.newSet`

Create a new string set with add/remove/has operations and set algebra (union, intersection).

```lua
lurek.patterns.newSet()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSet](#lset) | A new set instance. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    print("len = " .. set:len())
    print("has fire = " .. tostring(set:has("fire")))
end
```

---

### `lurek.patterns.newSimpleState`

Create a new finite state machine with enter/exit/update callbacks per state.

```lua
lurek.patterns.newSimpleState()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSimpleState](#lsimplestate) | A new state machine instance. |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end,
        update = function(dt)
            print("idle dt = " .. dt)
        end
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    print("current = " .. tostring(fsm:getCurrent()))
end
```

---

### `lurek.patterns.newStack`

Create a new LIFO stack with optional capacity limit.

```lua
lurek.patterns.newStack(capacity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capacity?` | number | Maximum items (0 = unlimited). |

**Returns**

| Type | Description |
|------|-------------|
| [LStack](#lstack) | A new stack instance. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("peek = " .. tostring(st:peek()))
    print("len = " .. st:len())
end
```

---

### `lurek.patterns.newStrategy`

Create a new strategy pattern container for hot-swappable algorithm implementations.

```lua
lurek.patterns.newStrategy()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStrategy](#lstrategy) | A new strategy instance. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute("orc")))
end
```

---

### `lurek.patterns.newThrottle`

Create a new throttle that limits how often an action can fire, enforcing a minimum interval.

```lua
lurek.patterns.newThrottle(interval)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `interval` | number | Minimum seconds between fires. |

**Returns**

| Type | Description |
|------|-------------|
| [LThrottle](#lthrottle) | A new throttle instance. |

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        print("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    th:update(0.2)
    print("fires = " .. th:getFireCount())
end
```

---

### `lurek.patterns.newWeightedRandom`

Create a new weighted random selection pool. Add items with weights and pick random selections.

```lua
lurek.patterns.newWeightedRandom()
```

**Returns**

| Type | Description |
|------|-------------|
| [LWeightedRandom](#lweightedrandom) | A new weighted random pool instance. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("items = " .. wr:len())
    print("picked = " .. tostring(wr:pick(0.5)))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LBehaviorTree](#lbehaviortree)
- [LBlackboard](#lblackboard)
- [LCommandStack](#lcommandstack)
- [LDebounce](#ldebounce)
- [LEventBus](#leventbus)
- [LFactory](#lfactory)
- [LFunnel](#lfunnel)
- [LList](#llist)
- [LMap](#lmap)
- [LMediator](#lmediator)
- [LObjectPool](#lobjectpool)
- [LObserver](#lobserver)
- [LPatternGraph](#lpatterngraph)
- [LPriorityQueue](#lpriorityqueue)
- [LQueue](#lqueue)
- [LRelationshipManager](#lrelationshipmanager)
- [LRing](#lring)
- [LServiceLocator](#lservicelocator)
- [LSet](#lset)
- [LSimpleState](#lsimplestate)
- [LStack](#lstack)
- [LStrategy](#lstrategy)
- [LThrottle](#lthrottle)
- [LWeightedRandom](#lweightedrandom)

## LBehaviorTree

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBehaviorTree:addChild`

Attach a child node to a parent composite or decorator node.

```lua
LBehaviorTree:addChild(parentId, childId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `parentId` | number | The parent node ID. |
| `childId` | number | The child node ID to attach. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if attached successfully. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(seq, check)
    bt:addChild(seq, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(seq)
    print("result = " .. bt:tick())
    print("node_count = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:addInverter`

Create a decorator node that inverts its child's result (success â†” failure).

```lua
LBehaviorTree:addInverter(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label?` | string | Optional debug label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The node ID. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addInverter("invert")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "failure"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:addLeaf`

Create a leaf (action) node that will invoke a named callback function on tick.

```lua
LBehaviorTree:addLeaf(name, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The leaf name (must match a setLeaf registration). |
| `label?` | string | Optional debug label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The node ID. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:addParallel`

Create a parallel composite node that runs all children simultaneously.

```lua
LBehaviorTree:addParallel(minSuccess, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `minSuccess` | number | Minimum successful children required for this node to succeed. |
| `label?` | string | Optional debug label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The node ID. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addParallel(2, "root")
    local a = bt:addLeaf("a")
    local b = bt:addLeaf("b")
    bt:addChild(root, a)
    bt:addChild(root, b)
    bt:setLeaf("a", function()
        return "success"
    end)
    bt:setLeaf("b", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:addRepeat`

Create a decorator node that repeats its child a fixed number of times.

```lua
LBehaviorTree:addRepeat(count, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of repetitions. |
| `label?` | string | Optional debug label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The node ID. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addRepeat(2, "repeat")
    local step = bt:addLeaf("step")
    local calls = 0
    bt:addChild(root, step)
    bt:setLeaf("step", function()
        calls = calls + 1
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("calls = " .. calls)
end
```

---

#### `LBehaviorTree:addSelector`

Create a selector (fallback) composite node. Succeeds if any child succeeds.

```lua
LBehaviorTree:addSelector(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label?` | string | Optional debug label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The node ID. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local check = bt:addLeaf("check")
    local idle = bt:addLeaf("idle")
    bt:addChild(root, check)
    bt:addChild(root, idle)
    bt:setLeaf("check", function()
        return "failure"
    end)
    bt:setLeaf("idle", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:addSequence`

Create a sequence composite node. All children must succeed for this node to succeed.

```lua
LBehaviorTree:addSequence(label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label?` | string | Optional debug label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The node ID. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local check = bt:addLeaf("check")
    bt:addChild(root, check)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:clearAll`

Remove all nodes and leaf functions, resetting the tree to empty.

```lua
LBehaviorTree:clearAll()
```

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSelector("root")
    local idle = bt:addLeaf("idle")
    bt:addChild(root, idle)
    bt:setRoot(root)
    print("before = " .. bt:nodeCount())
    bt:clearAll()
    print("after = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:getDebugState`

Returns behavior tree debug counters and status in a Lua table.

```lua
LBehaviorTree:getDebugState()
```

**Returns**

| Type | Description |
|------|-------------|
| LBehaviorTreeGetDebugStateResult | Table containing `node_count` and `last_status` fields. |

---

#### `LBehaviorTree:getLastStatus`

Returns the last behavior tree status string recorded by the tree.

```lua
LBehaviorTree:getLastStatus()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Last status such as `success`, `failure`, or `running`. |

---

#### `LBehaviorTree:nodeCount`

Return the total number of nodes in the tree.

```lua
LBehaviorTree:nodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Node count. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(seq, check)
    bt:addChild(seq, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(seq)
    print("node_count = " .. bt:nodeCount())
    print("result = " .. bt:tick())
end
```

---

#### `LBehaviorTree:resetState`

Reset the tree's running state. Use between encounters or when restarting AI logic.

```lua
LBehaviorTree:resetState()
```

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "running"
    end)
    bt:setRoot(root)
    print("first = " .. bt:tick())
    bt:resetState()
    print("after reset = " .. bt:tick())
end
```

---

#### `LBehaviorTree:setLeaf`

Register or replace the callback function for a named leaf. The function must return "success", "failure", or "running".

```lua
LBehaviorTree:setLeaf(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The leaf name (matching addLeaf). |
| `callback` | function | A function returning a status string. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        print("leaf fired")
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:setRoot`

Sets the behavior tree root by moving a node handle into the tree.

```lua
LBehaviorTree:setRoot(node)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node` | [LBTNode](ai.md#lbtnode) | Node handle to consume as the new tree root. |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local seq = bt:addSequence("root_seq")
    local check = bt:addLeaf("check")
    local act = bt:addLeaf("act")
    bt:addChild(seq, check)
    bt:addChild(seq, act)
    bt:setLeaf("check", function()
        return "success"
    end)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(seq)
    print("node_count = " .. bt:nodeCount())
    print("result = " .. bt:tick())
end
```

---

#### `LBehaviorTree:tick`

Execute one tick of the behavior tree from the root. Returns the root node's status.

```lua
LBehaviorTree:tick()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of "success", "failure", or "running". |

**Example**

```lua
do
    local bt = lurek.patterns.newBehaviorTree()
    local root = bt:addSequence("root")
    local act = bt:addLeaf("act")
    bt:addChild(root, act)
    bt:setLeaf("act", function()
        return "success"
    end)
    bt:setRoot(root)
    print("result = " .. bt:tick())
    print("nodes = " .. bt:nodeCount())
end
```

---

#### `LBehaviorTree:type`

Returns the Lua-visible type name for this behavior tree handle.

```lua
LBehaviorTree:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBehaviorTree](#lbehaviortree)`. |

---

#### `LBehaviorTree:typeOf`

Returns whether this behavior tree handle matches a supported type name.

```lua
LBehaviorTree:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `BehaviorTree` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

## LBlackboard

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBlackboard:clear`

Remove a single key from the blackboard.

```lua
LBlackboard:clear(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to remove. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    print("before = " .. tostring(bb:has("score")))
    bb:clear("score")
    print("after = " .. tostring(bb:has("score")))
end
```

---

#### `LBlackboard:clearAll`

Remove all keys and values from the blackboard.

```lua
LBlackboard:clearAll()
```

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    print("before = " .. #bb:keys())
    bb:clearAll()
    print("after = " .. #bb:keys())
end
```

---

#### `LBlackboard:get`

Retrieve the value stored under a key. Returns nil if the key does not exist.

```lua
LBlackboard:get(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | number|string|nil | The stored value. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("weapon", "sword")
    print("weapon = " .. tostring(bb:get("weapon")))
    print("has weapon = " .. tostring(bb:has("weapon")))
end
```

---

#### `LBlackboard:getRevision`

Return the current revision counter. Increments on every value change.

```lua
LBlackboard:getRevision()
```

**Returns**

| Type | Description |
|------|-------------|
| number | The revision number. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    print("revision = " .. bb:getRevision())
    print("score = " .. tostring(bb:get("score")))
end
```

---

#### `LBlackboard:has`

Check whether a key exists on the blackboard.

```lua
LBlackboard:has(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the key has a stored value. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("alive", true)
    print("has alive = " .. tostring(bb:has("alive")))
    print("has mana = " .. tostring(bb:has("mana")))
end
```

---

#### `LBlackboard:keys`

Return an array of all keys currently stored on the blackboard.

```lua
LBlackboard:keys()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Key name strings. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("health", 100)
    bb:set("weapon", "sword")
    local keys = bb:keys()
    print("keys = " .. #keys)
    print("first = " .. tostring(keys[1]))
end
```

---

#### `LBlackboard:set`

Set a key to a value (boolean, number, string, or nil to clear). Notifies registered watchers if value changed.

```lua
LBlackboard:set(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key name. |
| `value` | boolean|number|string|nil | The value to store. Pass nil to clear the key. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 10)
    bb:set("score", 20)
    print("score = " .. tostring(bb:get("score")))
    print("revision = " .. bb:getRevision())
end
```

---

#### `LBlackboard:snapshot`

Return a table containing all current key-value pairs as a snapshot. Useful for serialization or debug display.

```lua
LBlackboard:snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| table | A table mapping key strings to their stored values. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    bb:set("score", 42)
    bb:set("weapon", "sword")
    local snap = bb:snapshot()
    print("score = " .. tostring(snap.score))
    print("weapon = " .. tostring(snap.weapon))
end
```

---

#### `LBlackboard:unwatch`

Remove a previously registered watcher by its ID.

```lua
LBlackboard:unwatch(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The watcher ID returned by `watch()`. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:unwatch(watch_id)
    bb:set("score", 20)
    print("revision = " .. bb:getRevision())
end
```

---

#### `LBlackboard:watch`

Register a watcher callback that fires whenever the specified key changes. Use `"*"` to watch all keys.

```lua
LBlackboard:watch(key, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to watch, or `"*"` for all changes. |
| `callback` | function | Called with (key, newValue) when a change occurs. |

**Returns**

| Type | Description |
|------|-------------|
| number | A watcher ID for later removal with `unwatch()`. |

**Example**

```lua
do
    local bb = lurek.patterns.newBlackboard("game_state")
    local watch_id = bb:watch("score", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    bb:set("score", 10)
    bb:set("score", 25)
    print("revision = " .. bb:getRevision())
    bb:unwatch(watch_id)
end
```

---

## LCommandStack

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCommandStack:canRedo`

Check whether a redo operation is possible (there are commands ahead of the pointer).

```lua
LCommandStack:canRedo()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if redo is available. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    cmds:undo()
    print("can redo = " .. tostring(cmds:canRedo()))
    print("current = " .. tostring(cmds:getCurrentName()))
end
```

---

#### `LCommandStack:canUndo`

Check whether an undo operation is possible (there is a command with an undo function behind the pointer).

```lua
LCommandStack:canUndo()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if undo is available. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("can undo = " .. tostring(cmds:canUndo()))
    print("history = " .. cmds:getHistorySize())
end
```

---

#### `LCommandStack:clearAll`

Discard all command history and free associated callbacks.

```lua
LCommandStack:clearAll()
```

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("before = " .. cmds:getHistorySize())
    cmds:clearAll()
    print("after = " .. cmds:getHistorySize())
end
```

---

#### `LCommandStack:execute`

Execute a named command immediately, recording it in history. Discards any redo history ahead of the current position.

```lua
LCommandStack:execute(name, execFn, undoFn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | A descriptive name for the command (shown in history). |
| `execFn` | function | The function that performs the action. |
| `undoFn?` | function | An optional function that reverses the action. If omitted, command cannot be undone. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    print("value = " .. value)
    print("current = " .. tostring(cmds:getCurrentName()))
end
```

---

#### `LCommandStack:getCurrentName`

Return the name of the most recently executed (or undone-to) command, or nil if history is empty.

```lua
LCommandStack:getCurrentName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The command name, or nil if history is empty. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("current = " .. tostring(cmds:getCurrentName()))
    print("history = " .. cmds:getHistorySize())
end
```

---

#### `LCommandStack:getHistorySize`

Return the total number of commands in the history (both undone and available for redo).

```lua
LCommandStack:getHistorySize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total history depth. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack()
    cmds:execute("step1", function()
    end, function()
    end)
    cmds:execute("step2", function()
    end, function()
    end)
    print("history = " .. cmds:getHistorySize())
    print("can undo = " .. tostring(cmds:canUndo()))
end
```

---

#### `LCommandStack:redo`

Redo a previously undone command by re-calling its execute function. Moves the pointer forward.

```lua
LCommandStack:redo()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if redo succeeded, false if nothing to redo. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    cmds:undo()
    cmds:redo()
    print("value = " .. value)
    print("current = " .. tostring(cmds:getCurrentName()))
end
```

---

#### `LCommandStack:undo`

Undo the most recent command by calling its undo function. Moves the pointer back in history.

```lua
LCommandStack:undo()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if undo succeeded, false if nothing to undo or no undo function registered. |

**Example**

```lua
do
    local cmds = lurek.patterns.newCommandStack(10)
    local value = 1
    cmds:execute("add", function()
        value = value + 4
    end, function()
        value = value - 4
    end)
    cmds:execute("double", function()
        value = value * 2
    end, function()
        value = value / 2
    end)
    cmds:undo()
    print("value = " .. value)
    print("can redo = " .. tostring(cmds:canRedo()))
end
```

---

## LDebounce

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDebounce:cancel`

Cancel any pending debounce without firing. The callback will not be called until triggered again.

```lua
LDebounce:cancel()
```

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:cancel()
    db:update(1.1)
    print("fires = " .. db:getFireCount())
end
```

---

#### `LDebounce:getFireCount`

Return the total number of times this debounce has fired since creation.

```lua
LDebounce:getFireCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total fire count. |

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(0.3)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    db:update(0.4)
    print("fires = " .. db:getFireCount())
    print("pending = " .. tostring(db:isPending()))
end
```

---

#### `LDebounce:isPending`

Check whether the debounce is currently waiting to fire (has been triggered but wait period not yet elapsed).

```lua
LDebounce:isPending()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a fire is pending. |

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(1.0)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.2)
    print("fires = " .. db:getFireCount())
end
```

---

#### `LDebounce:onFire`

Set the callback function to invoke when the debounce fires after the wait period.

```lua
LDebounce:onFire(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | The callback to execute. |

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    print("fires = " .. db:getFireCount())
    print("pending = " .. tostring(db:isPending()))
end
```

---

#### `LDebounce:trigger`

Signal input activity. Resets the wait timer so the debounce will fire after the full wait period of inactivity.

```lua
LDebounce:trigger()
```

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    print("pending = " .. tostring(db:isPending()))
    db:update(0.6)
    print("fires = " .. db:getFireCount())
end
```

---

#### `LDebounce:update`

Advance the debounce timer. If the wait period elapsed since last trigger, fires the callback and returns true.

```lua
LDebounce:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since last update. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the debounce fired this frame. |

**Example**

```lua
do
    local db = lurek.patterns.newDebounce(0.5)
    db:onFire(function()
        print("debounce fired")
    end)
    db:trigger()
    db:update(0.6)
    print("pending = " .. tostring(db:isPending()))
    print("fires = " .. db:getFireCount())
end
```

---

## LEventBus

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LEventBus:clear`

Remove all listeners subscribed to a specific event name.

```lua
LEventBus:clear(event)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | The event name whose listeners will be removed. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    print("before = " .. bus:getListenerCount("spawn"))
    bus:clear("spawn")
    print("after = " .. bus:getListenerCount("spawn"))
end
```

---

#### `LEventBus:clearAll`

Remove all listeners from every event on this bus. Resets the bus to empty.

```lua
LEventBus:clearAll()
```

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        print("hit = " .. tostring(amount))
    end)
    print("before = " .. #bus:getEvents())
    bus:clearAll()
    print("after = " .. #bus:getEvents())
end
```

---

#### `LEventBus:emit`

Emit an event, invoking all subscribed listeners in priority order with optional payload arguments.

```lua
LEventBus:emit(event, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | The event name to emit. |
| — | — | @param ... any Additional arguments passed to each listener callback. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        print("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end)
    bus:emit("damage", 18, "fire")
    print("events = " .. #bus:getEvents())
    bus:off(id)
end
```

---

#### `LEventBus:getEvents`

Return an array of all event names that have at least one listener.

```lua
LEventBus:getEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Event name strings. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    bus:on("hit", function(amount)
        print("hit = " .. tostring(amount))
    end)
    local events = bus:getEvents()
    print("events = " .. #events)
    print("first = " .. tostring(events[1]))
end
```

---

#### `LEventBus:getListenerCount`

Return the number of active listeners for a given event name.

```lua
LEventBus:getListenerCount(event)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | The event name to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Count of currently registered listeners. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    bus:on("spawn", function(id)
        print("spawn = " .. tostring(id))
    end)
    bus:on("spawn", function(id)
        print("spawn log = " .. tostring(id))
    end)
    print("spawn listeners = " .. bus:getListenerCount("spawn"))
    print("events = " .. #bus:getEvents())
end
```

---

#### `LEventBus:off`

Unsubscribe a listener by its subscription ID. Removes the callback from the event bus.

```lua
LEventBus:off(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The subscription ID returned by `on()`. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount)
        print("damage = " .. tostring(amount))
    end)
    bus:off(id)
    bus:emit("damage", 5)
    print("listeners = " .. bus:getListenerCount("damage"))
end
```

---

#### `LEventBus:on`

Subscribe a callback to a named event. Higher priority listeners fire first.

```lua
LEventBus:on(event, callback, priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | The event name to listen for. |
| `callback` | function | The function to invoke when the event fires. |
| `priority?` | number | Listener priority (default 0). Higher values execute first. |

**Returns**

| Type | Description |
|------|-------------|
| number | A subscription ID used to unsubscribe later. |

**Example**

```lua
do
    local bus = lurek.patterns.newEventBus("game_events")
    local id = bus:on("damage", function(amount, source)
        print("damage = " .. tostring(amount) .. " from " .. tostring(source))
    end, 1)
    bus:emit("damage", 12, "ice")
    print("listeners = " .. bus:getListenerCount("damage"))
    bus:off(id)
end
```

---

## LFactory

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFactory:alias`

Create an alias that maps to an existing type name. `create(alias)` will use the canonical constructor.

```lua
LFactory:alias(alias, canonical)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `alias` | string | The alternative name. |
| `canonical` | string | The existing registered type name. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin", hp = 30}
    end)
    factory:alias("small_enemy", "goblin")
    local goblin = factory:create("small_enemy")
    print("alias type = " .. tostring(goblin and goblin.type))
    print("has alias target = " .. tostring(factory:has("small_enemy")))
end
```

---

#### `LFactory:clearAll`

Remove all registered types and constructors, resetting the factory.

```lua
LFactory:clearAll()
```

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    print("before = " .. #factory:getTypes())
    factory:clearAll()
    print("after = " .. #factory:getTypes())
end
```

---

#### `LFactory:create`

Create a new object by type name, passing additional arguments to the constructor.

```lua
LFactory:create(typeName, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | The registered type to instantiate. |
| — | — | @param ... any Extra arguments forwarded to the constructor. |

**Returns**

| Type | Description |
|------|-------------|
| table | The created object table. |
| nil | When not available. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    local bullet = factory:create("bullet", 450)
    print("bullet speed = " .. tostring(bullet and bullet.speed))
    print("types = " .. #factory:getTypes())
end
```

---

#### `LFactory:getTypes`

Return an array of all registered type names.

```lua
LFactory:getTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Type name strings. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function()
        return {type = "enemy"}
    end)
    factory:register("bullet", function()
        return {type = "bullet"}
    end)
    local types = factory:getTypes()
    print("types = " .. #types)
    print("has enemy = " .. tostring(factory:has("enemy")))
end
```

---

#### `LFactory:has`

Check whether a constructor is registered for the given type name.

```lua
LFactory:has(typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | The type name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a constructor exists for this type. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("bullet", function(speed)
        return {type = "bullet", speed = speed or 300}
    end)
    print("has bullet = " .. tostring(factory:has("bullet")))
    print("has enemy = " .. tostring(factory:has("enemy")))
end
```

---

#### `LFactory:register`

Register a constructor function for a given type name. Future `create()` calls with this type will invoke it.

```lua
LFactory:register(typeName, ctor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | The type identifier (e.g. "enemy", "bullet"). |
| `ctor` | function | A constructor function that returns a new instance. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("enemy", function(hp)
        return {type = "enemy", hp = hp or 100}
    end)
    print("has enemy = " .. tostring(factory:has("enemy")))
    print("types = " .. #factory:getTypes())
end
```

---

#### `LFactory:remove`

Unregister a type and discard its constructor function.

```lua
LFactory:remove(typeName)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `typeName` | string | The type name to remove. |

**Example**

```lua
do
    local factory = lurek.patterns.newFactory()
    factory:register("goblin", function()
        return {type = "goblin"}
    end)
    factory:remove("goblin")
    print("has goblin = " .. tostring(factory:has("goblin")))
    print("types = " .. #factory:getTypes())
end
```

---

## LFunnel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFunnel:discard`

Discard all pending entries without flushing or calling the callback.

```lua
LFunnel:discard()
```

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:discard()
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end
```

---

#### `LFunnel:flush`

Force an immediate flush of all pending entries, invoking the callback.

```lua
LFunnel:flush()
```

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end
```

---

#### `LFunnel:getFlushCount`

Return the total number of times this funnel has flushed since creation.

```lua
LFunnel:getFlushCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total flush count. |

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:flush()
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end
```

---

#### `LFunnel:onFlush`

Set the callback invoked when the funnel flushes. Receives an array of {tag, value} entries.

```lua
LFunnel:onFlush(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | Callback receiving a table array of batched entries. |

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end
```

---

#### `LFunnel:pendingCount`

Return the number of entries waiting to be flushed.

```lua
LFunnel:pendingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Pending entry count. |

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(5.0, 0, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end
```

---

#### `LFunnel:push`

Push a tagged event into the funnel. May trigger an immediate flush if the max entry count is reached.

```lua
LFunnel:push(tag, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | A category label for the event. |
| `value?` | number | Optional numeric value (default 0). |

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    print("pending = " .. funnel:pendingCount())
    funnel:update(1.1)
    print("flush count = " .. funnel:getFlushCount())
end
```

---

#### `LFunnel:update`

Advance the funnel's time window. Flushes and invokes the callback if the window elapsed.

```lua
LFunnel:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a flush occurred this frame. |

**Example**

```lua
do
    local funnel = lurek.patterns.newFunnel(1.0, 5, "damage_log")
    funnel:onFlush(function(entries)
        print("flushed = " .. #entries)
    end)
    funnel:push("fire", 10)
    funnel:push("ice", 5)
    funnel:update(1.1)
    print("pending = " .. funnel:pendingCount())
    print("flush count = " .. funnel:getFlushCount())
end
```

---

## LList

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LList:add`

Append a value to the end of the list.

```lua
LList:add(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to append. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("second = " .. tostring(list:get(2)))
end
```

---

#### `LList:clear`

Remove all items from the list. This method is available to Lua scripts.

```lua
LList:clear()
```

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add(1)
    list:add(2)
    list:add(3)
    print("before = " .. list:len())
    list:clear()
    print("after = " .. list:len())
end
```

---

#### `LList:contains`

Check whether the list contains a specific value.

```lua
LList:contains(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | string | The value to search for. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if found. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    print("contains b = " .. tostring(list:contains("b")))
    print("contains z = " .. tostring(list:contains("z")))
end
```

---

#### `LList:get`

Get the value at a 1-based index. Returns nil if out of range.

```lua
LList:get(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position. |

**Returns**

| Type | Description |
|------|-------------|
| string | The value. |
| nil | When not available. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("second = " .. tostring(list:get(2)))
    print("len = " .. list:len())
end
```

---

#### `LList:indexOf`

Find the 1-based index of the first occurrence of a value. Returns nil if not found.

```lua
LList:indexOf(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | string | The value to search for. |

**Returns**

| Type | Description |
|------|-------------|
| number | The 1-based index, or nil when the value is not found. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("beta = " .. tostring(list:indexOf("beta")))
    print("delta = " .. tostring(list:indexOf("delta")))
end
```

---

#### `LList:insert`

Insert a value at a 1-based index, shifting subsequent items right.

```lua
LList:insert(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based insertion position. |
| `value` | any | The value to insert. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("c")
    list:insert(2, "b")
    print("second = " .. tostring(list:get(2)))
    print("len = " .. list:len())
end
```

---

#### `LList:isEmpty`

Check whether the list is empty. This method is available to Lua scripts.

```lua
LList:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    print("empty = " .. tostring(list:isEmpty()))
    list:push("a")
    print("after push = " .. tostring(list:isEmpty()))
end
```

---

#### `LList:len`

Return the number of items in the list.

```lua
LList:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    print("len = " .. list:len())
    print("beta = " .. tostring(list:indexOf("beta")))
end
```

---

#### `LList:pop`

Remove and return the last value. Returns nil if empty.

```lua
LList:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The popped value. |
| nil | When not available. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local popped = list:pop()
    print("popped = " .. tostring(popped))
    print("len = " .. list:len())
end
```

---

#### `LList:push`

Append a value to the end of the list (alias for add).

```lua
LList:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to append. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    print("len = " .. list:len())
    print("last = " .. tostring(list:get(3)))
end
```

---

#### `LList:remove`

Remove and return the value at a 1-based index. Returns nil if out of range.

```lua
LList:remove(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position to remove. |

**Returns**

| Type | Description |
|------|-------------|
| string | The removed value. |
| nil | When not available. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:add("alpha")
    list:add("beta")
    list:add("gamma")
    local removed = list:remove(2)
    print("removed = " .. tostring(removed))
    print("len = " .. list:len())
end
```

---

#### `LList:reverse`

Reverse the order of all items in the list in-place.

```lua
LList:reverse()
```

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    list:reverse()
    print("first = " .. tostring(list:get(1)))
    print("last = " .. tostring(list:get(3)))
end
```

---

#### `LList:set`

Replace the value at a 1-based index. Errors if index is 0 or out of range.

```lua
LList:set(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position. |
| `value` | any | The new value. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:set(2, "B")
    print("second = " .. tostring(list:get(2)))
    print("len = " .. list:len())
end
```

---

#### `LList:shift`

Remove and return the first value. Returns nil if empty.

```lua
LList:shift()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The shifted value. |
| nil | When not available. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local shifted = list:shift()
    print("shifted = " .. tostring(shifted))
    print("len = " .. list:len())
end
```

---

#### `LList:toArray`

Return all items as an array table. This method is available to Lua scripts.

```lua
LList:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of all values. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("a")
    list:push("b")
    list:push("c")
    local arr = list:toArray()
    print("array = " .. #arr)
    print("first = " .. tostring(arr[1]))
end
```

---

#### `LList:unshift`

Insert a value at the beginning of the list.

```lua
LList:unshift(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to prepend. |

**Example**

```lua
do
    local list = lurek.patterns.newList()
    list:push("b")
    list:push("c")
    list:unshift("a")
    print("first = " .. tostring(list:get(1)))
    print("len = " .. list:len())
end
```

---

## LMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMap:clear`

Remove all entries from the map. This method is available to Lua scripts.

```lua
LMap:clear()
```

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    print("before = " .. map:len())
    map:clear()
    print("after = " .. map:len())
end
```

---

#### `LMap:entries`

Return an array of {key, value} tables for all entries.

```lua
LMap:entries()
```

**Returns**

| Type | Description |
|------|-------------|
| LMapEntriesResult | Array of entry tables. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("a", 1)
    map:set("b", 2)
    local entries = map:entries()
    print("entries = " .. #entries)
    print("len = " .. map:len())
end
```

---

#### `LMap:get`

Retrieve the value for a key. Returns nil if the key does not exist.

```lua
LMap:get(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to look up. |

**Returns**

| Type | Description |
|------|-------------|
| string | The value. |
| nil | When not available. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("name = " .. tostring(map:get("name")))
    print("has level = " .. tostring(map:has("level")))
end
```

---

#### `LMap:has`

Check whether a key exists in the map.

```lua
LMap:has(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if present. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("has level = " .. tostring(map:has("level")))
    print("has class = " .. tostring(map:has("class")))
end
```

---

#### `LMap:isEmpty`

Check whether the map has no entries.

```lua
LMap:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    print("empty = " .. tostring(map:isEmpty()))
    map:set("a", 1)
    print("after set = " .. tostring(map:isEmpty()))
end
```

---

#### `LMap:keys`

Return an array of all keys in the map.

```lua
LMap:keys()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Key strings. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local keys = map:keys()
    print("keys = " .. #keys)
    print("first = " .. tostring(keys[1]))
end
```

---

#### `LMap:len`

Return the number of key-value pairs.

```lua
LMap:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("len = " .. map:len())
    print("has name = " .. tostring(map:has("name")))
end
```

---

#### `LMap:merge`

Copy all entries from another [LMap](#lmap) into this map. Existing keys are overwritten.

```lua
LMap:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LMap](#lmap) | The source map to merge from. |

**Example**

```lua
do
    local m1 = lurek.patterns.newMap()
    local m2 = lurek.patterns.newMap()
    m1:set("a", 1)
    m2:set("b", 2)
    m1:merge(m2)
    print("len = " .. m1:len())
    print("b = " .. tostring(m1:get("b")))
end
```

---

#### `LMap:remove`

Remove a key from the map. Returns true if it was present.

```lua
LMap:remove(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if removed, false if not found. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("class", "warrior")
    map:remove("class")
    print("has class = " .. tostring(map:has("class")))
    print("len = " .. map:len())
end
```

---

#### `LMap:set`

Set a key-value pair in the map. Replaces any existing value for the same key.

```lua
LMap:set(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The key. |
| `value` | any | The value to store. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    print("name = " .. tostring(map:get("name")))
    print("len = " .. map:len())
end
```

---

#### `LMap:values`

Return an array of all values in the map.

```lua
LMap:values()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of values. |

**Example**

```lua
do
    local map = lurek.patterns.newMap()
    map:set("name", "hero")
    map:set("level", 5)
    local values = map:values()
    print("values = " .. #values)
    print("first = " .. tostring(values[1]))
end
```

---

## LMediator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMediator:broadcast`

Send a message to all handlers on all channels. Every registered handler receives the payload.

```lua
LMediator:broadcast(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... any Arguments passed to every handler. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        print("video = " .. tostring(msg))
    end)
    med:broadcast("pause")
    print("channels = " .. #med:channels())
    print("audio handlers = " .. med:handlerCount("audio"))
end
```

---

#### `LMediator:channels`

Return an array of all channel names that have at least one handler.

```lua
LMediator:channels()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Channel name strings. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        print("video = " .. tostring(msg))
    end)
    local channels = med:channels()
    print("channels = " .. #channels)
    print("first = " .. tostring(channels[1]))
end
```

---

#### `LMediator:clear`

Remove all channels and handlers, resetting the mediator.

```lua
LMediator:clear()
```

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("video", function(msg)
        print("video = " .. tostring(msg))
    end)
    print("before = " .. #med:channels())
    med:clear()
    print("after = " .. #med:channels())
end
```

---

#### `LMediator:handlerCount`

Return the number of handlers registered on a specific channel.

```lua
LMediator:handlerCount(channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | The channel name. |

**Returns**

| Type | Description |
|------|-------------|
| number | Handler count. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    med:on("audio", function(msg)
        print("audio log = " .. tostring(msg))
    end)
    print("audio handlers = " .. med:handlerCount("audio"))
    print("channels = " .. #med:channels())
end
```

---

#### `LMediator:off`

Unregister a handler from a channel by its ID.

```lua
LMediator:off(channel, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | The channel name. |
| `id` | number | The handler ID to remove. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:off("ui", id)
    med:send("ui", "hp", 80)
    print("handlers = " .. med:handlerCount("ui"))
end
```

---

#### `LMediator:on`

Register a handler callback on a named channel. Returns an ID for unregistration.

```lua
LMediator:on(channel, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | The message channel name. |
| `callback` | function | The handler to invoke when a message is sent to this channel. |

**Returns**

| Type | Description |
|------|-------------|
| number | Handler ID for later removal. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    print("handlers = " .. med:handlerCount("ui"))
    med:off("ui", id)
end
```

---

#### `LMediator:removeChannel`

Remove an entire channel and all its handlers.

```lua
LMediator:removeChannel(channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | The channel to remove. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    med:on("audio", function(msg)
        print("audio = " .. tostring(msg))
    end)
    print("before = " .. #med:channels())
    med:removeChannel("audio")
    print("after = " .. #med:channels())
end
```

---

#### `LMediator:send`

Send a message to all handlers on a specific channel with optional payload arguments.

```lua
LMediator:send(channel, ...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | The target channel name. |
| — | — | @param ... any Additional arguments passed to each handler. |

**Example**

```lua
do
    local med = lurek.patterns.newMediator()
    local id = med:on("ui", function(msg, data)
        print(msg .. " = " .. tostring(data))
    end)
    med:send("ui", "hp", 80)
    print("channels = " .. #med:channels())
    med:off("ui", id)
end
```

---

## LObjectPool

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LObjectPool:acquire`

Take an idle object from the pool and mark it active. Returns nil if the pool is empty.

```lua
LObjectPool:acquire()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The acquired object table. |
| nil | If none available. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    print("acquired = " .. tostring(obj and obj.id))
    print("active = " .. pool:getActiveCount())
end
```

---

#### `LObjectPool:add`

Add an object to the pool's idle set, making it available for future acquisition.

```lua
LObjectPool:add(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The object value to store in the pool. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
end
```

---

#### `LObjectPool:clearAll`

Destroy all objects (active and idle) and reset the pool to empty.

```lua
LObjectPool:clearAll()
```

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    print("before = " .. pool:getTotalCount())
    pool:clearAll()
    print("after = " .. pool:getTotalCount())
end
```

---

#### `LObjectPool:getActiveCount`

Return the number of objects currently checked out from the pool.

```lua
LObjectPool:getActiveCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of active (in-use) objects. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    local obj = pool:acquire()
    print("active = " .. pool:getActiveCount())
    print("got = " .. tostring(obj and obj.id))
end
```

---

#### `LObjectPool:getAvailableCount`

Return the number of idle objects ready for acquisition.

```lua
LObjectPool:getAvailableCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of available (idle) objects. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    pool:acquire()
    print("available = " .. pool:getAvailableCount())
    print("total = " .. pool:getTotalCount())
end
```

---

#### `LObjectPool:getTotalCount`

Return the total number of objects managed by this pool (active + idle).

```lua
LObjectPool:getTotalCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total object count. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1})
    pool:add({id = 2})
    print("total = " .. pool:getTotalCount())
    print("available = " .. pool:getAvailableCount())
end
```

---

#### `LObjectPool:release`

Return an active object back to the pool's idle set so it can be reused.

```lua
LObjectPool:release(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The object value to release back into the pool. |

**Example**

```lua
do
    local pool = lurek.patterns.newObjectPool()
    pool:add({id = 1, active = false})
    pool:add({id = 2, active = false})
    local obj = pool:acquire()
    pool:release(obj)
    print("active = " .. pool:getActiveCount())
    print("available = " .. pool:getAvailableCount())
end
```

---

## LObserver

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LObserver:get`

Retrieve the current value for a key. Returns nil if not set.

```lua
LObserver:get(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The property name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| number | The stored value. |
| nil | When not available. |

**Example**

```lua
do
    local obs = lurek.patterns.newObserver("player_stats")
    obs:set("hp", 90)
    print("hp = " .. tostring(obs:get("hp")))
    print("subs = " .. obs:getCount())
end
```

---

#### `LObserver:getCount`

Return the total number of active subscriptions across all keys.

```lua
LObserver:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total subscription count. |

**Example**

```lua
do
    local obs = lurek.patterns.newObserver("player_stats")
    obs:subscribe("score", function(key, value)
        print(key .. " = " .. tostring(value))
    end, true)
    print("subs = " .. obs:getCount())
    obs:set("score", 100)
    print("after = " .. obs:getCount())
end
```

---

#### `LObserver:set`

Set a value by key and notify all subscribers watching that key.

```lua
LObserver:set(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The property name. |
| `value` | number | The new value to store. |

**Example**

```lua
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    obs:set("hp", 75)
    print("hp = " .. tostring(obs:get("hp")))
    obs:unsubscribe(id)
end
```

---

#### `LObserver:subscribe`

Subscribe to changes on a specific key. The callback receives (key, newValue) on each change.

```lua
LObserver:subscribe(key, callback, once)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The property name to watch. |
| `callback` | function | Called with (key, newValue) when the property changes. |
| `once?` | boolean | If true, automatically unsubscribe after the first notification. |

**Returns**

| Type | Description |
|------|-------------|
| number | A subscription ID for later removal with `unsubscribe()`. |

**Example**

```lua
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:set("hp", 100)
    print("subs = " .. obs:getCount())
    obs:unsubscribe(id)
end
```

---

#### `LObserver:unsubscribe`

Remove a subscription by its ID. The callback will no longer fire.

```lua
LObserver:unsubscribe(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The subscription ID returned by `subscribe()`. |

**Example**

```lua
do
    local obs = lurek.patterns.newObserver("player_stats")
    local id = obs:subscribe("hp", function(key, value)
        print(key .. " = " .. tostring(value))
    end)
    obs:unsubscribe(id)
    obs:set("hp", 50)
    print("subs = " .. obs:getCount())
end
```

---

## LPatternGraph

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPatternGraph:addEdge`

Add a directed (or undirected) edge between two nodes with optional weight and label.

```lua
LPatternGraph:addEdge(from, to, weight, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source node ID. |
| `to` | number | Target node ID. |
| `weight?` | number | Edge weight (default 1.0). |
| `label?` | string | Optional edge label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The new edge's ID. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 2.5, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end
```

---

#### `LPatternGraph:addNode`

Add a node to the graph with an optional label and payload value.

```lua
LPatternGraph:addNode(label, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `label?` | string | Optional node label. |
| `value?` | table | Optional payload stored with the node. |

**Returns**

| Type | Description |
|------|-------------|
| number | The new node's ID. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A", {cost = 10})
    local b = g:addNode("B", {cost = 5})
    g:addEdge(a, b, 1.0, "road")
    print("nodes = " .. g:nodeCount())
    print("has a = " .. tostring(g:hasNode(a)))
end
```

---

#### `LPatternGraph:bfs`

Perform a breadth-first search from a node. Returns visited node IDs in BFS order.

```lua
LPatternGraph:bfs(start)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | The starting node ID. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of visited node IDs. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:bfs(a)
    print("bfs = " .. #order)
    print("connected = " .. tostring(g:isConnected(a, c)))
end
```

---

#### `LPatternGraph:clearAll`

Remove all nodes, edges, and payloads from the graph.

```lua
LPatternGraph:clearAll()
```

**Example**

```lua
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    print("before = " .. g:nodeCount())
    g:clearAll()
    print("after = " .. g:nodeCount())
end
```

---

#### `LPatternGraph:dfs`

Perform a depth-first search from a node. Returns visited node IDs in DFS order.

```lua
LPatternGraph:dfs(start)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | The starting node ID. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of visited node IDs. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local order = g:dfs(a)
    print("dfs = " .. #order)
    print("connected = " .. tostring(g:isConnected(a, c)))
end
```

---

#### `LPatternGraph:edgeCount`

Return the total number of edges in the graph.

```lua
LPatternGraph:edgeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Edge count. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end
```

---

#### `LPatternGraph:getNodeValue`

Retrieve the payload value stored on a node. Returns nil if no payload.

```lua
LPatternGraph:getNodeValue(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The node ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | The payload. |
| nil | When not available. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    local value = g:getNodeValue(a)
    print("room size = " .. tostring(value and value.size))
    print("edges = " .. g:edgeCount())
end
```

---

#### `LPatternGraph:hasNode`

Check whether a node with the given ID exists in the graph.

```lua
LPatternGraph:hasNode(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Node ID to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the node exists. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    g:addEdge(a, b)
    print("has a = " .. tostring(g:hasNode(a)))
    print("has 99 = " .. tostring(g:hasNode(99)))
end
```

---

#### `LPatternGraph:isConnected`

Check whether there is any path from one node to another.

```lua
LPatternGraph:isConnected(from, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source node ID. |
| `to` | number | Target node ID. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if a path exists. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    print("start to end = " .. tostring(g:isConnected(a, c)))
    print("start to start = " .. tostring(g:isConnected(a, a)))
end
```

---

#### `LPatternGraph:neighbors`

Return an array of node IDs directly connected to the given node.

```lua
LPatternGraph:neighbors(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The node ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of neighbor node IDs. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("start")
    local b = g:addNode("mid")
    local c = g:addNode("end")
    g:addEdge(a, b)
    g:addEdge(b, c)
    local neighbors = g:neighbors(b)
    print("neighbors = " .. #neighbors)
    print("has b = " .. tostring(g:hasNode(b)))
end
```

---

#### `LPatternGraph:nodeCount`

Return the total number of nodes in the graph.

```lua
LPatternGraph:nodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Node count. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph(true)
    local a = g:addNode("A")
    local b = g:addNode("B")
    g:addEdge(a, b, 1.0, "road")
    print("nodes = " .. g:nodeCount())
    print("edges = " .. g:edgeCount())
end
```

---

#### `LPatternGraph:removeEdge`

Remove an edge by its ID. Returns true if it existed.

```lua
LPatternGraph:removeEdge(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The edge ID to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if removed. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room")
    local b = g:addNode("hall")
    local edge = g:addEdge(a, b, 2.0, "door")
    g:removeEdge(edge)
    print("edges = " .. g:edgeCount())
    print("nodes = " .. g:nodeCount())
end
```

---

#### `LPatternGraph:removeNode`

Remove a node and all its connected edges. Returns true if the node existed.

```lua
LPatternGraph:removeNode(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The node ID to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if removed. |

**Example**

```lua
do
    local g = lurek.patterns.newGraph()
    local a = g:addNode("room", {size = 10})
    local b = g:addNode("hall")
    g:addEdge(a, b, 2.0, "door")
    g:removeNode(b)
    print("nodes = " .. g:nodeCount())
    print("has hall = " .. tostring(g:hasNode(b)))
end
```

---

## LPriorityQueue

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPriorityQueue:clearAll`

Remove all items from the queue. This method is available to Lua scripts.

```lua
LPriorityQueue:clearAll()
```

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("before = " .. pq:len())
    pq:clearAll()
    print("after = " .. pq:len())
end
```

---

#### `LPriorityQueue:isEmpty`

Check whether the queue contains no items.

```lua
LPriorityQueue:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the queue is empty. |

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    print("empty = " .. tostring(pq:isEmpty()))
    pq:push(10, "high_task", "high")
    print("after push = " .. tostring(pq:isEmpty()))
end
```

---

#### `LPriorityQueue:len`

Return the number of items currently in the queue.

```lua
LPriorityQueue:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("len = " .. pq:len())
    print("empty = " .. tostring(pq:isEmpty()))
end
```

---

#### `LPriorityQueue:peek`

Return the highest-priority item without removing it. Returns nil if empty.

```lua
LPriorityQueue:peek()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The item table. |
| nil | When not available. |

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("peek = " .. tostring(pq:peek()))
    print("len = " .. pq:len())
end
```

---

#### `LPriorityQueue:pop`

Remove and return the highest-priority item. Returns nil if the queue is empty.

```lua
LPriorityQueue:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| table | The item table. |
| nil | When not available. |

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    local value = pq:pop()
    print("popped = " .. tostring(value))
    print("len = " .. pq:len())
end
```

---

#### `LPriorityQueue:push`

Add an item with a numeric priority. Higher priority items are dequeued first.

```lua
LPriorityQueue:push(priority, value, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `priority` | number | The priority value (higher = dequeued sooner). |
| `value` | any | The payload value to store. |
| `label?` | string | Optional human-readable label for debugging. |

**Returns**

| Type | Description |
|------|-------------|
| number | The internal ID of the enqueued item. |

**Example**

```lua
do
    local pq = lurek.patterns.newPriorityQueue("tasks")
    pq:push(1, "low_task", "low")
    pq:push(10, "high_task", "high")
    print("peek = " .. tostring(pq:peek()))
    print("len = " .. pq:len())
end
```

---

## LQueue

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQueue:back`

Return the back value without removing it. Returns nil if empty.

```lua
LQueue:back()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The back value. |
| nil | When not available. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("back = " .. tostring(q:back()))
    print("len = " .. q:len())
end
```

---

#### `LQueue:clear`

Remove all items from the queue. This method is available to Lua scripts.

```lua
LQueue:clear()
```

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    print("before = " .. q:len())
    q:clear()
    print("after = " .. q:len())
end
```

---

#### `LQueue:dequeue`

Remove and return the front value. Returns nil if empty.

```lua
LQueue:dequeue()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The dequeued value. |
| nil | When not available. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    local value = q:dequeue()
    print("dequeued = " .. tostring(value))
    print("len = " .. q:len())
end
```

---

#### `LQueue:dequeueBack`

Remove and return the back value. Returns nil if empty.

```lua
LQueue:dequeueBack()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The dequeued value. |
| nil | When not available. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:dequeueBack()
    print("dequeued back = " .. tostring(value))
    print("len = " .. q:len())
end
```

---

#### `LQueue:enqueue`

Add a value to the back of the queue. Returns false if at capacity.

```lua
LQueue:enqueue(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to enqueue. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if enqueued, false if full. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("front = " .. tostring(q:front()))
    print("len = " .. q:len())
end
```

---

#### `LQueue:enqueueFront`

Add a value to the front of the queue (priority insertion). Returns false if at capacity.

```lua
LQueue:enqueueFront(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to insert at the front. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if enqueued, false if full. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueueFront("priority")
    print("front = " .. tostring(q:front()))
    print("len = " .. q:len())
end
```

---

#### `LQueue:front`

Return the front value without removing it. Returns nil if empty.

```lua
LQueue:front()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The front value. |
| nil | When not available. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("front = " .. tostring(q:front()))
    print("back = " .. tostring(q:back()))
end
```

---

#### `LQueue:insertAt`

Insert a value at a 1-based index in the queue. Returns false if at capacity.

```lua
LQueue:insertAt(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based insertion position. |
| `value` | any | The value to insert. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if inserted, false if full. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("c")
    q:insertAt(2, "b")
    print("at 2 = " .. tostring(q:peekAt(2)))
    print("len = " .. q:len())
end
```

---

#### `LQueue:isEmpty`

Check whether the queue is empty. This method is available to Lua scripts.

```lua
LQueue:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    print("empty = " .. tostring(q:isEmpty()))
    q:enqueue("msg1")
    print("after enqueue = " .. tostring(q:isEmpty()))
end
```

---

#### `LQueue:isFull`

Check whether the queue has reached its capacity limit.

```lua
LQueue:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if full. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(2)
    q:enqueue("a")
    q:enqueue("b")
    print("full = " .. tostring(q:isFull()))
    print("len = " .. q:len())
end
```

---

#### `LQueue:len`

Return the current number of items in the queue.

```lua
LQueue:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(10)
    q:enqueue("msg1")
    q:enqueue("msg2")
    print("len = " .. q:len())
    print("empty = " .. tostring(q:isEmpty()))
end
```

---

#### `LQueue:peekAt`

Return the value at a 1-based index without removing it. Returns nil if out of range.

```lua
LQueue:peekAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position. |

**Returns**

| Type | Description |
|------|-------------|
| string | The value. |
| nil | When not available. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    print("at 2 = " .. tostring(q:peekAt(2)))
    print("len = " .. q:len())
end
```

---

#### `LQueue:removeAt`

Remove and return the value at a 1-based index. Returns nil if out of range.

```lua
LQueue:removeAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position to remove. |

**Returns**

| Type | Description |
|------|-------------|
| string | The removed value. |
| nil | When not available. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local value = q:removeAt(2)
    print("removed = " .. tostring(value))
    print("len = " .. q:len())
end
```

---

#### `LQueue:toArray`

Return all queue items as an array table (front to back).

```lua
LQueue:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of all values. |

**Example**

```lua
do
    local q = lurek.patterns.newQueue(5)
    q:enqueue("a")
    q:enqueue("b")
    q:enqueue("c")
    local arr = q:toArray()
    print("array = " .. #arr)
    print("first = " .. tostring(arr[1]))
end
```

---

## LRelationshipManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRelationshipManager:adjustValue`

Adds a delta to the numeric relationship value between two entity ids.

```lua
LRelationshipManager:adjustValue(a, b, delta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |
| `delta` | number | Signed amount added to the current pair value. |

---

#### `LRelationshipManager:defineType`

Defines a named relationship type with ordered level labels and an optional default level for new pairs.

```lua
LRelationshipManager:defineType(name, levels, default_level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Relationship type name used for later `setLevel` and `getLevel` calls. |
| `levels` | string[] | Array table of allowed level labels in their semantic order. |
| `default_level?` | string | Optional fallback level assigned when a pair has no explicit level for this type. |

---

#### `LRelationshipManager:getLevel`

Returns the effective named level for one relationship type on a pair, falling back to the type default when no explicit level exists.

```lua
LRelationshipManager:getLevel(a, b, type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id for the relationship pair. |
| `b` | number | Target entity id for the relationship pair. |
| `type_name` | string | Registered relationship type name to query. |

**Returns**

| Type | Description |
|------|-------------|
| string? | Stored level label or the type default when available, otherwise `nil` if the type is unknown. |

---

#### `LRelationshipManager:getValue`

Returns the numeric relationship value between two entity ids.

```lua
LRelationshipManager:getValue(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Numeric value stored for the pair, or zero when unset. |

---

#### `LRelationshipManager:pairCount`

Returns how many entity-id pairs currently have tracked relationship data.

```lua
LRelationshipManager:pairCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of stored relationship pairs. |

---

#### `LRelationshipManager:removePair`

Removes all tracked relationship data between two entity ids.

```lua
LRelationshipManager:removePair(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |

---

#### `LRelationshipManager:removeType`

Removes a named relationship type definition.

```lua
LRelationshipManager:removeType(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Relationship type name to delete. |

---

#### `LRelationshipManager:setLevel`

Assigns a named level for one relationship type between two entity ids and reports whether the type-level pair was accepted.

```lua
LRelationshipManager:setLevel(a, b, type_name, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id for the relationship pair. |
| `b` | number | Target entity id for the relationship pair. |
| `type_name` | string | Registered relationship type name to mutate. |
| `level` | string | Level label to store for the given type on this entity pair. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the type exists and the supplied level is valid for that type. |

---

#### `LRelationshipManager:setValue`

Sets the numeric relationship value between two entity ids.

```lua
LRelationshipManager:setValue(a, b, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | Source entity id. |
| `b` | number | Target entity id. |
| `value` | number | Numeric value stored for the pair. |

---

#### `LRelationshipManager:type`

Returns the Lua-visible type name for this relationship manager handle.

```lua
LRelationshipManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LRelationshipManager](#lrelationshipmanager)`. |

---

#### `LRelationshipManager:typeNames`

Returns the defined relationship type names.

```lua
LRelationshipManager:typeNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Array table of registered relationship type names. |

---

#### `LRelationshipManager:typeOf`

Returns whether this relationship manager handle matches a supported type name.

```lua
LRelationshipManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LRelationshipManager](#lrelationshipmanager)` and `LObject`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

## LRing

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRing:average`

Return the arithmetic mean of all numeric values in the ring.

```lua
LRing:average()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Average value (0 if empty). |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("average = " .. ring:average())
    print("len = " .. ring:len())
end
```

---

#### `LRing:clear`

Remove all entries from the ring. This method is available to Lua scripts.

```lua
LRing:clear()
```

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    print("before = " .. ring:len())
    ring:clear()
    print("after = " .. ring:len())
end
```

---

#### `LRing:isFull`

Check whether the ring has reached its maximum capacity.

```lua
LRing:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if full. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(3, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("full = " .. tostring(ring:isFull()))
    print("len = " .. ring:len())
end
```

---

#### `LRing:latest`

Return the most recently pushed entry as a table with id, tag, value, and text fields. Returns nil if empty.

```lua
LRing:latest()
```

**Returns**

| Type | Description |
|------|-------------|
| LRingLatestResult | nil | Entry table or nil. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local entry = ring:latest()
    print("latest = " .. tostring(entry and entry.value))
    print("len = " .. ring:len())
end
```

---

#### `LRing:len`

Return the number of entries currently in the ring.

```lua
LRing:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("len = " .. ring:len())
    print("full = " .. tostring(ring:isFull()))
end
```

---

#### `LRing:push`

Push a number or string value into the ring. Overwrites the oldest entry if the ring is full.

```lua
LRing:push(value, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number|string | The value to store. |
| `tag?` | string | Optional label for categorizing entries. |

**Returns**

| Type | Description |
|------|-------------|
| number | The internal ID of the new entry. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("len = " .. ring:len())
    print("sum = " .. ring:sum())
end
```

---

#### `LRing:sum`

Return the sum of all numeric values in the ring. Non-numeric entries contribute zero.

```lua
LRing:sum()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sum of values. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    print("sum = " .. ring:sum())
    print("len = " .. ring:len())
end
```

---

#### `LRing:toArray`

Return all entries in the ring as an ordered array of tables (oldest to newest).

```lua
LRing:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| LRingToArrayResult | Array of entry tables with id, tag, value, and text fields. |

**Example**

```lua
do
    local ring = lurek.patterns.newRing(5, "fps_samples")
    ring:push(60)
    ring:push(58)
    ring:push(62)
    local arr = ring:toArray()
    print("array = " .. #arr)
    print("latest = " .. tostring(ring:latest() and ring:latest().value))
end
```

---

## LServiceLocator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LServiceLocator:clearAll`

Remove all registered services and reset the locator.

```lua
LServiceLocator:clearAll()
```

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 0.6})
    print("before = " .. #services:getServices())
    services:clearAll()
    print("after = " .. #services:getServices())
end
```

---

#### `LServiceLocator:getServices`

Return an array of all registered service names.

```lua
LServiceLocator:getServices()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Service name strings. |

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    services:provide("audio", {volume = 1.0})
    local names = services:getServices()
    print("services = " .. #names)
    print("first = " .. tostring(names[1]))
end
```

---

#### `LServiceLocator:has`

Check whether a service with the given name is currently registered.

```lua
LServiceLocator:has(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The service name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the service exists. |

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("input", {keyboard = true})
    print("has input = " .. tostring(services:has("input")))
    print("has physics = " .. tostring(services:has("physics")))
end
```

---

#### `LServiceLocator:locate`

Retrieve a registered service by name. Returns nil if not found.

```lua
LServiceLocator:locate(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The service name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| table | The service table. |
| nil | If not registered. |

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("audio", {volume = 0.8, muted = false})
    local audio = services:locate("audio")
    print("audio volume = " .. tostring(audio and audio.volume))
    print("has audio = " .. tostring(services:has("audio")))
end
```

---

#### `LServiceLocator:provide`

Register a service instance under a given name. Replaces any previously registered service with the same name.

```lua
LServiceLocator:provide(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique identifier for the service. |
| `value` | any | The service value to register. |

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("renderer", {backend = "wgpu"})
    print("has renderer = " .. tostring(services:has("renderer")))
    print("services = " .. #services:getServices())
end
```

---

#### `LServiceLocator:remove`

Unregister and discard a service by name.

```lua
LServiceLocator:remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The service name to remove. |

**Example**

```lua
do
    local services = lurek.patterns.newServiceLocator()
    services:provide("save", {slot = 1})
    services:remove("save")
    print("has save = " .. tostring(services:has("save")))
    print("services = " .. #services:getServices())
end
```

---

## LSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSet:add`

Add a string to the set. Returns true if it was not already present.

```lua
LSet:add(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The string to add. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if newly added, false if already existed. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    print("len = " .. set:len())
    print("has fire = " .. tostring(set:has("fire")))
end
```

---

#### `LSet:clear`

Remove all items from the set. This method is available to Lua scripts.

```lua
LSet:clear()
```

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("x")
    set:add("y")
    print("before = " .. set:len())
    set:clear()
    print("after = " .. set:len())
end
```

---

#### `LSet:has`

Check whether a string is in the set.

```lua
LSet:has(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The string to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if present. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    print("has fire = " .. tostring(set:has("fire")))
    print("has wind = " .. tostring(set:has("wind")))
end
```

---

#### `LSet:intersection`

Return a new set containing only items present in both this set and another.

```lua
LSet:intersection(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LSet](#lset) | The other set to intersect with. |

**Returns**

| Type | Description |
|------|-------------|
| [LSet](#lset) | A new set with only shared items. |

**Example**

```lua
do
    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local inter = a:intersection(b)
    print("intersection = " .. inter:len())
    print("union = " .. a:union(b):len())
end
```

---

#### `LSet:isEmpty`

Check whether the set is empty. This method is available to Lua scripts.

```lua
LSet:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    print("empty = " .. tostring(set:isEmpty()))
    set:add("x")
    print("after add = " .. tostring(set:isEmpty()))
end
```

---

#### `LSet:len`

Return the number of items in the set.

```lua
LSet:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:add("wind")
    print("len = " .. set:len())
    print("has fire = " .. tostring(set:has("fire")))
end
```

---

#### `LSet:remove`

Remove a string from the set. Returns true if it was present.

```lua
LSet:remove(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | The string to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if removed, false if not found. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    set:remove("ice")
    print("has ice = " .. tostring(set:has("ice")))
    print("len = " .. set:len())
end
```

---

#### `LSet:toArray`

Return all set items as an array table.

```lua
LSet:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | String values. |

**Example**

```lua
do
    local set = lurek.patterns.newSet()
    set:add("fire")
    set:add("ice")
    local arr = set:toArray()
    print("array = " .. #arr)
    print("len = " .. set:len())
end
```

---

#### `LSet:union`

Return a new set containing all items from both this set and another.

```lua
LSet:union(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LSet](#lset) | The other set to merge with. |

**Returns**

| Type | Description |
|------|-------------|
| [LSet](#lset) | A new set with the union of both. |

**Example**

```lua
do
    local a = lurek.patterns.newSet()
    local b = lurek.patterns.newSet()
    a:add("x")
    a:add("y")
    b:add("y")
    b:add("z")
    local union = a:union(b)
    print("union = " .. union:len())
    print("intersection = " .. a:intersection(b):len())
end
```

---

## LSimpleState

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSimpleState:addState`

Register a named state with optional enter, exit, and update callbacks.

```lua
LSimpleState:addState(name, callbacks)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique state identifier. |
| `callbacks?` | table | Table with optional fields: `enter` (function), `exit` (function), `update` (function receiving dt). |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end
    })
    fsm:addState("walk", {
        enter = function()
            print("enter walk")
        end
    })
    print("has walk = " .. tostring(fsm:hasState("walk")))
    print("states = " .. #fsm:getStates())
end
```

---

#### `LSimpleState:clearAll`

Remove all states and their callbacks, resetting the state machine.

```lua
LSimpleState:clearAll()
```

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    print("before = " .. #fsm:getStates())
    fsm:clearAll()
    print("after = " .. #fsm:getStates())
end
```

---

#### `LSimpleState:getCurrent`

Return the name of the currently active state, or nil if no state is set.

```lua
LSimpleState:getCurrent()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current state name, or nil if no state is set. |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end
    })
    fsm:transitionTo("idle")
    print("current = " .. tostring(fsm:getCurrent()))
    print("states = " .. #fsm:getStates())
end
```

---

#### `LSimpleState:getStates`

Return an array of all registered state names.

```lua
LSimpleState:getStates()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | State name strings. |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    fsm:addState("pause")
    print("states = " .. #fsm:getStates())
    print("has pause = " .. tostring(fsm:hasState("pause")))
end
```

---

#### `LSimpleState:hasState`

Check whether a state with the given name is registered.

```lua
LSimpleState:hasState(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | State name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the state exists. |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("menu")
    fsm:addState("game")
    print("has menu = " .. tostring(fsm:hasState("menu")))
    print("has pause = " .. tostring(fsm:hasState("pause")))
end
```

---

#### `LSimpleState:transitionTo`

Transition to a new state. Calls the current state's `exit` and the target state's `enter` callbacks.

```lua
LSimpleState:transitionTo(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The state to transition to. Must be previously added. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the transition happened, false if the target state does not exist. |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        enter = function()
            print("enter idle")
        end
    })
    fsm:addState("walk", {
        enter = function()
            print("enter walk")
        end
    })
    fsm:transitionTo("walk")
    print("current = " .. tostring(fsm:getCurrent()))
    print("has idle = " .. tostring(fsm:hasState("idle")))
end
```

---

#### `LSimpleState:update`

Call the current state's update callback with the frame delta time.

```lua
LSimpleState:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since last frame. |

**Example**

```lua
do
    local fsm = lurek.patterns.newSimpleState()
    fsm:addState("idle", {
        update = function(dt)
            print("tick idle = " .. dt)
        end
    })
    fsm:transitionTo("idle")
    fsm:update(0.016)
    print("current = " .. tostring(fsm:getCurrent()))
end
```

---

## LStack

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStack:clear`

Remove all items from the stack. This method is available to Lua scripts.

```lua
LStack:clear()
```

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    print("before = " .. st:len())
    st:clear()
    print("after = " .. st:len())
end
```

---

#### `LStack:insertAt`

Insert a value at a 1-based index in the stack, shifting items above it. Returns false if at capacity.

```lua
LStack:insertAt(index, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based insertion position. |
| `value` | any | The value to insert. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if inserted, false if full. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("c")
    st:insertAt(2, "b")
    print("at 2 = " .. tostring(st:peekAt(2)))
    print("len = " .. st:len())
end
```

---

#### `LStack:isEmpty`

Check whether the stack is empty. This method is available to Lua scripts.

```lua
LStack:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(100)
    print("empty = " .. tostring(st:isEmpty()))
    st:push("first")
    print("after push = " .. tostring(st:isEmpty()))
end
```

---

#### `LStack:isFull`

Check whether the stack has reached its capacity limit (if one was set).

```lua
LStack:isFull()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if full. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(2)
    st:push("a")
    st:push("b")
    print("full = " .. tostring(st:isFull()))
    print("len = " .. st:len())
end
```

---

#### `LStack:len`

Return the current number of items in the stack.

```lua
LStack:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Item count. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("len = " .. st:len())
    print("empty = " .. tostring(st:isEmpty()))
end
```

---

#### `LStack:moveWithin`

Move an item from one 1-based index to another within the stack.

```lua
LStack:moveWithin(from, to)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | number | Source index. |
| `to` | number | Destination index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the move succeeded. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    st:moveWithin(1, 3)
    local arr = st:toArray()
    print("first = " .. tostring(arr[1]))
    print("last = " .. tostring(arr[#arr]))
end
```

---

#### `LStack:peek`

Return the top value without removing it. Returns nil if empty.

```lua
LStack:peek()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The top value. |
| nil | When not available. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("peek = " .. tostring(st:peek()))
    print("len = " .. st:len())
end
```

---

#### `LStack:peekAt`

Return the value at a 1-based index without removing it. Returns nil if out of range.

```lua
LStack:peekAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position in the stack. |

**Returns**

| Type | Description |
|------|-------------|
| string | The value at that position. |
| nil | When not available. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    print("at 2 = " .. tostring(st:peekAt(2)))
    print("len = " .. st:len())
end
```

---

#### `LStack:peekBottom`

Return the bottom value without removing it. Returns nil if empty.

```lua
LStack:peekBottom()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The bottom value. |
| nil | When not available. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    print("bottom = " .. tostring(st:peekBottom()))
    print("len = " .. st:len())
end
```

---

#### `LStack:pop`

Remove and return the top value. Returns nil if the stack is empty.

```lua
LStack:pop()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The popped value. |
| nil | When not available. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    local value = st:pop()
    print("popped = " .. tostring(value))
    print("len = " .. st:len())
end
```

---

#### `LStack:popBottom`

Remove and return the bottom value. Returns nil if empty.

```lua
LStack:popBottom()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The popped value. |
| nil | When not available. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    local value = st:popBottom()
    print("bottom = " .. tostring(value))
    print("len = " .. st:len())
end
```

---

#### `LStack:popMany`

Pop up to `count` values from the top and return them as an array table.

```lua
LStack:popMany(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Maximum number of items to pop. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Popped values (may be shorter than count). |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local values = st:popMany(2)
    print("count = " .. #values)
    print("len = " .. st:len())
end
```

---

#### `LStack:push`

Push a value onto the top of the stack. Returns false if the stack is at capacity.

```lua
LStack:push(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to push. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if pushed, false if full. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(100)
    st:push("first")
    st:push("second")
    print("peek = " .. tostring(st:peek()))
    print("len = " .. st:len())
end
```

---

#### `LStack:pushBottom`

Push a value onto the bottom of the stack. Returns false if at capacity.

```lua
LStack:pushBottom(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The value to insert at the bottom. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if pushed, false if full. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:pushBottom("z")
    print("bottom = " .. tostring(st:peekBottom()))
    print("len = " .. st:len())
end
```

---

#### `LStack:removeAt`

Remove and return the value at a 1-based index. Returns nil if out of range.

```lua
LStack:removeAt(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based position to remove. |

**Returns**

| Type | Description |
|------|-------------|
| string | The removed value. |
| nil | When not available. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local value = st:removeAt(2)
    print("removed = " .. tostring(value))
    print("len = " .. st:len())
end
```

---

#### `LStack:toArray`

Return all stack items as an array table (bottom to top).

```lua
LStack:toArray()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of all values. |

**Example**

```lua
do
    local st = lurek.patterns.newStack(5)
    st:push("a")
    st:push("b")
    st:push("c")
    local arr = st:toArray()
    print("array = " .. #arr)
    print("first = " .. tostring(arr[1]))
end
```

---

## LStrategy

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStrategy:clear`

Remove all strategies and reset the selection.

```lua
LStrategy:clear()
```

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    print("before = " .. #strat:names())
    strat:clear()
    print("after = " .. #strat:names())
end
```

---

#### `LStrategy:execute`

Execute the currently active strategy, passing through all arguments and returning its results.

```lua
LStrategy:execute(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... any Arguments forwarded to the active strategy function. |

**Returns**

| Type | Description |
|------|-------------|
| table | Return value from the strategy function. |
| nil | When not available. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("attack")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute("slime")))
end
```

---

#### `LStrategy:getCurrent`

Return the name of the currently active strategy, or nil if none set.

```lua
LStrategy:getCurrent()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active strategy name, or nil if none is selected. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function()
        return "attacking"
    end)
    strat:register("flee", function()
        return "fleeing"
    end)
    strat:set("attack")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute()))
end
```

---

#### `LStrategy:has`

Check whether a strategy with the given name is registered.

```lua
LStrategy:has(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Strategy name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if registered. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    print("has fast = " .. tostring(strat:has("fast")))
    print("has medium = " .. tostring(strat:has("medium")))
end
```

---

#### `LStrategy:names`

Return an array of all registered strategy names.

```lua
LStrategy:names()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Strategy name strings. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    local names = strat:names()
    print("names = " .. #names)
    print("first = " .. tostring(names[1]))
end
```

---

#### `LStrategy:register`

Register a named strategy implementation function.

```lua
LStrategy:register(name, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Strategy identifier. |
| `callback` | function | The implementation function to call when this strategy is active. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    print("has attack = " .. tostring(strat:has("attack")))
    print("names = " .. #strat:names())
end
```

---

#### `LStrategy:remove`

Remove a named strategy. If it was the active strategy, no strategy will be selected.

```lua
LStrategy:remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Strategy name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the strategy was found and removed. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("fast", function()
        return "fast"
    end)
    strat:register("slow", function()
        return "slow"
    end)
    strat:remove("slow")
    print("has slow = " .. tostring(strat:has("slow")))
    print("names = " .. #strat:names())
end
```

---

#### `LStrategy:set`

Switch to a named strategy. Future `execute()` calls will use this implementation.

```lua
LStrategy:set(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | The strategy name to activate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the strategy exists and was set. |

**Example**

```lua
do
    local strat = lurek.patterns.newStrategy()
    strat:register("attack", function(target)
        return "attack " .. target
    end)
    strat:register("flee", function(target)
        return "flee from " .. target
    end)
    strat:set("flee")
    print("current = " .. tostring(strat:getCurrent()))
    print("result = " .. tostring(strat:execute("dragon")))
end
```

---

## LThrottle

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LThrottle:getFireCount`

Return the total number of times this throttle has fired since creation.

```lua
LThrottle:getFireCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total fire count. |

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(0.2)
    th:onFire(function()
        print("throttle fired")
    end)
    th:update(0.2)
    th:update(0.2)
    print("fires = " .. th:getFireCount())
    print("progress = " .. th:getProgress())
end
```

---

#### `LThrottle:getProgress`

Return how far through the current interval the throttle is (0.0 to 1.0).

```lua
LThrottle:getProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Progress fraction. |

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        print("throttle fired")
    end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:update(0.5)
    print("fires = " .. th:getFireCount())
end
```

---

#### `LThrottle:onFire`

Set the callback function to invoke each time the throttle fires.

```lua
LThrottle:onFire(f)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `f` | function | The callback to execute on fire. |

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        print("throttle fired = " .. fires)
    end)
    th:update(0.2)
    th:update(0.2)
    print("fires = " .. th:getFireCount())
end
```

---

#### `LThrottle:reset`

Reset the throttle timer back to zero without firing.

```lua
LThrottle:reset()
```

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        print("throttle fired")
    end)
    th:update(0.5)
    print("progress = " .. th:getProgress())
    th:reset()
    print("after reset = " .. th:getProgress())
end
```

---

#### `LThrottle:setEnabled`

Enable or disable the throttle. When disabled, update() will not accumulate time.

```lua
LThrottle:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to enable, false to disable. |

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(1.0)
    th:onFire(function()
        print("throttle fired")
    end)
    th:setEnabled(false)
    th:update(2.0)
    print("fires = " .. th:getFireCount())
    print("progress = " .. th:getProgress())
end
```

---

#### `LThrottle:update`

Advance the throttle timer. If the interval has elapsed, fires the callback and returns true.

```lua
LThrottle:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds since last update. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the throttle fired this frame. |

**Example**

```lua
do
    local th = lurek.patterns.newThrottle(0.2)
    local fires = 0
    th:onFire(function()
        fires = fires + 1
        print("throttle fired = " .. fires)
    end)
    th:update(0.1)
    th:update(0.1)
    print("fires = " .. th:getFireCount())
end
```

---

## LWeightedRandom

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LWeightedRandom:add`

Add an item with a relative weight. Higher weight = higher selection probability.

```lua
LWeightedRandom:add(weight, value, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weight` | number | The selection weight (must be > 0). |
| `value` | any | The payload value returned on pick. |
| `label?` | string | Optional human-readable label. |

**Returns**

| Type | Description |
|------|-------------|
| number | The internal ID of the added entry. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("items = " .. wr:len())
    print("total = " .. wr:totalWeight())
end
```

---

#### `LWeightedRandom:clearAll`

Remove all entries from the pool. This method is available to Lua scripts.

```lua
LWeightedRandom:clearAll()
```

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(5, "item_a")
    wr:add(5, "item_b")
    print("before = " .. wr:len())
    wr:clearAll()
    print("after = " .. wr:len())
end
```

---

#### `LWeightedRandom:getRevision`

Return the revision counter. Increments on any add/remove/weight change.

```lua
LWeightedRandom:getRevision()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Revision number. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:setWeight(id, 20)
    print("revision = " .. wr:getRevision())
    print("items = " .. wr:len())
end
```

---

#### `LWeightedRandom:isEmpty`

Check whether the pool has no entries.

```lua
LWeightedRandom:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if empty. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    print("empty = " .. tostring(wr:isEmpty()))
    wr:add(5, "item_a")
    print("after add = " .. tostring(wr:isEmpty()))
end
```

---

#### `LWeightedRandom:len`

Return the number of entries in the pool.

```lua
LWeightedRandom:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("items = " .. wr:len())
    print("total = " .. wr:totalWeight())
end
```

---

#### `LWeightedRandom:pick`

Pick one item using a random sample value in [0, 1). Returns its value or nil.

```lua
LWeightedRandom:pick(sample)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sample` | number | A random number in [0, 1) range. |

**Returns**

| Type | Description |
|------|-------------|
| string | The selected item's value. |
| nil | If pool is empty. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("picked = " .. tostring(wr:pick(0.5)))
    print("items = " .. wr:len())
end
```

---

#### `LWeightedRandom:pickN`

Pick multiple unique items. Requires an array of random samples.

```lua
LWeightedRandom:pickN(count, samples)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count` | number | Number of items to pick. |
| `samples` | table | Array of random numbers in [0, 1). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of picked values. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    wr:add(1, "legendary", "legendary_loot")
    local values = wr:pickN(2, {0.1, 0.9})
    print("count = " .. #values)
    print("items = " .. wr:len())
end
```

---

#### `LWeightedRandom:remove`

Remove an item by its ID. Returns true if it existed.

```lua
LWeightedRandom:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The entry ID to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if removed. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:remove(id)
    print("items = " .. wr:len())
    print("revision = " .. wr:getRevision())
end
```

---

#### `LWeightedRandom:setWeight`

Change the weight of an existing entry.

```lua
LWeightedRandom:setWeight(id, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | The entry ID. |
| `weight` | number | The new weight value. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the entry was found and updated. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    local id = wr:add(5, "item_a")
    wr:add(5, "item_b")
    wr:setWeight(id, 20)
    print("total = " .. wr:totalWeight())
    print("revision = " .. wr:getRevision())
end
```

---

#### `LWeightedRandom:totalWeight`

Return the sum of all entry weights.

```lua
LWeightedRandom:totalWeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total weight. |

**Example**

```lua
do
    local wr = lurek.patterns.newWeightedRandom()
    wr:add(10, "common", "common_loot")
    wr:add(3, "rare", "rare_loot")
    print("total = " .. wr:totalWeight())
    print("items = " .. wr:len())
end
```

---
