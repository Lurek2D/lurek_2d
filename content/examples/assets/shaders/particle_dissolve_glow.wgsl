@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
    @location(3) world_pos: vec2<f32>,
    @location(4) velocity: vec2<f32>,
    @location(5) age: f32,
    @location(6) lifetime: f32,
    @location(7) seed: f32,
    @location(8) sampled_color: vec4<f32>,
) -> @location(0) vec4<f32> {
    let radial = 1.0 - smoothstep(0.2, 0.75, length(uv - vec2<f32>(0.5, 0.5)));
    let speed = min(length(velocity) * 0.02, 1.0);
    let noise = fract(sin(dot(local_pos + world_pos + seed, vec2<f32>(12.9898, 78.233))) * 43758.5453);
    let dissolve = step(age * 0.85, noise);
    let glow = vec3<f32>(1.0, 0.55 + speed, 0.18) * radial;
    return vec4<f32>(max(sampled_color.rgb, glow), sampled_color.a * color.a * dissolve * max(0.0, lifetime));
}
