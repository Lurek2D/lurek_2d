//! Computes visible tile positions for repeating parallax layers inside a screen rect and cull margin. `parallax/tile_iter` delivers the tile iter implementation for the parallax subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Walks one axis at a time and combines X and Y into a full grid with bounded growth. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Emits only the single origin position for non-repeating layers. Public callable behavior is centered on `collect_tiled_positions`, while method-level behavior such as no named public items stays attached to the local data model and invariants.

/// Fraction of a tile width/height added on each side of the screen as a visibility margin.
const CULL_MARGIN_TILES: f32 = 1.5;
/// Hard cap on the total number of tile positions returned per call.
const MAX_TILED_POSITIONS: usize = 16_384;
/// Return all `(x, y)` tile positions visible inside `screen_size` plus the cull margin; capped at `MAX_TILED_POSITIONS`.
pub fn collect_tiled_positions(
    start_x: f32,
    start_y: f32,
    step_x: f32,
    step_y: f32,
    repeat_x: bool,
    repeat_y: bool,
    screen_size: [f32; 2],
) -> Vec<(f32, f32)> {
    let [screen_w, screen_h] = screen_size;
    let margin_x = step_x.abs() * CULL_MARGIN_TILES;
    let margin_y = step_y.abs() * CULL_MARGIN_TILES;
    let min_x = -margin_x;
    let max_x = screen_w + margin_x;
    let min_y = -margin_y;
    let max_y = screen_h + margin_y;
    let x_values = axis_positions(start_x, step_x, repeat_x, min_x, max_x);
    let y_values = axis_positions(start_y, step_y, repeat_y, min_y, max_y);
    let mut out = Vec::with_capacity((x_values.len() * y_values.len()).min(MAX_TILED_POSITIONS));
    for &x in &x_values {
        for &y in &y_values {
            out.push((x, y));
            if out.len() >= MAX_TILED_POSITIONS {
                return out;
            }
        }
    }
    out
}
/// Return all positions along one axis from `start` with `step` spacing that fall in `[min_v, max_v]`; returns `[start]` when non-repeating.
fn axis_positions(start: f32, step: f32, repeat: bool, min_v: f32, max_v: f32) -> Vec<f32> {
    if !repeat || step <= 0.0 {
        return vec![start];
    }
    let mut values = Vec::new();
    let mut cur = start;
    while cur > min_v {
        cur -= step;
    }
    while cur + step < min_v {
        cur += step;
    }
    while cur <= max_v {
        values.push(cur);
        if values.len() >= MAX_TILED_POSITIONS {
            break;
        }
        cur += step;
    }
    if values.is_empty() {
        values.push(start);
    }
    values
}
