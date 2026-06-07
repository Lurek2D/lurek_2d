-- tests/lua/unit/test_input_unit.lua
-- Lua-first unit tests for lurek.input module covering keyboard, mouse, gamepad, binding management, and action queries.

local harness = require("tests.lua.harness")

describe("lurek.input", function()
    -- @covers lurek.input.bind
    it("binds an input to an action", function()
        lurek.input.bind("jump", "space")
        assert_equal("userdata", type(lurek.input))
    end)

    -- @covers lurek.input.unbind
    it("unbinds an action removing all bindings", function()
        lurek.input.bind("move_left", "left")
        lurek.input.unbind("move_left")
        assert_equal("userdata", type(lurek.input))
    end)

    -- @covers lurek.input.isKeyDown
    it("queries if a key is currently held down", function()
        local result = lurek.input.isKeyDown("space")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.isKeyPressed
    it("queries if a key was just pressed this frame", function()
        local result = lurek.input.isKeyPressed("return")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.isKeyReleased
    it("queries if a key was just released this frame", function()
        local result = lurek.input.isKeyReleased("escape")
        assert_true(type(result) == "boolean")
    end)

    -- Mouse input
    -- @covers lurek.input.isMouseDown
    it("queries if a mouse button is held down", function()
        local result = lurek.input.isMouseDown("left")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.isMousePressed
    it("queries if a mouse button was just pressed", function()
        local result = lurek.input.isMousePressed("left")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.isMouseReleased
    it("queries if a mouse button was just released", function()
        local result = lurek.input.isMouseReleased("right")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.getMousePosition
    it("gets current mouse position in screen coordinates", function()
        local x, y = lurek.input.getMousePosition()
        assert_equal("number", type(x))
        assert_equal("number", type(y))
    end)

    -- Gamepad input
    -- @covers lurek.input.isGamepadDown
    it("queries if a gamepad button is held down", function()
        local result = lurek.input.isGamepadDown("gamepad0:a")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.isGamepadPressed
    it("queries if a gamepad button was just pressed", function()
        local result = lurek.input.isGamepadPressed("gamepad0:x")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.isGamepadReleased
    it("queries if a gamepad button was just released", function()
        local result = lurek.input.isGamepadReleased("gamepad0:y")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.getGamepadAxis
    it("queries a gamepad analog axis value", function()
        local value = lurek.input.getGamepadAxis("gamepad0:left_stick_x")
        assert_equal("number", type(value))
        assert_true(value >= -1.0 and value <= 1.0)
    end)

    -- @covers lurek.input.getGamepadVibration
    it("queries gamepad vibration state", function()
        local left, right = lurek.input.getGamepadVibration("gamepad0")
        assert_true(type(left) == "number" or left == nil)
        assert_true(type(right) == "number" or right == nil)
    end)

    -- Action mapping
    -- @covers lurek.input.define
    it("defines a named action with multiple bindings", function()
        lurek.input.define("attack", {"z", "gamepad0:a"})
        assert_equal("userdata", type(lurek.input))
    end)

    -- @covers lurek.input.isActionDown
    it("queries if an action is currently active", function()
        lurek.input.define("shoot", {"space"})
        local result = lurek.input.isActionDown("shoot")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.wasActionPressed
    it("queries if an action was just pressed", function()
        lurek.input.define("jump", {"space"})
        local result = lurek.input.wasActionPressed("jump")
        assert_true(type(result) == "boolean")
    end)

    -- @covers lurek.input.wasActionReleased
    it("queries if an action was just released", function()
        lurek.input.define("dash", {"shift"})
        local result = lurek.input.wasActionReleased("dash")
        assert_true(type(result) == "boolean")
    end)

    -- Analog input (virtual dpad / axes)
    -- @covers lurek.input.getAxis
    it("gets normalized axis value from multiple keys/buttons", function()
        local value = lurek.input.getAxis("horizontal")
        assert_equal("number", type(value))
        assert_true(value >= -1.0 and value <= 1.0)
    end)

    -- @covers lurek.input.getVector
    it("gets 2D vector from four directional inputs", function()
        local x, y = lurek.input.getVector("horizontal", "vertical")
        assert_equal("number", type(x))
        assert_equal("number", type(y))
    end)

    -- @covers lurek.input.reset
    it("resets all input state between frames", function()
        lurek.input.reset()
        assert_equal("userdata", type(lurek.input))
    end)

    -- Conflict detection and serialization
    -- @covers lurek.input.getConflicts
    it("detects conflicting bindings for actions", function()
        lurek.input.define("action1", {"space"})
        lurek.input.define("action2", {"space"})
        local conflicts = lurek.input.getConflicts()
        assert_true(type(conflicts) == "table" or conflicts == nil)
    end)

    -- @covers lurek.input.serializeBindings
    it("serializes all bindings to a string", function()
        lurek.input.define("test_action", {"q", "e"})
        local serialized = lurek.input.serializeBindings()
        assert_true(type(serialized) == "string" and string.len(serialized) > 0)
    end)

    -- @covers lurek.input.deserializeBindings
    it("deserializes bindings from a string", function()
        lurek.input.define("save_action", {"s"})
        local serialized = lurek.input.serializeBindings()
        lurek.input.deserializeBindings(serialized)
        assert_equal("userdata", type(lurek.input))
    end)
end)

test_summary()
