-- content/examples/svg_provinces/main.lua
-- Run: cargo run -- content/examples/svg_provinces

local R = lurek.render

local svg = nil
local provinces = { "prov_A", "prov_B", "prov_C", "prov_D" }
local province_points = {}
local adjacencies = {}
local hovered_prov = nil
local selected_prov = nil
local ui_font = nil

-- Point-in-polygon hit-testing helper
local function pointInPolygon(px, py, poly)
    if not poly then return false end
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local pi = poly[i]
        local pj = poly[j]
        if ((pi.y > py) ~= (pj.y > py)) and
           (px < (pj.x - pi.x) * (py - pi.y) / (pj.y - pi.y) + pi.x) then
            inside = not inside
        end
        j = i
    end
    return inside
end

function lurek.init()
    -- Load the SVG map relative to game dir
    svg = lurek.svg.load("map.svg")
    print("SVG loaded: " .. svg:getWidth() .. "x" .. svg:getHeight())

    -- Tesselate paths into flat point lists for hit-testing
    for _, id in ipairs(provinces) do
        province_points[id] = svg:getElementPoints(id, 5.0)
        print("Tesselated " .. id .. ": " .. #province_points[id] .. " points")
    end

    -- Precompute adjacency map with epsilon = 5.0
    adjacencies = svg:getAdjacencies("prov_", 5.0)
    for id, neighbors in pairs(adjacencies) do
        local n_str = {}
        for _, n in ipairs(neighbors) do table.insert(n_str, n) end
        print(id .. " neighbors: " .. table.concat(n_str, ", "))
    end

    -- Load a font for the UI HUD
    ui_font = R.newFont(14)
end

function lurek.update(dt)
    -- Determine which province is hovered using mouse screen position
    local mx, my = lurek.input.mouse.getPosition()
    hovered_prov = nil

    for _, id in ipairs(provinces) do
        if pointInPolygon(mx, my, province_points[id]) then
            hovered_prov = id
            break
        end
    end

    -- Update province colors dynamically
    for _, id in ipairs(provinces) do
        if id == selected_prov then
            -- Selected: Bright Orange
            svg:setElementColor(id, 1.0, 0.5, 0.0, 1.0)
        elseif id == hovered_prov then
            -- Hovered: Light Blue
            svg:setElementColor(id, 0.4, 0.7, 1.0, 1.0)
        elseif selected_prov and adjacencies[selected_prov] and (function()
            for _, n in ipairs(adjacencies[selected_prov]) do
                if n == id then return true end
            end
            return false
        end)() then
            -- Neighbor of Selected: Magenta/Pink
            svg:setElementColor(id, 0.9, 0.3, 0.9, 1.0)
        else
            -- Default colors from original SVG style
            if id == "prov_A" then svg:setElementColor(id, 0.23, 0.53, 0.78, 1.0) end
            if id == "prov_B" then svg:setElementColor(id, 0.23, 0.78, 0.53, 1.0) end
            if id == "prov_C" then svg:setElementColor(id, 0.78, 0.23, 0.53, 1.0) end
            if id == "prov_D" then svg:setElementColor(id, 0.78, 0.78, 0.23, 1.0) end
        end
    end
end

function lurek.draw()
    -- Draw the SVG map (which renders our dynamic colors)
    R.clear(0.12, 0.12, 0.15)
    svg:draw(0, 0)

    -- Draw UI HUD
    if ui_font then
        R.setFont(ui_font)
    end

    local fps = lurek.timer.getFPS()
    R.setColor(0, 0, 0, 0.75)
    R.rectangle("fill", 10, 10, 480, 140)
    R.setColor(1, 1, 1, 1)

    R.print("SVG Province Map Demo", 20, 20)
    R.print("FPS: " .. fps, 20, 45)
    R.print("Hovered Province: " .. (hovered_prov or "None"), 20, 70)
    R.print("Selected Province (click to select): " .. (selected_prov or "None"), 20, 95)

    if selected_prov and adjacencies[selected_prov] then
        local neighbors = table.concat(adjacencies[selected_prov], ", ")
        R.print("Neighbors (highlighted in pink): " .. neighbors, 20, 120)
    end
end

function lurek.mousepressed(x, y, button)
    if button == 1 then
        selected_prov = hovered_prov
    end
end

function lurek.keypressed(key)
    if key == "escape" then
        lurek.event.quit()
    end
end
