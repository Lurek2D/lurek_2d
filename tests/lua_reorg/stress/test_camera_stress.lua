-- Lurek2D Stress Test: Camera Transform Throughput
-- Measures camera position, zoom, and rotation update performance.

local function new_camera()
    return lurek.camera.newCamera()
end

local function measure_set_position_updates(count)
    local cam = new_camera()
    return measure("camera:setPosition x" .. count, count, function()
        cam:setPosition(math.random() * 1920, math.random() * 1080)
    end)
end

local function measure_set_zoom_updates(count)
    local cam = new_camera()
    return measure("camera:setZoom x" .. count, count, function()
        cam:setZoom(0.5 + math.random())
    end)
end

-- @describe stress: camera position updates
describe("stress: camera position updates", function()
    -- @stress LCamera:setPosition
    it("100000 camera setPosition calls in <5s", function()
        local count = 100000
        local elapsed = measure_set_position_updates(count)
        expect_true(elapsed < 5.0, "camera position budget: " .. elapsed .. "s")
    end)

    -- @stress LCamera:setZoom
    it("100000 camera zoom updates in <5s", function()
        local count = 100000
        local elapsed = measure_set_zoom_updates(count)
        expect_true(elapsed < 5.0, "camera zoom budget: " .. elapsed .. "s")
    end)

    -- @stress LCamera:getPosition
    it("100 cameras       1000 updates each in <5s", function()
        local cams = {}
        local camera_count = 100
        local updates = 1000

        for _ = 1, camera_count do
            cams[#cams + 1] = lurek.camera.newCamera()
        end

        local start = os.clock()
        local last_x, last_y = 0.0, 0.0
        for _ = 1, updates do
            for _, cam in ipairs(cams) do
                cam:setPosition(math.random() * 1920, math.random() * 1080)
                cam:setZoom(0.5 + math.random())
                last_x, last_y = cam:getPosition()
            end
        end
        local elapsed = os.clock() - start
        print(string.format("[STRESS] 100 cameras       1000 updates: %.4fs (%.0f updates/sec)",
            elapsed, (camera_count * updates) / elapsed))

        expect_true(elapsed < 5.0, "multi-camera budget: " .. elapsed .. "s")
        expect_true(type(last_x) == "number" and type(last_y) == "number", "camera getPosition remains callable under load")
    end)
end)
test_summary()
