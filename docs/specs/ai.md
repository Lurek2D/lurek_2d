# ai

## TL;DR

- The `ai` module is a comprehensive and deeply integrated Game AI toolkit designed to provide robust, scalable, and highly configurable non-player character (NPC) behavior for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ai/`
- Lua API path(s): `src/lua_api/ai_api.rs`
- Primary Lua namespace: `lurek.ai`
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua/unit/test_ai.lua, tests/lua/golden/test_ai_golden.lua, tests/lua/integration/test_ecs_ai.lua, tests/lua/integration/test_ai_physics.lua, tests/lua/integration/test_ai_pathfind.lua, tests/lua/integration/test_ai_ecs_scene.lua, tests/lua/stress/test_ai_stress.lua

## Summary

Positioned within the Feature Systems tier, the module is entirely pure CPU, headless-testable, and imposes zero rendering dependencies, making it suitable for server-side logic and highly optimized simulation loops. It imports only the `math` and `runtime` modules, maintaining strict architectural isolation.

At its core, the module offers a centralized `AIWorld` that manages registered agents and their execution. Individual `Agent` records maintain state, motion, and active decision models. To facilitate complex decision-making, the module includes over a dozen specialized subsystems. These include traditional reactive architectures like Finite State Machines (`FSM`) and Behavior Trees with a variety of composite, decorator, and leaf nodes, alongside advanced planning architectures such as Goal-Oriented Action Planning (`GOAP`) and Hierarchical Task Networks (`HTN`). For dynamic environments, Monte-Carlo Tree Search (`MCTS`) provides bounded lookahead, while `UtilityAI` allows agents to score candidate actions using response curves and considerations.

Beyond decision logic, the toolkit encompasses extensive systems for perception, steering, and learning. A robust `SensorWorld` handles visual, auditory, and custom stimuli, allowing agents to react to dynamic world events. Movement is managed through classic `Steering` behaviors (seek, flee, flock, pursue), `ContextSteering` for smooth obstacle avoidance using interest and danger maps, and `ORCA` for local crowd collision avoidance. For higher-level coordination, the `Squad` system groups agents into structured formations, while the `AIDirector` acts as an overarching pacing engine, adjusting difficulty, spawn rates, and ambient intensity dynamically based on player performance and tension metrics.

The module also integrates a suite of machine learning and adaptive systems via re-exports from the dedicated [`learning`](learning.md) module. It features multi-armed `Bandit` strategies (epsilon-greedy, UCB1, Thompson sampling), tabular `QLearner` reinforcement learning, and a lightweight `NeuralNet` supporting `Neuroevolution` via a population-based genetic algorithm. This allows for evolving behaviors over generations. Furthermore, agents can possess rich internal states using the `Emotion` and `NeedSystem` modules, alongside archetypal `TraitProfile`s that govern personality variables.

Inter-system communication is achieved seamlessly through a hierarchical `Blackboard` key-value store, while the `CommandQueue` stages interruptible actions. The entire API is thoroughly exposed via Lua bindings under the `lurek.ai.*` namespace, ensuring that developers and modders can instantiate, configure, and orchestrate these sophisticated AI tools entirely from script without wrestling with shared state.

## Files

### agent.rs

- Core runtime state for one AI actor: identity, motion, priority, and decision mode.
- Per-agent links to AI subsystems: blackboard, FSM, behavior tree, steering, and sensing.
- Optional emotion, needs, tags, and LOD data accessible through a single shared container.
- DecisionModel enum routing agents to FSM, BT, steering, or custom Lua callbacks.
- Single-call constructor initializing all fields to safe defaults with subsystem slots disconnected.

### behavior_tree.rs

- Runtime behavior tree executor for AI agents with Lua callbacks.
- For structural BT building and inspection, see [`crate::patterns::behavior_tree`].
- This module adds Lua RegistryKey-driven actions, conditions, guards, and per-tick running state.
- Behavior-tree node hierarchy with local runtime progress and last tick result.
- Control-flow variants: selector, sequence, parallel, decorator, guard, and Lua leaves.
- Subtree reset, node counting, status translation, and compact debug snapshots.
- Running state per composite node enabling cross-tick resume from last active child.
- Parallel policy configuration with independent success and failure thresholds.
- Root node container used as the single-instance tree by the per-agent AI runtime.

### blackboard.rs

- Agent blackboard: shared read/write key-value memory for behaviour-tree nodes.
- Stores typed values (`bool`, `i32`, `f32`, `String`) under string keys.
- Designed for single-agent or squad-shared access within one Lua game tick.
- Values are reset or persisted per agent lifecycle at the call site's discretion.
- Used by BT nodes to communicate patrol targets, attack counts, and state flags.

### command_queue.rs

- Queued command format staging discrete actor actions with targets, callbacks, and priority.
- FIFO command queue with front insertion, replacement, cancellation, and advance operations.
- Raw-construction helpers for enqueuing commands without separate struct building.
- Interruptible commands that can be cancelled individually without clearing the queue.
- Structured runtime logging for queue creation and bulk-clear events.

### context_steering.rs

- Slot-based context steering accumulating interest and danger around a directional ring.
- Behavior variants projecting targets, hazards, wander, fixed headings, and world-bound avoidance.
- Evaluation pass merging contributions and choosing the strongest safe direction.
- Seek-target interest projection using an angle cone toward the target position.
- Hash-based wander jitter biasing direction over time without explicit random state.
- Per-slot danger subtraction so agents steer around hazards while maintaining progress.
- Last chosen heading and magnitude recording for downstream movement application.
- Inspection accessors for interest and danger maps useful for debug visualization.
- Uses cosine-attenuated cone fill to smoothly distribute weights across
- neighboring slots near a target angle.

### director.rs

- Pacing director translating accumulated tension into pressure phases and runtime multipliers.
- Tunable thresholds and timers moving between buildup, peak, sustain, and relief phases.
- Derived outputs for spawn pressure, loot pressure, ambient intensity, and state inspection.
- Slower tension decay during peak and sustain phases to hold pressure before relief.
- Per-phase spawn, loot, and ambient multipliers scaling downstream gameplay intensity.

### emotion.rs

- Per-agent emotion state tracking named feelings as clamped scalars decaying toward rest.
- Single-emotion rules for activation thresholds, direct setting, triggering, and decay.
- Model-level add, replace, query, dominant-state lookup, update, and reset operations.
- Value clamping to [0, 1] at the write boundary preventing out-of-range propagation.
- Dominant emotion identification by filtering active entries and selecting highest value.

### fsm.rs

- Runtime state machine executor for AI agents.
- For structural FSM definition and graph validation, see [`crate::patterns::state_machine`].
- This module adds Lua callback execution, priority-based transitions, and per-frame time tracking.
- Finite-state-machine storing named states, callback hooks, transition rules, and active state.
- Callback bundles for state entry, update, and exit with priority-sorted transition records.
- Mutable machine state tracking current state, initial state, elapsed time, and registration helpers.
- Descending-priority transition sorting so the tick evaluator tests highest-priority guards first.
- Elapsed time tracking in the current state for time-based guards and Lua update callbacks.

### goap.rs

- GOAP planning data storing actions, goals, search nodes, and planner state.
- World-state model built from boolean preconditions, effects, and goal priorities.
- Optional Lua execution callbacks attached to actions for runtime behavior.
- Bounded A* search expanding reachable states and returning ordered action plans.
- Unsatisfied-condition count heuristic guiding A* toward goals with minimal expansion.
- Automatic highest-priority goal selection or targeted planning by goal index.
- Iteration cap preventing runaway planning on large or unsolvable state spaces.
- Search node tracking with parent links for plan reconstruction after goal reach.

### htn.rs

- HTN planning model representing symbolic world state, tasks, methods, and the task registry.
- Primitive tasks mutating state directly and compound tasks expanding through methods.
- Recursive decomposition of a root task into a linear primitive plan with precondition checks.
- Float-threshold preconditions on world-state keys expressing partial satisfaction.
- Recursion depth cap at 128 levels preventing infinite expansion in cyclic task domains.

### lod.rs

- AI level-of-detail model grouping agents into distance-based update tiers.
- Tier data controlling maximum coverage, think distance, and frame cadence.
- Tier sorting, agent assignment from positions, and per-frame run decisions.
- Frame-cadence check so distant agents skip updates while near agents run every frame.
- Default three-tier near/mid/far layout suitable for 2D worlds on integrated GPUs.

### mcts.rs

- Monte Carlo Tree Search configuring search parameters, arena-backed nodes, and rollout statistics.
- Selection, expansion, rollout, and backpropagation flow scoring actions through bounded simulations.
- Internal random helper and UCT scoring logic driving node choice and action sampling.
- Arena-backed tree structure avoiding per-node heap allocations during iterative search.
- Generic state, action-enumeration, transition, and evaluation closures for domain-independent search.

### mod.rs

- Public AI module surface grouping planning, decision, control, memory, and movement subsystems.
- Module-level export map for agent state, planners, blackboard, and command flow.
- Learning helpers, perception, steering, and squad coordination re-exports.
- Compact entry surface re-exporting runtime types for higher engine layers.

### needs.rs

- Need-tracking model with normalized internal drives, urgency settings, and external advertisements.
- Per-need decay, urgency scoring, satisfaction updates, and cooldown-aware advertisement scoring.
- System-level operations for adding needs, time-based updates, and most-urgent drive selection.
- Best-advertisement selection weighted by distance, cooldown, and need priority.

### orca.rs

- ORCA local-avoidance data representing moving agents, solver constraints, and safe output velocities.
- Per-agent motion inputs: current velocity, preferred velocity, collision radius, and max speed.
- Solver pass building pairwise half-plane constraints and projecting collision-free velocities.

### perception.rs

- Perception model storing stimuli, sensor configuration, detection results, and awareness state.
- Stimulus world for visual, auditory, and custom signals with insertion, decay, and removal.
- Sensor-side logic testing visibility, hearing, detecting nearby stimuli, and updating awareness.
- Custom detection range tracking and time-based stimulus expiration.

### render.rs

- AI debug rendering helpers turning FSM and behavior-tree state into renderer commands.
- Layout and traversal logic walking state-machine and tree data with position assignment.
- Image drawing helpers mirroring structures into offline ImageData for inspection.

### squad.rs

- Squad-level coordination grouping named members under one leader with shared local memory.
- Formation mode, spacing, and ordered membership determining relative placement.
- Formation-position logic producing target offsets for line, column, wedge, and circle patterns.

### steering.rs

- Steering model representing individual movement behaviors, blending rules, and waypoint following.
- Behavior variants: seek, flee, arrive, wander, flock, pursue, evade, and custom callbacks.
- Manager logic combining active behaviors with weighting or priority selection.
- Waypoint path advancement and final steering force clamping.

### strategy.rs

- High-level strategy selection scoring named goals against current tag context over time.
- Goal records with eligibility tags, priority scaling, enable state, and computed scores.
- Timed evaluation flow querying external scorers and storing the active strategic choice.

### traits.rs

- Personality-trait model storing base values, temporary modifiers, and reusable archetype presets.
- Profile logic resolving effective trait values, advancing and removing expiring modifiers.
- Interpolation toward other profiles with origin archetype tracking.
- Archetype registry and deterministic hash helper for varied profiles with per-trait jitter.

### utility_ai.rs

- Utility-AI scoring model storing actions, response curves, considerations, and evaluation results.
- Response-curve mapping rules and action-side data binding Lua scorers with momentum weighting.
- Evaluation flow calling registered scorers, tracking per-action scores, and selecting best action.

### world.rs

- Shared AI world container owning registered agents, name-to-index lookup, and global blackboard.
- Lifecycle operations adding or removing named agents with synchronized lookup tables.
- World update surface exposing global blackboard access and velocity-based position integration.

## Lua API Ref

- Binding: `src/lua_api/ai_api.rs`
- Namespace: `lurek.ai`

### Functions

- `lurek.ai.newAIDirector`: Creates an AI director for tension, phase, and pacing factor calculations.
- `lurek.ai.newAILod`: Creates a default AI level-of-detail tier selector.
- `lurek.ai.newAction`: Creates a behavior tree action leaf backed by a Lua callback.
- `lurek.ai.newBandit`: Creates a multi-armed bandit with a named selection strategy.
- `lurek.ai.newBehaviorTree`: Creates an empty behavior tree that can receive a root node.
- `lurek.ai.newBlackboard`: Creates an empty AI blackboard for typed local facts.
- `lurek.ai.newCommandQueue`: Creates an empty command queue for callback-backed AI commands.
- `lurek.ai.newCondition`: Creates a behavior tree condition leaf backed by a Lua callback.
- `lurek.ai.newContextSteering`: Creates a context steering model with the requested directional slot count.
- `lurek.ai.newDialogueAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.ai.newEmotionModel`: Creates an empty emotion model for named decaying emotion values.
- `lurek.ai.newGOAPPlanner`: Creates an empty GOAP planner for boolean world-state planning.
- `lurek.ai.newGeneticAlgorithm`: Creates a genetic algorithm population with fixed chromosome length.
- `lurek.ai.newGuard`: Creates a guard decorator that runs a predicate before ticking its child.
- `lurek.ai.newHTNDomain`: Creates an empty hierarchical task network domain.
- `lurek.ai.newInfluenceMap`: Creates a grid influence map with the supplied cell dimensions and world cell size.
- `lurek.ai.newInverter`: Creates a behavior tree inverter decorator with an empty sequence child.
- `lurek.ai.newMCTSEngine`: Creates a Monte Carlo tree search engine with deterministic configuration.
- `lurek.ai.newNeedSystem`: Creates an empty need system for decaying named needs.
- `lurek.ai.newNeuralNet`: Creates an empty feed-forward neural network.
- `lurek.ai.newNeuroevolution`: Creates a neuroevolution population from a layer specification table.
- `lurek.ai.newORCASolver`: Creates an ORCA avoidance solver with the supplied prediction horizon.
- `lurek.ai.newParallel`: Creates a behavior tree parallel node with optional success and failure policies.
- `lurek.ai.newQLearner`: Creates a Q-learner with fixed state and action counts.
- `lurek.ai.newRepeater`: Creates a behavior tree repeater decorator with an optional repeat count.
- `lurek.ai.newSelector`: Creates a behavior tree selector node with no children.
- `lurek.ai.newSequence`: Creates a behavior tree sequence node with no children.
- `lurek.ai.newSquad`: Creates an empty named squad. This function is exposed to Lua scripts.
- `lurek.ai.newStateMachine`: Creates an empty finite state machine with Lua-backed states and transitions.
- `lurek.ai.newSteeringManager`: Creates an empty steering manager with support for built-in and custom behaviors.
- `lurek.ai.newStimulusWorld`: Creates an empty stimulus world for visual and auditory stimulus records.
- `lurek.ai.newStrategyAI`: Creates a strategy AI that reevaluates goals on a fixed interval.
- `lurek.ai.newSucceeder`: Creates a behavior tree succeeder decorator with an empty sequence child.
- `lurek.ai.newTraitProfile`: Creates an empty trait profile with modifier support.
- `lurek.ai.newUtilityAI`: Creates an empty utility AI action scorer.
- `lurek.ai.newWorld`: Creates an isolated AI world for agents, blackboards, and custom decision callbacks.

### Enums

- No documented module-level enums/constants.

### Types


#### LAIBlackboard Type


##### Fields

- No documented fields.

##### Methods

- `LAIBlackboard:clear`: Removes every local entry from this blackboard.
- `LAIBlackboard:getBool`: Returns a boolean blackboard fact or the provided fallback when the key is missing or not boolean.
- `LAIBlackboard:getKeys`: Returns every local blackboard key in an array-style Lua table.
- `LAIBlackboard:getNumber`: Returns a numeric blackboard fact or the provided fallback when the key is missing or not numeric.
- `LAIBlackboard:getSize`: Returns the number of entries currently stored in this blackboard.
- `LAIBlackboard:getString`: Returns a string blackboard fact or the provided fallback when the key is missing or not a string.
- `LAIBlackboard:has`: Returns whether the blackboard contains any entry for the given key.
- `LAIBlackboard:remove`: Removes the given key from the blackboard if it exists.
- `LAIBlackboard:setBool`: Stores a boolean fact under the given blackboard key.
- `LAIBlackboard:setNumber`: Stores a numeric fact under the given blackboard key.
- `LAIBlackboard:setString`: Stores a string fact under the given blackboard key.
- `LAIBlackboard:type`: Returns the Lua-visible type name for this blackboard handle.
- `LAIBlackboard:typeOf`: Returns whether this blackboard handle matches a supported type name.


#### LAIDirector Type


##### Fields

- No documented fields.

##### Methods

- `LAIDirector:ambientIntensity`: Returns the ambient intensity derived from current tension and phase.
- `LAIDirector:lootFactor`: Returns the loot multiplier derived from current tension and phase.
- `LAIDirector:phase`: Returns the current director phase name.
- `LAIDirector:pushEvent`: Adds an event intensity sample to the director tension model.
- `LAIDirector:reset`: Resets director tension and phase state to defaults.
- `LAIDirector:setTension`: Directly sets the director tension value.
- `LAIDirector:spawnRateFactor`: Returns the spawn-rate multiplier derived from current tension and phase.
- `LAIDirector:tension`: Returns the current director tension value.
- `LAIDirector:type`: Returns the Lua-visible type name for this AI director handle.
- `LAIDirector:typeOf`: Returns whether this AI director handle matches a supported type name.
- `LAIDirector:update`: Advances director tension decay and phase evaluation.


#### LAILod Type


##### Fields

- No documented fields.

##### Methods

- `LAILod:shouldUpdate`: Returns whether a tier should update on a given frame counter.
- `LAILod:tierCount`: Returns the number of configured AI LOD tiers.
- `LAILod:tierFor`: Returns the LOD tier for an agent position relative to a reference position.
- `LAILod:tierName`: Returns the name of an AI LOD tier when the index is valid.
- `LAILod:type`: Returns the Lua-visible type name for this AI LOD handle.
- `LAILod:typeOf`: Returns whether this AI LOD handle matches a supported type name.


#### LAIWorld Type


##### Fields

- No documented fields.

##### Methods

- `LAIWorld:addAgent`: Creates a named agent in this world and returns a handle that can edit its movement and decision state.
- `LAIWorld:getAgent`: Returns the named agent handle when it exists in this world.
- `LAIWorld:getAgentCount`: Returns the number of agents currently stored in this world.
- `LAIWorld:getGlobalBlackboard`: Returns a blackboard snapshot containing the world's shared AI facts.
- `LAIWorld:removeAgent`: Removes an agent from this world by using an existing agent handle.
- `LAIWorld:type`: Returns the Lua-visible type name for this AI world handle.
- `LAIWorld:typeOf`: Returns whether this AI world handle matches a supported type name.
- `LAIWorld:update`: Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.


#### LBTNode Type


##### Fields

- No documented fields.

##### Methods

- `LBTNode:addChild`: Adds a child node to a composite selector, sequence, or parallel node.
- `LBTNode:getChildCount`: Returns the number of children owned by this behavior tree node.
- `LBTNode:getCount`: Returns the repeat count for repeater nodes or zero for other node kinds.
- `LBTNode:getNodeType`: Returns the behavior tree node kind as a lowercase string.
- `LBTNode:reset`: Resets this behavior tree node's runtime state.
- `LBTNode:setChild`: Sets the single child of a decorator node such as inverter, repeater, or succeeder.
- `LBTNode:setCount`: Sets the repeat count when this node is a repeater.
- `LBTNode:setFailurePolicy`: Sets the failure policy for a parallel node.
- `LBTNode:setSuccessPolicy`: Sets the success policy for a parallel node.
- `LBTNode:type`: Returns the Lua-visible type name for this behavior tree node handle.
- `LBTNode:typeOf`: Returns whether this behavior tree node handle matches a supported type name.


#### LBehaviorTree Type


##### Fields

- No documented fields.

##### Methods

- `LBehaviorTree:getDebugState`: Returns behavior tree debug counters and status in a Lua table.
- `LBehaviorTree:getLastStatus`: Returns the last behavior tree status string recorded by the tree.
- `LBehaviorTree:setRoot`: Sets the behavior tree root by moving a node handle into the tree.
- `LBehaviorTree:type`: Returns the Lua-visible type name for this behavior tree handle.
- `LBehaviorTree:typeOf`: Returns whether this behavior tree handle matches a supported type name.


#### LBot Type


##### Fields

- No documented fields.

##### Methods

- `LBot:addTag`: Adds a tag string to this agent when the agent still exists in its world.
- `LBot:getBlackboard`: Returns a blackboard snapshot for this agent or an empty blackboard when the agent has been removed.
- `LBot:getDecisionModel`: Returns this agent's decision model name or the default model name for a missing agent.
- `LBot:getMaxForce`: Returns this agent's maximum steering force or the default force for a missing agent.
- `LBot:getMaxSpeed`: Returns this agent's maximum movement speed or the default speed for a missing agent.
- `LBot:getName`: Returns this agent's stable world name.
- `LBot:getPosition`: Returns this agent's world position or the origin when the agent has been removed.
- `LBot:getPriority`: Returns this agent's integer priority or zero when the agent has been removed.
- `LBot:getVelocity`: Returns this agent's velocity vector or zero velocity when the agent has been removed.
- `LBot:hasTag`: Returns whether this agent currently has the given tag.
- `LBot:removeTag`: Removes a tag string from this agent when the agent still exists in its world.
- `LBot:setCustomModel`: Installs a Lua callback as this agent's decision model and stores it in the callback registry.
- `LBot:setDecisionModel`: Sets this agent's built-in decision model from a string name when the name is recognized.
- `LBot:setMaxForce`: Sets this agent's maximum steering force when the agent still exists in its world.
- `LBot:setMaxSpeed`: Sets this agent's maximum movement speed when the agent still exists in its world.
- `LBot:setPosition`: Sets this agent's world position when the agent still exists in its world.
- `LBot:setPriority`: Sets this agent's integer priority when the agent still exists in its world.
- `LBot:setVelocity`: Sets this agent's velocity vector when the agent still exists in its world.
- `LBot:type`: Returns the Lua-visible type name for this agent handle.
- `LBot:typeOf`: Returns whether this agent handle matches a supported type name.


#### LCommandQueue Type


##### Fields

- No documented fields.

##### Methods

- `LCommandQueue:cancelCurrent`: Cancels the currently active command when one exists.
- `LCommandQueue:clear`: Removes every queued command. This method is available to Lua scripts.
- `LCommandQueue:enqueue`: Adds a command callback to the back of the queue.
- `LCommandQueue:getCount`: Returns the number of commands currently queued.
- `LCommandQueue:getCurrentTarget`: Returns the current command target coordinates.
- `LCommandQueue:getCurrentType`: Returns the type label of the current command when one exists.
- `LCommandQueue:isEmpty`: Returns whether the command queue has no commands.
- `LCommandQueue:pushFront`: Adds a command callback to the front of the queue.
- `LCommandQueue:replace`: Replaces the queue contents with one command callback.
- `LCommandQueue:type`: Returns the Lua-visible type name for this command queue handle.
- `LCommandQueue:typeOf`: Returns whether this command queue handle matches a supported type name.


#### LContextSteering Type


##### Fields

- No documented fields.

##### Methods

- `LContextSteering:addAvoidBounds`: Adds rectangular bounds avoidance to context steering.
- `LContextSteering:addAvoidPoint`: Adds a point avoidance influence to context steering.
- `LContextSteering:addSeekTarget`: Adds a context steering target attraction.
- `LContextSteering:addWander`: Adds wander noise to context steering.
- `LContextSteering:chosenMagnitude`: Returns the magnitude of the last selected context steering slot.
- `LContextSteering:clearBehaviors`: Removes all context steering behaviors.
- `LContextSteering:evaluate`: Evaluates context steering and returns the selected movement direction.
- `LContextSteering:slotCount`: Returns the number of directional slots used by this context steering model.
- `LContextSteering:type`: Returns the Lua-visible type name for this context steering handle.
- `LContextSteering:typeOf`: Returns whether this context steering handle matches a supported type name.


#### LEmotionModel Type


##### Fields

- No documented fields.

##### Methods

- `LEmotionModel:add`: Adds an emotion definition with resting value, decay, and visibility threshold.
- `LEmotionModel:dominant`: Returns the strongest active emotion name when one is available.
- `LEmotionModel:get`: Returns the current value of a named emotion.
- `LEmotionModel:isActive`: Returns whether a named emotion is currently active.
- `LEmotionModel:reset`: Resets all emotions toward their default state.
- `LEmotionModel:trigger`: Adds an amount to a named emotion. This method is available to Lua scripts.
- `LEmotionModel:type`: Returns the Lua-visible type name for this emotion model handle.
- `LEmotionModel:typeOf`: Returns whether this emotion model handle matches a supported type name.
- `LEmotionModel:update`: Advances emotion decay over elapsed time.


#### LGOAPPlanner Type


##### Fields

- No documented fields.

##### Methods

- `LGOAPPlanner:addAction`: Adds a GOAP action with optional cost and completion callback.
- `LGOAPPlanner:addGoal`: Adds a GOAP goal with an optional priority weight.
- `LGOAPPlanner:getActionCount`: Returns the number of GOAP actions registered in this planner.
- `LGOAPPlanner:getGoalCount`: Returns the number of GOAP goals registered in this planner.
- `LGOAPPlanner:getMaxIterations`: Returns the maximum number of planner iterations allowed during search.
- `LGOAPPlanner:plan`: Builds a plan from the supplied boolean world state and returns action names in execution order.
- `LGOAPPlanner:setEffect`: Sets one boolean effect produced by an existing GOAP action.
- `LGOAPPlanner:setGoalState`: Sets one desired world-state key for an existing GOAP goal.
- `LGOAPPlanner:setMaxIterations`: Sets the maximum number of planner iterations allowed during search.
- `LGOAPPlanner:setPrecondition`: Sets one boolean precondition for an existing GOAP action.
- `LGOAPPlanner:type`: Returns the Lua-visible type name for this GOAP planner handle.
- `LGOAPPlanner:typeOf`: Returns whether this GOAP planner handle matches a supported type name.


#### LHTNDomain Type


##### Fields

- No documented fields.

##### Methods

- `LHTNDomain:addCompound`: Adds a compound HTN task with one or more ordered method definitions.
- `LHTNDomain:addPrimitive`: Adds a primitive HTN task with preconditions, effects, and cleared facts.
- `LHTNDomain:plan`: Plans from a root HTN task and numeric world state facts.
- `LHTNDomain:taskCount`: Returns the number of tasks defined in this HTN domain.
- `LHTNDomain:type`: Returns the Lua-visible type name for this HTN domain handle.
- `LHTNDomain:typeOf`: Returns whether this HTN domain handle matches a supported type name.


#### LInfluenceMap Type


##### Fields

- No documented fields.

##### Methods

- `LInfluenceMap:addLayer`: Adds an influence layer with the given name if it does not already exist.
- `LInfluenceMap:blend`: Blends two source layers into a destination layer using independent weights.
- `LInfluenceMap:clearAll`: Clears every influence value in every layer.
- `LInfluenceMap:clearLayer`: Clears every value in a named influence layer.
- `LInfluenceMap:decay`: Multiplies a named layer by a decay factor.
- `LInfluenceMap:getCellSize`: Returns the world size represented by each influence map cell.
- `LInfluenceMap:getHeight`: Returns the influence map height in cells.
- `LInfluenceMap:getInfluence`: Returns one cell value from a named influence layer using one-based cell coordinates.
- `LInfluenceMap:getMaxPosition`: Returns the cell position with the highest value on a named layer.
- `LInfluenceMap:getMinPosition`: Returns the cell position with the lowest value on a named layer.
- `LInfluenceMap:getWidth`: Returns the influence map width in cells.
- `LInfluenceMap:hasLayer`: Returns whether an influence layer exists.
- `LInfluenceMap:propagate`: Propagates influence values across neighboring cells on a named layer.
- `LInfluenceMap:queryRect`: Returns influence values inside a world-space rectangle on a named layer.
- `LInfluenceMap:setInfluence`: Sets one cell value in a named influence layer using one-based cell coordinates.
- `LInfluenceMap:stampInfluence`: Applies a radial influence stamp to a named layer in world coordinates.
- `LInfluenceMap:type`: Returns the Lua-visible type name for this influence map handle.
- `LInfluenceMap:typeOf`: Returns whether this influence map handle matches a supported type name.


#### LMCTSEngine Type


##### Fields

- No documented fields.

##### Methods

- `LMCTSEngine:search`: Runs MCTS from a root state using Lua callbacks for actions, transitions, and evaluation.
- `LMCTSEngine:type`: Returns the Lua-visible type name for this MCTS engine handle.
- `LMCTSEngine:typeOf`: Returns whether this MCTS engine handle matches a supported type name.


#### LNeedSystem Type


##### Fields

- No documented fields.

##### Methods

- `LNeedSystem:addNeed`: Adds a need with decay and urgency tuning values.
- `LNeedSystem:mostUrgent`: Returns the name of the most urgent need when any need is active.
- `LNeedSystem:satisfy`: Reduces or satisfies a named need by the supplied amount.
- `LNeedSystem:type`: Returns the Lua-visible type name for this need system handle.
- `LNeedSystem:typeOf`: Returns whether this need system handle matches a supported type name.
- `LNeedSystem:update`: Advances need decay over elapsed time.
- `LNeedSystem:valueOf`: Returns the current value of a named need.


#### LORCASolver Type


##### Fields

- No documented fields.

##### Methods

- `LORCASolver:addAgent`: Adds an ORCA avoidance agent and returns its zero-based solver index.
- `LORCASolver:agentCount`: Returns the number of ORCA agents in this solver.
- `LORCASolver:compute`: Computes safe velocities for all ORCA agents.
- `LORCASolver:getSafeVelocity`: Returns the computed safe velocity for an ORCA agent.
- `LORCASolver:setPosition`: Sets the position for an ORCA agent by zero-based index.
- `LORCASolver:setPreferredVelocity`: Sets the preferred velocity for an ORCA agent by zero-based index.
- `LORCASolver:type`: Returns the Lua-visible type name for this ORCA solver handle.
- `LORCASolver:typeOf`: Returns whether this ORCA solver handle matches a supported type name.


#### LSquad Type


##### Fields

- No documented fields.

##### Methods

- `LSquad:addMember`: Adds a member name to the squad member list.
- `LSquad:getBlackboard`: Returns a blackboard snapshot for this squad.
- `LSquad:getFormation`: Returns the current squad formation type name.
- `LSquad:getFormationPosition`: Returns a member's target formation position relative to the leader position.
- `LSquad:getFormationSpacing`: Returns the spacing used by squad formation positioning.
- `LSquad:getLeader`: Returns the squad leader name when one is assigned.
- `LSquad:getMemberCount`: Returns the number of members in this squad.
- `LSquad:getMembers`: Returns all squad members in an array-style Lua table.
- `LSquad:getName`: Returns the squad name. This method is available to Lua scripts.
- `LSquad:removeMember`: Removes every member entry with the given name.
- `LSquad:setFormation`: Sets the squad formation type and optionally updates spacing.
- `LSquad:setLeader`: Sets the squad leader name. This method is available to Lua scripts.
- `LSquad:type`: Returns the Lua-visible type name for this squad handle.
- `LSquad:typeOf`: Returns whether this squad handle matches a supported type name.


#### LStateMachine Type


##### Fields

- No documented fields.

##### Methods

- `LStateMachine:addState`: Adds a state with optional Lua lifecycle callbacks.
- `LStateMachine:addTransition`: Adds a transition between two states with an optional guard callback and priority.
- `LStateMachine:forceState`: Immediately switches the current state and resets the time spent in state.
- `LStateMachine:getCurrentState`: Returns the current state name when the state machine has entered a state.
- `LStateMachine:getTimeInState`: Returns how long the machine has spent in the current state.
- `LStateMachine:setInitialState`: Sets the initial state and also enters it when the machine has no current state yet.
- `LStateMachine:type`: Returns the Lua-visible type name for this state machine handle.
- `LStateMachine:typeOf`: Returns whether this state machine handle matches a supported type name.


#### LSteeringManager Type


##### Fields

- No documented fields.

##### Methods

- `LSteeringManager:addArrive`: Adds an arrive behavior that slows the agent as it approaches a target point.
- `LSteeringManager:addCustomBehavior`: Adds a custom steering behavior backed by a Lua callback.
- `LSteeringManager:addEvade`: Adds an evade behavior that moves away from another named agent when a threat name is supplied.
- `LSteeringManager:addFlee`: Adds a flee behavior that pushes the agent away from a target point inside a panic distance.
- `LSteeringManager:addFlock`: Adds a flocking behavior with separation, alignment, and cohesion weights.
- `LSteeringManager:addPursue`: Adds a pursue behavior that chases another named agent when a target name is supplied.
- `LSteeringManager:addSeek`: Adds a seek behavior that pulls the agent toward a target point.
- `LSteeringManager:addWander`: Adds a wander behavior that produces jittered exploratory movement.
- `LSteeringManager:applyCustomSteering`: Runs enabled custom steering callbacks for an agent and returns the weighted combined force.
- `LSteeringManager:calculate`: Calculates a steering force for the supplied agent movement state.
- `LSteeringManager:clearPath`: Clears the active waypoint path behavior.
- `LSteeringManager:enableSpatialHash`: Enables or disables spatial hash acceleration for neighbor queries.
- `LSteeringManager:getBehaviorCount`: Returns the number of steering behaviors configured on this manager.
- `LSteeringManager:getCombineMode`: Returns the current steering force combination mode.
- `LSteeringManager:getLastSteering`: Returns the last steering force calculated by this manager.
- `LSteeringManager:getPathProgress`: Returns the current one-based waypoint index and total waypoint count.
- `LSteeringManager:hasPath`: Returns whether this manager currently has an active waypoint path.
- `LSteeringManager:setCombineMode`: Sets how steering behavior forces are combined.
- `LSteeringManager:setPath`: Sets a waypoint path behavior from an array of `{x, y}` tables.
- `LSteeringManager:setSpatialHashCellSize`: Sets the cell size used by the steering manager spatial hash.
- `LSteeringManager:type`: Returns the Lua-visible type name for this steering manager handle.
- `LSteeringManager:typeOf`: Returns whether this steering manager handle matches a supported type name.


#### LStimulusWorld Type


##### Fields

- No documented fields.

##### Methods

- `LStimulusWorld:addAuditory`: Adds an auditory stimulus with decay and returns its identifier.
- `LStimulusWorld:addVisual`: Adds a visual stimulus and returns its identifier.
- `LStimulusWorld:clear`: Removes every active stimulus. This method is available to Lua scripts.
- `LStimulusWorld:count`: Returns the number of active stimuli.
- `LStimulusWorld:remove`: Removes a stimulus by identifier. This method is available to Lua scripts.
- `LStimulusWorld:type`: Returns the Lua-visible type name for this stimulus world handle.
- `LStimulusWorld:typeOf`: Returns whether this stimulus world handle matches a supported type name.
- `LStimulusWorld:update`: Advances stimulus decay and lifetime state.


#### LStrategyAI Type


##### Fields

- No documented fields.

##### Methods

- `LStrategyAI:activeGoal`: Returns the currently active strategic goal when one is selected.
- `LStrategyAI:addGoal`: Adds a named strategic goal. This method is available to Lua scripts.
- `LStrategyAI:addTag`: Adds a context tag to this strategy AI.
- `LStrategyAI:forceEvaluate`: Immediately scores all goals and updates the active goal.
- `LStrategyAI:removeTag`: Removes a context tag from this strategy AI.
- `LStrategyAI:timeUntilNext`: Returns time remaining until the next scheduled strategy evaluation.
- `LStrategyAI:type`: Returns the Lua-visible type name for this strategy AI handle.
- `LStrategyAI:typeOf`: Returns whether this strategy AI handle matches a supported type name.
- `LStrategyAI:update`: Advances strategy timing and scores goals when the update interval has elapsed.


#### LTraitProfile Type


##### Fields

- No documented fields.

##### Methods

- `LTraitProfile:addModifier`: Adds a temporary or permanent modifier to a named trait.
- `LTraitProfile:archetype`: Returns the best matching archetype name when the profile can classify one.
- `LTraitProfile:get`: Returns the current value of a named trait including active modifiers.
- `LTraitProfile:getBase`: Returns the base value of a named trait without temporary modifiers.
- `LTraitProfile:has`: Returns whether the profile has a named trait.
- `LTraitProfile:removeModifiers`: Removes all trait modifiers that match a source label.
- `LTraitProfile:set`: Sets the base value for a named trait.
- `LTraitProfile:traitCount`: Returns the number of traits stored in the profile.
- `LTraitProfile:type`: Returns the Lua-visible type name for this trait profile handle.
- `LTraitProfile:typeOf`: Returns whether this trait profile handle matches a supported type name.
- `LTraitProfile:update`: Advances modifier timers and removes expired modifiers.


#### LUtilityAI Type


##### Fields

- No documented fields.

##### Methods

- `LUtilityAI:addAction`: Adds an action scored by a Lua callback and optional momentum weight.
- `LUtilityAI:addConsideration`: Adds a consideration scorer and response curve to an existing utility action.
- `LUtilityAI:evaluate`: Evaluates all actions and returns the winning action name when one is available.
- `LUtilityAI:getActionCount`: Returns the number of actions registered in this utility AI.
- `LUtilityAI:getLastAction`: Returns the last winning action name when evaluation has selected one.
- `LUtilityAI:type`: Returns the Lua-visible type name for this utility AI handle.
- `LUtilityAI:typeOf`: Returns whether this utility AI handle matches a supported type name.

## References

- `dialog`: Imports or references `src/dialog/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `learning`: Imports or references `src/learning/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `patterns`: Imports or references `src/patterns/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.
