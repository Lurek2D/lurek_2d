# ai

## General Info

- Module group: `Feature Systems`
- Source path: `src/ai/`
- Lua API path(s): `src/lua_api/ai_api.rs`
- Primary Lua namespace: `lurek.ai`
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua/unit/test_ai.lua, tests/lua/golden/test_ai_golden.lua, tests/lua/integration/test_entity_ai.lua, tests/lua/integration/test_ai_physics.lua, tests/lua/integration/test_ai_pathfinding.lua, tests/lua/integration/test_ai_entity_scene.lua, tests/lua/stress/test_ai_stress.lua

## Summary

The `ai` module is Lurek2D's gameplay decision-making toolkit. It brings together multiple AI paradigms including finite state machines, behavior trees, steering, GOAP, utility AI, Q-learning, squad formations, command queues, and blackboard-driven coordination so different game genres can pick the right model instead of being forced into one framework.

It exists to keep decision logic, action scoring, and agent coordination separate from entities, physics, and scripts that only want to consume the results. The module owns the reusable AI algorithms and shared data models; the Lua bridge exposes them, and game code decides how to wire them into actual actors.

It intentionally does not own pathfinding algorithms at the implementation level, rendering beyond optional debug helpers, or any authoritative scene or entity storage. It can reference pathfinding data and provide debug output, but world simulation and movement application stay outside the module.

**Scope boundary**: This module currently depends on `image`, `render`, `runtime`. It stays within the Feature Systems responsibility boundary defined in the architecture docs.

## Files

- `agent.rs`: Defines the core `Agent` record and the top-level decision-model selection enum used to attach different AI styles to an actor.
- `behavior_tree.rs`: Implements behavior tree nodes, statuses, composite policies, and the execution model for hierarchical decision logic.
- `blackboard.rs`: Provides a hierarchical key-value blackboard for local and shared AI state.
- `command_queue.rs`: Implements queued AI commands with priorities, interruptibility, and callback integration.
- `fsm.rs`: Defines finite state machine structures, state callbacks, and guarded transitions.
- `goap.rs`: Implements GOAP planning primitives and planner search over world-state facts.
- `mod.rs`: Declares the AI submodules and re-exports the main decision-model and support types, including selected pathfinding-facing types.
- `qlearner.rs`: Provides a tabular Q-learning implementation for trainable action selection.
- `render.rs`: Generates debug render output for AI state, plans, or decision structures when visual inspection is needed.
- `squad.rs`: Defines squad grouping, formation handling, and shared blackboard coordination.
- `steering.rs`: Implements movement steering behaviors such as seek, flee, arrive, wander, pursue, evade, and flocking.
- `utility_ai.rs`: Implements utility-based action scoring with considerations and response curves.
- `world.rs`: Defines `AIWorld`, the central registry and coordination surface for agents and shared AI state.

## Types

- `DecisionModel` (`enum`, `agent.rs`): Chooses which AI paradigm an `Agent` is currently using.
- `Agent` (`struct`, `agent.rs`): One autonomous actor record with movement state, limits, selected decision model, and local blackboard.
- `BTStatus` (`enum`, `behavior_tree.rs`): The execution result returned by behavior-tree steps.
- `ParallelPolicy` (`enum`, `behavior_tree.rs`): Defines how parallel behavior-tree nodes determine success or failure.
- `BTNode` (`enum`, `behavior_tree.rs`): The behavior-tree node enum describing the actual tree shape.
- `BehaviorTree` (`struct`, `behavior_tree.rs`): Hierarchical decision structure for composite, decorator, and leaf AI behavior.
- `BlackboardValue` (`enum`, `blackboard.rs`): The value enum stored in a `Blackboard`.
- `Blackboard` (`struct`, `blackboard.rs`): Hierarchical key-value state store used for AI coordination and memory.
- `Command` (`struct`, `command_queue.rs`): One queued AI command with priority and callback information.
- `CommandQueue` (`struct`, `command_queue.rs`): Ordered queue of AI commands waiting to run or interrupt one another.
- `StateCallbacks` (`struct`, `fsm.rs`): Bundles per-state lifecycle callbacks for FSM behavior.
- `Transition` (`struct`, `fsm.rs`): One guarded edge between FSM states.
- `StateMachine` (`struct`, `fsm.rs`): Finite state machine with named states and guarded transitions.
- `GOAPAction` (`struct`, `goap.rs`): One GOAP action with preconditions and effects.
- `GOAPGoal` (`struct`, `goap.rs`): Desired end-state description for GOAP planning.
- `GOAPPlanner` (`struct`, `goap.rs`): Planner that searches action sequences over world-state facts.
- `QLearner` (`struct`, `qlearner.rs`): Tabular reinforcement learner for action value estimation.
- `FormationType` (`enum`, `squad.rs`): Identifies the supported squad formation patterns.
- `Squad` (`struct`, `squad.rs`): Group-level AI container for formations and shared decisions.
- `Force` (`type`, `steering.rs`): 2D force vector (fx, fy).
- `CombineMode` (`enum`, `steering.rs`): Controls how multiple steering behaviors are merged.
- `SteeringBase` (`struct`, `steering.rs`): Shared parameters common to all steering behavior instances.
- `SteeringBehaviorType` (`enum`, `steering.rs`): Names the available steering behaviors.
- `SteeringManager` (`struct`, `steering.rs`): Combines steering behaviors to produce movement intent.
- `ResponseCurve` (`enum`, `utility_ai.rs`): The curve applied to a consideration value before scoring.
- `Consideration` (`struct`, `utility_ai.rs`): One input dimension used in utility scoring.
- `UAAction` (`struct`, `utility_ai.rs`): A candidate action inside a utility-AI model.
- `UtilityAI` (`struct`, `utility_ai.rs`): Scores candidate actions using considerations and response curves.
- `AIWorld` (`struct`, `world.rs`): The central AI registry. It owns agents, shared blackboard access, and world-level coordination of AI state.

## Functions

- `DecisionModel::parse_str` (`agent.rs`): Parses a Lua-side string identifier into the corresponding `DecisionModel`.
- `DecisionModel::as_str` (`agent.rs`): Returns the canonical Lua string identifier for this decision model.
- `Agent::new` (`agent.rs`): Creates a new agent with sensible default kinematic state.
- `BTStatus::parse_str` (`behavior_tree.rs`): Converts a Lua status string into a `BTStatus`.
- `BTStatus::as_str` (`behavior_tree.rs`): Returns the canonical Lua string for this status.
- `ParallelPolicy::parse_str` (`behavior_tree.rs`): Parses a Lua string (`"requireOne"` or `"requireAll"`) into a policy.
- `ParallelPolicy::as_str` (`behavior_tree.rs`): Returns the Lua string identifier for this policy.
- `BTNode::reset` (`behavior_tree.rs`): Recursively resets all running-child memos and repeater counters.
- `BTNode::child_count` (`behavior_tree.rs`): Returns the number of direct children this node has.
- `BehaviorTree::new` (`behavior_tree.rs`): Creates a new behavior tree with no root node.
- `Blackboard::new` (`blackboard.rs`): Creates an empty Blackboard with no parent.
- `Blackboard::set_number` (`blackboard.rs`): Sets a number value in the local store.
- `Blackboard::get_number` (`blackboard.rs`): Gets a number value, walking the parent chain.
- `Blackboard::set_bool` (`blackboard.rs`): Sets a boolean value in the local store.
- `Blackboard::get_bool` (`blackboard.rs`): Gets a boolean value, walking the parent chain.
- `Blackboard::set_string` (`blackboard.rs`): Sets a string value in the local store.
- `Blackboard::get_string` (`blackboard.rs`): Gets a string value, walking the parent chain.
- `Blackboard::has` (`blackboard.rs`): Checks if a key exists locally or in any ancestor.
- `Blackboard::remove` (`blackboard.rs`): Removes a key from the local store only.
- `Blackboard::clear` (`blackboard.rs`): Clears all local entries.
- `Blackboard::keys` (`blackboard.rs`): Returns all local key names.
- `Blackboard::size` (`blackboard.rs`): Returns the number of local entries.
- `Blackboard::set_parent` (`blackboard.rs`): Sets the parent Blackboard for hierarchical lookup.
- `Blackboard::parent` (`blackboard.rs`): Returns a reference to the parent Blackboard, if any.
- `CommandQueue::new` (`command_queue.rs`): Creates a new empty command queue.
- `CommandQueue::enqueue` (`command_queue.rs`): Appends a command to the back of the queue.
- `CommandQueue::push_front` (`command_queue.rs`): Inserts a command at the front (interrupts current without clearing).
- `CommandQueue::replace` (`command_queue.rs`): Clears the queue and enqueues one new command.
- `CommandQueue::cancel_current` (`command_queue.rs`): Cancels the current (front) command if it's interruptible.
- `CommandQueue::clear` (`command_queue.rs`): Clears all commands.
- `CommandQueue::count` (`command_queue.rs`): Returns the number of queued commands.
- `CommandQueue::is_empty` (`command_queue.rs`): Returns whether the queue is empty.
- `CommandQueue::current_type` (`command_queue.rs`): Returns the type of the front command, if any.
- `CommandQueue::current_target` (`command_queue.rs`): Returns the target coordinates of the front command.
- `CommandQueue::advance` (`command_queue.rs`): Advances the queue by removing the front command.
- `CommandQueue::enqueue_raw` (`command_queue.rs`): Appends a new command built from raw parameters.
- `CommandQueue::push_front_raw` (`command_queue.rs`): Inserts at the front from raw parameters.
- `CommandQueue::replace_raw` (`command_queue.rs`): Clears the queue and replaces with a single command from raw parameters.
- `StateMachine::new` (`fsm.rs`): Creates a new empty state machine.
- `StateMachine::add_transition` (`fsm.rs`): Adds a transition and re-sorts by descending priority.
- `StateMachine::current_state` (`fsm.rs`): Returns the current state name, if any.
- `StateMachine::time_in_state` (`fsm.rs`): Returns the time spent in the current state in seconds.
- `StateMachine::add_state_raw` (`fsm.rs`): Adds a named state with optional lifecycle callbacks.
- `StateMachine::add_transition_raw` (`fsm.rs`): Adds a transition with optional guard callback.
- `StateMachine::set_initial_state` (`fsm.rs`): Sets the initial state name.
- `GOAPPlanner::new` (`goap.rs`): Creates a new empty GOAP planner.
- `GOAPPlanner::plan` (`goap.rs`): Plans a sequence of actions to satisfy the highest-priority goal.
- `GOAPPlanner::plan_for_goal_idx` (`goap.rs`): Plans for a specific goal index.
- `GOAPPlanner::add_action` (`goap.rs`): Adds an action with the given cost and optional Lua callback.
- `GOAPPlanner::add_precondition` (`goap.rs`): Adds a boolean precondition to the named action.
- `GOAPPlanner::add_effect` (`goap.rs`): Adds a boolean effect to the named action.
- `GOAPPlanner::add_goal` (`goap.rs`): Adds a goal with the given name and priority.
- `GOAPPlanner::set_goal_state` (`goap.rs`): Sets a boolean condition on the named goal.
- `QLearner::new` (`qlearner.rs`): Creates a new Q-learner with zero-initialized Q-values.
- `QLearner::choose_action` (`qlearner.rs`): Selects an action using the epsilon-greedy policy.
- `QLearner::best_action` (`qlearner.rs`): Returns the greedy-best action (highest Q-value) for the given state.
- `QLearner::learn` (`qlearner.rs`): Performs one Bellman Q-learning update.
- `QLearner::end_episode` (`qlearner.rs`): Ends the current episode: applies epsilon decay and increments episode count.
- `QLearner::get_q` (`qlearner.rs`): Returns the Q-value for a (state, action) pair, or 0.0 if out of range.
- `QLearner::set_q` (`qlearner.rs`): Overwrites the Q-value for a (state, action) pair.
- `QLearner::serialize` (`qlearner.rs`): Serializes the Q-table to a JSON string (2D array of state rows).
- `QLearner::deserialize` (`qlearner.rs`): Restores the Q-table from a JSON string produced by [`serialize`](Self::serialize).
- `StateMachine::generate_render_commands` (`render.rs`): Generate debug render commands representing the finite state machine.
- `StateMachine::draw_to_image` (`render.rs`): Render the FSM to a CPU image.
- `BehaviorTree::generate_render_commands` (`render.rs`): Generate debug render commands that outline the behavior tree structure.
- `BehaviorTree::draw_to_image` (`render.rs`): Render the behavior tree structure to a CPU image.
- `FormationType::parse_str` (`squad.rs`): Parses a Lua string into a `FormationType`.
- `FormationType::as_str` (`squad.rs`): Returns the canonical lowercase Lua string for this formation type.
- `Squad::new` (`squad.rs`): Creates a new squad with no members, no leader, no formation, and a default spacing of 30 world units.
- `Squad::get_formation_position` (`squad.rs`): Computes the ideal world-space position for the member at `member_idx` given the leader's current position.
- `CombineMode::parse_str` (`steering.rs`): Parses from Lua string.
- `CombineMode::as_str` (`steering.rs`): Returns the Lua string representation.
- `SteeringBehaviorType::base` (`steering.rs`): Returns a reference to the common steering data.
- `SteeringBehaviorType::base_mut` (`steering.rs`): Returns a mutable reference to the common steering data.
- `SteeringBehaviorType::kind` (`steering.rs`): Returns the behavior kind as a Lua-friendly string.
- `SteeringBehaviorType::calculate` (`steering.rs`): Computes the 2D steering force for this behavior given the agent's current kinematic state.
- `SteeringManager::new` (`steering.rs`): Creates a new empty SteeringManager with weighted combination.
- `SteeringManager::calculate` (`steering.rs`): Computes the combined steering force for the given agent state.
- `SteeringManager::add_seek` (`steering.rs`): Adds a Seek behavior targeting `(tx, ty)` with the given weight.
- `SteeringManager::add_flee` (`steering.rs`): Adds a Flee behavior away from `(tx, ty)` within `panic_dist`.
- `SteeringManager::add_arrive` (`steering.rs`): Adds an Arrive behavior targeting `(tx, ty)` with deceleration inside `slowing_radius`.
- `SteeringManager::add_wander` (`steering.rs`): Adds a Wander behavior with the given circle parameters.
- `SteeringManager::add_pursue` (`steering.rs`): Adds a Pursue behavior targeting a named agent.
- `SteeringManager::add_evade` (`steering.rs`): Adds an Evade behavior fleeing from a named threat agent.
- `SteeringManager::add_flock` (`steering.rs`): Adds a Flock behavior for group movement among named neighbors.
- `SteeringManager::set_combine_mode_str` (`steering.rs`): Sets the combination mode from a Lua string (`"weighted"` or `"priority"`).
- `SteeringManager::last_force` (`steering.rs`): Returns the force vector computed during the last `calculate()` call.
- `ResponseCurve::parse_str` (`utility_ai.rs`): Parses from Lua string.
- `ResponseCurve::apply` (`utility_ai.rs`): Transforms a raw input value through this response curve using the given parameters.
- `UtilityAI::new` (`utility_ai.rs`): Creates a new empty UtilityAI.
- `UtilityAI::add_action` (`utility_ai.rs`): Adds an action with the given scorer callback and momentum bonus.
- `UtilityAI::add_consideration` (`utility_ai.rs`): Adds a consideration to the named action.
- `UtilityAI::last_action_name` (`utility_ai.rs`): Returns the name of the last chosen action, or `None` if no evaluation has occurred.
- `UtilityAI::evaluate` (`utility_ai.rs`): Evaluates all actions using Lua scorer callbacks and returns the best action name.
- `AIWorld::new` (`world.rs`): Creates a new empty AIWorld.
- `AIWorld::add_agent` (`world.rs`): Adds a new agent with the given name.
- `AIWorld::remove_agent` (`world.rs`): Removes an agent by name.
- `AIWorld::get_agent_index` (`world.rs`): Returns the index of an agent by name.
- `AIWorld::agent_count` (`world.rs`): Returns the number of agents.
- `AIWorld::global_blackboard` (`world.rs`): Returns a reference to the global blackboard.
- `AIWorld::global_blackboard_mut` (`world.rs`): Returns a mutable reference to the global blackboard.
- `AIWorld::update` (`world.rs`): Advances all agents by `dt` seconds, integrating velocity into position.

## Lua API Reference

- Binding path(s): `src/lua_api/ai_api.rs`
- Namespace: `lurek.ai`

### Module Functions
- `lurek.ai.newWorld`: Creates a new AI world container.
- `lurek.ai.newBlackboard`: Creates a new standalone blackboard.
- `lurek.ai.newStateMachine`: Creates a new finite state machine.
- `lurek.ai.newBehaviorTree`: Creates a new behavior tree.
- `lurek.ai.newSelector`: Creates a BT selector node.
- `lurek.ai.newSequence`: Creates a BT sequence node.
- `lurek.ai.newParallel`: Creates a BT parallel node with optional policies.
- `lurek.ai.newInverter`: Creates a BT inverter decorator.
- `lurek.ai.newRepeater`: Creates a BT repeater decorator.
- `lurek.ai.newSucceeder`: Creates a BT succeeder decorator.
- `lurek.ai.newAction`: Creates a BT action leaf with a Lua callback.
- `lurek.ai.newCondition`: Creates a BT condition leaf with a Lua predicate.
- `lurek.ai.newSteeringManager`: Creates a new steering behavior manager.
- `lurek.ai.newQLearner`: Creates a tabular Q-learner.
- `lurek.ai.newUtilityAI`: Creates a new utility AI evaluator.
- `lurek.ai.newGOAPPlanner`: Creates a new GOAP planning solver.
- `lurek.ai.newInfluenceMap`: Creates a multi-layer influence map grid.
- `lurek.ai.newSquad`: Creates a named squad for formation positioning.
- `lurek.ai.newCommandQueue`: Creates an RTS-style command queue.

### `AIWorld` Methods
- `AIWorld:addAgent`: Registers a new named agent and returns its handle.
- `AIWorld:getAgent`: Returns the agent handle for the given name, or nil.
- `AIWorld:removeAgent`: Removes an agent by its userdata handle.
- `AIWorld:getAgentCount`: Returns the number of registered agents.
- `AIWorld:getGlobalBlackboard`: Returns a snapshot of the world-level blackboard.
- `AIWorld:update`: Advances all agents by dt seconds.
- `AIWorld:type`: Returns the type name of this object.
- `AIWorld:typeOf`: Returns true if this object is of the given type.

### `Agent` Methods
- `Agent:getName`: Returns the agent's registered name.
- `Agent:setPosition`: Sets the agent's world-space position.
- `Agent:getPosition`: Returns the agent's current position.
- `Agent:setVelocity`: Sets the agent's velocity vector.
- `Agent:getVelocity`: Returns the agent's current velocity.
- `Agent:setMaxSpeed`: Sets the maximum speed cap.
- `Agent:getMaxSpeed`: Returns the maximum speed cap.
- `Agent:setMaxForce`: Sets the maximum steering force cap.
- `Agent:getMaxForce`: Returns the maximum steering force cap.
- `Agent:setPriority`: Sets the scheduling priority (higher = earlier).
- `Agent:getPriority`: Returns the agent's scheduling priority.
- `Agent:setDecisionModel`: Sets the active decision model.
- `Agent:getDecisionModel`: Returns the name of the current decision model.
- `Agent:addTag`: Adds a tag to this agent.
- `Agent:removeTag`: Removes a tag from this agent.
- `Agent:hasTag`: Returns true if the agent has the given tag.
- `Agent:getBlackboard`: Returns the agent's local blackboard.
- `Agent:type`: Returns the type name of this object.
- `Agent:typeOf`: Returns true if this object is of the given type.

### `BTNode` Methods
- `BTNode:addChild`: Adds a child node (Selector, Sequence, or Parallel only).
- `BTNode:getChildCount`: Returns the number of direct children.
- `BTNode:reset`: Resets all running-child memos and repeater counters.
- `BTNode:setChild`: Sets the single child of a decorator node.
- `BTNode:setCount`: Sets the repeat count for a Repeater node.
- `BTNode:getCount`: Returns the repeat count, or 0 if not a Repeater.
- `BTNode:setSuccessPolicy`: Sets the success policy for a Parallel node.
- `BTNode:setFailurePolicy`: Sets the failure policy for a Parallel node.
- `BTNode:getNodeType`: Returns the node type as a string.
- `BTNode:type`: Returns the type name of this object.
- `BTNode:typeOf`: Returns true if this object is of the given type.

### `BehaviorTree` Methods
- `BehaviorTree:setRoot`: Sets the root node of this behavior tree.
- `BehaviorTree:getLastStatus`: Returns the status from the last tick.
- `BehaviorTree:type`: Returns the type name of this object.
- `BehaviorTree:typeOf`: Returns true if this object is of the given type.

### `Blackboard` Methods
- `Blackboard:setNumber`: Stores a number under the given key.
- `Blackboard:setBool`: Stores a boolean under the given key.
- `Blackboard:setString`: Stores a string under the given key.
- `Blackboard:has`: Returns true if a value exists under the key.
- `Blackboard:remove`: Removes the entry at key.
- `Blackboard:clear`: Removes all local entries.
- `Blackboard:getKeys`: Returns all local keys as a table.
- `Blackboard:getSize`: Returns the number of local entries.
- `Blackboard:type`: Returns the type name of this object.
- `Blackboard:typeOf`: Returns true if this object is of the given type.

### `CommandQueue` Methods
- `CommandQueue:cancelCurrent`: Cancels the front command if it is interruptible.
- `CommandQueue:clear`: Discards all queued commands.
- `CommandQueue:getCount`: Returns the number of queued commands.
- `CommandQueue:isEmpty`: Returns true if there are no queued commands.
- `CommandQueue:getCurrentType`: Returns the kind of the front command, or nil.
- `CommandQueue:getCurrentTarget`: Returns the target coordinates of the front command.
- `CommandQueue:type`: Returns the type name of this object.
- `CommandQueue:typeOf`: Returns true if this object is of the given type.

### `GOAPPlanner` Methods
- `GOAPPlanner:getActionCount`: Returns the number of registered actions.
- `GOAPPlanner:getGoalCount`: Returns the number of registered goals.
- `GOAPPlanner:type`: Returns the type name of this object.
- `GOAPPlanner:typeOf`: Returns true if this object is of the given type.

### `InfluenceMap` Methods
- `InfluenceMap:addLayer`: Adds a named influence layer.
- `InfluenceMap:hasLayer`: Returns true if the named layer exists.
- `InfluenceMap:decay`: Multiplies all influences by a decay factor.
- `InfluenceMap:clearLayer`: Clears all influence in a layer.
- `InfluenceMap:clearAll`: Clears all layers.
- `InfluenceMap:getMaxPosition`: Returns the world-space position of the maximum value.
- `InfluenceMap:getMinPosition`: Returns the world-space position of the minimum value.
- `InfluenceMap:getWidth`: Returns the grid width.
- `InfluenceMap:getHeight`: Returns the grid height.
- `InfluenceMap:getCellSize`: Returns the cell size in world units.
- `InfluenceMap:type`: Returns the type name of this object.
- `InfluenceMap:typeOf`: Returns true if this object is of the given type.

### `QLearner` Methods
- `QLearner:chooseAction`: Selects an action using epsilon-greedy policy (1-based).
- `QLearner:bestAction`: Returns the greedy-best action for the state (1-based).
- `QLearner:getQValue`: Returns the Q-value for a state-action pair (1-based).
- `QLearner:endEpisode`: Ends the current episode, applying epsilon decay.
- `QLearner:getEpisodeCount`: Returns the number of completed episodes.
- `QLearner:getStateCount`: Returns the number of discrete states.
- `QLearner:getActionCount`: Returns the number of discrete actions.
- `QLearner:setLearningRate`: Sets the learning rate alpha.
- `QLearner:getLearningRate`: Returns the current learning rate.
- `QLearner:setDiscountFactor`: Sets the discount factor gamma.
- `QLearner:getDiscountFactor`: Returns the current discount factor.
- `QLearner:setExplorationRate`: Sets the exploration rate epsilon.
- `QLearner:getExplorationRate`: Returns the current exploration rate.
- `QLearner:setExplorationDecay`: Sets the epsilon decay multiplier.
- `QLearner:getExplorationDecay`: Returns the epsilon decay multiplier.
- `QLearner:serialize`: Serializes the Q-table to a JSON string.
- `QLearner:deserialize`: Restores the Q-table from a JSON string.
- `QLearner:type`: Returns the type name of this object.
- `QLearner:typeOf`: Returns true if this object is of the given type.

### `Squad` Methods
- `Squad:getName`: Returns the squad name.
- `Squad:addMember`: Adds an agent by name to this squad.
- `Squad:removeMember`: Removes an agent by name from this squad.
- `Squad:getMemberCount`: Returns the number of squad members.
- `Squad:getMembers`: Returns the member names as a table.
- `Squad:setLeader`: Sets the squad leader by name.
- `Squad:getLeader`: Returns the leader name, or nil.
- `Squad:getFormation`: Returns the current formation type name.
- `Squad:getFormationSpacing`: Returns the formation spacing in world units.
- `Squad:getBlackboard`: Returns the squad's shared blackboard.
- `Squad:type`: Returns the type name of this object.
- `Squad:typeOf`: Returns true if this object is of the given type.

### `StateMachine` Methods
- `StateMachine:addState`: Registers a named state with optional lifecycle callbacks.
- `StateMachine:setInitialState`: Sets the initial state.
- `StateMachine:getCurrentState`: Returns the current state name, or nil.
- `StateMachine:forceState`: Forces a transition to the named state.
- `StateMachine:getTimeInState`: Returns seconds spent in the current state.
- `StateMachine:type`: Returns the type name of this object.
- `StateMachine:typeOf`: Returns true if this object is of the given type.

### `SteeringManager` Methods
- `SteeringManager:getBehaviorCount`: Returns the number of active behaviors.
- `SteeringManager:setCombineMode`: Sets the force combination mode.
- `SteeringManager:getCombineMode`: Returns the current combination mode.
- `SteeringManager:getLastSteering`: Returns the last computed steering force.
- `SteeringManager:type`: Returns the type name of this object.
- `SteeringManager:typeOf`: Returns true if this object is of the given type.

### `UtilityAI` Methods
- `UtilityAI:evaluate`: Evaluates all actions and returns the best action name, or nil.
- `UtilityAI:getActionCount`: Returns the number of registered actions.
- `UtilityAI:getLastAction`: Returns the name of the last chosen action, or nil.
- `UtilityAI:type`: Returns the type name of this object.
- `UtilityAI:typeOf`: Returns true if this object is of the given type.

## References

- `image`: Imports or references `image` from `src/image/`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/ai/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
