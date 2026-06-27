@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
) -> @location(0) vec4<f32> {
    let warm = vec3<f32>(1.0, 0.72, 0.38);
    let cool = vec3<f32>(0.25, 0.65, 1.0);
    let ramp = smoothstep(0.2, 0.9, dot(color.rgb, vec3<f32>(0.333)));
    return vec4<f32>(mix(cool, warm, ramp) * color.a, color.a + uv.x * 0.0);
}
