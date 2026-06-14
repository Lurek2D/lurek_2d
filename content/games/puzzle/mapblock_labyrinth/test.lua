local World = require("content.games.puzzle.mapblock_labyrinth.modules.world")

local function contains(list, expected)
    for i = 1, #list do
        if list[i] == expected then
            return true
        end
    end
    return false
end

local function placement_signature(placements)
    local parts = {}
    for i = 1, #placements do
        local placement = placements[i]
        parts[#parts + 1] = string.format(
            "%s:%s:%d:%d:l%d:r%d:m%s:c%d",
            placement.group_name,
            placement.block_name,
            placement.grid_x,
            placement.grid_y,
            placement.level,
            placement.rotation,
            tostring(placement.mirrored),
            #placement.cells
        )
    end
    table.sort(parts)
    return table.concat(parts, "|")
end

local function unique_nonzero_gids(world, level)
    local set = {}
    local count = 0
    for y = 0, world.detail.tile_height - 1 do
        for x = 0, world.detail.tile_width - 1 do
            local gid = World.resolve_level_gid(world, level, x, y)
            if gid ~= 0 and not set[gid] then
                set[gid] = true
                count = count + 1
            end
        end
    end
    return count
end

describe("mapblock_labyrinth demo", function()
    it("builds a deterministic irregular province with reachable endpoints", function()
        local world_a = World.build(41)
        local world_b = World.build(41)

        expect_equal(55, world_a.cell_count)
        expect_true(world_a.transformed_count > 0)
        expect_not_nil(world_a.start)
        expect_not_nil(world_a.goal)
        expect_true(world_a.optimal_steps > 0)
        expect_true(World.can_move(world_a, world_a.start.x, world_a.start.y))
        expect_true(World.can_move(world_a, world_a.goal.x, world_a.goal.y))
        expect_equal(placement_signature(world_a.macro.placements), placement_signature(world_b.macro.placements))
        expect_equal(placement_signature(world_a.detail.placements), placement_signature(world_b.detail.placements))
    end)

    it("builds a two-level detailed map with mixed block sizes", function()
        local world = World.build(41)

        expect_equal(2, world.detail.level_count)
        expect_equal(2, world.detail.layer_count)
        expect_equal(50, world.detail.tile_width)
        expect_equal(35, world.detail.tile_height)
        expect_true(world.detail.upper_count > 0)
        expect_equal(#world.macro.placements, world.detail.level_counts[0])
        expect_equal(world.detail.upper_count, world.detail.level_counts[1])
        expect_equal(#world.macro.placements + world.detail.upper_count, #world.detail.placements)
        expect_true(contains(world.detail.size_labels, "10x10"))
        expect_true(contains(world.detail.size_labels, "15x10"))
        expect_true(contains(world.detail.size_labels, "20x10"))
        expect_true(unique_nonzero_gids(world, 0) >= 7)
        expect_true(unique_nonzero_gids(world, 1) >= 3)
    end)

    it("renders the pipeline views from the shared world builder", function()
        local world = World.build(41)
        local level0 = World.render_level_image(world, 0, 4)
        local level1 = World.render_level_image(world, 1, 4)
        local pipeline = World.render_pipeline_image(world, 20, 4)

        expect_true(level0:getWidth() > 0)
        expect_true(level0:getHeight() > 0)
        expect_true(level1:getWidth() > 0)
        expect_true(level1:getHeight() > 0)
        expect_true(pipeline:getWidth() > level0:getWidth())
        expect_true(pipeline:getHeight() >= level0:getHeight())
    end)
end)

test_summary()
