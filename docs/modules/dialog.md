# Dialog

## Purpose

Orchestrates branching narrative graphs using conditional gates.

## When To Use

- Dialogue trees, speaker metadata, conditional gates, weighted branching, callbacks, waits, and jumps work together so conversations can be authored as explicit progression instead of scattered local state checks.
- Sequencing is a core part of the value: reveal timing, advancement, and event hooks let dialogue participate in pacing, scripting, and gameplay rather than acting as a static text lookup table.
- Variable-aware flow and state tracking make it practical to mix authored story beats with runtime-driven responses, which is important for larger RPG, strategy, and simulation interfaces.

## Minimal Example

From the `lurek.dialog.newAI` example block:

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    ai:addTopic("quest_offer", 0.7)
    local type_name = ai:type()
    local topic_count = ai:getTopicCount()
    lurek.log.info("dialog AI ready: " .. type_name)
    lurek.log.info("topics prepared for tavern NPC = " .. topic_count)
end
```

## Common Patterns

- Start with `lurek.dialog.call` when exploring this module.
- Start with `lurek.dialog.choice` when exploring this module.
- Start with `lurek.dialog.event` when exploring this module.
- Start with `lurek.dialog.jump` when exploring this module.
- Start with `lurek.dialog.newAI` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/dialog.lua`

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
    local timeline = { lurek.dialog.choice("Accept quest?", {"Yes", "No"}), node }
    local callback = timeline[2]
    lurek.log.info("call node type = " .. callback.type)
    lurek.log.info("callback name = " .. callback.name)
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
    local seq = lurek.dialog.newSequencer()
    seq:load({ node })
    seq:start()
    local labels = seq:getChoiceLabels()
    lurek.log.info("choice node type = " .. node.type)
    lurek.log.info("prompt=" .. seq:getChoiceText() .. " options=" .. #labels)
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
    local timeline = { lurek.dialog.say("Hero", "We did it."), node }
    local last = timeline[#timeline]
    lurek.log.info("event node type = " .. last.type)
    lurek.log.info("event name=" .. last.name .. " data=" .. tostring(last.data))
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
    local timeline = { lurek.dialog.say("Guide", "Choose your fate."), node }
    local jump = timeline[2]
    lurek.log.info("jump node type = " .. jump.type)
    lurek.log.info("jump target = " .. jump.target)
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
    ai:addTopic("quest_offer", 0.7)
    local type_name = ai:type()
    local topic_count = ai:getTopicCount()
    lurek.log.info("dialog AI ready: " .. type_name)
    lurek.log.info("topics prepared for tavern NPC = " .. topic_count)
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
    seq:load({ lurek.dialog.say("Guide", "Welcome to the inn.") })
    local type_name = seq:type()
    local state = seq:getState()
    local active = seq:isActive()
    lurek.log.info("sequencer type = " .. type_name)
    lurek.log.info("initial state = " .. state .. ", active=" .. tostring(active))
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
    local speaker = sr:get("guide")
    local type_name = sr:type()
    local count = sr:count()
    lurek.log.info("speaker registry type = " .. type_name)
    lurek.log.info("registered " .. speaker.name .. ", count=" .. count)
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
    ds:setVariable("speaker", "guide")
    local type_name = ds:type()
    local current = ds:current()
    lurek.log.info("dialog state type = " .. type_name)
    lurek.log.info("active=" .. tostring(ds:isActive()) .. " current=" .. tostring(current))
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
    local seq = lurek.dialog.newSequencer()
    seq:load({ node })
    seq:start()
    lurek.log.info("say node type = " .. node.type)
    lurek.log.info("speaker=" .. node.actor .. " text=" .. seq:currentText())
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
    local timeline = { lurek.dialog.say("Guide", "Hold on."), node, lurek.dialog.say("Guide", "Done.") }
    local total_nodes = #timeline
    local seconds = node.seconds
    lurek.log.info("wait node type = " .. node.type)
    lurek.log.info("pause seconds = " .. seconds .. " across " .. total_nodes .. " timeline nodes")
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
    lurek.log.info("LDialogSequencer:advance text=" .. seq:currentText())
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
    lurek.log.info("LDialogSequencer:choose state=" .. seq:getState())
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
    local speaker = seq:currentSpeaker()
    local text = seq:currentText()
    local state = seq:getState()
    lurek.log.info("current speaker = " .. tostring(speaker))
    lurek.log.info("state=" .. state .. " text=" .. text)
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
    local text = seq:currentText()
    local revealed = seq:revealedText()
    local speaker = seq:currentSpeaker()
    lurek.log.info("current text = " .. text)
    lurek.log.info("speaker=" .. tostring(speaker) .. " revealed=" .. revealed)
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
    lurek.log.info("LDialogSequencer:getChoiceLabels count=" .. #labels)
    lurek.log.info("first=" .. labels[1])
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
    local prompt = seq:getChoiceText()
    local labels = seq:getChoiceLabels()
    local waiting = seq:isWaitingForChoice()
    lurek.log.info("choice prompt = " .. tostring(prompt))
    lurek.log.info("waiting=" .. tostring(waiting) .. " options=" .. #labels)
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
    seq:load({ lurek.dialog.say("Guide", "Measured reveal") })
    seq:start()
    local speed = seq:getSpeed()
    local state = seq:getState()
    lurek.log.info("sequencer speed = " .. speed)
    lurek.log.info("state while typing = " .. state)
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
    local state = seq:getState()
    local active = seq:isActive()
    local speaker = seq:currentSpeaker()
    lurek.log.info("sequencer state = " .. state)
    lurek.log.info("active=" .. tostring(active) .. " speaker=" .. tostring(speaker))
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
    lurek.log.info("idle active=" .. tostring(seq:isActive()))
    seq:load({ lurek.dialog.say("NPC", "Started") })
    seq:start()
    lurek.log.info("started active=" .. tostring(seq:isActive()))
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
    local waiting = seq:isWaitingForChoice()
    local prompt = seq:getChoiceText()
    local labels = seq:getChoiceLabels()
    lurek.log.info("waiting for choice = " .. tostring(waiting))
    lurek.log.info("prompt=" .. tostring(prompt) .. " options=" .. #labels)
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
    lurek.log.info("LDialogSequencer:load ok")
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
    lurek.log.info("LDialogSequencer:revealedText=" .. seq:revealedText())
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
    seq:load({ lurek.dialog.say("Guide", "Fast line reveal") })
    seq:start()
    seq:update(0.1)
    lurek.log.info("configured speed = " .. seq:getSpeed())
    lurek.log.info("revealed text after tick = " .. seq:revealedText())
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
    lurek.log.info("LDialogSequencer:skip revealed=" .. seq:revealedText())
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
    local state = seq:getState()
    local speaker = seq:currentSpeaker()
    local text = seq:currentText()
    lurek.log.info("state after start = " .. state)
    lurek.log.info("speaker=" .. tostring(speaker) .. " text=" .. text)
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
    seq:load({ lurek.dialog.say("Guide", "Status check") })
    local type_name = seq:type()
    local state = seq:getState()
    lurek.log.info("sequencer type = " .. type_name)
    lurek.log.info("current state before start = " .. state)
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
    local is_seq = seq:typeOf("LDialogSequencer")
    local is_object = seq:typeOf("LObject")
    local is_ai = seq:typeOf("LDialogueAI")
    lurek.log.info("is sequencer = " .. tostring(is_seq))
    lurek.log.info("is object = " .. tostring(is_object) .. ", ai=" .. tostring(is_ai))
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
    lurek.log.info("LDialogSequencer:update revealed=" .. seq:revealedText())
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
    ai:setFSMState("idle")
    local branch = ai:selectBranch("greeting")
    local topics = ai:getTopicCount()
    lurek.log.info("branch added = " .. tostring(added))
    lurek.log.info("selected branch = " .. tostring(branch) .. ", topics=" .. topics)
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
    ai:addTopic("trade", 0.8, "idle")
    ai:setFSMState("idle")
    local count = ai:getTopicCount()
    local topic = ai:selectTopic()
    lurek.log.info("topic count = " .. count)
    lurek.log.info("selected idle topic = " .. tostring(topic))
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
    lurek.log.info("LDialogueAI:clearUtilityScores ok")
    lurek.log.info("selected=" .. tostring(ai:selectTopic()))
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
    ai:addTopic("rumor", 0.2)
    local count = ai:getTopicCount()
    local topic = ai:selectTopic()
    lurek.log.info("topic count = " .. count)
    lurek.log.info("currently selected topic = " .. tostring(topic))
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
    lurek.log.info("LDialogueAI:selectBranch=" .. tostring(branch))
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
    lurek.log.info("LDialogueAI:selectTopic=" .. tostring(topic))
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
    lurek.log.info("LDialogueAI:setBTStatus ok")
    lurek.log.info("selected=" .. tostring(ai:selectTopic()))
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
    lurek.log.info("LDialogueAI:setFSMState ok")
    lurek.log.info("selected=" .. tostring(ai:selectTopic()))
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
    lurek.log.info("LDialogueAI:setUtilityScore topic=" .. tostring(topic))
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
    ai:addTopic("greeting", 1.0)
    local type_name = ai:type()
    local count = ai:getTopicCount()
    lurek.log.info("dialog AI type = " .. type_name)
    lurek.log.info("registered topics = " .. count)
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
    local is_ai = ai:typeOf("LDialogueAI")
    local is_object = ai:typeOf("LObject")
    local is_seq = ai:typeOf("LDialogSequencer")
    lurek.log.info("is dialogue AI = " .. tostring(is_ai))
    lurek.log.info("active branch after cast = " .. tostring(ai:selectBranch("weather")) .. ", sequencer=" .. tostring(is_seq))
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
    local current = ds:current()
    local visited_intro = ds:hasVisited("chat_intro")
    local visits = ds:visitCount()
    lurek.log.info("advanced to " .. tostring(current))
    lurek.log.info("intro visited=" .. tostring(visited_intro) .. " total=" .. visits)
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
    ds:advance("quest_reward")
    local current = ds:current()
    local reward_path = ds:hasVisited("quest_reward")
    lurek.log.info("current node = " .. tostring(current))
    lurek.log.info("reward path active = " .. tostring(reward_path))
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
    local before = ds:isActive()
    ds:end_()
    local after = ds:isActive()
    local current = ds:current()
    lurek.log.info("dialog active before end = " .. tostring(before))
    lurek.log.info("after end active=" .. tostring(after) .. " current=" .. tostring(current))
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
    ds:setVariable("discount", "10")
    local coins = ds:getVariable("coins")
    local discount = ds:getVariable("discount")
    lurek.log.info("merchant coins = " .. tostring(coins))
    lurek.log.info("discount percent = " .. tostring(discount))
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
    lurek.log.info("visited info=" .. tostring(ds:hasVisited("info")))
    lurek.log.info("visited bridge_warning=" .. tostring(ds:hasVisited("bridge_warning")))
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
    local active_before = ds:isActive()
    ds:end_()
    local active_after = ds:isActive()
    lurek.log.info("state active before end = " .. tostring(active_before))
    lurek.log.info("state active after end = " .. tostring(active_after))
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
    lurek.log.info("LDialogueState:reset isActive=" .. tostring(ds:isActive()))
    lurek.log.info("visit count=" .. ds:visitCount())
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
    ds:setVariable("quest_id", "find-relic")
    local accepted = ds:getVariable("accepted")
    local quest_id = ds:getVariable("quest_id")
    lurek.log.info("accepted flag = " .. tostring(accepted))
    lurek.log.info("quest variable = " .. tostring(quest_id))
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
    ds:setVariable("branch", "intro")
    local active = ds:isActive()
    local current = ds:current()
    local visits = ds:visitCount()
    lurek.log.info("conversation started at " .. tostring(current))
    lurek.log.info("active=" .. tostring(active) .. " visits=" .. visits)
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
    ds:start("intro")
    local type_name = ds:type()
    local current = ds:current()
    local active = ds:isActive()
    lurek.log.info("state handle type = " .. type_name)
    lurek.log.info("active=" .. tostring(active) .. " current=" .. tostring(current))
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
    local is_state = ds:typeOf("LDialogueState")
    local is_object = ds:typeOf("LObject")
    local is_registry = ds:typeOf("LSpeakerRegistry")
    lurek.log.info("is state = " .. tostring(is_state))
    lurek.log.info("registry cast valid = " .. tostring(is_registry) .. ", active=" .. tostring(ds:isActive()))
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
    lurek.log.info("LDialogueState:visitCount=" .. ds:visitCount())
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
    local speaker = sr:get("blacksmith")
    local count = sr:count()
    lurek.log.info("added speaker " .. speaker.name)
    lurek.log.info("registry count = " .. count)
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
    local has_merchant = sr:contains("merchant")
    local has_guard = sr:contains("guard")
    lurek.log.info("merchant registered = " .. tostring(has_merchant))
    lurek.log.info("guard registered = " .. tostring(has_guard))
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
    local total = sr:count()
    local anna = sr:get("npc1")
    lurek.log.info("registry size = " .. total)
    lurek.log.info("first speaker in scene = " .. anna.name)
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
    local exists = sr:contains("guard")
    local count = sr:count()
    lurek.log.info("speaker fetched = " .. tostring(spk and spk.name))
    lurek.log.info("exists=" .. tostring(exists) .. " count=" .. count)
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
    local before = sr:count()
    local removed = sr:remove("temp")
    local after = sr:count()
    lurek.log.info("removed temp speaker = " .. tostring(removed))
    lurek.log.info("count " .. before .. " -> " .. after)
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
    sr:add("healer", "Mira")
    local type_name = sr:type()
    local count = sr:count()
    lurek.log.info("speaker registry type = " .. type_name)
    lurek.log.info("healer board count = " .. count)
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
    local is_registry = sr:typeOf("LSpeakerRegistry")
    local is_object = sr:typeOf("LObject")
    local is_state = sr:typeOf("LDialogueState")
    lurek.log.info("is speaker registry = " .. tostring(is_registry))
    lurek.log.info("speaker registry count = " .. sr:count() .. ", state=" .. tostring(is_state))
end
```

---
