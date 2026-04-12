-- Lurek2D Stress Test: Camera Transform Throughput
-- Measures camera position, zoom, and rotation update performance.

-- @description Covers suite: stress: camera position updates.
describe("stress: camera position updates", function()
    -- @covers lurek.camera.newCamera
    -- @covers Camera:setPosition
    -- @stress Times 100000 position changes on one camera with randomized coordinates.
    -- @description Stresses setter-call throughput by reusing a single camera and hammering position updates in a measured loop with changing screen-space values.
    it("100000 camera setPosition calls in <5s", function()
        local cam   = lurek.camera.newCamera()
        local COUNT = 100000

        local elapsed = measure("camera:setPosition x" .. COUNT, COUNT, function()
            cam:setPosition(math.random() * 1920, math.random() * 1080)
        end)

        expect_true(elapsed < 5.0, "camera position budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.camera.newCamera
    -- @covers Camera:setZoom
    -- @stress Times 100000 zoom changes on one camera with randomized scalar values.
    -- @description Stresses zoom update throughput by repeatedly mutating one camera's zoom factor in a tight measured loop.
    it("100000 camera zoom updates in <5s", function()
        local cam   = lurek.camera.newCamera()
        local COUNT = 100000

        local elapsed = measure("camera:setZoom x" .. COUNT, COUNT, function()
            cam:setZoom(0.5 + math.random())
        end)

        expect_true(elapsed < 5.0, "camera zoom budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.camera.newCamera
    -- @covers Camera:setPosition
    -- @covers Camera:setZoom
    -- @stress Allocates 100 cameras and performs 1000 combined position-plus-zoom updates on each.
    -- @description Stresses bulk camera mutation by iterating over a camera pool and changing both transform properties inside a nested update loop.
    it("100 cameras Ă— 1000 updates each in <5s", function()
        local CAMS    = 100
        local UPDATES = 1000
        local cams    = {}

        for _ = 1, CAMS do
            cams[#cams + 1] = lurek.camera.newCamera()
        end

        local start = os.clock()
        for _ = 1, UPDATES do
            for _, cam in ipairs(cams) do
                cam:setPosition(math.random() * 1920, math.random() * 1080)
                cam:setZoom(0.5 + math.random())
            end
        end
        local elapsed = os.clock() - start
        print(string.format("[STRESS] 100 cameras Ă— 1000 updates: %.4fs (%.0f updates/sec)",
            elapsed, (CAMS * UPDATES) / elapsed))

        expect_true(elapsed < 5.0, "multi-camera budget: " .. elapsed .. "s")
    end)
end)

test_summary()
