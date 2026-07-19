//! Owns the chunk owner for the tilemap subsystem and keeps its rules local to this file while keeping call sites explicit.
//! Centers the implementation around ChunkMap, DEFAULT_GID, new, with helpers kept close to their invariants.
//! Defines how chunk data is validated, transformed, or stored before neighboring systems use it.
//! Owns tilemap behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on chunk behavior while Lua registration stays elsewhere.
//! Documents the boundary where tilemap code accepts inputs, reports errors, or updates state.

use super::error::TileMapError;
use super::limits::{checked_chunk_cells, checked_flat_index, TileMapLimits};
use crate::log_msg;
use crate::math::Rect;
use crate::runtime::log_messages::{CK01, CK02, CK03};
use std::collections::{BTreeSet, HashMap, HashSet};

const CHUNK_BYTES_MAGIC: &[u8; 4] = b"LCM2";
const CHUNK_BYTES_VERSION: u16 = 1;
const CHUNK_BYTES_FLAGS: u16 = 0;
const CHUNK_BYTES_HEADER_LEN: usize = 12;

/// Infinite tile grid partitioned into fixed-size square chunks loaded on demand.
#[derive(Debug, Clone)]
/// # Fields
pub struct ChunkMap {
    /// Side length in tiles of each square chunk.
    chunk_size: u32,
    /// Sparse map from chunk coordinates to flattened tile GID arrays.
    chunks: HashMap<(i32, i32), Vec<u32>>,
    /// Chunks with tile edits pending downstream renderer/save/minimap work.
    dirty_chunks: HashSet<(i32, i32)>,
    /// Shared allocation and operation ceilings for this map.
    limits: TileMapLimits,
}

impl ChunkMap {
    /// GID value used for tiles in unloaded or unset chunks.
    pub const DEFAULT_GID: u32 = 0;

    /// Create a `ChunkMap` with the given `chunk_size`.
    /// Legacy callers are clamped to a minimum of `1`; use `try_new` for typed validation.
    pub fn new(chunk_size: u32) -> Self {
        debug_assert!(chunk_size >= 1, "chunk_size must be >= 1");
        // Keep the infallible legacy constructor safe even when callers pass
        // a value that cannot fit the default allocation policy.
        let chunk_size = chunk_size.clamp(1, 1024);
        log_msg!(debug, CK01, "chunk_size={}", chunk_size);
        Self {
            chunk_size,
            chunks: HashMap::new(),
            dirty_chunks: HashSet::new(),
            limits: TileMapLimits::default(),
        }
    }

    /// Create a validated `ChunkMap` that rejects zero and oversized chunk allocations.
    pub fn try_new(chunk_size: u32) -> Result<Self, TileMapError> {
        Self::try_new_with_limits(chunk_size, &TileMapLimits::default())
    }

    /// Create a validated `ChunkMap` using explicit limits.
    pub fn try_new_with_limits(
        chunk_size: u32,
        limits: &TileMapLimits,
    ) -> Result<Self, TileMapError> {
        if chunk_size == 0 {
            return Err(TileMapError::InvalidChunkSize { chunk_size });
        }
        limits.validate()?;
        checked_chunk_cells(chunk_size, limits)?;
        let mut map = Self::new(chunk_size);
        map.chunk_size = chunk_size;
        map.limits = *limits;
        Ok(map)
    }

    /// Return the side length in tiles of each chunk.
    pub fn get_chunk_size(&self) -> u32 {
        self.chunk_size
    }

    /// Return the allocation and operation ceilings used by this chunk map.
    pub fn limits(&self) -> TileMapLimits {
        self.limits
    }

    /// Return the GID at tile `(x, y)`; returns `DEFAULT_GID` when the chunk is not loaded.
    pub fn get_tile(&self, x: i32, y: i32) -> u32 {
        let (cx, cy, lx, ly) = self.decompose(x, y);
        match self.chunks.get(&(cx, cy)) {
            Some(chunk) => checked_flat_index(self.chunk_size, lx, ly, chunk.len())
                .and_then(|index| chunk.get(index).copied())
                .unwrap_or(Self::DEFAULT_GID),
            None => Self::DEFAULT_GID,
        }
    }

    /// Write `gid` to tile `(x, y)`, allocating the chunk if needed.
    pub fn set_tile(&mut self, x: i32, y: i32, gid: u32) {
        let _ = self.try_set_tile(x, y, gid);
    }

    /// Write `gid` to tile `(x, y)`, returning an error before an over-ceiling chunk allocation.
    pub fn try_set_tile(&mut self, x: i32, y: i32, gid: u32) -> Result<(), TileMapError> {
        let (cx, cy, lx, ly) = self.decompose(x, y);
        if !self.chunks.contains_key(&(cx, cy)) {
            self.try_load_chunk(cx, cy)?;
        }
        let requested = self.chunks.len().saturating_add(1);
        let max_chunks = self.limits.max_chunks;
        let Some(chunk) = self.chunks.get_mut(&(cx, cy)) else {
            return Err(TileMapError::MaxChunksExceeded {
                requested,
                max_chunks,
            });
        };
        let index = checked_flat_index(self.chunk_size, lx, ly, chunk.len()).ok_or(
            TileMapError::InvalidTileCoord {
                layer: 0,
                x: lx,
                y: ly,
                width: self.chunk_size,
                height: self.chunk_size,
            },
        )?;
        if chunk[index] != gid {
            chunk[index] = gid;
            self.mark_dirty_chunk(cx, cy);
        }
        Ok(())
    }

    /// Reset tile `(x, y)` to GID 0, allocating the chunk if needed.
    pub fn clear_tile(&mut self, x: i32, y: i32) {
        self.set_tile(x, y, 0);
    }

    /// Apply multiple tile edits in one call and return the dirty chunks touched.
    pub fn set_tiles(&mut self, edits: &[(i32, i32, u32)]) -> Vec<(i32, i32)> {
        self.try_set_tiles(edits).unwrap_or_default()
    }

    /// Apply multiple tile edits with one operation ceiling and return touched dirty chunks.
    pub fn try_set_tiles(
        &mut self,
        edits: &[(i32, i32, u32)],
    ) -> Result<Vec<(i32, i32)>, TileMapError> {
        if edits.len() as u64 > self.limits.max_tile_operation_cells {
            return Err(TileMapError::TileOperationLimitExceeded {
                cells: edits.len() as u64,
                max_cells: self.limits.max_tile_operation_cells,
            });
        }
        let mut changed = BTreeSet::new();
        for (x, y, gid) in edits {
            let before = self.get_tile(*x, *y);
            self.try_set_tile(*x, *y, *gid)?;
            if before != *gid {
                changed.insert(self.tile_to_chunk(*x, *y));
            }
        }
        Ok(changed.into_iter().collect())
    }

    /// Fill all tiles in the rectangle `[x0,x1) x [y0,y1)` with `gid`.
    /// Legacy callers silently skip oversized work; use `try_fill_rect` for typed validation.
    pub fn fill_rect(&mut self, x0: i32, y0: i32, x1: i32, y1: i32, gid: u32) {
        let limits = self.limits;
        let _ = self.try_fill_rect(x0, y0, x1, y1, gid, &limits);
    }

    /// Fill all tiles in the rectangle `[x0,x1) x [y0,y1)` with `gid`, rejecting oversized work.
    pub fn try_fill_rect(
        &mut self,
        x0: i32,
        y0: i32,
        x1: i32,
        y1: i32,
        gid: u32,
        limits: &TileMapLimits,
    ) -> Result<(), TileMapError> {
        let width = i64::from(x1).saturating_sub(i64::from(x0)).max(0) as u64;
        let height = i64::from(y1).saturating_sub(i64::from(y0)).max(0) as u64;
        let checks = width
            .checked_mul(height)
            .ok_or(TileMapError::TileOperationLimitExceeded {
                cells: u64::MAX,
                max_cells: limits.max_tile_operation_cells,
            })?;
        if checks > limits.max_tile_operation_cells {
            return Err(TileMapError::TileOperationLimitExceeded {
                cells: checks,
                max_cells: limits.max_tile_operation_cells,
            });
        }
        for y in y0..y1 {
            for x in x0..x1 {
                self.try_set_tile(x, y, gid)?;
            }
        }
        Ok(())
    }

    /// Ensure the chunk at `(cx, cy)` is allocated; no-op when already loaded.
    pub fn load_chunk(&mut self, cx: i32, cy: i32) {
        let _ = self.try_load_chunk(cx, cy);
    }

    /// Ensure the chunk at `(cx, cy)` is allocated within the configured chunk ceiling.
    pub fn try_load_chunk(&mut self, cx: i32, cy: i32) -> Result<(), TileMapError> {
        log_msg!(debug, CK02, "({}, {})", cx, cy);
        if self.chunks.contains_key(&(cx, cy)) {
            return Ok(());
        }
        if self.chunks.len() >= self.limits.max_chunks {
            return Err(TileMapError::MaxChunksExceeded {
                requested: self.chunks.len().saturating_add(1),
                max_chunks: self.limits.max_chunks,
            });
        }
        let cs = self.chunk_size;
        let cells = checked_chunk_cells(cs, &self.limits)?;
        self.chunks
            .entry((cx, cy))
            .or_insert_with(|| vec![0u32; cells]);
        Ok(())
    }

    /// Discard the chunk at `(cx, cy)` and free its memory.
    pub fn unload_chunk(&mut self, cx: i32, cy: i32) {
        log_msg!(debug, CK03, "({}, {})", cx, cy);
        self.chunks.remove(&(cx, cy));
        self.dirty_chunks.remove(&(cx, cy));
    }

    /// Return a stable list of chunks with pending tile changes.
    pub fn get_dirty_chunks(&self) -> Vec<(i32, i32)> {
        let mut chunks = self.dirty_chunks.iter().copied().collect::<Vec<_>>();
        chunks.sort();
        chunks
    }

    /// Clear dirty chunk tracking without changing tile data.
    pub fn clear_dirty_chunks(&mut self) {
        self.dirty_chunks.clear();
    }

    /// Clear and return chunks with pending tile changes.
    pub fn drain_dirty_chunks(&mut self) -> Vec<(i32, i32)> {
        let chunks = self.get_dirty_chunks();
        self.clear_dirty_chunks();
        chunks
    }

    /// Return the coordinates of all currently loaded chunks.
    pub fn get_loaded_chunks(&self) -> Vec<(i32, i32)> {
        self.chunks.keys().copied().collect()
    }

    /// Return the number of currently loaded chunks.
    pub fn get_loaded_chunk_count(&self) -> usize {
        self.chunks.len()
    }

    /// Return `true` when the chunk at `(cx, cy)` is loaded.
    pub fn is_chunk_loaded(&self, cx: i32, cy: i32) -> bool {
        self.chunks.contains_key(&(cx, cy))
    }

    /// Convert tile coordinates `(x, y)` to their parent chunk coordinates.
    pub fn tile_to_chunk(&self, x: i32, y: i32) -> (i32, i32) {
        let cs = self.chunk_size as i32;
        (x.div_euclid(cs), y.div_euclid(cs))
    }

    /// Return the inclusive tile range `(min_x, min_y, max_x, max_y)` covered by chunk `(cx, cy)`.
    pub fn chunk_tile_range(&self, cx: i32, cy: i32) -> (i32, i32, i32, i32) {
        let cs = self.chunk_size as i32;
        let x0 = cx.saturating_mul(cs);
        let y0 = cy.saturating_mul(cs);
        (x0, y0, x0.saturating_add(cs), y0.saturating_add(cs))
    }

    /// Return all chunk coordinates overlapping a view rectangle `(vx,vy,vw,vh)` with tile size `(tw,th)`.
    pub fn get_chunks_in_view(
        &self,
        vx: f32,
        vy: f32,
        vw: f32,
        vh: f32,
        tw: f32,
        th: f32,
    ) -> Vec<(i32, i32)> {
        self.try_get_chunks_in_view(vx, vy, vw, vh, tw, th)
            .unwrap_or_default()
    }

    /// Return visible chunk coordinates with a bounded result allocation.
    pub fn try_get_chunks_in_view(
        &self,
        vx: f32,
        vy: f32,
        vw: f32,
        vh: f32,
        tw: f32,
        th: f32,
    ) -> Result<Vec<(i32, i32)>, TileMapError> {
        if ![vx, vy, vw, vh, tw, th].iter().all(|v| v.is_finite()) {
            return Err(TileMapError::NonFiniteFloat {
                context: "chunk view",
            });
        }
        if vw <= 0.0 || vh <= 0.0 || tw <= 0.0 || th <= 0.0 {
            return Err(TileMapError::NonPositiveFloat {
                context: "chunk view extent",
                value: vw.min(vh).min(tw).min(th),
            });
        }
        if self.chunk_size == 0 {
            return Err(TileMapError::InvalidChunkSize {
                chunk_size: self.chunk_size,
            });
        }
        let cs = self.chunk_size as f32;
        let cpw = cs * tw;
        let cph = cs * th;
        if !cpw.is_finite() || !cph.is_finite() || cpw <= 0.0 || cph <= 0.0 {
            return Err(TileMapError::NonPositiveFloat {
                context: "chunk view cell size",
                value: cpw.min(cph),
            });
        }
        let Some(cx_min) = finite_i32((vx / cpw).floor()) else {
            return Err(TileMapError::NonFiniteFloat {
                context: "chunk view x bounds",
            });
        };
        let Some(cy_min) = finite_i32((vy / cph).floor()) else {
            return Err(TileMapError::NonFiniteFloat {
                context: "chunk view y bounds",
            });
        };
        let Some(cx_max) = finite_i32(((vx + vw) / cpw).ceil()) else {
            return Err(TileMapError::NonFiniteFloat {
                context: "chunk view x bounds",
            });
        };
        let Some(cy_max) = finite_i32(((vy + vh) / cph).ceil()) else {
            return Err(TileMapError::NonFiniteFloat {
                context: "chunk view y bounds",
            });
        };
        let span_x = (i64::from(cx_max) - i64::from(cx_min) + 1).max(0) as u64;
        let span_y = (i64::from(cy_max) - i64::from(cy_min) + 1).max(0) as u64;
        let cells = span_x
            .checked_mul(span_y)
            .ok_or(TileMapError::TileOperationLimitExceeded {
                cells: u64::MAX,
                max_cells: self.limits.max_tile_operation_cells,
            })?;
        if cells > self.limits.max_tile_operation_cells {
            return Err(TileMapError::TileOperationLimitExceeded {
                cells,
                max_cells: self.limits.max_tile_operation_cells,
            });
        }
        let capacity =
            usize::try_from(cells).map_err(|_| TileMapError::TileOperationLimitExceeded {
                cells,
                max_cells: self.limits.max_tile_operation_cells,
            })?;
        let mut result = Vec::with_capacity(capacity);
        for cy in cy_min..=cy_max {
            for cx in cx_min..=cx_max {
                result.push((cx, cy));
            }
        }
        Ok(result)
    }

    /// Return the world-space `Rect` occupied by chunk `(cx, cy)` given tile dimensions `(tw, th)`.
    pub fn chunk_world_rect(&self, cx: i32, cy: i32, tw: f32, th: f32) -> Rect {
        if !tw.is_finite() || !th.is_finite() || tw <= 0.0 || th <= 0.0 {
            return Rect::new(0.0, 0.0, 0.0, 0.0);
        }
        let cs = self.chunk_size as f32;
        Rect::new(cx as f32 * cs * tw, cy as f32 * cs * th, cs * tw, cs * th)
    }

    /// Return the tile slice of chunk `(cx, cy)`, or `None` when the chunk is not loaded.
    pub fn iter_chunk(&self, cx: i32, cy: i32) -> Option<&[u32]> {
        self.chunks.get(&(cx, cy)).map(|v| v.as_slice())
    }

    /// Serialize one loaded chunk to a compact binary format.
    pub fn chunk_to_bytes(&self, cx: i32, cy: i32) -> Option<Vec<u8>> {
        let chunk = self.chunks.get(&(cx, cy))?;
        let mut out = Vec::with_capacity(CHUNK_BYTES_HEADER_LEN + chunk.len() * 4);
        out.extend_from_slice(CHUNK_BYTES_MAGIC);
        out.extend_from_slice(&CHUNK_BYTES_VERSION.to_le_bytes());
        out.extend_from_slice(&CHUNK_BYTES_FLAGS.to_le_bytes());
        out.extend_from_slice(&self.chunk_size.to_le_bytes());
        for gid in chunk {
            out.extend_from_slice(&gid.to_le_bytes());
        }
        Some(out)
    }

    /// Load one chunk from bytes produced by `chunk_to_bytes`.
    pub fn load_chunk_from_bytes(&mut self, cx: i32, cy: i32, bytes: &[u8]) -> Result<(), String> {
        if bytes.len() < CHUNK_BYTES_HEADER_LEN || &bytes[0..4] != CHUNK_BYTES_MAGIC {
            return Err("chunk bytes have an invalid LChunkMap header".to_string());
        }
        let version = u16::from_le_bytes([bytes[4], bytes[5]]);
        if version != CHUNK_BYTES_VERSION {
            return Err(format!(
                "chunk bytes use version {version}, expected {CHUNK_BYTES_VERSION}"
            ));
        }
        let flags = u16::from_le_bytes([bytes[6], bytes[7]]);
        if flags != CHUNK_BYTES_FLAGS {
            return Err(format!("chunk bytes contain reserved flags 0x{flags:04x}"));
        }
        let chunk_size = u32::from_le_bytes([bytes[8], bytes[9], bytes[10], bytes[11]]);
        if chunk_size != self.chunk_size {
            return Err(format!(
                "chunk bytes use chunk size {chunk_size}, expected {}",
                self.chunk_size
            ));
        }
        let cells =
            checked_chunk_cells(self.chunk_size, &self.limits).map_err(|err| err.to_string())?;
        let expected = CHUNK_BYTES_HEADER_LEN
            .checked_add(
                cells
                    .checked_mul(4)
                    .ok_or_else(|| "chunk byte size overflowed addressable storage".to_string())?,
            )
            .ok_or_else(|| "chunk byte size overflowed addressable storage".to_string())?;
        if bytes.len() != expected {
            return Err(format!(
                "chunk bytes expected {expected} bytes, got {}",
                bytes.len()
            ));
        }
        let mut chunk = Vec::with_capacity(cells);
        for raw in bytes[CHUNK_BYTES_HEADER_LEN..].chunks_exact(4) {
            chunk.push(u32::from_le_bytes([raw[0], raw[1], raw[2], raw[3]]));
        }
        self.try_load_chunk(cx, cy).map_err(|err| err.to_string())?;
        self.chunks.insert((cx, cy), chunk);
        self.mark_dirty_chunk(cx, cy);
        Ok(())
    }

    /// Decompose world tile `(x, y)` into chunk coordinates `(cx, cy)` and local tile offsets `(lx, ly)`.
    fn decompose(&self, x: i32, y: i32) -> (i32, i32, u32, u32) {
        let cs = self.chunk_size as i32;
        let cx = x.div_euclid(cs);
        let cy = y.div_euclid(cs);
        let lx = x.rem_euclid(cs) as u32;
        let ly = y.rem_euclid(cs) as u32;
        (cx, cy, lx, ly)
    }

    fn mark_dirty_chunk(&mut self, cx: i32, cy: i32) {
        self.dirty_chunks.insert((cx, cy));
    }
}

fn finite_i32(value: f32) -> Option<i32> {
    value.is_finite().then_some(value).and_then(|value| {
        (i32::MIN as f32..=i32::MAX as f32)
            .contains(&value)
            .then_some(value as i32)
    })
}
