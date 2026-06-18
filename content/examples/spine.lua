-- content/examples/spine.lua
-- Auto-generated from content/examples2/spine_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/spine.lua

--- Spine Module: skeleton creation, bones, slots, IK, skins, animations, keyframes, events

local function spine_log(message)
    lurek.log.info("[spine] " .. message)
end

local function make_demo_skeleton(name)
    local skel = lurek.spine.newSkeleton(name)
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local torso = skel:addChildBone("torso", root, { x = 0, y = -12 })
    local slot = skel:addSlot("torso_slot", torso, "torso_idle")
    return skel, root, torso, slot
end

local function make_walk_animation(name, duration)
    local anim = lurek.spine.newSkeletonAnimation(name or "walk", duration or 1.0)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", duration or 1.0, 10.0)
    return anim
end

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.spine.newSkeleton
do
    local skel, root, torso, slot = make_demo_skeleton("hero")
    local type_name = skel:type()
    local bones = skel:boneCount()
    local slots = skel:slotCount()
    spine_log("newSkeleton type=" .. type_name .. " root=" .. tostring(root) .. " torso=" .. tostring(torso) .. " slot=" .. tostring(slot) .. " bones=" .. tostring(bones) .. " slots=" .. tostring(slots))
end

--@api: LSkeleton:addBone
do
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local chest = skel:addBone("chest", { x = 0, y = -12, rotation = 0.1 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    local bones = skel:boneCount()
    spine_log("addBone root=" .. tostring(root) .. " chest=" .. tostring(chest) .. " bones=" .. tostring(bones) .. " world=" .. tostring(world and world.x) .. "," .. tostring(world and world.y))
end

--@api: LSkeleton:addChildBone
do
    local skel = lurek.spine.newSkeleton("character")
    local root = skel:addBone("root", { x = 0, y = 0, rotation = 0, scale_x = 1, scale_y = 1 })
    local spine_bone = skel:addChildBone("spine", root, { x = 0, y = -20 })
    local head = skel:addChildBone("head", spine_bone, { x = 0, y = -10 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(head)
    spine_log("addChildBone root=" .. tostring(root) .. " spine=" .. tostring(spine_bone) .. " head=" .. tostring(head) .. " world_y=" .. tostring(world and world.y))
end

--@api: LSkeleton:addSlot
do
    local skel = lurek.spine.newSkeleton("slotted")
    local bone = skel:addBone("torso", { y = -10 })
    local body_slot = skel:addSlot("body_slot", bone, "body_image")
    local hand_slot = skel:addSlot("hand_slot", bone, "hand_image")
    local slot_count = skel:slotCount()
    local found = skel:findSlot("hand_slot")
    spine_log("addSlot body=" .. tostring(body_slot) .. " hand=" .. tostring(hand_slot) .. " slots=" .. tostring(slot_count) .. " found=" .. tostring(found))
end

--@api: LSkeleton:addIKConstraint
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    example_print_log("ik constraint id = " .. skel:addIKConstraint("arm_ik", { upper, lower }, true))
end

--@api: LSkeleton:setIKTarget
do
    local skel = lurek.spine.newSkeleton("ik_demo")
    local root = skel:addBone("root")
    local upper = skel:addChildBone("upper_arm", root, { x = 20 })
    local lower = skel:addChildBone("lower_arm", upper, { x = 20 })
    skel:addIKConstraint("arm_ik", { upper, lower }, true)
    local ok = skel:setIKTarget("arm_ik", 60, -30)
    example_print_log("IK target set = " .. tostring(ok))
end

--@api: LSkeleton:addSkin
do
    local skel, _, torso, _ = make_demo_skeleton("skinned")
    skel:addSkin("default")
    skel:setSkinMapping("default", "torso_slot", "torso_idle")
    local activated = skel:setSkin("default")
    local skin = skel:getSkin()
    spine_log("addSkin torso=" .. tostring(torso) .. " activated=" .. tostring(activated) .. " skin=" .. tostring(skin))
end

--@api: LSkeleton:setSkin
do
    local skel, _, _, _ = make_demo_skeleton("skinned")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkinMapping("warrior", "torso_slot", "warrior_body")
    local switched = skel:setSkin("warrior")
    local current = skel:getSkin()
    spine_log("setSkin switched=" .. tostring(switched) .. " current=" .. tostring(current) .. " slots=" .. tostring(skel:slotCount()))
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
    example_print_log("current skin = " .. tostring(skel:getSkin()))
end

--@api: LSkeleton:getSkin
do
    local skel, _, _, _ = make_demo_skeleton("skinned")
    skel:addSkin("default")
    skel:addSkin("warrior")
    skel:setSkin("warrior")
    local current = skel:getSkin()
    local has_default = skel:setSkin("default")
    local restored = skel:getSkin()
    spine_log("getSkin current=" .. tostring(current) .. " switched_default=" .. tostring(has_default) .. " restored=" .. tostring(restored))
end

--@api: LSkeleton:addAnimation
do
    local skel, _, _, _ = make_demo_skeleton("animated")
    local idle = make_walk_animation("idle", 1.0)
    local timelines = idle:getTimelineCount()
    skel:addAnimation(idle)
    local started = skel:playAnimation("idle", true)
    local time = skel:getAnimationTime()
    spine_log("addAnimation started=" .. tostring(started) .. " time=" .. tostring(time) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeleton:playAnimation
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    local started = skel:playAnimation("idle", true)
    example_print_log("started = " .. tostring(started))
    example_print_log("time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:stopAnimation
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    skel:stopAnimation()
    example_print_log("stopped at time = " .. skel:getAnimationTime())
end

--@api: LSkeleton:getAnimationTime
do
    local skel = lurek.spine.newSkeleton("animated")
    skel:addBone("root")
    skel:addAnimation(lurek.spine.newSkeletonAnimation("idle", 1.0))
    skel:playAnimation("idle", true)
    example_print_log("time = " .. string.format("%.1f", skel:getAnimationTime()))
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
    example_print_log("blended run")
end

--@api: LSkeleton:findBone
do
    local skel = lurek.spine.newSkeleton("query")
    skel:addBone("root", { x = 100, y = 200 })
    skel:addBone("arm", { x = 30, y = 0 })
    local arm = skel:findBone("arm")
    local missing = skel:findBone("leg")
    spine_log("findBone arm=" .. tostring(arm) .. " missing=" .. tostring(missing) .. " bones=" .. tostring(skel:boneCount()))
end

--@api: LSkeleton:findSlot
do
    local skel = lurek.spine.newSkeleton("query")
    local arm = skel:addBone("arm", { x = 30, y = 0 })
    skel:addSlot("arm_slot", arm, "arm_img")
    local found = skel:findSlot("arm_slot")
    local missing = skel:findSlot("shield_slot")
    local slots = skel:slotCount()
    spine_log("findSlot found=" .. tostring(found) .. " missing=" .. tostring(missing) .. " slots=" .. tostring(slots))
end

--@api: LSkeleton:setPosition
do
    local skel, root, _, _ = make_demo_skeleton("query")
    skel:setPosition(200, 300)
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    local before = skel:getAnimationTime()
    spine_log("setPosition root=" .. tostring(root) .. " world=" .. tostring(world and world.x) .. "," .. tostring(world and world.y) .. " time=" .. tostring(before))
end

--@api: LSkeleton:getBoneWorld
do
    local skel = lurek.spine.newSkeleton("query")
    local root = skel:addBone("root", { x = 100, y = 200 })
    skel:updateWorldTransforms()
    local world = skel:getBoneWorld(root)
    example_print_log("root world = " .. string.format("%.0f, %.0f", world.x, world.y))
end

--@api: LSkeleton:updateWorldTransforms
do
    local skel, root, torso, _ = make_demo_skeleton("query")
    skel:setPosition(100, 200)
    skel:updateWorldTransforms()
    local root_world = skel:getBoneWorld(root)
    local torso_world = skel:getBoneWorld(torso)
    spine_log("updateWorldTransforms root=" .. tostring(root_world and root_world.x) .. "," .. tostring(root_world and root_world.y) .. " torso=" .. tostring(torso_world and torso_world.x) .. "," .. tostring(torso_world and torso_world.y))
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
    example_print_log("frame loop time = " .. string.format("%.3f", skel:getAnimationTime()))
end

--@api: LSkeleton:drawToImage
do
    local skel = lurek.spine.newSkeleton("render_test")
    local root = skel:addBone("root", { x = 64, y = 64 })
    skel:addChildBone("body", root, { y = -20 })
    skel:updateWorldTransforms()
    local img = skel:drawToImage(128, 128)
    example_print_log("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end

--@api: lurek.spine.newSkeletonAnimation
do
    local anim = lurek.spine.newSkeletonAnimation("walk_cycle", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 0.8, 12.0)
    local type_name = anim:type()
    local duration = anim:getDuration()
    local timelines = anim:getTimelineCount()
    spine_log("newSkeletonAnimation type=" .. type_name .. " duration=" .. tostring(duration) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeletonAnimation:addKeyframe
do
    local anim = lurek.spine.newSkeletonAnimation("bob", 1.0)
    anim:addKeyframe(0, "y", 0.0, 0)
    anim:addKeyframe(0, "y", 1.0, 0, "ease_in")
    anim:addKeyframe(0, "rotation", 0.5, 12, "linear")
    local pose = anim:poseAt(0.5)
    local timelines = anim:getTimelineCount()
    spine_log("addKeyframe timelines=" .. tostring(timelines) .. " pose_entries=" .. tostring(#pose))
end

--@api: LSkeletonAnimation:addEventKey
do
    local anim = lurek.spine.newSkeletonAnimation("attack", 0.5)
    anim:addEventKey(0.2, "whoosh", 1)
    anim:addEventKey(0.3, "hit", 2)
    anim:addEventKey(0.45, "recover", 3)
    local events = anim:getEvents(0.0, 0.5)
    local partial = anim:getEvents(0.25, 0.5)
    spine_log("addEventKey events=" .. tostring(#events) .. " partial=" .. tostring(#partial))
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
    spine_log("getEvents partial=" .. tostring(#partial) .. " later=" .. tostring(#later) .. " first=" .. first)
end

--@api: LSkeletonAnimation:reverse
do
    local anim = lurek.spine.newSkeletonAnimation("swing", 0.6)
    anim:addKeyframe(0, "rotation", 0.0, 0)
    anim:addKeyframe(0, "rotation", 0.6, 0)
    local reversed = anim:reverse()
    example_print_log("reversed duration = " .. reversed:getDuration())
end

--@api: lurek.spine.animationFromJson
do
    local jsonData = '{"name":"idle_bounce","duration":1.2,"timelines":[{"bone":0,"property":"y","keys":[{"time":0,"value":0},{"time":1.2,"value":0}]}]}'
    local anim = lurek.spine.animationFromJson(jsonData)
    local timelines = anim and anim:getTimelineCount() or -1
    local duration = anim and anim:getDuration() or -1
    local reversed = anim and anim:reverse() or nil
    local reversed_duration = reversed and reversed:getDuration() or -1
    spine_log("animationFromJson timelines=" .. tostring(timelines) .. " duration=" .. tostring(duration) .. " reversed=" .. tostring(reversed_duration))
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
        example_print_log("imported bones = " .. imported:boneCount())
        example_print_log("imported slots = " .. imported:slotCount())
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
    spine_log("boneCount bones=" .. tostring(bones) .. " root=" .. tostring(root) .. " arm=" .. tostring(arm))
end

--@api: LSkeleton:slotCount
do
    local skel = lurek.spine.newSkeleton("hero")
    local arm = skel:addBone("arm", {})
    skel:addSlot("arm_slot", arm, nil)
    skel:addSlot("weapon_slot", arm, "sword")
    local slots = skel:slotCount()
    local found = skel:findSlot("weapon_slot")
    spine_log("slotCount slots=" .. tostring(slots) .. " weapon=" .. tostring(found))
end

--@api: LSkeleton:type
do
    local skel, _, _, _ = make_demo_skeleton("hero")
    local type_name = skel:type()
    local is_skeleton = skel:typeOf("LSkeleton")
    local bones = skel:boneCount()
    spine_log("LSkeleton:type name=" .. type_name .. " is_skeleton=" .. tostring(is_skeleton) .. " bones=" .. tostring(bones))
end

--@api: LSkeleton:typeOf
do
    local skel, _, _, _ = make_demo_skeleton("hero")
    local is_skeleton = skel:typeOf("LSkeleton")
    local is_object = skel:typeOf("Object")
    local is_anim = skel:typeOf("LSkeletonAnimation")
    spine_log("LSkeleton:typeOf skeleton=" .. tostring(is_skeleton) .. " object=" .. tostring(is_object) .. " anim=" .. tostring(is_anim))
end

--@api: LSkeletonAnimation:getDuration
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    anim:addKeyframe(0, "x", 0.8, 12.0)
    local duration = anim:getDuration()
    local timelines = anim:getTimelineCount()
    spine_log("getDuration duration=" .. tostring(duration) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeletonAnimation:getTimelineCount
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "rotation", 0.0, 0.0, "linear")
    anim:addKeyframe(0, "rotation", 0.8, 15.0, "ease_in_out")
    local timelines = anim:getTimelineCount()
    local pose = anim:poseAt(0.4)
    spine_log("getTimelineCount timelines=" .. tostring(timelines) .. " pose=" .. tostring(#pose))
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
    spine_log("poseAt entries=" .. tostring(#pose) .. " property=" .. property .. " value=" .. tostring(value))
end

--@api: LSkeletonAnimation:type
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    anim:addKeyframe(0, "x", 0.0, 0.0)
    local type_name = anim:type()
    local is_anim = anim:typeOf("LSkeletonAnimation")
    local timelines = anim:getTimelineCount()
    spine_log("LSkeletonAnimation:type name=" .. type_name .. " is_anim=" .. tostring(is_anim) .. " timelines=" .. tostring(timelines))
end

--@api: LSkeletonAnimation:typeOf
do
    local anim = lurek.spine.newSkeletonAnimation("run", 0.8)
    local is_anim = anim:typeOf("LSkeletonAnimation")
    local is_object = anim:typeOf("Object")
    local is_skeleton = anim:typeOf("LSkeleton")
    anim:addEventKey(0.2, "step", 1)
    spine_log("LSkeletonAnimation:typeOf anim=" .. tostring(is_anim) .. " object=" .. tostring(is_object) .. " skeleton=" .. tostring(is_skeleton))
end
