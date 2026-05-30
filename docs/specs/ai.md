# ai

## TL;DR

- The `ai` module is a comprehensive and deeply integrated Game AI toolkit designed to provide robust, scalable, and highly configurable non-player character (NPC) behavior for Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ai/`
- Binding: `src/lua_api/ai_api.rs`
- Namespace: `lurek.ai`
- Lua API surface: `36` functions, `24` types, `237` methods
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua/unit/test_ai.lua, tests/lua/golden/test_ai_golden.lua, tests/lua/integration/test_ecs_ai.lua, tests/lua/integration/test_ai_physics.lua, tests/lua/integration/test_ai_pathfind.lua, tests/lua/integration/test_ai_ecs_scene.lua, tests/lua/stress/test_ai_stress.lua

## Summary

Positioned within the Feature Systems tier, the module is entirely pure CPU, headless-testable, and imposes zero rendering dependencies, making it suitable for server-side logic and highly optimized simulation loops. It imports only the `math` and `runtime` modules, maintaining strict architectural isolation.

At its core, the module offers a centralized `AIWorld` that manages registered agents and their execution. Individual `Agent` records maintain state, motion, and active decision models. To facilitate complex decision-making, the module includes over a dozen specialized subsystems. These include traditional reactive architectures like Finite State Machines (`FSM`) and Behavior Trees with a variety of composite, decorator, and leaf nodes, alongside advanced planning architectures such as Goal-Oriented Action Planning (`GOAP`) and Hierarchical Task Networks (`HTN`). For dynamic environments, Monte-Carlo Tree Search (`MCTS`) provides bounded lookahead, while `UtilityAI` allows agents to score candidate actions using response curves and considerations.

Beyond decision logic, the toolkit encompasses extensive systems for perception, steering, and learning. A robust `SensorWorld` handles visual, auditory, and custom stimuli, allowing agents to react to dynamic world events. Movement is managed through classic `Steering` behaviors (seek, flee, flock, pursue), `ContextSteering` for smooth obstacle avoidance using interest and danger maps, and `ORCA` for local crowd collision avoidance. For higher-level coordination, the `Squad` system groups agents into structured formations, while the `AIDirector` acts as an overarching pacing engine, adjusting difficulty, spawn rates, and ambient intensity dynamically based on player performance and tension metrics.

The module also integrates a suite of machine learning and adaptive systems via re-exports from the dedicated [`learning`](learning.md) module. It features multi-armed `Bandit` strategies (epsilon-greedy, UCB1, Thompson sampling), tabular `QLearner` reinforcement learning, and a lightweight `NeuralNet` supporting `Neuroevolution` via a population-based genetic algorithm. This allows for evolving behaviors over generations. Furthermore, agents can possess rich internal states using the `Emotion` and `NeedSystem` modules, alongside archetypal `TraitProfile`s that govern personality variables.

Inter-system communication is achieved seamlessly through a hierarchical `Blackboard` key-value store re-exported from [`patterns`](patterns.md), while the `CommandQueue` stages interruptible actions. The entire API is thoroughly exposed via Lua bindings under the `lurek.ai.*` namespace, ensuring that developers and modders can instantiate, configure, and orchestrate these sophisticated AI tools entirely from script without wrestling with shared state.

## Imports

- `dialog`: Imports or references `src/dialog/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `learning`: Imports or references `src/learning/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `patterns`: Imports or references `src/patterns/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### agent.rs

- Defines the full runtime shape of one AI actor as a single cohesive control unit.
- Blends identity, movement, tactical priority, and decision style into one state heartbeat.
- Keeps planner-facing memory, sensing, affect, motives, traits, and squad semantics aligned.
- Preserves stable cross-system handoff so world updates read one consistent behavioral snapshot.
- Serves as the anchor object that orchestration layers drive without leaking subsystem coupling.

### behavior_tree.rs

- Implements a behavior orchestration lattice that evaluates intent through composable control flow.
- Carries running status across ticks so long actions keep temporal continuity instead of restarting.
- Balances branching policies to prefer resilient progress under mixed success and failure outcomes.
- Threads guard logic and decorator shaping into each decision pulse without breaking determinism.
- Emits inspectable execution state that tools can render as readable runtime decision rhythm.
- Provides a stable bridge for Lua-driven leaves while preserving engine-owned traversal guarantees.

### command_queue.rs

- Provides a staged action stream that turns chosen intent into executable command cadence.
- Maintains ordering, urgency, and interruption semantics so control pressure stays predictable.
- Couples command payloads with completion hooks to close the loop between plan and outcome.
- Offers controlled dequeue flow that supports reactive overrides without timeline fragmentation.
- Serves as the pacing buffer between high-level deliberation and low-level execution dispatch.

### context_steering.rs

- Implements slot-based directional reasoning that scores where motion should be pulled or resisted.
- Projects multiple influences into angular context so local movement stays responsive and legible.
- Mixes attraction, avoidance, drift, and boundary pressure as one continuous heading composition.
- Resolves conflict by weighing directional appetite against threat, then extracting the safest momentum lane.
- Preserves smooth steering continuity by keeping representation compact and frame-friendly.
- Outputs a movement-ready vector that downstream motion systems can apply with minimal translation.
- Acts as a tactical micro-navigation layer beneath planners and above raw kinematic integration.

### director.rs

- Models encounter tempo as a cyclic pressure waveform that alternates escalation and release.
- Converts accumulated tension into phase shifts that shape danger, reward, and ambient load.
- Keeps pacing legible by using bounded transitions instead of abrupt binary difficulty jumps.
- Exposes intensity signals that other systems can follow to stay synchronized with scenario mood.
- Preserves long-session flow by balancing peaks against recovery windows in deterministic cadence.
- Functions as the global dramaturgy spine for AI pressure management during runtime.

### emotion.rs

- Tracks affective channels as bounded signals that rise on events and relax toward personal baselines.
- Translates short-term emotional pressure into a clean modulation stream for decision weighting.
- Preserves stability with clamped values and predictable decay so mood changes remain interpretable.
- Resolves dominant feeling state as a compact summary other AI layers can consume cheaply.
- Supplies a lightweight emotional color layer without locking behavior to one planner architecture.

### fsm.rs

- Provides explicit mode-based control where behavior advances through named states over time.
- Evaluates guarded transitions in deterministic priority order to keep switching reproducible.
- Coordinates lifecycle callbacks around entry, steady update, and exit handoff boundaries.
- Tracks dwell time to support time-aware logic without external bookkeeping overhead.
- Serves agents that need clear phase changes rather than fully continuous utility arbitration.

### goap.rs

- Delivers deliberative planning over symbolic world facts, actionable effects, and prioritized intentions.
- Searches plan space with bounded best-first expansion to stay tractable under live-frame budgets.
- Reconstructs coherent action chains from explored nodes into executable intent trajectories.
- Balances optimality pressure against hard iteration ceilings so runtime cost remains predictable.
- Integrates Lua-side execution hooks while preserving engine-owned planning invariants.
- Acts as the intentional reasoning core for long-horizon task choice and sequencing.

### htn.rs

- Provides hierarchical task decomposition that transforms abstract goals into executable primitive flow.
- Expands authored methods through recursive branching while honoring world-state numeric constraints.
- Preserves plan structure and intent traceability across each decomposition depth step.
- Limits expansion depth to protect runtime from runaway combinatorial growth.
- Supports domain-authored behavioral style where sequencing logic is explicit and inspectable.
- Serves as a long-horizon planning backbone for structured narrative or tactical routines.

### lod.rs

- Defines distance-tiered AI update policy so compute effort follows player-relevant proximity.
- Assigns cadence bands that throttle far entities while keeping near interactions immediate.
- Stabilizes frame budget by converting spatial spread into predictable scheduling pressure.
- Provides a compact scalability dial for large-population scenes with bounded responsiveness loss.

### mcts.rs

- Implements Monte Carlo Tree Search as a reusable decision kernel for branching action spaces.
- Executes the full selection, expansion, rollout, and backpropagation rhythm under fixed budgets.
- Uses exploration pressure to balance known strong branches against uncertain alternatives.
- Stores tree state in compact node arenas for iterative simulation throughput.
- Returns action preference grounded in sampled outcomes rather than handcrafted deterministic rules.
- Supports game-specific state, transition, and scoring logic through generic integration hooks.

### mod.rs

- Groups the full AI runtime surface into one coherent module boundary for decision and control.
- Exposes complementary layers for actor state, sensing, planning, steering, coordination, and tooling.
- Keeps integration predictable by publishing shared types through a single composition entry point.
- Aligns tactical and strategic subsystems under consistent data flow and update expectations.
- Defines the high-level contract of engine-side intelligence capabilities available to the rest of runtime.

### needs.rs

- Models internal drives as normalized pressures that decay, recover, and compete for attention.
- Converts need intensity into urgency signals that higher decision layers can compare directly.
- Scores available satisfiers against context so fulfillment choice remains situational and explainable.
- Maintains cooldown-aware motivation flow to avoid oscillation between equivalent opportunities.
- Supplies a behavioral hunger layer that gives planners a dynamic reason to act.

### orca.rs

- Implements local collision avoidance by projecting preferred motion into safe velocity space.
- Builds pairwise movement constraints that encode short-horizon separation commitments between agents.
- Resolves feasible velocity choices while preserving as much intent direction as safety allows.
- Keeps radius and speed bounds explicit so output remains physically plausible for runtime integration.
- Serves as the crowd-scale micro-avoidance layer under higher-level navigation goals.

### perception.rs

- Implements sensory intake as a multi-channel stream of world cues with persistent awareness state.
- Captures visual, auditory, and custom signals in a unified format suitable for agent reasoning.
- Applies range and confidence dynamics so perception strength evolves instead of flipping abruptly.
- Maintains temporal awareness memory that can fade, refresh, or intensify based on new evidence.
- Separates sensing configuration from stimulus flow to keep tuning independent from event production.
- Bridges raw world events into decision-ready perceptual context consumed by planning layers.
- Acts as the attentional gate that determines what information reaches behavior systems and when.

### render.rs

- Provides debug-visualization translation from live AI state into drawable diagnostic artifacts.
- Turns control-graph structure into spatial layouts that remain readable during runtime inspection.
- Encodes execution status into visual signals so behavior flow can be understood at a glance.
- Supports both command-stream overlays and image snapshots for tooling and reporting paths.
- Keeps rendering concerns decoupled from decision logic while preserving faithful state representation.
- Acts as the observability lens for active finite-state and tree-based decision dynamics.

### squad.rs

- Defines group-level coordination state that binds members around shared intent and leadership.
- Maintains formation semantics as geometric offsets that stay coherent during leader motion.
- Carries shared tactical context so squad behavior can react as one unit instead of isolated actors.
- Produces placement guidance for synchronized movement patterns across common formation styles.
- Serves as the structural layer for multi-agent cohesion above individual steering behaviors.

### steering.rs

- Provides continuous movement intent synthesis for agents that steer instead of teleporting state.
- Combines concurrent influences into one force signal while preserving controllable blending semantics.
- Supports reactive pursuit, evasion, spacing, and exploratory drift as composable motion textures.
- Integrates waypoint progression so authored path flow and emergent steering can coexist smoothly.
- Applies bounded output shaping to keep acceleration pressure stable for frame-to-frame integration.
- Treats path following as a first-class influence that can lead or defer to behavior priorities.
- Preserves deterministic fallback when no active influence produces meaningful directional intent.
- Exposes configurable weighting that lets designers tune expressive movement character per actor role.
- Maintains lightweight state for runtime-safe updates under dense multi-agent simulation loads.
- Serves as the tactical locomotion bridge between decision outputs and physics-facing motion updates.

### strategy.rs

- Implements high-level intent arbitration that ranks strategic goals against current world context.
- Blends static priority and dynamic scoring pressure into a single comparable decision signal.
- Evaluates on a controlled cadence to avoid noisy goal thrashing between adjacent frames.
- Retains active intent continuity so tactical layers receive stable direction over time.
- Serves as the top strategic filter above lower-level planners and executors.

### traits.rs

- Defines long-lived personality dimensions that shape how agents weight and express decisions.
- Combines base profile values with temporary modifiers to model evolving behavioral flavor.
- Updates modifier lifecycles over time so transient influences fade in a controlled manner.
- Supports archetypal presets and deterministic variation for reproducible character differentiation.
- Supplies stable temperament context consumed by planners, scorers, and tactical selectors.

### utility_ai.rs

- Implements continuous utility-based action choice through layered consideration scoring pipelines.
- Shapes raw inputs with configurable response curves to express nonlinear decision preference.
- Blends historical momentum with fresh evidence so action selection avoids abrupt instability.
- Captures per-action score snapshots each tick for introspection and downstream decision context.
- Serves agents that benefit from smooth preference arbitration instead of hard state jumps.

### world.rs

- Provides the global AI registry that owns agents, lookup indices, and shared world context.
- Keeps identity-to-storage mapping synchronized so retrieval remains stable across lifecycle changes.
- Centralizes broad update progression to advance many actors through one coherent world pulse.
- Serves as the integration hub where individual agent logic becomes population-level simulation flow.

## Lua API Ref

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

### Callbacks

- `LBot:setCustomModel` param `callback` (`function`): Function called during world updates with `(agent, blackboard, dt)` for this agent.
- `LCommandQueue:enqueue` param `callback` (`function`): Callback invoked by command execution logic outside this wrapper.
- `LCommandQueue:pushFront` param `callback` (`function`): Callback invoked by command execution logic outside this wrapper.
- `LCommandQueue:replace` param `callback` (`function`): Callback invoked by command execution logic outside this wrapper.
- `LGOAPPlanner:addAction` param `callback` (`function?`): Optional callback stored with the action for game-side execution.
- `LMCTSEngine:search` param `apply_fn` (`function`): Function called with `(state, action)` and returning the next state integer.
- `LMCTSEngine:search` param `eval_fn` (`function`): Function called with a state and returning a numeric score.
- `LMCTSEngine:search` param `get_actions_fn` (`function`): Function called with a state and returning an array of integer actions.
- `LStateMachine:addTransition` param `guard` (`function?`): Optional function that must return true for the transition to run.
- `LSteeringManager:addCustomBehavior` param `func` (`function`): Function called as `(agent, dt)` that returns an X and Y steering force.
- `LStrategyAI:forceEvaluate` param `scorer_fn` (`function`): Function called with a goal name and returning a numeric score.
- `LStrategyAI:update` param `scorer_fn` (`function`): Function called with a goal name and returning a numeric score.
- `LUtilityAI:addAction` param `scorer_fn` (`function`): Function called by evaluation to score this action.
- `LUtilityAI:addConsideration` param `scorer_fn` (`function`): Function that returns the raw consideration score.
- `lurek.ai.newAction` param `callback` (`function`): Callback invoked when the action node ticks.
- `lurek.ai.newCondition` param `callback` (`function`): Callback invoked when the condition node ticks.
- `lurek.ai.newGuard` param `predicate` (`function`): Callback that decides whether the child may run.

### Enums

- No documented module-level enums/constants.

### Types

#### LAIBlackboard Type

- Lua handle for a typed AI blackboard storing local key-value facts.

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

- Lua handle for an AI director that tracks encounter tension and pacing factors.

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

- Lua handle for distance-based AI level-of-detail tier selection.

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

- Lua handle for an AI world that owns named agents, global blackboard data, and custom callback registrations.

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

- Lua handle for a behavior tree node that can be assembled into composites and decorators.

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

- Lua handle for a behavior tree root and its most recent execution status.

##### Fields

- No documented fields.

##### Methods

- `LBehaviorTree:getDebugState`: Returns behavior tree debug counters and status in a Lua table.
- `LBehaviorTree:getLastStatus`: Returns the last behavior tree status string recorded by the tree.
- `LBehaviorTree:setRoot`: Sets the behavior tree root by moving a node handle into the tree.
- `LBehaviorTree:type`: Returns the Lua-visible type name for this behavior tree handle.
- `LBehaviorTree:typeOf`: Returns whether this behavior tree handle matches a supported type name.

#### LBehaviorTreeGetDebugStateResult Type

- Generated result shape from @field tags.

##### Fields

- `last_status` (`string`): Last status.
- `node_count` (`integer`): Node count.

##### Methods

- No documented methods.

#### LBot Type

- Lua handle for a named agent stored inside an AI world.

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

- Lua handle for a command queue that stores ordered callback-backed commands.

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

- Lua handle for slot-based context steering direction selection.

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

- Lua handle for decaying named emotion intensities.

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

- Lua handle for a GOAP planner with boolean preconditions, effects, and goals.

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

- Lua handle for a hierarchical task network domain.

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

- Lua handle for a grid-based influence map with named layers.

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

- Lua handle for Monte Carlo tree search over Lua-defined game states and actions.

##### Fields

- No documented fields.

##### Methods

- `LMCTSEngine:search`: Runs MCTS from a root state using Lua callbacks for actions, transitions, and evaluation.
- `LMCTSEngine:type`: Returns the Lua-visible type name for this MCTS engine handle.
- `LMCTSEngine:typeOf`: Returns whether this MCTS engine handle matches a supported type name.

#### LNeedSystem Type

- Lua handle for decaying needs and urgency selection.

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

- Lua handle for reciprocal velocity obstacle avoidance agents.

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

- Lua handle for a named squad with members, leader, formation, and shared blackboard.

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

- Lua handle for a finite state machine with Lua-backed state callbacks and transition guards.

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

- Lua handle for a steering behavior stack that combines movement forces for an agent.

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

- Lua handle for sensory stimuli tracked in world space.

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

- Lua handle for interval-based strategic goal selection.

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

- Lua handle for trait values with temporary modifiers and archetype lookup.

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

- Lua handle for utility AI action scoring and consideration curves.

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
