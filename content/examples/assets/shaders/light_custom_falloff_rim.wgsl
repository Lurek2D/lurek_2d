@fragment
fn fs_main(
    @location(0) base_color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) world_pos: vec2<f32>,
    @location(3) light_pos: vec2<f32>,
    @location(4) normal_hint: vec2<f32>,
    @location(5) distance_norm: f32,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) shadow_factor: f32,
    @location(9) ambient_color: vec4<f32>,
    @location(10) direction_spot: vec4<f32>,
) -> @location(0) vec4<f32> {
    let rim = smoothstep(0.55, 1.0, distance_norm);
    let falloff = pow(max(1.0 - distance_norm, 0.0), 1.8);
    let normal_boost = 0.5 + 0.5 * dot(normalize(world_pos - light_pos + vec2<f32>(0.001)), normalize(normal_hint + vec2<f32>(0.001)));
    let facing = 0.8 + 0.2 * max(dot(normalize(world_pos - light_pos + vec2<f32>(0.001)), direction_spot.xy), 0.0);
    let lit = base_color.rgb * (falloff + rim * 0.35) * intensity * normal_boost * shadow_factor * facing;
    return vec4<f32>(lit + ambient_color.rgb * 0.05, base_color.a + radius * 0.0 + uv.x * 0.0);
}
