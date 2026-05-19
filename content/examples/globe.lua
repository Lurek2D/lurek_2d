-- content/examples/globe.lua
-- Auto-generated from content/examples2/globe_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/globe.lua

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

--- Globe Module Part 2: LGlobe methods (camera, provinces, markers, layers, fog)

--@api-stub: LGlobe:getName
-- Returns the registry name of this globe.
do
    local g = lurek.globe.new("named_globe")
    print("name = " .. g:getName())
end

--@api-stub: LGlobe:provinceCount
-- Returns the number of provinces.
do
    local g = lurek.globe.new("count_globe")
    print("provinces = " .. g:provinceCount())
end

--@api-stub: LGlobe:addProvince
-- Adds a province with id, centroid, vertices.
do
    local g = lurek.globe.new("prov_globe")
    local ok = g:addProvince({
        id = 1,
        centroid = {10.0, 20.0},
        vertices = {{9, 19}, {11, 19}, {11, 21}, {9, 21}},
    })
    print("added = " .. tostring(ok))
end

--@api-stub: LGlobe:removeProvince
-- Removes a province by id.
do
    local g = lurek.globe.new("rem_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local ok = g:removeProvince(1)
    print("removed = " .. tostring(ok))
end

--@api-stub: LGlobe:getNeighbors
-- Returns neighboring province ids.
do
    local g = lurek.globe.new("neigh_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    local n = g:getNeighbors(1)
    print("neighbors of 1: " .. #n)
end

--@api-stub: LGlobe:setProvinceAttr
-- Sets a string attribute on a province.
do
    local g = lurek.globe.new("attr_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "owner", "player1")
    print("set attr owner")
end

--@api-stub: LGlobe:getProvinceAttr
-- Reads a string attribute from a province.
do
    local g = lurek.globe.new("rattr_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "terrain", "forest")
    local val = g:getProvinceAttr(1, "terrain")
    print("terrain = " .. tostring(val))
end

--@api-stub: LGlobe:setProvinceSector
-- Assigns a province to a sector.
do
    local g = lurek.globe.new("sec_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "northern")
    print("sector set")
end

--@api-stub: LGlobe:getProvinceSector
-- Returns the sector name of a province.
do
    local g = lurek.globe.new("gsec_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "eastern")
    local s = g:getProvinceSector(1)
    print("sector = " .. tostring(s))
end

--@api-stub: LGlobe:getSectorProvinces
-- Returns province ids in a sector.
do
    local g = lurek.globe.new("sp_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "west")
    local ids = g:getSectorProvinces("west")
    print("west has " .. #ids .. " provinces")
end

--@api-stub: LGlobe:setCamera
-- Sets camera latitude, longitude, and zoom.
do
    local g = lurek.globe.new("cam_globe")
    g:setCamera(45, 90, 2.0)
    print("camera set")
end

--@api-stub: LGlobe:getCamera
-- Returns camera lat, lon, zoom.
do
    local g = lurek.globe.new("gcam_globe")
    g:setCamera(30, 60, 1.5)
    local lat, lon, z = g:getCamera()
    print("camera: " .. lat .. "," .. lon .. " z=" .. z)
end

--@api-stub: LGlobe:pan
-- Pans camera by lat/lon deltas.
do
    local g = lurek.globe.new("pan_globe")
    g:setCamera(0, 0, 1.0)
    g:pan(10, 20)
    local lat, lon, z = g:getCamera()
    print("after pan: " .. lat .. "," .. lon)
end

--@api-stub: LGlobe:zoom
-- Multiplies camera zoom by a factor.
do
    local g = lurek.globe.new("zoom_globe")
    g:setCamera(0, 0, 1.0)
    g:zoom(2.0)
    local _, _, z = g:getCamera()
    print("zoom = " .. z)
end

--@api-stub: LGlobe:getLod
-- Returns the camera-derived LOD tier name.
do
    local g = lurek.globe.new("lod_globe")
    g:setCamera(0, 0, 0.5)
    print("lod = " .. g:getLod())
end

--@api-stub: LGlobe:addMarker
-- Adds a marker at lat/lon with optional label.
do
    local g = lurek.globe.new("mark_globe")
    local id = g:addMarker("city", 51.5, -0.12, "London")
    print("marker id = " .. id)
end

--@api-stub: LGlobe:moveMarker
-- Moves a marker to new coordinates.
do
    local g = lurek.globe.new("mv_globe")
    local id = g:addMarker("pin", 0, 0)
    g:moveMarker(id, 10, 20)
    print("marker moved")
end

--@api-stub: LGlobe:removeMarker
-- Removes a marker by id.
do
    local g = lurek.globe.new("rm_globe")
    local id = g:addMarker("pin", 0, 0)
    local ok = g:removeMarker(id)
    print("removed marker = " .. tostring(ok))
end

--@api-stub: LGlobe:setMarkerAttr
-- Sets a string attribute on a marker.
do
    local g = lurek.globe.new("ma_globe")
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "population", "2M")
    print("marker attr set")
end

--@api-stub: LGlobe:getMarkerAttr
-- Reads a string attribute from a marker.
do
    local g = lurek.globe.new("ga_globe")
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "country", "France")
    local val = g:getMarkerAttr(id, "country")
    print("country = " .. tostring(val))
end

--@api-stub: LGlobe:setMarkerVisible
-- Shows or hides a marker.
do
    local g = lurek.globe.new("vis_globe")
    local id = g:addMarker("pin", 0, 0)
    g:setMarkerVisible(id, false)
    print("marker hidden")
end

--@api-stub: LGlobe:setMarkerPulse
-- Sets marker pulse animation.
do
    local g = lurek.globe.new("pulse_globe")
    local id = g:addMarker("alert", 0, 0, "!")
    g:setMarkerPulse(id, 2.0, 0.5)
    print("pulse set")
end

--@api-stub: LGlobe:setMarkerRotation
-- Sets marker rotation speed.
do
    local g = lurek.globe.new("rot_globe")
    local id = g:addMarker("spin", 0, 0)
    g:setMarkerRotation(id, 90)
    print("rotation = 90 dps")
end

--@api-stub: LGlobe:addLabel
-- Adds a text label at coordinates.
do
    local g = lurek.globe.new("lbl_globe")
    local id = g:addLabel("region", 40, -74, "New York")
    print("label id = " .. id)
end

--@api-stub: LGlobe:setLabelText
-- Changes text for a label.
do
    local g = lurek.globe.new("ltxt_globe")
    local id = g:addLabel("city", 0, 0, "old")
    g:setLabelText(id, "new")
    print("label updated")
end

--@api-stub: LGlobe:setLabelVisible
-- Shows or hides a label.
do
    local g = lurek.globe.new("lvis_globe")
    local id = g:addLabel("info", 0, 0, "text")
    g:setLabelVisible(id, false)
    print("label hidden")
end

--@api-stub: LGlobe:removeLabel
-- Removes a label by id.
do
    local g = lurek.globe.new("rlbl_globe")
    local id = g:addLabel("tmp", 0, 0, "temp")
    local ok = g:removeLabel(id)
    print("label removed = " .. tostring(ok))
end

--@api-stub: LGlobe:addArc
-- Adds a route arc between two points.
do
    local g = lurek.globe.new("arc_globe")
    local id = g:addArc(0, 0, 45, 90, 12)
    print("arc id = " .. id)
end

--@api-stub: LGlobe:removeArc
-- Removes an arc by id.
do
    local g = lurek.globe.new("rarc_globe")
    local id = g:addArc(0, 0, 30, 60)
    local ok = g:removeArc(id)
    print("arc removed = " .. tostring(ok))
end

--@api-stub: LGlobe:addLayer
-- Adds a render layer with optional z-order.
do
    local g = lurek.globe.new("layer_globe")
    g:addLayer("terrain", 0)
    g:addLayer("borders", 1)
    print("layers added")
end

--@api-stub: LGlobe:removeLayer
-- Removes a render layer.
do
    local g = lurek.globe.new("rl_globe")
    g:addLayer("temp_layer")
    local ok = g:removeLayer("temp_layer")
    print("layer removed = " .. tostring(ok))
end

--@api-stub: LGlobe:setLayerVisible
-- Shows or hides a render layer.
do
    local g = lurek.globe.new("lv_globe")
    g:addLayer("overlay")
    g:setLayerVisible("overlay", false)
    print("overlay hidden")
end

--@api-stub: LGlobe:setLayerAlpha
-- Sets render layer alpha.
do
    local g = lurek.globe.new("la_globe")
    g:addLayer("fog_layer")
    g:setLayerAlpha("fog_layer", 0.5)
    print("layer alpha = 0.5")
end

--@api-stub: LGlobe:setLayerColor
-- Sets a province color override in a layer.
do
    local g = lurek.globe.new("lc_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:addLayer("highlight")
    g:setLayerColor("highlight", 1, 1.0, 0.0, 0.0, 1.0)
    print("province 1 colored red in highlight layer")
end

--@api-stub: LGlobe:setHeatLayer
-- Creates a heat layer mapping attributes to colors.
do
    local g = lurek.globe.new("heat_globe")
    g:setHeatLayer("population", "pop", 0, 1000000, 0.7)
    print("heat layer set")
end

--@api-stub: LGlobe:removeHeatLayer
-- Removes a heat layer.
do
    local g = lurek.globe.new("rheat_globe")
    g:setHeatLayer("income", "gdp", 0, 50000, 0.5)
    local ok = g:removeHeatLayer("income")
    print("heat removed = " .. tostring(ok))
end

--@api-stub: LGlobe:setBorders
-- Enables or disables border rendering.
do
    local g = lurek.globe.new("bord_globe")
    g:setBorders(true)
    print("borders enabled")
end

--@api-stub: LGlobe:setActiveViewer
-- Sets the active fog-of-war viewer.
do
    local g = lurek.globe.new("fow_globe")
    g:setActiveViewer("player1")
    print("active viewer = player1")
end

--@api-stub: LGlobe:revealProvince
-- Reveals a province for a viewer.
do
    local g = lurek.globe.new("rev_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("player1", 1)
    print("province 1 revealed")
end

--@api-stub: LGlobe:hideProvince
-- Hides a province for a viewer.
do
    local g = lurek.globe.new("hide_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:hideProvince("player1", 1)
    print("province 1 hidden")
end

--@api-stub: LGlobe:revealAll
-- Reveals all provinces for a viewer.
do
    local g = lurek.globe.new("rall_globe")
    g:revealAll("player1")
    print("all revealed for player1")
end

--@api-stub: LGlobe:isVisible
-- Checks province visibility for a viewer.
do
    local g = lurek.globe.new("isv_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("p1", 1)
    print("visible = " .. tostring(g:isVisible("p1", 1)))
end

--@api-stub: LGlobe:setFogState
-- Sets fog state for a viewer and province.
do
    local g = lurek.globe.new("fs_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "explored")
    print("fog state set to explored")
end

--@api-stub: LGlobe:getFogState
-- Returns fog state for a viewer and province.
do
    local g = lurek.globe.new("gfs_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "visible")
    local state = g:getFogState("p1", 1)
    print("fog = " .. state)
end

--@api-stub: LGlobe:encodeFogBase64
-- Serializes fog state to base64.
do
    local g = lurek.globe.new("enc_globe")
    local b64 = g:encodeFogBase64("p1")
    print("encoded fog length = " .. #b64)
end

--@api-stub: LGlobe:decodeFogBase64
-- Loads fog state from base64.
do
    local g = lurek.globe.new("dec_globe")
    local b64 = g:encodeFogBase64("p1")
    local ok = g:decodeFogBase64("p1", b64)
    print("decoded = " .. tostring(ok))
end

--@api-stub: LGlobe:findPath
-- Finds a path between two provinces.
do
    local g = lurek.globe.new("path_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    local path = g:findPath(1, 2)
    if path then
        print("path length = " .. #path)
    end
end

--@api-stub: LGlobe:reachable
-- Returns reachable provinces within a cost budget.
do
    local g = lurek.globe.new("reach_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    local costs = g:reachable(1, 10.0)
    print("reachable provinces from 1: " .. tostring(costs))
end

--@api-stub: LGlobe:cacheReachability
-- Caches reachability for a faction.
do
    local g = lurek.globe.new("cache_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_a", 1, 5.0)
    print("reachability cached")
end

--@api-stub: LGlobe:getCachedReachability
-- Returns cached reachability for a faction.
do
    local g = lurek.globe.new("gcache_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_b", 1, 5.0)
    local costs = g:getCachedReachability("faction_b")
    print("cached costs type = " .. type(costs))
end

--@api-stub: LGlobe:pick
-- Picks a province at screen coordinates.
do
    local g = lurek.globe.new("pick_globe")
    local id = g:pick(400, 300)
    print("picked province = " .. tostring(id))
end

--@api-stub: LGlobe:pickLatLon
-- Picks screen coords and returns centroid lat/lon.
do
    local g = lurek.globe.new("pll_globe")
    local cx, cy = g:pickLatLon(400, 300)
    print("centroid = " .. tostring(cx) .. "," .. tostring(cy))
end

--@api-stub: LGlobe:pickRaycast
-- Picks using raycast sampling.
do
    local g = lurek.globe.new("pray_globe")
    local id = g:pickRaycast(400, 300, 32)
    print("raycast pick = " .. tostring(id))
end

--@api-stub: LGlobe:setProvinceTexture
-- Assigns a texture and UV rect to a province.
do
    local g = lurek.globe.new("tex_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0.0, 0.0, 1.0, 1.0)
    print("province texture set")
end

--@api-stub: LGlobe:clearProvinceTexture
-- Clears texture metadata from a province.
do
    local g = lurek.globe.new("ctex_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0, 0, 1, 1)
    g:clearProvinceTexture(1)
    print("texture cleared")
end

--@api-stub: LGlobe:exportProvinceMeshOBJ
-- Exports province geometry as OBJ text.
do
    local g = lurek.globe.new("obj_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local obj = g:exportProvinceMeshOBJ()
    print("OBJ length = " .. #obj)
end

--@api-stub: LGlobe:setRotation
-- Sets globe rotation angle.
do
    local g = lurek.globe.new("srot_globe")
    g:setRotation(45)
    print("rotation = 45 deg")
end

--@api-stub: LGlobe:setAutoRotationSpeed
-- Sets automatic rotation speed.
do
    local g = lurek.globe.new("arot_globe")
    g:setAutoRotationSpeed(10)
    print("auto rotation = 10 dps")
end

--@api-stub: LGlobe:setTimeOfDay
-- Sets globe time of day.
do
    local g = lurek.globe.new("tod_globe")
    g:setTimeOfDay(14.5)
    print("time = 14:30")
end

--@api-stub: LGlobe:getTimeOfDay
-- Returns globe time of day.
do
    local g = lurek.globe.new("gtod_globe")
    g:setTimeOfDay(8.0)
    local t = g:getTimeOfDay()
    print("time of day = " .. t)
end

--@api-stub: LGlobe:update
-- Advances globe simulation.
do
    local g = lurek.globe.new("upd_globe")
    g:update(0.016)
    print("globe updated")
end

--@api-stub: LGlobe:type
-- Returns the type name "LGlobe".
do
    local g = lurek.globe.new("type_globe")
    print("type = " .. g:type())
end

--@api-stub: LGlobe:typeOf
-- Returns whether this globe matches a type name.
do
    local g = lurek.globe.new("typeof_globe")
    print("is Globe = " .. tostring(g:typeOf("Globe")))
end

--- Globe Module: LGlobeRegistry methods

--@api-stub: LGlobeRegistry:get
--@api-stub: LGlobeRegistry:names
--@api-stub: LGlobeRegistry:new
--@api-stub: LGlobeRegistry:remove
--@api-stub: LGlobeRegistry:type
--@api-stub: LGlobeRegistry:typeOf
-- Globe registry: look up, create, remove, and type-check globe entries.
do
    ---@type LGlobeRegistry?
    local reg = nil
    if reg then
        local globe = reg:get("earth")
        local all_names = reg:names()
        for _, n in ipairs(all_names) do print(n) end
        local g2 = reg:new("mars", { radius = 1.0, subdivisions = 3 })
        reg:remove("mars")
        print(reg:type())
        print(reg:typeOf("LGlobeRegistry"))
        print(reg:typeOf("Object"))
    end
end

print("content/examples/globe.lua")
