--- Example usage for library.sprite.
-- Demonstrates SpriteAnimator clip playback and AnimController state machine.
-- @module example.sprite

local SpriteLib = require("library.sprite")

-- ── 1. SpriteAnimator: basic clip playback ────────────────────────────────────

local clips = {
    idle  = { row = 1, from = 1, to = 4,  fps = 8,  loop = true  },
    run   = { row = 2, from = 1, to = 8,  fps = 12, loop = true  },
    jump  = { row = 3, from = 1, to = 6,  fps = 10, loop = false },
    fall  = { row = 3, from = 7, to = 10, fps = 10, loop = false },
    hurt  = { row = 4, from = 1, to = 3,  fps = 6,  loop = false },
}

local anim = SpriteLib.SpriteAnimator.new(clips)

anim:play("idle")
print(string.format("[sprite] playing: %s, isPlaying: %s", anim:currentClip(), tostring(anim:isPlaying())))

-- Advance a few frames
for i = 1, 5 do
    anim:update(0.016)
end
local row, col = anim:currentFrame()
print(string.format("[sprite] idle frame: row=%d col=%d", row, col))

-- Switch to run
anim:play("run")
for i = 1, 10 do
    anim:update(0.016)
end
row, col = anim:currentFrame()
print(string.format("[sprite] run frame: row=%d col=%d", row, col))

-- Non-looping clip: play jump and let it end
anim:play("jump")
anim:onEnd(function(clip)
    print(string.format("[sprite] clip ended: %s", clip))
end)
-- Advance enough to finish the jump clip
local jump_dur = anim:clipDuration()
anim:update(jump_dur + 0.01)
print(string.format("[sprite] after jump: isPlaying=%s", tostring(anim:isPlaying())))

-- ── 2. AnimController: rule-based state machine ───────────────────────────────

local anim2 = SpriteLib.SpriteAnimator.new(clips)

local ctrl = SpriteLib.AnimController.new(anim2, {
    rules = {
        { state = "idle", condition = function(ctx) return ctx.vx == 0 and ctx.grounded end },
        { state = "run",  condition = function(ctx) return ctx.vx ~= 0 and ctx.grounded end },
        { state = "jump", condition = function(ctx) return not ctx.grounded and ctx.vy < 0 end },
        { state = "fall", condition = function(ctx) return not ctx.grounded and ctx.vy >= 0 end },
    },
    default = "idle",
})

ctrl:onStateChange(function(old, new)
    print(string.format("[sprite] state change: %s -> %s", tostring(old), new))
end)

-- Simulate: standing still
ctrl:update(0.016, { vx = 0, vy = 0, grounded = true })
print(string.format("[sprite] state: %s", ctrl:getState()))

-- Simulate: running
ctrl:update(0.016, { vx = 120, vy = 0, grounded = true })
print(string.format("[sprite] state: %s", ctrl:getState()))

-- Simulate: jumping
ctrl:update(0.016, { vx = 120, vy = -200, grounded = false })
print(string.format("[sprite] state: %s", ctrl:getState()))

-- Simulate: falling
ctrl:update(0.016, { vx = 50, vy = 80, grounded = false })
print(string.format("[sprite] state: %s", ctrl:getState()))

-- Simulate: landing
ctrl:update(0.016, { vx = 0, vy = 0, grounded = true })
print(string.format("[sprite] state: %s", ctrl:getState()))

-- ── 3. Force a state (e.g., hurt animation) ──────────────────────────────────

ctrl:force("hurt", 0.5)
print(string.format("[sprite] forced state: %s", ctrl:getState()))

-- While forced, rules are ignored
ctrl:update(0.016, { vx = 100, vy = 0, grounded = true })
print(string.format("[sprite] still forced: %s", ctrl:getState()))

-- After duration expires, rules resume
ctrl:update(0.5, { vx = 100, vy = 0, grounded = true })
print(string.format("[sprite] force expired, state: %s", ctrl:getState()))
