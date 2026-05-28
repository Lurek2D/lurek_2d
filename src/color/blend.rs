//! Colour blending helpers: linear interpolation and compositing operations.
//!
//! - Functions: `lerp_color`, `multiply`, `screen`, `overlay`, and 2 more.
//! - Contains 1 method implementation.

use super::color_core::Color;

/// Linearly interpolate between two colors by factor `t` (clamped to [0, 1]).
pub fn lerp_color(a: &Color, b: &Color, t: f32) -> Color {
    let t = t.clamp(0.0, 1.0);
    Color {
        r: a.r + (b.r - a.r) * t,
        g: a.g + (b.g - a.g) * t,
        b: a.b + (b.b - a.b) * t,
        a: a.a + (b.a - a.a) * t,
    }
}

/// Channel-wise multiply blend: each output channel = a * b.
pub fn multiply(a: &Color, b: &Color) -> Color {
    Color {
        r: a.r * b.r,
        g: a.g * b.g,
        b: a.b * b.b,
        a: a.a * b.a,
    }
}

/// Screen blend: output = 1 - (1 - a) * (1 - b) per channel.
pub fn screen(a: &Color, b: &Color) -> Color {
    Color {
        r: 1.0 - (1.0 - a.r) * (1.0 - b.r),
        g: 1.0 - (1.0 - a.g) * (1.0 - b.g),
        b: 1.0 - (1.0 - a.b) * (1.0 - b.b),
        a: 1.0 - (1.0 - a.a) * (1.0 - b.a),
    }
}

/// Photoshop-style overlay blend per channel.
///
/// If base < 0.5: 2 * base * blend, otherwise: 1 - 2 * (1-base) * (1-blend).
pub fn overlay(base: &Color, blend: &Color) -> Color {
    fn overlay_ch(base: f32, blend: f32) -> f32 {
        if base < 0.5 {
            2.0 * base * blend
        } else {
            1.0 - 2.0 * (1.0 - base) * (1.0 - blend)
        }
    }
    Color {
        r: overlay_ch(base.r, blend.r),
        g: overlay_ch(base.g, blend.g),
        b: overlay_ch(base.b, blend.b),
        a: overlay_ch(base.a, blend.a),
    }
}

/// Additive blend: clamp(a + b, 0, 1) per channel.
pub fn additive(a: &Color, b: &Color) -> Color {
    Color {
        r: (a.r + b.r).min(1.0),
        g: (a.g + b.g).min(1.0),
        b: (a.b + b.b).min(1.0),
        a: (a.a + b.a).min(1.0),
    }
}

/// Standard alpha compositing (Porter-Duff "over" operator).
///
/// Composites `fg` over `bg` using `fg.a` as the foreground opacity.
pub fn alpha_blend(fg: &Color, bg: &Color) -> Color {
    let fa = fg.a;
    let ba = bg.a * (1.0 - fa);
    let out_a = fa + ba;
    if out_a < 1e-7 {
        return Color::TRANSPARENT;
    }
    Color {
        r: (fg.r * fa + bg.r * ba) / out_a,
        g: (fg.g * fa + bg.g * ba) / out_a,
        b: (fg.b * fa + bg.b * ba) / out_a,
        a: out_a,
    }
}
