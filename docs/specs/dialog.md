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

- The `dialog` module is the conversation-runtime surface for users building branching narrative, tutorial flows, reactive chatter, or choice-driven UI exchanges.
- Dialogue trees, speaker metadata, conditional gates, weighted branching, callbacks, waits, and jumps work together so conversations can be authored as structured progression rather than scattered state checks.
- Sequencing features matter because the module does not stop at static text lookup: reveal timing, advancement, and event hooks let dialogue participate in pacing and game logic.
- State tracking and variable-aware flow make it practical to blend authored story content with system-driven responses, which is important for larger RPG, strategy, or simulation interfaces.
- This makes the module useful not only for narrative scenes but also for tutorials, reactive barks, negotiation flows, and any interaction where controlled text progression should react to runtime state.
- It also helps narrative and systems code meet cleanly, because authored dialogue can wait on runtime conditions without collapsing into custom state-machine glue.
- Read this module as the owner of conversation structure and progression. UI renders the words, but `dialog` decides how dialogue choices, conditions, and narrative state fit together.


## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### condition.rs

- `src/dialog/condition.rs` defines reusable gate rules that decide whether a dialog branch is currently eligible.
- It owns `GateContext` and `DialogueCondition`, including FSM, BT-status, utility-threshold, and composite checks.
- Condition evaluation lives here so authored gating rules stay data-driven and detached from tree traversal mechanics.
- Read it when branch availability rules, context fields, or condition semantics for dialog progression need changes.

### events.rs

- `src/dialog/events.rs` defines the event vocabulary emitted by the dialog system during conversation progress.
- It owns lifecycle and selection payloads for start, advance, topic choice, branch choice, ending, and variable writes.
- Read it when dialog event names, payload shapes, or script-facing milestone contracts need to change.

### mod.rs

- `src/dialog/mod.rs` is the module index for dialogue gating, events, speakers, runtime state, sequencers, and trees.
- It declares the files that own branch conditions, event vocabulary, speaker data, playback state, and selection logic.
- This file reexports the dialog-facing types so callers can assemble conversations without importing deep internal paths.
- No live conversation state or authored graph data lives here; it only defines visibility and subsystem boundaries.
- Read this index first when tracing dialog behavior, because it shows where gating, playback, and authored data split.
- Changes here affect module reachability and API shape, not sequencing rules, branch scoring, or runtime progression.

### sequencer.rs

- `src/dialog/sequencer.rs` plays authored dialog nodes as a runtime sequence with typewriter reveal and choices.
- It owns `DialogNode`, `SequencerState`, and `DialogSequencer`, including labels, jumps, waits, calls, and events.
- Current line text, reveal progress, active choice prompt, option labels, and label lookup tables are stored here.
- Node advancement, skip behavior, speed control, and choice selection live here so playback policy stays centralized.
- Wait, event, call, label, and jump nodes are interpreted here so scripted playback rules remain local to the sequencer.
- This file is the runtime playback boundary for authored dialog scripts; it does not score topics or manage speakers.
- Read it when reveal timing, node execution flow, choice UX state, or jump semantics for dialog playback change.

### speaker.rs

- `src/dialog/speaker.rs` owns canonical speaker records and the registry used to resolve who is speaking.
- It stores speaker identity, display name, portrait path, voice id, and tags in one stable lookup boundary.
- Conversation content depends on this file for character metadata, while sequencing and branching stay in sibling files.
- Read it when speaker lookup, metadata fields, or registry ownership for dialog characters needs to change.

### state.rs

- `src/dialog/state.rs` owns the mutable runtime snapshot for an active conversation and its visited progression history.
- It stores the current node, visited ids, per-run variables, and active flag as the authoritative dialog state record.
- Start, advance, end, reset, and variable mutation helpers live here so dialog progression state stays centralized.
- Read it when conversation persistence, visit tracking, or runtime variable handling for dialog sessions needs changes.

### tree.rs

- `src/dialog/tree.rs` owns the authored dialogue graph and the scoring logic that selects topics and branches.
- It defines topics, branches, and nodes while storing FSM state, BT status, and utility scores for gate-aware choice.
- Topic and branch ranking happen here so authored weights and runtime utility inputs produce one deterministic selector.
- This file is the planning layer for dialog content; it does not own typewriter playback or visited-state persistence.
- Gate checks and utility accumulation stay here so narrative selection remains close to the authored records it uses.
- Read it when branch scoring, topic selection, authored graph fields, or gating inputs for dialog AI need changes.



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

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
