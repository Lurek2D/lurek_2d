//! Sync political colors and fog visibility from the province registry into the globe.

use crate::globe::registry::Globe;
use crate::globe::types::RegionId;
use crate::province::registry::ProvinceRegistry;
/// Copy political colors from the province registry into matching globe provinces.
pub fn apply_political_colors(globe: &mut Globe, registry: &ProvinceRegistry) {
    for id in registry.province_ids() {
        let rid = RegionId(id.0);
        if let (Some(snap), Some(gp)) = (registry.get_province(id), globe.get_province_mut(rid)) {
            gp.base_color = snap.style.political_color;
        }
    }
}
/// Update a viewer fog mask from province visibility state in the registry.
pub fn apply_visibility_to_viewer(globe: &mut Globe, registry: &ProvinceRegistry, viewer: &str) {
    for id in registry.province_ids() {
        let rid = RegionId(id.0);
        if let Some(snap) = registry.get_province(id) {
            if snap.style.visibility_state > 0 {
                globe.fog.reveal(viewer, rid);
            } else {
                globe.fog.hide(viewer, rid);
            }
        }
    }
}
