//! This file owns map behavior inside the tilelight subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate map state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for map work.
//! Serialization, indexing, and boundary checks stay here when they depend on map internals. It keeps maintenance boundari.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when map ownership changes, but keep unrelated subsystem policy in sibling modules.
//! The code favors small data transformations so examples, specs, and tests can assert behavior directly.
//! Stateful changes are kept deterministic here so generated docs and smoke tests remain reproducible.
//! Cross-module dependencies are intentionally narrow, with shared types imported only at this boundary.

use crate::tilefield::line::visit_line_cells;
use crate::tilefield::{CellCoord, TileField, TileTopology};
use crate::tilelight::{
    AreaLight, AreaLightUpdate, LightColor, LightModulation, LineLight, LineLightUpdate,
    PointLight, PointLightUpdate, SunLight, SunLightMode, TileLightLimits,
};

/// Validated options shared by full and dirty tilelight computation.
///
/// # Fields
///
/// Include flags select source families, `ambient` optionally overrides the
/// map setting, and `time_seconds` is the finite modulation clock in seconds.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ComputeOptions {
    /// Include explicit point lights and authored tilefield emitters.
    pub include_point_lights: bool,
    /// Include line lights.
    pub include_line_lights: bool,
    /// Include rectangular area lights.
    pub include_area_lights: bool,
    /// Include the configured sun light.
    pub include_sun_light: bool,
    /// Optional ambient override; `None` uses the map setting.
    pub ambient: Option<LightColor>,
    /// Elapsed time in seconds used by source modulation.
    pub time_seconds: f32,
}

impl Default for ComputeOptions {
    fn default() -> Self {
        Self {
            include_point_lights: true,
            include_line_lights: true,
            include_area_lights: true,
            include_sun_light: true,
            ambient: None,
            time_seconds: 0.0,
        }
    }
}

/// Computed tile light values and runtime source state for one tilefield volume.
///
/// # Fields
///
/// Dense output is bounded by [`TileLightLimits`]. Runtime sources are compact
/// vectors with monotonically allocated ids. `computed_field_version` and
/// `computed_source_version` identify the exact inputs represented by output;
/// a changed field or source set makes the output stale until the next compute.
#[derive(Debug, Clone)]
pub struct TileLightMap {
    width: u32,
    height: u32,
    levels: u32,
    topology: TileTopology,
    point_lights: Vec<PointLight>,
    line_lights: Vec<LineLight>,
    area_lights: Vec<AreaLight>,
    next_light_id: u32,
    limits: TileLightLimits,
    ambient_light: LightColor,
    sun_light: SunLight,
    light_values: Vec<LightColor>,
    source_version: u64,
    computed_field_version: Option<u64>,
    computed_source_version: u64,
    computed_options: Option<ComputeOptions>,
    last_affected_cells: usize,
    last_compute_work: u64,
}

impl TileLightMap {
    /// Create light storage matching a tilefield-sized volume.
    pub fn new(
        width: u32,
        height: u32,
        levels: u32,
        topology: TileTopology,
    ) -> Result<Self, String> {
        Self::new_with_limits(width, height, levels, topology, TileLightLimits::default())
    }

    /// Create light storage with explicit allocation, source, and work ceilings.
    pub fn new_with_limits(
        width: u32,
        height: u32,
        levels: u32,
        topology: TileTopology,
        limits: TileLightLimits,
    ) -> Result<Self, String> {
        if width == 0 || height == 0 || levels == 0 {
            return Err("tilelight dimensions and levels must be > 0".to_string());
        }
        let len = limits.checked_volume_cells(width, height, levels)?;
        Ok(Self {
            width,
            height,
            levels,
            topology,
            point_lights: Vec::new(),
            line_lights: Vec::new(),
            area_lights: Vec::new(),
            next_light_id: 1,
            limits,
            ambient_light: LightColor::BLACK,
            sun_light: SunLight::default(),
            light_values: vec![LightColor::BLACK; len],
            source_version: 0,
            computed_field_version: None,
            computed_source_version: 0,
            computed_options: None,
            last_affected_cells: 0,
            last_compute_work: 0,
        })
    }

    /// Create light storage with the same dimensions and topology as a field.
    pub fn from_field(field: &TileField) -> Result<Self, String> {
        let (width, height, levels) = field.size();
        Self::new(width, height, levels, field.topology())
    }

    /// Return the active tilelight limits.
    pub fn limits(&self) -> TileLightLimits {
        self.limits
    }

    /// Return light-map dimensions.
    pub fn size(&self) -> (u32, u32, u32) {
        (self.width, self.height, self.levels)
    }

    /// Return true when the light map matches the field dimensions and topology.
    pub fn matches_field(&self, field: &TileField) -> bool {
        let (width, height, levels) = field.size();
        width == self.width
            && height == self.height
            && levels == self.levels
            && field.topology() == self.topology
    }

    fn index(&self, coord: CellCoord) -> Option<usize> {
        if coord.x >= self.width || coord.y >= self.height || coord.z >= self.levels {
            return None;
        }
        coord
            .z
            .checked_mul(self.width * self.height)
            .and_then(|base| base.checked_add(coord.y * self.width + coord.x))
            .and_then(|idx| usize::try_from(idx).ok())
    }

    /// Add a point light and return its stable id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_point_light(
        &mut self,
        field: &TileField,
        x: u32,
        y: u32,
        z: u32,
        radius: f32,
        intensity: f32,
        color: LightColor,
        modulation: LightModulation,
    ) -> Result<u32, String> {
        self.ensure_matches_field(field)?;
        let coord = CellCoord { x, y, z };
        if !field.in_bounds(coord) {
            return Err("tilelight addPointLight coordinate is out of bounds".to_string());
        }
        self.validate_point_source(coord, radius, intensity, color, modulation, "addPointLight")?;
        if self.point_lights.len() >= self.limits.max_point_lights {
            return Err(format!(
                "tilelight addPointLight source limit {} exceeded",
                self.limits.max_point_lights
            ));
        }
        let id = self.allocate_light_id("addPointLight")?;
        self.point_lights.push(PointLight {
            id,
            x,
            y,
            z,
            radius,
            intensity,
            color: color.clamped(),
            modulation,
        });
        self.mark_source_dirty();
        Ok(id)
    }

    /// Update an existing point light.
    pub fn update_point_light(
        &mut self,
        field: &TileField,
        id: u32,
        patch: PointLightUpdate,
    ) -> Result<(), String> {
        self.ensure_matches_field(field)?;
        let index = self
            .point_lights
            .iter()
            .position(|light| light.id == id)
            .ok_or_else(|| format!("tilelight point light id {id} does not exist"))?;
        let light = self.point_lights[index].clone();
        let next_x = patch.x.unwrap_or(light.x);
        let next_y = patch.y.unwrap_or(light.y);
        let next_z = patch.z.unwrap_or(light.z);
        let next_radius = patch.radius.unwrap_or(light.radius);
        let next_intensity = patch.intensity.unwrap_or(light.intensity);
        let next_color = patch.color.unwrap_or(light.color);
        let next_modulation = patch.modulation.unwrap_or(light.modulation);
        if !field.in_bounds(CellCoord {
            x: next_x,
            y: next_y,
            z: next_z,
        }) {
            return Err("tilelight updatePointLight coordinate is out of bounds".to_string());
        }
        self.validate_point_source(
            CellCoord {
                x: next_x,
                y: next_y,
                z: next_z,
            },
            next_radius,
            next_intensity,
            next_color,
            next_modulation,
            "updatePointLight",
        )?;
        self.point_lights[index] = PointLight {
            id: light.id,
            x: next_x,
            y: next_y,
            z: next_z,
            radius: next_radius,
            intensity: next_intensity,
            color: next_color.clamped(),
            modulation: next_modulation,
        };
        self.mark_source_dirty();
        Ok(())
    }

    /// Remove a point light by id. Returns true when a light was removed.
    pub fn remove_point_light(&mut self, id: u32) -> bool {
        if let Some(index) = self.point_lights.iter().position(|light| light.id == id) {
            self.point_lights.remove(index);
            self.mark_source_dirty();
            return true;
        }
        false
    }

    /// Remove all point lights.
    pub fn clear_point_lights(&mut self) {
        if !self.point_lights.is_empty() {
            self.point_lights.clear();
            self.mark_source_dirty();
        }
    }

    /// Add a line light and return its stable id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_line_light(
        &mut self,
        field: &TileField,
        start: CellCoord,
        end: CellCoord,
        radius: f32,
        intensity: f32,
        color: LightColor,
        modulation: LightModulation,
    ) -> Result<u32, String> {
        self.ensure_matches_field(field)?;
        if !field.in_bounds(start) || !field.in_bounds(end) {
            return Err("tilelight addLineLight coordinate is out of bounds".to_string());
        }
        if start.z != end.z {
            return Err("tilelight line lights must stay on one tilefield level".to_string());
        }
        self.validate_line_source(
            field,
            start,
            end,
            radius,
            intensity,
            color,
            modulation,
            "addLineLight",
        )?;
        if self.line_lights.len() >= self.limits.max_line_lights {
            return Err(format!(
                "tilelight addLineLight source limit {} exceeded",
                self.limits.max_line_lights
            ));
        }
        let id = self.allocate_light_id("addLineLight")?;
        self.line_lights.push(LineLight {
            id,
            x1: start.x,
            y1: start.y,
            z1: start.z,
            x2: end.x,
            y2: end.y,
            z2: end.z,
            radius,
            intensity,
            color: color.clamped(),
            modulation,
        });
        self.mark_source_dirty();
        Ok(id)
    }

    /// Update an existing line light.
    pub fn update_line_light(
        &mut self,
        field: &TileField,
        id: u32,
        patch: LineLightUpdate,
    ) -> Result<(), String> {
        self.ensure_matches_field(field)?;
        let index = self
            .line_lights
            .iter()
            .position(|light| light.id == id)
            .ok_or_else(|| format!("tilelight line light id {id} does not exist"))?;
        let light = self.line_lights[index].clone();
        let start = CellCoord {
            x: patch.x1.unwrap_or(light.x1),
            y: patch.y1.unwrap_or(light.y1),
            z: patch.z1.unwrap_or(light.z1),
        };
        let end = CellCoord {
            x: patch.x2.unwrap_or(light.x2),
            y: patch.y2.unwrap_or(light.y2),
            z: patch.z2.unwrap_or(light.z2),
        };
        if !field.in_bounds(start) || !field.in_bounds(end) {
            return Err("tilelight updateLineLight coordinate is out of bounds".to_string());
        }
        if start.z != end.z {
            return Err("tilelight line lights must stay on one tilefield level".to_string());
        }
        let next_radius = patch.radius.unwrap_or(light.radius);
        let next_intensity = patch.intensity.unwrap_or(light.intensity);
        let next_color = patch.color.unwrap_or(light.color);
        let next_modulation = patch.modulation.unwrap_or(light.modulation);
        self.validate_line_source(
            field,
            start,
            end,
            next_radius,
            next_intensity,
            next_color,
            next_modulation,
            "updateLineLight",
        )?;
        self.line_lights[index] = LineLight {
            id: light.id,
            x1: start.x,
            y1: start.y,
            z1: start.z,
            x2: end.x,
            y2: end.y,
            z2: end.z,
            radius: next_radius,
            intensity: next_intensity,
            color: next_color.clamped(),
            modulation: next_modulation,
        };
        self.mark_source_dirty();
        Ok(())
    }

    /// Remove a line light by id. Returns true when a light was removed.
    pub fn remove_line_light(&mut self, id: u32) -> bool {
        if let Some(index) = self.line_lights.iter().position(|light| light.id == id) {
            self.line_lights.remove(index);
            self.mark_source_dirty();
            return true;
        }
        false
    }

    /// Remove all line lights.
    pub fn clear_line_lights(&mut self) {
        if !self.line_lights.is_empty() {
            self.line_lights.clear();
            self.mark_source_dirty();
        }
    }

    /// Add a rectangular area light and return its stable id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_area_light(
        &mut self,
        field: &TileField,
        origin: CellCoord,
        width: u32,
        height: u32,
        radius: f32,
        intensity: f32,
        color: LightColor,
        modulation: LightModulation,
    ) -> Result<u32, String> {
        self.ensure_matches_field(field)?;
        self.validate_area_light(
            field,
            origin,
            width,
            height,
            radius,
            intensity,
            "addAreaLight",
        )?;
        self.validate_color_and_modulation(color, modulation, "addAreaLight")?;
        if self.area_lights.len() >= self.limits.max_area_lights {
            return Err(format!(
                "tilelight addAreaLight source limit {} exceeded",
                self.limits.max_area_lights
            ));
        }
        let id = self.allocate_light_id("addAreaLight")?;
        self.area_lights.push(AreaLight {
            id,
            x: origin.x,
            y: origin.y,
            z: origin.z,
            width,
            height,
            radius,
            intensity,
            color: color.clamped(),
            modulation,
        });
        self.mark_source_dirty();
        Ok(id)
    }

    /// Update an existing rectangular area light.
    pub fn update_area_light(
        &mut self,
        field: &TileField,
        id: u32,
        patch: AreaLightUpdate,
    ) -> Result<(), String> {
        self.ensure_matches_field(field)?;
        let index = self
            .area_lights
            .iter()
            .position(|light| light.id == id)
            .ok_or_else(|| format!("tilelight area light id {id} does not exist"))?;
        let light = self.area_lights[index].clone();
        let origin = CellCoord {
            x: patch.x.unwrap_or(light.x),
            y: patch.y.unwrap_or(light.y),
            z: patch.z.unwrap_or(light.z),
        };
        let width = patch.width.unwrap_or(light.width);
        let height = patch.height.unwrap_or(light.height);
        let radius = patch.radius.unwrap_or(light.radius);
        let intensity = patch.intensity.unwrap_or(light.intensity);
        self.validate_area_light(
            field,
            origin,
            width,
            height,
            radius,
            intensity,
            "updateAreaLight",
        )?;
        let color = patch.color.unwrap_or(light.color);
        let modulation = patch.modulation.unwrap_or(light.modulation);
        self.validate_color_and_modulation(color, modulation, "updateAreaLight")?;
        self.area_lights[index] = AreaLight {
            id: light.id,
            x: origin.x,
            y: origin.y,
            z: origin.z,
            width,
            height,
            radius,
            intensity,
            color: color.clamped(),
            modulation,
        };
        self.mark_source_dirty();
        Ok(())
    }

    /// Remove a rectangular area light by id. Returns true when a light was removed.
    pub fn remove_area_light(&mut self, id: u32) -> bool {
        if let Some(index) = self.area_lights.iter().position(|light| light.id == id) {
            self.area_lights.remove(index);
            self.mark_source_dirty();
            return true;
        }
        false
    }

    /// Remove all rectangular area lights.
    pub fn clear_area_lights(&mut self) {
        if !self.area_lights.is_empty() {
            self.area_lights.clear();
            self.mark_source_dirty();
        }
    }

    /// Set ambient light stored on this light map.
    pub fn set_ambient_light(&mut self, ambient: LightColor) {
        let _ = self.try_set_ambient_light(ambient);
    }

    /// Validate and set ambient light, returning the exact domain error.
    pub fn try_set_ambient_light(&mut self, ambient: LightColor) -> Result<(), String> {
        ambient.validate("setAmbient")?;
        self.ambient_light = ambient;
        self.mark_source_dirty();
        Ok(())
    }

    /// Set sun light.
    pub fn set_sun_light(&mut self, sun: SunLight) {
        let _ = self.try_set_sun_light(sun);
    }

    /// Validate and set sun light, returning the exact domain error.
    pub fn try_set_sun_light(&mut self, sun: SunLight) -> Result<(), String> {
        if !sun.intensity.is_finite() || sun.intensity < 0.0 {
            return Err("tilelight setSunLight intensity must be finite and >= 0".to_string());
        }
        sun.color.validate("setSunLight")?;
        self.sun_light = sun;
        self.mark_source_dirty();
        Ok(())
    }

    /// Return whether output is absent or no longer represents current inputs.
    pub fn is_dirty(&self, field: &TileField) -> bool {
        self.computed_field_version != Some(field.version())
            || self.computed_source_version != self.source_version
    }

    /// Return the field version represented by the last successful compute.
    pub fn computed_field_version(&self) -> Option<u64> {
        self.computed_field_version
    }

    /// Return the runtime source version used by the last successful compute.
    pub fn computed_source_version(&self) -> u64 {
        self.computed_source_version
    }

    /// Return the number of cells affected by the last successful compute.
    pub fn last_affected_cells(&self) -> usize {
        self.last_affected_cells
    }

    /// Return the estimated work consumed by the last successful compute.
    pub fn last_compute_work(&self) -> u64 {
        self.last_compute_work
    }

    /// Reject reads when output has not been computed for current inputs.
    pub fn ensure_current(&self, field: &TileField) -> Result<(), String> {
        self.ensure_matches_field(field)?;
        if self.computed_field_version != Some(field.version()) {
            return Err(format!(
                "tilelight output is stale for tilefield version {}",
                field.version()
            ));
        }
        if self.computed_source_version != self.source_version {
            return Err("tilelight output is stale for runtime source version".to_string());
        }
        Ok(())
    }

    fn mark_source_dirty(&mut self) {
        self.source_version = self.source_version.saturating_add(1);
    }

    fn allocate_light_id(&mut self, api: &str) -> Result<u32, String> {
        if self.next_light_id == 0 {
            return Err(format!(
                "tilelight {api} source id space exhausted; clear and recreate the map"
            ));
        }
        let id = self.next_light_id;
        self.next_light_id = id.checked_add(1).unwrap_or(0);
        Ok(id)
    }

    /// Set global light aliasing the sun-light source.
    pub fn set_global_light(&mut self, sun: SunLight) {
        self.set_sun_light(sun);
    }

    /// Validate and set the compatibility global sun light alias.
    pub fn try_set_global_light(&mut self, sun: SunLight) -> Result<(), String> {
        self.try_set_sun_light(sun)
    }

    /// Compute current light values from ambient, point lights, line lights, and sun light.
    #[allow(clippy::too_many_arguments)]
    pub fn compute(
        &mut self,
        field: &TileField,
        include_point_lights: bool,
        include_line_lights: bool,
        include_area_lights: bool,
        include_sun_light: bool,
        ambient: Option<LightColor>,
        time_seconds: f32,
    ) -> Result<(), String> {
        self.compute_with_options(
            field,
            ComputeOptions {
                include_point_lights,
                include_line_lights,
                include_area_lights,
                include_sun_light,
                ambient,
                time_seconds,
            },
        )
    }

    /// Compute a complete bounded result from validated options.
    pub fn compute_with_options(
        &mut self,
        field: &TileField,
        options: ComputeOptions,
    ) -> Result<(), String> {
        self.ensure_matches_field(field)?;
        self.validate_compute_options(options)?;
        let work = self.estimate_compute_work(field, options)?;
        self.light_values
            .fill(options.ambient.unwrap_or(self.ambient_light));
        if options.include_sun_light {
            self.apply_sun_light(field);
        }
        if options.include_point_lights {
            self.apply_point_lights(field, options.time_seconds);
            self.apply_tilefield_lights(field);
        }
        if options.include_line_lights {
            self.apply_line_lights(field, options.time_seconds);
        }
        if options.include_area_lights {
            self.apply_area_lights(field, options.time_seconds);
        }
        self.computed_field_version = Some(field.version());
        self.computed_source_version = self.source_version;
        self.computed_options = Some(options);
        self.last_affected_cells = self.light_values.len();
        self.last_compute_work = work;
        Ok(())
    }

    /// Recompute dirty output using the same full fallback as `compute`.
    ///
    /// A conservative full fallback preserves correctness while keeping the
    /// version/dirty contract ready for a future influence-region optimizer.
    pub fn compute_dirty(
        &mut self,
        field: &TileField,
        options: ComputeOptions,
    ) -> Result<(), String> {
        self.ensure_matches_field(field)?;
        if !self.is_dirty(field) && self.computed_options == Some(options) {
            return Ok(());
        }
        self.compute_with_options(field, options)
    }

    fn validate_color_and_modulation(
        &self,
        color: LightColor,
        modulation: LightModulation,
        api: &str,
    ) -> Result<(), String> {
        color.validate(api)?;
        modulation.validate(api)
    }

    fn validate_point_source(
        &self,
        coord: CellCoord,
        radius: f32,
        intensity: f32,
        color: LightColor,
        modulation: LightModulation,
        api: &str,
    ) -> Result<(), String> {
        let radius_cells = self.limits.radius_cells(radius, api)?;
        let footprint = Self::square_footprint(radius_cells)?;
        self.limits.check_affected_cells(footprint, api)?;
        if !intensity.is_finite() || intensity < 0.0 {
            return Err(format!("tilelight {api} intensity must be finite and >= 0"));
        }
        if coord.z >= self.levels {
            return Err(format!("tilelight {api} level is out of bounds"));
        }
        self.validate_color_and_modulation(color, modulation, api)
    }

    // Keep the complete candidate fields together so add/update validation shares one path.
    #[allow(clippy::too_many_arguments)]
    fn validate_line_source(
        &self,
        field: &TileField,
        start: CellCoord,
        end: CellCoord,
        radius: f32,
        intensity: f32,
        color: LightColor,
        modulation: LightModulation,
        api: &str,
    ) -> Result<(), String> {
        let radius_cells = self.limits.radius_cells(radius, api)?;
        let line_cells = self.line_cell_count(start, end, api)?;
        if line_cells > self.limits.max_line_cells {
            return Err(format!(
                "tilelight {api} line-cell limit {} exceeded",
                self.limits.max_line_cells
            ));
        }
        let footprint = self.line_footprint(start, end, radius_cells)?;
        self.limits.check_affected_cells(footprint, api)?;
        if !intensity.is_finite() || intensity < 0.0 {
            return Err(format!("tilelight {api} intensity must be finite and >= 0"));
        }
        if start.z != end.z || !field.in_bounds(start) || !field.in_bounds(end) {
            return Err(format!("tilelight {api} line coordinates are invalid"));
        }
        self.validate_color_and_modulation(color, modulation, api)
    }

    fn line_cell_count(
        &self,
        start: CellCoord,
        end: CellCoord,
        api: &str,
    ) -> Result<usize, String> {
        let mut count = 0usize;
        visit_line_cells(self.topology, start, end, |_| {
            count = count.saturating_add(1);
            count <= self.limits.max_line_cells
        })
        .map_err(|error| format!("tilelight {api} {error}"))?;
        if count > self.limits.max_line_cells {
            return Err(format!(
                "tilelight {api} line-cell limit {} exceeded",
                self.limits.max_line_cells
            ));
        }
        Ok(count)
    }

    fn square_footprint(radius: u32) -> Result<u64, String> {
        let span = u64::from(radius)
            .checked_mul(2)
            .and_then(|value| value.checked_add(1))
            .ok_or_else(|| "tilelight radius footprint overflows".to_string())?;
        span.checked_mul(span)
            .ok_or_else(|| "tilelight radius footprint overflows".to_string())
    }

    fn area_footprint(width: u32, height: u32, radius: u32) -> Result<u64, String> {
        let span_x = u64::from(width)
            .checked_add(
                u64::from(radius)
                    .checked_mul(2)
                    .ok_or_else(|| "tilelight area halo overflows".to_string())?,
            )
            .ok_or_else(|| "tilelight area halo overflows".to_string())?;
        let span_y = u64::from(height)
            .checked_add(
                u64::from(radius)
                    .checked_mul(2)
                    .ok_or_else(|| "tilelight area halo overflows".to_string())?,
            )
            .ok_or_else(|| "tilelight area halo overflows".to_string())?;
        span_x
            .checked_mul(span_y)
            .ok_or_else(|| "tilelight area footprint overflows".to_string())
    }

    fn line_footprint(&self, start: CellCoord, end: CellCoord, radius: u32) -> Result<u64, String> {
        let span_x = u64::from(start.x.max(end.x) - start.x.min(end.x))
            .checked_add(1)
            .and_then(|value| value.checked_add(u64::from(radius).checked_mul(2)?))
            .ok_or_else(|| "tilelight line halo overflows".to_string())?;
        let span_y = u64::from(start.y.max(end.y) - start.y.min(end.y))
            .checked_add(1)
            .and_then(|value| value.checked_add(u64::from(radius).checked_mul(2)?))
            .ok_or_else(|| "tilelight line halo overflows".to_string())?;
        span_x
            .checked_mul(span_y)
            .ok_or_else(|| "tilelight line footprint overflows".to_string())
    }

    fn validate_compute_options(&self, options: ComputeOptions) -> Result<(), String> {
        if !options.time_seconds.is_finite() {
            return Err("tilelight compute time must be finite".to_string());
        }
        if let Some(ambient) = options.ambient {
            ambient.validate("compute")?;
        }
        Ok(())
    }

    fn estimate_compute_work(
        &self,
        field: &TileField,
        options: ComputeOptions,
    ) -> Result<u64, String> {
        let mut work = self.light_values.len() as u64;
        let volume = work;
        if options.include_sun_light {
            let sun_steps = u64::from(self.levels)
                .checked_add(u64::from(self.width.max(self.height)))
                .ok_or_else(|| "tilelight sun work estimate overflows".to_string())?;
            work = work
                .checked_add(
                    volume
                        .checked_mul(sun_steps)
                        .ok_or_else(|| "tilelight sun work estimate overflows".to_string())?,
                )
                .ok_or_else(|| "tilelight compute work estimate overflows".to_string())?;
        }
        if options.include_point_lights {
            let authored = field.tile_light_sources();
            if authored.len() > self.limits.max_point_lights {
                return Err(format!(
                    "tilelight authored point source limit {} exceeded",
                    self.limits.max_point_lights
                ));
            }
            for source in authored {
                let radius = self.limits.radius_cells(source.radius, "compute")?;
                let footprint = Self::square_footprint(radius)?;
                self.limits.check_affected_cells(footprint, "compute")?;
                work = work
                    .checked_add(footprint)
                    .ok_or_else(|| "tilelight compute work estimate overflows".to_string())?;
            }
            for light in &self.point_lights {
                work = work
                    .checked_add(Self::square_footprint(
                        self.limits.radius_cells(light.radius, "compute")?,
                    )?)
                    .ok_or_else(|| "tilelight compute work estimate overflows".to_string())?;
            }
        }
        if options.include_line_lights {
            for light in &self.line_lights {
                work = work
                    .checked_add(self.line_footprint(
                        CellCoord {
                            x: light.x1,
                            y: light.y1,
                            z: light.z1,
                        },
                        CellCoord {
                            x: light.x2,
                            y: light.y2,
                            z: light.z2,
                        },
                        self.limits.radius_cells(light.radius, "compute")?,
                    )?)
                    .ok_or_else(|| "tilelight compute work estimate overflows".to_string())?;
            }
        }
        if options.include_area_lights {
            for light in &self.area_lights {
                work = work
                    .checked_add(Self::area_footprint(
                        light.width,
                        light.height,
                        self.limits.radius_cells(light.radius, "compute")?,
                    )?)
                    .ok_or_else(|| "tilelight compute work estimate overflows".to_string())?;
            }
        }
        self.limits.check_compute_work(work)?;
        Ok(work)
    }

    // Keep the complete candidate fields together so add/update validation shares one path.
    #[allow(clippy::too_many_arguments)]
    fn validate_area_light(
        &self,
        field: &TileField,
        origin: CellCoord,
        width: u32,
        height: u32,
        radius: f32,
        intensity: f32,
        api: &str,
    ) -> Result<(), String> {
        if width == 0 || height == 0 {
            return Err(format!("tilelight {api} width and height must be > 0"));
        }
        if width > self.limits.max_area_width || height > self.limits.max_area_height {
            return Err(format!(
                "tilelight {api} area dimensions exceed configured limits {}x{}",
                self.limits.max_area_width, self.limits.max_area_height
            ));
        }
        let max_x = origin
            .x
            .checked_add(width - 1)
            .ok_or_else(|| format!("tilelight {api} rectangle overflows tile coordinates"))?;
        let max_y = origin
            .y
            .checked_add(height - 1)
            .ok_or_else(|| format!("tilelight {api} rectangle overflows tile coordinates"))?;
        if !field.in_bounds(origin)
            || !field.in_bounds(CellCoord {
                x: max_x,
                y: max_y,
                z: origin.z,
            })
        {
            return Err(format!("tilelight {api} rectangle is out of bounds"));
        }
        if !radius.is_finite() || radius <= 0.0 {
            return Err(format!(
                "tilelight {api} area light radius must be finite and > 0"
            ));
        }
        if !intensity.is_finite() || intensity < 0.0 {
            return Err(format!(
                "tilelight {api} area light intensity must be finite and >= 0"
            ));
        }
        let radius_cells = self.limits.radius_cells(radius, api)?;
        let footprint = Self::area_footprint(width, height, radius_cells)?;
        self.limits.check_affected_cells(footprint, api)?;
        Ok(())
    }

    fn ensure_matches_field(&self, field: &TileField) -> Result<(), String> {
        if self.matches_field(field) {
            Ok(())
        } else {
            Err("tilelight map dimensions or topology do not match tilefield".to_string())
        }
    }

    fn apply_sun_light(&mut self, field: &TileField) {
        match self.sun_light.mode {
            SunLightMode::Top => self.apply_top_sun_light(field),
            SunLightMode::Directional { dx, dy } => self.apply_directional_sun_light(field, dx, dy),
        }
    }

    fn apply_top_sun_light(&mut self, field: &TileField) {
        for y in 0..self.height {
            for x in 0..self.width {
                let mut transmission = 1.0;
                for z in (0..self.levels).rev() {
                    let coord = CellCoord { x, y, z };
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx].add_scaled(
                            self.sun_light.color,
                            self.sun_light.intensity * transmission,
                        );
                    }
                    transmission *= self.top_sun_transmission_at(field, coord);
                }
            }
        }
    }

    fn apply_directional_sun_light(&mut self, field: &TileField, dx: i32, dy: i32) {
        if dx == 0 && dy == 0 {
            self.apply_top_sun_light(field);
            return;
        }
        for z in 0..self.levels {
            for y in 0..self.height {
                for x in 0..self.width {
                    let coord = CellCoord { x, y, z };
                    let transmission = self.directional_sun_transmission(field, coord, dx, dy);
                    if transmission <= f32::EPSILON {
                        continue;
                    }
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx].add_scaled(
                            self.sun_light.color,
                            self.sun_light.intensity * transmission,
                        );
                    }
                }
            }
        }
    }

    fn apply_point_lights(&mut self, field: &TileField, time_seconds: f32) {
        let lights = self.point_lights.clone();
        for light in lights {
            let origin = CellCoord {
                x: light.x,
                y: light.y,
                z: light.z,
            };
            let intensity = light.modulation.intensity_at(light.intensity, time_seconds);
            let color = light.modulation.color_at(light.color, time_seconds);
            let radius = light.radius.ceil() as u32;
            let (start_x, end_x) = self.axis_bounds(light.x, radius, self.width);
            let (start_y, end_y) = self.axis_bounds(light.y, radius, self.height);
            for y in start_y..=end_y {
                for x in start_x..=end_x {
                    let coord = CellCoord { x, y, z: light.z };
                    if !field.in_bounds(coord) {
                        continue;
                    }
                    let dist = self.point_light_distance(origin, coord);
                    if dist > light.radius {
                        continue;
                    }
                    let (transmission, filter) = self.light_transfer(field, origin, coord);
                    if transmission <= f32::EPSILON {
                        continue;
                    }
                    let color = Self::filtered_color(color, filter);
                    let falloff = 1.0 - (dist / light.radius);
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx]
                            .add_scaled(color, intensity * falloff.max(0.0) * transmission);
                    }
                }
            }
        }
    }

    fn apply_tilefield_lights(&mut self, field: &TileField) {
        for light in field.tile_light_sources() {
            if !light.radius.is_finite() || light.radius <= 0.0 || light.intensity <= 0.0 {
                continue;
            }
            let origin = CellCoord {
                x: light.x,
                y: light.y,
                z: light.z,
            };
            let radius = light.radius.ceil() as u32;
            let (start_x, end_x) = self.axis_bounds(light.x, radius, self.width);
            let (start_y, end_y) = self.axis_bounds(light.y, radius, self.height);
            let color = LightColor {
                r: light.color[0],
                g: light.color[1],
                b: light.color[2],
            }
            .clamped();
            for y in start_y..=end_y {
                for x in start_x..=end_x {
                    let coord = CellCoord { x, y, z: light.z };
                    if !field.in_bounds(coord) {
                        continue;
                    }
                    let dist = self.point_light_distance(origin, coord);
                    if dist > light.radius {
                        continue;
                    }
                    let (transmission, filter) = self.light_transfer(field, origin, coord);
                    if transmission <= f32::EPSILON {
                        continue;
                    }
                    let color = Self::filtered_color(color, filter);
                    let falloff = 1.0 - (dist / light.radius);
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx]
                            .add_scaled(color, light.intensity * falloff.max(0.0) * transmission);
                    }
                }
            }
        }
    }

    fn apply_line_lights(&mut self, field: &TileField, time_seconds: f32) {
        let lights = self.line_lights.clone();
        for light in lights {
            let start = CellCoord {
                x: light.x1,
                y: light.y1,
                z: light.z1,
            };
            let end = CellCoord {
                x: light.x2,
                y: light.y2,
                z: light.z2,
            };
            let mut line_cells = Vec::with_capacity(self.limits.max_line_cells.min(256));
            let _ = visit_line_cells(self.topology, start, end, |coord| {
                line_cells.push(coord);
                true
            });
            if line_cells.is_empty() {
                continue;
            }
            let intensity = light.modulation.intensity_at(light.intensity, time_seconds);
            let color = light.modulation.color_at(light.color, time_seconds);
            let radius = light.radius.ceil() as u32;
            let min_x = line_cells.iter().map(|cell| cell.x).min().unwrap_or(0);
            let max_x = line_cells.iter().map(|cell| cell.x).max().unwrap_or(0);
            let min_y = line_cells.iter().map(|cell| cell.y).min().unwrap_or(0);
            let max_y = line_cells.iter().map(|cell| cell.y).max().unwrap_or(0);
            let (start_x, _) = self.axis_bounds(min_x, radius, self.width);
            let (_, end_x) = self.axis_bounds(max_x, radius, self.width);
            let (start_y, _) = self.axis_bounds(min_y, radius, self.height);
            let (_, end_y) = self.axis_bounds(max_y, radius, self.height);
            for y in start_y..=end_y {
                for x in start_x..=end_x {
                    let coord = CellCoord { x, y, z: light.z1 };
                    if !field.in_bounds(coord) {
                        continue;
                    }
                    let Some(nearest) = self.nearest_line_cell(&line_cells, coord) else {
                        continue;
                    };
                    let dist = self.point_light_distance(nearest, coord);
                    if dist > light.radius {
                        continue;
                    }
                    let (transmission, filter) = self.light_transfer(field, nearest, coord);
                    if transmission <= f32::EPSILON {
                        continue;
                    }
                    let color = Self::filtered_color(color, filter);
                    let falloff = 1.0 - (dist / light.radius);
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx]
                            .add_scaled(color, intensity * falloff.max(0.0) * transmission);
                    }
                }
            }
        }
    }

    fn apply_area_lights(&mut self, field: &TileField, time_seconds: f32) {
        let lights = self.area_lights.clone();
        for light in lights {
            let intensity = light.modulation.intensity_at(light.intensity, time_seconds);
            let color = light.modulation.color_at(light.color, time_seconds);
            let radius = light.radius.ceil() as u32;
            let start_x = light.x.saturating_sub(radius);
            let start_y = light.y.saturating_sub(radius);
            let end_x = light
                .x
                .saturating_add(light.width - 1)
                .saturating_add(radius)
                .min(self.width - 1);
            let end_y = light
                .y
                .saturating_add(light.height - 1)
                .saturating_add(radius)
                .min(self.height - 1);
            for y in start_y..=end_y {
                for x in start_x..=end_x {
                    let coord = CellCoord { x, y, z: light.z };
                    if !field.in_bounds(coord) {
                        continue;
                    }
                    let nearest = self.nearest_area_cell(&light, coord);
                    let dist = self.point_light_distance(nearest, coord);
                    if dist > light.radius {
                        continue;
                    }
                    let (transmission, filter) = self.light_transfer(field, nearest, coord);
                    if transmission <= f32::EPSILON {
                        continue;
                    }
                    let color = Self::filtered_color(color, filter);
                    let falloff = 1.0 - (dist / light.radius);
                    if let Some(idx) = self.index(coord) {
                        self.light_values[idx]
                            .add_scaled(color, intensity * falloff.max(0.0) * transmission);
                    }
                }
            }
        }
    }

    fn axis_bounds(&self, center: u32, radius: u32, limit: u32) -> (u32, u32) {
        let max = limit.saturating_sub(1);
        (
            center.saturating_sub(radius),
            center.saturating_add(radius).min(max),
        )
    }

    fn nearest_area_cell(&self, light: &AreaLight, target: CellCoord) -> CellCoord {
        let max_x = light.x + light.width - 1;
        let max_y = light.y + light.height - 1;
        CellCoord {
            x: target.x.clamp(light.x, max_x),
            y: target.y.clamp(light.y, max_y),
            z: light.z,
        }
    }

    fn nearest_line_cell(&self, line_cells: &[CellCoord], target: CellCoord) -> Option<CellCoord> {
        line_cells.iter().copied().min_by(|a, b| {
            self.point_light_distance(*a, target)
                .partial_cmp(&self.point_light_distance(*b, target))
                .unwrap_or(std::cmp::Ordering::Equal)
        })
    }

    fn point_light_distance(&self, a: CellCoord, b: CellCoord) -> f32 {
        if a.z != b.z {
            return f32::INFINITY;
        }
        match self.topology {
            TileTopology::Square4 | TileTopology::Square | TileTopology::IsoSquare => {
                let dx = a.x.abs_diff(b.x) as f32;
                let dy = a.y.abs_diff(b.y) as f32;
                (dx * dx + dy * dy).sqrt()
            }
            TileTopology::Hex => self.topology.distance(a, b) as f32,
        }
    }

    fn filtered_color(color: LightColor, filter: [f32; 3]) -> LightColor {
        LightColor {
            r: color.r * filter[0],
            g: color.g * filter[1],
            b: color.b * filter[2],
        }
        .clamped()
    }

    fn light_transfer(
        &self,
        field: &TileField,
        origin: CellCoord,
        target: CellCoord,
    ) -> (f32, [f32; 3]) {
        if origin == target {
            return (1.0, [1.0, 1.0, 1.0]);
        }
        let mut transmission = 1.0;
        let mut filter = [1.0, 1.0, 1.0];
        let mut first = true;
        let _ = visit_line_cells(self.topology, origin, target, |coord| {
            if first {
                first = false;
                return true;
            }
            if coord == target {
                return false;
            }
            transmission *= field.category_transmission(coord, "light");
            let cell_filter = field.category_filter(coord, "light");
            filter[0] *= cell_filter[0];
            filter[1] *= cell_filter[1];
            filter[2] *= cell_filter[2];
            transmission > f32::EPSILON
        });
        (transmission.clamp(0.0, 1.0), filter)
    }

    fn directional_sun_transmission(
        &self,
        field: &TileField,
        target: CellCoord,
        dx: i32,
        dy: i32,
    ) -> f32 {
        let mut transmission = self.elevated_directional_sun_transmission(field, target, dx, dy);
        if transmission <= f32::EPSILON {
            return 0.0;
        }
        let mut x = target.x as i32 - dx.signum();
        let mut y = target.y as i32 - dy.signum();
        while x >= 0 && y >= 0 && x < self.width as i32 && y < self.height as i32 {
            let coord = CellCoord {
                x: x as u32,
                y: y as u32,
                z: target.z,
            };
            transmission *= self.directional_sun_transmission_at(field, coord);
            if transmission <= f32::EPSILON {
                return 0.0;
            }
            x -= dx.signum();
            y -= dy.signum();
        }
        transmission.clamp(0.0, 1.0)
    }

    fn elevated_directional_sun_transmission(
        &self,
        field: &TileField,
        target: CellCoord,
        dx: i32,
        dy: i32,
    ) -> f32 {
        let step_x = dx.signum();
        let step_y = dy.signum();
        if step_x == 0 && step_y == 0 {
            return 1.0;
        }
        let mut transmission = 1.0;
        for level_delta in 1..(self.levels - target.z) {
            let x = target.x as i32 - step_x * level_delta as i32;
            let y = target.y as i32 - step_y * level_delta as i32;
            if x < 0 || y < 0 || x >= self.width as i32 || y >= self.height as i32 {
                continue;
            }
            let coord = CellCoord {
                x: x as u32,
                y: y as u32,
                z: target.z + level_delta,
            };
            transmission *= self.top_sun_transmission_at(field, coord);
            if transmission <= f32::EPSILON {
                return 0.0;
            }
        }
        transmission.clamp(0.0, 1.0)
    }

    fn top_sun_transmission_at(&self, field: &TileField, coord: CellCoord) -> f32 {
        let channel = field.category_transmission(coord, "sun");
        let occlusion = 1.0 - field.sun_occlusion(coord).clamp(0.0, 1.0);
        (channel * occlusion).clamp(0.0, 1.0)
    }

    fn directional_sun_transmission_at(&self, field: &TileField, coord: CellCoord) -> f32 {
        let sun = field.category_transmission(coord, "sun");
        let light = field.category_transmission(coord, "light");
        let occlusion = 1.0 - field.sun_occlusion(coord).clamp(0.0, 1.0);
        (sun * light * occlusion).clamp(0.0, 1.0)
    }

    /// Return computed light for a cell.
    pub fn light_at(&self, coord: CellCoord) -> LightColor {
        self.index(coord)
            .and_then(|idx| self.light_values.get(idx).copied())
            .unwrap_or(LightColor::BLACK)
    }

    /// Export one computed light layer after validating level and copy bounds.
    pub fn export_layer(&self, z: u32) -> Result<Vec<LightColor>, String> {
        if z >= self.levels {
            return Err(format!("tilelight exportLayer level {z} is out of bounds"));
        }
        let cells = usize::try_from(u64::from(self.width) * u64::from(self.height))
            .map_err(|_| "tilelight exportLayer cell count is not addressable".to_string())?;
        if cells > self.limits.max_output_cells {
            return Err("tilelight exportLayer output cell limit exceeded".to_string());
        }
        let mut out = Vec::with_capacity(cells);
        for y in 0..self.height {
            for x in 0..self.width {
                out.push(self.light_at(CellCoord { x, y, z }));
            }
        }
        Ok(out)
    }

    /// Export all computed light levels with a bounded copy cost.
    pub fn export_volume(&self) -> Result<Vec<Vec<LightColor>>, String> {
        if self.light_values.len() > self.limits.max_output_cells {
            return Err("tilelight exportVolume output cell limit exceeded".to_string());
        }
        let mut volume = Vec::with_capacity(self.levels as usize);
        for z in 0..self.levels {
            volume.push(self.export_layer(z)?);
        }
        Ok(volume)
    }
}
