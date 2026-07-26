//! This file owns deterministic constrained placement and flat-grid connectivity validation for procgen data.
//! Placement consumes neutral coordinates, tags, levels, regions, weights, and caller uniqueness groups.
//! Seeded weighted selection remains bounded by shared procgen limits and returns partial diagnostic reports.
//! Connectivity consumes integer cells plus plain starts, goals, and safe points through iterative flood fill.
//! Stable ordered collections make component tie breaks, rejection counts, and returned diagnostics reproducible.
//! Public Rust helpers expose typed inputs and reports while Lua bindings only translate tables and userdata.
//! The algorithms never call Lua callbacks and never inspect tilefields, entities, loot, combat, or world state.
//! Open this file when neutral placement or connectivity rules change inside the existing procgen namespace.

use super::lcg::Lcg;
use super::limits::{checked_cell_count, validate_count, validate_finite, validate_iterations};
use super::{ProcgenError, ProcgenLimits};
use std::collections::{BTreeMap, BTreeSet, VecDeque};

/// One neutral candidate accepted by constrained placement.
#[derive(Debug, Clone, PartialEq)]
pub struct PlacementCandidate {
    /// Optional caller identifier returned unchanged with a placement.
    pub id: Option<String>,
    /// Horizontal coordinate.
    pub x: f64,
    /// Vertical coordinate.
    pub y: f64,
    /// Optional caller-defined level identifier.
    pub level: Option<String>,
    /// Optional caller-defined region identifier.
    pub region: Option<String>,
    /// Neutral candidate tags.
    pub tags: BTreeSet<String>,
    /// Positive weighted-selection contribution.
    pub weight: f64,
    /// Optional group that may appear at most once in the result.
    pub uniqueness_group: Option<String>,
}

/// Deterministic rules applied to a candidate set.
#[derive(Debug, Clone, PartialEq)]
pub struct PlacementRules {
    /// Requested number of placements.
    pub count: usize,
    /// Tags every selected candidate must carry.
    pub required_tags: BTreeSet<String>,
    /// Tags that disqualify a candidate.
    pub forbidden_tags: BTreeSet<String>,
    /// Minimum Euclidean distance between placements on the same level.
    pub min_distance: f64,
    /// Optional fallback capacity for every named region.
    pub default_region_capacity: Option<usize>,
    /// Per-region capacity overrides.
    pub region_capacities: BTreeMap<String, usize>,
}

/// One selected candidate together with its stable one-based input index.
#[derive(Debug, Clone, PartialEq)]
pub struct Placement {
    /// One-based index in the original candidate array.
    pub candidate_index: usize,
    /// Selected neutral candidate data.
    pub candidate: PlacementCandidate,
}

/// Bounded deterministic report returned by constrained placement.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PlacementReport {
    /// Seed supplied by the caller.
    pub seed: u64,
    /// Requested placement count.
    pub requested: usize,
    /// Number of selected placements.
    pub placed: usize,
    /// Number of weighted selection passes executed.
    pub attempts: u32,
    /// Whether the requested count was satisfied.
    pub complete: bool,
    /// Candidate rejection counts keyed by stable reason.
    pub rejected: BTreeMap<String, usize>,
}

/// Selects a bounded weighted subset satisfying all neutral rules.
pub fn place_constrained(
    candidates: &[PlacementCandidate],
    rules: &PlacementRules,
    seed: u64,
    max_attempts: u32,
    limits: &ProcgenLimits,
) -> Result<(Vec<Placement>, PlacementReport), ProcgenError> {
    validate_count(
        "procgen constrained candidates",
        candidates.len(),
        usize::try_from(limits.max_cells).unwrap_or(usize::MAX),
    )?;
    validate_iterations(max_attempts, limits)?;
    validate_finite("min_distance", rules.min_distance)?;
    if rules.min_distance < 0.0 {
        return Err(ProcgenError::ValueOutOfRange {
            field: "min_distance",
            min: 0.0,
            max: f64::MAX,
            value: rules.min_distance,
        });
    }
    for candidate in candidates {
        validate_finite("candidate.x", candidate.x)?;
        validate_finite("candidate.y", candidate.y)?;
        validate_finite("candidate.weight", candidate.weight)?;
        if candidate.weight <= 0.0 {
            return Err(ProcgenError::NonPositiveValue {
                field: "candidate.weight",
                value: candidate.weight,
            });
        }
    }

    let mut rng = Lcg::new(seed);
    let mut placements = Vec::with_capacity(rules.count.min(candidates.len()));
    let mut selected = BTreeSet::new();
    let mut used_groups = BTreeSet::new();
    let mut region_counts = BTreeMap::<String, usize>::new();
    let mut rejected = BTreeMap::<String, usize>::new();
    let mut attempts = 0_u32;

    while placements.len() < rules.count && attempts < max_attempts {
        let mut eligible = Vec::new();
        let mut total_weight = 0.0;
        for (index, candidate) in candidates.iter().enumerate() {
            let reason = candidate_rejection_reason(
                index,
                candidate,
                &selected,
                &placements,
                &used_groups,
                &region_counts,
                rules,
            );
            if let Some(reason) = reason {
                *rejected.entry(reason.to_string()).or_default() += 1;
                continue;
            }
            total_weight += candidate.weight;
            eligible.push((index, candidate, total_weight));
        }
        if eligible.is_empty() {
            break;
        }
        attempts += 1;
        let target = rng.next_f64() * total_weight;
        let &(index, candidate, _) = eligible
            .iter()
            .find(|(_, _, cumulative)| target < *cumulative)
            .unwrap_or_else(|| eligible.last().expect("eligible is non-empty"));
        selected.insert(index);
        if let Some(group) = &candidate.uniqueness_group {
            used_groups.insert(group.clone());
        }
        if let Some(region) = &candidate.region {
            *region_counts.entry(region.clone()).or_default() += 1;
        }
        placements.push(Placement {
            candidate_index: index + 1,
            candidate: candidate.clone(),
        });
    }

    Ok((
        placements,
        PlacementReport {
            seed,
            requested: rules.count,
            placed: selected.len(),
            attempts,
            complete: selected.len() == rules.count,
            rejected,
        },
    ))
}

fn candidate_rejection_reason(
    index: usize,
    candidate: &PlacementCandidate,
    selected: &BTreeSet<usize>,
    placements: &[Placement],
    used_groups: &BTreeSet<String>,
    region_counts: &BTreeMap<String, usize>,
    rules: &PlacementRules,
) -> Option<&'static str> {
    if selected.contains(&index) {
        return Some("already_selected");
    }
    if !rules.required_tags.is_subset(&candidate.tags) {
        return Some("missing_required_tag");
    }
    if !rules.forbidden_tags.is_disjoint(&candidate.tags) {
        return Some("forbidden_tag");
    }
    if candidate
        .uniqueness_group
        .as_ref()
        .is_some_and(|group| used_groups.contains(group))
    {
        return Some("uniqueness_group");
    }
    if let Some(region) = &candidate.region {
        let capacity = rules
            .region_capacities
            .get(region)
            .copied()
            .or(rules.default_region_capacity);
        if capacity
            .is_some_and(|capacity| region_counts.get(region).copied().unwrap_or(0) >= capacity)
        {
            return Some("region_capacity");
        }
    }
    let min_distance_squared = rules.min_distance * rules.min_distance;
    if min_distance_squared > 0.0
        && placements.iter().any(|placement| {
            placement.candidate.level == candidate.level && {
                let dx = placement.candidate.x - candidate.x;
                let dy = placement.candidate.y - candidate.y;
                dx * dx + dy * dy < min_distance_squared
            }
        })
    {
        return Some("min_distance");
    }
    None
}

/// Zero-based grid coordinate used by connectivity reports.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ConnectivityPoint {
    /// Column coordinate.
    pub x: u32,
    /// Row coordinate.
    pub y: u32,
}

/// Safe point whose radius must contain only walkable in-bounds cells.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ConnectivitySafePoint {
    /// Column coordinate.
    pub x: u32,
    /// Row coordinate.
    pub y: u32,
    /// Euclidean radius in cells.
    pub radius: f64,
}

/// Options controlling flat-grid connectivity analysis.
#[derive(Debug, Clone, PartialEq)]
pub struct ConnectivityOptions {
    /// Walkable integer cell values.
    pub walkable_values: BTreeSet<u32>,
    /// Four- or eight-neighbor adjacency.
    pub neighbors: u8,
    /// Candidate primary-component starts.
    pub starts: Vec<ConnectivityPoint>,
    /// Goals checked against the primary component.
    pub goals: Vec<ConnectivityPoint>,
    /// Safe-radius checks.
    pub safe_points: Vec<ConnectivitySafePoint>,
}

impl Default for ConnectivityOptions {
    fn default() -> Self {
        Self {
            walkable_values: BTreeSet::from([0]),
            neighbors: 4,
            starts: Vec::new(),
            goals: Vec::new(),
            safe_points: Vec::new(),
        }
    }
}

/// One connected walkable component.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConnectivityComponent {
    /// Stable component ID assigned in row-major discovery order.
    pub id: usize,
    /// Number of walkable cells in the component.
    pub size: usize,
    /// Inclusive minimum coordinate.
    pub min: ConnectivityPoint,
    /// Inclusive maximum coordinate.
    pub max: ConnectivityPoint,
}

/// One unreachable goal diagnostic.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UnreachableGoal {
    /// One-based index in the supplied goals list.
    pub index: usize,
    /// Goal coordinate.
    pub point: ConnectivityPoint,
    /// Stable reason: out_of_bounds, blocked, or different_component.
    pub reason: String,
}

/// One safe-radius violation summary.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SafeRadiusViolation {
    /// One-based index in the supplied safe-points list.
    pub index: usize,
    /// Safe-point coordinate.
    pub point: ConnectivityPoint,
    /// Number of blocked in-radius cells, or one for an out-of-bounds point.
    pub blocked_cells: usize,
}

/// Deterministic bounded connectivity diagnostics.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConnectivityReport {
    /// Components in row-major discovery order.
    pub components: Vec<ConnectivityComponent>,
    /// Primary component ID, when any walkable component exists.
    pub primary_component: Option<usize>,
    /// Goals outside the primary component.
    pub unreachable_goals: Vec<UnreachableGoal>,
    /// Walkable single-cell components.
    pub isolated_cells: Vec<ConnectivityPoint>,
    /// Non-primary component IDs.
    pub isolated_regions: Vec<usize>,
    /// Failed safe-radius checks.
    pub safe_radius_violations: Vec<SafeRadiusViolation>,
    /// Bounded stable textual diagnostics.
    pub diagnostics: Vec<String>,
}

/// Validates connectivity for a row-major integer grid without calling Lua.
pub fn validate_connectivity(
    width: u32,
    height: u32,
    cells: &[u32],
    options: &ConnectivityOptions,
    limits: &ProcgenLimits,
) -> Result<ConnectivityReport, ProcgenError> {
    let expected = checked_cell_count(width, height, limits)?;
    if cells.len() != expected {
        return Err(ProcgenError::InvalidLength {
            context: "procgen connectivity grid",
            expected,
            actual: cells.len(),
        });
    }
    if options.neighbors != 4 && options.neighbors != 8 {
        return Err(ProcgenError::InvalidSchema {
            context: "procgen connectivity",
            detail: "neighbors must be 4 or 8".to_string(),
        });
    }
    for safe in &options.safe_points {
        validate_finite("safe radius", safe.radius)?;
        if safe.radius < 0.0 {
            return Err(ProcgenError::ValueOutOfRange {
                field: "safe radius",
                min: 0.0,
                max: f64::MAX,
                value: safe.radius,
            });
        }
    }

    let is_walkable = |index: usize| options.walkable_values.contains(&cells[index]);
    let mut component_by_cell = vec![usize::MAX; expected];
    let mut components = Vec::new();
    for index in 0..expected {
        if !is_walkable(index) || component_by_cell[index] != usize::MAX {
            continue;
        }
        let id = components.len();
        let start = point_from_index(index, width);
        let mut queue = VecDeque::from([start]);
        component_by_cell[index] = id;
        let mut size = 0;
        let mut min = start;
        let mut max = start;
        while let Some(point) = queue.pop_front() {
            size += 1;
            min.x = min.x.min(point.x);
            min.y = min.y.min(point.y);
            max.x = max.x.max(point.x);
            max.y = max.y.max(point.y);
            for neighbor in connectivity_neighbors(point, width, height, options.neighbors) {
                let neighbor_index = (neighbor.y * width + neighbor.x) as usize;
                if is_walkable(neighbor_index) && component_by_cell[neighbor_index] == usize::MAX {
                    component_by_cell[neighbor_index] = id;
                    queue.push_back(neighbor);
                }
            }
        }
        components.push(ConnectivityComponent { id, size, min, max });
    }

    let primary_component = options
        .starts
        .iter()
        .find_map(|point| component_at(*point, width, height, &component_by_cell))
        .or_else(|| {
            components
                .iter()
                .max_by(|left, right| left.size.cmp(&right.size).then(right.id.cmp(&left.id)))
                .map(|component| component.id)
        });
    let unreachable_goals = options
        .goals
        .iter()
        .enumerate()
        .filter_map(|(index, point)| {
            let reason = if point.x >= width || point.y >= height {
                Some("out_of_bounds")
            } else {
                let component = component_by_cell[(point.y * width + point.x) as usize];
                if component == usize::MAX {
                    Some("blocked")
                } else if Some(component) != primary_component {
                    Some("different_component")
                } else {
                    None
                }
            }?;
            Some(UnreachableGoal {
                index: index + 1,
                point: *point,
                reason: reason.to_string(),
            })
        })
        .collect::<Vec<_>>();
    let isolated_cells = components
        .iter()
        .filter(|component| component.size == 1)
        .map(|component| component.min)
        .collect::<Vec<_>>();
    let isolated_regions = components
        .iter()
        .filter(|component| Some(component.id) != primary_component)
        .map(|component| component.id)
        .collect::<Vec<_>>();
    let safe_radius_violations = options
        .safe_points
        .iter()
        .enumerate()
        .filter_map(|(index, safe)| {
            let blocked_cells = count_safe_radius_blocks(width, height, cells, options, *safe);
            (blocked_cells > 0).then_some(SafeRadiusViolation {
                index: index + 1,
                point: ConnectivityPoint {
                    x: safe.x,
                    y: safe.y,
                },
                blocked_cells,
            })
        })
        .collect::<Vec<_>>();
    let mut diagnostics = Vec::new();
    if components.is_empty() {
        diagnostics.push("no_walkable_components".to_string());
    }
    if !unreachable_goals.is_empty() {
        diagnostics.push(format!("unreachable_goals={}", unreachable_goals.len()));
    }
    if !isolated_regions.is_empty() {
        diagnostics.push(format!("isolated_regions={}", isolated_regions.len()));
    }
    if !safe_radius_violations.is_empty() {
        diagnostics.push(format!(
            "safe_radius_violations={}",
            safe_radius_violations.len()
        ));
    }
    diagnostics.truncate(128);

    Ok(ConnectivityReport {
        components,
        primary_component,
        unreachable_goals,
        isolated_cells,
        isolated_regions,
        safe_radius_violations,
        diagnostics,
    })
}

fn point_from_index(index: usize, width: u32) -> ConnectivityPoint {
    ConnectivityPoint {
        x: index as u32 % width,
        y: index as u32 / width,
    }
}

fn component_at(
    point: ConnectivityPoint,
    width: u32,
    height: u32,
    component_by_cell: &[usize],
) -> Option<usize> {
    if point.x >= width || point.y >= height {
        return None;
    }
    let component = component_by_cell[(point.y * width + point.x) as usize];
    (component != usize::MAX).then_some(component)
}

fn connectivity_neighbors(
    point: ConnectivityPoint,
    width: u32,
    height: u32,
    count: u8,
) -> Vec<ConnectivityPoint> {
    const FOUR: [(i32, i32); 4] = [(-1, 0), (1, 0), (0, -1), (0, 1)];
    const EIGHT: [(i32, i32); 8] = [
        (-1, 0),
        (1, 0),
        (0, -1),
        (0, 1),
        (-1, -1),
        (1, -1),
        (-1, 1),
        (1, 1),
    ];
    let offsets = if count == 8 { &EIGHT[..] } else { &FOUR[..] };
    offsets
        .iter()
        .filter_map(|(dx, dy)| {
            let x = point.x as i64 + i64::from(*dx);
            let y = point.y as i64 + i64::from(*dy);
            (x >= 0 && y >= 0 && x < i64::from(width) && y < i64::from(height)).then_some(
                ConnectivityPoint {
                    x: x as u32,
                    y: y as u32,
                },
            )
        })
        .collect()
}

fn count_safe_radius_blocks(
    width: u32,
    height: u32,
    cells: &[u32],
    options: &ConnectivityOptions,
    safe: ConnectivitySafePoint,
) -> usize {
    if safe.x >= width || safe.y >= height {
        return 1;
    }
    let radius = safe.radius.ceil() as i64;
    let radius_squared = safe.radius * safe.radius;
    let mut blocked = 0;
    for y in (i64::from(safe.y) - radius)..=(i64::from(safe.y) + radius) {
        for x in (i64::from(safe.x) - radius)..=(i64::from(safe.x) + radius) {
            let dx = x - i64::from(safe.x);
            let dy = y - i64::from(safe.y);
            if (dx * dx + dy * dy) as f64 > radius_squared {
                continue;
            }
            if x < 0 || y < 0 || x >= i64::from(width) || y >= i64::from(height) {
                blocked += 1;
                continue;
            }
            let index = (y as u32 * width + x as u32) as usize;
            if !options.walkable_values.contains(&cells[index]) {
                blocked += 1;
            }
        }
    }
    blocked
}
