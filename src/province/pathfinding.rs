//! Province-level pathfinding on the adjacency graph using A* with centroid heuristic.
//!
//! Provides [`find_path`] (A*) and [`reachable`] (Dijkstra flood fill) as
//! methods on [`ProvinceMap`], plus a configurable [`ProvinceCostFn`] for
//! property-based and per-province cost overrides.

use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap, HashSet};

use super::core::ProvinceMap;
use super::properties::ProvinceProperties;

/// A path through the province adjacency graph.
#[derive(Debug, Clone)]
pub struct ProvincePath {
    /// Ordered list of province IDs from start to goal (inclusive).
    pub provinces: Vec<u32>,
    /// Accumulated traversal cost.
    pub total_cost: f64,
}

/// Configurable cost function for province pathfinding.
///
/// Costs are determined by looking up province properties. For example, if
/// `property_costs` contains `{"terrain": {"Mountain": 3.0, "Sea": 1.5}}`,
/// then a province whose `terrain` property is `"Mountain"` costs 3.0 to enter.
///
/// If no matching property cost is found, `default_cost` is used.
/// Per-province overrides in `province_costs` are added on top.
/// Edge tag costs in `tag_costs` are added when crossing a tagged edge.
#[derive(Debug, Clone)]
pub struct ProvinceCostFn {
    /// Per-property cost lookups: `property_key -> {value_string -> cost}`.
    pub property_costs: HashMap<String, HashMap<String, f64>>,
    /// Per-province cost overrides (e.g., fortification penalty). Added to base cost.
    pub province_costs: HashMap<u32, f64>,
    /// Cost to add when crossing an edge with a specific tag (e.g. "river" -> 0.5).
    pub tag_costs: HashMap<String, f64>,
    /// Default cost when no property cost matches (default: 1.0).
    pub default_cost: f64,
}

impl Default for ProvinceCostFn {
    fn default() -> Self {
        Self {
            property_costs: HashMap::new(),
            province_costs: HashMap::new(),
            tag_costs: HashMap::new(),
            default_cost: 1.0,
        }
    }
}

impl ProvinceCostFn {
    /// Compute the movement cost to enter a province.
    ///
    /// Looks up each key in `property_costs` against the province's properties.
    /// The first matching key+value determines the base cost. If no match, uses
    /// `default_cost`. Province-specific override is added on top.
    ///
    /// Returns `None` if the computed cost is infinite (impassable).
    fn cost_for(
        &self,
        province_id: u32,
        properties: Option<&ProvinceProperties>,
    ) -> Option<f64> {
        let mut base = self.default_cost;

        // Check property-based costs
        if let Some(props) = properties {
            for (key, value_costs) in &self.property_costs {
                if let Some(val) = props.get_string(key) {
                    if let Some(&cost) = value_costs.get(&val) {
                        base = cost;
                        break;
                    }
                }
            }
        }

        if base.is_infinite() {
            return None;
        }

        let extra = self.province_costs.get(&province_id).copied().unwrap_or(0.0);
        let total = base + extra;

        if total.is_infinite() {
            None
        } else {
            Some(total)
        }
    }

    /// Compute extra cost for crossing a specific edge based on its tags.
    fn edge_cost(&self, edge_tags: &HashSet<String>) -> f64 {
        let mut extra = 0.0;
        for (tag, &cost) in &self.tag_costs {
            if edge_tags.contains(tag) {
                extra += cost;
            }
        }
        extra
    }
}

/// A* open-set node, ordered by f_score (lowest first via reverse Ord).
struct AStarNode {
    province_id: u32,
    f_score: f64,
}

impl PartialEq for AStarNode {
    fn eq(&self, other: &Self) -> bool {
        self.f_score == other.f_score
    }
}

impl Eq for AStarNode {}

impl PartialOrd for AStarNode {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for AStarNode {
    fn cmp(&self, other: &Self) -> Ordering {
        // Reverse ordering for min-heap behaviour in BinaryHeap
        other
            .f_score
            .partial_cmp(&self.f_score)
            .unwrap_or(Ordering::Equal)
    }
}

impl ProvinceMap {
    /// Find a path between two provinces using A* with centroid distance heuristic.
    ///
    /// Returns `None` if no path exists under the given cost function.
    pub fn find_path(
        &self,
        from: u32,
        to: u32,
        cost_fn: &ProvinceCostFn,
        properties: &HashMap<u32, ProvinceProperties>,
    ) -> Option<ProvincePath> {
        if from == to {
            return Some(ProvincePath {
                provinces: vec![from],
                total_cost: 0.0,
            });
        }

        // Verify both provinces exist
        self.get_province(from)?;
        self.get_province(to)?;

        let goal_centroid = self.get_province(to)?.centroid;

        let mut open = BinaryHeap::new();
        let mut g_score: HashMap<u32, f64> = HashMap::new();
        let mut came_from: HashMap<u32, u32> = HashMap::new();
        let mut closed: HashSet<u32> = HashSet::new();

        g_score.insert(from, 0.0);
        let h = self.distance(from, to);
        open.push(AStarNode {
            province_id: from,
            f_score: h,
        });

        while let Some(current) = open.pop() {
            let current_id = current.province_id;

            if current_id == to {
                // Reconstruct path
                let mut path = vec![to];
                let mut node = to;
                while let Some(&prev) = came_from.get(&node) {
                    path.push(prev);
                    node = prev;
                }
                path.reverse();
                return Some(ProvincePath {
                    provinces: path,
                    total_cost: g_score[&to],
                });
            }

            if !closed.insert(current_id) {
                continue;
            }

            let current_g = g_score[&current_id];

            for neighbor_id in self.get_neighbors(current_id) {
                if closed.contains(&neighbor_id) {
                    continue;
                }

                let step_cost = match cost_fn.cost_for(neighbor_id, properties.get(&neighbor_id)) {
                    Some(c) => c,
                    None => continue, // impassable
                };

                // Add edge tag costs
                let edge_extra = self
                    .get_adjacency(current_id, neighbor_id)
                    .map(|e| cost_fn.edge_cost(&e.tags))
                    .unwrap_or(0.0);

                let tentative_g = current_g + step_cost + edge_extra;

                if tentative_g < *g_score.get(&neighbor_id).unwrap_or(&f64::INFINITY) {
                    g_score.insert(neighbor_id, tentative_g);
                    came_from.insert(neighbor_id, current_id);

                    let neighbor = match self.get_province(neighbor_id) {
                        Some(p) => p,
                        None => continue,
                    };
                    let dx = neighbor.centroid.x - goal_centroid.x;
                    let dy = neighbor.centroid.y - goal_centroid.y;
                    let h = ((dx * dx + dy * dy) as f64).sqrt();

                    open.push(AStarNode {
                        province_id: neighbor_id,
                        f_score: tentative_g + h,
                    });
                }
            }
        }

        None // No path found
    }

    /// Find all provinces reachable from `from` within a cost budget.
    ///
    /// Uses Dijkstra flood fill on the adjacency graph. Returns a list of all
    /// province IDs (including `from`) that can be reached without exceeding
    /// `max_cost`.
    pub fn reachable(
        &self,
        from: u32,
        max_cost: f64,
        cost_fn: &ProvinceCostFn,
        properties: &HashMap<u32, ProvinceProperties>,
    ) -> Vec<u32> {
        let mut dist: HashMap<u32, f64> = HashMap::new();
        let mut heap = BinaryHeap::new();
        let mut result = Vec::new();

        dist.insert(from, 0.0);
        heap.push(AStarNode {
            province_id: from,
            f_score: 0.0, // using f_score as distance for Dijkstra
        });

        while let Some(current) = heap.pop() {
            let current_id = current.province_id;
            let current_dist = *dist.get(&current_id).unwrap_or(&f64::INFINITY);

            if current_dist > max_cost {
                continue;
            }

            result.push(current_id);

            for neighbor_id in self.get_neighbors(current_id) {
                let step_cost =
                    match cost_fn.cost_for(neighbor_id, properties.get(&neighbor_id)) {
                        Some(c) => c,
                        None => continue,
                    };

                let edge_extra = self
                    .get_adjacency(current_id, neighbor_id)
                    .map(|e| cost_fn.edge_cost(&e.tags))
                    .unwrap_or(0.0);

                let new_dist = current_dist + step_cost + edge_extra;
                if new_dist <= max_cost
                    && new_dist < *dist.get(&neighbor_id).unwrap_or(&f64::INFINITY)
                {
                    dist.insert(neighbor_id, new_dist);
                    heap.push(AStarNode {
                        province_id: neighbor_id,
                        f_score: new_dist,
                    });
                }
            }
        }

        result.sort_unstable();
        result.dedup();
        result
    }

    /// Euclidean distance between two province centroids.
    ///
    /// Returns `f64::INFINITY` if either province does not exist.
    pub fn distance(&self, a: u32, b: u32) -> f64 {
        let pa = match self.get_province(a) {
            Some(p) => p,
            None => return f64::INFINITY,
        };
        let pb = match self.get_province(b) {
            Some(p) => p,
            None => return f64::INFINITY,
        };

        let dx = (pa.centroid.x - pb.centroid.x) as f64;
        let dy = (pa.centroid.y - pb.centroid.y) as f64;
        (dx * dx + dy * dy).sqrt()
    }
}
