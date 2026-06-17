//! Narrow-phase collision detection for tilemap movement using swept AABB-vs-AABB testing with separating-axis theorem implementation.
//! Computes continuous time-of-impact values in [0, 1) for moving rectangles against static tile geometry, enabling smooth sliding physics.
//! Returns collision metadata including hit surface normal, contact point, and tile coordinates to support wall-sliding and obstacle interactions.

use super::tilemap::SweepResult;
use crate::math::{Rect, Vec2};

/// Swept AABB-vs-AABB narrow-phase test; returns a `SweepResult` when the expanded target is hit in `[0, 1)`, or `None`.
pub(crate) fn sweep_aabb_vs_aabb(
    mover: Rect,
    dx: f32,
    dy: f32,
    target: Rect,
    tile_x: u32,
    tile_y: u32,
) -> Option<SweepResult> {
    let ex = Rect::new(
        target.x - mover.width,
        target.y - mover.height,
        target.width + mover.width,
        target.height + mover.height,
    );
    let origin_x = mover.x;
    let origin_y = mover.y;
    let (t_near_x, t_far_x) = if dx != 0.0 {
        let inv = 1.0 / dx;
        let t1 = (ex.x - origin_x) * inv;
        let t2 = (ex.x + ex.width - origin_x) * inv;
        if t1 < t2 {
            (t1, t2)
        } else {
            (t2, t1)
        }
    } else {
        if origin_x < ex.x || origin_x >= ex.x + ex.width {
            return None;
        }
        (f32::NEG_INFINITY, f32::INFINITY)
    };
    let (t_near_y, t_far_y) = if dy != 0.0 {
        let inv = 1.0 / dy;
        let t1 = (ex.y - origin_y) * inv;
        let t2 = (ex.y + ex.height - origin_y) * inv;
        if t1 < t2 {
            (t1, t2)
        } else {
            (t2, t1)
        }
    } else {
        if origin_y < ex.y || origin_y >= ex.y + ex.height {
            return None;
        }
        (f32::NEG_INFINITY, f32::INFINITY)
    };
    let t_near = t_near_x.max(t_near_y);
    let t_far = t_far_x.min(t_far_y);
    if t_near >= t_far || t_far <= 0.0 || t_near >= 1.0 {
        return None;
    }
    let t = t_near.max(0.0);
    let normal = if t_near_x > t_near_y {
        Vec2::new(if dx > 0.0 { -1.0 } else { 1.0 }, 0.0)
    } else {
        Vec2::new(0.0, if dy > 0.0 { -1.0 } else { 1.0 })
    };
    let contact = Vec2::new(origin_x + dx * t, origin_y + dy * t);
    Some(SweepResult {
        contact_point: contact,
        normal,
        tile_x,
        tile_y,
        t,
    })
}
