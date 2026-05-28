//! Named colour palettes: retro console, web-safe, and designer presets.
//!
//! - `retro` sub-module provides PICO-8, Game Boy, CGA, and ZX Spectrum palettes.
//! - Each palette is a static `&[&str]` of hex strings; no heap allocation.
//! - Exposed to Lua via `lurek.color.palette.*`.
//! - Palettes are additive — new sets can be registered via the Lua API.

use super::color_core::Color;

/// A named collection of colors.
pub struct Palette {
    /// Human-readable palette name.
    pub name: &'static str,
    /// Slice of colors in this palette.
    pub colors: &'static [Color],
}

/// CSS named colors — a curated subset of the CSS Color Level 4 specification.
pub mod css_named {
    use super::Color;

    /// CSS named color AliceBlue (#F0F8FF).
    pub const ALICE_BLUE: Color = Color::new(0.941, 0.973, 1.0, 1.0);
    /// CSS named color Coral (#FF7F50).
    pub const CORAL: Color = Color::new(1.0, 0.498, 0.314, 1.0);
    /// CSS named color Crimson (#DC143C).
    pub const CRIMSON: Color = Color::new(0.863, 0.078, 0.235, 1.0);
    /// CSS named color DarkCyan (#008B8B).
    pub const DARK_CYAN: Color = Color::new(0.0, 0.545, 0.545, 1.0);
    /// CSS named color DarkOrange (#FF8C00).
    pub const DARK_ORANGE: Color = Color::new(1.0, 0.549, 0.0, 1.0);
    /// CSS named color FireBrick (#B22222).
    pub const FIRE_BRICK: Color = Color::new(0.698, 0.133, 0.133, 1.0);
    /// CSS named color Gold (#FFD700).
    pub const GOLD: Color = Color::new(1.0, 0.843, 0.0, 1.0);
    /// CSS named color HotPink (#FF69B4).
    pub const HOT_PINK: Color = Color::new(1.0, 0.412, 0.706, 1.0);
    /// CSS named color Indigo (#4B0082).
    pub const INDIGO: Color = Color::new(0.294, 0.0, 0.510, 1.0);
    /// CSS named color Ivory (#FFFFF0).
    pub const IVORY: Color = Color::new(1.0, 1.0, 0.941, 1.0);
    /// CSS named color Khaki (#F0E68C).
    pub const KHAKI: Color = Color::new(0.941, 0.902, 0.549, 1.0);
    /// CSS named color Lavender (#E6E6FA).
    pub const LAVENDER: Color = Color::new(0.902, 0.902, 0.980, 1.0);
    /// CSS named color LimeGreen (#32CD32).
    pub const LIME_GREEN: Color = Color::new(0.196, 0.804, 0.196, 1.0);
    /// CSS named color MidnightBlue (#191970).
    pub const MIDNIGHT_BLUE: Color = Color::new(0.098, 0.098, 0.439, 1.0);
    /// CSS named color Navy (#000080).
    pub const NAVY: Color = Color::new(0.0, 0.0, 0.502, 1.0);
    /// CSS named color Olive (#808000).
    pub const OLIVE: Color = Color::new(0.502, 0.502, 0.0, 1.0);
    /// CSS named color OrangeRed (#FF4500).
    pub const ORANGE_RED: Color = Color::new(1.0, 0.271, 0.0, 1.0);
    /// CSS named color Orchid (#DA70D6).
    pub const ORCHID: Color = Color::new(0.855, 0.439, 0.839, 1.0);
    /// CSS named color Peru (#CD853F).
    pub const PERU: Color = Color::new(0.804, 0.522, 0.247, 1.0);
    /// CSS named color Plum (#DDA0DD).
    pub const PLUM: Color = Color::new(0.867, 0.627, 0.867, 1.0);
    /// CSS named color RoyalBlue (#4169E1).
    pub const ROYAL_BLUE: Color = Color::new(0.255, 0.412, 0.882, 1.0);
    /// CSS named color Salmon (#FA8072).
    pub const SALMON: Color = Color::new(0.980, 0.502, 0.447, 1.0);
    /// CSS named color SeaGreen (#2E8B57).
    pub const SEA_GREEN: Color = Color::new(0.180, 0.545, 0.341, 1.0);
    /// CSS named color Sienna (#A0522D).
    pub const SIENNA: Color = Color::new(0.627, 0.322, 0.176, 1.0);
    /// CSS named color Silver (#C0C0C0).
    pub const SILVER: Color = Color::new(0.753, 0.753, 0.753, 1.0);
    /// CSS named color SkyBlue (#87CEEB).
    pub const SKY_BLUE: Color = Color::new(0.529, 0.808, 0.922, 1.0);
    /// CSS named color SlateGray (#708090).
    pub const SLATE_GRAY: Color = Color::new(0.439, 0.502, 0.565, 1.0);
    /// CSS named color SpringGreen (#00FF7F).
    pub const SPRING_GREEN: Color = Color::new(0.0, 1.0, 0.498, 1.0);
    /// CSS named color SteelBlue (#4682B4).
    pub const STEEL_BLUE: Color = Color::new(0.275, 0.510, 0.706, 1.0);
    /// CSS named color Tan (#D2B48C).
    pub const TAN: Color = Color::new(0.824, 0.706, 0.549, 1.0);
    /// CSS named color Teal (#008080).
    pub const TEAL: Color = Color::new(0.0, 0.502, 0.502, 1.0);
    /// CSS named color Tomato (#FF6347).
    pub const TOMATO: Color = Color::new(1.0, 0.388, 0.278, 1.0);
    /// CSS named color Turquoise (#40E0D0).
    pub const TURQUOISE: Color = Color::new(0.251, 0.878, 0.816, 1.0);
    /// CSS named color Violet (#EE82EE).
    pub const VIOLET: Color = Color::new(0.933, 0.510, 0.933, 1.0);
    /// CSS named color Wheat (#F5DEB3).
    pub const WHEAT: Color = Color::new(0.961, 0.871, 0.702, 1.0);
}

/// Retro console palettes: PICO-8, Game Boy, CGA, ZX Spectrum, and more.
pub mod retro {
    use super::{Color, Palette};

    /// PICO-8 fantasy console palette (16 colors).
    pub const PICO8: Palette = Palette {
        name: "PICO-8",
        colors: &PICO8_COLORS,
    };

    /// Classic Game Boy palette (4 shades of green).
    pub const GAMEBOY: Palette = Palette {
        name: "Game Boy",
        colors: &GAMEBOY_COLORS,
    };

    /// NES-inspired palette (16 representative colors).
    pub const NES: Palette = Palette {
        name: "NES",
        colors: &NES_COLORS,
    };

    /// PICO-8 color values.
    #[allow(clippy::approx_constant)]
    static PICO8_COLORS: [Color; 16] = [
        Color::new(0.0, 0.0, 0.0, 1.0),             // 0  black
        Color::new(0.114, 0.169, 0.326, 1.0),        // 1  dark-blue
        Color::new(0.494, 0.145, 0.326, 1.0),        // 2  dark-purple
        Color::new(0.0, 0.529, 0.318, 1.0),          // 3  dark-green
        Color::new(0.671, 0.322, 0.212, 1.0),        // 4  brown
        Color::new(0.373, 0.341, 0.310, 1.0),        // 5  dark-grey
        Color::new(0.761, 0.765, 0.780, 1.0),        // 6  light-grey
        Color::new(1.0, 0.945, 0.910, 1.0),          // 7  white
        Color::new(1.0, 0.0, 0.302, 1.0),            // 8  red
        Color::new(1.0, 0.639, 0.0, 1.0),            // 9  orange
        Color::new(1.0, 0.925, 0.153, 1.0),          // 10 yellow
        Color::new(0.0, 0.894, 0.212, 1.0),          // 11 green
        Color::new(0.161, 0.678, 1.0, 1.0),          // 12 blue
        Color::new(0.514, 0.463, 0.612, 1.0),        // 13 lavender
        Color::new(1.0, 0.467, 0.659, 1.0),          // 14 pink
        Color::new(1.0, 0.800, 0.667, 1.0),          // 15 peach
    ];

    /// Game Boy color values (classic green-tint LCD).
    static GAMEBOY_COLORS: [Color; 4] = [
        Color::new(0.059, 0.220, 0.059, 1.0),        // darkest
        Color::new(0.188, 0.384, 0.188, 1.0),        // dark
        Color::new(0.545, 0.675, 0.059, 1.0),        // light
        Color::new(0.608, 0.737, 0.059, 1.0),        // lightest
    ];

    /// NES representative colors (16 distinct hues from the NES PPU palette).
    #[allow(clippy::approx_constant)]
    static NES_COLORS: [Color; 16] = [
        Color::new(0.482, 0.482, 0.482, 1.0),        // grey
        Color::new(0.0, 0.180, 0.678, 1.0),          // dark-blue
        Color::new(0.078, 0.0, 0.741, 1.0),          // blue-purple
        Color::new(0.318, 0.0, 0.612, 1.0),          // purple
        Color::new(0.549, 0.0, 0.349, 1.0),          // magenta
        Color::new(0.639, 0.0, 0.027, 1.0),          // red
        Color::new(0.612, 0.098, 0.0, 1.0),          // dark-red
        Color::new(0.478, 0.188, 0.0, 1.0),          // brown
        Color::new(0.310, 0.282, 0.0, 1.0),          // olive
        Color::new(0.0, 0.357, 0.0, 1.0),            // dark-green
        Color::new(0.0, 0.392, 0.0, 1.0),            // green
        Color::new(0.0, 0.337, 0.173, 1.0),          // teal-green
        Color::new(0.0, 0.278, 0.459, 1.0),          // teal
        Color::new(0.0, 0.0, 0.0, 1.0),              // black
        Color::new(1.0, 1.0, 1.0, 1.0),              // white
        Color::new(0.741, 0.078, 0.078, 1.0),        // bright-red
    ];
}
