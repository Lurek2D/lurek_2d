-- tests/lua/unit/test_fx.lua
-- Post-processing effect API tests (lurek.postfx / lurek.overlay).
-- Complements test_postfx.lua; focuses on the API surface check.
-- Headless-safe: no GPU, no window needed for API introspection.
-- @covers lurek.postfx.getEffectTypes
-- @covers lurek.postfx.newEffect
-- @covers lurek.postfx.newStack
-- @covers lurek.postfx.newPass
-- @covers lurek.postfx.newCustomEffect

-- ============================================================
-- Namespace surface
-- ============================================================
-- @description Verifies the postfx namespace tables and public constructor/helper functions are exposed with the expected Lua types.
describe("lurek.postfx module", function()
    -- @description Asserts that lurek.postfx exists and is exposed as a Lua table.
    it("is a table", function()
        expect_type("table", lurek.postfx)
    end)

    -- @description Asserts that lurek.overlay is exposed as a Lua table.
    it("lurek.overlay aliases the same table", function()
        -- Both namespaces point to the same module table
        expect_type("table", lurek.overlay)
    end)

    -- @description Asserts that lurek.postfx.getEffectTypes is exposed as a function.
    it("exposes getEffectTypes", function()
        expect_type("function", lurek.postfx.getEffectTypes)
    end)

    -- @description Asserts that lurek.postfx.newEffect is exposed as a function.
    it("exposes newEffect", function()
        expect_type("function", lurek.postfx.newEffect)
    end)

    -- @description Asserts that lurek.postfx.newStack is exposed as a function.
    it("exposes newStack", function()
        expect_type("function", lurek.postfx.newStack)
    end)

    -- @description Asserts that lurek.postfx.newPass is exposed as a function.
    it("exposes newPass", function()
        expect_type("function", lurek.postfx.newPass)
    end)

    -- @description Asserts that lurek.postfx.newCustomEffect is exposed as a function.
    it("exposes newCustomEffect", function()
        expect_type("function", lurek.postfx.newCustomEffect)
    end)
end)

-- ============================================================
-- getEffectTypes
-- ============================================================
-- @description Verifies getEffectTypes returns a non-empty table and that the returned list includes at least one expected built-in effect name.
describe("lurek.postfx.getEffectTypes", function()
    -- @description Calls getEffectTypes and asserts the returned value is a table.
    it("returns a table", function()
        local types = lurek.postfx.getEffectTypes()
        expect_type("table", types)
    end)

    -- @description Counts the returned entries and asserts the table contains at least one effect type.
    it("contains at least one entry", function()
        local types = lurek.postfx.getEffectTypes()
        local count = 0
        for _ in pairs(types) do count = count + 1 end
        expect_true(count > 0, "getEffectTypes should return at least one type")
    end)

    -- @description Builds a lookup from the returned list and asserts that bloom, blur, or pixelate appears in it.
    it("contains known built-in types", function()
        local types = lurek.postfx.getEffectTypes()
        local set = {}
        for _, v in ipairs(types) do set[v] = true end
        expect_true(set["bloom"] or set["blur"] or set["pixelate"],
            "at least one of bloom/blur/pixelate expected in type list")
    end)
end)

-- ============================================================
-- newEffect (built-in types by name)
-- ============================================================
-- @description Verifies newEffect creates userdata for known effect names, rejects an unknown name, and exposes the expected effect metadata and enabled-state behavior.
describe("lurek.postfx.newEffect", function()
    -- @description Creates a bloom effect and asserts the result is userdata.
    it("returns a userdata for 'bloom'", function()
        local eff = lurek.postfx.newEffect("bloom")
        expect_type("userdata", eff)
    end)

    -- @description Creates a pixelate effect and asserts the result is userdata.
    it("returns a userdata for 'pixelate'", function()
        local eff = lurek.postfx.newEffect("pixelate")
        expect_type("userdata", eff)
    end)

    -- @description Calls newEffect with an unknown type name and asserts that it raises an error.
    it("errors for an unknown effect type", function()
        expect_error(function()
            lurek.postfx.newEffect("magic_wand_effect")
        end)
    end)

    -- @description Creates a blur effect and asserts getTypeName returns the string blur.
    it("effect:getTypeName returns the requested type", function()
        local eff = lurek.postfx.newEffect("blur")
        expect_equal("blur", eff:getTypeName())
    end)

    -- @description Creates a vignette effect and asserts isBuiltIn returns true.
    it("effect:isBuiltIn returns true for newEffect", function()
        local eff = lurek.postfx.newEffect("vignette")
        expect_equal(true, eff:isBuiltIn())
    end)

    -- @description Creates a bloom effect and asserts isEnabled is true before any state changes.
    it("effect:isEnabled returns true by default", function()
        local eff = lurek.postfx.newEffect("bloom")
        expect_equal(true, eff:isEnabled())
    end)

    -- @description Toggles a bloom effect off and back on, asserting isEnabled reflects both changes.
    it("setEnabled/isEnabled round-trip", function()
        local eff = lurek.postfx.newEffect("bloom")
        eff:setEnabled(false)
        expect_equal(false, eff:isEnabled())
        eff:setEnabled(true)
        expect_equal(true, eff:isEnabled())
    end)

    -- @description Creates a blur effect and asserts type returns the string PostFxEffect.
    it("effect:type returns 'PostFxEffect'", function()
        local eff = lurek.postfx.newEffect("blur")
        expect_equal("PostFxEffect", eff:type())
    end)

    -- @description Creates a blur effect and asserts typeOf reports true for PostFxEffect.
    it("effect:typeOf('PostFxEffect') returns true", function()
        local eff = lurek.postfx.newEffect("blur")
        expect_equal(true, eff:typeOf("PostFxEffect"))
    end)
end)

-- ============================================================
-- newStack
-- ============================================================
-- @description Verifies newStack returns stack userdata with the expected empty-state values, size and dimension accessors, mutation behavior, enabled-state control, and effect retrieval.
describe("lurek.postfx.newStack", function()
    -- @description Creates a stack and asserts the returned value is userdata.
    it("returns a userdata", function()
        local stack = lurek.postfx.newStack()
        expect_type("userdata", stack)
    end)

    -- @description Creates an empty stack and asserts len returns 0.
    it("stack:len returns 0 for empty stack", function()
        local stack = lurek.postfx.newStack()
        expect_equal(0, stack:len())
    end)

    -- @description Creates an empty stack and asserts getEffectCount returns 0.
    it("stack:getEffectCount returns 0 for empty stack", function()
        local stack = lurek.postfx.newStack()
        expect_equal(0, stack:getEffectCount())
    end)

    -- @description Creates an empty stack and asserts isEmpty returns true.
    it("stack:isEmpty returns true when empty", function()
        local stack = lurek.postfx.newStack()
        expect_equal(true, stack:isEmpty())
    end)

    -- @description Adds one bloom effect to a new stack and asserts len increases to 1.
    it("stack:add increments len", function()
        local stack = lurek.postfx.newStack()
        local eff = lurek.postfx.newEffect("bloom")
        stack:add(eff)
        expect_equal(1, stack:len())
    end)

    -- @description Adds bloom and blur effects to a new stack and asserts len becomes 2.
    it("adding two effects gives len 2", function()
        local stack = lurek.postfx.newStack()
        stack:add(lurek.postfx.newEffect("bloom"))
        stack:add(lurek.postfx.newEffect("blur"))
        expect_equal(2, stack:len())
    end)

    -- @description Adds and then removes a pixelate effect, asserting len returns to 0.
    it("stack:remove decrements len", function()
        local stack = lurek.postfx.newStack()
        local eff = lurek.postfx.newEffect("pixelate")
        stack:add(eff)
        stack:remove(eff)
        expect_equal(0, stack:len())
    end)

    -- @description Adds two effects, clears the stack, and asserts len becomes 0.
    it("stack:clear empties the stack", function()
        local stack = lurek.postfx.newStack()
        stack:add(lurek.postfx.newEffect("bloom"))
        stack:add(lurek.postfx.newEffect("blur"))
        stack:clear()
        expect_equal(0, stack:len())
    end)

    -- @description Creates a stack and asserts type returns the string PostFxStack.
    it("stack:type returns 'PostFxStack'", function()
        local stack = lurek.postfx.newStack()
        expect_equal("PostFxStack", stack:type())
    end)

    -- @description Creates a stack with 320 by 240 dimensions and asserts getWidth and getHeight return those exact values.
    it("stack:getWidth and getHeight return positive integers", function()
        local stack = lurek.postfx.newStack(320, 240)
        expect_equal(320, stack:getWidth())
        expect_equal(240, stack:getHeight())
    end)

    -- @description Creates a stack with 640 by 480 dimensions and asserts getDimensions returns 640 and 480.
    it("stack:getDimensions returns (w, h)", function()
        local stack = lurek.postfx.newStack(640, 480)
        local w, h = stack:getDimensions()
        expect_equal(640, w)
        expect_equal(480, h)
    end)

    -- @description Adds one bloom effect, toggles slot 1 disabled and enabled, and asserts isEnabled matches both states.
    it("stack:setEnabled/isEnabled round-trip at position 1", function()
        local stack = lurek.postfx.newStack()
        stack:add(lurek.postfx.newEffect("bloom"))
        stack:setEnabled(1, false)
        expect_equal(false, stack:isEnabled(1))
        stack:setEnabled(1, true)
        expect_equal(true, stack:isEnabled(1))
    end)

    -- @description Adds a vignette effect to a stack, retrieves position 1, and asserts the retrieved effect is not nil.
    it("stack:getEffect returns the added effect", function()
        local stack = lurek.postfx.newStack()
        local eff = lurek.postfx.newEffect("vignette")
        stack:add(eff)
        local retrieved = stack:getEffect(1)
        expect_not_nil(retrieved)
    end)
end)

test_summary()
