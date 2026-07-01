//! Centralizes globe validation and file-load safety shared by loaders, registries, and Lua bindings.
//! Owns numeric range checks, region topology diagnostics, sandboxed file-path resolution, and loader size limits.
//! Keeps geometry and load-policy invariants in one place so globe callers do not drift into inconsistent error rules.
//! Open this owner when globe specs, multipart regions, or file-loader trust boundaries need coordinated updates.

use crate::globe::marker::MarkerPlacement;
use crate::globe::types::{
    Arc as GlobeArc, GlobeSpec, HeatLayer, Label, LabelStyle, Layer, MarkerStyle, Region,
    RegionId,
};
use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};

const DEFAULT_MAX_TOML_BYTES: u64 = 2 * 1024 * 1024;
const DEFAULT_MAX_PNG_BYTES: u64 = 16 * 1024 * 1024;
const DEFAULT_MAX_PNG_PIXELS: u64 = 8_388_608;

/// Loader policy applied to file-backed globe imports.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct GlobeLoadOptions {
    /// Canonical root directory that file-backed globe imports must stay under.
    pub sandbox_root: PathBuf,
    /// Maximum accepted TOML source size in bytes.
    pub max_toml_bytes: u64,
    /// Maximum accepted PNG file size in bytes.
    pub max_png_bytes: u64,
    /// Maximum accepted decoded PNG pixel count.
    pub max_png_pixels: u64,
}

impl Default for GlobeLoadOptions {
    fn default() -> Self {
        Self {
            sandbox_root: default_globe_sandbox_root(),
            max_toml_bytes: DEFAULT_MAX_TOML_BYTES,
            max_png_bytes: DEFAULT_MAX_PNG_BYTES,
            max_png_pixels: DEFAULT_MAX_PNG_PIXELS,
        }
    }
}

/// Resolve one globe loader path inside the configured sandbox root.
pub fn resolve_sandboxed_globe_path(root: &Path, candidate: &str) -> Result<PathBuf, String> {
    let canonical_root = std::fs::canonicalize(root).map_err(|error| {
        format!(
            "failed to resolve globe sandbox root '{}': {}",
            root.display(),
            error
        )
    })?;
    let candidate_path = PathBuf::from(candidate);
    let absolute = if candidate_path.is_absolute() {
        candidate_path
    } else {
        canonical_root.join(candidate_path)
    };
    let canonical_candidate = std::fs::canonicalize(&absolute).map_err(|error| {
        format!(
            "failed to resolve globe import path '{}': {}",
            absolute.display(),
            error
        )
    })?;
    if !canonical_candidate.starts_with(&canonical_root) {
        return Err(format!(
            "globe import path '{}' is outside sandbox root '{}'",
            canonical_candidate.display(),
            canonical_root.display()
        ));
    }
    Ok(canonical_candidate)
}

/// Enforce one decoded image pixel-count limit.
pub fn validate_png_pixel_limit(
    width: u32,
    height: u32,
    max_pixels: u64,
    label: &str,
) -> Result<(), String> {
    let pixels = width as u64 * height as u64;
    if pixels > max_pixels {
        return Err(format!(
            "{label} image is too large: {pixels} pixels exceeds limit {max_pixels}"
        ));
    }
    Ok(())
}

/// Enforce one file-size limit.
pub fn validate_file_size_limit(
    path: &Path,
    bytes: u64,
    max_bytes: u64,
    label: &str,
) -> Result<(), String> {
    if bytes > max_bytes {
        return Err(format!(
            "{label} '{}' is too large: {} bytes exceeds limit {}",
            path.display(),
            bytes,
            max_bytes
        ));
    }
    Ok(())
}

/// Validate one shared globe spec after parsing or mutation.
pub fn validate_globe_spec(spec: &GlobeSpec) -> Result<(), String> {
    validate_finite(spec.radius, "globe spec radius")?;
    if spec.radius < 1.0 {
        return Err("globe spec radius must be >= 1".to_string());
    }
    validate_finite(spec.axial_tilt_deg, "globe spec axial_tilt_deg")?;
    if !(-90.0..=90.0).contains(&spec.axial_tilt_deg) {
        return Err("globe spec axial_tilt_deg must be in -90..90".to_string());
    }
    validate_finite(spec.rotation_deg, "globe spec rotation_deg")?;
    validate_finite(spec.time_of_day, "globe spec time_of_day")?;
    if !(0.0..=24.0).contains(&spec.time_of_day) {
        return Err("globe spec time_of_day must be in 0..24".to_string());
    }
    validate_rgba(spec.border_color, "globe spec border_color")?;
    validate_finite(spec.border_width, "globe spec border_width")?;
    if spec.border_width < 0.0 {
        return Err("globe spec border_width must be >= 0".to_string());
    }
    validate_finite(spec.ambient, "globe spec ambient")?;
    if !(0.0..=1.0).contains(&spec.ambient) {
        return Err("globe spec ambient must be in 0..1".to_string());
    }
    validate_rgba(spec.atmosphere_color, "globe spec atmosphere_color")?;
    validate_finite(spec.atmosphere_width, "globe spec atmosphere_width")?;
    if spec.atmosphere_width < 0.0 {
        return Err("globe spec atmosphere_width must be >= 0".to_string());
    }
    validate_finite(
        spec.auto_rotation_deg_per_sec,
        "globe spec auto_rotation_deg_per_sec",
    )?;
    validate_rgba(spec.background_color, "globe spec background_color")?;
    Ok(())
}

/// Validate one region-like record before it enters globe storage.
pub fn validate_region(region: &Region, label: &str) -> Result<(), String> {
    let has_geometry = !region.parts.is_empty() || !region.vertices.is_empty();
    if !has_geometry && region.member_terrain_ids.is_empty() {
        return Err(format!(
            "{label} {} must contain geometry or member terrain ids",
            region.id
        ));
    }
    if region.parts.is_empty() {
        if !region.vertices.is_empty() {
            validate_loop(
                region.vertices.as_slice(),
                &format!("{label} {} vertices", region.id),
            )?;
        }
    } else {
        for (part_index, part) in region.parts.iter().enumerate() {
            validate_loop(
                part.outer.as_slice(),
                &format!("{label} {} part {} outer", region.id, part_index + 1),
            )?;
            for (hole_index, hole) in part.holes.iter().enumerate() {
                validate_loop(
                    hole.as_slice(),
                    &format!(
                        "{label} {} part {} hole {}",
                        region.id,
                        part_index + 1,
                        hole_index + 1
                    ),
                )?;
            }
        }
    }
    validate_lat_lon(
        region.centroid.0,
        region.centroid.1,
        &format!("{label} {} centroid", region.id),
    )?;
    validate_rgba(region.base_color, &format!("{label} {} base_color", region.id))?;
    if let Some(color) = region.overlay_color {
        validate_rgba(color, &format!("{label} {} overlay_color", region.id))?;
    }
    if let Some([u0, v0, u1, v1]) = region.texture_uv_rect {
        for (value, axis) in [(u0, "u0"), (v0, "v0"), (u1, "u1"), (v1, "v1")] {
            validate_finite(value, &format!("{label} {} texture_uv_rect {axis}", region.id))?;
            if !(0.0..=1.0).contains(&value) {
                return Err(format!(
                    "{label} {} texture_uv_rect {axis} must be in 0..1",
                    region.id
                ));
            }
        }
        if u1 < u0 || v1 < v0 {
            return Err(format!(
                "{label} {} texture_uv_rect must satisfy u1 >= u0 and v1 >= v0",
                region.id
            ));
        }
    }
    let mut neighbor_set = HashSet::new();
    for neighbor in &region.neighbors {
        if *neighbor == region.id {
            return Err(format!(
                "{label} {} must not list itself as a neighbor",
                region.id
            ));
        }
        if !neighbor_set.insert(*neighbor) {
            return Err(format!(
                "{label} {} lists neighbor {} more than once",
                region.id, neighbor
            ));
        }
    }
    let mut member_set = HashSet::new();
    for member in &region.member_terrain_ids {
        if !member_set.insert(*member) {
            return Err(format!(
                "{label} {} lists member terrain id {} more than once",
                region.id, member
            ));
        }
    }
    Ok(())
}

/// Validate one full region set, including cross-region topology references.
pub fn validate_region_set(regions: &[Region], label: &str) -> Result<(), String> {
    let mut by_id = HashMap::<RegionId, &Region>::with_capacity(regions.len());
    for region in regions {
        validate_region(region, label)?;
        if by_id.insert(region.id, region).is_some() {
            return Err(format!("{label} contains duplicate region id {}", region.id));
        }
    }
    for region in regions {
        for neighbor in &region.neighbors {
            let Some(other) = by_id.get(neighbor).copied() else {
                return Err(format!(
                    "{label} region {} references unknown neighbor {}",
                    region.id, neighbor
                ));
            };
            if !other.neighbors.contains(&region.id) {
                return Err(format!(
                    "{label} region {} lists neighbor {} but the reverse edge is missing",
                    region.id, neighbor
                ));
            }
        }
    }
    Ok(())
}

/// Validate one marker style and placement payload before it enters runtime storage.
pub fn validate_marker_placement(placement: &MarkerPlacement, label: &str) -> Result<(), String> {
    if placement.marker_type.trim().is_empty() {
        return Err(format!("{label} marker_type must not be empty"));
    }
    if placement.orbit.trim().is_empty() {
        return Err(format!("{label} orbit must not be empty"));
    }
    validate_lat_lon(placement.lat_deg, placement.lon_deg, label)?;
    if let Some(altitude_px) = placement.altitude_px {
        validate_finite(altitude_px, &format!("{label} altitude_px"))?;
        if altitude_px < 0.0 {
            return Err(format!("{label} altitude_px must be >= 0"));
        }
    }
    validate_marker_style(&placement.style, label)?;
    Ok(())
}

/// Validate one marker style independent from placement.
pub fn validate_marker_style(style: &MarkerStyle, label: &str) -> Result<(), String> {
    validate_rgba(style.color, &format!("{label} color"))?;
    validate_finite(style.size, &format!("{label} size"))?;
    if style.size < 1.0 {
        return Err(format!("{label} size must be >= 1"));
    }
    validate_finite(style.pulse_hz, &format!("{label} pulse_hz"))?;
    if style.pulse_hz < 0.0 {
        return Err(format!("{label} pulse_hz must be >= 0"));
    }
    validate_finite(
        style.pulse_amplitude,
        &format!("{label} pulse_amplitude"),
    )?;
    if !(0.0..=1.0).contains(&style.pulse_amplitude) {
        return Err(format!("{label} pulse_amplitude must be in 0..1"));
    }
    validate_finite(
        style.rotation_deg_per_sec,
        &format!("{label} rotation_deg_per_sec"),
    )?;
    Ok(())
}

/// Validate one label record before it enters runtime storage.
pub fn validate_label(label: &Label, owner: &str) -> Result<(), String> {
    if label.label_type.trim().is_empty() {
        return Err(format!("{owner} label_type must not be empty"));
    }
    validate_lat_lon(label.lat_deg, label.lon_deg, owner)?;
    validate_label_style(&label.style, owner)?;
    Ok(())
}

/// Validate one label style independent from label placement.
pub fn validate_label_style(style: &LabelStyle, owner: &str) -> Result<(), String> {
    validate_rgba(style.color, &format!("{owner} color"))?;
    validate_finite(style.font_size, &format!("{owner} font_size"))?;
    if style.font_size <= 0.0 {
        return Err(format!("{owner} font_size must be > 0"));
    }
    if style
        .font
        .as_deref()
        .is_some_and(|font| font.trim().is_empty())
    {
        return Err(format!("{owner} font must not be empty when provided"));
    }
    Ok(())
}

/// Validate one render layer before it is stored or mutated.
pub fn validate_layer(layer: &Layer, owner: &str) -> Result<(), String> {
    if layer.name.trim().is_empty() {
        return Err(format!("{owner} name must not be empty"));
    }
    validate_finite(layer.alpha, &format!("{owner} alpha"))?;
    if !(0.0..=1.0).contains(&layer.alpha) {
        return Err(format!("{owner} alpha must be in 0..1"));
    }
    for (region_id, color) in &layer.region_colors {
        validate_rgba(*color, &format!("{owner} region {} color", region_id))?;
    }
    Ok(())
}

/// Validate one heat layer definition before it is stored.
pub fn validate_heat_layer(layer: &HeatLayer, label: &str) -> Result<(), String> {
    if layer.name.trim().is_empty() {
        return Err(format!("{label} name must not be empty"));
    }
    if layer.attr_key.trim().is_empty() {
        return Err(format!("{label} attr_key must not be empty"));
    }
    validate_finite(layer.min_value, &format!("{label} min_value"))?;
    validate_finite(layer.max_value, &format!("{label} max_value"))?;
    if layer.max_value < layer.min_value {
        return Err(format!("{label} max_value must be >= min_value"));
    }
    validate_rgba(layer.cold_color, &format!("{label} cold_color"))?;
    validate_rgba(layer.hot_color, &format!("{label} hot_color"))?;
    validate_finite(layer.alpha, &format!("{label} alpha"))?;
    if !(0.0..=1.0).contains(&layer.alpha) {
        return Err(format!("{label} alpha must be in 0..1"));
    }
    Ok(())
}

/// Validate one render arc definition before it is stored.
pub fn validate_arc(arc: &GlobeArc, label: &str) -> Result<(), String> {
    if arc.arc_type.trim().is_empty() {
        return Err(format!("{label} arc_type must not be empty"));
    }
    validate_lat_lon(arc.from.0, arc.from.1, &format!("{label} from"))?;
    validate_lat_lon(arc.to.0, arc.to.1, &format!("{label} to"))?;
    validate_rgba(arc.color, &format!("{label} color"))?;
    validate_finite(arc.width, &format!("{label} width"))?;
    if arc.width <= 0.0 {
        return Err(format!("{label} width must be > 0"));
    }
    if arc.steps < 2 {
        return Err(format!("{label} steps must be >= 2"));
    }
    Ok(())
}

fn default_globe_sandbox_root() -> PathBuf {
    std::env::current_dir()
        .ok()
        .and_then(|path| std::fs::canonicalize(path).ok())
        .unwrap_or_else(|| PathBuf::from("."))
}

fn validate_loop(loop_points: &[(f32, f32)], label: &str) -> Result<(), String> {
    if loop_points.len() < 3 {
        return Err(format!("{label} must contain at least 3 vertices"));
    }
    for (index, &(lat, lon)) in loop_points.iter().enumerate() {
        validate_lat_lon(lat, lon, &format!("{label} vertex {}", index + 1))?;
    }
    Ok(())
}

fn validate_lat_lon(lat: f32, lon: f32, label: &str) -> Result<(), String> {
    validate_finite(lat, &format!("{label} latitude"))?;
    validate_finite(lon, &format!("{label} longitude"))?;
    if !(-90.0..=90.0).contains(&lat) {
        return Err(format!("{label} latitude must be in -90..90"));
    }
    if !(-180.0..=180.0).contains(&lon) {
        return Err(format!("{label} longitude must be in -180..180"));
    }
    Ok(())
}

fn validate_rgba(color: [f32; 4], label: &str) -> Result<(), String> {
    for (index, value) in color.into_iter().enumerate() {
        validate_finite(value, &format!("{label}[{}]", index + 1))?;
        if !(0.0..=1.0).contains(&value) {
            return Err(format!("{label}[{}] must be in 0..1", index + 1));
        }
    }
    Ok(())
}

fn validate_finite(value: f32, label: &str) -> Result<(), String> {
    if value.is_finite() {
        Ok(())
    } else {
        Err(format!("{label} must be a finite number"))
    }
}
