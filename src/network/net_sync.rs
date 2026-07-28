//! This file owns compact entity-snapshot and sync-snapshot models used for networked state replication.
//! `EntitySnapshot` stores tick, position, and velocity, while `SyncSnapshot` encodes full, delta, and corrective syncs.
//! NetValue conversion lives here because snapshot wire shape belongs with the replicated state contracts themselves.
//! Prediction and reconciliation helpers also stay here because smoothing policy is part of sync semantics, not transport.
//! The distance-based reconcile policy is local because soft and hard correction thresholds shape state convergence.
//! Open it when replicated actor semantics change; hosts, sockets, and Lua netstate bindings live in siblings.

use crate::network::message::NetValue;
use std::collections::{BTreeMap, BTreeSet};
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

/// One ordered player input retained by a bounded replication buffer.
#[derive(Debug, Clone, PartialEq)]
pub struct BufferedInput {
    /// Remote peer that authored the input.
    pub peer_id: u32,
    /// Simulation tick for which the input was sampled.
    pub tick: u32,
    /// Peer-local monotonically increasing input sequence.
    pub sequence: u32,
    /// Game-defined, serializable input payload.
    pub payload: NetValue,
}

/// Capacity and clock-skew limits for an [`InputBuffer`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InputBufferLimits {
    /// Maximum remote peers that can retain pending input.
    pub max_peers: usize,
    /// Maximum queued inputs per peer.
    pub max_inputs_per_peer: usize,
    /// Accepted future tick distance after the drain clock is initialized.
    pub max_future_ticks: u32,
    /// Accepted late tick distance after the drain clock is initialized.
    pub max_past_ticks: u32,
}

impl Default for InputBufferLimits {
    fn default() -> Self {
        Self {
            max_peers: 16,
            max_inputs_per_peer: 256,
            max_future_ticks: 120,
            max_past_ticks: 30,
        }
    }
}

/// Result of trying to insert one remote input into an [`InputBuffer`].
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InputPushResult {
    /// The input was retained for a later drain.
    Accepted,
    /// The input was already queued or had already been committed for that peer.
    Duplicate,
    /// The input was older than the configured late-input window.
    TooOld,
    /// The input was farther ahead than the configured future-input window.
    TooFarAhead,
    /// The input would exceed the bounded peer count.
    PeerLimit,
    /// The input would exceed that peer's bounded queue.
    PerPeerLimit,
}

impl InputPushResult {
    /// Returns the stable Lua-facing result label.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Accepted => "accepted",
            Self::Duplicate => "duplicate",
            Self::TooOld => "too_old",
            Self::TooFarAhead => "too_far_ahead",
            Self::PeerLimit => "peer_limit",
            Self::PerPeerLimit => "per_peer_limit",
        }
    }
}

/// Bounded deterministic buffer for game-defined input payloads received out of order.
///
/// Entries drain in `(tick, peer_id, sequence)` order. The buffer neither predicts entities nor
/// applies commands; a Lua game decides how each drained payload updates its own simulation.
#[derive(Debug)]
pub struct InputBuffer {
    limits: InputBufferLimits,
    entries: BTreeMap<(u32, u32, u32), NetValue>,
    pending_per_peer: BTreeMap<u32, usize>,
    known_peers: BTreeSet<u32>,
    last_committed_sequence: BTreeMap<u32, u32>,
    drained_through: Option<u32>,
}

/// Error returned when a snapshot history cannot resolve a received delta against its base.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SnapshotStoreError {
    /// The delta's declared base tick is no longer retained locally.
    MissingBase,
}

/// Bounded resolved snapshot history for Lua-owned interpolation and replication policies.
///
/// The store accepts the existing full, corrective, and delta snapshot wire models but does not
/// apply entity data to ECS, physics, rendering, or gameplay state. Lua reads retained frames and
/// decides which systems should consume them.
#[derive(Debug, Clone)]
pub struct SnapshotStore {
    capacity: usize,
    frames: BTreeMap<u32, BTreeMap<u32, EntitySnapshot>>,
}

impl SnapshotStore {
    /// Creates an empty history retaining at most `capacity` resolved ticks.
    pub fn new(capacity: usize) -> Self {
        Self {
            capacity: capacity.max(1),
            frames: BTreeMap::new(),
        }
    }

    /// Resolves and retains a snapshot, returning an error only when a delta lacks its base frame.
    pub fn push(&mut self, snapshot: &SyncSnapshot) -> Result<(), SnapshotStoreError> {
        let (tick, entities) = match snapshot {
            SyncSnapshot::Full { tick, entities } | SyncSnapshot::Corrective { tick, entities } => {
                let entities = entities
                    .iter()
                    .cloned()
                    .map(|entity| (entity.id, entity))
                    .collect();
                (*tick, entities)
            }
            SyncSnapshot::Delta {
                tick,
                base_tick,
                updates,
                removals,
            } => {
                let Some(base) = self.frames.get(base_tick) else {
                    return Err(SnapshotStoreError::MissingBase);
                };
                let mut entities = base.clone();
                for entity in updates {
                    entities.insert(entity.id, entity.clone());
                }
                for id in removals {
                    entities.remove(id);
                }
                (*tick, entities)
            }
        };
        self.frames.insert(tick, entities);
        while self.frames.len() > self.capacity {
            let Some(oldest) = self.frames.first_key_value().map(|(tick, _)| *tick) else {
                break;
            };
            self.frames.remove(&oldest);
        }
        Ok(())
    }

    /// Returns one resolved frame as id-sorted entity snapshots.
    pub fn frame(&self, tick: u32) -> Option<Vec<EntitySnapshot>> {
        self.frames
            .get(&tick)
            .map(|entities| entities.values().cloned().collect())
    }

    /// Returns the newest retained resolved frame.
    pub fn latest(&self) -> Option<(u32, Vec<EntitySnapshot>)> {
        self.frames
            .last_key_value()
            .map(|(tick, entities)| (*tick, entities.values().cloned().collect()))
    }

    /// Interpolates one entity between two retained resolved frames.
    pub fn interpolate(
        &self,
        id: u32,
        from_tick: u32,
        to_tick: u32,
        alpha: f32,
    ) -> Option<EntitySnapshot> {
        let from = self.frames.get(&from_tick)?.get(&id)?;
        let to = self.frames.get(&to_tick)?.get(&id)?;
        let t = alpha.clamp(0.0, 1.0);
        Some(EntitySnapshot {
            id,
            tick: to.tick,
            x: from.x + (to.x - from.x) * t,
            y: from.y + (to.y - from.y) * t,
            vx: from.vx + (to.vx - from.vx) * t,
            vy: from.vy + (to.vy - from.vy) * t,
        })
    }

    /// Returns the number of resolved frames currently retained.
    pub fn len(&self) -> usize {
        self.frames.len()
    }

    /// Returns true when no resolved snapshot frame is retained.
    pub fn is_empty(&self) -> bool {
        self.frames.is_empty()
    }

    /// Returns the configured retention capacity.
    pub fn capacity(&self) -> usize {
        self.capacity
    }

    /// Returns the retained tick set in ascending deterministic order.
    pub fn ticks(&self) -> BTreeSet<u32> {
        self.frames.keys().copied().collect()
    }
}

impl InputBuffer {
    /// Creates an empty buffer with explicit finite capacity and tick-window limits.
    pub fn new(limits: InputBufferLimits) -> Self {
        Self {
            limits,
            entries: BTreeMap::new(),
            pending_per_peer: BTreeMap::new(),
            known_peers: BTreeSet::new(),
            last_committed_sequence: BTreeMap::new(),
            drained_through: None,
        }
    }

    /// Inserts one game-defined payload when it fits the peer, capacity, and tick-window policy.
    pub fn push(&mut self, input: BufferedInput) -> InputPushResult {
        if let Some(drained_through) = self.drained_through {
            if input.tick.saturating_add(self.limits.max_past_ticks) < drained_through {
                return InputPushResult::TooOld;
            }
            if input.tick > drained_through.saturating_add(self.limits.max_future_ticks) {
                return InputPushResult::TooFarAhead;
            }
        }
        if self
            .last_committed_sequence
            .get(&input.peer_id)
            .is_some_and(|sequence| input.sequence <= *sequence)
        {
            return InputPushResult::Duplicate;
        }
        let key = (input.tick, input.peer_id, input.sequence);
        if self.entries.contains_key(&key) {
            return InputPushResult::Duplicate;
        }
        if !self.known_peers.contains(&input.peer_id)
            && self.known_peers.len() >= self.limits.max_peers
        {
            return InputPushResult::PeerLimit;
        }
        if self
            .pending_per_peer
            .get(&input.peer_id)
            .copied()
            .unwrap_or(0)
            >= self.limits.max_inputs_per_peer
        {
            return InputPushResult::PerPeerLimit;
        }
        self.known_peers.insert(input.peer_id);
        *self.pending_per_peer.entry(input.peer_id).or_default() += 1;
        self.entries.insert(key, input.payload);
        InputPushResult::Accepted
    }

    /// Drains all inputs through `tick` in stable tick, peer, and sequence order.
    pub fn drain_through(&mut self, tick: u32) -> Vec<BufferedInput> {
        self.drained_through = Some(
            self.drained_through
                .map_or(tick, |current| current.max(tick)),
        );
        let keys = self
            .entries
            .range(..=(tick, u32::MAX, u32::MAX))
            .map(|(key, _)| *key)
            .collect::<Vec<_>>();
        let mut drained = Vec::with_capacity(keys.len());
        for (input_tick, peer_id, sequence) in keys {
            let Some(payload) = self.entries.remove(&(input_tick, peer_id, sequence)) else {
                continue;
            };
            if let Some(count) = self.pending_per_peer.get_mut(&peer_id) {
                *count -= 1;
                if *count == 0 {
                    self.pending_per_peer.remove(&peer_id);
                }
            }
            self.last_committed_sequence
                .entry(peer_id)
                .and_modify(|last| *last = (*last).max(sequence))
                .or_insert(sequence);
            drained.push(BufferedInput {
                peer_id,
                tick: input_tick,
                sequence,
                payload,
            });
        }
        drained
    }

    /// Returns the last tick through which this buffer has been drained, if initialization occurred.
    pub fn drained_through(&self) -> Option<u32> {
        self.drained_through
    }

    /// Returns the number of queued inputs across all peers.
    pub fn len(&self) -> usize {
        self.entries.len()
    }

    /// Returns true when no input awaits a Lua-owned simulation step.
    pub fn is_empty(&self) -> bool {
        self.entries.is_empty()
    }

    /// Returns the configured finite input-buffer limits.
    pub fn limits(&self) -> InputBufferLimits {
        self.limits
    }

    /// Returns the number of peers that have retained or committed input history.
    pub fn peer_count(&self) -> usize {
        self.known_peers.len()
    }
}
