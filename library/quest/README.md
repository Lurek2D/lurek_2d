# quest

A pure-Lua quest library with staged objectives, journal entries, rewards, and
top-level quest-log helpers.

## Usage

```lua
local quest = require("library.quest")

local stage = quest.newQuestStage("kill", "Clear the wolves")
stage:addObjective(quest.newObjective("wolves", "Kill 5 wolves", 5))

local q = quest.newQuest("slay_wolves", "Pest Control")
q:addStage(stage)

local log = quest.newQuestLog()
log:addQuest(q)
log:startQuest("slay_wolves")
log:advanceObjective("slay_wolves", "wolves", 1)

print(log:activeIds()[1], q:completionPercent())
```

## Optional bindings

- `lurek.patterns.newEventBus`: used by `QuestLog` when available or injected.
- `lurek.serialize.toJson/fromJson`: used by `quest.toJson()` and
  `quest.fromJson()` helpers.
