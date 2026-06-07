-- Lurek2D Lua BDD tests for lurek.sprite
-- Headless: no GPU, no audio, no window.

-- module interface

-- @describe module interface
describe("module interface", function()
    -- @covers lurek.sprite.newSprite
    it("exposes newSprite for lit sprite normal map workflows", function()
        expect_type("function", lurek.sprite.newSprite)
    end)

    -- @covers lurek.sprite.newSheet
    it("exposes newSheet factory", function()
        expect_type("function", lurek.sprite.newSheet)
    end)

    -- @covers lurek.sprite.newRPGMakerSheet
    it("exposes newRPGMakerSheet factory", function()
        expect_type("function", lurek.sprite.newRPGMakerSheet)
    end)

    -- @covers lurek.sprite.parseAtlas
    it("exposes parseAtlas factory", function()
        expect_type("function", lurek.sprite.parseAtlas)
    end)

    -- @covers lurek.sprite.newAtlasSheet
    it("exposes newAtlasSheet factory", function()
        expect_type("function", lurek.sprite.newAtlasSheet)
    end)

    -- @covers lurek.sprite.newAtlasPacker
    it("exposes newAtlasPacker factory", function()
        expect_type("function", lurek.sprite.newAtlasPacker)
    end)

    -- @covers lurek.sprite.newAnimator
    it("exposes newAnimator factory", function()
        expect_type("function", lurek.sprite.newAnimator)
    end)
end)

-- @describe sprite animator
describe("sprite animator", function()
    local clips = {
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    }

    -- @covers lurek.sprite.newAnimator
    it("creates animator userdata", function()
        local anim = lurek.sprite.newAnimator(clips)
        expect_type("userdata", anim)
    end)

    -- @covers LSpriteAnimator:play
    it("play selects named clip", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        expect_equal("idle", anim:currentClip())
    end)

    -- @covers LSpriteAnimator:currentClip
    it("currentClip returns nil before play", function()
        local anim = lurek.sprite.newAnimator(clips)
        expect_equal(nil, anim:currentClip())
    end)

    -- @covers LSpriteAnimator:currentFrame
    it("currentFrame returns row and column", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        local row, col = anim:currentFrame()
        expect_equal(1, row)
        expect_equal(1, col)
    end)

    -- @covers LSpriteAnimator:update
    it("update advances to next frame", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        anim:update(0.11)
        local _, col = anim:currentFrame()
        expect_equal(2, col)
    end)

    -- @covers LSpriteAnimator:isPlaying
    it("isPlaying reflects running state", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        expect_equal(true, anim:isPlaying())
    end)

    -- @covers LSpriteAnimator:pause
    it("pause stops playback", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        anim:pause()
        expect_equal(false, anim:isPlaying())
    end)

    -- @covers LSpriteAnimator:resume
    it("resume continues paused clip", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        anim:pause()
        anim:resume()
        expect_equal(true, anim:isPlaying())
    end)

    -- @covers LSpriteAnimator:stop
    it("stop resets frame to clip start", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        anim:update(0.11)
        anim:stop()
        local _, col = anim:currentFrame()
        expect_equal(1, col)
    end)

    -- @covers LSpriteAnimator:addClip
    it("addClip appends a new playable clip", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:addClip("run", { row = 3, from = 1, to = 2, fps = 12, loop = true })
        anim:play("run")
        expect_equal("run", anim:currentClip())
    end)

    -- @covers LSpriteAnimator:frameDuration
    it("frameDuration returns reciprocal fps", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("idle")
        expect_near(0.1, anim:frameDuration(), 0.0001)
    end)

    -- @covers LSpriteAnimator:clipDuration
    it("clipDuration returns full clip length", function()
        local anim = lurek.sprite.newAnimator(clips)
        anim:play("jump")
        expect_near(0.4, anim:clipDuration(), 0.0001)
    end)

    -- @covers LSpriteAnimator:onFrame
    it("onFrame callback receives frame updates", function()
        local anim = lurek.sprite.newAnimator(clips)
        local received = 0
        anim:onFrame(function()
            received = received + 1
        end)
        anim:play("idle")
        anim:update(0.21)
        expect_equal(true, received >= 2)
    end)

    -- @covers LSpriteAnimator:onLoop
    it("onLoop callback fires when clip loops", function()
        local anim = lurek.sprite.newAnimator(clips)
        local loops = 0
        anim:onLoop(function()
            loops = loops + 1
        end)
        anim:play("idle")
        anim:update(0.31)
        expect_equal(true, loops >= 1)
    end)

    -- @covers LSpriteAnimator:onEnd
    it("onEnd callback fires for non-loop clip", function()
        local anim = lurek.sprite.newAnimator(clips)
        local ended = false
        anim:onEnd(function()
            ended = true
        end)
        anim:play("jump")
        anim:update(1.0)
        expect_equal(true, ended)
    end)

    -- @covers LSpriteAnimator:type
    it("type reports animator type", function()
        local anim = lurek.sprite.newAnimator(clips)
        expect_equal("LSpriteAnimator", anim:type())
    end)

    -- @covers LSpriteAnimator:typeOf
    it("typeOf recognizes animator type", function()
        local anim = lurek.sprite.newAnimator(clips)
        expect_equal(true, anim:typeOf("LSpriteAnimator"))
        expect_equal(false, anim:typeOf("LSpriteSheet"))
    end)
end)

-- @describe sprite lit sprite normal map support
describe("sprite lit sprite normal map support", function()
    -- @covers LSprite:getNormalIntensity
    -- @covers LSprite:getNormalMap
    -- @covers LSprite:hasNormalMap
    -- @covers LSprite:setNormalIntensity
    -- @covers LSprite:setNormalMap
    -- @covers lurek.sprite.newSprite
    it("stores and exposes normal map data for a lit sprite", function()
        local sprite = lurek.sprite.newSprite(7, 10, 20)

        expect_false(sprite:hasNormalMap())
        sprite:setNormalMap(11)
        sprite:setNormalIntensity(2.5)

        expect_true(sprite:hasNormalMap())
        expect_equal(11, sprite:getNormalMap())
        expect_near(2.5, sprite:getNormalIntensity(), 0.001)
    end)

    -- @covers LSprite:clearNormalMap
    -- @covers LSprite:hasNormalMap
    -- @covers LSprite:setNormalMap
    -- @covers lurek.sprite.newSprite
    it("clears the normal map from a lit sprite", function()
        local sprite = lurek.sprite.newSprite(7, 0, 0)
        sprite:setNormalMap(3)
        sprite:clearNormalMap()
        expect_false(sprite:hasNormalMap())
    end)

    -- @covers LSprite:setPosition
    it("setPosition updates sprite coordinates", function()
        local sprite = lurek.sprite.newSprite(7, 0, 0)
        sprite:setPosition(12, 34)
        local x, y = sprite:getPosition()
        expect_equal(12, x)
        expect_equal(34, y)
    end)

    -- @covers LSprite:getPosition
    it("getPosition returns constructor coordinates", function()
        local sprite = lurek.sprite.newSprite(7, 5, 9)
        local x, y = sprite:getPosition()
        expect_equal(5, x)
        expect_equal(9, y)
    end)

    -- @covers LSprite:type
    it("type reports LSprite", function()
        local sprite = lurek.sprite.newSprite(7, 0, 0)
        expect_equal("LSprite", sprite:type())
    end)

    -- @covers LSprite:typeOf
    it("typeOf recognizes sprite type names", function()
        local sprite = lurek.sprite.newSprite(7, 0, 0)
        expect_equal(true, sprite:typeOf("LSprite"))
        expect_equal(true, sprite:typeOf("LObject"))
        expect_equal(false, sprite:typeOf("LAtlasPacker"))
    end)
end)

-- newAtlasPacker

-- @describe newAtlasPacker()
describe("newAtlasPacker()", function()
    -- @covers lurek.sprite.newAtlasPacker
    it("returns a userdata", function()
        local p = lurek.sprite.newAtlasPacker(64, 64, 1)
        expect_type("userdata", p)
    end)

    -- @covers LAtlasPacker:pack
    -- @covers LAtlasPacker:getRegion
    -- @covers lurek.sprite.newAtlasPacker
    it("packs and returns a named region", function()
        local p = lurek.sprite.newAtlasPacker(64, 64, 1)
        expect_true(p:pack("hero", 16, 16), "expected hero to pack")

        local r = p:getRegion("hero")
        expect_type("table", r)
        expect_equal("hero", r.name)
        expect_equal(16, r.w)
        expect_equal(16, r.h)
    end)

    -- @covers LAtlasPacker:regionCount
    -- @covers lurek.sprite.newAtlasPacker
    it("regionCount tracks successful packs", function()
        local p = lurek.sprite.newAtlasPacker(64, 64, 1)
        expect_equal(0, p:regionCount())
        expect_true(p:pack("a", 8, 8), "expected a to pack")
        expect_true(p:pack("b", 8, 8), "expected b to pack")
        expect_equal(2, p:regionCount())
    end)

    -- @covers LAtlasPacker:getDimensions
    -- @covers lurek.sprite.newAtlasPacker
    it("getDimensions returns constructor dimensions", function()
        local p = lurek.sprite.newAtlasPacker(128, 96, 2)
        local w, h = p:getDimensions()
        expect_equal(128, w)
        expect_equal(96, h)
    end)

    -- @covers LAtlasPacker:setNineSlice
    -- @covers LAtlasPacker:getRegion
    -- @covers lurek.sprite.newAtlasPacker
    it("setNineSlice stores optional insets", function()
        local p = lurek.sprite.newAtlasPacker(64, 64, 1)
        expect_true(p:pack("panel", 20, 20), "expected panel to pack")
        expect_true(p:setNineSlice("panel", 2, 2, 3, 3), "expected insets to apply")

        local r = p:getRegion("panel")
        expect_type("table", r.nine_slice)
        expect_equal(2, r.nine_slice.left)
        expect_equal(3, r.nine_slice.top)
    end)

    -- @covers LAtlasPacker:clear
    -- @covers LAtlasPacker:regionCount
    -- @covers lurek.sprite.newAtlasPacker
    it("clear removes all packed regions", function()
        local p = lurek.sprite.newAtlasPacker(64, 64, 1)
        expect_true(p:pack("hero", 16, 16), "expected hero to pack")
        expect_equal(1, p:regionCount())
        p:clear()
        expect_equal(0, p:regionCount())
    end)

    -- @covers LAtlasPacker:type
    -- @covers LAtlasPacker:typeOf
    -- @covers lurek.sprite.newAtlasPacker
    it("type helpers are callable", function()
        local p = lurek.sprite.newAtlasPacker(32, 32, 0)
        expect_equal("LAtlasPacker", p:type())
        expect_equal(true, p:typeOf("LAtlasPacker"))
        expect_equal(false, p:typeOf("LSpriteSheet"))
    end)
end)

-- newSheet

-- @describe newSheet()
describe("newSheet()", function()
    -- @covers lurek.sprite.newSheet
    it("returns a userdata", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        expect_type("userdata", s)
    end)

    -- @covers LSpriteSheet:getFrameCount
    -- @covers lurek.sprite.newSheet
    it("getFrameCount returns 16 for a 4x4 grid", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        expect_equal(16, s:getFrameCount())
    end)

    -- @covers LSpriteSheet:getGridSize
    -- @covers lurek.sprite.newSheet
    it("getGridSize returns correct columns and rows", function()
        local s = lurek.sprite.newSheet(128, 64, 32, 32)
        local cols, rows = s:getGridSize()
        expect_equal(4, cols)
        expect_equal(2, rows)
    end)

    -- @covers LSpriteSheet:getFrameSize
    -- @covers lurek.sprite.newSheet
    it("getFrameSize returns tile dimensions", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 32)
        local fw, fh = s:getFrameSize()
        expect_equal(16, fw)
        expect_equal(32, fh)
    end)

    -- @covers LSpriteSheet:getFrame
    -- @covers lurek.sprite.newSheet
    it("getFrame(0) returns a quad table", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local q = s:getFrame(0)
        expect_type("table", q)
        expect_type("number", q.x)
        expect_type("number", q.y)
        expect_type("number", q.w)
        expect_type("number", q.h)
    end)

    -- @covers LSpriteSheet:getFrame
    -- @covers lurek.sprite.newSheet
    it("frame 0 starts at (0,0)", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local q = s:getFrame(0)
        expect_equal(0, q.x)
        expect_equal(0, q.y)
    end)

    -- @covers LSpriteSheet:getFrame
    -- @covers lurek.sprite.newSheet
    it("frame 1 starts at x = tile_w", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local q = s:getFrame(1)
        expect_equal(16, q.x)
        expect_equal(0, q.y)
    end)

    -- @covers LSpriteSheet:getRow
    -- @covers lurek.sprite.newSheet
    it("getRow(0) returns all frames in first row", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local row = s:getRow(0)
        expect_type("table", row)
        expect_equal(4, #row)
    end)

    -- @covers LSpriteSheet:getColumn
    -- @covers lurek.sprite.newSheet
    it("getColumn(0) returns all frames in first column", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local col = s:getColumn(0)
        expect_type("table", col)
        expect_equal(4, #col)
    end)

    -- @covers LSpriteSheet:getGroupFrames
    -- @covers LSpriteSheet:nameGroup
    -- @covers lurek.sprite.newSheet
    it("nameGroup registers retrievable group", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        s:nameGroup("run", 0, 4)
        local g = s:getGroupFrames("run")
        expect_type("table", g)
        expect_equal(4, #g)
    end)

    -- @covers LSpriteSheet:getGroupNames
    -- @covers LSpriteSheet:nameGroup
    -- @covers lurek.sprite.newSheet
    it("getGroupNames returns registered group names", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        s:nameGroup("idle", 0, 2)
        s:nameGroup("walk", 2, 4)
        local names = s:getGroupNames()
        expect_type("table", names)
        expect_equal(2, #names)
    end)

    -- @covers LSpriteSheet:getGroupFrames
    -- @covers lurek.sprite.newSheet
    it("getGroupFrames nil for unknown group", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local g = s:getGroupFrames("ghost")
        expect_equal(nil, g)
    end)

    -- @covers LSpriteSheet:drawToImage
    -- @covers lurek.sprite.newSheet
    it("drawToImage returns userdata", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        local img = s:drawToImage(64, 64)
        expect_type("userdata", img)
    end)
end)

-- newRPGMakerSheet

-- @describe newRPGMakerSheet()
describe("newRPGMakerSheet()", function()
    -- @covers lurek.sprite.newRPGMakerSheet
    it("returns a userdata", function()
        local s = lurek.sprite.newRPGMakerSheet(144, 192)
        expect_type("userdata", s)
    end)

    -- @covers LSpriteSheet:getFrameCount
    -- @covers lurek.sprite.newRPGMakerSheet
    it("getFrameCount returns 12 for standard RPGMaker sheet", function()
        local s = lurek.sprite.newRPGMakerSheet(144, 192)
        expect_equal(12, s:getFrameCount())
    end)

    -- @covers LSpriteSheet:getGroupNames
    -- @covers lurek.sprite.newRPGMakerSheet
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

-- parseAtlas

-- @describe parseAtlas()
describe("parseAtlas()", function()
    local HASH_JSON = [[{
        "frames": {
            "hero_idle": {"frame":{"x":0,"y":0,"w":32,"h":32},"rotated":false},
            "hero_run":  {"frame":{"x":32,"y":0,"w":32,"h":32},"rotated":false}
        }
    }]]

    -- @covers lurek.sprite.parseAtlas
    it("returns a userdata for valid hash JSON", function()
        local a = lurek.sprite.parseAtlas(HASH_JSON)
        expect_type("userdata", a)
    end)

    -- @covers LSpriteAtlas:entryCount
    -- @covers lurek.sprite.parseAtlas
    it("entryCount matches frame count", function()
        local a = lurek.sprite.parseAtlas(HASH_JSON)
        expect_equal(2, a:entryCount())
    end)

    -- @covers LSpriteAtlas:getEntry
    -- @covers lurek.sprite.parseAtlas
    it("getEntry returns correct quad for known name", function()
        local a = lurek.sprite.parseAtlas(HASH_JSON)
        local e = a:getEntry("hero_idle")
        expect_type("table", e)
        expect_equal(0, e.x)
        expect_equal(0, e.y)
        expect_equal(32, e.w)
        expect_equal(32, e.h)
    end)

    -- @covers LSpriteAtlas:getEntry
    -- @covers lurek.sprite.parseAtlas
    it("getEntry returns nil for unknown name", function()
        local a = lurek.sprite.parseAtlas(HASH_JSON)
        local e = a:getEntry("ghost")
        expect_equal(nil, e)
    end)

    -- @covers LSpriteAtlas:getByIndex
    -- @covers lurek.sprite.parseAtlas
    it("getByIndex(1) returns a valid entry", function()
        local json = [[{"frames":{"hero":{"frame":{"x":0,"y":0,"w":16,"h":16},"rotated":false}}}]]
        local a = lurek.sprite.parseAtlas(json)
        local e = a:getByIndex(1)
        expect_type("table", e)
        expect_type("string", e.name)
    end)

    -- @covers LSpriteAtlas:entryNames
    -- @covers lurek.sprite.parseAtlas
    it("entryNames returns all sprite names", function()
        local a = lurek.sprite.parseAtlas(HASH_JSON)
        local names = a:entryNames()
        expect_type("table", names)
        expect_equal(2, #names)
    end)

    -- @covers lurek.sprite.parseAtlas
    it("errors on invalid JSON", function()
        expect_error(function()
            lurek.sprite.parseAtlas("not json at all")
        end)
    end)

    -- @covers lurek.sprite.parseAtlas
    it("errors on malformed TexturePacker frame payload", function()
        expect_error(function()
            lurek.sprite.parseAtlas('{"frames":{"broken":{"rotated":false}}}')
        end)
    end)

-- newAtlasSheet

    -- @describe newAtlasSheet()
    describe("newAtlasSheet()", function()
        -- @covers lurek.sprite.newAtlasSheet
        -- @covers lurek.sprite.parseAtlas
        it("returns a userdata", function()
            local json = [[{"frames":{"a":{"frame":{"x":0,"y":0,"w":16,"h":16},"rotated":false}}}]]
            local atlas = lurek.sprite.parseAtlas(json)
            local s = lurek.sprite.newAtlasSheet(atlas, 64, 64)
            expect_type("userdata", s)
        end)

        -- @covers LSpriteSheet:getFrameCount
        -- @covers lurek.sprite.newAtlasSheet
        -- @covers lurek.sprite.parseAtlas
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

-- ============================================================
-- Merged from test_sprite_aseprite.lua
-- ============================================================

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

-- @describe sprite.parseAsepriteAtlas
describe("sprite.parseAsepriteAtlas", function()

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("parseAsepriteAtlas exists in lurek.sprite", function()
        expect_equal(type(lurek.sprite.parseAsepriteAtlas), "function")
    end)

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("parses array-format Aseprite JSON without error", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        expect_equal(atlas ~= nil, true)
    end)

    -- @covers LSpriteAtlas:entryCount
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("returns atlas with correct entry count from array format", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        expect_equal(atlas:entryCount(), 3)
    end)

    -- @covers LSpriteAtlas:entryCount
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("parses hash-format Aseprite JSON without error", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_HASH_JSON)
        expect_equal(atlas:entryCount(), 2)
    end)

    -- @covers LSpriteAtlas:getEntry
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getEntry returns correct region from array-format atlas", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local e = atlas:getEntry("hero/run_0.png")
        expect_equal(e ~= nil, true)
        expect_equal(e.x, 64)
        expect_equal(e.y, 0)
        expect_equal(e.w, 32)
        expect_equal(e.h, 32)
    end)

    -- @covers LSpriteAtlas:getEntry
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getEntry returns correct region from hash-format atlas", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_HASH_JSON)
        local e = atlas:getEntry("bullet_1.png")
        expect_equal(e ~= nil, true)
        expect_equal(e.x, 8)
        expect_equal(e.w, 8)
    end)

    -- @covers LSpriteAtlas:getEntry
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getEntry returns nil for unknown name", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local e = atlas:getEntry("nonexistent.png")
        expect_equal(e, nil)
    end)

    -- @covers LSpriteAtlas:entryNames
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("entryNames returns all frame names", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local names = atlas:entryNames()
        expect_equal(type(names), "table")
        expect_equal(#names, 3)
    end)

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("raises error for invalid JSON", function()
        expect_error(function()
            lurek.sprite.parseAsepriteAtlas("not json {{{")
        end)
    end)

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("raises error for JSON missing 'frames' key", function()
        expect_error(function()
            lurek.sprite.parseAsepriteAtlas('{"meta":{}}')
        end)
    end)

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("raises error for malformed Aseprite frame rect", function()
        expect_error(function()
            lurek.sprite.parseAsepriteAtlas('{"frames":{"hero.png":{"duration":100}},"meta":{"size":{"w":32,"h":32}}}')
        end)
    end)

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("raises error for array frames missing filename on the error path", function()
        expect_error(function()
            lurek.sprite.parseAsepriteAtlas('{"frames":[{"frame":{"x":0,"y":0,"w":16,"h":16}}],"meta":{"size":{"w":16,"h":16}}}')
        end)
    end)

end)

-- @describe sprite.atlas.getFlipped
describe("sprite.atlas.getFlipped", function()

    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getFlipped exists on SpriteAtlas userdata", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        expect_equal(type(atlas.getFlipped), "function")
    end)

    -- @covers LSpriteAtlas:getFlipped
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getFlipped returns a table with flip_x and flip_y set", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local flipped = atlas:getFlipped("hero/idle_0.png", true, false)
        expect_equal(type(flipped), "table")
        expect_equal(flipped.flip_x, true)
        expect_equal(flipped.flip_y, false)
    end)

    -- @covers LSpriteAtlas:getEntry
    -- @covers LSpriteAtlas:getFlipped
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getFlipped preserves source region coordinates", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local orig  = atlas:getEntry("hero/idle_0.png")
        local flipped = atlas:getFlipped("hero/idle_0.png", true, true)
        expect_equal(flipped.x, orig.x)
        expect_equal(flipped.y, orig.y)
        expect_equal(flipped.w, orig.w)
        expect_equal(flipped.h, orig.h)
    end)

    -- @covers LSpriteAtlas:getFlipped
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("getFlipped returns nil for unknown name", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local result = atlas:getFlipped("ghost.png", true, false)
        expect_equal(result, nil)
    end)

    -- @covers LSpriteAtlas:getFlipped
    -- @covers lurek.sprite.parseAtlas
    it("getFlipped works on TexturePacker atlas too", function()
        local tp_json = '{"frames":{"sword.png":{"frame":{"x":0,"y":0,"w":16,"h":32},"rotated":false}}}'
        local atlas = lurek.sprite.parseAtlas(tp_json)
        local flipped = atlas:getFlipped("sword.png", false, true)
        expect_equal(flipped.flip_y, true)
        expect_equal(flipped.w, 16)
    end)

end)

-- @describe lurek.sprite regression coverage
describe("lurek.sprite regression coverage", function()
    -- @covers LSpriteAtlas:entryCount
    -- @covers LSpriteAtlas:entryNames
    -- @covers LSpriteAtlas:getByIndex
    -- @covers LSpriteAtlas:getEntry
    -- @covers lurek.sprite.parseAsepriteAtlas
    it("parseAsepriteAtlas exposes atlas entries through every lookup helper", function()
        local atlas = lurek.sprite.parseAsepriteAtlas(ASEPRITE_ARRAY_JSON)
        local entry = atlas:getEntry("hero/run_0.png")
        local indexed = atlas:getByIndex(2)
        local names = atlas:entryNames()

        expect_equal(3, atlas:entryCount())
        expect_type("table", entry)
        expect_equal(64, entry.x)
        expect_equal(32, entry.w)
        expect_type("table", indexed)
        expect_equal("hero/idle_1.png", indexed.name)
        expect_equal(3, #names)

        local seen = {}
        for _, name in ipairs(names) do
            seen[name] = true
        end
        expect_true(seen["hero/idle_0.png"] ~= nil, "expected hero/idle_0.png in names")
        expect_true(seen["hero/run_0.png"] ~= nil, "expected hero/run_0.png in names")
    end)

    -- @covers LSpriteSheet:getColumn
    -- @covers LSpriteSheet:getFrame
    -- @covers LSpriteSheet:getFrameCount
    -- @covers LSpriteSheet:getFrameSize
    -- @covers LSpriteSheet:getGridSize
    -- @covers LSpriteSheet:getRow
    -- @covers lurek.sprite.newSheet
    it("SpriteSheet geometry helpers stay consistent", function()
        local sheet = lurek.sprite.newSheet(96, 64, 32, 32)
        local frame = sheet:getFrame(4)
        local row = sheet:getRow(1)
        local column = sheet:getColumn(1)
        local frame_w, frame_h = sheet:getFrameSize()
        local cols, rows = sheet:getGridSize()

        expect_equal(6, sheet:getFrameCount())
        expect_equal(32, frame.x)
        expect_equal(32, frame.y)
        expect_equal(3, #row)
        expect_equal(2, #column)
        expect_equal(0, row[1].x)
        expect_equal(32, row[1].y)
        expect_equal(32, column[1].x)
        expect_equal(32, column[2].y)
        expect_equal(32, frame_w)
        expect_equal(32, frame_h)
        expect_equal(3, cols)
        expect_equal(2, rows)
    end)

    -- @covers LSpriteSheet:drawToImage
    -- @covers LSpriteSheet:getGroupFrames
    -- @covers LSpriteSheet:getGroupNames
    -- @covers LSpriteSheet:nameGroup
    -- @covers lurek.sprite.newSheet
    it("SpriteSheet group helpers and drawToImage return usable results", function()
        local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
        sheet:nameGroup("idle", 0, 2)
        sheet:nameGroup("run", 2, 4)

        local idle = sheet:getGroupFrames("idle")
        local names = sheet:getGroupNames()
        local image = sheet:drawToImage(64, 64)

        expect_type("table", idle)
        expect_equal(2, #idle)
        expect_equal(2, #names)
        expect_type("userdata", image)
    end)
end)

-- @describe sprite strict: LSpriteSheet type/typeOf
describe("sprite strict: LSpriteSheet type/typeOf", function()
    -- @covers LSpriteSheet:type
    -- @covers LSpriteSheet:typeOf
    -- @covers lurek.sprite.newSheet
    it("LSpriteSheet type and typeOf are callable", function()
        local s = lurek.sprite.newSheet(64, 64, 16, 16)
        expect_type("string", s:type())
        expect_type("boolean", s:typeOf("LObject"))
    end)

end)

-- @describe sprite strict: LSpriteAtlas type/typeOf
describe("sprite strict: LSpriteAtlas type/typeOf", function()
    -- @covers LSpriteAtlas:type
    -- @covers LSpriteAtlas:typeOf
    -- @covers lurek.sprite.parseAtlas
    it("LSpriteAtlas type and typeOf are callable", function()
        local ok, atlas = pcall(function()
            return lurek.sprite.parseAtlas('{"frames":{},"meta":{"size":{"w":64,"h":64}}}')
        end)
        if ok and atlas ~= nil then
            expect_type("string", atlas:type())
            expect_type("boolean", atlas:typeOf("LObject"))
        else
            expect_false(ok and atlas ~= nil)
        end
    end)
end)

test_summary()
