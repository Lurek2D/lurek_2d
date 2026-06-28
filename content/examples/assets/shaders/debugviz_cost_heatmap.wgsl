@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    _ = uv;
    _ = texel;
    let normalized_x = pixel.x / max(resolution.x, 1.0);
    let hot = vec3<f32>(1.0, 0.18, 0.05);
    let cold = vec3<f32>(0.05, 0.35, 1.0);
    let heat = mix(cold, hot, clamp(normalized_x, 0.0, 1.0));
    return vec4<f32>(mix(color.rgb, heat, 0.55), color.a);
}
