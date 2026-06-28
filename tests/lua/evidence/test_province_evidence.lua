-- Canonical evidence file for lurek.province topology and property artifacts.

local Fixture = lurek.filesystem.load("tests/fixtures/province_evidence_fixture.lua")()
local OUT = evidence_output_dir("province")

local function registry_name(suffix)
    return "province_evidence_" .. suffix
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    elseif lurek and lurek.filesystem and lurek.filesystem.write then
        lurek.filesystem.write(path, text)
    else
        error("unable to create evidence text artifact: " .. path)
    end
    expect_evidence_created(path)
end

local function save_gif(frames, path)
    lurek.image.saveGIF(frames, path, { delayMs = 180, speed = 10, loop = true })
    expect_evidence_created(path)
end

local function mapviz_shader_code()
    return [[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0 + pixel.xyx * 0.0 + resolution.xyx * texel.x * 0.0, color.a);
}
]]
end

-- @describe Evidence: lurek.province fixture-derived artifacts
describe("Evidence: lurek.province fixture-derived artifacts", function()
    before_each(function()
        ensure_evidence_dir("province")
    end)

    -- Does: Binds a render-owned mapviz shader to a province registry and renders through the command backend.
    -- Shows: The TXT records constructor, target validation, shader id, render backend, and clear behavior.
    -- Artifact: tests/artifacts/current/province/province_shader_binding_contract.txt
    -- Why: This proves province stores only the semantic shader binding while render remains the WGSL and pipeline owner.
    it("TXT: province mapviz shader binding contract", function()
        local loaded = Fixture.load_registry(registry_name("shader"), OUT .. "province_sanitized_map.png")
        local shader = lurek.render.newShader(mapviz_shader_code(), { target = "mapviz" })
        loaded.registry:setShader(shader)
        loaded.registry:render({
            backend = "commands",
            draw_labels = false,
            draw_capitals = false,
            draw_roads = false,
        })
        local bound = loaded.registry:getShader()
        local lines = {
            "Province mapviz shader binding evidence",
            "constructor=lurek.render.newShader",
            "target=" .. shader:getTarget(),
            "shader_id=" .. shader:getId(),
            "bound_target=" .. bound:getTarget(),
            "render_path=commands",
            "gpu_backend_shadered=false",
        }
        loaded.registry:setShader(nil)
        lines[#lines + 1] = "cleared=" .. tostring(loaded.registry:getShader() == nil)
        save_text(OUT .. "province_shader_binding_contract.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Sanitizes an evidence-owned marker PNG before registry import.
    -- Shows: The PNG proves that capital and label marker pixels were replaced with surrounding province colors while the province shapes remain intact.
    -- Artifact: tests/artifacts/current/province/province_sanitized_map.png
    -- Why: This is meaningful because sanitizeMarkedPng is the province import pre-pass that turns authored marker maps back into clean ownership maps.
    it("PNG: sanitized marker map", function()
        local loaded = Fixture.load_registry(registry_name("sanitize"), OUT .. "province_sanitized_map.png")
        expect_true((loaded.summary.replaced_pixels or 0) > 0)
        expect_true((loaded.imported.mapped_provinces or 0) >= 6)
        expect_evidence_created(OUT .. "province_sanitized_map.png")
    end)

    -- Does: Extracts horizontal province span runs from the imported registry.
    -- Shows: The PNG makes raw per-province scanline runs visible as compressed geometry bands rather than a simple color screenshot.
    -- Artifact: tests/artifacts/current/province/province_span_runs.png
    -- Why: This is meaningful because provinceSpans is a province-owned geometry cache used by rendering, labels, and downstream spatial analysis.
    it("PNG: province span runs", function()
        local loaded = Fixture.load_registry(registry_name("spans"), OUT .. "province_sanitized_map.png")
        expect_true(#loaded.registry:provinceSpans() > 0)
        save_png(Fixture.render_span_runs(loaded), OUT .. "province_span_runs.png")
    end)

    -- Does: Builds adjacency border segments and asks the public province route adapter for a strategic path across neighboring provinces.
    -- Shows: The PNGs overlay province-pair borders and a multi-province route so topology extraction and route-adapter output are directly inspectable.
    -- Artifact: tests/artifacts/current/province/province_border_segments.png, province_route_trace.png
    -- Why: This is meaningful because province owns the extracted adjacency surface while reusable route search is delegated below the adapter boundary.
    it("PNG: border topology and route trace", function()
        local loaded = Fixture.load_registry(registry_name("borders"), OUT .. "province_sanitized_map.png")
        expect_true(#loaded.registry:borderSegments() > 0)
        local pairs = loaded.registry:adjacencies()
        expect_true(#pairs > 0)
        local route = loaded.registry:findRoute(pairs[1].province_a, pairs[1].province_b)
        expect_true(type(route) == "table" and #route >= 2)
        save_png(Fixture.render_border_segments(loaded), OUT .. "province_border_segments.png")
        save_png(Fixture.render_route_trace(loaded), OUT .. "province_route_trace.png")
    end)

    -- Does: Imports EU2 province metadata, then sets capital and angled label anchors on real land provinces before comparing them with computed centroids.
    -- Shows: The PNG distinguishes campaign capitals, label text/leader lines, and registry-computed province centroids on the actual EU2 source map.
    -- Artifact: tests/artifacts/current/province/province_capitals_labels_centroids.png
    -- Why: This is meaningful because province import keeps labels, capitals, and centroid geometry tied to the same province identity.
    it("PNG: capitals labels and centroids", function()
        local loaded = Fixture.load_registry(registry_name("labels"), OUT .. "province_sanitized_map.png")
        expect_true((loaded.imported.capitals_set or 0) >= 6)
        expect_true((loaded.decorated_labels or 0) >= 6)
        save_png(Fixture.render_capitals_centroids(loaded), OUT .. "province_capitals_labels_centroids.png")
    end)

    -- Does: Fits the EU2 province map into a screen, zooms around a cursor anchor, and resolves the same screen point back to map/province identity.
    -- Shows: The PNG compares the full fitted map with a zoomed crop and highlights the province returned by screenToProvince.
    -- Artifact: tests/artifacts/current/province/province_zoom_pick_view.png
    -- Why: This is meaningful because province strategy maps need camera zoom and pointer picking to stay tied to the authoritative province grid.
    it("PNG: zoom and province picking view", function()
        local loaded = Fixture.load_registry(registry_name("zoom"), OUT .. "province_sanitized_map.png")
        save_png(Fixture.render_zoom_pick_view(loaded), OUT .. "province_zoom_pick_view.png")
    end)

    -- Does: Applies runtime political tints, terrain-style watermarking, styled border widths, a capital path, and a province viewport rectangle.
    -- Shows: The PNG combines the render-prep data province owns with a minimap-style viewport inset while keeping routing and minimap ownership outside province.
    -- Artifact: tests/artifacts/current/province/province_render_plan_overlay.png
    -- Why: This is meaningful because the province module must provide static geometry, fast visual state, input-space mapping, and render-ready commands without becoming an all-in-one strategy system.
    it("PNG: render plan overlay", function()
        local loaded = Fixture.load_registry(registry_name("render_plan"), OUT .. "province_sanitized_map.png")
        save_png(Fixture.render_render_plan_overlay(loaded), OUT .. "province_render_plan_overlay.png")
        expect_true((loaded.render_plan_path_primitives or 0) > 0)
    end)

    -- Does: Mutates ownership, terrain, fog, visibility, political color, and map mode state across a short revision timeline.
    -- Shows: The PNG captures the final strategic view, while the GIF animates map-mode and revision-driven visual state changes.
    -- Artifact: tests/artifacts/current/province/province_strategy_modes.png, province_revision_timeline.gif
    -- Why: This is meaningful because every frame is driven by province registry mutations and read back through getProvince, getMapMode, and revision-aware state.
    it("PNG+GIF: strategy modes and revision timeline", function()
        local loaded = Fixture.load_registry(registry_name("timeline"), OUT .. "province_sanitized_map.png")
        local start_revision = loaded.registry:getRevision()
        local frames = Fixture.render_revision_timeline_frames(loaded)
        expect_true(#frames >= 4)
        expect_true(loaded.registry:getRevision() > start_revision)
        save_png(Fixture.render_strategy_modes(loaded), OUT .. "province_strategy_modes.png")
        save_gif(frames, OUT .. "province_revision_timeline.gif")
    end)

    -- Does: Binds mapviz-target shaders to province rendering and emits three province-map shader artifacts.
    -- Shows: Political coloring, province selection glow, and frontline heat visualization are represented as province/map visualization outputs.
    -- Artifact: tests/artifacts/current/province/province_shader_visual_01_political_map.png, tests/artifacts/current/province/province_shader_visual_02_selection_glow.png, tests/artifacts/current/province/province_shader_visual_03_frontline_heat.png
    -- Why: Province owns semantic map data and render plans, so shader evidence should show map visualization use cases rather than generic shader geometry.
    it("PNG: shader-backed province map visualization variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("province", {
            { target = "mapviz", slug = "political_map" },
            { target = "mapviz", slug = "selection_glow" },
            { target = "mapviz", slug = "frontline_heat" },
        }, OUT)
    end)
end)

test_summary()
