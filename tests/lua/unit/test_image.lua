-- tests/lua/unit/test_image.lua
-- BDD tests for luna.img compressed texture API.
-- The headless VM has no filesystem, so only function existence and
-- error-handling behaviour are tested here.

describe("luna.img compressed API", function()
    it("luna.img is a table", function()
        expect_type("table", luna.img)
    end)

    it("newCompressedData is a function", function()
        expect_type("function", luna.img.newCompressedData)
    end)

    it("isCompressed is a function", function()
        expect_type("function", luna.img.isCompressed)
    end)

    it("newCompressedData errors on missing file", function()
        expect_error(function()
            luna.img.newCompressedData("nonexistent_file.dds")
        end)
    end)

    it("isCompressed returns false for a missing path", function()
        local result = luna.img.isCompressed("nonexistent_file.dds")
        expect_equal(result, false)
    end)
end)

describe("luna.img existing API still works", function()
    it("newImageData is a function", function()
        expect_type("function", luna.img.newImageData)
    end)

    it("newImageData creates a blank buffer", function()
        local img = luna.img.newImageData(4, 4)
        expect_type("userdata", img)
    end)
end)

test_summary()
