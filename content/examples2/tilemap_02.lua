--- Tilemap Module Part 3: hex utilities, iso helpers, coordinate conversion, TMX/LDtk loading

--@api-stub: lurek.tilemap.toScreenHex
--@api-stub: lurek.fromScreenHex
-- Converting between hex axial and screen coordinates.
do
    local sx, sy = lurek.tilemap.toScreenHex(2, 3, 32)
    print("hex(2,3) -> screen(" .. sx .. ", " .. sy .. ")")
    local q, r = lurek.tilemap.fromScreenHex(sx, sy, 32)
    print("screen -> hex(" .. q .. ", " .. r .. ")")
end

--@api-stub: lurek.tilemap.hexDistance
-- Computing distance between two hex cells.
do
    local d = lurek.tilemap.hexDistance(0, 0, 3, 2)
    print("hex distance (0,0) to (3,2) = " .. d)
    d = lurek.tilemap.hexDistance(1, 1, 1, 1)
    print("same cell distance = " .. d)
    d = lurek.tilemap.hexDistance(-2, 1, 2, -1)
    print("across-origin distance = " .. d)
end

--@api-stub: lurek.tilemap.hexNeighbors
-- Getting the six neighbors of a hex cell.
do
    local neighbors = lurek.tilemap.hexNeighbors(3, 4)
    print("neighbors of (3,4): " .. #neighbors .. " cells")
    for i, n in ipairs(neighbors) do
        print("  " .. i .. ": q=" .. n.q .. " r=" .. n.r)
    end
end

--@api-stub: lurek.tilemap.hexRing
-- Cells forming a ring at radius.
do
    local ring = lurek.tilemap.hexRing(0, 0, 2)
    print("ring at radius 2: " .. #ring .. " cells")
    for _, cell in ipairs(ring) do
        print("  q=" .. cell.q .. " r=" .. cell.r)
    end
end

--@api-stub: lurek.tilemap.hexArea
-- All cells within a filled hex area.
do
    local area = lurek.tilemap.hexArea(0, 0, 1)
    print("area radius 1: " .. #area .. " cells")
    local bigArea = lurek.tilemap.hexArea(5, 5, 3)
    print("area radius 3 around (5,5): " .. #bigArea .. " cells")
end

--@api-stub: lurek.tilemap.hexSpiral
-- Spiral traversal of hex cells.
do
    local spiral = lurek.tilemap.hexSpiral(0, 0, 2)
    print("spiral radius 2: " .. #spiral .. " cells")
    print("center = q=" .. spiral[1].q .. " r=" .. spiral[1].r)
end

--@api-stub: lurek.tilemap.hexLine
-- Line of cells between two hex positions.
do
    local line = lurek.tilemap.hexLine(0, 0, 4, 2)
    print("line (0,0) to (4,2): " .. #line .. " cells")
    for i, cell in ipairs(line) do
        print("  step " .. i .. ": q=" .. cell.q .. " r=" .. cell.r)
    end
end

--@api-stub: lurek.tilemap.hexRound
-- Rounding fractional hex coordinates.
do
    local q, r = lurek.tilemap.hexRound(2.3, 1.7)
    print("round(2.3, 1.7) = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRound(-0.4, 0.6)
    print("round(-0.4, 0.6) = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.hexRotate
-- Rotating a hex cell around a pivot.
do
    local q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 1)
    print("(2,0) rotated 60deg CW around origin = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexRotate(2, 0, 0, 0, 3)
    print("(2,0) rotated 180deg = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.hexReflect
-- Reflecting a hex cell across an axis.
do
    local q, r = lurek.tilemap.hexReflect(3, 1, 0, 0, "q")
    print("reflect (3,1) across q axis = " .. q .. ", " .. r)
    q, r = lurek.tilemap.hexReflect(2, -1, 0, 0, "r")
    print("reflect (2,-1) across r axis = " .. q .. ", " .. r)
end

--@api-stub: lurek.tilemap.toScreenIso
--@api-stub: lurek.fromScreenIso
-- Isometric coordinate conversion.
do
    local sx, sy = lurek.tilemap.toScreenIso(3, 5, 64, 32)
    print("tile(3,5) -> screen(" .. sx .. ", " .. sy .. ")")
    local tx, ty = lurek.tilemap.fromScreenIso(sx, sy, 64, 32)
    print("screen -> tile(" .. tx .. ", " .. ty .. ")")
end

--@api-stub: lurek.tilemap.isoDirectionFromAngle
--@api-stub: lurek.isoDirectionName
--@api-stub: lurek.isoRotate
-- Isometric direction utilities.
do
    local dir = lurek.tilemap.isoDirectionFromAngle(45)
    print("45 degrees -> direction " .. dir)
    local name = lurek.tilemap.isoDirectionName(dir)
    print("direction name = " .. name)
    local rotated = lurek.tilemap.isoRotate(dir, 1)
    print("rotated +90 = " .. lurek.tilemap.isoDirectionName(rotated))
    rotated = lurek.tilemap.isoRotate(dir, 2)
    print("rotated +180 = " .. lurek.tilemap.isoDirectionName(rotated))
end

--@api-stub: lurek.tilemap.loadTMX
-- Parsing a TMX (Tiled) map file.
do
    local tmxData = [[<?xml version="1.0" encoding="UTF-8"?>
<map version="1.10" orientation="orthogonal" width="4" height="4" tilewidth="32" tileheight="32">
 <layer name="ground" width="4" height="4">
  <data encoding="csv">1,1,1,1,1,2,2,1,1,2,2,1,1,1,1,1</data>
 </layer>
</map>]]
    local result = lurek.tilemap.loadTMX(tmxData)
    print("TMX width = " .. result.width)
    print("TMX height = " .. result.height)
    print("TMX tile size = " .. result.tileWidth .. "x" .. result.tileHeight)
    print("TMX orientation = " .. result.orientation)
    print("TMX layers = " .. #result.layers)
end

--@api-stub: lurek.tilemap.fromLDtk
-- Loading a map from LDtk JSON.
do
    local ldtkJson = '{"levels":[{"identifier":"Level_0","layerInstances":[]}]}'
    ---@type LTileMap
    local map = lurek.tilemap.fromLDtk(ldtkJson)
    print("LDtk map type = " .. map:type())
    -- With specific level name:
    ---@type LTileMap
    local named = lurek.tilemap.fromLDtk(ldtkJson, "Level_0")
    print("named level loaded")
end

--@api-stub: lurek.tilemap constants
-- Tilemap layer type constants.
do
    print("FLOOR = " .. lurek.tilemap.FLOOR)
    print("NORTH_WALL = " .. lurek.tilemap.NORTH_WALL)
    print("WEST_WALL = " .. lurek.tilemap.WEST_WALL)
    print("OBJECT = " .. lurek.tilemap.OBJECT)
end

print("tilemap_02.lua")
