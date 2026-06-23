//! Internal tests for tilefield domain behavior that sits below the public Lua API.

use lurek2d::tilefield::{
    CellCoord, GlobalLight, LightColor, TileChannel, TileField, TileTopology,
};

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
fn point_light_respects_light_blockers() {
    let mut field = TileField::new(6, 3, 1, TileTopology::Square).unwrap();
    field
        .set_block(CellCoord { x: 2, y: 1, z: 0 }, TileChannel::Light, true)
        .unwrap();
    field
        .add_point_light(0, 1, 0, 6.0, 1.0, LightColor::WHITE)
        .unwrap();
    field.compute_light(true, false, LightColor::BLACK);

    let near = field.light_at(CellCoord { x: 1, y: 1, z: 0 }).luma();
    let behind_wall = field.light_at(CellCoord { x: 4, y: 1, z: 0 }).luma();

    assert!(near > 0.0);
    assert_eq!(behind_wall, 0.0);
}

#[test]
fn point_light_uses_light_cost_as_partial_transmission() {
    let mut field = TileField::new(7, 3, 1, TileTopology::Square).unwrap();
    field
        .set_cost(CellCoord { x: 2, y: 1, z: 0 }, TileChannel::Light, 0.5)
        .unwrap();
    field
        .add_point_light(0, 1, 0, 8.0, 1.0, LightColor::WHITE)
        .unwrap();
    field.compute_light(true, false, LightColor::BLACK);

    let before_filter = field.light_at(CellCoord { x: 1, y: 1, z: 0 }).luma();
    let behind_filter = field.light_at(CellCoord { x: 4, y: 1, z: 0 }).luma();
    let expected = 0.5 * (1.0 - 4.0 / 8.0);

    assert!(before_filter > behind_filter);
    assert!((behind_filter - expected).abs() < 0.001);
}

#[test]
fn square_point_light_uses_radial_euclidean_distance() {
    let mut field = TileField::new(5, 5, 1, TileTopology::Square).unwrap();
    field
        .add_point_light(0, 0, 0, 2.0, 1.0, LightColor::WHITE)
        .unwrap();
    field.compute_light(true, false, LightColor::BLACK);

    let straight_edge = field.light_at(CellCoord { x: 2, y: 0, z: 0 }).luma();
    let diagonal_outside = field.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma();

    assert_eq!(straight_edge, 0.0);
    assert_eq!(diagonal_outside, 0.0);

    field
        .add_point_light(
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
        )
        .unwrap();
    field.compute_light(true, false, LightColor::BLACK);
    let diagonal_inside = field.light_at(CellCoord { x: 2, y: 2, z: 0 }).luma();

    assert!(diagonal_inside > 0.0);
}

#[test]
fn colored_point_lights_add_by_channel_and_clamp() {
    let mut field = TileField::new(5, 3, 1, TileTopology::Square).unwrap();
    field
        .add_point_light(
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
        )
        .unwrap();
    field
        .add_point_light(
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
        )
        .unwrap();
    field.compute_light(true, false, LightColor::BLACK);

    let mixed = field.light_at(CellCoord { x: 2, y: 1, z: 0 });

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
    field.set_global_light(GlobalLight {
        intensity: 1.0,
        color: LightColor::WHITE,
    });
    field.compute_light(false, true, LightColor::BLACK);

    let top = field.light_at(CellCoord { x: 0, y: 0, z: 2 }).luma();
    let lower = field.light_at(CellCoord { x: 0, y: 0, z: 1 }).luma();

    assert!(top > lower);
    assert!(lower > 0.0);
}

#[test]
fn global_light_preserves_dusk_and_night_color() {
    let mut field = TileField::new(1, 1, 2, TileTopology::Square).unwrap();
    field
        .set_sun_occlusion(CellCoord { x: 0, y: 0, z: 1 }, 0.25)
        .unwrap();
    field.set_global_light(GlobalLight {
        intensity: 0.4,
        color: LightColor {
            r: 1.0,
            g: 0.55,
            b: 0.25,
        },
    });
    field.compute_light(false, true, LightColor::BLACK);
    let dusk_lower = field.light_at(CellCoord { x: 0, y: 0, z: 0 });

    field.set_global_light(GlobalLight {
        intensity: 0.12,
        color: LightColor {
            r: 0.22,
            g: 0.32,
            b: 1.0,
        },
    });
    field.compute_light(false, true, LightColor::BLACK);
    let night_lower = field.light_at(CellCoord { x: 0, y: 0, z: 0 });

    assert!(dusk_lower.r > dusk_lower.b);
    assert!(night_lower.b > night_lower.r);
    assert!(dusk_lower.luma() > night_lower.luma());
}
