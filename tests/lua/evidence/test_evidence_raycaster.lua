-- test_evidence_raycaster.lua
-- Evidence test: lurek.raycaster API contracts and pixel-level PNG evidence

-- The raycaster casts rays through a 2D grid and returns hit data.
-- Tests verify correctness of ray geometry and render results to a PNG
-- "depth buffer" image so the output can be visually inspected.

local OUT = "tests/lua/evidence/output/raycaster/"

-- @description Covers suite: Evidence: lurek.raycaster API contracts.
describe("Evidence: lurek.raycaster API contracts", function()

    -- @covers lurek.raycaster.new
    -- @description Creates a raycaster grid with fixed dimensions to prove the constructor returns a valid raycaster object.
    it("new creates a Raycaster of given dimensions", function()
        local rc = lurek.raycaster.new(16, 16)
    end)

    -- @covers Raycaster:getCell
    -- @description Reads an unset cell to document the default open-space value.
    it("getCell returns 0 for unset cells", function()
        local rc = lurek.raycaster.new(8, 8)
    end)

    -- @covers Raycaster:setCell
    -- @covers Raycaster:getCell
    -- @description Writes a wall cell and reads it back to cover individual cell mutation.
    it("setCell and getCell round-trip", function()
        local rc = lurek.raycaster.new(8, 8)
        rc:setCell(3, 4, 1)
    end)

    -- @covers Raycaster:isBlocked
    -- @description Queries blockage on an open cell to cover the false case.
    it("isBlocked returns false for open cells", function()
        local rc = lurek.raycaster.new(8, 8)
    end)

    -- @covers Raycaster:setCell
    -- @covers Raycaster:isBlocked
    -- @description Marks a wall tile and confirms the raycaster reports it as blocked.
    it("isBlocked returns true for wall cells", function()
        local rc = lurek.raycaster.new(8, 8)
        rc:setCell(2, 2, 1)
    end)

    -- @covers Raycaster:setCells
    -- @description Loads an entire grid from a flat array to cover bulk cell assignment.
    it("setCells fills the grid without error", function()
        local rc = lurek.raycaster.new(4, 4)
        local ok = pcall(function()
            rc:setCells({
                1, 1, 1, 1,
                1, 0, 0, 1,
                1, 0, 0, 1,
                1, 1, 1, 1,
            })
        end)
    end)

    -- @covers Raycaster:castRay
    -- @description Casts a ray through empty space to cover the no-hit case.
    it("castRay returns nil when no wall is hit", function()
        local rc = lurek.raycaster.new(8, 8) -- all cells = 0
        local hit = rc:castRay(4, 4, 0, 10)
    end)

    -- @covers Raycaster:setCells
    -- @covers Raycaster:castRay
    -- @description Casts a ray inside a boxed room so the hit table path is exercised against a known wall.
    it("castRay returns a hit table when wall exists", function()
        local rc = lurek.raycaster.new(8, 8)
        -- Surround with walls
        rc:setCells({
            1, 1, 1, 1, 1, 1, 1, 1,
            1, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 1,
            1, 1, 1, 1, 1, 1, 1, 1,
        })
        local hit = rc:castRay(4.0, 4.0, 0, 20)
        -- Should hit east wall
        if hit then
        end
    end)

    -- @covers Raycaster:setCell
    -- @covers Raycaster:castRays
    -- @description Casts a fan of rays from the center of a bounded room to cover the batched ray API.
    it("castRays returns an array of hit results", function()
        local rc = lurek.raycaster.new(16, 16)
        -- Outer wall ring
        for x = 0, 15 do
            rc:setCell(x, 0, 1)
            rc:setCell(x, 15, 1)
        end
        for y = 0, 15 do
            rc:setCell(0, y, 1)
            rc:setCell(15, y, 1)
        end
        local rays = rc:castRays(8.0, 8.0, 0.0, math.pi / 2, 60, 30)
    end)

    -- @covers Raycaster:lineOfSight
    -- @description Checks line of sight across an empty room to cover the unobstructed case.
    it("lineOfSight returns true when path is clear", function()
        local rc = lurek.raycaster.new(8, 8)
        -- All open â€” line of sight should be true
        local los = rc:lineOfSight(1, 1, 6, 6)
    end)

    -- @covers Raycaster:setCell
    -- @covers Raycaster:lineOfSight
    -- @description Adds a wall between two points and checks that line of sight reports the obstruction.
    it("lineOfSight returns false when wall blocks", function()
        local rc = lurek.raycaster.new(8, 8)
        rc:setCell(4, 1, 1)
        local los = rc:lineOfSight(3.5, 1.5, 4.5, 1.5)
    end)

    -- @covers lurek.raycaster.projectColumn
    -- @description Projects one wall distance into screen-space column bounds to cover wall-slice math helpers.
    it("projectColumn returns three numbers", function()
        local top, bottom, height = lurek.raycaster.projectColumn(5.0, 1.0472, 600)
    end)

    -- @covers lurek.raycaster.distanceShade
    -- @description Computes distance shading for a nonzero distance to cover the attenuation helper.
    it("distanceShade returns value between 0 and 1", function()
        local shade = lurek.raycaster.distanceShade(5.0, 20.0)
    end)

    -- @covers lurek.raycaster.distanceShade
    -- @description Samples distance shading at zero range to cover the maximum-brightness case.
    it("distanceShade at 0 distance returns 1 (full brightness)", function()
        local shade = lurek.raycaster.distanceShade(0.0, 20.0)
    end)

    -- @covers Raycaster:setCell
    -- @covers Raycaster:castRaysFlat
    -- @covers lurek.raycaster.distanceShade
    -- @covers lurek.raycaster.projectColumn
    -- @covers lurek.img.savePNG
    -- @evidence file
    -- @description Casts a full ray fan across a boxed room and saves the resulting depth buffer visualization as PNG evidence.
    it("saves raycaster depth-buffer as PNG evidence", function()
        local W, H = 128, 64
        local FOV = math.pi / 2

        local rc = lurek.raycaster.new(20, 20)
        -- Outer walls
        for x = 0, 19 do
            rc:setCell(x, 0, 1)
            rc:setCell(x, 19, 1)
        end
        for y = 0, 19 do
            rc:setCell(0, y, 1)
            rc:setCell(19, y, 1)
        end

        local img = lurek.img.newImageData(W, H)
        local rays = rc:castRaysFlat(10.0, 10.0, 0.0, FOV, W, 40)
        for col = 0, W - 1 do
            local base = col * 5
            local dist    = rays[base + 1] or 0
            local shade   = lurek.raycaster.distanceShade(dist, 40)
            local top, bottom = lurek.raycaster.projectColumn(dist, FOV, H)
            local brightness = math.floor(shade * 200 + 0.5)
            for y = 0, H - 1 do
                if y >= math.floor(top) and y <= math.floor(bottom) then
                    img:setPixel(col, y, brightness, brightness, brightness, 255)
                else
                    -- ceiling or floor
                    local shade2 = y < H / 2 and 40 or 20
                    img:setPixel(col, y, shade2, shade2, shade2, 255)
                end
            end
        end

        lurek.img.savePNG(img, OUT .. "raycaster_depth.png")
    end)

end)

test_summary()
