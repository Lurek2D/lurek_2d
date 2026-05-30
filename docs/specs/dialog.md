# dialog

## TL;DR

- The `dialog` module provides branching conversation runtime primitives with topic selection, branch gating, speaker metadata, and state progression.


## General Info

- Module group: `Edge/Integration`
- Source path: `src/dialog/`
- Binding: `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`
- Lua API surface: `3` functions, `3` types, `30` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `dialog` module is the runtime backbone for conversation flow. It lets projects define topics, branches, and progression state in a structured form, so dialogue behavior stays predictable during gameplay.

Its main value is controlled branching. Options can be gated by context rules, weighted for selection, and advanced through explicit transitions. This avoids fragile ad-hoc branching spread across many scripts.

Speaker metadata and dialogue events are part of the same runtime surface. That makes UI and tools easier to integrate, because they can react to conversation changes through stable module contracts.

The module stays focused on dialogue logic, not presentation policy. Games can layer custom pacing and visual style on top, while `lurek.dialog` provides consistent choice, gate, and progression behavior underneath.

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

- `lurek.dialog.newAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.dialog.newSpeakerRegistry`: Creates an empty speaker registry for dialog participants.
- `lurek.dialog.newState`: Creates an empty dialogue state for tracking conversation progress.

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

- `LDialogueAI:addBranch`: Adds a selectable branch under an existing dialogue topic.
- `LDialogueAI:addTopic`: Adds a selectable dialogue topic with optional context filters.
- `LDialogueAI:clearUtilityScores`: Removes every stored utility score from this dialogue selector.
- `LDialogueAI:getTopicCount`: Returns the number of topics registered in this dialogue selector.
- `LDialogueAI:selectBranch`: Selects the best currently valid branch for the given topic.
- `LDialogueAI:selectTopic`: Selects the best currently valid topic using weights and context filters.
- `LDialogueAI:setBTStatus`: Sets the behavior-tree status used as dialogue selection context.
- `LDialogueAI:setFSMState`: Sets the finite-state-machine state used as dialogue selection context.
- `LDialogueAI:setUtilityScore`: Stores a utility score used by topics and branches that reference the given key.
- `LDialogueAI:type`: Returns the Lua-visible type name for this dialogue AI handle.
- `LDialogueAI:typeOf`: Returns whether this dialogue AI handle matches a supported type name.

#### LDialogueState Type

- Lua handle for dialog conversation state tracking.

##### Fields

- No documented fields.

##### Methods

- `LDialogueState:advance`: Advances to a new node in the conversation.
- `LDialogueState:current`: Returns the ID of the currently active dialogue node or nil.
- `LDialogueState:end_`: End the active conversation and release its state data.
- `LDialogueState:getVariable`: Gets a conversation variable by key.
- `LDialogueState:hasVisited`: Check whether a given conversation node has been visited.
- `LDialogueState:isActive`: Returns whether the conversation is currently active.
- `LDialogueState:reset`: Reset all conversation progress, history, and visited flags.
- `LDialogueState:setVariable`: Sets a conversation variable for this object.
- `LDialogueState:start`: Starts a conversation at the given node.
- `LDialogueState:type`: Returns the Lua-visible type name.
- `LDialogueState:typeOf`: Returns whether this handle matches a supported type name.
- `LDialogueState:visitCount`: Returns the number of visited nodes.

#### LSpeakerRegistry Type

- Lua userdata handle for managing a named speaker registry.

##### Fields

- No documented fields.

##### Methods

- `LSpeakerRegistry:add`: Registers a speaker in the registry.
- `LSpeakerRegistry:contains`: Checks if a speaker exists in the registry.
- `LSpeakerRegistry:count`: Returns the number of registered speakers.
- `LSpeakerRegistry:get`: Gets a speaker by ID as a table with id, name, portrait, voice_id fields.
- `LSpeakerRegistry:remove`: Removes a speaker by ID for this object.
- `LSpeakerRegistry:type`: Returns the Lua-visible type name.
- `LSpeakerRegistry:typeOf`: Returns whether this handle matches a supported type name.
