# Ai

## Summary

The `ai` module is the behavior center for non-player actors. It gives one place to create agents, update them, and keep their decisions coherent over time. Functionally, it turns many AI techniques into one usable runtime surface, so game code can focus on design goals instead of wiring each method from scratch.

At the strategic level, the module supports several decision styles. You can use explicit state flow, tree-based control, utility scoring, and planner-driven reasoning, then choose the style that fits each actor. This flexibility helps teams build simple enemies quickly, while still supporting complex behavior for advanced encounters.

For moment-to-moment reactions, the module includes perception and motion layers that work together. Agents can sense events, interpret nearby context, and choose safe or expressive movement. Steering, context steering, and local avoidance make behavior look responsive in crowded scenes instead of rigid or delayed.

The module also supports coordination beyond one actor. Squad tools let units move and act as a group, while director logic controls pacing and pressure across longer play windows. In practice, this means encounters can feel structured, with clear peaks and recovery, instead of random intensity spikes.

Internal state is treated as first-class data. Needs, emotions, traits, and memory-like context help agents keep continuity across ticks. This allows behavior to change for understandable reasons, so actions feel connected to prior events rather than purely scripted triggers.

Adaptive systems expand what can be tuned over time. Bandit strategies, reinforcement learning, and neuroevolution tools allow experimentation with agents that improve or shift choices from feedback. The module keeps these capabilities near the rest of the AI stack, so learning features can be added without splitting architecture.

Control flow between subsystems is practical and script-friendly. Blackboard-style shared facts and command queues help pass intent and results between planning and execution. This reduces glue code and lowers the chance of fragile state handoffs in larger projects.

Overall, the module provides a scalable AI foundation for both gameplay and tooling. From single actors to large populations, it keeps decision, movement, coordination, and adaptation under one consistent API, making behavior systems easier to build, test, and maintain.

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
  dir:pushEvent(0.6)
  dir:update(1.0)
  print("lurek.ai.newAIDirector: ok=" .. tostring(dir ~= nil))
  print("lurek.ai.newAIDirector: phase=" .. dir:phase())
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
  print("lurek.ai.newAILod: ok=" .. tostring(lod ~= nil))
  print("lurek.ai.newAILod: tiers=" .. tostring(lod:tierCount()))
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
  act:reset()
  print("lurek.ai.newAction: type=" .. act:getNodeType())
  print("lurek.ai.newAction: child_count=" .. tostring(act:getChildCount()))
end
```

---

### `lurek.ai.newBandit`

Creates a multi-armed bandit with a named selection strategy.

```lua
lurek.ai.newBandit(arm_count, strategy, epsilon, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `arm_count` | number | Number of selectable arms. |
| `strategy` | string | Strategy name such as `ucb1`, `thompson`, or an epsilon-greedy fallback. |
| `epsilon` | number | Exploration probability used by epsilon-greedy strategy and clamped to `[0, 1]`. |
| `seed` | number | Random seed used by the bandit. |

**Returns**

| Type | Description |
|------|-------------|
| [LBandit](#lbandit) | New bandit handle. |

**Example**

```lua
do
  local bandit = lurek.ai.newBandit(3, "ucb1", 0.15, 55)
  local arm = bandit:select()
  bandit:update(arm, 0.8)
  print("lurek.ai.newBandit: ok=" .. tostring(bandit ~= nil))
  print("lurek.ai.newBandit: arms=" .. tostring(bandit:armCount()))
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
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("lurek.ai.newBehaviorTree: status=" .. tostring(bt:getLastStatus()))
  print("lurek.ai.newBehaviorTree: node_count=" .. tostring(info.node_count))
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
  bb:setString("state", "idle")
  print("lurek.ai.newBlackboard: state=" .. bb:getString("state", "none"))
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
  cq:enqueue("move", function() print("moving") end, { targetX = 32, targetY = 64 })
  print("lurek.ai.newCommandQueue: empty=" .. tostring(cq:isEmpty()))
  print("lurek.ai.newCommandQueue: count=" .. tostring(cq:getCount()))
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
  cond:reset()
  print("lurek.ai.newCondition: type=" .. cond:getNodeType())
  print("lurek.ai.newCondition: child_count=" .. tostring(cond:getChildCount()))
end
```

---

### `lurek.ai.newContextSteering`

Creates a context steering model with the requested directional slot count.

```lua
lurek.ai.newContextSteering(slots)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slots` | number | Directional slot count; zero selects the engine default of 16. |

**Returns**

| Type | Description |
|------|-------------|
| [LContextSteering](#lcontextsteering) | New context steering handle. |

**Example**

```lua
do
  local cs = lurek.ai.newContextSteering(8)
  cs:addSeekTarget(256, 128, 1.0)
  local dx, dy = cs:evaluate(0, 0, 1, 0)
  print("lurek.ai.newContextSteering: ok=" .. tostring(cs ~= nil))
  print("lurek.ai.newContextSteering: dir=" .. tostring(dx) .. "," .. tostring(dy))
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
  print("lurek.ai.newDialogueAI: ok=" .. tostring(dlg ~= nil))
  print("lurek.ai.newDialogueAI: topics=" .. tostring(dlg:getTopicCount()))
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
  print("lurek.ai.newEmotionModel: ok=" .. tostring(emo ~= nil))
  print("lurek.ai.newEmotionModel: dominant=" .. tostring(emo:dominant()))
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
  goap:addGoal("stay_alive", 5)
  goap:setGoalState("stay_alive", "alive", true)
  print("lurek.ai.newGOAPPlanner: ok=" .. tostring(goap ~= nil))
  print("lurek.ai.newGOAPPlanner: goals=" .. tostring(goap:getGoalCount()))
end
```

---

### `lurek.ai.newGeneticAlgorithm`

Creates a genetic algorithm population with fixed chromosome length.

```lua
lurek.ai.newGeneticAlgorithm(pop_size, gene_count, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pop_size` | number | Number of chromosomes in the population. |
| `gene_count` | number | Number of floating-point genes per chromosome. |
| `seed` | number | Random seed used for population initialization and evolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LGeneticAlgorithm](#lgeneticalgorithm) | New genetic algorithm handle. |

**Example**

```lua
do
  local ga = lurek.ai.newGeneticAlgorithm(8, 5, 7)
  print("lurek.ai.newGeneticAlgorithm: ok=" .. tostring(ga ~= nil))
  print("lurek.ai.newGeneticAlgorithm: pop=" .. tostring(ga:popSize()))
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
  print("lurek.ai.newGuard: node=" .. guard:getNodeType())
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
  print("lurek.ai.newHTNDomain: ok=" .. tostring(htn ~= nil))
  print("lurek.ai.newHTNDomain: tasks=" .. tostring(htn:taskCount()))
end
```

---

### `lurek.ai.newInfluenceMap`

Creates a grid influence map with the supplied cell dimensions and world cell size.

```lua
lurek.ai.newInfluenceMap(w, h, cs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Map width in cells. |
| `h` | number | Map height in cells. |
| `cs` | number | World size of one cell. |

**Returns**

| Type | Description |
|------|-------------|
| [LInfluenceMap](#linfluencemap) | New influence map handle. |

**Example**

```lua
do
  local imap = lurek.ai.newInfluenceMap(32, 32, 16)
  imap:addLayer("danger")
  imap:setInfluence("danger", 4, 5, 0.9)
  print("lurek.ai.newInfluenceMap: ok=" .. tostring(imap ~= nil))
  print("lurek.ai.newInfluenceMap: width=" .. tostring(imap:getWidth()))
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
  inv:setChild(lurek.ai.newCondition(function() return false end))
  print("lurek.ai.newInverter: type=" .. inv:getNodeType())
  print("lurek.ai.newInverter: child_count=" .. tostring(inv:getChildCount()))
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
  local get_actions = function(state)
    return { 1, 2, 3 }
  end
  local apply = function(state, action) return state + action end
  local evaluate = function(state) return state % 5 end
  local best_action = mcts:search(0, get_actions, apply, evaluate)
  print("lurek.ai.newMCTSEngine: action=" .. tostring(best_action))
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
  print("lurek.ai.newNeedSystem: ok=" .. tostring(needs ~= nil))
  print("lurek.ai.newNeedSystem: urgent=" .. tostring(needs:mostUrgent()))
end
```

---

### `lurek.ai.newNeuralNet`

Creates an empty feed-forward neural network.

```lua
lurek.ai.newNeuralNet()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralNet](#lneuralnet) | New neural network handle. |

**Example**

```lua
do
  local nn = lurek.ai.newNeuralNet()
  nn:addLayer(2, 3, "relu")
  nn:addLayer(3, 1, "linear")
  print("lurek.ai.newNeuralNet: ok=" .. tostring(nn ~= nil))
  print("lurek.ai.newNeuralNet: layers=" .. tostring(nn:layerCount()))
end
```

---

### `lurek.ai.newNeuroevolution`

Creates a neuroevolution population from a layer specification table.

```lua
lurek.ai.newNeuroevolution(layer_spec, pop_size, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer_spec` | table | Array of layer tables with `inputs`, `outputs`, and optional `activation` fields. |
| `pop_size` | number | Number of chromosomes in the population. |
| `seed` | number | Random seed used for population initialization and evolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LNeuroevolution](#lneuroevolution) | New neuroevolution handle. |

**Example**

```lua
do
  local layers = {
    { inputs = 3, outputs = 6, activation = "relu" },
    { inputs = 6, outputs = 2, activation = "softmax" },
  }
  local ne = lurek.ai.newNeuroevolution(layers, 8, 1)
  print("lurek.ai.newNeuroevolution: ok=" .. tostring(ne ~= nil))
  print("lurek.ai.newNeuroevolution: pop=" .. tostring(ne:popSize()))
end
```

---

### `lurek.ai.newORCASolver`

Creates an ORCA avoidance solver with the supplied prediction horizon.

```lua
lurek.ai.newORCASolver(time_horizon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `time_horizon` | number | Time horizon used when computing collision avoidance velocities. |

**Returns**

| Type | Description |
|------|-------------|
| [LORCASolver](#lorcasolver) | New ORCA solver handle. |

**Example**

```lua
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  print("lurek.ai.newORCASolver: ok=" .. tostring(orca ~= nil))
  print("lurek.ai.newORCASolver: agents=" .. tostring(orca:agentCount()))
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
  par:addChild(lurek.ai.newAction(function() return "running" end))
  par:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newParallel: type=" .. par:getNodeType())
  print("lurek.ai.newParallel: children=" .. tostring(par:getChildCount()))
end
```

---

### `lurek.ai.newQLearner`

Creates a Q-learner with fixed state and action counts.

```lua
lurek.ai.newQLearner(sc, ac)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sc` | number | Number of discrete states. |
| `ac` | number | Number of discrete actions. |

**Returns**

| Type | Description |
|------|-------------|
| [LQLearner](#lqlearner) | New Q-learner handle. |

**Example**

```lua
do
  local ql = lurek.ai.newQLearner(10, 4)
  ql:setQValue(1, 2, 0.75)
  print("lurek.ai.newQLearner: ok=" .. tostring(ql ~= nil))
  print("lurek.ai.newQLearner: best_action=" .. tostring(ql:bestAction(1)))
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
  rep:setChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newRepeater: count=" .. tostring(rep:getCount()))
  print("lurek.ai.newRepeater: type=" .. rep:getNodeType())
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
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newSelector: type=" .. sel:getNodeType())
  print("lurek.ai.newSelector: children=" .. tostring(sel:getChildCount()))
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
  seq:addChild(lurek.ai.newCondition(function() return true end))
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  print("lurek.ai.newSequence: type=" .. seq:getNodeType())
  print("lurek.ai.newSequence: children=" .. tostring(seq:getChildCount()))
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
  print("lurek.ai.newSquad: name=" .. squad:getName())
  print("lurek.ai.newSquad: members=" .. tostring(squad:getMemberCount()))
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
  fsm:setInitialState("idle")
  print("lurek.ai.newStateMachine: ok=" .. tostring(fsm ~= nil))
  print("lurek.ai.newStateMachine: current=" .. tostring(fsm:getCurrentState()))
end
```

---

### `lurek.ai.newSteeringManager`

Creates an empty steering manager with support for built-in and custom behaviors.

```lua
lurek.ai.newSteeringManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSteeringManager](#lsteeringmanager) | New steering manager handle. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(320, 180, 1.0)
  print("lurek.ai.newSteeringManager: ok=" .. tostring(steer ~= nil))
  print("lurek.ai.newSteeringManager: behaviors=" .. tostring(steer:getBehaviorCount()))
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
  sw:addVisual(100, 150, 1.0, 48.0, "enemy")
  print("lurek.ai.newStimulusWorld: stimuli=" .. tostring(sw:count()))
  print("lurek.ai.newStimulusWorld: type=" .. sw:type())
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
  print("lurek.ai.newStrategyAI: ok=" .. tostring(strat ~= nil))
  print("lurek.ai.newStrategyAI: next_eval=" .. tostring(strat:timeUntilNext()))
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
  suc:setChild(lurek.ai.newAction(function() return "failure" end))
  print("lurek.ai.newSucceeder: type=" .. suc:getNodeType())
  print("lurek.ai.newSucceeder: child_count=" .. tostring(suc:getChildCount()))
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
  traits:set("courage", 0.7)
  print("lurek.ai.newTraitProfile: ok=" .. tostring(traits ~= nil))
  print("lurek.ai.newTraitProfile: courage=" .. tostring(traits:get("courage")))
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
  print("lurek.ai.newUtilityAI: ok=" .. tostring(util ~= nil))
  print("lurek.ai.newUtilityAI: pick=" .. tostring(util:evaluate()))
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
  local scout = world:addAgent("scout_preview")
  local count = world:getAgentCount()
  print("lurek.ai.newWorld: agents=" .. tostring(count))
  print("lurek.ai.newWorld: first_agent=" .. scout:getName())
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

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
- [LBandit](#lbandit)
- [LBehaviorTree](#lbehaviortree)
- [LBot](#lbot)
- [LCommandQueue](#lcommandqueue)
- [LContextSteering](#lcontextsteering)
- [LDialogueAI](#ldialogueai)
- [LEmotionModel](#lemotionmodel)
- [LGOAPPlanner](#lgoapplanner)
- [LGeneticAlgorithm](#lgeneticalgorithm)
- [LHTNDomain](#lhtndomain)
- [LInfluenceMap](#linfluencemap)
- [LMCTSEngine](#lmctsengine)
- [LNeedSystem](#lneedsystem)
- [LNeuralNet](#lneuralnet)
- [LNeuroevolution](#lneuroevolution)
- [LORCASolver](#lorcasolver)
- [LQLearner](#lqlearner)
- [LSquad](#lsquad)
- [LStateMachine](#lstatemachine)
- [LSteeringManager](#lsteeringmanager)
- [LStimulusWorld](#lstimulusworld)
- [LStrategyAI](#lstrategyai)
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
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  print("LAIBlackboard:clear: size=" .. tostring(size))
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
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  print("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm))
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
  bb:setNumber("hp", 100)
  bb:setString("state", "idle")
  local keys = bb:getKeys()
  print("LAIBlackboard:getKeys: count=" .. tostring(#keys))
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
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  print("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing))
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
  bb:setNumber("hp", 10)
  bb:setString("name", "test")
  local size = bb:getSize()
  print("LAIBlackboard:getSize: " .. tostring(size))
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
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  print("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield)
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
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  print("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
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
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  print("LAIBlackboard:remove: has_temp=" .. tostring(still_has))
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
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  print("LAIBlackboard:setBool: can_attack=" .. tostring(attack))
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
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  print("LAIBlackboard:setNumber: distance=" .. tostring(dist))
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
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  print("LAIBlackboard:setString: target=" .. target)
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
  local t = bb:type()
  print("LAIBlackboard:type: " .. t)
  print("LAIBlackboard:type: matches=" .. tostring(bb:typeOf("LAIBlackboard")))
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
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LBot")
  print("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LBot=" .. tostring(is_agent))
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
    dir:setTension(0.7)
    dir:update(0.1)
    print("ambient intensity = " .. dir:ambientIntensity())
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
    dir:setTension(0.2)
    dir:update(0.1)
    print("loot factor = " .. dir:lootFactor())
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
    local p = dir:phase()
    print("initial phase = " .. p)
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
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    print("events pushed, tension = " .. dir:tension())
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
    dir:setTension(0.9)
    dir:reset()
    print("after reset, tension = " .. dir:tension())
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
    dir:setTension(0.5)
    print("tension set to " .. dir:tension())
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
    dir:setTension(0.9)
    dir:update(0.1)
    print("spawn rate factor = " .. dir:spawnRateFactor())
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
    dir:setTension(0.6)
    print("tension = " .. dir:tension())
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
    print("type = " .. dir:type())
  print("matches = " .. tostring(dir:typeOf("LAIDirector")))
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
    print("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector")))
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
    dir:pushEvent(1.0)
    dir:update(2.0)
    print("phase after update = " .. dir:phase())
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
    local run = lod:shouldUpdate(0, 1)
    print("tier 0 should update on frame 1 = " .. tostring(run))
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
    print("tier count = " .. lod:tierCount())
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
    local tier = lod:tierFor(100, 200, 0, 0)
    print("tier = " .. tier)
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
    local name = lod:tierName(0)
    print("tier 0 name = " .. name)
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
    print("type = " .. lod:type())
  print("matches = " .. tostring(lod:typeOf("LAILod")))
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
    print("is LAILod = " .. tostring(lod:typeOf("LAILod")))
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
  local archer = world:addAgent("archer_01")
  print("LAIWorld:addAgent: name=" .. archer:getName())
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
  world:addAgent("scout_01")
  local found = world:getAgent("scout_01")
  print("LAIWorld:getAgent: found=" .. tostring(found ~= nil))
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
  world:addAgent("unit_a")
  world:addAgent("unit_b")
  world:addAgent("unit_c")
  local count = world:getAgentCount()
  print("LAIWorld:getAgentCount: " .. tostring(count))
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
  local gb = world:getGlobalBlackboard()
  gb:setString("weather", "rain")
  print("LAIWorld:getGlobalBlackboard: ok=" .. tostring(gb ~= nil))
  print("LAIWorld:getGlobalBlackboard: weather=" .. gb:getString("weather", "none"))
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
  local temp = world:addAgent("temp_npc")
  world:removeAgent(temp)
  print("LAIWorld:removeAgent: removed")
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
  local t = world:type()
  local ok = world:typeOf("LAIWorld")
  print("LAIWorld:type: " .. t)
  print("LAIWorld:type: matches=" .. tostring(ok))
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
  local is_world = world:typeOf("LAIWorld")
  local is_wrong = world:typeOf("LImage")
  print("LAIWorld:typeOf: LAIWorld=" .. tostring(is_world) .. " LImage=" .. tostring(is_wrong))
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
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local ticked = false
  npc:setCustomModel(function(agent, blackboard, dt) ticked = true end)
  world:update(1 / 60)
  print("LAIWorld:update: ticked=" .. tostring(ticked))
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
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  local count = seq:getChildCount()
  print("LBTNode:addChild: children=" .. tostring(count))
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
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  local count = sel:getChildCount()
  print("LBTNode:getChildCount: " .. tostring(count))
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
  local count = rep:getCount()
  print("LBTNode:getCount: " .. tostring(count))
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
  print("LBTNode:getNodeType: " .. act:getNodeType())
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
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  print("LBTNode:reset: done")
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
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  print("LBTNode:setChild: configured")
  print("LBTNode:setChild: type=" .. inv:getNodeType())
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
  rep:setCount(10)
  local count = rep:getCount()
  print("LBTNode:setCount: " .. tostring(count))
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
  par:setFailurePolicy("requireOne")
  print("LBTNode:setFailurePolicy: done")
  print("LBTNode:setFailurePolicy: type=" .. par:getNodeType())
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
  par:setSuccessPolicy("requireOne")
  print("LBTNode:setSuccessPolicy: done")
  print("LBTNode:setSuccessPolicy: type=" .. par:getNodeType())
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
  local t = node:type()
  print("LBTNode:type: " .. t)
  print("LBTNode:type: matches=" .. tostring(node:typeOf("LBTNode")))
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
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  print("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other))
end
```

---

## LBandit

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBandit:armCount`

Returns the number of arms in this bandit.

```lua
LBandit:armCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Arm count. |

---

#### `LBandit:bestArm`

Returns the arm with the best current estimate.

```lua
LBandit:bestArm()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based best arm index. |

---

#### `LBandit:predict`

Alias for `select`. Selects an arm using the configured bandit strategy.

```lua
LBandit:predict()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based selected arm index. |

---

#### `LBandit:reset`

Resets all bandit arm statistics. This method is available to Lua scripts.

```lua
LBandit:reset()
```

---

#### `LBandit:select`

Selects an arm using the configured bandit strategy.

```lua
LBandit:select()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based selected arm index. |

---

#### `LBandit:totalPulls`

Returns the total number of arm selections recorded by this bandit.

```lua
LBandit:totalPulls()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total pull count. |

---

#### `LBandit:type`

Returns the Lua-visible type name for this bandit handle.

```lua
LBandit:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBandit](#lbandit)`. |

---

#### `LBandit:typeOf`

Returns whether this bandit handle matches a supported type name.

```lua
LBandit:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LBandit](#lbandit)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

#### `LBandit:update`

Updates one arm with a received reward.

```lua
LBandit:update(idx, reward)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based arm index. |
| `reward` | number | Reward value assigned to the arm pull. |

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
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local info = bt:getDebugState()
  print("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count))
  print("LBehaviorTree:getDebugState: last_status=" .. tostring(info.last_status))
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
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  print("LBehaviorTree:getLastStatus: " .. status)
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
  local t = bt:type()
  print("LBehaviorTree:type: " .. t)
  print("LBehaviorTree:type: matches=" .. tostring(bt:typeOf("LBehaviorTree")))
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
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LBot")
  print("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LBot=" .. tostring(is_other))
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
  local npc = world:addAgent("guard")
  npc:addTag("hostile")
  local has_hostile = npc:hasTag("hostile")
  print("LBot:addTag: hostile=" .. tostring(has_hostile))
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
  local npc = world:addAgent("ranger")
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  local hp = bb:getNumber("hp", 0)
  print("LBot:getBlackboard: hp=" .. tostring(hp))
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
  local npc = world:addAgent("farmer")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LBot:getDecisionModel: " .. model)
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
  local npc = world:addAgent("scout")
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  print("LBot:getMaxForce: " .. tostring(force))
  print("LBot:getMaxForce: name=" .. npc:getName())
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
  local npc = world:addAgent("courier")
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  print("LBot:getMaxSpeed: " .. tostring(speed))
  print("LBot:getMaxSpeed: name=" .. npc:getName())
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
  local npc = world:addAgent("knight_03")
  local name = npc:getName()
  print("LBot:getName: " .. name)
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
  local npc = world:addAgent("static_guard")
  npc:setPosition(400, 300)
  local x, y = npc:getPosition()
  print("LBot:getPosition: " .. tostring(x) .. ", " .. tostring(y))
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
  local npc = world:addAgent("grunt")
  npc:setPriority(5)
  local prio = npc:getPriority()
  print("LBot:getPriority: " .. tostring(prio))
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
  local npc = world:addAgent("idle_npc")
  npc:setVelocity(0, 0)
  local vx, vy = npc:getVelocity()
  print("LBot:getVelocity: vx=" .. tostring(vx) .. " vy=" .. tostring(vy))
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
  local npc = world:addAgent("merchant")
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  print("LBot:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile))
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
  local npc = world:addAgent("spy")
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  print("LBot:removeTag: visible=" .. tostring(still_has))
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
  local npc = world:addAgent("thinker")
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt) called_with_dt = dt end)
  world:update(0.016)
  print("LBot:setCustomModel: dt=" .. tostring(called_with_dt))
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
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  print("LBot:setDecisionModel: " .. model)
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
  local npc = world:addAgent("tank")
  npc:setMaxForce(80)
  print("LBot:setMaxForce: done")
  print("LBot:setMaxForce: force=" .. tostring(npc:getMaxForce()))
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
  local npc = world:addAgent("sprinter")
  npc:setMaxSpeed(200)
  print("LBot:setMaxSpeed: done")
  print("LBot:setMaxSpeed: speed=" .. tostring(npc:getMaxSpeed()))
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
  local npc = world:addAgent("mover")
  npc:setPosition(256, 128)
  local x, y = npc:getPosition()
  print("LBot:setPosition: done")
  print("LBot:setPosition: pos=" .. tostring(x) .. ", " .. tostring(y))
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
  local npc = world:addAgent("captain")
  npc:setPriority(10)
  print("LBot:setPriority: " .. tostring(npc:getPriority()))
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
  local npc = world:addAgent("runner")
  npc:setVelocity(60, -30)
  local vx, vy = npc:getVelocity()
  print("LBot:setVelocity: done")
  print("LBot:setVelocity: vel=" .. tostring(vx) .. ", " .. tostring(vy))
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
  local npc = world:addAgent("villager")
  local t = npc:type()
  print("LBot:type: " .. t)
  print("LBot:type: matches=" .. tostring(npc:typeOf("LBot")))
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
  local npc = world:addAgent("knight")
  local is_agent = npc:typeOf("LBot")
  local is_image = npc:typeOf("LImage")
  print("LBot:typeOf: LBot=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image))
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
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    print("after cancel, type = " .. tostring(cq:getCurrentType()))
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
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    print("after clear, empty = " .. tostring(cq:isEmpty()))
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
    cq:enqueue("move", function() print("  moving") end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() print("  attacking") end)
    print("queue size = " .. cq:getCount())
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
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    print("count = " .. cq:getCount())
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
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    print("target = " .. tostring(tgt))
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
    cq:enqueue("harvest", function() end)
    print("current type = " .. tostring(cq:getCurrentType()))
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
    print("empty initially = " .. tostring(cq:isEmpty()))
    cq:enqueue("step", function() end)
    print("empty after enqueue = " .. tostring(cq:isEmpty()))
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
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() print("  dodging") end)
    print("next type = " .. cq:getCurrentType())
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
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() print("  retreating") end)
    print("after replace count = " .. cq:getCount())
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
    print("type = " .. cq:type())
  print("matches = " .. tostring(cq:typeOf("LCommandQueue")))
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
    print("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue")))
end
```

---

## LContextSteering

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LContextSteering:addAvoidBounds`

Adds rectangular bounds avoidance to context steering.

```lua
LContextSteering:addAvoidBounds(min_x, min_y, max_x, max_y, margin, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min_x` | number | Minimum X bound. |
| `min_y` | number | Minimum Y bound. |
| `max_x` | number | Maximum X bound. |
| `max_y` | number | Maximum Y bound. |
| `margin` | number | Distance from bounds where avoidance begins. |
| `weight` | number | Avoidance behavior weight. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    print("avoid bounds set for 800x600 area")
end
```

---

#### `LContextSteering:addAvoidPoint`

Adds a point avoidance influence to context steering.

```lua
LContextSteering:addAvoidPoint(x, y, radius, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Avoidance point X position. |
| `y` | number | Avoidance point Y position. |
| `radius` | number | Avoidance radius in world units. |
| `weight` | number | Avoidance behavior weight. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    print("avoid point at (50, 50) radius 20")
end
```

---

#### `LContextSteering:addSeekTarget`

Adds a context steering target attraction.

```lua
LContextSteering:addSeekTarget(tx, ty, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Target X position in world units. |
| `ty` | number | Target Y position in world units. |
| `weight` | number | Attraction weight. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 150, 1.0)
    print("seek target added at (200, 150)")
end
```

---

#### `LContextSteering:addWander`

Adds wander noise to context steering.

```lua
LContextSteering:addWander(jitter, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `jitter` | number | Random steering jitter strength. |
| `weight` | number | Wander behavior weight. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addWander(0.3, 0.5)
    print("wander behavior added")
end
```

---

#### `LContextSteering:chosenMagnitude`

Returns the magnitude of the last selected context steering slot.

```lua
LContextSteering:chosenMagnitude()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Last chosen magnitude. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    print("magnitude = " .. mag)
end
```

---

#### `LContextSteering:clearBehaviors`

Removes all context steering behaviors.

```lua
LContextSteering:clearBehaviors()
```

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    print("behaviors cleared")
end
```

---

#### `LContextSteering:evaluate`

Evaluates context steering and returns the selected movement direction.

```lua
LContextSteering:evaluate(ax, ay, vx, vy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ax` | number | Agent X position. |
| `ay` | number | Agent Y position. |
| `vx` | number | Agent X velocity. |
| `vy` | number | Agent Y velocity. |

**Returns**

| Type | Description |
|------|-------------|
| number | Selected X and Y direction. (value 1). |
| number | Selected X and Y direction. (value 2). |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    print("direction = " .. dx .. ", " .. dy)
end
```

---

#### `LContextSteering:slotCount`

Returns the number of directional slots used by this context steering model.

```lua
LContextSteering:slotCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Direction slot count. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(16)
    print("slots = " .. cs:slotCount())
end
```

---

#### `LContextSteering:type`

Returns the Lua-visible type name for this context steering handle.

```lua
LContextSteering:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LContextSteering](#lcontextsteering)`. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    print("type = " .. cs:type())
  print("matches = " .. tostring(cs:typeOf("LContextSteering")))
end
```

---

#### `LContextSteering:typeOf`

Returns whether this context steering handle matches a supported type name.

```lua
LContextSteering:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LContextSteering](#lcontextsteering)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cs = lurek.ai.newContextSteering(8)
    print("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
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
    print("emotions registered")
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
    print("dominant = " .. tostring(em:dominant()))
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
    print("sadness = " .. val)
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
    print("surprise active = " .. tostring(em:isActive("surprise")))
    em:trigger("surprise", 0.5)
    print("surprise active = " .. tostring(em:isActive("surprise")))
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
    print("rage after reset = " .. em:get("rage"))
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
    print("fear = " .. em:get("fear"))
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
    print("type = " .. em:type())
  print("matches = " .. tostring(em:typeOf("LEmotionModel")))
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
    print("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel")))
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
    print("excitement after 3s = " .. em:get("excitement"))
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
    goap:addAction("chop_wood", 2, function() print("  chopping wood") end)
    goap:addAction("build_house", 5, function() print("  building house") end)
    print("goap actions = " .. goap:getActionCount())
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
    goap:addGoal("survive", 10)
    goap:addGoal("explore", 3)
    print("goals = " .. goap:getGoalCount())
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
    goap:addAction("a1", 1, function() end)
    goap:addAction("a2", 2, function() end)
    print("action count = " .. goap:getActionCount())
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
    goap:addGoal("g1", 1)
    goap:addGoal("g2", 5)
    goap:addGoal("g3", 3)
    print("goal count = " .. goap:getGoalCount())
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
    local max = goap:getMaxIterations()
    print("default max iterations = " .. max)
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
  goap:addAction("get_wood", 1, function() end)
  goap:setEffect("get_wood", "has_wood", true)
  goap:addAction("build", 2, function() end)
  goap:setPrecondition("build", "has_wood", true)
  goap:setEffect("build", "house_done", true)
  goap:addGoal("build_house", 10)
  goap:setGoalState("build_house", "house_done", true)
  local plan = goap:plan({ has_wood = false, house_done = false }, 10)
  print("plan steps = " .. #plan)
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
    goap:addAction("mine_ore", 3, function() end)
    goap:setEffect("mine_ore", "has_ore", true)
    print("effect set for mine_ore")
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
    goap:addGoal("build_shelter", 5)
    goap:setGoalState("build_shelter", "shelter_built", true)
    print("goal state set for build_shelter")
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
    goap:setMaxIterations(500)
    print("max iterations = " .. goap:getMaxIterations())
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
    goap:addAction("cook", 1, function() end)
    goap:setPrecondition("cook", "has_food", true)
    print("precondition set for cook")
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
    print("type = " .. goap:type())
  print("matches = " .. tostring(goap:typeOf("LGOAPPlanner")))
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
    print("is LGOAPPlanner = " .. tostring(goap:typeOf("LGOAPPlanner")))
end
```

---

## LGeneticAlgorithm

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGeneticAlgorithm:bestGenes`

Returns the genes for the best chromosome in the population.

```lua
LGeneticAlgorithm:bestGenes()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of best gene values, or an empty array when the population has no best chromosome. |

---

#### `LGeneticAlgorithm:evolve`

Advances the genetic algorithm by one generation.

```lua
LGeneticAlgorithm:evolve()
```

---

#### `LGeneticAlgorithm:generation`

Returns the current generation index.

```lua
LGeneticAlgorithm:generation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current generation count. |

---

#### `LGeneticAlgorithm:getGenes`

Returns the genes for a chromosome by zero-based index.

```lua
LGeneticAlgorithm:getGenes(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Gene values, or an empty table for an invalid index. |

---

#### `LGeneticAlgorithm:popSize`

Returns the population size. This method is available to Lua scripts.

```lua
LGeneticAlgorithm:popSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current population size. |

---

#### `LGeneticAlgorithm:setFitness`

Sets the fitness value for a chromosome by zero-based index.

```lua
LGeneticAlgorithm:setFitness(idx, fitness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |
| `fitness` | number | Fitness value used by the next evolution step. |

---

#### `LGeneticAlgorithm:type`

Returns the Lua-visible type name for this genetic algorithm handle.

```lua
LGeneticAlgorithm:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGeneticAlgorithm](#lgeneticalgorithm)`. |

---

#### `LGeneticAlgorithm:typeOf`

Returns whether this genetic algorithm handle matches a supported type name.

```lua
LGeneticAlgorithm:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGeneticAlgorithm](#lgeneticalgorithm)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

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
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
  htn:addCompound("get_metal", { { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } } })
  print("compound added, tasks = " .. htn:taskCount())
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
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    print("primitives = " .. htn:taskCount())
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
    htn:addPrimitive("gather", {}, { "has_food" }, {})
    htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
  htn:addCompound("prepare_meal", { { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } } })
  local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
  if plan then
    print("plan size = " .. #plan)
    print("plan = " .. table.concat(plan, " -> "))
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
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    print("task count = " .. htn:taskCount())
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
    print("type = " .. htn:type())
  print("matches = " .. tostring(htn:typeOf("LHTNDomain")))
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
    print("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain")))
end
```

---

## LInfluenceMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LInfluenceMap:addLayer`

Adds an influence layer with the given name if it does not already exist.

```lua
LInfluenceMap:addLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name used by later influence operations. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(16, 16, 1.0)
    im:addLayer("threat")
    im:addLayer("resources")
    print("layers added: threat, resources")
end
```

---

#### `LInfluenceMap:blend`

Blends two source layers into a destination layer using independent weights.

```lua
LInfluenceMap:blend(layer_a, weight_a, layer_b, weight_b, dest)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer_a` | string | First source layer name. |
| `weight_a` | number | Weight applied to the first source layer. |
| `layer_b` | string | Second source layer name. |
| `weight_b` | number | Weight applied to the second source layer. |
| `dest` | string | Destination layer name that receives the blended values. |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("threat")
  im:addLayer("reward")
  im:addLayer("combined")
  im:setInfluence("threat", 4, 4, 1.0)
  im:setInfluence("reward", 4, 4, 0.8)
  im:blend("threat", 0.5, "reward", 0.5, "combined")
  local val = im:getInfluence("combined", 4, 4)
    print("blended (4,4) = " .. val)
end
```

---

#### `LInfluenceMap:clearAll`

Clears every influence value in every layer.

```lua
LInfluenceMap:clearAll()
```

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("a")
  im:addLayer("b")
  im:setInfluence("a", 1, 1, 1.0)
    im:setInfluence("b", 2, 2, 0.5)
    im:clearAll()
    print("all cleared, a(1,1) = " .. im:getInfluence("a", 1, 1))
end
```

---

#### `LInfluenceMap:clearLayer`

Clears every value in a named influence layer.

```lua
LInfluenceMap:clearLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to clear. |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("marks")
    im:setInfluence("marks", 2, 2, 1.0)
    im:clearLayer("marks")
    local val = im:getInfluence("marks", 2, 2)
    print("after clear = " .. val)
end
```

---

#### `LInfluenceMap:decay`

Multiplies a named layer by a decay factor.

```lua
LInfluenceMap:decay(layer, factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to decay. |
| `factor` | number | Decay factor applied to every cell. |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(8, 8, 1.0)
  im:addLayer("heat")
    im:setInfluence("heat", 4, 4, 1.0)
    im:decay("heat", 0.5)
    local val = im:getInfluence("heat", 4, 4)
    print("heat after decay = " .. val)
end
```

---

#### `LInfluenceMap:getCellSize`

Returns the world size represented by each influence map cell.

```lua
LInfluenceMap:getCellSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell size in world units. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.5)
    print("cell size = " .. im:getCellSize())
end
```

---

#### `LInfluenceMap:getHeight`

Returns the influence map height in cells.

```lua
LInfluenceMap:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell height of the map. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("height = " .. im:getHeight())
end
```

---

#### `LInfluenceMap:getInfluence`

Returns one cell value from a named influence layer using one-based cell coordinates.

```lua
LInfluenceMap:getInfluence(layer, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to read. |
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Influence value at the requested cell. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("food")
    im:setInfluence("food", 4, 4, 0.75)
    local val = im:getInfluence("food", 4, 4)
    print("food at (4,4) = " .. val)
end
```

---

#### `LInfluenceMap:getMaxPosition`

Returns the cell position with the highest value on a named layer.

```lua
LInfluenceMap:getMaxPosition(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to scan. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based X and Y cell coordinates of the maximum value. (value 1). |
| number | One-based X and Y cell coordinates of the maximum value. (value 2). |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("gold")
    im:setInfluence("gold", 7, 3, 0.9)
    im:setInfluence("gold", 2, 8, 0.4)
    local mx, my = im:getMaxPosition("gold")
    print("max gold at (" .. mx .. ", " .. my .. ")")
end
```

---

#### `LInfluenceMap:getMinPosition`

Returns the cell position with the lowest value on a named layer.

```lua
LInfluenceMap:getMinPosition(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to scan. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based X and Y cell coordinates of the minimum value. (value 1). |
| number | One-based X and Y cell coordinates of the minimum value. (value 2). |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("cold")
    im:setInfluence("cold", 1, 1, -0.5)
    im:setInfluence("cold", 5, 5, 0.3)
    local mx, my = im:getMinPosition("cold")
    print("min cold at (" .. mx .. ", " .. my .. ")")
end
```

---

#### `LInfluenceMap:getWidth`

Returns the influence map width in cells.

```lua
LInfluenceMap:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell width of the map. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(16, 12, 2.0)
    print("width = " .. im:getWidth())
end
```

---

#### `LInfluenceMap:hasLayer`

Returns whether an influence layer exists.

```lua
LInfluenceMap:hasLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(8, 8, 2.0)
    im:addLayer("heat")
    print("has heat = " .. tostring(im:hasLayer("heat")))
    print("has cold = " .. tostring(im:hasLayer("cold")))
end
```

---

#### `LInfluenceMap:propagate`

Propagates influence values across neighboring cells on a named layer.

```lua
LInfluenceMap:propagate(layer, momentum)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to propagate. |
| `momentum?` | number | Propagation momentum factor; defaults to 0.5. |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("scent")
    im:setInfluence("scent", 5, 5, 1.0)
    im:propagate("scent", 0.8)
    local neighbor = im:getInfluence("scent", 4, 5)
    print("scent propagated to (4,5) = " .. neighbor)
end
```

---

#### `LInfluenceMap:queryRect`

Returns influence values inside a world-space rectangle on a named layer.

```lua
LInfluenceMap:queryRect(layer, wx, wy, ww, wh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to query. |
| `wx` | number | Rectangle X coordinate in world units. |
| `wy` | number | Rectangle Y coordinate in world units. |
| `ww` | number | Rectangle width in world units. |
| `wh` | number | Rectangle height in world units. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of influence samples from cells inside the rectangle. |

**Example**

```lua
do
  local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
  im:addLayer("energy")
    im:setInfluence("energy", 2, 2, 0.5)
    im:setInfluence("energy", 3, 3, 0.5)
    local total = im:queryRect("energy", 1, 1, 4, 4)
    print("energy in rect = " .. total)
end
```

---

#### `LInfluenceMap:setInfluence`

Sets one cell value in a named influence layer using one-based cell coordinates.

```lua
LInfluenceMap:setInfluence(layer, x, y, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to modify. |
| `x` | number | One-based cell X coordinate. |
| `y` | number | One-based cell Y coordinate. |
| `value` | number | Influence value to store in the cell. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(10, 10, 1.0)
    im:addLayer("danger")
    im:setInfluence("danger", 5, 5, 1.0)
    im:setInfluence("danger", 3, 7, 0.5)
    print("set influence at (5,5) and (3,7)")
end
```

---

#### `LInfluenceMap:stampInfluence`

Applies a radial influence stamp to a named layer in world coordinates.

```lua
LInfluenceMap:stampInfluence(layer, wx, wy, radius, value, falloff)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name to modify. |
| `wx` | number | World X coordinate of the stamp center. |
| `wy` | number | World Y coordinate of the stamp center. |
| `radius` | number | Stamp radius in world units. |
| `value` | number | Influence value applied at the center. |
| `falloff?` | number | Falloff exponent or multiplier; defaults to 1.0. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(20, 20, 1.0)
    im:addLayer("noise")
    im:stampInfluence("noise", 10.0, 10.0, 3.0, 1.0, 0.5)
    local center = im:getInfluence("noise", 10, 10)
    print("noise center = " .. center)
end
```

---

#### `LInfluenceMap:type`

Returns the Lua-visible type name for this influence map handle.

```lua
LInfluenceMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LInfluenceMap](#linfluencemap)`. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("type = " .. im:type())
  print("matches = " .. tostring(im:typeOf("LInfluenceMap")))
end
```

---

#### `LInfluenceMap:typeOf`

Returns whether this influence map handle matches a supported type name.

```lua
LInfluenceMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `InfluenceMap` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local im = lurek.ai.newInfluenceMap(4, 4, 1.0)
    print("is LInfluenceMap = " .. tostring(im:typeOf("LInfluenceMap")))
end
```

---

## LMCTSEngine

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
  print("best action = " .. tostring(action))
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
    print("type = " .. mcts:type())
  print("matches = " .. tostring(mcts:typeOf("LMCTSEngine")))
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
    print("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine")))
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
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    print("needs registered")
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
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    print("most urgent = " .. tostring(name))
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
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    print("thirst satisfied")
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
    print("type = " .. ns:type())
  print("matches = " .. tostring(ns:typeOf("LNeedSystem")))
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
    print("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem")))
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
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    print("most urgent after 2s = " .. tostring(urgent))
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
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    print("hunger value = " .. val)
end
```

---

## LNeuralNet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNeuralNet:addLayer`

Adds a neural network layer with an activation function.

```lua
LNeuralNet:addLayer(inputs, outputs, activation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `inputs` | number | Input count for the layer. |
| `outputs` | number | Output count for the layer. |
| `activation` | string | Activation name such as `relu`, `sigmoid`, `tanh`, `linear`, or `softmax`. |

---

#### `LNeuralNet:forward`

Runs a forward pass and returns output values.

```lua
LNeuralNet:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | table | Array of numeric input values. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric output values. |

---

#### `LNeuralNet:getWeights`

Returns the network weights as a flat numeric array.

```lua
LNeuralNet:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric weights in engine layer order. |

---

#### `LNeuralNet:layerCount`

Returns the number of layers in the network.

```lua
LNeuralNet:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

---

#### `LNeuralNet:paramCount`

Returns the total number of trainable parameters.

```lua
LNeuralNet:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Parameter count. |

---

#### `LNeuralNet:predict`

Alias for `forward`. Runs a forward pass and returns output values.

```lua
LNeuralNet:predict(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | table | Array of numeric input values. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric output values. |

---

#### `LNeuralNet:setWeights`

Replaces the network weights from a flat numeric array.

```lua
LNeuralNet:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat array of numeric weights in engine layer order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied weight slice matches the network shape. |

---

#### `LNeuralNet:type`

Returns the Lua-visible type name for this neural network handle.

```lua
LNeuralNet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNeuralNet](#lneuralnet)`. |

---

#### `LNeuralNet:typeOf`

Returns whether this neural network handle matches a supported type name.

```lua
LNeuralNet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNeuralNet](#lneuralnet)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

## LNeuroevolution

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNeuroevolution:bestFitness`

Returns the best fitness value in the population.

```lua
LNeuroevolution:bestFitness()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Best fitness value. |

---

#### `LNeuroevolution:bestNetwork`

Converts the best chromosome into a neural network handle when one exists.

```lua
LNeuroevolution:bestNetwork()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralNet](#lneuralnet) | Neural network handle. |

---

#### `LNeuroevolution:chromosomeToNet`

Converts one chromosome into a neural network handle when the index is valid.

```lua
LNeuroevolution:chromosomeToNet(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralNet](#lneuralnet) | Neural network handle. |

---

#### `LNeuroevolution:evolve`

Advances the neuroevolution population by one generation.

```lua
LNeuroevolution:evolve()
```

---

#### `LNeuroevolution:generation`

Returns the current generation index.

```lua
LNeuroevolution:generation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current generation count. |

---

#### `LNeuroevolution:popSize`

Returns the population size. This method is available to Lua scripts.

```lua
LNeuroevolution:popSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current population size. |

---

#### `LNeuroevolution:setFitness`

Sets the fitness value for a chromosome by zero-based index.

```lua
LNeuroevolution:setFitness(idx, fitness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |
| `fitness` | number | Fitness value used by the next evolution step. |

---

#### `LNeuroevolution:type`

Returns the Lua-visible type name for this neuroevolution handle.

```lua
LNeuroevolution:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNeuroevolution](#lneuroevolution)`. |

---

#### `LNeuroevolution:typeOf`

Returns whether this neuroevolution handle matches a supported type name.

```lua
LNeuroevolution:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNeuroevolution](#lneuroevolution)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

---

## LORCASolver

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LORCASolver:addAgent`

Adds an ORCA avoidance agent and returns its zero-based solver index.

```lua
LORCASolver:addAgent(x, y, radius, max_speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Initial X position. |
| `y` | number | Initial Y position. |
| `radius` | number | Collision radius. |
| `max_speed` | number | Maximum preferred speed. |

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based ORCA agent index. |

**Example**

```lua
do
    local orca = lurek.ai.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    print("agent index = " .. idx)
end
```

---

#### `LORCASolver:agentCount`

Returns the number of ORCA agents in this solver.

```lua
LORCASolver:agentCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current ORCA agent count. |

**Example**

```lua
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    print("agent count = " .. orca:agentCount())
end
```

---

#### `LORCASolver:compute`

Computes safe velocities for all ORCA agents.

```lua
LORCASolver:compute(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Elapsed time in seconds for the avoidance step. |

**Example**

```lua
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
  orca:addAgent(5, 0, 0.5, 3.0)
  orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute(0.016)
    print("collision avoidance computed")
end
```

---

#### `LORCASolver:getSafeVelocity`

Returns the computed safe velocity for an ORCA agent.

```lua
LORCASolver:getSafeVelocity(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Safe X and Y velocity; or zero velocity for an invalid index. (value 1). |
| number | Safe X and Y velocity; or zero velocity for an invalid index. (value 2). |

**Example**

```lua
do
  local orca = lurek.ai.newORCASolver(1.5)
  orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    print("safe velocity = " .. vx .. ", " .. vy)
end
```

---

#### `LORCASolver:setPosition`

Sets the position for an ORCA agent by zero-based index.

```lua
LORCASolver:setPosition(idx, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index. |
| `x` | number | New X position. |
| `y` | number | New Y position. |

**Example**

```lua
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    print("position updated for agent 0")
end
```

---

#### `LORCASolver:setPreferredVelocity`

Sets the preferred velocity for an ORCA agent by zero-based index.

```lua
LORCASolver:setPreferredVelocity(idx, pvx, pvy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based ORCA agent index. |
| `pvx` | number | Preferred X velocity. |
| `pvy` | number | Preferred Y velocity. |

**Example**

```lua
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    print("preferred velocity set for agent 0")
end
```

---

#### `LORCASolver:type`

Returns the Lua-visible type name for this ORCA solver handle.

```lua
LORCASolver:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LORCASolver](#lorcasolver)`. |

**Example**

```lua
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("type = " .. orca:type())
  print("matches = " .. tostring(orca:typeOf("LORCASolver")))
end
```

---

#### `LORCASolver:typeOf`

Returns whether this ORCA solver handle matches a supported type name.

```lua
LORCASolver:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LORCASolver](#lorcasolver)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end
```

---

## LQLearner

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQLearner:bestAction`

Returns the highest-valued action for a one-based state index without exploration.

```lua
LQLearner:bestAction(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based best action index. |

---

#### `LQLearner:chooseAction`

Chooses an action for a one-based state index using the learner's exploration policy.

```lua
LQLearner:chooseAction(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based chosen action index. |

---

#### `LQLearner:deserialize`

Replaces the Q-learner state from a JSON string.

```lua
LQLearner:deserialize(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | string | JSON data previously produced by `serialize`. |

---

#### `LQLearner:endEpisode`

Decays epsilon and increments the episode count.

```lua
LQLearner:endEpisode()
```

---

#### `LQLearner:getActionCount`

Returns the number of actions represented by this learner.

```lua
LQLearner:getActionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Action count. |

---

#### `LQLearner:getDiscountFactor`

Returns the Q-learning gamma discount factor.

```lua
LQLearner:getDiscountFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current discount factor. |

---

#### `LQLearner:getEpisodeCount`

Returns the total number of episodes completed so far.

```lua
LQLearner:getEpisodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Episode count. |

---

#### `LQLearner:getExplorationDecay`

Returns the exploration decay multiplier.

```lua
LQLearner:getExplorationDecay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current exploration decay multiplier. |

---

#### `LQLearner:getExplorationRate`

Returns the exploration rate used by action selection.

```lua
LQLearner:getExplorationRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current exploration rate. |

---

#### `LQLearner:getLearningRate`

Returns the Q-learning alpha learning rate.

```lua
LQLearner:getLearningRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current learning rate. |

---

#### `LQLearner:getQValue`

Returns the stored Q-value for a one-based state and action pair.

```lua
LQLearner:getQValue(state, action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |
| `action` | number | One-based action index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current Q-value. |

---

#### `LQLearner:getStateCount`

Returns the number of states represented by this learner.

```lua
LQLearner:getStateCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | State count. |

---

#### `LQLearner:learn`

Applies one Q-learning update from a transition and reward.

```lua
LQLearner:learn(state, action, reward, next_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based previous state index. |
| `action` | number | One-based action index taken in the previous state. |
| `reward` | number | Reward received for the transition. |
| `next_state` | number | One-based next state index. |

---

#### `LQLearner:predict`

Alias for `chooseAction`. Selects an action for the given one-based state using the learner's policy.

```lua
LQLearner:predict(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based chosen action index. |

---

#### `LQLearner:serialize`

Serializes the Q-learner state to a JSON string.

```lua
LQLearner:serialize()
```

**Returns**

| Type | Description |
|------|-------------|
| string | JSON representation of this learner. |

---

#### `LQLearner:setDiscountFactor`

Sets the Q-learning gamma discount factor.

```lua
LQLearner:setDiscountFactor(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Discount factor used by future updates. |

---

#### `LQLearner:setExplorationDecay`

Sets the exploration decay multiplier applied across episodes.

```lua
LQLearner:setExplorationDecay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Exploration decay multiplier. |

---

#### `LQLearner:setExplorationRate`

Sets the exploration rate used by action selection.

```lua
LQLearner:setExplorationRate(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Exploration probability for future `chooseAction` calls. |

---

#### `LQLearner:setLearningRate`

Sets the Q-learning alpha learning rate.

```lua
LQLearner:setLearningRate(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Learning rate used by future updates. |

---

#### `LQLearner:setQValue`

Sets the stored Q-value for a one-based state and action pair.

```lua
LQLearner:setQValue(state, action, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |
| `action` | number | One-based action index. |
| `value` | number | Q-value to store. |

---

#### `LQLearner:type`

Returns the Lua-visible type name for this Q-learner handle.

```lua
LQLearner:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LQLearner](#lqlearner)`. |

---

#### `LQLearner:typeOf`

Returns whether this Q-learner handle matches a supported type name.

```lua
LQLearner:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LQLearner](#lqlearner)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

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
    sq:addMember("soldier_1")
    sq:addMember("soldier_2")
    print("members = " .. sq:getMemberCount())
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
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    print("squad bb threat = " .. bb:getNumber("threat_level"))
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
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    print("formation = " .. f)
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
  sq:addMember("lead")
  sq:addMember("flank_l")
  sq:addMember("flank_r")
    sq:setFormation("wedge", 2.0)
    local x, y = sq:getFormationPosition(2, 100.0, 50.0)
    print("member 2 pos = " .. x .. ", " .. y)
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
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    print("spacing = " .. s)
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
    sq:addMember("commander")
    sq:setLeader("commander")
    local leader = sq:getLeader()
    print("leader = " .. tostring(leader))
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
    sq:addMember("a")
    sq:addMember("b")
    sq:addMember("c")
    print("count = " .. sq:getMemberCount())
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
    sq:addMember("sniper")
    sq:addMember("heavy")
    local members = sq:getMembers()
    print("members: " .. table.concat(members, ", "))
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
    print("squad name = " .. sq:getName())
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
    sq:addMember("scout")
    sq:addMember("medic")
    sq:removeMember("scout")
    print("after remove = " .. sq:getMemberCount())
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
  sq:addMember("point")
    sq:addMember("left")
    sq:addMember("right")
    sq:setFormation("wedge", 2.0)
    print("formation set to wedge, spacing 2.0")
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
    sq:addMember("captain")
    sq:addMember("private")
    sq:setLeader("captain")
    print("leader = " .. sq:getLeader())
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
    print("type = " .. sq:type())
  print("matches = " .. tostring(sq:typeOf("LSquad")))
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
    print("is LSquad = " .. tostring(sq:typeOf("LSquad")))
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
  local entered = ""
  fsm:addState("patrol", { onEnter = function() entered = "patrol" end })
  fsm:setInitialState("patrol")
  print("LStateMachine:addState: entered=" .. entered)
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
  fsm:addState("alert", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  print("LStateMachine:addTransition: configured")
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
  fsm:addState("alive", {})
  fsm:addState("dead", {})
  fsm:setInitialState("alive")
  fsm:forceState("dead")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:forceState: " .. current)
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
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  print("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after))
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
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  print("LStateMachine:getTimeInState: " .. tostring(time_in))
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
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  print("LStateMachine:setInitialState: " .. current .. " log=" .. log)
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
  local t = fsm:type()
  print("LStateMachine:type: " .. t)
  print("LStateMachine:type: matches=" .. tostring(fsm:typeOf("LStateMachine")))
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
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  print("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other))
end
```

---

## LSteeringManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSteeringManager:addArrive`

Adds an arrive behavior that slows the agent as it approaches a target point.

```lua
LSteeringManager:addArrive(tx, ty, slowing, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Target X position in world units. |
| `ty` | number | Target Y position in world units. |
| `slowing?` | number | Radius used to reduce speed near the target; defaults to 50.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  print("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addCustomBehavior`

Adds a custom steering behavior backed by a Lua callback.

```lua
LSteeringManager:addCustomBehavior(func, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called as `(agent, dt)` that returns an X and Y steering force. |
| `weight?` | number | Custom behavior weight applied to returned forces; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt) return 50, 0 end, 0.8)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end
```

---

#### `LSteeringManager:addEvade`

Adds an evade behavior that moves away from another named agent when a threat name is supplied.

```lua
LSteeringManager:addEvade(threat_name, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `threat_name?` | string | Optional name of the agent to evade. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addEvade("enemy_agent", 1.0)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addEvade: behaviors=" .. tostring(count))
end
```

---

#### `LSteeringManager:addFlee`

Adds a flee behavior that pushes the agent away from a target point inside a panic distance.

```lua
LSteeringManager:addFlee(tx, ty, panic_dist, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Threat X position in world units. |
| `ty` | number | Threat Y position in world units. |
| `panic_dist?` | number | Distance inside which fleeing is active; defaults to 200.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  print("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addFlock`

Adds a flocking behavior with separation, alignment, and cohesion weights.

```lua
LSteeringManager:addFlock(neighbor_radius, sep_w, align_w, coh_w, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `neighbor_radius?` | number | Radius used to find flock neighbors; defaults to 100.0. |
| `sep_w?` | number | Separation force weight; defaults to 1.5. |
| `align_w?` | number | Alignment force weight; defaults to 1.0. |
| `coh_w?` | number | Cohesion force weight; defaults to 1.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addFlock: behaviors=" .. tostring(count))
end
```

---

#### `LSteeringManager:addPursue`

Adds a pursue behavior that chases another named agent when a target name is supplied.

```lua
LSteeringManager:addPursue(target_name, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target_name?` | string | Optional name of the agent to pursue. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addPursue("target_agent", 1.0)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:addPursue: behaviors=" .. tostring(count))
end
```

---

#### `LSteeringManager:addSeek`

Adds a seek behavior that pulls the agent toward a target point.

```lua
LSteeringManager:addSeek(tx, ty, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Target X position in world units. |
| `ty` | number | Target Y position in world units. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  print("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:addWander`

Adds a wander behavior that produces jittered exploratory movement.

```lua
LSteeringManager:addWander(radius, dist, jitter, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius?` | number | Wander circle radius; defaults to 20.0. |
| `dist?` | number | Wander circle distance in front of the agent; defaults to 40.0. |
| `jitter?` | number | Random displacement applied per update; defaults to 5.0. |
| `weight?` | number | Behavior weight applied during steering combination; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  print("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:applyCustomSteering`

Runs enabled custom steering callbacks for an agent and returns the weighted combined force.

```lua
LSteeringManager:applyCustomSteering(agent, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `agent` | [LBot](#lbot) | Bot handle passed through to every custom steering callback. |
| `dt` | number | Elapsed time in seconds passed to every custom steering callback. |

**Returns**

| Type | Description |
|------|-------------|
| number | Combined custom X and Y steering force. (value 1). |
| number | Combined custom X and Y steering force. (value 2). |

**Example**

```lua
do
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("pusher")
  npc:setPosition(100, 100)
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt) return 25, -10 end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  print("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:calculate`

Calculates a steering force for the supplied agent movement state.

```lua
LSteeringManager:calculate(px, py, vx, vy, max_speed, max_force, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `px` | number | Current agent X position. |
| `py` | number | Current agent Y position. |
| `vx` | number | Current agent X velocity. |
| `vy` | number | Current agent Y velocity. |
| `max_speed` | number | Maximum allowed speed used by steering constraints. |
| `max_force` | number | Maximum allowed steering force. |
| `dt` | number | Elapsed time in seconds for this steering step. |

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y steering force. (value 1). |
| number | X and Y steering force. (value 2). |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  print("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end
```

---

#### `LSteeringManager:clearPath`

Clears the active waypoint path behavior.

```lua
LSteeringManager:clearPath()
```

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  print("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end
```

---

#### `LSteeringManager:enableSpatialHash`

Enables or disables spatial hash acceleration for neighbor queries.

```lua
LSteeringManager:enableSpatialHash(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | True to use spatial hashing, false to use direct scans. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  print("LSteeringManager:enableSpatialHash: done")
end
```

---

#### `LSteeringManager:getBehaviorCount`

Returns the number of steering behaviors configured on this manager.

```lua
LSteeringManager:getBehaviorCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current steering behavior count. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  print("LSteeringManager:getBehaviorCount: " .. tostring(count))
end
```

---

#### `LSteeringManager:getCombineMode`

Returns the current steering force combination mode.

```lua
LSteeringManager:getCombineMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Combine mode name. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  print("LSteeringManager:getCombineMode: " .. mode)
  print("LSteeringManager:getCombineMode: type=" .. steer:type())
end
```

---

#### `LSteeringManager:getLastSteering`

Returns the last steering force calculated by this manager.

```lua
LSteeringManager:getLastSteering()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X and Y force values from the previous calculation. (value 1). |
| number | X and Y force values from the previous calculation. (value 2). |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  print("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end
```

---

#### `LSteeringManager:getPathProgress`

Returns the current one-based waypoint index and total waypoint count.

```lua
LSteeringManager:getPathProgress()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current waypoint index and total waypoint count. (value 1). |
| number | Current waypoint index and total waypoint count. (value 2). |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 0, y = 0 }, { x = 100, y = 50 }, { x = 200, y = 100 } }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  print("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end
```

---

#### `LSteeringManager:hasPath`

Returns whether this manager currently has an active waypoint path.

```lua
LSteeringManager:hasPath()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a path is configured and not complete. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  print("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end
```

---

#### `LSteeringManager:setCombineMode`

Sets how steering behavior forces are combined.

```lua
LSteeringManager:setCombineMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Combine mode string parsed by the steering manager. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  print("LSteeringManager:setCombineMode: " .. mode)
end
```

---

#### `LSteeringManager:setPath`

Sets a waypoint path behavior from an array of `{x, y}` tables.

```lua
LSteeringManager:setPath(waypoints, reach_radius, weight)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `waypoints` | table | Array of waypoint tables, each containing numeric `x` and `y` fields. |
| `reach_radius?` | number | Distance at which a waypoint is considered reached; defaults to 12.0. |
| `weight?` | number | Path following behavior weight; defaults to 1.0. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  print("LSteeringManager:setPath: hasPath=" .. tostring(has))
end
```

---

#### `LSteeringManager:setSpatialHashCellSize`

Sets the cell size used by the steering manager spatial hash.

```lua
LSteeringManager:setSpatialHashCellSize(size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Spatial hash cell size in world units. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  steer:setSpatialHashCellSize(32)
  print("LSteeringManager:setSpatialHashCellSize: done")
end
```

---

#### `LSteeringManager:type`

Returns the Lua-visible type name for this steering manager handle.

```lua
LSteeringManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSteeringManager](#lsteeringmanager)`. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  local t = steer:type()
  print("LSteeringManager:type: " .. t)
  print("LSteeringManager:type: matches=" .. tostring(steer:typeOf("LSteeringManager")))
end
```

---

#### `LSteeringManager:typeOf`

Returns whether this steering manager handle matches a supported type name.

```lua
LSteeringManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `SteeringManager` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
  local steer = lurek.ai.newSteeringManager()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LBot")
  print("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LBot=" .. tostring(is_other))
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
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    print("auditory stimulus id = " .. id)
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
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    print("visual stimulus id = " .. id)
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
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    print("after clear, count = " .. sw:count())
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
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    print("stimulus count = " .. sw:count())
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
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    print("removed stimulus, count = " .. sw:count())
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
    print("type = " .. sw:type())
  print("matches = " .. tostring(sw:typeOf("LStimulusWorld")))
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
    print("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld")))
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
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    print("after update, count = " .. sw:count())
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
    local active = strat:activeGoal()
    print("active goal = " .. tostring(active))
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
    print("goals registered")
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
    print("tags added")
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
    print("forced active = " .. tostring(strat:activeGoal()))
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
    print("tag removed")
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
    print("time until next = " .. strat:timeUntilNext())
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
    print("type = " .. strat:type())
  print("matches = " .. tostring(strat:typeOf("LStrategyAI")))
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
    print("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI")))
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
    print("active = " .. tostring(strat:activeGoal()))
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
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    print("defense with modifier = " .. tp:get("defense"))
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
  tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype() or "unknown"
    print("archetype = " .. arch)
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
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    print("effective speed = " .. effective)
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
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    print("base strength = " .. tp:getBase("strength"))
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
    tp:set("wisdom", 0.6)
    print("has wisdom = " .. tostring(tp:has("wisdom")))
    print("has charm = " .. tostring(tp:has("charm")))
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
  tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    print("luck after remove = " .. tp:get("luck"))
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
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    print("courage = " .. tp:get("courage"))
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
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    print("trait count = " .. tp:traitCount())
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
    print("type = " .. tp:type())
  print("matches = " .. tostring(tp:typeOf("LTraitProfile")))
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
    print("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile")))
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
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    print("rage after 3s = " .. tp:get("rage"))
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
    uai:addAction("eat", function() return 0.8 end, 1.0)
    uai:addAction("sleep", function() return 0.3 end, 1.0)
    print("actions added = " .. uai:getActionCount())
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
    uai:addAction("heal", function() return 0.5 end)
    uai:addConsideration("heal", "low_health", function() return 0.9 end, "linear", 1.0, 0.0, 0.0, 1.0)
    uai:evaluate()
    print("consideration added, last = " .. tostring(uai:getLastAction()))
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
    uai:addAction("attack", function() return 0.9 end)
    uai:addAction("defend", function() return 0.4 end)
    local chosen = uai:evaluate()
    print("chosen action = " .. tostring(chosen))
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
    uai:addAction("patrol", function() return 0.5 end)
    uai:addAction("idle", function() return 0.1 end)
    uai:addAction("chase", function() return 0.7 end)
    print("action count = " .. uai:getActionCount())
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
  uai:addAction("gather", function() return 0.6 end)
    uai:addAction("build", function() return 0.2 end)
    uai:evaluate()
    local last = uai:getLastAction()
    print("last action = " .. tostring(last))
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
    print("type = " .. uai:type())
  print("matches = " .. tostring(uai:typeOf("LUtilityAI")))
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
    print("is LUtilityAI = " .. tostring(uai:typeOf("LUtilityAI")))
end
```

---
