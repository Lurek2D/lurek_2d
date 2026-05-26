--- Example usage for library.tween_chain.
-- Demonstrates sequential chains, parallel groups, looping, callbacks,
-- and playback control. Pure-Lua — no engine dependency.
-- @module example.tween_chain

local TweenChain = require("library.tween_chain")

-- ── 1. Basic sequential chain ─────────────────────────────────────────────────
print("[tween_chain] === Basic Sequential Chain ===")

local obj = { x = 0, y = 0, alpha = 1.0 }
local events = {}

local chain = TweenChain.new()
chain:to(obj, { x = 100, y = 200 }, 0.5, "easeOutQuad")
     :wait(0.2)
     :to(obj, { x = 300 }, 1.0, "easeInOutCubic")
     :call(function() events[#events + 1] = "moved" end)
     :to(obj, { alpha = 0 }, 0.3, "linear")

chain:onStart(function() events[#events + 1] = "start" end)
chain:onComplete(function() events[#events + 1] = "complete" end)

chain:start()
assert(chain:isPlaying(), "chain should be playing after start()")

-- Simulate 3 seconds at 60fps (enough to complete all steps)
local dt = 1 / 60
for _ = 1, 180 do
    chain:update(dt)
end

assert(chain:isComplete(), "chain should be complete")
assert(not chain:isPlaying(), "chain should not be playing when complete")
print(string.format("  obj.x=%.1f obj.y=%.1f obj.alpha=%.2f", obj.x, obj.y, obj.alpha))
print(string.format("  events: %s", table.concat(events, ", ")))
assert(math.abs(obj.x - 300) < 0.01, "x should be 300")
assert(math.abs(obj.y - 200) < 0.01, "y should be 200")
assert(math.abs(obj.alpha) < 0.01, "alpha should be 0")

-- ── 2. Parallel group ─────────────────────────────────────────────────────────
print("\n[tween_chain] === Parallel Group ===")

local sprite = { x = 0, y = 0, scale = 1.0 }
local group = TweenChain.parallel()
group:to(sprite, { x = 100 }, 1.0, "linear")
group:to(sprite, { y = 200 }, 1.5, "easeOutBounce")
group:to(sprite, { scale = 2.0 }, 0.8, "easeOutBack")

local pchain = TweenChain.new()
pchain:add(group)
pchain:start()

for _ = 1, 100 do
    pchain:update(dt)
end

assert(pchain:isComplete(), "parallel chain should complete after 1.5s")
print(string.format("  sprite.x=%.1f sprite.y=%.1f sprite.scale=%.2f",
    sprite.x, sprite.y, sprite.scale))
assert(math.abs(sprite.x - 100) < 0.01, "x should be 100")
assert(math.abs(sprite.y - 200) < 0.5, "y should be ~200 (bounce)")

-- ── 3. Looping ────────────────────────────────────────────────────────────────
print("\n[tween_chain] === Looping (3x) ===")

local counter = { val = 0 }
local loop_count = 0

local lchain = TweenChain.new()
lchain:to(counter, { val = 10 }, 0.5, "linear")
      :call(function() counter.val = 0 end)  -- reset for next loop
lchain:loop(3)
lchain:onLoop(function(n)
    loop_count = n
    print(string.format("  loop iteration %d complete", n))
end)
lchain:onComplete(function()
    print("  all loops done!")
end)

lchain:start()
for _ = 1, 120 do
    lchain:update(dt)
end

assert(lchain:isComplete(), "loop chain should be complete after 3 iterations")
assert(loop_count == 3, "should have looped 3 times, got " .. tostring(loop_count))

-- ── 4. Pause / Resume ─────────────────────────────────────────────────────────
print("\n[tween_chain] === Pause / Resume ===")

local mover = { x = 0 }
local pchain2 = TweenChain.new()
pchain2:to(mover, { x = 100 }, 1.0, "linear")
pchain2:start()

-- Advance 0.5 seconds
for _ = 1, 30 do pchain2:update(dt) end
local x_at_pause = mover.x
print(string.format("  x at pause: %.1f", x_at_pause))
assert(x_at_pause > 40 and x_at_pause < 60, "should be ~50 at 0.5s")

pchain2:pause()
assert(not pchain2:isPlaying(), "should not be playing while paused")

-- Update while paused — should not advance
for _ = 1, 30 do pchain2:update(dt) end
assert(math.abs(mover.x - x_at_pause) < 0.01, "x should not change while paused")

pchain2:resume()
assert(pchain2:isPlaying(), "should be playing after resume")

for _ = 1, 40 do pchain2:update(dt) end
assert(pchain2:isComplete(), "should complete after resume")
print(string.format("  x after resume + finish: %.1f", mover.x))
assert(math.abs(mover.x - 100) < 0.01, "x should be 100")

-- ── 5. Stop and Reset ─────────────────────────────────────────────────────────
print("\n[tween_chain] === Stop / Reset ===")

local obj2 = { x = 0 }
local schain = TweenChain.new()
schain:to(obj2, { x = 100 }, 1.0, "linear")
schain:start()

for _ = 1, 15 do schain:update(dt) end
schain:stop()
assert(schain:isComplete(), "stop marks as complete")
assert(not schain:isPlaying(), "stop stops playing")

schain:reset()
assert(not schain:isComplete(), "reset clears complete")
assert(not schain:isPlaying(), "reset clears playing")

-- ── 6. Easing showcase ────────────────────────────────────────────────────────
print("\n[tween_chain] === Easing Functions ===")

local ease_names = {
    "linear", "easeInQuad", "easeOutQuad", "easeInOutQuad",
    "easeInCubic", "easeOutCubic", "easeInOutCubic",
    "easeInBack", "easeOutBack", "easeInOutBack",
    "easeOutBounce", "easeOutElastic",
}

for _, name in ipairs(ease_names) do
    local fn = TweenChain.easing[name]
    assert(fn, "missing easing: " .. name)
    -- Verify boundary conditions
    local v0 = fn(0)
    local v1 = fn(1)
    assert(math.abs(v0) < 0.01, name .. "(0) should be ~0, got " .. tostring(v0))
    assert(math.abs(v1 - 1) < 0.01, name .. "(1) should be ~1, got " .. tostring(v1))
    print(string.format("  %s: f(0)=%.3f f(0.5)=%.3f f(1)=%.3f", name, v0, fn(0.5), v1))
end

-- ── 7. Progress tracking ──────────────────────────────────────────────────────
print("\n[tween_chain] === Progress ===")

local pobj = { x = 0 }
local prog_chain = TweenChain.new()
prog_chain:to(pobj, { x = 50 }, 0.5, "linear")
           :to(pobj, { x = 100 }, 0.5, "linear")
prog_chain:start()

assert(prog_chain:getProgress() == 0, "progress starts at 0")

for _ = 1, 35 do prog_chain:update(dt) end
local mid = prog_chain:getProgress()
print(string.format("  mid-progress: %.2f", mid))
assert(mid > 0.3 and mid < 0.7, "should be around 0.5")

for _ = 1, 40 do prog_chain:update(dt) end
assert(prog_chain:getProgress() == 1.0, "progress ends at 1.0")

print("\n[tween_chain] All examples passed!")
