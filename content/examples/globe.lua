-- content/examples/globe.lua
-- lurek.globe API examples.
-- Run: cargo run -- content/examples/globe.lua

--@api-stub: lurek.globe.new -- Creates a named globe with optional specification fields in the module registry
do -- lurek.globe.new
  local g = lurek.globe.new("earth_demo", { radius = 1.0, axial_tilt_deg = 23.5 })
  g:setBorders(true)
  lurek.log.info("created globe " .. g:getName(), "globe")
end

--@api-stub: lurek.globe.get -- Returns a globe from the module registry by name
do -- lurek.globe.get
  lurek.globe.new("campaign", {})
  local g = lurek.globe.get("campaign")
  if g then lurek.log.info("found globe " .. g:getName(), "globe") end
end

--@api-stub: lurek.globe.loadFromTOML -- Creates a globe and populates provinces from TOML source text
do -- lurek.globe.loadFromTOML
  local toml_src = [=[
  [[provinces]]
  id = 1
  centroid = [10.0, 20.0]
  vertices = [[5.0,15.0],[15.0,15.0],[15.0,25.0],[5.0,25.0]]
  ]=]
  local g = lurek.globe.loadFromTOML("loaded", toml_src, {})
  lurek.log.info("loaded provinces=" .. g:provinceCount(), "globe")
end

--@api-stub: lurek.globe.greatCircleDistance -- Computes great-circle distance between two latitude-longitude points
do -- lurek.globe.greatCircleDistance
  local rad = lurek.globe.greatCircleDistance(40.7, -74.0, 51.5, -0.1)
  local km = rad * 6371.0
  lurek.log.info(string.format("NYC->London = %.0f km", km), "globe")
end

--@api-stub: lurek.globe.greatCirclePath -- Computes sampled latitude-longitude points along a great-circle path
do -- lurek.globe.greatCirclePath
  local pts = lurek.globe.greatCirclePath(0.0, 0.0, 0.0, 90.0, 8)
  for i, p in ipairs(pts) do
    lurek.log.debug(string.format("step %d: lat=%.1f lon=%.1f", i, p[1], p[2]), "globe")
  end
end

--@api-stub: lurek.globe.latLonToUnit -- Converts latitude and longitude to a unit-sphere 3D vector table
do -- lurek.globe.latLonToUnit
  local v = lurek.globe.latLonToUnit(45.0, 90.0)
  local mag = math.sqrt(v[1]*v[1] + v[2]*v[2] + v[3]*v[3])
  lurek.log.info(string.format("unit vec |v|=%.3f", mag), "globe")
end

-- â”€â”€ Globe methods â”€â”€

--@api-stub: Globe:addProvince
do -- Globe:addProvince
  local g = lurek.globe.new("addprov", {})
  g:addProvince({
    id = 7, centroid = {30.0, 40.0},
    vertices = {{25.0,35.0},{35.0,35.0},{35.0,45.0},{25.0,45.0}},
    neighbors = {}, base_color = {0.2, 0.6, 0.3, 1.0},
  })
end

--@api-stub: Globe:removeProvince
do -- Globe:removeProvince
  local g = lurek.globe.new("rmprov", {})
  g:addProvince({ id = 9, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  local existed = g:removeProvince(9)
  lurek.log.info("removed=" .. tostring(existed) .. " count=" .. g:provinceCount(), "globe")
end

--@api-stub: Globe:provinceCount
do -- Globe:provinceCount
  local g = lurek.globe.new("count_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:addProvince({ id = 2, centroid = {5,5}, vertices = {{4,4},{6,4},{6,6}} })
  lurek.log.info("provinces=" .. g:provinceCount(), "globe")
end

--@api-stub: Globe:getNeighbors
do -- Globe:getNeighbors
  local g = lurek.globe.new("neigh_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}}, neighbors = {2, 3} })
  local nbrs = g:getNeighbors(1)
  lurek.log.info("province 1 has " .. #nbrs .. " neighbors", "globe")
end

--@api-stub: Globe:getProvinceAttr
do -- Globe:getProvinceAttr
  local g = lurek.globe.new("attr_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:setProvinceAttr(1, "owner", "blue_faction")
  local owner = g:getProvinceAttr(1, "owner") or "neutral"
  lurek.log.info("province 1 owner=" .. owner, "globe")
end

--@api-stub: Globe:pan
do -- Globe:pan
  local g = lurek.globe.new("pan_demo", {})
  function lurek.process(dt)
    if lurek.input.keyboard.isDown("a") then g:pan(0, -45.0 * dt) end
    if lurek.input.keyboard.isDown("d") then g:pan(0,  45.0 * dt) end
  end
end

--@api-stub: Globe:zoom
do -- Globe:zoom
  local g = lurek.globe.new("zoom_demo", {})
  function lurek.process(dt)
    local _, wheel = lurek.input.mouse.getWheelDelta()
    if wheel ~= 0 then g:zoom(1.0 + wheel * 0.1) end
  end
end

--@api-stub: Globe:setCamera
do -- Globe:setCamera
  local g = lurek.globe.new("setcam_demo", {})
  g:setCamera(48.85, 2.35, 3.0)  -- centred on Paris, zoomed in
  local lat, lon, z = g:getCamera()
  lurek.log.info(string.format("camera lat=%.2f lon=%.2f zoom=%.1f", lat, lon, z), "globe")
end

--@api-stub: Globe:getCamera
do -- Globe:getCamera
  local g = lurek.globe.new("getcam_demo", {})
  g:setCamera(0.0, 0.0, 1.5)
  local lat, lon, z = g:getCamera()
  lurek.filesystem.write("save/globe_camera.txt", string.format("%.3f,%.3f,%.3f", lat, lon, z))
end

--@api-stub: Globe:getLod
do -- Globe:getLod
  local g = lurek.globe.new("lod_demo", {})
  g:setCamera(0, 0, 5.0)
  local tier = g:getLod()
  if tier == "near" then lurek.log.info("show city sprites", "globe") end
end

--@api-stub: Globe:pick
do -- Globe:pick
  local g = lurek.globe.new("pick_demo", {})
  function lurek.input_pressed(key)
    local mx, my = lurek.input.mouse.getPosition()
    mx, my = mx or 0, my or 0
    local id = g:pick(mx, my)
    if id then lurek.log.info("clicked province " .. id, "globe") end
  end
end

--@api-stub: Globe:pickLatLon
do -- Globe:pickLatLon
  local g = lurek.globe.new("picklatlon_demo", {})
  function lurek.input_pressed(key)
    local mx, my = lurek.input.mouse.getPosition()
    mx, my = mx or 0, my or 0
    local lat, lon = g:pickLatLon(mx, my)
    if lat and lon then g:addMarker("waypoint", lat, lon, "click") end
  end
end

--@api-stub: Globe:setActiveViewer
do -- Globe:setActiveViewer
  local g = lurek.globe.new("viewer_demo", {})
  g:setActiveViewer("blue_faction")
  g:revealAll("blue_faction")
  lurek.log.info("active viewer set", "globe")
end

--@api-stub: Globe:revealProvince
do -- Globe:revealProvince
  local g = lurek.globe.new("reveal_demo", {})
  g:addProvince({ id = 12, centroid = {10,10}, vertices = {{9,9},{11,9},{11,11}} })
  g:revealProvince("blue_faction", 12)
  lurek.log.info("province 12 revealed for blue", "globe")
end

--@api-stub: Globe:hideProvince
do -- Globe:hideProvince
  local g = lurek.globe.new("hide_demo", {})
  g:addProvince({ id = 5, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:revealProvince("blue", 5)
  g:hideProvince("blue", 5)
  lurek.log.info("province 5 re-fogged for blue", "globe")
end

--@api-stub: Globe:isVisible
do -- Globe:isVisible
  local g = lurek.globe.new("vis_demo", {})
  g:addProvince({ id = 3, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:revealProvince("blue", 3)
  if g:isVisible("blue", 3) then lurek.log.info("province 3 visible to blue", "globe") end
end

--@api-stub: Globe:revealAll
do -- Globe:revealAll
  local g = lurek.globe.new("revealall_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:addProvince({ id = 2, centroid = {5,5}, vertices = {{4,4},{6,4},{6,6}} })
  g:revealAll("debug_viewer")
  lurek.log.info("all provinces revealed for debug_viewer", "globe")
end

--@api-stub: lurek.globe.loadFromPNG -- Creates a globe and populates provinces from a PNG file
do -- lurek.globe.loadFromPNG
  local ok, g = pcall(function()
    return lurek.globe.loadFromPNG("png_demo", "assets/textures/nonexistent.png", {})
  end)
  if ok and g then lurek.log.debug("png globe loaded", "globe") end
end

--@api-stub: lurek.globe.generateVoronoi -- Creates a globe and populates provinces from latitude-longitude seed points
do -- lurek.globe.generateVoronoi
  local g = lurek.globe.generateVoronoi("voronoi_demo", {
    {0.0, 0.0}, {10.0, 20.0}, {-20.0, 30.0},
  }, {})
  lurek.log.info("voronoi provinces=" .. g:provinceCount(), "globe")
end

--@api-stub: Globe:setProvinceTexture
do -- Globe:setProvinceTexture
  local g = lurek.globe.new("tex_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:setProvinceTexture(1, 0, 0.0, 0.0, 1.0, 1.0)
end

--@api-stub: Globe:clearProvinceTexture
do -- Globe:clearProvinceTexture
  local g = lurek.globe.new("cleartex_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:clearProvinceTexture(1)
end

--@api-stub: Globe
do -- Globe sector api
  local g = lurek.globe.new("sector_demo", {})
  g:addProvince({ id = 2, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:setProvinceSector(2, "north")
  local _ = g:getProvinceSector(2)
  local _ids = g:getSectorProvinces("north")
end

--@api-stub: Globe
do -- Globe heat layer api
  local g = lurek.globe.new("heat_demo", {})
  g:setHeatLayer("population", "pop", 0.0, 100.0, 0.5)
  g:removeHeatLayer("population")
end

--@api-stub: Globe
do -- Globe fog extended api
  local g = lurek.globe.new("fogx_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:setFogState("p1", 1, "explored")
  local _state = g:getFogState("p1", 1)
  local data = g:encodeFogBase64("p1")
  g:decodeFogBase64("p1", data)
end

--@api-stub: Globe
do -- Globe marker animation api
  local g = lurek.globe.new("marker_anim_demo", {})
  local id = g:addMarker("poi", 10.0, 10.0, "A")
  g:setMarkerPulse(id, 2.0, 0.2)
  g:setMarkerRotation(id, 120.0)
end

--@api-stub: Globe
do -- Globe auto rotation api
  local g = lurek.globe.new("autorot_demo", {})
  g:setAutoRotationSpeed(0.02)
end

--@api-stub: Globe
do -- Globe AI reachability api
  local g = lurek.globe.new("reach_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}}, neighbors = {2} })
  g:addProvince({ id = 2, centroid = {2,2}, vertices = {{2,2},{3,2},{3,3}}, neighbors = {1} })
  g:cacheReachability("blue", 1, 5.0)
  local _map = g:getCachedReachability("blue")
end

--@api-stub: Globe:pickRaycast
do -- Globe:pickRaycast
  local g = lurek.globe.new("raypick_demo", {})
  local _ = g:pickRaycast(640, 360, 16)
end

--@api-stub: Globe:exportProvinceMeshOBJ
do -- Globe:exportProvinceMeshOBJ
  local g = lurek.globe.new("obj_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  local obj = g:exportProvinceMeshOBJ()
  lurek.filesystem.write("save/globe_mesh.obj", obj)
end
--@api-stub: Globe:removeMarker
do -- Globe:removeMarker
  local g = lurek.globe.new("rmmark_demo", {})
  local id = g:addMarker("ufo", 30.0, -60.0, "Bogey-1")
  local ok = g:removeMarker(id)
  lurek.log.info("removed marker " .. id .. " ok=" .. tostring(ok), "globe")
end

--@api-stub: Globe:moveMarker
do -- Globe:moveMarker
  local g = lurek.globe.new("movemark_demo", {})
  local id = g:addMarker("ship", 0.0, 0.0, "USS Hope")
  function lurek.process(dt)
    g:moveMarker(id, 0.0, (lurek.time.getTime() * 5.0) % 360.0)
  end
end

--@api-stub: Globe:setMarkerVisible
do -- Globe:setMarkerVisible
  local g = lurek.globe.new("markvis_demo", {})
  local id = g:addMarker("base", 51.5, -0.1, "HQ")
  g:setMarkerVisible(id, false)
  lurek.log.info("HQ marker hidden during cutscene", "globe")
end

--@api-stub: Globe:getMarkerAttr
do -- Globe:getMarkerAttr
  local g = lurek.globe.new("markattr_demo", {})
  local id = g:addMarker("squad", 0.0, 0.0, "Alpha")
  g:setMarkerAttr(id, "fuel", "85")
  local fuel = g:getMarkerAttr(id, "fuel") or "0"
  lurek.log.info("squad fuel=" .. fuel, "globe")
end

--@api-stub: Globe:setLabelText
do -- Globe:setLabelText
  local g = lurek.globe.new("labeltxt_demo", {})
  local id = g:addLabel("city", 51.5, -0.1, "London")
  g:setLabelText(id, "New London")
  lurek.log.info("relabelled city " .. id, "globe")
end

--@api-stub: Globe:setLabelVisible
do -- Globe:setLabelVisible
  local g = lurek.globe.new("labelvis_demo", {})
  local id = g:addLabel("city", 0.0, 0.0, "Origin")
  g:setLabelVisible(id, g:getLod() ~= "far")
  lurek.log.info("label visible based on LOD", "globe")
end

--@api-stub: Globe:removeLabel
do -- Globe:removeLabel
  local g = lurek.globe.new("rmlabel_demo", {})
  local id = g:addLabel("city", 0, 0, "Atlantis")
  local ok = g:removeLabel(id)
  lurek.log.info("removed label " .. id .. " ok=" .. tostring(ok), "globe")
end

--@api-stub: Globe:removeLayer
do -- Globe:removeLayer
  local g = lurek.globe.new("rmlayer_demo", {})
  g:addLayer("weather", 5)
  local ok = g:removeLayer("weather")
  lurek.log.info("removed weather layer ok=" .. tostring(ok), "globe")
end

--@api-stub: Globe:setLayerVisible
do -- Globe:setLayerVisible
  local g = lurek.globe.new("layervis_demo", {})
  g:addLayer("politics", 1)
  g:setLayerVisible("politics", false)
  lurek.log.info("politics overlay hidden", "globe")
end

--@api-stub: Globe:setLayerAlpha
do -- Globe:setLayerAlpha
  local g = lurek.globe.new("layeralpha_demo", {})
  g:addLayer("heat", 2)
  function lurek.process(dt)
    local a = (math.sin(lurek.time.getTime()) * 0.5 + 0.5)
    g:setLayerAlpha("heat", a)
  end
end

--@api-stub: Globe:setTimeOfDay
do -- Globe:setTimeOfDay
  local g = lurek.globe.new("tod_demo", {})
  function lurek.process(dt)
    local hours = (lurek.time.getTime() * 0.5) % 24.0
    g:setTimeOfDay(hours)
  end
end

--@api-stub: Globe:getTimeOfDay
do -- Globe:getTimeOfDay
  local g = lurek.globe.new("getsod_demo", {})
  g:setTimeOfDay(20.0)
  local t = g:getTimeOfDay()
  if t < 6.0 or t > 18.0 then lurek.log.info("nocturnal spawn window open", "globe") end
end

--@api-stub: Globe:setRotation
do -- Globe:setRotation
  local g = lurek.globe.new("rot_demo", {})
  function lurek.process(dt)
    g:setRotation((lurek.time.getTime() * 6.0) % 360.0)
  end
end

--@api-stub: Globe:update
do -- Globe:update
  local g = lurek.globe.new("update_demo", {})
  function lurek.process(dt)
    g:update(dt)
  end
end

--@api-stub: Globe:setBorders
do -- Globe:setBorders
  local g = lurek.globe.new("border_demo", {})
  g:setBorders(true)
  if g:getLod() == "near" then g:setBorders(false) end
  lurek.log.info("borders configured for LOD " .. g:getLod(), "globe")
end

--@api-stub: Globe:findPath
do -- Globe:findPath
  local g = lurek.globe.new("path_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}}, neighbors = {2} })
  g:addProvince({ id = 2, centroid = {1,1}, vertices = {{1,0},{2,0},{2,1}}, neighbors = {1} })
  local path = g:findPath(1, 2)
  if path then lurek.log.info("path length=" .. #path, "globe") end
end

--@api-stub: Globe:removeArc
do -- Globe:removeArc
  local g = lurek.globe.new("rmarc_demo", {})
  local id = g:addArc(0.0, 0.0, 45.0, 90.0, 24)
  g:removeArc(id)
  lurek.log.info("arc " .. id .. " cleared", "globe")
end

--@api-stub: Globe:getName
do -- Globe:getName
  local g = lurek.globe.new("primary_world", {})
  local name = g:getName()
  lurek.filesystem.write("save/active_globe.txt", name)
  lurek.log.info("active globe = " .. name, "globe")
end

-- â”€â”€ GlobeRegistry methods â”€â”€

--@api-stub: GlobeRegistry:get
do -- GlobeRegistry:get
  lurek.globe.new("alt_world", {})
  local g = lurek.globe.get("alt_world")
  if g then lurek.log.info("registry returned " .. g:getName(), "globe") end
end

--@api-stub: GlobeRegistry:remove
do -- GlobeRegistry:remove
  lurek.globe.new("temp_world", {})
  local g = lurek.globe.get("temp_world")
  if g then lurek.log.info("about to drop " .. g:getName(), "globe") end
  -- registry drop happens at engine shutdown when no Lua handle remains
end

--@api-stub: GlobeRegistry:names
do -- GlobeRegistry:names
  lurek.globe.new("world_a", {})
  lurek.globe.new("world_b", {})
  local g = lurek.globe.get("world_a")
  if g then lurek.log.info("first registered = " .. g:getName(), "globe") end
end


--@api-stub: Globe:addArc
do -- Globe:addArc
  local g = lurek.globe.new("arc_demo", {})
  g:addProvince({ id = 1, centroid = {0,0}, vertices = {{0,0},{1,0},{1,1}} })
  g:addProvince({ id = 2, centroid = {5,5}, vertices = {{4,4},{6,4},{6,6}} })
  local arcId = g:addArc(0, 0, 5, 5, 16)
  lurek.log.info("arc id: " .. arcId, "globe")
end

local function sampleProvince(id, lat, lon, opts)
  opts = opts or {}
  return {
    id = id,
    centroid = {lat, lon},
    vertices = {{lat, lon}, {lat + 1, lon}, {lat + 1, lon + 1}},
    neighbors = opts.neighbors or {},
    base_color = opts.base_color or {0.5, 0.6, 0.7, 1.0},
  }
end

--@api-stub: Globe:addLabel
do -- Globe:addLabel
  local g = lurek.globe.new("label_demo", {})
  g:addProvince(sampleProvince(1, 3, 3))
  local lid = g:addLabel("city", 3, 3, "Capital City")
  lurek.log.info("label id: " .. lid, "globe")
end

--@api-stub: Globe:addLayer
do -- Globe:addLayer
  local g = lurek.globe.new("layer_demo", {})
  g:addLayer("terrain", 1)
  g:addLayer("borders", 2)
  lurek.log.info("layers added", "globe")
end

--@api-stub: Globe:addMarker
do -- Globe:addMarker
  local g = lurek.globe.new("marker_demo", {})
  g:addProvince(sampleProvince(5, 2, 2))
  local mid = g:addMarker("capital_icon", 2, 2, "Capital")
  lurek.log.info("marker id: " .. mid, "globe")
end

--@api-stub: lurek.globe.new -- Creates a named globe with optional specification fields in the module registry
do -- lurek.globe.new
  local g = lurek.globe.new("new_demo", {})
  g:addProvince(sampleProvince(1, 0, 0))
  lurek.log.info("globe province count: " .. g:provinceCount(), "globe")
end

--@api-stub: Globe:reachable
do -- Globe:reachable
  local g = lurek.globe.new("reachable_demo", {})
  for i=1,5 do g:addProvince(sampleProvince(i, i, 0, {neighbors = {i - 1, i + 1}})) end
  local ids = g:reachable(1, 3)
  lurek.log.info("reachable count: " .. #ids, "globe")
end

--@api-stub: Globe:setLayerColor
do -- Globe:setLayerColor
  local g = lurek.globe.new("layer_color_demo", {})
  g:addProvince(sampleProvince(1, 0, 0))
  g:addLayer("ownership", 1)
  g:setLayerColor("ownership", 1, 1, 0.3, 0.3, 0.8)
  lurek.log.info("layer colour set", "globe")
end

--@api-stub: Globe:setMarkerAttr
do -- Globe:setMarkerAttr
  local g = lurek.globe.new("marker_attr_demo", {})
  g:addProvince(sampleProvince(1, 0, 0))
  local mid = g:addMarker("fort_icon", 0, 0, "Fort")
  g:setMarkerAttr(mid, "strength", "5")
  lurek.log.info("marker attr set", "globe")
end

--@api-stub: Globe:setProvinceAttr
do -- Globe:setProvinceAttr
  local g = lurek.globe.new("province_attr_demo", {})
  g:addProvince(sampleProvince(3, 1, 1))
  g:setProvinceAttr(3, "population", "12000")
  lurek.log.info("attr: " .. g:getProvinceAttr(3, "population"), "globe")
end

--@api-stub: GlobeRegistry:new
do -- GlobeRegistry:new
  local g = lurek.globe.new("world_a", {})
  lurek.log.info("registry globe created", "globe")
end

-- -----------------------------------------------------------------------------
-- LGlobe methods
-- -----------------------------------------------------------------------------

--@api-stub: LGlobe:type -- Returns the Lua-visible type name for this globe handle
do -- LGlobe:type
  local globe_obj = lurek.globe.new("test", nil)
  local t = globe_obj:type()
  lurek.log.info("LGlobe:type = " .. t, "globe")
end
--@api-stub: LGlobe:typeOf -- Returns whether this globe handle matches a supported type name
do -- LGlobe:typeOf
  local globe_obj = lurek.globe.new("test", nil)
  lurek.log.info("is LGlobe: " .. tostring(globe_obj:typeOf("LGlobe")), "globe")
  lurek.log.info("is wrong: " .. tostring(globe_obj:typeOf("Unknown")), "globe")
end
--@api-stub: LGlobeRegistry:type -- Returns the Lua-visible type name for this globe registry handle
do -- LGlobeRegistry:type
  local obj = lurek.globe.new("alt_world", {})
    local g = lurek.globe.get("alt_world")
  local t = obj:type()
  lurek.log.info("LGlobeRegistry:type = " .. t, "globe")
end
--@api-stub: LGlobeRegistry:typeOf -- Returns whether this registry handle matches a supported type name
do -- LGlobeRegistry:typeOf
  local obj = lurek.globe.new("alt_world", {})
    local g = lurek.globe.get("alt_world")
  lurek.log.info("is LGlobeRegistry: " .. tostring(obj:typeOf("LGlobeRegistry")), "globe")
  lurek.log.info("is wrong: " .. tostring(obj:typeOf("Unknown")), "globe")
end

