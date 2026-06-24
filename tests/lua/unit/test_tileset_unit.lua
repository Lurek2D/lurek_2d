-- Canonical unit coverage for lurek.tileset atlas, object, and catalog APIs.

local function sample_tileset()
    return lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 8,
        columns = 4,
        tileWidth = 16,
        tileHeight = 16,
        spacing = 1,
        margin = 2,
        objects = {
            crate = {
                slot = "object",
                tileId = 3,
                visual = { image = "crate.png", order = 2 },
                categoryBlocks = { sight = true },
                categoryCosts = { tank = 9 },
                transmission = { light = 0.25 },
                filters = { light = { 0.5, 0.75, 1.0 } },
                footprint = { w = 2, h = 3 },
                physics = {
                    shape = "diamond",
                    bodyType = "static",
                    density = 2.0,
                    friction = 0.4,
                    restitution = 0.8,
                    layer = 2,
                    mask = 7,
                },
                renderLight = {
                    shape = "square",
                    radius = 96,
                    intensity = 1.5,
                    color = { 1.0, 0.8, 0.4, 1.0 },
                    shadowEnabled = true,
                    falloff = "smooth",
                },
                occluder = {
                    shape = "hex",
                    opacity = 0.9,
                    lightMask = 3,
                },
                properties = { material = "wood" },
            },
        },
        tileObjects = {
            [3] = "crate",
        },
        properties = {
            [2] = { biome = "forest", cost = 2.5, solid = true },
        },
        animations = {
            [1] = { { tileid = 1, duration = 80 }, { tileid = 2, duration = 120 } },
        },
    })
end

-- @describe lurek.tileset v2 catalog
describe("lurek.tileset v2 catalog", function()
    -- @covers lurek.tileset.newTileSet
    it("creates an empty native tileset", function()
        local tileset = lurek.tileset.newTileSet(10, 4, 2, 16, 16)
        expect_equal(10, tileset:getFirstGid())
    end)

    -- @covers lurek.tileset.fromProvider
    it("builds a native tileset from a provider table", function()
        local tileset = sample_tileset()
        expect_equal(8, tileset:getTileCount())
    end)

    -- @covers lurek.tileset.newCatalog
    it("creates a typed tileset catalog", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_equal("LTileCatalog", catalog:type())
    end)

    -- @covers LTileCatalog:getIds
    it("lists catalog ids", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_equal("props", catalog:getIds()[1])
    end)

    -- @covers LTileCatalog:getTileset
    it("returns a catalog tileset by id", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_equal("LTileSet", catalog:getTileset("props"):type())
    end)

    -- @covers LTileCatalog:getObject
    it("resolves a typed object reference", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_equal("crate", catalog:getObject({ tileset = "props", tile = 3 }).name)
    end)

    -- @covers LTileCatalog:getVisual
    it("resolves a typed visual reference", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_equal("crate.png", catalog:getVisual({ tileset = "props", object = "crate" }).image)
    end)

    -- @covers LTileCatalog:type
    it("reports the catalog type", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_equal("LTileCatalog", catalog:type())
    end)

    -- @covers LTileCatalog:typeOf
    it("matches catalog type names", function()
        local catalog = lurek.tileset.newCatalog({ props = sample_tileset() })
        expect_true(catalog:typeOf("LTileCatalog"))
    end)

    -- @covers LTileSet:getFirstGid
    it("returns first gid", function()
        expect_equal(1, sample_tileset():getFirstGid())
    end)

    -- @covers LTileSet:getTileCount
    it("returns tile count", function()
        expect_equal(8, sample_tileset():getTileCount())
    end)

    -- @covers LTileSet:getColumns
    it("returns column count", function()
        expect_equal(4, sample_tileset():getColumns())
    end)

    -- @covers LTileSet:getTileWidth
    it("returns tile width", function()
        expect_equal(16, sample_tileset():getTileWidth())
    end)

    -- @covers LTileSet:getTileHeight
    it("returns tile height", function()
        expect_equal(16, sample_tileset():getTileHeight())
    end)

    -- @covers LTileSet:getTileDimensions
    it("returns tile dimensions", function()
        local w, h = sample_tileset():getTileDimensions()
        expect_equal(16, w)
        expect_equal(16, h)
    end)

    -- @covers LTileSet:getTextureDimensions
    it("returns texture dimensions", function()
        local w, h = sample_tileset():getTextureDimensions()
        expect_true(w > 0)
        expect_true(h > 0)
    end)

    -- @covers LTileSet:getSpacing
    it("returns spacing", function()
        expect_equal(1, sample_tileset():getSpacing())
    end)

    -- @covers LTileSet:getMargin
    it("returns margin", function()
        expect_equal(2, sample_tileset():getMargin())
    end)

    -- @covers LTileSet:getQuad
    it("returns a tile quad", function()
        local quad = sample_tileset():getQuad(3)
        expect_type("number", quad.x)
        expect_equal(16, quad.width)
        expect_equal(16, quad.height)
    end)

    -- @covers LTileSet:setProfile
    it("sets a tile profile", function()
        local tileset = sample_tileset()
        tileset:setProfile(2, "wall")
        expect_equal("wall", tileset:getProfile(2))
    end)

    -- @covers LTileSet:getProfile
    it("gets a tile profile", function()
        local tileset = sample_tileset()
        tileset:setProfile(2, "floor")
        expect_equal("floor", tileset:getProfile(2))
    end)

    -- @covers LTileSet:setPhysicsShape
    it("sets a physics shape", function()
        local tileset = sample_tileset()
        tileset:setPhysicsShape(2, "solid")
        expect_equal("solid", tileset:getPhysicsShape(2))
    end)

    -- @covers LTileSet:getPhysicsShape
    it("gets a physics shape", function()
        local tileset = sample_tileset()
        tileset:setPhysicsShape(2, "slope")
        expect_equal("slope", tileset:getPhysicsShape(2))
    end)

    -- @covers LTileSet:setAnimation
    it("sets animation frames", function()
        local tileset = sample_tileset()
        tileset:setAnimation(1, { { tileid = 2, duration = 90 } })
        expect_equal(1, #tileset:getAnimation(1))
    end)

    -- @covers LTileSet:getAnimation
    it("gets animation frames", function()
        expect_equal(2, #sample_tileset():getAnimation(1))
    end)

    -- @covers LTileSet:setObject
    it("sets an object archetype", function()
        local tileset = sample_tileset()
        tileset:setObject("torch", { slot = "object", visual = { sprite = "torch" } })
        expect_equal("torch", tileset:getObject("torch").name)
    end)

    -- @covers LTileSet:getObject
    it("gets object category semantics and visuals", function()
        local object = sample_tileset():getObject("crate")
        expect_equal("object", object.slot)
        expect_equal("crate.png", object.visual.image)
        expect_true(object.categoryBlocks.sight)
        expect_near(9.0, object.categoryCosts.tank, 0.001)
        expect_near(0.25, object.transmission.light, 0.001)
        expect_near(0.75, object.filters.light[2], 0.001)
        expect_equal(2, object.footprint.w)
        expect_equal(3, object.footprint.h)
        expect_equal("diamond", object.physics.shape)
        expect_equal("static", object.physics.bodyType)
        expect_near(0.8, object.physics.restitution, 0.001)
        expect_equal("square", object.renderLight.shape)
        expect_near(96.0, object.renderLight.radius, 0.001)
        expect_equal("smooth", object.renderLight.falloff)
        expect_equal("hex", object.occluder.shape)
        expect_near(0.9, object.occluder.opacity, 0.001)
        expect_equal("wood", object.properties.material)
    end)

    -- @covers LTileSet:removeObject
    it("removes an object archetype", function()
        local tileset = sample_tileset()
        expect_true(tileset:removeObject("crate"))
        expect_equal(nil, tileset:getObject("crate"))
    end)

    -- @covers LTileSet:getObjectNames
    it("lists object archetype names", function()
        expect_equal("crate", sample_tileset():getObjectNames()[1])
    end)

    -- @covers LTileSet:setTileObject
    it("sets a tile-to-object mapping", function()
        local tileset = sample_tileset()
        tileset:setTileObject(4, "crate")
        expect_equal("crate", tileset:getTileObject(4))
    end)

    -- @covers LTileSet:getTileObject
    it("gets a tile-to-object mapping", function()
        expect_equal("crate", sample_tileset():getTileObject(3))
    end)

    -- @covers LTileSet:setProperty
    it("sets a tile property", function()
        local tileset = sample_tileset()
        tileset:setProperty(2, "biome", "cave")
        expect_equal("cave", tileset:getProperty(2, "biome"))
    end)

    -- @covers LTileSet:getProperty
    it("gets a tile property", function()
        expect_equal("forest", sample_tileset():getProperty(2, "biome"))
    end)

    -- @covers LTileSet:getPropertyNumber
    it("gets a numeric tile property", function()
        expect_near(2.5, sample_tileset():getPropertyNumber(2, "cost"), 0.001)
    end)

    -- @covers LTileSet:getPropertyBool
    it("gets a boolean tile property", function()
        expect_true(sample_tileset():getPropertyBool(2, "solid"))
    end)

    -- @covers LTileSet:getProperties
    it("gets all tile properties", function()
        expect_equal("forest", sample_tileset():getProperties(2).biome)
    end)

    -- @covers LTileSet:setAutoTileRule
    it("sets four-neighbor autotile rules", function()
        local tileset = sample_tileset()
        tileset:setAutoTileRule("wall", 3, 7)
        expect_equal(7, tileset:getAutoTileId("wall", 3))
    end)

    -- @covers LTileSet:getAutoTileId
    it("gets four-neighbor autotile ids", function()
        local tileset = sample_tileset()
        tileset:setAutoTileRule("road", 5, 6)
        expect_equal(6, tileset:getAutoTileId("road", 5))
    end)

    -- @covers LTileSet:setAutoTileRule8
    it("sets eight-neighbor autotile rules", function()
        local tileset = sample_tileset()
        tileset:setAutoTileRule8("water", 255, 8)
        expect_equal(8, tileset:getAutoTileId8("water", 255))
    end)

    -- @covers LTileSet:getAutoTileId8
    it("gets eight-neighbor autotile ids", function()
        local tileset = sample_tileset()
        tileset:setAutoTileRule8("cliff", 7, 4)
        expect_equal(4, tileset:getAutoTileId8("cliff", 7))
    end)

    -- @covers LTileSet:setAutoTileMode
    it("sets autotile mode", function()
        local tileset = sample_tileset()
        tileset:setAutoTileMode("water", "matchCornersAndSides")
        expect_equal("matchCornersAndSides", tileset:getAutoTileMode("water"))
    end)

    -- @covers LTileSet:getAutoTileMode
    it("gets autotile mode", function()
        local tileset = sample_tileset()
        tileset:setAutoTileMode("road", "matchSides")
        expect_equal("matchSides", tileset:getAutoTileMode("road"))
    end)

    -- @covers LTileSet:type
    it("reports tileset type", function()
        expect_equal("LTileSet", sample_tileset():type())
    end)

    -- @covers LTileSet:typeOf
    it("matches tileset type names", function()
        expect_true(sample_tileset():typeOf("LTileSet"))
    end)
end)

test_summary()
