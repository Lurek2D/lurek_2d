<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/dialog.md or source docstrings instead. -->

# dialog

## TL;DR

- Orchestrates branching narrative graphs using conditional gates.
- Provides typewriter-style dialog sequencer for node-based playback with choices.

## General Info

- Module group: `Feature Systems`
- Source path: `src/dialog`
- Binding: `src/lua_api/dialog_api.rs`
- Namespace: `lurek.dialog`
- Lua API surface: `12` functions, `5` types, `73` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

- The `dialog` module is the conversation-runtime surface for users building branching narrative, tutorial flows, reactive chatter, or choice-driven exchanges.
- Dialogue trees, speaker metadata, conditional gates, weighted branching, callbacks, waits, and jumps work together so conversations can be authored as explicit progression instead of scattered local state checks.
- Sequencing is a core part of the value: reveal timing, advancement, and event hooks let dialogue participate in pacing, scripting, and gameplay rather than acting as a static text lookup table.
- Variable-aware flow and state tracking make it practical to mix authored story beats with runtime-driven responses, which is important for larger RPG, strategy, and simulation interfaces.
- That same explicit flow is useful for branch testing and replay.
- It also helps keep dialogue progression inspectable in larger projects.
- The module therefore fits narrative scenes, tutorials, reactive barks, negotiation flows, and tool-driven branch inspection wherever text progression should remain a first-class runtime structure.
- Read `dialog` as the owner of conversation structure and progression.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Ownership

- Canonical source: `src/dialog`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/dialog_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

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

### story.rs

- Safe Ink-subset story compiler and runtime for `lurek.dialog.compileStory`.

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
- `lurek.dialog.compileStory(source, opts?) -> LDialogStory`: Compiles a safe Ink-subset story source into an `LDialogStory`.
- `lurek.dialog.event(name, data?, opts?) -> table`: Creates an Event node (fires a named callback).
- `lurek.dialog.jump(target, opts?) -> table`: Creates a Jump node (branches to a labeled position).
- `lurek.dialog.label(name) -> table`: Creates a Label node used as a jump target marker.
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
- `LDialogSequencer:clearHistory() -> nil`: Clears accumulated spoken-line history.
- `LDialogSequencer:currentId() -> string`: Returns the authored id of the current line, or nil when unset.
- `LDialogSequencer:currentRoute() -> string`: Returns the current line route marker, or nil when unset.
- `LDialogSequencer:currentSpeaker() -> string`: Returns the actor name for the current line, or nil.
- `LDialogSequencer:currentTags() -> table`: Returns the current line tag array.
- `LDialogSequencer:currentText() -> string`: Returns the full text of the current line.
- `LDialogSequencer:currentVoice() -> string`: Returns the current line voice id, or nil when unset.
- `LDialogSequencer:getChoiceLabels() -> table`: Returns an array of choice option labels.
- `LDialogSequencer:getChoiceText() -> string`: Returns the choice prompt text, or nil if not in a choice node.
- `LDialogSequencer:getHistory() -> table`: Returns spoken-line history in insertion order.
- `LDialogSequencer:getSpeed() -> number`: Gets the current typewriter speed in characters per second.
- `LDialogSequencer:getState() -> string`: Returns the current playback state as a string.
- `LDialogSequencer:isActive() -> boolean`: Checks if the sequencer is currently playing.
- `LDialogSequencer:isWaitingForChoice() -> boolean`: Checks if the sequencer is waiting for a choice selection.
- `LDialogSequencer:load(nodes) -> nil`: Loads a sequence of dialog nodes for playback.
- `LDialogSequencer:peekSignal() -> table`: Returns the next pending event/call signal without removing it.
- `LDialogSequencer:popSignal() -> table`: Removes and returns the next pending event/call signal.
- `LDialogSequencer:restore(snapshot) -> nil`: Restores sequencer runtime state from a prior snapshot table.
- `LDialogSequencer:revealedText() -> string`: Returns only the typewriter-revealed portion of the current line.
- `LDialogSequencer:setSpeed(cps) -> nil`: Sets the typewriter reveal speed in characters per second.
- `LDialogSequencer:skip() -> nil`: Instantly reveals the full current line without typewriter effect.
- `LDialogSequencer:snapshot() -> table`: Captures sequencer runtime state, including nodes, progress, history, and pending signals.
- `LDialogSequencer:start() -> nil`: Starts playback from the beginning of the loaded sequence.
- `LDialogSequencer:type() -> string`: Returns the Lua-visible type name.
- `LDialogSequencer:typeOf(name) -> boolean`: Returns whether this handle matches a supported type name.
- `LDialogSequencer:update(dt) -> nil`: Advances the sequencer by dt seconds, updating typewriter reveal.

#### LDialogStory Type

- Lua handle for a compiled safe Ink-subset story.

##### Fields

- No documented fields.

##### Methods

- `LDialogStory:canContinue() -> nil`: Returns whether the story can emit another line.
- `LDialogStory:choose(index) -> nil`: Selects an available story choice by one-based choice index.
- `LDialogStory:continue() -> nil`: Emits the next story line and tag array, or nil at choice/end.
- `LDialogStory:continueAll(sep?) -> nil`: Drains story lines until a choice or end and joins them.
- `LDialogStory:getChoices() -> nil`: Returns available choices as `{text, available, tags, index}` rows.
- `LDialogStory:getVariable(name) -> nil`: Returns one story variable value, or nil when the story variable is not currently defined.
- `LDialogStory:gotoKnot(name) -> nil`: Jumps immediately to a named story knot and resets the story position to that knot start.
- `LDialogStory:listVariables() -> nil`: Lists story variable names.
- `LDialogStory:restore(snapshot) -> nil`: Restores a snapshot returned by `snapshot`.
- `LDialogStory:setVariable(name, value) -> nil`: Sets or replaces one story variable using a nil, boolean, number, or string value.
- `LDialogStory:snapshot() -> nil`: Returns a serializable story runtime snapshot.
- `LDialogStory:start(knot?) -> nil`: Starts the story at a named knot or at START/ENTRY/first knot.
- `LDialogStory:type() -> nil`: Returns the Lua userdata type name for compiled dialog story handles.
- `LDialogStory:typeOf(name) -> nil`: Returns true for `LDialogStory` and shared `LObject` runtime type checks.
- `LDialogStory:visitCount(name) -> nil`: Returns how many times a knot has been entered.

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

## Examples

- `content/examples/dialog.lua` (present)

## Architecture Links

- Intentionally empty.

## Notes

- No additional module-specific notes.
