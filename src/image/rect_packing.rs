//! Implements a shelf-based rectangle packer used to place many sprites or regions into bounded atlas space.
//! Tracks padding, packed outputs, and shelf cursor state so callers can inspect occupancy after each insert.
//! Returns PackedRect placements only when width and height fit the configured container without overlap.
//! Resets internal shelves and placements on clear, making this the owner for packer lifecycle semantics.
//! Open this file when atlas occupancy, placement order, or padding handling produces wasted or invalid space.

/// Placement result for a single packed rectangle.
///
/// # Fields
///
/// Optional caller id and checked atlas coordinates describe one content rectangle.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PackedRect {
    /// Optional label assigned by the caller for mapping back to source assets.
    pub id: Option<String>,
    /// Left edge of the placed rectangle within the atlas, in pixels.
    pub x: u32,
    /// Top edge of the placed rectangle within the atlas, in pixels.
    pub y: u32,
    /// Width of the content area, not including padding.
    pub w: u32,
    /// Height of the content area, not including padding.
    pub h: u32,
}

/// Internal shelf row tracking its Y position, height, and fill cursor.
#[derive(Debug, Clone)]
struct Shelf {
    /// Y origin of this shelf in the atlas.
    y: u32,
    /// Row height reserved for this shelf (tallest rect + padding placed so far).
    height: u32,
    /// X position of the next free slot in this shelf.
    cursor_x: u32,
}

/// Shelf-first texture-atlas packer with configurable atlas dimensions and uniform padding.
///
/// # Fields
///
/// Atlas dimensions, padding, internal shelves, and insertion-order placements define one packing session.
#[derive(Debug, Clone)]
pub struct RectPacker {
    /// Atlas width in pixels.
    width: u32,
    /// Atlas height in pixels.
    height: u32,
    /// Uniform pixel gap added to every rect on the right and bottom.
    padding: u32,
    /// Ordered list of shelves from top to bottom.
    shelves: Vec<Shelf>,
    /// All successfully placed rects in insertion order.
    packed: Vec<PackedRect>,
}
impl RectPacker {
    /// Construct a packer with the given atlas `width × height` and uniform `padding`.
    pub fn new(width: u32, height: u32, padding: u32) -> Self {
        Self {
            width,
            height,
            padding,
            shelves: Vec::new(),
            packed: Vec::new(),
        }
    }
    /// Place a `w × h` rectangle with optional `id` label; returns placement or `None` when no space remains.
    pub fn pack(&mut self, w: u32, h: u32, id: Option<String>) -> Option<PackedRect> {
        if self.packed.len() >= crate::image::ImageLimits::default().max_atlas_rectangles {
            return None;
        }
        if w == 0 || h == 0 {
            return None;
        }
        let pw = w.saturating_add(self.padding);
        let ph = h.saturating_add(self.padding);
        if pw > self.width || ph > self.height {
            return None;
        }
        for shelf in &mut self.shelves {
            if ph <= shelf.height && shelf.cursor_x.saturating_add(pw) <= self.width {
                let placed = PackedRect {
                    id,
                    x: shelf.cursor_x,
                    y: shelf.y,
                    w,
                    h,
                };
                shelf.cursor_x = shelf.cursor_x.saturating_add(pw);
                self.packed.push(placed.clone());
                return Some(placed);
            }
        }
        let next_y = self
            .shelves
            .last()
            .map(|s| s.y.saturating_add(s.height))
            .unwrap_or(0);
        if next_y.saturating_add(ph) > self.height {
            return None;
        }
        let mut shelf = Shelf {
            y: next_y,
            height: ph,
            cursor_x: 0,
        };
        let placed = PackedRect {
            id,
            x: 0,
            y: next_y,
            w,
            h,
        };
        shelf.cursor_x = pw;
        self.shelves.push(shelf);
        self.packed.push(placed.clone());
        Some(placed)
    }
    /// Remove all placed rects and reset shelves, keeping atlas dimensions unchanged.
    pub fn clear(&mut self) {
        self.shelves.clear();
        self.packed.clear();
    }
    /// Return a slice of all successfully placed rects in insertion order.
    pub fn packed_rects(&self) -> &[PackedRect] {
        &self.packed
    }
    /// Return the fraction `[0,1]` of the atlas area covered by placed rects, excluding padding.
    pub fn occupancy(&self) -> f32 {
        if self.width == 0 || self.height == 0 {
            return 0.0;
        }
        let used: u64 = self
            .packed
            .iter()
            .map(|r| (r.w as u64) * (r.h as u64))
            .sum();
        let total = (self.width as u64) * (self.height as u64);
        (used as f32 / total as f32).clamp(0.0, 1.0)
    }
    /// Return the atlas dimensions as `(width, height)` in pixels.
    pub fn size(&self) -> (u32, u32) {
        (self.width, self.height)
    }
    /// Return the uniform padding value used during packing.
    pub fn padding(&self) -> u32 {
        self.padding
    }
}
