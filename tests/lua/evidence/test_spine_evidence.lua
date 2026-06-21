-- Canonical evidence file for lurek.spine visual outputs.


local OUT = evidence_output_dir("spine")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
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

local function render_pose_sheet()
    local sk, bones = build_walk_skeleton()
    local frame_w, frame_h = 192, 192
    local canvas = lurek.image.newImageData(frame_w * 3, frame_h * 2)
    canvas:fill(18, 20, 28, 255)

    for frame_index = 1, 6 do
        sk:updateAnimation(0.2)
        sk:updateWorldTransforms()
        local frame = render_walk_frame(sk, bones):resize(frame_w, frame_h, "bilinear")
        local col = (frame_index - 1) % 3
        local row = math.floor((frame_index - 1) / 3)
        local ox = col * frame_w
        local oy = row * frame_h
        canvas:paste(frame, ox, oy)
        canvas:drawLine(ox, oy, ox + frame_w - 1, oy, 235, 238, 246, 255)
        canvas:drawLine(ox + frame_w - 1, oy, ox + frame_w - 1, oy + frame_h - 1, 235, 238, 246, 255)
        canvas:drawLine(ox + frame_w - 1, oy + frame_h - 1, ox, oy + frame_h - 1, 235, 238, 246, 255)
        canvas:drawLine(ox, oy + frame_h - 1, ox, oy, 235, 238, 246, 255)
    end

    return canvas
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

local function render_ik_targets()
    local sk, bones = build_ik_demo()
    local targets = {
        { 96, 24 },
        { 122, -10 },
        { 100, 54 },
    }
    local panel_w, panel_h = 176, 176
    local canvas = lurek.image.newImageData(panel_w * #targets, panel_h)
    canvas:fill(16, 19, 25, 255)

    for i, target in ipairs(targets) do
        sk:setIKTarget("arm_ik", target[1], target[2])
        sk:updateWorldTransforms()
        local frame = sk:drawToImage(panel_w, panel_h)
        local ox = (i - 1) * panel_w
        canvas:drawRect(ox, 0, panel_w, panel_h, 32, 36, 46, 255)
        canvas:paste(frame, ox, 0)
        canvas:drawCircle(ox + target[1], 112 + target[2], 6, 255, 126, 126, 255)
        canvas:drawLine(ox, 0, ox + panel_w - 1, 0, 226, 230, 238, 255)
        canvas:drawLine(ox + panel_w - 1, 0, ox + panel_w - 1, panel_h - 1, 226, 230, 238, 255)
        canvas:drawLine(ox + panel_w - 1, panel_h - 1, ox, panel_h - 1, 226, 230, 238, 255)
        canvas:drawLine(ox, panel_h - 1, ox, 0, 226, 230, 238, 255)
    end

    return canvas
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
    -- Does: Runs "walk cycle pose sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LSkeleton:updateAnimation and LSkeleton:drawToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/spine_walk_cycle_pose_sheet.png
    -- Why: This is meaningful only if the visible/text output comes from LSkeleton:updateAnimation and LSkeleton:drawToImage; export helpers are just the container.

    it("PNG: walk cycle pose sheet", function()
        local path = OUT .. "spine_walk_cycle_pose_sheet.png"
        save_png(render_pose_sheet(), path)
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
    -- Artifact: tests/artifacts/current/spine/<artifact>
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
        lurek.image.saveGIF(frames, path, { delayMs = 400, speed = 10 })
        expect_evidence_created(path)
    end)
    -- Does: Runs "IK target reach panels" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LSkeleton:addIKConstraint, LSkeleton:setIKTarget, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/spine_ik_target_panels.png
    -- Why: This is meaningful only if the visible/text output comes from LSkeleton:addIKConstraint, LSkeleton:setIKTarget, and related owner calls; export helpers are just the container.

    it("PNG: IK target reach panels", function()
        local path = OUT .. "spine_ik_target_panels.png"
        save_png(render_ik_targets(), path)
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
    -- Does: Runs "imported skeleton animation contact sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.spine.animationFromJson, lurek.spine.skeletonFromJson, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/spine/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.spine.animationFromJson, lurek.spine.skeletonFromJson, and related owner calls; export helpers are just the container.

    it("PNG: imported skeleton animation contact sheet", function()
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

        local panel_w, panel_h = 160, 160
        local canvas = lurek.image.newImageData(panel_w * 4, panel_h)
        canvas:fill(18, 20, 28, 255)

        for i = 1, 4 do
            sk:updateAnimation(0.3)
            sk:updateWorldTransforms()
            local frame = sk:drawToImage(panel_w, panel_h)
            local ox = (i - 1) * panel_w
            canvas:paste(frame, ox, 0)
            canvas:drawLine(ox, 0, ox + panel_w - 1, 0, 236, 240, 246, 255)
            canvas:drawLine(ox + panel_w - 1, 0, ox + panel_w - 1, panel_h - 1, 236, 240, 246, 255)
            canvas:drawLine(ox + panel_w - 1, panel_h - 1, ox, panel_h - 1, 236, 240, 246, 255)
            canvas:drawLine(ox, panel_h - 1, ox, 0, 236, 240, 246, 255)
        end

        local path = OUT .. "spine_imported_animation_contact_sheet.png"
        save_png(canvas, path)
    end)
end)
test_summary()
