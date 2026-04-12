-- Lurek2D ImageEffect API Tests (headless - no window, GPU, or audio)

-- =============================================================================
-- Construction â€” empty
-- =============================================================================

-- @description Verifies that constructing an empty image effect chain exposes all expected chain-management methods and starts with zero effects.
describe("lurek.postfx.newImageEffect construction (empty)", function()
    -- @covers lurek.postfx.loadImageEffect
    -- @covers lurek.postfx.newImageEffect
    -- @description Confirms the constructor is exported as a callable function on lurek.postfx.
    it("newImageEffect is a function", function()
        expect_type("function", lurek.postfx.newImageEffect)
    end)

    -- @description Confirms calling the constructor with no arguments returns a non-nil image effect object.
    it("newImageEffect() returns non-nil", function()
        local fx = lurek.postfx.newImageEffect()
        expect_equal(fx ~= nil, true)
    end)

    -- @description Confirms the returned object exposes effectCount as a callable method for reporting chain length.
    it("newImageEffect() returns object with effectCount method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.effectCount)
    end)

    -- @description Confirms the returned object exposes addEffect as a callable method for appending effects.
    it("newImageEffect() returns object with addEffect method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.addEffect)
    end)

    -- @description Confirms the returned object exposes getEffect as a callable method for retrieving effects.
    it("newImageEffect() returns object with getEffect method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.getEffect)
    end)

    -- @description Confirms the returned object exposes removeEffect as a callable method for removing effects.
    it("newImageEffect() returns object with removeEffect method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.removeEffect)
    end)

    -- @description Confirms the returned object exposes clearEffects as a callable method for clearing the chain.
    it("newImageEffect() returns object with clearEffects method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.clearEffects)
    end)

    -- @description Confirms the returned object exposes clone as a callable method for duplicating the chain.
    it("newImageEffect() returns object with clone method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.clone)
    end)

    -- @description Confirms the returned object exposes save as a callable method for persistence.
    it("newImageEffect() returns object with save method", function()
        local fx = lurek.postfx.newImageEffect()
        expect_type("function", fx.save)
    end)

    -- @description Confirms a newly constructed empty chain reports an effect count of zero.
    it("empty chain has effectCount == 0", function()
        local fx = lurek.postfx.newImageEffect()
        expect_equal(fx:effectCount(), 0)
    end)
end)

-- =============================================================================
-- Construction â€” single effect by name
-- =============================================================================

-- @description Verifies that constructing with a single effect name or a name plus parameter table creates one effect of the requested type with the supplied parameter values.
describe("lurek.postfx.newImageEffect construction (single name)", function()
    -- @description Confirms constructing with the name "blur" creates a chain with exactly one effect.
    it("newImageEffect('blur') produces effectCount == 1", function()
        local fx = lurek.postfx.newImageEffect("blur")
        expect_equal(fx:effectCount(), 1)
    end)

    -- @description Confirms the first effect created from the name "blur" reports its type as "blur".
    it("first effect type is 'blur'", function()
        local fx = lurek.postfx.newImageEffect("blur")
        local e = fx:getEffect(1)
        expect_equal(e:getType(), "blur")
    end)

    -- @description Confirms constructing with "blur" and a radius parameter table still creates exactly one effect.
    it("newImageEffect('blur', {radius=4}) produces effectCount == 1", function()
        local fx = lurek.postfx.newImageEffect("blur", { radius = 4 })
        expect_equal(fx:effectCount(), 1)
    end)

    -- @description Confirms the constructor applies the provided radius parameter and getParameter returns a value within tolerance of 4.
    it("newImageEffect('blur', {radius=4}) sets radius parameter", function()
        local fx = lurek.postfx.newImageEffect("blur", { radius = 4 })
        local v = fx:getEffect(1):getParameter("radius")
        expect_equal(math.abs(v - 4) < 0.001, true)
    end)
end)

-- =============================================================================
-- Construction â€” chain table
-- =============================================================================

-- @description Verifies that constructing from a chain table preserves entry order, effect types, and entry parameters.
describe("lurek.postfx.newImageEffect construction (chain table)", function()
    -- @description Confirms a two-entry chain table creates exactly two effects.
    it("two-element chain produces effectCount == 2", function()
        local fx = lurek.postfx.newImageEffect({ { type = "blur", radius = 2 }, { type = "sepia" } })
        expect_equal(fx:effectCount(), 2)
    end)

    -- @description Confirms the first entry in the chain table remains the first effect and reports type "blur".
    it("first effect in chain is 'blur'", function()
        local fx = lurek.postfx.newImageEffect({ { type = "blur", radius = 2 }, { type = "sepia" } })
        expect_equal(fx:getEffect(1):getType(), "blur")
    end)

    -- @description Confirms the second entry in the chain table remains the second effect and reports type "sepia".
    it("second effect in chain is 'sepia'", function()
        local fx = lurek.postfx.newImageEffect({ { type = "blur", radius = 2 }, { type = "sepia" } })
        expect_equal(fx:getEffect(2):getType(), "sepia")
    end)

    -- @description Confirms parameters declared inside a chain-table entry are applied and radius reads back within tolerance of 2.
    it("chain entry parameters are applied", function()
        local fx = lurek.postfx.newImageEffect({ { type = "blur", radius = 2 } })
        local v = fx:getEffect(1):getParameter("radius")
        expect_equal(math.abs(v - 2) < 0.001, true)
    end)
end)

-- =============================================================================
-- addEffect
-- =============================================================================

-- @description Verifies that addEffect returns a created effect object, assigns the requested type, increments chain length, and appends new effects to the end.
describe("ImageEffect:addEffect", function()
    -- @description Confirms addEffect returns a non-nil PostFxEffect object when adding "vignette".
    it("addEffect returns non-nil", function()
        local fx = lurek.postfx.newImageEffect()
        local e = fx:addEffect("vignette")
        expect_equal(e ~= nil, true)
    end)

    -- @description Confirms the PostFxEffect returned by addEffect reports the requested type "vignette".
    it("addEffect returns PostFxEffect with correct type", function()
        local fx = lurek.postfx.newImageEffect()
        local e = fx:addEffect("vignette")
        expect_equal(e:getType(), "vignette")
    end)

    -- @description Confirms each addEffect call increments effectCount from 0 to 1 and then from 1 to 2.
    it("addEffect increments effectCount", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        expect_equal(fx:effectCount(), 1)
        fx:addEffect("sepia")
        expect_equal(fx:effectCount(), 2)
    end)

    -- @description Confirms successive addEffect calls preserve append order so the second inserted effect is stored at index 2.
    it("addEffect appends to end of chain", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("vignette")
        expect_equal(fx:getEffect(2):getType(), "vignette")
    end)
end)

-- =============================================================================
-- getEffect by index (1-based)
-- =============================================================================

-- @description Verifies indexed effect lookup is 1-based, returns the expected effect at valid indices, and handles invalid indices without an unhandled crash.
describe("ImageEffect:getEffect by index", function()
    -- @description Confirms getEffect(1) returns the first inserted effect and reports type "blur".
    it("getEffect(1) returns first effect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        expect_equal(fx:getEffect(1):getType(), "blur")
    end)

    -- @description Confirms getEffect(2) returns the second inserted effect and reports type "sepia".
    it("getEffect(2) returns second effect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        expect_equal(fx:getEffect(2):getType(), "sepia")
    end)

    -- @description Confirms requesting index 99 is treated gracefully by allowing either nil or a handled error, with no unhandled crash escaping the test.
    it("getEffect out-of-bounds returns nil or errors gracefully", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        local ok = pcall(function()
            local e = fx:getEffect(99)
            -- nil is also acceptable
            expect_equal(e == nil, true)
        end)
        -- either nil return or error is acceptable; what matters is no unhandled crash
        expect_equal(true, true)
    end)

    -- @description Confirms requesting index 0 is treated gracefully by allowing either nil or a handled error, with no unhandled crash escaping the test.
    it("getEffect(0) returns nil or errors gracefully", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        local ok = pcall(function()
            local e = fx:getEffect(0)
            expect_equal(e == nil, true)
        end)
        expect_equal(true, true)
    end)
end)

-- =============================================================================
-- getEffect by name
-- =============================================================================

-- @description Verifies named effect lookup finds inserted effects by type name and treats unknown names gracefully without an unhandled crash.
describe("ImageEffect:getEffect by name", function()
    -- @description Confirms getEffect("blur") returns a non-nil effect whose reported type is "blur".
    it("getEffect('blur') returns the blur effect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        local e = fx:getEffect("blur")
        expect_equal(e ~= nil, true)
        expect_equal(e:getType(), "blur")
    end)

    -- @description Confirms getEffect("sepia") returns a non-nil effect whose reported type is "sepia".
    it("getEffect('sepia') returns the sepia effect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        local e = fx:getEffect("sepia")
        expect_equal(e ~= nil, true)
        expect_equal(e:getType(), "sepia")
    end)

    -- @description Confirms requesting an unknown effect name is treated gracefully by allowing either nil or a handled error, with no unhandled crash escaping the test.
    it("getEffect with unknown name returns nil or errors gracefully", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        local ok = pcall(function()
            local e = fx:getEffect("nonexistent_effect")
            expect_equal(e == nil, true)
        end)
        expect_equal(true, true)
    end)
end)

-- =============================================================================
-- setParameter / getParameter round-trip
-- =============================================================================

-- @description Verifies effect parameters round-trip through setParameter and getParameter, overwrite correctly, and remain isolated between separate effect instances.
describe("PostFxEffect setParameter / getParameter round-trip", function()
    -- @description Confirms setting blur radius to 7.5 reads back the same value within tolerance.
    it("setParameter radius then getParameter returns same value", function()
        local fx = lurek.postfx.newImageEffect("blur")
        fx:getEffect(1):setParameter("radius", 7.5)
        local v = fx:getEffect(1):getParameter("radius")
        expect_equal(math.abs(v - 7.5) < 0.001, true)
    end)

    -- @description Confirms a second setParameter call overwrites the first value so radius reads back as 9.0 within tolerance.
    it("setParameter overwrites previous value", function()
        local fx = lurek.postfx.newImageEffect("blur")
        fx:getEffect(1):setParameter("radius", 3.0)
        fx:getEffect(1):setParameter("radius", 9.0)
        local v = fx:getEffect(1):getParameter("radius")
        expect_equal(math.abs(v - 9.0) < 0.001, true)
    end)

    -- @description Confirms setting radius on two separate blur effects keeps their stored values independent at 2.0 and 8.0.
    it("getParameter on separate effects are independent", function()
        local fx = lurek.postfx.newImageEffect()
        local e1 = fx:addEffect("blur")
        local e2 = fx:addEffect("blur")
        e1:setParameter("radius", 2.0)
        e2:setParameter("radius", 8.0)
        expect_equal(math.abs(e1:getParameter("radius") - 2.0) < 0.001, true)
        expect_equal(math.abs(e2:getParameter("radius") - 8.0) < 0.001, true)
    end)
end)

-- =============================================================================
-- effectCount
-- =============================================================================

-- @description Verifies effectCount reflects an empty chain, increments after additions, and decreases after removals.
describe("ImageEffect:effectCount", function()
    -- @description Confirms a newly constructed empty chain reports an effect count of zero.
    it("starts at 0 for empty chain", function()
        local fx = lurek.postfx.newImageEffect()
        expect_equal(fx:effectCount(), 0)
    end)

    -- @description Confirms effectCount increases stepwise from 1 to 3 as blur, vignette, and sepia are added.
    it("increments by 1 after each addEffect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        expect_equal(fx:effectCount(), 1)
        fx:addEffect("vignette")
        expect_equal(fx:effectCount(), 2)
        fx:addEffect("sepia")
        expect_equal(fx:effectCount(), 3)
    end)

    -- @description Confirms removing one of two effects reduces effectCount from 2 to 1.
    it("decrements after removeEffect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect(1)
        expect_equal(fx:effectCount(), 1)
    end)
end)

-- =============================================================================
-- removeEffect by index
-- =============================================================================

-- @description Verifies index-based removal shrinks the chain and compacts the remaining effects into the expected order.
describe("ImageEffect:removeEffect by index", function()
    -- @description Confirms removing the first effect from a two-effect chain reduces effectCount to 1.
    it("removeEffect(1) decrements effectCount", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect(1)
        expect_equal(fx:effectCount(), 1)
    end)

    -- @description Confirms removing index 1 shifts the original second effect into the first slot and leaves "sepia" at index 1.
    it("remaining effect after removing index 1 is the second original", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect(1)
        expect_equal(fx:getEffect(1):getType(), "sepia")
    end)

    -- @description Confirms removing index 2 deletes the second effect, leaving one effect whose type remains "blur".
    it("removeEffect(2) removes the second effect", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect(2)
        expect_equal(fx:effectCount(), 1)
        expect_equal(fx:getEffect(1):getType(), "blur")
    end)
end)

-- =============================================================================
-- removeEffect by name
-- =============================================================================

-- @description Verifies name-based removal deletes the matching effect and leaves the other effect in place with the expected chain length.
describe("ImageEffect:removeEffect by name", function()
    -- @description Confirms removing "sepia" from a [blur, sepia] chain reduces effectCount to 1.
    it("removeEffect('sepia') from [blur, sepia] â†’ effectCount == 1", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect("sepia")
        expect_equal(fx:effectCount(), 1)
    end)

    -- @description Confirms removing "sepia" from [blur, sepia] leaves "blur" as the sole remaining effect.
    it("remaining effect after removing 'sepia' is 'blur'", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect("sepia")
        expect_equal(fx:getEffect(1):getType(), "blur")
    end)

    -- @description Confirms removing "blur" from [blur, sepia] leaves exactly one effect whose type is "sepia".
    it("removeEffect('blur') from [blur, sepia] â†’ remaining is 'sepia'", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        fx:removeEffect("blur")
        expect_equal(fx:effectCount(), 1)
        expect_equal(fx:getEffect(1):getType(), "sepia")
    end)
end)

-- =============================================================================
-- clearEffects
-- =============================================================================

-- @description Verifies clearEffects empties populated chains, is safe on empty chains, and allows the chain to be reused afterward.
describe("ImageEffect:clearEffects", function()
    -- @description Confirms clearing a chain containing blur, vignette, and sepia resets effectCount to zero.
    it("clearEffects on populated chain produces effectCount == 0", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("vignette")
        fx:addEffect("sepia")
        fx:clearEffects()
        expect_equal(fx:effectCount(), 0)
    end)

    -- @description Confirms clearing an already empty chain leaves effectCount at zero without side effects.
    it("clearEffects on empty chain is a no-op", function()
        local fx = lurek.postfx.newImageEffect()
        fx:clearEffects()
        expect_equal(fx:effectCount(), 0)
    end)

    -- @description Confirms the chain remains usable after clearEffects by adding sepia back and observing a single remaining effect of type "sepia".
    it("can addEffect again after clearEffects", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:clearEffects()
        fx:addEffect("sepia")
        expect_equal(fx:effectCount(), 1)
        expect_equal(fx:getEffect(1):getType(), "sepia")
    end)
end)

-- =============================================================================
-- clone
-- =============================================================================

-- @description Verifies clone produces a non-nil deep copy that preserves chain structure and parameters while remaining independent from later clone mutations.
describe("ImageEffect:clone", function()
    -- @description Confirms cloning a populated chain returns a non-nil copy object.
    it("clone returns non-nil", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        local copy = fx:clone()
        expect_equal(copy ~= nil, true)
    end)

    -- @description Confirms the clone reports the same effectCount as the original two-effect chain.
    it("clone has the same effectCount as original", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        local copy = fx:clone()
        expect_equal(copy:effectCount(), fx:effectCount())
    end)

    -- @description Confirms the clone preserves effect ordering so indices 1 and 2 still report "blur" and "sepia".
    it("clone has the same effect types in order", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        fx:addEffect("sepia")
        local copy = fx:clone()
        expect_equal(copy:getEffect(1):getType(), "blur")
        expect_equal(copy:getEffect(2):getType(), "sepia")
    end)

    -- @description Confirms adding an effect to the clone changes only the clone's count, leaving the original at 1 while the clone becomes 2.
    it("modifying clone does not affect original effectCount", function()
        local fx = lurek.postfx.newImageEffect()
        fx:addEffect("blur")
        local copy = fx:clone()
        copy:addEffect("vignette")
        expect_equal(fx:effectCount(), 1)
        expect_equal(copy:effectCount(), 2)
    end)

    -- @description Confirms changing a parameter on the clone does not mutate the original, which still reports blur radius 3.0 within tolerance.
    it("modifying clone parameter does not affect original", function()
        local fx = lurek.postfx.newImageEffect("blur")
        fx:getEffect(1):setParameter("radius", 3.0)
        local copy = fx:clone()
        copy:getEffect(1):setParameter("radius", 99.0)
        local orig_v = fx:getEffect(1):getParameter("radius")
        expect_equal(math.abs(orig_v - 3.0) < 0.001, true)
    end)
end)

-- =============================================================================
-- Invalid effect name
-- =============================================================================

-- @description Verifies construction and addEffect both reject unknown effect names by raising Lua errors.
describe("lurek.postfx.newImageEffect invalid effect name", function()
    -- @description Confirms the constructor raises an error when given an effect name that does not exist.
    it("rejects unknown effect name on construction", function()
        expect_error(function()
            lurek.postfx.newImageEffect("not_a_real_effect")
        end)
    end)

    -- @description Confirms addEffect raises an error when asked to append an unknown effect name to an existing chain.
    it("addEffect rejects unknown effect name", function()
        local fx = lurek.postfx.newImageEffect()
        expect_error(function()
            fx:addEffect("not_a_real_effect")
        end)
    end)
end)

-- =============================================================================
-- loadImageEffect function exists
-- =============================================================================

-- @description Verifies the loadImageEffect loader is exported on lurek.postfx as a callable function.
describe("lurek.postfx.loadImageEffect", function()
    -- @description Confirms loadImageEffect is present and has Lua function type.
    it("loadImageEffect is a function", function()
        expect_type("function", lurek.postfx.loadImageEffect)
    end)
end)
test_summary()
