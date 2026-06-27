@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let wave = sin((uv.y * resolution.y + pixel.x * 0.15) * 0.05) * 0.025;
    return vec4<f32>(color.rg + vec2<f32>(wave, -wave) * texel.y * resolution.y, color.b, color.a);
}
