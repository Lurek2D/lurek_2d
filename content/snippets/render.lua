-- content/snippets/render.lua
-- Handcrafted snippets for lurek.render — shapes, color, transforms, images, layers,
-- canvas, sprite batches, shaders, blend modes, HUD, gradients, iso tiles.
-- API surface covered: setColor, rectangle, circle, ellipse, arc, line, polygon,
--   print, printf, printRich, push/pop, translate, rotate, scale, shear, origin,
--   setScissor, setBlendMode, setWireframe, newLayer/setLayer/setLayerVisible,
--   newCanvas/setCanvas, draw, drawq, drawMany, newImage, newQuad, newSpriteBatch,
--   drawGradientRect, drawColoredPolygon, drawHexTile, drawBevelRect, drawIsoCubeTile,
--   newDrawLayer, setShader, getStats, getDimensions, setBackgroundColor.

local r = lurek.render

-- ─────────────────────────────────────────────────────────────
-- DEBUG HUD
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.debug_hud_card
-- @prefix lk-render-debug-hud
-- @module render
-- @description Use for a semi-transparent debug card overlay. Combines a filled rectangle backdrop, setColor to reset alpha, and printf for aligned text.
-- @body
local SNIP_1_r = lurek.render
local hud_x, hud_y, hud_w, hud_h = 8, 8, 220, 56
r.setColor(0, 0, 0, 0.55)
r.rectangle("fill", hud_x, hud_y, hud_w, hud_h)
r.setColor(0.9, 0.9, 0.9, 1)
r.printf("FPS: " .. lurek.engine.fps(), hud_x + 8, hud_y + 8, hud_w - 16, "left")
r.printf("Frame: " .. lurek.engine.frameCount(), hud_x + 8, hud_y + 28, hud_w - 16, "left")
r.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.render.render_stats_overlay
-- @prefix lk-render-stats-overlay
-- @module render
-- @description Use when profiling draw call budget. getStats() shows drawcalls, textures, and GPU calls in one struct — displays a compact line each frame.
-- @body
local SNIP_1_r     = lurek.render
local stats = r.getStats()
r.setColor(0.2, 0.9, 0.2, 0.9)
r.print(string.format("dc=%d  gpu=%d  tex=%d  vmem=%.0fKB",
    stats.drawcalls, stats.gpu_draw_calls,
    stats.textures, stats.texture_memory / 1024), 8, 8)
r.setColor(1, 1, 1, 1)
-- @end

-- ─────────────────────────────────────────────────────────────
-- COLOR & BLEND
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.additive_particle_burst
-- @prefix lk-render-additive-burst
-- @module render
-- @description Use for glowing particles, explosions, and energy beams. Additive blend mode accumulates light values — overlapping translucent circles brighten the area instead of replacing it.
-- @body
local SNIP_1_r = lurek.render
r.setBlendMode("add")
for i = 1, 8 do
    local angle = (i / 8) * math.pi * 2
    local px    = 400 + math.cos(angle) * 40
    local py    = 300 + math.sin(angle) * 40
    r.setColor(1, 0.5, 0.1, 0.6)
    r.circle("fill", px, py, 18)
end
r.setBlendMode("alpha")
r.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.render.background_color_transition
-- @prefix lk-render-bg-color-transition
-- @module render
-- @description Use for day/night cycle, scene mood shift, or level transition. Lerps background RGB between two states each frame using a normalised progress t.
-- @body
local SNIP_1_r    = lurek.render
local dawn = {0.9, 0.6, 0.3}
local dusk = {0.1, 0.05, 0.2}
local t    = 0.5   -- [0=dawn, 1=dusk] — advance with uptime / cycle_duration

local br = dawn[1] + (dusk[1] - dawn[1]) * t
local bg = dawn[2] + (dusk[2] - dawn[2]) * t
local bb = dawn[3] + (dusk[3] - dawn[3]) * t
r.setBackgroundColor(br, bg, bb)
-- @end

-- ─────────────────────────────────────────────────────────────
-- TRANSFORMS
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.camera_follow_transform
-- @prefix lk-render-camera-follow
-- @module render
-- @description Use as the outer push/pop wrapper around your scene draw. Translates the origin so the camera target stays centred on screen. Wrap all world-space draw calls inside this block.
-- @body
local SNIP_1_r    = lurek.render
local W, H = r.getDimensions()
-- replace with your actual camera target and smoothed cam_x/cam_y
local cam_x, cam_y = 320, 240   -- smoothed camera world position
r.push()
r.translate(W * 0.5 - cam_x, H * 0.5 - cam_y)
    -- draw world objects here
    r.setColor(0.2, 0.8, 0.2, 1)
    r.circle("fill", cam_x, cam_y, 10)  -- actor at camera center
r.pop()
r.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.render.camera_shake_block
-- @prefix lk-render-camera-shake
-- @module render
-- @description Use for screen-shake on explosions, damage, and impacts. Applies a per-frame random offset capped by a decaying trauma value, then restores the matrix with pop() so UI elements are unaffected.
-- @body
local SNIP_1_r      = lurek.render
local trauma = 0.8   -- [0..1], decay toward 0 over time
local shake  = trauma * trauma * 12   -- quadratic falloff feels more natural

r.push()
r.translate(
    (math.random() * 2 - 1) * shake,
    (math.random() * 2 - 1) * shake
)
    -- draw all world-space content inside here
    r.setColor(0.8, 0.2, 0.1, 1)
    r.rectangle("fill", 200, 180, 60, 40)
r.pop()
-- decay trauma each frame: trauma = math.max(0, trauma - dt * 2)
-- @end

-- @snippet lurek.render.sprite_transform_stack
-- @prefix lk-render-sprite-transform
-- @module render
-- @description Use to draw a sprite with its own local pivot, rotation, and scale without affecting subsequent draw calls. Essential for hierarchical character rigs (weapon attached to hand) or world-space billboards.
-- @body
local SNIP_1_r  = lurek.render
local img = r.newImage("content/examples/assets/images/sample_texture.png")
local W, H = img:getDimensions()
-- world position, rotation angle, scale
local wx, wy, angle, sx, sy = 300, 250, math.pi / 6, 2, 2
local ox, oy = W * 0.5, H * 0.5    -- pivot at image centre

r.push()
r.translate(wx, wy)
r.rotate(angle)
r.scale(sx, sy)
r.draw(img, -ox, -oy)
r.pop()
r.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.render.scissor_viewport_clip
-- @prefix lk-render-scissor-clip
-- @module render
-- @description Use to restrict rendering to a minimap frame, inventory slot, or scrolling text panel — nothing drawn outside the scissor rect appears on screen.
-- @body
local SNIP_1_r      = lurek.render
local vp_x, vp_y, vp_w, vp_h = 650, 10, 140, 140   -- minimap rectangle
r.setScissor(vp_x, vp_y, vp_w, vp_h)
    r.setColor(0.1, 0.1, 0.1, 1)
    r.rectangle("fill", vp_x, vp_y, vp_w, vp_h)    -- minimap background
    r.setColor(0.3, 0.9, 0.3, 1)
    r.circle("fill", 720, 80, 6)                     -- player dot
r.setScissor()    -- restore full viewport
r.setColor(1, 1, 1, 1)
-- @end

-- ─────────────────────────────────────────────────────────────
-- LAYERS & DEPTH
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.layer_scene_setup
-- @prefix lk-render-layer-setup
-- @module render
-- @description Use at game init to define named draw layers in z-order. All subsequent setLayer() calls use these names — easier to read than raw z numbers and safe to reorder without touching every draw site.
-- @body
local SNIP_1_r = lurek.render
r.newLayer("sky",        0)
r.newLayer("terrain",   10)
r.newLayer("actors",    20)
r.newLayer("fx",        30)
r.newLayer("ui",       100)

r.setLayer("actors")
print("current layer=" .. r.currentLayer())
print("ui visible=" .. tostring(r.isLayerVisible("ui")))
-- @end

-- @snippet lurek.render.draw_layer_priority_queue
-- @prefix lk-render-draw-layer-priority
-- @module render
-- @description Use when you need fine-grained z-ordering within a layer (e.g. sort actors by Y position for 2.5D overlap). newDrawLayer queues callbacks by priority integer and flushes them in sorted order.
-- @body
local SNIP_1_r     = lurek.render
local layer = r.newDrawLayer()

local actors = {
    { y = 250, name = "orc"  },
    { y = 100, name = "hero" },
    { y = 310, name = "troll"},
}
for _, a in ipairs(actors) do
    local name = a.name
    layer:queue(a.y, function()
        r.setColor(0.7, 0.5, 0.3, 1)
        r.print(name, 50, a.y)
    end)
end
layer:flush()
r.setColor(1, 1, 1, 1)
-- @end

-- ─────────────────────────────────────────────────────────────
-- CANVAS / OFF-SCREEN RENDER
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.canvas_offscreen_post
-- @prefix lk-render-canvas-post
-- @module render
-- @description Use to render a scene to an off-screen canvas, then draw the canvas to screen with a tint, scale, or custom shader — foundation for minimap thumbnails, reflection captures, and simple post-processing effects.
-- @body
local SNIP_1_r      = lurek.render
local canvas = r.newCanvas(256, 256)

r.setCanvas(canvas)
    r.setColor(0.1, 0.05, 0.2, 1)
    r.rectangle("fill", 0, 0, 256, 256)
    r.setColor(0.8, 0.3, 0.1, 1)
    r.circle("fill", 128, 128, 60)
r.setCanvas(nil)

-- draw result with a blue tint at half size
r.setColor(0.7, 0.7, 1.0, 0.9)
r.draw(canvas, 500, 100, 0, 0.5, 0.5)
r.setColor(1, 1, 1, 1)
-- @end

-- ─────────────────────────────────────────────────────────────
-- SPRITES & BATCHES
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.sprite_batch_tilemap
-- @prefix lk-render-sprite-batch-tile
-- @module render
-- @description Use to render a tile map efficiently. SpriteBatch batches hundreds of quads in a single GPU draw call — essential for performance at 64×64+ tile maps. Rebuild the batch only when the map changes, not every frame.
-- @body
local SNIP_1_r    = lurek.render
local TILE = 16
local COLS = 10
local ROWS = 8
local sheet = r.newImage("content/examples/assets/images/sample_texture.png")
local sw, sh = sheet:getDimensions()
local batch = r.newSpriteBatch(sheet, COLS * ROWS)

-- build tile map (call once or when map changes)
batch:clear()
for row = 0, ROWS - 1 do
    for col = 0, COLS - 1 do
        -- tile 0 = top-left 16x16 of sheet
        local q = r.newQuad(0, 0, TILE, TILE, sw, sh)
        batch:add(col * TILE, row * TILE, 0, 1, 1)
        _ = q
    end
end
r.draw(batch, 50, 50)
-- @end

-- @snippet lurek.render.draw_many_particles
-- @prefix lk-render-draw-many
-- @module render
-- @description Use for a pool of transient visual objects (sparks, dust motes, debris). Build the list table once per frame and pass to drawMany — one call batches all draw operations with different positions and rotations.
-- @body
local SNIP_1_r   = lurek.render
local img = r.newImage("content/examples/assets/images/sample_texture.png")

local particles = {}
for i = 1, 20 do
    local px  = math.random(50, 750)
    local py  = math.random(50, 550)
    local ang = math.random() * math.pi * 2
    local sc  = 0.1 + math.random() * 0.3
    particles[i] = { img, px, py, ang, sc, sc }
end
r.drawMany(particles)
-- @end

-- @snippet lurek.render.quad_sprite_sheet_animate
-- @prefix lk-render-quad-anim
-- @module render
-- @description Use for frame-by-frame sprite animation from a sprite sheet. Build quads once at init, then select the current frame by index each update.
-- @body
local SNIP_1_r     = lurek.render
local sheet = r.newImage("content/examples/assets/images/sample_texture.png")
local sw, sh = sheet:getDimensions()
local FRAME_W, FRAME_H = 16, 16
local FRAME_COUNT = 4
local frame_duration = 0.12   -- seconds per frame
local quads = {}
for i = 0, FRAME_COUNT - 1 do
    quads[i + 1] = r.newQuad(i * FRAME_W, 0, FRAME_W, FRAME_H, sw, sh)
end
-- in update(dt): anim_timer = anim_timer + dt; if anim_timer >= frame_duration then ...
local current_frame = 1   -- index into quads[]
r.draw(sheet, 300, 300)   -- placeholder: real usage: r.drawq(sheet, quads[current_frame], x, y)
_ = quads
-- @end

-- ─────────────────────────────────────────────────────────────
-- DECORATIVE & SPECIAL SHAPES
-- ─────────────────────────────────────────────────────────────

-- @snippet lurek.render.gradient_banner_title
-- @prefix lk-render-gradient-banner
-- @module render
-- @description Use for title screens, section headers, or UI banners. drawGradientRect creates a smooth horizontal fade; printf centres the text on top.
-- @body
local SNIP_1_r   = lurek.render
local bx, by, bw, bh = 100, 200, 600, 64
r.drawGradientRect(bx, by, bw, bh, {0.1, 0.05, 0.4}, {0.6, 0.1, 0.2}, "horizontal")
r.setColor(1, 1, 1, 1)
r.printf("LEVEL COMPLETE", bx, by + 20, bw, "center")
-- @end

-- @snippet lurek.render.hex_tile_grid
-- @prefix lk-render-hex-grid
-- @module render
-- @description Use for hex-grid strategy or board game views. Iterates a grid of pointy- top hex tiles with the standard offset stagger between columns.
-- @body
local SNIP_1_r      = lurek.render
local RADIUS = 20
local COLS, ROWS = 6, 5
for col = 0, COLS - 1 do
    for row = 0, ROWS - 1 do
        local hx = 60 + col * (RADIUS * math.sqrt(3))
        local hy = 60 + row * (RADIUS * 2) + (col % 2 == 1 and RADIUS or 0)
        r.setColor(0.2, 0.55, 0.35, 1)
        r.drawHexTile(hx, hy, RADIUS, "pointyTop", "fill")
        r.setColor(0.1, 0.3, 0.2, 1)
        r.drawHexTile(hx, hy, RADIUS, "pointyTop", "line")
    end
end
r.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.render.iso_cube_tile_wall
-- @prefix lk-render-iso-cube
-- @module render
-- @description Use to draw isometric cube walls and floors. Vary topColor / leftColor / rightColor to encode terrain elevation, shadow, or material type while keeping a consistent isometric projection.
-- @body
local SNIP_1_r      = lurek.render
local tile_w = 64
local tile_h = 32
local walls  = {
    { col=0, row=0, depth=20, top={0.7,0.7,0.7,1}, left={0.45,0.45,0.45,1}, right={0.3,0.3,0.3,1} },
    { col=1, row=0, depth=20, top={0.3,0.6,0.3,1}, left={0.2,0.4,0.2,1},   right={0.1,0.25,0.1,1} },
}
for _, t in ipairs(walls) do
    local sx = 200 + (t.col - t.row) * tile_w * 0.5
    local sy = 150 + (t.col + t.row) * tile_h * 0.5
    r.drawIsoCubeTile(sx, sy, tile_w, tile_h,
        { depth=t.depth, topColor=t.top, leftColor=t.left, rightColor=t.right })
end
-- @end

-- @snippet lurek.render.bevel_rect_ui_panel
-- @prefix lk-render-bevel-panel
-- @module render
-- @description Use for retro / classic UI panels and inset fields. drawBevelRect provides raised, sunken, groove, and ridge effects with a single call — no extra image assets needed.
-- @body
local SNIP_1_r = lurek.render
-- window frame: raised
r.drawBevelRect(50, 50, 300, 200, 3, "raised")
-- inset content area: sunken
r.drawBevelRect(60, 90, 280, 150, 2, "sunken")
-- status bar: groove
r.drawBevelRect(60, 100, 280, 20, 1, "groove")
r.setColor(0.9, 0.9, 0.9, 1)
r.print("Health: 80 / 100", 70, 104)
r.setColor(1, 1, 1, 1)
-- @end

-- @snippet lurek.render.rich_text_colored_status
-- @prefix lk-render-rich-text
-- @module render
-- @description Use for status messages, chat lines, or dialogue that mix multiple colours and sizes in one string. printRich accepts a span table — no manual x offset bookkeeping required.
-- @body
local SNIP_1_r     = lurek.render
local spans = {
    { text = "HP ",    r=0.8, g=0.2, b=0.2, a=1, scale=1   },
    { text = "45",     r=1,   g=0,   b=0,   a=1, scale=1.2 },
    { text = " / 100 ", r=0.8, g=0.8, b=0.8, a=0.8, scale=1 },
    { text = "[low]",  r=1,   g=0.5, b=0,   a=1, scale=0.9 },
}
r.printRich(spans, 20, 560)
-- @end

-- @snippet lurek.render.wireframe_debug_toggle
-- @prefix lk-render-wireframe
-- @module render
-- @description Use during collision-mesh debugging to switch all filled shapes to outline mode for one frame, then restore normal fill — revealing triangle topology without permanently changing draw calls.
-- @body
local SNIP_1_r = lurek.render
if lurek.engine.isDebug() then
    r.setWireframe(true)
    -- draw filled geometry as wireframe:
    r.setColor(0, 1, 0.5, 1)
    r.rectangle("fill", 100, 100, 200, 150)
    r.circle("fill", 300, 200, 50)
    r.setWireframe(false)
end
-- @end
