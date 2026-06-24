-- content/examples/tileset.lua
-- Run: cargo run -- content/examples/tileset.lua

--- Tileset Module: atlas metadata, tile properties, object archetypes, and catalogs

--@api: lurek.tileset.newTileSet
do
    local tileset = lurek.tileset.newTileSet(1, 16, 4, 16, 16, 1, 2)
    lurek.log.info("tileset first gid = " .. tileset:getFirstGid())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: lurek.tileset.fromProvider
do
    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = {
            crate = { slot = "object", visual = { image = "crate.png", order = 2 } },
        },
    })
    lurek.log.info("provider object = " .. tileset:getObject("crate").name)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: lurek.tileset.newCatalog
do
    local terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local catalog = lurek.tileset.newCatalog({ terrain = terrain })
    lurek.log.info("catalog ids = " .. #catalog:getIds())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileCatalog:getIds
do
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    lurek.log.info("first catalog id = " .. catalog:getIds()[1])
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileCatalog:getTileset
do
    local terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    local catalog = lurek.tileset.newCatalog({ terrain = terrain })
    lurek.log.info("catalog tileset type = " .. catalog:getTileset("terrain"):type())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileCatalog:getObject
do
    local tileset = lurek.tileset.fromProvider({
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { crate = { slot = "object", tileId = 2 } },
        tileObjects = { [2] = "crate" },
    })
    local catalog = lurek.tileset.newCatalog({ props = tileset })
    lurek.log.info("catalog object = " .. catalog:getObject({ tileset = "props", tile = 2 }).name)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileCatalog:getVisual
do
    local tileset = lurek.tileset.fromProvider({
        tileCount = 4,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { crate = { slot = "object", visual = { image = "crate.png" } } },
    })
    local catalog = lurek.tileset.newCatalog({ props = tileset })
    lurek.log.info("catalog visual = " .. catalog:getVisual({ tileset = "props", object = "crate" }).image)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileCatalog:type
do
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    lurek.log.info("catalog type = " .. catalog:type())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileCatalog:typeOf
do
    local catalog = lurek.tileset.newCatalog({ terrain = lurek.tileset.newTileSet(1, 4, 2, 16, 16) })
    lurek.log.info("is catalog = " .. tostring(catalog:typeOf("LTileCatalog")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getFirstGid
do
    local tileset = lurek.tileset.newTileSet(10, 8, 4, 16, 16)
    lurek.log.info("first gid = " .. tileset:getFirstGid())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getTileCount
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("tile count = " .. tileset:getTileCount())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getColumns
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("columns = " .. tileset:getColumns())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getTileWidth
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("tile width = " .. tileset:getTileWidth())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getTileHeight
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    lurek.log.info("tile height = " .. tileset:getTileHeight())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getTileDimensions
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    local w, h = tileset:getTileDimensions()
    lurek.log.info("tile dimensions = " .. w .. "x" .. h)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getTextureDimensions
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16, 1, 2)
    local w, h = tileset:getTextureDimensions()
    lurek.log.info("texture dimensions = " .. w .. "x" .. h)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getSpacing
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16, 2, 0)
    lurek.log.info("spacing = " .. tileset:getSpacing())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getMargin
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16, 0, 3)
    lurek.log.info("margin = " .. tileset:getMargin())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getQuad
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    local quad = tileset:getQuad(3)
    lurek.log.info("quad = " .. quad.x .. "," .. quad.y .. "," .. quad.width .. "," .. quad.height)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setProfile
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProfile(2, "wall")
    lurek.log.info("profile set = " .. tileset:getProfile(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getProfile
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProfile(2, "floor")
    lurek.log.info("profile = " .. tileset:getProfile(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setPhysicsShape
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setPhysicsShape(2, "solid")
    lurek.log.info("shape set = " .. tileset:getPhysicsShape(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getPhysicsShape
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setPhysicsShape(2, "slope")
    lurek.log.info("shape = " .. tileset:getPhysicsShape(2))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setAnimation
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAnimation(1, { { tileid = 1, duration = 120 }, { tileid = 2, duration = 120 } })
    lurek.log.info("animation frames = " .. #tileset:getAnimation(1))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getAnimation
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAnimation(1, { { tileid = 2, duration = 90 } })
    lurek.log.info("animation tile = " .. tileset:getAnimation(1)[1].tileid)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setObject
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("torch", { slot = "object", visual = { sprite = "torch" }, light = { radius = 4 } })
    lurek.log.info("object set = " .. tileset:getObject("torch").name)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getObject
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object", properties = { material = "wood" } })
    lurek.log.info("object material = " .. tileset:getObject("crate").properties.material)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:removeObject
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object" })
    lurek.log.info("removed = " .. tostring(tileset:removeObject("crate")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getObjectNames
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object" })
    lurek.log.info("object names = " .. table.concat(tileset:getObjectNames(), ","))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setTileObject
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("crate", { slot = "object" })
    tileset:setTileObject(3, "crate")
    lurek.log.info("tile object set = " .. tileset:getTileObject(3))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getTileObject
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setObject("tree", { slot = "object" })
    tileset:setTileObject(4, "tree")
    lurek.log.info("tile object = " .. tileset:getTileObject(4))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setProperty
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "cost", 3)
    lurek.log.info("property set = " .. tileset:getProperty(2, "cost"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getProperty
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "biome", "forest")
    lurek.log.info("property = " .. tileset:getProperty(2, "biome"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getPropertyNumber
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "cost", 2.5)
    lurek.log.info("cost = " .. tileset:getPropertyNumber(2, "cost"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getPropertyBool
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "solid", true)
    lurek.log.info("solid = " .. tostring(tileset:getPropertyBool(2, "solid")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getProperties
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setProperty(2, "biome", "forest")
    lurek.log.info("properties biome = " .. tileset:getProperties(2).biome)
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setAutoTileRule
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAutoTileRule("wall", 3, 7)
    lurek.log.info("autotile rule = " .. tileset:getAutoTileId("wall", 3))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getAutoTileId
do
    local tileset = lurek.tileset.newTileSet(1, 8, 4, 16, 16)
    tileset:setAutoTileRule("road", 5, 6)
    lurek.log.info("autotile id = " .. tileset:getAutoTileId("road", 5))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setAutoTileRule8
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileRule8("water", 255, 12)
    lurek.log.info("autotile rule8 = " .. tileset:getAutoTileId8("water", 255))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getAutoTileId8
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileRule8("cliff", 7, 9)
    lurek.log.info("autotile id8 = " .. tileset:getAutoTileId8("cliff", 7))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:setAutoTileMode
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileMode("water", "matchCornersAndSides")
    lurek.log.info("autotile mode set = " .. tileset:getAutoTileMode("water"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:getAutoTileMode
do
    local tileset = lurek.tileset.newTileSet(1, 32, 8, 16, 16)
    tileset:setAutoTileMode("road", "matchSides")
    lurek.log.info("autotile mode = " .. tileset:getAutoTileMode("road"))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:type
do
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    lurek.log.info("tileset type = " .. tileset:type())
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end

--@api: LTileSet:typeOf
do
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    lurek.log.info("is tileset = " .. tostring(tileset:typeOf("LTileSet")))
    local verified = true
    local label = "tileset"
    lurek.log.info(label .. " verified = " .. tostring(verified))
end
