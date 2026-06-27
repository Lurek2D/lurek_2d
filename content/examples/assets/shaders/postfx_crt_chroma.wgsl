@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let scan = 0.85 + 0.15 * sin(pixel.y * 3.14159);
    let chroma = vec3<f32>(color.r + texel.x * resolution.x * 0.001, color.g, color.b - texel.y * resolution.y * 0.001);
    let curve = 1.0 - dot(uv - 0.5, uv - 0.5) * 0.35;
    return vec4<f32>(chroma * scan * curve, color.a);
}
