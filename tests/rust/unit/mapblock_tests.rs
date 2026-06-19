use lurek2d::mapblock::placement::{find_valid_placements, PlacementSearch};
use lurek2d::mapblock::{
    Edge, MapBlock, MapBlockConfig, MapBlockError, MapBlockGenerator, MapGroup, MapScript,
    NeighborRules, PlacedBlock, PlacementGrid, PlacementGridValidationError, ScriptStep,
    SolveFailureReason, SolverBudget, StepType,
};

fn config_with_segment(segment_size: u32) -> MapBlockConfig {
    let mut config = MapBlockConfig::new();
    config.set_default_segment_size(segment_size);
    config
}

#[test]
fn transformed_socket_map_normalizes_rotation() {
    let config = config_with_segment(1);
    let mut block = MapBlock::new(2, 2, 1, &config);
    block.set_footprint(&[(0, 0), (1, 0), (0, 1)]);
    block.set_socket(1, 0, Edge::East, 7);

    let rotated = block.transformed_footprint(1, false);
    assert_eq!(rotated, vec![(0, 0), (0, 1), (1, 1)]);
    assert_eq!(block.transformed_socket(0, 0, Edge::South, 1, false), 7);
    assert_eq!(block.transformed_socket(0, 0, Edge::East, 1, false), 0);
}

#[test]
fn find_valid_placements_supports_irregular_shapes_and_rotations() {
    let config = config_with_segment(1);
    let mut block = MapBlock::new(2, 1, 1, &config);
    block.set_footprint(&[(0, 0), (1, 0)]);
    block.set_name("domino");

    let mut group = MapGroup::new("roads");
    group.add_block(block);

    let mut groups = std::collections::HashMap::new();
    groups.insert(group.name().to_string(), group);

    let mut grid = lurek2d::mapblock::PlacementGrid::new();
    grid.add_positions(&[(0, 0), (1, 0), (2, 0), (1, 1)]);

    let rules = NeighborRules::new();
    let search = PlacementSearch {
        groups: &groups,
        group_name: "roads",
        block_index: 0,
        rules: &rules,
        match_sides: false,
        rotations: &[0, 1],
        mirrors: &[false],
    };
    let placements = find_valid_placements(&grid, &search);

    assert!(placements.iter().any(|candidate| {
        candidate.grid_x == 1 && candidate.grid_y == 0 && candidate.rotation == 1
    }));
    assert!(placements.iter().all(|candidate| {
        candidate
            .occupied_cells
            .iter()
            .all(|cell| grid.is_available(cell.0, cell.1))
    }));
}

#[test]
fn generator_result_keeps_group_identity_in_tiles_and_placements() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(2, 1);

    let mut grass = MapBlock::new(1, 1, 1, &config);
    grass.set_name("grass");
    grass.set_tile(0, 0, 0, 0, 1, 11);

    let mut water = MapBlock::new(1, 1, 1, &config);
    water.set_name("water");
    water.set_tile(0, 0, 0, 0, 1, 22);

    let mut terrain = MapGroup::new("terrain");
    terrain.add_block(grass);
    let mut rivers = MapGroup::new("rivers");
    rivers.add_block(water);

    gen.add_group(terrain);
    gen.add_group(rivers);

    let mut script = MapScript::new("two_groups");
    script.add_step(ScriptStep {
        step_type: StepType::PlaceBlock,
        group_name: "terrain".to_string(),
        block_index: 0,
        x: 0,
        y: 0,
        has_position: true,
        ..Default::default()
    });
    script.add_step(ScriptStep {
        step_type: StepType::PlaceBlock,
        group_name: "rivers".to_string(),
        block_index: 0,
        x: 1,
        y: 0,
        has_position: true,
        ..Default::default()
    });

    let result = gen.generate(&script);

    assert_eq!(result.get_gid(0, 0, 0, 0, 0), 11);
    assert_eq!(result.get_gid(0, 0, 1, 0, 0), 22);
    assert_eq!(result.placements().len(), 2);
    assert_eq!(result.placements()[0].group_name, "terrain");
    assert_eq!(result.placements()[1].group_name, "rivers");
    assert_eq!(result.placements()[1].block_name, "water");
}

#[test]
fn mapblock_try_new_rejects_huge_dimensions() {
    let config = MapBlockConfig::new();
    let err = MapBlock::try_new(16_384, 1, 1, &config).unwrap_err();

    assert!(matches!(
        err,
        MapBlockError::DimensionsTooLarge {
            width: 16_384,
            height: 1,
            ..
        }
    ));
}

#[test]
fn mapblock_try_new_rejects_zero_slots_and_too_many_layers() {
    let empty_config = MapBlockConfig::empty();
    assert!(matches!(
        MapBlock::try_new(1, 1, 1, &empty_config),
        Err(MapBlockError::ZeroSlots)
    ));

    let mut config = MapBlockConfig::new();
    config.set_max_layers(2);
    assert!(matches!(
        MapBlock::try_new(1, 1, 3, &config),
        Err(MapBlockError::TooManyLayers {
            layers: 3,
            max_layers: 2,
        })
    ));
}

#[test]
fn block_validate_rejects_invalid_weight_and_invalid_sockets() {
    let config = config_with_segment(1);
    let mut block = MapBlock::new(1, 1, 1, &config);

    block.weight = f32::NAN;
    assert!(matches!(
        block.validate(),
        Err(MapBlockError::InvalidWeight { .. })
    ));

    block.weight = 1.0;
    block.set_socket(2, 0, Edge::East, 7);
    assert!(matches!(
        block.validate(),
        Err(MapBlockError::SocketOutsideFootprint {
            x: 2,
            y: 0,
            edge: Edge::East,
        })
    ));

    let mut block = MapBlock::new(1, 1, 1, &config);
    assert!(matches!(
        block.try_set_edge(Edge::North, 1, 9),
        Err(MapBlockError::EdgeSegmentOutOfRange {
            edge: Edge::North,
            segment: 1,
            max_segments: 1,
        })
    ));
}

#[test]
fn placement_grid_validate_detects_invariant_break() {
    let mut grid = PlacementGrid::new_rect(1, 1);
    let placed = PlacedBlock {
        group_name: "terrain".to_string(),
        block_index: 0,
        grid_x: 0,
        grid_y: 0,
        level: 0,
        rotation: 0,
        mirrored: false,
        occupied_cells: vec![(0, 0)],
    };

    assert!(grid.place_block(placed));
    grid.remove_position(0, 0);

    assert_eq!(grid.available_count(), 0);
    assert!(matches!(
        grid.validate(),
        Err(PlacementGridValidationError::OccupiedOutsideAvailable { cell: (0, 0) })
    ));
}

#[test]
fn generate_with_report_tracks_missing_group_and_unsupported_steps() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config);
    gen.set_rect_shape(1, 1);

    let mut script = MapScript::new("diagnostics");
    script.add_step(ScriptStep {
        step_type: StepType::PlaceLine,
        ..Default::default()
    });
    script.add_step(ScriptStep {
        step_type: StepType::PlaceRandom,
        group_name: "missing".to_string(),
        ..Default::default()
    });

    let (_result, report) = gen.generate_with_report(&script);

    assert_eq!(report.diagnostics.unsupported_steps, 1);
    assert_eq!(report.diagnostics.missing_groups, 1);
    assert_eq!(report.placements_committed, 0);
    assert_eq!(gen.last_report(), &report);
}

#[test]
fn generate_with_report_rejects_level_span_overflow() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(1, 1);
    gen.set_max_levels(1);

    let mut block = MapBlock::new(1, 1, 1, &config);
    block.level_span = 2;

    let mut group = MapGroup::new("terrain");
    group.add_block(block);
    gen.add_group(group);

    let mut script = MapScript::new("overflow");
    script.add_step(ScriptStep {
        step_type: StepType::PlaceBlock,
        group_name: "terrain".to_string(),
        block_index: 0,
        x: 0,
        y: 0,
        has_position: true,
        ..Default::default()
    });

    let (result, report) = gen.generate_with_report(&script);

    assert_eq!(report.diagnostics.level_overflows, 1);
    assert_eq!(report.placements_committed, 0);
    assert_eq!(result.get_gid(0, 0, 0, 0, 0), 0);
}

#[test]
fn generate_with_report_keeps_same_seed_deterministic_with_invalid_weights() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(1, 1);
    gen.set_seed(99);

    let mut a = MapBlock::new(1, 1, 1, &config);
    a.set_tile(0, 0, 0, 0, 1, 11);
    a.weight = f32::NAN;

    let mut b = MapBlock::new(1, 1, 1, &config);
    b.set_tile(0, 0, 0, 0, 1, 22);
    b.weight = f32::INFINITY;

    let mut group = MapGroup::new("terrain");
    group.add_block(a);
    group.add_block(b);
    gen.add_group(group);

    let mut script = MapScript::new("fallback");
    script.add_step(ScriptStep {
        step_type: StepType::PlaceRandom,
        group_name: "terrain".to_string(),
        ..Default::default()
    });

    let (first, first_report) = gen.generate_with_report(&script);
    gen.set_seed(99);
    let (second, second_report) = gen.generate_with_report(&script);

    assert_eq!(first.get_gid(0, 0, 0, 0, 0), second.get_gid(0, 0, 0, 0, 0));
    assert!(first_report.diagnostics.invalid_weights > 0);
    assert!(first_report.diagnostics.zero_weight_fallbacks > 0);
    assert_eq!(first_report, second_report);
}

#[test]
fn solve_shape_budget_exceeded_returns_reason() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(2, 2);
    gen.set_solver_budget(SolverBudget {
        max_nodes: 1,
        max_depth: 16,
        max_ms: 5_000,
        max_candidates_per_cell: 8,
    });

    let mut block = MapBlock::new(1, 1, 1, &config);
    block.set_name("floor");
    let mut group = MapGroup::new("terrain");
    group.add_block(block);
    gen.add_group(group);

    let mut script = MapScript::new("budget");
    script.add_step(ScriptStep {
        step_type: StepType::SolveShape,
        group_name: "terrain".to_string(),
        ..Default::default()
    });

    let (result, report) = gen.generate_with_report(&script);

    assert!(result.is_empty());
    assert_eq!(report.diagnostics.solve_failures, 1);
    assert_eq!(
        report.solve_failure_reason,
        Some(SolveFailureReason::BudgetExceeded)
    );
    assert!(report.visited_nodes >= 1);
    assert!(report.candidates_tested >= 1);
}

#[test]
fn generate_with_report_tracks_transform_cache_hits() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(2, 1);

    let mut block = MapBlock::new(1, 1, 1, &config);
    block.set_name("floor");
    let mut group = MapGroup::new("terrain");
    group.add_block(block);
    gen.add_group(group);

    let mut script = MapScript::new("cache");
    script.add_step(ScriptStep {
        step_type: StepType::FillRandom,
        group_name: "terrain".to_string(),
        count: 2,
        ..Default::default()
    });

    let (_result, report) = gen.generate_with_report(&script);

    assert!(report.transform_cache_misses >= 1);
    assert!(report.transform_cache_hits >= 1);
}

#[test]
fn fill_rect_reports_clipped_and_rejected_status() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(1, 1);

    let mut script = MapScript::new("paint");
    script.add_step(ScriptStep {
        step_type: StepType::FillRect,
        x: -1,
        y: 0,
        width: 2,
        height: 1,
        layer: 0,
        level: 0,
        slot_index: 0,
        ..Default::default()
    });
    script.add_step(ScriptStep {
        step_type: StepType::FillRect,
        x: 99,
        y: 99,
        width: 1,
        height: 1,
        layer: 0,
        level: 0,
        slot_index: 0,
        ..Default::default()
    });
    script.add_step(ScriptStep {
        step_type: StepType::FillRect,
        x: 0,
        y: 0,
        width: 1,
        height: 1,
        layer: config.max_layers,
        level: 0,
        slot_index: 0,
        ..Default::default()
    });

    let (_result, report) = gen.generate_with_report(&script);

    assert_eq!(report.diagnostics.clipped_paint_ops, 1);
    assert_eq!(report.diagnostics.rejected_paint_ops, 2);
    assert_eq!(report.diagnostics.invalid_paint_ops, 1);
}

#[test]
fn auto_place_large_attempt_budget_breaks_on_no_progress() {
    let config = config_with_segment(1);
    let mut gen = MapBlockGenerator::new(config.clone());
    gen.set_rect_shape(1, 1);

    let mut block = MapBlock::new(2, 1, 1, &config);
    block.set_footprint(&[(0, 0), (1, 0)]);
    let mut group = MapGroup::new("terrain");
    group.add_block(block);
    gen.add_group(group);

    let mut script = MapScript::new("auto_place");
    script.add_step(ScriptStep {
        step_type: StepType::AutoPlace,
        group_name: "terrain".to_string(),
        count: u32::MAX,
        ..Default::default()
    });

    let (result, report) = gen.generate_with_report(&script);

    assert!(result.is_empty());
    assert_eq!(report.diagnostics.no_progress_breaks, 1);
    assert!(report.diagnostics.no_candidates >= 1);
}
