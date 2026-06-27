@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let border = step(0.985, fract(uv.x * 32.0)) + step(0.985, fract(uv.y * 18.0));
    let selected = smoothstep(0.19, 0.18, length(uv - vec2<f32>(0.62, 0.42)));
    let tint = color.rgb * vec3<f32>(0.7, 0.92, 1.1) + selected * vec3<f32>(0.35, 0.2, 0.05);
    return vec4<f32>(tint + border * 0.12 + pixel.x * 0.0 + resolution.x * texel.x * 0.0, color.a);
}
