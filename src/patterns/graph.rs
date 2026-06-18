//! This file owns the general graph container used to model labeled nodes and weighted edges with stable integer ids.
//! `GraphNode` and `GraphEdge` define stored topology, while `Graph` keeps nodes, edges, adjacency, and id allocators.
//! Directed and undirected edge insertion stay here because reverse-edge behavior is part of graph-owned structure rules.
//! Traversal helpers such as BFS, DFS, neighbor lookup, and connectivity checks also belong with the adjacency cache.
//! Node and edge removal remain local because index repair and adjacency rebuilds are internal consistency concerns.
//! Open it when topology semantics change; tries, blackboards, and state coordinators live in sibling modules.

use std::collections::{HashMap, HashSet, VecDeque};

/// A graph node with a debug label.
///
/// # Fields
/// - `id`: Stable node identifier within the owning graph.
/// - `label`: Human-readable node label.
#[derive(Debug, Clone)]
pub struct GraphNode {
    /// Unique identifier within the owning `Graph`.
    pub id: u32,
    /// Human-readable debug label.
    pub label: String,
}
/// A directed edge connecting two nodes with a weight and label.
///
/// # Fields
/// - `id`: Stable edge identifier.
/// - `from`: Source node id.
/// - `to`: Destination node id.
/// - `weight`: Traversal cost or score.
/// - `label`: Human-readable edge label.
#[derive(Debug, Clone)]
pub struct GraphEdge {
    /// Unique edge identifier.
    pub id: u32,
    /// Source node id.
    pub from: u32,
    /// Destination node id.
    pub to: u32,
    /// Traversal cost.
    pub weight: f64,
    /// Human-readable debug label.
    pub label: String,
}
/// Adjacency-list graph supporting directed and undirected modes.
///
/// # Fields
/// - `undirected`: Whether reverse edges are inserted automatically.
#[derive(Debug, Clone)]
pub struct Graph {
    /// All nodes.
    nodes: Vec<GraphNode>,
    /// All edges; undirected graphs store both directions.
    edges: Vec<GraphEdge>,
    /// Node id to vector index lookup.
    node_index: HashMap<u32, usize>,
    /// Cached outgoing neighbor ids keyed by source node id.
    adjacency: HashMap<u32, Vec<u32>>,
    /// Next node id to assign.
    next_node: u32,
    /// Next edge id to assign.
    next_edge: u32,
    /// When true, `add_edge` inserts a reverse edge automatically.
    pub undirected: bool,
}
/// Construction and traversal methods for `Graph`.
impl Graph {
    /// Create an empty directed graph.
    pub fn new() -> Self {
        Self {
            nodes: Vec::new(),
            edges: Vec::new(),
            node_index: HashMap::new(),
            adjacency: HashMap::new(),
            next_node: 1,
            next_edge: 1,
            undirected: false,
        }
    }
    /// Create an empty undirected graph.
    pub fn new_undirected() -> Self {
        Self {
            undirected: true,
            ..Self::new()
        }
    }
    /// Add a node with `label`; return the new node id.
    pub fn add_node(&mut self, label: &str) -> u32 {
        let id = self.next_node;
        self.next_node += 1;
        self.nodes.push(GraphNode {
            id,
            label: label.to_string(),
        });
        self.node_index.insert(id, self.nodes.len() - 1);
        self.adjacency.entry(id).or_default();
        id
    }
    /// Remove node `id` and all edges incident to it; return true when it existed.
    pub fn remove_node(&mut self, id: u32) -> bool {
        if let Some(pos) = self.node_index.remove(&id) {
            self.nodes.swap_remove(pos);
            if let Some(node) = self.nodes.get(pos) {
                self.node_index.insert(node.id, pos);
            }
            self.edges.retain(|e| e.from != id && e.to != id);
            self.rebuild_adjacency();
            true
        } else {
            false
        }
    }
    /// Return a reference to the node with `id`, or `None`.
    pub fn get_node(&self, id: u32) -> Option<&GraphNode> {
        self.node_index
            .get(&id)
            .and_then(|&idx| self.nodes.get(idx))
    }
    /// Return true when a node with `id` exists.
    pub fn has_node(&self, id: u32) -> bool {
        self.node_index.contains_key(&id)
    }
    /// Return all node ids. This function is part of the public API.
    pub fn node_ids(&self) -> Vec<u32> {
        self.nodes.iter().map(|n| n.id).collect()
    }
    /// Return the total number of nodes.
    pub fn node_count(&self) -> usize {
        self.nodes.len()
    }
    /// Add an edge from `from` to `to` with `weight` and `label`; return edge id, or `0` if either node is missing.
    pub fn add_edge(&mut self, from: u32, to: u32, weight: f64, label: &str) -> u32 {
        if !self.has_node(from) || !self.has_node(to) {
            return 0;
        }
        let id = self.next_edge;
        self.next_edge += 1;
        self.edges.push(GraphEdge {
            id,
            from,
            to,
            weight,
            label: label.to_string(),
        });
        if self.undirected && from != to {
            self.edges.push(GraphEdge {
                id,
                from: to,
                to: from,
                weight,
                label: label.to_string(),
            });
        }
        self.adjacency.entry(from).or_default().push(to);
        if self.undirected && from != to {
            self.adjacency.entry(to).or_default().push(from);
        }
        id
    }
    /// Remove all edges with `id`; return true when at least one was removed.
    pub fn remove_edge(&mut self, id: u32) -> bool {
        let before = self.edges.len();
        self.edges.retain(|e| e.id != id);
        let removed = self.edges.len() < before;
        if removed {
            self.rebuild_adjacency();
        }
        removed
    }
    /// Return a reference to the first edge with `id`, or `None`.
    pub fn get_edge(&self, id: u32) -> Option<&GraphEdge> {
        self.edges.iter().find(|e| e.id == id)
    }
    /// Return all edges originating from `from`.
    pub fn edges_from(&self, from: u32) -> Vec<&GraphEdge> {
        self.edges.iter().filter(|e| e.from == from).collect()
    }
    /// Return all edges pointing to `to`.
    pub fn edges_to(&self, to: u32) -> Vec<&GraphEdge> {
        self.edges.iter().filter(|e| e.to == to).collect()
    }
    /// Return the total number of stored edge entries.
    pub fn edge_count(&self) -> usize {
        self.edges.len()
    }
    /// Return the ids of all direct outgoing neighbours of `node_id`.
    pub fn neighbors(&self, node_id: u32) -> Vec<u32> {
        self.adjacency.get(&node_id).cloned().unwrap_or_default()
    }
    /// Return node ids reachable from `start` in BFS order.
    pub fn bfs(&self, start: u32) -> Vec<u32> {
        let mut visited = HashSet::new();
        let mut queue = VecDeque::new();
        let mut order = Vec::new();
        if !self.has_node(start) {
            return order;
        }
        queue.push_back(start);
        visited.insert(start);
        while let Some(cur) = queue.pop_front() {
            order.push(cur);
            if let Some(neighbors) = self.adjacency.get(&cur) {
                for &nb in neighbors {
                    if visited.insert(nb) {
                        queue.push_back(nb);
                    }
                }
            }
        }
        order
    }
    /// Return node ids reachable from `start` in DFS order.
    pub fn dfs(&self, start: u32) -> Vec<u32> {
        let mut visited = HashSet::new();
        let mut order = Vec::new();
        self.dfs_inner(start, &mut visited, &mut order);
        order
    }
    /// Recursive DFS helper accumulating visited nodes into `order`.
    fn dfs_inner(&self, cur: u32, visited: &mut HashSet<u32>, order: &mut Vec<u32>) {
        if !visited.insert(cur) {
            return;
        }
        order.push(cur);
        if let Some(neighbors) = self.adjacency.get(&cur) {
            for &nb in neighbors {
                self.dfs_inner(nb, visited, order);
            }
        }
    }
    /// Rebuilds cached outgoing adjacency lists from `edges`.
    fn rebuild_adjacency(&mut self) {
        self.adjacency.clear();
        for node in &self.nodes {
            self.adjacency.entry(node.id).or_default();
        }
        for edge in &self.edges {
            self.adjacency.entry(edge.from).or_default().push(edge.to);
        }
    }
    /// Return true when `to` is reachable from `from`.
    pub fn is_connected(&self, from: u32, to: u32) -> bool {
        if !self.has_node(from) || !self.has_node(to) {
            return false;
        }
        let mut visited = HashSet::new();
        let mut queue = VecDeque::from([from]);
        visited.insert(from);
        while let Some(cur) = queue.pop_front() {
            if cur == to {
                return true;
            }
            if let Some(neighbors) = self.adjacency.get(&cur) {
                for &nb in neighbors {
                    if visited.insert(nb) {
                        queue.push_back(nb);
                    }
                }
            }
        }
        false
    }
    /// Remove all nodes and edges. This function is part of the public API.
    pub fn clear(&mut self) {
        self.nodes.clear();
        self.edges.clear();
        self.node_index.clear();
        self.adjacency.clear();
    }
}
/// Delegates to `Self::new()`.
impl Default for Graph {
    fn default() -> Self {
        Self::new()
    }
}
