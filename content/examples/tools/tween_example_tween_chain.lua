--[[
    example_tween_chain.lua
    Demonstrates lurek.tween.newChain for sequential cinematic value sequences:
    - Multi-step chains with easing and labels
    - Event callbacks on step completion
    - Looping chains
    - jumpTo and reset for state machines

    API used:
      lurek.tween.newChain([looping])
        :push(opts)    opts: {from, to, duration, easing?, label?} -> index
        :tick(dt)      -> events: array of {step, label, value}
        :value()       -> number
        :cursor()      -> integer (1-based)
        :len()         -> integer
        :reset()
        :jumpTo(step)  step is 1-based
        :setLooping(bool)
        :isLooping()   -> bool
        :isFinished()  -> bool
        :clear()
--]]

-- ── 1. Simple 3-step cinematic camera dolly ──────────────────────────────────

lurek.log.info("=== Camera dolly sequence ===")
local dolly = lurek.tween.newChain()
dolly:push({ from = 0.0,  to = 200.0, duration = 1.0, easing = "easeOutCubic", label = "pan_right" })
dolly:push({ from = 200.0, to = 200.0, duration = 0.5, easing = "linear",       label = "hold" })
dolly:push({ from = 200.0, to = 0.0,   duration = 1.5, easing = "easeInOutQuad", label = "pan_back" })

lurek.log.info(string.format("  Steps: %d", dolly:len()))

local total_time = 0
local dt = 1/30  -- 30 fps simulation
while not dolly:isFinished() do
    local events = dolly:tick(dt)
    total_time = total_time + dt
    for _, ev in ipairs(events) do
        lurek.log.info(string.format("  [%.2fs] DONE step=%d label=%s value=%.1f",
            total_time, ev.step, tostring(ev.label), ev.value))
    end
    -- Safety break to avoid infinite loops in example
    if total_time > 10 then break end
end
lurek.log.info(string.format("  Final position: %.1f  (expected 0.0)", dolly:value()))

-- ── 2. Looping heartbeat pulse ────────────────────────────────────────────────

lurek.log.info("\n=== Looping heartbeat (3 beats, then reset) ===")
local pulse = lurek.tween.newChain(true)  -- looping=true
pulse:push({ from = 1.0, to = 1.2, duration = 0.1, easing = "easeOutQuad", label = "expand" })
pulse:push({ from = 1.2, to = 1.0, duration = 0.2, easing = "easeInQuad",  label = "contract" })

local beat_count = 0
local t2 = 0
while beat_count < 3 do
    local events = pulse:tick(dt)
    t2 = t2 + dt
    for _, ev in ipairs(events) do
        if ev.label == "expand" then
            beat_count = beat_count + 1
            lurek.log.info(string.format("  [%.2fs] beat %d  scale=%.3f", t2, beat_count, ev.value))
        end
    end
    if t2 > 5 then break end
end

-- ── 3. jumpTo for state-machine cutscene ─────────────────────────────────────

lurek.log.info("\n=== jumpTo: skip to step 2 ===")
local scene = lurek.tween.newChain()
scene:push({ from = 0.0, to = 50.0, duration = 1.0, label = "intro" })    -- step 1
scene:push({ from = 50.0, to = 100.0, duration = 0.5, label = "action" }) -- step 2
scene:push({ from = 100.0, to = 0.0, duration = 1.0, label = "outro" })   -- step 3

scene:jumpTo(2)  -- skip intro
lurek.log.info(string.format("  Cursor after jumpTo(2): %d  (expected 2)", scene:cursor()))
local evts = scene:tick(0.6)  -- completes step 2
for _, ev in ipairs(evts) do
    lurek.log.info(string.format("  Event: label=%s  value=%.1f", tostring(ev.label), ev.value))
end

-- ── 4. Multi-step dt span fires multiple events in one tick ──────────────────

lurek.log.info("\n=== Multi-step span in one tick ===")
local fast = lurek.tween.newChain()
fast:push({ from = 0.0, to = 1.0, duration = 0.01, label = "a" })
fast:push({ from = 1.0, to = 2.0, duration = 0.01, label = "b" })
fast:push({ from = 2.0, to = 3.0, duration = 0.01, label = "c" })
local all_events = fast:tick(0.1)  -- one big tick covers all 3 steps
lurek.log.info(string.format("  Events in one tick: %d  (expected 3)", #all_events))
for _, ev in ipairs(all_events) do
    lurek.log.info(string.format("    label=%s  value=%.2f", ev.label, ev.value))
end

-- ── 5. reset restarts the chain ───────────────────────────────────────────────

lurek.log.info("\n=== Reset ===")
local liner = lurek.tween.newChain()
liner:push({ from = 0.0, to = 100.0, duration = 2.0 })
liner:tick(1.0)
lurek.log.info(string.format("  value after 1s: %.1f", liner:value()))
liner:reset()
lurek.log.info(string.format("  value after reset: %.1f  (expected 0.0)", liner:value()))
