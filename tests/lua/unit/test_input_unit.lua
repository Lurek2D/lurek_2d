-- tests/lua/unit/test_input_unit.lua
-- Complementary input userdata coverage that avoids duplicating the broader core suite.

local function fresh_recording()
    lurek.input.stopRecording()
    lurek.input.startRecording()
    return lurek.input.stopRecording()
end

-- @describe lurek.input userdata handles
describe("lurek.input userdata handles", function()
    -- @covers LCursor:type
    it("system cursors report their userdata type name", function()
        local cursor = lurek.input.mouse.getSystemCursor("arrow")
        expect_equal("LCursor", cursor:type())
    end)

    -- @covers LCursor:typeOf
    it("system cursors match the LCursor type guard", function()
        local cursor = lurek.input.mouse.getSystemCursor("hand")
        expect_true(cursor:typeOf("LCursor"))
    end)

    -- @covers LCombo:progress
    it("combo progress advances after feeding the first matching step", function()
        local combo = lurek.input.newCombo({"a", "b"})
        expect_equal(0, combo:progress())
        combo:feed("a")
        expect_equal(1, combo:progress())
    end)

    -- @covers LCombo:type
    it("combo detectors report the LCombo type name", function()
        local combo = lurek.input.newCombo({"left", "right"})
        expect_equal("LCombo", combo:type())
    end)

    -- @covers LCombo:typeOf
    it("combo detectors match the LCombo type guard", function()
        local combo = lurek.input.newCombo({"up", "down"})
        expect_true(combo:typeOf("LCombo"))
    end)

    -- @covers LInputRecording:type
    it("stopped recordings report the LInputRecording type name", function()
        local rec = fresh_recording()
        expect_equal("LInputRecording", rec:type())
    end)

    -- @covers LInputRecording:typeOf
    it("stopped recordings match the LInputRecording type guard", function()
        local rec = fresh_recording()
        expect_true(rec:typeOf("LInputRecording"))
    end)
end)

test_summary()
