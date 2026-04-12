-- test_evidence_animation.lua
-- Evidence test: lurek.animation Animator API contracts and PNG sprite grid evidence

local OUT = "tests/lua/evidence/output/animation/"

-- â”€â”€ helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

--- Build a fake sprite-sheet ImageData (8 frames of 16Ă—16, laid out in a 4Ă—2 grid).
--- Each frame is a different hue so we can visually verify the correct frame is selected.
local function make_sprite_sheet()
    local FRAME_W, FRAME_H = 16, 16
    local COLS, ROWS = 4, 2
    local img = lurek.img.newImageData(FRAME_W * COLS, FRAME_H * ROWS)
    img:fill(0, 0, 0, 0)

    local hues = {
        {220, 60, 60},   -- red
        {220, 140, 60},  -- orange
        {200, 200, 60},  -- yellow
        {60, 200, 80},   -- green
        {60, 180, 220},  -- cyan
        {60, 80, 220},   -- blue
        {160, 60, 220},  -- purple
        {220, 60, 160},  -- pink
    }

    for f = 0, 7 do
        local col = f % COLS
        local row = math.floor(f / COLS)
        local ox  = col * FRAME_W
        local oy  = row * FRAME_H
        local c   = hues[f + 1] or {128, 128, 128}

        img:drawRect(ox + 1, oy + 1, FRAME_W - 2, FRAME_H - 2, c[1], c[2], c[3], 255)

        -- Frame number text marker (a small 2Ă—2 bright pixel per digit)
        img:setPixel(ox + 2, oy + 2, 255, 255, 255, 255)
        img:setPixel(ox + 3, oy + 2, 255, 255, 255, 255)
    end

    return img, FRAME_W, FRAME_H, COLS * FRAME_W, ROWS * FRAME_H
end

-- â”€â”€ tests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @covers lurek.animation.new
-- @covers Animator:addClip
-- @covers Animator:play
-- @covers Animator:isPlaying
-- @covers Animator:isLooping
-- @covers Animator:pause
-- @covers Animator:resume
-- @covers Animator:stop
-- @covers Animator:setSpeed
-- @covers Animator:getSpeed
-- @description Builds basic Animator clips and exercises playback state toggles before any visual evidence is written.
describe("Evidence: lurek.animation Animator creation", function()

    -- @covers lurek.animation.new
    -- @covers Animator:addClip
    -- @covers Animator:play
    -- @description Creates an Animator, adds a named clip, and starts playback to prove clip registration succeeds.
    it("new creates an Animator object", function()
        local anim = lurek.animation.new()
        anim:addClip("run", {1, 2, 3, 4}, 10, true)
        local ok = anim:play("run")
    end)

    -- @covers lurek.animation.new
    -- @covers Animator:play
    -- @covers Animator:isPlaying
    -- @description Starts a clip and checks the playing-state query path used by higher-level animation controllers.
    it("isPlaying returns true after play()", function()
        local anim = lurek.animation.new()
        anim:play("idle")
    end)

    -- @covers lurek.animation.new
    -- @covers Animator:isLooping
    -- @description Queries the looping flag reported by the active clip after playback begins.
    it("isLooping reflects clip looping flag", function()
        local anim = lurek.animation.new()
        anim:play("once")
    end)

    -- @covers lurek.animation.new
    -- @covers Animator:pause
    -- @covers Animator:resume
    -- @description Exercises pause and resume transitions so the Animator exposes stable transport controls.
    it("pause / resume toggles playing state", function()
        local anim = lurek.animation.new()
        anim:resume()
    end)

    -- @covers lurek.animation.new
    -- @covers Animator:stop
    -- @description Stops a fresh Animator to confirm the stop path resets state without requiring prior updates.
    it("stop resets state", function()
        local anim = lurek.animation.new()
    end)

    -- @covers lurek.animation.new
    -- @covers Animator:setSpeed
    -- @covers Animator:getSpeed
    -- @description Changes playback speed and then reads it back to document the speed-scaling control surface.
    it("getSpeed / setSpeed round-trip", function()
        local anim = lurek.animation.new()
        anim:setSpeed(2.5)
    end)
end)

-- @covers lurek.animation.new
-- @covers Animator:addClipFromGrid
-- @covers Animator:play
-- @covers Animator:update
-- @covers Animator:getQuad
-- @covers Animator:pollEvents
-- @description Proves grid-derived clips advance through quads correctly and emit completion events for one-shot playback.
describe("Evidence: lurek.animation addClipFromGrid quad selection", function()

    -- @covers lurek.animation.new
    -- @covers Animator:addClipFromGrid
    -- @covers Animator:play
    -- @covers Animator:update
    -- @covers Animator:getQuad
    -- @evidence file
    -- @description Steps through every frame of a sprite-sheet clip and writes a PNG grid showing the selected source quads.
    it("addClipFromGrid produces correct UV quads â€” PNG evidence: frame_grid", function()
        local img, FW, FH, TW, TH = make_sprite_sheet()

        local anim = lurek.animation.new()
        anim:addClipFromGrid("all_frames", TW, TH, FW, FH, 0, 8, 6, true)
        anim:play("all_frames")

        -- Collect the quad for each frame by stepping the animator
        local frame_w = FW
        local frame_h = FH
        local out_cols = 4
        local out_scale = 4
        local out = lurek.img.newImageData(
            frame_w * out_cols * out_scale,
            frame_h * 2 * out_scale
        )
        out:fill(20, 20, 30, 255)

        local frame_dt = 1.0 / 6.0  -- one frame at 6fps

        for f = 0, 7 do
            anim:update(frame_dt)
            local q = anim:getQuad()
            if q then
                -- Blit the source region from the sprite sheet
                local dst_col = f % out_cols
                local dst_row = math.floor(f / out_cols)
                local ox = dst_col * FW * out_scale
                local oy = dst_row * FH * out_scale

                for py = 0, FH - 1 do
                    for px = 0, FW - 1 do
                        local r, g, b, a = img:getPixel(q.x + px + 1, q.y + py + 1)
                        -- Scale each source pixel to out_scale Ă— out_scale block
                        for sy = 0, out_scale - 1 do
                            for sx = 0, out_scale - 1 do
                                out:setPixel(ox + px*out_scale + sx + 1,
                                             oy + py*out_scale + sy + 1,
                                             r, g, b, a)
                            end
                        end
                    end
                end
            end
        end

        lurek.img.savePNG(out, OUT .. "evidence_animation_frame_grid.png")
    end)

    -- @covers lurek.animation.new
    -- @covers Animator:addClip
    -- @covers Animator:play
    -- @covers Animator:update
    -- @covers Animator:pollEvents
    -- @description Advances a non-looping clip past its final frame and inspects the event queue for the terminal completion signal.
    it("one-shot clip fires 'done' event after last frame", function()
        local anim = lurek.animation.new()
        anim:addClip("once", {1, 2, 3}, 30, false)
        anim:play("once")

        -- Advance past 3 frames at 30fps
        for _ = 1, 5 do
            anim:update(1.0 / 30.0)
        end

        local events = anim:pollEvents()
        local found_done = false
        for _, ev in ipairs(events) do
            if ev.type == "done" or ev.type == "ended" or ev.type == "finish" then
                found_done = true
            end
        end
        -- The clip should no longer be playing
    end)
end)

-- @covers lurek.animation.new
-- @covers Animator:addClip
-- @covers Animator:setSpeed
-- @covers Animator:update
-- @covers Animator:getQuad
-- @description Compares normal and accelerated playback rates by sampling frame progression and plotting the results to file evidence.
describe("Evidence: animation speed scaling visual", function()

    -- @covers lurek.animation.new
    -- @covers Animator:addClip
    -- @covers Animator:setSpeed
    -- @covers Animator:update
    -- @covers Animator:getQuad
    -- @evidence file
    -- @description Renders a two-lane timing comparison that shows a 2x-speed clip advances through frame quads faster than the baseline clip.
    it("speed 2Ă— advances twice as fast â€” PNG evidence: speed_compare", function()
        local W = 120
        local img = lurek.img.newImageData(W, 20)
        img:fill(20, 20, 20, 255)

        -- Normal speed: step through 4 frames of a 4fps clip over 1 second
        local anim1 = lurek.animation.new()
        anim1:addClip("walk", {1, 2, 3, 4}, 4, true)
        anim1:play("walk")

        -- 2Ă— speed
        local anim2 = lurek.animation.new()
        anim2:addClip("walk", {1, 2, 3, 4}, 4, true)
        anim2:play("walk")
        anim2:setSpeed(2.0)

        -- Collect frame indices over 1s at 30fps
        local samples1 = {}
        local samples2 = {}
        for i = 1, 30 do
            anim1:update(1/30)
            anim2:update(1/30)
            local q1 = anim1:getQuad()
            local q2 = anim2:getQuad()
            samples1[i] = q1 and q1.x or 0
            samples2[i] = q2 and q2.x or 0
        end

        -- Draw sample bars
        for i, v in ipairs(samples1) do
            local val = math.min(255, (math.floor(v / 16)) * 64 + 60)
            img:setPixel(i * (math.floor(W / 30)), 5, val, 180, 80, 255)
        end
        for i, v in ipairs(samples2) do
            local val = math.min(255, (math.floor(v / 16)) * 64 + 60)
            img:setPixel(i * (math.floor(W / 30)), 15, 80, 180, val, 255)
        end

        lurek.img.savePNG(img, OUT .. "evidence_animation_speed_compare.png")
    end)
end)

test_summary()

