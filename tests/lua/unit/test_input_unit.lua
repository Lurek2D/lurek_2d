-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_input_core_unit.lua
do
-- Lurek2D Input API Tests

-- @describe lurek.input.keyboard functions
describe("lurek.input.keyboard functions", function()
    -- @covers lurek.input.keyboard.isDown
    it("isDown returns false for unpressed keys and accepts variadic input", function()
        local val = lurek.input.keyboard.isDown("space")
        expect_type("boolean", val)
        expect_false(lurek.input.keyboard.isDown("space"))
        expect_false(lurek.input.keyboard.isDown("a"))
        expect_false(lurek.input.keyboard.isDown("escape"))
        expect_false(lurek.input.keyboard.isDown("space", "a", "escape"))
    end)

    -- @covers lurek.input.keyboard.isScancodeDown
    it("isScancodeDown returns false for an unpressed scancode", function()
        expect_false(lurek.input.keyboard.isScancodeDown("space"))
    end)

    -- @covers lurek.input.keyboard.setKeyRepeat
    it("setKeyRepeat toggles repeat tracking", function()
        expect_type("function", lurek.input.keyboard.setKeyRepeat)
        lurek.input.keyboard.setKeyRepeat(true)
        expect_true(lurek.input.keyboard.hasKeyRepeat())
        lurek.input.keyboard.setKeyRepeat(false)
        expect_false(lurek.input.keyboard.hasKeyRepeat())
    end)

    -- @covers lurek.input.keyboard.hasKeyRepeat
    it("hasKeyRepeat reports the default disabled state", function()
        expect_type("function", lurek.input.keyboard.hasKeyRepeat)
        lurek.input.keyboard.setKeyRepeat(false)
        expect_false(lurek.input.keyboard.hasKeyRepeat())
    end)

    -- @covers lurek.input.keyboard.setTextInput
    it("setTextInput toggles text input tracking", function()
        expect_type("function", lurek.input.keyboard.setTextInput)
        lurek.input.keyboard.setTextInput(true)
        expect_true(lurek.input.keyboard.hasTextInput())
        lurek.input.keyboard.setTextInput(false)
        expect_false(lurek.input.keyboard.hasTextInput())
    end)

    -- @covers lurek.input.keyboard.hasTextInput
    it("hasTextInput reports the default disabled state", function()
        expect_type("function", lurek.input.keyboard.hasTextInput)
        lurek.input.keyboard.setTextInput(false)
        expect_false(lurek.input.keyboard.hasTextInput())
    end)

    -- @covers lurek.input.keyboard.getKeyFromScancode
    it("phase 03 scancode lookup helpers exist", function()
        expect_type("function", lurek.input.keyboard.getScancodeFromKey)
        expect_type("function", lurek.input.keyboard.getKeyFromScancode)
    end)

    -- @covers lurek.input.keyboard.getScancodeFromKey
    it("getScancodeFromKey returns a known scancode name for common keys", function()
        local scancode = lurek.input.keyboard.getScancodeFromKey("space")
        expect_type("string", scancode)
    end)
end)

-- @describe lurek.input.mouse functions
describe("lurek.input.mouse functions", function()
    -- @covers lurek.input.mouse.getPosition
    it("getPosition returns two numbers", function()
        local x, y = lurek.input.mouse.getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers lurek.input.mouse.getX
    it("getX returns a number", function()
        expect_type("number", lurek.input.mouse.getX())
    end)

    -- @covers lurek.input.mouse.getY
    it("getY returns a number", function()
        expect_type("number", lurek.input.mouse.getY())
    end)

    -- @covers lurek.input.mouse.isDown
    it("isDown returns false booleans for unpressed buttons", function()
        local val = lurek.input.mouse.isDown(1)
        expect_type("boolean", val)
        expect_false(lurek.input.mouse.isDown(1))
        expect_false(lurek.input.mouse.isDown(2))
        expect_false(lurek.input.mouse.isDown(3))
    end)
end)

-- @describe lurek.input.gamepad functions
describe("lurek.input.gamepad functions", function()
    -- @covers lurek.input.gamepad.getButtonCount
    it("core query functions exist", function()
        expect_type("function", lurek.input.gamepad.getCount)
        expect_type("function", lurek.input.gamepad.getJoystickCount)
        expect_type("function", lurek.input.gamepad.getJoysticks)
        expect_type("function", lurek.input.gamepad.isConnected)
        expect_type("function", lurek.input.gamepad.getName)
        expect_type("function", lurek.input.gamepad.isGamepad)
        expect_type("function", lurek.input.gamepad.getButtonCount)
        expect_type("function", lurek.input.gamepad.getAxisCount)
        expect_type("function", lurek.input.gamepad.isDown)
        expect_type("function", lurek.input.gamepad.getAxis)
        expect_type("function", lurek.input.gamepad.isVibrationSupported)
    end)

    -- @covers lurek.input.gamepad.getJoysticks
    it("empty inventory returns stable defaults", function()
        expect_equal(0, lurek.input.gamepad.getCount())
        expect_equal(0, lurek.input.gamepad.getJoystickCount())
        local ids = lurek.input.gamepad.getJoysticks()
        expect_type("table", ids)
        expect_equal(0, #ids)
        expect_false(lurek.input.gamepad.isConnected(0))
        expect_false(lurek.input.gamepad.isGamepad(0))
    end)

    -- @covers lurek.input.gamepad.getCount
    it("getCount returns the tracked gamepad slot count", function()
        expect_equal(0, lurek.input.gamepad.getCount())
    end)

    -- @covers lurek.input.gamepad.getJoystickCount
    it("getJoystickCount matches the tracked joystick slot count", function()
        expect_equal(0, lurek.input.gamepad.getJoystickCount())
    end)

    -- @covers lurek.input.gamepad.isConnected
    it("isConnected reports false for a missing gamepad id", function()
        expect_false(lurek.input.gamepad.isConnected(0))
    end)

    -- @covers lurek.input.gamepad.getName
    it("getName returns Unknown for a missing gamepad id", function()
        expect_equal("Unknown", lurek.input.gamepad.getName(0))
    end)

    -- @covers lurek.input.gamepad.isGamepad
    it("isGamepad reports false for a missing gamepad id", function()
        expect_false(lurek.input.gamepad.isGamepad(0))
    end)

    -- @covers lurek.input.gamepad.getAxisCount
    it("getAxisCount returns zero for a missing gamepad id", function()
        expect_equal(0, lurek.input.gamepad.getAxisCount(0))
    end)

    -- @covers lurek.input.gamepad.isDown
    it("gamepad isDown reports false for an unpressed button", function()
        expect_false(lurek.input.gamepad.isDown(0, 0))
    end)

    -- @covers lurek.input.gamepad.getAxis
    it("getAxis returns zero for a missing gamepad axis", function()
        expect_near(0.0, lurek.input.gamepad.getAxis(0, 0), 0.0001)
    end)

    -- @covers lurek.input.gamepad.getGUID
    it("phase 03 advanced gamepad hooks exist", function()
        expect_type("function", lurek.input.gamepad.getGUID)
        expect_type("function", lurek.input.gamepad.getHat)
        expect_type("function", lurek.input.gamepad.setVibration)
        expect_type("function", lurek.input.gamepad.wasPressed)
        expect_type("function", lurek.input.gamepad.wasReleased)
        expect_type("function", lurek.input.gamepad.wasConnected)
        expect_type("function", lurek.input.gamepad.wasDisconnected)
        expect_type("function", lurek.input.gamepad.virtualDpad)
    end)

    -- @covers lurek.input.gamepad.getHat
    it("getHat returns centered for a missing gamepad hat", function()
        expect_equal("c", lurek.input.gamepad.getHat(0, 0))
    end)

    -- @covers lurek.input.gamepad.wasPressed
    it("wasPressed reports false for a missing gamepad button", function()
        expect_false(lurek.input.gamepad.wasPressed(0, 0))
    end)

    -- @covers lurek.input.gamepad.wasReleased
    it("wasReleased reports false for a missing gamepad button", function()
        expect_false(lurek.input.gamepad.wasReleased(0, 0))
    end)

    -- @covers lurek.input.gamepad.wasConnected
    it("wasConnected reports false for a missing gamepad id", function()
        expect_false(lurek.input.gamepad.wasConnected(0))
    end)

    -- @covers lurek.input.gamepad.wasDisconnected
    it("wasDisconnected reports false for a missing gamepad id", function()
        expect_false(lurek.input.gamepad.wasDisconnected(0))
    end)

    -- @covers lurek.input.gamepad.virtualDpad
    it("virtualDpad returns stable digital direction table", function()
        local center = lurek.input.gamepad.virtualDpad(0.0, 0.0)
        expect_type("table", center)
        expect_equal("c", center.direction)
        expect_false(center.up)
        expect_false(center.down)
        expect_false(center.left)
        expect_false(center.right)

        local diag = lurek.input.gamepad.virtualDpad(0.9, -0.9, 0.2)
        expect_equal("ru", diag.direction)
        expect_true(diag.up)
        expect_false(diag.down)
        expect_false(diag.left)
        expect_true(diag.right)
    end)
end)

-- @describe lurek.input.touch functions
describe("lurek.input.touch functions", function()
    -- @covers lurek.input.touch.getTouches
    it("touch query helpers exist and getTouches defaults to an empty table", function()
        expect_type("function", lurek.input.touch.getTouches)
        expect_type("function", lurek.input.touch.getPosition)
        expect_type("function", lurek.input.touch.getPressure)
        expect_type("function", lurek.input.touch.getTouchCount)
        expect_type("function", lurek.input.touch.wasPressed)
        expect_type("function", lurek.input.touch.wasReleased)
        local touches = lurek.input.touch.getTouches()
        expect_type("table", touches)
        expect_equal(0, #touches)
    end)

    -- @covers lurek.input.touch.getTouchCount
    it("getTouchCount returns 0 by default", function()
        expect_equal(0, lurek.input.touch.getTouchCount())
    end)

    -- @covers lurek.input.touch.getPosition
    it("getPosition returns zero coordinates for a missing touch id", function()
        local x, y = lurek.input.touch.getPosition(999)
        expect_equal(0, x)
        expect_equal(0, y)
    end)

    -- @covers lurek.input.touch.getPressure
    it("getPressure returns zero for a missing touch id", function()
        expect_equal(0, lurek.input.touch.getPressure(999))
    end)

    -- @covers lurek.input.touch.wasPressed
    it("wasPressed reports false for a touch id with no events", function()
        expect_false(lurek.input.touch.wasPressed(999))
    end)

    -- @covers lurek.input.touch.wasReleased
    it("wasReleased reports false for a touch id with no events", function()
        expect_false(lurek.input.touch.wasReleased(999))
    end)
end)

-- @describe keyboard.isModifierActive
describe("keyboard.isModifierActive", function()
    -- @covers lurek.input.keyboard.isModifierActive
    it("reports booleans for known modifiers and false for unknown ones", function()
        expect_type("boolean", lurek.input.keyboard.isModifierActive("shift"))
        expect_type("boolean", lurek.input.keyboard.isModifierActive("ctrl"))
        expect_type("boolean", lurek.input.keyboard.isModifierActive("alt"))
        expect_type("boolean", lurek.input.keyboard.isModifierActive("altgr"))
        expect_type("boolean", lurek.input.keyboard.isModifierActive("meta"))
        expect_type("boolean", lurek.input.keyboard.isModifierActive("super"))
        expect_equal(false, lurek.input.keyboard.isModifierActive("capslock"))
        expect_equal(false, lurek.input.keyboard.isModifierActive("shift"))
        expect_equal(false, lurek.input.keyboard.isModifierActive("ctrl"))
    end)
end)

-- @describe mouse cursor userdata
describe("mouse cursor userdata", function()
    -- @covers lurek.input.mouse.getSystemCursor
    it("getSystemCursor returns usable cursor userdata for common system cursors", function()
        expect_type("userdata", lurek.input.mouse.getSystemCursor("arrow"))
        expect_type("userdata", lurek.input.mouse.getSystemCursor("hand"))
        expect_type("userdata", lurek.input.mouse.getSystemCursor("crosshair"))
    end)

    -- @covers lurek.input.mouse.isCursorSupported
    it("isCursorSupported returns a bool", function()
        expect_type("boolean", lurek.input.mouse.isCursorSupported())
        expect_equal(true, lurek.input.mouse.isCursorSupported())
    end)

    -- @covers lurek.input.mouse.setCursor
    it("setCursor accepts userdata and legacy string names", function()
        local c = lurek.input.mouse.getSystemCursor("hand")
        lurek.input.mouse.setCursor(c)
        expect_equal("hand", lurek.input.mouse.getCursor())
        lurek.input.mouse.setCursor("crosshair")
        expect_equal("crosshair", lurek.input.mouse.getCursor())
        lurek.input.mouse.setCursor("arrow")
    end)
end)

-- Phase 10: Gamepad Mapping Persistence
-- @describe lurek.input.gamepad mapping persistence
describe("lurek.input.gamepad mapping persistence", function()
    -- @covers lurek.input.gamepad.saveGamepadMappings
    it("mapping API functions exist", function()
        expect_type("function", lurek.input.gamepad.setGamepadMapping)
        expect_type("function", lurek.input.gamepad.getGamepadMappingString)
        expect_type("function", lurek.input.gamepad.loadGamepadMappings)
        expect_type("function", lurek.input.gamepad.saveGamepadMappings)
    end)

    -- @covers lurek.input.gamepad.setGamepadMapping
    it("setGamepadMapping does not error for valid guid", function()
        local guid = "030000005e0400008e02000014010000"
        lurek.input.gamepad.setGamepadMapping(
            guid,
            guid .. ",TestPad,a:b0"
        )
    end)

    -- @covers lurek.input.gamepad.getGamepadMappingString
    it("getGamepadMappingString returns nil for unknown guid and a string after set", function()
        expect_equal(nil, lurek.input.gamepad.getGamepadMappingString("unknown_guid_xyz"))
        local guid = "030000005e0400008e02000014010000"
        lurek.input.gamepad.setGamepadMapping(guid, guid .. ",XInput,a:b0")
        local s = lurek.input.gamepad.getGamepadMappingString(guid)
        expect_type("string", s)
    end)

    -- @covers lurek.input.gamepad.loadGamepadMappings
    it("loadGamepadMappings errors on missing or invalid paths", function()
        expect_error(function()
            lurek.input.gamepad.loadGamepadMappings("__nonexistent_mappings_file_.txt")
        end)
        expect_error(function()
            lurek.input.gamepad.loadGamepadMappings("../outside.txt")
        end)
    end)
end)

-- mouse visibility / grab / relative

-- @describe mouse.setVisible / isVisible
describe("mouse.setVisible / isVisible", function()
    -- @covers lurek.input.mouse.setVisible
    it("setVisible round-trips both true and false states", function()
        lurek.input.mouse.setVisible(true)
        expect_true(lurek.input.mouse.isVisible())
        lurek.input.mouse.setVisible(false)
        expect_false(lurek.input.mouse.isVisible())
        lurek.input.mouse.setVisible(true) -- restore
    end)

    -- @covers lurek.input.mouse.isVisible
    it("isVisible reports the current cursor visibility state", function()
        lurek.input.mouse.setVisible(false)
        expect_false(lurek.input.mouse.isVisible())
        lurek.input.mouse.setVisible(true)
        expect_true(lurek.input.mouse.isVisible())
    end)
end)

-- @describe mouse.setGrabbed / isGrabbed
describe("mouse.setGrabbed / isGrabbed", function()
    -- @covers lurek.input.mouse.setGrabbed
    it("setGrabbed / isGrabbed round-trip false", function()
        lurek.input.mouse.setGrabbed(false)
        expect_false(lurek.input.mouse.isGrabbed())
    end)

    -- @covers lurek.input.mouse.isGrabbed
    it("isGrabbed returns a boolean", function()
        expect_type("boolean", lurek.input.mouse.isGrabbed())
    end)
end)

-- @describe mouse.setRelativeMode / getRelativeMode
describe("mouse.setRelativeMode / getRelativeMode", function()
    -- @covers lurek.input.mouse.setRelativeMode
    it("setRelativeMode false / getRelativeMode round-trip", function()
        lurek.input.mouse.setRelativeMode(false)
        expect_false(lurek.input.mouse.getRelativeMode())
    end)

    -- @covers lurek.input.mouse.getRelativeMode
    it("getRelativeMode returns a boolean", function()
        expect_type("boolean", lurek.input.mouse.getRelativeMode())
    end)
end)

-- @describe mouse.getWheelDelta
describe("mouse.getWheelDelta", function()
    -- @covers lurek.input.mouse.getWheelDelta
    it("getWheelDelta returns two numbers and defaults to 0,0", function()
        local dx, dy = lurek.input.mouse.getWheelDelta()
        expect_type("number", dx)
        expect_type("number", dy)
        expect_equal(0, dx)
        expect_equal(0, dy)
    end)
end)

-- @describe mouse.setPosition
describe("mouse.setPosition", function()
    -- @covers lurek.input.mouse.setPosition
    it("setPosition does not error in headless mode", function()
        expect_no_error(function()
            lurek.input.mouse.setPosition(0, 0)
        end)
    end)
end)

-- Cursor extended methods

-- @describe Cursor.getType / Cursor.release
describe("Cursor.getType / Cursor.release", function()
    -- @covers LCursor:getType
    it("Cursor:getType returns a string", function()
        local cursor = lurek.input.mouse.getSystemCursor("default")
        expect_type("string", cursor:getType())
    end)

    -- @covers LCursor:release
    it("Cursor:release does not error", function()
        local cursor = lurek.input.mouse.getSystemCursor("arrow")
        expect_no_error(function() cursor:release() end)
    end)
end)

-- @describe lurek.input action mapping
describe("lurek.input action mapping", function()
  -- @covers lurek.input.bind
  it("bind registers an action", function()
    lurek.input.bind("jump", {"space", "up"})
    local bindings = lurek.input.getBindings()
    expect_equal(type(bindings), "table")
    expect_equal(type(bindings["jump"]), "table")
    expect_equal(#bindings["jump"], 2)
  end)

  -- @covers lurek.input.getBindings
  it("getBindings returns the registered action mapping table", function()
    lurek.input.clearBindings()
    lurek.input.bind("dash", {"shift", "gamepad:0:0"})
    local bindings = lurek.input.getBindings()
    expect_type("table", bindings)
    expect_equal(2, #bindings["dash"])
    lurek.input.clearBindings()
  end)

  -- @covers lurek.input.unbind
  it("unbind removes an action", function()
    lurek.input.bind("fire", "ctrl")
    local removed = lurek.input.unbind("fire")
    expect_equal(removed, true)
    local b = lurek.input.getBindings()
    expect_equal(b["fire"], nil)
  end)

  -- @covers lurek.input.clearBindings
  it("clearBindings empties all mappings", function()
    lurek.input.bind("run", "shift")
    lurek.input.clearBindings()
    local b = lurek.input.getBindings()
    local count = 0
    for _ in pairs(b) do count = count + 1 end
    expect_equal(count, 0)
  end)

  -- @covers lurek.input.isActionDown
  it("isActionDown is false for an unmapped action", function()
    lurek.input.clearBindings()
    expect_equal(lurek.input.isActionDown("nosuchaction"), false)
  end)

  -- @covers lurek.input.wasActionPressed
  it("wasActionPressed is false for an unmapped action", function()
    expect_equal(lurek.input.wasActionPressed("nosuchaction"), false)
  end)

  -- @covers lurek.input.wasActionReleased
  it("wasActionReleased is false for an unmapped action", function()
    expect_equal(lurek.input.wasActionReleased("nosuchaction"), false)
  end)

  -- @covers lurek.input.wasActionPressedWithin
  it("wasActionPressedWithin is false for an action never pressed", function()
    expect_equal(lurek.input.wasActionPressedWithin("nosuchaction", 10), false)
  end)

    -- @covers lurek.input.newMapping
    it("newMapping returns helper table", function()
        local mapping = lurek.input.newMapping("dash", {"shift", "gamepad:0:0"})
        expect_type("table", mapping)
        expect_type("function", mapping.isDown)
        expect_type("function", mapping.wasPressed)
        expect_type("function", mapping.wasReleased)
    end)

    -- @covers lurek.input.isDown
    it("mapping isDown returns a boolean for an action helper table", function()
        local mapping = lurek.input.newMapping("dash_state", {"shift"})
        expect_type("boolean", mapping.isDown())
        lurek.input.reset("dash_state")
    end)

    -- @covers lurek.input.wasPressed
    it("mapping wasPressed returns a boolean for an action helper table", function()
        local mapping = lurek.input.newMapping("dash_press", {"shift"})
        expect_type("boolean", mapping.wasPressed())
        lurek.input.reset("dash_press")
    end)

    -- @covers lurek.input.wasReleased
    it("mapping wasReleased returns a boolean for an action helper table", function()
        local mapping = lurek.input.newMapping("dash_release", {"shift"})
        expect_type("boolean", mapping.wasReleased())
        lurek.input.reset("dash_release")
    end)
end)

-- Input Combo (merged from test_input_combo.lua)

-- @describe lurek.input.newCombo  - basic construction
describe("lurek.input.newCombo  - basic construction", function()

    -- @covers LCombo:totalSteps
    it("totalSteps counts string and table-defined combos", function()
        local combo = lurek.input.newCombo({"a", "b", "c"})
        expect_equal(combo:totalSteps(), 3)
        local combo = lurek.input.newCombo(
            {{key="down", gap=300}, {key="right", gap=300}, {key="a", gap=300}}
        )
        expect_equal(combo:totalSteps(), 3)
    end)

    -- @covers LCombo:isInProgress
    it("starts with progress 0 and not in progress", function()
        local combo = lurek.input.newCombo({"x", "y"})
        expect_equal(combo:progress(), 0)
        expect_equal(combo:isInProgress(), false)
    end)

    -- @covers LCombo:getStep
    it("getStep returns indexed steps, default gap, custom gap, and nil out of range", function()
        local combo = lurek.input.newCombo({"down", "right", "a"})
        local s1 = combo:getStep(1)
        local s2 = combo:getStep(2)
        expect_equal(s1.key, "down")
        expect_equal(s2.key, "right")
        local combo = lurek.input.newCombo({{key="space", gap=750}})
        expect_equal(combo:getStep(1).gap_ms, 750)
        expect_equal(combo:getStep(0), nil)
        expect_equal(combo:getStep(2), nil)
        local default_combo = lurek.input.newCombo({"space"})
        expect_equal(default_combo:getStep(1).gap_ms, 500)
    end)

end)

-- @describe lurek.input.newCombo  - feed() advancement
describe("lurek.input.newCombo  - feed() advancement", function()

    -- @covers LCombo:feed
    it("advances, completes, breaks, and restarts combo sequences", function()
        local combo = lurek.input.newCombo({"a", "b", "c"})
        local result = combo:feed("x")
        expect_equal(result, "idle")
        expect_equal(combo:progress(), 0)
        result = combo:feed("a")
        expect_equal(result, "advanced")
        expect_equal(combo:progress(), 1)
        expect_equal(combo:isInProgress(), true)

        local r2 = combo:feed("b")
        expect_equal(r2, "advanced")
        expect_equal(combo:progress(), 2)
        local r = combo:feed("c")
        expect_equal(r, "completed")
        expect_equal(combo:progress(), 0)
        expect_equal(combo:isInProgress(), false)

        combo = lurek.input.newCombo({"a", "b", "c"})
        combo:feed("a")
        r = combo:feed("x")
        expect_equal(r, "broken")
        expect_equal(combo:progress(), 0)
        expect_equal(combo:isInProgress(), false)

        combo = lurek.input.newCombo({"a", "b"})
        combo:feed("a")
        combo:feed("x")  -- break
        r = combo:feed("a")  -- restart
        expect_equal(r, "advanced")

        combo = lurek.input.newCombo({"space"})
        r = combo:feed("space")
        expect_equal(r, "completed")
    end)

end)

-- @describe lurek.input.newCombo  - tick() timeout
describe("lurek.input.newCombo  - tick() timeout", function()

    -- @covers LCombo:tick
    it("tick reports idle, in-progress, and expiration states", function()
        local combo = lurek.input.newCombo({"a", "b"}, {total_gap=2000})
        local r = combo:tick(0.1)
        expect_equal(r, "idle")

        combo = lurek.input.newCombo({{key="a", gap=1000}, {key="b", gap=1000}}, {total_gap=2000})
        combo:feed("a")
        r = combo:tick(0.3)
        expect_equal(r, "in_progress")

        combo = lurek.input.newCombo({{key="a", gap=200}, {key="b", gap=200}}, {total_gap=2000})
        combo:feed("a")
        r = combo:tick(0.3)
        expect_equal(r, "expired")

        combo = lurek.input.newCombo({{key="a", gap=100}, {key="b", gap=100}}, {total_gap=2000})
        combo:feed("a")
        combo:tick(0.2)  -- expire
        expect_equal(combo:isInProgress(), false)
        expect_equal(combo:progress(), 0)

        combo = lurek.input.newCombo(
            {{key="a", gap=5000}, {key="b", gap=5000}},
            {total_gap=100}
        )
        combo:feed("a")
        r = combo:tick(0.2)
        expect_equal(r, "expired")
    end)

end)

-- @describe lurek.input.newCombo  - reset()
describe("lurek.input.newCombo  - reset()", function()

    -- @covers LCombo:reset
    it("reset clears progress and allows restarting the combo", function()
        local combo = lurek.input.newCombo({"a", "b", "c"})
        combo:feed("a")
        combo:feed("b")
        combo:reset()
        expect_equal(combo:progress(), 0)
        expect_equal(combo:isInProgress(), false)

        combo = lurek.input.newCombo({"a", "b"})
        combo:feed("a")
        combo:reset()
        combo:feed("a")
        local r = combo:feed("b")
        expect_equal(r, "completed")
    end)

end)

-- @describe lurek.input.newCombo  - error cases
describe("lurek.input.newCombo  - error cases", function()

    -- @covers lurek.input.newCombo
    it("validates combo step definitions", function()
        expect_error(function()
            lurek.input.newCombo({})
        end)
        expect_error(function()
            lurek.input.newCombo({{gap=300}})
        end)
    end)

end)

-- Input Recording (merged from test_input_recording.lua)

-- @describe input.recording
describe("input.recording", function()

    -- @covers lurek.input.startRecording
    it("startRecording/stopRecording returns an InputRecording userdata", function()
        lurek.input.startRecording()
        expect_equal(lurek.input.isRecording(), true)
        local rec = lurek.input.stopRecording()
        expect_equal(lurek.input.isRecording(), false)
        expect_equal(rec ~= nil, true)
    end)

    -- @covers lurek.input.stopRecording
    it("stopRecording returns nil when not recording", function()
        -- Ensure we are not recording
        lurek.input.stopRecording()  -- safe no-op
        local rec = lurek.input.stopRecording()
        expect_equal(rec, nil)
    end)

    -- @covers LInputRecording:totalFrames
    it("InputRecording:totalFrames is zero for empty recording", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        expect_equal(type(rec:totalFrames()), "number")
        expect_equal(rec:totalFrames() >= 0, true)
    end)

    -- @covers LInputRecording:frameCount
    it("InputRecording:frameCount returns 0 for recording with no events", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        expect_equal(rec:frameCount(), 0)
    end)

    -- @covers LInputRecording:toJson
    it("InputRecording:toJson returns a non-empty string", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        local json = rec:toJson()
        expect_equal(type(json), "string")
        expect_equal(#json > 0, true)
    end)

    -- @covers lurek.input.loadRecording
    it("loadRecording accepts valid JSON and rejects invalid payloads", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        local json = rec:toJson()
        lurek.input.loadRecording(json)
        expect_error(function()
            lurek.input.loadRecording("not valid json {{{{")
        end)
    end)

    -- @covers lurek.input.startPlayback
    it("startPlayback/stopPlayback / isPlayingBack work after load", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        expect_equal(lurek.input.isPlayingBack(), true)
        lurek.input.stopPlayback()
        expect_equal(lurek.input.isPlayingBack(), false)
    end)

    -- @covers lurek.input.stopPlayback
    it("stopPlayback ends playback after it has started", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        lurek.input.stopPlayback()
        expect_false(lurek.input.isPlayingBack())
    end)

    -- @covers lurek.input.getPlaybackFrame
    it("getPlaybackFrame returns 0 at start of playback", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        expect_equal(lurek.input.getPlaybackFrame(), 0)
        lurek.input.stopPlayback()
    end)

    -- @covers lurek.input.advancePlayback
    it("advancePlayback handles empty and populated recordings", function()
        lurek.input.startRecording()
        local rec = lurek.input.stopRecording()
        lurek.input.loadRecording(rec:toJson())
        lurek.input.startPlayback()
        local events = lurek.input.advancePlayback()
        expect_equal(type(events), "table")
        lurek.input.stopPlayback()

        local json = [[{"frames":[{"frame":0,"key_events":[{"kind":"down","name":"a"}],"mouse_x":null,"mouse_y":null},{"frame":1,"key_events":[],"mouse_x":null,"mouse_y":42},{"frame":2,"key_events":[{"kind":"up","name":"a"}],"mouse_x":null,"mouse_y":null}],"total_frames":3}]]
        lurek.input.loadRecording(json)
        lurek.input.startPlayback()

        local events0 = lurek.input.advancePlayback()
        expect_equal(#events0, 1)
        expect_equal(events0[1].kind, "down")
        expect_equal(events0[1].name, "a")
        expect_equal(lurek.input.getPlaybackFrame(), 1)
        expect_equal(lurek.input.isPlayingBack(), true)

        local events1 = lurek.input.advancePlayback()
        expect_equal(#events1, 0)
        expect_equal(events1.mouse_x, nil)
        expect_equal(events1.mouse_y, 42)
        expect_equal(lurek.input.getPlaybackFrame(), 2)
        expect_equal(lurek.input.isPlayingBack(), true)

        local events2 = lurek.input.advancePlayback()
        expect_equal(#events2, 1)
        expect_equal(events2[1].kind, "up")
        expect_equal(events2[1].name, "a")
        expect_equal(lurek.input.isPlayingBack(), false)
    end)

    -- @covers lurek.input.isRecording
    it("isRecording is false while not recording", function()
        expect_equal(lurek.input.isRecording(), false)
    end)

    -- @covers lurek.input.isPlayingBack
    it("isPlayingBack is false when not playing", function()
        expect_equal(lurek.input.isPlayingBack(), false)
    end)

end)

-- Input Vibrate (merged from test_input_vibrate.lua)


-- @describe lurek.input.gamepad vibration API types
describe("lurek.input.gamepad vibration API types", function()
  -- @covers lurek.input.gamepad.setVibration
  it("legacy vibration helpers are exposed", function()
    expect_type("function", lurek.input.gamepad.vibrate)
    expect_type("function", lurek.input.gamepad.isVibrationSupported)
    expect_type("function", lurek.input.gamepad.setVibration)
  end)
end)

-- @describe lurek.input.gamepad.isVibrationSupported
describe("lurek.input.gamepad.isVibrationSupported", function()
  -- @covers lurek.input.gamepad.isVibrationSupported
  it("returns booleans and rejects unknown ids", function()
    local result = lurek.input.gamepad.isVibrationSupported(0)
    expect_type("boolean", result)
    local missing = lurek.input.gamepad.isVibrationSupported(99)
    expect_equal(false, missing)
  end)
end)

-- @describe lurek.input.gamepad.vibrate
describe("lurek.input.gamepad.vibrate", function()
  -- @covers lurek.input.gamepad.vibrate
  it("returns booleans across supported edge-case inputs", function()
    local result = lurek.input.gamepad.vibrate(0, 0.5, 0.5, 200)
    expect_type("boolean", result)
    expect_equal(false, lurek.input.gamepad.vibrate(0, 1.0, 1.0, 500))
    expect_type("boolean", lurek.input.gamepad.vibrate(0, 0.0, 0.0, 0.0))
    expect_type("boolean", lurek.input.gamepad.vibrate(0, 5.0, 5.0, 100))
    expect_type("boolean", lurek.input.gamepad.vibrate(0, 0.5, 0.5, -100))
  end)
end)

-- Joystick Background Events (merged from test_joystick_ext.lua)

-- @describe lurek.input.gamepad.getBackgroundEvents
describe("lurek.input.gamepad.getBackgroundEvents", function()
    -- @covers lurek.input.gamepad.getBackgroundEvents
    it("defaults to false", function()
        expect_equal(false, lurek.input.gamepad.getBackgroundEvents())
    end)
end)

-- @describe lurek.input.gamepad.setBackgroundEvents
describe("lurek.input.gamepad.setBackgroundEvents", function()
    -- @covers lurek.input.gamepad.setBackgroundEvents
    it("can enable and disable background events", function()
        lurek.input.gamepad.setBackgroundEvents(true)
        expect_equal(true, lurek.input.gamepad.getBackgroundEvents())
        lurek.input.gamepad.setBackgroundEvents(false)
        expect_equal(false, lurek.input.gamepad.getBackgroundEvents())
    end)
end)

-- @describe lurek.input.mouse.newCursor
describe("lurek.input.mouse.newCursor", function()
    -- @covers lurek.input.mouse.newCursor
    it("newCursor validates raw pixel data", function()
        -- 1x1 RGBA pixel
        local pixels = { 255, 0, 0, 255 }
        local cursor = lurek.input.mouse.newCursor(pixels, 1, 1)
        expect_not_nil(cursor)
        expect_error(function()
            lurek.input.mouse.newCursor({ 255, 0, 0 }, 1, 1)
        end)
        expect_error(function()
            lurek.input.mouse.newCursor(pixels, 1, 1, 1, 0)
        end)
    end)
end)
-- @describe unit: migrated from integration/test_input_camera.lua
describe("unit: migrated from integration/test_input_camera.lua", function()
        -- @covers lurek.input.mouse.getCursor
        it("getCursor returns a cursor name without error", function()
            expect_no_error(function()
                local cursor = lurek.input.mouse.getCursor()
                expect_type("string", cursor, "cursor name is string")
            end)
        end)

end)

-- @describe lurek.input extended action binding (NM-04)
describe("lurek.input extended action binding (NM-04)", function()

    -- @covers lurek.input.define
    it("define stores and replaces bindings", function()
        lurek.input.define("nm04_def", {"d", "right"}, "movement")
        local bindings = lurek.input.getBindings()
        expect_not_nil(bindings.nm04_def)
        lurek.input.reset()
        lurek.input.bind("nm04_repl", "a")
        lurek.input.define("nm04_repl", {"b"})
        bindings = lurek.input.getBindings()
        expect_not_nil(bindings.nm04_repl)
        lurek.input.reset()
    end)

    -- @covers lurek.input.getAxis
    it("getAxis returns numbers for unknown and defined actions", function()
        local v = lurek.input.getAxis("nm04_nosuch")
        expect_type("number", v, "getAxis is number")
        lurek.input.define("nm04_axis", {"right", "left"}, "")
        v = lurek.input.getAxis("nm04_axis")
        expect_type("number", v, "getAxis is number")
        lurek.input.reset()
    end)

    -- @covers lurek.input.getVector
    it("getVector returns two numbers", function()
        lurek.input.define("nm04_h", {"d", "a"}, "")
        lurek.input.define("nm04_v", {"s", "w"}, "")
        local h, v = lurek.input.getVector("nm04_h", "nm04_v")
        expect_type("number", h, "getVector h is number")
        expect_type("number", v, "getVector v is number")
        lurek.input.reset()
    end)

    -- @covers lurek.input.reset
    it("reset clears one action or all actions", function()
        lurek.input.bind("nm04_one", "o")
        lurek.input.bind("nm04_two", "p")
        lurek.input.reset("nm04_one")
        local bindings = lurek.input.getBindings()
        expect_nil(bindings.nm04_one)
        expect_not_nil(bindings.nm04_two)
        lurek.input.bind("nm04_all1", "1")
        lurek.input.bind("nm04_all2", "2")
        lurek.input.reset()
        bindings = lurek.input.getBindings()
        expect_nil(bindings.nm04_all1)
        expect_nil(bindings.nm04_all2)
    end)

    -- @covers lurek.input.getConflicts
    it("getConflicts returns the shared binding map", function()
        lurek.input.bind("nm04_ca", "x")
        lurek.input.bind("nm04_cb", "x")
        local c = lurek.input.getConflicts()
        expect_type("table", c, "getConflicts is table")
        lurek.input.bind("nm04_cx", "mouse1")
        lurek.input.bind("nm04_cy", "mouse1")
        c = lurek.input.getConflicts()
        expect_not_nil(c["mouse1"])
        lurek.input.reset()
    end)

    -- @covers lurek.input.serializeBindings
    it("serializeBindings returns JSON string", function()
        lurek.input.bind("nm04_ser", "s")
        local json = lurek.input.serializeBindings()
        expect_type("string", json, "serializeBindings is string")
        expect_true(#json > 0)
        lurek.input.reset()
    end)

    -- @covers lurek.input.deserializeBindings
    it("deserializeBindings round-trips bindings", function()
        lurek.input.define("nm04_rt", {"q", "e"}, "test_cat")
        local json = lurek.input.serializeBindings()
        lurek.input.reset()
        local ok = lurek.input.deserializeBindings(json)
        expect_true(ok)
        local bindings = lurek.input.getBindings()
        expect_not_nil(bindings.nm04_rt)
        lurek.input.reset()
    end)

    -- @covers lurek.input.getByCategory
    it("getByCategory returns matches or an empty list", function()
        lurek.input.define("nm04_run", "lshift", "mv")
        lurek.input.define("nm04_walk", "lctrl", "mv")
        lurek.input.define("nm04_fire", "space", "combat")
        local mv = lurek.input.getByCategory("mv")
        expect_type("table", mv, "getByCategory is table")
        expect_true(#mv == 2)
        local r = lurek.input.getByCategory("no_such_cat")
        expect_type("table", r, "result is table")
        expect_true(#r == 0)
        lurek.input.reset()
    end)

    -- @covers lurek.input.onRebind
    it("onRebind callback receives action names and key tables", function()
        local fired = false
        lurek.input.onRebind(function(action, keys)
            if action == "nm04_rbtest" then fired = true end
        end)
        lurek.input.bind("nm04_rbtest", "z")
        expect_true(fired)
        lurek.input.reset()

        local got_action = nil
        local got_keys = nil
        lurek.input.onRebind(function(action, keys)
            got_action = action
            got_keys = keys
        end)
        lurek.input.bind("nm04_rbdata", "y")
        expect_not_nil(got_action)
        expect_not_nil(got_keys)
        expect_type("table", got_keys, "keys is table")
        lurek.input.reset()
    end)

end)
end
-- END test_input_core_unit.lua

-- BEGIN test_input_unit.lua
do
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
end
-- END test_input_unit.lua

test_summary()
