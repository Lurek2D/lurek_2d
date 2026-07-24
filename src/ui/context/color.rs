//! Implements color conversion and interpolation helpers used when GuiContext updates retained widget state.
//! Helpers normalize finite channels and preserve the UI 0..1 color convention before rendering reads widget values.
//! Theme ownership and paint selection remain in theme and render; this file supplies only context-local transforms.

use super::*;

impl GuiContext {
    /// Converts normalized HSV components into normalized RGB components.
    pub(super) fn hsv_to_rgb_unit(hue: f32, saturation: f32, value: f32) -> (f32, f32, f32) {
        let hue = hue.rem_euclid(1.0) * 6.0;
        let sector = hue.floor() as i32;
        let sector_fraction = hue - sector as f32;
        let p_component = value * (1.0 - saturation);
        let q_component = value * (1.0 - saturation * sector_fraction);
        let t_component = value * (1.0 - saturation * (1.0 - sector_fraction));
        match sector {
            0 => (value, t_component, p_component),
            1 => (q_component, value, p_component),
            2 => (p_component, value, t_component),
            3 => (p_component, q_component, value),
            4 => (t_component, p_component, value),
            _ => (value, p_component, q_component),
        }
    }

    /// Converts normalized RGB components into normalized HSV components.
    pub(super) fn rgb_to_hsv_unit(red: f32, green: f32, blue: f32) -> (f32, f32, f32) {
        let max_component = red.max(green).max(blue);
        let min_component = red.min(green).min(blue);
        let delta = max_component - min_component;
        let hue = if delta <= f32::EPSILON {
            0.0
        } else if (max_component - red).abs() <= f32::EPSILON {
            ((green - blue) / delta / 6.0).rem_euclid(1.0)
        } else if (max_component - green).abs() <= f32::EPSILON {
            ((blue - red) / delta + 2.0) / 6.0
        } else {
            ((red - green) / delta + 4.0) / 6.0
        };
        let saturation = if max_component <= f32::EPSILON {
            0.0
        } else {
            delta / max_component
        };
        (hue, saturation, max_component)
    }
}
