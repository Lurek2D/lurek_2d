-- Evidence tests: animation module
-- Artifacts are generated from lurek.animation APIs.


local OUT = "tests/output/animation/"

-- @describe Evidence: lurek.animation API
describe("Evidence: lurek.animation API", function()
    before_each(function()
        ensure_evidence_dir("animation")
    end)

    -- @evidence file
    it("PNG: animator current frame render", function()
        local anim = lurek.animation.new()
        anim:addClip("walk", { 1, 2, 3, 4, 5, 6, 7, 8 }, 8, true)
        anim:play("walk")

        for _ = 1, 20 do
            anim:update(1 / 60)
        end

        local img = anim:drawToImage(192, 96)
        local path = OUT .. "animation_frame.png"
        lurek.image.savePNG(img, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("PNG: preview grid from clip frames", function()
        local anim = lurek.animation.new()
        anim:addClip("idle", { 1, 2, 3, 4, 5, 6 }, 6, true)
        anim:play("idle")

        local grid = anim:drawPreviewGrid(3, 32)
        local path = OUT .. "animation_preview_grid.png"
        lurek.image.savePNG(grid, path)
        expect_evidence_created(path)
    end)

    -- @evidence file
    it("TXT: blend/crossfade state evidence", function()
        local anim = lurek.animation.new()
        anim:addClip("idle", { 1, 2, 3, 4 }, 4, true)
        anim:addClip("run", { 5, 6, 7, 8 }, 8, true)

        anim:play("idle")
        anim:update(0.2)
        local ok = anim:crossfade("run", 0.4)
        expect_true(ok)

        anim:update(0.1)
        local blend = anim:getBlendState()
        local info = {
            "frame_count=" .. tostring(anim:getFrameCount()),
            "clip_count=" .. tostring(anim:getClipCount()),
            "current_frame=" .. tostring(anim:getCurrentFrame()),
            "blend_active=" .. tostring(blend ~= nil),
        }

        local path = OUT .. "animation_blend_state.txt"
        write_file(path, table.concat(info, "\n") .. "\n")
        expect_evidence_created(path)
    end)
end)

test_summary()
