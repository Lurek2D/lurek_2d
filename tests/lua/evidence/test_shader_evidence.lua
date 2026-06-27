-- Canonical evidence file for lurek.shader target contracts and shader-bound module APIs.

local OUT = evidence_output_dir("shader")

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

-- @describe Evidence: lurek.shader
describe("Evidence: lurek.shader", function()
    before_each(function()
        ensure_evidence_dir("shader")
    end)

    -- Does: Builds one shader for every public target and binds the target-specific module APIs.
    -- Shows: The text artifact lists validated targets, diagnostics, and bound API ids for image, overlay, particle, effect, and light.
    -- Artifact: tests/artifacts/current/shader/shader_api_contract.txt
    -- Why: This is shader-owned evidence because it proves the cross-module binding contract and records a concrete offline image shader readback.
    it("TXT: shader target and binding contract", function()
        local targets = { "draw", "postfx", "image", "overlay", "particle", "light" }
        local lines = { "Shader API v2 target contract evidence" }
        local shaders = {}

        for _, target in ipairs(targets) do
            local code = target == "image" and image_shader_code() or shader_code()
            local shader = lurek.shader.new(code, { target = target })
            shaders[target] = shader
            local diagnostics = shader:getDiagnostics()
            lines[#lines + 1] = target .. ": id=" .. shader:getId() .. " diagnostics=" .. table.concat(diagnostics, "|")
        end

        local image = lurek.image.newImageData(2, 2)
        image:fill(10, 20, 30, 255)
        local output = image:applyShader(shaders.image)
        lines[#lines + 1] = "image.applyShader=" .. output:getWidth() .. "x" .. output:getHeight()
        local r, g, b, a = output:getPixel(0, 0)
        lines[#lines + 1] = "image.applyShader.pixel=" .. table.concat({ r, g, b, a }, ",")
        local job = lurek.image.requestShader(image, shaders.image)
        lines[#lines + 1] = "image.requestShader.wait=" .. tostring(job:wait(10) ~= nil)

        local fx = lurek.effect.newCustomEffect(shaders.postfx)
        lines[#lines + 1] = "effect.custom=" .. fx:getTypeName()

        local overlay = lurek.overlay.new(64, 64)
        overlay:setShaderLayer("heat_haze", shaders.overlay)
        lines[#lines + 1] = "overlay.layer=" .. overlay:getShaderLayer("heat_haze"):getTarget()
        lines[#lines + 1] = "overlay.plan.shader=" .. table.concat(overlay:getRenderPlan().shader, ",")

        local particles = lurek.particle.newSystem({ maxParticles = 8 })
        particles:setShader(shaders.particle)
        particles:setShaderUniform("glow_amount", 0.5)
        lines[#lines + 1] = "particle.shader=" .. particles:getShader():getTarget()

        lurek.light.setShader(shaders.light)
        local light = lurek.light.newLight(16, 16, 32)
        light:setShader(shaders.light)
        lines[#lines + 1] = "light.world=" .. lurek.light.getShader():getTarget()
        lines[#lines + 1] = "light.instance=" .. light:getShader():getTarget()

        save_text(OUT .. "shader_api_contract.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
