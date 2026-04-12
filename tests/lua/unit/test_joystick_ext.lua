-- tests/lua/test_joystick_ext.lua
-- BDD-style integration tests for lurek.gamepad background events extension

-- @description Covers suite: lurek.gamepad.getBackgroundEvents.
describe("lurek.gamepad.getBackgroundEvents", function()
    -- @covers lurek.gamepad.getBackgroundEvents
    -- @covers lurek.gamepad.setBackgroundEvents
    -- @description Verifies background joystick events are disabled by default.
    it("defaults to false", function()
        expect_equal(false, lurek.gamepad.getBackgroundEvents())
    end)
end)

-- @description Covers suite: lurek.gamepad.setBackgroundEvents.
describe("lurek.gamepad.setBackgroundEvents", function()
    -- @covers lurek.gamepad.setBackgroundEvents
    -- @covers lurek.gamepad.getBackgroundEvents
    -- @description Verifies enabling background events updates the stored gamepad setting.
    it("can enable background events", function()
        lurek.gamepad.setBackgroundEvents(true)
        expect_equal(true, lurek.gamepad.getBackgroundEvents())
    end)

    -- @covers lurek.gamepad.setBackgroundEvents
    -- @covers lurek.gamepad.getBackgroundEvents
    -- @description Verifies the background-event flag can be turned back off after being enabled.
    it("can disable background events", function()
        lurek.gamepad.setBackgroundEvents(true)
        lurek.gamepad.setBackgroundEvents(false)
        expect_equal(false, lurek.gamepad.getBackgroundEvents())
    end)
end)
test_summary()
