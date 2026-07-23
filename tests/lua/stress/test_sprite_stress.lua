-- Bounded workload coverage for sprite sheets, atlas packing, and animator catch-up.

local function max_sheet() return lurek.sprite.newSheet(256, 256, 1, 1) end
local function full_packer() return lurek.sprite.newAtlasPacker(64, 64, 0) end
local function capped_animator()
    local animator = lurek.sprite.newAnimator({ loop = { row = 1, from = 1, to = 2, fps = 1000, loop = true } })
    local events = { count = 0 }
    animator:onFrame(function() events.count = events.count + 1 end)
    animator:play("loop")
    return animator, events
end

-- @describe sprite bounded workloads
describe("sprite bounded workloads", function()
    -- @stress LSpriteSheet:getFrameCount
    it("reports the supported frame ceiling", function()
        local sheet = max_sheet()
        expect_equal(65536, sheet:getFrameCount())
    end)

    -- @stress LSpriteSheet:getFrame
    it("looks up the final frame at the supported ceiling", function()
        local sheet = max_sheet()
        expect_type("table", sheet:getFrame(65536))
    end)

    -- @stress LAtlasPacker:pack
    it("packs deterministic named regions until capacity is exhausted", function()
        local packer = full_packer()
        for i = 1, 16 do
            expect_true(packer:pack("region_" .. i, 16, 16))
        end
        local packed, reason = packer:pack("full", 16, 16)
        expect_false(packed)
        expect_equal("full", reason)
    end)

    -- @stress LSpriteAnimator:update
    it("caps huge-delta callback work", function()
        local animator, events = capped_animator()
        animator:update(1000000)
        expect_true(events.count <= 256)
    end)
end)

test_summary()
