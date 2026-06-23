-- content/examples/sprite.lua
-- Auto-generated from content/examples2/sprite_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/sprite.lua





--- Sprite Module: sheets, atlases, packing, lit sprites, and frame animation.

--@api: lurek.sprite.newSheet
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local frames = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    sprite_log("newSheet type=" .. sheet:type() .. " frames=" .. frames .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
end

--@api: LSpriteSheet:getFrame
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local first = sheet:getFrame(0)
    local second = sheet:getFrame(1)
    local count = sheet:getFrameCount()
    sprite_log("getFrame count=" .. count .. " first=" .. first.x .. "," .. first.y .. " second=" .. second.x .. "," .. second.y)
end

--@api: LSpriteSheet:getRow
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local row = sheet:getRow(0)
    local first = row[1]
    local last = row[#row]
    sprite_log("getRow size=" .. #row .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end

--@api: LSpriteSheet:getColumn
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local column = sheet:getColumn(1)
    local first = column[1]
    local last = column[#column]
    sprite_log("getColumn size=" .. #column .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
end

--@api: LSpriteSheet:nameGroup
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("run", 0, 4)
    local names = sheet:getGroupNames()
    local frames = sheet:getGroupFrames("run")
    sprite_log("nameGroup groups=" .. #names .. " run_frames=" .. #frames .. " first_group=" .. tostring(names[1]))
end

--@api: LSpriteSheet:getGroupFrames
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("idle", 0, 2)
    sheet:nameGroup("walk", 2, 4)
    local walk = sheet:getGroupFrames("walk")
    sprite_log("getGroupFrames walk_size=" .. #walk .. " first=" .. walk[1].x .. "," .. walk[1].y .. " last=" .. walk[#walk].x .. "," .. walk[#walk].y)
end

--@api: LSpriteSheet:getGroupNames
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newRPGMakerSheet(144, 192)
    local names = sheet:getGroupNames()
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    sprite_log("getGroupNames count=" .. #names .. " first=" .. tostring(names[1]) .. " frames=" .. count .. " grid=" .. cols .. "x" .. rows)
end

--@api: LSpriteSheet:drawToImage
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("idle", 0, 2)
    local image = sheet:drawToImage(64, 64)
    local width = image:getWidth()
    local height = image:getHeight()
    sprite_log("drawToImage preview=" .. width .. "x" .. height .. " groups=" .. #sheet:getGroupNames())
end

--@api: lurek.sprite.newRPGMakerSheet
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newRPGMakerSheet(144, 192)
    local count = sheet:getFrameCount()
    local fw, fh = sheet:getFrameSize()
    local names = sheet:getGroupNames()
    sprite_log("newRPGMakerSheet frames=" .. count .. " frame=" .. fw .. "x" .. fh .. " first_group=" .. tostring(names[1]))
end

--@api: lurek.sprite.parseAtlas
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local entry = atlas:getEntry("hero_idle_0")
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    sprite_log("parseAtlas count=" .. count .. " first=" .. tostring(names[1]) .. " hero=" .. entry.w .. "x" .. entry.h)
end

--@api: LSpriteAtlas:getEntry
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local entry = atlas:getEntry("hero_idle_1")
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    sprite_log("getEntry names=" .. #names .. " count=" .. count .. " hero_idle_1=" .. entry.x .. "," .. entry.y .. "," .. entry.w .. "x" .. entry.h)
end

--@api: LSpriteAtlas:getByIndex
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local first = atlas:getByIndex(1)
    local second = atlas:getByIndex(2)
    local count = atlas:entryCount()
    sprite_log("getByIndex count=" .. count .. " first=" .. first.name .. " second=" .. second.name)
end

--@api: LSpriteAtlas:getFlipped
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local flipped = atlas:getFlipped("arrow_right", true, false)
    local base = atlas:getEntry("arrow_right")
    local same_size = flipped.w == base.w and flipped.h == base.h
    sprite_log("getFlipped flip_x=" .. tostring(flipped.flip_x) .. " flip_y=" .. tostring(flipped.flip_y) .. " same_size=" .. tostring(same_size))
end

--@api: lurek.sprite.parseAsepriteAtlas
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local entry = atlas:getEntry("hero_walk_0001.png")
    local names = atlas:entryNames()
    local count = atlas:entryCount()
    sprite_log("parseAsepriteAtlas count=" .. count .. " first=" .. tostring(names[1]) .. " hero=" .. entry.w .. "x" .. entry.h)
end

--@api: lurek.sprite.newAtlasSheet
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local sheet = lurek.sprite.newAtlasSheet(atlas, 64, 64)
    local count = sheet:getFrameCount()
    local first = sheet:getFrame(0)
    local fw, fh = sheet:getFrameSize()
    sprite_log("newAtlasSheet type=" .. sheet:type() .. " frames=" .. count .. " frame=" .. fw .. "x" .. fh .. " first=" .. first.x .. "," .. first.y)
end

--@api: lurek.sprite.newAtlasPacker
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local width, height = packer:getDimensions()
    local count = packer:regionCount()
    local kind = packer:type()
    sprite_log("newAtlasPacker type=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
end

--@api: LAtlasPacker:pack
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local ok = packer:pack("hero", 24, 24)
    local region = packer:getRegion("hero")
    local count = packer:regionCount()
    sprite_log("pack ok=" .. tostring(ok) .. " count=" .. count .. " hero=" .. region.x .. "," .. region.y .. "," .. region.w .. "x" .. region.h)
end

--@api: LAtlasPacker:getRegion
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    local region = packer:getRegion("hero")
    local width, height = packer:getDimensions()
    sprite_log("getRegion hero=" .. region.name .. " at " .. region.x .. "," .. region.y .. " atlas=" .. width .. "x" .. height)
end

--@api: LAtlasPacker:regionCount
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    packer:pack("coin", 16, 16)
    local count = packer:regionCount()
    sprite_log("regionCount count=" .. count .. " has_coin=" .. tostring(packer:getRegion("coin") ~= nil))
end

--@api: LAtlasPacker:getDimensions
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local width, height = packer:getDimensions()
    local kind = packer:type()
    local count = packer:regionCount()
    sprite_log("getDimensions type=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
end

--@api: LAtlasPacker:setNineSlice
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("panel", 24, 24)
    local ok = packer:setNineSlice("panel", 4, 4, 4, 4)
    local region = packer:getRegion("panel")
    sprite_log("setNineSlice ok=" .. tostring(ok) .. " region=" .. region.name .. " has_nine_slice=" .. tostring(region.nine_slice ~= nil))
end

--@api: LAtlasPacker:clear
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    packer:pack("coin", 16, 16)
    local before = packer:regionCount()
    packer:clear()
    sprite_log("clear before=" .. before .. " after=" .. packer:regionCount() .. " hero_exists=" .. tostring(packer:getRegion("hero") ~= nil))
end

--@api: LAtlasPacker:type
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local width, height = packer:getDimensions()
    local kind = packer:type()
    local count = packer:regionCount()
    sprite_log("type kind=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
end

--@api: LAtlasPacker:typeOf
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local is_packer = packer:typeOf("LAtlasPacker")
    local is_object = packer:typeOf("LObject")
    local width, height = packer:getDimensions()
    sprite_log("typeOf packer=" .. tostring(is_packer) .. " object=" .. tostring(is_object) .. " size=" .. width .. "x" .. height)
end

--@api: LSpriteSheet:getFrameCount
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    sprite_log("getFrameCount count=" .. count .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
end

--@api: LSpriteSheet:getFrameSize
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local fw, fh = sheet:getFrameSize()
    local cols, rows = sheet:getGridSize()
    local count = sheet:getFrameCount()
    sprite_log("getFrameSize frame=" .. fw .. "x" .. fh .. " grid=" .. cols .. "x" .. rows .. " count=" .. count)
end

--@api: LSpriteSheet:getGridSize
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local cols, rows = sheet:getGridSize()
    local count = sheet:getFrameCount()
    local fw, fh = sheet:getFrameSize()
    sprite_log("getGridSize grid=" .. cols .. "x" .. rows .. " count=" .. count .. " frame=" .. fw .. "x" .. fh)
end

--@api: LSpriteSheet:type
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local kind = sheet:type()
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    sprite_log("sheet type=" .. kind .. " frames=" .. count .. " grid=" .. cols .. "x" .. rows)
end

--@api: LSpriteSheet:typeOf
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local is_sheet = sheet:typeOf("LSpriteSheet")
    local is_object = sheet:typeOf("LObject")
    local count = sheet:getFrameCount()
    sprite_log("sheet typeOf sheet=" .. tostring(is_sheet) .. " object=" .. tostring(is_object) .. " frames=" .. count)
end

--@api: LSpriteAtlas:entryCount
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    local entry = atlas:getEntry(names[1])
    sprite_log("entryCount count=" .. count .. " first=" .. tostring(names[1]) .. " size=" .. entry.w .. "x" .. entry.h)
end

--@api: LSpriteAtlas:entryNames
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local names = atlas:entryNames()
    local count = atlas:entryCount()
    local second = names[2] or "none"
    sprite_log("entryNames count=" .. count .. " first=" .. tostring(names[1]) .. " second=" .. tostring(second))
end

--@api: LSpriteAtlas:type
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local kind = atlas:type()
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    sprite_log("atlas type=" .. kind .. " count=" .. count .. " first=" .. tostring(names[1]))
end

--@api: LSpriteAtlas:typeOf
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local is_atlas = atlas:typeOf("LSpriteAtlas")
    local is_object = atlas:typeOf("LObject")
    local count = atlas:entryCount()
    sprite_log("atlas typeOf atlas=" .. tostring(is_atlas) .. " object=" .. tostring(is_object) .. " count=" .. count)
end

--@api: lurek.sprite.newSprite
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    local kind = sprite:type()
    sprite_log("newSprite type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:setNormalMap
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    local texture = sprite:getNormalMap()
    local has_normal = sprite:hasNormalMap()
    sprite_log("setNormalMap texture=" .. tostring(texture) .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:getNormalMap
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    local texture = sprite:getNormalMap()
    local intensity = sprite:getNormalIntensity()
    sprite_log("getNormalMap texture=" .. tostring(texture) .. " intensity=" .. tostring(intensity))
end

--@api: LSprite:hasNormalMap
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local before = sprite:hasNormalMap()
    sprite:setNormalMap(3)
    local after = sprite:hasNormalMap()
    sprite_log("hasNormalMap before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSprite:clearNormalMap
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(3)
    local before = sprite:hasNormalMap()
    sprite:clearNormalMap()
    sprite_log("clearNormalMap before=" .. tostring(before) .. " after=" .. tostring(sprite:hasNormalMap()))
end

--@api: LSprite:setNormalIntensity
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    sprite:setNormalIntensity(2.5)
    local intensity = sprite:getNormalIntensity()
    sprite_log("setNormalIntensity intensity=" .. tostring(intensity) .. " texture=" .. tostring(sprite:getNormalMap()))
end

--@api: LSprite:getNormalIntensity
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalIntensity(2.5)
    local intensity = sprite:getNormalIntensity()
    local x, y = sprite:getPosition()
    sprite_log("getNormalIntensity intensity=" .. tostring(intensity) .. " pos=" .. x .. "," .. y)
end

--@api: LSprite:setPosition
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setPosition(32, 48)
    local x, y = sprite:getPosition()
    local kind = sprite:type()
    sprite_log("setPosition type=" .. kind .. " pos=" .. x .. "," .. y)
end

--@api: LSprite:getPosition
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    local kind = sprite:type()
    sprite_log("getPosition type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:type
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local kind = sprite:type()
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    sprite_log("sprite type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
end

--@api: LSprite:typeOf
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local is_sprite = sprite:typeOf("LSprite")
    local is_object = sprite:typeOf("LObject")
    local x, y = sprite:getPosition()
    sprite_log("sprite typeOf sprite=" .. tostring(is_sprite) .. " object=" .. tostring(is_object) .. " pos=" .. x .. "," .. y)
end

--@api: lurek.sprite.newAnimator
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local kind = animator:type()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    sprite_log("newAnimator type=" .. kind .. " clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end

--@api: LSpriteAnimator:play
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    local clip = animator:currentClip()
    local row, col = animator:currentFrame()
    sprite_log("play clip=" .. tostring(clip) .. " frame=" .. row .. "," .. col)
end

--@api: LSpriteAnimator:pause
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:pause()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    sprite_log("pause clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end

--@api: LSpriteAnimator:resume
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:pause()
    animator:resume()
    sprite_log("resume clip=" .. tostring(animator:currentClip()) .. " playing=" .. tostring(animator:isPlaying()))
end

--@api: LSpriteAnimator:stop
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:update(0.2)
    animator:stop()
    local row, col = animator:currentFrame()
    sprite_log("stop frame_reset=" .. row .. "," .. col .. " playing=" .. tostring(animator:isPlaying()))
end

--@api: LSpriteAnimator:isPlaying
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local before = animator:isPlaying()
    animator:play("idle")
    local after = animator:isPlaying()
    sprite_log("isPlaying before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSpriteAnimator:currentClip
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local before = animator:currentClip()
    animator:play("idle")
    local after = animator:currentClip()
    sprite_log("currentClip before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api: LSpriteAnimator:currentFrame
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    local row1, col1 = animator:currentFrame()
    animator:update(0.11)
    local row2, col2 = animator:currentFrame()
    sprite_log("currentFrame before=" .. row1 .. "," .. col1 .. " after=" .. row2 .. "," .. col2)
end

--@api: LSpriteAnimator:update
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:update(0.11)
    local row, col = animator:currentFrame()
    local frame_duration = animator:frameDuration()
    sprite_log("update frame=" .. row .. "," .. col .. " frame_duration=" .. tostring(frame_duration))
end

--@api: LSpriteAnimator:onFrame
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local received = 0
    animator:onFrame(function() received = received + 1 end)
    animator:play("idle")
    animator:update(0.21)
    sprite_log("onFrame callbacks=" .. received .. " clip=" .. tostring(animator:currentClip()))
end

--@api: LSpriteAnimator:onLoop
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local loops = 0
    animator:onLoop(function() loops = loops + 1 end)
    animator:play("idle")
    animator:update(0.31)
    sprite_log("onLoop callbacks=" .. loops .. " clip=" .. tostring(animator:currentClip()))
end

--@api: LSpriteAnimator:onEnd
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local ended = 0
    animator:onEnd(function() ended = ended + 1 end)
    animator:play("jump")
    animator:update(1.0)
    sprite_log("onEnd callbacks=" .. ended .. " clip=" .. tostring(animator:currentClip()))
end

--@api: LSpriteAnimator:addClip
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:addClip("run", { row = 3, from = 1, to = 4, fps = 12, loop = true })
    animator:play("run")
    local row, col = animator:currentFrame()
    sprite_log("addClip clip=" .. tostring(animator:currentClip()) .. " frame=" .. row .. "," .. col)
end

--@api: LSpriteAnimator:frameDuration
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    local frame_duration = animator:frameDuration()
    local clip_duration = animator:clipDuration()
    sprite_log("frameDuration frame=" .. tostring(frame_duration) .. " clip=" .. tostring(clip_duration))
end

--@api: LSpriteAnimator:clipDuration
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("jump")
    local clip_duration = animator:clipDuration()
    local frame_duration = animator:frameDuration()
    sprite_log("clipDuration clip=" .. tostring(clip_duration) .. " frame=" .. tostring(frame_duration))
end

--@api: LSpriteAnimator:type
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local kind = animator:type()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    sprite_log("animator type=" .. kind .. " clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end

--@api: LSpriteAnimator:typeOf
do
    local function sprite_log(message)
        lurek.log.info("[sprite] " .. message)
    end
    local function make_texturepacker_json()
        return lurek.serial.toJson({
            frames = {
                { filename = "hero_idle_0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "hero_idle_1", frame = { x = 32, y = 0, w = 32, h = 32 }, rotated = false },
                { filename = "arrow_right", frame = { x = 0, y = 32, w = 32, h = 16 }, rotated = false },
            },
            meta = { size = { w = 64, h = 64 } },
        })
    end
    local function make_aseprite_json()
        return lurek.serial.toJson({
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
        })
    end
    local function make_clips()
        return {
            idle = { row = 1, from = 1, to = 3, fps = 10, loop = true },
            jump = { row = 2, from = 4, to = 5, fps = 5, loop = false },
        }
    end

    local animator = lurek.sprite.newAnimator(make_clips())
    local is_animator = animator:typeOf("LSpriteAnimator")
    local is_object = animator:typeOf("LObject")
    local kind = animator:type()
    sprite_log("animator typeOf animator=" .. tostring(is_animator) .. " object=" .. tostring(is_object) .. " type=" .. kind)
end
