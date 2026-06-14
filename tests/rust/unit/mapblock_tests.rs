use lurek2d::mapblock::placement::{find_valid_placements, PlacementSearch};
use lurek2d::mapblock::{
    Edge, MapBlock, MapBlockConfig, MapBlockGenerator, MapGroup, MapScript, NeighborRules,
    ScriptStep, StepType,
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
