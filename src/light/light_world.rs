//! Owns the light world owner for the light subsystem and keeps its rules local to this file.
//! Keeps light data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how light world data is validated, transformed, or stored before neighboring systems use it.
//! Owns light behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on light world behavior while Lua registration stays elsewhere.
//! Documents where light callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing light world defaults, lifecycle handling, validation, or data ownership.
//! Keeps failure paths and edge cases near the light state that can explain them while keeping call sites explicit.

use crate::color::Color;
use crate::light::attenuation::Attenuation;
use crate::light::blend_mode::LightBlendMode;
use crate::light::falloff::FalloffMode;
use crate::light::light2d::Light2D;
use crate::light::light_type::LightType;
use crate::light::occluder::Occluder;
use crate::light::shadow::ShadowFilter;
use crate::log_msg;
use crate::math::Vec2;
use crate::runtime::log_messages::{LW01_LIGHT_WORLD_INIT, LW02_LIGHT_ADD};
use crate::runtime::resource_keys::{LightKey, OccluderKey, ShaderKey};
use slotmap::SlotMap;

/// Scene-level container for all `Light2D` instances and `Occluder` shapes.
pub struct LightWorld {
    /// Slotmap of all registered lights, keyed by `LightKey`.
    pub lights: SlotMap<LightKey, Light2D>,
    /// Slotmap of all registered occluder shapes, keyed by `OccluderKey`.
    pub occluders: SlotMap<OccluderKey, Occluder>,
    /// Scene ambient base color added to all illuminated pixels.
    pub ambient: Color,
    /// Whether any light processing should run; set to `true` on first `add_light`.
    pub enabled: bool,
    /// Maximum number of active lights evaluated per frame by the renderer.
    pub max_lights: u16,
    /// Optional default custom light shader used when a light has no per-light shader.
    pub shader: Option<ShaderKey>,
    /// Cached list of keys for lights that have flicker enabled; rebuilt when `flicker_index_dirty`.
    flicker_keys: Vec<LightKey>,
    /// True when the flicker index is stale and must be rebuilt before next advance.
    flicker_index_dirty: bool,
}

/// Snapshot of a single light's normal-map binding used by the renderer for surface shading.
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

#[derive(Clone, Copy)]
struct RenderLight {
    x: f32,
    y: f32,
    radius: f32,
    color: Color,
    brightness: f32,
    blend_mode: LightBlendMode,
    falloff: FalloffMode,
    light_type: LightType,
    direction: f32,
    inner_angle: f32,
    outer_angle: f32,
    attenuation: Attenuation,
    shadow_enabled: bool,
    shadow_filter: ShadowFilter,
    shadow_smooth: f32,
    shadow_softness: f32,
    shadow_mask: u16,
}

struct RenderOccluder {
    vertices: Vec<Vec2>,
    opacity: f32,
    light_mask: u16,
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
            max_lights: 64,
            shader: None,
            flicker_keys: Vec::new(),
            flicker_index_dirty: true,
        }
    }
    /// Insert a light, enable the world if it was disabled, and return its key.
    pub fn add_light(&mut self, light: Light2D) -> LightKey {
        log_msg!(debug, LW02_LIGHT_ADD);
        if !self.enabled {
            self.enabled = true;
        }
        let key = self.lights.insert(light);
        self.flicker_index_dirty = true;
        key
    }
    /// Insert an occluder and return its key.
    pub fn add_occluder(&mut self, occluder: Occluder) -> OccluderKey {
        self.occluders.insert(occluder)
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
    /// Render an approximate light-map preview of this world into an `ImageData` debug image.
    pub fn draw_to_image(&self, width: u32, height: u32) -> crate::image::ImageData {
        let mut img = crate::image::ImageData::new(width, height);
        let ambient = [
            (self.ambient.r.clamp(0.0, 1.0) * 255.0).round(),
            (self.ambient.g.clamp(0.0, 1.0) * 255.0).round(),
            (self.ambient.b.clamp(0.0, 1.0) * 255.0).round(),
        ];
        img.fill(ambient[0] as u8, ambient[1] as u8, ambient[2] as u8, 255);
        if !self.enabled {
            return img;
        }

        let lights: Vec<RenderLight> = self
            .lights
            .values()
            .filter(|l| l.enabled && l.radius > 0.0 && l.intensity > 0.0 && l.energy > 0.0)
            .take(self.max_lights as usize)
            .map(|l| RenderLight {
                x: l.x,
                y: l.y,
                radius: l.radius,
                color: l.color,
                brightness: l.intensity * l.energy * l.flicker.multiplier(),
                blend_mode: l.blend_mode,
                falloff: l.falloff,
                light_type: l.light_type,
                direction: l.direction,
                inner_angle: l.inner_angle,
                outer_angle: l.outer_angle,
                attenuation: l.attenuation,
                shadow_enabled: l.shadow_enabled,
                shadow_filter: l.shadow_filter,
                shadow_smooth: l.shadow_smooth,
                shadow_softness: l.shadow_softness,
                shadow_mask: l.shadow_mask,
            })
            .collect();

        let occluders: Vec<RenderOccluder> = self
            .occluders
            .values()
            .filter(|occ| occ.enabled && occ.opacity > 0.0 && occ.vertices.len() >= 3)
            .map(|occ| RenderOccluder {
                vertices: occ
                    .vertices
                    .iter()
                    .map(|v| Vec2::new(v.x + occ.position.x, v.y + occ.position.y))
                    .collect(),
                opacity: occ.opacity.clamp(0.0, 1.0),
                light_mask: occ.light_mask,
            })
            .collect();

        if lights.is_empty() && occluders.is_empty() {
            return img;
        }
        for y in 0..height {
            for x in 0..width {
                let mut fr = ambient[0];
                let mut fg = ambient[1];
                let mut fb = ambient[2];
                let point = Vec2::new(x as f32 + 0.5, y as f32 + 0.5);
                for light in &lights {
                    let mut amount = light_intensity_at(light, point);
                    if amount <= 0.0 {
                        continue;
                    }
                    amount *= shadow_visibility(light, point, &occluders);
                    if amount <= 0.0 {
                        continue;
                    }
                    blend_light(&mut fr, &mut fg, &mut fb, light, amount);
                }
                img.set_pixel(
                    x,
                    y,
                    fr.clamp(0.0, 255.0) as u8,
                    fg.clamp(0.0, 255.0) as u8,
                    fb.clamp(0.0, 255.0) as u8,
                    255,
                );
            }
        }
        for occ in &occluders {
            for edge in occ.vertices.windows(2) {
                draw_occluder_edge(&mut img, edge[0], edge[1]);
            }
            if let (Some(first), Some(last)) = (occ.vertices.first(), occ.vertices.last()) {
                draw_occluder_edge(&mut img, *last, *first);
            }
        }
        for light in &lights {
            img.draw_circle(light.x as i32, light.y as i32, 4, 255, 240, 100, 255);
        }
        img
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
        self.lights
            .values()
            .filter(|l| l.enabled && l.light_type == LightType::Directional)
            .map(|l| (l.x, l.y, l.direction))
            .collect()
    }
    /// Return `NormalMapLightHint` snapshots for all enabled lights that have a normal map path.
    pub fn normal_map_light_hints(&self) -> Vec<NormalMapLightHint> {
        self.lights
            .values()
            .filter(|l| l.enabled)
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
            .collect()
    }
}

/// Delegates to `LightWorld::new`.
impl Default for LightWorld {
    fn default() -> Self {
        Self::new()
    }
}

fn light_intensity_at(light: &RenderLight, point: Vec2) -> f32 {
    let dx = point.x - light.x;
    let dy = point.y - light.y;
    let distance = (dx * dx + dy * dy).sqrt();
    let radial = match light.light_type {
        LightType::Directional => 1.0,
        LightType::Point | LightType::Spot => {
            if distance > light.radius {
                return 0.0;
            }
            radial_falloff(light.falloff, distance / light.radius)
        }
    };
    let angular = match light.light_type {
        LightType::Spot => spot_factor(
            light.direction,
            light.inner_angle,
            light.outer_angle,
            dx,
            dy,
        ),
        LightType::Point | LightType::Directional => 1.0,
    };
    radial * angular * light.attenuation.factor(distance) * light.brightness
}

fn radial_falloff(mode: FalloffMode, t: f32) -> f32 {
    let t = t.clamp(0.0, 1.0);
    match mode {
        FalloffMode::Linear => 1.0 - t,
        FalloffMode::Smooth => 1.0 - (t * t * (3.0 - 2.0 * t)),
        FalloffMode::Constant => 1.0,
    }
}

fn spot_factor(direction: f32, inner_angle: f32, outer_angle: f32, dx: f32, dy: f32) -> f32 {
    let angle = dy.atan2(dx);
    let diff = angle_delta(angle, direction).abs();
    let inner = inner_angle.max(0.0);
    let outer = outer_angle.max(inner + f32::EPSILON);
    if diff <= inner {
        1.0
    } else if diff >= outer {
        0.0
    } else {
        1.0 - ((diff - inner) / (outer - inner))
    }
}

fn angle_delta(a: f32, b: f32) -> f32 {
    let mut d = a - b;
    while d > std::f32::consts::PI {
        d -= std::f32::consts::TAU;
    }
    while d < -std::f32::consts::PI {
        d += std::f32::consts::TAU;
    }
    d
}

fn shadow_visibility(light: &RenderLight, point: Vec2, occluders: &[RenderOccluder]) -> f32 {
    if !light.shadow_enabled || occluders.is_empty() {
        return 1.0;
    }
    let offsets = shadow_sample_offsets(light.shadow_filter);
    let radius = match light.shadow_filter {
        ShadowFilter::None => 0.0,
        ShadowFilter::Pcf5 | ShadowFilter::Pcf13 => {
            (light.shadow_smooth * light.shadow_softness).max(0.0)
        }
    };
    let mut total = 0.0;
    for &(ox, oy) in offsets {
        let sample = Vec2::new(point.x + ox * radius, point.y + oy * radius);
        total += hard_shadow_visibility(light, sample, occluders);
    }
    total / offsets.len() as f32
}

fn shadow_sample_offsets(filter: ShadowFilter) -> &'static [(f32, f32)] {
    match filter {
        ShadowFilter::None => &[(0.0, 0.0)],
        ShadowFilter::Pcf5 => &[(0.0, 0.0), (1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)],
        ShadowFilter::Pcf13 => &[
            (0.0, 0.0),
            (1.0, 0.0),
            (-1.0, 0.0),
            (0.0, 1.0),
            (0.0, -1.0),
            (0.7, 0.7),
            (-0.7, 0.7),
            (0.7, -0.7),
            (-0.7, -0.7),
            (2.0, 0.0),
            (-2.0, 0.0),
            (0.0, 2.0),
            (0.0, -2.0),
        ],
    }
}

fn hard_shadow_visibility(light: &RenderLight, point: Vec2, occluders: &[RenderOccluder]) -> f32 {
    let origin = Vec2::new(light.x, light.y);
    let mut blocked = 0.0f32;
    for occ in occluders {
        if light.shadow_mask & occ.light_mask == 0 {
            continue;
        }
        if point_in_polygon(origin, &occ.vertices) {
            continue;
        }
        if point_in_polygon(point, &occ.vertices)
            || segment_hits_polygon(origin, point, &occ.vertices)
        {
            blocked = blocked.max(occ.opacity);
        }
    }
    1.0 - blocked.clamp(0.0, 1.0)
}

fn point_in_polygon(point: Vec2, vertices: &[Vec2]) -> bool {
    let mut inside = false;
    let mut j = vertices.len() - 1;
    for i in 0..vertices.len() {
        let vi = vertices[i];
        let vj = vertices[j];
        let crosses = (vi.y > point.y) != (vj.y > point.y);
        if crosses {
            let x_at_y = (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x;
            if point.x < x_at_y {
                inside = !inside;
            }
        }
        j = i;
    }
    inside
}

fn segment_hits_polygon(origin: Vec2, point: Vec2, vertices: &[Vec2]) -> bool {
    for i in 0..vertices.len() {
        let a = vertices[i];
        let b = vertices[(i + 1) % vertices.len()];
        if segments_intersect(origin, point, a, b) {
            return true;
        }
    }
    false
}

fn segments_intersect(a: Vec2, b: Vec2, c: Vec2, d: Vec2) -> bool {
    let r = Vec2::new(b.x - a.x, b.y - a.y);
    let s = Vec2::new(d.x - c.x, d.y - c.y);
    let denom = cross(r, s);
    if denom.abs() < 1e-5 {
        return false;
    }
    let cma = Vec2::new(c.x - a.x, c.y - a.y);
    let t = cross(cma, s) / denom;
    let u = cross(cma, r) / denom;
    t > 1e-4 && t < 1.0 - 1e-4 && (0.0..=1.0).contains(&u)
}

fn cross(a: Vec2, b: Vec2) -> f32 {
    a.x * b.y - a.y * b.x
}

fn blend_light(fr: &mut f32, fg: &mut f32, fb: &mut f32, light: &RenderLight, amount: f32) {
    let r = light.color.r.clamp(0.0, 1.0) * amount * 255.0;
    let g = light.color.g.clamp(0.0, 1.0) * amount * 255.0;
    let b = light.color.b.clamp(0.0, 1.0) * amount * 255.0;
    match light.blend_mode {
        LightBlendMode::Add => {
            *fr += r;
            *fg += g;
            *fb += b;
        }
        LightBlendMode::Sub => {
            *fr -= r;
            *fg -= g;
            *fb -= b;
        }
        LightBlendMode::Mix => {
            let alpha = amount.clamp(0.0, 1.0);
            *fr = *fr * (1.0 - alpha) + r * alpha;
            *fg = *fg * (1.0 - alpha) + g * alpha;
            *fb = *fb * (1.0 - alpha) + b * alpha;
        }
    }
}

fn draw_occluder_edge(img: &mut crate::image::ImageData, a: Vec2, b: Vec2) {
    img.draw_line(
        a.x.round() as i32,
        a.y.round() as i32,
        b.x.round() as i32,
        b.y.round() as i32,
        36,
        38,
        46,
        255,
    );
}
