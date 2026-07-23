//! Stores the scene's validated light and occluder state plus bounded render-facing snapshots.
//! GPU command submission and texture binding remain in `render`; this module only selects,
//! validates, and exposes data for those consumers. The CPU preview is a bounded debug helper.

use crate::color::Color;
use crate::light::light2d::Light2D;
use crate::light::light_type::LightType;
use crate::light::limits::LightLimits;
use crate::light::occluder::Occluder;
use crate::log_msg;
use crate::runtime::log_messages::{LW01_LIGHT_WORLD_INIT, LW02_LIGHT_ADD};
use crate::runtime::resource_keys::{LightKey, OccluderKey, ShaderKey};
use slotmap::SlotMap;

/// Scene-level container for all `Light2D` instances and `Occluder` shapes.
/// # Fields
pub struct LightWorld {
    /// Slotmap of all registered lights, keyed by `LightKey`.
    pub lights: SlotMap<LightKey, Light2D>,
    /// Slotmap of all registered occluder shapes, keyed by `OccluderKey`.
    pub occluders: SlotMap<OccluderKey, Occluder>,
    /// Scene ambient base color added to all illuminated pixels.
    pub ambient: Color,
    /// Whether any light processing should run; a first insertion enables it only before an explicit choice.
    pub enabled: bool,
    /// Records an explicit world enable choice so future insertion cannot override user intent.
    enabled_explicit: bool,
    /// Maximum number of active lights evaluated per frame by the renderer.
    pub max_lights: u16,
    /// Hard storage and preview ceilings for this world.
    pub limits: LightLimits,
    /// Optional default custom light shader used when a light has no per-light shader.
    pub shader: Option<ShaderKey>,
    /// Cached list of keys for lights that have flicker enabled; rebuilt when `flicker_index_dirty`.
    flicker_keys: Vec<LightKey>,
    /// True when the flicker index is stale and must be rebuilt before next advance.
    flicker_index_dirty: bool,
    /// Next monotonic insertion sequence for deterministic renderer selection.
    next_light_order: u64,
}

/// Snapshot of a single light's normal-map binding used by the renderer for surface shading.
/// # Fields
#[derive(Debug, Clone)]
pub struct NormalMapLightHint {
    /// World-space X of the contributing light.
    pub x: f32,
    /// World-space Y of the contributing light.
    pub y: f32,
    /// Effective radius of the contributing light.
    pub radius: f32,
    /// Intensity of the contributing light.
    pub intensity: f32,
    /// Direction angle in radians for spot lights.
    pub direction: f32,
    /// Path to the normal map texture asset.
    pub path: String,
    /// Normal map contribution strength in [0.0, 1.0].
    pub strength: f32,
}

/// Summary of one renderer-light selection pass.
/// # Fields
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct LightSelectionDiagnostics {
    /// Number of registered lights selected for rendering.
    pub selected_count: usize,
    /// Eligible lights omitted only because `max_lights` was reached.
    pub rejected_by_limit: usize,
    /// Registered lights disabled by their authored enabled flag.
    pub rejected_disabled: usize,
    /// Registered lights rejected because direct Rust mutation made their render state invalid.
    pub rejected_invalid: usize,
    /// Registered lights with zero energy, which cannot contribute to rendering.
    pub rejected_zero_energy: usize,
}

impl LightWorld {
    /// Create an empty world with ambient=0.1, disabled, and max_lights=64.
    pub fn new() -> Self {
        log_msg!(trace, LW01_LIGHT_WORLD_INIT);
        Self {
            lights: SlotMap::with_key(),
            occluders: SlotMap::with_key(),
            ambient: Color::new(0.1, 0.1, 0.1, 1.0),
            enabled: false,
            enabled_explicit: false,
            max_lights: 64,
            limits: LightLimits::default(),
            shader: None,
            flicker_keys: Vec::new(),
            flicker_index_dirty: true,
            next_light_order: 0,
        }
    }
    /// Insert a light when the registered-light ceiling permits it.
    pub fn add_light(&mut self, mut light: Light2D) -> Result<LightKey, String> {
        if !light.is_render_valid() {
            return Err("lurek.light.newLight: light state must be finite and valid".to_string());
        }
        if self.lights.len() >= self.limits.max_registered_lights {
            return Err(format!(
                "lurek.light.newLight: registered light limit {} reached",
                self.limits.max_registered_lights
            ));
        }
        log_msg!(debug, LW02_LIGHT_ADD);
        if !self.enabled && !self.enabled_explicit {
            self.enabled = true;
        }
        light.insertion_order = self.next_light_order;
        self.next_light_order = self.next_light_order.saturating_add(1);
        let key = self.lights.insert(light);
        self.flicker_index_dirty = true;
        Ok(key)
    }
    /// Insert a light only when the registered-light ceiling permits it.
    pub fn try_add_light(&mut self, light: Light2D) -> Result<LightKey, String> {
        self.add_light(light)
    }
    /// Insert an occluder when all storage ceilings permit it.
    pub fn add_occluder(&mut self, occluder: Occluder) -> Result<OccluderKey, String> {
        if !occluder.is_render_valid() {
            return Err(
                "lurek.light.newOccluder: occluder state must be finite and valid".to_string(),
            );
        }
        if self.occluders.len() >= self.limits.max_registered_occluders {
            return Err(format!(
                "lurek.light.newOccluder: registered occluder limit {} reached",
                self.limits.max_registered_occluders
            ));
        }
        if occluder.vertices.len() > self.limits.max_vertices_per_occluder {
            return Err(format!(
                "lurek.light.newOccluder: vertex limit {} exceeded",
                self.limits.max_vertices_per_occluder
            ));
        }
        let total = self
            .occluders
            .values()
            .map(|item| item.vertices.len())
            .sum::<usize>();
        if total.saturating_add(occluder.vertices.len()) > self.limits.max_total_occluder_vertices {
            return Err(format!(
                "lurek.light.newOccluder: total occluder vertex limit {} reached",
                self.limits.max_total_occluder_vertices
            ));
        }
        Ok(self.occluders.insert(occluder))
    }
    /// Insert an occluder only when count and aggregate-vertex ceilings permit it.
    pub fn try_add_occluder(&mut self, occluder: Occluder) -> Result<OccluderKey, String> {
        self.add_occluder(occluder)
    }
    /// Remove a light by key and evict it from the flicker index; returns the removed light or `None`.
    pub fn remove_light(&mut self, key: LightKey) -> Option<Light2D> {
        self.flicker_keys.retain(|k| *k != key);
        self.lights.remove(key)
    }
    /// Remove an occluder by key; returns the removed occluder or `None`.
    pub fn remove_occluder(&mut self, key: OccluderKey) -> Option<Occluder> {
        self.occluders.remove(key)
    }
    /// Return a shared reference to the light at `key`, or `None` if not present.
    pub fn get_light(&self, key: LightKey) -> Option<&Light2D> {
        self.lights.get(key)
    }
    /// Return a mutable reference to the light at `key`, or `None` if not present.
    pub fn get_light_mut(&mut self, key: LightKey) -> Option<&mut Light2D> {
        self.flicker_index_dirty = true;
        self.lights.get_mut(key)
    }
    /// Return a shared reference to the occluder at `key`, or `None` if not present.
    pub fn get_occluder(&self, key: OccluderKey) -> Option<&Occluder> {
        self.occluders.get(key)
    }
    /// Return a mutable reference to the occluder at `key`, or `None` if not present.
    pub fn get_occluder_mut(&mut self, key: OccluderKey) -> Option<&mut Occluder> {
        self.occluders.get_mut(key)
    }
    /// Return the number of registered lights.
    pub fn light_count(&self) -> usize {
        self.lights.len()
    }
    /// Set world processing state explicitly; later insertions preserve this choice.
    pub fn set_enabled(&mut self, enabled: bool) {
        self.enabled = enabled;
        self.enabled_explicit = true;
    }
    /// Return the number of registered occluders.
    pub fn occluder_count(&self) -> usize {
        self.occluders.len()
    }
    /// Remove all lights and occluders and reset ambient to 0.1 gray.
    pub fn clear(&mut self) {
        self.lights.clear();
        self.occluders.clear();
        self.ambient = Color::new(0.1, 0.1, 0.1, 1.0);
        self.flicker_keys.clear();
        self.flicker_index_dirty = false;
        self.next_light_order = 0;
    }
    /// Return `true` if any registered light has `enabled = true`.
    pub fn has_active_lights(&self) -> bool {
        self.lights.values().any(|l| l.enabled)
    }
    /// Set `enabled` on all lights in `group_id`.
    pub fn set_group_enabled(&mut self, group_id: u16, enabled: bool) {
        for light in self.lights.values_mut() {
            if light.group_id == group_id {
                light.enabled = enabled;
            }
        }
    }
    /// Set `intensity` on all lights in `group_id`.
    pub fn set_group_intensity(&mut self, group_id: u16, intensity: f32) {
        for light in self.lights.values_mut() {
            if light.group_id == group_id {
                light.intensity = intensity;
            }
        }
    }
    /// Set `color` on all lights in `group_id`.
    pub fn set_group_color(&mut self, group_id: u16, color: Color) {
        for light in self.lights.values_mut() {
            if light.group_id == group_id {
                light.color = color;
            }
        }
    }
    /// Return the count of lights in `group_id`.
    pub fn group_count(&self, group_id: u16) -> usize {
        self.lights
            .values()
            .filter(|l| l.group_id == group_id)
            .count()
    }
    /// Advance all flickering lights by `dt` seconds; rebuilds the flicker index if stale.
    pub fn advance_flickers(&mut self, dt: f32) {
        if self.flicker_index_dirty {
            self.reindex_flickers();
        }
        let mut stale = false;
        for key in self.flicker_keys.iter().copied() {
            if let Some(light) = self.lights.get_mut(key) {
                if light.flicker.enabled {
                    light.flicker.advance(dt);
                }
            } else {
                stale = true;
            }
        }
        if stale {
            self.flicker_keys.retain(|k| self.lights.contains_key(*k));
        }
    }
    /// Rebuild the flicker key index from all lights that have flicker enabled.
    pub fn reindex_flickers(&mut self) {
        self.flicker_keys.clear();
        for (key, light) in self.lights.iter() {
            if light.flicker.enabled {
                self.flicker_keys.push(key);
            }
        }
        self.flicker_index_dirty = false;
    }
    /// Return eligible render lights ordered by priority descending then stable insertion order.
    pub fn selected_render_lights(&self) -> Vec<(LightKey, &Light2D)> {
        let mut selected: Vec<_> = self
            .lights
            .iter()
            .filter(|(_, light)| light.enabled && light.is_render_valid() && light.energy > 0.0)
            .collect();
        selected.sort_by(|(_, left), (_, right)| {
            right
                .priority
                .cmp(&left.priority)
                .then_with(|| left.insertion_order.cmp(&right.insertion_order))
        });
        selected.truncate(self.max_lights as usize);
        selected
    }
    /// Return bounded renderer-selection counts without exposing renderer internals.
    pub fn selection_diagnostics(&self) -> LightSelectionDiagnostics {
        let mut diagnostics = LightSelectionDiagnostics::default();
        let mut eligible = 0usize;
        for light in self.lights.values() {
            if !light.enabled {
                diagnostics.rejected_disabled = diagnostics.rejected_disabled.saturating_add(1);
            } else if !light.is_render_valid() {
                diagnostics.rejected_invalid = diagnostics.rejected_invalid.saturating_add(1);
            } else if light.energy <= 0.0 {
                diagnostics.rejected_zero_energy =
                    diagnostics.rejected_zero_energy.saturating_add(1);
            } else {
                eligible = eligible.saturating_add(1);
            }
        }
        diagnostics.selected_count = eligible.min(self.max_lights as usize);
        diagnostics.rejected_by_limit = eligible.saturating_sub(diagnostics.selected_count);
        diagnostics
    }
    /// Render an approximate light-map preview after validating bounded preview cost.
    pub fn draw_to_image(
        &self,
        width: u32,
        height: u32,
    ) -> Result<crate::image::ImageData, String> {
        self.validate_preview_cost(width, height)?;
        Ok(self.draw_to_image_unchecked(width, height))
    }

    /// Render the already-validated preview. Kept private so all public callers enforce limits.
    fn draw_to_image_unchecked(&self, width: u32, height: u32) -> crate::image::ImageData {
        crate::light::debug_image::draw(self, width, height)
    }
    /// Validate all debug-preview costs before allocating its image buffer.
    pub fn try_draw_to_image(
        &self,
        width: u32,
        height: u32,
    ) -> Result<crate::image::ImageData, String> {
        self.draw_to_image(width, height)
    }

    fn validate_preview_cost(&self, width: u32, height: u32) -> Result<(), String> {
        let selected = self.selected_render_lights();
        let direct_light_samples = selected.len();
        let shadow_edge_samples = selected
            .iter()
            .filter(|(_, light)| light.shadow_enabled)
            .map(|(_, light)| match light.shadow_filter {
                crate::light::ShadowFilter::None => 1,
                crate::light::ShadowFilter::Pcf5 => 5,
                crate::light::ShadowFilter::Pcf13 => 13,
            })
            .sum();
        let edges = self
            .occluders
            .values()
            .filter(|o| o.enabled)
            .map(|o| o.vertices.len())
            .sum();
        self.limits.check_preview(
            width,
            height,
            direct_light_samples,
            edges,
            shadow_edge_samples,
        )
    }
    /// Return ambient color as an RGBA `[f32; 4]` array for shader upload.
    pub fn ambient_color_hint(&self) -> [f32; 4] {
        [
            self.ambient.r,
            self.ambient.g,
            self.ambient.b,
            self.ambient.a,
        ]
    }
    /// Return `(x, y, direction)` tuples for all enabled directional lights.
    pub fn directional_light_hints(&self) -> Vec<(f32, f32, f32)> {
        let mut hints = Vec::with_capacity(self.limits.max_hint_exports.min(self.lights.len()));
        self.write_directional_light_hints(&mut hints);
        hints
    }
    /// Write at most the configured storage ceiling of directional hints into caller-owned storage.
    pub fn write_directional_light_hints(&self, output: &mut Vec<(f32, f32, f32)>) {
        output.clear();
        output.reserve(self.limits.max_hint_exports.min(self.lights.len()));
        output.extend(
            self.lights
                .values()
                .filter(|light| light.enabled && light.light_type == LightType::Directional)
                .take(self.limits.max_hint_exports)
                .map(|light| (light.x, light.y, light.direction)),
        );
    }
    /// Return `NormalMapLightHint` snapshots for all enabled lights that have a normal map path.
    pub fn normal_map_light_hints(&self) -> Vec<NormalMapLightHint> {
        let mut hints = Vec::with_capacity(self.limits.max_hint_exports.min(self.lights.len()));
        self.write_normal_map_light_hints(&mut hints);
        hints
    }
    /// Write bounded normal-map hint snapshots into caller-owned storage.
    pub fn write_normal_map_light_hints(&self, output: &mut Vec<NormalMapLightHint>) {
        output.clear();
        output.reserve(self.limits.max_hint_exports.min(self.lights.len()));
        output.extend(
            self.lights
                .values()
                .filter(|light| light.enabled)
                .filter_map(|l| {
                    l.get_normal_map_path().map(|path| NormalMapLightHint {
                        x: l.x,
                        y: l.y,
                        radius: l.radius,
                        intensity: l.intensity,
                        direction: l.direction,
                        path: path.to_string(),
                        strength: l.normal_strength,
                    })
                })
                .take(self.limits.max_hint_exports),
        );
    }
}

/// Delegates to `LightWorld::new`.
impl Default for LightWorld {
    fn default() -> Self {
        Self::new()
    }
}
