--- Lurek2D coroutine scheduler — a pure-Lua cooperative task runner.
--
-- A pure-Lua coroutine scheduler that integrates with the engine's update loop.
-- No engine dependencies; works in headless test VMs.
--
-- Usage:
--   local patterns = require("library.patterns")
--   local sched = patterns.newScheduler()
--   sched:add(function(yield)
--       print("start")
--       yield(1.0)    -- pause for 1 second of game time
--       print("after 1 second")
--   end)
--   -- each frame:
--   sched:update(dt)
--
-- @module library.patterns

local M = {}

-- ── Internal helpers ──────────────────────────────────────────────────────────

---@local
local function wrap_task(fn)
    local co = coroutine.create(fn)
    return {
        co      = co,
        wait    = 0.0,
        paused  = false,
        done    = false,
        id      = nil,          -- assigned by scheduler
    }
end

-- ── Scheduler ─────────────────────────────────────────────────────────────────

--- Create a new coroutine scheduler.
-- Manages a pool of coroutine tasks; each task can yield(seconds) to pause itself.
--
-- @return Scheduler — schedulerhandle
function M.newScheduler()

    ---@class Scheduler
    local sched = {
        _tasks   = {},
        _next_id = 1,
    }

    --- Add a new task function to the scheduler.
    -- The task receives a `yield` function as its first argument.
    -- Call `yield(seconds)` inside the task to pause for that long.
    --
    -- @param fn function — coroutine body: `function(yield) ... end`
    -- @return number — task id
    function sched:add(fn)
        local task = wrap_task(fn)
        task.id = self._next_id
        self._next_id = self._next_id + 1
        table.insert(self._tasks, task)
        -- Kick off: run until the first yield or return
        -- Pass the yield helper to the coroutine
        local yield_fn = function(seconds)
            coroutine.yield(seconds or 0)
        end
        local ok, wait = coroutine.resume(task.co, yield_fn)
        if not ok then
            task.done = true
        elseif coroutine.status(task.co) == "dead" then
            task.done = true
        else
            task.wait = type(wait) == "number" and wait or 0
        end
        return task.id
    end

    --- Remove a task by id.
    -- @param id number — task id returned by add()
    -- @return boolean — true if a task was removed
    function sched:remove(id)
        for i, t in ipairs(self._tasks) do
            if t.id == id then
                table.remove(self._tasks, i)
                return true
            end
        end
        return false
    end

    --- Pause a task by id.
    -- @param id number
    function sched:pause(id)
        for _, t in ipairs(self._tasks) do
            if t.id == id then
                t.paused = true
                return
            end
        end
    end

    --- Resume a paused task by id.
    -- @param id number
    function sched:resume(id)
        for _, t in ipairs(self._tasks) do
            if t.id == id then
                t.paused = false
                return
            end
        end
    end

    --- Step all active tasks by dt seconds.
    -- Tasks whose wait time has elapsed are resumed once per update call.
    --
    -- @param dt number — delta time in seconds
    function sched:update(dt)
        local i = 1
        while i <= #self._tasks do
            local t = self._tasks[i]
            if t.done then
                table.remove(self._tasks, i)
                -- do not increment i
            elseif not t.paused then
                t.wait = t.wait - dt
                if t.wait <= 0 then
                    local ok, wait = coroutine.resume(t.co)
                    if not ok or coroutine.status(t.co) == "dead" then
                        t.done = true
                        table.remove(self._tasks, i)
                        -- do not increment i
                    else
                        t.wait = type(wait) == "number" and wait or 0
                        i = i + 1
                    end
                else
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
    end

    --- Return the number of active (non-done) tasks.
    -- @return number
    function sched:getCount()
        return #self._tasks
    end

    --- Remove all tasks immediately.
    function sched:clear()
        self._tasks = {}
    end

    return sched
end

return M
