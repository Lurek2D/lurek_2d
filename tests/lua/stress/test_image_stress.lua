-- Lurek2D Stress Test: Image Operations
-- Measures image creation and pixel operation throughput.

-- @description Covers suite: stress: image creation throughput.
describe("stress: image creation throughput", function()
    -- @covers lurek.image.newImage
    -- @stress Allocates 100 separate 64x64 image objects in a measured loop.
    -- @description Stresses image-object construction throughput by repeatedly creating small image buffers and retaining them in Lua memory.
    xit("create 100 images (64     64) without error: <10s", function()
        local COUNT  = 100
        local images = {}

        local elapsed = measure("image.newImage 64x64 x" .. COUNT, COUNT, function()
            local img = lurek.image.newImage(64, 64)
            images[#images + 1] = img
        end)

        expect_true(elapsed < 10.0, "image creation budget: " .. elapsed .. "s")
        expect_equal(COUNT, #images, "all images created")
    end)

    -- @covers lurek.image.newImage
    -- @covers Image:getPixel
    -- @stress Performs 10000 random pixel reads against one 64x64 image.
    -- @description Stresses read throughput by repeatedly sampling random coordinates from the same small image buffer.
    xit("pixel read 10000 times on single image: <5s", function()
        local img   = lurek.image.newImage(64, 64)
        local COUNT = 10000

        local elapsed = measure("image:getPixel x" .. COUNT, COUNT, function()
            local _ = img:getPixel(math.random(0, 63), math.random(0, 63))
        end)

        expect_true(elapsed < 5.0, "pixel read budget: " .. elapsed .. "s")
    end)

    -- @covers lurek.image.newImage
    -- @covers Image:setPixel
    -- @stress Performs 10000 random pixel writes against one 64x64 image.
    -- @description Stresses write throughput by mutating random pixels with changing RGBA values in a tight measured loop.
    xit("pixel write 10000 times on single image: <5s", function()
        local img   = lurek.image.newImage(64, 64)
        local COUNT = 10000

        local elapsed = measure("image:setPixel x" .. COUNT, COUNT, function()
            img:setPixel(math.random(0, 63), math.random(0, 63),
                math.random(), math.random(), math.random(), 1.0)
        end)

        expect_true(elapsed < 5.0, "pixel write budget: " .. elapsed .. "s")
    end)
end)

test_summary()
