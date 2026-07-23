//! Defines the fixed resource ceilings shared by light-world storage and debug previews.
//! These limits bound Lua-reachable scene state before insertion and preview work before allocation.

/// Resource ceilings for one `LightWorld`.
/// # Fields
#[derive(Clone, Copy, Debug)]
pub struct LightLimits {
    /// Maximum registered lights; separate from renderer selection (`max_lights`).
    pub max_registered_lights: usize,
    /// Maximum registered occluders.
    pub max_registered_occluders: usize,
    /// Maximum vertices in one occluder.
    pub max_vertices_per_occluder: usize,
    /// Maximum vertices across all registered occluders.
    pub max_total_occluder_vertices: usize,
    /// Maximum renderer-facing hint records exported in one snapshot.
    pub max_hint_exports: usize,
    /// Maximum UTF-8 bytes in a cookie or normal-map resource key.
    pub max_resource_path_bytes: usize,
    /// Maximum pixels in a debug preview.
    pub max_debug_preview_pixels: u64,
    /// Maximum conservative debug-preview work units.
    pub max_debug_preview_work: u64,
}

impl Default for LightLimits {
    fn default() -> Self {
        Self {
            max_registered_lights: 4_096,
            max_registered_occluders: 4_096,
            max_vertices_per_occluder: 512,
            max_total_occluder_vertices: 65_536,
            max_hint_exports: 4_096,
            max_resource_path_bytes: 1_024,
            max_debug_preview_pixels: 4_194_304,
            max_debug_preview_work: 100_000_000,
        }
    }
}

impl LightLimits {
    /// Validates preview dimensions and a conservative direct-light plus shadow-edge work estimate.
    pub fn check_preview(
        &self,
        width: u32,
        height: u32,
        direct_light_samples: usize,
        edges: usize,
        shadow_edge_samples: usize,
    ) -> Result<(), String> {
        let pixels = u64::from(width)
            .checked_mul(u64::from(height))
            .ok_or_else(|| "lurek.light.drawToImage: preview dimensions overflow".to_string())?;
        if pixels > self.max_debug_preview_pixels {
            return Err(format!(
                "lurek.light.drawToImage: preview has {pixels} pixels, limit is {}",
                self.max_debug_preview_pixels
            ));
        }
        // Every selected light contributes one direct sample. Shadowed lights additionally test
        // every relevant edge once per PCF tap (1, 5, or 13 today), matching the nested preview
        // loops before allocation begins.
        let edge_work = edges.saturating_mul(shadow_edge_samples);
        let per_pixel =
            u64::try_from(direct_light_samples.saturating_add(edge_work)).unwrap_or(u64::MAX);
        let work = pixels.saturating_mul(per_pixel);
        if work > self.max_debug_preview_work {
            return Err(format!(
                "lurek.light.drawToImage: preview work {work} exceeds limit {}",
                self.max_debug_preview_work
            ));
        }
        Ok(())
    }
}
