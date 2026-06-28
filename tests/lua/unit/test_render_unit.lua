-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_render_core_unit.lua
do
-- Lurek2D Graphics API Tests (headless  tests lurek.render API existence and behaviour)

local function icon_image()
    return lurek.render.newImage("assets/icon.png")
end

local function sample_texture_image()
    return lurek.render.newImage("content/examples/assets/images/sample_texture.png")
end

local function default_font()
    return lurek.render.getDefaultFont()
end

local function minimal_shader_code()
    return "@fragment fn fs() -> @location(0) vec4<f32> { return vec4<f32>(1.0); }"
end

local function draw_shader_code()
    return [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + vec3<f32>(uv, 0.0), color.a);
}
]]
end

local function screen_shader_code()
    return [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>, @location(3) resolution: vec2<f32>, @location(4) texel: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + texel.xyx * resolution.x * 0.001 + pixel.xyx * 0.0 + uv.xyx * 0.0, color.a);
}
]]
end

local function particle_shader_code()
    return [[
@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
    @location(3) world_pos: vec2<f32>,
    @location(4) velocity: vec2<f32>,
    @location(5) age: f32,
    @location(6) lifetime: f32,
    @location(7) seed: f32,
    @location(8) sampled_color: vec4<f32>
) -> @location(0) vec4<f32> {
    return sampled_color + color * 0.0 + vec4<f32>(uv + local_pos * 0.0 + world_pos * 0.0 + velocity * 0.0, age + lifetime + seed, 0.0);
}
]]
end

local function light_shader_code()
    return [[
@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) world_pos: vec2<f32>,
    @location(3) light_pos: vec2<f32>,
    @location(4) normal_hint: vec2<f32>,
    @location(5) distance_norm: f32,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) shadow_factor: f32,
    @location(9) ambient_color: vec4<f32>,
    @location(10) direction_spot: vec4<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * intensity * shadow_factor + (uv + world_pos + light_pos + normal_hint).x * 0.0 + ambient_color.rgb * 0.0 + direction_spot.xyz * 0.0, color.a + distance_norm * 0.0 + radius * 0.0 + direction_spot.w * 0.0);
}
]]
end

local function simple_mesh()
    return lurek.render.newMesh({
        { 0, 0, 0, 0, 1, 1, 1, 1 },
        { 50, 0, 1, 0, 1, 1, 1, 1 },
        { 25, 40, 0.5, 1, 1, 1, 1, 1 },
    })
end

-- @describe lurek.render module exists
describe("lurek.render module exists", function()
    -- @covers lurek.render.newDepthSorter
    it("newDepthSorter creates an empty depth sorter", function()
        local sorter = lurek.render.newDepthSorter()
        expect_type("userdata", sorter)
        expect_equal("LDepthSorter", sorter:type())
        expect_true(sorter:typeOf("LDepthSorter"))
        expect_equal(0, sorter:getCount())
    end)
end)

-- @describe lurek.render color functions
describe("lurek.render color functions", function()
    -- @covers lurek.render.setColor
    it("setColor accepts rgb and rgba arguments", function()
        expect_no_error(function()
            lurek.render.setColor(1, 0, 0)
        end)
        expect_no_error(function()
            lurek.render.setColor(1, 0, 0, 0.5)
        end)
    end)

    -- @covers lurek.render.setBackgroundColor
    it("setBackgroundColor accepts 3 args", function()
        expect_no_error(function()
            lurek.render.setBackgroundColor(0.1, 0.1, 0.1)
        end)
    end)

    -- @covers lurek.render.getBackgroundColor
    it("getBackgroundColor returns four components", function()
        local r, g, b, a = lurek.render.getBackgroundColor()
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", a)
    end)
end)

-- @describe lurek.render shape functions
describe("lurek.render shape functions", function()
    -- @covers lurek.render.rectangle
    it("rectangle supports fill and line modes", function()
        expect_no_error(function()
            lurek.render.rectangle("fill", 10, 10, 100, 50)
        end)
        expect_no_error(function()
            lurek.render.rectangle("line", 10, 10, 100, 50)
        end)
    end)

    -- @covers lurek.render.circle
    it("circle fill mode", function()
        expect_no_error(function()
            lurek.render.circle("fill", 50, 50, 25)
        end)
    end)

    -- @covers lurek.render.line
    it("line accepts 4 args", function()
        expect_no_error(function()
            lurek.render.line(0, 0, 100, 100)
        end)
    end)

    -- @covers lurek.render.arc
    it("arc accepts fill and line arc parameters", function()
        expect_no_error(function()
            lurek.render.arc("fill", 40, 40, 16, 0, math.pi)
        end)
        expect_no_error(function()
            lurek.render.arc("line", 40, 40, 16, math.pi, math.pi * 1.5, 12)
        end)
    end)
end)

-- @describe lurek.render text functions
describe("lurek.render text functions", function()
    -- @covers lurek.render.print
    it("print accepts text and position", function()
        expect_no_error(function()
            lurek.render.print("Hello", 10, 10)
        end)
    end)

    -- @covers lurek.render.printf
    it("printf accepts text, bounds, and alignment", function()
        expect_no_error(function()
            lurek.render.printf("Centered text", 10, 10, 160, "center")
        end)
    end)

    -- @covers lurek.render.printRich
    it("printRich accepts styled text spans and optional GPU transform parameters", function()
        local spans = {
            { text = "Hello ", color = { 1, 0, 0, 1 } },
            { text = "Render", color = { 0, 1, 0, 1 } },
        }
        expect_no_error(function()
            lurek.render.printRich(spans, 10, 20)
        end)
        local transformed_spans = {
            { text = "Hot ", r = 255, g = 128, b = 80, a = 255, scale = 1 },
            { text = "swap", r = 120, g = 220, b = 255, a = 255, scale = 1.2 },
        }
        expect_no_error(function()
            lurek.render.printRich(transformed_spans, 24, 28, -0.2, 1.4, 1.0, 4, 3)
        end)
    end)

    -- @covers lurek.render.drawText
    it("drawText accepts GPU transform parameters", function()
        expect_no_error(function()
            lurek.render.setColor(0.8, 0.9, 1.0, 0.75)
            lurek.render.drawText("GPU text", 40, 32, 0.35, 1.5, 1.25, 8, 6)
            lurek.render.setColor(1, 1, 1, 1)
        end)
    end)

end)

-- @describe lurek.render advanced shapes
describe("lurek.render advanced shapes", function()
    -- @covers lurek.render.ellipse
    it("ellipse fill mode", function()
        expect_no_error(function()
            lurek.render.ellipse("fill", 100, 100, 50, 30)
        end)
    end)

    -- @covers lurek.render.polygon
    it("polygon fill mode with vertices", function()
        expect_no_error(function()
            lurek.render.polygon("fill", 0, 0, 100, 0, 50, 100)
        end)
    end)

    -- @covers lurek.render.triangle
    it("triangle fill mode", function()
        expect_no_error(function()
            lurek.render.triangle("fill", 0, 0, 100, 0, 50, 80)
        end)
    end)

    -- @covers lurek.render.setLineWidth
    it("setLineWidth is callable and round-trips with getLineWidth", function()
        expect_type("function", lurek.render.setLineWidth)
        expect_type("function", lurek.render.getLineWidth)
        lurek.render.setLineWidth(3.0)
        expect_near(3.0, lurek.render.getLineWidth())
        lurek.render.setLineWidth(1.0) -- reset
    end)

    -- @covers lurek.render.getDimensions
    it("getDimensions returns two numbers", function()
        local w, h = lurek.render.getDimensions()
        expect_type("number", w)
        expect_type("number", h)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)

    -- @covers lurek.render.getLineWidth
    it("getLineWidth returns the current line width", function()
        lurek.render.setLineWidth(2.5)
        expect_near(2.5, lurek.render.getLineWidth())
        lurek.render.setLineWidth(1.0)
    end)

    -- @covers lurek.render.setPointSize
    it("setPointSize updates the active point size", function()
        lurek.render.setPointSize(6)
        expect_near(6, lurek.render.getPointSize())
        lurek.render.setPointSize(1)
    end)

    -- @covers lurek.render.getPointSize
    it("getPointSize returns the current point size", function()
        lurek.render.setPointSize(7)
        expect_near(7, lurek.render.getPointSize())
        lurek.render.setPointSize(1)
    end)

    -- @covers lurek.render.drawCubicBezier
    it("drawCubicBezier accepts start, controls, end, and segments", function()
        expect_no_error(function()
            lurek.render.drawCubicBezier(20, 40, 60, 20, 100, 60, 140, 40, 16)
        end)
    end)

    -- @covers lurek.render.drawQuadBezier
    it("drawQuadBezier accepts start, control, end, and segments", function()
        expect_no_error(function()
            lurek.render.drawQuadBezier(20, 40, 80, 10, 140, 40, 12)
        end)
    end)

    -- @covers lurek.render.drawGradientRect
    it("drawGradientRect accepts colors and direction", function()
        expect_no_error(function()
            lurek.render.drawGradientRect(10, 10, 80, 20, { 1, 0, 0, 1 }, { 0, 0, 1, 1 }, "horizontal")
        end)
    end)

    -- @covers lurek.render.drawColoredPolygon
    it("drawColoredPolygon accepts vertices and per-vertex colors", function()
        local vertices = { 0, 0, 20, 0, 10, 20 }
        local colors = {
            { 1, 0, 0, 1 },
            { 0, 1, 0, 1 },
            { 0, 0, 1, 1 },
        }
        expect_no_error(function()
            lurek.render.drawColoredPolygon(vertices, colors, "fill")
        end)
    end)

    -- @covers lurek.render.drawHexTile
    it("drawHexTile accepts size, orientation, and mode", function()
        expect_no_error(function()
            lurek.render.drawHexTile(120, 120, 24, "pointyTop", "fill")
        end)
    end)

    -- @covers lurek.render.drawIsoCubeTile
    it("drawIsoCubeTile accepts face-color options", function()
        expect_no_error(function()
            lurek.render.drawIsoCubeTile(100, 100, 20, 10, {
                depth = 12,
                topColor = { 0.8, 0.8, 0.9, 1 },
                leftColor = { 0.5, 0.5, 0.6, 1 },
                rightColor = { 0.3, 0.3, 0.4, 1 },
            })
        end)
    end)

    -- @covers lurek.render.drawBevelRect
    it("drawBevelRect accepts bevel width and style", function()
        expect_no_error(function()
            lurek.render.drawBevelRect(10, 10, 60, 20, 3, "raised")
        end)
    end)
end)

-- =========================================================================
-- Font metrics
-- =========================================================================
-- @describe font metrics
describe("font metrics", function()
    -- @covers lurek.render.getFontLineHeight
    it("getFontLineHeight is a function", function()
        expect_type("function", lurek.render.getFontLineHeight)
    end)

    -- @covers lurek.render.setFontLineHeight
    it("setFontLineHeight is a function", function()
        expect_type("function", lurek.render.setFontLineHeight)
    end)

    -- @covers lurek.render.getFontAscent
    it("getFontAscent is a function", function()
        expect_type("function", lurek.render.getFontAscent)
    end)

    -- @covers lurek.render.getFontDescent
    it("getFontDescent is a function", function()
        expect_type("function", lurek.render.getFontDescent)
    end)

    -- @covers lurek.render.getFontCellWidth
    it("getFontCellWidth returns a numeric cell width for a font", function()
        expect_type("number", lurek.render.getFontCellWidth(default_font()))
    end)

    -- @covers lurek.render.getFontWrap
    it("getFontWrap returns wrapped lines and width", function()
        local lines, width = lurek.render.getFontWrap("hello wrapped render world", 40)
        expect_type("table", lines)
        expect_type("number", width)
    end)
end)

-- Nine-Slice Tests

-- @describe lurek.render nine-slice
describe("lurek.render nine-slice", function()
    -- @covers LNineSlice:getTextureSize
    it("getTextureSize returns the source texture dimensions", function()
        local ns = lurek.sprite.newNineSlice(icon_image(), 4, 4, 4, 4)
        local w, h = ns:getTextureSize()
        expect_true(w > 0)
        expect_true(h > 0)
    end)

    -- @covers LNineSlice:typeOf
    it("typeOf recognizes nine-slice userdata and objects", function()
        local ns = lurek.sprite.newNineSlice(icon_image(), 4, 4, 4, 4)
        expect_true(ns:typeOf("LNineSlice"))
        expect_true(ns:typeOf("LObject"))
        expect_false(ns:typeOf("LImage"))
    end)

    -- @covers lurek.render.drawNineSlice
    it("drawNineSlice is callable for different rects", function()
        expect_type("function", lurek.render.drawNineSlice)
        local img = lurek.render.newImage("assets/icon.png")
        local ns = lurek.sprite.newNineSlice(img, 10, 10, 10, 10)
        expect_no_error(function()
            lurek.render.drawNineSlice(ns, 50, 50, 300, 200)
        end)
        expect_no_error(function()
            lurek.render.drawNineSlice(ns, 10, 20, 400, 300)
        end)
    end)
end)

-- Polymorphic draw() dispatch

-- @describe lurek.render.draw polymorphic dispatch
describe("lurek.render.draw polymorphic dispatch", function()
    -- @covers lurek.render.draw
    it("draw() is callable and rejects invalid drawables", function()
        expect_type("function", lurek.render.draw)
        expect_error(function()
            local bad = nil ---@type any
            lurek.render.draw(bad, 0, 0)
        end, "nil")
        ---@type any
        local not_a_drawable = "not_a_drawable"
        expect_error(function()
            lurek.render.draw(not_a_drawable, 0, 0)
        end, "drawable")
    end)
end)

-- @describe lurek.render.captureScreenshot
describe("lurek.render.captureScreenshot", function()
  -- @covers lurek.render.captureScreenshot
  it("accepts a callback and passes ImageData userdata", function()
    local ok, err = pcall(lurek.render.captureScreenshot, function(img)
      expect_equal("userdata", type(img))
    end)
    expect_equal(ok, true)
  end)
end)

-- @describe lurek.render.saveScreenshot
describe("lurek.render.saveScreenshot", function()
    -- @covers lurek.render.saveScreenshot
    it("accepts save-relative paths and rejects paths outside save", function()
        local ok = pcall(lurek.render.saveScreenshot, "save/test_render.png")
        expect_equal(ok, true)
        expect_error(function()
            lurek.render.saveScreenshot("test_render.png")
        end, "save/")
    end)
end)

-- @describe lurek.render stencil mode
describe("lurek.render stencil mode", function()
  -- @covers lurek.render.setStencilMode
  it("setStencilMode supports round-trips, defaults, and invalid actions", function()
    expect_type("function", lurek.render.setStencilMode)
    lurek.render.setStencilMode("replace", "always", 1)
    local action, compare, value = lurek.render.getStencilMode()
    expect_equal(action, "replace")
    expect_equal(compare, "always")
    expect_equal(value, 1)
    lurek.render.setStencilMode("zero")
    action, compare, value = lurek.render.getStencilMode()
    expect_equal(action, "zero")
    expect_equal(compare, "always")
    expect_equal(value, 0)
    expect_error(function()
      lurek.render.setStencilMode("explode")
    end)
  end)

  -- @covers lurek.render.getStencilMode
  it("getStencilMode is a function", function()
    expect_type("function", lurek.render.getStencilMode)
  end)

  -- @covers lurek.render.clearStencil
  it("clearStencil is callable and resets to keep/always/0", function()
    expect_type("function", lurek.render.clearStencil)
    lurek.render.setStencilMode("invert", "equal", 5)
    lurek.render.clearStencil()
    local action, compare, value = lurek.render.getStencilMode()
    expect_equal(action, "keep")
    expect_equal(compare, "always")
    expect_equal(value, 0)
  end)
end)

-- @describe lurek.render depth mode
describe("lurek.render depth mode", function()
  -- @covers lurek.render.setDepthMode
  it("setDepthMode supports round-trips, defaults, and invalid modes", function()
    expect_type("function", lurek.render.setDepthMode)
    lurek.render.setDepthMode("less", true)
    local mode, write = lurek.render.getDepthMode()
    expect_equal(mode, "less")
    expect_equal(write, true)
    lurek.render.setDepthMode("always")
    mode, write = lurek.render.getDepthMode()
    expect_equal(mode, "always")
    expect_equal(write, false)
    expect_error(function()
      lurek.render.setDepthMode("turbo")
    end)
  end)

  -- @covers lurek.render.getDepthMode
  it("getDepthMode is a function", function()
    expect_type("function", lurek.render.getDepthMode)
  end)
end)


-- [merged from test_render_pipeline.lua]
-- Target rendering/drawing contract acceptance tests.
-- These assertions pin the intended public API from
-- work/rendering-drawing-current-state/reports/target-rendering-drawing-state.md.
-- Canonical constructors are asserted directly; legacy constructors are used only
-- as fallbacks to build objects for method-level contract checks.

local function try_call(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end
    return nil
end

local function verify_image_data_contract(img)
    expect_not_nil(img, "draw_to_image should return an image object")
    if img ~= nil then
        if type(img.width) == "function" then
            expect_true(img:width() > 0, "image width should be positive")
        elseif type(img.getWidth) == "function" then
            expect_true(img:getWidth() > 0, "image width should be positive")
        end
    end
end

local function make_spine_subject()
    if lurek.spine ~= nil then
        if type(lurek.spine.newSkeleton) == "function" then
            return lurek.spine.newSkeleton("contract")
        end
    end
    error("No usable spine constructor available for contract test")
end

local function make_raycaster_subject()
    local rc = lurek.raycaster.new(8, 8)
    rc:setCell(5, 4, 1)
    return rc
end

local function make_ui_panel_subject()
    if lurek.ui ~= nil then
        if type(lurek.ui.newPanel) == "function" then
            return lurek.ui.newPanel()
        end
    end
    error("No usable UI panel constructor available for contract test")
end

local function make_particle_subject()
    if lurek.particle ~= nil and type(lurek.particle.newSystem) == "function" then
        return lurek.particle.newSystem({ maxParticles = 8, emissionRate = 0 })
    end
    error("No usable particle constructor available for contract test")
end

local function make_tilemap_subject()
    if lurek.tilemap ~= nil then
        if type(lurek.tilemap.newTileMap) == "function" then
            local map = lurek.tilemap.newTileMap(4, 4)
            if type(map.setTile) == "function" then
                try_call(function()
                    map:setTile(1, 1, 1, 1)
                end)
            end
            return map
        end
    end
    error("No usable tilemap constructor available for contract test")
end

local function make_minimap_subject()
    if lurek.minimap ~= nil then
        if type(lurek.minimap.newMinimap) == "function" then
            local mini = lurek.minimap.newMinimap(4, 4, 64, 64)
            if type(mini.setTerrainData) == "function" then
                mini:setTerrainData({
                    1, 1, 0, 0,
                    0, 1, 1, 0,
                    0, 0, 1, 1,
                    1, 0, 0, 1,
                })
            end
            return mini
        end
    end
    error("No usable minimap constructor available for contract test")
end

local function make_overlay_subject()
    if lurek.overlay ~= nil and type(lurek.overlay.new) == "function" then
        return lurek.overlay.new(64, 64)
    end
    if lurek.effect ~= nil then
        if type(lurek.effect.newOverlay) == "function" then
            return lurek.effect.newOverlay(64, 64)
        end
    end
    error("No usable overlay constructor available for contract test")
end

local function make_parallax_subject()
    if lurek.parallax ~= nil then
        if type(lurek.parallax.newSet) == "function" then
            local set = lurek.parallax.newSet("contract")
            if type(lurek.parallax.newLayer) == "function" and lurek.render ~= nil and type(lurek.render.newImage) == "function" then
                local img = lurek.render.newImage("assets/icon.png")
                local layer = try_call(lurek.parallax.newLayer, { texture = img })
                if layer ~= nil then
                    set:addLayer(layer)
                end
            end
            return set
        end
    end
    error("No usable parallax constructor available for contract test")
end

-- @describe target rendering/drawing contract: particle
describe("target rendering/drawing contract: particle", function()
    -- @covers LParticleSystem:render
    it("particle systems expose render()", function()
        local ps = make_particle_subject()
        expect_type("function", ps.render)
        expect_no_error(function()
            ps:render()
        end)
    end)

    -- @covers LParticleSystem:drawToImage
    it("particle systems expose drawToImage()", function()
        local ps = make_particle_subject()
        expect_type("function", ps.drawToImage)
        local img = ps:drawToImage(64, 64)
        verify_image_data_contract(img)
    end)
end)

-- @describe target rendering/drawing contract: tilemap
describe("target rendering/drawing contract: tilemap", function()
    -- @covers LTileMap:render
    it("tilemaps expose render()", function()
        local map = make_tilemap_subject()
        expect_type("function", map.render)
        expect_no_error(function()
            map:render()
        end)
    end)

end)

-- @describe target rendering/drawing contract: minimap
describe("target rendering/drawing contract: minimap", function()
    -- @covers LMinimap:drawToImage
    it("minimaps expose drawToImage()", function()
        local mini = make_minimap_subject()
        expect_type("function", mini.drawToImage)
        local img = mini:drawToImage(4)
        verify_image_data_contract(img)
    end)
end)

-- @describe target rendering/drawing contract: overlay
describe("target rendering/drawing contract: overlay", function()
    -- @covers LOverlay:render
    it("overlays expose render()", function()
        local ov = make_overlay_subject()
        expect_type("function", ov.render)
        expect_no_error(function()
            ov:render()
        end)
    end)

    -- @covers LOverlay:drawToImage
    it("overlays expose drawToImage()", function()
        local ov = make_overlay_subject()
        if type(ov.flash) == "function" then
            ov:flash(1, 1, 1, 1, 0.1)
        end
        expect_type("function", ov.drawToImage)
        local img = ov:drawToImage(64, 64)
        verify_image_data_contract(img)
    end)
end)

-- @describe render strict: screen globals
describe("render strict: screen globals", function()
    -- @covers lurek.render.getColor
    it("getColor returns four number components", function()
        local r, g, b, a = lurek.render.getColor()
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", a)
    end)

    -- @covers lurek.render.clear
    it("clear is callable without error", function()
        local ok = pcall(lurek.render.clear)
        expect_true(ok)
    end)

    -- @covers lurek.render.getWidth
    it("getWidth and getHeight return numbers", function()
        expect_type("number", lurek.render.getWidth())
        expect_type("number", lurek.render.getHeight())
    end)

    -- @covers lurek.render.getHeight
    it("getHeight returns a positive number", function()
        local h = lurek.render.getHeight()
        expect_type("number", h)
        expect_true(h > 0)
    end)

    -- @covers lurek.render.getStats
    it("getStats returns a table", function()
        local stats = lurek.render.getStats()
        expect_type("table", stats)
    end)

    -- @covers lurek.render.setLayerVisible
    it("setLayerVisible is callable with a name and bool", function()
        local ok = pcall(lurek.render.setLayerVisible, "hud", false)
        expect_true(ok)
    end)
end)

-- @describe render strict: blend mode
describe("render strict: blend mode", function()
    -- @covers lurek.render.setBlendMode
    it("setBlendMode and getBlendMode round-trip", function()
        lurek.render.setBlendMode("alpha")
        local mode = lurek.render.getBlendMode()
        expect_type("string", mode)
    end)

    -- @covers lurek.render.getBlendMode
    it("getBlendMode returns the active blend mode name", function()
        lurek.render.setBlendMode("alpha")
        expect_equal("alpha", lurek.render.getBlendMode())
    end)
end)

-- @describe render strict: transform stack
describe("render strict: transform stack", function()
    -- @covers lurek.render.push
    it("push is callable without error", function()
        local ok = pcall(lurek.render.push)
        expect_true(ok)
        lurek.render.pop()
    end)

    -- @covers lurek.render.translate
    it("translate is callable without error", function()
        local ok = pcall(lurek.render.translate, 10, 20)
        expect_true(ok)
        lurek.render.origin()
    end)

    -- @covers lurek.render.rotate
    it("rotate is callable without error", function()
        local ok = pcall(lurek.render.rotate, 0.5)
        expect_true(ok)
        lurek.render.origin()
    end)

    -- @covers lurek.render.scale
    it("scale is callable without error", function()
        local ok = pcall(lurek.render.scale, 2, 2)
        expect_true(ok)
        lurek.render.origin()
    end)

    -- @covers lurek.render.shear
    it("shear is callable without error", function()
        local ok = pcall(lurek.render.shear, 0.1, 0.1)
        expect_true(ok)
        lurek.render.origin()
    end)

    -- @covers lurek.render.origin
    it("origin is callable without error", function()
        local ok = pcall(lurek.render.origin)
        expect_true(ok)
    end)

    -- @covers lurek.render.pop
    it("pop restores the previous transform stack frame", function()
        expect_no_error(function()
            lurek.render.push()
            lurek.render.translate(5, 6)
            lurek.render.pop()
        end)
    end)

    -- @covers lurek.render.applyTransform
    it("applyTransform accepts a 3x3 row-major matrix", function()
        expect_no_error(function()
            lurek.render.push()
            lurek.render.applyTransform({
                1, 0, 0,
                0, 1, 0,
                12, 18, 1,
            })
            lurek.render.pop()
        end)
    end)
end)

-- @describe render strict: canvas and shader
describe("render strict: canvas and shader", function()
    -- @covers lurek.render.setCanvas
    it("setCanvas with nil resets to screen", function()
        local ok = pcall(lurek.render.setCanvas, nil)
        expect_true(ok)
        local canvas = lurek.render.newCanvas(8, 8)
        expect_true(pcall(lurek.render.resetCanvas, canvas))
    end)

    -- @covers lurek.render.newCanvas
    it("newCanvas creates a canvas userdata with requested dimensions", function()
        local canvas = lurek.render.newCanvas(12, 9)
        expect_type("userdata", canvas)
        expect_equal(12, canvas:getWidth())
        expect_equal(9, canvas:getHeight())
    end)

    -- @covers lurek.render.resetCanvas
    it("resetCanvas accepts a canvas handle", function()
        local canvas = lurek.render.newCanvas(8, 8)
        expect_no_error(function()
            lurek.render.resetCanvas(canvas)
        end)
    end)

    -- @covers lurek.render.getCanvas
    it("getCanvas returns the currently active canvas", function()
        local canvas = lurek.render.newCanvas(8, 8)
        lurek.render.setCanvas(canvas)
        local active = lurek.render.getCanvas()
        expect_type("userdata", active)
        lurek.render.setCanvas(nil)
    end)

    -- @covers lurek.render.getCanvasSize
    it("getCanvasSize returns the width and height of a canvas", function()
        local canvas = lurek.render.newCanvas(13, 7)
        local w, h = lurek.render.getCanvasSize(canvas)
        expect_equal(13, w)
        expect_equal(7, h)
    end)

    -- @covers lurek.render.applyShaderToCanvas
    it("applyShaderToCanvas accepts postfx shaders and rejects draw shaders", function()
        local canvas = lurek.render.newCanvas(8, 8)
        local shader = lurek.render.newShader(screen_shader_code(), { target = "postfx" })
        local returned = lurek.render.applyShaderToCanvas(canvas, shader)
        expect_equal("LCanvas", returned:type())
        expect_error(function()
            lurek.render.applyShaderToCanvas(canvas, lurek.render.newShader(draw_shader_code()))
        end)
    end)

    -- @covers lurek.render.setShader
    it("setShader accepts draw shaders and rejects other targets", function()
        local draw_shader = lurek.render.newShader(minimal_shader_code())
        lurek.render.setShader(draw_shader)
        expect_type("userdata", lurek.render.getShader())
        expect_error(function()
            lurek.render.setShader(lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "image" }))
        end)
        local ok = pcall(lurek.render.setShader, nil)
        expect_true(ok)
        local s = lurek.render.getShader()
        expect_true(s == nil)
    end)

    -- @covers lurek.render.newShader
    it("newShader compiles target-aware WGSL shaders", function()
        expect_equal(nil, lurek.shader)
        local shaders = {
            lurek.render.newShader(draw_shader_code()),
            lurek.render.newShader(draw_shader_code(), { target = "draw" }),
            lurek.render.newShader(screen_shader_code(), { target = "postfx" }),
            lurek.render.newShader(screen_shader_code(), { target = "image" }),
            lurek.render.newShader(screen_shader_code(), { target = "overlay" }),
            lurek.render.newShader(particle_shader_code(), { target = "particle" }),
            lurek.render.newShader(light_shader_code(), { target = "light" }),
            lurek.render.newShader(draw_shader_code(), { target = "sprite" }),
            lurek.render.newShader(draw_shader_code(), { target = "tilemap" }),
            lurek.render.newShader(screen_shader_code(), { target = "mapviz" }),
            lurek.render.newShader(screen_shader_code(), { target = "text" }),
            lurek.render.newShader(screen_shader_code(), { target = "ui" }),
            lurek.render.newShader(screen_shader_code(), { target = "debugviz" }),
        }
        local targets = { "draw", "draw", "postfx", "image", "overlay", "particle", "light", "sprite", "tilemap", "mapviz", "text", "ui", "debugviz" }
        for i, shader in ipairs(shaders) do
            expect_type("userdata", shader)
            expect_equal(targets[i], shader:getTarget())
            expect_true(shader:getId() > 0)
        end
    end)

    -- @covers LShader:getTarget
    it("getTarget returns the render-created shader target", function()
        local shader = lurek.render.newShader(draw_shader_code(), { target = "draw" })
        expect_equal("draw", shader:getTarget())
    end)

    -- @covers LShader:getDiagnostics
    it("getDiagnostics returns validation diagnostics", function()
        local shader = lurek.render.newShader(draw_shader_code(), { target = "draw" })
        local diagnostics = shader:getDiagnostics()
        expect_type("table", diagnostics)
        expect_true(#diagnostics >= 1)
        expect_true(string.find(diagnostics[1], "draw") ~= nil)
    end)

    -- @covers lurek.render.getShader
    it("getShader returns the active shader handle", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        lurek.render.setShader(shader)
        expect_type("userdata", lurek.render.getShader())
        lurek.render.setShader(nil)
    end)

    -- @covers lurek.render.setTextShader
    it("setTextShader accepts text shaders and rejects other targets", function()
        local shader = lurek.render.newShader(screen_shader_code(), { target = "text" })
        lurek.render.setTextShader(shader)
        lurek.render.print("shader text", 4, 8)
        lurek.render.setTextShader(nil)
        expect_error(function()
            lurek.render.setTextShader(lurek.render.newShader(draw_shader_code(), { target = "draw" }))
        end)
    end)

    -- @covers lurek.render.getTextShader
    it("getTextShader returns the active text shader handle", function()
        local shader = lurek.render.newShader(screen_shader_code(), { target = "text" })
        expect_equal(nil, lurek.render.getTextShader())
        lurek.render.setTextShader(shader)
        expect_equal("text", lurek.render.getTextShader():getTarget())
        lurek.render.setTextShader(nil)
        expect_equal(nil, lurek.render.getTextShader())
    end)

    -- @covers lurek.render.setDebugShader
    it("setDebugShader accepts debugviz shaders, rejects other targets, and restores draw shader state", function()
        local draw_shader = lurek.render.newShader(draw_shader_code(), { target = "draw" })
        local debug_shader = lurek.render.newShader(screen_shader_code(), { target = "debugviz" })
        lurek.render.setShader(draw_shader)
        lurek.render.setDebugShader(debug_shader)
        lurek.render.rectangle("fill", 2, 3, 10, 8)
        expect_equal("debugviz", lurek.render.getDebugShader():getTarget())
        lurek.render.setDebugShader(nil)
        expect_equal(nil, lurek.render.getDebugShader())
        expect_equal("draw", lurek.render.getShader():getTarget())
        expect_error(function()
            lurek.render.setDebugShader(lurek.render.newShader(screen_shader_code(), { target = "overlay" }))
        end)
        lurek.render.setShader(nil)
    end)

    -- @covers lurek.render.getDebugShader
    it("getDebugShader returns nil until a debug visualization shader is active", function()
        expect_equal(nil, lurek.render.getDebugShader())
        local shader = lurek.render.newShader(screen_shader_code(), { target = "debugviz" })
        lurek.render.setDebugShader(shader)
        expect_equal("debugviz", lurek.render.getDebugShader():getTarget())
        lurek.render.setDebugShader(nil)
        expect_equal(nil, lurek.render.getDebugShader())
    end)
end)

-- @describe render strict: state toggles and layers
describe("render strict: state toggles and layers", function()
    -- @covers lurek.render.setScissor
    it("setScissor assigns and clears the active scissor rectangle", function()
        lurek.render.setScissor(20, 30, 40, 50)
        local x, y, w, h = lurek.render.getScissor()
        expect_equal(20, x)
        expect_equal(30, y)
        expect_equal(40, w)
        expect_equal(50, h)
        lurek.render.setScissor()
        local cleared_x = select(1, lurek.render.getScissor())
        expect_nil(cleared_x)
    end)

    -- @covers lurek.render.getScissor
    it("getScissor returns the current scissor rectangle", function()
        lurek.render.setScissor(1, 2, 3, 4)
        local x, y, w, h = lurek.render.getScissor()
        expect_equal(1, x)
        expect_equal(2, y)
        expect_equal(3, w)
        expect_equal(4, h)
        lurek.render.setScissor()
    end)

    -- @covers lurek.render.intersectScissor
    it("intersectScissor narrows the current scissor rectangle", function()
        lurek.render.setScissor(0, 0, 100, 100)
        lurek.render.intersectScissor(25, 30, 20, 15)
        local x, y, w, h = lurek.render.getScissor()
        expect_equal(25, x)
        expect_equal(30, y)
        expect_equal(20, w)
        expect_equal(15, h)
        lurek.render.setScissor()
    end)

    -- @covers lurek.render.setColorMask
    it("setColorMask updates the color write mask", function()
        lurek.render.setColorMask(true, false, true, false)
        local r, g, b, a = lurek.render.getColorMask()
        expect_equal(true, r)
        expect_equal(false, g)
        expect_equal(true, b)
        expect_equal(false, a)
        lurek.render.setColorMask()
    end)

    -- @covers lurek.render.getColorMask
    it("getColorMask returns four booleans", function()
        lurek.render.setColorMask(true, false, false, true)
        local r, g, b, a = lurek.render.getColorMask()
        expect_type("boolean", r)
        expect_type("boolean", g)
        expect_type("boolean", b)
        expect_type("boolean", a)
        lurek.render.setColorMask()
    end)

    -- @covers lurek.render.setWireframe
    it("setWireframe toggles wireframe rendering mode", function()
        lurek.render.setWireframe(true)
        expect_equal(true, lurek.render.isWireframe())
        lurek.render.setWireframe(false)
        expect_equal(false, lurek.render.isWireframe())
    end)

    -- @covers lurek.render.isWireframe
    it("isWireframe reports the current wireframe state", function()
        lurek.render.setWireframe(false)
        expect_equal(false, lurek.render.isWireframe())
    end)

    -- @covers lurek.render.setDefaultFilter
    it("setDefaultFilter updates the default texture filtering", function()
        lurek.render.setDefaultFilter("nearest", "nearest", 1)
        local min_filter, mag_filter, aniso = lurek.render.getDefaultFilter()
        expect_equal("nearest", min_filter)
        expect_equal("nearest", mag_filter)
        expect_type("number", aniso)
        lurek.render.setDefaultFilter("linear", "linear", 1)
    end)

    -- @covers lurek.render.getDefaultFilter
    it("getDefaultFilter returns min, mag, and anisotropy", function()
        local min_filter, mag_filter, aniso = lurek.render.getDefaultFilter()
        expect_type("string", min_filter)
        expect_type("string", mag_filter)
        expect_type("number", aniso)
    end)

    -- @covers lurek.render.newLayer
    it("newLayer creates a named rendering layer", function()
        expect_no_error(function()
            lurek.render.newLayer("render_unit_background", 0)
        end)
    end)

    -- @covers lurek.render.setLayer
    it("setLayer switches the active rendering layer", function()
        lurek.render.newLayer("render_unit_set_layer", 1)
        lurek.render.setLayer("render_unit_set_layer")
        expect_equal("render_unit_set_layer", lurek.render.currentLayer())
        lurek.render.setLayer("default")
    end)

    -- @covers lurek.render.currentLayer
    it("currentLayer returns the active layer name", function()
        lurek.render.newLayer("render_unit_current_layer", 2)
        lurek.render.setLayer("render_unit_current_layer")
        expect_equal("render_unit_current_layer", lurek.render.currentLayer())
        lurek.render.setLayer("default")
    end)

    -- @covers lurek.render.isLayerVisible
    it("isLayerVisible reflects the visibility flag of a layer", function()
        lurek.render.newLayer("render_unit_visibility", 3)
        lurek.render.setLayerVisible("render_unit_visibility", false)
        expect_equal(false, lurek.render.isLayerVisible("render_unit_visibility"))
        lurek.render.setLayerVisible("render_unit_visibility", true)
        expect_equal(true, lurek.render.isLayerVisible("render_unit_visibility"))
    end)

    -- @covers lurek.render.getLayerZOrder
    it("getLayerZOrder returns the z-order of a named layer", function()
        lurek.render.newLayer("render_unit_z_read", 4)
        expect_equal(4, lurek.render.getLayerZOrder("render_unit_z_read"))
    end)

    -- @covers lurek.render.setLayerZOrder
    it("setLayerZOrder updates the z-order of a named layer", function()
        lurek.render.newLayer("render_unit_z_write", 1)
        lurek.render.setLayerZOrder("render_unit_z_write", 9)
        expect_equal(9, lurek.render.getLayerZOrder("render_unit_z_write"))
    end)

    -- @covers lurek.render.pushLayer
    it("pushLayer starts a compositing layer", function()
        expect_no_error(function()
            lurek.render.pushLayer(101, 0.75, "alpha")
            lurek.render.popLayer(101)
        end)
    end)

    -- @covers lurek.render.popLayer
    it("popLayer closes a compositing layer", function()
        lurek.render.pushLayer(102, 1.0, "alpha")
        expect_no_error(function()
            lurek.render.popLayer(102)
        end)
    end)

    -- @covers lurek.render.beginSortGroup
    it("beginSortGroup starts a sortable draw group", function()
        expect_no_error(function()
            lurek.render.beginSortGroup(201)
            lurek.render.flushSortGroup(201)
        end)
    end)

    -- @covers lurek.render.pushSortKey
    it("pushSortKey accepts a depth key inside a sort group", function()
        lurek.render.beginSortGroup(202)
        expect_no_error(function()
            lurek.render.pushSortKey(5)
        end)
        lurek.render.flushSortGroup(202)
    end)

    -- @covers lurek.render.flushSortGroup
    it("flushSortGroup closes the current sort group", function()
        lurek.render.beginSortGroup(203)
        lurek.render.pushSortKey(2)
        expect_no_error(function()
            lurek.render.flushSortGroup(203)
        end)
    end)
end)

-- @describe render strict: drawing primitives
describe("render strict: drawing primitives", function()
    -- @covers lurek.render.points
    it("points is callable with a coordinate table", function()
        local ok = pcall(lurek.render.points, { {0, 0}, {1, 1} })
        expect_true(ok)
    end)

    -- @covers lurek.render.drawPath
    it("drawPath is callable with moveTo and lineTo segments", function()
        local path = {
            { type="moveTo", x=0, y=0 },
            { type="lineTo", x=10, y=10 },
        }
        local ok = pcall(lurek.render.drawPath, path, "line", false)
        expect_true(ok)
    end)
end)

-- @describe render strict: stencil
describe("render strict: stencil", function()
    -- @covers lurek.render.stencil
    it("stencil is callable with action and value", function()
        local ok = pcall(lurek.render.stencil, "replace", 1)
        expect_true(ok)
    end)

    -- @covers lurek.render.setStencilTest
    it("setStencilTest accepts compare state and can be cleared", function()
        expect_no_error(function()
            lurek.render.setStencilTest("always", 0)
            lurek.render.setStencilTest()
        end)
    end)
end)

-- @describe render strict: LNineSlice methods
describe("render strict: LNineSlice methods", function()
    -- @covers LNineSlice:type
    it("LNineSlice:type returns correct string", function()
        local img = lurek.render.newImage("assets/icon.png")
        local ns = lurek.sprite.newNineSlice(img, 10, 10, 10, 10)
        expect_equal(ns:type(), "LNineSlice")
    end)
end)

-- @describe render strict: LImage methods
describe("render strict: LImage methods", function()
    -- @covers LImage:type
    it("LImage type and typeOf return correct strings", function()
        local img = lurek.render.newImage("assets/icon.png")
        expect_equal(img:type(), "LImage")
        expect_true(img:typeOf("LImage"))
    end)

    -- @covers LImage:typeOf
    it("LImage typeOf recognizes image userdata and objects", function()
        local img = icon_image()
        expect_true(img:typeOf("LImage"))
        expect_true(img:typeOf("LObject"))
        expect_false(img:typeOf("LCanvas"))
    end)

    -- @covers LImage:getWidth
    it("LImage getWidth and getHeight return numbers", function()
        local img = lurek.render.newImage("assets/icon.png")
        expect_type("number", img:getWidth())
        expect_type("number", img:getHeight())
    end)

    -- @covers LImage:getHeight
    it("LImage getHeight returns a number", function()
        local img = icon_image()
        expect_type("number", img:getHeight())
    end)

    -- @covers LImage:getId
    it("LImage getId returns a number", function()
        local img = lurek.render.newImage("assets/icon.png")
        expect_type("number", img:getId())
    end)

    -- @covers LImage:getDimensions
    it("LImage getDimensions returns two numbers", function()
        local img = lurek.render.newImage("assets/icon.png")
        local w, h = img:getDimensions()
        expect_type("number", w)
        expect_type("number", h)
    end)

    -- @covers LImage:release
    it("LImage release is callable without error", function()
        local img = lurek.render.newImage("assets/icon.png")
        local ok = pcall(function() img:release() end)
        expect_true(ok)
    end)
end)

-- @describe render strict: LFont methods
describe("render strict: LFont methods", function()
    -- @covers LFont:type
    it("LFont type and typeOf return correct strings", function()
        local font = lurek.render.getDefaultFont()
        expect_equal(font:type(), "LFont")
        expect_true(font:typeOf("LFont"))
    end)

    -- @covers LFont:typeOf
    it("LFont typeOf recognizes font userdata and objects", function()
        local font = default_font()
        expect_true(font:typeOf("LFont"))
        expect_true(font:typeOf("LObject"))
        expect_false(font:typeOf("LImage"))
    end)

    -- @covers LFont:getWidth
    it("LFont getWidth returns a number for a string", function()
        local font = lurek.render.getDefaultFont()
        expect_type("number", font:getWidth("hello"))
    end)

    -- @covers LFont:getHeight
    it("LFont getHeight returns a number", function()
        local font = lurek.render.getDefaultFont()
        expect_type("number", font:getHeight())
    end)

    -- @covers LFont:getWrap
    it("LFont getWrap returns lines and width", function()
        local font = lurek.render.getDefaultFont()
        local lines, max_w = font:getWrap("hello world", 100)
        expect_type("table", lines)
        -- max_w may be number or nil depending on build
        expect_true(max_w == nil or type(max_w) == "number")
    end)

    -- @covers LFont:setLineHeight
    it("setLineHeight updates the font line height", function()
        local font = lurek.render.newFont(12)
        local before = font:getHeight()
        font:setLineHeight(before + 3)
        expect_true(font:getHeight() >= before)
    end)

    -- @covers LFont:release
    it("LFont release is callable without error", function()
        local font = lurek.render.newFont(12)
        local ok = pcall(function() font:release() end)
        expect_true(ok)
    end)
end)

-- @describe render strict: LCanvas methods
describe("render strict: LCanvas methods", function()
    -- @covers LCanvas:type
    it("LCanvas type and typeOf return correct strings", function()
        local canvas = lurek.render.newCanvas(8, 8)
        expect_equal(canvas:type(), "LCanvas")
        expect_true(canvas:typeOf("LCanvas"))
    end)

    -- @covers LCanvas:typeOf
    it("LCanvas typeOf recognizes canvas userdata and objects", function()
        local canvas = lurek.render.newCanvas(8, 8)
        expect_true(canvas:typeOf("LCanvas"))
        expect_true(canvas:typeOf("LObject"))
        expect_false(canvas:typeOf("LImage"))
    end)

    -- @covers LCanvas:getWidth
    it("LCanvas getWidth and getHeight return numbers", function()
        local canvas = lurek.render.newCanvas(8, 8)
        expect_type("number", canvas:getWidth())
        expect_type("number", canvas:getHeight())
    end)

    -- @covers LCanvas:getHeight
    it("LCanvas getHeight returns a number", function()
        local canvas = lurek.render.newCanvas(8, 8)
        expect_type("number", canvas:getHeight())
    end)

    -- @covers LCanvas:getDimensions
    it("LCanvas getDimensions returns two numbers", function()
        local canvas = lurek.render.newCanvas(8, 8)
        local w, h = canvas:getDimensions()
        expect_type("number", w)
        expect_type("number", h)
    end)

    -- @covers LCanvas:applyShader
    it("LCanvas applyShader accepts postfx shaders and rejects draw shaders", function()
        local canvas = lurek.render.newCanvas(8, 8)
        local shader = lurek.render.newShader(screen_shader_code(), { target = "postfx" })
        local returned = canvas:applyShader(shader)
        expect_equal("LCanvas", returned:type())
        expect_error(function()
            canvas:applyShader(lurek.render.newShader(draw_shader_code()))
        end)
    end)

    -- @covers LCanvas:release
    it("LCanvas release is callable without error", function()
        local canvas = lurek.render.newCanvas(8, 8)
        local ok = pcall(function() canvas:release() end)
        expect_true(ok)
    end)
end)

-- @describe render strict: LSpriteBatch methods
describe("render strict: LSpriteBatch methods", function()
    -- @covers LSpriteBatch:type
    it("LSpriteBatch type and typeOf return correct strings", function()
        local img = lurek.render.newImage("assets/icon.png")
        local sb = lurek.render.newSpriteBatch(img, 8)
        expect_equal(sb:type(), "LSpriteBatch")
        expect_true(sb:typeOf("LSpriteBatch"))
    end)

    -- @covers LSpriteBatch:typeOf
    it("LSpriteBatch typeOf recognizes sprite batches and objects", function()
        local sb = lurek.render.newSpriteBatch(icon_image(), 8)
        expect_true(sb:typeOf("LSpriteBatch"))
        expect_true(sb:typeOf("LObject"))
        expect_false(sb:typeOf("LImage"))
    end)

    -- @covers LSpriteBatch:getCount
    it("LSpriteBatch getCount and getBufferSize return numbers", function()
        local img = lurek.render.newImage("assets/icon.png")
        local sb = lurek.render.newSpriteBatch(img, 8)
        expect_type("number", sb:getCount())
        expect_type("number", sb:getBufferSize())
    end)

    -- @covers LSpriteBatch:add
    it("LSpriteBatch add returns the inserted sprite index", function()
        local sb = lurek.render.newSpriteBatch(icon_image(), 8)
        local idx = sb:add(10, 20, 0, 1, 1, 0, 0)
        expect_type("number", idx)
        expect_equal(1, sb:getCount())
    end)

    -- @covers LSpriteBatch:getBufferSize
    it("LSpriteBatch getBufferSize returns the configured capacity", function()
        local sb = lurek.render.newSpriteBatch(icon_image(), 8)
        expect_equal(8, sb:getBufferSize())
    end)

    -- @covers LSpriteBatch:clear
    it("LSpriteBatch clear is callable without error", function()
        local img = lurek.render.newImage("assets/icon.png")
        local sb = lurek.render.newSpriteBatch(img, 8)
        local ok = pcall(function() sb:clear() end)
        expect_true(ok)
    end)

    -- @covers LSpriteBatch:release
    it("LSpriteBatch release is callable without error", function()
        local img = lurek.render.newImage("assets/icon.png")
        local sb = lurek.render.newSpriteBatch(img, 8)
        local ok = pcall(function() sb:release() end)
        expect_true(ok)
    end)
end)

-- @describe render strict: LMesh methods
describe("render strict: LMesh methods", function()
    -- @covers LMesh:type
    it("LMesh type and typeOf return correct strings", function()
        local mesh = lurek.render.newMesh({
            {0,0,0,0}, {1,0,1,0}, {0.5,1,0.5,1}
        })
        expect_equal(mesh:type(), "LMesh")
        expect_true(mesh:typeOf("LMesh"))
    end)

    -- @covers LMesh:typeOf
    it("LMesh typeOf recognizes mesh userdata and objects", function()
        local mesh = simple_mesh()
        expect_true(mesh:typeOf("LMesh"))
        expect_true(mesh:typeOf("LObject"))
        expect_false(mesh:typeOf("LShader"))
    end)

    -- @covers LMesh:getVertexCount
    it("LMesh getVertexCount returns the number of vertices", function()
        local mesh = simple_mesh()
        expect_equal(3, mesh:getVertexCount())
    end)

    -- @covers LMesh:getVertex
    it("LMesh getVertex returns the indexed vertex data", function()
        local mesh = simple_mesh()
        local x, y, u, v, r, g, b, a = mesh:getVertex(2)
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", u)
        expect_type("number", v)
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", a)
    end)

    -- @covers LMesh:setVertex
    it("LMesh setVertex updates one vertex row", function()
        local mesh = simple_mesh()
        mesh:setVertex(1, { 10, 11, 0, 0, 1, 0, 0, 1 })
        local x, y = mesh:getVertex(1)
        expect_equal(10, x)
        expect_equal(11, y)

        local ok = pcall(function()
            mesh:setVertex(99, { 0, 0, 0, 0, 1, 1, 1, 1 })
        end)
        expect_false(ok)
    end)

    -- @covers LMesh:setTexture
    it("LMesh setTexture with nil is callable without error", function()
        local mesh = lurek.render.newMesh({
            {0,0,0,0}, {1,0,1,0}, {0.5,1,0.5,1}
        })
        local ok = pcall(function() mesh:setTexture(nil) end)
        expect_true(ok)
    end)

    -- @covers LMesh:release
    it("LMesh release is callable without error", function()
        local mesh = lurek.render.newMesh({
            {0,0,0,0}, {1,0,1,0}, {0.5,1,0.5,1}
        })
        local ok = pcall(function() mesh:release() end)
        expect_true(ok)
    end)
end)

-- @describe render strict: LShader methods
describe("render strict: LShader methods", function()
    -- @covers LShader:type
    it("LShader type and typeOf return correct strings", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        expect_equal(shader:type(), "LShader")
        expect_true(shader:typeOf("LShader"))
    end)

    -- @covers LShader:typeOf
    it("LShader typeOf recognizes shader userdata and objects", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        expect_true(shader:typeOf("LShader"))
        expect_true(shader:typeOf("LObject"))
        expect_false(shader:typeOf("LMesh"))
    end)

    -- @covers LShader:send
    it("LShader send with a uniform name and value is callable", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        local ok = pcall(function() shader:send("u_time", 1.0) end)
        expect_true(ok)
    end)

    -- @covers LShader:hasUniform
    it("LShader hasUniform returns a boolean for a queried name", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        expect_type("boolean", shader:hasUniform("u_time"))
    end)

    -- @covers LShader:getId
    it("LShader getId returns a numeric shader handle", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        expect_type("number", shader:getId())
    end)

    -- @covers LShader:release
    it("LShader release is callable without error", function()
        local shader = lurek.render.newShader(minimal_shader_code())
        local ok = pcall(function() shader:release() end)
        expect_true(ok)
    end)
end)

-- @describe render strict: LQuad methods
describe("render strict: LQuad methods", function()
    -- @covers LQuad:type
    it("LQuad type and typeOf return correct strings", function()
        local q = lurek.render.newQuad(0, 0, 1, 1, 1, 1)
        expect_equal(q:type(), "LQuad")
        expect_true(q:typeOf("LQuad"))
    end)

    -- @covers LQuad:typeOf
    it("LQuad typeOf recognizes quad userdata and objects", function()
        local q = lurek.render.newQuad(0, 0, 1, 1, 8, 8)
        expect_true(q:typeOf("LQuad"))
        expect_true(q:typeOf("LObject"))
        expect_false(q:typeOf("LImage"))
    end)

    -- @covers LQuad:getViewport
    it("LQuad getViewport returns four numbers", function()
        local q = lurek.render.newQuad(0, 0, 8, 8, 32, 32)
        local x, y, w, h = q:getViewport()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", w)
        expect_type("number", h)
    end)

    -- @covers LQuad:setViewport
    it("LQuad setViewport is callable without error", function()
        local q = lurek.render.newQuad(0, 0, 8, 8, 32, 32)
        local ok = pcall(function() q:setViewport(0, 0, 4, 4) end)
        expect_true(ok)
    end)

    -- @covers LQuad:getTextureDimensions
    it("LQuad getTextureDimensions returns the source texture size", function()
        local q = lurek.render.newQuad(0, 0, 8, 8, 32, 48)
        local w, h = q:getTextureDimensions()
        expect_equal(32, w)
        expect_equal(48, h)
    end)
end)

-- @describe render strict: LShape methods
describe("render strict: LShape methods", function()
    -- @covers LShape:type
    it("LShape type and typeOf return correct strings", function()
        local shape = lurek.render.newShape()
        expect_equal(shape:type(), "LShape")
        expect_true(shape:typeOf("LObject"))
    end)

    -- @covers LShape:typeOf
    it("LShape typeOf recognizes shape userdata and objects", function()
        local shape = lurek.render.newShape()
        expect_true(shape:typeOf("LShape"))
        expect_true(shape:typeOf("LObject"))
        expect_false(shape:typeOf("LMesh"))
    end)
end)

-- @describe render strict: batch text and OBJ APIs
describe("render strict: batch text and OBJ APIs", function()
    -- @covers lurek.render.newSpriteBatch
    it("newSpriteBatch creates a sprite-batch userdata", function()
        local sb = lurek.render.newSpriteBatch(icon_image(), 8)
        expect_type("userdata", sb)
    end)

    -- @covers lurek.render.drawBatch
    it("drawBatch accepts a sprite batch handle", function()
        local sb = lurek.render.newSpriteBatch(icon_image(), 8)
        sb:add(4, 6, 0, 1, 1, 0, 0)
        expect_no_error(function()
            lurek.render.drawBatch(sb)
        end)
    end)

    -- @covers lurek.render.newQuad
    it("newQuad creates a quad userdata", function()
        local q = lurek.render.newQuad(0, 0, 8, 8, 32, 32)
        expect_type("userdata", q)
    end)

    -- @covers lurek.render.drawq
    it("drawq accepts an image and quad pair", function()
        local img = icon_image()
        local q = lurek.render.newQuad(0, 0, 8, 8, img:getWidth(), img:getHeight())
        expect_no_error(function()
            lurek.render.drawq(img, q, 5, 6, 0, 1, 1, 0, 0)
        end)
    end)

    -- @covers lurek.render.newMesh
    it("newMesh creates a mesh userdata", function()
        local mesh = simple_mesh()
        expect_type("userdata", mesh)

        local partial_ok = pcall(function()
            lurek.render.newMesh({
                { 0, 0, 0, 0 },
                { 1, 0, 1, 0 },
                { 0, 1, 0, 1 },
                { 1, 1, 1, 1 },
            }, "triangles")
        end)
        expect_false(partial_ok)

        local nan = 0 / 0
        local nan_ok = pcall(function()
            lurek.render.newMesh({
                { nan, 0, 0, 0 },
                { 1, 0, 1, 0 },
                { 0, 1, 0, 1 },
            })
        end)
        expect_false(nan_ok)
    end)

    -- @covers lurek.render.drawMany
    it("drawMany accepts batched draw entries", function()
        local img = lurek.render.newImage("assets/icon.png")
        local ok = pcall(function()
            lurek.render.drawMany({
                { img, 0, 0 },
                { img, 10, 8, 0.0, 1.0, 1.0, 0.0, 0.0 },
            })
        end)
        expect_true(ok)
    end)

    -- @covers lurek.render.printRotated
    it("printRotated is callable", function()
        local ok = pcall(function()
            lurek.render.printRotated("rot", 20, 20, 0.25, 1.0)
        end)
        expect_true(ok)
    end)

    -- @covers lurek.render.newImage
    it("newImage accepts valid color-space modes and rejects unsupported ones", function()
        local ok_srgb, img_srgb = pcall(function()
            return lurek.render.newImage("assets/icon.png", "srgb")
        end)
        local ok_linear, img_linear = pcall(function()
            return lurek.render.newImage("assets/icon.png", "linear")
        end)

        expect_true(ok_srgb)
        expect_true(ok_linear)
        expect_type("userdata", img_srgb)
        expect_type("userdata", img_linear)
        expect_type("number", img_srgb:getId())
        local ok = pcall(function()
            lurek.render.newImage("assets/icon.png", "gamma")
        end)
        expect_equal(false, ok)
    end)

    -- @covers lurek.render.loadObj
    it("loads OBJ model and exposes mesh projection methods", function()
        local obj = lurek.render.loadObj("content/games/dungeon_crawler/assets/models/tank.obj")
        local mdl = lurek.render.loadModel("content/games/dungeon_crawler/assets/models/tank.obj")

        expect_type("userdata", obj)
        expect_type("userdata", mdl)
        expect_true(obj:getFaceCount() >= 0)
        expect_true(obj:getUvCount() >= 0)
        expect_true(obj:getNormalCount() >= 0)
        expect_type("number", obj:getVertexCount())

        local ok_render_to_image = pcall(function()
            obj:renderToImage(64, 64, 0.0)
        end)
        expect_type("boolean", ok_render_to_image)

        local verts = obj:projectToMesh({ x = 0, y = 4, z = 8, tx = 0, ty = 0, tz = 0, fov = 60 }, 320, 180)
        expect_type("table", verts)
    end)

    -- @covers lurek.render.loadModel
    it("loadModel returns an OBJ model userdata", function()
        local mdl = lurek.render.loadModel("content/games/dungeon_crawler/assets/models/tank.obj")
        expect_type("userdata", mdl)
    end)

    -- @covers lurek.render.setBold
    it("isBold and setBold work correctly", function()
        local prev = lurek.render.isBold()
        expect_no_error(function()
            lurek.render.setBold(true)
        end)
        expect_equal(lurek.render.isBold(), true)
        lurek.render.setBold(prev)
    end)
end)

-- @describe render strict: LObjModel methods
describe("render strict: LObjModel methods", function()
    local function load_obj_model()
        return lurek.render.loadObj("content/games/dungeon_crawler/assets/models/tank.obj")
    end

    -- @covers LObjModel:getVertexCount
    it("LObjModel getVertexCount returns a number", function()
        expect_type("number", load_obj_model():getVertexCount())
    end)

    -- @covers LObjModel:getFaceCount
    it("LObjModel getFaceCount returns a number", function()
        expect_type("number", load_obj_model():getFaceCount())
    end)

    -- @covers LObjModel:getUvCount
    it("LObjModel getUvCount returns a number", function()
        expect_type("number", load_obj_model():getUvCount())
    end)

    -- @covers LObjModel:getNormalCount
    it("LObjModel getNormalCount returns a number", function()
        expect_type("number", load_obj_model():getNormalCount())
    end)

    -- @covers LObjModel:renderToImage
    it("LObjModel renderToImage returns an image userdata", function()
        local img = load_obj_model():renderToImage(64, 64, 0.0)
        expect_type("userdata", img)
    end)

    -- @covers LObjModel:projectToMesh
    it("LObjModel projectToMesh returns projected vertex rows", function()
        local verts = load_obj_model():projectToMesh(
            { x = 0, y = 4, z = 8, tx = 0, ty = 0, tz = 0, fov = 60 },
            320,
            180
        )
        expect_type("table", verts)
    end)
end)
end
-- END test_render_core_unit.lua

-- BEGIN test_render_drawlayer_unit.lua
do
-- tests/lua/unit/test_render_drawlayer_unit.lua
-- Lurek2D BDD tests for lurek.render.newDrawLayer().

-- @describe DrawLayer creation
describe("DrawLayer creation", function()
    -- @covers lurek.render.newDrawLayer
    it("creates a DrawLayer userdata", function()
        local layer = lurek.render.newDrawLayer()
        expect_type("userdata", layer)
    end)
end)

-- @describe DrawLayer queue
describe("DrawLayer queue", function()
    -- @covers LDrawLayer:getCount
    it("getCount reflects empty, queued, flushed, and cleared states", function()
        local layer = lurek.render.newDrawLayer()
        expect_equal(0, layer:getCount())
        layer:queue(1.0, function() end)
        layer:queue(2.0, function() end)
        expect_equal(2, layer:getCount())
        layer:flush()
        expect_equal(0, layer:getCount())
        layer:queue(3.0, function() end)
        expect_equal(1, layer:getCount())
        layer:clear()
        expect_equal(0, layer:getCount())
    end)

    -- @covers LDrawLayer:queue
    it("queue accepts positive, zero, and negative z-order values", function()
        local layer = lurek.render.newDrawLayer()
        layer:queue(1.0, function() end)
        layer:queue(0.0, function() end)
        layer:queue(-5.0, function() end)
        expect_equal(3, layer:getCount())
    end)
end)

-- @describe DrawLayer flush
describe("DrawLayer flush", function()
    -- @covers LDrawLayer:flush
    it("flush orders callbacks by z and supports reuse across cycles", function()
        local layer = lurek.render.newDrawLayer()
        local order = {}

        layer:flush()

        layer:queue(3.0, function() table.insert(order, "C1") end)
        layer:queue(1.0, function() table.insert(order, "A1") end)
        layer:queue(2.0, function() table.insert(order, "B1") end)
        layer:queue(-1.0, function() table.insert(order, "N1") end)
        layer:queue(2.0, function() table.insert(order, "B2") end)
        layer:flush()

        expect_equal(5, #order)
        expect_equal("N1", order[1])
        expect_equal("A1", order[2])
        expect_equal("B1", order[3])
        expect_equal("B2", order[4])
        expect_equal("C1", order[5])

        local second_cycle = {}
        layer:queue(4.0, function() table.insert(second_cycle, "D2") end)
        layer:queue(3.0, function() table.insert(second_cycle, "C2") end)
        layer:flush()
        expect_equal("C2", second_cycle[1])
        expect_equal("D2", second_cycle[2])

        local sum = 0
        for i = 100, 1, -1 do
            layer:queue(i, function() sum = sum + 1 end)
        end
        layer:flush()
        expect_equal(100, sum)

        local nan_order = {}
        local nan = 0 / 0
        layer:queue(nan, function() table.insert(nan_order, "nan1") end)
        layer:queue(nan, function() table.insert(nan_order, "nan2") end)
        layer:flush()
        expect_equal("nan1", nan_order[1])
        expect_equal("nan2", nan_order[2])
    end)
end)

-- @describe DrawLayer clear
describe("DrawLayer clear", function()
    -- @covers LDrawLayer:clear
    it("clear removes queued callbacks, is safe on empty layers, and allows reuse", function()
        local layer = lurek.render.newDrawLayer()
        local called = false

        layer:clear()
        expect_equal(0, layer:getCount())

        layer:queue(1.0, function() called = true end)
        layer:queue(2.0, function() called = true end)
        layer:clear()
        expect_equal(0, layer:getCount())

        layer:flush()
        expect_false(called)

        layer:queue(5.0, function() called = true end)
        expect_equal(1, layer:getCount())
    end)
end)

-- @describe DrawLayer type system
describe("DrawLayer type system", function()
    -- @covers LDrawLayer:type
    it("type returns LDrawLayer", function()
        local layer = lurek.render.newDrawLayer()
        expect_equal("LDrawLayer", layer:type())
    end)

    -- @covers LDrawLayer:typeOf
    it("typeOf matches DrawLayer and Object but rejects unrelated types", function()
        local layer = lurek.render.newDrawLayer()
        expect_true(layer:typeOf("LObject"))
        expect_true(layer:typeOf("LDrawLayer"))
        expect_false(layer:typeOf("LImage"))
    end)
end)
end
-- END test_render_drawlayer_unit.lua

test_summary()
