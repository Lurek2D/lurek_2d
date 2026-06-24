//! Provides tilemap projection transforms for isometric and hex render layouts.
//! Converts between tile/grid coordinates and screen space for storage-to-render adapters.
//! Keeps orientation-specific projection math out of map storage while avoiding gameplay topology ownership.
//! Does not provide navigation, range, neighbor, line, ring, or visibility algorithms.
//! Open this file when tilemap projection between tile coordinates and screen coordinates is wrong.

use crate::math::Vec2;

/// Convert tile coordinates `(tx, ty)` to isometric screen position for a tile of `tile_w` by `tile_h` pixels.
pub fn to_screen_iso(tx: f32, ty: f32, tile_w: f32, tile_h: f32) -> Vec2 {
    Vec2::new((tx - ty) * tile_w / 2.0, (tx + ty) * tile_h / 2.0)
}

/// Convert isometric screen position `(sx, sy)` back to tile coordinates for a tile of `tile_w` by `tile_h` pixels.
pub fn from_screen_iso(sx: f32, sy: f32, tile_w: f32, tile_h: f32) -> Vec2 {
    let tx = (sx / tile_w * 2.0 + sy / tile_h * 2.0) / 2.0;
    let ty = (sy / tile_h * 2.0 - sx / tile_w * 2.0) / 2.0;
    Vec2::new(tx, ty)
}

/// Convert hex axial coordinates `(q, r)` to flat-top screen position for a hex of the given `size`.
pub fn to_screen_hex(q: i32, r: i32, size: f32) -> Vec2 {
    let x = size * 3.0_f32.sqrt() * (q as f32 + r as f32 / 2.0);
    let y = size * 1.5 * r as f32;
    Vec2::new(x, y)
}

/// Convert screen position `(sx, sy)` to flat-top hex axial coordinates for a hex of the given `size`.
pub fn from_screen_hex(sx: f32, sy: f32, size: f32) -> (i32, i32) {
    let q = (sx * 3.0_f32.sqrt() / 3.0 - sy / 3.0) / size;
    let r = sy * 2.0 / 3.0 / size;
    round_axial_hex(q, r)
}

fn round_axial_hex(q: f32, r: f32) -> (i32, i32) {
    let s = -q - r;
    let mut rq = q.round();
    let mut rr = r.round();
    let rs = s.round();
    let dq = (rq - q).abs();
    let dr = (rr - r).abs();
    let ds = (rs - s).abs();
    if dq > dr && dq > ds {
        rq = -rr - rs;
    } else if dr > ds {
        rr = -rq - rs;
    }
    (rq as i32, rr as i32)
}
