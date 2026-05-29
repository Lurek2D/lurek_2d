# dialog

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/dialog/`
- Lua API path(s): `src/lua_api/dialog_api.rs`
- Primary Lua namespace: `lurek.dialog`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `dialog` module provides branching conversation runtime primitives built around dialog trees, guarded branching conditions, speaker metadata, and emitted dialog events. It supports both simple linear flows and richer weighted branch/topic selection based on runtime gate context.

Module responsibilities are explicit: `tree` models nodes and branch selection, `condition` evaluates gating predicates against supplied context, `state` tracks active conversation progression, `speaker` stores participant metadata, and `events` emits structured signals for external scripting or UI reactions.

The architecture keeps dialogue logic data-driven and testable. Selection policy and gate checks are represented as explicit model types rather than hardcoded branching paths scattered in scripts.

In feature-system terms, `dialog` should remain focused on conversation evaluation and progression contracts. Presentation, animation timing, and game-specific narrative policy should consume this runtime surface rather than live inside it.

## Files

### condition.rs

- Provides reusable gate predicates that decide whether dialog branches and topics are currently eligible.
- Encodes state checks and numeric-threshold checks in declarative data so selection logic stays data-driven.
- Combines predicates with all/any semantics to support layered narrative gating from runtime context.

### events.rs

- Provides the event payloads emitted by the dialog runtime while a conversation is advancing.
- Carries progression and selection signals so UI and script layers can react without inspecting engine internals.
- Keeps integration boundaries explicit by representing conversation lifecycle changes as typed records.

### mod.rs

- Provides the runtime conversation stack for branching dialogue, speaker metadata, and progression state.
- Combines gate-aware topic and branch selection with lightweight context signals for adaptive narrative flow.
- Exposes a clean integration surface where scripts consume events while core logic remains in typed dialog data.

### speaker.rs

- Provides character identity records used by dialogue nodes to resolve display and voice context.
- Centralizes participant lookup in a registry keyed by stable speaker identifiers across a session.
- Keeps conversation content decoupled from presentation assets by storing metadata separately from tree flow.

### state.rs

- Provides mutable conversation state that tracks active position, visit history, and per-run variables.
- Supports lifecycle transitions for starting, advancing, ending, and resetting dialogue progression.
- Preserves narrative continuity data in a compact structure that runtime systems can read each tick.

### tree.rs

- Provides the core dialogue graph data used to model selectable topics, branches, and authored node content.
- Applies contextual filtering so only candidates compatible with current runtime state remain eligible.
- Scores eligible options with base weights and optional utility signals to choose the strongest narrative path.
- Keeps selection deterministic and inspectable by storing gating and scoring inputs directly in dialog records.
- Serves as the central planning layer that higher-level dialogue state and scripting flows execute over time.

## Lua API Ref

- Binding: `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`

### Functions

- `lurek.dialog.newAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.dialog.newSpeakerRegistry`: Creates an empty speaker registry for dialog participants.
- `lurek.dialog.newState`: Creates an empty dialogue state for tracking conversation progress.

### Enums

- No documented module-level enums/constants.

### Types


#### LDialogueAI Type


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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
