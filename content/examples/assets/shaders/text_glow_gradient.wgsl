@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let band = 0.5 + 0.5 * sin((uv.y + pixel.y * texel.y) * 18.0);
    let glow = smoothstep(0.05, 0.8, color.a);
    let tint = mix(vec3<f32>(0.4, 0.8, 1.0), vec3<f32>(1.0, 0.9, 0.35), band);
    return vec4<f32>(color.rgb * tint + glow * 0.08 + resolution.xyx * 0.0, color.a);
}
