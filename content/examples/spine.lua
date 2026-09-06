-- content/examples/spine.lua
-- Auto-generated from content/examples2/spine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/spine.lua

--- Spine Module: skeleton creation, bones, slots, IK, skins, animations, keyframes, events





--@api: lurek.spine.newSkeleton
do

    local skel = lurek.spine.newSkeleton("hero")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    local type_name = skel:type()
    local bones = skel:boneCount()
    local slots = skel:slotCount()
    lurek.log.info("newSkeleton type=" .. type_name .. " root=" .. tostring(root) .. " torso=" .. tostring(torso) .. " slot=" .. tostring(slot) .. " bones=" .. tostring(bones) .. " slots=" .. tostring(slots))
end

--@api: LSkeleton:applyLoadoutVisuals
do
    local slot = lurek.ecs.newSlotDef("weapon", { accepts = { "gun" } })
    local part = lurek.ecs.newPartDef({ id = "railgun", slot = "weapon", tags = { "gun" }, visuals = { weapon_slot = "railgun_attachment" } })
    local loadout = lurek.ecs.newLoadout({ slots = { slot } })
    loadout:equip(part)
    local skeleton = lurek.spine.newSkeleton("mech")
    local root = skeleton:addBone("root")
    skeleton:addSlot("weapon_slot", root, "empty")
    lurek.log.info("loadout visuals applied=" .. tostring(skeleton:applyLoadoutVisuals(loadout)))
end

--@api: LSkeleton:addBone
do

    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local chest = skel:addBone("chest", { x = 0, y = -12, rotation = 0.1 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    local bones = skel:boneCount()
    lurek.log.info("addBone root=" .. tostring(root) .. " chest=" .. tostring(chest) .. " bones=" .. tostring(bones) .. " world=" .. tostring(world and world.x) .. "," .. tostring(world and world.y))
end

--@api: LSkeleton:addChildBone
do

    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local spine_bone = skel:addChildBone("spine", root, { x = 0, y = -20 })
    local head = skel:addChildBone("head", spine_bone, { x = 0, y = -10 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(head)
    lurek.log.info("addChildBone root=" .. tostring(root) .. " spine=" .. tostring(spine_bone) .. " head=" .. tostring(head) .. " world_y=" .. tostring(world and world.y))
end

--@api: LSkeleton:addSlot
do

    local skel = lurek.spine.newSkeleton("slotted")
    local bone = skel:addBone("torso", { y = -10 })
    local body_slot = skel:addSlot("body_slot", bone, "body_image")
    local hand_slot = skel:addSlot("hand_slot", bone, "hand_image")
    local slot_count = skel:slotCount()
    local found = skel:findSlot("hand_slot")
    lurek.log.info("addSlot body=" .. tostring(body_slot) .. " hand=" .. tostring(hand_slot) .. " slots=" .. tostring(slot_count) .. " found=" .. tostring(found))
end

--@api: LSkeleton:addIKConstraint
do

    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    lurek.log.info("ik constraint id = " .. skel:addIKConstraint("arm_ik", { upper, lower }, true))
end

--@api: LSkeleton:setIKTarget
do

    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    skel:addIKConstraint("arm_ik", { upper, lower }, true)
    local ok = skel:setIKTarget("arm_ik", 60, -30)
    lurek.log.info("IK target set = " .. tostring(ok))
end

--@api: LSkeleton:addSkin
do

    local skel = lurek.spine.newSkeleton("skinned")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    skel:addSkin("default")
    skel:setSkinMapping("default", "torso_slot", "torso_idle")
    local activated = skel:setSkin("default")
    local skin = skel:getSkin()
    lurek.log.info("addSkin torso=" .. tostring(torso) .. " activated=" .. tostring(activated) .. " skin=" .. tostring(skin))
end

--@api: LSkeleton:setSkin
do

    local skel = lurek.spine.newSkeleton("skinned")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkinMapping("warrior", "torso_slot", "warrior_body")
    local switched = skel:setSkin("warrior")
    local current = skel:getSkin()
    lurek.log.info("setSkin switched=" .. tostring(switched) .. " current=" .. tostring(current) .. " slots=" .. tostring(skel:slotCount()))
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
    lurek.log.info("current skin = " .. tostring(skel:getSkin()))
end

--@api: LSkeleton:getSkin
do

    local skel = lurek.spine.newSkeleton("skinned")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkin("warrior")
    local current = skel:getSkin()
    local has_default = skel:setSkin("default")
    local restored = skel:getSkin()
    lurek.log.info("getSkin current=" .. tostring(current) .. " switched_default=" .. tostring(has_default) .. " restored=" .. tostring(restored))
end

--@api: LSkeleton:addAnimation
do

    local skel = lurek.spine.newSkeleton("animated")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    local idle = lurek.spine.newSkeletonAnimation("idle", 1.0)
    idle:addKeyframe(0, "x", 0.0, 0.0)
    idle:addKeyframe(0, "x", 1.0, 10.0)
    local timelines = idle:getTimelineCount()
    skel:addAnimation(idle)
    local started = skel:playAnimation("idle", true)
    local time = skel:getAnimationTime()
    lurek.log.info("addAnimation started=" .. tostring(started) .. " time=" .. tostring(time) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeleton:playAnimation
do

    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    local started = skel:playAnimation("idle", true)
    lurek.log.info("started = " .. tostring(started))
    lurek.log.info("time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:stopAnimation
do

    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    skel:stopAnimation()
    lurek.log.info("stopped at time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:getAnimationTime
do

    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    lurek.log.info("time = " .. string.format("%.1f", skel:getAnimationTime()))
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
    lurek.log.info("blended run")
end

--@api: LSkeleton:findBone
do

    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:addBone("arm", { x = 30, y = 0 })
    local arm = skel:findBone("arm")
    local missing = skel:findBone("leg")
    lurek.log.info("findBone arm=" .. tostring(arm) .. " missing=" .. tostring(missing) .. " bones=" .. tostring(skel:boneCount()))
end

--@api: LSkeleton:findSlot
do

    local skel = lurek.spine.newSkeleton("query")
    local arm = skel:addBone("arm", { x = 30, y = 0 })
    skel:addSlot("arm_slot", arm, "arm_img")
    local found = skel:findSlot("arm_slot")
    local missing = skel:findSlot("shield_slot")
    local slots = skel:slotCount()
    lurek.log.info("findSlot found=" .. tostring(found) .. " missing=" .. tostring(missing) .. " slots=" .. tostring(slots))
end

--@api: LSkeleton:setPosition
do

    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    skel:setPosition(200, 300)
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    local before = skel:getAnimationTime()
    lurek.log.info("setPosition root=" .. tostring(root) .. " world=" .. tostring(world and world.x) .. "," .. tostring(world and world.y) .. " time=" .. tostring(before))
end

--@api: LSkeleton:getBoneWorld
do

    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    lurek.log.info("root world = " .. string.format("%.0f, %.0f", world.x, world.y))
end

--@api: LSkeleton:updateWorldTransforms
do

    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    skel:setPosition(100, 200)
    skel:updateWorldTransforms()
    local root_world = skel:getBoneWorld(root)
    local torso_world = skel:getBoneWorld(torso)
    lurek.log.info("updateWorldTransforms root=" .. tostring(root_world and root_world.x) .. "," .. tostring(root_world and root_world.y) .. " torso=" .. tostring(torso_world and torso_world.x) .. "," .. tostring(torso_world and torso_world.y))
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
    lurek.log.info("frame loop time = " .. string.format("%.3f", skel:getAnimationTime()))
end

--@api: LSkeleton:drawToImage
do

    local skel = lurek.spine.newSkeleton("render_test")
    local root = skel:addBone("root", { x = 64, y = 64 })
    skel:addChildBone("body", root, { y = -20 })
    skel:updateWorldTransforms()
    local img = skel:drawToImage(128, 128)
    lurek.log.info("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: lurek.spine.newSkeletonAnimation
do

    local anim = lurek.spine.newSkeletonAnimation("walk_cycle", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 0.8, 12.0)
    local type_name = anim:type()
    local duration = anim:getDuration()
    local timelines = anim:getTimelineCount()
    lurek.log.info("newSkeletonAnimation type=" .. type_name .. " duration=" .. tostring(duration) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeletonAnimation:addKeyframe
do

    local anim = lurek.spine.newSkeletonAnimation("bob", 1.0)
    anim:addKeyframe(0, "y", 0.0, 0)
    anim:addKeyframe(0, "y", 1.0, 0, "ease_in")
    anim:addKeyframe(0, "rotation", 0.5, 12, "linear")
    local pose = anim:poseAt(0.5)
    local timelines = anim:getTimelineCount()
    lurek.log.info("addKeyframe timelines=" .. tostring(timelines) .. " pose_entries=" .. tostring(#pose))
end

--@api: LSkeletonAnimation:addEventKey
do

    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    anim:addEventKey(0.45, "recover", 3)
    local events = anim:getEvents(0.0, 0.5)
    local partial = anim:getEvents(0.25, 0.5)
    lurek.log.info("addEventKey events=" .. tostring(#events) .. " partial=" .. tostring(#partial))
end

--@api: LSkeletonAnimation:getEvents
do

    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    anim:addEventKey(0.45, "recover", 3)
    local partial = anim:getEvents(0.15, 0.35)
    local later = anim:getEvents(0.35, 0.5)
    local first = partial[1] and partial[1].name or "none"
    lurek.log.info("getEvents partial=" .. tostring(#partial) .. " later=" .. tostring(#later) .. " first=" .. first)
end

--@api: LSkeletonAnimation:reverse
do

    local anim = lurek.spine.newSkeletonAnimation("swing", 0.6)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.6, 0)
    local reversed = anim:reverse()
    lurek.log.info("reversed duration = " .. reversed:getDuration())
end

--@api: lurek.spine.animationFromJson
do

    local jsonData = '{"name":"idle_bounce","duration":1.2,"timelines":[{"bone":0,"property":"y","keys":[{"time":0,"value":0},{"time":1.2,"value":0}]}]}'
    local anim = lurek.spine.animationFromJson(jsonData)
    local timelines = anim and anim:getTimelineCount() or -1
    local duration = anim and anim:getDuration() or -1
    local reversed = anim and anim:reverse() or nil
    local reversed_duration = reversed and reversed:getDuration() or -1
    lurek.log.info("animationFromJson timelines=" .. tostring(timelines) .. " duration=" .. tostring(duration) .. " reversed=" .. tostring(reversed_duration))
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
    ]
}
]]
local imported = lurek.spine.skeletonFromJson(jsonData)
lurek.log.info("skeletonFromJson bones=" .. tostring(imported:boneCount()) .. " slots=" .. tostring(imported:slotCount()))
end

--- Spine Module Part 1: LSkeleton, LSkeletonAnimation, animationFromJson, newSkeleton, newSkeletonAnimation

--@api: LSkeleton:boneCount
do

    local skel = lurek.spine.newSkeleton("hero")
    skel:addBone("root", {})
    skel:addBone("arm", {})
    local bones = skel:boneCount()
    local arm = skel:findBone("arm")
    local root = skel:findBone("root")
    lurek.log.info("boneCount bones=" .. tostring(bones) .. " root=" .. tostring(root) .. " arm=" .. tostring(arm))
end

--@api: LSkeleton:slotCount
do

    local skel = lurek.spine.newSkeleton("hero")
    local arm = skel:addBone("arm", {})
    skel:addSlot("arm_slot", arm, nil)
    skel:addSlot("weapon_slot", arm, "sword")
    local slots = skel:slotCount()
    local found = skel:findSlot("weapon_slot")
    lurek.log.info("slotCount slots=" .. tostring(slots) .. " weapon=" .. tostring(found))
end

--@api: LSkeleton:type
do

    local skel = lurek.spine.newSkeleton("hero")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    local type_name = skel:type()
    local is_skeleton = skel:typeOf("LSkeleton")
    local bones = skel:boneCount()
    lurek.log.info("LSkeleton:type name=" .. type_name .. " is_skeleton=" .. tostring(is_skeleton) .. " bones=" .. tostring(bones))
end

--@api: LSkeleton:typeOf
do

    local skel = lurek.spine.newSkeleton("hero")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    local is_skeleton = skel:typeOf("LSkeleton")
    local is_object = skel:typeOf("Object")
    local is_anim = skel:typeOf("LSkeletonAnimation")
    lurek.log.info("LSkeleton:typeOf skeleton=" .. tostring(is_skeleton) .. " object=" .. tostring(is_object) .. " anim=" .. tostring(is_anim))
end

--@api: LSkeletonAnimation:getDuration
do

    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 0.8, 12.0)
    local duration = anim:getDuration()
    local timelines = anim:getTimelineCount()
    lurek.log.info("getDuration duration=" .. tostring(duration) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeletonAnimation:getTimelineCount
do

    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    anim:addKeyframe(0, "rotation", 0.8, 15.0, "ease_in_out")
    local timelines = anim:getTimelineCount()
    local pose = anim:poseAt(0.4)
    lurek.log.info("getTimelineCount timelines=" .. tostring(timelines) .. " pose=" .. tostring(#pose))
end

--@api: LSkeletonAnimation:poseAt
do

    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    anim:addKeyframe(0, "rotation", 0.8, 15.0, "linear")
    local pose = anim:poseAt(0.3)
    local first = pose[1]
    local property = first and first.property or "none"
    local value = first and first.value or -1
    lurek.log.info("poseAt entries=" .. tostring(#pose) .. " property=" .. property .. " value=" .. tostring(value))
end

--@api: LSkeletonAnimation:type
do

    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    local type_name = anim:type()
    local is_anim = anim:typeOf("LSkeletonAnimation")
    local timelines = anim:getTimelineCount()
    lurek.log.info("LSkeletonAnimation:type name=" .. type_name .. " is_anim=" .. tostring(is_anim) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeletonAnimation:typeOf
do

    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    local is_anim = anim:typeOf("LSkeletonAnimation")
    local is_object = anim:typeOf("Object")
    local is_skeleton = anim:typeOf("LSkeleton")
    anim:addEventKey(0.2, "step", 1)
    lurek.log.info("LSkeletonAnimation:typeOf anim=" .. tostring(is_anim) .. " object=" .. tostring(is_object) .. " skeleton=" .. tostring(is_skeleton))
end
--@api: LSkeleton:buildAnimation
do
    local skel = lurek.spine.newSkeleton("builder_example")
    local root = skel:addBone("root", { x = 0, y = 0 })
    local hand = skel:addChildBone("hand", root, { x = 12, y = 0 })
    local anim = skel:buildAnimation("wave", 1.0, {
        { bone = "hand", keys = {
            { time = 0.0, x = 12, y = 0, rotation = 0.0 },
            { time = 0.5, x = 18, y = 4, rotation = 0.35, easing = "ease_in_out" },
            { time = 1.0, x = 12, y = 0, rotation = 0.0 },
        } },
    })
    local timeline_count = anim:getTimelineCount()
    skel:addAnimation(anim)
    skel:playAnimation("wave", true)
    lurek.log.info("[spine] buildAnimation bone=" .. tostring(hand) .. " timelines=" .. tostring(timeline_count))
end

--@api: LSkeleton:bindPhysics
do
    local skel = lurek.spine.newSkeleton("physics_example")
    local root = skel:addBone("root", { x = 32, y = 48 })
    local head = skel:addChildBone("head", root, { x = 0, y = -16 })
    skel:updateWorldTransforms()
    local world = lurek.physics.newWorld(0, 0)
    local binding = skel:bindPhysics(world, {
        { bone = root, width = 14, height = 20, joint = "none", density = 0.5 },
        { bone = head, radius = 6, joint = "revolute", restitution = 0.4 },
    }, { joint = "revolute" })
    world:step(1 / 60)
    lurek.log.info("[spine] bound bodies=" .. tostring(binding.bodyCount) .. " joints=" .. tostring(binding.jointCount))
end

--@api: LSkeletonAnimation:addBoneTrack
do
    local anim = lurek.spine.newSkeletonAnimation("track_example", 1.0)
    anim:addBoneTrack(0, {
        { time = 0.0, x = 0, y = 0, scale_x = 1.0 },
        { time = 0.5, x = 8, y = -2, scale_x = 1.1, easing = "ease_out" },
        { time = 1.0, x = 0, y = 0, scale_x = 1.0 },
    })
    local pose = anim:poseAt(0.5)
    local duration = anim:getDuration()
    lurek.log.info("[spine] addBoneTrack duration=" .. tostring(duration) .. " pose entries=" .. tostring(#pose))
end
--@api: LSkeleton:bindAtlas
do
    local skeleton = lurek.spine.newSkeleton("atlas_sources")
    skeleton:addBone("root")
    skeleton:addSlot("head_slot", 0, "head")
    local atlas = lurek.sprite.parseAtlas('{"frames":{"head":{"frame":{"x":0,"y":0,"w":16,"h":16},"rotated":false}}}')
    local count = skeleton:bindAtlas(atlas)
    lurek.log.info("[spine] bound atlas sources=" .. tostring(count))
end

--@api: LSkeleton:setAttachmentSource
do
    local skeleton = lurek.spine.newSkeleton("manual_sources")
    skeleton:addBone("root")
    skeleton:addSlot("body", 0, "body")
    skeleton:setAttachmentSource("body", { kind = "imageRegion", name = "body", x = 0, y = 0, w = 16, h = 16 })
    local source = skeleton:getAttachmentSource("body")
    lurek.log.info("[spine] source kind=" .. tostring(source.kind))
end

--@api: LSkeleton:getAttachmentSource
do
    local skeleton = lurek.spine.newSkeleton("source_lookup")
    skeleton:addBone("root")
    skeleton:addSlot("hand", 0, "hand")
    skeleton:setAttachmentSource("hand", { kind = "spriteRegion", name = "hand", x = 4, y = 4, w = 8, h = 8 })
    local source = skeleton:getAttachmentSource("hand")
    lurek.log.info("[spine] source width=" .. tostring(source.w))
end
