@fragment
fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
) -> @location(0) vec4<f32> {
    let levels = vec3<f32>(4.0, 6.0, 4.0);
    let remapped = floor(color.rgb * levels) / levels;
    let vignette = smoothstep(0.8, 0.1, length(uv - vec2<f32>(0.5, 0.5)));
    let grid = step(0.98, fract((pixel.x + pixel.y) * texel.x * resolution.x));
    return vec4<f32>(mix(remapped, color.rgb, 0.25) * max(vignette, 0.35) + grid * 0.015, color.a);
}
