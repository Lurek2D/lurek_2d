//! Color palette lookup table for shader-based palette swapping.
//!
//! [`PaletteLUT`] maps source colours to target colours, allowing sprites to be
//! re-coloured at render time without modifying the original texture.  Each entry
//! pairs a "from" [`Color`] with a "to" [`Color`]; a shader (or the CPU
//! [`PaletteLUT::apply`] path) replaces matching pixels in a single pass.
//!
//! This module is part of Lurek2D's `image` subsystem (Platform Services tier).
//!
//! All public items are documented.  See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

use crate::math::Color;

/// Color palette lookup table mapping source colors to target colors.
///
/// # Fields
/// - `from_colors` — `Vec<Color>`.
/// - `to_colors` — `Vec<Color>`.
///
/// Each entry pairs a "from" color with a "to" color. At render time a
/// shader can replace pixels matching a source color with the
/// corresponding target color.
pub struct PaletteLUT {
    /// Source colors to match against.
    pub from_colors: Vec<Color>,
    /// Replacement colors in the same order as `from_colors`.
    pub to_colors: Vec<Color>,
}

impl PaletteLUT {
    /// Creates an empty palette lookup table. Returns a fully initialised instance with all fields set to their initial values.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        Self {
            from_colors: Vec::new(),
            to_colors: Vec::new(),
        }
    }

    /// Returns the number of color mappings. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `usize`.
    pub fn get_color_count(&self) -> usize {
        self.from_colors.len()
    }

    /// Sets the color mapping at the given 0-based index.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    /// - `from` — `Color`.
    /// - `to` — `Color`.
    ///
    /// If `index` is beyond the current length, both vectors are extended
    /// with `Color::WHITE` entries to fill the gap.
    pub fn set_color(&mut self, index: usize, from: Color, to: Color) {
        while self.from_colors.len() <= index {
            self.from_colors.push(Color::WHITE);
            self.to_colors.push(Color::WHITE);
        }
        self.from_colors[index] = from;
        self.to_colors[index] = to;
    }

    /// Returns the source color at the given 0-based index, if it exists.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    ///
    /// # Returns
    /// `Option<Color>`.
    pub fn get_from_color(&self, index: usize) -> Option<Color> {
        self.from_colors.get(index).copied()
    }

    /// Returns the target color at the given 0-based index, if it exists.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    ///
    /// # Returns
    /// `Option<Color>`.
    pub fn get_to_color(&self, index: usize) -> Option<Color> {
        self.to_colors.get(index).copied()
    }

    /// Removes all color mappings. After this call the container is in the same state as immediately after construction.
    pub fn clear(&mut self) {
        self.from_colors.clear();
        self.to_colors.clear();
    }

    /// Applies this palette lookup table to an image in place.
    ///
    /// For every pixel in `img` whose RGBA byte values (0–255) match a `from_colors[i]`
    /// entry (exact comparison after converting from `f32 * 255.0`), the pixel is
    /// replaced with the corresponding `to_colors[i]` value.
    ///
    /// The first matching mapping is applied and the rest are skipped for that pixel.
    ///
    /// # Parameters
    /// - `img` — `&mut ImageData` — image modified in place.
    pub fn apply(&self, img: &mut crate::image::image_data::ImageData) {
        let w = img.width();
        let h = img.height();
        for y in 0..h {
            for x in 0..w {
                if let Some((r, g, b, a)) = img.get_pixel(x, y) {
                    for (i, from) in self.from_colors.iter().enumerate() {
                        let fr = (from.r * 255.0).round() as u8;
                        let fg = (from.g * 255.0).round() as u8;
                        let fb = (from.b * 255.0).round() as u8;
                        let fa = (from.a * 255.0).round() as u8;
                        if r == fr && g == fg && b == fb && a == fa {
                            let to = &self.to_colors[i];
                            img.set_pixel(
                                x,
                                y,
                                (to.r * 255.0).round() as u8,
                                (to.g * 255.0).round() as u8,
                                (to.b * 255.0).round() as u8,
                                (to.a * 255.0).round() as u8,
                            );
                            break;
                        }
                    }
                }
            }
        }
    }
}

impl Default for PaletteLUT {
    fn default() -> Self {
        Self::new()
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::image::ImageData;
    use crate::math::Color;

    #[test]
    fn new_palette_is_empty() {
        let p = PaletteLUT::new();
        assert_eq!(p.get_color_count(), 0);
    }

    #[test]
    fn default_is_same_as_new() {
        let p = PaletteLUT::default();
        assert_eq!(p.get_color_count(), 0);
    }

    #[test]
    fn set_color_appends_and_pads() {
        let mut p = PaletteLUT::new();
        let from = Color { r: 1.0, g: 0.0, b: 0.0, a: 1.0 };
        let to = Color { r: 0.0, g: 1.0, b: 0.0, a: 1.0 };
        p.set_color(2, from, to);
        // Gap entries 0 and 1 are padded with WHITE
        assert_eq!(p.get_color_count(), 3);
        assert_eq!(p.get_from_color(2).unwrap().r, 1.0);
        assert_eq!(p.get_to_color(2).unwrap().g, 1.0);
    }

    #[test]
    fn get_from_color_out_of_bounds() {
        let p = PaletteLUT::new();
        assert!(p.get_from_color(0).is_none());
        assert!(p.get_to_color(5).is_none());
    }

    #[test]
    fn clear_empties_palette() {
        let mut p = PaletteLUT::new();
        let c = Color::WHITE;
        p.set_color(0, c, c);
        p.set_color(1, c, c);
        assert_eq!(p.get_color_count(), 2);
        p.clear();
        assert_eq!(p.get_color_count(), 0);
    }

    #[test]
    fn apply_replaces_matching_pixel() {
        let mut img = ImageData::new(2, 1);
        // Set pixel (0,0) to pure red (255,0,0,255)
        img.set_pixel(0, 0, 255, 0, 0, 255);
        // Set pixel (1,0) to pure blue — should NOT be replaced
        img.set_pixel(1, 0, 0, 0, 255, 255);

        let mut p = PaletteLUT::new();
        p.set_color(
            0,
            Color { r: 1.0, g: 0.0, b: 0.0, a: 1.0 }, // from: red
            Color { r: 0.0, g: 1.0, b: 0.0, a: 1.0 }, // to: green
        );
        p.apply(&mut img);

        // Red pixel should now be green
        assert_eq!(img.get_pixel(0, 0), Some((0, 255, 0, 255)));
        // Blue pixel unchanged
        assert_eq!(img.get_pixel(1, 0), Some((0, 0, 255, 255)));
    }

    #[test]
    fn apply_with_empty_palette_is_noop() {
        let mut img = ImageData::new(2, 2);
        img.set_pixel(0, 0, 42, 84, 126, 200);
        let p = PaletteLUT::new();
        p.apply(&mut img);
        assert_eq!(img.get_pixel(0, 0), Some((42, 84, 126, 200)));
    }
}
