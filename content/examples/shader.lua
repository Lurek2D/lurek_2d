-- Lurek2D shader API examples.

--@api: lurek.shader.new
do
    local code = [[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(uv, 1.0), color.a);
}
]]
    local shader = lurek.shader.new(code, { target = "draw" })
    local shader_id = shader:getId()
    local target = shader:getTarget()
    local diagnostics = shader:getDiagnostics()
    shader:send("tint_amount", 0.5)
    local has_uniform = shader:hasUniform("tint_amount")
    local still_live = shader_id > 0 and target == "draw" and diagnostics[1] ~= nil and has_uniform
end
