# quest

A quest log system with objectives, staged progression, and a journal. Each Quest has one or more QuestStages; each stage has one or more Objectives with progress tracking. A QuestLog manages all active quests and fires events on start, advance, complete, and fail.

## Usage

```lua
local quest = require("library/quest")

local kill_q = quest.Quest.new({ id = "slay_wolves", title = "Pest Control" })
local stage1 = quest.QuestStage.new({ id = "kill" })
stage1:addObjective(quest.Objective.new({
    id = "wolves", text = "Kill 5 wolves", type = "counter", target = 5
}))
kill_q:addStage(stage1)

local log = quest.QuestLog.new()
log:start(kill_q)
log:progress("slay_wolves", "wolves", 1)  -- +1 kill
print("Done:", log:isComplete("slay_wolves"))
```

## Dependencies

- `lurek.patterns.newEventBus` (optional), `lurek.save.SaveManager` (optional)
