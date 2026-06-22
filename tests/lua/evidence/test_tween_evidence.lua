-- test_tween_evidence.lua
-- Canonical evidence file for lurek.tween visual and trace outputs.

local OUT = evidence_output_dir("tween")

local EASINGS = {
    { "linear", 255, 102, 102 },
    { "inQuad", 255, 153, 84 },
    { "outQuad", 255, 214, 92 },
    { "inOutQuad", 146, 232, 100 },
    { "inCubic", 92, 235, 152 },
    { "outCubic", 86, 220, 225 },
    { "inOutCubic", 92, 168, 255 },
    { "inSine", 140, 120, 255 },
    { "outSine", 190, 110, 255 },
    { "inOutSine", 255, 110, 214 },
    { "inExpo", 255, 132, 176 },
    { "outExpo", 208, 208, 218 },
}

local DIGITS = {
    ["0"] = {
        "111",
        "101",
        "101",
        "101",
        "111",
    },
    ["1"] = {
        "010",
        "110",
        "010",
        "010",
        "111",
    },
    ["2"] = {
        "111",
        "001",
        "111",
        "100",
        "111",
    },
    ["3"] = {
        "111",
        "001",
        "111",
        "001",
        "111",
    },
    ["4"] = {
        "101",
        "101",
        "111",
        "001",
        "001",
    },
    ["5"] = {
        "111",
        "100",
        "111",
        "001",
        "111",
    },
    ["6"] = {
        "111",
        "100",
        "111",
        "101",
        "111",
    },
    ["7"] = {
        "111",
        "001",
        "001",
        "001",
        "001",
    },
    ["8"] = {
        "111",
        "101",
        "111",
        "101",
        "111",
    },
    ["9"] = {
        "111",
        "101",
        "111",
        "001",
        "111",
    },
}

local function save_png(img, path)
    lurek.image.savePNG(img, path)
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

local function clamp255(v)
    if v < 0 then
        return 0
    end
    if v > 255 then
        return 255
    end
    return math.floor(v + 0.5)
end

local function sample_easing_curve(name, duration, steps)
    lurek.tween.cancelAll()

    local probe = { x = 0.0 }
    local tween = lurek.tween.to(probe, { x = 1.0 }, duration, name)
    local samples = { 0.0 }
    local active_peak = lurek.tween.getActiveCount()
    local dt = duration / steps

    for _ = 1, steps do
        lurek.tween.update(dt)
        samples[#samples + 1] = probe.x
        local active_now = lurek.tween.getActiveCount()
        if active_now > active_peak then
            active_peak = active_now
        end
    end

    return {
        samples = samples,
        quarter = samples[math.floor(steps * 0.25) + 1] or 0.0,
        half = samples[math.floor(steps * 0.5) + 1] or 0.0,
        three_quarter = samples[math.floor(steps * 0.75) + 1] or 0.0,
        final = probe.x,
        final_active = lurek.tween.getActiveCount(),
        tween_active = tween:isActive(),
        peak_active = active_peak,
    }
end

local function draw_digit(img, digit, x, y, scale, r, g, b, a)
    local glyph = DIGITS[digit]
    if not glyph then
        return
    end

    for row = 1, #glyph do
        local line = glyph[row]
        for col = 1, #line do
            if line:sub(col, col) == "1" then
                img:drawRect(
                    x + (col - 1) * scale,
                    y + (row - 1) * scale,
                    scale,
                    scale,
                    r,
                    g,
                    b,
                    a
                )
            end
        end
    end
end

local function draw_index(img, index, x, y, r, g, b, a)
    local text = string.format("%02d", index)
    draw_digit(img, text:sub(1, 1), x, y, 3, r, g, b, a)
    draw_digit(img, text:sub(2, 2), x + 12, y, 3, r, g, b, a)
end

local function draw_curve_card(img, card_x, card_y, card_w, card_h, index, sample, color)
    local r, g, b = color[1], color[2], color[3]
    local inner_x = card_x + 20
    local inner_y = card_y + 18
    local inner_w = card_w - 38
    local inner_h = card_h - 34

    img:drawRect(card_x, card_y, card_w, card_h, 26, 30, 40, 255)
    draw_outline(img, card_x, card_y, card_w, card_h, 78, 88, 108, 255)
    draw_index(img, index, card_x + 10, card_y + 8, 230, 236, 245, 255)

    for gx = 0, 4 do
        local x = inner_x + math.floor(inner_w * gx / 4 + 0.5)
        img:drawLine(x, inner_y, x, inner_y + inner_h, 56, 62, 76, 255)
    end
    for gy = 0, 4 do
        local y = inner_y + math.floor(inner_h * gy / 4 + 0.5)
        img:drawLine(inner_x, y, inner_x + inner_w, y, 56, 62, 76, 255)
    end

    img:drawLine(inner_x, inner_y + inner_h, inner_x + inner_w, inner_y, 84, 92, 108, 255)

    local previous_x = nil
    local previous_y = nil
    for i = 1, #sample.samples do
        local progress = (i - 1) / (#sample.samples - 1)
        local value = sample.samples[i]
        local px = inner_x + math.floor(progress * inner_w + 0.5)
        local py = inner_y + inner_h - math.floor(value * inner_h + 0.5)

        if previous_x ~= nil and previous_y ~= nil then
            img:drawLine(previous_x, previous_y, px, py, r, g, b, 255)
        end
        previous_x = px
        previous_y = py
    end

    local checkpoints = {
        sample.quarter,
        sample.half,
        sample.three_quarter,
        sample.final,
    }
    local checkpoint_colors = {
        { clamp255(r + 16), clamp255(g + 16), clamp255(b + 16) },
        { 255, 255, 255 },
        { clamp255(r + 8), clamp255(g + 8), clamp255(b + 8) },
        { 255, 244, 196 },
    }
    local checkpoint_progress = { 0.25, 0.5, 0.75, 1.0 }
    for i = 1, #checkpoints do
        local px = inner_x + math.floor(checkpoint_progress[i] * inner_w + 0.5)
        local py = inner_y + inner_h - math.floor(checkpoints[i] * inner_h + 0.5)
        local cc = checkpoint_colors[i]
        img:drawCircle(px, py, 3, cc[1], cc[2], cc[3], 255)
    end
end

-- @describe Evidence: lurek.tween showcase-derived artifacts
describe("Evidence: lurek.tween showcase-derived artifacts", function()
    before_each(function()
        ensure_evidence_dir("tween")
        lurek.tween.cancelAll()
    end)

    -- Does: Rebuilds the old tween showcase as standalone easing artifacts sampled from real lurek.tween interpolation.
    -- Shows: Each PNG+TXT pair should let a reviewer inspect one built-in easing mode instead of collapsing all modes into one gallery.
    -- Artifact: tests/artifacts/current/tween/tween_easing_linear.png, tests/artifacts/current/tween/tween_easing_linear.txt, tests/artifacts/current/tween/tween_easing_inQuad.png, tests/artifacts/current/tween/tween_easing_inQuad.txt, tests/artifacts/current/tween/tween_easing_outQuad.png, tests/artifacts/current/tween/tween_easing_outQuad.txt, tests/artifacts/current/tween/tween_easing_inOutQuad.png, tests/artifacts/current/tween/tween_easing_inOutQuad.txt, tests/artifacts/current/tween/tween_easing_inCubic.png, tests/artifacts/current/tween/tween_easing_inCubic.txt, tests/artifacts/current/tween/tween_easing_outCubic.png, tests/artifacts/current/tween/tween_easing_outCubic.txt, tests/artifacts/current/tween/tween_easing_inOutCubic.png, tests/artifacts/current/tween/tween_easing_inOutCubic.txt, tests/artifacts/current/tween/tween_easing_inSine.png, tests/artifacts/current/tween/tween_easing_inSine.txt, tests/artifacts/current/tween/tween_easing_outSine.png, tests/artifacts/current/tween/tween_easing_outSine.txt, tests/artifacts/current/tween/tween_easing_inOutSine.png, tests/artifacts/current/tween/tween_easing_inOutSine.txt, tests/artifacts/current/tween/tween_easing_inExpo.png, tests/artifacts/current/tween/tween_easing_inExpo.txt, tests/artifacts/current/tween/tween_easing_outExpo.png, tests/artifacts/current/tween/tween_easing_outExpo.txt
    -- Why: This is meaningful because every plotted point comes from lurek.tween.to, lurek.tween.update, and lurek.tween.getActiveCount rather than from a handwritten math approximation.

    it("PNG+TXT: tween easing standalone artifacts", function()
        local samples = {}
        for i, easing in ipairs(EASINGS) do
            samples[i] = sample_easing_curve(easing[1], 1.0, 64)
        end
        lurek.tween.cancelAll()
        for i, easing in ipairs(EASINGS) do
            local sample = samples[i]
            local img = lurek.image.newImageData(320, 180)
            img:fill(12, 15, 22, 255)
            draw_curve_card(img, 20, 18, 280, 145, i, sample, { easing[2], easing[3], easing[4] })
            save_png(img, OUT .. "tween_easing_" .. easing[1] .. ".png")

            local lines = {
                "duration=1.0",
                "steps=64",
                string.format(
                "%02d %s q25=%.4f q50=%.4f q75=%.4f q100=%.4f peak_active=%d final_active=%d tween_active=%s",
                i,
                easing[1],
                sample.quarter,
                sample.half,
                sample.three_quarter,
                sample.final,
                sample.peak_active,
                sample.final_active,
                tostring(sample.tween_active)
                )
            }
            write_text(OUT .. "tween_easing_" .. easing[1] .. ".txt", table.concat(lines, "\n") .. "\n")
        end
    end)

    -- Does: Captures the pause, hold, resume, and replay behavior that made the original tween showcase interactive.
    -- Shows: The text artifact should show that paused progress freezes under update calls, then resumes and can be recreated from scratch for manual replay.
    -- Artifact: tests/artifacts/current/tween/tween_pause_resume_scrub_trace.txt
    -- Why: This is meaningful because the trace is assembled from live LTween:pause, LTween:resume, LTween:getProgress, and lurek.tween.update behavior rather than from a fixed expected transcript.

    it("TXT: tween_pause_resume_scrub_trace.txt -- pause, hold, resume, and replay trace", function()
        local probe = { x = 0.0 }
        local tween = lurek.tween.to(probe, { x = 100.0 }, 1.0, "outQuad")

        lurek.tween.update(0.25)
        local before_pause_value = probe.x
        local before_pause_progress = tween:getProgress()

        tween:pause()
        lurek.tween.update(0.30)
        local held_value = probe.x
        local held_progress = tween:getProgress()

        tween:resume()
        lurek.tween.update(0.25)
        local resumed_value = probe.x
        local resumed_progress = tween:getProgress()
        local resumed_active = lurek.tween.getActiveCount()

        expect_near(before_pause_value, held_value, 0.0001)
        expect_near(before_pause_progress, held_progress, 0.0001)

        lurek.tween.cancelAll()
        local replay_probe = { x = 0.0 }
        local replay_tween = lurek.tween.to(replay_probe, { x = 100.0 }, 1.0, "outQuad")
        lurek.tween.update(0.10)

        local lines = {
            string.format("before_pause value=%.4f progress=%.4f", before_pause_value, before_pause_progress),
            string.format("held value=%.4f progress=%.4f", held_value, held_progress),
            string.format("resumed value=%.4f progress=%.4f active_count=%d", resumed_value, resumed_progress, resumed_active),
            string.format("replay value=%.4f progress=%.4f active=%s", replay_probe.x, replay_tween:getProgress(), tostring(replay_tween:isActive())),
        }
        write_text(OUT .. "tween_pause_resume_scrub_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
