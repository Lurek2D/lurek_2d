//! Internal regression tests for tile-light storage validation.

use lurek2d::tilefield::{CellCoord, TileChannel, TileField, TileTopology};
use lurek2d::tilelight::{GlobalLight, LightColor, LightModulation, SunLightMode, TileLightMap};

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
    assert_eq!(light.light_at(CellCoord { x: 4, y: 1, z: 0 }).luma(), 0.0);
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
    assert_eq!(light.light_at(CellCoord { x: 2, y: 0, z: 0 }).luma(), 0.0);
    assert_eq!(light.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma(), 0.0);
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
    assert_eq!(mixed.g, 0.0);
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
