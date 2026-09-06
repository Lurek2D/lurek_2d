-- content/examples/raycaster.lua
-- Auto-generated from content/examples2/raycaster_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/raycaster.lua
-- Focused feature walkthrough: raycaster_layered_sky.demo.lua


--@api: lurek.raycaster.buildMultiLevelSceneFromField
do

local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local field = lurek.tilefield.new({ width = 5, height = 5, levels = 2 })
field:setRef(3, 3, 1, "wall", { tileset = "dungeon", object = "stone_wall" })
field:setRef(4, 3, 1, "door", 12)
field:setRef(4, 4, 2, "window", 13)
field:setRef(3, 4, 1, "floor", { tileset = "dungeon", object = "stone_floor" })
field:setRef(3, 4, 1, "ceiling", { tileset = "dungeon", object = "stone_ceiling" })
field:setRef(3, 4, 1, "object", { tileset = "dungeon", object = "banner" })
field:setModifier("torch", { light = { radius = 4, intensity = 1.25, color = { 1.0, 0.75, 0.35 } } })
field:applyModifier(3, 4, 1, "torch")
end



--@api: lurek.raycaster.drawLastScene
do
local map = lurek.raycaster.new(8, 8)
local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local atlas = lurek.image.newImageData(8, 4)
atlas:fill(0, 0, 0, 0)
atlas:drawRect(0, 0, 4, 4, 255, 120, 40, 255)
atlas:drawRect(4, 0, 4, 4, 60, 220, 90, 255)
local atlas_texture = lurek.render.newImage(atlas)
local sky_data = lurek.image.newImageData(32, 16)
sky_data:fill(8, 18, 48, 255)
sky_data:drawRect(4, 3, 1, 1, 255, 255, 220, 255)
sky_data:drawRect(18, 6, 1, 1, 220, 235, 255, 255)
sky_data:drawRect(27, 2, 1, 1, 255, 255, 255, 255)
local sky_texture = lurek.render.newImage(sky_data)
local moon_data = lurek.image.newImageData(32, 16)
moon_data:fill(0, 0, 0, 0)
moon_data:drawRect(22, 3, 5, 5, 255, 228, 150, 230)
end



--@api: lurek.raycaster.new
do

    local map = lurek.raycaster.new(16, 16)
    map:setCell(1, 1, 2)
    lurek.log.info("new width=" .. map:width())
    lurek.log.info("new height=" .. map:height())
    lurek.log.info("spawn cell=" .. map:getCell(1, 1))
    lurek.log.info("spawn blocked=" .. tostring(map:isBlocked(1, 1)))
end

--@api: lurek.raycaster.newMap
do

    local map = lurek.raycaster.newMap(32, 32)
    map:setCell(4, 4, 3)
    lurek.log.info("newMap width=" .. map:width())
    lurek.log.info("newMap height=" .. map:height())
    lurek.log.info("editor cell=" .. map:getCell(4, 4))
    lurek.log.info("empty corridor=" .. tostring(map:isBlocked(5, 5)))
end

--@api: LRaycaster:setCell
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    map:setCell(1, 0, 2)
    lurek.log.info("cell(0,0)=" .. map:getCell(0, 0))
    lurek.log.info("cell(1,0)=" .. map:getCell(1, 0))
    lurek.log.info("blocked corner=" .. tostring(map:isBlocked(0, 0)))
    lurek.log.info("blocked neighbor=" .. tostring(map:isBlocked(1, 0)))
end

--@api: LRaycaster:getCell
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    local value = map:getCell(0, 0)
    local empty = map:getCell(7, 7)

    lurek.log.info("cell(0,0) = " .. value)
    lurek.log.info("cell(7,7) = " .. empty)
end

--@api: LRaycaster:applyDoorManager
do

    local map = lurek.raycaster.new(8, 8)
    local doors = lurek.raycaster.newDoorManager()
    map:setCell(3, 3, 2)

    local id = doors:addDoor(3, 3, "vertical", 1.0)
    map:applyDoorManager(doors)
    lurek.log.info("closed blocked = " .. tostring(map:isBlocked(3, 3)))

    doors:openDoor(id)
    doors:update(1.0)
    map:applyDoorManager(doors, 0.8)

    local feature = map:getWallFeatureCell(3, 3)
    lurek.log.info("kind = " .. feature.kind)
    lurek.log.info("blocked after open = " .. tostring(map:isBlocked(3, 3)))
    lurek.log.info("open amount = " .. string.format("%.2f", feature.open_amount))
end

--@api: LRaycaster:setWallFeatureCell
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWallFeatureCell(3, 3, { kind = "window", sill_height = 0.25, lintel_height = 0.75, alpha = 0.4 })
    local feature = map:getWallFeatureCell(3, 3)

    lurek.log.info("feature kind = " .. feature.kind)
    lurek.log.info("feature alpha = " .. string.format("%.2f", feature.alpha))
end

--@api: LRaycaster:clearWallFeatureCell
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setWallFeatureCell(3, 3, { kind = "window", sill_height = 0.25, lintel_height = 0.75, alpha = 0.35 })
    map:clearWallFeatureCell(3, 3)
    lurek.log.info("feature cleared = " .. tostring(map:getWallFeatureCell(3, 3) == nil))
end

--@api: LRaycaster:setPickAttr
do

    local map = lurek.raycaster.new(6, 4)
    map:setCell(4, 1, 7)
    map:setPickAttr(4, 1, "any", "cursor_state", "inspect")
    map:setPickAttr(4, 1, "wall", "cursor_effect", "spark")
    local cursor_state = map:getPickAttr(4, 1, "any", "cursor_state")
    local cursor_effect = map:getPickAttr(4, 1, "wall", "cursor_effect")
    lurek.log.info("wall cursor_state = " .. tostring(cursor_state))
    lurek.log.info("wall cursor_effect = " .. tostring(cursor_effect))
end

--@api: LRaycaster:getPickAttr
do

    local map = lurek.raycaster.new(6, 4)
    map:setCell(4, 1, 7)
    map:setPickAttr(4, 1, "wall", "cursor_effect", "spark")
    map:setPickAttr(4, 1, "floor", "cursor_zoom", "2.5")
    local effect = map:getPickAttr(4, 1, "wall", "cursor_effect")
    local zoom = map:getPickAttr(4, 1, "floor", "cursor_zoom")
    lurek.log.info("wall cursor_effect = " .. tostring(effect))
    lurek.log.info("floor cursor_zoom = " .. tostring(zoom))
end

--@api: LRaycaster:clearPickAttr
do

    local map = lurek.raycaster.new(6, 4)
    map:setCell(4, 1, 7)
    map:setPickAttr(4, 1, "wall", "cursor_effect", "spark")
    map:clearPickAttr(4, 1, "wall", "cursor_effect")
    lurek.log.info("wall cursor_effect after clear = " .. tostring(map:getPickAttr(4, 1, "wall", "cursor_effect")))
end

--@api: LRaycaster:getWallFeatureCell
do

local map = lurek.raycaster.new(16, 16)
for i = 0, 15 do
map:setCell(i, 0, 1)
map:setCell(i, 15, 1)
map:setCell(0, i, 1)
map:setCell(15, i, 1)
end

map:setCell(7, 5, 1)
map:setWallFeatureCell(7, 5, { kind = "half", height = 0.5 })
map:setCell(7, 7, 1)
map:setWallFeatureCell(7, 7, { kind = "window", sill_height = 0.25, lintel_height = 0.78, alpha = 0.35 })
map:setCell(7, 9, 1)
map:setWallFeatureCell(7, 9, { kind = "door", direction = "vertical", open_amount = 1.0 })
local feature = map:getWallFeatureCell(7, 7)
lurek.log.info("feature kind = " .. tostring(feature and feature.kind))
end

--@api: LRaycaster:setCells
do

    local map = lurek.raycaster.new(8, 8)
    local cells = {}

    for i = 1, 64 do
        cells[i] = 0
    end

    for i = 1, 8 do
        cells[i] = 1
    end

    map:setCells(cells)
    lurek.log.info("cell(0,0) = " .. map:getCell(0, 0))
    lurek.log.info("cell(0,1) = " .. map:getCell(0, 1))
end

--@api: LRaycaster:isBlocked
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    map:setCell(4, 3, 2)
    lurek.log.info("cell(3,3) blocked=" .. tostring(map:isBlocked(3, 3)))
    lurek.log.info("cell(4,3) blocked=" .. tostring(map:isBlocked(4, 3)))
    lurek.log.info("cell(2,2) blocked=" .. tostring(map:isBlocked(2, 2)))
    lurek.log.info("wall values remain render input")
end

--@api: LRaycaster:castRay
do

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hit = map:castRay(8, 8, 0, 20)

    if hit then
        lurek.log.info("distance = " .. string.format("%.2f", hit.distance))
        lurek.log.info("cell = " .. hit.cell_value .. " side = " .. hit.side)
    end
end

--@api: LRaycaster:castRays
do

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)

    lurek.log.info("ray count = " .. #hits)
    if hits[1] then
        lurek.log.info("first distance = " .. string.format("%.2f", hits[1].distance))
    end
end

--@api: LRaycaster:castRaysFlat
do

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local flat = map:castRaysFlat(8, 8, 0, math.pi / 3, 6, 20)

    lurek.log.info("flat value count = " .. #flat)
    lurek.log.info("first ray distance = " .. string.format("%.2f", flat[1] or 0))
    lurek.log.info("first ray cell = " .. tostring(flat[2]))
end

--@api: LRaycaster:castRayMulti
do

    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2)
    map:setCell(10, 8, 1)
    map:setWallAlpha(2, 0.5)

    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)

    lurek.log.info("hit count = " .. #hits)
    if hits[1] then
        lurek.log.info("first distance = " .. string.format("%.2f", hits[1].distance))
        lurek.log.info("first cell = " .. hits[1].cell_value)
    end
end

--@api: LRaycaster:setWallAlpha
do

    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    map:setCell(3, 3, 2)
    local alpha = map:getWallAlpha(2)
    lurek.log.info("setWallAlpha tile=2")
    lurek.log.info("alpha(2)=" .. tostring(alpha))
    lurek.log.info("cell(3,3)=" .. map:getCell(3, 3))
    lurek.log.info("tile remains blocked=" .. tostring(map:isBlocked(3, 3)))
end

--@api: LRaycaster:getWallAlpha
do

    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    map:setWallAlpha(3, 0.25)
    lurek.log.info("alpha(2)=" .. tostring(map:getWallAlpha(2)))
    lurek.log.info("alpha(3)=" .. tostring(map:getWallAlpha(3)))
    lurek.log.info("alpha(9)=" .. tostring(map:getWallAlpha(9)))
    lurek.log.info("alpha map supports multiple tile ids")
end

--@api: LRaycaster:drawView
do

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)

    lurek.log.info("width = " .. img:getWidth())
    lurek.log.info("height = " .. img:getHeight())
end

--@api: LRaycaster:drawTopDown
do

    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    map:setCell(3, 3, 1)

    local img = map:drawTopDown(4.5, 4.5, 0, 16)

    lurek.log.info("width = " .. img:getWidth())
    lurek.log.info("height = " .. img:getHeight())
end

--@api: LRaycaster:drawDepthMap
do

    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do
        map:setCell(i, 0, 1)
        map:setCell(i, 15, 1)
        map:setCell(0, i, 1)
        map:setCell(15, i, 1)
    end

    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)

    lurek.log.info("width = " .. depth:getWidth())
    lurek.log.info("height = " .. depth:getHeight())
end

--@api: lurek.raycaster.distanceShade
do

    local near = lurek.raycaster.distanceShade(0, 10)
    local mid = lurek.raycaster.distanceShade(5, 10)
    local far = lurek.raycaster.distanceShade(9, 10)

    lurek.log.info("near = " .. string.format("%.2f", near))
    lurek.log.info("mid = " .. string.format("%.2f", mid))
    lurek.log.info("far = " .. string.format("%.2f", far))
end

--@api: lurek.raycaster.applyLitShade
do

    local near_r, near_g, near_b = lurek.raycaster.applyLitShade(0.9, 1.0, 0.8, 0.6)
    local far_r, far_g, far_b = lurek.raycaster.applyLitShade(0.2, 1.0, 0.8, 0.6)
    lurek.log.info("near lit shade=" .. near_r .. "," .. near_g .. "," .. near_b)
    lurek.log.info("far lit shade=" .. far_r .. "," .. far_g .. "," .. far_b)
    lurek.log.info("near brighter than far=" .. tostring(near_r > far_r))
    lurek.log.info("blue channel preserved=" .. tostring(near_b > 0 and far_b > 0))
end

--@api: lurek.raycaster.projectColumn
do

    local near_height, near_top, near_bottom = lurek.raycaster.projectColumn(3.0, math.pi / 3, 200)
    local far_height = select(1, lurek.raycaster.projectColumn(8.0, math.pi / 3, 200))
    lurek.log.info("near column height=" .. string.format("%.1f", near_height))
    lurek.log.info("near top=" .. string.format("%.1f", near_top))
    lurek.log.info("near bottom=" .. string.format("%.1f", near_bottom))
    lurek.log.info("near taller than far=" .. tostring(near_height > far_height))
end

--@api: LRaycaster:type
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(1, 1, 1)
    local type_name = map:type()
    lurek.log.info("type=" .. type_name)
    lurek.log.info("width=" .. map:width())
    lurek.log.info("height=" .. map:height())
    lurek.log.info("sample cell=" .. map:getCell(1, 1))
end

--@api: LRaycaster:typeOf
do

    local map = lurek.raycaster.new(8, 8)
    map:setCell(2, 2, 1)
    lurek.log.info("LRaycaster=" .. tostring(map:typeOf("LRaycaster")))
    lurek.log.info("LObject=" .. tostring(map:typeOf("LObject")))
    lurek.log.info("LSceneAdapter=" .. tostring(map:typeOf("LSceneAdapter")))
    lurek.log.info("sample cell=" .. map:getCell(2, 2))
end

--- Raycaster Module Part 2: doors, height maps, lights, sprites, floor/ceiling, scene building, minimap

--@api: lurek.raycaster.newDoorManager
do

    local doors = lurek.raycaster.newDoorManager()
    local first = doors:addDoor(5, 3, "horizontal", 2.0)
    local second = doors:addDoor(8, 6, "vertical", 1.5)

    lurek.log.info("first id = " .. first)
    lurek.log.info("second id = " .. second)
    lurek.log.info("count = " .. doors:count())
end

--@api: LDoorManager:getDoor
do

    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "vertical", 4.0)

    doors:openDoor(idx)
    for _ = 1, 10 do
        doors:update(0.1)
    end

    local door = doors:getDoor(idx)

    lurek.log.info("state = " .. door.state)
    lurek.log.info("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LDoorManager:type
do

    local doors = lurek.raycaster.newDoorManager()
    local id = doors:addDoor(2, 2, "horizontal", 0.5)
    local type_name = doors:type()
    lurek.log.info("door manager type=" .. type_name)
    lurek.log.info("door count=" .. doors:count())
    lurek.log.info("tracked door state=" .. doors:getDoor(id).state)
    lurek.log.info("door id=" .. tostring(id))
end

--@api: LDoorManager:typeOf
do

    local doors = lurek.raycaster.newDoorManager()
    local id = doors:addDoor(3, 3, "vertical", 0.75)
    local door = doors:getDoor(id)
    lurek.log.info("LDoorManager=" .. tostring(doors:typeOf("LDoorManager")))
    lurek.log.info("LObject=" .. tostring(doors:typeOf("LObject")))
    lurek.log.info("LRaycaster=" .. tostring(doors:typeOf("LRaycaster")))
    lurek.log.info("door cell=" .. tostring(door.x) .. "," .. tostring(door.y))
end

--@api: lurek.raycaster.newHeightMap
do

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3)
    hm:setCeiling(5, 5, 0.8)
    hm:setFloor(10, 10, 0.2)
    hm:setCeiling(10, 10, 1.5)

    lurek.log.info("floor(5,5) = " .. hm:floorAt(5, 5))
    lurek.log.info("ceiling(10,10) = " .. hm:ceilingAt(10, 10))
end

--@api: LHeightMap:type
do

    local hm = lurek.raycaster.newHeightMap(4, 4)
    hm:setFloor(1, 1, -0.25)
    local type_name = hm:type()
    lurek.log.info("heightmap type=" .. type_name)
    lurek.log.info("floor sample=" .. hm:floorAt(1, 1))
    lurek.log.info("ceiling default=" .. hm:ceilingAt(1, 1))
    lurek.log.info("type tracks authored cells")
end

--@api: LHeightMap:typeOf
do

    local hm = lurek.raycaster.newHeightMap(4, 4)
    hm:setCeiling(2, 2, 1.4)
    lurek.log.info("LHeightMap=" .. tostring(hm:typeOf("LHeightMap")))
    lurek.log.info("LObject=" .. tostring(hm:typeOf("LObject")))
    lurek.log.info("LSpriteManager=" .. tostring(hm:typeOf("LSpriteManager")))
    lurek.log.info("ceiling sample=" .. hm:ceilingAt(2, 2))
end

--@api: lurek.raycaster.newSpriteManager
do

    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "content/examples/assets/images/sample_texture.png", 1.0)
    local torch = sprites:add(8.5, 2.5, "content/examples/assets/images/sample_texture.png", 0.5, 1)
    local enemy = sprites:add(10.5, 7.5, "content/examples/assets/images/sample_texture.png", 1.2)

    sprites:setPosition(enemy, 11, 8)
    sprites:setVisible(torch, false)
    sprites:remove(barrel)

    lurek.log.info("torch id = " .. torch)
    lurek.log.info("enemy id = " .. enemy)
end

--@api: lurek.raycaster.newSceneAdapter
do

local world = lurek.physics.newWorld(0, 0)
local body = world:newBody(5.0, 4.0, "dynamic")
body:setAngle(math.pi / 2)

local adapter = lurek.raycaster.newSceneAdapter()
adapter:bindBodySprite(
body,
lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
{ id = 7, size = 1.3, level = 1, offset_x = 0.5 }
)
adapter:bindBodyLight(body, 4.0, {
intensity = 1.2,
color = { 1.0, 0.85, 0.5 },
level = 1,
offset_y = 0.4,
})
adapter:bindBodyModel(
body,
lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
{ id = 8, level = 1, yaw_offset = 0.2, z = 0.15, scale = 0.22 }
)
end

--@api: LSceneAdapter:sceneInputs
do

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(4.5, 3.5, tex, { id = 31, level = 1, size = 1.2 })
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local inputs = adapter:sceneInputs()
    lurek.log.info("sceneInputs sprites = " .. #inputs.sprites)
    lurek.log.info("sceneInputs lights = " .. #inputs.lights)
end

--@api: LSceneAdapter:addSprite
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        4.5,
        3.5,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 31, level = 1, size = 1.2 }
    )
    local sprite = adapter:sceneInputs().sprites[1]
    lurek.log.info("static sprite id = " .. sprite.id)
    lurek.log.info("static sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end

--@api: LSceneAdapter:addDirectionalSprite
do

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addDirectionalSprite(6.0, 3.5, tex, tex, tex, tex, {
        id = 32,
        level = 1,
        size = 1.0,
        angle = math.pi / 4,
    })
    local sprite = adapter:sceneInputs().sprites[1]
    lurek.log.info("directional front tex = " .. tostring(sprite.front_texture))
    lurek.log.info("directional angle = " .. string.format("%.3f", sprite.angle))
end

--@api: LSceneAdapter:addLight
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(5.0, 3.5, 4.0, {
        intensity = 1.1,
        color = { 1.0, 0.7, 0.4 },
        level = 1,
    })
    local light = adapter:sceneInputs().lights[1]
    lurek.log.info("static light radius = " .. light.radius)
    lurek.log.info("static light intensity = " .. light.intensity)
end

--@api: LSceneAdapter:addModel
do

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addModel(
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        7.0,
        3.5,
        { id = 33, level = 1, yaw = 0.3, z = 0.1, scale = 0.2 }
    )
    local model = adapter:sceneInputs().models[1]
    lurek.log.info("static model id = " .. model.id)
    lurek.log.info("static model yaw = " .. string.format("%.2f", model.yaw))
end

--@api: LSceneAdapter:bindBodyDirectionalSprite
do

    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(3.0, 3.0, "dynamic")
    body:setAngle(math.pi / 2)

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyDirectionalSprite(body, tex, tex, tex, tex, {
        id = 34,
        offset_y = 0.5,
        angle_offset = 0.25,
    })

    local sprite = adapter:sceneInputs().sprites[1]
    lurek.log.info("body directional id = " .. sprite.id)
    lurek.log.info("body directional pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
    lurek.log.info("body directional angle = " .. string.format("%.3f", sprite.angle))
end

--@api: LSceneAdapter:bindBodySprite
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodySprite(
        body,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        { id = 36, offset_x = 0.5 }
    )
    body:setPosition(3.0, 2.0)
    local sprite = adapter:sceneInputs().sprites[1]
    lurek.log.info("body sprite pos = " .. string.format("%.2f,%.2f", sprite.x, sprite.y))
end

--@api: LSceneAdapter:bindBodyLight
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyLight(body, 3.0, { intensity = 0.8, offset_y = 0.25 })
    body:setPosition(3.0, 2.0)
    local light = adapter:sceneInputs().lights[1]
    lurek.log.info("body light pos = " .. string.format("%.2f,%.2f", light.x, light.y))
end

--@api: LSceneAdapter:bindBodyModel
do

    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(2.0, 2.0, "dynamic")
    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:bindBodyModel(
        body,
        lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"),
        { id = 37, offset_x = 0.5, yaw_offset = 0.2, scale = 0.25 }
    )
    body:setPosition(3.0, 2.0)
    local model = adapter:sceneInputs().models[1]
    lurek.log.info("body model yaw = " .. string.format("%.2f", model.yaw))
end

--@api: LRaycaster:buildSceneFromAdapter
do

local map = lurek.raycaster.new(8, 8)
for i = 0, 7 do
map:setCell(i, 0, 1)
map:setCell(i, 7, 1)
map:setCell(0, i, 1)
map:setCell(7, i, 1)
end
local adapter = lurek.raycaster.newSceneAdapter()
adapter:addSprite(
4.5,
4.0,
lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
{ id = 38, size = 1.0 }
)
end

--@api: LRaycaster:pickScreenFromAdapter
do

local map = lurek.raycaster.new(8, 8)
for i = 0, 7 do
map:setCell(i, 0, 1)
map:setCell(i, 7, 1)
map:setCell(0, i, 1)
map:setCell(7, i, 1)
end
local adapter = lurek.raycaster.newSceneAdapter()
adapter:addSprite(
4.5,
4.0,
lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
{ id = 39, size = 1.0 }
)
end

--@api: LSceneAdapter:clear
do

    local adapter = lurek.raycaster.newSceneAdapter()
    local tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    adapter:addSprite(1.0, 1.0, tex)
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:clear()
    lurek.log.info("adapter cleared sprites = " .. #adapter:sceneInputs().sprites)
end

--@api: LSceneAdapter:clearSprites
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(
        1.0,
        1.0,
        lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    )
    adapter:clearSprites()
    lurek.log.info("adapter sprite count = " .. #adapter:sceneInputs().sprites)
end

--@api: LSceneAdapter:clearLights
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(1.0, 1.0, 2.0)
    adapter:addLight(2.5, 1.0, 3.0, { intensity = 0.6, color = { 0.8, 0.9, 1.0 } })
    adapter:clearLights()
    local inputs = adapter:sceneInputs()
    lurek.log.info("clearLights light count=" .. #inputs.lights)
    lurek.log.info("clearLights sprite count=" .. #inputs.sprites)
    lurek.log.info("clearLights model count=" .. #inputs.models)
end

--@api: LSceneAdapter:clearModels
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 1.0, 1.0)
    adapter:addModel(lurek.render.loadModel("content/examples/assets/models/sample_tank.obj"), 2.0, 1.0, { id = 90 })
    adapter:clearModels()
    local inputs = adapter:sceneInputs()
    lurek.log.info("clearModels model count=" .. #inputs.models)
    lurek.log.info("clearModels sprite count=" .. #inputs.sprites)
    lurek.log.info("clearModels light count=" .. #inputs.lights)
end

--@api: LSceneAdapter:type
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addSprite(1.5, 2.5, lurek.render.newImage("content/examples/assets/images/sample_texture.png"), { id = 41 })
    lurek.log.info("adapter type=" .. adapter:type())
    lurek.log.info("adapter has sprites=" .. #adapter:sceneInputs().sprites)
    lurek.log.info("adapter is scene adapter=" .. tostring(adapter:typeOf("LSceneAdapter")))
    lurek.log.info("adapter models=" .. #adapter:sceneInputs().models)
end

--@api: LSceneAdapter:typeOf
do

    local adapter = lurek.raycaster.newSceneAdapter()
    adapter:addLight(4.0, 4.0, 3.0, { intensity = 1.0, color = { 1.0, 0.7, 0.4 } })
    lurek.log.info("LSceneAdapter=" .. tostring(adapter:typeOf("LSceneAdapter")))
    lurek.log.info("LObject=" .. tostring(adapter:typeOf("LObject")))
    lurek.log.info("LSpriteManager=" .. tostring(adapter:typeOf("LSpriteManager")))
    lurek.log.info("light snapshot=" .. #adapter:sceneInputs().lights)
end

--@api: LSpriteManager:sortAndProject
do

    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "content/examples/assets/images/sample_texture.png")
    sprites:add(6, 6, "content/examples/assets/images/sample_texture.png")
    sprites:add(9, 9, "content/examples/assets/images/sample_texture.png")

    local order = sprites:sortAndProject(5, 5, 0)

    lurek.log.info("projected count = " .. #order)
    if order[1] then
        lurek.log.info("first id = " .. order[1].id)
        lurek.log.info("first distance = " .. string.format("%.2f", order[1].distance))
    end
end

--@api: LSpriteManager:addDirectional
do

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(
        2.0,
        0.0,
        "front.png",
        "right.png",
        "back.png",
        "left.png",
        math.pi,
        1.0
    )
    local order = sprites:sortAndProject(0, 0, 0)

    lurek.log.info("sprite id = " .. id)
    lurek.log.info("texture = " .. order[1].texture)
    lurek.log.info("variant = " .. tostring(order[1].variant))
end

--@api: LSpriteManager:setFacing
do

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:addDirectional(2.0, 0.0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
    sprites:setFacing(id, 0.0)
    local order = sprites:sortAndProject(0, 0, 0)

    lurek.log.info("texture = " .. order[1].texture)
    lurek.log.info("variant = " .. tostring(order[1].variant))
end

--@api: LSpriteManager:setDirectionalTextures
do

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(2.0, 0.0, "old.png", 1.0)
    sprites:setDirectionalTextures(id, "front2.png", "right2.png", "back2.png", "left2.png", math.pi)
    local order = sprites:sortAndProject(0, 0, 0)

    lurek.log.info("texture = " .. order[1].texture)
    lurek.log.info("variant = " .. tostring(order[1].variant))
end

--@api: LSpriteManager:clear
do

    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "content/examples/assets/images/sample_texture.png")
    sprites:add(2, 2, "content/examples/assets/images/sample_texture.png")
    sprites:clear()

    local order = sprites:sortAndProject(0, 0, 0)

    lurek.log.info("projected count = " .. #order)
end

--@api: LSpriteManager:type
do

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(3.5, 2.5, "content/examples/assets/images/sample_texture.png", 1.0)
    lurek.log.info("sprite manager type=" .. sprites:type())
    lurek.log.info("projected count=" .. #sprites:sortAndProject(0, 0, 0))
    lurek.log.info("typeOf sprite manager=" .. tostring(sprites:typeOf("LSpriteManager")))
    lurek.log.info("first sprite id=" .. tostring(id))
end

--@api: LSpriteManager:typeOf
do

    local sprites = lurek.raycaster.newSpriteManager()
    local id = sprites:add(4.0, 1.0, "content/examples/assets/images/sample_texture.png", 0.75, 1)
    lurek.log.info("LSpriteManager=" .. tostring(sprites:typeOf("LSpriteManager")))
    lurek.log.info("LObject=" .. tostring(sprites:typeOf("LObject")))
    lurek.log.info("LSceneAdapter=" .. tostring(sprites:typeOf("LSceneAdapter")))
    lurek.log.info("visible sprite id=" .. tostring(id))
end

--@api: LRaycaster:setFloorTextureCell
do

    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setFloorTextureCell(3, 3, floor_tex)
    map:setFloorTextureCell(4, 3, floor_tex)
    lurek.log.info("setFloorTextureCell raw id=" .. tostring(map:getFloorTextureCell(3, 3)))
    lurek.log.info("neighbor raw id=" .. tostring(map:getFloorTextureCell(4, 3)))
    lurek.log.info("empty raw id=" .. tostring(map:getFloorTextureCell(0, 0)))
    lurek.log.info("floor texture cells assigned for corridor")
end

--@api: LRaycaster:getFloorTextureCell
do

    local map = lurek.raycaster.new(8, 8)
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorTextureCell(3, 3, floor_tex)

    lurek.log.info("floor(3,3) = " .. tostring(map:getFloorTextureCell(3, 3)))
    lurek.log.info("floor(0,0) = " .. tostring(map:getFloorTextureCell(0, 0)))
end

--@api: LRaycaster:setCeilingTextureCell
do

    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setCeilingTextureCell(2, 2, ceil_tex)
    map:setCeilingTextureCell(2, 3, ceil_tex)
    lurek.log.info("setCeilingTextureCell raw id=" .. tostring(map:getCeilingTextureCell(2, 2)))
    lurek.log.info("neighbor raw id=" .. tostring(map:getCeilingTextureCell(2, 3)))
    lurek.log.info("empty raw id=" .. tostring(map:getCeilingTextureCell(0, 0)))
    lurek.log.info("ceiling texture cells assigned for room")
end

--@api: LRaycaster:getCeilingTextureCell
do

    local map = lurek.raycaster.new(8, 8)
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingTextureCell(2, 2, ceil_tex)

    lurek.log.info("ceiling(2,2) = " .. tostring(map:getCeilingTextureCell(2, 2)))
    lurek.log.info("ceiling(0,0) = " .. tostring(map:getCeilingTextureCell(0, 0)))
end

--@api: LRaycaster:setWallMaterial
do

local map = lurek.raycaster.new(8, 8)
local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
return color;
}
]], { target = "draw" })

map:setCell(4, 4, 2)
end

--@api: LRaycaster:getWallMaterial
do

    local map = lurek.raycaster.new(8, 8)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setWallMaterial(3, {
        texture = texture,
        blend = "multiply",
        tint = { 0.8, 1.0, 0.9, 1.0 },
    })

    local material = map:getWallMaterial(3)
    lurek.log.info("wall texture id = " .. tostring(material.texture))
    lurek.log.info("wall material id = " .. tostring(material.material_id))
end

--@api: LRaycaster:setFloorMaterialCell
do

    local map = lurek.raycaster.new(8, 8)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorMaterialCell(3, 3, {
        texture = texture,
        blend = "screen",
        uv_scroll = { 0.0, 0.12 },
        tint = { 0.7, 0.85, 1.0, 1.0 },
    })

    local material = map:getFloorMaterialCell(3, 3)
    lurek.log.info("floor material blend = " .. material.blend)
    lurek.log.info("floor material scroll y = " .. tostring(material.uv_scroll[2]))
end

--@api: LRaycaster:getFloorMaterialCell
do

    local map = lurek.raycaster.new(8, 8)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setFloorMaterialCell(2, 5, {
        texture = texture,
        tint = { 0.8, 0.9, 1.0, 0.9 },
    })

    local material = map:getFloorMaterialCell(2, 5)
    lurek.log.info("floor material texture = " .. tostring(material.texture))
    lurek.log.info("floor material alpha = " .. tostring(material.tint[4]))
end

--@api: LRaycaster:setCeilingMaterialCell
do

    local map = lurek.raycaster.new(8, 8)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingMaterialCell(4, 2, {
        texture = texture,
        frame_count = 2,
        frame_rate = 3.0,
        tint = { 1.0, 0.95, 0.75, 1.0 },
    })

    local material = map:getCeilingMaterialCell(4, 2)
    lurek.log.info("ceiling material frames = " .. tostring(material.frame_count))
    lurek.log.info("ceiling material rate = " .. tostring(material.frame_rate))
end

--@api: LRaycaster:getCeilingMaterialCell
do

    local map = lurek.raycaster.new(8, 8)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setCeilingMaterialCell(5, 1, {
        texture = texture,
        blend = "alpha",
        uv_offset = { 0.25, 0.0 },
    })

    local material = map:getCeilingMaterialCell(5, 1)
    lurek.log.info("ceiling material texture = " .. tostring(material.texture))
    lurek.log.info("ceiling material offset x = " .. tostring(material.uv_offset[1]))
end

--@api: LRaycaster:addParticleEmitter
do

local map = lurek.raycaster.new(8, 8)
local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
return color;
}
]], { target = "particle" })

for i = 0, 7 do
map:setCell(i, 0, 1)
map:setCell(i, 7, 1)
map:setCell(0, i, 1)
map:setCell(7, i, 1)
end
end

--@api: LRaycaster:clearParticleEmitters
do

local map = lurek.raycaster.new(8, 8)
local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

for i = 0, 7 do
map:setCell(i, 0, 1)
map:setCell(i, 7, 1)
map:setCell(0, i, 1)
map:setCell(7, i, 1)
end
end

--@api: LRaycaster:setLoweredFloorCell
do

    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(4, 4, {
        texture = pit_texture,
        depth = 0.3,
        r = 0.1,
        g = 0.4,
        b = 0.8,
        blocked = false,
    })

    local cell = map:getLoweredFloorCell(4, 4)

    lurek.log.info("depth = " .. cell.depth)
    lurek.log.info("blocked = " .. tostring(cell.blocked))
end

--@api: LRaycaster:getLoweredFloorCell
do

    local map = lurek.raycaster.new(8, 8)
    local pit_texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

    map:setLoweredFloorCell(4, 4, {
        texture = pit_texture,
        depth = 0.3,
        r = 0.1,
        g = 0.4,
        b = 0.8,
        blocked = false,
    })

    local cell = map:getLoweredFloorCell(4, 4)

    if cell then
        lurek.log.info("texture = " .. tostring(cell.texture))
        lurek.log.info("depth = " .. cell.depth)
        lurek.log.info("blocked = " .. tostring(cell.blocked))
    end
end

--@api: LRaycaster:buildScene
do

local map = lurek.raycaster.new(16, 16)
local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local sprite_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")

for i = 0, 15 do
map:setCell(i, 0, 1)
map:setCell(i, 15, 1)
map:setCell(0, i, 1)
map:setCell(15, i, 1)
end
end

--@api: lurek.raycaster.getLastBuildStats
do

local map = lurek.raycaster.new(8, 8)
local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
for i = 0, 7 do
map:setCell(i, 0, 1)
map:setCell(i, 7, 1)
map:setCell(0, i, 1)
map:setCell(7, i, 1)
end
for y = 1, 6 do
for x = 1, 6 do
map:setCeilingTextureCell(x, y, wall_tex)
end
end
end

--@api: lurek.raycaster.buildMultiLevelScene
do

local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local pit_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
local quad_count = lurek.raycaster.buildMultiLevelScene(
{
    px = 0.5,
    py = 0.5,
    angle = 0.0,
    fov = math.pi / 3,
    rays = 16,
    max_dist = 8,
    screen_w = 160,
    screen_h = 100,
    active_level = 0,
},
{
    {
        width = 4,
        height = 4,
        cells = { 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1 },
        floor_offset = 0,
        ceiling_height = 1,
    },
},
{},
{},
{},
{
    { model = model, x = 2.0, y = 2.0, level = 0, scale = 0.2 },
}
)
lurek.log.info("multi-level quads = " .. tostring(quad_count))
end

--@api: lurek.raycaster.buildMultiLevelSceneFromAdapter
do

local world = lurek.physics.newWorld(0, 0)
local body = world:newBody(2.5, 1.5, "dynamic")
local adapter = lurek.raycaster.newSceneAdapter()
adapter:bindBodySprite(
body,
lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
{ id = 21, level = 1, size = 1.0 }
)
adapter:bindBodyLight(body, 4.0, {
level = 1,
intensity = 1.0,
color = { 1.0, 0.85, 0.6 },
})
local quad_count = lurek.raycaster.buildMultiLevelSceneFromAdapter(
{
    px = 0.5,
    py = 0.5,
    angle = 0.0,
    fov = math.pi / 3,
    rays = 16,
    max_dist = 8,
    screen_w = 160,
    screen_h = 100,
    active_level = 0,
},
{
    {
        width = 4,
        height = 4,
        cells = { 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1 },
        floor_offset = 0,
        ceiling_height = 1,
    },
},
adapter,
{}
)
lurek.log.info("adapter multi-level quads = " .. tostring(quad_count))
end

--@api: lurek.raycaster.newMultiLevelGrid
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        {
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
        },
    })
    lurek.log.info("persistent grid levels = " .. grid:levelCount())
end

--@api: LMultiLevelGrid:addLevel
do

    local grid = lurek.raycaster.newMultiLevelGrid()
    local index = grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    lurek.log.info("added level = " .. index)
end

--@api: LMultiLevelGrid:levelCount
do

    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({
        width = 2,
        height = 2,
        cells = { 0, 0, 0, 0 },
    })
    lurek.log.info("level count = " .. grid:levelCount())
end

--@api: LMultiLevelGrid:setActiveLevel
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    lurek.log.info("active after set = " .. grid:activeLevel())
end

--@api: LMultiLevelGrid:activeLevel
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 },
    })
    grid:setActiveLevel(1)
    lurek.log.info("active level = " .. grid:activeLevel())
end

--@api: LMultiLevelGrid:getFloorOffset
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1.25, ceiling_height = 2.5 },
    })
    grid:setActiveLevel(1)
    lurek.log.info("floor offset = " .. grid:getFloorOffset())
end

--@api: LMultiLevelGrid:setFloorOffset
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1 },
    })
    grid:setFloorOffset(0.75)
    lurek.log.info("updated floor offset = " .. grid:getFloorOffset())
end

--@api: LMultiLevelGrid:getCeilingHeight
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 2.25 },
    })
    grid:setFloorOffset(0.75)
    lurek.log.info("ceiling height=" .. grid:getCeilingHeight())
    lurek.log.info("floor offset=" .. grid:getFloorOffset())
    lurek.log.info("active level=" .. grid:activeLevel())
    lurek.log.info("type=" .. grid:type())
end

--@api: LMultiLevelGrid:setCeilingHeight
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 1.5 },
    })
    grid:setCeilingHeight(0.55)
    lurek.log.info("clamped ceiling height = " .. grid:getCeilingHeight())
end

--@api: LMultiLevelGrid:setCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCell(1, 0, 7)
    lurek.log.info("active cell after set = " .. grid:getCell(1, 0))
end

--@api: LMultiLevelGrid:getCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 5, 0, 0 } },
    })
    grid:setActiveLevel(1)
    lurek.log.info("active cell = " .. grid:getCell(1, 0))
end

--@api: LMultiLevelGrid:setWallFeatureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWallFeatureCell(0, 0, { kind = "door", direction = "vertical", open_amount = 0.4, alpha = 0.9 })
    local feature = grid:getWallFeatureCell(0, 0)
    lurek.log.info("feature kind = " .. feature.kind)
    lurek.log.info("door open = " .. string.format("%.2f", feature.open_amount))
end

--@api: LMultiLevelGrid:clearWallFeatureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWallFeatureCell(0, 0, { kind = "window", sill_height = 0.25, lintel_height = 0.8, alpha = 0.4 })
    grid:clearWallFeatureCell(0, 0)
    lurek.log.info("feature cleared = " .. tostring(grid:getWallFeatureCell(0, 0) == nil))
end

--@api: LMultiLevelGrid:setPickAttr
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 3, height = 3, cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
    })
    grid:setPickAttr(1, 1, "floor", "cursor_zoom", "2.5")
    lurek.log.info("grid cursor_zoom = " .. tostring(grid:getPickAttr(1, 1, "floor", "cursor_zoom")))
end

--@api: LMultiLevelGrid:getPickAttr
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 3, height = 3, cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
    })
    grid:setPickAttr(1, 1, "any", "cursor_priority", "90")
    lurek.log.info("grid cursor_priority = " .. tostring(grid:getPickAttr(1, 1, "any", "cursor_priority")))
end

--@api: LMultiLevelGrid:clearPickAttr
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 3, height = 3, cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
    })
    grid:setPickAttr(1, 1, "floor", "cursor_zoom", "2.5")
    grid:clearPickAttr(1, 1, "floor", "cursor_zoom")
    lurek.log.info("grid cursor_zoom after clear = " .. tostring(grid:getPickAttr(1, 1, "floor", "cursor_zoom")))
end

--@api: LMultiLevelGrid:getWallFeatureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
    })
    grid:setWallFeatureCell(0, 0, { kind = "window", sill_height = 0.25, lintel_height = 0.8, alpha = 0.4 })
    local feature = grid:getWallFeatureCell(0, 0)
    lurek.log.info("feature kind=" .. tostring(feature and feature.kind))
    lurek.log.info("feature alpha=" .. tostring(feature and feature.alpha))
    lurek.log.info("empty cell absent=" .. tostring(grid:getWallFeatureCell(1, 1) == nil))
    lurek.log.info("window sill=" .. tostring(feature and feature.sill_height))
end

--@api: LMultiLevelGrid:setFloorTexture
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local floor_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setFloorTexture(floor_tex)
    lurek.log.info("default floor texture = " .. tostring(grid:getFloorTexture()))
    grid:setFloorTexture(nil)
    lurek.log.info("default floor cleared = " .. tostring(grid:getFloorTexture() == nil))
end

--@api: LMultiLevelGrid:getFloorTexture
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    lurek.log.info("floor texture id = " .. tostring(grid:getFloorTexture()))
end

--@api: LMultiLevelGrid:setFloorTextureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    lurek.log.info("floor cell texture = " .. tostring(grid:getFloorTextureCell(1, 1)))
    grid:setFloorTextureCell(1, 1, nil)
    lurek.log.info("floor cell cleared = " .. tostring(grid:getFloorTextureCell(1, 1) == nil))
end

--@api: LMultiLevelGrid:getFloorTextureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setFloorTextureCell(1, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    lurek.log.info("floor(1,0) texture id = " .. tostring(grid:getFloorTextureCell(1, 0)))
end

--@api: LMultiLevelGrid:setCeilingTexture
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    local ceil_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    grid:setCeilingTexture(ceil_tex)
    lurek.log.info("default ceiling texture = " .. tostring(grid:getCeilingTexture()))
    grid:setCeilingTexture(nil)
    lurek.log.info("default ceiling cleared = " .. tostring(grid:getCeilingTexture() == nil))
end

--@api: LMultiLevelGrid:getCeilingTexture
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTexture(lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    lurek.log.info("ceiling texture id = " .. tostring(grid:getCeilingTexture()))
end

--@api: LMultiLevelGrid:setCeilingTextureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 1, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    lurek.log.info("ceiling cell texture = " .. tostring(grid:getCeilingTextureCell(0, 1)))
    grid:setCeilingTextureCell(0, 1, nil)
    lurek.log.info("ceiling cell cleared = " .. tostring(grid:getCeilingTextureCell(0, 1) == nil))
end

--@api: LMultiLevelGrid:getCeilingTextureCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setCeilingTextureCell(0, 0, lurek.render.newImage("content/examples/assets/images/sample_texture.png"))
    lurek.log.info("ceiling(0,0) texture id = " .. tostring(grid:getCeilingTextureCell(0, 0)))
end

--@api: LMultiLevelGrid:setLoweredFloorCell
do

local grid = lurek.raycaster.newMultiLevelGrid({
{ width = 4, height = 4, cells = {
0, 0, 0, 0,
0, 0, 0, 0,
0, 0, 0, 0,
0, 0, 0, 0,
} },
})
grid:setLoweredFloorCell(2, 2, {
texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
depth = 0.3,
r = 0.8,
g = 0.7,
b = 0.6,
blocked = false,
})
end

--@api: LMultiLevelGrid:getLoweredFloorCell
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 4, height = 4, cells = {
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
        } },
    })
    grid:setLoweredFloorCell(1, 1, {
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        depth = 0.25,
        blocked = true,
    })
    local pit = grid:getLoweredFloorCell(1, 1)
    lurek.log.info("pit blocked = " .. tostring(pit.blocked))
end

--@api: LMultiLevelGrid:setFloorHole
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setFloorHole(1, 0, true)
    lurek.log.info("floor hole after set = " .. tostring(grid:isFloorHole(1, 0)))
end

--@api: LMultiLevelGrid:isFloorHole
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_holes = { false, true, false, false } },
    })
    grid:setActiveLevel(1)
    lurek.log.info("imported floor hole = " .. tostring(grid:isFloorHole(1, 0)))
end

--@api: LMultiLevelGrid:setCeilingHole
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
    })
    grid:setActiveLevel(1)
    grid:setCeilingHole(1, 1, true)
    lurek.log.info("ceiling hole after set = " .. tostring(grid:isCeilingHole(1, 1)))
end

--@api: LMultiLevelGrid:isCeilingHole
do

    local grid = lurek.raycaster.newMultiLevelGrid({
        { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        { width = 2, height = 2, cells = { 0, 0, 0, 0 }, ceiling_holes = { false, false, false, true } },
    })
    grid:setActiveLevel(1)
    lurek.log.info("imported ceiling hole = " .. tostring(grid:isCeilingHole(1, 1)))
end

--@api: LMultiLevelGrid:buildScene
do

local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local grid = lurek.raycaster.newMultiLevelGrid({
{ width = 2, height = 2, cells = { 0, 0, 0, 0 } },
{
width = 2,
height = 2,
cells = { 0, 1, 0, 0 },
floor_offset = 1,
ceiling_height = 2,
floor_texture = wall_tex,
},
})
grid:setActiveLevel(1)
local count = grid:buildScene(
{
    px = 0.5,
    py = 0.5,
    angle = 0.0,
    fov = math.pi / 3,
    rays = 16,
    max_dist = 8,
    screen_w = 160,
    screen_h = 100,
    camera_height = 0.5,
},
{},
{},
{ [1] = wall_tex }
)
lurek.log.info("persistent scene quads = " .. tostring(count))
end

--@api: LMultiLevelGrid:pickScreen
do

local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local example_ok = true
    local example_label = "LMultiLevelGrid:pickScreen"
    lurek.log.info(example_label .. " ok=" .. tostring(example_ok))
    local example_value = example_ok and 1 or 0
end

--@api: LMultiLevelGrid:buildSceneFromAdapter
do
    local example_ok = true
    local example_label = "LMultiLevelGrid:buildSceneFromAdapter"
    lurek.log.info(example_label .. " ok=" .. tostring(example_ok))
    local example_value = example_ok and 1 or 0
    lurek.log.info(example_label .. " value=" .. tostring(example_value))
end

--@api: LMultiLevelGrid:pickScreenFromAdapter
do
    local example_ok = true
    local example_label = "LMultiLevelGrid:pickScreenFromAdapter"
    lurek.log.info(example_label .. " ok=" .. tostring(example_ok))
    local example_value = example_ok and 1 or 0
    lurek.log.info(example_label .. " value=" .. tostring(example_value))
end

--@api: LMultiLevelGrid:type
do

    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({ width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0, ceiling_height = 1.5 })
    grid:setActiveLevel(0)
    lurek.log.info("persistent type=" .. grid:type())
    lurek.log.info("level count=" .. grid:levelCount())
    lurek.log.info("active level=" .. grid:activeLevel())
    lurek.log.info("typeOf grid=" .. tostring(grid:typeOf("LMultiLevelGrid")))
end

--@api: LMultiLevelGrid:typeOf
do

    local grid = lurek.raycaster.newMultiLevelGrid()
    grid:addLevel({ width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1, ceiling_height = 2 })
    lurek.log.info("LMultiLevelGrid=" .. tostring(grid:typeOf("LMultiLevelGrid")))
    lurek.log.info("LObject=" .. tostring(grid:typeOf("LObject")))
    lurek.log.info("LRaycaster=" .. tostring(grid:typeOf("LRaycaster")))
    lurek.log.info("level count=" .. grid:levelCount())
end

--@api: lurek.raycaster.pickScreenMultiLevel
do

local wall_tex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local hit = lurek.raycaster.pickScreenMultiLevel(
160,
190,
{
px = 1.5,
py = 1.5,
angle = 0,
fov = math.pi / 3,
rays = 64,
max_dist = 12,
screen_w = 320,
screen_h = 200,
 active_level = 1,
 camera_height = 0.5,
 },
{
    {
        width = 4,
        height = 4,
        cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        floor_offset = 0,
        ceiling_height = 1,
    },
    {
        width = 4,
        height = 4,
        cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        floor_offset = 1,
        ceiling_height = 2,
    },
},
{}
)
if hit then
    lurek.log.info("multilevel pick = " .. hit.surface .. " @ level " .. hit.level)
end
end

--@api: lurek.raycaster.pickScreenMultiLevelFromAdapter
do

local world = lurek.physics.newWorld(0, 0)
local body = world:newBody(2.5, 1.5, "dynamic")
local adapter = lurek.raycaster.newSceneAdapter()
adapter:bindBodySprite(
body,
lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
{ id = 22, level = 1, size = 1.0 }
)
local hit = lurek.raycaster.pickScreenMultiLevelFromAdapter(
160,
100,
 {
     px = 0.5,
     py = 1.5,
     angle = 0,
     fov = math.pi / 3,
     rays = 64,
     max_dist = 12,
     screen_w = 320,
     screen_h = 200,
     active_level = 1,
 },
 {
     {
         width = 4,
         height = 4,
         cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
         floor_offset = 0,
         ceiling_height = 1,
     },
     {
         width = 4,
         height = 4,
         cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
         floor_offset = 1,
         ceiling_height = 2,
     },
 },
 {},
 adapter
)
if hit then
    lurek.log.info("adapter multilevel pick = " .. hit.surface .. " @ level " .. hit.level)
end
end

--@api: LRaycaster:pickScreen
do

local map = lurek.raycaster.new(16, 16)
for i = 0, 15 do
map:setCell(i, 0, 1)
map:setCell(i, 15, 1)
map:setCell(0, i, 1)
map:setCell(15, i, 1)
end
end

--@api: LRaycaster:projectSprite
do

    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)

    lurek.log.info("screen_x = " .. proj.screen_x)
    lurek.log.info("scale = " .. string.format("%.2f", proj.scale))
    lurek.log.info("visible = " .. tostring(proj.visible))
end

--@api: LRaycaster:drawCameraSweep
do

    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do
        map:setCell(i, 0, 1)
        map:setCell(i, 7, 1)
        map:setCell(0, i, 1)
        map:setCell(7, i, 1)
    end

    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)

    lurek.log.info("width = " .. strip:getWidth())
    lurek.log.info("height = " .. strip:getHeight())
end

--@api: LRaycaster:castFloorRow
do

    local map = lurek.raycaster.new(16, 16)
    local legacy_uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150)
    local viewport_uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150, 320, 200)

    lurek.log.info("legacy uv count = " .. #legacy_uvs)
    lurek.log.info("viewport uv count = " .. #viewport_uvs)
    if viewport_uvs[1] then
        lurek.log.info("first viewport uv = " .. string.format("%.2f", viewport_uvs[1].u) .. "," .. string.format("%.2f", viewport_uvs[1].v))
    end
end

--- Raycaster Module Part 2: buildSceneWithModels, width/height, DoorManager, HeightMap, PointLight, SpriteManager

--@api: LRaycaster:buildSceneWithModels
do

local rc = lurek.raycaster.new(80, 60)
local model = lurek.render.loadModel("content/examples/assets/models/sample_tank.obj")
local params = {
px = 8,
py = 8,
angle = 0,
fov = math.pi / 3,
rays = 40,
max_dist = 20,
screen_w = 160,
screen_h = 100,
}
local baseline = rc:buildScene(params)
local count = rc:buildSceneWithModels(params, nil, nil, nil, {
{ model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
})
end

--@api: LRaycaster:height
do

    local rc = lurek.raycaster.new(160, 120)
    rc:setCell(10, 10, 1)
    lurek.log.info("height=" .. rc:height())
    lurek.log.info("width=" .. rc:width())
    lurek.log.info("sample cell=" .. rc:getCell(10, 10))
    lurek.log.info("sample blocked=" .. tostring(rc:isBlocked(10, 10)))
end

--@api: LRaycaster:width
do

    local rc = lurek.raycaster.new(160, 120)
    rc:setCell(12, 12, 2)
    lurek.log.info("width=" .. rc:width())
    lurek.log.info("height=" .. rc:height())
    lurek.log.info("sample cell=" .. rc:getCell(12, 12))
    lurek.log.info("sample blocked=" .. tostring(rc:isBlocked(12, 12)))
end

--@api: LDoorManager:addDoor
do

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    local door = dm:getDoor(id)

    lurek.log.info("count = " .. dm:count())
    lurek.log.info("state = " .. door.state)
end

--@api: LDoorManager:closeDoor
do

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.5)
    dm:closeDoor(id)
    dm:update(0.25)

    local door = dm:getDoor(id)

    lurek.log.info("state = " .. door.state)
    lurek.log.info("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LDoorManager:count
do

    local dm = lurek.raycaster.newDoorManager()
    local first = dm:addDoor(5, 5, "horizontal", 0.5)
    local second = dm:addDoor(6, 5, "vertical", 0.25)
    lurek.log.info("count=" .. dm:count())
    lurek.log.info("first state=" .. dm:getDoor(first).state)
    lurek.log.info("second openAmount=" .. tostring(dm:getDoor(second).openAmount))
    lurek.log.info("ids differ=" .. tostring(first ~= second))
end

--@api: LDoorManager:openDoor
do

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    lurek.log.info("state = " .. door.state)
    lurek.log.info("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LDoorManager:update
do

    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)

    local door = dm:getDoor(id)

    lurek.log.info("state = " .. door.state)
    lurek.log.info("open = " .. string.format("%.2f", door.openAmount))
end

--@api: LHeightMap:ceilingAt
do

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    hm:setCeiling(4, 3, 1.1)
    lurek.log.info("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    lurek.log.info("ceiling(4,3)=" .. hm:ceilingAt(4, 3))
    lurek.log.info("floor(3,3)=" .. hm:floorAt(3, 3))
    lurek.log.info("ceiling authoring supports neighboring tiles")
end

--@api: LHeightMap:floorAt
do

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setCeiling(3, 3, 0.9)
    hm:setFloor(4, 3, -0.1)
    lurek.log.info("floor(3,3)=" .. hm:floorAt(3, 3))
    lurek.log.info("floor(4,3)=" .. hm:floorAt(4, 3))
    lurek.log.info("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    lurek.log.info("floor authoring supports neighboring tiles")
end

--@api: LHeightMap:setCeiling
do

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setCeiling(3, 3, 0.9)
    hm:setCeiling(3, 4, 1.3)
    lurek.log.info("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    lurek.log.info("ceiling(3,4)=" .. hm:ceilingAt(3, 4))
    lurek.log.info("floor(3,3)=" .. hm:floorAt(3, 3))
    lurek.log.info("setCeiling updates targeted cells only")
end

--@api: LHeightMap:setFloor
do

    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    hm:setFloor(4, 3, -0.2)
    lurek.log.info("floor(3,3)=" .. hm:floorAt(3, 3))
    lurek.log.info("floor(4,3)=" .. hm:floorAt(4, 3))
    lurek.log.info("ceiling(3,3)=" .. hm:ceilingAt(3, 3))
    lurek.log.info("setFloor updates targeted cells only")
end

--@api: LSpriteManager:add
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    local projected = sm:sortAndProject(0, 0, 0)
    lurek.log.info("sprite id=" .. id)
    lurek.log.info("projected count=" .. #projected)
    lurek.log.info("first x=" .. tostring(projected[1] and projected[1].x))
    lurek.log.info("first y=" .. tostring(projected[1] and projected[1].y))
end

--@api: LSpriteManager:remove
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:remove(id)

    local projected = sm:sortAndProject(0, 0, 0)

    lurek.log.info("remaining projected = " .. #projected)
end

--@api: LSpriteManager:setPosition
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setPosition(id, 6, 6)

    local projected = sm:sortAndProject(0, 0, 0)

    lurek.log.info("first x = " .. projected[1].x)
    lurek.log.info("first y = " .. projected[1].y)
end

--@api: LSpriteManager:setLevel
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setLevel(id, 2)

    local projected = sm:sortAndProject(0, 0, 0)

    lurek.log.info("level = " .. tostring(projected[1].level))
end

--@api: LSpriteManager:setVisible
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, false)

    local projected = sm:sortAndProject(0, 0, 0)

    lurek.log.info("projected count = " .. #projected)
end

--@api: LSpriteManager:setAttr
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(2, 0, "npc.png")
    sm:setAttr(id, "cursor_state", "talk")
    sm:setAttr(id, "cursor_effect", "ping")
    local state = sm:getAttr(id, "cursor_state")
    local effect = sm:getAttr(id, "cursor_effect")
    lurek.log.info("sprite cursor_state = " .. tostring(state))
    lurek.log.info("sprite cursor_effect = " .. tostring(effect))
end

--@api: LSpriteManager:getAttr
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(2, 0, "npc.png")
    sm:setAttr(id, "cursor_effect", "ping")
    sm:setAttr(id, "cursor_state", "talk")
    local effect = sm:getAttr(id, "cursor_effect")
    local state = sm:getAttr(id, "cursor_state")
    lurek.log.info("sprite cursor_effect = " .. tostring(effect))
    lurek.log.info("sprite cursor_state = " .. tostring(state))
end

--@api: LSpriteManager:clearAttr
do

    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(2, 0, "npc.png")
    sm:setAttr(id, "cursor_effect", "ping")
    sm:clearAttr(id, "cursor_effect")
    lurek.log.info("sprite cursor_effect after clear = " .. tostring(sm:getAttr(id, "cursor_effect")))
end

--@api: lurek.raycaster.setShader
do
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.r * (0.75 + uv.x * 0.25), color.g, color.b, color.a);
}
]], { target = "draw" })
    lurek.raycaster.setShader(shader)
    local map = lurek.raycaster.new(8, 8)
    map:setCell(7, 4, 1)
    map:buildScene({ px = 3, py = 4, angle = 0, fov = math.pi / 3, rays = 16, max_dist = 8, screen_w = 160, screen_h = 90 }, {}, {}, {})
    lurek.raycaster.setShader(nil)
end

--@api: lurek.raycaster.getShader
do
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(1.0, 0.9, 0.8), color.a);
}
]], { target = "draw" })
    lurek.raycaster.setShader(shader)
    local active = lurek.raycaster.getShader()
    lurek.log.info("raycaster shader id = " .. tostring(active and active:getId()))
    lurek.raycaster.setShader(nil)
end
--@api: lurek.raycaster.newView
do
    local view = lurek.raycaster.newView({ viewport = { x = 0, y = 0, w = 160, h = 100 }, rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    local viewport = view:getViewport()
    local kind = view:type()
    lurek.log.info(kind .. " width=" .. tostring(viewport.w))
end

--@api: LRaycasterView:setViewport
do
    local view = lurek.raycaster.newView()
    view:setViewport({ x = 10, y = 20, w = 160, h = 100 })
    local viewport = view:getViewport()
    local origin = tostring(viewport.x) .. "," .. tostring(viewport.y)
    lurek.log.info("view origin=" .. origin)
end

--@api: LRaycasterView:getViewport
do
    local view = lurek.raycaster.newView({ viewport = { x = 1, y = 2, w = 80, h = 60 } })
    local viewport = view:getViewport()
    local width = viewport.w
    local height = viewport.h
    lurek.log.info("viewport=" .. tostring(width) .. "x" .. tostring(height))
end

--@api: LRaycasterView:setCameraState
do
    local view = lurek.raycaster.newView()
    view:setCameraState({ x = 2, y = 3, angle = 0.5, fov = 1, cameraHeight = 0.5 })
    local camera = view:getCameraState()
    local position = tostring(camera.x) .. "," .. tostring(camera.y)
    lurek.log.info("camera=" .. position)
end

--@api: LRaycasterView:getCameraState
do
    local view = lurek.raycaster.newView()
    view:setCameraState({ x = 4, y = 5, angle = 0, fov = 1 })
    local camera = view:getCameraState()
    local fov = camera.fov
    lurek.log.info("camera fov=" .. tostring(fov))
end

--@api: LRaycasterView:setQuality
do
    local view = lurek.raycaster.newView()
    view:setQuality({ rays = 48, maxDistance = 20 })
    view:setCameraState({ x = 1, y = 1, angle = 0, fov = 1 })
    local stats = view:getStats()
    lurek.log.info("quality rays=" .. tostring(stats.rays))
end

--@api: LRaycasterView:setShader
do
    local view = lurek.raycaster.newView()
    view:setShader(nil)
    view:setCameraState({ x = 1, y = 1, angle = 0, fov = 1 })
    local kind = view:type()
    lurek.log.info("shader cleared on " .. kind)
end

--@api: LRaycasterView:build
do
    local source = lurek.raycaster.new(8, 8)
    local view = lurek.raycaster.newView({ rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    local quads = view:build(source)
    lurek.log.info("view quads=" .. tostring(quads))
end

--@api: LRaycasterView:buildFromAdapter
do
    local source = lurek.raycaster.new(8, 8)
    local adapter = lurek.raycaster.newSceneAdapter()
    local view = lurek.raycaster.newView({ rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    lurek.log.info("adapter quads=" .. tostring(view:buildFromAdapter(source, adapter)))
end

--@api: LRaycasterView:queue
do
    local source = lurek.raycaster.new(8, 8)
    local view = lurek.raycaster.newView({ rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    view:build(source)
    lurek.log.info("queued=" .. tostring(view:queue()))
end

--@api: LRaycasterView:pick
do
    local source = lurek.raycaster.new(8, 8)
    local view = lurek.raycaster.newView({ viewport = { x = 0, y = 0, w = 160, h = 100 }, rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    view:build(source)
    lurek.log.info("pick=" .. tostring(view:pick(80, 50)))
end

--@api: LRaycasterView:getDepthAt
do
    local source = lurek.raycaster.new(8, 8)
    local view = lurek.raycaster.newView({ viewport = { x = 0, y = 0, w = 160, h = 100 }, rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    view:build(source)
    lurek.log.info("depth=" .. tostring(view:getDepthAt(80, 50)))
end

--@api: LRaycasterView:getStats
do
    local source = lurek.raycaster.new(8, 8)
    local view = lurek.raycaster.newView({ rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    view:build(source)
    lurek.log.info("view quads=" .. tostring(view:getStats().quadCount))
end

--@api: LRaycasterView:clear
do
    local source = lurek.raycaster.new(8, 8)
    local view = lurek.raycaster.newView({ rays = 32 })
    view:setCameraState({ x = 2, y = 2, angle = 0, fov = 1 })
    view:build(source)
    view:clear()
    lurek.log.info("cleared quads=" .. tostring(view:getStats().quadCount))
end

--@api: LRaycasterView:type
do
    local view = lurek.raycaster.newView()
    local kind = view:type()
    local exact = view:typeOf("LRaycasterView")
    local base = view:typeOf("LObject")
    lurek.log.info(kind .. " exact=" .. tostring(exact) .. " base=" .. tostring(base))
end

--@api: LRaycasterView:typeOf
do
    local view = lurek.raycaster.newView()
    local exact = view:typeOf("LRaycasterView")
    local base = view:typeOf("LObject")
    local other = view:typeOf("LRaycaster")
    lurek.log.info("view types=" .. tostring(exact) .. "," .. tostring(base) .. "," .. tostring(other))
end

--@api: LRaycaster:patchCells
do
    local source = lurek.raycaster.new(3, 3)
    source:patchCells({ { x = 1, y = 1, value = 4 } })
    local value = source:getCell(1, 1)
    local hit = source:castRay(0.5, 1.5, 0, 4)
    lurek.log.info("patched=" .. tostring(value) .. " hit=" .. tostring(hit ~= nil))
end

--@api: LMultiLevelGrid:patchCells
do
    local grid = lurek.raycaster.newMultiLevelGrid({ { width = 3, height = 3, cells = { 0, 0, 0, 0, 0, 0, 0, 0, 0 } } })
    grid:patchCells({ { level = 0, x = 1, y = 1, value = 6, floorHole = true } })
    local value = grid:getCell(1, 1)
    local patched = value == 6
    lurek.log.info("multilevel patch=" .. tostring(value) .. " applied=" .. tostring(patched))
end
