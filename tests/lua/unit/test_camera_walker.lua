-- Tests for lurek.camera walker functionality with tile-grid movement and collision detection.
-- Covers position management, tile-based navigation, and camera following behavior.

-- @describe Camera Walker Tests

local lurek = require("lurek")
local function make_test_tilemap()
    -- Create a simple tilemap for testing walker collision
    local map = lurek.tilemap.new({ width = 10, height = 10, tile_w = 32, tile_h = 32 })
    -- Mark a solid block in the middle
    local chunk = lurek.tilemap.newChunk(10, 10)
    for x = 1, 10 do
        for y = 1, 10 do
            -- Set a wall at row 5 (1-based)
            if y == 5 then
                chunk:set(x - 1, y - 1, 1, 1, 1, false)  -- solid
            else
                chunk:set(x - 1, y - 1, 1, 1, 1, true)   -- passable
            end
        end
    end
    map:addChunk(1, 1, chunk)
    return map
end
-- -- newWalker --
-- @covers lurek.camera
it("creates a walker from a tilemap", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, {
        layer = 1,
        tile_w = 32,
        tile_h = 32,
        body_w = 24,
        body_h = 24,
        speed = 100,
        x = 50,
        y = 50
    })
    assert_equal("LCameraWalker", walker:type())
end)
-- -- newWalker --
-- @covers lurek.camera
it("creates walker with default options", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map)
    assert_true(walker ~= nil)
    assert_equal("LCameraWalker", walker:type())
end)
-- -- setPosition --
-- @covers lurek.camera
it("sets walker world position", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map)
    walker:setPosition(100, 150)
    local x, y = walker:getPosition()
    assert_near(x, 100, 0.1)
    assert_near(y, 150, 0.1)
end)
-- -- getPosition --
-- @covers LCameraWalker:getPosition
it("returns walker world position", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 64, y = 96 })
    local x, y = walker:getPosition()
    assert_near(x, 64, 0.1)
    assert_near(y, 96, 0.1)
end)
-- -- setTilePosition --
-- @covers lurek.camera
it("sets walker tile position (1-based)", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32 })
    walker:setTilePosition(3, 2)
    local tx, ty = walker:getTilePosition()
    assert_equal(3, tx)
    assert_equal(2, ty)
end)
-- -- getTilePosition --
-- @covers LCameraWalker:getTilePosition
it("returns walker tile position (1-based)", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { tile_w = 32, tile_h = 32, x = 96, y = 64 })
    local tx, ty = walker:getTilePosition()
    assert_equal(4, tx)
    assert_equal(3, ty)
end)
-- -- moveUp --
-- @covers lurek.camera
it("moves walker up (negative Y)", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 100, y = 100, speed = 50 })
    walker:moveUp(1.0)  -- Move for 1 second at 50 pix/sec
    local _, y = walker:getPosition()
    assert_true(y < 100)
end)
-- -- moveDown --
-- @covers lurek.camera
it("moves walker down (positive Y)", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 100, y = 100, speed = 50 })
    walker:moveDown(1.0)
    local _, y = walker:getPosition()
    assert_true(y > 100)
end)
-- -- moveLeft --
-- @covers lurek.camera
it("moves walker left (negative X)", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 100, y = 100, speed = 50 })
    walker:moveLeft(1.0)
    local x, _ = walker:getPosition()
    assert_true(x < 100)
end)
-- -- moveRight --
-- @covers lurek.camera
it("moves walker right (positive X)", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 100, y = 100, speed = 50 })
    walker:moveRight(1.0)
    local x, _ = walker:getPosition()
    assert_true(x > 100)
end)
-- -- update --
-- @covers lurek.camera
it("updates walker camera target", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 50, y = 50 })
    walker:setPosition(100, 100)
    walker:update(0.016)  -- Update at 60 FPS
    local x, y = walker:getPosition()
    assert_near(x, 100, 0.1)
    assert_near(y, 100, 0.1)
end)
-- -- getCamera --
-- @covers LCameraWalker:getCamera
it("returns associated camera", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map)
    local cam = walker:getCamera()
    assert_equal("LCamera", cam:type())
end)
-- -- type --
-- @covers lurek.camera
it("reports correct type name", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map)
    assert_equal("LCameraWalker", walker:type())
end)
-- -- typeOf --
-- @covers lurek.camera
it("checks type via typeOf", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map)
    assert_true(walker:typeOf("LCameraWalker"))
    assert_true(walker:typeOf("LObject"))
    assert_false(walker:typeOf("LCamera"))
end)
-- -- moveUp --
-- @covers lurek.camera
it("respects small time delta for movement", function()
    local map = make_test_tilemap()
    local walker = lurek.camera.newWalker(map, { x = 100, y = 100, speed = 100 })
    walker:moveUp(0.01)  -- Move for 10ms at 100 pix/sec = 1 pixel
    local _, y = walker:getPosition()
    assert_near(y, 99, 2)  -- Should be roughly 1 pixel down
end)
test_summary()
