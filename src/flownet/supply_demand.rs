//! Provides demand-processing logic that matches prioritized needs against available network supply. `flownet/supply_demand` delivers the supply demand implementation for the flownet subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Uses pathfinding to route produced items from supplier nodes toward consumer destinations. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Tracks fulfillment progress and decrements source supply quantities during transfer. Public callable behavior is centered on no named public items, while method-level behavior such as `process_demand` stays attached to the local data model and invariants.
//! Emits simulation events that expose depletion and fulfillment transitions to observers. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use super::core::Graph;
use super::simulation::GraphEvent;
impl Graph {
    /// Process node demands and return the resulting graph events.
    pub fn process_demand(&mut self) -> Vec<GraphEvent> {
        let mut events = Vec::new();
        let mut all_demands: Vec<(u64, String, i32, i32)> = Vec::new();
        for node_id in self.get_node_ids() {
            if let Some(node) = self.nodes.get(&node_id) {
                for d in &node.demands {
                    all_demands.push((node.id.raw(), d.item_type.clone(), d.quantity, d.priority));
                }
            }
        }
        all_demands.sort_by(|a, b| {
            b.3.cmp(&a.3)
                .then_with(|| a.0.cmp(&b.0))
                .then_with(|| a.1.cmp(&b.1))
        });
        for (demand_node_id, item_type, quantity, _priority) in all_demands {
            let mut remaining = quantity;
            let supply_nodes: Vec<u64> = self
                .get_node_ids()
                .into_iter()
                .filter(|node_id| {
                    self.nodes.get(node_id).is_some_and(|n| {
                        n.id.raw() != demand_node_id
                            && n.supplies
                                .iter()
                                .any(|s| s.item_type == item_type && s.quantity != 0)
                    })
                })
                .collect();
            for supply_node_id in supply_nodes {
                if remaining <= 0 {
                    break;
                }
                let path = match self.find_path(supply_node_id, demand_node_id) {
                    Some(p) => p,
                    None => continue,
                };
                let available = self
                    .nodes
                    .get(&supply_node_id)
                    .map(|n| n.get_available_supply(&item_type))
                    .unwrap_or(0);
                let to_send = if available < 0 {
                    remaining
                } else {
                    remaining.min(available)
                };
                if to_send <= 0 {
                    continue;
                }
                let mut sent = 0;
                for _ in 0..to_send {
                    let item_id = self.create_item(&item_type, -1.0);
                    let _ = self.move_item_to_node_inventory(item_id, supply_node_id);
                    if let Some(&first_edge) = path.edges.first() {
                        match self.send_item(item_id, first_edge) {
                            Ok(true) => {
                                sent += 1;
                            }
                            _ => {
                                self.remove_item(item_id);
                                break;
                            }
                        }
                    } else {
                        sent += 1;
                    }
                }
                if sent > 0 {
                    remaining -= sent;
                    if let Some(node) = self.nodes.get_mut(&supply_node_id) {
                        for s in &mut node.supplies {
                            if s.item_type == item_type && s.quantity > 0 {
                                s.quantity -= sent;
                                if s.quantity <= 0 {
                                    events.push(GraphEvent::SupplyDepleted {
                                        node_id: supply_node_id,
                                        item_type: item_type.clone(),
                                    });
                                }
                                break;
                            }
                        }
                    }
                    events.push(GraphEvent::DemandFulfilled {
                        demand_node: demand_node_id,
                        supply_node: supply_node_id,
                        item_type: item_type.clone(),
                        count: sent as u32,
                    });
                }
            }
        }
        events
    }
}
