//! Owns the mutable globe runtime state that aggregates topology, semantic regions, fog, overlays, camera, and arcs.
//! Stores markers, labels, layers, heat layers, sectors, viewer selection, and reachability cache beside globe spec.
//! Provides mutation and lookup APIs for regions and provinces, plus picking, dragging, marker queries, and frame emit.
//! Acts as the integration boundary where projection, picking, draw emission, and gameplay-facing globe state meet.
//! Also advances simulation time and auto-rotation, keeping temporal globe behavior close to the authoritative store.
//! This file matters when globe state semantics, sector grouping, or cached reachability rules need coordinated edits.
//! Open this owner when multiple globe features drift together, because it is the main state hub for the subsystem.

use crate::globe::draw::emit_globe_frame;
use crate::globe::fog::FogStore;
use crate::globe::label::LabelStore;
use crate::globe::layer::LayerStore;
use crate::globe::marker::MarkerStore;
use crate::globe::picking::{pick, point_in_geo_region, screen_to_surface, PickResult, SurfaceHit};
use crate::globe::projection::{screen_delta_to_pan, OrbitCamera};
use crate::globe::sphere::great_circle_distance;
use crate::globe::topology::RegionGraph;
use crate::globe::types::{
    Arc as GlobeArc, GlobeError, GlobeSpec, HeatLayer, Region, RegionId, MAX_REGIONS,
};
use crate::render::renderer::RenderCommand;
use crate::runtime::resource_keys::FontKey;
use std::collections::{HashMap, HashSet};

#[inline]
fn wrap_lon_delta(delta: f32) -> f32 {
    ((delta + 180.0).rem_euclid(360.0)) - 180.0
}

/// Mutable globe state used by the renderer and sync layers.
#[derive(Debug, Default)]
pub struct Globe {
    /// Globe name used for lookup.
    pub name: String,
    /// Shared render and simulation parameters.
    pub spec: GlobeSpec,
    /// Orbit camera used for projection.
    pub camera: OrbitCamera,
    /// Province topology and cached adjacency.
    pub graph: RegionGraph,
    /// Base terrain polygon patches rendered before province and region overlays.
    pub terrain: HashMap<RegionId, Region>,
    /// Semantic regions that may overlap and do not participate in province rendering.
    pub regions: HashMap<RegionId, Region>,
    /// Fog state per viewer.
    pub fog: FogStore,
    /// Marker collection for the globe.
    pub markers: MarkerStore,
    /// Label collection for the globe.
    pub labels: LabelStore,
    /// Overlay layer collection.
    pub layers: LayerStore,
    /// Arc render data keyed by id.
    pub arcs: HashMap<u32, GlobeArc>,
    /// Next arc id to assign.
    pub arc_next_id: u32,
    /// Active viewer name used for fog lookups.
    pub active_viewer: Option<String>,
    /// Heat overlays currently applied to the globe.
    pub heat_layers: Vec<HeatLayer>,
    /// Region ids grouped by sector name.
    pub sectors: HashMap<String, HashSet<RegionId>>,
    /// Cached reachability per faction name.
    pub reachability_cache: HashMap<String, HashMap<RegionId, f64>>,
    /// Simulation time in seconds.
    pub sim_time_sec: f32,
}

/// Sampled terrain coverage report for a globe.
#[derive(Debug, Clone)]
pub struct TerrainCoverageReport {
    /// True when every sampled lat/lon point lands inside at least one terrain patch.
    pub ok: bool,
    /// Total sampled points.
    pub samples: usize,
    /// Sampled points covered by terrain.
    pub covered_samples: usize,
    /// Lat/lon points not covered by any terrain patch.
    pub gaps: Vec<(f32, f32)>,
}

impl Globe {
    /// Create a globe with the supplied name and spec.
    pub fn new(name: impl Into<String>, spec: GlobeSpec) -> Self {
        Self {
            name: name.into(),
            spec,
            ..Default::default()
        }
    }
    /// Insert a base terrain polygon patch or return TooManyRegions when storage is full.
    pub fn add_terrain_patch(&mut self, patch: Region) -> Result<(), GlobeError> {
        if self.terrain.len() >= MAX_REGIONS {
            return Err(GlobeError::TooManyRegions);
        }
        self.terrain.insert(patch.id, patch);
        Ok(())
    }
    /// Remove a terrain patch by id and return it when present.
    pub fn remove_terrain_patch(&mut self, id: RegionId) -> Option<Region> {
        self.terrain.remove(&id)
    }
    /// Return a shared terrain patch reference when the id exists.
    pub fn get_terrain_patch(&self, id: RegionId) -> Option<&Region> {
        self.terrain.get(&id)
    }
    /// Return a mutable terrain patch reference when the id exists.
    pub fn get_terrain_patch_mut(&mut self, id: RegionId) -> Option<&mut Region> {
        self.terrain.get_mut(&id)
    }
    /// Return the number of stored terrain patches.
    pub fn terrain_patch_count(&self) -> usize {
        self.terrain.len()
    }
    /// Validate terrain coverage by sampling equirectangular lat/lon cell centers.
    pub fn validate_terrain_coverage(
        &self,
        lat_step_deg: f32,
        lon_step_deg: f32,
    ) -> TerrainCoverageReport {
        let lat_step = lat_step_deg.max(0.001);
        let lon_step = lon_step_deg.max(0.001);
        let mut samples = 0_usize;
        let mut covered_samples = 0_usize;
        let mut gaps = Vec::new();
        let mut lat = -90.0 + lat_step * 0.5;
        while lat < 90.0 {
            let mut lon = -180.0 + lon_step * 0.5;
            while lon < 180.0 {
                samples += 1;
                if self
                    .terrain
                    .values()
                    .any(|patch| patch.visible && point_in_geo_region(patch, lat, lon))
                {
                    covered_samples += 1;
                } else {
                    gaps.push((lat, lon));
                }
                lon += lon_step;
            }
            lat += lat_step;
        }
        TerrainCoverageReport {
            ok: gaps.is_empty(),
            samples,
            covered_samples,
            gaps,
        }
    }
    /// Insert a region or return TooManyRegions when the graph is full.
    pub fn add_region(&mut self, region: Region) -> Result<(), GlobeError> {
        if self.regions.len() >= MAX_REGIONS {
            return Err(GlobeError::TooManyRegions);
        }
        self.regions.insert(region.id, region);
        Ok(())
    }
    /// Remove a region by id and return it when present.
    pub fn remove_region(&mut self, id: RegionId) -> Option<Region> {
        self.regions.remove(&id)
    }
    /// Return a shared region reference when the id exists.
    pub fn get_region(&self, id: RegionId) -> Option<&Region> {
        self.regions.get(&id)
    }
    /// Return a mutable region reference when the id exists.
    pub fn get_region_mut(&mut self, id: RegionId) -> Option<&mut Region> {
        self.regions.get_mut(&id)
    }
    /// Return the number of stored regions.
    pub fn region_count(&self) -> usize {
        self.regions.len()
    }
    /// Backward compatibility: insert a region.
    #[inline]
    pub fn add_province(&mut self, province: Region) -> Result<(), GlobeError> {
        if self.graph.len() >= MAX_REGIONS {
            return Err(GlobeError::TooManyRegions);
        }
        self.graph.insert(province)?;
        Ok(())
    }
    /// Backward compatibility: remove a region by id.
    #[inline]
    pub fn remove_province(&mut self, id: RegionId) -> Option<Region> {
        self.graph.remove(id)
    }
    /// Backward compatibility: get a region reference.
    #[inline]
    pub fn get_province(&self, id: RegionId) -> Option<&Region> {
        self.graph.get(id)
    }
    /// Backward compatibility: get a mutable region reference.
    #[inline]
    pub fn get_province_mut(&mut self, id: RegionId) -> Option<&mut Region> {
        self.graph.get_mut(id)
    }
    /// Backward compatibility: return region count.
    #[inline]
    pub fn province_count(&self) -> usize {
        self.graph.len()
    }
    /// Insert an arc and return its assigned id.
    pub fn add_arc(&mut self, arc: GlobeArc) -> u32 {
        let id = self.arc_next_id;
        self.arc_next_id += 1;
        self.arcs.insert(id, arc);
        id
    }
    /// Remove an arc by id and return true when it existed.
    pub fn remove_arc(&mut self, id: u32) -> bool {
        self.arcs.remove(&id).is_some()
    }
    /// Advance simulation time and update the globe clock and rotation.
    pub fn update(&mut self, dt: f32) {
        let speed = 1.0;
        self.spec.time_of_day = (self.spec.time_of_day + dt * speed / 3600.0).rem_euclid(24.0);
        self.spec.rotation_deg =
            (self.spec.rotation_deg + dt * self.spec.auto_rotation_deg_per_sec).rem_euclid(360.0);
        self.sim_time_sec += dt.max(0.0);
    }
    /// Resolve a front-hemisphere surface hit from screen coordinates.
    pub fn screen_to_surface(&self, sx: f32, sy: f32) -> Option<SurfaceHit> {
        screen_to_surface(sx, sy, &self.spec, &self.camera)
    }
    /// Apply a screen-space drag to the camera, anchoring to the visible surface when possible.
    pub fn apply_mouse_drag(&mut self, start_x: f32, start_y: f32, end_x: f32, end_y: f32) {
        if let (Some(start), Some(end)) = (
            self.screen_to_surface(start_x, start_y),
            self.screen_to_surface(end_x, end_y),
        ) {
            let dlat = end.lat_deg - start.lat_deg;
            let dlon = wrap_lon_delta(end.lon_deg - start.lon_deg);
            self.camera.pan(dlat, dlon);
            return;
        }
        let (dlat, dlon) =
            screen_delta_to_pan(end_x - start_x, end_y - start_y, &self.spec, &self.camera);
        self.camera.pan(dlat, dlon);
    }
    /// Pick a province at screen coordinates or return None when no province matches.
    pub fn pick_screen(&self, sx: f32, sy: f32) -> Option<PickResult> {
        pick(sx, sy, &self.spec, &self.camera, &self.graph)
    }
    /// Return all semantic region ids that contain the supplied surface position.
    pub fn regions_at_lat_lon(&self, lat_deg: f32, lon_deg: f32) -> Vec<RegionId> {
        self.regions
            .values()
            .filter(|region| {
                region.visible
                    && (point_in_geo_region(region, lat_deg, lon_deg)
                        || region.member_terrain_ids.iter().any(|id| {
                            self.terrain
                                .get(id)
                                .is_some_and(|patch| point_in_geo_region(patch, lat_deg, lon_deg))
                        }))
            })
            .map(|region| region.id)
            .collect()
    }
    /// Return all semantic region ids that contain the supplied screen-space hit.
    pub fn pick_regions_at_screen(&self, sx: f32, sy: f32) -> Vec<RegionId> {
        let Some(surface) = self.screen_to_surface(sx, sy) else {
            return Vec::new();
        };
        self.regions_at_lat_lon(surface.lat_deg, surface.lon_deg)
    }
    /// Pick the nearest visible marker under a screen position within a pixel radius.
    pub fn pick_marker_screen(&self, sx: f32, sy: f32, max_distance_px: f32) -> Option<u32> {
        let view = crate::globe::projection::build_view_matrix(&self.spec, &self.camera);
        let max_sq = max_distance_px.max(0.0).powi(2);
        let radius = self.spec.radius;
        let zoom = self.camera.zoom;
        let cx = self.camera.screen_cx;
        let cy = self.camera.screen_cy;
        let mut best: Option<(f32, u32)> = None;
        for marker in self.markers.iter_visible() {
            let Some(pos) = crate::globe::projection::project_point(
                marker.lat_deg,
                marker.lon_deg,
                &view,
                radius,
                zoom,
                cx,
                cy,
            ) else {
                continue;
            };
            let dx = pos.x - sx;
            let dy = pos.y - sy;
            let dist_sq = dx * dx + dy * dy;
            if dist_sq > max_sq {
                continue;
            }
            if best.as_ref().is_none_or(|(prev, _)| dist_sq < *prev) {
                best = Some((dist_sq, marker.id));
            }
        }
        best.map(|(_, id)| id)
    }
    /// Return great-circle distance between two markers on the unit sphere.
    pub fn marker_distance(&self, a: u32, b: u32) -> Option<f32> {
        let ma = self.markers.get(a)?;
        let mb = self.markers.get(b)?;
        Some(great_circle_distance(
            ma.lat_deg, ma.lon_deg, mb.lat_deg, mb.lon_deg,
        ))
    }
    /// Emit render commands for the current globe state.
    pub fn emit_frame(&self, default_font: Option<FontKey>) -> Vec<RenderCommand> {
        emit_globe_frame(
            &self.spec,
            &self.camera,
            &self.terrain,
            &self.graph,
            &self.regions,
            &self.fog,
            &self.markers,
            &self.labels,
            &self.layers,
            &self.heat_layers,
            &self.arcs,
            self.active_viewer.as_deref(),
            default_font,
            self.sim_time_sec,
        )
    }
    /// Add or replace a heat layer by name.
    pub fn set_heat_layer(&mut self, layer: HeatLayer) {
        if let Some(existing) = self.heat_layers.iter_mut().find(|l| l.name == layer.name) {
            *existing = layer;
            return;
        }
        self.heat_layers.push(layer);
    }
    /// Remove a heat layer by name and return true when one was removed.
    pub fn remove_heat_layer(&mut self, name: &str) -> bool {
        let before = self.heat_layers.len();
        self.heat_layers.retain(|l| l.name != name);
        self.heat_layers.len() != before
    }
    /// Assign a region to a named sector.
    pub fn set_region_sector(&mut self, id: RegionId, sector: impl Into<String>) {
        let sector = sector.into();
        for ids in self.sectors.values_mut() {
            ids.remove(&id);
        }
        self.sectors.entry(sector).or_default().insert(id);
    }
    /// Return the sector name that contains a region when one exists.
    pub fn region_sector(&self, id: RegionId) -> Option<&str> {
        self.sectors.iter().find_map(|(name, ids)| {
            if ids.contains(&id) {
                Some(name.as_str())
            } else {
                None
            }
        })
    }
    /// Return all region ids for a named sector.
    pub fn sector_regions(&self, sector: &str) -> Vec<RegionId> {
        self.sectors
            .get(sector)
            .map(|set| set.iter().copied().collect())
            .unwrap_or_default()
    }
    /// Backward compatibility: assign a region to a sector.
    #[inline]
    pub fn set_province_sector(&mut self, id: RegionId, sector: impl Into<String>) {
        self.set_region_sector(id, sector)
    }
    /// Backward compatibility: get sector for a region.
    #[inline]
    pub fn province_sector(&self, id: RegionId) -> Option<&str> {
        self.region_sector(id)
    }
    /// Backward compatibility: get region ids in a sector.
    #[inline]
    pub fn sector_provinces(&self, sector: &str) -> Vec<RegionId> {
        self.sector_regions(sector)
    }
    /// Cache default reachability for a faction name.
    pub fn cache_reachability_default(
        &mut self,
        faction: impl Into<String>,
        start: RegionId,
        max_cost: f64,
    ) {
        let map = self.graph.reachable_default(start, max_cost);
        self.reachability_cache.insert(faction.into(), map);
    }
    /// Return cached reachability for a faction when present.
    pub fn cached_reachability(&self, faction: &str) -> Option<&HashMap<RegionId, f64>> {
        self.reachability_cache.get(faction)
    }
}
/// Named globe registry keyed by globe name.
#[derive(Debug, Default)]
pub struct GlobeRegistry {
    /// Stored globes by name.
    globes: HashMap<String, Globe>,
}
impl GlobeRegistry {
    /// Create an empty globe registry.
    pub fn new() -> Self {
        Self::default()
    }
    /// Create or replace a globe and return a mutable reference to it.
    pub fn create(&mut self, name: impl Into<String>, spec: GlobeSpec) -> &mut Globe {
        let name = name.into();
        self.globes
            .insert(name.clone(), Globe::new(name.clone(), spec));
        self.globes.get_mut(&name).expect("just inserted")
    }
    /// Return a shared globe reference when the name exists.
    pub fn get(&self, name: &str) -> Option<&Globe> {
        self.globes.get(name)
    }
    /// Return a mutable globe reference when the name exists.
    pub fn get_mut(&mut self, name: &str) -> Option<&mut Globe> {
        self.globes.get_mut(name)
    }
    /// Remove a globe by name and return it when found.
    pub fn remove(&mut self, name: &str) -> Option<Globe> {
        self.globes.remove(name)
    }
    /// Return all globe names in arbitrary order.
    pub fn names(&self) -> Vec<String> {
        self.globes.keys().cloned().collect()
    }
    /// Return the number of stored globes.
    pub fn len(&self) -> usize {
        self.globes.len()
    }
    /// Return true when no globes are stored.
    pub fn is_empty(&self) -> bool {
        self.globes.is_empty()
    }
}
