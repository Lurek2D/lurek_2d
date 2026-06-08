-- Lurek2D Library Camera Follow Walker Tests
-- @testCategory library

local CameraFollowWalker = require("library.camera_follow_walker")

local function build_map()
    local map = {
        tw = 32,
        th = 32,
        solids = {
            ["3:2"] = true,
        },
    }

    function map:getTileDimensions()
        return self.tw, self.th
    end

    function map:tileToWorld(tx, ty)
        return (tx - 1) * self.tw, (ty - 1) * self.th
    end

    function map:worldToTile(wx, wy)
        return math.floor(wx / self.tw) + 1, math.floor(wy / self.th) + 1
    end

    function map:rectOverlapsSolid(_, x, y, w, h)
        local tx1 = math.floor(x / self.tw) + 1
        local ty1 = math.floor(y / self.th) + 1
        local tx2 = math.floor((x + w - 0.001) / self.tw) + 1
        local ty2 = math.floor((y + h - 0.001) / self.th) + 1

        for ty = ty1, ty2 do
            for tx = tx1, tx2 do
                if self.solids[tx .. ":" .. ty] then
                    return true
                end
            end
        end

        return false
    end

    return map
end

-- @describe camera_follow_walker library
describe("camera_follow_walker library", function()
    -- @library lurek.library_camera_follow_walker
    it("creates helper and resolves tile position", function()
        local map = build_map()
        local helper = CameraFollowWalker.new({ map = map, layer = 1, speed = 32 })

        helper:setTilePosition(2, 2)
        helper:update(0.016, false)

        local tx, ty = helper:getTilePosition()
        expect_equal(tx, 2, "tile x must match setTilePosition")
        expect_equal(ty, 2, "tile y must match setTilePosition")

        local cx, cy = helper:getCameraPosition()
        expect_not_nil(cx, "camera x must be returned")
        expect_not_nil(cy, "camera y must be returned")
    end)

    -- @library lurek.library_camera_follow_walker
    it("blocks movement when rectOverlapsSolid reports collision", function()
        local map = build_map()
        local helper = CameraFollowWalker.new({ map = map, layer = 1, speed = 32 })

        helper:setTilePosition(2, 2)
        local moved = helper:move(1, 0, 1.0)

        expect_false(moved, "move into solid tile must be blocked")

        local tx, ty = helper:getTilePosition()
        expect_equal(tx, 2, "blocked move must keep tile x")
        expect_equal(ty, 2, "blocked move must keep tile y")
    end)

    -- @library lurek.library_camera_follow_walker
    it("moves through empty tiles", function()
        local map = build_map()
        local helper = CameraFollowWalker.new({ map = map, layer = 1, speed = 32 })

        helper:setTilePosition(2, 2)
        local moved = helper:move(0, 1, 1.0)

        expect_true(moved, "move into empty tile must succeed")

        local tx, ty = helper:getTilePosition()
        expect_equal(tx, 2, "tile x should stay on same column")
        expect_equal(ty, 3, "tile y should move to next row")
    end)
end)
test_summary()
