//! Internal tests for tilefield domain behavior that sits below the public Lua API.

use lurek2d::tilefield::{CellCoord, TileChannel, TileField, TileFieldMap, TileTopology};
use lurek2d::tilelight::{GlobalLight, LightColor, LightModulation, SunLightMode, TileLightMap};

#[test]
fn profiles_keep_channels_independent() {
    let mut field = TileField::new(5, 5, 2, TileTopology::Square).unwrap();
    let coord = CellCoord { x: 2, y: 2, z: 0 };

    field.apply_profile(coord, "window").unwrap();

    assert!(field.blocks(coord, TileChannel::Move));
    assert!(!field.blocks(coord, TileChannel::Vision));
    assert!(field.blocks(coord, TileChannel::Action));
    assert!(!field.blocks(coord, TileChannel::Light));
}

#[test]
fn line_queries_use_requested_channel() {
    let mut field = TileField::new(6, 4, 1, TileTopology::Square).unwrap();
    let blocker = CellCoord { x: 2, y: 1, z: 0 };
    let from = CellCoord { x: 0, y: 1, z: 0 };
    let to = CellCoord { x: 5, y: 1, z: 0 };

    field.set_block(blocker, TileChannel::Vision, true).unwrap();
    field
        .set_block(blocker, TileChannel::Action, false)
        .unwrap();

    assert!(!field.clear_line(from, to, TileChannel::Vision).unwrap());
    assert!(field.clear_line(from, to, TileChannel::Action).unwrap());
}

#[test]
fn cell_refs_store_author_defined_slots() {
    let mut field = TileField::new(4, 4, 2, TileTopology::Square).unwrap();
    let coord = CellCoord { x: 1, y: 2, z: 0 };

    field.set_ref(coord, "floor".to_string(), 12).unwrap();
    field.set_ref(coord, "wall_left".to_string(), 31).unwrap();

    assert_eq!(field.get_ref(coord, "floor"), Some(12));
    assert_eq!(field.export_ref_layer("wall_left", 0)[9], Some(31));

    field.clear_ref(coord, "floor").unwrap();
    assert_eq!(field.get_ref(coord, "floor"), None);
}

#[test]
fn hex_line_uses_hex_topology() {
    let field = TileField::new(8, 8, 1, TileTopology::Hex).unwrap();
    let cells = field
        .line(
            CellCoord { x: 0, y: 0, z: 0 },
            CellCoord { x: 3, y: 0, z: 0 },
            true,
        )
        .unwrap();

    assert_eq!(cells.first().unwrap().x, 0);
    assert_eq!(cells.last().unwrap().x, 3);
    assert_eq!(cells.len(), 4);
}

#[test]
fn square4_and_square8_distances_are_distinct() {
    let square4 = TileField::new(8, 8, 1, TileTopology::Square4).unwrap();
    let square8 = TileField::new(8, 8, 1, TileTopology::Square).unwrap();
    let a = CellCoord { x: 0, y: 0, z: 0 };
    let b = CellCoord { x: 3, y: 2, z: 0 };

    assert_eq!(square4.distance(a, b), 5);
    assert_eq!(square8.distance(a, b), 3);
}

#[test]
fn field_map_stores_layered_shared_fields() {
    let map = TileFieldMap::new(2, 3, 2, 4, 5, 1, TileTopology::Square4).unwrap();

    assert_eq!(map.map_size(), (2, 3, 2));
    assert_eq!(map.field_size(), (4, 5, 1));
    assert_eq!(map.topology(), TileTopology::Square4);
    assert!(map.in_bounds(1, 2, 1));
    assert!(!map.in_bounds(2, 0, 0));

    let field = map.field(1, 2, 1).unwrap();
    field
        .borrow_mut()
        .set_ref(CellCoord { x: 2, y: 3, z: 0 }, "floor".to_string(), 77)
        .unwrap();

    assert_eq!(
        map.field(1, 2, 1)
            .unwrap()
            .borrow()
            .get_ref(CellCoord { x: 2, y: 3, z: 0 }, "floor"),
        Some(77)
    );
}

#[test]
fn field_map_rejects_incompatible_replacement_fields() {
    let mut map = TileFieldMap::new(1, 1, 1, 3, 3, 1, TileTopology::Square).unwrap();
    let wrong_size = std::rc::Rc::new(std::cell::RefCell::new(
        TileField::new(4, 3, 1, TileTopology::Square).unwrap(),
    ));
    let wrong_topology = std::rc::Rc::new(std::cell::RefCell::new(
        TileField::new(3, 3, 1, TileTopology::Hex).unwrap(),
    ));

    assert!(map.set_field(0, 0, 0, wrong_size).is_err());
    assert!(map.set_field(0, 0, 0, wrong_topology).is_err());
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

    let near = light.light_at(CellCoord { x: 1, y: 1, z: 0 }).luma();
    let behind_wall = light.light_at(CellCoord { x: 4, y: 1, z: 0 }).luma();

    assert!(near > 0.0);
    assert_eq!(behind_wall, 0.0);
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

    let straight_edge = light.light_at(CellCoord { x: 2, y: 0, z: 0 }).luma();
    let diagonal_outside = light.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma();

    assert_eq!(straight_edge, 0.0);
    assert_eq!(diagonal_outside, 0.0);

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
    let diagonal_inside = light.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma();

    assert!(diagonal_inside > 0.0);
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
