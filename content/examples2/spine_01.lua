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

print("spine_01.lua")
