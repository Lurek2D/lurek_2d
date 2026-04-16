-- tests/lua/unit/test_sprite_aseprite.lua
-- Tests for lurek.sprite.parseAsepriteAtlas and SpriteAtlas:getFlipped.
-- No GPU, audio, or window calls.

local ASEPRITE_ARRAY_JSON = [[{
  "frames": [
    { "filename": "hero/idle_0.png", "frame": { "x": 0,  "y": 0, "w": 32, "h": 32 } },
    { "filename": "hero/idle_1.png", "frame": { "x": 32, "y": 0, "w": 32, "h": 32 } },
    { "filename": "hero/run_0.png",  "frame": { "x": 64, "y": 0, "w": 32, "h": 32 } }
  ]
}]]

local ASEPRITE_HASH_JSON = [[{
  "frames": {
    "bullet_0.png": { "frame": { "x": 0, "y": 32, "w": 8, "h": 8 } },
    "bullet_1.png": { "frame": { "x": 8, "y": 32, "w": 8, "h": 8 } }
  }
}]]

describe("sprite.parseAsepriteAtlas", function()

    it("parseAsepriteAtlas exists in lurek.sprite", function()
        expect_equal(type(lurek.sprite.parseAsepriteAtlas), "function")
    end)

    it("parses array-format Aseprite JSON without error", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        expect_equal(atlas ~= nil, true)
    end)

    it("returns atlas with correct entry count from array format", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        expect_equal(atlas:entryCount(), 3)
    end)

    it("parses hash-format Aseprite JSON without error", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_HASH_JSON)
        expect_equal(atlas:entryCount(), 2)
    end)

    it("getEntry returns correct region from array-format atlas", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local e = atlas:getEntry("hero/run_0.png")
        expect_equal(e ~= nil, true)
        expect_equal(e.x, 64)
        expect_equal(e.y, 0)
        expect_equal(e.w, 32)
        expect_equal(e.h, 32)
    end)

    it("getEntry returns correct region from hash-format atlas", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_HASH_JSON)
        local e = atlas:getEntry("bullet_1.png")
        expect_equal(e ~= nil, true)
        expect_equal(e.x, 8)
        expect_equal(e.w, 8)
    end)

    it("getEntry returns nil for unknown name", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local e = atlas:getEntry("nonexistent.png")
        expect_equal(e, nil)
    end)

    it("entryNames returns all frame names", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local names = atlas:entryNames()
        expect_equal(type(names), "table")
        expect_equal(#names, 3)
    end)

    it("raises error for invalid JSON", function()
        expect_error(function()
            lurek.sprite.parseAsepriteAtlas("not json {{{")
        end)
    end)

    it("raises error for JSON missing 'frames' key", function()
        expect_error(function()
            lurek.sprite.parseAsepriteAtlas('{"meta":{}}')
        end)
    end)

end)

describe("sprite.atlas.getFlipped", function()

    it("getFlipped exists on SpriteAtlas userdata", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        expect_equal(type(atlas.getFlipped), "function")
    end)

    it("getFlipped returns a table with flip_x and flip_y set", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local flipped = atlas:getFlipped("hero/idle_0.png", true, false)
        expect_equal(type(flipped), "table")
        expect_equal(flipped.flip_x, true)
        expect_equal(flipped.flip_y, false)
    end)

    it("getFlipped preserves source region coordinates", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local orig  = atlas:getEntry("hero/idle_0.png")
        local flipped = atlas:getFlipped("hero/idle_0.png", true, true)
        expect_equal(flipped.x, orig.x)
        expect_equal(flipped.y, orig.y)
        expect_equal(flipped.w, orig.w)
        expect_equal(flipped.h, orig.h)
    end)

    it("getFlipped returns nil for unknown name", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local result = atlas:getFlipped("ghost.png", true, false)
        expect_equal(result, nil)
    end)

    it("getFlipped works on TexturePacker atlas too", function()
        local tp_json = '{"frames":{"sword.png":{"frame":{"x":0,"y":0,"w":16,"h":32},"rotated":false}}}'
        local atlas = lurek.sprite.parseAtlas(tp_json)
        local flipped = atlas:getFlipped("sword.png", false, true)
        expect_equal(flipped.flip_y, true)
        expect_equal(flipped.w, 16)
    end)

end)

test_summary()
