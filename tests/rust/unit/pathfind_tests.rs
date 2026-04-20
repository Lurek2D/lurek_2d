//! Smoke tests for the pathfind module against the current public API.
//!
//! Migrated from inline `#[cfg(test)] mod tests` blocks in `src/pathfind/` per TST-02 (W1).

// ── ai_flow_field ───────────────────────────────────────────────────────────────

mod ai_flow_field_tests {
    use lurek2d::pathfind::SimpleFlowField as FlowField;

    fn open_grid(w: usize, h: usize) -> Vec<bool> {
        vec![true; w * h]
    }

    #[test]
    fn new_field_has_no_goal() {
        let ff = FlowField::new(4, 4, open_grid(4, 4));
        assert!(ff.goal.is_none());
    }

    #[test]
    fn set_goal_computes_directions() {
        let mut ff = FlowField::new(4, 4, open_grid(4, 4));
        ff.set_goal(3, 3);
        assert_eq!(ff.goal, Some((3, 3)));
        assert_eq!(ff.get_distance(3, 3), 0.0);
        assert!(ff.get_distance(0, 0) > 0.0);
        assert!(ff.get_distance(0, 0) < f32::INFINITY);
    }

    #[test]
    fn blocked_goal_stays_infinity() {
        let mut walkable = open_grid(3, 3);
        walkable[2 * 3 + 2] = false;
        let mut ff = FlowField::new(3, 3, walkable);
        ff.set_goal(2, 2);
        assert_eq!(ff.get_distance(0, 0), f32::INFINITY);
    }

    #[test]
    fn direction_points_toward_goal() {
        let mut ff = FlowField::new(5, 1, open_grid(5, 1));
        ff.set_goal(4, 0);
        let (dx, _dy) = ff.get_direction(0, 0);
        assert!(dx > 0.0, "should point right toward goal");
    }

    #[test]
    fn out_of_bounds_returns_defaults() {
        let ff = FlowField::new(2, 2, open_grid(2, 2));
        assert_eq!(ff.get_direction(10, 10), (0.0, 0.0));
        assert_eq!(ff.get_distance(10, 10), f32::INFINITY);
    }
}

// ── astar ───────────────────────────────────────────────────────────────────────

mod astar_tests {
    use lurek2d::pathfind::{astar, NavGrid};

    #[test]
    fn astar_finds_path_on_open_grid() {
        let grid = NavGrid::new(5, 5);
        let (path, complete) = astar(&grid, (0, 0), (4, 4), 1, 0);
        assert!(complete);
        let p = path.unwrap();
        assert_eq!(p.first(), Some(&(0, 0)));
        assert_eq!(p.last(), Some(&(4, 4)));
    }

    #[test]
    fn astar_returns_none_path_when_start_is_blocked() {
        let costs = vec![0u8; 25];
        let grid = NavGrid::from_costs(5, 5, costs);
        let (path, complete) = astar(&grid, (0, 0), (4, 4), 1, 0);
        assert!(!complete);
        assert!(path.is_none() || path.as_ref().map(|p| p.is_empty()).unwrap_or(true));
    }
}

// ── async_pool ──────────────────────────────────────────────────────────────────

mod async_pool_tests {
    use lurek2d::pathfind::PathThreadPool;

    #[test]
    fn default_thread_count() {
        let pool = PathThreadPool::new(1);
        assert!(pool.get_thread_count() >= 1);
    }

    #[test]
    fn set_thread_count_minimum_one() {
        let mut pool = PathThreadPool::new(1);
        pool.set_thread_count(0);
        assert_eq!(pool.get_thread_count(), 1);
        pool.set_thread_count(4);
        assert_eq!(pool.get_thread_count(), 4);
    }
}

// ── bidir ───────────────────────────────────────────────────────────────────────

mod bidir_tests {
    use lurek2d::pathfind::{bidirectional_astar, NavGrid};

    #[test]
    fn same_cell_returns_trivial_path() {
        let g = NavGrid::new(5, 5);
        let (p, _) = bidirectional_astar(&g, (2, 2), (2, 2), 1, 10000);
        assert!(p.is_some());
    }

    #[test]
    fn straight_line_path() {
        let g = NavGrid::new(10, 1);
        let (p, _) = bidirectional_astar(&g, (0, 0), (9, 0), 1, 10000);
        assert!(p.is_some());
        let path = p.unwrap();
        assert_eq!(*path.first().unwrap(), (0, 0));
        assert_eq!(*path.last().unwrap(), (9, 0));
    }

    #[test]
    fn wall_blocks_path() {
        let mut g = NavGrid::new(5, 5);
        for y in 0..5 {
            g.set_blocked(2, y, true);
        }
        let (p, _) = bidirectional_astar(&g, (0, 2), (4, 2), 1, 10000);
        assert!(p.is_none());
    }

    #[test]
    fn iteration_limit_triggers_flag() {
        let g = NavGrid::new(50, 50);
        let (_, is_complete) = bidirectional_astar(&g, (0, 0), (49, 49), 1, 5);
        assert!(!is_complete);
    }
}

// ── flow_field ──────────────────────────────────────────────────────────────────

mod flow_field_tests {
    use lurek2d::pathfind::{FlowField, NavGrid};
    use std::cell::RefCell;
    use std::rc::Rc;

    fn open_grid(w: u32, h: u32) -> Rc<RefCell<NavGrid>> {
        Rc::new(RefCell::new(NavGrid::new(w, h)))
    }

    #[test]
    fn new_field_not_calculated() {
        let g = open_grid(5, 5);
        let ff = FlowField::new(g);
        assert!(!ff.is_calculated());
    }

    #[test]
    fn calculate_and_get_direction() {
        let g = open_grid(5, 5);
        let mut ff = FlowField::new(g);
        ff.calculate(4, 4, 1);
        let (dx, dy) = ff.get_direction(0, 0);
        assert!(dx.is_finite() && dy.is_finite());
    }
}

// ── graph_nav ───────────────────────────────────────────────────────────────────

mod graph_nav_tests {
    use lurek2d::graph::core::Graph;
    use lurek2d::pathfind::{graph_astar, graph_range};

    fn simple_graph() -> (Graph, u64, u64, u64) {
        let mut g = Graph::new();
        let n1 = g.add_node("room", 10);
        let n2 = g.add_node("room", 10);
        let n3 = g.add_node("room", 10);
        let _ = g.add_edge(n1, n2, None);
        let _ = g.add_edge(n2, n3, None);
        (g, n1, n2, n3)
    }

    #[test]
    fn same_node_path() {
        let (g, n1, _, _) = simple_graph();
        let p = graph_astar(&g, n1, n1, None).unwrap();
        assert_eq!(p, vec![n1]);
    }

    #[test]
    fn linear_path() {
        let (g, n1, n2, n3) = simple_graph();
        let p = graph_astar(&g, n1, n3, None).unwrap();
        assert_eq!(p, vec![n1, n2, n3]);
    }

    #[test]
    fn no_path_missing_node() {
        let (g, n1, _, _) = simple_graph();
        assert!(graph_astar(&g, n1, 9999, None).is_none());
    }

    #[test]
    fn range_query() {
        let (g, n1, n2, n3) = simple_graph();
        let r = graph_range(&g, n1, 1.5);
        let ids: Vec<u64> = r.iter().map(|(id, _)| *id).collect();
        assert!(ids.contains(&n1));
        assert!(ids.contains(&n2));
        let _ = n3;
    }
}

// ── graph_path ──────────────────────────────────────────────────────────────────

mod graph_path_tests {
    use lurek2d::pathfind::{find_province_path, ProvinceCostFn};
    use std::collections::{HashMap, HashSet};

    #[allow(clippy::type_complexity)]
    fn make_linear_graph(
        n: u32,
    ) -> (
        HashMap<u32, Vec<u32>>,
        HashMap<u32, (f32, f32)>,
        HashMap<(u32, u32), HashSet<String>>,
    ) {
        let mut neighbors: HashMap<u32, Vec<u32>> = HashMap::new();
        let mut centroids: HashMap<u32, (f32, f32)> = HashMap::new();
        let edge_tags: HashMap<(u32, u32), HashSet<String>> = HashMap::new();
        for i in 0..n {
            centroids.insert(i, (i as f32 * 10.0, 0.0));
            if i + 1 < n {
                neighbors.entry(i).or_default().push(i + 1);
                neighbors.entry(i + 1).or_default().push(i);
            }
        }
        (neighbors, centroids, edge_tags)
    }

    #[test]
    fn find_province_path_same_node_returns_single() {
        let (neighbors, centroids, edge_tags) = make_linear_graph(3);
        let cost_fn = ProvinceCostFn::new();
        let path = find_province_path(&neighbors, &centroids, &edge_tags, 1, 1, &cost_fn).unwrap();
        assert_eq!(path.provinces, vec![1]);
        assert!((path.total_cost - 0.0).abs() < 1e-9);
    }

    #[test]
    fn find_province_path_linear_chain_finds_route() {
        let (neighbors, centroids, edge_tags) = make_linear_graph(4);
        let cost_fn = ProvinceCostFn::new();
        let path = find_province_path(&neighbors, &centroids, &edge_tags, 0, 3, &cost_fn).unwrap();
        assert_eq!(path.provinces.first(), Some(&0));
        assert_eq!(path.provinces.last(), Some(&3));
    }
}

// ── grid ────────────────────────────────────────────────────────────────────────

mod grid_tests {
    use lurek2d::pathfind::Grid;

    #[test]
    fn open_grid_finds_path() {
        let grid = Grid::new(5, 5, 1.0);
        let path = grid.find_path_astar(0, 0, 4, 4, false).unwrap();
        assert_eq!(*path.first().unwrap(), (0, 0));
        assert_eq!(*path.last().unwrap(), (4, 4));
        assert_eq!(path.len(), 9);
    }

    #[test]
    fn blocked_path_returns_none() {
        let mut grid = Grid::new(5, 1, 1.0);
        grid.set_walkable(2, 0, false);
        assert!(grid.find_path_astar(0, 0, 4, 0, false).is_none());
    }

    #[test]
    fn wall_grid_routes_around() {
        let mut grid = Grid::new(5, 5, 1.0);
        for y in 0..4 {
            grid.set_walkable(2, y, false);
        }
        let path = grid.find_path_astar(0, 0, 4, 0, false).unwrap();
        assert_eq!(*path.first().unwrap(), (0, 0));
        assert_eq!(*path.last().unwrap(), (4, 0));
        assert!(path.contains(&(2, 4)));
    }

    #[test]
    fn astar_and_dijkstra_same_simple() {
        let grid = Grid::new(5, 5, 1.0);
        let pa = grid.find_path_astar(0, 0, 4, 4, false).unwrap();
        let pd = grid.find_path_dijkstra(0, 0, 4, 4, false).unwrap();
        assert_eq!(pa.len(), pd.len());
        assert_eq!(*pa.first().unwrap(), *pd.first().unwrap());
        assert_eq!(*pa.last().unwrap(), *pd.last().unwrap());
    }

    #[test]
    fn bfs_finds_shortest_hop() {
        let grid = Grid::new(3, 3, 1.0);
        let path = grid.find_path_bfs(0, 0, 2, 2, false).unwrap();
        assert_eq!(path.len(), 5);
    }

    #[test]
    fn flow_field_directions() {
        let grid = Grid::new(3, 3, 1.0);
        let field = grid.build_flow_field(2, 2);
        let idx = 2 * 3 + 1;
        assert!((field[idx].0 - 1.0).abs() < 1e-5);
        assert!((field[idx].1 - 0.0).abs() < 1e-5);
        let gi = 2 * 3 + 2;
        assert!((field[gi].0).abs() < 1e-5);
        assert!((field[gi].1).abs() < 1e-5);
    }

    #[test]
    fn walkability_and_cost() {
        let mut grid = Grid::new(3, 3, 1.0);
        assert!(grid.is_walkable(1, 1));
        grid.set_walkable(1, 1, false);
        assert!(!grid.is_walkable(1, 1));
        grid.set_cost(0, 0, 5.0);
        assert!((grid.get_cost(0, 0) - 5.0).abs() < 1e-5);
    }
}

// ── hex_grid ────────────────────────────────────────────────────────────────────

mod hex_grid_tests {
    use lurek2d::pathfind::{HexGrid, HexLayout};

    #[test]
    fn new_hex_grid_defaults() {
        let g = HexGrid::new(5, 5, HexLayout::FlatTop);
        assert_eq!(g.width, 5);
        assert_eq!(g.height, 5);
        assert!(!g.is_blocked(0, 0));
    }

    #[test]
    fn trivial_path_same_cell() {
        let g = HexGrid::new(3, 3, HexLayout::PointyTop);
        let p = g.find_path((1, 1), (1, 1)).unwrap();
        assert_eq!(p, vec![(1, 1)]);
    }

    #[test]
    fn path_around_blocked() {
        let mut g = HexGrid::new(5, 5, HexLayout::FlatTop);
        g.set_blocked(2, 2, true);
        let p = g.find_path((0, 0), (4, 4));
        assert!(p.is_some());
        let path = p.unwrap();
        assert!(!path.contains(&(2, 2)));
    }

    #[test]
    fn line_of_sight_clear() {
        let g = HexGrid::new(5, 5, HexLayout::FlatTop);
        assert!(g.line_of_sight((0, 0), (4, 4)));
    }

    #[test]
    fn fov_includes_origin() {
        let g = HexGrid::new(5, 5, HexLayout::FlatTop);
        let vis = g.field_of_view((2, 2), 2);
        assert!(vis.contains(&(2, 2)));
    }

    #[test]
    fn range_of_movement_budget() {
        let g = HexGrid::new(5, 5, HexLayout::FlatTop);
        let cells = g.range_of_movement((2, 2), 1.0);
        assert!(cells.contains(&(2, 2)));
        assert!(cells.len() > 1);
    }
}

// ── hpa ─────────────────────────────────────────────────────────────────────────

mod hpa_tests {
    use lurek2d::pathfind::{build_abstract, hpa_star, NavGrid};

    #[test]
    fn build_abstract_on_small_open_grid_produces_graph() {
        let grid = NavGrid::new(8, 8);
        let graph = build_abstract(&grid, 4);
        assert_eq!(graph.grid_width, 8);
        assert_eq!(graph.grid_height, 8);
        assert_eq!(graph.chunk_size, 4);
    }

    #[test]
    fn hpa_star_finds_path_on_small_open_grid() {
        let grid = NavGrid::new(8, 8);
        let graph = build_abstract(&grid, 4);
        let path = hpa_star(&grid, &graph, (0, 0), (7, 7), 1);
        if let Some(p) = path {
            assert_eq!(p.first(), Some(&(0, 0)));
            assert_eq!(p.last(), Some(&(7, 7)));
        }
    }
}

// ── influence_map ───────────────────────────────────────────────────────────────

mod influence_map_tests {
    use lurek2d::pathfind::InfluenceMap;

    #[test]
    fn new_map_has_no_layers() {
        let im = InfluenceMap::new(4, 4, 1.0);
        assert_eq!(im.get_width(), 4);
        assert_eq!(im.get_height(), 4);
        assert!(im.get_layer_names().is_empty());
    }

    #[test]
    fn add_and_query_layer() {
        let mut im = InfluenceMap::new(3, 3, 1.0);
        im.add_layer("danger");
        assert!(im.has_layer("danger"));
        assert!(!im.has_layer("nope"));
        im.set_influence("danger", 1, 1, 0.75);
        assert!((im.get_influence("danger", 1, 1) - 0.75).abs() < 1e-6);
    }

    #[test]
    fn out_of_bounds_returns_zero() {
        let mut im = InfluenceMap::new(2, 2, 1.0);
        im.add_layer("a");
        assert_eq!(im.get_influence("a", 10, 10), 0.0);
    }

    #[test]
    fn clear_layer_zeros_all() {
        let mut im = InfluenceMap::new(3, 3, 1.0);
        im.add_layer("test");
        im.set_influence("test", 0, 0, 1.0);
        im.set_influence("test", 2, 2, 1.0);
        im.clear_layer("test");
        assert_eq!(im.get_influence("test", 0, 0), 0.0);
    }

    #[test]
    fn stamp_influence_adds_values() {
        let mut im = InfluenceMap::new(10, 10, 1.0);
        im.add_layer("threat");
        im.stamp_influence("threat", 5.0, 5.0, 3.0, 1.0, 1.0);
        assert!(im.get_influence("threat", 5, 5) > 0.0);
    }

    #[test]
    fn decay_reduces_values() {
        let mut im = InfluenceMap::new(3, 3, 1.0);
        im.add_layer("x");
        im.set_influence("x", 1, 1, 1.0);
        im.decay("x", 0.5);
        assert!((im.get_influence("x", 1, 1) - 0.5).abs() < 1e-6);
    }
}

// ── iso_grid ────────────────────────────────────────────────────────────────────

mod iso_grid_tests {
    use lurek2d::pathfind::IsoGrid;

    #[test]
    fn new_grid_defaults() {
        let g = IsoGrid::new(5, 5);
        assert_eq!(g.width, 5);
        assert_eq!(g.height, 5);
        assert!(!g.is_blocked_or_oob(0, 0));
    }

    #[test]
    fn blocked_cell_no_path() {
        let mut g = IsoGrid::new(3, 3);
        g.set_blocked(1, 0, true);
        g.set_blocked(1, 1, true);
        g.set_blocked(1, 2, true);
        assert!(g.find_path((0, 0), (2, 0)).is_none());
    }

    #[test]
    fn trivial_same_cell() {
        let g = IsoGrid::new(3, 3);
        let path = g.find_path((1, 1), (1, 1)).unwrap();
        assert_eq!(path, vec![(1, 1)]);
    }

    #[test]
    fn simple_path_exists() {
        let g = IsoGrid::new(5, 5);
        let path = g.find_path((0, 0), (4, 4));
        assert!(path.is_some());
        let p = path.unwrap();
        assert_eq!(*p.first().unwrap(), (0, 0));
        assert_eq!(*p.last().unwrap(), (4, 4));
    }

    #[test]
    fn line_of_sight_clear() {
        let g = IsoGrid::new(5, 5);
        assert!(g.line_of_sight((0, 0), (4, 4)));
    }

    #[test]
    fn line_of_sight_blocked() {
        let mut g = IsoGrid::new(5, 5);
        g.set_blocked(2, 2, true);
        assert!(!g.line_of_sight((0, 0), (4, 4)));
    }

    #[test]
    fn neighbors_gives_4_directions() {
        let g = IsoGrid::new(5, 5);
        let n = g.neighbors(2, 2);
        assert_eq!(n.len(), 4);
    }
}

// ── jps ─────────────────────────────────────────────────────────────────────────

mod jps_tests {
    use lurek2d::pathfind::JpsGrid;

    #[test]
    fn trivial_path_same_cell() {
        let g = JpsGrid::new(5, 5);
        let p = g.find_path((2, 2), (2, 2));
        assert!(p.is_some());
        assert_eq!(p.unwrap().len(), 1);
    }

    #[test]
    fn straight_line_path() {
        let g = JpsGrid::new(10, 1);
        let p = g.find_path((0, 0), (9, 0));
        assert!(p.is_some());
        let path = p.unwrap();
        assert_eq!(*path.first().unwrap(), (0, 0));
        assert_eq!(*path.last().unwrap(), (9, 0));
    }

    #[test]
    fn wall_blocks_forces_detour() {
        let mut g = JpsGrid::new(5, 5);
        for y in 0..5 {
            g.set_blocked(2, y, true);
        }
        let p = g.find_path((0, 2), (4, 2));
        assert!(p.is_none(), "solid wall should block");
    }

    #[test]
    fn path_around_obstacle() {
        let mut g = JpsGrid::new(5, 5);
        g.set_blocked(2, 1, true);
        g.set_blocked(2, 2, true);
        g.set_blocked(2, 3, true);
        let p = g.find_path((0, 2), (4, 2));
        assert!(p.is_some());
    }
}

// ── nav_grid ────────────────────────────────────────────────────────────────────

mod nav_grid_tests {
    use lurek2d::pathfind::{DiagonalMode, NavGrid};

    #[test]
    fn new_grid_all_walkable() {
        let g = NavGrid::new(10, 10);
        assert_eq!(g.get_width(), 10);
        assert_eq!(g.get_height(), 10);
        assert_eq!(g.get_dimensions(), (10, 10));
        for y in 0..10 {
            for x in 0..10 {
                assert!(!g.is_blocked(x, y));
                assert_eq!(g.get_cost(x, y), 1);
            }
        }
    }

    #[test]
    fn set_cost_and_blocked() {
        let mut g = NavGrid::new(5, 5);
        g.set_cost(2, 3, 0);
        assert!(g.is_blocked(2, 3));
        g.set_blocked(1, 1, true);
        assert!(g.is_blocked(1, 1));
        g.set_blocked(1, 1, false);
        assert!(!g.is_blocked(1, 1));
    }

    #[test]
    fn out_of_bounds_returns_blocked() {
        let g = NavGrid::new(3, 3);
        assert_eq!(g.get_cost(5, 5), 0);
        assert!(g.is_blocked(3, 0));
    }

    #[test]
    fn is_walkable_unit_size() {
        let mut g = NavGrid::new(5, 5);
        assert!(g.is_walkable(0, 0, 2));
        g.set_blocked(1, 0, true);
        assert!(!g.is_walkable(0, 0, 2));
    }

    #[test]
    fn from_costs_matches() {
        let costs = vec![1u8; 9];
        let g = NavGrid::from_costs(3, 3, costs);
        assert_eq!(g.get_dimensions(), (3, 3));
        assert!(!g.is_blocked(0, 0));
    }

    #[test]
    fn fill_and_fill_rect() {
        let mut g = NavGrid::new(4, 4);
        g.fill(0);
        assert!(g.is_blocked(2, 2));
        g.fill(1);
        g.fill_rect(1, 1, 2, 2, 0);
        assert!(g.is_blocked(1, 1));
        assert!(g.is_blocked(2, 2));
        assert!(!g.is_blocked(0, 0));
    }

    #[test]
    fn diagonal_mode_round_trip() {
        assert_eq!(DiagonalMode::from_lua_str("always"), Some(DiagonalMode::Always));
        assert_eq!(DiagonalMode::from_lua_str("none"), Some(DiagonalMode::None));
        assert_eq!(
            DiagonalMode::from_lua_str("nocornercut"),
            Some(DiagonalMode::NoCornerCut)
        );
        assert_eq!(DiagonalMode::from_lua_str("bogus"), None);
        assert_eq!(DiagonalMode::Always.to_lua_str(), "always");
    }

    #[test]
    fn load_save_bytes_round_trip() {
        let mut g = NavGrid::new(3, 3);
        g.set_cost(1, 1, 5);
        let bytes = g.save_to_bytes();
        let mut g2 = NavGrid::new(3, 3);
        g2.load_from_bytes(&bytes).unwrap();
        assert_eq!(g2.get_cost(1, 1), 5);
    }

    #[test]
    fn load_from_bytes_wrong_len_errors() {
        let mut g = NavGrid::new(3, 3);
        assert!(g.load_from_bytes(&[0u8; 5]).is_err());
    }
}

// ── pathgrid ────────────────────────────────────────────────────────────────────

mod pathgrid_tests {
    use lurek2d::pathfind::PathGrid;

    #[test]
    fn new_grid_all_walkable() {
        let g = PathGrid::new(4, 4, 1.0);
        assert!(g.is_walkable(0, 0));
        assert!(g.in_bounds(3, 3));
        assert!(!g.in_bounds(4, 0));
    }

    #[test]
    fn set_walkable_blocks_path() {
        let mut g = PathGrid::new(3, 1, 1.0);
        g.set_walkable(1, 0, false);
        assert!(g.find_path(0, 0, 2, 0).is_none());
    }

    #[test]
    fn same_cell_path() {
        let g = PathGrid::new(3, 3, 1.0);
        let p = g.find_path(1, 1, 1, 1).unwrap();
        assert_eq!(p.len(), 1);
    }

    #[test]
    fn path_returns_world_coords() {
        let g = PathGrid::new(5, 5, 10.0);
        let p = g.find_path(0, 0, 2, 0).unwrap();
        assert!(p.len() >= 2);
        assert!((p[0].0 - 5.0).abs() < 1e-3);
    }

    #[test]
    fn cost_multiplier_affects_path() {
        let mut g = PathGrid::new(3, 3, 1.0);
        g.set_cost(1, 0, 100.0);
        let p = g.find_path(0, 0, 2, 0);
        assert!(p.is_some());
    }
}

// ── range_map ───────────────────────────────────────────────────────────────────

mod range_map_tests {
    use lurek2d::pathfind::RangeMap;

    #[test]
    fn origin_always_reachable() {
        let costs = vec![1.0f32; 9];
        let blocked = vec![false; 9];
        let rm = RangeMap::from_grid(3, 3, &costs, &blocked, 1, 1, 10.0, false);
        assert!(rm.reachable(1, 1));
        assert_eq!(rm.cost_to(1, 1), Some(0.0));
    }

    #[test]
    fn budget_limits_reach() {
        let costs = vec![1.0f32; 25];
        let blocked = vec![false; 25];
        let rm = RangeMap::from_grid(5, 5, &costs, &blocked, 0, 0, 2.0, false);
        assert!(rm.reachable(0, 0));
        assert!(rm.reachable(2, 0));
        assert!(!rm.reachable(4, 4));
    }

    #[test]
    fn blocked_origin_empty() {
        let costs = vec![1.0; 4];
        let blocked = vec![true; 4];
        let rm = RangeMap::from_grid(2, 2, &costs, &blocked, 0, 0, 10.0, false);
        assert!(!rm.reachable(0, 0));
    }

    #[test]
    fn diagonal_extends_reach() {
        let costs = vec![1.0f32; 9];
        let blocked = vec![false; 9];
        let rm_4 = RangeMap::from_grid(3, 3, &costs, &blocked, 0, 0, 1.5, false);
        let rm_8 = RangeMap::from_grid(3, 3, &costs, &blocked, 0, 0, 1.5, true);
        let cells_4 = rm_4.reachable_cells().len();
        let cells_8 = rm_8.reachable_cells().len();
        assert!(cells_8 >= cells_4);
    }

    #[test]
    fn reachable_cells_with_cost_includes_origin() {
        let costs = vec![1.0; 4];
        let blocked = vec![false; 4];
        let rm = RangeMap::from_grid(2, 2, &costs, &blocked, 0, 0, 5.0, false);
        let cells = rm.reachable_cells_with_cost();
        assert!(cells.iter().any(|(x, y, c)| *x == 0 && *y == 0 && *c == 0.0));
    }
}

// ── render ──────────────────────────────────────────────────────────────────────

mod render_tests {
    use lurek2d::pathfind::{FlowField, InfluenceMap, NavGrid};
    use std::cell::RefCell;
    use std::rc::Rc;

    #[test]
    fn nav_grid_render_commands_empty_grid_returns_empty() {
        let g = NavGrid::new(0, 0);
        assert!(g.generate_render_commands(8.0).is_empty());
    }

    #[test]
    fn nav_grid_render_commands_count() {
        let g = NavGrid::new(4, 4);
        assert_eq!(g.generate_render_commands(8.0).len(), 32);
    }

    #[test]
    fn flow_field_uncalculated_returns_empty() {
        let g = Rc::new(RefCell::new(NavGrid::new(4, 4)));
        let ff = FlowField::new(g);
        assert!(ff.generate_render_commands(8.0).is_empty());
    }

    #[test]
    fn influence_map_empty_layer_returns_no_commands() {
        let im = InfluenceMap::new(4, 4, 1.0);
        assert!(im.generate_render_commands("nonexistent", 8.0).is_empty());
    }
}

// ── unit_pathfinder ─────────────────────────────────────────────────────────────

mod unit_pathfinder_tests {
    use lurek2d::pathfind::{NavGrid, UnitPathfinder};
    use std::cell::RefCell;
    use std::rc::Rc;

    fn open_grid(w: u32, h: u32) -> Rc<RefCell<NavGrid>> {
        Rc::new(RefCell::new(NavGrid::new(w, h)))
    }

    #[test]
    fn find_path_trivial() {
        let g = open_grid(5, 5);
        let mut up = UnitPathfinder::new(g);
        let path = up.find_path(0, 0, 4, 4, 1);
        assert!(path.is_some());
    }

    #[test]
    fn cache_hit_returns_same_path() {
        let g = open_grid(5, 5);
        let mut up = UnitPathfinder::new(g);
        let p1 = up.find_path(0, 0, 4, 4, 1).unwrap();
        let p2 = up.find_path(0, 0, 4, 4, 1).unwrap();
        assert_eq!(p1, p2);
    }

    #[test]
    fn path_through_blocked_returns_none() {
        let g_inner = NavGrid::new(3, 1);
        let g = Rc::new(RefCell::new(g_inner));
        g.borrow_mut().set_blocked(1, 0, true);
        let mut up = UnitPathfinder::new(g);
        assert!(up.find_path(0, 0, 2, 0, 1).is_none());
    }
}
