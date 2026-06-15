-- content/examples/globe.lua
-- Auto-generated from content/examples2/globe_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/globe.lua

--- Globe Module Part 1: factories, registry, constants, utilities

--@api: lurek.globe.MAX_PROVINCES
do
    print("max provinces = " .. lurek.globe.MAX_PROVINCES)
    print("capacity ok = " .. tostring(lurek.globe.MAX_PROVINCES > 0))
end

--@api: lurek.globe.LOD_FAR
do
    print("LOD_FAR = " .. lurek.globe.LOD_FAR)
    print("LOD_FAR > LOD_MID: " .. tostring(lurek.globe.LOD_FAR > lurek.globe.LOD_MID))
end

--@api: lurek.globe.LOD_MID
do
    print("LOD_MID = " .. lurek.globe.LOD_MID)
    print("LOD_MID between FAR and NEAR: " .. tostring(lurek.globe.LOD_FAR > lurek.globe.LOD_MID and lurek.globe.LOD_MID > lurek.globe.LOD_NEAR))
end

--@api: lurek.globe.LOD_NEAR
do
    print("LOD_NEAR = " .. lurek.globe.LOD_NEAR)
    print("LOD_NEAR smallest: " .. tostring(lurek.globe.LOD_NEAR < lurek.globe.LOD_MID))
end

--@api: lurek.globe.new
do
    local g = lurek.globe.new("test_globe")
    print("globe type = " .. g:type())
end

--@api: lurek.globe.newRegistry
do
    local reg = lurek.globe.newRegistry()
    print("registry created = " .. tostring(reg ~= nil))
    print("registry type = " .. reg:type())
end

--@api: lurek.globe.get
do
    lurek.globe.new("my_globe")
    local g = lurek.globe.get("my_globe")
    if g then
        print("got globe: " .. g:getName())
    end
end

--@api: lurek.globe.generateVoronoi
do
    local g = lurek.globe.generateVoronoi("voronoi_globe", { { 0, 0 }, { 30, 45 }, { -20, 90 }, { 60, -30 } }, {})
    print("voronoi provinces = " .. g:provinceCount())
end

--@api: lurek.globe.loadFromTOML
do
    local toml = '[[province]]\nid = 1\ncentroid = [10.0, 20.0]\nvertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]'
    local g = lurek.globe.loadFromTOML("toml_globe", toml)
    print("toml globe provinces = " .. g:provinceCount())
end

--@api: lurek.globe.loadFromTOMLFile
do
    local path = "save/globe_example.toml"
    lurek.filesystem.write(path, "[[province]]\nid = 1\ncentroid = [10.0, 20.0]\nvertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]\n")

    local g = lurek.globe.loadFromTOMLFile("toml_file_globe", path, {})
    print("toml file globe provinces = " .. g:provinceCount())
end

--@api: lurek.globe.loadFromPNG
do
    local g = lurek.globe.loadFromPNG("png_globe", "assets/textures/province_map.png")
    print("png globe provinces = " .. g:provinceCount())
end

--@api: lurek.globe.greatCircleDistance
do
    local d = lurek.globe.greatCircleDistance(0, 0, 90, 0)
    print("distance 0,0 -> 90,0 = " .. d)
end

--@api: lurek.globe.greatCirclePath
do
    local points = lurek.globe.greatCirclePath(0, 0, 45, 90, 5)
    print("path has " .. #points .. " points")
    for _, p in ipairs(points) do
        print("  lat=" .. p[1] .. " lon=" .. p[2])
    end
end

--@api: lurek.globe.latLonToUnit
do
    local v = lurek.globe.latLonToUnit(0, 0)
    print("unit vec = " .. v[1] .. "," .. v[2] .. "," .. v[3])
end

--@api: lurek.globe.raySphereIntersect
do
    local t = lurek.globe.raySphereIntersect(0.0, 0.0, -2.0, 0.0, 0.0, 1.0, 1.0)
    print("hit distance = " .. tostring(t))
    print("ray hits sphere = " .. tostring(t ~= nil))
end

--- Globe Module Part 2: LGlobe methods (camera, provinces, markers, layers, fog)

--@api: LGlobe:getName
do
    local g = lurek.globe.new("named_globe")
    print("name = " .. g:getName())
end

--@api: LGlobe:provinceCount
do
    local g = lurek.globe.new("count_globe")
    print("provinces = " .. g:provinceCount())
end

--@api: LGlobe:addProvince
do
    local g = lurek.globe.new("prov_globe")
    local ok = g:addProvince({ id = 1, centroid = { 10.0, 20.0 }, vertices = { { 9, 19 }, { 11, 19 }, { 11, 21 }, { 9, 21 } } })
    print("added = " .. tostring(ok))
end

--@api: LGlobe:removeProvince
do
    local g = lurek.globe.new("rem_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local ok = g:removeProvince(1)
    print("removed = " .. tostring(ok))
end

--@api: LGlobe:getNeighbors
do
    local g = lurek.globe.new("neigh_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    local n = g:getNeighbors(1)
    print("neighbors of 1: " .. #n)
end

--@api: LGlobe:setProvinceAttr
do
    local g = lurek.globe.new("attr_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "owner", "player1")
    print("set attr owner")
end

--@api: LGlobe:getProvinceAttr
do
    local g = lurek.globe.new("rattr_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "terrain", "forest")
    local val = g:getProvinceAttr(1, "terrain")
    print("terrain = " .. tostring(val))
end

--@api: LGlobe:setProvinceSector
do
    local g = lurek.globe.new("sec_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "northern")
    print("sector set")
end

--@api: LGlobe:getProvinceSector
do
    local g = lurek.globe.new("gsec_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "eastern")
    local s = g:getProvinceSector(1)
    print("sector = " .. tostring(s))
end

--@api: LGlobe:getSectorProvinces
do
    local g = lurek.globe.new("sp_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "west")
    local ids = g:getSectorProvinces("west")
    print("west has " .. #ids .. " provinces")
end

--@api: LGlobe:setCamera
do
    local g = lurek.globe.new("cam_globe")
    g:setCamera(45, 90, 2.0)
    print("camera set")
end

--@api: LGlobe:getCamera
do
    local g = lurek.globe.new("gcam_globe")
    g:setCamera(30, 60, 1.5)
    local lat, lon, z = g:getCamera()
    print("camera: " .. lat .. "," .. lon .. " z=" .. z)
end

--@api: LGlobe:pan
do
    local g = lurek.globe.new("pan_globe")
    g:setCamera(0, 0, 1.0)
    g:pan(10, 20)
    local lat, lon, z = g:getCamera()
    print("after pan: " .. lat .. "," .. lon)
end

--@api: LGlobe:zoom
do
    local g = lurek.globe.new("zoom_globe")
    g:setCamera(0, 0, 1.0)
    g:zoom(2.0)
    local _, _, z = g:getCamera()
    print("zoom = " .. z)
end

--@api: LGlobe:getLod
do
    local g = lurek.globe.new("lod_globe")
    g:setCamera(0, 0, 0.5)
    print("lod = " .. g:getLod())
end

--@api: LGlobe:addMarker
do
    local g = lurek.globe.new("mark_globe")
    local id = g:addMarker("city", 51.5, -0.12, "London")
    print("marker id = " .. id)
end

--@api: LGlobe:moveMarker
do
    local g = lurek.globe.new("mv_globe")
    local id = g:addMarker("pin", 0, 0)
    g:moveMarker(id, 10, 20)
    print("marker moved")
end

--@api: LGlobe:removeMarker
do
    local g = lurek.globe.new("rm_globe")
    local id = g:addMarker("pin", 0, 0)
    local ok = g:removeMarker(id)
    print("removed marker = " .. tostring(ok))
end

--@api: LGlobe:setMarkerAttr
do
    local g = lurek.globe.new("ma_globe")
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "population", "2M")
    print("marker attr set")
end

--@api: LGlobe:getMarkerAttr
do
    local g = lurek.globe.new("ga_globe")
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "country", "France")
    local val = g:getMarkerAttr(id, "country")
    print("country = " .. tostring(val))
end

--@api: LGlobe:setMarkerVisible
do
    local g = lurek.globe.new("vis_globe")
    local id = g:addMarker("pin", 0, 0)
    g:setMarkerVisible(id, false)
    print("marker hidden")
end

--@api: LGlobe:setMarkerPulse
do
    local g = lurek.globe.new("pulse_globe")
    local id = g:addMarker("alert", 0, 0, "!")
    g:setMarkerPulse(id, 2.0, 0.5)
    print("pulse set")
end

--@api: LGlobe:setMarkerRotation
do
    local g = lurek.globe.new("rot_globe")
    local id = g:addMarker("spin", 0, 0)
    g:setMarkerRotation(id, 90)
    print("rotation = 90 dps")
end

--@api: LGlobe:addLabel
do
    local g = lurek.globe.new("lbl_globe")
    local id = g:addLabel("region", 40, -74, "New York")
    print("label id = " .. id)
end

--@api: LGlobe:setLabelText
do
    local g = lurek.globe.new("ltxt_globe")
    local id = g:addLabel("city", 0, 0, "old")
    g:setLabelText(id, "new")
    print("label updated")
end

--@api: LGlobe:setLabelVisible
do
    local g = lurek.globe.new("lvis_globe")
    local id = g:addLabel("info", 0, 0, "text")
    g:setLabelVisible(id, false)
    print("label hidden")
end

--@api: LGlobe:removeLabel
do
    local g = lurek.globe.new("rlbl_globe")
    local id = g:addLabel("tmp", 0, 0, "temp")
    local ok = g:removeLabel(id)
    print("label removed = " .. tostring(ok))
end

--@api: LGlobe:addArc
do
    local g = lurek.globe.new("arc_globe")
    local id = g:addArc(0, 0, 45, 90, 12)
    print("arc id = " .. id)
end

--@api: LGlobe:removeArc
do
    local g = lurek.globe.new("rarc_globe")
    local id = g:addArc(0, 0, 30, 60)
    local ok = g:removeArc(id)
    print("arc removed = " .. tostring(ok))
end

--@api: LGlobe:addLayer
do
    local g = lurek.globe.new("layer_globe")
    g:addLayer("terrain", 0)
    g:addLayer("borders", 1)
    print("layers added")
end

--@api: LGlobe:removeLayer
do
    local g = lurek.globe.new("rl_globe")
    g:addLayer("temp_layer")
    local ok = g:removeLayer("temp_layer")
    print("layer removed = " .. tostring(ok))
end

--@api: LGlobe:setLayerVisible
do
    local g = lurek.globe.new("lv_globe")
    g:addLayer("overlay")
    g:setLayerVisible("overlay", false)
    print("overlay hidden")
end

--@api: LGlobe:setLayerAlpha
do
    local g = lurek.globe.new("la_globe")
    g:addLayer("fog_layer")
    g:setLayerAlpha("fog_layer", 0.5)
    print("layer alpha = 0.5")
end

--@api: LGlobe:setLayerColor
do
    local g = lurek.globe.new("lc_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:addLayer("highlight")
    g:setLayerColor("highlight", 1, 1.0, 0.0, 0.0, 1.0)
    print("province 1 colored red in highlight layer")
end

--@api: LGlobe:setHeatLayer
do
    local g = lurek.globe.new("heat_globe")
    g:setHeatLayer("population", "pop", 0, 1000000, 0.7)
    print("heat layer set")
end

--@api: LGlobe:removeHeatLayer
do
    local g = lurek.globe.new("rheat_globe")
    g:setHeatLayer("income", "gdp", 0, 50000, 0.5)
    local ok = g:removeHeatLayer("income")
    print("heat removed = " .. tostring(ok))
end

--@api: LGlobe:setBorders
do
    local g = lurek.globe.new("bord_globe")
    g:setBorders(true)
    print("borders enabled")
end

--@api: LGlobe:setActiveViewer
do
    local g = lurek.globe.new("fow_globe")
    g:setActiveViewer("player1")
    print("active viewer = player1")
end

--@api: LGlobe:revealProvince
do
    local g = lurek.globe.new("rev_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("player1", 1)
    print("province 1 revealed")
end

--@api: LGlobe:hideProvince
do
    local g = lurek.globe.new("hide_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:hideProvince("player1", 1)
    print("province 1 hidden")
end

--@api: LGlobe:revealAll
do
    local g = lurek.globe.new("rall_globe")
    g:revealAll("player1")
    print("all revealed for player1")
end

--@api: LGlobe:isVisible
do
    local g = lurek.globe.new("isv_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("p1", 1)
    print("visible = " .. tostring(g:isVisible("p1", 1)))
end

--@api: LGlobe:setFogState
do
    local g = lurek.globe.new("fs_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "explored")
    print("fog state set to explored")
end

--@api: LGlobe:getFogState
do
    local g = lurek.globe.new("gfs_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "visible")
    local state = g:getFogState("p1", 1)
    print("fog = " .. state)
end

--@api: LGlobe:encodeFogBase64
do
    local g = lurek.globe.new("enc_globe")
    local b64 = g:encodeFogBase64("p1")
    print("encoded fog length = " .. #b64)
end

--@api: LGlobe:decodeFogBase64
do
    local g = lurek.globe.new("dec_globe")
    local b64 = g:encodeFogBase64("p1")
    local ok = g:decodeFogBase64("p1", b64)
    print("decoded = " .. tostring(ok))
end

--@api: LGlobe:findPath
do
    local g = lurek.globe.new("path_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    print("path length = " .. #(g:findPath(1, 2) or {}))
end

--@api: LGlobe:reachable
do
    local g = lurek.globe.new("reach_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    local costs = g:reachable(1, 10.0)
    print("cost to 1 = " .. tostring(costs[1]))
    print("cost to 2 = " .. tostring(costs[2]))
end

--@api: LGlobe:cacheReachability
do
    local g = lurek.globe.new("cache_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_a", 1, 5.0)
    print("reachability cached")
end

--@api: LGlobe:getCachedReachability
do
    local g = lurek.globe.new("gcache_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_b", 1, 5.0)
    local costs = g:getCachedReachability("faction_b")
    print("cached costs type = " .. type(costs))
    print("cached cost to 1 = " .. tostring(costs[1]))
end

--@api: LGlobe:pick
do
    local g = lurek.globe.new("pick_globe")
    local id = g:pick(400, 300)
    print("picked province = " .. tostring(id))
end

--@api: LGlobe:pickLatLon
do
    local g = lurek.globe.new("pll_globe")
    local cx, cy = g:pickLatLon(400, 300)
    print("centroid = " .. tostring(cx) .. "," .. tostring(cy))
end

--@api: LGlobe:pickRaycast
do
    local g = lurek.globe.new("pray_globe")
    local id = g:pickRaycast(400, 300, 32)
    print("raycast pick = " .. tostring(id))
end

--@api: LGlobe:setProvinceTexture
do
    local g = lurek.globe.new("tex_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0.0, 0.0, 1.0, 1.0)
    print("province texture set")
end

--@api: LGlobe:clearProvinceTexture
do
    local g = lurek.globe.new("ctex_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0, 0, 1, 1)
    g:clearProvinceTexture(1)
    print("texture cleared")
end

--@api: LGlobe:exportProvinceMeshOBJ
do
    local g = lurek.globe.new("obj_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local obj = g:exportProvinceMeshOBJ()
    print("OBJ length = " .. #obj)
end

--@api: LGlobe:setRotation
do
    local g = lurek.globe.new("srot_globe")
    g:setRotation(45)
    print("rotation = 45 deg")
end

--@api: LGlobe:setAutoRotationSpeed
do
    local g = lurek.globe.new("arot_globe")
    g:setAutoRotationSpeed(10)
    print("auto rotation = 10 dps")
end

--@api: LGlobe:setTimeOfDay
do
    local g = lurek.globe.new("tod_globe")
    g:setTimeOfDay(14.5)
    print("time = 14:30")
end

--@api: LGlobe:getTimeOfDay
do
    local g = lurek.globe.new("gtod_globe")
    g:setTimeOfDay(8.0)
    local t = g:getTimeOfDay()
    print("time of day = " .. t)
end

--@api: LGlobe:update
do
    local g = lurek.globe.new("upd_globe")
    g:update(0.016)
    print("globe updated")
end

--@api: LGlobe:type
do
    local g = lurek.globe.new("type_globe")
    print("type = " .. g:type())
end

--@api: LGlobe:typeOf
do
    local g = lurek.globe.new("typeof_globe")
    print("is Globe = " .. tostring(g:typeOf("LGlobe")))
end

--- Globe Module: LGlobeRegistry methods

--@api: LGlobeRegistry:get
do
    local reg = lurek.globe.newRegistry()
    reg:new("earth")
    print("registry get = " .. tostring(reg:get("earth")))
end

--@api: LGlobeRegistry:names
do
    local reg = lurek.globe.newRegistry()
    reg:new("earth")
    reg:new("mars")
    print("registry names count = " .. #reg:names())
end

--@api: LGlobeRegistry:new
do
    local reg = lurek.globe.newRegistry()
    print("registry new = " .. tostring(reg:new("mars", { radius = 1.0 })))
end

--@api: LGlobeRegistry:remove
do
    local reg = lurek.globe.newRegistry()
    reg:new("mars")
    print("registry remove = " .. tostring(reg:remove("mars")))
end

--@api: LGlobeRegistry:type
do
    local reg = lurek.globe.newRegistry()
    print("registry type = " .. tostring(reg:type()))
end

--@api: LGlobeRegistry:typeOf
do
    local reg = lurek.globe.newRegistry()
    print("registry typeOf = " .. tostring(reg:typeOf("LGlobeRegistry")))
end

--@api: lurek.globe.remove
do
    local g = lurek.globe.new("tmp_remove")
    local ok = lurek.globe.remove("tmp_remove")
    print("removed=" .. tostring(ok))
end

--@api: LGlobe:addRegion
do
    local g = lurek.globe.new("region_globe")
    local ok = g:addRegion({
        id = 1,
        centroid = { 50, 15 },
        vertices = { { 49, 14 }, { 51, 14 }, { 51, 16 }, { 49, 16 } },
    })
    print("added region = " .. tostring(ok))
    print("region count = " .. g:regionCount())
end

--@api: LGlobe:removeRegion
do
    local g = lurek.globe.new("remove_region_globe")
    g:addRegion({
        id = 1,
        centroid = { 40, -90 },
        vertices = { { 39, -91 }, { 41, -91 }, { 41, -89 }, { 39, -89 } },
    })
    local ok = g:removeRegion(1)
    print("removed region = " .. tostring(ok))
    print("region count = " .. g:regionCount())
end

--@api: LGlobe:regionCount
do
    local g = lurek.globe.new("count_region_globe")
    g:addRegion({
        id = 1,
        centroid = { 35, 80 },
        vertices = { { 34, 79 }, { 36, 79 }, { 36, 81 }, { 34, 81 } },
    })
    g:addRegion({
        id = 2,
        centroid = { -10, 20 },
        vertices = { { -11, 19 }, { -9, 19 }, { -9, 21 }, { -11, 21 } },
    })
    print("region count = " .. g:regionCount())
end

local function build_demo_globe(name)
    local g = lurek.globe.new(name)
    g:addProvince({ id = 1, centroid = { 0, 0 }, vertices = { { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }, neighbors = { 2 } })
    g:addProvince({ id = 2, centroid = { 0, 5 }, vertices = { { -1, 4 }, { 1, 4 }, { 1, 6 }, { -1, 6 } }, neighbors = { 1, 3 } })
    g:addProvince({ id = 3, centroid = { 0, 10 }, vertices = { { -1, 9 }, { 1, 9 }, { 1, 11 }, { -1, 11 } }, neighbors = { 2 } })
    g:addRegion({ id = 10, centroid = { 0, 0 }, vertices = { { -2, -2 }, { 2, -2 }, { 2, 2 }, { -2, 2 } } })
    g:addRegion({ id = 11, centroid = { 0, 10 }, vertices = { { -2, 8 }, { 2, 8 }, { 2, 12 }, { -2, 12 } } })
    local a = g:addMarker("city", 0, 0, "Alpha")
    local b = g:addMarker("city", 0, 10, "Beta")
    g:setCamera(0, 0, 1.2)
    return g, a, b
end

--@api: LGlobe:setEdgeTags
do
    local g = build_demo_globe("edge_tags_globe")
    local ok = g:setEdgeTags(1, 2, { "road", "river" })
    print("set edge tags = " .. tostring(ok))
    print("tags count = " .. #(g:getEdgeTags(1, 2) or {}))
end

--@api: LGlobe:getEdgeTags
do
    local g = build_demo_globe("get_edge_tags_globe")
    g:setEdgeTags(1, 2, { "road", "trade" })
    local tags = g:getEdgeTags(1, 2)
    print("edge tags = " .. table.concat(tags, ","))
end

--@api: LGlobe:setRegionAttr
do
    local g = build_demo_globe("region_attr_globe")
    local ok = g:setRegionAttr(10, "climate", "temperate")
    print("set region attr = " .. tostring(ok))
    print("value = " .. tostring(g:getRegionAttr(10, "climate")))
end

--@api: LGlobe:getRegionAttr
do
    local g = build_demo_globe("get_region_attr_globe")
    g:setRegionAttr(11, "owner", "faction_b")
    print("owner = " .. tostring(g:getRegionAttr(11, "owner")))
end

--@api: LGlobe:screenDeltaToPan
do
    local g = build_demo_globe("screen_delta_globe")
    local dlat, dlon = g:screenDeltaToPan(32, -16)
    print("pan delta = " .. tostring(dlat) .. "," .. tostring(dlon))
end

--@api: LGlobe:applyMouseDrag
do
    local g = build_demo_globe("mouse_drag_globe")
    g:applyMouseDrag(320, 180, 360, 210)
    local lat, lon, zoom = g:getCamera()
    print("camera after drag = " .. lat .. "," .. lon .. "," .. zoom)
end

--@api: LGlobe:applyWheelZoom
do
    local g = build_demo_globe("wheel_zoom_globe")
    g:applyWheelZoom(-1.0)
    local _, _, zoom = g:getCamera()
    print("camera zoom = " .. zoom)
end

--@api: LGlobe:screenToLatLon
do
    local g = build_demo_globe("screen_latlon_globe")
    local lat, lon = g:screenToLatLon(320, 180)
    print("latlon = " .. tostring(lat) .. "," .. tostring(lon))
end

--@api: LGlobe:pickRegions
do
    local g = build_demo_globe("pick_regions_globe")
    local ids = g:pickRegions(320, 180)
    print("picked regions = " .. #ids)
end

--@api: LGlobe:regionsAtLatLon
do
    local g = build_demo_globe("regions_at_latlon_globe")
    local ids = g:regionsAtLatLon(0, 0)
    print("regions at latlon = " .. #ids)
end

--@api: LGlobe:pickMarker
do
    local g = build_demo_globe("pick_marker_globe")
    local id = g:pickMarker(320, 180, 24)
    print("picked marker = " .. tostring(id))
end

--@api: LGlobe:pickSurface
do
    local g = build_demo_globe("pick_surface_globe")
    local hit = g:pickSurface(320, 180, 24)
    print("picked surface table = " .. tostring(hit ~= nil))
end

--@api: LGlobe:setMarkerColor
do
    local g, a = build_demo_globe("marker_color_globe")
    local ok = g:setMarkerColor(a, 1.0, 0.3, 0.2, 0.9)
    print("set marker color = " .. tostring(ok))
end

--@api: LGlobe:setMarkerSize
do
    local g, a = build_demo_globe("marker_size_globe")
    local ok = g:setMarkerSize(a, 18)
    print("set marker size = " .. tostring(ok))
end

--@api: LGlobe:setMarkerShape
do
    local g, a = build_demo_globe("marker_shape_globe")
    local ok = g:setMarkerShape(a, "diamond")
    print("set marker shape = " .. tostring(ok))
end

--@api: LGlobe:setMarkerIconTexture
do
    local g, a = build_demo_globe("marker_icon_globe")
    local ok = g:setMarkerIconTexture(a, 7)
    print("set marker icon texture = " .. tostring(ok))
end

--@api: LGlobe:distanceBetweenMarkers
do
    local g, a, b = build_demo_globe("marker_distance_globe")
    local d = g:distanceBetweenMarkers(a, b)
    print("marker distance = " .. tostring(d))
end

--@api: LGlobe:draw
do
    local g = build_demo_globe("draw_globe")
    g:draw()
    print("draw issued")
    print("type = " .. g:type())
end

--@api: LGlobe:findPathWithCosts
do
    local g = build_demo_globe("find_costs_globe")
    local path = g:findPathWithCosts(1, 3)
    print("path table = " .. type(path))
    print("path first = " .. tostring(path and path[1]))
end

--@api: LGlobe:reachableWithCosts
do
    local g = build_demo_globe("reachable_costs_globe")
    local costs = g:reachableWithCosts(1, 10.0)
    print("cost table = " .. type(costs))
    print("cost to 2 = " .. tostring(costs[2]))
end
