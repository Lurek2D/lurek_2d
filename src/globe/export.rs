//! Export globe region geometry to standard mesh formats.
//!
//! - Functions: `export_regions_to_obj`, `export_provinces_to_obj`.

use crate::globe::registry::Globe;
use std::fmt::Write;
/// Export region polygons as a flat OBJ string with one object per region.
pub fn export_regions_to_obj(globe: &Globe) -> String {
    let mut out = String::new();
    let mut vertex_base: u32 = 1;
    for region in globe.graph.iter() {
        let _ = writeln!(&mut out, "o region_{}", region.id);
        for (lat, lon) in &region.vertices {
            let _ = writeln!(&mut out, "v {} {} 0.0", lon, lat);
        }
        if region.vertices.len() >= 3 {
            let mut face = String::from("f");
            for i in 0..region.vertices.len() {
                let _ = write!(&mut face, " {}", vertex_base + i as u32);
            }
            let _ = writeln!(&mut out, "{}", face);
        }
        vertex_base += region.vertices.len() as u32;
    }
    out
}

/// Backward compatibility alias.
#[inline]
pub fn export_provinces_to_obj(globe: &Globe) -> String {
    export_regions_to_obj(globe)
}
