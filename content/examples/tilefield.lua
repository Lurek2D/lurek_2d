-- content/examples/tilefield.lua
-- Run: cargo run -- content/examples/tilefield.lua


--@api: lurek.tilefield.new
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2, topology = "square" })
    local w, h, levels = field:getSize()
    local topology = field:getTopology()
    local inside = field:inBounds(8, 8, 2)
    tilefield_log("new field " .. w .. "x" .. h .. "x" .. levels .. " " .. topology .. " inside=" .. tostring(inside))
end

--@api: lurek.tilefield.fromTileMap
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilemap.newTileMap(16, 16)
    map:addLayer("ground", 4, 4)
    map:setTile(1, 2, 2, 9)
    local field = lurek.tilefield.fromTileMap(map, { layer = 1, solidGids = { 9 } })
    tilefield_log("tilemap copied, blocked=" .. tostring(field:blocks(2, 2, 1, "move")))
end

--@api: lurek.tilefield.newFieldMap
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 4, fieldHeight = 4, topology = "square4" })
    local mw, mh, ml = map:getMapSize()
    local fw, fh = map:getFieldSize()
    local topology = map:getTopology()
    tilefield_log("fieldmap " .. mw .. "x" .. mh .. "x" .. ml .. " field=" .. fw .. "x" .. fh .. " topology=" .. topology)
end

--@api: LTileFieldMap:getMapSize
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 3, height = 2, layers = 1, fieldWidth = 4, fieldHeight = 4 })
    local width, height, layers = map:getMapSize()
    local slots = width * height * layers
    local valid = slots == 6
    tilefield_log("map slots=" .. slots .. " valid=" .. tostring(valid))
end

--@api: LTileFieldMap:getFieldSize
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 8, fieldHeight = 6, fieldLevels = 2 })
    local width, height, levels = map:getFieldSize()
    local cells = width * height * levels
    local field = map:getField(1, 1, 1)
    tilefield_log("field cells=" .. cells .. " type=" .. field:type())
end

--@api: LTileFieldMap:getTopology
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, fieldWidth = 4, fieldHeight = 4, topology = "hex" })
    local topology = map:getTopology()
    local field = map:getField(1, 1, 1)
    local same = field:getTopology() == topology
    tilefield_log("fieldmap topology=" .. topology .. " same=" .. tostring(same))
end

--@api: LTileFieldMap:inBounds
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local inside = map:inBounds(2, 2, 2)
    local outside = map:inBounds(3, 1, 1)
    local default_layer = map:inBounds(1, 1)
    tilefield_log("fieldmap bounds=" .. tostring(inside) .. "," .. tostring(outside) .. "," .. tostring(default_layer))
end

--@api: LTileFieldMap:getField
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 2, height = 2, layers = 2, fieldWidth = 3, fieldHeight = 3 })
    local field = map:getField(2, 2, 2)
    field:setRef(1, 1, 1, "floor", 12)
    local shared = map:getField(2, 2, 2):getRef(1, 1, 1, "floor")
    tilefield_log("shared field ref=" .. tostring(shared))
end

--@api: LTileFieldMap:setField
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local map = lurek.tilefield.newFieldMap({ width = 1, height = 1, layers = 1, fieldWidth = 3, fieldHeight = 3, topology = "square8" })
    local field = lurek.tilefield.new({ width = 3, height = 3, topology = "square8" })
    field:setRef(2, 2, 1, "object", 90)
    map:setField(1, 1, 1, field)
    tilefield_log("stored object=" .. tostring(map:getField(1, 1, 1):getRef(2, 2, 1, "object")))
end

--@api: LTileField:getSize
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 10, height = 6, levels = 3 })
    local width, height, levels = field:getSize()
    local cells = width * height * levels
    local valid = cells == 180
    tilefield_log("field cells=" .. cells .. " valid=" .. tostring(valid))
end

--@api: LTileField:getTopology
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5, topology = "iso_square" })
    local topology = field:getTopology()
    local same_logic = topology == "iso_square"
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 3, y = 1, z = 1 } })
    tilefield_log("topology=" .. topology .. " line=" .. #line .. " same=" .. tostring(same_logic))
end

--@api: LTileField:inBounds
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3, levels = 2 })
    local a = field:inBounds(1, 1, 1)
    local b = field:inBounds(4, 1, 1)
    local c = field:inBounds(3, 3, 2)
    tilefield_log("bounds " .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end

--@api: LTileField:clear
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    local before = field:blocks(2, 2, 1, "move")
    field:clear()
    tilefield_log("clear before=" .. tostring(before) .. " after=" .. tostring(field:blocks(2, 2, 1, "move")))
end

--@api: LTileField:clearCell
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "vision", true)
    field:setBlock(3, 2, 1, "vision", true)
    field:clearCell(2, 2, 1)
    tilefield_log("clearCell target=" .. tostring(field:blocks(2, 2, 1, "vision")) .. " neighbor=" .. tostring(field:blocks(3, 2, 1, "vision")))
end

--@api: LTileField:getCell
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local cell = field:getCell(2, 2, 1)
    local move = cell.blocks.move
    local vision = cell.blocks.vision
    tilefield_log("cell move=" .. tostring(move) .. " vision=" .. tostring(vision))
end

--@api: LTileField:setCell
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCell(2, 2, 1, { blocks = { action = true }, costs = { move = 3 }, sunOcclusion = 0.25 })
    local action = field:blocks(2, 2, 1, "action")
    local cost = field:getCost(2, 2, 1, "move")
    tilefield_log("setCell action=" .. tostring(action) .. " cost=" .. cost)
end

--@api: LTileField:setBlock
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setBlock(2, 2, 1, "move", true)
    field:setBlock(2, 2, 1, "vision", false)
    local move = field:blocks(2, 2, 1, "move")
    tilefield_log("setBlock move=" .. tostring(move))
end

--@api: LTileField:blocks
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local vision = field:blocks(2, 2, 1, "vision")
    tilefield_log("blocks move=" .. tostring(move) .. " vision=" .. tostring(vision))
end

--@api: LTileField:setCost
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setCost(2, 2, 1, "move", 4)
    field:setCost(2, 3, 1, "move", 2)
    local a = field:getCost(2, 2, 1, "move")
    tilefield_log("setCost high=" .. a)
end

--@api: LTileField:getCost
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local base = field:getCost(1, 1, 1, "move")
    field:setCost(1, 2, 1, "move", 5)
    local changed = field:getCost(1, 2, 1, "move")
    tilefield_log("cost base=" .. base .. " changed=" .. changed)
end

--@api: LTileField:setSunOcclusion
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setSunOcclusion(1, 1, 2, 0.5)
    tilefield_log("sun occlusion=" .. field:getSunOcclusion(1, 1, 2))
end

--@api: LTileField:getSunOcclusion
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    field:setSunOcclusion(1, 1, 1, 0.3)
    local value = field:getSunOcclusion(1, 1, 1)
    local default = field:getSunOcclusion(2, 2, 1)
    tilefield_log("sun values=" .. value .. "," .. default)
end

--@api: LTileField:setProfile
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("bars", { blocks = { move = true, vision = false, action = true }, sunOcclusion = 0.1 })
    field:applyProfile(2, 2, 1, "bars")
    local visible = not field:blocks(2, 2, 1, "vision")
    tilefield_log("custom bars visible=" .. tostring(visible))
end

--@api: LTileField:applyProfile
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:applyProfile(2, 2, 1, "window")
    local move = field:blocks(2, 2, 1, "move")
    local light = field:blocks(2, 2, 1, "light")
    tilefield_log("window move=" .. tostring(move) .. " light=" .. tostring(light))
end

--@api: LTileField:getProfile
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local profile = field:getProfile("wall")
    local move = profile.blocks.move
    local vision = profile.blocks.vision
    tilefield_log("wall profile move=" .. tostring(move) .. " vision=" .. tostring(vision))
end

--@api: LTileField:removeProfile
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:setProfile("temporary", { blocks = { move = true } })
    field:removeProfile("temporary")
    local missing = field:getProfile("temporary") == nil
    tilefield_log("profile removed=" .. tostring(missing))
end

--@api: LTileField:exportRefLayer
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "floor", 101)
    field:setRef(2, 2, 1, "wall_left", 210)
    local layer = field:exportRefLayer("wall_left", 1)
    tilefield_log("floor=" .. field:getRef(2, 2, 1, "floor") .. " wall_left=" .. tostring(layer[6]))
end

--@api: LTileField:setRef
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", 101)
    local value = field:getRef(2, 2, 1, "object")
    tilefield_log("setRef object=" .. tostring(value))
end

--@api: LTileField:getRef
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4, levels = 2 })
    field:setRef(2, 2, 1, "object", { tileset = "props", object = "crate" })
    local value = field:getRef(2, 2, 1, "object")
    tilefield_log("getRef object=" .. tostring(value.object))
end

--@api: LTileField:line
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local line = field:line({ from = { x = 1, y = 1, z = 1 }, to = { x = 5, y = 1, z = 1 } })
    local first = line[1].x
    local last = line[#line].x
    tilefield_log("line first=" .. first .. " last=" .. last .. " count=" .. #line)
end

--@api: LTileField:clearLine
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local sight = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local action = field:clearLine({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "action")
    tilefield_log("clearLine sight=" .. tostring(sight) .. " action=" .. tostring(action))
end

--@api: LTileField:firstBlocker
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(4, 2, 1, "wall")
    local blocker = field:firstBlocker({ x = 1, y = 2, z = 1 }, { x = 6, y = 2, z = 1 }, "vision")
    local x = blocker and blocker.x or 0
    tilefield_log("first blocker x=" .. x)
end

--@api: LTileField:exportBlockLayer
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "wall")
    local layer = field:exportBlockLayer("move", 1)
    local blocked = layer[5]
    tilefield_log("block layer center=" .. tostring(blocked))
end

--@api: LTileField:exportCostLayer
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:setCost(2, 2, 1, "move", 7)
    local layer = field:exportCostLayer("move", 1)
    local center = layer[5]
    tilefield_log("cost layer center=" .. center)
end

--@api: LTileField:type
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local type_name = field:type()
    local expected = type_name == "LTileField"
    local object = field:typeOf("LObject")
    tilefield_log("type=" .. type_name .. " ok=" .. tostring(expected) .. " object=" .. tostring(object))
end

--@api: LTileField:typeOf
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local exact = field:typeOf("LTileField")
    local object = field:typeOf("LObject")
    local miss = field:typeOf("LNavGrid")
    tilefield_log("typeOf exact=" .. tostring(exact) .. " object=" .. tostring(object) .. " miss=" .. tostring(miss))
end

--- Added coverage examples for newer API owners.

--@api: lurek.tilefield.fromProvider
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getNeighbors
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local tileset = lurek.tileset.newTileSet(1, 4, 2, 16, 16)
    tileset:setObject("crate", { tileId = 1, blocks = { move = true }, costs = { move = 3 }, properties = { material = "wood", cost = 3, solid = true } })
    tileset:setTileObject(1, "crate")
    tileset:setProperty(1, "terrain", "floor")
    local ok, value = pcall(function()
        return #field:getNeighbors(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setRegionRect
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setRegionCells
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 4, levels = 2 })
    local cells = { { x = 2, y = 2, z = 1 }, { x = 3, y = 2, z = 1 } }
    field:setRegionCells("stairs", cells)
    local ok = field:regionContains("stairs", 3, 2, 1)
    example_log("setRegionCells contains=" .. tostring(ok))
end

--@api: LTileField:removeRegion
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:regionContains
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRegionCells
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRegionNames
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:defineCategory
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getCategory
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getCategories
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:blocksCategory
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryBlock
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryCost
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getCategoryCost
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryTransmission
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getCategoryTransmission
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setCategoryFilter
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getCategoryFilter
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:footprintPassable
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getVersion
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:setModifier
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getModifier
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:removeModifier
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:clearModifier
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:defineSlot
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:removeSlot
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:hasSlot
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:applyModifier
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getModifiers
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:applyTilesetObject
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:applyTilesetObjectLayer
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRefProperty
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRefPropertyNumber
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRefPropertyBool
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRefProperties
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:clearRef
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:getRefSlots
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:writeBlockLayer
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:writeCostLayer
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileField:writeRefLayer
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileFieldMap:type
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end

--@api: LTileFieldMap:typeOf
do
    local function example_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
end
