//! Map mode system for rendering provinces in different colour schemes.
//!
//! A [`MapMode`] determines how each province is coloured when generating a
//! pixel buffer for GPU texture upload. Supports fixed colours, source colours,
//! gradients, and property-based colouring strategies.

use std::collections::HashMap;

use super::core::{Province, ProvinceMap};
use super::properties::ProvinceProperties;

/// A named map mode that determines how provinces are coloured.
#[derive(Debug, Clone)]
pub struct MapMode {
    /// Human-readable name for this map mode.
    pub name: String,
    /// Strategy for computing province colours.
    pub color_fn: MapModeColorFn,
}

/// Strategy for computing province colours in a map mode.
#[derive(Debug, Clone)]
pub enum MapModeColorFn {
    /// Each province has a fixed color assigned directly.
    Fixed(HashMap<u32, [f32; 4]>),
    /// Province's own RGB colour (from the source PNG), normalized to [0,1].
    SourceColor,
    /// Gradient based on a numeric province property value.
    Gradient {
        /// Property key to look up in province properties.
        key: String,
        /// Colour at the minimum end of the gradient.
        min_color: [f32; 4],
        /// Colour at the maximum end of the gradient.
        max_color: [f32; 4],
        /// Minimum property value (maps to `min_color`).
        min_val: f64,
        /// Maximum property value (maps to `max_color`).
        max_val: f64,
    },
    /// Color provinces by a string property value.
    ///
    /// For each province, the property `key` is looked up. The resulting string
    /// value is mapped to a colour via `value_colors`. Provinces with missing
    /// or unmatched values use `default_color`.
    Property {
        /// Property key to look up.
        key: String,
        /// Mapping from property string value to RGBA colour.
        value_colors: HashMap<String, [f32; 4]>,
        /// Fallback colour for provinces without a matching value.
        default_color: [f32; 4],
    },
}

impl MapMode {
    /// Return the RGBA colour for a specific province under this map mode.
    ///
    /// Falls back to a neutral grey `[0.5, 0.5, 0.5, 1.0]` if no colour can
    /// be determined from the current strategy.
    pub fn resolve_color(
        &self,
        province: &Province,
        properties: Option<&ProvinceProperties>,
    ) -> [f32; 4] {
        let fallback = [0.5, 0.5, 0.5, 1.0];
        match &self.color_fn {
            MapModeColorFn::Fixed(colors) => {
                colors.get(&province.id).copied().unwrap_or(fallback)
            }
            MapModeColorFn::SourceColor => [
                province.color[0] as f32 / 255.0,
                province.color[1] as f32 / 255.0,
                province.color[2] as f32 / 255.0,
                1.0,
            ],
            MapModeColorFn::Gradient {
                key,
                min_color,
                max_color,
                min_val,
                max_val,
            } => {
                let val = properties
                    .and_then(|p| p.get_float(key))
                    .unwrap_or(*min_val);
                let range = max_val - min_val;
                let t = if range.abs() < 1e-10 {
                    0.0
                } else {
                    ((val - min_val) / range).clamp(0.0, 1.0) as f32
                };
                [
                    min_color[0] + (max_color[0] - min_color[0]) * t,
                    min_color[1] + (max_color[1] - min_color[1]) * t,
                    min_color[2] + (max_color[2] - min_color[2]) * t,
                    min_color[3] + (max_color[3] - min_color[3]) * t,
                ]
            }
            MapModeColorFn::Property {
                key,
                value_colors,
                default_color,
            } => {
                let val = properties.and_then(|p| p.get_string(key));
                match val {
                    Some(v) => value_colors.get(&v).copied().unwrap_or(*default_color),
                    None => *default_color,
                }
            }
        }
    }
}

/// Generate a full RGBA pixel buffer coloured by the given map mode.
///
/// Returns a `Vec<u8>` of `width * height * 4` bytes in RGBA order, suitable
/// for direct GPU texture upload. Pixels belonging to province ID `0` are set
/// to transparent black `(0, 0, 0, 0)`.
pub fn resolve_colors(
    map: &ProvinceMap,
    mode: &MapMode,
    properties: &HashMap<u32, ProvinceProperties>,
) -> Vec<u8> {
    let w = map.width() as usize;
    let h = map.height() as usize;
    let lookup = map.pixel_lookup();
    let mut buffer = vec![0u8; w * h * 4];

    // Pre-resolve colours per province to avoid repeated lookups
    let mut color_cache: HashMap<u32, [u8; 4]> = HashMap::new();

    for (idx, &pid) in lookup.iter().enumerate() {
        if pid == 0 {
            // Transparent black -- already zeroed
            continue;
        }

        let rgba = color_cache.entry(pid).or_insert_with(|| {
            let c = match map.get_province(pid) {
                Some(prov) => mode.resolve_color(prov, properties.get(&pid)),
                None => [0.5, 0.5, 0.5, 1.0],
            };
            [
                (c[0] * 255.0) as u8,
                (c[1] * 255.0) as u8,
                (c[2] * 255.0) as u8,
                (c[3] * 255.0) as u8,
            ]
        });

        let base = idx * 4;
        buffer[base] = rgba[0];
        buffer[base + 1] = rgba[1];
        buffer[base + 2] = rgba[2];
        buffer[base + 3] = rgba[3];
    }

    buffer
}
