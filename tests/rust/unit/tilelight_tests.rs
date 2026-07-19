//! Internal regression tests for tile-light storage validation.

use lurek2d::tilefield::{CellCoord, TileChannel, TileField, TileTopology};
use lurek2d::tilelight::{
    ComputeOptions, GlobalLight, LightColor, LightModulation, SunLightMode, TileLightLimits,
    TileLightMap,
};

#[test]
fn tilelight_validates_dimensions_and_reports_exact_size() {
    assert!(TileLightMap::new(0, 4, 1, TileTopology::Square).is_err());
    let map = TileLightMap::new(8, 6, 2, TileTopology::Square).unwrap();
    assert_eq!(map.size(), (8, 6, 2));
}

#[test]
fn point_light_respects_light_blockers() {
    let mut field = TileField::new(6, 3, 1, TileTopology::Square).unwrap();
    field
        .set_block(CellCoord { x: 2, y: 1, z: 0 }, TileChannel::Light, true)
        .unwrap();
    let mut light = TileLightMap::from_field(&field).unwrap();
    light
        .add_point_light(
            &field,
            0,
            1,
            0,
            6.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .unwrap();
    light
        .compute(
            &field,
            true,
            false,
            false,
            false,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    assert!(light.light_at(CellCoord { x: 1, y: 1, z: 0 }).luma() > 0.0);
    assert!(light.light_at(CellCoord { x: 4, y: 1, z: 0 }).luma().abs() < 0.0001);
}

#[test]
fn point_light_uses_light_cost_as_partial_transmission() {
    let mut field = TileField::new(7, 3, 1, TileTopology::Square).unwrap();
    field
        .set_cost(CellCoord { x: 2, y: 1, z: 0 }, TileChannel::Light, 0.5)
        .unwrap();
    let mut light = TileLightMap::from_field(&field).unwrap();
    light
        .add_point_light(
            &field,
            0,
            1,
            0,
            8.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .unwrap();
    light
        .compute(
            &field,
            true,
            false,
            false,
            false,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    let before_filter = light.light_at(CellCoord { x: 1, y: 1, z: 0 }).luma();
    let behind_filter = light.light_at(CellCoord { x: 4, y: 1, z: 0 }).luma();
    let expected = 0.5 * (1.0 - 4.0 / 8.0);
    assert!(before_filter > behind_filter);
    assert!((behind_filter - expected).abs() < 0.001);
}

#[test]
fn square_point_light_uses_radial_euclidean_distance() {
    let field = TileField::new(5, 5, 1, TileTopology::Square).unwrap();
    let mut light = TileLightMap::from_field(&field).unwrap();
    light
        .add_point_light(
            &field,
            0,
            0,
            0,
            2.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .unwrap();
    light
        .compute(
            &field,
            true,
            false,
            false,
            false,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    assert!(light.light_at(CellCoord { x: 2, y: 0, z: 0 }).luma().abs() < 0.0001);
    assert!(light.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma().abs() < 0.0001);
    light
        .add_point_light(
            &field,
            0,
            0,
            0,
            3.0,
            1.0,
            LightColor {
                r: 1.0,
                g: 0.0,
                b: 0.0,
            },
            LightModulation::default(),
        )
        .unwrap();
    light
        .compute(
            &field,
            true,
            false,
            false,
            false,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    assert!(light.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma() > 0.0);
}

#[test]
fn colored_point_lights_add_by_channel_and_clamp() {
    let field = TileField::new(5, 3, 1, TileTopology::Square).unwrap();
    let mut light = TileLightMap::from_field(&field).unwrap();
    light
        .add_point_light(
            &field,
            0,
            1,
            0,
            4.0,
            1.0,
            LightColor {
                r: 1.0,
                g: 0.0,
                b: 0.0,
            },
            LightModulation::default(),
        )
        .unwrap();
    light
        .add_point_light(
            &field,
            4,
            1,
            0,
            4.0,
            1.0,
            LightColor {
                r: 0.0,
                g: 0.0,
                b: 1.0,
            },
            LightModulation::default(),
        )
        .unwrap();
    light
        .compute(
            &field,
            true,
            false,
            false,
            false,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    let mixed = light.light_at(CellCoord { x: 2, y: 1, z: 0 });
    assert!((mixed.r - 0.5).abs() < 0.001);
    assert!(mixed.g.abs() < 0.0001);
    assert!((mixed.b - 0.5).abs() < 0.001);
}

#[test]
fn global_light_is_attenuated_from_upper_levels() {
    let mut field = TileField::new(2, 2, 3, TileTopology::Square).unwrap();
    field
        .set_sun_occlusion(CellCoord { x: 0, y: 0, z: 2 }, 0.5)
        .unwrap();
    let mut light = TileLightMap::from_field(&field).unwrap();
    light.set_global_light(GlobalLight {
        intensity: 1.0,
        color: LightColor::WHITE,
        mode: SunLightMode::Top,
    });
    light
        .compute(
            &field,
            false,
            false,
            false,
            true,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    let top = light.light_at(CellCoord { x: 0, y: 0, z: 2 }).luma();
    let lower = light.light_at(CellCoord { x: 0, y: 0, z: 1 }).luma();
    assert!(top > lower);
    assert!(lower > 0.0);
}

#[test]
fn global_light_preserves_dusk_and_night_color() {
    let mut field = TileField::new(1, 1, 2, TileTopology::Square).unwrap();
    field
        .set_sun_occlusion(CellCoord { x: 0, y: 0, z: 1 }, 0.25)
        .unwrap();
    let mut light = TileLightMap::from_field(&field).unwrap();
    light.set_global_light(GlobalLight {
        intensity: 0.4,
        color: LightColor {
            r: 1.0,
            g: 0.55,
            b: 0.25,
        },
        mode: SunLightMode::Top,
    });
    light
        .compute(
            &field,
            false,
            false,
            false,
            true,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    let dusk_lower = light.light_at(CellCoord { x: 0, y: 0, z: 0 });
    light.set_global_light(GlobalLight {
        intensity: 0.12,
        color: LightColor {
            r: 0.22,
            g: 0.32,
            b: 1.0,
        },
        mode: SunLightMode::Top,
    });
    light
        .compute(
            &field,
            false,
            false,
            false,
            true,
            Some(LightColor::BLACK),
            0.0,
        )
        .unwrap();
    let night_lower = light.light_at(CellCoord { x: 0, y: 0, z: 0 });
    assert!(dusk_lower.r > dusk_lower.b);
    assert!(night_lower.b > night_lower.r);
    assert!(dusk_lower.luma() > night_lower.luma());
}

#[test]
fn limits_reject_dense_volume_before_allocation() {
    let limits = TileLightLimits {
        max_volume_cells: 8,
        max_output_cells: 8,
        ..TileLightLimits::default()
    };
    assert!(TileLightMap::new_with_limits(3, 3, 1, TileTopology::Square, limits).is_err());
}

#[test]
fn limits_reject_radius_line_and_area_shapes() {
    let limits = TileLightLimits {
        max_radius: 2,
        max_line_cells: 3,
        max_affected_cells_per_source: 16,
        ..TileLightLimits::default()
    };
    let field = TileField::new(8, 8, 1, TileTopology::Square).unwrap();
    let mut map = TileLightMap::new_with_limits(8, 8, 1, TileTopology::Square, limits).unwrap();
    assert!(map
        .add_point_light(
            &field,
            1,
            1,
            0,
            3.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .is_err());
    assert!(map
        .add_line_light(
            &field,
            CellCoord { x: 0, y: 0, z: 0 },
            CellCoord { x: 4, y: 0, z: 0 },
            1.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .is_err());
    assert!(map
        .add_area_light(
            &field,
            CellCoord { x: 1, y: 1, z: 0 },
            3,
            3,
            1.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .is_err());
}

#[test]
fn invalid_numeric_input_is_rejected_transactionally() {
    let field = TileField::new(5, 5, 1, TileTopology::Square).unwrap();
    let mut map = TileLightMap::from_field(&field).unwrap();
    let id = map
        .add_point_light(
            &field,
            2,
            2,
            0,
            2.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .unwrap();
    assert!(map
        .update_point_light(
            &field,
            id,
            lurek2d::tilelight::PointLightUpdate {
                radius: Some(f32::NAN),
                ..Default::default()
            },
        )
        .is_err());
    map.compute(
        &field,
        true,
        false,
        false,
        false,
        Some(LightColor::BLACK),
        0.0,
    )
    .unwrap();
    assert!(map.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma() > 0.0);
    assert!(map
        .add_point_light(
            &field,
            1,
            1,
            0,
            2.0,
            1.0,
            LightColor {
                r: f32::INFINITY,
                g: 0.0,
                b: 0.0,
            },
            LightModulation::default(),
        )
        .is_err());
    assert!(map
        .compute(&field, true, false, false, false, None, f32::NAN)
        .is_err());
}

#[test]
fn source_storage_compacts_without_reusing_stable_ids() {
    let field = TileField::new(4, 4, 1, TileTopology::Square).unwrap();
    let mut map = TileLightMap::from_field(&field).unwrap();
    let first = map
        .add_point_light(
            &field,
            0,
            0,
            0,
            1.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .unwrap();
    assert!(map.remove_point_light(first));
    let second = map
        .add_point_light(
            &field,
            1,
            1,
            0,
            1.0,
            1.0,
            LightColor::WHITE,
            LightModulation::default(),
        )
        .unwrap();
    assert!(second > first);
    assert!(!map.remove_point_light(first));
}

#[test]
fn dirty_version_and_full_fallback_are_equivalent() {
    let mut field = TileField::new(5, 5, 1, TileTopology::Square).unwrap();
    let mut full = TileLightMap::from_field(&field).unwrap();
    let mut dirty = TileLightMap::from_field(&field).unwrap();
    let options = ComputeOptions {
        include_point_lights: false,
        include_line_lights: false,
        include_area_lights: false,
        include_sun_light: true,
        ambient: Some(LightColor::BLACK),
        time_seconds: 0.0,
    };
    full.set_sun_light(GlobalLight {
        intensity: 0.8,
        color: LightColor::WHITE,
        mode: SunLightMode::Top,
    });
    dirty.set_sun_light(GlobalLight {
        intensity: 0.8,
        color: LightColor::WHITE,
        mode: SunLightMode::Top,
    });
    full.compute_with_options(&field, options).unwrap();
    dirty.compute_dirty(&field, options).unwrap();
    assert_eq!(full.computed_field_version(), Some(field.version()));
    assert!(!dirty.is_dirty(&field));
    for z in 0..1 {
        for y in 0..5 {
            for x in 0..5 {
                let coord = CellCoord { x, y, z };
                assert!(
                    (full.light_at(coord).luma() - dirty.light_at(coord).luma()).abs() < 0.0001
                );
            }
        }
    }
    field
        .set_sun_occlusion(CellCoord { x: 2, y: 2, z: 0 }, 1.0)
        .unwrap();
    assert!(dirty.is_dirty(&field));
    assert!(dirty.ensure_current(&field).is_err());
    dirty.compute_dirty(&field, options).unwrap();
    assert!(!dirty.is_dirty(&field));
}

#[test]
fn line_area_exports_and_topologies_remain_bounded() {
    let field = TileField::new(6, 6, 1, TileTopology::Hex).unwrap();
    let mut map = TileLightMap::from_field(&field).unwrap();
    map.add_line_light(
        &field,
        CellCoord { x: 1, y: 1, z: 0 },
        CellCoord { x: 3, y: 2, z: 0 },
        1.5,
        1.0,
        LightColor::WHITE,
        LightModulation::default(),
    )
    .unwrap();
    map.add_area_light(
        &field,
        CellCoord { x: 2, y: 2, z: 0 },
        2,
        2,
        1.0,
        1.0,
        LightColor::WHITE,
        LightModulation::default(),
    )
    .unwrap();
    map.compute(
        &field,
        false,
        true,
        true,
        false,
        Some(LightColor::BLACK),
        0.0,
    )
    .unwrap();
    assert_eq!(map.export_layer(0).unwrap().len(), 36);
    assert!(map.export_layer(1).is_err());
    assert_eq!(map.export_volume().unwrap().len(), 1);
}

#[test]
fn settings_and_modulation_validation_stay_out_of_runtime_state() {
    let field = TileField::new(3, 3, 1, TileTopology::Square).unwrap();
    let mut map = TileLightMap::from_field(&field).unwrap();
    assert!(map
        .try_set_ambient_light(LightColor {
            r: f32::NAN,
            g: 0.0,
            b: 0.0,
        })
        .is_err());
    assert!(map
        .try_set_sun_light(GlobalLight {
            intensity: f32::INFINITY,
            color: LightColor::WHITE,
            mode: SunLightMode::Top,
        })
        .is_err());
    let modulation = LightModulation {
        intensity_amplitude: 2.0,
        ..Default::default()
    };
    assert!(map
        .add_point_light(&field, 0, 0, 0, 1.0, 1.0, LightColor::WHITE, modulation,)
        .is_err());
}

#[test]
fn compute_reports_versions_work_and_uses_dirty_noop() {
    let field = TileField::new(3, 3, 1, TileTopology::Square).unwrap();
    let mut map = TileLightMap::from_field(&field).unwrap();
    let options = ComputeOptions {
        include_point_lights: false,
        include_line_lights: false,
        include_area_lights: false,
        include_sun_light: false,
        ambient: Some(LightColor::WHITE),
        time_seconds: -2.0,
    };
    map.compute_with_options(&field, options).unwrap();
    assert_eq!(map.computed_field_version(), Some(field.version()));
    assert_eq!(map.last_affected_cells(), 9);
    assert!(map.last_compute_work() >= 9);
    let work = map.last_compute_work();
    map.compute_dirty(&field, options).unwrap();
    assert_eq!(map.last_compute_work(), work);
}
