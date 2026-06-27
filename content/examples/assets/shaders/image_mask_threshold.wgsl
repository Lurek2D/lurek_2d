@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let luma = dot(color.rgb, vec3<f32>(0.299, 0.587, 0.114));
    let edge_mask = step(1.0, pixel.x) * step(1.0, pixel.y) * step(pixel.x, resolution.x - 2.0) * step(pixel.y, resolution.y - 2.0);
    let alpha = step(0.5, luma) * edge_mask;
    return vec4<f32>(vec3<f32>(alpha), alpha * color.a + texel.x * 0.0 + uv.x * 0.0);
}
