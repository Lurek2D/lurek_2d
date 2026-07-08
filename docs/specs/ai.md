<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/ai.md or source docstrings instead. -->

# ai

## TL;DR

- Orchestrates agent choices via behavior trees, FSMs, GOAP, HTN, and utility AI.
- Interprets sensory perception, internal state, goals, plans, and action-selection models.
- Tracks squad coordination, trait-driven emotional motives, needs, and dramatic pacing.
- Exposes agent-owned command queues with inspectable order snapshots and drainable lifecycle events.
- Adds footprint-aware squad slot planning with distance-based ordering, subgroup preservation, and lane-width fallback.
- Consumes learned policies only through explicit `learning` integration points; ML/RL constructors live under the `learning` module.
- Controls dramatic pacing waves and optimizes runtime budgets with distance-based LOD tiers.

## General Info

- Module group: `Feature Systems`
- Source path: `src/ai`
- Binding: `src/lua_api/ai_api.rs`
- Namespace: `lurek.ai`
- Lua API surface: `29` functions, `22` types, `242` methods
- User-facing: `true`
- Plugin tier: `tier_1_plugin`

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
- Formation planning on the squad surface now goes beyond simple offsets. Member footprint metadata, subgroup clustering, and lane-width fallback give Lua enough engine support to express useful RTS-style group movement without re-implementing slot ordering or chokepoint degradation in scripts.
- Command queues are important because AI output is often not the final physical action. A stable queue boundary separates “what the AI wants next” from “what the actor is currently doing,” which helps with interruption, inspection, and synchronization with animation or movement systems.
- Agent-owned queues also make RTS-style control practical because Lua can inspect current and pending orders, drain lifecycle events, and clear orders per actor without rebuilding queue state on the script side.
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

## Ownership

- Canonical source: `src/ai`
- Owning tier: `Feature Systems`
- Plugin tier: `tier_1_plugin`
- Lua binding owner: `src/lua_api/ai_api.rs`
- Referenced engine modules: `dialog`, `image`, `patterns`, `render`, `runtime`

## Imports

- `dialog`: Imports or references `src/dialog/`. Dependency stays inside `Feature Systems` and should remain acyclic.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `patterns`: Imports or references `src/patterns/`. Cross-group dependency from `Feature Systems` into `Foundations`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Feature Systems` into `Platform Services`.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Feature Systems` into `Core Runtime`.

## Source Files

### agent.rs

- Defines the runtime state shape for one AI actor, combining identity, movement state, decision mode, and support models.
- Owns the DecisionModel enum plus agent-side blackboard, tags, optional sensor, emotions, needs, and traits.
- Stores links into decision-runtime handles so one agent can bind to FSM, behavior-tree, and movement-guidance models.
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

### diagnostics.rs

- Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.
- Keeps ai data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
- Defines how diagnostics data is validated, transformed, or stored before neighboring systems use it.
- Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.

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

- Owns the error taxonomy for the ai subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around AiError, fmt, with helpers kept close to their invariants.
- Defines how error data is validated, transformed, or stored before neighboring systems use it.
- Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.

### fsm.rs

- Owns the finite-state-machine runtime that stores named states, guarded transitions, and state dwell timing.
- Defines Lua callback sets for enter, update, and exit plus prioritized transitions sorted for deterministic checks.
- Tracks current and initial state names so runtime code can progress stateful control without external bookkeeping.
- Provides the mode-switching boundary between authored state logic and the systems that tick one active state.
- Open this owner when transition priority, callback registration, or time-in-state behavior needs revision.

### goap.rs

- Owns the goap owner for the ai subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around PlanFailureReason, as_str, GOAPAction, with helpers kept close to their invariants.
- Defines how goap data is validated, transformed, or stored before neighboring systems use it.
- Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.
- Keeps public crate helpers focused on goap behavior while Lua registration stays elsewhere.
- Documents the boundary where ai code accepts inputs, reports errors, or updates state while keeping call sites explicit.
- Use this file when changing goap defaults, lifecycle handling, validation, or data ownership.

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

- Exports the AI subsystem surface that groups decision models, sensing, planning, pacing, and debug tools.
- Acts as the navigation index for agent state, behavior trees, GOAP, HTN, MCTS, squads, and utility scoring.
- Keeps module boundaries explicit so callers can find whether an AI concern belongs to storage, reasoning, or draw.
- Open this file when adding or retiring AI owners or when public re-export policy for shared AI APIs changes.
- The exported set here connects world awareness, strategic choice, internal drives, and supporting data models.
- Agents should start here when tracing AI behavior because it reveals the authoritative file split by concern.
- This index owns visibility and compatibility re-exports rather than world state, planners, or runtime solvers.
- Neighboring work usually spans Agent, AIWorld, planning modules, and debug visualization helpers.
- It is the right owner for composition-level AI API changes that should not alter any one behavior algorithm.
- Read this file first when generated specs or Lua bindings need to map a feature to its concrete Rust owner.

### needs.rs

- Owns normalized need pressures and advertisements so motivation can decay, recover, and compete for attention.
- Defines individual needs, local satisfier offers, cooldown handling, and the need-system collection for one agent.
- Scores urgency and candidate advertisements so fulfillment choice can depend on both pressure and travel context.
- Provides the motivation boundary between internal drives and higher decision layers that choose what to satisfy.
- Open this owner when urgency math, advertisement cooldowns, or need decay behavior needs coordinated changes.

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

### strategy.rs

- Owns strategic goal arbitration that periodically scores candidate intents against active tags and timing cadence.
- Stores named goals, priorities, eligibility tags, the active goal, and the timer used to throttle reevaluation.
- Blends static priority with caller-provided dynamic scores so long-horizon intent can remain stable yet adaptive.
- Provides the high-level intent boundary between world context and tactical systems that consume one active goal.
- Open this owner when goal churn, update cadence, or tag-gated strategy selection needs a shared correction.

### traits.rs

- Owns the ai traits implementation for the ai subsystem and keeps related runtime rules local here.
- Keeps AI world state, traits, and decision-facing helpers so helpers stay close to invariants this file updates.
- Defines how ai traits data is validated, transformed, or stored before neighboring systems consume it.
- Separates ai traits behavior from Lua bindings, tests, and sibling owners so integration stays readable.
- Documents the boundary where ai code accepts inputs, reports errors, allocates state, or emits outputs.
- Use this file when changing ai traits defaults, lifecycle handling, validation, or data ownership rules.
- Keeps failure paths and edge cases near the ai traits state that explains them instead of spreading rules outward.

### utility_ai.rs

- Owns the utility ai owner for the ai subsystem and keeps its rules local to this file while keeping call sites explicit.
- Centers the implementation around ResponseCurve, parse_str, apply, with helpers kept close to their invariants.
- Defines how utility ai data is validated, transformed, or stored before neighboring systems use it.
- Owns ai behavior with explicit state, validation, and crate-local integration boundaries. for engine changes.
- Keeps public crate helpers focused on utility ai behavior while Lua registration stays elsewhere.
- Documents the boundary where ai code accepts inputs, reports errors, or updates state while keeping call sites explicit.
- Use this file when changing utility ai defaults, lifecycle handling, validation, or data ownership.

### validation.rs

- Owns shared validation limits for AI worlds, behavior trees, GOAP, utility AI, MCTS, and sensors.
- Centralizes numeric guards so planners, registries, and Lua-facing helpers reject the same bad shapes.
- Provides finite, count, and dimension checks with structured `AiError` output instead of panics.
- Keeps safety ceilings near AI domain code while avoiding ownership of any planner or evaluator state.
- Update this file when AI modules need new limits, validation helpers, or cross-module guard policy.

### world.rs

- Owns the ai world implementation for the ai subsystem and keeps related runtime rules local here.
- Keeps AI world state, traits, and decision-facing helpers so helpers stay close to invariants this file updates.
- Defines how ai world data is validated, transformed, or stored before neighboring systems consume it.
- Separates ai world behavior from Lua bindings, tests, and sibling owners so integration stays readable.



## Lua API Ref

### Functions

- `lurek.ai.newAIDirector() -> LAIDirector`: Creates an AI director for tension, phase, and pacing factor calculations.
- `lurek.ai.newAILod() -> LAILod`: Creates a default AI level-of-detail tier selector.
- `lurek.ai.newAction(callback) -> LBTNode`: Creates a behavior tree action leaf backed by a Lua callback.
- `lurek.ai.newBehaviorTree() -> LBehaviorTree`: Creates an empty behavior tree that can receive a root node.
- `lurek.ai.newBlackboard() -> LAIBlackboard`: Creates an empty AI blackboard for typed local facts.
- `lurek.ai.newCommandQueue() -> LCommandQueue`: Creates an empty command queue for callback-backed AI commands.
- `lurek.ai.newCondition(callback) -> LBTNode`: Creates a behavior tree condition leaf backed by a Lua callback.
- `lurek.ai.newDecisionBiasSet() -> LDecisionBiasSet`: Creates an empty set of rules that map profile traits onto named decision scores.
- `lurek.ai.newDialogueAI() -> LDialogueAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.ai.newEmotionModel() -> LEmotionModel`: Creates an empty emotion model for named decaying emotion values.
- `lurek.ai.newGOAPPlanner() -> LGOAPPlanner`: Creates an empty GOAP planner for boolean world-state planning.
- `lurek.ai.newGuard(predicate, child) -> LBTNode`: Creates a guard decorator that runs a predicate before ticking its child.
- `lurek.ai.newHTNDomain() -> LHTNDomain`: Creates an empty hierarchical task network domain.
- `lurek.ai.newInverter() -> LBTNode`: Creates a behavior tree inverter decorator with an empty sequence child.
- `lurek.ai.newMCTSEngine(iters, uct_c, depth, seed) -> LMCTSEngine`: Creates a Monte Carlo tree search engine with deterministic configuration.
- `lurek.ai.newNeedSystem() -> LNeedSystem`: Creates an empty need system for decaying named needs.
- `lurek.ai.newParallel(sp?, fp?) -> LBTNode`: Creates a behavior tree parallel node with optional success and failure policies.
- `lurek.ai.newRepeater(count?) -> LBTNode`: Creates a behavior tree repeater decorator with an optional repeat count.
- `lurek.ai.newSelector() -> LBTNode`: Creates a behavior tree selector node with no children.
- `lurek.ai.newSequence() -> LBTNode`: Creates a behavior tree sequence node with no children.
- `lurek.ai.newSquad(name) -> LSquad`: Creates an empty named squad. This function is exposed to Lua scripts.
- `lurek.ai.newStateMachine() -> LStateMachine`: Creates an empty finite state machine with Lua-backed states and transitions.
- `lurek.ai.newStimulusWorld() -> LStimulusWorld`: Creates an empty stimulus world for visual and auditory stimulus records.
- `lurek.ai.newStrategyAI(update_interval) -> LStrategyAI`: Creates a strategy AI that reevaluates goals on a fixed interval.
- `lurek.ai.newSucceeder() -> LBTNode`: Creates a behavior tree succeeder decorator with an empty sequence child.
- `lurek.ai.newTraitArchetypes() -> LTraitArchetypes`: Creates a trait archetype registry populated with engine-provided commander presets.
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
- `LAIWorld:getAutoAcquireBudget() -> integer`: Returns the per-update budget used for stance-driven hostile-acquisition queries.
- `LAIWorld:getGlobalBlackboard() -> LAIBlackboard`: Returns a blackboard snapshot containing the world's shared AI facts.
- `LAIWorld:getLastCallbackErrors() -> table`: Returns callback errors recorded during the most recent `update` call.
- `LAIWorld:getOrderArrivalRadius() -> number`: Returns the move-order arrival threshold used by world update.
- `LAIWorld:getOrderRuntimeStats() -> table`: Returns statistics from the most recent world update's order execution and acquisition work.
- `LAIWorld:getSpatialCellSize() -> number`: Returns the spatial-hash cell size used by nearby-agent queries in this world.
- `LAIWorld:getSpatialQueryStats() -> table`: Returns statistics from the most recent nearby-agent query.
- `LAIWorld:queryAgentsInRadius(x, y, radius, opts?) -> table`: Returns nearby agents by using the world's persistent spatial index instead of a full Lua scan.
- `LAIWorld:removeAgent(agent) -> nil`: Removes an agent from this world by using an existing agent handle.
- `LAIWorld:setAutoAcquireBudget(budget) -> nil`: Sets the maximum number of stance-driven hostile-acquisition queries attempted in one update.
- `LAIWorld:setOrderArrivalRadius(radius) -> nil`: Sets the move-order arrival threshold used by world update when completing queued move orders.
- `LAIWorld:setSpatialCellSize(size) -> nil`: Sets the spatial-hash cell size used by nearby-agent queries in this world.
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

- `LBot:acquireTarget(opts?) -> LuaValue`: Returns the nearest target selected from this agent's stance-driven hostile-acquisition query.
- `LBot:addTag(tag) -> nil`: Adds a tag string to this agent when the agent still exists in its world.
- `LBot:addTraitModifier(trait_name, delta, duration?, source) -> nil`: Adds a temporary or permanent modifier to one trait on this agent.
- `LBot:clearOrders(reason?) -> integer`: Clears every queued order owned by this agent.
- `LBot:drainCommandEvents() -> table`: Returns and clears queued order lifecycle events for this agent.
- `LBot:findHostilesInRange(radius?, opts?) -> table`: Returns nearby hostile agents by using the world's spatial index and this agent's team as the hostile reference.
- `LBot:getBlackboard() -> LAIBlackboard`: Returns a blackboard snapshot for this agent or an empty blackboard when the agent has been removed.
- `LBot:getCommandQueue() -> LCommandQueue`: Returns this agent's owned command queue handle for order staging and inspection.
- `LBot:getCurrentOrder() -> LuaValue`: Returns the current queued order snapshot for this agent when one exists.
- `LBot:getDecisionModel() -> string`: Returns this agent's decision model name or the default model name for a missing agent.
- `LBot:getMaxForce() -> number`: Returns this agent's maximum steering force or the default force for a missing agent.
- `LBot:getMaxSpeed() -> number`: Returns this agent's maximum movement speed or the default speed for a missing agent.
- `LBot:getName() -> string`: Returns this agent's stable world name.
- `LBot:getOrderRuntimeState() -> table`: Returns the live soft-interruption state used by world update for temporary engagement overrides.
- `LBot:getPosition() -> number, number`: Returns this agent's world position or the origin when the agent has been removed.
- `LBot:getPriority() -> integer`: Returns this agent's integer priority or zero when the agent has been removed.
- `LBot:getStance() -> table`: Returns this agent's current stance profile, including built-in name and effective override values.
- `LBot:getTeam() -> integer`: Returns this agent's integer team identifier or zero when the agent has been removed.
- `LBot:getTrait(name) -> number`: Returns one effective trait value from this agent's profile.
- `LBot:getTraitProfile() -> LuaValue`: Returns a snapshot copy of this agent's trait profile when one is assigned.
- `LBot:getVelocity() -> number, number`: Returns this agent's velocity vector or zero velocity when the agent has been removed.
- `LBot:hasTag(tag) -> boolean`: Returns whether this agent currently has the given tag.
- `LBot:hasTraitProfile() -> boolean`: Returns whether this agent currently has an assigned trait profile.
- `LBot:removeTag(tag) -> nil`: Removes a tag string from this agent when the agent still exists in its world.
- `LBot:setCustomModel(callback) -> nil`: Installs a Lua callback as this agent's decision model and stores it in the callback registry.
- `LBot:setDecisionModel(model) -> nil`: Sets this agent's built-in decision model from a string name when the name is recognized.
- `LBot:setMaxForce(v) -> nil`: Sets this agent's maximum steering force when the agent still exists in its world.
- `LBot:setMaxSpeed(v) -> nil`: Sets this agent's maximum movement speed when the agent still exists in its world.
- `LBot:setPosition(x, y) -> nil`: Sets this agent's world position when the agent still exists in its world.
- `LBot:setPriority(p) -> nil`: Sets this agent's integer priority when the agent still exists in its world.
- `LBot:setStance(stance, opts?) -> nil`: Sets this agent's built-in RTS stance and optionally overrides its acquisition settings.
- `LBot:setTeam(team) -> nil`: Sets this agent's integer team identifier used by hostile-acquisition queries.
- `LBot:setTrait(name, value) -> nil`: Sets one trait on this agent, creating an empty profile first when needed.
- `LBot:setTraitProfile(profile) -> nil`: Copies a trait profile onto this agent so future agent decisions can read commander personality values.
- `LBot:setVelocity(x, y) -> nil`: Sets this agent's velocity vector when the agent still exists in its world.
- `LBot:type() -> string`: Returns the Lua-visible type name for this agent handle.
- `LBot:typeOf(name) -> boolean`: Returns whether this agent handle matches a supported type name.

#### LCommandQueue Type

- Lua handle for a command queue that stores ordered callback-backed commands.

##### Fields

- No documented fields.

##### Methods

- `LCommandQueue:cancelByTag(tag) -> integer`: Cancels all queued orders whose kind matches `tag`.
- `LCommandQueue:cancelCurrent(reason?) -> boolean`: Cancels the currently active command when one exists.
- `LCommandQueue:clear(reason?) -> integer`: Removes every queued command. This method is available to Lua scripts.
- `LCommandQueue:completeCurrent(reason?) -> LuaValue`: Marks the current command as completed and advances the queue.
- `LCommandQueue:drainEvents() -> table`: Returns and clears queued lifecycle events.
- `LCommandQueue:enqueue(kind, callback, opts?) -> integer`: Adds a command callback to the back of the queue.
- `LCommandQueue:failCurrent(reason?) -> boolean`: Marks the current command as failed and advances the queue.
- `LCommandQueue:getCount() -> integer`: Returns the number of commands currently queued.
- `LCommandQueue:getCurrent() -> LuaValue`: Returns the full current command snapshot when one exists.
- `LCommandQueue:getCurrentTarget() -> number, number`: Returns the current command target coordinates.
- `LCommandQueue:getCurrentType() -> LuaValue`: Returns the type label of the current command when one exists.
- `LCommandQueue:getOrderSnapshot() -> table`: Returns every pending order snapshot in queue order.
- `LCommandQueue:getPending() -> table`: Returns every pending command snapshot in queue order.
- `LCommandQueue:isEmpty() -> boolean`: Returns whether the command queue has no commands.
- `LCommandQueue:peekOrder() -> table`: Returns the current order snapshot without advancing the queue.
- `LCommandQueue:pushFront(kind, callback, opts?) -> integer`: Adds a command callback to the front of the queue.
- `LCommandQueue:pushOrder(order) -> integer`: Adds a data-only RTS order to the back of the queue.
- `LCommandQueue:replace(kind, callback, opts?) -> integer`: Replaces the queue contents with one command callback.
- `LCommandQueue:replaceOrders(orders) -> integer`: Replaces the queue with an array of data-only orders.
- `LCommandQueue:type() -> string`: Returns the Lua-visible type name for this command queue handle.
- `LCommandQueue:typeOf(name) -> boolean`: Returns whether this command queue handle matches a supported type name.

#### LDecisionBiasSet Type

- Lua handle for open-ended rules that map traits to action or goal score changes.

##### Fields

- No documented fields.

##### Methods

- `LDecisionBiasSet:addRule(trait_name, decision_key, weight, mode?) -> nil`: Adds one rule that adjusts a named decision score using one trait.
- `LDecisionBiasSet:ruleCount() -> integer`: Returns the number of stored bias rules.
- `LDecisionBiasSet:score(profile, decision_key, base_score) -> number`: Scores one decision using a profile and this bias set.
- `LDecisionBiasSet:type() -> string`: Returns the Lua-visible type name for this decision bias handle.
- `LDecisionBiasSet:typeOf(name) -> boolean`: Returns whether this decision bias handle matches a supported type name.

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

#### LSquad Type

- Lua handle for a named squad with members, leader, formation, and shared blackboard.

##### Fields

- No documented fields.

##### Methods

- `LSquad:addMember(name) -> nil`: Adds a member name to the squad member list.
- `LSquad:assignFormationMove(world, leader_x, leader_y, opts?) -> table`: Resolves formation slots and applies queued `move` orders to matching agents in the supplied world.
- `LSquad:getBlackboard() -> LAIBlackboard`: Returns a blackboard snapshot for this squad.
- `LSquad:getFormation() -> string`: Returns the current squad formation type name.
- `LSquad:getFormationBehavior() -> table`: Returns the current formation assignment behavior settings.
- `LSquad:getFormationPosition(member_idx, leader_x, leader_y) -> number, number`: Returns a member's target formation position relative to the leader position.
- `LSquad:getFormationSlots(leader_x, leader_y, opts?) -> table`: Returns resolved formation slot assignments for every member, optionally using current member positions and lane width.
- `LSquad:getFormationSpacing() -> number`: Returns the spacing used by squad formation positioning.
- `LSquad:getFormationSummary(leader_x, leader_y, opts?) -> table`: Returns formation layout metadata after slot assignment and fallback policy are resolved.
- `LSquad:getLeader() -> LuaValue`: Returns the squad leader name when one is assigned.
- `LSquad:getMemberCount() -> integer`: Returns the number of members in this squad.
- `LSquad:getMemberProfile(name) -> table`: Returns the stored footprint and subgroup metadata for one member.
- `LSquad:getMembers() -> string[]`: Returns all squad members in an array-style Lua table.
- `LSquad:getName() -> string`: Returns the squad name. This method is available to Lua scripts.
- `LSquad:removeMember(name) -> nil`: Removes every member entry with the given name.
- `LSquad:setFormation(ftype, spacing?) -> nil`: Sets the squad formation type and optionally updates spacing.
- `LSquad:setFormationBehavior(sort_mode, fallback_mode?, preserve_subgroups?) -> nil`: Sets formation assignment behavior knobs used for slot ordering and chokepoint fallback.
- `LSquad:setLeader(name) -> nil`: Sets the squad leader name. This method is available to Lua scripts.
- `LSquad:setMemberProfile(name, opts) -> nil`: Stores footprint and subgroup metadata used during formation slot assignment.
- `LSquad:submitFormationPaths(world, grid, leader_x, leader_y, opts) -> table`: Resolves formation slots, converts world positions into navigation cells, and submits one async paired path batch.
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

#### LTraitArchetypes Type

- Lua handle for named trait archetypes used to create reusable AI personalities.

##### Fields

- No documented fields.

##### Methods

- `LTraitArchetypes:count() -> integer`: Returns the number of registered archetypes.
- `LTraitArchetypes:createProfile(name, variance?) -> LuaValue`: Creates a trait profile from a registered archetype and optional deterministic variance.
- `LTraitArchetypes:names() -> table`: Returns registered archetype names.
- `LTraitArchetypes:register(name, traits) -> nil`: Registers or replaces one named archetype from a table of trait values.
- `LTraitArchetypes:type() -> string`: Returns the Lua-visible type name for this archetype registry handle.
- `LTraitArchetypes:typeOf(name) -> boolean`: Returns whether this archetype registry handle matches a supported type name.

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
- `LTraitProfile:names() -> table`: Returns this profile's trait names.
- `LTraitProfile:removeModifiers(source) -> nil`: Removes all trait modifiers that match a source label.
- `LTraitProfile:scoreDecision(biases, decision_key, base_score) -> number`: Scores one decision by applying a decision bias set to this profile.
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
- `LUtilityAI:evaluateWithProfile(profile, biases) -> LuaValue`: Evaluates all actions after applying trait-profile decision bias rules to each action score.
- `LUtilityAI:getActionCount() -> integer`: Returns the number of actions registered in this utility AI.
- `LUtilityAI:getLastAction() -> LuaValue`: Returns the last winning action name when evaluation has selected one.
- `LUtilityAI:getLastTrace() -> table`: Returns the last structured utility evaluation trace.
- `LUtilityAI:type() -> string`: Returns the Lua-visible type name for this utility AI handle.
- `LUtilityAI:typeOf(name) -> boolean`: Returns whether this utility AI handle matches a supported type name.

## Examples

- `content/examples/ai.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
