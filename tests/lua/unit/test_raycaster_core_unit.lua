-- tests/lua/unit/test_raycaster_core_unit.lua
-- Canonical unit coverage for lurek.raycaster and related userdata APIs.

local TEXTURE_PATH = "content/examples/assets/images/sample_texture.png"

local function load_texture()
    return lurek.render.newImage(TEXTURE_PATH)
end

local function make_map(w, h)
    local map = lurek.raycaster.new(w, h)
    for i = 0, w - 1 do
        map:setCell(i, 0, 1)
        map:setCell(i, h - 1, 1)
    end
    for i = 0, h - 1 do
        map:setCell(0, i, 1)
        map:setCell(w - 1, i, 1)
    end
    return map
end

local function scene_params()
    return {
        px = 8.0,
        py = 8.0,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 16.0,
        screen_w = 160,
        screen_h = 100,
    }
end

-- @describe lurek.raycaster functions
describe("lurek.raycaster functions", function()
    -- @covers lurek.raycaster.applyLitShade
    it("applyLitShade scales rgb channels by the base shade", function()
        local r, g, b = lurek.raycaster.applyLitShade(0.5, 1.0, 0.8, 0.6)
        expect_near(0.5, r, 1e-5)
        expect_near(0.4, g, 1e-5)
        expect_near(0.3, b, 1e-5)
    end)

    -- @covers lurek.raycaster.distanceShade
    it("distanceShade darkens as distance approaches maxDistance", function()
        local near = lurek.raycaster.distanceShade(0, 10)
        local mid = lurek.raycaster.distanceShade(5, 10)
        local far = lurek.raycaster.distanceShade(9, 10)
        expect_true(near >= mid)
        expect_true(mid >= far)
    end)

    -- @covers lurek.raycaster.new
    it("new creates a raycaster map with requested dimensions", function()
        local map = lurek.raycaster.new(16, 12)
        expect_equal(16, map:width())
        expect_equal(12, map:height())
    end)

    -- @covers lurek.raycaster.newDoorManager
    it("newDoorManager returns an empty door manager", function()
        local doors = lurek.raycaster.newDoorManager()
        expect_equal(0, doors:count())
    end)

    -- @covers lurek.raycaster.newHeightMap
    it("newHeightMap returns a height map with default floor and ceiling", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        expect_near(0.0, hm:floorAt(0, 0), 1e-5)
        expect_near(1.0, hm:ceilingAt(0, 0), 1e-5)
    end)

    -- @covers lurek.raycaster.newMap
    it("newMap is an alias for raycaster construction", function()
        local map = lurek.raycaster.newMap(8, 6)
        expect_equal(8, map:width())
        expect_equal(6, map:height())
    end)

    -- @covers lurek.raycaster.newPointLight
    it("newPointLight stores the configured light values", function()
        local light = lurek.raycaster.newPointLight(10.0, 20.0, 0.2, 0.4, 0.6, 5.0, 0.8)
        local r, g, b = light:color()
        expect_near(10.0, light:x(), 1e-5)
        expect_near(20.0, light:y(), 1e-5)
        expect_near(0.2, r, 1e-5)
        expect_near(0.4, g, 1e-5)
        expect_near(0.6, b, 1e-5)
    end)

    -- @covers lurek.raycaster.newSpriteManager
    it("newSpriteManager returns an empty sprite manager", function()
        local sprites = lurek.raycaster.newSpriteManager()
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers lurek.raycaster.projectColumn
    it("projectColumn returns a positive projected height", function()
        local height = lurek.raycaster.projectColumn(5.0, math.pi / 3, 200)
        expect_type("number", height)
        expect_true(height > 0)
    end)
end)

-- @describe LDoorManager methods
describe("LDoorManager methods", function()
    -- @covers LDoorManager:addDoor
    it("addDoor registers a door and returns its index", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(3, 5, "horizontal", 1.0)
        expect_equal(0, id)
        expect_equal(1, doors:count())
    end)

    -- @covers LDoorManager:closeDoor
    it("closeDoor transitions an open door back toward closed state", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(1, 1, "vertical", 1.0)
        doors:openDoor(id)
        doors:update(1.1)
        doors:closeDoor(id)
        doors:update(0.5)
        expect_equal("closing", doors:getDoor(id).state)
    end)

    -- @covers LDoorManager:count
    it("count returns the number of registered doors", function()
        local doors = lurek.raycaster.newDoorManager()
        doors:addDoor(1, 1, "vertical", 1.0)
        doors:addDoor(2, 2, "horizontal", 1.0)
        expect_equal(2, doors:count())
    end)

    -- @covers LDoorManager:getDoor
    it("getDoor returns door state records", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(3, 3, "vertical", 1.0)
        local door = doors:getDoor(id)
        expect_equal(3, door.x)
        expect_equal(3, door.y)
        expect_equal("closed", door.state)
    end)

    -- @covers LDoorManager:openDoor
    it("openDoor begins the opening transition", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(1, 1, "vertical", 1.0)
        doors:openDoor(id)
        doors:update(0.5)
        expect_equal("opening", doors:getDoor(id).state)
    end)

    -- @covers LDoorManager:type
    it("type returns the door manager userdata name", function()
        local doors = lurek.raycaster.newDoorManager()
        expect_equal("LDoorManager", doors:type())
    end)

    -- @covers LDoorManager:typeOf
    it("typeOf accepts the door manager type name", function()
        local doors = lurek.raycaster.newDoorManager()
        expect_true(doors:typeOf("LDoorManager"))
    end)

    -- @covers LDoorManager:update
    it("update advances openAmount over time", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(1, 1, "vertical", 1.0)
        doors:openDoor(id)
        doors:update(0.5)
        expect_near(0.5, doors:getDoor(id).openAmount, 1e-5)
    end)
end)

-- @describe LHeightMap methods
describe("LHeightMap methods", function()
    -- @covers LHeightMap:ceilingAt
    it("ceilingAt returns the configured ceiling height", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setCeiling(1, 2, 0.75)
        expect_near(0.75, hm:ceilingAt(1, 2), 1e-5)
    end)

    -- @covers LHeightMap:floorAt
    it("floorAt returns the configured floor height", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setFloor(1, 2, 0.25)
        expect_near(0.25, hm:floorAt(1, 2), 1e-5)
    end)

    -- @covers LHeightMap:setCeiling
    it("setCeiling updates one cell", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setCeiling(0, 0, 1.5)
        expect_near(1.5, hm:ceilingAt(0, 0), 1e-5)
    end)

    -- @covers LHeightMap:setFloor
    it("setFloor updates one cell", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setFloor(0, 0, -0.3)
        expect_near(-0.3, hm:floorAt(0, 0), 1e-5)
    end)

    -- @covers LHeightMap:type
    it("type returns the height map userdata name", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        expect_equal("LHeightMap", hm:type())
    end)

    -- @covers LHeightMap:typeOf
    it("typeOf accepts the height map type name", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        expect_true(hm:typeOf("LHeightMap"))
    end)
end)

-- @describe LPointLight methods
describe("LPointLight methods", function()
    -- @covers LPointLight:color
    it("color returns the rgb channels", function()
        local light = lurek.raycaster.newPointLight(0, 0, 0.2, 0.4, 0.6, 5, 1)
        local r, g, b = light:color()
        expect_near(0.2, r, 1e-5)
        expect_near(0.4, g, 1e-5)
        expect_near(0.6, b, 1e-5)
    end)

    -- @covers LPointLight:intensity
    it("intensity returns the configured brightness", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 5, 0.8)
        expect_near(0.8, light:intensity(), 1e-5)
    end)

    -- @covers LPointLight:radius
    it("radius returns the configured falloff radius", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 5, 1)
        expect_near(5.0, light:radius(), 1e-5)
    end)

    -- @covers LPointLight:set
    it("set overwrites position color and intensity", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        light:set(7, 9, 0, 0, 1, 6, 2)
        local r, g, b = light:color()
        expect_near(7.0, light:x(), 1e-5)
        expect_near(9.0, light:y(), 1e-5)
        expect_near(0.0, r, 1e-5)
        expect_near(0.0, g, 1e-5)
        expect_near(1.0, b, 1e-5)
        expect_near(6.0, light:radius(), 1e-5)
        expect_near(2.0, light:intensity(), 1e-5)
    end)

    -- @covers LPointLight:type
    it("type returns the point light userdata name", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        expect_equal("LPointLight", light:type())
    end)

    -- @covers LPointLight:typeOf
    it("typeOf accepts the point light type name", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        expect_true(light:typeOf("LPointLight"))
    end)

    -- @covers LPointLight:x
    it("x returns the light world x coordinate", function()
        local light = lurek.raycaster.newPointLight(10, 20, 1, 1, 1, 1, 1)
        expect_near(10.0, light:x(), 1e-5)
    end)

    -- @covers LPointLight:y
    it("y returns the light world y coordinate", function()
        local light = lurek.raycaster.newPointLight(10, 20, 1, 1, 1, 1, 1)
        expect_near(20.0, light:y(), 1e-5)
    end)
end)

-- @describe LRaycaster methods
describe("LRaycaster methods", function()
    -- @covers LRaycaster:buildMinimapWindow
    it("buildMinimapWindow returns sampled tile records", function()
        local map = make_map(16, 16)
        map:setCell(4, 4, 1)
        local samples = map:buildMinimapWindow(5.5, 5.5, 3, 0.2, {})
        expect_type("table", samples)
        expect_true(#samples > 0)
        expect_type("number", samples[1].x)
    end)

    -- @covers LRaycaster:buildScene
    it("buildScene returns a quad count for a simple scene", function()
        local map = make_map(16, 16)
        local wall = load_texture()
        local count = map:buildScene(scene_params(), {}, {}, { [1] = wall })
        expect_type("number", count)
    end)

    -- @covers LRaycaster:buildSceneWithModels
    it("buildSceneWithModels returns a quad count without models", function()
        local map = make_map(16, 16)
        local count = map:buildSceneWithModels(scene_params(), nil, nil, nil, nil)
        expect_type("number", count)
    end)

    -- @covers LRaycaster:castFloorRow
    it("castFloorRow returns per-pixel uv tables", function()
        local map = make_map(5, 5)
        local uvs = map:castFloorRow(2.5, 2.5, 1.0, 0.0, 0.0, 0.66, 100)
        expect_type("table", uvs)
        if #uvs > 0 then
            expect_type("number", uvs[1].u)
            expect_type("number", uvs[1].v)
        end
    end)

    -- @covers LRaycaster:castRay
    it("castRay hits a wall placed directly ahead", function()
        local map = lurek.raycaster.new(10, 10)
        map:setCell(8, 4, 1)
        local hit = map:castRay(1.5, 4.5, 0.0, 20.0)
        expect_not_nil(hit)
        expect_equal(true, hit.hit)
        expect_equal(1, hit.cell_value)
    end)

    -- @covers LRaycaster:castRayMulti
    it("castRayMulti returns layered hits through transparent walls", function()
        local map = lurek.raycaster.new(16, 16)
        map:setCell(5, 8, 2)
        map:setCell(10, 8, 1)
        map:setWallAlpha(2, 0.5)
        local hits = map:castRayMulti(2, 8.5, 0, 20, 4)
        expect_type("table", hits)
        expect_true(#hits >= 1)
    end)

    -- @covers LRaycaster:castRays
    it("castRays returns exactly the requested number of ray tables", function()
        local map = lurek.raycaster.new(20, 20)
        local rays = map:castRays(10.0, 10.0, 0.0, math.pi / 2, 64, 30.0)
        expect_equal(64, #rays)
    end)

    -- @covers LRaycaster:castRaysFlat
    it("castRaysFlat returns flat numeric output", function()
        local map = make_map(8, 8)
        local flat = map:castRaysFlat(4.0, 4.0, 0.0, math.pi / 3, 5, 20.0)
        expect_equal(25, #flat)
        expect_type("number", flat[1])
    end)

    -- @covers LRaycaster:computeTileLight
    it("computeTileLight returns rgb and luma values in range", function()
        local map = lurek.raycaster.new(8, 8)
        local r, g, b, luma = map:computeTileLight(3, 3, 0.2, {
            { x = 3.5, y = 3.5, radius = 4.0, intensity = 8.0, color = { 1.0, 0.8, 0.5 } },
        })
        expect_true(r >= 0 and r <= 1)
        expect_true(g >= 0 and g <= 1)
        expect_true(b >= 0 and b <= 1)
        expect_true(luma >= 0 and luma <= 1)
    end)

    -- @covers LRaycaster:drawCameraSweep
    it("drawCameraSweep returns image data", function()
        local map = lurek.raycaster.new(8, 8)
        local img = map:drawCameraSweep(2.0, 2.0, 1.0, 20.0, 4, 16, 16)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawDepthMap
    it("drawDepthMap returns image data", function()
        local map = lurek.raycaster.new(8, 8)
        local img = map:drawDepthMap(1.0, 1.0, 0.0, 1.0, 8, 32, 16, 20.0)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawLineOfSight
    it("drawLineOfSight returns image data", function()
        local map = lurek.raycaster.new(8, 8)
        local img = map:drawLineOfSight(1.0, 1.0, 6.0, 6.0, 4)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawTopDown
    it("drawTopDown returns image data", function()
        local map = make_map(8, 8)
        local img = map:drawTopDown(4.5, 4.5, 0, 16)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawView
    it("drawView returns image data of the requested size", function()
        local map = make_map(16, 16)
        local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 100)
        expect_equal(320, img:getWidth())
        expect_equal(200, img:getHeight())
    end)

    -- @covers LRaycaster:extractMinimap
    it("extractMinimap returns a minimap image", function()
        local map = make_map(16, 16)
        local img = map:extractMinimap(8, 8, 0, 4, 8)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:getCeilingTextureCell
    it("getCeilingTextureCell returns nil when no override is set", function()
        local map = lurek.raycaster.new(8, 8)
        expect_nil(map:getCeilingTextureCell(0, 0))
    end)

    -- @covers LRaycaster:getCell
    it("getCell reads back values written to the grid", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(1, 2, 3)
        expect_equal(3, map:getCell(1, 2))
    end)

    -- @covers LRaycaster:getFloorTextureCell
    it("getFloorTextureCell returns nil when no override is set", function()
        local map = lurek.raycaster.new(8, 8)
        expect_nil(map:getFloorTextureCell(0, 0))
    end)

    -- @covers LRaycaster:getLoweredFloorCell
    it("getLoweredFloorCell returns stored lowered-floor options", function()
        local map = lurek.raycaster.new(8, 8)
        map:setLoweredFloorCell(2, 2, { texture = 1, depth = 0.35, blocked = true })
        local cell = map:getLoweredFloorCell(2, 2)
        expect_type("table", cell)
        expect_equal(1, cell.texture)
        expect_equal(true, cell.blocked)
    end)

    -- @covers LRaycaster:getWallAlpha
    it("getWallAlpha returns the configured transparency", function()
        local map = lurek.raycaster.new(4, 4)
        map:setWallAlpha(2, 0.5)
        expect_near(0.5, map:getWallAlpha(2), 1e-5)
    end)

    -- @covers LRaycaster:gridMove
    it("gridMove moves forward along the cardinal direction", function()
        local map = make_map(8, 8)
        local nx, ny, moved = map:gridMove(4.5, 4.5, 2, "forward", 1.0)
        expect_equal(true, moved)
        expect_type("number", nx)
        expect_type("number", ny)
    end)

    -- @covers LRaycaster:height
    it("height returns the map height in cells", function()
        local map = lurek.raycaster.new(5, 3)
        expect_equal(3, map:height())
    end)

    -- @covers LRaycaster:isBlocked
    it("isBlocked reports non-zero wall cells as blocked", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(0, 0, 1)
        expect_true(map:isBlocked(0, 0))
        expect_false(map:isBlocked(1, 1))
    end)

    -- @covers LRaycaster:isWalkBlocked
    it("isWalkBlocked respects lowered floor blocking flags", function()
        local map = lurek.raycaster.new(8, 8)
        map:setLoweredFloorCell(3, 3, { texture = load_texture(), depth = 0.3, blocked = true })
        expect_true(map:isWalkBlocked(3, 3))
    end)

    -- @covers LRaycaster:lineOfSight
    it("lineOfSight returns false when a wall blocks the path", function()
        local map = lurek.raycaster.new(10, 10)
        map:setCell(5, 5, 1)
        expect_false(map:lineOfSight(1.0, 5.5, 9.0, 5.5))
    end)

    -- @covers LRaycaster:projectSprite
    it("projectSprite returns projection fields for a visible sprite", function()
        local map = lurek.raycaster.new(10, 10)
        local sp = map:projectSprite(5.0, 5.0, 1.0, 5.0, 0.0, math.pi / 2, 320.0)
        expect_type("table", sp)
        expect_type("number", sp.screen_x)
        expect_type("number", sp.scale)
        expect_type("number", sp.distance)
        expect_type("boolean", sp.visible)
    end)

    -- @covers LRaycaster:revealCellsFromRays
    it("revealCellsFromRays returns cell records with coordinates", function()
        local map = lurek.raycaster.new(16, 16)
        local cells = map:revealCellsFromRays(8.5, 8.5, 0.0, math.pi / 3, 8, 8.0, 0.25)
        expect_type("table", cells)
        if #cells > 0 then
            expect_type("number", cells[1].x)
            expect_type("number", cells[1].y)
        end
    end)

    -- @covers LRaycaster:setCeilingTextureCell
    it("setCeilingTextureCell stores and clears per-cell texture overrides", function()
        local map = lurek.raycaster.new(8, 8)
        map:setCeilingTextureCell(3, 3, 2)
        expect_equal(2, map:getCeilingTextureCell(3, 3))
        map:setCeilingTextureCell(3, 3, nil)
        expect_nil(map:getCeilingTextureCell(3, 3))
    end)

    -- @covers LRaycaster:setCell
    it("setCell writes an integer wall value to one cell", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(0, 0, 7)
        expect_equal(7, map:getCell(0, 0))
    end)

    -- @covers LRaycaster:setCells
    it("setCells fills the grid from a flat Lua table", function()
        local map = lurek.raycaster.new(2, 2)
        map:setCells({ 1, 2, 3, 4 })
        expect_equal(4, map:getCell(1, 1))
    end)

    -- @covers LRaycaster:setFloorTextureCell
    it("setFloorTextureCell stores and clears per-cell texture overrides", function()
        local map = lurek.raycaster.new(8, 8)
        map:setFloorTextureCell(1, 1, 1)
        expect_equal(1, map:getFloorTextureCell(1, 1))
        map:setFloorTextureCell(1, 1, nil)
        expect_nil(map:getFloorTextureCell(1, 1))
    end)

    -- @covers LRaycaster:setLoweredFloorCell
    it("setLoweredFloorCell stores lowered-floor metadata", function()
        local map = lurek.raycaster.new(8, 8)
        map:setLoweredFloorCell(4, 4, {
            texture = load_texture(),
            depth = 0.3,
            blocked = false,
        })
        local cell = map:getLoweredFloorCell(4, 4)
        expect_near(0.3, cell.depth, 1e-5)
    end)

    -- @covers LRaycaster:setWallAlpha
    it("setWallAlpha changes the transparency for a wall type", function()
        local map = lurek.raycaster.new(4, 4)
        map:setWallAlpha(1, 0.75)
        expect_near(0.75, map:getWallAlpha(1), 1e-5)
    end)

    -- @covers LRaycaster:tryMove
    it("tryMove advances through empty space", function()
        local map = lurek.raycaster.new(6, 6)
        local nx, ny, moved = map:tryMove(1.5, 1.5, 1.0, 0.0)
        expect_equal(true, moved)
        expect_near(2.5, nx, 0.001)
        expect_near(1.5, ny, 0.001)
    end)

    -- @covers LRaycaster:type
    it("type returns the raycaster userdata name", function()
        local map = lurek.raycaster.new(8, 8)
        expect_equal("LRaycaster", map:type())
    end)

    -- @covers LRaycaster:typeOf
    it("typeOf accepts the raycaster type name", function()
        local map = lurek.raycaster.new(8, 8)
        expect_true(map:typeOf("LRaycaster"))
    end)

    -- @covers LRaycaster:width
    it("width returns the map width in cells", function()
        local map = lurek.raycaster.new(5, 3)
        expect_equal(5, map:width())
    end)
end)

-- @describe LSpriteManager methods
describe("LSpriteManager methods", function()
    -- @covers LSpriteManager:add
    it("add returns unique numeric sprite ids", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local a = sprites:add(1, 1, "a.png")
        local b = sprites:add(2, 2, "b.png")
        expect_type("number", a)
        expect_true(a ~= b)
    end)

    -- @covers LSpriteManager:clear
    it("clear removes all registered sprites", function()
        local sprites = lurek.raycaster.newSpriteManager()
        sprites:add(1, 1, "a.png")
        sprites:add(2, 2, "b.png")
        sprites:clear()
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers LSpriteManager:remove
    it("remove deletes a sprite by id", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(1, 1, "a.png")
        sprites:remove(id)
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers LSpriteManager:setPosition
    it("setPosition updates projected distance from the camera", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(0, 0, "spr")
        sprites:setPosition(id, 3, 4)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_near(5.0, proj[1].distance, 0.01)
    end)

    -- @covers LSpriteManager:setVisible
    it("setVisible toggles sprite participation in projection", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(5, 5, "ghost.png")
        sprites:setVisible(id, false)
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers LSpriteManager:sortAndProject
    it("sortAndProject returns far sprites before near sprites", function()
        local sprites = lurek.raycaster.newSpriteManager()
        sprites:add(2, 0, "near.png")
        sprites:add(10, 0, "far.png")
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_equal(2, #proj)
        expect_equal("far.png", proj[1].texture)
        expect_equal("near.png", proj[2].texture)
    end)

    -- @covers LSpriteManager:type
    it("type returns the sprite manager userdata name", function()
        local sprites = lurek.raycaster.newSpriteManager()
        expect_equal("LSpriteManager", sprites:type())
    end)

    -- @covers LSpriteManager:typeOf
    it("typeOf accepts the sprite manager type name", function()
        local sprites = lurek.raycaster.newSpriteManager()
        expect_true(sprites:typeOf("LSpriteManager"))
    end)
end)

test_summary()
