//! Internal tests for tilefield domain behavior below the public Lua API.

use lurek2d::tilefield::{
    CellCoord, TileCategory, TileCategoryKind, TileChannel, TileField, TileFieldLimits,
    TileFieldMap, TileModifier, TileTopology,
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
fn edit_dirty_rects_can_be_drained_as_a_batch() {
    let mut field = TileField::new(4, 4, 1, TileTopology::Square).unwrap();
    field.begin_edit();
    field
        .set_ref(CellCoord { x: 1, y: 1, z: 0 }, "foreground".to_string(), 7)
        .unwrap();
    field
        .set_resource(CellCoord { x: 2, y: 1, z: 0 }, Some("copper".to_string()))
        .unwrap();
    assert_eq!(field.dirty_rects().len(), 1);
    assert_eq!(field.commit_edit(), vec![(1, 1, 0, 2, 1)]);
    assert!(field.dirty_rects().is_empty());
}

#[test]
fn snapshot_support_lists_are_deterministic() {
    let mut field = TileField::new(4, 4, 1, TileTopology::Square).unwrap();
    field
        .set_resource(CellCoord { x: 2, y: 0, z: 0 }, Some("ore".to_string()))
        .unwrap();
    field
        .set_buildable(CellCoord { x: 1, y: 0, z: 0 }, false)
        .unwrap();
    field
        .set_occupant(CellCoord { x: 3, y: 0, z: 0 }, 42)
        .unwrap();
    assert_eq!(field.resource_cells()[0].1, "ore");
    assert!(!field.buildable_cells()[0].1);
    assert_eq!(field.occupant_cells()[0].1, 42);
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
fn explicit_limits_reject_field_and_map_products_before_allocation() {
    let limits = TileFieldLimits {
        max_cells_per_field: 4,
        max_fields_per_map: 2,
        max_cells_per_field_map: 8,
        ..TileFieldLimits::default()
    };
    assert!(TileField::new_with_limits(3, 2, 1, TileTopology::Square, limits).is_err());
    assert!(TileFieldMap::new_with_limits(2, 2, 1, 2, 2, 1, TileTopology::Square, limits).is_err());
}

#[test]
fn finite_values_and_custom_category_cleanup_are_enforced() {
    let mut field = TileField::new(2, 2, 1, TileTopology::Square).unwrap();
    field
        .define_category(
            TileCategory::new("heat".to_string(), TileCategoryKind::Custom, true).unwrap(),
        )
        .unwrap();
    field
        .set_category_filter(
            CellCoord { x: 0, y: 0, z: 0 },
            "heat".to_string(),
            [1.0, 0.5, 0.25],
        )
        .unwrap();
    assert!(field
        .set_cost(CellCoord { x: 0, y: 0, z: 0 }, TileChannel::Move, f32::NAN)
        .is_err());
    assert!(field.remove_category("heat").unwrap());
    assert!(field
        .cell(CellCoord { x: 0, y: 0, z: 0 })
        .unwrap()
        .category_filters()
        .is_empty());
}

#[test]
fn modifier_and_region_limits_reject_hostile_input() {
    let limits = TileFieldLimits {
        max_modifiers: 1,
        max_regions: 1,
        max_cells_per_region: 2,
        ..TileFieldLimits::default()
    };
    let mut field = TileField::new_with_limits(3, 3, 1, TileTopology::Square, limits).unwrap();
    assert!(field
        .set_modifier(
            "extra".to_string(),
            TileModifier::new("extra".to_string()).unwrap()
        )
        .is_err());
    assert!(field
        .set_region_rect("large".to_string(), 0, 0, 2, 2, 0)
        .is_err());
}
