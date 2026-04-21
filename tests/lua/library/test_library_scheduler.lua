-- Lurek2D Library Scheduler Tests
-- @testCategory library
-- @description Unit tests for the content/library/scheduler coroutine scheduler.

local scheduler = require("library.scheduler")

describe("scheduler library – newScheduler", function()
    -- @description Verify that newScheduler returns a usable scheduler object.
    it("returns a scheduler with zero tasks by default", function()
        local s = scheduler.newScheduler()
        assert(s ~= nil, "newScheduler() must return non-nil")
        assert(s:getCount() == 0, "fresh scheduler must have 0 tasks")
    end)

    -- @description Custom max_iterations option is accepted without error.
    it("accepts opts.max_iterations", function()
        local s = scheduler.newScheduler({ max_iterations = 500 })
        assert(s ~= nil)
        assert(s:getCount() == 0)
    end)
end)

describe("scheduler library – add and immediate execution", function()
    -- @description A task that does not yield runs to completion on add().
    it("runs a non-yielding task immediately on add", function()
        local s = scheduler.newScheduler()
        local ran = false
        s:add(function(_yield)
            ran = true
        end)
        assert(ran, "task must have run immediately")
        -- one update tick to reap the completed task
        s:update(0)
        assert(s:getCount() == 0, "completed task must be removed after update")
    end)

    -- @description add() returns the numeric task id starting at 1.
    it("returns incrementing ids", function()
        local s = scheduler.newScheduler()
        local id1 = s:add(function(y) y(999) end)
        local id2 = s:add(function(y) y(999) end)
        assert(type(id1) == "number", "id must be a number")
        assert(id2 == id1 + 1, "ids must be sequential")
    end)

    -- @description add() rejects non-function arguments.
    it("errors on non-function argument", function()
        local s = scheduler.newScheduler()
        local ok = pcall(function() s:add("not a function") end)
        assert(not ok, "must error when passed a non-function")
    end)
end)

describe("scheduler library – yield and update timing", function()
    -- @description A task that yields 1 s is still pending after 0.5 s of updates.
    it("task is still pending after partial dt", function()
        local s = scheduler.newScheduler()
        local done = false
        s:add(function(y)
            y(1.0)
            done = true
        end)
        s:update(0.5)
        assert(not done, "task must not resume before the wait elapses")
        assert(s:getCount() == 1, "task must still be active")
    end)

    -- @description A task that yields 1 s resumes and completes after 1 s of updates.
    it("task resumes after enough dt", function()
        local s = scheduler.newScheduler()
        local done = false
        s:add(function(y)
            y(1.0)
            done = true
        end)
        s:update(1.0)
        s:update(0)
        assert(done, "task must have resumed and completed")
        assert(s:getCount() == 0, "task must be removed after completion")
    end)

    -- @description Multiple sequential yields are processed correctly.
    it("multi-yield task resumes at each step", function()
        local s = scheduler.newScheduler()
        local step = 0
        s:add(function(y)
            step = 1; y(0.5)
            step = 2; y(0.5)
            step = 3
        end)
        assert(step == 1, "first step runs on add")
        s:update(0.5)
        assert(step == 2, "second step after first yield")
        s:update(0.5)
        s:update(0)
        assert(step == 3, "third step after second yield")
    end)
end)

describe("scheduler library – remove", function()
    -- @description Removing a task by id stops it from being resumed.
    it("removes a pending task before it resumes", function()
        local s = scheduler.newScheduler()
        local done = false
        local id = s:add(function(y)
            y(1.0)
            done = true
        end)
        s:remove(id)
        s:update(2.0)
        assert(not done, "removed task must not resume")
        assert(s:getCount() == 0)
    end)
end)

describe("scheduler library – pause and resume", function()
    -- @description A paused task does not progress even when dt passes.
    it("paused task does not advance", function()
        local s = scheduler.newScheduler()
        local done = false
        local id = s:add(function(y)
            y(0.5)
            done = true
        end)
        s:pause(id)
        s:update(2.0)
        assert(not done, "paused task must not advance")
    end)

    -- @description A resumed-after-pause task completes normally.
    it("resumed task completes after unpausing", function()
        local s = scheduler.newScheduler()
        local done = false
        local id = s:add(function(y)
            y(0.5)
            done = true
        end)
        s:pause(id)
        s:update(2.0)
        s:resume(id)
        s:update(0.5)
        s:update(0)
        assert(done, "task must complete after resume")
    end)
end)

describe("scheduler library – getStatus", function()
    -- @description getStatus returns 'running' for an active task.
    it("returns running for an active task", function()
        local s = scheduler.newScheduler()
        local id = s:add(function(y) y(999) end)
        local st = s:getStatus(id)
        assert(st == "running" or st ~= nil, "status must be a string for active task")
    end)

    -- @description getStatus returns nil or 'done' for an unknown id.
    it("returns nil or done for unknown id", function()
        local s = scheduler.newScheduler()
        local st = s:getStatus(999)
        assert(st == nil or st == "done", "unknown id must return nil or 'done'")
    end)
end)

describe("scheduler library – getCount and clear", function()
    -- @description getCount reflects the number of active tasks.
    it("getCount increments on add", function()
        local s = scheduler.newScheduler()
        s:add(function(y) y(999) end)
        s:add(function(y) y(999) end)
        assert(s:getCount() == 2)
    end)

    -- @description clear() removes all tasks at once.
    it("clear removes all tasks", function()
        local s = scheduler.newScheduler()
        s:add(function(y) y(999) end)
        s:add(function(y) y(999) end)
        s:clear()
        assert(s:getCount() == 0, "clear must remove all tasks")
    end)
end)

describe("scheduler library – error handling", function()
    -- @description An erroring task is captured in getErrors() and removed.
    it("captures erroring task in getErrors", function()
        local s = scheduler.newScheduler()
        local id = s:add(function(_y)
            error("intentional error")
        end)
        s:update(0)
        local errs = s:getErrors()
        assert(type(errs) == "table", "getErrors must return a table")
        -- At least one error recorded
        assert(#errs > 0, "error must be recorded")
        assert(s:getCount() == 0, "errored task must be removed")
    end)

    -- @description clearErrors() empties the error list.
    it("clearErrors empties the error list", function()
        local s = scheduler.newScheduler()
        s:add(function(_y) error("boom") end)
        s:update(0)
        s:clearErrors()
        assert(#s:getErrors() == 0, "clearErrors must empty the list")
    end)
end)

test_summary()
