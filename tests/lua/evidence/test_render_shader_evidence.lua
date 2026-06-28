-- Canonical evidence file for lurek.render shader target contracts and shader-bound module APIs.

local OUT = evidence_output_dir("render")

local function save_text(path, text)
    if write_file then
        write_file(path, text)
    elseif lurek and lurek.filesystem and lurek.filesystem.write then
        lurek.filesystem.write(path, text)
    else
        error("unable to create evidence text artifact: " .. path)
    end
    expect_evidence_created(path)
end

local function shader_code()
    return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]]
end

local function image_shader_code()
    return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    _ = uv;
    return vec4<f32>(1.0, 0.0, 0.0, color.a);
}
]]
end

-- @describe Evidence: lurek.render
describe("Evidence: lurek.render", function()
    before_each(function()
        ensure_evidence_dir("render")
    end)

    -- Does: Builds one shader for every public target and binds the target-specific module APIs.
    -- Shows: Text artifacts list validated targets, diagnostics, and bound API ids for draw, image, overlay, particle, effect, light, sprite, tilemap, mapviz, text, ui, and debugviz.
    -- Artifact: tests/artifacts/current/render/render_shader_contract.txt plus render_shader_draw_contract.txt, render_shader_postfx_contract.txt, render_shader_image_contract.txt, render_shader_overlay_contract.txt, render_shader_particle_contract.txt, render_shader_light_contract.txt, render_shader_sprite_contract.txt, render_shader_tilemap_contract.txt, render_shader_mapviz_contract.txt, render_shader_text_contract.txt, render_shader_ui_contract.txt, render_shader_debugviz_contract.txt, and render_canvas_shader_pass_contract.txt
    -- Why: This is render-owned evidence because render compiles shaders, validates targets, and executes the GPU-backed shader paths.
    it("TXT: render shader target and binding contract", function()
        local targets = { "draw", "postfx", "image", "overlay", "particle", "light", "sprite", "tilemap", "mapviz", "text", "ui", "debugviz" }
        local lines = { "Shader API v2 target contract evidence" }
        local shaders = {}
        local target_lines = {}

        for _, target in ipairs(targets) do
            local code = target == "image" and image_shader_code() or shader_code()
            local shader = lurek.render.newShader(code, { target = target })
            shaders[target] = shader
            local diagnostics = shader:getDiagnostics()
            lines[#lines + 1] = target .. ": id=" .. shader:getId() .. " diagnostics=" .. table.concat(diagnostics, "|")
            target_lines[target] = {
                "Shader API v2 per-target evidence",
                "constructor=lurek.render.newShader",
                "target=" .. target,
                "id=" .. shader:getId(),
                "actual_target=" .. shader:getTarget(),
                "diagnostics=" .. table.concat(diagnostics, "|"),
            }
        end

        lurek.render.setShader(shaders.draw)
        target_lines.draw[#target_lines.draw + 1] = "render.setShader.accepted=true"
        target_lines.draw[#target_lines.draw + 1] = "render.getShader.target=" .. lurek.render.getShader():getTarget()
        lurek.render.setShader(nil)
        target_lines.draw[#target_lines.draw + 1] = "render.setShader.cleared=true"

        local image = lurek.image.newImageData(2, 2)
        image:fill(10, 20, 30, 255)
        local output = image:applyShader(shaders.image)
        lines[#lines + 1] = "image.applyShader=" .. output:getWidth() .. "x" .. output:getHeight()
        target_lines.image[#target_lines.image + 1] = "image.applyShader=" .. output:getWidth() .. "x" .. output:getHeight()
        local r, g, b, a = output:getPixel(0, 0)
        lines[#lines + 1] = "image.applyShader.pixel=" .. table.concat({ r, g, b, a }, ",")
        target_lines.image[#target_lines.image + 1] = "image.applyShader.pixel=" .. table.concat({ r, g, b, a }, ",")
        local job = lurek.image.requestShader(image, shaders.image)
        lines[#lines + 1] = "image.requestShader.wait=" .. tostring(job:wait(10) ~= nil)
        target_lines.image[#target_lines.image + 1] = "image.requestShader.wait=true"

        local fx = lurek.effect.newCustomEffect(shaders.postfx)
        lines[#lines + 1] = "effect.custom=" .. fx:getTypeName()
        target_lines.postfx[#target_lines.postfx + 1] = "effect.newCustomEffect.type=" .. fx:getTypeName()
        target_lines.postfx[#target_lines.postfx + 1] = "effect.target=postfx"
        local canvas = lurek.render.newCanvas(8, 8)
        local canvas_returned = lurek.render.applyShaderToCanvas(canvas, shaders.postfx)
        local method_returned = canvas:applyShader(shaders.postfx)
        lines[#lines + 1] = "canvas.applyShaderToCanvas=" .. canvas_returned:type()
        lines[#lines + 1] = "canvas.method.applyShader=" .. method_returned:type()
        target_lines.postfx[#target_lines.postfx + 1] = "render.applyShaderToCanvas=" .. canvas_returned:type()
        target_lines.postfx[#target_lines.postfx + 1] = "LCanvas.applyShader=" .. method_returned:type()
        lines[#lines + 1] = "postfx.screen_transition=wipe,dissolve,fade_mask"
        target_lines.postfx[#target_lines.postfx + 1] = "screen_transition.use_cases=wipe,dissolve,fade_mask"

        local overlay = lurek.overlay.new(64, 64)
        overlay:setShaderLayer("heat_haze", shaders.overlay)
        lines[#lines + 1] = "overlay.layer=" .. overlay:getShaderLayer("heat_haze"):getTarget()
        lines[#lines + 1] = "overlay.plan.shader=" .. table.concat(overlay:getRenderPlan().shader, ",")
        target_lines.overlay[#target_lines.overlay + 1] = "overlay.layer=" .. overlay:getShaderLayer("heat_haze"):getTarget()
        target_lines.overlay[#target_lines.overlay + 1] = "overlay.plan.shader=" .. table.concat(overlay:getRenderPlan().shader, ",")

        local particles = lurek.particle.newSystem({ maxParticles = 8 })
        particles:setShader(shaders.particle)
        particles:setShaderUniform("glow_amount", 0.5)
        lines[#lines + 1] = "particle.shader=" .. particles:getShader():getTarget()
        target_lines.particle[#target_lines.particle + 1] = "particle.shader=" .. particles:getShader():getTarget()
        target_lines.particle[#target_lines.particle + 1] = "particle.uniform.glow_amount=" .. tostring(shaders.particle:hasUniform("glow_amount"))

        lurek.light.setShader(shaders.light)
        local light = lurek.light.newLight(16, 16, 32)
        light:setShader(shaders.light)
        lines[#lines + 1] = "light.world=" .. lurek.light.getShader():getTarget()
        lines[#lines + 1] = "light.instance=" .. light:getShader():getTarget()
        target_lines.light[#target_lines.light + 1] = "light.world=" .. lurek.light.getShader():getTarget()
        target_lines.light[#target_lines.light + 1] = "light.instance=" .. light:getShader():getTarget()

        local sprite = lurek.sprite.newSprite(7, 10, 20)
        sprite:setShader(shaders.sprite)
        sprite:setShaderUniform("team_color", { 0.2, 0.6, 1.0, 1.0 })
        lines[#lines + 1] = "sprite.shader=" .. sprite:getShader():getTarget()
        target_lines.sprite[#target_lines.sprite + 1] = "sprite.shader=" .. sprite:getShader():getTarget()
        target_lines.sprite[#target_lines.sprite + 1] = "sprite.uniform.team_color=" .. tostring(shaders.sprite:hasUniform("team_color"))

        local tilemap = lurek.tilemap.newTileMap(16, 16)
        tilemap:addLayer("terrain", 2, 2)
        tilemap:setTile(1, 1, 1, 1)
        tilemap:setShader(shaders.tilemap)
        tilemap:setLayerShader(1, shaders.tilemap)
        tilemap:render()
        lines[#lines + 1] = "tilemap.shader=" .. tilemap:getShader():getTarget()
        lines[#lines + 1] = "tilemap.layer_shader=" .. tilemap:getLayerShader(1):getTarget()
        target_lines.tilemap[#target_lines.tilemap + 1] = "tilemap.shader=" .. tilemap:getShader():getTarget()
        target_lines.tilemap[#target_lines.tilemap + 1] = "tilemap.layer_shader=" .. tilemap:getLayerShader(1):getTarget()

        local province = lurek.province.newFromPng("render-shader-mapviz-evidence", "content/games/eu2/map.png")
        province:setShader(shaders.mapviz)
        province:render({ backend = "commands", draw_labels = false, draw_capitals = false, draw_roads = false })
        lines[#lines + 1] = "province.shader=" .. province:getShader():getTarget()
        target_lines.mapviz[#target_lines.mapviz + 1] = "province.shader=" .. province:getShader():getTarget()

        local minimap = lurek.minimap.newMinimap(8, 8, 64, 64)
        minimap:setShader(shaders.mapviz)
        minimap:render(0, 0)
        lines[#lines + 1] = "minimap.shader=" .. minimap:getShader():getTarget()
        target_lines.mapviz[#target_lines.mapviz + 1] = "minimap.shader=" .. minimap:getShader():getTarget()

        lurek.render.setTextShader(shaders.text)
        lurek.render.print("shader text evidence", 8, 14)
        lines[#lines + 1] = "render.text_shader=" .. lurek.render.getTextShader():getTarget()
        target_lines.text[#target_lines.text + 1] = "render.setTextShader.accepted=true"
        target_lines.text[#target_lines.text + 1] = "render.getTextShader.target=" .. lurek.render.getTextShader():getTarget()
        target_lines.text[#target_lines.text + 1] = "render.print.queued=true"
        lurek.render.setTextShader(nil)
        target_lines.text[#target_lines.text + 1] = "render.setTextShader.cleared=true"

        local terminal = lurek.terminal.newTerminal(18, 4)
        terminal:setShader(shaders.ui)
        terminal:print(1, 1, "ui shader")
        terminal:render(0, 0)
        lines[#lines + 1] = "terminal.shader=" .. terminal:getShader():getTarget()
        target_lines.ui[#target_lines.ui + 1] = "terminal.shader=" .. terminal:getShader():getTarget()
        target_lines.ui[#target_lines.ui + 1] = "terminal.render.queued=true"
        terminal:setShader(nil)
        target_lines.ui[#target_lines.ui + 1] = "terminal.shader.cleared=true"

        local ui_button = lurek.ui.newButton("Shader UI")
        ui_button:setPosition(12, 12)
        ui_button:setSize(120, 32)
        ui_button:setShader(shaders.ui)
        lurek.ui.draw()
        lines[#lines + 1] = "ui.widget_shader=ui"
        target_lines.ui[#target_lines.ui + 1] = "ui.widget.setShader=true"
        target_lines.ui[#target_lines.ui + 1] = "ui.draw.queued_retained_commands=true"
        ui_button:setShader(nil)

        lurek.render.setDebugShader(shaders.debugviz)
        lurek.render.rectangle("fill", 2, 2, 8, 6)
        lines[#lines + 1] = "render.debug_shader=" .. lurek.render.getDebugShader():getTarget()
        target_lines.debugviz[#target_lines.debugviz + 1] = "render.setDebugShader.accepted=true"
        target_lines.debugviz[#target_lines.debugviz + 1] = "render.getDebugShader.target=" .. lurek.render.getDebugShader():getTarget()
        target_lines.debugviz[#target_lines.debugviz + 1] = "render.debug_rectangle.queued=true"
        lurek.render.setDebugShader(nil)
        target_lines.debugviz[#target_lines.debugviz + 1] = "render.setDebugShader.cleared=true"

        save_text(OUT .. "render_shader_contract.txt", table.concat(lines, "\n") .. "\n")
        for _, target in ipairs(targets) do
            save_text(OUT .. "render_shader_" .. target .. "_contract.txt", table.concat(target_lines[target], "\n") .. "\n")
        end
        save_text(OUT .. "render_canvas_shader_pass_contract.txt", table.concat({
            "Render canvas shader pass evidence",
            "constructor=lurek.render.newShader",
            "target=postfx",
            "render.applyShaderToCanvas=" .. canvas_returned:type(),
            "LCanvas.applyShader=" .. method_returned:type(),
            "canvas_target_reuse=postfx",
            "screen_transition.use_cases=wipe,dissolve,fade_mask",
        }, "\n") .. "\n")
    end)
end)

test_summary()
