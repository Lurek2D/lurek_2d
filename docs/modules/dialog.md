# Dialog

## General Info

- Module group: `Edge/Integration`
- Source path: `src/dialog/`
- Lua API path(s): `src/lua_api/dialog_api.rs`
- Primary Lua namespace: `lurek.dialog`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

Provides a flexible dialog tree engine for interactive conversations. Supports
weighted topic/branch selection with gate conditions (FSM state, behavior tree
status, utility scores), conversation state tracking with visited history and
variables, and a speaker registry for character metadata.

Extracted from `src/ai/dialogue.rs` and expanded into a full dialog subsystem.

## Functions

### `lurek.dialog.newAI`

Creates an empty dialogue selector for weighted topics and branches.

```lua
-- signature
lurek.dialog.newAI()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDialogueAI` | New dialogue AI handle. |

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

### `lurek.dialog.newSpeakerRegistry`

Creates an empty speaker registry for dialog participants.

```lua
-- signature
lurek.dialog.newSpeakerRegistry()
```

**Returns**

| Type | Description |
|------|-------------|
| `LSpeakerRegistry` | New speaker registry handle. |

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
-- signature
lurek.dialog.newState()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDialogueState` | New dialogue state handle. |

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

## LDialogueAI

### `LDialogueAI:addBranch`

Adds a selectable branch under an existing dialogue topic.

```lua
-- signature
LDialogueAI:addBranch(topic_id, branch_id, weight, fsm_state, bt_status, utility_key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `topic_id` | `string` | Topic identifier that receives the branch. |
| `branch_id` | `string` | Unique branch identifier within the topic. |
| `weight?` | `number` | Base branch weight; defaults to 1.0. |
| `fsm_state?` | `string` | Optional FSM state required for this branch. |
| `bt_status?` | `string` | Optional behavior tree status required for this branch. |
| `utility_key?` | `string` | Optional utility score key multiplied into selection. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the branch was added to an existing topic. |

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

### `LDialogueAI:addTopic`

Adds a selectable dialogue topic with optional context filters.

```lua
-- signature
LDialogueAI:addTopic(id, weight, fsm_state, bt_status, utility_key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Unique topic identifier. |
| `weight?` | `number` | Base selection weight; defaults to 1.0. |
| `fsm_state?` | `string` | Optional FSM state required for this topic. |
| `bt_status?` | `string` | Optional behavior tree status required for this topic. |
| `utility_key?` | `string` | Optional utility score key multiplied into selection. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5, "idle")
    print("LDialogueAI:addTopic count=" .. ai:getTopicCount())
end
```

---

### `LDialogueAI:clearUtilityScores`

Removes every stored utility score from this dialogue selector.

```lua
-- signature
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

### `LDialogueAI:getTopicCount`

Returns the number of topics registered in this dialogue selector.

```lua
-- signature
LDialogueAI:getTopicCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current topic count. |

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

### `LDialogueAI:selectBranch`

Selects the best currently valid branch for the given topic.

```lua
-- signature
LDialogueAI:selectBranch(topic_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `topic_id` | `string` | Topic identifier whose branches should be considered. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Selected branch identifier, or nil when no branch is available. |

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

### `LDialogueAI:selectTopic`

Selects the best currently valid topic using weights and context filters.

```lua
-- signature
LDialogueAI:selectTopic()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Selected topic identifier, or nil when no topic is available. |

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

### `LDialogueAI:setBTStatus`

Sets the behavior-tree status used as dialogue selection context.

```lua
-- signature
LDialogueAI:setBTStatus(status)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `status?` | `string` | Current behavior tree status, or nil to clear the status context. |

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

### `LDialogueAI:setFSMState`

Sets the finite-state-machine state used as dialogue selection context.

```lua
-- signature
LDialogueAI:setFSMState(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state?` | `string` | Current FSM state name, or nil to clear the FSM context. |

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

### `LDialogueAI:setUtilityScore`

Stores a utility score used by topics and branches that reference the given key.

```lua
-- signature
LDialogueAI:setUtilityScore(key, score)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Utility score key. |
| `score` | `number` | Utility score value used during weighted selection. |

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

### `LDialogueAI:type`

Returns the Lua-visible type name for this dialogue AI handle.

```lua
-- signature
LDialogueAI:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDialogueAI`. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:type=" .. ai:type())
end
```

---

### `LDialogueAI:typeOf`

Returns whether this dialogue AI handle matches a supported type name.

```lua
-- signature
LDialogueAI:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `DialogueAI` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:typeOf LDialogueAI=" .. tostring(ai:typeOf("LDialogueAI")))
end
```

---

## LDialogueState

### `LDialogueState:advance`

Advances to a new node in the conversation.

```lua
-- signature
LDialogueState:advance(node_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_id` | `string` | Node identifier to advance to. |

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

### `LDialogueState:current`

Returns the ID of the currently active dialogue node or nil.

```lua
-- signature
LDialogueState:current()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Current node identifier, or nil when no node is active. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("quest_offer")
    print("LDialogueState:current=" .. tostring(ds:current()))
end
```

---

### `LDialogueState:end_`

End the active conversation and release its state data.

```lua
-- signature
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

### `LDialogueState:getVariable`

Gets a conversation variable by key.

```lua
-- signature
LDialogueState:getVariable(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Variable name. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Variable value, or nil when the variable is not set. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:setVariable("coins", "50")
    print("LDialogueState:getVariable=" .. tostring(ds:getVariable("coins")))
end
```

---

### `LDialogueState:hasVisited`

Check whether a given conversation node has been visited.

```lua
-- signature
LDialogueState:hasVisited(node_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_id` | `string` | Node identifier to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the node has been visited. |

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

### `LDialogueState:isActive`

Returns whether the conversation is currently active.

```lua
-- signature
LDialogueState:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when conversation is active. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("LDialogueState:isActive=" .. tostring(ds:isActive()))
end
```

---

### `LDialogueState:reset`

Reset all conversation progress, history, and visited flags.

```lua
-- signature
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

### `LDialogueState:setVariable`

Sets a conversation variable for this object.

```lua
-- signature
LDialogueState:setVariable(key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | `string` | Variable name. |
| `value` | `string` | Variable value. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    ds:setVariable("accepted", "no")
    print("LDialogueState:setVariable=" .. tostring(ds:getVariable("accepted")))
end
```

---

### `LDialogueState:start`

Starts a conversation at the given node.

```lua
-- signature
LDialogueState:start(node_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `node_id` | `string` | Starting node identifier. |

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

### `LDialogueState:type`

Returns the Lua-visible type name.

```lua
-- signature
LDialogueState:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDialogueState`. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:type=" .. ds:type())
end
```

---

### `LDialogueState:typeOf`

Returns whether this handle matches a supported type name.

```lua
-- signature
LDialogueState:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the type name matches. |

**Example**

```lua
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:typeOf LDialogueState=" .. tostring(ds:typeOf("LDialogueState")))
end
```

---

### `LDialogueState:visitCount`

Returns the number of visited nodes.

```lua
-- signature
LDialogueState:visitCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of visited nodes. |

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

### `LSpeakerRegistry:add`

Registers a speaker in the registry.

```lua
-- signature
LSpeakerRegistry:add(id, name, portrait, voice_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Unique speaker identifier. |
| `name` | `string` | Display name. |
| `portrait?` | `string` | Optional portrait asset path. |
| `voice_id?` | `string` | Optional voice identifier. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("blacksmith", "Gordan", "gordan.png", "smith.voice")
    print("LSpeakerRegistry:add count=" .. sr:count())
end
```

---

### `LSpeakerRegistry:contains`

Checks if a speaker exists in the registry.

```lua
-- signature
LSpeakerRegistry:contains(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Speaker identifier. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the speaker exists. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("merchant", "Henri")
    print("LSpeakerRegistry:contains=" .. tostring(sr:contains("merchant")))
end
```

---

### `LSpeakerRegistry:count`

Returns the number of registered speakers.

```lua
-- signature
LSpeakerRegistry:count()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Speaker count. |

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

### `LSpeakerRegistry:get`

Gets a speaker by ID as a table with id, name, portrait, voice_id fields.

```lua
-- signature
LSpeakerRegistry:get(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Speaker identifier. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Speaker info table, or nil when the speaker ID is not found. |

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

### `LSpeakerRegistry:remove`

Removes a speaker by ID for this object.

```lua
-- signature
LSpeakerRegistry:remove(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Speaker identifier. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the speaker was found and removed. |

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

### `LSpeakerRegistry:type`

Returns the Lua-visible type name.

```lua
-- signature
LSpeakerRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LSpeakerRegistry`. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:type=" .. sr:type())
end
```

---

### `LSpeakerRegistry:typeOf`

Returns whether this handle matches a supported type name.

```lua
-- signature
LSpeakerRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the type name matches. |

**Example**

```lua
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:typeOf LSpeakerRegistry=" .. tostring(sr:typeOf("LSpeakerRegistry")))
end
```

---
