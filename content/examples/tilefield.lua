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
    field:setGlobalLight({ intensity = 1 })
    field:computeLight({ includeGlobalLight = true })
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

--@api: LTileField:addPointLight
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local id = field:addPointLight({ x = 2, y = 2, z = 1, radius = 4, intensity = 1 })
    field:computeLight({ includePointLights = true })
    local _, _, _, luma = field:getLight(2, 2, 1)
    tilefield_log("light id=" .. id .. " luma=" .. luma)
end

--@api: LTileField:updatePointLight
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local id = field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    field:updatePointLight(id, { x = 3, y = 3, radius = 4, intensity = 0.5 })
    field:computeLight({ includePointLights = true })
    tilefield_log("updated light at center")
end

--@api: LTileField:removePointLight
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    local id = field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    local removed = field:removePointLight(id)
    field:computeLight({ includePointLights = true })
    tilefield_log("removed=" .. tostring(removed))
end

--@api: LTileField:clearPointLights
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
    field:clearPointLights()
    field:computeLight({ includePointLights = true })
    tilefield_log("point lights cleared")
end

--@api: LTileField:setGlobalLight
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:setGlobalLight({ intensity = 0.35, color = { r = 1, g = 0.95, b = 0.8 } })
    field:computeLight({ includeGlobalLight = true })
    local _, _, _, luma = field:getLight(1, 1, 2)
    tilefield_log("global luma=" .. luma)
end

--@api: LTileField:computeLight
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 6, height = 4 })
    field:setProfile("smoked_glass", {
        blocks = { light = false, vision = false, move = true, action = true },
        costs = { light = 0.5 },
        sunOcclusion = 0.25,
    })
    field:applyProfile(4, 2, 1, "smoked_glass")
    field:addPointLight({ x = 2, y = 2, z = 1, radius = 5, color = { r = 1, g = 0.35, b = 0.1 } })
    field:computeLight({ includePointLights = true, ambient = { r = 0.02, g = 0.02, b = 0.02 } })
    local r, g, b, luma = field:getLight(6, 2, 1)
    tilefield_log("filtered rgb=" .. (r + g + b) .. " luma=" .. luma)
end

--@api: LTileField:getLight
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 4, height = 4 })
    field:computeLight({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
    local r, g, b, luma = field:getLight(1, 1, 1)
    local rgb = r + g + b
    tilefield_log("light rgb=" .. rgb .. " luma=" .. luma)
end

--@api: LTileField:exportLightLayer
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:computeLight({ ambient = { r = 0.1, g = 0.1, b = 0.1 } })
    local layer = field:exportLightLayer(1)
    local count = #layer
    tilefield_log("light layer count=" .. count .. " first=" .. layer[1].luma)
end

--@api: LTileField:exportLightVolume
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 2, height = 2, levels = 2 })
    field:computeLight({ ambient = { r = 0.05, g = 0.05, b = 0.05 } })
    local volume = field:exportLightVolume()
    local levels = #volume
    tilefield_log("light volume levels=" .. levels .. " cells=" .. #volume[1])
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

--@api: LTileField:exportProfileLayer
do
    local function tilefield_log(message)
        lurek.log.info("[tilefield.example] " .. tostring(message))
    end

    local field = lurek.tilefield.new({ width = 3, height = 3 })
    field:applyProfile(2, 2, 1, "window")
    local layer = field:exportProfileLayer(1)
    local center = layer[5]
    tilefield_log("profile layer center=" .. tostring(center))
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
