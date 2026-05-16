-- content/examples/raycaster.lua
-- lurek.raycaster API examples.
-- Run: cargo run -- content/examples/raycaster.lua

--@api-stub: lurek.raycaster.new -- Creates a new raycaster map with the given grid dimensions
do -- lurek.raycaster.new
  local rc = lurek.raycaster.new(16, 12)
  rc:setCell(3, 4, 1)
  lurek.log.info("grid " .. rc:width() .. "x" .. rc:height(), "raycaster")
end

--@api-stub: lurek.raycaster.newMap -- Creates a new raycaster map (alias for `new`)
do -- lurek.raycaster.newMap
  local map = lurek.raycaster.newMap(32, 32)
  for x = 0, 31 do map:setCell(x, 0, 1); map:setCell(x, 31, 1) end
  for y = 0, 31 do map:setCell(0, y, 1); map:setCell(31, y, 1) end
end

--@api-stub: lurek.raycaster.projectColumn -- Computes the projected wall-column height for a given distance, FOV, and screen height
do -- lurek.raycaster.projectColumn
  local fov = math.pi / 3
  local h, top, bot = lurek.raycaster.projectColumn(4.5, fov, 720)
  lurek.log.debug("col h=" .. h .. " top=" .. top .. " bot=" .. bot, "raycaster")
end

--@api-stub: lurek.raycaster.distanceShade -- Returns a brightness multiplier (0
do -- lurek.raycaster.distanceShade
  local shade = lurek.raycaster.distanceShade(6.0, 12.0)
  local r, g, b = 0.8 * shade, 0.6 * shade, 0.4 * shade
  lurek.log.debug("wall rgb=" .. r .. "," .. g .. "," .. b, "raycaster")
end

--@api-stub: lurek.raycaster.newDoorManager -- Creates a new door manager for tracking and animating sliding doors
do -- lurek.raycaster.newDoorManager
  local doors = lurek.raycaster.newDoorManager()
  doors:addDoor(5, 7, "horizontal", 2.5)
  doors:addDoor(9, 3, "vertical", 1.8)
end

--@api-stub: lurek.raycaster.newHeightMap -- Creates a new height map for variable floor/ceiling heights across the grid
do -- lurek.raycaster.newHeightMap
  local hm = lurek.raycaster.newHeightMap(16, 12)
  hm:setFloor(4, 5, -0.25)
  hm:setCeiling(4, 5, 1.5)
end

--@api-stub: lurek.raycaster.newPointLight -- Creates a new point light with position, color, radius, and intensity
do -- lurek.raycaster.newPointLight
  local torch = lurek.raycaster.newPointLight(8.5, 6.0, 1.0, 0.7, 0.3, 4.0, 1.5)
  lurek.log.info("torch radius=" .. torch:radius(), "raycaster")
end

--@api-stub: lurek.raycaster.newSpriteManager -- Creates a new sprite manager for tracking and projecting billboard sprites
do -- lurek.raycaster.newSpriteManager
  local sprites = lurek.raycaster.newSpriteManager()
  sprites:add(6.5, 4.5, "enemy_zombie", 1.0)
  sprites:add(10.0, 8.0, "barrel", 0.75)
end

-- â”€â”€ DoorManager methods â”€â”€

--@api-stub: DoorManager:openDoor
do -- DoorManager:openDoor
  local doors = lurek.raycaster.newDoorManager()
  local idx = doors:addDoor(5, 7, "horizontal", 2.0)
  doors:openDoor(idx)
end

--@api-stub: DoorManager:closeDoor
do -- DoorManager:closeDoor
  local doors = lurek.raycaster.newDoorManager()
  local idx = doors:addDoor(12, 4, "vertical", 1.5)
  doors:openDoor(idx)
  doors:closeDoor(idx)
end

--@api-stub: DoorManager:update
do -- DoorManager:update
  local doors = lurek.raycaster.newDoorManager()
  doors:addDoor(3, 3, "horizontal", 2.0)
  function lurek.process(dt) doors:update(dt) end
end

--@api-stub: DoorManager:getDoor
do -- DoorManager:getDoor
  local doors = lurek.raycaster.newDoorManager()
  local idx = doors:addDoor(5, 7, "horizontal", 2.0)
  local d = doors:getDoor(idx)
  if d and d.openAmount > 0.9 then lurek.log.info("door " .. d.x .. "," .. d.y .. " passable", "doors") end
end

--@api-stub: DoorManager:count
do -- DoorManager:count
  local doors = lurek.raycaster.newDoorManager()
  doors:addDoor(2, 2, "horizontal", 2.0)
  doors:addDoor(8, 5, "vertical", 2.0)
  lurek.log.info("level has " .. doors:count() .. " doors", "doors")
end

--@api-stub: DoorManager:type
do -- DoorManager:type
  local doors = lurek.raycaster.newDoorManager()
  if doors:type() == "DoorManager" then lurek.log.debug("door manager OK", "raycaster") end
end

--@api-stub: DoorManager:typeOf
do -- DoorManager:typeOf
  local doors = lurek.raycaster.newDoorManager()
  if doors:typeOf("DoorManager") then lurek.log.debug("dispatched as DoorManager", "raycaster") end
end

-- â”€â”€ HeightMap methods â”€â”€

--@api-stub: HeightMap:setFloor
do -- HeightMap:setFloor
  local hm = lurek.raycaster.newHeightMap(16, 12)
  for x = 4, 7 do hm:setFloor(x, 6, -0.5) end
  hm:setFloor(8, 6, -0.25)
end

--@api-stub: HeightMap:setCeiling
do -- HeightMap:setCeiling
  local hm = lurek.raycaster.newHeightMap(16, 12)
  for x = 0, 15 do hm:setCeiling(x, 0, 0.6) end
end

--@api-stub: HeightMap:floorAt
do -- HeightMap:floorAt
  local hm = lurek.raycaster.newHeightMap(16, 12)
  hm:setFloor(5, 5, -0.4)
  local h = hm:floorAt(5, 5)
  if h < 0 then lurek.log.debug("pit depth " .. -h, "raycaster") end
end

--@api-stub: HeightMap:ceilingAt
do -- HeightMap:ceilingAt
  local hm = lurek.raycaster.newHeightMap(16, 12)
  local headroom = hm:ceilingAt(3, 4) - hm:floorAt(3, 4)
  lurek.log.debug("cell headroom=" .. headroom, "raycaster")
end

--@api-stub: HeightMap:type
do -- HeightMap:type
  local hm = lurek.raycaster.newHeightMap(8, 8)
  lurek.log.debug("heightmap type: " .. hm:type(), "raycaster")
end

--@api-stub: HeightMap:typeOf
do -- HeightMap:typeOf
  local hm = lurek.raycaster.newHeightMap(8, 8)
  if hm:typeOf("HeightMap") then lurek.log.debug("is HeightMap", "raycaster") end
end

-- â”€â”€ PointLight methods â”€â”€

--@api-stub: PointLight:x
do -- PointLight:x
  local light = lurek.raycaster.newPointLight(10.0, 5.0, 1, 1, 1, 5, 1)
  local px = light:x()
  if px > 8 then lurek.log.debug("light is east of midpoint at x=" .. px, "raycaster") end
end

--@api-stub: PointLight:y
do -- PointLight:y
  local light = lurek.raycaster.newPointLight(4.0, 7.5, 1, 0.8, 0.6, 4, 1.2)
  local py = light:y()
  lurek.log.debug("light row " .. math.floor(py), "raycaster")
end

--@api-stub: PointLight:radius
do -- PointLight:radius
  local light = lurek.raycaster.newPointLight(8, 6, 1, 1, 1, 6.0, 1.0)
  local r = light:radius()
  if r > 5 then lurek.log.info("large light radius=" .. r, "raycaster") end
end

--@api-stub: PointLight:intensity
do -- PointLight:intensity
  local light = lurek.raycaster.newPointLight(2, 3, 1, 0.5, 0.2, 3, 2.5)
  local mul = light:intensity() * lurek.raycaster.distanceShade(1.5, 6.0)
  lurek.log.debug("contrib=" .. mul, "raycaster")
end

--@api-stub: PointLight:color
do -- PointLight:color
  local light = lurek.raycaster.newPointLight(4, 4, 1.0, 0.4, 0.2, 5, 1)
  local r, g, b = light:color()
  lurek.log.debug("torch tint " .. r .. "," .. g .. "," .. b, "raycaster")
end

--@api-stub: PointLight:type
do -- PointLight:type
  local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
  lurek.log.info("PointLight:type = " .. light:type(), "raycaster")
end

--@api-stub: PointLight:typeOf
do -- PointLight:typeOf
  local light = lurek.raycaster.newPointLight(1, 1, 0.5, 0.5, 1, 2, 1)
  if light:typeOf("LPointLight") then lurek.log.debug("light kind ok", "raycaster") end
end

-- â”€â”€ Raycaster methods â”€â”€
-- do  -- Raycaster:setCell
--   local rc = lurek.raycaster.new(8, 8)
--   for x = 0, 7 do rc:setCell(x, 0, 1); rc:setCell(x, 7, 1) end
--   rc:setCell(3, 3, 2)
-- end

--@api-stub: Raycaster:getCell
do -- Raycaster:getCell
  local rc = lurek.raycaster.new(8, 8)
  rc:setCell(2, 2, 3)
  if rc:getCell(2, 2) == 3 then lurek.log.debug("cell holds tile id 3", "raycaster") end
end

--@api-stub: Raycaster:setCells
do -- Raycaster:setCells
  local rc = lurek.raycaster.new(4, 3)
  rc:setCells({
    1, 1, 1, 1,
    1, 0, 0, 1,
    1, 1, 1, 1,
  })
end

--@api-stub: Raycaster:tryMove
do -- Raycaster:tryMove
  local rc = lurek.raycaster.new(8, 8)
  rc:setCell(4, 3, 1)
  local x, y, moved = rc:tryMove(3.5, 3.5, 1.0, 0.0)
  lurek.log.debug("tryMove -> " .. tostring(x) .. "," .. tostring(y) .. " moved=" .. tostring(moved), "raycaster")
end

--@api-stub: Raycaster:gridMove
do -- Raycaster:gridMove
  local rc = lurek.raycaster.new(8, 8)
  local x, y, moved = rc:gridMove(2.5, 2.5, 1, "forward", 1.0)
  lurek.log.debug("gridMove -> " .. tostring(x) .. "," .. tostring(y) .. " moved=" .. tostring(moved), "raycaster")
end
-- end

--@api-stub: Raycaster:width
do -- Raycaster:width
  local rc = lurek.raycaster.new(20, 15)
  for x = 0, rc:width() - 1 do rc:setCell(x, 0, 1) end
end

--@api-stub: Raycaster:height
do -- Raycaster:height
  local rc = lurek.raycaster.new(20, 15)
  for y = 0, rc:height() - 1 do rc:setCell(0, y, 1) end
end

--@api-stub: Raycaster:setWallAlpha
do -- Raycaster:setWallAlpha
  local rc = lurek.raycaster.new(8, 8)
  rc:setCell(3, 3, 5)
  rc:setWallAlpha(5, 0.4)
end

--@api-stub: Raycaster:getWallAlpha
do -- Raycaster:getWallAlpha
  local rc = lurek.raycaster.new(8, 8)
  rc:setWallAlpha(2, 0.6)
  local a = rc:getWallAlpha(2)
  if a < 1.0 then lurek.log.debug("tile 2 alpha=" .. a, "raycaster") end
end

-- â”€â”€ SpriteManager methods â”€â”€

--@api-stub: SpriteManager:remove
do -- SpriteManager:remove
  local sprites = lurek.raycaster.newSpriteManager()
  local id = sprites:add(5.0, 4.0, "potion", 0.5)
  sprites:remove(id)
end

--@api-stub: SpriteManager:setPosition
do -- SpriteManager:setPosition
  local sprites = lurek.raycaster.newSpriteManager()
  local id = sprites:add(2.0, 2.0, "enemy_imp", 1.0)
  function lurek.process(dt) sprites:setPosition(id, 2.0 + dt, 2.0) end
end

--@api-stub: SpriteManager:setVisible
do -- SpriteManager:setVisible
  local sprites = lurek.raycaster.newSpriteManager()
  local id = sprites:add(7.0, 3.0, "key_red", 0.6)
  sprites:setVisible(id, false)
end

--@api-stub: SpriteManager:clear
do -- SpriteManager:clear
  local sprites = lurek.raycaster.newSpriteManager()
  sprites:add(1, 1, "barrel", 1.0)
  sprites:add(3, 4, "barrel", 1.0)
  sprites:clear()
end

--@api-stub: SpriteManager:type
do -- SpriteManager:type
  local sprites = lurek.raycaster.newSpriteManager()
  lurek.log.info("SpriteManager:type = " .. tostring(sprites and sprites:type() or "nil"), "raycaster")
end

--@api-stub: SpriteManager:typeOf
do -- SpriteManager:typeOf
  local sprites = lurek.raycaster.newSpriteManager()
  if sprites and sprites:typeOf("LSpriteManager") then lurek.log.debug("sprite mgr ok", "raycaster") end
end
-- content/examples/raycaster.lua
-- EXAMPLEed coverage of the lurek.raycaster API (42 items).
--
-- Every --@api-stub: block below is a SCAFFOLD. The body must be
-- replaced by hand with a 3-6 line real usage snippet showing how to
-- call the API in real game context, written by reading:
--   * src/lua_api/raycaster_api.rs   (Lua binding, arg types, return shape)
--   * src/raycaster/                 (semantics, side effects)
--   * docs/specs/raycaster.md        (canonical reference)
--
-- Snippet rules (love2d-wiki style):
--   * NO `return` at top-level (breaks the file).
--   * NO `pcall` defensive wrappers, NO `if false then`.
--   * Wrap GPU / audio / physics calls inside
--     `function lurek.draw() ... end` or
--     `function lurek.update(dt) ... end` callbacks so the file loads.
--   * Use REAL values: paths like "sfx/jump.ogg", keys like "space",
--     colours like {1, 0.5, 0, 1}.
--   * Keep the two `--` comment lines: 1) what the API does (use the
--     existing description), 2) one line of practical advice.
--
-- Run: cargo run -- content/examples/raycaster.lua

-- â”€â”€ lurek.raycaster.* functions â”€â”€

--@api-stub: SpriteManager:add
do -- SpriteManager:add
  local sm = lurek.raycaster.newSpriteManager()
  local id = sm:add(3.5, 2.5, "crate", 1.0)
  lurek.log.info("sprite id: " .. id, "raycaster")
end

--@api-stub: DoorManager:addDoor
do -- DoorManager:addDoor
  local dm = lurek.raycaster.newDoorManager()
  local rc = lurek.raycaster.new(32, 32)
  local did = dm:addDoor(5, 7, "horizontal", 1.0)
  lurek.log.info("door id: " .. did, "raycaster")
end

--@api-stub: Raycaster:buildScene
do -- Raycaster:buildScene
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  local params = { px = 8, py = 8, angle = 0, fov = math.pi/3, rays = 320,
                   max_dist = 16, screen_w = 320, screen_h = 240 }
  rc:buildScene(params, nil, nil, { [1] = tex })
  lurek.log.info("scene built", "raycaster")
end

--@api-stub: Raycaster:castFloorRow
do -- Raycaster:castFloorRow
  local rc = lurek.raycaster.new(16, 16)
  local uvs = rc:castFloorRow(8, 8, 1, 0, 0, 0.66, 240)
  lurek.log.info("floor row uv count: " .. (uvs and #uvs or 0), "raycaster")
end

--@api-stub: Raycaster:castRay
do -- Raycaster:castRay
  local rc = lurek.raycaster.new(16, 16)
  local hit = rc:castRay(8, 8, 0, 16)
  lurek.log.info("ray dist: " .. (hit and hit.dist or -1), "raycaster")
end

--@api-stub: Raycaster:castRayMulti
do -- Raycaster:castRayMulti
  local rc = lurek.raycaster.new(16, 16)
  local results = rc:castRayMulti(8, 8, 0, 16)
  lurek.log.info("multi-ray results: " .. #results, "raycaster")
end

--@api-stub: Raycaster:castRays
do -- Raycaster:castRays
  local rc = lurek.raycaster.new(16, 16)
  local cols = rc:castRays(8, 8, 0, math.pi/3, 320, 16)
  lurek.log.info("columns: " .. (cols and #cols or 0), "raycaster")
end

--@api-stub: Raycaster:castRaysFlat
do -- Raycaster:castRaysFlat
  local rc = lurek.raycaster.new(16, 16)
  local flat = rc:castRaysFlat(8, 8, 0, math.pi/3, 320, 16)
  lurek.log.info("flat ray count: " .. (flat and #flat or 0), "raycaster")
end

--@api-stub: Raycaster:drawCameraSweep
do -- Raycaster:drawCameraSweep
  local rc = lurek.raycaster.new(16, 16)
  local img = rc:drawCameraSweep(8, 8, math.pi/3, 16, 6, 64, 48)
  lurek.log.info("camera sweep drawn", "raycaster")
end

--@api-stub: Raycaster:drawDepthMap
do -- Raycaster:drawDepthMap
  local rc = lurek.raycaster.new(16, 16)
  local img = rc:drawDepthMap(8, 8, 0, math.pi/3, 320, 320, 240, 16)
  lurek.log.info("depth map drawn", "raycaster")
end

--@api-stub: Raycaster:drawLineOfSight
do -- Raycaster:drawLineOfSight
  local rc = lurek.raycaster.new(16, 16)
  local img = rc:drawLineOfSight(4, 4, 12, 12, 8)
  lurek.log.info("LOS drawn", "raycaster")
end

--@api-stub: Raycaster:drawTopDown
do -- Raycaster:drawTopDown
  local rc = lurek.raycaster.new(16, 16)
  local img = rc:drawTopDown(8, 8, 0, 8)
  lurek.log.info("top-down drawn", "raycaster")
end

--@api-stub: Raycaster:drawView
do -- Raycaster:drawView
  local rc = lurek.raycaster.new(16, 16)
  local img = rc:drawView(8, 8, 0, math.pi/3, 320, 240, 16)
  lurek.log.info("view rendered", "raycaster")
end

--@api-stub: Raycaster:lineOfSight
do -- Raycaster:lineOfSight
  local rc = lurek.raycaster.new(16, 16)
  local los = rc:lineOfSight(4, 4, 12, 12)
  lurek.log.info("LOS result: " .. tostring(los), "raycaster")
end

--@api-stub: Raycaster:revealCellsFromRays
do -- Raycaster:revealCellsFromRays
  local rc = lurek.raycaster.new(32, 32)
  local cells = rc:revealCellsFromRays(10.5, 10.5, 0.0, math.pi/3, 32, 12.0, 0.2)
  lurek.log.info("revealed cells: " .. #cells, "raycaster")
end

--@api-stub: Raycaster:computeTileLight
do -- Raycaster:computeTileLight
  local rc = lurek.raycaster.new(16, 16)
  local r, g, b, luma = rc:computeTileLight(8, 8, 0.2, {
    { x = 8.5, y = 8.5, radius = 5.0, r = 1.0, g = 0.8, b = 0.6, intensity = 8.0 }
  })
  lurek.log.info("tile luma: " .. luma, "raycaster")
end

--@api-stub: Raycaster:buildMinimapWindow
do -- Raycaster:buildMinimapWindow
  local rc = lurek.raycaster.new(32, 32)
  local rows = rc:buildMinimapWindow(12.5, 14.5, 10, 0.25, nil)
  lurek.log.info("minimap rows: " .. #rows, "raycaster")
end

--@api-stub: Raycaster:projectSprite
do -- Raycaster:projectSprite
  local rc = lurek.raycaster.new(16, 16)
  local sp = rc:projectSprite(8, 4, 4, 0, math.pi/3, 320, 240)
  lurek.log.info("projected: " .. (sp and sp.screen_x or -1), "raycaster")
end

--@api-stub: Raycaster:setCell
do -- Raycaster:setCell
  local rc = lurek.raycaster.new(16, 16)
  rc:setCell(4, 4, 2)
  lurek.log.info("cell 4,4 = 2", "raycaster")
end

--@api-stub: Raycaster:setFloorTextureCell
do -- Raycaster:setFloorTextureCell
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  rc:setFloorTextureCell(4, 4, tex)
  rc:setFloorTextureCell(4, 4, nil)
end

--@api-stub: Raycaster:getFloorTextureCell
do -- Raycaster:getFloorTextureCell
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  rc:setFloorTextureCell(2, 2, tex)
  local id = rc:getFloorTextureCell(2, 2)
  lurek.log.info("floor tex id: " .. tostring(id), "raycaster")
end

--@api-stub: Raycaster:setCeilingTextureCell
do -- Raycaster:setCeilingTextureCell
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  rc:setCeilingTextureCell(4, 4, tex)
  rc:setCeilingTextureCell(4, 4, nil)
end

--@api-stub: Raycaster:getCeilingTextureCell
do -- Raycaster:getCeilingTextureCell
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  rc:setCeilingTextureCell(2, 2, tex)
  local id = rc:getCeilingTextureCell(2, 2)
  lurek.log.info("ceiling tex id: " .. tostring(id), "raycaster")
end

--@api-stub: Raycaster:setLoweredFloorCell
do -- Raycaster:setLoweredFloorCell
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  rc:setLoweredFloorCell(6, 6, {
    texture = tex,
    depth = 0.25,
    r = 0.8,
    g = 0.9,
    b = 1.0,
    blocked = true,
  })
  rc:setLoweredFloorCell(6, 6, nil)
end

--@api-stub: Raycaster:getLoweredFloorCell
do -- Raycaster:getLoweredFloorCell
  local rc = lurek.raycaster.new(16, 16)
  local tex = lurek.render.newImage("assets/icon.png")
  rc:setLoweredFloorCell(3, 3, { texture = tex, depth = 0.25, blocked = true })
  local cell = rc:getLoweredFloorCell(3, 3)
  lurek.log.info("lowered floor blocked: " .. tostring(cell and cell.blocked), "raycaster")
end

--@api-stub: Raycaster:isWalkBlocked
do -- Raycaster:isWalkBlocked
  local rc = lurek.raycaster.new(16, 16)
  rc:setCell(1, 1, 2)
  lurek.log.info("wall blocked: " .. tostring(rc:isWalkBlocked(1, 1)), "raycaster")
end

--@api-stub: SpriteManager:sortAndProject
do -- SpriteManager:sortAndProject
  local sm = lurek.raycaster.newSpriteManager()
  sm:add(3.5, 2.5, "crate", 1.0)
  local projs = sm:sortAndProject(8, 8, 0)
  lurek.log.info("projected sprites: " .. #projs, "raycaster")
end

--@api-stub: PointLight:set
do -- PointLight:set
  local light = lurek.raycaster.newPointLight(4.5, 3.5, 1.0, 0.9, 0.7, 6.0, 1.0)
  light:set(4.5, 3.5, 1.0, 0.9, 0.7, 6.0, 1.0)
  lurek.log.info("point light configured", "raycaster")
end


-- -----------------------------------------------------------------------------
-- LRaycaster methods
-- -----------------------------------------------------------------------------


--@api-stub: LRaycaster:type -- Returns the type name of this object ("LRaycaster")
do -- LRaycaster:type
  local rc = lurek.raycaster.new(8, 8)
  local t = rc:type()
  lurek.log.info("LRaycaster:type = " .. t, "raycaster")
end


--@api-stub: LRaycaster:typeOf -- Checks whether this object matches the given type name
do -- LRaycaster:typeOf
  local rc = lurek.raycaster.new(8, 8)
  lurek.log.info("is LRaycaster: " .. tostring(rc:typeOf("LRaycaster")), "raycaster")
  lurek.log.info("is unknown: " .. tostring(rc:typeOf("Unknown")), "raycaster")
end


-- -----------------------------------------------------------------------------
-- LRaycaster methods
-- -----------------------------------------------------------------------------


--@api-stub: Raycaster:isBlocked
do -- Raycaster:isBlocked
  local rc = lurek.raycaster.new(8, 8)
  rc:setCell(4, 4, 1)
  local blocked = rc:isBlocked(4, 4)
  lurek.log.debug("(4,4) blocked=" .. tostring(blocked), "raycaster")
end


--@api-stub: Raycaster:buildSceneWithModels
do -- Raycaster:buildSceneWithModels
  local rc = lurek.raycaster.new(8, 8)
  rc:setCell(3, 3, 1)
  local params = { pos_x = 1.5, pos_y = 1.5, angle = 0, fov = 1.0, screen_w = 320, screen_h = 200 }
  local ok, n = pcall(function() return rc:buildSceneWithModels(params) end)
  lurek.log.info("buildSceneWithModels ok=" .. tostring(ok), "raycaster")
end

