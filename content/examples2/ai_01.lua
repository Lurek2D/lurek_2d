--@api-stub: LAgent:getMaxSpeed
-- Returns this agent's maximum movement speed.
do
  -- getMaxSpeed returns the value previously set with setMaxSpeed.
  -- Default max speed is 0 until explicitly set.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("courier")
  npc:setMaxSpeed(150)
  local speed = npc:getMaxSpeed()
  -- Use max speed to normalize velocity or display in UI.
  print("LAgent:getMaxSpeed: " .. tostring(speed))
end

--@api-stub: LAgent:setMaxForce
-- Sets this agent's maximum steering force when the agent still exists in its world.
do
  -- setMaxForce limits how strongly steering behaviors can push the agent.
  -- Higher force = faster turns and sharper corrections.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("tank")
  npc:setMaxForce(80)
  local force = npc:getMaxForce()
  -- Heavy units get low max force for sluggish movement; light units get high.
  print("LAgent:setMaxForce: " .. tostring(force))
end

--@api-stub: LAgent:getMaxForce
-- Returns this agent's maximum steering force.
do
  -- getMaxForce returns the value previously set with setMaxForce.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("scout")
  npc:setMaxForce(200)
  local force = npc:getMaxForce()
  -- Compare max force against current steering output for debug.
  print("LAgent:getMaxForce: " .. tostring(force))
end

--@api-stub: LAgent:setPriority
-- Sets this agent's update priority when the agent still exists in its world.
do
  -- Higher priority agents get updated first during world:update().
  -- Use priority to ensure leaders decide before followers.
  local world = lurek.ai.newWorld()
  local leader = world:addAgent("captain")
  local follower = world:addAgent("private")
  leader:setPriority(10)
  follower:setPriority(1)
  -- Leader's callback runs before follower's, so follower can read leader decisions.
  print("LAgent:setPriority: leader=" .. tostring(leader:getPriority()))
end

--@api-stub: LAgent:getPriority
-- Returns this agent's update priority.
do
  -- getPriority returns the integer set with setPriority. Default is 0.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("grunt")
  npc:setPriority(5)
  local prio = npc:getPriority()
  -- Priority determines tick order within world:update().
  print("LAgent:getPriority: " .. tostring(prio))
end

--@api-stub: LAgent:setDecisionModel
-- Sets the agent's decision model type when the agent still exists.
do
  -- Decision model determines how the agent's logic is ticked.
  -- "custom" means the engine calls a Lua function each update.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("worker")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  -- Custom is the most flexible; use it with setCustomModel.
  print("LAgent:setDecisionModel: " .. model)
end

--@api-stub: LAgent:getDecisionModel
-- Returns the agent's decision model type string.
do
  -- getDecisionModel returns "custom" or other model names.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("farmer")
  npc:setDecisionModel("custom")
  local model = npc:getDecisionModel()
  -- Use getDecisionModel to serialize agent state for save files.
  print("LAgent:getDecisionModel: " .. model)
end

--@api-stub: LAgent:setCustomModel
-- Sets the Lua callback that runs every world:update() for this agent.
do
  -- The callback receives (agent, blackboard, dt). Use it to drive all decisions.
  -- Blackboard is the agent's local fact store.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("thinker")
  npc:setDecisionModel("custom")
  local called_with_dt = 0
  npc:setCustomModel(function(agent, bb, dt)
    called_with_dt = dt
    bb:setString("state", "thinking")
  end)
  world:update(0.016)
  -- The callback fires every update while the agent uses "custom" model.
  print("LAgent:setCustomModel: dt=" .. tostring(called_with_dt))
end

--@api-stub: LAgent:addTag
-- Adds a string tag to this agent when the agent still exists.
do
  -- Tags are lightweight string labels for filtering and queries.
  -- The same tag can only be added once; duplicates are ignored.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("guard")
  npc:addTag("hostile")
  npc:addTag("armored")
  local has_hostile = npc:hasTag("hostile")
  -- Tags let you group agents without maintaining separate lists.
  print("LAgent:addTag: hostile=" .. tostring(has_hostile))
end

--@api-stub: LAgent:removeTag
-- Removes a string tag from this agent when the agent still exists.
do
  -- Removing a tag that does not exist is safe (no error).
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("spy")
  npc:addTag("visible")
  npc:removeTag("visible")
  local still_has = npc:hasTag("visible")
  -- Remove tags when state changes: enemy becomes ally, visible becomes hidden.
  print("LAgent:removeTag: visible=" .. tostring(still_has))
end

--@api-stub: LAgent:hasTag
-- Returns whether this agent currently has a specific tag.
do
  -- hasTag is O(1) and safe for per-frame checks.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("merchant")
  npc:addTag("friendly")
  local friendly = npc:hasTag("friendly")
  local hostile = npc:hasTag("hostile")
  -- Use hasTag to decide behavior branches in custom model callbacks.
  print("LAgent:hasTag: friendly=" .. tostring(friendly) .. " hostile=" .. tostring(hostile))
end

--@api-stub: LAgent:getBlackboard
-- Returns this agent's local blackboard for reading and writing facts.
do
  -- Each agent has its own blackboard separate from the global one.
  -- Use it for agent-local knowledge: current target, health, morale.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("ranger")
  local bb = npc:getBlackboard()
  bb:setNumber("hp", 100)
  bb:setString("target", "goblin_01")
  local hp = bb:getNumber("hp", 0)
  -- The custom model callback also receives this blackboard as its 2nd arg.
  print("LAgent:getBlackboard: hp=" .. tostring(hp))
end

--@api-stub: LAgent:type
-- Returns the Lua-visible type name for this agent handle.
do
  -- type() returns the string "LAgent" for agent handles.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("villager")
  local t = npc:type()
  -- Use type() for runtime type checks in generic code.
  print("LAgent:type: " .. t)
end

--@api-stub: LAgent:typeOf
-- Returns whether this agent handle matches a supported type name.
do
  -- typeOf accepts "LAgent" and "Object". Other strings return false.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("knight")
  local is_agent = npc:typeOf("LAgent")
  local is_image = npc:typeOf("LImage")
  -- typeOf is useful for polymorphic code that handles mixed userdata.
  print("LAgent:typeOf: LAgent=" .. tostring(is_agent) .. " LImage=" .. tostring(is_image))
end

--@api-stub: LAIBlackboard:setNumber
-- Stores a numeric value under a string key in this blackboard.
do
  -- setNumber overwrites any existing value at the same key.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("distance", 42.5)
  bb:setNumber("ammo", 30)
  local dist = bb:getNumber("distance", 0)
  -- Numbers are stored as f64 internally; integers and floats both work.
  print("LAIBlackboard:setNumber: distance=" .. tostring(dist))
end

--@api-stub: LAIBlackboard:getNumber
-- Returns a numeric value from this blackboard or the default if not found.
do
  -- The second argument is the default value returned when the key is absent.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("score", 95.5)
  local score = bb:getNumber("score", 0)
  local missing = bb:getNumber("nonexistent", -1)
  -- Default values prevent nil errors in decision code.
  print("LAIBlackboard:getNumber: score=" .. tostring(score) .. " missing=" .. tostring(missing))
end

--@api-stub: LAIBlackboard:setBool
-- Stores a boolean value under a string key in this blackboard.
do
  -- setBool overwrites any existing value at the same key.
  local bb = lurek.ai.newBlackboard()
  bb:setBool("can_attack", true)
  bb:setBool("is_hiding", false)
  local attack = bb:getBool("can_attack", false)
  -- Boolean facts are common for condition checks in behavior trees.
  print("LAIBlackboard:setBool: can_attack=" .. tostring(attack))
end

--@api-stub: LAIBlackboard:getBool
-- Returns a boolean value from this blackboard or the default if not found.
do
  -- The second argument is the default value returned when the key is absent.
  local bb = lurek.ai.newBlackboard()
  bb:setBool("alert", true)
  local alert = bb:getBool("alert", false)
  local calm = bb:getBool("calm", true)
  -- Use getBool in condition nodes and guard predicates.
  print("LAIBlackboard:getBool: alert=" .. tostring(alert) .. " calm=" .. tostring(calm))
end

--@api-stub: LAIBlackboard:setString
-- Stores a string value under a string key in this blackboard.
do
  -- setString overwrites any existing value at the same key.
  local bb = lurek.ai.newBlackboard()
  bb:setString("target_name", "dragon")
  bb:setString("current_zone", "forest")
  local target = bb:getString("target_name", "none")
  -- String facts hold entity references, zone names, or state labels.
  print("LAIBlackboard:setString: target=" .. target)
end

--@api-stub: LAIBlackboard:getString
-- Returns a string value from this blackboard or the default if not found.
do
  -- The second argument is the default string returned when the key is absent.
  local bb = lurek.ai.newBlackboard()
  bb:setString("weapon", "sword")
  local weapon = bb:getString("weapon", "fists")
  local shield = bb:getString("shield", "none")
  -- Default strings avoid nil concatenation errors.
  print("LAIBlackboard:getString: weapon=" .. weapon .. " shield=" .. shield)
end

--@api-stub: LAIBlackboard:has
-- Returns whether this blackboard contains a value for the given key.
do
  -- has() checks existence regardless of value type (number, bool, string).
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("hp", 80)
  local has_hp = bb:has("hp")
  local has_mp = bb:has("mp")
  -- Use has() before remove() to avoid unnecessary work.
  print("LAIBlackboard:has: hp=" .. tostring(has_hp) .. " mp=" .. tostring(has_mp))
end

--@api-stub: LAIBlackboard:remove
-- Removes a single key-value pair from this blackboard.
do
  -- Removing a key that does not exist is safe (no error).
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("temp", 99)
  bb:remove("temp")
  local still_has = bb:has("temp")
  -- Remove facts when they become stale: target defeated, buff expired.
  print("LAIBlackboard:remove: has_temp=" .. tostring(still_has))
end

--@api-stub: LAIBlackboard:clear
-- Removes all key-value pairs from this blackboard.
do
  -- clear() is useful on scene transitions or agent respawn.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("a", 1)
  bb:setString("b", "x")
  bb:setBool("c", true)
  bb:clear()
  local size = bb:getSize()
  -- After clear, getSize returns 0 and all get calls return their defaults.
  print("LAIBlackboard:clear: size=" .. tostring(size))
end

--@api-stub: LAIBlackboard:getKeys
-- Returns a table of all keys currently stored in this blackboard.
do
  -- getKeys returns a flat string array of all active keys.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("health", 100)
  bb:setString("state", "idle")
  bb:setBool("alive", true)
  local keys = bb:getKeys()
  -- Use getKeys for debug dumps or serialization.
  print("LAIBlackboard:getKeys: count=" .. tostring(#keys))
end

--@api-stub: LAIBlackboard:getSize
-- Returns the number of key-value pairs currently stored in this blackboard.
do
  -- getSize is O(1) and safe for per-frame debug overlays.
  local bb = lurek.ai.newBlackboard()
  bb:setNumber("x", 10)
  bb:setNumber("y", 20)
  bb:setString("name", "test")
  local size = bb:getSize()
  -- Use getSize to check memory pressure or blackboard growth.
  print("LAIBlackboard:getSize: " .. tostring(size))
end

--@api-stub: LAIBlackboard:type
-- Returns the Lua-visible type name for this blackboard handle.
do
  -- type() returns "LAIBlackboard" for blackboard handles.
  local bb = lurek.ai.newBlackboard()
  local t = bb:type()
  -- Use type() for runtime identification in generic code.
  print("LAIBlackboard:type: " .. t)
end

--@api-stub: LAIBlackboard:typeOf
-- Returns whether this blackboard handle matches a supported type name.
do
  -- typeOf accepts "LAIBlackboard" and "Object". Other strings return false.
  local bb = lurek.ai.newBlackboard()
  local is_bb = bb:typeOf("LAIBlackboard")
  local is_agent = bb:typeOf("LAgent")
  -- typeOf helps distinguish objects in polymorphic containers.
  print("LAIBlackboard:typeOf: LAIBlackboard=" .. tostring(is_bb) .. " LAgent=" .. tostring(is_agent))
end

--@api-stub: LStateMachine:addState
-- Adds a named state with optional enter and exit callbacks.
do
  -- State callbacks fire once on entry/exit, not every frame.
  -- Pass a table with optional onEnter and onExit function fields.
  local fsm = lurek.ai.newStateMachine()
  local entered = ""
  fsm:addState("patrol", {
    onEnter = function() entered = "patrol" end,
    onExit = function() end,
  })
  fsm:addState("chase", {
    onEnter = function() entered = "chase" end,
  })
  fsm:setInitialState("patrol")
  -- States are inactive until setInitialState or forceState activates one.
  print("LStateMachine:addState: entered=" .. entered)
end

--@api-stub: LStateMachine:addTransition
-- Adds a conditional transition between two named states.
do
  -- Transition fires when the predicate returns true. Priority controls order
  -- when multiple transitions from the same state are eligible.
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("idle", {})
  fsm:addState("alert", {})
  fsm:addState("attack", {})
  fsm:addTransition("idle", "alert", function() return true end, 1)
  fsm:addTransition("alert", "attack", function() return false end, 2)
  fsm:setInitialState("idle")
  local state = fsm:getCurrentState() or "none"
  -- Higher priority transitions are checked first.
  print("LStateMachine:addTransition: state=" .. state)
end

--@api-stub: LStateMachine:setInitialState
-- Sets the FSM's starting state and calls its onEnter callback.
do
  -- setInitialState must be called after addState. It triggers onEnter immediately.
  local fsm = lurek.ai.newStateMachine()
  local log = ""
  fsm:addState("sleep", { onEnter = function() log = "entered_sleep" end })
  fsm:setInitialState("sleep")
  local current = fsm:getCurrentState() or "none"
  -- After setInitialState, getCurrentState returns the active state.
  print("LStateMachine:setInitialState: " .. current .. " log=" .. log)
end

--@api-stub: LStateMachine:getCurrentState
-- Returns the name of the currently active state or nil if none set.
do
  -- getCurrentState returns nil before setInitialState is called.
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("wander", {})
  local before = fsm:getCurrentState()
  fsm:setInitialState("wander")
  local after = fsm:getCurrentState()
  -- Use getCurrentState to drive animation selection or UI display.
  print("LStateMachine:getCurrentState: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api-stub: LStateMachine:forceState
-- Forces an immediate state transition bypassing normal transition logic.
do
  -- forceState calls onExit on the old state and onEnter on the new state.
  -- Use it for cutscenes, death, or other scripted transitions.
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("alive", {})
  fsm:addState("dead", {})
  fsm:setInitialState("alive")
  fsm:forceState("dead")
  local current = fsm:getCurrentState() or "none"
  -- forceState skips condition checks; it always succeeds.
  print("LStateMachine:forceState: " .. current)
end

--@api-stub: LStateMachine:getTimeInState
-- Returns the elapsed time in the current state since the last transition.
do
  -- Time resets to zero on every state change (including forceState).
  local fsm = lurek.ai.newStateMachine()
  fsm:addState("cooking", {})
  fsm:setInitialState("cooking")
  local time_in = fsm:getTimeInState()
  -- Use time in state for cooldowns or delayed transitions.
  print("LStateMachine:getTimeInState: " .. tostring(time_in))
end

--@api-stub: LStateMachine:type
-- Returns the Lua-visible type name for this state machine handle.
do
  -- type() returns "LStateMachine" for FSM handles.
  local fsm = lurek.ai.newStateMachine()
  local t = fsm:type()
  print("LStateMachine:type: " .. t)
end

--@api-stub: LStateMachine:typeOf
-- Returns whether this FSM handle matches a supported type name.
do
  -- typeOf accepts "LStateMachine" and "Object".
  local fsm = lurek.ai.newStateMachine()
  local is_fsm = fsm:typeOf("LStateMachine")
  local is_other = fsm:typeOf("LBehaviorTree")
  print("LStateMachine:typeOf: LStateMachine=" .. tostring(is_fsm) .. " LBehaviorTree=" .. tostring(is_other))
end

--@api-stub: LBehaviorTree:setRoot
-- Sets the root node for this behavior tree.
do
  -- setRoot replaces any existing root. The tree ticks from this node.
  local bt = lurek.ai.newBehaviorTree()
  local root = lurek.ai.newAction(function() return "success" end)
  bt:setRoot(root)
  local info = bt:getDebugState()
  -- A tree without a root does nothing when ticked.
  print("LBehaviorTree:setRoot: nodes=" .. tostring(info.node_count))
end

--@api-stub: LBehaviorTree:getLastStatus
-- Returns the result of the most recent tree tick.
do
  -- Returns "success", "failure", "running", or "none" if never ticked.
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(lurek.ai.newAction(function() return "success" end))
  local status = bt:getLastStatus()
  -- Use last status to trigger side effects: play sound on success, retry on failure.
  print("LBehaviorTree:getLastStatus: " .. status)
end

--@api-stub: LBehaviorTree:getDebugState
-- Returns a table with internal debug state about this behavior tree.
do
  -- getDebugState returns {node_count=n} showing total nodes in the tree.
  local bt = lurek.ai.newBehaviorTree()
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  seq:addChild(lurek.ai.newCondition(function() return true end))
  bt:setRoot(seq)
  local info = bt:getDebugState()
  -- Use node_count for debug overlays or complexity budgets.
  print("LBehaviorTree:getDebugState: node_count=" .. tostring(info.node_count))
end

--@api-stub: LBehaviorTree:type
-- Returns the Lua-visible type name for this behavior tree handle.
do
  local bt = lurek.ai.newBehaviorTree()
  local t = bt:type()
  print("LBehaviorTree:type: " .. t)
end

--@api-stub: LBehaviorTree:typeOf
-- Returns whether this BT handle matches a supported type name.
do
  local bt = lurek.ai.newBehaviorTree()
  local is_bt = bt:typeOf("LBehaviorTree")
  local is_other = bt:typeOf("LAgent")
  print("LBehaviorTree:typeOf: LBehaviorTree=" .. tostring(is_bt) .. " LAgent=" .. tostring(is_other))
end

--@api-stub: LBTNode:addChild
-- Appends a child node to this composite (selector, sequence, or parallel).
do
  -- addChild is for composite nodes only; decorators use setChild.
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "success" end))
  seq:addChild(lurek.ai.newCondition(function() return true end))
  local count = seq:getChildCount()
  -- Children are ticked in insertion order.
  print("LBTNode:addChild: children=" .. tostring(count))
end

--@api-stub: LBTNode:getChildCount
-- Returns the number of children currently in this composite node.
do
  -- Leaf nodes (action, condition) always return 0.
  local sel = lurek.ai.newSelector()
  sel:addChild(lurek.ai.newAction(function() return "failure" end))
  sel:addChild(lurek.ai.newAction(function() return "success" end))
  sel:addChild(lurek.ai.newAction(function() return "running" end))
  local count = sel:getChildCount()
  -- Use child count to validate tree structure before ticking.
  print("LBTNode:getChildCount: " .. tostring(count))
end

--@api-stub: LBTNode:reset
-- Resets this node and all descendants to their initial state.
do
  -- Reset clears running status from nodes that were mid-execution.
  -- Call reset when re-using a tree for a new scenario.
  local seq = lurek.ai.newSequence()
  seq:addChild(lurek.ai.newAction(function() return "running" end))
  seq:reset()
  -- After reset, the next tick starts fresh from the first child.
  print("LBTNode:reset: done")
end

--@api-stub: LBTNode:setChild
-- Sets the single child of a decorator node (inverter, repeater, succeeder, guard).
do
  -- setChild replaces the decorator's current child if one exists.
  local inv = lurek.ai.newInverter()
  inv:setChild(lurek.ai.newAction(function() return "failure" end))
  local bt = lurek.ai.newBehaviorTree()
  bt:setRoot(inv)
  local status = bt:getLastStatus()
  -- Decorators wrap exactly one child; composites use addChild.
  print("LBTNode:setChild: status=" .. status)
end

--@api-stub: LBTNode:setCount
-- Sets the repeat count on a repeater decorator node.
do
  -- setCount(n) controls how many times the repeater ticks its child.
  -- A count of 0 means infinite repeat.
  local rep = lurek.ai.newRepeater(3)
  rep:setCount(10)
  local count = rep:getCount()
  -- Change count at runtime to adjust loop iterations dynamically.
  print("LBTNode:setCount: " .. tostring(count))
end

--@api-stub: LBTNode:getCount
-- Returns the repeat count from a repeater decorator node.
do
  -- getCount returns the value set by setCount or the constructor.
  local rep = lurek.ai.newRepeater(7)
  local count = rep:getCount()
  -- Use getCount for debug display or save serialization.
  print("LBTNode:getCount: " .. tostring(count))
end

--@api-stub: LBTNode:setSuccessPolicy
-- Sets the success policy on a parallel composite node.
do
  -- "requireAll" means all children must succeed for the parallel to succeed.
  -- "requireOne" means any one child succeeding is enough.
  local par = lurek.ai.newParallel("requireAll", "requireOne")
  par:setSuccessPolicy("requireOne")
  par:addChild(lurek.ai.newAction(function() return "success" end))
  par:addChild(lurek.ai.newAction(function() return "failure" end))
  -- Policy change takes effect on the next tick.
  print("LBTNode:setSuccessPolicy: done")
end

--@api-stub: LBTNode:setFailurePolicy
-- Sets the failure policy on a parallel composite node.
do
  -- "requireAll" means all children must fail for the parallel to fail.
  -- "requireOne" means any one child failing is enough.
  local par = lurek.ai.newParallel("requireOne", "requireAll")
  par:setFailurePolicy("requireOne")
  par:addChild(lurek.ai.newAction(function() return "running" end))
  -- Failure policy controls when the parallel aborts early.
  print("LBTNode:setFailurePolicy: done")
end

--@api-stub: LBTNode:getNodeType
-- Returns a string identifying what kind of BT node this is.
do
  -- Node types: "action", "condition", "selector", "sequence", "parallel",
  -- "inverter", "repeater", "succeeder", "guard".
  local act = lurek.ai.newAction(function() return "success" end)
  local sel = lurek.ai.newSelector()
  local inv = lurek.ai.newInverter()
  -- Use getNodeType for debug tree visualization.
  print("LBTNode:getNodeType: " .. act:getNodeType() .. " " .. sel:getNodeType() .. " " .. inv:getNodeType())
end

--@api-stub: LBTNode:type
-- Returns the Lua-visible type name for this BT node handle.
do
  -- type() returns "LBTNode" for all behavior tree node handles.
  local node = lurek.ai.newAction(function() return "success" end)
  local t = node:type()
  -- All node kinds (action, selector, inverter, etc.) share the same type string.
  print("LBTNode:type: " .. t)
end

print("ai_01.lua")
