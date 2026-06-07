# dialog

## TL;DR

- Orchestrates branching narrative graphs using conditional gates.
- Provides typewriter-style dialog sequencer for node-based playback with choices.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/dialog/`
- Binding: `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`
- Lua API surface: `10` functions, `4` types, `48` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): tests/lua/unit/test_dialog_sequencer_unit.lua

## Summary

This module provides the narrative scripting and conversation logic system, allowing gameplay scripts to choreograph complex dialogues. It handles multi-character conversation graphs, player choices, and conditional narrative gates. Conversations are built as dialogue trees where branches are evaluated and ranked dynamically using utility scoring, ensuring the engine can select contextually appropriate dialogue paths.

To keep dialogue flows organized, the system separates narrative structure from presentation. It features a dedicated speaker registry that maps character IDs to display names, portraits, and audio properties. Additionally, a persistent state tracker maintains the history of visited nodes, active conversation nodes, and custom variable stores. This decouples visual layouts from script logic while ensuring progression stays coherent.

The dialog sequencer adds a presentation layer on top of the tree system, enabling typewriter-style text reveal, choice selection, branching nodes, and playback control. Scripts can load node sequences, control reveal speed, advance through lines, and handle player choices through a unified interface.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### condition.rs

- Provides reusable gate rules that decide whether dialog options are eligible under the current runtime context.
- Encodes state and threshold checks as portable data so narrative gating stays configurable and data-first.
- Supports composable all-or-any logic for layered progression constraints across branching conversations.
- Delivers a deterministic condition engine that keeps availability checks consistent between systems and scripts.

### events.rs

- Defines the dialogue event vocabulary used to publish lifecycle milestones and selection outcomes.
- Carries typed payloads so UI, scripting, and telemetry can react without digging into internal state.
- Delivers a clean event contract that keeps conversation flow observable across integration points.

### mod.rs

- Provides the high-level dialog module surface that unifies authored conversation flow with runtime progression state.
- Connects speaker identity, gating logic, selection models, and lifecycle events into one coherent interaction layer.
- Delivers a stable module boundary that scripts and systems consume as the canonical dialogue orchestration entry point.

### sequencer.rs

- Cinematic dialog sequencer with typewriter reveal effect.
- Provides node-based dialog playback with:
- Typewriter character-by-character reveal
- Choice branching with option selection
- Lifecycle callbacks (line, choice, end, custom events)
- Playback state tracking and control (play, pause, seek, skip)

### speaker.rs

- Provides canonical speaker identity records used by dialogue flow to resolve who is talking at each step.
- Centralizes speaker lookup in a stable registry keyed by durable identifiers shared across a session.
- Keeps narrative content decoupled from presentation metadata like portraits, voices, and character tags.
- Delivers a single reference layer that makes speaker data consistent for tree logic and runtime state.

### state.rs

- Provides mutable dialogue runtime state that tracks active position, visit history, and per-run variables.
- Supports conversation lifecycle transitions for start, advance, end, and subsequent re-entry handling.
- Preserves continuity data in a compact snapshot that dependent systems can query every frame.
- Delivers the authoritative progression record used to keep branching dialogue behavior coherent over time.

### tree.rs

- Provides the core dialogue graph model for authored topics, branches, nodes, and selectable progression paths.
- Applies runtime gate filtering so only context-compatible narrative candidates remain available.
- Combines base weights with utility-driven influence to rank candidates and pick strong conversation outcomes.
- Keeps decision flow transparent by storing gating and scoring inputs directly with authored records.
- Serves as the planning backbone executed by dialogue state, scripting hooks, and event publication.
- Delivers data-first branching behavior that stays testable, tunable, and stable across gameplay sessions.

## Lua API Ref

### Functions

- `lurek.dialog.call(fn_name, opts?) -> table`: Creates a Call node (invokes a Lua function by name).
- `lurek.dialog.choice(prompt, options, opts?) -> table`: Creates a Choice node with selectable options.
- `lurek.dialog.event(name, data?, opts?) -> table`: Creates an Event node (fires a named callback).
- `lurek.dialog.jump(target, opts?) -> table`: Creates a Jump node (branches to a labeled position).
- `lurek.dialog.newAI() -> LDialogueAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.dialog.newSequencer() -> LDialogSequencer`: Creates an empty dialog sequencer for typewriter-style playback.
- `lurek.dialog.newSpeakerRegistry() -> LSpeakerRegistry`: Creates an empty speaker registry for dialog participants.
- `lurek.dialog.newState() -> LDialogueState`: Creates an empty dialogue state for tracking conversation progress.
- `lurek.dialog.say(actor, text, opts?) -> table`: Creates a Say node for character dialog.
- `lurek.dialog.wait(seconds, opts?) -> table`: Creates a Wait node (delay before continuing).

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LDialogSequencer Type

- Lua handle for a dialog sequencer with typewriter-reveal playback.

##### Fields

- No documented fields.

##### Methods

- `LDialogSequencer:advance() -> nil`: Skips to the next node (or instantly reveals current line if typing).
- `LDialogSequencer:choose(index) -> nil`: Selects a choice option when waiting for choice input.
- `LDialogSequencer:currentSpeaker() -> string`: Returns the actor name for the current line, or nil.
- `LDialogSequencer:currentText() -> string`: Returns the full text of the current line.
- `LDialogSequencer:getChoiceLabels() -> table`: Returns an array of choice option labels.
- `LDialogSequencer:getChoiceText() -> string`: Returns the choice prompt text, or nil if not in a choice node.
- `LDialogSequencer:getSpeed() -> number`: Gets the current typewriter speed in characters per second.
- `LDialogSequencer:getState() -> string`: Returns the current playback state as a string.
- `LDialogSequencer:isActive() -> boolean`: Checks if the sequencer is currently playing.
- `LDialogSequencer:isWaitingForChoice() -> boolean`: Checks if the sequencer is waiting for a choice selection.
- `LDialogSequencer:load(nodes) -> nil`: Loads a sequence of dialog nodes for playback.
- `LDialogSequencer:revealedText() -> string`: Returns only the typewriter-revealed portion of the current line.
- `LDialogSequencer:setSpeed(cps) -> nil`: Sets the typewriter reveal speed in characters per second.
- `LDialogSequencer:skip() -> nil`: Instantly reveals the full current line without typewriter effect.
- `LDialogSequencer:start() -> nil`: Starts playback from the beginning of the loaded sequence.
- `LDialogSequencer:type() -> string`: Returns the Lua-visible type name.
- `LDialogSequencer:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LDialogSequencer:update(dt) -> nil`: Advances the sequencer by dt seconds, updating typewriter reveal.

#### LDialogueAI Type

- Lua handle for topic and branch selection driven by dialogue AI state.

##### Fields

- No documented fields.

##### Methods

- `LDialogueAI:addBranch(topic_id, branch_id, weight?, fsm_state?, bt_status?, utility_key?) -> boolean`: Adds a selectable branch under an existing dialogue topic.
- `LDialogueAI:addTopic(id, weight?, fsm_state?, bt_status?, utility_key?) -> nil`: Adds a selectable dialogue topic with optional context filters.
- `LDialogueAI:clearUtilityScores() -> nil`: Removes every stored utility score from this dialogue selector.
- `LDialogueAI:getTopicCount() -> integer`: Returns the number of topics registered in this dialogue selector.
- `LDialogueAI:selectBranch(topic_id) -> string`: Selects the best currently valid branch for the given topic.
- `LDialogueAI:selectTopic() -> string`: Selects the best currently valid topic using weights and context filters.
- `LDialogueAI:setBTStatus(status?) -> nil`: Sets the behavior-tree status used as dialogue selection context.
- `LDialogueAI:setFSMState(state?) -> nil`: Sets the finite-state-machine state used as dialogue selection context.
- `LDialogueAI:setUtilityScore(key, score) -> nil`: Stores a utility score used by topics and branches that reference the given key.
- `LDialogueAI:type() -> string`: Returns the Lua-visible type name for this dialogue AI handle.
- `LDialogueAI:typeOf(name) -> boolean`: Returns whether this dialogue AI handle matches a supported type name.

#### LDialogueState Type

- Lua handle for dialog conversation state tracking.

##### Fields

- No documented fields.

##### Methods

- `LDialogueState:advance(node_id) -> nil`: Advances to a new node in the conversation.
- `LDialogueState:current() -> string`: Returns the ID of the currently active dialogue node or nil.
- `LDialogueState:end_() -> nil`: End the active conversation and release its state data.
- `LDialogueState:getVariable(key) -> string`: Gets a conversation variable by key.
- `LDialogueState:hasVisited(node_id) -> boolean`: Check whether a given conversation node has been visited.
- `LDialogueState:isActive() -> boolean`: Returns whether the conversation is currently active.
- `LDialogueState:reset() -> nil`: Reset all conversation progress, history, and visited flags.
- `LDialogueState:setVariable(key, value) -> nil`: Sets a conversation variable for this object.
- `LDialogueState:start(node_id) -> nil`: Starts a conversation at the given node.
- `LDialogueState:type() -> string`: Returns the Lua-visible type name.
- `LDialogueState:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LDialogueState:visitCount() -> integer`: Returns the number of visited nodes.

#### LSpeakerRegistry Type

- Lua userdata handle for managing a named speaker registry.

##### Fields

- No documented fields.

##### Methods

- `LSpeakerRegistry:add(id, name, portrait?, voice_id?) -> nil`: Registers a speaker in the registry.
- `LSpeakerRegistry:contains(id) -> boolean`: Checks if a speaker exists in the registry.
- `LSpeakerRegistry:count() -> integer`: Returns the number of registered speakers.
- `LSpeakerRegistry:get(id) -> table`: Gets a speaker by ID as a table with id, name, portrait, voice_id fields.
- `LSpeakerRegistry:remove(id) -> boolean`: Removes a speaker by ID for this object.
- `LSpeakerRegistry:type() -> string`: Returns the Lua-visible type name.
- `LSpeakerRegistry:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
