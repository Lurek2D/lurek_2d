//! This file owns `Graph`, the flownet container storing nodes, edges, items, id counters, and adjacency indexes.
//! It provides the authoritative CRUD path for nodes, edges, and items, including cascading cleanup and id assignment.
//! Item placement helpers live here because inventories, queues, and transit buffers must stay mutually consistent.
//! Send validation also lives here so edge activity, cooldown, filters, and current item position are checked in one place.
//! Outgoing and incoming edge indexes are maintained here to keep pathfinding, analytics, and simulation queries cheap.
//! `subgraph` cloning lives here because it remaps nodes, edges, items, and container ownership into a coherent snapshot.
//! Aggregate counts from `GraphStats` are computed here because only this file sees the full graph-wide ownership picture.
//! `draw_to_image` provides a quick preview boundary, but the richer renderer integration lives in sibling `render.rs`.
//! Serialization and deserialization live here because persistence rebuilds nodes, edges, items, and references together.
//! Legacy and versioned snapshot loaders are validated here so broken references fail before other flownet code runs.
//! This file does not advance time; `simulation.rs` owns per-tick behavior and `supply_demand.rs` owns fulfillment policy.
//! Open it when graph ownership or persistence changes; node contracts and routing algorithms are implemented elsewhere.

use super::edge::Edge;
use super::item::{GraphItem, ItemPosition};
use super::node::{Node, OverflowPolicy};
use crate::log_msg;
use crate::runtime::log_messages::{GC01, GC02, GC03, GC04};
use std::collections::{BTreeMap, HashMap, HashSet};

const FLOWNET_SERIALIZE_VERSION: u64 = 2;

fn resolve_topology_node(
    node: &TopologyNodeRef,
    external_nodes: &BTreeMap<String, u64>,
) -> Result<u64, String> {
    match node {
        TopologyNodeRef::Existing(id) => Ok(*id),
        TopologyNodeRef::External(key) => external_nodes
            .get(key)
            .copied()
            .ok_or_else(|| format!("unknown external node key '{key}'")),
    }
}
/// Aggregate counts derived from the current graph state.
#[derive(Debug, Clone)]
pub struct GraphStats {
    /// Total node count.
    pub nodes: usize,
    /// Total edge count.
    pub edges: usize,
    /// Total item count.
    pub items: usize,
    /// Number of active nodes.
    pub active_nodes: usize,
    /// Number of active edges.
    pub active_edges: usize,
    /// Number of items currently in transit.
    pub items_in_transit: usize,
    /// Number of items currently on nodes.
    pub items_on_nodes: usize,
    /// Sum of node demand quantities.
    pub total_demand: i32,
    /// Sum of node supply quantities.
    pub total_supply: i32,
    /// Number of queued items across all nodes.
    pub queued_items: usize,
}

/// Aggregate inventory counts for Lua-side economy and UI orchestration.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GraphInventorySummary {
    /// Total stored item records.
    pub total: usize,
    /// Items whose alive flag is set.
    pub alive: usize,
    /// Items currently owned by node inventories or queues.
    pub at_nodes: usize,
    /// Items currently traveling on edges.
    pub in_transit: usize,
    /// Items with no current container.
    pub unplaced: usize,
    /// Items specifically waiting in node queues.
    pub queued: usize,
    /// Alive item counts keyed by item type in deterministic order.
    pub by_type: BTreeMap<String, usize>,
}

/// Result of one bounded explicit multi-input recipe execution.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RecipeExecution {
    /// Number of complete recipe runs performed.
    pub runs: u32,
    /// Consumed item ids in deterministic type and inventory order.
    pub consumed: Vec<u64>,
    /// Produced item ids in deterministic output order.
    pub produced: Vec<u64>,
}
/// Main graph container with nodes, edges, items, and adjacency indexes.
#[derive(Clone)]
pub struct Graph {
    /// Stored nodes by id.
    pub nodes: HashMap<u64, Node>,
    /// Stored edges by id.
    pub edges: HashMap<u64, Edge>,
    /// Stored items by id.
    pub items: HashMap<u64, GraphItem>,
    /// Outgoing edge ids keyed by source node id.
    outgoing_index: HashMap<u64, Vec<u64>>,
    /// Incoming edge ids keyed by destination node id.
    incoming_index: HashMap<u64, Vec<u64>>,
    /// Next node id to assign.
    next_node_id: u64,
    /// Next edge id to assign.
    next_edge_id: u64,
    /// Next item id to assign.
    next_item_id: u64,
    /// Monotonic topology version used by prepared graph edits.
    topology_version: u64,
}

/// Node target used by prepared topology edits.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TopologyNodeRef {
    /// Existing numeric graph node id.
    Existing(u64),
    /// External key assigned by an earlier add-node edit in the same batch.
    External(String),
}

/// One topology-only edit for a prepared graph batch.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum TopologyEdit {
    /// Add a node and optionally publish its id under an external key.
    AddNode {
        external_key: Option<String>,
        node_type: String,
        capacity: i32,
    },
    /// Remove an existing or same-batch node.
    RemoveNode { node: TopologyNodeRef },
    /// Add an edge between existing or same-batch nodes.
    AddEdge {
        from: TopologyNodeRef,
        to: TopologyNodeRef,
        edge_type: Option<String>,
    },
    /// Remove an existing edge id.
    RemoveEdge { edge_id: u64 },
}

/// Fully validated graph topology replacement awaiting a version-checked commit.
#[derive(Clone)]
pub struct PreparedTopologyBatch {
    base_version: u64,
    staged: Box<Graph>,
    external_nodes: BTreeMap<String, u64>,
    created_nodes: Vec<u64>,
    created_edges: Vec<u64>,
    operation_count: usize,
    changed_count: usize,
}

impl PreparedTopologyBatch {
    /// Return the topology version observed during preparation.
    pub fn base_version(&self) -> u64 {
        self.base_version
    }

    /// Return the number of submitted operations.
    pub fn operation_count(&self) -> usize {
        self.operation_count
    }

    /// Return the number of topology mutations that changed state.
    pub fn changed_count(&self) -> usize {
        self.changed_count
    }

    /// Return external node-key mappings in deterministic key order.
    pub fn external_nodes(&self) -> &BTreeMap<String, u64> {
        &self.external_nodes
    }

    /// Return node ids created by this batch in operation order.
    pub fn created_nodes(&self) -> &[u64] {
        &self.created_nodes
    }

    /// Return edge ids created by this batch in operation order.
    pub fn created_edges(&self) -> &[u64] {
        &self.created_edges
    }
}
/// Create an empty graph with fresh id counters.
impl Default for Graph {
    fn default() -> Self {
        Self::new()
    }
}
/// Core operations for building, querying, and mutating the graph.
impl Graph {
    /// Create an empty graph with fresh id counters.
    pub fn new() -> Self {
        Self {
            nodes: HashMap::new(),
            edges: HashMap::new(),
            items: HashMap::new(),
            outgoing_index: HashMap::new(),
            incoming_index: HashMap::new(),
            next_node_id: 1,
            next_edge_id: 1,
            next_item_id: 1,
            topology_version: 1,
        }
    }

    /// Return the monotonic topology version.
    pub fn version(&self) -> u64 {
        self.topology_version
    }

    /// Validate and stage topology edits without mutating this graph.
    pub fn prepare_topology_batch(
        &self,
        edits: &[TopologyEdit],
    ) -> Result<PreparedTopologyBatch, String> {
        const MAX_TOPOLOGY_BATCH_OPS: usize = 100_000;
        if edits.len() > MAX_TOPOLOGY_BATCH_OPS {
            return Err(format!(
                "topology batch has {} operations, exceeding limit {MAX_TOPOLOGY_BATCH_OPS}",
                edits.len()
            ));
        }
        let mut staged = self.clone();
        let mut external_nodes = BTreeMap::new();
        let mut created_nodes = Vec::new();
        let mut created_edges = Vec::new();
        let mut changed_count = 0usize;
        for (index, edit) in edits.iter().enumerate() {
            match edit {
                TopologyEdit::AddNode {
                    external_key,
                    node_type,
                    capacity,
                } => {
                    if node_type.trim().is_empty() {
                        return Err(format!(
                            "topology operation {} has empty node type",
                            index + 1
                        ));
                    }
                    if let Some(key) = external_key {
                        if key.trim().is_empty() {
                            return Err(format!(
                                "topology operation {} has empty external key",
                                index + 1
                            ));
                        }
                        if external_nodes.contains_key(key) {
                            return Err(format!(
                                "topology operation {} duplicates external key '{key}'",
                                index + 1
                            ));
                        }
                    }
                    let id = staged.add_node(node_type, *capacity);
                    created_nodes.push(id);
                    if let Some(key) = external_key {
                        external_nodes.insert(key.clone(), id);
                    }
                    changed_count += 1;
                }
                TopologyEdit::RemoveNode { node } => {
                    let id = resolve_topology_node(node, &external_nodes)
                        .map_err(|error| format!("topology operation {}: {error}", index + 1))?;
                    if !staged.remove_node(id) {
                        return Err(format!(
                            "topology operation {} targets missing node {id}",
                            index + 1
                        ));
                    }
                    changed_count += 1;
                }
                TopologyEdit::AddEdge {
                    from,
                    to,
                    edge_type,
                } => {
                    let from = resolve_topology_node(from, &external_nodes).map_err(|error| {
                        format!("topology operation {} from: {error}", index + 1)
                    })?;
                    let to = resolve_topology_node(to, &external_nodes)
                        .map_err(|error| format!("topology operation {} to: {error}", index + 1))?;
                    let edge_id = staged.add_edge(from, to, edge_type.as_deref())?;
                    created_edges.push(edge_id);
                    changed_count += 1;
                }
                TopologyEdit::RemoveEdge { edge_id } => {
                    if !staged.remove_edge(*edge_id) {
                        return Err(format!(
                            "topology operation {} targets missing edge {edge_id}",
                            index + 1
                        ));
                    }
                    changed_count += 1;
                }
            }
        }
        staged.topology_version = if changed_count == 0 {
            self.topology_version
        } else {
            self.topology_version
                .checked_add(1)
                .ok_or_else(|| "graph topology version overflow".to_string())?
        };
        Ok(PreparedTopologyBatch {
            base_version: self.topology_version,
            staged: Box::new(staged),
            external_nodes,
            created_nodes,
            created_edges,
            operation_count: edits.len(),
            changed_count,
        })
    }

    /// Commit a prepared topology replacement when its base version still matches.
    pub fn commit_topology_batch(
        &mut self,
        batch: PreparedTopologyBatch,
    ) -> Result<BTreeMap<String, u64>, String> {
        if self.topology_version != batch.base_version {
            return Err(format!(
                "graph topology version conflict: prepared for {}, current version is {}",
                batch.base_version, self.topology_version
            ));
        }
        let external_nodes = batch.external_nodes;
        *self = *batch.staged;
        Ok(external_nodes)
    }
    /// Return an immutable node reference or a descriptive error.
    fn require_node(&self, node_id: u64) -> Result<&Node, String> {
        self.nodes
            .get(&node_id)
            .ok_or_else(|| format!("node {node_id} does not exist"))
    }
    /// Return a mutable node reference or a descriptive error.
    fn require_node_mut(&mut self, node_id: u64) -> Result<&mut Node, String> {
        self.nodes
            .get_mut(&node_id)
            .ok_or_else(|| format!("node {node_id} does not exist"))
    }
    /// Return an immutable edge reference or a descriptive error.
    fn require_edge(&self, edge_id: u64) -> Result<&Edge, String> {
        self.edges
            .get(&edge_id)
            .ok_or_else(|| format!("edge {edge_id} does not exist"))
    }
    /// Return a mutable edge reference or a descriptive error.
    fn require_edge_mut(&mut self, edge_id: u64) -> Result<&mut Edge, String> {
        self.edges
            .get_mut(&edge_id)
            .ok_or_else(|| format!("edge {edge_id} does not exist"))
    }
    /// Return an immutable item reference or a descriptive error.
    fn require_item(&self, item_id: u64) -> Result<&GraphItem, String> {
        self.items
            .get(&item_id)
            .ok_or_else(|| format!("item {item_id} does not exist"))
    }
    /// Return a mutable item reference or a descriptive error.
    fn require_item_mut(&mut self, item_id: u64) -> Result<&mut GraphItem, String> {
        self.items
            .get_mut(&item_id)
            .ok_or_else(|| format!("item {item_id} does not exist"))
    }
    /// Return true when the node inventory currently contains the item id.
    fn node_inventory_contains(&self, node_id: u64, item_id: u64) -> bool {
        self.nodes
            .get(&node_id)
            .is_some_and(|node| node.items.contains(&item_id))
    }
    /// Return true when the node queue currently contains the item id.
    fn node_queue_contains(&self, node_id: u64, item_id: u64) -> bool {
        self.nodes
            .get(&node_id)
            .is_some_and(|node| node.queue.contains(&item_id))
    }
    /// Remove an item id from the container referenced by its current item position.
    fn detach_item_from_position(
        &mut self,
        item_id: u64,
        position: &ItemPosition,
    ) -> Result<(), String> {
        match position {
            ItemPosition::AtNode(node_id) => {
                let node = self.require_node_mut(*node_id)?;
                node.items.retain(|&id| id != item_id);
                node.queue.retain(|&id| id != item_id);
            }
            ItemPosition::InTransit { edge_id, .. } => {
                let edge = self.require_edge_mut(*edge_id)?;
                edge.items_in_transit.retain(|&id| id != item_id);
            }
            ItemPosition::Unplaced => {}
        }
        Ok(())
    }
    /// Move an item to the unplaced state while removing any old container membership.
    pub(crate) fn move_item_to_unplaced(&mut self, item_id: u64) -> Result<(), String> {
        let position = self.require_item(item_id)?.position.clone();
        self.detach_item_from_position(item_id, &position)?;
        self.require_item_mut(item_id)?.position = ItemPosition::Unplaced;
        Ok(())
    }
    /// Move an item into a node inventory and make that inventory its only owner.
    pub(crate) fn move_item_to_node_inventory(
        &mut self,
        item_id: u64,
        node_id: u64,
    ) -> Result<(), String> {
        self.require_node(node_id)?;
        let position = self.require_item(item_id)?.position.clone();
        self.detach_item_from_position(item_id, &position)?;
        let node = self.require_node_mut(node_id)?;
        if !node.items.contains(&item_id) {
            node.items.push(item_id);
        }
        self.require_item_mut(item_id)?.position = ItemPosition::AtNode(node_id);
        Ok(())
    }
    /// Move an item into a node queue and make that queue its only owner.
    pub(crate) fn move_item_to_node_queue(
        &mut self,
        item_id: u64,
        node_id: u64,
    ) -> Result<bool, String> {
        let can_enqueue = {
            let node = self.require_node(node_id)?;
            node.queue_capacity < 0 || node.queue.len() < node.queue_capacity as usize
        };
        if !can_enqueue {
            return Ok(false);
        }
        let position = self.require_item(item_id)?.position.clone();
        self.detach_item_from_position(item_id, &position)?;
        let node = self.require_node_mut(node_id)?;
        if !node.queue.contains(&item_id) {
            node.queue.push_back(item_id);
        }
        self.require_item_mut(item_id)?.position = ItemPosition::AtNode(node_id);
        Ok(true)
    }
    /// Move an item onto an edge transit buffer and reset its progress.
    pub(crate) fn move_item_to_edge_transit(
        &mut self,
        item_id: u64,
        edge_id: u64,
        progress: f64,
    ) -> Result<(), String> {
        self.require_edge(edge_id)?;
        let position = self.require_item(item_id)?.position.clone();
        self.detach_item_from_position(item_id, &position)?;
        let edge = self.require_edge_mut(edge_id)?;
        if !edge.items_in_transit.contains(&item_id) {
            edge.items_in_transit.push(item_id);
        }
        edge.cooldown_timer = edge.cooldown;
        self.require_item_mut(item_id)?.position = ItemPosition::InTransit { edge_id, progress };
        Ok(())
    }
    /// Kill an item and remove it from any container that currently owns it.
    pub(crate) fn kill_item_and_detach(&mut self, item_id: u64) -> Result<(), String> {
        self.move_item_to_unplaced(item_id)?;
        self.require_item_mut(item_id)?.kill();
        Ok(())
    }
    /// Validate that an item can be sent from the edge source node inventory.
    fn ensure_item_ready_for_edge(&self, item_id: u64, edge: &Edge) -> Result<(), String> {
        let item = self.require_item(item_id)?;
        if !item.alive {
            return Err(format!("item {item_id} is not alive"));
        }
        match item.position {
            ItemPosition::AtNode(node_id) if node_id == edge.from_node => {
                if self.node_inventory_contains(node_id, item_id) {
                    Ok(())
                } else if self.node_queue_contains(node_id, item_id) {
                    Err(format!(
                        "item {item_id} is queued on node {node_id} and cannot be sent"
                    ))
                } else {
                    Err(format!(
                        "item {item_id} position references node {node_id}, but that node does not own it"
                    ))
                }
            }
            ItemPosition::AtNode(node_id) => Err(format!(
                "item {item_id} is on node {node_id}, but edge {edge_id} starts at node {}",
                edge.from_node,
                edge_id = edge.id.raw()
            )),
            ItemPosition::InTransit { edge_id, .. } => Err(format!(
                "item {item_id} is already in transit on edge {edge_id}"
            )),
            ItemPosition::Unplaced => Err(format!("item {item_id} is unplaced")),
        }
    }
    /// Add an edge id to the outgoing and incoming indexes.
    fn index_edge(&mut self, edge_id: u64, from_node: u64, to_node: u64) {
        self.outgoing_index
            .entry(from_node)
            .or_default()
            .push(edge_id);
        self.incoming_index
            .entry(to_node)
            .or_default()
            .push(edge_id);
    }
    /// Remove an edge id from the outgoing and incoming indexes.
    fn unindex_edge(&mut self, edge_id: u64, from_node: u64, to_node: u64) {
        if let Some(ids) = self.outgoing_index.get_mut(&from_node) {
            ids.retain(|&id| id != edge_id);
        }
        if let Some(ids) = self.incoming_index.get_mut(&to_node) {
            ids.retain(|&id| id != edge_id);
        }
    }
    /// Return the indexed outgoing edge ids for a node.
    pub(crate) fn outgoing_edge_ids_slice(&self, node_id: u64) -> &[u64] {
        self.outgoing_index
            .get(&node_id)
            .map(Vec::as_slice)
            .unwrap_or(&[])
    }
    /// Return the indexed incoming edge ids for a node.
    pub(crate) fn incoming_edge_ids_slice(&self, node_id: u64) -> &[u64] {
        self.incoming_index
            .get(&node_id)
            .map(Vec::as_slice)
            .unwrap_or(&[])
    }
    /// Add a node and return its assigned id.
    pub fn add_node(&mut self, node_type: &str, capacity: i32) -> u64 {
        let id = self.next_node_id;
        self.next_node_id += 1;
        log_msg!(debug, GC01, "id={} type={}", id, node_type);
        self.nodes.insert(id, Node::new(id, node_type, capacity));
        self.outgoing_index.entry(id).or_default();
        self.incoming_index.entry(id).or_default();
        self.bump_topology_version();
        id
    }
    /// Remove a node and all connected edges, returning true when it existed.
    pub fn remove_node(&mut self, node_id: u64) -> bool {
        let base_version = self.topology_version;
        let Some(node) = self.nodes.get(&node_id) else {
            return false;
        };
        let mut edge_ids = self.get_outgoing_edges(node_id);
        edge_ids.extend(self.get_incoming_edges(node_id));
        edge_ids.sort_unstable();
        edge_ids.dedup();
        let mut item_ids = node.items.clone();
        item_ids.extend(node.queue.iter().copied());
        item_ids.sort_unstable();
        item_ids.dedup();
        for item_id in item_ids {
            let _ = self.move_item_to_unplaced(item_id);
        }
        for eid in edge_ids {
            self.remove_edge(eid);
        }
        self.nodes.remove(&node_id);
        self.outgoing_index.remove(&node_id);
        self.incoming_index.remove(&node_id);
        log_msg!(debug, GC02, "{}", node_id);
        self.topology_version = base_version.saturating_add(1);
        true
    }
    /// Return true when the node id exists.
    pub fn has_node(&self, node_id: u64) -> bool {
        self.nodes.contains_key(&node_id)
    }
    /// Return all node ids in arbitrary order.
    pub fn get_node_ids(&self) -> Vec<u64> {
        let mut ids: Vec<u64> = self.nodes.keys().copied().collect();
        ids.sort_unstable();
        ids
    }
    /// Return the number of nodes. This function is part of the public API.
    pub fn get_node_count(&self) -> usize {
        self.nodes.len()
    }
    /// Add an edge and return its assigned id or an error when either endpoint is missing.
    pub fn add_edge(&mut self, from: u64, to: u64, edge_type: Option<&str>) -> Result<u64, String> {
        if !self.nodes.contains_key(&from) {
            return Err(format!("source node {from} does not exist"));
        }
        if !self.nodes.contains_key(&to) {
            return Err(format!("destination node {to} does not exist"));
        }
        let id = self.next_edge_id;
        self.next_edge_id += 1;
        let e = Edge::new(id, from, to, edge_type.unwrap_or("default"));
        self.edges.insert(id, e);
        self.index_edge(id, from, to);
        self.bump_topology_version();
        log_msg!(debug, GC03, "{} -> {} (id={})", from, to, id);
        Ok(id)
    }
    /// Add an edge without validating that source/target nodes exist.
    /// Use for hot paths where node existence is already guaranteed by construction.
    pub fn add_edge_unchecked(&mut self, from: u64, to: u64, edge_type: Option<&str>) -> u64 {
        let id = self.next_edge_id;
        self.next_edge_id += 1;
        let e = Edge::new(id, from, to, edge_type.unwrap_or("default"));
        self.edges.insert(id, e);
        self.index_edge(id, from, to);
        self.bump_topology_version();
        id
    }
    /// Remove an edge and detach any items in transit, returning true when it existed.
    pub fn remove_edge(&mut self, edge_id: u64) -> bool {
        let Some(transit_items) = self
            .edges
            .get(&edge_id)
            .map(|edge| edge.items_in_transit.clone())
        else {
            return false;
        };
        for item_id in transit_items {
            let _ = self.move_item_to_unplaced(item_id);
        }
        if let Some(edge) = self.edges.remove(&edge_id) {
            self.unindex_edge(edge_id, edge.from_node, edge.to_node);
            log_msg!(debug, GC04, "{}", edge_id);
            self.bump_topology_version();
            true
        } else {
            false
        }
    }
    /// Return true when the edge id exists.
    pub fn has_edge(&self, edge_id: u64) -> bool {
        self.edges.contains_key(&edge_id)
    }
    /// Return all edge ids in arbitrary order.
    pub fn get_edge_ids(&self) -> Vec<u64> {
        let mut ids: Vec<u64> = self.edges.keys().copied().collect();
        ids.sort_unstable();
        ids
    }
    /// Return the number of edges. This function is part of the public API.
    pub fn get_edge_count(&self) -> usize {
        self.edges.len()
    }
    /// Return the first outgoing edge id that connects the supplied nodes.
    pub fn get_edge_between(&self, from: u64, to: u64) -> Option<u64> {
        self.outgoing_edge_ids_slice(from)
            .iter()
            .find_map(|edge_id| {
                self.edges.get(edge_id).and_then(|edge| {
                    if edge.to_node == to {
                        Some(edge.id.raw())
                    } else {
                        None
                    }
                })
            })
    }
    /// Build a new graph containing only the selected nodes and connected data.
    pub fn subgraph(&self, node_ids: &[u64]) -> Self {
        let requested: HashSet<u64> = node_ids
            .iter()
            .copied()
            .filter(|id| self.nodes.contains_key(id))
            .collect();
        let mut sorted_nodes: Vec<u64> = requested.iter().copied().collect();
        sorted_nodes.sort_unstable();
        let mut sub = Graph::new();
        let mut node_map: HashMap<u64, u64> = HashMap::new();
        for old_id in sorted_nodes {
            let old = &self.nodes[&old_id];
            let new_id = sub.add_node(&old.node_type, old.capacity);
            let new_node = sub.nodes.get_mut(&new_id).expect("new node must exist");
            new_node.active = old.active;
            new_node.overflow_policy = old.overflow_policy.clone();
            new_node.flow_mode = old.flow_mode.clone();
            new_node.push_rate = old.push_rate;
            new_node.pull_rate = old.pull_rate;
            new_node.push_filter = old.push_filter.clone();
            new_node.pull_filter = old.pull_filter.clone();
            new_node.process_time = old.process_time;
            new_node.queue_enabled = old.queue_enabled;
            new_node.queue_capacity = old.queue_capacity;
            new_node.conversions = old.conversions.clone();
            new_node.demands = old.demands.clone();
            new_node.supplies = old.supplies.clone();
            new_node.tags = old.tags.clone();
            new_node.capacity_reservations = old.capacity_reservations.clone();
            node_map.insert(old_id, new_id);
        }
        let mut edge_map: HashMap<u64, u64> = HashMap::new();
        let mut edge_ids: Vec<u64> = self.edges.keys().copied().collect();
        edge_ids.sort_unstable();
        for old_edge_id in edge_ids {
            let old_edge = &self.edges[&old_edge_id];
            let Some(&new_from) = node_map.get(&old_edge.from_node) else {
                continue;
            };
            let Some(&new_to) = node_map.get(&old_edge.to_node) else {
                continue;
            };
            let new_edge_id = sub
                .add_edge(new_from, new_to, Some(&old_edge.edge_type))
                .expect("subgraph edge endpoints should be valid");
            let new_edge = sub
                .edges
                .get_mut(&new_edge_id)
                .expect("new edge must exist");
            new_edge.capacity = old_edge.capacity;
            new_edge.throughput = old_edge.throughput;
            new_edge.travel_time = old_edge.travel_time;
            new_edge.weight = old_edge.weight;
            new_edge.speed_modifier = old_edge.speed_modifier;
            new_edge.cooldown = old_edge.cooldown;
            new_edge.cooldown_timer = old_edge.cooldown_timer;
            new_edge.bidirectional = old_edge.bidirectional;
            new_edge.active = old_edge.active;
            new_edge.allowed_types = old_edge.allowed_types.clone();
            new_edge.capacity_reservations = old_edge.capacity_reservations.clone();
            edge_map.insert(old_edge_id, new_edge_id);
        }
        let mut item_map: HashMap<u64, u64> = HashMap::new();
        let mut item_ids: Vec<u64> = self.items.keys().copied().collect();
        item_ids.sort_unstable();
        for old_item_id in item_ids {
            let old_item = &self.items[&old_item_id];
            let new_position = match old_item.position {
                ItemPosition::AtNode(old_node_id) => {
                    let Some(&new_node_id) = node_map.get(&old_node_id) else {
                        continue;
                    };
                    ItemPosition::AtNode(new_node_id)
                }
                ItemPosition::InTransit {
                    edge_id: old_edge_id,
                    progress,
                } => {
                    let Some(&new_edge_id) = edge_map.get(&old_edge_id) else {
                        continue;
                    };
                    ItemPosition::InTransit {
                        edge_id: new_edge_id,
                        progress,
                    }
                }
                ItemPosition::Unplaced => ItemPosition::Unplaced,
            };
            let new_item_id = sub.create_item(&old_item.item_type, old_item.decay_time);
            let new_item = sub
                .items
                .get_mut(&new_item_id)
                .expect("new item must exist");
            new_item.remaining_life = old_item.remaining_life;
            new_item.alive = old_item.alive;
            new_item.priority = old_item.priority;
            new_item.position = new_position;
            item_map.insert(old_item_id, new_item_id);
        }
        for (&old_node_id, &new_node_id) in &node_map {
            if let Some(old_node) = self.nodes.get(&old_node_id) {
                if let Some(new_node) = sub.nodes.get_mut(&new_node_id) {
                    new_node.items = old_node
                        .items
                        .iter()
                        .filter_map(|old_item_id| item_map.get(old_item_id).copied())
                        .collect();
                    new_node.queue = old_node
                        .queue
                        .iter()
                        .filter_map(|old_item_id| item_map.get(old_item_id).copied())
                        .collect();
                }
            }
        }
        for (&old_edge_id, &new_edge_id) in &edge_map {
            if let Some(old_edge) = self.edges.get(&old_edge_id) {
                if let Some(new_edge) = sub.edges.get_mut(&new_edge_id) {
                    new_edge.items_in_transit = old_edge
                        .items_in_transit
                        .iter()
                        .filter_map(|old_item_id| item_map.get(old_item_id).copied())
                        .collect();
                }
            }
        }
        sub
    }
    /// Create an item and return its assigned id.
    pub fn create_item(&mut self, item_type: &str, decay_time: f64) -> u64 {
        let id = self.next_item_id;
        self.next_item_id += 1;
        self.items
            .insert(id, GraphItem::new(id, item_type, decay_time));
        id
    }
    /// Add an item to a node and return whether the placement succeeded.
    pub fn add_item_to_node(&mut self, item_id: u64, node_id: u64) -> Result<bool, String> {
        let item = self.require_item(item_id)?;
        if !item.alive {
            return Err(format!("item {item_id} is not alive"));
        }
        if matches!(item.position, ItemPosition::AtNode(id) if id == node_id)
            && (self.node_inventory_contains(node_id, item_id)
                || self.node_queue_contains(node_id, item_id))
        {
            return Ok(true);
        }
        let node = self.require_node(node_id)?;
        if node.is_full() {
            match node.overflow_policy {
                OverflowPolicy::Reject => return Ok(false),
                OverflowPolicy::Destroy => {
                    self.kill_item_and_detach(item_id)?;
                    return Ok(false);
                }
                OverflowPolicy::Queue => {
                    return self.move_item_to_node_queue(item_id, node_id);
                }
            }
        }
        self.move_item_to_node_inventory(item_id, node_id)?;
        Ok(true)
    }
    /// Remove an item from the graph and all node or edge containers.
    pub fn remove_item(&mut self, item_id: u64) -> bool {
        let Some(position) = self.items.get(&item_id).map(|item| item.position.clone()) else {
            return false;
        };
        let _ = self.detach_item_from_position(item_id, &position);
        self.items.remove(&item_id);
        true
    }
    /// Return true when the item id exists.
    pub fn has_item(&self, item_id: u64) -> bool {
        self.items.contains_key(&item_id)
    }
    /// Return all item ids in arbitrary order.
    pub fn get_item_ids(&self) -> Vec<u64> {
        let mut ids: Vec<u64> = self.items.keys().copied().collect();
        ids.sort_unstable();
        ids
    }
    /// Return the number of items. This function is part of the public API.
    pub fn get_item_count(&self) -> usize {
        self.items.len()
    }

    fn bump_topology_version(&mut self) {
        self.topology_version = self.topology_version.saturating_add(1);
    }
    /// Send an item onto an edge and return whether the transfer succeeded.
    pub fn send_item(&mut self, item_id: u64, edge_id: u64) -> Result<bool, String> {
        let item_type = self.require_item(item_id)?.item_type.clone();
        let edge = self.require_edge(edge_id)?;
        self.ensure_item_ready_for_edge(item_id, edge)?;
        if !edge.active {
            return Ok(false);
        }
        if edge.is_on_cooldown() {
            return Ok(false);
        }
        if !edge.is_item_type_allowed(&item_type) {
            return Ok(false);
        }
        if edge.is_transit_full() {
            return Ok(false);
        }
        self.move_item_to_edge_transit(item_id, edge_id, 0.0)?;
        Ok(true)
    }
    /// Return aggregate counts derived from the current graph state.
    pub fn get_stats(&self) -> GraphStats {
        let mut stats = GraphStats {
            nodes: self.nodes.len(),
            edges: self.edges.len(),
            items: self.items.len(),
            active_nodes: 0,
            active_edges: 0,
            items_in_transit: 0,
            items_on_nodes: 0,
            total_demand: 0,
            total_supply: 0,
            queued_items: 0,
        };
        for node in self.nodes.values() {
            if node.active {
                stats.active_nodes += 1;
            }
            stats.items_on_nodes += node.items.len();
            stats.queued_items += node.queue.len();
            for d in &node.demands {
                stats.total_demand += d.quantity;
            }
            for s in &node.supplies {
                stats.total_supply += s.quantity;
            }
        }
        for edge in self.edges.values() {
            if edge.active {
                stats.active_edges += 1;
            }
            stats.items_in_transit += edge.items_in_transit.len();
        }
        stats
    }

    /// Return graph-wide item ownership and type counts without crossing into game policy.
    pub fn summarize_inventory(&self) -> GraphInventorySummary {
        let queued_ids: HashSet<u64> = self
            .nodes
            .values()
            .flat_map(|node| node.queue.iter().copied())
            .collect();
        let mut summary = GraphInventorySummary {
            total: self.items.len(),
            alive: 0,
            at_nodes: 0,
            in_transit: 0,
            unplaced: 0,
            queued: queued_ids.len(),
            by_type: BTreeMap::new(),
        };
        for item in self.items.values() {
            if item.alive {
                summary.alive += 1;
                *summary.by_type.entry(item.item_type.clone()).or_insert(0) += 1;
            }
            match item.position {
                ItemPosition::AtNode(_) => summary.at_nodes += 1,
                ItemPosition::InTransit { .. } => summary.in_transit += 1,
                ItemPosition::Unplaced => summary.unplaced += 1,
            }
        }
        summary
    }

    /// Execute a named node recipe up to `max_runs` times as one bounded Rust operation.
    ///
    /// Timing and scheduling remain Lua-owned: this method only performs inventory
    /// matching, capacity checks, consumption, and production.
    pub fn run_recipe(
        &mut self,
        node_id: u64,
        name: &str,
        max_runs: u32,
    ) -> Result<RecipeExecution, String> {
        const MAX_RECIPE_ITEM_OPS: u64 = 100_000;
        if max_runs == 0 {
            return Ok(RecipeExecution {
                runs: 0,
                consumed: Vec::new(),
                produced: Vec::new(),
            });
        }
        let node = self.require_node(node_id)?;
        let recipe = node
            .get_recipe(name)
            .cloned()
            .ok_or_else(|| format!("recipe '{name}' does not exist on node {node_id}"))?;

        let mut available = BTreeMap::<String, u32>::new();
        for item_id in &node.items {
            if let Some(item) = self.items.get(item_id) {
                if item.alive {
                    *available.entry(item.item_type.clone()).or_insert(0) += 1;
                }
            }
        }
        let mut runs = max_runs;
        for input in &recipe.inputs {
            runs = runs.min(available.get(&input.item_type).copied().unwrap_or(0) / input.count);
        }
        let input_count: u64 = recipe
            .inputs
            .iter()
            .map(|stack| u64::from(stack.count))
            .sum();
        let output_count: u64 = recipe
            .outputs
            .iter()
            .map(|stack| u64::from(stack.count))
            .sum();
        let work_per_run = input_count.saturating_add(output_count);
        if work_per_run > 0 {
            runs = runs.min((MAX_RECIPE_ITEM_OPS / work_per_run) as u32);
        }
        if node.capacity >= 0 && output_count > input_count {
            let free = (node.capacity as usize).saturating_sub(node.items.len()) as u64;
            runs = runs.min((free / (output_count - input_count)) as u32);
        }
        if runs == 0 {
            return Ok(RecipeExecution {
                runs: 0,
                consumed: Vec::new(),
                produced: Vec::new(),
            });
        }

        let consumed_capacity = usize::try_from(input_count.saturating_mul(u64::from(runs)))
            .map_err(|_| "recipe consumed-item count exceeds addressable memory".to_string())?;
        let produced_capacity = usize::try_from(output_count.saturating_mul(u64::from(runs)))
            .map_err(|_| "recipe produced-item count exceeds addressable memory".to_string())?;
        self.next_item_id
            .checked_add(produced_capacity as u64)
            .ok_or_else(|| "graph item id overflow".to_string())?;
        let mut consumed = Vec::new();
        consumed
            .try_reserve_exact(consumed_capacity)
            .map_err(|_| "could not allocate recipe consumption staging".to_string())?;
        for input in &recipe.inputs {
            let needed = input.count as usize * runs as usize;
            consumed.extend(
                node.items
                    .iter()
                    .filter(|item_id| {
                        self.items
                            .get(item_id)
                            .is_some_and(|item| item.alive && item.item_type == input.item_type)
                    })
                    .copied()
                    .take(needed),
            );
        }
        if consumed.len() != consumed_capacity {
            return Err("recipe inventory changed during preparation".to_string());
        }
        let mut produced = Vec::new();
        produced
            .try_reserve_exact(produced_capacity)
            .map_err(|_| "could not allocate recipe production staging".to_string())?;
        for item_id in &consumed {
            self.kill_item_and_detach(*item_id)?;
        }
        for _ in 0..runs {
            for output in &recipe.outputs {
                for _ in 0..output.count {
                    let item_id = self.create_item(&output.item_type, -1.0);
                    self.move_item_to_node_inventory(item_id, node_id)?;
                    produced.push(item_id);
                }
            }
        }
        Ok(RecipeExecution {
            runs,
            consumed,
            produced,
        })
    }

    /// Create many same-type items directly in one node inventory.
    pub fn spawn_items_at_node(
        &mut self,
        node_id: u64,
        item_type: &str,
        count: u32,
        decay_time: f64,
    ) -> Result<Vec<u64>, String> {
        const MAX_SPAWN_ITEMS: u32 = 100_000;
        if count > MAX_SPAWN_ITEMS {
            return Err(format!(
                "item count {count} exceeds limit {MAX_SPAWN_ITEMS}"
            ));
        }
        if item_type.trim().is_empty() || item_type.len() > 128 {
            return Err("item type must contain 1..=128 characters".to_string());
        }
        if !decay_time.is_finite() || decay_time < -1.0 {
            return Err("decay time must be finite and at least -1".to_string());
        }
        let node = self.require_node(node_id)?;
        if node.capacity >= 0
            && node.items.len().saturating_add(count as usize) > node.capacity as usize
        {
            return Err(format!(
                "node {node_id} does not have capacity for {count} additional items"
            ));
        }
        self.next_item_id
            .checked_add(u64::from(count))
            .ok_or_else(|| "graph item id overflow".to_string())?;
        let mut ids = Vec::new();
        ids.try_reserve_exact(count as usize)
            .map_err(|_| "could not allocate item spawn result".to_string())?;
        for _ in 0..count {
            let item_id = self.create_item(item_type, decay_time);
            self.move_item_to_node_inventory(item_id, node_id)?;
            ids.push(item_id);
        }
        Ok(ids)
    }

    /// Serialize the complete graph state to stable compact JSON.
    pub fn snapshot_json(&self) -> Result<String, String> {
        let ordered: BTreeMap<String, serde_json::Value> = self.serialize().into_iter().collect();
        serde_json::to_string(&ordered).map_err(|error| error.to_string())
    }

    /// Return a deterministic FNV-1a hash of the complete graph snapshot.
    pub fn state_hash(&self) -> Result<String, String> {
        let snapshot = self.snapshot_json()?;
        let mut hash = 0xcbf29ce484222325u64;
        for byte in snapshot.as_bytes() {
            hash ^= u64::from(*byte);
            hash = hash.wrapping_mul(0x100000001b3);
        }
        Ok(format!("{hash:016x}"))
    }

    /// Replace graph state from a snapshot after an optional topology-version check.
    pub fn restore_snapshot_json(
        &mut self,
        snapshot: &str,
        expected_version: Option<u64>,
    ) -> Result<(), String> {
        if let Some(expected) = expected_version {
            if expected != self.topology_version {
                return Err(format!(
                    "version conflict: expected {expected}, current version is {}",
                    self.topology_version
                ));
            }
        }
        let values: BTreeMap<String, serde_json::Value> =
            serde_json::from_str(snapshot).map_err(|error| error.to_string())?;
        let values: HashMap<String, serde_json::Value> = values.into_iter().collect();
        let mut replacement = Self::deserialize(&values)?;
        replacement.topology_version = self
            .topology_version
            .checked_add(1)
            .ok_or_else(|| "graph topology version overflow".to_string())?;
        *self = replacement;
        Ok(())
    }
    /// Return outgoing edge ids for a node.
    pub fn get_outgoing_edges(&self, node_id: u64) -> Vec<u64> {
        self.outgoing_edge_ids_slice(node_id).to_vec()
    }
    /// Return incoming edge ids for a node.
    pub fn get_incoming_edges(&self, node_id: u64) -> Vec<u64> {
        self.incoming_edge_ids_slice(node_id).to_vec()
    }
    /// Return edge ids by requested direction or an error when the direction is invalid.
    pub fn get_edges_by_direction(
        &self,
        node_id: u64,
        direction: &str,
    ) -> Result<Vec<u64>, String> {
        if !self.nodes.contains_key(&node_id) {
            return Err("node not found".into());
        }
        match direction {
            "in" => Ok(self.get_incoming_edges(node_id)),
            "out" => Ok(self.get_outgoing_edges(node_id)),
            "both" => {
                let mut combined = self.get_outgoing_edges(node_id);
                combined.extend(self.get_incoming_edges(node_id));
                combined.sort();
                combined.dedup();
                Ok(combined)
            }
            _ => Err(format!(
                "invalid direction: '{}'. Use 'in', 'out', or 'both'",
                direction
            )),
        }
    }
    /// Draw a simple circular graph preview into an image buffer.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        img.fill(25, 25, 35, 255);
        let cx = width as f32 / 2.0;
        let cy = height as f32 / 2.0;
        let radius = (width.min(height) as f32) * 0.35;
        let mut node_ids: Vec<u64> = self.nodes.keys().copied().collect();
        node_ids.sort();
        let n = node_ids.len();
        if n == 0 {
            return img;
        }
        let positions: Vec<(f32, f32)> = (0..n)
            .map(|i| {
                let angle =
                    i as f32 * std::f32::consts::PI * 2.0 / n as f32 - std::f32::consts::FRAC_PI_2;
                (cx + radius * angle.cos(), cy + radius * angle.sin())
            })
            .collect();
        let id_to_idx: std::collections::HashMap<u64, usize> = node_ids
            .iter()
            .enumerate()
            .map(|(i, &id)| (id, i))
            .collect();
        for edge in self.edges.values() {
            if let (Some(&ai), Some(&bi)) =
                (id_to_idx.get(&edge.from_node), id_to_idx.get(&edge.to_node))
            {
                let (ax, ay) = positions[ai];
                let (bx, by) = positions[bi];
                img.draw_line(
                    ax as i32, ay as i32, bx as i32, by as i32, 80, 120, 160, 200,
                );
            }
        }
        for (i, &nid) in node_ids.iter().enumerate() {
            let (px, py) = positions[i];
            let (r, g, b) = if self.nodes[&nid].node_type == "city" {
                (200u8, 80, 80)
            } else {
                (80, 200, 80)
            };
            img.draw_circle(px as i32, py as i32, 8, r, g, b, 255);
        }
        img
    }
    /// Serialize nodes and edges into a JSON-like value map.
    pub fn serialize(&self) -> HashMap<String, serde_json::Value> {
        use serde_json::{json, Value};
        let mut nodes_arr: Vec<Value> = self
            .nodes
            .values()
            .map(|n| {
                let mut tags = n.get_tags();
                tags.sort_unstable();
                let mut conversions: Vec<Value> = n
                    .conversions
                    .values()
                    .map(|rule| {
                        json!({
                            "in_type": rule.in_type,
                            "out_type": rule.out_type,
                            "in_count": rule.in_count,
                            "out_count": rule.out_count
                        })
                    })
                    .collect();
                conversions.sort_by(|a, b| {
                    a["in_type"]
                        .as_str()
                        .unwrap_or_default()
                        .cmp(b["in_type"].as_str().unwrap_or_default())
                });
                let recipes: Vec<Value> = n
                    .recipes
                    .values()
                    .map(|recipe| {
                        json!({
                            "name": recipe.name,
                            "inputs": recipe.inputs.iter().map(|stack| json!({
                                "item_type": stack.item_type,
                                "count": stack.count
                            })).collect::<Vec<_>>(),
                            "outputs": recipe.outputs.iter().map(|stack| json!({
                                "item_type": stack.item_type,
                                "count": stack.count
                            })).collect::<Vec<_>>()
                        })
                    })
                    .collect();
                let demands: Vec<Value> = n
                    .demands
                    .iter()
                    .map(|d| {
                        json!({
                            "item_type": d.item_type,
                            "quantity": d.quantity,
                            "priority": d.priority
                        })
                    })
                    .collect();
                let supplies: Vec<Value> = n
                    .supplies
                    .iter()
                    .map(|s| {
                        json!({
                            "item_type": s.item_type,
                            "quantity": s.quantity
                        })
                    })
                    .collect();
                let mut capacity_reservations: Vec<Value> = n
                    .capacity_reservations
                    .iter()
                    .map(|(key, slots)| json!({ "key": key, "slots": slots }))
                    .collect();
                capacity_reservations.sort_by(|a, b| {
                    a["key"]
                        .as_str()
                        .unwrap_or_default()
                        .cmp(b["key"].as_str().unwrap_or_default())
                });
                json!({
                    "id": n.id.raw(),
                    "node_type": n.node_type,
                    "capacity": n.capacity,
                    "active": n.active,
                    "overflow_policy": n.overflow_policy.to_str(),
                    "flow_mode": n.flow_mode.to_str(),
                    "push_rate": n.push_rate,
                    "pull_rate": n.pull_rate,
                    "push_filter": n.push_filter,
                    "pull_filter": n.pull_filter,
                    "process_time": n.process_time,
                    "queue_enabled": n.queue_enabled,
                    "queue_capacity": n.queue_capacity,
                    "queue": n.queue.iter().copied().collect::<Vec<u64>>(),
                    "items": n.items,
                    "conversions": conversions,
                    "recipes": recipes,
                    "demands": demands,
                    "supplies": supplies,
                    "tags": tags,
                    "capacity_reservations": capacity_reservations,
                    "push_timer": n.push_timer,
                    "pull_timer": n.pull_timer,
                    "process_accumulator": n.process_accumulator
                })
            })
            .collect();
        nodes_arr.sort_by_key(|v| v["id"].as_u64().unwrap_or(0));
        let mut edges_arr: Vec<Value> = self
            .edges
            .values()
            .map(|e| {
                let mut allowed_types: Vec<String> = e.allowed_types.iter().cloned().collect();
                allowed_types.sort_unstable();
                let mut capacity_reservations: Vec<Value> = e
                    .capacity_reservations
                    .iter()
                    .map(|(key, slots)| json!({ "key": key, "slots": slots }))
                    .collect();
                capacity_reservations.sort_by(|a, b| {
                    a["key"]
                        .as_str()
                        .unwrap_or_default()
                        .cmp(b["key"].as_str().unwrap_or_default())
                });
                json!({
                    "id": e.id.raw(),
                    "edge_type": e.edge_type,
                    "from": e.from_node,
                    "to": e.to_node,
                    "capacity": e.capacity,
                    "throughput": e.throughput,
                    "travel_time": e.travel_time,
                    "weight": e.weight,
                    "speed_modifier": e.speed_modifier,
                    "cooldown": e.cooldown,
                    "cooldown_timer": e.cooldown_timer,
                    "bidirectional": e.bidirectional,
                    "active": e.active,
                    "allowed_types": allowed_types,
                    "capacity_reservations": capacity_reservations,
                    "items_in_transit": e.items_in_transit
                })
            })
            .collect();
        edges_arr.sort_by_key(|v| v["id"].as_u64().unwrap_or(0));
        let mut items_arr: Vec<Value> = self
            .items
            .values()
            .map(|item| {
                let position = match item.get_position() {
                    ItemPosition::AtNode(node_id) => {
                        json!({ "kind": "node", "node_id": node_id })
                    }
                    ItemPosition::InTransit { edge_id, progress } => {
                        json!({ "kind": "edge", "edge_id": edge_id, "progress": progress })
                    }
                    ItemPosition::Unplaced => json!({ "kind": "unplaced" }),
                };
                json!({
                    "id": item.id.raw(),
                    "item_type": item.item_type,
                    "decay_time": item.decay_time,
                    "remaining_life": item.remaining_life,
                    "alive": item.alive,
                    "priority": item.priority,
                    "position": position
                })
            })
            .collect();
        items_arr.sort_by_key(|v| v["id"].as_u64().unwrap_or(0));
        let mut map = HashMap::new();
        map.insert(
            "version".to_string(),
            Value::from(FLOWNET_SERIALIZE_VERSION),
        );
        map.insert("nodes".to_string(), Value::Array(nodes_arr));
        map.insert("edges".to_string(), Value::Array(edges_arr));
        map.insert("items".to_string(), Value::Array(items_arr));
        map
    }
    /// Deserialize a graph from the JSON-like value map or return a shape error.
    pub fn deserialize(data: &HashMap<String, serde_json::Value>) -> Result<Self, String> {
        let version = data.get("version").and_then(serde_json::Value::as_u64);
        if version.is_none() {
            return Self::deserialize_legacy_topology(data);
        }
        if version != Some(FLOWNET_SERIALIZE_VERSION) {
            return Err(format!(
                "unsupported flownet serialization version: {:?}",
                version
            ));
        }
        Self::deserialize_full_state(data)
    }
    /// Deserialize the legacy topology-only payload used before versioned state snapshots.
    fn deserialize_legacy_topology(
        data: &HashMap<String, serde_json::Value>,
    ) -> Result<Self, String> {
        let mut g = Self::new();
        if let Some(nodes_val) = data.get("nodes") {
            let arr = nodes_val.as_array().ok_or("nodes must be an array")?;
            for n in arr {
                let node_type = n["node_type"].as_str().unwrap_or("default");
                let capacity = n["capacity"].as_i64().unwrap_or(-1) as i32;
                g.add_node(node_type, capacity);
            }
        }
        if let Some(edges_val) = data.get("edges") {
            let arr = edges_val.as_array().ok_or("edges must be an array")?;
            for e in arr {
                let from = e["from"].as_u64().ok_or("edge missing 'from'")?;
                let to = e["to"].as_u64().ok_or("edge missing 'to'")?;
                let edge_type = e["edge_type"].as_str();
                let weight = e["weight"].as_f64().unwrap_or(1.0);
                let bidirectional = e["bidirectional"].as_bool().unwrap_or(false);
                let eid = g
                    .add_edge(from, to, edge_type)
                    .map_err(|e| format!("add_edge error: {e}"))?;
                if let Some(edge) = g.edges.get_mut(&eid) {
                    edge.weight = weight;
                    edge.bidirectional = bidirectional;
                }
            }
        }
        Ok(g)
    }
    /// Deserialize the versioned full-state payload and validate cross-references.
    fn deserialize_full_state(data: &HashMap<String, serde_json::Value>) -> Result<Self, String> {
        use super::node::{ConversionRule, Demand, FlowMode, RecipeRule, RecipeStack, Supply};
        use serde_json::Value;

        fn parse_u64_array(value: &Value, label: &str) -> Result<Vec<u64>, String> {
            let arr = value
                .as_array()
                .ok_or_else(|| format!("{label} must be an array"))?;
            arr.iter()
                .map(|entry| {
                    entry
                        .as_u64()
                        .ok_or_else(|| format!("{label} entries must be integers"))
                })
                .collect()
        }

        let nodes_arr = data
            .get("nodes")
            .ok_or("nodes missing from flownet snapshot")?
            .as_array()
            .ok_or("nodes must be an array")?;
        let edges_arr = data
            .get("edges")
            .ok_or("edges missing from flownet snapshot")?
            .as_array()
            .ok_or("edges must be an array")?;
        let items_arr = data
            .get("items")
            .ok_or("items missing from flownet snapshot")?
            .as_array()
            .ok_or("items must be an array")?;

        let mut g = Self::new();

        for node_value in nodes_arr {
            let node_id = node_value["id"]
                .as_u64()
                .ok_or("node id must be an integer")?;
            let node_type = node_value["node_type"].as_str().unwrap_or("default");
            let capacity = node_value["capacity"].as_i64().unwrap_or(-1) as i32;
            let overflow_policy = node_value["overflow_policy"]
                .as_str()
                .unwrap_or("reject")
                .parse::<OverflowPolicy>()?;
            let flow_mode = node_value["flow_mode"]
                .as_str()
                .unwrap_or("passive")
                .parse::<FlowMode>()?;
            let queue_values = parse_u64_array(&node_value["queue"], "node.queue")?;
            let item_values = parse_u64_array(&node_value["items"], "node.items")?;
            let mut node = Node::new(node_id, node_type, capacity);
            node.active = node_value["active"].as_bool().unwrap_or(true);
            node.overflow_policy = overflow_policy;
            node.flow_mode = flow_mode;
            node.push_rate = node_value["push_rate"].as_f64().unwrap_or(1.0);
            node.pull_rate = node_value["pull_rate"].as_f64().unwrap_or(1.0);
            node.push_filter = node_value["push_filter"].as_str().map(str::to_string);
            node.pull_filter = node_value["pull_filter"].as_str().map(str::to_string);
            node.process_time = node_value["process_time"].as_f64().unwrap_or(0.0);
            node.queue_enabled = node_value["queue_enabled"].as_bool().unwrap_or(false);
            node.queue_capacity = node_value["queue_capacity"].as_i64().unwrap_or(-1) as i32;
            node.queue = queue_values.into_iter().collect();
            node.items = item_values;
            if let Some(conversions) = node_value["conversions"].as_array() {
                for conversion in conversions {
                    let rule = ConversionRule {
                        in_type: conversion["in_type"]
                            .as_str()
                            .ok_or("conversion.in_type must be a string")?
                            .to_string(),
                        out_type: conversion["out_type"]
                            .as_str()
                            .ok_or("conversion.out_type must be a string")?
                            .to_string(),
                        in_count: conversion["in_count"].as_u64().unwrap_or(1) as u32,
                        out_count: conversion["out_count"].as_u64().unwrap_or(1) as u32,
                    };
                    node.set_conversion(rule);
                }
            }
            if let Some(recipes) = node_value["recipes"].as_array() {
                for recipe in recipes {
                    let parse_stacks = |field: &str| -> Result<Vec<RecipeStack>, String> {
                        recipe[field]
                            .as_array()
                            .ok_or_else(|| format!("recipe.{field} must be an array"))?
                            .iter()
                            .map(|stack| {
                                Ok(RecipeStack {
                                    item_type: stack["item_type"]
                                        .as_str()
                                        .ok_or_else(|| {
                                            format!("recipe.{field}.item_type must be a string")
                                        })?
                                        .to_string(),
                                    count: u32::try_from(stack["count"].as_u64().ok_or_else(
                                        || format!("recipe.{field}.count must be an integer"),
                                    )?)
                                    .map_err(|_| {
                                        format!("recipe.{field}.count exceeds 32-bit range")
                                    })?,
                                })
                            })
                            .collect()
                    };
                    node.set_recipe(RecipeRule {
                        name: recipe["name"]
                            .as_str()
                            .ok_or("recipe.name must be a string")?
                            .to_string(),
                        inputs: parse_stacks("inputs")?,
                        outputs: parse_stacks("outputs")?,
                    })?;
                }
            }
            if let Some(demands) = node_value["demands"].as_array() {
                node.demands = demands
                    .iter()
                    .map(|value| {
                        Ok(Demand {
                            item_type: value["item_type"]
                                .as_str()
                                .ok_or("demand.item_type must be a string")
                                .map(str::to_string)?,
                            quantity: value["quantity"].as_i64().unwrap_or(0) as i32,
                            priority: value["priority"].as_i64().unwrap_or(0) as i32,
                        })
                    })
                    .collect::<Result<Vec<_>, String>>()?;
            }
            if let Some(supplies) = node_value["supplies"].as_array() {
                node.supplies = supplies
                    .iter()
                    .map(|value| {
                        Ok(Supply {
                            item_type: value["item_type"]
                                .as_str()
                                .ok_or("supply.item_type must be a string")
                                .map(str::to_string)?,
                            quantity: value["quantity"].as_i64().unwrap_or(0) as i32,
                        })
                    })
                    .collect::<Result<Vec<_>, String>>()?;
            }
            if let Some(tags) = node_value["tags"].as_array() {
                node.tags = tags
                    .iter()
                    .map(|tag| {
                        tag.as_str()
                            .ok_or_else(|| "node tag must be a string".to_string())
                            .map(str::to_string)
                    })
                    .collect::<Result<_, _>>()?;
            }
            if let Some(reservations) = node_value["capacity_reservations"].as_array() {
                node.capacity_reservations = reservations
                    .iter()
                    .map(|reservation| {
                        let key = reservation["key"]
                            .as_str()
                            .ok_or("node reservation key must be a string")?
                            .to_string();
                        let slots = reservation["slots"].as_u64().unwrap_or(0) as u32;
                        Ok((key, slots))
                    })
                    .collect::<Result<_, String>>()?;
            }
            node.push_timer = node_value["push_timer"].as_f64().unwrap_or(0.0);
            node.pull_timer = node_value["pull_timer"].as_f64().unwrap_or(0.0);
            node.process_accumulator = node_value["process_accumulator"].as_f64().unwrap_or(0.0);

            g.next_node_id = g.next_node_id.max(node_id + 1);
            g.outgoing_index.entry(node_id).or_default();
            g.incoming_index.entry(node_id).or_default();
            g.nodes.insert(node_id, node);
        }

        for edge_value in edges_arr {
            let edge_id = edge_value["id"]
                .as_u64()
                .ok_or("edge id must be an integer")?;
            let from = edge_value["from"]
                .as_u64()
                .ok_or("edge.from must be an integer")?;
            let to = edge_value["to"]
                .as_u64()
                .ok_or("edge.to must be an integer")?;
            if !g.nodes.contains_key(&from) || !g.nodes.contains_key(&to) {
                return Err(format!(
                    "edge {edge_id} references missing endpoint(s): {from} -> {to}"
                ));
            }
            let mut edge = Edge::new(
                edge_id,
                from,
                to,
                edge_value["edge_type"].as_str().unwrap_or("default"),
            );
            edge.capacity = edge_value["capacity"].as_i64().unwrap_or(-1) as i32;
            edge.throughput = edge_value["throughput"].as_f64().unwrap_or(1.0);
            edge.travel_time = edge_value["travel_time"].as_f64().unwrap_or(1.0);
            edge.weight = edge_value["weight"].as_f64().unwrap_or(1.0);
            edge.speed_modifier = edge_value["speed_modifier"].as_f64().unwrap_or(1.0);
            edge.cooldown = edge_value["cooldown"].as_f64().unwrap_or(0.0);
            edge.cooldown_timer = edge_value["cooldown_timer"].as_f64().unwrap_or(0.0);
            edge.bidirectional = edge_value["bidirectional"].as_bool().unwrap_or(false);
            edge.active = edge_value["active"].as_bool().unwrap_or(true);
            edge.allowed_types = edge_value["allowed_types"]
                .as_array()
                .map(|types| {
                    types
                        .iter()
                        .map(|value| {
                            value
                                .as_str()
                                .ok_or_else(|| "edge allowed type must be a string".to_string())
                                .map(str::to_string)
                        })
                        .collect::<Result<_, _>>()
                })
                .transpose()?
                .unwrap_or_default();
            if let Some(reservations) = edge_value["capacity_reservations"].as_array() {
                edge.capacity_reservations = reservations
                    .iter()
                    .map(|reservation| {
                        let key = reservation["key"]
                            .as_str()
                            .ok_or("edge reservation key must be a string")?
                            .to_string();
                        let slots = reservation["slots"].as_u64().unwrap_or(0) as u32;
                        Ok((key, slots))
                    })
                    .collect::<Result<_, String>>()?;
            }
            edge.items_in_transit =
                parse_u64_array(&edge_value["items_in_transit"], "edge.items_in_transit")?;

            g.next_edge_id = g.next_edge_id.max(edge_id + 1);
            g.edges.insert(edge_id, edge);
            g.index_edge(edge_id, from, to);
        }

        for item_value in items_arr {
            let item_id = item_value["id"]
                .as_u64()
                .ok_or("item id must be an integer")?;
            let mut item = GraphItem::new(
                item_id,
                item_value["item_type"].as_str().unwrap_or("default"),
                item_value["decay_time"].as_f64().unwrap_or(-1.0),
            );
            item.remaining_life = item_value["remaining_life"]
                .as_f64()
                .unwrap_or(item.decay_time);
            item.alive = item_value["alive"].as_bool().unwrap_or(true);
            item.priority = item_value["priority"].as_i64().unwrap_or(0) as i32;
            let position_value = item_value
                .get("position")
                .ok_or("item.position is required")?;
            item.position = match position_value["kind"].as_str().unwrap_or("unplaced") {
                "node" => ItemPosition::AtNode(
                    position_value["node_id"]
                        .as_u64()
                        .ok_or("item.position.node_id must be an integer")?,
                ),
                "edge" => ItemPosition::InTransit {
                    edge_id: position_value["edge_id"]
                        .as_u64()
                        .ok_or("item.position.edge_id must be an integer")?,
                    progress: position_value["progress"].as_f64().unwrap_or(0.0),
                },
                "unplaced" => ItemPosition::Unplaced,
                other => return Err(format!("unknown item position kind '{other}'")),
            };
            g.next_item_id = g.next_item_id.max(item_id + 1);
            g.items.insert(item_id, item);
        }

        for (node_id, node) in &g.nodes {
            for item_id in &node.items {
                let item = g
                    .items
                    .get(item_id)
                    .ok_or_else(|| format!("node {node_id} references missing item {item_id}"))?;
                match item.position {
                    ItemPosition::AtNode(owner) if owner == *node_id => {}
                    _ => {
                        return Err(format!(
                            "node {node_id} inventory references item {item_id} with mismatched position"
                        ))
                    }
                }
            }
            for item_id in &node.queue {
                let item = g.items.get(item_id).ok_or_else(|| {
                    format!("node {node_id} queue references missing item {item_id}")
                })?;
                match item.position {
                    ItemPosition::AtNode(owner) if owner == *node_id => {}
                    _ => {
                        return Err(format!(
                        "node {node_id} queue references item {item_id} with mismatched position"
                    ))
                    }
                }
            }
        }

        for (edge_id, edge) in &g.edges {
            for item_id in &edge.items_in_transit {
                let item = g
                    .items
                    .get(item_id)
                    .ok_or_else(|| format!("edge {edge_id} references missing item {item_id}"))?;
                match item.position {
                    ItemPosition::InTransit { edge_id: owner, .. } if owner == *edge_id => {}
                    _ => {
                        return Err(format!(
                            "edge {edge_id} transit buffer references item {item_id} with mismatched position"
                        ))
                    }
                }
            }
        }

        for (item_id, item) in &g.items {
            match item.position {
                ItemPosition::AtNode(node_id) => {
                    if !g.nodes.contains_key(&node_id) {
                        return Err(format!("item {item_id} references missing node {node_id}"));
                    }
                    if !g.node_inventory_contains(node_id, *item_id)
                        && !g.node_queue_contains(node_id, *item_id)
                    {
                        return Err(format!(
                            "item {item_id} is positioned on node {node_id} but no node container owns it"
                        ));
                    }
                }
                ItemPosition::InTransit { edge_id, .. } => {
                    let Some(edge) = g.edges.get(&edge_id) else {
                        return Err(format!("item {item_id} references missing edge {edge_id}"));
                    };
                    if !edge.items_in_transit.contains(item_id) {
                        return Err(format!(
                            "item {item_id} is positioned on edge {edge_id} but the edge does not own it"
                        ));
                    }
                }
                ItemPosition::Unplaced => {}
            }
        }

        Ok(g)
    }
}
