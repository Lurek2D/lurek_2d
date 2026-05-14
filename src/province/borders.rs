//! - Classify shared borders between adjacent provinces by terrain type.
//! - Map land/water combinations to discrete border classes (land-land, coast, sea-sea).
//! - Provide a single pure function with no side effects for pipeline integration.

use crate::province::types::{BorderClass, ProvinceStyle};

/// Classify the shared border between provinces with styles a and b; uses terrain_type == 0 as the water test.
pub fn classify_border(a: &ProvinceStyle, b: &ProvinceStyle) -> BorderClass {
    let a_water = a.terrain_type == 0;
    let b_water = b.terrain_type == 0;
    match (a_water, b_water) {
        (false, false) => BorderClass::LandLand,
        (true, true) => BorderClass::SeaSea,
        _ => BorderClass::Coast,
    }
}
