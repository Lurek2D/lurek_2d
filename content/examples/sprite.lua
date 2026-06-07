-- content/examples/sprite.lua
-- Auto-generated from content/examples2/sprite_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/sprite.lua

--- Sprite Module: sheets, atlases, frames, groups, rows/columns, RPGMaker, Aseprite

--@api-stub: lurek.sprite.newSheet
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 512, 64, 64)
    print("type = " .. sheet:type())
    print("frame count = " .. sheet:getFrameCount())
end

--@api-stub: LSpriteSheet:getFrame
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(256, 128, 32, 32)
    local frame1 = sheet:getFrame(1)
    print("frame 1: x=" .. frame1.x .. " y=" .. frame1.y .. " w=" .. frame1.w .. " h=" .. frame1.h)
end

--@api-stub: LSpriteSheet:getRow
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(192, 192, 64, 64)
    local row0 = sheet:getRow(0)
    print("row 0 frames = " .. #row0)
    print("row 0 first frame = " .. row0[1].x .. "," .. row0[1].y)
end

--@api-stub: LSpriteSheet:getColumn
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(192, 192, 64, 64)
    local col0 = sheet:getColumn(0)
    print("col 0 frames = " .. #col0)
    print("col 0 second frame = " .. col0[2].x .. "," .. col0[2].y)
end

--@api-stub: LSpriteSheet:nameGroup
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    sheet:nameGroup("idle", 1, 4)
    print("group named = idle")
end

--@api-stub: LSpriteSheet:getGroupFrames
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    sheet:nameGroup("walk", 5, 8)
    local walkFrames = sheet:getGroupFrames("walk")
    print("walk frames = " .. #walkFrames)
end

--@api-stub: LSpriteSheet:getGroupNames
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    sheet:nameGroup("idle", 1, 4)
    local names = sheet:getGroupNames()
    print("groups = " .. #names)
    print("first group = " .. tostring(names[1]))
end

--@api-stub: LSpriteSheet:drawToImage
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(256, 256, 32, 32)
    local img = sheet:drawToImage(256, 256)
    print("preview image width = " .. img:getWidth())
    print("preview image height = " .. img:getHeight())
end

--@api-stub: lurek.sprite.newRPGMakerSheet
do
    local rpg = lurek.sprite.newRPGMakerSheet(384, 256)
    print("frame count = " .. rpg:getFrameCount())
    local fw, fh = rpg:getFrameSize()
    local cols, rows = rpg:getGridSize()
    print("frame size = " .. fw .. "x" .. fh .. " grid = " .. cols .. "x" .. rows)
end

--@api-stub: lurek.sprite.parseAtlas
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "player_idle_0", frame = { x = 0, y = 0, w = 64, h = 64 }, rotated = false } }, meta = { size = { w = 64, h = 64 } } }))
    local entry = atlas:getEntry("player_idle_0")
    print("entry count = " .. atlas:entryCount())
    print("player_idle_0 = " .. entry.w .. "x" .. entry.h)
end

--@api-stub: LSpriteAtlas:getEntry
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "coin_0", frame = { x = 0, y = 0, w = 16, h = 16 }, rotated = false } }, meta = { size = { w = 16, h = 16 } } }))
    local coin = atlas:getEntry("coin_0")
    print("coin_0: x=" .. coin.x .. " y=" .. coin.y .. " w=" .. coin.w .. " h=" .. coin.h)
    print("rotated = " .. tostring(coin.rotated))
end

--@api-stub: LSpriteAtlas:getByIndex
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "coin_0", frame = { x = 0, y = 0, w = 16, h = 16 }, rotated = false } }, meta = { size = { w = 16, h = 16 } } }))
    local byIdx = atlas:getByIndex(1)
    print("index 1 name = " .. byIdx.name)
end

--@api-stub: LSpriteAtlas:getFlipped
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "arrow_right", frame = { x = 0, y = 0, w = 32, h = 16 }, rotated = false } }, meta = { size = { w = 32, h = 16 } } }))
    local flippedH = atlas:getFlipped("arrow_right", true, false)
    print("flip_x = " .. tostring(flippedH.flip_x) .. " flip_y = " .. tostring(flippedH.flip_y))
    print("still same coords: x=" .. flippedH.x .. " w=" .. flippedH.w)
end

--@api-stub: lurek.sprite.parseAsepriteAtlas
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serial.toJson({ frames = { ["hero_idle_0.png"] = { frame = { x = 0, y = 0, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } } }, meta = { image = "hero.png", size = { w = 48, h = 48 }, scale = "1" } }))
    local entry = atlas:getEntry("hero_idle_0.png")
    print("aseprite atlas entries = " .. atlas:entryCount())
    print("hero_idle_0.png = " .. entry.w .. "x" .. entry.h)
end

--@api-stub: lurek.sprite.newAtlasSheet
do
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "f0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false } }, meta = { size = { w = 32, h = 32 } } }))
    local sheet = lurek.sprite.newAtlasSheet(atlas, 128, 32)
    print("frame count = " .. sheet:getFrameCount())
    print("atlas sheet type = " .. sheet:type())
end

--@api-stub: lurek.sprite.newAtlasPacker
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    print("atlas packer type = " .. packer:type())
end

--@api-stub: LAtlasPacker:pack
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local ok = packer:pack("hero", 24, 24)
    print("packed hero = " .. tostring(ok))
end

--@api-stub: LAtlasPacker:getRegion
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    local region = packer:getRegion("hero")
    print("region x = " .. (region and region.x or -1))
end

--@api-stub: LAtlasPacker:regionCount
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    print("region count = " .. packer:regionCount())
end

--@api-stub: LAtlasPacker:getDimensions
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local w, h = packer:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
end

--@api-stub: LAtlasPacker:setNineSlice
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    local ok = packer:setNineSlice("hero", 4, 4, 4, 4)
    print("set nine-slice = " .. tostring(ok))
end

--@api-stub: LAtlasPacker:clear
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    if packer:getRegion("hero") ~= nil and packer:getRegion("hero").nine_slice ~= nil then
        print("hero nine-slice left = " .. packer:getRegion("hero").nine_slice.left)
    end
    packer:clear()
    print("after clear count = " .. packer:regionCount())
end

--@api-stub: LAtlasPacker:type
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    print("type = " .. packer:type())
end

--@api-stub: LAtlasPacker:typeOf
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    print("typeOf LAtlasPacker = " .. tostring(packer:typeOf("LAtlasPacker")))
end

--- Sprite Module Part 1: LSpriteSheet advanced, newAtlasSheet, newRPGMakerSheet, parseAsepriteAtlas, parseAtlas

--@api-stub: LSpriteSheet:getFrameCount
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    print("frame_count = " .. sheet:getFrameCount())
end

--@api-stub: LSpriteSheet:getFrameSize
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local fw, fh = sheet:getFrameSize()
    print("frame_size = " .. fw .. "x" .. fh)
end

--@api-stub: LSpriteSheet:getGridSize
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local gw, gh = sheet:getGridSize()
    print("grid = " .. gw .. "x" .. gh)
end

--@api-stub: LSpriteSheet:type
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    print("type = " .. sheet:type())
end

--@api-stub: LSpriteSheet:typeOf
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    print("typeOf = " .. tostring(sheet:typeOf("LSpriteSheet")))
end

--@api-stub: LSpriteAtlas:entryCount
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("aseprite_count = " .. atlas:entryCount())
end

--@api-stub: LSpriteAtlas:entryNames
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    local names = atlas:entryNames()
    print("aseprite_names = " .. #names)
    print("first name = " .. tostring(names[1]))
end

--@api-stub: LSpriteAtlas:type
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("type = " .. atlas:type())
end

--@api-stub: LSpriteAtlas:typeOf
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("typeOf = " .. tostring(atlas:typeOf("LSpriteAtlas")))
end

--@api-stub: lurek.sprite.newSprite
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("sprite created = " .. tostring(sprite ~= nil))
end

--@api-stub: LSprite:setNormalMap
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    print("normal map set = " .. tostring(sprite:getNormalMap() == 11))
end

--@api-stub: LSprite:getNormalMap
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    print("normal map = " .. tostring(sprite:getNormalMap()))
end

--@api-stub: LSprite:hasNormalMap
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("has normal before = " .. tostring(sprite:hasNormalMap()))
    sprite:setNormalMap(3)
    print("has normal after = " .. tostring(sprite:hasNormalMap()))
end

--@api-stub: LSprite:clearNormalMap
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(3)
    sprite:clearNormalMap()
    print("has normal after clear = " .. tostring(sprite:hasNormalMap()))
end

--@api-stub: LSprite:setNormalIntensity
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalIntensity(2.5)
    print("normal intensity set")
end

--@api-stub: LSprite:getNormalIntensity
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalIntensity(2.5)
    print("normal intensity = " .. tostring(sprite:getNormalIntensity()))
end

--@api-stub: LSprite:setPosition
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setPosition(32, 48)
    local x, y = sprite:getPosition()
    print("position = " .. x .. "," .. y)
end

--@api-stub: LSprite:getPosition
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local x, y = sprite:getPosition()
    print("position = " .. x .. "," .. y)
end

--@api-stub: LSprite:type
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("type = " .. sprite:type())
end

--@api-stub: LSprite:typeOf
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("typeOf LSprite = " .. tostring(sprite:typeOf("LSprite")))
end

--@api-stub: lurek.sprite.newAnimator
do
    local anim = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true }
    })
    print("animator type = " .. anim:type())
end

--@api-stub: LSpriteAnimator:play
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    print("clip after play = " .. tostring(anim:currentClip()))
end

--@api-stub: LSpriteAnimator:pause
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:pause()
    print("is playing after pause = " .. tostring(anim:isPlaying()))
end

--@api-stub: LSpriteAnimator:resume
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:pause()
    anim:resume()
    print("is playing after resume = " .. tostring(anim:isPlaying()))
end

--@api-stub: LSpriteAnimator:stop
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:update(0.2)
    anim:stop()
    local _, col = anim:currentFrame()
    print("frame after stop = " .. tostring(col))
end

--@api-stub: LSpriteAnimator:isPlaying
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    print("is playing = " .. tostring(anim:isPlaying()))
end

--@api-stub: LSpriteAnimator:currentClip
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    print("current clip = " .. tostring(anim:currentClip()))
end

--@api-stub: LSpriteAnimator:currentFrame
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 2, from = 3, to = 4, fps = 10, loop = true } })
    anim:play("idle")
    local row, col = anim:currentFrame()
    print("frame = " .. row .. "," .. col)
end

--@api-stub: LSpriteAnimator:update
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:update(0.11)
    local _, col = anim:currentFrame()
    print("frame after update = " .. tostring(col))
end

--@api-stub: LSpriteAnimator:onFrame
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:onFrame(function(row, col, clip)
        print("onFrame " .. clip .. " " .. row .. ":" .. col)
    end)
    anim:play("idle")
    anim:update(0.11)
end

--@api-stub: LSpriteAnimator:onLoop
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 2, fps = 10, loop = true } })
    anim:onLoop(function(clip)
        print("onLoop " .. clip)
    end)
    anim:play("idle")
    anim:update(0.25)
end

--@api-stub: LSpriteAnimator:onEnd
do
    local anim = lurek.sprite.newAnimator({ jump = { row = 1, from = 1, to = 2, fps = 10, loop = false } })
    anim:onEnd(function(clip)
        print("onEnd " .. clip)
    end)
    anim:play("jump")
    anim:update(0.5)
end

--@api-stub: LSpriteAnimator:addClip
do
    local anim = lurek.sprite.newAnimator()
    anim:addClip("run", { row = 3, from = 1, to = 4, fps = 12, loop = true })
    anim:play("run")
    print("current clip after add = " .. tostring(anim:currentClip()))
end

--@api-stub: LSpriteAnimator:frameDuration
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 20, loop = true } })
    anim:play("idle")
    print("frame duration = " .. tostring(anim:frameDuration()))
end

--@api-stub: LSpriteAnimator:clipDuration
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 6, loop = true } })
    anim:play("idle")
    print("clip duration = " .. tostring(anim:clipDuration()))
end

--@api-stub: LSpriteAnimator:type
do
    local anim = lurek.sprite.newAnimator()
    print("type = " .. anim:type())
end

--@api-stub: LSpriteAnimator:typeOf
do
    local anim = lurek.sprite.newAnimator()
    print("typeOf LSpriteAnimator = " .. tostring(anim:typeOf("LSpriteAnimator")))
end
