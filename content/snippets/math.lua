-- content/snippets/math.lua
-- Handcrafted snippets for lurek.math — interpolation, geometry, curves, noise, random.
-- API surface covered: clamp, lerp, inverseLerp, remap, smoothstep, sign, abs,
--   distance, distanceSq, angleBetween, closestPointOnSegment, lineIntersect,
--   segmentIntersectsSegment, circleContainsPoint, circleIntersectsCircle,
--   pointInPolygon, polygonArea, polygonCentroid, convexHull, triangulate,
--   bresenham, rectUnion, rectFromCenter, catmullRom, newBezierCurve, random, randomInt.

local m = lurek.math

-- ─────────────────────────────────────────────────────────────
-- INTERPOLATION & MAPPING
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.math.smooth_follow_value
-- @prefix lk-math-smooth-follow
-- @module math
-- @description Use for camera tracking, health-bar animation, and any value that should ease toward a target without overshooting. smoothstep gives a natural velocity curve; speed is controlled by the lerp factor.
-- @body
local SNIP_1_m       = lurek.math
local current = 0
local target  = 100
local speed   = 0.1   -- fraction per frame (higher = faster)

-- each frame:
local t       = m.smoothstep(0, 1, speed)
current       = m.lerp(current, target, t)
print("current=" .. string.format("%.2f", current))
-- @end

-- @snippet lurek.math.progress_remap_window
-- @prefix lk-math-progress-remap
-- @module math
-- @description Use to drive a progress window animation (e.g. show progress bar only between t=0.2 and t=0.8 of a full cutscene). remap + clamp extracts a sub-range of a normalised [0..1] timeline into its own [0..1].
-- @body
local SNIP_1_m        = lurek.math
local total_t  = 1.0   -- full timeline length (seconds or normalised)
local seg_start = 0.2
local seg_end   = 0.8
local t        = 0.5   -- current position in [0..1]

local sub_t = m.clamp(m.remap(t, seg_start, seg_end, 0, 1), 0, 1)
print("sub progress=" .. string.format("%.3f", sub_t))
-- @end

-- @snippet lurek.math.aim_distance_bundle
-- @prefix lk-math-aim-distance
-- @module math
-- @description Use to compute the angle and distance between an actor and a target for aiming, aggro-range checks, and steering. angleBetween gives the heading in radians; distanceSq avoids the sqrt for range-only comparisons.
-- @body
local SNIP_1_m     = lurek.math
local px, py = 100, 200    -- player position
local tx, ty = 350, 180    -- target position
local angle  = m.angleBetween(px, py, tx, ty)
local dist   = m.distance(px, py, tx, ty)
local dist2  = m.distanceSq(px, py, tx, ty)
local aggro  = 200
print(string.format("angle=%.2frad  dist=%.1f  in_aggro=%s",
    angle, dist, tostring(dist2 < aggro * aggro)))
-- @end

-- @snippet lurek.math.inverse_lerp_opacity_gate
-- @prefix lk-math-inv-lerp-opacity
-- @module math
-- @description Use to compute a fade-in opacity from a distance or any ranged value. inverseLerp turns the raw measurement back into [0..1], then clamp prevents negative or >1 values at the extremes.
-- @body
local SNIP_1_m    = lurek.math
local dist      = 150      -- current distance to camera or trigger
local fade_near = 80       -- fully visible at or below this distance
local fade_far  = 200      -- fully invisible at or above this distance

local opacity = m.clamp(m.inverseLerp(fade_far, fade_near, dist), 0, 1)
print("opacity=" .. string.format("%.3f", opacity))
-- @end

-- @snippet lurek.math.sign_bounce_direction
-- @prefix lk-math-sign-bounce
-- @module math
-- @description Use for wall-bounce logic, score differentials, and left/right split. sign() returns -1, 0, or +1 — multiply by a speed to flip velocity on impact without a manual if/else branch.
-- @body
local SNIP_1_m   = lurek.math
local vx  = 3.5   -- current x velocity
local wall_x = 400
local px_after = wall_x + 5   -- position just past the wall

-- flip velocity on the frame the object crosses the boundary
if m.sign(px_after - wall_x) ~= m.sign((px_after - vx) - wall_x) then
    vx = -vx
end
print("vx after bounce=" .. vx)
-- @end

-- ─────────────────────────────────────────────────────────────
-- GEOMETRY
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.math.closest_point_on_path
-- @prefix lk-math-closest-point-path
-- @module math
-- @description Use to snap an entity to the nearest point on a road, rail, or patrol path defined as polyline segments. Iterate segments and keep the closest result from closestPointOnSegment.
-- @body
local SNIP_1_m = lurek.math
local path = { {0,0}, {100,50}, {200,80}, {300,30} }
local px, py = 150, 120   -- query point

local best_dist = math.huge
local snap_x, snap_y = px, py
for i = 1, #path - 1 do
    local ax, ay = path[i][1],   path[i][2]
    local bx, by = path[i+1][1], path[i+1][2]
    local cx, cy = m.closestPointOnSegment(px, py, ax, ay, bx, by)
    local d      = m.distanceSq(px, py, cx, cy)
    if d < best_dist then
        best_dist = d
        snap_x, snap_y = cx, cy
    end
end
print(string.format("snap=(%.1f,%.1f) dist=%.1f", snap_x, snap_y, math.sqrt(best_dist)))
-- @end

-- @snippet lurek.math.line_intersect_laser
-- @prefix lk-math-laser-bounce
-- @module math
-- @description Use for laser / light-ray bouncing off a wall segment. lineIntersect returns the crossing point; segmentIntersectsSegment guards against infinite-line false positives outside segment extents.
-- @body
local SNIP_1_m   = lurek.math
-- ray from (50,50) heading right-down
local rx1, ry1 = 50,  50
local rx2, ry2 = 300, 200
-- wall segment
local wx1, wy1 = 200, 0
local wx2, wy2 = 200, 300

local hit, ix, iy = m.segmentIntersectsSegment(rx1, ry1, rx2, ry2, wx1, wy1, wx2, wy2)
if hit and ix and iy then
    print(string.format("laser hits wall at (%.1f,%.1f)", ix, iy))
end
-- @end

-- @snippet lurek.math.circle_overlap_check
-- @prefix lk-math-circle-overlap
-- @module math
-- @description Use for simple trigger zones, pickup radii, and explosion hit detection. circleContainsPoint for point-in-circle, circleIntersectsCircle for collision between two radial actors.
-- @body
local SNIP_1_m = lurek.math
-- trigger zone at (200, 300) radius 40
local zx, zy, zr = 200, 300, 40
-- player at (205, 295) radius 10
local px, py, pr = 205, 295, 10

local player_in_zone = m.circleContainsPoint(zx, zy, zr, px, py)
local circles_touch  = m.circleIntersectsCircle(zx, zy, zr, px, py, pr)
print("in_zone=" .. tostring(player_in_zone) .. "  circles_touch=" .. tostring(circles_touch))
-- @end

-- @snippet lurek.math.polygon_point_in_room
-- @prefix lk-math-point-in-room
-- @module math
-- @description Use to test whether a character or cursor is inside an irregular room polygon — for room entry events, valid placement checks, and fog-of-war.
-- @body
local SNIP_1_m = lurek.math
-- convex room outline (flat list: x1,y1,x2,y2,...)
local room = { 0, 0,  200, 0,  250, 100,  200, 200,  0, 200 }
local px, py = 100, 100   -- test point

local inside = m.pointInPolygon(room, px, py)
print("inside room=" .. tostring(inside))
if inside then
    local area = m.polygonArea(room)
    local cx, cy = m.polygonCentroid(room)
    print(string.format("  area=%.1f  centroid=(%.1f,%.1f)", area, cx, cy))
end
-- @end

-- @snippet lurek.math.convex_hull_selection
-- @prefix lk-math-convex-hull
-- @module math
-- @description Use when building a selection boundary around a set of scattered units or points — the convex hull is the tightest non-concave enclosure and is also the correct input for physics shape decomposition.
-- @body
local SNIP_1_m = lurek.math
-- scatter of unit positions (flat x,y pairs)
local pts = { 10, 20,  50, 10,  30, 60,  80, 40,  60, 80,  20, 90 }
local hull = m.convexHull(pts)
print("hull vertices = " .. (#hull / 2))
for i = 1, #hull, 2 do
    print(string.format("  (%.0f, %.0f)", hull[i], hull[i+1]))
end
-- @end

-- @snippet lurek.math.triangulate_render_mesh
-- @prefix lk-math-triangulate
-- @module math
-- @description Use to decompose a concave room or level-section polygon into triangles before passing to lurek.render mesh calls or collision shape builders that require triangle lists.
-- @body
local SNIP_1_m  = lurek.math
local pts = { 0, 0,  100, 0,  100, 50,  60, 50,  60, 100,  0, 100 }  -- L-shape
local tris = m.triangulate(pts)
print("triangles = " .. #tris)
-- @end

-- @snippet lurek.math.bresenham_grid_path
-- @prefix lk-math-bresenham-grid
-- @module math
-- @description Use for tile-based line-of-sight, projectile paths on a grid, or highlighting cells a line passes through. bresenham returns all integer cell coordinates between two grid positions.
-- @body
local SNIP_1_m    = lurek.math
local cells = m.bresenham(2, 3, 8, 7)
print("grid cells on path: " .. #cells)
for _, c in ipairs(cells) do
    print("  tile=" .. c.x .. "," .. c.y)
end
-- @end

-- @snippet lurek.math.rect_union_bounding_box
-- @prefix lk-math-rect-union
-- @module math
-- @description Use to compute the bounding box that covers multiple objects — for camera framing, dirty region invalidation, or multi-selection outlines.
-- @body
local SNIP_1_m = lurek.math
-- grow bounding box over a list of objects
local objects = {
    { x=10, y=20, w=40, h=30 },
    { x=80, y=15, w=25, h=60 },
    { x=50, y=90, w=30, h=20 },
}
local bx, by, bw, bh = objects[1].x, objects[1].y, objects[1].w, objects[1].h
for i = 2, #objects do
    local o = objects[i]
    bx, by, bw, bh = m.rectUnion(bx, by, bw, bh, o.x, o.y, o.w, o.h)
end
print(string.format("bounding box=%.0f,%.0f %.0fx%.0f", bx, by, bw, bh))
-- @end

-- ─────────────────────────────────────────────────────────────
-- CURVES
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.math.bezier_bullet_trajectory
-- @prefix lk-math-bezier-traj
-- @module math
-- @description Use for arcing projectile paths, thrown objects, or animated spline motion. Define start/control/end, then evaluate at t to get position each frame. Derivative curve gives the tangent for rotation of the sprite along the path.
-- @body
local SNIP_1_m  = lurek.math
local bz = m.newBezierCurve({ 50, 400,  200, 100,  500, 380 })
local t  = 0.5   -- animation progress [0..1], advance by dt/total_time each frame
local px, py = bz:evaluate(t)
print(string.format("projectile at (%.1f,%.1f) t=%.2f", px, py, t))
-- tangent for rotation:
local deriv = bz:getDerivative()
local dx, dy = deriv:evaluate(t)
local angle  = math.atan2(dy, dx)
print("angle=" .. string.format("%.3f", angle))
-- @end

-- @snippet lurek.math.bezier_edit_control_point
-- @prefix lk-math-bezier-edit
-- @module math
-- @description Use in an in-game spline editor or patrol-path tool. Allow the designer to drag control points at runtime; evaluate + render to preview the curve instantly after each change.
-- @body
local SNIP_1_m  = lurek.math
local bz = m.newBezierCurve({ 0, 0,  100, 200,  300, 200,  400, 0 })

-- simulate moving control point 2 to a new position:
bz:setControlPoint(2, 100, 250)
local nx, ny = bz:getControlPoint(2)
print("cp2 moved to=" .. nx .. "," .. ny)

-- render the updated curve as line segments
local pts = bz:render(20)
print("render sample count=" .. #pts)
-- @end

-- @snippet lurek.math.catmullrom_patrol_path
-- @prefix lk-math-catmullrom-patrol
-- @module math
-- @description Use for smooth patrol paths, camera dolly tracks, or any looping motion that must pass through exact waypoints. Catmull-Rom guarantees C1 continuity at every point — no sharp corners.
-- @body
local SNIP_1_m     = lurek.math
local waypoints = {
    {x=50,  y=300},
    {x=200, y=100},
    {x=400, y=200},
    {x=550, y=350},
}
local cr  = m.catmullRom(waypoints)
local t   = 0.0   -- advance by dt / patrol_duration each frame

local px, py = cr:sample(t)
print(string.format("patrol at (%.1f,%.1f)  t=%.3f  segments=%d",
    px, py, t, cr:len()))
-- @end

-- ─────────────────────────────────────────────────────────────
-- RANDOM
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.math.random_loot_roll
-- @prefix lk-math-random-loot
-- @module math
-- @description Use for loot tables, ability proc chances, and random event triggers. random() returns [0,1); compare against a threshold for probability checks.
-- @body
local SNIP_1_m = lurek.math
local function roll_loot(common_pct, rare_pct)
    local r = m.random()
    if r < rare_pct then
        return "rare"
    elseif r < rare_pct + common_pct then
        return "common"
    end
    return "nothing"
end

local result = roll_loot(0.5, 0.05)  -- 5 % rare, 50 % common
print("loot=" .. result)
local dice = m.randomInt(1, 20)
print("d20=" .. dice)
-- @end
