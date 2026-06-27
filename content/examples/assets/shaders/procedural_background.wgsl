@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let bands = 0.5 + 0.5 * sin((uv.x * 8.0 + uv.y * 5.0) * 6.28318);
    let grid = step(0.96, fract(pixel.x * texel.x * 20.0)) + step(0.96, fract(pixel.y * texel.y * 20.0));
    let bg = mix(vec3<f32>(0.05, 0.08, 0.11), vec3<f32>(0.1, 0.2, 0.24), bands);
    return vec4<f32>(mix(bg, color.rgb, color.a) + grid * 0.025, 1.0 + resolution.x * 0.0);
}
