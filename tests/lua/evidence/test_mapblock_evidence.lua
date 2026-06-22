-- Canonical evidence file for lurek.mapblock artifacts.

local Fixture = lurek.filesystem.load("tests/fixtures/mapblock_evidence_fixture.lua")()
local OUT = evidence_output_dir("mapblock")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path)
    lurek.image.saveGIF(frames, path, { delayMs = 140, speed = 10, loop = true })
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.mapblock scenarios
describe("Evidence: lurek.mapblock scenarios", function()
    before_each(function()
        ensure_evidence_dir("mapblock")
    end)

    -- Does: Renders the same generated fortress at strategic block scale and tactical tile scale.
    -- Shows: The PNG links placement cells from result:getPlacements with the exported per-tile GIDs returned by result:getGid.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_strategic_tactical_split.png
    -- Why: This is meaningful because mapblock owns both the high-level block grammar and the low-level tile export consumed by tactical maps.
    it("PNG: strategic blocks and tactical tile zoom", function()
        local world = Fixture.build(41)
        expect_true(world.result:getBlocksPlaced() >= 8)
        save_png(Fixture.render_strategic_tactical_split(world), OUT .. "mapblock_strategic_tactical_split.png")
    end)

    -- Does: Generates the two-level fortress fixture and draws level 1 over level 0 as a vertical cutaway.
    -- Shows: The PNG makes upper-storey placements, lower-storey tiles, and their shared x/y coordinates visible in one stacked view.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_two_level_cutaway.png
    -- Why: This is meaningful because setMaxLevels, per-step level fields, getLevelCount, and per-level getGid must agree for multi-storey maps.
    it("PNG: two-level vertical cutaway", function()
        local world = Fixture.build(41)
        expect_equal(2, world.result:getLevelCount())
        save_png(Fixture.render_two_level_cutaway(world), OUT .. "mapblock_two_level_cutaway.png")
    end)

    -- Does: Runs the scripted fortress generation and visualizes the authored step order as a five-stage storyboard.
    -- Shows: The PNG separates empty authored shape, lower-level block placement, upper-level placement, and final script output.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_script_pipeline_storyboard.png
    -- Why: This is meaningful because MapScript:addStep controls the staged pipeline that turns reusable blocks into the final result.
    it("PNG: scripted generation pipeline storyboard", function()
        local world = Fixture.build(41)
        expect_true(#world.placements >= 8)
        save_png(Fixture.render_script_pipeline_storyboard(world), OUT .. "mapblock_script_pipeline_storyboard.png")
    end)

    -- Does: Reads the final MapBlockResult back through per-level getGid and summarizes the exported tile histograms.
    -- Shows: The PNG compares level 0, level 1, and the GID distribution bars created by block export and paint operations.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_result_contract_histogram.png
    -- Why: This is meaningful because downstream tilemap consumers rely on MapBlockResult dimensions, level count, and stable tile values.
    it("PNG: result tile contract and histograms", function()
        local world = Fixture.build(41)
        expect_true(world.result:getWidth() > 0)
        expect_true(world.result:getHeight() > 0)
        save_png(Fixture.render_result_contract(world), OUT .. "mapblock_result_contract_histogram.png")
    end)

    -- Does: Places edge-only, interior-only, and neutral blocks in one rectangular placement grid.
    -- Shows: The PNG distinguishes legal perimeter cells from interior cells and marks which block type was accepted at each policy zone.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_edge_interior_constraints.png
    -- Why: This is meaningful because edge_only/interior_only are mapblock-owned placement constraints, not tile-rendering decoration.
    it("PNG: edge-only and interior-only placement policy", function()
        local world = Fixture.build_edge_interior(53)
        expect_equal(7, world.result:getBlocksPlaced())
        save_png(Fixture.render_edge_interior_constraints(world), OUT .. "mapblock_edge_interior_constraints.png")
    end)

    -- Does: Runs solve_shape over an irregular placement shape built from reusable block footprints.
    -- Shows: The PNG exposes which solver-chosen blocks cover the non-rectangular map and which cells are outside the authored shape.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_solver_footprints.png
    -- Why: This is meaningful because the artifact is derived from live solve_shape placements, custom footprints, rotations, and the resulting placement list.
    it("PNG: solve_shape footprint coverage", function()
        local world = Fixture.build_solver(73)
        expect_true(world.result:getBlocksPlaced() >= 1)
        expect_true((world.report.diagnostics.solve_failures or 0) == 0)
        save_png(Fixture.render_solver(world), OUT .. "mapblock_solver_footprints.png")
    end)

    -- Does: Places a source-link-link-link-sink corridor with explicit per-cell sockets and neighbor rules.
    -- Shows: The PNG makes compatible east/west socket joins visible as a legal chain across the generated row.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_socket_constraints.png
    -- Why: This is meaningful because placement succeeds only through lurek.mapblock socket metadata, setRules, and match_sides validation.
    it("PNG: socket constrained corridor", function()
        local world = Fixture.build_socket_corridor(11)
        expect_equal(5, world.result:getBlocksPlaced())
        save_png(Fixture.render_socket_corridor(world), OUT .. "mapblock_socket_constraints.png")
    end)

    -- Does: Exports deliberately rotated and mirrored authored blocks into a generated result.
    -- Shows: The PNG exposes transformed tile output plus rotation direction and mirror markers for each placed block.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_transform_export.png
    -- Why: This is meaningful because the visual cells come from result:getGid after mapblock applies rotation and mirroring at export time.
    it("PNG: rotation and mirror export", function()
        local world = Fixture.build_transform(19)
        expect_equal(3, world.result:getBlocksPlaced())
        save_png(Fixture.render_transform_export(world), OUT .. "mapblock_transform_export.png")
    end)

    -- Does: Generates a two-storey fortress fixture and renders both levels into one comparison atlas.
    -- Shows: The PNG separates lower terrain composition from upper-level banners and lanterns while preserving shared placement coordinates.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_multilevel_layers.png
    -- Why: This is meaningful because both halves are read from the same MapBlockResult with getLevelCount and per-level getGid calls.
    it("PNG: multi-level result atlas", function()
        local world = Fixture.build(41)
        expect_equal(2, world.result:getLevelCount())
        save_png(Fixture.render_multilevel(world), OUT .. "mapblock_multilevel_layers.png")
    end)

    -- Does: Applies scripted fill_rect paint operations after block placement and animates the fixture placement order.
    -- Shows: The PNG exposes clipped paint diagnostics as bars, while the GIF shows the generated fortress accumulating block by block.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_scripted_paint_diagnostics.png, mapblock_generation_timeline.gif
    -- Why: This is meaningful because paint counters come from the mapblock report and the GIF frames are built from the live placement sequence.
    it("PNG+GIF: paint diagnostics and generation timeline", function()
        local painted = Fixture.build_paint(29)
        expect_true((painted.report.diagnostics.clipped_paint_ops or 0) >= 1)
        save_png(Fixture.render_paint_diagnostics(painted), OUT .. "mapblock_scripted_paint_diagnostics.png")

        local world = Fixture.build(41)
        local frames = Fixture.render_timeline_frames(world)
        expect_true(#frames >= 4)
        save_gif(frames, OUT .. "mapblock_generation_timeline.gif")
    end)
end)

test_summary()
