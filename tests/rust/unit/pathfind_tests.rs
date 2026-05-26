//! INTERNAL ONLY: Rust-only tests for pathfinding internals that are not asserted through the
//! Lua-facing `lurek.pathfind.*` API.
//!
//! Grid, JPS, NavGrid, UnitPathfinder, RangeMap, and thread-pool behavior reachable via
//! `lurek.pathfind.*` lives in `tests/lua/unit/test_pathfind_core_unit.lua` and
//! `tests/lua/unit/test_pathfind_ai_unit.lua`.
//!
//! Remaining coverage:
//! - `IsoGrid` (not exposed to Lua)
//! - `NavGrid::from_costs` and raw byte load error paths
//! - `DiagonalMode::from_lua_str` enum parsing used by bindings
//! - `PathThreadPool` (`setThreadCount` / `getThreadCount` Lua stubs are not wired yet)
//! - `graph_astar` / `graph_range` (feature `graph`, no direct Lua surface)

use lurek2d::pathfind::{DiagonalMode, IsoGrid, NavGrid, PathThreadPool};

mod async_pool_tests {
    use super::*;

    #[test]
    fn default_thread_count_is_at_least_one() {
        let pool = PathThreadPool::new(0);
        assert!(pool.get_thread_count() >= 1);
    }

    #[test]
    fn set_thread_count_clamps_zero_to_one() {
        let mut pool = PathThreadPool::new(1);
        pool.set_thread_count(0);
        assert_eq!(pool.get_thread_count(), 1);
    }

    #[test]
    fn set_thread_count_updates_pool_size() {
        let mut pool = PathThreadPool::new(1);
        pool.set_thread_count(4);
        assert_eq!(pool.get_thread_count(), 4);
    }
}

#[cfg(feature = "flownet")]
mod graph_nav_tests {
    use lurek2d::flownet::core::Graph;
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
    fn same_node_path_is_singleton() {
        let (g, n1, _, _) = simple_graph();
        let p = graph_astar(&g, n1, n1, None).unwrap();
        assert_eq!(p, vec![n1]);
    }

    #[test]
    fn linear_path_follows_edges() {
        let (g, n1, n2, n3) = simple_graph();
        let p = graph_astar(&g, n1, n3, None).unwrap();
        assert_eq!(p, vec![n1, n2, n3]);
    }

    #[test]
    fn missing_goal_returns_none() {
        let (g, n1, _, _) = simple_graph();
        assert!(graph_astar(&g, n1, 9999, None).is_none());
    }

    #[test]
    fn range_query_includes_neighbors_within_radius() {
        let (g, n1, n2, n3) = simple_graph();
        let r = graph_range(&g, n1, 1.5);
        let ids: Vec<u64> = r.iter().map(|(id, _)| *id).collect();
        assert!(ids.contains(&n1));
        assert!(ids.contains(&n2));
        let _ = n3;
    }
}

mod iso_grid_tests {
    use super::*;

    #[test]
    fn new_grid_has_expected_dimensions() {
        let g = IsoGrid::new(5, 5);
        assert_eq!(g.width, 5);
        assert_eq!(g.height, 5);
    }

    #[test]
    fn blocked_column_prevents_path() {
        let mut g = IsoGrid::new(3, 3);
        g.set_blocked(1, 0, true);
        g.set_blocked(1, 1, true);
        g.set_blocked(1, 2, true);
        assert!(g.find_path((0, 0), (2, 0)).is_none());
    }

    #[test]
    fn same_cell_path_is_singleton() {
        let g = IsoGrid::new(3, 3);
        let path = g.find_path((1, 1), (1, 1)).unwrap();
        assert_eq!(path, vec![(1, 1)]);
    }

    #[test]
    fn open_grid_connects_corners() {
        let g = IsoGrid::new(5, 5);
        let path = g.find_path((0, 0), (4, 4));
        assert!(path.is_some());
        let p = path.unwrap();
        assert_eq!(*p.first().unwrap(), (0, 0));
        assert_eq!(*p.last().unwrap(), (4, 4));
    }

    #[test]
    fn line_of_sight_clear_on_open_grid() {
        let g = IsoGrid::new(5, 5);
        assert!(g.line_of_sight((0, 0), (4, 4)));
    }

    #[test]
    fn line_of_sight_blocked_by_cell() {
        let mut g = IsoGrid::new(5, 5);
        g.set_blocked(2, 2, true);
        assert!(!g.line_of_sight((0, 0), (4, 4)));
    }

    #[test]
    fn center_cell_has_four_neighbors() {
        let g = IsoGrid::new(5, 5);
        let n = g.neighbors(2, 2);
        assert_eq!(n.len(), 4);
    }
}

mod nav_grid_internal_tests {
    use super::*;

    #[test]
    fn from_costs_matches_dimensions() {
        let costs = vec![1u8; 9];
        let g = NavGrid::from_costs(3, 3, costs);
        assert_eq!(g.get_dimensions(), (3, 3));
        assert!(!g.is_blocked(0, 0));
    }

    #[test]
    fn load_from_bytes_wrong_len_errors() {
        let mut g = NavGrid::new(3, 3);
        assert!(g.load_from_bytes(&[0u8; 5]).is_err());
    }

    #[test]
    fn diagonal_mode_from_lua_str_round_trip() {
        assert_eq!(
            DiagonalMode::from_lua_str("always"),
            Some(DiagonalMode::Always)
        );
        assert_eq!(DiagonalMode::from_lua_str("none"), Some(DiagonalMode::None));
        assert_eq!(
            DiagonalMode::from_lua_str("nocornercut"),
            Some(DiagonalMode::NoCornerCut)
        );
        assert_eq!(DiagonalMode::from_lua_str("bogus"), None);
        assert_eq!(DiagonalMode::Always.to_lua_str(), "always");
    }
}
