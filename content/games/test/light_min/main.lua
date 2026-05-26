-- light_min: minimal demo — one point light + one occluder wall
-- WASD = move light, ESC = quit

local lx, ly = 400, 300
local light

function lurek.init()
    lurek.window.setTitle("Light Min")
    lurek.render.setBackgroundColor(0.45, 0.42, 0.38)

    lurek.light.setEnabled(true)
    lurek.light.setAmbient(0.06, 0.06, 0.08, 1.0)

    light = lurek.light.newLight(lx, ly, 320)
    light:setIntensity(1.6)
    light:setColor(1.0, 0.85, 0.5)
    light:setBlendMode("add")
    light:setFalloff("smooth")
    light:setShadowEnabled(true)
    light:setAttenuation(1.0, 0.02, 0.003)

    lurek.light.newOccluder({ 370, 180, 390, 180, 390, 420, 370, 420 })
end

function lurek.process(dt)
    lurek.light.advanceFlickers(dt)
    if lurek.input.keyboard.isDown("escape") then lurek.event.quit() end
    local spd = 220 * dt
    if lurek.input.keyboard.isDown("a") then lx = lx - spd end
    if lurek.input.keyboard.isDown("d") then lx = lx + spd end
    if lurek.input.keyboard.isDown("w") then ly = ly - spd end
    if lurek.input.keyboard.isDown("s") then ly = ly + spd end
    light:setPosition(lx, ly)
end

function lurek.draw()
    -- Scene at full brightness — light pipeline will darken unlit areas (multiply)
    lurek.render.setColor(0.45, 0.42, 0.38, 1)
    lurek.render.rectangle("fill", 0, 0, 800, 600)
    -- occluder wall (visual)
    lurek.render.setColor(0.6, 0.5, 0.35, 1)
    lurek.render.rectangle("fill", 370, 180, 20, 240)
    -- light source marker
    lurek.render.setColor(1, 0.95, 0.5, 1)
    lurek.render.circle("fill", lx, ly, 5)
end

function lurek.draw_ui()
    lurek.render.setColor(1, 1, 1, 1)
    lurek.render.print("WASD: move light   ESC: quit", 10, 10)
    lurek.render.print(string.format("pos: %.0f, %.0f", lx, ly), 10, 28)
end
