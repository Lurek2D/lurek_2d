@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let center = vec2<f32>(0.5, 0.5);
    let reveal = 1.0 - smoothstep(0.18, 0.46, length(uv - center));
    let fog = vec3<f32>(0.02, 0.025, 0.04);
    return vec4<f32>(mix(fog, color.rgb, reveal), color.a + pixel.x * 0.0 + resolution.x * texel.x * 0.0);
}
