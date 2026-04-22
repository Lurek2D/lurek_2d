-- content/examples/sprite.lua
-- love2d-style usage snippets for the lurek.sprite API (18 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/sprite.lua

-- ── lurek.sprite.* functions ──

--@api-stub: lurek.sprite.newSheet
-- Creates a sprite sheet with a uniform grid of `frame_w Ă— frame_h` frames.
-- Build once at startup; reuse across frames.
local sheet = lurek.sprite.newSheet(tw, th, fw, fh)
print("created", sheet)
return sheet

--@api-stub: lurek.sprite.newRPGMakerSheet
-- Creates an RPGMaker VX/Ace character sheet (3 cols Ă— 4 rows) with "down", "left", "right", "up" groups.
-- Build once at startup; reuse across frames.
local rpgmakersheet = lurek.sprite.newRPGMakerSheet(tw, th)
print("created", rpgmakersheet)
return rpgmakersheet

--@api-stub: lurek.sprite.parseAtlas
-- Parses a TexturePacker JSON string (hash or array format) and returns a SpriteAtlas.
-- See the module spec for detailed semantics.
local result = lurek.sprite.parseAtlas("hello")
print("parseAtlas:", result)
return result

--@api-stub: lurek.sprite.newAtlasSheet
-- Builds a SpriteSheet whose frames come from named entries in a SpriteAtlas.
-- Build once at startup; reuse across frames.
local atlassheet = lurek.sprite.newAtlasSheet(atlas_ud, sw, sh)
print("created", atlassheet)
return atlassheet

--@api-stub: lurek.sprite.parseAsepriteAtlas
-- Parses an Aseprite JSON export string and returns a `SpriteAtlas`.
-- See the module spec for detailed semantics.
local result = lurek.sprite.parseAsepriteAtlas("hello")
print("parseAsepriteAtlas:", result)
return result

-- ── SpriteSheet methods ──

--@api-stub: SpriteSheet:getFrame
-- Returns the quad for the 0-based frame index, or nil if out of range.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getFrame(1)
print("SpriteSheet:getFrame ->", value)

--@api-stub: SpriteSheet:getFrameCount
-- Returns the total number of frames in the sheet.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getFrameCount()
print("SpriteSheet:getFrameCount ->", value)

--@api-stub: SpriteSheet:getRow
-- Returns a sequential table of quad tables for every frame in the given row.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getRow(row)
print("SpriteSheet:getRow ->", value)

--@api-stub: SpriteSheet:getColumn
-- Returns a sequential table of quad tables for every frame in the given column.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getColumn(col)
print("SpriteSheet:getColumn ->", value)

--@api-stub: SpriteSheet:getGroupFrames
-- Returns a sequential table of quad tables for the named frame group, or nil.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getGroupFrames("main")
print("SpriteSheet:getGroupFrames ->", value)

--@api-stub: SpriteSheet:getGroupNames
-- Returns a sequential table of all defined group names.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getGroupNames()
print("SpriteSheet:getGroupNames ->", value)

--@api-stub: SpriteSheet:getFrameSize
-- Returns the width and height of a single frame cell in pixels.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getFrameSize()
print("SpriteSheet:getFrameSize ->", value)

--@api-stub: SpriteSheet:getGridSize
-- Returns the number of columns and rows in the grid.
-- Cheap to call; safe inside callbacks.
local spriteSheet = lurek.sprite.newSpriteSheet()  -- or your existing handle
local value = spriteSheet:getGridSize()
print("SpriteSheet:getGridSize ->", value)

--@api-stub: SpriteSheet:drawToImage
-- Renders the sheet grid as a debug view into a new ImageData.
-- Place inside `function lurek.render() ... end`.
local spriteSheet = lurek.sprite.newSpriteSheet()
spriteSheet:drawToImage(64, 64)
print("SpriteSheet:drawToImage done")

-- ── SpriteAtlas methods ──

--@api-stub: SpriteAtlas:getEntry
-- Returns the named region as a table `{name, x, y, w, h, rotated}`, or nil.
-- Cheap to call; safe inside callbacks.
local spriteAtlas = lurek.sprite.newSpriteAtlas()  -- or your existing handle
local value = spriteAtlas:getEntry("main")
print("SpriteAtlas:getEntry ->", value)

--@api-stub: SpriteAtlas:getByIndex
-- Returns the region at the given 1-based insertion index, or nil.
-- Cheap to call; safe inside callbacks.
local spriteAtlas = lurek.sprite.newSpriteAtlas()  -- or your existing handle
local value = spriteAtlas:getByIndex(1)
print("SpriteAtlas:getByIndex ->", value)

--@api-stub: SpriteAtlas:entryCount
-- Returns the total number of named regions in the atlas.
-- See the module spec for detailed semantics.
local spriteAtlas = lurek.sprite.newSpriteAtlas()
spriteAtlas:entryCount()
print("SpriteAtlas:entryCount done")

--@api-stub: SpriteAtlas:entryNames
-- Returns a sequential table of all region names.
-- See the module spec for detailed semantics.
local spriteAtlas = lurek.sprite.newSpriteAtlas()
spriteAtlas:entryNames()
print("SpriteAtlas:entryNames done")

