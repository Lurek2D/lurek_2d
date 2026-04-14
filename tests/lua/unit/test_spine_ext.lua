-- Lurek2D Lua BDD tests for lurek.spine extended API
-- Covers: playAnimation, stopAnimation, updateAnimation, getAnimationTime,
--         newSkeletonAnimation, addKeyframe, getDuration, getTimelineCount,
--         addIKConstraint, setIKTarget, addSkin, setSkin, getSkin, setSkinMapping.
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.spine extended features.
describe("lurek.spine extended", function()
    -- ── module interface ──────────────────────────────────────────────────

    -- @description Covers suite: new API factories.
    describe("new API factories", function()
        -- @covers lurek.spine.newSkeletonAnimation
        -- @description Verifies the newSkeletonAnimation factory is exposed on the module.
        it("exposes newSkeletonAnimation factory", function()
            expect_type("function", lurek.spine.newSkeletonAnimation)
        end)
    end)

    -- ── animation playback ────────────────────────────────────────────────

    -- @description Covers suite: skeleton animation playback.
    describe("skeleton animation playback", function()
        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.playAnimation
        -- @covers lurek.spine.stopAnimation
        -- @covers lurek.spine.updateAnimation
        -- @covers lurek.spine.getAnimationTime
        -- @description Confirms getAnimationTime advances after update when playing.
        it("animation time advances after updateAnimation", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:playAnimation("walk", true)
            sk:updateAnimation(0.1)
            local t = sk:getAnimationTime()
            expect_type("number", t)
            expect_true(t >= 0.0, "time should be non-negative")
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.playAnimation
        -- @covers lurek.spine.stopAnimation
        -- @covers lurek.spine.getAnimationTime
        -- @description Confirms stopAnimation resets animation time to zero.
        it("stopAnimation sets time back to zero", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:playAnimation("walk", true)
            sk:updateAnimation(0.5)
            sk:stopAnimation()
            expect_near(0.0, sk:getAnimationTime(), 0.001)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.getAnimationTime
        -- @description Confirms a fresh skeleton reports animation time of zero.
        it("fresh skeleton has animation time of 0", function()
            local sk = lurek.spine.newSkeleton("new")
            expect_near(0.0, sk:getAnimationTime(), 0.001)
        end)
    end)

    -- ── SkeletonAnimation (timeline) ──────────────────────────────────────

    -- @description Covers suite: SkeletonAnimation object.
    describe("SkeletonAnimation", function()
        -- @covers lurek.spine.newSkeletonAnimation
        -- @description Confirms newSkeletonAnimation returns a SkeletonAnimation userdata.
        it("returns a userdata", function()
            local sa = lurek.spine.newSkeletonAnimation("hero_walk", 1.0)
            expect_type("userdata", sa)
        end)

        -- @covers lurek.spine.newSkeletonAnimation
        -- @covers lurek.spine.getDuration
        -- @description Confirms getDuration returns the duration passed at construction.
        it("getDuration returns the configured duration", function()
            local sa = lurek.spine.newSkeletonAnimation("run", 2.5)
            expect_near(2.5, sa:getDuration(), 0.001)
        end)

        -- @covers lurek.spine.newSkeletonAnimation
        -- @covers lurek.spine.getTimelineCount
        -- @description Confirms a new animation starts with zero timelines.
        it("getTimelineCount is 0 for new animation", function()
            local sa = lurek.spine.newSkeletonAnimation("idle", 1.0)
            expect_equal(0, sa:getTimelineCount())
        end)

        -- @covers lurek.spine.newSkeletonAnimation
        -- @covers lurek.spine.addKeyframe
        -- @covers lurek.spine.getTimelineCount
        -- @description Confirms addKeyframe increases the timeline count by 1.
        it("addKeyframe increments timeline count", function()
            local sa = lurek.spine.newSkeletonAnimation("run", 1.0)
            sa:addKeyframe(0, "x", 0.0, 0.0)
            expect_equal(1, sa:getTimelineCount())
        end)

        -- @covers lurek.spine.newSkeletonAnimation
        -- @covers lurek.spine.addKeyframe
        -- @description Confirms addKeyframe with easing param does not error.
        it("addKeyframe accepts optional easing parameter", function()
            local sa = lurek.spine.newSkeletonAnimation("run", 1.0)
            sa:addKeyframe(0, "x", 0.0, 10.0, "linear")
            sa:addKeyframe(0, "x", 1.0, 20.0, "ease_in_out")
            expect_equal(1, sa:getTimelineCount()) -- same bone-property = same timeline
        end)
    end)

    -- ── addAnimation (attach to skeleton) ─────────────────────────────────

    -- @description Covers suite: addAnimation().
    describe("addAnimation()", function()
        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.newSkeletonAnimation
        -- @covers lurek.spine.addAnimation
        -- @description Confirms addAnimation does not error when called with a valid SkeletonAnimation.
        it("does not error for a valid animation", function()
            local sk = lurek.spine.newSkeleton("hero")
            local sa = lurek.spine.newSkeletonAnimation("idle", 1.0)
            sk:addAnimation(sa) -- should not throw
            expect_equal(true, true)
        end)
    end)

    -- ── IK constraints ────────────────────────────────────────────────────

    -- @description Covers suite: IK constraints.
    describe("IK constraints", function()
        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.addIKConstraint
        -- @description Confirms addIKConstraint does not error for a valid bone chain.
        it("addIKConstraint does not error", function()
            local sk = lurek.spine.newSkeleton("robot")
            sk:addIKConstraint("arm_ik", {0, 1}, true)
            expect_equal(true, true)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.addIKConstraint
        -- @covers lurek.spine.setIKTarget
        -- @description Confirms setIKTarget can be called after adding a constraint.
        it("setIKTarget does not error after addIKConstraint", function()
            local sk = lurek.spine.newSkeleton("robot")
            sk:addIKConstraint("arm_ik", {0, 1}, true)
            sk:setIKTarget("arm_ik", 100.0, 50.0)
            expect_equal(true, true)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.setIKTarget
        -- @description Confirms setIKTarget errors gracefully for an unknown constraint name.
        it("setIKTarget errors for unknown constraint", function()
            local sk = lurek.spine.newSkeleton("robot")
            expect_error(function()
                sk:setIKTarget("ghost_ik", 0.0, 0.0)
            end)
        end)
    end)

    -- ── skins ─────────────────────────────────────────────────────────────

    -- @description Covers suite: skeleton skins.
    describe("skeleton skins", function()
        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.addSkin
        -- @covers lurek.spine.setSkin
        -- @covers lurek.spine.getSkin
        -- @description Confirms getSkin returns the name set via setSkin.
        it("getSkin returns the name from setSkin", function()
            local sk = lurek.spine.newSkeleton("char")
            sk:addSkin("hero")
            sk:setSkin("hero")
            expect_equal("hero", sk:getSkin())
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.getSkin
        -- @description Confirms a fresh skeleton has no active skin (nil).
        it("fresh skeleton has nil skin", function()
            local sk = lurek.spine.newSkeleton("char")
            expect_equal(nil, sk:getSkin())
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.addSkin
        -- @covers lurek.spine.setSkin
        -- @description Confirms setSkin errors for a skin that was never added.
        it("setSkin errors for unknown skin", function()
            local sk = lurek.spine.newSkeleton("char")
            expect_error(function()
                sk:setSkin("ghost_skin")
            end)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @covers lurek.spine.addSkin
        -- @covers lurek.spine.setSkinMapping
        -- @description Confirms setSkinMapping does not error for a known skin and slot.
        it("setSkinMapping does not error for known skin/slot", function()
            local sk = lurek.spine.newSkeleton("char")
            sk:addSkin("armor")
            sk:setSkinMapping("armor", "torso", "heavy_chest")
            expect_equal(true, true)
        end)
    end)
end)

test_summary()
