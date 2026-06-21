-- Canonical evidence file for lurek.mapblock artifacts.

local Fixture = lurek.filesystem.load("tests/fixtures/mapblock_evidence_fixture.lua")()
local OUT = evidence_output_dir("mapblock")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_text(path, data)
    write_file(path, data)
    expect_evidence_created(path)
end

-- @describe Evidence: lurek.mapblock scenarios
describe("Evidence: lurek.mapblock scenarios", function()
    -- Does: Builds a dedicated fortress fixture through lurek.mapblock and exports the macro placement view as a standalone evidence PNG.
    -- Shows: The artifact exposes irregular macro occupancy and variable block sizes without relying on any playable game content.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_macro_placement.png
    -- Why: This is meaningful only if the visible output is assembled from a local mapblock fixture and live placement output rather than from a game-owned module.
    it("PNG: macro placement view", function()
        ensure_evidence_dir("mapblock")
        local world = Fixture.build(41)

        expect_equal(2, world.result:getLevelCount())
        expect_true(world.result:getBlocksPlaced() >= 1)
        expect_true((world.report.diagnostics.transform_cache_hits or 0) >= 0)

        local img = Fixture.render_macro(world, 34, 18)
        save_png(img, OUT .. "mapblock_macro_placement.png")
    end)

    -- Does: Renders each generated level from the local fortress fixture into its own readable atlas.
    -- Shows: The artifacts expose lower-level terrain composition and upper-level overlays derived from real mapblock placements.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_detail_level0.png
    -- Why: This is meaningful only if every visible tile comes from result:getGid on the generated fixture world.
    it("PNG: detailed level renders", function()
        ensure_evidence_dir("mapblock")
        local world = Fixture.build(41)

        local manifest = Fixture.manifest(world)
        local level0_hist = manifest.gid_histograms.level0
        local level1_hist = manifest.gid_histograms.level1
        expect_true(next(level0_hist) ~= nil)
        expect_true(next(level1_hist) ~= nil)

        local level0 = Fixture.render_level(world.result, 0, 20)
        local level1 = Fixture.render_level(world.result, 1, 20)
        save_png(level0, OUT .. "mapblock_detail_level0.png")
        save_png(level1, OUT .. "mapblock_detail_level1.png")
    end)

    -- Does: Serializes the dedicated fortress fixture result and diagnostics into a manifest.
    -- Shows: The artifact exposes shape size, placements, level counts, and gid histograms from the local evidence-only scenario.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_two_stage_manifest.json
    -- Why: This is meaningful only if the manifest is built from the generated fixture world rather than from a hand-authored summary.
    it("JSON: two-stage placement manifest", function()
        ensure_evidence_dir("mapblock")
        local world = Fixture.build(41)
        local manifest = lurek.serial.toJson(Fixture.manifest(world), true)
        save_text(OUT .. "mapblock_two_stage_manifest.json", manifest)
    end)
end)

test_summary()
