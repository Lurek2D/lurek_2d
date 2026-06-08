# ai

## TL;DR

- Orchestrates agent choices via behavior trees, FSMs, GOAP, HTN, and utility AI.
- Synthesizes steering locomotion, spatial collision avoidance, and sensory perception.
- Tracks tactical influence grids, squad formations, and trait-driven emotional motives.
- Embeds adaptable machine learning solvers, Q-learning, and neuroevolution pipelines.
- Controls dramatic pacing waves and optimizes runtime budgets with distance-based LOD tiers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ai/`
- Binding: `src/lua_api/ai_api.rs`
- Namespace: `lurek.ai`
- Lua API surface: `36` functions, `24` types, `237` methods
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua/unit/test_ai.lua, tests/lua/golden/test_ai_golden.lua, tests/lua/integration/test_ecs_ai.lua, tests/lua/integration/test_ai_physics.lua, tests/lua/integration/test_ai_pathfind.lua, tests/lua/integration/test_ai_ecs_scene.lua, tests/lua/stress/test_ai_stress.lua

## Summary

- The ai module is the engine's gameplay intelligence surface for actors that must perceive, decide, and react.
- It unifies reactive and deliberative techniques so teams can choose control style per unit archetype.
- Behavior trees provide deterministic branching flow for moment-to-moment tactical reactions.
- Finite state machines provide explicit phase transitions for authored mode-based behaviors.
- Utility scoring supports weighted action selection when many options are simultaneously valid.
- GOAP supports goal-driven planning over symbolic world state with executable action chains.
- HTN supports hierarchical decomposition of authored plans into runtime-ready primitive tasks.
- MCTS supports sampled search for high-branching choices under bounded compute budgets.
- The module lets projects mix these methods instead of committing to a single AI doctrine.
- Agent runtime state is centralized so planning, movement, mood, and memory stay coherent.
- Command queues turn selected intent into ordered execution that can be interrupted safely.
- Perception channels capture visual and audio-like stimuli as graded, time-evolving signals.
- Awareness can fade, refresh, and compete instead of behaving as a binary omniscient flag.
- Blackboard-like state sharing allows local and shared memory models across AI participants.
- Steering layers translate high-level intent into continuous movement vectors.
- Steering includes seek, flee, wander, arrive, separation, and context-sensitive heading choice.
- ORCA-style local avoidance keeps crowds stable in dense movement scenarios.
- Tactical influence maps encode area pressure for threat, control, and reward bias.
- Squad and formation tools coordinate multiple agents as cohesive tactical groups.
- Needs and motives add internal pressure that influences behavior prioritization.
- Emotion channels add short-term affect modulation without replacing core planner logic.
- Trait systems let similar agents diverge in risk profile and reaction style.
- Director pacing tools shape encounter pressure through escalation and release windows.
- LOD policy scales AI update cadence by distance and relevance to control frame cost.
- Nearby entities can update richly while distant entities use cheaper evaluation intervals.
- The module includes observability tools because complex AI must remain inspectable.
- Debug rendering can expose decision state, steering intent, and planning diagnostics.
- Deterministic update order is prioritized for replayability and reproducible tests.
- Data surfaces are designed to be script-friendly while preserving Rust-side invariants.
- Integration points exist for learning systems without forcing ML into every project.
- Reinforcement learning and bandit patterns can adapt action preferences over time.
- Neural and evolutionary hooks support simulation-heavy experimentation workflows.
- The module owns cognition and behavior policy, not rendering or asset decoding logic.
- It collaborates with runtime, render, patterns, dialog, and learning modules through boundaries.
- It supports enemies, companions, civilians, traffic, and strategy-unit behaviors.
- It reduces duplicated AI architecture across combat, navigation, and group coordination.
- It allows incremental complexity growth instead of mid-project AI rewrites.
- It keeps behavior authoring inspectable rather than opaque.
- The API is broad but organized around stable AI contracts.
- Planning systems operate under bounded budgets to protect frame stability.
- Movement systems are layered so local avoidance does not invalidate strategic intent.
- Perception and memory are explicit, making sensory assumptions testable.
- Group behavior is first-class rather than bolted on from single-agent logic.
- Emotional and motivational layers are optional but integrated coherently.
- Debug surfaces are practical for tuning and regression verification.
- The module is suitable for both scripted and adaptive AI stacks.
- It is designed for systemic gameplay where behavior quality must scale with content.
- Invariants emphasize deterministic progression under identical input conditions.
- Contracts emphasize explicit ownership of AI state and transition rules.
- Overall, ai is the Feature Systems intelligence platform for production gameplay behavior.

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

- `lurek.ai.newAIDirector() -> LAIDirector`: Creates an AI director for tension, phase, and pacing factor calculations.
- `lurek.ai.newAILod() -> LAILod`: Creates a default AI level-of-detail tier selector.
- `lurek.ai.newAction(callback) -> LBTNode`: Creates a behavior tree action leaf backed by a Lua callback.
- `lurek.ai.newBandit(arm_count, strategy, epsilon, seed) -> LBandit`: Creates a multi-armed bandit with a named selection strategy.
- `lurek.ai.newBehaviorTree() -> LBehaviorTree`: Creates an empty behavior tree that can receive a root node.
- `lurek.ai.newBlackboard() -> LAIBlackboard`: Creates an empty AI blackboard for typed local facts.
- `lurek.ai.newCommandQueue() -> LCommandQueue`: Creates an empty command queue for callback-backed AI commands.
- `lurek.ai.newCondition(callback) -> LBTNode`: Creates a behavior tree condition leaf backed by a Lua callback.
- `lurek.ai.newContextSteering(slots) -> LContextSteering`: Creates a context steering model with the requested directional slot count.
- `lurek.ai.newDialogueAI() -> LDialogueAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.ai.newEmotionModel() -> LEmotionModel`: Creates an empty emotion model for named decaying emotion values.
- `lurek.ai.newGOAPPlanner() -> LGOAPPlanner`: Creates an empty GOAP planner for boolean world-state planning.
- `lurek.ai.newGeneticAlgorithm(pop_size, gene_count, seed) -> LGeneticAlgorithm`: Creates a genetic algorithm population with fixed chromosome length.
- `lurek.ai.newGuard(predicate, child) -> LBTNode`: Creates a guard decorator that runs a predicate before ticking its child.
- `lurek.ai.newHTNDomain() -> LHTNDomain`: Creates an empty hierarchical task network domain.
- `lurek.ai.newInfluenceMap(w, h, cs) -> LInfluenceMap`: Creates a grid influence map with the supplied cell dimensions and world cell size.
- `lurek.ai.newInverter() -> LBTNode`: Creates a behavior tree inverter decorator with an empty sequence child.
- `lurek.ai.newMCTSEngine(iters, uct_c, depth, seed) -> LMCTSEngine`: Creates a Monte Carlo tree search engine with deterministic configuration.
- `lurek.ai.newNeedSystem() -> LNeedSystem`: Creates an empty need system for decaying named needs.
- `lurek.ai.newNeuralNet() -> LNeuralNet`: Creates an empty feed-forward neural network.
- `lurek.ai.newNeuroevolution(layer_spec, pop_size, seed) -> LNeuroevolution`: Creates a neuroevolution population from a layer specification table.
- `lurek.ai.newORCASolver(time_horizon) -> LORCASolver`: Creates an ORCA avoidance solver with the supplied prediction horizon.
- `lurek.ai.newParallel(sp?, fp?) -> LBTNode`: Creates a behavior tree parallel node with optional success and failure policies.
- `lurek.ai.newQLearner(sc, ac) -> LQLearner`: Creates a Q-learner with fixed state and action counts.
- `lurek.ai.newRepeater(count?) -> LBTNode`: Creates a behavior tree repeater decorator with an optional repeat count.
- `lurek.ai.newSelector() -> LBTNode`: Creates a behavior tree selector node with no children.
- `lurek.ai.newSequence() -> LBTNode`: Creates a behavior tree sequence node with no children.
- `lurek.ai.newSquad(name) -> LSquad`: Creates an empty named squad. This function is exposed to Lua scripts.
- `lurek.ai.newStateMachine() -> LStateMachine`: Creates an empty finite state machine with Lua-backed states and transitions.
- `lurek.ai.newSteeringManager() -> LSteeringManager`: Creates an empty steering manager with support for built-in and custom behaviors.
- `lurek.ai.newStimulusWorld() -> LStimulusWorld`: Creates an empty stimulus world for visual and auditory stimulus records.
- `lurek.ai.newStrategyAI(update_interval) -> LStrategyAI`: Creates a strategy AI that reevaluates goals on a fixed interval.
- `lurek.ai.newSucceeder() -> LBTNode`: Creates a behavior tree succeeder decorator with an empty sequence child.
- `lurek.ai.newTraitProfile() -> LTraitProfile`: Creates an empty trait profile with modifier support.
- `lurek.ai.newUtilityAI() -> LUtilityAI`: Creates an empty utility AI action scorer.
- `lurek.ai.newWorld() -> LAIWorld`: Creates an isolated AI world for agents, blackboards, and custom decision callbacks.

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

- `LAIBlackboard:clear() -> nil`: Removes every local entry from this blackboard.
- `LAIBlackboard:getBool(key, default?) -> boolean`: Returns a boolean blackboard fact or the provided fallback when the key is missing or not boolean.
- `LAIBlackboard:getKeys() -> string[]`: Returns every local blackboard key in an array-style Lua table.
- `LAIBlackboard:getNumber(key, default?) -> number`: Returns a numeric blackboard fact or the provided fallback when the key is missing or not numeric.
- `LAIBlackboard:getSize() -> integer`: Returns the number of entries currently stored in this blackboard.
- `LAIBlackboard:getString(key, default?) -> string`: Returns a string blackboard fact or the provided fallback when the key is missing or not a string.
- `LAIBlackboard:has(key) -> boolean`: Returns whether the blackboard contains any entry for the given key.
- `LAIBlackboard:remove(key) -> nil`: Removes the given key from the blackboard if it exists.
- `LAIBlackboard:setBool(key, value) -> nil`: Stores a boolean fact under the given blackboard key.
- `LAIBlackboard:setNumber(key, value) -> nil`: Stores a numeric fact under the given blackboard key.
- `LAIBlackboard:setString(key, value) -> nil`: Stores a string fact under the given blackboard key.
- `LAIBlackboard:type() -> string`: Returns the Lua-visible type name for this blackboard handle.
- `LAIBlackboard:typeOf(name) -> boolean`: Returns whether this blackboard handle matches a supported type name.

#### LAIDirector Type

- Lua handle for an AI director that tracks encounter tension and pacing factors.

##### Fields

- No documented fields.

##### Methods

- `LAIDirector:ambientIntensity() -> number`: Returns the ambient intensity derived from current tension and phase.
- `LAIDirector:lootFactor() -> number`: Returns the loot multiplier derived from current tension and phase.
- `LAIDirector:phase() -> string`: Returns the current director phase name.
- `LAIDirector:pushEvent(intensity) -> nil`: Adds an event intensity sample to the director tension model.
- `LAIDirector:reset() -> nil`: Resets director tension and phase state to defaults.
- `LAIDirector:setTension(value) -> nil`: Directly sets the director tension value.
- `LAIDirector:spawnRateFactor() -> number`: Returns the spawn-rate multiplier derived from current tension and phase.
- `LAIDirector:tension() -> number`: Returns the current director tension value.
- `LAIDirector:type() -> string`: Returns the Lua-visible type name for this AI director handle.
- `LAIDirector:typeOf(name) -> boolean`: Returns whether this AI director handle matches a supported type name.
- `LAIDirector:update(dt) -> nil`: Advances director tension decay and phase evaluation.

#### LAILod Type

- Lua handle for distance-based AI level-of-detail tier selection.

##### Fields

- No documented fields.

##### Methods

- `LAILod:shouldUpdate(tier, frame) -> boolean`: Returns whether a tier should update on a given frame counter.
- `LAILod:tierCount() -> integer`: Returns the number of configured AI LOD tiers.
- `LAILod:tierFor(ax, ay, rx, ry) -> integer`: Returns the LOD tier for an agent position relative to a reference position.
- `LAILod:tierName(tier) -> LuaValue`: Returns the name of an AI LOD tier when the index is valid.
- `LAILod:type() -> string`: Returns the Lua-visible type name for this AI LOD handle.
- `LAILod:typeOf(name) -> boolean`: Returns whether this AI LOD handle matches a supported type name.

#### LAIWorld Type

- Lua handle for an AI world that owns named agents, global blackboard data, and custom callback registrations.

##### Fields

- No documented fields.

##### Methods

- `LAIWorld:addAgent(name) -> LBot`: Creates a named agent in this world and returns a handle that can edit its movement and decision state.
- `LAIWorld:getAgent(name) -> LuaValue`: Returns the named agent handle when it exists in this world.
- `LAIWorld:getAgentCount() -> integer`: Returns the number of agents currently stored in this world.
- `LAIWorld:getGlobalBlackboard() -> LAIBlackboard`: Returns a blackboard snapshot containing the world's shared AI facts.
- `LAIWorld:removeAgent(agent) -> nil`: Removes an agent from this world by using an existing agent handle.
- `LAIWorld:type() -> string`: Returns the Lua-visible type name for this AI world handle.
- `LAIWorld:typeOf(name) -> boolean`: Returns whether this AI world handle matches a supported type name.
- `LAIWorld:update(dt) -> nil`: Advances the world simulation and invokes custom decision callbacks for agents that use a custom model.

#### LBTNode Type

- Lua handle for a behavior tree node that can be assembled into composites and decorators.

##### Fields

- No documented fields.

##### Methods

- `LBTNode:addChild(child) -> nil`: Adds a child node to a composite selector, sequence, or parallel node.
- `LBTNode:getChildCount() -> integer`: Returns the number of children owned by this behavior tree node.
- `LBTNode:getCount() -> integer`: Returns the repeat count for repeater nodes or zero for other node kinds.
- `LBTNode:getNodeType() -> string`: Returns the behavior tree node kind as a lowercase string.
- `LBTNode:reset() -> nil`: Resets this behavior tree node's runtime state.
- `LBTNode:setChild(child) -> nil`: Sets the single child of a decorator node such as inverter, repeater, or succeeder.
- `LBTNode:setCount(n) -> nil`: Sets the repeat count when this node is a repeater.
- `LBTNode:setFailurePolicy(policy) -> nil`: Sets the failure policy for a parallel node.
- `LBTNode:setSuccessPolicy(policy) -> nil`: Sets the success policy for a parallel node.
- `LBTNode:type() -> string`: Returns the Lua-visible type name for this behavior tree node handle.
- `LBTNode:typeOf(name) -> boolean`: Returns whether this behavior tree node handle matches a supported type name.

#### LBehaviorTree Type

- Lua handle for a behavior tree root and its most recent execution status.

##### Fields

- No documented fields.

##### Methods

- `LBehaviorTree:getDebugState() -> table`: Returns behavior tree debug counters and status in a Lua table.
- `LBehaviorTree:getLastStatus() -> string`: Returns the last behavior tree status string recorded by the tree.
- `LBehaviorTree:setRoot(node) -> nil`: Sets the behavior tree root by moving a node handle into the tree.
- `LBehaviorTree:type() -> string`: Returns the Lua-visible type name for this behavior tree handle.
- `LBehaviorTree:typeOf(name) -> boolean`: Returns whether this behavior tree handle matches a supported type name.

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

- `LBot:addTag(tag) -> nil`: Adds a tag string to this agent when the agent still exists in its world.
- `LBot:getBlackboard() -> LAIBlackboard`: Returns a blackboard snapshot for this agent or an empty blackboard when the agent has been removed.
- `LBot:getDecisionModel() -> string`: Returns this agent's decision model name or the default model name for a missing agent.
- `LBot:getMaxForce() -> number`: Returns this agent's maximum steering force or the default force for a missing agent.
- `LBot:getMaxSpeed() -> number`: Returns this agent's maximum movement speed or the default speed for a missing agent.
- `LBot:getName() -> string`: Returns this agent's stable world name.
- `LBot:getPosition() -> number, number`: Returns this agent's world position or the origin when the agent has been removed.
- `LBot:getPriority() -> integer`: Returns this agent's integer priority or zero when the agent has been removed.
- `LBot:getVelocity() -> number, number`: Returns this agent's velocity vector or zero velocity when the agent has been removed.
- `LBot:hasTag(tag) -> boolean`: Returns whether this agent currently has the given tag.
- `LBot:removeTag(tag) -> nil`: Removes a tag string from this agent when the agent still exists in its world.
- `LBot:setCustomModel(callback) -> nil`: Installs a Lua callback as this agent's decision model and stores it in the callback registry.
- `LBot:setDecisionModel(model) -> nil`: Sets this agent's built-in decision model from a string name when the name is recognized.
- `LBot:setMaxForce(v) -> nil`: Sets this agent's maximum steering force when the agent still exists in its world.
- `LBot:setMaxSpeed(v) -> nil`: Sets this agent's maximum movement speed when the agent still exists in its world.
- `LBot:setPosition(x, y) -> nil`: Sets this agent's world position when the agent still exists in its world.
- `LBot:setPriority(p) -> nil`: Sets this agent's integer priority when the agent still exists in its world.
- `LBot:setVelocity(x, y) -> nil`: Sets this agent's velocity vector when the agent still exists in its world.
- `LBot:type() -> string`: Returns the Lua-visible type name for this agent handle.
- `LBot:typeOf(name) -> boolean`: Returns whether this agent handle matches a supported type name.

#### LCommandQueue Type

- Lua handle for a command queue that stores ordered callback-backed commands.

##### Fields

- No documented fields.

##### Methods

- `LCommandQueue:cancelCurrent() -> boolean`: Cancels the currently active command when one exists.
- `LCommandQueue:clear() -> nil`: Removes every queued command. This method is available to Lua scripts.
- `LCommandQueue:enqueue(kind, callback, opts?) -> nil`: Adds a command callback to the back of the queue.
- `LCommandQueue:getCount() -> integer`: Returns the number of commands currently queued.
- `LCommandQueue:getCurrentTarget() -> number, number`: Returns the current command target coordinates.
- `LCommandQueue:getCurrentType() -> LuaValue`: Returns the type label of the current command when one exists.
- `LCommandQueue:isEmpty() -> boolean`: Returns whether the command queue has no commands.
- `LCommandQueue:pushFront(kind, callback, opts?) -> nil`: Adds a command callback to the front of the queue.
- `LCommandQueue:replace(kind, callback, opts?) -> nil`: Replaces the queue contents with one command callback.
- `LCommandQueue:type() -> string`: Returns the Lua-visible type name for this command queue handle.
- `LCommandQueue:typeOf(name) -> boolean`: Returns whether this command queue handle matches a supported type name.

#### LContextSteering Type

- Lua handle for slot-based context steering direction selection.

##### Fields

- No documented fields.

##### Methods

- `LContextSteering:addAvoidBounds(min_x, min_y, max_x, max_y, margin, weight) -> nil`: Adds rectangular bounds avoidance to context steering.
- `LContextSteering:addAvoidPoint(x, y, radius, weight) -> nil`: Adds a point avoidance influence to context steering.
- `LContextSteering:addSeekTarget(tx, ty, weight) -> nil`: Adds a context steering target attraction.
- `LContextSteering:addWander(jitter, weight) -> nil`: Adds wander noise to context steering.
- `LContextSteering:chosenMagnitude() -> number`: Returns the magnitude of the last selected context steering slot.
- `LContextSteering:clearBehaviors() -> nil`: Removes all context steering behaviors.
- `LContextSteering:evaluate(ax, ay, vx, vy) -> number, number`: Evaluates context steering and returns the selected movement direction.
- `LContextSteering:slotCount() -> integer`: Returns the number of directional slots used by this context steering model.
- `LContextSteering:type() -> string`: Returns the Lua-visible type name for this context steering handle.
- `LContextSteering:typeOf(name) -> boolean`: Returns whether this context steering handle matches a supported type name.

#### LEmotionModel Type

- Lua handle for decaying named emotion intensities.

##### Fields

- No documented fields.

##### Methods

- `LEmotionModel:add(name, rest, decay, min_vis) -> nil`: Adds an emotion definition with resting value, decay, and visibility threshold.
- `LEmotionModel:dominant() -> LuaValue`: Returns the strongest active emotion name when one is available.
- `LEmotionModel:get(name) -> number`: Returns the current value of a named emotion.
- `LEmotionModel:isActive(name) -> boolean`: Returns whether a named emotion is currently active.
- `LEmotionModel:reset() -> nil`: Resets all emotions toward their default state.
- `LEmotionModel:trigger(name, amount) -> nil`: Adds an amount to a named emotion. This method is available to Lua scripts.
- `LEmotionModel:type() -> string`: Returns the Lua-visible type name for this emotion model handle.
- `LEmotionModel:typeOf(name) -> boolean`: Returns whether this emotion model handle matches a supported type name.
- `LEmotionModel:update(dt) -> nil`: Advances emotion decay over elapsed time.

#### LGOAPPlanner Type

- Lua handle for a GOAP planner with boolean preconditions, effects, and goals.

##### Fields

- No documented fields.

##### Methods

- `LGOAPPlanner:addAction(name, cost?, callback?) -> nil`: Adds a GOAP action with optional cost and completion callback.
- `LGOAPPlanner:addGoal(name, priority?) -> nil`: Adds a GOAP goal with an optional priority weight.
- `LGOAPPlanner:getActionCount() -> integer`: Returns the number of GOAP actions registered in this planner.
- `LGOAPPlanner:getGoalCount() -> integer`: Returns the number of GOAP goals registered in this planner.
- `LGOAPPlanner:getMaxIterations() -> integer`: Returns the maximum number of planner iterations allowed during search.
- `LGOAPPlanner:plan(world_state_tbl, max_depth?) -> string[]`: Builds a plan from the supplied boolean world state and returns action names in execution order.
- `LGOAPPlanner:setEffect(action_name, key, value) -> nil`: Sets one boolean effect produced by an existing GOAP action.
- `LGOAPPlanner:setGoalState(goal_name, key, value) -> nil`: Sets one desired world-state key for an existing GOAP goal.
- `LGOAPPlanner:setMaxIterations(n) -> nil`: Sets the maximum number of planner iterations allowed during search.
- `LGOAPPlanner:setPrecondition(action_name, key, value) -> nil`: Sets one boolean precondition for an existing GOAP action.
- `LGOAPPlanner:type() -> string`: Returns the Lua-visible type name for this GOAP planner handle.
- `LGOAPPlanner:typeOf(name) -> boolean`: Returns whether this GOAP planner handle matches a supported type name.

#### LHTNDomain Type

- Lua handle for a hierarchical task network domain.

##### Fields

- No documented fields.

##### Methods

- `LHTNDomain:addCompound(comp_name, methods_table) -> nil`: Adds a compound HTN task with one or more ordered method definitions.
- `LHTNDomain:addPrimitive(name, preconds, effects, clears) -> nil`: Adds a primitive HTN task with preconditions, effects, and cleared facts.
- `LHTNDomain:plan(root_task, state_table) -> LuaValue`: Plans from a root HTN task and numeric world state facts.
- `LHTNDomain:taskCount() -> integer`: Returns the number of tasks defined in this HTN domain.
- `LHTNDomain:type() -> string`: Returns the Lua-visible type name for this HTN domain handle.
- `LHTNDomain:typeOf(name) -> boolean`: Returns whether this HTN domain handle matches a supported type name.

#### LInfluenceMap Type

- Lua handle for a grid-based influence map with named layers.

##### Fields

- No documented fields.

##### Methods

- `LInfluenceMap:addLayer(name) -> nil`: Adds an influence layer with the given name if it does not already exist.
- `LInfluenceMap:blend(layer_a, weight_a, layer_b, weight_b, dest) -> nil`: Blends two source layers into a destination layer using independent weights.
- `LInfluenceMap:clearAll() -> nil`: Clears every influence value in every layer.
- `LInfluenceMap:clearLayer(layer) -> nil`: Clears every value in a named influence layer.
- `LInfluenceMap:decay(layer, factor) -> nil`: Multiplies a named layer by a decay factor.
- `LInfluenceMap:getCellSize() -> number`: Returns the world size represented by each influence map cell.
- `LInfluenceMap:getHeight() -> integer`: Returns the influence map height in cells.
- `LInfluenceMap:getInfluence(layer, x, y) -> number`: Returns one cell value from a named influence layer using one-based cell coordinates.
- `LInfluenceMap:getMaxPosition(layer) -> integer, integer`: Returns the cell position with the highest value on a named layer.
- `LInfluenceMap:getMinPosition(layer) -> integer, integer`: Returns the cell position with the lowest value on a named layer.
- `LInfluenceMap:getWidth() -> integer`: Returns the influence map width in cells.
- `LInfluenceMap:hasLayer(name) -> boolean`: Returns whether an influence layer exists.
- `LInfluenceMap:propagate(layer, momentum?) -> nil`: Propagates influence values across neighboring cells on a named layer.
- `LInfluenceMap:queryRect(layer, wx, wy, ww, wh) -> number[]`: Returns influence values inside a world-space rectangle on a named layer.
- `LInfluenceMap:setInfluence(layer, x, y, value) -> nil`: Sets one cell value in a named influence layer using one-based cell coordinates.
- `LInfluenceMap:stampInfluence(layer, wx, wy, radius, value, falloff?) -> nil`: Applies a radial influence stamp to a named layer in world coordinates.
- `LInfluenceMap:type() -> string`: Returns the Lua-visible type name for this influence map handle.
- `LInfluenceMap:typeOf(name) -> boolean`: Returns whether this influence map handle matches a supported type name.

#### LMCTSEngine Type

- Lua handle for Monte Carlo tree search over Lua-defined game states and actions.

##### Fields

- No documented fields.

##### Methods

- `LMCTSEngine:search(root_state, get_actions_fn, apply_fn, eval_fn) -> LuaValue`: Runs MCTS from a root state using Lua callbacks for actions, transitions, and evaluation.
- `LMCTSEngine:type() -> string`: Returns the Lua-visible type name for this MCTS engine handle.
- `LMCTSEngine:typeOf(name) -> boolean`: Returns whether this MCTS engine handle matches a supported type name.

#### LNeedSystem Type

- Lua handle for decaying needs and urgency selection.

##### Fields

- No documented fields.

##### Methods

- `LNeedSystem:addNeed(name, decay_rate, urgency_threshold, urgency_factor) -> nil`: Adds a need with decay and urgency tuning values.
- `LNeedSystem:mostUrgent() -> LuaValue`: Returns the name of the most urgent need when any need is active.
- `LNeedSystem:satisfy(name, amount) -> nil`: Reduces or satisfies a named need by the supplied amount.
- `LNeedSystem:type() -> string`: Returns the Lua-visible type name for this need system handle.
- `LNeedSystem:typeOf(name) -> boolean`: Returns whether this need system handle matches a supported type name.
- `LNeedSystem:update(dt) -> nil`: Advances need decay over elapsed time.
- `LNeedSystem:valueOf(name) -> number`: Returns the current value of a named need.

#### LORCASolver Type

- Lua handle for reciprocal velocity obstacle avoidance agents.

##### Fields

- No documented fields.

##### Methods

- `LORCASolver:addAgent(x, y, radius, max_speed) -> integer`: Adds an ORCA avoidance agent and returns its zero-based solver index.
- `LORCASolver:agentCount() -> integer`: Returns the number of ORCA agents in this solver.
- `LORCASolver:compute(dt) -> nil`: Computes safe velocities for all ORCA agents.
- `LORCASolver:getSafeVelocity(idx) -> number, number`: Returns the computed safe velocity for an ORCA agent.
- `LORCASolver:setPosition(idx, x, y) -> nil`: Sets the position for an ORCA agent by zero-based index.
- `LORCASolver:setPreferredVelocity(idx, pvx, pvy) -> nil`: Sets the preferred velocity for an ORCA agent by zero-based index.
- `LORCASolver:type() -> string`: Returns the Lua-visible type name for this ORCA solver handle.
- `LORCASolver:typeOf(name) -> boolean`: Returns whether this ORCA solver handle matches a supported type name.

#### LSquad Type

- Lua handle for a named squad with members, leader, formation, and shared blackboard.

##### Fields

- No documented fields.

##### Methods

- `LSquad:addMember(name) -> nil`: Adds a member name to the squad member list.
- `LSquad:getBlackboard() -> LAIBlackboard`: Returns a blackboard snapshot for this squad.
- `LSquad:getFormation() -> string`: Returns the current squad formation type name.
- `LSquad:getFormationPosition(member_idx, leader_x, leader_y) -> number, number`: Returns a member's target formation position relative to the leader position.
- `LSquad:getFormationSpacing() -> number`: Returns the spacing used by squad formation positioning.
- `LSquad:getLeader() -> LuaValue`: Returns the squad leader name when one is assigned.
- `LSquad:getMemberCount() -> integer`: Returns the number of members in this squad.
- `LSquad:getMembers() -> string[]`: Returns all squad members in an array-style Lua table.
- `LSquad:getName() -> string`: Returns the squad name. This method is available to Lua scripts.
- `LSquad:removeMember(name) -> nil`: Removes every member entry with the given name.
- `LSquad:setFormation(ftype, spacing?) -> nil`: Sets the squad formation type and optionally updates spacing.
- `LSquad:setLeader(name) -> nil`: Sets the squad leader name. This method is available to Lua scripts.
- `LSquad:type() -> string`: Returns the Lua-visible type name for this squad handle.
- `LSquad:typeOf(name) -> boolean`: Returns whether this squad handle matches a supported type name.

#### LStateMachine Type

- Lua handle for a finite state machine with Lua-backed state callbacks and transition guards.

##### Fields

- No documented fields.

##### Methods

- `LStateMachine:addState(name, opts) -> nil`: Adds a state with optional Lua lifecycle callbacks.
- `LStateMachine:addTransition(from, to, guard?, priority?) -> nil`: Adds a transition between two states with an optional guard callback and priority.
- `LStateMachine:forceState(name) -> nil`: Immediately switches the current state and resets the time spent in state.
- `LStateMachine:getCurrentState() -> LuaValue`: Returns the current state name when the state machine has entered a state.
- `LStateMachine:getTimeInState() -> number`: Returns how long the machine has spent in the current state.
- `LStateMachine:setInitialState(name) -> nil`: Sets the initial state and also enters it when the machine has no current state yet.
- `LStateMachine:type() -> string`: Returns the Lua-visible type name for this state machine handle.
- `LStateMachine:typeOf(name) -> boolean`: Returns whether this state machine handle matches a supported type name.

#### LSteeringManager Type

- Lua handle for a steering behavior stack that combines movement forces for an agent.

##### Fields

- No documented fields.

##### Methods

- `LSteeringManager:addArrive(tx, ty, slowing?, weight?) -> nil`: Adds an arrive behavior that slows the agent as it approaches a target point.
- `LSteeringManager:addCustomBehavior(func, weight?) -> nil`: Adds a custom steering behavior backed by a Lua callback.
- `LSteeringManager:addEvade(threat_name?, weight?) -> nil`: Adds an evade behavior that moves away from another named agent when a threat name is supplied.
- `LSteeringManager:addFlee(tx, ty, panic_dist?, weight?) -> nil`: Adds a flee behavior that pushes the agent away from a target point inside a panic distance.
- `LSteeringManager:addFlock(neighbor_radius?, sep_w?, align_w?, coh_w?, weight?) -> nil`: Adds a flocking behavior with separation, alignment, and cohesion weights.
- `LSteeringManager:addPursue(target_name?, weight?) -> nil`: Adds a pursue behavior that chases another named agent when a target name is supplied.
- `LSteeringManager:addSeek(tx, ty, weight?) -> nil`: Adds a seek behavior that pulls the agent toward a target point.
- `LSteeringManager:addWander(radius?, dist?, jitter?, weight?) -> nil`: Adds a wander behavior that produces jittered exploratory movement.
- `LSteeringManager:applyCustomSteering(agent, dt) -> number, number`: Runs enabled custom steering callbacks for an agent and returns the weighted combined force.
- `LSteeringManager:calculate(px, py, vx, vy, max_speed, max_force, dt) -> number, number`: Calculates a steering force for the supplied agent movement state.
- `LSteeringManager:clearPath() -> nil`: Clears the active waypoint path behavior.
- `LSteeringManager:enableSpatialHash(enabled) -> nil`: Enables or disables spatial hash acceleration for neighbor queries.
- `LSteeringManager:getBehaviorCount() -> integer`: Returns the number of steering behaviors configured on this manager.
- `LSteeringManager:getCombineMode() -> string`: Returns the current steering force combination mode.
- `LSteeringManager:getLastSteering() -> number, number`: Returns the last steering force calculated by this manager.
- `LSteeringManager:getPathProgress() -> integer, integer`: Returns the current one-based waypoint index and total waypoint count.
- `LSteeringManager:hasPath() -> boolean`: Returns whether this manager currently has an active waypoint path.
- `LSteeringManager:setCombineMode(mode) -> nil`: Sets how steering behavior forces are combined.
- `LSteeringManager:setPath(waypoints, reach_radius?, weight?) -> nil`: Sets a waypoint path behavior from an array of `{x, y}` tables.
- `LSteeringManager:setSpatialHashCellSize(size) -> nil`: Sets the cell size used by the steering manager spatial hash.
- `LSteeringManager:type() -> string`: Returns the Lua-visible type name for this steering manager handle.
- `LSteeringManager:typeOf(name) -> boolean`: Returns whether this steering manager handle matches a supported type name.

#### LStimulusWorld Type

- Lua handle for sensory stimuli tracked in world space.

##### Fields

- No documented fields.

##### Methods

- `LStimulusWorld:addAuditory(x, y, intensity, radius, decay_rate, tag?) -> integer`: Adds an auditory stimulus with decay and returns its identifier.
- `LStimulusWorld:addVisual(x, y, intensity, radius, tag?) -> integer`: Adds a visual stimulus and returns its identifier.
- `LStimulusWorld:clear() -> nil`: Removes every active stimulus. This method is available to Lua scripts.
- `LStimulusWorld:count() -> integer`: Returns the number of active stimuli.
- `LStimulusWorld:remove(id) -> boolean`: Removes a stimulus by identifier. This method is available to Lua scripts.
- `LStimulusWorld:type() -> string`: Returns the Lua-visible type name for this stimulus world handle.
- `LStimulusWorld:typeOf(name) -> boolean`: Returns whether this stimulus world handle matches a supported type name.
- `LStimulusWorld:update(dt) -> nil`: Advances stimulus decay and lifetime state.

#### LStrategyAI Type

- Lua handle for interval-based strategic goal selection.

##### Fields

- No documented fields.

##### Methods

- `LStrategyAI:activeGoal() -> LuaValue`: Returns the currently active strategic goal when one is selected.
- `LStrategyAI:addGoal(name) -> nil`: Adds a named strategic goal. This method is available to Lua scripts.
- `LStrategyAI:addTag(tag) -> nil`: Adds a context tag to this strategy AI.
- `LStrategyAI:forceEvaluate(scorer_fn) -> nil`: Immediately scores all goals and updates the active goal.
- `LStrategyAI:removeTag(tag) -> nil`: Removes a context tag from this strategy AI.
- `LStrategyAI:timeUntilNext() -> number`: Returns time remaining until the next scheduled strategy evaluation.
- `LStrategyAI:type() -> string`: Returns the Lua-visible type name for this strategy AI handle.
- `LStrategyAI:typeOf(name) -> boolean`: Returns whether this strategy AI handle matches a supported type name.
- `LStrategyAI:update(dt, scorer_fn) -> nil`: Advances strategy timing and scores goals when the update interval has elapsed.

#### LTraitProfile Type

- Lua handle for trait values with temporary modifiers and archetype lookup.

##### Fields

- No documented fields.

##### Methods

- `LTraitProfile:addModifier(trait_name, delta, duration?, source) -> nil`: Adds a temporary or permanent modifier to a named trait.
- `LTraitProfile:archetype() -> LuaValue`: Returns the best matching archetype name when the profile can classify one.
- `LTraitProfile:get(name) -> number`: Returns the current value of a named trait including active modifiers.
- `LTraitProfile:getBase(name) -> number`: Returns the base value of a named trait without temporary modifiers.
- `LTraitProfile:has(name) -> boolean`: Returns whether the profile has a named trait.
- `LTraitProfile:removeModifiers(source) -> nil`: Removes all trait modifiers that match a source label.
- `LTraitProfile:set(name, value) -> nil`: Sets the base value for a named trait.
- `LTraitProfile:traitCount() -> integer`: Returns the number of traits stored in the profile.
- `LTraitProfile:type() -> string`: Returns the Lua-visible type name for this trait profile handle.
- `LTraitProfile:typeOf(name) -> boolean`: Returns whether this trait profile handle matches a supported type name.
- `LTraitProfile:update(dt) -> nil`: Advances modifier timers and removes expired modifiers.

#### LUtilityAI Type

- Lua handle for utility AI action scoring and consideration curves.

##### Fields

- No documented fields.

##### Methods

- `LUtilityAI:addAction(name, scorer_fn, weight?) -> nil`: Adds an action scored by a Lua callback and optional momentum weight.
- `LUtilityAI:addConsideration(action_name, name, scorer_fn, curve_arg, p1?, p2?, p3?, weight?) -> nil`: Adds a consideration scorer and response curve to an existing utility action.
- `LUtilityAI:evaluate() -> LuaValue`: Evaluates all actions and returns the winning action name when one is available.
- `LUtilityAI:getActionCount() -> integer`: Returns the number of actions registered in this utility AI.
- `LUtilityAI:getLastAction() -> LuaValue`: Returns the last winning action name when evaluation has selected one.
- `LUtilityAI:type() -> string`: Returns the Lua-visible type name for this utility AI handle.
- `LUtilityAI:typeOf(name) -> boolean`: Returns whether this utility AI handle matches a supported type name.
