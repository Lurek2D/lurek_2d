# Dialog

## Summary

- This module gives users a structured dialogue runtime for branching conversations and narrative progression.
- Dialogue trees support conditional gates, weighted branch selection, and context-sensitive topic choice.
- Speaker registries decouple character metadata from authored dialogue content.
- State tracking preserves visited nodes, active position, and runtime variables across interactions.
- Sequencer support enables typewriter reveal, line advance, and choice-based branching playback.
- Event hooks allow scripts to react to narrative milestones and user selections.
- Utility-style branch scoring supports dynamic conversational behavior.
- Callback nodes support embedding scripted side effects within dialogue flow.
- Jump and wait nodes allow cinematic pacing and control-flow shaping.
- The module is useful for RPG conversations, tutorials, and story-driven UI interactions.
- For users, it centralizes narrative logic instead of scattering dialogue state across scripts.
- It supports both authored story content and reactive systems-driven chatter.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.dialog.call`

Creates a Call node (invokes a Lua function by name).

```lua
lurek.dialog.call(fn_name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn_name` | string | Lua function name to call. |
| `opts?` | table | Optional table (reserved for future use). |

**Returns**

| Type | Description |
|------|-------------|
| table | Call node table for sequencer.load(). |

**Example**

```lua
do
    local node = lurek.dialog.call("on_quest_accepted")
    print("lurek.dialog.call type=" .. node.type)
    print("name=" .. node.name)
end
```

---

### `lurek.dialog.choice`

Creates a Choice node with selectable options.

```lua
lurek.dialog.choice(prompt, options, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | Choice prompt text. |
| `options` | table | Array of option strings. |
| `opts?` | table | Optional table (reserved for future use). |

**Returns**

| Type | Description |
|------|-------------|
| table | Choice node table for sequencer.load(). |

**Example**

```lua
do
    local node = lurek.dialog.choice("What do you do?", {"Fight", "Flee", "Talk"})
    print("lurek.dialog.choice type=" .. node.type)
    print("prompt=" .. node.prompt)
    print("options=" .. #node.options)
end
```

---

### `lurek.dialog.event`

Creates an Event node (fires a named callback).

```lua
lurek.dialog.event(name, data, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Event name. |
| `data?` | string | Optional event payload. |
| `opts?` | table | Optional table (reserved for future use). |

**Returns**

| Type | Description |
|------|-------------|
| table | Event node table for sequencer.load(). |

**Example**

```lua
do
    local node = lurek.dialog.event("combat_end", "victory")
    print("lurek.dialog.event type=" .. node.type)
    print("name=" .. node.name)
    print("data=" .. tostring(node.data))
end
```

---

### `lurek.dialog.jump`

Creates a Jump node (branches to a labeled position).

```lua
lurek.dialog.jump(target, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `target` | string | Label name to jump to. |
| `opts?` | table | Optional table (reserved for future use). |

**Returns**

| Type | Description |
|------|-------------|
| table | Jump node table for sequencer.load(). |

**Example**

```lua
do
    local node = lurek.dialog.jump("ending_good")
    print("lurek.dialog.jump type=" .. node.type)
    print("target=" .. node.target)
end
```

---

### `lurek.dialog.newAI`

Creates an empty dialogue selector for weighted topics and branches.

```lua
lurek.dialog.newAI()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDialogueAI](#ldialogueai) | New dialogue AI handle. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    print("lurek.dialog.newAI type=" .. ai:type())
    print("topics=" .. ai:getTopicCount())
end
```

---

### `lurek.dialog.newSequencer`

Creates an empty dialog sequencer for typewriter-style playback.

```lua
lurek.dialog.newSequencer()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDialogSequencer](#ldialogsequencer) | New sequencer handle. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    print("lurek.dialog.newSequencer type=" .. seq:type())
    print("state=" .. seq:getState())
end
```

---

### `lurek.dialog.newSpeakerRegistry`

Creates an empty speaker registry for dialog participants.

```lua
lurek.dialog.newSpeakerRegistry()
```

**Returns**

| Type | Description |
|------|-------------|
| [LSpeakerRegistry](#lspeakerregistry) | New speaker registry handle. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guide", "Guide", "portraits/guide.png", "npc.guide")
    print("lurek.dialog.newSpeakerRegistry type=" .. sr:type())
    print("count=" .. sr:count())
end
```

---

### `lurek.dialog.newState`

Creates an empty dialogue state for tracking conversation progress.

```lua
lurek.dialog.newState()
```

**Returns**

| Type | Description |
|------|-------------|
| [LDialogueState](#ldialoguestate) | New dialogue state handle. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("lurek.dialog.newState type=" .. ds:type())
    print("active=" .. tostring(ds:isActive()))
end
```

---

### `lurek.dialog.say`

Creates a Say node for character dialog.

```lua
lurek.dialog.say(actor, text, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `actor` | string | Character name. |
| `text` | string | Dialog text. |
| `opts?` | table | Optional table with duration field. |

**Returns**

| Type | Description |
|------|-------------|
| table | Say node table for sequencer.load(). |

**Example**

```lua
do
    local node = lurek.dialog.say("Hero", "I'm ready!")
    print("lurek.dialog.say type=" .. node.type)
    print("actor=" .. node.actor)
    print("text=" .. node.text)
end
```

---

### `lurek.dialog.wait`

Creates a Wait node (delay before continuing).

```lua
lurek.dialog.wait(seconds, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | number | Seconds to wait. |
| `opts?` | table | Optional table (reserved for future use). |

**Returns**

| Type | Description |
|------|-------------|
| table | Wait node table for sequencer.load(). |

**Example**

```lua
do
    local node = lurek.dialog.wait(3.0)
    print("lurek.dialog.wait type=" .. node.type)
    print("seconds=" .. node.seconds)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LDialogSequencer](#ldialogsequencer)
- [LDialogueAI](#ldialogueai)
- [LDialogueState](#ldialoguestate)
- [LSpeakerRegistry](#lspeakerregistry)

## LDialogSequencer

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDialogSequencer:advance`

Skips to the next node (or instantly reveals current line if typing).

```lua
LDialogSequencer:advance()
```

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({
        lurek.dialog.say("NPC", "Line one"),
        lurek.dialog.say("NPC", "Line two")
    })
    seq:start()
    seq:advance()
    seq:advance()
    print("LDialogSequencer:advance text=" .. seq:currentText())
end
```

---

#### `LDialogSequencer:choose`

Selects a choice option when waiting for choice input.

```lua
LDialogSequencer:choose(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | Option index (1-based) to select. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({
        lurek.dialog.choice("Pick one:", {"A", "B", "C"}),
        lurek.dialog.say("NPC", "You picked!")
    })
    seq:start()
    seq:choose(2)
    print("LDialogSequencer:choose state=" .. seq:getState())
end
```

---

#### `LDialogSequencer:currentSpeaker`

Returns the actor name for the current line, or nil.

```lua
LDialogSequencer:currentSpeaker()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Actor name, or nil. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("Warrior", "At last!") })
    seq:start()
    print("LDialogSequencer:currentSpeaker=" .. tostring(seq:currentSpeaker()))
end
```

---

#### `LDialogSequencer:currentText`

Returns the full text of the current line.

```lua
LDialogSequencer:currentText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Full line text. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "The full line here") })
    seq:start()
    print("LDialogSequencer:currentText=" .. seq:currentText())
end
```

---

#### `LDialogSequencer:getChoiceLabels`

Returns an array of choice option labels.

```lua
LDialogSequencer:getChoiceLabels()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of choice strings. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Pick:", {"Option A", "Option B", "Option C"}) })
    seq:start()
    local labels = seq:getChoiceLabels()
    print("LDialogSequencer:getChoiceLabels count=" .. #labels)
    print("first=" .. labels[1])
end
```

---

#### `LDialogSequencer:getChoiceText`

Returns the choice prompt text, or nil if not in a choice node.

```lua
LDialogSequencer:getChoiceText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Choice prompt, or nil. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Your move?", {"Attack", "Defend"}) })
    seq:start()
    print("LDialogSequencer:getChoiceText=" .. tostring(seq:getChoiceText()))
end
```

---

#### `LDialogSequencer:getSpeed`

Gets the current typewriter speed in characters per second.

```lua
LDialogSequencer:getSpeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Characters per second. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(25.0)
    print("LDialogSequencer:getSpeed=" .. seq:getSpeed())
end
```

---

#### `LDialogSequencer:getState`

Returns the current playback state as a string.

```lua
LDialogSequencer:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of: "idle", "typing", "waiting", "choice", "done". |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "Text") })
    seq:start()
    print("LDialogSequencer:getState=" .. seq:getState())
end
```

---

#### `LDialogSequencer:isActive`

Checks if the sequencer is currently playing.

```lua
LDialogSequencer:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when not idle or done. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    print("idle active=" .. tostring(seq:isActive()))
    seq:load({ lurek.dialog.say("NPC", "Started") })
    seq:start()
    print("started active=" .. tostring(seq:isActive()))
end
```

---

#### `LDialogSequencer:isWaitingForChoice`

Checks if the sequencer is waiting for a choice selection.

```lua
LDialogSequencer:isWaitingForChoice()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when waiting for player choice. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Pick:", {"Yes", "No"}) })
    seq:start()
    print("LDialogSequencer:isWaitingForChoice=" .. tostring(seq:isWaitingForChoice()))
end
```

---

#### `LDialogSequencer:load`

Loads a sequence of dialog nodes for playback.

```lua
LDialogSequencer:load(nodes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `nodes` | table | Array of node tables created via lurek.dialog.say(), choice(), etc. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    local nodes = {
        lurek.dialog.say("NPC", "Hello there!"),
        lurek.dialog.choice("How are you?", {"Good", "Bad"})
    }
    seq:load(nodes)
    print("LDialogSequencer:load ok")
end
```

---

#### `LDialogSequencer:revealedText`

Returns only the typewriter-revealed portion of the current line.

```lua
LDialogSequencer:revealedText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Revealed text. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(5.0)
    seq:load({ lurek.dialog.say("NPC", "Slowly revealed") })
    seq:start()
    seq:update(0.2)
    print("LDialogSequencer:revealedText=" .. seq:revealedText())
end
```

---

#### `LDialogSequencer:setSpeed`

Sets the typewriter reveal speed in characters per second.

```lua
LDialogSequencer:setSpeed(cps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cps` | number | Characters per second. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(50.0)
    print("LDialogSequencer:setSpeed speed=" .. seq:getSpeed())
end
```

---

#### `LDialogSequencer:skip`

Instantly reveals the full current line without typewriter effect.

```lua
LDialogSequencer:skip()
```

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({ lurek.dialog.say("NPC", "Instant reveal") })
    seq:start()
    seq:skip()
    print("LDialogSequencer:skip revealed=" .. seq:revealedText())
end
```

---

#### `LDialogSequencer:start`

Starts playback from the beginning of the loaded sequence.

```lua
LDialogSequencer:start()
```

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "Beginning...") })
    seq:start()
    print("LDialogSequencer:start state=" .. seq:getState())
end
```

---

#### `LDialogSequencer:type`

Returns the Lua-visible type name.

```lua
LDialogSequencer:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDialogSequencer](#ldialogsequencer)`. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    print("LDialogSequencer:type=" .. seq:type())
end
```

---

#### `LDialogSequencer:typeOf`

Returns whether this handle matches a supported type name.

```lua
LDialogSequencer:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the type name matches. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    print("LDialogSequencer:typeOf LDialogSequencer=" .. tostring(seq:typeOf("LDialogSequencer")))
end
```

---

#### `LDialogSequencer:update`

Advances the sequencer by dt seconds, updating typewriter reveal.

```lua
LDialogSequencer:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0)
    seq:load({ lurek.dialog.say("NPC", "Hello") })
    seq:start()
    seq:update(0.15)
    print("LDialogSequencer:update revealed=" .. seq:revealedText())
end
```

---

## LDialogueAI

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDialogueAI:addBranch`

Adds a selectable branch under an existing dialogue topic.

```lua
LDialogueAI:addBranch(topic_id, branch_id, weight, fsm_state, bt_status, utility_key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `topic_id` | string | Topic identifier that receives the branch. |
| `branch_id` | string | Unique branch identifier within the topic. |
| `weight?` | number | Base branch weight; defaults to 1.0. |
| `fsm_state?` | string | Optional FSM state required for this branch. |
| `bt_status?` | string | Optional behavior tree status required for this branch. |
| `utility_key?` | string | Optional utility score key multiplied into selection. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the branch was added to an existing topic. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    local added = ai:addBranch("greeting", "hello_once", 2.0, "idle")
    print("LDialogueAI:addBranch ok=" .. tostring(added))
end
```

---

#### `LDialogueAI:addTopic`

Adds a selectable dialogue topic with optional context filters.

```lua
LDialogueAI:addTopic(id, weight, fsm_state, bt_status, utility_key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Unique topic identifier. |
| `weight?` | number | Base selection weight; defaults to 1.0. |
| `fsm_state?` | string | Optional FSM state required for this topic. |
| `bt_status?` | string | Optional behavior tree status required for this topic. |
| `utility_key?` | string | Optional utility score key multiplied into selection. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5, "idle")
    print("LDialogueAI:addTopic count=" .. ai:getTopicCount())
end
```

---

#### `LDialogueAI:clearUtilityScores`

Removes every stored utility score from this dialogue selector.

```lua
LDialogueAI:clearUtilityScores()
```

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 1.0, nil, nil, "weather_score")
    ai:setUtilityScore("weather_score", 0.9)
    ai:clearUtilityScores()
    print("LDialogueAI:clearUtilityScores ok")
    print("selected=" .. tostring(ai:selectTopic()))
end
```

---

#### `LDialogueAI:getTopicCount`

Returns the number of topics registered in this dialogue selector.

```lua
LDialogueAI:getTopicCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current topic count. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5)
    ai:addTopic("quest", 0.8)
    print("LDialogueAI:getTopicCount=" .. ai:getTopicCount())
end
```

---

#### `LDialogueAI:selectBranch`

Selects the best currently valid branch for the given topic.

```lua
LDialogueAI:selectBranch(topic_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `topic_id` | string | Topic identifier whose branches should be considered. |

**Returns**

| Type | Description |
|------|-------------|
| string | Selected branch identifier, or nil when no branch is available. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("friendly", 1.0, "idle")
    ai:addBranch("friendly", "weather_smalltalk", 1.0, "idle")
    ai:addBranch("friendly", "quest_prompt", 0.5, "idle")
    ai:setFSMState("idle")
    local branch = ai:selectBranch("friendly")
    print("LDialogueAI:selectBranch=" .. tostring(branch))
end
```

---

#### `LDialogueAI:selectTopic`

Selects the best currently valid topic using weights and context filters.

```lua
LDialogueAI:selectTopic()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Selected topic identifier, or nil when no topic is available. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("rumors", 0.7)
    ai:addTopic("trade", 1.0, nil, nil, "trade_score")
    ai:setUtilityScore("trade_score", 1.5)
    local topic = ai:selectTopic()
    print("LDialogueAI:selectTopic=" .. tostring(topic))
end
```

---

#### `LDialogueAI:setBTStatus`

Sets the behavior-tree status used as dialogue selection context.

```lua
LDialogueAI:setBTStatus(status)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `status?` | string | Current behavior tree status, or nil to clear the status context. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("combat_bark", 1.0, nil, "running")
    ai:setBTStatus("running")
    print("LDialogueAI:setBTStatus ok")
    print("selected=" .. tostring(ai:selectTopic()))
end
```

---

#### `LDialogueAI:setFSMState`

Sets the finite-state-machine state used as dialogue selection context.

```lua
LDialogueAI:setFSMState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state?` | string | Current FSM state name, or nil to clear the FSM context. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("shop", 1.0, "shop")
    ai:setFSMState("shop")
    print("LDialogueAI:setFSMState ok")
    print("selected=" .. tostring(ai:selectTopic()))
end
```

---

#### `LDialogueAI:setUtilityScore`

Stores a utility score used by topics and branches that reference the given key.

```lua
LDialogueAI:setUtilityScore(key, score)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Utility score key. |
| `score` | number | Utility score value used during weighted selection. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("danger", 0.3, nil, nil, "danger")
    ai:setUtilityScore("danger", 0.95)
    local topic = ai:selectTopic()
    print("LDialogueAI:setUtilityScore topic=" .. tostring(topic))
end
```

---

#### `LDialogueAI:type`

Returns the Lua-visible type name for this dialogue AI handle.

```lua
LDialogueAI:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDialogueAI](#ldialogueai)`. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:type=" .. ai:type())
end
```

---

#### `LDialogueAI:typeOf`

Returns whether this dialogue AI handle matches a supported type name.

```lua
LDialogueAI:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `DialogueAI` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:typeOf LDialogueAI=" .. tostring(ai:typeOf("LDialogueAI")))
end
```

---

## LDialogueState

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDialogueState:advance`

Advances to a new node in the conversation.

```lua
LDialogueState:advance(node_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_id` | string | Node identifier to advance to. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("chat_intro")
    ds:advance("chat_reply")
    print("LDialogueState:advance current=" .. tostring(ds:current()))
end
```

---

#### `LDialogueState:current`

Returns the ID of the currently active dialogue node or nil.

```lua
LDialogueState:current()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current node identifier, or nil when no node is active. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("quest_offer")
    print("LDialogueState:current=" .. tostring(ds:current()))
end
```

---

#### `LDialogueState:end_`

End the active conversation and release its state data.

```lua
LDialogueState:end_()
```

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("farewell")
    ds:end_()
    print("LDialogueState:end_ isActive=" .. tostring(ds:isActive()))
end
```

---

#### `LDialogueState:getVariable`

Gets a conversation variable by key.

```lua
LDialogueState:getVariable(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name. |

**Returns**

| Type | Description |
|------|-------------|
| string | Variable value, or nil when the variable is not set. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:setVariable("coins", "50")
    print("LDialogueState:getVariable=" .. tostring(ds:getVariable("coins")))
end
```

---

#### `LDialogueState:hasVisited`

Check whether a given conversation node has been visited.

```lua
LDialogueState:hasVisited(node_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_id` | string | Node identifier to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the node has been visited. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("info")
    ds:advance("bridge_warning")
    print("visited info=" .. tostring(ds:hasVisited("info")))
    print("visited bridge_warning=" .. tostring(ds:hasVisited("bridge_warning")))
end
```

---

#### `LDialogueState:isActive`

Returns whether the conversation is currently active.

```lua
LDialogueState:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when conversation is active. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("LDialogueState:isActive=" .. tostring(ds:isActive()))
end
```

---

#### `LDialogueState:reset`

Reset all conversation progress, history, and visited flags.

```lua
LDialogueState:reset()
```

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("cycle_a")
    ds:advance("cycle_b")
    ds:reset()
    print("LDialogueState:reset isActive=" .. tostring(ds:isActive()))
    print("visit count=" .. ds:visitCount())
end
```

---

#### `LDialogueState:setVariable`

Sets a conversation variable for this object.

```lua
LDialogueState:setVariable(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Variable name. |
| `value` | string | Variable value. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:setVariable("accepted", "no")
    print("LDialogueState:setVariable=" .. tostring(ds:getVariable("accepted")))
end
```

---

#### `LDialogueState:start`

Starts a conversation at the given node.

```lua
LDialogueState:start(node_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_id` | string | Starting node identifier. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("intro")
    print("LDialogueState:start isActive=" .. tostring(ds:isActive()))
    print("current=" .. tostring(ds:current()))
end
```

---

#### `LDialogueState:type`

Returns the Lua-visible type name.

```lua
LDialogueState:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDialogueState](#ldialoguestate)`. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:type=" .. ds:type())
end
```

---

#### `LDialogueState:typeOf`

Returns whether this handle matches a supported type name.

```lua
LDialogueState:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the type name matches. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:typeOf LDialogueState=" .. tostring(ds:typeOf("LDialogueState")))
end
```

---

#### `LDialogueState:visitCount`

Returns the number of visited nodes.

```lua
LDialogueState:visitCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of visited nodes. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("rumor_intro")
    ds:advance("rumor_detail")
    ds:advance("rumor_exit")
    print("LDialogueState:visitCount=" .. ds:visitCount())
end
```

---

## LSpeakerRegistry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpeakerRegistry:add`

Registers a speaker in the registry.

```lua
LSpeakerRegistry:add(id, name, portrait, voice_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Unique speaker identifier. |
| `name` | string | Display name. |
| `portrait?` | string | Optional portrait asset path. |
| `voice_id?` | string | Optional voice identifier. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("blacksmith", "Gordan", "gordan.png", "smith.voice")
    print("LSpeakerRegistry:add count=" .. sr:count())
end
```

---

#### `LSpeakerRegistry:contains`

Checks if a speaker exists in the registry.

```lua
LSpeakerRegistry:contains(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Speaker identifier. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the speaker exists. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("merchant", "Henri")
    print("LSpeakerRegistry:contains=" .. tostring(sr:contains("merchant")))
end
```

---

#### `LSpeakerRegistry:count`

Returns the number of registered speakers.

```lua
LSpeakerRegistry:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Speaker count. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("npc1", "Anna")
    sr:add("npc2", "Bob")
    print("LSpeakerRegistry:count=" .. sr:count())
end
```

---

#### `LSpeakerRegistry:get`

Gets a speaker by ID as a table with id, name, portrait, voice_id fields.

```lua
LSpeakerRegistry:get(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Speaker identifier. |

**Returns**

| Type | Description |
|------|-------------|
| table | Speaker info table, or nil when the speaker ID is not found. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guard", "Marcus")
    local spk = sr:get("guard")
    print("LSpeakerRegistry:get name=" .. tostring(spk and spk.name))
end
```

---

#### `LSpeakerRegistry:remove`

Removes a speaker by ID for this object.

```lua
LSpeakerRegistry:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Speaker identifier. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the speaker was found and removed. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("temp", "Temp")
    sr:remove("temp")
    print("LSpeakerRegistry:remove count=" .. sr:count())
end
```

---

#### `LSpeakerRegistry:type`

Returns the Lua-visible type name.

```lua
LSpeakerRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSpeakerRegistry](#lspeakerregistry)`. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:type=" .. sr:type())
end
```

---

#### `LSpeakerRegistry:typeOf`

Returns whether this handle matches a supported type name.

```lua
LSpeakerRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the type name matches. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:typeOf LSpeakerRegistry=" .. tostring(sr:typeOf("LSpeakerRegistry")))
end
```

---
