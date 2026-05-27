//! `lurek.font` -- Font bindings for text measurement, font loading, word wrapping, and text shaping.

use super::SharedState;
use crate::render::font::{AVAILABLE_POINT_SIZES, Font};
use crate::runtime::resource_keys::FontKey;
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::path::Path;
use std::rc::Rc;

/// Lua-visible font handle storing the slot key and cached metadata.
#[derive(Clone)]
pub struct LuaFont {
    /// SlotMap key into SharedState.fonts.
    handle_id: FontKey,
    /// Human-readable font name exposed by the lurek engine.
    name: String,
    /// Point size of the font exposed by the lurek engine.
    size: u32,
    /// Style string ("regular" or "bold").
    style: String,
    /// Shared runtime state for font access.
    state: Rc<RefCell<SharedState>>,
}

impl LuaUserData for LuaFont {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getName --
        /// Returns the human-readable name of this font. This method is available to Lua scripts.
        /// @return | string | Font name.
        methods.add_method("getName", |_, this, ()| Ok(this.name.clone()));

        // -- getSize --
        /// Returns the point size of this font. This method is available to Lua scripts.
        /// @return | number | Point size.
        methods.add_method("getSize", |_, this, ()| Ok(this.size));

        // -- getStyle --
        /// Returns the style string of this font. This method is available to Lua scripts.
        /// @return | string | Style name ("regular", "bold").
        methods.add_method("getStyle", |_, this, ()| Ok(this.style.clone()));

        // -- isBold --
        /// Returns whether this font is the bold variant. This method is available to Lua scripts.
        /// @return | boolean | True if font style is bold.
        methods.add_method("isBold", |_, this, ()| Ok(this.style == "bold"));

        // -- lineHeight --
        /// Returns the line height of this font in pixels. This method is available to Lua scripts.
        /// @return | number | Line height in pixels.
        methods.add_method("lineHeight", |_, this, ()| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.handle_id).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            Ok(font.line_height())
        });

        // -- measure --
        /// Measures the pixel dimensions of a text string at the given scale. This method is available to Lua scripts.
        /// @param | text | string | Text to measure.
        /// @param | scale | number | Scale factor applied to dimensions.
        /// @return | number, number | Width and height in pixels.
        methods.add_method("measure", |_, this, (text, scale): (String, Option<f32>)| {
            let scale = scale.unwrap_or(1.0);
            let st = this.state.borrow();
            let font = st.fonts.get(this.handle_id).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            let width = font.text_width(&text) * scale;
            let height = font.line_height() * scale;
            Ok((width, height))
        });

        // -- wrapText --
        /// Wraps text into lines fitting within the given max width. This method is available to Lua scripts.
        /// @param | text | string | Text to wrap.
        /// @param | maxWidth | number | Maximum line width in pixels.
        /// @param | scale | number | Scale factor.
        /// @return | table | Array of wrapped line strings.
        methods.add_method(
            "wrapText",
            |lua, this, (text, max_width, scale): (String, f32, Option<f32>)| {
                let scale = scale.unwrap_or(1.0);
                let st = this.state.borrow();
                let font = st.fonts.get(this.handle_id).ok_or_else(|| {
                    LuaError::RuntimeError("Font handle is not valid or was released".into())
                })?;
                let limit = if scale > 0.0 {
                    max_width / scale
                } else {
                    max_width
                };
                let lines = font.wrap_text(&text, limit);
                let tbl = lua.create_table()?;
                for (i, line) in lines.iter().enumerate() {
                    tbl.set(i + 1, line.as_str())?;
                }
                Ok(tbl)
            },
        );

        // -- containsGlyph --
        /// Returns whether the font contains a glyph for the given character. This method is available to Lua scripts.
        /// @param | char | string | A single-character string to check.
        /// @return | boolean | True if the font has a glyph for this character.
        methods.add_method("containsGlyph", |_, this, ch: String| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.handle_id).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            let c = ch.chars().next().unwrap_or('\0');
            Ok(font.glyph(c).is_some())
        });
    }
}

/// Resolves the active font key, falling back to the default font.
fn active_font_key(st: &SharedState) -> Option<FontKey> {
    st.active_font.or(st.default_font)
}

/// Determines the style string for a font key in shared state.
fn font_style_str(st: &SharedState, key: FontKey) -> &'static str {
    for bold_key in &st.default_bold_fonts {
        if *bold_key == Some(key) {
            return "bold";
        }
    }
    "regular"
}

/// Determines a human-readable name for a font key in shared state.
fn font_name_for_key(st: &SharedState, key: FontKey) -> String {
    for (i, regular_key) in st.default_fonts.iter().enumerate() {
        if *regular_key == Some(key) {
            return format!("font_{}", AVAILABLE_POINT_SIZES[i]);
        }
    }
    for (i, bold_key) in st.default_bold_fonts.iter().enumerate() {
        if *bold_key == Some(key) {
            return format!("fontb_{}", AVAILABLE_POINT_SIZES[i]);
        }
    }
    format!("font_{}", key.data().as_ffi())
}

/// Determines the point size for a font key in shared state.
fn font_size_for_key(st: &SharedState, key: FontKey) -> u32 {
    if let Some(font) = st.fonts.get(key) {
        font.size() as u32
    } else {
        0
    }
}

/// Builds a LuaFont userdata from a font key.
fn make_lua_font(state: Rc<RefCell<SharedState>>, key: FontKey) -> LuaFont {
    let st = state.borrow();
    let name = font_name_for_key(&st, key);
    let size = font_size_for_key(&st, key);
    let style = font_style_str(&st, key).to_string();
    drop(st);
    LuaFont {
        handle_id: key,
        name,
        size,
        style,
        state,
    }
}

/// Registers the `lurek.font` namespace and returns the Lua table.
pub fn register_font_api(lua: &Lua, state: Rc<RefCell<SharedState>>) -> LuaResult<LuaTable<'_>> {
    let font = lua.create_table()?;

    // --- Constants ---
    font.set("ALIGN_LEFT", "left")?;
    font.set("ALIGN_CENTER", "center")?;
    font.set("ALIGN_RIGHT", "right")?;
    font.set("ALIGN_JUSTIFY", "justify")?;
    font.set("WRAP_NONE", "none")?;
    font.set("WRAP_WORD", "word")?;
    font.set("WRAP_CHAR", "char")?;
    font.set("STYLE_REGULAR", "regular")?;
    font.set("STYLE_BOLD", "bold")?;

    // -- getDefault --
    /// Returns the default engine font as a LuaFont userdata. This function is available to Lua scripts.
    /// @return | LuaFont | The default font handle.
    {
        let s = state.clone();
        /// Returns the default engine font as an LFont userdata handle.
        ///
        /// @return | LFont | The default engine font handle.
        font.set(
            "getDefault",
            lua.create_function(move |_, ()| {
                let key = {
                    let st = s.borrow();
                    active_font_key(&st).ok_or_else(|| {
                        LuaError::RuntimeError(
                            "lurek.font.getDefault: no default font loaded".into(),
                        )
                    })?
                };
                Ok(make_lua_font(s.clone(), key))
            })?,
        )?;
    }

    // -- load --
    /// Loads a TTF/OTF font file at the given point size and returns a LuaFont handle. This function is available to Lua scripts.
    /// @param | path | string | Relative path to the font file.
    /// @param | size | number | Point size for rasterisation.
    /// @return | LuaFont | The loaded font handle.
    {
        let s = state.clone();
        /// Loads a TTF/OTF/PNG font file at the given point size and returns an LFont handle.
        ///
        /// @param | path | string | Relative path to the font file.
        /// @param | size | number | Point size for rasterisation.
        /// @return | LFont | The loaded font handle.
        font.set(
            "load",
            lua.create_function(move |_, (path, size): (String, f32)| {
                let key = {
                    let mut st = s.borrow_mut();
                    let full_path = st.game_dir.join(&path);
                    let data = std::fs::read(&full_path).map_err(|e| {
                        LuaError::RuntimeError(format!(
                            "lurek.font.load: failed to read '{}': {}",
                            path, e
                        ))
                    })?;
                    let ext = Path::new(&path)
                        .extension()
                        .and_then(|ext| ext.to_str())
                        .map(|ext| ext.to_ascii_lowercase());
                    let bitmap_cell_h = size.max(1.0).round() as u32;
                    let bitmap_cell_w = (size.max(1.0) * 0.6).round().max(1.0) as u32;
                    let loaded = match ext.as_deref() {
                        Some("ttf") | Some("otf") | Some("ttc") => {
                            Font::from_font_bytes(&data, size)
                        }
                        Some("png") => {
                            Font::from_png_bytes(&data, bitmap_cell_w, bitmap_cell_h, false)
                        }
                        _ => Font::from_font_bytes(&data, size).or_else(|_| {
                            Font::from_png_bytes(&data, bitmap_cell_w, bitmap_cell_h, false)
                        }),
                    }
                    .map_err(|e| {
                        LuaError::RuntimeError(format!("lurek.font.load: {}", e))
                    })?;
                    st.fonts.insert(loaded)
                };
                let lua_font = {
                    let st = s.borrow();
                    let name = Path::new(&path)
                        .file_stem()
                        .and_then(|n| n.to_str())
                        .unwrap_or("custom")
                        .to_string();
                    let font_size = st
                        .fonts
                        .get(key)
                        .map(|f| f.size() as u32)
                        .unwrap_or(size as u32);
                    drop(st);
                    LuaFont {
                        handle_id: key,
                        name,
                        size: font_size,
                        style: "regular".to_string(),
                        state: s.clone(),
                    }
                };
                Ok(lua_font)
            })?,
        )?;
    }

    // -- loadBitmap --
    /// Loads a bitmap font atlas PNG with the given cell dimensions. This function is available to Lua scripts.
    /// @param | path | string | Relative path to the PNG atlas.
    /// @param | cellWidth | integer | Cell width in pixels.
    /// @param | cellHeight | integer | Cell height in pixels.
    /// @return | LuaFont | The loaded bitmap font handle.
    {
        let s = state.clone();
        /// Loads a bitmap font atlas PNG with the given cell dimensions and returns an LFont handle.
        ///
        /// @param | path | string | Relative path to the PNG atlas.
        /// @param | cellWidth | integer | Cell width in pixels.
        /// @param | cellHeight | integer | Cell height in pixels.
        /// @return | LFont | The loaded bitmap font handle.
        font.set(
            "loadBitmap",
            lua.create_function(
                move |_, (path, cell_width, cell_height): (String, u32, u32)| {
                    let key = {
                        let mut st = s.borrow_mut();
                        let full_path = st.game_dir.join(&path);
                        let data = std::fs::read(&full_path).map_err(|e| {
                            LuaError::RuntimeError(format!(
                                "lurek.font.loadBitmap: failed to read '{}': {}",
                                path, e
                            ))
                        })?;
                        let loaded =
                            Font::from_png_bytes(&data, cell_width, cell_height, false)
                                .map_err(|e| {
                                    LuaError::RuntimeError(format!(
                                        "lurek.font.loadBitmap: {}",
                                        e
                                    ))
                                })?;
                        st.fonts.insert(loaded)
                    };
                    let lua_font = {
                        let st = s.borrow();
                        let name = Path::new(&path)
                            .file_stem()
                            .and_then(|n| n.to_str())
                            .unwrap_or("bitmap")
                            .to_string();
                        let font_size = st
                            .fonts
                            .get(key)
                            .map(|f| f.size() as u32)
                            .unwrap_or(cell_height);
                        drop(st);
                        LuaFont {
                            handle_id: key,
                            name,
                            size: font_size,
                            style: "regular".to_string(),
                            state: s.clone(),
                        }
                    };
                    Ok(lua_font)
                },
            )?,
        )?;
    }

    // -- list --
    /// Lists all registered fonts with their name, size, and style. This function is available to Lua scripts.
    /// @return | table | Array of tables with fields: name (string), size (number), style (string).
    {
        let s = state.clone();
        /// Lists all registered fonts with their name, size, and style metadata.
        ///
        /// @return | table | Array of tables with fields: name (string), size (number), style (string).
        font.set(
            "list",
            lua.create_function(move |lua, ()| {
                let st = s.borrow();
                let tbl = lua.create_table()?;
                let mut idx = 1;
                for (i, regular_key) in st.default_fonts.iter().enumerate() {
                    if regular_key.is_some() {
                        let entry = lua.create_table()?;
                        entry.set("name", format!("font_{}", AVAILABLE_POINT_SIZES[i]))?;
                        entry.set("size", AVAILABLE_POINT_SIZES[i])?;
                        entry.set("style", "regular")?;
                        tbl.set(idx, entry)?;
                        idx += 1;
                    }
                }
                for (i, bold_key) in st.default_bold_fonts.iter().enumerate() {
                    if bold_key.is_some() {
                        let entry = lua.create_table()?;
                        entry.set("name", format!("fontb_{}", AVAILABLE_POINT_SIZES[i]))?;
                        entry.set("size", AVAILABLE_POINT_SIZES[i])?;
                        entry.set("style", "bold")?;
                        tbl.set(idx, entry)?;
                        idx += 1;
                    }
                }
                Ok(tbl)
            })?,
        )?;
    }

    // -- availableSizes --
    /// Returns the built-in bitmap font sizes available in the engine. This function is available to Lua scripts.
    /// @return | table | Array of numbers representing available point sizes.
    {
        /// Returns the array of built-in bitmap font point sizes available in the engine.
        ///
        /// @return | table | Array of integer point sizes available as built-in fonts.
        font.set(
            "availableSizes",
            lua.create_function(move |lua, ()| {
                let tbl = lua.create_table()?;
                for (i, &size) in AVAILABLE_POINT_SIZES.iter().enumerate() {
                    tbl.set(i + 1, size)?;
                }
                Ok(tbl)
            })?,
        )?;
    }

    // -- measure --
    /// Measures text dimensions using a font at the given scale. This function is available to Lua scripts.
    /// @param | font | LuaFont | Font handle to measure with.
    /// @param | text | string | Text to measure.
    /// @param | scale | number | Scale factor.
    /// @return | number, number | Width and height in pixels.
    {
        let s = state.clone();
        /// Measures the pixel dimensions of a text string using the given font handle and scale.
        ///
        /// @param | font | LFont | Font handle to measure with.
        /// @param | text | string | Text string to measure.
        /// @param | scale | number | Scale factor (default 1.0).
        /// @return | number | Width in pixels (height returned as second value).
        font.set(
            "measure",
            lua.create_function(
                move |_, (font_ud, text, scale): (LuaAnyUserData, String, Option<f32>)| {
                    let scale = scale.unwrap_or(1.0);
                    let lua_font = font_ud.borrow::<LuaFont>()?;
                    let key = lua_font.handle_id;
                    let state_ref = lua_font.state.clone();
                    drop(lua_font);
                    let st = state_ref.borrow();
                    let f = st.fonts.get(key).ok_or_else(|| {
                        LuaError::RuntimeError("Font handle is not valid or was released".into())
                    })?;
                    let width = f.text_width(&text) * scale;
                    let height = f.line_height() * scale;
                    Ok((width, height))
                },
            )?,
        )?;
        let _ = &s;
    }

    // -- measureLine --
    /// Measures a single line of text. This function is available to Lua scripts.
    /// @param | font | LuaFont | Font handle to measure with.
    /// @param | text | string | Single-line text to measure.
    /// @param | scale | number | Scale factor.
    /// @return | number, number | Width and height in pixels.
    {
        let s = state.clone();
        /// Measures the pixel width and height of a single line of text with the given font.
        ///
        /// @param | font | LFont | Font handle to measure with.
        /// @param | text | string | Single-line text string to measure.
        /// @param | scale | number | Scale factor (default 1.0).
        /// @return | number | Width in pixels (height returned as second value).
        font.set(
            "measureLine",
            lua.create_function(
                move |_, (font_ud, text, scale): (LuaAnyUserData, String, Option<f32>)| {
                    let scale = scale.unwrap_or(1.0);
                    let lua_font = font_ud.borrow::<LuaFont>()?;
                    let key = lua_font.handle_id;
                    let state_ref = lua_font.state.clone();
                    drop(lua_font);
                    let st = state_ref.borrow();
                    let f = st.fonts.get(key).ok_or_else(|| {
                        LuaError::RuntimeError("Font handle is not valid or was released".into())
                    })?;
                    let width = f.text_width(&text) * scale;
                    let height = f.line_height() * scale;
                    Ok((width, height))
                },
            )?,
        )?;
        let _ = &s;
    }

    // -- wrapText --
    /// Wraps text into lines fitting within a maximum width. This function is available to Lua scripts.
    /// @param | font | LuaFont | Font handle.
    /// @param | text | string | Text to wrap.
    /// @param | maxWidth | number | Maximum line width in pixels.
    /// @param | scale | number | Scale factor.
    /// @param | mode | string | Wrap mode: "none", "word", or "char".
    /// @return | table | Array of wrapped line strings.
    {
        let s = state.clone();
        /// Wraps a text string into lines that fit within the given maximum pixel width.
        ///
        /// @param | font | LFont | Font handle used for measurement.
        /// @param | text | string | Text to wrap.
        /// @param | maxWidth | number | Maximum line width in pixels.
        /// @param | scale | number | Scale factor (default 1.0).
        /// @param | mode | string | Wrap mode: "none", "word", or "char".
        /// @return | table | Array of wrapped line strings.
        font.set(
            "wrapText",
            lua.create_function(
                move |lua,
                      (font_ud, text, max_width, scale, _mode): (
                    LuaAnyUserData,
                    String,
                    f32,
                    Option<f32>,
                    Option<String>,
                )| {
                    let scale = scale.unwrap_or(1.0);
                    let lua_font = font_ud.borrow::<LuaFont>()?;
                    let key = lua_font.handle_id;
                    let state_ref = lua_font.state.clone();
                    drop(lua_font);
                    let st = state_ref.borrow();
                    let f = st.fonts.get(key).ok_or_else(|| {
                        LuaError::RuntimeError("Font handle is not valid or was released".into())
                    })?;
                    let limit = if scale > 0.0 {
                        max_width / scale
                    } else {
                        max_width
                    };
                    let lines = f.wrap_text(&text, limit);
                    let tbl = lua.create_table()?;
                    for (i, line) in lines.iter().enumerate() {
                        tbl.set(i + 1, line.as_str())?;
                    }
                    Ok(tbl)
                },
            )?,
        )?;
        let _ = &s;
    }

    // -- shapeText --
    /// Shapes text into aligned, wrapped lines with offset data. This function is available to Lua scripts.
    /// @param | font | LuaFont | Font handle.
    /// @param | text | string | Text to shape.
    /// @param | maxWidth | number | Maximum line width in pixels.
    /// @param | scale | number | Scale factor.
    /// @param | align | string | Alignment: "left", "center", "right", "justify".
    /// @param | wrap | string | Wrap mode: "none", "word", "char".
    /// @return | table | Array of tables with fields: text (string), width (number), xOffset (number).
    {
        let s = state.clone();
        /// Shapes and aligns text into wrapped lines with x-offset data for rendering.
        ///
        /// @param | font | LFont | Font handle used for shaping.
        /// @param | text | string | Text to shape.
        /// @param | maxWidth | number | Maximum line width in pixels.
        /// @param | scale | number | Scale factor (default 1.0).
        /// @param | align | string | Alignment: "left", "center", "right", or "justify".
        /// @param | wrap | string | Wrap mode: "none", "word", or "char".
        /// @return | table | Array of tables with fields: text (string), width (number), xOffset (number).
        font.set(
            "shapeText",
            lua.create_function(
                move |lua,
                      (font_ud, text, max_width, scale, align, wrap): (
                    LuaAnyUserData,
                    String,
                    f32,
                    Option<f32>,
                    Option<String>,
                    Option<String>,
                )| {
                    let scale = scale.unwrap_or(1.0);
                    let align_str = align.unwrap_or_else(|| "left".to_string());
                    let wrap_str = wrap.unwrap_or_else(|| "word".to_string());

                    let lua_font = font_ud.borrow::<LuaFont>()?;
                    let key = lua_font.handle_id;
                    let state_ref = lua_font.state.clone();
                    drop(lua_font);

                    let st = state_ref.borrow();
                    let f = st.fonts.get(key).ok_or_else(|| {
                        LuaError::RuntimeError("Font handle is not valid or was released".into())
                    })?;

                    let limit = if scale > 0.0 {
                        max_width / scale
                    } else {
                        max_width
                    };

                    // Wrap lines based on mode
                    let raw_lines: Vec<String> = match wrap_str.as_str() {
                        "none" => text.split('\n').map(String::from).collect(),
                        "char" => {
                            // Character-level wrapping
                            let mut lines = Vec::new();
                            for paragraph in text.split('\n') {
                                let mut current = String::new();
                                let mut current_width = 0.0f32;
                                for ch in paragraph.chars() {
                                    let adv = f
                                        .glyph(ch)
                                        .map(|g| g.advance_width)
                                        .unwrap_or(0.0);
                                    if current_width + adv > limit && !current.is_empty() {
                                        lines.push(current);
                                        current = String::new();
                                        current_width = 0.0;
                                    }
                                    current.push(ch);
                                    current_width += adv;
                                }
                                lines.push(current);
                            }
                            lines
                        }
                        _ => f.wrap_text(&text, limit), // "word" default
                    };

                    // Compute alignment offsets
                    let tbl = lua.create_table()?;
                    for (i, line_text) in raw_lines.iter().enumerate() {
                        let width = f.text_width(line_text) * scale;
                        let x_offset = match align_str.as_str() {
                            "center" => ((max_width - width) * 0.5).max(0.0),
                            "right" => (max_width - width).max(0.0),
                            _ => 0.0, // "left" and "justify"
                        };
                        let entry = lua.create_table()?;
                        entry.set("text", line_text.as_str())?;
                        entry.set("width", width)?;
                        entry.set("xOffset", x_offset)?;
                        tbl.set(i + 1, entry)?;
                    }
                    Ok(tbl)
                },
            )?,
        )?;
        let _ = &s;
    }

    // -- charAdvance --
    /// Returns the horizontal advance width of a single character. This function is available to Lua scripts.
    /// @param | font | LuaFont | Font handle.
    /// @param | char | string | A single-character string.
    /// @param | scale | number | Scale factor.
    /// @return | number | Advance width in pixels.
    {
        let s = state.clone();
        /// Returns the horizontal advance width in pixels of a single character using the given font.
        ///
        /// @param | font | LFont | Font handle.
        /// @param | char | string | A single-character string.
        /// @param | scale | number | Scale factor (default 1.0).
        /// @return | number | Horizontal advance width in pixels.
        font.set(
            "charAdvance",
            lua.create_function(
                move |_, (font_ud, ch, scale): (LuaAnyUserData, String, Option<f32>)| {
                    let scale = scale.unwrap_or(1.0);
                    let lua_font = font_ud.borrow::<LuaFont>()?;
                    let key = lua_font.handle_id;
                    let state_ref = lua_font.state.clone();
                    drop(lua_font);
                    let st = state_ref.borrow();
                    let f = st.fonts.get(key).ok_or_else(|| {
                        LuaError::RuntimeError("Font handle is not valid or was released".into())
                    })?;
                    let c = ch.chars().next().unwrap_or(' ');
                    let adv = f.glyph(c).map(|g| g.advance_width).unwrap_or(0.0);
                    Ok(adv * scale)
                },
            )?,
        )?;
        let _ = &s;
    }

    // -- lineHeight --
    /// Returns the line height of a font in pixels. This function is available to Lua scripts.
    /// @param | font | LuaFont | Font handle.
    /// @return | number | Line height in pixels.
    {
        let s = state.clone();
        /// Returns the line height of the given font in pixels.
        ///
        /// @param | font | LFont | Font handle to query.
        /// @return | number | Line height in pixels.
        font.set(
            "lineHeight",
            lua.create_function(move |_, font_ud: LuaAnyUserData| {
                let lua_font = font_ud.borrow::<LuaFont>()?;
                let key = lua_font.handle_id;
                let state_ref = lua_font.state.clone();
                drop(lua_font);
                let st = state_ref.borrow();
                let f = st.fonts.get(key).ok_or_else(|| {
                    LuaError::RuntimeError("Font handle is not valid or was released".into())
                })?;
                Ok(f.line_height())
            })?,
        )?;
        let _ = &s;
    }

    Ok(font)
}

/// Standard module registration entry point — registers `lurek.font` and returns `Ok(())`.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let font = register_font_api(lua, state)?;
    lurek.set("font", font)?;
    Ok(())
}
