# ai

## General Info

- Module group: `Feature Systems`
- Source path: `src/ai/`
- Binding: `src/lua_api/ai_api.rs`
- Namespace: `lurek.ai`
- Lua API surface: `36` functions, `24` types, `237` methods
- Rust test path(s): tests/rust/unit/ai_tests.rs, tests/rust/game/ai_tests.rs
- Lua test path(s): tests/lua/unit/test_ai.lua, tests/lua/golden/test_ai_golden.lua, tests/lua/integration/test_ecs_ai.lua, tests/lua/integration/test_ai_physics.lua, tests/lua/integration/test_ai_pathfind.lua, tests/lua/integration/test_ai_ecs_scene.lua, tests/lua/stress/test_ai_stress.lua

## Summary

The AI module provides a rich array of decision-making, planning, spatial navigation, and learning tools for Lurek2D agents. At its foundation, it manages isolated virtual worlds with shared global and agent-specific blackboards, enabling actors to record and query typed local facts. Sensory input is processed through a persistent multi-channel perception system that tracks visual and auditory stimuli in the environment, simulating attention fade and sensory reliability based on range.

For agent locomotion, the module separates high-level choices from micro-navigation and steering mechanics. Planners output abstract targets, which are fed into steering managers that synthesize continuous movement forces like seeking, fleeing, arriving, wandering, pursuing, and evading. This is enhanced by local collision avoidance algorithms such as reciprocal velocity obstacle solvers and slot-based angular context steering to ensure safe, natural path navigation.

Multi-agent tactical scenarios are organized using dedicated group structures and spatial mapping utilities. Squad managers synchronize several agents around a leader, calculating precise formation offsets and sharing tactical context. In parallel, grid-based influence maps allow the AI to represent spatial data as decaying, blended layers, propagating threat or reward values to detect tactical hotspots, safe pathways, and optimal spawn locations across the game world.

To support complex reasoning horizons, the module implements multiple high-level deliberative planners. Goal-Oriented Action Planning allows agents to search symbolic action-effect state spaces to assemble plans under frame budgets. For structured behaviors, Hierarchical Task Networks recursively decompose abstract goals into primitive actions under constraints. For branching spaces, a Monte Carlo Tree Search engine evaluates action preference through simulated trials.

Intermediate action dispatching and execution rhythms are coordinated by a suite of reactive controllers. Composed behavior trees manage complex task structures with sequenced, parallel, or decorated control nodes, preserving action status across frames. Simple state transitions are handled by finite state machines tracking dwell time, while command queues buffer executable actions with callback-backed completion hooks and immediate reactive overrides.

Agents exhibit unique characters using trait, emotion, and internal need models. Drive-based need systems decay and recover normalized internal pressures like hunger to produce situational motivations. These motivations are shaped by trait profiles containing personality dimensions and active modifiers, which feed into utility AI systems that arbitrate actions using non-linear consideration curves. Decaying emotion values further color final decision weightings.

Beyond hand-authored algorithms, the module houses learning capabilities, including neural networks, genetic algorithms, and reinforcement learning machines. Scripts can create Q-learners for experience-based action scoring, multi-armed bandits with selectable exploration strategies, and feed-forward neural nets. These nets can evolve over generations using neuroevolution systems, letting agents adapt, optimize behavioral strategies, and learn live during game sessions.

Global encounters and performance scaling are managed through drama and resource directors. An AI director models game tension as a cyclic decay waveform, adjusting pacing factors like spawn rates and loot multipliers to match player stress. To ensure stable frame rates in populated games, level-of-detail selectors scale computation by mapping distance-based update tiers, throttling distant actors while keeping near interactions highly responsive.

Finally, the module provides specialized game systems like dialogue AIs for weighted conversational branching, alongside diagnostic renderers that translate live AI decision trees, finite-state configurations, and steering forces into spatial debug visual overlays. This complete array of capabilities makes the AI module the primary cognitive engine where individual perceptions, personality dynamics, spatial navigation, and structural choices unify.

## Files

### [agent.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/agent.rs)

- Defines the full runtime shape of one AI actor as a single cohesive control unit.
- Blends identity, movement, tactical priority, and decision style into one state heartbeat.
- Keeps planner-facing memory, sensing, affect, motives, traits, and squad semantics aligned.
- Preserves stable cross-system handoff so world updates read one consistent behavioral snapshot.
- Serves as the anchor object that orchestration layers drive without leaking subsystem coupling.

### [behavior_tree.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/behavior_tree.rs)

- Implements a behavior orchestration lattice that evaluates intent through composable control flow.
- Carries running status across ticks so long actions keep temporal continuity instead of restarting.
- Balances branching policies to prefer resilient progress under mixed success and failure outcomes.
- Threads guard logic and decorator shaping into each decision pulse without breaking determinism.
- Emits inspectable execution state that tools can render as readable runtime decision rhythm.
- Provides a stable bridge for Lua-driven leaves while preserving engine-owned traversal guarantees.

### [command_queue.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/command_queue.rs)

- Provides a staged action stream that turns chosen intent into executable command cadence.
- Maintains ordering, urgency, and interruption semantics so control pressure stays predictable.
- Couples command payloads with completion hooks to close the loop between plan and outcome.
- Offers controlled dequeue flow that supports reactive overrides without timeline fragmentation.
- Serves as the pacing buffer between high-level deliberation and low-level execution dispatch.

### [context_steering.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/context_steering.rs)

- Implements slot-based directional reasoning that scores where motion should be pulled or resisted.
- Projects multiple influences into angular context so local movement stays responsive and legible.
- Mixes attraction, avoidance, drift, and boundary pressure as one continuous heading composition.
- Resolves conflict by weighing directional appetite against threat, then extracting the safest momentum lane.
- Preserves smooth steering continuity by keeping representation compact and frame-friendly.
- Outputs a movement-ready vector that downstream motion systems can apply with minimal translation.
- Acts as a tactical micro-navigation layer beneath planners and above raw kinematic integration.

### [director.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/director.rs)

- Models encounter tempo as a cyclic pressure waveform that alternates escalation and release.
- Converts accumulated tension into phase shifts that shape danger, reward, and ambient load.
- Keeps pacing legible by using bounded transitions instead of abrupt binary difficulty jumps.
- Exposes intensity signals that other systems can follow to stay synchronized with scenario mood.
- Preserves long-session flow by balancing peaks against recovery windows in deterministic cadence.
- Functions as the global dramaturgy spine for AI pressure management during runtime.

### [emotion.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/emotion.rs)

- Tracks affective channels as bounded signals that rise on events and relax toward personal baselines.
- Translates short-term emotional pressure into a clean modulation stream for decision weighting.
- Preserves stability with clamped values and predictable decay so mood changes remain interpretable.
- Resolves dominant feeling state as a compact summary other AI layers can consume cheaply.
- Supplies a lightweight emotional color layer without locking behavior to one planner architecture.

### [fsm.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/fsm.rs)

- Provides explicit mode-based control where behavior advances through named states over time.
- Evaluates guarded transitions in deterministic priority order to keep switching reproducible.
- Coordinates lifecycle callbacks around entry, steady update, and exit handoff boundaries.
- Tracks dwell time to support time-aware logic without external bookkeeping overhead.
- Serves agents that need clear phase changes rather than fully continuous utility arbitration.

### [goap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/goap.rs)

- Delivers deliberative planning over symbolic world facts, actionable effects, and prioritized intentions.
- Searches plan space with bounded best-first expansion to stay tractable under live-frame budgets.
- Reconstructs coherent action chains from explored nodes into executable intent trajectories.
- Balances optimality pressure against hard iteration ceilings so runtime cost remains predictable.
- Integrates Lua-side execution hooks while preserving engine-owned planning invariants.
- Acts as the intentional reasoning core for long-horizon task choice and sequencing.

### [htn.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/htn.rs)

- Provides hierarchical task decomposition that transforms abstract goals into executable primitive flow.
- Expands authored methods through recursive branching while honoring world-state numeric constraints.
- Preserves plan structure and intent traceability across each decomposition depth step.
- Limits expansion depth to protect runtime from runaway combinatorial growth.
- Supports domain-authored behavioral style where sequencing logic is explicit and inspectable.
- Serves as a long-horizon planning backbone for structured narrative or tactical routines.

### [lod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/lod.rs)

- Defines distance-tiered AI update policy so compute effort follows player-relevant proximity.
- Assigns cadence bands that throttle far entities while keeping near interactions immediate.
- Stabilizes frame budget by converting spatial spread into predictable scheduling pressure.
- Provides a compact scalability dial for large-population scenes with bounded responsiveness loss.

### [mcts.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/mcts.rs)

- Implements Monte Carlo Tree Search as a reusable decision kernel for branching action spaces.
- Executes the full selection, expansion, rollout, and backpropagation rhythm under fixed budgets.
- Uses exploration pressure to balance known strong branches against uncertain alternatives.
- Stores tree state in compact node arenas for iterative simulation throughput.
- Returns action preference grounded in sampled outcomes rather than handcrafted deterministic rules.
- Supports game-specific state, transition, and scoring logic through generic integration hooks.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/mod.rs)

- Groups the full AI runtime surface into one coherent module boundary for decision and control.
- Exposes complementary layers for actor state, sensing, planning, steering, coordination, and tooling.
- Keeps integration predictable by publishing shared types through a single composition entry point.
- Aligns tactical and strategic subsystems under consistent data flow and update expectations.
- Defines the high-level contract of engine-side intelligence capabilities available to the rest of runtime.

### [needs.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/needs.rs)

- Models internal drives as normalized pressures that decay, recover, and compete for attention.
- Converts need intensity into urgency signals that higher decision layers can compare directly.
- Scores available satisfiers against context so fulfillment choice remains situational and explainable.
- Maintains cooldown-aware motivation flow to avoid oscillation between equivalent opportunities.
- Supplies a behavioral hunger layer that gives planners a dynamic reason to act.

### [orca.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/orca.rs)

- Implements local collision avoidance by projecting preferred motion into safe velocity space.
- Builds pairwise movement constraints that encode short-horizon separation commitments between agents.
- Resolves feasible velocity choices while preserving as much intent direction as safety allows.
- Keeps radius and speed bounds explicit so output remains physically plausible for runtime integration.
- Serves as the crowd-scale micro-avoidance layer under higher-level navigation goals.

### [perception.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/perception.rs)

- Implements sensory intake as a multi-channel stream of world cues with persistent awareness state.
- Captures visual, auditory, and custom signals in a unified format suitable for agent reasoning.
- Applies range and confidence dynamics so perception strength evolves instead of flipping abruptly.
- Maintains temporal awareness memory that can fade, refresh, or intensify based on new evidence.
- Separates sensing configuration from stimulus flow to keep tuning independent from event production.
- Bridges raw world events into decision-ready perceptual context consumed by planning layers.
- Acts as the attentional gate that determines what information reaches behavior systems and when.

### [render.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/render.rs)

- Provides debug-visualization translation from live AI state into drawable diagnostic artifacts.
- Turns control-graph structure into spatial layouts that remain readable during runtime inspection.
- Encodes execution status into visual signals so behavior flow can be understood at a glance.
- Supports both command-stream overlays and image snapshots for tooling and reporting paths.
- Keeps rendering concerns decoupled from decision logic while preserving faithful state representation.
- Acts as the observability lens for active finite-state and tree-based decision dynamics.

### [squad.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/squad.rs)

- Defines group-level coordination state that binds members around shared intent and leadership.
- Maintains formation semantics as geometric offsets that stay coherent during leader motion.
- Carries shared tactical context so squad behavior can react as one unit instead of isolated actors.
- Produces placement guidance for synchronized movement patterns across common formation styles.
- Serves as the structural layer for multi-agent cohesion above individual steering behaviors.

### [steering.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/steering.rs)

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

### [strategy.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/strategy.rs)

- Implements high-level intent arbitration that ranks strategic goals against current world context.
- Blends static priority and dynamic scoring pressure into a single comparable decision signal.
- Evaluates on a controlled cadence to avoid noisy goal thrashing between adjacent frames.
- Retains active intent continuity so tactical layers receive stable direction over time.
- Serves as the top strategic filter above lower-level planners and executors.

### [traits.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/traits.rs)

- Defines long-lived personality dimensions that shape how agents weight and express decisions.
- Combines base profile values with temporary modifiers to model evolving behavioral flavor.
- Updates modifier lifecycles over time so transient influences fade in a controlled manner.
- Supports archetypal presets and deterministic variation for reproducible character differentiation.
- Supplies stable temperament context consumed by planners, scorers, and tactical selectors.

### [utility_ai.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/utility_ai.rs)

- Implements continuous utility-based action choice through layered consideration scoring pipelines.
- Shapes raw inputs with configurable response curves to express nonlinear decision preference.
- Blends historical momentum with fresh evidence so action selection avoids abrupt instability.
- Captures per-action score snapshots each tick for introspection and downstream decision context.
- Serves agents that benefit from smooth preference arbitration instead of hard state jumps.

### [world.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/ai/world.rs)

- Provides the global AI registry that owns agents, lookup indices, and shared world context.
- Keeps identity-to-storage mapping synchronized so retrieval remains stable across lifecycle changes.
- Centralizes broad update progression to advance many actors through one coherent world pulse.
- Serves as the integration hub where individual agent logic becomes population-level simulation flow.
