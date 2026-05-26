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

Provides a flexible dialog tree engine for interactive conversations. Supports
weighted topic/branch selection with gate conditions (FSM state, behavior tree
status, utility scores), conversation state tracking with visited history and
variables, and a speaker registry for character metadata.

Extracted from `src/ai/dialogue.rs` and expanded into a full dialog subsystem.

## Source Documentation

### `condition.rs`
- Dialog gate conditions: guards that control branch and topic visibility.
- `Condition` is an enum with variants for flag checks, stat comparisons, and Lua callbacks.
- Evaluated lazily at the point where the dialog engine requests the next node.
- Lua callback conditions receive the current `DialogState` as a table argument.
- Composed with `And` / `Or` / `Not` wrappers for complex gating logic.

### `events.rs`
- Events emitted by the dialog tree engine during conversation playback.
- `DialogEvent` variants: `NodeEntered`, `ChoiceMade`, `Finished`, `Interrupted`.
- Pushed into the engine's event queue; consumed by game scripts each tick.
- `NodeEntered` carries the node ID and speaker ID for UI presentation.
- Cleared at the start of each tick after the Lua callback has processed them.

### `mod.rs`
- Dialog and conversation system.
- Provides a flexible dialog tree engine with:
- Weighted topic/branch selection with gate conditions
- FSM and behavior tree state context for conditional branching
- Utility-score-based topic prioritization
- Speaker registry for character metadata
- Event emission for script integration
- The module powers both simple linear dialogs and complex branching
- conversations with dynamic topic selection.

### `speaker.rs`
- Speaker registry and character metadata used across dialog trees.
- `Speaker` holds a display name, portrait asset path, and voice bank key.
- The global `SpeakerRegistry` maps speaker IDs to `Speaker` values.
- Speakers are registered from TOML at load time or dynamically via `lurek.dialog`.
- Speaker IDs are stable string slugs (e.g. `"npc_merchant"`) not numeric indices.

### `state.rs`
- Dialog FSM state: tracks the current node, visited history, and variable bindings.
- `DialogState` is the mutable context passed through the dialog engine each tick.
- Tracks the current node ID, conversation ID, and per-run variable map.
- `visited` set prevents re-entering nodes marked as non-repeatable.
- Serialisable via `Save` system for checkpoint-save mid-conversation support.

### `tree.rs`
- Dialogue tree types: topics, branches, and the AI selector.
- Dialogue selection choosing topics and branches from weighted sets guarded by FSM and BT state.
- Topic and branch records with optional gate keys and utility-score references.
- Scoring and matching logic filtering by gates, folding utility, and returning best candidates.
- Independent gating against FSM state and behavior-tree status for adaptive selection.
- Base weight combined with optional utility scores for flexible priority ranking.

## Types

- `GateContext` (`struct`, `condition.rs`): Context provided to gate evaluation.
- `DialogueCondition` (`enum`, `condition.rs`): A condition that guards whether a dialog branch is available.
- `DialogueEvent` (`enum`, `events.rs`): Events emitted by the dialog system for script integration.
- `Speaker` (`struct`, `speaker.rs`): Information about a dialog speaker/character.
- `SpeakerRegistry` (`struct`, `speaker.rs`): Registry of all known speakers in a dialog system.
- `DialogueState` (`struct`, `state.rs`): Tracks the current state of an active dialog conversation.
- `DialogueBranch` (`struct`, `tree.rs`): Single branch inside a topic.
- `DialogueTopic` (`struct`, `tree.rs`): Top-level dialogue topic with an ordered set of branches.
- `DialogueNode` (`struct`, `tree.rs`): A node in a dialogue tree that can represent a line of text, a choice point, or a scripted action.
- `DialogueAI` (`struct`, `tree.rs`): Topic and branch selector with gate checks and utility scoring.

## Functions

- `DialogueCondition::evaluate` (`condition.rs`): Evaluate this condition against the provided context.
- `Speaker::new` (`speaker.rs`): Create a new speaker with the given id and display name.
- `SpeakerRegistry::new` (`speaker.rs`): Create an empty speaker registry.
- `SpeakerRegistry::add` (`speaker.rs`): Register a speaker in the registry.
- `SpeakerRegistry::get` (`speaker.rs`): Get a registered speaker by its ID.
- `SpeakerRegistry::remove` (`speaker.rs`): Remove and return a speaker by its ID.
- `SpeakerRegistry::count` (`speaker.rs`): Number of registered speakers.
- `SpeakerRegistry::contains` (`speaker.rs`): Check if a speaker ID exists in the registry.
- `SpeakerRegistry::ids` (`speaker.rs`): Get all registered speaker ID strings.
- `DialogueState::new` (`state.rs`): Create a new inactive dialogue state.
- `DialogueState::start` (`state.rs`): Start a conversation at the given node.
- `DialogueState::advance` (`state.rs`): Advance the conversation to a new dialog node.
- `DialogueState::end` (`state.rs`): End the active conversation and clear current node.
- `DialogueState::current` (`state.rs`): Get the current active dialog node ID.
- `DialogueState::has_visited` (`state.rs`): Check if a node has been visited.
- `DialogueState::visit_count` (`state.rs`): Get the number of visited nodes.
- `DialogueState::is_active` (`state.rs`): Whether conversation is active.
- `DialogueState::set_variable` (`state.rs`): Set a conversation variable.
- `DialogueState::get_variable` (`state.rs`): Get a conversation variable.
- `DialogueState::reset` (`state.rs`): Reset all conversation state and variables.
- `DialogueNode::new` (`tree.rs`): Create a new dialogue node with the given id and text.
- `DialogueAI::new` (`tree.rs`): Create an empty dialogue selector.
- `DialogueAI::set_fsm_state` (`tree.rs`): Set the FSM state gate used by topic and branch selection.
- `DialogueAI::set_bt_status` (`tree.rs`): Set the behavior-tree status gate used by topic and branch selection.
- `DialogueAI::set_utility_score` (`tree.rs`): Store a utility score under `key`.
- `DialogueAI::clear_utility_scores` (`tree.rs`): Remove all cached utility scores.
- `DialogueAI::add_topic` (`tree.rs`): Add a topic with optional gate requirements and utility key.
- `DialogueAI::add_branch` (`tree.rs`): Add a branch to the named topic; returns `false` if the topic is missing.
- `DialogueAI::select_topic` (`tree.rs`): Return the best matching topic id, or `None` when no topic matches.
- `DialogueAI::select_branch` (`tree.rs`): Return the best matching branch id for `topic_id`, or `None` when none matches.
- `DialogueAI::topic_count` (`tree.rs`): Return the number of registered topics.

## Lua API Reference

- Binding path(s): `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`

### Module Functions
- `lurek.dialog.newAI`: Creates an empty dialogue selector for weighted topics and branches.
- `lurek.dialog.newState`: Creates an empty dialogue state for tracking conversation progress.
- `lurek.dialog.newSpeakerRegistry`: Creates an empty speaker registry for dialog participants.

### `LDialogueAI` Methods
- `LDialogueAI:setFSMState`: Sets the finite-state-machine state used as dialogue selection context.
- `LDialogueAI:setBTStatus`: Sets the behavior-tree status used as dialogue selection context.
- `LDialogueAI:setUtilityScore`: Stores a utility score used by topics and branches that reference the given key.
- `LDialogueAI:clearUtilityScores`: Removes every stored utility score from this dialogue selector.
- `LDialogueAI:addTopic`: Adds a selectable dialogue topic with optional context filters.
- `LDialogueAI:addBranch`: Adds a selectable branch under an existing dialogue topic.
- `LDialogueAI:selectTopic`: Selects the best currently valid topic using weights and context filters.
- `LDialogueAI:selectBranch`: Selects the best currently valid branch for the given topic.
- `LDialogueAI:getTopicCount`: Returns the number of topics registered in this dialogue selector.
- `LDialogueAI:type`: Returns the Lua-visible type name for this dialogue AI handle.
- `LDialogueAI:typeOf`: Returns whether this dialogue AI handle matches a supported type name.

### `LDialogueState` Methods
- `LDialogueState:start`: Starts a conversation at the given node.
- `LDialogueState:advance`: Advances to a new node in the conversation.
- `LDialogueState:end_`: End the active conversation and release its state data.
- `LDialogueState:current`: Returns the ID of the currently active dialogue node or nil.
- `LDialogueState:hasVisited`: Check whether a given conversation node has been visited.
- `LDialogueState:visitCount`: Returns the number of visited nodes.
- `LDialogueState:isActive`: Returns whether the conversation is currently active.
- `LDialogueState:setVariable`: Sets a conversation variable for this object.
- `LDialogueState:getVariable`: Gets a conversation variable by key.
- `LDialogueState:reset`: Reset all conversation progress, history, and visited flags.
- `LDialogueState:type`: Returns the Lua-visible type name.
- `LDialogueState:typeOf`: Returns whether this handle matches a supported type name.

### `LSpeakerRegistry` Methods
- `LSpeakerRegistry:add`: Registers a speaker in the registry.
- `LSpeakerRegistry:get`: Gets a speaker by ID as a table with id, name, portrait, voice_id fields.
- `LSpeakerRegistry:remove`: Removes a speaker by ID for this object.
- `LSpeakerRegistry:count`: Returns the number of registered speakers.
- `LSpeakerRegistry:contains`: Checks if a speaker exists in the registry.
- `LSpeakerRegistry:type`: Returns the Lua-visible type name.
- `LSpeakerRegistry:typeOf`: Returns whether this handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/dialog/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
