--- Globe Module Part 1: factories, registry, constants, utilities

--@api-stub: lurek.globe.MAX_PROVINCES
-- Maximum number of provinces the globe supports.
do
    print("max provinces = " .. lurek.globe.MAX_PROVINCES)
end

--@api-stub: lurek.globe.LOD_FAR
-- LOD tier constant for zoomed-out view.
do
    print("LOD_FAR = " .. lurek.globe.LOD_FAR)
end

--@api-stub: lurek.globe.LOD_MID
-- LOD tier constant for medium zoom.
do
    print("LOD_MID = " .. lurek.globe.LOD_MID)
end

--@api-stub: lurek.globe.LOD_NEAR
-- LOD tier constant for close zoom.
do
    print("LOD_NEAR = " .. lurek.globe.LOD_NEAR)
end

--@api-stub: lurek.globe.new
-- Creates a named globe in the module registry.
do
    local g = lurek.globe.new("test_globe")
    print("globe type = " .. g:type())
end

--@api-stub: lurek.globe.get
-- Returns a globe from the registry by name.
do
    lurek.globe.new("my_globe")
    local g = lurek.globe.get("my_globe")
    if g then
        print("got globe: " .. g:getName())
    end
end

--@api-stub: lurek.globe.generateVoronoi
-- Creates a globe from latitude-longitude seed points.
do
    local seeds = {
        {lat = 0, lon = 0},
        {lat = 30, lon = 45},
        {lat = -20, lon = 90},
        {lat = 60, lon = -30},
    }
    local g = lurek.globe.generateVoronoi("voronoi_globe", seeds)
    print("voronoi provinces = " .. g:provinceCount())
end

--@api-stub: lurek.globe.loadFromTOML
-- Creates a globe from TOML province source text.
do
    local toml = [=[
[[province]]
id = 1
centroid = [10.0, 20.0]
vertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]
]=]
    local g = lurek.globe.loadFromTOML("toml_globe", toml)
    print("toml globe provinces = " .. g:provinceCount())
end

--@api-stub: lurek.globe.loadFromPNG
-- Creates a globe from a PNG file.
do
    local g = lurek.globe.loadFromPNG("png_globe", "assets/textures/globe_map.png")
    print("png globe provinces = " .. g:provinceCount())
end

--@api-stub: lurek.globe.greatCircleDistance
-- Computes great-circle distance between two points.
do
    local d = lurek.globe.greatCircleDistance(0, 0, 90, 0)
    print("distance 0,0 -> 90,0 = " .. d)
end

--@api-stub: lurek.globe.greatCirclePath
-- Samples points along a great-circle path.
do
    local points = lurek.globe.greatCirclePath(0, 0, 45, 90, 5)
    print("path has " .. #points .. " points")
    for _, p in ipairs(points) do
        print("  lat=" .. p.lat .. " lon=" .. p.lon)
    end
end

--@api-stub: lurek.globe.latLonToUnit
-- Converts latitude/longitude to a unit-sphere 3D vector.
do
    local v = lurek.globe.latLonToUnit(0, 0)
    print("unit vec = " .. v.x .. "," .. v.y .. "," .. v.z)
end

print("globe_00.lua")
