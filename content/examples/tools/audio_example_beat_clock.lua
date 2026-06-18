--[[
    example_beat_clock.lua
    Demonstrates lurek.audio.newBeatClock for rhythm-game timing:
    - BPM tracking and beat/bar position
    - Tap-tempo estimation
    - Beat scheduling and drainFired
    - Quantisation

    API used:
      lurek.audio.newBeatClock(bpm, beats_per_bar?)
        :start() / :stop() / :reset()
        :tick(dt)               -> beat-crossing array
        :position()             -> {beat, bar, beat_in_bar, phase}
        :bpm() / :setBpm(bpm)
        :beatsPerBar() / :setBeatsPerBar(n)
        :tap(wall_time_secs)    -> estimated_bpm
        :scheduleAt(beat)       -> bool
        :drainFired()           -> array of fired beats
        :secondsPerBeat()       -> number
        :secondsToNextBeat()    -> number
        :isRunning()            -> bool
        :quantise(beat, grid)   -> number
--]]

-- ── 1. Basic position tracking at 120 BPM ────────────────────────────────────

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

local bc = lurek.audio.newBeatClock(120.0, 4)
bc:start()

example_print_log("=== Position tracking at 120 BPM (4/4 time) ===")
local t = 0
local step = 1/8  -- simulate 8 steps per second
for i = 1, 24 do
    t = t + step
    local crossings = bc:tick(step)
    if #crossings > 0 then
        local pos = bc:position()
        example_print_log(string.format("  t=%.2fs  beat=%.2f  bar=%d  beat_in_bar=%d",
            t, pos.beat, pos.bar, pos.beat_in_bar))
    end
end

-- ── 2. Seconds-per-beat info ──────────────────────────────────────────────────

example_print_log(string.format("\n120 BPM: %.4f sec/beat", bc:secondsPerBeat()))
bc:setBpm(180.0)
example_print_log(string.format("180 BPM: %.4f sec/beat", bc:secondsPerBeat()))
bc:setBpm(120.0)

-- ── 3. Beat scheduling ────────────────────────────────────────────────────────

bc:reset()
bc:start()

example_print_log("\n=== Scheduled beat events ===")
bc:scheduleAt(1.0)
bc:scheduleAt(2.0)
bc:scheduleAt(3.0)

t = 0
local accum = 0
local fired_total = 0
for i = 1, 50 do
    local dt = 1/30
    t = t + dt
    bc:tick(dt)
    local fired = bc:drainFired()
    if #fired > 0 then
        for _, beat in ipairs(fired) do
            fired_total = fired_total + 1
            example_print_log(string.format("  EVENT  beat=%.1f  fired at t=%.3fs", beat, t))
        end
    end
end
example_print_log(string.format("  Total events fired: %d (expected 3)", fired_total))

-- ── 4. Tap-tempo estimation ───────────────────────────────────────────────────

example_print_log("\n=== Tap-tempo (simulating 140 BPM taps) ===")
local tap_clock = lurek.audio.newBeatClock(120.0)
local spb = 60.0 / 140.0  -- 140 bpm spacing
local tap_times = { 0.0, spb, spb*2, spb*3, spb*4 }
local last_bpm = 0
for _, ts in ipairs(tap_times) do
    last_bpm = tap_clock:tap(ts)
end
example_print_log(string.format("  Estimated BPM: %.1f  (expected ~140)", last_bpm))

-- ── 5. Quantisation ───────────────────────────────────────────────────────────

example_print_log("\n=== Quantisation ===")
local q = tap_clock:quantise(1.3, 0.25)
example_print_log(string.format("  beat 1.3 quantised to 1/4-beat grid = %.2f", q))
q = tap_clock:quantise(2.7, 0.5)
example_print_log(string.format("  beat 2.7 quantised to 1/2-beat grid = %.2f", q))

-- ── 6. 3/4 waltz time ────────────────────────────────────────────────────────

example_print_log("\n=== Waltz (3/4 time) at 90 BPM ===")
local waltz = lurek.audio.newBeatClock(90.0, 3)
waltz:start()
for i = 1, 9 do
    waltz:tick(60.0 / 90.0)  -- one beat per tick
    local pos = waltz:position()
    example_print_log(string.format("  beat %d  bar=%d  beat_in_bar=%d", i, pos.bar, pos.beat_in_bar))
end
