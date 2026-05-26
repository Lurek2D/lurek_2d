# dialog

> Dialog and conversation system with weighted topic/branch selection, state tracking, and speaker management.

## Purpose

Provides a flexible dialog tree engine for interactive conversations. Supports
weighted topic/branch selection with gate conditions (FSM state, behavior tree
status, utility scores), conversation state tracking with visited history and
variables, and a speaker registry for character metadata.

Extracted from `src/ai/dialogue.rs` and expanded into a full dialog subsystem.

## Architecture

- **Tier:** Feature Systems
- **Dependencies:** none (standalone logic module)
- **Dependents:** game scripts via `lurek.dialog`, `library/dialog/` (UI frontend)
- **Related:** ai module (backward-compat re-exports `DialogueAI`, `DialogueBranch`, `DialogueTopic`)

## Files

| File | Purpose |
|------|---------|
| `mod.rs` | Module exports and public API surface |
| `tree.rs` | `DialogueAI`, `DialogueTopic`, `DialogueBranch`, `DialogueNode` — decision tree and selector |
| `condition.rs` | `DialogueCondition`, `GateContext` — gate/condition evaluation system |
| `state.rs` | `DialogueState` — conversation progress tracking (current node, visited, variables) |
| `speaker.rs` | `Speaker`, `SpeakerRegistry` — speaker/character metadata registry |
| `events.rs` | `DialogueEvent` — events emitted during dialog progression |

## Public Types

| Type | Description |
|------|-------------|
| `DialogueAI` | Topic and branch selector with gate checks and utility scoring |
| `DialogueTopic` | Top-level dialogue topic with branches and selection gates |
| `DialogueBranch` | Single branch inside a topic with weight and gates |
| `DialogueNode` | A node in a dialogue tree (text, speaker, children, condition) |
| `DialogueCondition` | Condition enum guarding branch availability |
| `GateContext` | Context provided to condition evaluation |
| `DialogueState` | Tracks conversation progress (current node, visited, variables) |
| `Speaker` | Information about a dialog speaker/character |
| `SpeakerRegistry` | Registry of all known speakers |
| `DialogueEvent` | Events emitted by the dialog system |

## Lua API (`lurek.dialog`)

| Function | Returns | Description |
|----------|---------|-------------|
| `lurek.dialog.newAI()` | `LDialogueAI` | Create an empty dialogue selector |
| `lurek.dialog.newState()` | `LDialogueState` | Create a new conversation state tracker |
| `lurek.dialog.newSpeakerRegistry()` | `LSpeakerRegistry` | Create an empty speaker registry |

### LDialogueAI Methods

| Method | Description |
|--------|-------------|
| `setFSMState(state?)` | Set FSM state context for selection |
| `setBTStatus(status?)` | Set behavior tree status context |
| `setUtilityScore(key, score)` | Store a utility score |
| `clearUtilityScores()` | Remove all utility scores |
| `addTopic(id, weight?, fsm?, bt?, util_key?)` | Add a selectable topic |
| `addBranch(topic_id, branch_id, weight?, fsm?, bt?, util_key?)` | Add a branch to a topic |
| `selectTopic()` | Select the best valid topic |
| `selectBranch(topic_id)` | Select the best valid branch |
| `getTopicCount()` | Return number of topics |

### LDialogueState Methods

| Method | Description |
|--------|-------------|
| `start(node_id)` | Start conversation at node |
| `advance(node_id)` | Advance to a new node |
| `end_()` | End the conversation |
| `current()` | Get current node ID |
| `hasVisited(node_id)` | Check if node was visited |
| `visitCount()` | Number of visited nodes |
| `isActive()` | Whether conversation is active |
| `setVariable(key, value)` | Set a conversation variable |
| `getVariable(key)` | Get a conversation variable |
| `reset()` | Reset all state |

### LSpeakerRegistry Methods

| Method | Description |
|--------|-------------|
| `add(id, name, portrait?, voice_id?)` | Register a speaker |
| `get(id)` | Get speaker info table |
| `remove(id)` | Remove a speaker |
| `count()` | Number of speakers |
| `contains(id)` | Check if speaker exists |

## Backward Compatibility

`lurek.ai.newDialogueAI()` still works and creates the same `LDialogueAI` handle.
The `src/ai/` module re-exports `DialogueAI`, `DialogueBranch`, and `DialogueTopic`
from `crate::dialog` for existing Rust code that imports from `crate::ai`.
