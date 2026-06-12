-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_event_core_unit.lua
do
-- tests/lua/unit/test_event_core_unit.lua
-- Canonical Lua unit tests for lurek.event and LSignal.

local function reset_shared_event_state()
    lurek.event.clear()
    lurek.event.clearHistory()
    lurek.event.enableHistory(0)
end

local function collect_polled_events()
    local events = {}
    for name, a1, a2, a3 in lurek.event.poll() do
        table.insert(events, {
            name = name,
            args = { a1, a2, a3 },
        })
    end
    return events
end

local function new_signal()
    local sig = lurek.event.newSignal()
    expect_not_nil(sig, "newSignal should return a userdata")
    return sig
end

-- @describe lurek.event shared queue
describe("lurek.event shared queue", function()
    before_each(reset_shared_event_state)
    after_each(reset_shared_event_state)

    -- @covers lurek.event.push
    it("push queues a normal event with payload values", function()
        lurek.event.push("player_hit", 25, "critical")

        local events = collect_polled_events()
        expect_equal(1, #events)
        expect_equal("player_hit", events[1].name)
        expect_equal(25, events[1].args[1])
        expect_equal("critical", events[1].args[2])
    end)

    -- @covers lurek.event.pushPriority
    it("pushPriority drains the high lane before normal events", function()
        lurek.event.push("normal_evt", 1)
        lurek.event.pushPriority("high_evt", "high", 2)

        local events = collect_polled_events()
        expect_equal(2, #events)
        expect_equal("high_evt", events[1].name)
        expect_equal(2, events[1].args[1])
        expect_equal("normal_evt", events[2].name)
        expect_equal(1, events[2].args[1])
    end)

    -- @covers lurek.event.pushDeferred
    it("pushDeferred keeps events out of the live queue until flush", function()
        lurek.event.pushDeferred("scene_ready", "main_menu")

        local before_flush = collect_polled_events()
        expect_equal(0, #before_flush)

        local moved = lurek.event.flushDeferred()
        expect_equal(1, moved)

        local after_flush = collect_polled_events()
        expect_equal(1, #after_flush)
        expect_equal("scene_ready", after_flush[1].name)
        expect_equal("main_menu", after_flush[1].args[1])
    end)

    -- @covers lurek.event.pushDeferredPriority
    it("pushDeferredPriority preserves priority order after flush", function()
        lurek.event.pushDeferred("normal_deferred", "slow")
        lurek.event.pushDeferredPriority("high_deferred", "high", "fast")

        expect_equal(2, lurek.event.flushDeferred())

        local events = collect_polled_events()
        expect_equal(2, #events)
        expect_equal("high_deferred", events[1].name)
        expect_equal("fast", events[1].args[1])
        expect_equal("normal_deferred", events[2].name)
        expect_equal("slow", events[2].args[1])
    end)

    -- @covers lurek.event.flushDeferred
    it("flushDeferred returns the number of moved deferred events", function()
        lurek.event.pushDeferred("a", 1)
        lurek.event.pushDeferred("b", 2)

        local moved = lurek.event.flushDeferred()
        expect_equal(2, moved)

        local events = collect_polled_events()
        expect_equal(2, #events)
    end)

    -- @covers lurek.event.poll
    it("poll returns an iterator that drains queued events in order", function()
        lurek.event.push("ev1", 10)
        lurek.event.push("ev2", 20)

        local poll_iter = lurek.event.poll()
        expect_type("function", poll_iter)

        local names = {}
        for name, value in poll_iter do
            table.insert(names, name)
            table.insert(names, value)
        end

        expect_equal(4, #names)
        expect_equal("ev1", names[1])
        expect_equal(10, names[2])
        expect_equal("ev2", names[3])
        expect_equal(20, names[4])
    end)

    -- @covers lurek.event.wait
    it("wait returns timeout and ready tuples correctly", function()
        local timed_out, empty_name, empty_args = lurek.event.wait(0.01)
        expect_false(timed_out)
        expect_equal("", empty_name)
        expect_type("table", empty_args)
        expect_equal(0, #empty_args)

        lurek.event.push("wake_up", "now")
        local ok, name, args = lurek.event.wait(0)
        expect_true(ok)
        expect_equal("wake_up", name)
        expect_type("table", args)
        expect_equal(1, #args)
        expect_equal("now", args[1])
    end)

    -- @covers lurek.event.clear
    it("clear removes all queued live events", function()
        lurek.event.push("discard_me", 1)
        lurek.event.push("discard_me_too", 2)
        lurek.event.clear()

        local events = collect_polled_events()
        expect_equal(0, #events)
    end)

    -- @covers lurek.event.pump
    it("pump is exposed and runs without error", function()
        expect_type("function", lurek.event.pump)
        expect_no_error(function()
            lurek.event.pump()
        end)
    end)

    -- @covers lurek.event.enableHistory
    it("enableHistory enforces the requested retention capacity", function()
        lurek.event.enableHistory(1)
        lurek.event.push("first", 1)
        lurek.event.push("second", 2)

        local history = lurek.event.getHistory()
        expect_equal(1, #history)
        expect_equal("second", history[1].name)
        expect_equal(2, history[1].args[1])
    end)

    -- @covers lurek.event.getHistory
    it("getHistory returns entries with name and args fields", function()
        lurek.event.enableHistory(4)
        lurek.event.push("score", 999, "gold")

        local history = lurek.event.getHistory()
        expect_type("table", history)
        expect_equal(1, #history)
        expect_equal("score", history[1].name)
        expect_type("table", history[1].args)
        expect_equal(999, history[1].args[1])
        expect_equal("gold", history[1].args[2])
    end)

    -- @covers lurek.event.clearHistory
    it("clearHistory removes retained entries", function()
        lurek.event.enableHistory(4)
        lurek.event.push("histA", 1)
        lurek.event.push("histB", 2)
        expect_equal(2, #lurek.event.getHistory())

        lurek.event.clearHistory()

        local history = lurek.event.getHistory()
        expect_equal(0, #history)
    end)

    -- @covers lurek.event.exit
    it("exit is exposed as a function", function()
        expect_type("function", lurek.event.exit)
    end)

    -- @covers lurek.event.quit
    it("quit is exposed as a function alias", function()
        expect_type("function", lurek.event.quit)
    end)

    -- @covers lurek.event.restart
    it("restart is exposed as a function", function()
        expect_type("function", lurek.event.restart)
    end)
end)

-- @describe LSignal methods
describe("LSignal methods", function()
    -- @covers lurek.event.newSignal
    it("newSignal creates an isolated signal userdata", function()
        local sig = lurek.event.newSignal()
        expect_not_nil(sig)
        expect_equal("LSignal", sig:type())
    end)

    -- @covers LSignal:connect
    it("connect supports wildcard patterns and returns a handle", function()
        local sig = new_signal()
        local fired = false

        local handle = sig:connect("player.*", function(kind)
            fired = (kind == "jump")
        end)

        expect_type("number", handle)
        expect_true(handle > 0)

        sig:emit("player.jump", "jump")
        expect_true(fired)
    end)

    -- @covers LSignal:register
    it("register adds an exact-name listener and returns a handle", function()
        local sig = new_signal()
        local handle = sig:register("heal", function() end)

        expect_type("number", handle)
        expect_true(handle > 0)
        expect_equal(1, sig:getCount("heal"))
    end)

    -- @covers LSignal:registerWithFilter
    it("registerWithFilter only fires callbacks accepted by the predicate", function()
        local sig = new_signal()
        local hits = 0

        sig:registerWithFilter("hit", function(dmg)
            hits = hits + dmg
        end, function(dmg)
            return dmg > 50
        end)

        sig:emit("hit", 10)
        sig:emit("hit", 75)
        expect_equal(75, hits)
    end)

    -- @covers LSignal:once
    it("once removes the listener after the first matching emit", function()
        local sig = new_signal()
        local count = 0

        local handle = sig:once("init", function()
            count = count + 1
        end)

        expect_type("number", handle)
        sig:emit("init")
        sig:emit("init")
        expect_equal(1, count)
    end)

    -- @covers LSignal:emit
    it("emit forwards arguments to matching listeners", function()
        local sig = new_signal()
        local received_a = nil
        local received_b = nil

        sig:connect("ping", function(a, b)
            received_a = a
            received_b = b
        end)

        sig:emit("ping", 4, "ok")
        expect_equal(4, received_a)
        expect_equal("ok", received_b)
    end)

    -- @covers LSignal:remove
    it("remove unregisters only the selected listener handle", function()
        local sig = new_signal()
        local count_a = 0
        local count_b = 0

        local handle_a = sig:connect("tick", function()
            count_a = count_a + 1
        end)
        sig:connect("tick", function()
            count_b = count_b + 1
        end)

        expect_true(sig:remove(handle_a))
        sig:emit("tick")
        expect_equal(0, count_a)
        expect_equal(1, count_b)
        expect_false(sig:remove(handle_a))
    end)

    -- @covers LSignal:clear
    it("clear removes listeners for one event name only", function()
        local sig = new_signal()
        sig:connect("click", function() end)
        sig:connect("click", function() end)
        sig:connect("hover", function() end)

        local removed = sig:clear("click")
        expect_equal(2, removed)
        expect_equal(0, sig:getCount("click"))
        expect_equal(1, sig:getCount("hover"))
    end)

    -- @covers LSignal:clearAll
    it("clearAll empties every listener bucket", function()
        local sig = new_signal()
        sig:connect("a", function() end)
        sig:connect("b", function() end)
        sig:connect("b", function() end)

        expect_equal(3, sig:getTotalCount())
        expect_equal(3, sig:clearAll())
        expect_equal(0, sig:getTotalCount())
    end)

    -- @covers LSignal:getCount
    it("getCount returns the number of exact-name listeners", function()
        local sig = new_signal()
        sig:register("click", function() end)
        sig:register("click", function() end)
        sig:register("hover", function() end)

        expect_equal(2, sig:getCount("click"))
        expect_equal(1, sig:getCount("hover"))
        expect_equal(0, sig:getCount("missing"))
    end)

    -- @covers LSignal:getTotalCount
    it("getTotalCount returns the total number of listeners", function()
        local sig = new_signal()
        expect_equal(0, sig:getTotalCount())

        sig:register("a", function() end)
        sig:register("b", function() end)
        sig:register("b", function() end)
        expect_equal(3, sig:getTotalCount())
    end)

    -- @covers LSignal:type
    it("type returns the LSignal type name", function()
        local sig = new_signal()
        expect_equal("LSignal", sig:type())
    end)

    -- @covers LSignal:typeOf
    it("typeOf matches signal and base object identities only", function()
        local sig = new_signal()
        expect_true(sig:typeOf("LSignal"))
        expect_true(sig:typeOf("LObject"))
        expect_false(sig:typeOf("LEntity"))
    end)
end)
end
-- END test_event_core_unit.lua

test_summary()
