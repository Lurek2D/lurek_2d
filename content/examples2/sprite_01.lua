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

print("sprite_01.lua")
