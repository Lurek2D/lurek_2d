@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>
) -> @location(0) vec4<f32> {
    let wet_edge = smoothstep(0.0, 0.35, uv.y);
    let biome_tint = mix(vec3<f32>(0.20, 0.45, 0.25), vec3<f32>(0.25, 0.55, 0.80), wet_edge);
    return vec4<f32>(mix(color.rgb, biome_tint, 0.28), color.a);
}
