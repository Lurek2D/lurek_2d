-- content/examples/spine.lua
-- Auto-generated from content/examples2/spine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/spine.lua

--- Spine Module: skeleton creation, bones, slots, IK, skins, animations, keyframes, events

--@api: lurek.spine.newSkeleton
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("hero")
    print("type = " .. skel:type())
    print("bone count = " .. skel:boneCount())
    print("slot count = " .. skel:slotCount())
end

--@api: LSkeleton:addBone
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    print("root bone index = " .. root)
end

--@api: LSkeleton:addChildBone
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local spine_bone = skel:addChildBone("spine", root, { x = 0, y = -20 })
    print("spine bone index = " .. spine_bone)
end

--@api: LSkeleton:addSlot
do
    local skel = lurek.spine.newSkeleton("slotted")
    local bone = skel:addBone("torso", { y = -10 })
    print("body slot = " .. skel:addSlot("body_slot", bone, "body_image"))
    print("slot count = " .. skel:slotCount())
end

--@api: LSkeleton:addIKConstraint
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    print("ik constraint id = " .. skel:addIKConstraint("arm_ik", { upper, lower }, true))
end

--@api: LSkeleton:setIKTarget
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    skel:addIKConstraint("arm_ik", { upper, lower }, true)
    local ok = skel:setIKTarget("arm_ik", 60, -30)
    print("IK target set = " .. tostring(ok))
end

--@api: LSkeleton:addSkin
do
    local skel = lurek.spine.newSkeleton("skinned")
    skel:addBone("root")
    skel:addSkin("default")
    print("skin added")
end

--@api: LSkeleton:setSkin
do
    local skel = lurek.spine.newSkeleton("skinned")
    skel:addSkin("default")
    skel:setSkin("default")
    print("current skin = " .. skel:getSkin())
end

--@api: LSkeleton:setSkinMapping
do
    local skel = lurek.spine.newSkeleton("skinned")
    local body = skel:addBone("body")
    skel:addSlot("body_slot", body, "default_body")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkinMapping("warrior", "body_slot", "warrior_body")
    skel:setSkin("warrior")
    print("current skin = " .. tostring(skel:getSkin()))
end

--@api: LSkeleton:getSkin
do
    local skel = lurek.spine.newSkeleton("skinned")
    skel:addSkin("warrior")
    skel:setSkin("warrior")
    print("current skin = " .. skel:getSkin())
end

--@api: LSkeleton:addAnimation
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    print("animation time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:playAnimation
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    local started = skel:playAnimation("idle", true)
    print("started = " .. tostring(started))
    print("time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:stopAnimation
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    skel:stopAnimation()
    print("stopped at time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:getAnimationTime
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    print("time = " .. string.format("%.1f", skel:getAnimationTime()))
end

--@api: LSkeleton:blendAnimation
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    local run = lurek.spine.newSkeletonAnimation("run", 0.5)
    run:addKeyframe(0, "x", 0.0, 0)
    run:addKeyframe(0, "x", 0.5, 10)
    skel:updateAnimation(0.2)
    skel:blendAnimation(run, 0.25, 0.5)
    print("blended run")
end

--@api: LSkeleton:findBone
do
    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:addBone("arm", { x = 30, y = 0 })
    print("found arm = " .. skel:findBone("arm"))
end

--@api: LSkeleton:findSlot
do
    local skel = lurek.spine.newSkeleton("query")
    local arm = skel:addBone("arm", { x = 30, y = 0 })
    skel:addSlot("arm_slot", arm, "arm_img")
    print("found slot = " .. skel:findSlot("arm_slot"))
end

--@api: LSkeleton:setPosition
do
    local skel = lurek.spine.newSkeleton("query")
    skel:setPosition(200, 300)
    print("position set")
end

--@api: LSkeleton:getBoneWorld
do
    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    print("root world = " .. string.format("%.0f, %.0f", world.x, world.y))
end

--@api: LSkeleton:updateWorldTransforms
do
    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    print("world transforms updated")
end

--@api: LSkeleton:updateAnimation
do
    local skel = lurek.spine.newSkeleton("frame_loop")
    skel:addBone("root")
    local anim = lurek.spine.newSkeletonAnimation("walk", 1.0)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 1.0, 10.0)
    skel:addAnimation(anim)
    skel:playAnimation("walk", true)
    for _ = 1, 60 do
        skel:updateAnimation(1.0 / 60.0)
        skel:updateWorldTransforms()
    end
    print("frame loop time = " .. string.format("%.3f", skel:getAnimationTime()))
end

--@api: LSkeleton:drawToImage
do
    local skel = lurek.spine.newSkeleton("render_test")
    local root = skel:addBone("root", { x = 64, y = 64 })
    skel:addChildBone("body", root, { y = -20 })
    skel:updateWorldTransforms()
    local img = skel:drawToImage(128, 128)
    print("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: lurek.spine.newSkeletonAnimation
do
    local anim = lurek.spine.newSkeletonAnimation("walk_cycle", 0.8)
    print("type = " .. anim:type())
    print("duration = " .. anim:getDuration())
    print("timelines = " .. anim:getTimelineCount())
end

--@api: LSkeletonAnimation:addKeyframe
do
    local anim = lurek.spine.newSkeletonAnimation("bob", 1.0)
    anim:addKeyframe(0, "y", 0.0, 0)
    anim:addKeyframe(0, "y", 1.0, 0, "ease_in")
    print("timeline count = " .. anim:getTimelineCount())
end

--@api: LSkeletonAnimation:addEventKey
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    print("events = " .. #anim:getEvents(0.0, 0.5))
end

--@api: LSkeletonAnimation:getEvents
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    print("partial events = " .. #anim:getEvents(0.15, 0.35))
end

--@api: LSkeletonAnimation:reverse
do
    local anim = lurek.spine.newSkeletonAnimation("swing", 0.6)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.6, 0)
    local reversed = anim:reverse()
    print("reversed duration = " .. reversed:getDuration())
end

--@api: lurek.spine.animationFromJson
do
    local jsonData = '{"name":"idle_bounce","duration":1.2,"timelines":[{"bone":0,"property":"y","keys":[{"time":0,"value":0},{"time":1.2,"value":0}]}]}'
    local anim = lurek.spine.animationFromJson(jsonData)
    print("timelines = " .. (anim and tostring(anim:getTimelineCount()) or "nil"))
end

--@api: lurek.spine.skeletonFromJson
do
        local jsonData = [[
        {
            "skeleton": {"name": "example_import"},
            "bones": [
                {"name": "root"},
                {"name": "torso", "parent": "root", "x": 4.0, "y": -6.0}
            ],
            "slots": [
                {"name": "body", "bone": "torso", "attachment": "body_idle"}
            ],
            "animations": {
                "idle": {
                    "bones": {
                        "torso": {
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
        local importer = rawget(lurek.spine, "skeletonFromJson")
        local imported = importer and importer(jsonData)
        print("imported bones = " .. imported:boneCount())
        print("imported slots = " .. imported:slotCount())
end

--- Spine Module Part 1: LSkeleton, LSkeletonAnimation, animationFromJson, newSkeleton, newSkeletonAnimation

--@api: LSkeleton:boneCount
do
    local skel = lurek.spine.newSkeleton("hero")
    skel:addBone("root", {})
    skel:addBone("arm", {})
    print("bones = " .. skel:boneCount())
end

--@api: LSkeleton:slotCount
do
    local skel = lurek.spine.newSkeleton("hero")
    local arm = skel:addBone("arm", {})
    skel:addSlot("arm_slot", arm, nil)
    print("slots = " .. skel:slotCount())
end

--@api: LSkeleton:type
do
    local skel = lurek.spine.newSkeleton("hero")
    print("type = " .. skel:type())
end

--@api: LSkeleton:typeOf
do
    local skel = lurek.spine.newSkeleton("hero")
    print("is LSkeleton = " .. tostring(skel:typeOf("LSkeleton")))
end

--@api: LSkeletonAnimation:getDuration
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    print("duration=" .. anim:getDuration())
end

--@api: LSkeletonAnimation:getTimelineCount
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    print("timelines=" .. anim:getTimelineCount())
end

--@api: LSkeletonAnimation:poseAt
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    local pose = anim:poseAt(0.3)
    print("pose type=" .. type(pose))
end

--@api: LSkeletonAnimation:type
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    print("type=" .. anim:type())
end

--@api: LSkeletonAnimation:typeOf
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    print("typeOf=" .. tostring(anim:typeOf("LSkeletonAnimation")))
end
