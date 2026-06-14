-- Canonical evidence file for lurek.mapblock artifacts.
-- @covers lurek.image.savePNG
-- @covers lurek.serial.toJson


local World = require("content.games.puzzle.mapblock_labyrinth.modules.world")

local OUT = evidence_output_dir("mapblock")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_text(path, data)
    write_file(path, data)
    expect_evidence_created(path)
end

local function copy_counts(counts)
    local out = {}
    for name, value in pairs(counts) do
        out[name] = value
    end
    return out
end

local function level_gid_histogram(world, level)
    local histogram = {}
    for y = 0, world.detail.tile_height - 1 do
        for x = 0, world.detail.tile_width - 1 do
            local gid = World.resolve_level_gid(world, level, x, y)
            if gid ~= 0 then
                histogram[tostring(gid)] = (histogram[tostring(gid)] or 0) + 1
            end
        end
    end
    return histogram
end

local function manifest_payload(world)
    return {
        seed = world.seed,
        province = {
            bounds = {
                min_x = world.bounds[1],
                min_y = world.bounds[2],
                max_x = world.bounds[3],
                max_y = world.bounds[4],
            },
            cell_count = world.cell_count,
            transformed_count = world.transformed_count,
            counts = copy_counts(world.counts),
            start = { x = world.start.x, y = world.start.y, block = world.start.block_name },
            goal = { x = world.goal.x, y = world.goal.y, block = world.goal.block_name },
            optimal_steps = world.optimal_steps,
        },
        detail = {
            tile_width = world.detail.tile_width,
            tile_height = world.detail.tile_height,
            segment_tiles = world.detail.segment_tiles,
            level_count = world.detail.level_count,
            layer_count = world.detail.layer_count,
            upper_count = world.detail.upper_count,
            size_labels = world.detail.size_labels,
            block_sizes = world.detail.block_sizes,
            level_counts = world.detail.level_counts,
            gid_histograms = {
                level0 = level_gid_histogram(world, 0),
                level1 = level_gid_histogram(world, 1),
            },
        },
        macro_placements = world.macro.placements,
        detail_placements = world.detail.placements,
    }
end

-- @describe Evidence: lurek.mapblock scenarios
describe("Evidence: lurek.mapblock scenarios", function()
    -- Does: Runs the shared two-stage province builder and exports the complete pipeline view.
    -- Shows: The artifact exposes stage 1 macro block placement on an irregular province and stage 2 tile expansion into two detailed levels.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_two_stage_pipeline.png
    -- Why: This is meaningful only if the overview comes from the same mapblock-driven world used by the playable demo.
    it("PNG: two-stage pipeline overview", function()
        ensure_evidence_dir("mapblock")
        local world = World.build(41)

        expect_equal(2, world.detail.level_count)
        expect_true(world.detail.upper_count > 0)

        local img = World.render_pipeline_image(world, 28, 12)
        save_png(img, OUT .. "mapblock_two_stage_pipeline.png")
    end)

    -- Does: Renders the final full-map tile outputs for both detail levels produced by the shared world builder.
    -- Shows: The artifacts expose variable block sizes, level 0 ground composition, and level 1 overlays generated from mapblock placements.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_detail_level0.png
    -- Why: This is meaningful only if the detailed maps are assembled from mapblock results rather than from a separate painter.
    it("PNG: detailed level renders", function()
        ensure_evidence_dir("mapblock")
        local world = World.build(41)

        expect_true(#world.detail.size_labels >= 3)
        expect_true(next(level_gid_histogram(world, 0)) ~= nil)
        expect_true(next(level_gid_histogram(world, 1)) ~= nil)

        local level0 = World.render_level_image(world, 0, 12)
        local level1 = World.render_level_image(world, 1, 12)
        save_png(level0, OUT .. "mapblock_detail_level0.png")
        save_png(level1, OUT .. "mapblock_detail_level1.png")
    end)

    -- Does: Serializes the shared two-stage world into a manifest driven directly by mapblock placement output.
    -- Shows: The artifact exposes macro placements, detail placements, level counts, variable block sizes, transforms, and endpoint metadata.
    -- Artifact: tests/artifacts/current/mapblock/mapblock_two_stage_manifest.json
    -- Why: This is meaningful only if the manifest is derived from real mapblock generation output rather than from a hand-authored summary.
    it("JSON: two-stage placement manifest", function()
        ensure_evidence_dir("mapblock")
        local world = World.build(41)
        local manifest = lurek.serial.toJson(manifest_payload(world), true)
        save_text(OUT .. "mapblock_two_stage_manifest.json", manifest)
    end)
end)

test_summary()
