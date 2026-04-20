//! Grid-based sprite sheet with directional support and named groups.
//!
//! Splits a texture into a uniform grid of frames and provides indexed,
//! row/column, named-group, and directional access to the resulting quads.

use std::collections::HashMap;

use crate::log_msg;
use crate::math::Rect;
use crate::runtime::log_messages::{SS01, SS02};

/// Named frame group within the sprite sheet.
///
/// # Fields
/// - `name` — `String`.
/// - `start_frame` — `usize`.
/// - `count` — `usize`.
#[derive(Debug, Clone)]
pub struct FrameGroup {
    /// Human-readable name for this group.
    pub name: String,
    /// 0-based index of the first frame in the group.
    pub start_frame: usize,
    /// Number of frames in the group.
    pub count: usize,
}

/// Directional layout for sprite sets. Consult the module-level documentation for the broader usage context and preconditions.
///
/// # Variants
/// - `Rows` — Rows variant.
/// - `Columns` — Columns variant.
#[derive(Debug, Clone, PartialEq)]
pub enum DirectionLayout {
    /// Each direction occupies a row.
    Rows,
    /// Each direction occupies a column.
    Columns,
}

/// Grid-based sprite sheet with directional support and named groups.
///
/// # Fields
/// - `frame_width` — `u32`.
/// - `frame_height` — `u32`.
/// - `columns` — `u32`.
/// - `rows` — `u32`.
/// - `texture_width` — `u32`.
/// - `texture_height` — `u32`.
///
/// Divides a texture into equal-sized cells and pre-computes UV quads
/// for every frame. Supports named groups and 4/8-directional layouts.
pub struct SpriteSheet {
    /// Width of a single frame in pixels.
    pub frame_width: u32,
    /// Height of a single frame in pixels.
    pub frame_height: u32,
    /// Number of columns in the grid.
    pub columns: u32,
    /// Number of rows in the grid.
    pub rows: u32,
    /// Width of the source texture in pixels.
    pub texture_width: u32,
    /// Height of the source texture in pixels.
    pub texture_height: u32,
    /// Pre-computed quads for every frame.
    frames: Vec<Rect>,
    /// Named frame groups.
    groups: HashMap<String, FrameGroup>,
    /// Optional directional count (4 or 8).
    direction_count: Option<u32>,
    /// Whether directions are laid out in rows or columns.
    direction_layout: DirectionLayout,
}

impl SpriteSheet {
    /// Create a new sprite sheet by dividing a texture into a uniform grid.
    ///
    /// # Parameters
    /// - `texture_width` — `u32`.
    /// - `texture_height` — `u32`.
    /// - `frame_width` — `u32`.
    /// - `frame_height` — `u32`.
    ///
    /// # Returns
    /// `Self`.
    ///
    /// Computes columns/rows from texture and frame dimensions and
    /// pre-generates all frame quads.
    pub fn new(
        texture_width: u32,
        texture_height: u32,
        frame_width: u32,
        frame_height: u32,
    ) -> Self {
        let columns = if frame_width > 0 {
            texture_width / frame_width
        } else {
            0
        };
        let rows = if frame_height > 0 {
            texture_height / frame_height
        } else {
            0
        };
        let total = (columns * rows) as usize;

        let mut frames = Vec::with_capacity(total);
        for i in 0..total {
            let col = (i as u32) % columns;
            let row = (i as u32) / columns;
            frames.push(Rect {
                x: (col * frame_width) as f32,
                y: (row * frame_height) as f32,
                width: frame_width as f32,
                height: frame_height as f32,
            });
        }

        log_msg!(debug, SS01, "frames={}", total);

        Self {
            frame_width,
            frame_height,
            columns,
            rows,
            texture_width,
            texture_height,
            frames,
            groups: HashMap::new(),
            direction_count: None,
            direction_layout: DirectionLayout::Rows,
        }
    }

    /// Return the quad for a 0-based frame index.
    ///
    /// # Parameters
    /// - `index` — `usize`.
    ///
    /// # Returns
    /// `Option<Rect>`.
    pub fn get_frame(&self, index: usize) -> Option<Rect> {
        self.frames.get(index).copied()
    }

    /// Total number of frames in the sheet. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `usize`.
    pub fn get_frame_count(&self) -> usize {
        self.frames.len()
    }

    /// Dimensions of a single frame `(width, height)`.
    ///
    /// # Returns
    /// `(u32, u32)`.
    pub fn get_frame_size(&self) -> (u32, u32) {
        (self.frame_width, self.frame_height)
    }

    /// Grid dimensions `(columns, rows)`. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `(u32, u32)`.
    pub fn get_grid_size(&self) -> (u32, u32) {
        (self.columns, self.rows)
    }

    /// Return all frame quads in a 0-based row.
    ///
    /// # Parameters
    /// - `row` — `u32`.
    ///
    /// # Returns
    /// `Vec<Rect>`.
    pub fn get_row(&self, row: u32) -> Vec<Rect> {
        if row >= self.rows {
            return Vec::new();
        }
        let start = (row * self.columns) as usize;
        let end = start + self.columns as usize;
        self.frames[start..end.min(self.frames.len())].to_vec()
    }

    /// Return all frame quads in a 0-based column.
    ///
    /// # Parameters
    /// - `col` — `u32`.
    ///
    /// # Returns
    /// `Vec<Rect>`.
    pub fn get_column(&self, col: u32) -> Vec<Rect> {
        if col >= self.columns {
            return Vec::new();
        }
        (0..self.rows)
            .filter_map(|r| {
                let idx = (r * self.columns + col) as usize;
                self.frames.get(idx).copied()
            })
            .collect()
    }

    /// Return a contiguous range of frame quads starting at `start` (0-based).
    ///
    /// # Parameters
    /// - `start` — `usize`.
    /// - `count` — `usize`.
    ///
    /// # Returns
    /// `Vec<Rect>`.
    pub fn get_range(&self, start: usize, count: usize) -> Vec<Rect> {
        let end = (start + count).min(self.frames.len());
        if start >= self.frames.len() {
            return Vec::new();
        }
        self.frames[start..end].to_vec()
    }

    /// Store a named frame group. Consult the module-level documentation for the broader usage context and preconditions.
    ///
    /// # Parameters
    /// - `name` — `impl Into<String>`.
    /// - `start_frame` — `usize`.
    /// - `count` — `usize`.
    pub fn name_group(&mut self, name: impl Into<String>, start_frame: usize, count: usize) {
        let name = name.into();
        log_msg!(debug, SS02, "{} [{}..{}]", name, start_frame, count);
        self.groups.insert(
            name.clone(),
            FrameGroup {
                name,
                start_frame,
                count,
            },
        );
    }

    /// Return the frame quads for a named group.
    ///
    /// # Parameters
    /// - `name` — `&str`.
    ///
    /// # Returns
    /// `Option<Vec<Rect>>`.
    pub fn get_group(&self, name: &str) -> Option<Vec<Rect>> {
        let group = self.groups.get(name)?;
        Some(self.get_range(group.start_frame, group.count))
    }

    /// Return the names of all defined groups. This accessor incurs no allocation; call it freely in hot paths.
    ///
    /// # Returns
    /// `Vec<String>`.
    pub fn get_group_names(&self) -> Vec<String> {
        self.groups.keys().cloned().collect()
    }

    /// Set the directional mode (4 or 8 directions) and layout.
    ///
    /// # Parameters
    /// - `count` — `u32`.
    /// - `layout` — `DirectionLayout`.
    pub fn set_directions(&mut self, count: u32, layout: DirectionLayout) {
        self.direction_count = Some(count);
        self.direction_layout = layout;
    }

    /// Return the frame quads for a 0-based direction index.
    ///
    /// # Parameters
    /// - `direction` — `u32`.
    ///
    /// # Returns
    /// `Option<Vec<Rect>>`.
    ///
    /// With `Rows` layout, direction `n` maps to row `n`.
    /// With `Columns` layout, direction `n` maps to column `n`.
    pub fn get_direction_frames(&self, direction: u32) -> Option<Vec<Rect>> {
        let count = self.direction_count?;
        if direction >= count {
            return None;
        }
        match self.direction_layout {
            DirectionLayout::Rows => {
                if direction >= self.rows {
                    return None;
                }
                Some(self.get_row(direction))
            }
            DirectionLayout::Columns => {
                if direction >= self.columns {
                    return None;
                }
                Some(self.get_column(direction))
            }
        }
    }

    // ── Rendering ────────────────────────────────────────────────────────

    /// Renders the sprite-sheet grid into a new `ImageData` as a colour-coded debug view.
    ///
    /// Every frame cell is outlined in red. The first frame of each named group is
    /// tinted green. Background is white.
    ///
    /// # Parameters
    /// - `width` — `u32`. Output image width in pixels.
    /// - `height` — `u32`. Output image height in pixels.
    ///
    /// # Returns
    /// `crate::image::ImageData`.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        // White background.
        for y in 0..height {
            for x in 0..width {
                img.set_pixel(x, y, 255, 255, 255, 255);
            }
        }

        // Collect first frames of each group for green highlight.
        let mut group_starts: std::collections::HashSet<usize> = std::collections::HashSet::new();
        for group in self.groups.values() {
            group_starts.insert(group.start_frame);
        }

        let scale_x = width as f32 / self.texture_width as f32;
        let scale_y = height as f32 / self.texture_height as f32;

        for i in 0..self.get_frame_count() {
            if let Some(rect) = self.get_frame(i) {
                let rx = (rect.x * scale_x) as i32;
                let ry = (rect.y * scale_y) as i32;
                let rw = ((rect.width * scale_x) as u32).max(1);
                let rh = ((rect.height * scale_y) as u32).max(1);
                let (r, g, b) = if group_starts.contains(&i) {
                    (0, 200, 0)
                } else {
                    (200, 0, 0)
                };
                // Top and bottom edges.
                img.draw_rect(rx, ry, rw, 1, r, g, b, 255);
                img.draw_rect(rx, ry + rh as i32 - 1, rw, 1, r, g, b, 255);
                // Left and right edges.
                img.draw_rect(rx, ry, 1, rh, r, g, b, 255);
                img.draw_rect(rx + rw as i32 - 1, ry, 1, rh, r, g, b, 255);
            }
        }
        img
    }

    // ── Constructors ─────────────────────────────────────────────────────

    /// Builds an RPGMaker VX/Ace-style 3-column × 4-row character sprite sheet.
    ///
    /// Groups are registered as `"down"` (row 0), `"left"` (row 1), `"right"` (row 2),
    /// `"up"` (row 3). Each row contains 3 frames.
    ///
    /// # Parameters
    /// - `texture_width` — `u32`. Full texture width in pixels.
    /// - `texture_height` — `u32`. Full texture height in pixels.
    ///
    /// # Returns
    /// `SpriteSheet`.
    pub fn from_rpgmaker(texture_width: u32, texture_height: u32) -> Self {
        let mut sheet = Self::new(
            texture_width,
            texture_height,
            texture_width / 3,
            texture_height / 4,
        );
        sheet.name_group("down", 0, 3);
        sheet.name_group("left", 3, 3);
        sheet.name_group("right", 6, 3);
        sheet.name_group("up", 9, 3);
        sheet
    }

    /// Builds a sprite sheet whose frame quads are sourced from named entries in a [`SpriteAtlas`].
    ///
    /// Frames are appended in the atlas's insertion order.  The resulting sheet has no
    /// uniform grid — all frames are laid out as a single row from the atlas rectangles.
    ///
    /// # Parameters
    /// - `atlas` — `&super::atlas::SpriteAtlas`. Source atlas.
    /// - `sheet_width` — `u32`. Full texture width (used for UV normalisation).
    /// - `sheet_height` — `u32`. Full texture height.
    ///
    /// # Returns
    /// `SpriteSheet`.
    pub fn from_atlas(
        atlas: &super::atlas::SpriteAtlas,
        sheet_width: u32,
        sheet_height: u32,
    ) -> Self {
        // Build a 1×N grid sheet as a container and then replace the frames.
        let count = atlas.entry_count().max(1);
        let w = if count > 0 {
            sheet_width / count as u32
        } else {
            sheet_width
        };
        let mut sheet = Self::new(sheet_width, sheet_height, w.max(1), sheet_height);
        // Clear auto-generated frames and replace with atlas entries.
        sheet.frames.clear();
        for i in 0..atlas.entry_count() {
            if let Some(entry) = atlas.get_by_index(i) {
                sheet.frames.push(Rect::new(
                    entry.x as f32,
                    entry.y as f32,
                    entry.w as f32,
                    entry.h as f32,
                ));
                // Also register each entry as its own named group.
                let start = sheet.frames.len() - 1;
                sheet.name_group(&entry.name, start, 1);
            }
        }
        sheet
    }
}
