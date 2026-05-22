-- content/examples/raycaster.lua
-- Auto-generated from content/examples2/raycaster_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/raycaster.lua

--@api-stub: lurek.raycaster.new
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    print("size = " .. map:width() .. "x" .. map:height())
end

--@api-stub: lurek.raycaster.newMap
do
    ---@type LRaycaster
    local map = lurek.raycaster.newMap(32, 32)
    print("alias size = " .. map:width() .. "x" .. map:height())
end

--@api-stub: LRaycaster:setCell
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    print("cell set")
end

--@api-stub: LRaycaster:getCell
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(0, 0, 1)
    print("cell 0,0 = " .. map:getCell(0, 0))
end

--@api-stub: LRaycaster:setCells
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    local cells = {1, 1, 1, 1, 1, 1, 1, 1}; for i = 9, 64 do cells[i] = 0 end
    map:setCells(cells)
    print("after setCells: 0,0 = " .. map:getCell(0, 0))
end

--@api-stub: LRaycaster:isBlocked
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    print("3,3 blocked = " .. tostring(map:isBlocked(3, 3)))
end

--@api-stub: LRaycaster:isWalkBlocked
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setCell(3, 3, 1)
    print("3,3 walk blocked = " .. tostring(map:isWalkBlocked(3, 3)))
end

--@api-stub: LRaycaster:castRay
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    local hit = map:castRay(8, 8, 0, 20)
    if hit then print("distance = " .. hit.distance .. " cell=" .. hit.cell_value .. " side=" .. hit.side .. " hit=" .. tostring(hit.hit)) end
end

--@api-stub: LRaycaster:castRays
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    local hits = map:castRays(8, 8, 0, math.pi / 3, 10, 20)
    print("rays cast = " .. #hits .. (hits[1] and hits[1].hit and (" first=" .. string.format("%.2f", hits[1].distance)) or ""))
end

--@api-stub: LRaycaster:castRaysFlat
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    local distances = map:castRaysFlat(8, 8, 0, math.pi / 3, 320, 20)
    print("distance array = " .. #distances .. " center=" .. string.format("%.2f", distances[160]))
end

--@api-stub: LRaycaster:castRayMulti
do
    local map = lurek.raycaster.new(16, 16)
    map:setCell(5, 8, 2); map:setCell(10, 8, 1); map:setWallAlpha(2, 0.5)
    local hits = map:castRayMulti(2, 8.5, 0, 20, 4)
    print("multi hits = " .. #hits .. (hits[1] and (" first=" .. string.format("%.2f", hits[1].distance) .. " cell=" .. hits[1].cell_value) or ""))
end

--@api-stub: LRaycaster:setWallAlpha
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    print("wall alpha set")
end

--@api-stub: LRaycaster:getWallAlpha
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    map:setWallAlpha(2, 0.5)
    print("type 2 alpha = " .. map:getWallAlpha(2))
end

--@api-stub: LRaycaster:tryMove
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do map:setCell(i, 0, 1); map:setCell(i, 7, 1); map:setCell(0, i, 1); map:setCell(7, i, 1) end
    local nx, ny, moved = map:tryMove(4.5, 4.5, 0.1, 0); local wx, wy, wmoved = map:tryMove(0.5, 0.5, -1, 0)
    print("moved = " .. tostring(moved) .. " new=" .. nx .. "," .. ny .. " wall=" .. tostring(wmoved) .. " pos=" .. wx .. "," .. wy)
end

--@api-stub: LRaycaster:gridMove
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do map:setCell(i, 0, 1); map:setCell(i, 7, 1); map:setCell(0, i, 1); map:setCell(7, i, 1) end
    local nx, ny, ok = map:gridMove(4.5, 4.5, 1, "forward", 1.0); local sx, sy, sok = map:gridMove(nx, ny, 1, "left", 1.0)
    print("forward: " .. nx .. "," .. ny .. " ok=" .. tostring(ok) .. " left=" .. sx .. "," .. sy .. " ok=" .. tostring(sok))
end

--@api-stub: LRaycaster:lineOfSight
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(16, 16)
    map:setCell(8, 8, 1)
    local clear = map:lineOfSight(4, 4, 12, 4); local blocked = map:lineOfSight(4, 8, 12, 8)
    print("clear path = " .. tostring(clear) .. " blocked=" .. tostring(blocked))
end

--@api-stub: LRaycaster:revealCellsFromRays
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    map:setCell(6, 8, 1)
    local revealed = map:revealCellsFromRays(8, 8, 0, math.pi * 2, 64, 10)
    print("revealed cells = " .. #revealed .. " first=" .. (#revealed > 0 and (revealed[1].x .. "," .. revealed[1].y) or "none"))
end

--@api-stub: LRaycaster:drawView
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 16)
    print("view image created")
end

--@api-stub: LRaycaster:drawTopDown
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do map:setCell(i, 0, 1); map:setCell(i, 7, 1); map:setCell(0, i, 1); map:setCell(7, i, 1) end
    map:setCell(3, 3, 1); local img = map:drawTopDown(4.5, 4.5, 0, 16)
    print("top-down image created")
end

--@api-stub: LRaycaster:drawDepthMap
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    local depth = map:drawDepthMap(8, 8, 0, math.pi / 3, 160, 160, 100, 16)
    print("depth map created")
end

--@api-stub: lurek.raycaster.distanceShade
do
    local bright = lurek.raycaster.distanceShade(0, 10); local mid = lurek.raycaster.distanceShade(5, 10); local dark = lurek.raycaster.distanceShade(9, 10)
    print("dist 0: " .. string.format("%.2f", bright) .. " dist 5: " .. string.format("%.2f", mid) .. " dist 9: " .. string.format("%.2f", dark))
end

--@api-stub: lurek.raycaster.projectColumn
do
    local h1 = lurek.raycaster.projectColumn(1.0, math.pi / 3, 200); local h2 = lurek.raycaster.projectColumn(5.0, math.pi / 3, 200); local h3 = lurek.raycaster.projectColumn(10.0, math.pi / 3, 200)
    print("dist 1 height = " .. string.format("%.1f", h1) .. " dist 5 = " .. string.format("%.1f", h2) .. " dist 10 = " .. string.format("%.1f", h3))
end

--@api-stub: LRaycaster:type
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    print("type = " .. map:type())
end

--@api-stub: LRaycaster:typeOf
do
    ---@type LRaycaster
    local map = lurek.raycaster.new(8, 8)
    print("is LRaycaster = " .. tostring(map:typeOf("LRaycaster")))
end

--- Raycaster Module Part 2: doors, height maps, lights, sprites, floor/ceiling, scene building, minimap


--@api-stub: lurek.raycaster.newDoorManager
do
    local doors = lurek.raycaster.newDoorManager()
    local idx1 = doors:addDoor(5, 3, "north", 2.0); local idx2 = doors:addDoor(8, 6, "east", 1.5)
    doors:openDoor(idx1); doors:update(0.5); local d = doors:getDoor(idx1)
    doors:closeDoor(idx1); doors:update(1.0)
    print("door 1 idx = " .. idx1 .. " door 2 idx = " .. idx2 .. " total = " .. doors:count() .. " state=" .. d.state)
end

--@api-stub: LDoorManager:getDoor
do
    local doors = lurek.raycaster.newDoorManager()
    local idx = doors:addDoor(3, 3, "south", 4.0)
    doors:openDoor(idx); for i = 1, 10 do doors:update(0.1) end
    local d = doors:getDoor(idx); doors:closeDoor(idx); for i = 1, 10 do doors:update(0.1) end
    print("after 1s: open=" .. string.format("%.2f", d.openAmount) .. " after close=" .. string.format("%.2f", doors:getDoor(idx).openAmount))
end

--@api-stub: LDoorManager:type
do
    ---@type LDoorManager
    local doors = lurek.raycaster.newDoorManager()
    print("type = " .. doors:type())
end

--@api-stub: LDoorManager:typeOf
do
    ---@type LDoorManager
    local doors = lurek.raycaster.newDoorManager()
    print("is LDoorManager = " .. tostring(doors:typeOf("LDoorManager")))
end

--@api-stub: lurek.raycaster.newHeightMap
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(5, 5, -0.3); hm:setCeiling(5, 5, 0.8); hm:setFloor(10, 10, 0.2); hm:setCeiling(10, 10, 1.5)
    print("floor at 5,5 = " .. hm:floorAt(5, 5) .. " ceiling at 5,5 = " .. hm:ceilingAt(5, 5))
    print("floor at 10,10 = " .. hm:floorAt(10, 10) .. " ceiling at 10,10 = " .. hm:ceilingAt(10, 10))
end

--@api-stub: LHeightMap:type
do
    ---@type LHeightMap
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("type = " .. hm:type())
end

--@api-stub: LHeightMap:typeOf
do
    ---@type LHeightMap
    local hm = lurek.raycaster.newHeightMap(4, 4)
    print("is LHeightMap = " .. tostring(hm:typeOf("LHeightMap")))
end

--@api-stub: lurek.raycaster.newPointLight
do
    local torch = lurek.raycaster.newPointLight(5.5, 3.5, 1.0, 0.8, 0.4, 4.0, 1.5)
    local r, g, b = torch:color()
    print("pos = " .. torch:x() .. ", " .. torch:y() .. " color = " .. r .. "," .. g .. "," .. b)
    print("radius = " .. torch:radius() .. " intensity = " .. torch:intensity())
end

--@api-stub: LPointLight:set
do
    local light = lurek.raycaster.newPointLight(2, 2, 1, 1, 1, 3, 1.0)
    light:set(8, 8, 0, 0, 1, 6, 2.0)
    print("moved to " .. light:x() .. "," .. light:y() .. " radius=" .. light:radius() .. " intensity=" .. light:intensity())
end

--@api-stub: LPointLight:type
do
    ---@type LPointLight
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("type = " .. light:type())
end

--@api-stub: LPointLight:typeOf
do
    ---@type LPointLight
    local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
    print("is LPointLight = " .. tostring(light:typeOf("LPointLight")))
end

--@api-stub: lurek.raycaster.newSpriteManager
do
    local sprites = lurek.raycaster.newSpriteManager()
    local barrel = sprites:add(5.5, 3.5, "barrel", 1.0); local torch = sprites:add(8.5, 2.5, "torch", 0.5); local enemy = sprites:add(10.5, 7.5, "enemy", 1.2)
    sprites:setPosition(enemy, 11, 8); sprites:setVisible(torch, false); sprites:remove(barrel)
    print("barrel id = " .. barrel .. " torch id = " .. torch)
    print("sprite manager ready")
end

--@api-stub: LSpriteManager:sortAndProject
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(3, 3, "crate"); sprites:add(6, 6, "pillar"); sprites:add(9, 9, "lamp")
    local order = sprites:sortAndProject(5, 5, 0)
    print("render order = " .. #order .. (order[1] and (" first=" .. tostring(order[1])) or ""))
end

--@api-stub: LSpriteManager:clear
do
    local sprites = lurek.raycaster.newSpriteManager()
    sprites:add(1, 1, "item")
    sprites:add(2, 2, "item")
    sprites:clear()
    print("sprites cleared")
end

--@api-stub: LSpriteManager:type
do
    ---@type LSpriteManager
    local sprites = lurek.raycaster.newSpriteManager()
    print("type = " .. sprites:type())
end

--@api-stub: LSpriteManager:typeOf
do
    ---@type LSpriteManager
    local sprites = lurek.raycaster.newSpriteManager()
    print("is LSpriteManager = " .. tostring(sprites:typeOf("LSpriteManager")))
end

--@api-stub: LRaycaster:setFloorTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local floorTex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setFloorTextureCell(3, 3, floorTex)
    print("floor texture assigned")
end

--@api-stub: LRaycaster:getFloorTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local floorTex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setFloorTextureCell(3, 3, floorTex)
    print("floor at 3,3 = " .. tostring(map:getFloorTextureCell(3, 3)))
end

--@api-stub: LRaycaster:setCeilingTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local ceilTex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setCeilingTextureCell(2, 2, ceilTex)
    print("ceiling texture assigned")
end

--@api-stub: LRaycaster:getCeilingTextureCell
do
    local map = lurek.raycaster.new(8, 8)
    local ceilTex = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    map:setCeilingTextureCell(2, 2, ceilTex)
    print("ceiling at 2,2 = " .. tostring(map:getCeilingTextureCell(2, 2)))
end

--@api-stub: LRaycaster:setLoweredFloorCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setLoweredFloorCell(4, 4, {texture = 2, depth = 0.3, r = 0, g = 100, b = 200, blocked = false})
    print("lowered floor assigned")
end

--@api-stub: LRaycaster:getLoweredFloorCell
do
    local map = lurek.raycaster.new(8, 8)
    map:setLoweredFloorCell(4, 4, {texture = 2, depth = 0.3, r = 0, g = 100, b = 200, blocked = false})
    local cell = map:getLoweredFloorCell(4, 4)
    if cell then print("lowered: texture=" .. cell.texture .. " depth=" .. cell.depth) end
end

--@api-stub: LRaycaster:computeTileLight
do
    local map = lurek.raycaster.new(16, 16)
    local light1 = lurek.raycaster.newPointLight(8, 8, 1.0, 0.9, 0.7, 5.0, 2.0); local light2 = lurek.raycaster.newPointLight(3, 3, 0.2, 0.5, 1.0, 3.0, 1.0)
    local r, g, b, luma = map:computeTileLight(7, 8, 0.1, { light1, light2 })
    print("tile light: r=" .. string.format("%.2f", r) .. " g=" .. string.format("%.2f", g) .. " b=" .. string.format("%.2f", b) .. " luma=" .. string.format("%.2f", luma))
end

--@api-stub: LRaycaster:buildScene
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    local params = {cam_x = 8, cam_y = 8, cam_angle = 0, fov = math.pi / 3, screen_w = 320, screen_h = 200, max_dist = 16}
    local numQuads = map:buildScene(params)
    print("scene quads = " .. numQuads)
end

--@api-stub: LRaycaster:buildMinimapWindow
do
    local map = lurek.raycaster.new(16, 16)
    for i = 0, 15 do map:setCell(i, 0, 1); map:setCell(i, 15, 1); map:setCell(0, i, 1); map:setCell(15, i, 1) end
    map:setCell(5, 8, 1)
    local cells = map:buildMinimapWindow(8, 8, 5, 0.2)
    print("minimap cells = " .. #cells .. " first=" .. (#cells > 0 and (cells[1].x .. "," .. cells[1].y) or "none"))
end

--@api-stub: LRaycaster:projectSprite
do
    local map = lurek.raycaster.new(16, 16)
    local proj = map:projectSprite(10, 8, 8, 8, 0, math.pi / 3, 320)
    print("screen_x = " .. proj.screen_x .. " scale = " .. string.format("%.2f", proj.scale) .. " distance = " .. string.format("%.2f", proj.distance) .. " visible = " .. tostring(proj.visible))
end

--@api-stub: LRaycaster:drawLineOfSight
do
    local map = lurek.raycaster.new(8, 8)
    map:setCell(4, 4, 1); local img = map:drawLineOfSight(1, 1, 7, 7, 16)
    print("LOS image created")
end

--@api-stub: LRaycaster:drawCameraSweep
do
    local map = lurek.raycaster.new(8, 8)
    for i = 0, 7 do map:setCell(i, 0, 1); map:setCell(i, 7, 1); map:setCell(0, i, 1); map:setCell(7, i, 1) end
    local strip = map:drawCameraSweep(4, 4, math.pi / 3, 8, 8, 160, 100)
    print("camera sweep strip created")
end

--@api-stub: LRaycaster:castFloorRow
do
    local map = lurek.raycaster.new(16, 16)
    local uvs = map:castFloorRow(8, 8, 1, 0, 0, 0.66, 150)
    print("floor UVs = " .. #uvs .. (#uvs > 0 and (" first=" .. string.format("%.2f", uvs[1].u) .. "," .. string.format("%.2f", uvs[1].v)) or ""))
end

--- Raycaster Module Part 2: buildSceneWithModels, width/height, DoorManager, HeightMap, PointLight, SpriteManager


--@api-stub: LRaycaster:buildSceneWithModels
do
    local rc = lurek.raycaster.new(80, 60)
    local scene = rc:buildSceneWithModels({ px = 8, py = 8, angle = 0 }, {}, {}, { "content/examples/assets/images/sample_texture.png" }, {})
    print("scene=" .. tostring(scene ~= nil))
end

--@api-stub: LRaycaster:height
do
    local rc = lurek.raycaster.new(160, 120)
    print("w=" .. rc:width())
    print("h=" .. rc:height())
end

--@api-stub: LRaycaster:width
do
    local rc = lurek.raycaster.new(160, 120)
    print("w=" .. rc:width())
    print("h=" .. rc:height())
end

--@api-stub: LDoorManager:addDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    print("count=" .. dm:count() .. " door=" .. tostring(dm:getDoor(id) ~= nil))
end

--@api-stub: LDoorManager:closeDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:closeDoor(id)
    print("closed door " .. id)
end

--@api-stub: LDoorManager:count
do
    local dm = lurek.raycaster.newDoorManager()
    dm:addDoor(5, 5, "horizontal", 0.5)
    print("count=" .. dm:count())
end

--@api-stub: LDoorManager:openDoor
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)
    print("door opened = " .. tostring(dm:getDoor(id) ~= nil))
end

--@api-stub: LDoorManager:update
do
    local dm = lurek.raycaster.newDoorManager()
    local id = dm:addDoor(5, 5, "horizontal", 0.5)
    dm:openDoor(id)
    dm:update(0.1)
    print("door after update = " .. tostring(dm:getDoor(id) ~= nil))
end

--@api-stub: LHeightMap:ceilingAt
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2); hm:setCeiling(3, 3, 0.9)
    print("ceiling=" .. hm:ceilingAt(3, 3))
end

--@api-stub: LHeightMap:floorAt
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2); hm:setCeiling(3, 3, 0.9)
    print("floor=" .. hm:floorAt(3, 3))
end

--@api-stub: LHeightMap:setCeiling
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setCeiling(3, 3, 0.9)
    print("ceiling=" .. hm:ceilingAt(3, 3))
end

--@api-stub: LHeightMap:setFloor
do
    local hm = lurek.raycaster.newHeightMap(16, 16)
    hm:setFloor(3, 3, 0.2)
    print("floor=" .. hm:floorAt(3, 3))
end

--@api-stub: LPointLight:color
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    local r, g, b = pl:color()
    print("color=" .. r .. "," .. g .. "," .. b)
end

--@api-stub: LPointLight:intensity
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    print("intensity=" .. pl:intensity())
end

--@api-stub: LPointLight:radius
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    print("radius=" .. pl:radius())
end

--@api-stub: LPointLight:x
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    print("x=" .. pl:x())
end

--@api-stub: LPointLight:y
do
    local pl = lurek.raycaster.newPointLight(8, 8, 1, 1, 0.8, 5.0, 2.0)
    print("y=" .. pl:y())
end

--@api-stub: LSpriteManager:add
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    print("sprite id=" .. id)
end

--@api-stub: LSpriteManager:remove
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:remove(id)
    print("removed sprite " .. id)
end

--@api-stub: LSpriteManager:setPosition
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setPosition(id, 6, 6)
    print("moved sprite " .. id)
end

--@api-stub: LSpriteManager:setVisible
do
    local sm = lurek.raycaster.newSpriteManager()
    local id = sm:add(5, 5, "content/examples/assets/images/sample_texture.png", 1.0)
    sm:setVisible(id, true)
    print("visible sprite " .. id)
end

print("content/examples/raycaster.lua")

