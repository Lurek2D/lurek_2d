//! Entity snapshot capture and wire serialization for networked state. `network/net_sync` delivers the net sync implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Supports linear dead-reckoning prediction between ticks. The file owns or coordinates data contracts including `EntitySnapshot`, `SyncSnapshot`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Handles server-authoritative reconciliation with a configurable blend factor. Public callable behavior is centered on `predict_linear`, `reconcile`, `reconcile_with_policy`, while method-level behavior such as `to_netvalue`, `from_netvalue` stays attached to the local data model and invariants.
//! Gives the multiplayer stack a compact sync model for replicated actors. Runtime integration reaches sibling engine areas through crate modules `network`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! `network/net_sync` delivers the net sync implementation for the network subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

use crate::network::message::NetValue;
/// Point-in-time position and velocity snapshot for one networked entity.
#[derive(Debug, Clone, PartialEq)]
pub struct EntitySnapshot {
    /// Unique entity identifier consistent across all peers.
    pub id: u32,
    /// Simulation tick this snapshot was captured on.
    pub tick: u32,
    /// X position in world units.
    pub x: f32,
    /// Y position in world units.
    pub y: f32,
    /// X velocity in world units per second.
    pub vx: f32,
    /// Y velocity in world units per second.
    pub vy: f32,
}
/// Serialization and deserialization of entity snapshots to/from `NetValue`.
impl EntitySnapshot {
    /// Encode this snapshot as a `NetValue::Map` suitable for wire transmission.
    pub fn to_netvalue(&self) -> NetValue {
        NetValue::Map(vec![
            ("id".to_string(), NetValue::Integer(self.id as i64)),
            ("tick".to_string(), NetValue::Integer(self.tick as i64)),
            ("x".to_string(), NetValue::Float(self.x as f64)),
            ("y".to_string(), NetValue::Float(self.y as f64)),
            ("vx".to_string(), NetValue::Float(self.vx as f64)),
            ("vy".to_string(), NetValue::Float(self.vy as f64)),
        ])
    }
    /// Decode an `EntitySnapshot` from a `NetValue::Map`; returns `None` on missing or wrong-typed fields.
    pub fn from_netvalue(value: &NetValue) -> Option<Self> {
        let NetValue::Map(fields) = value else {
            return None;
        };
        let get_i = |name: &str| {
            fields.iter().find_map(|(k, v)| {
                if k == name {
                    if let NetValue::Integer(i) = v {
                        return Some(*i);
                    }
                }
                None
            })
        };
        let get_f = |name: &str| {
            fields.iter().find_map(|(k, v)| {
                if k == name {
                    match v {
                        NetValue::Float(f) => Some(*f as f32),
                        NetValue::Integer(i) => Some(*i as f32),
                        _ => None,
                    }
                } else {
                    None
                }
            })
        };
        Some(Self {
            id: get_i("id")? as u32,
            tick: get_i("tick")? as u32,
            x: get_f("x")?,
            y: get_f("y")?,
            vx: get_f("vx")?,
            vy: get_f("vy")?,
        })
    }
}
/// Return a linearly extrapolated snapshot one tick ahead of `snapshot` using its velocity and `dt` seconds.
pub fn predict_linear(snapshot: &EntitySnapshot, dt: f32) -> EntitySnapshot {
    let mut out = snapshot.clone();
    out.tick = out.tick.saturating_add(1);
    out.x += out.vx * dt;
    out.y += out.vy * dt;
    out
}
/// Blend `predicted` toward `authoritative` by factor `alpha` (0.0 = keep predicted, 1.0 = snap to authoritative).
pub fn reconcile(
    predicted: &EntitySnapshot,
    authoritative: &EntitySnapshot,
    alpha: f32,
) -> EntitySnapshot {
    let t = alpha.clamp(0.0, 1.0);
    EntitySnapshot {
        id: authoritative.id,
        tick: authoritative.tick,
        x: predicted.x + (authoritative.x - predicted.x) * t,
        y: predicted.y + (authoritative.y - predicted.y) * t,
        vx: authoritative.vx,
        vy: authoritative.vy,
    }
}

/// Variants of network state synchronization snapshots.
#[derive(Debug, Clone, PartialEq)]
pub enum SyncSnapshot {
    /// Full snapshot containing the complete state of all entities.
    Full {
        /// Active simulation tick.
        tick: u32,
        /// List of entity snapshots.
        entities: Vec<EntitySnapshot>,
    },
    /// Delta snapshot containing changes relative to a base tick.
    Delta {
        /// Active simulation tick.
        tick: u32,
        /// Base simulation tick that the changes are relative to.
        base_tick: u32,
        /// Updates and additions.
        updates: Vec<EntitySnapshot>,
        /// Removals of entity IDs.
        removals: Vec<u32>,
    },
    /// Corrective snapshot sent to reconcile client state.
    Corrective {
        /// Active simulation tick.
        tick: u32,
        /// List of entity snapshots.
        entities: Vec<EntitySnapshot>,
    },
}

impl SyncSnapshot {
    /// Encode this snapshot as a `NetValue`.
    pub fn to_netvalue(&self) -> NetValue {
        match self {
            SyncSnapshot::Full { tick, entities } => {
                let ent_vals = NetValue::Array(entities.iter().map(|e| e.to_netvalue()).collect());
                NetValue::Map(vec![
                    ("type".to_string(), NetValue::String("full".to_string())),
                    ("tick".to_string(), NetValue::Integer(*tick as i64)),
                    ("entities".to_string(), ent_vals),
                ])
            }
            SyncSnapshot::Delta {
                tick,
                base_tick,
                updates,
                removals,
            } => {
                let up_vals = NetValue::Array(updates.iter().map(|e| e.to_netvalue()).collect());
                let rem_vals = NetValue::Array(
                    removals
                        .iter()
                        .map(|&id| NetValue::Integer(id as i64))
                        .collect(),
                );
                NetValue::Map(vec![
                    ("type".to_string(), NetValue::String("delta".to_string())),
                    ("tick".to_string(), NetValue::Integer(*tick as i64)),
                    (
                        "base_tick".to_string(),
                        NetValue::Integer(*base_tick as i64),
                    ),
                    ("updates".to_string(), up_vals),
                    ("removals".to_string(), rem_vals),
                ])
            }
            SyncSnapshot::Corrective { tick, entities } => {
                let ent_vals = NetValue::Array(entities.iter().map(|e| e.to_netvalue()).collect());
                NetValue::Map(vec![
                    (
                        "type".to_string(),
                        NetValue::String("corrective".to_string()),
                    ),
                    ("tick".to_string(), NetValue::Integer(*tick as i64)),
                    ("entities".to_string(), ent_vals),
                ])
            }
        }
    }

    /// Decode a `SyncSnapshot` from a `NetValue`.
    pub fn from_netvalue(value: &NetValue) -> Option<Self> {
        let NetValue::Map(fields) = value else {
            return None;
        };

        let type_str = fields.iter().find_map(|(k, v)| {
            if k == "type" {
                if let NetValue::String(s) = v {
                    return Some(s.as_str());
                }
            }
            None
        })?;

        let get_i = |name: &str| {
            fields.iter().find_map(|(k, v)| {
                if k == name {
                    if let NetValue::Integer(i) = v {
                        return Some(*i);
                    }
                }
                None
            })
        };

        let get_entities = |name: &str| -> Option<Vec<EntitySnapshot>> {
            let list_val = fields.iter().find_map(|(k, v)| {
                if k == name {
                    if let NetValue::Array(arr) = v {
                        return Some(arr);
                    }
                }
                None
            })?;
            let mut list = Vec::new();
            for item in list_val {
                list.push(EntitySnapshot::from_netvalue(item)?);
            }
            Some(list)
        };

        match type_str {
            "full" => {
                let tick = get_i("tick")? as u32;
                let entities = get_entities("entities")?;
                Some(SyncSnapshot::Full { tick, entities })
            }
            "delta" => {
                let tick = get_i("tick")? as u32;
                let base_tick = get_i("base_tick")? as u32;
                let updates = get_entities("updates")?;
                let removals_val = fields.iter().find_map(|(k, v)| {
                    if k == "removals" {
                        if let NetValue::Array(arr) = v {
                            return Some(arr);
                        }
                    }
                    None
                })?;
                let mut removals = Vec::new();
                for item in removals_val {
                    if let NetValue::Integer(id) = item {
                        removals.push(*id as u32);
                    } else {
                        return None;
                    }
                }
                Some(SyncSnapshot::Delta {
                    tick,
                    base_tick,
                    updates,
                    removals,
                })
            }
            "corrective" => {
                let tick = get_i("tick")? as u32;
                let entities = get_entities("entities")?;
                Some(SyncSnapshot::Corrective { tick, entities })
            }
            _ => None,
        }
    }
}

/// Reconcile a predicted position towards an authoritative position using a distance-based tolerance policy:
/// - Under `soft_threshold` distance, no correction is applied.
/// - Between `soft_threshold` and `hard_threshold`, soft reconciliation (interpolation) is applied with the given `alpha`.
/// - Above `hard_threshold`, hard snap to the authoritative position is applied.
pub fn reconcile_with_policy(
    predicted: &EntitySnapshot,
    authoritative: &EntitySnapshot,
    alpha: f32,
    soft_threshold: f32,
    hard_threshold: f32,
) -> EntitySnapshot {
    let dx = authoritative.x - predicted.x;
    let dy = authoritative.y - predicted.y;
    let dist = (dx * dx + dy * dy).sqrt();

    if dist <= soft_threshold {
        let mut out = predicted.clone();
        out.vx = authoritative.vx;
        out.vy = authoritative.vy;
        out.tick = authoritative.tick;
        out
    } else if dist >= hard_threshold {
        authoritative.clone()
    } else {
        reconcile(predicted, authoritative, alpha)
    }
}
