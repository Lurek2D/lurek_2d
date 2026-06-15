//! Provides the flownet simulation engine that advances transport, decay, conversion, and queue behavior per tick.
//! Processes item lifetimes and removes expired entities while preserving graph consistency guarantees.
//! Moves transit items along edges and resolves arrivals using each node's overflow policy.
//! Executes push and pull flow mechanics with rate-limited logic tied to node configuration.
//! Applies conversion rules that consume inputs and emit transformed output items at nodes.
//! Handles queued backpressure by promoting waiting items when capacity becomes available.
//! Emits structured simulation events for observable state transitions consumed by scripts.
//! Supports optional parallel stepping paths for larger network workloads under feature gating.
//! Coordinates sub-steps in deterministic order to keep outcomes reproducible across runs.
//! Delivers the runtime progression core for logistics-style gameplay simulation.

use super::core::Graph;
use super::item::ItemPosition;
use super::node::{FlowMode, OverflowPolicy};
use crate::log_msg;
use crate::runtime::log_messages::{GR01, GR02};
/// Simulation event emitted by graph updates.
#[derive(Debug, Clone)]
pub enum GraphEvent {
    /// Item entered a node.
    ItemEnter {
        /// Item id that entered.
        item_id: u64,
        /// Destination node id.
        node_id: u64,
    },
    /// Item left a node.
    ItemLeave {
        /// Item id that left.
        item_id: u64,
        /// Source node id.
        node_id: u64,
    },
    /// Item decayed and was removed from play.
    ItemDecay {
        /// Item id that decayed.
        item_id: u64,
    },
    /// Node converted items into new output items.
    ItemConvert {
        /// Node that performed the conversion.
        node_id: u64,
        /// Consumed item ids.
        consumed: Vec<u64>,
        /// Produced item ids.
        produced: Vec<u64>,
    },
    /// Item was lost because it could not enter a node.
    ItemLost {
        /// Item id that was lost.
        item_id: u64,
        /// Node that rejected or destroyed the item.
        node_id: u64,
    },
    /// Item entered an edge transit buffer.
    EdgeEnter {
        /// Item id that entered transit.
        item_id: u64,
        /// Edge id that accepted the item.
        edge_id: u64,
    },
    /// Item left an edge transit buffer.
    EdgeLeave {
        /// Item id that left transit.
        item_id: u64,
        /// Edge id that released the item.
        edge_id: u64,
    },
    /// Demand pulled supply from another node.
    DemandFulfilled {
        /// Node that requested the items.
        demand_node: u64,
        /// Node that supplied the items.
        supply_node: u64,
        /// Item type that moved.
        item_type: String,
        /// Number of items fulfilled.
        count: u32,
    },
    /// Supply record reached zero.
    SupplyDepleted {
        /// Node whose supply was depleted.
        node_id: u64,
        /// Item type that ran out.
        item_type: String,
    },
    /// Item entered a node queue.
    ItemQueued {
        /// Queued item id.
        item_id: u64,
        /// Node id that queued the item.
        node_id: u64,
    },
    /// Item left a node queue and entered the node inventory.
    ItemDequeued {
        /// Dequeued item id.
        item_id: u64,
        /// Node id that dequeued the item.
        node_id: u64,
    },
}
impl Graph {
    /// Run one simulation update and return the emitted events.
    pub fn update(&mut self, dt: f64) -> Vec<GraphEvent> {
        log_msg!(debug, GR01);
        let mut events = Vec::new();
        self.process_decay(dt, &mut events);
        self.process_transit(dt, &mut events);
        self.process_cooldowns(dt);
        self.process_push_flow(dt, &mut events);
        self.process_pull_flow(dt, &mut events);
        self.process_conversions(&mut events);
        self.process_queues(dt, &mut events);
        log_msg!(debug, GR02, "{}", events.len());
        events
    }
    /// Run one simulation update with dt set to 1.0.
    pub fn step(&mut self) -> Vec<GraphEvent> {
        self.update(1.0)
    }
    /// Run one simulation update using parallel decay processing when enabled.
    #[cfg(feature = "flownet-parallel")]
    pub fn update_parallel(&mut self, dt: f64) -> Vec<GraphEvent> {
        use rayon::prelude::*;
        log_msg!(debug, GR01);
        let mut events = Vec::new();
        self.items.par_iter_mut().for_each(|(_, item)| {
            if item.alive && item.decay_time >= 0.0 {
                item.remaining_life -= dt;
            }
        });
        let dead_ids: Vec<u64> = self
            .items
            .iter()
            .filter_map(|(id, item)| {
                if item.alive && item.decay_time >= 0.0 && item.remaining_life <= 0.0 {
                    Some(*id)
                } else {
                    None
                }
            })
            .collect();
        for id in dead_ids {
            let _ = self.kill_item_and_detach(id);
            events.push(GraphEvent::ItemDecay { item_id: id });
        }
        self.process_transit(dt, &mut events);
        self.process_cooldowns(dt);
        self.process_push_flow(dt, &mut events);
        self.process_pull_flow(dt, &mut events);
        self.process_conversions(&mut events);
        self.process_queues(dt, &mut events);
        log_msg!(debug, GR02, "{}", events.len());
        events
    }
    /// Run one simulation update when the parallel feature is disabled.
    #[cfg(not(feature = "flownet-parallel"))]
    pub fn update_parallel(&mut self, dt: f64) -> Vec<GraphEvent> {
        self.update(dt)
    }
    /// Apply item decay and emit decay events.
    fn process_decay(&mut self, dt: f64, events: &mut Vec<GraphEvent>) {
        let mut dead_ids = Vec::new();
        for item in self.items.values_mut() {
            if !item.alive || item.decay_time < 0.0 {
                continue;
            }
            item.remaining_life -= dt;
            if item.remaining_life <= 0.0 {
                item.kill();
                dead_ids.push(item.id.raw());
            }
        }
        for id in dead_ids {
            let _ = self.kill_item_and_detach(id);
            events.push(GraphEvent::ItemDecay { item_id: id });
        }
    }
    /// Advance edge transit progress and resolve arrivals.
    fn process_transit(&mut self, dt: f64, events: &mut Vec<GraphEvent>) {
        let mut arrivals: Vec<(u64, u64, u64)> = Vec::new();
        let edge_info: Vec<(u64, u64, f64, f64, Vec<u64>)> = self
            .edges
            .values()
            .filter(|e| e.active)
            .map(|e| {
                let effective_travel = e.travel_time / e.speed_modifier.max(0.001);
                let progress_delta = if effective_travel > 0.0 {
                    dt / effective_travel
                } else {
                    1.0
                };
                (
                    e.id.0,
                    e.to_node,
                    progress_delta,
                    e.travel_time,
                    e.items_in_transit.clone(),
                )
            })
            .collect();
        for (edge_id, dest_node, progress_delta, _travel_time, transit_items) in &edge_info {
            for &iid in transit_items {
                if let Some(item) = self.items.get_mut(&iid) {
                    if let ItemPosition::InTransit {
                        edge_id: eid,
                        ref mut progress,
                    } = item.position
                    {
                        if eid == *edge_id {
                            *progress += progress_delta;
                            if *progress >= 1.0 {
                                arrivals.push((iid, *edge_id, *dest_node));
                            }
                        }
                    }
                }
            }
        }
        for (item_id, edge_id, dest_node) in arrivals {
            events.push(GraphEvent::EdgeLeave { item_id, edge_id });
            if let Some(node) = self.nodes.get(&dest_node) {
                if node.is_full() {
                    match node.overflow_policy {
                        OverflowPolicy::Reject => {
                            let _ = self.move_item_to_unplaced(item_id);
                        }
                        OverflowPolicy::Destroy => {
                            let _ = self.kill_item_and_detach(item_id);
                            events.push(GraphEvent::ItemLost {
                                item_id,
                                node_id: dest_node,
                            });
                            continue;
                        }
                        OverflowPolicy::Queue => {
                            match self.move_item_to_node_queue(item_id, dest_node) {
                                Ok(true) => {
                                    events.push(GraphEvent::ItemQueued {
                                        item_id,
                                        node_id: dest_node,
                                    });
                                }
                                Ok(false) | Err(_) => {
                                    let _ = self.move_item_to_unplaced(item_id);
                                }
                            }
                            continue;
                        }
                    }
                } else {
                    let _ = self.move_item_to_node_inventory(item_id, dest_node);
                    events.push(GraphEvent::ItemEnter {
                        item_id,
                        node_id: dest_node,
                    });
                }
            }
        }
    }
    /// Reduce edge cooldown timers by the update delta.
    fn process_cooldowns(&mut self, dt: f64) {
        for edge in self.edges.values_mut() {
            if edge.cooldown_timer > 0.0 {
                edge.cooldown_timer = (edge.cooldown_timer - dt).max(0.0);
            }
        }
    }
    /// Push items from push-capable nodes onto outgoing edges.
    fn process_push_flow(&mut self, dt: f64, events: &mut Vec<GraphEvent>) {
        let push_nodes: Vec<u64> = self
            .get_node_ids()
            .into_iter()
            .filter(|node_id| {
                self.nodes.get(node_id).is_some_and(|node| {
                    node.active
                        && (node.flow_mode == FlowMode::Push || node.flow_mode == FlowMode::Both)
                })
            })
            .collect();
        for nid in push_nodes {
            let (push_rate, push_filter, items_snapshot) = {
                let node = match self.nodes.get_mut(&nid) {
                    Some(n) => n,
                    None => continue,
                };
                node.push_timer += dt;
                let slots = (node.push_timer * node.push_rate).floor() as usize;
                if slots == 0 {
                    continue;
                }
                node.push_timer -= slots as f64 / node.push_rate;
                (slots, node.push_filter.clone(), node.items.clone())
            };
            let outgoing: Vec<u64> = self.get_outgoing_edges(nid);
            let mut sent = 0;
            for &iid in &items_snapshot {
                if sent >= push_rate {
                    break;
                }
                let item_type = match self.items.get(&iid) {
                    Some(item) if item.alive => item.item_type.clone(),
                    _ => continue,
                };
                if let Some(ref filter) = push_filter {
                    if &item_type != filter {
                        continue;
                    }
                }
                for &eid in &outgoing {
                    let can_send = {
                        let edge = match self.edges.get(&eid) {
                            Some(e) => e,
                            None => continue,
                        };
                        edge.active
                            && !edge.is_on_cooldown()
                            && edge.is_item_type_allowed(&item_type)
                            && !edge.is_transit_full()
                    };
                    if can_send {
                        if let Ok(true) = self.send_item(iid, eid) {
                            events.push(GraphEvent::ItemLeave {
                                item_id: iid,
                                node_id: nid,
                            });
                            events.push(GraphEvent::EdgeEnter {
                                item_id: iid,
                                edge_id: eid,
                            });
                            sent += 1;
                            break;
                        }
                    }
                }
            }
        }
    }
    /// Pull items into pull-capable nodes from incoming edges.
    fn process_pull_flow(&mut self, dt: f64, events: &mut Vec<GraphEvent>) {
        let pull_nodes: Vec<u64> = self
            .get_node_ids()
            .into_iter()
            .filter(|node_id| {
                self.nodes.get(node_id).is_some_and(|node| {
                    node.active
                        && (node.flow_mode == FlowMode::Pull || node.flow_mode == FlowMode::Both)
                })
            })
            .collect();
        for nid in pull_nodes {
            let (pull_slots, pull_filter) = {
                let node = match self.nodes.get_mut(&nid) {
                    Some(n) => n,
                    None => continue,
                };
                node.pull_timer += dt;
                let slots = (node.pull_timer * node.pull_rate).floor() as usize;
                if slots == 0 {
                    continue;
                }
                node.pull_timer -= slots as f64 / node.pull_rate;
                (slots, node.pull_filter.clone())
            };
            let incoming: Vec<u64> = self.get_incoming_edges(nid);
            let mut pulled = 0;
            for &eid in &incoming {
                if pulled >= pull_slots {
                    break;
                }
                let (source_node_id, edge_active) = match self.edges.get(&eid) {
                    Some(e) => (e.from_node, e.active),
                    None => continue,
                };
                if !edge_active {
                    continue;
                }
                if let Some(node) = self.nodes.get(&nid) {
                    if node.is_full() {
                        break;
                    }
                }
                let source_items: Vec<u64> = match self.nodes.get(&source_node_id) {
                    Some(n) => n.items.clone(),
                    None => continue,
                };
                for &iid in &source_items {
                    if pulled >= pull_slots {
                        break;
                    }
                    let item_type = match self.items.get(&iid) {
                        Some(item) if item.alive => item.item_type.clone(),
                        _ => continue,
                    };
                    if let Some(ref filter) = pull_filter {
                        if &item_type != filter {
                            continue;
                        }
                    }
                    let allowed = match self.edges.get(&eid) {
                        Some(e) => e.is_item_type_allowed(&item_type) && !e.is_transit_full(),
                        None => false,
                    };
                    if !allowed {
                        continue;
                    }
                    if let Ok(true) = self.send_item(iid, eid) {
                        events.push(GraphEvent::ItemLeave {
                            item_id: iid,
                            node_id: source_node_id,
                        });
                        events.push(GraphEvent::EdgeEnter {
                            item_id: iid,
                            edge_id: eid,
                        });
                        pulled += 1;
                        break;
                    }
                }
            }
        }
    }
    /// Consume matching inputs and produce outputs for node conversion rules.
    fn process_conversions(&mut self, events: &mut Vec<GraphEvent>) {
        let node_ids = self.get_node_ids();
        for nid in node_ids {
            let conversions: Vec<(String, String, u32, u32)> = match self.nodes.get(&nid) {
                Some(node) if node.active && !node.conversions.is_empty() => node
                    .conversions
                    .values()
                    .map(|r| {
                        (
                            r.in_type.clone(),
                            r.out_type.clone(),
                            r.in_count,
                            r.out_count,
                        )
                    })
                    .collect(),
                _ => continue,
            };
            for (in_type, out_type, in_count, out_count) in conversions {
                loop {
                    let matching: Vec<u64> = {
                        let node = match self.nodes.get(&nid) {
                            Some(n) => n,
                            None => break,
                        };
                        node.items
                            .iter()
                            .filter(|&&iid| {
                                self.items
                                    .get(&iid)
                                    .map(|i| i.alive && i.item_type == in_type)
                                    .unwrap_or(false)
                            })
                            .copied()
                            .take(in_count as usize)
                            .collect()
                    };
                    if matching.len() < in_count as usize {
                        break;
                    }
                    let consumed = matching;
                    for &iid in &consumed {
                        let _ = self.kill_item_and_detach(iid);
                    }
                    let mut produced = Vec::new();
                    for _ in 0..out_count {
                        let new_id = self.create_item(&out_type, -1.0);
                        let _ = self.move_item_to_node_inventory(new_id, nid);
                        produced.push(new_id);
                    }
                    events.push(GraphEvent::ItemConvert {
                        node_id: nid,
                        consumed: consumed.clone(),
                        produced,
                    });
                }
            }
        }
    }
    /// Move queued items into node inventories when processing time and capacity allow.
    fn process_queues(&mut self, dt: f64, events: &mut Vec<GraphEvent>) {
        let node_ids = self.get_node_ids();
        for nid in node_ids {
            let should_dequeue = {
                let node = match self.nodes.get_mut(&nid) {
                    Some(n) => n,
                    None => continue,
                };
                if !node.queue_enabled || node.queue.is_empty() {
                    continue;
                }
                node.process_accumulator += dt;
                if node.process_time > 0.0 && node.process_accumulator < node.process_time {
                    continue;
                }
                if node.is_full() {
                    continue;
                }
                node.process_accumulator = 0.0;
                true
            };
            if should_dequeue {
                let item_id = {
                    let node = match self.nodes.get_mut(&nid) {
                        Some(node) => node,
                        None => continue,
                    };
                    match node.dequeue() {
                        Some(id) => id,
                        None => continue,
                    }
                };
                let _ = self.move_item_to_node_inventory(item_id, nid);
                events.push(GraphEvent::ItemDequeued {
                    item_id,
                    node_id: nid,
                });
            }
        }
    }
}
