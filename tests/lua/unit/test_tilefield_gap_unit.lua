-- Gap coverage for newer tilefield APIs.

local function field()
    return lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
end

local function object_tileset()
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", {
        tileId = 1,
        blocks = { move = true },
        costs = { move = 3 },
        properties = { material = "wood", cost = 3, solid = true },
    })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    return tileset
end

local function field_map()
    return lurek.tilefield.newFieldMap({
        width = 2,
        height = 3,
        layers = 2,
        fieldWidth = 4,
        fieldHeight = 5,
        fieldLevels = 2,
        topology = "hex",
    })
end

-- @describe tilefield module gap APIs
describe("tilefield module gap APIs", function()
    -- @covers lurek.tilefield.fromProvider
    it("creates a field from provider dimensions", function()
        local f = lurek.tilefield.fromProvider({ width = 3, height = 2, levels = 2, topology = "square4" })
        expect_equal("LTileField", f:type())
        expect_equal("square4", f:getTopology())
    end)
end)

-- @describe LTileField region and neighborhood APIs
describe("LTileField region and neighborhood APIs", function()
    -- @covers LTileField:getNeighbors
    it("returns neighboring cells", function()
        local cells = field():getNeighbors(2, 2, 1)
        expect_true(#cells >= 4)
    end)

    -- @covers LTileField:setRegionRect
    it("sets rectangular regions", function()
        local f = field()
        f:setRegionRect("room", 2, 2, 3, 2, 1)
        expect_true(f:regionContains("room", 2, 2, 1))
    end)

    -- @covers LTileField:removeRegion
    it("removes regions", function()
        local f = field()
        f:setRegionRect("room", 1, 1, 2, 2, 1)
        expect_true(f:removeRegion("room"))
    end)

    -- @covers LTileField:regionContains
    it("checks region membership", function()
        local f = field()
        f:setRegionCells("stairs", { { x = 2, y = 2, z = 1 } })
        expect_true(f:regionContains("stairs", 2, 2, 1))
    end)

    -- @covers LTileField:getRegionCells
    it("returns region cells", function()
        local f = field()
        f:setRegionRect("room", 1, 1, 2, 2, 1)
        expect_equal(4, #f:getRegionCells("room"))
    end)

    -- @covers LTileField:getRegionNames
    it("returns region names", function()
        local f = field()
        f:setRegionCells("stairs", { { x = 1, y = 1, z = 1 } })
        expect_equal("stairs", f:getRegionNames()[1])
    end)
end)

-- @describe LTileField category APIs
describe("LTileField category APIs", function()
    -- @covers LTileField:defineCategory
    it("defines categories", function()
        local f = field()
        f:defineCategory("tank", { kind = "movement" })
        expect_equal("movement", f:getCategory("tank").kind)
    end)

    -- @covers LTileField:blocksCategory
    it("reads category blockers", function()
        local f = field()
        f:setCategoryBlock(2, 2, 1, "tank", true)
        expect_true(f:blocksCategory(2, 2, 1, "tank"))
    end)

    -- @covers LTileField:setCategoryCost
    it("sets category costs", function()
        local f = field()
        f:setCategoryCost(2, 2, 1, "tank", 5)
        expect_near(5, f:getCategoryCost(2, 2, 1, "tank"), 0.001)
    end)

    -- @covers LTileField:getCategoryCost
    it("gets category costs", function()
        local f = field()
        f:setCategoryCost(2, 2, 1, "tank", 6)
        expect_near(6, f:getCategoryCost(2, 2, 1, "tank"), 0.001)
    end)

    -- @covers LTileField:setCategoryTransmission
    it("sets category transmission", function()
        local f = field()
        f:setCategoryTransmission(2, 2, 1, "light", 0.5)
        expect_near(0.5, f:getCategoryTransmission(2, 2, 1, "light"), 0.001)
    end)

    -- @covers LTileField:getCategoryTransmission
    it("gets category transmission", function()
        local f = field()
        f:setCategoryTransmission(2, 2, 1, "light", 0.25)
        expect_near(0.25, f:getCategoryTransmission(2, 2, 1, "light"), 0.001)
    end)

    -- @covers LTileField:setCategoryFilter
    it("sets category filters", function()
        local f = field()
        f:setCategoryFilter(2, 2, 1, "light", { 1, 0.5, 0.25 })
        expect_near(0.5, f:getCategoryFilter(2, 2, 1, "light")[2], 0.001)
    end)

    -- @covers LTileField:getCategoryFilter
    it("gets category filters", function()
        local f = field()
        f:setCategoryFilter(2, 2, 1, "light", { 0.25, 0.5, 1 })
        expect_near(1, f:getCategoryFilter(2, 2, 1, "light")[3], 0.001)
    end)

    -- @covers LTileField:footprintPassable
    it("checks category footprint passability", function()
        local f = field()
        f:setCategoryBlock(3, 2, 1, "tank", true)
        expect_true(not f:footprintPassable(2, 2, 1, 2, 1, "tank"))
    end)

    -- @covers LTileField:getVersion
    it("increments field version when changed", function()
        local f = field()
        local before = f:getVersion()
        f:setBlock(1, 1, 1, "move", true)
        expect_true(f:getVersion() > before)
    end)
end)

-- @describe LTileField modifier and slot APIs
describe("LTileField modifier and slot APIs", function()
    -- @covers LTileField:setProfile
    it("sets legacy profiles", function()
        local f = field()
        f:setProfile("bars", { blocks = { move = true, vision = false }, costs = { light = 0.35 } })
        expect_equal("bars", f:getProfile("bars").name)
    end)

    -- @covers LTileField:applyProfile
    it("applies legacy profiles", function()
        local f = field()
        f:setProfile("bars", { blocks = { move = true, vision = false } })
        f:applyProfile(2, 2, 1, "bars")
        expect_true(f:blocks(2, 2, 1, "move"))
    end)

    -- @covers LTileField:getProfile
    it("gets legacy profiles", function()
        local f = field()
        f:setProfile("glass", { blocks = { move = true, vision = false }, costs = { light = 0.25 } })
        expect_near(0.25, f:getProfile("glass").costs.light, 0.001)
    end)

    -- @covers LTileField:removeProfile
    it("removes legacy profiles", function()
        local f = field()
        f:setProfile("temporary", { blocks = { move = true } })
        expect_true(f:removeProfile("temporary"))
    end)

    -- @covers LTileField:setModifier
    it("sets named modifiers", function()
        local f = field()
        f:setModifier("mud", { costs = { move = 4 } })
        expect_equal("mud", f:getModifier("mud").name)
    end)

    -- @covers LTileField:getModifier
    it("gets named modifiers", function()
        local f = field()
        f:setModifier("mud", { costAdd = { move = 4 } })
        expect_near(4, f:getModifier("mud").costAdd.move, 0.001)
    end)

    -- @covers LTileField:removeModifier
    it("removes named modifiers", function()
        local f = field()
        f:setModifier("mud", { costs = { move = 4 } })
        expect_true(f:removeModifier("mud"))
    end)

    -- @covers LTileField:defineSlot
    it("defines ref slots", function()
        local f = field()
        f:defineSlot("object")
        expect_true(f:hasSlot("object"))
    end)

    -- @covers LTileField:removeSlot
    it("removes ref slots", function()
        local f = field()
        f:defineSlot("object")
        expect_true(f:removeSlot("object"))
    end)

    -- @covers LTileField:hasSlot
    it("checks ref slots", function()
        local f = field()
        f:defineSlot("object")
        expect_true(f:hasSlot("object"))
    end)

    -- @covers LTileField:applyModifier
    it("applies named modifiers", function()
        local f = field()
        f:setModifier("wall", { blocks = { move = true } })
        f:applyModifier(2, 2, 1, "wall")
        expect_true(f:blocks(2, 2, 1, "move"))
    end)

    -- @covers LTileField:getModifiers
    it("lists active modifiers", function()
        local f = field()
        f:setModifier("wall", { blocks = { move = true } })
        f:applyModifier(2, 2, 1, "wall")
        expect_equal("wall", f:getModifiers(2, 2, 1)[1])
    end)
end)

-- @describe LTileField ref and tileset APIs
describe("LTileField ref and tileset APIs", function()
    -- @covers LTileField:setRef
    it("sets refs", function()
        local f = field()
        f:setRef(2, 2, 1, "object", 1)
        expect_equal(1, f:getRef(2, 2, 1, "object"))
    end)

    -- @covers LTileField:getRef
    it("gets refs", function()
        local f = field()
        f:setRef(2, 2, 1, "object", { tileset = "props", object = "crate" })
        expect_equal("crate", f:getRef(2, 2, 1, "object").object)
    end)

    -- @covers LTileField:applyTilesetObject
    it("applies tileset object metadata to one ref", function()
        local f = field()
        local tileset = object_tileset()
        f:setRef(1, 1, 1, "object", 1)
        expect_true(f:applyTilesetObject(1, 1, 1, "object", tileset))
        expect_true(f:blocks(1, 1, 1, "move"))
    end)

    -- @covers LTileField:applyTilesetObjectLayer
    it("applies tileset object metadata to ref layers", function()
        local f = field()
        local tileset = object_tileset()
        f:setRef(1, 1, 1, "object", 1)
        f:setRef(2, 1, 1, "object", 1)
        expect_equal(2, f:applyTilesetObjectLayer("object", tileset, { z = 1 }))
    end)

    -- @covers LTileField:getRefProperty
    it("gets ref tileset properties", function()
        local f = field()
        local tileset = object_tileset()
        f:setRef(1, 1, 1, "object", 1)
        expect_equal("wood", f:getRefProperty(1, 1, 1, "object", tileset, "material"))
    end)

    -- @covers LTileField:getRefPropertyNumber
    it("gets numeric ref tileset properties", function()
        local f = field()
        local tileset = object_tileset()
        f:setRef(1, 1, 1, "object", 1)
        expect_near(3, f:getRefPropertyNumber(1, 1, 1, "object", tileset, "cost"), 0.001)
    end)

    -- @covers LTileField:getRefPropertyBool
    it("gets boolean ref tileset properties", function()
        local f = field()
        local tileset = object_tileset()
        f:setRef(1, 1, 1, "object", 1)
        expect_true(f:getRefPropertyBool(1, 1, 1, "object", tileset, "solid"))
    end)

    -- @covers LTileField:getRefProperties
    it("gets all ref tileset properties", function()
        local f = field()
        local tileset = object_tileset()
        f:setRef(1, 1, 1, "object", 1)
        expect_equal("floor", f:getRefProperties(1, 1, 1, "object", tileset).terrain)
    end)

    -- @covers LTileField:clearRef
    it("clears refs", function()
        local f = field()
        f:setRef(2, 2, 1, "object", 1)
        f:clearRef(2, 2, 1, "object")
        expect_equal(nil, f:getRef(2, 2, 1, "object"))
    end)

    -- @covers LTileField:getRefSlots
    it("lists ref slots", function()
        local f = field()
        f:defineSlot("object")
        expect_equal("object", f:getRefSlots()[1])
    end)
end)

-- @describe LTileField layer write APIs
describe("LTileField layer write APIs", function()
    -- @covers LTileField:writeBlockLayer
    it("writes block layers", function()
        local f = lurek.tilefield.new({ width = 2, height = 2 })
        f:writeBlockLayer("move", 1, { true, false, false, true })
        expect_true(f:blocks(1, 1, 1, "move"))
    end)

    -- @covers LTileField:writeCostLayer
    it("writes cost layers", function()
        local f = lurek.tilefield.new({ width = 2, height = 2 })
        f:writeCostLayer("move", 1, { 1, 2, 3, 4 })
        expect_near(4, f:getCost(2, 2, 1, "move"), 0.001)
    end)

    -- @covers LTileField:exportRefLayer
    it("exports ref layers", function()
        local f = lurek.tilefield.new({ width = 2, height = 2 })
        f:setRef(2, 1, 1, "object", 7)
        expect_equal(7, f:exportRefLayer("object", 1)[2])
    end)

    -- @covers LTileField:writeRefLayer
    it("writes ref layers", function()
        local f = lurek.tilefield.new({ width = 2, height = 2 })
        f:writeRefLayer("object", 1, { 1, nil, 3, 4 })
        expect_equal(3, f:getRef(1, 2, 1, "object"))
    end)
end)

-- @describe LTileFieldMap gap APIs
describe("LTileFieldMap gap APIs", function()
    -- @covers LTileFieldMap:getMapSize
    it("returns field map size", function()
        local w, h, layers = field_map():getMapSize()
        expect_equal(2, w)
        expect_equal(3, h)
        expect_equal(2, layers)
    end)

    -- @covers LTileFieldMap:getFieldSize
    it("returns contained field size", function()
        local w, h, levels = field_map():getFieldSize()
        expect_equal(4, w)
        expect_equal(5, h)
        expect_equal(2, levels)
    end)

    -- @covers LTileFieldMap:getTopology
    it("returns field map topology", function()
        expect_equal("hex", field_map():getTopology())
    end)

    -- @covers LTileFieldMap:type
    it("reports field map type", function()
        expect_equal("LTileFieldMap", field_map():type())
    end)

    -- @covers LTileFieldMap:typeOf
    it("matches field map type", function()
        expect_true(field_map():typeOf("LTileFieldMap"))
    end)
end)

test_summary()
