//! Implements a named texture atlas that packs image regions and records their placement inside one sheet.
//! Stores atlas dimensions, padding, shelf state, and region metadata so sprite lookup stays data driven.
//! Supports optional nine-slice insets per region, making UI skin assets travel with their packing metadata.
//! Exposes region counts, atlas size, and immutable region views for tools that inspect generated sprite maps.
//! Open this file when atlas packing, region lookup, or nine-slice metadata does not match authored assets.

use crate::image::RectPacker;
use crate::sprite::SpriteLimits;
use std::collections::HashMap;
/// # Fields
///
/// Nine-slice border distances used to preserve corners and edges.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct NineSliceInsets {
    /// Left border width in pixels.
    pub left: u32,
    /// Right border width in pixels.
    pub right: u32,
    /// Top border height in pixels.
    pub top: u32,
    /// Bottom border height in pixels.
    pub bottom: u32,
}
/// # Fields
///
/// A packed atlas region with coordinates, size, and optional nine-slice data.
#[derive(Debug, Clone)]
pub struct AtlasRegion {
    /// Region name used for lookup.
    pub name: String,
    /// Left coordinate in atlas pixels.
    pub x: u32,
    /// Top coordinate in atlas pixels.
    pub y: u32,
    /// Region width in pixels.
    pub w: u32,
    /// Region height in pixels.
    pub h: u32,
    /// Optional nine-slice border metadata.
    pub nine_slice: Option<NineSliceInsets>,
}
/// # Variants
///
/// Why a runtime atlas insertion was rejected.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AtlasPackError {
    /// The name already identifies a packed region.
    Duplicate,
    /// Name, dimensions, insets, or configured capacity are invalid.
    Invalid,
    /// Checked coordinate arithmetic overflowed.
    Overflow,
    /// The generic rectangle packer has no remaining space.
    Full,
}

impl AtlasPackError {
    /// Stable Lua-facing diagnostic code.
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::Duplicate => "duplicate",
            Self::Invalid => "invalid",
            Self::Overflow => "overflow",
            Self::Full => "full",
        }
    }
}
/// # Fields
///
/// Shelf-based texture atlas for packing named regions into a fixed canvas.
pub struct TextureAtlas {
    /// Atlas width in pixels.
    pub width: u32,
    /// Atlas height in pixels.
    pub height: u32,
    /// Padding added around packed regions.
    pub padding: u32,
    /// Packed regions keyed by name.
    regions: HashMap<String, AtlasRegion>,
    /// Canonical generic rectangle packer; sprite retains only region metadata.
    packer: RectPacker,
}
impl TextureAtlas {
    /// Validate runtime atlas dimensions before constructing the generic packer.
    pub fn validate_dimensions(width: u32, height: u32, padding: u32) -> Result<(), String> {
        if width == 0 || height == 0 {
            return Err("atlas dimensions must be greater than zero".into());
        }
        if width > SpriteLimits::MAX_ATLAS_DIMENSION || height > SpriteLimits::MAX_ATLAS_DIMENSION {
            return Err(format!(
                "atlas dimensions exceed {} pixels",
                SpriteLimits::MAX_ATLAS_DIMENSION
            ));
        }
        if padding > SpriteLimits::MAX_ATLAS_PADDING || padding >= width || padding >= height {
            return Err("atlas padding is invalid for the atlas dimensions".into());
        }
        let area = u64::from(width) * u64::from(height);
        if area > SpriteLimits::MAX_ATLAS_AREA {
            return Err(format!(
                "atlas area exceeds {} pixels",
                SpriteLimits::MAX_ATLAS_AREA
            ));
        }
        Ok(())
    }
    /// Create an empty atlas with the given dimensions and padding.
    pub fn new(width: u32, height: u32, padding: u32) -> Self {
        let usable_width = width.saturating_sub(padding);
        let usable_height = height.saturating_sub(padding);
        Self {
            width,
            height,
            padding,
            regions: HashMap::new(),
            packer: RectPacker::new(usable_width, usable_height, padding),
        }
    }
    /// Strict constructor used for untrusted/public atlas creation.
    pub fn try_new(width: u32, height: u32, padding: u32) -> Result<Self, String> {
        Self::validate_dimensions(width, height, padding)?;
        Ok(Self::new(width, height, padding))
    }
    /// Pack a region without nine-slice metadata and return whether it fit.
    pub fn pack(&mut self, name: &str, w: u32, h: u32) -> bool {
        self.pack_checked(name, w, h, None).is_ok()
    }
    /// Pack a region and return a typed reason when it cannot be allocated.
    pub fn pack_checked(
        &mut self,
        name: &str,
        w: u32,
        h: u32,
        nine_slice: Option<NineSliceInsets>,
    ) -> Result<(), AtlasPackError> {
        if name.is_empty()
            || name.len() > SpriteLimits::MAX_NAME_BYTES
            || w == 0
            || h == 0
            || self.regions.len() >= SpriteLimits::MAX_ATLAS_ENTRIES
        {
            return Err(AtlasPackError::Invalid);
        }
        if let Some(insets) = nine_slice {
            if insets
                .left
                .checked_add(insets.right)
                .is_none_or(|sum| sum > w)
                || insets
                    .top
                    .checked_add(insets.bottom)
                    .is_none_or(|sum| sum > h)
            {
                return Err(AtlasPackError::Invalid);
            }
        }
        if self.regions.contains_key(name) {
            return Err(AtlasPackError::Duplicate);
        }
        let packed = self
            .packer
            .pack(w, h, Some(name.to_string()))
            .ok_or(AtlasPackError::Full)?;
        let x = packed
            .x
            .checked_add(self.padding)
            .ok_or(AtlasPackError::Overflow)?;
        let y = packed
            .y
            .checked_add(self.padding)
            .ok_or(AtlasPackError::Overflow)?;
        self.regions.insert(
            name.to_string(),
            AtlasRegion {
                name: name.to_string(),
                x,
                y,
                w,
                h,
                nine_slice,
            },
        );
        Ok(())
    }
    /// Pack a region with optional nine-slice metadata and return whether it fit.
    pub fn pack_with_nine_slice(
        &mut self,
        name: &str,
        w: u32,
        h: u32,
        nine_slice: Option<NineSliceInsets>,
    ) -> bool {
        self.pack_checked(name, w, h, nine_slice).is_ok()
    }
    /// Update the nine-slice metadata for a packed region and return whether it fit.
    pub fn set_nine_slice(&mut self, name: &str, nine_slice: Option<NineSliceInsets>) -> bool {
        let Some(region) = self.regions.get_mut(name) else {
            return false;
        };
        if let Some(insets) = nine_slice {
            if insets
                .left
                .checked_add(insets.right)
                .is_none_or(|sum| sum > region.w)
                || insets
                    .top
                    .checked_add(insets.bottom)
                    .is_none_or(|sum| sum > region.h)
            {
                return false;
            }
        }
        region.nine_slice = nine_slice;
        true
    }
    /// Return a packed region by name.
    pub fn get_region(&self, name: &str) -> Option<&AtlasRegion> {
        self.regions.get(name)
    }
    /// Return the number of packed regions.
    pub fn get_region_count(&self) -> usize {
        self.regions.len()
    }
    /// Return the atlas dimensions.
    pub fn get_dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }
    /// Return all packed regions as borrowed values.
    pub fn get_regions(&self) -> Vec<&AtlasRegion> {
        let mut regions: Vec<_> = self.regions.values().collect();
        regions.sort_by(|a, b| a.name.cmp(&b.name));
        regions
    }
    /// Remove all packed regions and shelves.
    pub fn clear(&mut self) {
        self.regions.clear();
        self.packer.clear();
    }
}
