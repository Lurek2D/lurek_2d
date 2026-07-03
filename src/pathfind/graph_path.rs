//! Owns the pathfind graph path implementation for the pathfind subsystem and keeps related runtime rules local here.
//! Keeps path graphs, routes, and traversal-facing helpers ownership so helpers stay close to invariants this file updates.
//! Defines how pathfind graph path data is validated, transformed, or stored before neighboring systems consume it.
//! Separates pathfind graph path behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where pathfind code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing pathfind graph path defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near pathfind graph path state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping pathfind graph path calculations at their owning subsystem boundary.

use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap, HashSet, VecDeque};
/// Result of a province-level pathfinding query.
#[derive(Debug, Clone)]
pub struct ProvincePath {
    /// Ordered sequence of province ids from start to destination, inclusive.
    pub provinces: Vec<u32>,
    /// Summed move cost along the chosen path.
    pub total_cost: f64,
}
/// Per-province and per-edge-tag move-cost configuration passed to path queries.
#[derive(Debug, Clone, Default)]
pub struct ProvinceCostFn {
    /// Base cost applied to every traversable province.
    pub default_cost: f64,
    /// Per-province cost additions keyed by province id.
    pub province_costs: HashMap<u32, f64>,
    /// Edge surcharges applied when a crossing edge carries the given tag.
    pub tag_costs: HashMap<String, f64>,
    /// Province ids that cannot be entered; paths will not pass through them.
    pub blocked: HashSet<u32>,
}

/// Generic graph path result alias kept at the pathfinding ownership boundary.
pub type GraphPath = ProvincePath;

/// Generic graph cost-function alias kept at the pathfinding ownership boundary.
pub type GraphCostFn = ProvinceCostFn;

/// Construction and cost helpers for `ProvinceCostFn`.
impl ProvinceCostFn {
    /// Create a default cost function with `default_cost = 1.0` and no blocked provinces.
    pub fn new() -> Self {
        Self {
            default_cost: 1.0,
            ..Default::default()
        }
    }
    /// Return the total cost to enter `province_id`, or `None` when blocked or infinite.
    fn cost_for(&self, province_id: u32) -> Option<f64> {
        if self.blocked.contains(&province_id) {
            return None;
        }
        let base = self.default_cost;
        let extra = self
            .province_costs
            .get(&province_id)
            .copied()
            .unwrap_or(0.0);
        let total = base + extra;
        if total.is_infinite() {
            None
        } else {
            Some(total)
        }
    }
    /// Sum tag surcharges for an edge whose tag set intersects `edge_tags`.
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
/// Internal priority-queue node for province-level A\* and Dijkstra.
struct AStarNode {
    /// Province id held by this node.
    province_id: u32,
    /// f-score (g + h for A\*, g for Dijkstra).
    f_score: f64,
}
/// Equality by f-score.
impl PartialEq for AStarNode {
    fn eq(&self, other: &Self) -> bool {
        self.f_score == other.f_score
    }
}
/// Marker trait required by `Ord`; delegates equality to `PartialEq`.
impl Eq for AStarNode {}

/// Delegates to `Ord`.
impl PartialOrd for AStarNode {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
/// Reverse ordering so `BinaryHeap` is a min-heap on f-score.
impl Ord for AStarNode {
    fn cmp(&self, other: &Self) -> Ordering {
        other
            .f_score
            .partial_cmp(&self.f_score)
            .unwrap_or(Ordering::Equal)
    }
}

/// Build a graph adjacency map from positive integer node-id pairs.
pub fn build_graph_adjacency_map(pairs: &[(u32, u32)], directed: bool) -> HashMap<u32, Vec<u32>> {
    let mut out: HashMap<u32, Vec<u32>> = HashMap::new();
    for &(a, b) in pairs {
        if a == 0 || b == 0 || a == b {
            continue;
        }
        out.entry(a).or_default().push(b);
        if !directed {
            out.entry(b).or_default().push(a);
        }
    }
    for neighbors in out.values_mut() {
        neighbors.sort_unstable();
        neighbors.dedup();
    }
    out
}

/// Build an undirected province adjacency map from `(a, b)` id pairs.
pub fn build_province_adjacency_map(pairs: &[(u32, u32)]) -> HashMap<u32, Vec<u32>> {
    build_graph_adjacency_map(pairs, false)
}

/// Find a graph route with the fewest hops by breadth-first search.
pub fn find_graph_route_bfs(
    adjacency: &HashMap<u32, Vec<u32>>,
    from: u32,
    to: u32,
) -> Option<Vec<u32>> {
    if from == 0 || to == 0 {
        return None;
    }
    if from == to {
        return Some(vec![from]);
    }

    let mut queue = VecDeque::new();
    let mut visited: HashSet<u32> = HashSet::new();
    let mut prev: HashMap<u32, u32> = HashMap::new();

    queue.push_back(from);
    visited.insert(from);

    while let Some(cur) = queue.pop_front() {
        if let Some(neighbors) = adjacency.get(&cur) {
            for &next in neighbors {
                if visited.insert(next) {
                    prev.insert(next, cur);
                    if next == to {
                        return Some(reconstruct_province_path(&prev, from, to));
                    }
                    queue.push_back(next);
                }
            }
        }
    }

    None
}

/// Find a province route with the fewest graph hops by breadth-first search.
pub fn find_province_route_bfs(
    adjacency: &HashMap<u32, Vec<u32>>,
    from: u32,
    to: u32,
) -> Option<Vec<u32>> {
    find_graph_route_bfs(adjacency, from, to)
}

/// Find the lowest-cost graph route using Dijkstra and a caller-provided edge cost.
pub fn find_graph_route_dijkstra(
    adjacency: &HashMap<u32, Vec<u32>>,
    from: u32,
    to: u32,
    edge_cost: &dyn Fn(u32, u32) -> f64,
) -> Option<Vec<u32>> {
    if from == 0 || to == 0 {
        return None;
    }
    if from == to {
        return Some(vec![from]);
    }

    let mut dist: HashMap<u32, f64> = HashMap::new();
    let mut prev: HashMap<u32, u32> = HashMap::new();
    let mut heap = BinaryHeap::new();

    dist.insert(from, 0.0);
    heap.push(AStarNode {
        province_id: from,
        f_score: 0.0,
    });

    while let Some(AStarNode {
        province_id: id,
        f_score: cost,
    }) = heap.pop()
    {
        if id == to {
            return Some(reconstruct_province_path(&prev, from, to));
        }
        if let Some(best) = dist.get(&id) {
            if cost > *best {
                continue;
            }
        }

        if let Some(neighbors) = adjacency.get(&id) {
            for &next in neighbors {
                let w = edge_cost(id, next);
                if !w.is_finite() || w <= 0.0 {
                    continue;
                }
                let new_cost = cost + w;
                let old = *dist.get(&next).unwrap_or(&f64::INFINITY);
                if new_cost < old {
                    dist.insert(next, new_cost);
                    prev.insert(next, id);
                    heap.push(AStarNode {
                        province_id: next,
                        f_score: new_cost,
                    });
                }
            }
        }
    }

    None
}

/// Find the lowest-cost province route using Dijkstra and a caller-provided edge cost.
pub fn find_province_route_dijkstra(
    adjacency: &HashMap<u32, Vec<u32>>,
    from: u32,
    to: u32,
    edge_cost: &dyn Fn(u32, u32) -> f64,
) -> Option<Vec<u32>> {
    find_graph_route_dijkstra(adjacency, from, to, edge_cost)
}

/// Return sorted connected components for the supplied graph node ids.
pub fn graph_connected_components(
    adjacency: &HashMap<u32, Vec<u32>>,
    nodes: &[u32],
) -> Vec<Vec<u32>> {
    let mut out: Vec<Vec<u32>> = Vec::new();
    let mut visited: HashSet<u32> = HashSet::new();

    for &start in nodes {
        if start == 0 || !visited.insert(start) {
            continue;
        }

        let mut queue = VecDeque::new();
        let mut comp = Vec::new();
        queue.push_back(start);

        while let Some(cur) = queue.pop_front() {
            comp.push(cur);
            if let Some(neighbors) = adjacency.get(&cur) {
                for &next in neighbors {
                    if visited.insert(next) {
                        queue.push_back(next);
                    }
                }
            }
        }

        comp.sort_unstable();
        out.push(comp);
    }

    out.sort_by_key(|c| c.first().copied().unwrap_or(u32::MAX));
    out
}

/// Return sorted connected components for the supplied province ids.
pub fn province_connected_components(
    adjacency: &HashMap<u32, Vec<u32>>,
    nodes: &[u32],
) -> Vec<Vec<u32>> {
    graph_connected_components(adjacency, nodes)
}

/// Return true when two graph node ids are connected by adjacency.
pub fn graph_connected(adjacency: &HashMap<u32, Vec<u32>>, from: u32, to: u32) -> bool {
    find_graph_route_bfs(adjacency, from, to).is_some()
}

/// Return true when two province ids are connected by province adjacency.
pub fn provinces_connected(adjacency: &HashMap<u32, Vec<u32>>, from: u32, to: u32) -> bool {
    graph_connected(adjacency, from, to)
}

/// Run A* across graph adjacency; return the cheapest path and its cost, or `None` when unreachable.
pub fn find_graph_path(
    neighbors: &HashMap<u32, Vec<u32>>,
    centroids: &HashMap<u32, (f32, f32)>,
    edge_tags: &HashMap<(u32, u32), HashSet<String>>,
    from: u32,
    to: u32,
    cost_fn: &GraphCostFn,
) -> Option<GraphPath> {
    if from == to {
        return Some(ProvincePath {
            provinces: vec![from],
            total_cost: 0.0,
        });
    }
    let goal_centroid = centroids.get(&to)?;
    centroids.get(&from)?;
    let mut open = BinaryHeap::new();
    let mut g_score: HashMap<u32, f64> = HashMap::new();
    let mut came_from: HashMap<u32, u32> = HashMap::new();
    let mut closed: HashSet<u32> = HashSet::new();
    g_score.insert(from, 0.0);
    let h = centroid_distance(centroids.get(&from)?, goal_centroid);
    open.push(AStarNode {
        province_id: from,
        f_score: h,
    });
    while let Some(current) = open.pop() {
        let current_id = current.province_id;
        if current_id == to {
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
        let empty_neighbors = Vec::new();
        let neighbor_ids = neighbors.get(&current_id).unwrap_or(&empty_neighbors);
        for &neighbor_id in neighbor_ids {
            if closed.contains(&neighbor_id) {
                continue;
            }
            let step_cost = match cost_fn.cost_for(neighbor_id) {
                Some(c) => c,
                None => continue,
            };
            let edge_key = if current_id <= neighbor_id {
                (current_id, neighbor_id)
            } else {
                (neighbor_id, current_id)
            };
            let edge_extra = edge_tags
                .get(&edge_key)
                .map(|tags| cost_fn.edge_cost(tags))
                .unwrap_or(0.0);
            let tentative_g = current_g + step_cost + edge_extra;
            if tentative_g < *g_score.get(&neighbor_id).unwrap_or(&f64::INFINITY) {
                g_score.insert(neighbor_id, tentative_g);
                came_from.insert(neighbor_id, current_id);
                let nc = match centroids.get(&neighbor_id) {
                    Some(c) => c,
                    None => continue,
                };
                let h = centroid_distance(nc, goal_centroid);
                open.push(AStarNode {
                    province_id: neighbor_id,
                    f_score: tentative_g + h,
                });
            }
        }
    }
    None
}
/// Run A* across province adjacency; return the cheapest path and its cost, or `None` when unreachable.
pub fn find_province_path(
    neighbors: &HashMap<u32, Vec<u32>>,
    centroids: &HashMap<u32, (f32, f32)>,
    edge_tags: &HashMap<(u32, u32), HashSet<String>>,
    from: u32,
    to: u32,
    cost_fn: &ProvinceCostFn,
) -> Option<ProvincePath> {
    find_graph_path(neighbors, centroids, edge_tags, from, to, cost_fn)
}

/// Return all graph nodes reachable from `start` within `max_cost` as a node-id cost map.
pub fn graph_reachable(
    neighbors: &HashMap<u32, Vec<u32>>,
    edge_tags: &HashMap<(u32, u32), HashSet<String>>,
    start: u32,
    max_cost: f64,
    cost_fn: &GraphCostFn,
) -> HashMap<u32, f64> {
    let mut dist: HashMap<u32, f64> = HashMap::new();
    let mut heap = BinaryHeap::new();
    let mut visited: HashSet<u32> = HashSet::new();
    dist.insert(start, 0.0);
    heap.push(AStarNode {
        province_id: start,
        f_score: 0.0,
    });
    while let Some(current) = heap.pop() {
        let current_id = current.province_id;
        let current_dist = *dist.get(&current_id).unwrap_or(&f64::INFINITY);
        if current_dist > max_cost || !visited.insert(current_id) {
            continue;
        }
        let empty_neighbors = Vec::new();
        let neighbor_ids = neighbors.get(&current_id).unwrap_or(&empty_neighbors);
        for &neighbor_id in neighbor_ids {
            if visited.contains(&neighbor_id) {
                continue;
            }
            let step_cost = match cost_fn.cost_for(neighbor_id) {
                Some(c) => c,
                None => continue,
            };
            let edge_key = if current_id <= neighbor_id {
                (current_id, neighbor_id)
            } else {
                (neighbor_id, current_id)
            };
            let edge_extra = edge_tags
                .get(&edge_key)
                .map(|tags| cost_fn.edge_cost(tags))
                .unwrap_or(0.0);
            let new_dist = current_dist + step_cost + edge_extra;
            if new_dist <= max_cost && new_dist < *dist.get(&neighbor_id).unwrap_or(&f64::INFINITY)
            {
                dist.insert(neighbor_id, new_dist);
                heap.push(AStarNode {
                    province_id: neighbor_id,
                    f_score: new_dist,
                });
            }
        }
    }
    dist.into_iter()
        .filter(|(id, _)| visited.contains(id))
        .collect()
}

/// Return all provinces reachable from `start` within `max_cost` as a province-id cost map.
pub fn province_reachable(
    neighbors: &HashMap<u32, Vec<u32>>,
    edge_tags: &HashMap<(u32, u32), HashSet<String>>,
    start: u32,
    max_cost: f64,
    cost_fn: &ProvinceCostFn,
) -> HashMap<u32, f64> {
    graph_reachable(neighbors, edge_tags, start, max_cost, cost_fn)
}

/// Return Euclidean distance between two centroid points.
fn centroid_distance(a: &(f32, f32), b: &(f32, f32)) -> f64 {
    let dx = (a.0 - b.0) as f64;
    let dy = (a.1 - b.1) as f64;
    (dx * dx + dy * dy).sqrt()
}

fn reconstruct_province_path(prev: &HashMap<u32, u32>, from: u32, to: u32) -> Vec<u32> {
    let mut out = vec![to];
    let mut cur = to;
    while cur != from {
        if let Some(&p) = prev.get(&cur) {
            cur = p;
            out.push(cur);
        } else {
            break;
        }
    }
    out.reverse();
    out
}
