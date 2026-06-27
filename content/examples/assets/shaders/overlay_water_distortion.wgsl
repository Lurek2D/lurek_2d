@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let ripple = sin((uv.x + uv.y) * 80.0) * 0.02;
    let tint = vec3<f32>(0.78, 0.92, 1.08);
    return vec4<f32>(color.rgb * tint + ripple * texel.x * resolution.x, color.a);
}
