-- test_animation_evidence.lua
-- Canonical evidence file for lurek.animation outputs.

local OUT = evidence_output_dir("animation")
local IMAGE_PATH = "content/examples/assets/images/sample_texture.png"

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

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function load_image()
    return lurek.render.newImage(IMAGE_PATH)
end

local function build_demo_animation()
    local anim = lurek.animation.new()
    anim:addFramesFromGrid(64, 32, 16, 16, 0, 8)
    anim:addClip("idle", { 0, 1, 2, 3 }, 4, true)
    anim:addClip("walk", { 0, 1, 2, 3, 4, 5, 6, 7 }, 10, true)
    anim:setImage(load_image())
    return anim
end

local function framed_animation_image(anim, w, h, accent)
    local frame = anim:drawToImage(w, h)
    local canvas = lurek.image.newImageData(w + 48, h + 56)
    canvas:fill(18, 20, 28, 255)
    canvas:drawRect(16, 20, w + 16, h + 16, 28, 32, 42, 255)
    canvas:paste(frame, 24, 28)
    draw_outline(canvas, 24, 28, w, h, 235, 239, 246, 255)
    canvas:drawLine(16, h + 44, w + 31, h + 44, accent[1], accent[2], accent[3], 255)
    return canvas
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
    -- Does: Runs "animator current frame render" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.animation.new and LAnimation:drawToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.animation.new and LAnimation:drawToImage; export helpers are just the container.

    it("PNG: animator current frame render", function()
        local anim = build_demo_animation()
        anim:play("walk")

        for _ = 1, 20 do
            anim:update(1 / 60)
        end

        local img = framed_animation_image(anim, 192, 96, { 110, 214, 255 })
        local path = OUT .. "animation_current_frame_walk.png"
        save_png(img, path)
    end)
    -- Does: Runs "walk clip progression over one second" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.animation.new, LAnimation:update, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.animation.new, LAnimation:update, and related owner calls; export helpers are just the container.

    it("GIF: walk clip progression over one second", function()
        local anim = build_demo_animation()
        anim:play("walk")

        local frames = {}
        for i = 1, 10 do
            anim:update(0.1)
            frames[i] = framed_animation_image(anim, 192, 96, { 255, 196, 94 })
        end

        local path = OUT .. "animation_walk_cycle_preview.gif"
        save_gif(frames, path, { delayMs = 100, speed = 10 })
    end)
    -- Does: Runs "preview grid from clip frames" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LAnimation:drawPreviewGrid without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/animation_clip_preview_grid.png
    -- Why: This is meaningful only if the visible/text output comes from LAnimation:drawPreviewGrid; export helpers are just the container.

    it("PNG: preview grid from clip frames", function()
        local anim = build_demo_animation()
        anim:play("walk")

        local grid = anim:drawPreviewGrid(4, 48)
        local canvas = lurek.image.newImageData(grid:getWidth() + 48, grid:getHeight() + 48)
        canvas:fill(16, 18, 24, 255)
        canvas:drawRect(12, 12, grid:getWidth() + 24, grid:getHeight() + 24, 26, 30, 40, 255)
        canvas:paste(grid, 24, 24)
        draw_outline(canvas, 24, 24, grid:getWidth(), grid:getHeight(), 232, 236, 244, 255)
        local path = OUT .. "animation_clip_preview_grid.png"
        save_png(canvas, path)
    end)
    -- Does: Runs "blend/crossfade state evidence" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.animation.new without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/animation_blend_crossfade_state.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.animation.new; export helpers are just the container.

    it("TXT: blend/crossfade state evidence", function()
        local anim = build_demo_animation()

        anim:play("idle")
        anim:update(0.2)
        local ok = anim:crossfade("run", 0.4)
        expect_type("boolean", ok)

        anim:update(0.1)
        local blend = anim:getBlendState()
        local info = {
            "crossfade_started=" .. tostring(ok),
            "frame_count=" .. tostring(anim:getFrameCount()),
            "clip_count=" .. tostring(anim:getClipCount()),
            "current_frame=" .. tostring(anim:getCurrentFrame()),
            "blend_active=" .. tostring(blend ~= nil),
        }

        local path = OUT .. "animation_blend_crossfade_state.txt"
        write_text(path, table.concat(info, "\n") .. "\n")
    end)
    -- Does: Runs "animation curves sampled as line plots" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.animation.newCurve, LAnimCurve:addKeyframe, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/animation_curve_comparison.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.animation.newCurve, LAnimCurve:addKeyframe, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "animation state-machine transition trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.animation.newStateMachine, LAnimStateMachine:addState, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.animation.newStateMachine, LAnimStateMachine:addState, and related owner calls; export helpers are just the container.

    it("TXT: animation state-machine transition trace", function()
        local anim = build_demo_animation()

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
    -- Does: Runs "animation contact sheet" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LAnimation:drawPreviewGrid and LAnimation:drawToImage without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/animation_contact_sheet.png
    -- Why: This is meaningful only if the visible/text output comes from LAnimation:drawPreviewGrid and LAnimation:drawToImage; export helpers are just the container.

    it("PNG: animation contact sheet", function()
        local anim = build_demo_animation()
        anim:play("walk")
        anim:update(0.2)

        local current = framed_animation_image(anim, 192, 96, { 122, 214, 255 })
        local preview = anim:drawPreviewGrid(4, 40)
        local canvas = lurek.image.newImageData(560, 320)
        canvas:fill(14, 16, 22, 255)
        canvas:paste(current, 24, 24)
        canvas:paste(preview, 280, 36)
        draw_outline(canvas, 280, 36, preview:getWidth(), preview:getHeight(), 232, 236, 244, 255)

        local curve = lurek.animation.newCurve()
        curve:addKeyframe(0.0, 0.0)
        curve:addKeyframe(0.4, 0.8)
        curve:addKeyframe(1.0, 0.2)
        curve:setEasing("ease_in_out")
        canvas:drawRect(24, 180, 512, 112, 24, 28, 38, 255)
        draw_outline(canvas, 24, 180, 512, 112, 232, 236, 244, 255)
        draw_curve(canvas, curve, 40, 196, 476, 80, 255, 188, 96)

        local path = OUT .. "animation_contact_sheet.png"
        save_png(canvas, path)
    end)
    -- Does: Runs "animation clip control trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LAnimation:addClip, LAnimation:addClipFromGrid, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/animation/animation_clip_control_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LAnimation:addClip, LAnimation:addClipFromGrid, and related owner calls; export helpers are just the container.

    it("TXT: animation clip control trace", function()
        local anim = lurek.animation.new()
        anim:addFrame(0, 0, 16, 16)
        anim:addFramesFromRects({
            { x = 16, y = 0, w = 16, h = 16 },
            { x = 32, y = 0, w = 16, h = 16 },
        })
        anim:addClipFromGrid("grid", 0, 0, 16, 16, 4, 1, 8, true)
        anim:addClip("manual", { 0, 1, 2 }, 6, false)
        anim:setImage(load_image())
        anim:play("manual")
        anim:setClipMode("manual", "forward")
        anim:setSpeed(1.25)
        anim:update(0.2)
        anim:setFrame(2)
        anim:pause()
        local paused_playing = anim:isPlaying()
        anim:resume()
        local resumed_playing = anim:isPlaying()
        local events = anim:pollEvents() or {}
        local lines = {
            "clip_count=" .. tostring(anim:getClipCount()),
            "manual_mode=" .. tostring(anim:getClipMode("manual")),
            "speed=" .. tostring(anim:getSpeed()),
            "current_frame=" .. tostring(anim:getCurrentFrame()),
            "paused_playing=" .. tostring(paused_playing),
            "resumed_playing=" .. tostring(resumed_playing),
            "manual_looping=" .. tostring(anim:isLooping()),
            "event_count=" .. tostring(#events),
            "clip_present=" .. tostring(anim:getClip("manual") ~= nil),
        }
        anim:stop()
        lines[#lines + 1] = "after_stop_playing=" .. tostring(anim:isPlaying())
        write_text(OUT .. "animation_clip_control_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
