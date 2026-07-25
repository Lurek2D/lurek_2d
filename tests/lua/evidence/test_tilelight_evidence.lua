-- Evidence tests: tilelight module.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.tilefield.new
-- @covers lurek.tilelight.new


local OUT = evidence_output_dir("tilelight")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function clamp_byte(value)
    return math.max(0, math.min(255, math.floor(value + 0.5)))
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function paint_lit_cell(img, field, light, x, y, z, cell, offset_x, offset_y)
    local r, g, b, luma = light:getLight(x, y, z)
    local base = field:blocks(x, y, z, "light") and 22 or 42
    local ox = offset_x + (x - 1) * cell
    local oy = offset_y + (y - 1) * cell
    img:drawRect(
        ox,
        oy,
        cell,
        cell,
        clamp_byte(base + (tonumber(r) or 0) * 210),
        clamp_byte(base + (tonumber(g) or 0) * 210),
        clamp_byte(base + (tonumber(b) or 0) * 210),
        255
    )
    if field:blocks(x, y, z, "light") then
        img:drawLine(ox + 3, oy + 3, ox + cell - 4, oy + cell - 4, 255, 76, 76, 255)
        img:drawLine(ox + cell - 4, oy + 3, ox + 3, oy + cell - 4, 255, 76, 76, 255)
    elseif (tonumber(luma) or 0) > 0.55 then
        img:drawCircle(ox + math.floor(cell / 2), oy + math.floor(cell / 2), math.max(2, math.floor(cell / 6)), 255, 245, 160, 255)
    end
    draw_outline(img, ox, oy, cell, cell, 20, 22, 30, 255)
end

local function draw_light_grid(field, light, path, opts)
    opts = opts or {}
    local w, h = field:getSize()
    local cell = opts.cell or 18
    local z = opts.z or 1
    local img = lurek.image.newImageData(w * cell, h * cell)
    img:fill(10, 12, 18, 255)
    for y = 1, h do
        for x = 1, w do
            paint_lit_cell(img, field, light, x, y, z, cell, 0, 0)
        end
    end
    for _, source in ipairs(opts.sources or {}) do
        img:drawCircle(
            math.floor((source.x - 0.5) * cell),
            math.floor((source.y - 0.5) * cell),
            math.max(3, math.floor(cell / 4)),
            source.r,
            source.g,
            source.b,
            255
        )
    end
    draw_outline(img, 0, 0, w * cell, h * cell, 235, 238, 246, 255)
    save_png(img, path)
end

local function draw_staggered_light_grid(field, light, path, sources)
    local w, h = field:getSize()
    local cell = 18
    local img = lurek.image.newImageData(w * cell + math.floor(cell / 2), h * cell)
    img:fill(10, 12, 18, 255)
    for y = 1, h do
        local row_offset = (y % 2 == 0) and math.floor(cell / 2) or 0
        for x = 1, w do
            paint_lit_cell(img, field, light, x, y, 1, cell, row_offset, 0)
        end
    end
    for _, source in ipairs(sources) do
        local row_offset = (source.y % 2 == 0) and math.floor(cell / 2) or 0
        img:drawCircle(
            row_offset + math.floor((source.x - 0.5) * cell),
            math.floor((source.y - 0.5) * cell),
            math.max(3, math.floor(cell / 4)),
            source.r,
            source.g,
            source.b,
            255
        )
    end
    draw_outline(img, 0, 0, w * cell + math.floor(cell / 2), h * cell, 235, 238, 246, 255)
    save_png(img, path)
end

-- @describe evidence: tilelight
describe("evidence: tilelight", function()
    before_each(function()
        ensure_evidence_dir("tilelight")
    end)

    -- Does: Computes a square tilefield light map from point, line, and area sources.
    -- Shows: Light blockers, transmission costs, colored point lights, and mixed source types in a top-down map.
    -- Artifact: tests/artifacts/current/tilelight/tilelight_square_sources_blockers.png
    -- Why: This makes the owned LTileLightMap computation visible without relying on tilefield's combined showcase.
    it("PNG: square sources, blockers, and attenuation", function()
        local field = lurek.tilefield.new({ width = 18, height = 12 })
        for y = 2, 11 do
            if y ~= 6 and y ~= 7 then
                field:setBlock(9, y, 1, "light", true)
            end
        end
        for x = 12, 16 do
            field:setCost(x, 4, 1, "light", 0.35)
            field:setCost(x, 5, 1, "light", 0.35)
        end

        local light = lurek.tilelight.new(field)
        light:setAmbient({ r = 0.03, g = 0.04, b = 0.06 })
        light:addPointLight({ x = 3, y = 3, z = 1, radius = 6, intensity = 1.1, color = { r = 1.0, g = 0.55, b = 0.25 } })
        light:addPointLight({ x = 15, y = 9, z = 1, radius = 5, intensity = 0.9, color = { r = 0.20, g = 0.55, b = 1.0 } })
        light:addLineLight({ x1 = 3, y1 = 10, x2 = 8, y2 = 10, z1 = 1, z2 = 1, radius = 3, intensity = 0.65, color = { r = 0.4, g = 1.0, b = 0.55 } })
        light:addAreaLight({ x = 12, y = 2, z = 1, width = 4, height = 2, radius = 4, intensity = 0.55, color = { r = 0.9, g = 0.35, b = 1.0 } })
        light:compute({ includeSunLight = false })

        draw_light_grid(field, light, OUT .. "tilelight_square_sources_blockers.png", {
            sources = {
                { x = 3, y = 3, r = 255, g = 160, b = 80 },
                { x = 15, y = 9, r = 80, g = 160, b = 255 },
                { x = 5, y = 10, r = 120, g = 255, b = 145 },
                { x = 14, y = 3, r = 230, g = 120, b = 255 },
            },
        })
    end)

    -- Does: Computes tilelight on a hex tilefield topology and renders it with staggered rows.
    -- Shows: The same light API working over a hex field with blocker cells and colored sources.
    -- Artifact: tests/artifacts/current/tilelight/tilelight_hex_sources_blockers.png
    -- Why: Hex lighting was previously only implied by tilefield evidence; this artifact gives tilelight a direct owner proof.
    it("PNG: hex topology light propagation", function()
        local field = lurek.tilefield.new({ width = 13, height = 10, topology = "hex" })
        for y = 2, 9 do
            if y ~= 5 then
                field:setBlock(7, y, 1, "light", true)
            end
        end
        for x = 2, 12 do
            if x % 3 == 0 then
                field:setCost(x, 7, 1, "light", 0.45)
            end
        end

        local light = lurek.tilelight.new(field)
        light:setAmbient({ r = 0.02, g = 0.03, b = 0.04 })
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 5, intensity = 1.0, color = { r = 1.0, g = 0.45, b = 0.18 } })
        light:addPointLight({ x = 12, y = 8, z = 1, radius = 5, intensity = 0.95, color = { r = 0.18, g = 0.6, b = 1.0 } })
        light:addAreaLight({ x = 4, y = 7, z = 1, width = 2, height = 2, radius = 3, intensity = 0.55, color = { r = 0.35, g = 1.0, b = 0.4 } })
        light:compute({ includeSunLight = false })

        draw_staggered_light_grid(field, light, OUT .. "tilelight_hex_sources_blockers.png", {
            { x = 2, y = 2, r = 255, g = 145, b = 70 },
            { x = 12, y = 8, r = 80, g = 170, b = 255 },
            { x = 5, y = 8, r = 110, g = 255, b = 125 },
        })
    end)

    -- Does: Computes a three-level light volume with top-down global light and per-level occlusion.
    -- Shows: Level 1-3 panels darken where upper layers occlude sunlight while local point light remains visible.
    -- Artifact: tests/artifacts/current/tilelight/tilelight_multilevel_volume.png
    -- Why: Multilevel tilelight is a separate map combination that should not depend on tilemap's iso XCOM artifact.
    it("PNG: multilevel global light volume", function()
        local field = lurek.tilefield.new({ width = 10, height = 8, levels = 3 })
        for y = 2, 7 do
            field:setSunOcclusion(5, y, 3, 0.85)
            field:setSunOcclusion(6, y, 2, 0.55)
            if y ~= 4 then
                field:setBlock(5, y, 1, "light", true)
            end
        end

        local light = lurek.tilelight.new(field)
        light:setAmbient({ r = 0.02, g = 0.02, b = 0.03 })
        light:setGlobalLight({ intensity = 0.75, color = { r = 1.0, g = 0.88, b = 0.55 } })
        light:addPointLight({ x = 3, y = 6, z = 1, radius = 4, intensity = 0.85, color = { r = 0.25, g = 0.65, b = 1.0 } })
        light:addPointLight({ x = 8, y = 3, z = 2, radius = 3, intensity = 0.75, color = { r = 1.0, g = 0.35, b = 0.45 } })
        light:compute({ includeGlobalLight = true, includeSunLight = false })

        local cell = 14
        local gap = 10
        local w, h = field:getSize()
        local img = lurek.image.newImageData(w * cell * 3 + gap * 2, h * cell)
        img:fill(10, 12, 18, 255)
        for z = 1, 3 do
            local offset = (z - 1) * (w * cell + gap)
            for y = 1, h do
                for x = 1, w do
                    paint_lit_cell(img, field, light, x, y, z, cell, offset, 0)
                end
            end
            draw_outline(img, offset, 0, w * cell, h * cell, 235, 238, 246, 255)
        end
        save_png(img, OUT .. "tilelight_multilevel_volume.png")

        local l1 = ({ light:getLight(3, 6, 1) })[4]
        local l2 = ({ light:getLight(8, 3, 2) })[4]
        local shadow = ({ light:getLight(5, 5, 1) })[4]
        save_text(
            OUT .. "tilelight_multilevel_samples.txt",
            string.format("level1_blue_luma=%.4f\nlevel2_red_luma=%.4f\nshadow_column_luma=%.4f\n", l1, l2, shadow)
        )
    end)
end)

test_summary()
