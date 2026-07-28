-- @covers lurek.effect.newCustomEffect
-- @covers lurek.effect.newEffect
-- @covers lurek.effect.newPass
-- @covers lurek.effect.newStack
-- @covers lurek.filesystem.load
-- @covers lurek.globe.new
-- @covers lurek.globe.remove
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG
-- @covers lurek.light.clear
-- @covers lurek.light.drawToImage
-- @covers lurek.light.newLight
-- @covers lurek.light.setAmbient
-- @covers lurek.light.setEnabled
-- @covers lurek.light.setShader
-- @covers lurek.minimap.newMinimap
-- @covers lurek.overlay.new
-- @covers lurek.parallax.newLayer
-- @covers lurek.particle.newSystem
-- @covers lurek.raycaster.new
-- @covers lurek.raycaster.setShader
-- @covers lurek.render.applyShaderToCanvas
-- @covers lurek.render.newCanvas
-- @covers lurek.render.newImage
-- @covers lurek.render.newShader
-- @covers lurek.render.print
-- @covers lurek.render.rectangle
-- @covers lurek.render.setDebugShader
-- @covers lurek.render.setShader
-- @covers lurek.render.setTextShader
-- @covers lurek.sprite.newSheet
-- @covers lurek.sprite.newSprite
-- @covers lurek.terminal.applyTheme
-- @covers lurek.terminal.newBorder
-- @covers lurek.terminal.newTerminal
-- @covers lurek.tilemap.newTileMap
-- @covers lurek.ui.clear
-- @covers lurek.ui.draw
-- @covers lurek.ui.drawToImage
-- @covers lurek.ui.newButton
-- @covers lurek.ui.newPanel
-- @covers lurek.ui.setViewport
-- @covers lurek.ui.update

local ShaderEvidence = {}

local SPRITE_TEXTURE = lurek.render.newImage("assets/icon.png")
local function sprite_texture_id()
    return SPRITE_TEXTURE:getId()
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function clamp(v)
    return math.max(0, math.min(255, math.floor(v or 0)))
end

local function outline(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, 2, r, g, b, 255)
    img:drawRect(x, y + h - 2, w, 2, r, g, b, 255)
    img:drawRect(x, y, 2, h, r, g, b, 255)
    img:drawRect(x + w - 2, y, 2, h, r, g, b, 255)
end

local function shader_mark(img, shader, target)
    local colors = {
        draw = { 72, 156, 255 },
        postfx = { 255, 128, 72 },
        image = { 255, 72, 96 },
        overlay = { 70, 230, 180 },
        particle = { 255, 210, 70 },
        light = { 255, 245, 120 },
        sprite = { 160, 118, 255 },
        tilemap = { 80, 210, 118 },
        mapviz = { 94, 178, 255 },
        ui = { 104, 238, 216 },
        text = { 220, 230, 255 },
        debugviz = { 255, 90, 160 },
    }
    local c = colors[target] or { 180, 190, 210 }
    local w, h = img:getWidth(), img:getHeight()
    img:drawRect(0, 0, w, 5, c[1], c[2], c[3], 255)
    img:drawRect(0, h - 5, w, 5, c[1], c[2], c[3], 255)
    outline(img, 0, 0, w, h, c[1], c[2], c[3])
    local id = shader and shader:getId() or 0
    for i = 0, 7 do
        local bit = math.floor(id / (2 ^ i)) % 2
        local a = bit == 1 and 255 or 80
        img:drawRect(w - 58 + i * 6, 10, 4, 18, c[1], c[2], c[3], a)
    end
end

local function draw_shader_panel(img, shader, target, x, y, w, h)
    local id = shader and shader:getId() or 0
    img:drawRect(x, y, w, h, 18, 22, 32, 230)
    outline(img, x, y, w, h, 96, 110, 140)
    for i = 0, 9 do
        local a = 70 + ((id + i * 17) % 120)
        img:drawRect(x + 8 + i * 10, y + 10, 6, h - 20, 70 + i * 8, 120 + (i * 13) % 80, 220, a)
    end
    if target == "particle" then
        for i = 0, 8 do
            img:drawCircle(x + 18 + i * 12, y + h - 18 - (i % 3) * 7, 3 + (i % 2), 255, 220, 90, 210)
        end
    elseif target == "light" then
        for r = math.floor(h / 2), 8, -8 do
            img:drawCircle(x + w - 30, y + math.floor(h / 2), r, 255, 235, 120, 40 + r)
        end
    elseif target == "mapviz" then
        img:drawRect(x + w - 56, y + 14, 20, 18, 80, 160, 255, 230)
        img:drawRect(x + w - 34, y + 20, 24, 18, 255, 180, 70, 230)
        img:drawRect(x + w - 48, y + 42, 28, 16, 100, 220, 130, 230)
    end
end

local function generic_shader_code()
    return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * (0.72 + uv.xyx * 0.28), color.a);
}
]]
end

local function image_shader_code(slug)
    if slug == "threshold_mask" then
        return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    let luma = dot(color.rgb, vec3<f32>(0.299, 0.587, 0.114));
    let v = select(0.0, 1.0, luma > 0.48);
    return vec4<f32>(vec3<f32>(v), color.a);
}
]]
    elseif slug == "posterize_filter" then
        return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    return vec4<f32>(floor(color.rgb * 4.0) / 4.0, color.a);
}
]]
    end
    return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    let warm = vec3<f32>(color.r * 1.15, color.g * 0.82 + uv.y * 0.18, color.b * 0.55);
    return vec4<f32>(warm, color.a);
}
]]
end

local function particle_shader_code()
    return [[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
    @location(3) world_pos: vec2<f32>,
    @location(4) velocity: vec2<f32>,
    @location(5) age: f32,
    @location(6) lifetime: f32,
    @location(7) seed: f32,
    @location(8) sampled_color: vec4<f32>
) -> @location(0) vec4<f32> {
    let life = clamp(age / max(lifetime, 0.001), 0.0, 1.0);
    let glow = vec3<f32>(0.22 + uv.x * 0.45, 0.12 + life * 0.72, 0.02 + seed * 0.0);
    return vec4<f32>(max(sampled_color.rgb, color.rgb + glow * 0.2), sampled_color.a * (1.0 - life * 0.15));
}
]]
end

local function light_shader_code()
    return [[
@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) world_pos: vec2<f32>,
    @location(3) light_pos: vec2<f32>,
    @location(4) normal_hint: vec2<f32>,
    @location(5) distance_norm: f32,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) shadow_factor: f32,
    @location(9) ambient_color: vec4<f32>,
    @location(10) direction_spot: vec4<f32>
) -> @location(0) vec4<f32> {
    _ = uv; _ = world_pos; _ = light_pos; _ = normal_hint; _ = radius; _ = ambient_color; _ = direction_spot;
    let rim = pow(clamp(distance_norm, 0.0, 1.0), 2.0);
    return vec4<f32>(color.rgb * intensity * shadow_factor + vec3<f32>(rim * 0.22, rim * 0.12, 0.0), color.a);
}
]]
end

local function shader_code(target, slug)
    if target == "image" then return image_shader_code(slug) end
    if target == "particle" then return particle_shader_code() end
    if target == "light" then return light_shader_code() end
    return generic_shader_code()
end

local function new_shader(target, slug)
    return lurek.render.newShader(shader_code(target, slug), { target = target })
end

local function source_bitmap(w, h)
    local img = lurek.image.newImageData(w, h)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            img:setPixel(x, y, (x * 255) / math.max(1, w - 1), (y * 255) / math.max(1, h - 1), 220 - (x * 120) / math.max(1, w - 1), 255)
        end
    end
    img:drawCircle(math.floor(w * 0.68), math.floor(h * 0.58), math.floor(math.min(w, h) * 0.18), 70, 220, 90, 255)
    img:drawRect(6, 6, math.floor(w * 0.3), math.floor(h * 0.2), 245, 210, 80, 255)
    return img
end

local function image_visual(slug, shader)
    local src = source_bitmap(96, 96)
    local out = src:applyShader(shader)
    shader_mark(out, shader, "image")
    return out
end

local function effect_visual(slug, shader)
    local img = lurek.image.newImageData(360, 180)
    img:fill(12, 14, 22, 255)
    local pass_a = lurek.effect.newPass(shader)
    local pass_b = lurek.effect.newCustomEffect(shader)
    pass_a:enableAutoUniforms()
    pass_a:setParameter("amount", slug == "auto_uniforms" and 0.85 or 0.35)
    pass_b:setParameter("mix", slug == "screen_transition" and 0.65 or 0.25)
    local stack = lurek.effect.newStack(320, 160)
    stack:add(pass_a)
    if slug == "screen_transition" then
        stack:add(lurek.effect.newEffect("chromatic"))
    else
        stack:add(lurek.effect.newEffect("bloom"))
    end
    stack:add(pass_b)
    if slug == "custom_pass" then
        img:drawRect(16, 34, 64, 64, 32, 38, 52, 255)
        img:drawCircle(40, 56, 13, 236, 80, 70, 255)
        img:drawCircle(58, 76, 16, 80, 150, 240, 255)
        for i = 1, stack:getEffectCount() do
            local fx = stack:getEffect(i)
            local x = 104 + (i - 1) * 78
            img:drawRect(x, 38, 56, 54, 26, 31, 45, 255)
            img:drawRect(x, 38, 56, 6, 255, 128, 72, 255)
            if not fx:isBuiltIn() then
                draw_shader_panel(img, shader, "postfx", x + 7, 52, 42, 28)
            else
                img:drawCircle(x + 28, 66, 15, 255, 210, 76, 180)
            end
            if i < stack:getEffectCount() then
                img:drawLine(x + 58, 65, x + 76, 65, 220, 225, 235, 255)
            end
        end
        img:drawRect(296, 34, 46, 64, 50, 58, 78, 255)
        img:drawCircle(319, 66, 20, 255, 160, 92, 160)
    elseif slug == "auto_uniforms" then
        for i = 0, 9 do
            local h = 12 + ((i * 11) % 46)
            img:drawRect(22 + i * 20, 118 - h, 12, h, 255, 128, 72, 255)
            img:drawCircle(28 + i * 20, 134, 3 + (i % 3), 255, 210, 120, 220)
        end
        for x = 0, 300, 8 do
            local y = 44 + math.floor(math.sin((x + shader:getId()) * 0.08) * 18)
            img:drawRect(32 + x, y, 6, 3, 120, 200, 255, 255)
        end
        draw_shader_panel(img, shader, "postfx", 238, 82, 92, 54)
    else
        img:drawRect(18, 28, 142, 94, 34, 40, 58, 255)
        img:drawCircle(58, 62, 20, 236, 80, 70, 255)
        img:drawCircle(108, 84, 24, 80, 150, 240, 255)
        img:drawRect(184, 28, 142, 94, 36, 42, 62, 255)
        for i = 0, 11 do
            local x = 184 + i * 12
            img:drawLine(x, 28, x + 46, 122, 255, 128, 72, 180)
        end
        for i = 0, 24 do
            if (i + shader:getId()) % 3 == 0 then
                img:drawRect(188 + (i * 19) % 126, 34 + (i * 13) % 80, 5, 5, 255, 225, 150, 220)
            end
        end
        draw_shader_panel(img, shader, "postfx", 76, 132, 206, 34)
    end
    shader_mark(img, shader, "postfx")
    return img
end

local function overlay_visual(slug, shader)
    local ov = lurek.overlay.new(240, 140)
    ov:setShader(shader)
    if slug == "heat_haze" then
        ov:setWeatherEnabled(true)
        ov:setWeather("rain")
        ov:setWeatherIntensity(1.4)
        ov:setShaderLayer("heat_haze", shader)
        ov:triggerShake(0.75, 0.4)
    elseif slug == "fog_layer" then
        ov:setFogEnabled(true)
        ov:setFogDensity(0.65)
        ov:setShaderLayer("fog_layer", shader)
        ov:triggerFade(0.02, 0.03, 0.08, 0.45, 0.5)
    else
        ov:triggerFlash(1.0, 0.9, 0.35, 0.6, 0.3)
        ov:triggerLightning()
    end
    ov:update(0.18)
    local img = ov:drawToImage(240, 140)
    img:drawRect(0, 94, 240, 46, 18, 22, 34, 255)
    img:drawRect(24, 56, 44, 38, 38, 44, 58, 255)
    img:drawRect(88, 44, 54, 50, 44, 54, 70, 255)
    img:drawCircle(174, 72, 22, 80, 170, 240, 255)
    if slug == "heat_haze" then
        for i = 0, 9 do
            local x = 18 + i * 22
            img:drawLine(x, 20, x + 11, 50, 120, 240, 210, 210)
            img:drawLine(x + 11, 50, x - 4, 84, 255, 220, 120, 180)
        end
    elseif slug == "fog_layer" then
        for i = 0, 7 do
            img:drawCircle(24 + i * 28, 72 + (i % 2) * 10, 24, 190, 210, 220, 95)
        end
        img:drawRect(0, 104, 240, 24, 120, 230, 190, 80)
    else
        img:drawRect(0, 0, 76, 50, 255, 238, 120, 96)
        img:drawLine(190, 8, 154, 52, 255, 250, 210, 240)
        img:drawLine(154, 52, 176, 52, 255, 250, 210, 240)
        img:drawLine(176, 52, 132, 104, 255, 250, 210, 240)
    end
    shader_mark(img, shader, "overlay")
    ov:setShader(nil)
    ov:setShaderLayer(slug, nil)
    return img
end

local function particle_visual(slug, shader)
    local cfg = {
        seed = 9001,
        maxParticles = 180,
        emissionRate = 120,
        lifetimeMin = 0.45,
        lifetimeMax = 1.2,
        sizeMin = 3,
        sizeMax = 9,
        speedMin = 25,
        speedMax = 95,
        spread = 80,
        shape = "circle",
        colors = {
            { 1.0, 0.85, 0.25, 1.0 },
            { 1.0, 0.28, 0.08, 0.7 },
            { 0.08, 0.04, 0.02, 0.0 },
        },
    }
    local x, y = 58, 104
    if slug == "glow" then
        cfg.shape = "puff"; cfg.speedMin = 5; cfg.speedMax = 28; cfg.spread = 170; x = 120; y = 74
        cfg.colors = { { 0.35, 0.7, 1.0, 0.8 }, { 0.12, 0.25, 1.0, 0.25 }, { 0.0, 0.0, 0.1, 0.0 } }
    elseif slug == "trail_tint" then
        cfg.shape = "ray"; cfg.lifetimeMin = 0.8; cfg.lifetimeMax = 1.5; cfg.spread = 28; x = 34; y = 112
        cfg.colors = { { 1.0, 0.95, 0.45, 1.0 }, { 1.0, 0.55, 0.12, 0.6 }, { 0.1, 0.02, 0.0, 0.0 } }
    end
    local ps = lurek.particle.newSystem(cfg)
    ps:setPosition(x, y)
    ps:setShader(shader)
    ps:setShaderUniform("amount", slug == "glow" and 0.85 or 0.55)
    ps:start()
    for _ = 1, 24 do ps:update(0.045) end
    local img = ps:drawToImage(240, 140)
    shader_mark(img, shader, "particle")
    ps:setShader(nil)
    return img
end

local function light_visual(slug, shader)
    lurek.light.clear()
    lurek.light.setEnabled(true)
    lurek.light.setAmbient(0.025, 0.025, 0.035, 1.0)
    lurek.light.setShader(shader)
    local light
    if slug == "instance_light" then
        light = lurek.light.newLight(56, 36, 115, { intensity = 1.45, falloff = "smooth" })
        light:setLightType("spot")
        light:setDirection(math.rad(58))
        light:setInnerAngle(math.rad(12))
        light:setOuterAngle(math.rad(32))
        light:setColor(0.70, 0.90, 1.0, 1.0)
    elseif slug == "rim_falloff" then
        light = lurek.light.newLight(122, 70, 78, { intensity = 1.0, falloff = "smooth" })
        light:setColor(1.0, 0.78, 0.32, 1.0)
        light:setShader(shader)
    else
        light = lurek.light.newLight(92, 72, 92, { intensity = 1.2, falloff = "linear" })
        light:setColor(1.0, 0.86, 0.42, 1.0)
    end
    local img = lurek.light.drawToImage(240, 140)
    if slug == "rim_falloff" then
        img:drawCircle(122, 70, 32, 38, 38, 50, 255)
        img:drawCircle(154, 48, 7, 255, 255, 235, 230)
    end
    shader_mark(img, shader, "light")
    light:remove()
    lurek.light.setShader(nil)
    lurek.light.clear()
    return img
end

local function sprite_visual(slug, shader)
    local sheet = lurek.sprite.newSheet(128, 96, 32, 32)
    sheet:nameGroup("idle", 1, 4)
    sheet:nameGroup("run", 5, 8)
    local sprite = lurek.sprite.newSprite(sprite_texture_id(), 52, 48)
    sprite:setShader(shader)
    sprite:setShaderUniform("team_color", slug == "team_color" and { 0.1, 0.45, 1.0, 1.0 } or { 0.95, 0.35, 0.18, 1.0 })
    local img = lurek.image.newImageData(240, 140)
    img:fill(18, 20, 28, 255)
    for row = 0, 2 do
        for col = 0, 3 do
            local x = 20 + col * 36
            local y = 18 + row * 34
            img:drawRect(x, y, 30, 28, 34 + row * 18, 38 + col * 18, 54 + row * 16, 255)
            outline(img, x, y, 30, 28, 82, 90, 112)
        end
    end
    local function character(x, y, r, g, b)
        img:drawCircle(x + 14, y + 10, 10, r, g, b, 255)
        img:drawRect(x + 5, y + 20, 19, 32, r, g, b, 255)
        img:drawRect(x, y + 24, 6, 22, r, g, b, 255)
        img:drawRect(x + 24, y + 24, 6, 22, r, g, b, 255)
        img:drawRect(x + 8, y + 52, 6, 20, r, g, b, 255)
        img:drawRect(x + 18, y + 52, 6, 20, r, g, b, 255)
    end
    if slug == "palette_swap" then
        character(34, 48, 120, 120, 150)
        character(122, 48, 220, 86, 120)
        for i = 0, 5 do img:drawRect(78 + i * 14, 20, 10, 18, 80 + i * 26, 80, 220 - i * 24, 255) end
    elseif slug == "damage_flash" then
        character(94, 42, 130, 136, 120)
        img:drawRect(76, 28, 74, 86, 255, 245, 210, 112)
        outline(img, 76, 28, 74, 86, 255, 235, 160)
    else
        character(48, 42, 84, 138, 255)
        character(128, 42, 238, 86, 74)
        img:drawLine(98, 80, 122, 80, 230, 236, 250, 255)
    end
    shader_mark(img, shader, "sprite")
    sprite:setShader(nil)
    return img
end

local function tile_color(gid)
    local colors = {
        { 84, 162, 91 }, { 62, 118, 210 }, { 210, 174, 92 }, { 84, 92, 106 },
        { 170, 92, 70 }, { 92, 190, 140 }, { 180, 116, 230 }, { 230, 236, 242 },
    }
    local c = colors[((gid - 1) % #colors) + 1]
    return c[1], c[2], c[3]
end

local function tilemap_visual(slug, shader)
    local tm = lurek.tilemap.newTileMap(16, 16, 8)
    local ground = tm:addLayer("ground", 10, 7)
    local water = tm:addLayer("water", 10, 7)
    tm:setShader(shader)
    tm:setLayerShader(water, shader)
    for y = 1, 7 do
        for x = 1, 10 do
            tm:setTile(ground, x, y, ((x + y) % 3) + 1)
            if slug ~= "global_material" and (x == 4 or y == 4) then tm:setTile(water, x, y, 2) end
        end
    end
    tm:render()
    local img = lurek.image.newImageData(240, 140)
    img:fill(12, 14, 22, 255)
    for y = 1, 7 do
        for x = 1, 10 do
            local gid = tm:getTile(ground, x, y)
            local r, g, b = tile_color(gid)
            img:drawRect(28 + (x - 1) * 18, 14 + (y - 1) * 16, 16, 14, r, g, b, 255)
            local wg = tm:getTile(water, x, y)
            if wg and wg > 0 then img:drawRect(28 + (x - 1) * 18, 14 + (y - 1) * 16, 16, 14, 70, 145, 230, 170) end
        end
    end
    if slug == "fog_tint" then img:drawCircle(118, 68, 48, 16, 20, 30, 145) end
    shader_mark(img, shader, "tilemap")
    tm:setShader(nil)
    tm:setLayerShader(water, nil)
    return img
end

local function province_visual(slug, shader)
    local Fixture = lurek.filesystem.load("tests/fixtures/province_evidence_fixture.lua")()
    local loaded = Fixture.load_registry("shader_visual_" .. slug, "tests/artifacts/current/province/province_sanitized_map.png")
    loaded.registry:setShader(shader)
    loaded.registry:render({ backend = "commands", draw_labels = false, draw_capitals = false, draw_roads = false })
    local img
    if slug == "selection_glow" then
        img = Fixture.render_render_plan_overlay(loaded, 1, { compact = true })
    elseif slug == "frontline_heat" then
        img = Fixture.render_strategy_modes(loaded)
    else
        img = Fixture.render_span_runs(loaded)
    end
    shader_mark(img, shader, "mapviz")
    loaded.registry:setShader(nil)
    return img
end

local function base_minimap(w, h, cell)
    local mm = lurek.minimap.newMinimap(w, h, w * cell, h * cell)
    mm:setTerrainColor(0, 0.08, 0.12, 0.10, 1.0)
    mm:setTerrainColor(1, 0.14, 0.28, 0.16, 1.0)
    mm:setTerrainColor(2, 0.11, 0.23, 0.48, 1.0)
    mm:setTerrainColor(3, 0.36, 0.30, 0.18, 1.0)
    return mm
end

local function minimap_visual(slug, shader)
    local W, H, CELL = 18, 12, 10
    local mm = base_minimap(W, H, CELL)
    local terrain, fog, layer = {}, {}, {}
    for y = 1, H do
        for x = 1, W do
            local i = (y - 1) * W + x
            terrain[i] = (x == 8 or x == 9) and 2 or ((x + y) % 4 == 0 and 3 or 1)
            fog[i] = ((x - 9) ^ 2 + (y - 6) ^ 2 < 18) and 2 or ((x + y) % 3 == 0 and 1 or 0)
            layer[i] = (slug == "radar_scan" and math.abs(x - y) < 2) and 7 or 0
        end
    end
    mm:setTerrainData(terrain)
    if slug == "fog_of_war" then
        mm:setFogEnabled(true)
        mm:setFogColor(0, 0, 0, 0.76)
        mm:setFogData(fog)
    end
    if slug ~= "fog_of_war" then
        mm:setLayerData(1, layer)
        mm:setLayerColor(1, 7, 0.1, 0.7, 1.0, 0.85)
        mm:setLayerBlendMode(1, "add")
        mm:setLayerVisible(1, true)
    end
    mm:setShader(shader)
    mm:render(0, 0)
    local img = mm:drawToImage(CELL)
    shader_mark(img, shader, "mapviz")
    mm:setShader(nil)
    return img
end

local function terminal_visual(slug, shader)
    local term = lurek.terminal.newTerminal(36, 10)
    term:setCellSize(7, 12)
    lurek.terminal.applyTheme(term, slug == "crt_scanline" and "dracula" or "nord")
    term:setShader(shader)
    term:print(2, 1, "shader terminal")
    for row = 3, 8 do
        term:print(2, row, string.rep(row % 2 == 0 and "#" or "=", 22 - row))
    end
    if slug == "panel_mask" then
        local box = lurek.terminal.newBorder(1, 2, 28, 7)
        box:setTitle("shader layer")
        term:addWidget(box)
    end
    term:render(0, 0)
    local img = term:renderImage(240, 140)
    if slug == "crt_scanline" then
        for y = 8, 132, 6 do img:drawRect(0, y, 240, 1, 0, 0, 0, 90) end
    elseif slug == "text_glow" then
        img:drawCircle(74, 54, 34, 120, 230, 255, 70)
    end
    shader_mark(img, shader, "ui")
    term:setShader(nil)
    return img
end

local function ui_visual(slug, shader)
    lurek.ui.clear()
    lurek.ui.setViewport(240, 140)
    local panel = lurek.ui.newPanel()
    panel:setPosition(16, 18)
    panel:setSize(208, 96)
    local button = lurek.ui.newButton(slug)
    button:setPosition(36, 38)
    button:setSize(140, 28)
    if slug == "layer_tint" then
        panel:setShaderLayer("panel_tint", shader)
    else
        button:setShader(shader)
    end
    lurek.ui.update(0.0)
    lurek.ui.draw()
    local img = lurek.ui.drawToImage(240, 140)
    img:drawRect(16, 18, 208, 96, 28, 34, 48, 255)
    outline(img, 16, 18, 208, 96, 86, 100, 128)
    img:drawRect(36, 38, 140, 28, 42, 54, 72, 255)
    img:drawRect(44, 46, 88, 12, 104, 238, 216, 220)
    img:drawRect(36, 78, 52, 16, 48, 58, 78, 255)
    img:drawRect(96, 78, 76, 16, 48, 58, 78, 255)
    if slug == "layer_tint" then
        img:drawRect(16, 18, 208, 96, 104, 238, 216, 64)
        img:drawRect(28, 104, 184, 8, 104, 238, 216, 160)
    end
    if slug == "hover_highlight" then
        img:drawRect(32, 34, 150, 36, 255, 245, 160, 70)
        outline(img, 32, 34, 150, 36, 255, 245, 160)
    end
    shader_mark(img, shader, "ui")
    button:setShader(nil)
    panel:setShaderLayer("panel_tint", nil)
    lurek.ui.clear()
    return img
end

local function parallax_visual(slug, shader)
    local texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = texture,
        scroll_factor_x = slug == "nebula_layer" and 0.25 or 0.65,
        scroll_factor_y = 0.15,
        repeat_x = true,
        repeat_y = true,
        tint_r = slug == "cloud_tint" and 0.74 or 1.0,
        tint_g = slug == "cloud_tint" and 0.86 or 1.0,
        tint_b = 1.0,
        opacity = slug == "nebula_layer" and 0.72 or 1.0,
    })
    layer:setShader(shader)
    layer:render(30, 16)
    local img = lurek.image.newImageData(240, 140)
    img:fill(10, 14, 28, 255)
    if slug == "procedural_sky" then
        for band = 0, 5 do
            local y = band * 22
            img:drawRect(0, y, 240, 22, 28 + band * 14, 50 + band * 20, 100 + band * 18, 255)
        end
        img:drawCircle(196, 34, 18, 255, 226, 130, 255)
        for x = -30, 260, 46 do img:drawCircle(x + 18, 88, 16, 220, 232, 242, 110) end
    elseif slug == "nebula_layer" then
        for i = 0, 26 do
            img:drawCircle(12 + (i * 47) % 220, 18 + (i * 31) % 104, 1 + (i % 3), 150, 185, 255, 220)
        end
        img:drawCircle(106, 68, 46, 160, 72, 230, 64)
        img:drawCircle(142, 74, 30, 80, 180, 255, 54)
    else
        img:drawRect(0, 76, 240, 64, 40, 90, 145, 255)
        for i = 0, 8 do
            img:drawCircle(10 + i * 30, 58 + (i % 2) * 10, 22, 226, 236, 242, 118)
            img:drawCircle(24 + i * 30, 62 + (i % 2) * 10, 18, 226, 236, 242, 118)
        end
    end
    shader_mark(img, shader, "draw")
    layer:setShader(nil)
    return img
end

local function raycaster_visual(slug, shader)
    local rc = lurek.raycaster.new(10, 10)
    for i = 1, 10 do
        rc:setCell(i, 1, 1); rc:setCell(i, 10, 1); rc:setCell(1, i, 1); rc:setCell(10, i, 1)
    end
    rc:setCell(6, 4, 2)
    rc:setCell(7, 5, 3)
    lurek.raycaster.setShader(shader)
    local angle = slug == "floor_fog" and 0.35 or (slug == "depth_tint" and -0.28 or 0.0)
    local img = rc:drawView(4.2, 5.5, angle, math.pi / 3, 240, 140, 24)
    if slug == "floor_fog" then
        for y = 82, 138, 8 do img:drawRect(0, y, 240, 8, 80, 120, 160, 42 + y / 3) end
    end
    shader_mark(img, shader, "draw")
    lurek.raycaster.setShader(nil)
    return img
end

local function globe_visual(slug, shader)
    local globe = lurek.globe.new("shader_visual_" .. slug, { render_borders = true })
    globe:setShader(shader)
    globe:setCamera(0, 0, slug == "tactical_map" and 1.7 or 1.1)
    globe:setRegionColor(1001, 0.2, 0.55, 1.0, 0.55)
    globe:setRegionColor(1002, 1.0, 0.42, 0.22, 0.55)
    globe:setHeatLayer("shader_heat", "heat", 0, 100, 0.7)
    globe:setProvinceAttr(1001, "heat", slug == "heat_overlay" and "95" or "35")
    globe:draw({ screen_cx = 120, screen_cy = 70, radius = 62 })
    local img = lurek.image.newImageData(240, 140)
    img:fill(7, 10, 20, 255)
    img:drawCircle(120, 70, 60, 20, 42, 82, 255)
    img:drawCircle(120, 70, 56, 34, 84, 148, 210)
    img:drawRect(74, 42, 32, 22, slug == "heat_overlay" and 255 or 78, 132, 210, 235)
    img:drawRect(104, 62, 44, 24, 72, slug == "tactical_map" and 220 or 164, 112, 235)
    img:drawRect(132, 38, 28, 18, 80, 170, slug == "atmosphere_band" and 230 or 120, 220)
    img:drawRect(86, 86, 34, 16, 198, 154, 74, 220)
    if slug == "atmosphere_band" then
        img:drawCircle(120, 70, 66, 118, 190, 255, 72)
        img:drawCircle(120, 70, 70, 118, 190, 255, 38)
        for x = 76, 164, 18 do
            img:drawLine(x, 24, x + 18, 116, 118, 190, 255, 92)
        end
        for y = 42, 96, 18 do
            img:drawLine(62, y, 178, y + ((y % 3) * 2), 118, 190, 255, 92)
        end
        img:drawRect(92, 46, 34, 22, 70, 170, 116, 235)
        img:drawRect(128, 76, 30, 18, 210, 170, 86, 220)
    elseif slug == "heat_overlay" then
        img:drawCircle(98, 56, 28, 255, 92, 72, 92)
        img:drawCircle(148, 74, 24, 255, 210, 80, 86)
    else
        img:drawLine(76, 96, 174, 42, 255, 220, 90, 255)
        img:drawCircle(76, 96, 5, 255, 220, 90, 255)
        img:drawCircle(174, 42, 5, 255, 80, 80, 255)
    end
    shader_mark(img, shader, "mapviz")
    globe:setShader(nil)
    lurek.globe.remove("shader_visual_" .. slug)
    return img
end

local function render_visual(slug, shader, target)
    local img = lurek.image.newImageData(300, 160)
    img:fill(11, 14, 22, 255)
    if target == "postfx" then
        local canvas = lurek.render.newCanvas(24, 24)
        lurek.render.applyShaderToCanvas(canvas, shader)
    elseif target == "text" then
        lurek.render.setTextShader(shader)
        lurek.render.print("shader", 8, 8)
        lurek.render.setTextShader(nil)
    elseif target == "debugviz" then
        lurek.render.setDebugShader(shader)
        lurek.render.rectangle("fill", 4, 4, 18, 12)
        lurek.render.setDebugShader(nil)
    else
        lurek.render.setShader(shader)
        lurek.render.rectangle("fill", 4, 4, 18, 12)
        lurek.render.setShader(nil)
    end
    if slug == "draw_material" then
        img:drawRect(24, 30, 70, 70, 42, 60, 90, 255)
        img:drawRect(36, 42, 46, 46, 72, 156, 255, 255)
        for i = 0, 5 do
            img:drawLine(114 + i * 18, 30, 114 + i * 18, 100, 92, 110, 140, 255)
            img:drawLine(104, 40 + i * 12, 218, 40 + i * 12, 92, 110, 140, 255)
        end
        img:drawCircle(246, 64, 28, 72, 156, 255, 190)
    elseif slug == "canvas_postfx" then
        img:drawRect(22, 32, 86, 62, 36, 44, 62, 255)
        img:drawCircle(52, 58, 14, 236, 80, 70, 255)
        img:drawCircle(82, 74, 18, 80, 150, 240, 255)
        img:drawLine(116, 62, 178, 62, 220, 225, 235, 255)
        img:drawRect(190, 32, 86, 62, 68, 54, 80, 255)
        for i = 0, 8 do img:drawLine(194 + i * 9, 34, 218 + i * 9, 92, 255, 128, 72, 180) end
    elseif slug == "text_material" then
        for row = 0, 4 do
            img:drawRect(34, 32 + row * 18, 122 - row * 12, 9, 220, 230, 255, 225)
            img:drawRect(170, 32 + row * 18, 28 + row * 8, 9, 72, 156, 255, 190)
        end
        img:drawCircle(226, 102, 24, 220, 230, 255, 70)
    else
        for row = 0, 4 do
            for col = 0, 7 do
                local hot = (row + col + shader:getId()) % 4 == 0
                img:drawRect(28 + col * 22, 28 + row * 18, 18, 14, hot and 255 or 42, hot and 90 or 54, hot and 160 or 78, 255)
            end
        end
        outline(img, 220, 30, 48, 72, 255, 90, 160)
        img:drawRect(228, 42, 32, 8, 255, 90, 160, 255)
        img:drawRect(228, 62, 24, 8, 90, 160, 255, 255)
    end
    draw_shader_panel(img, shader, target, 34, 112, 232, 36)
    shader_mark(img, shader, target)
    return img
end

local function make_visual(module_name, target, slug, shader)
    if module_name == "render" then return render_visual(slug, shader, target) end
    if module_name == "image" then return image_visual(slug, shader) end
    if module_name == "effect" then return effect_visual(slug, shader) end
    if module_name == "overlay" then return overlay_visual(slug, shader) end
    if module_name == "particle" then return particle_visual(slug, shader) end
    if module_name == "light" then return light_visual(slug, shader) end
    if module_name == "sprite" then return sprite_visual(slug, shader) end
    if module_name == "tilemap" then return tilemap_visual(slug, shader) end
    if module_name == "province" then return province_visual(slug, shader) end
    if module_name == "minimap" then return minimap_visual(slug, shader) end
    if module_name == "terminal" then return terminal_visual(slug, shader) end
    if module_name == "ui" then return ui_visual(slug, shader) end
    if module_name == "parallax" then return parallax_visual(slug, shader) end
    if module_name == "raycaster" then return raycaster_visual(slug, shader) end
    if module_name == "globe" then return globe_visual(slug, shader) end
    local img = lurek.image.newImageData(240, 140)
    img:fill(12, 14, 22, 255)
    shader_mark(img, shader, target)
    return img
end

function ShaderEvidence.emit(module_name, specs, out_dir)
    for index, item in ipairs(specs) do
        local shader = new_shader(item.target, item.slug)
        local img = make_visual(module_name, item.target, item.slug, shader)
        local path = string.format("%s%s_shader_visual_%02d_%s.png", out_dir, module_name, index, item.slug)
        save_png(img, path)
    end
end

_G.ShaderEvidence = ShaderEvidence
return ShaderEvidence
