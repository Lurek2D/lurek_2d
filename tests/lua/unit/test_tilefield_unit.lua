-- Canonical unit coverage for lurek.tilefield.

-- @describe lurek.tilefield module functions
describe("lurek.tilefield module functions", function()
    -- @covers lurek.tilefield.new
    it("creates a multi-level field", function()
        local field = lurek.tilefield.new({ width = 6, height = 5, levels = 2, topology = "square" })
        expect_type("userdata", field)
        expect_equal("LTileField", field:type())
    end)

    -- @covers lurek.tilefield.fromTileMap
    it("copies solid gids from tilemap into a field", function()
        local map = lurek.tilemap.newTileMap(16, 16)
        map:addLayer("ground", 3, 3)
        map:setTile(1, 2, 2, 9)
        local field = lurek.tilefield.fromTileMap(map, { layer = 1, levels = 2, level = 2, solidGids = { 9 } })
        expect_true(field:blocks(2, 2, 2, "move"))
        expect_true(not field:blocks(2, 2, 1, "move"))
        expect_true(not field:blocks(1, 1, 1, "move"))
    end)

    -- @covers lurek.tilefield.createPhysicsFromTileset
    it("creates physics bodies from tileset object physics", function()
        local tileset = lurek.tileset.fromProvider({
            firstGid = 10,
            tileCount = 4,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                wall = {
                    physics = {
                        shape = "diamond",
                        bodyType = "static",
                        density = 2.0,
                        friction = 0.2,
                        restitution = 0.85,
                        layer = 2,
                        mask = 3,
                    },
                },
            },
            tileObjects = { [2] = "wall" },
        })
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setRef(2, 2, 1, "tiles", 11)
        local world = lurek.physics.newWorld(0, 0)

        local bodies = lurek.tilefield.createPhysicsFromTileset(field, "tiles", tileset, world, { refIsGid = true })

        expect_equal(1, #bodies)
        expect_equal(1, world:getBodyCount())
        expect_equal("LBody", bodies[1]:type())
        local x, y = bodies[1]:getPosition()
        expect_near(24.0, x, 0.001)
        expect_near(24.0, y, 0.001)
        expect_near(0.85, bodies[1]:getRestitution(), 0.001)
        expect_equal(2, bodies[1]:getLayer())
        expect_equal(3, bodies[1]:getMask())
    end)

    -- @covers lurek.tilefield.createLightsFromTileset
    it("creates normal lights and occluders from tileset objects", function()
        lurek.light.clear()
        local tileset = lurek.tileset.fromProvider({
            firstGid = 20,
            tileCount = 4,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                torch_wall = {
                    renderLight = {
                        shape = "square",
                        radius = 80,
                        intensity = 1.25,
                        color = { 1.0, 0.7, 0.3, 1.0 },
                        shadowEnabled = true,
                    },
                    occluder = {
                        shape = "hex",
                        opacity = 0.75,
                        lightMask = 5,
                    },
                },
            },
            tileObjects = { [1] = "torch_wall" },
        })
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setRef(1, 2, 1, "tiles", 20)

        local spawned = lurek.tilefield.createLightsFromTileset(field, "tiles", tileset, { refIsGid = true })

        expect_equal(1, #spawned.lights)
        expect_equal(1, #spawned.occluders)
        expect_equal(1, lurek.light.getLightCount())
        expect_equal(1, lurek.light.getOccluderCount())
        local lx, ly = spawned.lights[1]:getPosition()
        expect_near(8.0, lx, 0.001)
        expect_near(24.0, ly, 0.001)
        expect_near(80.0, spawned.lights[1]:getRadius(), 0.001)
        expect_near(1.25, spawned.lights[1]:getIntensity(), 0.001)
        local ox, oy = spawned.occluders[1]:getPosition()
        expect_near(8.0, ox, 0.001)
        expect_near(24.0, oy, 0.001)
        expect_equal(12, #spawned.occluders[1]:getVertices())
        expect_near(0.75, spawned.occluders[1]:getOpacity(), 0.001)
        expect_equal(5, spawned.occluders[1]:getLightMask())
    end)

    -- @covers lurek.tilefield.newFieldMap
    it("creates a layered map of shared fields", function()
        local map = lurek.tilefield.newFieldMap({
            width = 2,
            height = 3,
            layers = 2,
            fieldWidth = 4,
            fieldHeight = 5,
            fieldLevels = 1,
            topology = "square4",
        })
        expect_equal("LTileFieldMap", map:type())
        expect_true(map:typeOf("LTileFieldMap"))
    end)
end)

-- @describe LTileFieldMap methods
describe("LTileFieldMap methods", function()
    -- @covers LTileFieldMap:inBounds
    it("checks map slot bounds", function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
        expect_true(map:inBounds(2, 2, 2))
        expect_true(not map:inBounds(3, 1, 1))
    end)

    -- @covers LTileFieldMap:getField
    it("returns shared fields from map slots", function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
        local field = map:getField(2, 2, 2)
        field:setRef(1, 1, 1, "floor", 44)
        expect_equal(44, map:getField(2, 2, 2):getRef(1, 1, 1, "floor"))
    end)

    -- @covers LTileFieldMap:setField
    it("stores compatible external fields", function()
        local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
        local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
        field:setRef(2, 2, 1, "object", 90)
        map:setField(1, 1, 1, field)
        expect_equal(90, map:getField(1, 1, 1):getRef(2, 2, 1, "object"))
    end)
end)

-- @describe LTileField cell state
describe("LTileField cell state", function()
    -- @covers LTileField:getSize
    it("returns width height and levels", function()
        local field = lurek.tilefield.new({ width = 7, height = 8, levels = 3 })
        local w, h, levels = field:getSize()
        expect_equal(7, w)
        expect_equal(8, h)
        expect_equal(3, levels)
    end)

    -- @covers LTileField:getTopology
    it("returns topology", function()
        local field = lurek.tilefield.new({ width = 4, height = 4, topology = "iso_square" })
        expect_equal("iso_square", field:getTopology())
    end)

    -- @covers LTileField:inBounds
    it("checks one-based bounds", function()
        local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
        expect_true(field:inBounds(2, 2, 2))
        expect_true(not field:inBounds(3, 2, 1))
    end)

    -- @covers LTileField:setRegionCells
    it("stores named regions from explicit tile cells", function()
        local field = lurek.tilefield.new({ width = 5, height = 5, levels = 2 })
        field:setRegionCells("stairs", {
            { x = 2, y = 2, z = 1 },
            { x = 2, y = 2, z = 1 },
            { x = 2, y = 3, z = 2 },
        })
        expect_equal(2, #field:getRegionCells("stairs"))
        expect_true(field:regionContains("stairs", 2, 3, 2))
    end)

    -- @covers LTileField:clear
    it("clears all cells", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "move", true)
        field:clear()
        expect_true(not field:blocks(2, 2, 1, "move"))
    end)

    -- @covers LTileField:clearCell
    it("clears one cell", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "vision", true)
        field:clearCell(2, 2, 1)
        expect_true(not field:blocks(2, 2, 1, "vision"))
    end)

    -- @covers LTileField:getCell
    it("returns cell table", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "action", true)
        local cell = field:getCell(2, 2, 1)
        expect_true(cell.blocks.action)
    end)

    -- @covers LTileField:setCell
    it("sets cell table", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setCell(2, 2, 1, {
            blocks = { move = true },
            costs = { move = 4 },
            sunOcclusion = 0.25,
            refs = { floor = 7 },
        })
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_near(4.0, field:getCost(2, 2, 1, "move"), 0.001)
        expect_near(0.25, field:getSunOcclusion(2, 2, 1), 0.001)
        expect_equal(7, field:getCell(2, 2, 1).refs.floor)
    end)

    -- @covers LTileField:setBlock
    it("sets channel blockers independently", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(2, 2, 1, "vision", true)
        expect_true(field:blocks(2, 2, 1, "vision"))
        expect_true(not field:blocks(2, 2, 1, "action"))
    end)

    -- @covers LTileField:blocks
    it("returns blocker state", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setBlock(1, 1, 1, "light", true)
        expect_true(field:blocks(1, 1, 1, "light"))
    end)

    -- @covers LTileField:setCost
    it("sets channel cost", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setCost(1, 2, 1, "move", 3.5)
        expect_near(3.5, field:getCost(1, 2, 1, "move"), 0.001)
    end)

    -- @covers LTileField:getCost
    it("returns default cost", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        expect_near(1.0, field:getCost(1, 1, 1, "move"), 0.001)
    end)

    -- @covers LTileField:setSunOcclusion
    it("sets sun occlusion", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        field:setSunOcclusion(1, 1, 1, 0.75)
        expect_near(0.75, field:getSunOcclusion(1, 1, 1), 0.001)
    end)

    -- @covers LTileField:getSunOcclusion
    it("returns default sun occlusion", function()
        local field = lurek.tilefield.new({ width = 3, height = 3 })
        expect_near(0.0, field:getSunOcclusion(1, 1, 1), 0.001)
    end)

    -- @covers LTileField:getDirtyRects
    it("getDirtyRects reports pending edit rectangles with optional chunk coordinates", function()
        local field = lurek.tilefield.new({ width = 6, height = 6 })
        field:beginEdit()
        field:setBlock(2, 2, 1, "move", true)
        field:setResource(3, 2, 1, "copper")
        local rects = field:getDirtyRects(4)
        expect_equal(2, #rects)
        expect_equal(0, rects[1].cx)
    end)

    -- @covers LTileField:beginEdit
    it("beginEdit batches dirty rectangles until commit", function()
        local field = lurek.tilefield.new({ width = 6, height = 6 })
        field:beginEdit()
        field:setBlock(2, 2, 1, "move", true)
        expect_equal(1, #field:getDirtyRects())
    end)

    -- @covers LTileField:commitEdit
    it("commitEdit returns grouped dirty rectangles and ends the batch", function()
        local field = lurek.tilefield.new({ width = 6, height = 6 })
        field:beginEdit()
        field:setBlock(2, 2, 1, "move", true)
        field:setResource(3, 2, 1, "copper")
        local dirty = field:commitEdit(4)
        expect_equal(2, #dirty)
        expect_equal(2, dirty[1].x)
        expect_equal(1, dirty[1].z)
        expect_equal(0, dirty[1].cx)
    end)

    -- @covers LTileField:drainDirtyRects
    it("drainDirtyRects clears pending dirty rectangles", function()
        local field = lurek.tilefield.new({ width = 6, height = 6 })
        field:setBlock(2, 2, 1, "move", true)
        expect_equal(1, #field:drainDirtyRects())
        expect_equal(0, #field:drainDirtyRects())
    end)

    -- @covers LTileField:defineBlockWorldSlots
    it("defines conventional block-world ref slots on the existing field", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        local slots = field:defineBlockWorldSlots()
        expect_equal("foreground", slots[1])
        field:setRef(2, 2, 1, "foreground", 11)
        field:setRef(2, 2, 1, "wall", 12)
        expect_equal(11, field:getRef(2, 2, 1, "foreground"))
        expect_equal(12, field:getRef(2, 2, 1, "wall"))
    end)

    -- @covers LTileField:snapshot
    it("snapshot captures block layers, refs, resources, and buildable facts", function()
        local field = lurek.tilefield.new({ width = 4, height = 4, levels = 1 })
        field:defineBlockWorldSlots()
        field:setBlock(2, 2, 1, "move", true)
        field:setCost(2, 2, 1, "move", 5.0)
        field:setRef(2, 2, 1, "foreground", 20)
        field:setRef(2, 2, 1, "wall", 30)
        field:setResource(3, 2, 1, "iron")
        field:setBuildable(4, 2, 1, false)
        field:setOccupant(1, 1, 1, 77)

        local snapshot = field:snapshot()
        local clone = lurek.tilefield.new({ width = 1, height = 1 })
        clone:restore(snapshot)

        expect_equal(4, snapshot.width)
        expect_equal(4, snapshot.height)
        expect_equal(20, clone:getRef(2, 2, 1, "foreground"))
        expect_equal("iron", clone:getResource(3, 2, 1))
    end)

    -- @covers LTileField:restore
    it("restore applies a tilefield snapshot to another field", function()
        local field = lurek.tilefield.new({ width = 4, height = 4, levels = 1 })
        field:defineBlockWorldSlots()
        field:setBlock(2, 2, 1, "move", true)
        field:setCost(2, 2, 1, "move", 5.0)
        field:setRef(2, 2, 1, "foreground", 20)
        field:setRef(2, 2, 1, "wall", 30)
        field:setResource(3, 2, 1, "iron")
        field:setBuildable(4, 2, 1, false)
        field:setOccupant(1, 1, 1, 77)

        local clone = lurek.tilefield.new({ width = 1, height = 1 })
        clone:restore(field:snapshot())

        expect_true(clone:blocks(2, 2, 1, "move"))
        expect_near(5.0, clone:getCost(2, 2, 1, "move"), 0.001)
        expect_equal(20, clone:getRef(2, 2, 1, "foreground"))
        expect_equal(30, clone:getRef(2, 2, 1, "wall"))
        expect_equal("iron", clone:getResource(3, 2, 1))
        expect_false(clone:isBuildable(4, 2, 1))
        expect_equal(77, clone:getOccupant(1, 1, 1))
    end)
end)

-- @describe LTileField categories and lines
describe("LTileField categories and lines", function()
    -- @covers LTileField:setCategoryBlock
    it("registers custom category blocker", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:defineCategory("grate_move", { kind = "movement" })
        field:setCategoryBlock(2, 2, 1, "grate_move", true)
        field:setSunOcclusion(2, 2, 1, 0.1)
        expect_true(field:blocksCategory(2, 2, 1, "grate_move"))
        expect_near(0.1, field:getSunOcclusion(2, 2, 1), 0.001)
    end)

    -- @covers LTileField:getCategory
    it("returns category details", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:defineCategory("wall_move", { kind = "movement", active = true })
        local wall = field:getCategory("wall_move")
        expect_equal("movement", wall.kind)
        expect_true(wall.active)
    end)

    -- @covers LTileField:clearModifier
    it("removes applied modifier", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setModifier("tmp", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "tmp")
        expect_true(field:blocks(2, 2, 1, "move"))
        expect_true(field:clearModifier(2, 2, 1, "tmp"))
        expect_true(not field:blocks(2, 2, 1, "move"))
    end)

    -- @covers LTileField:line
    it("returns square line cells", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        local cells = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 4, y = 1, z = 1 } })
        expect_equal(4, #cells)
        expect_equal(4, cells[#cells].x)
    end)

    -- @covers LTileField:clearLine
    it("uses selected blocker channel for clear line", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        field:setBlock(3, 1, 1, "vision", true)
        expect_true(not field:clearLine({ x = 1, y = 1, z = 1 }, { x = 5, y = 1, z = 1 }, "vision"))
        expect_true(field:clearLine({ x = 1, y = 1, z = 1 }, { x = 5, y = 1, z = 1 }, "action"))
    end)

    -- @covers LTileField:firstBlocker
    it("returns first blocker cell", function()
        local field = lurek.tilefield.new({ width = 5, height = 5 })
        field:setBlock(3, 1, 1, "action", true)
        local blocker = field:firstBlocker({ x = 1, y = 1, z = 1 }, { x = 5, y = 1, z = 1 }, "action")
        expect_equal(3, blocker.x)
    end)
end)

-- @describe LTileLightMap lighting and LTileField exports
describe("LTileLightMap lighting and LTileField exports", function()
    -- @covers LTileField:exportBlockLayer
    it("exports block layer", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setBlock(2, 1, 1, "move", true)
        local layer = field:exportBlockLayer("move", 1)
        expect_equal(4, #layer)
        expect_true(layer[2])
    end)

    -- @covers LTileField:exportCostLayer
    it("exports cost layer", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setCost(2, 1, 1, "move", 5)
        local layer = field:exportCostLayer("move", 1)
        expect_equal(5, layer[2])
    end)

    -- @covers LTileField:getCategories
    it("exports category registry names", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:defineCategory("window_move", { kind = "movement" })
        local names = field:getCategories()
        expect_true(#names >= 1)
    end)

    -- @covers LTileField:setRegionProperty
    it("sets and clears region properties", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setRegionCells("exit", { { x = 4, y = 2, z = 1 } })
        field:setRegionProperty("exit", "targetScene", "town_square")
        expect_equal("town_square", field:getRegionProperty("exit", "targetScene"))
        field:setRegionProperty("exit", "targetScene", nil)
        expect_nil(field:getRegionProperty("exit", "targetScene"))
    end)

    -- @covers LTileField:getRegionProperty
    it("returns nil for missing region properties", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setRegionCells("shop", { { x = 2, y = 2, z = 1 } })
        expect_nil(field:getRegionProperty("shop", "music"))
    end)

    -- @covers LTileField:getRegionProperties
    it("returns all properties for a region", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setRegionCells("shop", { { x = 2, y = 2, z = 1 } })
        field:setRegionProperty("shop", "trigger", "open_shop")
        field:setRegionProperty("shop", "facing", "south")
        local props = field:getRegionProperties("shop")
        expect_equal("open_shop", props.trigger)
        expect_equal("south", props.facing)
    end)

    -- @covers LTileField:regionsAt
    it("lists all named regions containing a cell", function()
        local field = lurek.tilefield.new({ width = 4, height = 4 })
        field:setRegionRect("stairs", 2, 2, 3, 2, 1)
        field:setRegionCells("shop_door", { { x = 2, y = 2, z = 1 } })
        local regions = field:regionsAt(2, 2, 1)
        expect_equal(2, #regions)
        expect_equal("shop_door", regions[1])
        expect_equal("stairs", regions[2])
    end)

    -- @covers LTileField:type
    it("returns type name", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        expect_equal("LTileField", field:type())
    end)

    -- @covers LTileField:typeOf
    it("checks type name", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        expect_true(field:typeOf("LTileField"))
        expect_true(field:typeOf("LObject"))
    end)
end)

test_summary()
