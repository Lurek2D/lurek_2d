-- tests/lua/stress/test_procgen_stress.lua
-- Stress tests for lurek.procgen     throughput and allocation under load.
-- Validates that generators don't crash, memory-leak, or hang under large inputs.

local function new_hex_grid_with_path(width, height, start_x, start_y, end_x, end_y)
    local grid = lurek.pathfind.newHexGrid(width, height)
    local path = grid:findPath(start_x, start_y, end_x, end_y)
    return grid, path
end

local function hex_grid_field_of_view(width, height, origin_x, origin_y, radius)
    local grid = lurek.pathfind.newHexGrid(width, height)
    return grid:fieldOfView(origin_x, origin_y, radius)
end


--                                                                                                                                        
-- Repeated dungeon generation
--                                                                                                                                        
-- @describe procgen stress: repeated dungeon generation
describe("procgen stress: repeated dungeon generation", function()

    -- @stress lurek.procgen.bspDungeon
    it("bspDungeon handles repeated and large-map generation", function()
        for seed = 1, 100 do
            local d = lurek.procgen.bspDungeon({ width = 60, height = 40, seed = seed })
            expect_type("table", d.rooms)
        end
        local d = lurek.procgen.bspDungeon({ width = 200, height = 150, seed = 777 })
        expect_type("table", d.rooms)
        expect_true(#d.rooms > 0, "large map should generate rooms")
    end)

    -- @stress lurek.procgen.roomsDungeon
    it("roomsDungeon 50 iterations", function()
        for seed = 1, 50 do
            local d = lurek.procgen.roomsDungeon({ width = 40, height = 30, max_rooms = 10, seed = seed })
            expect_true(#d.grid == 40 * 30, "grid size mismatch at seed " .. seed)
        end
    end)
end)

--                                                                                                                                        
-- Heightmap throughput
--                                                                                                                                        
-- @describe procgen stress: heightmap large and repeated
describe("procgen stress: heightmap large and repeated", function()

    -- @stress lurek.procgen.heightmap
    it("heightmap handles large grids and repeated generation", function()
        local hm = lurek.procgen.heightmap({ width = 128, height = 128, seed = 1, octaves = 4 })
        expect_equal(128 * 128, #hm.cells)
        hm = lurek.procgen.heightmap({ width = 256, height = 256, seed = 2, octaves = 6 })
        expect_equal(256 * 256, #hm.cells)
        for i = 1, 20 do
            hm = lurek.procgen.heightmap({ width = 32, height = 32, seed = i })
            expect_equal(32 * 32, #hm.cells)
        end
    end)
end)

--                                                                                                                                        
-- Noise map throughput
--                                                                                                                                        
-- @describe procgen stress: noise maps
describe("procgen stress: noise maps", function()

    -- @stress lurek.procgen.noiseMap
    it("noiseMap 512  512 completes", function()
        local m = lurek.procgen.noiseMap(512, 512, { seed = 1 })
        expect_equal(512 * 512, #m)
    end)

    -- @stress lurek.procgen.noiseMapParallel
    it("noiseMapParallel handles large and repeated workloads", function()
        local m = lurek.procgen.noiseMapParallel(512, 512, { octaves = 4 })
        expect_equal(512 * 512, #m)
        m = lurek.procgen.noiseMapParallel(1024, 1024)
        expect_equal(1024 * 1024, #m)
        for i = 1, 10 do
            m = lurek.procgen.noiseMapParallel(64, 64, { octaves = 3 })
            expect_equal(64 * 64, #m)
        end
    end)
end)

--                                                                                                                                        
-- L-System expansion
--                                                                                                                                        
-- @describe procgen stress: L-system deep expansion
describe("procgen stress: L-system deep expansion", function()

    -- @stress lurek.procgen.lsystem
    it("L-system 8 iterations completes fast", function()
        local s = lurek.procgen.lsystem({ axiom = "F", rules = { F = "FF" }, iterations = 8 })
        expect_equal(256, #s)  -- 2^8
    end)

    -- @stress lurek.procgen.lsystemSegments
    it("Koch curve 5 iterations produces many segments", function()
        local segs = lurek.procgen.lsystemSegments(
            { axiom = "F--F--F", rules = { F = "F+F--F+F" }, iterations = 5 },
            60, 1.0
        )
        expect_type("table", segs)
        expect_true(#segs > 100, "5-iteration Koch should produce >100 segments")
    end)
end)

--                                                                                                                                        
-- Name generation throughput
--                                                                                                                                        
-- @describe procgen stress: name generation
describe("procgen stress: name generation", function()

    -- @stress lurek.procgen.generateNames
    it("1000 names generated without error", function()
        local training = { "Aria", "Lyra", "Mira", "Elara", "Kira", "Tara", "Nara", "Zara",
                           "Vera", "Lara", "Sera", "Fira", "Bora", "Cora", "Diana" }
        local names = lurek.procgen.generateNames(training, 1000, 3, 10, 42)
        expect_equal(1000, #names)
        for _, n in ipairs(names) do
            expect_type("string", n)
            expect_true(#n >= 3 and #n <= 10, "name out of range: " .. n)
        end
    end)
end)

--                                                                                                                                        
-- World graph large
--                                                                                                                                        
-- @describe procgen stress: world graph
describe("procgen stress: world graph", function()

    -- @stress lurek.procgen.worldGraph
    it("worldGraph handles large region counts and many seeds", function()
        local wg = lurek.procgen.worldGraph(2000, 1500, 100, 1)
        expect_equal(100, #wg.regions)
        expect_true(#wg.edges > 0, "expected edges in large world graph")
        for seed = 1, 50 do
            wg = lurek.procgen.worldGraph(400, 300, 15, seed)
            expect_equal(15, #wg.regions)
        end
    end)
end)

--                                                                                                                                        
-- WFC stress
--                                                                                                                                        
-- @describe procgen stress: wfc generation
describe("procgen stress: wfc generation", function()

    -- @stress lurek.procgen.wfcGenerate
    it("wfc completes on large grids and across many seeds", function()
        local tiles = { { id = 0, weight = 1.0 }, { id = 1, weight = 0.5 } }
        local adj = { [0] = { 0, 1 }, [1] = { 0, 1 } }
        local g = lurek.procgen.wfcGenerate({ width = 32, height = 32, tiles = tiles, adjacencies = adj, seed = 5 })
        expect_equal(32 * 32, #g.cells)
        tiles = { { id = 0, weight = 1.0 }, { id = 1, weight = 1.0 } }
        for seed = 1, 20 do
            g = lurek.procgen.wfcGenerate({ width = 16, height = 16, tiles = tiles, adjacencies = adj, seed = seed })
            expect_equal(256, #g.cells)
        end
    end)
end)

--                                                                                                                                        
-- HexGrid range-of-movement large map
--                                                                                                                                        
-- @describe pathfinding stress: hexGrid large map
describe("pathfinding stress: hexGrid large map", function()

    -- @stress lurek.pathfind.newHexGrid
    it("hexGrid 100  100 findPath completes", function()
        local g, path = new_hex_grid_with_path(100, 100, 1, 1, 100, 100)
        expect_type("userdata", g)
        expect_true(path == nil or #path > 0, "should find path or return nil")
    end)

    -- @stress LHexGrid:fieldOfView
    it("hexGrid 50  50 fieldOfView radius=20 completes", function()
        local fov = hex_grid_field_of_view(50, 50, 25, 25, 20)
        expect_type("table", fov)
        expect_true(#fov > 0, "FOV should cover some cells")
    end)

    -- @stress lurek.pathfind.rangeMap
    it("rangeMap 50  50 with budget 15 completes", function()
        local r = lurek.pathfind.rangeMap({
            width = 50, height = 50,
            origin_x = 25, origin_y = 25,
            budget = 15.0
        })
        expect_true(#r.cells > 0, "expected reachable cells")
    end)
end)

-- @describe procgen stress: bounded constrained placement
describe("procgen stress: bounded constrained placement", function()
    -- @stress lurek.procgen.placeConstrained
    it("places from 5000 candidates with bounded attempts", function()
        local candidates = {}
        for i = 1, 5000 do
            candidates[i] = {
                id = "candidate_" .. i,
                x = i * 2,
                y = i % 31,
                level = i % 3,
                region = "region_" .. (i % 16),
                tags = { "floor" },
                weight = 1 + (i % 5),
            }
        end
        local placements, report = lurek.procgen.placeConstrained(candidates, {
            count = 256,
            requiredTags = { "floor" },
            minDistance = 1,
            perRegionCapacity = 32,
        }, {
            seed = 991,
            maxAttempts = 4096,
        })
        expect_equal(256, #placements)
        expect_true(report.complete)
        expect_true(report.attempts <= 4096)
    end)

    -- @stress lurek.procgen.validateConnectivity
    it("validates a 256 by 256 grid iteratively", function()
        local width, height = 256, 256
        local cells = {}
        for i = 1, width * height do
            cells[i] = 0
        end
        local report = lurek.procgen.validateConnectivity({
            width = width,
            height = height,
            cells = cells,
        }, {
            starts = { { x = 0, y = 0 } },
            goals = { { x = width - 1, y = height - 1 } },
        })
        expect_equal(1, #report.components)
        expect_equal(width * height, report.components[1].size)
        expect_equal(0, #report.unreachableGoals)
    end)
end)

test_summary()
