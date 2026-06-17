//! Multi-source Dijkstra distance field for goal-oriented AI movement. `pathfind/goal_map` delivers the goal map implementation for the pathfind subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Builds a cost-to-reach map from many weighted source cells. The file owns or coordinates data contracts including `GoalSource`, `GoalMap`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Returns downhill gradient, uphill flee direction, and flood-fill reachability. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `width`, `height`, `add_source`, `set_sources`, `clear_sources`, and 8 more stays attached to the local data model and invariants.
//! Supports custom blocker predicates during baking from Lua bindings. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Serializes and restores the field as a compact binary blob. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

use std::cmp::Reverse;
use std::collections::BinaryHeap;

/// Sentinel value indicating a cell is unreachable.
pub const UNREACHABLE: u32 = u32::MAX;

/// A weighted source cell for the distance field.
#[derive(Clone, Debug)]
pub struct GoalSource {
    /// One-based column (stored as zero-based internally).
    pub x: u32,
    /// One-based row (stored as zero-based internally).
    pub y: u32,
    /// Relative weight; lower weight = stronger attraction. Must be >= 1.
    pub weight: u32,
}

/// Multi-source Dijkstra distance field for tile-grid AI.
///
/// Callers build the field via [`GoalMap::bake`] with a blocker predicate,
/// then query it every frame with [`GoalMap::gradient_at`] or
/// [`GoalMap::flee_at`]. The field only needs rebaking when the map layout
/// or sources change.
pub struct GoalMap {
    /// Grid width in cells.
    width: u32,
    /// Grid height in cells.
    height: u32,
    /// Flat distance array; index = y * width + x.
    distances: Vec<u32>,
    /// Registered source cells (zero-based coordinates).
    sources: Vec<GoalSource>,
    /// True when sources or blockers changed since last bake.
    dirty: bool,
}

impl GoalMap {
    /// Create an empty goal map for the given grid dimensions.
    pub fn new(width: u32, height: u32) -> Self {
        let size = (width * height) as usize;
        Self {
            width,
            height,
            distances: vec![UNREACHABLE; size],
            sources: Vec::new(),
            dirty: true,
        }
    }

    /// Returns the goal-map grid width in cells.
    pub fn width(&self) -> u32 {
        self.width
    }

    /// Returns the goal-map grid height in cells.
    pub fn height(&self) -> u32 {
        self.height
    }

    /// Register a source cell. Coordinates are zero-based.
    pub fn add_source(&mut self, x: u32, y: u32, weight: u32) {
        self.sources.push(GoalSource {
            x,
            y,
            weight: weight.max(1),
        });
        self.dirty = true;
    }

    /// Replace all source cells. Coordinates are zero-based.
    pub fn set_sources(&mut self, sources: Vec<GoalSource>) {
        self.sources = sources;
        self.dirty = true;
    }

    /// Removes all registered source cells from this goal map.
    pub fn clear_sources(&mut self) {
        self.sources.clear();
        self.dirty = true;
    }

    /// Return true when `bake` has not been called since the last mutation.
    pub fn is_dirty(&self) -> bool {
        self.dirty
    }

    /// Run multi-source Dijkstra to build the distance field.
    ///
    /// `blocker(x, y)` returns `true` for impassable cells (zero-based).
    /// After `bake`, `is_dirty` returns `false`.
    pub fn bake(&mut self, blocker: &dyn Fn(u32, u32) -> bool) {
        let size = (self.width * self.height) as usize;
        self.distances = vec![UNREACHABLE; size];

        // Min-heap: (distance, x, y)
        let mut heap: BinaryHeap<Reverse<(u32, u32, u32)>> = BinaryHeap::new();

        for src in &self.sources {
            if src.x < self.width && src.y < self.height && !blocker(src.x, src.y) {
                let idx = self.index(src.x, src.y);
                self.distances[idx] = 0;
                heap.push(Reverse((0, src.x, src.y)));
            }
        }

        while let Some(Reverse((dist, x, y))) = heap.pop() {
            let idx = self.index(x, y);
            if self.distances[idx] < dist {
                continue; // stale entry
            }
            for (nx, ny) in self.neighbors(x, y) {
                if blocker(nx, ny) {
                    continue;
                }
                let nidx = self.index(nx, ny);
                let new_dist = dist.saturating_add(1);
                if new_dist < self.distances[nidx] {
                    self.distances[nidx] = new_dist;
                    heap.push(Reverse((new_dist, nx, ny)));
                }
            }
        }

        self.dirty = false;
    }

    /// Distance from (x, y) to the nearest source. Returns `UNREACHABLE` when
    /// the cell is blocked or disconnected. Coordinates are zero-based.
    pub fn distance_at(&self, x: u32, y: u32) -> u32 {
        if x >= self.width || y >= self.height {
            return UNREACHABLE;
        }
        self.distances[self.index(x, y)]
    }

    /// Downhill gradient at (x, y): normalised direction toward the nearest
    /// source. Returns `(0.0, 0.0)` when unreachable or already at source.
    /// Coordinates are zero-based.
    pub fn gradient_at(&self, x: u32, y: u32) -> (f32, f32) {
        let d = self.distance_at(x, y);
        if d == UNREACHABLE {
            return (0.0, 0.0);
        }
        let mut best_dx: f32 = 0.0;
        let mut best_dy: f32 = 0.0;
        let mut best_d: u32 = d;
        for (nx, ny) in self.neighbors(x, y) {
            let nd = self.distance_at(nx, ny);
            if nd < best_d {
                best_d = nd;
                best_dx = nx as f32 - x as f32;
                best_dy = ny as f32 - y as f32;
            }
        }
        let len = (best_dx * best_dx + best_dy * best_dy).sqrt();
        if len > 0.0 {
            (best_dx / len, best_dy / len)
        } else {
            (0.0, 0.0)
        }
    }

    /// Uphill gradient at (x, y): normalised direction away from sources.
    /// `fear` scales the output magnitude (default 1.0).
    /// Coordinates are zero-based.
    pub fn flee_at(&self, x: u32, y: u32, fear: f32) -> (f32, f32) {
        let (gx, gy) = self.gradient_at(x, y);
        (-gx * fear, -gy * fear)
    }

    /// Return all cells reachable from (cx, cy) within `threshold` steps.
    /// Uses BFS from the center outward. Coordinates are zero-based.
    pub fn flood_fill(&self, cx: u32, cy: u32, threshold: u32) -> Vec<(u32, u32)> {
        let origin_d = self.distance_at(cx, cy);
        if origin_d == UNREACHABLE {
            return Vec::new();
        }
        let mut result = Vec::new();
        for y in 0..self.height {
            for x in 0..self.width {
                let d = self.distance_at(x, y);
                if d != UNREACHABLE && d <= threshold {
                    result.push((x, y));
                }
            }
        }
        result
    }

    /// Serialise the distance field to a compact binary blob.
    ///
    /// Layout: `[width: u32 le][height: u32 le][distances: N × u32 le]`.
    pub fn save(&self) -> Vec<u8> {
        let mut out = Vec::with_capacity(8 + self.distances.len() * 4);
        out.extend_from_slice(&self.width.to_le_bytes());
        out.extend_from_slice(&self.height.to_le_bytes());
        for &d in &self.distances {
            out.extend_from_slice(&d.to_le_bytes());
        }
        out
    }

    /// Restore a distance field from a blob produced by [`GoalMap::save`].
    /// Returns an error string if the blob is malformed or dimensions mismatch.
    pub fn restore(&mut self, data: &[u8]) -> Result<(), String> {
        if data.len() < 8 {
            return Err("goal_map restore: blob too short".into());
        }
        let w = u32::from_le_bytes(data[0..4].try_into().unwrap());
        let h = u32::from_le_bytes(data[4..8].try_into().unwrap());
        if w != self.width || h != self.height {
            return Err(format!(
                "goal_map restore: size mismatch ({w}×{h} vs {}×{})",
                self.width, self.height
            ));
        }
        let expected = 8 + (w * h) as usize * 4;
        if data.len() < expected {
            return Err("goal_map restore: blob truncated".into());
        }
        self.distances = data[8..expected]
            .chunks_exact(4)
            .map(|b| u32::from_le_bytes(b.try_into().unwrap()))
            .collect();
        self.dirty = false;
        Ok(())
    }

    // ── Internal helpers ──────────────────────────────────────────────────────

    /// Flat index for a zero-based (x, y) pair.
    #[inline]
    fn index(&self, x: u32, y: u32) -> usize {
        (y * self.width + x) as usize
    }

    /// 4-connected neighbours within grid bounds.
    #[inline]
    fn neighbors(&self, x: u32, y: u32) -> [(u32, u32); 4] {
        // Saturating arithmetic: wraps stay in-bounds checks below.
        let up = (x, y.saturating_sub(1));
        let down = (x, (y + 1).min(self.height.saturating_sub(1)));
        let left = (x.saturating_sub(1), y);
        let right = ((x + 1).min(self.width.saturating_sub(1)), y);
        [up, down, left, right]
    }
}
