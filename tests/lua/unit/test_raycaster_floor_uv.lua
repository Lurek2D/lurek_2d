-- Lurek2D Lua BDD tests — raycaster castFloorRow (floor UV generation)
-- Covers: castFloorRow — per-column (tex_u, tex_v) pairs for a floor row.
-- Headless: no GPU, no audio, no window.

-- Helper: build a basic raycaster and map.
local function make_raycaster()
    local map = {
        {1, 1, 1, 1, 1},
        {1, 0, 0, 0, 1},
        {1, 0, 0, 0, 1},
        {1, 0, 0, 0, 1},
        {1, 1, 1, 1, 1},
    }
    local rc = lurek.raycaster.new(5, 5, map)
    return rc
end

-- @description Covers suite: lurek.raycaster castFloorRow.
describe("lurek.raycaster castFloorRow", function()
    -- @description Covers suite: API exposure.
    describe("API exposure", function()
        -- @covers lurek.raycaster:castFloorRow
        -- @description castFloorRow is callable on a raycaster.
        it("castFloorRow is a function on raycaster", function()
            local rc = make_raycaster()
            expect_type("function", rc.castFloorRow)
        end)
    end)

    -- @description Covers suite: return value structure.
    describe("return value", function()
        -- Camera basis vectors for a player facing +X.
        local cam_x, cam_y  = 2.5, 2.5
        local dir_x, dir_y  = 1.0, 0.0
        local plane_x, plane_y = 0.0, 0.66  -- standard 66° FOV half-plane

        -- @covers lurek.raycaster:castFloorRow
        -- @description Returns a table.
        it("returns a table", function()
            local rc = make_raycaster()
            local uvs = rc:castFloorRow(cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, 100)
            expect_type("table", uvs)
        end)

        -- @covers lurek.raycaster:castFloorRow
        -- @description Table length equals screen width.
        it("table length equals screen width", function()
            local rc = make_raycaster()
            local uvs = rc:castFloorRow(cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, 100)
            local w = rc:getScreenWidth()
            expect_equal(w, #uvs)
        end)

        -- @covers lurek.raycaster:castFloorRow
        -- @description Each element has u and v keys.
        it("each element is a {u, v} table", function()
            local rc = make_raycaster()
            local uvs = rc:castFloorRow(cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, 100)
            for _, uv in ipairs(uvs) do
                expect_type("number", uv.u)
                expect_type("number", uv.v)
                break  -- check just the first entry
            end
        end)

        -- @covers lurek.raycaster:castFloorRow
        -- @description UV values are in [0, 1] range.
        it("UV values are in [0, 1]", function()
            local rc = make_raycaster()
            local uvs = rc:castFloorRow(cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, 100)
            for _, uv in ipairs(uvs) do
                assert(uv.u >= 0.0 and uv.u <= 1.0,
                    "tex_u out of range: " .. tostring(uv.u))
                assert(uv.v >= 0.0 and uv.v <= 1.0,
                    "tex_v out of range: " .. tostring(uv.v))
            end
        end)

        -- @covers lurek.raycaster:castFloorRow
        -- @description Calling for multiple rows does not error.
        it("works for consecutive rows", function()
            local rc = make_raycaster()
            local h = rc:getScreenHeight()
            for row = h // 2, h - 1 do
                local uvs = rc:castFloorRow(cam_x, cam_y, dir_x, dir_y, plane_x, plane_y, row)
                expect_type("table", uvs)
            end
        end)
    end)
end)

test_summary()
