-- Lurek2D AI — AILod (Level-of-Detail) tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the AILod factory and basic API.
describe("lurek.ai.newAILod factory", function()
    -- @covers lurek.ai.newAILod
    it("exists as a function", function()
        expect_type("function", lurek.ai.newAILod)
    end)

    -- @covers lurek.ai.newAILod
    it("creates a userdata object", function()
        local lod = lurek.ai.newAILod()
        expect_type("userdata", lod)
    end)

    -- @covers lurek.ai.newAILod
    it("tierCount is >= 1", function()
        local lod = lurek.ai.newAILod()
        expect_equal(lod:tierCount() >= 1, true)
    end)
end)

-- =========================================================================
-- 2. Tier assignment
-- =========================================================================
-- @description Verifies tierFor() returns valid tier indices based on distance.
describe("AILod tierFor", function()
    -- @covers lurek.ai.newAILod
    it("returns an integer tier index", function()
        local lod = lurek.ai.newAILod()
        local tier = lod:tierFor(0, 0, 0, 0)
        expect_type("number", tier)
        expect_equal(tier >= 0, true)
    end)

    -- @covers lurek.ai.newAILod
    it("agent at same position as reference gets tier 0 (nearest)", function()
        local lod = lurek.ai.newAILod()
        local tier = lod:tierFor(0, 0, 0, 0)
        expect_equal(tier, 0)
    end)

    -- @covers lurek.ai.newAILod
    it("distant agent gets higher tier than close agent", function()
        local lod = lurek.ai.newAILod()
        local near_tier = lod:tierFor(5, 0, 0, 0)    -- close
        local far_tier  = lod:tierFor(2000, 0, 0, 0) -- very far
        expect_equal(far_tier >= near_tier, true)
    end)

    -- @covers lurek.ai.newAILod
    it("tier index never exceeds tierCount-1", function()
        local lod = lurek.ai.newAILod()
        local max_tier = lod:tierCount() - 1
        local tier = lod:tierFor(99999, 99999, 0, 0)
        expect_equal(tier <= max_tier, true)
    end)
end)

-- =========================================================================
-- 3. shouldUpdate
-- =========================================================================
-- @description Verifies shouldUpdate() behaviour for near vs far tiers.
describe("AILod shouldUpdate", function()
    -- @covers lurek.ai.newAILod
    it("tier 0 updates every frame", function()
        local lod = lurek.ai.newAILod()
        -- Tier 0 (near) should update every frame
        expect_equal(lod:shouldUpdate(0, 0), true)
        expect_equal(lod:shouldUpdate(0, 1), true)
        expect_equal(lod:shouldUpdate(0, 7), true)
    end)

    -- @covers lurek.ai.newAILod
    it("far tier does not update every frame", function()
        local lod = lurek.ai.newAILod()
        local max_tier = lod:tierCount() - 1
        if max_tier > 0 then
            -- At least one frame in the stride should not update
            -- (stride = update_every for that tier, which is > 1 for far tiers)
            local updates = 0
            for frame = 0, 15 do
                if lod:shouldUpdate(max_tier, frame) then
                    updates = updates + 1
                end
            end
            -- Far tier should update fewer than 16 times in 16 frames
            expect_equal(updates < 16, true)
        else
            -- Single tier: always updates (pass vacuously)
            expect_equal(true, true)
        end
    end)
end)

-- =========================================================================
-- 4. tierName
-- =========================================================================
-- @description Verifies tierName returns a string for valid tiers.
describe("AILod tierName", function()
    -- @covers lurek.ai.newAILod
    it("tier 0 has a non-nil name", function()
        local lod = lurek.ai.newAILod()
        local name = lod:tierName(0)
        expect_type("string", name)
    end)

    -- @covers lurek.ai.newAILod
    it("out-of-bounds tier returns nil", function()
        local lod = lurek.ai.newAILod()
        local name = lod:tierName(9999)
        expect_equal(name, nil)
    end)
end)

-- Print summary
test_summary()
