@fragment
fn fs(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>
) -> @location(0) vec4<f32> {
    let progress = 0.52;
    let feather = max(texel.x * 24.0, 0.015);
    let diagonal = (uv.x + uv.y) * 0.5;
    let wipe = smoothstep(progress - feather, progress + feather, diagonal);
    let dissolve_noise = fract(sin(dot(pixel, vec2<f32>(12.9898, 78.233))) * 43758.5453);
    let dissolve = step(progress, dissolve_noise);
    let fade_mask = min(wipe, dissolve);
    let transition_tint = vec3<f32>(0.08, 0.10, 0.14) + resolution.xyx * 0.0;
    return vec4<f32>(mix(color.rgb, transition_tint, fade_mask), color.a);
}
