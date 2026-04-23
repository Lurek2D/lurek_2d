-- tests/lua/unit/test_library_quest.lua
-- BDD tests for library.quest          pure-Lua quest system

local quest = require("library.quest")

--                          Objective                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

-- @description Verifies objective defaults, progress tracking, completion state, tags, visibility, and optional or required objective metadata.
describe("Objective", function()
    -- @covers library.quest.newObjective
    -- @description Verifies case: creates with correct defaults.
    it("creates with correct defaults", function()
        local obj = quest.newObjective("kill_wolves", "Kill 3 wolves", 3)
        expect_equal(obj.id, "kill_wolves")
        expect_equal(obj.description, "Kill 3 wolves")
        expect_equal(obj.current, 0)
        expect_equal(obj.required, 3)
        expect_equal(obj.mandatory, true)
        expect_equal(obj.status, "pending")
        expect_equal(obj.visible, true)
    end)

    -- @description Verifies case: advance completes when reaching required.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.newObjective
    it("advance completes when reaching required", function()
        local obj = quest.newObjective("kill_wolves", "Kill 3 wolves", 3)
        obj:advance(2)
        expect_equal(obj.current, 2)
        expect_equal(obj.status, "active")
        obj:advance(1)
        expect_equal(obj.current, 3)
        expect_equal(obj.status, "done")
    end)

    -- @description Verifies case: advance clamps at required.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.newObjective
    it("advance clamps at required", function()
        local obj = quest.newObjective("fetch", "Fetch 5 apples", 5)
        obj:advance(10)
        expect_equal(obj.current, 5)
        expect_equal(obj.status, "done")
    end)

    -- @description Verifies case: advance does nothing when done.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.newObjective
    it("advance does nothing when done", function()
        local obj = quest.newObjective("task", "Task", 1)
        obj:advance(1)
        expect_equal(obj.status, "done")
        obj:advance(1)
        expect_equal(obj.current, 1) -- unchanged
    end)

    -- @description Verifies case: advance does nothing when failed.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.newObjective
    it("advance does nothing when failed", function()
        local obj = quest.newObjective("task", "Task", 3)
        obj.status = "failed"
        obj:advance(1)
        expect_equal(obj.current, 0)
    end)

    -- @description Verifies case: setProgress sets correct status.
    -- @covers library.quest.Objective:setProgress
    -- @covers library.quest.newObjective
    it("setProgress sets correct status", function()
        local obj = quest.newObjective("task", "Task", 5)
        obj:setProgress(3)
        expect_equal(obj.current, 3)
        expect_equal(obj.status, "active")
        obj:setProgress(5)
        expect_equal(obj.status, "done")
        obj:setProgress(0)
        expect_equal(obj.status, "pending")
    end)

    -- @description Verifies case: setProgress clamps to range.
    -- @covers library.quest.Objective:setProgress
    -- @covers library.quest.newObjective
    it("setProgress clamps to range", function()
        local obj = quest.newObjective("task", "Task", 5)
        obj:setProgress(100)
        expect_equal(obj.current, 5)
        obj:setProgress(-10)
        expect_equal(obj.current, 0)
    end)

    -- @description Verifies case: isComplete returns true for done or skipped.
    -- @covers library.quest.Objective:isComplete
    -- @covers library.quest.newObjective
    it("isComplete returns true for done or skipped", function()
        local obj = quest.newObjective("task", "Task", 1)
        expect_equal(obj:isComplete(), false)
        obj.status = "done"
        expect_equal(obj:isComplete(), true)
        obj.status = "skipped"
        expect_equal(obj:isComplete(), true)
        obj.status = "active"
        expect_equal(obj:isComplete(), false)
    end)

    -- @description Verifies case: addTag and hasTag work.
    -- @covers library.quest.Objective:addTag
    -- @covers library.quest.Objective:hasTag
    -- @covers library.quest.newObjective
    it("addTag and hasTag work", function()
        local obj = quest.newObjective("task", "Task", 1)
        expect_equal(obj:hasTag("kill"), false)
        obj:addTag("kill")
        expect_equal(obj:hasTag("kill"), true)
        -- duplicate add is ignored
        obj:addTag("kill")
        expect_equal(#obj.tags, 1)
    end)
end)

--                          QuestStage                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

-- @description Covers quest-stage creation, objective aggregation, completion checks, and stage-level metadata or ordering helpers.
describe("QuestStage", function()
    -- @covers library.quest.newQuestStage
    -- @description Verifies case: creates with correct defaults.
    it("creates with correct defaults", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        expect_equal(stage.id, "s1")
        expect_equal(stage.name, "Stage One")
        expect_equal(#stage.objectives, 0)
    end)

    -- @description Verifies case: addObjective and getObjective work.
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.QuestStage:objectiveCount
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuestStage
    it("addObjective and getObjective work", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        local obj = quest.newObjective("task1", "Task 1", 1)
        stage:addObjective(obj)
        expect_equal(stage:objectiveCount(), 1)
        local found = stage:getObjective("task1")
        expect_equal(found.id, "task1")
        expect_equal(stage:getObjective("nope"), nil)
    end)

    -- @description Verifies case: hasObjective works.
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:hasObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuestStage
    it("hasObjective works", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        stage:addObjective(quest.newObjective("task1", "Task 1", 1))
        expect_equal(stage:hasObjective("task1"), true)
        expect_equal(stage:hasObjective("task2"), false)
    end)

    -- @description Verifies case: clearObjectives removes all.
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:clearObjectives
    -- @covers library.quest.QuestStage:objectiveCount
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuestStage
    it("clearObjectives removes all", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        stage:addObjective(quest.newObjective("task1", "Task 1", 1))
        stage:addObjective(quest.newObjective("task2", "Task 2", 1))
        expect_equal(stage:objectiveCount(), 2)
        stage:clearObjectives()
        expect_equal(stage:objectiveCount(), 0)
    end)

    -- @description Verifies case: isComplete checks mandatory objectives.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:isComplete
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuestStage
    it("isComplete checks mandatory objectives", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        local mandatory = quest.newObjective("m1", "Mandatory", 1)
        local optional = quest.newObjective("o1", "Optional", 1)
        optional.mandatory = false
        stage:addObjective(mandatory)
        stage:addObjective(optional)
        expect_equal(stage:isComplete(), false)
        mandatory:advance(1)
        expect_equal(stage:isComplete(), true) -- optional doesn't matter
    end)

    -- @description Verifies case: isComplete returns true when empty.
    -- @covers library.quest.QuestStage:isComplete
    -- @covers library.quest.newQuestStage
    it("isComplete returns true when empty", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        expect_equal(stage:isComplete(), true)
    end)
end)

--                          Quest                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

-- @description Exercises quest defaults, stage progression, status changes, tags, rewards, and stage or objective accessors.
describe("Quest", function()
    -- @covers library.quest.newQuest
    -- @description Verifies case: creates with correct defaults.
    it("creates with correct defaults", function()
        local q = quest.newQuest("tutorial", "Tutorial")
        expect_equal(q.id, "tutorial")
        expect_equal(q.title, "Tutorial")
        expect_equal(q.status, "available")
        expect_equal(q.current_stage, 1)
        expect_equal(#q.stages, 0)
        expect_equal(#q.journal, 0)
    end)

    -- @description Verifies case: start/complete/fail transitions.
    -- @covers library.quest.Quest:complete
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("start/complete/fail transitions", function()
        local q = quest.newQuest("q1", "Quest 1")
        expect_equal(q.status, "available")
        expect_equal(q:start(), true)
        expect_equal(q.status, "active")
        expect_equal(q:complete(), true)
        expect_equal(q.status, "completed")
    end)

    -- @description Verifies case: start only works from available.
    -- @covers library.quest.Quest:fail
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("start only works from available", function()
        local q = quest.newQuest("q1", "Quest 1")
        expect_equal(q:start(), true)
        expect_equal(q:fail(), true)
        expect_equal(q.status, "failed")
        expect_equal(q:start(), false) -- should not change from failed
        expect_equal(q.status, "failed")
    end)

    -- @description Verifies case: stages and nextStage.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:nextStage
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("stages and nextStage", function()
        local q = quest.newQuest("main", "Main Quest")
        q:addStage(quest.newQuestStage("s1", "Stage 1"))
        q:addStage(quest.newQuestStage("s2", "Stage 2"))
        expect_equal(q.current_stage, 1) -- Lua 1-indexed
        expect_equal(q:nextStage(), true)
        expect_equal(q.current_stage, 2)
        expect_equal(q:nextStage(), false) -- already at last
    end)

    -- @description Verifies case: gotoStage works.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:gotoStage
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("gotoStage works", function()
        local q = quest.newQuest("main", "Main Quest")
        q:addStage(quest.newQuestStage("s1", "Stage 1"))
        q:addStage(quest.newQuestStage("s2", "Stage 2"))
        q:addStage(quest.newQuestStage("s3", "Stage 3"))
        expect_equal(q:gotoStage("s3"), true)
        expect_equal(q.current_stage, 3)
        expect_equal(q:gotoStage("nope"), false)
    end)

    -- @description Verifies case: getCurrentStage returns active stage.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:getCurrentStage
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("getCurrentStage returns active stage", function()
        local q = quest.newQuest("main", "Main Quest")
        q:addStage(quest.newQuestStage("s1", "Stage 1"))
        local cs = q:getCurrentStage()
        expect_equal(cs.id, "s1")
    end)

    -- @description Verifies case: getStage by id.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:getStage
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("getStage by id", function()
        local q = quest.newQuest("main", "Main Quest")
        q:addStage(quest.newQuestStage("s1", "Stage 1"))
        q:addStage(quest.newQuestStage("s2", "Stage 2"))
        local s = q:getStage("s2")
        expect_equal(s.name, "Stage 2")
        expect_equal(q:getStage("nope"), nil)
    end)

    -- @description Verifies case: advanceObjective works in the current stage.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("advanceObjective works in the current stage", function()
        local q = quest.newQuest("main", "Main Quest")
        local s1 = quest.newQuestStage("s1", "Stage 1")
        s1:addObjective(quest.newObjective("obj1", "Objective 1", 3))
        q:addStage(s1)
        expect_equal(q:advanceObjective("obj1", 2), true)
        local obj = s1:getObjective("obj1")
        expect_equal(obj.current, 2)
        expect_equal(q:advanceObjective("nope"), false)
    end)

    -- @description Verifies case: setObjectiveStatus works.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:setObjectiveStatus
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("setObjectiveStatus works", function()
        local q = quest.newQuest("main", "Main Quest")
        local s = quest.newQuestStage("s1", "Stage 1")
        s:addObjective(quest.newObjective("obj1", "Obj", 1))
        q:addStage(s)
        expect_equal(q:setObjectiveStatus("obj1", "skipped"), true)
        expect_equal(s:getObjective("obj1").status, "skipped")
        expect_equal(q:setObjectiveStatus("nope", "done"), false)
    end)

    -- @description Verifies case: journal entries.
    -- @covers library.quest.Quest:addJournalEntry
    -- @covers library.quest.newQuest
    it("journal entries", function()
        local q = quest.newQuest("main", "Main Quest")
        local idx1 = q:addJournalEntry("Found the cave", "discovered")
        local idx2 = q:addJournalEntry("Defeated the boss", "completed")
        expect_equal(idx1, 0)
        expect_equal(idx2, 1)
        expect_equal(#q.journal, 2)
        expect_equal(q.journal[1].text, "Found the cave")
        expect_equal(q.journal[1].tag, "discovered")
        expect_equal(q.journal[2].text, "Defeated the boss")
    end)

    -- @description Verifies case: metadata set/get.
    -- @covers library.quest.Quest:getMeta
    -- @covers library.quest.Quest:setMeta
    -- @covers library.quest.newQuest
    it("metadata set/get", function()
        local q = quest.newQuest("main", "Main Quest")
        q:setMeta("giver", "Old Man")
        expect_equal(q:getMeta("giver"), "Old Man")
        expect_equal(q:getMeta("nope"), nil)
    end)

    -- @description Verifies case: completionPercent works.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.Quest:completionPercent
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("completionPercent works", function()
        local q = quest.newQuest("main", "Main Quest")
        local s = quest.newQuestStage("s1", "Stage 1")
        s:addObjective(quest.newObjective("a", "A", 1))
        s:addObjective(quest.newObjective("b", "B", 1))
        q:addStage(s)
        expect_near(q:completionPercent(), 0.0, 0.01)
        q:advanceObjective("a", 1)
        expect_near(q:completionPercent(), 50.0, 0.01)
        q:advanceObjective("b", 1)
        expect_near(q:completionPercent(), 100.0, 0.01)
    end)

    -- @description Verifies case: completionPercent with no objectives returns 0.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:completionPercent
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("completionPercent with no objectives returns 0", function()
        local q = quest.newQuest("empty", "Empty")
        q:addStage(quest.newQuestStage("s1", "Stage 1"))
        expect_near(q:completionPercent(), 0.0, 0.01)
    end)

    -- @description Verifies case: activeObjectiveIds works.
    -- @covers library.quest.Quest:activeObjectiveIds
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("activeObjectiveIds works", function()
        local q = quest.newQuest("main", "Main Quest")
        local s = quest.newQuestStage("s1", "S1")
        local obj1 = quest.newObjective("a", "A", 3)
        local obj2 = quest.newObjective("b", "B", 1)
        s:addObjective(obj1)
        s:addObjective(obj2)
        q:addStage(s)
        q:advanceObjective("a", 1)
        local active = q:activeObjectiveIds()
        expect_equal(#active, 1)
        expect_equal(active[1], "a")
    end)

    -- @description Verifies case: resetObjective works.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:resetObjective
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("resetObjective works", function()
        local q = quest.newQuest("main", "Main Quest")
        local s = quest.newQuestStage("s1", "S1")
        local obj = quest.newObjective("a", "A", 1)
        obj:advance(1)
        s:addObjective(obj)
        q:addStage(s)
        expect_equal(obj.status, "done")
        expect_equal(q:resetObjective("a"), true)
        expect_equal(obj.status, "active")
        expect_equal(q:resetObjective("nope"), false)
    end)

    -- @description Verifies case: allObjectivesComplete works.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.Quest:allObjectivesComplete
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("allObjectivesComplete works", function()
        local q = quest.newQuest("main", "Main Quest")
        local s = quest.newQuestStage("s1", "S1")
        s:addObjective(quest.newObjective("a", "A", 1))
        q:addStage(s)
        expect_equal(q:allObjectivesComplete(), false)
        q:advanceObjective("a", 1)
        expect_equal(q:allObjectivesComplete(), true)
    end)
end)

--                          QuestLog                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         

-- @description Validates log-level quest registration, activation, completion, failure, lookup, sorting, and log-wide mutation helpers.
describe("QuestLog", function()
    -- @covers library.quest.newQuestLog
    -- @description Verifies case: creates empty.
    -- @covers library.quest.QuestLog:questCount
    -- @covers library.quest.QuestLog:questIds
    it("creates empty", function()
        local log = quest.newQuestLog()
        expect_equal(log:questCount(), 0)
        expect_equal(#log:questIds(), 0)
    end)

    -- @description Verifies case: addQuest and getQuest work.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:getQuest
    -- @covers library.quest.QuestLog:questCount
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("addQuest and getQuest work", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        expect_equal(log:questCount(), 1)
        local q = log:getQuest("q1")
        expect_equal(q.title, "Quest 1")
    end)

    -- @description Verifies case: addQuest replaces existing.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:getQuest
    -- @covers library.quest.QuestLog:questCount
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("addQuest replaces existing", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        log:addQuest(quest.newQuest("q1", "Quest 1 v2"))
        expect_equal(log:questCount(), 1)
        expect_equal(log:getQuest("q1").title, "Quest 1 v2")
    end)

    -- @description Verifies case: removeQuest works.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:questCount
    -- @covers library.quest.QuestLog:removeQuest
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("removeQuest works", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        expect_equal(log:removeQuest("q1"), true)
        expect_equal(log:questCount(), 0)
        expect_equal(log:removeQuest("q1"), false)
    end)

    -- @description Verifies case: questIds preserves insertion order.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:questIds
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("questIds preserves insertion order", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q2", "Quest 2"))
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        local ids = log:questIds()
        expect_equal(ids[1], "q2")
        expect_equal(ids[2], "q1")
    end)

    -- @description Verifies case: questsWithStatus filters correctly.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:questsWithStatus
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("questsWithStatus filters correctly", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        log:addQuest(quest.newQuest("q2", "Quest 2"))
        log:startQuest("q1")
        local active = log:questsWithStatus("active")
        expect_equal(#active, 1)
        expect_equal(active[1], "q1")
    end)

    -- @description Verifies case: startQuest transitions available to active.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:getQuest
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("startQuest transitions available to active", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        expect_equal(log:startQuest("q1"), true)
        expect_equal(log:getQuest("q1").status, "active")
    end)

    -- @description Verifies case: startQuest returns false for unknown id.
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.newQuestLog
    it("startQuest returns false for unknown id", function()
        local log = quest.newQuestLog()
        expect_equal(log:startQuest("nope"), false)
    end)

    -- @description Verifies case: completeQuest and failQuest work.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:completeQuest
    -- @covers library.quest.QuestLog:failQuest
    -- @covers library.quest.QuestLog:getQuest
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("completeQuest and failQuest work", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        log:startQuest("q1")
        log:completeQuest("q1")
        expect_equal(log:getQuest("q1").status, "completed")

        log:addQuest(quest.newQuest("q2", "Quest 2"))
        log:startQuest("q2")
        log:failQuest("q2")
        expect_equal(log:getQuest("q2").status, "failed")
    end)

    -- @description Verifies case: activeIds/completedIds/failedIds convenience.
    -- @covers library.quest.QuestLog:activeIds
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:completeQuest
    -- @covers library.quest.QuestLog:completedIds
    -- @covers library.quest.QuestLog:failQuest
    -- @covers library.quest.QuestLog:failedIds
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("activeIds/completedIds/failedIds convenience", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Q1"))
        log:addQuest(quest.newQuest("q2", "Q2"))
        log:addQuest(quest.newQuest("q3", "Q3"))
        log:startQuest("q1")
        log:startQuest("q2")
        log:completeQuest("q2")
        log:startQuest("q3")
        log:failQuest("q3")
        expect_equal(#log:activeIds(), 1)
        expect_equal(#log:completedIds(), 1)
        expect_equal(#log:failedIds(), 1)
    end)

    -- @description Verifies case: advanceObjective through log.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:advanceObjective
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    -- @covers library.quest.newQuestStage
    it("advanceObjective through log", function()
        local log = quest.newQuestLog()
        local q = quest.newQuest("q1", "Q1")
        local s = quest.newQuestStage("s1", "S1")
        s:addObjective(quest.newObjective("obj1", "Obj 1", 3))
        q:addStage(s)
        log:addQuest(q)
        expect_equal(log:advanceObjective("q1", "obj1", 2), true)
        expect_equal(s:getObjective("obj1").current, 2)
        expect_equal(log:advanceObjective("nope", "obj1", 1), false)
        expect_equal(log:advanceObjective("q1", "nope", 1), false)
    end)
end)

--                          Objective:removeTag                                                                                                                                                                                                                                                                                                                                                                                                                                                 

-- @description Adds focused coverage for removing objective tags and reporting whether a tag was actually present.
describe("Objective:removeTag", function()
    -- @covers library.quest.newObjective
    -- @description Verifies case: removes an existing tag and returns true.
    -- @covers library.quest.Objective:addTag
    -- @covers library.quest.Objective:hasTag
    -- @covers library.quest.Objective:removeTag
    it("removes an existing tag and returns true", function()
        local obj = quest.newObjective("task", "Task", 1)
        obj:addTag("kill")
        expect_equal(obj:removeTag("kill"), true)
        expect_equal(obj:hasTag("kill"), false)
    end)

    -- @description Verifies case: returns false for a tag that is not present.
    -- @covers library.quest.Objective:removeTag
    -- @covers library.quest.newObjective
    it("returns false for a tag that is not present", function()
        local obj = quest.newObjective("task", "Task", 1)
        expect_equal(obj:removeTag("nope"), false)
    end)

    -- @description Verifies case: removing one tag leaves others intact.
    -- @covers library.quest.Objective:addTag
    -- @covers library.quest.Objective:hasTag
    -- @covers library.quest.Objective:removeTag
    -- @covers library.quest.newObjective
    it("removing one tag leaves others intact", function()
        local obj = quest.newObjective("task", "Task", 1)
        obj:addTag("kill")
        obj:addTag("bonus")
        obj:removeTag("kill")
        expect_equal(obj:hasTag("kill"), false)
        expect_equal(obj:hasTag("bonus"), true)
    end)
end)

--                          QuestStage:getObjectives                                                                                                                                                                                                                                                                                                                                                                                                         

-- @description Verifies stage objective access returns the stored objective list in insertion order.
describe("QuestStage:getObjectives", function()
    -- @covers library.quest.newQuestStage
    -- @description Verifies case: returns all objectives in insertion order.
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjectives
    -- @covers library.quest.newObjective
    it("returns all objectives in insertion order", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        stage:addObjective(quest.newObjective("a", "A", 1))
        stage:addObjective(quest.newObjective("b", "B", 2))
        local objs = stage:getObjectives()
        expect_equal(#objs, 2)
        expect_equal(objs[1].id, "a")
        expect_equal(objs[2].id, "b")
    end)

    -- @description Verifies case: returns empty table when stage has no objectives.
    -- @covers library.quest.QuestStage:getObjectives
    -- @covers library.quest.newQuestStage
    it("returns empty table when stage has no objectives", function()
        local stage = quest.newQuestStage("s1", "Stage One")
        expect_equal(#stage:getObjectives(), 0)
    end)
end)

--                          QuestLog extended                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

-- @description Covers resetting quests in the log so progress and statuses return to their starting values.
describe("QuestLog:resetQuest", function()
    -- @covers library.quest.newQuestLog
    -- @description Verifies case: resets status, stage index, and objective progress.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:nextStage
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:advanceObjective
    -- @covers library.quest.QuestLog:resetQuest
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("resets status, stage index, and objective progress", function()
        local log = quest.newQuestLog()
        local q = quest.newQuest("q1", "Quest 1")
        local s = quest.newQuestStage("s1", "S1")
        local obj = quest.newObjective("kill", "Kill 3", 3)
        s:addObjective(obj)
        q:addStage(s)
        q:addStage(quest.newQuestStage("s2", "S2"))
        log:addQuest(q)

        log:startQuest("q1")
        log:advanceObjective("q1", "kill", 2)
        q:nextStage()
        expect_equal(q.status, "active")
        expect_equal(q.current_stage, 2)
        expect_equal(obj.current, 2)

        expect_equal(log:resetQuest("q1"), true)
        expect_equal(q.status, "available")
        expect_equal(q.current_stage, 1)
        expect_equal(obj.current, 0)
        expect_equal(obj.status, "pending")
    end)

    -- @description Verifies case: returns false for unknown quest id.
    -- @covers library.quest.QuestLog:resetQuest
    -- @covers library.quest.newQuestLog
    it("returns false for unknown quest id", function()
        local log = quest.newQuestLog()
        expect_equal(log:resetQuest("nope"), false)
    end)
end)

-- @description Tests explicit quest reward mutation and retrieval, including unknown quests and overwriting prior rewards.
describe("QuestLog:setQuestReward / getQuestReward", function()
    -- @covers library.quest.newQuestLog
    -- @description Verifies case: sets and retrieves reward string.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:getQuestReward
    -- @covers library.quest.QuestLog:setQuestReward
    -- @covers library.quest.newQuest
    it("sets and retrieves reward string", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        log:setQuestReward("q1", "100 gold")
        expect_equal(log:getQuestReward("q1"), "100 gold")
    end)

    -- @description Verifies case: getQuestReward returns nil for unknown quest.
    -- @covers library.quest.QuestLog:getQuestReward
    -- @covers library.quest.newQuestLog
    it("getQuestReward returns nil for unknown quest", function()
        local log = quest.newQuestLog()
        expect_equal(log:getQuestReward("nope"), nil)
    end)

    -- @description Verifies case: setQuestReward overwrites previous value.
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:getQuestReward
    -- @covers library.quest.QuestLog:setQuestReward
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestLog
    it("setQuestReward overwrites previous value", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Quest 1"))
        log:setQuestReward("q1", "10 silver")
        log:setQuestReward("q1", "500 gold")
        expect_equal(log:getQuestReward("q1"), "500 gold")
    end)
end)

-- @description Verifies aggregate active and completed quest counts for empty and partially progressed logs.
describe("QuestLog:activeCount / completedCount", function()
    -- @covers library.quest.newQuestLog
    -- @description Verifies case: counts active and completed quests correctly.
    -- @covers library.quest.QuestLog:activeCount
    -- @covers library.quest.QuestLog:addQuest
    -- @covers library.quest.QuestLog:completeQuest
    -- @covers library.quest.QuestLog:completedCount
    -- @covers library.quest.QuestLog:startQuest
    -- @covers library.quest.newQuest
    it("counts active and completed quests correctly", function()
        local log = quest.newQuestLog()
        log:addQuest(quest.newQuest("q1", "Q1"))
        log:addQuest(quest.newQuest("q2", "Q2"))
        log:addQuest(quest.newQuest("q3", "Q3"))
        log:startQuest("q1")
        log:startQuest("q2")
        log:completeQuest("q2")
        expect_equal(log:activeCount(), 1)
        expect_equal(log:completedCount(), 1)
    end)

    -- @description Verifies case: both return 0 for empty log.
    -- @covers library.quest.QuestLog:activeCount
    -- @covers library.quest.QuestLog:completedCount
    -- @covers library.quest.newQuestLog
    it("both return 0 for empty log", function()
        local log = quest.newQuestLog()
        expect_equal(log:activeCount(), 0)
        expect_equal(log:completedCount(), 0)
    end)
end)

--                          Status enum tables                                                                                                                                                                                                                                                                                                                                                                                                                                                         

-- @description Confirms exported quest-status constants match the string values used by quest state transitions.
describe("M.QuestStatus enum", function()
    -- @covers library.quest.QuestStatus
    -- @description Verifies case: has expected string constants.
    it("has expected string constants", function()
        expect_equal(quest.QuestStatus.LOCKED,    "locked")
        expect_equal(quest.QuestStatus.ACTIVE,    "active")
        expect_equal(quest.QuestStatus.COMPLETED, "completed")
        expect_equal(quest.QuestStatus.FAILED,    "failed")
    end)
end)

-- @description Confirms exported objective-status constants match the string values used by objective state transitions.
describe("M.ObjectiveStatus enum", function()
    -- @covers library.quest.ObjectiveStatus
    -- @description Verifies case: has expected string constants.
    it("has expected string constants", function()
        expect_equal(quest.ObjectiveStatus.LOCKED,    "locked")
        expect_equal(quest.ObjectiveStatus.ACTIVE,    "active")
        expect_equal(quest.ObjectiveStatus.COMPLETED, "completed")
        expect_equal(quest.ObjectiveStatus.FAILED,    "failed")
    end)
end)
--           Bug-fix regression tests                                                                                                                                                    

-- @description Tests that advanceObjective only searches the current stage by default.
describe("Quest:advanceObjective current-stage scoping", function()
    -- @description Verifies case: objective in a non-current stage is not found by default.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("does not advance objective in a non-current stage", function()
        local q = quest.newQuest("main", "Main Quest")
        local s1 = quest.newQuestStage("s1", "Stage 1")
        local s2 = quest.newQuestStage("s2", "Stage 2")
        s1:addObjective(quest.newObjective("obj_s1", "S1 Obj", 3))
        s2:addObjective(quest.newObjective("obj_s2", "S2 Obj", 3))
        q:addStage(s1)
        q:addStage(s2)
        -- current_stage = 1 (s1), so obj_s2 should not be found
        expect_equal(q:advanceObjective("obj_s2", 1), false)
        expect_equal(s2:getObjective("obj_s2").current, 0)
    end)

    -- @description Verifies case: advancing with explicit stage_id targets that stage.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("advances objective in explicit stage_id", function()
        local q = quest.newQuest("main", "Main Quest")
        local s1 = quest.newQuestStage("s1", "Stage 1")
        local s2 = quest.newQuestStage("s2", "Stage 2")
        s1:addObjective(quest.newObjective("obj_s1", "S1 Obj", 3))
        s2:addObjective(quest.newObjective("obj_s2", "S2 Obj", 3))
        q:addStage(s1)
        q:addStage(s2)
        -- Explicitly target s2
        expect_equal(q:advanceObjective("obj_s2", 2, "s2"), true)
        expect_equal(s2:getObjective("obj_s2").current, 2)
    end)

    -- @description Verifies case: after nextStage, the new current stage is searched.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:advanceObjective
    -- @covers library.quest.Quest:nextStage
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.QuestStage:getObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("after nextStage, new current stage is searched", function()
        local q = quest.newQuest("main", "Main Quest")
        local s1 = quest.newQuestStage("s1", "Stage 1")
        local s2 = quest.newQuestStage("s2", "Stage 2")
        s1:addObjective(quest.newObjective("obj_s1", "S1 Obj", 1))
        s2:addObjective(quest.newObjective("obj_s2", "S2 Obj", 3))
        q:addStage(s1)
        q:addStage(s2)
        q:nextStage()
        expect_equal(q:advanceObjective("obj_s2", 1), true)
        expect_equal(s2:getObjective("obj_s2").current, 1)
        -- s1 objective should not be reachable from current stage
        expect_equal(q:advanceObjective("obj_s1", 1), false)
    end)
end)

-- @description Tests that completionPercent returns 0.0 for zero mandatory objectives.
describe("Quest:completionPercent zero objectives", function()
    -- @description Verifies case: quest with no stages returns 0%.
    -- @covers library.quest.Quest:completionPercent
    -- @covers library.quest.newQuest
    it("returns 0 for quest with no stages", function()
        local q = quest.newQuest("empty", "Empty")
        expect_near(q:completionPercent(), 0.0, 0.01)
    end)

    -- @description Verifies case: quest with only optional objectives returns 0%.
    -- @covers library.quest.Quest:addStage
    -- @covers library.quest.Quest:completionPercent
    -- @covers library.quest.QuestStage:addObjective
    -- @covers library.quest.newObjective
    -- @covers library.quest.newQuest
    -- @covers library.quest.newQuestStage
    it("returns 0 for quest with only optional objectives", function()
        local q = quest.newQuest("opt", "Optional Only")
        local s = quest.newQuestStage("s1", "S1")
        local obj = quest.newObjective("a", "A", 1)
        obj.mandatory = false
        s:addObjective(obj)
        q:addStage(s)
        expect_near(q:completionPercent(), 0.0, 0.01)
    end)
end)

-- @description Tests that quest state machine rejects invalid transitions.
describe("Quest state machine enforcement", function()
    -- @description Verifies case: complete from available is rejected.
    -- @covers library.quest.Quest:complete
    -- @covers library.quest.newQuest
    it("complete from available is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        expect_equal(q:complete(), false)
        expect_equal(q.status, "available")
    end)

    -- @description Verifies case: fail from available is rejected.
    -- @covers library.quest.Quest:fail
    -- @covers library.quest.newQuest
    it("fail from available is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        expect_equal(q:fail(), false)
        expect_equal(q.status, "available")
    end)

    -- @description Verifies case: start from completed is rejected.
    -- @covers library.quest.Quest:complete
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("start from completed is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        q:start()
        q:complete()
        expect_equal(q:start(), false)
        expect_equal(q.status, "completed")
    end)

    -- @description Verifies case: start from failed is rejected.
    -- @covers library.quest.Quest:fail
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("start from failed is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        q:start()
        q:fail()
        expect_equal(q:start(), false)
        expect_equal(q.status, "failed")
    end)

    -- @description Verifies case: fail from completed is rejected.
    -- @covers library.quest.Quest:complete
    -- @covers library.quest.Quest:fail
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("fail from completed is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        q:start()
        q:complete()
        expect_equal(q:fail(), false)
        expect_equal(q.status, "completed")
    end)

    -- @description Verifies case: complete from failed is rejected.
    -- @covers library.quest.Quest:complete
    -- @covers library.quest.Quest:fail
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("complete from failed is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        q:start()
        q:fail()
        expect_equal(q:complete(), false)
        expect_equal(q.status, "failed")
    end)

    -- @description Verifies case: double start is rejected.
    -- @covers library.quest.Quest:start
    -- @covers library.quest.newQuest
    it("double start is rejected", function()
        local q = quest.newQuest("q1", "Quest 1")
        expect_equal(q:start(), true)
        expect_equal(q:start(), false)
        expect_equal(q.status, "active")
    end)
end)

-- @description Tests that journal entries are purged when max_journal_entries is set.
describe("Quest journal max-entry limit", function()
    -- @description Verifies case: journal respects max_journal_entries.
    -- @covers library.quest.Quest:addJournalEntry
    -- @covers library.quest.newQuest
    it("trims oldest entries when exceeding limit", function()
        local q = quest.newQuest("q1", "Quest 1", 3)
        q:addJournalEntry("entry1", "a")
        q:addJournalEntry("entry2", "b")
        q:addJournalEntry("entry3", "c")
        expect_equal(#q.journal, 3)
        q:addJournalEntry("entry4", "d")
        expect_equal(#q.journal, 3)
        -- oldest entry (entry1) should be gone
        expect_equal(q.journal[1].text, "entry2")
        expect_equal(q.journal[3].text, "entry4")
    end)

    -- @description Verifies case: nil max means unlimited.
    -- @covers library.quest.Quest:addJournalEntry
    -- @covers library.quest.newQuest
    it("nil max means unlimited journal", function()
        local q = quest.newQuest("q1", "Quest 1")
        for i = 1, 100 do
            q:addJournalEntry("entry" .. i)
        end
        expect_equal(#q.journal, 100)
    end)

    -- @description Verifies case: max of 1 keeps only latest.
    -- @covers library.quest.Quest:addJournalEntry
    -- @covers library.quest.newQuest
    it("max of 1 keeps only the latest entry", function()
        local q = quest.newQuest("q1", "Quest 1", 1)
        q:addJournalEntry("first")
        q:addJournalEntry("second")
        expect_equal(#q.journal, 1)
        expect_equal(q.journal[1].text, "second")
    end)
end)

-- @description Tests input validation for quest and objective constructors.
describe("Input validation", function()
    -- @description Verifies case: newQuest rejects empty id.
    -- @covers library.quest.newQuest
    it("newQuest rejects empty id", function()
        expect_error(function() quest.newQuest("", "Title") end)
    end)

    -- @description Verifies case: newQuest rejects non-string id.
    -- @covers library.quest.newQuest
    it("newQuest rejects non-string id", function()
        expect_error(function() quest.newQuest(123, "Title") end)
    end)

    -- @description Verifies case: newObjective rejects negative required.
    -- @covers library.quest.newObjective
    it("newObjective rejects negative required", function()
        expect_error(function() quest.newObjective("id", "desc", -1) end)
    end)

    -- @description Verifies case: advance rejects zero amount.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.newObjective
    it("advance rejects zero amount", function()
        local obj = quest.newObjective("id", "desc", 3)
        expect_error(function() obj:advance(0) end)
    end)

    -- @description Verifies case: advance rejects negative amount.
    -- @covers library.quest.Objective:advance
    -- @covers library.quest.newObjective
    it("advance rejects negative amount", function()
        local obj = quest.newObjective("id", "desc", 3)
        expect_error(function() obj:advance(-1) end)
    end)

    -- @description Verifies case: setProgress rejects non-number.
    -- @covers library.quest.Objective:setProgress
    -- @covers library.quest.newObjective
    it("setProgress rejects non-number", function()
        local obj = quest.newObjective("id", "desc", 3)
        expect_error(function() obj:setProgress("abc") end)
    end)

    -- @description Verifies case: addJournalEntry rejects non-string text.
    -- @covers library.quest.Quest:addJournalEntry
    -- @covers library.quest.newQuest
    it("addJournalEntry rejects non-string text", function()
        local q = quest.newQuest("q1", "Quest 1")
        expect_error(function() q:addJournalEntry(123) end)
    end)
end)

test_summary()
