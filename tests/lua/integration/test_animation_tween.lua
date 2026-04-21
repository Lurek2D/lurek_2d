-- tests/lua/integration/test_animation_tween.lua
-- Integration: lurek.animation frame logic combined with lurek.tween interpolation.

describe("animation + tween integration", function()
    it("animation plays frames while tween advances a value", function()
        local anim = lurek.animation.new()
        anim:addFramesFromGrid(1, 1, 8, 1, 0.1)

        local tw = lurek.tween.new()
        local progress = { value = 0.0 }
        tw:tween(progress, { value = 1.0 }, 0.8, "linear")

        -- simulate 4 frames at 0.1 s each
        for _ = 1, 4 do
            anim:update(0.1)
            tw:update(0.1)
        end

        local frame = anim:getCurrentFrame()
        expect_true(frame > 0, "animation advanced past frame 0")
        expect_true(progress.value > 0.0 and progress.value < 1.0,
            "tween is in-progress after 0.4 s of 0.8 s duration")
    end)

    it("tween reaches target before animation loops", function()
        local anim = lurek.animation.new()
        anim:addFramesFromGrid(1, 1, 4, 1, 0.1)
        anim:setLooping(true)

        local tw = lurek.tween.new()
        local obj = { alpha = 0.0 }
        tw:tween(obj, { alpha = 1.0 }, 0.2, "linear")

        -- advance past tween duration
        tw:update(0.25)
        anim:update(0.25)

        expect_near(obj.alpha, 1.0, 0.001, "tween reached 1.0")
        expect_true(anim:isPlaying(), "animation still looping")
    end)

    it("animation addFrame and tween compose without error", function()
        local anim = lurek.animation.new()
        anim:addFrame(1, 1, 16, 16, 0.05)
        anim:addFrame(17, 1, 16, 16, 0.05)

        local tw = lurek.tween.new()
        local obj = { scale = 1.0 }
        tw:tween(obj, { scale = 2.0 }, 0.1, "easeIn")

        tw:update(0.1)
        expect_near(obj.scale, 2.0, 0.01, "scale tweened to 2.0")
        expect_true(anim:getCurrentFrame() >= 0, "animation frame is valid")
    end)
end)

test_summary()
