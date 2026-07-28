-- content/examples/tilefield.lua
-- Run: cargo run -- content/examples/tilefield.lua


--@api: LTileField:removeCategory
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:defineCategory("hazard", { kind = "custom" })
    field:setCategoryFilter(2, 2, 1, "hazard", { 1.0, 0.5, 0.25 })
    local removed = field:removeCategory("hazard")
    local category = field:getCategory("hazard")
    local filter = field:getCategoryFilter(2, 2, 1, "hazard")
    lurek.log.info("custom category removed=" .. tostring(removed) .. " category=" .. tostring(category) .. " filter=" .. filter[1])
end


--@api: lurek.tilefield.new
do

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    lurek.log.info("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end

--@api: lurek.tilefield.fromTileMap
do

    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("ground", 4, 4)
    map:setTile(1, 2, 2, 9)
    local field = lurek.tilefield.fromTileMap(map, { layer = 1, solidGids = { 9 } })
    lurek.log.info("tilemap copied, blocked=" .. tostring(field:blocks(2, 2, 1, "move")))
end

--@api: lurek.tilefield.createPhysicsFromTileset
do

    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 2,
        columns = 2,
        tileWidth = 16,
        tileHeight = 16,
        objects = { wall = { physics = { shape = "rect", bodyType = "static", restitution = 0.8 } } },
        tileObjects = { [1] = "wall" },
    })
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setRef(2, 2, 1, "tiles", 1)
    local world = lurek.physics.newWorld(0, 0)
    local bodies = lurek.tilefield.createPhysicsFromTileset(field, "tiles", tileset, world, { refIsGid = true })
    lurek.log.info("tileset physics bodies=" .. #bodies .. " world=" .. world:getBodyCount())
end

--@api: lurek.tilefield.createLightsFromTileset
do

    lurek.light.clear()
    local tileset = lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 1,
        columns = 1,
        tileWidth = 16,
        tileHeight = 16,
        objects = { torch_wall = { renderLight = { radius = 64, intensity = 1.2, color = { 1, 0.8, 0.4, 1 } }, occluder = { shape = "diamond" } } },
        tileObjects = { [1] = "torch_wall" },
    })
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setRef(1, 1, 1, "tiles", 1)
    local spawned = lurek.tilefield.createLightsFromTileset(field, "tiles", tileset, { refIsGid = true })
    lurek.log.info("tileset lights=" .. #spawned.lights .. " occluders=" .. #spawned.occluders)
end

--@api: lurek.tilefield.newFieldMap
do

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 4, fieldHeight = 4, topology = "square4" })
    local mw, mh, ml = map:getMapSize()
    local fw, fh = map:getFieldSize()
    local topology = map:getTopology()
    lurek.log.info("fieldmap " .. mw .. "x" .. mh .. "x" .. ml .. " field=" .. fw .. "x" .. fh .. " topology=" .. topology)
end

--@api: LTileFieldMap:getMapSize
do

    local map = lurek.tilefield.newFieldMap({ width = 3, height = 2, layers = 1, fieldWidth = 4, fieldHeight = 4 })
    local width, height, layers = map:getMapSize()
    local slots = width * height * layers
    local valid = slots == 6
    lurek.log.info("map slots=" .. slots .. " valid=" .. tostring(valid))
end

--@api: LTileFieldMap:getFieldSize
do

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 8, fieldHeight = 6, fieldLevels = 2 })
    local width, height, levels = map:getFieldSize()
    local cells = width * height * levels
    local field = map:getField(1, 1, 1)
    lurek.log.info("field cells=" .. cells .. " type=" .. field:type())
end

--@api: LTileFieldMap:getTopology
do

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 4, fieldHeight = 4, topology = "hex" })
    local topology = map:getTopology()
    local field = map:getField(1, 1, 1)
    local same = field:getTopology() == topology
    lurek.log.info("fieldmap topology=" .. topology .. " same=" .. tostring(same))
end

--@api: LTileFieldMap:inBounds
do

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local inside = map:inBounds(2, 2, 2)
    local outside = map:inBounds(3, 1, 1)
    local default_layer = map:inBounds(1, 1)
    lurek.log.info("fieldmap bounds=" .. tostring(inside) .. "," .. tostring(outside) .. "," .. tostring(default_layer))
end

--@api: LTileFieldMap:getField
do

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local field = map:getField(2, 2, 2)
    field:setRef(1, 1, 1, "floor", 12)
    local shared = map:getField(2, 2, 2):getRef(1, 1, 1, "floor")
    lurek.log.info("shared field ref=" .. tostring(shared))
end

--@api: LTileFieldMap:setField
do

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
    local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
    field:setRef(2, 2, 1, "object", 90)
    map:setField(1, 1, 1, field)
    lurek.log.info("stored object=" .. tostring(map:getField(1, 1, 1):getRef(2, 2, 1, "object")))
end

--@api: LTileField:getSize
do

    local field = lurek.tilefield.new({ width = 10, height = 6, levels = 3 })
    local width, height, levels = field:getSize()
    local cells = width * height * levels
    local valid = cells == 180
    lurek.log.info("field cells=" .. cells .. " valid=" .. tostring(valid))
end

--@api: LTileField:getTopology
do

    local field = lurek.tilefield.new({ width = 5, height = 5, topology = "iso_square" })
    local topology = field:getTopology()
    local same_logic = topology == "iso_square"
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 3, y = 1, z = 1 } })
    lurek.log.info("topology=" .. topology .. " line=" .. #line .. " same=" .. tostring(same_logic))
end

--@api: LTileField:inBounds
do

    local field = lurek.tilefield.new({ width = 3, height = 3, levels = 2 })
    local a = field:inBounds(1, 1, 1)
    local b = field:inBounds(4, 1, 1)
    local c = field:inBounds(3, 3, 2)
    lurek.log.info("bounds " .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end

--@api: LTileField:clear
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    local before = field:blocks(2, 2, 1, "move")
    field:clear()
    lurek.log.info("clear before=" .. tostring(before) .. " after=" .. tostring(field:blocks(2, 2, 1, "move")))
end

--@api: LTileField:clearCell
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "vision", true)
    field:setBlock(3, 2, 1, "vision", true)
    field:clearCell(2, 2, 1)
    lurek.log.info("clearCell target=" .. tostring(field:blocks(2, 2, 1, "vision")) .. " neighbor=" .. tostring(field:blocks(3, 2, 1, "vision")))
end

--@api: LTileField:getCell
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local cell = field:getCell(2, 2, 1)
    local move = cell.blocks.move
    local vision = cell.blocks.vision
    lurek.log.info("cell move=" .. tostring(move) .. " vision=" .. tostring(vision))
end

--@api: LTileField:setCell
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCell(2, 2, 1, { blocks = { action = true }, costs = { move = 3 }, sunOcclusion = 0.25 })
    local action = field:blocks(2, 2, 1, "action")
    local cost = field:getCost(2, 2, 1, "move")
    lurek.log.info("setCell action=" .. tostring(action) .. " cost=" .. cost)
end

--@api: LTileField:setBlock
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(2, 2, 1, "vision", false)
    local move = field:blocks(2, 2, 1, "move")
    lurek.log.info("setBlock move=" .. tostring(move))
end

--@api: LTileField:blocks
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local vision = field:blocks(2, 2, 1, "vision")
    lurek.log.info("blocks move=" .. tostring(move) .. " vision=" .. tostring(vision))
end

--@api: LTileField:setCost
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCost(2, 2, 1, "move", 4)
    field:setCost(2, 3, 1, "move", 2)
    local a = field:getCost(2, 2, 1, "move")
    lurek.log.info("setCost high=" .. a)
end

--@api: LTileField:getCost
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local base = field:getCost(1, 1, 1, "move")
    field:setCost(1, 2, 1, "move", 5)
    local changed = field:getCost(1, 2, 1, "move")
    lurek.log.info("cost base=" .. base .. " changed=" .. changed)
end

--@api: LTileField:setSunOcclusion
do

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setSunOcclusion(1, 1, 2, 0.5)
    local value = field:getSunOcclusion(1, 1, 2)
    local default = field:getSunOcclusion(2, 2, 2)
    lurek.log.info("sun occlusion=" .. value .. " default=" .. default)
end

--@api: LTileField:getSunOcclusion
do

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setSunOcclusion(1, 1, 1, 0.3)
    local value = field:getSunOcclusion(1, 1, 1)
    local default = field:getSunOcclusion(2, 2, 1)
    lurek.log.info("sun values=" .. value .. "," .. default)
end

--@api: LTileField:setProfile
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("bars", { blocks = { move = true, vision = false, action = true }, sunOcclusion = 0.1 })
    field:applyProfile(2, 2, 1, "bars")
    local visible = not field:blocks(2, 2, 1, "vision")
    lurek.log.info("custom bars visible=" .. tostring(visible))
end

--@api: LTileField:applyProfile
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local light = field:blocks(2, 2, 1, "light")
    lurek.log.info("window move=" .. tostring(move) .. " light=" .. tostring(light))
end

--@api: LTileField:getProfile
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local profile = field:getProfile("wall")
    local move = profile.blocks.move
    local vision = profile.blocks.vision
    lurek.log.info("wall profile move=" .. tostring(move) .. " vision=" .. tostring(vision))
end

--@api: LTileField:removeProfile
do

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("temporary", { blocks = { move = true } })
    field:removeProfile("temporary")
    local missing = field:getProfile("temporary") == nil
    lurek.log.info("profile removed=" .. tostring(missing))
end

--@api: LTileField:exportRefLayer
do

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "floor", 101)
    field:setRef(2, 2, 1, "wall_left", 210)
    local layer = field:exportRefLayer("wall_left", 1)
    lurek.log.info("floor=" .. field:getRef(2, 2, 1, "floor") .. " wall_left=" .. tostring(layer[6]))
end

--@api: LTileField:setRef
do

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", 101)
    local value = field:getRef(2, 2, 1, "object")
    local slots = field:getRefSlots()
    lurek.log.info("setRef object=" .. tostring(value) .. " slots=" .. #slots)
end

--@api: LTileField:getRef
do

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", { tileset = "props", object = "crate" })
    local value = field:getRef(2, 2, 1, "object")
    local missing = field:getRef(1, 1, 1, "object")
    lurek.log.info("getRef object=" .. tostring(value.object) .. " missing=" .. tostring(missing))
end

--@api: LTileField:line
do

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 5, y = 1, z = 1 } })
    local first = line[1].x
    local last = line[#line].x
    lurek.log.info("line first=" .. first .. " last=" .. last .. " count=" .. #line)
end

--@api: LTileField:clearLine
do

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local sight = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local action = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "action")
    lurek.log.info("clearLine sight=" .. tostring(sight) .. " action=" .. tostring(action))
end

--@api: LTileField:firstBlocker
do

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(4, 2, 1, "wall")
    local blocker = field:firstBlocker({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local x = blocker and blocker.x or 0
    lurek.log.info("first blocker x=" .. x)
end

--@api: LTileField:exportBlockLayer
do

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "wall")
    local layer = field:exportBlockLayer("move", 1)
    local blocked = layer[5]
    lurek.log.info("block layer center=" .. tostring(blocked))
end

--@api: LTileField:exportCostLayer
do

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setCost(2, 2, 1, "move", 7)
    local layer = field:exportCostLayer("move", 1)
    local center = layer[5]
    lurek.log.info("cost layer center=" .. center)
end

--@api: LTileField:type
do

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local type_name = field:type()
    local expected = type_name == "LTileField"
    local object = field:typeOf("LObject")
    lurek.log.info("type=" .. type_name .. " ok=" .. tostring(expected) .. " object=" .. tostring(object))
end

--@api: LTileField:typeOf
do

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local exact = field:typeOf("LTileField")
    local object = field:typeOf("LObject")
    local miss = field:typeOf("LNavGrid")
    lurek.log.info("typeOf exact=" .. tostring(exact) .. " object=" .. tostring(object) .. " miss=" .. tostring(miss))
end

--- Added coverage examples for newer API owners.

--@api: lurek.tilefield.fromProvider
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local f = lurek.tilefield.fromProvider({ width = 3, height = 2, levels = 2, topology = "square4" })
        return f:getTopology()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getNeighbors
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        return #field:getNeighbors(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setRegionRect
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 2, 2, 3, 2, 1)
        return field:regionContains("room", 2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setRegionCells
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local cells = { { x = 2, y = 2, z = 1 }, { x = 3, y = 2, z = 1 } }
    field:setRegionCells("stairs", cells)
    local ok = field:regionContains("stairs", 3, 2, 1)
    lurek.log.info("setRegionCells contains=" .. tostring(ok))
end

--@api: LTileField:removeRegion
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 1, 1, 2, 2, 1)
        return field:removeRegion("room")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:regionContains
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionCells("stairs", { { x = 2, y = 2, z = 1 } })
        return field:regionContains("stairs", 2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRegionCells
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionRect("room", 1, 1, 2, 2, 1)
        return #field:getRegionCells("room")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRegionNames
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRegionCells("stairs", { { x = 1, y = 1, z = 1 } })
        return field:getRegionNames()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setRegionProperty
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionCells("exit", { { x = 5, y = 2, z = 1 } })
    field:setRegionProperty("exit", "targetScene", "town_square")
    local target = field:getRegionProperty("exit", "targetScene")
    lurek.log.info("region property set = " .. tostring(target))
end

--@api: LTileField:getRegionProperty
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionCells("inn", { { x = 2, y = 2, z = 1 } })
    field:setRegionProperty("inn", "music", "inn_theme")
    local music = field:getRegionProperty("inn", "music")
    lurek.log.info("region property = " .. tostring(music))
end

--@api: LTileField:getRegionProperties
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionCells("shop", { { x = 3, y = 3, z = 1 } })
    field:setRegionProperty("shop", "trigger", "open_shop")
    field:setRegionProperty("shop", "facing", "south")
    local props = field:getRegionProperties("shop")
    lurek.log.info("region properties trigger = " .. tostring(props and props.trigger))
    lurek.log.info("region properties facing = " .. tostring(props and props.facing))
end

--@api: LTileField:regionsAt
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    field:setRegionRect("stairs", 2, 2, 3, 2, 1)
    field:setRegionCells("shop_door", { { x = 2, y = 2, z = 1 } })
    local names = field:regionsAt(2, 2, 1)
    lurek.log.info("regions at tile = " .. #names)
    lurek.log.info("first region = " .. tostring(names[1]))
end

--@api: LTileField:defineCategory
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategory("tank").kind
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getCategory
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategory("tank").kind
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getCategories
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineCategory("tank", { kind = "movement" })
        return field:getCategories()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:blocksCategory
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(2, 2, 1, "tank", true)
        return field:blocksCategory(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryBlock
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(2, 2, 1, "tank", true)
        return field:blocksCategory(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryCost
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryCost(2, 2, 1, "tank", 5)
        return field:getCategoryCost(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getCategoryCost
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryCost(2, 2, 1, "tank", 6)
        return field:getCategoryCost(2, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryTransmission
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryTransmission(2, 2, 1, "light", 0.5)
        return field:getCategoryTransmission(2, 2, 1, "light")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getCategoryTransmission
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryTransmission(2, 2, 1, "light", 0.25)
        return field:getCategoryTransmission(2, 2, 1, "light")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryFilter
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryFilter(2, 2, 1, "light", { 1, 0.5, 0.25 })
        return field:getCategoryFilter(2, 2, 1, "light")[2]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getCategoryFilter
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryFilter(2, 2, 1, "light", { 0.25, 0.5, 1 })
        return field:getCategoryFilter(2, 2, 1, "light")[3]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:footprintPassable
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setCategoryBlock(3, 2, 1, "tank", true)
        return field:footprintPassable(2, 2, 1, 2, 1, "tank")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getVersion
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local before = field:getVersion()
        field:setBlock(1, 1, 1, "move", true)
        return field:getVersion() - before
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setModifier
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:getModifier("mud").name
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getModifier
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:getModifier("mud").costs.move
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:removeModifier
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        return field:removeModifier("mud")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:clearModifier
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("mud", { costs = { move = 4 } })
        field:applyModifier(2, 2, 1, "mud")
        field:clearModifier(2, 2, 1)
        return #field:getModifiers(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:defineSlot
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:hasSlot("object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:removeSlot
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:removeSlot("object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:hasSlot
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:hasSlot("object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:applyModifier
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("wall", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "wall")
        return field:blocks(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getModifiers
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setModifier("wall", { blocks = { move = true } })
        field:applyModifier(2, 2, 1, "wall")
        return field:getModifiers(2, 2, 1)[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:applyTilesetObject
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:applyTilesetObject(1, 1, 1, "object", tileset)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:applyTilesetObjectLayer
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        field:setRef(2, 1, 1, "object", 1)
        return field:applyTilesetObjectLayer("object", tileset, { z = 1 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRefProperty
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefProperty(1, 1, 1, "object", tileset, "material")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRefPropertyNumber
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefPropertyNumber(1, 1, 1, "object", tileset, "cost")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRefPropertyBool
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefPropertyBool(1, 1, 1, "object", tileset, "solid")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRefProperties
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(1, 1, 1, "object", 1)
        return field:getRefProperties(1, 1, 1, "object", tileset).terrain
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:clearRef
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:setRef(2, 2, 1, "object", 1)
        field:clearRef(2, 2, 1, "object")
        return field:getRef(2, 2, 1, "object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:getRefSlots
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:defineSlot("object")
        return field:getRefSlots()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:writeBlockLayer
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeBlockLayer("move", 1, { true, false, false, true })
        return field:blocks(1, 1, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:writeCostLayer
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeCostLayer("move", 1, { 1, 2, 3, 4 })
        return field:getCost(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:writeRefLayer
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        field:writeRefLayer("object", 1, { 1, nil, 3, 4 })
        return field:getRef(1, 2, 1, "object")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:beginEdit
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:beginEdit()
    field:setBlock(2, 2, 1, "move", true)
    field:setResource(3, 2, 1, "iron")
    local dirty = field:getDirtyRects()
    lurek.log.info("beginEdit dirty=" .. tostring(#dirty))
    lurek.log.info("beginEdit resource=" .. tostring(field:getResource(3, 2, 1)))
end

--@api: LTileField:getDirtyRects
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(3, 2, 1, "light", true)
    local dirty = field:getDirtyRects(4)
    local first = dirty[1] or { x = 0, y = 0, cx = 0, cy = 0 }
    lurek.log.info("dirty rects=" .. tostring(#dirty))
    lurek.log.info("first rect=" .. tostring(first.x) .. "," .. tostring(first.y) .. " chunk=" .. tostring(first.cx) .. "," .. tostring(first.cy))
end

--@api: LTileField:drainDirtyRects
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:setBlock(2, 2, 1, "move", true)
    field:setResource(3, 2, 1, "coal")
    local drained = field:drainDirtyRects()
    local remaining = field:getDirtyRects()
    lurek.log.info("drained rects=" .. tostring(#drained))
    lurek.log.info("remaining rects=" .. tostring(#remaining))
end

--@api: LTileField:commitEdit
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:beginEdit()
    field:setBlock(2, 2, 1, "move", true)
    field:setRef(2, 2, 1, "foreground", 12)
    local dirty = field:commitEdit(4)
    lurek.log.info("commit rects=" .. tostring(#dirty))
    lurek.log.info("commit ref=" .. tostring(field:getRef(2, 2, 1, "foreground")))
end

--@api: LTileField:defineBlockWorldSlots
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    local slots = field:defineBlockWorldSlots()
    field:setRef(2, 2, 1, "foreground", 12)
    field:setRef(2, 2, 1, "wall", 13)
    local foreground = field:getRef(2, 2, 1, "foreground")
    lurek.log.info("block slots=" .. tostring(#slots))
    lurek.log.info("foreground ref=" .. tostring(foreground))
end

--@api: LTileField:snapshot
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    field:defineBlockWorldSlots()
    field:setRef(2, 2, 1, "foreground", 12)
    field:setResource(3, 2, 1, "copper")
    local snapshot = field:snapshot()
    lurek.log.info("snapshot width=" .. tostring(snapshot.width))
    lurek.log.info("snapshot resources=" .. tostring(#snapshot.resources))
end

--@api: LTileField:restore
do
    local source = lurek.tilefield.new({ width = 5, height = 4, levels = 1 })
    source:defineBlockWorldSlots()
    source:setRef(2, 2, 1, "wall", 13)
    source:setBuildable(3, 2, 1, false)
    local snapshot = source:snapshot()
    local clone = lurek.tilefield.new({ width = 1, height = 1 })
    clone:restore(snapshot)
    lurek.log.info("restore wall=" .. tostring(clone:getRef(2, 2, 1, "wall")))
    lurek.log.info("restore buildable=" .. tostring(clone:isBuildable(3, 2, 1)))
end

--@api: LTileFieldMap:type
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 3, layers = 2, fieldWidth = 4, fieldHeight = 5, fieldLevels = 2 })
        return map:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileFieldMap:typeOf
do
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        local map = lurek.tilefield.newFieldMap({ width = 2, height = 3, layers = 2, fieldWidth = 4, fieldHeight = 5, fieldLevels = 2 })
        return map:typeOf("LTileFieldMap")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LTileField:setOccupant
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setOccupant(2, 3, 1, 99)
    local occupant = field:getOccupant(2, 3, 1)
    local occupied = occupant ~= nil
    lurek.log.info("occupant set=" .. tostring(occupant) .. " occupied=" .. tostring(occupied))
end

--@api: LTileField:clearOccupant
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setOccupant(2, 3, 1, 99)
    field:clearOccupant(2, 3, 1)
    local occupant = field:getOccupant(2, 3, 1)
    lurek.log.info("occupant after clear=" .. tostring(occupant))
end

--@api: LTileField:getOccupant
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setOccupant(1, 1, 77)
    local occupant = field:getOccupant(1, 1, 1)
    local same = occupant == 77
    lurek.log.info("occupant read=" .. tostring(occupant) .. " same=" .. tostring(same))
end

--@api: LTileField:setResource
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setResource(2, 3, 1, "ore")
    local resource = field:getResource(2, 3, 1)
    local has_resource = resource ~= nil
    lurek.log.info("resource set=" .. tostring(resource) .. " present=" .. tostring(has_resource))
end

--@api: LTileField:getResource
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setResource(2, 3, 1, "ore")
    local resource = field:getResource(2, 3, 1)
    local same = resource == "ore"
    lurek.log.info("resource read=" .. tostring(resource) .. " same=" .. tostring(same))
end

--@api: LTileField:setBuildable
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setBuildable(2, 3, 1, true)
    local buildable = field:isBuildable(2, 3, 1)
    local status = buildable and "allowed" or "blocked"
    lurek.log.info("buildability set=" .. status)
end

--@api: LTileField:isBuildable
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    field:setBuildable(2, 3, 1, true)
    local buildable = field:isBuildable(2, 3, 1)
    local status = buildable and "allowed" or "blocked"
    lurek.log.info("buildability read=" .. status)
end
--@api: LTileField:patchCells
do
    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:patchCells({ { x = 1, y = 1, costs = { move = 2 }, blocks = { move = true } } })
    local cost = field:getCost(1, 1, nil, "move")
    local blocked = field:blocks(1, 1, nil, "move")
    lurek.log.info("tile patch cost=" .. tostring(cost) .. " blocked=" .. tostring(blocked))
end
--@api: LTileField:inspectCells
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setOccupant(2, 2, 1, 41)
    local rows = field:inspectCells({ { x = 2, y = 2 }, { x = 3, y = 2 } })
    local first = rows[1].occupant
    local second = rows[2].occupant
    lurek.log.info("inspected occupants=" .. tostring(first) .. "," .. tostring(second))
end

--@api: LTileField:inspectFootprint
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setResource(1, 1, 1, "ore")
    field:setOccupant(2, 1, 1, 9)
    local summary = field:inspectFootprint({ x = 1, y = 1, w = 2, h = 2 })
    local occupied = summary.occupiedCount
    local resources = summary.resources.ore
    lurek.log.info("footprint occupied=" .. tostring(occupied))
    lurek.log.info("footprint resource cells=" .. tostring(resources))
end

--@api: LTileField:summarizeResources
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setResource(1, 1, 1, "ore")
    field:setResource(2, 1, 1, "ore")
    field:setResource(3, 1, 1, "coal")
    local resources = field:summarizeResources({ x = 1, y = 1, w = 3, h = 1 })
    lurek.log.info("ore cells=" .. tostring(resources.ore))
    lurek.log.info("coal cells=" .. tostring(resources.coal))
end

--@api: LTileField:setFootprintOccupant
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local before = field:getVersion()
    local changed = field:setFootprintOccupant({ x = 1, y = 1, w = 2, h = 2, occupant = 77 })
    local occupant = field:getOccupant(2, 2, 1)
    local after = field:getVersion()
    lurek.log.info("footprint changed=" .. tostring(changed) .. " occupant=" .. tostring(occupant))
    lurek.log.info("version advanced once=" .. tostring(after == before + 1))
end

--@api: LTileField:hashRegion
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setOccupant(2, 2, 1, 77)
    local first = field:hashRegion({ x = 1, y = 1, w = 3, h = 3 })
    local second = field:hashRegion({ x = 1, y = 1, w = 3, h = 3 })
    local stable = first == second
    lurek.log.info("field region hash=" .. first)
    lurek.log.info("stable=" .. tostring(stable))
end

--@api: LTileField:snapshotRegion
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setOccupant(2, 2, 1, 77)
    local snapshot = field:snapshotRegion({ x = 1, y = 1, w = 3, h = 3 })
    local cells = #snapshot.cells
    local hash = snapshot.hash
    lurek.log.info("snapshot cells=" .. tostring(cells))
    lurek.log.info("snapshot hash=" .. hash)
end

--@api: LTileField:preparePatch
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local before = field:getVersion()
    local batch = field:preparePatch({ { x = 1, y = 1, blocks = { move = true } } }, before)
    local preview = batch:preview()
    local pending = batch:isPending()
    lurek.log.info("prepared patches=" .. tostring(preview.patchCount))
    lurek.log.info("pending=" .. tostring(pending))
end

--@api: LTileFieldBatch:preview
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local batch = field:preparePatch({ { x = 1, y = 1, costs = { move = 3 } } })
    local preview = batch:preview()
    local affected = preview.affectedCellCount
    local changed = preview.changed
    lurek.log.info("affected cells=" .. tostring(affected))
    lurek.log.info("changed=" .. tostring(changed))
end

--@api: LTileFieldBatch:commit
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local before = field:getVersion()
    local batch = field:preparePatch({ { x = 1, y = 1, blocks = { move = true } } })
    local dirty = batch:commit()
    local blocked = field:blocks(1, 1, 1, "move")
    lurek.log.info("dirty cells=" .. tostring(#dirty) .. " blocked=" .. tostring(blocked))
    lurek.log.info("version=" .. tostring(before + 1))
end

--@api: LTileFieldBatch:discard
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local batch = field:preparePatch({ { x = 1, y = 1, blocks = { move = true } } })
    local discarded = batch:discard()
    local pending = batch:isPending()
    local blocked = field:blocks(1, 1, 1, "move")
    lurek.log.info("discarded=" .. tostring(discarded))
    lurek.log.info("pending=" .. tostring(pending) .. " blocked=" .. tostring(blocked))
end

--@api: LTileFieldBatch:isPending
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local batch = field:preparePatch({})
    local before = batch:isPending()
    batch:discard()
    local after = batch:isPending()
    lurek.log.info("pending before=" .. tostring(before))
    lurek.log.info("pending after=" .. tostring(after))
end

--@api: LTileFieldBatch:type
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local batch = field:preparePatch({})
    local type_name = batch:type()
    local pending = batch:isPending()
    local preview = batch:preview()
    lurek.log.info("field batch type=" .. type_name)
    lurek.log.info("pending=" .. tostring(pending) .. " patches=" .. tostring(preview.patchCount))
end

--@api: LTileFieldBatch:typeOf
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local batch = field:preparePatch({})
    local exact = batch:typeOf("LTileFieldBatch")
    local object = batch:typeOf("LObject")
    local other = batch:typeOf("LTileField")
    lurek.log.info("field batch exact=" .. tostring(exact))
    lurek.log.info("object=" .. tostring(object) .. " other=" .. tostring(other))
end
