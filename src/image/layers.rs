//! Compositing layer stack for CPU-side image editing.
//!
//! This module provides [`ImageLayer`] and [`LayeredImage`], which together
//! implement a simple paint-program-style layer compositor.  Each layer holds
//! its own RGBA8 pixel buffer ([`ImageData`]), an opacity scalar, a visibility
//! flag, and a human-readable name.  The entire stack can be flattened into a
//! single [`ImageData`] via [`LayeredImage::merge`], using the standard
//! Porter-Duff "over" compositing algorithm.
//!
//! Layers are ordered from index 0 (bottom / background) to the last index
//! (top / foreground).  [`LayeredImage::add_layer`] always appends to the top.
//! Use [`LayeredImage::swap_layers`] or [`LayeredImage::move_layer`] to reorder.
//!
//! All public items are documented.  See the parent module for architectural
//! context and the `lurek.*` Lua API for the scripting interface.

use super::image_data::ImageData;

// -------------------------------------------------------------------------------
// ImageLayer
// -------------------------------------------------------------------------------

/// A single compositing layer inside a [`LayeredImage`] stack.
///
/// Each layer bundles an RGBA8 pixel buffer with per-layer blending properties.
/// Pixels are stored in the same `width × height` as the parent stack; layers
/// that are smaller than the canvas simply have transparent padding.
///
/// # Fields
/// - `name`    — `String`.  Human-readable label for the layer.
/// - `opacity` — `f32`.  Uniform opacity multiplied onto every pixel's alpha,
///   clamped to `[0.0, 1.0]`.  `1.0` = fully opaque; `0.0` = invisible.
/// - `visible` — `bool`.  When `false` the layer is skipped during [`LayeredImage::merge`].
/// - `data`    — `ImageData`.  RGBA8 pixel buffer for this layer.
#[derive(Debug, Clone)]
pub struct ImageLayer {
    /// Human-readable name for this layer.
    pub name: String,
    /// Per-layer opacity multiplier, clamped to `[0.0, 1.0]`.
    pub opacity: f32,
    /// Whether this layer participates in compositing.
    pub visible: bool,
    /// RGBA8 pixel buffer for this layer.
    pub data: ImageData,
}

impl ImageLayer {
    /// Create a new transparent layer with the given canvas dimensions.
    ///
    /// # Parameters
    /// - `name`   — `String`. Human-readable label.
    /// - `width`  — `u32`.   Canvas width in pixels.
    /// - `height` — `u32`.   Canvas height in pixels.
    ///
    /// # Returns
    /// `Self` — a blank (fully transparent) layer.
    pub fn new(name: impl Into<String>, width: u32, height: u32) -> Self {
        Self {
            name: name.into(),
            opacity: 1.0,
            visible: true,
            data: ImageData::new(width, height),
        }
    }
}

// -------------------------------------------------------------------------------
// LayeredImage
// -------------------------------------------------------------------------------

/// A compositing stack of [`ImageLayer`] values sharing the same canvas size.
///
/// Layers are stored in bottom-to-top order (index 0 = background).
/// [`add_layer`](Self::add_layer) appends to the top.
/// [`merge`](Self::merge) flattens all visible layers into a single [`ImageData`]
/// using Porter-Duff "over" compositing.
///
/// # Usage Sequence
/// 1. `LayeredImage::new(width, height)` — create the canvas.
/// 2. `add_layer(name)` — append transparent layers.
/// 3. Edit each layer through [`ImageLayer::data`] (via [`get_layer_mut`](Self::get_layer_mut)).
/// 4. Adjust `opacity` and `visible` per layer.
/// 5. `merge()` → flat [`ImageData`] ready for display or export.
///
/// # Fields
/// - `width`  — `u32`. Canvas width shared by all layers.
/// - `height` — `u32`. Canvas height shared by all layers.
/// - `layers` — `Vec<ImageLayer>`. Ordered stack, index 0 = bottom.
#[derive(Debug, Clone)]
pub struct LayeredImage {
    /// Canvas width in pixels; all layers share this dimension.
    pub(super) width: u32,
    /// Canvas height in pixels; all layers share this dimension.
    pub(super) height: u32,
    /// Layer stack in bottom-to-top order.
    pub(super) layers: Vec<ImageLayer>,
}

impl LayeredImage {
    /// Create an empty layer stack with no layers.
    ///
    /// # Parameters
    /// - `width`  — `u32`. Canvas width in pixels.
    /// - `height` — `u32`. Canvas height in pixels.
    ///
    /// # Returns
    /// `Self` — a stack with zero layers.
    pub fn new(width: u32, height: u32) -> Self {
        Self {
            width,
            height,
            layers: Vec::new(),
        }
    }

    /// Canvas width shared by all layers.
    ///
    /// # Returns
    /// `u32`.
    pub fn width(&self) -> u32 {
        self.width
    }

    /// Canvas height shared by all layers.
    ///
    /// # Returns
    /// `u32`.
    pub fn height(&self) -> u32 {
        self.height
    }

    /// Number of layers currently in the stack.
    ///
    /// # Returns
    /// `usize`.
    pub fn layer_count(&self) -> usize {
        self.layers.len()
    }

    /// Append a new blank (transparent) layer on top of the stack and return its index.
    ///
    /// # Parameters
    /// - `name` — `&str`. Human-readable name for the new layer.
    ///
    /// # Returns
    /// `usize` — zero-based index of the newly created layer.
    pub fn add_layer(&mut self, name: impl Into<String>) -> usize {
        self.layers
            .push(ImageLayer::new(name, self.width, self.height));
        self.layers.len() - 1
    }

    /// Remove the layer at the given index and return it.  Returns `None` if
    /// the index is out of range.
    ///
    /// # Parameters
    /// - `index` — `usize`. Zero-based layer index.
    ///
    /// # Returns
    /// `Option<ImageLayer>`.
    pub fn remove_layer(&mut self, index: usize) -> Option<ImageLayer> {
        if index < self.layers.len() {
            Some(self.layers.remove(index))
        } else {
            None
        }
    }

    /// Immutable access to a layer by index.
    ///
    /// # Parameters
    /// - `index` — `usize`. Zero-based layer index.
    ///
    /// # Returns
    /// `Option<&ImageLayer>`.
    pub fn get_layer(&self, index: usize) -> Option<&ImageLayer> {
        self.layers.get(index)
    }

    /// Mutable access to a layer by index.
    ///
    /// # Parameters
    /// - `index` — `usize`. Zero-based layer index.
    ///
    /// # Returns
    /// `Option<&mut ImageLayer>`.
    pub fn get_layer_mut(&mut self, index: usize) -> Option<&mut ImageLayer> {
        self.layers.get_mut(index)
    }

    /// Set the opacity of a layer.  The value is clamped to `[0.0, 1.0]`.
    ///
    /// # Parameters
    /// - `index`   — `usize`. Zero-based layer index.
    /// - `opacity` — `f32`.  Opacity in `[0.0, 1.0]`.
    ///
    /// # Returns
    /// `bool` — `true` if the layer existed and was updated.
    pub fn set_opacity(&mut self, index: usize, opacity: f32) -> bool {
        if let Some(layer) = self.layers.get_mut(index) {
            layer.opacity = opacity.clamp(0.0, 1.0);
            true
        } else {
            false
        }
    }

    /// Set the visibility of a layer.  Invisible layers are skipped in [`merge`](Self::merge).
    ///
    /// # Parameters
    /// - `index`   — `usize`. Zero-based layer index.
    /// - `visible` — `bool`.
    ///
    /// # Returns
    /// `bool` — `true` if the layer existed and was updated.
    pub fn set_visible(&mut self, index: usize, visible: bool) -> bool {
        if let Some(layer) = self.layers.get_mut(index) {
            layer.visible = visible;
            true
        } else {
            false
        }
    }

    /// Rename a layer.
    ///
    /// # Parameters
    /// - `index` — `usize`. Zero-based layer index.
    /// - `name`  — `&str`.  New human-readable name.
    ///
    /// # Returns
    /// `bool` — `true` if the layer existed and was renamed.
    pub fn set_name(&mut self, index: usize, name: impl Into<String>) -> bool {
        if let Some(layer) = self.layers.get_mut(index) {
            layer.name = name.into();
            true
        } else {
            false
        }
    }

    /// Replace a layer's pixel buffer with a clone of the given [`ImageData`].
    /// The `ImageData` is re-sampled to the canvas size if its dimensions differ.
    /// Returns `false` if the index is out of range.
    ///
    /// # Parameters
    /// - `index`  — `usize`. Zero-based layer index.
    /// - `source` — `&ImageData`. Source pixel buffer.
    ///
    /// # Returns
    /// `bool`.
    pub fn set_layer_image(&mut self, index: usize, source: &ImageData) -> bool {
        if let Some(layer) = self.layers.get_mut(index) {
            if source.width() == self.width && source.height() == self.height {
                layer.data = source.clone();
            } else {
                // Paste into a fresh canvas of the correct size
                let mut canvas = ImageData::new(self.width, self.height);
                canvas.paste(source, 0, 0);
                layer.data = canvas;
            }
            true
        } else {
            false
        }
    }

    /// Swap two layers by index within the stack, changing their compositing order.
    ///
    /// # Parameters
    /// - `a` — `usize`. Zero-based index of the first layer.
    /// - `b` — `usize`. Zero-based index of the second layer.
    ///
    /// # Returns
    /// `bool` — `false` if either index is out of range or they are the same.
    pub fn swap_layers(&mut self, a: usize, b: usize) -> bool {
        let len = self.layers.len();
        if a >= len || b >= len || a == b {
            return false;
        }
        self.layers.swap(a, b);
        true
    }

    /// Move a layer from `from_index` to `to_index`, shifting all layers in
    /// between.  This is equivalent to remove + insert.
    ///
    /// # Parameters
    /// - `from_index` — `usize`. Current zero-based index of the layer to move.
    /// - `to_index`   — `usize`. Target zero-based position.
    ///
    /// # Returns
    /// `bool` — `false` if either index is out of range.
    pub fn move_layer(&mut self, from_index: usize, to_index: usize) -> bool {
        let len = self.layers.len();
        if from_index >= len || to_index >= len {
            return false;
        }
        let layer = self.layers.remove(from_index);
        self.layers.insert(to_index, layer);
        true
    }

    /// Flatten all visible layers into a single [`ImageData`] using Porter-Duff
    /// "over" compositing.
    ///
    /// Compositing is performed from the bottom layer (index 0) upward.  Each
    /// visible layer's per-pixel alpha is multiplied by the layer's `opacity`
    /// scalar before blending.  The output image is always the same size as
    /// the canvas (`width × height`).
    ///
    /// # Returns
    /// `ImageData` — the flattened image (RGBA8, same size as the canvas).
    pub fn merge(&self) -> ImageData {
        let mut result = ImageData::new(self.width, self.height);
        let pixels_len = (self.width * self.height * 4) as usize;
        let dst = result.pixels.as_mut_slice();

        for layer in &self.layers {
            if !layer.visible {
                continue;
            }
            let src = layer.data.pixels.as_slice();
            let src_len = src.len().min(pixels_len);
            let px_count = src_len / 4;

            for i in 0..px_count {
                let si = i * 4;
                let sr = src[si] as f32;
                let sg = src[si + 1] as f32;
                let sb = src[si + 2] as f32;
                let sa = src[si + 3] as f32 / 255.0 * layer.opacity;

                if sa <= 0.0 {
                    continue;
                }

                let dr = dst[si] as f32;
                let dg = dst[si + 1] as f32;
                let db = dst[si + 2] as f32;
                let da = dst[si + 3] as f32 / 255.0;

                // Porter-Duff "over": out_a = sa + da*(1-sa)
                let out_a = sa + da * (1.0 - sa);
                if out_a <= 0.0 {
                    dst[si] = 0;
                    dst[si + 1] = 0;
                    dst[si + 2] = 0;
                    dst[si + 3] = 0;
                } else {
                    dst[si] = ((sr * sa + dr * da * (1.0 - sa)) / out_a).round() as u8;
                    dst[si + 1] = ((sg * sa + dg * da * (1.0 - sa)) / out_a).round() as u8;
                    dst[si + 2] = ((sb * sa + db * da * (1.0 - sa)) / out_a).round() as u8;
                    dst[si + 3] = (out_a * 255.0).round().min(255.0) as u8;
                }
            }
        }
        result
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn new_layer_is_transparent() {
        let layer = ImageLayer::new("bg", 4, 4);
        assert_eq!(layer.name, "bg");
        assert_eq!(layer.opacity, 1.0);
        assert!(layer.visible);
        // All pixels should be transparent black
        assert!(layer.data.as_bytes().iter().all(|&b| b == 0));
    }

    #[test]
    fn new_layered_image_has_zero_layers() {
        let li = LayeredImage::new(32, 32);
        assert_eq!(li.width(), 32);
        assert_eq!(li.height(), 32);
        assert_eq!(li.layer_count(), 0);
    }

    #[test]
    fn add_and_remove_layer() {
        let mut li = LayeredImage::new(8, 8);
        let idx = li.add_layer("first");
        assert_eq!(idx, 0);
        assert_eq!(li.layer_count(), 1);
        let removed = li.remove_layer(0);
        assert!(removed.is_some());
        assert_eq!(li.layer_count(), 0);
    }

    #[test]
    fn remove_out_of_bounds_returns_none() {
        let mut li = LayeredImage::new(4, 4);
        assert!(li.remove_layer(0).is_none());
    }

    #[test]
    fn get_layer_by_index() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("a");
        li.add_layer("b");
        assert_eq!(li.get_layer(0).unwrap().name, "a");
        assert_eq!(li.get_layer(1).unwrap().name, "b");
        assert!(li.get_layer(2).is_none());
    }

    #[test]
    fn set_opacity_clamps() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("x");
        assert!(li.set_opacity(0, 1.5));
        assert_eq!(li.get_layer(0).unwrap().opacity, 1.0);
        assert!(li.set_opacity(0, -0.5));
        assert_eq!(li.get_layer(0).unwrap().opacity, 0.0);
        assert!(!li.set_opacity(5, 0.5)); // out of bounds
    }

    #[test]
    fn set_visible_toggles() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("x");
        assert!(li.set_visible(0, false));
        assert!(!li.get_layer(0).unwrap().visible);
    }

    #[test]
    fn set_name_renames() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("old");
        assert!(li.set_name(0, "new"));
        assert_eq!(li.get_layer(0).unwrap().name, "new");
    }

    #[test]
    fn swap_layers_changes_order() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("bottom");
        li.add_layer("top");
        assert!(li.swap_layers(0, 1));
        assert_eq!(li.get_layer(0).unwrap().name, "top");
        assert_eq!(li.get_layer(1).unwrap().name, "bottom");
    }

    #[test]
    fn swap_same_index_returns_false() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("a");
        assert!(!li.swap_layers(0, 0));
    }

    #[test]
    fn move_layer_reorders() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("a");
        li.add_layer("b");
        li.add_layer("c");
        assert!(li.move_layer(2, 0));
        assert_eq!(li.get_layer(0).unwrap().name, "c");
    }

    #[test]
    fn merge_empty_stack_returns_blank() {
        let li = LayeredImage::new(4, 4);
        let merged = li.merge();
        assert_eq!(merged.width(), 4);
        assert_eq!(merged.height(), 4);
        assert!(merged.as_bytes().iter().all(|&b| b == 0));
    }

    #[test]
    fn merge_single_opaque_layer() {
        let mut li = LayeredImage::new(2, 2);
        li.add_layer("bg");
        if let Some(layer) = li.get_layer_mut(0) {
            layer.data.set_pixel(0, 0, 255, 0, 0, 255);
        }
        let merged = li.merge();
        assert_eq!(merged.get_pixel(0, 0), Some((255, 0, 0, 255)));
    }

    #[test]
    fn merge_skips_invisible_layers() {
        let mut li = LayeredImage::new(2, 2);
        li.add_layer("bg");
        if let Some(layer) = li.get_layer_mut(0) {
            layer.data.set_pixel(0, 0, 255, 0, 0, 255);
            layer.visible = false;
        }
        let merged = li.merge();
        // Invisible → should be blank
        assert_eq!(merged.get_pixel(0, 0), Some((0, 0, 0, 0)));
    }

    #[test]
    fn merge_respects_opacity() {
        let mut li = LayeredImage::new(1, 1);
        li.add_layer("half");
        li.set_opacity(0, 0.5);
        if let Some(layer) = li.get_layer_mut(0) {
            layer.data.set_pixel(0, 0, 200, 100, 50, 255);
        }
        let merged = li.merge();
        let (_, _, _, a) = merged.get_pixel(0, 0).unwrap();
        // With 0.5 opacity on a 255-alpha pixel, effective alpha ≈ 0.5 → ~128
        assert!((a as i32 - 128).abs() <= 1);
    }

    #[test]
    fn set_layer_image_replaces_data() {
        let mut li = LayeredImage::new(4, 4);
        li.add_layer("target");
        let mut src = ImageData::new(4, 4);
        src.set_pixel(1, 1, 42, 84, 126, 200);
        assert!(li.set_layer_image(0, &src));
        assert_eq!(
            li.get_layer(0).unwrap().data.get_pixel(1, 1),
            Some((42, 84, 126, 200))
        );
    }
}
