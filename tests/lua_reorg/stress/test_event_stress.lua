-- Lurek2D Stress Test: Signal Dispatch Throughput
-- Measures signal emit performance under high listener counts.

local function new_signal_with_counting_listeners(listener_count, event_name)
    local sig = lurek.event.newSignal()
    local count = 0
    for _ = 1, listener_count do
        sig:connect(event_name, function()
            count = count + 1
        end)
    end
    return sig, function()
        return count
    end
end

local function emit_signal_many(sig, emits, event_name)
    for _ = 1, emits do
        sig:emit(event_name)
    end
end

local function connect_and_remove_many(sig, count)
    return measure("signal connect+disconnect x" .. count, count, function()
        local conn = sig:connect("stress", function() end)
        sig:remove(conn)
    end)
end

local function build_signal_pool(signal_count, listener_count, total_ref)
    local sigs = {}
    for _ = 1, signal_count do
        local s = lurek.event.newSignal()
        for _ = 1, listener_count do
            s:connect("stress", function()
                total_ref.value = total_ref.value + 1
            end)
        end
        sigs[#sigs + 1] = s
    end
    return sigs
end

local function payload_roundtrip_dispatches(sig, emits)
    local count = 0
    local checksum = 0
    sig:connect("payload", function(v)
        count = count + 1
        checksum = checksum + v
    end)
    for i = 1, emits do
        sig:emit("payload", i)
    end
    return count, checksum
end

-- @describe stress: signal emit to many listeners
describe("stress: signal emit to many listeners", function()
    -- @stress LSignal:emit
    it("1 signal       1000 listeners       100 emits: <5s", function()
        local sig, count_ref = new_signal_with_counting_listeners(100, "stress")
        local LISTENERS = 100
        local EMITS     = 1000

        local start = os.clock()
        emit_signal_many(sig, EMITS, "stress")
        local elapsed = os.clock() - start
        local dispatches = LISTENERS * EMITS
        print(string.format("[STRESS] signal: %d dispatches in %.4fs (%.0f/sec)",
            dispatches, elapsed, dispatches / elapsed))

        expect_true(elapsed < 5.0, "signal dispatch budget: " .. elapsed .. "s")
        expect_equal(dispatches, count_ref(), "all listeners fired")
    end)

    -- @stress LSignal:remove
    it("signal connect/disconnect 5000 times in <5s", function()
        local sig   = lurek.event.newSignal()
        local COUNT = 5000
        local elapsed = connect_and_remove_many(sig, COUNT)
        expect_true(elapsed < 5.0, "connect/disconnect budget: " .. elapsed .. "s")
    end)

    -- @stress lurek.event.newSignal
    it("10 signals       100 listeners       1000 emits each: <10s", function()
        local N_SIGS    = 10
        local N_LISTEN  = 100
        local N_EMITS   = 1000
        local total = { value = 0 }
        local sigs = build_signal_pool(N_SIGS, N_LISTEN, total)

        local start = os.clock()
        for _, s in ipairs(sigs) do
            for _ = 1, N_EMITS do s:emit("stress") end
        end
        local elapsed = os.clock() - start
        print(string.format("[STRESS] 10 sigs       100     1000: elapsed=%.4fs", elapsed))

        expect_true(elapsed < 10.0, "multi-signal budget: " .. elapsed .. "s")
        expect_equal(N_SIGS * N_LISTEN * N_EMITS, total.value, "all dispatches fired")
    end)

    -- @stress LSignal:connect
    it("payload forwarding stays consistent across 5000 emits", function()
        local sig = lurek.event.newSignal()
        local count, checksum = payload_roundtrip_dispatches(sig, 5000)
        local expected_sum = (5000 * 5001) / 2
        expect_equal(5000, count, "all payload emits reached listener")
        expect_equal(expected_sum, checksum, "payload values preserved under load")
    end)
end)
test_summary()
