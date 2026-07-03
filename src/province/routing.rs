//! Owns the province routing implementation for the province subsystem and keeps related runtime rules local here.
//! Keeps province data, render helpers, and map-facing transforms so helpers stay close to invariants this file updates.
//! Defines how province routing data is validated, transformed, or stored before neighboring systems consume it.
//! Separates province routing behavior from Lua bindings, tests, and sibling owners so integration stays readable.

use crate::pathfind::graph_path::{
    build_province_adjacency_map, find_province_route_bfs, find_province_route_dijkstra,
    province_connected_components, provinces_connected,
};
use std::collections::HashMap;

/// Build an adjacency map from undirected `(a, b)` province-id pairs.
pub fn build_adjacency_map(pairs: &[(u32, u32)]) -> HashMap<u32, Vec<u32>> {
    build_province_adjacency_map(pairs)
}

/// Find the shortest path by edge count (BFS).
pub fn find_route_bfs(adjacency: &HashMap<u32, Vec<u32>>, from: u32, to: u32) -> Option<Vec<u32>> {
    find_province_route_bfs(adjacency, from, to)
}

/// Find the lowest-cost route using Dijkstra and a per-edge cost callback.
pub fn find_route_dijkstra(
    adjacency: &HashMap<u32, Vec<u32>>,
    from: u32,
    to: u32,
    edge_cost: &dyn Fn(u32, u32) -> f64,
) -> Option<Vec<u32>> {
    find_province_route_dijkstra(adjacency, from, to, edge_cost)
}

/// Returns all connected components as sorted arrays of province ids.
pub fn connected_components(adjacency: &HashMap<u32, Vec<u32>>, nodes: &[u32]) -> Vec<Vec<u32>> {
    province_connected_components(adjacency, nodes)
}

/// True when `to` is reachable from `from`.
pub fn is_connected(adjacency: &HashMap<u32, Vec<u32>>, from: u32, to: u32) -> bool {
    provinces_connected(adjacency, from, to)
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
