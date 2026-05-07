-- tests/lua/integration/test_automation_event.lua
-- Integration: lurek.automation <-> lurek.event

---@type any
local automation = lurek.automation

-- @describe automation + event integration
describe("automation + event integration", function()
    -- @covers lurek.automation.load
    -- @covers lurek.automation.start
    -- @covers lurek.automation.stop
    -- @covers lurek.automation.unload
    -- @covers lurek.automation.update
    -- @covers lurek.event.clear
    -- @covers lurek.event.wait
    it("dispatches queued key events with expected payload", function()
        lurek.event.clear()
        lurek.automation.load("evt_payload", {
            steps = {
                { action = "keypress", key = "a", scancode = "KeyA", isRepeat = true, time = 0.0 },
                { action = "keyrelease", key = "a", scancode = "KeyA", time = 0.01 },
            }
        })

        lurek.automation.start("evt_payload")
        lurek.automation.update(0.02)

        local ok1, name1, args1 = lurek.event.wait(0)
        expect_equal(ok1, true)
        expect_equal(name1, "keypressed")
        expect_equal(args1[1], "a")
        expect_equal(args1[2], "KeyA")
        expect_equal(args1[3], true)

        local ok2, name2, args2 = lurek.event.wait(0)
        expect_equal(ok2, true)
        expect_equal(name2, "keyreleased")
        expect_equal(args2[1], "a")
        expect_equal(args2[2], "KeyA")

        lurek.automation.stop()
        lurek.automation.unload("evt_payload")
        lurek.event.clear()
    end)

    -- @covers lurek.automation.getLastError
    -- @covers lurek.automation.isFailed
    -- @covers lurek.automation.load
    -- @covers lurek.automation.setCondition
    -- @covers lurek.automation.start
    -- @covers lurek.automation.stop
    -- @covers lurek.automation.unload
    -- @covers lurek.automation.update
    it("fails assert action when condition is false", function()
        lurek.automation.load("assert_fail", {
            steps = {
                { action = "assert", assert = "boss_dead", time = 0.0 },
            }
        })

        automation.setCondition("boss_dead", false)
        automation.start("assert_fail")
        automation.update(0.01)

        expect_equal(automation.isFailed(), true)
        local err = automation.getLastError()
        expect_type("string", err)

        automation.stop()
        automation.unload("assert_fail")
    end)

    -- @covers lurek.automation.isFailed
    -- @covers lurek.automation.load
    -- @covers lurek.automation.start
    -- @covers lurek.automation.stop
    -- @covers lurek.automation.unload
    -- @covers lurek.automation.update
    -- @covers lurek.image.newImageData
    -- @covers lurek.image.savePNG
    it("passes visualassert action on identical images", function()
        local img = lurek.image.newImageData(2, 2)
        img:setPixel(0, 0, 255, 0, 0, 255)
        img:setPixel(1, 0, 255, 0, 0, 255)
        img:setPixel(0, 1, 255, 0, 0, 255)
        img:setPixel(1, 1, 255, 0, 0, 255)

        lurek.image.savePNG(img, "save/automation/base.png")
        lurek.image.savePNG(img, "save/automation/actual.png")

        lurek.automation.load("visual_ok", {
            steps = {
                {
                    action = "visualassert",
                    baseline = "save/automation/base.png",
                    actual = "save/automation/actual.png",
                    maxDiff = 0,
                    time = 0.0,
                },
            }
        })

        automation.start("visual_ok")
        automation.update(0.01)
        expect_equal(automation.isFailed(), false)

        automation.stop()
        automation.unload("visual_ok")
    end)
end)

test_summary()
