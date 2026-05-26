//! `lurek.color` -- Color bindings for RGBA construction, color-space conversions, blending modes, palettes, and utility operations.

use super::SharedState;
use crate::color::{
    blend, gamma_to_linear, hsl_to_rgb, hsv_to_rgb, linear_to_gamma, retro, Color,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Extracts RGBA floats from a Lua table at indices 1-4 (alpha defaults to 1.0).
fn color_from_table(t: &LuaTable) -> LuaResult<(f32, f32, f32, f32)> {
    let r: f32 = t.get(1)?;
    let g: f32 = t.get(2)?;
    let b: f32 = t.get(3)?;
    let a: f32 = t.get(4).unwrap_or(1.0);
    Ok((r, g, b, a))
}

/// Creates a Lua table with RGBA at indices 1-4.
fn color_to_table(lua: &Lua, r: f32, g: f32, b: f32, a: f32) -> LuaResult<LuaTable> {
    let t = lua.create_table()?;
    t.set(1, r)?;
    t.set(2, g)?;
    t.set(3, b)?;
    t.set(4, a)?;
    Ok(t)
}

/// Converts a Color struct into a Lua table.
fn color_struct_to_table(lua: &Lua, c: &Color) -> LuaResult<LuaTable> {
    color_to_table(lua, c.r, c.g, c.b, c.a)
}

/// Registers the `lurek.color` API table with the Lua VM.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // ── Constants ────────────────────────────────────────────────────────────
    tbl.set("WHITE", color_to_table(lua, 1.0, 1.0, 1.0, 1.0)?)?;
    tbl.set("BLACK", color_to_table(lua, 0.0, 0.0, 0.0, 1.0)?)?;
    tbl.set("RED", color_to_table(lua, 1.0, 0.0, 0.0, 1.0)?)?;
    tbl.set("GREEN", color_to_table(lua, 0.0, 1.0, 0.0, 1.0)?)?;
    tbl.set("BLUE", color_to_table(lua, 0.0, 0.0, 1.0, 1.0)?)?;
    tbl.set("YELLOW", color_to_table(lua, 1.0, 1.0, 0.0, 1.0)?)?;
    tbl.set("CYAN", color_to_table(lua, 0.0, 1.0, 1.0, 1.0)?)?;
    tbl.set("MAGENTA", color_to_table(lua, 1.0, 0.0, 1.0, 1.0)?)?;
    tbl.set("TRANSPARENT", color_to_table(lua, 0.0, 0.0, 0.0, 0.0)?)?;

    // ── Constructors ─────────────────────────────────────────────────────────

    // -- new --
    /// Creates an RGBA color from 0–1 float components. Alpha defaults to 1.0.
    /// @param | r | number | Red channel (0–1).
    /// @param | g | number | Green channel (0–1).
    /// @param | b | number | Blue channel (0–1).
    /// @param | a | number? | Alpha channel (0–1); defaults to 1.0.
    /// @return | table | Color table {r, g, b, a}.
    tbl.set(
        "new",
        lua.create_function(|lua, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
            color_to_table(lua, r, g, b, a.unwrap_or(1.0))
        })?,
    )?;

    // -- fromU8 --
    /// Creates a color from 0–255 integer components. Alpha defaults to 255.
    /// @param | r | integer | Red channel (0–255).
    /// @param | g | integer | Green channel (0–255).
    /// @param | b | integer | Blue channel (0–255).
    /// @param | a | integer? | Alpha channel (0–255); defaults to 255.
    /// @return | table | Color table {r, g, b, a} with values normalised to 0–1.
    tbl.set(
        "fromU8",
        lua.create_function(|lua, (r, g, b, a): (u8, u8, u8, Option<u8>)| {
            let c = Color::from_u8(r, g, b, a.unwrap_or(255));
            color_struct_to_table(lua, &c)
        })?,
    )?;

    // -- fromHex --
    /// Parses a hex color string ("#RRGGBB" or "#RRGGBBAA") into a color table. Returns nil on invalid input.
    /// @param | hex | string | Hex color string with leading '#'.
    /// @param | | | |
    /// @return | table|nil | Color table or nil if parsing fails.
    tbl.set(
        "fromHex",
        lua.create_function(|lua, hex: String| match Color::from_hex(&hex) {
            Some(c) => Ok(LuaValue::Table(color_struct_to_table(lua, &c)?)),
            None => Ok(LuaValue::Nil),
        })?,
    )?;

    // -- fromHsl --
    /// Creates a color from HSL components. Returns an opaque color (alpha = 1).
    /// @param | h | number | Hue in degrees (0–360).
    /// @param | s | number | Saturation (0–1).
    /// @param | l | number | Lightness (0–1).
    /// @return | table | Color table {r, g, b, a}.
    tbl.set(
        "fromHsl",
        lua.create_function(|lua, (h, s, l): (f32, f32, f32)| {
            let c = hsl_to_rgb(h, s, l);
            color_struct_to_table(lua, &c)
        })?,
    )?;

    // -- fromHsv --
    /// Creates a color from HSV components. Returns an opaque color (alpha = 1).
    /// @param | h | number | Hue in degrees (0–360).
    /// @param | s | number | Saturation (0–1).
    /// @param | v | number | Value/brightness (0–1).
    /// @return | table | Color table {r, g, b, a}.
    tbl.set(
        "fromHsv",
        lua.create_function(|lua, (h, s, v): (f32, f32, f32)| {
            let (r, g, b) = hsv_to_rgb((h as u16).min(359), s, v);
            color_to_table(lua, r as f32 / 255.0, g as f32 / 255.0, b as f32 / 255.0, 1.0)
        })?,
    )?;

    // ── Conversions ──────────────────────────────────────────────────────────

    // -- toHsl --
    /// Convert RGB color components to HSL color representation.
    /// @param | r | number | Red channel (0–1).
    /// @param | g | number | Green channel (0–1).
    /// @param | b | number | Blue channel (0–1).
    /// @return | number, number, number | Hue (0–360), saturation (0–1), lightness (0–1).
    tbl.set(
        "toHsl",
        lua.create_function(|_, (r, g, b): (f32, f32, f32)| {
            let c = Color::new(r, g, b, 1.0);
            let (h, s, l) = c.to_hsl();
            Ok((h, s, l))
        })?,
    )?;

    // -- toHex --
    /// Converts RGBA components to a hex string ("#RRGGBB" or "#RRGGBBAA" if alpha < 1).
    /// @param | r | number | Red channel (0–1).
    /// @param | g | number | Green channel (0–1).
    /// @param | b | number | Blue channel (0–1).
    /// @param | a | number? | Alpha channel (0–1); defaults to 1.0.
    /// @return | string | Hex color string.
    tbl.set(
        "toHex",
        lua.create_function(|_, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
            let c = Color::new(r, g, b, a.unwrap_or(1.0));
            Ok(c.to_hex())
        })?,
    )?;

    // ── Blending ─────────────────────────────────────────────────────────────

    // -- lerp --
    /// Linearly interpolates between two color tables by factor t (clamped to 0–1).
    /// @param | c1 | table | Start color {r, g, b, a}.
    /// @param | c2 | table | End color {r, g, b, a}.
    /// @param | t | number | Interpolation factor (0–1).
    /// @return | table | Interpolated color table.
    tbl.set(
        "lerp",
        lua.create_function(|lua, (c1, c2, t): (LuaTable, LuaTable, f32)| {
            let (r1, g1, b1, a1) = color_from_table(&c1)?;
            let (r2, g2, b2, a2) = color_from_table(&c2)?;
            let a = Color::new(r1, g1, b1, a1);
            let b = Color::new(r2, g2, b2, a2);
            let result = blend::lerp_color(&a, &b, t);
            color_struct_to_table(lua, &result)
        })?,
    )?;

    // -- multiply --
    /// Channel-wise multiply blend of two colors.
    /// @param | c1 | table | First color {r, g, b, a}.
    /// @param | c2 | table | Second color {r, g, b, a}.
    /// @return | table | Multiplied color table.
    tbl.set(
        "multiply",
        lua.create_function(|lua, (c1, c2): (LuaTable, LuaTable)| {
            let (r1, g1, b1, a1) = color_from_table(&c1)?;
            let (r2, g2, b2, a2) = color_from_table(&c2)?;
            let a = Color::new(r1, g1, b1, a1);
            let b = Color::new(r2, g2, b2, a2);
            let result = blend::multiply(&a, &b);
            color_struct_to_table(lua, &result)
        })?,
    )?;

    // -- screen --
    /// Apply screen blend mode to combine two color values.
    /// @param | c1 | table | First color {r, g, b, a}.
    /// @param | c2 | table | Second color {r, g, b, a}.
    /// @return | table | Screen-blended color table.
    tbl.set(
        "screen",
        lua.create_function(|lua, (c1, c2): (LuaTable, LuaTable)| {
            let (r1, g1, b1, a1) = color_from_table(&c1)?;
            let (r2, g2, b2, a2) = color_from_table(&c2)?;
            let a = Color::new(r1, g1, b1, a1);
            let b = Color::new(r2, g2, b2, a2);
            let result = blend::screen(&a, &b);
            color_struct_to_table(lua, &result)
        })?,
    )?;

    // -- overlay --
    /// Overlay blend of two colors exposed by the lurek engine.
    /// @param | base | table | Base color {r, g, b, a}.
    /// @param | blend | table | Blend color {r, g, b, a}.
    /// @return | table | Overlay-blended color table.
    tbl.set(
        "overlay",
        lua.create_function(|lua, (base_t, blend_t): (LuaTable, LuaTable)| {
            let (r1, g1, b1, a1) = color_from_table(&base_t)?;
            let (r2, g2, b2, a2) = color_from_table(&blend_t)?;
            let base = Color::new(r1, g1, b1, a1);
            let bl = Color::new(r2, g2, b2, a2);
            let result = blend::overlay(&base, &bl);
            color_struct_to_table(lua, &result)
        })?,
    )?;

    // -- additive --
    /// Additive blend of two colors (clamped to 0–1 per channel).
    /// @param | c1 | table | First color {r, g, b, a}.
    /// @param | c2 | table | Second color {r, g, b, a}.
    /// @return | table | Additively blended color table.
    tbl.set(
        "additive",
        lua.create_function(|lua, (c1, c2): (LuaTable, LuaTable)| {
            let (r1, g1, b1, a1) = color_from_table(&c1)?;
            let (r2, g2, b2, a2) = color_from_table(&c2)?;
            let a = Color::new(r1, g1, b1, a1);
            let b = Color::new(r2, g2, b2, a2);
            let result = blend::additive(&a, &b);
            color_struct_to_table(lua, &result)
        })?,
    )?;

    // -- alphaBlend --
    /// Alpha compositing (Porter-Duff "over") of foreground over background.
    /// @param | fg | table | Foreground color {r, g, b, a}.
    /// @param | bg | table | Background color {r, g, b, a}.
    /// @return | table | Composited color table.
    tbl.set(
        "alphaBlend",
        lua.create_function(|lua, (fg_t, bg_t): (LuaTable, LuaTable)| {
            let (r1, g1, b1, a1) = color_from_table(&fg_t)?;
            let (r2, g2, b2, a2) = color_from_table(&bg_t)?;
            let fg = Color::new(r1, g1, b1, a1);
            let bg = Color::new(r2, g2, b2, a2);
            let result = blend::alpha_blend(&fg, &bg);
            color_struct_to_table(lua, &result)
        })?,
    )?;

    // ── Utilities ────────────────────────────────────────────────────────────

    // -- invert --
    /// Inverts the RGB channels of a color, keeping alpha unchanged.
    /// @param | r | number | Red channel (0–1).
    /// @param | g | number | Green channel (0–1).
    /// @param | b | number | Blue channel (0–1).
    /// @param | a | number? | Alpha channel (0–1); defaults to 1.0.
    /// @return | table | Inverted color table.
    tbl.set(
        "invert",
        lua.create_function(|lua, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
            let c = Color::new(r, g, b, a.unwrap_or(1.0));
            let inv = c.invert();
            color_struct_to_table(lua, &inv)
        })?,
    )?;

    // -- brightness --
    /// Computes perceived luminance (ITU-R BT.601) of an RGB color.
    /// @param | r | number | Red channel (0–1).
    /// @param | g | number | Green channel (0–1).
    /// @param | b | number | Blue channel (0–1).
    /// @return | number | Perceived brightness (0–1).
    tbl.set(
        "brightness",
        lua.create_function(|_, (r, g, b): (f32, f32, f32)| {
            let c = Color::new(r, g, b, 1.0);
            Ok(c.brightness())
        })?,
    )?;

    // -- withAlpha --
    /// Returns a color with the alpha channel replaced.
    /// @param | r | number | Red channel (0–1).
    /// @param | g | number | Green channel (0–1).
    /// @param | b | number | Blue channel (0–1).
    /// @param | a | number | Original alpha (ignored in output).
    /// @param | newAlpha | number | New alpha channel value (0–1).
    /// @return | table | Color table with the new alpha.
    tbl.set(
        "withAlpha",
        lua.create_function(|lua, (r, g, b, _a, new_alpha): (f32, f32, f32, f32, f32)| {
            color_to_table(lua, r, g, b, new_alpha)
        })?,
    )?;

    // -- gammaToLinear --
    /// Converts a single sRGB gamma-encoded component to linear space.
    /// @param | c | number | Gamma-encoded value (0–1).
    /// @return | number | Linear value.
    tbl.set(
        "gammaToLinear",
        lua.create_function(|_, c: f32| Ok(gamma_to_linear(c)))?,
    )?;

    // -- linearToGamma --
    /// Converts a single linear component to sRGB gamma-encoded space.
    /// @param | c | number | Linear value (0–1).
    /// @return | number | Gamma-encoded value.
    tbl.set(
        "linearToGamma",
        lua.create_function(|_, c: f32| Ok(linear_to_gamma(c)))?,
    )?;

    // -- palette --
    /// Returns a named retro palette as a table of color tables. Supported: "pico8", "gameboy", "nes".
    /// @param | name | string | Palette name ("pico8", "gameboy", or "nes").
    /// @return | table | Array of color tables, or empty table if name is unknown.
    tbl.set(
        "palette",
        lua.create_function(|lua, name: String| {
            let colors: &[Color] = match name.to_ascii_lowercase().as_str() {
                "pico8" | "pico-8" => retro::PICO8.colors,
                "gameboy" | "game boy" | "gb" => retro::GAMEBOY.colors,
                "nes" => retro::NES.colors,
                _ => &[],
            };
            let result = lua.create_table()?;
            for (i, c) in colors.iter().enumerate() {
                result.set(i + 1, color_struct_to_table(lua, c)?)?;
            }
            Ok(result)
        })?,
    )?;

    lurek.set("color", tbl)?;
    Ok(())
}
