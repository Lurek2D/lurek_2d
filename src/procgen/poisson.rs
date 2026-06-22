//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around poisson_disk, try_poisson_disk, with helpers kept close to their invariants.
//! Defines how poisson data is validated, transformed, or stored before neighboring systems use it.
//! Owns procgen behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on poisson behavior while Lua registration stays elsewhere.

use super::lcg::Lcg;
use crate::procgen::{
    limits::{checked_cell_count, validate_iterations, validate_positive},
    ProcgenError, ProcgenLimits,
};

/// Generate a Poisson disk sample set in a `width × height` rectangle with minimum distance `min_dist`.
///
/// Uses `max_attempts` candidate trials per active point and `seed` for reproducibility.
/// Returns all accepted points as `(x, y)` pairs.
pub fn poisson_disk(
    width: f32,
    height: f32,
    min_dist: f32,
    max_attempts: u32,
    seed: u64,
) -> Vec<(f32, f32)> {
    try_poisson_disk(
        width,
        height,
        min_dist,
        max_attempts,
        seed,
        &ProcgenLimits::default(),
    )
    .expect("poisson_disk received invalid bounds or sampling parameters")
}

/// Generate a Poisson disk sample set after validating bounds, spacing, and grid budgets.
pub fn try_poisson_disk(
    width: f32,
    height: f32,
    min_dist: f32,
    max_attempts: u32,
    seed: u64,
    limits: &ProcgenLimits,
) -> Result<Vec<(f32, f32)>, ProcgenError> {
    use std::f32::consts::PI;
    validate_positive("width", width as f64)?;
    validate_positive("height", height as f64)?;
    validate_positive("min_dist", min_dist as f64)?;
    validate_iterations(max_attempts, limits)?;
    let mut rng = Lcg::new(seed);
    let cell_size = min_dist / std::f32::consts::SQRT_2;
    let grid_w = ((f64::from(width) / f64::from(cell_size)).ceil() + 1.0) as u32;
    let grid_h = ((f64::from(height) / f64::from(cell_size)).ceil() + 1.0) as u32;
    let grid_len = checked_cell_count(grid_w, grid_h, limits)?;
    let grid_w_usize = usize::try_from(grid_w).expect("validated grid width should fit usize");
    let grid_h_usize = usize::try_from(grid_h).expect("validated grid height should fit usize");
    let mut grid: Vec<Option<usize>> = vec![None; grid_len];
    let mut points: Vec<(f32, f32)> = Vec::new();
    let mut active: Vec<usize> = Vec::new();
    let first = (rng.next_f32() * width, rng.next_f32() * height);
    points.push(first);
    active.push(0);
    let gx = (first.0 / cell_size) as usize;
    let gy = (first.1 / cell_size) as usize;
    if gx < grid_w_usize && gy < grid_h_usize {
        grid[gy * grid_w_usize + gx] = Some(0);
    }
    while !active.is_empty() {
        let idx = rng.next_index(active.len());
        let point = points[active[idx]];
        let mut found = false;
        for _ in 0..max_attempts {
            let angle = rng.next_f32() * 2.0 * PI;
            let dist = min_dist + rng.next_f32() * min_dist;
            let nx = point.0 + angle.cos() * dist;
            let ny = point.1 + angle.sin() * dist;
            if nx < 0.0 || ny < 0.0 || nx >= width || ny >= height {
                continue;
            }
            let gx = (nx / cell_size) as usize;
            let gy = (ny / cell_size) as usize;
            let mut too_close = false;
            let search_radius = 2usize;
            for dy in 0..=(search_radius * 2) {
                let cy = (gy + dy).wrapping_sub(search_radius);
                if cy >= grid_h_usize {
                    continue;
                }
                for dx_off in 0..=(search_radius * 2) {
                    let cx = (gx + dx_off).wrapping_sub(search_radius);
                    if cx >= grid_w_usize {
                        continue;
                    }
                    if let Some(pi) = grid[cy * grid_w_usize + cx] {
                        let (qx, qy) = points[pi];
                        let ddx = nx - qx;
                        let ddy = ny - qy;
                        if ddx * ddx + ddy * ddy < min_dist * min_dist {
                            too_close = true;
                            break;
                        }
                    }
                }
                if too_close {
                    break;
                }
            }
            if !too_close {
                let new_idx = points.len();
                points.push((nx, ny));
                active.push(new_idx);
                if gx < grid_w_usize && gy < grid_h_usize {
                    grid[gy * grid_w_usize + gx] = Some(new_idx);
                }
                found = true;
                break;
            }
        }
        if !found {
            active.swap_remove(idx);
        }
    }
    Ok(points)
}
