-- content/examples/tilemap.lua
-- Lurek2D lurek.tilemap API Reference
-- Run with: cargo run -- content/examples/tilemap
--
-- Scenario: A top-down RPG with a multi-layer overworld, hex grid combat arenas,
-- isometric town views, chunk-streamed large maps, auto-tiling for terrain transitions,
-- procedural dungeon generation, and a TMX-imported village map.

print("=== lurek.tilemap — RPG Tilemap Systems ===\n")

-- =============================================================================
-- TileSet & TileMap Creation (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.tilemap.newTileSet ---------------------------------------
--@api-stub: lurek.tilemap.newTileSet
-- Demonstrates the proper usage of lurek.tilemap.newTileSet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newTileSet()
    local overworld_ts = lurek.tilemap.newTileSet("assets/tilesets/overworld.png", {
    tile_width = 16,
    tile_height = 16,
    columns = 20,
    spacing = 0,
    margin = 0
    })
    print("overworld tileset: 16x16 tiles, 20 columns")
end
local _ok, _err = pcall(demo_lurek_tilemap_newTileSet)

-- ---- Stub: lurek.tilemap.newTileMap ---------------------------------------
--@api-stub: lurek.tilemap.newTileMap
-- Demonstrates the proper usage of lurek.tilemap.newTileMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newTileMap()
    local overworld = lurek.tilemap.newTileMap(100, 80, 16, 16)
    print("overworld map: 100x80 tiles at 16x16 pixels each")
end
local _ok, _err = pcall(demo_lurek_tilemap_newTileMap)

-- ---- Stub: lurek.tilemap.newAutoTileSheet ---------------------------------
--@api-stub: lurek.tilemap.newAutoTileSheet
-- Auto-tile sheets handle terrain transitions automatically.
-- The sheet contains all 47 (or 16) tile variants for a terrain type.
local grass_auto = lurek.tilemap.newAutoTileSheet("assets/tilesets/grass_autotile.png", {
    tile_width = 16,
    tile_height = 16,
    layout = "blob47"  -- 47-tile blob pattern (Wang tiles)
})
print("grass auto-tile: blob47 layout (47 transition variants)")

-- ---- Stub: lurek.tilemap.newChunkMap --------------------------------------
--@api-stub: lurek.tilemap.newChunkMap
-- Demonstrates the proper usage of lurek.tilemap.newChunkMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newChunkMap()
    local world_chunks = lurek.tilemap.newChunkMap({
    chunk_width = 32,
    chunk_height = 32,
    tile_width = 16,
    tile_height = 16
    })
    print("chunk map: 32x32 tile chunks, streaming loader")
end
local _ok, _err = pcall(demo_lurek_tilemap_newChunkMap)

-- ---- Stub: lurek.tilemap.newIsoMap ----------------------------------------
--@api-stub: lurek.tilemap.newIsoMap
-- Demonstrates the proper usage of lurek.tilemap.newIsoMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newIsoMap()
    local town_iso = lurek.tilemap.newIsoMap({
    width = 20,
    height = 20,
    tile_width = 64,
    tile_height = 32
    })
    print("isometric town: 20x20 tiles at 64x32 diamond projection")
end
local _ok, _err = pcall(demo_lurek_tilemap_newIsoMap)

-- ---- Stub: lurek.tilemap.newMapBlock --------------------------------------
--@api-stub: lurek.tilemap.newMapBlock
-- Demonstrates the proper usage of lurek.tilemap.newMapBlock.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newMapBlock()
    local room_block = lurek.tilemap.newMapBlock(8, 6, {
    tile_width = 16,
    tile_height = 16,
    layers = 1
    })
    print("map block: 8x6 room template for dungeon assembly")
end
local _ok, _err = pcall(demo_lurek_tilemap_newMapBlock)

-- ---- Stub: lurek.tilemap.newMapGroup --------------------------------------
--@api-stub: lurek.tilemap.newMapGroup
-- Demonstrates the proper usage of lurek.tilemap.newMapGroup.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newMapGroup()
    local dungeon_group = lurek.tilemap.newMapGroup("dungeon_rooms")
    print("map group: 'dungeon_rooms' for procedural assembly")
end
local _ok, _err = pcall(demo_lurek_tilemap_newMapGroup)

-- ---- Stub: lurek.tilemap.newMapScript -------------------------------------
--@api-stub: lurek.tilemap.newMapScript
-- Demonstrates the proper usage of lurek.tilemap.newMapScript.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newMapScript()
    local gen_script = lurek.tilemap.newMapScript()
    print("map generation script created")
end
local _ok, _err = pcall(demo_lurek_tilemap_newMapScript)

-- ---- Stub: lurek.tilemap.newMapGen ----------------------------------------
--@api-stub: lurek.tilemap.newMapGen
-- Demonstrates the proper usage of lurek.tilemap.newMapGen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newMapGen()
    local map_gen = lurek.tilemap.newMapGen({
    width = 64,
    height = 64,
    seed = 42
    })
    print("map generator: 64x64, seed=42")
end
local _ok, _err = pcall(demo_lurek_tilemap_newMapGen)

-- =============================================================================
-- File Import (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.tilemap.loadTMX ------------------------------------------
--@api-stub: lurek.tilemap.loadTMX
-- Demonstrates the proper usage of lurek.tilemap.loadTMX.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_loadTMX()
    local village = lurek.tilemap.loadTMX("assets/maps/village.tmx")
    print("TMX loaded: village map (Tiled editor format)")
end
local _ok, _err = pcall(demo_lurek_tilemap_loadTMX)

-- ---- Stub: lurek.tilemap.fromLDtk ----------------------------------------
--@api-stub: lurek.tilemap.fromLDtk
-- Demonstrates the proper usage of lurek.tilemap.fromLDtk.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_fromLDtk()
    local ldtk_map = lurek.tilemap.fromLDtk("assets/maps/dungeon.ldtk")
    print("LDtk loaded: dungeon project")
end
local _ok, _err = pcall(demo_lurek_tilemap_fromLDtk)

-- ---- Stub: lurek.tilemap.newLargeMapRenderer ------------------------------
--@api-stub: lurek.tilemap.newLargeMapRenderer
-- Demonstrates the proper usage of lurek.tilemap.newLargeMapRenderer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_newLargeMapRenderer()
    local large_renderer = lurek.tilemap.newLargeMapRenderer(overworld, {
    chunk_size = 16,
    max_cached_chunks = 64
    })
    print("large map renderer: 16-tile chunks, 64 cache slots")
end
local _ok, _err = pcall(demo_lurek_tilemap_newLargeMapRenderer)

-- =============================================================================
-- Coordinate Conversions — Isometric (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.tilemap.toScreenIso --------------------------------------
--@api-stub: lurek.tilemap.toScreenIso
-- Demonstrates the proper usage of lurek.tilemap.toScreenIso.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_toScreenIso()
    local sx, sy = lurek.tilemap.toScreenIso(5, 3, 64, 32)
    print("iso tile (5,3) -> screen (" .. sx .. ", " .. sy .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_toScreenIso)

-- ---- Stub: lurek.tilemap.fromScreenIso ------------------------------------
--@api-stub: lurek.tilemap.fromScreenIso
-- Demonstrates the proper usage of lurek.tilemap.fromScreenIso.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_fromScreenIso()
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    print("screen -> iso tile (" .. tx .. ", " .. ty .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_fromScreenIso)

-- ---- Stub: lurek.tilemap.isoRotate ---------------------------------------
--@api-stub: lurek.tilemap.isoRotate
-- Demonstrates the proper usage of lurek.tilemap.isoRotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_isoRotate()
    local rx, ry = lurek.tilemap.isoRotate(5, 3, 1)  -- 1 = 90 degrees CW
    print("iso rotated (5,3) by 90°: (" .. rx .. ", " .. ry .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_isoRotate)

-- ---- Stub: lurek.tilemap.isoDirectionName ---------------------------------
--@api-stub: lurek.tilemap.isoDirectionName
-- Demonstrates the proper usage of lurek.tilemap.isoDirectionName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_isoDirectionName()
    print("direction 0: " .. lurek.tilemap.isoDirectionName(0))
end
local _ok, _err = pcall(demo_lurek_tilemap_isoDirectionName)

-- ---- Stub: lurek.tilemap.isoDirectionFromAngle ----------------------------
--@api-stub: lurek.tilemap.isoDirectionFromAngle
-- Demonstrates the proper usage of lurek.tilemap.isoDirectionFromAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_isoDirectionFromAngle()
    local dir = lurek.tilemap.isoDirectionFromAngle(math.rad(45))
    print("45 degrees -> iso direction: " .. dir)
end
local _ok, _err = pcall(demo_lurek_tilemap_isoDirectionFromAngle)

-- =============================================================================
-- Coordinate Conversions — Hex Grid (module-level functions)
-- =============================================================================

-- ---- Stub: lurek.tilemap.toScreenHex --------------------------------------
--@api-stub: lurek.tilemap.toScreenHex
-- Demonstrates the proper usage of lurek.tilemap.toScreenHex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_toScreenHex()
    local hx, hy = lurek.tilemap.toScreenHex(3, 2, 32)
    print("hex (3,2) -> screen (" .. hx .. ", " .. hy .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_toScreenHex)

-- ---- Stub: lurek.tilemap.fromScreenHex ------------------------------------
--@api-stub: lurek.tilemap.fromScreenHex
-- Demonstrates the proper usage of lurek.tilemap.fromScreenHex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_fromScreenHex()
    local hq, hr = lurek.tilemap.fromScreenHex(hx, hy, 32)
    print("screen -> hex (" .. hq .. ", " .. hr .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_fromScreenHex)

-- ---- Stub: lurek.tilemap.hexNeighbors -------------------------------------
--@api-stub: lurek.tilemap.hexNeighbors
-- Demonstrates the proper usage of lurek.tilemap.hexNeighbors.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexNeighbors()
    local neighbors = lurek.tilemap.hexNeighbors(3, 2)
    print("hex (3,2) neighbors: " .. #neighbors .. " cells")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexNeighbors)

-- ---- Stub: lurek.tilemap.hexDistance --------------------------------------
--@api-stub: lurek.tilemap.hexDistance
-- Demonstrates the proper usage of lurek.tilemap.hexDistance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexDistance()
    local hdist = lurek.tilemap.hexDistance(0, 0, 3, 2)
    print("hex distance (0,0) -> (3,2): " .. hdist)
end
local _ok, _err = pcall(demo_lurek_tilemap_hexDistance)

-- ---- Stub: lurek.tilemap.hexRound -----------------------------------------
--@api-stub: lurek.tilemap.hexRound
-- Demonstrates the proper usage of lurek.tilemap.hexRound.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexRound()
    local rq, rr = lurek.tilemap.hexRound(2.7, 1.3)
    print("hex round (2.7, 1.3) -> (" .. rq .. ", " .. rr .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexRound)

-- ---- Stub: lurek.tilemap.hexLine ------------------------------------------
--@api-stub: lurek.tilemap.hexLine
-- Demonstrates the proper usage of lurek.tilemap.hexLine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexLine()
    local line_cells = lurek.tilemap.hexLine(0, 0, 5, 3)
    print("hex line (0,0) -> (5,3): " .. #line_cells .. " cells")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexLine)

-- ---- Stub: lurek.tilemap.hexRing ------------------------------------------
--@api-stub: lurek.tilemap.hexRing
-- Demonstrates the proper usage of lurek.tilemap.hexRing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexRing()
    local ring = lurek.tilemap.hexRing(3, 2, 2)
    print("hex ring radius 2 around (3,2): " .. #ring .. " cells")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexRing)

-- ---- Stub: lurek.tilemap.hexSpiral ----------------------------------------
--@api-stub: lurek.tilemap.hexSpiral
-- Demonstrates the proper usage of lurek.tilemap.hexSpiral.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexSpiral()
    local spiral = lurek.tilemap.hexSpiral(3, 2, 3)
    print("hex spiral radius 3: " .. #spiral .. " cells (including center)")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexSpiral)

-- ---- Stub: lurek.tilemap.hexArea ------------------------------------------
--@api-stub: lurek.tilemap.hexArea
-- Demonstrates the proper usage of lurek.tilemap.hexArea.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexArea()
    local area = lurek.tilemap.hexArea(3, 2, 2)
    print("hex area radius 2: " .. #area .. " cells")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexArea)

-- ---- Stub: lurek.tilemap.hexRotate ----------------------------------------
--@api-stub: lurek.tilemap.hexRotate
-- Demonstrates the proper usage of lurek.tilemap.hexRotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexRotate()
    local rotq, rotr = lurek.tilemap.hexRotate(1, -2, 1)  -- 1 step CW
    print("hex rotate (1,-2) by 60°: (" .. rotq .. ", " .. rotr .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexRotate)

-- ---- Stub: lurek.tilemap.hexReflect ---------------------------------------
--@api-stub: lurek.tilemap.hexReflect
-- Demonstrates the proper usage of lurek.tilemap.hexReflect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_tilemap_hexReflect()
    local refq, refr = lurek.tilemap.hexReflect(3, -1, "q")
    print("hex reflect (3,-1) across q-axis: (" .. refq .. ", " .. refr .. ")")
end
local _ok, _err = pcall(demo_lurek_tilemap_hexReflect)

-- =============================================================================
-- TileSet Object Methods
-- =============================================================================

-- ---- Stub: TileSet:getFirstGid --------------------------------------------
--@api-stub: TileSet:getFirstGid
-- Demonstrates the proper usage of TileSet:getFirstGid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getFirstGid()
    print("tileset first GID: " .. overworld_ts:getFirstGid())
end
local _ok, _err = pcall(demo_TileSet_getFirstGid)

-- ---- Stub: TileSet:getTileCount -------------------------------------------
--@api-stub: TileSet:getTileCount
-- Demonstrates the proper usage of TileSet:getTileCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getTileCount()
    print("tileset tile count: " .. overworld_ts:getTileCount())
end
local _ok, _err = pcall(demo_TileSet_getTileCount)

-- ---- Stub: TileSet:getColumns ---------------------------------------------
--@api-stub: TileSet:getColumns
-- Demonstrates the proper usage of TileSet:getColumns.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getColumns()
    print("tileset columns: " .. overworld_ts:getColumns())
end
local _ok, _err = pcall(demo_TileSet_getColumns)

-- ---- Stub: TileSet:getTileWidth -------------------------------------------
--@api-stub: TileSet:getTileWidth
-- Demonstrates the proper usage of TileSet:getTileWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getTileWidth()
    print("tile width: " .. overworld_ts:getTileWidth() .. "px")
end
local _ok, _err = pcall(demo_TileSet_getTileWidth)

-- ---- Stub: TileSet:getTileHeight ------------------------------------------
--@api-stub: TileSet:getTileHeight
-- Demonstrates the proper usage of TileSet:getTileHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getTileHeight()
    print("tile height: " .. overworld_ts:getTileHeight() .. "px")
end
local _ok, _err = pcall(demo_TileSet_getTileHeight)

-- ---- Stub: TileSet:getTileDimensions --------------------------------------
--@api-stub: TileSet:getTileDimensions
-- Demonstrates the proper usage of TileSet:getTileDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getTileDimensions()
    local tw, th = overworld_ts:getTileDimensions()
    print("tile dimensions: " .. tw .. "x" .. th)
end
local _ok, _err = pcall(demo_TileSet_getTileDimensions)

-- ---- Stub: TileSet:getSpacing ---------------------------------------------
--@api-stub: TileSet:getSpacing
-- Demonstrates the proper usage of TileSet:getSpacing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getSpacing()
    print("tileset spacing: " .. overworld_ts:getSpacing() .. "px")
end
local _ok, _err = pcall(demo_TileSet_getSpacing)

-- ---- Stub: TileSet:getMargin ----------------------------------------------
--@api-stub: TileSet:getMargin
-- Demonstrates the proper usage of TileSet:getMargin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getMargin()
    print("tileset margin: " .. overworld_ts:getMargin() .. "px")
end
local _ok, _err = pcall(demo_TileSet_getMargin)

-- ---- Stub: TileSet:getQuad ------------------------------------------------
--@api-stub: TileSet:getQuad
-- Demonstrates the proper usage of TileSet:getQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getQuad()
    local quad = overworld_ts:getQuad(5)
    print("tile 5 quad: " .. tostring(quad))
end
local _ok, _err = pcall(demo_TileSet_getQuad)

-- ---- Stub: TileSet:getAnimation -------------------------------------------
--@api-stub: TileSet:getAnimation
-- Demonstrates the proper usage of TileSet:getAnimation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_getAnimation()
    local anim = overworld_ts:getAnimation(42)
    if anim then
    print("tile 42 animation: " .. #anim .. " frames")
    else
    print("tile 42: no animation")
end
local _ok, _err = pcall(demo_TileSet_getAnimation)

-- ---- Stub: TileSet:setSolid -----------------------------------------------
--@api-stub: TileSet:setSolid
-- Demonstrates the proper usage of TileSet:setSolid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_setSolid()
    overworld_ts:setSolid(1, true)   -- wall tile
    overworld_ts:setSolid(15, true)  -- rock tile
    print("tiles 1, 15 marked solid")
end
local _ok, _err = pcall(demo_TileSet_setSolid)

-- ---- Stub: TileSet:isSolid -----------------------------------------------
--@api-stub: TileSet:isSolid
-- Demonstrates the proper usage of TileSet:isSolid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileSet_isSolid()
    print("tile 1 solid: " .. tostring(overworld_ts:isSolid(1)))
    print("tile 0 solid: " .. tostring(overworld_ts:isSolid(0)))
end
local _ok, _err = pcall(demo_TileSet_isSolid)

-- =============================================================================
-- TileMap Object Methods — Layer management and tile access
-- =============================================================================

-- ---- Stub: TileMap:addTileSet ---------------------------------------------
--@api-stub: TileMap:addTileSet
-- Demonstrates the proper usage of TileMap:addTileSet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_addTileSet()
    overworld:addTileSet(overworld_ts)
    print("overworld tileset added to map")
end
local _ok, _err = pcall(demo_TileMap_addTileSet)

-- ---- Stub: TileMap:getTileSetCount ----------------------------------------
--@api-stub: TileMap:getTileSetCount
-- Demonstrates the proper usage of TileMap:getTileSetCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getTileSetCount()
    print("tilemap tilesets: " .. overworld:getTileSetCount())
end
local _ok, _err = pcall(demo_TileMap_getTileSetCount)

-- ---- Stub: TileMap:getTileSet ---------------------------------------------
--@api-stub: TileMap:getTileSet
-- Demonstrates the proper usage of TileMap:getTileSet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getTileSet()
    local ts_ref = overworld:getTileSet(0)
    print("tileset 0 retrieved: " .. tostring(ts_ref))
end
local _ok, _err = pcall(demo_TileMap_getTileSet)

-- ---- Stub: TileMap:addLayer -----------------------------------------------
--@api-stub: TileMap:addLayer
-- Demonstrates the proper usage of TileMap:addLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_addLayer()
    overworld:addLayer("ground")
    overworld:addLayer("decoration")
    overworld:addLayer("collision")
    print("3 layers added: ground, decoration, collision")
end
local _ok, _err = pcall(demo_TileMap_addLayer)

-- ---- Stub: TileMap:getLayerCount ------------------------------------------
--@api-stub: TileMap:getLayerCount
-- Demonstrates the proper usage of TileMap:getLayerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getLayerCount()
    print("layer count: " .. overworld:getLayerCount())
end
local _ok, _err = pcall(demo_TileMap_getLayerCount)

-- ---- Stub: TileMap:getLayerName -------------------------------------------
--@api-stub: TileMap:getLayerName
-- Demonstrates the proper usage of TileMap:getLayerName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getLayerName()
    print("layer 0: " .. overworld:getLayerName(0))
    print("layer 1: " .. overworld:getLayerName(1))
end
local _ok, _err = pcall(demo_TileMap_getLayerName)

-- ---- Stub: TileMap:getLayerVisible ----------------------------------------
--@api-stub: TileMap:getLayerVisible
-- Demonstrates the proper usage of TileMap:getLayerVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getLayerVisible()
    print("ground visible: " .. tostring(overworld:getLayerVisible(0)))
end
local _ok, _err = pcall(demo_TileMap_getLayerVisible)

-- ---- Stub: TileMap:getLayerColor ------------------------------------------
--@api-stub: TileMap:getLayerColor
-- Demonstrates the proper usage of TileMap:getLayerColor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getLayerColor()
    local lr, lg, lb, la = overworld:getLayerColor(0)
    print("ground layer color: (" .. tostring(lr) .. "," .. tostring(lg) .. "," .. tostring(lb) .. ")")
end
local _ok, _err = pcall(demo_TileMap_getLayerColor)

-- ---- Stub: TileMap:getLayerOffset -----------------------------------------
--@api-stub: TileMap:getLayerOffset
-- Demonstrates the proper usage of TileMap:getLayerOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getLayerOffset()
    local ox, oy = overworld:getLayerOffset(1)
    print("decoration offset: (" .. tostring(ox) .. ", " .. tostring(oy) .. ")")
end
local _ok, _err = pcall(demo_TileMap_getLayerOffset)

-- ---- Stub: TileMap:getLayerParallax ---------------------------------------
--@api-stub: TileMap:getLayerParallax
-- Demonstrates the proper usage of TileMap:getLayerParallax.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getLayerParallax()
    local px, py = overworld:getLayerParallax(0)
    print("ground parallax: (" .. tostring(px) .. ", " .. tostring(py) .. ")")
end
local _ok, _err = pcall(demo_TileMap_getLayerParallax)

-- ---- Stub: TileMap:getTile ------------------------------------------------
--@api-stub: TileMap:getTile
-- Demonstrates the proper usage of TileMap:getTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getTile()
    local tile_id = overworld:getTile(0, 10, 5)  -- layer 0, col 10, row 5
    print("tile at (10,5) layer 0: " .. tostring(tile_id))
end
local _ok, _err = pcall(demo_TileMap_getTile)

-- ---- Stub: TileMap:clearTile ----------------------------------------------
--@api-stub: TileMap:clearTile
-- Demonstrates the proper usage of TileMap:clearTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_clearTile()
    overworld:clearTile(0, 10, 5)
    print("tile at (10,5) layer 0 cleared")
end
local _ok, _err = pcall(demo_TileMap_clearTile)

-- ---- Stub: TileMap:fill ---------------------------------------------------
--@api-stub: TileMap:fill
-- Demonstrates the proper usage of TileMap:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_fill()
    overworld:fill(0, 3)  -- layer 0, tile ID 3 (grass)
    print("ground layer filled with grass (tile 3)")
end
local _ok, _err = pcall(demo_TileMap_fill)

-- ---- Stub: TileMap:getViewport --------------------------------------------
--@api-stub: TileMap:getViewport
-- Demonstrates the proper usage of TileMap:getViewport.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getViewport()
    local vx, vy, vw, vh = overworld:getViewport()
    print("viewport: (" .. tostring(vx) .. "," .. tostring(vy) .. "," .. tostring(vw) .. "," .. tostring(vh) .. ")")
end
local _ok, _err = pcall(demo_TileMap_getViewport)

-- ---- Stub: TileMap:update -------------------------------------------------
--@api-stub: TileMap:update
-- Demonstrates the proper usage of TileMap:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_update()
    overworld:update(0.016)
    print("tilemap updated (16ms frame)")
end
local _ok, _err = pcall(demo_TileMap_update)

-- ---- Stub: TileMap:worldToTile --------------------------------------------
--@api-stub: TileMap:worldToTile
-- Demonstrates the proper usage of TileMap:worldToTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_worldToTile()
    local tx2, ty2 = overworld:worldToTile(256, 128)
    print("world (256,128) -> tile (" .. tostring(tx2) .. ", " .. tostring(ty2) .. ")")
end
local _ok, _err = pcall(demo_TileMap_worldToTile)

-- ---- Stub: TileMap:tileToWorld --------------------------------------------
--@api-stub: TileMap:tileToWorld
-- Demonstrates the proper usage of TileMap:tileToWorld.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_tileToWorld()
    local wx, wy = overworld:tileToWorld(10, 8)
    print("tile (10,8) -> world (" .. tostring(wx) .. ", " .. tostring(wy) .. ")")
end
local _ok, _err = pcall(demo_TileMap_tileToWorld)

-- ---- Stub: TileMap:getTileWidth -------------------------------------------
--@api-stub: TileMap:getTileWidth
-- Demonstrates the proper usage of TileMap:getTileWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getTileWidth()
    print("map tile width: " .. overworld:getTileWidth() .. "px")
end
local _ok, _err = pcall(demo_TileMap_getTileWidth)

-- ---- Stub: TileMap:getTileHeight ------------------------------------------
--@api-stub: TileMap:getTileHeight
-- Demonstrates the proper usage of TileMap:getTileHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getTileHeight()
    print("map tile height: " .. overworld:getTileHeight() .. "px")
end
local _ok, _err = pcall(demo_TileMap_getTileHeight)

-- ---- Stub: TileMap:getTileDimensions --------------------------------------
--@api-stub: TileMap:getTileDimensions
-- Demonstrates the proper usage of TileMap:getTileDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getTileDimensions()
    local mtw, mth = overworld:getTileDimensions()
    print("map tile dimensions: " .. mtw .. "x" .. mth)
end
local _ok, _err = pcall(demo_TileMap_getTileDimensions)

-- ---- Stub: TileMap:getChunkSize -------------------------------------------
--@api-stub: TileMap:getChunkSize
-- Demonstrates the proper usage of TileMap:getChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getChunkSize()
    print("tilemap chunk size: " .. tostring(overworld:getChunkSize()))
end
local _ok, _err = pcall(demo_TileMap_getChunkSize)

-- ---- Stub: TileMap:isSolid -----------------------------------------------
--@api-stub: TileMap:isSolid
-- Demonstrates the proper usage of TileMap:isSolid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_isSolid()
    print("tile (5,3) solid: " .. tostring(overworld:isSolid(5, 3)))
end
local _ok, _err = pcall(demo_TileMap_isSolid)

-- ---- Stub: TileMap:getOrientation -----------------------------------------
--@api-stub: TileMap:getOrientation
-- Demonstrates the proper usage of TileMap:getOrientation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_getOrientation()
    print("orientation: " .. tostring(overworld:getOrientation()))
end
local _ok, _err = pcall(demo_TileMap_getOrientation)

-- ---- Stub: TileMap:setOrientation -----------------------------------------
--@api-stub: TileMap:setOrientation
-- Demonstrates the proper usage of TileMap:setOrientation.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_setOrientation()
    overworld:setOrientation("orthogonal")
    print("orientation set to orthogonal")
end
local _ok, _err = pcall(demo_TileMap_setOrientation)

-- ---- Stub: TileMap:render -------------------------------------------------
--@api-stub: TileMap:render
-- Demonstrates the proper usage of TileMap:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_render()
    overworld:render()
    print("tilemap rendered")
end
local _ok, _err = pcall(demo_TileMap_render)

-- ---- Stub: TileMap:drawToImage --------------------------------------------
--@api-stub: TileMap:drawToImage
-- Demonstrates the proper usage of TileMap:drawToImage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_drawToImage()
    overworld:drawToImage("output/overworld_preview.png")
    print("tilemap exported to PNG")
end
local _ok, _err = pcall(demo_TileMap_drawToImage)

-- ---- Stub: TileMap:toNavGrid ----------------------------------------------
--@api-stub: TileMap:toNavGrid
-- Demonstrates the proper usage of TileMap:toNavGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_TileMap_toNavGrid()
    local nav = overworld:toNavGrid()
    print("navigation grid generated from tilemap solids")
end
local _ok, _err = pcall(demo_TileMap_toNavGrid)

-- =============================================================================
-- AutoTileSheet Object Methods
-- =============================================================================

-- ---- Stub: AutoTileSheet:getLayout ----------------------------------------
--@api-stub: AutoTileSheet:getLayout
-- Demonstrates the proper usage of AutoTileSheet:getLayout.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getLayout()
    print("auto-tile layout: " .. grass_auto:getLayout())
end
local _ok, _err = pcall(demo_AutoTileSheet_getLayout)

-- ---- Stub: AutoTileSheet:getTileCount -------------------------------------
--@api-stub: AutoTileSheet:getTileCount
-- Demonstrates the proper usage of AutoTileSheet:getTileCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getTileCount()
    print("auto-tile count: " .. grass_auto:getTileCount())
end
local _ok, _err = pcall(demo_AutoTileSheet_getTileCount)

-- ---- Stub: AutoTileSheet:getTileWidth -------------------------------------
--@api-stub: AutoTileSheet:getTileWidth
-- Demonstrates the proper usage of AutoTileSheet:getTileWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getTileWidth()
    print("auto-tile width: " .. grass_auto:getTileWidth() .. "px")
end
local _ok, _err = pcall(demo_AutoTileSheet_getTileWidth)

-- ---- Stub: AutoTileSheet:getTileHeight ------------------------------------
--@api-stub: AutoTileSheet:getTileHeight
-- Demonstrates the proper usage of AutoTileSheet:getTileHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getTileHeight()
    print("auto-tile height: " .. grass_auto:getTileHeight() .. "px")
end
local _ok, _err = pcall(demo_AutoTileSheet_getTileHeight)

-- ---- Stub: AutoTileSheet:getBitmaskForTile ---------------------------------
--@api-stub: AutoTileSheet:getBitmaskForTile
-- Demonstrates the proper usage of AutoTileSheet:getBitmaskForTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getBitmaskForTile()
    local bitmask = grass_auto:getBitmaskForTile(12)
    print("auto-tile 12 bitmask: " .. tostring(bitmask))
end
local _ok, _err = pcall(demo_AutoTileSheet_getBitmaskForTile)

-- ---- Stub: AutoTileSheet:getTileForBitmask --------------------------------
--@api-stub: AutoTileSheet:getTileForBitmask
-- Demonstrates the proper usage of AutoTileSheet:getTileForBitmask.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getTileForBitmask()
    local auto_idx = grass_auto:getTileForBitmask(0xFF)
    print("bitmask 0xFF (all neighbors) -> tile: " .. tostring(auto_idx))
end
local _ok, _err = pcall(demo_AutoTileSheet_getTileForBitmask)

-- ---- Stub: AutoTileSheet:getQuad ------------------------------------------
--@api-stub: AutoTileSheet:getQuad
-- Demonstrates the proper usage of AutoTileSheet:getQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AutoTileSheet_getQuad()
    local auto_quad = grass_auto:getQuad(0)
    print("auto-tile 0 quad: " .. tostring(auto_quad))
end
local _ok, _err = pcall(demo_AutoTileSheet_getQuad)

-- =============================================================================
-- ChunkMap Object Methods — streaming tile access
-- =============================================================================

-- ---- Stub: ChunkMap:loadChunk ---------------------------------------------
--@api-stub: ChunkMap:loadChunk
-- Demonstrates the proper usage of ChunkMap:loadChunk.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_loadChunk()
    world_chunks:loadChunk(0, 0)
    world_chunks:loadChunk(1, 0)
    print("chunks (0,0) and (1,0) loaded")
end
local _ok, _err = pcall(demo_ChunkMap_loadChunk)

-- ---- Stub: ChunkMap:unloadChunk -------------------------------------------
--@api-stub: ChunkMap:unloadChunk
-- Demonstrates the proper usage of ChunkMap:unloadChunk.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_unloadChunk()
    world_chunks:unloadChunk(1, 0)
    print("chunk (1,0) unloaded (player moved away)")
end
local _ok, _err = pcall(demo_ChunkMap_unloadChunk)

-- ---- Stub: ChunkMap:setTile -----------------------------------------------
--@api-stub: ChunkMap:setTile
-- Demonstrates the proper usage of ChunkMap:setTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_setTile()
    world_chunks:setTile(5, 3, 7)
    print("chunk tile (5,3) set to ID 7")
end
local _ok, _err = pcall(demo_ChunkMap_setTile)

-- ---- Stub: ChunkMap:getTile -----------------------------------------------
--@api-stub: ChunkMap:getTile
-- Demonstrates the proper usage of ChunkMap:getTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_getTile()
    print("chunk tile (5,3): " .. tostring(world_chunks:getTile(5, 3)))
end
local _ok, _err = pcall(demo_ChunkMap_getTile)

-- ---- Stub: ChunkMap:clearTile ---------------------------------------------
--@api-stub: ChunkMap:clearTile
-- Demonstrates the proper usage of ChunkMap:clearTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_clearTile()
    world_chunks:clearTile(5, 3)
    print("chunk tile (5,3) cleared")
end
local _ok, _err = pcall(demo_ChunkMap_clearTile)

-- ---- Stub: ChunkMap:getChunkSize ------------------------------------------
--@api-stub: ChunkMap:getChunkSize
-- Demonstrates the proper usage of ChunkMap:getChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_getChunkSize()
    print("chunk size: " .. tostring(world_chunks:getChunkSize()) .. " tiles")
end
local _ok, _err = pcall(demo_ChunkMap_getChunkSize)

-- ---- Stub: ChunkMap:getLoadedChunks ---------------------------------------
--@api-stub: ChunkMap:getLoadedChunks
-- Demonstrates the proper usage of ChunkMap:getLoadedChunks.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_getLoadedChunks()
    local loaded = world_chunks:getLoadedChunks()
    print("loaded chunks: " .. #loaded)
end
local _ok, _err = pcall(demo_ChunkMap_getLoadedChunks)

-- ---- Stub: ChunkMap:chunkTileRange ----------------------------------------
--@api-stub: ChunkMap:chunkTileRange
-- Demonstrates the proper usage of ChunkMap:chunkTileRange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ChunkMap_chunkTileRange()
    local cmin_x, cmin_y, cmax_x, cmax_y = world_chunks:chunkTileRange(0, 0)
    print("chunk (0,0) tiles: (" .. cmin_x .. "," .. cmin_y .. ") to (" .. cmax_x .. "," .. cmax_y .. ")")
end
local _ok, _err = pcall(demo_ChunkMap_chunkTileRange)

-- =============================================================================
-- LargeMapRenderer Object Methods
-- =============================================================================

-- ---- Stub: LargeMapRenderer:setTile ---------------------------------------
--@api-stub: LargeMapRenderer:setTile
-- Demonstrates the proper usage of LargeMapRenderer:setTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setTile()
    large_renderer:setTile(50, 40, 12)
    print("large renderer: tile (50,40) set to 12")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setTile)

-- ---- Stub: LargeMapRenderer:getTile ---------------------------------------
--@api-stub: LargeMapRenderer:getTile
-- Demonstrates the proper usage of LargeMapRenderer:getTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_getTile()
    print("large renderer tile (50,40): " .. tostring(large_renderer:getTile(50, 40)))
end
local _ok, _err = pcall(demo_LargeMapRenderer_getTile)

-- ---- Stub: LargeMapRenderer:getMapSize ------------------------------------
--@api-stub: LargeMapRenderer:getMapSize
-- Demonstrates the proper usage of LargeMapRenderer:getMapSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_getMapSize()
    local lmw, lmh = large_renderer:getMapSize()
    print("large map size: " .. lmw .. "x" .. lmh)
end
local _ok, _err = pcall(demo_LargeMapRenderer_getMapSize)

-- ---- Stub: LargeMapRenderer:setChunkSize ----------------------------------
--@api-stub: LargeMapRenderer:setChunkSize
-- Demonstrates the proper usage of LargeMapRenderer:setChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setChunkSize()
    large_renderer:setChunkSize(16)
    print("large renderer chunk size: 16")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setChunkSize)

-- ---- Stub: LargeMapRenderer:getChunkSize ----------------------------------
--@api-stub: LargeMapRenderer:getChunkSize
-- Demonstrates the proper usage of LargeMapRenderer:getChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_getChunkSize()
    print("large renderer chunk size: " .. tostring(large_renderer:getChunkSize()))
end
local _ok, _err = pcall(demo_LargeMapRenderer_getChunkSize)

-- ---- Stub: LargeMapRenderer:invalidateChunk -------------------------------
--@api-stub: LargeMapRenderer:invalidateChunk
-- Demonstrates the proper usage of LargeMapRenderer:invalidateChunk.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_invalidateChunk()
    large_renderer:invalidateChunk(3, 2)
    print("chunk (3,2) invalidated — will re-render next frame")
end
local _ok, _err = pcall(demo_LargeMapRenderer_invalidateChunk)

-- ---- Stub: LargeMapRenderer:invalidateAll ---------------------------------
--@api-stub: LargeMapRenderer:invalidateAll
-- Demonstrates the proper usage of LargeMapRenderer:invalidateAll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_invalidateAll()
    large_renderer:invalidateAll()
    print("all chunks invalidated (tileset changed)")
end
local _ok, _err = pcall(demo_LargeMapRenderer_invalidateAll)

-- ---- Stub: LargeMapRenderer:getVisibleChunks ------------------------------
--@api-stub: LargeMapRenderer:getVisibleChunks
-- Demonstrates the proper usage of LargeMapRenderer:getVisibleChunks.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_getVisibleChunks()
    print("visible chunks: " .. tostring(large_renderer:getVisibleChunks()))
end
local _ok, _err = pcall(demo_LargeMapRenderer_getVisibleChunks)

-- ---- Stub: LargeMapRenderer:getTotalChunks --------------------------------
--@api-stub: LargeMapRenderer:getTotalChunks
-- Demonstrates the proper usage of LargeMapRenderer:getTotalChunks.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_getTotalChunks()
    print("total chunks: " .. tostring(large_renderer:getTotalChunks()))
end
local _ok, _err = pcall(demo_LargeMapRenderer_getTotalChunks)

-- ---- Stub: LargeMapRenderer:setCamera -------------------------------------
--@api-stub: LargeMapRenderer:setCamera
-- Demonstrates the proper usage of LargeMapRenderer:setCamera.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setCamera()
    large_renderer:setCamera(800, 600)
    print("large renderer camera at (800, 600)")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setCamera)

-- ---- Stub: LargeMapRenderer:setViewport -----------------------------------
--@api-stub: LargeMapRenderer:setViewport
-- Demonstrates the proper usage of LargeMapRenderer:setViewport.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setViewport()
    large_renderer:setViewport(0, 0, 800, 600)
    print("large renderer viewport: 800x600")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setViewport)

-- ---- Stub: LargeMapRenderer:setLodEnabled ---------------------------------
--@api-stub: LargeMapRenderer:setLodEnabled
-- Demonstrates the proper usage of LargeMapRenderer:setLodEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setLodEnabled()
    large_renderer:setLodEnabled(true)
    print("LOD enabled (distant chunks render at lower detail)")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setLodEnabled)

-- ---- Stub: LargeMapRenderer:isLodEnabled ----------------------------------
--@api-stub: LargeMapRenderer:isLodEnabled
-- Demonstrates the proper usage of LargeMapRenderer:isLodEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_isLodEnabled()
    print("LOD enabled: " .. tostring(large_renderer:isLodEnabled()))
end
local _ok, _err = pcall(demo_LargeMapRenderer_isLodEnabled)

-- ---- Stub: LargeMapRenderer:setLodThresholds ------------------------------
--@api-stub: LargeMapRenderer:setLodThresholds
-- Demonstrates the proper usage of LargeMapRenderer:setLodThresholds.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setLodThresholds()
    large_renderer:setLodThresholds({ 512, 1024, 2048 })
    print("LOD thresholds: 512, 1024, 2048 pixels from camera")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setLodThresholds)

-- ---- Stub: LargeMapRenderer:setTilesetColumns -----------------------------
--@api-stub: LargeMapRenderer:setTilesetColumns
-- Demonstrates the proper usage of LargeMapRenderer:setTilesetColumns.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_setTilesetColumns()
    large_renderer:setTilesetColumns(20)
    print("large renderer tileset columns: 20")
end
local _ok, _err = pcall(demo_LargeMapRenderer_setTilesetColumns)

-- ---- Stub: LargeMapRenderer:getTilesetColumns -----------------------------
--@api-stub: LargeMapRenderer:getTilesetColumns
-- Demonstrates the proper usage of LargeMapRenderer:getTilesetColumns.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_LargeMapRenderer_getTilesetColumns()
    print("tileset columns: " .. tostring(large_renderer:getTilesetColumns()))
end
local _ok, _err = pcall(demo_LargeMapRenderer_getTilesetColumns)

-- =============================================================================
-- IsoMap Object Methods — isometric map with levels
-- =============================================================================

-- ---- Stub: IsoMap:addLevel ------------------------------------------------
--@api-stub: IsoMap:addLevel
-- Demonstrates the proper usage of IsoMap:addLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_addLevel()
    town_iso:addLevel()
    town_iso:addLevel()
    print("2 levels added to isometric town (ground + 1st floor)")
end
local _ok, _err = pcall(demo_IsoMap_addLevel)

-- ---- Stub: IsoMap:getLevelCount -------------------------------------------
--@api-stub: IsoMap:getLevelCount
-- Demonstrates the proper usage of IsoMap:getLevelCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getLevelCount()
    print("iso levels: " .. town_iso:getLevelCount())
end
local _ok, _err = pcall(demo_IsoMap_getLevelCount)

-- ---- Stub: IsoMap:setLevelVisible -----------------------------------------
--@api-stub: IsoMap:setLevelVisible
-- Demonstrates the proper usage of IsoMap:setLevelVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_setLevelVisible()
    town_iso:setLevelVisible(1, false)
    print("level 1 hidden (roof removed for top-down view)")
end
local _ok, _err = pcall(demo_IsoMap_setLevelVisible)

-- ---- Stub: IsoMap:isLevelVisible ------------------------------------------
--@api-stub: IsoMap:isLevelVisible
-- Demonstrates the proper usage of IsoMap:isLevelVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_isLevelVisible()
    print("level 0 visible: " .. tostring(town_iso:isLevelVisible(0)))
    print("level 1 visible: " .. tostring(town_iso:isLevelVisible(1)))
end
local _ok, _err = pcall(demo_IsoMap_isLevelVisible)

-- ---- Stub: IsoMap:fillLevel -----------------------------------------------
--@api-stub: IsoMap:fillLevel
-- Demonstrates the proper usage of IsoMap:fillLevel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_fillLevel()
    town_iso:fillLevel(0, 5)  -- Fill ground level with tile 5 (cobblestone)
    print("ground level filled with cobblestone (tile 5)")
end
local _ok, _err = pcall(demo_IsoMap_fillLevel)

-- ---- Stub: IsoMap:setOrigin -----------------------------------------------
--@api-stub: IsoMap:setOrigin
-- Demonstrates the proper usage of IsoMap:setOrigin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_setOrigin()
    town_iso:setOrigin(400, 100)
    print("iso origin: (400, 100)")
end
local _ok, _err = pcall(demo_IsoMap_setOrigin)

-- ---- Stub: IsoMap:getWidth ------------------------------------------------
--@api-stub: IsoMap:getWidth
-- Demonstrates the proper usage of IsoMap:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getWidth()
    print("iso width: " .. town_iso:getWidth() .. " tiles")
end
local _ok, _err = pcall(demo_IsoMap_getWidth)

-- ---- Stub: IsoMap:getHeight -----------------------------------------------
--@api-stub: IsoMap:getHeight
-- Demonstrates the proper usage of IsoMap:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getHeight()
    print("iso height: " .. town_iso:getHeight() .. " tiles")
end
local _ok, _err = pcall(demo_IsoMap_getHeight)

-- ---- Stub: IsoMap:getTileWidth --------------------------------------------
--@api-stub: IsoMap:getTileWidth
-- Demonstrates the proper usage of IsoMap:getTileWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getTileWidth()
    print("iso tile width: " .. town_iso:getTileWidth() .. "px")
end
local _ok, _err = pcall(demo_IsoMap_getTileWidth)

-- ---- Stub: IsoMap:getTileHeight -------------------------------------------
--@api-stub: IsoMap:getTileHeight
-- Demonstrates the proper usage of IsoMap:getTileHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getTileHeight()
    print("iso tile height: " .. town_iso:getTileHeight() .. "px")
end
local _ok, _err = pcall(demo_IsoMap_getTileHeight)

-- ---- Stub: IsoMap:getLevelHeight -------------------------------------------
--@api-stub: IsoMap:getLevelHeight
-- Demonstrates the proper usage of IsoMap:getLevelHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getLevelHeight()
    print("iso level height: " .. tostring(town_iso:getLevelHeight()) .. "px")
end
local _ok, _err = pcall(demo_IsoMap_getLevelHeight)

-- ---- Stub: IsoMap:tileToScreen --------------------------------------------
--@api-stub: IsoMap:tileToScreen
-- Demonstrates the proper usage of IsoMap:tileToScreen.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_tileToScreen()
    local isx, isy = town_iso:tileToScreen(5, 3)
    print("iso tile (5,3) -> screen (" .. tostring(isx) .. ", " .. tostring(isy) .. ")")
end
local _ok, _err = pcall(demo_IsoMap_tileToScreen)

-- ---- Stub: IsoMap:screenToTile --------------------------------------------
--@api-stub: IsoMap:screenToTile
-- Demonstrates the proper usage of IsoMap:screenToTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_screenToTile()
    local itx, ity = town_iso:screenToTile(isx, isy)
    print("screen -> iso tile (" .. tostring(itx) .. ", " .. tostring(ity) .. ")")
end
local _ok, _err = pcall(demo_IsoMap_screenToTile)

-- ---- Stub: IsoMap:getPartCount --------------------------------------------
--@api-stub: IsoMap:getPartCount
-- Demonstrates the proper usage of IsoMap:getPartCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getPartCount()
    print("iso parts: " .. tostring(town_iso:getPartCount()))
end
local _ok, _err = pcall(demo_IsoMap_getPartCount)

-- ---- Stub: IsoMap:getPartOrder --------------------------------------------
--@api-stub: IsoMap:getPartOrder
-- Demonstrates the proper usage of IsoMap:getPartOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_getPartOrder()
    local order = town_iso:getPartOrder()
    print("iso part order: " .. tostring(order))
end
local _ok, _err = pcall(demo_IsoMap_getPartOrder)

-- ---- Stub: IsoMap:setPartOrder --------------------------------------------
--@api-stub: IsoMap:setPartOrder
-- Demonstrates the proper usage of IsoMap:setPartOrder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_IsoMap_setPartOrder()
    town_iso:setPartOrder("back-to-front")
    print("iso render order: back-to-front")
end
local _ok, _err = pcall(demo_IsoMap_setPartOrder)

-- =============================================================================
-- MapBlock Object Methods — tile pattern templates
-- =============================================================================

-- ---- Stub: MapBlock:getTile -----------------------------------------------
--@api-stub: MapBlock:getTile
-- Demonstrates the proper usage of MapBlock:getTile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getTile()
    print("block tile (0,0): " .. tostring(room_block:getTile(0, 0)))
end
local _ok, _err = pcall(demo_MapBlock_getTile)

-- ---- Stub: MapBlock:getSide -----------------------------------------------
--@api-stub: MapBlock:getSide
-- Demonstrates the proper usage of MapBlock:getSide.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getSide()
    local side = room_block:getSide("north")
    print("block north side: " .. tostring(side))
end
local _ok, _err = pcall(demo_MapBlock_getSide)

-- ---- Stub: MapBlock:getWidth ----------------------------------------------
--@api-stub: MapBlock:getWidth
-- Demonstrates the proper usage of MapBlock:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getWidth()
    print("block width: " .. room_block:getWidth())
end
local _ok, _err = pcall(demo_MapBlock_getWidth)

-- ---- Stub: MapBlock:getHeight ---------------------------------------------
--@api-stub: MapBlock:getHeight
-- Demonstrates the proper usage of MapBlock:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getHeight()
    print("block height: " .. room_block:getHeight())
end
local _ok, _err = pcall(demo_MapBlock_getHeight)

-- ---- Stub: MapBlock:getDimensions -----------------------------------------
--@api-stub: MapBlock:getDimensions
-- Demonstrates the proper usage of MapBlock:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getDimensions()
    local bw, bh = room_block:getDimensions()
    print("block dimensions: " .. bw .. "x" .. bh)
end
local _ok, _err = pcall(demo_MapBlock_getDimensions)

-- ---- Stub: MapBlock:getLayerCount -----------------------------------------
--@api-stub: MapBlock:getLayerCount
-- Demonstrates the proper usage of MapBlock:getLayerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getLayerCount()
    print("block layers: " .. room_block:getLayerCount())
end
local _ok, _err = pcall(demo_MapBlock_getLayerCount)

-- ---- Stub: MapBlock:getSegmentSize ----------------------------------------
--@api-stub: MapBlock:getSegmentSize
-- Demonstrates the proper usage of MapBlock:getSegmentSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getSegmentSize()
    print("block segment size: " .. tostring(room_block:getSegmentSize()))
end
local _ok, _err = pcall(demo_MapBlock_getSegmentSize)

-- ---- Stub: MapBlock:getWidthInSegments ------------------------------------
--@api-stub: MapBlock:getWidthInSegments
-- Demonstrates the proper usage of MapBlock:getWidthInSegments.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getWidthInSegments()
    print("block width in segments: " .. tostring(room_block:getWidthInSegments()))
end
local _ok, _err = pcall(demo_MapBlock_getWidthInSegments)

-- ---- Stub: MapBlock:getHeightInSegments -----------------------------------
--@api-stub: MapBlock:getHeightInSegments
-- Demonstrates the proper usage of MapBlock:getHeightInSegments.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getHeightInSegments()
    print("block height in segments: " .. tostring(room_block:getHeightInSegments()))
end
local _ok, _err = pcall(demo_MapBlock_getHeightInSegments)

-- ---- Stub: MapBlock:setName -----------------------------------------------
--@api-stub: MapBlock:setName
-- Demonstrates the proper usage of MapBlock:setName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_setName()
    room_block:setName("entrance_hall")
    print("block named: entrance_hall")
end
local _ok, _err = pcall(demo_MapBlock_setName)

-- ---- Stub: MapBlock:getName -----------------------------------------------
--@api-stub: MapBlock:getName
-- Demonstrates the proper usage of MapBlock:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getName()
    print("block name: " .. room_block:getName())
end
local _ok, _err = pcall(demo_MapBlock_getName)

-- ---- Stub: MapBlock:setWeight ---------------------------------------------
--@api-stub: MapBlock:setWeight
-- Demonstrates the proper usage of MapBlock:setWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_setWeight()
    room_block:setWeight(2.0)
    print("block weight: 2.0 (appears twice as often)")
end
local _ok, _err = pcall(demo_MapBlock_setWeight)

-- ---- Stub: MapBlock:getWeight ---------------------------------------------
--@api-stub: MapBlock:getWeight
-- Demonstrates the proper usage of MapBlock:getWeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapBlock_getWeight()
    print("block weight: " .. tostring(room_block:getWeight()))
end
local _ok, _err = pcall(demo_MapBlock_getWeight)

-- =============================================================================
-- MapGroup Object Methods — block collections for generation
-- =============================================================================

-- ---- Stub: MapGroup:addBlock ----------------------------------------------
--@api-stub: MapGroup:addBlock
-- Demonstrates the proper usage of MapGroup:addBlock.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapGroup_addBlock()
    dungeon_group:addBlock(room_block)
    print("entrance_hall added to dungeon group")
end
local _ok, _err = pcall(demo_MapGroup_addBlock)

-- ---- Stub: MapGroup:getBlockCount -----------------------------------------
--@api-stub: MapGroup:getBlockCount
-- Demonstrates the proper usage of MapGroup:getBlockCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapGroup_getBlockCount()
    print("blocks in group: " .. dungeon_group:getBlockCount())
end
local _ok, _err = pcall(demo_MapGroup_getBlockCount)

-- ---- Stub: MapGroup:removeBlock -------------------------------------------
--@api-stub: MapGroup:removeBlock
-- Demonstrates the proper usage of MapGroup:removeBlock.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapGroup_removeBlock()
    dungeon_group:removeBlock(0)
    print("block 0 removed from group")
end
local _ok, _err = pcall(demo_MapGroup_removeBlock)

-- ---- Stub: MapGroup:getName -----------------------------------------------
--@api-stub: MapGroup:getName
-- Demonstrates the proper usage of MapGroup:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapGroup_getName()
    print("group name: " .. dungeon_group:getName())
end
local _ok, _err = pcall(demo_MapGroup_getName)

-- ---- Stub: MapGroup:addScript ---------------------------------------------
--@api-stub: MapGroup:addScript
-- Demonstrates the proper usage of MapGroup:addScript.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapGroup_addScript()
    dungeon_group:addScript(gen_script)
    print("generation script attached to group")
end
local _ok, _err = pcall(demo_MapGroup_addScript)

-- ---- Stub: MapGroup:getScriptCount ----------------------------------------
--@api-stub: MapGroup:getScriptCount
-- Demonstrates the proper usage of MapGroup:getScriptCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapGroup_getScriptCount()
    print("group scripts: " .. dungeon_group:getScriptCount())
end
local _ok, _err = pcall(demo_MapGroup_getScriptCount)

-- =============================================================================
-- MapScript Object Methods — generation step sequences
-- =============================================================================

-- ---- Stub: MapScript:addStep ----------------------------------------------
--@api-stub: MapScript:addStep
-- Demonstrates the proper usage of MapScript:addStep.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapScript_addStep()
    gen_script:addStep({ type = "fill", tile = 1 })
    gen_script:addStep({ type = "carve_rooms", count = 8, min_size = 4, max_size = 10 })
    gen_script:addStep({ type = "connect_rooms", algorithm = "corridors" })
    print("3 generation steps added: fill, carve, connect")
end
local _ok, _err = pcall(demo_MapScript_addStep)

-- ---- Stub: MapScript:getStepCount -----------------------------------------
--@api-stub: MapScript:getStepCount
-- Demonstrates the proper usage of MapScript:getStepCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_MapScript_getStepCount()
    print("generation steps: " .. gen_script:getStepCount())
    print("\n-- tilemap.lua example complete --")
end
local _ok, _err = pcall(demo_MapScript_getStepCount)
