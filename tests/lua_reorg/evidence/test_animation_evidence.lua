-- test_animation_evidence.lua
-- Canonical evidence file for lurek.animation outputs.

local OUT = evidence_output_dir("animation")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options)
    expect_evidence_created(path)
end

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function draw_curve(img, curve, ox, oy, w, h, r, g, b)
    local prev_x, prev_y = nil, nil
    for i = 0, w - 1 do
        local t = i / math.max(1, w - 1)
        local value = curve:eval(t)
        local px = ox + i
        local py = oy + h - 1 - math.floor(math.max(0, math.min(1, value)) * (h - 1) + 0.5)
        if prev_x then
            img:drawLine(prev_x, prev_y, px, py, r, g, b, 255)
        end
        prev_x, prev_y = px, py
    end
end

-- @describe Evidence: lurek.animation API
describe("Evidence: lurek.animation API", function()
    before_each(function()
        ensure_evidence_dir("animation")
    end)

    -- @evidence lurek.animation.new
    -- @evidence LAnimation:drawToImage
    -- @evidence lurek.image.savePNG
    it("PNG: animator current frame render", function()
        local anim = lurek.animation.new()
        anim:addClip("walk", { 1, 2, 3, 4, 5, 6, 7, 8 }, 8, true)
        anim:play("walk")

        for _ = 1, 20 do
            anim:update(1 / 60)
        end

        local img = anim:drawToImage(192, 96)
        local path = OUT .. "animation_current_frame_walk.png"
        save_png(img, path)
    end)

    -- @evidence lurek.animation.new
    -- @evidence LAnimation:update
    -- @evidence LAnimation:drawToImage
    -- @evidence lurek.image.saveGIF
    it("GIF: walk clip progression over one second", function()
        local anim = lurek.animation.new()
        anim:addClip("walk", { 1, 2, 3, 4, 5, 6 }, 10, true)
        anim:play("walk")

        local frames = {}
        for i = 1, 10 do
            anim:update(0.1)
            frames[i] = anim:drawToImage(192, 96)
        end

        local path = OUT .. "animation_walk_cycle_preview.gif"
        save_gif(frames, path, { delayMs = 100, speed = 10 })
    end)

    -- @evidence LAnimation:drawPreviewGrid
    -- @evidence lurek.image.savePNG
    it("PNG: preview grid from clip frames", function()
        local anim = lurek.animation.new()
        anim:addClip("idle", { 1, 2, 3, 4, 5, 6 }, 6, true)
        anim:play("idle")

        local grid = anim:drawPreviewGrid(3, 32)
        local path = OUT .. "animation_clip_preview_grid.png"
        save_png(grid, path)
    end)

    -- @evidence lurek.animation.new
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

        local path = OUT .. "animation_blend_crossfade_state.txt"
        write_text(path, table.concat(info, "\n") .. "\n")
    end)

    -- @evidence lurek.animation.newCurve
    -- @evidence LAnimCurve:addKeyframe
    -- @evidence LAnimCurve:setEasing
    -- @evidence LAnimCurve:eval
    -- @evidence lurek.image.savePNG
    it("PNG: animation curves sampled as line plots", function()
        local linear = lurek.animation.newCurve()
        linear:addKeyframe(0.0, 0.0)
        linear:addKeyframe(1.0, 1.0)

        local eased = lurek.animation.newCurve()
        eased:addKeyframe(0.0, 0.0)
        eased:addKeyframe(1.0, 1.0)
        eased:setEasing("ease_in_out")

        local img = lurek.image.newImageData(256, 160)
        img:fill(14, 16, 20, 255)
        img:drawRect(20, 20, 216, 120, 70, 78, 92, 255)
        draw_curve(img, linear, 20, 20, 216, 120, 120, 210, 255)
        draw_curve(img, eased, 20, 20, 216, 120, 255, 180, 90)

        local path = OUT .. "animation_curve_comparison.png"
        save_png(img, path)
    end)

    -- @evidence lurek.animation.newStateMachine
    -- @evidence LAnimStateMachine:addState
    -- @evidence LAnimStateMachine:addTransition
    -- @evidence LAnimStateMachine:setParam
    -- @evidence LAnimStateMachine:update
    it("TXT: animation state-machine transition trace", function()
        local anim = lurek.animation.new()
        anim:addFrame(0, 0, 16, 16)
        anim:addFrame(16, 0, 16, 16)
        anim:addClip("idle", { 0 }, 2, true)
        anim:addClip("run", { 1 }, 8, true)

        local sm = lurek.animation.newStateMachine(anim, "idle")
        sm:addState("idle", "idle", true)
        sm:addState("run", "run", true)
        sm:addTransition("idle", "run", "speed > 0.1")
        sm:addTransition("run", "idle", "speed <= 0.1")

        local speeds = { 0.0, 0.0, 0.5, 1.0, 1.0, 0.0, 0.0 }
        local lines = {}
        for i, speed in ipairs(speeds) do
            sm:setParam("speed", speed)
            sm:update(0.2)
            lines[#lines + 1] = string.format("step=%d speed=%.2f state=%s", i, speed, tostring(sm:getState()))
        end

        local path = OUT .. "animation_state_machine_transition_trace.txt"
        write_text(path, table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
