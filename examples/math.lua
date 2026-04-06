-- examples/math.lua
-- Luna2D luna.math API Reference
-- This file is documentation code, not a runnable game.
-- Every luna.math function is demonstrated with inline comments.

-- ─────────────────────────────────────────────────────────────────────────────
-- Basic Math Functions
-- ─────────────────────────────────────────────────────────────────────────────

-- Clamp a value to a range
local clamped = luna.math.clamp(1.5, 0, 1)   -- → 1
local clamped2 = luna.math.clamp(-5, 0, 100) -- → 0

-- Linear interpolation between two values
local blend = luna.math.lerp(0, 100, 0.25)   -- → 25

-- Distance between two points
local dist = luna.math.distance(0, 0, 3, 4)  -- → 5

-- Angle from point A to point B (in radians)
local ang = luna.math.angle(0, 0, 1, 0)      -- → 0 (facing right)
local ang2 = luna.math.angle(0, 0, 0, 1)     -- → math.pi/2 (facing down)

-- Normalize a 2D vector (returns unit vector components)
local nx, ny = luna.math.normalize(3, 4)     -- → 0.6, 0.8

-- Dot product of two 2D vectors
local d = luna.math.dot(1, 0, 0, 1)          -- → 0 (perpendicular)

-- Convert from polar (magnitude, angle) to Cartesian (x, y)
local x, y = luna.math.fromPolar(10, math.pi / 4) -- → 7.07, 7.07

-- Convert from Cartesian to polar (magnitude, angle)
local r, theta = luna.math.toPolar(1, 1)     -- → 1.41, 0.785

-- ─────────────────────────────────────────────────────────────────────────────
-- Standard Math (also available as normal Lua math.*)
-- ─────────────────────────────────────────────────────────────────────────────
local a1 = luna.math.abs(-7)        -- → 7
local a2 = luna.math.floor(3.9)     -- → 3
local a3 = luna.math.ceil(3.1)      -- → 4
local a4 = luna.math.sqrt(16)       -- → 4
local a5 = luna.math.sin(math.pi)   -- → ~0
local a6 = luna.math.cos(0)         -- → 1
local a7 = luna.math.atan2(1, 0)    -- → pi/2
local a8 = luna.math.max(3, 7, 2)   -- → 7
local a9 = luna.math.min(3, 7, 2)   -- → 2
local pi  = luna.math.pi            -- → 3.14159...

-- ─────────────────────────────────────────────────────────────────────────────
-- Color Space Conversion
-- ─────────────────────────────────────────────────────────────────────────────

-- sRGB gamma → linear (for physically correct blending)
local lr, lg, lb, la = luna.math.gammaToLinear(0.5, 0.5, 0.5, 1.0)

-- Linear → sRGB gamma (for display output)
local gr, gg, gb, ga = luna.math.linearToGamma(0.21, 0.21, 0.21, 1.0)

-- ─────────────────────────────────────────────────────────────────────────────
-- Random Numbers (global state)
-- ─────────────────────────────────────────────────────────────────────────────

-- Seedless random (integer 1–100)
local roll = luna.math.random(1, 100)

-- Float in range
local speed = luna.math.randomFloat(0.5, 2.0)

-- ─────────────────────────────────────────────────────────────────────────────
-- RandomGenerator (local seeded instance)
-- ─────────────────────────────────────────────────────────────────────────────

local rng = luna.math.newRandomGenerator(42)

local n1 = rng:random()              -- float in [0, 1)
local n2 = rng:random(1, 6)          -- integer in [1, 6]
local n3 = rng:randomFloat(-1, 1)    -- float in [-1, 1]
local n4 = rng:randomInt(0, 255)     -- integer in [0, 255]
local n5 = rng:randomNormal(1.0)     -- normal distribution, stddev=1
local n6 = rng:randomNormal(2.0, 5.0)-- normal distribution, stddev=2, mean=5

-- Reproducibility: save and restore state
local seed = rng:getSeed()
local state = rng:getState()
rng:setSeed(12345)
rng:setState(state) -- restore to saved point

-- ─────────────────────────────────────────────────────────────────────────────
-- Easing Functions  (luna.math.easing table)
-- ─────────────────────────────────────────────────────────────────────────────
-- All easing functions: f(t) where t ∈ [0, 1] → value ∈ [0, 1]
-- Apply to lerp for smooth interpolation

local easing = luna.math.easing

local t = 0.5 -- progress value in [0, 1]

-- Quadratic
local v1 = easing.linear(t)      -- linear (no easing)
local v2 = easing.inQuad(t)      -- slow start
local v3 = easing.outQuad(t)     -- slow end
local v4 = easing.inOutQuad(t)   -- slow start and end

-- Cubic
local v5 = easing.inCubic(t)
local v6 = easing.outCubic(t)
local v7 = easing.inOutCubic(t)

-- Sinusoidal
local v8 = easing.inSine(t)
local v9 = easing.outSine(t)
local v10 = easing.inOutSine(t)

-- Exponential
local v11 = easing.inExpo(t)
local v12 = easing.outExpo(t)
local v13 = easing.inOutExpo(t)

-- Elastic (overshoots)
local v14 = easing.inElastic(t)
local v15 = easing.outElastic(t)
local v16 = easing.inOutElastic(t)

-- Bounce (bounces at destination)
local v17 = easing.inBounce(t)
local v18 = easing.outBounce(t)
local v19 = easing.inOutBounce(t)

-- Back (overshoots then returns)
local v20 = easing.inBack(t)
local v21 = easing.outBack(t)
local v22 = easing.inOutBack(t)

-- Apply easing to lerp:
local smooth_x = luna.math.lerp(0, 800, easing.outQuad(t))

-- ─────────────────────────────────────────────────────────────────────────────
-- Tween (automated value interpolation)
-- ─────────────────────────────────────────────────────────────────────────────

-- Create a tween: duration=1.0s, easing=outQuad, values: from 0→100 and from 0→255
local tw = luna.math.newTween(1.0, luna.math.easing.outQuad, {
    {from = 0,   to = 100},   -- value 1: x position
    {from = 0,   to = 255},   -- value 2: alpha
    {from = 200, to = 50},    -- value 3: size
})

-- Tick the tween forward by dt each frame
local dt = 0.016
tw:update(dt)

-- Read current values
local px = tw:getValue(1)     -- current x
local alpha = tw:getValue(2)  -- current alpha
local sz = tw:getValue(3)     -- current size

-- Or get all values at once
local vals = tw:getAllValues() -- {100, 255, 50} when complete

-- Check completion
if tw:isComplete() then
    -- tween has reached end
end

-- Introspect
local dur = tw:getDuration()   -- → 1.0
local now = tw:getTime()       -- current elapsed time
local name = tw:getEasingName()-- → "outQuad"
local cnt = tw:getValueCount() -- → 3

-- Seek to a specific moment
tw:setTime(0.5)  -- jump to 50% through
tw:reset()       -- restart from beginning

-- Add more values dynamically
tw:addValue(0, 360)  -- add rotation 0→360

-- ─────────────────────────────────────────────────────────────────────────────
-- BezierCurve
-- ─────────────────────────────────────────────────────────────────────────────

-- Define a cubic Bezier with 4 control points {x1,y1, x2,y2, x3,y3, x4,y4}
local curve = luna.math.newBezierCurve({
    0,   0,    -- P0: start
    100, 0,    -- P1: control 1
    100, 200,  -- P2: control 2
    200, 200,  -- P3: end
})

-- Evaluate position at parameter t ∈ [0, 1]
local cx, cy = curve:evaluate(0.5)   -- point at middle of curve

-- Derivative (tangent) at t
local dx, dy = curve:getDerivative(0.5)

-- Approximate arc length
local len = curve:getLength()

-- Get all control points as {x1,y1,...}
local pts = curve:getPoints()

-- Render to polygon points (for drawing), segments = quality
local poly_pts = curve:render(20)  -- 20 line segments

-- ─────────────────────────────────────────────────────────────────────────────
-- Transform (2D affine matrix)
-- ─────────────────────────────────────────────────────────────────────────────

local tf = luna.math.newTransform()

-- Chain transforms
tf:translate(100, 200)
tf:rotate(math.pi / 4)  -- 45 degrees
tf:scale(2, 2)

-- Apply transform to a point
local wx, wy = tf:transformPoint(0, 0)  -- in world space
local lx, ly = tf:inverseTransformPoint(wx, wy)  -- back to local

-- Get/set matrix directly
local m = tf:getMatrix()         -- 9 numbers, row-major 3x3
tf:setMatrix(1,0,0, 0,1,0, 0,0,1) -- identity

-- Reset to identity
tf:reset()

-- Clone
local tf2 = tf:clone()

-- Concatenate two transforms
tf:apply(tf2)  -- tf = tf * tf2

-- ─────────────────────────────────────────────────────────────────────────────
-- SpatialHash (broad-phase collision grid)
-- ─────────────────────────────────────────────────────────────────────────────

-- Create grid with cell size 64 pixels
local grid = luna.math.newSpatialHash(64)

-- Insert objects by an arbitrary id and AABB
grid:insert("player",       100, 100, 32, 48)
grid:insert("enemy_1",      200, 150, 32, 32)
grid:insert("powerup",      300, 300, 16, 16)

-- Update a moving object's AABB
grid:update("player", 110, 100, 32, 48)

-- Query all objects whose AABB overlaps a rectangle
local hits = grid:queryRect(80, 80, 100, 80)
-- hits = {"player", "enemy_1"}  (or may be empty)

-- Query within a circle radius
local nearby = grid:queryCircle(200, 200, 100)

-- Remove an object
grid:remove("powerup")

-- Stats
local cell_sz = grid:getCellSize()   -- → 64
local count   = grid:getItemCount()  -- number of tracked objects

-- Clear all
grid:clear()

-- ─────────────────────────────────────────────────────────────────────────────
-- NoiseGenerator
-- ─────────────────────────────────────────────────────────────────────────────

local noise = luna.math.newNoiseGenerator(42) -- optional seed

-- 1D noise (t = time or position along a line)
local n = noise:perlin1d(0.5)   -- → float in roughly [-1, 1]
local s = noise:simplex1d(0.5)

-- 2D noise (terrain, texture generation)
local h = noise:perlin2d(x, y)
local h2 = noise:simplex2d(x, y)

-- 3D noise (animated 2D; add time as z)
local h3 = noise:perlin3d(x, y, 0.0)
local h4 = noise:simplex3d(x, y, 0.0)

-- 4D noise
local h5 = noise:perlin4d(x, y, z, w)

-- Worley / cellular noise (returns distance to nearest cell center)
local d1 = noise:worley2d(x, y)
local d2 = noise:worley3d(x, y, z)

-- Fractal Brownian Motion (layered noise, more natural)
local fbm = noise:fbm(x, y)          -- default octaves/lacunarity/gain
local fbm2 = noise:fbm(x, y, 6, 2.0, 0.5) -- explicit: octaves, lacunarity, gain

-- Ridged multifractal (mountain ridges)
local ridge = noise:ridged(x, y)

-- Turbulence (absolute value of FBM, good for clouds)
local turb = noise:turbulence(x, y)

-- Domain warping (distorted FBM for organic shapes)
local warped = noise:warpDomain(x, y)

-- Generate a 2D noise map as a flat table of floats
local map = noise:generateMap(256, 256) -- {float, ...} row-major
local map2 = noise:generateMap(128, 128, {
    type = "fbm",         -- "perlin", "simplex", "fbm", "ridged", "worley"
    scale = 0.01,         -- frequency (larger = more zoomed out)
    octaves = 6,
    lacunarity = 2.0,
    gain = 0.5,
    normalize = true,     -- remap to [0, 1]
})

noise:setSeed(99)
local seed2 = noise:getSeed()

-- ─────────────────────────────────────────────────────────────────────────────
-- Polygon Triangulation (ear-clipping)
-- ─────────────────────────────────────────────────────────────────────────────

-- Input: flat list of 2D vertices {x1,y1, x2,y2, ...}
local polygon = {
    0, 0,
    100, 0,
    100, 100,
    50,  150,
    0,   100,
}

-- Returns a flat list of triangles: {x1,y1, x2,y2, x3,y3, ...}
-- Each consecutive group of 6 floats is one triangle.
local triangles = luna.math.triangulate(polygon)
for i = 1, #triangles, 6 do
    local tx1, ty1 = triangles[i],   triangles[i+1]
    local tx2, ty2 = triangles[i+2], triangles[i+3]
    local tx3, ty3 = triangles[i+4], triangles[i+5]
    -- draw triangle (tx1,ty1) → (tx2,ty2) → (tx3,ty3)
end
