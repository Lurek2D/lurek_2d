//! Private-domain coverage for checked atlas arithmetic and tileset metadata seams.

use lurek2d::tilefield::TileRef;
use lurek2d::tileset::{
    AutoTileMode, TerrainProfile, TileAnimFrame, TileCatalog, TileObjectArchetype, TileObjectLight,
    TileSet, TileVisual, TilesetError, TilesetLimits,
};

#[test]
fn checked_constructor_rejects_zero_and_gid_overflow() {
    assert!(matches!(
        TileSet::try_new(1, 0, 1, 16, 16, 0, 0),
        Err(TilesetError::InvalidValue { .. })
    ));
    assert!(matches!(
        TileSet::try_new(u32::MAX, 2, 1, 16, 16, 0, 0),
        Err(TilesetError::GidRangeOverflow { .. })
    ));
    assert!(matches!(
        TileSet::try_new(1, 2, 1, 0, 16, 0, 0),
        Err(TilesetError::InvalidValue { .. })
    ));
}

#[test]
fn checked_atlas_dimensions_are_exact_and_quad_queries_fail() {
    let tileset = TileSet::try_new(1, 5, 2, 16, 16, 1, 2).unwrap();
    assert_eq!(tileset.get_texture_width(), 37);
    assert_eq!(tileset.get_texture_height(), 54);
    let quad = tileset.try_get_quad(2).unwrap();
    assert!((quad.x - 2.0).abs() < f32::EPSILON);
    assert!((quad.y - 19.0).abs() < f32::EPSILON);
    assert!((quad.width - 16.0).abs() < f32::EPSILON);
    assert!((quad.height - 16.0).abs() < f32::EPSILON);
    assert!(matches!(
        tileset.try_get_quad(5),
        Err(TilesetError::TileIdOutOfBounds { .. })
    ));
}

#[test]
fn mutation_validation_covers_ids_frames_properties_and_rules() {
    let mut tileset = TileSet::try_new(1, 4, 2, 16, 16, 0, 0).unwrap();
    assert!(matches!(
        tileset.set_animation(
            4,
            vec![TileAnimFrame {
                tile_id: 0,
                duration_ms: 10.0,
            }]
        ),
        Err(TilesetError::TileIdOutOfBounds { .. })
    ));
    assert!(matches!(
        tileset.set_animation(
            0,
            vec![TileAnimFrame {
                tile_id: 0,
                duration_ms: f32::NAN,
            }]
        ),
        Err(TilesetError::InvalidValue { .. })
    ));
    assert!(matches!(
        tileset.set_animation(
            0,
            vec![TileAnimFrame {
                tile_id: 4,
                duration_ms: 10.0,
            }]
        ),
        Err(TilesetError::TileIdOutOfBounds { .. })
    ));
    tileset
        .set_property(1, "biome".to_string(), Some("forest".to_string()))
        .unwrap();
    tileset.set_property(1, "biome".to_string(), None).unwrap();
    assert!(tileset.properties(1).is_none());
    assert!(tileset
        .set_property(4, "bad".to_string(), Some("x".to_string()))
        .is_err());
    assert!(tileset.set_auto_tile_rule("", 0, 0).is_err());
    assert!(tileset.set_auto_tile_rule("wall", 0, 4).is_err());
    tileset.set_auto_tile_rule("wall", 3, 1).unwrap();
    tileset.set_auto_tile_rule_8("wall", 0xFF, 2).unwrap();
    assert_eq!(tileset.get_auto_tile_id("wall", 3), Some(1));
    assert_eq!(tileset.get_auto_tile_id_8("wall", 0xFF), Some(2));
    assert_eq!(
        tileset.get_auto_tile_mode("unknown"),
        AutoTileMode::MatchSides
    );
}

#[test]
fn archetype_validation_rejects_non_finite_defaults_and_detach_is_clean() {
    let mut tileset = TileSet::try_new(1, 4, 2, 16, 16, 0, 0).unwrap();
    let mut invalid = TileObjectArchetype::new("lamp".to_string()).unwrap();
    invalid.light = Some(TileObjectLight {
        radius: f32::INFINITY,
        intensity: 1.0,
        color: [1.0, 1.0, 1.0],
    });
    assert!(tileset.set_archetype(invalid).is_err());

    let mut visual = TileObjectArchetype::new("crate".to_string()).unwrap();
    visual.visual = Some(TileVisual {
        image: Some("crate.png".to_string()),
        tile_id: Some(2),
        ..TileVisual::default()
    });
    tileset.set_archetype(visual).unwrap();
    tileset
        .set_tile_archetype(1, Some("crate".to_string()))
        .unwrap();
    assert!(tileset.archetype_for_tile(1).is_some());
    assert!(tileset.remove_archetype("crate"));
    assert!(tileset.archetype_for_tile(1).is_none());
}

#[test]
fn catalogs_are_sorted_and_use_snapshot_semantics() {
    let mut original = TileSet::try_new(1, 4, 2, 16, 16, 0, 0).unwrap();
    let mut object = TileObjectArchetype::new("crate".to_string()).unwrap();
    object.visual = Some(TileVisual {
        image: Some("crate.png".to_string()),
        ..TileVisual::default()
    });
    original.set_archetype(object).unwrap();
    let catalog = TileCatalog::from_entries(vec![
        (
            "z_props".to_string(),
            TileSet::try_new(1, 1, 1, 8, 8, 0, 0).unwrap(),
        ),
        ("a_props".to_string(), original.clone()),
    ])
    .unwrap();
    assert_eq!(catalog.ids(), vec!["a_props", "z_props"]);
    let reference = TileRef::object("a_props".to_string(), "crate".to_string()).unwrap();
    assert_eq!(
        catalog.visual_for_ref(&reference).unwrap().image.as_deref(),
        Some("crate.png")
    );
    original.remove_archetype("crate");
    assert!(catalog.visual_for_ref(&reference).is_some());
    original
        .set_terrain_profile(
            "ground",
            TerrainProfile {
                terrain_set: "terrain".to_string(),
                mode: AutoTileMode::MatchCornersAndSides,
                default_tile_id: Some(0),
            },
        )
        .unwrap();
}

#[test]
fn explicit_limits_fail_before_nested_growth() {
    let limits = TilesetLimits {
        max_tile_count: 4,
        max_columns: 4,
        max_atlas_dimension: 64,
        max_spacing: 4,
        max_margin: 4,
        max_archetypes: 1,
        max_catalog_entries: 1,
        max_properties_per_owner: 1,
        max_total_properties: 1,
        max_animation_sequences: 1,
        max_animation_frames: 1,
        max_autotile_rules_4: 1,
        max_autotile_rules_8: 1,
        max_terrain_profiles: 1,
        max_name_bytes: 8,
        max_string_bytes: 8,
        max_footprint_dimension: 2,
        max_numeric_value: 100.0,
    };
    let mut tileset = TileSet::try_new_with_limits(1, 4, 2, 16, 16, 0, 0, limits).unwrap();
    tileset
        .set_property(0, "a".to_string(), Some("1".to_string()))
        .unwrap();
    assert!(tileset
        .set_property(0, "b".to_string(), Some("2".to_string()))
        .is_err());
}

#[test]
fn geometry_getters_preserve_valid_constructor_values() {
    let tileset = TileSet::try_new(7, 6, 3, 12, 20, 2, 4).unwrap();
    assert_eq!(tileset.get_first_gid(), 7);
    assert_eq!(tileset.get_tile_count(), 6);
    assert_eq!(tileset.get_columns(), 3);
    assert_eq!(tileset.get_tile_width(), 12);
    assert_eq!(tileset.get_tile_height(), 20);
    assert_eq!(tileset.get_tile_dimensions(), (12, 20));
    assert_eq!(tileset.get_spacing(), 2);
    assert_eq!(tileset.get_margin(), 4);
}

#[test]
fn animation_storage_returns_borrowed_frames_and_ids() {
    let mut tileset = TileSet::try_new(1, 3, 3, 8, 8, 0, 0).unwrap();
    tileset
        .set_animation(
            1,
            vec![TileAnimFrame {
                tile_id: 2,
                duration_ms: 25.0,
            }],
        )
        .unwrap();
    assert_eq!(tileset.get_animation(1).unwrap()[0].tile_id, 2);
    assert!(tileset.iter_animated_local_ids().eq([1]));
}

#[test]
fn property_and_archetype_name_queries_are_stable() {
    let mut tileset = TileSet::try_new(1, 2, 2, 8, 8, 0, 0).unwrap();
    tileset
        .set_property(0, "kind".to_string(), Some("floor".to_string()))
        .unwrap();
    assert_eq!(tileset.get_property(0, "kind"), Some("floor"));
    let first = TileObjectArchetype::new("z".to_string()).unwrap();
    let second = TileObjectArchetype::new("a".to_string()).unwrap();
    tileset.set_archetype(first).unwrap();
    tileset.set_archetype(second).unwrap();
    assert_eq!(tileset.archetype_names(), vec!["a", "z"]);
}

#[test]
fn terrain_profile_and_mode_queries_round_trip() {
    let mut tileset = TileSet::try_new(1, 3, 3, 8, 8, 0, 0).unwrap();
    tileset
        .set_auto_tile_mode("terrain", AutoTileMode::MatchCorners)
        .unwrap();
    assert!(tileset.has_auto_tile_mode("terrain"));
    assert_eq!(
        tileset.get_auto_tile_mode("terrain"),
        AutoTileMode::MatchCorners
    );
    tileset
        .set_terrain_profile(
            "ground",
            TerrainProfile {
                terrain_set: "terrain".to_string(),
                mode: AutoTileMode::MatchSides,
                default_tile_id: Some(2),
            },
        )
        .unwrap();
    assert_eq!(
        tileset
            .get_terrain_profile("ground")
            .unwrap()
            .default_tile_id,
        Some(2)
    );
}

#[test]
fn limits_and_mapping_queries_reject_unknown_data() {
    let mut tileset = TileSet::try_new(1, 2, 2, 8, 8, 0, 0).unwrap();
    let object = TileObjectArchetype::new("crate".to_string()).unwrap();
    tileset.set_archetype(object).unwrap();
    assert_eq!(tileset.get_tile_archetype(0), None);
    assert!(tileset.archetype("missing").is_none());
    assert!(tileset.archetype_for_tile(1).is_none());
    assert_eq!(
        tileset.limits().max_tile_count,
        TilesetLimits::default().max_tile_count
    );
}

#[test]
fn tile_object_mapping_can_be_set_and_cleared() {
    let mut tileset = TileSet::try_new(1, 2, 2, 8, 8, 0, 0).unwrap();
    tileset
        .set_archetype(TileObjectArchetype::new("crate".to_string()).unwrap())
        .unwrap();
    tileset
        .set_tile_archetype(0, Some("crate".to_string()))
        .unwrap();
    assert_eq!(tileset.get_tile_archetype(0), Some("crate"));
    tileset.set_tile_archetype(0, None).unwrap();
    assert_eq!(tileset.get_tile_archetype(0), None);
}

#[test]
fn catalog_tileset_lookup_returns_snapshot_entry() {
    let tileset = TileSet::try_new(1, 2, 2, 8, 8, 0, 0).unwrap();
    let catalog = TileCatalog::from_entries(vec![("terrain".to_string(), tileset)]).unwrap();
    assert_eq!(catalog.tileset("terrain").unwrap().get_tile_count(), 2);
    assert!(catalog.tileset("missing").is_none());
}

#[test]
fn shape_and_mode_names_use_stable_vocabulary() {
    use lurek2d::tileset::TileObjectShapeKind;
    assert_eq!(
        TileObjectShapeKind::parse("rectangle").unwrap().as_str(),
        "rect"
    );
    assert!(TileObjectShapeKind::parse("unknown").is_err());
    assert_eq!(
        AutoTileMode::MatchCornersAndSides.as_str(),
        "matchCornersAndSides"
    );
}

#[test]
fn visual_validation_accepts_identifier_only_records() {
    let visual = TileVisual {
        image: Some("tiles.png".to_string()),
        ..TileVisual::default()
    };
    visual.validate(&TilesetLimits::default()).unwrap();
    assert!(visual
        .validate(&TilesetLimits {
            max_string_bytes: 4,
            ..TilesetLimits::default()
        })
        .is_err());
}

#[test]
fn error_constructor_keeps_field_context() {
    let error = TilesetError::invalid("tile_count", "must be positive");
    assert!(error.to_string().contains("tile_count"));
}
