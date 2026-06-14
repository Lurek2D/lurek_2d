//! Provides globe snapshot transfer structures for cross-thread synchronization and state exchange.
//! Defines channel wrappers and snapshot payload shapes used to move globe state safely.
//! Supports building and applying snapshots to keep remote and local globe views aligned.
//! Delivers the synchronization utility layer for background simulation integration.

use crate::globe::fog::FogStore;
use crate::globe::label::LabelStore;
use crate::globe::layer::LayerStore;
use crate::globe::marker::MarkerStore;
use crate::globe::projection::OrbitCamera;
use crate::globe::registry::Globe;
use crate::globe::topology::RegionGraph;
use crate::globe::types::{Arc as GlobeArc, GlobeSpec, HeatLayer, Region, RegionId};
use std::collections::{HashMap, HashSet};
use std::sync::mpsc::{channel, Receiver, Sender};
/// Serializable globe state used for snapshot transfer.
#[derive(Debug, Clone)]
pub struct GlobeSyncSnapshot {
    /// Globe name included in the snapshot.
    pub name: String,
    /// Full globe specification captured in the snapshot.
    pub spec: GlobeSpec,
    /// Full orbit camera state.
    pub camera: OrbitCamera,
    /// Province topology graph.
    pub graph: RegionGraph,
    /// Semantic regions that sit beside province topology.
    pub regions: HashMap<RegionId, Region>,
    /// Fog-of-war state for all viewers.
    pub fog: FogStore,
    /// Marker state.
    pub markers: MarkerStore,
    /// Label state.
    pub labels: LabelStore,
    /// Render layer state.
    pub layers: LayerStore,
    /// Arc render data keyed by arc id.
    pub arcs: HashMap<u32, GlobeArc>,
    /// Next arc id to assign.
    pub arc_next_id: u32,
    /// Active viewer name if one is set.
    pub active_viewer: Option<String>,
    /// Heat layers.
    pub heat_layers: Vec<HeatLayer>,
    /// Sector membership map.
    pub sectors: HashMap<String, HashSet<RegionId>>,
    /// Cached reachability data.
    pub reachability_cache: HashMap<String, HashMap<RegionId, f64>>,
    /// Simulation time accumulated by the globe runtime.
    pub sim_time_sec: f32,
}
/// Channel pair used to send and receive globe snapshots.
#[derive(Debug)]
pub struct GlobeSyncChannel {
    /// Sender side of the snapshot channel.
    pub tx: Sender<GlobeSyncSnapshot>,
    /// Receiver side of the snapshot channel.
    pub rx: Receiver<GlobeSyncSnapshot>,
}
impl GlobeSyncChannel {
    /// Create a new snapshot channel pair.
    pub fn new() -> Self {
        let (tx, rx) = channel();
        Self { tx, rx }
    }
}
/// Create a default snapshot channel pair.
impl Default for GlobeSyncChannel {
    /// Delegate to `GlobeSyncChannel::new`.
    fn default() -> Self {
        Self::new()
    }
}
/// Build a snapshot from the current globe state.
pub fn build_snapshot(globe: &Globe) -> GlobeSyncSnapshot {
    GlobeSyncSnapshot {
        name: globe.name.clone(),
        spec: globe.spec.clone(),
        camera: globe.camera.clone(),
        graph: globe.graph.clone(),
        regions: globe.regions.clone(),
        fog: globe.fog.clone(),
        markers: globe.markers.clone(),
        labels: globe.labels.clone(),
        layers: globe.layers.clone(),
        arcs: globe.arcs.clone(),
        arc_next_id: globe.arc_next_id,
        active_viewer: globe.active_viewer.clone(),
        heat_layers: globe.heat_layers.clone(),
        sectors: globe.sectors.clone(),
        reachability_cache: globe.reachability_cache.clone(),
        sim_time_sec: globe.sim_time_sec,
    }
}
/// Apply a snapshot to a mutable globe instance.
pub fn apply_snapshot(globe: &mut Globe, snap: &GlobeSyncSnapshot) {
    globe.name = snap.name.clone();
    globe.spec = snap.spec.clone();
    globe.camera = snap.camera.clone();
    globe.camera.clamp();
    globe.graph = snap.graph.clone();
    globe.regions = snap.regions.clone();
    globe.fog = snap.fog.clone();
    globe.markers = snap.markers.clone();
    globe.labels = snap.labels.clone();
    globe.layers = snap.layers.clone();
    globe.arcs = snap.arcs.clone();
    globe.arc_next_id = snap.arc_next_id;
    globe.active_viewer = snap.active_viewer.clone();
    globe.heat_layers = snap.heat_layers.clone();
    globe.sectors = snap.sectors.clone();
    globe.reachability_cache = snap.reachability_cache.clone();
    globe.sim_time_sec = snap.sim_time_sec;
}
