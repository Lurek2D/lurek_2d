-- Lurek2D Library Sprite Tests
-- @testCategory library
-- @library lurek.library_sprite

require("tests/lua/init")
local SpriteLib = require("library.sprite")

local SpriteAnimator = SpriteLib.SpriteAnimator
local AnimController = SpriteLib.AnimController

local clips = {
    idle = { row = 1, from = 1, to = 4, fps = 8,  loop = true  },
    run  = { row = 2, from = 1, to = 8, fps = 12, loop = true  },
    jump = { row = 3, from = 1, to = 6, fps = 10, loop = false },
}

--                  SpriteAnimator

-- @describe SpriteAnimator
describe("SpriteAnimator", function()
    -- @covers SpriteAnimator.new
    it("new() returns non-nil animator", function()
        local anim = SpriteAnimator.new(clips)
        expect_not_nil(anim)
    end)

    -- @covers SpriteAnimator:play, SpriteAnimator:currentClip
    it("play() sets the current clip", function()
        local anim = SpriteAnimator.new(clips)
        anim:play("run")
        expect_equal(anim:currentClip(), "run")
    end)

    -- @covers SpriteAnimator:currentFrame
    it("currentFrame() returns correct initial frame", function()
        local anim = SpriteAnimator.new(clips)
        anim:play("idle")
        local row, col = anim:currentFrame()
        expect_equal(row, 1)
        expect_equal(col, 1)
    end)

    -- @covers SpriteAnimator:update, SpriteAnimator:currentFrame
    it("update() advances frame after enough dt", function()
        local anim = SpriteAnimator.new(clips)
        anim:play("idle") -- fps=8, frame_time=0.125
        anim:update(0.13) -- slightly past one frame
        local row, col = anim:currentFrame()
        expect_equal(row, 1)
        expect_equal(col, 2)
    end)

    -- @covers SpriteAnimator:pause, SpriteAnimator:resume, SpriteAnimator:isPlaying
    it("pause()/resume() toggles playing state", function()
        local anim = SpriteAnimator.new(clips)
        anim:play("idle")
        expect_true(anim:isPlaying())

        anim:pause()
        expect_true(not anim:isPlaying())

        anim:resume()
        expect_true(anim:isPlaying())
    end)

    -- @covers SpriteAnimator:stop, SpriteAnimator:isPlaying, SpriteAnimator:currentFrame
    it("stop() resets to first frame and stops", function()
        local anim = SpriteAnimator.new(clips)
        anim:play("idle")
        anim:update(0.13) -- advance one frame
        anim:stop()

        expect_true(not anim:isPlaying())
        local _, col = anim:currentFrame()
        expect_equal(col, 1)
    end)
end)

--                  AnimController

-- @describe AnimController
describe("AnimController", function()
    -- @covers AnimController.new
    it("new() returns a controller", function()
        local anim = SpriteAnimator.new(clips)
        local ctrl = AnimController.new(anim, {
            rules   = {},
            default = "idle",
        })
        expect_not_nil(ctrl)
    end)

    -- @covers AnimController:update, AnimController:getState
    it("evaluates rules and selects matching state", function()
        local anim = SpriteAnimator.new(clips)
        local ctrl = AnimController.new(anim, {
            rules = {
                { state = "run",  condition = function(ctx) return ctx.speed > 0 end },
                { state = "jump", condition = function(ctx) return ctx.airborne end },
            },
            default = "idle",
        })

        ctrl:update(0.016, { speed = 5, airborne = false })
        expect_equal(ctrl:getState(), "run")

        ctrl:update(0.016, { speed = 0, airborne = false })
        expect_equal(ctrl:getState(), "idle")
    end)

    -- @covers AnimController:force, AnimController:getState
    it("force() locks state temporarily", function()
        local anim = SpriteAnimator.new(clips)
        local ctrl = AnimController.new(anim, {
            rules   = { { state = "run", condition = function() return true end } },
            default = "idle",
        })

        ctrl:update(0.016, {})
        expect_equal(ctrl:getState(), "run")

        ctrl:force("jump", 0.5)
        expect_equal(ctrl:getState(), "jump")

        -- Still forced after partial tick
        ctrl:update(0.2, {})
        expect_equal(ctrl:getState(), "jump")

        -- Expires after remaining duration
        ctrl:update(0.4, {})
        -- Force expired, rules re-evaluated on next update
        ctrl:update(0.016, {})
        expect_equal(ctrl:getState(), "run")
    end)

    -- @covers AnimController:onStateChange
    it("onStateChange callback fires on transition", function()
        local anim = SpriteAnimator.new(clips)
        local ctrl = AnimController.new(anim, {
            rules   = { { state = "run", condition = function(ctx) return ctx.moving end } },
            default = "idle",
        })

        local transitions = {}
        ctrl:onStateChange(function(old, new)
            transitions[#transitions + 1] = { old = old, new = new }
        end)

        ctrl:update(0.016, { moving = false }) -- nil -> idle
        ctrl:update(0.016, { moving = true })  -- idle -> run

        expect_equal(#transitions, 2)
        expect_equal(transitions[1].new, "idle")
        expect_equal(transitions[2].old, "idle")
        expect_equal(transitions[2].new, "run")
    end)
end)

test_summary()
