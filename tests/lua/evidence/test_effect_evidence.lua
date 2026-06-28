-- Evidence tests: effect module
-- Artifacts are generated from lurek.effect constructors, parameter APIs, stack ordering, and capture-state APIs.
-- This file intentionally avoids file-level @covers markers; evidence ownership is described per artifact block.

local OUT = evidence_output_dir("effect")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options or { delayMs = 100, speed = 10 })
    expect_evidence_created(path)
end

local function reset_effect_outputs()
    local names = {
        "effect_capture_preset_state.json",
        "effect_image_chain_parameters.png",
        "effect_image_chain_state.json",
        "effect_custom_shader_pass_map.png",
        "effect_enable_dedup_matrix.png",
        "effect_parameter_response_curves.png",
        "effect_preset_stack_contact_sheet.png",
        "effect_stack_order_lookbook.gif",
        "effect_stack_parameter_sequence.gif",
        "effect_stack_pipeline.gif",
        "effect_stack_state.json",
        "effect_type_catalog.png",
    }
    for _, name in ipairs(names) do
        pcall(function()
            lurek.filesystem.remove(OUT .. name)
        end)
        if os and os.remove then
            pcall(function()
                os.remove(OUT .. name)
            end)
        end
    end
end

local function clamp01(v)
    return math.max(0.0, math.min(1.0, tonumber(v) or 0.0))
end

local function effect_color(name)
    if name == "blur" then
        return { 92, 170, 255 }
    end
    if name == "bloom" then
        return { 255, 210, 76 }
    end
    if name == "crt" then
        return { 90, 225, 125 }
    end
    if name == "chromatic" then
        return { 255, 82, 142 }
    end
    if name == "colourgrade" then
        return { 180, 122, 255 }
    end
    if name == "vignette" then
        return { 70, 75, 96 }
    end
    return { 172, 182, 198 }
end

local function normalize_parameter(name, value)
    value = tonumber(value) or 0.0
    if name == "radius" then
        return clamp01(value / 12.0)
    end
    if name == "threshold" or name == "intensity" or name == "strength" then
        return clamp01(value / 2.0)
    end
    if name == "scanline_strength" or name == "offset" then
        return clamp01(value / 0.8)
    end
    if name == "brightness" or name == "contrast" or name == "saturation" then
        return clamp01(value / 2.0)
    end
    return clamp01(value)
end

local function parameter_names(effect)
    local names = effect:getParameterNames()
    table.sort(names)
    return names
end

local function minimal_shader_code()
    return [[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]]
end

local function draw_outline(img, x, y, w, h, r, g, b)
    img:drawLine(x, y, x + w - 1, y, r, g, b, 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, 255)
end

local function draw_effect_node(img, x, y, w, h, effect, enabled)
    local color = effect_color(effect:getTypeName())
    local alpha = enabled and 255 or 85
    img:drawRect(x, y, w, h, 23, 27, 39, 255)
    img:drawRect(x, y, w, 3, color[1], color[2], color[3], alpha)
    img:drawCircle(x + 14, y + 15, 8, color[1], color[2], color[3], alpha)
    if not enabled then
        img:drawLine(x + 6, y + 6, x + w - 6, y + h - 6, 235, 80, 90, 255)
        img:drawLine(x + w - 6, y + 6, x + 6, y + h - 6, 235, 80, 90, 255)
    end

    local names = parameter_names(effect)
    local bar_y = y + 34
    for i, name in ipairs(names) do
        if i > 5 then
            break
        end
        local value = normalize_parameter(name, effect:getParameter(name, 0.0))
        img:drawRect(x + 10, bar_y, w - 20, 5, 40, 44, 58, 255)
        img:drawRect(x + 10, bar_y, math.max(2, math.floor((w - 20) * value)), 5, color[1], color[2], color[3], alpha)
        bar_y = bar_y + 8
    end
end

local function draw_stack_pipeline_frame(stack, frame_index, width, height)
    local img = lurek.image.newImageData(width, height)
    img:fill(12, 14, 22, 255)
    img:drawRect(0, 0, width, 16, 33, 39, 58, 255)
    img:drawRect(0, height - 16, width, 16, 33, 39, 58, 255)

    local source_x = 14
    img:drawRect(source_x, 36, 58, 58, 42, 50, 68, 255)
    img:drawCircle(source_x + 18, 54, 10, 230, 80, 70, 255)
    img:drawCircle(source_x + 38, 72, 12, 80, 150, 240, 255)
    img:drawLine(source_x + 10, 88, source_x + 50, 42, 235, 210, 90, 255)

    local count = stack:getEffectCount()
    local node_w = 84
    local gap = 16
    local x = 92
    for i = 1, count do
        local effect = stack:getEffect(i)
        local enabled = stack:isEnabled(i) and effect:isEnabled()
        img:drawLine(x - gap + 2, 65, x - 4, 65, 92, 102, 128, 255)
        draw_effect_node(img, x, 28, node_w, 82, effect, enabled)
        x = x + node_w + gap
    end

    local feedback = stack:getFeedback()
    img:drawRect(92, 126, width - 116, 10, 38, 42, 56, 255)
    img:drawRect(92, 126, math.max(1, math.floor((width - 116) * feedback)), 10, 130, 190, 255, 255)
    img:drawCircle(width - 24, 131, 5 + frame_index % 5, 130, 190, 255, 220)
    return img
end

local function draw_effect_catalog(types, width, height)
    local img = lurek.image.newImageData(width, height)
    img:fill(13, 15, 24, 255)
    local cols = 3
    local cell_w = math.floor(width / cols)
    local cell_h = 72
    for i, name in ipairs(types) do
        local effect = lurek.effect.newEffect(name)
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = col * cell_w + 8
        local y = row * cell_h + 10
        local color = effect_color(name)
        img:drawRect(x, y, cell_w - 16, cell_h - 12, 24, 28, 40, 255)
        img:drawRect(x, y, cell_w - 16, 4, color[1], color[2], color[3], 255)
        img:drawCircle(x + 18, y + 24, 10, color[1], color[2], color[3], 255)
        local names = parameter_names(effect)
        for p = 1, #names do
            local dot_x = x + 42 + ((p - 1) % 5) * 16
            local dot_y = y + 19 + math.floor((p - 1) / 5) * 16
            img:drawCircle(dot_x, dot_y, 4, color[1], color[2], color[3], 220)
        end
    end
    return img
end

local function draw_image_chain(chain, width, height)
    local img = lurek.image.newImageData(width, height)
    img:fill(12, 14, 22, 255)
    local count = chain:getEffectCount()
    for i = 1, count do
        local effect = chain:getEffect(i)
        local color = effect_color(effect:getTypeName())
        local x = 18 + (i - 1) * 128
        img:drawRect(x, 24, 106, 96, 24, 28, 40, 255)
        img:drawRect(x, 24, 106, 5, color[1], color[2], color[3], 255)
        img:drawCircle(x + 24, 50, 12, color[1], color[2], color[3], 255)
        for p, name in ipairs(parameter_names(effect)) do
            local y = 72 + (p - 1) * 10
            if y > 112 then
                break
            end
            local value = normalize_parameter(name, effect:getParameter(name, 0.0))
            img:drawRect(x + 16, y, 74, 5, 38, 42, 56, 255)
            img:drawRect(x + 16, y, math.max(2, math.floor(74 * value)), 5, color[1], color[2], color[3], 255)
        end
        if i < count then
            img:drawLine(x + 108, 72, x + 126, 72, 92, 102, 128, 255)
        end
    end
    return img
end

local function draw_stack_strip(img, stack, x, y, w, h)
    img:drawRect(x, y, w, h, 18, 22, 34, 255)
    local count = stack:getEffectCount()
    local node_w = math.max(30, math.floor((w - 20) / math.max(1, count)))
    for i = 1, count do
        local effect = stack:getEffect(i)
        local color = effect_color(effect:getTypeName())
        local nx = x + 10 + (i - 1) * node_w
        local enabled = stack:isEnabled(i) and effect:isEnabled()
        img:drawRect(nx, y + 12, node_w - 6, h - 24, 28, 32, 44, 255)
        img:drawRect(nx, y + 12, node_w - 6, 5, color[1], color[2], color[3], enabled and 255 or 90)
        img:drawCircle(nx + math.floor((node_w - 6) / 2), y + math.floor(h / 2), 7, color[1], color[2], color[3], enabled and 255 or 90)
        if not enabled then
            img:drawLine(nx + 3, y + 18, nx + node_w - 10, y + h - 18, 235, 75, 90, 255)
        end
    end
    draw_outline(img, x, y, w, h, 210, 218, 234)
end

reset_effect_outputs()

-- @describe Evidence: lurek.effect API
describe("Evidence: lurek.effect API", function()
    before_each(function()
        ensure_evidence_dir("effect")
    end)

    -- Does: Creates the built-in effect catalog and renders one tile per effect type with dots for its public parameter set.
    -- Shows: The PNG makes the module scope visible: effects are typed parameter carriers, not arbitrary image drawing.
    -- Artifact: tests/artifacts/current/effect/effect_type_catalog.png
    -- Why: This proves lurek.effect.newEffect, LPostFxEffect:getTypeName, and LPostFxEffect:getParameterNames in a visual form a reviewer can inspect quickly.
    it("PNG: built-in effect type catalog", function()
        local img = draw_effect_catalog({
            "blur",
            "bloom",
            "crt",
            "chromatic",
            "colourgrade",
            "vignette",
        }, 420, 150)
        save_png(img, OUT .. "effect_type_catalog.png")
    end)

    -- Does: Builds an ordered stack, mutates pass parameters over time, toggles CRT off and on, and animates the resulting pipeline graph.
    -- Shows: The GIF exposes effect-stack semantics: source image, pass order, enabled/disabled state, parameter magnitudes, and feedback all change over time.
    -- Artifact: tests/artifacts/current/effect/effect_stack_pipeline.gif
    -- Why: Lua effect APIs currently expose stack/preset/capture state rather than a full CPU postprocess raster; this artifact visualizes the actual effect objects and stack state without borrowing overlay or particle behavior.
    it("GIF: animated post-fx stack pipeline", function()
        local stack = lurek.effect.newStack(512, 220)
        local blur = lurek.effect.newEffect("blur")
        local bloom = lurek.effect.newEffect("bloom")
        local crt = lurek.effect.newEffect("crt")
        local chromatic = lurek.effect.newEffect("chromatic")
        local grade = lurek.effect.newEffect("colourgrade")

        stack:add(blur)
        stack:add(bloom)
        stack:add(crt)
        stack:add(chromatic)
        stack:add(grade)

        local frames = {}
        for i = 1, 14 do
            local t = (i - 1) / 13.0
            blur:setRadius(1.0 + t * 9.0)
            bloom:setThreshold(0.20 + t * 0.62)
            bloom:setIntensity(0.35 + t * 1.45)
            crt:setScanlineStrength(0.10 + t * 0.75)
            chromatic:setOffset(0.02 + t * 0.26)
            grade:setBrightness(0.82 + t * 0.36)
            grade:setContrast(0.78 + t * 0.54)
            grade:setSaturation(0.58 + t * 0.82)
            stack:setEnabled(3, i < 6 or i > 10)
            stack:setFeedback(t)
            frames[i] = draw_stack_pipeline_frame(stack, i, 640, 160)
        end

        save_gif(frames, OUT .. "effect_stack_pipeline.gif", { delayMs = 85, speed = 10 })
    end)

    -- Does: Creates an image-effect chain and renders each chain pass with its parameter bars.
    -- Shows: The PNG demonstrates local image-effect composition separately from global stack capture.
    -- Artifact: tests/artifacts/current/effect/effect_image_chain_parameters.png
    -- Why: This belongs to lurek.effect because the chain entries and parameter values come from lurek.effect.newImageEffect and LImageEffect/LPostFxEffect methods.
    it("PNG: image effect chain parameters", function()
        local chain = lurek.effect.newImageEffect({
            { type = "blur", radius = 6.0, strength = 0.75 },
            { type = "bloom", threshold = 0.62, intensity = 1.35 },
            { type = "colourgrade", brightness = 1.15, contrast = 1.28, saturation = 1.42 },
        })
        local img = draw_image_chain(chain, 410, 145)
        save_png(img, OUT .. "effect_image_chain_parameters.png")
    end)

    -- Does: Exports stack mutation, capture, preset, and image-chain values as exact structured evidence.
    -- Shows: The JSON records the precise order, dedup/remove result, enabled passes, capture lifecycle, preset size, and image-chain effect values behind the visual evidence.
    -- Artifact: tests/artifacts/current/effect/effect_stack_state.json, tests/artifacts/current/effect/effect_capture_preset_state.json, tests/artifacts/current/effect/effect_image_chain_state.json
    -- Why: These traces are secondary evidence for effect logic that is hard to read from pixels alone, while the primary PNG/GIF artifacts explain the module visually.
    it("JSON: effect stack and chain state traces", function()
        local stack = lurek.effect.newStack(320, 180)
        local blur = lurek.effect.newEffect("blur")
        local bloom = lurek.effect.newEffect("bloom")
        local crt = lurek.effect.newEffect("crt")
        stack:add(bloom)
        stack:insert(1, blur)
        stack:add(crt)
        stack:add(blur)
        local removed = stack:dedup()
        stack:setEnabled(2, false)
        stack:remove(crt)

        local enabled = stack:getEnabledEffects()
        local effect1 = stack:getEffect(1)
        local effect2 = stack:getEffect(2)
        write_text(
            OUT .. "effect_stack_state.json",
            string.format(
                '{"count":%d,"removed":%d,"first":"%s","second":"%s","enabled_count":%d,"enabled_first":"%s"}',
                stack:getEffectCount(),
                removed,
                effect1:getTypeName(),
                effect2:getTypeName(),
                #enabled,
                enabled[1] and enabled[1]:getTypeName() or "nil"
            )
        )

        local preset = lurek.effect.newPresetStack("retro_tv", 256, 144)
        local before = preset:isCapturing()
        preset:beginCapture()
        local during = preset:isCapturing()
        preset:apply()
        preset:endCapture()
        local after = preset:isCapturing()
        local preset_names = lurek.effect.getPresetNames()
        write_text(
            OUT .. "effect_capture_preset_state.json",
            string.format(
                '{"before":%s,"during":%s,"after":%s,"width":%d,"height":%d,"effect_count":%d,"preset_count":%d}',
                tostring(before),
                tostring(during),
                tostring(after),
                preset:getWidth(),
                preset:getHeight(),
                preset:getEffectCount(),
                #preset_names
            )
        )

        local image_effect = lurek.effect.newImageEffect({
            { type = "blur", radius = 3.0, strength = 0.5 },
            { type = "bloom", threshold = 0.7, intensity = 1.2 },
        })
        local first = image_effect:getEffect(1)
        local second = image_effect:getEffect(2)
        write_text(
            OUT .. "effect_image_chain_state.json",
            string.format(
                '{"count":%d,"first":"%s","second":"%s","first_radius":%.2f,"second_intensity":%.2f}',
                image_effect:getEffectCount(),
                first:getType(),
                second:getType(),
                first:getParameter("radius", 0.0),
                second:getParameter("intensity", 0.0)
            )
        )
    end)

    -- Does: Sweeps key parameters for blur, bloom, CRT, chromatic, colourgrade, and vignette into response-curve strips.
    -- Shows: The PNG makes effect instances visible as typed post-process controls with different parameter vocabularies and magnitudes.
    -- Artifact: tests/artifacts/current/effect/effect_parameter_response_curves.png
    -- Why: This is effect-owned evidence because every curve is driven by LPostFxEffect parameter setters/getters for built-in post-fx types.
    it("PNG: parameter response curves", function()
        local specs = {
            { name = "blur", param = "radius", setter = "setRadius", max = 12.0 },
            { name = "bloom", param = "intensity", setter = "setIntensity", max = 2.0 },
            { name = "crt", param = "scanline_strength", setter = "setScanlineStrength", max = 0.9 },
            { name = "chromatic", param = "offset", setter = "setOffset", max = 0.38 },
            { name = "colourgrade", param = "saturation", setter = "setSaturation", max = 1.8 },
            { name = "vignette", param = "strength", setter = "setStrength", max = 1.0 },
        }
        local img = lurek.image.newImageData(520, 230)
        img:fill(11, 14, 23, 255)
        for row, spec in ipairs(specs) do
            local effect = lurek.effect.newEffect(spec.name)
            local color = effect_color(spec.name)
            local y = 14 + (row - 1) * 34
            img:drawRect(18, y, 482, 24, 24, 28, 40, 255)
            for step = 1, 12 do
                local v = (step - 1) / 11 * spec.max
                effect[spec.setter](effect, v)
                local norm = normalize_parameter(spec.param, effect:getParameter(spec.param, 0.0))
                local x = 30 + (step - 1) * 38
                local h = math.max(2, math.floor(18 * norm))
                img:drawRect(x, y + 20 - h, 24, h, color[1], color[2], color[3], 255)
            end
            draw_outline(img, 18, y, 482, 24, color[1], color[2], color[3])
        end
        save_png(img, OUT .. "effect_parameter_response_curves.png")
    end)

    -- Does: Creates several named preset stacks and renders their pass counts, ordering, enabled state, and target dimensions as a contact sheet.
    -- Shows: The PNG exposes presets as reusable post-fx recipes, not one-off arbitrary graphics.
    -- Artifact: tests/artifacts/current/effect/effect_preset_stack_contact_sheet.png
    -- Why: This belongs to lurek.effect because each strip is produced from getPresetNames and newPresetStack stack metadata.
    it("PNG: preset stack contact sheet", function()
        local names = lurek.effect.getPresetNames()
        local img = lurek.image.newImageData(560, 210)
        img:fill(10, 13, 22, 255)
        for i = 1, math.min(5, #names) do
            local stack = lurek.effect.newPresetStack(names[i], 320 + i * 16, 180 + i * 8)
            stack:setFeedback((i - 1) / 5)
            local y = 12 + (i - 1) * 38
            draw_stack_strip(img, stack, 18, y, 430, 30)
            img:drawRect(462, y + 5, math.max(2, stack:getEffectCount() * 14), 8, 120, 190, 255, 255)
            img:drawRect(462, y + 18, math.max(2, math.floor(stack:getFeedback() * 70)), 7, 255, 180, 90, 255)
        end
        save_png(img, OUT .. "effect_preset_stack_contact_sheet.png")
    end)

    -- Does: Builds a stack with duplicate passes, disables individual stack slots and effect handles, dedups it, then renders before/after matrices.
    -- Shows: The PNG focuses on effect-stack ownership: pass order, duplicate removal, and two layers of enabled state.
    -- Artifact: tests/artifacts/current/effect/effect_enable_dedup_matrix.png
    -- Why: This is effect evidence because it visualizes LPostFxStack:add/insert/setEnabled/dedup and LPostFxEffect:setEnabled behavior.
    it("PNG: enabled state and dedup matrix", function()
        local blur = lurek.effect.newEffect("blur")
        local bloom = lurek.effect.newEffect("bloom")
        local crt = lurek.effect.newEffect("crt")
        local chroma = lurek.effect.newEffect("chromatic")
        local before = lurek.effect.newStack(420, 120)
        before:add(blur)
        before:add(bloom)
        before:add(blur)
        before:add(crt)
        before:add(chroma)
        before:setEnabled(2, false)
        crt:setEnabled(false)

        local after = lurek.effect.newStack(420, 120)
        after:add(blur)
        after:add(bloom)
        after:add(blur)
        after:add(crt)
        after:add(chroma)
        after:setEnabled(2, false)
        crt:setEnabled(false)
        after:dedup()

        local img = lurek.image.newImageData(500, 145)
        img:fill(12, 15, 24, 255)
        draw_stack_strip(img, before, 18, 18, 462, 44)
        draw_stack_strip(img, after, 18, 82, 462, 44)
        save_png(img, OUT .. "effect_enable_dedup_matrix.png")
    end)

    -- Does: Creates custom shader-backed passes, toggles automatic uniforms, sets custom parameters, and renders their pass map.
    -- Shows: The PNG demonstrates the module's custom post-fx pass path separately from built-in effect types.
    -- Artifact: tests/artifacts/current/effect/effect_custom_shader_pass_map.png
    -- Why: It proves lurek.effect.newPass/newCustomEffect plus LPostFxEffect auto-uniform and parameter APIs are represented visually.
    it("PNG: custom shader pass map", function()
        local shader = lurek.render.newShader(minimal_shader_code(), { target = "postfx" })
        local pass_a = lurek.effect.newPass(shader)
        local pass_b = lurek.effect.newCustomEffect(shader)
        pass_a:enableAutoUniforms()
        pass_a:setParameter("time_scale", 0.75)
        pass_a:setParameter("stack_mix", 0.35)
        pass_b:disableAutoUniforms()
        pass_b:setParameter("manual_mix", 0.9)

        local stack = lurek.effect.newStack(320, 180)
        stack:add(pass_a)
        stack:add(lurek.effect.newEffect("bloom"))
        stack:add(pass_b)
        stack:setFeedback(0.42)

        local img = lurek.image.newImageData(430, 145)
        img:fill(10, 13, 22, 255)
        draw_stack_strip(img, stack, 20, 20, 390, 42)
        local auto_alpha = pass_a:isAutoUniforms() and 255 or 70
        local manual_alpha = pass_b:isAutoUniforms() and 255 or 70
        img:drawRect(42, 86, 120, 16, 90, 170, 255, auto_alpha)
        img:drawRect(224, 86, 120, 16, 255, 120, 150, manual_alpha)
        img:drawRect(42, 112, math.floor(120 * pass_a:getParameter("time_scale", 0.0)), 8, 90, 170, 255, 255)
        img:drawRect(224, 112, math.floor(120 * pass_b:getParameter("manual_mix", 0.0)), 8, 255, 120, 150, 255)
        save_png(img, OUT .. "effect_custom_shader_pass_map.png")
    end)

    -- Does: Animates two stacks with the same effects in different pass order while parameter magnitudes change over time.
    -- Shows: The GIF makes effect composition order visible as a pipeline decision owned by the effect module.
    -- Artifact: tests/artifacts/current/effect/effect_stack_order_lookbook.gif
    -- Why: This is effect-specific because the frames are generated from LPostFxStack ordering, pass toggles, feedback, and LPostFxEffect parameter state.
    it("GIF: stack order lookbook", function()
        local frames = {}
        for frame = 1, 14 do
            local t = (frame - 1) / 13
            local stack_a = lurek.effect.newStack(480, 160)
            local stack_b = lurek.effect.newStack(480, 160)
            local blur_a = lurek.effect.newEffect("blur")
            local bloom_a = lurek.effect.newEffect("bloom")
            local grade_a = lurek.effect.newEffect("colourgrade")
            local blur_b = lurek.effect.newEffect("blur")
            local bloom_b = lurek.effect.newEffect("bloom")
            local grade_b = lurek.effect.newEffect("colourgrade")
            blur_a:setRadius(2 + t * 8)
            blur_b:setRadius(2 + t * 8)
            bloom_a:setIntensity(0.4 + t * 1.3)
            bloom_b:setIntensity(0.4 + t * 1.3)
            grade_a:setSaturation(0.7 + t * 0.9)
            grade_b:setSaturation(0.7 + t * 0.9)
            stack_a:add(blur_a)
            stack_a:add(bloom_a)
            stack_a:add(grade_a)
            stack_b:add(grade_b)
            stack_b:add(bloom_b)
            stack_b:add(blur_b)
            stack_a:setFeedback(t)
            stack_b:setFeedback(1 - t)
            local img = lurek.image.newImageData(520, 142)
            img:fill(10, 13, 22, 255)
            draw_stack_strip(img, stack_a, 22, 20, 476, 42)
            draw_stack_strip(img, stack_b, 22, 82, 476, 42)
            frames[frame] = img
        end
        save_gif(frames, OUT .. "effect_stack_order_lookbook.gif", { delayMs = 85, speed = 10 })
    end)
end)

test_summary()
