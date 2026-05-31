# dialog

## TL;DR

- Orchestrates branching narrative graphs using conditional gates.

## General Info

- Module group: `Edge/Integration`
- Source path: `src/dialog/`
- Binding: `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`
- Lua API surface: `3` functions, `3` types, `30` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

This module provides the narrative scripting and conversation logic system, allowing gameplay scripts to choreograph complex dialogues. It handles multi-character conversation graphs, player choices, and conditional narrative gates. Conversations are built as dialogue trees where branches are evaluated and ranked dynamically using utility scoring, ensuring the engine can select contextually appropriate dialogue paths.

To keep dialogue flows organized, the system separates narrative structure from presentation. It features a dedicated speaker registry that maps character IDs to display names, portraits, and audio properties. Additionally, a persistent state tracker maintains the history of visited nodes, active conversation nodes, and custom variable stores. This decouples visual layouts from script logic while ensuring progression stays coherent.

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

- `lurek.dialog.newAI() -> LDialogueAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.dialog.newSpeakerRegistry() -> LSpeakerRegistry`: Creates an empty speaker registry for dialog participants.
- `lurek.dialog.newState() -> LDialogueState`: Creates an empty dialogue state for tracking conversation progress.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

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
