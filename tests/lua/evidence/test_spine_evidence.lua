-- Evidence tests: spine module
-- Artifacts are generated from lurek.spine APIs.

local OUT = "tests/output/spine/"

-- @describe Evidence: lurek.spine API
describe("Evidence: lurek.spine API", function()
    before_each(function()
        ensure_evidence_dir("spine")
    end)

    -- @evidence file
    it("PNG: stick figure skeleton", function()
        local sk = lurek.spine.newSkeleton("stick_figure")

        local torso = sk:addBone("torso", { length = 50 })
        local head = sk:addChildBone("head", torso, { length = 20, rotation = 0 })
        local hip = sk:addChildBone("hip", torso, { length = 10, rotation = 180 })
        sk:addChildBone("l_arm", torso, { length = 35, rotation = -45 })
        sk:addChildBone("r_arm", torso, { length = 35, rotation = 45 })
        sk:addChildBone("l_leg", hip, { length = 40, rotation = 160 })
        sk:addChildBone("r_leg", hip, { length = 40, rotation = 200 })

        sk:addSlot("head_slot", head, "circle")
        sk:addSlot("body_slot", torso, "rect")

        sk:setPosition(128, 80)
        sk:updateWorldTransforms()

        local img = sk:drawToImage(256, 256)
        local path = OUT .. "skeleton_stick_figure.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
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
        lurek.filesystem.write(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
    end)
end)

test_summary()
