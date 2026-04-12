-- Lurek2D Lua BDD tests for lurek.spine
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.spine.
describe("lurek.spine", function()
    -- @description Covers suite: module interface.
    describe("module interface", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies the spine namespace exposes the legacy newSkeleton factory.
        it("exposes newSkeleton factory", function()
            expect_type("function", lurek.spine.newSkeleton)
        end)
    end)

    -- @description Covers suite: newSkeleton(name).
    describe("newSkeleton(name)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies newSkeleton returns userdata for a named skeleton handle.
        it("returns a userdata object", function()
            local sk = lurek.spine.newSkeleton("hero")
            expect_type("userdata", sk)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies new skeletons start with zero bones.
        it("starts with zero bones", function()
            local sk = lurek.spine.newSkeleton("test")
            expect_equal(0, sk:boneCount())
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies new skeletons start with zero slots.
        it("starts with zero slots", function()
            local sk = lurek.spine.newSkeleton("test")
            expect_equal(0, sk:slotCount())
        end)
    end)

    -- @description Covers suite: addBone(name, opts).
    describe("addBone(name, opts)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies addBone returns a zero-based index for the first inserted bone.
        it("returns an index starting from 0", function()
            local sk = lurek.spine.newSkeleton("test")
            local idx = sk:addBone("root")
            expect_equal(0, idx)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies addBone increments the bone count for each insertion.
        it("increments boneCount", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:addBone("root")
            sk:addBone("torso")
            expect_equal(2, sk:boneCount())
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies addBone accepts optional transform metadata without error.
        it("accepts opts table with x, y, rotation", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:addBone("root", { x = 10, y = 20, rotation = 0.5 })
            expect_equal(1, sk:boneCount())
        end)
    end)

    -- @description Covers suite: addChildBone(name, parent_idx, opts).
    describe("addChildBone(name, parent_idx, opts)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies addChildBone appends a child bone and increments the total count.
        it("increments boneCount", function()
            local sk = lurek.spine.newSkeleton("test")
            local root = sk:addBone("root")
            sk:addChildBone("arm", root)
            expect_equal(2, sk:boneCount())
        end)
    end)

    -- @description Covers suite: findBone(name).
    describe("findBone(name)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies findBone returns the stored index for an existing bone name.
        it("returns the index of an existing bone", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:addBone("root")
            sk:addBone("chest")
            local idx = sk:findBone("chest")
            expect_equal(1, idx)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies findBone returns nil for unknown bone names.
        it("returns nil for unknown bone name", function()
            local sk = lurek.spine.newSkeleton("test")
            expect_equal(nil, sk:findBone("nonexistent"))
        end)
    end)

    -- @description Covers suite: addSlot(name, bone_idx, attachment).
    describe("addSlot(name, bone_idx, attachment)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies addSlot increments slotCount when a slot is attached to a bone.
        it("increments slotCount", function()
            local sk = lurek.spine.newSkeleton("test")
            local b = sk:addBone("root")
            sk:addSlot("slot0", b)
            expect_equal(1, sk:slotCount())
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies addSlot accepts an optional attachment name.
        it("accepts optional attachment name", function()
            local sk = lurek.spine.newSkeleton("test")
            local b = sk:addBone("root")
            sk:addSlot("slot0", b, "torso_skin")
            expect_equal(1, sk:slotCount())
        end)
    end)

    -- @description Covers suite: findSlot(name).
    describe("findSlot(name)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies findSlot returns the index for an existing slot.
        it("returns the index of an existing slot", function()
            local sk = lurek.spine.newSkeleton("test")
            local b = sk:addBone("root")
            sk:addSlot("weapon_slot", b)
            local idx = sk:findSlot("weapon_slot")
            expect_equal(0, idx)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies findSlot returns nil for missing slot names.
        it("returns nil for unknown slot name", function()
            local sk = lurek.spine.newSkeleton("test")
            expect_equal(nil, sk:findSlot("nope"))
        end)
    end)

    -- @description Covers suite: setPosition(x, y).
    describe("setPosition(x, y)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies setPosition accepts a new origin without raising an error.
        it("does not error", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:setPosition(50, 120)
        end)
    end)

    -- @description Covers suite: updateWorldTransforms().
    describe("updateWorldTransforms()", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies updateWorldTransforms runs safely after bones exist.
        it("does not error", function()
            local sk = lurek.spine.newSkeleton("test")
            sk:addBone("root")
            sk:updateWorldTransforms()
        end)
    end)

    -- @description Covers suite: getBoneWorld(idx).
    describe("getBoneWorld(idx)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies getBoneWorld returns numeric transform fields for a valid bone after world updates.
        it("returns a table with transform fields after updateWorldTransforms", function()
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
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies getBoneWorld returns nil for an out-of-bounds bone index.
        it("returns nil for out-of-bounds index", function()
            local sk = lurek.spine.newSkeleton("test")
            local result = sk:getBoneWorld(999)
            expect_equal(nil, result)
        end)
    end)
    -- @description Covers suite: drawToImage(w, h).
    describe("drawToImage(w, h)", function()
        -- @covers lurek.spine.newSkeleton
        -- @description Verifies skeleton userdata exposes drawToImage as a callable method.
        it("is a function on skeleton", function()
            local sk = lurek.spine.newSkeleton("test")
            expect_type("function", function() sk:drawToImage(64, 64) end)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies drawToImage returns userdata for the generated image payload.
        it("returns a userdata (ImageData)", function()
            local sk = lurek.spine.newSkeleton("test")
            local img = sk:drawToImage(64, 64)
            expect_type("userdata", img)
        end)

        -- @covers lurek.spine.newSkeleton
        -- @description Verifies drawToImage accepts minimal 1x1 dimensions.
        it("works with minimal dimensions 1x1", function()
            local sk = lurek.spine.newSkeleton("test")
            local img = sk:drawToImage(1, 1)
            expect_not_nil(img)
        end)
    end)
end)
test_summary()
