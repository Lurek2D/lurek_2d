-- Canonical unit coverage for lurek.mapblock.

local function new_config()
    return lurek.mapblock.newConfig()
end

local function new_empty_config()
    return lurek.mapblock.newEmptyConfig()
end

local function new_block(config, width, height, layers)
    return lurek.mapblock.newBlock(width or 4, height or 3, layers or 2, config or new_config())
end

local function new_group(name)
    return lurek.mapblock.newGroup(name or "terrain")
end

local function new_script(name)
    return lurek.mapblock.newScript(name)
end

local function new_rules()
    return lurek.mapblock.newRules()
end

local function new_grid(width, height)
    return lurek.mapblock.newGrid(width or 4, height or 3)
end

local function new_generator(config)
    return lurek.mapblock.newGenerator(config or new_config())
end

local function new_tileset()
    return lurek.mapblock.newTilesetRef(7, "ground", 64, 8, 16, 16)
end

local function new_footprint_block()
    local config = new_config()
    config:setDefaultSegmentSize(1)
    local block = lurek.mapblock.newBlock(2, 2, 1, config)
    block:setFootprint({
        { 0, 0 },
        { 1, 0 },
        { 0, 1 },
    })
    return block
end

local function generate_single_placement_result()
    local config = new_config()
    config:setDefaultSegmentSize(1)
    local gen = new_generator(config)
    gen:setRectShape(1, 1)

    local block = lurek.mapblock.newBlock(1, 1, 1, config)
    block:setName("seed")
    block:setTile(0, 0, 0, 0, 1, 9)

    local group = new_group("terrain")
    group:addBlock(block)
    gen:addGroup(group)

    local script = new_script("place_once")
    script:addStep("place_block", { group = "terrain", block_index = 0, x = 0, y = 0 })
    return gen:generate(script)
end

local function generate_empty_result(config)
    local gen = new_generator(config)
    gen:setRectShape(2, 1)
    return gen:generate(new_script("empty"))
end

-- @describe lurek.mapblock module
describe("lurek.mapblock module", function()
    -- @covers lurek.mapblock.newConfig
    it("newConfig creates a default config with standard slots", function()
        local config = new_config()
        expect_equal("userdata", type(config))
        expect_equal(5, config:getSlotCount())
    end)

    -- @covers lurek.mapblock.newEmptyConfig
    it("newEmptyConfig creates a config with no predefined slots", function()
        local config = new_empty_config()
        expect_equal("userdata", type(config))
        expect_equal(0, config:getSlotCount())
    end)

    -- @covers lurek.mapblock.newBlock
    it("newBlock creates a block with the requested dimensions", function()
        local block = new_block()
        expect_equal("userdata", type(block))
        expect_equal(4, block:getWidth())
        expect_equal(3, block:getHeight())
        expect_equal(2, block:getLayerCount())
    end)

    -- @covers lurek.mapblock.newGroup
    it("newGroup creates a named map group", function()
        expect_equal("userdata", type(new_group("props")))
    end)

    -- @covers lurek.mapblock.newScript
    it("newScript defaults the script name to default", function()
        expect_equal("default", new_script():getName())
    end)

    -- @covers lurek.mapblock.newRules
    it("newRules creates an empty ruleset", function()
        local rules = new_rules()
        expect_equal("userdata", type(rules))
        expect_false(rules:isCompatible(1, 2))
    end)

    -- @covers lurek.mapblock.newGrid
    it("newGrid creates a rectangular availability grid", function()
        local grid = new_grid(4, 3)
        expect_equal("userdata", type(grid))
        expect_equal(12, grid:getAvailableCount())
    end)

    -- @covers lurek.mapblock.newEmptyGrid
    it("newEmptyGrid starts without available cells", function()
        local grid = lurek.mapblock.newEmptyGrid()
        expect_equal("userdata", type(grid))
        expect_equal(0, grid:getAvailableCount())
    end)

    -- @covers lurek.mapblock.newGenerator
    it("newGenerator creates a generator bound to a config", function()
        expect_equal("userdata", type(new_generator()))
    end)

    -- @covers lurek.mapblock.newTilesetRef
    it("newTilesetRef creates a tileset reference userdata", function()
        expect_equal("userdata", type(new_tileset()))
    end)
end)

-- @describe config methods
describe("mapblock config methods", function()
    -- @covers LMapBlockConfig:addSlot
    it("addSlot appends one slot to an empty config", function()
        local config = new_empty_config()
        config:addSlot("floor")
        expect_equal(1, config:getSlotCount())
    end)

    -- @covers LMapBlockConfig:removeSlot
    it("removeSlot deletes a previously added slot", function()
        local config = new_empty_config()
        config:addSlot("floor")
        config:removeSlot("floor")
        expect_equal(0, config:getSlotCount())
    end)

    -- @covers LMapBlockConfig:getSlotCount
    it("getSlotCount reports the default slot count", function()
        expect_equal(5, new_config():getSlotCount())
    end)

    -- @covers LMapBlockConfig:setMaxLayers
    it("setMaxLayers clamps block layer count through the config", function()
        local config = new_config()
        config:setMaxLayers(3)
        local block = new_block(config, 4, 3, 9)
        expect_equal(3, block:getLayerCount())
    end)

    -- @covers LMapBlockConfig:setDefaultSegmentSize
    it("setDefaultSegmentSize changes generated output dimensions", function()
        local config = new_config()
        config:setDefaultSegmentSize(4)
        local result = generate_empty_result(config)
        expect_equal(8, result:getWidth())
        expect_equal(4, result:getHeight())
    end)
end)

-- @describe block methods
describe("mapblock block methods", function()
    -- @covers LMapBlock:getTile
    it("getTile returns the gid stored by setTile", function()
        local block = new_block()
        block:setTile(0, 1, 2, 0, 1, 42)
        expect_equal(42, block:getTile(0, 1, 2, 0))
    end)

    -- @covers LMapBlock:setEdge
    it("setEdge accepts valid names and rejects unknown ones", function()
        local block = new_block()
        expect_no_error(function()
            block:setEdge("north", 0, 2)
        end)
        expect_error(function()
            block:setEdge("upward", 0, 2)
        end)
    end)

    -- @covers LMapBlock:setName
    it("setName updates the block name", function()
        local block = new_block()
        block:setName("corner")
        expect_equal("corner", block:getName())
    end)

    -- @covers LMapBlock:getName
    it("getName returns the block name string", function()
        local block = new_block()
        block:setName("hall")
        expect_equal("hall", block:getName())
    end)

    -- @covers LMapBlock:setWeight
    it("setWeight accepts floating point weights", function()
        local block = new_block()
        expect_no_error(function()
            block:setWeight(2.5)
        end)
    end)

    -- @covers LMapBlock:getWeight
    it("getWeight returns the previously stored weight", function()
        local block = new_block()
        block:setWeight(3.25)
        expect_equal(3.25, block:getWeight())
    end)

    -- @covers LMapBlock:setFootprint
    it("setFootprint accepts a custom polyomino footprint", function()
        local block = new_footprint_block()
        expect_equal(3, block:getFootprintCellCount())
    end)

    -- @covers LMapBlock:getFootprintCellCount
    it("getFootprintCellCount reports the custom footprint size", function()
        local block = new_footprint_block()
        expect_equal(3, block:getFootprintCellCount())
    end)

    -- @covers LMapBlock:isFootprintCell
    it("isFootprintCell returns true only for occupied footprint cells", function()
        local block = new_footprint_block()
        expect_true(block:isFootprintCell(1, 0))
        expect_false(block:isFootprintCell(1, 1))
    end)

    -- @covers LMapBlock:setSocket
    it("setSocket stores per-cell socket metadata", function()
        local block = new_footprint_block()
        expect_no_error(function()
            block:setSocket(1, 0, "east", 12)
        end)
    end)

    -- @covers LMapBlock:getSocket
    it("getSocket returns a stored per-cell socket type", function()
        local block = new_footprint_block()
        block:setSocket(1, 0, "east", 12)
        expect_equal(12, block:getSocket(1, 0, "east"))
    end)

    -- @covers LMapBlock:setEdgeOnly
    it("setEdgeOnly accepts a boolean placement restriction", function()
        local block = new_block()
        expect_no_error(function()
            block:setEdgeOnly(true)
        end)
    end)

    -- @covers LMapBlock:setInteriorOnly
    it("setInteriorOnly accepts a boolean placement restriction", function()
        local block = new_block()
        expect_no_error(function()
            block:setInteriorOnly(true)
        end)
    end)

    -- @covers LMapBlock:setLevelSpan
    it("setLevelSpan accepts a multi-level span", function()
        local block = new_block(new_config(), 4, 3, 2)
        expect_no_error(function()
            block:setLevelSpan(2)
        end)
    end)

    -- @covers LMapBlock:getWidth
    it("getWidth returns the block width", function()
        expect_equal(4, new_block():getWidth())
    end)

    -- @covers LMapBlock:getHeight
    it("getHeight returns the block height", function()
        expect_equal(3, new_block():getHeight())
    end)

    -- @covers LMapBlock:getLayerCount
    it("getLayerCount returns the layer count", function()
        expect_equal(2, new_block():getLayerCount())
    end)
end)

-- @describe group and script methods
describe("mapblock group and script methods", function()
    -- @covers LMapGroup:getBlockCount
    it("getBlockCount reflects added blocks", function()
        local group = new_group("terrain")
        group:addBlock(new_block())
        expect_equal(1, group:getBlockCount())
    end)

    -- @covers LMapGroup:getName
    it("getName returns the group name", function()
        expect_equal("props", new_group("props"):getName())
    end)

    -- @covers LMapGroup:addScript
    it("addScript accepts a map script userdata", function()
        local group = new_group("terrain")
        expect_no_error(function()
            group:addScript(new_script("decorate"))
        end)
    end)

    -- @covers LMapScript:getStepCount
    it("getStepCount returns the number of queued steps", function()
        local script = new_script("steps")
        script:addStep("fill_rect", { tile_id = 3, x = 0, y = 0, width = 1, height = 1 })
        expect_equal(1, script:getStepCount())
    end)

    -- @covers LMapScript:clear
    it("clear removes all queued script steps", function()
        local script = new_script("steps")
        script:addStep("fill_rect", { tile_id = 3, x = 0, y = 0, width = 1, height = 1 })
        script:clear()
        expect_equal(0, script:getStepCount())
    end)

    -- @covers LMapScript:getName
    it("getName returns the script name", function()
        expect_equal("decorate", new_script("decorate"):getName())
    end)
end)

-- @describe rules and grids
describe("mapblock rules and grids", function()
    -- @covers LNeighborRules:addCompatible
    it("addCompatible creates bidirectional compatibility", function()
        local rules = new_rules()
        rules:addCompatible(1, 2)
        expect_true(rules:isCompatible(1, 2))
        expect_true(rules:isCompatible(2, 1))
    end)

    -- @covers LNeighborRules:addCompatibleOneWay
    it("addCompatibleOneWay creates one-way compatibility", function()
        local rules = new_rules()
        rules:addCompatibleOneWay(3, 4)
        expect_true(rules:isCompatible(3, 4))
        expect_false(rules:isCompatible(4, 3))
    end)

    -- @covers LNeighborRules:isCompatible
    it("isCompatible returns false for unknown pairs", function()
        expect_false(new_rules():isCompatible(99, 100))
    end)

    -- @covers LNeighborRules:clear
    it("clear removes previously registered compatibility", function()
        local rules = new_rules()
        rules:addCompatible(1, 2)
        rules:clear()
        expect_false(rules:isCompatible(1, 2))
    end)

    -- @covers LPlacementGrid:addPosition
    it("addPosition inserts a new available cell", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(2, 4)
        expect_equal(1, grid:getAvailableCount())
    end)

    -- @covers LPlacementGrid:removePosition
    it("removePosition deletes a previously available cell", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(2, 4)
        grid:removePosition(2, 4)
        expect_equal(0, grid:getAvailableCount())
    end)

    -- @covers LPlacementGrid:isAvailable
    it("isAvailable returns true for inserted positions", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(2, 4)
        expect_true(grid:isAvailable(2, 4))
    end)

    -- @covers LPlacementGrid:getAvailableCount
    it("getAvailableCount reports all rectangular positions", function()
        expect_equal(12, new_grid(4, 3):getAvailableCount())
    end)

    -- @covers LPlacementGrid:isEdgePosition
    it("isEdgePosition detects boundary cells in an irregular shape", function()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(0, 0)
        grid:addPosition(1, 0)
        grid:addPosition(1, 1)
        expect_true(grid:isEdgePosition(0, 0))
        expect_true(grid:isEdgePosition(1, 1))
    end)

    -- @covers LPlacementGrid:clear
    it("clear removes all available cells", function()
        local grid = new_grid(4, 3)
        grid:clear()
        expect_equal(0, grid:getAvailableCount())
    end)
end)

-- @describe generator and result methods
describe("mapblock generator and result methods", function()
    -- @covers LMapBlockGenerator:setRectShape
    it("setRectShape defines rectangular result bounds", function()
        local gen = new_generator()
        gen:setRectShape(3, 2)
        local result = gen:generate(new_script("empty"))
        expect_equal(24, result:getWidth())
        expect_equal(16, result:getHeight())
    end)

    -- @covers LMapBlockGenerator:setShape
    it("setShape defines result bounds from arbitrary positions", function()
        local gen = new_generator()
        gen:setShape({
            { 0, 0 },
            { 2, 1 },
        })
        local result = gen:generate(new_script("empty"))
        expect_equal(24, result:getWidth())
        expect_equal(16, result:getHeight())
    end)

    -- @covers LMapBlockGenerator:setGrid
    it("setGrid accepts an explicit irregular placement grid", function()
        local gen = new_generator()
        local grid = lurek.mapblock.newEmptyGrid()
        grid:addPosition(0, 0)
        grid:addPosition(1, 0)
        grid:addPosition(1, 1)
        gen:setGrid(grid)
        local result = gen:generate(new_script("empty"))
        expect_equal(16, result:getWidth())
        expect_equal(16, result:getHeight())
    end)

    -- @covers LMapBlockGenerator:setOrientation
    it("setOrientation accepts known names and rejects unknown ones", function()
        local gen = new_generator()
        expect_no_error(function()
            gen:setOrientation("isometric")
        end)
        expect_error(function()
            gen:setOrientation("diagonal")
        end)
    end)

    -- @covers LMapBlockGenerator:setMaxLevels
    it("setMaxLevels changes the generated level count", function()
        local gen = new_generator()
        gen:setRectShape(1, 1)
        gen:setMaxLevels(3)
        local result = gen:generate(new_script("empty"))
        expect_equal(3, result:getLevelCount())
    end)

    -- @covers LMapBlockGenerator:setRules
    it("setRules accepts a neighbor rules object", function()
        local gen = new_generator()
        local rules = new_rules()
        rules:addCompatible(1, 1)
        expect_no_error(function()
            gen:setRules(rules)
        end)
    end)

    -- @covers LMapBlockGenerator:setSeed
    it("setSeed accepts a deterministic seed value", function()
        local gen = new_generator()
        expect_no_error(function()
            gen:setSeed(12345)
        end)
    end)

    -- @covers LMapBlockGenerator:setTileSize
    it("setTileSize accepts tile pixel dimensions", function()
        local gen = new_generator()
        expect_no_error(function()
            gen:setTileSize(32, 24)
        end)
    end)

    -- @covers LMapBlockGenerator:addGroup
    it("addGroup accepts a named group definition", function()
        local gen = new_generator()
        local group = new_group("terrain")
        group:addBlock(new_block())
        expect_no_error(function()
            gen:addGroup(group)
        end)
    end)

    -- @covers LMapBlockGenerator:generate
    it("generate returns a map block result userdata", function()
        local gen = new_generator()
        gen:setRectShape(2, 1)
        local result = gen:generate(new_script("empty"))
        expect_equal("userdata", type(result))
    end)

    -- @covers LMapBlockGenerator:getLastPlacedCount
    it("getLastPlacedCount starts at zero for an empty run", function()
        local gen = new_generator()
        gen:setRectShape(2, 1)
        gen:generate(new_script("empty"))
        expect_equal(0, gen:getLastPlacedCount())
    end)

    -- @covers LMapBlockResult:getWidth
    it("getWidth returns generated tile width", function()
        expect_equal(16, generate_empty_result(new_config()):getWidth())
    end)

    -- @covers LMapBlockResult:getHeight
    it("getHeight returns generated tile height", function()
        expect_equal(8, generate_empty_result(new_config()):getHeight())
    end)

    -- @covers LMapBlockResult:getLevelCount
    it("getLevelCount returns the number of generated levels", function()
        expect_equal(1, generate_empty_result(new_config()):getLevelCount())
    end)

    -- @covers LMapBlockResult:getLayerCount
    it("getLayerCount returns the generated layer count", function()
        expect_equal(1, generate_empty_result(new_config()):getLayerCount())
    end)

    -- @covers LMapBlockResult:getGid
    it("getGid returns zero for empty generated tiles", function()
        expect_equal(0, generate_empty_result(new_config()):getGid(0, 0, 0, 0, 0))
    end)

    -- @covers LMapBlockResult:getBlocksPlaced
    it("getBlocksPlaced is zero when no blocks were placed", function()
        expect_equal(0, generate_empty_result(new_config()):getBlocksPlaced())
    end)

    -- @covers LMapBlockResult:isEmpty
    it("isEmpty returns true when generation placed nothing", function()
        expect_true(generate_empty_result(new_config()):isEmpty())
    end)

    -- @covers LMapBlockResult:getPlacements
    it("getPlacements returns structured placement records", function()
        local placements = generate_single_placement_result():getPlacements()
        expect_equal(1, #placements)
        expect_equal("terrain", placements[1].group_name)
        expect_equal("seed", placements[1].block_name)
        expect_equal(1, #placements[1].cells)
    end)
end)

-- @describe tileset reference methods
describe("mapblock tileset reference methods", function()
    -- @covers LTilesetRef:getId
    it("getId returns the tileset identifier", function()
        expect_equal(7, new_tileset():getId())
    end)

    -- @covers LTilesetRef:getName
    it("getName returns the tileset name", function()
        expect_equal("ground", new_tileset():getName())
    end)

    -- @covers LTilesetRef:setImagePath
    it("setImagePath accepts a path string", function()
        local tileset = new_tileset()
        expect_no_error(function()
            tileset:setImagePath("assets/tilesets/ground.png")
        end)
    end)
end)

test_summary()
