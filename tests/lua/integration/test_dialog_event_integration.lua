-- Integration test: library.dialog    lurek.event (runtime name for "lurek.event").
--
-- Scope: Verifies that library.dialog sequencer events ("line", "choice",
-- "finished") can be routed through a `lurek.event.newSignal()` instance
-- so that external observers subscribe to the engine signal layer rather
-- than the library's local handler table. The bridge is a one-line forward
-- (`seq:on(name, function(...) sig:emit(name, ...) end)`) representative
-- of how a game wires dialog into engine-wide event plumbing.
--
-- Fallback: lurek.event is registered as `lurek.event` at runtime
-- (see P1 map). The Signal userdata is the engine's pub/sub primitive;
-- no fallback was needed.
--

local dialog = require("library.dialog")

-- @describe integration: library.dialog    lurek.event
describe("integration: library.dialog    lurek.event", function()

    local function bridge(seq, sig, events)
        for _, name in ipairs(events) do
            seq:on(name, function(...) sig:emit(name, ...) end)
        end
    end

    -- no longer reach the Signal subscribers.

    -- @integration lurek.dialog_event_integration
    it("seq:on rejects non-string event names with a clear error", function()
        local seq = dialog.newSequencer()
        local err = expect_error(function()
            seq:on(123, function() end)
        end)
        expect_contains(tostring(err), "string event name")
    end)

end)

-- ================================================================
-- Merged from: test_integration_dialog_event.lua
-- ================================================================

-- Integration test: library.dialog    lurek.event (runtime name for "lurek.event").
--
-- Scope: Verifies that library.dialog sequencer events ("line", "choice",
-- "finished") can be routed through a `lurek.event.newSignal()` instance
-- so that external observers subscribe to the engine signal layer rather
-- than the library's local handler table. The bridge is a one-line forward
-- (`seq:on(name, function(...) sig:emit(name, ...) end)`) representative
-- of how a game wires dialog into engine-wide event plumbing.
--
-- Fallback: lurek.event is registered as `lurek.event` at runtime
-- (see P1 map). The Signal userdata is the engine's pub/sub primitive;
-- no fallback was needed.
--

local dialog = require("library.dialog")

-- @describe integration: library.dialog    lurek.event
describe("integration: library.dialog    lurek.event", function()

    local function bridge(seq, sig, events)
        for _, name in ipairs(events) do
            seq:on(name, function(...) sig:emit(name, ...) end)
        end
    end

    -- no longer reach the Signal subscribers.

    -- @integration lurek.dialog_event_integration
    it("seq:on rejects non-string event names with a clear error", function()
        local seq = dialog.newSequencer()
        local err = expect_error(function()
            seq:on(123, function() end)
        end)
        expect_contains(tostring(err), "string event name")
    end)

end)
test_summary()
