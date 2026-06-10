-- Lurek2D Font API Tests

-- @describe lurek.font.getDefault
describe("lurek.font.getDefault", function()
    -- @covers lurek.font.getDefault
    it("returns a userdata value", function()
        local f = lurek.font.getDefault()
        expect_not_nil(f, "default font should exist")
        expect_equal("userdata", type(f))
    end)
end)

-- @describe lurek.font.availableSizes
describe("lurek.font.availableSizes", function()
    -- @covers lurek.font.availableSizes
    it("returns positive numeric built-in sizes", function()
        local sizes = lurek.font.availableSizes()
        expect_true(type(sizes) == "table", "should be a table")
        expect_true(#sizes >= 7, "should have at least 7 sizes")
        for i = 1, #sizes do
            expect_true(type(sizes[i]) == "number", "entry is a number")
            expect_true(sizes[i] > 0, "size is positive")
        end
    end)
end)

-- @describe lurek.font.list
describe("lurek.font.list", function()
    -- @covers lurek.font.list
    it("returns font entries with name size and style fields", function()
        local fonts = lurek.font.list()
        expect_true(type(fonts) == "table", "should be a table")
        expect_true(#fonts > 0, "should have at least one font")
        local fonts = lurek.font.list()
        local entry = fonts[1]
        expect_true(type(entry.name) == "string", "name is string")
        expect_true(type(entry.size) == "number", "size is number")
        expect_true(type(entry.style) == "string", "style is string")
    end)
end)

-- @describe lurek.font.measure
describe("lurek.font.measure", function()
    -- @covers lurek.font.measure
    it("measures visible text and reports zero width for empty text", function()
        local f = lurek.font.getDefault()
        local w, h = lurek.font.measure(f, "Hello", 1.0)
        expect_true(w > 0, "width should be > 0")
        expect_true(h > 0, "height should be > 0")
        local empty_w = lurek.font.measure(f, "", 1.0)
        expect_near(0, empty_w, 0.01)
    end)
end)

-- @describe lurek.font.measureLine
describe("lurek.font.measureLine", function()
    -- @covers lurek.font.measureLine
    it("single line measurement returns width > 0", function()
        local f = lurek.font.getDefault()
        local w, h = lurek.font.measureLine(f, "Test line", 1.0)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)
end)

-- @describe lurek.font.wrapText
describe("lurek.font.wrapText", function()
    -- @covers lurek.font.wrapText
    it("wrapText handles narrow and wide line widths", function()
        local f = lurek.font.getDefault()
        local lines = lurek.font.wrapText(f, "This is a long sentence that should wrap into multiple lines", 50, 1.0, "word")
        expect_true(#lines > 1, "should produce multiple lines")
        local wide_lines = lurek.font.wrapText(f, "Short", 9999, 1.0, "word")
        expect_equal(1, #wide_lines)
    end)
end)

-- @describe lurek.font.shapeText
describe("lurek.font.shapeText", function()
    -- @covers lurek.font.shapeText
    it("returns shaped lines and alignment offsets", function()
        local f = lurek.font.getDefault()
        local shaped = lurek.font.shapeText(f, "Hello world", 200, 1.0, "left", "word")
        expect_true(type(shaped) == "table", "returns a table")
        expect_true(#shaped >= 1, "at least one line")
        local first = shaped[1]
        expect_true(type(first.text) == "string", "has text field")
        expect_true(type(first.width) == "number", "has width field")
        expect_true(type(first.xOffset) == "number", "has xOffset field")
        local centered = lurek.font.shapeText(f, "Hi", 500, 1.0, "center", "word")
        expect_true(centered[1].xOffset > 0, "center offset should be > 0")
    end)
end)

-- @describe lurek.font.charAdvance
describe("lurek.font.charAdvance", function()
    -- @covers lurek.font.charAdvance
    it("charAdvance reports positive advances for letters and spaces", function()
        local f = lurek.font.getDefault()
        local adv_a = lurek.font.charAdvance(f, "A", 1.0)
        local adv_space = lurek.font.charAdvance(f, " ", 1.0)
        expect_true(adv_a > 0, "advance should be positive")
        expect_true(adv_space > 0, "space advance should be positive")
    end)
end)

-- @describe lurek.font.lineHeight
describe("lurek.font.lineHeight", function()
    -- @covers lurek.font.lineHeight
    it("returns positive value for default font", function()
        local f = lurek.font.getDefault()
        local lh = lurek.font.lineHeight(f)
        expect_true(lh > 0, "line height should be > 0")
    end)
end)

-- @describe LuaFont methods
describe("LuaFont methods", function()
    -- @covers LFont:getName
    it("getName returns a string", function()
        local f = lurek.font.getDefault()
        local name = f:getName()
        expect_true(type(name) == "string", "name is a string")
        expect_true(#name > 0, "name is not empty")
    end)

    -- @covers LFont:getSize
    it("getSize returns a positive number", function()
        local f = lurek.font.getDefault()
        local size = f:getSize()
        expect_true(type(size) == "number", "size is a number")
        expect_true(size > 0, "size is positive")
    end)

    -- @covers LFont:getStyle
    it("getStyle returns 'regular' or 'bold'", function()
        local f = lurek.font.getDefault()
        local style = f:getStyle()
        expect_true(style == "regular" or style == "bold", "style is valid")
    end)

    -- @covers LFont:isBold
    it("isBold returns boolean", function()
        local f = lurek.font.getDefault()
        local bold = f:isBold()
        expect_true(type(bold) == "boolean", "isBold returns boolean")
    end)
end)

-- @describe lurek.font.loadBitmap
describe("lurek.font.loadBitmap", function()
    -- @covers lurek.font.loadBitmap
    it("loadBitmap validates arguments and rejects missing files", function()
        expect_type("function", lurek.font.loadBitmap)
        local ok, err = pcall(function()
            local bad_path ---@type any
            bad_path = nil
            lurek.font.loadBitmap(bad_path, 8, 8)
        end)
        expect_true(not ok, "must error on nil path")
        expect_true(err ~= nil, "error must be non-nil")
        ok = pcall(function()
            local bad_width ---@type any
            bad_width = "wide"
            lurek.font.loadBitmap("test.png", bad_width, 8)
        end)
        expect_true(not ok, "must error on non-numeric cellWidth")
        ok = pcall(function()
            lurek.font.loadBitmap("nonexistent_bitmap_font.png", 8, 8)
        end)
        expect_true(not ok, "must error when file does not exist")
    end)
end)

-- @describe lurek.font.getDefault methods
describe("lurek.font.getDefault methods", function()
    -- @covers LFont:containsGlyph
    it("containsGlyph reports known glyphs and rejects control characters", function()
        local f = lurek.font.getDefault()
        expect_true(f:containsGlyph("A"), "should contain glyph for A")
        expect_equal(false, f:containsGlyph(string.char(1)))
    end)

    -- @covers LFont:lineHeight
    it("method lineHeight matches module function", function()
        local f = lurek.font.getDefault()
        local method_lh = f:lineHeight()
        local fn_lh = lurek.font.lineHeight(f)
        expect_near(fn_lh, method_lh, 0.01)
    end)

    -- @covers LFont:measure
    it("method measure returns positive dimensions", function()
        local f = lurek.font.getDefault()
        local w, h = f:measure("Test", 1.0)
        expect_true(w > 0, "width > 0")
        expect_true(h > 0, "height > 0")
    end)
end)
test_summary()
