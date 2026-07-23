-- content/examples/sprite.lua
-- Auto-generated from content/examples2/sprite_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/sprite.lua





--- Sprite Module: sheets, atlases, packing, lit sprites, and frame animation.

local SPRITE_TEXTURE = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
local function sprite_texture_id()
    return SPRITE_TEXTURE:getId()
end

--@api: lurek.sprite.newNineSlice
do

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local slice = lurek.sprite.newNineSlice(image, 4, 4, 4, 4)
    local top, right, bottom, left = slice:getInsets()
    local width, height = slice:getTextureSize()
    lurek.log.info("newNineSlice insets=" .. top .. "," .. right .. "," .. bottom .. "," .. left)
    lurek.log.info("newNineSlice texture=" .. width .. "x" .. height)
end

--@api: lurek.sprite.newSheet
do

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local frames = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    lurek.log.info("newSheet type=" .. sheet:type() .. " frames=" .. frames .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
end

--@api: LSpriteSheet:getFrame
do

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local first = sheet:getFrame(1)
    local second = sheet:getFrame(1)
    local count = sheet:getFrameCount()
    lurek.log.info("getFrame count=" .. count .. " first=" .. first.x .. "," .. first.y .. " second=" .. second.x .. "," .. second.y)
end

--@api: LSpriteSheet:getRow
do

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local row = sheet:getRow(0)
    local first = row[1]
    local last = row[#row]
    lurek.log.info("getRow size=" .. #row .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end

--@api: LSpriteSheet:getColumn
do

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local column = sheet:getColumn(1)
    local first = column[1]
    local last = column[#column]
    lurek.log.info("getColumn size=" .. #column .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end

--@api: LSpriteSheet:nameGroup
do

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("run", 1, 4)
    local names = sheet:getGroupNames()
    local frames = sheet:getGroupFrames("run")
    lurek.log.info("nameGroup groups=" .. #names .. " run_frames=" .. #frames .. " first_group=" .. tostring(names[1]))
end

--@api: LSpriteSheet:getGroupFrames
do

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("idle", 1, 2)
    sheet:nameGroup("walk", 3, 4)
    local walk = sheet:getGroupFrames("walk")
    lurek.log.info("getGroupFrames walk_size=" .. #walk .. " first=" .. walk[1].x .. "," .. walk[1].y .. " last=" .. walk[#walk].x .. "," .. walk[#walk].y)
end

--@api: LSpriteSheet:getGroupNames
do

    local sheet = lurek.sprite.newRPGMakerSheet(144, 192)
    local names = sheet:getGroupNames()
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    lurek.log.info("getGroupNames count=" .. #names .. " first=" .. tostring(names[1]) .. " frames=" .. count .. " grid=" .. cols .. "x" .. rows)
end

--@api: LSpriteSheet:drawToImage
do

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("idle", 1, 2)
    local image = sheet:drawToImage(64, 64)
    local width = image:getWidth()
    local height = image:getHeight()
    lurek.log.info("drawToImage preview=" .. width .. "x" .. height .. " groups=" .. #sheet:getGroupNames())
end

--@api: lurek.sprite.newRPGMakerSheet
do

    local sheet = lurek.sprite.newRPGMakerSheet(144, 192)
    local count = sheet:getFrameCount()
    local fw, fh = sheet:getFrameSize()
    local names = sheet:getGroupNames()
    lurek.log.info("newRPGMakerSheet frames=" .. count .. " frame=" .. fw .. "x" .. fh .. " first_group=" .. tostring(names[1]))
end

--@api: lurek.sprite.parseAtlas
do

    local atlas = lurek.sprite.parseAtlas(lurek.serialize.toJson({
        frames = {
            { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
        },
        meta = { size = { w = 64, h = 64 } },
    }))
    local entry = atlas:getEntry("hero_idle_0")
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    lurek.log.info("parseAtlas count=" .. count .. " first=" .. tostring(names[1]) .. " hero=" .. entry.w .. "x" .. entry.h)
end

--@api: LSpriteAtlas:getEntry
do

    local atlas = lurek.sprite.parseAtlas(lurek.serialize.toJson({
        frames = {
            { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
        },
        meta = { size = { w = 64, h = 64 } },
    }))
    local entry = atlas:getEntry("hero_idle_1")
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    lurek.log.info("getEntry names=" .. #names .. " count=" .. count .. " hero_idle_1=" .. entry.x .. "," .. entry.y .. "," .. entry.w .. "x" .. entry.h)
end

--@api: LSpriteAtlas:getByIndex
do

    local atlas = lurek.sprite.parseAtlas(lurek.serialize.toJson({
        frames = {
            { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
        },
        meta = { size = { w = 64, h = 64 } },
    }))
    local first = atlas:getByIndex(1)
    local second = atlas:getByIndex(2)
    local count = atlas:entryCount()
    lurek.log.info("getByIndex count=" .. count .. " first=" .. first.name .. " second=" .. second.name)
end

--@api: LSpriteAtlas:getFlipped
do

    local atlas = lurek.sprite.parseAtlas(lurek.serialize.toJson({
        frames = {
            { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
        },
        meta = { size = { w = 64, h = 64 } },
    }))
    local flipped = atlas:getFlipped("arrow_right", true, false)
    local base = atlas:getEntry("arrow_right")
    local same_size = flipped.w == base.w and flipped.h == base.h
    lurek.log.info("getFlipped flip_x=" .. tostring(flipped.flip_x) .. " flip_y=" .. tostring(flipped.flip_y) .. " same_size=" .. tostring(same_size))
end

--@api: lurek.sprite.parseAsepriteAtlas
do

    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serialize.toJson({
        frames = {
            ["hero_walk_0001.png"] = {
                frame = { x = 0, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
            ["hero_walk_0002.png"] = {
                frame = { x = 16, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
        },
        meta = { image = "hero.png", size = { w = 32, h = 16 }, scale = "1" },
    }))
    local entry = atlas:getEntry("hero_walk_0001.png")
    local names = atlas:entryNames()
    local count = atlas:entryCount()
    lurek.log.info("parseAsepriteAtlas count=" .. count .. " first=" .. tostring(names[1]) .. " hero=" .. entry.w .. "x" .. entry.h)
end

--@api: lurek.sprite.newAtlasSheet
do

    local atlas = lurek.sprite.parseAtlas(lurek.serialize.toJson({
        frames = {
            { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
            { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
        },
        meta = { size = { w = 64, h = 64 } },
    }))
    local sheet = lurek.sprite.newAtlasSheet(atlas, 64, 64)
    local count = sheet:getFrameCount()
    local first = sheet:getFrame(1)
    local fw, fh = sheet:getFrameSize()
    lurek.log.info("newAtlasSheet type=" .. sheet:type() .. " frames=" .. count .. " frame=" .. fw .. "x" .. fh .. " first=" .. first.x .. "," .. first.y)
end

--@api: lurek.sprite.newAtlasPacker
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local width, height = packer:getDimensions()
    local count = packer:regionCount()
    local kind = packer:type()
    lurek.log.info("newAtlasPacker type=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
end

--@api: LAtlasPacker:pack
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local ok = packer:pack("hero", 24, 24)
    local region = packer:getRegion("hero")
    local count = packer:regionCount()
    lurek.log.info("pack ok=" .. tostring(ok) .. " count=" .. count .. " hero=" .. region.x .. "," .. region.y .. "," .. region.w .. "x" .. region.h)
end

--@api: LAtlasPacker:getRegion
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    local region = packer:getRegion("hero")
    local width, height = packer:getDimensions()
    lurek.log.info("getRegion hero=" .. region.name .. " at " .. region.x .. "," .. region.y .. " atlas=" .. width .. "x" .. height)
end

--@api: LAtlasPacker:regionCount
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    packer:pack("coin", 16, 16)
    local count = packer:regionCount()
    lurek.log.info("regionCount count=" .. count .. " has_coin=" .. tostring(packer:getRegion("coin") ~= nil))
end

--@api: LAtlasPacker:getDimensions
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local width, height = packer:getDimensions()
    local kind = packer:type()
    local count = packer:regionCount()
    lurek.log.info("getDimensions type=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
end

--@api: LAtlasPacker:setNineSlice
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("panel", 24, 24)
    local ok = packer:setNineSlice("panel", 4, 4, 4, 4)
    local region = packer:getRegion("panel")
    lurek.log.info("setNineSlice ok=" .. tostring(ok) .. " region=" .. region.name .. " has_nine_slice=" .. tostring(region.nine_slice ~= nil))
end

--@api: LAtlasPacker:clear
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    packer:pack("coin", 16, 16)
    local before = packer:regionCount()
    packer:clear()
    lurek.log.info("clear before=" .. before .. " after=" .. packer:regionCount() .. " hero_exists=" .. tostring(packer:getRegion("hero") ~= nil))
end

--@api: LAtlasPacker:type
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local width, height = packer:getDimensions()
    local kind = packer:type()
    local count = packer:regionCount()
    lurek.log.info("type kind=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
end

--@api: LAtlasPacker:typeOf
do

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local is_packer = packer:typeOf("LAtlasPacker")
    local is_object = packer:typeOf("LObject")
    local width, height = packer:getDimensions()
    lurek.log.info("typeOf packer=" .. tostring(is_packer) .. " object=" .. tostring(is_object) .. " size=" .. width .. "x" .. height)
end

--@api: LSpriteSheet:getFrameCount
do

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    lurek.log.info("getFrameCount count=" .. count .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
end

--@api: LSpriteSheet:getFrameSize
do

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local fw, fh = sheet:getFrameSize()
    local cols, rows = sheet:getGridSize()
    local count = sheet:getFrameCount()
    lurek.log.info("getFrameSize frame=" .. fw .. "x" .. fh .. " grid=" .. cols .. "x" .. rows .. " count=" .. count)
end

--@api: LSpriteSheet:getGridSize
do

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local cols, rows = sheet:getGridSize()
    local count = sheet:getFrameCount()
    local fw, fh = sheet:getFrameSize()
    lurek.log.info("getGridSize grid=" .. cols .. "x" .. rows .. " count=" .. count .. " frame=" .. fw .. "x" .. fh)
end

--@api: LSpriteSheet:type
do

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local kind = sheet:type()
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    lurek.log.info("sheet type=" .. kind .. " frames=" .. count .. " grid=" .. cols .. "x" .. rows)
end

--@api: LSpriteSheet:typeOf
do

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local is_sheet = sheet:typeOf("LSpriteSheet")
    local is_object = sheet:typeOf("LObject")
    local count = sheet:getFrameCount()
    lurek.log.info("sheet typeOf sheet=" .. tostring(is_sheet) .. " object=" .. tostring(is_object) .. " frames=" .. count)
end

--@api: LSpriteAtlas:entryCount
do

    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serialize.toJson({
        frames = {
            ["hero_walk_0001.png"] = {
                frame = { x = 0, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
            ["hero_walk_0002.png"] = {
                frame = { x = 16, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
        },
        meta = { image = "hero.png", size = { w = 32, h = 16 }, scale = "1" },
    }))
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    local entry = atlas:getEntry(names[1])
    lurek.log.info("entryCount count=" .. count .. " first=" .. tostring(names[1]) .. " size=" .. entry.w .. "x" .. entry.h)
end

--@api: LSpriteAtlas:entryNames
do

    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serialize.toJson({
        frames = {
            ["hero_walk_0001.png"] = {
                frame = { x = 0, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
            ["hero_walk_0002.png"] = {
                frame = { x = 16, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
        },
        meta = { image = "hero.png", size = { w = 32, h = 16 }, scale = "1" },
    }))
    local names = atlas:entryNames()
    local count = atlas:entryCount()
    local second = names[2] or "none"
    lurek.log.info("entryNames count=" .. count .. " first=" .. tostring(names[1]) .. " second=" .. tostring(second))
end

--@api: LSpriteAtlas:type
do

    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serialize.toJson({
        frames = {
            ["hero_walk_0001.png"] = {
                frame = { x = 0, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
            ["hero_walk_0002.png"] = {
                frame = { x = 16, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
        },
        meta = { image = "hero.png", size = { w = 32, h = 16 }, scale = "1" },
    }))
    local kind = atlas:type()
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    lurek.log.info("atlas type=" .. kind .. " count=" .. count .. " first=" .. tostring(names[1]))
end

--@api: LSpriteAtlas:typeOf
do

    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serialize.toJson({
        frames = {
            ["hero_walk_0001.png"] = {
                frame = { x = 0, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
            ["hero_walk_0002.png"] = {
                frame = { x = 16, y = 0, w = 16, h = 16 },
                rotated = false,
                sourceSize = { w = 16, h = 16 },
            },
        },
        meta = { image = "hero.png", size = { w = 32, h = 16 }, scale = "1" },
    }))
    local is_atlas = atlas:typeOf("LSpriteAtlas")
    local is_object = atlas:typeOf("LObject")
    local count = atlas:entryCount()
    lurek.log.info("atlas typeOf atlas=" .. tostring(is_atlas) .. " object=" .. tostring(is_object) .. " count=" .. count)
end

--@api: lurek.sprite.newSprite
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    local kind = sprite:type()
    lurek.log.info("newSprite type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:setShader
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "sprite" })
    sprite:setShader(shader)
    local target = sprite:getShader():getTarget()
    sprite:setShader(nil)
    lurek.log.info("setShader target=" .. target .. " cleared=" .. tostring(sprite:getShader() == nil))
end

--@api: LSprite:getShader
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "sprite" })
    sprite:setShader(shader)
    local bound = sprite:getShader()
    local id = bound:getId()
    lurek.log.info("getShader id=" .. id .. " target=" .. bound:getTarget())
end

--@api: LSprite:setShaderUniform
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "sprite" })
    sprite:setShader(shader)
    sprite:setShaderUniform("team_color", { 0.2, 0.6, 1.0, 1.0 })
    lurek.log.info("setShaderUniform team_color=" .. tostring(shader:hasUniform("team_color")))
end

--@api: LSprite:setNormalMap
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    sprite:setNormalMap(sprite_texture_id())
    local texture = sprite:getNormalMap()
    local has_normal = sprite:hasNormalMap()
    lurek.log.info("setNormalMap texture=" .. tostring(texture) .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:getNormalMap
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    sprite:setNormalMap(sprite_texture_id())
    local texture = sprite:getNormalMap()
    local intensity = sprite:getNormalIntensity()
    lurek.log.info("getNormalMap texture=" .. tostring(texture) .. " intensity=" .. tostring(intensity))
end

--@api: LSprite:hasNormalMap
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local before = sprite:hasNormalMap()
    sprite:setNormalMap(sprite_texture_id())
    local after = sprite:hasNormalMap()
    lurek.log.info("hasNormalMap before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSprite:clearNormalMap
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    sprite:setNormalMap(sprite_texture_id())
    local before = sprite:hasNormalMap()
    sprite:clearNormalMap()
    lurek.log.info("clearNormalMap before=" .. tostring(before) .. " after=" .. tostring(sprite:hasNormalMap()))
end

--@api: LSprite:setNormalIntensity
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    sprite:setNormalMap(sprite_texture_id())
    sprite:setNormalIntensity(2.5)
    local intensity = sprite:getNormalIntensity()
    lurek.log.info("setNormalIntensity intensity=" .. tostring(intensity) .. " texture=" .. tostring(sprite:getNormalMap()))
end

--@api: LSprite:getNormalIntensity
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    sprite:setNormalIntensity(2.5)
    local intensity = sprite:getNormalIntensity()
    local x, y = sprite:getPosition()
    lurek.log.info("getNormalIntensity intensity=" .. tostring(intensity) .. " pos=" .. x .. "," .. y)
end

--@api: LSprite:setPosition
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    sprite:setPosition(32, 48)
    local x, y = sprite:getPosition()
    local kind = sprite:type()
    lurek.log.info("setPosition type=" .. kind .. " pos=" .. x .. "," .. y)
end

--@api: LSprite:getPosition
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    local kind = sprite:type()
    lurek.log.info("getPosition type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:type
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local kind = sprite:type()
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    lurek.log.info("sprite type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:typeOf
do

    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 10, 20)
    local is_sprite = sprite:typeOf("LSprite")
    local is_object = sprite:typeOf("LObject")
    local x, y = sprite:getPosition()
    lurek.log.info("sprite typeOf sprite=" .. tostring(is_sprite) .. " object=" .. tostring(is_object) .. " pos=" .. x .. "," .. y)
end

--@api: lurek.sprite.newAnimator
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local kind = animator:type()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    lurek.log.info("newAnimator type=" .. kind .. " clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end

--@api: LSpriteAnimator:play
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    local clip = animator:currentClip()
    local row, col = animator:currentFrame()
    lurek.log.info("play clip=" .. tostring(clip) .. " frame=" .. row .. "," .. col)
end

--@api: LSpriteAnimator:pause
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    animator:pause()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    lurek.log.info("pause clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end

--@api: LSpriteAnimator:resume
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    animator:pause()
    animator:resume()
    lurek.log.info("resume clip=" .. tostring(animator:currentClip()) .. " playing=" .. tostring(animator:isPlaying()))
end

--@api: LSpriteAnimator:stop
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    animator:update(0.2)
    animator:stop()
    local row, col = animator:currentFrame()
    lurek.log.info("stop frame_reset=" .. row .. "," .. col .. " playing=" .. tostring(animator:isPlaying()))
end

--@api: LSpriteAnimator:isPlaying
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local before = animator:isPlaying()
    animator:play("idle")
    local after = animator:isPlaying()
    lurek.log.info("isPlaying before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSpriteAnimator:currentClip
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local before = animator:currentClip()
    animator:play("idle")
    local after = animator:currentClip()
    lurek.log.info("currentClip before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSpriteAnimator:currentFrame
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    local row1, col1 = animator:currentFrame()
    animator:update(0.11)
    local row2, col2 = animator:currentFrame()
    lurek.log.info("currentFrame before=" .. row1 .. "," .. col1 .. " after=" .. row2 .. "," .. col2)
end

--@api: LSpriteAnimator:update
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    animator:update(0.11)
    local row, col = animator:currentFrame()
    local frame_duration = animator:frameDuration()
    lurek.log.info("update frame=" .. row .. "," .. col .. " frame_duration=" .. tostring(frame_duration))
end

--@api: LSpriteAnimator:onFrame
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local received = 0
    animator:onFrame(function() received = received + 1 end)
    animator:play("idle")
    animator:update(0.21)
    lurek.log.info("onFrame callbacks=" .. received .. " clip=" .. tostring(animator:currentClip()))
end

--@api: LSpriteAnimator:onLoop
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local loops = 0
    animator:onLoop(function() loops = loops + 1 end)
    animator:play("idle")
    animator:update(0.31)
    lurek.log.info("onLoop callbacks=" .. loops .. " clip=" .. tostring(animator:currentClip()))
end

--@api: LSpriteAnimator:onEnd
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local ended = 0
    animator:onEnd(function() ended = ended + 1 end)
    animator:play("jump")
    animator:update(1.0)
    lurek.log.info("onEnd callbacks=" .. ended .. " clip=" .. tostring(animator:currentClip()))
end

--@api: LSpriteAnimator:addClip
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:addClip("run", { row = 3, from = 1, to = 4, fps = 12, loop = true })
    animator:play("run")
    local row, col = animator:currentFrame()
    lurek.log.info("addClip clip=" .. tostring(animator:currentClip()) .. " frame=" .. row .. "," .. col)
end

--@api: LSpriteAnimator:frameDuration
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("idle")
    local frame_duration = animator:frameDuration()
    local clip_duration = animator:clipDuration()
    lurek.log.info("frameDuration frame=" .. tostring(frame_duration) .. " clip=" .. tostring(clip_duration))
end

--@api: LSpriteAnimator:clipDuration
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    animator:play("jump")
    local clip_duration = animator:clipDuration()
    local frame_duration = animator:frameDuration()
    lurek.log.info("clipDuration clip=" .. tostring(clip_duration) .. " frame=" .. tostring(frame_duration))
end

--@api: LSpriteAnimator:type
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local kind = animator:type()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    lurek.log.info("animator type=" .. kind .. " clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end

--@api: LSpriteAnimator:typeOf
do

    local animator = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
        jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
    })
    local is_animator = animator:typeOf("LSpriteAnimator")
    local is_object = animator:typeOf("LObject")
    local kind = animator:type()
    lurek.log.info("animator typeOf animator=" .. tostring(is_animator) .. " object=" .. tostring(is_object) .. " type=" .. kind)
end
--@api: lurek.sprite.newSheetFromImage
do
    local image = lurek.image.newImageData(32, 16)
    image:fill(255, 255, 255, 255)
    local sheet = lurek.sprite.newSheetFromImage(image, { frameWidth = 16, frameHeight = 16 })
    local frames = sheet:toFrames()
    lurek.log.info("[sprite] image sheet frames=" .. tostring(#frames))
end

--@api: lurek.sprite.newAtlasFromImage
do
    local image = lurek.image.newImageData(16, 16)
    image:fill(255, 255, 255, 255)
    local json = '{"frames":{"part":{"frame":{"x":0,"y":0,"w":8,"h":8},"rotated":false}}}'
    local atlas = lurek.sprite.newAtlasFromImage(image, json)
    local entry = atlas:getEntry("part")
    lurek.log.info("[sprite] image atlas entry=" .. tostring(entry.w))
end

--@api: LSpriteSheet:toFrames
do
    local sheet = lurek.sprite.newSheet(32, 16, 16, 16)
    sheet:nameGroup("idle", 1, 2)
    local frames = sheet:toFrames("idle")
    local first = frames[1]
    lurek.log.info("[sprite] toFrames first=" .. tostring(first.w))
end

--@api: LSpriteSheet:toAnimationClip
do
    local sheet = lurek.sprite.newSheet(32, 16, 16, 16)
    sheet:nameGroup("idle", 1, 2)
    local clip = sheet:toAnimationClip({ group = "idle", name = "idle", fps = 8 })
    local frame_count = #clip.frames
    lurek.log.info("[sprite] clip frames=" .. tostring(frame_count))
end

--@api: lurek.sprite.newAutoTileSheet
do
    local image = lurek.image.newImageData(256, 16)
    image:fill(255, 255, 255, 255)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local count = sheet:getTileCount()
    lurek.log.info("[sprite] autotile count=" .. tostring(count))
end

--@api: LSpriteAutoTileSheet:getLayout
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local layout = sheet:getLayout()
    local count = sheet:getTileCount()
    lurek.log.info("[sprite] autotile layout=" .. layout .. " count=" .. tostring(count))
end

--@api: LSpriteAutoTileSheet:getDefaultMode
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local mode = sheet:getDefaultMode()
    local layout = sheet:getLayout()
    lurek.log.info("[sprite] autotile mode=" .. mode .. " layout=" .. layout)
end

--@api: LSpriteAutoTileSheet:getTileCount
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local count = sheet:getTileCount()
    local layout = sheet:getLayout()
    lurek.log.info("[sprite] autotile count=" .. tostring(count) .. " layout=" .. layout)
end

--@api: LSpriteAutoTileSheet:getQuad
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local quad = sheet:getQuad(2)
    local count = sheet:getTileCount()
    lurek.log.info("[sprite] autotile quad=" .. tostring(quad.x) .. " count=" .. tostring(count))
end

--@api: LSpriteAutoTileSheet:getBitmaskForTile
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local bitmask = sheet:getBitmaskForTile(1)
    local layout = sheet:getLayout()
    lurek.log.info("[sprite] autotile bitmask=" .. tostring(bitmask) .. " layout=" .. layout)
end

--@api: LSpriteAutoTileSheet:getTileForBitmask
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local tile = sheet:getTileForBitmask(0)
    local count = sheet:getTileCount()
    lurek.log.info("[sprite] autotile tile=" .. tostring(tile) .. " count=" .. tostring(count))
end

--@api: LSpriteAutoTileSheet:toFrames
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local frames = sheet:toFrames()
    local count = sheet:getTileCount()
    lurek.log.info("[sprite] autotile frames=" .. tostring(#frames) .. " count=" .. tostring(count))
end

--@api: LSpriteAutoTileSheet:type
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local kind = sheet:type()
    local layout = sheet:getLayout()
    lurek.log.info("[sprite] autotile type=" .. kind .. " layout=" .. layout)
end

--@api: LSpriteAutoTileSheet:typeOf
do
    local image = lurek.image.newImageData(256, 16)
    local sheet = lurek.sprite.newAutoTileSheet(image, "minimal16", { tileWidth = 16, tileHeight = 16 })
    local ok = sheet:typeOf("LObject")
    local kind = sheet:type()
    lurek.log.info("[sprite] autotile typeOf=" .. tostring(ok) .. " type=" .. kind)
end
