-- content/examples/spine.lua
-- Auto-generated from content/examples2/spine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/spine.lua

--- Spine Module: skeleton creation, bones, slots, IK, skins, animations, keyframes, events

--@api-stub: lurek.spine.newSkeleton
-- Creating a basic skeleton.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("hero")
    print("type = " .. skel:type())
    print("is LSkeleton = " .. tostring(skel:typeOf("LSkeleton")))
    print("bone count = " .. skel:boneCount())
    print("slot count = " .. skel:slotCount())
end

--@api-stub: LSkeleton:addBone
--@api-stub: LSkeleton:addChildBone
-- Building a bone hierarchy with opts table.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    print("root bone index = " .. root)
    local spine_bone = skel:addChildBone("spine", root, { x = 0, y = -20 })
    print("spine bone index = " .. spine_bone)
    local head = skel:addChildBone("head", spine_bone, { x = 0, y = -30 })
    print("head bone index = " .. head)
    local leftArm = skel:addChildBone("left_arm", spine_bone, { x = -15, y = -10 })
    local rightArm = skel:addChildBone("right_arm", spine_bone, { x = 15, y = -10 })
    print("left arm = " .. leftArm .. " right arm = " .. rightArm)
    local leftLeg = skel:addChildBone("left_leg", root, { x = -8, y = 20 })
    local rightLeg = skel:addChildBone("right_leg", root, { x = 8, y = 20 })
    print("bone count = " .. skel:boneCount())
end

-- Bones with no opts use defaults.
--@api-stub: lurek.spine.newSkeleton
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("minimal")
    local root = skel:addBone("root")
    print("root (no opts) = " .. root)
    local child = skel:addChildBone("child", root)
    print("child (no opts) = " .. child)
    print("bone count = " .. skel:boneCount())
end

--@api-stub: LSkeleton:addSlot
-- Attaching visual slots to bones.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("slotted")
    local root = skel:addBone("root")
    local torso = skel:addChildBone("torso", root, { y = -10 })
    local head = skel:addChildBone("head", torso, { y = -25 })
    local slotBody = skel:addSlot("body_slot", torso, "body_image")
    print("body slot = " .. slotBody)
    local slotHead = skel:addSlot("head_slot", head, "head_image")
    print("head slot = " .. slotHead)
    local slotWeapon = skel:addSlot("weapon_slot", torso, "sword_image")
    print("weapon slot = " .. slotWeapon)
    print("slot count = " .. skel:slotCount())
end

--@api-stub: LSkeleton:addIKConstraint
--@api-stub: LSkeleton:setIKTarget
-- Inverse kinematics setup.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upperArm = skel:addChildBone("upper_arm", root, { x = 20 })
    local lowerArm = skel:addChildBone("lower_arm", upperArm, { x = 20 })
    local hand = skel:addChildBone("hand", lowerArm, { x = 15 })
    local ikId = skel:addIKConstraint("arm_ik", { upperArm, lowerArm, hand }, true)
    print("ik constraint id = " .. ikId)
    skel:setIKTarget("arm_ik", 60, -30)
    print("IK target set")
    skel:updateWorldTransforms()
    local result = skel:getBoneWorld(hand)
    print("hand world pos = " .. string.format("%.1f, %.1f", result.x, result.y))
end

--@api-stub: LSkeleton:addSkin
--@api-stub: LSkeleton:setSkin
--@api-stub: LSkeleton:setSkinMapping
--@api-stub: LSkeleton:getSkin
-- Skin management for character variants.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("skinned")
    local root = skel:addBone("root")
    local body = skel:addChildBone("body", root)
    skel:addSlot("body_slot", body, "default_body")
    skel:addSlot("armor_slot", body, "no_armor")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:addSkin("mage")
    skel:setSkinMapping("warrior", "body_slot", "warrior_body")
    skel:setSkinMapping("warrior", "armor_slot", "plate_armor")
    skel:setSkinMapping("mage", "body_slot", "mage_body")
    skel:setSkinMapping("mage", "armor_slot", "mage_robe")
    skel:setSkin("warrior")
    print("current skin = " .. skel:getSkin())
    skel:setSkin("mage")
    print("current skin = " .. skel:getSkin())
    skel:setSkin("default")
    print("current skin = " .. skel:getSkin())
end

--@api-stub: LSkeleton:addAnimation
--@api-stub: LSkeleton:playAnimation
--@api-stub: LSkeleton:stopAnimation
--@api-stub: LSkeleton:updateAnimation
--@api-stub: LSkeleton:getAnimationTime
-- Registering and playing skeleton animations.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("animated")
    local root = skel:addBone("root")
    ---@type LSkeletonAnimation
    local idleAnim = lurek.spine.newSkeletonAnimation("idle", 1.0)
    idleAnim:addKeyframe(0, "y", 0.0, 0)
    idleAnim:addKeyframe(0, "y", 0.5, -3, "ease_in_out")
    idleAnim:addKeyframe(0, "y", 1.0, 0, "ease_in_out")
    ---@type LSkeletonAnimation
    local walkAnim = lurek.spine.newSkeletonAnimation("walk", 0.6)
    walkAnim:addKeyframe(0, "x", 0.0, 0)
    walkAnim:addKeyframe(0, "x", 0.3, 5)
    walkAnim:addKeyframe(0, "x", 0.6, 0)
    skel:addAnimation(idleAnim)
    skel:addAnimation(walkAnim)
    skel:playAnimation("idle", true)
    print("playing idle, time = " .. skel:getAnimationTime())
    skel:updateAnimation(0.5)
    print("after 0.5s time = " .. string.format("%.1f", skel:getAnimationTime()))
    skel:playAnimation("walk")
    skel:updateAnimation(0.3)
    print("walk time = " .. string.format("%.1f", skel:getAnimationTime()))
    skel:stopAnimation()
    skel:updateAnimation(0.1)
    print("stopped time = " .. string.format("%.1f", skel:getAnimationTime()))
end

--@api-stub: LSkeleton:blendAnimation
-- Blending animation onto current pose.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("blending")
    local root = skel:addBone("root")
    ---@type LSkeletonAnimation
    local idleAnim = lurek.spine.newSkeletonAnimation("idle", 1.0)
    idleAnim:addKeyframe(0, "y", 0.0, 0)
    idleAnim:addKeyframe(0, "y", 1.0, -5)
    ---@type LSkeletonAnimation
    local runAnim = lurek.spine.newSkeletonAnimation("run", 0.5)
    runAnim:addKeyframe(0, "x", 0.0, 0)
    runAnim:addKeyframe(0, "x", 0.5, 10)
    skel:addAnimation(idleAnim)
    skel:addAnimation(runAnim)
    skel:playAnimation("idle", true)
    skel:updateAnimation(0.2)
    skel:blendAnimation(runAnim, 0.25, 0.5)
    print("blended run at 50% weight")
    skel:blendAnimation(runAnim, 0.25, 1.0)
    print("blended run at 100% weight")
end

--@api-stub: LSkeleton:findBone
--@api-stub: LSkeleton:findSlot
--@api-stub: LSkeleton:setPosition
--@api-stub: LSkeleton:getBoneWorld
--@api-stub: LSkeleton:updateWorldTransforms
-- Querying and positioning.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 100, y = 200 })
    local arm = skel:addChildBone("arm", root, { x = 30, y = 0 })
    skel:addSlot("arm_slot", arm, "arm_img")
    local foundBone = skel:findBone("arm")
    print("found arm = " .. foundBone)
    local foundSlot = skel:findSlot("arm_slot")
    print("found arm_slot = " .. foundSlot)
    skel:setPosition(200, 300)
    skel:updateWorldTransforms()
    local rootWorld = skel:getBoneWorld(root)
    print("root world = " .. string.format("%.0f, %.0f", rootWorld.x, rootWorld.y))
    local armWorld = skel:getBoneWorld(arm)
    print("arm world = " .. string.format("%.0f, %.0f", armWorld.x, armWorld.y))
end

--@api-stub: LSkeleton:drawToImage
-- Rendering the skeleton to an image.
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("render_test")
    local root = skel:addBone("root", { x = 64, y = 64 })
    skel:addChildBone("body", root, { y = -20 })
    skel:updateWorldTransforms()
    local img = skel:drawToImage(128, 128)
    print("rendered image type = " .. type(img))
    print("image width = " .. img:getWidth())
    print("image height = " .. img:getHeight())
end

--@api-stub: lurek.spine.newSkeletonAnimation
-- Creating animation timelines manually.
do
    ---@type LSkeletonAnimation
    local anim = lurek.spine.newSkeletonAnimation("walk_cycle", 0.8)
    print("type = " .. anim:type())
    print("is LSkeletonAnimation = " .. tostring(anim:typeOf("LSkeletonAnimation")))
    print("duration = " .. anim:getDuration())
    print("timeline count = " .. anim:getTimelineCount())
end

--@api-stub: LSkeletonAnimation:addKeyframe
-- Building keyframe timelines.
do
    ---@type LSkeletonAnimation
    local anim = lurek.spine.newSkeletonAnimation("bob", 1.0)
    anim:addKeyframe(0, "y", 0.0, 0)
    anim:addKeyframe(0, "y", 0.25, -5, "ease_out")
    anim:addKeyframe(0, "y", 0.5, 0, "ease_in")
    anim:addKeyframe(0, "y", 0.75, -5, "ease_out")
    anim:addKeyframe(0, "y", 1.0, 0, "ease_in")
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.5, 5)
    anim:addKeyframe(0, "rotation", 1.0, 0)
    print("timeline count = " .. anim:getTimelineCount())
    local pose = anim:poseAt(0.25)
    print("pose at 0.25 type = " .. type(pose))
end

--@api-stub: LSkeletonAnimation:addEventKey
--@api-stub: LSkeletonAnimation:getEvents
-- Animation events for sound/effect triggers.
do
    ---@type LSkeletonAnimation
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.2, -45)
    anim:addKeyframe(0, "rotation", 0.4, 30)
    anim:addKeyframe(0, "rotation", 0.5, 0)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    anim:addEventKey(0.5, "recover")
    local events = anim:getEvents(0.0, 0.5)
    print("events in range = " .. #events)
    for _, ev in ipairs(events) do
        print("  name=" .. ev.name .. " value=" .. tostring(ev.value))
    end
    local partial = anim:getEvents(0.15, 0.35)
    print("events 0.15-0.35 = " .. #partial)
end

--@api-stub: LSkeletonAnimation:reverse
-- Reversing an animation.
do
    ---@type LSkeletonAnimation
    local anim = lurek.spine.newSkeletonAnimation("swing", 0.6)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.3, 90)
    anim:addKeyframe(0, "rotation", 0.6, 0)
    anim:addEventKey(0.3, "peak")
    local reversed = anim:reverse()
    print("reversed duration = " .. reversed:getDuration())
    print("reversed timelines = " .. reversed:getTimelineCount())
end

--@api-stub: lurek.spine.animationFromJson
-- Loading animation from JSON data.
do
    local jsonData = lurek.serial.toJson({
        name = "idle_bounce",
        duration = 1.2,
        timelines = {
            { bone = 0, property = "y", keys = {
                { time = 0, value = 0 },
                { time = 0.6, value = -3 },
                { time = 1.2, value = 0 },
            }},
        },
    })
    ---@type LSkeletonAnimation
    local anim = lurek.spine.animationFromJson(jsonData)
    print("loaded type = " .. anim:type())
    print("duration = " .. anim:getDuration())
    print("timelines = " .. anim:getTimelineCount())
end

-- Complete skeleton with bones, slots, skins, IK, and animation.
--@api-stub: lurek.spine.newSkeleton
--@api-stub: lurek.spine.newSkeletonAnimation
do
    ---@type LSkeleton
    local skel = lurek.spine.newSkeleton("full_character")
    local root = skel:addBone("root", { x = 200, y = 400 })
    local hip = skel:addChildBone("hip", root)
    local torso = skel:addChildBone("torso", hip, { y = -30 })
    local head = skel:addChildBone("head", torso, { y = -25 })
    local lArm = skel:addChildBone("l_arm", torso, { x = -15, y = -5 })
    local rArm = skel:addChildBone("r_arm", torso, { x = 15, y = -5 })
    local lLeg = skel:addChildBone("l_leg", hip, { x = -8, y = 25 })
    local rLeg = skel:addChildBone("r_leg", hip, { x = 8, y = 25 })
    skel:addSlot("torso_slot", torso, "torso_default")
    skel:addSlot("head_slot", head, "head_default")
    skel:addSlot("l_arm_slot", lArm, "arm_default")
    skel:addSlot("r_arm_slot", rArm, "arm_default")
    skel:addSlot("l_leg_slot", lLeg, "leg_default")
    skel:addSlot("r_leg_slot", rLeg, "leg_default")
    skel:addSkin("default")
    skel:addSkin("armored")
    skel:setSkinMapping("armored", "torso_slot", "plate_torso")
    skel:setSkinMapping("armored", "head_slot", "helmet")
    skel:addIKConstraint("l_arm_ik", { lArm })
    skel:addIKConstraint("r_arm_ik", { rArm })
    ---@type LSkeletonAnimation
    local idleAnim = lurek.spine.newSkeletonAnimation("idle", 1.0)
    idleAnim:addKeyframe(0, "y", 0.0, 0)
    idleAnim:addKeyframe(0, "y", 0.5, -3)
    idleAnim:addKeyframe(0, "y", 1.0, 0)
    skel:addAnimation(idleAnim)
    skel:setSkin("armored")
    skel:playAnimation("idle", true)
    print("full character:")
    print("  bones = " .. skel:boneCount())
    print("  slots = " .. skel:slotCount())
    print("  skin = " .. skel:getSkin())
    for i = 1, 10 do
        skel:updateAnimation(1 / 60)
        skel:updateWorldTransforms()
    end
    print("  after 10 frames, time = " .. string.format("%.3f", skel:getAnimationTime()))
    local headWorld = skel:getBoneWorld(head)
    print("  head pos = " .. string.format("%.1f, %.1f", headWorld.x, headWorld.y))
end

--- Spine Module Part 1: LSkeleton, LSkeletonAnimation, animationFromJson, newSkeleton, newSkeletonAnimation

--@api-stub: LSkeleton:boneCount
--@api-stub: LSkeleton:slotCount
--@api-stub: LSkeleton:type
--@api-stub: LSkeleton:typeOf
-- Skeleton lifecycle, bones, skins, slots, animations, and type introspection.
do
    local skel = lurek.spine.newSkeleton("hero")
    local b0 = skel:addBone("root", {})
    local b1 = skel:addChildBone("arm", b0, {})
    skel:addSkin("default")
    skel:addSlot("arm_slot", b1, nil)
    skel:addIKConstraint("arm_ik", { b0, b1 }, true)

    local anim = lurek.spine.newSkeletonAnimation("walk", 1.0)
    skel:addAnimation(anim)

    skel:setSkin("default")
    print("skin=" .. skel:getSkin())
    print("bones=" .. skel:boneCount())
    print("slots=" .. skel:slotCount())

    local idx = skel:findBone("root")
    print("root_idx=" .. idx)
    local slot_idx = skel:findSlot("arm_slot")
    print("slot_idx=" .. slot_idx)

    skel:setPosition(100, 200)
    skel:setIKTarget("arm_ik", 120, 180)
    skel:playAnimation("walk", true)
    print("anim_time=" .. skel:getAnimationTime())
    local wx, wy = skel:getBoneWorld(b0)
    print("world=" .. wx .. "," .. wy)
    skel:blendAnimation(anim, 0.5, 1.0)
    skel:stopAnimation()

    local img = skel:drawToImage(128, 128)
    print("img=" .. tostring(img ~= nil))

    skel:setSkinMapping("default", "arm_slot", "arm_attachment")
    print("type=" .. skel:type())
    print("typeOf=" .. tostring(skel:typeOf("LSkeleton")))
end

--@api-stub: LSkeletonAnimation:getDuration
--@api-stub: LSkeletonAnimation:getTimelineCount
--@api-stub: LSkeletonAnimation:poseAt
--@api-stub: LSkeletonAnimation:type
--@api-stub: LSkeletonAnimation:typeOf
-- Skeleton animation keyframe API and type introspection.
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    anim:addKeyframe(0, "rotation", 0.4, 45.0, "linear")
    anim:addKeyframe(0, "rotation", 0.8, 0.0, "linear")
    anim:addEventKey(0.2, "foot_left", 1)
    anim:addEventKey(0.6, "foot_right", 1)

    print("duration=" .. anim:getDuration())
    print("timelines=" .. anim:getTimelineCount())

    local events = anim:getEvents(0.0, 1.0)
    print("events=" .. #events)

    anim:poseAt(0.3)
    anim:reverse()

    print("type=" .. anim:type())
    print("typeOf=" .. tostring(anim:typeOf("LSkeletonAnimation")))
end

print("content/examples/spine.lua")
