@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    _ = uv;
    let scan = select(0.82, 1.0, (i32(pixel.y) & 1) == 0);
    let vignette_uv = (pixel / max(resolution, vec2<f32>(1.0, 1.0))) * 2.0 - vec2<f32>(1.0, 1.0);
    let edge = clamp(1.0 - dot(vignette_uv, vignette_uv) * 0.22, 0.55, 1.0);
    let glow = vec3<f32>(0.04, 0.12, 0.10) * (1.0 - texel.y);
    return vec4<f32>(color.rgb * scan * edge + glow * color.a, color.a);
}
