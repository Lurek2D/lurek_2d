//! Owns the camera viewport implementation for the camera subsystem and keeps related runtime rules local here.
//! Keeps camera transforms, view state, and viewport rules ownership so helpers stay close to invariants this file updates.
//! Defines how camera viewport data is validated, transformed, or stored before neighboring systems consume it.
//! Separates camera viewport behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where camera code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing camera viewport defaults, lifecycle handling, validation, or data ownership rules.

#[derive(Debug, Clone, PartialEq)]
/// Selects how the game surface scales into a window surface.
pub enum ScaleMode {
    /// Preserves aspect ratio and pads unused space.
    Letterbox,
    /// Fills full window independently on each axis.
    Stretch,
    /// Preserves aspect ratio using integer scale factors.
    PixelPerfect,
}
impl ScaleMode {
    /// Compute scale and offset transforms and return (sx, sy, ox, oy).
    pub fn compute_transforms(
        &self,
        game_width: f32,
        game_height: f32,
        window_width: f32,
        window_height: f32,
    ) -> (f32, f32, f32, f32) {
        match self {
            ScaleMode::Letterbox => {
                let scale = (window_width / game_width).min(window_height / game_height);
                let offset_x = (window_width - game_width * scale) / 2.0;
                let offset_y = (window_height - game_height * scale) / 2.0;
                (scale, scale, offset_x, offset_y)
            }
            ScaleMode::Stretch => {
                let scale_x = window_width / game_width;
                let scale_y = window_height / game_height;
                (scale_x, scale_y, 0.0, 0.0)
            }
            ScaleMode::PixelPerfect => {
                let scale = (window_width / game_width)
                    .min(window_height / game_height)
                    .floor()
                    .max(1.0);
                let offset_x = (window_width - game_width * scale) / 2.0;
                let offset_y = (window_height - game_height * scale) / 2.0;
                (scale, scale, offset_x, offset_y)
            }
        }
    }
}

/// Return (offset_x, offset_y, zoom) that fits a logical content rectangle inside a screen rectangle.
pub fn fit_content_to_screen(
    content_width: f32,
    content_height: f32,
    unit_size: f32,
    screen_width: f32,
    screen_height: f32,
) -> (f32, f32, f32) {
    let safe_unit = unit_size.max(0.0001);
    let content_screen_w = content_width * safe_unit;
    let content_screen_h = content_height * safe_unit;
    if content_screen_w <= 0.0
        || content_screen_h <= 0.0
        || screen_width <= 0.0
        || screen_height <= 0.0
    {
        return (0.0, 0.0, 1.0);
    }
    let zoom = (screen_width / content_screen_w)
        .min(screen_height / content_screen_h)
        .max(0.0001);
    let offset_x = (screen_width - content_screen_w * zoom) * 0.5;
    let offset_y = (screen_height - content_screen_h * zoom) * 0.5;
    (offset_x, offset_y, zoom)
}

/// Convert screen coordinates into logical content coordinates using offset, zoom, and unit size.
pub fn screen_to_content(
    screen_x: f32,
    screen_y: f32,
    offset_x: f32,
    offset_y: f32,
    zoom: f32,
    unit_size: f32,
) -> (f32, f32) {
    let denom = (zoom * unit_size).max(0.0001);
    ((screen_x - offset_x) / denom, (screen_y - offset_y) / denom)
}

/// Return the new view offset after zooming around a screen-space anchor point.
pub fn zoom_offset_at(
    anchor_x: f32,
    anchor_y: f32,
    offset_x: f32,
    offset_y: f32,
    old_zoom: f32,
    new_zoom: f32,
) -> (f32, f32) {
    if old_zoom.abs() < 0.0001 {
        return (offset_x, offset_y);
    }
    let scale = new_zoom / old_zoom;
    (
        anchor_x - (anchor_x - offset_x) * scale,
        anchor_y - (anchor_y - offset_y) * scale,
    )
}

/// Inclusive chunk-coordinate range visible through a camera viewport.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ChunkViewportRange {
    /// Minimum visible chunk X coordinate.
    pub min_x: i32,
    /// Maximum visible chunk X coordinate.
    pub max_x: i32,
    /// Minimum visible chunk Y coordinate.
    pub min_y: i32,
    /// Maximum visible chunk Y coordinate.
    pub max_y: i32,
}

impl ChunkViewportRange {
    /// Return an empty range used when the camera cannot see any chunk.
    pub fn empty() -> Self {
        Self {
            min_x: 0,
            max_x: -1,
            min_y: 0,
            max_y: -1,
        }
    }

    /// Return true when the range contains no chunk coordinates.
    pub fn is_empty(&self) -> bool {
        self.min_x > self.max_x || self.min_y > self.max_y
    }
}

/// Compute the map chunk range visible through a centered camera viewport.
#[allow(clippy::too_many_arguments)]
pub fn camera_visible_chunk_range(
    map_width_tiles: u32,
    map_height_tiles: u32,
    tile_width: u32,
    tile_height: u32,
    chunk_size_tiles: u32,
    camera_x: f32,
    camera_y: f32,
    camera_zoom: f32,
    viewport_width: f32,
    viewport_height: f32,
) -> ChunkViewportRange {
    if map_width_tiles == 0
        || map_height_tiles == 0
        || tile_width == 0
        || tile_height == 0
        || chunk_size_tiles == 0
    {
        return ChunkViewportRange::empty();
    }

    let chunks_x = map_width_tiles.div_ceil(chunk_size_tiles) as i32;
    let chunks_y = map_height_tiles.div_ceil(chunk_size_tiles) as i32;
    if viewport_width <= 0.0 || viewport_height <= 0.0 {
        return ChunkViewportRange {
            min_x: 0,
            max_x: chunks_x - 1,
            min_y: 0,
            max_y: chunks_y - 1,
        };
    }

    let zoom = if camera_zoom.abs() > f32::EPSILON {
        camera_zoom
    } else {
        1.0
    };
    let half_w = viewport_width * 0.5 / zoom.abs();
    let half_h = viewport_height * 0.5 / zoom.abs();
    let world_left = camera_x - half_w;
    let world_right = camera_x + half_w;
    let world_top = camera_y - half_h;
    let world_bottom = camera_y + half_h;
    let map_world_w = map_width_tiles as f32 * tile_width as f32;
    let map_world_h = map_height_tiles as f32 * tile_height as f32;
    if world_right < 0.0
        || world_bottom < 0.0
        || world_left > map_world_w
        || world_top > map_world_h
    {
        return ChunkViewportRange::empty();
    }

    let chunk_w = chunk_size_tiles as f32 * tile_width as f32;
    let chunk_h = chunk_size_tiles as f32 * tile_height as f32;
    ChunkViewportRange {
        min_x: ((world_left / chunk_w).floor() as i32).clamp(0, chunks_x - 1),
        max_x: ((world_right / chunk_w).floor() as i32).clamp(0, chunks_x - 1),
        min_y: ((world_top / chunk_h).floor() as i32).clamp(0, chunks_y - 1),
        max_y: ((world_bottom / chunk_h).floor() as i32).clamp(0, chunks_y - 1),
    }
}

/// Stores viewport scaling state used during window resize and conversion.
pub struct Viewport {
    /// Stores virtual game width in logical units.
    pub game_width: f32,
    /// Stores virtual game height in logical units.
    pub game_height: f32,
    /// Stores active scaling mode for transform computation.
    pub scale_mode: ScaleMode,
    /// Stores computed horizontal scale factor.
    pub scale_x: f32,
    /// Stores computed vertical scale factor.
    pub scale_y: f32,
    /// Stores computed horizontal screen offset in pixels.
    pub offset_x: f32,
    /// Stores computed vertical screen offset in pixels.
    pub offset_y: f32,
}
impl Viewport {
    /// Create viewport state and return it with identity scaling.
    pub fn new(game_width: f32, game_height: f32, scale_mode: ScaleMode) -> Self {
        Self {
            game_width,
            game_height,
            scale_mode,
            scale_x: 1.0,
            scale_y: 1.0,
            offset_x: 0.0,
            offset_y: 0.0,
        }
    }
    /// Recompute scale and offsets from window size and return after updating state.
    pub fn resize(&mut self, window_width: f32, window_height: f32) {
        let (scale_x, scale_y, offset_x, offset_y) = self.scale_mode.compute_transforms(
            self.game_width,
            self.game_height,
            window_width,
            window_height,
        );
        self.scale_x = scale_x;
        self.scale_y = scale_y;
        self.offset_x = offset_x;
        self.offset_y = offset_y;
    }
    /// Read current scale factors and return (scale_x, scale_y).
    pub fn get_scale(&self) -> (f32, f32) {
        (self.scale_x, self.scale_y)
    }
    /// Read current screen offsets and return (offset_x, offset_y).
    pub fn get_offset(&self) -> (f32, f32) {
        (self.offset_x, self.offset_y)
    }
    /// Read configured game dimensions and return (width, height).
    pub fn get_game_dimensions(&self) -> (f32, f32) {
        (self.game_width, self.game_height)
    }
    /// Read active scale mode and return immutable reference to mode.
    pub fn get_scale_mode(&self) -> &ScaleMode {
        &self.scale_mode
    }
    /// Set active scale mode and return after replacing previous mode.
    pub fn set_scale_mode(&mut self, mode: ScaleMode) {
        self.scale_mode = mode;
    }
    /// Convert screen coordinates to game coordinates and return mapped pair.
    pub fn to_game(&self, screen_x: f32, screen_y: f32) -> (f32, f32) {
        (
            (screen_x - self.offset_x) / self.scale_x,
            (screen_y - self.offset_y) / self.scale_y,
        )
    }
    /// Convert game coordinates to screen coordinates and return mapped pair.
    pub fn to_screen(&self, game_x: f32, game_y: f32) -> (f32, f32) {
        (
            game_x * self.scale_x + self.offset_x,
            game_y * self.scale_y + self.offset_y,
        )
    }
}
