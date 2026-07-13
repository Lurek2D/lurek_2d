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
- attributes, resources, modifiers, and XP/level tracks;
- achievements with manual and counter-triggered unlocks;
- reward records with pending, claimed, applied, and rejected states;
- quest definitions with reveal and availability lifecycle, manual progress, canonical journal entries, visible/hidden objectives, explicit objective status overrides, counter-driven objectives, and quest rewards;
- transaction batching, debug snapshots, bounded changeset envelopes with schema/hash validation, ack/compaction helpers, and compatibility `exportChangesSince` / `applyChangeset` support built from retained revision snapshots;
- initial changeset merge policies with conflict reports for local profile divergence and quest-branch mismatches;
- malformed or oversized changesets are rejected before snapshot application;
- legacy import helpers for snapshots produced by the former `library.stats` and `library.quest` flows.

The module is intentionally headless. It owns data and mutation rules only.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.progression.acquirePerk`

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
    define_example_trait(store, "example_trait", 10)
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = "example_trait" })
    local acquired = adapter:acquirePerk("iron_skin")
    lurek.log.info("{api} acquired=" .. tostring(acquired) .. " has=" .. tostring(adapter:hasPerk("iron_skin")))
end
```

---

### `lurek.progression.activeCount`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local count = adapter:activeCount()
    lurek.log.info("lurek.progression.activeCount count=" .. tostring(count))
end
```

---

### `lurek.progression.activeIds`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local ids = adapter:activeIds()
    lurek.log.info("lurek.progression.activeIds first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.addBuff`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:addJournalEntry("cleanup", "Entered the cellar", "story")
    local quest_state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.addJournalEntry journal=" .. tostring(#quest_state.journal))
end
```

---

### `lurek.progression.addQuest`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.addQuest first=" .. tostring(ids[1]) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.addXP`

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

```lua
lurek.progression.advanceObjective()
```

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lurek_progression_advanceobjective" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.advanceObjective status=" .. tostring(state.status))
end
```

---

### `lurek.progression.applyDamage`

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
    define_example_trait(store, "example_trait", 10)
    adapter:applyTraitBuffs("example_trait")
    local traits = adapter:getActiveTraits()
    lurek.log.info("{api} trait=" .. tostring(traits[1]))
end
```

---

### `lurek.progression.beginTurn`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:completeQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.completeQuest status=" .. tostring(state.status))
end
```

---

### `lurek.progression.completedCount`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    lurek.log.info("lurek.progression.completedCount count=" .. tostring(adapter:completedCount()))
end
```

---

### `lurek.progression.completedIds`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local ids = adapter:completedIds()
    lurek.log.info("lurek.progression.completedIds first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.createLegacyQuestAdapter`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local kind = adapter.type()
    lurek.log.info("lurek.progression.createLegacyQuestAdapter type=" .. tostring(kind) .. " first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.createLegacyStatsAdapter`

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
    define_example_trait(store, "example_trait", 10)
    adapter:definePerk("iron_skin", { require_level = 1, trait_name = "example_trait" })
    adapter:setXP(150)
    lurek.log.info("{api} ready=" .. tostring(adapter:hasPerk("iron_skin")))
end
```

---

### `lurek.progression.defineSkill`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:failQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.failQuest status=" .. tostring(state.status))
end
```

---

### `lurek.progression.failedIds`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:failQuest("cleanup")
    local ids = adapter:failedIds()
    lurek.log.info("lurek.progression.failedIds first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.get`

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

```lua
lurek.progression.getActionPoints(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

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
    define_example_trait(store, "example_trait", 10)
    adapter:applyTraitBuffs("example_trait")
    local traits = adapter:getActiveTraits()
    lurek.log.info("{api} trait=" .. tostring(traits[1]))
end
```

---

### `lurek.progression.getBase`

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

```lua
lurek.progression.getMorale(this)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    local fetched = adapter:getQuest("cleanup")
    local ids = adapter:questIds()
    lurek.log.info("lurek.progression.getQuest id=" .. tostring(fetched.id) .. " first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.getQuestReward`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:setQuestReward("cleanup", "gold")
    local reward = adapter:getQuestReward("cleanup")
    lurek.log.info("lurek.progression.getQuestReward reward=" .. tostring(reward))
end
```

---

### `lurek.progression.getRegen`

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
    define_example_trait(store, "example_trait", 10)
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = "example_trait" })
    lurek.log.info("{api} has=" .. tostring(adapter:hasPerk("iron_skin")))
end
```

---

### `lurek.progression.hasTrait`

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
    define_example_trait(store, "example_trait", 10)
    adapter:applyTraitBuffs("example_trait")
    lurek.log.info("{api} has=" .. tostring(adapter:hasTrait("example_trait")))
end
```

---

### `lurek.progression.importLegacyQuestSnapshot`

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

### `lurek.progression.newStore`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    local count = adapter:questCount()
    local ids = adapter:questIds()
    lurek.log.info("lurek.progression.questCount count=" .. tostring(count) .. " first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.questIds`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.questIds first=" .. tostring(ids[1]) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.questsWithStatus`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local ids = adapter:questsWithStatus("active")
    lurek.log.info("lurek.progression.questsWithStatus first=" .. tostring(ids[1]))
end
```

---

### `lurek.progression.recordUse`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    local removed = adapter:removeQuest("cleanup")
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.removeQuest removed=" .. tostring(removed) .. " count=" .. tostring(count))
end
```

---

### `lurek.progression.removeTraitBuffs`

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
    define_example_trait(store, "example_trait", 10)
    adapter:applyTraitBuffs("example_trait")
    local removed = adapter:removeTraitBuffs("example_trait")
    lurek.log.info("{api} removed=" .. tostring(removed))
end
```

---

### `lurek.progression.resetQuest`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local reset = adapter:resetQuest("cleanup")
    lurek.log.info("lurek.progression.resetQuest reset=" .. tostring(reset))
end
```

---

### `lurek.progression.restore`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:setQuestReward("cleanup", "gold")
    local reward = adapter:getQuestReward("cleanup")
    lurek.log.info("lurek.progression.setQuestReward reward=" .. tostring(reward))
end
```

---

### `lurek.progression.setRegen`

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
    local quest = new_example_legacy_quest("cleanup", "Cleanup")
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.startQuest status=" .. tostring(state.status))
end
```

---

### `lurek.progression.type`

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

```lua
lurek.progression.useSkill(this, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `this` | any |  |
| `name` | any |  |

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

- [LProgressionProfile](#lprogressionprofile)
- [LProgressionStore](#lprogressionstore)
- [LProgressionTransaction](#lprogressiontransaction)

## LProgressionProfile

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProgressionProfile:getId`

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

#### `LProgressionProfile:type`

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

#### `LProgressionStore:addQuestJournalEntry`

```lua
LProgressionStore:addQuestJournalEntry(profile, quest_id, text, tag)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |
| `text` | any |  |
| `tag?` | any |  |

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
    store:addQuestJournalEntry("player", "journaled", "Found clue", "discover")
    store:addQuestJournalEntry(player, "journaled", "Opened door", "progress")
    local entry = store:addQuestJournalEntry("player", "journaled", "Reached boss")
    local journal = store:listQuestJournalEntries("player", "journaled")
    lurek.log.info("addQuestJournalEntry last=" .. tostring(entry.index) .. " kept=" .. tostring(#journal) .. " first_text=" .. tostring(journal[1] and journal[1].text))
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

#### `LProgressionStore:claimReward`

```lua
LProgressionStore:claimReward(profile, reward_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `reward_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_claimreward" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:claimReward profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:clear`

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
    local rewards = store:getPendingRewards("player")
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
    local rewards = store:getPendingRewards("player")
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
    lurek.log.info("getActivityFeed total=" .. tostring(#feed) .. " last=" .. tostring(feed[#feed] and feed[#feed].event_type))
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

#### `LProgressionStore:getPendingRewards`

```lua
LProgressionStore:getPendingRewards(profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getpendingrewards" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getPendingRewards profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:getPopulation`

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

#### `LProgressionStore:listQuestJournalEntries`

```lua
LProgressionStore:listQuestJournalEntries(profile, quest_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `quest_id` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listquestjournalentries" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listQuestJournalEntries profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:listRivals`

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

#### `LProgressionStore:markRewardApplied`

```lua
LProgressionStore:markRewardApplied(profile, reward_id, external_receipt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `reward_id` | any |  |
| `external_receipt?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_markrewardapplied" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:markRewardApplied profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
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

#### `LProgressionStore:rejectReward`

```lua
LProgressionStore:rejectReward(profile, reward_id, reason)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `profile` | any |  |
| `reward_id` | any |  |
| `reason?` | any |  |

**Example**

```lua
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_rejectreward" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:rejectReward profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end
```

---

#### `LProgressionStore:removeDerivedValue`

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
    local claimed = store:claimReward("player", reward_id)
    local applied = store:markRewardApplied(player, reward_id, "receipt-1")
    lurek.log.info("unlockAchievement reward=" .. tostring(claimed.id) .. " state=" .. tostring(applied.state))
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
