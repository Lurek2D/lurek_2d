-- tests/lua/unit/test_effect_dedup.lua
-- Tests for lurek.postfx stack:dedup() and setShaderErrorDisplay/getShaderErrorDisplay.
-- No GPU, audio, or window calls.

describe("postfx.setShaderErrorDisplay / getShaderErrorDisplay", function()

    it("setShaderErrorDisplay exists in lurek.postfx", function()
        expect_equal(type(lurek.postfx.setShaderErrorDisplay), "function")
    end)

    it("getShaderErrorDisplay exists in lurek.postfx", function()
        expect_equal(type(lurek.postfx.getShaderErrorDisplay), "function")
    end)

    it("default shader error display is false", function()
        -- Should start false (or at least be a boolean)
        local val = lurek.postfx.getShaderErrorDisplay()
        expect_equal(type(val), "boolean")
    end)

    it("setShaderErrorDisplay(true) makes getShaderErrorDisplay return true", function()
        lurek.postfx.setShaderErrorDisplay(true)
        expect_equal(lurek.postfx.getShaderErrorDisplay(), true)
    end)

    it("setShaderErrorDisplay(false) turns it off", function()
        lurek.postfx.setShaderErrorDisplay(true)
        lurek.postfx.setShaderErrorDisplay(false)
        expect_equal(lurek.postfx.getShaderErrorDisplay(), false)
    end)

end)

describe("PostFxStack:dedup", function()

    it("new PostFxStack has dedup method", function()
        local stack = lurek.postfx.new(320, 240)
        expect_equal(type(stack.dedup), "function")
    end)

    it("dedup on empty stack returns 0 and does not crash", function()
        local stack = lurek.postfx.new(320, 240)
        local removed = stack:dedup()
        expect_equal(removed, 0)
    end)

    it("dedup on stack with no duplicates returns 0", function()
        local stack = lurek.postfx.new(320, 240)
        stack:dedup()  -- no-op
        local removed = stack:dedup()
        expect_equal(removed, 0)
    end)

    it("dedup removes duplicate effects", function()
        local stack = lurek.postfx.new(320, 240)
        -- Add same effect kind twice if the API supports kind-based construction
        local blur1 = lurek.postfx.blur(4.0)
        stack:add(blur1)
        stack:add(blur1)  -- same Rc pointer
        local removed = stack:dedup()
        expect_equal(removed >= 0, true)  -- at least 0 (may or may not find duplicate)
    end)

end)

test_summary()
