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
- Lua API surface: `36` functions, `24` types, `247` methods
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua/unit/test_ai.lua, tests/lua/golden/test_ai_golden.lua, tests/lua/integration/test_ecs_ai.lua, tests/lua/integration/test_ai_physics.lua, tests/lua/integration/test_ai_pathfind.lua, tests/lua/integration/test_ai_ecs_scene.lua, tests/lua/stress/test_ai_stress.lua

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
- Steering and movement-side intelligence are part of the same story. Context steering, ORCA-like local avoidance, formation logic, command queues, locomotion helpers, and related movement support keep decision-making grounded in how agents actually traverse the world.
- Squad support extends the module from isolated actors to coordinated groups. Leader-relative placement, formation maintenance, shared group state, and coordinated command handling make it possible to express teams, patrols, or formations rather than only individual units.
- Command queues are important because AI output is often not the final physical action. A stable queue boundary separates “what the AI wants next” from “what the actor is currently doing,” which helps with interruption, inspection, and synchronization with animation or movement systems.
- Director-style pacing support shows that the module also thinks beyond single actors. Encounter rhythm, phase pressure, tension, spawn pacing, and other orchestration behavior can be represented here when the “agent” is really the game experience itself.
- Level-of-detail and update-policy support matter for scale. Large groups of intelligent actors can become expensive quickly, so the module includes ways to throttle, schedule, or simplify updates without abandoning the common behavior vocabulary.
- Debug rendering and inspection support are essential for real use. Visualizing state machines, behavior trees, perception ranges, chosen targets, or queue contents shortens the path from “the agent behaved strangely” to “here is the exact internal reason.”
- The module is useful for enemies, companions, neutral populations, strategic directors, simulation agents, crowd coordinators, and any feature where behavior should be data-driven, inspectable, and scalable rather than buried in one-off control code.
- Neighboring modules still matter, but the boundary is clear. `pathfind` searches space, `physics` defines motion and collision semantics, and `render` visualizes results, while `ai` owns the reasoning structures, internal drives, sensory interpretation, and coordination layers that decide what to do.
- The breadth of the spec is intentional because modern game AI is an ecosystem. Perception, memory, scoring, planning, execution, local movement, and group coordination all reinforce one another, and users need them to live under a shared conceptual surface.
- That ecosystem view also improves authoring. Teams can mix authored logic, tactical heuristics, and simulation-like drives within one runtime surface instead of treating each behavior family as an isolated special case.
- It also helps debugging stay on one common reasoning vocabulary.
- That common vocabulary matters once several actor types share a world.
- The module is therefore not only about smarter enemies; it is also about giving complex runtime behavior a legible structure that can be tuned, debugged, and scaled over the lifetime of a project.
- For wiki readers, the key takeaway is that `ai` is not one algorithm or one enemy helper. It is the engine's full runtime toolkit for building decision-rich actors whose perception, planning, movement, group behavior, and debugging story are treated as one coherent feature family.

This module primarily collaborates with `dialog`, `image`, `learning`, `patterns`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `dialog`: Imports or references `src/dialog/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `learning`: Imports or references `src/learning/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `patterns`: Imports or references `src/patterns/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### agent.rs

- Defines the runtime state shape for one AI actor, combining identity, movement, decision mode, and support models.
- Owns the DecisionModel enum plus agent-side blackboard, tags, optional sensor, emotions, needs, and traits.
- Stores links into FSM, behavior-tree, and steering arenas so one agent can bind to multiple decision runtimes.
- Provides the per-actor boundary between shared AI systems and the concrete state they read and update.
- Open this owner when agent schema, decision-mode tagging, or cross-system state handoff needs to change.

### behavior_tree.rs

- Owns the behavior-tree runtime that stores node structure, running status, decorators, and debug tree summaries.
- Defines selector, sequence, parallel, inverter, repeater, succeeder, guard, action, and condition node variants.
- Keeps running indices and repetition counters in the node tree so long-lived control flow survives across ticks.
- Also exposes compact debug state describing node count and last status for render and tooling consumers.
- Provides the control-flow boundary between authored hierarchical behavior logic and runtime execution state.
- Open this owner when branching policy, decorator semantics, or tree reset behavior needs coordinated revision.

### command_queue.rs

- Owns the staged command queue that turns chosen intent into ordered executable actions with interruption rules.
- Defines command payloads with targets, priority, callbacks, and interruptibility, then stores them in FIFO order.
- Provides enqueue, push-front, replace, cancel, and advance helpers so reactive overrides stay explicit and safe.
- Acts as the execution boundary between decision layers that choose commands and runtime code that consumes them.
- Open this owner when command ordering, cancellation, or raw-command construction semantics must change.

### context_steering.rs

- Implements slot-based context steering that scores angular interest and danger before picking a movement lane.
- Owns directional ring buffers, behavior registrations, wander accumulation, and the chosen heading snapshot.
- Mixes seek, avoid, wander, fixed-direction, and boundary pressures into one compact frame-friendly sampler.
- Resolves conflicts by comparing interest against danger per slot instead of blending unsafe vectors directly.
- Provides the local movement boundary between authored context behaviors and the final chosen travel heading.
- This file matters when directional slot math or danger suppression yields jittery or obviously unsafe motion.
- Open this owner before generic steering when the bug is in lane choice rather than force combination policy.

### diagnostics.rs

- Owns lightweight diagnostics and decision traces shared by AI scorers, planners, search, and callback wrappers.
- It keeps last-decision evidence structured so Lua bindings, tests, and debugging tools can inspect what an AI subsystem just did.
- Open it when new AI owners need to expose traceable decisions or callback failures.

### director.rs

- Owns the encounter pacing director that turns accumulated tension into build-up, peak, sustain, and relief phases.
- Stores tuning thresholds, decay rates, event counts, sustain timers, and phase-specific spawn or loot multipliers.
- Updates a bounded tension waveform so other systems can read ambient intensity and pacing pressure each frame.
- Provides the scenario-mood boundary between raw gameplay events and systemic intensity signals for AI content.
- This file matters when pacing swings feel erratic or when reward and spawn factors drift out of phase together.
- Open this owner for encounter cadence fixes before changing local combat or navigation logic in sibling modules.

### emotion.rs

- Owns named emotional channels that rise from triggers and decay toward resting levels over simulation time.
- Stores per-emotion thresholds and decay settings, then aggregates them into an EmotionModel for one agent.
- Supports dominant-emotion queries and active-name filtering so higher AI layers can read compact affect summaries.
- Provides the affect boundary between raw events and reusable mood state that can bias planning or scoring.
- Open this owner when emotional decay, trigger clamping, or dominant-state semantics need coordinated changes.

### error.rs

- Owns typed validation and safety errors shared by AI planners, steering, scoring, and Lua-facing helpers.
- It keeps failure reasons explicit so AI owners can reject invalid numeric input, unsafe tree shapes, and bad budgets consistently.
- Open it when AI callers need clearer diagnostics or when a new AI subsystem joins the shared validation contract.

### fsm.rs

- Owns the finite-state-machine runtime that stores named states, guarded transitions, and state dwell timing.
- Defines Lua callback sets for enter, update, and exit plus prioritized transitions sorted for deterministic checks.
- Tracks current and initial state names so runtime code can progress stateful control without external bookkeeping.
- Provides the mode-switching boundary between authored state logic and the systems that tick one active state.
- Open this owner when transition priority, callback registration, or time-in-state behavior needs revision.

### goap.rs

- Implements goal-oriented action planning over boolean world facts, action effects, and prioritized desired states.
- Owns GOAP actions, goals, bounded best-first search nodes, and the iteration cap that keeps planning tractable.
- Searches forward from the current world state, reconstructing ordered action names once a goal state is satisfied.
- Also exposes mutators for action preconditions, effects, and goal facts so planners can be assembled incrementally.
- Provides the deliberative planning boundary between symbolic world state and executable action chains.
- Open this owner when plan search cost, iteration ceilings, or goal satisfaction semantics need shared fixes.

### htn.rs

- Implements hierarchical task network planning that decomposes abstract tasks into primitive executable sequences.
- Owns world-state maps, primitive and compound task definitions, methods, domains, and recursive decomposition.
- Applies preconditions and primitive effects while expanding a root task, keeping state updates inside the plan walk.
- Also enforces a depth cap so authored domains cannot explode into unbounded recursive search at runtime.
- Provides the planning boundary between symbolic task authoring and concrete action lists consumed by execution.
- Open this owner when decomposition order, method applicability, or effect application semantics need revision.

### lod.rs

- Owns AI level-of-detail tiers that map agent distance into update cadence and thinking-budget policy.
- Stores ordered distance bands with frame cadence and think-distance settings, then assigns tiers to many agents.
- Provides the scalability boundary between raw spatial spread and scheduled AI work across near, mid, and far bands.
- Open this owner when LOD tier assignment or frame-based update gating needs shared tuning across many actors.

### mcts.rs

- Implements Monte Carlo Tree Search as a reusable decision kernel for sampled action selection under uncertainty.
- Owns the arena-backed node tree, UCT scoring, rollout budget, RNG state, and selection or expansion workflow.
- Runs full selection, expansion, rollout, and backpropagation, then returns the most visited root action choice.
- Provides the sampled planning boundary between abstract action generators and a concrete chosen action id.
- This file matters when rollout budgets, exploration pressure, or visit accounting stop producing sane choices.
- Open this owner when search-policy behavior changes without affecting deterministic planners like GOAP or HTN.

### mod.rs

- Exports the AI subsystem surface that groups decision models, sensing, planning, steering, pacing, and debug tools.
- Acts as the navigation index for agent state, behavior trees, GOAP, HTN, MCTS, squads, and utility scoring.
- Keeps module boundaries explicit so callers can find whether an AI concern belongs to storage, reasoning, or draw.
- Open this file when adding or retiring AI owners or when public re-export policy for shared AI APIs changes.
- The exported set here connects tactical motion, world awareness, strategic choice, and supporting data models.
- Agents should start here when tracing AI behavior because it reveals the authoritative file split by concern.
- This index owns visibility and compatibility re-exports rather than world state, planners, or runtime solvers.
- Neighboring work usually spans Agent, AIWorld, steering, planning modules, and debug visualization helpers.
- It is the right owner for composition-level AI API changes that should not alter any one behavior algorithm.
- Read this file first when generated specs or Lua bindings need to map a feature to its concrete Rust owner.

### needs.rs

- Owns normalized need pressures and advertisements so motivation can decay, recover, and compete for attention.
- Defines individual needs, local satisfier offers, cooldown handling, and the need-system collection for one agent.
- Scores urgency and candidate advertisements so fulfillment choice can depend on both pressure and travel context.
- Provides the motivation boundary between internal drives and higher decision layers that choose what to satisfy.
- Open this owner when urgency math, advertisement cooldowns, or need decay behavior needs coordinated changes.

### orca.rs

- Implements ORCA-style local collision avoidance that projects preferred motion into safe velocity choices.
- Owns solver agents, pairwise half-plane constraints, time horizon tuning, and the linear projection step.
- Computes a safe velocity for every registered agent while respecting radius and max-speed bounds.
- Provides the crowd-avoidance boundary between desired steering intent and collision-safe local movement output.
- Open this owner when avoidance stability, neighbor constraints, or safe-velocity projection needs adjustment.

### perception.rs

- Owns the perception stream that stores stimuli, sensor tuning, awareness memory, and multi-channel detection rules.
- Defines visual, auditory, and custom stimulus types plus the world container that adds, decays, and removes them.
- Lets sensors test sight cones, hearing ranges, and custom labels, then produce detected cues with distance data.
- Also updates alertness over time so awareness can rise from repeated contact and decay after stimuli disappear.
- Provides the sensing boundary between world cue production and agent logic that needs filtered evidence only.
- This file matters when awareness, detection ranges, or cue classification stop matching authored AI expectations.
- Open this owner when perception memory or stimulus lifetimes are wrong before touching higher-level planners.

### render.rs

- Adds AI debug rendering adapters that translate FSM and behavior-tree state into commands or image snapshots.
- Owns layout helpers for state boxes, transition lines, behavior-tree node graphs, and status indicator visuals.
- Provides the presentation boundary between live AI state structures and generic renderer or image debug surfaces.
- Supports both command-stream overlays and raster output so tooling and in-engine inspection share one owner.
- This file is the right place for visualization-only changes that should not alter decision logic behavior itself.
- Open this owner when AI debug views are misleading even though the underlying state machines still evaluate well.

### squad.rs

- Owns squad-level coordination state that groups members around a leader, formation choice, and shared blackboard.
- Defines formation semantics for line, wedge, circle, and column layouts, yielding member offsets from the leader.
- Provides the group-coordination boundary between individual agents and higher-level formation-aware movement logic.
- Also carries squad-local context so cooperative decisions can read shared tactical state instead of isolated tags.
- Open this owner when formation geometry or leader-centric placement rules need to change across the whole squad.

### steering.rs

- Owns the continuous steering runtime that turns many movement influences into one bounded force for an agent.
- Defines seek, flee, arrive, wander, pursue, evade, flock, and custom behavior variants with shared base state.
- Combines behavior outputs under weighted or priority blending so path following and reactive forces can coexist.
- Stores waypoint path progress, named entity context, and last-force output beside the behavior collection itself.
- Provides the movement boundary between high-level intent and low-level velocity updates driven every frame.
- This file matters when acceleration shaping, blend semantics, or path-follow steering interaction is incorrect.
- Neighboring changes usually involve agent movement data, context steering, ORCA, and authored path waypoints.
- Open this owner when motion quality is wrong even though the chosen decision and destination are already correct.
- It is the right file for steering-force bugs because no sibling module owns the final force synthesis contract.

### strategy.rs

- Owns strategic goal arbitration that periodically scores candidate intents against active tags and timing cadence.
- Stores named goals, priorities, eligibility tags, the active goal, and the timer used to throttle reevaluation.
- Blends static priority with caller-provided dynamic scores so long-horizon intent can remain stable yet adaptive.
- Provides the high-level intent boundary between world context and tactical systems that consume one active goal.
- Open this owner when goal churn, update cadence, or tag-gated strategy selection needs a shared correction.

### traits.rs

- Owns persistent personality trait profiles and temporary modifiers that shape how other AI systems score choices.
- Stores base values, expiring additive modifiers, and optional archetype provenance used to initialize a profile.
- Supports deterministic archetype jitter, modifier aging, interpolation, and source-based modifier removal.
- Provides the temperament boundary between authored character identity and tactical systems that read trait values.
- Also maintains the archetype registry so reusable presets stay separate from one-off agent mutation logic.
- Open this owner when personality baselines, modifier lifetimes, or archetype contracts need shared changes.

### utility_ai.rs

- Owns the utility-AI scorer that ranks candidate actions through response curves and per-action consideration data.
- Defines response-curve variants, considerations, actions, and the last-evaluation score snapshot for inspection.
- Calls action scorers, applies momentum bonuses, and records the chosen action so later systems can read results.
- Provides the continuous scoring boundary between raw Lua evaluations and one selected utility-driven action.
- Open this owner when nonlinear score shaping, momentum behavior, or action-evaluation bookkeeping needs changes.

### validation.rs

- Owns shared AI sizing, traversal, and numeric validation limits used by planners, steering, trees, and scoring helpers.
- It centralizes checked counts and finite-value policy so AI owners share one narrow validation contract.
- Open it when AI ceilings or numeric hardening rules change across the subsystem.

### world.rs

- Owns the global AI world registry that stores agents, name lookup, and the shared blackboard inherited by new actors.
- Provides add, remove, index, and mutable access helpers so population-level systems can manage agents coherently.
- Advances all agents through one broad world pulse, integrating velocity into position inside the central owner.
- Open this owner when registry integrity or world-wide update flow needs coordinated changes across agents.



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
- `LAIWorld:getLastCallbackErrors() -> table`: Returns callback errors recorded during the most recent `update` call.
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
- `LGOAPPlanner:getLastFailureReason() -> LuaValue`: Returns the last planner failure reason string when planning did not succeed.
- `LGOAPPlanner:getLastTrace() -> table`: Returns the last structured GOAP planning trace.
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

- `LMCTSEngine:getLastTrace() -> table`: Returns the last structured MCTS search trace.
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
- `LSteeringManager:clearEntities() -> nil`: Clears all steering-context entities.
- `LSteeringManager:clearPath() -> nil`: Clears the active waypoint path behavior.
- `LSteeringManager:enableSpatialHash(enabled) -> nil`: Enables or disables spatial hash acceleration for neighbor queries.
- `LSteeringManager:entityCount() -> integer`: Returns the number of steering-context entities.
- `LSteeringManager:getBehaviorCount() -> integer`: Returns the number of steering behaviors configured on this manager.
- `LSteeringManager:getCombineMode() -> string`: Returns the current steering force combination mode.
- `LSteeringManager:getLastDiagnostic() -> LuaValue`: Returns the most recent steering validation or runtime diagnostic.
- `LSteeringManager:getLastSteering() -> number, number`: Returns the last steering force calculated by this manager.
- `LSteeringManager:getPathProgress() -> integer, integer`: Returns the current one-based waypoint index and total waypoint count.
- `LSteeringManager:hasPath() -> boolean`: Returns whether this manager currently has an active waypoint path.
- `LSteeringManager:removeEntity(name) -> boolean`: Removes one named steering-context entity.
- `LSteeringManager:setCombineMode(mode) -> nil`: Sets how steering behavior forces are combined.
- `LSteeringManager:setEntity(name, x, y, vx?, vy?) -> nil`: Sets or replaces one named steering-context entity.
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
- `LUtilityAI:getLastTrace() -> table`: Returns the last structured utility evaluation trace.
- `LUtilityAI:type() -> string`: Returns the Lua-visible type name for this utility AI handle.
- `LUtilityAI:typeOf(name) -> boolean`: Returns whether this utility AI handle matches a supported type name.

## References

- `dialog`: Imports or references `src/dialog/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `image`: Imports or references `image` from `src/image/`.
- `learning`: Imports or references `src/learning/`. Cross-group dependency from `Feature Systems` into `Edge/Integration`.
- `patterns`: Imports or references `src/patterns/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `render` from `src/render/`.
- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
