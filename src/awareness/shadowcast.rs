//! This file owns `TileFov`, the tile-grid field-of-view runtime that computes current sight and remembered exploration.
//! It stores dimensions, range, wall-lighting policy, and per-cell visible or explored masks for one observer context.
//! `compute` runs deterministic recursive shadowcasting across eight octants using a caller-supplied blocker predicate.
//! Helpers expose width, height, range, visible cells, explored state, and callback iteration over current sight.
//! Save and restore logic serializes packed visibility masks so field-of-view memory can survive persistence boundaries.
//! Internal bit-pack helpers keep the blob compact, while private casting code isolates slope math from public APIs.
//! Open this file when tile FOV behavior changes; shared region-state visibility logic lives in sibling modules.

/// Per-cell visibility state for a single observer on a tile grid.
pub struct TileFov {
    /// Grid width in cells.
    width: u32,
    /// Grid height in cells.
    height: u32,
    /// Maximum visibility radius in cells.
    range: u32,
    /// When true, blocking cells on the boundary are considered visible.
    light_walls: bool,
    /// True for every cell visible in the current `compute` call.
    visible: Vec<bool>,
    /// True for every cell seen at least once across all `compute` calls.
    explored: Vec<bool>,
}

impl TileFov {
    /// Create a new `TileFov` for a grid of `width` × `height` cells.
    /// `range` is the maximum Manhattan-like sight radius. `light_walls`
    /// controls whether opaque edge cells are lit.
    pub fn new(width: u32, height: u32, range: u32, light_walls: bool) -> Self {
        let size = (width * height) as usize;
        Self {
            width,
            height,
            range,
            light_walls,
            visible: vec![false; size],
            explored: vec![false; size],
        }
    }

    /// Returns the visibility-grid width in cells.
    pub fn width(&self) -> u32 {
        self.width
    }

    /// Returns the visibility-grid height in cells.
    pub fn height(&self) -> u32 {
        self.height
    }

    /// Return the current visibility radius.
    pub fn range(&self) -> u32 {
        self.range
    }

    /// Change the visibility radius for subsequent `compute` calls.
    pub fn set_range(&mut self, range: u32) {
        self.range = range;
    }

    /// Run recursive shadowcasting from the observer at zero-based (ox, oy).
    /// `blocker(x, y)` returns `true` for opaque cells. Resets `visible`,
    /// then marks newly visible cells in both `visible` and `explored`.
    pub fn compute(&mut self, ox: u32, oy: u32, blocker: &dyn Fn(u32, u32) -> bool) {
        // Reset current frame visibility
        for v in &mut self.visible {
            *v = false;
        }

        // Origin is always visible
        if ox < self.width && oy < self.height {
            self.mark_visible(ox, oy);
        }

        // Run all 8 octants
        let light_walls = self.light_walls;
        for octant in 0..8u8 {
            let p = CastParams {
                ox: ox as i32,
                oy: oy as i32,
                row: 1,
                start_slope: 1.0,
                end_slope: 0.0,
                octant,
            };
            self.cast_light(p, light_walls, blocker);
        }
    }

    /// Return `true` if the cell at zero-based (x, y) is visible in the current frame.
    pub fn is_visible(&self, x: u32, y: u32) -> bool {
        if x >= self.width || y >= self.height {
            return false;
        }
        self.visible[(y * self.width + x) as usize]
    }

    /// Return `true` if the cell at zero-based (x, y) has ever been seen.
    pub fn is_explored(&self, x: u32, y: u32) -> bool {
        if x >= self.width || y >= self.height {
            return false;
        }
        self.explored[(y * self.width + x) as usize]
    }

    /// Clear the explored mask — all cells become unexplored.
    pub fn reset_explored(&mut self) {
        for e in &mut self.explored {
            *e = false;
        }
    }

    /// Iterate over every currently visible cell, calling `f(x, y)` for each.
    /// Coordinates are zero-based.
    pub fn each_visible(&self, mut f: impl FnMut(u32, u32)) {
        for y in 0..self.height {
            for x in 0..self.width {
                if self.visible[(y * self.width + x) as usize] {
                    f(x, y);
                }
            }
        }
    }

    /// Collect all currently visible cells as `(x, y)` pairs (zero-based).
    pub fn visible_cells(&self) -> Vec<(u32, u32)> {
        let mut out = Vec::new();
        self.each_visible(|x, y| out.push((x, y)));
        out
    }

    /// Serialise `visible` + `explored` as a compact binary blob.
    ///
    /// Layout:
    /// `[width: u32 le][height: u32 le][N visible bits packed][N explored bits packed]`
    /// where N = width × height rounded up to the next byte.
    pub fn save(&self) -> Vec<u8> {
        let n = (self.width * self.height) as usize;
        let byte_count = n.div_ceil(8);
        let mut out = Vec::with_capacity(8 + byte_count * 2);
        out.extend_from_slice(&self.width.to_le_bytes());
        out.extend_from_slice(&self.height.to_le_bytes());
        out.extend(pack_bits(&self.visible));
        out.extend(pack_bits(&self.explored));
        out
    }

    /// Restore from a blob produced by [`TileFov::save`].
    /// Returns an error string on malformed input or dimension mismatch.
    pub fn restore(&mut self, data: &[u8]) -> Result<(), String> {
        if data.len() < 8 {
            return Err("fov restore: blob too short".into());
        }
        let w = u32::from_le_bytes(
            data[0..4]
                .try_into()
                .map_err(|_| "fov restore: invalid width bytes")?,
        );
        let h = u32::from_le_bytes(
            data[4..8]
                .try_into()
                .map_err(|_| "fov restore: invalid height bytes")?,
        );
        if w != self.width || h != self.height {
            return Err(format!(
                "fov restore: dimension mismatch ({w}×{h} vs {}×{})",
                self.width, self.height
            ));
        }
        let n = (w * h) as usize;
        let byte_count = n.div_ceil(8);
        let expected = 8 + byte_count * 2;
        if data.len() < expected {
            return Err("fov restore: blob truncated".into());
        }
        self.visible = unpack_bits(&data[8..8 + byte_count], n);
        self.explored = unpack_bits(&data[8 + byte_count..expected], n);
        Ok(())
    }

    // ── Private ───────────────────────────────────────────────────────────────

    /// Mark a cell visible in the current frame and explored permanently.
    fn mark_visible(&mut self, x: u32, y: u32) {
        let idx = (y * self.width + x) as usize;
        self.visible[idx] = true;
        self.explored[idx] = true;
    }

    /// Recursive shadowcasting for one octant.
    /// `light_walls` is passed by value to avoid a `self` borrow alongside the mutable borrow
    /// inside the recursive call.
    fn cast_light(&mut self, p: CastParams, light_walls: bool, blocker: &dyn Fn(u32, u32) -> bool) {
        // Octant transform table: (xx, xy, yx, yy) for each octant
        const MULT: [[i32; 4]; 8] = [
            [1, 0, 0, 1],
            [0, 1, 1, 0],
            [0, -1, 1, 0],
            [-1, 0, 0, 1],
            [-1, 0, 0, -1],
            [0, -1, -1, 0],
            [0, 1, -1, 0],
            [1, 0, 0, -1],
        ];
        let m = &MULT[p.octant as usize];

        let mut start_slope = p.start_slope;
        if start_slope < p.end_slope {
            return;
        }

        let range = self.range;
        let mut previous_was_blocked = false;
        let mut r = p.row;

        while r <= range {
            let dy = -(r as i32);
            let dx_start = (-dy as f32 * start_slope) as i32;

            let mut blocked = false;
            let mut dx = dx_start;

            'col: loop {
                let wx = p.ox + dx * m[0] + dy * m[1];
                let wy = p.oy + dx * m[2] + dy * m[3];

                if wx < 0 || wy < 0 || wx >= self.width as i32 || wy >= self.height as i32 {
                    dx += 1;
                    if dx > 0 {
                        break 'col;
                    }
                    continue;
                }

                let wx = wx as u32;
                let wy = wy as u32;

                let l_slope = (dx as f32 - 0.5) / (dy as f32 + 0.5);
                let r_slope = (dx as f32 + 0.5) / (dy as f32 - 0.5);

                if start_slope < r_slope {
                    dx += 1;
                    if dx > 0 {
                        break 'col;
                    }
                    continue;
                }
                if p.end_slope > l_slope {
                    break 'col;
                }

                let is_blocked = blocker(wx, wy);

                // Mark visible when open, or when opaque and light_walls is enabled.
                if !is_blocked || light_walls {
                    self.mark_visible(wx, wy);
                }

                if previous_was_blocked {
                    if !is_blocked {
                        previous_was_blocked = false;
                        start_slope = r_slope;
                    }
                } else if is_blocked {
                    blocked = true;
                    let child = CastParams {
                        ox: p.ox,
                        oy: p.oy,
                        row: r + 1,
                        start_slope,
                        end_slope: l_slope,
                        octant: p.octant,
                    };
                    self.cast_light(child, light_walls, blocker);
                    previous_was_blocked = true;
                    start_slope = r_slope;
                }

                dx += 1;
                if dx > 0 {
                    break 'col;
                }
            }

            if blocked {
                break;
            }
            r += 1;
        }
    }
}

/// Parameters for one recursive shadowcast call — avoids `too_many_arguments`.
struct CastParams {
    ox: i32,
    oy: i32,
    row: u32,
    start_slope: f32,
    end_slope: f32,
    octant: u8,
}

// ── Bit packing helpers ───────────────────────────────────────────────────────

/// Pack a slice of booleans into a byte vec (LSB-first per byte).
fn pack_bits(bits: &[bool]) -> Vec<u8> {
    let byte_count = bits.len().div_ceil(8);
    let mut out = vec![0u8; byte_count];
    for (i, &b) in bits.iter().enumerate() {
        if b {
            out[i / 8] |= 1 << (i % 8);
        }
    }
    out
}

/// Unpack a byte slice back into a bool vec of `n` elements.
fn unpack_bits(bytes: &[u8], n: usize) -> Vec<bool> {
    let mut out = vec![false; n];
    for i in 0..n {
        out[i] = (bytes[i / 8] >> (i % 8)) & 1 == 1;
    }
    out
}
