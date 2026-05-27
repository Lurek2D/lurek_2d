//! INTERNAL ONLY: Rust-only tests for `lurek2d::patterns::graph::Graph`.
//!
//! Public graph behavior reachable through `lurek.graph.*` is covered in Lua tests.
//! These Rust-only checks cover internal adjacency, BFS/DFS, and node/edge invariants.

use lurek2d::patterns::graph::Graph;

#[test]
fn new_graph_is_empty() {
    let g = Graph::new();
    assert_eq!(g.node_count(), 0);
    assert_eq!(g.edge_count(), 0);
}

#[test]
fn add_node_increments_count() {
    let mut g = Graph::new();
    let id = g.add_node("factory");
    assert_eq!(g.node_count(), 1);
    assert!(g.has_node(id));
}

#[test]
fn add_edge_increments_count() {
    let mut g = Graph::new();
    let a = g.add_node("a");
    let b = g.add_node("b");
    g.add_edge(a, b, 1.0, "link");
    assert_eq!(g.edge_count(), 1);
}

#[test]
fn undirected_graph_adds_reverse_edge() {
    let mut g = Graph::new_undirected();
    let a = g.add_node("a");
    let b = g.add_node("b");
    g.add_edge(a, b, 1.0, "link");
    assert!(!g.edges_to(a).is_empty(), "undirected should have reverse edge");
}

#[test]
fn remove_node_decrements_count() {
    let mut g = Graph::new();
    let id = g.add_node("sink");
    assert!(g.remove_node(id));
    assert_eq!(g.node_count(), 0);
    assert!(!g.has_node(id));
}

#[test]
fn bfs_visits_all_reachable_nodes() {
    let mut g = Graph::new();
    let a = g.add_node("a");
    let b = g.add_node("b");
    let c = g.add_node("c");
    g.add_edge(a, b, 1.0, "");
    g.add_edge(b, c, 1.0, "");
    let visited = g.bfs(a);
    assert!(visited.contains(&a));
    assert!(visited.contains(&b));
    assert!(visited.contains(&c));
}

#[test]
fn dfs_visits_all_reachable_nodes() {
    let mut g = Graph::new();
    let a = g.add_node("a");
    let b = g.add_node("b");
    let c = g.add_node("c");
    g.add_edge(a, b, 1.0, "");
    g.add_edge(b, c, 1.0, "");
    let visited = g.dfs(a);
    assert!(visited.contains(&a));
    assert!(visited.contains(&b));
    assert!(visited.contains(&c));
}

#[test]
fn neighbors_returns_directly_connected_nodes() {
    let mut g = Graph::new();
    let a = g.add_node("a");
    let b = g.add_node("b");
    let c = g.add_node("c");
    g.add_edge(a, b, 1.0, "");
    g.add_edge(a, c, 1.0, "");
    let nbrs = g.neighbors(a);
    assert!(nbrs.contains(&b));
    assert!(nbrs.contains(&c));
    assert!(!nbrs.contains(&a));
}
