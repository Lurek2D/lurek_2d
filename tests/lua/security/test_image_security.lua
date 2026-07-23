-- Adversarial coverage for bounded image allocation, raw buffers, and transactional pixel callbacks.

local function callback_fixture()
    local image = lurek.image.newImageData(2, 1)
    image:setPixel(0, 0, 10, 20, 30, 40)
    image:setPixel(1, 0, 50, 60, 70, 80)
    return image
end

local function expect_callback_fixture_unchanged(image)
    local r, g, b, a = image:getPixel(0, 0)
    expect_equal(10, r)
    expect_equal(20, g)
    expect_equal(30, b)
    expect_equal(40, a)
end

local function layer_fixture()
    local layered = lurek.image.newLayeredImage(1, 1)
    layered:addLayer("only")
    return layered
end

-- @describe image hostile dimensions and bytes
describe("image hostile dimensions and bytes", function()
    -- @security lurek.image.newImageData
    it("rejects dimensions beyond the shared image budget", function()
        expect_error(function()
            lurek.image.newImageData(16385, 1)
        end)
        expect_error(function()
            lurek.image.newImageData(8192, 8193)
        end)
    end)

    -- @security lurek.image.newImageDataFromBytes
    it("rejects raw byte lengths that do not match bounded dimensions", function()
        expect_error(function()
            lurek.image.newImageDataFromBytes(16, 16, "short")
        end)
        expect_error(function()
            lurek.image.newImageDataFromBytes(16385, 1, "")
        end)
    end)
end)

-- @describe image hostile callbacks
describe("image hostile callbacks", function()
    -- @security LImageData:mapPixel
    it("preserves the original image when a pixel callback fails", function()
        local image = callback_fixture()
        expect_error(function()
            image:mapPixel(function(x, y, r, g, b, a)
                if x == 1 then error("stop") end
                return r + 1, g, b, a
            end)
        end)
        expect_callback_fixture_unchanged(image)
    end)

    -- @security LImageData:mapPixels
    it("rejects reentrant userdata access without committing scratch pixels", function()
        local image = callback_fixture()
        expect_error(function()
            image:mapPixels(function(x, y, r, g, b, a)
                image:getPixel(0, 0)
                return r + 1, g, b, a
            end)
        end)
        expect_callback_fixture_unchanged(image)
    end)
end)

-- @describe image hostile numeric effects
describe("image hostile numeric effects", function()
    -- @security LImageData:brightness
    it("rejects non-finite brightness", function()
        local image = callback_fixture()
        expect_error(function()
            image:brightness(math.huge)
        end)
        expect_error(function()
            image:brightness(0 / 0)
        end)
    end)

    -- @security LLayeredImage:setOpacity
    it("rejects non-finite layer opacity", function()
        local layered = layer_fixture()
        expect_error(function()
            layered:setOpacity(1, math.huge)
        end)
    end)
end)

-- @describe image transactional effect chains
describe("image transactional effect chains", function()
    -- @security LImageData:applyEffects
    it("does not commit an earlier effect when a later effect is invalid", function()
        local image = callback_fixture()
        expect_error(function()
            image:applyEffects({ "invert", "notAnEffect" })
        end)
        expect_callback_fixture_unchanged(image)
    end)
end)

-- @describe image sandboxed output paths
describe("image sandboxed output paths", function()
    -- @security lurek.image.savePNG
    it("rejects traversal when saving PNG image data", function()
        local image = callback_fixture()
        expect_error(function()
            lurek.image.savePNG(image, "../outside.png")
        end)
    end)

    -- @security lurek.image.saveImage
    it("rejects traversal when saving LIMG image data", function()
        local image = callback_fixture()
        expect_error(function()
            lurek.image.saveImage(image, "../outside.limg")
        end)
    end)

    -- @security lurek.image.saveGIF
    it("rejects traversal when saving GIF image data", function()
        local image = callback_fixture()
        expect_error(function()
            lurek.image.saveGIF({ image }, "../outside.gif")
        end)
    end)

    -- @security LLayeredImage:save
    it("rejects traversal when saving a layered image", function()
        local layered = layer_fixture()
        expect_error(function()
            layered:save("../outside.limg")
        end)
    end)
end)

test_summary()
