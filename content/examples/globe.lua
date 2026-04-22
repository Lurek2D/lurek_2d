-- content/examples/globe.lua
-- love2d-style usage snippets for the lurek.globe API (44 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/globe.lua

-- ── lurek.globe.* functions ──

--@api-stub: lurek.globe.new
-- Creates a new globe instance with default settings and empty collections.
-- Build once at startup; reuse across frames.
local obj = lurek.globe.new("main", spec_tbl)
print("created", obj)
return obj

--@api-stub: lurek.globe.get
-- Get an existing globe by name, or nil.
-- Cheap to call; safe inside callbacks.
local value = lurek.globe.get("main")
print("get:", value)
return value

--@api-stub: lurek.globe.loadFromTOML
-- Load provinces from a TOML string and create a globe.
-- May block — call from a worker thread for large payloads.
local result = lurek.globe.loadFromTOML("main", toml_src, spec_tbl)
-- may block; consider lurek.thread for large payloads
print("loadFromTOML:", result)
print("ok")

--@api-stub: lurek.globe.greatCircleDistance
-- Great-circle distance between two lat/lon points (in unit-sphere radians).
-- See the module spec for detailed semantics.
local result = lurek.globe.greatCircleDistance(la, lo, lb, lo2)
print("greatCircleDistance:", result)
return result

--@api-stub: lurek.globe.greatCirclePath
-- Great-circle path as a table of {lat, lon} pairs.
-- See the module spec for detailed semantics.
local result = lurek.globe.greatCirclePath(la, lo, lb, lo2, 10)
print("greatCirclePath:", result)
return result

--@api-stub: lurek.globe.latLonToUnit
-- Convert lat/lon (degrees) to a unit-sphere Cartesian vector {x, y, z}.
-- See the module spec for detailed semantics.
local result = lurek.globe.latLonToUnit(lat, lon)
print("latLonToUnit:", result)
return result

-- ── Globe methods ──

--@api-stub: Globe:addProvince
-- Adds a province from a table {id, centroid={lat,lon}, vertices={{lat,lon},...},.
-- Side-effecting; safe to call any time after init.
local globe = lurek.globe.newGlobe()
globe:addProvince(p)
print("Globe:addProvince done")

--@api-stub: Globe:removeProvince
-- Removes a province by ID.
-- Pair with the matching constructor to free resources.
local globe = lurek.globe.newGlobe()
globe:removeProvince(1)
-- globe is now released
print("ok")

--@api-stub: Globe:provinceCount
-- Returns the number of provinces.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:provinceCount()
print("Globe:provinceCount done")

--@api-stub: Globe:getNeighbors
-- Returns the neighbor IDs of a province.
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getNeighbors(1)
print("Globe:getNeighbors ->", value)

--@api-stub: Globe:getProvinceAttr
-- Gets a string attribute from a province.
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getProvinceAttr(1, "space")
print("Globe:getProvinceAttr ->", value)

--@api-stub: Globe:pan
-- Pan the orbit camera by delta-latitude and delta-longitude (degrees).
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:pan(dlat, dlon)
print("Globe:pan done")

--@api-stub: Globe:zoom
-- Zoom the camera by a multiplier (>1 zooms in, <1 zooms out).
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:zoom(1.0)
print("Globe:zoom done")

--@api-stub: Globe:setCamera
-- Set the camera position directly.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setCamera(lat, lon, 0)
print("Globe:setCamera applied")

--@api-stub: Globe:getCamera
-- Get the current camera (lat, lon, zoom).
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getCamera()
print("Globe:getCamera ->", value)

--@api-stub: Globe:getLod
-- Returns the current LOD tier as a string: "far", "mid", or "near".
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getLod()
print("Globe:getLod ->", value)

--@api-stub: Globe:pick
-- Returns the province ID under screen coordinates, or nil.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:pick(sx, sy)
print("Globe:pick done")

--@api-stub: Globe:pickLatLon
-- Returns (lat, lon) of the screen point on the globe surface, or nil.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:pickLatLon(sx, sy)
print("Globe:pickLatLon done")

--@api-stub: Globe:setActiveViewer
-- Set the faction/viewer whose fog mask filters rendering.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setActiveViewer(viewer)
print("Globe:setActiveViewer applied")

--@api-stub: Globe:revealProvince
-- Reveal a province for a viewer.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:revealProvince(viewer, 1)
print("Globe:revealProvince done")

--@api-stub: Globe:hideProvince
-- Hide a province for a viewer.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:hideProvince(viewer, 1)
print("Globe:hideProvince done")

--@api-stub: Globe:isVisible
-- Returns true if the province is visible to the viewer.
-- Use as a guard inside lurek.update or event handlers.
local globe = lurek.globe.newGlobe()
if globe:isVisible(viewer, 1) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Globe:revealAll
-- Reveal all provinces for a viewer.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:revealAll(viewer)
print("Globe:revealAll done")

--@api-stub: Globe:removeMarker
-- Removes a marker from the globe map by its unique string identifier.
-- Pair with the matching constructor to free resources.
local globe = lurek.globe.newGlobe()
globe:removeMarker(1)
-- globe is now released
print("ok")

--@api-stub: Globe:moveMarker
-- Move a marker to a new lat/lon.
-- See the module spec for detailed semantics.
local globe = lurek.globe.newGlobe()
globe:moveMarker(1, lat, lon)
print("Globe:moveMarker done")

--@api-stub: Globe:setMarkerVisible
-- Sets whether this specific marker is visible on the globe.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setMarkerVisible(1, vis)
print("Globe:setMarkerVisible applied")

--@api-stub: Globe:getMarkerAttr
-- Get a string attribute from a marker.
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getMarkerAttr(1, "space")
print("Globe:getMarkerAttr ->", value)

--@api-stub: Globe:setLabelText
-- Updates the visible text content of an existing globe label.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setLabelText(1, "hello")
print("Globe:setLabelText applied")

--@api-stub: Globe:setLabelVisible
-- Sets whether this specific label is visible on the globe.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setLabelVisible(1, vis)
print("Globe:setLabelVisible applied")

--@api-stub: Globe:removeLabel
-- Removes a text label from the globe map by its unique string identifier.
-- Pair with the matching constructor to free resources.
local globe = lurek.globe.newGlobe()
globe:removeLabel(1)
-- globe is now released
print("ok")

--@api-stub: Globe:removeLayer
-- Removes a texture layer from the globe map by its unique string identifier.
-- Pair with the matching constructor to free resources.
local globe = lurek.globe.newGlobe()
globe:removeLayer("main")
-- globe is now released
print("ok")

--@api-stub: Globe:setLayerVisible
-- Sets whether this specific texture layer is visible on the globe.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setLayerVisible("main", vis)
print("Globe:setLayerVisible applied")

--@api-stub: Globe:setLayerAlpha
-- Set layer opacity (0.0–1.0).
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setLayerAlpha("main", 1)
print("Globe:setLayerAlpha applied")

--@api-stub: Globe:setTimeOfDay
-- Set time of day (0.0–24.0 hours).
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setTimeOfDay(t)
print("Globe:setTimeOfDay applied")

--@api-stub: Globe:getTimeOfDay
-- Gets the current simulated time of day for daylight computation.
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getTimeOfDay()
print("Globe:getTimeOfDay ->", value)

--@api-stub: Globe:setRotation
-- Set planet rotation (degrees).
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setRotation(deg)
print("Globe:setRotation applied")

--@api-stub: Globe:update
-- Advance globe simulation by dt seconds.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:update(dt)
print("Globe:update applied")

--@api-stub: Globe:setBorders
-- Enable or disable province border rendering.
-- Apply at startup or in response to user input.
local globe = lurek.globe.newGlobe()
globe:setBorders(show)
print("Globe:setBorders applied")

--@api-stub: Globe:findPath
-- Find the shortest province path from `from_id` to `to_id`.
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:findPath(1, 1)
print("Globe:findPath ->", value)

--@api-stub: Globe:removeArc
-- Removes an arc from the globe map by its unique string identifier.
-- Pair with the matching constructor to free resources.
local globe = lurek.globe.newGlobe()
globe:removeArc(1)
-- globe is now released
print("ok")

--@api-stub: Globe:getName
-- Returns the string identifier name assigned to this globe instance.
-- Cheap to call; safe inside callbacks.
local globe = lurek.globe.newGlobe()  -- or your existing handle
local value = globe:getName()
print("Globe:getName ->", value)

-- ── GlobeRegistry methods ──

--@api-stub: GlobeRegistry:get
-- Get an existing globe by name, or nil.
-- Cheap to call; safe inside callbacks.
local globeRegistry = lurek.globe.newGlobeRegistry()  -- or your existing handle
local value = globeRegistry:get("main")
print("GlobeRegistry:get ->", value)

--@api-stub: GlobeRegistry:remove
-- Removes a globe from the central registry by its string name.
-- Pair with the matching constructor to free resources.
local globeRegistry = lurek.globe.newGlobeRegistry()
globeRegistry:remove("main")
-- globeRegistry is now released
print("ok")

--@api-stub: GlobeRegistry:names
-- Returns a table of all globe names.
-- See the module spec for detailed semantics.
local globeRegistry = lurek.globe.newGlobeRegistry()
globeRegistry:names()
print("GlobeRegistry:names done")

