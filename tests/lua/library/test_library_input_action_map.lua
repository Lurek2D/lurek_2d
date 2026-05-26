-- Lurek2D Library Input Action Map Tests
-- @testCategory library

local InputActionMap = require("library.input_action_map")

-- @describe input_action_map library     new
describe("input_action_map library     new", function()
    -- @library lurek.library_input_action_map
    it("returns non-nil object", function()
        local m = InputActionMap.new()
        expect_not_nil(m, "new() must return non-nil")
    end)
end)

-- @describe input_action_map library     bind
describe("input_action_map library     bind", function()
    -- @library lurek.library_input_action_map
    it("adds a binding to the action", function()
        local m = InputActionMap.new()
        m:bind("jump", "space")
        local bindings = m:getBindings("jump")
        expect_equal(#bindings, 1, "must have exactly one binding")
        expect_equal(bindings[1], "space", "binding must be 'space'")
    end)

    -- @library lurek.library_input_action_map
    it("prevents duplicate bindings for the same action and key", function()
        local m = InputActionMap.new()
        m:bind("jump", "space")
        m:bind("jump", "space")
        local bindings = m:getBindings("jump")
        expect_equal(#bindings, 1, "duplicate bind must not create second entry")
    end)
end)

-- @describe input_action_map library     getBindings
describe("input_action_map library     getBindings", function()
    -- @library lurek.library_input_action_map
    it("returns correct keys for an action with multiple bindings", function()
        local m = InputActionMap.new()
        m:bind("move_left", "a")
        m:bind("move_left", "left")
        local bindings = m:getBindings("move_left")
        expect_equal(#bindings, 2, "must have two bindings")
        expect_equal(bindings[1], "a", "first binding must be 'a'")
        expect_equal(bindings[2], "left", "second binding must be 'left'")
    end)

    -- @library lurek.library_input_action_map
    it("returns empty table for unbound action", function()
        local m = InputActionMap.new()
        local bindings = m:getBindings("nonexistent")
        expect_equal(#bindings, 0, "unbound action must return empty table")
    end)
end)

-- @describe input_action_map library     unbind
describe("input_action_map library     unbind", function()
    -- @library lurek.library_input_action_map
    it("removes specific binding from action", function()
        local m = InputActionMap.new()
        m:bind("shoot", "mouse_left")
        m:bind("shoot", "space")
        m:unbind("shoot", "mouse_left")
        local bindings = m:getBindings("shoot")
        expect_equal(#bindings, 1, "must have one binding remaining")
        expect_equal(bindings[1], "space", "remaining binding must be 'space'")
    end)
end)

-- @describe input_action_map library     unbindAll
describe("input_action_map library     unbindAll", function()
    -- @library lurek.library_input_action_map
    it("removes all bindings for action", function()
        local m = InputActionMap.new()
        m:bind("attack", "x")
        m:bind("attack", "gamepad_a")
        m:unbindAll("attack")
        local bindings = m:getBindings("attack")
        expect_equal(#bindings, 0, "unbindAll must remove all bindings")
    end)
end)

-- @describe input_action_map library     axis
describe("input_action_map library     axis", function()
    -- @library lurek.library_input_action_map
    it("returns 0 when nothing is held", function()
        local m = InputActionMap.new()
        m:bind("left", "a")
        m:bind("right", "d")
        local val = m:axis("left", "right")
        expect_equal(val, 0, "axis must return 0 when no input")
    end)
end)

-- @describe input_action_map library     clear
describe("input_action_map library     clear", function()
    -- @library lurek.library_input_action_map
    it("removes everything", function()
        local m = InputActionMap.new()
        m:bind("jump", "space")
        m:bind("shoot", "mouse_left")
        m:clear()
        local b1 = m:getBindings("jump")
        local b2 = m:getBindings("shoot")
        expect_equal(#b1, 0, "clear must remove jump bindings")
        expect_equal(#b2, 0, "clear must remove shoot bindings")
    end)
end)

-- @describe input_action_map library     pressed held released
describe("input_action_map library     pressed held released", function()
    -- @library lurek.library_input_action_map
    it("pressed returns false when no input backend", function()
        local m = InputActionMap.new()
        m:bind("jump", "space")
        expect_true(m:pressed("jump") == false, "pressed must return false without engine input")
    end)

    -- @library lurek.library_input_action_map
    it("held returns false when no input backend", function()
        local m = InputActionMap.new()
        m:bind("jump", "space")
        expect_true(m:held("jump") == false, "held must return false without engine input")
    end)

    -- @library lurek.library_input_action_map
    it("released returns false when no input backend", function()
        local m = InputActionMap.new()
        m:bind("jump", "space")
        expect_true(m:released("jump") == false, "released must return false without engine input")
    end)
end)

test_summary()
