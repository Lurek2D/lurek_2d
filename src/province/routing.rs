//! Province-routing helper layer for asking strategic map questions about reachability, shortest paths, and isolated clusters across province adjacencies.
//! The file offers both unweighted and weighted traversal styles so games can move from simple neighbor hops to cost-aware movement without swapping data models.
//! Connectivity and component helpers make the map graph useful for analysis, not just for single-route requests.
//! These routines stay separate from the core registry so graph algorithms do not crowd the state store itself.
//! Functionally this file delivers travel and connectivity reasoning over the province adjacency network.

use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap, HashSet, VecDeque};

#[derive(Copy, Clone, Debug)]
struct QueueNode {
    cost: f64,
    id: u32,
}

impl PartialEq for QueueNode {
    fn eq(&self, other: &Self) -> bool {
        self.id == other.id && self.cost.to_bits() == other.cost.to_bits()
    }
}

impl Eq for QueueNode {}

impl PartialOrd for QueueNode {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for QueueNode {
    fn cmp(&self, other: &Self) -> Ordering {
        // Reverse ordering so BinaryHeap behaves as min-heap by cost.
        other
            .cost
            .total_cmp(&self.cost)
            .then_with(|| self.id.cmp(&other.id))
    }
}

/// Build an adjacency map from undirected `(a, b)` province-id pairs.
pub fn build_adjacency_map(pairs: &[(u32, u32)]) -> HashMap<u32, Vec<u32>> {
    let mut out: HashMap<u32, Vec<u32>> = HashMap::new();
    for &(a, b) in pairs {
        if a == 0 || b == 0 || a == b {
            continue;
        }
        out.entry(a).or_default().push(b);
        out.entry(b).or_default().push(a);
    }
    for neighbors in out.values_mut() {
        neighbors.sort_unstable();
        neighbors.dedup();
    }
    out
}

/// Find the shortest path by edge count (BFS).
pub fn find_route_bfs(adjacency: &HashMap<u32, Vec<u32>>, from: u32, to: u32) -> Option<Vec<u32>> {
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
                        return Some(reconstruct_path(&prev, from, to));
                    }
                    queue.push_back(next);
                }
            }
        }
    }

    None
}

/// Find the lowest-cost route using Dijkstra and a per-edge cost callback.
pub fn find_route_dijkstra(
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
    heap.push(QueueNode {
        cost: 0.0,
        id: from,
    });

    while let Some(QueueNode { cost, id }) = heap.pop() {
        if id == to {
            return Some(reconstruct_path(&prev, from, to));
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
                    heap.push(QueueNode {
                        cost: new_cost,
                        id: next,
                    });
                }
            }
        }
    }

    None
}

/// Returns all connected components as sorted arrays of province ids.
pub fn connected_components(adjacency: &HashMap<u32, Vec<u32>>, nodes: &[u32]) -> Vec<Vec<u32>> {
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

/// True when `to` is reachable from `from`.
pub fn is_connected(adjacency: &HashMap<u32, Vec<u32>>, from: u32, to: u32) -> bool {
    find_route_bfs(adjacency, from, to).is_some()
}

/// Returns province ids that have no adjacent province with the same owner value.
pub fn find_isolated_provinces(
    adjacency: &HashMap<u32, Vec<u32>>,
    owner_by_id: &HashMap<u32, String>,
) -> Vec<u32> {
    let mut out = Vec::new();

    for (&id, owner) in owner_by_id {
        if owner.is_empty() {
            continue;
        }

        let mut has_same_owner_neighbor = false;
        if let Some(neighbors) = adjacency.get(&id) {
            for n in neighbors {
                if owner_by_id.get(n).is_some_and(|v| v == owner) {
                    has_same_owner_neighbor = true;
                    break;
                }
            }
        }

        if !has_same_owner_neighbor {
            out.push(id);
        }
    }

    out.sort_unstable();
    out
}

/// Sum numeric values for ids owned by `owner_val`.
pub fn total_numeric_attr_for_owner(
    owner_by_id: &HashMap<u32, String>,
    value_by_id: &HashMap<u32, f64>,
    owner_val: &str,
) -> f64 {
    let mut sum = 0.0;
    for (&id, owner) in owner_by_id {
        if owner == owner_val {
            sum += value_by_id.get(&id).copied().unwrap_or(0.0);
        }
    }
    sum
}

fn reconstruct_path(prev: &HashMap<u32, u32>, from: u32, to: u32) -> Vec<u32> {
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
