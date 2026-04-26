---@meta
--- Auto-generated Lurek2D API documentation for LuaCATS.

lurek = {}

---@class lurek.ai
lurek.ai = {}

--- Lua-side wrapper around a [`Blackboard`].
---@class LAIBlackboard
LAIBlackboard = {}

--- Removes all local entries.
function LAIBlackboard:clear() end

--- Returns the boolean for the given key, or default.
---@param key any
---@param default? any
function LAIBlackboard:getBool(key, default) end

--- Returns all local keys as a table.
function LAIBlackboard:getKeys() end

--- Returns the number for the given key, or default.
---@param key any
---@param default? any
function LAIBlackboard:getNumber(key, default) end

--- Returns the number of local entries.
function LAIBlackboard:getSize() end

--- Returns the string for the given key, or default.
---@param key any
---@param default? any
function LAIBlackboard:getString(key, default) end

--- Returns true if a value exists under the key.
---@param key any
function LAIBlackboard:has(key) end

--- Removes the entry at key.
---@param key any
function LAIBlackboard:remove(key) end

--- Stores a boolean under the given key.
---@param key any
---@param value any
function LAIBlackboard:setBool(key, value) end

--- Stores a number under the given key.
---@param key any
---@param value any
function LAIBlackboard:setNumber(key, value) end

--- Stores a string under the given key.
---@param key any
---@param value any
function LAIBlackboard:setString(key, value) end

--- Returns the type name of this object.
function LAIBlackboard:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAIBlackboard:typeOf(name) end

--- Lua wrapper for [`crate::ai::director::AIDirector`].
---@class LAIDirector
LAIDirector = {}

--- Returns or performs ambient intensity.
function LAIDirector:ambientIntensity() end

--- Returns or performs loot factor.
function LAIDirector:lootFactor() end

--- Returns or performs phase.
function LAIDirector:phase() end

--- Pushes a gameplay event with the given intensity to the director for awareness analysis.
---@param intensity any
function LAIDirector:pushEvent(intensity) end

--- Resets or clears the state.
function LAIDirector:reset() end

--- Sets the global narrative tension level (0â€“1 scale).
---@param value any
function LAIDirector:setTension(value) end

--- Returns or performs spawn rate factor.
function LAIDirector:spawnRateFactor() end

--- Returns or performs tension.
function LAIDirector:tension() end

--- Returns the type name of this object.
function LAIDirector:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAIDirector:typeOf(name) end

--- Advances the simulation by one time step.
---@param dt any
function LAIDirector:update(dt) end

--- Lua wrapper for [`crate::ai::lod::AILod`].
---@class LAILod
LAILod = {}

--- Returns or performs should update.
---@param tier any
---@param frame any
function LAILod:shouldUpdate(tier, frame) end

--- Returns or performs tier count.
function LAILod:tierCount() end

--- Returns or performs tier for.
---@param ax any
---@param ay any
---@param rx any
---@param ry any
function LAILod:tierFor(ax, ay, rx, ry) end

--- Returns or performs tier name.
---@param tier any
function LAILod:tierName(tier) end

--- Returns the type name of this object.
function LAILod:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAILod:typeOf(name) end

--- Lua-side wrapper around an [`AIWorld`].
---@class LAIWorld
LAIWorld = {}

--- Registers a new named agent and returns its handle.
---@param name any
function LAIWorld:addAgent(name) end

--- Returns the agent handle for the given name, or nil.
---@param name any
function LAIWorld:getAgent(name) end

--- Returns the number of registered agents.
function LAIWorld:getAgentCount() end

--- Returns a snapshot of the world-level blackboard.
function LAIWorld:getGlobalBlackboard() end

--- Removes an agent by its userdata handle.
---@param agent any
function LAIWorld:removeAgent(agent) end

--- Returns the type name of this object.
function LAIWorld:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAIWorld:typeOf(name) end

--- Advances all agents by dt seconds, then invokes any custom-model callbacks.
---@param dt any
function LAIWorld:update(dt) end

--- Lua-side wrapper for an agent accessed by name through the owning world.
---@class LAgent
LAgent = {}

--- Adds a tag to this agent.
---@param tag any
function LAgent:addTag(tag) end

--- Returns the agent's local blackboard.
function LAgent:getBlackboard() end

--- Returns the name of the current decision model.
function LAgent:getDecisionModel() end

--- Returns the maximum steering force cap.
function LAgent:getMaxForce() end

--- Returns the maximum speed cap.
function LAgent:getMaxSpeed() end

--- Returns the agent's registered name.
function LAgent:getName() end

--- Returns the agent's current position.
function LAgent:getPosition() end

--- Returns the agent's scheduling priority.
function LAgent:getPriority() end

--- Returns the agent's current velocity.
function LAgent:getVelocity() end

--- Returns true if the agent has the given tag.
---@param tag any
function LAgent:hasTag(tag) end

--- Removes a tag from this agent.
---@param tag any
function LAgent:removeTag(tag) end

--- Installs a Lua-driven decision model on this agent.
---@param callback any
function LAgent:setCustomModel(callback) end

--- Sets the active decision model.
---@param model any
function LAgent:setDecisionModel(model) end

--- Sets the maximum steering force cap.
---@param v any
function LAgent:setMaxForce(v) end

--- Sets the maximum speed cap.
---@param v any
function LAgent:setMaxSpeed(v) end

--- Sets the agent's world-space position.
---@param x any
---@param y any
function LAgent:setPosition(x, y) end

--- Sets the scheduling priority (higher = earlier).
---@param p any
function LAgent:setPriority(p) end

--- Sets the agent's velocity vector.
---@param x any
---@param y any
function LAgent:setVelocity(x, y) end

--- Returns the type name of this object.
function LAgent:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAgent:typeOf(name) end

--- Lua-side wrapper around a [`BTNode`].
---@class LBTNode
LBTNode = {}

--- Adds a child node (Selector, Sequence, or Parallel only).
---@param child_ud any
function LBTNode:addChild(child_ud) end

--- Returns the number of direct children.
function LBTNode:getChildCount() end

--- Returns the repeat count, or 0 if not a Repeater.
function LBTNode:getCount() end

--- Returns the node type as a string.
function LBTNode:getNodeType() end

--- Resets all running-child memos and repeater counters.
function LBTNode:reset() end

--- Sets the single child of a decorator node.
---@param child_ud any
function LBTNode:setChild(child_ud) end

--- Sets the repeat count for a Repeater node.
---@param n any
function LBTNode:setCount(n) end

--- Sets the failure policy for a Parallel node.
---@param policy any
function LBTNode:setFailurePolicy(policy) end

--- Sets the success policy for a Parallel node.
---@param policy any
function LBTNode:setSuccessPolicy(policy) end

--- Returns the type name of this object.
function LBTNode:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBTNode:typeOf(name) end

--- Lua wrapper for [`crate::ai::bandit::Bandit`].
---@class LBandit
LBandit = {}

--- Returns or performs arm count.
function LBandit:armCount() end

--- Returns or performs best arm.
function LBandit:bestArm() end

--- Resets or clears the state.
function LBandit:reset() end

--- Returns or performs select.
function LBandit:select() end

--- Returns or performs total pulls.
function LBandit:totalPulls() end

--- Returns the type name of this object.
function LBandit:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBandit:typeOf(name) end

--- Advances the simulation by one time step.
---@param idx any
---@param reward any
function LBandit:update(idx, reward) end

--- Lua-side wrapper around a [`BehaviorTree`].
---@class LBehaviorTree
LBehaviorTree = {}

--- Returns a diagnostic snapshot of this behavior tree.
function LBehaviorTree:getDebugState() end

--- Returns the status from the last tick.
function LBehaviorTree:getLastStatus() end

--- Sets the root node of this behavior tree.
---@param node_ud any
function LBehaviorTree:setRoot(node_ud) end

--- Returns the type name of this object.
function LBehaviorTree:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBehaviorTree:typeOf(name) end

--- Lua-side wrapper around a [`CommandQueue`].
---@class LCommandQueue
LCommandQueue = {}

--- Cancels the front command if it is interruptible.
function LCommandQueue:cancelCurrent() end

--- Discards all queued commands.
function LCommandQueue:clear() end

--- Appends a command to the back of the queue.
---@param kind any
---@param callback any
---@param opts? any
function LCommandQueue:enqueue(kind, callback, opts) end

--- Returns the number of queued commands.
function LCommandQueue:getCount() end

--- Returns the target coordinates of the front command.
function LCommandQueue:getCurrentTarget() end

--- Returns the kind of the front command, or nil.
function LCommandQueue:getCurrentType() end

--- Returns true if there are no queued commands.
function LCommandQueue:isEmpty() end

--- Inserts a command at the front, interrupting the current one.
---@param kind any
---@param callback any
---@param opts? any
function LCommandQueue:pushFront(kind, callback, opts) end

--- Clears the queue and enqueues one new command.
---@param kind any
---@param callback any
---@param opts? any
function LCommandQueue:replace(kind, callback, opts) end

--- Returns the type name of this object.
function LCommandQueue:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCommandQueue:typeOf(name) end

--- Lua wrapper for [`crate::ai::context_steering::ContextSteering`].
---@class LContextSteering
LContextSteering = {}

--- Registers a rectangular region this agent must avoid.
---@param min_x any
---@param min_y any
---@param max_x any
---@param max_y any
---@param margin any
---@param weight any
function LContextSteering:addAvoidBounds(min_x, min_y, max_x, max_y, margin, weight) end

--- Adds a world-space point that this agent steers away from.
---@param x any
---@param y any
---@param radius any
---@param weight any
function LContextSteering:addAvoidPoint(x, y, radius, weight) end

--- Adds a world-space target that this agent steers towards.
---@param tx any
---@param ty any
---@param weight any
function LContextSteering:addSeekTarget(tx, ty, weight) end

--- Adds a wander behavior with jitter and weight to the context steering evaluator.
---@param jitter any
---@param weight any
function LContextSteering:addWander(jitter, weight) end

--- Returns or performs chosen magnitude.
function LContextSteering:chosenMagnitude() end

--- Resets or clears the behaviors.
function LContextSteering:clearBehaviors() end

--- Evaluates and returns the computed result.
---@param ax any
---@param ay any
---@param vx any
---@param vy any
function LContextSteering:evaluate(ax, ay, vx, vy) end

--- Returns or performs slot count.
function LContextSteering:slotCount() end

--- Returns the type name of this object.
function LContextSteering:type() end

--- Returns true if this object is of the given type.
---@param name any
function LContextSteering:typeOf(name) end

--- Lua wrapper for [`crate::ai::emotion::EmotionModel`].
---@class LEmotionModel
LEmotionModel = {}

--- Adds an emotion category with the given name and initial intensity to the model.
---@param name any
---@param rest any
---@param decay any
---@param min_vis any
function LEmotionModel:add(name, rest, decay, min_vis) end

--- Returns or performs dominant.
function LEmotionModel:dominant() end

--- Returns the current float value of this emotion dimension.
---@param name any
function LEmotionModel:get(name) end

--- Returns `true` if the emotion dimension is currently active and above threshold.
---@param name any
function LEmotionModel:isActive(name) end

--- Resets or clears the state.
function LEmotionModel:reset() end

--- Returns or performs trigger.
---@param name any
---@param amount any
function LEmotionModel:trigger(name, amount) end

--- Returns the type name of this object.
function LEmotionModel:type() end

--- Returns true if this object is of the given type.
---@param name any
function LEmotionModel:typeOf(name) end

--- Advances the simulation by one time step.
---@param dt any
function LEmotionModel:update(dt) end

--- Lua-side wrapper around a [`GOAPPlanner`].
---@class LGOAPPlanner
LGOAPPlanner = {}

--- Adds a GOAP action with optional cost and callback.
---@param name any
---@param cost? any
---@param callback? any
function LGOAPPlanner:addAction(name, cost, callback) end

--- Adds a planning goal with optional priority.
---@param name any
---@param priority? any
function LGOAPPlanner:addGoal(name, priority) end

--- Returns the number of registered actions.
function LGOAPPlanner:getActionCount() end

--- Returns the number of registered goals.
function LGOAPPlanner:getGoalCount() end

--- Returns the maximum A* planning iterations.
function LGOAPPlanner:getMaxIterations() end

--- Runs A* planning and returns an action sequence table.
---@param world_state_tbl any
---@param max_depth? any
function LGOAPPlanner:plan(world_state_tbl, max_depth) end

--- Sets a boolean effect on an action.
---@param action_name any
---@param key any
---@param value any
function LGOAPPlanner:setEffect(action_name, key, value) end

--- Sets a boolean condition on a goal.
---@param goal_name any
---@param key any
---@param value any
function LGOAPPlanner:setGoalState(goal_name, key, value) end

--- Sets the maximum A* planning iterations (0 = unlimited).
---@param n any
function LGOAPPlanner:setMaxIterations(n) end

--- Sets a boolean precondition on an action.
---@param action_name any
---@param key any
---@param value any
function LGOAPPlanner:setPrecondition(action_name, key, value) end

--- Returns the type name of this object.
function LGOAPPlanner:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGOAPPlanner:typeOf(name) end

--- Lua wrapper for [`crate::ai::genetic::GeneticAlgorithm`].
---@class LGeneticAlgorithm
LGeneticAlgorithm = {}

--- Returns or performs best genes.
function LGeneticAlgorithm:bestGenes() end

--- Runs one generation of the evolutionary algorithm.
function LGeneticAlgorithm:evolve() end

--- Returns or performs generation.
function LGeneticAlgorithm:generation() end

--- Returns the chromosome as an ordered table of gene values.
---@param idx any
function LGeneticAlgorithm:getGenes(idx) end

--- Returns or performs pop size.
function LGeneticAlgorithm:popSize() end

--- Sets the fitness score used by the genetic algorithm selection step.
---@param idx any
---@param fitness any
function LGeneticAlgorithm:setFitness(idx, fitness) end

--- Returns the type name of this object.
function LGeneticAlgorithm:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGeneticAlgorithm:typeOf(name) end

--- Lua wrapper for [`crate::ai::htn::HTNDomain`].
---@class LHTNDomain
LHTNDomain = {}

--- Registers a compound HTN task that decomposes into sub-tasks.
---@param comp_name any
---@param methods_table any
function LHTNDomain:addCompound(comp_name, methods_table) end

--- Registers a primitive HTN task with a direct operator function.
---@param name any
---@param preconds any
---@param effects any
---@param clears any
function LHTNDomain:addPrimitive(name, preconds, effects, clears) end

--- Runs planning and returns the resulting action sequence.
---@param root_task any
---@param state_table any
function LHTNDomain:plan(root_task, state_table) end

--- Returns or performs task count.
function LHTNDomain:taskCount() end

--- Returns the type name of this object.
function LHTNDomain:type() end

--- Returns true if this object is of the given type.
---@param name any
function LHTNDomain:typeOf(name) end

--- Lua-side wrapper around an [`InfluenceMap`].
---@class LInfluenceMap
LInfluenceMap = {}

--- Adds a named influence layer.
---@param name any
function LInfluenceMap:addLayer(name) end

--- Blends two layers into a destination layer.
---@param layer_a any
---@param weight_a any
---@param layer_b any
---@param weight_b any
---@param dest any
function LInfluenceMap:blend(layer_a, weight_a, layer_b, weight_b, dest) end

--- Removes all influence values from every layer in the map.
function LInfluenceMap:clearAll() end

--- Clears all influence in a layer.
---@param layer any
function LInfluenceMap:clearLayer(layer) end

--- Multiplies all influences by a decay factor.
---@param layer any
---@param factor any
function LInfluenceMap:decay(layer, factor) end

--- Returns the cell size in world units.
function LInfluenceMap:getCellSize() end

--- Returns the influence map height in grid cells.
function LInfluenceMap:getHeight() end

--- Returns the influence value at a cell (1-based).
---@param layer any
---@param x any
---@param y any
function LInfluenceMap:getInfluence(layer, x, y) end

--- Returns the world-space position of the maximum value.
---@param layer any
function LInfluenceMap:getMaxPosition(layer) end

--- Returns the world-space position of the minimum value.
---@param layer any
function LInfluenceMap:getMinPosition(layer) end

--- Returns the influence map width in grid cells.
function LInfluenceMap:getWidth() end

--- Returns true if the named layer exists.
---@param name any
function LInfluenceMap:hasLayer(name) end

--- Propagates influence values with momentum.
---@param layer any
---@param momentum? any
function LInfluenceMap:propagate(layer, momentum) end

--- Returns the summed influence in a world-space rectangle.
---@param layer any
---@param wx any
---@param wy any
---@param ww any
---@param wh any
function LInfluenceMap:queryRect(layer, wx, wy, ww, wh) end

--- Sets the influence value at a cell (1-based).
---@param layer any
---@param x any
---@param y any
---@param value any
function LInfluenceMap:setInfluence(layer, x, y, value) end

--- Stamps influence in a radial area.
---@param layer any
---@param wx any
---@param wy any
---@param radius any
---@param value any
---@param falloff? any
function LInfluenceMap:stampInfluence(layer, wx, wy, radius, value, falloff) end

--- Returns the type name of this object.
function LInfluenceMap:type() end

--- Returns true if this object is of the given type.
---@param name any
function LInfluenceMap:typeOf(name) end

--- Lua wrapper for [`crate::ai::mcts::MCTSEngine`].
---@class LMCTSEngine
LMCTSEngine = {}

--- Uses Lua closures for game logic. All closures receive/return integer states.
function LMCTSEngine:search() end

--- Returns the type name of this object.
function LMCTSEngine:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMCTSEngine:typeOf(name) end

--- Lua wrapper for [`crate::ai::needs::NeedSystem`].
---@class LNeedSystem
LNeedSystem = {}

--- Registers a new need with the specified name, urgency, and decay rate in the system.
---@param name any
---@param decay_rate any
---@param urgency_threshold any
---@param urgency_factor any
function LNeedSystem:addNeed(name, decay_rate, urgency_threshold, urgency_factor) end

--- Returns or performs most urgent.
function LNeedSystem:mostUrgent() end

--- Returns or performs satisfy.
---@param name any
---@param amount any
function LNeedSystem:satisfy(name, amount) end

--- Returns the type name of this object.
function LNeedSystem:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNeedSystem:typeOf(name) end

--- Advances the simulation by one time step.
---@param dt any
function LNeedSystem:update(dt) end

--- Returns or performs value of.
---@param name any
function LNeedSystem:valueOf(name) end

--- Lua wrapper for [`crate::ai::neural_net::NeuralNet`].
---@class LNeuralNet
LNeuralNet = {}

--- Adds a neural network layer with inputs, outputs, and an activation function.
---@param inputs any
---@param outputs any
---@param activation any
function LNeuralNet:addLayer(inputs, outputs, activation) end

--- Returns or performs forward.
---@param input any
function LNeuralNet:forward(input) end

--- Returns a flat table of all connection weight values in the network.
function LNeuralNet:getWeights() end

--- Returns or performs layer count.
function LNeuralNet:layerCount() end

--- Returns or performs param count.
function LNeuralNet:paramCount() end

--- Overwrites all connection weights with values from a flat table.
---@param weights any
function LNeuralNet:setWeights(weights) end

--- Returns the type name of this object.
function LNeuralNet:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNeuralNet:typeOf(name) end

--- Lua wrapper for [`crate::ai::neuroevolution::Neuroevolution`].
---@class LNeuroevolution
LNeuroevolution = {}

--- Returns or performs best fitness.
function LNeuroevolution:bestFitness() end

--- Returns or performs best network.
function LNeuroevolution:bestNetwork() end

--- Returns or performs chromosome to net.
---@param idx any
function LNeuroevolution:chromosomeToNet(idx) end

--- Runs one generation of the evolutionary algorithm.
function LNeuroevolution:evolve() end

--- Returns or performs generation.
function LNeuroevolution:generation() end

--- Returns or performs pop size.
function LNeuroevolution:popSize() end

--- Sets the fitness score used by the genetic algorithm selection step.
---@param idx any
---@param fitness any
function LNeuroevolution:setFitness(idx, fitness) end

--- Returns the type name of this object.
function LNeuroevolution:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNeuroevolution:typeOf(name) end

--- Lua wrapper for [`crate::ai::orca::ORCASolver`].
---@class LORCASolver
LORCASolver = {}

--- Adds an ORCA agent at the given position with radius and max speed to the solver.
---@param x any
---@param y any
---@param radius any
---@param max_speed any
function LORCASolver:addAgent(x, y, radius, max_speed) end

--- Returns or performs agent count.
function LORCASolver:agentCount() end

--- Computes and returns the result.
---@param dt any
function LORCASolver:compute(dt) end

--- Returns the safe velocity.
---@param idx any
function LORCASolver:getSafeVelocity(idx) end

--- Sets the agent's current world-space position for ORCA velocity computation.
---@param idx any
---@param x any
---@param y any
function LORCASolver:setPosition(idx, x, y) end

--- Sets the preferred velocity.
---@param idx any
---@param pvx any
---@param pvy any
function LORCASolver:setPreferredVelocity(idx, pvx, pvy) end

--- Returns the type name of this object.
function LORCASolver:type() end

--- Returns true if this object is of the given type.
---@param name any
function LORCASolver:typeOf(name) end

--- Lua-side wrapper around a [`QLearner`].
---@class LQLearner
LQLearner = {}

--- Returns the greedy-best action for the state (1-based).
---@param state any
function LQLearner:bestAction(state) end

--- Selects an action using epsilon-greedy policy (1-based).
---@param state any
function LQLearner:chooseAction(state) end

--- Restores the Q-table from a JSON string.
---@param json any
function LQLearner:deserialize(json) end

--- Ends the current episode, applying epsilon decay.
function LQLearner:endEpisode() end

--- Returns the number of discrete actions.
function LQLearner:getActionCount() end

--- Returns the current discount factor.
function LQLearner:getDiscountFactor() end

--- Returns the number of completed episodes.
function LQLearner:getEpisodeCount() end

--- Returns the epsilon decay multiplier.
function LQLearner:getExplorationDecay() end

--- Returns the current exploration rate.
function LQLearner:getExplorationRate() end

--- Returns the current learning rate.
function LQLearner:getLearningRate() end

--- Returns the Q-value for a state-action pair (1-based).
---@param state any
---@param action any
function LQLearner:getQValue(state, action) end

--- Returns the number of discrete states.
function LQLearner:getStateCount() end

--- Performs one Bellman Q-learning update (1-based indices).
---@param state any
---@param action any
---@param reward any
---@param next_state any
function LQLearner:learn(state, action, reward, next_state) end

--- Serializes the Q-table to a JSON string.
function LQLearner:serialize() end

--- Sets the discount factor gamma.
---@param v any
function LQLearner:setDiscountFactor(v) end

--- Sets the epsilon decay multiplier.
---@param v any
function LQLearner:setExplorationDecay(v) end

--- Sets the exploration rate epsilon.
---@param v any
function LQLearner:setExplorationRate(v) end

--- Sets the learning rate alpha.
---@param v any
function LQLearner:setLearningRate(v) end

--- Overwrites the Q-value for a state-action pair (1-based).
---@param state any
---@param action any
---@param value any
function LQLearner:setQValue(state, action, value) end

--- Returns the type name of this object.
function LQLearner:type() end

--- Returns true if this object is of the given type.
---@param name any
function LQLearner:typeOf(name) end

--- Lua-side wrapper around a [`Squad`].
---@class LSquad
LSquad = {}

--- Adds an agent by name to this squad.
---@param name any
function LSquad:addMember(name) end

--- Returns the squad's shared blackboard.
function LSquad:getBlackboard() end

--- Returns the current formation type name.
function LSquad:getFormation() end

--- Computes the world-space position for a member index (1-based).
---@param member_idx any
---@param leader_x any
---@param leader_y any
function LSquad:getFormationPosition(member_idx, leader_x, leader_y) end

--- Returns the formation spacing in world units.
function LSquad:getFormationSpacing() end

--- Returns the leader name, or nil.
function LSquad:getLeader() end

--- Returns the number of squad members.
function LSquad:getMemberCount() end

--- Returns the member names as a table.
function LSquad:getMembers() end

--- Returns the unique name string assigned to this squad.
function LSquad:getName() end

--- Removes an agent by name from this squad.
---@param name any
function LSquad:removeMember(name) end

--- Sets the formation type and optional spacing.
---@param ftype any
---@param spacing? any
function LSquad:setFormation(ftype, spacing) end

--- Sets the squad leader by name.
---@param name any
function LSquad:setLeader(name) end

--- Returns the type name of this object.
function LSquad:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSquad:typeOf(name) end

--- Lua-side wrapper around a [`StateMachine`].
---@class LStateMachine
LStateMachine = {}

--- Registers a named state with optional lifecycle callbacks.
---@param name any
---@param opts any
function LStateMachine:addState(name, opts) end

--- Adds a guarded transition between states.
---@param from any
---@param to any
---@param guard? any
---@param priority? any
function LStateMachine:addTransition(from, to, guard, priority) end

--- Forces a transition to the named state.
---@param name any
function LStateMachine:forceState(name) end

--- Returns the current state name, or nil.
function LStateMachine:getCurrentState() end

--- Returns seconds spent in the current state.
function LStateMachine:getTimeInState() end

--- Sets the FSM's initial state; must be called before the first update.
---@param name any
function LStateMachine:setInitialState(name) end

--- Returns the type name of this object.
function LStateMachine:type() end

--- Returns true if this object is of the given type.
---@param name any
function LStateMachine:typeOf(name) end

--- Lua-side wrapper around a [`SteeringManager`].
---@class LSteeringManager
LSteeringManager = {}

--- Adds an Arrive behavior with deceleration.
---@param tx any
---@param ty any
---@param slowing? any
---@param weight? any
function LSteeringManager:addArrive(tx, ty, slowing, weight) end

--- Registers a Lua callback as a custom steering behavior.
---@param func any
---@param weight? any
function LSteeringManager:addCustomBehavior(func, weight) end

--- Adds an Evade behavior fleeing from a named agent.
---@param threat_name? any
---@param weight? any
function LSteeringManager:addEvade(threat_name, weight) end

--- Adds a Flee behavior away from the target.
---@param tx any
---@param ty any
---@param panic_dist? any
---@param weight? any
function LSteeringManager:addFlee(tx, ty, panic_dist, weight) end

--- Adds a Flock behavior for group movement.
function LSteeringManager:addFlock() end

--- Adds a Pursue behavior targeting a named agent.
---@param target_name? any
---@param weight? any
function LSteeringManager:addPursue(target_name, weight) end

--- Adds a Seek behavior toward the target.
---@param tx any
---@param ty any
---@param weight? any
function LSteeringManager:addSeek(tx, ty, weight) end

--- Adds a Wander behavior for random meandering.
function LSteeringManager:addWander() end

--- Invokes all registered custom steering callbacks and returns the combined force.
---@param agent_ud any
---@param dt any
function LSteeringManager:applyCustomSteering(agent_ud, dt) end

--- Computes the combined steering force for the given agent state.
---@param px any
---@param py any
---@param vx any
---@param vy any
---@param max_speed any
---@param max_force any
---@param dt any
function LSteeringManager:calculate(px, py, vx, vy, max_speed, max_force, dt) end

--- Enables or disables spatial-hash bucketing for neighbourhood queries.
---@param enabled any
function LSteeringManager:enableSpatialHash(enabled) end

--- Returns the number of active behaviors.
function LSteeringManager:getBehaviorCount() end

--- Returns the current combination mode.
function LSteeringManager:getCombineMode() end

--- Returns the last computed steering force.
function LSteeringManager:getLastSteering() end

--- Sets the force combination mode.
---@param mode any
function LSteeringManager:setCombineMode(mode) end

--- Sets the cell size used by the spatial-hash neighbourhood search.
---@param size any
function LSteeringManager:setSpatialHashCellSize(size) end

--- Returns the type name of this object.
function LSteeringManager:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSteeringManager:typeOf(name) end

--- Lua wrapper for [`crate::ai::perception::StimulusWorld`].
---@class LStimulusWorld
LStimulusWorld = {}

--- Registers an auditory stimulus at a world-space position.
function LStimulusWorld:addAuditory() end

--- Adds a visual stimulus at the specified world position with radius and intensity.
---@param x any
---@param y any
---@param intensity any
---@param radius any
---@param tag? any
function LStimulusWorld:addVisual(x, y, intensity, radius, tag) end

--- Resets or clears the state.
function LStimulusWorld:clear() end

--- Returns or performs count.
function LStimulusWorld:count() end

--- Removes the specified item.
---@param id any
function LStimulusWorld:remove(id) end

--- Returns the type name of this object.
function LStimulusWorld:type() end

--- Returns true if this object is of the given type.
---@param name any
function LStimulusWorld:typeOf(name) end

--- Advances the simulation by one time step.
---@param dt any
function LStimulusWorld:update(dt) end

--- Lua wrapper for [`crate::ai::strategy::StrategyAI`].
---@class LStrategyAI
LStrategyAI = {}

--- Returns or performs active goal.
function LStrategyAI:activeGoal() end

--- Adds a strategic goal with priority score to the planner for future evaluation.
---@param name any
function LStrategyAI:addGoal(name) end

--- Adds a string tag to the strategy AI instance for goal filtering and categorization.
---@param tag any
function LStrategyAI:addTag(tag) end

--- Returns or performs force evaluate.
---@param scorer_fn any
function LStrategyAI:forceEvaluate(scorer_fn) end

--- Removes the specified tag.
---@param tag any
function LStrategyAI:removeTag(tag) end

--- Returns or performs time until next.
function LStrategyAI:timeUntilNext() end

--- Returns the type name of this object.
function LStrategyAI:type() end

--- Returns true if this object is of the given type.
---@param name any
function LStrategyAI:typeOf(name) end

--- Advances the simulation by one time step.
---@param dt any
---@param scorer_fn any
function LStrategyAI:update(dt, scorer_fn) end

--- Lua wrapper for [`crate::ai::traits::TraitProfile`].
---@class LTraitProfile
LTraitProfile = {}

--- Adds a named modifier that adjusts the trait value by a delta.
---@param trait_name any
---@param delta any
---@param duration? any
---@param source any
function LTraitProfile:addModifier(trait_name, delta, duration, source) end

--- Returns or performs archetype.
function LTraitProfile:archetype() end

--- Returns the current float value of this emotion dimension.
---@param name any
function LTraitProfile:get(name) end

--- Returns the unmodified base value of this trait before modifiers.
---@param name any
function LTraitProfile:getBase(name) end

--- Returns true if a item is present.
---@param name any
function LTraitProfile:has(name) end

--- Removes the specified modifiers.
---@param source any
function LTraitProfile:removeModifiers(source) end

--- Sets the base value of this trait, replacing any previous base.
---@param name any
---@param value any
function LTraitProfile:set(name, value) end

--- Returns or performs trait count.
function LTraitProfile:traitCount() end

--- Returns the type name of this object.
function LTraitProfile:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTraitProfile:typeOf(name) end

--- Advances the simulation by one time step.
---@param dt any
function LTraitProfile:update(dt) end

--- Lua-side wrapper around a [`UtilityAI`].
---@class LUtilityAI
LUtilityAI = {}

--- Adds a scored action with optional momentum weight.
---@param name any
---@param scorer_fn any
---@param weight? any
function LUtilityAI:addAction(name, scorer_fn, weight) end

--- Adds a multi-axis consideration to a named action.
function LUtilityAI:addConsideration() end

--- Evaluates all actions and returns the best action name, or nil.
function LUtilityAI:evaluate() end

--- Returns the number of registered actions.
function LUtilityAI:getActionCount() end

--- Returns the name of the last chosen action, or nil.
function LUtilityAI:getLastAction() end

--- Returns the type name of this object.
function LUtilityAI:type() end

--- Returns true if this object is of the given type.
---@param name any
function LUtilityAI:typeOf(name) end

--- Creates a new AI pacing director with default config.
lurek.ai.newAIDirector = function() end

--- Creates a new AI LOD controller with default 3-tier config.
lurek.ai.newAILod = function() end

--- Creates a BT action leaf with a Lua callback.
---@param callback any
lurek.ai.newAction = function(callback) end

--- Creates a new multi-armed bandit.
---@param arm_count any
---@param strategy any
---@param epsilon any
---@param seed any
lurek.ai.newBandit = function(arm_count, strategy, epsilon, seed) end

--- Creates a new behavior tree.
lurek.ai.newBehaviorTree = function() end

--- Creates a new standalone blackboard.
lurek.ai.newBlackboard = function() end

--- Creates an RTS-style command queue.
lurek.ai.newCommandQueue = function() end

--- Creates a BT condition leaf with a Lua predicate.
---@param callback any
lurek.ai.newCondition = function(callback) end

--- Creates a new context steering controller.
---@param slots any
lurek.ai.newContextSteering = function(slots) end

--- Creates a new affective emotion model.
lurek.ai.newEmotionModel = function() end

--- Creates a new GOAP planning solver.
lurek.ai.newGOAPPlanner = function() end

--- Creates a new genetic algorithm.
---@param pop_size any
---@param gene_count any
---@param seed any
lurek.ai.newGeneticAlgorithm = function(pop_size, gene_count, seed) end

--- Creates a BT Guard decorator. The predicate is evaluated before each tick;
---@param predicate any
---@param child_ud any
lurek.ai.newGuard = function(predicate, child_ud) end

--- Creates a new Hierarchical Task Network domain.
lurek.ai.newHTNDomain = function() end

--- Creates a multi-layer influence map grid.
---@param w any
---@param h any
---@param cs any
lurek.ai.newInfluenceMap = function(w, h, cs) end

--- Creates a BT inverter decorator.
lurek.ai.newInverter = function() end

--- Creates a new Monte Carlo Tree Search engine.
---@param iters any
---@param uct_c any
---@param depth any
---@param seed any
lurek.ai.newMCTSEngine = function(iters, uct_c, depth, seed) end

--- Creates a new motivational need system.
lurek.ai.newNeedSystem = function() end

--- Creates a new feedforward neural network (inference only).
lurek.ai.newNeuralNet = function() end

--- Creates a neuroevolution trainer (GA for neural network weights).
---@param layer_spec any
---@param pop_size any
---@param seed any
lurek.ai.newNeuroevolution = function(layer_spec, pop_size, seed) end

--- Creates a new ORCA crowd avoidance solver.
---@param time_horizon any
lurek.ai.newORCASolver = function(time_horizon) end

--- Creates a BT parallel node with optional policies.
---@param sp? any
---@param fp? any
lurek.ai.newParallel = function(sp, fp) end

--- Creates a tabular Q-learner.
---@param sc any
---@param ac any
lurek.ai.newQLearner = function(sc, ac) end

--- Creates a BT repeater decorator.
---@param count? any
lurek.ai.newRepeater = function(count) end

--- Creates a BT selector node.
lurek.ai.newSelector = function() end

--- Creates a BT sequence node.
lurek.ai.newSequence = function() end

--- Creates a named squad for formation positioning.
---@param name any
lurek.ai.newSquad = function(name) end

--- Creates a new finite state machine.
lurek.ai.newStateMachine = function() end

--- Creates a new steering behavior manager.
lurek.ai.newSteeringManager = function() end

--- Creates a new stimulus perception world.
lurek.ai.newStimulusWorld = function() end

--- Creates a new throttled strategy AI.
---@param update_interval any
lurek.ai.newStrategyAI = function(update_interval) end

--- Creates a BT succeeder decorator.
lurek.ai.newSucceeder = function() end

--- Creates a new personality trait profile.
lurek.ai.newTraitProfile = function() end

--- Creates a new utility AI evaluator.
lurek.ai.newUtilityAI = function() end

--- Creates a new AI world container.
lurek.ai.newWorld = function() end

---@class lurek.animation
lurek.animation = {}

--- Lua-side wrapper around an [`AnimCurve`].
---@class LAnimCurve
LAnimCurve = {}

--- Inserts a keyframe at the given time. If a keyframe at the same time already
---@param t any
---@param v any
function LAnimCurve:addKeyframe(t, v) end

--- Removes all keyframes from this animation curve, resetting it to empty.
function LAnimCurve:clear() end

--- Returns the interpolated value at the given time using the curve's easing.
---@param t any
function LAnimCurve:eval(t) end

--- Returns the number of keyframes currently stored.
function LAnimCurve:keyframeCount() end

--- Set a custom Lua easing function for this curve.
---@param func any
function LAnimCurve:setCustomEasing(func) end

--- Sets the easing kind applied between all keyframe segments.
---@param mode any
function LAnimCurve:setEasing(mode) end

--- Returns the type name of this object.
function LAnimCurve:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAnimCurve:typeOf(name) end

--- Lua-side wrapper around an [`AnimStateMachine`] FSM controller.
---@class LAnimStateMachine
LAnimStateMachine = {}

--- Registers a new named state that plays a clip from the embedded animation.
---@param name any
---@param clip any
---@param looping any
function LAnimStateMachine:addState(name, clip, looping) end

--- Adds a conditional transition between two states.
---@param from_state any
---@param to_state any
---@param condition any
function LAnimStateMachine:addTransition(from_state, to_state, condition) end

--- Immediately jumps to the named state, bypassing transition conditions.
---@param name any
function LAnimStateMachine:forceState(name) end

--- Returns the source quad for the current animation frame, or nil.
function LAnimStateMachine:getQuad() end

--- Returns the name of the currently active state.
function LAnimStateMachine:getState() end

--- Sets an FSM parameter value (number, boolean, or integer supported).
---@param name any
---@param value any
function LAnimStateMachine:setParam(name, value) end

--- Returns the type name of this object.
function LAnimStateMachine:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAnimStateMachine:typeOf(name) end

--- Advances the FSM by `dt` seconds, evaluating transitions.
---@param dt any
function LAnimStateMachine:update(dt) end

--- Lua-side wrapper around an [`AnimSyncGroup`].
---@class LAnimSyncGroup
LAnimSyncGroup = {}

--- Adds an animation handle to the group.
---@param handle any
function LAnimSyncGroup:add(handle) end

--- Removes all animation handles from the group.
function LAnimSyncGroup:clear() end

--- Returns the number of animations currently in the group.
function LAnimSyncGroup:memberCount() end

--- Removes an animation handle from the group.
---@param handle any
function LAnimSyncGroup:remove(handle) end

--- Returns the type name of this object.
function LAnimSyncGroup:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAnimSyncGroup:typeOf(name) end

--- Lua-side wrapper around an [`Animation`] controller.
---@class LAnimation
LAnimation = {}

--- Adds a named clip from explicit frame indices.
---@param name any
---@param indices_tbl any
---@param fps any
---@param looping any
function LAnimation:addClip(name, indices_tbl, fps, looping) end

--- Adds a named clip sliced from a sprite-sheet grid.
function LAnimation:addClipFromGrid() end

--- Adds a single frame to the frame pool by source rectangle.
---@param x any
---@param y any
---@param w any
---@param h any
function LAnimation:addFrame(x, y, w, h) end

--- Slices a sprite-sheet grid into frames and appends them.
---@param tw any
---@param th any
---@param fw any
---@param fh any
---@param start any
---@param count any
function LAnimation:addFramesFromGrid(tw, th, fw, fh, start, count) end

--- Begins a smooth crossfade from the current clip to a new named clip.
---@param clip_name any
---@param duration any
function LAnimation:crossfade(clip_name, duration) end

--- Renders the current animation frame into a new ImageData (white bg, blue frame rect).
---@param w any
---@param h any
function LAnimation:drawToImage(w, h) end

--- Returns the two quads and blend factor during a crossfade, or nil when not blending.
function LAnimation:getBlendState() end

--- Returns the name of the currently playing clip, or nil.
function LAnimation:getClip() end

--- Returns the number of registered clips.
function LAnimation:getClipCount() end

--- Returns the current position within the active clip (0-based).
function LAnimation:getCurrentFrame() end

--- Returns the total number of frames in the frame pool.
function LAnimation:getFrameCount() end

--- Returns the source quad (x, y, w, h) for the current frame, or nil.
function LAnimation:getQuad() end

--- Returns the playback speed multiplier.
function LAnimation:getSpeed() end

--- Returns true if the current clip is set to loop.
function LAnimation:isLooping() end

--- Returns true if a clip is currently playing.
function LAnimation:isPlaying() end

--- Pauses playback at the current frame.
function LAnimation:pause() end

--- Starts playback of the named clip.
---@param name any
function LAnimation:play(name) end

--- Drains and returns all pending animation events as a table.
function LAnimation:pollEvents() end

--- Resumes playback from the current frame.
function LAnimation:resume() end

--- Sets the playback position within the current clip.
---@param index any
function LAnimation:setFrame(index) end

--- Sets the playback speed multiplier.
---@param speed any
function LAnimation:setSpeed(speed) end

--- Stops playback and resets to frame 0.
function LAnimation:stop() end

--- Returns the type name of this object.
function LAnimation:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAnimation:typeOf(name) end

--- Advances the animation by dt seconds.
---@param dt any
function LAnimation:update(dt) end

--- Lua-side wrapper around a [`BlendLayerSet`] blend layer compositor.
---@class LBlendLayerSet
LBlendLayerSet = {}

--- Appends a new blend layer.
---@param name any
---@param clip_name any
---@param weight any
---@param bones? any
function LBlendLayerSet:addLayer(name, clip_name, weight, bones) end

--- Returns the blend weight of a named layer, or nil if not found.
---@param name any
function LBlendLayerSet:getWeight(name) end

--- Returns the number of blend layers.
function LBlendLayerSet:len() end

--- Returns an ordered array of layer info tables: {name, clip_name, weight, bones}.
function LBlendLayerSet:listLayers() end

--- Removes a blend layer by name.
---@param name any
function LBlendLayerSet:removeLayer(name) end

--- Replaces the bone mask of a layer.
---@param name any
---@param bones any
function LBlendLayerSet:setMask(name, bones) end

--- Sets the blend weight of a named layer (clamped to [0, 1]).
---@param name any
---@param weight any
function LBlendLayerSet:setWeight(name, weight) end

--- Returns the type name of this object.
function LBlendLayerSet:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBlendLayerSet:typeOf(name) end

--- Parses an Aseprite JSON export string and builds an Animation with clips and frames.
---@param json_str any
lurek.animation.fromAseprite = function(json_str) end

--- Creates a new, empty Animation controller.
lurek.animation.new = function() end

--- Creates a new empty [`BlendLayerSet`] for compositing multiple animation clips.
lurek.animation.newBlendLayerSet = function() end

--- Creates a new empty [`AnimCurve`] with linear interpolation.
lurek.animation.newCurve = function() end

--- Creates an animation FSM from an Animation controller and an initial state name.
---@param anim_ud any
---@param initial any
lurek.animation.newStateMachine = function(anim_ud, initial) end

--- Creates a new empty [`AnimSyncGroup`].
lurek.animation.newSyncGroup = function() end

---@class lurek.audio
lurek.audio = {}

--- Lua-side wrapper for an audio bus resource.
---@class LBus
LBus = {}

--- Removes the ducking target from this bus, restoring the target bus
function LBus:clearDuck() end

--- Returns the unique name string assigned to this audio bus.
function LBus:getName() end

--- Returns the average peak amplitude of all sources currently on this bus.
function LBus:getPeak() end

--- Returns the bus pitch multiplier.
function LBus:getPitch() end

--- Returns the current volume multiplier applied to all sources on this bus.
function LBus:getVolume() end

--- Returns true if this bus is paused.
function LBus:isPaused() end

--- Pauses all sources on this bus.
function LBus:pause() end

--- Resumes all sources on this bus.
function LBus:resume() end

--- Configures this bus to duck (lower the volume of) another bus when
---@param target_name any
---@param duck_vol any
function LBus:setDuckTarget(target_name, duck_vol) end

--- Sets the pitch multiplier for all sources on this bus.
---@param pitch any
function LBus:setPitch(pitch) end

--- Sets the volume for all sources on this bus.
---@param vol any
function LBus:setVolume(vol) end

--- Returns the type name of this object.
function LBus:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBus:typeOf(name) end

--- Lua-side wrapper for a streaming audio decoder.
---@class LDecoder
LDecoder = {}

--- Decodes the next chunk of samples, or nil at EOF.
function LDecoder:decode() end

--- Returns the per-sample bit depth of this decoded audio stream.
function LDecoder:getBitDepth() end

--- Returns the number of audio channels.
function LDecoder:getChannelCount() end

--- Returns the total duration in seconds.
function LDecoder:getDuration() end

--- Returns the sample rate in Hz.
function LDecoder:getSampleRate() end

--- Returns true if seeking is supported.
function LDecoder:isSeekable() end

--- Releases the decoder (no-op).
function LDecoder:release() end

--- Rewinds to the beginning.
function LDecoder:rewind() end

--- Seeks to a time offset in seconds.
---@param offset any
function LDecoder:seek(offset) end

--- Returns the current position in seconds.
function LDecoder:tell() end

--- Returns the type name of this object.
function LDecoder:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDecoder:typeOf(name) end

--- Lua-side wrapper for the MIDI player.
---@class LMidiPlayer
LMidiPlayer = {}

--- Returns the assigned bus, or nil.
function LMidiPlayer:getBus() end

--- Returns the number of MIDI channels.
function LMidiPlayer:getChannelCount() end

--- Returns the GM instrument for a MIDI channel (1-indexed).
---@param ch any
function LMidiPlayer:getChannelInstrument(ch) end

--- Returns the volume for a MIDI channel (1-indexed).
---@param ch any
function LMidiPlayer:getChannelVolume(ch) end

--- Returns the PCM output channel count (1 = mono, 2 = stereo).
function LMidiPlayer:getChannels() end

--- Returns the total MIDI duration in seconds.
function LMidiPlayer:getDuration() end

--- Returns the file path of the loaded MIDI, or nil.
function LMidiPlayer:getFilePath() end

--- Returns the total note count in the MIDI sequence.
function LMidiPlayer:getNoteCount() end

--- Returns the original MIDI file tempo in BPM.
function LMidiPlayer:getOriginalTempo() end

--- Returns the PCM output sample rate in Hz.
function LMidiPlayer:getSampleRate() end

--- Returns the SoundFont file path, or nil (stub).
function LMidiPlayer:getSoundFontPath() end

--- Returns the current tempo in BPM.
function LMidiPlayer:getTempo() end

--- Returns the current tempo scale factor.
function LMidiPlayer:getTempoScale() end

--- Returns the PPQ resolution from the MIDI header.
function LMidiPlayer:getTicksPerBeat() end

--- Returns the number of tracks in the MIDI sequence.
function LMidiPlayer:getTrackCount() end

--- Returns the name of a MIDI track (1-indexed), or nil.
---@param idx any
function LMidiPlayer:getTrackName(idx) end

--- Returns the current MIDI volume.
function LMidiPlayer:getVolume() end

--- Returns true if a MIDI channel is muted (1-indexed).
---@param ch any
function LMidiPlayer:isChannelMuted(ch) end

--- Returns true if a MIDI sequence is loaded.
function LMidiPlayer:isLoaded() end

--- Returns true if looping is enabled.
function LMidiPlayer:isLooping() end

--- Returns true if MIDI playback is paused.
function LMidiPlayer:isPaused() end

--- Returns true if MIDI is currently playing.
function LMidiPlayer:isPlaying() end

--- Returns true if a track is muted (1-indexed).
---@param idx any
function LMidiPlayer:isTrackMuted(idx) end

--- Loads a MIDI file from the given path.
---@param path any
function LMidiPlayer:load(path) end

--- Loads MIDI data from a Lua string.
function LMidiPlayer:loadData() end

--- Pauses the MIDI sequence at the current position; resume with `play()`.
function LMidiPlayer:pause() end

--- Starts or resumes MIDI sequence playback from the current position.
function LMidiPlayer:play() end

--- Seeks to a time position in seconds.
---@param secs any
function LMidiPlayer:seek(secs) end

--- Routes MIDI output through a bus (or nil to clear).
---@param bus_val any
function LMidiPlayer:setBus(bus_val) end

--- Sets the GM instrument for a MIDI channel (1-indexed).
---@param ch any
---@param inst any
function LMidiPlayer:setChannelInstrument(ch, inst) end

--- Mutes or unmutes a MIDI channel (1-indexed).
---@param ch any
---@param muted any
function LMidiPlayer:setChannelMuted(ch, muted) end

--- Sets volume for a MIDI channel (1-indexed).
---@param ch any
---@param vol any
function LMidiPlayer:setChannelVolume(ch, vol) end

--- Sets the PCM output channel count (clamped 1â€“2).
---@param channels any
function LMidiPlayer:setChannels(channels) end

--- Enables or disables looping.
---@param looping any
function LMidiPlayer:setLooping(looping) end

--- Registers a playback-end callback (stub).
---@param cb any
function LMidiPlayer:setOnEnd(cb) end

--- Registers a note-off callback (stub).
---@param cb any
function LMidiPlayer:setOnNoteOff(cb) end

--- Registers a note-on callback (stub).
---@param cb any
function LMidiPlayer:setOnNoteOn(cb) end

--- Sets the PCM output sample rate in Hz (clamped 8000â€“192000).
---@param rate any
function LMidiPlayer:setSampleRate(rate) end

--- Loads a SoundFont file into this player (stub).
---@param path any
function LMidiPlayer:setSoundFont(path) end

--- Sets playback tempo in BPM.
---@param bpm any
function LMidiPlayer:setTempo(bpm) end

--- Sets the tempo scale factor (1.0 = original speed).
---@param scale any
function LMidiPlayer:setTempoScale(scale) end

--- Mutes or unmutes a track (1-indexed).
---@param idx any
---@param muted any
function LMidiPlayer:setTrackMuted(idx, muted) end

--- Sets MIDI playback volume.
---@param vol any
function LMidiPlayer:setVolume(vol) end

--- Solos a MIDI channel (1-indexed).
---@param ch any
function LMidiPlayer:soloChannel(ch) end

--- Stops MIDI playback and resets the playhead to the beginning.
function LMidiPlayer:stop() end

--- Returns the current playback position in seconds.
function LMidiPlayer:tell() end

--- Returns the type name of this object.
function LMidiPlayer:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMidiPlayer:typeOf(name) end

--- Clears solo on all channels.
function LMidiPlayer:unsoloAll() end

--- Reverts to the built-in default SoundFont (stub).
function LMidiPlayer:useDefaultSoundFont() end

--- Decoded PCM audio buffer that can be created from a file or synthesised sample-by-sample.
---@class LSoundData
LSoundData = {}

--- Draws the waveform onto an ImageData buffer.
function LSoundData:drawWaveform() end

--- Returns the bit depth of this audio buffer (typically 16 or 32 bits per sample).
function LSoundData:getBitDepth() end

--- Get the number of channels.
function LSoundData:getChannelCount() end

--- Get the audio duration in seconds.
function LSoundData:getDuration() end

--- Get a specific sample by index.
---@param index any
function LSoundData:getSample(index) end

--- Get the total number of samples.
function LSoundData:getSampleCount() end

--- Returns the sample rate of this audio buffer in Hz (e.g. 44100 or 48000).
function LSoundData:getSampleRate() end

--- Set a specific sample by index.
---@param index any
---@param value any
function LSoundData:setSample(index, value) end

--- Lua-side wrapper for a polyphonic [`crate::audio::SoundPool`].
---@class LSoundPool
LSoundPool = {}

--- Returns the total number of voices in this pool.
function LSoundPool:getVoiceCount() end

--- Plays the next available voice and returns its SoundKey as an integer.
function LSoundPool:play() end

--- Releases all voices from the mixer and invalidates this pool.
function LSoundPool:release() end

--- Routes all voices through the named bus.
---@param name any
function LSoundPool:setBus(name) end

--- Sets the volume for all voices in this pool.
---@param vol any
function LSoundPool:setVolume(vol) end

--- Stops all voices in this pool.
function LSoundPool:stopAll() end

--- Returns the type name of this object.
function LSoundPool:type() end

--- Returns true if the type name matches.
---@param name any
function LSoundPool:typeOf(name) end

--- Lua-side wrapper for an audio source resource.
---@class LSource
LSource = {}

--- Removes any active filter from this source.
function LSource:clearFilter() end

--- Creates an independent copy of this source.
function LSource:clone() end

--- Fades in from silence over the given duration in seconds.
---@param dur any
function LSource:fadeIn(dur) end

--- Returns the total duration in seconds.
function LSource:getDuration() end

--- Returns the current fade-in duration in seconds.
function LSource:getFadeIn() end

--- Returns the high-pass filter cutoff frequency.
function LSource:getHighpass() end

--- Returns the low-pass filter cutoff frequency.
function LSource:getLowpass() end

--- Returns the current stereo panning value.
function LSource:getPan() end

--- Returns the current pitch multiplier.
function LSource:getPitch() end

--- Returns the source type ("static" or "stream").
function LSource:getType() end

--- Returns the current volume multiplier.
function LSource:getVolume() end

--- Returns true if looping is enabled.
function LSource:isLooping() end

--- Returns true if playback is paused.
function LSource:isPaused() end

--- Returns true if currently playing.
function LSource:isPlaying() end

--- Returns true if playback has stopped.
function LSource:isStopped() end

--- Pauses playback at the current position.
function LSource:pause() end

--- Starts or resumes playback.
function LSource:play() end

--- Resumes playback from the paused position.
function LSource:resume() end

--- Seeks to a time position in seconds.
---@param pos any
function LSource:seek(pos) end

--- Applies a high-pass filter at the given cutoff frequency.
---@param cutoff_hz any
function LSource:setHighpass(cutoff_hz) end

--- Enables or disables looping playback.
---@param looping any
function LSource:setLooping(looping) end

--- Applies a low-pass filter at the given cutoff frequency.
---@param cutoff_hz any
function LSource:setLowpass(cutoff_hz) end

--- Sets stereo panning (-1.0 left to 1.0 right).
---@param pan any
function LSource:setPan(pan) end

--- Sets the pitch multiplier (1.0 = normal).
---@param pitch any
function LSource:setPitch(pitch) end

--- Sets playback volume (0.0 = silent, 1.0 = full).
---@param vol any
function LSource:setVolume(vol) end

--- Stops playback and resets seek position.
function LSource:stop() end

--- Returns the current playback position in seconds.
function LSource:tell() end

--- Returns the type name of this object.
function LSource:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSource:typeOf(name) end

--- Adds a DSP effect to a bus.
---@param bus_name any
---@param effect_type_str any
---@param params? any
lurek.audio.add_effect = function(bus_name, effect_type_str, params) end

--- Applies a bandpass filter (high-pass then low-pass) to a SoundData in-place.
---@param sd_ud any
---@param low_hz any
---@param high_hz any
lurek.audio.applyBandpass = function(sd_ud, low_hz, high_hz) end

--- Scales every sample by gain (clamped to [-1, 1]).
---@param sd_ud any
---@param gain any
lurek.audio.applyGain = function(sd_ud, gain) end

--- Applies a first-order IIR high-pass filter to a SoundData in-place.
---@param sd_ud any
---@param cutoff_hz any
lurek.audio.applyHighpass = function(sd_ud, cutoff_hz) end

--- Applies a first-order IIR low-pass filter to a SoundData in-place.
---@param sd_ud any
---@param cutoff_hz any
lurek.audio.applyLowpass = function(sd_ud, cutoff_hz) end

--- Removes any active filter from a source.
---@param id_val any
lurek.audio.clearFilter = function(id_val) end

--- Unloads the active SoundFont.
lurek.audio.clearMidiSoundFont = function() end

--- Clears any random pitch range on a source, restoring fixed pitch.
---@param src_ud any
lurek.audio.clearRandomPitch = function(src_ud) end

--- Creates an independent copy of a source.
---@param id_val any
lurek.audio.clone = function(id_val) end

--- Creates a bus by name (functional style).
---@param name any
---@param parent_name? any
lurek.audio.create_bus = function(name, parent_name) end

--- Crossfades from one source to another over a duration.
---@param from_ud any
---@param to_ud any
---@param duration any
lurek.audio.crossfade = function(from_ud, to_ud, duration) end

--- Fades a source in from silence over the given duration.
---@param id_val any
---@param dur any
lurek.audio.fadeIn = function(id_val, dur) end

--- Returns the number of currently playing sources.
lurek.audio.getActiveSourceCount = function() end

--- Returns the peak signal level of the named bus (stub: always 0.0).
---@param bus_name any
lurek.audio.getBusPeak = function(bus_name) end

--- Returns the RMS signal level of the named bus (stub: always 0.0).
---@param bus_name any
lurek.audio.getBusRms = function(bus_name) end

--- Returns the current distance model name.
lurek.audio.getDistanceModel = function() end

--- Returns the current Doppler scale.
lurek.audio.getDopplerScale = function() end

--- Returns the total duration of a source in seconds.
---@param id_val any
lurek.audio.getDuration = function(id_val) end

--- Returns the fade-in duration of a source.
---@param id_val any
lurek.audio.getFadeIn = function(id_val) end

--- Returns the free buffer slots in a queueable source.
---@param qsource_id any
lurek.audio.getFreeBufferCount = function(qsource_id) end

--- Returns the high-pass filter cutoff of a source.
---@param id_val any
lurek.audio.getHighpass = function(id_val) end

--- Returns the 3D listener position (x, y, z).
lurek.audio.getListener = function() end

--- Returns the 2D listener position (x, y).
lurek.audio.getListener2D = function() end

--- Returns the low-pass filter cutoff of a source.
---@param id_val any
lurek.audio.getLowpass = function(id_val) end

--- Returns the global master volume.
lurek.audio.getMasterVolume = function() end

--- Returns the maximum number of simultaneous sources.
lurek.audio.getMaxSources = function() end

--- Returns the stored master peak meter level.
lurek.audio.getMeter = function() end

--- Returns the 6-component orientation of a source.
---@param id_val any
lurek.audio.getOrientation = function(id_val) end

--- Returns the source stereo panning.
---@param id_val any
lurek.audio.getPan = function(id_val) end

--- Returns the source pitch multiplier.
---@param id_val any
lurek.audio.getPitch = function(id_val) end

--- Returns the current audio output device name.
lurek.audio.getPlaybackDevice = function() end

--- Returns a table of available audio output device names.
lurek.audio.getPlaybackDevices = function() end

--- Returns the 3D position of a source (x, y, z).
---@param id_val any
lurek.audio.getPosition = function(id_val) end

--- Returns the bus a source is assigned to, or nil.
---@param id_val any
lurek.audio.getSourceBus = function(id_val) end

--- Returns the total number of registered sources.
lurek.audio.getSourceCount = function() end

--- Returns the type string ("static" or "stream") of a source.
---@param id_val any
lurek.audio.getSourceType = function(id_val) end

--- Returns the current stereo width for a source.
---@param src_ud any
lurek.audio.getStereoWidth = function(src_ud) end

--- Returns the velocity of a source (x, y, z).
---@param id_val any
lurek.audio.getVelocity = function(id_val) end

--- Returns the source volume.
---@param id_val any
lurek.audio.getVolume = function(id_val) end

--- Returns true if a SoundFont is loaded.
lurek.audio.hasMidiSoundFont = function() end

--- Returns true if looping is enabled.
---@param id_val any
lurek.audio.isLooping = function(id_val) end

--- Returns true if the source is paused.
---@param id_val any
lurek.audio.isPaused = function(id_val) end

--- Returns true if the source is playing.
---@param id_val any
lurek.audio.isPlaying = function(id_val) end

--- Returns true if the source is stopped.
---@param id_val any
lurek.audio.isStopped = function(id_val) end

--- Additively mixes another SoundData into the destination in-place.
---@param dest_ud any
---@param src_ud any
lurek.audio.mixInto = function(dest_ud, src_ud) end

--- Creates a named audio bus for grouping sources.
---@param name any
lurek.audio.newBus = function(name) end

--- Creates a streaming audio decoder.
---@param source any
---@param buffersize? any
lurek.audio.newDecoder = function(source, buffersize) end

--- Creates a MIDI player, optionally loading a file.
---@param path? any
lurek.audio.newMidiPlayer = function(path) end

--- Creates a polyphonic sound pool for the given file with N simultaneous voices.
---@param file_path any
---@param voice_count any
lurek.audio.newPool = function(file_path, voice_count) end

--- Creates a queueable source for manual PCM buffering.
lurek.audio.newQueueableSource = function() end

--- Generate a mono sawtooth-wave SoundData buffer.
---@param freq any
---@param duration any
---@param sample_rate any
---@param amplitude any
lurek.audio.newSawtoothWave = function(freq, duration, sample_rate, amplitude) end

--- Generate a mono sine-wave SoundData buffer.
---@param freq any
---@param duration any
---@param sample_rate any
---@param amplitude any
lurek.audio.newSineWave = function(freq, duration, sample_rate, amplitude) end

--- Creates a SoundData from a file or as a silent buffer.
---@param ... any
lurek.audio.newSoundData = function(...) end

--- Loads an audio file and returns a Source handle.
---@param ... any
lurek.audio.newSource = function(...) end

--- Generate a mono square-wave SoundData buffer.
---@param freq any
---@param duration any
---@param sample_rate any
---@param amplitude any
lurek.audio.newSquareWave = function(freq, duration, sample_rate, amplitude) end

--- Generate a mono triangle-wave SoundData buffer.
---@param freq any
---@param duration any
---@param sample_rate any
---@param amplitude any
lurek.audio.newTriangleWave = function(freq, duration, sample_rate, amplitude) end

--- Generate a reproducible white-noise SoundData buffer.
---@param duration any
---@param sample_rate any
---@param amplitude any
---@param seed any
lurek.audio.newWhiteNoise = function(duration, sample_rate, amplitude, seed) end

--- Normalizes a WAV file peak amplitude to target_level and writes output.
---@param input any
---@param output any
---@param target any
lurek.audio.normalizeFile = function(input, output, target) end

--- Pauses playback at the current position.
---@param id_val any
lurek.audio.pause = function(id_val) end

--- Pauses all currently playing sources.
lurek.audio.pauseAll = function() end

--- Plays a source, with optional bus routing via options table.
---@param id_val any
---@param options? any
lurek.audio.play = function(id_val, options) end

--- Plays the source in a continuous loop.
---@param id_val any
lurek.audio.playLooping = function(id_val) end

--- Starts playback of a queueable source.
---@param qsource_id any
lurek.audio.playQueueable = function(qsource_id) end

--- Applies a DSP effect chain to a WAV file and writes output.
---@param input any
---@param output any
---@param effects_tbl any
lurek.audio.processOffline = function(input, output, effects_tbl) end

--- Pushes a SoundData buffer into a queueable source.
---@param qsource_id any
---@param sd any
lurek.audio.queueSource = function(qsource_id, sd) end

--- Releases a source and frees its memory.
---@param id_val any
lurek.audio.release = function(id_val) end

--- Removes a DSP effect from a bus.
---@param bus_name any
---@param effect_id any
lurek.audio.remove_effect = function(bus_name, effect_id) end

--- Resumes playback from pause.
---@param id_val any
lurek.audio.resume = function(id_val) end

--- Resumes all paused sources.
lurek.audio.resumeAll = function() end

--- Saves a SoundData as a 16-bit PCM WAV file at the given path.
---@param sd_ud any
---@param filename any
lurek.audio.saveWAV = function(sd_ud, filename) end

--- Seeks to a time position in seconds.
---@param id_val any
---@param pos any
lurek.audio.seek = function(id_val, pos) end

--- Sets the distance attenuation model.
---@param model any
lurek.audio.setDistanceModel = function(model) end

--- Sets the global Doppler effect scale.
---@param scale any
lurek.audio.setDopplerScale = function(scale) end

--- Applies a high-pass filter to a source.
---@param id_val any
---@param cutoff_hz any
lurek.audio.setHighpass = function(id_val, cutoff_hz) end

--- Sets the 3D listener position.
---@param x any
---@param y any
---@param z? any
lurek.audio.setListener = function(x, y, z) end

--- Sets the 2D listener position for spatial audio.
---@param x any
---@param y any
lurek.audio.setListener2D = function(x, y) end

--- Enables or disables looping.
---@param id_val any
---@param looping any
lurek.audio.setLooping = function(id_val, looping) end

--- Applies a low-pass filter to a source.
---@param id_val any
---@param cutoff_hz any
lurek.audio.setLowpass = function(id_val, cutoff_hz) end

--- Sets the global master volume.
---@param vol any
lurek.audio.setMasterVolume = function(vol) end

--- Sets the master peak meter level (0.0â€“1.0).
---@param level any
lurek.audio.setMeter = function(level) end

--- Sets the global SoundFont for MIDI synthesis.
---@param path any
lurek.audio.setMidiSoundFont = function(path) end

--- Sets the 6-component orientation of a source.
---@param id_val any
---@param fx any
---@param fy any
---@param fz any
---@param ux any
---@param uy any
---@param uz any
lurek.audio.setOrientation = function(id_val, fx, fy, fz, ux, uy, uz) end

--- Sets stereo panning (-1.0 left to 1.0 right).
---@param id_val any
---@param pan any
lurek.audio.setPan = function(id_val, pan) end

--- Sets source pitch multiplier.
---@param id_val any
---@param pitch any
lurek.audio.setPitch = function(id_val, pitch) end

--- Selects an audio output device by name.
---@param name any
lurek.audio.setPlaybackDevice = function(name) end

--- Sets the 3D position of a source.
---@param id_val any
---@param x any
---@param y any
---@param z? any
lurek.audio.setPosition = function(id_val, x, y, z) end

--- Sets a random pitch range applied each time the source is played.
---@param src_ud any
---@param min any
---@param max any
lurek.audio.setRandomPitch = function(src_ud, min, max) end

--- Assigns a source to a bus.
---@param id_val any
---@param bus_val any
lurek.audio.setSourceBus = function(id_val, bus_val) end

--- Sets the stereo width multiplier for a source (1.0 = normal, 0.0 = mono).
---@param src_ud any
---@param width any
lurek.audio.setStereoWidth = function(src_ud, width) end

--- Sets the velocity of a source for Doppler.
---@param id_val any
---@param x any
---@param y any
---@param z? any
lurek.audio.setVelocity = function(id_val, x, y, z) end

--- Sets source playback volume.
---@param id_val any
---@param vol any
lurek.audio.setVolume = function(id_val, vol) end

--- Sets a bus volume by name.
---@param name any
---@param volume any
lurek.audio.set_bus_volume = function(name, volume) end

--- Sets a parameter on a DSP effect.
---@param bus_name any
---@param effect_id any
---@param param_name any
---@param value any
lurek.audio.set_effect_param = function(bus_name, effect_id, param_name, value) end

--- Renders a time-frequency spectrogram of a WAV file to a PNG image.
---@param input any
---@param output any
---@param width any
---@param height any
lurek.audio.spectrogramToPng = function(input, output, width, height) end

--- Stops playback and resets seek position.
---@param id_val any
lurek.audio.stop = function(id_val) end

--- Stops all currently playing sources.
lurek.audio.stopAll = function() end

--- Stops a queueable source and drains its buffers.
---@param qsource_id any
lurek.audio.stopQueueable = function(qsource_id) end

--- Returns the current playback position in seconds.
---@param id_val any
lurek.audio.tell = function(id_val) end

--- Renders the waveform of a WAV file to a PNG image.
---@param input any
---@param output any
---@param width any
---@param height any
lurek.audio.waveformToPng = function(input, output, width, height) end

---@class lurek.simulator
lurek.simulator = {}

--- Returns the name of the active script, or nil if idle.
lurek.simulator.getCurrentScript = function() end

--- Returns the index of the next step to be dispatched.
lurek.simulator.getCurrentStep = function() end

--- Returns seconds elapsed since playback started.
lurek.simulator.getElapsedTime = function() end

--- Returns the current playback speed multiplier (default 1.0).
lurek.simulator.getPlaybackSpeed = function() end

--- Returns an array of all registered script names.
lurek.simulator.getScripts = function() end

--- Returns the total number of steps in the active script.
lurek.simulator.getStepCount = function() end

--- Returns the step limit for the named script, or nil if not found.
---@param name any
lurek.simulator.getStepLimit = function(name) end

--- Returns true if a macro with the given name has been saved.
---@param name any
lurek.simulator.hasMacro = function(name) end

--- Returns true if a script with the given name is registered.
---@param name any
lurek.simulator.hasScript = function(name) end

--- Returns true if all steps in the active script have been dispatched.
lurek.simulator.isComplete = function() end

--- Returns whether the highlight overlay hint is active.
lurek.simulator.isHighlightMode = function() end

--- Returns true if playback is currently paused.
lurek.simulator.isPaused = function() end

--- Returns true if the simulator is actively playing a script.
lurek.simulator.isRunning = function() end

--- Returns an array of all saved macro names.
lurek.simulator.listMacros = function() end

--- Loads a named script from a Lua data table containing a steps array.
---@param name any
---@param data any
lurek.simulator.load = function(name, data) end

--- Parses a TOML string and registers it as a named script.
---@param name any
---@param toml_str any
lurek.simulator.loadFromToml = function(name, toml_str) end

--- Pauses playback at the current step position.
lurek.simulator.pause = function() end

--- Loads and starts playback of a previously saved macro.
---@param name any
lurek.simulator.playMacro = function(name) end

--- Resumes playback from a paused position.
lurek.simulator.resume = function() end

--- Saves a currently-loaded script under a macro name for fast replay.
---@param macro_name any
---@param script_name any
lurek.simulator.saveMacro = function(macro_name, script_name) end

--- Enables or disables the highlight overlay hint.
---@param enable any
lurek.simulator.setHighlightMode = function(enable) end

--- Sets the dt multiplier for script playback (0.5 = half speed, 2.0 = double).
---@param factor any
lurek.simulator.setPlaybackSpeed = function(factor) end

--- Sets the step limit for the named script (clamped to 1..MAX_STEPS).
---@param name any
---@param n any
lurek.simulator.setStepLimit = function(name, n) end

--- Starts playback of the named script from the beginning.
---@param name any
lurek.simulator.start = function(name) end

--- Stops playback and resets the simulator to idle.
lurek.simulator.stop = function() end

--- Removes a loaded script by name, returning true if it existed.
---@param name any
lurek.simulator.unload = function(name) end

--- Advances the playback clock by `dt` seconds, dispatching due steps.
---@param dt any
lurek.simulator.update = function(dt) end

--- Pauses playback advancement until predicate() returns true or timeout seconds elapse.
---@param predicate any
---@param timeout any
lurek.simulator.waitUntil = function(predicate, timeout) end

---@class lurek.camera
lurek.camera = {}

--- Lua-side wrapper around a [`Camera2D`] instance.
---@class LCamera
LCamera = {}

--- Applies this camera's transform to the render stack.
---@return nil No return value.
function LCamera:apply() end

--- Alias for `apply()`.
---@return nil No return value.
function LCamera:attach() end

--- Removes all parallax factor overrides, resetting every layer to the default factor of 1.0 (no parallax).
---@return nil No return value.
function LCamera:clearParallaxFactors() end

--- Clears the follow target so the camera stops tracking any position.
---@return nil No return value.
function LCamera:clearTarget() end

--- Alias for `reset()`.
---@return nil No return value.
function LCamera:detach() end

--- Animates the camera along a sequence of world-space waypoints over the given duration (seconds).
---@param points table Value for points.
---@param duration number Value for duration.
---@return nil No return value.
function LCamera:followPath(points, duration) end

--- Returns the current world-space x/y offset contributed by the sway and shake effects.
---@return number
---@return number
function LCamera:getEffectOffset() end

--- Returns the current zoom level including contributions from zoom pulse and breathing effects on top of the base zoom factor.
---@return number The total effective zoom level
function LCamera:getEffectiveZoom() end

--- Returns the parallax scroll factor for the named render layer.
---@param layer string The render layer name to query
---@return number The parallax factor (1.0 = moves with camera)
function LCamera:getParallaxFactor(layer) end

--- Returns the camera's current world-space position as two values.
---@return number
---@return number
function LCamera:getPosition() end

--- Returns the camera's current rotation angle in radians.
---@return number The rotation angle in radians
function LCamera:getRotation() end

--- Returns the current screen-space viewport rectangle as four values.
---@return number
---@return number
---@return number
---@return number
function LCamera:getViewport() end

--- Returns the axis-aligned bounding rectangle of the currently visible world area as four values.
---@return number
---@return number
---@return number
---@return number
function LCamera:getVisibleArea() end

--- Returns the camera's current base zoom factor (before any pulse or breathing effect is applied).
---@return number The base zoom multiplier
function LCamera:getZoom() end

--- Returns true if the breathing zoom oscillation is currently active.
---@return boolean True if breathing is active
function LCamera:isBreathing() end

--- Returns true if the sway oscillation effect is currently running.
---@return boolean True if sway is active
function LCamera:isSway() end

--- Instantly snaps the camera to look at the given world-space position.
---@param x number The world X coordinate to center on
---@param y number The world Y coordinate to center on
---@return nil No return value.
function LCamera:lookAt(x, y) end

--- Translates the camera by the given delta in world space.
---@param dx number Horizontal offset in world units
---@param dy number Vertical offset in world units
---@return nil No return value.
function LCamera:move(dx, dy) end

--- Returns the fractional progress `[0, 1]` of the active path, or `1` if no path is running.
---@return number Returned number.
function LCamera:pathProgress() end

--- Removes previously set world-space bounds, allowing the camera to move freely in any direction without clamping.
---@return nil No return value.
function LCamera:removeBounds() end

--- Pops the camera transform from the render stack.
---@return nil No return value.
function LCamera:reset() end

--- Sets world-space rectangular bounds that clamp the camera position.
---@param x number Left edge of the bounding rectangle in world space
---@param y number Top edge of the bounding rectangle in world space
---@param w number Width of the bounding rectangle in world units
---@param h number Height of the bounding rectangle in world units
---@return nil No return value.
function LCamera:setBounds(x, y, w, h) end

--- Sets the dead zone half-extents for camera follow.
---@param w number Half-width of the dead zone in world units
---@param h number Half-height of the dead zone in world units
---@return nil No return value.
function LCamera:setDeadZone(w, h) end

--- Sets the follow interpolation speed for smooth camera tracking.
---@param speed number Interpolation speed (0.0 = instant, higher = faster catch-up)
---@return nil No return value.
function LCamera:setFollowSmooth(speed) end

--- Sets the look-ahead multiplier for predictive camera follow.
---@param mul number Look-ahead multiplier (0.0 = disabled, 1.0 = full velocity offset)
---@return nil No return value.
function LCamera:setLookAhead(mul) end

--- Sets the parallax scroll factor for the named render layer.
---@param layer string Value for layer.
---@param factor number Value for factor.
---@return nil No return value.
function LCamera:setParallaxFactor(layer, factor) end

--- Sets the camera's world-space position to the given coordinates.
---@param x number The X coordinate in world space
---@param y number The Y coordinate in world space
---@return nil No return value.
function LCamera:setPosition(x, y) end

--- Sets the camera rotation angle in radians.
---@param r number The rotation angle in radians
---@return nil No return value.
function LCamera:setRotation(r) end

--- Sets the follow target position in world space.
---@param x number The target X coordinate in world space
---@param y number The target Y coordinate in world space
---@return nil No return value.
function LCamera:setTarget(x, y) end

--- Sets the screen-space viewport rectangle in pixels.
---@param x number Left edge of the viewport in screen pixels
---@param y number Top edge of the viewport in screen pixels
---@param w number Width of the viewport in screen pixels
---@param h number Height of the viewport in screen pixels
---@return nil No return value.
function LCamera:setViewport(x, y, w, h) end

--- Sets the camera's uniform zoom factor.
---@param zoom number The zoom multiplier (1.0 = 100%)
---@return nil No return value.
function LCamera:setZoom(zoom) end

--- Starts a screen-shake effect with the given intensity and duration.
---@param intensity number Maximum random offset in world units
---@param duration number Duration of the shake effect in seconds
---@return nil No return value.
function LCamera:shake(intensity, duration) end

--- Starts a subtle periodic zoom oscillation that gives the camera a "living" feel, as if the viewport is gently breathing.
---@param amplitude number|nil Peak zoom offset from base (default 0.005)
---@param rate number|nil Oscillation rate in cycles per second (default 0.2)
---@return nil No return value.
function LCamera:startBreathing(amplitude, rate) end

--- Starts a sinusoidal x/y offset oscillation for ambient camera motion (e.g.
---@param amplitude_x number Maximum horizontal offset in world units
---@param amplitude_y number Maximum vertical offset in world units
---@param frequency number Oscillation frequency in cycles per second
---@param decay number|nil Decay multiplier applied each second (default 1.0 = no decay)
---@return nil No return value.
function LCamera:startSway(amplitude_x, amplitude_y, frequency, decay) end

--- Stops the active breathing zoom oscillation effect immediately.
---@return nil No return value.
function LCamera:stopBreathing() end

--- Cancels the active camera path animation immediately, leaving the camera at its current position along the path.
---@return nil No return value.
function LCamera:stopPath() end

--- Stops the active sway oscillation effect immediately, resetting the camera's offset back to zero.
---@return nil No return value.
function LCamera:stopSway() end

--- Cancels the active smooth zoom tween immediately, leaving the camera at its current zoom level.
---@return nil No return value.
function LCamera:stopZoom() end

--- Converts world-space coordinates to screen-space pixel coordinates accounting for the camera's position, zoom, rotation, and viewport.
---@param wx number World X coordinate
---@param wy number World Y coordinate
---@return number
---@return number
function LCamera:toScreen(wx, wy) end

--- Converts screen-space pixel coordinates to world-space coordinates accounting for the camera's position, zoom, rotation, and viewport.
---@param sx number Screen X coordinate in pixels
---@param sy number Screen Y coordinate in pixels
---@return number
---@return number
function LCamera:toWorld(sx, sy) end

--- Returns the string type name of this userdata object.
---@return string The type name (e.g. "LScheduler", "LCamera", "LSignal")
function LCamera:type() end

--- Checks whether this object matches the given type name.
---@param name string The type name to check against (e.g. "LScheduler", "Object")
---@return boolean True if this object matches the given type name
function LCamera:typeOf(name) end

--- Advances the camera simulation by `dt` seconds.
---@param dt number Delta time in seconds since the last frame
---@return nil No return value.
function LCamera:update(dt) end

--- Advances the path animation by `dt` seconds and applies the resulting position to the camera.
---@param dt number Delta time in seconds.
---@return boolean Boolean result.
function LCamera:updatePath(dt) end

--- Advances the zoom tween by `dt` seconds and applies the resulting zoom level to the camera.
---@param dt number Delta time in seconds.
---@return boolean Boolean result.
function LCamera:updateZoom(dt) end

--- Triggers a momentary zoom-in effect that decays back to the base zoom level via a sine envelope.
---@param amplitude number Maximum zoom offset at the pulse peak
---@param duration number Total duration of the pulse effect in seconds
---@return nil No return value.
function LCamera:zoomPulse(amplitude, duration) end

--- Smoothly tweens the camera zoom from its current level to `target_zoom` over `duration` seconds.
---@param target_zoom number Value for target_zoom.
---@param duration number Value for duration.
---@return nil No return value.
function LCamera:zoomTo(target_zoom, duration) end

--- Creates a new Camera2D with the given viewport dimensions.
---@param viewport_w number|nil Viewport width in pixels (default 800)
---@param viewport_h number|nil Viewport height in pixels (default 600)
---@return LCamera Returned value.
lurek.camera.new = function(viewport_w, viewport_h) end

--- Creates a new 2D camera with the given viewport dimensions.
---@param viewport_w number|nil Viewport width in pixels (default 800)
---@param viewport_h number|nil Viewport height in pixels (default 600)
---@return LCamera Returned value.
lurek.camera.newCamera = function(viewport_w, viewport_h) end

---@class lurek.compute
lurek.compute = {}

--- Lua-side wrapper around [`NdArray`].
---@class LArray
LArray = {}

--- Element-wise absolute value.
function LArray:abs() end

--- Returns true if all elements are nonzero.
function LArray:all() end

--- Returns true if any element is nonzero.
function LArray:any() end

--- Returns the 1-based flat index of the maximum element.
function LArray:argmax() end

--- Returns the 1-based flat index of the minimum element.
function LArray:argmin() end

--- Bitwise AND of two Int32 arrays.
---@param other any
function LArray:bitwiseAnd(other) end

--- Bitwise left shift of an Int32 array.
---@param amount any
function LArray:bitwiseLShift(amount) end

--- Bitwise NOT of an Int32 array.
function LArray:bitwiseNot() end

--- Bitwise OR of two Int32 arrays.
---@param other any
function LArray:bitwiseOr(other) end

--- Bitwise right shift of an Int32 array.
---@param amount any
function LArray:bitwiseRShift(amount) end

--- Bitwise XOR of two Int32 arrays.
---@param other any
function LArray:bitwiseXor(other) end

--- Clamps each element to the given range.
---@param min any
---@param max any
function LArray:clamp(min, max) end

--- Returns a deep copy of this array.
function LArray:clone() end

--- 1D convolution with a kernel array (full output).
---@param kernel any
function LArray:convolve1d(kernel) end

--- 2D convolution with zero-padding.
---@param kernel any
function LArray:convolve2D(kernel) end

--- 1D cross-correlation with a template array (valid output).
---@param template any
function LArray:correlate1d(template) end

--- Returns the count of nonzero elements.
function LArray:countNonZero() end

--- Population covariance with another 1D array.
---@param other any
function LArray:covariance(other) end

--- Signed 2D cross product with another length-2 array.
---@param other any
function LArray:cross2d(other) end

--- Cumulative sum of all elements (flattened).
function LArray:cumsum() end

--- Discrete difference applied `order` times.
---@param order? any
function LArray:diff(order) end

--- Morphological dilation with a diamond structuring element.
---@param radius any
function LArray:dilate(radius) end

--- Dot product of two 1D arrays.
---@param other any
function LArray:dot(other) end

--- Computes the dominant eigenvalue and its eigenvector using power iteration.
---@param max_iter? any
---@param tol? any
function LArray:eigenPower(max_iter, tol) end

--- Morphological erosion with a diamond structuring element.
---@param radius any
function LArray:erode(radius) end

--- Evaluate a Lua expression string element-wise, returning a new Array.
---@param expr any
function LArray:eval(expr) end

--- Fills all elements with the given value in-place.
---@param val any
function LArray:fill(val) end

--- Flood fill from a 1-based (row, col) with a new value.
---@param row any
---@param col any
---@param val any
function LArray:floodFill(row, col, val) end

--- Returns the element at the given 1-based indices.
---@param ... any
function LArray:get(...) end

--- Returns the element data type name.
function LArray:getDataType() end

--- Returns the number of dimensions.
function LArray:getDimensions() end

--- Extracts a rectangular sub-region (1-based row, col).
---@param row any
---@param col any
---@param rows any
---@param cols any
function LArray:getRegion(row, col, rows, cols) end

--- Returns the shape as a table of dimension sizes.
function LArray:getShape() end

--- Returns the total number of elements.
function LArray:getSize() end

--- Compute a histogram. Returns a table of {lo, hi, count} tables.
---@param bins any
---@param lo? any
---@param hi? any
function LArray:histogram(bins, lo, hi) end

--- Returns false (CPU arrays only).
function LArray:isOnGPU() end

--- Solve AÂ·x = b where this array is A (square [n,n]) and b is a 1D vector.
---@param b any
function LArray:linsolve(b) end

--- Decomposes this square matrix into L and U factors with partial pivoting.
function LArray:luDecompose() end

--- Apply a Lua callback element-wise, returning a new Array of the same shape.
---@param func any
function LArray:map(func) end

--- Matrix multiplication of two 2D arrays.
---@param other any
function LArray:matmul(other) end

--- Maximum of all elements, or along an axis (1-based).
---@param axis? any
function LArray:max(axis) end

--- Mean of all elements, or along an axis (1-based).
---@param axis? any
function LArray:mean(axis) end

--- Minimum of all elements, or along an axis (1-based).
---@param axis? any
function LArray:min(axis) end

--- Returns a new Array with every element negated (multiplied by â’1).
function LArray:neg() end

--- Linearly rescale values to [out_min, out_max].
---@param lo any
---@param hi any
function LArray:normalizeRange(lo, hi) end

--- L2-normalise a 1D vector.
function LArray:normalizeVec() end

--- Outer product of two 1D vectors â†’ 2D array [m, n].
---@param other any
function LArray:outer(other) end

--- Pearson correlation coefficient with another 1D array.
---@param other any
function LArray:pearsonCorr(other) end

--- Compute the p-th percentile (0â€“100).
---@param p any
function LArray:percentile(p) end

--- Raises each element to a scalar exponent.
---@param exp any
function LArray:pow(exp) end

--- Fold the array left-to-right with an accumulator.
---@param func any
---@param init any
function LArray:reduce(func, init) end

--- Returns a new array with the given shape and the same data.
---@param shape any
function LArray:reshape(shape) end

--- Running accumulation — like reduce but returns every intermediate result.
---@param func any
---@param init any
function LArray:scan(func, init) end

--- Sets the element at the given 1-based indices to a value.
---@param ... any
function LArray:set(...) end

--- Copies a source array into this array at the given 1-based position.
---@param row any
---@param col any
---@param source any
function LArray:setRegion(row, col, source) end

--- Apply Sobel edge detection to a 2D array. Returns {gx=Array, gy=Array}.
function LArray:sobel() end

--- Element-wise square root.
function LArray:sqrt() end

--- Sum of all elements, or along an axis (1-based).
---@param axis? any
function LArray:sum(axis) end

--- Returns a mask array with 1.0 where elements >= val, else 0.0.
---@param val any
function LArray:threshold(val) end

--- Returns all elements as a flat table of numbers.
function LArray:toTable() end

--- Apply this 2Ă—2 or 3Ă—3 matrix to an [N,2] points array.
---@param pts any
function LArray:transformPoints(pts) end

--- Returns the transposed 2D array.
function LArray:transpose() end

--- Returns the type name "Array".
function LArray:type() end

--- Returns true when the given name matches "Array" or a parent type.
---@param name any
function LArray:typeOf(name) end

--- Selects elements from this where mask is nonzero, else from other.
---@param mask any
---@param other any
function LArray:where(mask, other) end

--- Standardise values to zero mean and unit variance.
function LArray:zscore() end

--- Creates a 3Ă—3 homogeneous affine matrix.
---@param tx any
---@param ty any
---@param angle_rad any
---@param sx any
---@param sy any
lurek.compute.affine2d = function(tx, ty, angle_rad, sx, sy) end

--- Computes the discrete Fourier transform of a 1D real-valued sample array.
---@param samples any
lurek.compute.fft = function(samples) end

--- Returns the magnitude spectrum `|X[k]|` of a real-valued sample array.
---@param samples any
lurek.compute.fftMagnitude = function(samples) end

--- Creates an array from a Lua table of numbers with optional shape and dtype.
---@param data any
---@param shape? any
---@param dtype? any
lurek.compute.fromTable = function(data, shape, dtype) end

--- Creates a sizeĂ—size Gaussian kernel array.
---@param size any
---@param sigma any
lurek.compute.gaussianKernel = function(size, sigma) end

--- Computes the inverse discrete Fourier transform.
---@param freqs any
lurek.compute.ifft = function(freqs) end

--- Creates a zero-initialized array with the given shape and optional dtype.
---@param shape any
---@param dtype? any
lurek.compute.newArray = function(shape, dtype) end

--- Creates a one-filled array with the given shape and optional dtype.
---@param shape any
---@param dtype? any
lurek.compute.ones = function(shape, dtype) end

--- Creates a 1D array from start to stop with optional step and dtype.
---@param start any
---@param stop any
---@param step? any
---@param dtype? any
lurek.compute.range = function(start, stop, step, dtype) end

--- Creates a 2Ă—2 rotation matrix for the given angle in radians.
---@param angle_rad any
lurek.compute.rotate2dMatrix = function(angle_rad) end

--- Creates a zero-filled array with the given shape and optional dtype.
---@param shape any
---@param dtype? any
lurek.compute.zeros = function(shape, dtype) end

---@class lurek.data
lurek.data = {}

--- Raw byte buffer for binary I/O; addressable by byte or bit offset.
---@class LByteData
LByteData = {}

--- Creates an independent copy of this byte buffer with identical contents.
function LByteData:clone() end

--- Returns the value of a single bit within the buffer.
---@param byte_offset any
---@param bit_offset any
function LByteData:getBit(byte_offset, bit_offset) end

--- Get a byte at the specified offset.
---@param offset any
function LByteData:getByte(offset) end

--- Returns the total byte length of this buffer.
function LByteData:getSize() end

--- Get the string representation.
function LByteData:getString() end

--- Reads `count` consecutive bits starting at `byte_offset`/`bit_offset`
---@param byte_offset any
---@param bit_offset any
---@param count any
function LByteData:readBits(byte_offset, bit_offset, count) end

--- Sets or clears a single bit within the buffer.
---@param byte_offset any
---@param bit_offset any
---@param value any
function LByteData:setBit(byte_offset, bit_offset, value) end

--- Set a byte at the specified offset.
---@param offset any
---@param value any
function LByteData:setByte(offset, value) end

--- Access structured binary data efficiently without copying.
---@class LDataView
LDataView = {}

--- Reads a 64-bit float at the given offset.
---@param offset any
function LDataView:getDouble(offset) end

--- Reads a 32-bit float at the given offset.
---@param offset any
function LDataView:getFloat(offset) end

--- Reads a signed 16-bit integer at the given offset.
---@param offset any
function LDataView:getInt16(offset) end

--- Reads a signed 32-bit integer at the given offset.
---@param offset any
function LDataView:getInt32(offset) end

--- Reads a signed 8-bit integer at the given offset.
---@param offset any
function LDataView:getInt8(offset) end

--- Returns the size of this view in bytes.
function LDataView:getSize() end

--- Reads an unsigned 16-bit integer at the given offset.
---@param offset any
function LDataView:getUInt16(offset) end

--- Reads an unsigned 32-bit integer at the given offset.
---@param offset any
function LDataView:getUInt32(offset) end

--- Reads an unsigned 8-bit integer at the given offset.
---@param offset any
function LDataView:getUInt8(offset) end

--- Returns the type name of this object.
function LDataView:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDataView:typeOf(name) end

--- Write-cursor wrapper for the `lurek.data` module.
---@class LDataWriter
LDataWriter = {}

--- Returns the total buffer length.
function LDataWriter:len() end

--- Moves the write cursor to the given position.
---@param pos any
function LDataWriter:seek(pos) end

--- Returns the current write cursor position.
function LDataWriter:tell() end

--- Returns the buffer contents as a Lua string.
function LDataWriter:toBytes() end

--- Returns the type name of this object.
function LDataWriter:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDataWriter:typeOf(name) end

--- Writes raw bytes from a Lua string.
function LDataWriter:writeBytes() end

--- Writes a 32-bit LE float.
---@param v any
function LDataWriter:writeF32LE(v) end

--- Writes a 64-bit LE float.
---@param v any
function LDataWriter:writeF64LE(v) end

--- Writes a signed 16-bit LE integer.
---@param v any
function LDataWriter:writeI16LE(v) end

--- Writes a signed 32-bit LE integer.
---@param v any
function LDataWriter:writeI32LE(v) end

--- Writes a signed 8-bit integer.
---@param v any
function LDataWriter:writeI8(v) end

--- Writes a length-prefixed UTF-8 string (4-byte LE length + bytes).
---@param s any
function LDataWriter:writeString(s) end

--- Writes an unsigned 16-bit BE integer.
---@param v any
function LDataWriter:writeU16BE(v) end

--- Writes an unsigned 16-bit LE integer.
---@param v any
function LDataWriter:writeU16LE(v) end

--- Writes an unsigned 32-bit LE integer.
---@param v any
function LDataWriter:writeU32LE(v) end

--- Writes an unsigned 8-bit integer.
---@param v any
function LDataWriter:writeU8(v) end

--- Lua-side fixed-capacity ring buffer that holds any Lua value.
---@class LRingBuffer
LRingBuffer = {}

--- Returns the maximum number of elements the buffer can hold.
function LRingBuffer:capacity() end

--- Removes all elements from the buffer, releasing their registry entries.
function LRingBuffer:clear() end

--- Returns true if the buffer contains no elements.
function LRingBuffer:isEmpty() end

--- Returns true if the buffer has reached its capacity.
function LRingBuffer:isFull() end

--- Returns the number of elements currently in the buffer.
function LRingBuffer:len() end

--- Returns the oldest element without removing it, or nil if empty.
function LRingBuffer:peek() end

--- Returns the newest element without removing it, or nil if empty.
function LRingBuffer:peekNewest() end

--- Removes and returns the oldest element, or nil if the buffer is empty.
function LRingBuffer:pop() end

--- Pushes a value onto the ring buffer.
---@param value any
function LRingBuffer:push(value) end

--- Returns all elements as an array table ordered oldest-first.
function LRingBuffer:toTable() end

--- Returns the type name of this object.
function LRingBuffer:type() end

--- Returns true if this object is of the given type.
---@param name any
function LRingBuffer:typeOf(name) end

--- Compresses data using the given algorithm (deflate, gzip, lz4).
---@param format_str any
---@param raw_data any
---@param level? any
lurek.data.compress = function(format_str, raw_data, level) end

--- Returns the CRC-32 checksum of the input data as an integer.
---@param raw_data any
lurek.data.crc32 = function(raw_data) end

--- Decodes encoded text back to binary (base64, hex).
---@param format_str any
---@param encoded any
lurek.data.decode = function(format_str, encoded) end

--- Decompresses data using the given algorithm (deflate, gzip, lz4).
---@param format_str any
---@param compressed any
lurek.data.decompress = function(format_str, compressed) end

--- Encodes binary data using the given format (base64, hex).
---@param format_str any
---@param raw_data any
lurek.data.encode = function(format_str, raw_data) end

--- Encodes a Lua table into a TOML string.
---@param tbl any
lurek.data.encodeToml = function(tbl) end

--- Deserializes a MessagePack binary string back into a Lua value.
---@param bytes any
lurek.data.fromMsgPack = function(bytes) end

--- Returns the number of bytes the given format and values would occupy.
---@param fmt any
---@param ... any
lurek.data.getPackedSize = function(fmt, ...) end

--- Returns the cryptographic hash of the input (md5, sha1, sha256, sha512).
---@param algo_str any
---@param raw_data any
lurek.data.hash = function(algo_str, raw_data) end

--- Instantiates a raw byte data container object.
---@param value any
lurek.data.newByteData = function(value) end

--- Creates a read-only windowed view into a byte string.
---@param raw any
---@param offset? any
---@param size? any
lurek.data.newDataView = function(raw, offset, size) end

--- Creates a fixed-capacity ring buffer that can store any Lua value.
---@param capacity any
lurek.data.newRingBuffer = function(capacity) end

--- Creates a new write-cursor for building binary data.
lurek.data.newWriter = function() end

--- Packs values into a binary byte string using the format string.
---@param fmt any
---@param ... any
lurek.data.pack = function(fmt, ...) end

--- Parses a TOML string into a Lua table.
---@param text any
lurek.data.parseToml = function(text) end

--- Reads values using the Lurek2D Binary Pack Format.
---@param fmt any
---@param raw any
---@param offset? any
lurek.data.read = function(fmt, raw, offset) end

--- Returns the byte size of a Lurek2D Binary Pack Format string.
---@param fmt any
lurek.data.size = function(fmt) end

--- Serializes a Lua value (table, string, number, boolean, or nil) to MessagePack binary.
---@param value any
lurek.data.toMsgPack = function(value) end

--- Unpacks values from a binary byte string, returning values followed by next offset.
---@param fmt any
---@param raw any
---@param offset? any
lurek.data.unpack = function(fmt, raw, offset) end

--- Writes values using the Lurek2D Binary Pack Format.
---@param fmt any
---@param ... any
lurek.data.write = function(fmt, ...) end

---@class lurek.dataframe
lurek.dataframe = {}

--- Lua-side wrapper around a shared [`DataFrame`].
---@class LDataFrame
LDataFrame = {}

--- Adds a new column with an optional default value.
---@param name any
---@param default? any
function LDataFrame:addColumn(name, default) end

--- Adds a row from an optional table of name-value pairs, returns 1-based index.
---@param row_tbl? any
function LDataFrame:addRow(row_tbl) end

--- Add multiple rows at once from a table of row tables.
---@param rows any
function LDataFrame:addRowBatch(rows) end

--- Applies a function to each value in a column, replacing cells with results.
---@param col_val any
---@param func any
function LDataFrame:apply(col_val, func) end

--- Returns a deep copy of this DataFrame.
function LDataFrame:clone() end

--- Returns a table of column names.
function LDataFrame:columns() end

--- Pearson correlation coefficient between two numeric columns.
---@param col_a any
---@param col_b any
function LDataFrame:corr(col_a, col_b) end

--- Compute a correlation matrix for all numeric columns.
function LDataFrame:correlationMatrix() end

--- Returns the row count (alias for nrows).
function LDataFrame:count() end

--- Counts distinct values in a column, returns a DataFrame with value and count columns.
---@param col any
function LDataFrame:countBy(col) end

--- Returns descriptive statistics for all numeric columns.
function LDataFrame:describe() end

--- Removes rows where the given column is nil, returns a new DataFrame.
---@param col any
function LDataFrame:dropNil(col) end

--- Shannon entropy (bits) of the value distribution in a column.
---@param col any
function LDataFrame:entropy(col) end

--- Replaces nil values in a column with the given value.
---@param col any
---@param val any
function LDataFrame:fillNil(col, val) end

--- Filters rows where column matches a condition, returns a new DataFrame.
---@param col any
---@param op any
---@param val any
function LDataFrame:filter(col, op, val) end

--- Returns all values in a column as a table.
---@param col any
function LDataFrame:getColumn(col) end

--- Return a numeric column as a Lua array of numbers (nils → 0/nan).
---@param col any
function LDataFrame:getColumnAsF64(col) end

--- Returns a row as a table of name-value pairs.
---@param row any
function LDataFrame:getRow(row) end

--- Returns a single cell value.
---@param row any
---@param col any
function LDataFrame:getValue(row, col) end

--- Aggregate agg_col grouped by group_col using the named function.
---@param group_col any
---@param agg_col any
---@param fn_name any
function LDataFrame:groupAgg(group_col, agg_col, fn_name) end

--- Groups rows by column value, returns a table of DataFrames keyed by value.
---@param col any
function LDataFrame:groupBy(col) end

--- Groups rows by column value, returns a GroupedFrame object supporting aggregate().
---@param col any
function LDataFrame:groupByObj(col) end

--- Returns the first n rows (default 5).
---@param n? any
function LDataFrame:head(n) end

--- Joins with another DataFrame on matching columns.
function LDataFrame:join() end

--- Returns the maximum numeric value in a column.
---@param col any
function LDataFrame:max(col) end

--- Returns the mean of numeric values in a column.
---@param col any
function LDataFrame:mean(col) end

--- Returns the median of numeric values in a column.
---@param col any
function LDataFrame:median(col) end

--- Appends rows from another DataFrame in-place.
---@param other any
function LDataFrame:merge(other) end

--- Returns the minimum numeric value in a column.
---@param col any
function LDataFrame:min(col) end

--- Return the most frequent value in a column (nil if empty).
---@param col any
function LDataFrame:modeVal(col) end

--- Returns the number of columns.
function LDataFrame:ncols() end

--- Add a min-max normalized column scaled to [out_min, out_max].
---@param col any
---@param out_min any
---@param out_max any
---@param name any
function LDataFrame:normalizeCol(col, out_min, out_max, name) end

--- Returns the number of rows.
function LDataFrame:nrows() end

--- Return a new DataFrame with only outlier rows (|z-score| > threshold).
---@param col any
---@param threshold? any
function LDataFrame:outliers(col, threshold) end

--- Creates a wide pivot table by reshaping rows into columns.
---@param row_col any
---@param col_col any
---@param val_col any
function LDataFrame:pivot(row_col, col_col, val_col) end

--- Reshapes a long-format DataFrame into wide format.
function LDataFrame:pivotTable() end

--- Executes a SQL query against this DataFrame.
---@param sql_str any
function LDataFrame:query(sql_str) end

--- Returns a new DataFrame with a dense-rank column appended.
---@param col any
---@param order? any
---@param result_col? any
function LDataFrame:rank(col, order, result_col) end

--- Removes a column by name or index.
---@param col any
function LDataFrame:removeColumn(col) end

--- Removes a row by 1-based index.
---@param row any
function LDataFrame:removeRow(row) end

--- Renames the column `old_name` to `new_name` in this DataFrame.
---@param col any
---@param new_name any
function LDataFrame:rename(col, new_name) end

--- Returns a new DataFrame with a rolling mean column appended.
---@param col any
---@param window any
---@param result_col? any
function LDataFrame:rollingMean(col, window, result_col) end

--- Returns a new DataFrame with a rolling sum column appended.
---@param col any
---@param window any
---@param result_col? any
function LDataFrame:rollingSum(col, window, result_col) end

--- Returns a random sample of n rows.
---@param n any
---@param seed? any
function LDataFrame:sample(n, seed) end

--- Selects a subset of columns, returns a new DataFrame.
---@param ... any
function LDataFrame:select(...) end

--- Set a numeric column from a Lua array of numbers.
---@param col any
---@param values any
function LDataFrame:setColumnFromF64(col, values) end

--- Sets a single cell value.
---@param row any
---@param col any
---@param val any
function LDataFrame:setValue(row, col, val) end

--- Returns rows from start to end (1-based, inclusive).
---@param start any
---@param end_ any
function LDataFrame:slice(start, end_) end

--- Sorts by column, returns a new DataFrame.
---@param col any
---@param ascending? any
function LDataFrame:sort(col, ascending) end

--- Returns the population standard deviation of numeric values in a column.
---@param col any
function LDataFrame:stddev(col) end

--- Returns the sum of numeric values in a column.
---@param col any
function LDataFrame:sum(col) end

--- Returns the last n rows (default 5).
---@param n? any
function LDataFrame:tail(n) end

--- Serializes this DataFrame to a binary LVDF string.
function LDataFrame:toBinary() end

--- Serializes this DataFrame to a CSV string.
function LDataFrame:toCSV() end

--- Serializes this DataFrame to a JSON string.
function LDataFrame:toJSON() end

--- Returns a formatted string table representation.
function LDataFrame:toString() end

--- Converts this DataFrame to a Lua table of row tables.
function LDataFrame:toTable() end

--- Returns the type name of this object.
function LDataFrame:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDataFrame:typeOf(name) end

--- Returns unique values in a column as a table.
---@param col any
function LDataFrame:unique(col) end

--- Returns the population variance of numeric values in a column.
---@param col any
function LDataFrame:variance(col) end

--- Add a cumulative-sum column.
---@param col any
---@param name any
function LDataFrame:withCumsum(col, name) end

--- Returns a new DataFrame with an additional computed column named `col_name`.
---@param col_name any
---@param expr any
function LDataFrame:withEval(col_name, expr) end

--- Add a percent-change-from-previous-row column.
---@param col any
---@param name any
function LDataFrame:withPctChange(col, name) end

--- Add a rank column (1-based, ties averaged).
---@param col any
---@param asc? any
---@param name any
function LDataFrame:withRank(col, asc, name) end

--- Add a rolling maximum column.
---@param col any
---@param window any
---@param name any
function LDataFrame:withRollingMax(col, window, name) end

--- Add a rolling mean column. Rows with insufficient history get nil.
---@param col any
---@param window any
---@param name any
function LDataFrame:withRollingMean(col, window, name) end

--- Add a rolling minimum column.
---@param col any
---@param window any
---@param name any
function LDataFrame:withRollingMin(col, window, name) end

--- Add a rolling sum column.
---@param col any
---@param window any
---@param name any
function LDataFrame:withRollingSum(col, window, name) end

--- Add a z-score column for the given numeric column.
---@param col any
---@param name any
function LDataFrame:zscoreCol(col, name) end

--- Lua-side wrapper around a shared [`Database`].
---@class LDatabase
LDatabase = {}

--- Adds or replaces a table by cloning the given DataFrame.
---@param name any
---@param df_ud any
function LDatabase:addTable(name, df_ud) end

--- Drops every table from this in-memory database, leaving it empty.
function LDatabase:clear() end

--- Returns a copy of a table by name, or nil if not found.
---@param name any
function LDatabase:getTable(name) end

--- Returns true if a table with the given name exists.
---@param name any
function LDatabase:hasTable(name) end

--- Returns a table of all table names.
function LDatabase:listTables() end

--- Merges all tables from another Database into this one.
---@param other any
function LDatabase:merge(other) end

--- Executes a SQL query against the database tables.
---@param sql_str any
function LDatabase:query(sql_str) end

--- Drops the named table from this in-memory database if it exists.
---@param name any
function LDatabase:removeTable(name) end

--- Returns the number of tables.
function LDatabase:tableCount() end

--- Serializes all tables to a JSON object string.
function LDatabase:toJSON() end

--- Returns the type name of this object.
function LDatabase:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDatabase:typeOf(name) end

--- Lua-side wrapper around a grouped result from [`DataFrame::group_by`].
---@class LGroupedFrame
LGroupedFrame = {}

--- Apply a Lua function to aggregate a column's values per group.
---@param col_name any
---@param func any
function LGroupedFrame:aggregate(col_name, func) end

--- Returns the type name of this object.
function LGroupedFrame:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGroupedFrame:typeOf(name) end

--- Thin Lua wrapper around a [`VecFrame`]: typed-column vectorized DataFrame.
---@class LVecFrame
LVecFrame = {}

--- Return a new VecFrame containing only the rows where mask[i] is true.
---@param mask_tbl any
function LVecFrame:applyMask(mask_tbl) end

--- Apply absolute value to every element of a Float64 column.
---@param col any
function LVecFrame:colAbs(col) end

--- Add a scalar to every element of a Float64 column.
---@param col any
---@param val any
function LVecFrame:colAdd(col, val) end

--- Cast a column to a new dtype: "float64", "int64", or "text".
---@param col any
---@param dtype any
function LVecFrame:colCast(col, dtype) end

--- Apply ceiling to every element of a Float64 column.
---@param col any
function LVecFrame:colCeil(col) end

--- Clamp every element of a Float64 column to [min, max].
---@param col any
---@param min_val any
---@param max_val any
function LVecFrame:colClamp(col, min_val, max_val) end

--- Divide every element of a Float64 column by a scalar.
---@param col any
---@param val any
function LVecFrame:colDiv(col, val) end

--- Apply floor to every element of a Float64 column.
---@param col any
function LVecFrame:colFloor(col) end

--- Multiply every element of a Float64 column by a scalar.
---@param col any
---@param val any
function LVecFrame:colMul(col, val) end

--- Negate every element of a Float64 column.
---@param col any
function LVecFrame:colNeg(col) end

--- Compute out[i] = left[i] op right[i] for every row.
---@param out_col any
---@param left_col any
---@param op any
---@param right_col any
function LVecFrame:colOp(out_col, left_col, op, right_col) end

--- Apply square root to every element of a Float64 column.
---@param col any
function LVecFrame:colSqrt(col) end

--- Subtract a scalar from every element of a Float64 column.
---@param col any
---@param val any
function LVecFrame:colSub(col, val) end

--- Return the dtype name of a column: "float64", "int64", "bool", or "text".
---@param col any
function LVecFrame:colType(col) end

--- Return a table of column names.
function LVecFrame:columns() end

--- Build a boolean row mask: mask[i] = col[i] cmp_op val.
---@param col any
---@param cmp_op any
---@param val any
function LVecFrame:filterMask(col, cmp_op, val) end

--- Return the number of columns.
function LVecFrame:ncols() end

--- Return the number of rows.
function LVecFrame:nrows() end

--- Reduce multiple columns in parallel, returning {col → value} table.
---@param cols_tbl any
---@param op any
function LVecFrame:parReduce(cols_tbl, op) end

--- Apply a scalar op in parallel to multiple Float64 columns.
---@param cols_tbl any
---@param op any
---@param val any
function LVecFrame:parScalarOp(cols_tbl, op, val) end

--- Reduce an entire numeric column to a single value.
---@param col any
---@param op any
function LVecFrame:reduce(col, op) end

--- Convert this VecFrame back to a DataFrame.
function LVecFrame:toDataFrame() end

--- Returns the type name of this object.
function LVecFrame:type() end

--- Returns true if this object is of the given type.
---@param name any
function LVecFrame:typeOf(name) end

--- Deserializes a binary LVDF string into a DataFrame.
---@param s any
lurek.dataframe.fromBinary = function(s) end

--- Parses a CSV string into a DataFrame.
---@param s any
lurek.dataframe.fromCSV = function(s) end

--- Parses a JSON string into a DataFrame.
---@param s any
lurek.dataframe.fromJSON = function(s) end

--- Creates a DataFrame from an array of row tables.
---@param rows any
lurek.dataframe.fromTable = function(rows) end

--- Converts a VecFrame back to a DataFrame.
---@param vf any
lurek.dataframe.fromVec = function(vf) end

--- Creates a new empty DataFrame.
lurek.dataframe.newDataFrame = function() end

--- Creates a new empty Database.
lurek.dataframe.newDatabase = function() end

--- Generates a DataFrame with random data from column definitions.
---@param defs_tbl any
---@param n any
---@param seed? any
lurek.dataframe.random = function(defs_tbl, n, seed) end

--- Converts a DataFrame to a VecFrame for vectorized column operations.
---@param df any
lurek.dataframe.toVec = function(df) end

---@class lurek.debugbridge
lurek.debugbridge = {}

--- Broadcasts a JSON event to all connected clients.
---@param event any
---@param json_data any
lurek.debugbridge.broadcast = function(event, json_data) end

--- Captures a print message and broadcasts it to connected clients.
---@param msg any
---@param source? any
---@param line? any
lurek.debugbridge.capturePrint = function(msg, source, line) end

--- Clears the print history.
lurek.debugbridge.clearPrintHistory = function() end

--- Returns the number of connected TCP clients.
lurek.debugbridge.getClientCount = function() end

--- Returns performance statistics.
lurek.debugbridge.getPerformance = function() end

--- Returns the server port (0 if not running).
lurek.debugbridge.getPort = function() end

--- Returns the print history.
---@param count? any
lurek.debugbridge.getPrintHistory = function(count) end

--- Returns whether the server is currently running.
lurek.debugbridge.isRunning = function() end

--- Returns whether a screenshot is currently requested.
lurek.debugbridge.isScreenshotRequested = function() end

--- Poll for pending Lua-dependent requests from TCP clients.
lurek.debugbridge.poll = function() end

--- Flags a screenshot request for the next frame.
---@param scale? any
lurek.debugbridge.requestScreenshot = function(scale) end

--- Sets the maximum print history size.
---@param max any
lurek.debugbridge.setMaxPrintHistory = function(max) end

--- Start the TCP debug server on 127.0.0.1:port.
---@param port? any
lurek.debugbridge.start = function(port) end

--- Stop the TCP debug server and close all connections.
lurek.debugbridge.stop = function() end

---@class lurek.devtools
lurek.devtools = {}

--- Lua-side handle for a per-path file watcher.
---@class LFileWatcher
LFileWatcher = {}

--- Removes the stored `onChanged` callback and stops future notifications.
function LFileWatcher:cancel() end

--- Polls the watcher. If the file has changed since the last call, fires the
function LFileWatcher:check() end

--- Returns the watched path string.
function LFileWatcher:getPath() end

--- Registers a callback invoked (with no arguments) when the watched path changes.
---@param func any
function LFileWatcher:onChanged(func) end

--- Returns the type name of this object.
function LFileWatcher:type() end

--- Returns true if this object is of the given type.
---@param name any
function LFileWatcher:typeOf(name) end

--- Lua-side wrapper around a [`ReplConsole`] interactive evaluator.
---@class LReplConsole
LReplConsole = {}

--- Clears the REPL history buffer.
function LReplConsole:clear() end

--- Evaluates a Lua snippet and records the input in history.
---@param code any
function LReplConsole:eval(code) end

--- Returns an ordered array of past inputs (oldest first).
function LReplConsole:history() end

--- Returns the number of history entries.
function LReplConsole:len() end

--- Returns the type name of this object.
function LReplConsole:type() end

--- Returns true if this object is of the given type.
---@param name any
function LReplConsole:typeOf(name) end

--- Discards all accumulated log entries from the in-memory devtools log buffer.
lurek.devtools.clearLog = function() end

--- Clears all watched paths.
lurek.devtools.clearWatches = function() end

--- Logs a message at DEBUG level.
---@param message any
lurek.devtools.debug = function(message) end

--- Logs a message at ERROR level.
---@param message any
lurek.devtools.error = function(message) end

--- Evaluates a Lua string and returns (success, results...).
---@param code any
lurek.devtools.eval = function(code) end

--- Registers a named live watch. The getter function is called on demand to sample a value.
---@param name any
---@param getter any
---@param category? any
lurek.devtools.exposeWatch = function(name, getter, category) end

--- Logs a message at FATAL level.
---@param message any
lurek.devtools.fatal = function(message) end

--- Returns the Lua call stack as a table of frames.
---@param max_depth? any
lurek.devtools.getCallStack = function(max_depth) end

--- Returns the raw frame-time sample array.
lurek.devtools.getFrameHistory = function() end

--- Returns the current frame-history buffer capacity.
lurek.devtools.getFrameHistorySize = function() end

--- Returns a table of computed frame statistics.
lurek.devtools.getFrameStats = function() end

--- Returns whether console log output is enabled.
lurek.devtools.getLogConsole = function() end

--- Returns the current log file path.
lurek.devtools.getLogFile = function() end

--- Returns recent log entries as an array of tables.
---@param count? any
lurek.devtools.getLogHistory = function(count) end

--- Returns the current minimum log level.
lurek.devtools.getLogLevel = function() end

--- Returns zone data table for a specific frame (0 or nil = most recent).
---@param frame? any
lurek.devtools.getProfileData = function(frame) end

--- Returns the number of retained profile frames.
lurek.devtools.getProfileFrameCount = function() end

--- Returns the file watch poll interval in seconds.
lurek.devtools.getWatchInterval = function() end

--- Returns an array of all watched paths.
lurek.devtools.getWatchedPaths = function() end

--- Calls all registered watch getters and returns a table of {name, category, value} records.
lurek.devtools.getWatches = function() end

--- Logs a message at INFO level.
---@param message any
lurek.devtools.info = function(message) end

--- Returns whether the console is considered open.
lurek.devtools.isConsoleOpen = function() end

--- Returns whether the profiler is enabled.
lurek.devtools.isProfilingEnabled = function() end

--- Logs a message at the given level.
---@param level any
---@param message any
lurek.devtools.log = function(level, message) end

--- Creates a standalone per-path file watcher. Call `:check()` once per frame
---@param path any
lurek.devtools.newFileWatcher = function(path) end

--- Creates an interactive Lua REPL console with a bounded history buffer.
---@param max_history? any
lurek.devtools.newRepl = function(max_history) end

--- Opens the console window (updates the console flag; returns true).
lurek.devtools.openConsole = function() end

--- Seals the current frame of profiling data.
lurek.devtools.profileFrame = function() end

--- Closes the most recent profiling zone.
lurek.devtools.profilePop = function() end

--- Opens a named profiling zone on the stack.
---@param name any
lurek.devtools.profilePush = function(name) end

--- Returns a flat summary table of all recorded profiler zones across all stored
lurek.devtools.profilerReport = function() end

--- Records a frame-time sample (call each frame with delta time in seconds).
---@param dt_val any
lurek.devtools.recordFrameTime = function(dt_val) end

--- Removes a watch by the id returned from exposeWatch. Returns true if removed.
---@param id any
lurek.devtools.removeWatch = function(id) end

--- Clears all profiling data and resets the zone stack.
lurek.devtools.resetProfile = function() end

--- Polls all watched paths and returns paths whose mtime changed.
lurek.devtools.scan = function() end

--- Sets the frame-history buffer capacity (clamped 10-10000).
---@param size any
lurek.devtools.setFrameHistorySize = function(size) end

--- Enables or disables console log output.
---@param enabled any
lurek.devtools.setLogConsole = function(enabled) end

--- Sets the log file path (empty string disables file output).
---@param path any
lurek.devtools.setLogFile = function(path) end

--- Sets the minimum log level.
---@param level any
lurek.devtools.setLogLevel = function(level) end

--- Enables or disables the profiler.
---@param enabled any
lurek.devtools.setProfilingEnabled = function(enabled) end

--- Sets the file watch poll interval in seconds.
---@param interval any
lurek.devtools.setWatchInterval = function(interval) end

--- Takes a structured snapshot of all watches + frame stats + last profile frame.
lurek.devtools.snapshot = function() end

--- Logs a message at TRACE level.
---@param message any
lurek.devtools.trace = function(message) end

--- Removes a file path from the watch list.
---@param path any
lurek.devtools.unwatch = function(path) end

--- Logs a message at WARN level.
---@param message any
lurek.devtools.warn = function(message) end

--- Adds a file path to the watch list. Returns false if already watched.
---@param path any
lurek.devtools.watch = function(path) end

---@class lurek.docs
lurek.docs = {}

--- Wraps a catalog snapshot of API entries for Lua access.
---@class LApiCatalog
LApiCatalog = {}

--- Returns the number of entries, optionally scoped to a module.
---@param module? any
function LApiCatalog:entryCount(module) end

--- Returns a new catalog containing only entries for which predicate returns true.
---@param predicate any
function LApiCatalog:filter(predicate) end

--- Returns all entries, optionally filtered to a single module.
---@param module? any
function LApiCatalog:getEntries(module) end

--- Returns a single entry by qualified name, or nil.
---@param qualified_name any
function LApiCatalog:getEntry(qualified_name) end

--- Returns a sorted list of module names present in the catalog.
function LApiCatalog:getModules() end

--- Returns entries that are methods of the given type qualified name.
---@param qualified_name any
function LApiCatalog:getTypeMethods(qualified_name) end

--- Returns the names of all entries with kind "type" in the given module.
---@param module_name any
function LApiCatalog:getTypes(module_name) end

--- Returns a new catalog that is the union of this and another catalog, with other overriding duplicates.
---@param other any
function LApiCatalog:merge(other) end

--- Returns a table of entries whose name, qualified name, or description contains query.
---@param query any
function LApiCatalog:search(query) end

--- Serialises the catalog to a pretty-printed JSON string.
function LApiCatalog:toJSON() end

--- Converts the catalog to a plain Lua table array.
function LApiCatalog:toTable() end

--- Returns the type name of this object.
function LApiCatalog:type() end

--- Returns true if this object is of the given type.
---@param name any
function LApiCatalog:typeOf(name) end

--- Wraps a single doc entry for Lua access.
---@class LDocEntry
LDocEntry = {}

--- Returns the deprecation message, or nil.
function LDocEntry:getDeprecated() end

--- Returns the human-readable description text for this documentation entry.
function LDocEntry:getDescription() end

--- Returns the example snippet, or nil.
function LDocEntry:getExample() end

--- Returns the kind tag for this entry (e.g. `'function'`, `'method'`, `'class'`).
function LDocEntry:getKind() end

--- Returns the Lua module name this entry belongs to (e.g. `'lurek.math'`).
function LDocEntry:getModule() end

--- Returns the symbol name for this documentation entry.
function LDocEntry:getName() end

--- Returns the parameters as a table of `{name, type, description, optional, default?}` records.
function LDocEntry:getParameters() end

--- Returns the qualified name.
function LDocEntry:getQualifiedName() end

--- Returns the return values as a table of `{type, description}` records.
function LDocEntry:getReturns() end

--- Returns the quality score in [0,1].
function LDocEntry:getScore() end

--- Returns the since version string, or nil.
function LDocEntry:getSince() end

--- Returns true when the entry has a non-empty description.
function LDocEntry:hasDescription() end

--- Returns true when the entry has an example snippet.
function LDocEntry:hasExample() end

--- Returns true when the entry has at least one parameter.
function LDocEntry:hasParameters() end

--- Returns true when the entry declares at least one return type.
function LDocEntry:hasReturnType() end

--- Returns the type name of this object.
function LDocEntry:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDocEntry:typeOf(name) end

--- Wraps documentation quality metrics for Lua access.
---@class LQualityReport
LQualityReport = {}

--- Returns up to count entries with the highest quality scores.
---@param count? any
function LQualityReport:getBest(count) end

--- Returns entries whose grade exactly matches the given letter grade.
---@param grade any
function LQualityReport:getByGrade(grade) end

--- Returns the letter grade for the overall score.
function LQualityReport:getGrade() end

--- Returns a table mapping module name to its average quality score.
function LQualityReport:getModuleScores() end

--- Returns the overall quality score in [0,1].
function LQualityReport:getOverallScore() end

--- Returns a multi-line human-readable summary of quality by module.
function LQualityReport:getSummary() end

--- Returns up to count entries with the lowest quality scores.
---@param count? any
function LQualityReport:getWorst(count) end

--- Serialises the quality report to a pretty-printed JSON string.
function LQualityReport:toJSON() end

--- Converts the quality report to a plain Lua table.
function LQualityReport:toTable() end

--- Returns the type name of this object.
function LQualityReport:type() end

--- Returns true if this object is of the given type.
---@param name any
function LQualityReport:typeOf(name) end

--- Lua wrapper for a runtime data-validation schema.
---@class LSchema
LSchema = {}

--- Validates data and throws a Lua error on failure with all error messages joined.
---@param data any
function LSchema:assert(data) end

--- Returns true when the data passes all schema rules.
---@param data any
function LSchema:check(data) end

--- Returns a table of declared field names.
function LSchema:getFields() end

--- Returns the name identifier of this API schema group.
function LSchema:getName() end

--- Returns the type name of this object.
function LSchema:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSchema:typeOf(name) end

--- Validates a Lua table against the schema.
---@param data any
function LSchema:validate(data) end

--- Wraps a validation report for Lua access.
---@class LValidationReport
LValidationReport = {}

--- Returns the list of qualified names whose catalog entry is incomplete.
function LValidationReport:getIncomplete() end

--- Returns the list of qualified names present in the live API but missing from the catalog.
function LValidationReport:getMissing() end

--- Returns the list of qualified names in the catalog that are not present in the live API.
function LValidationReport:getPhantom() end

--- Returns a single-line summary of the validation results.
function LValidationReport:getSummary() end

--- Returns the count of incomplete entries.
function LValidationReport:incompleteCount() end

--- Returns true when the report has no missing entries.
function LValidationReport:isValid() end

--- Returns the count of missing entries.
function LValidationReport:missingCount() end

--- Returns the count of phantom entries.
function LValidationReport:phantomCount() end

--- Serialises the report to a pretty-printed JSON string.
function LValidationReport:toJSON() end

--- Converts the report to a plain Lua table.
function LValidationReport:toTable() end

--- Returns the type name of this object.
function LValidationReport:type() end

--- Returns true if this object is of the given type.
---@param name any
function LValidationReport:typeOf(name) end

--- Compare catalog entries against source files in a directory for staleness.
---@param catalog_ud any
---@param source_dir any
lurek.docs.checkStaleness = function(catalog_ud, source_dir) end

--- Return (documented_count, total_live_count) coverage tuple.
---@param catalog_ud? any
lurek.docs.coverage = function(catalog_ud) end

--- Return (documented_count, total_live_count) for a single module.
---@param module_name any
---@param catalog_ud? any
lurek.docs.coverageModule = function(module_name, catalog_ud) end

--- Inject or update a description for a named API entry.
---@param qualified_name any
---@param description any
lurek.docs.describe = function(qualified_name, description) end

--- Export completions.json, hover.json, and signatures.json to a directory.
---@param catalog_ud any
---@param output_dir any
lurek.docs.exportAll = function(catalog_ud, output_dir) end

--- Export a one-line-per-function plain-text cheatsheet.
---@param catalog_ud any
---@param path any
lurek.docs.exportCheatsheet = function(catalog_ud, path) end

--- Export VS Code IntelliSense completions JSON to a file.
---@param catalog_ud any
---@param path any
lurek.docs.exportCompletions = function(catalog_ud, path) end

--- Export VS Code hover JSON to a file.
---@param catalog_ud any
---@param path any
lurek.docs.exportHover = function(catalog_ud, path) end

--- Export a Markdown API reference file.
---@param catalog_ud any
---@param path any
lurek.docs.exportMarkdown = function(catalog_ud, path) end

--- Export VS Code signature-help JSON to a file.
---@param catalog_ud any
---@param path any
lurek.docs.exportSignatures = function(catalog_ud, path) end

--- Return the current internal catalog as an ApiCatalog userdata.
lurek.docs.getCatalog = function() end

--- Load all .toml files in a directory and merge into a single ApiCatalog.
---@param directory any
lurek.docs.loadAll = function(directory) end

--- Load a TOML doc file into an ApiCatalog.
---@param path any
lurek.docs.loadToml = function(path) end

--- Calculate quality metrics for a catalog or the internal catalog.
---@param catalog_ud? any
lurek.docs.quality = function(catalog_ud) end

--- Calculate quality metrics for a single module.
---@param module_name any
---@param catalog_ud? any
lurek.docs.qualityModule = function(module_name, catalog_ud) end

--- Walks the live lurek.* Lua table and returns a structured reflection of all
---@param ns? any
lurek.docs.reflectLive = function(ns) end

--- Reflects any Lua table, returning a structure describing its keys,
---@param tbl any
---@param name? any
lurek.docs.reflectTable = function(tbl, name) end

--- Clear all entries from the internal catalog.
lurek.docs.resetCatalog = function() end

--- Scan the lurek.* namespace to build an API catalog from live bindings.
---@param opts? any
lurek.docs.scan = function(opts) end

--- Scan a single module's bindings.
---@param module_name any
lurek.docs.scanModule = function(module_name) end

--- Creates a Schema validator from a rules table.
---@param rules any
---@param name? any
lurek.docs.schema = function(rules, name) end

--- Set the parameter metadata for a catalog entry.
---@param qualified_name any
---@param params any
lurek.docs.setParamInfo = function(qualified_name, params) end

--- Set the return type metadata for a catalog entry.
---@param qualified_name any
---@param returns any
lurek.docs.setReturnInfo = function(qualified_name, returns) end

--- Validate catalog completeness against the live lurek.* bindings.
---@param catalog_ud? any
lurek.docs.validate = function(catalog_ud) end

--- Validate a single module against the live lurek.<module>.* bindings.
---@param module_name any
---@param catalog_ud? any
lurek.docs.validateModule = function(module_name, catalog_ud) end

---@class lurek.ecs
lurek.ecs = {}

--- Lua-side wrapper around a [`Universe`] ECS world.
---@class LUniverse
LUniverse = {}

--- Adds a directed named relationship from entity `from` to entity `to`.
---@param from any
---@param name any
---@param to any
function LUniverse:addRelation(from, name, to) end

--- Adds a system table to the universe with an optional priority (lower = earlier).
---@param system any
---@param opts? any
function LUniverse:addSystem(system, opts) end

--- Attaches a string tag to an entity.
---@param id any
---@param tag any
function LUniverse:addTag(id, tag) end

--- Adds a bitmap tag to an entity.
---@param id any
---@param name any
function LUniverse:bitmapTag(id, name) end

--- Removes a bitmap tag from an entity.
---@param id any
---@param name any
function LUniverse:bitmapUntag(id, name) end

--- Removes all entities, components, tags, layers, and systems. Blueprints are preserved.
function LUniverse:clear() end

--- Removes all directed named relationships of type `name` from entity `from`.
---@param from any
---@param name any
function LUniverse:clearRelations(from, name) end

--- Defines a blueprint from a component table.
---@param name any
---@param components any
function LUniverse:defineBlueprint(name, components) end

--- Defines a bitmap tag name, returning its bit index.
---@param name any
function LUniverse:defineTag(name) end

--- Restores entity state from a snapshot produced by serialize().
---@param snapshot any
function LUniverse:deserialize(snapshot) end

--- Calls callback(id, value) for every entity with the named component.
---@param name any
---@param callback any
function LUniverse:each(name, callback) end

--- Emits a named event to all systems that implement the handler, in priority order.
---@param ... any
function LUniverse:emit(...) end

--- Defines a blueprint by extending a parent with overrides.
---@param name any
---@param parent any
---@param overrides any
function LUniverse:extendBlueprint(name, parent, overrides) end

--- Dispatches all pending component-add and component-remove events to registered callbacks.
function LUniverse:flushObservers() end

--- Returns the component value for an entity, or nil if missing.
---@param id any
---@param name any
function LUniverse:get(id, name) end

--- Returns the bit index for a bitmap tag name, or nil if undefined.
---@param name any
function LUniverse:getBitmapTagBit(name) end

--- Returns a deep copy of a blueprint's component table, or nil.
---@param name any
function LUniverse:getBlueprintComponents(name) end

--- Returns all direct child entity IDs.
---@param parent_id any
function LUniverse:getChildren(parent_id) end

--- Returns all component names for an entity.
---@param id any
function LUniverse:getComponents(id) end

--- Returns all alive entity IDs.
function LUniverse:getEntities() end

--- Returns all alive entities on a specific layer.
---@param layer any
function LUniverse:getEntitiesByLayer(layer) end

--- Returns all alive entities with the given string tag.
---@param tag any
function LUniverse:getEntitiesByTag(tag) end

--- Returns all alive entities sorted by layer then ID.
function LUniverse:getEntitiesSorted() end

--- Returns the number of alive entities.
function LUniverse:getEntityCount() end

--- Returns the layer for an entity, defaulting to zero.
---@param id any
function LUniverse:getLayer(id) end

--- Returns the parent entity ID, or nil if unparented.
---@param child_id any
function LUniverse:getParent(child_id) end

--- Returns all entity IDs reachable from `from` via the named relationship.
---@param from any
---@param name any
function LUniverse:getRelated(from, name) end

--- Returns the number of registered systems.
function LUniverse:getSystemCount() end

--- Returns all string tags for an entity.
---@param id any
function LUniverse:getTags(id) end

--- Returns true if the entity has the named component.
---@param id any
---@param name any
function LUniverse:has(id, name) end

--- Returns true if the entity has the given bitmap tag.
---@param id any
---@param name any
function LUniverse:hasBitmapTag(id, name) end

--- Returns true if a blueprint with the given name exists.
---@param name any
function LUniverse:hasBlueprint(name) end

--- Returns true if a directed named relationship from `from` to `to` exists.
---@param from any
---@param name any
---@param to any
function LUniverse:hasRelation(from, name, to) end

--- Returns true if the entity carries the given tag.
---@param id any
---@param tag any
function LUniverse:hasTag(id, tag) end

--- Returns true if the entity ID is currently alive.
---@param id any
function LUniverse:isAlive(id) end

--- Destroys the entity with the given ID, freeing its slot for reuse.
---@param id any
function LUniverse:kill(id) end

--- Kills an entity and all its descendants recursively.
---@param id any
function LUniverse:killRecursive(id) end

--- Returns all defined blueprint names.
function LUniverse:listBlueprints() end

--- Registers a callback to fire when a component is added to any entity.
---@param name any
---@param cb any
function LUniverse:onComponentAdded(name, cb) end

--- Registers a callback to fire when a component is removed from any entity.
---@param name any
---@param cb any
function LUniverse:onComponentRemoved(name, cb) end

--- Returns entity IDs that have all listed component names.
---@param ... any
function LUniverse:query(...) end

--- Returns all alive entities with all of the listed bitmap tags.
---@param names any
function LUniverse:queryBitmapAll(names) end

--- Returns all alive entities with any of the listed bitmap tags.
---@param names any
function LUniverse:queryBitmapAny(names) end

--- Returns all alive entities with the given bitmap tag.
---@param name any
function LUniverse:queryBitmapTag(name) end

--- Returns entity IDs that have all `with` components and none of the `without` components.
---@param with_tbl any
---@param without_tbl any
function LUniverse:queryNot(with_tbl, without_tbl) end

--- Releases all universe state, equivalent to clear.
function LUniverse:release() end

--- Removes a component from an entity.
---@param id any
---@param name any
function LUniverse:remove(id, name) end

--- Removes a blueprint definition.
---@param name any
function LUniverse:removeBlueprint(name) end

--- Removes the directed named relationship from entity `from` to entity `to`.
---@param from any
---@param name any
---@param to any
function LUniverse:removeRelation(from, name, to) end

--- Removes a system table from the universe.
---@param system any
function LUniverse:removeSystem(system) end

--- Removes a string tag from an entity.
---@param id any
---@param tag any
function LUniverse:removeTag(id, tag) end

--- Calls render(system, world) on each registered system in priority order.
function LUniverse:render() end

--- Serializes all alive entities to a Lua table snapshot.
function LUniverse:serialize() end

--- Sets a component value on an entity.
---@param id any
---@param name any
---@param value any
function LUniverse:set(id, name, value) end

--- Sets the layer for an entity.
---@param id any
---@param layer any
function LUniverse:setLayer(id, layer) end

--- Sets or clears the parent of an entity.
---@param child_id any
---@param parent_id? any
function LUniverse:setParent(child_id, parent_id) end

--- Creates a new entity and returns its packed ID.
function LUniverse:spawn() end

--- Spawns an entity from a blueprint with optional overrides.
---@param name any
---@param overrides? any
function LUniverse:spawnBlueprint(name, overrides) end

--- Spawns `count` entities from a blueprint, returns an array of entity IDs.
---@param name any
---@param count any
---@param overrides? any
function LUniverse:spawnBulk(name, count, overrides) end

--- Returns the type name of this object.
function LUniverse:type() end

--- Returns true if this object is of the given type.
---@param name any
function LUniverse:typeOf(name) end

--- Calls update(system, world, dt) on each registered system in priority order.
---@param dt any
function LUniverse:update(dt) end

--- Creates a new empty ECS universe.
lurek.ecs.newUniverse = function() end

---@class lurek.effect
lurek.effect = {}

--- Lua-side wrapper around [`ImageEffect`].
---@class LImageEffect
LImageEffect = {}

--- Creates a new effect by type name, appends it, and returns the shared PostFxEffect.
---@param name any
function LImageEffect:addEffect(name) end

--- Removes all effects from the chain (alias for clearEffects).
function LImageEffect:clear() end

--- Removes all effects from the chain.
function LImageEffect:clearEffects() end

--- Returns a deep copy of this ImageEffect chain.
function LImageEffect:clone() end

--- Returns the number of effects in the chain.
function LImageEffect:effectCount() end

--- Returns the effect at the given 1-based index or with the given type name.
---@param key any
function LImageEffect:getEffect(key) end

--- Returns the number of effects in the chain (alias for effectCount).
function LImageEffect:getEffectCount() end

--- Removes the effect at the given 0-based index from the chain.
---@param idx any
function LImageEffect:removeByIndex(idx) end

--- Removes the first effect matching the given type name.
---@param name any
function LImageEffect:removeByName(name) end

--- Removes the effect at the given 1-based index or with the given type name.
---@param key any
function LImageEffect:removeEffect(key) end

--- Stub: no-op serialisation placeholder.
function LImageEffect:save() end

--- Returns the type name "ImageEffect".
function LImageEffect:type() end

--- Returns true when the given name matches "ImageEffect" or a parent type.
---@param name any
function LImageEffect:typeOf(name) end

--- Lua-side wrapper around [`Overlay`].
---@class LOverlay
LOverlay = {}

--- Resets all effect subsystems to their default inactive state.
function LOverlay:clear() end

--- Renders the effect state (flash, fade, effects) to a CPU ImageData.
---@param w any
---@param h any
function LOverlay:drawToImage(w, h) end

--- Animates a full-screen colour fade; alpha defaults to 1.0, duration to 1.0 s.
---@param r any
---@param g any
---@param b any
---@param a? any
---@param dur? any
function LOverlay:fade(r, g, b, a, dur) end

--- Triggers a full-screen colour flash; alpha defaults to 1.0, duration to 0.2 s.
---@param r any
---@param g any
---@param b any
---@param a? any
---@param dur? any
function LOverlay:flash(r, g, b, a, dur) end

--- Returns the current ambient tint as r, g, b, a components.
function LOverlay:getAmbientColor() end

--- Returns the current cloud shadow instance count.
function LOverlay:getCloudCount() end

--- Returns the current cloud shadow opacity.
function LOverlay:getCloudOpacity() end

--- Returns the current cloud shadow scale.
function LOverlay:getCloudScale() end

--- Returns the current cloud shadow scroll speed.
function LOverlay:getCloudSpeed() end

--- Returns the effect width and height.
function LOverlay:getDimensions() end

--- Returns the current film-grain intensity.
function LOverlay:getFilmGrainIntensity() end

--- Returns the current flash overlay alpha value.
function LOverlay:getFlashAlpha() end

--- Returns the current fog tint as r, g, b, a components.
function LOverlay:getFogColor() end

--- Returns the current fog density.
function LOverlay:getFogDensity() end

--- Returns the current heat-haze distortion intensity.
function LOverlay:getHeatHazeIntensity() end

--- Returns the effect height.
function LOverlay:getHeight() end

--- Returns the current lightning overlay alpha value.
function LOverlay:getLightningAlpha() end

--- Returns the lightning flash tint as r, g, b, a components.
function LOverlay:getLightningColor() end

--- Returns the current shake displacement as x, y.
function LOverlay:getShakeOffset() end

--- Returns the current simulated time-of-day (0â€“24).
function LOverlay:getTimeOfDay() end

--- Returns the current vignette strength.
function LOverlay:getVignetteStrength() end

--- Returns a table describing the current water overlay state.
function LOverlay:getWater() end

--- Returns the name of the current weather type.
function LOverlay:getWeather() end

--- Returns the current weather intensity.
function LOverlay:getWeatherIntensity() end

--- Returns the effect width.
function LOverlay:getWidth() end

--- Returns the current wind direction in radians.
function LOverlay:getWindDirection() end

--- Returns the current wind speed.
function LOverlay:getWindSpeed() end

--- Returns true if any effect subsystem is currently active.
function LOverlay:isActive() end

--- Returns whether the ambient light layer is active.
function LOverlay:isAmbientEnabled() end

--- Returns whether cloud shadows are active.
function LOverlay:isCloudShadowsEnabled() end

--- Returns true while a fade effect is in progress.
function LOverlay:isFading() end

--- Returns whether the film-grain layer is active.
function LOverlay:isFilmGrainEnabled() end

--- Returns true while a flash effect is in progress.
function LOverlay:isFlashing() end

--- Returns whether the fog layer is active.
function LOverlay:isFogEnabled() end

--- Returns whether the heat-haze layer is active.
function LOverlay:isHeatHazeEnabled() end

--- Returns true while a shake effect is in progress.
function LOverlay:isShaking() end

--- Returns whether the vignette layer is active.
function LOverlay:isVignetteEnabled() end

--- Returns whether the weather particle system is active.
function LOverlay:isWeatherEnabled() end

--- Emits GPU render commands for all active overlay effects (flash, fade, lightning, vignette).
function LOverlay:render() end

--- Resizes the effect to match new window dimensions.
---@param w any
---@param h any
function LOverlay:resize(w, h) end

--- Sets the ambient light tint colour; alpha defaults to 1.0.
---@param r any
---@param g any
---@param b any
---@param a? any
function LOverlay:setAmbientColor(r, g, b, a) end

--- Enables or disables the ambient light layer.
---@param v any
function LOverlay:setAmbientEnabled(v) end

--- Sets the number of cloud shadow instances to render.
---@param v any
function LOverlay:setCloudCount(v) end

--- Sets the opacity of cloud shadows (0.0 = invisible, 1.0 = fully dark).
---@param v any
function LOverlay:setCloudOpacity(v) end

--- Sets the scale multiplier applied to each cloud shadow.
---@param v any
function LOverlay:setCloudScale(v) end

--- Enables or disables scrolling cloud-shadow projection.
---@param v any
function LOverlay:setCloudShadows(v) end

--- Sets the horizontal scroll speed of cloud shadows in pixels per second.
---@param v any
function LOverlay:setCloudSpeed(v) end

--- Assigns a custom shader name to the effect, or clears it when `nil` is passed.
---@param name? any
function LOverlay:setCustomShader(name) end

--- Enables or disables the film-grain noise layer.
---@param v any
function LOverlay:setFilmGrainEnabled(v) end

--- Sets the film-grain noise intensity (0.0â€“1.0).
---@param v any
function LOverlay:setFilmGrainIntensity(v) end

--- Sets the fog tint colour; alpha defaults to 1.0.
---@param r any
---@param g any
---@param b any
---@param a? any
function LOverlay:setFogColor(r, g, b, a) end

--- Sets the fog density (0.0 = clear, 1.0 = fully opaque).
---@param v any
function LOverlay:setFogDensity(v) end

--- Enables or disables the fog layer.
---@param v any
function LOverlay:setFogEnabled(v) end

--- Enables or disables the heat-haze distortion layer.
---@param v any
function LOverlay:setHeatHazeEnabled(v) end

--- Sets the heat-haze distortion intensity (0.0â€“1.0).
---@param v any
function LOverlay:setHeatHazeIntensity(v) end

--- Sets the lightning flash tint colour; alpha defaults to 1.0.
---@param r any
---@param g any
---@param b any
---@param a? any
function LOverlay:setLightningColor(r, g, b, a) end

--- Sets the simulated time-of-day (0â€“24) which drives ambient colour.
---@param v any
function LOverlay:setTimeOfDay(v) end

--- Enables or disables the screen-edge vignette layer.
---@param v any
function LOverlay:setVignetteEnabled(v) end

--- Sets the vignette darkening strength (0.0â€“1.0).
---@param v any
function LOverlay:setVignetteStrength(v) end

--- Enables the water UV-distortion overlay and sets its wave parameters.
---@param amplitude any
---@param frequency any
---@param speed any
function LOverlay:setWater(amplitude, frequency, speed) end

--- Sets the water tint colour and blend strength.
---@param r any
---@param g any
---@param b any
---@param strength any
function LOverlay:setWaterTint(r, g, b, strength) end

--- Sets the active weather type by name ("none", "rain", "snow", "hail", "dust", "leaves", "ash", "pollen").
---@param name any
function LOverlay:setWeather(name) end

--- Enables or disables the weather particle system.
---@param v any
function LOverlay:setWeatherEnabled(v) end

--- Sets the particle spawn rate multiplier (0.0â€“1.0).
---@param v any
function LOverlay:setWeatherIntensity(v) end

--- Sets the wind direction in radians (0 = right, Ď€/2 = down).
---@param v any
function LOverlay:setWindDirection(v) end

--- Sets the wind speed applied to weather particles in units per second.
---@param v any
function LOverlay:setWindSpeed(v) end

--- Triggers a camera shake; duration defaults to 0.5 s.
---@param intensity any
---@param dur? any
function LOverlay:shake(intensity, dur) end

--- Triggers a screen fade effect to the given colour and alpha.
---@param r any
---@param g any
---@param b any
---@param target_alpha any
---@param duration any
function LOverlay:triggerFade(r, g, b, target_alpha, duration) end

--- Triggers a screen-wide colour flash effect.
---@param r any
---@param g any
---@param b any
---@param a any
---@param duration any
function LOverlay:triggerFlash(r, g, b, a, duration) end

--- Triggers a lightning flash effect.
function LOverlay:triggerLightning() end

--- Triggers a screen shake effect with the given intensity and duration.
---@param intensity any
---@param duration any
function LOverlay:triggerShake(intensity, duration) end

--- Returns the type name of this object ("Overlay").
function LOverlay:type() end

--- Returns true if this object is of the given type ("Object" or "Overlay").
---@param name any
function LOverlay:typeOf(name) end

--- Advances all effect subsystems by the given delta time.
---@param dt any
function LOverlay:update(dt) end

--- Lua-side wrapper around [`PostFxEffect`].
---@class LPostFxEffect
LPostFxEffect = {}

--- Disables auto-injection of common uniforms into shader slot p[3].
function LPostFxEffect:disableAutoUniforms() end

--- Enables auto-injection of common uniforms into shader slot p[3] each frame.
function LPostFxEffect:enableAutoUniforms() end

--- Returns the type name of this effect (alias for getTypeName).
function LPostFxEffect:getEffectType() end

--- Returns a named parameter value, or the default if not set.
---@param name any
---@param default? any
function LPostFxEffect:getParameter(name, default) end

--- Returns a list of all parameter names on this effect.
function LPostFxEffect:getParameterNames() end

--- Returns the type name of this effect (alias for getTypeName).
function LPostFxEffect:getType() end

--- Returns the display name of this effect type.
function LPostFxEffect:getTypeName() end

--- Returns true if the named parameter exists on this effect.
---@param name any
function LPostFxEffect:hasParameter(name) end

--- Returns whether auto-uniform injection is enabled for this effect.
function LPostFxEffect:isAutoUniforms() end

--- Returns true if this is a built-in effect, false if custom.
function LPostFxEffect:isBuiltIn() end

--- Returns whether this effect is currently active.
function LPostFxEffect:isEnabled() end

--- Sets the brightness parameter of this effect.
---@param v any
function LPostFxEffect:setBrightness(v) end

--- Sets the contrast parameter of this effect.
---@param v any
function LPostFxEffect:setContrast(v) end

--- Enables or disables this effect.
---@param enabled any
function LPostFxEffect:setEnabled(enabled) end

--- Sets the intensity parameter of this effect.
---@param v any
function LPostFxEffect:setIntensity(v) end

--- Sets the offset parameter of this effect.
---@param v any
function LPostFxEffect:setOffset(v) end

--- Sets a named float parameter on this effect.
---@param name any
---@param value any
function LPostFxEffect:setParameter(name, value) end

--- Sets the radius parameter of this effect.
---@param v any
function LPostFxEffect:setRadius(v) end

--- Sets the saturation parameter of this effect.
---@param v any
function LPostFxEffect:setSaturation(v) end

--- Sets the scanline strength parameter of this effect.
---@param v any
function LPostFxEffect:setScanlineStrength(v) end

--- Sets the strength parameter of this effect.
---@param v any
function LPostFxEffect:setStrength(v) end

--- Sets the threshold parameter of this effect.
---@param v any
function LPostFxEffect:setThreshold(v) end

--- Returns the type name "PostFxEffect".
function LPostFxEffect:type() end

--- Returns true when the given name matches "PostFxEffect" or a parent type.
---@param name any
function LPostFxEffect:typeOf(name) end

--- Lua-side wrapper around [`PostFxStack`].
---@class LPostFxStack
LPostFxStack = {}

--- Appends a PostFxEffect to the end of the pipeline.
---@param effect_ud any
function LPostFxStack:add(effect_ud) end

--- Applies all enabled effects in the stack and composites the result to screen.
function LPostFxStack:apply() end

--- Begins capturing the scene for post-processing.
function LPostFxStack:beginCapture() end

--- Removes all effects from the pipeline.
function LPostFxStack:clear() end

--- Resets the feedback intensity to `0.0` (disables feedback).
function LPostFxStack:clearFeedback() end

--- Removes duplicate effects from the pipeline, keeping the first occurrence
function LPostFxStack:dedup() end

--- Ends scene capture for post-processing.
function LPostFxStack:endCapture() end

--- Returns width and height of the render target.
function LPostFxStack:getDimensions() end

--- Returns the effect at the given 1-based position, or nil.
---@param index any
function LPostFxStack:getEffect(index) end

--- Returns the number of effects in the pipeline.
function LPostFxStack:getEffectCount() end

--- Returns a list of currently enabled effect objects.
function LPostFxStack:getEnabledEffects() end

--- Returns the current feedback loop intensity `[0.0, 1.0]`.
function LPostFxStack:getFeedback() end

--- Returns the height of the render target.
function LPostFxStack:getHeight() end

--- Returns the width of the render target.
function LPostFxStack:getWidth() end

--- Inserts a PostFxEffect at a specific 1-based position in the pipeline.
---@param position any
---@param effect_ud any
function LPostFxStack:insert(position, effect_ud) end

--- Returns whether the stack is currently capturing the scene.
function LPostFxStack:isCapturing() end

--- Returns true if the pipeline has no effect slots.
function LPostFxStack:isEmpty() end

--- Returns whether the effect at the given 1-based position is enabled.
---@param position any
function LPostFxStack:isEnabled(position) end

--- Returns the total number of effect slots in the pipeline.
function LPostFxStack:len() end

--- Removes the given PostFxEffect from the pipeline.
---@param effect_ud any
function LPostFxStack:remove(effect_ud) end

--- Resizes the render target to the given dimensions.
---@param w any
---@param h any
function LPostFxStack:resize(w, h) end

--- Enables or disables the effect at the given 1-based position.
---@param position any
---@param enabled any
function LPostFxStack:setEnabled(position, enabled) end

--- Sets the feedback loop intensity. At `0.0` (default) there is no
---@param factor any
function LPostFxStack:setFeedback(factor) end

--- Returns the type name "PostFxStack".
function LPostFxStack:type() end

--- Returns true when the given name matches "PostFxStack" or a parent type.
---@param name any
function LPostFxStack:typeOf(name) end

--- Lua-side wrapper around a [`crate::effect::ScreenTransition`].
---@class LScreenTransition
LScreenTransition = {}

--- Returns the fill color as four numbers: `r, g, b, a`.
function LScreenTransition:color() end

--- Returns `true` while the transition is running.
function LScreenTransition:isActive() end

--- Returns `true` after the transition has completed.
function LScreenTransition:isDone() end

--- Returns the transition kind name (`"fade"`, `"wipe"`, `"iris_wipe"`,
function LScreenTransition:kind() end

--- Starts the transition playing forward (scene fades/wipes out).
function LScreenTransition:play() end

--- Returns the fractional progress `[0, 1]` of the transition, taking
function LScreenTransition:progress() end

--- Starts the transition in reverse (scene fades/wipes in).
function LScreenTransition:reverse() end

--- Updates the fill color from `{r, g, b, a?}`.
function LScreenTransition:setColor() end

--- Returns the type name of this object ("ScreenTransition").
function LScreenTransition:type() end

--- Returns true if this object is of the given type name or a parent type.
---@param name any
function LScreenTransition:typeOf(name) end

--- Advances the transition by `dt` seconds. Returns `true` while
---@param dt any
function LScreenTransition:update(dt) end

--- Returns the list of all built-in effect type names.
lurek.effect.getEffectTypes = function() end

--- Returns whether shader error display is currently enabled.
lurek.effect.getShaderErrorDisplay = function() end

--- Creates a custom shader post-processing effect.
---@param shader_id any
lurek.effect.newCustomEffect = function(shader_id) end

--- Creates a new built-in post-processing effect by type name.
---@param type_name any
lurek.effect.newEffect = function(type_name) end

--- Creates a new per-image effect chain. Accepts:
---@param ... any
lurek.effect.newImageEffect = function(...) end

--- Creates a new screen overlay controller for weather, flash, shake, and fade effects.
---@param w? any
---@param h? any
lurek.effect.newOverlay = function(w, h) end

--- Creates a custom-shader post-processing effect (alias for newCustomEffect).
---@param shader_id any
lurek.effect.newPass = function(shader_id) end

--- Creates a pre-configured effect stack from a named preset.
---@param name any
---@param w? any
---@param h? any
lurek.effect.newPresetStack = function(name, w, h) end

--- Creates a new post-processing pipeline stack.
---@param w? any
---@param h? any
lurek.effect.newStack = function(w, h) end

--- Creates a new screen-transition controller. `kind` is one of:
---@param kind? any
---@param duration? any
---@param color_tbl? any
lurek.effect.newTransition = function(kind, duration, color_tbl) end

--- Enables or disables the effect that renders shader compile errors as red text
---@param enabled any
lurek.effect.setShaderErrorDisplay = function(enabled) end

---@class lurek.engine
lurek.engine = {}

--- Returns the current measured frames-per-second.
lurek.engine.fps = function() end

--- Returns the total number of frames processed since engine start.
lurek.engine.frameCount = function() end

--- Returns the target frame budget in milliseconds (default: 1000 / 60 â‰ 16.667 ms).
lurek.engine.getFrameBudget = function() end

--- Returns a table with resident resource memory statistics.
lurek.engine.getResourceStats = function() end

--- Returns the engine version string (from `Cargo.toml`).
lurek.engine.getVersion = function() end

--- Returns `true` if the engine was compiled in debug mode.
lurek.engine.isDebug = function() end

--- Returns a table with `lua_bytes` (Lua GC heap usage in bytes) and
lurek.engine.memoryUsage = function() end

--- Returns a string identifying the host operating system:
lurek.engine.platform = function() end

--- Sets the maximum resident texture memory budget in bytes.
---@param budget_bytes any
lurek.engine.setResourceBudget = function(budget_bytes) end

--- Returns the total engine uptime in seconds (sum of all processed deltas).
lurek.engine.uptime = function() end

---@class lurek.signal
lurek.signal = {}

--- Lua-side wrapper around a [`Signal`] with registry-stored callbacks.
---@class LSignal
LSignal = {}

--- Removes every callback registered for the specified event name and releases their Lua registry entries.
---@param name string The event name whose callbacks should be cleared
---@return number The number of callbacks that were removed
function LSignal:clear(name) end

--- Removes every callback across all event names in this Signal instance, effectively resetting it to an empty state.
---@return number The total number of callbacks that were removed
function LSignal:clearAll() end

--- Subscribes to an event name or wildcard glob pattern and returns a handle.
---@param name string An event name or wildcard pattern (e.g. "player.*")
---@param func function The Lua function to invoke when a matching event fires
---@return number A unique handle ID for this subscription
function LSignal:connect(name, func) end

--- Fires all callbacks registered for the named event, passing any extra arguments to each callback function.
---@param ... string
---@return nil No return value.
function LSignal:emit(...) end

--- Returns the number of callbacks currently registered for the specified event name.
---@param name string The event name to query
---@return number The number of active callbacks for this event
function LSignal:getCount(name) end

--- Returns the total number of callbacks registered across all event names in this Signal instance.
---@return number The total number of active callbacks
function LSignal:getTotalCount() end

--- Registers a one-shot callback that fires at most once for the named event and then automatically removes itself.
---@param name string The event name to subscribe to (case-sensitive)
---@param callback function The Lua function to invoke exactly once
---@return number A unique handle ID for this one-shot subscription
function LSignal:once(name, callback) end

--- Registers a Lua callback function for the named event and returns a numeric handle ID.
---@param name string The event name to subscribe to (case-sensitive)
---@param callback function The Lua function to invoke when the event fires
---@return number A unique handle ID for this subscription
function LSignal:register(name, callback) end

--- Registers a callback with an associated filter predicate function.
---@param name string The event name to subscribe to (case-sensitive)
---@param callback function The Lua function to invoke when the filter passes
---@param filter function A predicate function that receives emit args and returns boolean
---@return number A unique handle ID for this filtered subscription
function LSignal:registerWithFilter(name, callback, filter) end

--- Removes a previously registered subscription identified by its numeric handle.
---@param handle integer The subscription handle returned by `register` or `once`
---@return boolean True if the subscription existed and was removed
function LSignal:remove(handle) end

--- Returns the string type name of this userdata object.
---@return string The type name (e.g. "LScheduler", "LCamera", "LSignal")
function LSignal:type() end

--- Returns true if the given type name matches this object's type or any parent type.
---@param name string type name to test
---@return boolean Boolean result.
function LSignal:typeOf(name) end

--- Discards every pending event in the engine event queue without processing them.
---@return nil No return value.
lurek.signal.clear = function() end

--- Clears all recorded event history entries from the ring buffer.
---@return nil No return value.
lurek.signal.clearHistory = function() end

--- Enables event history recording, keeping a ring buffer of the last `capacity` events pushed via `push()`.
---@param capacity integer Maximum number of events to retain (0 to disable)
---@return nil No return value.
lurek.signal.enableHistory = function(capacity) end

--- Pushes an exit event onto the engine event queue, requesting a graceful shutdown at the end of the current frame.
---@param code integer|nil Optional OS exit code (default 0)
---@return nil No return value.
lurek.signal.exit = function(code) end

--- Moves all events from the deferred buffer into the main engine event queue and clears the buffer.
---@return number The number of deferred events moved to the main queue
lurek.signal.flushDeferred = function() end

--- Returns an array of recently pushed events as tables.
---@return table Array of {name: string, args: table} event records
lurek.signal.getHistory = function() end

--- Creates and returns a new independent Signal pub-sub dispatcher.
---@return LSignal A new empty Signal instance
lurek.signal.newSignal = function() end

--- Returns an iterator function that pops events one at a time from the engine event queue.
---@return function An iterator function that yields (name, ...) tuples
lurek.signal.poll = function() end

--- Synchronises OS-level windowing events into the engine event queue.
---@return nil No return value.
lurek.signal.pump = function() end

---@param ... any
lurek.signal.push = function(...) end

--- Pushes a named event into the deferred buffer instead of the main queue.
---@param ... string
---@return nil No return value.
lurek.signal.pushDeferred = function(...) end

--- Alias for `exit()` - requests the engine to stop gracefully at the end of the current frame with exit code 0.
---@return nil No return value.
lurek.signal.quit = function() end

--- Requests that the engine perform a full restart at the beginning of the next frame.
---@return nil No return value.
lurek.signal.restart = function() end

--- Blocks the current thread until the next engine event arrives or the optional timeout (in seconds) elapses.
---@param timeout number|nil Maximum seconds to wait (nil = wait indefinitely)
---@return string The event name and payload values, or nil on timeout
lurek.signal.wait = function(timeout) end

---@class lurek.filesystem
lurek.filesystem = {}

--- Lua-side wrapper around a [`FileData`] buffer.
---@class LFileData
LFileData = {}

--- Returns the virtual path this data was loaded from.
function LFileData:getFilename() end

--- Returns the file size in bytes.
function LFileData:getSize() end

--- Returns the file content as a Lua string.
function LFileData:getString() end

--- Returns the type name of this object.
function LFileData:type() end

--- Returns true if this object is of the given type.
---@param name any
function LFileData:typeOf(name) end

--- Lua-side wrapper around a [`FileHandle`] with interior mutability.
---@class LFileHandle
LFileHandle = {}

--- Flushes any pending writes and closes the file handle.
function LFileHandle:close() end

--- Flushes all buffered writes to disk without closing the handle.
function LFileHandle:flush() end

--- Returns the access mode the file was opened with.
function LFileHandle:getMode() end

--- Returns the size of the open file in bytes.
function LFileHandle:getSize() end

--- Returns whether the read cursor has reached the end of the file.
function LFileHandle:isEOF() end

--- Reads bytes from the file, returning them as a string.
---@param count? any
function LFileHandle:read(count) end

--- Reads the next line from the file without the trailing newline.
function LFileHandle:readLine() end

--- Seeks the file position to the given byte offset from the start.
---@param pos any
function LFileHandle:seek(pos) end

--- Returns the current read/write byte offset from the start of the file.
function LFileHandle:tell() end

--- Returns the type name of this object.
function LFileHandle:type() end

--- Returns true if this object is of the given type.
---@param name any
function LFileHandle:typeOf(name) end

--- Writes a string to the file and returns the number of bytes written.
---@param data any
function LFileHandle:write(data) end

--- Lua userdata wrapper around a [`ZipMount`].
---@class LZipMount
LZipMount = {}

--- Returns true if `virtual_path` exists inside this ZIP mount.
---@param virtual_path any
function LZipMount:contains(virtual_path) end

--- Returns a sorted array of all virtual paths exposed by this ZIP mount.
function LZipMount:listFiles() end

--- Returns the virtual path prefix this archive was mounted under.
function LZipMount:prefix() end

--- Reads a file from the ZIP and returns it as a string of bytes.
---@param virtual_path any
function LZipMount:readFile(virtual_path) end

--- Returns the type name of this object.
function LZipMount:type() end

--- Returns true if this object is of the given type.
---@param name any
function LZipMount:typeOf(name) end

--- Opens the file in append mode and writes the given string at the end.
---@param path any
---@param data any
lurek.filesystem.append = function(path, data) end

--- Copies a file within the sandbox.
---@param src any
---@param dst any
lurek.filesystem.copy = function(src, dst) end

--- Creates a directory and any missing parent directories in the save area.
---@param path any
lurek.filesystem.createDirectory = function(path) end

--- Creates an empty temporary file in the `save/` sandbox and returns its
---@param prefix? any
lurek.filesystem.createTempFile = function(prefix) end

--- Returns whether the given file or directory exists.
---@param path any
lurek.filesystem.exists = function(path) end

--- Returns a table containing the names of every file and subdirectory in the given path.
---@param path any
lurek.filesystem.getDirectoryItems = function(path) end

--- Returns the identity string used to locate the game's save directory.
lurek.filesystem.getIdentity = function() end

--- Returns a table of metadata for a path, or nil if the path does not exist.
---@param path any
lurek.filesystem.getInfo = function(path) end

--- Returns the sandboxed save data directory path.
lurek.filesystem.getSaveDirectory = function() end

--- Returns the absolute path of the directory the game was loaded from.
lurek.filesystem.getSource = function() end

--- Returns the current user's home directory path.
lurek.filesystem.getUserDirectory = function() end

--- Returns the current working directory path.
lurek.filesystem.getWorkingDirectory = function() end

--- Returns a sorted list of paths matching a simple wildcard pattern.
---@param pattern any
lurek.filesystem.glob = function(pattern) end

--- Returns whether the given path is a directory.
---@param path any
lurek.filesystem.isDirectory = function(path) end

--- Returns whether the given path is a regular file.
---@param path any
lurek.filesystem.isFile = function(path) end

--- Returns an iterator function over the lines of a text file.
---@param path any
lurek.filesystem.lines = function(path) end

--- Returns a sorted list of all files under `path`, recursively.
---@param path any
lurek.filesystem.listRecursive = function(path) end

--- Loads and compiles a Lua file from the VFS, returning it as a callable function.
---@param path any
lurek.filesystem.load = function(path) end

--- Creates a directory (and any missing parents) relative to the game root.
---@param path any
lurek.filesystem.mkdir = function(path) end

--- Mounts a directory at a virtual path inside the game filesystem.
---@param src any
---@param mp any
lurek.filesystem.mount = function(src, mp) end

--- Mounts a ZIP archive at a virtual path prefix, making its contents readable
---@param archive_path any
---@param prefix any
lurek.filesystem.mountZip = function(archive_path, prefix) end

--- Moves (renames) a file within the `save/` directory.
---@param src any
---@param dst any
lurek.filesystem.move = function(src, dst) end

--- Loads a file from the VFS into a FileData buffer.
---@param path any
lurek.filesystem.newFileData = function(path) end

--- Opens a file and returns a readable/writable file handle.
---@param path any
---@param mode any
lurek.filesystem.openFile = function(path, mode) end

--- Polls an async load handle, returning status and optional data.
---@param handle_id any
lurek.filesystem.pollAsync = function(handle_id) end

--- Polls all watched paths and returns an array of paths that changed since the
lurek.filesystem.pollWatchers = function() end

--- Reads a text file and returns its contents as a string.
---@param path any
lurek.filesystem.read = function(path) end

--- Starts loading a file in the background and returns an opaque handle.
---@param path any
lurek.filesystem.readAsync = function(path) end

--- Permanently deletes a file or empty directory from the save directory.
---@param path any
lurek.filesystem.remove = function(path) end

--- Recursively deletes a directory and all its contents within `save/`.
---@param path any
lurek.filesystem.removeDir = function(path) end

--- Sets the identity string that names the game's sandboxed save-data directory.
---@param name any
lurek.filesystem.setIdentity = function(name) end

--- Returns lightweight file statistics for the given path.
---@param path any
lurek.filesystem.stat = function(path) end

--- Resolves a path relative to the game root to an absolute OS path string.
---@param path any
lurek.filesystem.toAbsolutePath = function(path) end

--- Removes a virtual mount layer by mountpoint.
---@param mp any
lurek.filesystem.unmount = function(mp) end

--- Removes `path` from the polled file-watch list.  No-op if not watched.
---@param path any
lurek.filesystem.unwatchPath = function(path) end

--- Adds `path` to the polled file-watch list.
---@param path any
lurek.filesystem.watchPath = function(path) end

--- Writes a string to a file in the save directory.
---@param path any
---@param data any
lurek.filesystem.write = function(path, data) end

---@class lurek.globe
lurek.globe = {}

--- Lua-accessible handle to a `Globe` inside a `GlobeRegistry`.
---@class LGlobe
LGlobe = {}

--- Add an arc (great-circle path between two lat/lon points).
---@param lat1 any
---@param lon1 any
---@param lat2 any
---@param lon2 any
---@param steps? any
function LGlobe:addArc(lat1, lon1, lat2, lon2, steps) end

--- Add a text label. Returns label ID.
---@param ltype any
---@param lat any
---@param lon any
---@param text any
function LGlobe:addLabel(ltype, lat, lon, text) end

--- Add or replace a named thematic layer.
---@param name any
---@param z_order? any
function LGlobe:addLayer(name, z_order) end

--- Add a marker. Returns marker ID.
---@param mtype any
---@param lat any
---@param lon any
---@param label? any
function LGlobe:addMarker(mtype, lat, lon, label) end

--- Adds a province from a table {id, centroid={lat,lon}, vertices={{lat,lon},...},
---@param p any
function LGlobe:addProvince(p) end

--- Find the shortest province path from `from_id` to `to_id`.
---@param from_id any
---@param to_id any
function LGlobe:findPath(from_id, to_id) end

--- Get the current camera (lat, lon, zoom).
function LGlobe:getCamera() end

--- Returns the current LOD tier as a string: "far", "mid", or "near".
function LGlobe:getLod() end

--- Get a string attribute from a marker.
---@param id any
---@param key any
function LGlobe:getMarkerAttr(id, key) end

--- Returns the string identifier name assigned to this globe instance.
function LGlobe:getName() end

--- Returns the neighbor IDs of a province.
---@param id any
function LGlobe:getNeighbors(id) end

--- Gets a string attribute from a province.
---@param id any
---@param key any
function LGlobe:getProvinceAttr(id, key) end

--- Gets the current simulated time of day for daylight computation.
function LGlobe:getTimeOfDay() end

--- Hide a province for a viewer.
---@param viewer any
---@param id any
function LGlobe:hideProvince(viewer, id) end

--- Returns true if the province is visible to the viewer.
---@param viewer any
---@param id any
function LGlobe:isVisible(viewer, id) end

--- Move a marker to a new lat/lon.
---@param id any
---@param lat any
---@param lon any
function LGlobe:moveMarker(id, lat, lon) end

--- Pan the orbit camera by delta-latitude and delta-longitude (degrees).
---@param dlat any
---@param dlon any
function LGlobe:pan(dlat, dlon) end

--- Returns the province ID under screen coordinates, or nil.
---@param sx any
---@param sy any
function LGlobe:pick(sx, sy) end

--- Returns (lat, lon) of the screen point on the globe surface, or nil.
---@param sx any
---@param sy any
function LGlobe:pickLatLon(sx, sy) end

--- Returns the number of provinces.
function LGlobe:provinceCount() end

--- Return all provinces reachable within `max_cost` steps from `start_id`.
---@param start_id any
---@param max_cost any
function LGlobe:reachable(start_id, max_cost) end

--- Removes an arc from the globe map by its unique string identifier.
---@param id any
function LGlobe:removeArc(id) end

--- Removes a text label from the globe map by its unique string identifier.
---@param id any
function LGlobe:removeLabel(id) end

--- Removes a texture layer from the globe map by its unique string identifier.
---@param name any
function LGlobe:removeLayer(name) end

--- Removes a marker from the globe map by its unique string identifier.
---@param id any
function LGlobe:removeMarker(id) end

--- Removes a province by ID. Returns true if it existed.
---@param id any
function LGlobe:removeProvince(id) end

--- Reveal all provinces for a viewer.
---@param viewer any
function LGlobe:revealAll(viewer) end

--- Reveal a province for a viewer.
---@param viewer any
---@param id any
function LGlobe:revealProvince(viewer, id) end

--- Set the faction/viewer whose fog mask filters rendering.
---@param viewer? any
function LGlobe:setActiveViewer(viewer) end

--- Enable or disable province border rendering.
---@param show any
function LGlobe:setBorders(show) end

--- Set the camera position directly.
---@param lat any
---@param lon any
---@param z any
function LGlobe:setCamera(lat, lon, z) end

--- Updates the visible text content of an existing globe label.
---@param id any
---@param text any
function LGlobe:setLabelText(id, text) end

--- Sets whether this specific label is visible on the globe.
---@param id any
---@param vis any
function LGlobe:setLabelVisible(id, vis) end

--- Set layer opacity (0.0–1.0).
---@param name any
---@param alpha any
function LGlobe:setLayerAlpha(name, alpha) end

--- Set a per-province color override on a layer.
---@param layer any
---@param id any
---@param r any
---@param g any
---@param b any
---@param a any
function LGlobe:setLayerColor(layer, id, r, g, b, a) end

--- Sets whether this specific texture layer is visible on the globe.
---@param name any
---@param vis any
function LGlobe:setLayerVisible(name, vis) end

--- Set a string attribute on a marker.
---@param id any
---@param key any
---@param val any
function LGlobe:setMarkerAttr(id, key, val) end

--- Sets whether this specific marker is visible on the globe.
---@param id any
---@param vis any
function LGlobe:setMarkerVisible(id, vis) end

--- Sets a string attribute on a province.
---@param id any
---@param key any
---@param val any
function LGlobe:setProvinceAttr(id, key, val) end

--- Set planet rotation (degrees).
---@param deg any
function LGlobe:setRotation(deg) end

--- Set time of day (0.0–24.0 hours).
---@param t any
function LGlobe:setTimeOfDay(t) end

--- Returns the type name of this object.
function LGlobe:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGlobe:typeOf(name) end

--- Advance globe simulation by dt seconds.
---@param dt any
function LGlobe:update(dt) end

--- Zoom the camera by a multiplier (>1 zooms in, <1 zooms out).
---@param factor any
function LGlobe:zoom(factor) end

--- Lua-accessible handle to the shared `GlobeRegistry`.
---@class LGlobeRegistry
LGlobeRegistry = {}

--- Get an existing globe by name, or nil.
---@param name any
function LGlobeRegistry:get(name) end

--- Returns a table of all globe names.
function LGlobeRegistry:names() end

--- Create a globe with the given name and optional spec table.
---@param name any
---@param spec_tbl? any
function LGlobeRegistry:new(name, spec_tbl) end

--- Removes a globe from the central registry by its string name.
---@param name any
function LGlobeRegistry:remove(name) end

--- Returns the type name of this object.
function LGlobeRegistry:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGlobeRegistry:typeOf(name) end

--- Get an existing globe by name, or nil.
---@param name any
lurek.globe.get = function(name) end

--- Great-circle distance between two lat/lon points (in unit-sphere radians).
---@param la any
---@param lo any
---@param lb any
---@param lo2 any
lurek.globe.greatCircleDistance = function(la, lo, lb, lo2) end

--- Great-circle path as a table of {lat, lon} pairs.
---@param la any
---@param lo any
---@param lb any
---@param lo2 any
---@param n any
lurek.globe.greatCirclePath = function(la, lo, lb, lo2, n) end

--- Convert lat/lon (degrees) to a unit-sphere Cartesian vector {x, y, z}.
---@param lat any
---@param lon any
lurek.globe.latLonToUnit = function(lat, lon) end

--- Load provinces from a TOML string and create a globe.
---@param name any
---@param toml_src any
---@param spec_tbl? any
lurek.globe.loadFromTOML = function(name, toml_src, spec_tbl) end

--- Creates a new globe instance with default settings and empty collections.
---@param name any
---@param spec_tbl? any
lurek.globe.new = function(name, spec_tbl) end

---@class lurek.graph
lurek.graph = {}

--- Lua wrapper around a directed `Graph` with event callback registry.
---@class LGraph
LGraph = {}

--- Adds a directed edge between two nodes and returns its handle.
---@param from_ud any
---@param to_ud any
---@param edge_type? any
function LGraph:addEdge(from_ud, to_ud, edge_type) end

--- Places an item at a node.
---@param item_ud any
---@param node_ud any
function LGraph:addItem(item_ud, node_ud) end

--- Adds a node and returns its handle.
---@param node_type? any
---@param capacity? any
function LGraph:addNode(node_type, capacity) end

--- Finds the shortest path between two nodes using A*.
---@param from_node any
---@param to_node any
function LGraph:astar(from_node, to_node) end

--- Assigns each node the smallest non-negative integer colour not shared with any
function LGraph:colorGraph() end

--- Creates a new unplaced item and returns its handle.
---@param item_type? any
---@param decay_time? any
function LGraph:createItem(item_type, decay_time) end

--- Finds the shortest path between two nodes using Dijkstra.
---@param from_ud any
---@param to_ud any
function LGraph:findPath(from_ud, to_ud) end

--- Finds the shortest path for a specific item, filtering by item type.
---@param item_ud any
---@param from_ud any
---@param to_ud any
function LGraph:findPathForItem(item_ud, from_ud, to_ud) end

--- Returns weakly connected components as a table of tables of Node handles.
function LGraph:getComponents() end

--- Returns the shortest path distance, or nil if unreachable.
---@param from_ud any
---@param to_ud any
function LGraph:getDistance(from_ud, to_ud) end

--- Returns the edge between two nodes, or nil if none exists.
---@param from_ud any
---@param to_ud any
function LGraph:getEdgeBetween(from_ud, to_ud) end

--- Returns the number of edges in the graph.
function LGraph:getEdgeCount() end

--- Returns a table of all Edge handles.
function LGraph:getEdges() end

--- Returns the number of items in the graph.
function LGraph:getItemCount() end

--- Returns a table of all GraphItem handles.
function LGraph:getItems() end

--- Returns a table of direct neighbor Node handles.
---@param node_ud any
function LGraph:getNeighbors(node_ud) end

--- Returns the number of nodes in the graph.
function LGraph:getNodeCount() end

--- Returns a table of all Node handles.
function LGraph:getNodes() end

--- Returns a table of Node handles reachable from the given node.
---@param from_ud any
---@param max_dist? any
function LGraph:getReachable(from_ud, max_dist) end

--- Returns a statistics snapshot table.
function LGraph:getStats() end

--- Returns true if the graph contains a directed cycle.
function LGraph:hasCycle() end

--- Returns true if the edge exists in the graph.
---@param edge_ud any
function LGraph:hasEdge(edge_ud) end

--- Returns true if the item exists in the graph.
---@param item_ud any
function LGraph:hasItem(item_ud) end

--- Returns true if the node exists in the graph.
---@param node_ud any
function LGraph:hasNode(node_ud) end

--- Returns `true` when the graph can be 2-coloured (bipartite check via BFS).
function LGraph:isBipartite() end

--- Returns edge IDs forming a minimum spanning tree (Kruskal, undirected view).
function LGraph:mst() end

--- Registers a callback for a graph simulation event.
---@param event_name any
---@param func any
function LGraph:on(event_name, func) end

--- Processes all supply/demand declarations and fires event callbacks.
function LGraph:processDemand() end

--- Removes an edge from the graph.
---@param edge_ud any
function LGraph:removeEdge(edge_ud) end

--- Removes an item from the graph entirely.
---@param item_ud any
function LGraph:removeItem(item_ud) end

--- Removes a node from the graph.
---@param node_ud any
function LGraph:removeNode(node_ud) end

--- Sends an item onto an edge to begin transit.
---@param item_ud any
---@param edge_ud any
function LGraph:sendItem(item_ud, edge_ud) end

--- Runs one discrete simulation step and fires event callbacks.
function LGraph:step() end

--- Advances simulation by dt seconds using a parallelised decay phase.
---@param dt any
function LGraph:tickParallel(dt) end

--- Returns a topologically sorted table of Node handles, or nil if a cycle exists.
function LGraph:topologicalSort() end

--- Returns the type name of this object.
function LGraph:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGraph:typeOf(name) end

--- Advances simulation by dt seconds and fires event callbacks.
---@param dt any
function LGraph:update(dt) end

--- Lua handle for an edge inside a `Graph`.
---@class LGraphEdge
LGraphEdge = {}

--- Adds an item type to the edge allow-list.
---@param t any
function LGraphEdge:addAllowedType(t) end

--- Clears the edge allow-list so all item types are permitted.
function LGraphEdge:clearAllowedTypes() end

--- Returns the edge capacity (-1 = unlimited).
function LGraphEdge:getCapacity() end

--- Returns the cooldown duration in seconds.
function LGraphEdge:getCooldown() end

--- Returns the source node handle.
function LGraphEdge:getFrom() end

--- Returns a table of GraphItem handles currently in transit on this edge.
function LGraphEdge:getItemsInTransit() end

--- Returns the speed modifier applied to items in transit.
function LGraphEdge:getSpeedModifier() end

--- Returns items per second this edge can transfer.
function LGraphEdge:getThroughput() end

--- Returns the destination node handle.
function LGraphEdge:getTo() end

--- Returns the travel time in seconds for items on this edge.
function LGraphEdge:getTravelTime() end

--- Returns the edge type string.
function LGraphEdge:getType() end

--- Returns the pathfinding weight of this edge.
function LGraphEdge:getWeight() end

--- Returns true if the edge is active.
function LGraphEdge:isActive() end

--- Returns true if items can travel the edge in either direction.
function LGraphEdge:isBidirectional() end

--- Returns true if the given item type is allowed on this edge.
---@param t any
function LGraphEdge:isItemTypeAllowed(t) end

--- Returns true if the edge is currently on cooldown.
function LGraphEdge:isOnCooldown() end

--- Removes an item type from the edge allow-list.
---@param t any
function LGraphEdge:removeAllowedType(t) end

--- Sets the active state of this edge.
---@param a any
function LGraphEdge:setActive(a) end

--- Sets whether items can travel the edge in either direction.
---@param b any
function LGraphEdge:setBidirectional(b) end

--- Sets the edge capacity (-1 = unlimited).
---@param c any
function LGraphEdge:setCapacity(c) end

--- Sets the cooldown duration in seconds.
---@param c any
function LGraphEdge:setCooldown(c) end

--- Sets the speed modifier applied to items in transit.
---@param m any
function LGraphEdge:setSpeedModifier(m) end

--- Sets items per second this edge can transfer.
---@param t any
function LGraphEdge:setThroughput(t) end

--- Sets the travel time in seconds for items on this edge.
---@param t any
function LGraphEdge:setTravelTime(t) end

--- Sets the edge type string.
---@param t any
function LGraphEdge:setType(t) end

--- Sets the pathfinding weight of this edge.
---@param w any
function LGraphEdge:setWeight(w) end

--- Returns the type name "GraphEdge".
function LGraphEdge:type() end

--- Returns true when the given name matches "GraphEdge" or a parent type.
---@param name any
function LGraphEdge:typeOf(name) end

--- Lua handle for an item inside a `Graph`.
---@class LGraphItem
LGraphItem = {}

--- Returns the decay time in seconds (-1 = immortal).
function LGraphItem:getDecayTime() end

--- Returns the item position: node userdata if at a node, (edge, progress)
function LGraphItem:getPosition() end

--- Returns the item priority.
function LGraphItem:getPriority() end

--- Returns the remaining life in seconds.
function LGraphItem:getRemainingLife() end

--- Returns the item type string.
function LGraphItem:getType() end

--- Returns true if the item is alive.
function LGraphItem:isAlive() end

--- Marks this graph item as dead so it is removed on the next cleanup pass.
function LGraphItem:kill() end

--- Sets the decay time in seconds (-1 = immortal).
---@param t any
function LGraphItem:setDecayTime(t) end

--- Sets the scheduling priority; higher values are processed before lower ones.
---@param p any
function LGraphItem:setPriority(p) end

--- Sets the item type string.
---@param t any
function LGraphItem:setType(t) end

--- Returns the type name of this object.
function LGraphItem:type() end

--- Returns true if this object is of the given type.
---@param name any
function LGraphItem:typeOf(name) end

--- Lua handle for a node inside a `Graph`.
---@class LGraphNode
LGraphNode = {}

--- Declares a demand for the given item type, quantity, and priority.
---@param item_type any
---@param quantity any
---@param priority? any
function LGraphNode:addDemand(item_type, quantity, priority) end

--- Declares a supply of the given item type and quantity at this node.
---@param item_type any
---@param quantity any
function LGraphNode:addSupply(item_type, quantity) end

--- Attaches a string tag to this node for fast group queries.
---@param tag any
function LGraphNode:addTag(tag) end

--- Removes all conversion rules from this node.
function LGraphNode:clearAllConversions() end

--- Removes the conversion rule for the given input type.
---@param in_type any
function LGraphNode:clearConversion(in_type) end

--- Removes all demand declarations from this node.
function LGraphNode:clearDemands() end

--- Removes all supply declarations from this node.
function LGraphNode:clearSupplies() end

--- Removes all tags from this node.
function LGraphNode:clearTags() end

--- Pops the next item from the node queue, or nil if empty.
function LGraphNode:dequeue() end

--- Pushes an item into the node queue.
---@param item_ud any
function LGraphNode:enqueue(item_ud) end

--- Returns the node capacity (-1 = unlimited).
function LGraphNode:getCapacity() end

--- Returns a table of Edge handles connected to this node.
---@param dir? any
function LGraphNode:getEdges(dir) end

--- Returns the flow mode as a string.
function LGraphNode:getFlowMode() end

--- Returns the number of items currently at this node.
function LGraphNode:getItemCount() end

--- Returns a table of GraphItem handles at this node.
function LGraphNode:getItems() end

--- Returns the overflow policy as a string.
function LGraphNode:getOverflowPolicy() end

--- Returns the processing time in seconds.
function LGraphNode:getProcessTime() end

--- Returns the pull filter string, or nil if unset.
function LGraphNode:getPullFilter() end

--- Returns items per second this node pulls.
function LGraphNode:getPullRate() end

--- Returns the push filter string, or nil if unset.
function LGraphNode:getPushFilter() end

--- Returns items per second this node pushes.
function LGraphNode:getPushRate() end

--- Returns the queue capacity (-1 = unlimited).
function LGraphNode:getQueueCapacity() end

--- Returns the number of items currently in the queue.
function LGraphNode:getQueueSize() end

--- Returns a table of tag strings on this node.
function LGraphNode:getTags() end

--- Returns the node type string.
function LGraphNode:getType() end

--- Returns true if this node has the given tag.
---@param tag any
function LGraphNode:hasTag(tag) end

--- Returns true if the node is active.
function LGraphNode:isActive() end

--- Returns true if the node has reached its capacity.
function LGraphNode:isFull() end

--- Returns true if the node queue is enabled.
function LGraphNode:isQueueEnabled() end

--- Removes the demand declaration for the given item type.
---@param item_type any
function LGraphNode:removeDemand(item_type) end

--- Removes the supply declaration for the given item type.
---@param item_type any
function LGraphNode:removeSupply(item_type) end

--- Removes a tag from this node.
---@param tag any
function LGraphNode:removeTag(tag) end

--- Sets the active state of this node.
---@param a any
function LGraphNode:setActive(a) end

--- Sets the node capacity (-1 = unlimited).
---@param c any
function LGraphNode:setCapacity(c) end

--- Adds or replaces a conversion rule on this node.
function LGraphNode:setConversion() end

--- Sets the flow mode from a string.
---@param m any
function LGraphNode:setFlowMode(m) end

--- Sets the overflow policy from a string.
---@param p any
function LGraphNode:setOverflowPolicy(p) end

--- Sets the processing time in seconds.
---@param t any
function LGraphNode:setProcessTime(t) end

--- Sets the pull filter string, or nil to clear.
---@param f? any
function LGraphNode:setPullFilter(f) end

--- Sets items per second this node pulls.
---@param r any
function LGraphNode:setPullRate(r) end

--- Sets the push filter string, or nil to clear.
---@param f? any
function LGraphNode:setPushFilter(f) end

--- Sets items per second this node pushes.
---@param r any
function LGraphNode:setPushRate(r) end

--- Sets the queue capacity (-1 = unlimited).
---@param c any
function LGraphNode:setQueueCapacity(c) end

--- Enables or disables the node queue.
---@param e any
function LGraphNode:setQueueEnabled(e) end

--- Sets the node type string.
---@param t any
function LGraphNode:setType(t) end

--- Returns the type name "GraphNode".
function LGraphNode:type() end

--- Returns true when the given name matches "GraphNode" or a parent type.
---@param name any
function LGraphNode:typeOf(name) end

--- Creates a new empty directed graph for item flow simulation.
lurek.graph.newGraph = function() end

---@class lurek.html
lurek.html = {}

--- Lua wrapper around a shared `HtmlDocument` and its callback registry.
---@class LHtmlDocument
LHtmlDocument = {}

--- Appends stylesheet text after existing CSS rules.
---@param css any
function LHtmlDocument:addCss(css) end

--- Removes all stylesheet rules from this document.
function LHtmlDocument:clearCss() end

--- Builds the current draw command list and discards it for now.
---@param x? any
---@param y? any
function LHtmlDocument:draw(x, y) end

--- Finds the first element whose id attribute matches the given value, or nil.
---@param id any
function LHtmlDocument:getElementById(id) end

--- Returns the source markup used by this document.
function LHtmlDocument:getHtml() end

--- Returns the root element for this document.
function LHtmlDocument:getRoot() end

--- Returns the document layout viewport in UI pixels.
function LHtmlDocument:getViewport() end

--- Returns whether DOM, CSS, viewport, or layout state changed.
function LHtmlDocument:isDirty() end

--- Forwards a key press and emits a keydown event.
---@param key any
function LHtmlDocument:keypressed(key) end

--- Forwards a mouse move event.
---@param x any
---@param y any
function LHtmlDocument:mousemoved(x, y) end

--- Forwards a mouse press and emits a minimal click event.
---@param x any
---@param y any
---@param button? any
function LHtmlDocument:mousepressed(x, y, button) end

--- Forwards a mouse release event.
---@param x any
---@param y any
---@param button? any
function LHtmlDocument:mousereleased(x, y, button) end

--- Removes a document-level event listener.
---@param handle any
function LHtmlDocument:off(handle) end

--- Registers a document-level event listener.
---@param event any
---@param func any
function LHtmlDocument:on(event, func) end

--- Finds the first element matching a supported selector.
---@param selector any
function LHtmlDocument:query(selector) end

--- Returns all elements matching a supported selector in document order.
---@param selector any
function LHtmlDocument:queryAll(selector) end

--- Forces a layout pass immediately.
function LHtmlDocument:relayout() end

--- Replaces this document's stylesheet text.
---@param css any
function LHtmlDocument:setCss(css) end

--- Replaces this document's markup and invalidates existing element handles.
---@param html any
function LHtmlDocument:setHtml(html) end

--- Sets the document layout viewport in UI pixels.
---@param w any
---@param h any
function LHtmlDocument:setViewport(w, h) end

--- Forwards text input and emits an input event for focused input elements.
---@param text any
function LHtmlDocument:textinput(text) end

--- Returns the type name of this object.
function LHtmlDocument:type() end

--- Returns true if this object is of the given type.
---@param name any
function LHtmlDocument:typeOf(name) end

--- Advances document state and runs layout if needed.
---@param dt any
function LHtmlDocument:update(dt) end

--- Forwards a mouse wheel event.
---@param dx any
---@param dy any
function LHtmlDocument:wheelmoved(dx, dy) end

--- Lua wrapper that references a single element inside a shared `HtmlDocument`.
---@class LHtmlElement
LHtmlElement = {}

--- Adds a CSS class to this element.
---@param name any
function LHtmlElement:addClass(name) end

--- Appends HTML inside this element.
---@param html any
function LHtmlElement:appendHtml(html) end

--- Clears focus from this element if it currently has focus.
function LHtmlElement:blur() end

--- Gives focus to this element.
function LHtmlElement:focus() end

--- Returns an attribute value or nil.
---@param name any
function LHtmlElement:getAttribute(name) end

--- Returns the owning HtmlDocument.
function LHtmlElement:getDocument() end

--- Returns this element's inner HTML.
function LHtmlElement:getHtml() end

--- Returns this element's id or nil.
function LHtmlElement:getId() end

--- Returns this element's last computed layout rectangle.
function LHtmlElement:getRect() end

--- Returns an inline or stylesheet value for a property.
---@param name any
function LHtmlElement:getStyle(name) end

--- Returns this element's tag name.
function LHtmlElement:getTagName() end

--- Returns this element's text content.
function LHtmlElement:getText() end

--- Returns whether this element has a CSS class.
---@param name any
function LHtmlElement:hasClass(name) end

--- Removes an element event listener.
---@param handle any
function LHtmlElement:off(handle) end

--- Registers an element event listener.
---@param event any
---@param func any
function LHtmlElement:on(event, func) end

--- Finds the first descendant matching a selector.
---@param selector any
function LHtmlElement:query(selector) end

--- Returns all descendants matching a selector.
---@param selector any
function LHtmlElement:queryAll(selector) end

--- Removes this element from the document tree.
function LHtmlElement:remove() end

--- Removes the named attribute from this element; does nothing if absent.
---@param name any
function LHtmlElement:removeAttribute(name) end

--- Removes a CSS class from this element.
---@param name any
function LHtmlElement:removeClass(name) end

--- Sets or removes an attribute value.
---@param name any
---@param value? any
function LHtmlElement:setAttribute(name, value) end

--- Replaces this element's inner HTML.
---@param html any
function LHtmlElement:setHtml(html) end

--- Sets or removes this element's id.
---@param id? any
function LHtmlElement:setId(id) end

--- Sets or removes an inline style value.
---@param name any
---@param value? any
function LHtmlElement:setStyle(name, value) end

--- Replaces this element's text content.
---@param text any
function LHtmlElement:setText(text) end

--- Toggles a CSS class and returns the final state.
---@param name any
---@param force? any
function LHtmlElement:toggleClass(name, force) end

--- Returns the type name of this object.
function LHtmlElement:type() end

--- Returns true if this object is of the given type.
---@param name any
function LHtmlElement:typeOf(name) end

--- Placeholder for future sandboxed document loading.
---@param path any
---@param opts? any
lurek.html.loadDocument = function(path, opts) end

--- Creates a detached HTML document from markup and optional CSS/viewport options.
---@param source? any
---@param opts? any
lurek.html.newDocument = function(source, opts) end

--- Returns whether the active HTML facade supports a named feature.
---@param feature any
lurek.html.supports = function(feature) end

---@class lurek.i18n
lurek.i18n = {}

--- Builds an inverted word index for the active locale. Returns index as {word â†’ {keys}}.
lurek.i18n.buildIndex = function() end

--- Returns unique first-path-segment category prefixes for all active locale keys.
lurek.i18n.categories = function() end

--- Formats a Unix timestamp according to the active locale's date order.
---@param timestamp any
---@param fmt? any
lurek.i18n.formatDate = function(timestamp, fmt) end

--- Formats a number with locale-aware decimal and thousands separators.
---@param n any
---@param opts? any
lurek.i18n.formatNumber = function(n, opts) end

--- Returns all loaded locale codes (alias for getLanguages).
lurek.i18n.getAvailableLanguages = function() end

--- Returns the base/fallback language.
lurek.i18n.getBase = function() end

--- Returns the current fallback locale array.
lurek.i18n.getFallbacks = function() end

--- Returns all known keys for the active locale.
lurek.i18n.getKeys = function() end

--- Returns the currently active locale code, or nil if unset.
lurek.i18n.getLanguage = function() end

--- Returns all loaded locale codes.
lurek.i18n.getLanguages = function() end

--- Returns an array of all currently loaded locale codes.
lurek.i18n.getLoadedLocales = function() end

--- Returns whether a key exists in the active locale.
---@param key any
lurek.i18n.hasKey = function(key) end

--- Returns whether a locale has been loaded.
---@param locale any
lurek.i18n.hasLanguage = function(locale) end

--- Interpolates {name} placeholders in a template string.
---@param template any
---@param vars any
lurek.i18n.interpolate = function(template, vars) end

--- Returns the number of keys loaded in the active locale.
lurek.i18n.keyCount = function() end

--- Returns all keys in the active locale whose first path segment matches category.
---@param category any
lurek.i18n.keysInCategory = function(category) end

--- Loads a language table under the given locale code.
---@param locale any
---@param tbl any
lurek.i18n.loadTable = function(locale, tbl) end

--- Merges a flat keyâ†’value table into an existing locale without replacing the whole table.
---@param locale any
---@param entries any
lurek.i18n.mergeLocale = function(locale, entries) end

--- Unregisters all onChange callbacks (cb arg is ignored; all callbacks are cleared).
lurek.i18n.offChange = function() end

--- Registers a callback invoked when setLanguage() is called (alias: onChange).
---@param cb any
lurek.i18n.onChange = function(cb) end

--- Registers a callback invoked when setLanguage() is called.
---@param cb any
lurek.i18n.onLanguageChange = function(cb) end

--- Returns the CLDR plural category for a number ("one" or "other", etc.).
---@param n any
lurek.i18n.pluralFor = function(n) end

--- Searches active locale values for a substring query (case-insensitive). Returns {key, value} pairs.
---@param query any
---@param limit? any
lurek.i18n.search = function(query, limit) end

--- Searches the provided pre-built index for entries matching all words in query.
---@param index any
---@param query any
---@param limit? any
lurek.i18n.searchIndexed = function(index, query, limit) end

--- Sets the base/fallback language (adds it as first fallback).
---@param locale any
lurek.i18n.setBase = function(locale) end

--- Sets the ordered list of fallback locale codes tried when a key is missing.
---@param locales any
lurek.i18n.setFallbacks = function(locales) end

--- Inserts or overwrites a single key in the given locale.
---@param locale any
---@param key any
---@param value any
lurek.i18n.setKey = function(locale, key, value) end

--- Sets the active translation language.
---@param locale any
lurek.i18n.setLanguage = function(locale) end

--- Translates a key against the active locale with optional variable
---@param key any
---@param vars? any
---@param count? any
lurek.i18n.t = function(key, vars, count) end

--- Looks up a translation key augmented with a gender suffix.
---@param key any
---@param gender any
---@param vars? any
lurek.i18n.tGender = function(key, gender, vars) end

--- Unloads a locale from the catalog.
---@param locale any
lurek.i18n.unloadTable = function(locale) end

---@class lurek.image
lurek.image = {}

--- Lua-side wrapper around [`CompressedImageData`].
---@class LCompressedImageData
LCompressedImageData = {}

--- Returns the width and height of the base mip level.
function LCompressedImageData:getDimensions() end

--- Returns the compressed format name string.
function LCompressedImageData:getFormat() end

--- Returns the height of the base mip level in pixels.
function LCompressedImageData:getHeight() end

--- Returns the number of mipmap levels stored.
function LCompressedImageData:getMipmapCount() end

--- Returns the width of the base mip level in pixels.
function LCompressedImageData:getWidth() end

--- Returns the type name of this object.
function LCompressedImageData:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCompressedImageData:typeOf(name) end

--- RGBA pixel buffer for software image manipulation, pixel access, and encoding.
---@class LImageData
LImageData = {}

--- Scales every pixel's alpha channel by factor; use to fade an image in or out uniformly.
---@param factor any
function LImageData:alphaMask(factor) end

--- Applies a `PaletteLUT` to the image in place, replacing exact colour matches.
---@param lut_ud any
function LImageData:applyPaletteLut(lut_ud) end

--- Blits the source ImageData onto this image at (dst_x, dst_y) using Porter-Duff over.
---@param src_ud any
---@param dst_x any
---@param dst_y any
function LImageData:blit(src_ud, dst_x, dst_y) end

--- Returns a new ImageData with a box blur applied using the given pixel radius.
---@param radius any
function LImageData:blur(radius) end

--- Adjusts the brightness of every pixel by the given factor (< 1.0 darkens, > 1.0 brightens).
---@param factor any
function LImageData:brightness(factor) end

--- Adjusts the contrast of every pixel by the given factor (< 1.0 reduces, > 1.0 increases).
---@param factor any
function LImageData:contrast(factor) end

--- Applies a custom NxN convolution kernel to the image and returns a new ImageData.
---@param kernel_t any
---@param ksize any
function LImageData:convolve(kernel_t, ksize) end

--- Returns a new ImageData containing the rectangular sub-region at (x, y) of the given width and height.
---@param x any
---@param y any
---@param w any
---@param h any
function LImageData:crop(x, y, w, h) end

--- Returns the sum of absolute per-channel pixel differences with another ImageData.
---@param other_ud any
function LImageData:diff(other_ud) end

--- Draws a filled circle onto the image.
---@param cx any
---@param cy any
---@param radius any
---@param r any
---@param g any
---@param b any
---@param a any
function LImageData:drawCircle(cx, cy, radius, r, g, b, a) end

--- Draws a line using Bresenham's algorithm.
---@param x0 any
---@param y0 any
---@param x1 any
---@param y1 any
---@param r any
---@param g any
---@param b any
---@param a any
function LImageData:drawLine(x0, y0, x1, y1, r, g, b, a) end

--- Draws a filled rectangle onto the image.
---@param x any
---@param y any
---@param w any
---@param h any
---@param r any
---@param g any
---@param b any
---@param a any
function LImageData:drawRect(x, y, w, h, r, g, b, a) end

--- Encodes the image into a byte string in the specified format (currently "png").
---@param format any
function LImageData:encode(format) end

--- Fills every pixel with the given solid RGBA colour, overwriting all existing content.
---@param r any
---@param g any
---@param b any
---@param a any
function LImageData:fill(r, g, b, a) end

--- Flips the image left-to-right (mirror across vertical axis), modifying in place.
function LImageData:flipHorizontal() end

--- Flips the image top-to-bottom (mirror across horizontal axis), modifying in place.
function LImageData:flipVertical() end

--- Applies gamma correction; values < 1.0 brighten shadows, > 1.0 darken them.
---@param gamma any
function LImageData:gamma(gamma) end

--- Returns the width and height of the image as two integers.
function LImageData:getDimensions() end

--- Returns the height of the image in pixels.
function LImageData:getHeight() end

--- Returns the RGBA colour components of the pixel at (x, y) as four integers (0-255).
---@param x any
---@param y any
function LImageData:getPixel(x, y) end

--- Returns a copy of the rectangular sub-region as a new ImageData.
---@param x any
---@param y any
---@param w any
---@param h any
function LImageData:getRegion(x, y, w, h) end

--- Returns the raw pixel bytes of the image as a Lua string.
function LImageData:getString() end

--- Returns the width of the image in pixels.
function LImageData:getWidth() end

--- Converts the image to grayscale using luminance weights (BT.601).
function LImageData:grayscale() end

--- Inverts every colour channel (subtracts each R/G/B value from 255); alpha is preserved.
function LImageData:invert() end

--- Calls func(x, y, r, g, b, a) for each pixel and writes the returned RGBA back.
---@param func any
function LImageData:mapPixel(func) end

--- Applies a function to every pixel in-place.
---@param func any
function LImageData:mapPixels(func) end

--- Adds random noise to every pixel channel; amount controls the maximum per-channel perturbation.
---@param amount any
function LImageData:noise(amount) end

--- Copies pixels from `source` onto this image starting at (dx, dy).
---@param src_ud any
---@param dx any
---@param dy any
function LImageData:paste(src_ud, dx, dy) end

--- Reduces each channel to `levels` discrete steps, creating a flat poster-paint look.
---@param levels any
function LImageData:posterize(levels) end

--- Returns a bilinear-interpolated copy of the image at the given dimensions.
---@param w any
---@param h any
function LImageData:resize(w, h) end

--- Returns a new ImageData scaled to (new_w, new_h) using nearest-neighbour interpolation.
---@param new_w any
---@param new_h any
function LImageData:resizeNearest(new_w, new_h) end

--- Returns a new ImageData rotated 90 degrees clockwise; the original is not modified.
function LImageData:rotate90cw() end

--- Adjusts colour saturation; 0.0 produces grayscale, 1.0 is unchanged, > 1.0 boosts saturation.
---@param factor any
function LImageData:saturation(factor) end

--- Applies a warm sepia tone to the image using standard sepia matrix weights.
function LImageData:sepia() end

--- Sets the RGBA colour of the pixel at (x, y); returns an error if coordinates are out of bounds.
---@param x any
---@param y any
---@param r any
---@param g any
---@param b any
---@param a any
function LImageData:setPixel(x, y, r, g, b, a) end

--- Replaces all pixel data from a raw RGBA byte string.
---@param bytes any
function LImageData:setRawData(bytes) end

--- Returns a new ImageData with a sharpening convolution kernel applied.
function LImageData:sharpen() end

--- Converts the image to black-and-white: pixels above value become white, at or below become black.
---@param value any
function LImageData:threshold(value) end

--- Blends an RGB tint colour into every pixel, controlled by factor (0.0 = no change, 1.0 = full tint).
---@param tr any
---@param tg any
---@param tb any
---@param factor any
function LImageData:tint(tr, tg, tb, factor) end

--- Returns the type name of this object.
function LImageData:type() end

--- Returns true if this object is of the given type name.
---@param name any
function LImageData:typeOf(name) end

--- Lua-side wrapper around [`LayeredImage`].
---@class LLayeredImage
LLayeredImage = {}

--- Appends a new blank transparent layer on top and returns its 1-based index.
---@param name? any
function LLayeredImage:addLayer(name) end

--- Returns the canvas height shared by all layers.
function LLayeredImage:getHeight() end

--- Returns a copy of the layer's pixel buffer as an ImageData.
---@param index any
function LLayeredImage:getLayer(index) end

--- Returns the name of a layer.
---@param index any
function LLayeredImage:getName(index) end

--- Returns the opacity of a layer in [0.0, 1.0].
---@param index any
function LLayeredImage:getOpacity(index) end

--- Returns the canvas width shared by all layers.
function LLayeredImage:getWidth() end

--- Returns whether a layer is visible.
---@param index any
function LLayeredImage:isVisible(index) end

--- Returns the number of layers in the stack.
function LLayeredImage:layerCount() end

--- Flattens all visible layers into a single ImageData using Porter-Duff "over" compositing.
function LLayeredImage:merge() end

--- Moves a layer from one position to another, shifting layers in between.
---@param from_idx any
---@param to_idx any
function LLayeredImage:moveLayer(from_idx, to_idx) end

--- Removes the layer at the given 1-based index. Returns true on success.
---@param index any
function LLayeredImage:removeLayer(index) end

--- Saves the layered image to a LIMG binary file at the given path.
---@param path any
function LLayeredImage:save(path) end

--- Replaces a layer's pixel buffer with a copy of the given ImageData.
---@param index any
---@param img any
function LLayeredImage:setLayer(index, img) end

--- Renames the layer at the given index to the new name string.
---@param index any
---@param name any
function LLayeredImage:setName(index, name) end

--- Sets the opacity of a layer. Value is clamped to [0.0, 1.0].
---@param index any
---@param opacity any
function LLayeredImage:setOpacity(index, opacity) end

--- Shows or hides a layer during compositing.
---@param index any
---@param visible any
function LLayeredImage:setVisible(index, visible) end

--- Swaps two layers by their 1-based indices, changing their compositing order.
---@param a any
---@param b any
function LLayeredImage:swapLayers(a, b) end

--- Returns the type name of this object.
function LLayeredImage:type() end

--- Returns true if this object is of the given type.
---@param name any
function LLayeredImage:typeOf(name) end

--- Lua-side wrapper around [`PaletteLUT`].
---@class LPaletteLUT
LPaletteLUT = {}

--- Removes all colour mapping entries.
function LPaletteLUT:clear() end

--- Returns the number of colour mapping entries.
function LPaletteLUT:getColorCount() end

--- Appends a colour mapping entry to the palette: when a pixel exactly matching
---@param fr any
---@param fg any
---@param fb any
---@param fa any
---@param tr any
---@param tg any
---@param tb any
---@param ta any
function LPaletteLUT:setColor(fr, fg, fb, fa, tr, tg, tb, ta) end

--- Returns the type name of this object.
function LPaletteLUT:type() end

--- Returns true if this object is of the given type.
---@param name any
function LPaletteLUT:typeOf(name) end

--- Lua-side wrapper around [`ProvinceGrid`].
---@class LProvinceGrid
LProvinceGrid = {}

--- Returns an array of adjacency records. Each record is {province_a, province_b, border_pixels}.
function LProvinceGrid:adjacencies() end

--- Returns the province ID at pixel coordinates (x, y). Returns 0 for background or out-of-bounds.
---@param x any
---@param y any
function LProvinceGrid:getAt(x, y) end

--- Returns the grid height in pixels.
function LProvinceGrid:getHeight() end

--- Returns the grid width in pixels.
function LProvinceGrid:getWidth() end

--- Returns the number of unique non-zero province IDs detected in the map.
function LProvinceGrid:provinceCount() end

--- Returns the type name of this object.
function LProvinceGrid:type() end

--- Returns true if this object is of the given type.
---@param name any
function LProvinceGrid:typeOf(name) end

--- Returns true if the file at the given path is a DDS file.
---@param filename any
lurek.image.isCompressed = function(filename) end

--- Loads an ImageData from a LIMG binary file.
---@param filename any
lurek.image.loadImage = function(filename) end

--- Loads a LayeredImage from a LIMG binary file.
---@param filename any
lurek.image.loadLayered = function(filename) end

--- Loads compressed texture data from a DDS file.
---@param filename any
lurek.image.newCompressedData = function(filename) end

--- Creates a new blank ImageData or loads one from a file.
---@param ... any
lurek.image.newImageData = function(...) end

--- Creates a new empty LayeredImage canvas with no layers.
---@param width any
---@param height any
lurek.image.newLayeredImage = function(width, height) end

--- Creates a new empty `PaletteLUT` used to remap colours in an image.
lurek.image.newPaletteLut = function() end

--- Loads a province map PNG and builds an O(1) spatial index with adjacency data.
---@param filename any
lurek.image.newProvinceGrid = function(filename) end

--- Saves a flat ImageData to a LIMG binary file at the given path.
---@param img_ud any
---@param filename any
lurek.image.saveImage = function(img_ud, filename) end

--- Saves a flat ImageData as a PNG file at the given path.
---@param img_ud any
---@param filename any
lurek.image.savePNG = function(img_ud, filename) end

---@class lurek.input
lurek.input = {}

---@class lurek.input.keyboard
lurek.input.keyboard = {}

---@class lurek.input.mouse
lurek.input.mouse = {}

---@class lurek.input.gamepad
lurek.input.gamepad = {}

---@class lurek.input.touch
lurek.input.touch = {}

--- Lua-side wrapper for a [`ComboDetector`] with an integrated millisecond clock.
---@class LCombo
LCombo = {}

--- Feed a key-press event into the combo detector.
---@param key any
function LCombo:feed(key) end

--- Returns the step at the given 1-based index as `{key=..., gap_ms=...}`.
---@param index any
function LCombo:getStep(index) end

--- Returns true if the detector is currently mid-sequence.
function LCombo:isInProgress() end

--- Returns the number of steps matched so far (0 when idle).
function LCombo:progress() end

--- Reset the detector to its initial idle state, cancelling any in-progress sequence.
function LCombo:reset() end

--- Advance the internal clock by `dt` seconds and check for timeouts.
---@param dt any
function LCombo:tick(dt) end

--- Returns the total number of steps in the combo sequence.
function LCombo:totalSteps() end

--- Returns the type name of this object.
function LCombo:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCombo:typeOf(name) end

--- Lua-side wrapper around a mouse cursor handle.
---@class LCursor
LCursor = {}

--- Returns the cursor type as "system" or "custom".
function LCursor:getType() end

--- Releases the cursor resource (no-op on desktop).
function LCursor:release() end

--- Returns the type name of this object.
function LCursor:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCursor:typeOf(name) end

--- Lua userdata wrapper for a completed [`crate::input::recorder::InputRecording`].
---@class LInputRecording
LInputRecording = {}

--- Returns the number of sparse event frames stored in this recording.
function LInputRecording:frameCount() end

--- Serializes this recording to a JSON string for saving to disk.
function LInputRecording:toJson() end

--- Returns the total frame count when recording was stopped.
function LInputRecording:totalFrames() end

--- Returns the type name of this object.
function LInputRecording:type() end

--- Returns true if this object is of the given type.
---@param name any
function LInputRecording:typeOf(name) end

--- Advances playback by one frame and returns an array of key/button events for that
lurek.input.advancePlayback = function() end

--- Maps an action name to one or more key/button names.
---@param action any
---@param keys any
lurek.input.bind = function(action, keys) end

--- Removes all action bindings.
lurek.input.clearBindings = function() end

--- Returns the current value (-1 to 1) of a gamepad analog axis.
---@param id any
---@param axis any
lurek.input.gamepad.getAxis = function(id, axis) end

--- Returns the total number of analog axes on the gamepad.
---@param id any
lurek.input.gamepad.getAxisCount = function(id) end

--- Returns whether background gamepad events are enabled.
lurek.input.gamepad.getBackgroundEvents = function() end

--- Returns a table mapping each action name to its bound keys.
lurek.input.getBindings = function() end

--- Returns the total number of buttons on the gamepad.
---@param id any
lurek.input.gamepad.getButtonCount = function(id) end

--- Returns the number of connected gamepads.
lurek.input.gamepad.getCount = function() end

--- Returns the name of the currently active system cursor.
lurek.input.mouse.getCursor = function() end

--- Returns the hardware GUID string of the gamepad.
---@param id any
lurek.input.gamepad.getGUID = function(id) end

--- Returns the stored mapping string for the given GUID, or nil.
---@param guid any
lurek.input.gamepad.getGamepadMappingString = function(guid) end

--- Returns the direction string of a hat switch on the gamepad.
---@param id any
---@param hat any
lurek.input.gamepad.getHat = function(id, hat) end

--- Returns the number of tracked gamepad slots.
lurek.input.gamepad.getJoystickCount = function() end

--- Returns a list of connected gamepad IDs.
lurek.input.gamepad.getJoysticks = function() end

--- Returns the key name for the given hardware scancode.
---@param scancode any
lurek.input.keyboard.getKeyFromScancode = function(scancode) end

--- Returns the human-readable name of a gamepad.
---@param id any
lurek.input.gamepad.getName = function(id) end

--- Returns the current playback frame index (0-based).  Returns 0 when not playing.
lurek.input.getPlaybackFrame = function() end

--- Returns the current cursor position as (x, y).
lurek.input.mouse.getPosition = function() end

--- Returns the position (x, y) of the touch with the given ID.
---@param id any
lurek.input.touch.getPosition = function(id) end

--- Returns the pressure (0-1) of the touch with the given ID.
---@param id any
lurek.input.touch.getPressure = function(id) end

--- Returns whether relative mouse mode is active.
lurek.input.mouse.getRelativeMode = function() end

--- Returns the hardware scancode for the given key name.
---@param key any
lurek.input.keyboard.getScancodeFromKey = function(key) end

--- Returns a system cursor object for the named cursor shape.
---@param name any
lurek.input.mouse.getSystemCursor = function(name) end

--- Returns the number of currently active touch points.
lurek.input.touch.getTouchCount = function() end

--- Returns a table of active touch points with id, x, y, and pressure fields.
lurek.input.touch.getTouches = function() end

--- Returns the mouse scroll wheel delta (dx, dy) since last frame.
lurek.input.mouse.getWheelDelta = function() end

--- Returns the current mouse X position in window coordinates.
lurek.input.mouse.getX = function() end

--- Returns the current mouse Y position in window coordinates.
lurek.input.mouse.getY = function() end

--- Returns whether key-repeat is currently enabled.
lurek.input.keyboard.hasKeyRepeat = function() end

--- Returns whether text input mode is currently active.
lurek.input.keyboard.hasTextInput = function() end

--- Returns true if any key bound to the action is currently held down.
---@param action any
lurek.input.isActionDown = function(action) end

--- Returns whether the gamepad with the given ID is connected.
---@param id any
lurek.input.gamepad.isConnected = function(id) end

--- Returns whether cursor customisation is supported on this platform.
lurek.input.mouse.isCursorSupported = function() end

--- Returns true if any of the given keys is currently held down.
---@param args any
lurek.input.keyboard.isDown = function(args) end

--- Returns whether the given mouse button is currently held down.
---@param button any
lurek.input.mouse.isDown = function(button) end

--- Returns whether the given button on the gamepad is currently held.
---@param id any
---@param button any
lurek.input.gamepad.isDown = function(id, button) end

--- Returns whether the joystick at the given slot is a recognized gamepad.
---@param id any
lurek.input.gamepad.isGamepad = function(id) end

--- Returns whether the mouse cursor is locked to the window.
lurek.input.mouse.isGrabbed = function() end

--- Returns whether the named modifier key is currently held.
---@param modifier any
lurek.input.keyboard.isModifierActive = function(modifier) end

--- Returns true if input playback is currently active.
lurek.input.isPlayingBack = function() end

--- Returns true if input recording is currently active.
lurek.input.isRecording = function() end

--- Returns whether the key with the given scancode is held.
---@param scancode any
lurek.input.keyboard.isScancodeDown = function(scancode) end

--- Returns whether the gamepad supports haptic vibration.
---@param id any
lurek.input.gamepad.isVibrationSupported = function(id) end

--- Returns whether the mouse cursor is currently visible.
lurek.input.mouse.isVisible = function() end

--- Loads SDL2 GameControllerDB-format mappings from a file.
---@param path any
lurek.input.gamepad.loadGamepadMappings = function(path) end

--- Loads a JSON-encoded recording string for playback.
---@param json any
lurek.input.loadRecording = function(json) end

--- Creates a new combo detector from an ordered list of steps.
---@param steps_val any
---@param opts? any
lurek.input.newCombo = function(steps_val, opts) end

--- Creates a custom mouse cursor from RGBA pixel data.
lurek.input.mouse.newCursor = function() end

--- Saves all stored gamepad mappings to a plain-text file.
---@param path any
lurek.input.gamepad.saveGamepadMappings = function(path) end

--- Enable or disable receiving gamepad events when the window is not focused.
---@param enable any
lurek.input.gamepad.setBackgroundEvents = function(enable) end

--- Sets the active mouse cursor from a Cursor handle, name string, or nil to reset.
---@param cursor_val any
lurek.input.mouse.setCursor = function(cursor_val) end

--- Stores or replaces the SDL2 GameControllerDB mapping string for the given GUID.
---@param guid any
---@param mapping any
lurek.input.gamepad.setGamepadMapping = function(guid, mapping) end

--- Locks or unlocks the mouse cursor to the window.
---@param grabbed any
lurek.input.mouse.setGrabbed = function(grabbed) end

--- Enables or disables key-repeat events.
---@param enabled any
lurek.input.keyboard.setKeyRepeat = function(enabled) end

--- Moves the mouse cursor to the given window-space position.
---@param x any
---@param y any
lurek.input.mouse.setPosition = function(x, y) end

--- Enables or disables raw relative mouse motion mode.
---@param relative any
lurek.input.mouse.setRelativeMode = function(relative) end

--- Enables or disables Unicode text input mode.
---@param enabled any
lurek.input.keyboard.setTextInput = function(enabled) end

--- Triggers haptic rumble (currently a no-op stub).
---@param ... any
lurek.input.gamepad.setVibration = function(...) end

--- Shows or hides the operating-system mouse cursor.
---@param visible any
lurek.input.mouse.setVisible = function(visible) end

--- Starts playback from the beginning of the loaded recording.
lurek.input.startPlayback = function() end

--- Starts capturing input events frame-by-frame.  Clears any previous recording.
lurek.input.startRecording = function() end

--- Stops playback immediately.
lurek.input.stopPlayback = function() end

--- Stops recording and returns an `InputRecording` userdata, or nil if not recording.
lurek.input.stopRecording = function() end

--- Removes all key bindings for the given action name.
---@param action any
lurek.input.unbind = function(action) end

--- Requests haptic vibration on a gamepad.
---@param id any
---@param low_freq any
---@param high_freq any
---@param duration_ms any
lurek.input.gamepad.vibrate = function(id, low_freq, high_freq, duration_ms) end

--- Returns true if any key bound to the action was pressed this frame.
---@param action any
lurek.input.wasActionPressed = function(action) end

--- Was action pressed within.
---@param action any
---@param frames any
lurek.input.wasActionPressedWithin = function(action, frames) end

--- Returns true if any key bound to the action was released this frame.
---@param action any
lurek.input.wasActionReleased = function(action) end

---@class lurek.light
lurek.light = {}

--- Lua-side handle to a light resource stored in [`LightWorld`].
---@class LLight
LLight = {}

--- Convenience method to set a flicker effect using amplitude range and
---@param min any
---@param max any
---@param hz any
function LLight:addFlicker(min, max, hz) end

--- Removes the cookie texture assignment.
function LLight:clearCookie() end

--- Returns the custom attenuation coefficients as (constant, linear, quadratic).
function LLight:getAttenuation() end

--- Returns the blend mode as a string.
function LLight:getBlendMode() end

--- Returns the light's tint color as (r, g, b, a).
function LLight:getColor() end

--- Returns the current cookie texture path, or `nil` if unset.
function LLight:getCookie() end

--- Returns the direction angle in radians.
function LLight:getDirection() end

--- Returns the energy scaling factor.
function LLight:getEnergy() end

--- Returns the falloff mode as a string.
function LLight:getFalloff() end

--- Returns the flicker effect speed and strength.
function LLight:getFlicker() end

--- Returns the group identifier.
function LLight:getGroupId() end

--- Returns the inner cone angle in radians.
function LLight:getInnerAngle() end

--- Returns the brightness multiplier.
function LLight:getIntensity() end

--- Returns the light interaction bitmask.
function LLight:getLightMask() end

--- Returns the geometric light type as a string.
function LLight:getLightType() end

--- Returns the outer cone angle in radians.
function LLight:getOuterAngle() end

--- Returns the light's world-space position.
function LLight:getPosition() end

--- Returns the light's influence radius.
function LLight:getRadius() end

--- Returns the shadow region color as (r, g, b, a).
function LLight:getShadowColor() end

--- Returns the shadow edge filter as a string.
function LLight:getShadowFilter() end

--- Returns the shadow casting bitmask.
function LLight:getShadowMask() end

--- Returns the shadow edge smoothing factor.
function LLight:getShadowSmooth() end

--- Returns whether this light is active.
function LLight:isEnabled() end

--- Returns whether the flicker effect is active.
function LLight:isFlickerEnabled() end

--- Returns whether this light casts shadows.
function LLight:isShadowEnabled() end

--- Returns whether this light handle is still valid.
function LLight:isValid() end

--- Returns whether this light hints at volumetric scattering.
function LLight:isVolumetric() end

--- Removes this light from the world.
function LLight:remove() end

--- Sets the custom attenuation coefficients (constant, linear, quadratic).
---@param c any
---@param l any
---@param q any
function LLight:setAttenuation(c, l, q) end

--- Sets the blend mode ('add', 'sub', or 'mix').
---@param mode any
function LLight:setBlendMode(mode) end

--- Sets the light's tint color.
---@param r any
---@param g any
---@param b any
---@param a? any
function LLight:setColor(r, g, b, a) end

--- Sets the texture path used as a light cookie (mask) for projection.
---@param path any
function LLight:setCookie(path) end

--- Sets the direction angle in radians.
---@param dir any
function LLight:setDirection(dir) end

--- Sets whether this light is active.
---@param b any
function LLight:setEnabled(b) end

--- Sets the energy scaling factor.
---@param e any
function LLight:setEnergy(e) end

--- Sets the falloff mode ('linear', 'smooth', or 'constant').
---@param mode any
function LLight:setFalloff(mode) end

--- Sets the flicker effect speed and strength (enables flicker).
---@param speed any
---@param strength any
function LLight:setFlicker(speed, strength) end

--- Sets whether the flicker effect is active.
---@param b any
function LLight:setFlickerEnabled(b) end

--- Sets the group identifier for batch operations.
---@param id any
function LLight:setGroupId(id) end

--- Sets the inner cone angle in radians for spot lights.
---@param a any
function LLight:setInnerAngle(a) end

--- Sets the brightness multiplier.
---@param i any
function LLight:setIntensity(i) end

--- Sets the light interaction bitmask.
---@param mask any
function LLight:setLightMask(mask) end

--- Sets the geometric light type ('point', 'directional', or 'spot').
---@param t any
function LLight:setLightType(t) end

--- Sets the outer cone angle in radians for spot lights.
---@param a any
function LLight:setOuterAngle(a) end

--- Sets the light's world-space position.
---@param x any
---@param y any
function LLight:setPosition(x, y) end

--- Sets the light's influence radius.
---@param r any
function LLight:setRadius(r) end

--- Sets the shadow region color.
---@param r any
---@param g any
---@param b any
---@param a? any
function LLight:setShadowColor(r, g, b, a) end

--- Sets whether this light casts shadows.
---@param b any
function LLight:setShadowEnabled(b) end

--- Sets the shadow edge filter ('none', 'pcf5', or 'pcf13').
---@param filter any
function LLight:setShadowFilter(filter) end

--- Sets the shadow casting bitmask.
---@param mask any
function LLight:setShadowMask(mask) end

--- Sets the shadow edge smoothing factor.
---@param s any
function LLight:setShadowSmooth(s) end

--- Sets whether this light hints at volumetric scattering.
---@param b any
function LLight:setVolumetric(b) end

--- Cancels the active light transition.
function LLight:stopTransition() end

--- Returns the fractional progress `[0, 1]` of the active transition,
function LLight:transitionProgress() end

--- Begins a smooth linear transition of the light's color, intensity,
---@param target any
---@param duration any
function LLight:transitionTo(target, duration) end

--- Returns the type name of this object.
function LLight:type() end

--- Returns true if this object is of the given type.
---@param name any
function LLight:typeOf(name) end

--- Advances the active transition by `dt` seconds and applies the
---@param dt any
function LLight:updateTransition(dt) end

--- Lua-side handle to an occluder resource stored in [`LightWorld`].
---@class LOccluder
LOccluder = {}

--- Returns the light interaction bitmask.
function LOccluder:getLightMask() end

--- Returns the shadow opacity.
function LOccluder:getOpacity() end

--- Returns the translation offset as (x, y).
function LOccluder:getPosition() end

--- Returns the polygon vertices as a flat table {x1,y1,x2,y2,...}.
function LOccluder:getVertices() end

--- Returns whether this occluder is active.
function LOccluder:isEnabled() end

--- Returns whether this occluder handle is still valid.
function LOccluder:isValid() end

--- Removes this occluder from the world.
function LOccluder:remove() end

--- Sets whether this occluder is active.
---@param b any
function LOccluder:setEnabled(b) end

--- Sets the light interaction bitmask.
---@param mask any
function LOccluder:setLightMask(mask) end

--- Sets the shadow opacity (0.0â€“1.0).
---@param o any
function LOccluder:setOpacity(o) end

--- Sets the translation offset applied to all vertices.
---@param x any
---@param y any
function LOccluder:setPosition(x, y) end

--- Replaces the polygon vertices from a flat table {x1,y1,x2,y2,...}.
---@param tbl any
function LOccluder:setVertices(tbl) end

--- Returns the type name of this object.
function LOccluder:type() end

--- Returns true if this object is of the given type.
---@param name any
function LOccluder:typeOf(name) end

--- Advances flicker phase for all lights with flicker enabled.
---@param dt any
lurek.light.advanceFlickers = function(dt) end

--- Removes all lights and occluders, resets ambient to default.
lurek.light.clear = function() end

--- Returns the global ambient light color as (r, g, b, a).
lurek.light.getAmbient = function() end

--- Returns a list of directional light hints for god-ray rendering.
lurek.light.getGodRayHints = function() end

--- Returns the number of lights in the given group.
---@param group_id any
lurek.light.getGroupCount = function(group_id) end

--- Returns the number of lights in the world.
lurek.light.getLightCount = function() end

--- Returns the maximum number of lights processed per frame.
lurek.light.getMaxLights = function() end

--- Returns the number of occluders in the world.
lurek.light.getOccluderCount = function() end

--- Returns whether the lighting system is active.
lurek.light.isEnabled = function() end

--- Creates a new light at (x, y) with the given radius and optional settings.
---@param x any
---@param y any
---@param radius any
---@param opts? any
lurek.light.newLight = function(x, y, radius, opts) end

--- Creates a new shadow occluder from a vertex table and optional settings.
---@param vtbl any
---@param opts? any
lurek.light.newOccluder = function(vtbl, opts) end

--- Sets the global ambient light color.
---@param r any
---@param g any
---@param b any
---@param a? any
lurek.light.setAmbient = function(r, g, b, a) end

--- Sets whether the lighting system is active.
---@param enabled any
lurek.light.setEnabled = function(enabled) end

--- Sets the color for all lights in the given group.
---@param group_id any
---@param r any
---@param g any
---@param b any
---@param a? any
lurek.light.setGroupColor = function(group_id, r, g, b, a) end

--- Sets the enabled state for all lights in the given group.
---@param group_id any
---@param enabled any
lurek.light.setGroupEnabled = function(group_id, enabled) end

--- Sets the intensity for all lights in the given group.
---@param group_id any
---@param intensity any
lurek.light.setGroupIntensity = function(group_id, intensity) end

--- Sets the maximum number of lights processed per frame (clamped 1â€“256).
---@param n any
lurek.light.setMaxLights = function(n) end

--- Returns the current ambient light colour as (r, g, b, a).
lurek.light.syncAmbient = function() end

---@class lurek.log
lurek.log = {}

--- Creates and registers a new log output sink from the given configuration table.
---@param config table Configuration table with keys: type (string), level (string), path (string, for file/rotating), capacity (integer, for memory), max_bytes (integer, for rotating), keep_files (integer, for rotating)
---@return number The unique identifier of the newly created sink
lurek.log.addSink = function(config) end

--- Removes every registered log sink, returning the logging system to its default state where messages go only to the engine log backend (stderr).
---@return nil No return value.
lurek.log.clearSinks = function() end

--- Emits a message at debug severity to the engine log and all registered sinks.
---@param message string The text content of the log message
---@param tag string|nil Optional category tag (defaults to "Lua" when omitted)
---@return nil No return value.
lurek.log.debug = function(message, tag) end

--- Emits a structured log message at debug severity with key-value metadata.
---@param message string The human-readable log message
---@param fields_table table Key-value pairs of metadata (string keys, any values)
---@return nil No return value.
lurek.log.debug_fields = function(message, fields_table) end

--- Emits a message at error severity to the engine log and all registered sinks.
---@param message string The text content of the error message
---@param tag string|nil Optional category tag (defaults to "Lua" when omitted)
---@return nil No return value.
lurek.log.error = function(message, tag) end

--- Emits a structured log message at error severity with key-value metadata.
---@param message string The human-readable error message
---@param fields_table table Key-value pairs of metadata (string keys, any values)
---@return nil No return value.
lurek.log.error_fields = function(message, fields_table) end

--- Forces the operating system to write any buffered data for a file-type sink to disk.
---@param id integer The file sink identifier returned by addSink
---@return nil No return value.
lurek.log.flushFile = function(id) end

--- Returns the name of the current global minimum severity threshold as a lowercase string (e.g.
---@return string The active log level name
lurek.log.getLevel = function() end

--- Emits a message at info severity to the engine log and all registered sinks.
---@param message string The text content of the log message
---@param tag string|nil Optional category tag (defaults to "Lua" when omitted)
---@return nil No return value.
lurek.log.info = function(message, tag) end

--- Emits a structured log message at info severity with key-value metadata.
---@param message string The human-readable log message
---@param fields_table table Key-value pairs of metadata (string keys, any values)
---@return nil No return value.
lurek.log.info_fields = function(message, fields_table) end

--- Returns an array-like table where each entry is a table describing one registered sink.
---@return table Array of sink descriptor tables
lurek.log.listSinks = function() end

--- Emits a log message at an arbitrary severity level specified as a string.
---@param level string Severity name: "debug", "info", "warn", "error", or "trace"
---@param message string The text content of the log message
---@param tag string|nil Optional category tag (defaults to "Lua" when omitted)
---@return nil No return value.
lurek.log.print = function(level, message, tag) end

--- Reads log entries stored in a memory-type sink.
---@param id integer The memory sink identifier returned by addSink
---@param drain boolean|nil When true, clears read entries from the buffer (default false)
---@return table Array of log entry tables, or nil if the sink was not found
lurek.log.readMemory = function(id, drain) end

--- Removes a previously registered log sink by its numeric identifier.
---@param id integer The sink identifier returned by addSink
---@return boolean True if the sink existed and was removed
lurek.log.removeSink = function(id) end

--- Sets the global minimum severity threshold for the engine log backend.
---@param level string One of "error", "warn", "info", "debug", "trace", or "off"
---@return nil No return value.
lurek.log.setLevel = function(level) end

--- Emits a structured log message that includes arbitrary key-value metadata alongside the human-readable text.
---@param level string Severity name: "debug", "info", "warn", or "error"
---@param message string The human-readable log message
---@param fields_table table Key-value pairs of metadata (string keys, any values)
---@return nil No return value.
lurek.log.struct = function(level, message, fields_table) end

--- Emits a message at warning severity to the engine log and all registered sinks.
---@param message string The text content of the warning message
---@param tag string|nil Optional category tag (defaults to "Lua" when omitted)
---@return nil No return value.
lurek.log.warn = function(message, tag) end

--- Emits a structured log message at warning severity with key-value metadata.
---@param message string The human-readable warning message
---@param fields_table table Key-value pairs of metadata (string keys, any values)
---@return nil No return value.
lurek.log.warn_fields = function(message, fields_table) end

---@class lurek.math
---@field pi number  π ≈ 3.14159265358979
---@field tau number  τ = 2π ≈ 6.28318530717959
lurek.math = {}

--- Lua-side wrapper around an [`AabbTree`].
---@class LAabbTree
LAabbTree = {}

--- Removes all entries from the tree.
function LAabbTree:clear() end

--- Returns true if an entry with the given id exists in the tree.
---@param id any
function LAabbTree:contains(id) end

--- Inserts an entry with the given AABB into the tree.
---@param id any
---@param min_x any
---@param min_y any
---@param max_x any
---@param max_y any
function LAabbTree:insert(id, min_x, min_y, max_x, max_y) end

--- Returns true if the tree contains no entries.
function LAabbTree:isEmpty() end

--- Returns the number of entries in the tree.
function LAabbTree:len() end

--- Returns the ids of all entries whose AABBs overlap the query rectangle.
---@param min_x any
---@param min_y any
---@param max_x any
---@param max_y any
function LAabbTree:query(min_x, min_y, max_x, max_y) end

--- Returns the ids of all entries whose AABBs contain the given point.
---@param x any
---@param y any
function LAabbTree:queryPoint(x, y) end

--- Removes the entry with the given id.
---@param id any
function LAabbTree:remove(id) end

--- Returns the type name of this object.
function LAabbTree:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAabbTree:typeOf(name) end

--- Updates the AABB for an existing entry.
---@param id any
---@param min_x any
---@param min_y any
---@param max_x any
---@param max_y any
function LAabbTree:update(id, min_x, min_y, max_x, max_y) end

--- Lua-side wrapper around a [`BezierCurve`].
---@class LBezierCurve
LBezierCurve = {}

--- Evaluates the curve at parameter t, returning (x, y).
---@param t any
function LBezierCurve:evaluate(t) end

--- Returns the control point at 1-based index as (x, y), or nil.
---@param index any
function LBezierCurve:getControlPoint(index) end

--- Returns the number of control points.
function LBezierCurve:getControlPointCount() end

--- Returns a new BezierCurve representing the first derivative.
function LBezierCurve:getDerivative() end

--- Inserts a control point. If index is given (1-based), inserts at that position.
---@param x any
---@param y any
---@param index? any
function LBezierCurve:insertControlPoint(x, y, index) end

--- Returns the approximate arc length of the curve.
function LBezierCurve:length() end

--- Removes a control point at 1-based index.
---@param index any
function LBezierCurve:removeControlPoint(index) end

--- Renders the curve as a polyline with the given number of segments.
---@param segments any
function LBezierCurve:render(segments) end

--- Rotates all control points around a pivot by angle radians.
---@param angle any
---@param ox any
---@param oy any
function LBezierCurve:rotate(angle, ox, oy) end

--- Scales all control points around a pivot by factor s.
---@param s any
---@param ox any
---@param oy any
function LBezierCurve:scale(s, ox, oy) end

--- Sets the control point at 1-based index.
---@param index any
---@param x any
---@param y any
function LBezierCurve:setControlPoint(index, x, y) end

--- Translates all control points by (dx, dy).
---@param dx any
---@param dy any
function LBezierCurve:translate(dx, dy) end

--- Returns the type name of this object.
function LBezierCurve:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBezierCurve:typeOf(name) end

--- Lua-side wrapper around a [`CatmullRomSpline`].
---@class LCatmullRom
LCatmullRom = {}

--- Appends a control point to the spline.
---@param x any
---@param y any
function LCatmullRom:addPoint(x, y) end

--- Number of control points.
function LCatmullRom:len() end

--- Removes the control point at `index` (0-based) and returns it.
---@param idx any
function LCatmullRom:removePoint(idx) end

--- Sample the spline at global t in [0, 1].
---@param t any
function LCatmullRom:sample(t) end

--- Sample a specific segment at local t in [0, 1].
---@param seg any
---@param t any
function LCatmullRom:sampleSegment(seg, t) end

--- Returns the type name of this object.
function LCatmullRom:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCatmullRom:typeOf(name) end

--- Lua-side wrapper around a [`Circle`].
---@class LCircle
LCircle = {}

--- Returns the axis-aligned bounding box as (min_x, min_y, max_x, max_y).
function LCircle:aabb() end

--- Returns the area of the circle (π r²).
function LCircle:area() end

--- Returns true if the point (px, py) lies inside or on the boundary.
---@param px any
---@param py any
function LCircle:contains(px, py) end

--- Returns true if this circle overlaps another circle.
---@param other any
function LCircle:intersects(other) end

--- Returns the circumference of the circle (2 π r).
function LCircle:perimeter() end

--- Returns the circle radius.
function LCircle:radius() end

--- Returns the type name of this object.
function LCircle:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCircle:typeOf(name) end

--- Returns the circle centre X.
function LCircle:x() end

--- Returns the circle centre Y.
function LCircle:y() end

--- Lua-side wrapper around a [`HermiteSpline`].
---@class LHermite
LHermite = {}

--- Evaluate the spline at parameter t in [0, 1].
---@param t any
function LHermite:sample(t) end

--- Returns the type name of this object.
function LHermite:type() end

--- Returns true if this object is of the given type.
---@param name any
function LHermite:typeOf(name) end

--- Lua-side wrapper around a [`NoiseGenerator`].
---@class LNoiseGenerator
LNoiseGenerator = {}

--- Returns fractal Brownian motion noise at (x, y).
function LNoiseGenerator:fbm() end

--- Generates a 2D noise map as a flat table (row-major).
---@param w any
---@param h any
---@param opts? any
function LNoiseGenerator:generateMap(w, h, opts) end

--- Returns the current seed.
function LNoiseGenerator:getSeed() end

--- Returns 1D Perlin noise at x.
---@param x any
function LNoiseGenerator:perlin1d(x) end

--- Returns 2D Perlin noise at (x, y).
---@param x any
---@param y any
function LNoiseGenerator:perlin2d(x, y) end

--- Returns 3D Perlin noise at (x, y, z).
---@param x any
---@param y any
---@param z any
function LNoiseGenerator:perlin3d(x, y, z) end

--- Returns 4D Perlin noise at (x, y, z, w).
---@param x any
---@param y any
---@param z any
---@param w any
function LNoiseGenerator:perlin4d(x, y, z, w) end

--- Returns ridged multi-fractal noise at (x, y).
function LNoiseGenerator:ridged() end

--- Sets the seed and rebuilds the permutation table.
---@param seed any
function LNoiseGenerator:setSeed(seed) end

--- Returns 1D Simplex noise at x.
---@param x any
function LNoiseGenerator:simplex1d(x) end

--- Returns 2D Simplex noise at (x, y).
---@param x any
---@param y any
function LNoiseGenerator:simplex2d(x, y) end

--- Returns 3D Simplex noise at (x, y, z).
---@param x any
---@param y any
---@param z any
function LNoiseGenerator:simplex3d(x, y, z) end

--- Returns turbulence noise at (x, y).
function LNoiseGenerator:turbulence() end

--- Returns the type name of this object.
function LNoiseGenerator:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNoiseGenerator:typeOf(name) end

--- Applies domain warping, returning offset (x, y).
---@param x any
---@param y any
---@param strength any
function LNoiseGenerator:warpDomain(x, y, strength) end

--- Returns 2D Worley (cellular) noise at (x, y).
---@param x any
---@param y any
---@param dist_name? any
---@param f2? any
function LNoiseGenerator:worley2d(x, y, dist_name, f2) end

--- Returns 3D Worley (cellular) noise at (x, y, z).
---@param x any
---@param y any
---@param z any
---@param dist_name? any
---@param f2? any
function LNoiseGenerator:worley3d(x, y, z, dist_name, f2) end

--- Lua-side wrapper around a [`RandomGenerator`].
---@class LRandomGenerator
LRandomGenerator = {}

--- Returns the seed used to initialise this generator.
function LRandomGenerator:getSeed() end

--- Serialises the generator state as a string for later restoration.
function LRandomGenerator:getState() end

--- Returns a uniform random number in [0, 1).
function LRandomGenerator:random() end

--- Returns a uniform random float in [min, max).
---@param min any
---@param max any
function LRandomGenerator:randomFloat(min, max) end

--- Returns a uniform random integer in [min, max].
---@param min any
---@param max any
function LRandomGenerator:randomInt(min, max) end

--- Returns a random number from a normal (Gaussian) distribution.
---@param stddev? any
---@param mean? any
function LRandomGenerator:randomNormal(stddev, mean) end

--- Sets the seed, fully resetting the generator state.
---@param seed any
function LRandomGenerator:setSeed(seed) end

--- Restores the generator state from a previously serialised string.
---@param state any
function LRandomGenerator:setState(state) end

--- Returns the type name of this object.
function LRandomGenerator:type() end

--- Returns true if this object is of the given type.
---@param name any
function LRandomGenerator:typeOf(name) end

--- Lua-side wrapper around a [`SpatialHash`].
---@class LSpatialHash
LSpatialHash = {}

--- Removes all registered items from this spatial hash, leaving it empty.
function LSpatialHash:clear() end

--- Returns the cell size used to partition the spatial hash grid.
function LSpatialHash:getCellSize() end

--- Returns the number of items in the hash.
function LSpatialHash:getItemCount() end

--- Inserts an item with the given AABB.
---@param id any
---@param x any
---@param y any
---@param w any
---@param h any
function LSpatialHash:insert(id, x, y, w, h) end

--- Returns IDs of items overlapping the query circle.
---@param cx any
---@param cy any
---@param radius any
function LSpatialHash:queryCircle(cx, cy, radius) end

--- Returns IDs of items overlapping the query rectangle.
---@param x any
---@param y any
---@param w any
---@param h any
function LSpatialHash:queryRect(x, y, w, h) end

--- Returns IDs of items whose AABBs are intersected by the line segment.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function LSpatialHash:querySegment(x1, y1, x2, y2) end

--- Removes an item by its ID.
---@param id any
function LSpatialHash:remove(id) end

--- Returns the type name of this object.
function LSpatialHash:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSpatialHash:typeOf(name) end

--- Updates an existing item's AABB.
---@param id any
---@param x any
---@param y any
---@param w any
---@param h any
function LSpatialHash:update(id, x, y, w, h) end

--- Lua-side wrapper around a [`Transform`].
---@class LTransform
LTransform = {}

--- Returns a copy of this transform.
function LTransform:clone() end

--- Decomposes this transform into translation, rotation, and scale.
function LTransform:decompose() end

--- Returns the 3x3 matrix as a flat table of 9 numbers (row-major).
function LTransform:getMatrix() end

--- Returns a new Transform that undoes this transform.
function LTransform:inverse() end

--- Transforms a point from world space back to local space.
---@param x any
---@param y any
function LTransform:inverseTransformPoint(x, y) end

--- Resets the transform to identity.
function LTransform:reset() end

--- Applies a rotation in radians.
---@param angle any
function LTransform:rotate(angle) end

--- Applies non-uniform scaling.
---@param sx any
---@param sy? any
function LTransform:scale(sx, sy) end

--- Replaces the transform with full transformation parameters.
function LTransform:setTransformation() end

--- Applies horizontal and vertical shear factors to this transform matrix.
---@param kx any
---@param ky any
function LTransform:shear(kx, ky) end

--- Transforms a point from local space to world space.
---@param x any
---@param y any
function LTransform:transformPoint(x, y) end

--- Applies translation to the transform.
---@param dx any
---@param dy any
function LTransform:translate(dx, dy) end

--- Returns the type name of this object.
function LTransform:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTransform:typeOf(name) end

--- Lua-side wrapper around a [`Tween`].
---@class LTween
LTween = {}

--- Adds a start/target value pair. Returns the 1-based index.
---@param start any
---@param target any
function LTween:addValue(start, target) end

--- Returns all interpolated values as a table.
function LTween:getAllValues() end

--- Alias for getTime(). Returns the current clock time.
function LTween:getClock() end

--- Returns the tween duration in seconds.
function LTween:getDuration() end

--- Returns the easing function name.
function LTween:getEasingName() end

--- Returns the current clock time.
function LTween:getTime() end

--- Returns the interpolated value at 1-based index, or all values as a
---@param index? any
function LTween:getValue(index) end

--- Returns the number of values in this tween.
function LTween:getValueCount() end

--- Returns true if the tween has finished.
function LTween:isComplete() end

--- Resets the tween elapsed time to zero, restarting the animation.
function LTween:reset() end

--- Alias for setTime(). Sets the clock to t, clamped to [0, duration].
---@param t any
function LTween:set(t) end

--- Sets the clock to a specific time, clamped to [0, duration].
---@param t any
function LTween:setTime(t) end

--- Returns the type name of this object.
function LTween:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTween:typeOf(name) end

--- Advances the clock by dt seconds. Returns true when complete.
---@param dt any
function LTween:update(dt) end

--- Lua-side wrapper around a [`Vec2`] value type.
---@class LVec2
---@field x number  x component
---@field y number  y component
LVec2 = {}

--- Returns the angle of this vector in radians (atan2(y, x)).
function LVec2:angle() end

--- Returns the 2D cross product (scalar) with another vector.
---@param other any
function LVec2:cross(other) end

--- Returns the Euclidean distance from this vector to another.
---@param other any
function LVec2:distance(other) end

--- Returns the dot product with another vector.
---@param other any
function LVec2:dot(other) end

--- Creates a unit vector from an angle in radians.
---@param radians any
LVec2.fromAngle = function(radians) end

--- Returns the Euclidean length of the vector.
function LVec2:length() end

--- Returns the squared length of the vector (faster than length).
function LVec2:lengthSquared() end

--- Returns a linearly interpolated vector between this and other at parameter t.
---@param other any
---@param t any
function LVec2:lerp(other, t) end

--- Returns a unit-length copy of this vector. Returns zero if length is zero.
function LVec2:normalize() end

--- Compatibility alias for `normalize`.
function LVec2:normalized() end

--- Returns the perpendicular vector (-y, x).
function LVec2:perpendicular() end

--- Reflects this vector off a surface with the given normal.
---@param normal any
function LVec2:reflect(normal) end

--- Returns a new vector rotated by the given angle in radians.
---@param angle any
function LVec2:rotate(angle) end

--- Returns the type name of this object.
function LVec2:type() end

--- Returns true if this object is of the given type.
---@param name any
function LVec2:typeOf(name) end

--- Returns the horizontal component of the vector.
function LVec2:x() end

--- Returns the vertical component of the vector.
function LVec2:y() end

--- Lua-side wrapper around a [`Vec3`] value type.
---@class LVec3
---@field x number  x component
---@field y number  y component
---@field z number  z component
LVec3 = {}

--- Add another Vec3 and return the result.
---@param other any
function LVec3:add(other) end

--- Cross product with another Vec3.
---@param other any
function LVec3:cross(other) end

--- Euclidean distance to another Vec3.
---@param other any
function LVec3:distance(other) end

--- Dot product with another Vec3.
---@param other any
function LVec3:dot(other) end

--- Returns the Euclidean length of the vector.
function LVec3:length() end

--- Returns the squared Euclidean length (avoids sqrt).
function LVec3:lengthSquared() end

--- Linear interpolation towards another Vec3.
---@param other any
---@param t any
function LVec3:lerp(other, t) end

--- Returns a unit-length version of this vector.
function LVec3:normalize() end

--- Scale this vector by a scalar and return the result.
---@param s any
function LVec3:scale(s) end

--- Creates a Vec3 with all components set to `v`.
---@param v any
LVec3.splat = function(v) end

--- Subtract another Vec3 and return the result.
---@param other any
function LVec3:sub(other) end

--- Returns the type name of this object.
function LVec3:type() end

--- Returns true if this object is of the given type.
---@param name any
function LVec3:typeOf(name) end

--- Compatibility alias for `vec2`.
---@param x any
---@param y any
lurek.math.Vec2 = function(x, y) end

--- Compatibility alias for `vec3`.
---@param x any
---@param y any
---@param z any
lurek.math.Vec3 = function(x, y, z) end

--- Creates a new empty AABB tree for efficient broad-phase overlap queries.
lurek.math.aabbTree = function() end

--- Returns the absolute value of x.
---@param x any
lurek.math.abs = function(x) end

--- Returns the arccosine of x, in radians.
---@param x any
lurek.math.acos = function(x) end

--- Returns the angle in radians from (x1, y1) to (x2, y2).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
lurek.math.angleBetween = function(x1, y1, x2, y2) end

--- Applies a named easing function to progress value t.
---@param name any
---@param t any
lurek.math.applyEasing = function(name, t) end

--- Returns the arcsine of x, in radians.
---@param x any
lurek.math.asin = function(x) end

--- Returns the arctangent of x (or atan2(y, x) when two args given).
---@param y any
---@param x? any
lurek.math.atan = function(y, x) end

--- Returns atan(y/x) using the signs of both args to determine the quadrant.
---@param y any
---@param x any
lurek.math.atan2 = function(y, x) end

--- Rasterizes a line from (x1,y1) to (x2,y2) using Bresenham's algorithm. Returns a table of {x,y} tables.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
lurek.math.bresenham = function(x1, y1, x2, y2) end

--- Creates a Catmull-Rom spline through the given control points.
---@param points any
lurek.math.catmullRom = function(points) end

--- Returns the smallest integer ≥ x.
---@param x any
lurek.math.ceil = function(x) end

--- Returns true if the point (px, py) lies inside the circle.
---@param cx any
---@param cy any
---@param r any
---@param px any
---@param py any
lurek.math.circleContainsPoint = function(cx, cy, r, px, py) end

--- Returns true if two circles overlap.
---@param x1 any
---@param y1 any
---@param r1 any
---@param x2 any
---@param y2 any
---@param r2 any
lurek.math.circleIntersectsCircle = function(x1, y1, r1, x2, y2, r2) end

--- Tests an infinite line against a circle. Returns hit, then two optional hit-point pairs.
---@param cx any
---@param cy any
---@param r any
---@param lx1 any
---@param ly1 any
---@param lx2 any
---@param ly2 any
lurek.math.circleIntersectsLine = function(cx, cy, r, lx1, ly1, lx2, ly2) end

--- Tests a line segment against a circle. Returns hit, then two optional hit-point pairs.
---@param cx any
---@param cy any
---@param r any
---@param sx1 any
---@param sy1 any
---@param sx2 any
---@param sy2 any
lurek.math.circleIntersectsSegment = function(cx, cy, r, sx1, sy1, sx2, sy2) end

--- Clamps `v` between `min` and `max`.
---@param v any
---@param min any
---@param max any
lurek.math.clamp = function(v, min, max) end

--- Returns the closest point on segment (x1,y1)-(x2,y2) to point (px,py).
---@param px any
---@param py any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
lurek.math.closestPointOnSegment = function(px, py, x1, y1, x2, y2) end

--- Computes the convex hull of a flat {x1,y1,...} point list. Returns a flat table.
---@param pts any
lurek.math.convexHull = function(pts) end

--- Returns the cosine of x (radians).
---@param x any
lurek.math.cos = function(x) end

--- Converts radians to degrees.
---@param rad any
lurek.math.deg = function(rad) end

--- Delaunay triangulation of a flat {x1,y1,...} point list. Returns a table of flat 6-number triangle tables.
---@param pts any
lurek.math.delaunayTriangulate = function(pts) end

--- Returns the Euclidean distance between (x1,y1) and (x2,y2).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
lurek.math.distance = function(x1, y1, x2, y2) end

--- Returns the squared Euclidean distance between (x1,y1) and (x2,y2) (avoids sqrt).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
lurek.math.distanceSq = function(x1, y1, x2, y2) end

--- Returns e raised to the power x.
---@param x any
lurek.math.exp = function(x) end

--- Returns fractal Brownian motion noise at (x, y).
lurek.math.fbm = function() end

--- Returns the largest integer ≤ x.
---@param x any
lurek.math.floor = function(x) end

--- Returns the remainder of x / y (fmod).
---@param x any
---@param y any
lurek.math.fmod = function(x, y) end

--- Parses a hex color string (#RRGGBB or #RRGGBBAA) into (r, g, b, a) floats.
---@param hex any
lurek.math.fromHex = function(hex) end

--- Converts a gamma-encoded sRGB value to linear space.
---@param c any
lurek.math.gammaToLinear = function(c) end

--- Creates a Hermite spline defined by two endpoints and tangents.
---@param p0x any
---@param p0y any
---@param p1x any
---@param p1y any
---@param m0x any
---@param m0y any
---@param m1x any
---@param m1y any
lurek.math.hermite = function(p0x, p0y, p1x, p1y, m0x, m0y, m1x, m1y) end

--- Converts HSL (h: 0-360, s: 0-1, l: 0-1) to RGBA (r, g, b, a) floats.
---@param h any
---@param s any
---@param l any
lurek.math.hslToRgb = function(h, s, l) end

--- Back ease-in — overshoots slightly before settling at the target.
---@param t any
lurek.math.inBack = function(t) end

--- Bounce ease-in — reverse bounce effect that accelerates into the motion.
---@param t any
lurek.math.inBounce = function(t) end

--- Cubic ease-in — acceleration starts slowly then increases sharply.
---@param t any
lurek.math.inCubic = function(t) end

--- Elastic ease-in — spring-like overshoot at the beginning of the motion.
---@param t any
lurek.math.inElastic = function(t) end

--- Exponential ease-in — very slow start that accelerates sharply near the end.
---@param t any
lurek.math.inExpo = function(t) end

--- Back ease-in-out — overshoot on both ends.
---@param t any
lurek.math.inOutBack = function(t) end

--- Bounce ease-in-out — bouncing motion on both ends.
---@param t any
lurek.math.inOutBounce = function(t) end

--- Cubic ease-in-out — slow start and end with fast cubic middle.
---@param t any
lurek.math.inOutCubic = function(t) end

--- Elastic ease-in-out — spring-like oscillation on both ends.
---@param t any
lurek.math.inOutElastic = function(t) end

--- Exponential ease-in-out — very slow start and end with an exponential surge.
---@param t any
lurek.math.inOutExpo = function(t) end

--- Quadratic ease-in-out — slow start, fast middle, slow end.
---@param t any
lurek.math.inOutQuad = function(t) end

--- Quartic ease-in-out — very slow start and end with a sharp middle peak.
---@param t any
lurek.math.inOutQuart = function(t) end

--- Sinusoidal ease-in-out — smooth S-curve based on cosine interpolation.
---@param t any
lurek.math.inOutSine = function(t) end

--- Quadratic ease-in — acceleration that starts at zero and increases.
---@param t any
lurek.math.inQuad = function(t) end

--- Quartic ease-in — strongly delayed acceleration using a power-of-4 curve.
---@param t any
lurek.math.inQuart = function(t) end

--- Sinusoidal ease-in — gentle acceleration based on a sine curve.
---@param t any
lurek.math.inSine = function(t) end

--- Returns the interpolation parameter t for `v` in [a, b].
---@param a any
---@param b any
---@param v any
lurek.math.inverseLerp = function(a, b, v) end

--- Returns true if the polygon (flat table {x1,y1,...}) is convex.
---@param pts any
lurek.math.isConvex = function(pts) end

--- Linear interpolation between two numbers: a + (b - a) * t.
---@param a any
---@param b any
---@param t any
lurek.math.lerp = function(a, b, t) end

--- Infinite line intersection. Returns (x, y) or (nil, nil) if lines are parallel.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param x3 any
---@param y3 any
---@param x4 any
---@param y4 any
lurek.math.lineIntersect = function(x1, y1, x2, y2, x3, y3, x4, y4) end

--- Linear easing (identity).
---@param t any
lurek.math.linear = function(t) end

--- Converts a linear-space value to gamma-encoded sRGB.
---@param c any
lurek.math.linearToGamma = function(c) end

--- Returns the natural log of x, or log base b if b is supplied.
---@param x any
---@param b? any
lurek.math.log = function(x, b) end

--- Returns the largest of the supplied numbers.
lurek.math.max = function() end

--- Returns the smallest of the supplied numbers.
lurek.math.min = function() end

--- Creates a new BezierCurve from a flat table of coordinates {x1,y1, x2,y2, ...}.
---@param points any
lurek.math.newBezierCurve = function(points) end

--- Creates a new Circle value type with the given centre and radius.
---@param x any
---@param y any
---@param radius any
lurek.math.newCircle = function(x, y, radius) end

--- Creates a new seeded noise generator.
---@param seed? any
lurek.math.newNoiseGenerator = function(seed) end

--- Creates a new random number generator with an optional seed.
---@param seed? any
lurek.math.newRandomGenerator = function(seed) end

--- Creates a new SpatialHash with the given cell size.
---@param cell_size any
lurek.math.newSpatialHash = function(cell_size) end

--- Creates a new Transform, optionally initialised from full parameters.
lurek.math.newTransform = function() end

--- Creates a new Tween with the given duration and easing name.
---@param duration any
---@param easing_name? any
lurek.math.newTween = function(duration, easing_name) end

--- Back ease-out — overshoots the target then snaps back into place.
---@param t any
lurek.math.outBack = function(t) end

--- Bounce ease-out — simulates a ball bouncing against the target value.
---@param t any
lurek.math.outBounce = function(t) end

--- Cubic ease-out — rapid deceleration using a cubic power curve.
---@param t any
lurek.math.outCubic = function(t) end

--- Elastic ease-out — spring-like oscillation that settles at the target.
---@param t any
lurek.math.outElastic = function(t) end

--- Exponential ease-out — sharp initial speed that decelerates exponentially.
---@param t any
lurek.math.outExpo = function(t) end

--- Quadratic ease-out — deceleration that starts fast and ends at zero.
---@param t any
lurek.math.outQuad = function(t) end

--- Quartic ease-out — rapid deceleration using a power-of-4 curve.
---@param t any
lurek.math.outQuart = function(t) end

--- Sinusoidal ease-out — gentle deceleration based on a cosine curve.
---@param t any
lurek.math.outSine = function(t) end

--- Returns 2D Perlin noise at (x, y) with the given seed.
---@param x any
---@param y any
---@param seed? any
lurek.math.perlin2d = function(x, y, seed) end

--- Returns 3D Perlin noise at (x, y, z) with the given seed.
---@param x any
---@param y any
---@param z any
---@param seed? any
lurek.math.perlin3d = function(x, y, z, seed) end

--- Returns true if (px, py) is inside the polygon given as a flat {x1,y1,...} table.
---@param pts any
---@param px any
---@param py any
lurek.math.pointInPolygon = function(pts, px, py) end

--- Returns the signed area of a polygon given as a flat {x1,y1,...} table.
---@param pts any
lurek.math.polygonArea = function(pts) end

--- Returns the centroid (cx, cy) of a polygon given as a flat {x1,y1,...} table.
---@param pts any
lurek.math.polygonCentroid = function(pts) end

--- Clips a polygon against a single half-plane using the Sutherland-Hodgman algorithm.
---@param pts any
---@param nx any
---@param ny any
---@param d any
lurek.math.polygonClip = function(pts, nx, ny, d) end

--- Computes the approximate difference `A - B` (the part of A not covered by B).
---@param a any
---@param b any
lurek.math.polygonDifference = function(a, b) end

--- Computes the intersection of two convex polygons using the Sutherland-Hodgman
---@param a any
---@param b any
lurek.math.polygonIntersection = function(a, b) end

--- Computes the approximate union of two convex polygons as the convex hull of
---@param a any
---@param b any
lurek.math.polygonUnion = function(a, b) end

--- Returns x raised to the power y.
---@param x any
---@param y any
lurek.math.pow = function(x, y) end

--- Converts degrees to radians.
---@param deg any
lurek.math.rad = function(deg) end

--- Returns a pseudo-random number in [0,1) with no args,
---@param a? any
---@param b? any
lurek.math.random = function(a, b) end

--- Returns a pseudo-random integer in [lo, hi] (inclusive).
---@param lo any
---@param hi any
lurek.math.randomInt = function(lo, hi) end

--- Creates a rectangle centered at (cx, cy) with the given width and height.
---@param cx any
---@param cy any
---@param w any
---@param h any
lurek.math.rectFromCenter = function(cx, cy, w, h) end

--- Returns the union (bounding box) of two rectangles.
---@param x1 any
---@param y1 any
---@param w1 any
---@param h1 any
---@param x2 any
---@param y2 any
---@param w2 any
---@param h2 any
lurek.math.rectUnion = function(x1, y1, w1, h1, x2, y2, w2, h2) end

--- Remaps `v` from [in_min, in_max] to [out_min, out_max].
---@param v any
---@param in_min any
---@param in_max any
---@param out_min any
---@param out_max any
lurek.math.remap = function(v, in_min, in_max, out_min, out_max) end

--- Converts RGBA floats to HSL (h: 0-360, s: 0-1, l: 0-1).
---@param r any
---@param g any
---@param b any
lurek.math.rgbToHsl = function(r, g, b) end

--- Returns x rounded to the nearest integer (half-up).
---@param x any
lurek.math.round = function(x) end

--- Tests if two line segments intersect. Returns (hit, ix?, iy?).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param x3 any
---@param y3 any
---@param x4 any
---@param y4 any
lurek.math.segmentIntersectsSegment = function(x1, y1, x2, y2, x3, y3, x4, y4) end

--- Returns -1, 0, or 1 depending on the sign of `v`.
---@param v any
lurek.math.sign = function(v) end

--- Returns 2D Simplex noise at (x, y) with the given seed.
---@param x any
---@param y any
---@param seed? any
lurek.math.simplex2d = function(x, y, seed) end

--- Returns a simplex noise value in [-1, 1] for 2D or 3D coordinates.
---@param x any
---@param y any
---@param z? any
lurek.math.simplexNoise = function(x, y, z) end

--- Returns the sine of x (radians).
---@param x any
lurek.math.sin = function(x) end

--- Hermite smoothstep between `edge0` and `edge1`.
---@param edge0 any
---@param edge1 any
---@param x any
lurek.math.smoothstep = function(edge0, edge1, x) end

--- Returns the square root of x.
---@param x any
lurek.math.sqrt = function(x) end

--- Returns the tangent of x (radians).
---@param x any
lurek.math.tan = function(x) end

--- Triangulates a simple polygon given as a flat table {x1,y1, x2,y2, ...}.
---@param pts any
lurek.math.triangulate = function(pts) end

--- Creates a 2D vector with x and y components.
---@param x any
---@param y any
lurek.math.vec2 = function(x, y) end

--- Creates a 3D vector `{x, y, z}` table with numeric components.
---@param x any
---@param y any
---@param z any
lurek.math.vec3 = function(x, y, z) end

--- Computes the Voronoi diagram for a list of 2-D seed points.
---@param points any
lurek.math.voronoi = function(points) end

---@class lurek.minimap
lurek.minimap = {}

--- Lua-side wrapper around a [`Minimap`].
---@class LMinimap
LMinimap = {}

--- Adds a persistent marker and returns its auto-assigned ID.
function LMinimap:addMarker() end

--- Registers a new object type and returns its 1-based index.
---@param name any
---@param r any
---@param g any
---@param b any
---@param a? any
function LMinimap:addObjectType(name, r, g, b, a) end

--- Adds an animated ping at grid coordinates with a duration and optional color.
function LMinimap:addPing() end

--- Removes the animation from a marker, reverting it to static.
---@param id any
function LMinimap:clearMarkerAnimation(id) end

--- Removes all tracked objects.
function LMinimap:clearObjects() end

--- Removes all custom geometry from the minimap overlay.
function LMinimap:clearOverlay() end

--- Removes a displayed path. If id is nil, all paths are removed.
---@param id? any
function LMinimap:clearPath(id) end

--- Clears the viewport rectangle overlay.
function LMinimap:clearViewportRect() end

--- Draws a custom line segment on the minimap overlay.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param color_tbl any
function LMinimap:drawLine(x1, y1, x2, y2, color_tbl) end

--- Draws a custom rectangle on the minimap overlay.
---@param x any
---@param y any
---@param w any
---@param h any
---@param color_tbl any
function LMinimap:drawRect(x, y, w, h, color_tbl) end

--- Renders the minimap grid to a CPU ImageData.
---@param pixel_size any
function LMinimap:drawToImage(pixel_size) end

--- Returns the center coordinates as x, y.
function LMinimap:getCenter() end

--- Returns the center X coordinate.
function LMinimap:getCenterX() end

--- Returns the center Y coordinate.
function LMinimap:getCenterY() end

--- Returns the current color mode as a string.
function LMinimap:getColorMode() end

--- Returns the display height in pixels.
function LMinimap:getDisplayHeight() end

--- Returns the display width and height as two values.
function LMinimap:getDisplaySize() end

--- Returns the display width in pixels.
function LMinimap:getDisplayWidth() end

--- Returns the fog overlay color as r, g, b, a.
function LMinimap:getFogColor() end

--- Returns the fog level at a 1-based grid position (0=hidden, 1=explored, 2=visible).
---@param x any
---@param y any
function LMinimap:getFogLevel(x, y) end

--- Returns the grid height in cells.
function LMinimap:getGridHeight() end

--- Returns the grid width and height as two values.
function LMinimap:getGridSize() end

--- Returns the grid width in cells.
function LMinimap:getGridWidth() end

--- Returns hover tooltip text for the element under screen coordinates, or nil.
---@param sx any
---@param sy any
---@param mx any
---@param my any
function LMinimap:getHoverInfo(sx, sy, mx, my) end

--- Returns the index of the currently active render layer.
function LMinimap:getLayer() end

--- Returns the number of markers.
function LMinimap:getMarkerCount() end

--- Returns the description of a marker, or nil.
---@param id any
function LMinimap:getMarkerDescription(id) end

--- Returns the number of tracked objects.
function LMinimap:getObjectCount() end

--- Returns the number of registered object types.
function LMinimap:getObjectTypeCount() end

--- Returns the display color for an owner/faction as r, g, b, a.
---@param owner any
function LMinimap:getOwnerColor(owner) end

--- Returns the number of active pings.
function LMinimap:getPingCount() end

--- Returns the terrain type at a 1-based grid position.
---@param x any
---@param y any
function LMinimap:getTerrain(x, y) end

--- Returns the display color for a terrain type as r, g, b, a.
---@param terrain_type any
function LMinimap:getTerrainColor(terrain_type) end

--- Returns the hover tooltip string for a terrain type ID, or nil.
---@param type_id any
function LMinimap:getTileDescription(type_id) end

--- Returns the viewport rectangle color as r, g, b, a.
function LMinimap:getViewportColor() end

--- Returns the viewport rectangle as x, y, w, h or nil if not set.
function LMinimap:getViewportRect() end

--- Returns the current zoom level.
function LMinimap:getZoom() end

--- Converts grid coordinates to screen coordinates.
---@param gx any
---@param gy any
---@param mx any
---@param my any
function LMinimap:gridToScreen(gx, gy, mx, my) end

--- Returns whether a marker with the given ID exists.
---@param id any
function LMinimap:hasMarker(id) end

--- Returns whether anti-aliasing is enabled.
function LMinimap:isAntiAlias() end

--- Returns whether this minimap responds to click hit-testing.
function LMinimap:isClickable() end

--- Returns whether fog of war is enabled.
function LMinimap:isFogEnabled() end

--- Returns whether an object type (1-based index) is visible.
---@param type_idx any
function LMinimap:isObjectTypeVisible(type_idx) end

--- Returns whether the viewport rectangle is visible.
function LMinimap:isViewportVisible() end

--- Removes the minimap marker with the given integer ID, if present.
---@param id any
function LMinimap:removeMarker(id) end

--- Removes a tracked object by ID.
---@param id any
function LMinimap:removeObject(id) end

--- Renders the minimap to the screen at the given position.
---@param x? any
---@param y? any
function LMinimap:render(x, y) end

--- Converts screen coordinates to grid coordinates.
---@param sx any
---@param sy any
---@param mx any
---@param my any
function LMinimap:screenToGrid(sx, sy, mx, my) end

--- Sets whether anti-aliasing is enabled.
---@param enabled any
function LMinimap:setAntiAlias(enabled) end

--- Sets the center of the minimap view in grid coordinates.
---@param x any
---@param y any
function LMinimap:setCenter(x, y) end

--- Sets whether this minimap responds to click hit-testing.
---@param enabled any
function LMinimap:setClickable(enabled) end

--- Sets the color mode ("terrain" or "political").
---@param mode any
function LMinimap:setColorMode(mode) end

--- Sets the display size in pixels.
---@param w any
---@param h any
function LMinimap:setDisplaySize(w, h) end

--- Sets the fog overlay color.
---@param r any
---@param g any
---@param b any
---@param a? any
function LMinimap:setFogColor(r, g, b, a) end

--- Sets the entire fog grid from a flat 1-based table (0=hidden, 1=explored, 2=visible).
---@param data any
function LMinimap:setFogData(data) end

--- Enables or disables fog of war.
---@param enabled any
function LMinimap:setFogEnabled(enabled) end

--- Sets the fog level at a 1-based grid position (0=hidden, 1=explored, 2=visible).
---@param x any
---@param y any
---@param level any
function LMinimap:setFogLevel(x, y, level) end

--- Switches the minimap's active render layer (0-based index).
---@param layer any
function LMinimap:setLayer(layer) end

--- Stores tile data for a specific layer index.
---@param layer any
---@param data_tbl any
function LMinimap:setLayerData(layer, data_tbl) end

--- Attaches an animation to a marker. Does nothing if the ID does not exist.
---@param id any
---@param anim_type any
---@param speed any
function LMinimap:setMarkerAnimation(id, anim_type, speed) end

--- Sets or updates a tracked object on the minimap.
---@param id any
---@param x any
---@param y any
---@param type_idx any
---@param owner? any
function LMinimap:setObject(id, x, y, type_idx, owner) end

--- Sets whether an object type (1-based index) is visible.
---@param type_idx any
---@param visible any
function LMinimap:setObjectTypeVisible(type_idx, visible) end

--- Sets the display color for an owner/faction.
---@param owner any
---@param r any
---@param g any
---@param b any
---@param a? any
function LMinimap:setOwnerColor(owner, r, g, b, a) end

--- Sets the terrain type at a 1-based grid position.
---@param x any
---@param y any
---@param terrain_type any
function LMinimap:setTerrain(x, y, terrain_type) end

--- Sets the display color for a terrain type.
---@param terrain_type any
---@param r any
---@param g any
---@param b any
---@param a? any
function LMinimap:setTerrainColor(terrain_type, r, g, b, a) end

--- Sets terrain types from a flat 1-based Lua table of integers (row-major).
---@param data any
function LMinimap:setTerrainData(data) end

--- Sets a hover tooltip string for a terrain type ID.
---@param type_id any
---@param desc any
function LMinimap:setTileDescription(type_id, desc) end

--- Sets the viewport rectangle color.
---@param r any
---@param g any
---@param b any
---@param a? any
function LMinimap:setViewportColor(r, g, b, a) end

--- Sets the viewport rectangle overlay in grid coordinates.
---@param x any
---@param y any
---@param w any
---@param h any
function LMinimap:setViewportRect(x, y, w, h) end

--- Sets whether the viewport rectangle is visible.
---@param visible any
function LMinimap:setViewportVisible(visible) end

--- Sets the zoom level (minimum 0.1).
---@param zoom any
function LMinimap:setZoom(zoom) end

--- Displays a pathfinding route on the minimap and returns its path ID.
---@param points_tbl any
---@param color_tbl any
function LMinimap:showPath(points_tbl, color_tbl) end

--- Returns the type name of this object.
function LMinimap:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMinimap:typeOf(name) end

--- Advances time-based effects by dt seconds (expires pings).
---@param dt any
function LMinimap:update(dt) end

--- Creates a new grid-based minimap.
---@param grid_w any
---@param grid_h any
---@param display_w? any
---@param display_h? any
lurek.minimap.newMinimap = function(grid_w, grid_h, display_w, display_h) end

---@class lurek.mods
lurek.mods = {}

--- A typed content registry for mod-contributed assets and objects.
---@class LContentRegistry
LContentRegistry = {}

--- Retrieve a content entry.
---@param type_name any
---@param id any
function LContentRegistry:get(type_name, id) end

--- Get all entries for a type.
---@param type_name any
function LContentRegistry:getAll(type_name) end

--- Get all registered type names.
function LContentRegistry:getTypes() end

--- Register a content entry.
---@param type_name any
---@param id any
---@param obj any
function LContentRegistry:register(type_name, id, obj) end

--- Register a new content type.
---@param type_name any
function LContentRegistry:registerType(type_name) end

--- Returns the type name of this object.
function LContentRegistry:type() end

--- Returns true if this object is of the given type.
---@param name any
function LContentRegistry:typeOf(name) end

--- Lua-side wrapper around [`ModInfo`] with per-mod hook and config storage.
---@class LMod
LMod = {}

--- Returns the required engine API version string, or nil if not set
function LMod:getApiVersion() end

--- Returns the author name string from this mod's metadata manifest
function LMod:getAuthor() end

--- Returns an array of declared capability flags
function LMod:getCapabilities() end

--- Returns the stored config value, or nil
function LMod:getConfig() end

--- Returns the config schema as an array of `{key, type, default}` tables.
function LMod:getConfigSchema() end

--- Returns the list of required mod IDs
function LMod:getDependencies() end

--- Returns the mod description
function LMod:getDescription() end

--- Returns the hook function for the given name, or nil
---@param name any
function LMod:getHook(name) end

--- Returns an array of registered hook names
function LMod:getHookNames() end

--- Returns the unique mod identifier
function LMod:getId() end

--- Returns the localized or human-readable display name of the mod.
function LMod:getName() end

--- Returns the load-order priority
function LMod:getPriority() end

--- Returns the version string
function LMod:getVersion() end

--- Returns whether a hook with the given name exists
---@param name any
function LMod:hasHook(name) end

--- Returns whether the mod is enabled
function LMod:isEnabled() end

--- Returns whether the mod has been loaded
function LMod:isLoaded() end

--- Releases all hook and config registry references
function LMod:releaseRefs() end

--- Sets the required engine API version string
---@param api_version any
function LMod:setApiVersion(api_version) end

--- Replaces the capability list with the given array of strings
---@param caps any
function LMod:setCapabilities(caps) end

--- Stores an arbitrary config value for this mod
---@param value any
function LMod:setConfig(value) end

--- Replaces the config schema with the given array of `{key, type, default}` tables.
---@param schema any
function LMod:setConfigSchema(schema) end

--- Enables or disables this mod; disabled mods are skipped during loading
---@param enabled any
function LMod:setEnabled(enabled) end

--- Registers a named hook callback, replacing any existing one
---@param name any
---@param func any
function LMod:setHook(name, func) end

--- Returns the type name of this object.
function LMod:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMod:typeOf(name) end

--- Lua-side wrapper around [`ModManager`].
---@class LModManager
LModManager = {}

--- Clears the custom load order, reverting to priority-based sorting
function LModManager:clearLoadOrder() end

--- Clears the reload queue without reloading
function LModManager:clearReloadQueue() end

--- Returns an array of info tables for all registered mods
function LModManager:getAllMods() end

--- Returns an array of info tables in effective load order
function LModManager:getLoadOrder() end

--- Returns the number of registered mods
function LModManager:getModCount() end

--- Returns the filesystem path of a registered mod, or nil
---@param mod_id any
function LModManager:getModPath(mod_id) end

--- Returns the array of mod IDs pending hot-reload
function LModManager:getReloadQueue() end

--- Returns whether any circular dependency cycles exist
function LModManager:hasCircularDependencies() end

--- Returns whether a mod with the given ID is registered
---@param mod_id any
function LModManager:hasMod(mod_id) end

--- Marks a registered mod for hot-reload
---@param mod_id any
function LModManager:markForReload(mod_id) end

--- Registers a mod from its Mod userdata
---@param ud any
function LModManager:registerMod(ud) end

--- Scans a directory for mods with mod.toml and registers them
---@param path any
function LModManager:scanFolder(path) end

--- Sets an explicit load order from an array of mod ID strings
---@param order_table any
function LModManager:setLoadOrder(order_table) end

--- Returns the type name of this object.
function LModManager:type() end

--- Returns true if this object is of the given type.
---@param name any
function LModManager:typeOf(name) end

--- Removes a mod by ID and returns whether it was found
---@param mod_id any
function LModManager:unregisterMod(mod_id) end

--- Returns an array of mod IDs with missing dependencies
function LModManager:validateDependencies() end

--- Checks whether a mod's required `api_version` is compatible with the given `host_version`.
---@param mod_ud any
---@param host_version any
lurek.mods.checkApiVersion = function(mod_ud, host_version) end

--- Creates a new Mod from an info table with at least an `id` field.
---@param info any
lurek.mods.newMod = function(info) end

--- Creates a new empty ModManager.
lurek.mods.newModManager = function() end

--- Creates a new empty ContentRegistry for mod-contributed assets.
lurek.mods.newRegistry = function() end

---@class lurek.network
lurek.network = {}

--- Lua-side wrapper around [`NetworkHost`].
---@class LNetworkHost
LNetworkHost = {}

--- Broadcasts data to all connected peers on a channel.
---@param channel_id any
---@param data any
---@param reliable? any
function LNetworkHost:broadcast(channel_id, data, reliable) end

--- Initiates a connection to a remote host, returning the peer ID.
---@param addr_str any
---@param channels? any
---@param data? any
function LNetworkHost:connect(addr_str, channels, data) end

--- Destroys the host, closing the underlying socket.
function LNetworkHost:destroy() end

--- Gracefully disconnects a peer.
---@param peer_id any
---@param data? any
function LNetworkHost:disconnect(peer_id, data) end

--- Disconnects a peer after all queued packets have been sent.
---@param peer_id any
---@param data? any
function LNetworkHost:disconnectLater(peer_id, data) end

--- Immediately disconnects a peer without handshake.
---@param peer_id any
---@param data? any
function LNetworkHost:disconnectNow(peer_id, data) end

--- Flushes all pending sends immediately.
function LNetworkHost:flush() end

--- Returns the local bind address as a string.
function LNetworkHost:getAddress() end

--- Returns the bandwidth limits as a table with incoming and outgoing fields.
function LNetworkHost:getBandwidthLimit() end

--- Returns the maximum number of channels per connection.
function LNetworkHost:getChannelLimit() end

--- Returns the number of currently connected peers.
function LNetworkHost:getConnectedPeerCount() end

--- Returns a table of connected peer IDs.
function LNetworkHost:getConnectedPeerIds() end

--- Returns the remote address of a peer, or nil if unavailable.
---@param peer_id any
function LNetworkHost:getPeerAddress(peer_id) end

--- Returns the maximum number of peer slots.
function LNetworkHost:getPeerLimit() end

--- Returns the connection state of a peer as a string.
---@param peer_id any
function LNetworkHost:getPeerState(peer_id) end

--- Returns a statistics table for a peer.
---@param peer_id any
function LNetworkHost:getPeerStats(peer_id) end

--- Returns the multiplayer role of this host ("server", "client", or "host").
function LNetworkHost:getRole() end

--- Returns the round-trip time estimate for a peer in milliseconds.
---@param peer_id any
function LNetworkHost:getRoundTripTime(peer_id) end

--- Returns true if this host was created as a client.
function LNetworkHost:isClient() end

--- Returns true if the host has been destroyed.
function LNetworkHost:isDestroyed() end

--- Returns true if this host was created as a server.
function LNetworkHost:isServer() end

--- Sends a ping to a peer to measure round-trip time.
---@param peer_id any
function LNetworkHost:ping(peer_id) end

--- Resets a peer connection immediately without notifying the remote side.
---@param peer_id any
function LNetworkHost:resetPeer(peer_id) end

--- Sends data to a specific peer on a channel.
---@param peer_id any
---@param channel_id any
---@param data any
---@param reliable? any
function LNetworkHost:send(peer_id, channel_id, data, reliable) end

--- Polls the network for one event, returning an event table or nil.
function LNetworkHost:service() end

--- Sets the bandwidth limits in bytes per second.
---@param incoming? any
---@param outgoing? any
function LNetworkHost:setBandwidthLimit(incoming, outgoing) end

--- Sets the channel limit for future connections.
---@param limit any
function LNetworkHost:setChannelLimit(limit) end

--- Returns the type name of this object.
function LNetworkHost:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNetworkHost:typeOf(name) end

--- Lua-side wrapper around [`NetworkRuntime`] for async HTTP/TCP/WebSocket.
---@class LNetworkRuntime
LNetworkRuntime = {}

--- Convenience: sends an HTTP GET request.
---@param url any
---@param headers? any
function LNetworkRuntime:httpGet(url, headers) end

--- Convenience: sends an HTTP POST request.
---@param url any
---@param body any
---@param headers? any
function LNetworkRuntime:httpPost(url, body, headers) end

--- Sends an HTTP request asynchronously. Poll with `poll()` for the response.
---@param opts any
function LNetworkRuntime:httpRequest(opts) end

--- Polls for completed async responses (HTTP, TCP events, WebSocket events).
function LNetworkRuntime:poll() end

--- Shuts down the background network thread.
function LNetworkRuntime:shutdown() end

--- Closes the TCP connection identified by the given connection handle.
---@param id any
function LNetworkRuntime:tcpClose(id) end

--- Opens a TCP connection to a remote address.
---@param addr any
function LNetworkRuntime:tcpConnect(addr) end

--- Sends data over a TCP connection.
---@param id any
---@param data any
function LNetworkRuntime:tcpSend(id, data) end

--- Returns the type name of this object.
function LNetworkRuntime:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNetworkRuntime:typeOf(name) end

--- Closes a WebSocket connection.
---@param id any
function LNetworkRuntime:wsClose(id) end

--- Opens a WebSocket connection.
---@param url any
function LNetworkRuntime:wsConnect(url) end

--- Sends a text message over a WebSocket connection.
---@param id any
---@param data any
function LNetworkRuntime:wsSend(id, data) end

--- Creates a LobbyInfo record and broadcasts it once on the local network.
---@param name any
---@param port any
---@param player_count? any
---@param max_players? any
lurek.network.createLobby = function(name, port, player_count, max_players) end

--- Listens for LAN lobby announcements for `timeout_ms` milliseconds (default 500).
---@param timeout_ms? any
lurek.network.discoverLobbies = function(timeout_ms) end

--- Creates a client host that connects to a remote server.
---@param opts any
lurek.network.newClient = function(opts) end

--- Creates a new network host bound to the given address.
---@param opts any
lurek.network.newHost = function(opts) end

--- Creates a background network runtime for async HTTP, TCP, and WebSocket.
lurek.network.newRuntime = function() end

--- Creates a server host that binds to a port and accepts connections.
---@param opts any
lurek.network.newServer = function(opts) end

--- Serializes a Lua value to a binary MessagePack string.
---@param value any
lurek.network.pack = function(value) end

--- Convenience helper: packs an entity snapshot and broadcasts it to all peers.
lurek.network.syncEntity = function() end

--- Deserializes a MessagePack binary string back to a Lua value.
---@param data any
lurek.network.unpack = function(data) end

---@class lurek.parallax
lurek.parallax = {}

--- Lua-side handle to a single parallax background layer.
---@class LParallaxLayer
LParallaxLayer = {}

--- Removes scroll clamping so the layer scrolls freely.
function LParallaxLayer:clearClamp() end

--- Returns the autoscroll velocity as `(vx, vy)`.
function LParallaxLayer:getAutoscroll() end

--- Returns the current blend mode as a string.
function LParallaxLayer:getBlendMode() end

--- Returns the current floating-point depth.
function LParallaxLayer:getDepth() end

--- Returns the static offset as `(x, y)`.
function LParallaxLayer:getOffset() end

--- Returns the current opacity.
function LParallaxLayer:getOpacity() end

--- Returns the scroll factor as `(x, y)`.
function LParallaxLayer:getScrollFactor() end

--- Returns `true` if seamless infinite tiling is enabled.
function LParallaxLayer:getTiling() end

--- Returns the current tint as `(r, g, b, a)`.
function LParallaxLayer:getTint() end

--- Returns the draw-order depth.
function LParallaxLayer:getZ() end

--- Returns `true` if the layer is currently visible.
function LParallaxLayer:isVisible() end

--- Draws the layer using an explicit camera world position.
---@param cam_x any
---@param cam_y any
function LParallaxLayer:render(cam_x, cam_y) end

--- Draws the layer using the engine active camera position automatically.
function LParallaxLayer:renderAuto() end

--- Resets the autonomous scroll accumulator to zero.
function LParallaxLayer:resetAutoscroll() end

--- Sets the autonomous scroll velocity in world-pixels per second.
---@param vx any
---@param vy any
function LParallaxLayer:setAutoscroll(vx, vy) end

--- Sets the GPU blend mode for this layer.
---@param mode any
function LParallaxLayer:setBlendMode(mode) end

--- Clamps the scroll offset to a world-pixel range on each axis.
---@param min_x any
---@param min_y any
---@param max_x any
---@param max_y any
function LParallaxLayer:setClamp(min_x, min_y, max_x, max_y) end

--- Sets the floating-point draw depth for fine-grained layer ordering.
---@param z any
function LParallaxLayer:setDepth(z) end

--- Sets the static world-pixel position bias added on top of camera scroll.
---@param x any
---@param y any
function LParallaxLayer:setOffset(x, y) end

--- Sets the layer-wide opacity override in `[0.0, 1.0]`.
---@param a any
function LParallaxLayer:setOpacity(a) end

--- Sets whether the layer tiles on the X and Y axes.
---@param rx any
---@param ry any
function LParallaxLayer:setRepeat(rx, ry) end

--- Sets the texture display scale factor on each axis.
---@param sx any
---@param sy any
function LParallaxLayer:setScale(sx, sy) end

--- Sets the scroll factor relative to camera movement on each axis.
---@param x any
---@param y any
function LParallaxLayer:setScrollFactor(x, y) end

--- Sets explicit tile dimensions in logical pixels, overriding the default
---@param w any
---@param h any
function LParallaxLayer:setTileSize(w, h) end

--- Enables or disables seamless infinite tiling on both axes simultaneously.
---@param enabled any
function LParallaxLayer:setTiling(enabled) end

--- Sets the multiplicative RGBA tint applied to all pixels of this layer.
---@param r any
---@param g any
---@param b any
---@param a any
function LParallaxLayer:setTint(r, g, b, a) end

--- Shows or hides this layer.
---@param v any
function LParallaxLayer:setVisible(v) end

--- Sets the draw-order depth. Lower values render first (further back).
---@param z any
function LParallaxLayer:setZ(z) end

--- Returns the type name of this object.
function LParallaxLayer:type() end

--- Advances the autonomous scroll accumulator by `dt` seconds.
---@param dt any
function LParallaxLayer:update(dt) end

--- Lua-side container that groups `LuaParallaxLayer` objects for scene-level management.
---@class LParallaxSet
LParallaxSet = {}

--- Adds a layer to this set.
---@param layer any
function LParallaxSet:addLayer(layer) end

--- Returns the name of this set.
function LParallaxSet:getName() end

--- Returns `true` if the set is currently visible.
function LParallaxSet:isVisible() end

--- Returns the number of layers in this set.
function LParallaxSet:layerCount() end

--- Removes the layer at the given 1-based index.
---@param index any
function LParallaxSet:removeLayerAt(index) end

--- Draws all visible layers in ascending `z` order using an explicit camera position.
---@param cam_x any
---@param cam_y any
function LParallaxSet:render(cam_x, cam_y) end

--- Draws all visible layers using the engine active camera position.
function LParallaxSet:renderAuto() end

--- Sets the name of this set.
---@param name any
function LParallaxSet:setName(name) end

--- Shows or hides all layers in this set.
---@param v any
function LParallaxSet:setVisible(v) end

--- Re-sorts all layers by ascending `z` value.
function LParallaxSet:sortByZ() end

--- Returns the type name of this object.
function LParallaxSet:type() end

--- Advances the autoscroll accumulator of every layer by `dt` seconds.
---@param dt any
function LParallaxSet:update(dt) end

--- Creates a new parallax background layer from an options table.
---@param opts any
lurek.parallax.newLayer = function(opts) end

--- Creates a new empty parallax set with the given name.
---@param name any
lurek.parallax.newSet = function(name) end

---@class lurek.particle
lurek.particle = {}

--- Lua-side handle to a particle system stored in SharedState.
---@class LParticleSystem
LParticleSystem = {}

--- Adds a gravity well that pulls (positive strength) or repels
---@param x any
---@param y any
---@param strength any
---@param radius any
function LParticleSystem:addAttractor(x, y, strength, radius) end

--- Attaches a sub-emitter that bursts when a particle dies.
---@param config_tbl any
---@param burst_count? any
function LParticleSystem:addSubEmitter(config_tbl, burst_count) end

--- Adds a child emitter that updates and renders with this system.
---@param config_tbl any
function LParticleSystem:addSubSystem(config_tbl) end

--- Removes all attractors from this particle system.
function LParticleSystem:clearAttractors() end

--- Removes the bounding rectangle so particles can move freely.
function LParticleSystem:clearBounds() end

--- Creates a copy of this particle system (config only, no live particles).
function LParticleSystem:clone() end

--- Returns the number of living particles.
function LParticleSystem:count() end

--- Renders all live particles to a CPU ImageData.
---@param w any
---@param h any
function LParticleSystem:drawToImage(w, h) end

--- Emits a burst of the given number of particles.
---@param count any
function LParticleSystem:emit(count) end

--- Returns the number of attractors currently registered on this system.
function LParticleSystem:getAttractorCount() end

--- Returns the maximum particle count.
function LParticleSystem:getBufferSize() end

--- Returns color keyframes as a table of {r,g,b,a} tables.
function LParticleSystem:getColors() end

--- Returns the number of living particles (alias for count).
function LParticleSystem:getCount() end

--- Returns emission direction in radians.
function LParticleSystem:getDirection() end

--- Returns emission area: dist-string, w, h.
function LParticleSystem:getEmissionArea() end

--- Returns particles emitted per second.
function LParticleSystem:getEmissionRate() end

--- Returns the emitter lifetime.
function LParticleSystem:getEmitterLifetime() end

--- Returns the current flipbook configuration as `(cols, rows, fps)`, or `nil` if not set.
function LParticleSystem:getFlipbook() end

--- Returns the gravity acceleration applied to particles as two numbers `gx, gy`.
function LParticleSystem:getGravity() end

--- Returns the insert mode as a string.
function LParticleSystem:getInsertMode() end

--- Returns linear acceleration range.
function LParticleSystem:getLinearAcceleration() end

--- Returns linear damping range.
function LParticleSystem:getLinearDamping() end

--- Returns the render origin offset.
function LParticleSystem:getOffset() end

--- Returns min and max particle lifetime.
function LParticleSystem:getParticleLifetime() end

--- Returns the emitter world position.
function LParticleSystem:getPosition() end

--- Returns radial acceleration range.
function LParticleSystem:getRadialAcceleration() end

--- Returns initial rotation range.
function LParticleSystem:getRotation() end

--- Returns the particle draw shape as a string.
function LParticleSystem:getShape() end

--- Returns the maximum random size variation applied to newly emitted particles.
function LParticleSystem:getSizeVariation() end

--- Returns size keyframes as a Lua table.
function LParticleSystem:getSizes() end

--- Returns min/max initial speed.
function LParticleSystem:getSpeed() end

--- Returns angular velocity range.
function LParticleSystem:getSpin() end

--- Returns the maximum random angular velocity variation for new particles.
function LParticleSystem:getSpinVariation() end

--- Returns the half-angle spread in radians for the emission cone.
function LParticleSystem:getSpread() end

--- Returns tangential acceleration range.
function LParticleSystem:getTangentialAcceleration() end

--- Returns whether relative rotation is enabled.
function LParticleSystem:hasRelativeRotation() end

--- Returns true if the emitter is currently emitting or has live particles.
function LParticleSystem:isActive() end

--- Returns true if there are no live particles.
function LParticleSystem:isEmpty() end

--- Returns true if the system has reached max_particles.
function LParticleSystem:isFull() end

--- Returns true if the emitter is paused.
function LParticleSystem:isPaused() end

--- Returns true if the emitter is stopped.
function LParticleSystem:isStopped() end

--- Moves the emitter to the given world position.
---@param x any
---@param y any
function LParticleSystem:moveTo(x, y) end

--- Pauses particle emission; existing particles continue to simulate.
function LParticleSystem:pause() end

--- Removes the particle system from the engine, freeing its slot.
function LParticleSystem:release() end

--- Renders all live particles to the GPU command queue.
---@param ox? any
---@param oy? any
function LParticleSystem:render(ox, oy) end

--- Removes all particles and resets the emitter.
function LParticleSystem:reset() end

--- Resumes a paused emitter.
function LParticleSystem:resume() end

--- Constrains all particles to an axis-aligned bounding rectangle.
---@param xmin any
---@param xmax any
---@param ymin any
---@param ymax any
---@param restitution any
function LParticleSystem:setBounds(xmin, xmax, ymin, ymax, restitution) end

--- Sets the maximum number of particles (resizes the pool).
---@param n any
function LParticleSystem:setBufferSize(n) end

--- Sets color keyframes. Each arg is a table {r, g, b, a}.
---@param ... any
function LParticleSystem:setColors(...) end

--- Sets a Lua function that returns (offset_x, offset_y) for each newly spawned
---@param cb any
function LParticleSystem:setCustomEmissionShape(cb) end

--- Sets emission direction in radians.
---@param dir any
function LParticleSystem:setDirection(dir) end

--- Sets emission area distribution and size.
---@param dist any
---@param w any
---@param h any
---@param angle? any
---@param dir_rel? any
function LParticleSystem:setEmissionArea(dist, w, h, angle, dir_rel) end

--- Sets particles emitted per second.
---@param rate any
function LParticleSystem:setEmissionRate(rate) end

--- Sets how long the emitter runs before auto-stopping. Negative = infinite.
---@param t any
function LParticleSystem:setEmitterLifetime(t) end

--- Configures sprite-sheet flipbook animation by dividing the texture into a grid.
---@param cols any
---@param rows any
---@param fps any
function LParticleSystem:setFlipbook(cols, rows, fps) end

--- Sets the gravity acceleration applied to all active particles each frame.
---@param gx any
---@param gy any
function LParticleSystem:setGravity(gx, gy) end

--- Sets the insert mode: "top", "bottom", or "random".
---@param mode any
function LParticleSystem:setInsertMode(mode) end

--- Sets linear acceleration range.
---@param xmin any
---@param ymin any
---@param xmax any
---@param ymax any
function LParticleSystem:setLinearAcceleration(xmin, ymin, xmax, ymax) end

--- Sets linear damping range.
---@param min any
---@param max any
function LParticleSystem:setLinearDamping(min, max) end

--- Sets the render origin offset.
---@param ox any
---@param oy any
function LParticleSystem:setOffset(ox, oy) end

--- Sets a Lua function called after each update() with all particles that died
---@param cb any
function LParticleSystem:setOnDeathBatch(cb) end

--- Sets min and max particle lifetime in seconds.
---@param min any
---@param max any
function LParticleSystem:setParticleLifetime(min, max) end

--- Sets the emitter world position.
---@param x any
---@param y any
function LParticleSystem:setPosition(x, y) end

--- Sets radial acceleration range.
---@param min any
---@param max any
function LParticleSystem:setRadialAcceleration(min, max) end

--- Sets whether particle rotation follows velocity direction.
---@param v any
function LParticleSystem:setRelativeRotation(v) end

--- Sets initial rotation range in radians.
---@param min any
---@param max any
function LParticleSystem:setRotation(min, max) end

--- Sets the particle draw shape.
---@param shape any
function LParticleSystem:setShape(shape) end

--- Sets size variation (0â€“1).
---@param v any
function LParticleSystem:setSizeVariation(v) end

--- Sets size keyframes (varargs: each number is one keyframe).
---@param ... any
function LParticleSystem:setSizes(...) end

--- Sets min/max initial speed.
---@param min any
---@param max any
function LParticleSystem:setSpeed(min, max) end

--- Sets angular velocity range.
---@param min any
---@param max any
function LParticleSystem:setSpin(min, max) end

--- Sets spin variation (0â€“1).
---@param v any
function LParticleSystem:setSpinVariation(v) end

--- Sets emission spread (half-angle cone) in radians.
---@param spread any
function LParticleSystem:setSpread(spread) end

--- Sets tangential acceleration range.
---@param min any
---@param max any
function LParticleSystem:setTangentialAcceleration(min, max) end

--- Starts or restarts particle emission.
function LParticleSystem:start() end

--- Stops particle emission immediately.
function LParticleSystem:stop() end

--- Returns the number of direct child sub-systems attached to this emitter.
function LParticleSystem:subSystemCount() end

--- Alias for `drawToImage`. Renders all live particles to a CPU ImageData.
---@param w any
---@param h any
function LParticleSystem:toImage(w, h) end

--- Returns the type name "ParticleSystem".
function LParticleSystem:type() end

--- Returns true if this matches the given type name.
---@param name any
function LParticleSystem:typeOf(name) end

--- Advances the particle simulation by dt seconds.
---@param dt any
function LParticleSystem:update(dt) end

--- Pre-simulates the particle system for `seconds` so it appears fully
---@param seconds any
function LParticleSystem:warmUp(seconds) end

--- Lua-side wrapper around a [`Trail`] ribbon effect.
---@class LTrail
LTrail = {}

--- Removes all trail points.
function LTrail:clear() end

--- Renders the trail ribbon to a CPU ImageData.
---@param w any
---@param h any
function LTrail:drawToImage(w, h) end

--- Returns the trail point lifetime in seconds.
function LTrail:getLifetime() end

--- Returns the number of active trail points.
function LTrail:getPointCount() end

--- Returns the start and end width.
function LTrail:getWidth() end

--- Appends a new point to the trail head.
---@param x any
---@param y any
function LTrail:pushPoint(x, y) end

--- Sets the colour at the newest end of the trail.
---@param r any
---@param g any
---@param b any
---@param a any
function LTrail:setHeadColor(r, g, b, a) end

--- Sets how long each trail point persists in seconds.
---@param lifetime any
function LTrail:setLifetime(lifetime) end

--- Sets the minimum distance between trail points.
---@param distance any
function LTrail:setMinDistance(distance) end

--- Sets the colour at the oldest end of the trail.
---@param r any
---@param g any
---@param b any
---@param a any
function LTrail:setTailColor(r, g, b, a) end

--- Sets the start and end width of the trail ribbon.
---@param start any
---@param end_? any
function LTrail:setWidth(start, end_) end

--- Returns the type name of this object.
function LTrail:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTrail:typeOf(name) end

--- Ages trail points and removes expired ones.
---@param dt any
function LTrail:update(dt) end

--- Creates a new particle system from a TOML config file.
---@param path any
lurek.particle.fromTOML = function(path) end

--- Creates a new particle system and stores it in the engine pool.
---@param config? any
lurek.particle.newSystem = function(config) end

--- Creates a new trail ribbon effect.
---@param lifetime any
---@param start_width any
lurek.particle.newTrail = function(lifetime, start_width) end

-- Flat forwarding: lurek.particle.METHOD(ps,...) == ps:METHOD(...)
lurek.particle.addAttractor = LParticleSystem.addAttractor
lurek.particle.addSubEmitter = LParticleSystem.addSubEmitter
lurek.particle.addSubSystem = LParticleSystem.addSubSystem
lurek.particle.clearAttractors = LParticleSystem.clearAttractors
lurek.particle.clearBounds = LParticleSystem.clearBounds
lurek.particle.clone = LParticleSystem.clone
lurek.particle.count = LParticleSystem.count
lurek.particle.drawToImage = LParticleSystem.drawToImage
lurek.particle.emit = LParticleSystem.emit
lurek.particle.getAttractorCount = LParticleSystem.getAttractorCount
lurek.particle.getBufferSize = LParticleSystem.getBufferSize
lurek.particle.getColors = LParticleSystem.getColors
lurek.particle.getCount = LParticleSystem.getCount
lurek.particle.getDirection = LParticleSystem.getDirection
lurek.particle.getEmissionArea = LParticleSystem.getEmissionArea
lurek.particle.getEmissionRate = LParticleSystem.getEmissionRate
lurek.particle.getEmitterLifetime = LParticleSystem.getEmitterLifetime
lurek.particle.getFlipbook = LParticleSystem.getFlipbook
lurek.particle.getGravity = LParticleSystem.getGravity
lurek.particle.getInsertMode = LParticleSystem.getInsertMode
lurek.particle.getLinearAcceleration = LParticleSystem.getLinearAcceleration
lurek.particle.getLinearDamping = LParticleSystem.getLinearDamping
lurek.particle.getOffset = LParticleSystem.getOffset
lurek.particle.getParticleLifetime = LParticleSystem.getParticleLifetime
lurek.particle.getPosition = LParticleSystem.getPosition
lurek.particle.getRadialAcceleration = LParticleSystem.getRadialAcceleration
lurek.particle.getRotation = LParticleSystem.getRotation
lurek.particle.getShape = LParticleSystem.getShape
lurek.particle.getSizeVariation = LParticleSystem.getSizeVariation
lurek.particle.getSizes = LParticleSystem.getSizes
lurek.particle.getSpeed = LParticleSystem.getSpeed
lurek.particle.getSpin = LParticleSystem.getSpin
lurek.particle.getSpinVariation = LParticleSystem.getSpinVariation
lurek.particle.getSpread = LParticleSystem.getSpread
lurek.particle.getTangentialAcceleration = LParticleSystem.getTangentialAcceleration
lurek.particle.hasRelativeRotation = LParticleSystem.hasRelativeRotation
lurek.particle.isActive = LParticleSystem.isActive
lurek.particle.isEmpty = LParticleSystem.isEmpty
lurek.particle.isFull = LParticleSystem.isFull
lurek.particle.isPaused = LParticleSystem.isPaused
lurek.particle.isStopped = LParticleSystem.isStopped
lurek.particle.moveTo = LParticleSystem.moveTo
lurek.particle.pause = LParticleSystem.pause
lurek.particle.release = LParticleSystem.release
lurek.particle.render = LParticleSystem.render
lurek.particle.reset = LParticleSystem.reset
lurek.particle.resume = LParticleSystem.resume
lurek.particle.setBounds = LParticleSystem.setBounds
lurek.particle.setBufferSize = LParticleSystem.setBufferSize
lurek.particle.setColors = LParticleSystem.setColors
lurek.particle.setCustomEmissionShape = LParticleSystem.setCustomEmissionShape
lurek.particle.setDirection = LParticleSystem.setDirection
lurek.particle.setEmissionArea = LParticleSystem.setEmissionArea
lurek.particle.setEmissionRate = LParticleSystem.setEmissionRate
lurek.particle.setEmitterLifetime = LParticleSystem.setEmitterLifetime
lurek.particle.setFlipbook = LParticleSystem.setFlipbook
lurek.particle.setGravity = LParticleSystem.setGravity
lurek.particle.setInsertMode = LParticleSystem.setInsertMode
lurek.particle.setLinearAcceleration = LParticleSystem.setLinearAcceleration
lurek.particle.setLinearDamping = LParticleSystem.setLinearDamping
lurek.particle.setOffset = LParticleSystem.setOffset
lurek.particle.setOnDeathBatch = LParticleSystem.setOnDeathBatch
lurek.particle.setParticleLifetime = LParticleSystem.setParticleLifetime
lurek.particle.setPosition = LParticleSystem.setPosition
lurek.particle.setRadialAcceleration = LParticleSystem.setRadialAcceleration
lurek.particle.setRelativeRotation = LParticleSystem.setRelativeRotation
lurek.particle.setRotation = LParticleSystem.setRotation
lurek.particle.setShape = LParticleSystem.setShape
lurek.particle.setSizeVariation = LParticleSystem.setSizeVariation
lurek.particle.setSizes = LParticleSystem.setSizes
lurek.particle.setSpeed = LParticleSystem.setSpeed
lurek.particle.setSpin = LParticleSystem.setSpin
lurek.particle.setSpinVariation = LParticleSystem.setSpinVariation
lurek.particle.setSpread = LParticleSystem.setSpread
lurek.particle.setTangentialAcceleration = LParticleSystem.setTangentialAcceleration
lurek.particle.start = LParticleSystem.start
lurek.particle.stop = LParticleSystem.stop
lurek.particle.subSystemCount = LParticleSystem.subSystemCount
lurek.particle.toImage = LParticleSystem.toImage
lurek.particle.type = LParticleSystem.type
lurek.particle.typeOf = LParticleSystem.typeOf
lurek.particle.update = LParticleSystem.update
lurek.particle.warmUp = LParticleSystem.warmUp

---@class lurek.pathfind
lurek.pathfind = {}

--- Lua-side wrapper around a PathGrid-based [`AiFlowField`].
---@class LAIFlowField
LAIFlowField = {}

--- Returns the normalised direction toward the goal (1-based coordinates).
---@param x any
---@param y any
function LAIFlowField:getDirection(x, y) end

--- Returns the BFS distance to the goal (1-based coordinates).
---@param x any
---@param y any
function LAIFlowField:getDistance(x, y) end

--- Returns the goal cell (1-based coordinates) or nil if unset.
function LAIFlowField:getGoal() end

--- Returns the flow field grid height in cells.
function LAIFlowField:getHeight() end

--- Returns the flow field grid width in cells.
function LAIFlowField:getWidth() end

--- Returns true if a goal has been set.
function LAIFlowField:hasGoal() end

--- Sets the goal cell and triggers BFS recomputation (1-based coordinates).
---@param x any
---@param y any
function LAIFlowField:setGoal(x, y) end

--- Returns the type name of this object.
function LAIFlowField:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAIFlowField:typeOf(name) end

--- Lua-side wrapper around a [`FlowField`].
---@class LFlowField
LFlowField = {}

--- Computes the flow field toward a single target (1-based coordinates).
---@param tx any
---@param ty any
---@param unit_size? any
function LFlowField:calculate(tx, ty, unit_size) end

--- Computes the flow field toward multiple targets (1-based coordinates).
---@param targets any
---@param unit_size? any
function LFlowField:calculateMulti(targets, unit_size) end

--- Returns the integrated cost to the nearest target (1-based coordinates).
---@param x any
---@param y any
function LFlowField:getCostToTarget(x, y) end

--- Returns the normalised direction vector at a cell (1-based coordinates).
---@param x any
---@param y any
function LFlowField:getDirection(x, y) end

--- Returns the flow direction as an angle in radians (1-based coordinates).
---@param x any
---@param y any
function LFlowField:getDirectionAngle(x, y) end

--- Returns the target cells from the most recent computation (1-based coordinates).
function LFlowField:getTargets() end

--- Returns true if the flow field has been computed at least once.
function LFlowField:isCalculated() end

--- Converts a world-space position into a velocity vector via the flow field.
---@param wx any
---@param wy any
---@param speed any
---@param tw any
---@param th any
function LFlowField:steer(wx, wy, speed, tw, th) end

--- Returns the type name of this object.
function LFlowField:type() end

--- Returns true if this object is of the given type.
---@param name any
function LFlowField:typeOf(name) end

--- Lua-side wrapper around a [`HexGrid`].
---@class LHexGrid
LHexGrid = {}

--- Hex-distance between two cells.
---@param c1 any
---@param r1 any
---@param c2 any
---@param r2 any
function LHexGrid:distance(c1, r1, c2, r2) end

--- Returns all cells visible from origin within max_range (1-based coordinates).
---@param col any
---@param row any
---@param max_range any
function LHexGrid:fieldOfView(col, row, max_range) end

--- Find A* path between two cells (1-based coordinates).
---@param fc any
---@param fr any
---@param tc any
---@param tr any
function LHexGrid:findPath(fc, fr, tc, tr) end

--- Returns true if a cell is blocked (1-based coordinates).
---@param col any
---@param row any
function LHexGrid:isBlocked(col, row) end

--- Returns true if there is an unobstructed line between two cells (1-based).
---@param fc any
---@param fr any
---@param tc any
---@param tr any
function LHexGrid:lineOfSight(fc, fr, tc, tr) end

--- Returns all cells reachable from origin within movement budget (1-based).
---@param col any
---@param row any
---@param budget any
function LHexGrid:rangeOfMovement(col, row, budget) end

--- Mark/unmark a cell as blocked (1-based coordinates).
---@param col any
---@param row any
---@param blocked any
function LHexGrid:setBlocked(col, row, blocked) end

--- Set movement cost for a cell (1-based coordinates).
---@param col any
---@param row any
---@param cost any
function LHexGrid:setCost(col, row, cost) end

--- Returns the type name of this object.
function LHexGrid:type() end

--- Returns true if this object is of the given type.
---@param name any
function LHexGrid:typeOf(name) end

--- Lua-side wrapper around a [`JpsGrid`].
---@class LJpsGrid
LJpsGrid = {}

--- Find a JPS path between two cells (1-based coordinates).
---@param fx any
---@param fy any
---@param tx any
---@param ty any
function LJpsGrid:findPath(fx, fy, tx, ty) end

--- Returns true if the cell is blocked (1-based coordinates).
---@param x any
---@param y any
function LJpsGrid:isBlocked(x, y) end

--- Mark/unmark a cell as blocked (1-based coordinates).
---@param x any
---@param y any
---@param blocked any
function LJpsGrid:setBlocked(x, y, blocked) end

--- Returns the type name of this object.
function LJpsGrid:type() end

--- Returns true if this object is of the given type.
---@param name any
function LJpsGrid:typeOf(name) end

--- Lua-side wrapper around a [`NavGrid`] with optional HPA★ abstract graph.
---@class LNavGrid
LNavGrid = {}

--- Clears all pending dirty rectangles.
function LNavGrid:clearDirty() end

--- Sets every cell to the given cost.
---@param cost any
function LNavGrid:fill(cost) end

--- Sets all cells in a rectangle to the given cost (1-based coordinates).
---@param x any
---@param y any
---@param w any
---@param h any
---@param cost any
function LNavGrid:fillRect(x, y, w, h, cost) end

--- Returns the current HPA★ chunk size.
function LNavGrid:getChunkSize() end

--- Returns the traversal cost of a cell (1-based coordinates).
---@param x any
---@param y any
function LNavGrid:getCost(x, y) end

--- Returns the current diagonal movement mode as a string.
function LNavGrid:getDiagonalMode() end

--- Returns the grid dimensions as width, height.
function LNavGrid:getDimensions() end

--- Returns the grid height in cells.
function LNavGrid:getHeight() end

--- Returns the grid width in cells.
function LNavGrid:getWidth() end

--- Returns true if the cell is blocked (1-based coordinates).
---@param x any
---@param y any
function LNavGrid:isBlocked(x, y) end

--- Returns true if a unit footprint is fully walkable (1-based coordinates).
---@param x any
---@param y any
---@param unit_size? any
function LNavGrid:isWalkable(x, y, unit_size) end

--- Overwrites the grid from a raw byte string (row-major, one byte per cell).
---@param data any
function LNavGrid:loadFromString(data) end

--- Rebuilds the HPA★ abstract graph from the current grid state.
function LNavGrid:rebuildAbstract() end

--- Exports the cost grid as a byte string (row-major, one byte per cell).
function LNavGrid:saveToString() end

--- Marks a cell as blocked or unblocked (1-based coordinates).
---@param x any
---@param y any
---@param blocked any
function LNavGrid:setBlocked(x, y, blocked) end

--- Sets the HPA★ chunk size.
---@param size any
function LNavGrid:setChunkSize(size) end

--- Sets the traversal cost of a cell (1-based coordinates).
---@param x any
---@param y any
---@param cost any
function LNavGrid:setCost(x, y, cost) end

--- Sets the diagonal movement mode.
---@param mode any
function LNavGrid:setDiagonalMode(mode) end

--- Records a dirty rectangle for incremental HPA★ updates (1-based coordinates).
---@param x any
---@param y any
---@param w any
---@param h any
function LNavGrid:setDirty(x, y, w, h) end

--- Returns the type name of this object.
function LNavGrid:type() end

--- Returns true if this object is of the given type.
---@param name any
function LNavGrid:typeOf(name) end

--- Lua-side wrapper around a [`PathGrid`] (A★ weighted grid with per-cell cost).
---@class LPathGrid
LPathGrid = {}

--- Finds an A★ path returning world-space waypoints (1-based coordinates).
---@param sx any
---@param sy any
---@param gx any
---@param gy any
function LPathGrid:findPath(sx, sy, gx, gy) end

--- Finds a smoothed A★ path with string-pulling (1-based coordinates).
---@param sx any
---@param sy any
---@param gx any
---@param gy any
function LPathGrid:findPathSmoothed(sx, sy, gx, gy) end

--- Returns the world-space size of each cell.
function LPathGrid:getCellSize() end

--- Returns the cost multiplier for a cell (1-based coordinates).
---@param x any
---@param y any
function LPathGrid:getCost(x, y) end

--- Returns the grid height in cells.
function LPathGrid:getHeight() end

--- Returns the grid width in cells.
function LPathGrid:getWidth() end

--- Returns true if a cell is walkable (1-based coordinates).
---@param x any
---@param y any
function LPathGrid:isWalkable(x, y) end

--- Sets the cost multiplier for a cell (1-based coordinates).
---@param x any
---@param y any
---@param cost any
function LPathGrid:setCost(x, y, cost) end

--- Sets the walkability of a cell (1-based coordinates).
---@param x any
---@param y any
---@param w any
function LPathGrid:setWalkable(x, y, w) end

--- Returns the type name of this object.
function LPathGrid:type() end

--- Returns true if this object is of the given type.
---@param name any
function LPathGrid:typeOf(name) end

--- Lua-side wrapper around a [`UnitPathfinder`].
---@class LUnitPathfinder
LUnitPathfinder = {}

--- Removes all cached path results.
function LUnitPathfinder:clearCache() end

--- Finds the nearest walkable cell within a radius (1-based coordinates).
---@param x any
---@param y any
---@param max_radius any
---@param unit_size? any
function LUnitPathfinder:findNearestWalkable(x, y, max_radius, unit_size) end

--- Finds a partial path with a node expansion limit (1-based coordinates).
function LUnitPathfinder:findPartialPath() end

--- Finds an A★ path between two cells (1-based coordinates).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param unit_size? any
function LUnitPathfinder:findPath(x1, y1, x2, y2, unit_size) end

--- Finds a path using bidirectional A★, expanding from start and goal simultaneously
function LUnitPathfinder:findPathBidirectional() end

--- Finds a Theta★ smoothed path between two cells (1-based coordinates).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param unit_size? any
function LUnitPathfinder:findPathSmooth(x1, y1, x2, y2, unit_size) end

--- Returns the number of entries in the path cache.
function LUnitPathfinder:getCacheSize() end

--- Returns the sum of grid traversal costs along a path.
---@param path any
function LUnitPathfinder:getPathCost(path) end

--- Returns the euclidean length of a path table.
---@param path any
function LUnitPathfinder:getPathLength(path) end

--- Returns the octile heuristic distance between two cells (1-based coordinates).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function LUnitPathfinder:heuristicDistance(x1, y1, x2, y2) end

--- Returns true if path result caching is enabled.
function LUnitPathfinder:isCacheEnabled() end

--- Returns true if a path exists between two cells (1-based coordinates).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param unit_size? any
function LUnitPathfinder:isReachable(x1, y1, x2, y2, unit_size) end

--- Returns true if there is a clear line of sight between two cells (1-based coordinates).
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param unit_size? any
function LUnitPathfinder:lineOfSight(x1, y1, x2, y2, unit_size) end

--- Enables or disables path result caching.
---@param enabled any
function LUnitPathfinder:setCacheEnabled(enabled) end

--- Sets the maximum number of cached path entries.
---@param n any
function LUnitPathfinder:setCacheMaxSize(n) end

--- Returns the type name of this object.
function LUnitPathfinder:type() end

--- Returns true if this object is of the given type.
---@param name any
function LUnitPathfinder:typeOf(name) end

--- Returns the background pathfinding thread count (currently always 0).
lurek.pathfind.getThreadCount = function() end

--- Creates a new FlowField backed by a NavGrid.
---@param grid_ud any
lurek.pathfind.newFlowField = function(grid_ud) end

--- Creates a hex grid for pathfinding, LOS, FOV, and range queries.
---@param width any
---@param height any
---@param layout_str? any
lurek.pathfind.newHexGrid = function(width, height, layout_str) end

--- Creates a uniform-cost grid optimised for Jump Point Search (orthogonal + diagonal).
---@param width any
---@param height any
lurek.pathfind.newJpsGrid = function(width, height) end

--- Creates a new NavGrid with all cells walkable.
---@param width any
---@param height any
lurek.pathfind.newNavGrid = function(width, height) end

--- Builds a NavGrid from a TileMap layer, treating specified GIDs as blocked (unwalkable).
---@param tm_ud any
---@param layer_index any
---@param blocked_table any
lurek.pathfind.newNavGridFromTileMap = function(tm_ud, layer_index, blocked_table) end

--- Creates a new BFS flow field from a PathGrid.
---@param grid_ud any
lurek.pathfind.newPathFlowField = function(grid_ud) end

--- Creates a new PathGrid with per-cell cost and walkability.
---@param w any
---@param h any
---@param cell_size any
lurek.pathfind.newPathGrid = function(w, h, cell_size) end

--- Creates a new UnitPathfinder backed by a NavGrid.
---@param grid_ud any
lurek.pathfind.newPathfinder = function(grid_ud) end

--- Computes a Dijkstra range-of-movement map from an origin within a movement budget.
---@param opts any
lurek.pathfind.rangeMap = function(opts) end

--- Sets the background pathfinding thread count (currently a no-op).
---@param count any
lurek.pathfind.setThreadCount = function(count) end

---@class lurek.patterns
lurek.patterns = {}

--- Lua wrapper for the Blackboard pattern.
---@class LBlackboard
LBlackboard = {}

--- Removes a fact from the blackboard.
---@param key any
function LBlackboard:clear(key) end

--- Clears all facts from the blackboard.
function LBlackboard:clearAll() end

--- Gets a fact from the blackboard. Returns nil if not set.
---@param key any
function LBlackboard:get(key) end

--- Returns the monotonic revision counter (incremented on every write).
function LBlackboard:getRevision() end

--- Returns true when the key has a non-nil value.
---@param key any
function LBlackboard:has(key) end

--- Returns all set fact keys as a table.
function LBlackboard:keys() end

--- Sets a fact on the blackboard. Accepts boolean, number, or string values.
---@param key any
---@param value any
function LBlackboard:set(key, value) end

--- Returns all facts as a flat keyâ†’value table.
function LBlackboard:snapshot() end

--- Removes a watcher subscription by id.
---@param id any
function LBlackboard:unwatch(id) end

--- Subscribes to changes on a specific key (or "*" for all changes).
---@param key any
---@param callback any
function LBlackboard:watch(key, callback) end

--- Lua wrapper for the CommandStack pattern.
---@class LCommandStack
LCommandStack = {}

--- Returns true if there is a command available to redo.
function LCommandStack:canRedo() end

--- Returns true if the most recent command can be undone.
function LCommandStack:canUndo() end

--- Clears all command history, releasing Lua registry values.
function LCommandStack:clearAll() end

--- Executes a named command and records it in undo/redo history.
---@param name any
---@param exec_fn any
---@param undo_fn? any
function LCommandStack:execute(name, exec_fn, undo_fn) end

--- Returns the name of the most recently executed command, or nil.
function LCommandStack:getCurrentName() end

--- Returns the total number of recorded commands (undo + redo).
function LCommandStack:getHistorySize() end

--- Re-executes the next undone command. Returns true if successful.
function LCommandStack:redo() end

--- Undoes the most recent command. Returns true if successful.
function LCommandStack:undo() end

--- Lua wrapper for the Debounce pattern.
---@class LDebounce
LDebounce = {}

--- Cancels the pending trigger without firing.
function LDebounce:cancel() end

--- Returns the total number of times this debounce has fired.
function LDebounce:getFireCount() end

--- Returns true when a trigger is pending.
function LDebounce:isPending() end

--- Sets the callback invoked when the debounce fires.
---@param f any
function LDebounce:onFire(f) end

--- Records an input event, resetting the idle timer.
function LDebounce:trigger() end

--- Advances the idle timer by dt seconds; fires the callback if idle wait expired.
---@param dt any
function LDebounce:update(dt) end

--- Lua wrapper for the EventBus pattern.
---@class LEventBus
LEventBus = {}

--- Removes all listeners for a specific event.
---@param event any
function LEventBus:clear(event) end

--- Removes all listeners on this EventBus.
function LEventBus:clearAll() end

--- Dispatches an event, calling all registered listeners in priority order.
---@param ... any
function LEventBus:emit(...) end

--- Returns all event names that have at least one listener.
function LEventBus:getEvents() end

--- Returns the number of listeners registered for an event.
---@param event any
function LEventBus:getListenerCount(event) end

--- Removes a previously registered event listener by subscription ID.
---@param id any
function LEventBus:off(id) end

--- Registers a listener callback for an event.
---@param event any
---@param callback any
---@param priority? any
function LEventBus:on(event, callback, priority) end

--- Lua wrapper for the Factory pattern.
---@class LFactory
LFactory = {}

--- Registers an alias pointing to an existing canonical type name.
---@param alias any
---@param canonical any
function LFactory:alias(alias, canonical) end

--- Removes all registered type constructors and aliases.
function LFactory:clearAll() end

--- Creates an instance of the named type by invoking its constructor.
---@param ... any
function LFactory:create(...) end

--- Returns a table of all registered type names.
function LFactory:getTypes() end

--- Returns true if the named type (or alias) is registered.
---@param type_name any
function LFactory:has(type_name) end

--- Registers a named type constructor function.
---@param type_name any
---@param ctor any
function LFactory:register(type_name, ctor) end

--- Unregisters a type constructor (and any aliases pointing to it).
---@param type_name any
function LFactory:remove(type_name) end

--- Lua wrapper for the Funnel (event aggregator) pattern.
---@class LFunnel
LFunnel = {}

--- Discards all buffered entries without flushing.
function LFunnel:discard() end

--- Manually flushes all pending entries, invoking the onFlush callback.
function LFunnel:flush() end

--- Returns the total number of flushes performed.
function LFunnel:getFlushCount() end

--- Sets a callback invoked when the funnel flushes. Receives a table of {tag, value} entries.
---@param f any
function LFunnel:onFlush(f) end

--- Returns the number of buffered entries not yet flushed.
function LFunnel:pendingCount() end

--- Adds an event to the funnel. Immediately flushes if max_entries reached or window is 0.
---@param tag any
---@param value? any
function LFunnel:push(tag, value) end

--- Advances the window timer by dt seconds; flushes when window expires.
---@param dt any
function LFunnel:update(dt) end

--- Lua wrapper for an ordered, resizable list.
---@class LList
LList = {}

--- Appends a value to the end of the list.
---@param value any
function LList:add(value) end

--- Removes all values from the list.
function LList:clear() end

--- Returns true if the list contains a value equal to the given Lua value (string/number/boolean).
---@param value any
function LList:contains(value) end

--- Returns the value at a 1-based index, or nil.
---@param index any
function LList:get(index) end

--- Returns true if the list is empty.
function LList:isEmpty() end

--- Returns the number of items in the list.
function LList:len() end

--- Removes and returns the value at a 1-based index.
---@param index any
function LList:remove(index) end

--- Replaces the value at a 1-based index.
---@param index any
---@param value any
function LList:set(index, value) end

--- Returns all items as a Lua table.
function LList:toArray() end

--- Lua wrapper for the Mediator pattern.
---@class LMediator
LMediator = {}

--- Dispatches a message to all handlers across all channels.
---@param ... any
function LMediator:broadcast(...) end

--- Returns all registered channel names.
function LMediator:channels() end

--- Removes all channels and handlers.
function LMediator:clear() end

--- Returns the number of handlers on a channel.
---@param channel any
function LMediator:handlerCount(channel) end

--- Unregisters a handler by ID.
---@param channel any
---@param id any
function LMediator:off(channel, id) end

--- Registers a handler callback on a channel; returns handler ID.
---@param channel any
---@param callback any
function LMediator:on(channel, callback) end

--- Removes a channel and all its handlers.
---@param channel any
function LMediator:removeChannel(channel) end

--- Dispatches a message to all handlers on a channel.
---@param ... any
function LMediator:send(...) end

--- Lua wrapper for the ObjectPool pattern.
---@class LObjectPool
LObjectPool = {}

--- Acquires an available object from the pool; returns nil if empty.
function LObjectPool:acquire() end

--- Inserts a pre-built object into the available pool.
---@param value any
function LObjectPool:add(value) end

--- Clears all objects from the pool, releasing Lua registry values.
function LObjectPool:clearAll() end

--- Returns the number of currently active (acquired) objects.
function LObjectPool:getActiveCount() end

--- Returns the number of available (idle) objects in the pool.
function LObjectPool:getAvailableCount() end

--- Returns the total number of tracked objects (active + available).
function LObjectPool:getTotalCount() end

--- Returns an object to the available pool.
---@param value any
function LObjectPool:release(value) end

--- Lua wrapper for the Observer pattern.
---@class LObserver
LObserver = {}

--- Gets a property value, or nil if not set.
---@param key any
function LObserver:get(key) end

--- Returns the total number of active subscriptions.
function LObserver:getCount() end

--- Sets a property value and fires subscribed watchers.
---@param key any
---@param new_val any
function LObserver:set(key, new_val) end

--- Subscribes to changes on a property key (or "*" for all).
---@param key any
---@param callback any
---@param once? any
function LObserver:subscribe(key, callback, once) end

--- Removes a subscription by id.
---@param id any
function LObserver:unsubscribe(id) end

--- Lua wrapper for the PriorityQueue pattern.
---@class LPriorityQueue
LPriorityQueue = {}

--- Removes all items from the queue.
function LPriorityQueue:clearAll() end

--- Returns true when the queue has no items.
function LPriorityQueue:isEmpty() end

--- Returns the number of items in the queue.
function LPriorityQueue:len() end

--- Returns the highest-priority item without removing it, or nil if empty.
function LPriorityQueue:peek() end

--- Removes and returns the highest-priority item, or nil if empty.
function LPriorityQueue:pop() end

--- Inserts an item with a priority. Higher priorities are dequeued first.
---@param priority any
---@param value any
---@param label? any
function LPriorityQueue:push(priority, value, label) end

--- Lua wrapper for a FIFO queue.
---@class LQueue
LQueue = {}

--- Removes all values from the queue.
function LQueue:clear() end

--- Removes and returns the front value, or nil if empty.
function LQueue:dequeue() end

--- Adds a value to the back of the queue. Returns false if capacity is full.
---@param value any
function LQueue:enqueue(value) end

--- Returns the front value without removing it, or nil if empty.
function LQueue:front() end

--- Returns true if the queue is empty.
function LQueue:isEmpty() end

--- Returns true if the queue is at its capacity limit.
function LQueue:isFull() end

--- Returns the number of items in the queue.
function LQueue:len() end

--- Returns all items as a Lua table (front to back).
function LQueue:toArray() end

--- Lua wrapper for the RelationshipManager pattern.
---@class LRelationshipManager
LRelationshipManager = {}

--- Adjusts the numeric relationship value by a delta.
---@param a any
---@param b any
---@param delta any
function LRelationshipManager:adjustValue(a, b, delta) end

--- Defines a relationship type with ordered levels.
---@param name any
---@param levels any
---@param default_level? any
function LRelationshipManager:defineType(name, levels, default_level) end

--- Returns the named level for a typed relationship, or nil.
---@param a any
---@param b any
---@param type_name any
function LRelationshipManager:getLevel(a, b, type_name) end

--- Returns the numeric relationship value between two entities (default 0.0).
---@param a any
---@param b any
function LRelationshipManager:getValue(a, b) end

--- Returns the total number of stored relationship pairs.
function LRelationshipManager:pairCount() end

--- Removes all relationship data between two entities.
---@param a any
---@param b any
function LRelationshipManager:removePair(a, b) end

--- Removes a relationship type definition.
---@param name any
function LRelationshipManager:removeType(name) end

--- Sets a named level for a typed relationship between two entities.
---@param a any
---@param b any
---@param type_name any
---@param level any
function LRelationshipManager:setLevel(a, b, type_name, level) end

--- Sets the numeric relationship value between two entities.
---@param a any
---@param b any
---@param value any
function LRelationshipManager:setValue(a, b, value) end

--- Returns all defined relationship type names.
function LRelationshipManager:typeNames() end

--- Lua wrapper for the Ring (circular buffer) pattern.
---@class LRing
LRing = {}

--- Returns the average of all numeric values, or 0 if empty.
function LRing:average() end

--- Removes all entries from the ring.
function LRing:clear() end

--- Returns true when the ring is at capacity.
function LRing:isFull() end

--- Returns the most recently pushed entry, or nil.
function LRing:latest() end

--- Returns the number of entries currently in the ring.
function LRing:len() end

--- Pushes a value (number or string) with an optional tag. Overwrites oldest on overflow.
---@param value any
---@param tag? any
function LRing:push(value, tag) end

--- Returns the sum of all numeric values in the ring.
function LRing:sum() end

--- Returns all entries (oldest first) as an array of {id, tag, value?, text?} tables.
function LRing:toArray() end

--- Lua wrapper for the ServiceLocator pattern.
---@class LServiceLocator
LServiceLocator = {}

--- Removes all registered services.
function LServiceLocator:clearAll() end

--- Returns a table of all registered service names.
function LServiceLocator:getServices() end

--- Returns true if a service with the given name is registered.
---@param name any
function LServiceLocator:has(name) end

--- Retrieves a registered service by name; returns nil if not found.
---@param name any
function LServiceLocator:locate(name) end

--- Registers a named service with an associated Lua value.
---@param name any
---@param value any
function LServiceLocator:provide(name, value) end

--- Unregisters and removes a named service.
---@param name any
function LServiceLocator:remove(name) end

--- Lua wrapper for an unordered set. Values are keyed by their string representation.
---@class LSet
LSet = {}

--- Adds a string key to the set. Returns true if it was not already present.
---@param key any
function LSet:add(key) end

--- Removes all keys from the set.
function LSet:clear() end

--- Returns true if the key is in the set.
---@param key any
function LSet:has(key) end

--- Returns the intersection of this set and another as a new Set.
---@param other any
function LSet:intersection(other) end

--- Returns true if the set is empty.
function LSet:isEmpty() end

--- Returns the number of distinct keys in the set.
function LSet:len() end

--- Removes a key from the set. Returns true if it was present.
---@param key any
function LSet:remove(key) end

--- Returns all keys as a Lua table (unordered).
function LSet:toArray() end

--- Returns the union of this set and another as a new Set.
---@param other any
function LSet:union(other) end

--- Lua wrapper for the SimpleState finite state machine pattern.
---@class LSimpleState
LSimpleState = {}

--- Registers a named state with optional enter, exit, and update callbacks.
---@param name any
---@param callbacks? any
function LSimpleState:addState(name, callbacks) end

--- Removes all states and callbacks from this state machine.
function LSimpleState:clearAll() end

--- Returns the name of the current state, or nil if none is active.
function LSimpleState:getCurrent() end

--- Returns a table of all registered state names.
function LSimpleState:getStates() end

--- Returns true if a state with the given name is registered.
---@param name any
function LSimpleState:hasState(name) end

--- Transitions to a named state, calling exit/enter callbacks as needed.
---@param name any
function LSimpleState:transitionTo(name) end

--- Calls the update callback of the current state with the given delta time.
---@param dt any
function LSimpleState:update(dt) end

--- Lua wrapper for a LIFO stack.
---@class LStack
LStack = {}

--- Removes all values from the stack.
function LStack:clear() end

--- Returns true if the stack is empty.
function LStack:isEmpty() end

--- Returns true if the stack is at its capacity limit.
function LStack:isFull() end

--- Returns the number of items on the stack.
function LStack:len() end

--- Returns the top value without removing it, or nil if empty.
function LStack:peek() end

--- Removes and returns the top value, or nil if empty.
function LStack:pop() end

--- Pushes a value onto the stack. Returns false if capacity is full.
---@param value any
function LStack:push(value) end

--- Returns all items as a Lua table (bottom to top).
function LStack:toArray() end

--- Lua wrapper for the Strategy pattern.
---@class LStrategy
LStrategy = {}

--- Removes all strategies and clears the active selection.
function LStrategy:clear() end

--- Calls the currently active strategy function with the given arguments.
---@param ... any
function LStrategy:execute(...) end

--- Returns the name of the active strategy, or nil.
function LStrategy:getCurrent() end

--- Returns true if a strategy with this name is registered.
---@param name any
function LStrategy:has(name) end

--- Returns all registered strategy names.
function LStrategy:names() end

--- Registers a named strategy function.
---@param name any
---@param callback any
function LStrategy:register(name, callback) end

--- Removes a strategy by name.
---@param name any
function LStrategy:remove(name) end

--- Sets the active strategy by name. Returns false if not registered.
---@param name any
function LStrategy:set(name) end

--- Lua wrapper for the Throttle pattern.
---@class LThrottle
LThrottle = {}

--- Returns the total number of times this throttle has fired.
function LThrottle:getFireCount() end

--- Returns the normalised progress through the current interval [0, 1].
function LThrottle:getProgress() end

--- Sets the callback invoked when the throttle fires.
---@param f any
function LThrottle:onFire(f) end

--- Resets the elapsed counter without firing.
function LThrottle:reset() end

--- Enables or disables the throttle.
---@param v any
function LThrottle:setEnabled(v) end

--- Advances the timer by dt seconds; fires the callback if the interval elapsed.
---@param dt any
function LThrottle:update(dt) end

--- Creates a new Blackboard shared key-value store.
---@param name? any
lurek.patterns.newBlackboard = function(name) end

--- Creates a new CommandStack instance.
---@param max_size? any
lurek.patterns.newCommandStack = function(max_size) end

--- Creates a trailing-edge debounce that fires after the input stream is idle for wait seconds.
---@param wait any
lurek.patterns.newDebounce = function(wait) end

--- Creates a new EventBus instance.
---@param name? any
lurek.patterns.newEventBus = function(name) end

--- Creates a new Factory instance.
lurek.patterns.newFactory = function() end

--- Creates a time-windowed event aggregator. window=0 means flush on every push.
---@param window any
---@param max_entries? any
---@param name? any
lurek.patterns.newFunnel = function(window, max_entries, name) end

--- Creates an ordered, resizable list.
lurek.patterns.newList = function() end

--- Creates a new named-channel message broker.
lurek.patterns.newMediator = function() end

--- Creates a new ObjectPool instance.
lurek.patterns.newObjectPool = function() end

--- Creates a new reactive property Observer.
---@param name? any
lurek.patterns.newObserver = function(name) end

--- Creates a stable priority-ordered task queue.
---@param name? any
lurek.patterns.newPriorityQueue = function(name) end

--- Creates a FIFO queue. capacity=0 means unlimited.
---@param capacity? any
lurek.patterns.newQueue = function(capacity) end

--- Creates a new entity relationship manager.
lurek.patterns.newRelationshipManager = function() end

--- Creates a fixed-capacity circular history buffer.
---@param capacity any
---@param name? any
lurek.patterns.newRing = function(capacity, name) end

--- Creates a new ServiceLocator instance.
lurek.patterns.newServiceLocator = function() end

--- Creates an unordered set that rejects duplicate values (by string key).
lurek.patterns.newSet = function() end

--- Creates a new SimpleState finite state machine instance.
lurek.patterns.newSimpleState = function() end

--- Creates a LIFO stack. capacity=0 means unlimited.
---@param capacity? any
lurek.patterns.newStack = function(capacity) end

--- Creates a new strategy registry.
lurek.patterns.newStrategy = function() end

--- Creates a leading-edge rate limiter that fires at most once per interval seconds.
---@param interval any
lurek.patterns.newThrottle = function(interval) end

---@class lurek.physics
---@field CELL_AIR integer  empty air cell (0)
---@field CELL_SAND integer  sand cell (1)
---@field CELL_WATER integer  water cell (2)
---@field CELL_ROCK integer  rock cell (3)
---@field CELL_FIRE integer  fire cell (4)
---@field CELL_GAS integer  gas cell (5)
lurek.physics = {}

--- Lua-side handle to a physics body accessed through its world.
---@class LBody
LBody = {}

--- Applies an angular impulse.
---@param impulse any
function LBody:applyAngularImpulse(impulse) end

--- Applies a continuous force to the body.
---@param fx any
---@param fy any
function LBody:applyForce(fx, fy) end

--- Applies a force at a specific world-space point.
---@param fx any
---@param fy any
---@param px any
---@param py any
function LBody:applyForceAtPoint(fx, fy, px, py) end

--- Applies a linear impulse to the body.
---@param ix any
---@param iy any
function LBody:applyImpulse(ix, iy) end

--- Applies a torque (rotational force).
---@param torque any
function LBody:applyTorque(torque) end

--- Removes this body from the world.
function LBody:destroy() end

--- Returns the body angle in radians.
function LBody:getAngle() end

--- Returns the angular damping coefficient.
function LBody:getAngularDamping() end

--- Returns the angular velocity in radians/s.
function LBody:getAngularVelocity() end

--- Returns the body friction coefficient.
function LBody:getFriction() end

--- Returns the per-body gravity multiplier.
function LBody:getGravityScale() end

--- Returns the height of this body's primary collider shape in world units.
function LBody:getHeight() end

--- Returns the body's integer ID.
function LBody:getId() end

--- Returns the collision layer bitmask.
function LBody:getLayer() end

--- Returns the linear damping coefficient.
function LBody:getLinearDamping() end

--- Returns the collision mask bitmask.
function LBody:getMask() end

--- Returns the body mass in kilograms used for force and impulse calculations.
function LBody:getMass() end

--- Returns the body position (x, y).
function LBody:getPosition() end

--- Returns the body restitution (bounciness).
function LBody:getRestitution() end

--- Returns the body type as a string.
function LBody:getType() end

--- Returns the body velocity (vx, vy).
function LBody:getVelocity() end

--- Returns the width of this body's primary collider shape in world units.
function LBody:getWidth() end

--- Returns the body X position.
function LBody:getX() end

--- Returns the body Y position.
function LBody:getY() end

--- Returns whether CCD is enabled.
function LBody:isBullet() end

--- Returns whether rotation is locked.
function LBody:isFixedRotation() end

--- Returns true if this body is currently sleeping (inactive).
function LBody:isSleeping() end

--- Returns whether the body can sleep.
function LBody:isSleepingAllowed() end

--- Sets the body angle in radians.
---@param angle any
function LBody:setAngle(angle) end

--- Sets the angular damping coefficient.
---@param damping any
function LBody:setAngularDamping(damping) end

--- Sets the angular velocity.
---@param omega any
function LBody:setAngularVelocity(omega) end

--- Enables or disables continuous collision detection (CCD) for fast-moving bodies.
---@param bullet any
function LBody:setBullet(bullet) end

--- Locks or unlocks rotation.
---@param fixed any
function LBody:setFixedRotation(fixed) end

--- Sets the body friction coefficient.
---@param friction any
function LBody:setFriction(friction) end

--- Sets the per-body gravity multiplier.
---@param scale any
function LBody:setGravityScale(scale) end

--- Sets the collision layer bitmask.
---@param layer any
function LBody:setLayer(layer) end

--- Sets the linear damping coefficient.
---@param damping any
function LBody:setLinearDamping(damping) end

--- Sets the collision mask bitmask.
---@param mask any
function LBody:setMask(mask) end

--- Sets the body mass; affects how forces and impulses change velocity.
---@param mass any
function LBody:setMass(mass) end

--- Teleports the body to the given world-space position, bypassing collision.
---@param x any
---@param y any
function LBody:setPosition(x, y) end

--- Sets the body restitution (bounciness).
---@param restitution any
function LBody:setRestitution(restitution) end

--- Sets whether the body can sleep.
---@param allowed any
function LBody:setSleepingAllowed(allowed) end

--- Changes the body type: `"dynamic"`, `"static"`, or `"kinematic"`.
---@param bt any
function LBody:setType(bt) end

--- Sets the body's linear velocity in world units per second.
---@param vx any
---@param vy any
function LBody:setVelocity(vx, vy) end

--- Puts this body to sleep immediately.
function LBody:sleep() end

--- Returns the type name of this object.
function LBody:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBody:typeOf(name) end

--- Forcibly wakes up this body.
function LBody:wakeUp() end

--- Lua-side handle to a falling-sand [`CellularWorld`].
---@class LCellular
LCellular = {}

--- Counts cells of the given material type.
---@param t any
function LCellular:countCells(t) end

--- Fills a circle of cells with the given material.
---@param cx any
---@param cy any
---@param r any
---@param t any
function LCellular:fillCircle(cx, cy, r, t) end

--- Fills a rectangular region of cells with the given material.
---@param cx0 any
---@param cy0 any
---@param cw any
---@param ch any
---@param t any
function LCellular:fillRect(cx0, cy0, cw, ch, t) end

--- Returns positions of all cells of the given material as an array of `{x, y}` tables.
---@param t any
function LCellular:findCells(t) end

--- Returns the material at `(cx, cy)` as an integer constant.
---@param cx any
---@param cy any
function LCellular:getCell(cx, cy) end

--- Loads grid data from bytes produced by `toBytes`.
---@param data any
function LCellular:loadFromBytes(data) end

--- Sets the material of a cell.
---@param cx any
---@param cy any
---@param t any
function LCellular:setCell(cx, cy, t) end

--- Advances the simulation by one tick.
function LCellular:step() end

--- Advances the simulation by `n` ticks.
---@param n any
function LCellular:stepN(n) end

--- Serialises the grid to a byte string.
function LCellular:toBytes() end

--- Returns the full grid as an RGBA byte string using the default colour palette.
function LCellular:toImageData() end

--- Returns a sub-region as an RGBA byte string.
---@param cx0 any
---@param cy0 any
---@param cw any
---@param ch any
function LCellular:toImageDataRegion(cx0, cy0, cw, ch) end

--- Returns the type name of this object.
function LCellular:type() end

--- Returns true if this object is of the given type.
---@param name any
function LCellular:typeOf(name) end

--- Lua-side standalone shape object (circle, rectangle, edge, polygon, chain).
---@class LPhysicsShape
LPhysicsShape = {}

--- Releases this shape handle (GC handles cleanup).
function LPhysicsShape:destroy() end

--- Returns the axis-aligned bounding box (x1, y1, x2, y2).
function LPhysicsShape:getBoundingBox() end

--- Returns the radius. Only valid for circle shapes.
function LPhysicsShape:getRadius() end

--- Returns the shape type string: "circle", "rectangle", "polygon", "edge", or "chain".
function LPhysicsShape:getType() end

--- Sets the density for this shape (used when attaching to a body).
---@param density any
function LPhysicsShape:setDensity(density) end

--- Sets the friction coefficient.
---@param friction any
function LPhysicsShape:setFriction(friction) end

--- Sets the restitution (bounciness) coefficient.
---@param restitution any
function LPhysicsShape:setRestitution(restitution) end

--- Sets whether this shape is a sensor (non-colliding trigger).
---@param sensor any
function LPhysicsShape:setSensor(sensor) end

--- Returns the type name of this object.
function LPhysicsShape:type() end

--- Returns true if this object is of the given type.
---@param name any
function LPhysicsShape:typeOf(name) end

--- Lua-side handle to a destructible [`TerrainMap`].
---@class LTerrain
LTerrain = {}

--- Removes unsupported cells, returning the number of cells that fell.
function LTerrain:collapseColumns() end

--- Sets every cell in the grid to `solid`.
---@param solid any
function LTerrain:fillAll(solid) end

--- Fills a circle of cells centred at world position `(wx, wy)`.
---@param wx any
---@param wy any
---@param radius any
---@param solid any
function LTerrain:fillCircle(wx, wy, radius, solid) end

--- Fills a rectangular region of cells.
---@param wx any
---@param wy any
---@param w any
---@param h any
---@param solid any
function LTerrain:fillRect(wx, wy, w, h, solid) end

--- Rebuilds physics bodies for all dirty chunks.
function LTerrain:flush() end

--- Returns whether a cell is solid.
---@param cx any
---@param cy any
function LTerrain:getCell(cx, cy) end

--- Returns `true` when at least one chunk needs flushing.
function LTerrain:isDirty() end

--- Loads terrain cell data from bytes produced by `toBytes`.
---@param data any
function LTerrain:loadFromBytes(data) end

--- Sets a single terrain cell to solid or empty.
---@param cx any
---@param cy any
---@param solid any
function LTerrain:setCell(cx, cy, solid) end

--- Returns the world-space centres of all solid cells as an array of `{x, y}` tables.
function LTerrain:solidPositions() end

--- Spawns dynamic debris bodies at the given positions.
---@param positions any
---@param mass any
---@param restitution any
function LTerrain:spawnDebris(positions, mass, restitution) end

--- Serialises the terrain grid to a byte string for save/load.
function LTerrain:toBytes() end

--- Returns the terrain as an RGBA byte string.
---@param sr any
---@param sg any
---@param sb any
---@param er any
---@param eg any
---@param eb any
function LTerrain:toImageData(sr, sg, sb, er, eg, eb) end

--- Returns the type name of this object.
function LTerrain:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTerrain:typeOf(name) end

--- Lua-side handle wrapping a physics World.
---@class LWorld
LWorld = {}

--- Creates a distance joint between two bodies.
---@param a any
---@param b any
---@param ax1 any
---@param ay1 any
---@param ax2 any
---@param ay2 any
---@param len any
function LWorld:addDistanceJoint(a, b, ax1, ay1, ax2, ay2, len) end

--- Adds an extra fixture (collider) to a body.
function LWorld:addFixture() end

--- Creates a friction joint that resists relative motion.
---@param a any
---@param b any
---@param ax any
---@param ay any
---@param max_f any
---@param max_t any
function LWorld:addFrictionJoint(a, b, ax, ay, max_f, max_t) end

--- Creates a gear joint (stub — falls back to weld joint).
---@param a any
---@param b any
---@param ax any
---@param ay any
function LWorld:addGearJoint(a, b, ax, ay) end

--- Creates a motor joint that drives body_b toward body_a.
---@param a any
---@param b any
---@param factor any
function LWorld:addMotorJoint(a, b, factor) end

--- Creates a mouse joint connecting a body to a target point.
---@param body_id any
---@param tx any
---@param ty any
---@param max_f any
function LWorld:addMouseJoint(body_id, tx, ty, max_f) end

--- Creates a prismatic (slider) joint between two bodies.
---@param a any
---@param b any
---@param ax any
---@param ay any
---@param axis_x any
---@param axis_y any
function LWorld:addPrismaticJoint(a, b, ax, ay, axis_x, axis_y) end

--- Creates a pulley joint (stub — falls back to weld joint).
---@param a any
---@param b any
---@param ax any
---@param ay any
function LWorld:addPulleyJoint(a, b, ax, ay) end

--- Creates a revolute (pin) joint between two bodies.
---@param a any
---@param b any
---@param ax any
---@param ay any
function LWorld:addRevoluteJoint(a, b, ax, ay) end

--- Creates a rope joint with a maximum distance.
---@param a any
---@param b any
---@param ax1 any
---@param ay1 any
---@param ax2 any
---@param ay2 any
---@param max any
function LWorld:addRopeJoint(a, b, ax1, ay1, ax2, ay2, max) end

--- Creates a weld (rigid) joint between two bodies.
---@param a any
---@param b any
---@param ax any
---@param ay any
function LWorld:addWeldJoint(a, b, ax, ay) end

--- Creates a wheel joint (prismatic + rotation).
---@param a any
---@param b any
---@param ax any
---@param ay any
---@param axis_x any
---@param axis_y any
function LWorld:addWheelJoint(a, b, ax, ay, axis_x, axis_y) end

--- Creates a rectangular gravity/damping zone and returns a LuaZone handle.
---@param x any
---@param y any
---@param w any
---@param h any
function LWorld:addZone(x, y, w, h) end

--- Resets the world, removing all bodies and joints.
function LWorld:clear() end

--- Removes the begin-contact callback.
function LWorld:clearBeginContact() end

--- Removes the Lua data attached to a body.
---@param id any
function LWorld:clearBodyData(id) end

--- Removes the one-way platform flag from a body.
---@param id any
function LWorld:clearBodyOneWay(id) end

--- Removes the end-contact callback.
function LWorld:clearEndContact() end

--- Removes a body from the world.
---@param id any
function LWorld:destroyBody(id) end

--- Removes a joint from the world.
---@param jid any
function LWorld:destroyJoint(jid) end

--- Draws physics objects for debugging
function LWorld:drawDebug() end

--- Returns the number of fixtures on a body.
---@param body_id any
function LWorld:fixtureCount(body_id) end

--- Returns begin-contact events from the last step.
function LWorld:getBeginContactEvents() end

--- Returns the body ID at a world-space point, or nil.
---@param x any
---@param y any
function LWorld:getBodyAtPoint(x, y) end

--- Returns whether CCD is enabled for a body.
---@param id any
function LWorld:getBodyCCD(id) end

--- Returns contacts involving a specific body.
---@param body_id any
function LWorld:getBodyContacts(body_id) end

--- Returns the total number of bodies in the world.
function LWorld:getBodyCount() end

--- Returns the Lua data previously attached to a body, or nil if none is set.
---@param id any
function LWorld:getBodyData(id) end

--- Returns all body IDs in the world.
function LWorld:getBodyIds() end

--- Returns the one-way normal for a body, or nil if not configured.
---@param id any
function LWorld:getBodyOneWay(id) end

--- Returns the body type as a string.
---@param id any
function LWorld:getBodyType(id) end

--- Returns collision events from the last step.
function LWorld:getCollisionEvents() end

--- Returns all contact pairs from the narrow phase.
function LWorld:getContacts() end

--- Returns end-contact events from the last step.
function LWorld:getEndContactEvents() end

--- Returns the gravity vector (gx, gy).
function LWorld:getGravity() end

--- Returns the two body IDs connected by a joint.
---@param jid any
function LWorld:getJointBodies(jid) end

--- Returns the break threshold for a joint, or nil if not set.
---@param jid any
function LWorld:getJointBreakForce(jid) end

--- Returns a table of integer IDs for every joint attached to this world.
function LWorld:getJointIds() end

--- Returns the angular limits on a joint.
---@param jid any
function LWorld:getJointLimits(jid) end

--- Returns the motor speed on a joint's angular axis.
---@param jid any
function LWorld:getJointMotorSpeed(jid) end

--- Returns the type name of a joint.
---@param jid any
function LWorld:getJointType(jid) end

--- Returns the pixels-per-meter scaling factor.
function LWorld:getMeter() end

--- Returns the current number of solver iterations per step.
function LWorld:getSolverIterations() end

--- Returns zone enter/leave events produced by the most recent step.
function LWorld:getZoneEvents() end

--- Returns true if a body is currently sleeping (inactive).
---@param id any
function LWorld:isBodySleeping(id) end

--- Returns the total number of joints.
function LWorld:jointCount() end

--- Creates multiple bodies in one call.
---@param specs any
function LWorld:newBodies(specs) end

--- Creates a new rectangular body and adds it to the world.
---@param x any
---@param y any
---@param bt any
function LWorld:newBody(x, y, bt) end

--- Creates a new chain body from a flat vertex table and adds it to the world.
---@param x any
---@param y any
---@param tbl any
---@param closed any
---@param bt any
function LWorld:newChainBody(x, y, tbl, closed, bt) end

--- Creates a new circular body and adds it to the world.
---@param x any
---@param y any
---@param radius any
---@param bt any
function LWorld:newCircleBody(x, y, radius, bt) end

--- Creates a new edge (line segment) body and adds it to the world.
---@param x any
---@param y any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param bt any
function LWorld:newEdgeBody(x, y, x1, y1, x2, y2, bt) end

--- Creates a new polygon body from a flat vertex table and adds it to the world.
---@param x any
---@param y any
---@param tbl any
---@param bt any
function LWorld:newPolygonBody(x, y, tbl, bt) end

--- Returns body IDs within an axis-aligned bounding box.
---@param x any
---@param y any
---@param w any
---@param h any
function LWorld:queryAABB(x, y, w, h) end

--- Casts a ray and returns the nearest hit, or nil.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function LWorld:raycast(x1, y1, x2, y2) end

--- Casts a ray and returns all hits.
---@param x1 any
---@param y1 any
---@param dx any
---@param dy any
---@param max_dist any
function LWorld:raycastAll(x1, y1, dx, dy, max_dist) end

--- Casts a ray and returns the closest hit using the query pipeline.
---@param x1 any
---@param y1 any
---@param dx any
---@param dy any
---@param max_dist any
function LWorld:raycastClosest(x1, y1, dx, dy, max_dist) end

--- Registers a Lua function called with (bodyIdA, bodyIdB) when two
---@param f any
function LWorld:setBeginContact(f) end

--- Enables or disables Continuous Collision Detection for a body.
---@param id any
---@param enabled any
function LWorld:setBodyCCD(id, enabled) end

--- Attaches arbitrary Lua data to a body for retrieval in collision callbacks.
---@param id any
---@param value any
function LWorld:setBodyData(id, value) end

--- Marks a body as a one-way platform.  Bodies approaching from the
---@param id any
---@param nx any
---@param ny any
function LWorld:setBodyOneWay(id, nx, ny) end

--- Changes the simulation type of the body: `"dynamic"`, `"static"`, or `"kinematic"`.
---@param id any
---@param bt any
function LWorld:setBodyType(id, bt) end

--- Registers a Lua function called with (bodyIdA, bodyIdB) when two
---@param f any
function LWorld:setEndContact(f) end

--- Sets friction on a fixture by index.
---@param body_id any
---@param fix_idx any
---@param friction any
function LWorld:setFixtureFriction(body_id, fix_idx, friction) end

--- Sets restitution on a fixture by index.
---@param body_id any
---@param fix_idx any
---@param restitution any
function LWorld:setFixtureRestitution(body_id, fix_idx, restitution) end

--- Sets whether a fixture is a sensor.
---@param body_id any
---@param fix_idx any
---@param sensor any
function LWorld:setFixtureSensor(body_id, fix_idx, sensor) end

--- Sets the world gravity vector; default is `(0, 9.81)` (downward).
---@param gx any
---@param gy any
function LWorld:setGravity(gx, gy) end

--- Sets the relative-velocity threshold above which a joint breaks.
---@param jid any
---@param f any
function LWorld:setJointBreakForce(jid, f) end

--- Sets the angular limits on a joint.
---@param jid any
---@param lower any
---@param upper any
function LWorld:setJointLimits(jid, lower, upper) end

--- Enables or disables angular limits on a joint.
---@param jid any
---@param enabled any
function LWorld:setJointLimitsEnabled(jid, enabled) end

--- Sets the motor speed on a joint's angular axis.
---@param jid any
---@param speed any
function LWorld:setJointMotorSpeed(jid, speed) end

--- Sets the pixels-per-meter scaling factor.
---@param ppm any
function LWorld:setMeter(ppm) end

--- Updates the target position of a mouse joint.
---@param jid any
---@param x any
---@param y any
function LWorld:setMouseJointTarget(jid, x, y) end

--- Sets the number of constraint solver iterations per step.
---@param n any
function LWorld:setSolverIterations(n) end

--- Puts a body to sleep immediately.
---@param id any
function LWorld:sleepBody(id) end

--- Advances the physics simulation by dt seconds, firing onBeginContact /
---@param dt any
function LWorld:step(dt) end

--- Steps the world using a fixed sub-step size to consume accumulated time.
---@param accum any
---@param step_dt any
---@param max_steps any
function LWorld:stepFixed(accum, step_dt, max_steps) end

--- Converts a pixel value to physics units.
---@param px any
function LWorld:toPhysics(px) end

--- Converts a physics-unit value to pixels.
---@param m any
function LWorld:toPixels(m) end

--- Returns the type name of this object.
function LWorld:type() end

--- Returns true if this object is of the given type.
---@param name any
function LWorld:typeOf(name) end

--- Forcibly wakes up a sleeping body.
---@param id any
function LWorld:wakeUpBody(id) end

--- Lua-side handle to a [`PhysicsZone`] living inside a [`World`].
---@class LZone
LZone = {}

--- Removes the zone from the world.
function LZone:destroy() end

--- Returns the zone's integer ID.
function LZone:getId() end

--- Sets an optional angular damping override for bodies inside the zone.
---@param value? any
function LZone:setAngularDampingOverride(value) end

--- Replaces the zone boundary with a circle.
---@param cx any
---@param cy any
---@param radius any
function LZone:setCircle(cx, cy, radius) end

--- Enables or disables the zone.
---@param enabled any
function LZone:setEnabled(enabled) end

--- Sets directional gravity inside the zone.
---@param gx any
---@param gy any
function LZone:setGravityDirectional(gx, gy) end

--- Sets point-attractor gravity inside the zone.
---@param cx any
---@param cy any
---@param strength any
function LZone:setGravityPoint(cx, cy, strength) end

--- Sets point-repulsor gravity inside the zone.
---@param cx any
---@param cy any
---@param strength any
function LZone:setGravityRepulsor(cx, cy, strength) end

--- Suppresses gravity inside the zone (zero-g pocket).
function LZone:setGravityZero() end

--- Sets the layer bitmask; only bodies whose `layer & mask != 0` are affected.
---@param mask any
function LZone:setLayerMask(mask) end

--- Sets an optional linear damping override for bodies inside the zone.
---@param value? any
function LZone:setLinearDampingOverride(value) end

--- Sets the zone priority; higher values win over lower when zones overlap.
---@param priority any
function LZone:setPriority(priority) end

--- Returns the type name of this object.
function LZone:type() end

--- Returns true if this object is of the given type.
---@param name any
function LZone:typeOf(name) end

--- Attaches a standalone shape to a body as an additional fixture.
---@param body_ud any
---@param shape_ud any
lurek.physics.attachShape = function(body_ud, shape_ud) end

--- Enables or disables the physics debug overlay (AABB boxes and velocity vectors).
---@param enable any
lurek.physics.debugDraw = function(enable) end

--- Marks a physics world for destruction. Subsequent operations on the world
---@param world_ud any
lurek.physics.destroyWorld = function(world_ud) end

--- Extracts collider geometry from a World and queues a GPU physics debug
---@param world_ud any
---@param config_val any
lurek.physics.drawDebugGpu = function(world_ud, config_val) end

--- Returns the position and velocity of a body (x, y, vx, vy).
---@param world_ud any
---@param body_ud any
lurek.physics.getBody = function(world_ud, body_ud) end

--- Returns all collision events from the last simulation step.
---@param world_ud any
lurek.physics.getCollisions = function(world_ud) end

--- Returns whether the body is allowed to sleep.
---@param world_ud any
---@param body_ud any
lurek.physics.isSleepingAllowed = function(world_ud, body_ud) end

--- Creates a new rectangular body in the given world.
---@param world_ud any
---@param x any
---@param y any
---@param bt any
lurek.physics.newBody = function(world_ud, x, y, bt) end

--- Creates a falling-sand cellular automaton grid.
---@param width any
---@param height any
lurek.physics.newCellular = function(width, height) end

--- Creates a chain shape userdata from flat variadic vertex pairs.
---@param closed any
---@param coords any
lurek.physics.newChainShape = function(closed, coords) end

--- Creates a circle shape userdata.
---@param r any
lurek.physics.newCircleShape = function(r) end

--- Creates an edge (line segment) shape userdata.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
lurek.physics.newEdgeShape = function(x1, y1, x2, y2) end

--- Creates a convex polygon shape userdata from flat variadic vertex pairs.
lurek.physics.newPolygonShape = function() end

--- Creates a rectangle shape userdata.
---@param w any
---@param h any
lurek.physics.newRectangleShape = function(w, h) end

--- Creates a destructible terrain grid.
---@param width any
---@param height any
---@param cell_size any
---@param world_ud any
lurek.physics.newTerrain = function(width, height, cell_size, world_ud) end

--- Creates a new physics world with the given gravity vector.
---@param gx any
---@param gy any
lurek.physics.newWorld = function(gx, gy) end

--- Sets the velocity of a body.
---@param world_ud any
---@param body_ud any
---@param vx any
---@param vy any
lurek.physics.setBodyVelocity = function(world_ud, body_ud, vx, vy) end

--- Sets whether the body is allowed to sleep.
---@param world_ud any
---@param body_ud any
---@param allowed any
lurek.physics.setSleepingAllowed = function(world_ud, body_ud, allowed) end

--- Advances the physics world by dt seconds.
---@param world_ud any
---@param dt any
lurek.physics.step = function(world_ud, dt) end

--- Returns true when two axis-aligned bounding boxes overlap.
---@param ax any
---@param ay any
---@param aw any
---@param ah any
---@param bx any
---@param by any
---@param bw any
---@param bh any
lurek.physics.testAABB = function(ax, ay, aw, ah, bx, by, bw, bh) end

--- Returns true when a circle overlaps an AABB.
---@param cx any
---@param cy any
---@param cr any
---@param ax any
---@param ay any
---@param aw any
---@param ah any
lurek.physics.testCircleAABB = function(cx, cy, cr, ax, ay, aw, ah) end

--- Returns true when two circles overlap.
---@param ax any
---@param ay any
---@param ar any
---@param bx any
---@param by any
---@param br any
lurek.physics.testCircles = function(ax, ay, ar, bx, by, br) end

--- Returns true when point (px, py) lies inside the AABB.
---@param px any
---@param py any
---@param ax any
---@param ay any
---@param aw any
---@param ah any
lurek.physics.testPoint = function(px, py, ax, ay, aw, ah) end

---@class lurek.pipeline
lurek.pipeline = {}

--- Lua-side wrapper around a [`Pipeline`] DAG with scheduler and Lua callback registry.
---@class LPipeline
LPipeline = {}

--- Adds a step with a runtime condition guard: the step is skipped when `when_fn()` returns false.
---@param name any
---@param deps_tbl any
---@param cb any
---@param cond any
function LPipeline:addConditional(name, deps_tbl, cb, cond) end

--- Adds a step to the pipeline. Returns self for chaining.
---@param step_ud any
function LPipeline:addStep(step_ud) end

--- Inlines all steps from `sub_pipeline` into this pipeline, prefixing
---@param sub_ud any
---@param alias any
---@param deps_tbl? any
function LPipeline:addSubPipeline(sub_ud, alias, deps_tbl) end

--- Cancels all pending and waiting steps.
function LPipeline:cancel() end

--- Clears all steps from the pipeline.
function LPipeline:clear() end

--- Returns the stored async context table, or nil.
function LPipeline:getContext() end

--- Returns the current error mode as a string.
function LPipeline:getErrorMode() end

--- Returns the topological execution order as an array of step names.
function LPipeline:getExecutionOrder() end

--- Returns the pipeline's name.
function LPipeline:getName() end

--- Returns parallel execution groups as a nested array of step name arrays.
function LPipeline:getParallelGroups() end

--- Returns the current result table built from step states, or nil.
function LPipeline:getResult() end

--- Returns the LuaStep wrapper for the named step, or nil.
---@param name any
function LPipeline:getStep(name) end

--- Returns the total number of steps.
function LPipeline:getStepCount() end

--- Returns a Lua array of all step wrappers in the pipeline.
function LPipeline:getSteps() end

--- Returns a Lua array of all steps whose tag matches the given string.
---@param tag any
function LPipeline:getStepsByTag(tag) end

--- Returns true if all steps have reached a terminal state.
function LPipeline:isComplete() end

--- Returns true if the pipeline is currently running asynchronously.
function LPipeline:isRunning() end

--- Registers a callback invoked after every step with `(step_name, status)`.
---@param cb any
function LPipeline:onProgress(cb) end

--- Removes a step from the pipeline by name.
---@param name any
function LPipeline:removeStep(name) end

--- Resets all step states and clears the async context.
function LPipeline:reset() end

--- Executes the pipeline synchronously in topological order.
---@param context? any
function LPipeline:run(context) end

--- Starts an async pipeline run. Steps are executed one-per-frame via update(dt).
---@param context? any
function LPipeline:runAsync(context) end

--- Sets the pipeline error mode: "abort" or "continue".
---@param mode any
function LPipeline:setErrorMode(mode) end

--- Sets the pipeline's name.
---@param name any
function LPipeline:setName(name) end

--- Sets the callback to invoke when the pipeline completes.
---@param cb? any
function LPipeline:setOnComplete(cb) end

--- Sets the callback to invoke each time a step completes successfully.
---@param cb? any
function LPipeline:setOnStepComplete(cb) end

--- Sets the callback to invoke each time a step fails.
---@param cb? any
function LPipeline:setOnStepError(cb) end

--- Returns a multi-line ASCII string visualising the pipeline DAG.
function LPipeline:toAscii() end

--- Serialises the pipeline definition to a Lua table (no callbacks).
function LPipeline:toTable() end

--- Returns the type name of this object.
function LPipeline:type() end

--- Returns the type identifier string of this pipeline stage object.
---@param name any
function LPipeline:typeOf(name) end

--- Advances the async pipeline by one tick. Returns true when all steps are done.
---@param dt any
function LPipeline:update(dt) end

--- Validates the pipeline DAG. Returns (ok, error_array).
function LPipeline:validate() end

--- Lua-side wrapper around a single [`PipelineStep`], plus Lua callback registry keys.
---@class LPipelineStep
LPipelineStep = {}

--- Adds a dependency on another step by name or PipelineStep. Returns self for chaining
---@param dep any
function LPipelineStep:dependsOn(dep) end

--- Returns the number of execution attempts so far
function LPipelineStep:getAttempt() end

--- Retrieves a metadata value by key, returning nil if not found
---@param key any
function LPipelineStep:getData(key) end

--- Returns the configured delay in seconds
function LPipelineStep:getDelay() end

--- Returns the list of dependency step names
function LPipelineStep:getDependencies() end

--- Returns the number of declared dependencies
function LPipelineStep:getDependencyCount() end

--- Returns total seconds spent executing this step
function LPipelineStep:getDuration() end

--- Returns the error message from the last failed attempt, or nil
function LPipelineStep:getError() end

--- Returns the unique name of this step
function LPipelineStep:getName() end

--- Returns the configured retry count
function LPipelineStep:getRetryCount() end

--- Returns the current execution status as a string
function LPipelineStep:getStatus() end

--- Returns the tag on this step, or nil if unset
function LPipelineStep:getTag() end

--- Returns the timeout stored in metadata, or 0.0 if unset
function LPipelineStep:getTimeout() end

--- Returns whether this step is marked as optional
function LPipelineStep:isOptional() end

--- Stores a Lua function as the execute callback for this step
---@param cb any
function LPipelineStep:setCallback(cb) end

--- Stores a Lua function (or nil) as the run-condition for this step
---@param cond? any
function LPipelineStep:setCondition(cond) end

--- Stores an arbitrary string value under the given key in step metadata
---@param key any
---@param value any
function LPipelineStep:setData(key, value) end

--- Sets the delay in seconds to wait after dependencies finish
---@param seconds any
function LPipelineStep:setDelay(seconds) end

--- Stores a Lua function (or nil) to call if this step fails
---@param cb? any
function LPipelineStep:setOnError(cb) end

--- Marks whether this step is optional (downstream steps continue on failure)
---@param optional any
function LPipelineStep:setOptional(optional) end

--- Sets the maximum number of retry attempts on failure
---@param count any
function LPipelineStep:setRetryCount(count) end

--- Sets the delay in seconds between retry attempts
---@param seconds any
function LPipelineStep:setRetryDelay(seconds) end

--- Sets the tag on this step for grouping and filtering
---@param tag any
function LPipelineStep:setTag(tag) end

--- Stores a timeout in seconds in the step's metadata
---@param seconds any
function LPipelineStep:setTimeout(seconds) end

--- Returns the type name "PipelineStep"
function LPipelineStep:type() end

--- Returns true when the given name matches "PipelineStep" or a parent type
---@param name any
function LPipelineStep:typeOf(name) end

--- Deserialises a pipeline from a definition table.
---@param def any
lurek.pipeline.fromTable = function(def) end

--- Creates a new empty pipeline with the given name (defaults to "pipeline").
---@param name? any
lurek.pipeline.newPipeline = function(name) end

--- Creates a new pipeline step with the given name and optional callback.
---@param name any
---@param callback? any
lurek.pipeline.newStep = function(name, callback) end

---@class lurek.procgen
lurek.procgen = {}

--- Generates a dungeon using Binary Space Partitioning.
---@param opts? any
lurek.procgen.bspDungeon = function(opts) end

--- Generates a cave-like map using cellular automata.
---@param w any
---@param h any
---@param opts? any
lurek.procgen.cellularAutomata = function(w, h, opts) end

--- BFS flood fill on a flat grid of bytes.
lurek.procgen.floodFill = function() end

--- Generates a single procedural name using a Markov chain.
lurek.procgen.generateName = function() end

--- Generates N procedural names using a Markov chain.
lurek.procgen.generateNames = function() end

--- Generates a heightmap using fractal noise.
---@param opts? any
lurek.procgen.heightmap = function(opts) end

--- Generates an L-system string.
---@param opts any
lurek.procgen.lsystem = function(opts) end

--- Generates L-system line segments for rendering.
---@param opts any
---@param angle_deg? any
---@param step? any
lurek.procgen.lsystemSegments = function(opts, angle_deg, step) end

--- Generates a noise map using the configurable NoiseGenerator.
---@param width any
---@param height any
---@param opts? any
lurek.procgen.noiseMap = function(width, height, opts) end

--- Generates a noise map using rayon parallel processing.
---@param width any
---@param height any
---@param opts? any
lurek.procgen.noiseMapParallel = function(width, height, opts) end

--- Evaluates periodic Perlin noise at a point.
---@param x any
---@param y any
---@param px any
---@param py any
lurek.procgen.perlinNoise = function(x, y, px, py) end

--- Generates Poisson disk sample points using Bridson's algorithm.
---@param w any
---@param h any
---@param min_dist any
---@param max_attempts? any
---@param seed? any
lurek.procgen.poissonDisk = function(w, h, min_dist, max_attempts, seed) end

--- Generates a rooms-and-corridors dungeon.
---@param opts? any
lurek.procgen.roomsDungeon = function(opts) end

--- Returns a single Simplex noise value at the given 2-D coordinate.
---@param x any
---@param y any
lurek.procgen.simplex2d = function(x, y) end

--- Returns a single Simplex noise value at the given 3-D coordinate.
---@param x any
---@param y any
---@param z any
lurek.procgen.simplex3d = function(x, y, z) end

--- Generates a Voronoi diagram for a set of seed points.
---@param w any
---@param h any
---@param pts_tbl any
---@param opts_tbl? any
lurek.procgen.voronoi = function(w, h, pts_tbl, opts_tbl) end

--- Generates a tile grid using Wave Function Collapse.
---@param opts any
lurek.procgen.wfcGenerate = function(opts) end

--- Generates a world graph with scattered regions and edges.
---@param width any
---@param height any
---@param region_count any
---@param seed? any
lurek.procgen.worldGraph = function(width, height, region_count, seed) end

---@class lurek.raycaster
lurek.raycaster = {}

--- Lua-side wrapper around a [`DoorManager`], managing sliding doors in a level.
---@class LDoorManager
LDoorManager = {}

--- Registers a door at grid position (x, y).
---@param x any
---@param y any
---@param dir_str any
---@param speed any
function LDoorManager:addDoor(x, y, dir_str, speed) end

--- Begins closing the door at the given index.
---@param index any
function LDoorManager:closeDoor(index) end

--- Returns the number of registered doors.
function LDoorManager:count() end

--- Returns the state table for door at index, or nil if out of range.
---@param index any
function LDoorManager:getDoor(index) end

--- Begins opening the door at the given index.
---@param index any
function LDoorManager:openDoor(index) end

--- Returns the type string "DoorManager".
function LDoorManager:type() end

--- Returns the type string "DoorManager".
function LDoorManager:typeOf() end

--- Advances all door animations by dt seconds.
---@param dt any
function LDoorManager:update(dt) end

--- Lua-side wrapper around a [`HeightMap`] for variable floor/ceiling heights.
---@class LHeightMap
LHeightMap = {}

--- Returns the ceiling height at (x, y). Returns 1.0 for out-of-bounds.
---@param x any
---@param y any
function LHeightMap:ceilingAt(x, y) end

--- Returns the floor height at (x, y). Returns 0.0 for out-of-bounds.
---@param x any
---@param y any
function LHeightMap:floorAt(x, y) end

--- Sets the ceiling height at (x, y).
---@param x any
---@param y any
---@param h any
function LHeightMap:setCeiling(x, y, h) end

--- Sets the floor height at (x, y).
---@param x any
---@param y any
---@param h any
function LHeightMap:setFloor(x, y, h) end

--- Returns the type string "HeightMap".
function LHeightMap:type() end

--- Returns the type string "HeightMap".
function LHeightMap:typeOf() end

--- Lua-side value wrapper around a raycaster [`PointLight`].
---@class LPointLight
LPointLight = {}

--- Returns the RGB color as three separate values.
function LPointLight:color() end

--- Returns the intensity multiplier.
function LPointLight:intensity() end

--- Returns the illumination radius.
function LPointLight:radius() end

--- Updates all light properties at once.
---@param x any
---@param y any
---@param r any
---@param g any
---@param b any
---@param radius any
---@param intensity any
function LPointLight:set(x, y, r, g, b, radius, intensity) end

--- Returns the type string "PointLight".
function LPointLight:type() end

--- Returns the type string "PointLight".
function LPointLight:typeOf() end

--- Returns the world-space X position.
function LPointLight:x() end

--- Returns the world-space Y position.
function LPointLight:y() end

--- Lua-side wrapper around a [`Raycaster2D`] grid.
---@class LRaycaster
LRaycaster = {}

--- Builds a raycaster scene and stores it in SharedState for GPU rendering.
function LRaycaster:buildScene() end

--- Computes floor (or ceiling) texture UV coordinates for one horizontal screen row.
function LRaycaster:castFloorRow() end

--- Casts a single ray and returns a hit table, or nil if nothing was hit.
---@param ox any
---@param oy any
---@param angle any
---@param max_dist any
function LRaycaster:castRay(ox, oy, angle, max_dist) end

--- Casts a ray collecting up to max_hits wall layers, continuing through
---@param ox any
---@param oy any
---@param angle any
---@param max_dist any
---@param max_hits? any
function LRaycaster:castRayMulti(ox, oy, angle, max_dist, max_hits) end

--- Casts multiple rays across a field of view, returns an array of hit tables.
---@param ox any
---@param oy any
---@param angle any
---@param fov any
---@param count any
---@param max_dist any
function LRaycaster:castRays(ox, oy, angle, fov, count, max_dist) end

--- Casts multiple rays and returns a flat array of 5 floats per ray.
---@param ox any
---@param oy any
---@param angle any
---@param fov any
---@param count any
---@param max_dist any
function LRaycaster:castRaysFlat(ox, oy, angle, fov, count, max_dist) end

--- Renders a mosaic of first-person views from evenly spaced angles to an ImageData.
---@param x any
---@param y any
---@param fov any
---@param max_dist any
---@param num_frames any
---@param fw any
---@param fh any
function LRaycaster:drawCameraSweep(x, y, fov, max_dist, num_frames, fw, fh) end

--- Renders a depth-map column view to an ImageData.
function LRaycaster:drawDepthMap() end

--- Renders a line-of-sight test between two points to an ImageData.
---@param ax any
---@param ay any
---@param bx any
---@param by any
---@param scale any
function LRaycaster:drawLineOfSight(ax, ay, bx, by, scale) end

--- Renders a top-down grid view with player marker to an ImageData.
---@param px any
---@param py any
---@param angle any
---@param scale any
function LRaycaster:drawTopDown(px, py, angle, scale) end

--- Renders a first-person column view to an ImageData.
---@param px any
---@param py any
---@param angle any
---@param fov any
---@param w any
---@param h any
---@param max_dist any
function LRaycaster:drawView(px, py, angle, fov, w, h, max_dist) end

--- Returns the cell value at (x, y).
---@param x any
---@param y any
function LRaycaster:getCell(x, y) end

--- Returns the opacity for a wall tile type. Returns 1.0 if not set.
---@param tile_type any
function LRaycaster:getWallAlpha(tile_type) end

--- Returns the grid height in cells.
function LRaycaster:height() end

--- Returns true when the cell at (x, y) is a wall (value > 0).
---@param x any
---@param y any
function LRaycaster:isBlocked(x, y) end

--- Checks line of sight between two points using DDA traversal.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function LRaycaster:lineOfSight(x1, y1, x2, y2) end

--- Projects a world-space sprite onto screen space.
---@param sx any
---@param sy any
---@param px any
---@param py any
---@param pa any
---@param fov any
---@param screen_w any
function LRaycaster:projectSprite(sx, sy, px, py, pa, fov, screen_w) end

--- Sets the cell value at grid position (x, y).
---@param x any
---@param y any
---@param val any
function LRaycaster:setCell(x, y, val) end

--- Replaces all grid cells from a flat array of values in row-major order.
---@param cells_tbl any
function LRaycaster:setCells(cells_tbl) end

--- Sets the opacity for a wall tile type. Alpha is clamped to [0, 1].
---@param tile_type any
---@param alpha any
function LRaycaster:setWallAlpha(tile_type, alpha) end

--- Returns the type name of this object.
function LRaycaster:type() end

--- Returns true if this object is of the given type.
---@param name any
function LRaycaster:typeOf(name) end

--- Returns the grid width in cells.
function LRaycaster:width() end

--- Lua-side wrapper around a [`SpriteManager`] for batch depth-sorted sprite projection.
---@class LSpriteManager
LSpriteManager = {}

--- Adds a sprite at world position (x, y) and returns its unique id.
---@param x any
---@param y any
---@param texture any
---@param scale? any
function LSpriteManager:add(x, y, texture, scale) end

--- Removes all sprites from the manager.
function LSpriteManager:clear() end

--- Removes the sprite with the given id. No-op if not found.
---@param id any
function LSpriteManager:remove(id) end

--- Moves the sprite with the given id to world (x, y).
---@param id any
---@param x any
---@param y any
function LSpriteManager:setPosition(id, x, y) end

--- Shows or hides the sprite with the given id.
---@param id any
---@param visible any
function LSpriteManager:setVisible(id, visible) end

--- Returns an array of visible sprites sorted back-to-front from camera position.
---@param cam_x any
---@param cam_y any
---@param cam_angle any
function LSpriteManager:sortAndProject(cam_x, cam_y, cam_angle) end

--- Returns the type string "SpriteManager".
function LSpriteManager:type() end

--- Returns the type string "SpriteManager".
function LSpriteManager:typeOf() end

--- Returns distance-based brightness in [0, 1].
---@param distance any
---@param max_distance any
lurek.raycaster.distanceShade = function(distance, max_distance) end

--- Creates a new raycaster grid of the given dimensions.
---@param w any
---@param h any
lurek.raycaster.new = function(w, h) end

--- Creates a new empty door manager.
lurek.raycaster.newDoorManager = function() end

--- Creates a new height map with default floor (0.0) and ceiling (1.0) values.
---@param w any
---@param h any
lurek.raycaster.newHeightMap = function(w, h) end

--- Alias for `new`. Creates a new raycaster grid of the given dimensions.
---@param w any
---@param h any
lurek.raycaster.newMap = function(w, h) end

--- Creates a point light for use in raycaster scene lighting.
---@param x any
---@param y any
---@param r any
---@param g any
---@param b any
---@param radius any
---@param intensity any
lurek.raycaster.newPointLight = function(x, y, r, g, b, radius, intensity) end

--- Creates a new empty batch sprite manager for depth-sorted projection.
lurek.raycaster.newSpriteManager = function() end

--- Projects a wall distance to screen-space drawing parameters.
---@param distance any
---@param fov any
---@param screen_height any
lurek.raycaster.projectColumn = function(distance, fov, screen_height) end

---@class lurek.render
lurek.render = {}

--- Lua-side handle to an off-screen render target stored in SharedState.
---@class LCanvas
LCanvas = {}

--- Returns width and height of this canvas.
function LCanvas:getDimensions() end

--- Returns the height of this canvas in pixels.
function LCanvas:getHeight() end

--- Returns the width of this canvas in pixels.
function LCanvas:getWidth() end

--- Releases GPU framebuffer memory for this canvas.
function LCanvas:release() end

--- Returns the type name of this object.
function LCanvas:type() end

--- Returns the type name of this object.
function LCanvas:typeOf() end

--- Lua-side z-ordered draw queue. Callbacks are sorted by z and called on `flush()`.
---@class LDrawLayer
LDrawLayer = {}

--- Removes all queued callbacks without calling them.
function LDrawLayer:clear() end

--- Sorts and calls all queued callbacks, then empties the queue.
function LDrawLayer:flush() end

--- Returns the number of queued callbacks.
function LDrawLayer:getCount() end

--- Queues a draw callback at the given z-order.
---@param z any
---@param f any
function LDrawLayer:queue(z, f) end

--- Returns the string type identifier of this draw layer (e.g. `'sprite'`).
function LDrawLayer:type() end

--- Returns true if this object is an instance of the given type name.
---@param name any
function LDrawLayer:typeOf(name) end

--- Lua-side handle to a loaded font stored in SharedState.
---@class LFont
LFont = {}

--- Returns the ascent of this font in pixels.
function LFont:getAscent() end

--- Returns the descent of this font in pixels.
function LFont:getDescent() end

--- Returns the line height of this font.
function LFont:getHeight() end

--- Returns the line height multiplier of this font.
function LFont:getLineHeight() end

--- Returns the rendered width of the given text string.
---@param text any
function LFont:getWidth(text) end

--- Wraps text to the given width and returns the lines.
---@param text any
---@param limit any
function LFont:getWrap(text, limit) end

--- Releases this font and frees its atlas memory.
function LFont:release() end

--- Sets the line height multiplier for this font.
---@param height any
function LFont:setLineHeight(height) end

--- Returns the type name of this object.
function LFont:type() end

--- Returns the type name of this object.
function LFont:typeOf() end

--- Lua-side handle to a loaded GPU texture stored in the engine's texture pool.
---@class LImage
LImage = {}

--- Returns width and height of this image.
function LImage:getDimensions() end

--- Returns the height of this image in pixels.
function LImage:getHeight() end

--- Returns the width of this image in pixels.
function LImage:getWidth() end

--- Releases the GPU texture memory for this image.
function LImage:release() end

--- Returns the type name of this object.
function LImage:type() end

--- Returns the type name of this object.
function LImage:typeOf() end

--- Lua-side handle to a loaded texture stored in SharedState.
---@class LImageData
LImageData = {}

--- Blits the source ImageData onto this image at (dst_x, dst_y) using Porter-Duff `over`.
---@param src_ud any
---@param dst_x any
---@param dst_y any
function LImageData:blit(src_ud, dst_x, dst_y) end

--- Returns the sum of absolute per-channel differences between this image and `other`.
---@param other_ud any
function LImageData:diff(other_ud) end

--- Returns the pixel height of this image buffer.
function LImageData:getHeight() end

--- Returns a copy of the rectangular sub-region as a new ImageData.
---@param x any
---@param y any
---@param w any
---@param h any
function LImageData:getRegion(x, y, w, h) end

--- Returns the pixel width of this image buffer.
function LImageData:getWidth() end

--- Applies a Lua function to every pixel in-place.
---@param callback any
function LImageData:mapPixels(callback) end

--- Returns a new ImageData scaled to the given dimensions using bilinear interpolation.
---@param w any
---@param h any
function LImageData:resize(w, h) end

--- Returns the type name "ImageData".
function LImageData:type() end

--- Returns true when the given name matches "ImageData" or a parent type.
---@param name any
function LImageData:typeOf(name) end

--- Lua-side handle to a mesh stored in SharedState.
---@class LMesh
LMesh = {}

--- Returns vertex data at the given 1-based index.
---@param index any
function LMesh:getVertex(index) end

--- Returns the number of vertices in this mesh.
function LMesh:getVertexCount() end

--- Releases the GPU mesh resource, freeing VRAM immediately.
function LMesh:release() end

--- Assigns a texture to this mesh.
---@param ud? any
function LMesh:setTexture(ud) end

--- Sets vertex data at the given 1-based index.
---@param index any
---@param data any
function LMesh:setVertex(index, data) end

--- Returns the type name of this object.
function LMesh:type() end

--- Returns the type name of this object.
function LMesh:typeOf() end

--- Lua-side 9-slice descriptor.
---@class LNineSlice
LNineSlice = {}

--- Compatibility stub: queuing handled by lurek.graphic.drawNineSlice.
---@param x any
---@param y any
---@param w any
---@param h any
function LNineSlice:draw(x, y, w, h) end

--- Returns the four inset values as (top, right, bottom, left).
function LNineSlice:getInsets() end

--- Returns the width and height of the source texture.
function LNineSlice:getTextureSize() end

--- Returns the type name "NineSlice".
function LNineSlice:type() end

--- Returns true when the given name matches "NineSlice" or a parent type.
---@param name any
function LNineSlice:typeOf(name) end

--- Lua-side quad viewport into a texture.
---@class LQuad
LQuad = {}

--- Returns the reference texture dimensions.
function LQuad:getTextureDimensions() end

--- Returns the quad viewport rectangle.
function LQuad:getViewport() end

--- Sets the quad viewport rectangle.
---@param x any
---@param y any
---@param w any
---@param h any
function LQuad:setViewport(x, y, w, h) end

--- Returns the type name of this object.
function LQuad:type() end

--- Returns the type name of this object.
function LQuad:typeOf() end

--- Lua-side handle to a compiled shader stored in SharedState.
---@class LShader
LShader = {}

--- Returns whether this shader has a uniform with the given name.
---@param name any
function LShader:hasUniform(name) end

--- Releases the compiled GPU shader, freeing VRAM and shader slots.
function LShader:release() end

--- Sends a uniform value to this shader.
---@param name any
---@param value any
function LShader:send(name, value) end

--- Returns the type name of this object.
function LShader:type() end

--- Returns the type name of this object.
function LShader:typeOf() end

--- Lua-side handle to a [`CompoundShape`] stored in [`SharedState::shapes`].
---@class LShape
LShape = {}

--- Queues a filled or outlined arc draw command onto this shape.
function LShape:arc() end

--- Queues a filled or outlined circle draw command onto this shape.
---@param mode any
---@param x any
---@param y any
---@param r any
function LShape:circle(mode, x, y, r) end

--- Removes all commands and resets the shape to empty.
function LShape:clear() end

--- Queues a draw command for this shape at the given position.
function LShape:draw() end

--- Queues an ellipse command.
---@param mode any
---@param x any
---@param y any
---@param rx any
---@param ry any
function LShape:ellipse(mode, x, y, rx, ry) end

--- Returns the number of drawing commands currently stored.
function LShape:getCommandCount() end

--- Queues a line segment command.
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
function LShape:line(x1, y1, x2, y2) end

--- Queues a polygon command from variadic (x, y) coordinate pairs.
---@param mode any
---@param coords any
function LShape:polygon(mode, coords) end

--- Queues a polyline command from variadic (x, y) coordinate pairs.
function LShape:polyline() end

--- Queues a rectangle command.
---@param mode any
---@param x any
---@param y any
---@param w any
---@param h any
function LShape:rectangle(mode, x, y, w, h) end

--- Queues a rounded rectangle command.
---@param mode any
---@param x any
---@param y any
---@param w any
---@param h any
---@param rx any
---@param ry? any
function LShape:roundedRectangle(mode, x, y, w, h, rx, ry) end

--- Sets the drawing color for subsequent primitives.
---@param r any
---@param g any
---@param b any
---@param a? any
function LShape:setColor(r, g, b, a) end

--- Sets the stroke width for subsequent outlined primitives.
---@param w any
function LShape:setLineWidth(w) end

--- Queues a triangle command.
---@param mode any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param x3 any
---@param y3 any
function LShape:triangle(mode, x1, y1, x2, y2, x3, y3) end

--- Returns the type name of this object.
function LShape:type() end

--- Returns true if the given type name matches this object's type or any parent type.
---@param name any
function LShape:typeOf(name) end

--- Lua-side handle to a sprite batch stored in SharedState.
---@class LSpriteBatch
LSpriteBatch = {}

--- Adds a sprite entry to this batch.
function LSpriteBatch:add() end

--- Removes all sprites from this batch.
function LSpriteBatch:clear() end

--- Returns the maximum capacity of this batch.
function LSpriteBatch:getBufferSize() end

--- Returns the number of sprites in this batch.
function LSpriteBatch:getCount() end

--- Releases this sprite batch.
function LSpriteBatch:release() end

--- Returns the type name of this object.
function LSpriteBatch:type() end

--- Returns the type name of this object.
function LSpriteBatch:typeOf() end

--- Applies an affine transform matrix.
---@param mat any
lurek.render.applyTransform = function(mat) end

--- Draws a partial circle arc at the given position with specified radius and angle range.
lurek.render.arc = function() end

--- Begins a Y/Z depth sort group. Draw commands until flushSortGroup are depth-sortable.
---@param id any
lurek.render.beginSortGroup = function(id) end

--- Begins a Y/Z depth sort group identified by id.
---@param id any
lurek.render.beginSortGroup = function(id) end

--- Calls the given callback with an ImageData captured from the current frame (stub: creates blank).
---@param callback any
lurek.render.captureScreenshot = function(callback) end

--- Draws a filled or outlined circle at the given world-space position.
---@param mode any
---@param x any
---@param y any
---@param radius any
lurek.render.circle = function(mode, x, y, radius) end

--- Clears the draw command queue (resets the screen).
---@param r? any
---@param g? any
---@param b? any
lurek.render.clear = function(r, g, b) end

--- Resets the stencil mode to the default (keep / always / 0).
lurek.render.clearStencil = function() end

--- Returns the name of the currently active named layer.
lurek.render.currentLayer = function() end

--- Draws a drawable (Image, Canvas, SpriteBatch, Mesh) at the given position.
---@param ... any
lurek.render.draw = function(...) end

--- Queues a beveled border rectangle with inner fill.
lurek.render.drawBevelRect = function() end

--- Queues a beveled border rectangle.
lurek.render.drawBevelRect = function() end

--- Queues a convex polygon with per-vertex colours.
---@param vertices any
---@param colors any
---@param mode? any
lurek.render.drawColoredPolygon = function(vertices, colors, mode) end

--- Queues a convex polygon with per-vertex colours.
---@param vertices any
---@param colors any
---@param mode? any
lurek.render.drawColoredPolygon = function(vertices, colors, mode) end

--- Queues a cubic BĂ©zier curve from (x1,y1) to (x2,y2) with two control points.
lurek.render.drawCubicBezier = function() end

--- Queues a cubic BĂ©zier curve from (x1,y1) to (x2,y2) with two control points.
lurek.render.drawCubicBezier = function() end

--- Queues a gradient-filled rectangle. color1/color2 are {r,g,b,a} tables.
lurek.render.drawGradientRect = function() end

--- Queues a gradient-filled rectangle. Both colors are RGBA tables {r,g,b,a} or positional {[1]=r,[2]=g,[3]=b,[4]=a}.
lurek.render.drawGradientRect = function() end

--- Queues a hexagonal tile at centre (cx, cy) with given circumradius.
lurek.render.drawHexTile = function() end

--- Queues a hexagonal tile at centre (cx, cy) with given circumradius.
lurek.render.drawHexTile = function() end

--- Queues a three-face isometric cube tile at screen position (sx, sy).
---@param sx any
---@param sy any
---@param half_w any
---@param half_h any
---@param opts? any
lurek.render.drawIsoCubeTile = function(sx, sy, half_w, half_h, opts) end

--- Queues a three-face isometric cube tile at screen position (sx, sy).
---@param sx any
---@param sy any
---@param half_w any
---@param half_h any
---@param opts? any
lurek.render.drawIsoCubeTile = function(sx, sy, half_w, half_h, opts) end

--- Queues a 9-slice draw call inside lurek.draw / lurek.draw_ui.
---@param slice any
---@param x any
---@param y any
---@param w any
---@param h any
lurek.render.drawNineSlice = function(slice, x, y, w, h) end

--- Queues a multi-segment vector path.
---@param path any
---@param mode? any
---@param close? any
lurek.render.drawPath = function(path, mode, close) end

--- Queues a multi-segment vector path.
---@param path any
---@param mode? any
---@param close? any
lurek.render.drawPath = function(path, mode, close) end

--- Queues a quadratic BĂ©zier curve from (x1,y1) to (x2,y2) with one control point.
---@param x1 any
---@param y1 any
---@param cx any
---@param cy any
---@param x2 any
---@param y2 any
---@param segs? any
lurek.render.drawQuadBezier = function(x1, y1, cx, cy, x2, y2, segs) end

--- Must be called inside lurek.draw or lurek.draw_ui.
lurek.render.drawQuadBezier = function() end

--- Draws a portion of an image defined by a Quad.
lurek.render.drawq = function() end

--- Draws a filled or outlined ellipse with independent x/y radii.
---@param mode any
---@param x any
---@param y any
---@param rx any
---@param ry any
lurek.render.ellipse = function(mode, x, y, rx, ry) end

--- Sorts and flushes all draw commands in the sort group.
---@param id any
lurek.render.flushSortGroup = function(id) end

--- Sorts and flushes all draw commands in the sort group.
---@param id any
lurek.render.flushSortGroup = function(id) end

--- Returns the current background color.
lurek.render.getBackgroundColor = function() end

--- Returns the current blend mode as a string.
lurek.render.getBlendMode = function() end

--- Returns the current canvas, or nil if drawing to screen.
lurek.render.getCanvas = function() end

--- Returns the dimensions of a canvas.
---@param ud any
lurek.render.getCanvasSize = function(ud) end

--- Returns the current drawing color.
lurek.render.getColor = function() end

--- Returns the current color mask.
lurek.render.getColorMask = function() end

--- Returns the default texture filter mode.
lurek.render.getDefaultFilter = function() end

--- Returns a built-in font by pixel height (snaps to nearest available size).
---@param pixel_height? any
lurek.render.getDefaultFont = function(pixel_height) end

--- Returns the current depth mode as (mode, write).
lurek.render.getDepthMode = function() end

--- Returns window width and height.
lurek.render.getDimensions = function() end

--- Returns the currently active font, or nil.
lurek.render.getFont = function() end

--- Returns the ascent of the given font.
---@param ud any
lurek.render.getFontAscent = function(ud) end

--- Returns the cell width of the given font (for monospaced bitmap fonts).
---@param ud any
lurek.render.getFontCellWidth = function(ud) end

--- Returns the descent of the given font.
---@param ud any
lurek.render.getFontDescent = function(ud) end

--- Returns the line height of the given font.
---@param ud any
lurek.render.getFontHeight = function(ud) end

--- Returns the line height of the given font (alias for getFontHeight).
---@param ud any
lurek.render.getFontLineHeight = function(ud) end

--- Returns a table of available built-in font pixel heights.
lurek.render.getFontSizes = function() end

--- Returns the pixel width of text in the given font.
---@param ud any
---@param text any
lurek.render.getFontWidth = function(ud, text) end

--- Returns wrapped lines and the maximum line width.
---@param text any
---@param limit any
lurek.render.getFontWrap = function(text, limit) end

--- Returns the window height in pixels.
lurek.render.getHeight = function() end

--- Returns the z-order of the named layer, or `0` if unregistered.
---@param name any
lurek.render.getLayerZOrder = function(name) end

--- Returns the current line width.
lurek.render.getLineWidth = function() end

--- Returns the current point size.
lurek.render.getPointSize = function() end

--- Returns the active scissor rectangle, or nothing.
lurek.render.getScissor = function() end

--- Returns the active shader, or nil.
lurek.render.getShader = function() end

--- Returns a table of renderer statistics.
lurek.render.getStats = function() end

--- Returns the current stencil mode as (action, compare, value).
lurek.render.getStencilMode = function() end

--- Returns the window width in pixels.
lurek.render.getWidth = function() end

--- Intersects the current scissor with a new rectangle.
---@param x any
---@param y any
---@param w any
---@param h any
lurek.render.intersectScissor = function(x, y, w, h) end

--- Returns `true` if the named layer is visible (default: `true`).
---@param name any
lurek.render.isLayerVisible = function(name) end

--- Returns whether wireframe mode is active.
lurek.render.isWireframe = function() end

--- Draws a line between two points.
---@param ... any
lurek.render.line = function(...) end

--- Creates an off-screen render canvas.
---@param width any
---@param height any
lurek.render.newCanvas = function(width, height) end

--- Creates a new z-ordered draw-call queue.
lurek.render.newDrawLayer = function() end

--- Loads a bitmap font PNG from a file, or selects a built-in size by pixel height.
---@param ... any
lurek.render.newFont = function(...) end

--- Loads an image from a file path or creates one from ImageData.
---@param arg any
lurek.render.newImage = function(arg) end

--- Registers a named render layer with an optional z-order (default 0).
---@param name any
---@param z_order? any
lurek.render.newLayer = function(name, z_order) end

--- Creates a custom mesh from vertex data.
---@param verts any
---@param mode? any
lurek.render.newMesh = function(verts, mode) end

--- Creates a 9-slice descriptor from a texture and inset values.
---@param image any
---@param top any
---@param right any
---@param bottom any
---@param left any
lurek.render.newNineSlice = function(image, top, right, bottom, left) end

--- Creates a new Quad viewport into a texture.
---@param x any
---@param y any
---@param w any
---@param h any
---@param sw any
---@param sh any
lurek.render.newQuad = function(x, y, w, h, sw, sh) end

--- Compiles a custom WGSL shader and returns its handle.
---@param code any
lurek.render.newShader = function(code) end

--- Creates a new empty [`CompoundShape`] stored in the resource pool.
lurek.render.newShape = function() end

--- Creates a new sprite batch for the given image.
---@param ud any
---@param max? any
lurek.render.newSpriteBatch = function(ud, max) end

--- Resets the transform to the identity.
lurek.render.origin = function() end

--- Draws a batch of individual points at the specified world-space coordinates.
---@param ... any
lurek.render.points = function(...) end

--- Draws a polygon from a list of vertices.
---@param ... any
lurek.render.polygon = function(...) end

--- Pops the transform from the stack.
lurek.render.pop = function() end

--- Ends and composites the named layer back to its parent.
---@param id any
lurek.render.popLayer = function(id) end

--- Ends and composites the named layer.
---@param id any
lurek.render.popLayer = function(id) end

--- Draws text at the given position.
---@param text any
---@param x? any
---@param y? any
---@param scale? any
lurek.render.print = function(text, x, y, scale) end

--- Draws a sequence of individually-styled text spans at `(x, y)`.
---@param spans_table any
---@param x any
---@param y any
lurek.render.printRich = function(spans_table, x, y) end

--- Draws word-wrapped text within a given width.
---@param text any
---@param x any
---@param y any
---@param limit any
---@param align? any
lurek.render.printf = function(text, x, y, limit, align) end

--- Pushes the current transform onto the stack.
lurek.render.push = function() end

--- Begins a named compositing layer with optional alpha and blend mode.
---@param id any
---@param alpha? any
---@param blend_mode? any
lurek.render.pushLayer = function(id, alpha, blend_mode) end

--- Begins a named compositing layer. Provides alpha and blend mode for composite.
---@param id any
---@param alpha? any
---@param blend_mode? any
lurek.render.pushLayer = function(id, alpha, blend_mode) end

--- Associates the previous draw command with a depth value within the active sort group.
---@param depth any
lurek.render.pushSortKey = function(depth) end

--- Associates the previous draw command with a depth value within the active sort group.
---@param depth any
lurek.render.pushSortKey = function(depth) end

--- Draws a filled or outlined axis-aligned rectangle at the given position.
lurek.render.rectangle = function() end

--- Rotates the coordinate system.
---@param angle any
lurek.render.rotate = function(angle) end

--- Queues a screenshot to be saved after the current frame.
---@param path any
lurek.render.saveScreenshot = function(path) end

--- Scales the coordinate system.
---@param sx any
---@param sy? any
lurek.render.scale = function(sx, sy) end

--- Sets the background clear color.
---@param r any
---@param g any
---@param b any
lurek.render.setBackgroundColor = function(r, g, b) end

--- Sets the blend mode for drawing.
---@param mode any
lurek.render.setBlendMode = function(mode) end

--- Sets the active render target to a Canvas, or back to the screen.
---@param ud? any
lurek.render.setCanvas = function(ud) end

--- Sets the current drawing color.
---@param r any
---@param g any
---@param b any
---@param a? any
lurek.render.setColor = function(r, g, b, a) end

--- Sets which RGBA channels are written. Reset with no args.
---@param ... any
lurek.render.setColorMask = function(...) end

--- Sets the default texture filter mode.
---@param min any
---@param mag any
---@param anisotropy? any
lurek.render.setDefaultFilter = function(min, mag, anisotropy) end

--- Sets the depth test comparison and write enable.
---@param mode any
---@param write? any
lurek.render.setDepthMode = function(mode, write) end

--- Sets the active font for print calls.
---@param ud any
lurek.render.setFont = function(ud) end

--- Sets the line height of the given font (stub â€” returns nil; fonts are immutable in headless mode).
---@param font any
---@param lh any
lurek.render.setFontLineHeight = function(font, lh) end

--- Sets the active named layer. Draw calls made after this will be
---@param name any
lurek.render.setLayer = function(name) end

--- Shows or hides the named layer. Hidden layers are excluded from
---@param name any
---@param visible any
lurek.render.setLayerVisible = function(name, visible) end

--- Updates the z-order of the named layer. Auto-creates the layer if
---@param name any
---@param z any
lurek.render.setLayerZOrder = function(name, z) end

--- Sets the line width for outline drawing.
---@param w any
lurek.render.setLineWidth = function(w) end

--- Sets the point diameter in pixels.
---@param size any
lurek.render.setPointSize = function(size) end

--- Restricts drawing to a rectangle, or clears scissor if no args.
---@param ... any
lurek.render.setScissor = function(...) end

--- Sets the active shader, or clears it.
---@param ud? any
lurek.render.setShader = function(ud) end

--- Sets the stencil buffer write/test mode.
---@param action any
---@param compare? any
---@param value? any
lurek.render.setStencilMode = function(action, compare, value) end

--- Sets the stencil comparison test, or disables stencil testing.
---@param compare? any
---@param value? any
lurek.render.setStencilTest = function(compare, value) end

--- Enables or disables wireframe rendering.
---@param enabled any
lurek.render.setWireframe = function(enabled) end

--- Shears the coordinate system.
---@param kx any
---@param ky any
lurek.render.shear = function(kx, ky) end

--- Begins stencil writing with the given action and value.
---@param action? any
---@param value? any
lurek.render.stencil = function(action, value) end

--- Translates the coordinate system.
---@param x any
---@param y any
lurek.render.translate = function(x, y) end

--- Draws a filled or outlined triangle connecting three world-space vertices.
---@param mode any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param x3 any
---@param y3 any
lurek.render.triangle = function(mode, x1, y1, x2, y2, x3, y3) end

---@class lurek.save
lurek.save = {}

--- Lua-side wrapper around [`SaveManager`] with per-module callback storage.
---@class LSaveManager
LSaveManager = {}

--- Registers a migration function for upgrading from a schema version
---@param from_ver any
---@param func any
function LSaveManager:addMigration(from_ver, func) end

--- Collects data from all registered collectors into a table with metadata
function LSaveManager:collect() end

--- Deletes a save file for the given slot.
---@param slot any
function LSaveManager:delete(slot) end

--- Disables automatic periodic saving; manual `write()` calls still work.
function LSaveManager:disableAutoSave() end

--- Enables auto-save with a given interval and target slot
---@param interval any
---@param slot any
function LSaveManager:enableAutoSave(interval, slot) end

--- Returns whether a save file exists for the given slot.
---@param slot any
function LSaveManager:exists(slot) end

--- Returns the current schema version
function LSaveManager:getSchemaVersion() end

--- Returns metadata for a single slot, or nil if not found.
---@param slot any
function LSaveManager:getSlotInfo(slot) end

--- Returns a list of all save slots with metadata.
function LSaveManager:getSlots() end

--- Returns the current summary string
function LSaveManager:getSummary() end

--- Returns whether compression is currently enabled.
function LSaveManager:isCompressed() end

--- Returns whether data has been modified since the last save or load
function LSaveManager:isDirty() end

--- Loads data from a slot file, applies migrations, and restores.
---@param slot any
function LSaveManager:load(slot) end

--- Marks data as modified since the last save or load
function LSaveManager:markDirty() end

--- Registers a callback that fires after every successful load operation.
---@param func any
function LSaveManager:onAfterLoad(func) end

--- Registers a callback that fires before every save operation.
---@param func any
function LSaveManager:onBeforeSave(func) end

--- Registers a named module with collector and restorer callbacks
---@param name any
---@param collect_fn any
---@param restore_fn any
function LSaveManager:register(name, collect_fn, restore_fn) end

--- Resets all state, removing callbacks and clearing the manager
function LSaveManager:reset() end

--- Restores data from a table, applying migrations and calling restorers
---@param data any
function LSaveManager:restore(data) end

--- Collects data and writes it to a slot file.
---@param slot any
function LSaveManager:save(slot) end

--- Enables or disables LZ4 compression for saved data
---@param enabled any
function LSaveManager:setCompress(enabled) end

--- Sets the current schema version for new saves
---@param version any
function LSaveManager:setSchemaVersion(version) end

--- Sets the summary string included in save metadata
---@param summary any
function LSaveManager:setSummary(summary) end

--- Returns the type name of this object.
function LSaveManager:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSaveManager:typeOf(name) end

--- Removes a named module and its callbacks
---@param name any
function LSaveManager:unregister(name) end

--- Advances the auto-save timer, returning the slot name if a save should trigger
---@param dt any
function LSaveManager:update(dt) end

--- Creates a new SaveManager for slot-based save/load operations.
lurek.save.newSaveManager = function() end

---@class lurek.scene
lurek.scene = {}

--- Lua-side wrapper around a [`DepthSorter`] with registry-stored callbacks.
---@class LDepthSorter
LDepthSorter = {}

--- Registers a draw callback at the given depth layer.
---@param callback any
---@param depth any
function LDepthSorter:add(callback, depth) end

--- Registers a table object with a draw method at the given depth.
---@param obj any
function LDepthSorter:addObject(obj) end

--- Removes all registered callbacks without calling them.
function LDepthSorter:clear() end

--- Calls all draw callbacks in sorted depth order, then clears.
function LDepthSorter:flush() end

--- Returns the number of registered draw entries.
function LDepthSorter:getCount() end

--- Returns true if stable sort mode is enabled.
function LDepthSorter:isStable() end

--- Sets whether equal-depth entries preserve insertion order.
---@param stable any
function LDepthSorter:setStable(stable) end

--- Sorts all registered callbacks by depth ascending.
function LDepthSorter:sort() end

--- Returns the type name of this object.
function LDepthSorter:type() end

--- Returns true if this object is of the given type.
---@param name any
function LDepthSorter:typeOf(name) end

--- Clears all scenes from the stack, calling leave on each.
lurek.scene.clear = function() end

--- Creates a reusable scene class â€” returns a zero-argument constructor function.
---@param def? any
lurek.scene.define = function(def) end

--- Returns the number of scenes on the stack.
lurek.scene.depth = function() end

--- Restores scene data_refs from a snapshot produced by serializeScene().
---@param snapshot any
lurek.scene.deserializeScene = function(snapshot) end

--- Draws all scenes in the stack from bottom to top (legacy name; prefer `render`).
lurek.scene.draw = function() end

--- Returns a fade cross-dissolve transition config table.
---@param duration? any
lurek.scene.fade = function(duration) end

--- Returns a table array of all active scene tables.
lurek.scene.getActiveScenes = function() end

--- Returns the current top scene table, or nil if the stack is empty.
lurek.scene.getCurrent = function() end

--- Returns a value from the inter-scene data store, or nil if not found.
---@param key any
lurek.scene.getData = function(key) end

--- Returns a registered scene table by name, or nil if not found.
---@param name any
lurek.scene.getRegistered = function(name) end

--- Returns a list of all registered scene names.
lurek.scene.getRegisteredNames = function() end

--- Returns the number of scenes on the stack.
lurek.scene.getStackSize = function() end

--- Returns the transition progress from 0.0 to 1.0.
lurek.scene.getTransitionProgress = function() end

--- Returns the easing-adjusted transition progress from 0.0 to 1.0.
lurek.scene.getTransitionProgressEased = function() end

--- Returns a table listing all supported transition type strings.
lurek.scene.getTransitionTypes = function() end

--- Returns true if the given key exists in the data store.
---@param key any
lurek.scene.hasData = function(key) end

--- Returns true if a scene is registered under the given name.
---@param name any
lurek.scene.hasRegistered = function(name) end

--- Returns an iris in/out (circular reveal) transition config table.
---@param duration? any
lurek.scene.iris = function(duration) end

--- Returns true if the scene stack is empty.
lurek.scene.isEmpty = function() end

--- Returns true if the current top scene was pushed as an overlay.
lurek.scene.isOverlay = function() end

--- Returns true if the named scene has been preloaded.
---@param name any
lurek.scene.isPreloaded = function(name) end

--- Returns true if a scene transition is currently active.
lurek.scene.isTransitioning = function() end

--- Creates a scene instance directly from a methods table.
---@param def? any
lurek.scene.new = function(def) end

--- Creates a new DepthSorter for z-ordered draw batching.
lurek.scene.newDepthSorter = function() end

--- Alias for `lurek.scene.new`. Creates a scene instance from a methods table.
---@param def? any
lurek.scene.newScene = function(def) end

--- Pops the top scene from the stack with an optional transition and easing.
---@param transition? any
---@param duration? any
---@param easing? any
lurek.scene.pop = function(transition, duration, easing) end

--- Pops scenes until the named scene is on top, calling leave on each removed.
---@param name any
lurek.scene.popTo = function(name) end

--- Registers a loader function for a named scene. The loader is called
---@param name any
---@param loader any
lurek.scene.preload = function(name, loader) end

--- Calls `scene:ready(self)` once per scene on the first tick after enter,
---@param dt any
lurek.scene.process = function(dt) end

--- Calls `scene:process_late(dt)` on all active scenes (after process, before render).
---@param dt any
lurek.scene.processLate = function(dt) end

--- Calls `scene:process_physics(dt)` on all active scenes (fixed timestep).
---@param dt any
lurek.scene.processPhysics = function(dt) end

--- Pushes a scene table onto the stack with an optional transition and easing.
lurek.scene.push = function() end

--- Pushes a scene as a non-pausing overlay over the current top scene.
lurek.scene.pushOverlay = function() end

--- Pushes a registered scene by name, running its loader if not yet preloaded.
lurek.scene.pushPreloaded = function() end

--- Registers a scene table by name for later retrieval.
---@param name any
---@param scene any
lurek.scene.registerScene = function(name, scene) end

--- Removes a value from the inter-scene data store by key.
---@param key any
lurek.scene.removeData = function(key) end

--- Draws all scenes in the stack from bottom to top.
lurek.scene.render = function() end

--- Draws UI overlay for all scenes in the stack from bottom to top.
lurek.scene.renderUi = function() end

--- Returns a snapshot of the scene stack as a Lua table: { stack=[name...], data={key=val} }.
lurek.scene.serializeScene = function() end

--- Stores a value in the inter-scene data store under the given key.
---@param key any
---@param value any
lurek.scene.setData = function(key, value) end

--- Returns a directional slide transition config table.
---@param direction? any
---@param duration? any
lurek.scene.slide = function(direction, duration) end

--- Replaces the top scene with a new one, calling leave and enter callbacks.
lurek.scene.switchTo = function() end

--- Removes a scene from the registry by name.
---@param name any
lurek.scene.unregisterScene = function(name) end

--- Updates the top scene and any active transition (legacy name; prefer `process`).
---@param dt any
lurek.scene.update = function(dt) end

--- Returns a wipe/curtain transition config table.
---@param duration? any
lurek.scene.wipe = function(duration) end

---@class lurek.serial
lurek.serial = {}

--- Decodes a binary MessagePack string into a Lua table.
lurek.serial.decodeMsgPack = function() end

--- Parses an XML string and returns a nested Lua table.
---@param s any
lurek.serial.decodeXml = function(s) end

--- Encodes a Lua table to a binary MessagePack string.
---@param value any
lurek.serial.encodeMsgPack = function(value) end

--- Parses a CSV string and returns a sequence of row tables.
---@param s any
---@param delim? any
---@param headers? any
lurek.serial.fromCsv = function(s, delim, headers) end

--- Parses a JSON string and returns a Lua table.
---@param s any
lurek.serial.fromJson = function(s) end

--- Parses a TOML string and returns a Lua table.
---@param s any
lurek.serial.fromToml = function(s) end

--- Serializes a sequence of row tables to a CSV string.
---@param value any
---@param delim? any
---@param headers? any
lurek.serial.toCsv = function(value, delim, headers) end

--- Serializes a Lua value to a JSON string.
---@param value any
---@param pretty? any
lurek.serial.toJson = function(value, pretty) end

--- Serializes a Lua table to a TOML string.
---@param value any
lurek.serial.toToml = function(value) end

--- Validates a Lua table against a schema table.
---@param value any
---@param schema any
lurek.serial.validate = function(value, schema) end

---@class lurek.spine
lurek.spine = {}

--- Lua-side wrapper around a [`Skeleton`].
---@class LSkeleton
LSkeleton = {}

--- Adds a SkeletonAnimation to this skeleton's library.
---@param anim_ud any
function LSkeleton:addAnimation(anim_ud) end

--- Adds a root bone with optional local transform and returns its index.
---@param name any
---@param opts? any
function LSkeleton:addBone(name, opts) end

--- Adds a child bone attached to a parent and returns its index.
---@param name any
---@param parent_idx any
---@param opts? any
function LSkeleton:addChildBone(name, parent_idx, opts) end

--- Adds a two-bone IK constraint and returns its index.
---@param name any
---@param chain_tbl any
---@param bend_positive? any
function LSkeleton:addIKConstraint(name, chain_tbl, bend_positive) end

--- Registers a new empty skin by name.
---@param name any
function LSkeleton:addSkin(name) end

--- Adds a slot bound to a bone and returns its index.
---@param name any
---@param bone_idx any
---@param attachment? any
function LSkeleton:addSlot(name, bone_idx, attachment) end

--- Evaluates `anim` at `time` and blends the result into this skeleton
---@param anim_ud any
---@param time any
---@param blend_weight? any
function LSkeleton:blendAnimation(anim_ud, time, blend_weight) end

--- Returns the total number of bones.
function LSkeleton:boneCount() end

--- Renders the skeleton as a stick-figure debug view into a new ImageData.
---@param w any
---@param h any
function LSkeleton:drawToImage(w, h) end

--- Returns the index of the named bone, or nil if not found.
---@param name any
function LSkeleton:findBone(name) end

--- Returns the index of the named slot, or nil if not found.
---@param name any
function LSkeleton:findSlot(name) end

--- Returns the current playback time in seconds of the active animation.
function LSkeleton:getAnimationTime() end

--- Returns the world-space transform of a bone as a table, or nil if out of range.
---@param idx any
function LSkeleton:getBoneWorld(idx) end

--- Returns the name of the currently active skin, or nil.
function LSkeleton:getSkin() end

--- Starts playback of the named skeletal animation clip.
---@param name any
---@param looping? any
function LSkeleton:playAnimation(name, looping) end

--- Sets the world-space target position for the named IK constraint.
---@param name any
---@param x any
---@param y any
function LSkeleton:setIKTarget(name, x, y) end

--- Sets the root bone position and propagates world transforms.
---@param x any
---@param y any
function LSkeleton:setPosition(x, y) end

--- Activates the named skin for attachment lookups.
---@param name any
function LSkeleton:setSkin(name) end

--- Registers a slot-to-attachment mapping in the named skin.
---@param skin any
---@param slot any
---@param attachment any
function LSkeleton:setSkinMapping(skin, slot, attachment) end

--- Returns the total number of slots.
function LSkeleton:slotCount() end

--- Stops the current skeletal animation.
function LSkeleton:stopAnimation() end

--- Returns the type name of this object.
function LSkeleton:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSkeleton:typeOf(name) end

--- Advances the playing animation by `dt` seconds and applies keyframes.
---@param dt any
function LSkeleton:updateAnimation(dt) end

--- Propagates local transforms down the bone hierarchy to compute world positions.
function LSkeleton:updateWorldTransforms() end

--- Lua-side wrapper around a [`SkeletonAnimation`] keyframe clip.
---@class LSkeletonAnimation
LSkeletonAnimation = {}

--- Adds a named event marker at `time` seconds in the animation.
---@param time any
---@param name any
---@param value? any
function LSkeletonAnimation:addEventKey(time, name, value) end

--- Adds a keyframe to the bone timeline for the given property and bone index.
function LSkeletonAnimation:addKeyframe() end

--- Returns the total duration of the animation in seconds.
function LSkeletonAnimation:getDuration() end

--- Returns a list of event names that fall in the half-open interval `(from, to]`.
---@param from any
---@param to any
function LSkeletonAnimation:getEvents(from, to) end

--- Returns the number of bone timelines in this animation.
function LSkeletonAnimation:getTimelineCount() end

--- Returns the type name of this object.
function LSkeletonAnimation:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSkeletonAnimation:typeOf(name) end

--- Creates a new empty skeleton with the given name.
---@param name any
lurek.spine.newSkeleton = function(name) end

--- Creates a new empty SkeletonAnimation clip with the given name and duration.
---@param name any
---@param duration any
lurek.spine.newSkeletonAnimation = function(name, duration) end

---@class lurek.sprite
lurek.sprite = {}

--- Lua-side wrapper around a [`SpriteAtlas`] named-region store.
---@class LSpriteAtlas
LSpriteAtlas = {}

--- Returns the total number of named regions in the atlas.
function LSpriteAtlas:entryCount() end

--- Returns a sequential table of all region names.
function LSpriteAtlas:entryNames() end

--- Returns the region at the given 1-based insertion index, or nil.
---@param index any
function LSpriteAtlas:getByIndex(index) end

--- Returns the named region as a table `{name, x, y, w, h, rotated}`, or nil.
---@param name any
function LSpriteAtlas:getEntry(name) end

--- Returns a copy of the named region with `flip_x` and `flip_y` flags set.
---@param name any
---@param flip_x any
---@param flip_y any
function LSpriteAtlas:getFlipped(name, flip_x, flip_y) end

--- Returns the type name of this object.
function LSpriteAtlas:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSpriteAtlas:typeOf(name) end

--- Lua-side wrapper around a [`SpriteSheet`] frame-grid calculator.
---@class LSpriteSheet
LSpriteSheet = {}

--- Renders the sheet grid as a debug view into a new ImageData.
---@param w any
---@param h any
function LSpriteSheet:drawToImage(w, h) end

--- Returns a sequential table of quad tables for every frame in the given column.
---@param col any
function LSpriteSheet:getColumn(col) end

--- Returns the quad for the 0-based frame index, or nil if out of range.
---@param index any
function LSpriteSheet:getFrame(index) end

--- Returns the total number of frames in the sheet.
function LSpriteSheet:getFrameCount() end

--- Returns the width and height of a single frame cell in pixels.
function LSpriteSheet:getFrameSize() end

--- Returns the number of columns and rows in the grid.
function LSpriteSheet:getGridSize() end

--- Returns a sequential table of quad tables for the named frame group, or nil.
---@param name any
function LSpriteSheet:getGroupFrames(name) end

--- Returns a sequential table of all defined group names.
function LSpriteSheet:getGroupNames() end

--- Returns a sequential table of quad tables for every frame in the given row.
---@param row any
function LSpriteSheet:getRow(row) end

--- Registers a named frame group starting at `start_frame` with `count` frames.
---@param name any
---@param start any
---@param count any
function LSpriteSheet:nameGroup(name, start, count) end

--- Returns the type name of this object.
function LSpriteSheet:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSpriteSheet:typeOf(name) end

--- Builds a SpriteSheet whose frames come from named entries in a SpriteAtlas.
---@param atlas_ud any
---@param sw any
---@param sh any
lurek.sprite.newAtlasSheet = function(atlas_ud, sw, sh) end

--- Creates an RPGMaker VX/Ace character sheet (3 cols Ă— 4 rows) with "down", "left", "right", "up" groups.
---@param tw any
---@param th any
lurek.sprite.newRPGMakerSheet = function(tw, th) end

--- Creates a sprite sheet with a uniform grid of `frame_w Ă— frame_h` frames.
---@param tw any
---@param th any
---@param fw any
---@param fh any
lurek.sprite.newSheet = function(tw, th, fw, fh) end

--- Parses an Aseprite JSON export string and returns a `SpriteAtlas`.
---@param json_str any
lurek.sprite.parseAsepriteAtlas = function(json_str) end

--- Parses a TexturePacker JSON string (hash or array format) and returns a SpriteAtlas.
---@param json_str any
lurek.sprite.parseAtlas = function(json_str) end

---@class lurek.system
lurek.system = {}

--- Serialises an engine error message to a compact JSON string.
---@param msg any
lurek.runtime.errorSnapshot = function(msg) end

--- Returns the CPU architecture string for the current machine.
lurek.runtime.getArch = function() end

--- Returns the command-line arguments as a table.
lurek.runtime.getArgs = function() end

--- Returns the output table from the most recently completed runBatch call.
---@param results any
lurek.runtime.getBatchResults = function(results) end

--- Returns the current contents of the system clipboard.
lurek.runtime.getClipboardText = function() end

--- Returns whether the debug overlay is currently visible.
lurek.runtime.getDebugOverlay = function() end

--- Returns the value of an environment variable, or nil if not set.
---@param name any
lurek.runtime.getEnv = function(name) end

--- Returns a table of system information including OS name, CPU model, and installed RAM.
lurek.runtime.getInfo = function() end

--- Returns the last unhandled error message, or nil.
lurek.runtime.getLastError = function() end

--- Returns the name of the current minimum log level for runtime messages.
lurek.runtime.getLogLevel = function() end

--- Returns the total amount of installed system RAM in megabytes.
lurek.runtime.getMemorySize = function() end

--- Resolves a stable runtime message ID such as 'L001' to its human-readable text.
---@param id any
lurek.runtime.getMessage = function(id) end

--- Returns the total number of message entries loaded into the runtime message catalog.
lurek.runtime.getMessageCount = function() end

--- Returns the host operating system name ('Windows', 'Linux', 'macOS').
lurek.runtime.getOS = function() end

--- Returns battery state, percentage charged, and estimated time remaining.
lurek.runtime.getPowerInfo = function() end

--- Returns an ordered list of the user's preferred locale strings (e.g. 'en-US').
lurek.runtime.getPreferredLocales = function() end

--- Returns the number of logical CPU cores available.
lurek.runtime.getProcessorCount = function() end

--- Returns the Lurek2D engine version string.
lurek.runtime.getVersion = function() end

--- Returns true when the runtime message catalog contains the given stable message ID.
---@param id any
lurek.runtime.hasMessage = function(id) end

--- Emit a log message from Lua at the specified level.
---@param level any
---@param message any
lurek.runtime.log = function(level, message) end

--- Opens a URL in the system's default browser.
---@param url any
lurek.runtime.openURL = function(url) end

--- Parses a command-line argument string and returns a structured key/value table.
---@param args? any
lurek.runtime.parseArgs = function(args) end

--- Runs a list of shell commands in parallel and returns immediately without blocking.
---@param tasks any
---@param opts? any
lurek.runtime.runBatch = function(tasks, opts) end

--- Replaces the system clipboard contents with the given string.
---@param text any
lurek.runtime.setClipboardText = function(text) end

--- Shows or hides the FPS/draw-call debug overlay.
---@param enabled any
lurek.runtime.setDebugOverlay = function(enabled) end

--- Sets the minimum severity level for runtime log messages.
---@param level any
lurek.runtime.setLogLevel = function(level) end

---@class lurek.terminal
lurek.terminal = {}

--- Lua-side wrapper around a [`Terminal`] with widget binding management.
---@class LTerminal
LTerminal = {}

--- Attaches a widget to this terminal.
---@param widget_ud any
function LTerminal:addWidget(widget_ud) end

--- Resizes the window to exactly fit the terminal grid at the current font size.
function LTerminal:autoResize() end

--- Clears all cells to defaults.
function LTerminal:clear() end

--- Detaches all widgets from this terminal.
function LTerminal:clearWidgets() end

--- Returns the cell data at 1-based coordinates.
---@param col any
---@param row any
function LTerminal:get(col, row) end

--- Returns the active cell size override as `{w, h}`, or `nil` if none is set.
function LTerminal:getCellSize() end

--- Returns the terminal grid dimensions.
function LTerminal:getDimensions() end

--- Returns the currently focused widget, or nil.
function LTerminal:getFocused() end

--- Returns the number of attached widgets.
function LTerminal:getWidgetCount() end

--- Routes a key press to the focused widget and fires callbacks.
---@param key any
function LTerminal:keypressed(key) end

--- Routes a mouse press to widgets using pixel coordinates.
---@param px any
---@param py any
---@param button? any
function LTerminal:mousepressed(px, py, button) end

--- Detaches a widget from this terminal.
---@param widget_ud any
function LTerminal:removeWidget(widget_ud) end

--- Renders the terminal grid and widgets as render commands.
---@param x? any
---@param y? any
function LTerminal:render(x, y) end

--- Removes the cell size override, restoring font-derived cell dimensions.
function LTerminal:resetCellSize() end

--- Sets a cell at 1-based coordinates with character FG and BG colours.
---@param ... any
function LTerminal:set(...) end

--- Sets a per-terminal cell pixel size override, bypassing the font-derived size.
---@param w any
---@param h any
function LTerminal:setCellSize(w, h) end

--- Sets the focused widget, or clears focus if nil is passed.
---@param value any
function LTerminal:setFocus(value) end

--- Sets the terminal font by pixel height, snapping to the nearest built-in size.
---@param height any
function LTerminal:setFont(height) end

--- Routes text input to the focused widget and fires callbacks.
---@param text any
function LTerminal:textinput(text) end

--- Returns the type name of this object.
function LTerminal:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTerminal:typeOf(name) end

--- Lua-side wrapper around a [`Widget`] with attachment and callback state.
---@class LWidget
LWidget = {}

--- Adds a child widget to a panel widget.
---@param child_ud any
function LWidget:addChild(child_ud) end

--- Adds an item to a list widget.
---@param item any
function LWidget:addItem(item) end

--- Removes all children from a panel widget.
function LWidget:clearChildren() end

--- Removes all items from a list widget.
function LWidget:clearItems() end

--- Returns a child widget from a panel by 1-based index, or nil.
---@param index any
function LWidget:getChild(index) end

--- Returns the number of children in a panel widget.
function LWidget:getChildCount() end

--- Returns the colour of a label or border widget.
function LWidget:getColor() end

--- Returns a list item by 1-based index.
---@param index any
function LWidget:getItem(index) end

--- Returns the number of items in a list widget.
function LWidget:getItemCount() end

--- Returns the maximum character length of a text box widget.
function LWidget:getMaxLength() end

--- Returns the widget position as 1-based coordinates.
function LWidget:getPosition() end

--- Returns the selected item index (1-based) in a list widget, or nil.
function LWidget:getSelected() end

--- Returns the widget size in cells.
function LWidget:getSize() end

--- Returns the border style name of a border widget.
function LWidget:getStyle() end

--- Returns the free-form identification tag.
function LWidget:getTag() end

--- Returns the text content of a label, button, or text box widget.
function LWidget:getText() end

--- Returns the title of a border widget.
function LWidget:getTitle() end

--- Returns whether the widget accepts input.
function LWidget:isEnabled() end

--- Returns whether the widget is visible.
function LWidget:isVisible() end

--- Removes a child widget from a panel widget.
---@param child_ud any
function LWidget:removeChild(child_ud) end

--- Removes an item from a list widget by 1-based index.
---@param index any
function LWidget:removeItem(index) end

--- Sets the colour of a label or border widget.
---@param r any
---@param g any
---@param b any
---@param a? any
function LWidget:setColor(r, g, b, a) end

--- Sets whether the widget accepts input.
---@param enabled any
function LWidget:setEnabled(enabled) end

--- Sets the maximum character length of a text box widget.
---@param max_length any
function LWidget:setMaxLength(max_length) end

--- Registers a text change callback for a text box widget.
---@param callback? any
function LWidget:setOnChange(callback) end

--- Registers a click callback for a button widget.
---@param callback? any
function LWidget:setOnClick(callback) end

--- Registers a selection change callback for a list widget.
---@param callback? any
function LWidget:setOnSelect(callback) end

--- Sets the widget position from 1-based coordinates.
---@param col any
---@param row any
function LWidget:setPosition(col, row) end

--- Sets the selected item in a list widget by 1-based index.
---@param index? any
function LWidget:setSelected(index) end

--- Sets the widget size in cells.
---@param width any
---@param height any
function LWidget:setSize(width, height) end

--- Sets the border style of a border widget.
---@param style_name any
function LWidget:setStyle(style_name) end

--- Sets the free-form identification tag.
---@param tag any
function LWidget:setTag(tag) end

--- Sets the text content of a label, button, or text box widget.
---@param text any
function LWidget:setText(text) end

--- Sets the title of a border widget.
---@param title any
function LWidget:setTitle(title) end

--- Sets the widget visibility.
---@param visible any
function LWidget:setVisible(visible) end

--- Returns the type name of this object.
function LWidget:type() end

--- Returns true if this object is of the given type.
---@param name any
function LWidget:typeOf(name) end

--- Adds a candidate string to the tab-completion engine.
---@param candidate any
lurek.terminal.addCompletion = function(candidate) end

--- Applies a named colour theme to a terminal, recolouring all existing cells.
---@param term_ud any
---@param theme any
lurek.terminal.applyTheme = function(term_ud, theme) end

--- Clears all entries from this terminal's command history.
---@param term_ud any
lurek.terminal.clearCmdHistory = function(term_ud) end

--- Clears all completion candidates.
lurek.terminal.clearCompletions = function() end

--- Returns the total number of entries in this terminal's command history.
---@param term_ud any
lurek.terminal.cmdHistoryLen = function(term_ud) end

--- Returns all registered candidates that start with `prefix`, as a sorted array.
---@param prefix any
lurek.terminal.getCompletions = function(prefix) end

--- Returns the maximum number of columns a Terminal can be constructed with.
lurek.terminal.getMaxCols = function() end

--- Returns the maximum number of rows a Terminal can be constructed with.
lurek.terminal.getMaxRows = function() end

--- Returns a table of lines from the scrollback buffer.
---@param term_ud any
---@param offset any
---@param count any
lurek.terminal.getScrollback = function(term_ud, offset, count) end

--- Creates a new decorative border widget at 1-based coordinates.
---@param col any
---@param row any
---@param width any
---@param height any
lurek.terminal.newBorder = function(col, row, width, height) end

--- Creates a new button widget at 1-based coordinates.
lurek.terminal.newButton = function() end

--- Creates a new label widget at 1-based coordinates.
---@param col any
---@param row any
---@param text? any
lurek.terminal.newLabel = function(col, row, text) end

--- Creates a new scrollable list widget at 1-based coordinates.
---@param col any
---@param row any
---@param width any
---@param height any
lurek.terminal.newList = function(col, row, width, height) end

--- Creates a new container panel widget at 1-based coordinates.
---@param col any
---@param row any
---@param width? any
---@param height? any
lurek.terminal.newPanel = function(col, row, width, height) end

--- Creates a new terminal grid with the given dimensions.
---@param cols? any
---@param rows? any
lurek.terminal.newTerminal = function(cols, rows) end

--- Creates a new single-line text box widget at 1-based coordinates.
---@param col any
---@param row any
---@param width any
lurek.terminal.newTextBox = function(col, row, width) end

--- Steps one entry forward in command history (toward newer commands).
---@param term_ud any
lurek.terminal.nextCmd = function(term_ud) end

--- Returns the next candidate for `prefix`, cycling on repeated calls.
---@param prefix any
lurek.terminal.nextCompletion = function(prefix) end

--- Parses `text` into coloured spans.  Returns an array of tables, each with
---@param text any
lurek.terminal.parseAnsi = function(text) end

--- Steps one entry back in command history (toward older commands).
---@param term_ud any
lurek.terminal.prevCmd = function(term_ud) end

--- Prints ANSI-escaped `text` onto terminal `t` starting at `(col, row)`.
---@param t_ud any
---@param col any
---@param row any
---@param text any
lurek.terminal.printAnsi = function(t_ud, col, row, text) end

--- Prints text at 1-based `(col, row)` with per-keyword colour highlighting.
lurek.terminal.printHighlighted = function() end

--- Appends a command string to this terminal's history.
---@param term_ud any
---@param cmd any
lurek.terminal.pushCmdHistory = function(term_ud, cmd) end

--- Appends a line to this terminal's scrollback buffer.
---@param term_ud any
---@param line any
lurek.terminal.pushScrollback = function(term_ud, line) end

--- Removes a candidate string from the tab-completion engine.
---@param candidate any
lurek.terminal.removeCompletion = function(candidate) end

--- Resets the cycling cursor without clearing the candidate list.
lurek.terminal.resetCompletion = function() end

--- Returns the number of lines currently in this terminal's scrollback buffer.
---@param term_ud any
lurek.terminal.scrollbackLen = function(term_ud) end

--- Sets the maximum number of lines retained in the scrollback buffer.
---@param term_ud any
---@param cap any
lurek.terminal.setScrollbackCap = function(term_ud, cap) end

--- Strips all ANSI escape codes from `text` and returns the plain string.
---@param text any
lurek.terminal.stripAnsi = function(text) end

---@class lurek.thread
lurek.thread = {}

--- A synchronized message queue for cross-VM communication.
---@class LChannel
LChannel = {}

--- Clears all items from the channel.
function LChannel:clear() end

--- Blocks until a value is available or the timeout expires, then removes and returns it.
---@param timeout? any
function LChannel:demand(timeout) end

--- Returns the number of items in the channel.
function LChannel:getCount() end

--- Retrieves the value from the channel without removing it.
function LChannel:peek() end

--- Retrieves and removes a value from the channel.
function LChannel:pop() end

--- Pops a bytes value from the channel and returns it as a Lua string.
function LChannel:popBytes() end

--- Pops a value from the channel expecting a table.
function LChannel:popTable() end

--- Pushes a value to the channel.
---@param value any
function LChannel:push(value) end

--- Pushes raw binary data (a Lua string treated as a byte array) to the channel.
---@param data any
function LChannel:pushBytes(data) end

--- Serializes a Lua table and pushes it to the channel.
---@param value any
function LChannel:pushTable(value) end

--- Blocks until the channel has space, then adds the value.
---@param value any
function LChannel:supply(value) end

--- Returns the type of the object.
function LChannel:type() end

--- Checks if the object is of the specified type.
---@param name any
function LChannel:typeOf(name) end

--- Lua-side wrapper around a one-shot [`Promise`].
---@class LPromise
LPromise = {}

--- Returns the worker error string if the promise failed, otherwise nil.
function LPromise:getError() end

--- Returns true if the promise has a result or has errored (non-blocking).
function LPromise:isDone() end

--- Pops and returns the promise result, or nil if not yet ready.
function LPromise:result() end

--- Returns the type name of this object.
function LPromise:type() end

--- Returns whether this object is of the given type.
---@param name any
function LPromise:typeOf(name) end

--- Lua-side wrapper around a background [`LuaThread`].
---@class LThread
LThread = {}

--- Returns the error message if the thread failed, or nil.
function LThread:getError() end

--- Returns whether the thread is currently executing.
function LThread:isRunning() end

--- Launches the background thread, passing optional arguments via varargs.
---@param ... any
function LThread:start(...) end

--- Returns the type name of this object.
function LThread:type() end

--- Returns whether this object is of the given type.
---@param name any
function LThread:typeOf(name) end

--- Blocks the calling thread until the background thread finishes.
function LThread:wait() end

--- Lua-side wrapper around a [`ThreadPool`].
---@class LThreadPool
LThreadPool = {}

--- Retrieves the next result from the pool's output channel (non-blocking).
function LThreadPool:collect() end

--- Returns the shared input Channel (main â†’ workers).
function LThreadPool:getInputChannel() end

--- Returns the shared output Channel (workers â†’ main).
function LThreadPool:getOutputChannel() end

--- Blocks until all workers in the pool have finished execution.
function LThreadPool:join() end

--- Returns the number of workers in this pool.
function LThreadPool:size() end

--- Submits a value to the pool's input channel for processing by a worker.
---@param value any
function LThreadPool:submit(value) end

--- Returns the type name of this object.
function LThreadPool:type() end

--- Returns whether this object is of the given type.
---@param name any
function LThreadPool:typeOf(name) end

--- Starts a one-shot background computation and returns a Promise.
---@param code any
---@param ... any
lurek.thread.async = function(code, ...) end

--- Gets or creates a named global channel shared across threads.
---@param name any
lurek.thread.getChannel = function(name) end

--- Creates an unnamed thread-safe channel for inter-thread communication.
lurek.thread.newChannel = function() end

--- Creates a thread pool of N workers all running the same Lua code.
---@param size any
---@param code any
lurek.thread.newPool = function(size, code) end

--- Creates a new background thread from a Lua code string.
---@param code any
lurek.thread.newThread = function(code) end

---@class lurek.tilemap
---@field FLOOR integer  solid floor tile type (1)
---@field NORTH_WALL integer  north-facing wall tile type (2)
---@field WEST_WALL integer  west-facing wall tile type (3)
---@field OBJECT integer  object tile type (4)
lurek.tilemap = {}

--- Lua-side wrapper around an [`AutoTileSheet`].
---@class LAutoTileSheet
LAutoTileSheet = {}

--- Applies autotile rules from this sheet to a TileSet.
---@param ts_ud any
---@param type_name any
---@param start_gid? any
function LAutoTileSheet:applyToTileSet(ts_ud, type_name, start_gid) end

--- Returns the bitmask value associated with a 1-based local tile ID.
---@param tile_id any
function LAutoTileSheet:getBitmaskForTile(tile_id) end

--- Returns the layout variant as a string.
function LAutoTileSheet:getLayout() end

--- Returns the atlas region rectangle for the 1-based tile ID.
---@param tile_id any
function LAutoTileSheet:getQuad(tile_id) end

--- Returns the number of tiles in this sheet.
function LAutoTileSheet:getTileCount() end

--- Returns the 1-based tile ID for a given bitmask, or nil.
---@param bitmask any
function LAutoTileSheet:getTileForBitmask(bitmask) end

--- Returns the tile height in pixels.
function LAutoTileSheet:getTileHeight() end

--- Returns the tile width in pixels.
function LAutoTileSheet:getTileWidth() end

--- Returns the type name of this object.
function LAutoTileSheet:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAutoTileSheet:typeOf(name) end

--- Lua-side wrapper around a [`ChunkMap`].
---@class LChunkMap
LChunkMap = {}

--- Returns the tile coordinate range for chunk (cx, cy) as (x0, y0, x1, y1).
---@param cx any
---@param cy any
function LChunkMap:chunkTileRange(cx, cy) end

--- Clears the tile at (x, y) by setting its GID to 0.
---@param x any
---@param y any
function LChunkMap:clearTile(x, y) end

--- Fills the rectangular tile region with a GID.
---@param x0 any
---@param y0 any
---@param x1 any
---@param y1 any
---@param gid any
function LChunkMap:fillRect(x0, y0, x1, y1, gid) end

--- Returns the chunk size (tiles per side).
function LChunkMap:getChunkSize() end

--- Returns chunk coordinates whose world-pixel footprint overlaps the given viewport.
---@param vx any
---@param vy any
---@param vw any
---@param vh any
---@param tw any
---@param th any
function LChunkMap:getChunksInView(vx, vy, vw, vh, tw, th) end

--- Returns a table of all currently loaded chunk coordinates as {{cx, cy}, ...}.
function LChunkMap:getLoadedChunks() end

--- Returns the GID at tile coordinate (x, y).
---@param x any
---@param y any
function LChunkMap:getTile(x, y) end

--- Pre-allocates the chunk at chunk coordinates (cx, cy).
---@param cx any
---@param cy any
function LChunkMap:loadChunk(cx, cy) end

--- Sets the GID at tile coordinate (x, y).
---@param x any
---@param y any
---@param gid any
function LChunkMap:setTile(x, y, gid) end

--- Returns the type name of this object.
function LChunkMap:type() end

--- Returns true if this object is of the given type.
---@param name any
function LChunkMap:typeOf(name) end

--- Removes the chunk at chunk coordinates (cx, cy) from memory.
---@param cx any
---@param cy any
function LChunkMap:unloadChunk(cx, cy) end

--- Lua-side wrapper around an [`IsoMap`].
---@class LIsoMap
LIsoMap = {}

--- Appends a new empty Z-level and returns its 1-based index.
function LIsoMap:addLevel() end

--- Fills every cell in level z with gid for the given part (1-based z; 0-based part).
---@param z any
---@param part any
---@param gid any
function LIsoMap:fillLevel(z, part, gid) end

--- Returns the map height in tiles.
function LIsoMap:getHeight() end

--- Returns the number of Z-levels currently in the map.
function LIsoMap:getLevelCount() end

--- Returns the vertical pixel offset between consecutive Z-levels.
function LIsoMap:getLevelHeight() end

--- Returns the number of GID slots per tile.
function LIsoMap:getPartCount() end

--- Returns the current draw-order array (0-based part slot indices).
function LIsoMap:getPartOrder() end

--- Returns the tile footprint height in pixels.
function LIsoMap:getTileHeight() end

--- Reads the GID in the part slot of tile (x, y) on level z (1-based z, x, y; 0-based part).
---@param z any
---@param x any
---@param y any
---@param part any
function LIsoMap:getTilePart(z, x, y, part) end

--- Returns the tile footprint width in pixels.
function LIsoMap:getTileWidth() end

--- Returns the map width in tiles.
function LIsoMap:getWidth() end

--- Returns the visibility of a level (1-based z).
---@param z any
function LIsoMap:isLevelVisible(z) end

--- Converts screen pixel coordinates to isometric tile coordinates at Z-level 0.
---@param sx any
---@param sy any
function LIsoMap:screenToTile(sx, sy) end

--- Sets the visibility of a level (1-based z).
---@param z any
---@param visible any
function LIsoMap:setLevelVisible(z, visible) end

--- Sets the screen pixel origin.
---@param x any
---@param y any
function LIsoMap:setOrigin(x, y) end

--- Overrides the draw order for this IsoMap. Length must equal partCount.
---@param order any
function LIsoMap:setPartOrder(order) end

--- Writes a GID into the part slot of tile (x, y) on level z (1-based z, x, y; 0-based part).
---@param z any
---@param x any
---@param y any
---@param part any
---@param gid any
function LIsoMap:setTilePart(z, x, y, part, gid) end

--- Projects isometric tile coordinates (tx, ty, tz) to screen pixels.
---@param tx any
---@param ty any
---@param tz any
function LIsoMap:tileToScreen(tx, ty, tz) end

--- Returns the type name of this object.
function LIsoMap:type() end

--- Returns true if this object is of the given type.
---@param name any
function LIsoMap:typeOf(name) end

--- Lua-side wrapper around a [`LargeMapRenderer`] for chunk-level occlusion culling on large worlds.
---@class LLargeMapRenderer
LLargeMapRenderer = {}

--- Returns the current chunk size.
function LLargeMapRenderer:getChunkSize() end

--- Returns the map dimensions as (width, height) in tiles.
function LLargeMapRenderer:getMapSize() end

--- Returns the tile ID at (x, y), or nil if out of bounds.
---@param x any
---@param y any
function LLargeMapRenderer:getTile(x, y) end

--- Returns the number of tileset atlas columns.
function LLargeMapRenderer:getTilesetColumns() end

--- Returns the total number of chunks that cover the loaded map.
function LLargeMapRenderer:getTotalChunks() end

--- Returns the number of chunks currently within the camera viewport.
function LLargeMapRenderer:getVisibleChunks() end

--- Marks every chunk as dirty.
function LLargeMapRenderer:invalidateAll() end

--- Marks a chunk at chunk-grid coordinates (cx, cy) as dirty,
---@param cx any
---@param cy any
function LLargeMapRenderer:invalidateChunk(cx, cy) end

--- Returns whether LOD rendering is currently enabled.
function LLargeMapRenderer:isLodEnabled() end

--- Updates the camera position and zoom used for visibility culling.
---@param x any
---@param y any
---@param zoom any
function LLargeMapRenderer:setCamera(x, y, zoom) end

--- Sets the chunk size used for culling (default 16).
---@param size any
function LLargeMapRenderer:setChunkSize(size) end

--- Enables or disables level-of-detail rendering for distant chunks.
---@param enabled any
function LLargeMapRenderer:setLodEnabled(enabled) end

--- Sets the distance thresholds (in tile units) at which each LOD level activates.
---@param levels any
function LLargeMapRenderer:setLodThresholds(levels) end

--- Loads a flat array of tile IDs (row-major) covering width Ă— height tiles.
---@param data any
---@param width any
---@param height any
function LLargeMapRenderer:setMapData(data, width, height) end

--- Sets a single tile ID at (x, y).  Coordinates are 0-based.
---@param x any
---@param y any
---@param tile_id any
function LLargeMapRenderer:setTile(x, y, tile_id) end

--- Sets the number of tile columns in the atlas texture used for UV calculation.
---@param cols any
function LLargeMapRenderer:setTilesetColumns(cols) end

--- Sets the viewport dimensions in pixels used for visibility culling.
---@param w any
---@param h any
function LLargeMapRenderer:setViewport(w, h) end

--- Returns the type name of this object.
function LLargeMapRenderer:type() end

--- Returns true if this object is of the given type.
---@param name any
function LLargeMapRenderer:typeOf(name) end

--- Lua-side wrapper around a [`MapBlock`].
---@class LMapBlock
LMapBlock = {}

--- Returns the block dimensions as (width, height) in tiles.
function LMapBlock:getDimensions() end

--- Returns the block height in tiles.
function LMapBlock:getHeight() end

--- Returns the number of segments along the height.
function LMapBlock:getHeightInSegments() end

--- Returns the number of layers in this block.
function LMapBlock:getLayerCount() end

--- Returns the name of this block.
function LMapBlock:getName() end

--- Returns the segment size in tiles.
function LMapBlock:getSegmentSize() end

--- Returns the side connection ID for a segment on a given edge.
---@param edge_str any
---@param segment any
function LMapBlock:getSide(edge_str, segment) end

--- Returns the GID of the tile at (x, y) on the given layer (1-based).
---@param layer any
---@param x any
---@param y any
function LMapBlock:getTile(layer, x, y) end

--- Returns the placement weight.
function LMapBlock:getWeight() end

--- Returns the block width in tiles.
function LMapBlock:getWidth() end

--- Returns the number of segments along the width.
function LMapBlock:getWidthInSegments() end

--- Sets the human-readable name of this block.
---@param name any
function LMapBlock:setName(name) end

--- Sets the side connection ID for a segment on a given edge.
---@param edge_str any
---@param segment any
---@param side_id any
function LMapBlock:setSide(edge_str, segment, side_id) end

--- Sets the GID of a tile at (x, y) on the given layer (1-based).
---@param layer any
---@param x any
---@param y any
---@param gid any
function LMapBlock:setTile(layer, x, y, gid) end

--- Sets the placement weight.
---@param weight any
function LMapBlock:setWeight(weight) end

--- Returns the type name of this object.
function LMapBlock:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMapBlock:typeOf(name) end

--- Lua-side wrapper for a map generator (size preset or explicit dimensions).
---@class LMapGen
LMapGen = {}

--- Generates a TileMap using the group's blocks and an optional script index, seed, and layer name.
---@param script_idx? any
---@param seed? any
---@param layer_name? any
function LMapGen:generate(script_idx, seed, layer_name) end

--- Returns the type name of this object.
function LMapGen:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMapGen:typeOf(name) end

--- Lua-side wrapper around a [`MapGroup`].
---@class LMapGroup
LMapGroup = {}

--- Adds a block to this group.
---@param block_ud any
function LMapGroup:addBlock(block_ud) end

--- Adds a MapScript to this group.
---@param script_ud any
function LMapGroup:addScript(script_ud) end

--- Returns the number of blocks in this group.
function LMapGroup:getBlockCount() end

--- Returns the name of this group.
function LMapGroup:getName() end

--- Returns the number of scripts in this group.
function LMapGroup:getScriptCount() end

--- Removes a block by 1-based index.
---@param idx any
function LMapGroup:removeBlock(idx) end

--- Returns the type name of this object.
function LMapGroup:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMapGroup:typeOf(name) end

--- Lua-side wrapper around a [`MapScript`] procedural generation script.
---@class LMapScript
LMapScript = {}

--- Appends a generation step from a step-definition table.
---@param step_def any
function LMapScript:addStep(step_def) end

--- Returns the number of steps in this script.
function LMapScript:getStepCount() end

--- Returns the type name of this object.
function LMapScript:type() end

--- Returns true if this object is of the given type.
---@param name any
function LMapScript:typeOf(name) end

--- Lua-side wrapper around a [`TileMap`].
---@class LTileMap
LTileMap = {}

--- Adds a new empty layer and returns its 1-based index.
---@param name any
---@param w any
---@param h any
function LTileMap:addLayer(name, w, h) end

--- Adds a tileset to this map.
---@param ts_ud any
function LTileMap:addTileSet(ts_ud) end

--- Applies 4-bit cardinal autotile rules to every tile on layer (1-based).
---@param layer any
---@param type_name any
function LTileMap:applyAutoTile(layer, type_name) end

--- Applies 8-bit directional autotile rules to every tile on layer (1-based).
---@param layer any
---@param type_name any
function LTileMap:applyAutoTile8(layer, type_name) end

--- Applies 8-bit directional autotile at a single cell and its 3x3 neighborhood (1-based).
---@param layer any
---@param x any
---@param y any
---@param type_name any
function LTileMap:applyAutoTile8At(layer, x, y, type_name) end

--- Applies 4-bit cardinal autotile at a single cell and its 3x3 neighborhood (1-based).
---@param layer any
---@param x any
---@param y any
---@param type_name any
function LTileMap:applyAutoTileAt(layer, x, y, type_name) end

--- Checks a list of entity positions against registered tile callbacks and fires matches.
---@param layer any
---@param entities any
function LTileMap:checkEntities(layer, entities) end

--- Clears a tile (sets GID to 0) at (x, y) on the given layer (1-based).
---@param layer any
---@param x any
---@param y any
function LTileMap:clearTile(layer, x, y) end

--- Renders the tile map to a CPU ImageData using the given tile pixel size.
---@param tile_size any
function LTileMap:drawToImage(tile_size) end

--- Fills an entire layer with the given GID (1-based layer).
---@param layer any
---@param gid any
function LTileMap:fill(layer, gid) end

--- Fire the tile exit callback for the given GID (call when entity leaves tile).
---@param gid any
---@param entity any
---@param tx any
---@param ty any
function LTileMap:fireTileExit(gid, entity, tx, ty) end

--- Fire the tile step callback for the given GID (call each frame while entity is on tile).
---@param gid any
---@param entity any
---@param tx any
---@param ty any
function LTileMap:fireTileStep(gid, entity, tx, ty) end

--- Returns the chunk size used for spatial partitioning.
function LTileMap:getChunkSize() end

--- Returns the RGBA tint color of a layer.
---@param idx any
function LTileMap:getLayerColor(idx) end

--- Returns the number of layers.
function LTileMap:getLayerCount() end

--- Returns the name of a layer by 1-based index.
---@param idx any
function LTileMap:getLayerName(idx) end

--- Returns the pixel offset of a layer.
---@param idx any
function LTileMap:getLayerOffset(idx) end

--- Returns the parallax factor of a layer.
---@param idx any
function LTileMap:getLayerParallax(idx) end

--- Returns layer visibility.
---@param idx any
function LTileMap:getLayerVisible(idx) end

--- Returns the map orientation as a string ("topdown", "sideview", "isometric", or "hexagonal").
function LTileMap:getOrientation() end

--- Returns the GID at (x, y) on the given layer (1-based).
---@param layer any
---@param x any
---@param y any
function LTileMap:getTile(layer, x, y) end

--- Returns tile dimensions as (width, height).
function LTileMap:getTileDimensions() end

--- Returns the tile height in pixels.
function LTileMap:getTileHeight() end

--- Returns a tileset by 1-based index, or nil if out of range.
---@param idx any
function LTileMap:getTileSet(idx) end

--- Returns the number of tilesets attached to this map.
function LTileMap:getTileSetCount() end

--- Returns the tile width in pixels.
function LTileMap:getTileWidth() end

--- Returns the viewport as (x, y, w, h) or nil if not set.
function LTileMap:getViewport() end

--- Returns true if the tile at (x, y) on layer is solid (1-based).
---@param layer any
---@param x any
---@param y any
function LTileMap:isSolid(layer, x, y) end

--- Registers a callback fired when any entity's tile GID matches `gid`.
---@param gid any
---@param func any
function LTileMap:onTileEnter(gid, func) end

--- Register a callback for when an entity exits a tile with the given GID.
---@param gid any
---@param func any
function LTileMap:onTileExit(gid, func) end

--- Register a callback for when an entity steps on a tile with the given GID.
---@param gid any
---@param func any
function LTileMap:onTileStep(gid, func) end

--- Returns true if any solid tile overlaps the given world-space rectangle on layer (1-based).
---@param layer any
---@param x any
---@param y any
---@param w any
---@param h any
function LTileMap:rectOverlapsSolid(layer, x, y, w, h) end

--- Renders the tile map to the screen at the given offset.
---@param ox? any
---@param oy? any
function LTileMap:render(ox, oy) end

--- Sets the RGBA tint color for a layer.
---@param idx any
---@param r any
---@param g any
---@param b any
---@param a any
function LTileMap:setLayerColor(idx, r, g, b, a) end

--- Sets the pixel offset for a layer.
---@param idx any
---@param ox any
---@param oy any
function LTileMap:setLayerOffset(idx, ox, oy) end

--- Sets the parallax scrolling factor for a layer.
---@param idx any
---@param px any
---@param py any
function LTileMap:setLayerParallax(idx, px, py) end

--- Shows or hides a tile layer by its 1-based index.
---@param idx any
---@param visible any
function LTileMap:setLayerVisible(idx, visible) end

--- Sets the map orientation from a string ("topdown", "sideview", "isometric", or "hexagonal").
---@param orientation any
function LTileMap:setOrientation(orientation) end

--- Sets the GID of a tile at (x, y) on the given layer (1-based).
---@param layer any
---@param x any
---@param y any
---@param gid any
function LTileMap:setTile(layer, x, y, gid) end

--- Sets a per-tile RGBA tint override (1-based layer, x, y).
---@param layer any
---@param x any
---@param y any
---@param r any
---@param g any
---@param b any
---@param a any
function LTileMap:setTileTint(layer, x, y, r, g, b, a) end

--- Sets the viewport rectangle for rendering culling.
---@param x any
---@param y any
---@param w any
---@param h any
function LTileMap:setViewport(x, y, w, h) end

--- Performs a swept AABB collision test against solid tiles on layer (1-based).
---@param layer any
---@param x any
---@param y any
---@param w any
---@param h any
---@param dx any
---@param dy any
function LTileMap:sweepRect(layer, x, y, w, h, dx, dy) end

--- Converts tile coordinates to world pixel coordinates (1-based input).
---@param tx any
---@param ty any
function LTileMap:tileToWorld(tx, ty) end

--- Converts the given layer into a 2D navigation grid.
---@param layer any
---@param gids_tbl any
function LTileMap:toNavGrid(layer, gids_tbl) end

--- Returns the type name of this object.
function LTileMap:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTileMap:typeOf(name) end

--- Advances tile animation timers by dt seconds.
---@param dt any
function LTileMap:update(dt) end

--- Converts world pixel coordinates to tile coordinates.
---@param wx any
---@param wy any
function LTileMap:worldToTile(wx, wy) end

--- Lua-side wrapper around a [`TileSet`].
---@class LTileSet
LTileSet = {}

--- Returns the animation frames for a 1-based local tile ID as a table of {tileid, duration}, or nil.
---@param tile_id any
function LTileSet:getAnimation(tile_id) end

--- Looks up the 1-based local tile ID for a 4-bit cardinal autotile bitmask, or nil.
---@param type_name any
---@param bitmask any
function LTileSet:getAutoTileId(type_name, bitmask) end

--- Looks up the 1-based local tile ID for an 8-bit directional autotile bitmask, or nil.
---@param type_name any
---@param bitmask any
function LTileSet:getAutoTileId8(type_name, bitmask) end

--- Returns the number of tile columns in the atlas texture.
function LTileSet:getColumns() end

--- Returns the first global ID assigned to this tileset.
function LTileSet:getFirstGid() end

--- Returns the margin in pixels around the edges of the atlas.
function LTileSet:getMargin() end

--- Computes the atlas source rectangle for a 1-based local tile ID.
---@param tile_id any
function LTileSet:getQuad(tile_id) end

--- Returns the spacing in pixels between tiles in the atlas.
function LTileSet:getSpacing() end

--- Returns the total number of tiles in this tileset.
function LTileSet:getTileCount() end

--- Returns the tile dimensions as (width, height).
function LTileSet:getTileDimensions() end

--- Returns the height of a single tile in pixels.
function LTileSet:getTileHeight() end

--- Returns the width of a single tile in pixels.
function LTileSet:getTileWidth() end

--- Returns whether a 1-based local tile ID is solid.
---@param tile_id any
function LTileSet:isSolid(tile_id) end

--- Sets the animation frames for a 1-based local tile ID from a table of {tileid, duration}.
---@param tile_id any
---@param frames any
function LTileSet:setAnimation(tile_id, frames) end

--- Registers a 4-bit cardinal autotile rule. tileId is 1-based.
---@param type_name any
---@param bitmask any
---@param tile_id any
function LTileSet:setAutoTileRule(type_name, bitmask, tile_id) end

--- Registers an 8-bit directional autotile rule. tileId is 1-based.
---@param type_name any
---@param bitmask any
---@param tile_id any
function LTileSet:setAutoTileRule8(type_name, bitmask, tile_id) end

--- Sets whether a 1-based local tile ID is solid for collision purposes.
---@param tile_id any
---@param solid any
function LTileSet:setSolid(tile_id, solid) end

--- Returns the type name of this object.
function LTileSet:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTileSet:typeOf(name) end

--- Parses an LDtk JSON export string and returns a TileMap.
---@param json_str any
---@param level_name? any
lurek.tilemap.fromLDtk = function(json_str, level_name) end

--- Converts screen position back to axial hex coordinates (pointy-top layout).
---@param sx any
---@param sy any
---@param size any
lurek.tilemap.fromScreenHex = function(sx, sy, size) end

--- Converts screen position back to tile coordinates for diamond isometric projection.
---@param sx any
---@param sy any
---@param tw any
---@param th any
lurek.tilemap.fromScreenIso = function(sx, sy, tw, th) end

--- Returns all hex cells within radius distance (filled hex circle) as a table.
---@param q any
---@param r any
---@param radius any
lurek.tilemap.hexArea = function(q, r, radius) end

--- Returns the hex distance between two axial coordinates.
---@param q1 any
---@param r1 any
---@param q2 any
---@param r2 any
lurek.tilemap.hexDistance = function(q1, r1, q2, r2) end

--- Returns all hex cells along a line between two axial coordinates as a table.
---@param q1 any
---@param r1 any
---@param q2 any
---@param r2 any
lurek.tilemap.hexLine = function(q1, r1, q2, r2) end

--- Returns the six axial neighbor coordinates as a table of {q, r} pairs.
---@param q any
---@param r any
lurek.tilemap.hexNeighbors = function(q, r) end

--- Reflects hex coordinates across an axis through the center.
---@param q any
---@param r any
---@param center_q any
---@param center_r any
---@param axis any
lurek.tilemap.hexReflect = function(q, r, center_q, center_r, axis) end

--- Returns all cells at exactly radius distance from (q, r) as a table.
---@param q any
---@param r any
---@param radius any
lurek.tilemap.hexRing = function(q, r, radius) end

--- Rotates hex coordinates around a center by steps x 60 degrees clockwise.
---@param q any
---@param r any
---@param center_q any
---@param center_r any
---@param steps any
lurek.tilemap.hexRotate = function(q, r, center_q, center_r, steps) end

--- Rounds fractional axial coordinates to the nearest hex cell.
---@param q any
---@param r any
lurek.tilemap.hexRound = function(q, r) end

--- Returns all hex cells from center outward to radius, ring by ring, as a table.
---@param q any
---@param r any
---@param radius any
lurek.tilemap.hexSpiral = function(q, r, radius) end

--- Snaps an angle (in radians) to the nearest isometric direction (1-4).
---@param angle any
lurek.tilemap.isoDirectionFromAngle = function(angle) end

--- Returns the name of an isometric direction (1-4).
---@param direction any
lurek.tilemap.isoDirectionName = function(direction) end

--- Rotates an isometric direction (1-4) clockwise by steps.
---@param direction any
---@param steps any
lurek.tilemap.isoRotate = function(direction, steps) end

--- Parses a TMX XML string and returns a table with map metadata and layers.
---@param xml any
lurek.tilemap.loadTMX = function(xml) end

--- Creates a new AutoTileSheet with the given tile dimensions and layout.
---@param tile_w any
---@param tile_h any
---@param layout_str any
lurek.tilemap.newAutoTileSheet = function(tile_w, tile_h, layout_str) end

--- Creates a new ChunkMap with the given chunk size.
---@param chunk_size? any
lurek.tilemap.newChunkMap = function(chunk_size) end

--- Creates a new IsoMap with no levels.
lurek.tilemap.newIsoMap = function() end

--- Creates a LargeMapRenderer for chunk-level occlusion culling on maps > 200Ă—200 tiles.
---@param tile_w any
---@param tile_h any
lurek.tilemap.newLargeMapRenderer = function(tile_w, tile_h) end

--- Creates a new MapBlock with the given dimensions.
---@param width any
---@param height any
---@param layers? any
---@param segment_size? any
lurek.tilemap.newMapBlock = function(width, height, layers, segment_size) end

--- Creates a MapGen from a MapGroup, a preset name or dimensions, and a segment size.
lurek.tilemap.newMapGen = function() end

--- Creates a new empty MapGroup with the given name.
---@param name any
lurek.tilemap.newMapGroup = function(name) end

--- Creates a new empty MapScript procedural generation script.
lurek.tilemap.newMapScript = function() end

--- Creates a new TileMap with the given tile size and chunk size.
---@param tile_width any
---@param tile_height any
---@param chunk_size? any
lurek.tilemap.newTileMap = function(tile_width, tile_height, chunk_size) end

--- Creates a new TileSet with the given atlas layout parameters.
lurek.tilemap.newTileSet = function() end

--- Converts axial hex coordinates to screen position (pointy-top layout).
---@param q any
---@param r any
---@param size any
lurek.tilemap.toScreenHex = function(q, r, size) end

--- Converts tile coordinates to screen position using diamond isometric projection.
---@param tx any
---@param ty any
---@param tw any
---@param th any
lurek.tilemap.toScreenIso = function(tx, ty, tw, th) end

---@class lurek.time
lurek.time = {}

--- Lua-side wrapper around a [`Scheduler`] with per-event callback storage.
---@class LScheduler
LScheduler = {}

--- Schedules a callback to fire once after a delay.
---@param delay number Value for delay.
---@param callback function Callback function.
---@return number Returned integer.
function LScheduler:after(delay, callback) end

--- Schedules a callback to fire once after `n` frames.
---@param n integer Value for n.
---@param callback function Callback function.
---@return number Returned integer.
function LScheduler:afterFrames(n, callback) end

--- Schedules a named one-shot callback, replacing any existing event with the same name.
---@param name string Name value.
---@param delay number Value for delay.
---@param callback function Callback function.
---@return number Returned integer.
function LScheduler:afterNamed(name, delay, callback) end

--- Cancels a scheduled event by its numeric ID.
---@param id integer Object identifier.
---@return boolean Boolean result.
function LScheduler:cancel(id) end

--- Cancels all scheduled events and returns the count removed.
---@return number Returned integer.
function LScheduler:cancelAll() end

--- Cancels and removes a previously scheduled event identified by its string name assigned via `afterNamed` or `everyNamed`.
---@param name string The string name given when the event was scheduled
---@return boolean True if the named event existed and was cancelled
function LScheduler:cancelNamed(name) end

--- Schedules a callback to fire repeatedly at the given interval.
---@param interval number Value for interval.
---@param callback function Callback function.
---@param count integer|nil Value for count.
---@return number Returned integer.
function LScheduler:every(interval, callback, count) end

--- Schedules a callback to fire every `n` frames.
---@param n integer " frame interval
---@param func function " callback
---@param count integer|nil " repetitions (-1 = infinite, default)
---@return number " event ID
function LScheduler:everyFrames(n, func, count) end

--- Schedules a named repeating callback, replacing any existing event with the same name.
---@param name string Name value.
---@param interval number Value for interval.
---@param callback function Callback function.
---@param count integer|nil Value for count.
---@return number Returned integer.
function LScheduler:everyNamed(name, interval, callback, count) end

--- Returns the total number of currently active (not yet completed or cancelled) events in this scheduler instance.
---@return number The count of active scheduled events
function LScheduler:getCount() end

--- Returns the configured base interval in seconds for a repeating event, or nil if the event id is not recognised.
---@param id integer The event identifier to query
---@return number The interval in seconds, or nil if the event does not exist
function LScheduler:getInterval(id) end

--- Returns the number of seconds remaining until the specified event fires next, or nil if the event id is not recognised.
---@param id integer The event identifier to query
---@return number Seconds remaining, or nil if the event does not exist
function LScheduler:getRemaining(id) end

--- Returns the number of remaining repetitions for a limited-repeat event (created with `everyN`), or nil if the event id is not recognised or the event has unlimited repeats.
---@param id integer The event identifier to query
---@return number Remaining repetitions, or nil if not applicable
function LScheduler:getRepeatCount(id) end

--- Returns the current time-scale multiplier for this scheduler instance.
---@return number The active time-scale multiplier
function LScheduler:getTimeScale() end

--- Returns true if this scheduler has zero active events.
---@return boolean True if there are no active events
function LScheduler:isEmpty() end

--- Returns whether the given event is currently paused.
---@param id integer Object identifier.
---@return boolean Boolean result.
function LScheduler:isPaused(id) end

--- Checks whether the named scheduled event is currently in the paused state.
---@param name string The string name of the event to check
---@return boolean True if the named event is paused
function LScheduler:isPausedNamed(name) end

--- Pauses a scheduled event by its ID.
---@param id integer Object identifier.
---@return boolean Boolean result.
function LScheduler:pause(id) end

--- Temporarily suspends the named scheduled event so it stops accumulating time.
---@param name string The string name of the event to pause
---@return boolean True if the named event existed and was paused
function LScheduler:pauseNamed(name) end

--- Resets the countdown for a scheduled event back to its full configured interval, as if it had just been created.
---@param id integer The event identifier to reset
---@return boolean True if the event existed and was reset
function LScheduler:resetEvent(id) end

--- Resumes a paused event by its ID.
---@param id integer Object identifier.
---@return boolean Boolean result.
function LScheduler:resume(id) end

--- Resumes a previously paused named event so it continues accumulating time.
---@param name string The string name of the event to resume
---@return boolean True if the named event existed and was resumed
function LScheduler:resumeNamed(name) end

--- Modifies the repeat interval of an already-scheduled repeating event.
---@param id integer The event identifier to modify
---@param interval number The new interval in seconds
---@return boolean True if the event existed and its interval was changed
function LScheduler:setInterval(id, interval) end

--- Sets a time-scale multiplier that affects all events in this scheduler.
---@param scale number The time-scale multiplier (0.0 or greater)
---@return nil No return value.
function LScheduler:setTimeScale(scale) end

--- Returns the string type name of this userdata object.
---@return string The type name (e.g. "LScheduler", "LCamera", "LSignal")
function LScheduler:type() end

--- Checks whether this object matches the given type name.
---@param name string The type name to check against (e.g. "LScheduler", "Object")
---@return boolean True if this object matches the given type name
function LScheduler:typeOf(name) end

--- Advances all time-based events in this scheduler by `dt` seconds (scaled by the scheduler's time-scale multiplier).
---@param dt number Delta time in seconds since the last update call
---@return number The number of callbacks that were fired
function LScheduler:update(dt) end

--- Advances all frame-based events by one frame tick.
---@return number The number of callbacks that were fired
function LScheduler:updateFrames() end

--- Schedules a one-shot callback that fires after `delay` wall-clock seconds, completely unaffected by the engine's time scale or pause state.
---@param delay number Wall-clock seconds to wait before firing
---@param func function The Lua function to call when the deadline arrives
---@return nil No return value.
lurek.time.afterReal = function(delay, func) end

--- Creates a new Scheduler pre-loaded with a sequence of one-shot callbacks that fire in order with cumulative delays.
---@param steps table Array of {delay: number, func: function} entries
---@return LScheduler A new scheduler pre-loaded with the chained callbacks
lurek.time.chain = function(steps) end

--- Returns a rolling average of recent frame delta times in seconds.
---@return number Rolling average delta time in seconds
lurek.time.getAverageDelta = function() end

--- Returns the time elapsed since the previous frame in seconds.
---@return number Delta time in seconds for the current frame
lurek.time.getDelta = function() end

--- Returns the current instantaneous frames-per-second as measured by the engine clock.
---@return number The current FPS value
lurek.time.getFPS = function() end

--- Returns the total number of frames that have been rendered since the engine was initialised.
---@return number Total frame count since engine start
lurek.time.getFrameCount = function() end

--- Returns the high-resolution (microsecond-precision) elapsed time since engine start in seconds.
---@return number High-resolution elapsed seconds
lurek.time.getMicroTime = function() end

--- Returns the fixed timestep interval used by the `process_physics` callback loop, in seconds.
---@return number The fixed physics timestep in seconds
lurek.time.getPhysicsDelta = function() end

--- Returns the maximum number of physics simulation sub-steps that the engine will perform in a single frame.
---@return number The maximum physics sub-steps per frame
lurek.time.getPhysicsMaxSteps = function() end

--- Returns the exponentially smoothed frame delta time in seconds.
---@return number The smoothed delta time in seconds
lurek.time.getSmoothedDelta = function() end

--- Returns the total wall-clock time that has elapsed since the engine was initialised, in seconds.
---@return number Total elapsed seconds since engine start
lurek.time.getTime = function() end

--- Creates and returns a new independent Scheduler userdata object for managing timed and frame-based callbacks.
---@return LScheduler A new scheduler instance
lurek.time.newScheduler = function() end

--- Sets the fixed timestep interval for the `process_physics` callback loop, in seconds.
---@param dt number The desired fixed timestep in seconds
---@return nil No return value.
lurek.time.setPhysicsDelta = function(dt) end

--- Sets the maximum number of physics simulation sub-steps allowed per frame.
---@param n integer The desired maximum sub-step count (clamped to 1-64)
---@return nil No return value.
lurek.time.setPhysicsMaxSteps = function(n) end

--- Sets the exponential moving-average smoothing factor (alpha) used by `getSmoothedDelta`.
---@param alpha number Smoothing factor between 0.01 (very smooth) and 1.0 (raw)
---@return nil No return value.
lurek.time.setSmoothingFactor = function(alpha) end

--- Blocks the current thread for the specified number of seconds using an OS-level sleep.
---@param seconds number Duration to sleep in seconds
---@return nil No return value.
lurek.time.sleep = function(seconds) end

--- Manually advances the engine timer by one frame tick and returns the resulting delta time.
---@return number The delta time for the stepped frame
lurek.time.step = function() end

lurek.time.tickRealTimers = function() end

lurek.time.tickWaits = function() end

--- Yields the current Lua coroutine until at least `frames` engine frames have elapsed.
---@param frames integer Number of engine frames to wait
---@return nil No return value.
lurek.time.waitFrames = function(frames) end

--- Yields the current Lua coroutine for at least `seconds` wall-clock seconds.
---@param seconds number Minimum wall-clock seconds to wait
---@return nil No return value.
lurek.time.waitSeconds = function(seconds) end

---@class lurek.tween
lurek.tween = {}

--- Lua-side spring handle: wraps [`SpringSystem`] and a registry reference to the target table.
---@class LSpring
LSpring = {}

--- Stops the spring. The engine will drop it on the next `update(dt)` call.
function LSpring:cancel() end

--- Returns the current interpolated position for the named field, or `nil`.
---@param field any
function LSpring:getPosition(field) end

--- Returns `true` if the spring has not been cancelled or settled.
function LSpring:isActive() end

--- Returns `true` when all spring axes have converged within `precision`.
function LSpring:isSettled() end

--- Updates the damping coefficient on all axes.
---@param value any
function LSpring:setDamping(value) end

--- Updates the stiffness constant on all axes.
---@param value any
function LSpring:setStiffness(value) end

--- Updates target values for all fields present in `fields_table`.
---@param fields_tbl any
function LSpring:setTarget(fields_tbl) end

--- Returns the type name of this object.
function LSpring:type() end

--- Returns true if this object is of the given type.
---@param name any
function LSpring:typeOf(name) end

--- Advances the spring by `dt` seconds and writes positions to the target table.
---@param dt any
function LSpring:update(dt) end

--- A managed interpolation from start to end values over time.
---@class LTween
LTween = {}

--- Cancels this tween immediately; fires the `onCancel` callback if set.
---@param ud any
LTween.cancel = function(ud) end

--- Returns raw 0..1 playback progress (not eased, not accounting for yoyo).
function LTween:getProgress() end

--- Returns true if the tween is still running (not completed or cancelled).
function LTween:isActive() end

--- Sets a callback called when the tween is cancelled. Returns self.
---@param ud any
---@param f any
LTween.onCancel = function(ud, f) end

--- Sets a callback to fire when the tween finishes all cycles. Returns self for chaining.
---@param ud any
---@param f any
LTween.onComplete = function(ud, f) end

--- Sets a callback called every tick with the current eased `t` (0..=1). Returns self.
---@param ud any
---@param f any
LTween.onUpdate = function(ud, f) end

--- Pauses this tween; time stops advancing but the tween is not cancelled.
function LTween:pause() end

--- Resumes a paused tween, continuing from the position where it was paused.
function LTween:resume() end

--- Sets the number of extra play cycles after the first (0 = play once, -1 = infinite).
---@param n any
function LTween:setRepeat(n) end

--- Enables or disables yoyo (ping-pong) on each repeat cycle.
---@param enabled any
function LTween:setYoyo(enabled) end

--- Returns the type name of this object.
function LTween:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTween:typeOf(name) end

--- A group of animations that run simultaneously over the same duration.
---@class LTweenParallel
LTweenParallel = {}

--- Adds an existing LuaTween to the parallel group; marks the tween as owned.
---@param par_ud any
---@param tw_ud any
LTweenParallel.add = function(par_ud, tw_ud) end

--- Cancels the parallel group immediately.
function LTweenParallel:cancel() end

--- Returns true if the parallel is running and not yet complete.
function LTweenParallel:isActive() end

--- Sets a callback fired when all child tweens finish. Returns self.
---@param ud any
---@param f any
LTweenParallel.onComplete = function(ud, f) end

--- Marks the parallel as active. Returns self.
---@param ud any
LTweenParallel.start = function(ud) end

--- Creates and adds an inline tween entry to the parallel group. Returns self.
LTweenParallel.tween = function() end

--- Returns the type name of this object.
function LTweenParallel:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTweenParallel:typeOf(name) end

--- A chained sequence of animations that run one after another.
---@class LTweenSequence
LTweenSequence = {}

--- Appends an immediate callback step. Returns self.
---@param ud any
---@param f any
LTweenSequence.callback = function(ud, f) end

--- Cancels the sequence and stops all pending steps.
function LTweenSequence:cancel() end

--- Appends a delay step that waits `seconds` before proceeding. Returns self.
---@param ud any
---@param seconds any
---@param cb? any
LTweenSequence.delay = function(ud, seconds, cb) end

--- Returns true if the sequence has been started and has not yet completed.
function LTweenSequence:isActive() end

--- Sets a callback fired when all steps complete. Returns self.
---@param ud any
---@param f any
LTweenSequence.onComplete = function(ud, f) end

--- Marks the sequence as active so `lurek.tween.update(dt)` begins ticking it. Returns self.
---@param ud any
LTweenSequence.start = function(ud) end

--- Appends a tween step: animates `fields` on `target` over `duration`. Returns self.
LTweenSequence.tween = function() end

--- Returns the type name of this object.
function LTweenSequence:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTweenSequence:typeOf(name) end

--- Lua-side wrapper around the pure-Rust [`TweenState`] timing core.
---@class LTweenState
---@field paused boolean  whether the tween is currently paused
LTweenState = {}

--- Returns whether the tween state has completed.
function LTweenState:isComplete() end

--- Interpolates from `start` to `finish` using the eased tween progress.
---@param start any
---@param finish any
function LTweenState:lerp(start, finish) end

--- Resets the tween state to elapsed time zero.
function LTweenState:reset() end

--- Returns the raw 0..1 playback progress.
function LTweenState:t() end

--- Advances the tween state by `dt` seconds.
---@param dt any
function LTweenState:tick(dt) end

--- Returns the type name of this object.
function LTweenState:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTweenState:typeOf(name) end

--- Cancels all active tweens, sequences, parallels, and springs immediately.
lurek.tween.cancelAll = function() end

--- Creates a no-op tween that waits `seconds`, then optionally calls `callback`.
---@param seconds any
---@param cb? any
lurek.tween.delay = function(seconds, cb) end

--- Returns the number of currently active tween objects (tweens + seqs + pars).
lurek.tween.getActiveCount = function() end

--- Returns a list of all available easing names (built-in + custom).
lurek.tween.getEasingNames = function() end

--- Creates a standalone tween timing state without registering it with the engine.
---@param duration any
---@param easing? any
lurek.tween.newState = function(duration, easing) end

--- Creates an empty TweenParallel. Add entries with :tween() or :add(tween),
lurek.tween.parallel = function() end

--- Registers a custom easing function under `name`. `fn(t)` receives 0..1, returns 0..1.
---@param name any
---@param f any
lurek.tween.registerEasing = function(name, f) end

--- Creates an empty TweenSequence. Add steps with :tween(), :delay(), :callback(),
lurek.tween.sequence = function() end

--- Creates a physics-based spring animation that drives named fields on `target_table`
---@param target_tbl any
---@param fields_tbl any
---@param opts? any
lurek.tween.spring = function(target_tbl, fields_tbl, opts) end

--- Sugar for `tween()` with `target` first â€” natural read order.
lurek.tween.to = function() end

--- Creates a new property tween and registers it for automatic updating.
lurek.tween.tween = function() end

--- Advances all active tweens, sequences, and parallels by `dt` seconds.
---@param dt any
lurek.tween.update = function(dt) end

---@class lurek.ui
lurek.ui = {}

--- Adds Accordion-specific methods (1-based sections in Lua).
---@class LAccordion
LAccordion = {}

--- Adds a section entry to this Accordion widget.
---@param title any
---@param content_idx? any
function LAccordion:addSection(title, content_idx) end

--- Returns the section count of this Accordion widget.
function LAccordion:getSectionCount() end

--- Returns the section title of this Accordion widget.
---@param section_idx any
function LAccordion:getSectionTitle(section_idx) end

--- Returns true if exclusive is enabled for this Accordion widget.
function LAccordion:isExclusive() end

--- Returns true if section expanded is enabled for this Accordion widget.
---@param section_idx any
function LAccordion:isSectionExpanded(section_idx) end

--- Sets the exclusive for this Accordion widget.
---@param v any
function LAccordion:setExclusive(v) end

--- Toggles the expanded/collapsed status of an Accordion section.
---@param section_idx any
function LAccordion:toggleSection(section_idx) end

--- Lua wrapper for a stacked area chart renderer.
---@class LAreaChart
LAreaChart = {}

--- Adds a stacked layer with values and colour.
---@param name any
---@param vals_tbl any
---@param r any
---@param g any
---@param b any
function LAreaChart:addLayer(name, vals_tbl, r, g, b) end

--- Renders the area chart into an existing ImageData.
function LAreaChart:drawToImage() end

--- Sets the maximum Y value for axis scaling.
---@param v any
function LAreaChart:setYMax(v) end

--- Returns the type name of this object.
function LAreaChart:type() end

--- Returns true if this object is of the given type.
---@param name any
function LAreaChart:typeOf(name) end

--- Adds Badge-specific methods to a widget table.
---@class LBadge
LBadge = {}

--- Returns the raw count of this Badge widget.
function LBadge:getCount() end

--- Returns the display text of this Badge widget, e.g. "99+" when over the max.
function LBadge:getDisplayText() end

--- Sets the count displayed on this Badge widget.
---@param count any
function LBadge:setCount(count) end

--- Lua wrapper for a grouped bar chart renderer.
---@class LBarChart
LBarChart = {}

--- Adds a category group with per-series values.
---@param label any
---@param vals_tbl any
function LBarChart:addCategory(label, vals_tbl) end

--- Adds a bar series with a name and colour.
---@param name any
---@param r any
---@param g any
---@param b any
function LBarChart:addSeries(name, r, g, b) end

--- Renders the bar chart into an existing ImageData.
function LBarChart:drawToImage() end

--- Returns the type name of this object.
function LBarChart:type() end

--- Returns true if this object is of the given type.
---@param name any
function LBarChart:typeOf(name) end

--- Adds Button-specific methods to a widget table.
---@class LButton
LButton = {}

--- Returns the text of this Button widget.
function LButton:getText() end

--- Sets the text for this Button widget.
---@param text any
function LButton:setText(text) end

--- Adds CheckBox-specific methods to a widget table.
---@class LCheckbox
LCheckbox = {}

--- Returns the text of this Checkbox widget.
function LCheckbox:getText() end

--- Returns true if checked is enabled for this Checkbox widget.
function LCheckbox:isChecked() end

--- Sets the checked for this Checkbox widget.
---@param checked any
function LCheckbox:setChecked(checked) end

--- Sets the text for this Checkbox widget.
---@param text any
function LCheckbox:setText(text) end

--- Adds ColorPicker-specific methods.
---@class LColorPicker
LColorPicker = {}

--- Returns the color of this Color_Picker widget.
function LColorPicker:getColor() end

--- Returns the color mode of this Color_Picker widget.
function LColorPicker:getColorMode() end

--- Returns the show alpha of this Color_Picker widget.
function LColorPicker:getShowAlpha() end

--- Sets the color for this Color_Picker widget.
---@param r any
---@param green any
---@param b any
---@param a? any
function LColorPicker:setColor(r, green, b, a) end

--- Sets the color mode for this Color_Picker widget.
---@param mode any
function LColorPicker:setColorMode(mode) end

--- Registers a callback invoked when this widget's value changes.
---@param f any
function LColorPicker:setOnChange(f) end

--- Sets the show alpha for this Color_Picker widget.
---@param v any
function LColorPicker:setShowAlpha(v) end

--- Adds ComboBox-specific methods (1-based indices in Lua).
---@class LComboBox
LComboBox = {}

--- Adds a item entry to this Combo_Box widget.
---@param text any
function LComboBox:addItem(text) end

--- Clears all items entries from this Combo_Box widget.
function LComboBox:clearItems() end

--- Returns the item of this Combo_Box widget.
---@param index any
function LComboBox:getItem(index) end

--- Returns the item count of this Combo_Box widget.
function LComboBox:getItemCount() end

--- Returns the selected index of this Combo_Box widget.
function LComboBox:getSelectedIndex() end

--- Returns the selected item of this Combo_Box widget.
function LComboBox:getSelectedItem() end

--- Removes the item from this Combo_Box widget.
---@param index any
function LComboBox:removeItem(index) end

--- Sets the selected index for this Combo_Box widget.
---@param index any
function LComboBox:setSelectedIndex(index) end

--- Adds Dialog-specific methods.
---@class LDialog
LDialog = {}

--- Adds a button entry to this Dialog widget.
---@param text any
---@param cb? any
function LDialog:addButton(text, cb) end

--- Closes and removes this dialog from the screen.
function LDialog:close() end

--- Returns the content of this Dialog widget.
function LDialog:getContent() end

--- Returns the title of this Dialog widget.
function LDialog:getTitle() end

--- Returns true if modal is enabled for this Dialog widget.
function LDialog:isModal() end

--- Returns true if open is enabled for this Dialog widget.
function LDialog:isOpen() end

--- Performs the open operation on this Dialog widget.
function LDialog:open() end

--- Sets the content for this Dialog widget.
---@param content_idx? any
function LDialog:setContent(content_idx) end

--- Sets the modal for this Dialog widget.
---@param v any
function LDialog:setModal(v) end

--- Registers a callback invoked when this dialog is closed.
---@param f any
function LDialog:setOnClose(f) end

--- Sets the title for this Dialog widget.
---@param title any
function LDialog:setTitle(title) end

--- Adds DockPanel-specific methods.
---@class LDockPanel
LDockPanel = {}

--- Performs the dock operation on this Dock_Panel widget.
---@param child_idx any
---@param side any
function LDockPanel:dock(child_idx, side) end

--- Returns the docked count of this Dock_Panel widget.
function LDockPanel:getDockedCount() end

--- Returns the split size of this Dock_Panel widget.
---@param side any
function LDockPanel:getSplitSize(side) end

--- Sets the split size for this Dock_Panel widget.
---@param side any
---@param size any
function LDockPanel:setSplitSize(side, size) end

--- Performs the undock operation on this Dock_Panel widget.
---@param child_idx any
function LDockPanel:undock(child_idx) end

--- Adds GUITable-specific methods (1-based rows/cols in Lua).
---@class LGuiTable
LGuiTable = {}

--- Adds a column entry to this Gui_Table widget.
---@param header any
---@param width? any
function LGuiTable:addColumn(header, width) end

--- Adds a row entry to this Gui_Table widget.
---@param cells any
function LGuiTable:addRow(cells) end

--- Returns the cell of this Gui_Table widget.
---@param row any
---@param col any
function LGuiTable:getCell(row, col) end

--- Returns the column count of this Gui_Table widget.
function LGuiTable:getColumnCount() end

--- Returns the row count of this Gui_Table widget.
function LGuiTable:getRowCount() end

--- Returns the selected row of this Gui_Table widget.
function LGuiTable:getSelectedRow() end

--- Returns true if sortable is enabled for this Gui_Table widget.
function LGuiTable:isSortable() end

--- Sets the cell for this Gui_Table widget.
---@param row any
---@param col any
---@param text any
function LGuiTable:setCell(row, col, text) end

--- Registers a callback invoked when a table row is selected.
---@param f any
function LGuiTable:setOnSelect(f) end

--- Sets the selected row for this Gui_Table widget.
---@param row? any
function LGuiTable:setSelectedRow(row) end

--- Sets the sortable for this Gui_Table widget.
---@param v any
function LGuiTable:setSortable(v) end

--- Adds GUIWindow-specific methods.
---@class LGuiWindow
LGuiWindow = {}

--- Returns the title of this Gui_Window widget.
function LGuiWindow:getTitle() end

--- Returns true if closeable is enabled for this Gui_Window widget.
function LGuiWindow:isCloseable() end

--- Returns true if draggable is enabled for this Gui_Window widget.
function LGuiWindow:isDraggable() end

--- Returns true if resizable is enabled for this Gui_Window widget.
function LGuiWindow:isResizable() end

--- Sets the closeable for this Gui_Window widget.
---@param v any
function LGuiWindow:setCloseable(v) end

--- Sets the draggable for this Gui_Window widget.
---@param v any
function LGuiWindow:setDraggable(v) end

--- Registers a callback invoked when this window is closed.
---@param f any
function LGuiWindow:setOnClose(f) end

--- Sets the resizable for this Gui_Window widget.
---@param v any
function LGuiWindow:setResizable(v) end

--- Sets the title for this Gui_Window widget.
---@param title any
function LGuiWindow:setTitle(title) end

--- Adds ImageWidget-specific methods.
---@class LImageWidget
LImageWidget = {}

--- Returns the scale mode of this Image_Widget widget.
function LImageWidget:getScaleMode() end

--- Returns the tint of this Image_Widget widget.
function LImageWidget:getTint() end

--- Sets the scale mode for this Image_Widget widget.
---@param mode any
function LImageWidget:setScaleMode(mode) end

--- Sets the tint for this Image_Widget widget.
---@param r any
---@param green any
---@param b any
---@param a? any
function LImageWidget:setTint(r, green, b, a) end

--- Adds Label-specific methods to a widget table.
---@class LLabel
LLabel = {}

--- Returns the text of this Label widget.
function LLabel:getText() end

--- Sets the text for this Label widget.
---@param text any
function LLabel:setText(text) end

--- Adds Layout-specific methods.
---@class LLayout
LLayout = {}

--- Returns the align of this Layout widget.
function LLayout:getAlign() end

--- Returns the direction of this Layout widget.
function LLayout:getDirection() end

--- Returns the justify of this Layout widget.
function LLayout:getJustify() end

--- Returns the spacing of this Layout widget.
function LLayout:getSpacing() end

--- Returns the wrap of this Layout widget.
function LLayout:getWrap() end

--- Sets the align for this Layout widget.
---@param align any
function LLayout:setAlign(align) end

--- Sets the columns for this Layout widget.
---@param n any
function LLayout:setColumns(n) end

--- Sets the direction for this Layout widget.
---@param dir any
function LLayout:setDirection(dir) end

--- Sets the justify for this Layout widget.
---@param justify any
function LLayout:setJustify(justify) end

--- Sets the spacing for this Layout widget.
---@param spacing any
function LLayout:setSpacing(spacing) end

--- Sets the wrap for this Layout widget.
---@param wrap any
function LLayout:setWrap(wrap) end

--- Lua wrapper for a line chart renderer.
---@class LLineChart
LLineChart = {}

--- Adds a named data series to the chart.
---@param name any
---@param pts_tbl any
---@param r any
---@param g any
---@param b any
function LLineChart:addSeries(name, pts_tbl, r, g, b) end

--- Renders the line chart into an existing ImageData.
function LLineChart:drawToImage() end

--- Sets the maximum X value for axis scaling.
---@param v any
function LLineChart:setXMax(v) end

--- Sets the maximum Y value for axis scaling.
---@param v any
function LLineChart:setYMax(v) end

--- Returns the type name of this object.
function LLineChart:type() end

--- Returns true if this object is of the given type.
---@param name any
function LLineChart:typeOf(name) end

--- Adds ListBox-specific methods (1-based indices in Lua).
---@class LListBox
LListBox = {}

--- Adds a item entry to this List_Box widget.
---@param text any
function LListBox:addItem(text) end

--- Clears all items entries from this List_Box widget.
function LListBox:clearItems() end

--- Returns the item of this List_Box widget.
---@param index any
function LListBox:getItem(index) end

--- Returns the item count of this List_Box widget.
function LListBox:getItemCount() end

--- Returns the selected index of this List_Box widget.
function LListBox:getSelectedIndex() end

--- Removes the item from this List_Box widget.
---@param index any
function LListBox:removeItem(index) end

--- Sets the item height for this List_Box widget.
---@param h any
function LListBox:setItemHeight(h) end

--- Sets the selected index for this List_Box widget.
---@param index any
function LListBox:setSelectedIndex(index) end

--- Adds MenuBar-specific methods.
---@class LMenuBar
LMenuBar = {}

--- Adds a menu entry to this Menu_Bar widget.
---@param menu_idx any
function LMenuBar:addMenu(menu_idx) end

--- Returns the menu count of this Menu_Bar widget.
function LMenuBar:getMenuCount() end

--- Returns the menus of this Menu_Bar widget.
function LMenuBar:getMenus() end

--- Removes the menu from this Menu_Bar widget.
---@param menu_idx any
function LMenuBar:removeMenu(menu_idx) end

--- Adds MenuItem-specific methods.
---@class LMenuItem
LMenuItem = {}

--- Adds a sub item entry to this Menu_Item widget.
---@param child_idx any
function LMenuItem:addSubItem(child_idx) end

--- Returns the shortcut of this Menu_Item widget.
function LMenuItem:getShortcut() end

--- Returns the sub items of this Menu_Item widget.
function LMenuItem:getSubItems() end

--- Returns the text of this Menu_Item widget.
function LMenuItem:getText() end

--- Returns true if checked is enabled for this Menu_Item widget.
function LMenuItem:isChecked() end

--- Sets the checked for this Menu_Item widget.
---@param v any
function LMenuItem:setChecked(v) end

--- Registers a callback invoked when this menu item is clicked.
---@param f any
function LMenuItem:setOnClick(f) end

--- Sets the shortcut for this Menu_Item widget.
---@param shortcut any
function LMenuItem:setShortcut(shortcut) end

--- Sets the text for this Menu_Item widget.
---@param text any
function LMenuItem:setText(text) end

--- Adds NinePatch-specific methods.
---@class LNinePatch
LNinePatch = {}

--- Returns the image dimensions of this Nine_Patch widget.
function LNinePatch:getImageDimensions() end

--- Returns the insets of this Nine_Patch widget.
function LNinePatch:getInsets() end

--- Returns the slices of this Nine_Patch widget.
function LNinePatch:getSlices() end

--- Sets the image dimensions for this Nine_Patch widget.
---@param w any
---@param h any
function LNinePatch:setImageDimensions(w, h) end

--- Sets the insets for this Nine_Patch widget.
---@param left any
---@param top any
---@param right any
---@param bottom any
function LNinePatch:setInsets(left, top, right, bottom) end

--- Adds Panel-specific methods.
---@class LPanel
LPanel = {}

--- Returns the title of this Panel widget.
function LPanel:getTitle() end

--- Sets the scrollable for this Panel widget.
---@param scrollable any
function LPanel:setScrollable(scrollable) end

--- Sets the title for this Panel widget.
---@param title any
function LPanel:setTitle(title) end

--- Lua wrapper for a pie chart renderer.
---@class LPieChart
LPieChart = {}

--- Adds a labelled pie segment.
---@param label any
---@param value any
---@param r any
---@param g any
---@param b any
function LPieChart:addSegment(label, value, r, g, b) end

--- Renders the pie chart into an existing ImageData.
function LPieChart:drawToImage() end

--- Returns the type name of this object.
function LPieChart:type() end

--- Returns true if this object is of the given type.
---@param name any
function LPieChart:typeOf(name) end

--- Adds ProgressBar-specific methods to a widget table.
---@class LProgressBar
LProgressBar = {}

--- Returns the max of this Progress_Bar widget.
function LProgressBar:getMax() end

--- Returns the min of this Progress_Bar widget.
function LProgressBar:getMin() end

--- Returns the progress of this Progress_Bar widget.
function LProgressBar:getProgress() end

--- Returns the value of this Progress_Bar widget.
function LProgressBar:getValue() end

--- Sets the range for this Progress_Bar widget.
---@param min any
---@param max any
function LProgressBar:setRange(min, max) end

--- Sets the value for this Progress_Bar widget.
---@param v any
function LProgressBar:setValue(v) end

--- Adds RadioButton-specific methods.
---@class LRadioButton
LRadioButton = {}

--- Returns the group of this Radio_Button widget.
function LRadioButton:getGroup() end

--- Returns the text of this Radio_Button widget.
function LRadioButton:getText() end

--- Returns true if selected is enabled for this Radio_Button widget.
function LRadioButton:isSelected() end

--- Sets the group for this Radio_Button widget.
---@param group any
function LRadioButton:setGroup(group) end

--- Registers a callback invoked when this widget's value changes.
---@param f any
function LRadioButton:setOnChange(f) end

--- Sets the selected for this Radio_Button widget.
---@param v any
function LRadioButton:setSelected(v) end

--- Sets the text for this Radio_Button widget.
---@param text any
function LRadioButton:setText(text) end

--- Lua wrapper for a scatter plot renderer.
---@class LScatterPlot
LScatterPlot = {}

--- Adds a named data series.
---@param name any
---@param pts_tbl any
---@param r any
---@param g any
---@param b any
function LScatterPlot:addSeries(name, pts_tbl, r, g, b) end

--- Renders the scatter plot into an existing ImageData.
function LScatterPlot:drawToImage() end

--- Sets the X-axis data range.
---@param mn any
---@param mx any
function LScatterPlot:setXRange(mn, mx) end

--- Sets the Y-axis data range.
---@param mn any
---@param mx any
function LScatterPlot:setYRange(mn, mx) end

--- Returns the type name of this object.
function LScatterPlot:type() end

--- Returns true if this object is of the given type.
---@param name any
function LScatterPlot:typeOf(name) end

--- Adds ScrollBar-specific methods.
---@class LScrollBar
LScrollBar = {}

--- Returns the content size of this Scroll_Bar widget.
function LScrollBar:getContentSize() end

--- Returns the scroll position of this Scroll_Bar widget.
function LScrollBar:getScrollPosition() end

--- Returns the view size of this Scroll_Bar widget.
function LScrollBar:getViewSize() end

--- Returns true if vertical is enabled for this Scroll_Bar widget.
function LScrollBar:isVertical() end

--- Sets the content size for this Scroll_Bar widget.
---@param v any
function LScrollBar:setContentSize(v) end

--- Registers a callback invoked when this widget's value changes.
---@param f any
function LScrollBar:setOnChange(f) end

--- Sets the scroll position for this Scroll_Bar widget.
---@param v any
function LScrollBar:setScrollPosition(v) end

--- Sets the view size for this Scroll_Bar widget.
---@param v any
function LScrollBar:setViewSize(v) end

--- Adds ScrollPanel-specific methods.
---@class LScrollPanel
LScrollPanel = {}

--- Returns the content size of this Scroll_Panel widget.
function LScrollPanel:getContentSize() end

--- Returns the max scroll of this Scroll_Panel widget.
function LScrollPanel:getMaxScroll() end

--- Returns the scroll position of this Scroll_Panel widget.
function LScrollPanel:getScrollPosition() end

--- Returns the scroll speed of this Scroll_Panel widget.
function LScrollPanel:getScrollSpeed() end

--- Sets the content size for this Scroll_Panel widget.
---@param w any
---@param h any
function LScrollPanel:setContentSize(w, h) end

--- Sets the scroll position for this Scroll_Panel widget.
---@param x any
---@param y any
function LScrollPanel:setScrollPosition(x, y) end

--- Sets the scroll speed for this Scroll_Panel widget.
---@param speed any
function LScrollPanel:setScrollSpeed(speed) end

--- Adds Separator-specific methods.
---@class LSeparator
LSeparator = {}

--- Returns the thickness of this Separator widget.
function LSeparator:getThickness() end

--- Returns true if vertical is enabled for this Separator widget.
function LSeparator:isVertical() end

--- Sets the thickness for this Separator widget.
---@param thickness any
function LSeparator:setThickness(thickness) end

--- Sets the vertical for this Separator widget.
---@param v any
function LSeparator:setVertical(v) end

--- Adds Slider-specific methods to a widget table.
---@class LSlider
LSlider = {}

--- Returns the max of this Slider widget.
function LSlider:getMax() end

--- Returns the min of this Slider widget.
function LSlider:getMin() end

--- Returns the value of this Slider widget.
function LSlider:getValue() end

--- Sets the range for this Slider widget.
---@param min any
---@param max any
function LSlider:setRange(min, max) end

--- Sets the step for this Slider widget.
---@param step any
function LSlider:setStep(step) end

--- Sets the value for this Slider widget.
---@param v any
function LSlider:setValue(v) end

--- Adds SpinBox-specific methods to a widget table.
---@class LSpinBox
LSpinBox = {}

--- Decrements the value by one step.
function LSpinBox:decrement() end

--- Returns the current value of this SpinBox widget.
function LSpinBox:getValue() end

--- Increments the value by one step.
function LSpinBox:increment() end

--- Sets the valid range for this SpinBox widget.
---@param min any
---@param max any
function LSpinBox:setRange(min, max) end

--- Sets the increment step for this SpinBox widget.
---@param step any
function LSpinBox:setStep(step) end

--- Sets the value for this SpinBox widget.
---@param v any
function LSpinBox:setValue(v) end

--- Adds SplitPanel-specific methods.
---@class LSplitPanel
LSplitPanel = {}

--- Returns the first child of this Split_Panel widget.
function LSplitPanel:getFirstChild() end

--- Returns the min panel size of this Split_Panel widget.
function LSplitPanel:getMinPanelSize() end

--- Returns the orientation of this Split_Panel widget.
function LSplitPanel:getOrientation() end

--- Returns the second child of this Split_Panel widget.
function LSplitPanel:getSecondChild() end

--- Returns the split position of this Split_Panel widget.
function LSplitPanel:getSplitPosition() end

--- Sets the first child for this Split_Panel widget.
---@param child_idx any
function LSplitPanel:setFirstChild(child_idx) end

--- Sets the min panel size for this Split_Panel widget.
---@param v any
function LSplitPanel:setMinPanelSize(v) end

--- Sets the orientation for this Split_Panel widget.
---@param v any
function LSplitPanel:setOrientation(v) end

--- Sets the second child for this Split_Panel widget.
---@param child_idx any
function LSplitPanel:setSecondChild(child_idx) end

--- Sets the split position for this Split_Panel widget.
---@param v any
function LSplitPanel:setSplitPosition(v) end

--- Adds StatusBar-specific methods.
---@class LStatusBar
LStatusBar = {}

--- Adds a section entry to this Status_Bar widget.
---@param text any
---@param width? any
function LStatusBar:addSection(text, width) end

--- Returns the section count of this Status_Bar widget.
function LStatusBar:getSectionCount() end

--- Returns the section text of this Status_Bar widget.
---@param section_idx any
function LStatusBar:getSectionText(section_idx) end

--- Resizes the section list for this Status_Bar widget.
---@param count any
function LStatusBar:setSectionCount(count) end

--- Sets the section text for this Status_Bar widget.
---@param section_idx any
---@param text any
function LStatusBar:setSectionText(section_idx, text) end

--- Compatibility shim for assigning a widget to a section.
---@param section_idx any
---@param widget any
function LStatusBar:setSectionWidget(section_idx, widget) end

--- Adds Switch-specific methods to a widget table.
---@class LSwitch
LSwitch = {}

--- Returns the on/off state of this Switch widget.
function LSwitch:isOn() end

--- Sets the on/off state of this Switch widget.
---@param on any
function LSwitch:setOn(on) end

--- Toggles the on/off state of this Switch widget.
function LSwitch:toggle() end

--- Adds TabBar-specific methods (1-based indices in Lua).
---@class LTabBar
LTabBar = {}

--- Adds a tab entry to this Tab_Bar widget.
---@param label any
function LTabBar:addTab(label) end

--- Returns the active tab of this Tab_Bar widget.
function LTabBar:getActiveTab() end

--- Returns the tab of this Tab_Bar widget.
---@param index any
function LTabBar:getTab(index) end

--- Returns the tab count of this Tab_Bar widget.
function LTabBar:getTabCount() end

--- Removes the tab from this Tab_Bar widget.
---@param index any
function LTabBar:removeTab(index) end

--- Sets the active tab for this Tab_Bar widget.
---@param index any
function LTabBar:setActiveTab(index) end

--- Adds TextInput-specific methods to a widget table.
---@class LTextInput
LTextInput = {}

--- Returns the cursor position of this Text_Input widget.
function LTextInput:getCursorPosition() end

--- Returns the placeholder of this Text_Input widget.
function LTextInput:getPlaceholder() end

--- Returns the text of this Text_Input widget.
function LTextInput:getText() end

--- Returns true if focused is enabled for this Text_Input widget.
function LTextInput:isFocused() end

--- Sets the max length for this Text_Input widget.
---@param n any
function LTextInput:setMaxLength(n) end

--- Sets the placeholder for this Text_Input widget.
---@param text any
function LTextInput:setPlaceholder(text) end

--- Sets the text for this Text_Input widget.
---@param text any
function LTextInput:setText(text) end

--- Lua-side wrapper around a GUI [`Theme`].
---@class LTheme
LTheme = {}

--- Sets a style for a (widget_type, state) pair.
---@param widget_type any
---@param state any
---@param style_table any
function LTheme:setStyle(widget_type, state, style_table) end

--- Returns the type name of this object.
function LTheme:type() end

--- Returns true if this object is of the given type.
---@param name any
function LTheme:typeOf(name) end

--- Adds Toast-specific methods.
---@class LToast
LToast = {}

--- Returns the duration of this Toast widget.
function LToast:getDuration() end

--- Returns the message of this Toast widget.
function LToast:getMessage() end

--- Returns the progress of this Toast widget.
function LToast:getProgress() end

--- Returns true if expired is enabled for this Toast widget.
function LToast:isExpired() end

--- Sets the duration for this Toast widget.
---@param d any
function LToast:setDuration(d) end

--- Sets the message for this Toast widget.
---@param msg any
function LToast:setMessage(msg) end

--- Adds Toolbar-specific methods.
---@class LToolbar
LToolbar = {}

--- Adds a button entry to this Toolbar widget.
---@param id any
---@param tooltip? any
function LToolbar:addButton(id, tooltip) end

--- Adds a separator entry to this Toolbar widget.
function LToolbar:addSeparator() end

--- Adds a spacer entry to this Toolbar widget.
---@param size? any
function LToolbar:addSpacer(size) end

--- Returns the button of this Toolbar widget.
---@param id any
function LToolbar:getButton(id) end

--- Returns the orientation of this Toolbar widget.
function LToolbar:getOrientation() end

--- Returns true if button toggled is enabled for this Toolbar widget.
---@param id any
function LToolbar:isButtonToggled(id) end

--- Sets the button enabled for this Toolbar widget.
---@param id any
---@param enabled any
function LToolbar:setButtonEnabled(id, enabled) end

--- Sets the button toggled for this Toolbar widget.
---@param id any
---@param toggled any
function LToolbar:setButtonToggled(id, toggled) end

--- Sets the orientation for this Toolbar widget.
---@param v any
function LToolbar:setOrientation(v) end

--- Adds TooltipPanel-specific methods.
---@class LTooltipPanel
LTooltipPanel = {}

--- Returns the delay of this Tooltip_Panel widget.
function LTooltipPanel:getDelay() end

--- Returns the target of this Tooltip_Panel widget.
function LTooltipPanel:getTarget() end

--- Returns the text of this Tooltip_Panel widget.
function LTooltipPanel:getText() end

--- Sets the delay for this Tooltip_Panel widget.
---@param v any
function LTooltipPanel:setDelay(v) end

--- Sets the target for this Tooltip_Panel widget.
---@param target? any
function LTooltipPanel:setTarget(target) end

--- Sets the text for this Tooltip_Panel widget.
---@param text any
function LTooltipPanel:setText(text) end

--- Adds TreeView-specific methods (1-based indices in Lua).
---@class LTreeView
LTreeView = {}

--- Adds a node entry to this Tree_View widget.
---@param text any
---@param parent_index? any
function LTreeView:addNode(text, parent_index) end

--- Clears all nodes entries from this Tree_View widget.
function LTreeView:clearNodes() end

--- Performs the collapse all operation on this Tree_View widget.
function LTreeView:collapseAll() end

--- Performs the collapse node operation on this Tree_View widget.
---@param index any
function LTreeView:collapseNode(index) end

--- Performs the expand all operation on this Tree_View widget.
function LTreeView:expandAll() end

--- Performs the expand node operation on this Tree_View widget.
---@param index any
function LTreeView:expandNode(index) end

--- Returns the child nodes of this Tree_View widget.
---@param index any
function LTreeView:getChildNodes(index) end

--- Returns the node count of this Tree_View widget.
function LTreeView:getNodeCount() end

--- Returns the node depth of this Tree_View widget.
---@param index any
function LTreeView:getNodeDepth(index) end

--- Returns the node text of this Tree_View widget.
---@param index any
function LTreeView:getNodeText(index) end

--- Returns the parent node of this Tree_View widget.
---@param index any
function LTreeView:getParentNode(index) end

--- Returns the selected node of this Tree_View widget.
function LTreeView:getSelectedNode() end

--- Returns true if expanded is enabled for this Tree_View widget.
---@param index any
function LTreeView:isExpanded(index) end

--- Returns true if node expanded is enabled for this Tree_View widget.
---@param index any
function LTreeView:isNodeExpanded(index) end

--- Removes the node from this Tree_View widget.
---@param index any
function LTreeView:removeNode(index) end

--- Sets the node icon for this Tree_View widget.
---@param index any
---@param icon any
function LTreeView:setNodeIcon(index, icon) end

--- Sets the node text for this Tree_View widget.
---@param index any
---@param text any
function LTreeView:setNodeText(index, text) end

--- Sets the selected node for this Tree_View widget.
---@param index any
function LTreeView:setSelectedNode(index) end

--- Toggles the expanded/collapsed status of a Tree_View node.
---@param index any
function LTreeView:toggleNode(index) end

--- Adds a child widget to this container.
---@param child any
lurek.ui.addChild = function(child) end

--- Queues a toast notification from a table.
---@param toast_table any
lurek.ui.addToast = function(toast_table) end

--- Anchors this widget to a world-space entity by its numeric ID.
---@param entity_id any
lurek.ui.attachToEntity = function(entity_id) end

--- Registers a data-binding key on this widget.
---@param key any
lurek.ui.bind = function(key) end

--- Removes all anchor constraints.
lurek.ui.clearAnchor = function() end

--- Removes keyboard focus from this widget so key events go to the next focusable.
lurek.ui.clearFocus = function() end

--- Returns whether (x, y) is inside this widget.
---@param x any
---@param y any
lurek.ui.containsPoint = function(x, y) end

--- Removes the entity anchor from this widget, restoring normal layout positioning.
lurek.ui.detachFromEntity = function() end

--- Invokes all registered on_draw callbacks, each receiving the widget's
lurek.ui.draw = function() end

--- Renders the UI widget tree to a CPU ImageData at the given resolution.
---@param w any
---@param h any
lurek.ui.drawToImage = function(w, h) end

--- Instantly fades the widget in (sets alpha to `1.0`).
lurek.ui.fadeIn = function() end

--- Instantly fades the widget out (sets alpha to `0.0` and hides it).
lurek.ui.fadeOut = function() end

--- Recursively searches for a widget by id starting from this widget.
---@param id any
lurek.ui.findById = function(id) end

--- Returns true if the widget tree changed since the last call, then resets the flag.
lurek.ui.flushCache = function() end

--- Moves focus to the next focusable widget.
lurek.ui.focusNext = function() end

--- Moves focus to the previous focusable widget.
lurek.ui.focusPrev = function() end

--- Returns the widget's current alpha transparency.
lurek.ui.getAlpha = function() end

--- Returns the number of children in this container.
lurek.ui.getChildCount = function() end

--- Returns this container's children as widget-handle tables.
lurek.ui.getChildren = function() end

--- Returns the flex-grow factor.
lurek.ui.getFlexGrow = function() end

--- Returns the flex-shrink factor.
lurek.ui.getFlexShrink = function() end

--- Returns the focused widget index or nil.
lurek.ui.getFocus = function() end

--- Returns the widget string identifier.
lurek.ui.getId = function() end

--- Returns the widget margin (top, right, bottom, left).
lurek.ui.getMargin = function() end

--- Returns the maximum widget size.
lurek.ui.getMaxSize = function() end

--- Returns the minimum widget size.
lurek.ui.getMinSize = function() end

--- Returns the widget padding (top, right, bottom, left).
lurek.ui.getPadding = function() end

--- Returns the widget position.
lurek.ui.getPosition = function() end

--- Returns the computed screen-space rectangle after layout.
lurek.ui.getRect = function() end

--- Returns the root panel widget table.
lurek.ui.getRoot = function() end

--- Returns the current width and height of the widget in UI pixels.
lurek.ui.getSize = function() end

--- Returns the widget interaction state name.
lurek.ui.getState = function() end

--- Returns whether a theme is set.
lurek.ui.getTheme = function() end

--- Returns the number of active toasts.
lurek.ui.getToastCount = function() end

--- Returns the widget tooltip text.
lurek.ui.getTooltip = function() end

--- Returns the total widget count in the context.
lurek.ui.getWidgetCount = function() end

--- Returns the widget z-order.
lurek.ui.getZOrder = function() end

--- Returns whether the widget is enabled.
lurek.ui.isEnabled = function() end

--- Returns whether the widget is visible.
lurek.ui.isVisible = function() end

--- Forwards a key press event to the GUI.
---@param key any
lurek.ui.keypressed = function(key) end

--- Load a widget tree from a Lua table definition and attach it to the UI
lurek.ui.loadLayout = function() end

--- Load a widget tree from a TOML layout file and attach it to the UI root.
---@param path any
lurek.ui.loadLayoutFile = function(path) end

--- Forwards a mouse move event to the GUI.
---@param x any
---@param y any
lurek.ui.mousemoved = function(x, y) end

--- Forwards a mouse press event to the GUI.
---@param x any
---@param y any
---@param btn? any
lurek.ui.mousepressed = function(x, y, btn) end

--- Forwards a mouse release event to the GUI.
---@param x any
---@param y any
---@param btn? any
lurek.ui.mousereleased = function(x, y, btn) end

--- Creates a collapsible accordion widget.
lurek.ui.newAccordion = function() end

--- Creates a new stacked-area chart.
---@param opts any
lurek.ui.newAreaChart = function(opts) end

--- Creates a badge widget displaying a numeric count.
---@param count? any
lurek.ui.newBadge = function(count) end

--- Creates and returns a new bar chart widget attached to this image widget.
---@param opts any
lurek.ui.newBarChart = function(opts) end

--- Creates and returns a new interactive button widget as a child of this widget.
---@param text? any
lurek.ui.newButton = function(text) end

--- Creates a checkbox widget.
---@param text? any
lurek.ui.newCheckbox = function(text) end

--- Creates a color picker widget.
lurek.ui.newColorPicker = function() end

--- Creates a dropdown combo box widget.
lurek.ui.newComboBox = function() end

--- Creates a new widget with custom Lua-driven rendering.
---@param config? any
lurek.ui.newCustomWidget = function(config) end

--- Creates a modal dialog widget.
---@param title? any
lurek.ui.newDialog = function(title) end

--- Creates and returns a new docking panel that arranges children along its edges.
lurek.ui.newDockPanel = function() end

--- Creates an image display widget.
lurek.ui.newImageWidget = function() end

--- Creates a text label widget.
---@param text? any
lurek.ui.newLabel = function(text) end

--- Creates a flexbox layout container.
---@param direction? any
lurek.ui.newLayout = function(direction) end

--- Creates a new line chart.
---@param opts any
lurek.ui.newLineChart = function(opts) end

--- Creates a selectable list widget.
lurek.ui.newList = function() end

--- Creates a menu bar widget.
lurek.ui.newMenuBar = function() end

--- Creates a menu item widget.
---@param text? any
lurek.ui.newMenuItem = function(text) end

--- Creates a 9-patch slicer widget.
lurek.ui.newNinePatch = function() end

--- Creates a container panel widget.
lurek.ui.newPanel = function() end

--- Creates and returns a new pie chart widget attached to this image widget.
---@param opts any
lurek.ui.newPieChart = function(opts) end

--- Creates a progress bar widget.
---@param min? any
---@param max? any
lurek.ui.newProgressBar = function(min, max) end

--- Creates a grouped radio button widget.
---@param text? any
---@param group? any
lurek.ui.newRadioButton = function(text, group) end

--- Creates a new scatter plot.
---@param opts any
lurek.ui.newScatterPlot = function(opts) end

--- Creates a scroll bar widget.
---@param vertical? any
lurek.ui.newScrollBar = function(vertical) end

--- Creates a scrollable panel widget.
lurek.ui.newScrollPanel = function() end

--- Creates a separator line.
---@param vertical? any
lurek.ui.newSeparator = function(vertical) end

--- Creates a value slider widget.
---@param min? any
---@param max? any
lurek.ui.newSlider = function(min, max) end

--- Creates a spacing filler widget.
---@param w? any
---@param h? any
lurek.ui.newSpacer = function(w, h) end

--- Creates a numeric spin box widget with increment and decrement buttons.
---@param min? any
---@param max? any
lurek.ui.newSpinBox = function(min, max) end

--- Creates a resizable split panel.
---@param orientation? any
lurek.ui.newSplitPanel = function(orientation) end

--- Creates a status bar widget.
lurek.ui.newStatusBar = function() end

--- Creates a toggle switch widget.
---@param on? any
lurek.ui.newSwitch = function(on) end

--- Creates a tab bar widget.
lurek.ui.newTabBar = function() end

--- Creates a data table widget.
lurek.ui.newTable = function() end

--- Creates a text input widget.
lurek.ui.newTextInput = function() end

--- Creates a new theme instance.
lurek.ui.newTheme = function() end

--- Creates a toast notification widget.
---@param message? any
---@param duration? any
lurek.ui.newToast = function(message, duration) end

--- Creates a toolbar widget.
---@param orientation? any
lurek.ui.newToolbar = function(orientation) end

--- Creates a tooltip panel widget.
---@param text? any
lurek.ui.newTooltipPanel = function(text) end

--- Creates a collapsible tree view widget.
lurek.ui.newTreeView = function() end

--- Creates a draggable window widget.
---@param title? any
lurek.ui.newWindow = function(title) end

--- Parses a widget state string, returning the canonical form or nil if invalid.
---@param state any
lurek.ui.parseWidgetState = function(state) end

--- Removes a child widget from this container.
---@param child any
lurek.ui.removeChild = function(child) end

--- Render the current UI widget tree to a PNG file for testing purposes.
---@param width any
---@param height any
---@param path any
lurek.ui.renderToImage = function(width, height, path) end

--- Sets the widget's alpha transparency (`0.0` fully transparent, `1.0` opaque).
---@param alpha any
lurek.ui.setAlpha = function(alpha) end

--- Sets anchor edges (left, top, right, bottom).
lurek.ui.setAnchor = function() end

--- Sets center anchor offsets.
---@param cx? any
---@param cy? any
lurek.ui.setAnchorCenter = function(cx, cy) end

--- Installs the built-in dark theme as the active GUI theme.
lurek.ui.setDefaultTheme = function() end

--- Sets whether the widget is enabled.
---@param v any
lurek.ui.setEnabled = function(v) end

--- Sets the flex-grow factor.
---@param grow any
lurek.ui.setFlexGrow = function(grow) end

--- Sets the flex-shrink factor.
---@param shrink any
lurek.ui.setFlexShrink = function(shrink) end

--- Sets keyboard focus to a widget or clears it.
---@param widget? any
lurek.ui.setFocus = function(widget) end

--- Sets the widget string identifier.
---@param id any
lurek.ui.setId = function(id) end

--- Sets widget margin (CSS-like: top, right?, bottom?, left?).
---@param top any
---@param right? any
---@param bottom? any
---@param left? any
lurek.ui.setMargin = function(top, right, bottom, left) end

--- Sets the maximum widget size.
---@param w any
---@param h any
lurek.ui.setMaxSize = function(w, h) end

--- Sets the minimum widget size.
---@param w any
---@param h any
lurek.ui.setMinSize = function(w, h) end

--- Registers a callback invoked when this widget's value changes.
---@param f any
lurek.ui.setOnChange = function(f) end

--- Registers a callback invoked when this widget is clicked.
---@param f any
lurek.ui.setOnClick = function(f) end

--- Stores a custom draw callback for later invocation.
---@param self any
---@param f any
lurek.ui.setOnDraw = function(self, f) end

--- Sets widget padding (CSS-like: top, right?, bottom?, left?).
---@param top any
---@param right? any
---@param bottom? any
---@param left? any
lurek.ui.setPadding = function(top, right, bottom, left) end

--- Sets the widget position.
---@param x any
---@param y any
lurek.ui.setPosition = function(x, y) end

--- Sets the width and height of the widget in UI pixels.
---@param w any
---@param h any
lurek.ui.setSize = function(w, h) end

--- Sets the active GUI theme.
---@param theme_ud any
lurek.ui.setTheme = function(theme_ud) end

--- Sets the widget tooltip text.
---@param text any
lurek.ui.setTooltip = function(text) end

--- Sets the viewport dimensions used for anchor constraints and layout.
---@param w any
---@param h any
lurek.ui.setViewport = function(w, h) end

--- Shows or hides the widget; hidden widgets are not rendered or interactive.
---@param v any
lurek.ui.setVisible = function(v) end

--- Sets the widget z-order for draw sorting.
---@param z any
lurek.ui.setZOrder = function(z) end

--- Instantly moves the widget to `(x, y)` and makes it visible.
---@param x any
---@param y any
lurek.ui.slideIn = function(x, y) end

--- Instantly moves the widget to the off-screen position `(x, y)` and hides it.
---@param x any
---@param y any
lurek.ui.slideOut = function(x, y) end

--- Forwards text input to the focused text input widget.
---@param text any
lurek.ui.textinput = function(text) end

--- Returns the Lua type name of this widget (e.g. "LButton").
lurek.ui.type = function() end

--- Returns true if this widget is of the given type, "LWidget", or "Object".
---@param name any
lurek.ui.typeOf = function(name) end

--- Removes the data-binding key from this widget.
lurek.ui.unbind = function() end

--- Advances toast timers, removes expired toasts, and dispatches pending GUI events.
---@param dt any
lurek.ui.update = function(dt) end

--- Updates all widgets that have a data-binding key registered via `:bind(key)`.
lurek.ui.update_bindings = function() end

--- Forwards a mouse wheel event to the GUI.
---@param x any
---@param y any
lurek.ui.wheelmoved = function(x, y) end

---@class lurek.window
lurek.window = {}

--- Requests the window to close, which will end the game loop after the current frame finishes.
---@return nil No return value.
lurek.window.close = function() end

--- Requests the window manager to bring the window to the foreground.
---@return nil No return value.
lurek.window.focus = function() end

--- Converts a physical pixel value back to device-independent (logical) coordinates using the current DPI scale factor.
---@param value number The physical pixel value to convert
---@return number The corresponding logical coordinate value
lurek.window.fromPixels = function(value) end

--- Returns the current DPI scaling factor for the window as a number.
---@return number The DPI scale factor (1.0 = standard density)
lurek.window.getDPIScale = function() end

--- Returns the full desktop resolution of the current monitor as two values (width, height) in physical pixels.
---@return integer
---@return integer
lurek.window.getDesktopDimensions = function() end

--- Returns the window dimensions as two values (width, height) in logical pixels.
---@return integer
---@return integer
lurek.window.getDimensions = function() end

--- Returns the number of displays (monitors) currently connected to the system.
---@return number The number of connected displays
lurek.window.getDisplayCount = function() end

--- Returns the human-readable name of a connected display as reported by the operating system (for example "DELL U2723QE" or "Built-in Retina").
---@param display integer|nil Zero-based display index; omit for the current monitor
---@return string The display name string
lurek.window.getDisplayName = function(display) end

--- Returns the current display orientation.
---@return string Returned string.
lurek.window.getDisplayOrientation = function() end

--- Returns the current fullscreen state as two values: a boolean indicating whether fullscreen is active, and a string describing the type ("desktop" or "exclusive").
---@return boolean
---@return string
lurek.window.getFullscreen = function() end

--- Returns an array of all available fullscreen video modes supported by the current monitor.
---@return table An array of tables, each with width, height, and refreshRate fields
lurek.window.getFullscreenModes = function() end

--- Returns the logical game height in virtual pixels.
---@return number Returned number.
lurek.window.getGameHeight = function() end

--- Returns the logical game width in virtual pixels.
---@return number Returned number.
lurek.window.getGameWidth = function() end

--- Returns the current window height in logical pixels.
---@return number The window height in logical pixels
lurek.window.getHeight = function() end

--- Returns the current window dimensions and mode flags as three values: width, height, and a flags table.
---@return integer
---@return integer
---@return table
lurek.window.getMode = function() end

--- Returns the native DPI scale factor.
---@return number Returned number.
lurek.window.getNativeDPIScale = function() end

--- Returns the window dimensions in physical (device) pixels as two values (width, height).
---@return integer
---@return integer
lurek.window.getPixelDimensions = function() end

--- Returns the top-left corner position of the window in screen coordinates as two values (x, y).
---@return integer
---@return integer
lurek.window.getPosition = function() end

--- Returns the safe display area as x, y, w, h.
---@return number
---@return number
---@return number
---@return number
lurek.window.getSafeArea = function() end

--- Returns viewport scale and offset information as a table.
---@return table Returned table.
lurek.window.getScaleInfo = function() end

--- Returns the current viewport scale mode string.
---@return string Returned string.
lurek.window.getScaleMode = function() end

--- Returns the OS color theme preference.
---@return string Returned string.
lurek.window.getSystemTheme = function() end

--- Returns the current window title bar text as a string.
---@return string The current window title
lurek.window.getTitle = function() end

--- Returns the current vertical synchronisation mode as an integer: 1 = VSync on, 0 = VSync off, -1 = adaptive VSync.
---@return number The current VSync mode
lurek.window.getVSync = function() end

--- Returns the current window width in logical pixels.
---@return number The window width in logical pixels
lurek.window.getWidth = function() end

--- Returns whether the window currently has keyboard input focus from the operating system.
---@return boolean True if the window has keyboard focus
lurek.window.hasFocus = function() end

--- Returns whether the mouse cursor is currently inside the window's client area.
---@return boolean True if the mouse cursor is inside the window
lurek.window.hasMouseFocus = function() end

--- Returns whether the window is in fullscreen mode.
---@return boolean Boolean result.
lurek.window.isFullscreen = function() end

--- Returns whether high-DPI rendering is allowed.
---@return boolean Boolean result.
lurek.window.isHighDPIAllowed = function() end

--- Returns whether the window is currently maximised to fill the entire desktop work area.
---@return boolean True if the window is maximised
lurek.window.isMaximized = function() end

--- Returns whether the window is currently minimised to the taskbar.
---@return boolean True if the window is minimised
lurek.window.isMinimized = function() end

--- Returns whether the window is currently open and active.
---@return boolean Always true during normal engine operation
lurek.window.isOpen = function() end

--- Returns whether the window can be resized by the user.
---@return boolean Boolean result.
lurek.window.isResizable = function() end

--- Returns whether the window is currently visible on screen.
---@return boolean True if the window is visible
lurek.window.isVisible = function() end

--- Maximises the window so it fills the entire desktop work area, excluding the taskbar.
---@return nil No return value.
lurek.window.maximize = function() end

--- Minimises the window to the operating system taskbar or dock.
---@return nil No return value.
lurek.window.minimize = function() end

--- Registers a callback invoked (with the new scale factor) when the display DPI changes.
---@param callback function Value for fn.
---@return nil No return value.
lurek.window.onDpiChange = function(callback) end

--- Opens a blocking native file-open dialog.
---@param opts table|nil Options table.
---@return string nil | Returned value.
lurek.window.openFileDialog = function(opts) end

lurek.window.pollDpiChange = function() end

--- Flashes the window icon in the operating system taskbar or dock to attract the user's attention.
---@return nil No return value.
lurek.window.requestAttention = function() end

--- Restores the window to its previous size and position after a `minimize` or `maximize` call.
---@return nil No return value.
lurek.window.restore = function() end

--- Enables or disables fullscreen mode.
---@param enabled boolean True to enter fullscreen, false to exit
---@param fstype string|nil Fullscreen type: "desktop" or "exclusive" (default "desktop")
---@return nil No return value.
lurek.window.setFullscreen = function(enabled, fstype) end

--- Sets the window icon from an image file located in the game directory.
---@param path string Relative path to the icon image file
---@return nil No return value.
lurek.window.setIcon = function(path) end

--- Resizes the window and optionally changes fullscreen and vsync settings in a single call.
---@param w integer The new window width in logical pixels
---@param h integer The new window height in logical pixels
---@param flags table|nil Optional table with fullscreen, fullscreentype, and vsync keys
---@return nil No return value.
lurek.window.setMode = function(w, h, flags) end

--- Moves the top-left corner of the window to the given screen coordinates.
---@param x integer The target horizontal screen coordinate in pixels
---@param y integer The target vertical screen coordinate in pixels
---@return nil No return value.
lurek.window.setPosition = function(x, y) end

--- Sets the viewport scale mode.
---@param mode string Mode value.
---@return nil No return value.
lurek.window.setScaleMode = function(mode) end

--- Sets the text displayed in the window's title bar.
---@param title string The new window title text
---@return nil No return value.
lurek.window.setTitle = function(title) end

--- Sets the vertical synchronisation mode for the window's swap chain.
---@param mode integer VSync mode: 1 = on, 0 = off, -1 = adaptive
---@return nil No return value.
lurek.window.setVSync = function(mode) end

--- Shows a platform-native message box dialog.
---@param title string Window title text.
---@param message string Message text.
---@param boxType string|nil Value for boxType.
---@param btnType string|nil Value for btnType.
---@return string Returned string.
lurek.window.showMessageBox = function(title, message, boxType, btnType) end

--- Converts a device-independent (logical) coordinate value to its equivalent in physical pixels using the current DPI scale factor.
---@param value number The logical coordinate value to convert
---@return number The corresponding physical pixel value
lurek.window.toPixels = function(value) end
