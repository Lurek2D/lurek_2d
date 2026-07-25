-- Canonical evidence file for lurek.spine visual outputs.
-- @covers lurek.image.newImageData
-- @covers lurek.image.saveGIF
-- @covers lurek.image.savePNG
-- @covers lurek.spine.animationFromJson
-- @covers lurek.spine.newSkeleton
-- @covers lurek.spine.newSkeletonAnimation



local OUT = evidence_output_dir("spine")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options or { delayMs = 100, speed = 20 })
    expect_evidence_created(path)
end

local function build_walk_skeleton()
    local sk = lurek.spine.newSkeleton("walk_cycle")

    local torso = sk:addBone("torso", { length = 44 })
    local head = sk:addChildBone("head", torso, { y = -34, length = 20 })
    local hip = sk:addChildBone("hip", torso, { y = 22, length = 10, rotation = 180 })
    local l_arm = sk:addChildBone("l_arm", torso, { x = -6, y = -8, length = 28, rotation = -28 })
    local r_arm = sk:addChildBone("r_arm", torso, { x = 6, y = -8, length = 28, rotation = 28 })
    local l_leg = sk:addChildBone("l_leg", hip, { x = -5, y = 8, length = 34, rotation = 166 })
    local r_leg = sk:addChildBone("r_leg", hip, { x = 5, y = 8, length = 34, rotation = 194 })
    local l_hand = sk:addChildBone("l_hand", l_arm, { x = -24, y = 4, length = 12 })
    local r_hand = sk:addChildBone("r_hand", r_arm, { x = 24, y = 4, length = 12 })
    local l_foot = sk:addChildBone("l_foot", l_leg, { x = -6, y = 26, length = 10 })
    local r_foot = sk:addChildBone("r_foot", r_leg, { x = 6, y = 26, length = 10 })

    sk:addSlot("head_slot", head, "circle")
    sk:addSlot("body_slot", torso, "rect")
    sk:addSlot("left_arm_slot", l_arm, "line")
    sk:addSlot("right_arm_slot", r_arm, "line")
    sk:addSlot("left_leg_slot", l_leg, "line")
    sk:addSlot("right_leg_slot", r_leg, "line")
    sk:setPosition(128, 142)

    local anim = lurek.spine.newSkeletonAnimation("walk", 1.2)
    anim:addKeyframe(torso, "y", 0.0, 0.0)
    anim:addKeyframe(torso, "y", 0.6, -6.0)
    anim:addKeyframe(torso, "y", 1.2, 0.0)
    anim:addKeyframe(l_arm, "rotation", 0.0, -40.0)
    anim:addKeyframe(l_arm, "rotation", 0.6, 36.0)
    anim:addKeyframe(l_arm, "rotation", 1.2, -40.0)
    anim:addKeyframe(r_arm, "rotation", 0.0, 40.0)
    anim:addKeyframe(r_arm, "rotation", 0.6, -36.0)
    anim:addKeyframe(r_arm, "rotation", 1.2, 40.0)
    anim:addKeyframe(l_leg, "rotation", 0.0, 192.0)
    anim:addKeyframe(l_leg, "rotation", 0.6, 148.0)
    anim:addKeyframe(l_leg, "rotation", 1.2, 192.0)
    anim:addKeyframe(r_leg, "rotation", 0.0, 148.0)
    anim:addKeyframe(r_leg, "rotation", 0.6, 192.0)
    anim:addKeyframe(r_leg, "rotation", 1.2, 148.0)

    sk:addAnimation(anim)
    expect_true(sk:playAnimation("walk", true))
    return sk, {
        torso = torso,
        head = head,
        hip = hip,
        l_arm = l_arm,
        r_arm = r_arm,
        l_leg = l_leg,
        r_leg = r_leg,
        l_hand = l_hand,
        r_hand = r_hand,
        l_foot = l_foot,
        r_foot = r_foot,
    }
end

local function map_pose_point(anchor, world)
    local scale = 4.5
    return 128 + (world.x - anchor.x) * scale, 128 + (world.y - anchor.y) * scale
end

local function draw_bone_segment(img, sk, anchor, a, b, r, g, blue)
    local aw = sk:getBoneWorld(a)
    local bw = sk:getBoneWorld(b)
    if aw and bw then
        local ax, ay = map_pose_point(anchor, aw)
        local bx, by = map_pose_point(anchor, bw)
        img:drawLine(ax, ay, bx, by, r, g, blue, 255)
        img:drawCircle(ax, ay, 4, 255, 214, 150, 255)
        img:drawCircle(bx, by, 4, 255, 214, 150, 255)
    end
end

local function render_walk_frame(sk, bones)
    local figure = sk:drawToImage(256, 256)
    local img = lurek.image.newImageData(256, 256)
    img:fill(22, 24, 32, 255)
    img:drawRect(0, 188, 256, 68, 32, 36, 48, 255)
    img:drawLine(0, 188, 255, 188, 58, 64, 86, 255)
    img:paste(figure, 0, 0)
    local anchor = sk:getBoneWorld(bones.torso) or { x = 0, y = 0 }
    draw_bone_segment(img, sk, anchor, bones.torso, bones.head, 255, 210, 120)
    draw_bone_segment(img, sk, anchor, bones.torso, bones.hip, 255, 210, 120)
    draw_bone_segment(img, sk, anchor, bones.torso, bones.l_arm, 120, 210, 255)
    draw_bone_segment(img, sk, anchor, bones.l_arm, bones.l_hand, 120, 210, 255)
    draw_bone_segment(img, sk, anchor, bones.torso, bones.r_arm, 120, 210, 255)
    draw_bone_segment(img, sk, anchor, bones.r_arm, bones.r_hand, 120, 210, 255)
    draw_bone_segment(img, sk, anchor, bones.hip, bones.l_leg, 120, 255, 170)
    draw_bone_segment(img, sk, anchor, bones.l_leg, bones.l_foot, 120, 255, 170)
    draw_bone_segment(img, sk, anchor, bones.hip, bones.r_leg, 120, 255, 170)
    draw_bone_segment(img, sk, anchor, bones.r_leg, bones.r_foot, 120, 255, 170)
    return img
end

local function draw_label_bar(img, text, color)
    img:drawRect(0, 0, 260, 20, 32, 38, 54, 255)
    img:drawRect(0, 20, 260, 2, color[1], color[2], color[3], 255)
    img:drawRect(10, 7, 42, 6, color[1], color[2], color[3], 255)
    img:drawRect(58, 7, 22, 6, 92, 102, 128, 255)
    img:drawRect(86, 7, 22, 6, 92, 102, 128, 255)
end

local function compose_spine_frame(source, title, color)
    local img = lurek.image.newImageData(260, 180)
    img:fill(16, 18, 25, 255)
    draw_label_bar(img, title, color)
    img:drawRect(12, 32, 176, 136, 24, 28, 38, 255)
    img:paste(source, 12, 20)
    img:drawLine(12, 156, 188, 156, 64, 72, 92, 255)
    return img
end

local function build_ik_demo()
    local sk = lurek.spine.newSkeleton("ik_reach")
    local root = sk:addBone("root", { length = 16 })
    local shoulder = sk:addChildBone("shoulder", root, { x = 0, y = 0, length = 32 })
    local elbow = sk:addChildBone("elbow", shoulder, { x = 30, y = 0, length = 28 })
    local hand = sk:addChildBone("hand", elbow, { x = 26, y = 0, length = 12 })
    sk:addSlot("shoulder_slot", shoulder, "line")
    sk:addSlot("elbow_slot", elbow, "line")
    sk:addSlot("hand_slot", hand, "circle")
    sk:setPosition(72, 112)
    sk:addIKConstraint("arm_ik", { shoulder, elbow }, true)
    return sk, { shoulder = shoulder, elbow = elbow, hand = hand }
end

-- @describe Evidence: lurek.spine API
describe("Evidence: lurek.spine API", function()
    before_each(function()
        ensure_evidence_dir("spine")
    end)
    -- Does: Runs "stick figure skeleton" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.spine.newSkeleton, LSkeleton:addBone, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/skeleton_stick_figure.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.spine.newSkeleton, LSkeleton:addBone, and related owner calls; export helpers are just the container.

    it("PNG: stick figure skeleton", function()
        local sk, bones = build_walk_skeleton()
        sk:updateWorldTransforms()
        local img = render_walk_frame(sk, bones)
        local path = OUT .. "skeleton_stick_figure.png"
        save_png(img, path)
    end)
    -- Does: Runs "walk cycle pose playback" and stores sampled LSkeleton:updateAnimation output as one animated artifact.
    -- Shows: The GIF exposes bone hierarchy motion, slot rendering, and world-transform recomputation over the cycle without scattering motion across still PNG files.
    -- Artifact: tests/artifacts/current/spine/spine_walk_cycle_pose_snapshots.gif
    -- Why: This is spine-owned evidence because every frame comes from LSkeleton:updateAnimation, LSkeleton:updateWorldTransforms, and LSkeleton:drawToImage.

    it("GIF: walk cycle pose playback", function()
        local sk, bones = build_walk_skeleton()
        local frames = {}
        for frame_index = 1, 6 do
            sk:updateAnimation(0.2)
            sk:updateWorldTransforms()
            frames[frame_index] = render_walk_frame(sk, bones):resize(192, 192, "bilinear")
        end
        save_gif(frames, OUT .. "spine_walk_cycle_pose_snapshots.gif", { delayMs = 120, speed = 20 })
    end)
    -- Does: Runs "bone world-transform query" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.spine.newSkeleton, LSkeleton:getBoneWorld, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/bone_operations.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.spine.newSkeleton, LSkeleton:getBoneWorld, and related owner calls; export helpers are just the container.

    it("TXT: bone world-transform query", function()
        local sk = lurek.spine.newSkeleton("query_test")
        local root = sk:addBone("root", { length = 40 })
        sk:addChildBone("child", root, { length = 30, rotation = 45 })

        sk:setPosition(64, 64)
        sk:updateWorldTransforms()

        local w = sk:getBoneWorld(root)
        expect_true(w ~= nil)

        local lines = {
            "boneCount=" .. tostring(sk:boneCount()),
            "slotCount=" .. tostring(sk:slotCount()),
            "x=" .. tostring(w and w.x or 0),
            "y=" .. tostring(w and w.y or 0),
            "rotation=" .. tostring(w and w.rotation or 0),
        }

        local path = OUT .. "bone_operations.txt"
        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)
    -- Does: Runs "walk cycle over five seconds" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.spine.newSkeletonAnimation, LSkeleton:addAnimation, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/spine_walk_cycle_5s.gif
    -- Why: This is meaningful only if the visible/text output comes from lurek.spine.newSkeletonAnimation, LSkeleton:addAnimation, and related owner calls; export helpers are just the container.

    it("GIF: walk cycle over five seconds", function()
        local sk, bones = build_walk_skeleton()
        local frames = {}

        for frame_index = 1, 13 do
            sk:updateAnimation(0.4)
            sk:updateWorldTransforms()
            frames[frame_index] = render_walk_frame(sk, bones)
        end

        local path = OUT .. "spine_walk_cycle_5s.gif"
        save_gif(frames, path, { delayMs = 400, speed = 10 })
    end)
    -- Does: Moves an IK target across several positions and records the solved arm chain as an animated artifact.
    -- Shows: The GIF makes the constraint solver legible: the same shoulder/elbow/hand hierarchy reaches different targets over time.
    -- Artifact: tests/artifacts/current/spine/spine_ik_target_reach.gif
    -- Why: This is spine-specific evidence for LSkeleton:addIKConstraint, LSkeleton:setIKTarget, and LSkeleton:updateWorldTransforms rather than generic sprite animation.

    it("GIF: IK target reach captures", function()
        local sk = build_ik_demo()
        local targets = {
            { 96, 24 },
            { 122, -10 },
            { 100, 54 },
            { 64, 8 },
            { 118, 38 },
        }

        local frames = {}
        for i, target in ipairs(targets) do
            sk:setIKTarget("arm_ik", target[1], target[2])
            sk:updateWorldTransforms()
            local source = sk:drawToImage(176, 176)
            source:drawCircle(target[1], 112 + target[2], 7, 255, 126, 126, 255)
            source:drawLine(72, 112, target[1], 112 + target[2], 255, 210, 120, 255)
            local frame = compose_spine_frame(source, "IK TARGET", { 255, 126, 126 })
            frame:drawRect(204, 48, 34, 86, 34, 40, 54, 255)
            for j = 1, #targets do
                local ty = 52 + j * 14
                local active = j == i
                frame:drawCircle(221, ty, active and 6 or 3, active and 255 or 104, active and 126 or 116, active and 126 or 138, 255)
            end
            frame:drawRect(204, 146, math.floor(34 * i / #targets), 8, 255, 126, 126, 255)
            frames[i] = frame
        end
        save_gif(frames, OUT .. "spine_ik_target_reach.gif", { delayMs = 160, speed = 20 })
    end)
    -- Does: Runs "skin, event and pose trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LSkeleton:addSkin, LSkeleton:getSkin, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/spine_skin_event_pose_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LSkeleton:addSkin, LSkeleton:getSkin, and related owner calls; export helpers are just the container.

    it("TXT: skin, event and pose trace", function()
        local sk = lurek.spine.newSkeleton("trace_skin")
        local torso = sk:addBone("torso", { x = 10, y = 12, length = 24 })
        sk:addSlot("torso_slot", torso, "body_default")
        sk:addSkin("default")
        sk:addSkin("armor")
        sk:setSkinMapping("armor", "torso_slot", "body_armor")
        expect_true(sk:setSkin("armor"))

        local anim = lurek.spine.newSkeletonAnimation("pulse", 1.0)
        anim:addKeyframe(torso, "rotation", 0.0, -10.0)
        anim:addKeyframe(torso, "rotation", 0.5, 12.0)
        anim:addKeyframe(torso, "rotation", 1.0, -10.0)
        anim:addEventKey(0.25, "windup", 1.0)
        anim:addEventKey(0.75, "release", 2.0)

        local pose = anim:poseAt(0.5)
        local events = anim:getEvents(0.0, 0.8)
        local path = OUT .. "spine_skin_event_pose_trace.txt"
        local lines = {
            "skin=" .. tostring(sk:getSkin()),
            "events=" .. tostring(#events),
            "first_event=" .. tostring(events[1] and events[1].name or "nil"),
            "pose_type=" .. type(pose),
            "timeline_count=" .. tostring(anim:getTimelineCount()),
        }

        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)
    -- Does: Imports a skeleton and animation from JSON, plays the imported clip, and records the resulting pose playback as a GIF.
    -- Shows: The artifact proves imported bone and slot data are not just parsed; the animation timeline drives visible runtime skeleton poses.
    -- Artifact: tests/artifacts/current/spine/spine_imported_animation.gif
    -- Why: Imported skeletal animation is a spine responsibility, so moving evidence belongs in one GIF generated from skeletonFromJson, animationFromJson, and LSkeleton:updateAnimation.

    it("GIF: imported skeleton animation playback", function()
        local importer = rawget(lurek.spine, "skeletonFromJson")
        expect_true(importer ~= nil)

        local sk = importer([[
        {
            "skeleton": { "name": "import_demo" },
            "bones": [
                { "name": "root" },
                { "name": "torso", "parent": "root", "x": 0.0, "y": -6.0 },
                { "name": "arm", "parent": "torso", "x": 18.0, "y": -2.0 }
            ],
            "slots": [
                { "name": "body", "bone": "torso", "attachment": "rect" },
                { "name": "arm_slot", "bone": "arm", "attachment": "line" }
            ]
        }
        ]])

        local anim = lurek.spine.animationFromJson([[
        {
            "name": "import_wave",
            "duration": 1.2,
            "timelines": [
                {
                    "bone_idx": 1,
                    "property": "y",
                    "keys": [
                        { "time": 0.0, "value": 0.0 },
                        { "time": 0.6, "value": -6.0 },
                        { "time": 1.2, "value": 0.0 }
                    ]
                },
                {
                    "bone_idx": 2,
                    "property": "rotation",
                    "keys": [
                        { "time": 0.0, "value": -28.0 },
                        { "time": 0.6, "value": 32.0 },
                        { "time": 1.2, "value": -28.0 }
                    ]
                }
            ]
        }
        ]])

        sk:setPosition(84, 110)
        expect_type("userdata", anim)
        sk:addAnimation(anim)
        expect_true(sk:playAnimation("import_wave", true))

        local frames = {}
        for i = 1, 6 do
            sk:updateAnimation(0.3)
            sk:updateWorldTransforms()
            local source = sk:drawToImage(160, 160)
            local frame = compose_spine_frame(source, "JSON IMPORT", { 120, 210, 255 })
            frame:drawRect(204, 50, 40, 10, 120, 210, 255, 255)
            frame:drawRect(204, 76, 40, 10, 255, 210, 120, 255)
            frame:drawRect(204, 102, 40, 10, 120, 255, 170, 255)
            frame:drawRect(204, 142, math.floor(40 * i / 6), 8, 120, 210, 255, 255)
            frames[i] = frame
        end
        save_gif(frames, OUT .. "spine_imported_animation.gif", { delayMs = 120, speed = 20 })
    end)
end)
test_summary()
