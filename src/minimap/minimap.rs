//! `src/minimap/minimap.rs` owns the `Minimap` state object that stores terrain, fog, markers, overlays, and view settings.
//! It is the main data and behavior boundary for minimap grids, terrain palettes, owner colors, icons, layers, and paths.
//! Object types, live objects, pings, marker animations, and viewport outlines are updated here with local state.
//! Camera tracking, pan and zoom, hover lookup, and grid-to-screen coordinate conversion also live in this implementation.
//! The file exposes mutation APIs for terrain, fog, objects, markers, overlays, paths, layers, and display configuration.
//! Export helpers such as `draw_to_image` and render-command entry points are defined here for sibling use.
//! Internal helpers resolve active cell colors and owner mappings so terrain and political display modes stay consistent.
//! This file does not import province data or compute raycast visibility; dedicated adapters handle those translations.
//! Read it when minimap ownership, per-frame updates, view math, or public state mutation behavior needs to change.

use super::types::{
    ColorMode, FogLevel, LayerData, MarkerAnimation, MinimapError, MinimapLimits, MinimapMarker,
    MinimapObject, MinimapObjectType, MinimapPing, MinimapValidationLimits, OverlayPath,
    OverlayShape,
};
use crate::camera::Camera2D;
use crate::log_msg;
use crate::runtime::log_messages::MM01_MINIMAP_INIT;
use crate::runtime::resource_keys::TextureKey;
use std::collections::HashMap;

/// Cached icon dimensions for one object type or marker texture slot.
#[derive(Debug, Clone, Copy)]
pub(crate) struct MinimapIcon {
    /// Texture resource key in the runtime texture cache.
    pub texture_key: TextureKey,
    /// Pixel width of the source texture region.
    pub texture_width: f32,
    /// Pixel height of the source texture region.
    pub texture_height: f32,
    /// Pixel width to draw the icon on-screen.
    pub display_width: f32,
    /// Pixel height to draw the icon on-screen.
    pub display_height: f32,
}

/// Complete minimap state: terrain, fog, objects, markers, overlays, and rendering configuration.
#[derive(Debug, Clone)]
pub struct Minimap {
    /// Number of grid columns.
    grid_width: u32,
    /// Number of grid rows.
    grid_height: u32,
    /// Pixel width of the minimap display area.
    display_width: u32,
    /// Pixel height of the minimap display area.
    display_height: u32,
    /// Hard guardrails for allocations and collection sizes.
    limits: MinimapLimits,
    /// Validation policy for public float and text inputs.
    validation: MinimapValidationLimits,
    /// Flat terrain type array indexed by `y * grid_width + x`.
    terrain: Vec<u32>,
    /// RGBA colour associated with each terrain type id.
    terrain_colors: HashMap<u32, [f32; 4]>,
    /// Human-readable description strings for each terrain type id.
    tile_descriptions: HashMap<u32, String>,
    /// Fog values per cell: 0 = hidden, 1 = explored, 2 = visible.
    fog: Vec<u8>,
    /// Whether fog-of-war rendering is active.
    fog_enabled: bool,
    /// RGBA colour used to tint hidden fog cells.
    fog_color: [f32; 4],
    /// Live minimap objects (units, buildings, etc.) keyed by game id.
    objects: HashMap<u32, MinimapObject>,
    /// Registered object type descriptors indexed by type index.
    object_types: Vec<MinimapObjectType>,
    /// Optional custom icon for each object type index.
    object_type_icons: HashMap<usize, MinimapIcon>,
    /// RGBA colour assigned to each owner id for political colour mode.
    owner_colors: HashMap<u32, [f32; 4]>,
    /// Active colour mode: terrain colours or political owner colours.
    color_mode: ColorMode,
    /// Zoom factor; values > 1.0 enlarge the view, values < 1.0 show more of the map.
    zoom: f32,
    /// World-space X coordinate the minimap is currently centred on.
    center_x: f32,
    /// World-space Y coordinate the minimap is currently centred on.
    center_y: f32,
    /// Optional camera viewport rectangle `(x, y, w, h)` drawn as an outline.
    viewport_rect: Option<(f32, f32, f32, f32)>,
    /// Whether the viewport rectangle outline is visible.
    viewport_visible: bool,
    /// RGBA colour of the viewport rectangle outline.
    viewport_color: [f32; 4],
    /// Active pings with countdown timers.
    pings: Vec<MinimapPing>,
    /// Named markers keyed by auto-incrementing id.
    markers: HashMap<u32, MinimapMarker>,
    /// Optional custom icon for each marker id.
    marker_icons: HashMap<u32, MinimapIcon>,
    /// Counter for the next auto-assigned marker id.
    next_marker_id: u32,
    /// Whether anti-aliasing is applied during pixel render.
    anti_alias: bool,
    /// Whether the minimap responds to click events.
    clickable: bool,
    /// Vector overlay shapes drawn each frame.
    overlay_shapes: Vec<OverlayShape>,
    /// Named overlay paths (polylines).
    paths: Vec<OverlayPath>,
    /// Counter for the next auto-assigned path id.
    next_path_id: u32,
    /// Multi-layer cell data; index is the layer number.
    layers: Vec<LayerData>,
    /// Currently active render layer index.
    active_layer: usize,
}

impl Minimap {
    fn checked_grid_product(grid_width: u32, grid_height: u32) -> Result<u32, MinimapError> {
        grid_width
            .checked_mul(grid_height)
            .ok_or(MinimapError::GridCellOverflow {
                grid_width,
                grid_height,
            })
    }

    fn checked_pixel_count(width: u32, height: u32) -> Result<u64, MinimapError> {
        u64::from(width)
            .checked_mul(u64::from(height))
            .ok_or(MinimapError::PixelLimitExceeded {
                pixel_count: u64::MAX,
                limit: u64::MAX,
            })
    }

    fn checked_rgba_bytes(width: u32, height: u32) -> Result<u64, MinimapError> {
        Self::checked_pixel_count(width, height)?
            .checked_mul(4)
            .ok_or(MinimapError::OutputByteLimitExceeded {
                byte_count: u64::MAX,
                limit: u64::MAX,
            })
    }

    fn validate_dimensions(
        grid_width: u32,
        grid_height: u32,
        display_width: u32,
        display_height: u32,
        limits: MinimapLimits,
    ) -> Result<usize, MinimapError> {
        if grid_width == 0 || grid_height == 0 {
            return Err(MinimapError::GridDimensionsZero);
        }
        if display_width == 0 || display_height == 0 {
            return Err(MinimapError::DisplayDimensionsZero {
                width: display_width,
                height: display_height,
            });
        }
        let cell_count_u32 = Self::checked_grid_product(grid_width, grid_height)?;
        let cell_count = cell_count_u32 as usize;
        if cell_count > limits.max_grid_cells {
            return Err(MinimapError::GridCellLimitExceeded {
                cell_count,
                limit: limits.max_grid_cells,
            });
        }
        let display_pixels = Self::checked_pixel_count(display_width, display_height)?;
        if display_pixels > limits.max_display_pixels {
            return Err(MinimapError::PixelLimitExceeded {
                pixel_count: display_pixels,
                limit: limits.max_display_pixels,
            });
        }
        let output_bytes = Self::checked_rgba_bytes(display_width, display_height)?;
        if output_bytes > limits.max_output_bytes {
            return Err(MinimapError::OutputByteLimitExceeded {
                byte_count: output_bytes,
                limit: limits.max_output_bytes,
            });
        }
        Ok(cell_count)
    }

    fn clamp_color(field: &'static str, color: [f32; 4]) -> Result<[f32; 4], MinimapError> {
        if color.iter().any(|channel| !channel.is_finite()) {
            return Err(MinimapError::InvalidColor { field });
        }
        Ok(color.map(|channel| channel.clamp(0.0, 1.0)))
    }

    fn validate_finite(&self, field: &'static str, value: f32) -> Result<f32, MinimapError> {
        if !value.is_finite() {
            return Err(MinimapError::InvalidFloat { field });
        }
        if value.abs() > self.validation.max_coordinate_abs {
            return Err(MinimapError::InvalidFloat { field });
        }
        Ok(value)
    }

    fn validate_description(&self, field: &'static str, value: &str) -> Result<(), MinimapError> {
        let len = value.len();
        if len > self.validation.max_description_len {
            return Err(MinimapError::DescriptionTooLong {
                field,
                len,
                limit: self.validation.max_description_len,
            });
        }
        Ok(())
    }

    /// Return cached view-to-screen transform metrics shared by sibling minimap render helpers.
    pub(crate) fn transform_metrics(&self) -> Result<(f32, f32, f32, f32, f32, f32), MinimapError> {
        if self.grid_width == 0 || self.grid_height == 0 {
            return Err(MinimapError::TransformUnavailable {
                reason: "grid dimensions are zero",
            });
        }
        if self.display_width == 0 || self.display_height == 0 {
            return Err(MinimapError::TransformUnavailable {
                reason: "display dimensions are zero",
            });
        }
        if !self.zoom.is_finite() || self.zoom <= 0.0 {
            return Err(MinimapError::TransformUnavailable {
                reason: "zoom is non-finite or non-positive",
            });
        }
        let gw = self.grid_width as f32;
        let gh = self.grid_height as f32;
        let cells_visible_x = gw / self.zoom;
        let cells_visible_y = gh / self.zoom;
        if !cells_visible_x.is_finite()
            || !cells_visible_y.is_finite()
            || cells_visible_x <= 0.0
            || cells_visible_y <= 0.0
        {
            return Err(MinimapError::TransformUnavailable {
                reason: "visible cell span is invalid",
            });
        }
        let cell_px_w = self.display_width as f32 / cells_visible_x;
        let cell_px_h = self.display_height as f32 / cells_visible_y;
        if !cell_px_w.is_finite() || !cell_px_h.is_finite() || cell_px_w <= 0.0 || cell_px_h <= 0.0
        {
            return Err(MinimapError::TransformUnavailable {
                reason: "cell pixel size is invalid",
            });
        }
        let start_x = self.center_x - cells_visible_x / 2.0;
        let start_y = self.center_y - cells_visible_y / 2.0;
        if !start_x.is_finite() || !start_y.is_finite() {
            return Err(MinimapError::TransformUnavailable {
                reason: "transform origin is non-finite",
            });
        }
        Ok((
            cells_visible_x,
            cells_visible_y,
            cell_px_w,
            cell_px_h,
            start_x,
            start_y,
        ))
    }

    fn image_dimensions(&self, pixel_size: u32) -> Result<(u32, u32), MinimapError> {
        let (width, height) = if pixel_size > 0 {
            let width = self.grid_width.checked_mul(pixel_size).ok_or(
                MinimapError::PixelLimitExceeded {
                    pixel_count: u64::MAX,
                    limit: self.limits.max_display_pixels,
                },
            )?;
            let height = self.grid_height.checked_mul(pixel_size).ok_or(
                MinimapError::PixelLimitExceeded {
                    pixel_count: u64::MAX,
                    limit: self.limits.max_display_pixels,
                },
            )?;
            (width, height)
        } else {
            (self.display_width, self.display_height)
        };
        if width == 0 || height == 0 {
            return Err(MinimapError::DisplayDimensionsZero { width, height });
        }
        let pixel_count = Self::checked_pixel_count(width, height)?;
        if pixel_count > self.limits.max_display_pixels {
            return Err(MinimapError::PixelLimitExceeded {
                pixel_count,
                limit: self.limits.max_display_pixels,
            });
        }
        let byte_count = Self::checked_rgba_bytes(width, height)?;
        if byte_count > self.limits.max_output_bytes {
            return Err(MinimapError::OutputByteLimitExceeded {
                byte_count,
                limit: self.limits.max_output_bytes,
            });
        }
        Ok((width, height))
    }

    /// Create a minimap with the given grid and display dimensions; logs MM01.
    pub fn new(grid_width: u32, grid_height: u32, display_width: u32, display_height: u32) -> Self {
        Self::try_new(
            grid_width,
            grid_height,
            display_width,
            display_height,
            MinimapLimits::default(),
        )
        .expect("Minimap::new received invalid dimensions; use Minimap::try_new for fallible construction")
    }

    /// Create a minimap with explicit safety limits and checked sizing.
    pub fn try_new(
        grid_width: u32,
        grid_height: u32,
        display_width: u32,
        display_height: u32,
        limits: MinimapLimits,
    ) -> Result<Self, MinimapError> {
        log_msg!(
            debug,
            MM01_MINIMAP_INIT,
            "{}x{} grid",
            grid_width,
            grid_height
        );
        let cell_count = Self::validate_dimensions(
            grid_width,
            grid_height,
            display_width,
            display_height,
            limits,
        )?;
        Ok(Self {
            grid_width,
            grid_height,
            display_width,
            display_height,
            limits,
            validation: MinimapValidationLimits::default(),
            terrain: vec![0; cell_count],
            terrain_colors: HashMap::new(),
            tile_descriptions: HashMap::new(),
            fog: vec![0; cell_count],
            fog_enabled: false,
            fog_color: [0.0, 0.0, 0.0, 0.8],
            objects: HashMap::new(),
            object_types: Vec::new(),
            object_type_icons: HashMap::new(),
            owner_colors: HashMap::new(),
            color_mode: ColorMode::Terrain,
            zoom: 1.0,
            center_x: grid_width as f32 / 2.0,
            center_y: grid_height as f32 / 2.0,
            viewport_rect: None,
            viewport_visible: true,
            viewport_color: [1.0, 1.0, 1.0, 0.8],
            pings: Vec::new(),
            markers: HashMap::new(),
            marker_icons: HashMap::new(),
            next_marker_id: 1,
            anti_alias: false,
            clickable: true,
            overlay_shapes: Vec::new(),
            paths: Vec::new(),
            next_path_id: 1,
            layers: Vec::new(),
            active_layer: 0,
        })
    }

    /// Return the number of grid columns.
    pub fn grid_width(&self) -> u32 {
        self.grid_width
    }

    /// Return the number of grid rows.
    pub fn grid_height(&self) -> u32 {
        self.grid_height
    }

    /// Return the total cell count (`grid_width * grid_height`).
    pub fn grid_size(&self) -> u32 {
        self.grid_width * self.grid_height
    }

    /// Return the total cell count as `usize`, or `None` if multiplication overflows.
    pub fn grid_size_checked(&self) -> Option<usize> {
        self.grid_width
            .checked_mul(self.grid_height)
            .map(|cells| cells as usize)
    }

    /// Return the pixel display width.
    pub fn display_width(&self) -> u32 {
        self.display_width
    }

    /// Return the pixel display height.
    pub fn display_height(&self) -> u32 {
        self.display_height
    }

    /// Return the configured hard limits.
    pub fn limits(&self) -> MinimapLimits {
        self.limits
    }

    /// Return the configured float and text validation policy.
    pub fn validation_limits(&self) -> MinimapValidationLimits {
        self.validation
    }

    /// Update the pixel display dimensions.
    pub fn set_display_size(&mut self, width: u32, height: u32) {
        self.display_width = width;
        self.display_height = height;
    }

    /// Update the pixel display dimensions with validation.
    pub fn try_set_display_size(&mut self, width: u32, height: u32) -> Result<(), MinimapError> {
        if width == 0 || height == 0 {
            return Err(MinimapError::DisplayDimensionsZero { width, height });
        }
        let pixel_count = Self::checked_pixel_count(width, height)?;
        if pixel_count > self.limits.max_display_pixels {
            return Err(MinimapError::PixelLimitExceeded {
                pixel_count,
                limit: self.limits.max_display_pixels,
            });
        }
        let byte_count = Self::checked_rgba_bytes(width, height)?;
        if byte_count > self.limits.max_output_bytes {
            return Err(MinimapError::OutputByteLimitExceeded {
                byte_count,
                limit: self.limits.max_output_bytes,
            });
        }
        self.display_width = width;
        self.display_height = height;
        Ok(())
    }

    /// Set the terrain type for cell `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_terrain(&mut self, x: u32, y: u32, terrain_type: u32) {
        if x < self.grid_width && y < self.grid_height {
            let idx = (y * self.grid_width + x) as usize;
            self.terrain[idx] = terrain_type;
        }
    }

    /// Return the terrain type for cell `(x, y)`; returns 0 for out-of-bounds.
    pub fn get_terrain(&self, x: u32, y: u32) -> u32 {
        if x < self.grid_width && y < self.grid_height {
            self.terrain[(y * self.grid_width + x) as usize]
        } else {
            0
        }
    }

    /// Bulk-write terrain types from a flat slice and return the number of patched cells.
    pub fn set_terrain_data(&mut self, data: &[u32]) -> usize {
        let cell_count = self.grid_size_checked().unwrap_or(0);
        let write_count = data.len().min(cell_count);
        for (i, &val) in data.iter().enumerate().take(write_count) {
            self.terrain[i] = val;
        }
        write_count
    }

    /// Replace terrain data only when the caller provides the exact cell count.
    pub fn try_set_terrain_data(&mut self, data: &[u32]) -> Result<(), MinimapError> {
        let cell_count = self.grid_size_checked().unwrap_or(0);
        if data.len() != cell_count {
            return Err(MinimapError::DataLengthMismatch {
                context: "terrain data",
                expected: cell_count,
                actual: data.len(),
            });
        }
        self.terrain.copy_from_slice(data);
        Ok(())
    }

    /// Register an RGBA colour for a terrain type id.
    pub fn set_terrain_color(&mut self, terrain_type: u32, color: [f32; 4]) {
        self.terrain_colors.insert(terrain_type, color);
    }

    /// Return the colour for a terrain type id; returns mid-grey when unregistered.
    pub fn get_terrain_color(&self, terrain_type: u32) -> [f32; 4] {
        self.terrain_colors
            .get(&terrain_type)
            .copied()
            .unwrap_or([0.5, 0.5, 0.5, 1.0])
    }

    /// Register a human-readable description for a terrain type id.
    pub fn set_tile_description(&mut self, type_id: u32, desc: String) {
        self.tile_descriptions.insert(type_id, desc);
    }

    /// Return the description string for a terrain type id, or `None` when unregistered.
    pub fn get_tile_description(&self, type_id: u32) -> Option<&str> {
        self.tile_descriptions.get(&type_id).map(|s| s.as_str())
    }

    /// Enable or disable fog-of-war rendering.
    pub fn set_fog_enabled(&mut self, enabled: bool) {
        self.fog_enabled = enabled;
    }

    /// Return true when fog-of-war is active.
    pub fn fog_enabled(&self) -> bool {
        self.fog_enabled
    }

    /// Set the fog level for cell `(x, y)`; out-of-bounds writes are silently ignored.
    pub fn set_fog_level(&mut self, x: u32, y: u32, level: FogLevel) {
        if x < self.grid_width && y < self.grid_height {
            let idx = (y * self.grid_width + x) as usize;
            self.fog[idx] = level as u8;
        }
    }

    /// Return the fog level for cell `(x, y)`; returns `Hidden` for out-of-bounds.
    pub fn get_fog_level(&self, x: u32, y: u32) -> FogLevel {
        if x < self.grid_width && y < self.grid_height {
            FogLevel::from_u8(self.fog[(y * self.grid_width + x) as usize])
        } else {
            FogLevel::Hidden
        }
    }

    /// Set the RGBA tint colour used for hidden fog cells.
    pub fn set_fog_color(&mut self, color: [f32; 4]) {
        self.fog_color = color;
    }

    /// Return the current fog tint colour.
    pub fn fog_color(&self) -> [f32; 4] {
        self.fog_color
    }

    /// Bulk-write raw fog bytes from a flat slice and return the number of patched cells.
    pub fn set_fog_data(&mut self, data: &[u8]) -> usize {
        let cell_count = self.grid_size_checked().unwrap_or(0);
        let write_count = data.len().min(cell_count);
        for (i, &val) in data.iter().enumerate().take(write_count) {
            self.fog[i] = val.min(2);
        }
        write_count
    }

    /// Replace fog data only when the caller provides the exact cell count.
    pub fn try_set_fog_data(&mut self, data: &[u8]) -> Result<(), MinimapError> {
        let cell_count = self.grid_size_checked().unwrap_or(0);
        if data.len() != cell_count {
            return Err(MinimapError::DataLengthMismatch {
                context: "fog data",
                expected: cell_count,
                actual: data.len(),
            });
        }
        for (dst, src) in self.fog.iter_mut().zip(data.iter().copied()) {
            *dst = src.min(2);
        }
        Ok(())
    }

    /// Return the colour-multiplier for cell `(x, y)` based on fog state: 1.0/0.5/0.15.
    pub fn fog_multiplier(&self, x: u32, y: u32) -> f32 {
        if !self.fog_enabled {
            return 1.0;
        }
        match self.get_fog_level(x, y) {
            FogLevel::Visible => 1.0,
            FogLevel::Explored => 0.5,
            FogLevel::Hidden => 0.15,
        }
    }

    /// Register a new object type with a name and base colour; returns its type index.
    pub fn add_object_type(&mut self, name: String, color: [f32; 4]) -> usize {
        let idx = self.object_types.len();
        self.object_types.push(MinimapObjectType {
            name,
            color,
            visible: true,
        });
        idx
    }

    /// Assign a texture icon to an object type; returns `false` when `type_index` is out of range.
    pub fn set_object_type_texture(
        &mut self,
        type_index: usize,
        texture_key: TextureKey,
        texture_width: f32,
        texture_height: f32,
        display_width: f32,
        display_height: f32,
    ) -> bool {
        if self.object_types.get(type_index).is_none() {
            return false;
        }
        self.object_type_icons.insert(
            type_index,
            MinimapIcon {
                texture_key,
                texture_width: texture_width.max(1.0),
                texture_height: texture_height.max(1.0),
                display_width: display_width.max(1.0),
                display_height: display_height.max(1.0),
            },
        );
        true
    }

    /// Remove the custom icon from an object type, reverting it to colour-dot rendering.
    pub fn clear_object_type_texture(&mut self, type_index: usize) {
        self.object_type_icons.remove(&type_index);
    }

    /// Show or hide all objects of the given type; returns `false` when the type is missing.
    pub fn set_object_type_visible(&mut self, type_index: usize, visible: bool) -> bool {
        if let Some(ot) = self.object_types.get_mut(type_index) {
            ot.visible = visible;
            true
        } else {
            false
        }
    }

    /// Return true when objects of the given type are visible.
    pub fn is_object_type_visible(&self, type_index: usize) -> bool {
        self.object_types
            .get(type_index)
            .is_some_and(|ot| ot.visible)
    }

    /// Return the number of registered object types.
    pub fn object_type_count(&self) -> usize {
        self.object_types.len()
    }

    /// Insert or update a minimap object with a type index and owner.
    pub fn set_object(&mut self, id: u32, x: f32, y: f32, type_index: usize, owner: u32) -> bool {
        if self.object_types.get(type_index).is_none() {
            return false;
        }
        if self.validate_finite("object x", x).is_err()
            || self.validate_finite("object y", y).is_err()
        {
            return false;
        }
        let is_new = !self.objects.contains_key(&id);
        if is_new && self.objects.len() >= self.limits.max_objects {
            return false;
        }
        self.objects.insert(
            id,
            MinimapObject {
                x,
                y,
                type_index,
                owner,
            },
        );
        true
    }

    /// Remove object `id`; returns true when an object was actually removed.
    pub fn remove_object(&mut self, id: u32) -> bool {
        self.objects.remove(&id).is_some()
    }

    /// Remove all objects from the map.
    pub fn clear_objects(&mut self) {
        self.objects.clear();
    }

    /// Return the number of live objects.
    pub fn object_count(&self) -> usize {
        self.objects.len()
    }

    /// Iterate over all live objects; used by the renderer.
    pub(crate) fn objects_iter(&self) -> impl Iterator<Item = &MinimapObject> {
        self.objects.values()
    }

    /// Return the object type descriptor for `type_index`, or `None` when out of range.
    pub(crate) fn object_type(&self, type_index: usize) -> Option<&MinimapObjectType> {
        self.object_types.get(type_index)
    }

    /// Register an RGBA colour for an owner id used in political colour mode.
    pub fn set_owner_color(&mut self, owner: u32, color: [f32; 4]) {
        self.owner_colors.insert(owner, color);
    }

    /// Return the colour for an owner id; returns light-grey when unregistered.
    pub fn get_owner_color(&self, owner: u32) -> [f32; 4] {
        self.owner_colors
            .get(&owner)
            .copied()
            .unwrap_or([0.8, 0.8, 0.8, 1.0])
    }

    /// Set whether cells are coloured by terrain type or by object owner.
    pub fn set_color_mode(&mut self, mode: ColorMode) {
        self.color_mode = mode;
    }

    /// Return the active colour mode.
    pub fn color_mode(&self) -> ColorMode {
        self.color_mode
    }

    /// Set the zoom factor; clamped to a minimum of 0.1.
    pub fn set_zoom(&mut self, zoom: f32) {
        self.zoom = zoom.max(0.1);
    }

    /// Set the zoom factor using the configured validation range.
    pub fn try_set_zoom(&mut self, zoom: f32) -> Result<(), MinimapError> {
        if !zoom.is_finite() {
            return Err(MinimapError::InvalidFloat { field: "zoom" });
        }
        if zoom < self.validation.min_zoom || zoom > self.validation.max_zoom {
            return Err(MinimapError::InvalidZoom {
                zoom,
                min: self.validation.min_zoom,
                max: self.validation.max_zoom,
            });
        }
        self.zoom = zoom;
        Ok(())
    }

    /// Return the current zoom factor.
    pub fn zoom(&self) -> f32 {
        self.zoom
    }

    /// Set the world-space centre the minimap is panned to.
    pub fn set_center(&mut self, x: f32, y: f32) {
        self.center_x = x;
        self.center_y = y;
    }

    /// Set the world-space centre after validating both coordinates.
    pub fn try_set_center(&mut self, x: f32, y: f32) -> Result<(), MinimapError> {
        self.center_x = self.validate_finite("center x", x)?;
        self.center_y = self.validate_finite("center y", y)?;
        Ok(())
    }

    /// Sync the minimap centre and viewport rect from a `Camera2D`.
    pub fn track_camera(&mut self, camera: &Camera2D) {
        let (camera_x, camera_y) = camera.get_position();
        let (vx, vy, vw, vh) = camera.get_visible_area();
        self.set_center(camera_x, camera_y);
        self.set_viewport_rect(vx, vy, vw, vh);
    }

    /// Mark all cells within `radius` grid units of `(cx, cy)` as `Visible`.
    pub fn reveal_radius(&mut self, cx: f32, cy: f32, radius: f32) {
        let _ = self.try_reveal_radius(cx, cy, radius);
    }

    /// Mark all cells within `radius` grid units of `(cx, cy)` as `Visible`, rejecting invalid inputs.
    pub fn try_reveal_radius(&mut self, cx: f32, cy: f32, radius: f32) -> Result<(), MinimapError> {
        if self.grid_width == 0 || self.grid_height == 0 {
            return Ok(());
        }
        let cx = self.validate_finite("reveal center x", cx)?;
        let cy = self.validate_finite("reveal center y", cy)?;
        let radius = self.validate_finite("reveal radius", radius)?;
        if radius <= 0.0 {
            return Ok(());
        }
        let radius_sq = radius * radius;
        let min_x = ((cx - radius).floor() as i64).max(0) as u32;
        let min_y = ((cy - radius).floor() as i64).max(0) as u32;
        let max_x = ((cx + radius).ceil() as i64).min(self.grid_width as i64 - 1) as u32;
        let max_y = ((cy + radius).ceil() as i64).min(self.grid_height as i64 - 1) as u32;
        let span_x = usize::try_from(max_x - min_x + 1).unwrap_or(usize::MAX);
        let span_y = usize::try_from(max_y - min_y + 1).unwrap_or(usize::MAX);
        let requested = span_x.saturating_mul(span_y);
        if requested > self.limits.max_reveal_cells_per_call {
            return Err(MinimapError::RevealAreaTooLarge {
                requested,
                limit: self.limits.max_reveal_cells_per_call,
            });
        }
        for gy in min_y..=max_y {
            for gx in min_x..=max_x {
                let dx = gx as f32 + 0.5 - cx;
                let dy = gy as f32 + 0.5 - cy;
                if dx * dx + dy * dy <= radius_sq {
                    self.set_fog_level(gx, gy, FogLevel::Visible);
                }
            }
        }
        Ok(())
    }

    /// Return the world-space X coordinate the minimap is centred on.
    pub fn center_x(&self) -> f32 {
        self.center_x
    }

    /// Return the world-space Y coordinate the minimap is centred on.
    pub fn center_y(&self) -> f32 {
        self.center_y
    }

    /// Set the viewport outline rectangle as `(x, y, w, h)` in world coordinates.
    pub fn set_viewport_rect(&mut self, x: f32, y: f32, w: f32, h: f32) {
        self.viewport_rect = Some((x, y, w, h));
    }

    /// Set the viewport outline rectangle after validating all coordinates.
    pub fn try_set_viewport_rect(
        &mut self,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
    ) -> Result<(), MinimapError> {
        let x = self.validate_finite("viewport x", x)?;
        let y = self.validate_finite("viewport y", y)?;
        let w = self.validate_finite("viewport width", w)?;
        let h = self.validate_finite("viewport height", h)?;
        self.viewport_rect = Some((x, y, w, h));
        Ok(())
    }

    /// Remove the viewport outline rectangle.
    pub fn clear_viewport_rect(&mut self) {
        self.viewport_rect = None;
    }

    /// Return the current viewport outline rectangle, or `None` when cleared.
    pub fn viewport_rect(&self) -> Option<(f32, f32, f32, f32)> {
        self.viewport_rect
    }

    /// Show or hide the viewport outline rectangle.
    pub fn set_viewport_visible(&mut self, visible: bool) {
        self.viewport_visible = visible;
    }

    /// Return true when the viewport outline is visible.
    pub fn viewport_visible(&self) -> bool {
        self.viewport_visible
    }

    /// Set the RGBA colour of the viewport outline rectangle.
    pub fn set_viewport_color(&mut self, color: [f32; 4]) {
        self.viewport_color = color;
    }

    /// Return the viewport outline colour.
    pub fn viewport_color(&self) -> [f32; 4] {
        self.viewport_color
    }

    /// Spawn a timed ping at `(x, y)` that fades over `duration` seconds.
    pub fn add_ping(&mut self, x: f32, y: f32, duration: f32, color: [f32; 4]) -> bool {
        if self.pings.len() >= self.limits.max_pings {
            return false;
        }
        let Ok(x) = self.validate_finite("ping x", x) else {
            return false;
        };
        let Ok(y) = self.validate_finite("ping y", y) else {
            return false;
        };
        if !duration.is_finite() || duration < 0.0 || duration > self.validation.max_duration {
            return false;
        }
        let Ok(color) = Self::clamp_color("ping color", color) else {
            return false;
        };
        self.pings.push(MinimapPing {
            x,
            y,
            remaining: duration,
            duration,
            color,
        });
        true
    }

    /// Return the number of active pings.
    pub fn ping_count(&self) -> usize {
        self.pings.len()
    }

    /// Return the slice of active pings; used by the renderer.
    pub fn pings(&self) -> &[MinimapPing] {
        &self.pings
    }

    /// Iterate over all markers; used by the Lua API.
    pub fn markers_iter(&self) -> impl Iterator<Item = &MinimapMarker> {
        self.markers.values()
    }

    /// Iterate over markers with their ids; used by the renderer.
    pub(crate) fn markers_with_ids(&self) -> impl Iterator<Item = (&u32, &MinimapMarker)> {
        self.markers.iter()
    }

    /// Add a named marker at `(x, y)` and return its auto-assigned id.
    pub fn add_marker(&mut self, x: f32, y: f32, description: String, color: [f32; 4]) -> u32 {
        self.try_add_marker(x, y, description, color)
            .expect("Minimap::add_marker received invalid marker data; use Minimap::try_add_marker for fallible insertion")
    }

    /// Add a named marker at `(x, y)` and return its auto-assigned id.
    pub fn try_add_marker(
        &mut self,
        x: f32,
        y: f32,
        description: String,
        color: [f32; 4],
    ) -> Result<u32, MinimapError> {
        if self.markers.len() >= self.limits.max_markers {
            return Err(MinimapError::MarkerLimitExceeded {
                limit: self.limits.max_markers,
            });
        }
        let x = self.validate_finite("marker x", x)?;
        let y = self.validate_finite("marker y", y)?;
        self.validate_description("marker description", &description)?;
        let color = Self::clamp_color("marker color", color)?;
        let id = self.next_marker_id;
        self.next_marker_id = self
            .next_marker_id
            .checked_add(1)
            .ok_or(MinimapError::IdOverflow { kind: "marker" })?;
        self.markers.insert(
            id,
            MinimapMarker {
                x,
                y,
                description,
                color,
                animation: None,
            },
        );
        Ok(id)
    }

    /// Remove marker `id` and its optional icon; returns true when a marker was removed.
    pub fn remove_marker(&mut self, id: u32) -> bool {
        self.marker_icons.remove(&id);
        self.markers.remove(&id).is_some()
    }

    /// Assign a texture icon to an existing marker; returns `false` when `id` is unknown.
    pub fn set_marker_texture(
        &mut self,
        id: u32,
        texture_key: TextureKey,
        texture_width: f32,
        texture_height: f32,
        display_width: f32,
        display_height: f32,
    ) -> bool {
        if !self.markers.contains_key(&id) {
            return false;
        }
        self.marker_icons.insert(
            id,
            MinimapIcon {
                texture_key,
                texture_width: texture_width.max(1.0),
                texture_height: texture_height.max(1.0),
                display_width: display_width.max(1.0),
                display_height: display_height.max(1.0),
            },
        );
        true
    }

    /// Remove the custom icon from marker `id`, reverting it to cross rendering.
    pub fn clear_marker_texture(&mut self, id: u32) {
        self.marker_icons.remove(&id);
    }

    /// Return true when marker `id` exists.
    pub fn has_marker(&self, id: u32) -> bool {
        self.markers.contains_key(&id)
    }

    /// Return the description string for marker `id`, or `None` when not found.
    pub fn get_marker_description(&self, id: u32) -> Option<&str> {
        self.markers.get(&id).map(|m| m.description.as_str())
    }

    /// Return the total number of markers.
    pub fn marker_count(&self) -> usize {
        self.markers.len()
    }

    /// Attach a blink, pulse, or rotation animation to marker `id`.
    pub fn set_marker_animation(&mut self, id: u32, anim: MarkerAnimation) {
        if let Some(marker) = self.markers.get_mut(&id) {
            marker.animation = Some(anim);
        }
    }

    /// Remove any animation from marker `id`.
    pub fn clear_marker_animation(&mut self, id: u32) {
        if let Some(marker) = self.markers.get_mut(&id) {
            marker.animation = None;
        }
    }

    /// Append a line segment to the overlay shape list.
    pub fn draw_line(&mut self, x1: f32, y1: f32, x2: f32, y2: f32, color: [u8; 4]) -> bool {
        if self.overlay_shapes.len() >= self.limits.max_overlay_shapes {
            return false;
        }
        if self.validate_finite("line x1", x1).is_err()
            || self.validate_finite("line y1", y1).is_err()
            || self.validate_finite("line x2", x2).is_err()
            || self.validate_finite("line y2", y2).is_err()
        {
            return false;
        }
        self.overlay_shapes.push(OverlayShape::Line {
            x1,
            y1,
            x2,
            y2,
            color,
        });
        true
    }

    /// Append a rectangle outline to the overlay shape list.
    pub fn draw_rect(&mut self, x: f32, y: f32, w: f32, h: f32, color: [u8; 4]) -> bool {
        if self.overlay_shapes.len() >= self.limits.max_overlay_shapes {
            return false;
        }
        if self.validate_finite("rect x", x).is_err()
            || self.validate_finite("rect y", y).is_err()
            || self.validate_finite("rect width", w).is_err()
            || self.validate_finite("rect height", h).is_err()
        {
            return false;
        }
        self.overlay_shapes
            .push(OverlayShape::Rect { x, y, w, h, color });
        true
    }

    /// Clear all overlay shapes. This function is part of the public API.
    pub fn clear_overlay(&mut self) {
        self.overlay_shapes.clear();
    }

    /// Return the current overlay shape list; used by the renderer.
    pub fn overlay_shapes(&self) -> &[OverlayShape] {
        &self.overlay_shapes
    }

    /// Add a named polyline path and return its auto-assigned id.
    pub fn show_path(&mut self, points: Vec<(f32, f32)>, color: [u8; 4]) -> u32 {
        self.try_show_path(points, color)
            .expect("Minimap::show_path received invalid path data; use Minimap::try_show_path for fallible insertion")
    }

    /// Add a named polyline path and return its auto-assigned id.
    pub fn try_show_path(
        &mut self,
        points: Vec<(f32, f32)>,
        color: [u8; 4],
    ) -> Result<u32, MinimapError> {
        if self.paths.len() >= self.limits.max_paths {
            return Err(MinimapError::PathLimitExceeded {
                limit: self.limits.max_paths,
            });
        }
        if points.len() > self.limits.max_path_points {
            return Err(MinimapError::PathPointLimitExceeded {
                points: points.len(),
                limit: self.limits.max_path_points,
            });
        }
        for &(x, y) in &points {
            self.validate_finite("path x", x)?;
            self.validate_finite("path y", y)?;
        }
        let id = self.next_path_id;
        self.next_path_id = self
            .next_path_id
            .checked_add(1)
            .ok_or(MinimapError::IdOverflow { kind: "path" })?;
        self.paths.push(OverlayPath { id, points, color });
        Ok(id)
    }

    /// Remove a specific path by id, or all paths when `id` is `None`.
    pub fn clear_path(&mut self, id: Option<u32>) {
        match id {
            Some(n) => self.paths.retain(|p| p.id != n),
            None => self.paths.clear(),
        }
    }

    /// Return all active overlay paths; used by the renderer.
    pub fn paths(&self) -> &[OverlayPath] {
        &self.paths
    }

    /// Switch the active render layer by index; returns `false` when the requested layer is unavailable.
    pub fn set_layer(&mut self, layer: usize) -> bool {
        if layer == 0 && self.layers.is_empty() {
            self.active_layer = 0;
            return true;
        }
        match self.layers.get(layer) {
            Some(data) if !data.cells.is_empty() => {
                self.active_layer = layer;
                true
            }
            _ => false,
        }
    }

    /// Return the active render layer index.
    pub fn get_layer(&self) -> usize {
        self.active_layer
    }

    /// Write cell data for a layer, auto-extending the layer list as needed.
    pub fn set_layer_data(&mut self, layer: usize, data: LayerData) {
        self.try_set_layer_data(layer, data)
            .expect("Minimap::set_layer_data received invalid layer data; use Minimap::try_set_layer_data for fallible updates")
    }

    /// Write cell data for a layer after validating dimensions and limits.
    pub fn try_set_layer_data(
        &mut self,
        layer: usize,
        data: LayerData,
    ) -> Result<(), MinimapError> {
        if layer >= self.limits.max_layers {
            return Err(MinimapError::LayerLimitExceeded {
                layer,
                limit: self.limits.max_layers,
            });
        }
        if data.width != self.grid_width || data.height != self.grid_height {
            return Err(MinimapError::DataLengthMismatch {
                context: "layer dimensions",
                expected: self.grid_size_checked().unwrap_or(0),
                actual: data.cells.len(),
            });
        }
        let expected = self.grid_size_checked().unwrap_or(0);
        if data.cells.len() != expected {
            return Err(MinimapError::DataLengthMismatch {
                context: "layer data",
                expected,
                actual: data.cells.len(),
            });
        }
        if layer >= self.layers.len() {
            self.layers.resize_with(layer + 1, || LayerData {
                cells: Vec::new(),
                width: self.grid_width,
                height: self.grid_height,
            });
        }
        self.layers[layer] = data;
        Ok(())
    }

    /// Return the cell data for a layer, or `None` when that layer index is unused.
    pub fn layer_data(&self, layer: usize) -> Option<&LayerData> {
        self.layers.get(layer)
    }

    /// Return the number of allocated layers.
    pub fn layer_count(&self) -> usize {
        self.layers.len()
    }

    /// Enable or disable anti-aliased rendering for the minimap texture.
    pub fn set_anti_alias(&mut self, enabled: bool) {
        self.anti_alias = enabled;
    }

    /// Return true when anti-aliasing is enabled.
    pub fn anti_alias(&self) -> bool {
        self.anti_alias
    }

    /// Enable or disable click-event handling on the minimap.
    pub fn set_clickable(&mut self, enabled: bool) {
        self.clickable = enabled;
    }

    /// Return true when the minimap responds to click events.
    pub fn is_clickable(&self) -> bool {
        self.clickable
    }

    /// Convert a screen pixel `(sx, sy)` relative to `(minimap_x, minimap_y)` to grid coordinates.
    pub fn screen_to_grid(&self, sx: f32, sy: f32, minimap_x: f32, minimap_y: f32) -> (f32, f32) {
        self.try_screen_to_grid(sx, sy, minimap_x, minimap_y)
            .unwrap_or((self.center_x, self.center_y))
    }

    /// Convert a screen pixel `(sx, sy)` relative to `(minimap_x, minimap_y)` to grid coordinates.
    pub fn try_screen_to_grid(
        &self,
        sx: f32,
        sy: f32,
        minimap_x: f32,
        minimap_y: f32,
    ) -> Result<(f32, f32), MinimapError> {
        let (_, _, cell_px_w, cell_px_h, start_x, start_y) = self.transform_metrics()?;
        if !sx.is_finite() || !sy.is_finite() || !minimap_x.is_finite() || !minimap_y.is_finite() {
            return Err(MinimapError::InvalidFloat {
                field: "screen position",
            });
        }
        let local_x = sx - minimap_x;
        let local_y = sy - minimap_y;
        let gx = start_x + local_x / cell_px_w;
        let gy = start_y + local_y / cell_px_h;
        if !gx.is_finite() || !gy.is_finite() {
            return Err(MinimapError::TransformUnavailable {
                reason: "grid transform produced non-finite coordinates",
            });
        }
        Ok((gx, gy))
    }

    /// Convert grid coordinates to screen pixels relative to `(minimap_x, minimap_y)`.
    pub fn grid_to_screen(&self, gx: f32, gy: f32, minimap_x: f32, minimap_y: f32) -> (f32, f32) {
        self.try_grid_to_screen(gx, gy, minimap_x, minimap_y)
            .unwrap_or((minimap_x, minimap_y))
    }

    /// Convert grid coordinates to screen pixels relative to `(minimap_x, minimap_y)`.
    pub fn try_grid_to_screen(
        &self,
        gx: f32,
        gy: f32,
        minimap_x: f32,
        minimap_y: f32,
    ) -> Result<(f32, f32), MinimapError> {
        let (_, _, cell_px_w, cell_px_h, start_x, start_y) = self.transform_metrics()?;
        if !gx.is_finite() || !gy.is_finite() || !minimap_x.is_finite() || !minimap_y.is_finite() {
            return Err(MinimapError::InvalidFloat {
                field: "grid position",
            });
        }
        let sx = minimap_x + (gx - start_x) * cell_px_w;
        let sy = minimap_y + (gy - start_y) * cell_px_h;
        if !sx.is_finite() || !sy.is_finite() {
            return Err(MinimapError::TransformUnavailable {
                reason: "screen transform produced non-finite coordinates",
            });
        }
        Ok((sx, sy))
    }

    /// Return the terrain description for the cell under screen point `(sx, sy)`, or `None` when out of bounds.
    pub fn get_hover_info(&self, sx: f32, sy: f32, minimap_x: f32, minimap_y: f32) -> Option<&str> {
        let local_x = sx - minimap_x;
        let local_y = sy - minimap_y;
        if !local_x.is_finite()
            || !local_y.is_finite()
            || local_x < 0.0
            || local_y < 0.0
            || local_x >= self.display_width as f32
            || local_y >= self.display_height as f32
        {
            return None;
        }
        let (gx, gy) = self.try_screen_to_grid(sx, sy, minimap_x, minimap_y).ok()?;
        let gxi = gx.floor() as i64;
        let gyi = gy.floor() as i64;
        if gxi < 0 || gyi < 0 || gxi >= self.grid_width as i64 || gyi >= self.grid_height as i64 {
            return None;
        }
        let terrain_type = self.terrain[(gyi as u32 * self.grid_width + gxi as u32) as usize];
        self.get_tile_description(terrain_type)
    }

    /// Advance ping timers and marker animation phases by `dt` seconds; remove expired pings.
    pub fn update(&mut self, dt: f32) {
        if !dt.is_finite() || dt <= 0.0 {
            return;
        }
        self.pings.retain_mut(|ping| {
            ping.remaining -= dt;
            ping.remaining > 0.0
        });
        for marker in self.markers.values_mut() {
            if let Some(ref mut anim) = marker.animation {
                match anim {
                    MarkerAnimation::Blink { speed, phase }
                    | MarkerAnimation::Pulse { speed, phase } => {
                        if speed.is_finite() && phase.is_finite() {
                            *phase = (*phase + dt * *speed).rem_euclid(1.0);
                        }
                    }
                    MarkerAnimation::Rotate { speed, angle } => {
                        if speed.is_finite() && angle.is_finite() {
                            *angle = (*angle + dt * *speed).rem_euclid(std::f32::consts::TAU);
                        }
                    }
                }
            }
        }
    }

    /// Rasterise the minimap to an `ImageData` buffer for export or screenshot.
    pub fn draw_to_image(&self, pixel_size: u32) -> crate::image::ImageData {
        self.try_draw_to_image(pixel_size)
            .expect("Minimap::draw_to_image received invalid output dimensions; use Minimap::try_draw_to_image for fallible export")
    }

    /// Rasterise the minimap to an `ImageData` buffer for export or screenshot.
    pub fn try_draw_to_image(
        &self,
        pixel_size: u32,
    ) -> Result<crate::image::ImageData, MinimapError> {
        let (w, h) = self.image_dimensions(pixel_size)?;
        let mut img = crate::image::ImageData::try_new(w, h).map_err(|_| {
            let byte_count = Self::checked_rgba_bytes(w, h).unwrap_or(u64::MAX);
            MinimapError::OutputByteLimitExceeded {
                byte_count,
                limit: self.limits.max_output_bytes,
            }
        })?;
        let owner_colors = self.owner_colors_by_cell();
        let grid_w = self.grid_width.max(1);
        let grid_h = self.grid_height.max(1);
        for py in 0..h {
            let gy = ((u64::from(py) * u64::from(grid_h)) / u64::from(h)).min(u64::from(grid_h - 1))
                as u32;
            for px in 0..w {
                let gx = ((u64::from(px) * u64::from(grid_w)) / u64::from(w))
                    .min(u64::from(grid_w - 1)) as u32;
                let terrain_type = self.get_terrain(gx, gy);
                let tc = self.resolve_cell_color(gx, gy, terrain_type, &owner_colors);
                let mult = self.fog_multiplier(gx, gy);
                let r = (tc[0] * 255.0 * mult).clamp(0.0, 255.0) as u8;
                let g = (tc[1] * 255.0 * mult).clamp(0.0, 255.0) as u8;
                let b = (tc[2] * 255.0 * mult).clamp(0.0, 255.0) as u8;
                img.set_pixel(px, py, r, g, b, 255);
            }
        }

        let cell_px_w = w as f32 / self.grid_width as f32;
        let cell_px_h = h as f32 / self.grid_height as f32;
        for obj in self.objects.values() {
            let Some(ot) = self.object_types.get(obj.type_index) else {
                continue;
            };
            if !obj.x.is_finite() || !obj.y.is_finite() || !ot.visible {
                continue;
            }
            let screen_x = (obj.x * cell_px_w) as i32;
            let screen_y = (obj.y * cell_px_h) as i32;
            let (cr, cg, cb, radius) = (
                (ot.color[0] * 255.0).clamp(0.0, 255.0) as u8,
                (ot.color[1] * 255.0).clamp(0.0, 255.0) as u8,
                (ot.color[2] * 255.0).clamp(0.0, 255.0) as u8,
                4u32,
            );
            img.draw_circle(screen_x, screen_y, radius, cr, cg, cb, 255);
        }
        for marker in self.markers.values() {
            if !marker.x.is_finite() || !marker.y.is_finite() {
                continue;
            }
            let mx = (marker.x * cell_px_w) as i32;
            let my = (marker.y * cell_px_h) as i32;
            let mr = (marker.color[0] * 255.0).clamp(0.0, 255.0) as u8;
            let mg = (marker.color[1] * 255.0).clamp(0.0, 255.0) as u8;
            let mb = (marker.color[2] * 255.0).clamp(0.0, 255.0) as u8;
            img.draw_circle(mx, my, 3, mr, mg, mb, 255);
            img.draw_line(mx - 4, my, mx + 4, my, mr, mg, mb, 255);
            img.draw_line(mx, my - 4, mx, my + 4, mr, mg, mb, 255);
        }
        Ok(img)
    }

    /// Build the full set of `RenderCommand`s for the minimap at screen position `(screen_x, screen_y)`.
    pub fn build_render_commands(
        &self,
        screen_x: f32,
        screen_y: f32,
    ) -> Vec<crate::render::renderer::RenderCommand> {
        self.generate_render_commands(screen_x, screen_y)
    }

    /// Return the icon for object type `type_index`, or `None` when no icon is registered.
    pub(crate) fn object_type_icon(&self, type_index: usize) -> Option<MinimapIcon> {
        self.object_type_icons.get(&type_index).copied()
    }

    /// Return the icon for marker `id`, or `None` when no icon is registered.
    pub(crate) fn marker_icon(&self, id: u32) -> Option<MinimapIcon> {
        self.marker_icons.get(&id).copied()
    }

    /// Build a map of `(grid_x, grid_y) -> owner colour` from the current object set.
    pub(crate) fn owner_colors_by_cell(&self) -> HashMap<(u32, u32), [f32; 4]> {
        let mut owner_colors = HashMap::with_capacity(self.objects.len());
        for object in self.objects.values() {
            let gx = object.x.floor() as i64;
            let gy = object.y.floor() as i64;
            if gx < 0 || gy < 0 || gx >= self.grid_width as i64 || gy >= self.grid_height as i64 {
                continue;
            }
            owner_colors.insert((gx as u32, gy as u32), self.get_owner_color(object.owner));
        }
        owner_colors
    }

    /// Resolve the display colour for cell `(gx, gy)` based on the active colour mode.
    pub(crate) fn resolve_cell_color(
        &self,
        gx: u32,
        gy: u32,
        terrain_type: u32,
        owner_colors: &HashMap<(u32, u32), [f32; 4]>,
    ) -> [f32; 4] {
        match self.color_mode {
            ColorMode::Terrain => self.get_terrain_color(terrain_type),
            ColorMode::Political => owner_colors
                .get(&(gx, gy))
                .copied()
                .unwrap_or_else(|| self.get_terrain_color(terrain_type)),
        }
    }

    /// Set the next marker id to a caller-provided value for Rust-side overflow tests.
    #[doc(hidden)]
    pub fn set_next_marker_id_for_testing(&mut self, next_id: u32) {
        self.next_marker_id = next_id;
    }

    /// Set the next path id to a caller-provided value for Rust-side overflow tests.
    #[doc(hidden)]
    pub fn set_next_path_id_for_testing(&mut self, next_id: u32) {
        self.next_path_id = next_id;
    }
}
