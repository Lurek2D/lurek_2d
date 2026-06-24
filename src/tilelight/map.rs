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
    PointLight, PointLightUpdate, SunLight, SunLightMode,
};

/// Computed tile light values and source-light state for one tilefield-sized volume.
#[derive(Debug, Clone)]
pub struct TileLightMap {
    width: u32,
    height: u32,
    levels: u32,
    topology: TileTopology,
    point_lights: Vec<Option<PointLight>>,
    line_lights: Vec<Option<LineLight>>,
    area_lights: Vec<Option<AreaLight>>,
    next_light_id: u32,
    ambient_light: LightColor,
    sun_light: SunLight,
    light_values: Vec<LightColor>,
}

impl TileLightMap {
    /// Create light storage matching a tilefield-sized volume.
    pub fn new(
        width: u32,
        height: u32,
        levels: u32,
        topology: TileTopology,
    ) -> Result<Self, String> {
        if width == 0 || height == 0 || levels == 0 {
            return Err("tilelight dimensions and levels must be > 0".to_string());
        }
        let len = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(levels))
            .and_then(|v| usize::try_from(v).ok())
            .ok_or_else(|| "tilelight dimensions overflow addressable storage".to_string())?;
        Ok(Self {
            width,
            height,
            levels,
            topology,
            point_lights: Vec::new(),
            line_lights: Vec::new(),
            area_lights: Vec::new(),
            next_light_id: 1,
            ambient_light: LightColor::BLACK,
            sun_light: SunLight::default(),
            light_values: vec![LightColor::BLACK; len],
        })
    }

    /// Create light storage with the same dimensions and topology as a field.
    pub fn from_field(field: &TileField) -> Result<Self, String> {
        let (width, height, levels) = field.size();
        Self::new(width, height, levels, field.topology())
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
        if !radius.is_finite() || radius <= 0.0 {
            return Err("tilelight point light radius must be finite and > 0".to_string());
        }
        if !intensity.is_finite() || intensity < 0.0 {
            return Err("tilelight point light intensity must be finite and >= 0".to_string());
        }
        let id = self.next_light_id;
        self.next_light_id = self.next_light_id.saturating_add(1).max(1);
        self.point_lights.push(Some(PointLight {
            id,
            x,
            y,
            z,
            radius,
            intensity,
            color: color.clamped(),
            modulation,
        }));
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
        let light = self
            .point_lights
            .iter_mut()
            .filter_map(Option::as_mut)
            .find(|light| light.id == id)
            .ok_or_else(|| format!("tilelight point light id {id} does not exist"))?;
        let next_x = patch.x.unwrap_or(light.x);
        let next_y = patch.y.unwrap_or(light.y);
        let next_z = patch.z.unwrap_or(light.z);
        if !field.in_bounds(CellCoord {
            x: next_x,
            y: next_y,
            z: next_z,
        }) {
            return Err("tilelight updatePointLight coordinate is out of bounds".to_string());
        }
        if let Some(radius) = patch.radius {
            if !radius.is_finite() || radius <= 0.0 {
                return Err("tilelight point light radius must be finite and > 0".to_string());
            }
            light.radius = radius;
        }
        if let Some(intensity) = patch.intensity {
            if !intensity.is_finite() || intensity < 0.0 {
                return Err("tilelight point light intensity must be finite and >= 0".to_string());
            }
            light.intensity = intensity;
        }
        light.x = next_x;
        light.y = next_y;
        light.z = next_z;
        if let Some(color) = patch.color {
            light.color = color.clamped();
        }
        if let Some(modulation) = patch.modulation {
            light.modulation = modulation;
        }
        Ok(())
    }

    /// Remove a point light by id. Returns true when a light was removed.
    pub fn remove_point_light(&mut self, id: u32) -> bool {
        for slot in &mut self.point_lights {
            if slot.as_ref().is_some_and(|light| light.id == id) {
                *slot = None;
                return true;
            }
        }
        false
    }

    /// Remove all point lights.
    pub fn clear_point_lights(&mut self) {
        self.point_lights.clear();
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
        if !radius.is_finite() || radius <= 0.0 {
            return Err("tilelight line light radius must be finite and > 0".to_string());
        }
        if !intensity.is_finite() || intensity < 0.0 {
            return Err("tilelight line light intensity must be finite and >= 0".to_string());
        }
        let id = self.next_light_id;
        self.next_light_id = self.next_light_id.saturating_add(1).max(1);
        self.line_lights.push(Some(LineLight {
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
        }));
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
        let light = self
            .line_lights
            .iter_mut()
            .filter_map(Option::as_mut)
            .find(|light| light.id == id)
            .ok_or_else(|| format!("tilelight line light id {id} does not exist"))?;
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
        if let Some(radius) = patch.radius {
            if !radius.is_finite() || radius <= 0.0 {
                return Err("tilelight line light radius must be finite and > 0".to_string());
            }
            light.radius = radius;
        }
        if let Some(intensity) = patch.intensity {
            if !intensity.is_finite() || intensity < 0.0 {
                return Err("tilelight line light intensity must be finite and >= 0".to_string());
            }
            light.intensity = intensity;
        }
        light.x1 = start.x;
        light.y1 = start.y;
        light.z1 = start.z;
        light.x2 = end.x;
        light.y2 = end.y;
        light.z2 = end.z;
        if let Some(color) = patch.color {
            light.color = color.clamped();
        }
        if let Some(modulation) = patch.modulation {
            light.modulation = modulation;
        }
        Ok(())
    }

    /// Remove a line light by id. Returns true when a light was removed.
    pub fn remove_line_light(&mut self, id: u32) -> bool {
        for slot in &mut self.line_lights {
            if slot.as_ref().is_some_and(|light| light.id == id) {
                *slot = None;
                return true;
            }
        }
        false
    }

    /// Remove all line lights.
    pub fn clear_line_lights(&mut self) {
        self.line_lights.clear();
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
        Self::validate_area_light(
            field,
            origin,
            width,
            height,
            radius,
            intensity,
            "addAreaLight",
        )?;
        let id = self.next_light_id;
        self.next_light_id = self.next_light_id.saturating_add(1).max(1);
        self.area_lights.push(Some(AreaLight {
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
        }));
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
        let light = self
            .area_lights
            .iter_mut()
            .filter_map(Option::as_mut)
            .find(|light| light.id == id)
            .ok_or_else(|| format!("tilelight area light id {id} does not exist"))?;
        let origin = CellCoord {
            x: patch.x.unwrap_or(light.x),
            y: patch.y.unwrap_or(light.y),
            z: patch.z.unwrap_or(light.z),
        };
        let width = patch.width.unwrap_or(light.width);
        let height = patch.height.unwrap_or(light.height);
        let radius = patch.radius.unwrap_or(light.radius);
        let intensity = patch.intensity.unwrap_or(light.intensity);
        Self::validate_area_light(
            field,
            origin,
            width,
            height,
            radius,
            intensity,
            "updateAreaLight",
        )?;
        light.x = origin.x;
        light.y = origin.y;
        light.z = origin.z;
        light.width = width;
        light.height = height;
        light.radius = radius;
        light.intensity = intensity;
        if let Some(color) = patch.color {
            light.color = color.clamped();
        }
        if let Some(modulation) = patch.modulation {
            light.modulation = modulation;
        }
        Ok(())
    }

    /// Remove a rectangular area light by id. Returns true when a light was removed.
    pub fn remove_area_light(&mut self, id: u32) -> bool {
        for slot in &mut self.area_lights {
            if slot.as_ref().is_some_and(|light| light.id == id) {
                *slot = None;
                return true;
            }
        }
        false
    }

    /// Remove all rectangular area lights.
    pub fn clear_area_lights(&mut self) {
        self.area_lights.clear();
    }

    /// Set ambient light stored on this light map.
    pub fn set_ambient_light(&mut self, ambient: LightColor) {
        self.ambient_light = ambient.clamped();
    }

    /// Set sun light.
    pub fn set_sun_light(&mut self, sun: SunLight) {
        self.sun_light = SunLight {
            intensity: sun.intensity.max(0.0),
            color: sun.color.clamped(),
            mode: sun.mode,
        };
    }

    /// Set global light aliasing the sun-light source.
    pub fn set_global_light(&mut self, sun: SunLight) {
        self.set_sun_light(sun);
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
        self.ensure_matches_field(field)?;
        self.light_values
            .fill(ambient.unwrap_or(self.ambient_light).clamped());
        if include_sun_light {
            self.apply_sun_light(field);
        }
        if include_point_lights {
            self.apply_point_lights(field, time_seconds);
        }
        if include_point_lights {
            self.apply_tilefield_lights(field);
        }
        if include_line_lights {
            self.apply_line_lights(field, time_seconds);
        }
        if include_area_lights {
            self.apply_area_lights(field, time_seconds);
        }
        Ok(())
    }

    fn validate_area_light(
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
        let lights: Vec<_> = self.point_lights.iter().filter_map(Clone::clone).collect();
        for light in lights {
            let origin = CellCoord {
                x: light.x,
                y: light.y,
                z: light.z,
            };
            let intensity = light.modulation.intensity_at(light.intensity, time_seconds);
            let color = light.modulation.color_at(light.color, time_seconds);
            let radius = light.radius.ceil() as i32;
            for dy in -radius..=radius {
                for dx in -radius..=radius {
                    let x = light.x as i32 + dx;
                    let y = light.y as i32 + dy;
                    if x < 0 || y < 0 {
                        continue;
                    }
                    let coord = CellCoord {
                        x: x as u32,
                        y: y as u32,
                        z: light.z,
                    };
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
            let radius = light.radius.ceil() as i32;
            let color = LightColor {
                r: light.color[0],
                g: light.color[1],
                b: light.color[2],
            }
            .clamped();
            for dy in -radius..=radius {
                for dx in -radius..=radius {
                    let x = light.x as i32 + dx;
                    let y = light.y as i32 + dy;
                    if x < 0 || y < 0 {
                        continue;
                    }
                    let coord = CellCoord {
                        x: x as u32,
                        y: y as u32,
                        z: light.z,
                    };
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
        let lights: Vec<_> = self.line_lights.iter().filter_map(Clone::clone).collect();
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
            let mut line_cells = Vec::new();
            let _ = visit_line_cells(self.topology, start, end, |coord| {
                line_cells.push(coord);
                true
            });
            if line_cells.is_empty() {
                continue;
            }
            let intensity = light.modulation.intensity_at(light.intensity, time_seconds);
            let color = light.modulation.color_at(light.color, time_seconds);
            let radius = light.radius.ceil() as i32;
            for source in &line_cells {
                for dy in -radius..=radius {
                    for dx in -radius..=radius {
                        let x = source.x as i32 + dx;
                        let y = source.y as i32 + dy;
                        if x < 0 || y < 0 {
                            continue;
                        }
                        let coord = CellCoord {
                            x: x as u32,
                            y: y as u32,
                            z: source.z,
                        };
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
    }

    fn apply_area_lights(&mut self, field: &TileField, time_seconds: f32) {
        let lights: Vec<_> = self.area_lights.iter().filter_map(Clone::clone).collect();
        for light in lights {
            let intensity = light.modulation.intensity_at(light.intensity, time_seconds);
            let color = light.modulation.color_at(light.color, time_seconds);
            let radius = light.radius.ceil() as i32;
            let start_x = light.x.saturating_sub(radius as u32);
            let start_y = light.y.saturating_sub(radius as u32);
            let end_x = light
                .x
                .saturating_add(light.width - 1)
                .saturating_add(radius as u32)
                .min(self.width - 1);
            let end_y = light
                .y
                .saturating_add(light.height - 1)
                .saturating_add(radius as u32)
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

    /// Export one computed light layer.
    pub fn export_layer(&self, z: u32) -> Vec<LightColor> {
        let mut out = Vec::with_capacity((self.width * self.height) as usize);
        for y in 0..self.height {
            for x in 0..self.width {
                out.push(self.light_at(CellCoord { x, y, z }));
            }
        }
        out
    }

    /// Export all computed light levels.
    pub fn export_volume(&self) -> Vec<Vec<LightColor>> {
        let mut volume = Vec::with_capacity(self.levels as usize);
        for z in 0..self.levels {
            volume.push(self.export_layer(z));
        }
        volume
    }
}
