-- Lurek2D Lua BDD tests for lurek.sprite
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.sprite.
describe("lurek.sprite", function()
    -- ── module interface ──────────────────────────────────────────────────

    -- @description Covers suite: module interface.
    describe("module interface", function()
        -- @covers lurek.sprite.newSheet
        -- @description Verifies the sprite namespace exposes the newSheet factory.
        it("exposes newSheet factory", function()
            expect_type("function", lurek.sprite.newSheet)
        end)

        -- @covers lurek.sprite.newRPGMakerSheet
        -- @description Verifies the sprite namespace exposes the newRPGMakerSheet factory.
        it("exposes newRPGMakerSheet factory", function()
            expect_type("function", lurek.sprite.newRPGMakerSheet)
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @description Verifies the sprite namespace exposes the parseAtlas factory.
        it("exposes parseAtlas factory", function()
            expect_type("function", lurek.sprite.parseAtlas)
        end)

        -- @covers lurek.sprite.newAtlasSheet
        -- @description Verifies the sprite namespace exposes the newAtlasSheet factory.
        it("exposes newAtlasSheet factory", function()
            expect_type("function", lurek.sprite.newAtlasSheet)
        end)
    end)

    -- ── newSheet ──────────────────────────────────────────────────────────

    -- @description Covers suite: newSheet().
    describe("newSheet()", function()
        -- @covers lurek.sprite.newSheet
        -- @description Confirms newSheet returns userdata for a valid grid description.
        it("returns a userdata", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            expect_type("userdata", s)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getFrameCount
        -- @description Confirms a 4×4 grid sheet has 16 frames.
        it("getFrameCount returns 16 for a 4x4 grid", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            expect_equal(16, s:getFrameCount())
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getGridSize
        -- @description Checks grid dimensions are reported accurately.
        it("getGridSize returns correct columns and rows", function()
            local s = lurek.sprite.newSheet(128, 64, 32, 32)
            local cols, rows = s:getGridSize()
            expect_equal(4, cols)
            expect_equal(2, rows)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getFrameSize
        -- @description Confirms getFrameSize returns the tile dimensions given at construction.
        it("getFrameSize returns tile dimensions", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 32)
            local fw, fh = s:getFrameSize()
            expect_equal(16, fw)
            expect_equal(32, fh)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getFrame
        -- @description Verifies frame 0 returns a table with x/y/w/h fields.
        it("getFrame(0) returns a quad table", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local q = s:getFrame(0)
            expect_type("table", q)
            expect_type("number", q.x)
            expect_type("number", q.y)
            expect_type("number", q.w)
            expect_type("number", q.h)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getFrame
        -- @description Verifies the first frame starts at pixel (0, 0).
        it("frame 0 starts at (0,0)", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local q = s:getFrame(0)
            expect_equal(0, q.x)
            expect_equal(0, q.y)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getFrame
        -- @description Verifies frame 1 starts at x = tile width.
        it("frame 1 starts at x = tile_w", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local q = s:getFrame(1)
            expect_equal(16, q.x)
            expect_equal(0, q.y)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getRow
        -- @description Verifies getRow returns all frames in the first row.
        it("getRow(0) returns all frames in first row", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local row = s:getRow(0)
            expect_type("table", row)
            expect_equal(4, #row)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getColumn
        -- @description Verifies getColumn returns all frames in the first column.
        it("getColumn(0) returns all frames in first column", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local col = s:getColumn(0)
            expect_type("table", col)
            expect_equal(4, #col)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.nameGroup
        -- @covers lurek.sprite.getGroupFrames
        -- @description Verifies a named group can be retrieved after registration.
        it("nameGroup registers retrievable group", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            s:nameGroup("run", 0, 4)
            local g = s:getGroupFrames("run")
            expect_type("table", g)
            expect_equal(4, #g)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.nameGroup
        -- @covers lurek.sprite.getGroupNames
        -- @description Verifies getGroupNames returns the names of all registered groups.
        it("getGroupNames returns registered group names", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            s:nameGroup("idle", 0, 2)
            s:nameGroup("walk", 2, 4)
            local names = s:getGroupNames()
            expect_type("table", names)
            expect_equal(2, #names)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.getGroupFrames
        -- @description Verifies getGroupFrames returns nil for an unregistered name.
        it("getGroupFrames nil for unknown group", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local g = s:getGroupFrames("ghost")
            expect_equal(nil, g)
        end)

        -- @covers lurek.sprite.newSheet
        -- @covers lurek.sprite.drawToImage
        -- @description Verifies drawToImage returns userdata (an ImageData object).
        it("drawToImage returns userdata", function()
            local s = lurek.sprite.newSheet(64, 64, 16, 16)
            local img = s:drawToImage(64, 64)
            expect_type("userdata", img)
        end)
    end)

    -- ── newRPGMakerSheet ──────────────────────────────────────────────────

    -- @description Covers suite: newRPGMakerSheet().
    describe("newRPGMakerSheet()", function()
        -- @covers lurek.sprite.newRPGMakerSheet
        -- @description Confirms the RPGMaker factory returns a valid SpriteSheet.
        it("returns a userdata", function()
            local s = lurek.sprite.newRPGMakerSheet(144, 192)
            expect_type("userdata", s)
        end)

        -- @covers lurek.sprite.newRPGMakerSheet
        -- @covers lurek.sprite.getFrameCount
        -- @description Confirms a standard RPGMaker sheet (3×4 grid) has 12 frames.
        it("getFrameCount returns 12 for standard RPGMaker sheet", function()
            local s = lurek.sprite.newRPGMakerSheet(144, 192)
            expect_equal(12, s:getFrameCount())
        end)

        -- @covers lurek.sprite.newRPGMakerSheet
        -- @covers lurek.sprite.getGroupNames
        -- @description Confirms RPGMaker direction groups are present.
        it("has down/left/right/up groups", function()
            local s = lurek.sprite.newRPGMakerSheet(144, 192)
            local names = s:getGroupNames()
            local by_name = {}
            for _, n in ipairs(names) do by_name[n] = true end
            expect_true(by_name["down"]  ~= nil, "expected down group")
            expect_true(by_name["left"]  ~= nil, "expected left group")
            expect_true(by_name["right"] ~= nil, "expected right group")
            expect_true(by_name["up"]    ~= nil, "expected up group")
        end)
    end)

    -- ── parseAtlas ────────────────────────────────────────────────────────

    -- @description Covers suite: parseAtlas().
    describe("parseAtlas()", function()
        local HASH_JSON = [[{
            "frames": {
                "hero_idle": {"frame":{"x":0,"y":0,"w":32,"h":32},"rotated":false},
                "hero_run":  {"frame":{"x":32,"y":0,"w":32,"h":32},"rotated":false}
            }
        }]]

        -- @covers lurek.sprite.parseAtlas
        -- @description Confirms parseAtlas returns a SpriteAtlas userdata on valid JSON.
        it("returns a userdata for valid hash JSON", function()
            local a = lurek.sprite.parseAtlas(HASH_JSON)
            expect_type("userdata", a)
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @covers lurek.sprite.entryCount
        -- @description Confirms entryCount equals the number of frame entries in the JSON.
        it("entryCount matches frame count", function()
            local a = lurek.sprite.parseAtlas(HASH_JSON)
            expect_equal(2, a:entryCount())
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @covers lurek.sprite.getEntry
        -- @description Verifies getEntry returns a table with x/y/w/h fields for a known entry.
        it("getEntry returns correct quad for known name", function()
            local a = lurek.sprite.parseAtlas(HASH_JSON)
            local e = a:getEntry("hero_idle")
            expect_type("table", e)
            expect_equal(0, e.x)
            expect_equal(0, e.y)
            expect_equal(32, e.w)
            expect_equal(32, e.h)
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @covers lurek.sprite.getEntry
        -- @description Verifies getEntry returns nil for an unknown sprite name.
        it("getEntry returns nil for unknown name", function()
            local a = lurek.sprite.parseAtlas(HASH_JSON)
            local e = a:getEntry("ghost")
            expect_equal(nil, e)
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @covers lurek.sprite.getByIndex
        -- @description Verifies getByIndex(1) returns a valid entry table for a one-entry atlas.
        it("getByIndex(1) returns a valid entry", function()
            local json = [[{"frames":{"hero":{"frame":{"x":0,"y":0,"w":16,"h":16},"rotated":false}}}]]
            local a = lurek.sprite.parseAtlas(json)
            local e = a:getByIndex(1)
            expect_type("table", e)
            expect_type("string", e.name)
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @covers lurek.sprite.entryNames
        -- @description Verifies entryNames returns a table of all sprite names in the atlas.
        it("entryNames returns all sprite names", function()
            local a = lurek.sprite.parseAtlas(HASH_JSON)
            local names = a:entryNames()
            expect_type("table", names)
            expect_equal(2, #names)
        end)

        -- @covers lurek.sprite.parseAtlas
        -- @description Verifies parseAtlas surfaces an error on malformed JSON input.
        it("errors on invalid JSON", function()
            expect_error(function()
                lurek.sprite.parseAtlas("not json at all")
            end)
        end)
    end)

    -- ── newAtlasSheet ─────────────────────────────────────────────────────

    -- @description Covers suite: newAtlasSheet().
    describe("newAtlasSheet()", function()
        -- @covers lurek.sprite.newAtlasSheet
        -- @description Confirms newAtlasSheet returns a SpriteSheet from a parsed atlas.
        it("returns a userdata", function()
            local json = [[{"frames":{"a":{"frame":{"x":0,"y":0,"w":16,"h":16},"rotated":false}}}]]
            local atlas = lurek.sprite.parseAtlas(json)
            local s = lurek.sprite.newAtlasSheet(atlas, 64, 64)
            expect_type("userdata", s)
        end)

        -- @covers lurek.sprite.newAtlasSheet
        -- @covers lurek.sprite.getFrameCount
        -- @description Confirms atlas-derived sheet has the same number of frames as atlas entries.
        it("frame count equals atlas entry count", function()
            local json = [[{"frames":{
                "a":{"frame":{"x":0,"y":0,"w":16,"h":16},"rotated":false},
                "b":{"frame":{"x":16,"y":0,"w":16,"h":16},"rotated":false}
            }}]]
            local atlas = lurek.sprite.parseAtlas(json)
            local s = lurek.sprite.newAtlasSheet(atlas, 64, 64)
            expect_equal(2, s:getFrameCount())
        end)
    end)
end)

test_summary()
