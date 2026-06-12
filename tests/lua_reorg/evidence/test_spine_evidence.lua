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
    local img = sk:drawToImage(256, 256)
    img:fill(22, 24, 32, 255)
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

-- @describe Evidence: lurek.spine API
describe("Evidence: lurek.spine API", function()
    before_each(function()
        ensure_evidence_dir("spine")
    end)

    -- @evidence lurek.spine.newSkeleton
    -- @evidence LSkeleton:addBone
    -- @evidence LSkeleton:addChildBone
    -- @evidence LSkeleton:addSlot
    -- @evidence LSkeleton:setPosition
    -- @evidence LSkeleton:updateWorldTransforms
    -- @evidence LSkeleton:drawToImage
    -- @evidence lurek.image.savePNG
    it("PNG: stick figure skeleton", function()
        local sk, bones = build_walk_skeleton()
        sk:updateWorldTransforms()
        local img = render_walk_frame(sk, bones)
        local path = OUT .. "skeleton_stick_figure.png"
        save_png(img, path)
    end)

    -- @evidence lurek.spine.newSkeleton
    -- @evidence LSkeleton:getBoneWorld
    -- @evidence LSkeleton:boneCount
    -- @evidence LSkeleton:slotCount
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

    -- @evidence lurek.spine.newSkeletonAnimation
    -- @evidence LSkeleton:addAnimation
    -- @evidence LSkeleton:playAnimation
    -- @evidence LSkeleton:updateAnimation
    -- @evidence LSkeleton:updateWorldTransforms
    -- @evidence LSkeleton:drawToImage
    -- @evidence lurek.image.saveGIF
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
end)
test_summary()
