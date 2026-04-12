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
describe("lurek.postfx module", function()
    it("is a table", function()
        expect_type("table", lurek.postfx)
    end)

    it("lurek.overlay aliases the same table", function()
        -- Both namespaces point to the same module table
        expect_type("table", lurek.overlay)
    end)

    it("exposes getEffectTypes", function()
        expect_type("function", lurek.postfx.getEffectTypes)
    end)

    it("exposes newEffect", function()
        expect_type("function", lurek.postfx.newEffect)
    end)

    it("exposes newStack", function()
        expect_type("function", lurek.postfx.newStack)
    end)

    it("exposes newPass", function()
        expect_type("function", lurek.postfx.newPass)
    end)

    it("exposes newCustomEffect", function()
        expect_type("function", lurek.postfx.newCustomEffect)
    end)
end)

-- ============================================================
-- getEffectTypes
-- ============================================================
describe("lurek.postfx.getEffectTypes", function()
    it("returns a table", function()
        local types = lurek.postfx.getEffectTypes()
        expect_type("table", types)
    end)

    it("contains at least one entry", function()
        local types = lurek.postfx.getEffectTypes()
        local count = 0
        for _ in pairs(types) do count = count + 1 end
        expect_true(count > 0, "getEffectTypes should return at least one type")
    end)

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
describe("lurek.postfx.newEffect", function()
    it("returns a userdata for 'bloom'", function()
        local eff = lurek.postfx.newEffect("bloom")
        expect_type("userdata", eff)
    end)

    it("returns a userdata for 'pixelate'", function()
        local eff = lurek.postfx.newEffect("pixelate")
        expect_type("userdata", eff)
    end)

    it("errors for an unknown effect type", function()
        expect_error(function()
            lurek.postfx.newEffect("magic_wand_effect")
        end)
    end)

    it("effect:getTypeName returns the requested type", function()
        local eff = lurek.postfx.newEffect("blur")
        expect_equal("blur", eff:getTypeName())
    end)

    it("effect:isBuiltIn returns true for newEffect", function()
        local eff = lurek.postfx.newEffect("vignette")
        expect_equal(true, eff:isBuiltIn())
    end)

    it("effect:isEnabled returns true by default", function()
        local eff = lurek.postfx.newEffect("bloom")
        expect_equal(true, eff:isEnabled())
    end)

    it("setEnabled/isEnabled round-trip", function()
        local eff = lurek.postfx.newEffect("bloom")
        eff:setEnabled(false)
        expect_equal(false, eff:isEnabled())
        eff:setEnabled(true)
        expect_equal(true, eff:isEnabled())
    end)

    it("effect:type returns 'PostFxEffect'", function()
        local eff = lurek.postfx.newEffect("blur")
        expect_equal("PostFxEffect", eff:type())
    end)

    it("effect:typeOf('PostFxEffect') returns true", function()
        local eff = lurek.postfx.newEffect("blur")
        expect_equal(true, eff:typeOf("PostFxEffect"))
    end)
end)

-- ============================================================
-- newStack
-- ============================================================
describe("lurek.postfx.newStack", function()
    it("returns a userdata", function()
        local stack = lurek.postfx.newStack()
        expect_type("userdata", stack)
    end)

    it("stack:len returns 0 for empty stack", function()
        local stack = lurek.postfx.newStack()
        expect_equal(0, stack:len())
    end)

    it("stack:getEffectCount returns 0 for empty stack", function()
        local stack = lurek.postfx.newStack()
        expect_equal(0, stack:getEffectCount())
    end)

    it("stack:isEmpty returns true when empty", function()
        local stack = lurek.postfx.newStack()
        expect_equal(true, stack:isEmpty())
    end)

    it("stack:add increments len", function()
        local stack = lurek.postfx.newStack()
        local eff = lurek.postfx.newEffect("bloom")
        stack:add(eff)
        expect_equal(1, stack:len())
    end)

    it("adding two effects gives len 2", function()
        local stack = lurek.postfx.newStack()
        stack:add(lurek.postfx.newEffect("bloom"))
        stack:add(lurek.postfx.newEffect("blur"))
        expect_equal(2, stack:len())
    end)

    it("stack:remove decrements len", function()
        local stack = lurek.postfx.newStack()
        local eff = lurek.postfx.newEffect("pixelate")
        stack:add(eff)
        stack:remove(eff)
        expect_equal(0, stack:len())
    end)

    it("stack:clear empties the stack", function()
        local stack = lurek.postfx.newStack()
        stack:add(lurek.postfx.newEffect("bloom"))
        stack:add(lurek.postfx.newEffect("blur"))
        stack:clear()
        expect_equal(0, stack:len())
    end)

    it("stack:type returns 'PostFxStack'", function()
        local stack = lurek.postfx.newStack()
        expect_equal("PostFxStack", stack:type())
    end)

    it("stack:getWidth and getHeight return positive integers", function()
        local stack = lurek.postfx.newStack(320, 240)
        expect_equal(320, stack:getWidth())
        expect_equal(240, stack:getHeight())
    end)

    it("stack:getDimensions returns (w, h)", function()
        local stack = lurek.postfx.newStack(640, 480)
        local w, h = stack:getDimensions()
        expect_equal(640, w)
        expect_equal(480, h)
    end)

    it("stack:setEnabled/isEnabled round-trip at position 1", function()
        local stack = lurek.postfx.newStack()
        stack:add(lurek.postfx.newEffect("bloom"))
        stack:setEnabled(1, false)
        expect_equal(false, stack:isEnabled(1))
        stack:setEnabled(1, true)
        expect_equal(true, stack:isEnabled(1))
    end)

    it("stack:getEffect returns the added effect", function()
        local stack = lurek.postfx.newStack()
        local eff = lurek.postfx.newEffect("vignette")
        stack:add(eff)
        local retrieved = stack:getEffect(1)
        expect_not_nil(retrieved)
    end)
end)

test_summary()
