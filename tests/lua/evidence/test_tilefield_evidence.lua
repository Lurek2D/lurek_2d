-- Evidence tests: tilefield module.

local OUT = evidence_output_dir("tilefield")

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

local function fmt(value)
    return string.format("%.4f", value)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function paint_cell(img, x, y, cell, r, g, b)
    local ox = (x - 1) * cell
    local oy = (y - 1) * cell
    img:drawRect(ox, oy, cell, cell, r, g, b, 255)
    draw_outline(img, ox, oy, cell, cell, 24, 27, 32, 255)
end

local function draw_dot(img, x, y, cell, r, g, b)
    img:drawCircle(math.floor((x - 0.5) * cell), math.floor((y - 0.5) * cell), math.max(2, math.floor(cell / 4)), r, g, b, 255)
end

-- @describe evidence: tilefield
describe("evidence: tilefield", function()
    before_each(function()
        ensure_evidence_dir("tilefield")
    end)

    -- Does: Draws wall, window, door, and half-wall profiles over the four gameplay channels.
    -- Shows: Move, vision, action, and light blockers differ per profile instead of sharing one solid flag.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_channels.png
    -- Why: This makes the new tilefield channel contract inspectable without relying on pathfind, visibility, or raycaster.
    it("PNG: profile channels stay independent", function()
        local cell = 22
        local profiles = { "wall", "window", "door_open", "door_closed", "half_wall" }
        local channels = { "move", "vision", "action", "light" }
        local field = lurek.tilefield.new({ width = #profiles, height = #channels })
        for x, profile in ipairs(profiles) do
            for y = 1, #channels do
                field:applyProfile(x, y, 1, profile)
            end
        end

        local img = lurek.image.newImageData(#profiles * cell, #channels * cell)
        img:fill(12, 14, 18, 255)
        for y, channel in ipairs(channels) do
            for x = 1, #profiles do
                if field:blocks(x, y, 1, channel) then
                    paint_cell(img, x, y, cell, 156, 56, 70)
                else
                    paint_cell(img, x, y, cell, 54, 120, 94)
                end
            end
        end
        save_png(img, OUT .. "tilefield_channels.png")
    end)

    -- Does: Computes separate visible and action masks for two players on one shared field.
    -- Shows: Player masks are independent and action range is not identical to visibility.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_visibility_action_players.png
    -- Why: This demonstrates tilefield as source data while visibility owns per-player state.
    it("PNG: per-player visibility and action masks differ", function()
        local cell = 18
        local field = lurek.tilefield.new({ width = 12, height = 8 })
        for y = 2, 7 do field:applyProfile(6, y, 1, "wall") end
        field:applyProfile(6, 4, 1, "window")
        field:applyProfile(8, 5, 1, "half_wall")
        local vis = lurek.awareness.newTileAwareness(field, { players = { "blue", "red" } })
        vis:computeVisible("blue", { origin = { x = 3, y = 4, z = 1 }, range = 5, channel = "vision" })
        vis:computeAction("blue", { origin = { x = 3, y = 4, z = 1 }, range = 5, channel = "action" })
        vis:computeVisible("red", { origin = { x = 10, y = 4, z = 1 }, range = 4, channel = "vision" })
        vis:computeAction("red", { origin = { x = 10, y = 4, z = 1 }, range = 4, channel = "action" })

        local img = lurek.image.newImageData(12 * cell, 8 * cell)
        img:fill(10, 11, 15, 255)
        for y = 1, 8 do
            for x = 1, 12 do
                local r, g, b = 34, 38, 46
                if vis:isVisible("blue", x, y, 1) then r, g, b = 38, 78, 138 end
                if vis:isVisible("red", x, y, 1) then r, g, b = 110, 48, 56 end
                if vis:canActOn("blue", x, y, 1) or vis:canActOn("red", x, y, 1) then
                    g = math.min(220, g + 70)
                end
                if field:blocks(x, y, 1, "move") then r, g, b = 64, 62, 70 end
                paint_cell(img, x, y, cell, r, g, b)
            end
        end
        draw_dot(img, 3, 4, cell, 90, 180, 255)
        draw_dot(img, 10, 4, cell, 255, 105, 105)
        save_png(img, OUT .. "tilefield_visibility_action_players.png")
    end)

    -- Does: Computes point lights plus top light across three levels with opaque and partial occluders.
    -- Shows: Several colored light sources mix additively while wall, glass, and shade cells attenuate differently.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_lighting_multilevel.png
    -- Why: This proves tilelight consumes tilefield data without becoming raycaster-owned rendering state.
    it("PNG: multilevel point and global lighting", function()
        local cell = 16
        local field = lurek.tilefield.new({ width = 12, height = 8, levels = 3 })
        field:setProfile("smoked_glass", {
            blocks = { move = true, vision = false, action = true, light = false },
            costs = { light = 0.35 },
            sunOcclusion = 0.35,
        })
        field:setProfile("shade_screen", {
            blocks = { move = false, vision = false, action = false, light = false },
            costs = { light = 0.65 },
            sunOcclusion = 0.65,
        })
        for y = 1, 8 do field:applyProfile(6, y, 1, "wall") end
        for y = 2, 7, 2 do field:applyProfile(8, y, 1, "smoked_glass") end
        for x = 3, 10 do field:applyProfile(x, 5, 2, "shade_screen") end
        field:applyProfile(4, 3, 3, "half_wall")
        field:applyProfile(4, 4, 3, "wall")
        local light = lurek.tilelight.new(field)
        light:addPointLight({ x = 2, y = 4, z = 1, radius = 8, intensity = 1.0, color = { r = 1.0, g = 0.48, b = 0.18 } })
        light:addPointLight({ x = 11, y = 4, z = 1, radius = 7, intensity = 0.85, color = { r = 0.15, g = 0.35, b = 1.0 } })
        light:addPointLight({ x = 5, y = 2, z = 2, radius = 5, intensity = 0.65, color = { r = 0.25, g = 1.0, b = 0.35 } })
        light:addPointLight({ x = 10, y = 7, z = 3, radius = 5, intensity = 0.55, color = { r = 0.9, g = 0.2, b = 0.85 } })
        light:setGlobalLight({ intensity = 0.32, color = { r = 1.0, g = 0.58, b = 0.24 } })
        light:compute({ includePointLights = true, includeGlobalLight = true })

        local img = lurek.image.newImageData(12 * cell * 3, 8 * cell)
        img:fill(8, 9, 13, 255)
        for z = 1, 3 do
            local layer = light:exportLayer(z)
            for y = 1, 8 do
                for x = 1, 12 do
                    local light = layer[(y - 1) * 12 + x]
                    local ox = (z - 1) * 12
                    local r = math.floor((light.r or 0) * 255)
                    local g = math.floor((light.g or 0) * 255)
                    local b = math.floor((light.b or 0) * 255)
                    if field:blocks(x, y, z, "light") then
                        r, g, b = math.floor(r * 0.35), math.floor(g * 0.35), math.floor(b * 0.35)
                    end
                    paint_cell(img, ox + x, y, cell, r, g, b)
                end
            end
        end
        save_png(img, OUT .. "tilefield_lighting_multilevel.png")
    end)

    -- Does: Writes measured and expected RGB/luma values for point lights, filters, blockers, and global colors.
    -- Shows: Opaque walls produce zero behind them, partial blockers multiply transmission, colored lights mix by channel, and dusk/night global light keep different colors.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_lighting_values.txt
    -- Why: The visual PNG proves shape; this text artifact proves exact tile-light math that a reviewer can audit.
    it("TXT: tile lighting numeric calculations", function()
        local lines = {
            "case,channel,expected,measured",
        }

        local blocked = lurek.tilefield.new({ width = 5, height = 3 })
        blocked:setBlock(3, 2, 1, "light", true)
        local blocked_light = lurek.tilelight.new(blocked)
        blocked_light:addPointLight({ x = 1, y = 2, z = 1, radius = 5, intensity = 1.0, color = { r = 1, g = 1, b = 1 } })
        blocked_light:compute({ includePointLights = true, includeGlobalLight = false })
        local _, _, _, blocked_luma = blocked_light:getLight(5, 2, 1)
        lines[#lines + 1] = "opaque_wall,luma,0.0000," .. fmt(blocked_luma)
        expect_near(0.0, blocked_luma, 0.001)

        local partial = lurek.tilefield.new({ width = 7, height = 3 })
        partial:setCost(4, 2, 1, "light", 0.5)
        local partial_light = lurek.tilelight.new(partial)
        partial_light:addPointLight({ x = 1, y = 2, z = 1, radius = 8, intensity = 1.0, color = { r = 1, g = 0.25, b = 0 } })
        partial_light:compute({ includePointLights = true, includeGlobalLight = false })
        local pr, pg, pb, pl = partial_light:getLight(6, 2, 1)
        lines[#lines + 1] = "partial_filter,r,0.1875," .. fmt(pr)
        lines[#lines + 1] = "partial_filter,g,0.0469," .. fmt(pg)
        lines[#lines + 1] = "partial_filter,b,0.0000," .. fmt(pb)
        lines[#lines + 1] = "partial_filter,luma,0.0734," .. fmt(pl)
        expect_near(0.1875, pr, 0.001)
        expect_near(0.046875, pg, 0.001)
        expect_near(0.0, pb, 0.001)

        local radial = lurek.tilefield.new({ width = 4, height = 4, topology = "square" })
        local radial_light = lurek.tilelight.new(radial)
        radial_light:addPointLight({ x = 1, y = 1, z = 1, radius = 2, intensity = 1.0, color = { r = 1, g = 1, b = 1 } })
        radial_light:compute({ includePointLights = true, includeGlobalLight = false })
        local _, _, _, diagonal = radial_light:getLight(3, 3, 1)
        lines[#lines + 1] = "radial_square_diagonal_outside,luma,0.0000," .. fmt(diagonal)
        expect_near(0.0, diagonal, 0.001)

        local mixed = lurek.tilefield.new({ width = 5, height = 3 })
        local mixed_light = lurek.tilelight.new(mixed)
        mixed_light:addPointLight({ x = 1, y = 2, z = 1, radius = 4, intensity = 1.0, color = { r = 1, g = 0, b = 0 } })
        mixed_light:addPointLight({ x = 5, y = 2, z = 1, radius = 4, intensity = 1.0, color = { r = 0, g = 0, b = 1 } })
        mixed_light:compute({ includePointLights = true, includeGlobalLight = false })
        local mr, mg, mb, ml = mixed_light:getLight(3, 2, 1)
        lines[#lines + 1] = "red_blue_mix,r,0.5000," .. fmt(mr)
        lines[#lines + 1] = "red_blue_mix,g,0.0000," .. fmt(mg)
        lines[#lines + 1] = "red_blue_mix,b,0.5000," .. fmt(mb)
        lines[#lines + 1] = "red_blue_mix,luma,0.1424," .. fmt(ml)
        expect_near(0.5, mr, 0.001)
        expect_near(0.0, mg, 0.001)
        expect_near(0.5, mb, 0.001)

        local sky = lurek.tilefield.new({ width = 1, height = 1, levels = 2 })
        sky:setSunOcclusion(1, 1, 2, 0.25)
        local sky_light = lurek.tilelight.new(sky)
        sky_light:setGlobalLight({ intensity = 0.4, color = { r = 1.0, g = 0.55, b = 0.25 } })
        sky_light:compute({ includePointLights = false, includeGlobalLight = true })
        local dr, dg, db, dl = sky_light:getLight(1, 1, 1)
        lines[#lines + 1] = "dusk_lower,r,0.3000," .. fmt(dr)
        lines[#lines + 1] = "dusk_lower,g,0.1650," .. fmt(dg)
        lines[#lines + 1] = "dusk_lower,b,0.0750," .. fmt(db)
        lines[#lines + 1] = "dusk_lower,luma,0.1871," .. fmt(dl)
        expect_near(0.3, dr, 0.001)
        expect_near(0.165, dg, 0.001)
        expect_near(0.075, db, 0.001)

        sky_light:setGlobalLight({ intensity = 0.12, color = { r = 0.22, g = 0.32, b = 1.0 } })
        sky_light:compute({ includePointLights = false, includeGlobalLight = true })
        local nr, ng, nb, nl = sky_light:getLight(1, 1, 1)
        lines[#lines + 1] = "night_lower,r,0.0198," .. fmt(nr)
        lines[#lines + 1] = "night_lower,g,0.0288," .. fmt(ng)
        lines[#lines + 1] = "night_lower,b,0.0900," .. fmt(nb)
        lines[#lines + 1] = "night_lower,luma,0.0313," .. fmt(nl)
        expect_near(0.0198, nr, 0.001)
        expect_near(0.0288, ng, 0.001)
        expect_near(0.09, nb, 0.001)
        expect_true(dl > nl, "dusk should be brighter than night")
        expect_true(nb > nr, "night should be blue-dominant")

        save_text(OUT .. "tilefield_lighting_values.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Exports a vision block layer and builds a raycaster scene from the same field.
    -- Shows: Raycaster input is derived from tilefield data instead of independent raycaster gameplay flags.
    -- Artifact: tests/artifacts/current/tilefield/tilefield_raycaster_input.png
    -- Why: This is the migration bridge: tilefield owns the blockers, raycaster consumes the exported semantics.
    it("PNG: raycaster input layer from tilefield", function()
        local cell = 20
        local field = lurek.tilefield.new({ width = 8, height = 8, levels = 2 })
        for x = 1, 8 do
            field:applyProfile(x, 1, 1, "wall")
            field:applyProfile(x, 8, 1, "wall")
        end
        for y = 1, 8 do
            field:applyProfile(1, y, 1, "wall")
            field:applyProfile(8, y, 1, "wall")
        end
        field:applyProfile(4, 4, 1, "window")
        field:applyProfile(5, 4, 1, "door_closed")
        local quads = lurek.raycaster.buildMultiLevelSceneFromField({
            px = 3.5, py = 3.5, angle = 0, fov = 1.0, rays = 40, max_dist = 8,
            screen_w = 120, screen_h = 80, active_level = 0,
        }, field, { wallChannel = "vision" })

        local img = lurek.image.newImageData(8 * cell, 8 * cell)
        img:fill(11, 13, 17, 255)
        for y = 1, 8 do
            for x = 1, 8 do
                if field:blocks(x, y, 1, "vision") then
                    paint_cell(img, x, y, cell, 98, 88, 104)
                elseif field:blocks(x, y, 1, "action") then
                    paint_cell(img, x, y, cell, 84, 112, 136)
                else
                    paint_cell(img, x, y, cell, 34, 42, 52)
                end
            end
        end
        local marker = math.max(3, math.min(14, quads))
        img:drawRect(3, 3, marker, 6, 255, 210, 90, 255)
        save_png(img, OUT .. "tilefield_raycaster_input.png")
    end)
end)

test_summary()
