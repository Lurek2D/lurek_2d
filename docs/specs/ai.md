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
- Lua API surface: `36` functions, `24` types, `241` methods
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua_reorg/unit/test_ai.lua, tests/lua_reorg/golden/test_ai_golden.lua, tests/lua_reorg/integration/test_ecs_ai.lua, tests/lua_reorg/integration/test_ai_physics.lua, tests/lua_reorg/integration/test_ai_pathfind.lua, tests/lua_reorg/integration/test_ai_ecs_scene.lua, tests/lua_reorg/stress/test_ai_stress.lua

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

This module primarily collaborates with `dialog`, `image`, `learning`, `patterns`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

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

## Types

- `DecisionModel` (`enum`, `agent.rs`): Active AI decision strategy assigned to an `Agent`. Details: variants: Fsm, Bt, Steering, FsmSteering, BtSteering, Custom | methods: as_str (Return the canonical string tag for this model.); parse_str (Parse a string tag into a `DecisionModel`; returns `None` for unknown tags.)
- `Agent` (`struct`, `agent.rs`): Runtime state for one AI-controlled entity in the world. Details: fields: name: String, priority: i32, position: (f32, velocity: (f32, max_speed: f32, max_force: f32, decision_model: DecisionModel, blackboard: Blackboard, tags: HashSet<String>, fsm_index: Option<usize>, bt_index: Option<usize>, steering_index: Option<usize>, trait_profile: Option<TraitProfile>, sensor: Option<Sensor>, emotion_model: Option<EmotionModel>, need_system: Option<NeedSystem>, lod_tier: usize | methods: new (Create a new agent with default movement, AI, and support systems.)
- `BTStatus` (`enum`, `behavior_tree.rs`): Execution result produced by a behavior-tree node or whole tree. Details: variants: Success, Failure, Running | methods: as_str (Return the canonical lowercase string tag for this status.); parse_str (Parse a string tag into `BTStatus`; unknown strings default to `Running`.)
- `ParallelPolicy` (`enum`, `behavior_tree.rs`): Success and failure rule used when a parallel node combines child results. Details: variants: RequireOne, RequireAll | methods: as_str (Return the canonical string tag for this policy.); parse_str (Parse a string tag; unknown strings default to `RequireOne`.)
- `BTNode` (`enum`, `behavior_tree.rs`): Behavior-tree node with child links and any per-node progress it owns. Details: variants: Selector, Sequence, Parallel, Inverter, Repeater, Succeeder, Guard, Action, Condition | methods: child_count (Return the number of direct children; leaf nodes return 0.); reset (Reset all running indices and repetition counters in this subtree recursively.)
- `BehaviorTree` (`struct`, `behavior_tree.rs`): Root node and last completed status for one behavior-tree instance. Details: fields: root: Option<BTNode>, last_status: BTStatus | methods: debug_state (Build a `BtDebugState` snapshot from the current tree shape and status.); draw_to_image (Draw the BT debug view into an `ImageData` buffer.); generate_render_commands (Build render commands for the BT debug view.); new (Create an empty tree with `last_status` initialised to `Success`.)
- `BtDebugState` (`struct`, `behavior_tree.rs`): Debug summary containing node count and the last resolved tree status. Details: fields: node_count: usize, last_status: String
- `Command` (`struct`, `command_queue.rs`): Pending AI action with target data and an optional completion callback. Details: fields: kind: String, callback: RegistryKey, target_x: f32, target_y: f32, priority: i32, interruptible: bool
- `CommandQueue` (`struct`, `command_queue.rs`): FIFO queue of pending AI commands for one actor. Details: fields: commands: VecDeque<Command> | methods: advance (Remove the front command as completed and expose the next one.); cancel_current (Pop the front command if it is interruptible; return `true` on success.); clear (Discard all queued commands.); count (Return the number of pending commands.); current_target (Return the `(target_x, target_y)` of the front command; returns `(0, 0)` if empty.); current_type (Return the `kind` tag of the front command, or `None` if the queue is empty.); enqueue (Append `cmd` to the back of the queue.); enqueue_raw (Build a `Command` from raw parts and append it to the back of the queue.); is_empty (Return `true` when the queue has no pending commands.); new (Create an empty queue.); push_front (Insert `cmd` at the front, making it the next command to execute.); push_front_raw (Build a `Command` from raw parts and insert it at the front of the queue.); replace (Clear the entire queue and enqueue `cmd` as the sole pending command.); replace_raw (Build a `Command` from raw parts, clear the queue, and set it as the only entry.)
- `ContextBehaviorKind` (`enum`, `context_steering.rs`): Behavior kind used by context steering slots. Details: variants: SeekTarget, AvoidPoint, Wander, Direction, AvoidBounds
- `ContextBehavior` (`struct`, `context_steering.rs`): Single behavior contribution to a context-steering ring. Details: fields: kind: ContextBehaviorKind, weight: f32, is_interest: bool, enabled: bool
- `ContextSteering` (`struct`, `context_steering.rs`): Slot-based steering accumulator with interest, danger, and result rings. Details: methods: add_avoid_bounds (Add a world-bounds avoidance danger behavior.); add_avoid_point (Add a point-avoidance danger behavior.); add_danger (Add a danger behavior.); add_interest (Add an interest behavior.); add_seek_target (Add a seek-target interest behavior.); add_wander (Add a wander interest behavior.); chosen_direction (Return the heading in radians chosen by the last evaluation.); chosen_magnitude (Return the magnitude chosen by the last evaluation.); clear_behaviors (Remove all registered behaviors.); danger_map (Return a copy of the last computed danger ring.); evaluate (Evaluate all behaviors and return the chosen steering direction vector.); interest_map (Return a copy of the last computed interest ring.); new (Create a context-steering sampler with at least four slots.); slot_count (Return the number of angular slots.)
- `DirectorPhase` (`enum`, `director.rs`): Director pacing phase. Details: variants: BuildUp, Peak, Sustain, Relief | methods: as_str (Return the canonical string tag for this pacing phase.)
- `DirectorConfig` (`struct`, `director.rs`): Tunable thresholds for the AI director. Details: fields: tension_decay_rate: f32, peak_threshold: f32, relief_threshold: f32, sustain_duration: f32, max_tension_per_event: f32, peak_spawn_factor: f32, relief_loot_factor: f32
- `AIDirector` (`struct`, `director.rs`): Runtime director state used by pacing systems. Details: fields: config: DirectorConfig | methods: ambient_intensity (Return the current ambient intensity scalar.); elapsed (Return elapsed seconds.); loot_factor (Return the current loot multiplier.); new (Create a director with default config.); phase (Return the current phase.); phase_str (Return the current phase as a string tag.); push_event (Add one event and clamp the resulting tension to `[0, 1]`.); reset (Reset tension, phase, and timers to their initial state.); set_tension (Set tension directly and clamp it to `[0, 1]`.); spawn_rate_factor (Return the current spawn rate multiplier.); tension (Return the current tension.); total_events (Return total events received.); update (Advance the director and update phase transitions.); with_config (Create a director with a custom config.)
- `Emotion` (`struct`, `emotion.rs`): One named emotion tracked by `EmotionModel`. Details: fields: name: String, value: f32, resting_level: f32, decay_rate: f32, min_visible: f32 | methods: is_active (Return `true` when the emotion is above the visible threshold.); new (Create a new emotion with clamped resting and visibility levels.); set (Set the emotion value directly and clamp it to `[0, 1]`.); trigger (Increase the emotion value and clamp it to `[0, 1]`.); update (Move the emotion toward its resting level over `dt` seconds.)
- `EmotionModel` (`struct`, `emotion.rs`): Collection of named emotions for one agent. Details: methods: active_names (Return the names of all active emotions.); add (Add or replace an emotion by name.); count (Return the number of tracked emotions.); dominant (Return the name of the highest active emotion, or `None` when none are active.); get (Return the current value for `name`, or 0.0 if missing.); is_active (Return `true` when the named emotion exists and is active.); new (Create an empty emotion model.); reset (Reset all emotions to their resting levels.); set (Set the value of the named emotion when present.); trigger (Increase the value of the named emotion when present.); update (Advance all emotions toward their resting levels.)
- `StateCallbacks` (`struct`, `fsm.rs`): Lua callback set attached to one FSM state. Details: fields: on_enter: Option<RegistryKey>, on_update: Option<RegistryKey>, on_exit: Option<RegistryKey>
- `Transition` (`struct`, `fsm.rs`): One transition rule between FSM states. Details: fields: from: String, to: String, guard: Option<RegistryKey>, priority: i32
- `StateMachine` (`struct`, `fsm.rs`): Finite-state-machine storage for states, transitions, and runtime selection. Details: fields: states: HashMap<String, transitions: Vec<Transition>, current_state: Option<String>, initial_state: Option<String>, time_in_state: f32 | methods: add_state_raw (Register a state by name with optional enter, update, and exit registry keys.); add_transition (Register a transition and re-sort the transition list by descending priority.); add_transition_raw (Build a `Transition` from raw parts and add it via `add_transition`.); current_state (Return the name of the currently active state, or `None` before the first tick.); draw_to_image (Draw the FSM debug view into an `ImageData` buffer.); generate_render_commands (Build line and box commands for the FSM debug view.); new (Create an empty state machine with no states or transitions.); set_initial_state (Set the state name that will be activated on the first tick.); time_in_state (Return elapsed seconds since the current state was entered.)
- `GOAPAction` (`struct`, `goap.rs`): One GOAP action with planning metadata and world-state changes. Details: fields: name: String, cost: f64, callback: Option<RegistryKey>, preconditions: HashMap<String, effects: HashMap<String
- `GOAPGoal` (`struct`, `goap.rs`): One named goal with a priority and desired world state. Details: fields: name: String, priority: f64, state: HashMap<String
- `GOAPPlanner` (`struct`, `goap.rs`): GOAP planner that stores actions, goals, and the bounded search configuration. Details: fields: actions: Vec<GOAPAction>, goals: Vec<GOAPGoal>, max_iterations: usize | methods: add_action (Register a new action with an empty precondition and effect set.); add_effect (Add an effect entry to the named action; no-op if the action is not found.); add_goal (Register a new goal with an empty desired state map.); add_precondition (Add a precondition entry to the named action; no-op if the action is not found.); get_max_iterations (Return the current A* iteration cap.); new (Create a planner with an empty action and goal lists and `max_iterations = 10 000`.); plan (Plan for the highest-priority goal; return ordered action name list or empty on failure.); plan_for_goal_idx (Plan for the goal at `goal_idx`; return ordered action name list or empty on failure.); set_goal_state (Add a desired world-state entry to the named goal; no-op if goal is not found.); set_max_iterations (Set the A* iteration cap to `n`.)
- `WorldState` (`type`, `htn.rs`): Symbolic world state keyed by string names.
- `HTNTask` (`enum`, `htn.rs`): Compound or primitive task in an HTN domain. Details: variants: Compound, Primitive | methods: apply_effects (Apply primitive effects to the world state.); is_primitive (Return `true` for primitive tasks.); name (Return the task name.); preconditions_met (Return `true` when the task preconditions are satisfied.)
- `HTNMethod` (`struct`, `htn.rs`): One method that decomposes a compound task into subtasks. Details: fields: name: String, preconditions: Vec<String>, sub_tasks: Vec<String> | methods: always (Create a method with no preconditions.); is_applicable (Return `true` when the method preconditions are satisfied.); with_preconditions (Create a method with explicit preconditions.)
- `HTNDomain` (`struct`, `htn.rs`): Task registry that stores the named HTN tasks available to planning. Details: methods: add_compound (Add a compound task.); add_primitive (Add a primitive task.); get (Return a task by name.); new (Create an empty domain.); register (Register a task by its name.); task_count (Return the number of tasks in the domain.)
- `HTNPlanner` (`struct`, `htn.rs`): HTN planner that expands a root task into a primitive task sequence. Details: methods: plan (Plan from `root_task` and return a primitive task sequence, or `None` on failure.)
- `LodTier` (`struct`, `lod.rs`): One LOD bucket for AI work. Details: fields: name: String, max_distance: f32, update_every: u32, think_distance: f32 | methods: new (Create a tier with the given parameters.)
- `AILod` (`struct`, `lod.rs`): Ordered LOD tier set. Details: fields: tiers: Vec<LodTier> | methods: assign_tiers (Return one tier index per agent position.); new (Sort tiers by distance and build an `AILod`.); should_update (Return `true` when tier `tier` should update on `frame_number`.); tier (Return tier `i` if it exists.); tier_count (Return the number of tiers.); tier_for (Return the tier index for `agent_pos` relative to `ref_pos`.)
- `MCTSConfig` (`struct`, `mcts.rs`): Configuration for one MCTS search run. Details: fields: iterations: u32, uct_c: f32, rollout_depth: usize, seed: u64
- `MCTSEngine` (`struct`, `mcts.rs`): MCTS search engine with an internal arena-backed tree. Details: fields: config: MCTSConfig | methods: config (Return the active config.); new (Create a search engine with the provided config.); search (Search for the best action and return its id, or `None` when no actions exist.)
- `Need` (`struct`, `needs.rs`): One tracked need with a normalized value. Details: fields: name: String, value: f32, decay_rate: f32, urgency_threshold: f32, urgency_factor: f32, enabled: bool | methods: deprive (Decrease the need value and clamp it at 0.); is_urgent (Return `true` when the need is enabled and below its urgency threshold.); new (Create a need with value initialized to 1.0.); satisfy (Increase the need value and clamp it to `[0, 1]`.); update (Apply passive decay over `dt` seconds.); urgency_score (Return a score used for prioritising needs.)
- `NeedAdvertisement` (`struct`, `needs.rs`): Local advertisement that satisfies a specific need. Details: fields: need_name: String, satisfaction: f32, position: (f32, advertiser_name: String, cooldown: f32, remaining_cooldown: f32 | methods: is_available (Return `true` when the ad is off cooldown.); new (Create a new advertisement at `(x, y)`.); score (Return a distance-weighted score for the ad.); update (Advance the cooldown timer.); use_it (Start the cooldown timer when the ad has a positive cooldown.)
- `NeedSystem` (`struct`, `needs.rs`): Collection of named needs for one agent. Details: methods: add_need (Add or replace a need by name.); best_advertisement (Return the best-scoring available advertisement, or `None` if none score positive.); get (Return a need by name, or `None` if missing.); get_mut (Return a mutable need by name, or `None` if missing.); most_urgent (Return the most urgent enabled need name, or `None` when none are enabled.); need_names (Return all tracked need names.); new (Create an empty need system.); satisfy (Increase the named need when present.); update (Advance all needs by `dt` seconds.); value_of (Return the current value of the named need, or 1.0 if missing.)
- `ORCAAgent` (`struct`, `orca.rs`): One agent used by the ORCA solver. Details: fields: position: (f32, velocity: (f32, preferred_velocity: (f32, safe_velocity: (f32, radius: f32, max_speed: f32 | methods: new (Create a new agent at `(x, y)`.)
- `ORCASolver` (`struct`, `orca.rs`): Solver that computes collision-free velocities for all registered agents. Details: fields: time_horizon: f32, agents: Vec<ORCAAgent> | methods: add_agent (Add an agent and return its index.); agent_count (Return the number of registered agents.); compute (Compute safe velocities for all agents.); new (Create a solver with a minimum time horizon of 0.1 seconds.); remove_agent (Remove and return the agent at `index`, or `None` when out of bounds.)
- `StimulusType` (`enum`, `perception.rs`): Stimulus classification used by the sensor world. Details: variants: Visual, Auditory, Custom | methods: as_str (Return a display string for the stimulus type.); from_str (Parse a stimulus type name; unknown strings become `Custom`.)
- `Stimulus` (`struct`, `perception.rs`): Source stimulus stored in the world. Details: fields: id: u64, stimulus_type: StimulusType, position: (f32, intensity: f32, radius: f32, decay_rate: f32, source_name: Option<String>, tag: Option<String>
- `DetectedStimulus` (`struct`, `perception.rs`): Stimulus result returned by `Sensor::detect`. Details: fields: stimulus_id: u64, stimulus_type: StimulusType, position: (f32, intensity: f32, distance: f32, source_name: Option<String>, tag: Option<String>
- `StimulusWorld` (`struct`, `perception.rs`): Container for all stimuli available to sensors. Details: methods: add (Insert a stimulus and return its assigned id.); add_auditory (Add an auditory stimulus.); add_custom (Add a custom stimulus type.); add_visual (Add a visual stimulus.); clear (Remove all stimuli.); count (Return the number of active stimuli.); new (Create an empty stimulus world.); remove (Remove a stimulus by id and return `true` when one was removed.); stimuli (Return the active stimuli slice.); update (Decay all stimuli and drop exhausted entries.)
- `Sensor` (`struct`, `perception.rs`): Perception configuration and transient awareness state. Details: fields: sight_range: f32, sight_angle: f32, hearing_range: f32, facing: f32, awareness: f32, awareness_rise: f32, awareness_decay: f32, alert_threshold: f32, custom_ranges: HashMap<String | methods: add_custom_range (Register a detection range override for one custom stimulus label.); can_hear (Return `true` when the auditory stimulus is within the effective hearing range.); can_see (Return `true` when the target lies within sight range and the vision cone.); detect (Return every stimulus currently detected from `sensor_pos`.); is_alert (Return `true` when awareness reached the alert threshold.); new (Create a sensor with default sight, hearing, and awareness settings.); update_awareness (Raise or decay awareness based on the current number of detections.)
- `FormationType` (`enum`, `squad.rs`): Supported squad formation shapes. Details: variants: None, Line, Wedge, Circle, Column | methods: as_str (Return the canonical lowercase formation name.); parse_str (Parse a lowercase formation name; unknown strings map to `None`.)
- `Squad` (`struct`, `squad.rs`): Squad membership, formation state, and local blackboard. Details: fields: name: String, members: Vec<String>, leader: Option<String>, formation: FormationType, formation_spacing: f32, blackboard: Blackboard | methods: get_formation_position (Return the target position for one member relative to a leader position.); new (Create an empty squad with default spacing.)
- `Force` (`type`, `steering.rs`): Force vector used by steering systems.
- `SteeringEntity` (`struct`, `steering.rs`): Named entity state used by pursue, evade, and flock steering. Details: fields: name: String, position: (f32, velocity: (f32
- `CombineMode` (`enum`, `steering.rs`): How multiple steering behaviors are blended. Details: variants: Weighted, Priority | methods: as_str (Return the canonical string tag for this mode.); parse_str (Parse a string tag into `CombineMode`; unknown strings map to `Weighted`.)
- `SteeringBase` (`struct`, `steering.rs`): Shared enable/weight state for a steering behavior. Details: fields: weight: f32, enabled: bool
- `SteeringBehaviorType` (`enum`, `steering.rs`): Individual steering behavior variants. Details: variants: Seek, Flee, Arrive, Wander, Pursue, Evade, Flock, Custom | methods: base (Return the shared base state for the behavior.); base_mut (Return the mutable shared base state for the behavior.); calculate (Compute the steering force for this behavior.); kind (Return the canonical behavior kind string.)
- `SteeringManager` (`struct`, `steering.rs`): Aggregates steering behaviors and optional waypoint path following. Details: fields: behaviors: Vec<SteeringBehaviorType>, combine_mode: CombineMode, last_force: Force, cell_size: f32, use_spatial_hash: bool, path_waypoints: Vec<(f32, path_index: usize, path_reach_radius: f32, path_weight: f32, entities: HashMap<String | methods: add_arrive (Add an arrive behavior.); add_evade (Add an evade behavior.); add_flee (Add a flee behavior.); add_flock (Add a flock behavior.); add_pursue (Add a pursue behavior.); add_seek (Add a seek behavior.); add_wander (Add a wander behavior.); calculate (Combine all enabled behaviors and clamp the result to `max_force`.); clear_entities (Clear all steering-context entities.); clear_path (Clear all waypoints and reset path progress.); entity_count (Return the number of steering-context entities.); has_active_path (Return `true` when there are remaining waypoints.); last_force (Return the last computed force.); new (Create a steering manager with default parameters.); path_progress (Return `(current_index, waypoint_count)`.); remove_entity (Remove one named entity from the steering context.); set_cell_size (Set the spatial-hash cell size.); set_combine_mode_str (Set combine mode from a string tag.); set_entity (Set or replace one named entity in the steering context.); set_path (Replace the waypoint path and reset traversal state.); set_use_spatial_hash (Enable or disable spatial hashing.)
- `StrategicGoal` (`struct`, `strategy.rs`): One strategic goal considered by the planner. Details: fields: name: String, score: f32, precondition_tags: Vec<String>, enabled: bool, priority: f32 | methods: is_eligible (Return `true` when all required tags are present and the goal is enabled.); new (Create an enabled goal with default priority.); require_tag (Add a required tag.)
- `StrategyAI` (`struct`, `strategy.rs`): Periodic goal scorer that keeps the currently active goal name. Details: fields: goals: Vec<StrategicGoal>, update_interval: f32, active_tags: Vec<String>, total_evaluations: u32 | methods: active_goal (Return the name of the active goal, or `None` when nothing is selected.); add_goal (Add a goal to the evaluation set.); add_goal_named (Add a goal with the given name.); add_tag (Add a tag if it is not already present.); force_evaluate (Force immediate evaluation and reset the timer.); goal_count (Return the number of goals.); new (Create a strategy AI that evaluates every `update_interval` seconds.); remove_tag (Remove a tag if it exists.); set_tags (Replace the active tag set.); time_until_next (Return the remaining time until the next scheduled evaluation.); update (Advance the timer and evaluate goals when the update interval elapses.)
- `TraitModifier` (`struct`, `traits.rs`): Temporary additive change applied to one named trait. Details: fields: trait_name: String, delta: f32, remaining: Option<f32>, source: String | methods: is_expired (Return `true` when this modifier has reached zero remaining lifetime.); new (Create a modifier for one trait.); tick (Advance the modifier timer by `dt` seconds when it is time-limited.)
- `TraitProfile` (`struct`, `traits.rs`): Base trait values plus active temporary modifiers for one agent. Details: fields: base_values: HashMap<String, modifiers: Vec<TraitModifier>, archetype: Option<String> | methods: add_modifier (Add a temporary modifier to one trait.); archetype (Return the archetype name used to initialize this profile, when present.); from_archetype (Build a profile from a registered archetype and optional deterministic variance.); get (Return the resolved value for one trait after applying active modifiers.); get_base (Return the unclamped base value for one trait without modifiers.); has (Return `true` when the profile has a base value for the named trait.); lerp_toward (Move all shared trait values toward another profile by factor `t`.); new (Create an empty trait profile.); remove_modifiers_by_source (Remove all modifiers that originated from the given source tag.); set (Set the base value for one trait and clamp it to `[0, 1]`.); trait_count (Return the number of base traits stored in this profile.); trait_names (Return all registered trait names.); update (Advance active modifier timers and discard expired entries.)
- `TraitArchetypes` (`struct`, `traits.rs`): Registry of named trait archetypes used to initialize agent profiles. Details: methods: count (Return the number of registered archetypes.); get (Return the trait map for one named archetype.); names (Return all registered archetype names.); new (Create an empty archetype registry.); register (Register or replace one named archetype after clamping all values to `[0, 1]`.)
- `ResponseCurve` (`enum`, `utility_ai.rs`): Response-curve variant used to transform raw consideration inputs. Details: variants: Linear, Quadratic, Logistic, Logit, Step, Custom | methods: apply (Evaluate the curve at `input` using shape parameters p1, p2, p3.); parse_str (Parse a string tag into a `ResponseCurve`; unknown strings map to `Linear`.)
- `Consideration` (`struct`, `utility_ai.rs`): One consideration that transforms a raw Lua score into a weighted utility value. Details: fields: name: String, callback: RegistryKey, curve: ResponseCurve, p1: f64, p2: f64, p3: f64, weight: f64
- `UAAction` (`struct`, `utility_ai.rs`): One candidate action scored by the utility-AI system. Details: fields: name: String, scorer: RegistryKey, considerations: Vec<Consideration>, momentum_bonus: f64
- `UtilityAI` (`struct`, `utility_ai.rs`): Utility-AI runtime that stores actions and the latest evaluation results. Details: fields: actions: Vec<UAAction>, last_action: Option<usize>, last_scores: Vec<f64> | methods: add_action (Register a new action with an empty consideration list.); add_consideration (Append a consideration to the named action; no-op if the action is not found.); evaluate (Call all action scorers, apply momentum, and return the best action name.); last_action_name (Return the name of the action selected on the last `evaluate` call, or `None`.); new (Create a `UtilityAI` with no actions.)
- `AIWorld` (`struct`, `world.rs`): World-level AI registry and update surface. Details: fields: agents: Vec<Agent>, name_index: HashMap<String, global_blackboard: Blackboard | methods: add_agent (Add a named agent and return its index; returns an error on duplicate names.); agent (Return a reference to an agent by name.); agent_count (Return the number of agents in the world.); agent_mut (Return a mutable reference to an agent by name.); get_agent_index (Return the index of an agent by name.); global_blackboard (Return the shared global blackboard.); global_blackboard_mut (Return the shared global blackboard mutably.); new (Create an empty AI world.); remove_agent (Remove an agent by name and rebuild the index map.); update (Advance all agents by integrating velocity over `dt`.)

## Functions

- `DecisionModel::parse_str` (`agent.rs`): Parse a string tag into a `DecisionModel`; returns `None` for unknown tags.
- `DecisionModel::as_str` (`agent.rs`): Return the canonical string tag for this model.
- `Agent::new` (`agent.rs`): Create a new agent with default movement, AI, and support systems.
- `BTStatus::parse_str` (`behavior_tree.rs`): Parse a string tag into `BTStatus`; unknown strings default to `Running`.
- `BTStatus::as_str` (`behavior_tree.rs`): Return the canonical lowercase string tag for this status.
- `ParallelPolicy::parse_str` (`behavior_tree.rs`): Parse a string tag; unknown strings default to `RequireOne`.
- `ParallelPolicy::as_str` (`behavior_tree.rs`): Return the canonical string tag for this policy.
- `BTNode::reset` (`behavior_tree.rs`): Reset all running indices and repetition counters in this subtree recursively.
- `BTNode::child_count` (`behavior_tree.rs`): Return the number of direct children; leaf nodes return 0.
- `BehaviorTree::new` (`behavior_tree.rs`): Create an empty tree with `last_status` initialised to `Success`.
- `BehaviorTree::debug_state` (`behavior_tree.rs`): Build a `BtDebugState` snapshot from the current tree shape and status.
- `CommandQueue::new` (`command_queue.rs`): Create an empty queue.
- `CommandQueue::enqueue` (`command_queue.rs`): Append `cmd` to the back of the queue.
- `CommandQueue::push_front` (`command_queue.rs`): Insert `cmd` at the front, making it the next command to execute.
- `CommandQueue::replace` (`command_queue.rs`): Clear the entire queue and enqueue `cmd` as the sole pending command.
- `CommandQueue::cancel_current` (`command_queue.rs`): Pop the front command if it is interruptible; return `true` on success.
- `CommandQueue::clear` (`command_queue.rs`): Discard all queued commands.
- `CommandQueue::count` (`command_queue.rs`): Return the number of pending commands.
- `CommandQueue::is_empty` (`command_queue.rs`): Return `true` when the queue has no pending commands.
- `CommandQueue::current_type` (`command_queue.rs`): Return the `kind` tag of the front command, or `None` if the queue is empty.
- `CommandQueue::current_target` (`command_queue.rs`): Return the `(target_x, target_y)` of the front command; returns `(0, 0)` if empty.
- `CommandQueue::advance` (`command_queue.rs`): Remove the front command as completed and expose the next one.
- `CommandQueue::enqueue_raw` (`command_queue.rs`): Build a `Command` from raw parts and append it to the back of the queue.
- `CommandQueue::push_front_raw` (`command_queue.rs`): Build a `Command` from raw parts and insert it at the front of the queue.
- `CommandQueue::replace_raw` (`command_queue.rs`): Build a `Command` from raw parts, clear the queue, and set it as the only entry.
- `ContextSteering::new` (`context_steering.rs`): Create a context-steering sampler with at least four slots.
- `ContextSteering::slot_count` (`context_steering.rs`): Return the number of angular slots.
- `ContextSteering::add_interest` (`context_steering.rs`): Add an interest behavior.
- `ContextSteering::add_danger` (`context_steering.rs`): Add a danger behavior.
- `ContextSteering::add_seek_target` (`context_steering.rs`): Add a seek-target interest behavior.
- `ContextSteering::add_wander` (`context_steering.rs`): Add a wander interest behavior.
- `ContextSteering::add_avoid_point` (`context_steering.rs`): Add a point-avoidance danger behavior.
- `ContextSteering::add_avoid_bounds` (`context_steering.rs`): Add a world-bounds avoidance danger behavior.
- `ContextSteering::clear_behaviors` (`context_steering.rs`): Remove all registered behaviors.
- `ContextSteering::evaluate` (`context_steering.rs`): Evaluate all behaviors and return the chosen steering direction vector.
- `ContextSteering::chosen_direction` (`context_steering.rs`): Return the heading in radians chosen by the last evaluation.
- `ContextSteering::chosen_magnitude` (`context_steering.rs`): Return the magnitude chosen by the last evaluation.
- `ContextSteering::interest_map` (`context_steering.rs`): Return a copy of the last computed interest ring.
- `ContextSteering::danger_map` (`context_steering.rs`): Return a copy of the last computed danger ring.
- `DirectorPhase::as_str` (`director.rs`): Return the canonical string tag for this pacing phase.
- `AIDirector::new` (`director.rs`): Create a director with default config.
- `AIDirector::with_config` (`director.rs`): Create a director with a custom config.
- `AIDirector::tension` (`director.rs`): Return the current tension.
- `AIDirector::phase` (`director.rs`): Return the current phase.
- `AIDirector::phase_str` (`director.rs`): Return the current phase as a string tag.
- `AIDirector::elapsed` (`director.rs`): Return elapsed seconds.
- `AIDirector::total_events` (`director.rs`): Return total events received.
- `AIDirector::push_event` (`director.rs`): Add one event and clamp the resulting tension to `[0, 1]`.
- `AIDirector::update` (`director.rs`): Advance the director and update phase transitions.
- `AIDirector::spawn_rate_factor` (`director.rs`): Return the current spawn rate multiplier.
- `AIDirector::loot_factor` (`director.rs`): Return the current loot multiplier.
- `AIDirector::ambient_intensity` (`director.rs`): Return the current ambient intensity scalar.
- `AIDirector::set_tension` (`director.rs`): Set tension directly and clamp it to `[0, 1]`.
- `AIDirector::reset` (`director.rs`): Reset tension, phase, and timers to their initial state.
- `Emotion::new` (`emotion.rs`): Create a new emotion with clamped resting and visibility levels.
- `Emotion::is_active` (`emotion.rs`): Return `true` when the emotion is above the visible threshold.
- `Emotion::trigger` (`emotion.rs`): Increase the emotion value and clamp it to `[0, 1]`.
- `Emotion::set` (`emotion.rs`): Set the emotion value directly and clamp it to `[0, 1]`.
- `Emotion::update` (`emotion.rs`): Move the emotion toward its resting level over `dt` seconds.
- `EmotionModel::new` (`emotion.rs`): Create an empty emotion model.
- `EmotionModel::add` (`emotion.rs`): Add or replace an emotion by name.
- `EmotionModel::get` (`emotion.rs`): Return the current value for `name`, or 0.0 if missing.
- `EmotionModel::trigger` (`emotion.rs`): Increase the value of the named emotion when present.
- `EmotionModel::set` (`emotion.rs`): Set the value of the named emotion when present.
- `EmotionModel::update` (`emotion.rs`): Advance all emotions toward their resting levels.
- `EmotionModel::dominant` (`emotion.rs`): Return the name of the highest active emotion, or `None` when none are active.
- `EmotionModel::is_active` (`emotion.rs`): Return `true` when the named emotion exists and is active.
- `EmotionModel::active_names` (`emotion.rs`): Return the names of all active emotions.
- `EmotionModel::count` (`emotion.rs`): Return the number of tracked emotions.
- `EmotionModel::reset` (`emotion.rs`): Reset all emotions to their resting levels.
- `StateMachine::new` (`fsm.rs`): Create an empty state machine with no states or transitions.
- `StateMachine::add_transition` (`fsm.rs`): Register a transition and re-sort the transition list by descending priority.
- `StateMachine::current_state` (`fsm.rs`): Return the name of the currently active state, or `None` before the first tick.
- `StateMachine::time_in_state` (`fsm.rs`): Return elapsed seconds since the current state was entered.
- `StateMachine::add_state_raw` (`fsm.rs`): Register a state by name with optional enter, update, and exit registry keys.
- `StateMachine::add_transition_raw` (`fsm.rs`): Build a `Transition` from raw parts and add it via `add_transition`.
- `StateMachine::set_initial_state` (`fsm.rs`): Set the state name that will be activated on the first tick.
- `GOAPPlanner::new` (`goap.rs`): Create a planner with an empty action and goal lists and `max_iterations = 10 000`.
- `GOAPPlanner::plan` (`goap.rs`): Plan for the highest-priority goal; return ordered action name list or empty on failure.
- `GOAPPlanner::plan_for_goal_idx` (`goap.rs`): Plan for the goal at `goal_idx`; return ordered action name list or empty on failure.
- `GOAPPlanner::add_action` (`goap.rs`): Register a new action with an empty precondition and effect set.
- `GOAPPlanner::add_precondition` (`goap.rs`): Add a precondition entry to the named action; no-op if the action is not found.
- `GOAPPlanner::add_effect` (`goap.rs`): Add an effect entry to the named action; no-op if the action is not found.
- `GOAPPlanner::add_goal` (`goap.rs`): Register a new goal with an empty desired state map.
- `GOAPPlanner::set_goal_state` (`goap.rs`): Add a desired world-state entry to the named goal; no-op if goal is not found.
- `GOAPPlanner::get_max_iterations` (`goap.rs`): Return the current A* iteration cap.
- `GOAPPlanner::set_max_iterations` (`goap.rs`): Set the A* iteration cap to `n`.
- `HTNTask::name` (`htn.rs`): Return the task name.
- `HTNTask::is_primitive` (`htn.rs`): Return `true` for primitive tasks.
- `HTNTask::preconditions_met` (`htn.rs`): Return `true` when the task preconditions are satisfied.
- `HTNTask::apply_effects` (`htn.rs`): Apply primitive effects to the world state.
- `HTNMethod::always` (`htn.rs`): Create a method with no preconditions.
- `HTNMethod::with_preconditions` (`htn.rs`): Create a method with explicit preconditions.
- `HTNMethod::is_applicable` (`htn.rs`): Return `true` when the method preconditions are satisfied.
- `HTNDomain::new` (`htn.rs`): Create an empty domain.
- `HTNDomain::register` (`htn.rs`): Register a task by its name.
- `HTNDomain::add_primitive` (`htn.rs`): Add a primitive task.
- `HTNDomain::add_compound` (`htn.rs`): Add a compound task.
- `HTNDomain::get` (`htn.rs`): Return a task by name.
- `HTNDomain::task_count` (`htn.rs`): Return the number of tasks in the domain.
- `HTNPlanner::plan` (`htn.rs`): Plan from `root_task` and return a primitive task sequence, or `None` on failure.
- `LodTier::new` (`lod.rs`): Create a tier with the given parameters.
- `AILod::new` (`lod.rs`): Sort tiers by distance and build an `AILod`.
- `AILod::tier` (`lod.rs`): Return tier `i` if it exists.
- `AILod::tier_count` (`lod.rs`): Return the number of tiers.
- `AILod::tier_for` (`lod.rs`): Return the tier index for `agent_pos` relative to `ref_pos`.
- `AILod::assign_tiers` (`lod.rs`): Return one tier index per agent position.
- `AILod::should_update` (`lod.rs`): Return `true` when tier `tier` should update on `frame_number`.
- `MCTSEngine::new` (`mcts.rs`): Create a search engine with the provided config.
- `MCTSEngine::config` (`mcts.rs`): Return the active config.
- `MCTSEngine::search` (`mcts.rs`): Search for the best action and return its id, or `None` when no actions exist.
- `Need::new` (`needs.rs`): Create a need with value initialized to 1.0.
- `Need::is_urgent` (`needs.rs`): Return `true` when the need is enabled and below its urgency threshold.
- `Need::urgency_score` (`needs.rs`): Return a score used for prioritising needs.
- `Need::satisfy` (`needs.rs`): Increase the need value and clamp it to `[0, 1]`.
- `Need::deprive` (`needs.rs`): Decrease the need value and clamp it at 0.
- `Need::update` (`needs.rs`): Apply passive decay over `dt` seconds.
- `NeedAdvertisement::new` (`needs.rs`): Create a new advertisement at `(x, y)`.
- `NeedAdvertisement::is_available` (`needs.rs`): Return `true` when the ad is off cooldown.
- `NeedAdvertisement::use_it` (`needs.rs`): Start the cooldown timer when the ad has a positive cooldown.
- `NeedAdvertisement::update` (`needs.rs`): Advance the cooldown timer.
- `NeedAdvertisement::score` (`needs.rs`): Return a distance-weighted score for the ad.
- `NeedSystem::new` (`needs.rs`): Create an empty need system.
- `NeedSystem::add_need` (`needs.rs`): Add or replace a need by name.
- `NeedSystem::get` (`needs.rs`): Return a need by name, or `None` if missing.
- `NeedSystem::get_mut` (`needs.rs`): Return a mutable need by name, or `None` if missing.
- `NeedSystem::update` (`needs.rs`): Advance all needs by `dt` seconds.
- `NeedSystem::most_urgent` (`needs.rs`): Return the most urgent enabled need name, or `None` when none are enabled.
- `NeedSystem::satisfy` (`needs.rs`): Increase the named need when present.
- `NeedSystem::need_names` (`needs.rs`): Return all tracked need names.
- `NeedSystem::value_of` (`needs.rs`): Return the current value of the named need, or 1.0 if missing.
- `NeedSystem::best_advertisement` (`needs.rs`): Return the best-scoring available advertisement, or `None` if none score positive.
- `ORCAAgent::new` (`orca.rs`): Create a new agent at `(x, y)`.
- `ORCASolver::new` (`orca.rs`): Create a solver with a minimum time horizon of 0.1 seconds.
- `ORCASolver::add_agent` (`orca.rs`): Add an agent and return its index.
- `ORCASolver::remove_agent` (`orca.rs`): Remove and return the agent at `index`, or `None` when out of bounds.
- `ORCASolver::agent_count` (`orca.rs`): Return the number of registered agents.
- `ORCASolver::compute` (`orca.rs`): Compute safe velocities for all agents.
- `StimulusType::from_str` (`perception.rs`): Parse a stimulus type name; unknown strings become `Custom`.
- `StimulusType::as_str` (`perception.rs`): Return a display string for the stimulus type.
- `StimulusWorld::new` (`perception.rs`): Create an empty stimulus world.
- `StimulusWorld::add` (`perception.rs`): Insert a stimulus and return its assigned id.
- `StimulusWorld::add_visual` (`perception.rs`): Add a visual stimulus.
- `StimulusWorld::add_auditory` (`perception.rs`): Add an auditory stimulus.
- `StimulusWorld::add_custom` (`perception.rs`): Add a custom stimulus type.
- `StimulusWorld::remove` (`perception.rs`): Remove a stimulus by id and return `true` when one was removed.
- `StimulusWorld::update` (`perception.rs`): Decay all stimuli and drop exhausted entries.
- `StimulusWorld::stimuli` (`perception.rs`): Return the active stimuli slice.
- `StimulusWorld::count` (`perception.rs`): Return the number of active stimuli.
- `StimulusWorld::clear` (`perception.rs`): Remove all stimuli.
- `Sensor::new` (`perception.rs`): Create a sensor with default sight, hearing, and awareness settings.
- `Sensor::can_see` (`perception.rs`): Return `true` when the target lies within sight range and the vision cone.
- `Sensor::can_hear` (`perception.rs`): Return `true` when the auditory stimulus is within the effective hearing range.
- `Sensor::detect` (`perception.rs`): Return every stimulus currently detected from `sensor_pos`.
- `Sensor::update_awareness` (`perception.rs`): Raise or decay awareness based on the current number of detections.
- `Sensor::is_alert` (`perception.rs`): Return `true` when awareness reached the alert threshold.
- `Sensor::add_custom_range` (`perception.rs`): Register a detection range override for one custom stimulus label.
- `StateMachine::generate_render_commands` (`render.rs`): Build line and box commands for the FSM debug view.
- `StateMachine::draw_to_image` (`render.rs`): Draw the FSM debug view into an `ImageData` buffer.
- `BehaviorTree::generate_render_commands` (`render.rs`): Build render commands for the BT debug view.
- `BehaviorTree::draw_to_image` (`render.rs`): Draw the BT debug view into an `ImageData` buffer.
- `FormationType::parse_str` (`squad.rs`): Parse a lowercase formation name; unknown strings map to `None`.
- `FormationType::as_str` (`squad.rs`): Return the canonical lowercase formation name.
- `Squad::new` (`squad.rs`): Create an empty squad with default spacing.
- `Squad::get_formation_position` (`squad.rs`): Return the target position for one member relative to a leader position.
- `CombineMode::parse_str` (`steering.rs`): Parse a string tag into `CombineMode`; unknown strings map to `Weighted`.
- `CombineMode::as_str` (`steering.rs`): Return the canonical string tag for this mode.
- `SteeringBehaviorType::base` (`steering.rs`): Return the shared base state for the behavior.
- `SteeringBehaviorType::base_mut` (`steering.rs`): Return the mutable shared base state for the behavior.
- `SteeringBehaviorType::kind` (`steering.rs`): Return the canonical behavior kind string.
- `SteeringBehaviorType::calculate` (`steering.rs`): Compute the steering force for this behavior.
- `SteeringManager::new` (`steering.rs`): Create a steering manager with default parameters.
- `SteeringManager::calculate` (`steering.rs`): Combine all enabled behaviors and clamp the result to `max_force`.
- `SteeringManager::set_entity` (`steering.rs`): Set or replace one named entity in the steering context.
- `SteeringManager::remove_entity` (`steering.rs`): Remove one named entity from the steering context.
- `SteeringManager::clear_entities` (`steering.rs`): Clear all steering-context entities.
- `SteeringManager::entity_count` (`steering.rs`): Return the number of steering-context entities.
- `SteeringManager::add_seek` (`steering.rs`): Add a seek behavior.
- `SteeringManager::add_flee` (`steering.rs`): Add a flee behavior.
- `SteeringManager::add_arrive` (`steering.rs`): Add an arrive behavior.
- `SteeringManager::add_wander` (`steering.rs`): Add a wander behavior.
- `SteeringManager::add_pursue` (`steering.rs`): Add a pursue behavior.
- `SteeringManager::add_evade` (`steering.rs`): Add an evade behavior.
- `SteeringManager::add_flock` (`steering.rs`): Add a flock behavior.
- `SteeringManager::set_combine_mode_str` (`steering.rs`): Set combine mode from a string tag.
- `SteeringManager::last_force` (`steering.rs`): Return the last computed force.
- `SteeringManager::set_cell_size` (`steering.rs`): Set the spatial-hash cell size.
- `SteeringManager::set_use_spatial_hash` (`steering.rs`): Enable or disable spatial hashing.
- `SteeringManager::set_path` (`steering.rs`): Replace the waypoint path and reset traversal state.
- `SteeringManager::clear_path` (`steering.rs`): Clear all waypoints and reset path progress.
- `SteeringManager::has_active_path` (`steering.rs`): Return `true` when there are remaining waypoints.
- `SteeringManager::path_progress` (`steering.rs`): Return `(current_index, waypoint_count)`.
- `StrategicGoal::new` (`strategy.rs`): Create an enabled goal with default priority.
- `StrategicGoal::require_tag` (`strategy.rs`): Add a required tag.
- `StrategicGoal::is_eligible` (`strategy.rs`): Return `true` when all required tags are present and the goal is enabled.
- `StrategyAI::new` (`strategy.rs`): Create a strategy AI that evaluates every `update_interval` seconds.
- `StrategyAI::add_goal` (`strategy.rs`): Add a goal to the evaluation set.
- `StrategyAI::add_goal_named` (`strategy.rs`): Add a goal with the given name.
- `StrategyAI::set_tags` (`strategy.rs`): Replace the active tag set.
- `StrategyAI::add_tag` (`strategy.rs`): Add a tag if it is not already present.
- `StrategyAI::remove_tag` (`strategy.rs`): Remove a tag if it exists.
- `StrategyAI::active_goal` (`strategy.rs`): Return the name of the active goal, or `None` when nothing is selected.
- `StrategyAI::update` (`strategy.rs`): Advance the timer and evaluate goals when the update interval elapses.
- `StrategyAI::force_evaluate` (`strategy.rs`): Force immediate evaluation and reset the timer.
- `StrategyAI::goal_count` (`strategy.rs`): Return the number of goals.
- `StrategyAI::time_until_next` (`strategy.rs`): Return the remaining time until the next scheduled evaluation.
- `TraitModifier::new` (`traits.rs`): Create a modifier for one trait.
- `TraitModifier::is_expired` (`traits.rs`): Return `true` when this modifier has reached zero remaining lifetime.
- `TraitModifier::tick` (`traits.rs`): Advance the modifier timer by `dt` seconds when it is time-limited.
- `TraitProfile::new` (`traits.rs`): Create an empty trait profile.
- `TraitProfile::from_archetype` (`traits.rs`): Build a profile from a registered archetype and optional deterministic variance.
- `TraitProfile::set` (`traits.rs`): Set the base value for one trait and clamp it to `[0, 1]`.
- `TraitProfile::get` (`traits.rs`): Return the resolved value for one trait after applying active modifiers.
- `TraitProfile::get_base` (`traits.rs`): Return the unclamped base value for one trait without modifiers.
- `TraitProfile::add_modifier` (`traits.rs`): Add a temporary modifier to one trait.
- `TraitProfile::remove_modifiers_by_source` (`traits.rs`): Remove all modifiers that originated from the given source tag.
- `TraitProfile::update` (`traits.rs`): Advance active modifier timers and discard expired entries.
- `TraitProfile::trait_names` (`traits.rs`): Return all registered trait names.
- `TraitProfile::trait_count` (`traits.rs`): Return the number of base traits stored in this profile.
- `TraitProfile::has` (`traits.rs`): Return `true` when the profile has a base value for the named trait.
- `TraitProfile::lerp_toward` (`traits.rs`): Move all shared trait values toward another profile by factor `t`.
- `TraitProfile::archetype` (`traits.rs`): Return the archetype name used to initialize this profile, when present.
- `TraitArchetypes::new` (`traits.rs`): Create an empty archetype registry.
- `TraitArchetypes::register` (`traits.rs`): Register or replace one named archetype after clamping all values to `[0, 1]`.
- `TraitArchetypes::get` (`traits.rs`): Return the trait map for one named archetype.
- `TraitArchetypes::names` (`traits.rs`): Return all registered archetype names.
- `TraitArchetypes::count` (`traits.rs`): Return the number of registered archetypes.
- `ResponseCurve::parse_str` (`utility_ai.rs`): Parse a string tag into a `ResponseCurve`; unknown strings map to `Linear`.
- `ResponseCurve::apply` (`utility_ai.rs`): Evaluate the curve at `input` using shape parameters p1, p2, p3.
- `UtilityAI::new` (`utility_ai.rs`): Create a `UtilityAI` with no actions.
- `UtilityAI::add_action` (`utility_ai.rs`): Register a new action with an empty consideration list.
- `UtilityAI::add_consideration` (`utility_ai.rs`): Append a consideration to the named action; no-op if the action is not found.
- `UtilityAI::last_action_name` (`utility_ai.rs`): Return the name of the action selected on the last `evaluate` call, or `None`.
- `UtilityAI::evaluate` (`utility_ai.rs`): Call all action scorers, apply momentum, and return the best action name.
- `AIWorld::new` (`world.rs`): Create an empty AI world.
- `AIWorld::add_agent` (`world.rs`): Add a named agent and return its index; returns an error on duplicate names.
- `AIWorld::remove_agent` (`world.rs`): Remove an agent by name and rebuild the index map.
- `AIWorld::get_agent_index` (`world.rs`): Return the index of an agent by name.
- `AIWorld::agent` (`world.rs`): Return a reference to an agent by name.
- `AIWorld::agent_mut` (`world.rs`): Return a mutable reference to an agent by name.
- `AIWorld::agent_count` (`world.rs`): Return the number of agents in the world.
- `AIWorld::global_blackboard` (`world.rs`): Return the shared global blackboard.
- `AIWorld::global_blackboard_mut` (`world.rs`): Return the shared global blackboard mutably.
- `AIWorld::update` (`world.rs`): Advance all agents by integrating velocity over `dt`.

## Lua API Reference

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
- `LSteeringManager:clearEntities() -> nil`: Clears all steering-context entities.
- `LSteeringManager:clearPath() -> nil`: Clears the active waypoint path behavior.
- `LSteeringManager:enableSpatialHash(enabled) -> nil`: Enables or disables spatial hash acceleration for neighbor queries.
- `LSteeringManager:entityCount() -> integer`: Returns the number of steering-context entities.
- `LSteeringManager:getBehaviorCount() -> integer`: Returns the number of steering behaviors configured on this manager.
- `LSteeringManager:getCombineMode() -> string`: Returns the current steering force combination mode.
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
