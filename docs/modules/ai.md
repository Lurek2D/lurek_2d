# Ai

## Purpose

Orchestrates agent choices via behavior trees, FSMs, GOAP, HTN, and utility AI. - Interprets sensory perception, internal state, goals, plans, and action-selection models. - Tracks squad coordination, trait-driven emotional motives, needs, and dramatic pacing. - Consumes learned policies only through explicit learning integration points; ML/RL constructors live under the learning module. - Controls dramatic pacing waves and optimizes runtime budgets with distance-based LOD tiers.

## Summary

- The `ai` module is the engine's gameplay-intelligence surface for users who need actors to perceive, decide, coordinate, and adapt in ways that go far beyond hard-coded if-then behavior.
- Its defining characteristic is breadth of decision models. The module deliberately supports behavior trees, finite state machines, utility scoring, GOAP, HTN, Monte Carlo Tree Search, and related helpers so a single project can choose the right reasoning style for each actor type or gameplay layer.
- That breadth matters because game AI is rarely solved by one universal algorithm.
- Reactive control and deliberative planning are both first-class here. An actor can respond immediately through short-horizon stateful logic while also relying on planning, utility, or hierarchical decomposition for larger goals and longer-term behavior.
- The module is therefore not only about selecting an action. It also models the internal information that makes action selection meaningful: perceptions, remembered stimuli, blackboard facts, needs, emotions, traits, alertness, and contextual world knowledge.
- Perception support is especially important because believable decisions depend on what an agent knows, not only on what the world objectively contains. Vision, hearing, custom stimuli, awareness memory, and alertness tracking all shape what options the actor should consider.
- This makes the AI contract more realistic and more debuggable. Instead of a hidden boolean like “sees player,” the module encourages explicit sensory interpretation that can be inspected, tuned, and reused across several behavior styles.
- Needs, drives, and emotional-style state broaden the feature beyond combat logic. They make the module useful for simulation actors, companions, social agents, or director systems where behavior depends on internal pressure as much as on external threats.
- Blackboard-style context storage and shared decision data matter because larger AI systems usually need stable intermediate state. Several subsystems may contribute facts, priorities, or targets, and the module provides a shared surface for that internal coordination.
- Movement-side helpers are deliberately owned by `pathfind`. Steering stacks, context steering, ORCA-style local avoidance, flow fields, and influence maps live there so navigation and tactical space analysis have one public owner.
- Squad support extends the module from isolated actors to coordinated groups. Shared group state and coordinated command handling make it possible to express teams or patrols, while pure movement and local-avoidance execution stays in `pathfind`.
- Command queues are important because AI output is often not the final physical action. A stable queue boundary separates “what the AI wants next” from “what the actor is currently doing,” which helps with interruption, inspection, and synchronization with animation or movement systems.
- Director-style pacing support shows that the module also thinks beyond single actors. Encounter rhythm, phase pressure, tension, spawn pacing, and other orchestration behavior can be represented here when the “agent” is really the game experience itself.
- Level-of-detail and update-policy support matter for scale. Large groups of intelligent actors can become expensive quickly, so the module includes ways to throttle, schedule, or simplify updates without abandoning the common behavior vocabulary.
- Debug rendering and inspection support are essential for real use. Visualizing state machines, behavior trees, perception ranges, chosen targets, or queue contents shortens the path from “the agent behaved strangely” to “here is the exact internal reason.”
- The module is useful for enemies, companions, neutral populations, strategic directors, simulation agents, crowd coordinators, and any feature where behavior should be data-driven, inspectable, and scalable rather than buried in one-off control code.
- Machine-learning, reinforcement-learning, bandit, neural-network, genetic, and neuroevolution constructors are not owned here. Those belong to `learning`; `ai` may consume their outputs through explicit integration but must not duplicate their public API.
- Neighboring modules still matter, but the boundary is clear. `pathfind` owns route search, influence maps, steering, and local avoidance; `physics` defines motion and collision semantics; and `render` visualizes results, while `ai` owns the reasoning structures, internal drives, sensory interpretation, and coordination layers that decide what to do.
- The breadth of the spec is intentional because modern game AI is an ecosystem. Perception, memory, scoring, planning, execution intent, and group coordination all reinforce one another, while movement execution uses the neighboring `pathfind` surface.
- That ecosystem view also improves authoring. Teams can mix authored logic, tactical heuristics, and simulation-like drives within one runtime surface instead of treating each behavior family as an isolated special case.
- It also helps debugging stay on one common reasoning vocabulary.
- That common vocabulary matters once several actor types share a world.
- The module is therefore not only about smarter enemies; it is also about giving complex runtime behavior a legible structure that can be tuned, debugged, and scaled over the lifetime of a project.
- For wiki readers, the key takeaway is that `ai` is not one algorithm or one enemy helper. It is the engine's full runtime toolkit for building decision-rich actors whose perception, planning, movement, group behavior, and debugging story are treated as one coherent feature family.

This module primarily collaborates with `dialog`, `image`, `learning`, `patterns`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.ai.newAIDirector`

Creates an AI director for tension, phase, and pacing factor calculations.

```lua
lurek.ai.newAIDirector()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAIDirector](#laidirector) | New AI director handle. |

**Example**

```lua
do
  local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
  dir:pushEvent(0.6)
  dir:update(1.0)
  lurek.log.info(tostring("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil)))
  lurek.log.info(tostring("lurek.ai.newAIDirector: phase=" .. dir:phase()))
end
```

---

### `lurek.ai.newAILod`

Creates a default AI level-of-detail tier selector.

```lua
lurek.ai.newAILod()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAILod](#lailod) | New AI LOD handle. |

**Example**

```lua
do
  local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
  lurek.log.info(tostring("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil)))
  lurek.log.info(tostring("lurek.ai.newAILod: tiers=" .. tostring(lod:tierCount())))
end
```

---

### `lurek.ai.newAction`

Creates a behavior tree action leaf backed by a Lua callback.

```lua
lurek.ai.newAction(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Callback invoked when the action node ticks. |

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New action node handle. |

**Example**

```lua
do
  local act = lurek.ai.newAction(function() return "success" end)
  local node_type = act:getNodeType()
  local child_count = act:getChildCount()
  act:reset()
  lurek.log.info(tostring("lurek.ai.newAction: type=" .. act:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newAction: child_count=" .. tostring(act:getChildCount())))
end
```

---

### `lurek.ai.newBehaviorTree`

Creates an empty behavior tree that can receive a root node.

```lua
lurek.ai.newBehaviorTree()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBehaviorTree](#lbehaviortree) | New behavior tree handle. |

**Example**

```lua
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  lurek.log.info(tostring("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus())))
  lurek.log.info(tostring("lurek.ai.newBehaviorTree: node_count=" .. tostring(info.node_count)))
end
```

---

### `lurek.ai.newBlackboard`

Creates an empty AI blackboard for typed local facts.

```lua
lurek.ai.newBlackboard()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAIBlackboard](#laiblackboard) | New blackboard handle. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("state", "idle")
  lurek.log.info(tostring("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none")))
end
```

---

### `lurek.ai.newCommandQueue`

Creates an empty command queue for callback-backed AI commands.

```lua
lurek.ai.newCommandQueue()
```

**Returns**

| Type | Description |
|------|-------------|
| [LCommandQueue](#lcommandqueue) | New command queue handle. |

**Example**

```lua
do
  local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
  cq:enqueue("move", function() lurek.log.info(tostring("moving")) end, { targetX = 32, targetY = 64 })
  lurek.log.info(tostring("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty())))
  lurek.log.info(tostring("lurek.ai.newCommandQueue: count=" .. tostring(cq:getCount())))
end
```

---

### `lurek.ai.newCondition`

Creates a behavior tree condition leaf backed by a Lua callback.

```lua
lurek.ai.newCondition(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Callback invoked when the condition node ticks. |

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New condition node handle. |

**Example**

```lua
do
  local cond = lurek.ai.newCondition(function() return true end)
  local node_type = cond:getNodeType()
  local child_count = cond:getChildCount()
  cond:reset()
  lurek.log.info(tostring("lurek.ai.newCondition: type=" .. cond:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newCondition: child_count=" .. tostring(cond:getChildCount())))
end
```

---

### `lurek.ai.newDecisionBiasSet`

Creates an empty set of rules that map profile traits onto named decision scores.

```lua
lurek.ai.newDecisionBiasSet()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDecisionBiasSet](#ldecisionbiasset) | New decision bias handle. |

**Example**

```lua
do
  local profile = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  profile:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.2, "add")
  local score = bias:score(profile, "attack", 0.5)
  lurek.log.info(tostring("lurek.ai.newDecisionBiasSet: score=" .. tostring(score)))
end
```

---

### `lurek.ai.newDialogueAI`

Creates an empty dialogue selector for weighted topics and branches.

```lua
lurek.ai.newDialogueAI()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDialogueAI](#ldialogueai) | New dialogue AI handle. |

**Example**

```lua
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.5, nil, nil, "greet_score")
  dlg:setUtilityScore("greet_score", 0.8)
  lurek.log.info(tostring("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil)))
  lurek.log.info(tostring("lurek.ai.newDialogueAI: topics=" .. tostring(dlg:getTopicCount())))
end
```

---

### `lurek.ai.newEmotionModel`

Creates an empty emotion model for named decaying emotion values.

```lua
lurek.ai.newEmotionModel()
```

**Returns**

| Type | Description |
|------|-------------|
| [LEmotionModel](#lemotionmodel) | New emotion model handle. |

**Example**

```lua
do
  local emo = lurek.ai.newEmotionModel()
  emo:add("fear", 0.1, 0.2, 0.3)
  emo:trigger("fear", 0.5)
  lurek.log.info(tostring("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil)))
  lurek.log.info(tostring("lurek.ai.newEmotionModel: dominant=" .. tostring(emo:dominant())))
end
```

---

### `lurek.ai.newGOAPPlanner`

Creates an empty GOAP planner for boolean world-state planning.

```lua
lurek.ai.newGOAPPlanner()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGOAPPlanner](#lgoapplanner) | New GOAP planner handle. |

**Example**

```lua
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
  goap:addGoal("stay_alive", 5)
  goap:setGoalState("stay_alive", "alive", true)
  lurek.log.info(tostring("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil)))
  lurek.log.info(tostring("lurek.ai.newGOAPPlanner: goals=" .. tostring(goap:getGoalCount())))
end
```

---

### `lurek.ai.newGuard`

Creates a guard decorator that runs a predicate before ticking its child.

```lua
lurek.ai.newGuard(predicate, child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `predicate` | function | Callback that decides whether the child may run. |
| `child` | [LBTNode](#lbtnode) | Child node handle consumed by the guard. |

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New guard node handle. |

**Example**

```lua
do
  local child_action = lurek.ai.newAction(function() return "success" end)
  local guard = lurek.ai.newGuard(function() return true end, child_action)
  local node_type = guard:getNodeType()
  local child_count = guard:getChildCount()
  lurek.log.info(tostring("lurek.ai.newGuard: node=" .. guard:getNodeType()))
end
```

---

### `lurek.ai.newHTNDomain`

Creates an empty hierarchical task network domain.

```lua
lurek.ai.newHTNDomain()
```

**Returns**

| Type | Description |
|------|-------------|
| [LHTNDomain](#lhtndomain) | New HTN domain handle. |

**Example**

```lua
do
  local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
  lurek.log.info(tostring("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil)))
  lurek.log.info(tostring("lurek.ai.newHTNDomain: tasks=" .. tostring(htn:taskCount())))
end
```

---

### `lurek.ai.newInverter`

Creates a behavior tree inverter decorator with an empty sequence child.

```lua
lurek.ai.newInverter()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New inverter node handle. |

**Example**

```lua
do
  local inv = lurek.ai.newInverter()
  local node_type = inv:getNodeType()
  local child_count = inv:getChildCount()
  inv:setChild(lurek.ai.newCondition(function() return false end))
  lurek.log.info(tostring("lurek.ai.newInverter: type=" .. inv:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newInverter: child_count=" .. tostring(inv:getChildCount())))
end
```

---

### `lurek.ai.newMCTSEngine`

Creates a Monte Carlo tree search engine with deterministic configuration.

```lua
lurek.ai.newMCTSEngine(iters, uct_c, depth, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `iters` | number | Search iteration count. |
| `uct_c` | number | UCT exploration constant. |
| `depth` | number | Rollout depth limit. |
| `seed` | number | Random seed used by the engine. |

**Returns**

| Type | Description |
|------|-------------|
| [LMCTSEngine](#lmctsengine) | New MCTS engine handle. |

**Example**

```lua
do
  local mcts = lurek.ai.newMCTSEngine(100, 1.41, 20, 42)
  local get_actions = function(state) return { 1, 2, 3 } end
  local apply = function(state, action) return state + action end
  local evaluate = function(state) return state % 5 end
  local search_budget = 100
  local exploration = 1.41
  local rollout_depth = 20
  local root_state = 0
  local best_action = mcts:search(0, get_actions, apply, evaluate)
  lurek.log.info(tostring("lurek.ai.newMCTSEngine: action=" .. tostring(best_action)))
end
```

---

### `lurek.ai.newNeedSystem`

Creates an empty need system for decaying named needs.

```lua
lurek.ai.newNeedSystem()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeedSystem](#lneedsystem) | New need system handle. |

**Example**

```lua
do
  local needs = lurek.ai.newNeedSystem()
  needs:addNeed("hunger", 0.1, 0.7, 2.0)
  needs:update(2.0)
  lurek.log.info(tostring("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil)))
  lurek.log.info(tostring("lurek.ai.newNeedSystem: urgent=" .. tostring(needs:mostUrgent())))
end
```

---

### `lurek.ai.newParallel`

Creates a behavior tree parallel node with optional success and failure policies.

```lua
lurek.ai.newParallel(sp, fp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sp?` | string | Success policy name; defaults to the engine's require-one policy. |
| `fp?` | string | Failure policy name; defaults to the engine's require-one policy. |

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New parallel node handle. |

**Example**

```lua
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newParallel: type=" .. par:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newParallel: children=" .. tostring(par:getChildCount())))
end
```

---

### `lurek.ai.newRepeater`

Creates a behavior tree repeater decorator with an optional repeat count.

```lua
lurek.ai.newRepeater(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Repeat count stored on the node; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New repeater node handle. |

**Example**

```lua
do
  local rep = lurek.ai.newRepeater(5)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newRepeater: count=" .. tostring(rep:getCount())))
  lurek.log.info(tostring("lurek.ai.newRepeater: type=" .. rep:getNodeType()))
end
```

---

### `lurek.ai.newSelector`

Creates a behavior tree selector node with no children.

```lua
lurek.ai.newSelector()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New selector node handle. |

**Example**

```lua
do
  local sel = lurek.ai.newSelector()
  local node_type = sel:getNodeType()
  local child_count = sel:getChildCount()
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newSelector: type=" .. sel:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newSelector: children=" .. tostring(sel:getChildCount())))
end
```

---

### `lurek.ai.newSequence`

Creates a behavior tree sequence node with no children.

```lua
lurek.ai.newSequence()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New sequence node handle. |

**Example**

```lua
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  lurek.log.info(tostring("lurek.ai.newSequence: type=" .. seq:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newSequence: children=" .. tostring(seq:getChildCount())))
end
```

---

### `lurek.ai.newSquad`

Creates an empty named squad. This function is exposed to Lua scripts.

```lua
lurek.ai.newSquad(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Squad name stored on the handle. |

**Returns**

| Type | Description |
|------|-------------|
| [LSquad](#lsquad) | New squad handle. |

**Example**

```lua
do
  local squad = lurek.ai.newSquad("bravo")
  squad:addMember("leader")
  squad:setLeader("leader")
  lurek.log.info(tostring("lurek.ai.newSquad: name=" .. squad:getName()))
  lurek.log.info(tostring("lurek.ai.newSquad: members=" .. tostring(squad:getMemberCount())))
end
```

---

### `lurek.ai.newStateMachine`

Creates an empty finite state machine with Lua-backed states and transitions.

```lua
lurek.ai.newStateMachine()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStateMachine](#lstatemachine) | New state machine handle. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("idle", {})
  fsm:setInitialState("idle")
  lurek.log.info(tostring("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil)))
  lurek.log.info(tostring("lurek.ai.newStateMachine: current=" .. tostring(fsm:getCurrentState())))
end
```

---

### `lurek.ai.newStimulusWorld`

Creates an empty stimulus world for visual and auditory stimulus records.

```lua
lurek.ai.newStimulusWorld()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStimulusWorld](#lstimulusworld) | New stimulus world handle. |

**Example**

```lua
do
  local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
  sw:addVisual(100, 150, 1.0, 48.0, "enemy")
  lurek.log.info(tostring("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count())))
  lurek.log.info(tostring("lurek.ai.newStimulusWorld: type=" .. sw:type()))
end
```

---

### `lurek.ai.newStrategyAI`

Creates a strategy AI that reevaluates goals on a fixed interval.

```lua
lurek.ai.newStrategyAI(update_interval)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `update_interval` | number | Seconds between automatic strategy evaluations. |

**Returns**

| Type | Description |
|------|-------------|
| [LStrategyAI](#lstrategyai) | New strategy AI handle. |

**Example**

```lua
do
  local strat = lurek.ai.newStrategyAI(3.0)
  strat:addGoal("expand")
  strat:addTag("economy")
  lurek.log.info(tostring("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil)))
  lurek.log.info(tostring("lurek.ai.newStrategyAI: next_eval=" .. tostring(strat:timeUntilNext())))
end
```

---

### `lurek.ai.newSucceeder`

Creates a behavior tree succeeder decorator with an empty sequence child.

```lua
lurek.ai.newSucceeder()
```

**Returns**

| Type | Description |
|------|-------------|
| [LBTNode](#lbtnode) | New succeeder node handle. |

**Example**

```lua
do
  local suc = lurek.ai.newSucceeder()
  local node_type = suc:getNodeType()
  local child_count = suc:getChildCount()
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  lurek.log.info(tostring("lurek.ai.newSucceeder: type=" .. suc:getNodeType()))
  lurek.log.info(tostring("lurek.ai.newSucceeder: child_count=" .. tostring(suc:getChildCount())))
end
```

---

### `lurek.ai.newTraitArchetypes`

Creates a trait archetype registry populated with engine-provided commander presets.

```lua
lurek.ai.newTraitArchetypes()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTraitArchetypes](#ltraitarchetypes) | New archetype registry handle. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local profile = archetypes:createProfile("aggressive")
  local names = archetypes:names()
  local count = archetypes:count()
  lurek.log.info(tostring("lurek.ai.newTraitArchetypes: count=" .. tostring(count)))
  lurek.log.info(tostring("lurek.ai.newTraitArchetypes: aggression=" .. tostring(profile:get("aggression"))))
  lurek.log.info(tostring("lurek.ai.newTraitArchetypes: first=" .. tostring(names[1])))
end
```

---

### `lurek.ai.newTraitProfile`

Creates an empty trait profile with modifier support.

```lua
lurek.ai.newTraitProfile()
```

**Returns**

| Type | Description |
|------|-------------|
| [LTraitProfile](#ltraitprofile) | New trait profile handle. |

**Example**

```lua
do
  local traits = lurek.ai.newTraitProfile()
  traits:set("discipline", 0.4)
  traits:set("courage", 0.7)
  lurek.log.info(tostring("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil)))
  lurek.log.info(tostring("lurek.ai.newTraitProfile: courage=" .. tostring(traits:get("courage"))))
end
```

---

### `lurek.ai.newUtilityAI`

Creates an empty utility AI action scorer.

```lua
lurek.ai.newUtilityAI()
```

**Returns**

| Type | Description |
|------|-------------|
| [LUtilityAI](#lutilityai) | New utility AI handle. |

**Example**

```lua
do
  local util = lurek.ai.newUtilityAI()
  util:addAction("wait", function() return 0.2 end)
  util:addAction("attack", function() return 0.9 end)
  lurek.log.info(tostring("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil)))
  lurek.log.info(tostring("lurek.ai.newUtilityAI: pick=" .. tostring(util:evaluate())))
end
```

---

### `lurek.ai.newWorld`

Creates an isolated AI world for agents, blackboards, and custom decision callbacks.

```lua
lurek.ai.newWorld()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAIWorld](#laiworld) | New AI world handle. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local scout = world:addAgent("scout_preview")
  local count = world:getAgentCount()
  lurek.log.info(tostring("lurek.ai.newWorld: agents=" .. tostring(count)))
  lurek.log.info(tostring("lurek.ai.newWorld: first_agent=" .. scout:getName()))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callback Parameters

- `lurek.ai.newAction` param `callback` (`function`): Callback invoked when the action node ticks.
- `lurek.ai.newCondition` param `callback` (`function`): Callback invoked when the condition node ticks.
- `lurek.ai.newGuard` param `predicate` (`function`): Callback that decides whether the child may run.

## Enums

*No module-specific enums documented.*

## Types

- [LAIBlackboard](#laiblackboard)
- [LAIDirector](#laidirector)
- [LAILod](#lailod)
- [LAIWorld](#laiworld)
- [LBTNode](#lbtnode)
- [LBehaviorTree](#lbehaviortree)
- [LBot](#lbot)
- [LCommandQueue](#lcommandqueue)
- [LDecisionBiasSet](#ldecisionbiasset)
- [LDialogueAI](#ldialogueai)
- [LEmotionModel](#lemotionmodel)
- [LGOAPPlanner](#lgoapplanner)
- [LHTNDomain](#lhtndomain)
- [LMCTSEngine](#lmctsengine)
- [LNeedSystem](#lneedsystem)
- [LSquad](#lsquad)
- [LStateMachine](#lstatemachine)
- [LStimulusWorld](#lstimulusworld)
- [LStrategyAI](#lstrategyai)
- [LTraitArchetypes](#ltraitarchetypes)
- [LTraitProfile](#ltraitprofile)
- [LUtilityAI](#lutilityai)

## LAIBlackboard

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAIBlackboard:clear`

Removes every local entry from this blackboard.

```lua
LAIBlackboard:clear()
```

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  lurek.log.info(tostring("LAIBlackboard:clear: size=" .. tostring(size)))
end
```

---

#### `LAIBlackboard:getBool`

Returns a boolean blackboard fact or the provided fallback when the key is missing or not boolean.

```lua
LAIBlackboard:getBool(key, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to read. |
| `default?` | boolean | Fallback value used when the key has no boolean entry; defaults to false. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Stored boolean value or fallback value. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  lurek.log.info(tostring("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm)))
end
```

---

#### `LAIBlackboard:getKeys`

Returns every local blackboard key in an array-style Lua table.

```lua
LAIBlackboard:getKeys()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Array table containing all stored key names as strings. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  lurek.log.info(tostring("LAIBlackboard:getKeys: count=" .. tostring(#keys)))
end
```

---

#### `LAIBlackboard:getNumber`

Returns a numeric blackboard fact or the provided fallback when the key is missing or not numeric.

```lua
LAIBlackboard:getNumber(key, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to read. |
| `default?` | number | Fallback value used when the key has no numeric entry; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stored numeric value or fallback value. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  lurek.log.info(tostring("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing)))
end
```

---

#### `LAIBlackboard:getSize`

Returns the number of entries currently stored in this blackboard.

```lua
LAIBlackboard:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current blackboard entry count. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  lurek.log.info(tostring("LAIBlackboard:getSize: " .. tostring(size)))
end
```

---

#### `LAIBlackboard:getString`

Returns a string blackboard fact or the provided fallback when the key is missing or not a string.

```lua
LAIBlackboard:getString(key, default)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to read. |
| `default?` | string | Fallback value used when the key has no string entry; defaults to an empty string. |

**Returns**

| Type | Description |
|------|-------------|
| string | Stored string value or fallback value. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  lurek.log.info(tostring("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield))
end
```

---

#### `LAIBlackboard:has`

Returns whether the blackboard contains any entry for the given key.

```lua
LAIBlackboard:has(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when any typed value is stored at the key. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  lurek.log.info(tostring("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp)))
end
```

---

#### `LAIBlackboard:remove`

Removes the given key from the blackboard if it exists.

```lua
LAIBlackboard:remove(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to remove. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  lurek.log.info(tostring("LAIBlackboard:remove: has_temp=" .. tostring(still_has)))
end
```

---

#### `LAIBlackboard:setBool`

Stores a boolean fact under the given blackboard key.

```lua
LAIBlackboard:setBool(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to write. |
| `value` | boolean | Boolean value stored for later boolean reads. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  lurek.log.info(tostring("LAIBlackboard:setBool: can_attack=" .. tostring(attack)))
end
```

---

#### `LAIBlackboard:setNumber`

Stores a numeric fact under the given blackboard key.

```lua
LAIBlackboard:setNumber(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to write. |
| `value` | number | Numeric value stored for later numeric reads. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  lurek.log.info(tostring("LAIBlackboard:setNumber: distance=" .. tostring(dist)))
end
```

---

#### `LAIBlackboard:setString`

Stores a string fact under the given blackboard key.

```lua
LAIBlackboard:setString(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Blackboard key to write. |
| `value` | string | String value stored for later string reads. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  lurek.log.info(tostring("LAIBlackboard:setString: target=" .. target))
end
```

---

#### `LAIBlackboard:type`

Returns the Lua-visible type name for this blackboard handle.

```lua
LAIBlackboard:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAIBlackboard](#laiblackboard)`. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  local t = bb:type()
  lurek.log.info(tostring("LAIBlackboard:type: " .. t))
  lurek.log.info(tostring("LAIBlackboard:type: matches=" .. tostring(bb:typeOf("LAIBlackboard"))))
end
```

---

#### `LAIBlackboard:typeOf`

Returns whether this blackboard handle matches a supported type name.

```lua
LAIBlackboard:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `AIBlackboard`, `Blackboard`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local bb = lurek.ai.newBlackboard()
  bb:setString("context", "active")
  local bb_size = bb:getSize()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LBot")
  lurek.log.info(tostring("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LBot=" .. tostring(is_agent)))
end
```

---

## LAIDirector

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAIDirector:ambientIntensity`

Returns the ambient intensity derived from current tension and phase.

```lua
LAIDirector:ambientIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Ambient intensity factor. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.7)
    dir:update(0.1)
    lurek.log.info(tostring("ambient intensity = " .. dir:ambientIntensity()))
end
```

---

#### `LAIDirector:lootFactor`

Returns the loot multiplier derived from current tension and phase.

```lua
LAIDirector:lootFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Loot factor. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.2)
    dir:update(0.1)
    lurek.log.info(tostring("loot factor = " .. dir:lootFactor()))
end
```

---

#### `LAIDirector:phase`

Returns the current director phase name.

```lua
LAIDirector:phase()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current pacing phase. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    local p = dir:phase()
    lurek.log.info(tostring("initial phase = " .. p))
end
```

---

#### `LAIDirector:pushEvent`

Adds an event intensity sample to the director tension model.

```lua
LAIDirector:pushEvent(intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | number | Event intensity added to current tension. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    lurek.log.info(tostring("events pushed, tension = " .. dir:tension()))
end
```

---

#### `LAIDirector:reset`

Resets director tension and phase state to defaults.

```lua
LAIDirector:reset()
```

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.9)
    dir:reset()
    lurek.log.info(tostring("after reset, tension = " .. dir:tension()))
end
```

---

#### `LAIDirector:setTension`

Directly sets the director tension value.

```lua
LAIDirector:setTension(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | number | New tension value. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.5)
    lurek.log.info(tostring("tension set to " .. dir:tension()))
end
```

---

#### `LAIDirector:spawnRateFactor`

Returns the spawn-rate multiplier derived from current tension and phase.

```lua
LAIDirector:spawnRateFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Spawn rate factor. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.9)
    dir:update(0.1)
    lurek.log.info(tostring("spawn rate factor = " .. dir:spawnRateFactor()))
end
```

---

#### `LAIDirector:tension`

Returns the current director tension value.

```lua
LAIDirector:tension()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current tension. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:setTension(0.6)
    lurek.log.info(tostring("tension = " .. dir:tension()))
end
```

---

#### `LAIDirector:type`

Returns the Lua-visible type name for this AI director handle.

```lua
LAIDirector:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAIDirector](#laidirector)`. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    lurek.log.info(tostring("type = " .. dir:type()))
  lurek.log.info(tostring("matches = " .. tostring(dir:typeOf("LAIDirector"))))
end
```

---

#### `LAIDirector:typeOf`

Returns whether this AI director handle matches a supported type name.

```lua
LAIDirector:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAIDirector](#laidirector)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    local type_name = dir:type()
    lurek.log.info(tostring("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector"))))
end
```

---

#### `LAIDirector:update`

Advances director tension decay and phase evaluation.

```lua
LAIDirector:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local dir = lurek.ai.newAIDirector()
  dir:pushEvent(0.1)
  local current_phase = dir:phase()
    dir:pushEvent(1.0)
    dir:update(2.0)
    lurek.log.info(tostring("phase after update = " .. dir:phase()))
end
```

---

## LAILod

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAILod:shouldUpdate`

Returns whether a tier should update on a given frame counter.

```lua
LAILod:shouldUpdate(tier, frame)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tier` | number | Zero-based LOD tier index. |
| `frame` | number | Current frame counter. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when agents in the tier should update this frame. |

**Example**

```lua
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local run = lod:shouldUpdate(0, 1)
    lurek.log.info(tostring("tier 0 should update on frame 1 = " .. tostring(run)))
end
```

---

#### `LAILod:tierCount`

Returns the number of configured AI LOD tiers.

```lua
LAILod:tierCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | LOD tier count. |

**Example**

```lua
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local type_name = lod:type()
    local is_lod = lod:typeOf("LAILod")
    lurek.log.info(tostring("tier count = " .. lod:tierCount()))
end
```

---

#### `LAILod:tierFor`

Returns the LOD tier for an agent position relative to a reference position.

```lua
LAILod:tierFor(ax, ay, rx, ry)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | number | Agent X position. |
| `ay` | number | Agent Y position. |
| `rx` | number | Reference X position, usually camera or player position. |
| `ry` | number | Reference Y position, usually camera or player position. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based LOD tier index. |

**Example**

```lua
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local tier = lod:tierFor(100, 200, 0, 0)
    lurek.log.info(tostring("tier = " .. tier))
end
```

---

#### `LAILod:tierName`

Returns the name of an AI LOD tier when the index is valid.

```lua
LAILod:tierName(tier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tier` | number | Zero-based LOD tier index. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Tier name, or nil when the tier index is invalid. |

**Example**

```lua
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local name = lod:tierName(0)
    lurek.log.info(tostring("tier 0 name = " .. name))
end
```

---

#### `LAILod:type`

Returns the Lua-visible type name for this AI LOD handle.

```lua
LAILod:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAILod](#lailod)`. |

**Example**

```lua
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    lurek.log.info(tostring("type = " .. lod:type()))
  lurek.log.info(tostring("matches = " .. tostring(lod:typeOf("LAILod"))))
end
```

---

#### `LAILod:typeOf`

Returns whether this AI LOD handle matches a supported type name.

```lua
LAILod:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LAILod](#lailod)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local lod = lurek.ai.newAILod()
  local tier_name = lod:tierName(0)
  local tier_index = lod:tierFor(0, 0, 0, 0)
    local count = lod:tierCount()
    local type_name = lod:type()
    lurek.log.info(tostring("is LAILod = " .. tostring(lod:typeOf("LAILod"))))
end
```

---

## LAIWorld

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAIWorld:addAgent`

Creates a named agent in this world and returns a handle that can edit its movement and decision state.

```lua
LAIWorld:addAgent(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique agent name used by later lookup, tags, custom callbacks, and squad membership references. |

**Returns**

| Type | Description |
|------|-------------|
| [LBot](#lbot) | Lua handle for the newly inserted bot. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local archer = world:addAgent("archer_01")
  local count = world:getAgentCount()
  lurek.log.info(tostring("LAIWorld:addAgent: name=" .. archer:getName()))
end
```

---

#### `LAIWorld:getAgent`

Returns the named agent handle when it exists in this world.

```lua
LAIWorld:getAgent(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Agent name previously passed to `addAgent`. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Agent handle when found, or nil when the world has no agent with that name. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  lurek.log.info(tostring("LAIWorld:getAgent: found=" .. tostring(found ~= nil)))
end
```

---

#### `LAIWorld:getAgentCount`

Returns the number of agents currently stored in this world.

```lua
LAIWorld:getAgentCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current agent count. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  lurek.log.info(tostring("LAIWorld:getAgentCount: " .. tostring(count)))
end
```

---

#### `LAIWorld:getGlobalBlackboard`

Returns a blackboard snapshot containing the world's shared AI facts.

```lua
LAIWorld:getGlobalBlackboard()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAIBlackboard](#laiblackboard) | Blackboard handle initialized from the world's global blackboard values at call time. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local gb = world:getGlobalBlackboard()
  gb:setString("weather", "rain")
  lurek.log.info(tostring("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil)))
  lurek.log.info(tostring("LAIWorld:getGlobalBlackboard: weather=" .. gb:getString("weather", "none")))
end
```

---

#### `LAIWorld:getLastCallbackErrors`

Returns callback errors recorded during the most recent `update` call.

```lua
LAIWorld:getLastCallbackErrors()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `{ context, message }` tables. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local agent = world:addAgent("callback_probe")
  agent:setCustomModel(function() error("probe failure") end)
  world:update(1 / 60)
  local errors = world:getLastCallbackErrors()
  lurek.log.info(tostring("LAIWorld:getLastCallbackErrors: count=" .. tostring(#errors)))
end
```

---

#### `LAIWorld:removeAgent`

Removes an agent from this world by using an existing agent handle.

```lua
LAIWorld:removeAgent(agent)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `agent` | [LBot](#lbot) | Bot handle whose stored name identifies the world entry to remove. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  lurek.log.info(tostring("LAIWorld:removeAgent: removed"))
end
```

---

#### `LAIWorld:type`

Returns the Lua-visible type name for this AI world handle.

```lua
LAIWorld:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LAIWorld](#laiworld)`. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local t = world:type()
  local ok = world:typeOf("LAIWorld")
  lurek.log.info(tostring("LAIWorld:type: " .. t))
  lurek.log.info(tostring("LAIWorld:type: matches=" .. tostring(ok)))
end
```

---

#### `LAIWorld:typeOf`

Returns whether this AI world handle matches a supported type name.

```lua
LAIWorld:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `AIWorld` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  lurek.log.info(tostring("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong)))
end
```

---

#### `LAIWorld:update`

Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.

```lua
LAIWorld:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed simulation time in seconds for this update step. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("worker")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt) ticked = true end)
  world:update(1 / 60)
  lurek.log.info(tostring("LAIWorld:update: ticked=" .. tostring(ticked)))
end
```

---

## LBTNode

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBTNode:addChild`

Adds a child node to a composite selector, sequence, or parallel node.

```lua
LBTNode:addChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | [LBTNode](#lbtnode) | Child node handle to move into this composite node. |

**Example**

```lua
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  lurek.log.info(tostring("LBTNode:addChild: children=" .. tostring(count)))
end
```

---

#### `LBTNode:getChildCount`

Returns the number of children owned by this behavior tree node.

```lua
LBTNode:getChildCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Child count for composite nodes, or zero for leaf and decorator nodes without child lists. |

**Example**

```lua
do
  local sel = lurek.ai.newSelector()
  local node_type = sel:getNodeType()
  local child_count = sel:getChildCount()
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  lurek.log.info(tostring("LBTNode:getChildCount: " .. tostring(count)))
end
```

---

#### `LBTNode:getCount`

Returns the repeat count for repeater nodes or zero for other node kinds.

```lua
LBTNode:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Repeater count value. |

**Example**

```lua
do
  local rep = lurek.ai.newRepeater(7)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  local count = rep:getCount()
  lurek.log.info(tostring("LBTNode:getCount: " .. tostring(count)))
end
```

---

#### `LBTNode:getNodeType`

Returns the behavior tree node kind as a lowercase string.

```lua
LBTNode:getNodeType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Node kind such as `selector`, `sequence`, `parallel`, `action`, or `condition`. |

**Example**

```lua
do
  local act = lurek.ai.newAction(function() return "success" end)
  local node_type = act:getNodeType()
  local child_count = act:getChildCount()
  act:reset()
  lurek.log.info(tostring("LBTNode:getNodeType: " .. act:getNodeType()))
end
```

---

#### `LBTNode:reset`

Resets this behavior tree node's runtime state.

```lua
LBTNode:reset()
```

**Example**

```lua
do
  local seq = lurek.ai.newSequence()
  local node_type = seq:getNodeType()
  local child_count = seq:getChildCount()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  lurek.log.info(tostring("LBTNode:reset: done"))
end
```

---

#### `LBTNode:setChild`

Sets the single child of a decorator node such as inverter, repeater, or succeeder.

```lua
LBTNode:setChild(child)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `child` | [LBTNode](#lbtnode) | Child node handle to move into this decorator node. |

**Example**

```lua
do
  local inv = lurek.ai.newInverter()
  local node_type = inv:getNodeType()
  local child_count = inv:getChildCount()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  lurek.log.info(tostring("LBTNode:setChild: configured"))
  lurek.log.info(tostring("LBTNode:setChild: type=" .. inv:getNodeType()))
end
```

---

#### `LBTNode:setCount`

Sets the repeat count when this node is a repeater.

```lua
LBTNode:setCount(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of successful child executions before the repeater stops; zero means engine-defined repeat behavior. |

**Example**

```lua
do
  local rep = lurek.ai.newRepeater(3)
  local node_type = rep:getNodeType()
  local child_count = rep:getChildCount()
  rep:setCount(10)
  local count = rep:getCount()
  lurek.log.info(tostring("LBTNode:setCount: " .. tostring(count)))
end
```

---

#### `LBTNode:setFailurePolicy`

Sets the failure policy for a parallel node.

```lua
LBTNode:setFailurePolicy(policy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `policy` | string | Parallel failure policy name parsed by the engine. |

**Example**

```lua
do
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:setFailurePolicy("requireOne")
  lurek.log.info(tostring("LBTNode:setFailurePolicy: done"))
  lurek.log.info(tostring("LBTNode:setFailurePolicy: type=" .. par:getNodeType()))
end
```

---

#### `LBTNode:setSuccessPolicy`

Sets the success policy for a parallel node.

```lua
LBTNode:setSuccessPolicy(policy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `policy` | string | Parallel success policy name parsed by the engine. |

**Example**

```lua
do
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  local node_type = par:getNodeType()
  local child_count = par:getChildCount()
  par:setSuccessPolicy("requireOne")
  lurek.log.info(tostring("LBTNode:setSuccessPolicy: done"))
  lurek.log.info(tostring("LBTNode:setSuccessPolicy: type=" .. par:getNodeType()))
end
```

---

#### `LBTNode:type`

Returns the Lua-visible type name for this behavior tree node handle.

```lua
LBTNode:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBTNode](#lbtnode)`. |

**Example**

```lua
do
  local node = lurek.ai.newAction(function() return "success" end)
  local node_type = node:getNodeType()
  local child_count = node:getChildCount()
  local t = node:type()
  lurek.log.info(tostring("LBTNode:type: " .. t))
  lurek.log.info(tostring("LBTNode:type: matches=" .. tostring(node:typeOf("LBTNode"))))
end
```

---

#### `LBTNode:typeOf`

Returns whether this behavior tree node handle matches a supported type name.

```lua
LBTNode:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `BTNode` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local node = lurek.ai.newSelector()
  local node_type = node:getNodeType()
  local child_count = node:getChildCount()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  lurek.log.info(tostring("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other)))
end
```

---

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

---

#### `LBehaviorTree:clearAll`

Remove all nodes and leaf functions, resetting the tree to empty.

```lua
LBehaviorTree:clearAll()
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

**Example**

```lua
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  lurek.log.info(tostring("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count)))
  lurek.log.info(tostring("LBehaviorTree:getDebugState: last_status=" .. tostring(info.last_status)))
end
```

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

**Example**

```lua
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  lurek.log.info(tostring("LBehaviorTree:getLastStatus: " .. status))
end
```

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

---

#### `LBehaviorTree:resetState`

Reset the tree's running state. Use between encounters or when restarting AI logic.

```lua
LBehaviorTree:resetState()
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

---

#### `LBehaviorTree:setRoot`

Sets the behavior tree root by moving a node handle into the tree.

```lua
LBehaviorTree:setRoot(node)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node` | [LBTNode](#lbtnode) | Node handle to consume as the new tree root. |

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

**Example**

```lua
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  local t = bt:type()
  lurek.log.info(tostring("LBehaviorTree:type: " .. t))
  lurek.log.info(tostring("LBehaviorTree:type: matches=" .. tostring(bt:typeOf("LBehaviorTree"))))
end
```

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

**Example**

```lua
do
  local bt = lurek.ai.newBehaviorTree()
  local bt_debug = bt:getDebugState()
  local bt_status = bt:getLastStatus()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LBot")
  lurek.log.info(tostring("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LBot=" .. tostring(is_other)))
end
```

---

## LBot

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBot:addTag`

Adds a tag string to this agent when the agent still exists in its world.

```lua
LBot:addTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag name to insert into the agent tag set. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("guard")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:addTag("hostile")
  local has_hostile = npc:hasTag("hostile")
  lurek.log.info(tostring("LBot:addTag: hostile=" .. tostring(has_hostile)))
end
```

---

#### `LBot:addTraitModifier`

Adds a temporary or permanent modifier to one trait on this agent.

```lua
LBot:addTraitModifier(trait_name, delta, duration, source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `trait_name` | string | Trait key affected by the modifier. |
| `delta` | number | Additive value applied while the modifier is active. |
| `duration?` | number | Modifier lifetime in seconds, or nil for permanent. |
| `source` | string | Source label used for later removal. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("caution", 0.3)
  bot:addTraitModifier("caution", 0.4, 1.0, "ambush")
  local boosted = bot:getTrait("caution")
  world:update(2.0)
  lurek.log.info(tostring("LBot:addTraitModifier: boosted=" .. tostring(boosted) .. " now=" .. tostring(bot:getTrait("caution"))))
end
```

---

#### `LBot:getBlackboard`

Returns a blackboard snapshot for this agent or an empty blackboard when the agent has been removed.

```lua
LBot:getBlackboard()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAIBlackboard](#laiblackboard) | Blackboard handle initialized from the agent's local blackboard values at call time. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("ranger")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  local hp = bb:getNumber("hp", 0)
  lurek.log.info(tostring("LBot:getBlackboard: hp=" .. tostring(hp)))
end
```

---

#### `LBot:getDecisionModel`

Returns this agent's decision model name or the default model name for a missing agent.

```lua
LBot:getDecisionModel()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current decision model name. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("farmer")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  lurek.log.info(tostring("LBot:getDecisionModel: " .. model))
end
```

---

#### `LBot:getMaxForce`

Returns this agent's maximum steering force or the default force for a missing agent.

```lua
LBot:getMaxForce()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum steering force value. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("scout")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  lurek.log.info(tostring("LBot:getMaxForce: " .. tostring(force)))
  lurek.log.info(tostring("LBot:getMaxForce: name=" .. npc:getName()))
end
```

---

#### `LBot:getMaxSpeed`

Returns this agent's maximum movement speed or the default speed for a missing agent.

```lua
LBot:getMaxSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Maximum speed in world units per second. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("courier")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  lurek.log.info(tostring("LBot:getMaxSpeed: " .. tostring(speed)))
  lurek.log.info(tostring("LBot:getMaxSpeed: name=" .. npc:getName()))
end
```

---

#### `LBot:getName`

Returns this agent's stable world name.

```lua
LBot:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Agent name stored in the handle. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("knight_03")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local name = npc:getName()
  lurek.log.info(tostring("LBot:getName: " .. name))
end
```

---

#### `LBot:getPosition`

Returns this agent's world position or the origin when the agent has been removed.

```lua
LBot:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y position in world units. (value 1). |
| number | X and Y position in world units. (value 2). |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("static_guard")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  lurek.log.info(tostring("LBot:getPosition: " .. tostring(x) .. ", " .. tostring(y)))
end
```

---

#### `LBot:getPriority`

Returns this agent's integer priority or zero when the agent has been removed.

```lua
LBot:getPriority()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current priority value. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("grunt")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPriority(5)
  local prio = npc:getPriority()
  lurek.log.info(tostring("LBot:getPriority: " .. tostring(prio)))
end
```

---

#### `LBot:getTrait`

Returns one effective trait value from this agent's profile.

```lua
LBot:getTrait(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Trait key to read. |

**Returns**

| Type | Description |
|------|-------------|
| number | Effective trait value, or zero when unset. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("aggression", 0.75)
  local aggression = bot:getTrait("aggression")
  local missing = bot:getTrait("missing")
  lurek.log.info(tostring("LBot:getTrait: aggression=" .. tostring(aggression) .. " missing=" .. tostring(missing)))
end
```

---

#### `LBot:getTraitProfile`

Returns a snapshot copy of this agent's trait profile when one is assigned.

```lua
LBot:getTraitProfile()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Trait profile snapshot, or nil when this agent has no profile. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("caution", 0.6)
  local profile = bot:getTraitProfile()
  local caution = profile:get("caution")
  lurek.log.info(tostring("LBot:getTraitProfile: caution=" .. tostring(caution)))
end
```

---

#### `LBot:getVelocity`

Returns this agent's velocity vector or zero velocity when the agent has been removed.

```lua
LBot:getVelocity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y velocity in world units per second. (value 1). |
| number | X and Y velocity in world units per second. (value 2). |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("idle_npc")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  lurek.log.info(tostring("LBot:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy)))
end
```

---

#### `LBot:hasTag`

Returns whether this agent currently has the given tag.

```lua
LBot:hasTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag name to check in the agent tag set. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tag exists on the agent. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("merchant")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  lurek.log.info(tostring("LBot:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile)))
end
```

---

#### `LBot:hasTraitProfile`

Returns whether this agent currently has an assigned trait profile.

```lua
LBot:hasTraitProfile()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a trait profile exists on the agent. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  local before = bot:hasTraitProfile()
  bot:setTrait("caution", 0.6)
  local after = bot:hasTraitProfile()
  lurek.log.info(tostring("LBot:hasTraitProfile: before=" .. tostring(before) .. " after=" .. tostring(after)))
end
```

---

#### `LBot:removeTag`

Removes a tag string from this agent when the agent still exists in its world.

```lua
LBot:removeTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag name to remove from the agent tag set. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("spy")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  lurek.log.info(tostring("LBot:removeTag: visible=" .. tostring(still_has)))
end
```

---

#### `LBot:setCustomModel`

Installs a Lua callback as this agent's decision model and stores it in the callback registry.

```lua
LBot:setCustomModel(callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `callback` | function | Function called during world updates with `(agent, blackboard, dt)` for this agent. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("thinker")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt) called_with_dt = dt end)
  world:update(0.016)
  lurek.log.info(tostring("LBot:setCustomModel: dt=" .. tostring(called_with_dt)))
end
```

---

#### `LBot:setDecisionModel`

Sets this agent's built-in decision model from a string name when the name is recognized.

```lua
LBot:setDecisionModel(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | string | Decision model name such as `fsm`, `bt`, `utility`, or another engine-supported model string. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("worker")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  lurek.log.info(tostring("LBot:setDecisionModel: " .. model))
end
```

---

#### `LBot:setMaxForce`

Sets this agent's maximum steering force when the agent still exists in its world.

```lua
LBot:setMaxForce(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Maximum steering force applied during steering calculations. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("tank")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxForce(80)
  lurek.log.info(tostring("LBot:setMaxForce: done"))
  lurek.log.info(tostring("LBot:setMaxForce: force=" .. tostring(npc:getMaxForce())))
end
```

---

#### `LBot:setMaxSpeed`

Sets this agent's maximum movement speed when the agent still exists in its world.

```lua
LBot:setMaxSpeed(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Maximum speed in world units per second. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("sprinter")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setMaxSpeed(200)
  lurek.log.info(tostring("LBot:setMaxSpeed: done"))
  lurek.log.info(tostring("LBot:setMaxSpeed: speed=" .. tostring(npc:getMaxSpeed())))
end
```

---

#### `LBot:setPosition`

Sets this agent's world position when the agent still exists in its world.

```lua
LBot:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | New X position in world units. |
| `y` | number | New Y position in world units. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("mover")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPosition(256, 128)
  local x, y = npc:getPosition()
  lurek.log.info(tostring("LBot:setPosition: done"))
  lurek.log.info(tostring("LBot:setPosition: pos=" .. tostring(x) .. ", " .. tostring(y)))
end
```

---

#### `LBot:setPriority`

Sets this agent's integer priority when the agent still exists in its world.

```lua
LBot:setPriority(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | number | Priority value used by game-side AI scheduling or ordering logic. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("captain")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setPriority(10)
  lurek.log.info(tostring("LBot:setPriority: " .. tostring(npc:getPriority())))
end
```

---

#### `LBot:setTrait`

Sets one trait on this agent, creating an empty profile first when needed.

```lua
LBot:setTrait(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Trait key to create or update. |
| `value` | number | Base trait value clamped by the engine to `[0, 1]`. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  bot:setTrait("risk_tolerance", 0.8)
  local risk = bot:getTrait("risk_tolerance")
  bot:setTrait("risk_tolerance", 0.6)
  lurek.log.info(tostring("LBot:setTrait: risk=" .. tostring(risk) .. " updated=" .. tostring(bot:getTrait("risk_tolerance"))))
end
```

---

#### `LBot:setTraitProfile`

Copies a trait profile onto this agent so future agent decisions can read commander personality values.

```lua
LBot:setTraitProfile(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | [LTraitProfile](#ltraitprofile) | Trait profile copied into the agent state. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local bot = world:addAgent("commander")
  local profile = lurek.ai.newTraitProfile()
  profile:set("aggression", 0.7)
  bot:setTraitProfile(profile)
  local aggression = bot:getTrait("aggression")
  lurek.log.info(tostring("LBot:setTraitProfile: aggression=" .. tostring(aggression)))
end
```

---

#### `LBot:setVelocity`

Sets this agent's velocity vector when the agent still exists in its world.

```lua
LBot:setVelocity(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | New X velocity in world units per second. |
| `y` | number | New Y velocity in world units per second. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("runner")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  npc:setVelocity(60, -30)
  local vx, vy = npc:getVelocity()
  lurek.log.info(tostring("LBot:setVelocity: done"))
  lurek.log.info(tostring("LBot:setVelocity: vel=" .. tostring(vx) .. ", " .. tostring(vy)))
end
```

---

#### `LBot:type`

Returns the Lua-visible type name for this agent handle.

```lua
LBot:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBot](#lbot)`. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("villager")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local t = npc:type()
  lurek.log.info(tostring("LBot:type: " .. t))
  lurek.log.info(tostring("LBot:type: matches=" .. tostring(npc:typeOf("LBot"))))
end
```

---

#### `LBot:typeOf`

Returns whether this agent handle matches a supported type name.

```lua
LBot:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `Agent` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local world_type = world:type()
  local npc = world:addAgent("knight")
  local agent_name = npc:getName()
  npc:setPriority(0.5)
  local is_agent = npc:typeOf("LBot")
  local is_image = npc:typeOf("LImage")
  lurek.log.info(tostring("LBot:typeOf: LBot=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image)))
end
```

---

## LCommandQueue

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCommandQueue:cancelCurrent`

Cancels the currently active command when one exists.

```lua
LCommandQueue:cancelCurrent()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a current command was cancelled. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    lurek.log.info(tostring("after cancel, type = " .. tostring(cq:getCurrentType())))
end
```

---

#### `LCommandQueue:clear`

Removes every queued command. This method is available to Lua scripts.

```lua
LCommandQueue:clear()
```

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    lurek.log.info(tostring("after clear, empty = " .. tostring(cq:isEmpty())))
end
```

---

#### `LCommandQueue:enqueue`

Adds a command callback to the back of the queue.

```lua
LCommandQueue:enqueue(kind, callback, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Command type label stored for inspection. |
| `callback` | function | Callback invoked by command execution logic outside this wrapper. |
| `opts?` | table | Optional table with `targetX`, `targetY`, `priority`, and `interruptible` fields. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("move", function() lurek.log.info(tostring("  moving")) end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() lurek.log.info(tostring("  attacking")) end)
    lurek.log.info(tostring("queue size = " .. cq:getCount()))
end
```

---

#### `LCommandQueue:getCount`

Returns the number of commands currently queued.

```lua
LCommandQueue:getCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current queue length. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    lurek.log.info(tostring("count = " .. cq:getCount()))
end
```

---

#### `LCommandQueue:getCurrentTarget`

Returns the current command target coordinates.

```lua
LCommandQueue:getCurrentTarget()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Target X and Y coordinates for the current command; or queue defaults. (value 1). |
| number | Target X and Y coordinates for the current command; or queue defaults. (value 2). |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    lurek.log.info(tostring("target = " .. tostring(tgt)))
end
```

---

#### `LCommandQueue:getCurrentType`

Returns the type label of the current command when one exists.

```lua
LCommandQueue:getCurrentType()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Current command type label, or nil when no command is active. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("harvest", function() end)
    lurek.log.info(tostring("current type = " .. tostring(cq:getCurrentType())))
end
```

---

#### `LCommandQueue:isEmpty`

Returns whether the command queue has no commands.

```lua
LCommandQueue:isEmpty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the queue is empty. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    lurek.log.info(tostring("empty initially = " .. tostring(cq:isEmpty())))
    cq:enqueue("step", function() end)
    lurek.log.info(tostring("empty after enqueue = " .. tostring(cq:isEmpty())))
end
```

---

#### `LCommandQueue:pushFront`

Adds a command callback to the front of the queue.

```lua
LCommandQueue:pushFront(kind, callback, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Command type label stored for inspection. |
| `callback` | function | Callback invoked by command execution logic outside this wrapper. |
| `opts?` | table | Optional table with `targetX`, `targetY`, `priority`, and `interruptible` fields. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() lurek.log.info(tostring("  dodging")) end)
    lurek.log.info(tostring("next type = " .. cq:getCurrentType()))
end
```

---

#### `LCommandQueue:replace`

Replaces the queue contents with one command callback.

```lua
LCommandQueue:replace(kind, callback, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kind` | string | Command type label stored for inspection. |
| `callback` | function | Callback invoked by command execution logic outside this wrapper. |
| `opts?` | table | Optional table with `targetX`, `targetY`, `priority`, and `interruptible` fields. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() lurek.log.info(tostring("  retreating")) end)
    lurek.log.info(tostring("after replace count = " .. cq:getCount()))
end
```

---

#### `LCommandQueue:type`

Returns the Lua-visible type name for this command queue handle.

```lua
LCommandQueue:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LCommandQueue](#lcommandqueue)`. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    lurek.log.info(tostring("type = " .. cq:type()))
  lurek.log.info(tostring("matches = " .. tostring(cq:typeOf("LCommandQueue"))))
end
```

---

#### `LCommandQueue:typeOf`

Returns whether this command queue handle matches a supported type name.

```lua
LCommandQueue:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `CommandQueue` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cq = lurek.ai.newCommandQueue()
  cq:enqueue("hold", function() end, { targetX = 0, targetY = 0 })
  local queue_count = cq:getCount()
    local type_name = cq:type()
    lurek.log.info(tostring("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue"))))
end
```

---

## LDecisionBiasSet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDecisionBiasSet:addRule`

Adds one rule that adjusts a named decision score using one trait.

```lua
LDecisionBiasSet:addRule(trait_name, decision_key, weight, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `trait_name` | string | Trait key read from a profile. |
| `decision_key` | string | Action or goal key affected by this rule; `*` applies to every key. |
| `weight` | number | Adjustment strength; negative values reduce the score. |
| `mode?` | string | `add` or `multiply`; defaults to `add`. |

**Example**

```lua
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2, "add")
  bias:addRule("caution", "retreat", 0.3, "multiply")
  local count = bias:ruleCount()
  lurek.log.info(tostring("LDecisionBiasSet:addRule: count=" .. tostring(count)))
end
```

---

#### `LDecisionBiasSet:ruleCount`

Returns the number of stored bias rules.

```lua
LDecisionBiasSet:ruleCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Rule count. |

**Example**

```lua
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2)
  bias:addRule("defensiveness", "defend", 0.3)
  local count = bias:ruleCount()
  lurek.log.info(tostring("LDecisionBiasSet:ruleCount: " .. tostring(count)))
end
```

---

#### `LDecisionBiasSet:score`

Scores one decision using a profile and this bias set.

```lua
LDecisionBiasSet:score(profile, decision_key, base_score)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | [LTraitProfile](#ltraitprofile) | Profile that supplies trait values. |
| `decision_key` | string | Decision key to score. |
| `base_score` | number | Base score before bias rules. |

**Returns**

| Type | Description |
|------|-------------|
| number | Biased score clamped to `[0, 1]`. |

**Example**

```lua
do
  local profile = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  profile:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.2, "add")
  local score = bias:score(profile, "attack", 0.5)
  lurek.log.info(tostring("LDecisionBiasSet:score: " .. tostring(score)))
end
```

---

#### `LDecisionBiasSet:type`

Returns the Lua-visible type name for this decision bias handle.

```lua
LDecisionBiasSet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDecisionBiasSet](#ldecisionbiasset)`. |

**Example**

```lua
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2)
  local count = bias:ruleCount()
  local type_name = bias:type()
  lurek.log.info(tostring("LDecisionBiasSet:type: " .. type_name .. " count=" .. tostring(count)))
end
```

---

#### `LDecisionBiasSet:typeOf`

Returns whether this decision bias handle matches a supported type name.

```lua
LDecisionBiasSet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDecisionBiasSet](#ldecisionbiasset)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local bias = lurek.ai.newDecisionBiasSet()
  bias:addRule("aggression", "attack", 0.2)
  local is_bias = bias:typeOf("LDecisionBiasSet")
  local is_object = bias:typeOf("LObject")
  lurek.log.info(tostring("LDecisionBiasSet:typeOf: bias=" .. tostring(is_bias) .. " object=" .. tostring(is_object)))
end
```

---

## LDialogueAI

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDialogueAI:addBranch`

Adds a selectable branch under an existing dialogue topic.

```lua
LDialogueAI:addBranch(topic_id, branch_id, weight, fsm_state, bt_status, utility_key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `topic_id` | string | Topic identifier that receives the branch. |
| `branch_id` | string | Unique branch identifier within the topic. |
| `weight?` | number | Base branch weight; defaults to 1.0. |
| `fsm_state?` | string | Optional FSM state required for this branch. |
| `bt_status?` | string | Optional behavior tree status required for this branch. |
| `utility_key?` | string | Optional utility score key multiplied into selection. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the branch was added to an existing topic. |

---

#### `LDialogueAI:addTopic`

Adds a selectable dialogue topic with optional context filters.

```lua
LDialogueAI:addTopic(id, weight, fsm_state, bt_status, utility_key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Unique topic identifier. |
| `weight?` | number | Base selection weight; defaults to 1.0. |
| `fsm_state?` | string | Optional FSM state required for this topic. |
| `bt_status?` | string | Optional behavior tree status required for this topic. |
| `utility_key?` | string | Optional utility score key multiplied into selection. |

---

#### `LDialogueAI:clearUtilityScores`

Removes every stored utility score from this dialogue selector.

```lua
LDialogueAI:clearUtilityScores()
```

---

#### `LDialogueAI:getTopicCount`

Returns the number of topics registered in this dialogue selector.

```lua
LDialogueAI:getTopicCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current topic count. |

---

#### `LDialogueAI:selectBranch`

Selects the best currently valid branch for the given topic.

```lua
LDialogueAI:selectBranch(topic_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `topic_id` | string | Topic identifier whose branches should be considered. |

**Returns**

| Type | Description |
|------|-------------|
| string | Selected branch identifier, or nil when no branch is available. |

---

#### `LDialogueAI:selectTopic`

Selects the best currently valid topic using weights and context filters.

```lua
LDialogueAI:selectTopic()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Selected topic identifier, or nil when no topic is available. |

---

#### `LDialogueAI:setBTStatus`

Sets the behavior-tree status used as dialogue selection context.

```lua
LDialogueAI:setBTStatus(status)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `status?` | string | Current behavior tree status, or nil to clear the status context. |

---

#### `LDialogueAI:setFSMState`

Sets the finite-state-machine state used as dialogue selection context.

```lua
LDialogueAI:setFSMState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state?` | string | Current FSM state name, or nil to clear the FSM context. |

---

#### `LDialogueAI:setUtilityScore`

Stores a utility score used by topics and branches that reference the given key.

```lua
LDialogueAI:setUtilityScore(key, score)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Utility score key. |
| `score` | number | Utility score value used during weighted selection. |

---

#### `LDialogueAI:type`

Returns the Lua-visible type name for this dialogue AI handle.

```lua
LDialogueAI:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDialogueAI](#ldialogueai)`. |

---

#### `LDialogueAI:typeOf`

Returns whether this dialogue AI handle matches a supported type name.

```lua
LDialogueAI:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `DialogueAI` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

## LEmotionModel

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LEmotionModel:add`

Adds an emotion definition with resting value, decay, and visibility threshold.

```lua
LEmotionModel:add(name, rest, decay, min_vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Emotion name. |
| `rest` | number | Resting emotion value. |
| `decay` | number | Decay rate back toward rest. |
| `min_vis` | number | Minimum value considered visible or active. |

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    local joy = em:get("joy")
    local anger = em:get("anger")
    lurek.log.info(tostring("emotions registered"))
end
```

---

#### `LEmotionModel:dominant`

Returns the strongest active emotion name when one is available.

```lua
LEmotionModel:dominant()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Dominant emotion name, or nil when no emotion is active. |

**Example**

```lua
do
  local em = lurek.ai.newEmotionModel()
  em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    lurek.log.info(tostring("dominant = " .. tostring(em:dominant())))
end
```

---

#### `LEmotionModel:get`

Returns the current value of a named emotion.

```lua
LEmotionModel:get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Emotion name to read. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current emotion value. |

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    lurek.log.info(tostring("sadness = " .. val))
end
```

---

#### `LEmotionModel:isActive`

Returns whether a named emotion is currently active.

```lua
LEmotionModel:isActive(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Emotion name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the emotion is above its active threshold. |

**Example**

```lua
do
  local em = lurek.ai.newEmotionModel()
  em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    lurek.log.info(tostring("surprise active = " .. tostring(em:isActive("surprise"))))
    em:trigger("surprise", 0.5)
    lurek.log.info(tostring("surprise active = " .. tostring(em:isActive("surprise"))))
end
```

---

#### `LEmotionModel:reset`

Resets all emotions toward their default state.

```lua
LEmotionModel:reset()
```

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    lurek.log.info(tostring("rage after reset = " .. em:get("rage")))
end
```

---

#### `LEmotionModel:trigger`

Adds an amount to a named emotion. This method is available to Lua scripts.

```lua
LEmotionModel:trigger(name, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Emotion name to trigger. |
| `amount` | number | Amount added to the current emotion value. |

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    local dominant = em:dominant()
    local active = em:isActive("fear")
    lurek.log.info(tostring("fear = " .. em:get("fear")))
end
```

---

#### `LEmotionModel:type`

Returns the Lua-visible type name for this emotion model handle.

```lua
LEmotionModel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LEmotionModel](#lemotionmodel)`. |

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.1, 0.1, 0.1)
    local dominant = em:dominant()
    lurek.log.info(tostring("type = " .. em:type()))
  lurek.log.info(tostring("matches = " .. tostring(em:typeOf("LEmotionModel"))))
end
```

---

#### `LEmotionModel:typeOf`

Returns whether this emotion model handle matches a supported type name.

```lua
LEmotionModel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LEmotionModel](#lemotionmodel)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.1, 0.1, 0.1)
    local type_name = em:type()
    local dominant = em:dominant()
    lurek.log.info(tostring("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel"))))
end
```

---

#### `LEmotionModel:update`

Advances emotion decay over elapsed time.

```lua
LEmotionModel:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    lurek.log.info(tostring("excitement after 3s = " .. em:get("excitement")))
end
```

---

## LGOAPPlanner

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGOAPPlanner:addAction`

Adds a GOAP action with optional cost and completion callback.

```lua
LGOAPPlanner:addAction(name, cost, callback)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Action name emitted in generated plans. |
| `cost?` | number | Planning cost for the action; defaults to 1.0. |
| `callback?` | function | Optional callback stored with the action for game-side execution. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("chop_wood", 2, function() lurek.log.info(tostring("  chopping wood")) end)
    goap:addAction("build_house", 5, function() lurek.log.info(tostring("  building house")) end)
    lurek.log.info(tostring("goap actions = " .. goap:getActionCount()))
end
```

---

#### `LGOAPPlanner:addGoal`

Adds a GOAP goal with an optional priority weight.

```lua
LGOAPPlanner:addGoal(name, priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Goal name used for planning and debugging. |
| `priority?` | number | Goal priority; defaults to 1.0. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    lurek.log.info(tostring("goals = " .. goap:getGoalCount()))
end
```

---

#### `LGOAPPlanner:getActionCount`

Returns the number of GOAP actions registered in this planner.

```lua
LGOAPPlanner:getActionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current action count. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    lurek.log.info(tostring("action count = " .. goap:getActionCount()))
end
```

---

#### `LGOAPPlanner:getGoalCount`

Returns the number of GOAP goals registered in this planner.

```lua
LGOAPPlanner:getGoalCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current goal count. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    lurek.log.info(tostring("goal count = " .. goap:getGoalCount()))
end
```

---

#### `LGOAPPlanner:getLastFailureReason`

Returns the last planner failure reason string when planning did not succeed.

```lua
LGOAPPlanner:getLastFailureReason()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Failure reason string, or nil when the last plan succeeded. |

**Example**

```lua
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:setMaxIterations(1)
  goap:addAction("get_axe", 1.0)
  goap:setEffect("get_axe", "has_axe", true)
  goap:addAction("chop", 1.0)
  goap:setPrecondition("chop", "has_axe", true)
  goap:setEffect("chop", "has_wood", true)
  goap:addGoal("house", 1.0)
  goap:setGoalState("house", "has_house", true)
  local plan = goap:plan({ has_axe = false, has_wood = false, has_house = false }, 8)
  lurek.log.info(tostring("LGOAPPlanner:getLastFailureReason: plan_size=" .. tostring(#plan)))
  lurek.log.info(tostring("LGOAPPlanner:getLastFailureReason: failure=" .. tostring(goap:getLastFailureReason())))
end
```

---

#### `LGOAPPlanner:getLastTrace`

Returns the last structured GOAP planning trace.

```lua
LGOAPPlanner:getLastTrace()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table containing `selected_goal`, `chosen_plan`, `iterations`, `expanded_nodes`, and `failure_reason`. |

**Example**

```lua
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:plan({}, 4)
  local trace = goap:getLastTrace()
  lurek.log.info(tostring("LGOAPPlanner:getLastTrace: failure=" .. tostring(trace.failure_reason)))
  lurek.log.info(tostring("LGOAPPlanner:getLastTrace: iterations=" .. tostring(trace.iterations)))
  lurek.log.info(tostring("LGOAPPlanner:getLastTrace: selected_goal=" .. tostring(trace.selected_goal)))
end
```

---

#### `LGOAPPlanner:getMaxIterations`

Returns the maximum number of planner iterations allowed during search.

```lua
LGOAPPlanner:getMaxIterations()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current maximum iteration count. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    local max = goap:getMaxIterations()
    lurek.log.info(tostring("default max iterations = " .. max))
end
```

---

#### `LGOAPPlanner:plan`

Builds a plan from the supplied boolean world state and returns action names in execution order.

```lua
LGOAPPlanner:plan(world_state_tbl, max_depth)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `world_state_tbl` | table | Map table from string world-state keys to boolean values. |
| `max_depth?` | number | Maximum search depth; defaults to 10. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Action names selected by the planner. |

**Example**

```lua
do
  local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
  goap:addAction("get_wood", 1, function() end)
  goap:setEffect("get_wood", "has_wood", true)
  goap:addAction("build", 2, function() end)
  goap:setPrecondition("build", "has_wood", true)
  goap:setEffect("build", "house_done", true)
  goap:addGoal("build_house", 10)
  goap:setGoalState("build_house", "house_done", true)
  local plan = goap:plan({ has_wood = false, house_done = false }, 10)
  lurek.log.info(tostring("plan steps = " .. #plan))
end
```

---

#### `LGOAPPlanner:setEffect`

Sets one boolean effect produced by an existing GOAP action.

```lua
LGOAPPlanner:setEffect(action_name, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_name` | string | Name of the action to update. |
| `key` | string | World-state key changed by the action. |
| `value` | boolean | Boolean value written by the effect. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    lurek.log.info(tostring("effect set for mine_ore"))
end
```

---

#### `LGOAPPlanner:setGoalState`

Sets one desired world-state key for an existing GOAP goal.

```lua
LGOAPPlanner:setGoalState(goal_name, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `goal_name` | string | Name of the goal to update. |
| `key` | string | World-state key required by the goal. |
| `value` | boolean | Desired boolean value for the key. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    lurek.log.info(tostring("goal state set for build_shelter"))
end
```

---

#### `LGOAPPlanner:setMaxIterations`

Sets the maximum number of planner iterations allowed during search.

```lua
LGOAPPlanner:setMaxIterations(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Maximum iteration count. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:setMaxIterations(500)
    lurek.log.info(tostring("max iterations = " .. goap:getMaxIterations()))
end
```

---

#### `LGOAPPlanner:setPrecondition`

Sets one boolean precondition for an existing GOAP action.

```lua
LGOAPPlanner:setPrecondition(action_name, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_name` | string | Name of the action to update. |
| `key` | string | World-state key required by the action. |
| `value` | boolean | Required boolean value for the key. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    lurek.log.info(tostring("precondition set for cook"))
end
```

---

#### `LGOAPPlanner:type`

Returns the Lua-visible type name for this GOAP planner handle.

```lua
LGOAPPlanner:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGOAPPlanner](#lgoapplanner)`. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    lurek.log.info(tostring("type = " .. goap:type()))
  lurek.log.info(tostring("matches = " .. tostring(goap:typeOf("LGOAPPlanner"))))
end
```

---

#### `LGOAPPlanner:typeOf`

Returns whether this GOAP planner handle matches a supported type name.

```lua
LGOAPPlanner:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `GOAPPlanner` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local goap = lurek.ai.newGOAPPlanner()
  goap:addGoal("idle", 1)
  local goal_count = goap:getGoalCount()
    local type_name = goap:type()
    lurek.log.info(tostring("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner"))))
end
```

---

## LHTNDomain

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHTNDomain:addCompound`

Adds a compound HTN task with one or more ordered method definitions.

```lua
LHTNDomain:addCompound(comp_name, methods_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `comp_name` | string | Compound task name. |
| `methods_table` | table | Array of method tables with `name`, `preconditions`, and `sub_tasks` fields. |

**Example**

```lua
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
  htn:addCompound("get_metal", { { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } } })
  lurek.log.info(tostring("compound added, tasks = " .. htn:taskCount()))
end
```

---

#### `LHTNDomain:addPrimitive`

Adds a primitive HTN task with preconditions, effects, and cleared facts.

```lua
LHTNDomain:addPrimitive(name, preconds, effects, clears)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Primitive task name. |
| `preconds` | table | Array of fact names required before the task can run. |
| `effects` | table | Array of fact names added by the task. |
| `clears` | table | Array of fact names removed by the task. |

**Example**

```lua
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    lurek.log.info(tostring("primitives = " .. htn:taskCount()))
end
```

---

#### `LHTNDomain:plan`

Plans from a root HTN task and numeric world state facts.

```lua
LHTNDomain:plan(root_task, state_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `root_task` | string | Root task name to decompose. |
| `state_table` | table | Map table from fact names to numeric values. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Array table of primitive task names, or nil when no plan is found. |

**Example**

```lua
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("gather", {}, { "has_food" }, {})
    htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
  htn:addCompound("prepare_meal", { { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } } })
  local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
  if plan then
    lurek.log.info(tostring("plan size = " .. #plan))
    lurek.log.info(tostring("plan = " .. table.concat(plan, " -> ")))
  end
end
```

---

#### `LHTNDomain:taskCount`

Returns the number of tasks defined in this HTN domain.

```lua
LHTNDomain:taskCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current task count. |

**Example**

```lua
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    lurek.log.info(tostring("task count = " .. htn:taskCount()))
end
```

---

#### `LHTNDomain:type`

Returns the Lua-visible type name for this HTN domain handle.

```lua
LHTNDomain:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LHTNDomain](#lhtndomain)`. |

**Example**

```lua
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    lurek.log.info(tostring("type = " .. htn:type()))
  lurek.log.info(tostring("matches = " .. tostring(htn:typeOf("LHTNDomain"))))
end
```

---

#### `LHTNDomain:typeOf`

Returns whether this HTN domain handle matches a supported type name.

```lua
LHTNDomain:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LHTNDomain](#lhtndomain)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local htn = lurek.ai.newHTNDomain()
  local domain_type = htn:type()
  local task_count = htn:taskCount()
    local type_name = htn:type()
    lurek.log.info(tostring("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain"))))
end
```

---

## LMCTSEngine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMCTSEngine:getLastTrace`

Returns the last structured MCTS search trace.

```lua
LMCTSEngine:getLastTrace()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table containing `chosen_action`, `iterations_run`, `nodes_expanded`, `invalid_score_count`, `callback_errors`, and `failure_reason`. |

**Example**

```lua
do
  local mcts = lurek.ai.newMCTSEngine(8, 1.4, 4, 42)
  mcts:search(
    1,
    function(_) return { 7 } end,
    function(state, act) return state + act end,
    function(_) return 0 / 0 end
  )
  local trace = mcts:getLastTrace()
  lurek.log.info(tostring("LMCTSEngine:getLastTrace: invalid_scores=" .. tostring(trace.invalid_score_count)))
end
```

---

#### `LMCTSEngine:search`

Runs MCTS from a root state using Lua callbacks for actions, transitions, and evaluation.

```lua
LMCTSEngine:search(root_state, get_actions_fn, apply_fn, eval_fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `root_state` | number | Opaque integer state identifier supplied by game code. |
| `get_actions_fn` | function | Function called with a state and returning an array of integer actions. |
| `apply_fn` | function | Function called with `(state, action)` and returning the next state integer. |
| `eval_fn` | function | Function called with a state and returning a numeric score. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Selected action integer, or nil when search cannot choose an action. |

**Example**

```lua
do
    local mcts = lurek.ai.newMCTSEngine(100, 1.4, 10, 42)
  local action = mcts:search(
    1,
    function(state) return { 1, 2, 3 } end,
    function(state, act) return state + act end,
    function(state) return -math.abs(state - 5) end
  )
  lurek.log.info(tostring("best action = " .. tostring(action)))
end
```

---

#### `LMCTSEngine:type`

Returns the Lua-visible type name for this MCTS engine handle.

```lua
LMCTSEngine:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LMCTSEngine](#lmctsengine)`. |

**Example**

```lua
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    local simulations = 50
    local exploration = 1.0
    lurek.log.info(tostring("type = " .. mcts:type()))
  lurek.log.info(tostring("matches = " .. tostring(mcts:typeOf("LMCTSEngine"))))
end
```

---

#### `LMCTSEngine:typeOf`

Returns whether this MCTS engine handle matches a supported type name.

```lua
LMCTSEngine:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LMCTSEngine](#lmctsengine)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    local simulations = 50
    local exploration = 1.0
    local type_name = mcts:type()
    lurek.log.info(tostring("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine"))))
end
```

---

## LNeedSystem

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNeedSystem:addNeed`

Adds a need with decay and urgency tuning values.

```lua
LNeedSystem:addNeed(name, decay_rate, urgency_threshold, urgency_factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Need name used by satisfaction and lookup calls. |
| `decay_rate` | number | Value decay rate applied during updates. |
| `urgency_threshold` | number | Value threshold where the need becomes urgent. |
| `urgency_factor` | number | Weight applied to urgent needs. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    lurek.log.info(tostring("needs registered"))
end
```

---

#### `LNeedSystem:mostUrgent`

Returns the name of the most urgent need when any need is active.

```lua
LNeedSystem:mostUrgent()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Need name, or nil when no urgent need is available. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    lurek.log.info(tostring("most urgent = " .. tostring(name)))
end
```

---

#### `LNeedSystem:satisfy`

Reduces or satisfies a named need by the supplied amount.

```lua
LNeedSystem:satisfy(name, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Need name to satisfy. |
| `amount` | number | Amount applied to the need value. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    lurek.log.info(tostring("thirst satisfied"))
end
```

---

#### `LNeedSystem:type`

Returns the Lua-visible type name for this need system handle.

```lua
LNeedSystem:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNeedSystem](#lneedsystem)`. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    lurek.log.info(tostring("type = " .. ns:type()))
  lurek.log.info(tostring("matches = " .. tostring(ns:typeOf("LNeedSystem"))))
end
```

---

#### `LNeedSystem:typeOf`

Returns whether this need system handle matches a supported type name.

```lua
LNeedSystem:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNeedSystem](#lneedsystem)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    local type_name = ns:type()
    lurek.log.info(tostring("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem"))))
end
```

---

#### `LNeedSystem:update`

Advances need decay over elapsed time.

```lua
LNeedSystem:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    lurek.log.info(tostring("most urgent after 2s = " .. tostring(urgent)))
end
```

---

#### `LNeedSystem:valueOf`

Returns the current value of a named need.

```lua
LNeedSystem:valueOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Need name to read. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current need value. |

**Example**

```lua
do
    local ns = lurek.ai.newNeedSystem()
  ns:addNeed("rest", 0.1, 0.5, 1.0)
  local urgent_need = ns:mostUrgent()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    lurek.log.info(tostring("hunger value = " .. val))
end
```

---

## LSquad

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSquad:addMember`

Adds a member name to the squad member list.

```lua
LSquad:addMember(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Agent or game object name to append as a squad member. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("bravo")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    lurek.log.info(tostring("members = " .. sq:getMemberCount()))
end
```

---

#### `LSquad:getBlackboard`

Returns a blackboard snapshot for this squad.

```lua
LSquad:getBlackboard()
```

**Returns**

| Type | Description |
|------|-------------|
| [LAIBlackboard](#laiblackboard) | Blackboard handle initialized from the squad blackboard values at call time. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("intel")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    lurek.log.info(tostring("squad bb threat = " .. bb:getNumber("threat_level")))
end
```

---

#### `LSquad:getFormation`

Returns the current squad formation type name.

```lua
LSquad:getFormation()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Formation type name. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("recon")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    lurek.log.info(tostring("formation = " .. f))
end
```

---

#### `LSquad:getFormationPosition`

Returns a member's target formation position relative to the leader position.

```lua
LSquad:getFormationPosition(member_idx, leader_x, leader_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `member_idx` | number | One-based member index in the squad. |
| `leader_x` | number | Leader X position in world units. |
| `leader_y` | number | Leader Y position in world units. |

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y formation target position. (value 1). |
| number | X and Y formation target position. (value 2). |

**Example**

```lua
do
  local sq = lurek.ai.newSquad("patrol")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
  sq:addMember("lead")
  sq:addMember("flank_l")
  sq:addMember("flank_r")
    sq:setFormation("wedge", 2.0)
    local x, y = sq:getFormationPosition(2, 100.0, 50.0)
    lurek.log.info(tostring("member 2 pos = " .. x .. ", " .. y))
end
```

---

#### `LSquad:getFormationSpacing`

Returns the spacing used by squad formation positioning.

```lua
LSquad:getFormationSpacing()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Formation spacing in world units. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("assault")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    lurek.log.info(tostring("spacing = " .. s))
end
```

---

#### `LSquad:getLeader`

Returns the squad leader name when one is assigned.

```lua
LSquad:getLeader()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Leader name, or nil when no leader is assigned. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("golf")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    lurek.log.info(tostring("leader = " .. tostring(leader)))
end
```

---

#### `LSquad:getMemberCount`

Returns the number of members in this squad.

```lua
LSquad:getMemberCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current member count. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("delta")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    lurek.log.info(tostring("count = " .. sq:getMemberCount()))
end
```

---

#### `LSquad:getMembers`

Returns all squad members in an array-style Lua table.

```lua
LSquad:getMembers()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Member names. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("echo")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    lurek.log.info(tostring("members: " .. table.concat(members, ", ")))
end
```

---

#### `LSquad:getName`

Returns the squad name. This method is available to Lua scripts.

```lua
LSquad:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Squad name supplied at construction. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("alpha")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:setLeader("unit_1")
    lurek.log.info(tostring("squad name = " .. sq:getName()))
end
```

---

#### `LSquad:removeMember`

Removes every member entry with the given name.

```lua
LSquad:removeMember(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Member name to remove. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("charlie")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    lurek.log.info(tostring("after remove = " .. sq:getMemberCount()))
end
```

---

#### `LSquad:setFormation`

Sets the squad formation type and optionally updates spacing.

```lua
LSquad:setFormation(ftype, spacing)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ftype` | string | Formation type name parsed by the engine. |
| `spacing?` | number | Optional spacing between formation slots. |

**Example**

```lua
do
  local sq = lurek.ai.newSquad("hotel")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
  sq:addMember("point")
    sq:addMember("left")
    sq:addMember("right")
    sq:setFormation("wedge", 2.0)
    lurek.log.info(tostring("formation set to wedge, spacing 2.0"))
end
```

---

#### `LSquad:setLeader`

Sets the squad leader name. This method is available to Lua scripts.

```lua
LSquad:setLeader(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Member or agent name to store as leader. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("foxtrot")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    lurek.log.info(tostring("leader = " .. sq:getLeader()))
end
```

---

#### `LSquad:type`

Returns the Lua-visible type name for this squad handle.

```lua
LSquad:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSquad](#lsquad)`. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("test")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    lurek.log.info(tostring("type = " .. sq:type()))
  lurek.log.info(tostring("matches = " .. tostring(sq:typeOf("LSquad"))))
end
```

---

#### `LSquad:typeOf`

Returns whether this squad handle matches a supported type name.

```lua
LSquad:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `Squad` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local sq = lurek.ai.newSquad("test2")
  sq:addMember("unit_1")
  local member_count = sq:getMemberCount()
    local type_name = sq:type()
    lurek.log.info(tostring("is LSquad = " .. tostring(sq:typeOf("LSquad"))))
end
```

---

## LStateMachine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStateMachine:addState`

Adds a state with optional Lua lifecycle callbacks.

```lua
LStateMachine:addState(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | State name used by transitions and direct state changes. |
| `opts` | table | Optional table with `onEnter`, `onUpdate`, and `onExit` callback functions. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local entered = ""
  fsm:addState("patrol", { onEnter = function() entered = "patrol" end })
  fsm:setInitialState("patrol")
  lurek.log.info(tostring("LStateMachine:addState: entered=" .. entered))
end
```

---

#### `LStateMachine:addTransition`

Adds a transition between two states with an optional guard callback and priority.

```lua
LStateMachine:addTransition(from, to, guard, priority)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | string | Source state name. |
| `to` | string | Destination state name. |
| `guard?` | function | Optional function that must return true for the transition to run. |
| `priority?` | number | Transition priority used when multiple transitions are available; defaults to zero. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  lurek.log.info(tostring("LStateMachine:addTransition: configured"))
end
```

---

#### `LStateMachine:forceState`

Immediately switches the current state and resets the time spent in state.

```lua
LStateMachine:forceState(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | State name to set as current without transition checks. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("alive", {})
  fsm:addState("dead", {})
  fsm:setInitialState("alive")
  fsm:forceState("dead")
  local current = fsm:getCurrentState() or "none"
  lurek.log.info(tostring("LStateMachine:forceState: " .. current))
end
```

---

#### `LStateMachine:getCurrentState`

Returns the current state name when the state machine has entered a state.

```lua
LStateMachine:getCurrentState()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Current state name, or nil before any state is active. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  lurek.log.info(tostring("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after)))
end
```

---

#### `LStateMachine:getTimeInState`

Returns how long the machine has spent in the current state.

```lua
LStateMachine:getTimeInState()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Elapsed time in seconds since the current state was entered. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  lurek.log.info(tostring("LStateMachine:getTimeInState: " .. tostring(time_in)))
end
```

---

#### `LStateMachine:setInitialState`

Sets the initial state and also enters it when the machine has no current state yet.

```lua
LStateMachine:setInitialState(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | State name to use as the initial state. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  lurek.log.info(tostring("LStateMachine:setInitialState: " .. current .. " log=" .. log))
end
```

---

#### `LStateMachine:type`

Returns the Lua-visible type name for this state machine handle.

```lua
LStateMachine:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LStateMachine](#lstatemachine)`. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local t = fsm:type()
  lurek.log.info(tostring("LStateMachine:type: " .. t))
  lurek.log.info(tostring("LStateMachine:type: matches=" .. tostring(fsm:typeOf("LStateMachine"))))
end
```

---

#### `LStateMachine:typeOf`

Returns whether this state machine handle matches a supported type name.

```lua
LStateMachine:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `StateMachine` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  local fsm_type = fsm:type()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  lurek.log.info(tostring("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other)))
end
```

---

## LStimulusWorld

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStimulusWorld:addAuditory`

Adds an auditory stimulus with decay and returns its identifier.

```lua
LStimulusWorld:addAuditory(x, y, intensity, radius, decay_rate, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Stimulus X position in world units. |
| `y` | number | Stimulus Y position in world units. |
| `intensity` | number | Initial stimulus intensity. |
| `radius` | number | Stimulus radius in world units. |
| `decay_rate` | number | Intensity decay rate applied during updates. |
| `tag?` | string | Optional category tag for game-side filtering. |

**Returns**

| Type | Description |
|------|-------------|
| number | New stimulus identifier. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    lurek.log.info(tostring("auditory stimulus id = " .. id))
end
```

---

#### `LStimulusWorld:addVisual`

Adds a visual stimulus and returns its identifier.

```lua
LStimulusWorld:addVisual(x, y, intensity, radius, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Stimulus X position in world units. |
| `y` | number | Stimulus Y position in world units. |
| `intensity` | number | Initial stimulus intensity. |
| `radius` | number | Stimulus radius in world units. |
| `tag?` | string | Optional category tag for game-side filtering. |

**Returns**

| Type | Description |
|------|-------------|
| number | New stimulus identifier. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    lurek.log.info(tostring("visual stimulus id = " .. id))
end
```

---

#### `LStimulusWorld:clear`

Removes every active stimulus. This method is available to Lua scripts.

```lua
LStimulusWorld:clear()
```

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    lurek.log.info(tostring("after clear, count = " .. sw:count()))
end
```

---

#### `LStimulusWorld:count`

Returns the number of active stimuli.

```lua
LStimulusWorld:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Active stimulus count. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    lurek.log.info(tostring("stimulus count = " .. sw:count()))
end
```

---

#### `LStimulusWorld:remove`

Removes a stimulus by identifier. This method is available to Lua scripts.

```lua
LStimulusWorld:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stimulus identifier returned by `addVisual` or `addAuditory`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a stimulus was removed. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    lurek.log.info(tostring("removed stimulus, count = " .. sw:count()))
end
```

---

#### `LStimulusWorld:type`

Returns the Lua-visible type name for this stimulus world handle.

```lua
LStimulusWorld:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LStimulusWorld](#lstimulusworld)`. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    lurek.log.info(tostring("type = " .. sw:type()))
  lurek.log.info(tostring("matches = " .. tostring(sw:typeOf("LStimulusWorld"))))
end
```

---

#### `LStimulusWorld:typeOf`

Returns whether this stimulus world handle matches a supported type name.

```lua
LStimulusWorld:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LStimulusWorld](#lstimulusworld)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    local type_name = sw:type()
    lurek.log.info(tostring("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld"))))
end
```

---

#### `LStimulusWorld:update`

Advances stimulus decay and lifetime state.

```lua
LStimulusWorld:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local sw = lurek.ai.newStimulusWorld()
  local stimulus_id = sw:addVisual(0, 0, 0.5, 8.0, "ping")
  local stimulus_count = sw:count()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    lurek.log.info(tostring("after update, count = " .. sw:count()))
end
```

---

## LStrategyAI

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStrategyAI:activeGoal`

Returns the currently active strategic goal when one is selected.

```lua
LStrategyAI:activeGoal()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Active goal name, or nil before selection. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    strat:addTag("waiting")
    local until_next = strat:timeUntilNext()
    local active = strat:activeGoal()
    lurek.log.info(tostring("active goal = " .. tostring(active)))
end
```

---

#### `LStrategyAI:addGoal`

Adds a named strategic goal. This method is available to Lua scripts.

```lua
LStrategyAI:addGoal(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Goal name scored by update callbacks. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    lurek.log.info(tostring("goals registered"))
end
```

---

#### `LStrategyAI:addTag`

Adds a context tag to this strategy AI.

```lua
LStrategyAI:addTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag name to add. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    strat:addGoal("expand")
    local next_eval = strat:timeUntilNext()
    lurek.log.info(tostring("tags added"))
end
```

---

#### `LStrategyAI:forceEvaluate`

Immediately scores all goals and updates the active goal.

```lua
LStrategyAI:forceEvaluate(scorer_fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `scorer_fn` | function | Function called with a goal name and returning a numeric score. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal) if goal == "scout" then return 5.0 end return 1.0 end)
    lurek.log.info(tostring("forced active = " .. tostring(strat:activeGoal())))
end
```

---

#### `LStrategyAI:removeTag`

Removes a context tag from this strategy AI.

```lua
LStrategyAI:removeTag(tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tag` | string | Tag name to remove. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    strat:addGoal("defend")
    local next_eval = strat:timeUntilNext()
    lurek.log.info(tostring("tag removed"))
end
```

---

#### `LStrategyAI:timeUntilNext`

Returns time remaining until the next scheduled strategy evaluation.

```lua
LStrategyAI:timeUntilNext()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Seconds until the next interval evaluation. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    strat:addTag("timer")
    local active = strat:activeGoal()
    lurek.log.info(tostring("time until next = " .. strat:timeUntilNext()))
end
```

---

#### `LStrategyAI:type`

Returns the Lua-visible type name for this strategy AI handle.

```lua
LStrategyAI:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LStrategyAI](#lstrategyai)`. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    lurek.log.info(tostring("type = " .. strat:type()))
  lurek.log.info(tostring("matches = " .. tostring(strat:typeOf("LStrategyAI"))))
end
```

---

#### `LStrategyAI:typeOf`

Returns whether this strategy AI handle matches a supported type name.

```lua
LStrategyAI:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LStrategyAI](#lstrategyai)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local until_next = strat:timeUntilNext()
    local type_name = strat:type()
    lurek.log.info(tostring("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI"))))
end
```

---

#### `LStrategyAI:update`

Advances strategy timing and scores goals when the update interval has elapsed.

```lua
LStrategyAI:update(dt, scorer_fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |
| `scorer_fn` | function | Function called with a goal name and returning a numeric score. |

**Example**

```lua
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal) if goal == "attack" then return 0.8 end return 0.2 end)
    lurek.log.info(tostring("active = " .. tostring(strat:activeGoal())))
end
```

---

## LTraitArchetypes

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTraitArchetypes:count`

Returns the number of registered archetypes.

```lua
LTraitArchetypes:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Archetype count. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local before = archetypes:count()
  archetypes:register("turtle", { defensiveness = 0.9, caution = 0.8 })
  local after = archetypes:count()
  lurek.log.info(tostring("LTraitArchetypes:count: before=" .. tostring(before) .. " after=" .. tostring(after)))
end
```

---

#### `LTraitArchetypes:createProfile`

Creates a trait profile from a registered archetype and optional deterministic variance.

```lua
LTraitArchetypes:createProfile(name, variance)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Archetype name to copy. |
| `variance?` | number | Maximum deterministic trait jitter; defaults to zero. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | New trait profile, or nil when the archetype is unknown. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local profile = archetypes:createProfile("aggressive")
  local aggression = profile:get("aggression")
  local archetype_name = profile:archetype() or "none"
  lurek.log.info(tostring("LTraitArchetypes:createProfile: " .. archetype_name .. " aggression=" .. tostring(aggression)))
end
```

---

#### `LTraitArchetypes:names`

Returns registered archetype names.

```lua
LTraitArchetypes:names()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of archetype names. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local names = archetypes:names()
  local count = #names
  local first = names[1] or "none"
  lurek.log.info(tostring("LTraitArchetypes:names: count=" .. tostring(count) .. " first=" .. tostring(first)))
end
```

---

#### `LTraitArchetypes:register`

Registers or replaces one named archetype from a table of trait values.

```lua
LTraitArchetypes:register(name, traits)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Archetype name. |
| `traits` | table | Map of trait names to numeric values. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  archetypes:register("naval_raider", { aggression = 0.8, naval_focus = 1.0 })
  local profile = archetypes:createProfile("naval_raider")
  local focus = profile:get("naval_focus")
  local count = archetypes:count()
  lurek.log.info(tostring("LTraitArchetypes:register: focus=" .. tostring(focus) .. " count=" .. tostring(count)))
end
```

---

#### `LTraitArchetypes:type`

Returns the Lua-visible type name for this archetype registry handle.

```lua
LTraitArchetypes:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTraitArchetypes](#ltraitarchetypes)`. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local count = archetypes:count()
  local type_name = archetypes:type()
  local is_match = archetypes:typeOf("LTraitArchetypes")
  lurek.log.info(tostring("LTraitArchetypes:type: " .. type_name .. " match=" .. tostring(is_match)))
end
```

---

#### `LTraitArchetypes:typeOf`

Returns whether this archetype registry handle matches a supported type name.

```lua
LTraitArchetypes:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTraitArchetypes](#ltraitarchetypes)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local archetypes = lurek.ai.newTraitArchetypes()
  local count = archetypes:count()
  local is_arch = archetypes:typeOf("LTraitArchetypes")
  local is_object = archetypes:typeOf("LObject")
  lurek.log.info(tostring("LTraitArchetypes:typeOf: arch=" .. tostring(is_arch) .. " object=" .. tostring(is_object)))
end
```

---

## LTraitProfile

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTraitProfile:addModifier`

Adds a temporary or permanent modifier to a named trait.

```lua
LTraitProfile:addModifier(trait_name, delta, duration, source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `trait_name` | string | Trait name affected by the modifier. |
| `delta` | number | Value added to the trait while the modifier is active. |
| `duration?` | number | Modifier lifetime in seconds, or nil for engine-defined permanent duration. |
| `source` | string | Source label used to remove related modifiers later. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    lurek.log.info(tostring("defense with modifier = " .. tp:get("defense")))
end
```

---

#### `LTraitProfile:archetype`

Returns the best matching archetype name when the profile can classify one.

```lua
LTraitProfile:archetype()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Archetype name, or nil when no archetype matches. |

**Example**

```lua
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
  tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype() or "unknown"
    lurek.log.info(tostring("archetype = " .. arch))
end
```

---

#### `LTraitProfile:get`

Returns the current value of a named trait including active modifiers.

```lua
LTraitProfile:get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Trait name to read. |

**Returns**

| Type | Description |
|------|-------------|
| number | Effective trait value. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    lurek.log.info(tostring("effective speed = " .. effective))
end
```

---

#### `LTraitProfile:getBase`

Returns the base value of a named trait without temporary modifiers.

```lua
LTraitProfile:getBase(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Trait name to read. |

**Returns**

| Type | Description |
|------|-------------|
| number | Base trait value. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    lurek.log.info(tostring("base strength = " .. tp:getBase("strength")))
end
```

---

#### `LTraitProfile:has`

Returns whether the profile has a named trait.

```lua
LTraitProfile:has(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Trait name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the trait exists. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("wisdom", 0.6)
    lurek.log.info(tostring("has wisdom = " .. tostring(tp:has("wisdom"))))
    lurek.log.info(tostring("has charm = " .. tostring(tp:has("charm"))))
end
```

---

#### `LTraitProfile:names`

Returns this profile's trait names.

```lua
LTraitProfile:names()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of trait names. |

**Example**

```lua
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("aggression", 0.7)
  tp:set("caution", 0.2)
  local names = tp:names()
  local count = #names
  lurek.log.info(tostring("LTraitProfile:names: count=" .. tostring(count)))
end
```

---

#### `LTraitProfile:removeModifiers`

Removes all trait modifiers that match a source label.

```lua
LTraitProfile:removeModifiers(source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source` | string | Source label to remove. |

**Example**

```lua
do
  local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
  tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    lurek.log.info(tostring("luck after remove = " .. tp:get("luck")))
end
```

---

#### `LTraitProfile:scoreDecision`

Scores one decision by applying a decision bias set to this profile.

```lua
LTraitProfile:scoreDecision(biases, decision_key, base_score)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `biases` | [LDecisionBiasSet](#ldecisionbiasset) | Bias rules to apply. |
| `decision_key` | string | Action or goal key to score. |
| `base_score` | number | Base score before bias rules. |

**Returns**

| Type | Description |
|------|-------------|
| number | Biased score clamped to `[0, 1]`. |

**Example**

```lua
do
  local tp = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  tp:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.2, "add")
  local score = tp:scoreDecision(bias, "attack", 0.5)
  lurek.log.info(tostring("LTraitProfile:scoreDecision: " .. tostring(score)))
end
```

---

#### `LTraitProfile:set`

Sets the base value for a named trait.

```lua
LTraitProfile:set(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Trait name to create or update. |
| `value` | number | Base trait value. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    lurek.log.info(tostring("courage = " .. tp:get("courage")))
end
```

---

#### `LTraitProfile:traitCount`

Returns the number of traits stored in the profile.

```lua
LTraitProfile:traitCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current trait count. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    lurek.log.info(tostring("trait count = " .. tp:traitCount()))
end
```

---

#### `LTraitProfile:type`

Returns the Lua-visible type name for this trait profile handle.

```lua
LTraitProfile:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTraitProfile](#ltraitprofile)`. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    lurek.log.info(tostring("type = " .. tp:type()))
  lurek.log.info(tostring("matches = " .. tostring(tp:typeOf("LTraitProfile"))))
end
```

---

#### `LTraitProfile:typeOf`

Returns whether this trait profile handle matches a supported type name.

```lua
LTraitProfile:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTraitProfile](#ltraitprofile)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    local type_name = tp:type()
    lurek.log.info(tostring("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile"))))
end
```

---

#### `LTraitProfile:update`

Advances modifier timers and removes expired modifiers.

```lua
LTraitProfile:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds. |

**Example**

```lua
do
    local tp = lurek.ai.newTraitProfile()
  tp:set("morale", 0.5)
  local morale = tp:get("morale")
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    lurek.log.info(tostring("rage after 3s = " .. tp:get("rage")))
end
```

---

## LUtilityAI

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LUtilityAI:addAction`

Adds an action scored by a Lua callback and optional momentum weight.

```lua
LUtilityAI:addAction(name, scorer_fn, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Action name returned when this action wins evaluation. |
| `scorer_fn` | function | Function called by evaluation to score this action. |
| `weight?` | number | Momentum bonus or base weighting value; defaults to 1.0. |

**Example**

```lua
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    lurek.log.info(tostring("actions added = " .. uai:getActionCount()))
end
```

---

#### `LUtilityAI:addConsideration`

Adds a consideration scorer and response curve to an existing utility action.

```lua
LUtilityAI:addConsideration(action_name, name, scorer_fn, curve_arg, p1, p2, p3, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action_name` | string | Name of the action that receives the consideration. |
| `name` | string | Consideration name used for debugging and documentation. |
| `scorer_fn` | function | Function that returns the raw consideration score. |
| `curve_arg` | LuaValue | Curve name string, custom curve function, or another value to use the linear fallback. |
| `p1?` | number | First curve parameter; defaults to 1.0. |
| `p2?` | number | Second curve parameter; defaults to 0.0. |
| `p3?` | number | Third curve parameter; defaults to 0.0. |
| `weight?` | number | Consideration weight; defaults to 1.0. |

**Example**

```lua
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    lurek.log.info(tostring("consideration added, last = " .. tostring(uai:getLastAction())))
end
```

---

#### `LUtilityAI:evaluate`

Evaluates all actions and returns the winning action name when one is available.

```lua
LUtilityAI:evaluate()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Winning action name, or nil when no action can be selected. |

**Example**

```lua
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    lurek.log.info(tostring("chosen action = " .. tostring(chosen)))
end
```

---

#### `LUtilityAI:evaluateWithProfile`

Evaluates all actions after applying trait-profile decision bias rules to each action score.

```lua
LUtilityAI:evaluateWithProfile(profile, biases)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | [LTraitProfile](#ltraitprofile) | Trait profile that supplies personality values. |
| `biases` | [LDecisionBiasSet](#ldecisionbiasset) | Bias rules keyed by action name. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Winning action name, or nil when no action can be selected. |

**Example**

```lua
do
  local uai = lurek.ai.newUtilityAI()
  local profile = lurek.ai.newTraitProfile()
  local bias = lurek.ai.newDecisionBiasSet()
  uai:addAction("attack", function() return 0.4 end)
  uai:addAction("defend", function() return 0.5 end)
  profile:set("aggression", 0.8)
  bias:addRule("aggression", "attack", 0.3, "add")
  lurek.log.info(tostring("LUtilityAI:evaluateWithProfile: chosen=" .. tostring(uai:evaluateWithProfile(profile, bias))))
end
```

---

#### `LUtilityAI:getActionCount`

Returns the number of actions registered in this utility AI.

```lua
LUtilityAI:getActionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current action count. |

**Example**

```lua
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    lurek.log.info(tostring("action count = " .. uai:getActionCount()))
end
```

---

#### `LUtilityAI:getLastAction`

Returns the last winning action name when evaluation has selected one.

```lua
LUtilityAI:getLastAction()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Last action name, or nil before an action has won. |

**Example**

```lua
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
  uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    lurek.log.info(tostring("last action = " .. tostring(last)))
end
```

---

#### `LUtilityAI:getLastTrace`

Returns the last structured utility evaluation trace.

```lua
LUtilityAI:getLastTrace()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Table containing `chosen_action`, `callbacks_used`, `actions`, and `callback_errors`. |

**Example**

```lua
do
  local uai = lurek.ai.newUtilityAI()
  uai:addAction("heal", function() return 0.8 end)
  uai:addConsideration("heal", "low_health", function() return 1.0 end, "linear", 1.0, 0.0, 0.0, 1.0)
  uai:evaluate()
  local trace = uai:getLastTrace()
  lurek.log.info(tostring("LUtilityAI:getLastTrace: chosen=" .. tostring(trace.chosen_action)))
end
```

---

#### `LUtilityAI:type`

Returns the Lua-visible type name for this utility AI handle.

```lua
LUtilityAI:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LUtilityAI](#lutilityai)`. |

**Example**

```lua
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    lurek.log.info(tostring("type = " .. uai:type()))
  lurek.log.info(tostring("matches = " .. tostring(uai:typeOf("LUtilityAI"))))
end
```

---

#### `LUtilityAI:typeOf`

Returns whether this utility AI handle matches a supported type name.

```lua
LUtilityAI:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `UtilityAI` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local uai = lurek.ai.newUtilityAI()
  uai:addAction("idle", function() return 0.1 end)
  local chosen_preview = uai:evaluate()
    local type_name = uai:type()
    lurek.log.info(tostring("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI"))))
end
```

---
