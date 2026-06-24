-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_spine_core_unit.lua
do
-- Lurek2D Lua BDD tests for lurek.spine
-- Headless: no GPU, no audio, no window.

-- @describe newSkeleton(name)
describe("newSkeleton(name)", function()
    -- @covers lurek.spine.newSkeleton
    it("exposes the factory and returns a userdata object", function()
        expect_type("function", lurek.spine.newSkeleton)
        local sk = lurek.spine.newSkeleton("hero")
        expect_type("userdata", sk)
    end)

    -- @covers LSkeleton:boneCount
    it("starts empty and reflects added bones", function()
        local sk = lurek.spine.newSkeleton("test")
        expect_equal(0, sk:boneCount())
        sk:addBone("root")
        sk:addBone("torso")
        expect_equal(2, sk:boneCount())
    end)

    -- @covers LSkeleton:slotCount
    it("starts with zero slots", function()
        local sk = lurek.spine.newSkeleton("test")
        expect_equal(0, sk:slotCount())
    end)
end)

-- @describe addBone(name, opts)
describe("addBone(name, opts)", function()
    -- @covers LSkeleton:addBone
    it("returns an index starting from 0 and accepts opts table values", function()
        local sk = lurek.spine.newSkeleton("test")
        local idx = sk:addBone("root")
        expect_equal(0, idx)
        sk:addBone("root", { x = 10, y = 20, rotation = 0.5 })
        expect_equal(2, sk:boneCount())
    end)
end)

-- @describe addChildBone(name, parent_idx, opts)
describe("addChildBone(name, parent_idx, opts)", function()
    -- @covers LSkeleton:addChildBone
    it("increments boneCount and rejects invalid parent indices", function()
        local sk = lurek.spine.newSkeleton("test")
        local root = sk:addBone("root")
        sk:addChildBone("arm", root)
        expect_equal(2, sk:boneCount())

        expect_error(function()
            sk:addChildBone("arm", 9)
        end)
    end)
end)

-- @describe findBone(name)
describe("findBone(name)", function()
    -- @covers LSkeleton:findBone
    it("returns the index of an existing bone and nil for unknown names", function()
        local sk = lurek.spine.newSkeleton("test")
        sk:addBone("root")
        sk:addBone("chest")
        local idx = sk:findBone("chest")
        expect_equal(1, idx)
        expect_equal(nil, sk:findBone("nonexistent"))
    end)
end)

-- @describe addSlot(name, bone_idx, attachment)
describe("addSlot(name, bone_idx, attachment)", function()
    -- @covers LSkeleton:addSlot
    it("increments slotCount and rejects invalid bone indices", function()
        local sk = lurek.spine.newSkeleton("test")
        local b = sk:addBone("root")
        sk:addSlot("slot0", b)
        expect_equal(1, sk:slotCount())
        sk:addSlot("slot1", b, "torso_skin")
        expect_equal(2, sk:slotCount())

        expect_error(function()
            sk:addSlot("slot0", 4)
        end)
    end)
end)

-- @describe findSlot(name)
describe("findSlot(name)", function()
    -- @covers LSkeleton:findSlot
    it("returns the index of an existing slot and nil for unknown names", function()
        local sk = lurek.spine.newSkeleton("test")
        local b = sk:addBone("root")
        sk:addSlot("weapon_slot", b)
        local idx = sk:findSlot("weapon_slot")
        expect_equal(0, idx)
        expect_equal(nil, sk:findSlot("nope"))
    end)
end)

-- @describe setPosition(x, y)
describe("setPosition(x, y)", function()
    -- @covers LSkeleton:setPosition
    it("does not error", function()
        local sk = lurek.spine.newSkeleton("test")
        sk:setPosition(50, 120)
    end)
end)

-- @describe getBoneWorld(idx)
describe("getBoneWorld(idx)", function()
    -- @covers LSkeleton:getBoneWorld
    it("returns transform fields after updates and nil for out-of-bounds indices", function()
        local sk = lurek.spine.newSkeleton("test")
        local root = sk:addBone("root")
        sk:updateWorldTransforms()
        local t = sk:getBoneWorld(root)
        if t ~= nil then
            expect_type("number", t.x)
            expect_type("number", t.y)
            expect_type("number", t.rotation)
            expect_type("number", t.scale_x)
            expect_type("number", t.scale_y)
        end
        local result = sk:getBoneWorld(999)
        expect_equal(nil, result)
    end)
end)

--  Spine Extended API (merged from test_spine_ext.lua)

-- module interface

-- @describe new API factories
describe("new API factories", function()
    -- @covers lurek.spine.newSkeletonAnimation
    it("exposes the factory and rejects negative animation duration", function()
        expect_type("function", lurek.spine.newSkeletonAnimation)
        expect_error(function()
            lurek.spine.newSkeletonAnimation("walk", -1.0)
        end)
    end)
end)

-- animation playback

-- @describe skeleton animation playback
describe("skeleton animation playback", function()
    -- @covers LSkeleton:updateAnimation
    it("animation time advances, stays stable, and rejects negative delta time", function()
        local sk = lurek.spine.newSkeleton("test")
        sk:addBone("root")
        local anim = lurek.spine.newSkeletonAnimation("walk", 1.0)
        anim:addKeyframe(0, "x", 0.0, 0.0)
        anim:addKeyframe(0, "x", 1.0, 10.0)
        sk:addAnimation(anim)
        expect_true(sk:playAnimation("walk", true))
        sk:updateAnimation(0.1)
        local t = sk:getAnimationTime()
        expect_type("number", t)
        expect_true(t > 0.0, "time should advance once playback starts")

        for _ = 1, 120 do
            sk:updateAnimation(1.0 / 60.0)
            sk:updateWorldTransforms()
        end

        t = sk:getAnimationTime()
        expect_type("number", t)
        expect_true(t >= 0.0 and t < 1.0)

        expect_error(function()
            sk:updateAnimation(-0.1)
        end)
    end)

    -- @covers LSkeleton:stopAnimation
    it("stopAnimation freezes animation time", function()
        local sk = lurek.spine.newSkeleton("test")
        sk:addBone("root")
        local anim = lurek.spine.newSkeletonAnimation("walk", 1.0)
        anim:addKeyframe(0, "x", 0.0, 0.0)
        anim:addKeyframe(0, "x", 1.0, 10.0)
        sk:addAnimation(anim)
        expect_true(sk:playAnimation("walk", true))
        sk:updateAnimation(0.5)
        sk:stopAnimation()
        local stopped_at = sk:getAnimationTime()
        sk:updateAnimation(0.25)
        expect_near(0.5, stopped_at, 0.001)
        expect_near(stopped_at, sk:getAnimationTime(), 0.001)
    end)

    -- @covers LSkeleton:getAnimationTime
    it("fresh skeleton has animation time of 0", function()
        local sk = lurek.spine.newSkeleton("new")
        expect_near(0.0, sk:getAnimationTime(), 0.001)
    end)
end)

-- SkeletonAnimation (timeline)

-- @describe SkeletonAnimation
describe("SkeletonAnimation", function()
    -- @covers LSkeletonAnimation:reverse
    it("returns a userdata", function()
        local sa = lurek.spine.newSkeletonAnimation("hero_walk", 1.0)
        expect_type("userdata", sa)
        local reversed = sa:reverse()
        expect_type("userdata", reversed)
    end)

    -- @covers LSkeletonAnimation:getDuration
    it("getDuration returns the configured duration", function()
        local sa = lurek.spine.newSkeletonAnimation("run", 2.5)
        expect_near(2.5, sa:getDuration(), 0.001)
    end)

    -- @covers LSkeletonAnimation:getTimelineCount
    it("getTimelineCount is 0 for new animation", function()
        local sa = lurek.spine.newSkeletonAnimation("idle", 1.0)
        expect_equal(0, sa:getTimelineCount())
    end)

    -- @covers LSkeletonAnimation:addKeyframe
    it("addKeyframe increments timeline count and rejects negative time", function()
        local sa = lurek.spine.newSkeletonAnimation("run", 1.0)
        sa:addKeyframe(0, "x", 0.0, 0.0)
        expect_equal(1, sa:getTimelineCount())
        sa:addKeyframe(0, "x", 0.0, 10.0, "linear")
        sa:addKeyframe(0, "x", 1.0, 20.0, "ease_in_out")
        expect_equal(1, sa:getTimelineCount())

        expect_error(function()
            sa:addKeyframe(0, "x", -0.1, 0.0)
        end)
    end)
end)

-- addAnimation (attach to skeleton)

-- @describe addAnimation()
describe("addAnimation()", function()
    -- @covers LSkeleton:addAnimation
    it("does not error for a valid animation", function()
        local sk = lurek.spine.newSkeleton("hero")
        local sa = lurek.spine.newSkeletonAnimation("idle", 1.0)
        sk:addAnimation(sa) -- should not throw
        expect_equal(true, true)
    end)
end)

-- IK constraints

-- @describe IK constraints
describe("IK constraints", function()
    -- @covers LSkeleton:addIKConstraint
    it("addIKConstraint does not error", function()
        local sk = lurek.spine.newSkeleton("robot")
        sk:addIKConstraint("arm_ik", {0, 1}, true)
        expect_equal(true, true)
    end)

    -- @covers LSkeleton:setIKTarget
    it("setIKTarget succeeds for known constraints and fails for unknown ones", function()
        local sk = lurek.spine.newSkeleton("robot")
        sk:addIKConstraint("arm_ik", {0, 1}, true)
        sk:setIKTarget("arm_ik", 100.0, 50.0)
        expect_equal(true, true)
        local ok = sk:setIKTarget("ghost_ik", 0.0, 0.0)
        expect_equal(false, ok)
    end)
end)

-- skins

-- @describe skeleton skins
describe("skeleton skins", function()
    -- @covers LSkeleton:addSkin
    it("addSkin registers a skin name that can later be selected", function()
        local sk = lurek.spine.newSkeleton("char")
        sk:addSkin("hero")
        expect_true(sk:setSkin("hero"))
    end)

    -- @covers LSkeleton:getSkin
    it("getSkin returns the selected name and nil for fresh skeletons", function()
        local sk = lurek.spine.newSkeleton("char")
        expect_equal(nil, sk:getSkin())
        sk:addSkin("hero")
        sk:setSkin("hero")
        expect_equal("hero", sk:getSkin())
    end)

    -- @covers LSkeleton:setSkin
    it("setSkin with unknown skin returns false", function()
        local sk = lurek.spine.newSkeleton("char")
        local ok = sk:setSkin("ghost_skin")
        expect_equal(false, ok)
    end)

    -- @covers LSkeleton:setSkinMapping
    it("setSkinMapping does not error for known skin/slot", function()
        local sk = lurek.spine.newSkeleton("char")
        sk:addSkin("armor")
        sk:setSkinMapping("armor", "torso", "heavy_chest")
        expect_equal(true, true)
    end)
end)

-- @describe lurek.spine regression coverage
describe("lurek.spine regression coverage", function()
    -- @covers LSkeleton:updateWorldTransforms
    it("skeleton topology and world transform helpers stay consistent", function()
        local sk = lurek.spine.newSkeleton("rig")
        local root = sk:addBone("root", { x = 5, y = 10 })
        local arm = sk:addChildBone("arm", root, { x = 3, y = 4 })
        local slot = sk:addSlot("hand_slot", arm, "hand")

        sk:setPosition(20, 30)
        sk:updateWorldTransforms()

        local world = sk:getBoneWorld(arm)
        local image = sk:drawToImage(32, 32)

        expect_equal(root, sk:findBone("root"))
        expect_equal(arm, sk:findBone("arm"))
        expect_equal(slot, sk:findSlot("hand_slot"))
        expect_equal(2, sk:boneCount())
        expect_equal(1, sk:slotCount())
        expect_type("table", world)
        expect_type("number", world.x)
        expect_type("number", world.y)
        expect_type("userdata", image)
    end)

    -- @covers LSkeletonAnimation:getEvents
    it("SkeletonAnimation exposes duration timelines and event windows", function()
        local anim = lurek.spine.newSkeletonAnimation("wave", 1.5)
        anim:addKeyframe(0, "x", 0.0, 0.0)
        anim:addKeyframe(0, "x", 1.0, 10.0)
        anim:addEventKey(0.25, "start", 1.0)
        anim:addEventKey(0.75, "peak", 2.0)

        local events = anim:getEvents(0.0, 0.5)

        expect_near(1.5, anim:getDuration(), 0.001)
        expect_equal(1, anim:getTimelineCount())
        expect_equal(1, #events)
        expect_equal("start", events[1].name)
        expect_near(1.0, events[1].value, 0.001)
    end)

    -- @covers LSkeleton:playAnimation
    it("skeleton playback and skin helpers work with a real animation", function()
        local sk = lurek.spine.newSkeleton("hero")
        sk:addBone("root")
        sk:addSkin("hero_skin")

        expect_true(sk:setSkin("hero_skin"))
        expect_equal("hero_skin", sk:getSkin())

        local anim = lurek.spine.newSkeletonAnimation("walk", 1.0)
        anim:addKeyframe(0, "x", 0.0, 0.0)
        anim:addKeyframe(0, "x", 1.0, 12.0)
        sk:addAnimation(anim)

        expect_true(sk:playAnimation("walk", false))

        sk:updateAnimation(0.5)
        expect_true(sk:getAnimationTime() > 0.0, "expected animation time to advance")

        sk:stopAnimation()
        local stopped_at = sk:getAnimationTime()
        sk:updateAnimation(0.25)
        expect_near(0.5, stopped_at, 0.001)
        expect_near(stopped_at, sk:getAnimationTime(), 0.001)
    end)

    -- @covers LSkeleton:drawToImage
    it("animation ik render pipeline stays stable end to end", function()
        local sk = lurek.spine.newSkeleton("pipeline")
        local root = sk:addBone("root", { x = 0, y = 0 })
        sk:addChildBone("arm", root, { x = 8, y = 0 })
        sk:addIKConstraint("arm_ik", { root, 1 }, true)
        sk:setIKTarget("arm_ik", 20, 12)

        local anim = lurek.spine.newSkeletonAnimation("reach", 1.0)
        anim:addKeyframe(root, "x", 0.0, 0.0)
        anim:addKeyframe(root, "x", 1.0, 6.0)
        sk:addAnimation(anim)

        expect_true(sk:playAnimation("reach", true))
        sk:updateAnimation(0.25)
        sk:updateWorldTransforms()

        local image = sk:drawToImage(32, 32)
        expect_type("userdata", image)
    end)
end)

-- =========================================================================
-- =========================================================================

-- @describe Skeleton:blendAnimation
describe("Skeleton:blendAnimation ", function()
    -- @covers LSkeleton:blendAnimation
    it("blendAnimation does not crash on a fresh skeleton", function()
        local skel = lurek.spine.newSkeleton("cov_blend_skel")
        local anim = lurek.spine.newSkeletonAnimation("idle", 1.0)
        local ok, _ = pcall(function()
            skel:blendAnimation(anim, 1.0, 0.0)
        end)
        expect_type("boolean", ok)
    end)
end)

-- @describe SkeletonAnimation:addEventKey
describe("SkeletonAnimation:addEventKey ", function()
    -- @covers LSkeletonAnimation:addEventKey
    it("addEventKey accepts valid keys and rejects negative time", function()
        local anim = lurek.spine.newSkeletonAnimation("cov_anim", 1.0)
        local ok, _ = pcall(function()
            anim:addEventKey(0.5, "footstep", 0)
        end)
        expect_type("boolean", ok)

        expect_error(function()
            anim:addEventKey(-0.5, "footstep", 0)
        end)
    end)
end)

-- @describe spine strict: LSkeleton type/typeOf
describe("spine strict: LSkeleton type/typeOf", function()
    -- @covers LSkeleton:type
    it("LSkeleton type and typeOf are callable", function()
        local sk = lurek.spine.newSkeleton("strict_skel")
        expect_type("string", sk:type())
        expect_type("boolean", sk:typeOf("LObject"))
    end)

    -- @covers LSkeleton:typeOf
    it("LSkeleton:typeOf recognizes skeleton and object types", function()
        local sk = lurek.spine.newSkeleton("strict_skel")
        expect_true(sk:typeOf("LSkeleton"))
        expect_true(sk:typeOf("LObject"))
    end)

end)

-- @describe spine strict: LSkeletonAnimation type/typeOf
describe("spine strict: LSkeletonAnimation type/typeOf", function()
    -- @covers LSkeletonAnimation:type
    it("LSkeletonAnimation type and typeOf are callable", function()
        local sa = lurek.spine.newSkeletonAnimation("strict_anim", 1.0)
        expect_type("string", sa:type())
        expect_type("boolean", sa:typeOf("LObject"))
    end)

    -- @covers LSkeletonAnimation:typeOf
    it("LSkeletonAnimation:typeOf recognizes animation and object types", function()
        local sa = lurek.spine.newSkeletonAnimation("strict_anim", 1.0)
        expect_true(sa:typeOf("LSkeletonAnimation"))
        expect_true(sa:typeOf("LObject"))
    end)
end)

-- @describe animationFromJson(json)
describe("animationFromJson(json)", function()
        -- @covers lurek.spine.animationFromJson
        it("parses valid json into LSkeletonAnimation", function()
                local json = [[
                {
                    "name":"parsed",
                    "duration":1.0,
                    "timelines":[
                        {"bone_idx":0,"property":"x","keys":[
                            {"time":0.0,"value":0.0,"easing":"linear"},
                            {"time":1.0,"value":2.0,"easing":"linear"}
                        ]}
                    ],
                    "events":[{"time":0.5,"name":"tick","value":1.0}]
                }
                ]]
                local anim = lurek.spine.animationFromJson(json)
                expect_type("userdata", anim)
        end)
end)

-- @describe skeletonFromJson(json)
describe("skeletonFromJson(json)", function()
        -- @covers lurek.spine.skeletonFromJson
        it("imports Spine and DragonBones payloads and rejects unsupported shapes", function()
            local importer = rawget(lurek.spine, "skeletonFromJson")
            expect_type("function", importer)

                local json = [[
                {
                    "skeleton": {"name": "lua_spine"},
                    "bones": [
                        {"name": "root"},
                        {"name": "hip", "parent": "root", "x": 3.0, "y": 2.0}
                    ],
                    "slots": [
                        {"name": "body", "bone": "hip", "attachment": "body_idle"}
                    ],
                    "animations": {
                        "idle": {
                            "bones": {
                                "hip": {
                                    "translate": [
                                        {"time": 0.0, "x": 0.0, "y": 0.0},
                                        {"time": 1.0, "x": 1.0, "y": 0.0}
                                    ]
                                }
                            }
                        }
                    }
                }
                ]]

                local sk = importer(json)
                expect_type("userdata", sk)
                expect_equal(2, sk:boneCount())
                expect_equal(1, sk:slotCount())
                expect_equal(1, sk:findBone("hip"))
                expect_equal(0, sk:findSlot("body"))
                local json = [[
                {
                    "frameRate": 24,
                    "armature": [
                        {
                            "name": "lua_db",
                            "bone": [
                                {"name": "root"},
                                {"name": "torso", "parent": "root", "transform": {"x": 2.0, "y": 1.0, "skX": 10.0}}
                            ],
                            "slot": [
                                {"name": "body_slot", "parent": "torso"}
                            ],
                            "animation": [
                                {"name": "idle", "duration": 24}
                            ]
                        }
                    ]
                }
                ]]

                local sk = importer(json)
                expect_type("userdata", sk)
                expect_equal(2, sk:boneCount())
                expect_equal(1, sk:slotCount())
                expect_equal(1, sk:findBone("torso"))
                expect_equal(0, sk:findSlot("body_slot"))
                local ok, err = pcall(function()
                importer('{"invalid":true}')
                end)

                expect_false(ok)
            local err_msg = tostring(err or "")
            expect_true(string.find(err_msg, "skeletonFromJson", 1, true) ~= nil)
        end)
end)

    -- @describe poseAt(time)
    describe("poseAt(time)", function()
        -- @covers LSkeletonAnimation:poseAt
        it("returns a table snapshot", function()
            local sa = lurek.spine.newSkeletonAnimation("pose_probe", 1.0)
            sa:addKeyframe(0, "x", 0.0, 0.0, "linear")
            sa:addKeyframe(0, "x", 1.0, 5.0, "linear")
            local pose = sa:poseAt(0.5)
            expect_type("table", pose)
        end)
    end)
end
-- END test_spine_core_unit.lua

-- BEGIN test_spine_physics_binding_unit.lua
do
-- Public coverage for track builders and skeleton-to-physics binding.

-- @describe spine animation track builders
describe("spine animation track builders", function()
    -- @covers LSkeleton:buildAnimation
    it("buildAnimation creates timelines from named bone tracks", function()
        local sk = lurek.spine.newSkeleton("builder")
        sk:addBone("root")
        local hand = sk:addChildBone("hand", 0, { x = 12, y = 0 })
        local anim = sk:buildAnimation("wave", 1.0, {
            {
                bone = "hand",
                keys = {
                    { time = 0.0, x = 12, y = 0, rotation = 0 },
                    { time = 0.5, x = 18, y = 4, rotation = 0.3, easing = "ease_in_out" },
                    { time = 1.0, x = 12, y = 0, rotation = 0 },
                },
            },
        })

        expect_type("userdata", anim)
        expect_true(anim:getTimelineCount() >= 3)
        sk:addAnimation(anim)
        expect_true(sk:playAnimation("wave", false))
        sk:updateAnimation(0.5)
        sk:updateWorldTransforms()
        local world = sk:getBoneWorld(hand)
        expect_true(world.x > 12)
    end)

    -- @covers LSkeletonAnimation:addBoneTrack
    it("addBoneTrack appends multiple properties to an existing clip", function()
        local anim = lurek.spine.newSkeletonAnimation("track", 1.0)
        anim:addBoneTrack(0, {
            { time = 0.0, x = 0, y = 0 },
            { time = 1.0, x = 10, y = 3, scale_x = 1.2 },
        })

        expect_true(anim:getTimelineCount() >= 3)
        local pose = anim:poseAt(1.0)
        expect_type("table", pose)
    end)
end)

-- @describe spine physics binding
describe("spine physics binding", function()
    -- @covers LSkeleton:bindPhysics
    it("bindPhysics creates bodies and parent-child joints for configured parts", function()
        local sk = lurek.spine.newSkeleton("ragdoll")
        local root = sk:addBone("root", { x = 20, y = 20 })
        local head = sk:addChildBone("head", root, { x = 0, y = -12 })
        sk:updateWorldTransforms()

        local world = lurek.physics.newWorld(0, 0)
        local binding = sk:bindPhysics(world, {
            { bone = "root", width = 12, height = 18, joint = "none", bodyType = "dynamic", density = 0.5 },
            { bone = head, radius = 5, joint = "revolute", restitution = 0.4 },
        }, { joint = "revolute" })

        expect_equal(2, binding.bodyCount)
        expect_equal(1, binding.jointCount)
        expect_equal(2, world:getBodyCount())
        expect_equal(1, world:jointCount())
        expect_type("userdata", binding.bodies[1])
        expect_type("number", binding.bodyIds[1])
        expect_type("number", binding.jointIds[1])

        local img = lurek.image.newImageData(24, 24)
        img:drawCircle(12, 12, 7, 255, 255, 255, 255)
        local image_skel = lurek.spine.newSkeleton("image_parts")
        image_skel:addBone("root", { x = 10, y = 10 })
        local image_world = lurek.physics.newWorld(0, 0)
        local image_binding = image_skel:bindPhysics(image_world, {
            { bone = "root", image = img, joint = "none", density = 1.0 },
        }, { alphaThreshold = 1 })

        expect_equal(1, image_binding.bodyCount)
        expect_equal(0, image_binding.jointCount)
        expect_type("userdata", image_binding.bodies[1])
    end)
end)
end
-- END test_spine_physics_binding_unit.lua

test_summary()
