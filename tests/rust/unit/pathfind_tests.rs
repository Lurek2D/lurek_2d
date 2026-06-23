//! File: tests/rust/unit/pathfind_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::pathfind::{
    AsyncPathRequest, DiagonalMode, IsoGrid, NavGrid, PathEventStatus, PathThreadPool,
    UnitPathfinder,
};
use std::cell::RefCell;
use std::rc::Rc;
use std::thread;
use std::time::{Duration, Instant};

mod async_pool_tests {
    use super::*;

    fn collect_events_until(
        pool: &PathThreadPool,
        predicate: impl Fn(&[lurek2d::pathfind::AsyncPathEvent]) -> bool,
    ) -> Vec<lurek2d::pathfind::AsyncPathEvent> {
        let deadline = Instant::now() + Duration::from_secs(2);
        let mut events = Vec::new();
        while Instant::now() < deadline {
            let mut batch = pool.poll_events();
            if !batch.is_empty() {
                events.append(&mut batch);
                if predicate(&events) {
                    return events;
                }
            }
            thread::sleep(Duration::from_millis(5));
        }
        events
    }

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
    fn set_thread_count_updates_configured_pool_size() {
        let mut pool = PathThreadPool::new(1);
        pool.set_thread_count(4);
        assert_eq!(pool.get_thread_count(), 4);
    }

    #[test]
    fn streaming_request_emits_partial_then_complete() {
        let pool = PathThreadPool::new(1);
        let events = {
            let request = AsyncPathRequest {
                id: 1,
                owner_id: 1,
                version: 0,
                priority: 0,
                grid: NavGrid::new(64, 64),
                start: (0, 0),
                goal: (63, 63),
                unit_size: 1,
                stream_budget: 4,
            };
            assert!(pool.submit_query(request));
            collect_events_until(&pool, |events| {
                events.iter().any(|e| e.status == PathEventStatus::Partial)
                    && events
                        .iter()
                        .any(|e| e.status == PathEventStatus::Complete && e.final_event)
            })
        };

        assert!(events.iter().any(|e| e.status == PathEventStatus::Partial));
        assert!(events
            .iter()
            .any(|e| e.status == PathEventStatus::Complete && e.final_event));
    }

    #[test]
    fn cancelled_request_emits_cancelled_terminal_event() {
        let pool = PathThreadPool::new(1);
        let request = AsyncPathRequest {
            id: 2,
            owner_id: 2,
            version: 0,
            priority: 0,
            grid: NavGrid::new(96, 96),
            start: (0, 0),
            goal: (95, 95),
            unit_size: 1,
            stream_budget: 8,
        };
        assert!(pool.submit_query(request));
        pool.cancel(2);
        let events = collect_events_until(&pool, |events| {
            events
                .iter()
                .any(|e| e.id == 2 && e.status == PathEventStatus::Cancelled && e.final_event)
        });

        assert!(events
            .iter()
            .any(|e| e.id == 2 && e.status == PathEventStatus::Cancelled && e.final_event));
    }

    #[test]
    fn newer_version_supersedes_older_request() {
        let pool = PathThreadPool::new(1);
        assert!(pool.submit_query(AsyncPathRequest {
            id: 3,
            owner_id: 77,
            version: 1,
            priority: 0,
            grid: NavGrid::new(96, 96),
            start: (0, 0),
            goal: (95, 95),
            unit_size: 1,
            stream_budget: 8,
        }));
        assert!(pool.submit_query(AsyncPathRequest {
            id: 4,
            owner_id: 77,
            version: 2,
            priority: 1,
            grid: NavGrid::new(96, 96),
            start: (0, 0),
            goal: (95, 95),
            unit_size: 1,
            stream_budget: 8,
        }));

        let events = collect_events_until(&pool, |events| {
            events
                .iter()
                .any(|e| e.id == 3 && e.status == PathEventStatus::Superseded && e.final_event)
                && events
                    .iter()
                    .any(|e| e.id == 4 && e.status == PathEventStatus::Complete && e.final_event)
        });

        assert!(events
            .iter()
            .any(|e| e.id == 3 && e.status == PathEventStatus::Superseded && e.final_event));
        assert!(events
            .iter()
            .any(|e| e.id == 4 && e.status == PathEventStatus::Complete && e.final_event));
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

    #[test]
    fn fill_rect_saturates_large_extents_without_panicking() {
        let mut g = NavGrid::new(4, 4);
        g.fill_rect(3, 3, u32::MAX, u32::MAX, 9);
        assert_eq!(g.get_cost(3, 3), 9);
    }
}

mod unit_pathfinder_internal_tests {
    use super::*;

    fn new_pathfinder(width: u32, height: u32) -> UnitPathfinder {
        UnitPathfinder::new(Rc::new(RefCell::new(NavGrid::new(width, height))))
    }

    #[test]
    fn nearest_walkable_out_of_bounds_returns_none() {
        let pathfinder = new_pathfinder(4, 4);
        assert_eq!(pathfinder.find_nearest_walkable(99, 99, 3, 1), None);
    }

    #[test]
    fn unreachable_out_of_bounds_returns_false() {
        let pathfinder = new_pathfinder(4, 4);
        assert!(!pathfinder.is_reachable(0, 0, 99, 99, 1));
    }
}
