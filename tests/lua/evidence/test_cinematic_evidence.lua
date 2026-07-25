-- Canonical evidence file for lurek.cinematic visual artifacts.
-- @covers lurek.cinematic.new
-- @covers lurek.cinematic.newTimeline
-- @covers lurek.image.newImageData
-- @covers lurek.image.saveGIF
-- @covers lurek.image.savePNG


local OUT = evidence_output_dir("cinematic")

local FONT = {
    [" "] = { "000", "000", "000", "000", "000", "000", "000" },
    ["-"] = { "00000", "00000", "00000", "11110", "00000", "00000", "00000" },
    [":"] = { "000", "010", "000", "000", "010", "000", "000" },
    ["/"] = { "00001", "00010", "00010", "00100", "01000", "01000", "10000" },
    ["."] = { "000", "000", "000", "000", "000", "010", "000" },
    ["0"] = { "01110", "10001", "10011", "10101", "11001", "10001", "01110" },
    ["1"] = { "00100", "01100", "00100", "00100", "00100", "00100", "01110" },
    ["2"] = { "01110", "10001", "00001", "00010", "00100", "01000", "11111" },
    ["3"] = { "11110", "00001", "00001", "01110", "00001", "00001", "11110" },
    ["4"] = { "00010", "00110", "01010", "10010", "11111", "00010", "00010" },
    ["5"] = { "11111", "10000", "10000", "11110", "00001", "00001", "11110" },
    ["6"] = { "01110", "10000", "10000", "11110", "10001", "10001", "01110" },
    ["7"] = { "11111", "00001", "00010", "00100", "01000", "01000", "01000" },
    ["8"] = { "01110", "10001", "10001", "01110", "10001", "10001", "01110" },
    ["9"] = { "01110", "10001", "10001", "01111", "00001", "00001", "01110" },
    A = { "01110", "10001", "10001", "11111", "10001", "10001", "10001" },
    B = { "11110", "10001", "10001", "11110", "10001", "10001", "11110" },
    C = { "01111", "10000", "10000", "10000", "10000", "10000", "01111" },
    D = { "11110", "10001", "10001", "10001", "10001", "10001", "11110" },
    E = { "11111", "10000", "10000", "11110", "10000", "10000", "11111" },
    F = { "11111", "10000", "10000", "11110", "10000", "10000", "10000" },
    G = { "01111", "10000", "10000", "10011", "10001", "10001", "01111" },
    H = { "10001", "10001", "10001", "11111", "10001", "10001", "10001" },
    I = { "11111", "00100", "00100", "00100", "00100", "00100", "11111" },
    J = { "00111", "00010", "00010", "00010", "00010", "10010", "01100" },
    K = { "10001", "10010", "10100", "11000", "10100", "10010", "10001" },
    L = { "10000", "10000", "10000", "10000", "10000", "10000", "11111" },
    M = { "10001", "11011", "10101", "10101", "10001", "10001", "10001" },
    N = { "10001", "11001", "10101", "10011", "10001", "10001", "10001" },
    O = { "01110", "10001", "10001", "10001", "10001", "10001", "01110" },
    P = { "11110", "10001", "10001", "11110", "10000", "10000", "10000" },
    Q = { "01110", "10001", "10001", "10001", "10101", "10010", "01101" },
    R = { "11110", "10001", "10001", "11110", "10100", "10010", "10001" },
    S = { "01111", "10000", "10000", "01110", "00001", "00001", "11110" },
    T = { "11111", "00100", "00100", "00100", "00100", "00100", "00100" },
    U = { "10001", "10001", "10001", "10001", "10001", "10001", "01110" },
    V = { "10001", "10001", "10001", "10001", "10001", "01010", "00100" },
    W = { "10001", "10001", "10001", "10101", "10101", "10101", "01010" },
    X = { "10001", "10001", "01010", "00100", "01010", "10001", "10001" },
    Y = { "10001", "10001", "01010", "00100", "00100", "00100", "00100" },
    Z = { "11111", "00001", "00010", "00100", "01000", "10000", "11111" },
}

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path)
    lurek.image.saveGIF(frames, path, { delayMs = 100, speed = 10 })
    expect_evidence_created(path)
end

local function draw_text(img, text, x, y, scale, r, g, b)
    text = string.upper(tostring(text or ""))
    scale = scale or 1
    local cursor = math.floor(x)
    for i = 1, #text do
        local ch = string.sub(text, i, i)
        local glyph = FONT[ch] or FONT[" "]
        for gy = 1, #glyph do
            local row = glyph[gy]
            for gx = 1, #row do
                if string.sub(row, gx, gx) == "1" then
                    img:drawRect(cursor + (gx - 1) * scale, y + (gy - 1) * scale, scale, scale, r, g, b, 255)
                end
            end
        end
        cursor = cursor + (#glyph[1] + 1) * scale
    end
end

local function text_width(text, scale)
    return #tostring(text or "") * 6 * (scale or 1)
end

local function outline(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, 2, r, g, b, 255)
    img:drawRect(x, y + h - 2, w, 2, r, g, b, 255)
    img:drawRect(x, y, 2, h, r, g, b, 255)
    img:drawRect(x + w - 2, y, 2, h, r, g, b, 255)
end

local function new_canvas(title)
    local img = lurek.image.newImageData(820, 460)
    img:fill(15, 17, 23, 255)
    img:drawRect(18, 18, 784, 42, 31, 37, 50, 255)
    draw_text(img, title, 34, 32, 2, 235, 241, 247)
    img:drawRect(18, 78, 784, 354, 22, 25, 34, 255)
    outline(img, 18, 78, 784, 354, 78, 90, 112)
    return img
end

local function build_showcase_timeline()
    local timeline = lurek.cinematic.newTimeline()
    local clips = {
        { track = "camera", at = 0.0, duration = 1.4, type = "camera", label = "PAN", color = { 82, 150, 220 }, data = { type = "camera", x = 180, y = 30, zoom = 1.15, easing = "ease_in_out" } },
        { track = "tween", at = 0.6, duration = 1.8, type = "tween", label = "TITLE", color = { 116, 204, 146 }, data = { type = "tween", target = "title", properties = { alpha = 1.0, y = 42 }, easing = "out_quad" } },
        { track = "audio", at = 1.2, duration = 0.8, type = "audio", label = "STING", color = { 255, 204, 94 }, data = { type = "audio", path = "audio/reveal.ogg" } },
        { track = "signal", at = 2.0, duration = 0.2, type = "signal", label = "REV", color = { 232, 112, 112 }, data = { type = "signal", name = "reveal", data = "boss" } },
        { track = "camera", at = 2.4, duration = 1.2, type = "camera", label = "ZOOM", color = { 82, 150, 220 }, data = { type = "camera", x = 320, y = 90, zoom = 1.8, easing = "in_quad" } },
        { track = "signal", at = 3.6, duration = 0.4, type = "signal", label = "END", color = { 232, 112, 112 }, data = { type = "signal", name = "complete" } },
    }
    local tracks = { "camera", "tween", "audio", "signal" }
    for _, track in ipairs(tracks) do
        timeline:addTrack(track)
    end
    for _, clip in ipairs(clips) do
        timeline:addClip(clip.track, clip.at, clip.duration, clip.data)
    end
    return timeline, clips, tracks
end

local function time_to_x(t, duration)
    return 166 + math.floor((t / math.max(0.01, duration)) * 570)
end

local function draw_timeline(img, timeline, clips, tracks, playhead)
    local duration = timeline:getDuration()
    img:drawRect(148, 112, 604, 264, 28, 32, 42, 255)
    outline(img, 148, 112, 604, 264, 80, 92, 112)
    for i, track in ipairs(tracks) do
        local y = 132 + (i - 1) * 58
        draw_text(img, track, 56, y + 15, 1, 196, 208, 224)
        img:drawLine(162, y + 20, 736, y + 20, 60, 70, 88, 255)
    end
    for _, clip in ipairs(clips) do
        local lane = 1
        for i, track in ipairs(tracks) do
            if track == clip.track then lane = i end
        end
        local x = time_to_x(clip.at, duration)
        local w = math.max(12, time_to_x(clip.at + clip.duration, duration) - x)
        local y = 126 + (lane - 1) * 58
        img:drawRect(x, y, w, 30, clip.color[1], clip.color[2], clip.color[3], 255)
        outline(img, x, y, w, 30, 238, 244, 250)
        draw_text(img, clip.label, x + math.max(4, math.floor((w - text_width(clip.label, 1)) / 2)), y + 10, 1, 18, 24, 32)
    end
    for tick = 0, math.floor(duration + 0.5) do
        local x = time_to_x(tick, duration)
        img:drawLine(x, 104, x, 386, 52, 62, 78, 255)
        draw_text(img, tostring(tick), x - 4, 394, 1, 170, 184, 204)
    end
    if playhead then
        local px = time_to_x(math.max(0, math.min(duration, playhead)), duration)
        img:drawLine(px, 96, px, 386, 255, 236, 128, 255)
        img:drawCircle(px, 94, 6, 255, 236, 128, 255)
    end
end

local function draw_metric(img, x, y, label, value, max_value, color)
    max_value = math.max(1, max_value or 1)
    local fill = math.floor(160 * math.max(0, math.min(1, value / max_value)))
    draw_text(img, label, x, y, 1, 182, 194, 210)
    img:drawRect(x, y + 14, 164, 12, 42, 49, 64, 255)
    img:drawRect(x + 2, y + 16, fill, 8, color[1], color[2], color[3], 255)
    outline(img, x, y + 14, 164, 12, 92, 104, 126)
end

-- @describe evidence: cinematic
describe("evidence: cinematic", function()
    before_each(function()
        ensure_evidence_dir("cinematic")
    end)

    -- Does: Builds a modern LCinematicTimeline with camera, tween, audio, and signal clips, then draws its schedule.
    -- Shows: Multiple systems share one playhead and one duration instead of separate hand-synchronized timers.
    -- Artifact: tests/artifacts/current/cinematic/cinematic_multitrack_schedule.png
    -- Why: Cinematic owns sequencing, so the evidence must show track timing rather than sprite frames or skeleton poses.
    it("PNG: multitrack schedule", function()
        local timeline, clips, tracks = build_showcase_timeline()
        local img = new_canvas("CINEMATIC MULTITRACK")
        draw_timeline(img, timeline, clips, tracks, nil)
        draw_text(img, "DURATION " .. tostring(math.floor(timeline:getDuration() * 10) / 10), 74, 408, 1, 226, 234, 242)
        save_png(img, OUT .. "cinematic_multitrack_schedule.png")
    end)

    -- Does: Adds labels, branches to reveal, and draws the resulting playhead position on the timeline.
    -- Shows: Named labels become reactive jump points that can skip directly to a cinematic beat.
    -- Artifact: tests/artifacts/current/cinematic/cinematic_labels_branching.png
    -- Why: Branching is a cinematic timeline concern and should be visible as playhead control, not as animation playback.
    it("PNG: labels and branching", function()
        local timeline, clips, tracks = build_showcase_timeline()
        timeline:addLabel("intro", 0.0)
        timeline:addLabel("reveal", 2.0)
        timeline:addLabel("exit", 3.6)
        local ok = timeline:branch("reveal")
        local img = new_canvas("CINEMATIC LABEL BRANCH")
        draw_timeline(img, timeline, clips, tracks, timeline:getTime())
        local labels = { { "INTRO", 0.0 }, { "REVEAL", 2.0 }, { "EXIT", 3.6 } }
        for _, label in ipairs(labels) do
            local x = time_to_x(label[2], timeline:getDuration())
            img:drawCircle(x, 104, 8, 232, 112, 112, 255)
            draw_text(img, label[1], x - 22, 86, 1, 248, 236, 226)
        end
        draw_text(img, "BRANCH OK " .. tostring(ok and 1 or 0), 74, 408, 1, 226, 234, 242)
        save_png(img, OUT .. "cinematic_labels_branching.png")
    end)

    -- Does: Plays, updates, skips to end, checks completion, then stops a timeline and draws the control states.
    -- Shows: The same timeline changes state through playing, complete, and stopped with measurable time positions.
    -- Artifact: tests/artifacts/current/cinematic/cinematic_completion_controls.png
    -- Why: Playback control is the runtime behavior cinematic provides beyond static clip authoring.
    it("PNG: completion controls", function()
        local timeline = build_showcase_timeline()
        timeline:play()
        timeline:update(0.8)
        local playing_time = timeline:getTime()
        local playing_state = timeline:getState()
        timeline:skipToEnd()
        local end_time = timeline:getTime()
        local complete = timeline:isComplete()
        timeline:stop()
        local stopped_time = timeline:getTime()
        local stopped_state = timeline:getState()

        local img = new_canvas("CINEMATIC CONTROLS")
        local cards = {
            { label = "PLAY", state = playing_state, time = playing_time, color = { 82, 150, 220 } },
            { label = "SKIP END", state = complete and "complete" or "open", time = end_time, color = { 255, 204, 94 } },
            { label = "STOP", state = stopped_state, time = stopped_time, color = { 116, 204, 146 } },
        }
        for i, card in ipairs(cards) do
            local x = 86 + (i - 1) * 238
            img:drawRect(x, 136, 188, 174, card.color[1], card.color[2], card.color[3], 255)
            outline(img, x, 136, 188, 174, 238, 244, 250)
            draw_text(img, card.label, x + 32, 164, 2, 18, 24, 32)
            draw_text(img, string.upper(card.state), x + 34, 224, 1, 18, 24, 32)
            draw_text(img, "T " .. tostring(math.floor(card.time * 10) / 10), x + 62, 254, 1, 18, 24, 32)
        end
        draw_metric(img, 114, 356, "DURATION", end_time, math.max(1, end_time), { 255, 204, 94 })
        draw_metric(img, 356, 356, "COMPLETE " .. tostring(complete and 1 or 0), complete and 1 or 0, 1, { 116, 204, 146 })
        save_png(img, OUT .. "cinematic_completion_controls.png")
    end)

    -- Does: Uses the legacy LCinematic cut API, records cutCount before and after clear, and draws the cut list shape.
    -- Shows: The old cut-based surface is a compatibility path distinct from the multi-track timeline.
    -- Artifact: tests/artifacts/current/cinematic/cinematic_legacy_cut_list.png
    -- Why: The module exposes both APIs, so evidence should make the legacy cut model explicit instead of hiding it in text only.
    it("PNG: legacy cut list", function()
        local cinematic = lurek.cinematic.new()
        local cuts = {
            { time = 0.0, label = "FADE" },
            { time = 0.8, label = "PAN" },
            { time = 1.6, label = "REVEAL" },
            { time = 2.4, label = "CUT" },
        }
        for _, cut in ipairs(cuts) do
            cinematic:addCut(cut.time, cut.label)
        end
        cinematic:play()
        local before = cinematic:cutCount()
        cinematic:clear()
        local after = cinematic:cutCount()
        local img = new_canvas("CINEMATIC LEGACY CUTS")
        img:drawLine(104, 236, 716, 236, 98, 112, 136, 255)
        for i, cut in ipairs(cuts) do
            local x = 120 + (i - 1) * 166
            img:drawCircle(x, 236, 20, 232, 122, 92, 255)
            draw_text(img, tostring(i), x - 5, 229, 2, 18, 24, 32)
            draw_text(img, cut.label, x - 24, 270, 1, 228, 236, 244)
            draw_text(img, "T " .. tostring(math.floor(cut.time * 10) / 10), x - 16, 292, 1, 184, 198, 216)
        end
        draw_metric(img, 126, 360, "BEFORE " .. tostring(before), before, 4, { 232, 122, 92 })
        draw_metric(img, 390, 360, "AFTER " .. tostring(after), after, 4, { 116, 204, 146 })
        save_png(img, OUT .. "cinematic_legacy_cut_list.png")
    end)

    -- Does: Builds a reveal sequence with signal and audio clips and draws the intended event chain over time.
    -- Shows: Signal/audio clips are timed cinematic beats alongside camera/tween work, not frame animation assets.
    -- Artifact: tests/artifacts/current/cinematic/cinematic_signal_audio_sequence.png
    -- Why: This is the module-specific coordination use case from the spec: timed presentation events under one authored timeline.
    it("PNG: signal audio sequence", function()
        local timeline = lurek.cinematic.newTimeline()
        local tracks = { "signal", "audio", "camera" }
        local clips = {
            { track = "signal", at = 0.0, duration = 0.2, label = "LOCK", color = { 232, 112, 112 }, data = { type = "signal", name = "lock_input" } },
            { track = "audio", at = 0.3, duration = 0.7, label = "HIT", color = { 255, 204, 94 }, data = { type = "audio", path = "audio/hit.ogg" } },
            { track = "camera", at = 0.5, duration = 1.1, label = "SHAKE", color = { 82, 150, 220 }, data = { type = "camera", x = 20, y = 8, zoom = 1.05 } },
            { track = "signal", at = 1.7, duration = 0.2, label = "OPEN", color = { 116, 204, 146 }, data = { type = "signal", name = "unlock_input" } },
        }
        for _, track in ipairs(tracks) do timeline:addTrack(track) end
        for _, clip in ipairs(clips) do timeline:addClip(clip.track, clip.at, clip.duration, clip.data) end
        timeline:play()
        timeline:update(0.5)
        local img = new_canvas("CINEMATIC EVENT CHAIN")
        draw_timeline(img, timeline, clips, tracks, timeline:getTime())
        draw_text(img, "STATE " .. timeline:getState(), 74, 408, 1, 226, 234, 242)
        save_png(img, OUT .. "cinematic_signal_audio_sequence.png")
    end)

    -- Does: Plays a timeline, advances update/pause/seek/play control flow, and records the moving playhead as a GIF.
    -- Shows: The playhead responds to runtime controls over time, which cannot be proven by a single still frame.
    -- Artifact: tests/artifacts/current/cinematic/cinematic_playhead_controls.gif
    -- Why: Cinematic sequencing is temporal, so an animated artifact is the clearest evidence of playback behavior.
    it("GIF: playhead controls", function()
        local timeline, clips, tracks = build_showcase_timeline()
        timeline:play()
        local frames = {}
        for frame = 1, 12 do
            if frame == 5 then
                timeline:pause()
            elseif frame == 7 then
                timeline:play()
            elseif frame == 9 then
                timeline:seek(2.4)
            end
            timeline:update(0.25)
            local img = new_canvas("CINEMATIC PLAYHEAD")
            draw_timeline(img, timeline, clips, tracks, timeline:getTime())
            draw_text(img, "FRAME " .. tostring(frame), 74, 408, 1, 226, 234, 242)
            draw_text(img, "STATE " .. timeline:getState(), 562, 408, 1, 226, 234, 242)
            frames[frame] = img
        end
        save_gif(frames, OUT .. "cinematic_playhead_controls.gif")
    end)
end)

test_summary()
