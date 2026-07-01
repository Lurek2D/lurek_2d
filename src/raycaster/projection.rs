//! Owns wall-column projection math and distance-based shading for the raycaster renderer.
//! Converts corrected ray distances into screen-space wall heights and brightness multipliers.
//! Open this file when wall projection math changes; hit records and sprite payloads live in sibling files.

use super::contract::{ProjectionParams, RaycasterError, RaycasterLimits};

/// Project a wall column at `distance` using `fov` and `screen_height`.
/// Return `(wall_height, draw_start_y, draw_end_y)` in screen pixels.
pub fn project_column(distance: f32, fov: f32, screen_height: f32) -> (f32, f32, f32) {
    match try_project_column(distance, fov, screen_height) {
        Ok(projected) => projected,
        Err(_) => {
            let screen_height = if screen_height.is_finite() {
                screen_height.max(0.0)
            } else {
                0.0
            };
            (screen_height, 0.0, screen_height)
        }
    }
}

/// Project a validated wall column, returning an error instead of NaN/Inf on invalid input.
pub fn try_project_column(
    distance: f32,
    fov: f32,
    screen_height: f32,
) -> Result<(f32, f32, f32), RaycasterError> {
    ProjectionParams {
        distance,
        fov,
        screen_height,
    }
    .validate(&RaycasterLimits::default())?;
    if distance <= 0.0 {
        return Ok((screen_height, 0.0, screen_height));
    }
    let wall_height = screen_height / (distance * (fov / 2.0).tan());
    let draw_start = (screen_height - wall_height) / 2.0;
    let draw_end = draw_start + wall_height;
    Ok((
        wall_height,
        draw_start.max(0.0),
        draw_end.min(screen_height),
    ))
}

/// Return a brightness multiplier 0.0..1.0 based on `distance` relative to `max_distance`.
pub fn distance_shade(distance: f32, max_distance: f32) -> f32 {
    if max_distance <= 0.0 {
        return 0.0;
    }
    (1.0 - distance / max_distance).clamp(0.0, 1.0)
}
