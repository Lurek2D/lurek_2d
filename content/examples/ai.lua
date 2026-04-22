-- content/examples/ai.lua
-- love2d-style usage snippets for the lurek.ai API (240 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/ai.lua

-- ── lurek.ai.* functions ──

--@api-stub: lurek.ai.newWorld
-- Creates a new AI world container.
-- Build once at startup; reuse across frames.
local world = lurek.ai.newWorld()
print("created", world)
return world

--@api-stub: lurek.ai.newBlackboard
-- Creates a new standalone blackboard.
-- Build once at startup; reuse across frames.
local blackboard = lurek.ai.newBlackboard()
print("created", blackboard)
return blackboard

--@api-stub: lurek.ai.newStateMachine
-- Creates a new finite state machine.
-- Build once at startup; reuse across frames.
local statemachine = lurek.ai.newStateMachine()
print("created", statemachine)
return statemachine

--@api-stub: lurek.ai.newBehaviorTree
-- Creates a new behavior tree.
-- Build once at startup; reuse across frames.
local behaviortree = lurek.ai.newBehaviorTree()
print("created", behaviortree)
return behaviortree

--@api-stub: lurek.ai.newSelector
-- Creates a BT selector node.
-- Build once at startup; reuse across frames.
local selector = lurek.ai.newSelector()
print("created", selector)
return selector

--@api-stub: lurek.ai.newSequence
-- Creates a BT sequence node.
-- Build once at startup; reuse across frames.
local sequence = lurek.ai.newSequence()
print("created", sequence)
return sequence

--@api-stub: lurek.ai.newParallel
-- Creates a BT parallel node with optional policies.
-- Build once at startup; reuse across frames.
local parallel = lurek.ai.newParallel(sp, fp)
print("created", parallel)
return parallel

--@api-stub: lurek.ai.newInverter
-- Creates a BT inverter decorator.
-- Build once at startup; reuse across frames.
local inverter = lurek.ai.newInverter()
print("created", inverter)
return inverter

--@api-stub: lurek.ai.newRepeater
-- Creates a BT repeater decorator.
-- Build once at startup; reuse across frames.
local repeater = lurek.ai.newRepeater(10)
print("created", repeater)
return repeater

--@api-stub: lurek.ai.newSucceeder
-- Creates a BT succeeder decorator.
-- Build once at startup; reuse across frames.
local succeeder = lurek.ai.newSucceeder()
print("created", succeeder)
return succeeder

--@api-stub: lurek.ai.newAction
-- Creates a BT action leaf with a Lua callback.
-- Build once at startup; reuse across frames.
local action = lurek.ai.newAction(function() print("newAction fired") end)
print("created", action)
return action

--@api-stub: lurek.ai.newCondition
-- Creates a BT condition leaf with a Lua predicate.
-- Build once at startup; reuse across frames.
local condition = lurek.ai.newCondition(function() print("newCondition fired") end)
print("created", condition)
return condition

--@api-stub: lurek.ai.newSteeringManager
-- Creates a new steering behavior manager.
-- Build once at startup; reuse across frames.
local steeringmanager = lurek.ai.newSteeringManager()
print("created", steeringmanager)
return steeringmanager

--@api-stub: lurek.ai.newQLearner
-- Creates a tabular Q-learner.
-- Build once at startup; reuse across frames.
local qlearner = lurek.ai.newQLearner(sc, ac)
print("created", qlearner)
return qlearner

--@api-stub: lurek.ai.newUtilityAI
-- Creates a new utility AI evaluator.
-- Build once at startup; reuse across frames.
local utilityai = lurek.ai.newUtilityAI()
print("created", utilityai)
return utilityai

--@api-stub: lurek.ai.newGOAPPlanner
-- Creates a new GOAP planning solver.
-- Build once at startup; reuse across frames.
local goapplanner = lurek.ai.newGOAPPlanner()
print("created", goapplanner)
return goapplanner

--@api-stub: lurek.ai.newInfluenceMap
-- Creates a multi-layer influence map grid.
-- Build once at startup; reuse across frames.
local influencemap = lurek.ai.newInfluenceMap(64, 64, cs)
print("created", influencemap)
return influencemap

--@api-stub: lurek.ai.newSquad
-- Creates a named squad for formation positioning.
-- Build once at startup; reuse across frames.
local squad = lurek.ai.newSquad("main")
print("created", squad)
return squad

--@api-stub: lurek.ai.newCommandQueue
-- Creates an RTS-style command queue.
-- Build once at startup; reuse across frames.
local commandqueue = lurek.ai.newCommandQueue()
print("created", commandqueue)
return commandqueue

--@api-stub: lurek.ai.newTraitProfile
-- Creates a new personality trait profile.
-- Build once at startup; reuse across frames.
local traitprofile = lurek.ai.newTraitProfile()
print("created", traitprofile)
return traitprofile

--@api-stub: lurek.ai.newStimulusWorld
-- Creates a new stimulus perception world.
-- Build once at startup; reuse across frames.
local stimulusworld = lurek.ai.newStimulusWorld()
print("created", stimulusworld)
return stimulusworld

--@api-stub: lurek.ai.newContextSteering
-- Creates a new context steering controller.
-- Build once at startup; reuse across frames.
local contextsteering = lurek.ai.newContextSteering(slots)
print("created", contextsteering)
return contextsteering

--@api-stub: lurek.ai.newNeedSystem
-- Creates a new motivational need system.
-- Build once at startup; reuse across frames.
local needsystem = lurek.ai.newNeedSystem()
print("created", needsystem)
return needsystem

--@api-stub: lurek.ai.newAIDirector
-- Creates a new AI pacing director with default config.
-- Build once at startup; reuse across frames.
local aidirector = lurek.ai.newAIDirector()
print("created", aidirector)
return aidirector

--@api-stub: lurek.ai.newHTNDomain
-- Creates a new Hierarchical Task Network domain.
-- Build once at startup; reuse across frames.
local htndomain = lurek.ai.newHTNDomain()
print("created", htndomain)
return htndomain

--@api-stub: lurek.ai.newMCTSEngine
-- Creates a new Monte Carlo Tree Search engine.
-- Build once at startup; reuse across frames.
local mctsengine = lurek.ai.newMCTSEngine(iters, uct_c, depth, seed)
print("created", mctsengine)
return mctsengine

--@api-stub: lurek.ai.newEmotionModel
-- Creates a new affective emotion model.
-- Build once at startup; reuse across frames.
local emotionmodel = lurek.ai.newEmotionModel()
print("created", emotionmodel)
return emotionmodel

--@api-stub: lurek.ai.newORCASolver
-- Creates a new ORCA crowd avoidance solver.
-- Build once at startup; reuse across frames.
local orcasolver = lurek.ai.newORCASolver(time_horizon)
print("created", orcasolver)
return orcasolver

--@api-stub: lurek.ai.newNeuralNet
-- Creates a new feedforward neural network (inference only).
-- Build once at startup; reuse across frames.
local neuralnet = lurek.ai.newNeuralNet()
print("created", neuralnet)
return neuralnet

--@api-stub: lurek.ai.newGeneticAlgorithm
-- Creates a new genetic algorithm.
-- Build once at startup; reuse across frames.
local geneticalgorithm = lurek.ai.newGeneticAlgorithm(pop_size, 10, seed)
print("created", geneticalgorithm)
return geneticalgorithm

--@api-stub: lurek.ai.newBandit
-- Creates a new multi-armed bandit.
-- Build once at startup; reuse across frames.
local bandit = lurek.ai.newBandit(10, "hello", epsilon, seed)
print("created", bandit)
return bandit

--@api-stub: lurek.ai.newNeuroevolution
-- Creates a neuroevolution trainer (GA for neural network weights).
-- Build once at startup; reuse across frames.
local neuroevolution = lurek.ai.newNeuroevolution(layer_spec, pop_size, seed)
print("created", neuroevolution)
return neuroevolution

--@api-stub: lurek.ai.newStrategyAI
-- Creates a new throttled strategy AI.
-- Build once at startup; reuse across frames.
local strategyai = lurek.ai.newStrategyAI(update_interval)
print("created", strategyai)
return strategyai

--@api-stub: lurek.ai.newAILod
-- Creates a new AI LOD controller with default 3-tier config.
-- Build once at startup; reuse across frames.
local ailod = lurek.ai.newAILod()
print("created", ailod)
return ailod

-- ── AIWorld methods ──

--@api-stub: AIWorld:addAgent
-- Registers a new named agent and returns its handle.
-- Side-effecting; safe to call any time after init.
local aIWorld = lurek.ai.newAIWorld()
aIWorld:addAgent("main")
print("AIWorld:addAgent done")

--@api-stub: AIWorld:getAgent
-- Returns the agent handle for the given name, or nil.
-- Cheap to call; safe inside callbacks.
local aIWorld = lurek.ai.newAIWorld()  -- or your existing handle
local value = aIWorld:getAgent("main")
print("AIWorld:getAgent ->", value)

--@api-stub: AIWorld:removeAgent
-- Removes an agent by its userdata handle.
-- Pair with the matching constructor to free resources.
local aIWorld = lurek.ai.newAIWorld()
aIWorld:removeAgent(agent)
-- aIWorld is now released
print("ok")

--@api-stub: AIWorld:getAgentCount
-- Returns the number of registered agents.
-- Cheap to call; safe inside callbacks.
local aIWorld = lurek.ai.newAIWorld()  -- or your existing handle
local value = aIWorld:getAgentCount()
print("AIWorld:getAgentCount ->", value)

--@api-stub: AIWorld:getGlobalBlackboard
-- Returns a snapshot of the world-level blackboard.
-- Cheap to call; safe inside callbacks.
local aIWorld = lurek.ai.newAIWorld()  -- or your existing handle
local value = aIWorld:getGlobalBlackboard()
print("AIWorld:getGlobalBlackboard ->", value)

--@api-stub: AIWorld:update
-- Advances all agents by dt seconds.
-- Apply at startup or in response to user input.
local aIWorld = lurek.ai.newAIWorld()
aIWorld:update(dt)
print("AIWorld:update applied")

--@api-stub: AIWorld:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local aIWorld = lurek.ai.newAIWorld()
aIWorld:type()
print("AIWorld:type done")

--@api-stub: AIWorld:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local aIWorld = lurek.ai.newAIWorld()
aIWorld:typeOf("main")
print("AIWorld:typeOf done")

-- ── Agent methods ──

--@api-stub: Agent:getName
-- Returns the agent's registered name.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getName()
print("Agent:getName ->", value)

--@api-stub: Agent:setPosition
-- Sets the agent's world-space position.
-- Apply at startup or in response to user input.
local agent = lurek.ai.newAgent()
agent:setPosition(100, 100)
print("Agent:setPosition applied")

--@api-stub: Agent:getPosition
-- Returns the agent's current position.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getPosition()
print("Agent:getPosition ->", value)

--@api-stub: Agent:setVelocity
-- Sets the agent's velocity vector.
-- Apply at startup or in response to user input.
local agent = lurek.ai.newAgent()
agent:setVelocity(100, 100)
print("Agent:setVelocity applied")

--@api-stub: Agent:getVelocity
-- Returns the agent's current velocity.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getVelocity()
print("Agent:getVelocity ->", value)

--@api-stub: Agent:setMaxSpeed
-- Sets the maximum speed cap.
-- Apply at startup or in response to user input.
local agent = lurek.ai.newAgent()
agent:setMaxSpeed(v)
print("Agent:setMaxSpeed applied")

--@api-stub: Agent:getMaxSpeed
-- Returns the maximum speed cap.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getMaxSpeed()
print("Agent:getMaxSpeed ->", value)

--@api-stub: Agent:setMaxForce
-- Sets the maximum steering force cap.
-- Apply at startup or in response to user input.
local agent = lurek.ai.newAgent()
agent:setMaxForce(v)
print("Agent:setMaxForce applied")

--@api-stub: Agent:getMaxForce
-- Returns the maximum steering force cap.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getMaxForce()
print("Agent:getMaxForce ->", value)

--@api-stub: Agent:setPriority
-- Sets the scheduling priority (higher = earlier).
-- Apply at startup or in response to user input.
local agent = lurek.ai.newAgent()
agent:setPriority(p)
print("Agent:setPriority applied")

--@api-stub: Agent:getPriority
-- Returns the agent's scheduling priority.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getPriority()
print("Agent:getPriority ->", value)

--@api-stub: Agent:setDecisionModel
-- Sets the active decision model.
-- Apply at startup or in response to user input.
local agent = lurek.ai.newAgent()
agent:setDecisionModel(model)
print("Agent:setDecisionModel applied")

--@api-stub: Agent:getDecisionModel
-- Returns the name of the current decision model.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getDecisionModel()
print("Agent:getDecisionModel ->", value)

--@api-stub: Agent:addTag
-- Adds a tag to this agent.
-- Side-effecting; safe to call any time after init.
local agent = lurek.ai.newAgent()
agent:addTag("main")
print("Agent:addTag done")

--@api-stub: Agent:removeTag
-- Removes a tag from this agent.
-- Pair with the matching constructor to free resources.
local agent = lurek.ai.newAgent()
agent:removeTag("main")
-- agent is now released
print("ok")

--@api-stub: Agent:hasTag
-- Returns true if the agent has the given tag.
-- Use as a guard inside lurek.update or event handlers.
local agent = lurek.ai.newAgent()
if agent:hasTag("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Agent:getBlackboard
-- Returns the agent's local blackboard.
-- Cheap to call; safe inside callbacks.
local agent = lurek.ai.newAgent()  -- or your existing handle
local value = agent:getBlackboard()
print("Agent:getBlackboard ->", value)

--@api-stub: Agent:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local agent = lurek.ai.newAgent()
agent:type()
print("Agent:type done")

--@api-stub: Agent:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local agent = lurek.ai.newAgent()
agent:typeOf("main")
print("Agent:typeOf done")

-- ── Blackboard methods ──

--@api-stub: Blackboard:setNumber
-- Stores a number under the given key.
-- Apply at startup or in response to user input.
local blackboard = lurek.ai.newBlackboard()
blackboard:setNumber("space", value)
print("Blackboard:setNumber applied")

--@api-stub: Blackboard:setBool
-- Stores a boolean under the given key.
-- Apply at startup or in response to user input.
local blackboard = lurek.ai.newBlackboard()
blackboard:setBool("space", value)
print("Blackboard:setBool applied")

--@api-stub: Blackboard:setString
-- Stores a string under the given key.
-- Apply at startup or in response to user input.
local blackboard = lurek.ai.newBlackboard()
blackboard:setString("space", value)
print("Blackboard:setString applied")

--@api-stub: Blackboard:has
-- Returns true if a value exists under the key.
-- See the module spec for detailed semantics.
local blackboard = lurek.ai.newBlackboard()
blackboard:has("space")
print("Blackboard:has done")

--@api-stub: Blackboard:remove
-- Removes the entry at key.
-- Pair with the matching constructor to free resources.
local blackboard = lurek.ai.newBlackboard()
blackboard:remove("space")
-- blackboard is now released
print("ok")

--@api-stub: Blackboard:clear
-- Removes all local entries.
-- Pair with the matching constructor to free resources.
local blackboard = lurek.ai.newBlackboard()
blackboard:clear()
-- blackboard is now released
print("ok")

--@api-stub: Blackboard:getKeys
-- Returns all local keys as a table.
-- Cheap to call; safe inside callbacks.
local blackboard = lurek.ai.newBlackboard()  -- or your existing handle
local value = blackboard:getKeys()
print("Blackboard:getKeys ->", value)

--@api-stub: Blackboard:getSize
-- Returns the number of local entries.
-- Cheap to call; safe inside callbacks.
local blackboard = lurek.ai.newBlackboard()  -- or your existing handle
local value = blackboard:getSize()
print("Blackboard:getSize ->", value)

--@api-stub: Blackboard:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local blackboard = lurek.ai.newBlackboard()
blackboard:type()
print("Blackboard:type done")

--@api-stub: Blackboard:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local blackboard = lurek.ai.newBlackboard()
blackboard:typeOf("main")
print("Blackboard:typeOf done")

-- ── StateMachine methods ──

--@api-stub: StateMachine:addState
-- Registers a named state with optional lifecycle callbacks.
-- Side-effecting; safe to call any time after init.
local stateMachine = lurek.ai.newStateMachine()
stateMachine:addState("main", { x = 0, y = 0 })
print("StateMachine:addState done")

--@api-stub: StateMachine:setInitialState
-- Sets the FSM's initial state; must be called before the first update.
-- Apply at startup or in response to user input.
local stateMachine = lurek.ai.newStateMachine()
stateMachine:setInitialState("main")
print("StateMachine:setInitialState applied")

--@api-stub: StateMachine:getCurrentState
-- Returns the current state name, or nil.
-- Cheap to call; safe inside callbacks.
local stateMachine = lurek.ai.newStateMachine()  -- or your existing handle
local value = stateMachine:getCurrentState()
print("StateMachine:getCurrentState ->", value)

--@api-stub: StateMachine:forceState
-- Forces a transition to the named state.
-- See the module spec for detailed semantics.
local stateMachine = lurek.ai.newStateMachine()
stateMachine:forceState("main")
print("StateMachine:forceState done")

--@api-stub: StateMachine:getTimeInState
-- Returns seconds spent in the current state.
-- Cheap to call; safe inside callbacks.
local stateMachine = lurek.ai.newStateMachine()  -- or your existing handle
local value = stateMachine:getTimeInState()
print("StateMachine:getTimeInState ->", value)

--@api-stub: StateMachine:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local stateMachine = lurek.ai.newStateMachine()
stateMachine:type()
print("StateMachine:type done")

--@api-stub: StateMachine:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local stateMachine = lurek.ai.newStateMachine()
stateMachine:typeOf("main")
print("StateMachine:typeOf done")

-- ── BehaviorTree methods ──

--@api-stub: BehaviorTree:setRoot
-- Sets the root node of this behavior tree.
-- Apply at startup or in response to user input.
local behaviorTree = lurek.ai.newBehaviorTree()
behaviorTree:setRoot(node_ud)
print("BehaviorTree:setRoot applied")

--@api-stub: BehaviorTree:getLastStatus
-- Returns the status from the last tick.
-- Cheap to call; safe inside callbacks.
local behaviorTree = lurek.ai.newBehaviorTree()  -- or your existing handle
local value = behaviorTree:getLastStatus()
print("BehaviorTree:getLastStatus ->", value)

--@api-stub: BehaviorTree:getDebugState
-- Returns a diagnostic snapshot of this behavior tree.
-- Cheap to call; safe inside callbacks.
local behaviorTree = lurek.ai.newBehaviorTree()  -- or your existing handle
local value = behaviorTree:getDebugState()
print("BehaviorTree:getDebugState ->", value)

--@api-stub: BehaviorTree:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local behaviorTree = lurek.ai.newBehaviorTree()
behaviorTree:type()
print("BehaviorTree:type done")

--@api-stub: BehaviorTree:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local behaviorTree = lurek.ai.newBehaviorTree()
behaviorTree:typeOf("main")
print("BehaviorTree:typeOf done")

-- ── BTNode methods ──

--@api-stub: BTNode:addChild
-- Adds a child node (Selector, Sequence, or Parallel only).
-- Side-effecting; safe to call any time after init.
local bTNode = lurek.ai.newBTNode()
bTNode:addChild(child_ud)
print("BTNode:addChild done")

--@api-stub: BTNode:getChildCount
-- Returns the number of direct children.
-- Cheap to call; safe inside callbacks.
local bTNode = lurek.ai.newBTNode()  -- or your existing handle
local value = bTNode:getChildCount()
print("BTNode:getChildCount ->", value)

--@api-stub: BTNode:reset
-- Resets all running-child memos and repeater counters.
-- Pair with the matching constructor to free resources.
local bTNode = lurek.ai.newBTNode()
bTNode:reset()
-- bTNode is now released
print("ok")

--@api-stub: BTNode:setChild
-- Sets the single child of a decorator node.
-- Apply at startup or in response to user input.
local bTNode = lurek.ai.newBTNode()
bTNode:setChild(child_ud)
print("BTNode:setChild applied")

--@api-stub: BTNode:setCount
-- Sets the repeat count for a Repeater node.
-- Apply at startup or in response to user input.
local bTNode = lurek.ai.newBTNode()
bTNode:setCount(10)
print("BTNode:setCount applied")

--@api-stub: BTNode:getCount
-- Returns the repeat count, or 0 if not a Repeater.
-- Cheap to call; safe inside callbacks.
local bTNode = lurek.ai.newBTNode()  -- or your existing handle
local value = bTNode:getCount()
print("BTNode:getCount ->", value)

--@api-stub: BTNode:setSuccessPolicy
-- Sets the success policy for a Parallel node.
-- Apply at startup or in response to user input.
local bTNode = lurek.ai.newBTNode()
bTNode:setSuccessPolicy(policy)
print("BTNode:setSuccessPolicy applied")

--@api-stub: BTNode:setFailurePolicy
-- Sets the failure policy for a Parallel node.
-- Apply at startup or in response to user input.
local bTNode = lurek.ai.newBTNode()
bTNode:setFailurePolicy(policy)
print("BTNode:setFailurePolicy applied")

--@api-stub: BTNode:getNodeType
-- Returns the node type as a string.
-- Cheap to call; safe inside callbacks.
local bTNode = lurek.ai.newBTNode()  -- or your existing handle
local value = bTNode:getNodeType()
print("BTNode:getNodeType ->", value)

--@api-stub: BTNode:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local bTNode = lurek.ai.newBTNode()
bTNode:type()
print("BTNode:type done")

--@api-stub: BTNode:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local bTNode = lurek.ai.newBTNode()
bTNode:typeOf("main")
print("BTNode:typeOf done")

-- ── SteeringManager methods ──

--@api-stub: SteeringManager:getBehaviorCount
-- Returns the number of active behaviors.
-- Cheap to call; safe inside callbacks.
local steeringManager = lurek.ai.newSteeringManager()  -- or your existing handle
local value = steeringManager:getBehaviorCount()
print("SteeringManager:getBehaviorCount ->", value)

--@api-stub: SteeringManager:setCombineMode
-- Sets the force combination mode.
-- Apply at startup or in response to user input.
local steeringManager = lurek.ai.newSteeringManager()
steeringManager:setCombineMode(mode)
print("SteeringManager:setCombineMode applied")

--@api-stub: SteeringManager:getCombineMode
-- Returns the current combination mode.
-- Cheap to call; safe inside callbacks.
local steeringManager = lurek.ai.newSteeringManager()  -- or your existing handle
local value = steeringManager:getCombineMode()
print("SteeringManager:getCombineMode ->", value)

--@api-stub: SteeringManager:getLastSteering
-- Returns the last computed steering force.
-- Cheap to call; safe inside callbacks.
local steeringManager = lurek.ai.newSteeringManager()  -- or your existing handle
local value = steeringManager:getLastSteering()
print("SteeringManager:getLastSteering ->", value)

--@api-stub: SteeringManager:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local steeringManager = lurek.ai.newSteeringManager()
steeringManager:type()
print("SteeringManager:type done")

--@api-stub: SteeringManager:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local steeringManager = lurek.ai.newSteeringManager()
steeringManager:typeOf("main")
print("SteeringManager:typeOf done")

--@api-stub: SteeringManager:setSpatialHashCellSize
-- Sets the cell size used by the spatial-hash neighbourhood search.
-- Apply at startup or in response to user input.
local steeringManager = lurek.ai.newSteeringManager()
steeringManager:setSpatialHashCellSize(10)
print("SteeringManager:setSpatialHashCellSize applied")

--@api-stub: SteeringManager:enableSpatialHash
-- Enables or disables spatial-hash bucketing for neighbourhood queries.
-- See the module spec for detailed semantics.
local steeringManager = lurek.ai.newSteeringManager()
steeringManager:enableSpatialHash(enabled)
print("SteeringManager:enableSpatialHash done")

-- ── QLearner methods ──

--@api-stub: QLearner:chooseAction
-- Selects an action using epsilon-greedy policy (1-based).
-- See the module spec for detailed semantics.
local qLearner = lurek.ai.newQLearner()
qLearner:chooseAction(state)
print("QLearner:chooseAction done")

--@api-stub: QLearner:bestAction
-- Returns the greedy-best action for the state (1-based).
-- See the module spec for detailed semantics.
local qLearner = lurek.ai.newQLearner()
qLearner:bestAction(state)
print("QLearner:bestAction done")

--@api-stub: QLearner:getQValue
-- Returns the Q-value for a state-action pair (1-based).
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getQValue(state, action)
print("QLearner:getQValue ->", value)

--@api-stub: QLearner:endEpisode
-- Ends the current episode, applying epsilon decay.
-- See the module spec for detailed semantics.
local qLearner = lurek.ai.newQLearner()
qLearner:endEpisode()
print("QLearner:endEpisode done")

--@api-stub: QLearner:getEpisodeCount
-- Returns the number of completed episodes.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getEpisodeCount()
print("QLearner:getEpisodeCount ->", value)

--@api-stub: QLearner:getStateCount
-- Returns the number of discrete states.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getStateCount()
print("QLearner:getStateCount ->", value)

--@api-stub: QLearner:getActionCount
-- Returns the number of discrete actions.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getActionCount()
print("QLearner:getActionCount ->", value)

--@api-stub: QLearner:setLearningRate
-- Sets the learning rate alpha.
-- Apply at startup or in response to user input.
local qLearner = lurek.ai.newQLearner()
qLearner:setLearningRate(v)
print("QLearner:setLearningRate applied")

--@api-stub: QLearner:getLearningRate
-- Returns the current learning rate.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getLearningRate()
print("QLearner:getLearningRate ->", value)

--@api-stub: QLearner:setDiscountFactor
-- Sets the discount factor gamma.
-- Apply at startup or in response to user input.
local qLearner = lurek.ai.newQLearner()
qLearner:setDiscountFactor(v)
print("QLearner:setDiscountFactor applied")

--@api-stub: QLearner:getDiscountFactor
-- Returns the current discount factor.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getDiscountFactor()
print("QLearner:getDiscountFactor ->", value)

--@api-stub: QLearner:setExplorationRate
-- Sets the exploration rate epsilon.
-- Apply at startup or in response to user input.
local qLearner = lurek.ai.newQLearner()
qLearner:setExplorationRate(v)
print("QLearner:setExplorationRate applied")

--@api-stub: QLearner:getExplorationRate
-- Returns the current exploration rate.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getExplorationRate()
print("QLearner:getExplorationRate ->", value)

--@api-stub: QLearner:setExplorationDecay
-- Sets the epsilon decay multiplier.
-- Apply at startup or in response to user input.
local qLearner = lurek.ai.newQLearner()
qLearner:setExplorationDecay(v)
print("QLearner:setExplorationDecay applied")

--@api-stub: QLearner:getExplorationDecay
-- Returns the epsilon decay multiplier.
-- Cheap to call; safe inside callbacks.
local qLearner = lurek.ai.newQLearner()  -- or your existing handle
local value = qLearner:getExplorationDecay()
print("QLearner:getExplorationDecay ->", value)

--@api-stub: QLearner:serialize
-- Serializes the Q-table to a JSON string.
-- May block — call from a worker thread for large payloads.
local qLearner = lurek.ai.newQLearner()
qLearner:serialize()
print("QLearner:serialize done")

--@api-stub: QLearner:deserialize
-- Restores the Q-table from a JSON string.
-- May block — call from a worker thread for large payloads.
local qLearner = lurek.ai.newQLearner()
qLearner:deserialize(json)
print("QLearner:deserialize done")

--@api-stub: QLearner:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local qLearner = lurek.ai.newQLearner()
qLearner:type()
print("QLearner:type done")

--@api-stub: QLearner:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local qLearner = lurek.ai.newQLearner()
qLearner:typeOf("main")
print("QLearner:typeOf done")

-- ── UtilityAI methods ──

--@api-stub: UtilityAI:evaluate
-- Evaluates all actions and returns the best action name, or nil.
-- See the module spec for detailed semantics.
local utilityAI = lurek.ai.newUtilityAI()
utilityAI:evaluate()
print("UtilityAI:evaluate done")

--@api-stub: UtilityAI:getActionCount
-- Returns the number of registered actions.
-- Cheap to call; safe inside callbacks.
local utilityAI = lurek.ai.newUtilityAI()  -- or your existing handle
local value = utilityAI:getActionCount()
print("UtilityAI:getActionCount ->", value)

--@api-stub: UtilityAI:getLastAction
-- Returns the name of the last chosen action, or nil.
-- Cheap to call; safe inside callbacks.
local utilityAI = lurek.ai.newUtilityAI()  -- or your existing handle
local value = utilityAI:getLastAction()
print("UtilityAI:getLastAction ->", value)

--@api-stub: UtilityAI:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local utilityAI = lurek.ai.newUtilityAI()
utilityAI:type()
print("UtilityAI:type done")

--@api-stub: UtilityAI:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local utilityAI = lurek.ai.newUtilityAI()
utilityAI:typeOf("main")
print("UtilityAI:typeOf done")

-- ── GOAPPlanner methods ──

--@api-stub: GOAPPlanner:getActionCount
-- Returns the number of registered actions.
-- Cheap to call; safe inside callbacks.
local gOAPPlanner = lurek.ai.newGOAPPlanner()  -- or your existing handle
local value = gOAPPlanner:getActionCount()
print("GOAPPlanner:getActionCount ->", value)

--@api-stub: GOAPPlanner:getGoalCount
-- Returns the number of registered goals.
-- Cheap to call; safe inside callbacks.
local gOAPPlanner = lurek.ai.newGOAPPlanner()  -- or your existing handle
local value = gOAPPlanner:getGoalCount()
print("GOAPPlanner:getGoalCount ->", value)

--@api-stub: GOAPPlanner:getMaxIterations
-- Returns the maximum A* planning iterations.
-- Cheap to call; safe inside callbacks.
local gOAPPlanner = lurek.ai.newGOAPPlanner()  -- or your existing handle
local value = gOAPPlanner:getMaxIterations()
print("GOAPPlanner:getMaxIterations ->", value)

--@api-stub: GOAPPlanner:setMaxIterations
-- Sets the maximum A* planning iterations (0 = unlimited).
-- Apply at startup or in response to user input.
local gOAPPlanner = lurek.ai.newGOAPPlanner()
gOAPPlanner:setMaxIterations(10)
print("GOAPPlanner:setMaxIterations applied")

--@api-stub: GOAPPlanner:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local gOAPPlanner = lurek.ai.newGOAPPlanner()
gOAPPlanner:type()
print("GOAPPlanner:type done")

--@api-stub: GOAPPlanner:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local gOAPPlanner = lurek.ai.newGOAPPlanner()
gOAPPlanner:typeOf("main")
print("GOAPPlanner:typeOf done")

-- ── InfluenceMap methods ──

--@api-stub: InfluenceMap:addLayer
-- Adds a named influence layer.
-- Side-effecting; safe to call any time after init.
local influenceMap = lurek.ai.newInfluenceMap()
influenceMap:addLayer("main")
print("InfluenceMap:addLayer done")

--@api-stub: InfluenceMap:hasLayer
-- Returns true if the named layer exists.
-- Use as a guard inside lurek.update or event handlers.
local influenceMap = lurek.ai.newInfluenceMap()
if influenceMap:hasLayer("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: InfluenceMap:decay
-- Multiplies all influences by a decay factor.
-- See the module spec for detailed semantics.
local influenceMap = lurek.ai.newInfluenceMap()
influenceMap:decay(layer, 1.0)
print("InfluenceMap:decay done")

--@api-stub: InfluenceMap:clearLayer
-- Clears all influence in a layer.
-- Pair with the matching constructor to free resources.
local influenceMap = lurek.ai.newInfluenceMap()
influenceMap:clearLayer(layer)
-- influenceMap is now released
print("ok")

--@api-stub: InfluenceMap:clearAll
-- Removes all influence values from every layer in the map.
-- Pair with the matching constructor to free resources.
local influenceMap = lurek.ai.newInfluenceMap()
influenceMap:clearAll()
-- influenceMap is now released
print("ok")

--@api-stub: InfluenceMap:getMaxPosition
-- Returns the world-space position of the maximum value.
-- Cheap to call; safe inside callbacks.
local influenceMap = lurek.ai.newInfluenceMap()  -- or your existing handle
local value = influenceMap:getMaxPosition(layer)
print("InfluenceMap:getMaxPosition ->", value)

--@api-stub: InfluenceMap:getMinPosition
-- Returns the world-space position of the minimum value.
-- Cheap to call; safe inside callbacks.
local influenceMap = lurek.ai.newInfluenceMap()  -- or your existing handle
local value = influenceMap:getMinPosition(layer)
print("InfluenceMap:getMinPosition ->", value)

--@api-stub: InfluenceMap:getWidth
-- Returns the influence map width in grid cells.
-- Cheap to call; safe inside callbacks.
local influenceMap = lurek.ai.newInfluenceMap()  -- or your existing handle
local value = influenceMap:getWidth()
print("InfluenceMap:getWidth ->", value)

--@api-stub: InfluenceMap:getHeight
-- Returns the influence map height in grid cells.
-- Cheap to call; safe inside callbacks.
local influenceMap = lurek.ai.newInfluenceMap()  -- or your existing handle
local value = influenceMap:getHeight()
print("InfluenceMap:getHeight ->", value)

--@api-stub: InfluenceMap:getCellSize
-- Returns the cell size in world units.
-- Cheap to call; safe inside callbacks.
local influenceMap = lurek.ai.newInfluenceMap()  -- or your existing handle
local value = influenceMap:getCellSize()
print("InfluenceMap:getCellSize ->", value)

--@api-stub: InfluenceMap:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local influenceMap = lurek.ai.newInfluenceMap()
influenceMap:type()
print("InfluenceMap:type done")

--@api-stub: InfluenceMap:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local influenceMap = lurek.ai.newInfluenceMap()
influenceMap:typeOf("main")
print("InfluenceMap:typeOf done")

-- ── Squad methods ──

--@api-stub: Squad:getName
-- Returns the unique name string assigned to this squad.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getName()
print("Squad:getName ->", value)

--@api-stub: Squad:addMember
-- Adds an agent by name to this squad.
-- Side-effecting; safe to call any time after init.
local squad = lurek.ai.newSquad()
squad:addMember("main")
print("Squad:addMember done")

--@api-stub: Squad:removeMember
-- Removes an agent by name from this squad.
-- Pair with the matching constructor to free resources.
local squad = lurek.ai.newSquad()
squad:removeMember("main")
-- squad is now released
print("ok")

--@api-stub: Squad:getMemberCount
-- Returns the number of squad members.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getMemberCount()
print("Squad:getMemberCount ->", value)

--@api-stub: Squad:getMembers
-- Returns the member names as a table.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getMembers()
print("Squad:getMembers ->", value)

--@api-stub: Squad:setLeader
-- Sets the squad leader by name.
-- Apply at startup or in response to user input.
local squad = lurek.ai.newSquad()
squad:setLeader("main")
print("Squad:setLeader applied")

--@api-stub: Squad:getLeader
-- Returns the leader name, or nil.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getLeader()
print("Squad:getLeader ->", value)

--@api-stub: Squad:getFormation
-- Returns the current formation type name.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getFormation()
print("Squad:getFormation ->", value)

--@api-stub: Squad:getFormationSpacing
-- Returns the formation spacing in world units.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getFormationSpacing()
print("Squad:getFormationSpacing ->", value)

--@api-stub: Squad:getBlackboard
-- Returns the squad's shared blackboard.
-- Cheap to call; safe inside callbacks.
local squad = lurek.ai.newSquad()  -- or your existing handle
local value = squad:getBlackboard()
print("Squad:getBlackboard ->", value)

--@api-stub: Squad:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local squad = lurek.ai.newSquad()
squad:type()
print("Squad:type done")

--@api-stub: Squad:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local squad = lurek.ai.newSquad()
squad:typeOf("main")
print("Squad:typeOf done")

-- ── CommandQueue methods ──

--@api-stub: CommandQueue:cancelCurrent
-- Cancels the front command if it is interruptible.
-- Pair with the matching constructor to free resources.
local commandQueue = lurek.ai.newCommandQueue()
commandQueue:cancelCurrent()
-- commandQueue is now released
print("ok")

--@api-stub: CommandQueue:clear
-- Discards all queued commands.
-- Pair with the matching constructor to free resources.
local commandQueue = lurek.ai.newCommandQueue()
commandQueue:clear()
-- commandQueue is now released
print("ok")

--@api-stub: CommandQueue:getCount
-- Returns the number of queued commands.
-- Cheap to call; safe inside callbacks.
local commandQueue = lurek.ai.newCommandQueue()  -- or your existing handle
local value = commandQueue:getCount()
print("CommandQueue:getCount ->", value)

--@api-stub: CommandQueue:isEmpty
-- Returns true if there are no queued commands.
-- Use as a guard inside lurek.update or event handlers.
local commandQueue = lurek.ai.newCommandQueue()
if commandQueue:isEmpty() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: CommandQueue:getCurrentType
-- Returns the kind of the front command, or nil.
-- Cheap to call; safe inside callbacks.
local commandQueue = lurek.ai.newCommandQueue()  -- or your existing handle
local value = commandQueue:getCurrentType()
print("CommandQueue:getCurrentType ->", value)

--@api-stub: CommandQueue:getCurrentTarget
-- Returns the target coordinates of the front command.
-- Cheap to call; safe inside callbacks.
local commandQueue = lurek.ai.newCommandQueue()  -- or your existing handle
local value = commandQueue:getCurrentTarget()
print("CommandQueue:getCurrentTarget ->", value)

--@api-stub: CommandQueue:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local commandQueue = lurek.ai.newCommandQueue()
commandQueue:type()
print("CommandQueue:type done")

--@api-stub: CommandQueue:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local commandQueue = lurek.ai.newCommandQueue()
commandQueue:typeOf("main")
print("CommandQueue:typeOf done")

-- ── TraitProfile methods ──

--@api-stub: TraitProfile:set
-- Sets the base value of this trait, replacing any previous base.
-- Apply at startup or in response to user input.
local traitProfile = lurek.ai.newTraitProfile()
traitProfile:set("main", value)
print("TraitProfile:set applied")

--@api-stub: TraitProfile:get
-- Returns the current float value of this emotion dimension.
-- Cheap to call; safe inside callbacks.
local traitProfile = lurek.ai.newTraitProfile()  -- or your existing handle
local value = traitProfile:get("main")
print("TraitProfile:get ->", value)

--@api-stub: TraitProfile:getBase
-- Returns the unmodified base value of this trait before modifiers.
-- Cheap to call; safe inside callbacks.
local traitProfile = lurek.ai.newTraitProfile()  -- or your existing handle
local value = traitProfile:getBase("main")
print("TraitProfile:getBase ->", value)

--@api-stub: TraitProfile:removeModifiers
-- Removes the specified modifiers.
-- Pair with the matching constructor to free resources.
local traitProfile = lurek.ai.newTraitProfile()
traitProfile:removeModifiers(source)
-- traitProfile is now released
print("ok")

--@api-stub: TraitProfile:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local traitProfile = lurek.ai.newTraitProfile()
traitProfile:update(dt)
print("TraitProfile:update applied")

--@api-stub: TraitProfile:has
-- Returns true if a item is present.
-- See the module spec for detailed semantics.
local traitProfile = lurek.ai.newTraitProfile()
traitProfile:has("main")
print("TraitProfile:has done")

--@api-stub: TraitProfile:traitCount
-- Returns or performs trait count.
-- See the module spec for detailed semantics.
local traitProfile = lurek.ai.newTraitProfile()
traitProfile:traitCount()
print("TraitProfile:traitCount done")

--@api-stub: TraitProfile:archetype
-- Returns or performs archetype.
-- See the module spec for detailed semantics.
local traitProfile = lurek.ai.newTraitProfile()
traitProfile:archetype()
print("TraitProfile:archetype done")

-- ── StimulusWorld methods ──

--@api-stub: StimulusWorld:remove
-- Removes the specified item.
-- Pair with the matching constructor to free resources.
local stimulusWorld = lurek.ai.newStimulusWorld()
stimulusWorld:remove(1)
-- stimulusWorld is now released
print("ok")

--@api-stub: StimulusWorld:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local stimulusWorld = lurek.ai.newStimulusWorld()
stimulusWorld:update(dt)
print("StimulusWorld:update applied")

--@api-stub: StimulusWorld:clear
-- Resets or clears the state.
-- Pair with the matching constructor to free resources.
local stimulusWorld = lurek.ai.newStimulusWorld()
stimulusWorld:clear()
-- stimulusWorld is now released
print("ok")

-- ── ContextSteering methods ──

--@api-stub: ContextSteering:addWander
-- Adds a wander behavior with jitter and weight to the context steering evaluator.
-- Side-effecting; safe to call any time after init.
local contextSteering = lurek.ai.newContextSteering()
contextSteering:addWander(jitter, weight)
print("ContextSteering:addWander done")

--@api-stub: ContextSteering:addAvoidBounds
-- Registers a rectangular region this agent must avoid.
-- Side-effecting; safe to call any time after init.
local contextSteering = lurek.ai.newContextSteering()
contextSteering:addAvoidBounds(min_x, min_y, max_x, max_y, margin, weight)
print("ContextSteering:addAvoidBounds done")

--@api-stub: ContextSteering:clearBehaviors
-- Resets or clears the behaviors.
-- Pair with the matching constructor to free resources.
local contextSteering = lurek.ai.newContextSteering()
contextSteering:clearBehaviors()
-- contextSteering is now released
print("ok")

--@api-stub: ContextSteering:chosenMagnitude
-- Returns or performs chosen magnitude.
-- See the module spec for detailed semantics.
local contextSteering = lurek.ai.newContextSteering()
contextSteering:chosenMagnitude()
print("ContextSteering:chosenMagnitude done")

--@api-stub: ContextSteering:slotCount
-- Returns or performs slot count.
-- See the module spec for detailed semantics.
local contextSteering = lurek.ai.newContextSteering()
contextSteering:slotCount()
print("ContextSteering:slotCount done")

-- ── NeedSystem methods ──

--@api-stub: NeedSystem:addNeed
-- Registers a new need with the specified name, urgency, and decay rate in the system.
-- Side-effecting; safe to call any time after init.
local needSystem = lurek.ai.newNeedSystem()
needSystem:addNeed("main", decay_rate, urgency_threshold, urgency_factor)
print("NeedSystem:addNeed done")

--@api-stub: NeedSystem:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local needSystem = lurek.ai.newNeedSystem()
needSystem:update(dt)
print("NeedSystem:update applied")

--@api-stub: NeedSystem:mostUrgent
-- Returns or performs most urgent.
-- See the module spec for detailed semantics.
local needSystem = lurek.ai.newNeedSystem()
needSystem:mostUrgent()
print("NeedSystem:mostUrgent done")

--@api-stub: NeedSystem:satisfy
-- Returns or performs satisfy.
-- See the module spec for detailed semantics.
local needSystem = lurek.ai.newNeedSystem()
needSystem:satisfy("main", amount)
print("NeedSystem:satisfy done")

--@api-stub: NeedSystem:valueOf
-- Returns or performs value of.
-- See the module spec for detailed semantics.
local needSystem = lurek.ai.newNeedSystem()
needSystem:valueOf("main")
print("NeedSystem:valueOf done")

-- ── AIDirector methods ──

--@api-stub: AIDirector:pushEvent
-- Pushes a gameplay event with the given intensity to the director for awareness analysis.
-- Side-effecting; safe to call any time after init.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:pushEvent(intensity)
print("AIDirector:pushEvent done")

--@api-stub: AIDirector:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:update(dt)
print("AIDirector:update applied")

--@api-stub: AIDirector:tension
-- Returns or performs tension.
-- See the module spec for detailed semantics.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:tension()
print("AIDirector:tension done")

--@api-stub: AIDirector:phase
-- Returns or performs phase.
-- See the module spec for detailed semantics.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:phase()
print("AIDirector:phase done")

--@api-stub: AIDirector:spawnRateFactor
-- Returns or performs spawn rate factor.
-- Build once at startup; reuse across frames.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:spawnRateFactor()
print("AIDirector:spawnRateFactor done")

--@api-stub: AIDirector:lootFactor
-- Returns or performs loot factor.
-- See the module spec for detailed semantics.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:lootFactor()
print("AIDirector:lootFactor done")

--@api-stub: AIDirector:ambientIntensity
-- Returns or performs ambient intensity.
-- See the module spec for detailed semantics.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:ambientIntensity()
print("AIDirector:ambientIntensity done")

--@api-stub: AIDirector:setTension
-- Sets the global narrative tension level (0â€“1 scale).
-- Apply at startup or in response to user input.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:setTension(value)
print("AIDirector:setTension applied")

--@api-stub: AIDirector:reset
-- Resets or clears the state.
-- Pair with the matching constructor to free resources.
local aIDirector = lurek.ai.newAIDirector()
aIDirector:reset()
-- aIDirector is now released
print("ok")

-- ── HTNDomain methods ──

--@api-stub: HTNDomain:addPrimitive
-- Registers a primitive HTN task with a direct operator function.
-- Side-effecting; safe to call any time after init.
local hTNDomain = lurek.ai.newHTNDomain()
hTNDomain:addPrimitive("main", preconds, effects, clears)
print("HTNDomain:addPrimitive done")

--@api-stub: HTNDomain:taskCount
-- Returns or performs task count.
-- See the module spec for detailed semantics.
local hTNDomain = lurek.ai.newHTNDomain()
hTNDomain:taskCount()
print("HTNDomain:taskCount done")

-- ── EmotionModel methods ──

--@api-stub: EmotionModel:trigger
-- Returns or performs trigger.
-- See the module spec for detailed semantics.
local emotionModel = lurek.ai.newEmotionModel()
emotionModel:trigger("main", amount)
print("EmotionModel:trigger done")

--@api-stub: EmotionModel:get
-- Returns the current float value of this emotion dimension.
-- Cheap to call; safe inside callbacks.
local emotionModel = lurek.ai.newEmotionModel()  -- or your existing handle
local value = emotionModel:get("main")
print("EmotionModel:get ->", value)

--@api-stub: EmotionModel:dominant
-- Returns or performs dominant.
-- See the module spec for detailed semantics.
local emotionModel = lurek.ai.newEmotionModel()
emotionModel:dominant()
print("EmotionModel:dominant done")

--@api-stub: EmotionModel:isActive
-- Returns `true` if the emotion dimension is currently active and above threshold.
-- Use as a guard inside lurek.update or event handlers.
local emotionModel = lurek.ai.newEmotionModel()
if emotionModel:isActive("main") then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: EmotionModel:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local emotionModel = lurek.ai.newEmotionModel()
emotionModel:update(dt)
print("EmotionModel:update applied")

--@api-stub: EmotionModel:reset
-- Resets or clears the state.
-- Pair with the matching constructor to free resources.
local emotionModel = lurek.ai.newEmotionModel()
emotionModel:reset()
-- emotionModel is now released
print("ok")

-- ── ORCASolver methods ──

--@api-stub: ORCASolver:setPosition
-- Sets the agent's current world-space position for ORCA velocity computation.
-- Apply at startup or in response to user input.
local oRCASolver = lurek.ai.newORCASolver()
oRCASolver:setPosition(1, 100, 100)
print("ORCASolver:setPosition applied")

--@api-stub: ORCASolver:compute
-- Computes and returns the result.
-- See the module spec for detailed semantics.
local oRCASolver = lurek.ai.newORCASolver()
oRCASolver:compute(dt)
print("ORCASolver:compute done")

--@api-stub: ORCASolver:getSafeVelocity
-- Returns the safe velocity.
-- Cheap to call; safe inside callbacks.
local oRCASolver = lurek.ai.newORCASolver()  -- or your existing handle
local value = oRCASolver:getSafeVelocity(1)
print("ORCASolver:getSafeVelocity ->", value)

--@api-stub: ORCASolver:agentCount
-- Returns or performs agent count.
-- See the module spec for detailed semantics.
local oRCASolver = lurek.ai.newORCASolver()
oRCASolver:agentCount()
print("ORCASolver:agentCount done")

-- ── NeuralNet methods ──

--@api-stub: NeuralNet:forward
-- Returns or performs forward.
-- See the module spec for detailed semantics.
local neuralNet = lurek.ai.newNeuralNet()
neuralNet:forward(input)
print("NeuralNet:forward done")

--@api-stub: NeuralNet:setWeights
-- Overwrites all connection weights with values from a flat table.
-- Apply at startup or in response to user input.
local neuralNet = lurek.ai.newNeuralNet()
neuralNet:setWeights(weights)
print("NeuralNet:setWeights applied")

--@api-stub: NeuralNet:getWeights
-- Returns a flat table of all connection weight values in the network.
-- Cheap to call; safe inside callbacks.
local neuralNet = lurek.ai.newNeuralNet()  -- or your existing handle
local value = neuralNet:getWeights()
print("NeuralNet:getWeights ->", value)

--@api-stub: NeuralNet:paramCount
-- Returns or performs param count.
-- See the module spec for detailed semantics.
local neuralNet = lurek.ai.newNeuralNet()
neuralNet:paramCount()
print("NeuralNet:paramCount done")

--@api-stub: NeuralNet:layerCount
-- Returns or performs layer count.
-- See the module spec for detailed semantics.
local neuralNet = lurek.ai.newNeuralNet()
neuralNet:layerCount()
print("NeuralNet:layerCount done")

-- ── GeneticAlgorithm methods ──

--@api-stub: GeneticAlgorithm:evolve
-- Runs one generation of the evolutionary algorithm.
-- See the module spec for detailed semantics.
local geneticAlgorithm = lurek.ai.newGeneticAlgorithm()
geneticAlgorithm:evolve()
print("GeneticAlgorithm:evolve done")

--@api-stub: GeneticAlgorithm:generation
-- Returns or performs generation.
-- See the module spec for detailed semantics.
local geneticAlgorithm = lurek.ai.newGeneticAlgorithm()
geneticAlgorithm:generation()
print("GeneticAlgorithm:generation done")

--@api-stub: GeneticAlgorithm:popSize
-- Returns or performs pop size.
-- Pair with the matching constructor to free resources.
local geneticAlgorithm = lurek.ai.newGeneticAlgorithm()
geneticAlgorithm:popSize()
-- geneticAlgorithm is now released
print("ok")

--@api-stub: GeneticAlgorithm:setFitness
-- Sets the fitness score used by the genetic algorithm selection step.
-- Apply at startup or in response to user input.
local geneticAlgorithm = lurek.ai.newGeneticAlgorithm()
geneticAlgorithm:setFitness(1, fitness)
print("GeneticAlgorithm:setFitness applied")

--@api-stub: GeneticAlgorithm:getGenes
-- Returns the chromosome as an ordered table of gene values.
-- Cheap to call; safe inside callbacks.
local geneticAlgorithm = lurek.ai.newGeneticAlgorithm()  -- or your existing handle
local value = geneticAlgorithm:getGenes(1)
print("GeneticAlgorithm:getGenes ->", value)

--@api-stub: GeneticAlgorithm:bestGenes
-- Returns or performs best genes.
-- See the module spec for detailed semantics.
local geneticAlgorithm = lurek.ai.newGeneticAlgorithm()
geneticAlgorithm:bestGenes()
print("GeneticAlgorithm:bestGenes done")

-- ── Bandit methods ──

--@api-stub: Bandit:select
-- Returns or performs select.
-- See the module spec for detailed semantics.
local bandit = lurek.ai.newBandit()
bandit:select()
print("Bandit:select done")

--@api-stub: Bandit:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local bandit = lurek.ai.newBandit()
bandit:update(1, reward)
print("Bandit:update applied")

--@api-stub: Bandit:bestArm
-- Returns or performs best arm.
-- See the module spec for detailed semantics.
local bandit = lurek.ai.newBandit()
bandit:bestArm()
print("Bandit:bestArm done")

--@api-stub: Bandit:reset
-- Resets or clears the state.
-- Pair with the matching constructor to free resources.
local bandit = lurek.ai.newBandit()
bandit:reset()
-- bandit is now released
print("ok")

--@api-stub: Bandit:armCount
-- Returns or performs arm count.
-- See the module spec for detailed semantics.
local bandit = lurek.ai.newBandit()
bandit:armCount()
print("Bandit:armCount done")

--@api-stub: Bandit:totalPulls
-- Returns or performs total pulls.
-- See the module spec for detailed semantics.
local bandit = lurek.ai.newBandit()
bandit:totalPulls()
print("Bandit:totalPulls done")

-- ── Neuroevolution methods ──

--@api-stub: Neuroevolution:evolve
-- Runs one generation of the evolutionary algorithm.
-- See the module spec for detailed semantics.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:evolve()
print("Neuroevolution:evolve done")

--@api-stub: Neuroevolution:setFitness
-- Sets the fitness score used by the genetic algorithm selection step.
-- Apply at startup or in response to user input.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:setFitness(1, fitness)
print("Neuroevolution:setFitness applied")

--@api-stub: Neuroevolution:chromosomeToNet
-- Returns or performs chromosome to net.
-- See the module spec for detailed semantics.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:chromosomeToNet(1)
print("Neuroevolution:chromosomeToNet done")

--@api-stub: Neuroevolution:bestNetwork
-- Returns or performs best network.
-- See the module spec for detailed semantics.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:bestNetwork()
print("Neuroevolution:bestNetwork done")

--@api-stub: Neuroevolution:bestFitness
-- Returns or performs best fitness.
-- See the module spec for detailed semantics.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:bestFitness()
print("Neuroevolution:bestFitness done")

--@api-stub: Neuroevolution:popSize
-- Returns or performs pop size.
-- Pair with the matching constructor to free resources.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:popSize()
-- neuroevolution is now released
print("ok")

--@api-stub: Neuroevolution:generation
-- Returns or performs generation.
-- See the module spec for detailed semantics.
local neuroevolution = lurek.ai.newNeuroevolution()
neuroevolution:generation()
print("Neuroevolution:generation done")

-- ── StrategyAI methods ──

--@api-stub: StrategyAI:addGoal
-- Adds a strategic goal with priority score to the planner for future evaluation.
-- Side-effecting; safe to call any time after init.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:addGoal("main")
print("StrategyAI:addGoal done")

--@api-stub: StrategyAI:addTag
-- Adds a string tag to the strategy AI instance for goal filtering and categorization.
-- Side-effecting; safe to call any time after init.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:addTag("main")
print("StrategyAI:addTag done")

--@api-stub: StrategyAI:removeTag
-- Removes the specified tag.
-- Pair with the matching constructor to free resources.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:removeTag("main")
-- strategyAI is now released
print("ok")

--@api-stub: StrategyAI:update
-- Advances the simulation by one time step.
-- Apply at startup or in response to user input.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:update(dt, function() print("update fired") end)
print("StrategyAI:update applied")

--@api-stub: StrategyAI:forceEvaluate
-- Returns or performs force evaluate.
-- See the module spec for detailed semantics.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:forceEvaluate(function() print("forceEvaluate fired") end)
print("StrategyAI:forceEvaluate done")

--@api-stub: StrategyAI:activeGoal
-- Returns or performs active goal.
-- See the module spec for detailed semantics.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:activeGoal()
print("StrategyAI:activeGoal done")

--@api-stub: StrategyAI:timeUntilNext
-- Returns or performs time until next.
-- See the module spec for detailed semantics.
local strategyAI = lurek.ai.newStrategyAI()
strategyAI:timeUntilNext()
print("StrategyAI:timeUntilNext done")

-- ── AILod methods ──

--@api-stub: AILod:shouldUpdate
-- Returns or performs should update.
-- Use as a guard inside lurek.update or event handlers.
local aILod = lurek.ai.newAILod()
if aILod:shouldUpdate(tier, frame) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: AILod:tierCount
-- Returns or performs tier count.
-- See the module spec for detailed semantics.
local aILod = lurek.ai.newAILod()
aILod:tierCount()
print("AILod:tierCount done")

--@api-stub: AILod:tierName
-- Returns or performs tier name.
-- See the module spec for detailed semantics.
local aILod = lurek.ai.newAILod()
aILod:tierName(tier)
print("AILod:tierName done")

