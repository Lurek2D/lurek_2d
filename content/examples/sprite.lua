-- content/examples/sprite.lua
-- Auto-generated from content/examples2/sprite_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/sprite.lua

--- Sprite Module: sheets, atlases, frames, groups, rows/columns, RPGMaker, Aseprite

--@api-stub: lurek.sprite.newSheet
-- Creating a grid-based sprite sheet.
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 512, 64, 64)
    print("type = " .. sheet:type())
    print("is LSpriteSheet = " .. tostring(sheet:typeOf("LSpriteSheet")))
    print("frame count = " .. sheet:getFrameCount())
    local fw, fh = sheet:getFrameSize()
    print("frame size = " .. fw .. "x" .. fh)
    local cols, rows = sheet:getGridSize()
    print("grid = " .. cols .. " cols x " .. rows .. " rows")
end

--@api-stub: LSpriteSheet:getFrame
-- Accessing individual frames by index.
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(256, 128, 32, 32)
    local frame1 = sheet:getFrame(1)
    print("frame 1: x=" .. frame1.x .. " y=" .. frame1.y .. " w=" .. frame1.w .. " h=" .. frame1.h)
    local frame2 = sheet:getFrame(2)
    print("frame 2: x=" .. frame2.x .. " y=" .. frame2.y .. " w=" .. frame2.w .. " h=" .. frame2.h)
    local lastIdx = sheet:getFrameCount()
    local lastFrame = sheet:getFrame(lastIdx)
    print("last frame (" .. lastIdx .. "): x=" .. lastFrame.x .. " y=" .. lastFrame.y)
end

--@api-stub: LSpriteSheet:getRow
--@api-stub: LSpriteSheet:getColumn
-- Accessing entire rows and columns.
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(192, 192, 64, 64)
    local cols, rows = sheet:getGridSize()
    print("grid = " .. cols .. "x" .. rows)
    local row0 = sheet:getRow(0)
    print("row 0 frames = " .. #row0)
    for i, f in ipairs(row0) do
        print("  frame " .. i .. ": x=" .. f.x .. " y=" .. f.y)
    end
    local col0 = sheet:getColumn(0)
    print("col 0 frames = " .. #col0)
    for i, f in ipairs(col0) do
        print("  frame " .. i .. ": x=" .. f.x .. " y=" .. f.y)
    end
end

--@api-stub: LSpriteSheet:nameGroup
--@api-stub: LSpriteSheet:getGroupFrames
--@api-stub: LSpriteSheet:getGroupNames
-- Named animation groups from frame ranges.
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    print("total frames = " .. sheet:getFrameCount())
    sheet:nameGroup("idle", 1, 4)
    sheet:nameGroup("walk", 5, 8)
    sheet:nameGroup("attack", 13, 6)
    sheet:nameGroup("death", 19, 4)
    local names = sheet:getGroupNames()
    print("groups = " .. #names)
    for _, name in ipairs(names) do
        print("  " .. name)
    end
    local walkFrames = sheet:getGroupFrames("walk")
    print("walk frames = " .. #walkFrames)
    for i, f in ipairs(walkFrames) do
        print("  walk " .. i .. ": x=" .. f.x .. " y=" .. f.y .. " w=" .. f.w)
    end
    local idleFrames = sheet:getGroupFrames("idle")
    print("idle frames = " .. #idleFrames)
end

--@api-stub: LSpriteSheet:drawToImage
-- Rendering the sheet grid as an image for debug preview.
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(256, 256, 32, 32)
    local img = sheet:drawToImage(256, 256)
    print("preview image width = " .. img:getWidth())
    print("preview image height = " .. img:getHeight())
end

--@api-stub: lurek.sprite.newRPGMakerSheet
-- RPG Maker character sprite layout.
do
    ---@type LSpriteSheet
    local rpg = lurek.sprite.newRPGMakerSheet(384, 256)
    print("rpg sheet type = " .. rpg:type())
    print("frame count = " .. rpg:getFrameCount())
    local fw, fh = rpg:getFrameSize()
    print("frame size = " .. fw .. "x" .. fh)
    local cols, rows = rpg:getGridSize()
    print("grid = " .. cols .. "x" .. rows)
    local frame1 = rpg:getFrame(1)
    print("frame 1: " .. frame1.x .. "," .. frame1.y .. " " .. frame1.w .. "x" .. frame1.h)
end

-- Parsing a TexturePacker-style atlas.
--@api-stub: lurek.sprite.parseAtlas
do
    local atlasJson = lurek.serial.toJson({
        frames = {
            { filename = "player_idle_0", frame = { x = 0, y = 0, w = 64, h = 64 }, rotated = false },
            { filename = "player_idle_1", frame = { x = 64, y = 0, w = 64, h = 64 }, rotated = false },
            { filename = "player_walk_0", frame = { x = 128, y = 0, w = 64, h = 64 }, rotated = false },
            { filename = "player_walk_1", frame = { x = 192, y = 0, w = 64, h = 64 }, rotated = false },
            { filename = "player_attack_0", frame = { x = 0, y = 64, w = 96, h = 96 }, rotated = false },
        },
        meta = { size = { w = 512, h = 512 } },
    })
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(atlasJson)
    print("atlas type = " .. atlas:type())
    print("is LSpriteAtlas = " .. tostring(atlas:typeOf("LSpriteAtlas")))
    print("entry count = " .. atlas:entryCount())
    local names = atlas:entryNames()
    print("entries:")
    for _, name in ipairs(names) do
        print("  " .. name)
    end
end

--@api-stub: LSpriteAtlas:getEntry
--@api-stub: LSpriteAtlas:getByIndex
-- Looking up atlas entries.
do
    local atlasJson = lurek.serial.toJson({
        frames = {
            { filename = "coin_0", frame = { x = 0, y = 0, w = 16, h = 16 }, rotated = false },
            { filename = "coin_1", frame = { x = 16, y = 0, w = 16, h = 16 }, rotated = false },
            { filename = "coin_2", frame = { x = 32, y = 0, w = 16, h = 16 }, rotated = false },
            { filename = "gem_0", frame = { x = 0, y = 16, w = 24, h = 24 }, rotated = false },
        },
        meta = { size = { w = 256, h = 256 } },
    })
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(atlasJson)
    local coin = atlas:getEntry("coin_0")
    print("coin_0: x=" .. coin.x .. " y=" .. coin.y .. " w=" .. coin.w .. " h=" .. coin.h)
    print("rotated = " .. tostring(coin.rotated))
    local gem = atlas:getEntry("gem_0")
    print("gem_0: x=" .. gem.x .. " y=" .. gem.y .. " w=" .. gem.w .. " h=" .. gem.h)
    local byIdx = atlas:getByIndex(1)
    print("index 1 name = " .. byIdx.name)
    local byIdx3 = atlas:getByIndex(3)
    print("index 3 name = " .. byIdx3.name)
end

--@api-stub: LSpriteAtlas:getFlipped
-- Getting flipped copies of atlas entries.
do
    local atlasJson = lurek.serial.toJson({
        frames = {
            { filename = "arrow_right", frame = { x = 0, y = 0, w = 32, h = 16 }, rotated = false },
            { filename = "arrow_up", frame = { x = 32, y = 0, w = 16, h = 32 }, rotated = false },
        },
        meta = { size = { w = 128, h = 128 } },
    })
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(atlasJson)
    local flippedH = atlas:getFlipped("arrow_right", true, false)
    print("flip_x = " .. tostring(flippedH.flip_x) .. " flip_y = " .. tostring(flippedH.flip_y))
    print("still same coords: x=" .. flippedH.x .. " w=" .. flippedH.w)
    local flippedBoth = atlas:getFlipped("arrow_up", true, true)
    print("both flipped: flip_x=" .. tostring(flippedBoth.flip_x) .. " flip_y=" .. tostring(flippedBoth.flip_y))
    local noFlip = atlas:getFlipped("arrow_right", false, false)
    print("no flip: flip_x=" .. tostring(noFlip.flip_x) .. " flip_y=" .. tostring(noFlip.flip_y))
end

--@api-stub: lurek.sprite.parseAsepriteAtlas
-- Parsing an Aseprite JSON atlas export.
do
    local aseJson = lurek.serial.toJson({
        frames = {
            ["hero_idle_0.png"] = { frame = { x = 0, y = 0, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } },
            ["hero_idle_1.png"] = { frame = { x = 48, y = 0, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } },
            ["hero_idle_2.png"] = { frame = { x = 96, y = 0, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } },
            ["hero_run_0.png"] = { frame = { x = 0, y = 48, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } },
            ["hero_run_1.png"] = { frame = { x = 48, y = 48, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } },
        },
        meta = { image = "hero.png", size = { w = 256, h = 256 }, scale = "1" },
    })
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAsepriteAtlas(aseJson)
    print("aseprite atlas entries = " .. atlas:entryCount())
    local names = atlas:entryNames()
    for _, name in ipairs(names) do
        local entry = atlas:getEntry(name)
        print("  " .. name .. ": " .. entry.w .. "x" .. entry.h .. " at " .. entry.x .. "," .. entry.y)
    end
end

--@api-stub: lurek.sprite.newAtlasSheet
-- Creating a sprite sheet from a parsed atlas.
do
    local atlasJson = lurek.serial.toJson({
        frames = {
            { filename = "f0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "f1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "f2", frame = { x = 64, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "f3", frame = { x = 96, y = 0, w = 32, h = 32 }, rotated = false },
        },
        meta = { size = { w = 128, h = 32 } },
    })
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(atlasJson)
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newAtlasSheet(atlas, 128, 32)
    print("atlas sheet type = " .. sheet:type())
    print("frame count = " .. sheet:getFrameCount())
    local fw, fh = sheet:getFrameSize()
    print("frame size = " .. fw .. "x" .. fh)
    local f1 = sheet:getFrame(1)
    print("frame 1: x=" .. f1.x .. " y=" .. f1.y)
end

-- Combining sheets, groups, and frame access for a game character.
--@api-stub: lurek.sprite.newSheet
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(384, 256, 48, 64)
    local cols, rows = sheet:getGridSize()
    print("character sheet: " .. cols .. "x" .. rows .. " = " .. sheet:getFrameCount() .. " frames")
    sheet:nameGroup("idle_down", 1, 4)
    sheet:nameGroup("idle_up", 5, 4)
    sheet:nameGroup("walk_down", 9, 6)
    sheet:nameGroup("walk_up", 15, 6)
    sheet:nameGroup("walk_left", 21, 6)
    sheet:nameGroup("walk_right", 27, 6)
    local groups = sheet:getGroupNames()
    print("animation groups:")
    for _, g in ipairs(groups) do
        local frames = sheet:getGroupFrames(g)
        print("  " .. g .. " = " .. #frames .. " frames")
    end
    local walkDown = sheet:getGroupFrames("walk_down")
    print("walk_down animation frames:")
    for i, f in ipairs(walkDown) do
        print("  " .. i .. ": x=" .. f.x .. " y=" .. f.y .. " w=" .. f.w .. " h=" .. f.h)
    end
end

-- Different texture and frame sizes.
--@api-stub: lurek.sprite.newSheet
do
    ---@type LSpriteSheet
    local tiny = lurek.sprite.newSheet(64, 64, 8, 8)
    print("tiny: " .. tiny:getFrameCount() .. " frames of 8x8")
    ---@type LSpriteSheet
    local wide = lurek.sprite.newSheet(1024, 64, 128, 64)
    print("wide: " .. wide:getFrameCount() .. " frames of 128x64")
    ---@type LSpriteSheet
    local tall = lurek.sprite.newSheet(64, 1024, 64, 128)
    print("tall: " .. tall:getFrameCount() .. " frames of 64x128")
    ---@type LSpriteSheet
    local single = lurek.sprite.newSheet(256, 256, 256, 256)
    print("single: " .. single:getFrameCount() .. " frame of 256x256")
end

--- Sprite Module Part 1: LSpriteSheet advanced, newAtlasSheet, newRPGMakerSheet, parseAsepriteAtlas, parseAtlas

--@api-stub: LSpriteSheet:getFrameCount
--@api-stub: LSpriteSheet:getFrameSize
--@api-stub: LSpriteSheet:getGridSize
--@api-stub: LSpriteSheet:type
--@api-stub: LSpriteSheet:typeOf
-- Sprite sheet frame, group, and grid queries, plus type introspection.
do
    local sheet = lurek.sprite.newSheet(16, 16, 64, 128)
    print("frame_count=" .. sheet:getFrameCount())
    local fw, fh = sheet:getFrameSize()
    print("frame_size=" .. fw .. "x" .. fh)
    local gw, gh = sheet:getGridSize()
    print("grid=" .. gw .. "x" .. gh)

    local frame = sheet:getFrame(0)
    print("frame0=" .. tostring(frame ~= nil))

    local row = sheet:getRow(0)
    print("row0_len=" .. #row)

    local col = sheet:getColumn(0)
    print("col0_len=" .. #col)

    sheet:nameGroup("walk", 0, 4)
    local names = sheet:getGroupNames()
    print("groups=" .. #names)
    local group_frames = sheet:getGroupFrames("walk")
    print("walk_frames=" .. #group_frames)

    local img = sheet:drawToImage(64, 128)
    print("sheet_img=" .. tostring(img ~= nil))

    print("type=" .. sheet:type())
    print("typeOf=" .. tostring(sheet:typeOf("LSpriteSheet")))
end

--@api-stub: LSpriteAtlas:entryCount
--@api-stub: LSpriteAtlas:entryNames
--@api-stub: LSpriteAtlas:type
--@api-stub: LSpriteAtlas:typeOf
-- Load an Aseprite JSON atlas into an LSpriteAtlas and query entries.
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("aseprite_count=" .. atlas:entryCount())
    local names = atlas:entryNames()
    print("aseprite_names=" .. #names)
    local e0 = atlas:getByIndex(0)
    print("e0=" .. tostring(e0 ~= nil))
    local entry = atlas:getEntry("hero_walk_0001.png")
    print("entry=" .. tostring(entry ~= nil))
    local flipped = atlas:getFlipped("hero_walk_0001.png", true, false)
    print("flipped=" .. tostring(flipped ~= nil))
    print("type=" .. atlas:type())
    print("typeOf=" .. tostring(atlas:typeOf("LSpriteAtlas")))
end

print("content/examples/sprite.lua")
