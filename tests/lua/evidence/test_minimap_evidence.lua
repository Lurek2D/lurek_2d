-- test_minimap_evidence.lua
-- Evidence tests: lurek.minimap API + PNG visualization
-- Canonical evidence file for lurek.minimap visual outputs.

local OUT = evidence_output_dir("minimap")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function fill_terrain(mm, width, height, fn)
    local data = {}
    for y = 1, height do
        for x = 1, width do
            data[(y - 1) * width + x] = fn(x, y)
        end
    end
    mm:setTerrainData(data)
    return data
end

local function base_minimap(width, height, cell)
    local mm = lurek.minimap.newMinimap(width, height, width * cell, height * cell)
    mm:setTerrainColor(0, 0.07, 0.11, 0.10, 1.0)
    mm:setTerrainColor(1, 0.13, 0.22, 0.15, 1.0)
    mm:setTerrainColor(2, 0.12, 0.22, 0.42, 1.0)
    mm:setTerrainColor(3, 0.34, 0.29, 0.20, 1.0)
    mm:setTerrainColor(4, 0.34, 0.36, 0.38, 1.0)
    return mm
end

-- @describe Evidence: lurek.minimap render output
describe("Evidence: lurek.minimap render output", function()
    -- Does: Renders a multi-terrain map using only terrain ids and terrain palette colors.
    -- Shows: The PNG should make terrain palette resolution and full-grid cell rasterization legible.
    -- Artifact: tests/artifacts/current/minimap/minimap_terrain_palette_grid.png
    -- Why: This proves the base minimap image export path before fog, overlays, or adapters are involved.

    it("PNG: terrain palette grid", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_terrain_palette_grid.png"

        local W, H, CELL = 18, 12, 8
        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            if x == 8 or x == 9 then return 2 end
            if y <= 3 then return 4 end
            if y >= 9 and x <= 6 then return 1 end
            if y == 7 or x == 14 then return 3 end
            return 0
        end)

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Renders hidden, explored, and visible fog states over the same terrain.
    -- Shows: The PNG should show dark hidden cells, dim explored cells, and fully visible center cells.
    -- Artifact: tests/artifacts/current/minimap/minimap_fog_states.png
    -- Why: This proves minimap-owned fog composition over existing terrain colors.

    it("PNG: fog states", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_fog_states.png"

        local W, H, CELL = 18, 12, 8
        local mm = base_minimap(W, H, CELL)
        mm:setFogEnabled(true)
        mm:setFogColor(0.0, 0.0, 0.0, 0.8)
        fill_terrain(mm, W, H, function(x, y)
            return ((x + y) % 5 == 0) and 2 or 1
        end)

        local fog = {}
        for y = 1, H do
            for x = 1, W do
                local dx = x - 9.5
                local dy = y - 6.5
                local dist = math.sqrt(dx * dx + dy * dy)
                local level = 0
                if dist <= 3.4 then
                    level = 2
                elseif dist <= 5.5 then
                    level = 1
                end
                fog[(y - 1) * W + x] = level
            end
        end
        mm:setFogData(fog)

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Renders four raw data layers with different minimap blend modes over matching terrain bands.
    -- Shows: The PNG should show normal, multiply, add, and replace composition as distinct vertical regions.
    -- Artifact: tests/artifacts/current/minimap/minimap_layer_blend_modes.png
    -- Why: This proves minimap owns raw layer presentation policy instead of pushing color math into producers.

    it("PNG: layer blend modes", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_layer_blend_modes.png"

        local W, H, CELL = 16, 8, 10
        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            return ((x + y) % 2 == 0) and 1 or 3
        end)

        local modes = {
            { layer = 1, first = 1, last = 4, mode = "normal", color = { 1.0, 0.2, 0.1, 0.75 } },
            { layer = 2, first = 5, last = 8, mode = "multiply", color = { 0.4, 0.9, 0.4, 0.8 } },
            { layer = 3, first = 9, last = 12, mode = "add", color = { 0.1, 0.45, 1.0, 0.72 } },
            { layer = 4, first = 13, last = 16, mode = "replace", color = { 0.95, 0.8, 0.12, 1.0 } },
        }

        for _, spec in ipairs(modes) do
            local layer = {}
            for y = 1, H do
                for x = 1, W do
                    layer[(y - 1) * W + x] = (x >= spec.first and x <= spec.last) and 7 or 0
                end
            end
            mm:setLayerData(spec.layer, layer)
            mm:setLayerColor(spec.layer, 7, spec.color[1], spec.color[2], spec.color[3], spec.color[4])
            mm:setLayerBlendMode(spec.layer, spec.mode)
            mm:setLayerAlpha(spec.layer, 1.0)
            mm:setLayerVisible(spec.layer, true)
        end

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Renders one visible layer while a stronger hidden layer is present but disabled.
    -- Shows: The PNG should show only the visible cyan diagonal layer, not the hidden red full-map layer.
    -- Artifact: tests/artifacts/current/minimap/minimap_layer_visibility_toggle.png
    -- Why: This proves runtime layer visibility can modify minimap presentation without changing producer data.

    it("PNG: layer visibility toggle", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_layer_visibility_toggle.png"

        local W, H, CELL = 14, 10, 9
        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            return ((x + y) % 4 == 0) and 4 or 0
        end)

        local hidden = {}
        local visible = {}
        for y = 1, H do
            for x = 1, W do
                hidden[(y - 1) * W + x] = 9
                visible[(y - 1) * W + x] = (math.abs(x - y) <= 1 or math.abs((W - x + 1) - y) <= 1) and 5 or 0
            end
        end
        mm:setLayerData(1, hidden)
        mm:setLayerColor(1, 9, 1.0, 0.0, 0.0, 1.0)
        mm:setLayerBlendMode(1, "replace")
        mm:setLayerVisible(1, false)

        mm:setLayerData(2, visible)
        mm:setLayerColor(2, 5, 0.1, 0.75, 1.0, 0.85)
        mm:setLayerBlendMode(2, "add")
        mm:setLayerVisible(2, true)

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Renders object types, persistent markers, and active pings over terrain.
    -- Shows: The PNG should show colored unit blips, crosshair-style markers, and ping circles from minimap state.
    -- Artifact: tests/artifacts/current/minimap/minimap_markers_objects_pings.png
    -- Why: This proves compact tactical symbols are exported by minimap rather than added by a separate image script.

    it("PNG: markers objects pings", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_markers_objects_pings.png"

        local W, H, CELL = 16, 12, 9
        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            if x == 6 or y == 8 then return 2 end
            return 1
        end)

        local player = mm:addObjectType("Player", 0.1, 1.0, 0.25, 1.0)
        local enemy = mm:addObjectType("Enemy", 1.0, 0.1, 0.08, 1.0)
        local support = mm:addObjectType("Support", 0.1, 0.6, 1.0, 1.0)
        mm:setObject(1, 3.0, 4.0, player, 1)
        mm:setObject(2, 12.0, 5.0, enemy, 2)
        mm:setObject(3, 8.5, 9.0, support, 1)
        mm:addMarker(4.5, 10.0, "Quest", 1.0, 0.9, 0.1, 1.0)
        mm:addMarker(13.0, 2.5, "Exit", 0.9, 0.8, 1.0, 1.0)
        mm:addPing(7.0, 7.0, 2.0, 1.0, 0.85, 0.1, 1.0)
        mm:addPing(12.0, 5.0, 1.6, 1.0, 0.2, 0.1, 1.0)
        mm:update(0.35)

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Renders a polyline path together with line and rectangle overlay shapes.
    -- Shows: The PNG should show route lines and overlay geometry produced by minimap-owned overlay state.
    -- Artifact: tests/artifacts/current/minimap/minimap_paths_and_overlay_shapes.png
    -- Why: This proves `drawToImage` exports the same route/overlay concepts used by the runtime minimap renderer.

    it("PNG: paths and overlay shapes", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_paths_and_overlay_shapes.png"

        local W, H, CELL = 18, 12, 8
        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            return (x == 9 or y == 6) and 3 or 0
        end)

        mm:showPath({
            { 1.5, 10.5 },
            { 4.5, 8.0 },
            { 8.0, 7.0 },
            { 13.0, 4.0 },
            { 16.5, 2.0 },
        }, { 255, 128, 64, 255 })
        mm:drawLine(2.0, 2.0, 16.0, 10.0, { 70, 220, 255, 255 })
        mm:drawRect(5.0, 3.0, 6.0, 4.0, { 255, 235, 80, 255 })

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Renders a visible camera viewport rectangle over the minimap grid.
    -- Shows: The PNG should show the viewport outline using `setViewportRect` and `setViewportColor`.
    -- Artifact: tests/artifacts/current/minimap/minimap_viewport_rect.png
    -- Why: This proves viewport export is part of minimap rendering instead of a manual evidence overlay.

    it("PNG: viewport rect", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_viewport_rect.png"

        local W, H, CELL = 20, 12, 8
        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            return (x % 5 == 0 or y % 4 == 0) and 4 or 1
        end)
        mm:setViewportRect(4.0, 2.0, 10.0, 6.0)
        mm:setViewportVisible(true)
        mm:setViewportColor(1.0, 0.88, 0.12, 1.0)

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Uses `library.tilefield_minimap` to copy blocker, movement-cost, and tilelight exports into raw minimap layers.
    -- Shows: The PNG should show tilefield gameplay data rendered by minimap layer styling.
    -- Artifact: tests/artifacts/current/minimap/minimap_tilefield_layers.png
    -- Why: This proves tilefield remains the data owner while minimap owns compact layer rendering.

    it("PNG: tilefield layers", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_tilefield_layers.png"
        local TilefieldMinimap = require("library.tilefield_minimap")

        local W, H, CELL = 12, 9, 9
        local field = lurek.tilefield.new({ width = W, height = H, levels = 1 })
        for x = 4, 8 do
            field:setBlock(x, 4, 1, "move", true)
        end
        field:setBlock(6, 4, 1, "move", false)
        field:setCost(8, 6, 1, "move", 4)
        field:setCost(9, 6, 1, "move", 5)
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 3, y = 7, z = 1, radius = 4, intensity = 1.0, color = { r = 1, g = 0.8, b = 0.2 } })
        light:compute({ includePointLights = true, includeGlobalLight = false })

        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function() return 1 end)
        local helper = TilefieldMinimap.new({ field = field, lightMap = light, width = W, height = H, minimap = mm })
        helper:syncBlockLayer("move", 1, {
            blocked_value = 9,
            style = {
                visible = true,
                alpha = 1.0,
                blend = "replace",
                colors = { [9] = { 0.92, 0.12, 0.08, 1.0 } },
            },
        })
        helper:syncCostLayer("move", 2, {
            scale = 2,
            style = {
                visible = true,
                alpha = 0.5,
                blend = "add",
                colors = {
                    [8] = { 0.1, 0.35, 1.0, 0.8 },
                    [10] = { 0.15, 0.65, 1.0, 0.9 },
                },
            },
        })
        helper:syncLightLayer(3, {
            scale = 9,
            style = { visible = true, alpha = 0.75, blend = "add" },
        })

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Uses `library.awareness_minimap` to copy LTileAwareness visible/action masks into fog and raw minimap layers.
    -- Shows: The PNG should show fog-of-war plus an actionable overlay produced from visibility data.
    -- Artifact: tests/artifacts/current/minimap/minimap_visibility_fog_action.png
    -- Why: This proves visibility remains the mask authority while minimap owns fog and layer presentation.

    it("PNG: visibility fog action", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_visibility_fog_action.png"
        local AwarenessMinimap = require("library.awareness_minimap")

        local W, H, CELL = 14, 10, 9
        local field = lurek.tilefield.new({ width = W, height = H, levels = 1 })
        for y = 2, 9 do
            field:setBlock(8, y, 1, "vision", true)
        end
        field:setBlock(8, 5, 1, "vision", false)
        field:setBlock(9, 6, 1, "action", true)

        local awareness = lurek.awareness.newTileAwareness(field, { players = { "scout" }, rememberExplored = true })
        awareness:computeVisible("scout", {
            origin = { x = 4, y = 5, z = 1 },
            range = 6,
            channel = "vision",
        })
        awareness:computeAction("scout", {
            origin = { x = 4, y = 5, z = 1 },
            range = 4,
            channel = "action",
        })

        local mm = base_minimap(W, H, CELL)
        fill_terrain(mm, W, H, function(x, y)
            return (x == 8 or y == 5) and 3 or 1
        end)
        mm:setFogColor(0.0, 0.0, 0.0, 0.78)
        local helper = AwarenessMinimap.new({ visibility = awareness, width = W, height = H, minimap = mm })
        helper:syncFog("scout")
        helper:syncActionLayer("scout", 1, {
            action_value = 8,
            style = {
                visible = true,
                alpha = 0.65,
                blend = "add",
                colors = { [8] = { 0.12, 0.65, 1.0, 0.85 } },
            },
        })

        save_png(mm:drawToImage(CELL), path)
    end)

    -- Does: Copies province terrain, political palette, and visibility state into LMinimap through `syncProvinceRegistry`.
    -- Shows: The PNG should show a province registry rendered as a compact minimap.
    -- Artifact: tests/artifacts/current/minimap/minimap_province_registry_compact.png
    -- Why: This proves province remains the region data owner while minimap owns compact full-map rendering.

    it("PNG: province registry compact", function()
        ensure_evidence_dir("minimap")
        local path = OUT .. "minimap_province_registry_compact.png"

        local reg = lurek.province.newFromPng("minimap_province_compact_evidence", "content/examples/assets/textures/province_map.png")
        local ids = reg:provinceIds()
        for i = 1, math.min(#ids, 6) do
            local id = ids[i]
            reg:setTerrainType(id, i)
            reg:setAwarenessState(id, i <= 2 and 96 or 255)
            reg:setPoliticalColor(id, 0.10 + 0.12 * i, 0.25 + 0.08 * i, 0.82 - 0.06 * i, 1.0)
        end

        local mm = lurek.minimap.newMinimap(reg:getWidth(), reg:getHeight(), 320, 144)
        mm:syncProvinceRegistry(reg)
        save_png(mm:drawToImage(0), path)
    end)
end)
test_summary()
