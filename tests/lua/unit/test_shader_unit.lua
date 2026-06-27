-- Shader API unit tests.

-- @describe lurek.shader module
describe("lurek.shader module", function()
    -- @covers lurek.shader.new
    it("new compiles target-aware WGSL shaders", function()
        local draw_code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + vec3<f32>(uv, 0.0), color.a);
}
]]
        local shader = lurek.shader.new(draw_code, { target = "draw" })
        expect_type("userdata", shader)
        expect_equal("draw", shader:getTarget())
        expect_true(shader:getId() > 0)
        shader:send("amount", 0.25)
        expect_true(shader:hasUniform("amount"))
        local diagnostics = shader:getDiagnostics()
        expect_true(#diagnostics >= 1)
    end)

    -- @covers LShader:getTarget
    it("getTarget reports the validated shader family", function()
        local postfx_code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) pixel: vec2<f32>, @location(3) resolution: vec2<f32>, @location(4) texel: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + texel.xyx * resolution.x * 0.001 + pixel.xyx * 0.0 + uv.xyx * 0.0, color.a);
}
]]
        local shader = lurek.shader.new(postfx_code, { target = "postfx" })
        expect_equal("postfx", shader:getTarget())
        local ok, err = pcall(function()
            lurek.effect.newCustomEffect(lurek.shader.new(postfx_code, { target = "image" }))
        end)
        expect_equal(false, ok)
        expect_true(string.find(tostring(err), "postfx shader") ~= nil)
    end)

    -- @covers LShader:getDiagnostics
    it("getDiagnostics returns validation notes", function()
        local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return color + vec4<f32>(uv, 0.0, 0.0);
}
]]
        local shader = lurek.shader.new(code, { target = "draw" })
        local diagnostics = shader:getDiagnostics()
        expect_type("table", diagnostics)
        expect_true(#diagnostics >= 1)
        expect_true(string.find(diagnostics[1], "draw") ~= nil)
    end)
end)

test_summary()
