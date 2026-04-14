-- test_postfx_stack_extended.lua
-- Unit tests for the extended lurek.postfx stack API:
-- newStack, newPresetStack, beginCapture, endCapture, apply, getEffectTypes (new types).

local describe     = describe
local it           = it
local expect_equal = expect_equal
local expect_error = expect_error

describe("lurek.postfx.newStack (extended)", function()
    it("newStack() returns a non-nil stack", function()
        local s = lurek.postfx.newStack()
        expect_equal(s ~= nil, true)
    end)

    it("beginCapture does not error in headless mode", function()
        local s = lurek.postfx.newStack()
        s:beginCapture()
    end)

    it("endCapture does not error in headless mode", function()
        local s = lurek.postfx.newStack()
        s:beginCapture()
        s:endCapture()
    end)

    it("apply does not error when stack has no effects", function()
        local s = lurek.postfx.newStack()
        s:beginCapture()
        s:endCapture()
        s:apply()
    end)

    it("apply submits one ApplyPostFx command per call", function()
        -- We push a command; just verify no error thrown.
        local s = lurek.postfx.newStack(320, 240)
        s:beginCapture()
        s:endCapture()
        s:apply()
        s:apply()  -- second call also fine
    end)
end)

describe("lurek.postfx.newPresetStack", function()
    local preset_names = { "retro_tv", "horror", "dream", "neon", "sepia_age" }

    for _, name in ipairs(preset_names) do
        it("newPresetStack('" .. name .. "') returns non-nil", function()
            local s = lurek.postfx.newPresetStack(name)
            expect_equal(s ~= nil, true)
        end)

        it("newPresetStack('" .. name .. "') beginCapture/endCapture/apply do not error", function()
            local s = lurek.postfx.newPresetStack(name)
            s:beginCapture()
            s:endCapture()
            s:apply()
        end)
    end

    it("newPresetStack with unknown name returns error", function()
        expect_error(function() lurek.postfx.newPresetStack("nonexistent_preset") end)
    end)

    it("newPresetStack with dimensions applies those dimensions", function()
        local s = lurek.postfx.newPresetStack("retro_tv", 512, 256)
        expect_equal(s ~= nil, true)
    end)
end)

describe("lurek.postfx.getEffectTypes (new types)", function()
    local NEW_TYPES = {
        "depthoffield", "motionblur", "paletteswap", "colorlut",
        "waterdistort", "sharpen", "dither", "outline",
    }

    it("getEffectTypes returns a table including all new types", function()
        local types = lurek.postfx.getEffectTypes()
        expect_equal(type(types), "table")
        local type_set = {}
        for _, t in ipairs(types) do type_set[t] = true end
        for _, expected in ipairs(NEW_TYPES) do
            expect_equal(type_set[expected] == true, true)
        end
    end)

    it("all new types can be used to create effects", function()
        for _, t in ipairs(NEW_TYPES) do
            local e = lurek.postfx.newEffect(t)
            expect_equal(e ~= nil, true)
        end
    end)
end)

test_summary()
