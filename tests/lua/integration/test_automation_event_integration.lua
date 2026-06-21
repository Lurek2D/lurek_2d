-- Integration: automation script replay + event queue
-- @integration lurek.automation.isComplete
-- @integration lurek.automation.isFailed
-- @integration lurek.automation.load
-- @integration lurek.automation.saveMacro
-- @integration lurek.automation.setCondition
-- @integration lurek.automation.start
-- @integration lurek.automation.stop
-- @integration lurek.automation.unload
-- @integration lurek.automation.update
-- @integration lurek.event.clear
-- @integration lurek.event.poll
-- @integration lurek.event.wait
-- @integration lurek.image.newImageData
-- @integration lurek.image.savePNG




local automation = lurek.automation

-- @describe automation + event integration
describe("automation + event integration", function()
    -- @integration lurek.automation.load
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.event.clear
    -- @integration lurek.event.wait
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

    -- @integration lurek.automation.load
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.event.clear
    -- @integration lurek.event.wait
    it("defaults keypress scancode to key and repeat to false", function()
        lurek.event.clear()
        lurek.automation.load("key_defaults", {
            steps = {
                { action = "keypress", key = "a", time = 0.0 },
            }
        })
        lurek.automation.start("key_defaults")
        lurek.automation.update(0.01)

        local ok, name, args = lurek.event.wait(0)
        expect_equal(ok, true)
        expect_equal(name, "keypressed")
        expect_equal(args[1], "a")
        expect_equal(args[2], "a")
        expect_equal(args[3], false)

        lurek.automation.stop()
        lurek.automation.unload("key_defaults")
        lurek.event.clear()
    end)

    -- @integration lurek.automation.load
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.event.clear
    -- @integration lurek.event.wait
    it("prefers explicit scancode in queued keypress events", function()
        lurek.event.clear()
        lurek.automation.load("key_scancode", {
            steps = {
                { action = "keypress", key = "a", scancode = "KeyA", time = 0.0 },
            }
        })
        lurek.automation.start("key_scancode")
        lurek.automation.update(0.01)

        local ok, name, args = lurek.event.wait(0)
        expect_equal(ok, true)
        expect_equal(name, "keypressed")
        expect_equal(args[1], "a")
        expect_equal(args[2], "KeyA")
        expect_equal(args[3], false)

        lurek.automation.stop()
        lurek.automation.unload("key_scancode")
        lurek.event.clear()
    end)

    -- @integration lurek.automation.load
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.input.clearBindings
    -- @integration lurek.input.bind
    -- @integration lurek.input.wasActionPressed
    -- @integration lurek.input.keyboard.isDown
    -- @integration lurek.input.mouse.getPosition
    -- @integration lurek.input.mouse.getWheelDelta
    -- @integration lurek.input.mouse.isDown
    it("updates live input state and callbacks for keyboard and mouse automation", function()
        local seen = {}
        lurek.keypressed = function(key, scancode, is_repeat)
            seen.keypressed = { key, scancode, is_repeat }
        end
        lurek.keyreleased = function(key, scancode)
            seen.keyreleased = { key, scancode }
        end
        lurek.mousemoved = function(x, y, dx, dy)
            seen.mousemoved = { x, y, dx, dy }
        end
        lurek.mousepressed = function(x, y, button)
            seen.mousepressed = { x, y, button }
        end
        lurek.mousereleased = function(x, y, button)
            seen.mousereleased = { x, y, button }
        end
        lurek.wheelmoved = function(dx, dy)
            seen.wheelmoved = { dx, dy }
        end

        lurek.input.clearBindings()
        lurek.input.bind("jump", "a")
        lurek.input.bind("click", "mouse1")

        lurek.automation.load("live_input", {
            steps = {
                { action = "keypress", key = "a", scancode = "KeyA", time = 0.0 },
                { action = "mousemove", x = 120, y = 84, time = 0.01 },
                { action = "mousepress", x = 120, y = 84, button = 1, time = 0.02 },
                { action = "mousewheel", x = 0, y = -2, time = 0.03 },
                { action = "keyrelease", key = "a", scancode = "KeyA", time = 0.05 },
                { action = "mouserelease", x = 120, y = 84, button = 1, time = 0.06 },
            }
        })

        lurek.automation.start("live_input")
        lurek.automation.update(0.04)

        expect_equal("a", seen.keypressed[1])
        expect_equal("KeyA", seen.keypressed[2])
        expect_equal(false, seen.keypressed[3])
        expect_equal(120, seen.mousemoved[1])
        expect_equal(84, seen.mousemoved[2])
        expect_equal(120, seen.mousepressed[1])
        expect_equal(84, seen.mousepressed[2])
        expect_equal(1, seen.mousepressed[3])
        expect_equal(0, seen.wheelmoved[1])
        expect_equal(-2, seen.wheelmoved[2])
        expect_true(lurek.input.keyboard.isDown("a"))
        expect_true(lurek.input.wasActionPressed("jump"))
        expect_true(lurek.input.mouse.isDown(1))
        expect_true(lurek.input.wasActionPressed("click"))
        local mx, my = lurek.input.mouse.getPosition()
        expect_equal(120, mx)
        expect_equal(84, my)
        local wx, wy = lurek.input.mouse.getWheelDelta()
        expect_equal(0, wx)
        expect_equal(-2, wy)

        lurek.automation.update(0.03)

        expect_equal("a", seen.keyreleased[1])
        expect_equal("KeyA", seen.keyreleased[2])
        expect_equal(120, seen.mousereleased[1])
        expect_equal(84, seen.mousereleased[2])
        expect_equal(1, seen.mousereleased[3])
        expect_false(lurek.input.keyboard.isDown("a"))
        expect_false(lurek.input.mouse.isDown(1))

        lurek.automation.stop()
        lurek.automation.unload("live_input")
        lurek.input.clearBindings()
        lurek.keypressed = nil
        lurek.keyreleased = nil
        lurek.mousemoved = nil
        lurek.mousepressed = nil
        lurek.mousereleased = nil
        lurek.wheelmoved = nil
    end)

    -- @integration lurek.automation.isFailed
    -- @integration lurek.automation.load
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.image.newImageData
    -- @integration lurek.image.savePNG
    -- @integration LImageData:setPixel
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

    -- @integration lurek.automation.load
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.automation.setCondition
    -- @integration lurek.automation.isFailed
    -- @integration lurek.event.clear
    -- @integration lurek.event.wait
    it("supports boolean expressions in when gates", function()
        lurek.event.clear()
        automation.setCondition("ready", true)
        automation.setCondition("paused", true)

        automation.load("expr_when", {
            steps = {
                {
                    action = "keypress",
                    key = "z",
                    when = "ready && !paused",
                    time = 0.0,
                },
            }
        })

        automation.start("expr_when")
        automation.update(0.02)
        local ok1 = lurek.event.wait(0)
        expect_equal(ok1, false)

        automation.stop()
        automation.setCondition("paused", false)
        automation.start("expr_when")
        automation.update(0.02)

        local ok2, name = lurek.event.wait(0)
        expect_equal(ok2, true)
        expect_equal(name, "keypressed")

        automation.stop()
        automation.unload("expr_when")
        lurek.event.clear()
    end)

    -- @integration lurek.automation.isComplete
    -- @integration lurek.automation.load
    -- @integration lurek.automation.saveMacro
    -- @integration lurek.automation.start
    -- @integration lurek.automation.stop
    -- @integration lurek.automation.unload
    -- @integration lurek.automation.update
    -- @integration lurek.event.clear
    -- @integration lurek.event.poll
    it("callmacro expands a saved macro into queued events", function()
        lurek.event.clear()
        automation.load("macro_src_ext", {
            steps = { { action = "textinput", text = "hello", time = 0.0 } }
        })
        automation.saveMacro("macro_ext", "macro_src_ext")

        automation.load("macro_call", {
            steps = { { action = "callmacro", macro = "macro_ext", time = 0.0 } }
        })

        automation.start("macro_call")
        automation.update(0.05)

        local names = {}
        for name in lurek.event.poll() do
            table.insert(names, name)
        end

        expect_equal(1, #names)
        expect_equal("textinput", names[1])
        expect_true(automation.isComplete())

        automation.stop()
        automation.unload("macro_src_ext")
        automation.unload("macro_call")
        lurek.event.clear()
    end)
end)
test_summary()
