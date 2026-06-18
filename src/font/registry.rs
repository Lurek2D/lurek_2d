//! `src/font/registry.rs` owns runtime font registration, handle allocation, and lookup by name for loaded bitmap fonts.
//! It defines `FontStyle`, `FontHandle`, and `FontRegistry`, keeping public font identity separate from raw font storage.
//! Replacement, default-font selection, and registration order live here so text consumers share one asset authority.
//! Open this file when font ownership, lookup semantics, or public handle metadata for runtime text assets must change.
//! Neighboring systems should treat this file as the font boundary for asset access, not the place for shaping or metrics.

use std::collections::HashMap;

use crate::font::bitmap_font::BitmapFont;

/// Font style variant (regular, bold, italic, or bold-italic).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum FontStyle {
    /// Normal weight, upright.
    Regular,
    /// Bold weight, upright.
    Bold,
    /// Normal weight, italic.
    Italic,
    /// Bold weight, italic.
    BoldItalic,
}

/// An opaque handle to a registered font.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub struct FontHandle {
    /// Internal font identifier.
    pub id: u32,
    /// Human-readable font name.
    pub name: String,
    /// Point size of the font.
    pub size: u32,
    /// Style variant.
    pub style: FontStyle,
}

/// Central font storage mapping handles and names to loaded fonts.
#[derive(Debug)]
pub struct FontRegistry {
    /// Fonts indexed by handle ID.
    fonts: HashMap<u32, BitmapFont>,
    /// Name-to-ID lookup.
    by_name: HashMap<String, u32>,
    /// Stable registration order for unique font names.
    order: Vec<String>,
    /// Next available handle ID.
    next_id: u32,
}

impl FontRegistry {
    /// Creates an empty font registry.
    pub fn new() -> Self {
        Self {
            fonts: HashMap::new(),
            by_name: HashMap::new(),
            order: Vec::new(),
            next_id: 1,
        }
    }

    /// Registers a font and returns its handle.
    ///
    /// If a font with the same name already exists, it is replaced.
    pub fn register(&mut self, name: &str, font: BitmapFont) -> FontHandle {
        if let Some(existing_id) = self.by_name.get(name).copied() {
            self.fonts.remove(&existing_id);
        } else {
            self.order.push(name.to_string());
        }

        let id = self.next_id;
        self.next_id += 1;

        let size = font.point_size();
        let style = if font.is_bold() {
            FontStyle::Bold
        } else {
            FontStyle::Regular
        };

        self.fonts.insert(id, font);
        self.by_name.insert(name.to_string(), id);

        FontHandle {
            id,
            name: name.to_string(),
            size,
            style,
        }
    }

    /// Retrieves a font by its handle.
    pub fn get(&self, handle: &FontHandle) -> Option<&BitmapFont> {
        self.fonts.get(&handle.id)
    }

    /// Retrieves a font by its registered name.
    pub fn get_by_name(&self, name: &str) -> Option<&BitmapFont> {
        let id = self.by_name.get(name)?;
        self.fonts.get(id)
    }

    /// Returns the first registered font, or `None` if the registry is empty.
    pub fn default_font(&self) -> Option<&BitmapFont> {
        for name in &self.order {
            if let Some(id) = self.by_name.get(name) {
                if let Some(font) = self.fonts.get(id) {
                    return Some(font);
                }
            }
        }
        None
    }

    /// Lists all registered font handles.
    pub fn list_fonts(&self) -> Vec<FontHandle> {
        self.order
            .iter()
            .filter_map(|name| {
                let id = *self.by_name.get(name)?;
                let font = self.fonts.get(&id)?;
                Some(FontHandle {
                    id,
                    name: name.clone(),
                    size: font.point_size(),
                    style: if font.is_bold() {
                        FontStyle::Bold
                    } else {
                        FontStyle::Regular
                    },
                })
            })
            .collect()
    }
}

impl Default for FontRegistry {
    fn default() -> Self {
        Self::new()
    }
}
