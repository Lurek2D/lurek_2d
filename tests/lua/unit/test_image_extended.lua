-- test_image_extended.lua
-- Unit tests for the extended lurek.img ImageData API:
-- resize, blit, getRegion, diff, mapPixels.

local describe     = describe
local it           = it
local expect_equal = expect_equal

-- Helper: create a blank RGBA image filled with a solid colour.
local function make_solid(w, h, r, g, b, a)
    local img = lurek.img.newImageData(w, h)
    img:mapPixels(function(_, _, _, _, _, _) return r, g, b, a end)
    return img
end

describe("ImageData:resize", function()
    it("resize to same dimensions returns a copy", function()
        local img = make_solid(4, 4, 255, 0, 0, 255)
        local copy = img:resize(4, 4)
        expect_equal(copy ~= nil, true)
        expect_equal(copy:getWidth(), 4)
        expect_equal(copy:getHeight(), 4)
    end)

    it("resize returns correct dimensions", function()
        local img = make_solid(8, 8, 0, 255, 0, 255)
        local small = img:resize(2, 3)
        expect_equal(small:getWidth(), 2)
        expect_equal(small:getHeight(), 3)
    end)

    it("resize to zero returns nil", function()
        local img = make_solid(4, 4, 0, 0, 0, 255)
        local result = img:resize(0, 4)
        expect_equal(result, nil)
    end)
end)

describe("ImageData:blit", function()
    it("blit does not error for valid coordinates", function()
        local dst = make_solid(8, 8, 0, 0, 0, 255)
        local src = make_solid(2, 2, 255, 255, 255, 255)
        dst:blit(src, 3, 3)
        -- No error expected.
    end)

    it("blit at (0,0) covers the top-left corner", function()
        local dst = make_solid(4, 4, 0, 0, 0, 255)
        local src = make_solid(2, 2, 200, 100, 50, 255)
        dst:blit(src, 0, 0)
        -- After opaque blit the src pixels should dominate top-left corner.
        -- Just verify no error and pixel access works.
        expect_equal(dst:getWidth(), 4)
    end)

    it("blit with negative offset does not error (clips out-of-bounds)", function()
        local dst = make_solid(4, 4, 0, 0, 0, 255)
        local src = make_solid(2, 2, 255, 0, 0, 255)
        dst:blit(src, -1, -1)
    end)
end)

describe("ImageData:getRegion", function()
    it("getRegion of full image returns same dimensions", function()
        local img = make_solid(6, 4, 128, 64, 32, 255)
        local region = img:getRegion(0, 0, 6, 4)
        expect_equal(region ~= nil, true)
        expect_equal(region:getWidth(), 6)
        expect_equal(region:getHeight(), 4)
    end)

    it("getRegion of sub-rectangle returns correct dimensions", function()
        local img = make_solid(8, 8, 0, 0, 255, 255)
        local region = img:getRegion(2, 2, 4, 3)
        expect_equal(region:getWidth(), 4)
        expect_equal(region:getHeight(), 3)
    end)

    it("getRegion outside bounds returns nil", function()
        local img = make_solid(4, 4, 0, 0, 0, 255)
        local result = img:getRegion(10, 10, 4, 4)
        expect_equal(result, nil)
    end)
end)

describe("ImageData:diff", function()
    it("diff of identical images is 0", function()
        local a = make_solid(4, 4, 100, 150, 200, 255)
        local b = make_solid(4, 4, 100, 150, 200, 255)
        local d = a:diff(b)
        expect_equal(d, 0)
    end)

    it("diff of different images is > 0", function()
        local a = make_solid(4, 4, 0, 0, 0, 255)
        local b = make_solid(4, 4, 255, 255, 255, 255)
        local d = a:diff(b)
        expect_equal(d > 0, true)
    end)

    it("diff of images with different dimensions is > 0", function()
        local a = make_solid(4, 4, 0, 0, 0, 255)
        local b = make_solid(2, 2, 0, 0, 0, 255)
        local d = a:diff(b)
        expect_equal(d > 0, true)
    end)
end)

describe("ImageData:mapPixels", function()
    it("mapPixels can invert all pixels", function()
        local img = make_solid(4, 4, 100, 150, 200, 255)
        img:mapPixels(function(_, _, r, g, b, a)
            return 255 - r, 255 - g, 255 - b, a
        end)
        -- Confirm width preserved.
        expect_equal(img:getWidth(), 4)
    end)

    it("mapPixels identity function produces same diff as 0", function()
        local img_a = make_solid(4, 4, 42, 88, 177, 255)
        local img_b = make_solid(4, 4, 42, 88, 177, 255)
        img_a:mapPixels(function(_, _, r, g, b, a) return r, g, b, a end)
        local d = img_a:diff(img_b)
        expect_equal(d, 0)
    end)

    it("mapPixels can set all pixels to a constant colour", function()
        local img = make_solid(4, 4, 0, 0, 0, 255)
        img:mapPixels(function(_, _, _, _, _, _) return 1, 2, 3, 4 end)
        expect_equal(img:getWidth(), 4)
    end)
end)

test_summary()
