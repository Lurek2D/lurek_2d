//! This file owns the Wave Function Collapse generator that resolves tile grids from weighted adjacency constraints.
//! `WfcTile`, `WfcRules`, `WfcOpts`, and `WfcGrid` define the tile vocabulary, rule set, run inputs, and result cells.
//! Entropy-style cell choice and weighted collapse stay here because tile selection policy is core WFC behavior.
//! Constraint propagation also belongs here since neighbor pruning and contradiction detection define valid outcomes.
//! Retry logic remains local because contradiction recovery is part of the generator contract, not caller plumbing.

use crate::procgen::lcg::Lcg;
use crate::procgen::{
    limits::{checked_cell_count, validate_non_zero_dimensions, validate_wfc_attempts},
    ProcgenError, ProcgenLimits, ProcgenReport,
};
use std::collections::{HashMap, HashSet};

/// A tile variant with an identifier and a sampling weight.
#[derive(Debug, Clone)]
pub struct WfcTile {
    /// Unique tile identifier referenced by `WfcRules` adjacency maps.
    pub id: u32,
    /// Relative probability weight used when collapsing a superposition; must be > 0.
    pub weight: f32,
}

/// Adjacency constraints between tile IDs.
#[derive(Debug, Clone, Default)]
pub struct WfcRules {
    /// Map from tile ID to the set of tile IDs that may appear in any neighbouring cell.
    /// When a tile ID has no entry, all other tiles are considered valid neighbours.
    pub adjacencies: HashMap<u32, Vec<u32>>,
}

/// Configuration for a WFC generation run.
#[derive(Debug, Clone)]
pub struct WfcOpts {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Full set of available tile variants.
    pub tiles: Vec<WfcTile>,
    /// Adjacency rules applied during constraint propagation.
    pub rules: WfcRules,
    /// Base seed; each retry increments this to avoid repeating the same contradiction.
    pub seed: u64,
    /// Number of generation attempts before returning an all-`None` grid.
    pub max_attempts: u32,
}

impl WfcOpts {
    /// Validate dimensions, attempt budgets, tile weights, and adjacency references for safe WFC generation.
    pub fn validate(&self, limits: &ProcgenLimits) -> Result<(), ProcgenError> {
        validate_non_zero_dimensions(self.width, self.height)?;
        checked_cell_count(self.width, self.height, limits)?;
        if self.tiles.is_empty() {
            return Err(ProcgenError::EmptyTileSet);
        }
        let attempts = self.max_attempts.max(1);
        validate_wfc_attempts(attempts, limits)?;
        let mut ids = HashSet::new();
        for tile in &self.tiles {
            if !ids.insert(tile.id) {
                return Err(ProcgenError::DuplicateTileId { tile_id: tile.id });
            }
            if !tile.weight.is_finite() || tile.weight <= 0.0 {
                return Err(ProcgenError::InvalidTileWeight {
                    tile_id: tile.id,
                    weight: tile.weight,
                });
            }
        }
        for (&owner_id, neighbours) in &self.rules.adjacencies {
            if !ids.contains(&owner_id) {
                return Err(ProcgenError::UnknownAdjacencyTileId {
                    owner_id,
                    tile_id: owner_id,
                });
            }
            for &tile_id in neighbours {
                if !ids.contains(&tile_id) {
                    return Err(ProcgenError::UnknownAdjacencyTileId { owner_id, tile_id });
                }
            }
        }
        Ok(())
    }
}

/// Legacy or safe WFC completion reason.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WfcFailureReason {
    /// Generation completed with a full assignment.
    Success,
    /// Generation was asked to run without any tiles.
    EmptyTileSet,
    /// Dimensions or tile/rule validation failed before generation.
    InvalidInput,
    /// Constraint propagation exhausted the retry budget after contradiction(s).
    Contradiction,
}

/// Diagnostics describing how a WFC generation attempt completed or failed.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WfcReport {
    /// Shared procgen summary fields for the run.
    pub summary: ProcgenReport,
    /// Number of attempts executed.
    pub attempts: u32,
    /// Number of contradiction-triggered retries encountered.
    pub contradictions: u32,
    /// Number of cells collapsed in the last attempt.
    pub collapsed_count: usize,
    /// Final completion or failure reason.
    pub reason: WfcFailureReason,
}

/// Completed WFC grid; cells with no valid assignment are `None` (contradiction or invalid legacy input).
#[derive(Debug, Clone)]
pub struct WfcGrid {
    /// Grid width in cells.
    pub width: u32,
    /// Grid height in cells.
    pub height: u32,
    /// Flat row-major assignment results; `None` indicates unresolved contradiction.
    pub cells: Vec<Option<u32>>,
    /// Generation diagnostics for success or legacy failure fallback.
    pub report: WfcReport,
}

/// Run WFC on `opts`, retrying up to `max_attempts` times; returns a fully-assigned grid or all-`None` on failure.
pub fn wfc_generate(opts: &WfcOpts) -> WfcGrid {
    match try_wfc_generate(opts, &ProcgenLimits::default()) {
        Ok(grid) => grid,
        Err(err) => legacy_failure_grid(opts, &err),
    }
}

/// Run WFC after validating dimensions, attempts, tile weights, and adjacency references.
pub fn try_wfc_generate(opts: &WfcOpts, limits: &ProcgenLimits) -> Result<WfcGrid, ProcgenError> {
    opts.validate(limits)?;
    let n = checked_cell_count(opts.width, opts.height, limits)?;
    let all_ids: Vec<u32> = opts.tiles.iter().map(|t| t.id).collect();
    let weight_map: HashMap<u32, f32> = opts.tiles.iter().map(|t| (t.id, t.weight)).collect();
    let attempts = opts.max_attempts.max(1);
    let idx = |x: u32, y: u32| (y * opts.width + x) as usize;
    let mut contradictions = 0u32;
    let mut last_collapsed_count = 0usize;

    for attempt in 0..attempts {
        let mut rng = Lcg::new(opts.seed.wrapping_add(attempt as u64));
        let mut wave: Vec<Vec<u32>> = vec![all_ids.clone(); n];
        let mut collapsed = vec![false; n];
        let mut result = vec![None; n];
        let mut failed = false;

        loop {
            let chosen = (0..n)
                .filter(|&i| !collapsed[i] && !wave[i].is_empty())
                .min_by_key(|&i| wave[i].len());
            let Some(chosen_idx) = chosen else {
                break;
            };

            let total: f32 = wave[chosen_idx]
                .iter()
                .map(|id| weight_map.get(id).copied().unwrap_or(1.0))
                .sum();
            let mut pick = rng.next_f32() * total;
            let mut chosen_tile = wave[chosen_idx][0];
            for &tid in &wave[chosen_idx] {
                let weight = weight_map.get(&tid).copied().unwrap_or(1.0);
                if pick <= weight {
                    chosen_tile = tid;
                    break;
                }
                pick -= weight;
            }

            wave[chosen_idx] = vec![chosen_tile];
            collapsed[chosen_idx] = true;
            result[chosen_idx] = Some(chosen_tile);
            let mut stack = vec![chosen_idx];

            while let Some(cur) = stack.pop() {
                let cx = (cur as u32) % opts.width;
                let cy = (cur as u32) / opts.width;
                let cur_possible = wave[cur].clone();
                let dirs: [(i32, i32); 4] = [(1, 0), (-1, 0), (0, 1), (0, -1)];

                for (dx, dy) in dirs {
                    let nx = cx as i32 + dx;
                    let ny = cy as i32 + dy;
                    if nx < 0 || ny < 0 || nx >= opts.width as i32 || ny >= opts.height as i32 {
                        continue;
                    }
                    let ni = idx(nx as u32, ny as u32);
                    if collapsed[ni] {
                        continue;
                    }
                    let allowed: Vec<u32> = wave[ni]
                        .iter()
                        .copied()
                        .filter(|nb_tile| {
                            cur_possible.iter().any(|cur_tile| {
                                opts.rules
                                    .adjacencies
                                    .get(cur_tile)
                                    .is_none_or(|adj| adj.contains(nb_tile))
                            })
                        })
                        .collect();
                    if allowed.len() != wave[ni].len() {
                        if allowed.is_empty() {
                            failed = true;
                            break;
                        }
                        wave[ni] = allowed;
                        stack.push(ni);
                    }
                }
                if failed {
                    break;
                }
            }
            if failed {
                break;
            }
        }

        last_collapsed_count = result.iter().filter(|cell| cell.is_some()).count();
        if !failed {
            return Ok(WfcGrid {
                width: opts.width,
                height: opts.height,
                cells: result,
                report: WfcReport {
                    summary: ProcgenReport {
                        seed: Some(opts.seed.wrapping_add(attempt as u64)),
                        cell_count: n,
                        iterations: 0,
                        attempts: attempt + 1,
                    },
                    attempts: attempt + 1,
                    contradictions,
                    collapsed_count: last_collapsed_count,
                    reason: WfcFailureReason::Success,
                },
            });
        }
        contradictions += 1;
    }

    Err(ProcgenError::WfcContradiction {
        attempts,
        collapsed_count: last_collapsed_count,
    })
}

fn legacy_failure_grid(opts: &WfcOpts, err: &ProcgenError) -> WfcGrid {
    let cells = match u64::from(opts.width).checked_mul(u64::from(opts.height)) {
        Some(total) => usize::try_from(total)
            .ok()
            .map_or_else(Vec::new, |n| vec![None; n]),
        None => Vec::new(),
    };
    let reason = match err {
        ProcgenError::EmptyTileSet => WfcFailureReason::EmptyTileSet,
        ProcgenError::WfcContradiction { .. } => WfcFailureReason::Contradiction,
        _ => WfcFailureReason::InvalidInput,
    };
    let (attempts, collapsed_count, contradictions) = match err {
        ProcgenError::WfcContradiction {
            attempts,
            collapsed_count,
        } => (*attempts, *collapsed_count, *attempts),
        _ => (0, 0, 0),
    };
    let cell_count = cells.len();
    WfcGrid {
        width: opts.width,
        height: opts.height,
        cells,
        report: WfcReport {
            summary: ProcgenReport {
                seed: Some(opts.seed),
                cell_count,
                iterations: 0,
                attempts,
            },
            attempts,
            contradictions,
            collapsed_count,
            reason,
        },
    }
}
