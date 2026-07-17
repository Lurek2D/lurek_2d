# Progression

## Purpose

lurek.progression is the canonical offline-first progression store for counters, stats-like data, resources, XP, achievements, quests, rewards, event history, seasons, rivals, deterministic virtual populations, and initial transport-neutral changesets. - The initial implementation is headless and deterministic. - Legacy-style stats and quest adapters now live directly inside lurek.progression, so old gameplay patterns can migrate without keeping separate library.stats or library.quest modules.

## Summary

`lurek.progression` introduces a store-based progression model under `src/progression/` and exposes it to Lua as `lurek.progression`.

The current slice includes:

- isolated stores with logical time and bounded events;
- profiles with tags and metadata;
- counter definitions and threshold events;
- shared condition compile/validate/evaluate/explain helpers for counter, achievement, quest, tag, all/any/not checks;
- initial derived-value definitions with named progression inputs, arithmetic expressions, validation, and explanations;
- initial profile template definitions with authored counter, attribute, resource, XP, tag, and metadata seeding;
- initial trait and perk definitions with canonical per-profile trait activation and perk-granted trait unlocks;
- initial skill definitions with learned levels, attribute-backed costs, manual use, and cooldown ticking through store updates;
- initial leaderboard definitions with deterministic ranking, manual score submission, counter-backed score sources, top/range/around-profile queries, and top-threshold movement events;
- initial season definitions with manual logical start/end control, optional archive snapshots, and reset hooks for selected counters and leaderboards;
- initial prestige definitions with level-gated rebirth checks, selected counter/level resets, preserved achievement state, and lifetime counter carry-forward;
- initial collections with achievement-set items, hidden codex-style discoveries, completion percentage, and optional meta-achievement unlocks;
- initial challenge templates with manual or counter-driven progress, activation windows, status filters, expiry, and reward records;
- initial rivals with leaderboard-aware delta queries, overtake events, and a bounded local activity feed derived from retained progression events;
- initial virtual population templates with deterministic identity generation, leaderboard-backed lightweight profiles, logical-time simulation, materialization/dematerialization, and leaderboard participation without a network service;
- isolated `newStatusTracker()` handles with validated status definitions, replace/refresh/add stacking, finite duration and periodic tick scheduling, snapshots, and neutral lifecycle events;
- attributes, resources, modifiers, and XP/level tracks;
- achievements with manual and counter-triggered unlocks;
- reward records with pending, claimed, applied, and rejected states;
- quest definitions with reveal and availability lifecycle, manual progress, canonical journal entries, visible/hidden objectives, explicit objective status overrides, counter-driven objectives, and quest rewards;
- transaction batching, debug snapshots, bounded changeset envelopes with schema/hash validation, ack/compaction helpers, and compatibility `exportChangesSince` / `applyChangeset` support built from retained revision snapshots;
- initial changeset merge policies with conflict reports for local profile divergence and quest-branch mismatches;
- malformed or oversized changesets are rejected before snapshot application;
- legacy import helpers for snapshots produced by the former `library.stats` and `library.quest` flows.

The module is intentionally headless. It owns data and mutation rules only.
Status ticks and expiry are emitted as neutral records; Lua gameplay code explicitly decides whether
to apply damage, healing, animation, audio, ECS changes, or other effects.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.progression.acquirePerk`

Acquire perk.

```lua
lurek.progression.acquirePerk(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_acquireperk" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = "example_trait" })
    local acquired = adapter:acquirePerk("iron_skin")
    lurek.log.info("{api} acquired=" .. tostring(acquired) .. " has=" .. tostring(adapter:hasPerk("iron_skin")))
end
```

---

### `lurek.progression.activeCount`

Active count.

```lua
lurek.progression.activeCount(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_activecount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local count = adapter:activeCount()
    lurek.log.info("lurek.progression.activeCount count=" .. tostring(count))
end
```

---

### `lurek.progression.activeIds`

Active ids.

```lua
lurek.progression.activeIds(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_activeids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local ids = adapter:activeIds()
    lurek.log.info("lurek.progression.activeIds first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.addBuff`

Adds buff.

```lua
lurek.progression.addBuff()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addbuff" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local handle = adapter:addBuff("hp", 5, 1, 2, "potion")
    local count = adapter:getBuffCount("hp")
    lurek.log.info("{api} handle=" .. tostring(handle) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.addJournalEntry`

Adds journal entry.

```lua
lurek.progression.addJournalEntry(this, quest_id, text, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `quest_id` | any |  |
| `text` | any |  |
| `tag?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addjournalentry" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:addJournalEntry("cleanup", "Entered the cellar", "story")
    local quest_state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.addJournalEntry journal=" .. tostring(#quest_state.journal))
end
```

---

### `lurek.progression.addQuest`

Adds quest.

```lua
lurek.progression.addQuest(this, quest)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `quest` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.addQuest first=" .. tostring(ids[1]) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.addXP`

Adds xp.

```lua
lurek.progression.addXP(this, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addxp" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:addXP(120)
    local xp = adapter:getXP()
    local level = adapter:getLevel()
    lurek.log.info("{api} xp=" .. tostring(xp) .. " level=" .. tostring(level))
end
```

---

### `lurek.progression.adjustMorale`

Adjust morale.

```lua
lurek.progression.adjustMorale(this, delta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `delta` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_adjustmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:adjustMorale(-3)
    local current = select(1, adapter:getMorale())
    lurek.log.info("{api} morale=" .. tostring(current))
end
```

---

### `lurek.progression.advanceObjective`

Advance objective.

```lua
lurek.progression.advanceObjective()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_advanceobjective" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.advanceObjective status=" .. tostring(state.status))
end
```

---

### `lurek.progression.applyDamage`

Apply damage.

```lua
lurek.progression.applyDamage(this, stat, amount, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `stat` | any |  |
| `amount` | any |  |
| `dtype?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_applydamage" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setResistance("fire", 0.25)
    local actual = adapter:applyDamage("hp", 40, "fire")
    local hp = adapter:getBase("hp")
    lurek.log.info("{api} actual=" .. tostring(actual) .. " hp=" .. tostring(hp))
end
```

---

### `lurek.progression.applyTraitBuffs`

Apply trait buffs.

```lua
lurek.progression.applyTraitBuffs(this, trait_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `trait_name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_applytraitbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    local traits = adapter:getActiveTraits()
    lurek.log.info("{api} trait=" .. tostring(traits[1]))
end
```

---

### `lurek.progression.beginTurn`

Begin turn.

```lua
lurek.progression.beginTurn(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_beginturn" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    adapter:spendActionPoints(3)
    adapter:beginTurn()
    local current = select(1, adapter:getActionPoints())
    lurek.log.info("{api} current=" .. tostring(current))
end
```

---

### `lurek.progression.checkMorale`

Check morale.

```lua
lurek.progression.checkMorale(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_checkmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:setPanicThreshold(6)
    adapter:setBerserkThreshold(3)
    adapter:adjustMorale(-5)
    lurek.log.info("{api} state=" .. tostring(adapter:checkMorale()))
end
```

---

### `lurek.progression.clearBuffs`

Clears buffs.

```lua
lurek.progression.clearBuffs(this, stat)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `stat?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_clearbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:addBuff("hp", 5, 1, 1, "a")
    adapter:clearBuffs("hp")
    lurek.log.info("{api} count=" .. tostring(adapter:getBuffCount("hp")))
end
```

---

### `lurek.progression.clearFlag`

Clears flag.

```lua
lurek.progression.clearFlag(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_clearflag" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    adapter:clearFlag("panic")
    local flags = adapter:getFlags()
    lurek.log.info("{api} count=" .. tostring(#flags))
end
```

---

### `lurek.progression.completeQuest`

Complete quest.

```lua
lurek.progression.completeQuest(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_completequest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:completeQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.completeQuest status=" .. tostring(state.status))
end
```

---

### `lurek.progression.completedCount`

Completed count.

```lua
lurek.progression.completedCount(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_completedcount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    lurek.log.info("lurek.progression.completedCount count=" .. tostring(adapter:completedCount()))
end
```

---

### `lurek.progression.completedIds`

Completed ids.

```lua
lurek.progression.completedIds(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_completedids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local ids = adapter:completedIds()
    lurek.log.info("lurek.progression.completedIds first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.createLegacyQuestAdapter`

Create legacy quest adapter.

```lua
lurek.progression.createLegacyQuestAdapter(store, profile, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `store` | any |  |
| `profile` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_createlegacyquestadapter" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local kind = adapter.type()
    lurek.log.info("lurek.progression.createLegacyQuestAdapter type=" .. tostring(kind) .. " first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.createLegacyStatsAdapter`

Create legacy stats adapter.

```lua
lurek.progression.createLegacyStatsAdapter(store, profile, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `store` | any |  |
| `profile` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_createlegacystatsadapter" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    local stats = adapter:getStatNames()
    local kind = adapter.type()
    lurek.log.info("{api} type=" .. tostring(kind) .. " stats=" .. tostring(#stats))
end
```

---

### `lurek.progression.define`

Define.

```lua
lurek.progression.define(this, name, base, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `base` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_define" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local names = adapter:getStatNames()
    local value = adapter:get("hp")
    lurek.log.info("{api} stat=" .. tostring(names[1]) .. " value=" .. tostring(value))
end
```

---

### `lurek.progression.definePerk`

Define perk.

```lua
lurek.progression.definePerk(this, name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_defineperk" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:definePerk("iron_skin", { require_level = 1, trait_name = "example_trait" })
    adapter:setXP(150)
    lurek.log.info("{api} ready=" .. tostring(adapter:hasPerk("iron_skin")))
end
```

---

### `lurek.progression.defineSkill`

Define skill.

```lua
lurek.progression.defineSkill(this, name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_defineskill" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    lurek.log.info("{api} level=" .. tostring(adapter:getSkillLevel("heal")))
end
```

---

### `lurek.progression.failQuest`

Fail quest.

```lua
lurek.progression.failQuest(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_failquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:failQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.failQuest status=" .. tostring(state.status))
end
```

---

### `lurek.progression.failedIds`

Failed ids.

```lua
lurek.progression.failedIds(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_failedids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:failQuest("cleanup")
    local ids = adapter:failedIds()
    lurek.log.info("lurek.progression.failedIds first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.get`

Returns a value.

```lua
lurek.progression.get(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_get" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local value = adapter:get("hp")
    local base = adapter:getBase("hp")
    lurek.log.info("{api} value=" .. tostring(value) .. " base=" .. tostring(base))
end
```

---

### `lurek.progression.getActionPoints`

Returns the action points.

```lua
lurek.progression.getActionPoints(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Returns**

| Type | Description |
|------|-------------|
| number | Current action points followed by the configured maximum. (value 1). |
| number | Current action points followed by the configured maximum. (value 2). |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getactionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    local current, maxv = adapter:getActionPoints()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.getActiveTraits`

Returns the active traits.

```lua
lurek.progression.getActiveTraits(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getactivetraits" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    local traits = adapter:getActiveTraits()
    lurek.log.info("{api} trait=" .. tostring(traits[1]))
end
```

---

### `lurek.progression.getBase`

Returns the base.

```lua
lurek.progression.getBase(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getbase" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local base = adapter:getBase("hp")
    local value = adapter:get("hp")
    lurek.log.info("{api} base=" .. tostring(base) .. " value=" .. tostring(value))
end
```

---

### `lurek.progression.getBuffCount`

Returns the buff count.

```lua
lurek.progression.getBuffCount(this, stat)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `stat?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getbuffcount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:addBuff("hp", 5, 1, 1, "a")
    local count = adapter:getBuffCount("hp")
    lurek.log.info("{api} count=" .. tostring(count))
end
```

---

### `lurek.progression.getBuffs`

Returns the buffs.

```lua
lurek.progression.getBuffs(this, stat)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `stat?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:addBuff("hp", 5, 1, 1, "a")
    local buffs = adapter:getBuffs("hp")
    lurek.log.info("{api} count=" .. tostring(#buffs))
end
```

---

### `lurek.progression.getCooldownRemaining`

Returns the cooldown remaining.

```lua
lurek.progression.getCooldownRemaining(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getcooldownremaining" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    adapter:useSkill("heal")
    lurek.log.info("{api} cooldown=" .. tostring(adapter:getCooldownRemaining("heal")))
end
```

---

### `lurek.progression.getEncumbrance`

Returns the encumbrance.

```lua
lurek.progression.getEncumbrance(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getencumbrance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setEncumbrance(12, 20)
    local enc = adapter:getEncumbrance()
    local over = adapter:isEncumbered()
    lurek.log.info("{api} current=" .. tostring(enc.current) .. " over=" .. tostring(over))
end
```

---

### `lurek.progression.getFlags`

Returns the flags.

```lua
lurek.progression.getFlags(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getflags" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    adapter:setFlag("wounded")
    local flags = adapter:getFlags()
    lurek.log.info("{api} count=" .. tostring(#flags) .. " first=" .. tostring(flags[1]))
end
```

---

### `lurek.progression.getInitiative`

Returns the initiative.

```lua
lurek.progression.getInitiative(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getinitiative" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setInitiative(17)
    local initiative = adapter:getInitiative()
    local kind = adapter.type()
    lurek.log.info("{api} initiative=" .. tostring(initiative) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.getLevel`

Returns the level.

```lua
lurek.progression.getLevel(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getlevel" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:addXP(150)
    local level = adapter:getLevel()
    local xp = adapter:getXP()
    lurek.log.info("{api} level=" .. tostring(level) .. " xp=" .. tostring(xp))
end
```

---

### `lurek.progression.getMax`

Returns the max.

```lua
lurek.progression.getMax(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getmax" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local maxv = adapter:getMax("hp")
    local minv = adapter:getMin("hp")
    lurek.log.info("{api} min=" .. tostring(minv) .. " max=" .. tostring(maxv))
end
```

---

### `lurek.progression.getMin`

Returns the min.

```lua
lurek.progression.getMin(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getmin" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local minv = adapter:getMin("hp")
    local maxv = adapter:getMax("hp")
    lurek.log.info("{api} min=" .. tostring(minv) .. " max=" .. tostring(maxv))
end
```

---

### `lurek.progression.getMorale`

Returns the morale.

```lua
lurek.progression.getMorale(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Returns**

| Type | Description |
|------|-------------|
| number | Current morale followed by the configured maximum. (value 1). |
| number | Current morale followed by the configured maximum. (value 2). |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    local current, maxv = adapter:getMorale()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.getQuest`

Returns the quest.

```lua
lurek.progression.getQuest(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local fetched = adapter:getQuest("cleanup")
    local ids = adapter:questIds()
    lurek.log.info("lurek.progression.getQuest id=" .. tostring(fetched.id) .. " first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.getQuestReward`

Returns the quest reward.

```lua
lurek.progression.getQuestReward(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getquestreward" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:setQuestReward("cleanup", "gold")
    local reward = adapter:getQuestReward("cleanup")
    lurek.log.info("lurek.progression.getQuestReward reward=" .. tostring(reward))
end
```

---

### `lurek.progression.getRegen`

Returns the regen.

```lua
lurek.progression.getRegen(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getregen" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setRegen("hp", 1.5)
    local regen = adapter:getRegen("hp")
    lurek.log.info("{api} regen=" .. tostring(regen))
end
```

---

### `lurek.progression.getResistance`

Returns the resistance.

```lua
lurek.progression.getResistance(this, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `dtype` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getresistance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setResistance("fire", 0.25)
    local value = adapter:getResistance("fire")
    local kind = adapter.type()
    lurek.log.info("{api} value=" .. tostring(value) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.getSkillLevel`

Returns the skill level.

```lua
lurek.progression.getSkillLevel(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getskilllevel" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    lurek.log.info("{api} level=" .. tostring(adapter:getSkillLevel("heal")))
end
```

---

### `lurek.progression.getStatNames`

Returns the stat names.

```lua
lurek.progression.getStatNames(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getstatnames" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("agi", 8, { min = 0, max = 20 })
    adapter:define("hp", 100, { min = 0, max = 150 })
    local names = adapter:getStatNames()
    lurek.log.info("{api} first=" .. tostring(names[1]) .. " total=" .. tostring(#names))
end
```

---

### `lurek.progression.getUseCount`

Returns the use count.

```lua
lurek.progression.getUseCount(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getusecount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:recordUse("heal")
    local count = adapter:getUseCount("heal")
    local kind = adapter.type()
    lurek.log.info("{api} count=" .. tostring(count) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.getXP`

Returns the xp.

```lua
lurek.progression.getXP(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getxp" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:addXP(120)
    local xp = adapter:getXP()
    local level = adapter:getLevel()
    lurek.log.info("{api} xp=" .. tostring(xp) .. " level=" .. tostring(level))
end
```

---

### `lurek.progression.hasFlag`

Returns true if flag.

```lua
lurek.progression.hasFlag(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_hasflag" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    local has = adapter:hasFlag("panic")
    local flags = adapter:getFlags()
    lurek.log.info("{api} has=" .. tostring(has) .. " count=" .. tostring(#flags))
end
```

---

### `lurek.progression.hasPerk`

Returns true if perk.

```lua
lurek.progression.hasPerk(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_hasperk" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = "example_trait" })
    lurek.log.info("{api} has=" .. tostring(adapter:hasPerk("iron_skin")))
end
```

---

### `lurek.progression.hasTrait`

Returns true if trait.

```lua
lurek.progression.hasTrait(this, trait_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `trait_name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_hastrait" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    lurek.log.info("{api} has=" .. tostring(adapter:hasTrait("example_trait")))
end
```

---

### `lurek.progression.importLegacyQuestSnapshot`

Import legacy quest snapshot.

```lua
lurek.progression.importLegacyQuestSnapshot(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | any |  |

**Example**

```lua
do
    local converted = lurek.progression.importLegacyQuestSnapshot({
        quests = {
            { id = "rat_hunt", title = "Rat Hunt", status = "active" },
            { id = "cleanup", title = "Cleanup", status = "completed" },
        },
    })
    lurek.log.info("importLegacyQuestSnapshot quests=" .. tostring(#converted.quests) .. " first=" .. tostring(converted.quests[1] and converted.quests[1].id))
end
```

---

### `lurek.progression.importLegacyStatsSnapshot`

Import legacy stats snapshot.

```lua
lurek.progression.importLegacyStatsSnapshot(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | any |  |

**Example**

```lua
do
    local converted = lurek.progression.importLegacyStatsSnapshot({
        xp = 120,
        level = 2,
        attributes = {
            strength = { base = 10 },
            agility = { base = 8 },
        },
    })
    lurek.log.info("importLegacyStatsSnapshot attrs=" .. tostring(#converted.attributes) .. " xp=" .. tostring(converted.experience.experience) .. " level=" .. tostring(converted.experience.level))
end
```

---

### `lurek.progression.isEncumbered`

Returns true if encumbered.

```lua
lurek.progression.isEncumbered(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_isencumbered" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setEncumbrance(21, 20)
    local enc = adapter:getEncumbrance()
    local over = adapter:isEncumbered()
    lurek.log.info("{api} current=" .. tostring(enc.current) .. " over=" .. tostring(over))
end
```

---

### `lurek.progression.learnSkill`

Learn skill.

```lua
lurek.progression.learnSkill(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_learnskill" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    lurek.log.info("{api} level=" .. tostring(adapter:getSkillLevel("heal")))
end
```

---

### `lurek.progression.loadStore`

Load store.

```lua
lurek.progression.loadStore(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | any |  |

**Example**

```lua
do
    local original = lurek.progression.newStore({ id = "snapshot_source" })
    original:createProfile("player", { display_name = "Snapshot Hero" })
    local snapshot = original:exportSnapshot()
    local restored = lurek.progression.loadStore(snapshot)
    lurek.log.info("loadStore id=" .. tostring(restored:getId()) .. " hash=" .. tostring(restored:getDefinitionHash()) .. " profiles=" .. tostring(restored:countProfiles()))
end
```

---

### `lurek.progression.newStatusTracker`

Creates an isolated deterministic status lifecycle tracker.

```lua
lurek.progression.newStatusTracker()
```

**Returns**

| Type | Description |
|------|-------------|
| [LStatusTracker](#lstatustracker) | New status tracker handle. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    local type_name = tracker:type()
    local empty = tracker:list(1)
    lurek.log.info("status tracker type=" .. type_name .. " empty=" .. #empty .. " isolated=" .. tostring(tracker ~= nil))
end
```

---

### `lurek.progression.newStore`

New store.

```lua
lurek.progression.newStore(options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({
        id = "example_store",
        clock = "manual",
        event_capacity = 32,
        max_profiles = 16,
        strict = true,
    })
    local stats = store:stats()
    local snapshot = store:debugSnapshot()
    lurek.log.info("newStore id=" .. tostring(store:getId()) .. " revision=" .. tostring(store:getRevision()) .. " profiles=" .. tostring(stats.profiles) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

### `lurek.progression.questCount`

Quest count.

```lua
lurek.progression.questCount(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_questcount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local count = adapter:questCount()
    local ids = adapter:questIds()
    lurek.log.info("lurek.progression.questCount count=" .. tostring(count) .. " first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.questIds`

Quest ids.

```lua
lurek.progression.questIds(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_questids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.questIds first=" .. tostring(ids[1]) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.questsWithStatus`

Quests with status.

```lua
lurek.progression.questsWithStatus(this, wanted)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `wanted` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_questswithstatus" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local ids = adapter:questsWithStatus("active")
    lurek.log.info("lurek.progression.questsWithStatus first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.recordUse`

Record use.

```lua
lurek.progression.recordUse(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_recorduse" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:recordUse("heal")
    local count = adapter:getUseCount("heal")
    local kind = adapter.type()
    lurek.log.info("{api} count=" .. tostring(count) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.recoverActionPoints`

Recover action points.

```lua
lurek.progression.recoverActionPoints(this, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_recoveractionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    adapter:spendActionPoints(3)
    adapter:recoverActionPoints(2)
    local current = select(1, adapter:getActionPoints())
    lurek.log.info("{api} current=" .. tostring(current))
end
```

---

### `lurek.progression.removeBuff`

Removes buff.

```lua
lurek.progression.removeBuff(this, handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `handle` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_removebuff" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local handle = adapter:addBuff("hp", 5, 1, 1, "a")
    local removed = adapter:removeBuff(handle)
    lurek.log.info("{api} removed=" .. tostring(removed))
end
```

---

### `lurek.progression.removeQuest`

Removes quest.

```lua
lurek.progression.removeQuest(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_removequest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local removed = adapter:removeQuest("cleanup")
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.removeQuest removed=" .. tostring(removed) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.removeTraitBuffs`

Removes trait buffs.

```lua
lurek.progression.removeTraitBuffs(this, trait_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `trait_name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_removetraitbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    local removed = adapter:removeTraitBuffs("example_trait")
    lurek.log.info("{api} removed=" .. tostring(removed))
end
```

---

### `lurek.progression.resetQuest`

Clears quest.

```lua
lurek.progression.resetQuest(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_resetquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local reset = adapter:resetQuest("cleanup")
    lurek.log.info("lurek.progression.resetQuest reset=" .. tostring(reset))
end
```

---

### `lurek.progression.restore`

Restore.

```lua
lurek.progression.restore(this, snap)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `snap` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_restore" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setXP(0)
    local snap = adapter:snapshot()
    adapter:restore(snap)
    local value = adapter:get("hp")
    lurek.log.info("{api} value=" .. tostring(value))
end
```

---

### `lurek.progression.setActionPoints`

Sets the action points.

```lua
lurek.progression.setActionPoints(this, max_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `max_val` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setactionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    local current, maxv = adapter:getActionPoints()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.setBase`

Sets the base.

```lua
lurek.progression.setBase(this, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setbase" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setBase("hp", 120)
    local base = adapter:getBase("hp")
    lurek.log.info("{api} base=" .. tostring(base))
end
```

---

### `lurek.progression.setBerserkThreshold`

Sets the berserk threshold.

```lua
lurek.progression.setBerserkThreshold(this, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setberserkthreshold" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:setPanicThreshold(7)
    adapter:setBerserkThreshold(4)
    adapter:adjustMorale(-7)
    lurek.log.info("{api} state=" .. tostring(adapter:checkMorale()))
end
```

---

### `lurek.progression.setEncumbrance`

Sets the encumbrance.

```lua
lurek.progression.setEncumbrance(this, cur, max_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `cur` | any |  |
| `max_val` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setencumbrance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setEncumbrance(12, 20)
    local enc = adapter:getEncumbrance()
    local over = adapter:isEncumbered()
    lurek.log.info("{api} current=" .. tostring(enc.current) .. " over=" .. tostring(over))
end
```

---

### `lurek.progression.setFlag`

Sets the flag.

```lua
lurek.progression.setFlag(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setflag" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    local has = adapter:hasFlag("panic")
    local flags = adapter:getFlags()
    lurek.log.info("{api} has=" .. tostring(has) .. " count=" .. tostring(#flags))
end
```

---

### `lurek.progression.setInitiative`

Sets the initiative.

```lua
lurek.progression.setInitiative(this, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setinitiative" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setInitiative(17)
    local initiative = adapter:getInitiative()
    local kind = adapter.type()
    lurek.log.info("{api} initiative=" .. tostring(initiative) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.setLevel`

Sets the level.

```lua
lurek.progression.setLevel(this, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setlevel" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setXP(0)
    adapter:setLevel(3)
    local level = adapter:getLevel()
    local xp = adapter:getXP()
    lurek.log.info("{api} level=" .. tostring(level) .. " xp=" .. tostring(xp))
end
```

---

### `lurek.progression.setLevelThresholds`

Sets the level thresholds.

```lua
lurek.progression.setLevelThresholds(this, thresholds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `thresholds` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setlevelthresholds" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setLevelThresholds({ kind = "table", values = { 50, 100, 200 } })
    adapter:addXP(160)
    local level = adapter:getLevel()
    local xp = adapter:getXP()
    lurek.log.info("{api} level=" .. tostring(level) .. " xp=" .. tostring(xp))
end
```

---

### `lurek.progression.setMax`

Sets the max.

```lua
lurek.progression.setMax(this, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setmax" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setMax("hp", 160)
    local maxv = adapter:getMax("hp")
    lurek.log.info("{api} max=" .. tostring(maxv))
end
```

---

### `lurek.progression.setMin`

Sets the min.

```lua
lurek.progression.setMin(this, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setmin" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setMin("hp", 10)
    local minv = adapter:getMin("hp")
    lurek.log.info("{api} min=" .. tostring(minv))
end
```

---

### `lurek.progression.setMorale`

Sets the morale.

```lua
lurek.progression.setMorale(this, max_val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `max_val` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    local current, maxv = adapter:getMorale()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.setPanicThreshold`

Sets the panic threshold.

```lua
lurek.progression.setPanicThreshold(this, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setpanicthreshold" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:setPanicThreshold(8)
    adapter:setBerserkThreshold(4)
    adapter:adjustMorale(-3)
    lurek.log.info("{api} state=" .. tostring(adapter:checkMorale()))
end
```

---

### `lurek.progression.setQuestReward`

Sets the quest reward.

```lua
lurek.progression.setQuestReward(this, id, reward)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |
| `reward` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setquestreward" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:setQuestReward("cleanup", "gold")
    local reward = adapter:getQuestReward("cleanup")
    lurek.log.info("lurek.progression.setQuestReward reward=" .. tostring(reward))
end
```

---

### `lurek.progression.setRegen`

Sets the regen.

```lua
lurek.progression.setRegen(this, name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setregen" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local value = adapter:get("hp")
    local names = adapter:getStatNames()
    lurek.log.info("lurek.progression.setRegen value=" .. tostring(value) .. " stats=" .. tostring(#names))
end
```

---

### `lurek.progression.setResistance`

Sets the resistance.

```lua
lurek.progression.setResistance(this, dtype, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `dtype` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setresistance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setResistance("fire", 0.25)
    local value = adapter:getResistance("fire")
    local kind = adapter.type()
    lurek.log.info("{api} value=" .. tostring(value) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.setXP`

Sets the xp.

```lua
lurek.progression.setXP(this, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setxp" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setXP(180)
    local xp = adapter:getXP()
    local level = adapter:getLevel()
    lurek.log.info("{api} xp=" .. tostring(xp) .. " level=" .. tostring(level))
end
```

---

### `lurek.progression.snapshot`

Snapshot.

```lua
lurek.progression.snapshot(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_snapshot" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setXP(0)
    local snap = adapter:snapshot()
    local value = snap.attributes.hp.base
    lurek.log.info("{api} base=" .. tostring(value) .. " level=" .. tostring(snap.level))
end
```

---

### `lurek.progression.spendActionPoints`

Spend action points.

```lua
lurek.progression.spendActionPoints(this, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_spendactionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    local ok = adapter:spendActionPoints(2)
    local current = select(1, adapter:getActionPoints())
    lurek.log.info("{api} ok=" .. tostring(ok) .. " current=" .. tostring(current))
end
```

---

### `lurek.progression.startQuest`

Start quest.

```lua
lurek.progression.startQuest(this, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_startquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.startQuest status=" .. tostring(state.status))
end
```

---

### `lurek.progression.type`

Type.

```lua
lurek.progression.type()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_type" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    local kind = adapter.type()
    local ok = adapter.typeOf("LLegacyStatsAdapter")
    local names = adapter:getStatNames()
    lurek.log.info("{api} type=" .. tostring(kind) .. " ok=" .. tostring(ok) .. " names=" .. tostring(#names))
end
```

---

### `lurek.progression.typeOf`

Type of.

```lua
lurek.progression.typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_typeof" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    local kind = adapter.type()
    local ok = adapter.typeOf("LLegacyStatsAdapter")
    local names = adapter:getStatNames()
    lurek.log.info("{api} type=" .. tostring(kind) .. " ok=" .. tostring(ok) .. " names=" .. tostring(#names))
end
```

---

### `lurek.progression.update`

Update.

```lua
lurek.progression.update(this, dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `dt` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_update" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    adapter:update(0.5)
    local current = select(1, adapter:getActionPoints())
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " type=" .. tostring(kind))
end
```

---

### `lurek.progression.useSkill`

Use skill.

```lua
lurek.progression.useSkill(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Success flag followed by an optional failure reason. (value 1). |
| string? | Success flag followed by an optional failure reason. (value 2). |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_useskill" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    local ok = adapter:useSkill("heal")
    lurek.log.info("{api} ok=" .. tostring(ok))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAchievement](#lachievement)
- [LActivityFeed](#lactivityfeed)
- [LActivityFeedEntry](#lactivityfeedentry)
- [LChallenge](#lchallenge)
- [LCollection](#lcollection)
- [LLeaderboardEntry](#lleaderboardentry)
- [LPopulation](#lpopulation)
- [LPopulationProfile](#lpopulationprofile)
- [LPrestige](#lprestige)
- [LProgressionProfile](#lprogressionprofile)
- [LProgressionStore](#lprogressionstore)
- [LProgressionTransaction](#lprogressiontransaction)
- [LQuestJournal](#lquestjournal)
- [LQuestJournalEntry](#lquestjournalentry)
- [LQuestState](#lqueststate)
- [LReward](#lreward)
- [LRival](#lrival)
- [LRivalDelta](#lrivaldelta)
- [LSeason](#lseason)
- [LSeasonArchive](#lseasonarchive)
- [LStatusTracker](#lstatustracker)

## LAchievement

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAchievement:getId`

Returns the authored achievement id.

```lua
LAchievement:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Stable achievement identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "achievement_get_id_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("first_win", { title = "First Win" })
    store:unlockAchievement(profile, "first_win")
    local achievement = store:getAchievement("player", "first_win")
    lurek.log.info("LAchievement:getId id=" .. tostring(achievement:getId()) .. " title=" .. tostring(achievement:getTitle()) .. " unlocked=" .. tostring(achievement:isUnlocked()))
end
```

---

#### `LAchievement:getTitle`

Returns the authored achievement title.

```lua
LAchievement:getTitle()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Local presentation title. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "achievement_get_title_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("cartographer", { title = "Cartographer" })
    store:unlockAchievement(profile, "cartographer")
    local achievement = store:getAchievement(profile, "cartographer")
    lurek.log.info("LAchievement:getTitle title=" .. tostring(achievement:getTitle()) .. " id=" .. tostring(achievement:getId()) .. " unlocked=" .. tostring(achievement:isUnlocked()))
end
```

---

#### `LAchievement:isUnlocked`

Returns whether the achievement is currently unlocked for the owning profile.

```lua
LAchievement:isUnlocked()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the achievement was unlocked. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "achievement_is_unlocked_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("finisher", { title = "Finisher" })
    local before = store:getAchievement(profile, "finisher")
    store:unlockAchievement(profile, "finisher")
    local after = store:getAchievement("player", "finisher")
    lurek.log.info("LAchievement:isUnlocked before=" .. tostring(before:isUnlocked()) .. " after=" .. tostring(after:isUnlocked()) .. " id=" .. tostring(after:getId()))
end
```

---

## LActivityFeed

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LActivityFeed:count`

Returns the number of retained activity-feed entries in this selection.

```lua
LActivityFeed:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of feed entries currently stored in this feed snapshot. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "activity_feed_count_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("manual_reward", { title = "Manual Reward" })
    store:unlockAchievement(profile, "manual_reward")
    local feed = store:getActivityFeed({
        profiles = { profile },
        types = { "achievement_unlocked" },
        limit = 4,
    })
    lurek.log.info("LActivityFeed:count total=" .. tostring(feed:count()) .. " requested_limit=" .. tostring(feed.limit))
end
```

---

#### `LActivityFeed:listEntries`

Returns every retained activity-feed entry as typed userdata.

```lua
LActivityFeed:listEntries()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LActivityFeedEntry](#lactivityfeedentry)` userdata values. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "activity_feed_entries_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("manual_reward", { title = "Manual Reward" })
    store:unlockAchievement(profile, "manual_reward")
    local feed = store:getActivityFeed({
        profiles = { "player" },
        types = { "achievement_unlocked" },
        limit = 2,
    })
    local entries = feed:listEntries()
    lurek.log.info("LActivityFeed:listEntries total=" .. tostring(#entries) .. " first=" .. tostring(entries[1] and entries[1]:getEventType()))
end
```

---

## LActivityFeedEntry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LActivityFeedEntry:getEventType`

Returns the canonical activity event type name.

```lua
LActivityFeedEntry:getEventType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Event type such as `"achievement_unlocked"`. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "activity_feed_type_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("headline", { title = "Headline" })
    store:unlockAchievement(profile, "headline")
    local entry = store:getActivityFeed({ profiles = { profile }, limit = 1 }):listEntries()[1]
    lurek.log.info("LActivityFeedEntry:getEventType type=" .. tostring(entry:getEventType()) .. " seq=" .. tostring(entry:getSequence()))
end
```

---

#### `LActivityFeedEntry:getSequence`

Returns the retained event sequence number.

```lua
LActivityFeedEntry:getSequence()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Event sequence in feed order. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "activity_feed_sequence_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("beat", { title = "Beat" })
    store:unlockAchievement(profile, "beat")
    local entry = store:getActivityFeed({ profiles = { "player" }, limit = 1 }):listEntries()[1]
    lurek.log.info("LActivityFeedEntry:getSequence seq=" .. tostring(entry:getSequence()) .. " type=" .. tostring(entry:getEventType()))
end
```

---

## LChallenge

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LChallenge:getId`

Returns the authored challenge id.

```lua
LChallenge:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Stable challenge identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_get_id_example" })
    local profile = store:createProfile("player")
    store:defineChallengeTemplate("daily_wins", { title = "Daily Wins", required = 3, tags = { "daily" } })
    local challenge = store:activateChallenge(profile, "daily_wins")
    lurek.log.info("LChallenge:getId id=" .. tostring(challenge:getId()) .. " status=" .. tostring(challenge:getStatus()))
end
```

---

#### `LChallenge:getStatus`

Returns the current challenge lifecycle status.

```lua
LChallenge:getStatus()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"inactive"`, `"active"`, `"completed"`, or `"expired"`. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_get_status_example" })
    local profile = store:createProfile("player")
    store:defineChallengeTemplate("night_ops", { title = "Night Ops", required = 2, tags = { "weekly" } })
    store:activateChallenge(profile, "night_ops")
    local challenge = store:setChallengeProgress("player", "night_ops", 1)
    lurek.log.info("LChallenge:getStatus id=" .. tostring(challenge:getId()) .. " status=" .. tostring(challenge:getStatus()))
end
```

---

## LCollection

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCollection:getId`

Returns the authored collection id.

```lua
LCollection:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Stable collection identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "collection_get_id_example" })
    local profile = store:createProfile("player")
    store:defineCollection("field_notes", { title = "Field Notes", items = { { id = "entry_a", title = "Entry A" } } })
    local collection = store:collectCollectionItem(profile, "field_notes", "entry_a")
    lurek.log.info("LCollection:getId id=" .. tostring(collection:getId()) .. " complete=" .. tostring(collection:isComplete()))
end
```

---

#### `LCollection:isComplete`

Returns whether every collection item is currently collected.

```lua
LCollection:isComplete()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the collection is complete. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "collection_is_complete_example" })
    local profile = store:createProfile("player")
    store:defineCollection("museum", { title = "Museum", items = { { id = "artifact", title = "Artifact" } } })
    local before = store:getCollection(profile, "museum")
    local after = store:collectCollectionItem("player", "museum", "artifact")
    lurek.log.info("LCollection:isComplete before=" .. tostring(before:isComplete()) .. " after=" .. tostring(after:isComplete()) .. " id=" .. tostring(after:getId()))
end
```

---

## LLeaderboardEntry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LLeaderboardEntry:getLeaderboardId`

Returns the leaderboard that produced this row.

```lua
LLeaderboardEntry:getLeaderboardId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Leaderboard identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "leaderboard_get_lb_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 7)
    local entry = store:getLeaderboardEntry("alpha", "arena")
    lurek.log.info("LLeaderboardEntry:getLeaderboardId leaderboard=" .. tostring(entry:getLeaderboardId()) .. " profile=" .. tostring(entry:getProfileId()))
end
```

---

#### `LLeaderboardEntry:getProfileId`

Returns the profile that owns this row.

```lua
LLeaderboardEntry:getProfileId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Profile identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "leaderboard_get_profile_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("beta", "arena", 5)
    local entry = store:getLeaderboardEntry("beta", "arena")
    lurek.log.info("LLeaderboardEntry:getProfileId profile=" .. tostring(entry:getProfileId()) .. " leaderboard=" .. tostring(entry:getLeaderboardId()))
end
```

---

#### `LLeaderboardEntry:getRank`

Returns the one-based rank currently assigned to this row.

```lua
LLeaderboardEntry:getRank()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Deterministic rank for the current ordering. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "leaderboard_get_rank_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    local entry = store:submitScore("beta", "arena", 3)
    lurek.log.info("LLeaderboardEntry:getRank rank=" .. tostring(entry:getRank()) .. " profile=" .. tostring(entry:getProfileId()))
end
```

---

## LPopulation

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPopulation:getId`

Returns the population id.

```lua
LPopulation:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Population identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_get_id_example", seed = 42 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("citizens", {
        id_prefix = "citizen_",
        count = 3,
        identity = { name_generator = { mode = "parts", prefixes = { "North" }, suffixes = { "Vale", "Gate" } }, tags = { "npc" } },
        archetypes = { { id = "worker", weight = 1, activity = { min = 1, max = 2 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    local pop = store:generatePopulation("citizens", { id = "city_pop" })
    local stats = store:getPopulationStatistics("city_pop")
    lurek.log.info("LPopulation:getId id=" .. tostring(pop:getId()) .. " paused=" .. tostring(pop:isPaused()) .. " active=" .. tostring(stats.active_count))
end
```

---

#### `LPopulation:isPaused`

Returns whether logical simulation for this population is paused.

```lua
LPopulation:isPaused()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when updates are paused. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_is_paused_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("visitors", {
        id_prefix = "visitor_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "East" }, suffixes = { "Pier", "Row" } }, tags = { "guest" } },
        archetypes = { { id = "guest", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 980, deviation = 5 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 1, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("visitors", { id = "camp" })
    store:pausePopulation("camp")
    local pop = store:getPopulation("camp")
    lurek.log.info("LPopulation:isPaused paused=" .. tostring(pop:isPaused()) .. " id=" .. tostring(pop:getId()))
end
```

---

## LPopulationProfile

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPopulationProfile:getProfileId`

Returns the virtual profile id.

```lua
LPopulationProfile:getProfileId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Virtual profile identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_profile_get_id_example", seed = 11 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox", "Wing" } }, tags = { "bot" } },
        archetypes = { { id = "runner", weight = 1, activity = { min = 1, max = 2 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bot_pack" })
    local profile = store:listPopulationProfiles("bot_pack", { limit = 1 })[1]
    lurek.log.info("LPopulationProfile:getProfileId profile=" .. tostring(profile:getProfileId()) .. " materialized=" .. tostring(profile:isMaterialized()))
end
```

---

#### `LPopulationProfile:isMaterialized`

Returns whether this virtual profile is materialized as a normal store profile.

```lua
LPopulationProfile:isMaterialized()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the virtual profile was materialized. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_profile_materialized_example", seed = 12 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("pilots", {
        id_prefix = "pilot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Sky" }, suffixes = { "Ace" } }, tags = { "pilot" } },
        archetypes = { { id = "ace", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1025, deviation = 0 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 1, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("pilots", { id = "pilot_pack" })
    local before = store:listPopulationProfiles("pilot_pack", { limit = 1 })[1]
    store:materializePopulationProfile(before:getProfileId())
    local after = store:listPopulationProfiles("pilot_pack", { limit = 1 })[1]
    lurek.log.info("LPopulationProfile:isMaterialized before=" .. tostring(before:isMaterialized()) .. " after=" .. tostring(after:isMaterialized()) .. " profile=" .. tostring(after:getProfileId()))
end
```

---

## LPrestige

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPrestige:getId`

Returns the authored prestige id.

```lua
LPrestige:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Prestige identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_get_id_example" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:addCounter(profile, "wins", 3)
    store:definePrestige("rebirth", { condition = { counter = "wins", op = ">=", value = 1 }, reset = { counters = { "wins" }, level_tracks = {} }, preserve = { achievements = true, lifetime_counters = true } })
    local prestige = store:getPrestige("player", "rebirth")
    lurek.log.info("LPrestige:getId id=" .. tostring(prestige:getId()) .. " available=" .. tostring(prestige:isAvailable()))
end
```

---

#### `LPrestige:isAvailable`

Returns whether the owning profile currently satisfies the prestige condition.

```lua
LPrestige:isAvailable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the prestige is currently available. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_is_available_example" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:definePrestige("rebirth", { condition = { counter = "wins", op = ">=", value = 2 }, reset = { counters = { "wins" }, level_tracks = {} }, preserve = { achievements = true, lifetime_counters = true } })
    local before = store:getPrestige(profile, "rebirth")
    store:addCounter("player", "wins", 2)
    local after = store:getPrestige("player", "rebirth")
    lurek.log.info("LPrestige:isAvailable before=" .. tostring(before:isAvailable()) .. " after=" .. tostring(after:isAvailable()) .. " id=" .. tostring(after:getId()))
end
```

---

## LProgressionProfile

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProgressionProfile:getId`

Returns the id.

```lua
LProgressionProfile:getId()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_getid" })
    local profile = store:createProfile("player")
    local pid = profile:getId()
    local kind = profile:type()
    lurek.log.info("LProgressionProfile:getId id=" .. tostring(pid) .. " kind=" .. tostring(kind) .. " ok=" .. tostring(profile:typeOf("LProgressionProfile")))
end
```

---

#### `LProgressionProfile:getPendingRewards`

Returns this profile's pending reward records as typed reward handles.

```lua
LProgressionProfile:getPendingRewards()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LReward](#lreward)` values still waiting for claim. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_getpendingrewards" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local rewards = profile:getPendingRewards()
    local reward = rewards[1]
    lurek.log.info("LProgressionProfile:getPendingRewards total=" .. tostring(#rewards) .. " reward=" .. tostring(reward:getId()) .. " state=" .. tostring(reward:getState()))
end
```

---

#### `LProgressionProfile:type`

Type.

```lua
LProgressionProfile:type()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_type" })
    local profile = store:createProfile("player")
    local pid = profile:getId()
    local kind = profile:type()
    lurek.log.info("LProgressionProfile:type id=" .. tostring(pid) .. " kind=" .. tostring(kind) .. " ok=" .. tostring(profile:typeOf("LProgressionProfile")))
end
```

---

#### `LProgressionProfile:typeOf`

Type of.

```lua
LProgressionProfile:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_typeof" })
    local profile = store:createProfile("player")
    local pid = profile:getId()
    local kind = profile:type()
    lurek.log.info("LProgressionProfile:typeOf id=" .. tostring(pid) .. " kind=" .. tostring(kind) .. " ok=" .. tostring(profile:typeOf("LProgressionProfile")))
end
```

---

## LProgressionStore

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProgressionStore:acceptQuest`

Returns the pending rewards.

```lua
LProgressionStore:acceptQuest(profile, quest_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_acceptquest" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:acceptQuest profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:ackChangesThrough`

Ack changes through.

```lua
LProgressionStore:ackChangesThrough(revision)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `revision` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changeset_ack_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 1)
    local first = lurek.serialize.fromJson(source:exportChangesSince(0))[1]
    local ack = source:ackChangesThrough(first.revision)
    lurek.log.info("ackChangesThrough removed=" .. tostring(ack.removedCount) .. " remaining=" .. tostring(ack.remainingCount))
end
```

---

#### `LProgressionStore:acquirePerk`

```lua
LProgressionStore:acquirePerk(profile, perk_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `perk_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_acquireperk" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:acquirePerk profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:activateChallenge`

```lua
LProgressionStore:activateChallenge(profile, challenge_id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `challenge_id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_activate_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        required = 3,
        counter_id = "wins",
        reward_payload = { currency = 25 },
    })
    local started = store:activateChallenge(player, "win_streak")
    lurek.log.info("activateChallenge status=" .. tostring(started.status) .. " current=" .. tostring(started.current))
end
```

---

#### `LProgressionStore:addAttributeBase`

```lua
LProgressionStore:addAttributeBase(profile, attribute_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `attribute_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addattributebase" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addAttributeBase profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:addCounter`

```lua
LProgressionStore:addCounter(profile, counter_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `counter_id` | any |  |
| `amount?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addcounter" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addCounter profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:addExperience`

```lua
LProgressionStore:addExperience(profile, track_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addexperience" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addExperience profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:addModifier`

```lua
LProgressionStore:addModifier(profile, target_id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `target_id` | any |  |
| `opts` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addmodifier" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addModifier profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:addProfileTag`

Adds profile tag.

```lua
LProgressionStore:addProfileTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `tag` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addprofiletag" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addProfileTag profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:addResource`

```lua
LProgressionStore:addResource(profile, resource_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:advanceTime`

Advance time.

```lua
LProgressionStore:advanceTime(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_advancetime" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:advanceTime profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:applyChangeset`

Apply changeset.

```lua
LProgressionStore:applyChangeset(changeset)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `changeset` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "apply_changeset_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 3)
    local changes = source:exportChangesSince(0)
    local target = lurek.progression.newStore({ id = "apply_changeset_target" })
    local report = target:applyChangeset(changes)
    lurek.log.info("LProgressionStore:applyChangeset applied=" .. tostring(report.applied) .. " wins=" .. tostring(target:getCounter("player", "wins")))
end
```

---

#### `LProgressionStore:applyChangesetEnvelope`

```lua
LProgressionStore:applyChangesetEnvelope(changeset, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `changeset` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changeset_reject_source" })
    local oversized = lurek.serialize.toJson({
        schema_version = source:getSchemaVersion(),
        definition_hash = source:getDefinitionHash(),
        from_revision = 0,
        to_revision = 1,
        truncated = false,
        records = {
            {
                revision = 1,
                snapshot = {
                    blob = string.rep("x", 300000),
                },
            },
        },
    })
    local ok, err = pcall(function()
        source:applyChangesetEnvelope(oversized, {
            require_definition_hash_match = true,
            require_schema_match = true,
        })
    end)
    lurek.log.info("applyChangesetEnvelope oversized_ok=" .. tostring(ok) .. " err=" .. tostring(err))
end
```

---

#### `LProgressionStore:applyPrestige`

```lua
LProgressionStore:applyPrestige(profile, prestige_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `prestige_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_apply_example" })
    local player = store:createProfile("player")
    store:defineCounter("campaign_kills", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", {
        condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        reset = { level_tracks = { "character_xp" }, counters = { "campaign_kills" } },
        preserve = { lifetime_counters = true },
    })
    store:setLevel(player, "character_xp", 100)
    store:addCounter("player", "campaign_kills", 42)
    local prestige = store:applyPrestige(player, "career")
    lurek.log.info("applyPrestige count=" .. tostring(prestige.count) .. " kills=" .. tostring(store:getCounter("player", "campaign_kills")) .. " lifetime=" .. tostring(prestige.lifetime_counters.campaign_kills))
end
```

---

#### `LProgressionStore:applyProfileTemplate`

```lua
LProgressionStore:applyProfileTemplate(profile, template_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `template_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_applyprofiletemplate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:applyProfileTemplate profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:applyTrait`

```lua
LProgressionStore:applyTrait(profile, trait_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `trait_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_applytrait" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:applyTrait profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:beginTransaction`

```lua
LProgressionStore:beginTransaction(options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "transaction_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    local tx = store:beginTransaction({ id = "match_1" })
    tx:addCounter(player, "wins", 1)
    tx:setResource("player", "focus", 2)
    local summary = tx:commit()
    lurek.log.info("beginTransaction revision=" .. tostring(summary.revision) .. " changes=" .. tostring(summary.changes) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end
```

---

#### `LProgressionStore:canPrestige`

```lua
LProgressionStore:canPrestige(profile, prestige_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `prestige_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_can_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", { condition = { level = { track = "character_xp", op = ">=", value = 100 } } })
    local before = store:canPrestige(player, "career")
    store:setLevel("player", "character_xp", 100)
    local after = store:canPrestige("player", "career")
    lurek.log.info("canPrestige before=" .. tostring(before) .. " after=" .. tostring(after) .. " level=" .. tostring(store:getLevel("player", "character_xp")))
end
```

---

#### `LProgressionStore:canSpendResource`

```lua
LProgressionStore:canSpendResource(profile, resource_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_canspendresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:canSpendResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:clear`

Clears the state.

```lua
LProgressionStore:clear()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_clear" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:clear profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:clearEvents`

Clears events.

```lua
LProgressionStore:clearEvents()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_clearevents" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:clearEvents profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:collectCollectionItem`

```lua
LProgressionStore:collectCollectionItem(profile, collection_id, item_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `collection_id` | any |  |
| `item_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "collection_collect_example" })
    local player = store:createProfile("player")
    store:defineAchievement("boss_slayer", { title = "Boss Slayer" })
    store:defineAchievement("museum_complete", { title = "Museum Complete" })
    store:defineCollection("museum", {
        title = "Museum",
        meta_achievement_id = "museum_complete",
        items = {
            { id = "boss_trophy", title = "Boss Trophy", achievement_id = "boss_slayer" },
            { id = "secret_codex", title = "Secret Codex", hidden = true },
        },
    })
    store:unlockAchievement(player, "boss_slayer")
    local collection = store:collectCollectionItem(player, "museum", "secret_codex")
    lurek.log.info("collectCollectionItem completion=" .. tostring(collection.completion) .. " meta=" .. tostring(store:getAchievement("player", "museum_complete").unlocked))
end
```

---

#### `LProgressionStore:compactChanges`

Compact changes.

```lua
LProgressionStore:compactChanges(max_records)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_records` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changeset_compact_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 1)
    local compact = source:compactChanges(1)
    lurek.log.info("compactChanges after=" .. tostring(compact.afterCount) .. " removed=" .. tostring(compact.removedCount))
end
```

---

#### `LProgressionStore:compileCondition`

Compile condition.

```lua
LProgressionStore:compileCondition(condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `condition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "condition_example" })
    local player = store:createProfile("player", { tags = { "hero" } })
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    local condition = {
        all = {
            { tag = "hero" },
            { counter = "wins", op = ">=", value = 2 },
        },
    }
    local compiled = store:compileCondition(condition)
    store:addCounter(player, "wins", 2)
    local ok = store:evaluateCondition("player", condition)
    local explanation = store:explainCondition(player, condition)
    lurek.log.info("compileCondition kind=" .. tostring(compiled.kind) .. " ok=" .. tostring(ok) .. " children=" .. tostring(#explanation.children))
end
```

---

#### `LProgressionStore:completeQuest`

```lua
LProgressionStore:completeQuest(profile, quest_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_manual_example" })
    local player = store:createProfile("player")
    store:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Clear", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    store:acceptQuest(player, "cleanup")
    store:completeQuest("player", "cleanup")
    local quest = store:getQuestState(player, "cleanup")
    lurek.log.info("completeQuest status=" .. tostring(quest.status))
end
```

---

#### `LProgressionStore:countProfiles`

Returns the number of items.

```lua
LProgressionStore:countProfiles()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_countprofiles" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:countProfiles profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:createProfile`

```lua
LProgressionStore:createProfile(id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "profile_example" })
    local profile = store:createProfile("player", {
        kind = "human",
        display_name = "Mira",
        tags = { "local", "campaign_a" },
        metadata = { country = "PL", runs = 3 },
    })
    local snapshot = store:getProfile("player")
    lurek.log.info("createProfile id=" .. tostring(profile:getId()) .. " name=" .. tostring(snapshot.display_name) .. " tags=" .. tostring(#snapshot.tags))
end
```

---

#### `LProgressionStore:debugSnapshot`

Debug snapshot.

```lua
LProgressionStore:debugSnapshot()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_debugsnapshot" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:debugSnapshot profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:defineAchievement`

```lua
LProgressionStore:defineAchievement(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "achievement_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", {
        kind = "cumulative_integer",
        initial = 0,
        min = 0,
        monotonic = true,
    })
    store:defineAchievement("first_win", {
        title = "First Win",
        description = "Win one match",
        counter_trigger = {
            counter_id = "wins",
            op = ">=",
            value = 1,
        },
        reward_payload = {
            currency = 100,
        },
    })
    store:addCounter(player, "wins", 1)
    local achievement = store:getAchievement("player", "first_win")
    local rewards = player:getPendingRewards()
    lurek.log.info("defineAchievement unlocked=" .. tostring(achievement.unlocked) .. " rewards=" .. tostring(#rewards))
end
```

---

#### `LProgressionStore:defineAttribute`

```lua
LProgressionStore:defineAttribute(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "attribute_example" })
    local player = store:createProfile("player")
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:setAttributeBase(player, "strength", 12)
    local modifier = store:addModifier(player, "strength", { value = 3, layer = "final_add", duration = 30 })
    local effective = store:getAttribute(player, "strength", "effective")
    local explanation = store:explainAttribute("player", "strength")
    lurek.log.info("defineAttribute mod=" .. tostring(modifier) .. " effective=" .. tostring(effective) .. " delta=" .. tostring(explanation.modifier_total))
end
```

---

#### `LProgressionStore:defineChallengeTemplate`

```lua
LProgressionStore:defineChallengeTemplate(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_define_example" })
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        description = "Win three matches",
        required = 3,
        counter_id = "wins",
        tags = { "daily" },
        reward_payload = { currency = 25 },
    })
    store:createProfile("player")
    local challenge = store:getChallenge("player", "win_streak")
    lurek.log.info("defineChallengeTemplate id=" .. tostring(challenge.id) .. " status=" .. tostring(challenge.status) .. " tag=" .. tostring(challenge.tags[1]))
end
```

---

#### `LProgressionStore:defineCollection`

```lua
LProgressionStore:defineCollection(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "collection_define_example" })
    local player = store:createProfile("player")
    store:defineAchievement("boss_slayer", { title = "Boss Slayer" })
    store:defineAchievement("museum_complete", { title = "Museum Complete" })
    store:defineCollection("museum", {
        title = "Museum",
        description = "Collect lore and trophies",
        meta_achievement_id = "museum_complete",
        items = {
            { id = "boss_trophy", title = "Boss Trophy", achievement_id = "boss_slayer" },
            { id = "secret_codex", title = "Secret Codex", hidden = true },
        },
    })
    local collection = store:getCollection(player, "museum")
    lurek.log.info("defineCollection items=" .. tostring(collection.total_count) .. " title=" .. tostring(collection.title) .. " complete=" .. tostring(collection.complete))
end
```

---

#### `LProgressionStore:defineCounter`

```lua
LProgressionStore:defineCounter(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "counter_example" })
    local player = store:createProfile("player")
    store:defineCounter("rats_killed", {
        kind = "cumulative_integer",
        initial = 0,
        min = 0,
        monotonic = true,
        thresholds = { 3, 5 },
    })
    local after_add = store:addCounter(player, "rats_killed", 4)
    local counter = store:getCounterState("player", "rats_killed")
    lurek.log.info("defineCounter value=" .. tostring(after_add) .. " snapshot=" .. tostring(counter.value))
end
```

---

#### `LProgressionStore:defineDerivedValue`

```lua
LProgressionStore:defineDerivedValue(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "derived_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    store:addCounter(player, "wins", 3)
    store:setAttributeBase("player", "strength", 12)
    store:addResource("player", "stamina", -2)
    store:addExperience("player", "character_xp", 180)
    store:defineDerivedValue("combat_rating", {
        expression = "round((wins * 5 + strength + stamina + level) / 2)",
        inputs = {
            wins = { kind = "counter", counter_id = "wins" },
            strength = { kind = "attribute", attribute_id = "strength", mode = "effective" },
            stamina = { kind = "resource", resource_id = "stamina" },
            level = { kind = "level", track_id = "character_xp" },
        },
        min = 0,
    })
    local value = store:getDerivedValue(player, "combat_rating")
    local explanation = store:explainDerivedValue("player", "combat_rating")
    lurek.log.info("defineDerivedValue value=" .. tostring(value) .. " wins=" .. tostring(explanation.inputs.wins))
end
```

---

#### `LProgressionStore:defineLeaderboard`

```lua
LProgressionStore:defineLeaderboard(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "leaderboard_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:createProfile("gamma")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", {
        title = "Arena",
        sort = "descending",
        rank_mode = "competition",
        max_entries = 10,
        counter_id = "wins",
    })
    store:addCounter("alpha", "wins", 5)
    store:addCounter("beta", "wins", 5)
    store:addCounter("gamma", "wins", 3)
    local top = store:listLeaderboardTop("arena", 3)
    local around = store:listLeaderboardAroundProfile("arena", "beta", 1, 1)
    local promoted = store:submitScore("gamma", "arena", 8)
    lurek.log.info("defineLeaderboard first=" .. tostring(top[1] and top[1].profile_id) .. " center=" .. tostring(around[2] and around[2].profile_id) .. " promoted_rank=" .. tostring(promoted.rank))
end
```

---

#### `LProgressionStore:defineLevelTrack`

```lua
LProgressionStore:defineLevelTrack(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "level_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
        allow_level_down = false,
    })
    local xp = store:addExperience(player, "character_xp", 180)
    local to_next = store:getExperienceToNextLevel("player", "character_xp")
    lurek.log.info("defineLevelTrack level=" .. tostring(xp.level) .. " xp=" .. tostring(xp.experience) .. " to_next=" .. tostring(to_next))
end
```

---

#### `LProgressionStore:definePerk`

```lua
LProgressionStore:definePerk(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_defineperk" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:definePerk profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:definePopulationTemplate`

```lua
LProgressionStore:definePopulationTemplate(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_define_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 3,
        identity = {
            name_generator = { mode = "parts", prefixes = { "Iron", "Silver" }, suffixes = { "Fox", "Wing" } },
            avatars = { "bots/a.png", "bots/b.png" },
            tags = { "bot", "ranked" },
        },
        archetypes = {
            { id = "steady", weight = 2, activity = { min = 1, max = 2 }, skill = { mean = 1200, deviation = 20 } },
            { id = "volatile", weight = 1, activity = { min = 2, max = 4 }, skill = { mean = 1180, deviation = 35 } },
        },
        leaderboards = {
            arena = {
                category = "ranked",
                initial_score = { distribution = "normal" },
                progression = { mode = "bounded_random_walk", volatility = 4, mean_reversion = 0.2 },
            },
        },
    })
    local report = store:validatePopulationTemplate("bots")
    lurek.log.info("definePopulationTemplate ok=" .. tostring(report.ok) .. " errors=" .. tostring(#report.errors) .. " definitions=" .. tostring(store:stats().populationTemplates))
end
```

---

#### `LProgressionStore:definePrestige`

```lua
LProgressionStore:definePrestige(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_define_example" })
    local profile = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:defineCounter("campaign_kills", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:definePrestige("career", {
        condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        reset = { level_tracks = { "character_xp" }, counters = { "campaign_kills" } },
        preserve = { achievements = true, lifetime_counters = true },
    })
    local prestige = store:getPrestige(profile, "career")
    lurek.log.info("definePrestige id=" .. tostring(prestige.id) .. " resets=" .. tostring(#prestige.reset.counters) .. " keep_achievements=" .. tostring(prestige.preserve.achievements))
end
```

---

#### `LProgressionStore:defineProfileTemplate`

```lua
LProgressionStore:defineProfileTemplate(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "template_example" })
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:defineResource("stamina", { initial = 2, min = 0, max = 10, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    store:defineProfileTemplate("veteran_scout", {
        kind = "scout",
        counters = { wins = 4 },
        attributes = { strength = 14 },
        resources = { stamina = 7 },
        experience = { character_xp = 180 },
        tags = { "veteran" },
        metadata = { origin = "frontier" },
    })
    store:createProfile("player", { display_name = "Mira", template = "veteran_scout" })
    local snapshot = store:getProfile("player")
    lurek.log.info("defineProfileTemplate kind=" .. tostring(snapshot.kind) .. " origin=" .. tostring(snapshot.metadata.origin) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end
```

---

#### `LProgressionStore:defineQuest`

```lua
LProgressionStore:defineQuest(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_example" })
    local player = store:createProfile("player", { tags = { "hero" } })
    store:defineCounter("rats_killed", {
        kind = "cumulative_integer",
        initial = 0,
        min = 0,
        monotonic = true,
    })
    store:defineQuest("rat_hunt", {
        title = "Rat Hunt",
        reveal_condition = {
            tag = "hero",
        },
        availability_condition = {
            tag = "hero",
        },
        reward_payload = {
            currency = 50,
        },
        stages = {
            {
                id = "stage_1",
                name = "Cull",
                objectives = {
                    { id = "kills", description = "Defeat three rats", required = 3, mandatory = true, counter_id = "rats_killed" },
                },
            },
        },
    })
    store:acceptQuest(player, "rat_hunt")
    store:addCounter(player, "rats_killed", 3)
    local quest = store:getQuestState("player", "rat_hunt")
    local rewards = player:getPendingRewards()
    lurek.log.info("defineQuest status=" .. tostring(quest.status) .. " stage=" .. tostring(quest.current_stage_index) .. " rewards=" .. tostring(#rewards))
end
```

---

#### `LProgressionStore:defineResource`

```lua
LProgressionStore:defineResource(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "resource_example" })
    local player = store:createProfile("player")
    store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
    local spent = store:spendResource(player, "stamina", 2)
    local resource = store:getResource("player", "stamina")
    local refilled = store:refillResource(player, "stamina")
    lurek.log.info("defineResource spent=" .. tostring(spent) .. " value=" .. tostring(resource.value) .. " refilled=" .. tostring(refilled))
end
```

---

#### `LProgressionStore:defineSeason`

```lua
LProgressionStore:defineSeason(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_define_example" })
    store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal", counter_id = "season_wins" })
    store:defineSeason("arena_s1", {
        starts_at = 0,
        ends_at = 100,
        reset = { leaderboards = { "arena" }, counters = { "season_wins" } },
        archive = true,
    })
    local season = store:getSeason("arena_s1")
    lurek.log.info("defineSeason id=" .. tostring(season.id) .. " archives=" .. tostring(season.archive_count) .. " resets=" .. tostring(#season.reset.counters))
end
```

---

#### `LProgressionStore:defineSkill`

```lua
LProgressionStore:defineSkill(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "skill_example" })
    store:createProfile("player")
    store:defineAttribute("mana", { base = 100, min = 0, max = 100 })
    store:setAttributeBase("player", "mana", 100)
    store:defineSkill("heal", {
        max_level = 5,
        resource = "mana",
        cost = 30,
        cooldown = 5,
    })
    store:learnSkill("player", "heal")
    local used = store:useSkill("player", "heal")
    store:update(3)
    lurek.log.info("defineSkill ok=" .. tostring(used.ok) .. " mana=" .. tostring(store:getAttribute("player", "mana", "base")) .. " cooldown=" .. tostring(store:getSkillCooldown("player", "heal")))
end
```

---

#### `LProgressionStore:defineTrait`

```lua
LProgressionStore:defineTrait(id, definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `definition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "trait_perk_example" })
    store:createProfile("player")
    store:defineAttribute("hp", { base = 100, min = 0, max = 999 })
    store:defineLevelTrack("__legacy_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 100 },
        carry_over = true,
    })
    store:defineTrait("tough", {
        modifiers = {
            { target_id = "hp", value = 20, layer = "final_add" },
        },
    })
    store:definePerk("iron_skin", {
        require_level = 3,
        track_id = "__legacy_xp",
        trait_ids = { "tough" },
    })
    store:applyTrait("player", "tough")
    store:removeTrait("player", "tough")
    store:setLevel("player", "__legacy_xp", 3)
    store:acquirePerk("player", "iron_skin")
    lurek.log.info("defineTrait hp=" .. tostring(store:getAttribute("player", "hp", "effective")) .. " has_perk=" .. tostring(store:hasPerk("player", "iron_skin")))
end
```

---

#### `LProgressionStore:dematerializePopulationProfile`

```lua
LProgressionStore:dematerializePopulationProfile(profile_id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile_id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_dematerialize_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local virtual_profile = store:listPopulationProfiles("bots_run")[1]
    store:materializePopulationProfile(virtual_profile.profile_id)
    local changed = store:dematerializePopulationProfile(virtual_profile.profile_id, { remove_profile = true })
    local remaining = store:listPopulationProfiles("bots_run", { materialized = false })
    lurek.log.info("dematerializePopulationProfile changed=" .. tostring(changed) .. " has_profile=" .. tostring(store:hasProfile(virtual_profile.profile_id)) .. " visible=" .. tostring(#remaining))
end
```

---

#### `LProgressionStore:drainEvents`

Drain events.

```lua
LProgressionStore:drainEvents()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_drainevents" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:drainEvents profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:endSeason`

```lua
LProgressionStore:endSeason(id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_end_example" })
    store:createProfile("alpha")
    store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal", counter_id = "season_wins" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, reset = { leaderboards = { "arena" }, counters = { "season_wins" } }, archive = true })
    store:startSeason("arena_s1", { time = 0 })
    store:addCounter("alpha", "season_wins", 4)
    local ended = store:endSeason("arena_s1", { time = 100 })
    lurek.log.info("endSeason active=" .. tostring(ended.active) .. " wins=" .. tostring(store:getCounter("alpha", "season_wins")) .. " top=" .. tostring(#store:listLeaderboardTop("arena", 3)))
end
```

---

#### `LProgressionStore:ensureProfile`

```lua
LProgressionStore:ensureProfile(id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_ensureprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:ensureProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:evaluateCondition`

```lua
LProgressionStore:evaluateCondition(profile, condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `condition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_evaluatecondition" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:evaluateCondition profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:explainAttribute`

```lua
LProgressionStore:explainAttribute(profile, attribute_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `attribute_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_explainattribute" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:explainAttribute profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:explainCondition`

```lua
LProgressionStore:explainCondition(profile, condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `condition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_explaincondition" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:explainCondition profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:explainDerivedValue`

```lua
LProgressionStore:explainDerivedValue(profile, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_explainderivedvalue" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:explainDerivedValue profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:exportChangesSince`

Export changes since.

```lua
LProgressionStore:exportChangesSince(revision)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `revision` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changes_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 3)
    local changes = source:exportChangesSince(0)
    local target = lurek.progression.newStore({ id = "changes_target" })
    local applied = target:applyChangeset(changes)
    lurek.log.info("exportChangesSince applied=" .. tostring(applied.applied) .. " wins=" .. tostring(target:getCounter("player", "wins")))
end
```

---

#### `LProgressionStore:exportChangeset`

```lua
LProgressionStore:exportChangeset(revision, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `revision` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changeset_export_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 2)
    source:addCounter(profile, "wins", 3)
    local envelope = lurek.serialize.fromJson(source:exportChangeset(0, { max_records = 2 }))
    lurek.log.info("exportChangeset truncated=" .. tostring(envelope.truncated) .. " count=" .. tostring(#envelope.records) .. " to=" .. tostring(envelope.to_revision))
end
```

---

#### `LProgressionStore:exportSnapshot`

Export snapshot.

```lua
LProgressionStore:exportSnapshot()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_exportsnapshot" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:exportSnapshot profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:failQuest`

```lua
LProgressionStore:failQuest(profile, quest_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_failquest" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:failQuest profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:generatePopulation`

```lua
LProgressionStore:generatePopulation(template_id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `template_id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_generate_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox", "Wing" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 2 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    local population = store:generatePopulation("bots", { id = "bots_run" })
    lurek.log.info("generatePopulation id=" .. tostring(population.id) .. " active=" .. tostring(population.active_count) .. " materialized=" .. tostring(population.materialized_count))
end
```

---

#### `LProgressionStore:getAchievement`

```lua
LProgressionStore:getAchievement(profile, achievement_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `achievement_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getachievement" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getAchievement profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getActivityFeed`

Returns one typed activity-feed selection object.

```lua
LProgressionStore:getActivityFeed(query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "activity_feed_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:submitScore(player, "arena", 5)
    store:submitScore(rival, "arena", 6)
    store:pinRival(player, rival, { leaderboard_id = "arena" })
    store:submitScore("player", "arena", 8)
    local feed = store:getActivityFeed({
        profiles = { player, rival },
        types = { "profile_overtook_rival", "rival_overtook_profile" },
        limit = 10,
    })
    local entries = feed:listEntries()
    lurek.log.info("getActivityFeed total=" .. tostring(feed:count()) .. " last=" .. tostring(entries[#entries] and entries[#entries]:getEventType()))
end
```

---

#### `LProgressionStore:getAttribute`

```lua
LProgressionStore:getAttribute(profile, attribute_id, mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `attribute_id` | any |  |
| `mode?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getattribute" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getAttribute profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getAttributeState`

```lua
LProgressionStore:getAttributeState(profile, attribute_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `attribute_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getattributestate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getAttributeState profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getChallenge`

```lua
LProgressionStore:getChallenge(profile, challenge_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `challenge_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_get_example" })
    local player = store:createProfile("player")
    store:defineChallengeTemplate("timed_route", {
        title = "Timed Route",
        required = 1,
        duration = 5,
        repeatable = true,
    })
    store:activateChallenge(player, "timed_route", { time = 0 })
    store:advanceTime(6)
    local challenge = store:getChallenge("player", "timed_route")
    lurek.log.info("getChallenge status=" .. tostring(challenge.status) .. " expires_in=" .. tostring(challenge.expires_in))
end
```

---

#### `LProgressionStore:getCollection`

```lua
LProgressionStore:getCollection(profile, collection_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `collection_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "collection_get_example" })
    local player = store:createProfile("player")
    store:defineCollection("museum", {
        title = "Museum",
        items = {
            { id = "entry_a", title = "Entry A" },
            { id = "entry_b", title = "Entry B", hidden = true },
        },
    })
    local collection = store:getCollection(player, "museum")
    lurek.log.info("getCollection visible=" .. tostring(collection.items[1].title) .. " hidden=" .. tostring(collection.items[2].title) .. " completion=" .. tostring(collection.completion))
end
```

---

#### `LProgressionStore:getCounter`

```lua
LProgressionStore:getCounter(profile, counter_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `counter_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getcounter" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getCounter profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getCounterState`

```lua
LProgressionStore:getCounterState(profile, counter_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `counter_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getcounterstate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getCounterState profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getDefinitionHash`

Returns the definition hash.

```lua
LProgressionStore:getDefinitionHash()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getdefinitionhash" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getDefinitionHash profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getDerivedValue`

```lua
LProgressionStore:getDerivedValue(profile, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getderivedvalue" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getDerivedValue profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getExperience`

```lua
LProgressionStore:getExperience(profile, track_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getexperience" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getExperience profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getExperienceToNextLevel`

```lua
LProgressionStore:getExperienceToNextLevel(profile, track_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getexperiencetonextlevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getExperienceToNextLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getId`

Returns the id.

```lua
LProgressionStore:getId()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getid" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getId profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getLeaderboardEntry`

```lua
LProgressionStore:getLeaderboardEntry(profile, leaderboard_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `leaderboard_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getleaderboardentry" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getLeaderboardEntry profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getLevel`

```lua
LProgressionStore:getLevel(profile, track_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getlevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getPopulation`

Returns the population.

```lua
LProgressionStore:getPopulation(handle_or_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_get_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local population = store:getPopulation("bots_run")
    lurek.log.info("getPopulation profiles=" .. tostring(#population.profiles) .. " paused=" .. tostring(population.paused) .. " time=" .. tostring(population.logical_time))
end
```

---

#### `LProgressionStore:getPopulationStatistics`

```lua
LProgressionStore:getPopulationStatistics(handle_or_id, query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |
| `query?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_stats_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local stats = store:getPopulationStatistics("bots_run", { leaderboard_id = "arena" })
    lurek.log.info("getPopulationStatistics count=" .. tostring(stats.leaderboards.arena.count) .. " min=" .. tostring(stats.leaderboards.arena.min) .. " max=" .. tostring(stats.leaderboards.arena.max))
end
```

---

#### `LProgressionStore:getPrestige`

```lua
LProgressionStore:getPrestige(profile, prestige_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `prestige_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_get_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", { condition = { level = { track = "character_xp", op = ">=", value = 100 } } })
    local prestige = store:getPrestige(player, "career")
    local stats = store:stats()
    lurek.log.info("getPrestige count=" .. tostring(prestige.count) .. " available=" .. tostring(prestige.available) .. " definitions=" .. tostring(stats.prestigeDefinitions))
end
```

---

#### `LProgressionStore:getProfile`

Returns the profile.

```lua
LProgressionStore:getProfile(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getQuestState`

```lua
LProgressionStore:getQuestState(profile, quest_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getqueststate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getQuestState profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getResource`

```lua
LProgressionStore:getResource(profile, resource_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getRevision`

Returns the revision.

```lua
LProgressionStore:getRevision()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getrevision" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getRevision profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getRival`

```lua
LProgressionStore:getRival(profile, rival_profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `rival_profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_get_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:submitScore(player, "arena", 5)
    store:submitScore(rival, "arena", 6)
    store:pinRival(player, rival, { leaderboard_id = "arena" })
    local snapshot = store:getRival(player, rival)
    lurek.log.info("getRival rival_rank=" .. tostring(snapshot.delta.rival_rank) .. " player_rank=" .. tostring(snapshot.delta.profile_rank))
end
```

---

#### `LProgressionStore:getRivalDelta`

```lua
LProgressionStore:getRivalDelta(profile, rival_profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `rival_profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_delta_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:submitScore(player, "arena", 5)
    store:submitScore(rival, "arena", 6)
    store:pinRival(player, rival, { leaderboard_id = "arena" })
    local delta = store:getRivalDelta(player, rival)
    lurek.log.info("getRivalDelta rank_delta=" .. tostring(delta.rank_delta) .. " score_delta=" .. tostring(delta.score_delta))
end
```

---

#### `LProgressionStore:getSchemaVersion`

Returns the schema version.

```lua
LProgressionStore:getSchemaVersion()
```

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changeset_conflict_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    source:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    local source_profile = source:createProfile("player")
    source:addCounter(source_profile, "wins", 1)
    source:acceptQuest(source_profile, "cleanup")
    local envelope = source:exportChangeset(0)

    local target = lurek.progression.newStore({ id = "changeset_conflict_target" })
    target:defineCounter("wins", { kind = "integer", initial = 0 })
    target:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    local target_profile = target:createProfile("player")
    target:createProfile("local_only")
    target:addCounter(target_profile, "wins", 5)
    target:acceptQuest(target_profile, "cleanup")
    target:setQuestObjective(target_profile, "cleanup", "step", 1)
    local report = target:applyChangesetEnvelope(envelope, {
        require_definition_hash_match = true,
        require_schema_match = true,
        merge_policy = "keep_local",
    })
    lurek.log.info("applyChangesetEnvelope conflict_count=" .. tostring(report.conflictCount) .. " reason=" .. tostring(report.reason) .. " kept_wins=" .. tostring(target:getCounter("player", "wins")))
end
```

---

#### `LProgressionStore:getSeason`

Returns the season.

```lua
LProgressionStore:getSeason(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_get_example" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, archive = true })
    store:startSeason("arena_s1", { time = 12 })
    local season = store:getSeason("arena_s1")
    local stats = store:stats()
    lurek.log.info("getSeason active=" .. tostring(season.active) .. " started_at=" .. tostring(season.started_at) .. " season_defs=" .. tostring(stats.seasonDefinitions))
end
```

---

#### `LProgressionStore:getSeasonArchive`

```lua
LProgressionStore:getSeasonArchive(id, query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `query?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_archive_example" })
    store:createProfile("alpha")
    store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal", counter_id = "season_wins" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, reset = { leaderboards = { "arena" }, counters = { "season_wins" } }, archive = true })
    store:startSeason("arena_s1", { time = 0 })
    store:addCounter("alpha", "season_wins", 4)
    store:endSeason("arena_s1", { time = 100 })
    local archive = store:getSeasonArchive("arena_s1", { latest = true })
    lurek.log.info("getSeasonArchive archive=" .. tostring(archive.archive_index) .. " wins=" .. tostring(archive.snapshot.profiles.alpha.counters.season_wins.value))
end
```

---

#### `LProgressionStore:getSkillCooldown`

```lua
LProgressionStore:getSkillCooldown(profile, skill_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `skill_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getskillcooldown" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getSkillCooldown profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getSkillLevel`

```lua
LProgressionStore:getSkillLevel(profile, skill_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `skill_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getskilllevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getSkillLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getTime`

Returns the time.

```lua
LProgressionStore:getTime()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_gettime" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getTime profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:hasPerk`

```lua
LProgressionStore:hasPerk(profile, perk_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `perk_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_hasperk" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:hasPerk profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:hasProfile`

Returns true if profile.

```lua
LProgressionStore:hasProfile(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_hasprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:hasProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:hasTrait`

```lua
LProgressionStore:hasTrait(profile, trait_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `trait_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_hastrait" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:hasTrait profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:learnSkill`

```lua
LProgressionStore:learnSkill(profile, skill_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `skill_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_learnskill" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:learnSkill profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listAchievements`

List achievements.

```lua
LProgressionStore:listAchievements(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listachievements" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listAchievements profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listChallenges`

```lua
LProgressionStore:listChallenges(profile, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_list_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        required = 1,
        counter_id = "wins",
    })
    store:defineChallengeTemplate("timed_route", {
        title = "Timed Route",
        required = 1,
        duration = 2,
        repeatable = true,
    })
    store:activateChallenge(player, "win_streak")
    store:activateChallenge(player, "timed_route", { time = 0 })
    store:addCounter("player", "wins", 1)
    store:advanceTime(3)
    local completed = store:listChallenges(player, { status = "completed" })
    local expired = store:listChallenges("player", { status = "expired" })
    lurek.log.info("listChallenges completed=" .. tostring(#completed) .. " expired=" .. tostring(#expired))
end
```

---

#### `LProgressionStore:listCollections`

List collections.

```lua
LProgressionStore:listCollections(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "collection_list_example" })
    local player = store:createProfile("player")
    store:defineCollection("museum", { title = "Museum", items = { { id = "entry_a", title = "Entry A" } } })
    store:defineCollection("bestiary", { title = "Bestiary", items = { { id = "slime", title = "Slime" } } })
    local collections = store:listCollections(player)
    lurek.log.info("listCollections total=" .. tostring(#collections) .. " first=" .. tostring(collections[1] and collections[1].id))
end
```

---

#### `LProgressionStore:listCounters`

List counters.

```lua
LProgressionStore:listCounters(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listcounters" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listCounters profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listLeaderboardAroundProfile`

```lua
LProgressionStore:listLeaderboardAroundProfile()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listleaderboardaroundprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listLeaderboardAroundProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listLeaderboardRange`

```lua
LProgressionStore:listLeaderboardRange(leaderboard_id, start_rank, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `leaderboard_id` | any |  |
| `start_rank` | any |  |
| `limit?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listleaderboardrange" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listLeaderboardRange profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listLeaderboardTop`

```lua
LProgressionStore:listLeaderboardTop(leaderboard_id, limit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `leaderboard_id` | any |  |
| `limit?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listleaderboardtop" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listLeaderboardTop profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listModifiers`

List modifiers.

```lua
LProgressionStore:listModifiers(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listmodifiers" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listModifiers profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listPopulationProfiles`

```lua
LProgressionStore:listPopulationProfiles(handle_or_id, query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |
| `query?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_list_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local profiles = store:listPopulationProfiles("bots_run", { limit = 1 })
    lurek.log.info("listPopulationProfiles count=" .. tostring(#profiles) .. " first=" .. tostring(profiles[1] and profiles[1].profile_id) .. " population=" .. tostring(profiles[1] and profiles[1].population_id))
end
```

---

#### `LProgressionStore:listPrestiges`

List prestiges.

```lua
LProgressionStore:listPrestiges(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "prestige_list_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", { condition = { level = { track = "character_xp", op = ">=", value = 100 } } })
    store:definePrestige("rebirth", { condition = { level = { track = "character_xp", op = ">=", value = 50 } } })
    local prestiges = store:listPrestiges(player)
    lurek.log.info("listPrestiges total=" .. tostring(#prestiges) .. " first=" .. tostring(prestiges[1] and prestiges[1].id) .. " second=" .. tostring(prestiges[2] and prestiges[2].id))
end
```

---

#### `LProgressionStore:listProfiles`

List profiles.

```lua
LProgressionStore:listProfiles()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listprofiles" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listProfiles profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listRivals`

List rivals.

```lua
LProgressionStore:listRivals(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_list_example" })
    local player = store:createProfile("player")
    local alpha = store:createProfile("alpha")
    local beta = store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:pinRival(player, beta, { leaderboard_id = "arena" })
    store:pinRival(player, alpha, { leaderboard_id = "arena" })
    local rivals = store:listRivals(player)
    lurek.log.info("listRivals total=" .. tostring(#rivals) .. " first=" .. tostring(rivals[1] and rivals[1].rival_profile_id))
end
```

---

#### `LProgressionStore:listSeasons`

List seasons.

```lua
LProgressionStore:listSeasons(query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_list_example" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100 })
    store:defineSeason("arena_s2", { starts_at = 100, ends_at = 200 })
    store:startSeason("arena_s1", { time = 0 })
    local active = store:listSeasons({ active = true })
    local all = store:listSeasons()
    lurek.log.info("listSeasons active=" .. tostring(#active) .. " total=" .. tostring(#all) .. " first=" .. tostring(all[1] and all[1].id))
end
```

---

#### `LProgressionStore:listTraits`

List traits.

```lua
LProgressionStore:listTraits(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listtraits" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listTraits profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:loadSnapshot`

Load snapshot.

```lua
LProgressionStore:loadSnapshot(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_loadsnapshot" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:loadSnapshot profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:materializePopulationProfile`

```lua
LProgressionStore:materializePopulationProfile(profile_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_materialize_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local virtual_profile = store:listPopulationProfiles("bots_run")[1]
    local materialized = store:materializePopulationProfile(virtual_profile.profile_id)
    lurek.log.info("materializePopulationProfile id=" .. tostring(materialized.id) .. " exists=" .. tostring(store:hasProfile(virtual_profile.profile_id)) .. " kind=" .. tostring(materialized.kind))
end
```

---

#### `LProgressionStore:pausePopulation`

Pause population.

```lua
LProgressionStore:pausePopulation(handle_or_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_pause_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local paused = store:pausePopulation("bots_run")
    local report = store:updatePopulation("bots_run", 4)
    lurek.log.info("pausePopulation paused=" .. tostring(paused.paused) .. " updated=" .. tostring(report.updated_profiles) .. " time=" .. tostring(report.logical_time))
end
```

---

#### `LProgressionStore:pinRival`

```lua
LProgressionStore:pinRival(profile, rival_profile, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `rival_profile` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_pin_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    local pinned = store:pinRival(player, rival, { leaderboard_id = "arena" })
    lurek.log.info("pinRival rival=" .. tostring(pinned.rival_profile_id) .. " board=" .. tostring(pinned.leaderboard_id))
end
```

---

#### `LProgressionStore:refillResource`

```lua
LProgressionStore:refillResource(profile, resource_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |
| `amount?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_refillresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:refillResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:refreshQuestLifecycle`

Refresh quest lifecycle.

```lua
LProgressionStore:refreshQuestLifecycle(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_refreshquestlifecycle" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:refreshQuestLifecycle profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:regeneratePopulation`

```lua
LProgressionStore:regeneratePopulation(handle_or_id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_regenerate_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    store:updatePopulation("bots_run", 4)
    local regenerated = store:regeneratePopulation("bots_run")
    lurek.log.info("regeneratePopulation time=" .. tostring(regenerated.logical_time) .. " generated=" .. tostring(regenerated.generated_count) .. " paused=" .. tostring(regenerated.paused))
end
```

---

#### `LProgressionStore:removeDerivedValue`

Removes derived value.

```lua
LProgressionStore:removeDerivedValue(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removederivedvalue" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeDerivedValue profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:removeModifier`

```lua
LProgressionStore:removeModifier(profile, handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `handle` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removemodifier" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeModifier profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:removePopulation`

```lua
LProgressionStore:removePopulation(handle_or_id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_remove_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local removed = store:removePopulation("bots_run")
    local stats = store:stats()
    lurek.log.info("removePopulation removed=" .. tostring(removed) .. " populations=" .. tostring(stats.populations) .. " templates=" .. tostring(stats.populationTemplates))
end
```

---

#### `LProgressionStore:removeProfile`

```lua
LProgressionStore:removeProfile(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removeprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:removeProfileMetadata`

```lua
LProgressionStore:removeProfileMetadata(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `key` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removeprofilemetadata" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeProfileMetadata profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:removeProfileTag`

```lua
LProgressionStore:removeProfileTag(id, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `tag` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removeprofiletag" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeProfileTag profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:removeTrait`

```lua
LProgressionStore:removeTrait(profile, trait_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `trait_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removetrait" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeTrait profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:resumePopulation`

Resume population.

```lua
LProgressionStore:resumePopulation(handle_or_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_resume_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    store:pausePopulation("bots_run")
    local resumed = store:resumePopulation("bots_run")
    local report = store:updatePopulation("bots_run", 2)
    lurek.log.info("resumePopulation paused=" .. tostring(resumed.paused) .. " updated=" .. tostring(report.updated_profiles) .. " time=" .. tostring(report.logical_time))
end
```

---

#### `LProgressionStore:revealQuest`

```lua
LProgressionStore:revealQuest(profile, quest_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_lifecycle_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineQuest("arena", {
        title = "Arena",
        reveal_condition = {
            counter = "wins",
            op = ">=",
            value = 1,
        },
        availability_condition = {
            counter = "wins",
            op = ">=",
            value = 2,
        },
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    local hidden = store:getQuestState("player", "arena")
    store:addCounter(player, "wins", 1)
    local revealed = store:getQuestState(player, "arena")
    store:addCounter("player", "wins", 1)
    local available = store:getQuestState("player", "arena")
    lurek.log.info("revealQuest hidden=" .. tostring(hidden.status) .. " revealed=" .. tostring(revealed.status) .. " available=" .. tostring(available.status))
end
```

---

#### `LProgressionStore:setAttributeBase`

```lua
LProgressionStore:setAttributeBase(profile, attribute_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `attribute_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setattributebase" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setAttributeBase profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:setChallengeProgress`

```lua
LProgressionStore:setChallengeProgress(profile, challenge_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `challenge_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "challenge_progress_example" })
    local player = store:createProfile("player")
    store:defineChallengeTemplate("timed_route", {
        title = "Timed Route",
        required = 2,
        duration = 10,
        repeatable = true,
    })
    store:activateChallenge(player, "timed_route", { time = 0 })
    local progress = store:setChallengeProgress("player", "timed_route", 1)
    lurek.log.info("setChallengeProgress status=" .. tostring(progress.status) .. " completion=" .. tostring(progress.completion))
end
```

---

#### `LProgressionStore:setCounter`

```lua
LProgressionStore:setCounter(profile, counter_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `counter_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setcounter" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setCounter profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:setExperience`

```lua
LProgressionStore:setExperience(profile, track_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "xp_set_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    local xp = store:setExperience(player, "character_xp", 275)
    local forced = store:setLevel("player", "character_xp", 4)
    lurek.log.info("setExperience level=" .. tostring(xp.level) .. " xp=" .. tostring(xp.experience) .. " forced_level=" .. tostring(forced.level))
end
```

---

#### `LProgressionStore:setLevel`

```lua
LProgressionStore:setLevel(profile, track_id, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |
| `level` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setlevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:setProfileMetadata`

```lua
LProgressionStore:setProfileMetadata(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `key` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setprofilemetadata" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setProfileMetadata profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:setQuestObjective`

```lua
LProgressionStore:setQuestObjective(profile, quest_id, objective_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |
| `objective_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local source = lurek.progression.newStore({ id = "changeset_apply_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 4)
    local envelope = source:exportChangeset(0)

    local target = lurek.progression.newStore({ id = "changeset_apply_target" })
    target:defineCounter("wins", { kind = "integer", initial = 0 })
    local applied = target:applyChangesetEnvelope(envelope, {
        require_definition_hash_match = true,
        require_schema_match = true,
        merge_policy = "replace",
    })
    lurek.log.info("applyChangesetEnvelope applied=" .. tostring(applied.applied) .. " policy=" .. tostring(applied.mergePolicy) .. " wins=" .. tostring(target:getCounter("player", "wins")))
end
```

---

#### `LProgressionStore:setQuestObjectiveStatus`

```lua
LProgressionStore:setQuestObjectiveStatus(profile, quest_id, objective_id, status)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |
| `objective_id` | any |  |
| `status` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_objective_controls_example" })
    local player = store:createProfile("player")
    store:defineQuest("stealth", {
        title = "Stealth",
        stages = {
            {
                id = "stage_1",
                name = "Stage",
                objectives = {
                    { id = "required", description = "Required", required = 1, mandatory = true, visible = false },
                    { id = "optional", description = "Optional", required = 1, mandatory = false, visible = true },
                },
            },
        },
    })
    store:acceptQuest(player, "stealth")
    local before = store:getQuestState("player", "stealth")
    store:setQuestObjectiveVisibility(player, "stealth", "required", true)
    local after = store:setQuestObjectiveStatus("player", "stealth", "required", "skipped")
    lurek.log.info("setQuestObjectiveStatus before_visible=" .. tostring(before.objectives[1].visible) .. " final=" .. tostring(after.status))
end
```

---

#### `LProgressionStore:setQuestObjectiveVisibility`

```lua
LProgressionStore:setQuestObjectiveVisibility(profile, quest_id, objective_id, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |
| `objective_id` | any |  |
| `visible` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setquestobjectivevisibility" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setQuestObjectiveVisibility profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:setResource`

```lua
LProgressionStore:setResource(profile, resource_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:setTime`

Sets the time.

```lua
LProgressionStore:setTime(seconds)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seconds` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_settime" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setTime profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:simulatePopulationUntil`

```lua
LProgressionStore:simulatePopulationUntil(handle_or_id, logical_time, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |
| `logical_time` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_until_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local report = store:simulatePopulationUntil("bots_run", 8)
    local population = store:getPopulation("bots_run")
    lurek.log.info("simulatePopulationUntil time=" .. tostring(report.logical_time) .. " paused=" .. tostring(population.paused) .. " updates=" .. tostring(report.score_updates))
end
```

---

#### `LProgressionStore:spendResource`

```lua
LProgressionStore:spendResource(profile, resource_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_spendresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:spendResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:startSeason`

```lua
LProgressionStore:startSeason(id, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_start_example" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100 })
    local started = store:startSeason("arena_s1", { time = 5 })
    local fetched = store:getSeason("arena_s1")
    local active = store:listSeasons({ active = true })
    lurek.log.info("startSeason active=" .. tostring(started.active) .. " started_at=" .. tostring(fetched.started_at) .. " listed=" .. tostring(#active))
end
```

---

#### `LProgressionStore:stats`

Stats.

```lua
LProgressionStore:stats()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_stats" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:stats profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:submitScore`

```lua
LProgressionStore:submitScore(profile, leaderboard_id, score)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `leaderboard_id` | any |  |
| `score` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_submitscore" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:submitScore profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:type`

Type.

```lua
LProgressionStore:type()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_type" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:type profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:typeOf`

Type of.

```lua
LProgressionStore:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_typeof" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:typeOf profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:unlockAchievement`

```lua
LProgressionStore:unlockAchievement(profile, achievement_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `achievement_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "reward_flow_example" })
    local player = store:createProfile("player", { tags = { "hero" } })
    store:defineAchievement("manual_reward", {
        title = "Manual Reward",
        condition = {
            tag = "hero",
        },
        repeatable = true,
        reward_payload = {
            items = { "token" },
        },
    })
    local achievement = store:unlockAchievement(player, "manual_reward")
    local reward_id = "achievement:manual_reward:" .. tostring(achievement.unlock_count)
    local claimed = player:getPendingRewards()[1]:claim()
    local applied = claimed:markApplied("receipt-1")
    lurek.log.info("unlockAchievement reward=" .. tostring(reward_id) .. " state=" .. tostring(applied:getState()))
end
```

---

#### `LProgressionStore:update`

```lua
LProgressionStore:update(dt, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "update_owner_store" })
    local profile = store:createProfile("player")
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 1, refill = "rate" })
    store:setResource(profile, "focus", 1)
    store:update(2.0)
    lurek.log.info("LProgressionStore:update focus=" .. tostring(store:getResource("player", "focus").value) .. " revision=" .. tostring(store:getRevision()))
end
```

---

#### `LProgressionStore:updatePopulation`

```lua
LProgressionStore:updatePopulation(handle_or_id, dt, options)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle_or_id` | any |  |
| `dt` | any |  |
| `options?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_update_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local before = store:listPopulationProfiles("bots_run")[1]
    local report = store:updatePopulation("bots_run", 5)
    local after = store:listPopulationProfiles("bots_run")[1]
    lurek.log.info("updatePopulation dt=" .. tostring(report.dt) .. " before=" .. tostring(before.leaderboard_scores.arena) .. " after=" .. tostring(after.leaderboard_scores.arena))
end
```

---

#### `LProgressionStore:updateProfile`

```lua
LProgressionStore:updateProfile(id, patch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |
| `patch?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "profile_patch_example" })
    store:createProfile("player", { display_name = "Mira" })
    store:updateProfile("player", {
        kind = "human",
        display_name = "Captain Mira",
        tags = { "story" },
        metadata = { chapter = 2 },
    })
    store:addProfileTag("player", "veteran")
    store:setProfileMetadata("player", "region", "old_tunnels")
    local profile = store:getProfile("player")
    lurek.log.info("updateProfile name=" .. tostring(profile.display_name) .. " tags=" .. tostring(#profile.tags) .. " chapter=" .. tostring(profile.metadata.chapter))
end
```

---

#### `LProgressionStore:useSkill`

```lua
LProgressionStore:useSkill(profile, skill_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `skill_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_useskill" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:useSkill profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:validate`

Validate.

```lua
LProgressionStore:validate()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "validate_owner_store" })
    store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    local report = store:validate()
    lurek.log.info("LProgressionStore:validate ok=" .. tostring(report.ok) .. " errors=" .. tostring(#report.errors))
end
```

---

#### `LProgressionStore:validateCondition`

Validate condition.

```lua
LProgressionStore:validateCondition(condition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `condition` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_validatecondition" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:validateCondition profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:validateDerivedValues`

Validate derived values.

```lua
LProgressionStore:validateDerivedValues()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_validatederivedvalues" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:validateDerivedValues profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:validatePopulationTemplate`

Validate population template.

```lua
LProgressionStore:validatePopulationTemplate(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "population_validate_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = {
            { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } },
        },
        leaderboards = {
            arena = {
                initial_score = { distribution = "normal" },
                progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 },
            },
        },
    })
    local report = store:validatePopulationTemplate("bots")
    lurek.log.info("validatePopulationTemplate template=" .. tostring(report.template_id) .. " ok=" .. tostring(report.ok) .. " errors=" .. tostring(#report.errors))
end
```

---

## LProgressionTransaction

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProgressionTransaction:addCounter`

```lua
LProgressionTransaction:addCounter(profile, counter_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `counter_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_addcounter" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_addcounter_tx" })
    tx:addCounter(profile, "wins", 2)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:addCounter changes=" .. tostring(summary.changes) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end
```

---

#### `LProgressionTransaction:addExperience`

```lua
LProgressionTransaction:addExperience(profile, track_id, amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `track_id` | any |  |
| `amount` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_addexperience" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_addexperience_tx" })
    tx:addExperience(profile, "xp", 150)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:addExperience changes=" .. tostring(summary.changes) .. " level=" .. tostring(store:getLevel("player", "xp")))
end
```

---

#### `LProgressionTransaction:addModifier`

```lua
LProgressionTransaction:addModifier(profile, target_id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `target_id` | any |  |
| `opts` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_addmodifier" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_addmodifier_tx" })
    tx:addModifier(profile, "hp", { value = 10, layer = "final_add" })
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:addModifier changes=" .. tostring(summary.changes) .. " hp=" .. tostring(store:getAttribute("player", "hp", "effective")))
end
```

---

#### `LProgressionTransaction:commit`

Commit.

```lua
LProgressionTransaction:commit()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_commit" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_commit_tx" })
    local summary = tx:commit()
    local stats = store:stats()
    lurek.log.info("LProgressionTransaction:commit revision=" .. tostring(summary.revision) .. " changes=" .. tostring(summary.changes) .. " profiles=" .. tostring(stats.profiles))
end
```

---

#### `LProgressionTransaction:rollback`

Rollback.

```lua
LProgressionTransaction:rollback()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_rollback" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_rollback_tx" })
    tx:addCounter(profile, "wins", 2)
    tx:rollback()
    lurek.log.info("LProgressionTransaction:rollback wins=" .. tostring(store:getCounter("player", "wins")) .. " revision=" .. tostring(store:getRevision()))
end
```

---

#### `LProgressionTransaction:setAttributeBase`

```lua
LProgressionTransaction:setAttributeBase(profile, attribute_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `attribute_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setattributebase" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setattributebase_tx" })
    tx:setAttributeBase(profile, "hp", 120)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setAttributeBase changes=" .. tostring(summary.changes) .. " hp=" .. tostring(store:getAttribute("player", "hp", "base")))
end
```

---

#### `LProgressionTransaction:setCounter`

```lua
LProgressionTransaction:setCounter(profile, counter_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `counter_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setcounter" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setcounter_tx" })
    tx:setCounter(profile, "wins", 4)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setCounter changes=" .. tostring(summary.changes) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end
```

---

#### `LProgressionTransaction:setQuestObjective`

```lua
LProgressionTransaction:setQuestObjective(profile, quest_id, objective_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |
| `objective_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setquestobjective" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setquestobjective_tx" })
    tx:setQuestObjective(profile, "cleanup", "step", 1)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setQuestObjective changes=" .. tostring(summary.changes) .. " status=" .. tostring(store:getQuestState("player", "cleanup").status))
end
```

---

#### `LProgressionTransaction:setResource`

```lua
LProgressionTransaction:setResource(profile, resource_id, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `resource_id` | any |  |
| `value` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setresource" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setresource_tx" })
    tx:setResource(profile, "focus", 2)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setResource changes=" .. tostring(summary.changes) .. " focus=" .. tostring(store:getResource("player", "focus").value))
end
```

---

#### `LProgressionTransaction:type`

Type.

```lua
LProgressionTransaction:type()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_type" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_type_tx" })
    local kind = tx:type()
    local is_tx = tx:typeOf("LProgressionTransaction")
    lurek.log.info("LProgressionTransaction:type type=" .. tostring(kind) .. " ok=" .. tostring(is_tx))
end
```

---

#### `LProgressionTransaction:typeOf`

Type of.

```lua
LProgressionTransaction:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_typeof" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_typeof_tx" })
    local kind = tx:type()
    local is_tx = tx:typeOf("LProgressionTransaction")
    lurek.log.info("LProgressionTransaction:typeOf type=" .. tostring(kind) .. " ok=" .. tostring(is_tx))
end
```

---

## LQuestJournal

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQuestJournal:addEntry`

Appends one entry to the live quest journal and returns the stored entry object.

```lua
LQuestJournal:addEntry(text, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Non-empty journal body text to append. |
| `tag?` | string | Optional tag that categorizes the new journal entry. |

**Returns**

| Type | Description |
|------|-------------|
| [LQuestJournalEntry](#lquestjournalentry) | Retained journal entry after store-side indexing and trimming. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_add_entry_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local journal = store:getQuestState("player", "cleanup"):getJournal()
    local entry = journal:addEntry("Opened vault", "discover")
    lurek.log.info("LQuestJournal:addEntry index=" .. tostring(entry:getIndex()) .. " text=" .. tostring(entry:getText()) .. " total=" .. tostring(journal:count()))
end
```

---

#### `LQuestJournal:count`

Returns the number of retained entries currently stored in this journal.

```lua
LQuestJournal:count()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Journal entry count after retention trimming. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_count_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local journal = store:getQuestState(profile, "cleanup"):getJournal()
    journal:addEntry("Found clue", "discover")
    journal:addEntry("Opened door", "progress")
    lurek.log.info("LQuestJournal:count total=" .. tostring(journal:count()) .. " quest=" .. tostring(journal:getQuestId()))
end
```

---

#### `LQuestJournal:getQuestId`

Returns the quest id that owns this journal.

```lua
LQuestJournal:getQuestId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Authored quest identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_get_id_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local journal = store:getQuestState("player", "cleanup"):getJournal()
    journal:addEntry("Found clue", "discover")
    lurek.log.info("LQuestJournal:getQuestId quest=" .. tostring(journal:getQuestId()) .. " entries=" .. tostring(journal:count()))
end
```

---

#### `LQuestJournal:listEntries`

Returns every retained journal entry as typed entry userdata.

```lua
LQuestJournal:listEntries()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of `[LQuestJournalEntry](#lquestjournalentry)` userdata values. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lquestjournal_listentries" })
    local profile = store:createProfile("player")
    store:defineQuest("journaled", {
        title = "Journaled",
        max_journal_entries = 3,
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    store:acceptQuest(profile, "journaled")
    local journal = store:getQuestState("player", "journaled"):getJournal()
    journal:addEntry("Found clue", "discover")
    journal:addEntry("Opened door", "progress")
    local entries = journal:listEntries()
    lurek.log.info("LQuestJournal:listEntries total=" .. tostring(#entries) .. " first=" .. tostring(entries[1] and entries[1]:getText()) .. " quest=" .. tostring(journal:getQuestId()))
end
```

---

## LQuestJournalEntry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQuestJournalEntry:getIndex`

Returns the stable monotonically increasing journal index.

```lua
LQuestJournalEntry:getIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based journal entry index. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_entry_index_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local entry = store:getQuestState("player", "cleanup"):getJournal():addEntry("Found clue", "discover")
    lurek.log.info("LQuestJournalEntry:getIndex index=" .. tostring(entry:getIndex()) .. " tag=" .. tostring(entry:getTag()))
end
```

---

#### `LQuestJournalEntry:getTag`

Returns the optional journal entry tag.

```lua
LQuestJournalEntry:getTag()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Journal entry tag, or an empty string when no tag was stored. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_entry_tag_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local entry = store:getQuestState("player", "cleanup"):getJournal():addEntry("Opened door", "progress")
    lurek.log.info("LQuestJournalEntry:getTag tag=" .. tostring(entry:getTag()) .. " text=" .. tostring(entry:getText()))
end
```

---

#### `LQuestJournalEntry:getText`

Returns the authored journal entry text.

```lua
LQuestJournalEntry:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Retained journal body text. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_entry_text_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local entry = store:getQuestState(profile, "cleanup"):getJournal():addEntry("Mapped tunnel", "discover")
    lurek.log.info("LQuestJournalEntry:getText text=" .. tostring(entry:getText()) .. " index=" .. tostring(entry:getIndex()))
end
```

---

## LQuestState

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQuestState:getJournal`

Returns the retained quest journal as a typed journal object.

```lua
LQuestState:getJournal()
```

**Returns**

| Type | Description |
|------|-------------|
| [LQuestJournal](#lquestjournal) | Journal handle for the current quest state. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_journal_example" })
    local player = store:createProfile("player")
    store:defineQuest("journaled", {
        title = "Journaled",
        max_journal_entries = 2,
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    store:acceptQuest(player, "journaled")
    local state = store:getQuestState("player", "journaled")
    local journal = state:getJournal()
    journal:addEntry("Found clue", "discover")
    journal:addEntry("Opened door", "progress")
    local entry = journal:addEntry("Reached boss")
    lurek.log.info("LQuestState:getJournal quest=" .. tostring(journal:getQuestId()) .. " kept=" .. tostring(journal:count()) .. " last=" .. tostring(entry:getText()))
end
```

---

#### `LQuestState:getQuestId`

Returns the authored quest id.

```lua
LQuestState:getQuestId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Quest identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_state_get_id_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    local state = store:getQuestState(profile, "cleanup")
    lurek.log.info("LQuestState:getQuestId quest=" .. tostring(state:getQuestId()) .. " status=" .. tostring(state:getStatus()))
end
```

---

#### `LQuestState:getStatus`

Returns the current quest lifecycle status.

```lua
LQuestState:getStatus()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current quest state such as `"hidden"`, `"available"`, or `"active"`. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_state_get_status_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local state = store:getQuestState("player", "cleanup")
    lurek.log.info("LQuestState:getStatus quest=" .. tostring(state:getQuestId()) .. " status=" .. tostring(state:getStatus()))
end
```

---

#### `LQuestState:isRevealed`

Returns whether the quest is currently revealed to the owning profile.

```lua
LQuestState:isRevealed()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the quest is visible. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "quest_state_is_revealed_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    local before = store:getQuestState(profile, "cleanup")
    local after = store:revealQuest("player", "cleanup")
    lurek.log.info("LQuestState:isRevealed before=" .. tostring(before:isRevealed()) .. " after=" .. tostring(after:isRevealed()) .. " quest=" .. tostring(after:getQuestId()))
end
```

---

## LReward

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LReward:claim`

Claims this pending reward and returns the updated reward object.

```lua
LReward:claim()
```

**Returns**

| Type | Description |
|------|-------------|
| [LReward](#lreward) | Updated reward handle after the claim transition. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "reward_claim_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    local claimed = reward_record:claim()
    lurek.log.info("LReward:claim before=" .. tostring(reward_record:getState()) .. " after=" .. tostring(claimed:getState()) .. " id=" .. tostring(claimed:getId()))
end
```

---

#### `LReward:getId`

Returns the reward record id.

```lua
LReward:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Stable reward identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "reward_get_id_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    lurek.log.info("LReward:getId id=" .. tostring(reward_record:getId()) .. " state=" .. tostring(reward_record:getState()))
end
```

---

#### `LReward:getState`

Returns the current reward state.

```lua
LReward:getState()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `"pending"`, `"claimed"`, `"applied"`, or `"rejected"`. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "reward_get_state_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    local claimed = reward_record:claim()
    lurek.log.info("LReward:getState pending=" .. tostring(reward_record:getState()) .. " claimed=" .. tostring(claimed:getState()))
end
```

---

#### `LReward:markApplied`

Marks this claimed reward as applied and returns the updated reward object.

```lua
LReward:markApplied(external_receipt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `external_receipt?` | string | Optional game-specific receipt or transaction token. |

**Returns**

| Type | Description |
|------|-------------|
| [LReward](#lreward) | Updated reward handle after the apply transition. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "reward_mark_applied_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local claimed = profile:getPendingRewards()[1]:claim()
    local applied = claimed:markApplied("receipt-42")
    lurek.log.info("LReward:markApplied state=" .. tostring(applied:getState()) .. " receipt=" .. tostring(applied.external_receipt))
end
```

---

#### `LReward:reject`

Rejects this reward and returns the updated reward object.

```lua
LReward:reject(reason)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `reason?` | string | Optional rejection reason for logs or external flow control. |

**Returns**

| Type | Description |
|------|-------------|
| [LReward](#lreward) | Updated reward handle after the rejection transition. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "reward_reject_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    local rejected = reward_record:reject("inventory_full")
    lurek.log.info("LReward:reject state=" .. tostring(rejected:getState()) .. " id=" .. tostring(rejected:getId()))
end
```

---

## LRival

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRival:getProfileId`

Returns the owner profile id for this rivalry.

```lua
LRival:getProfileId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Profile identifier that pinned the rival. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_get_profile_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    local rival_state = store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
    lurek.log.info("LRival:getProfileId profile=" .. tostring(rival_state:getProfileId()) .. " rival=" .. tostring(rival_state:getRivalProfileId()))
end
```

---

#### `LRival:getRivalProfileId`

Returns the pinned rival profile id.

```lua
LRival:getRivalProfileId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Rival profile identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_get_rival_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    local rival_state = store:getRival(store:pinRival("alpha", "beta", { leaderboard_id = "arena" }):getProfileId(), "beta")
    lurek.log.info("LRival:getRivalProfileId profile=" .. tostring(rival_state:getProfileId()) .. " rival=" .. tostring(rival_state:getRivalProfileId()))
end
```

---

## LRivalDelta

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LRivalDelta:getLeaderboardId`

Returns the leaderboard used to compute this rivalry delta.

```lua
LRivalDelta:getLeaderboardId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Leaderboard identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_delta_get_lb_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
    local delta = store:getRivalDelta("alpha", "beta")
    lurek.log.info("LRivalDelta:getLeaderboardId leaderboard=" .. tostring(delta:getLeaderboardId()) .. " rank_delta=" .. tostring(delta:getRankDelta()))
end
```

---

#### `LRivalDelta:getRankDelta`

Returns the signed rank gap between the owner and rival profiles.

```lua
LRivalDelta:getRankDelta()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Positive when the rival is behind, negative when ahead. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "rival_delta_get_rank_delta_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
    local delta = store:getRivalDelta("alpha", "beta")
    lurek.log.info("LRivalDelta:getRankDelta leaderboard=" .. tostring(delta:getLeaderboardId()) .. " rank_delta=" .. tostring(delta:getRankDelta()))
end
```

---

## LSeason

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSeason:getId`

Returns the authored season id.

```lua
LSeason:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Season identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_get_id_example" })
    store:defineSeason("spring", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = false })
    store:startSeason("spring")
    local season_state = store:getSeason("spring")
    lurek.log.info("LSeason:getId id=" .. tostring(season_state:getId()) .. " active=" .. tostring(season_state:isActive()))
end
```

---

#### `LSeason:isActive`

Returns whether this season is currently active.

```lua
LSeason:isActive()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | `true` when the season is active. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_is_active_example" })
    store:defineSeason("summer", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = false })
    local before = store:getSeason("summer")
    store:startSeason("summer")
    local after = store:getSeason("summer")
    lurek.log.info("LSeason:isActive before=" .. tostring(before:isActive()) .. " after=" .. tostring(after:isActive()) .. " id=" .. tostring(after:getId()))
end
```

---

## LSeasonArchive

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSeasonArchive:getArchiveIndex`

Returns the monotonically increasing archive index for this season.

```lua
LSeasonArchive:getArchiveIndex()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Archive sequence number. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_archive_index_example" })
    store:createProfile("player")
    store:defineSeason("league", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = true })
    store:startSeason("league")
    store:endSeason("league", { archive = true })
    local archive = store:getSeasonArchive("league", { latest = true })
    lurek.log.info("LSeasonArchive:getArchiveIndex id=" .. tostring(archive:getId()) .. " index=" .. tostring(archive:getArchiveIndex()))
end
```

---

#### `LSeasonArchive:getId`

Returns the season id that owns this archive record.

```lua
LSeasonArchive:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Season identifier. |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "season_archive_id_example" })
    store:createProfile("player")
    store:defineSeason("league", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = true })
    store:startSeason("league")
    store:endSeason("league", { archive = true })
    local archive = store:getSeasonArchive("league", { latest = true })
    lurek.log.info("LSeasonArchive:getId id=" .. tostring(archive:getId()) .. " index=" .. tostring(archive:getArchiveIndex()))
end
```

---

## LStatusTracker

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LStatusTracker:apply`

Applies a status to a subject and returns its stable runtime instance id.

```lua
LStatusTracker:apply(subjectId, definitionId, sourceId, stacks)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `subjectId` | number | Stable subject/entity id. |
| `definitionId` | string | Registered status definition id. |
| `sourceId?` | number | Optional source/owner id. |
| `stacks?` | number | Initial stack count, clamped to maxStacks. |

**Returns**

| Type | Description |
|------|-------------|
| number | Status instance id. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "slow", duration = 4, maxStacks = 2, stacking = "refresh" })
    local instance = tracker:apply(7, "slow", 99, 1)
    lurek.log.info("applied instance=" .. instance .. " subject=" .. tracker:list(7)[1].subjectId .. " source=" .. tracker:list(7)[1].sourceId)
end
```

---

#### `LStatusTracker:clear`

Removes all definitions, instances, and queued events.

```lua
LStatusTracker:clear()
```

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "shield", duration = 10 })
    tracker:apply(1, "shield")
    tracker:clear()
    lurek.log.info("cleared status count=" .. #tracker:list(1) .. " events=" .. #tracker:drainEvents())
end
```

---

#### `LStatusTracker:define`

Registers or replaces one status definition.

```lua
LStatusTracker:define(definition)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `definition` | table | Definition with id, duration, tickInterval, maxStacks, stacking, and tags. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "poison", duration = 5, tickInterval = 1, maxStacks = 3, stacking = "add", tags = { "damage_over_time" } })
    lurek.log.info("defined poison statuses=" .. #tracker:list(1) .. " type=" .. tracker:type())
end
```

---

#### `LStatusTracker:drainEvents`

Takes and clears neutral apply/refresh/stack/tick/expired events.

```lua
LStatusTracker:drainEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Event records in deterministic emission order. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "regen", duration = 3, tickInterval = 1 })
    tracker:apply(2, "regen")
    local events = tracker:drainEvents()
    lurek.log.info("status events=" .. #events .. " first=" .. events[1].kind .. " instance=" .. events[1].instanceId)
end
```

---

#### `LStatusTracker:list`

Lists active status instances attached to one subject.

```lua
LStatusTracker:list(subjectId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `subjectId` | number | Stable subject/entity id. |

**Returns**

| Type | Description |
|------|-------------|
| table | Status instance records. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "marked", duration = 8 })
    tracker:apply(3, "marked", nil, 2)
    local statuses = tracker:list(3)
    lurek.log.info("status count=" .. #statuses .. " definition=" .. statuses[1].definitionId .. " stacks=" .. statuses[1].stacks)
end
```

---

#### `LStatusTracker:remove`

Removes one active status instance.

```lua
LStatusTracker:remove(instanceId)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `instanceId` | number | Runtime status instance id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an instance was removed. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", duration = 8 })
    local instance = tracker:apply(4, "ward")
    local removed = tracker:remove(instance)
    lurek.log.info("removed=" .. tostring(removed) .. " remaining=" .. #tracker:list(4) .. " second=" .. tostring(tracker:remove(instance)))
end
```

---

#### `LStatusTracker:restore`

Restores definitions, active instances, and ID allocation from a snapshot.

```lua
LStatusTracker:restore(snapshot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `snapshot` | table | Table returned by `snapshot`. |

**Example**

```lua
do
    local source = lurek.progression.newStatusTracker()
    source:define({ id = "burn", duration = 2, tickInterval = 1 })
    source:apply(5, "burn")
    local target = lurek.progression.newStatusTracker()
    target:restore(source:snapshot())
    lurek.log.info("restored statuses=" .. #target:list(5) .. " definition=" .. target:list(5)[1].definitionId)
end
```

---

#### `LStatusTracker:snapshot`

Captures definitions, instances, and ID allocation state.

```lua
LStatusTracker:snapshot()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Serializable status tracker snapshot. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "haste", duration = 6 })
    tracker:apply(6, "haste")
    local snapshot = tracker:snapshot()
    lurek.log.info("snapshot definitions=" .. tostring(snapshot.definitions.haste.id) .. " instances=" .. #snapshot.instances .. " next=" .. snapshot.nextId)
end
```

---

#### `LStatusTracker:type`

Returns the Lua-visible type name.

```lua
LStatusTracker:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `[LStatusTracker](#lstatustracker)`. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    lurek.log.info("status tracker type=" .. tracker:type() .. " empty=" .. tostring(#tracker:list(1) == 0) .. " snapshot=" .. tostring(tracker:snapshot() ~= nil))
end
```

---

#### `LStatusTracker:typeOf`

Checks whether this handle matches `[LStatusTracker](#lstatustracker)` or `LObject`.

```lua
LStatusTracker:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the name matches. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    lurek.log.info("tracker=" .. tostring(tracker:typeOf("LStatusTracker")) .. " object=" .. tostring(tracker:typeOf("LObject")) .. " store=" .. tostring(tracker:typeOf("LProgressionStore")))
end
```

---

#### `LStatusTracker:update`

Advances finite durations and periodic tick timers by dt seconds.

```lua
LStatusTracker:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Non-negative logical seconds. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of events currently queued after the update. |

**Example**

```lua
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "poison", duration = 2.5, tickInterval = 1 })
    tracker:apply(8, "poison")
    local queued = tracker:update(1.1)
    local events = tracker:drainEvents()
    lurek.log.info("update queued=" .. queued .. " tick=" .. tostring(events[#events].kind == "tick") .. " remaining=" .. tracker:list(8)[1].remaining)
end
```

---
