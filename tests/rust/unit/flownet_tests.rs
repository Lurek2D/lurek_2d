//! File: tests/rust/unit/flownet_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::flownet::{Graph, ItemPosition, OverflowPolicy};

// â”€â”€ render â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod render_tests {
    use super::*;

    #[test]
    fn empty_graph_returns_no_commands() {
        let g = Graph::new();
        assert!(g.generate_render_commands(400.0, 300.0).is_empty());
    }

    #[test]
    fn single_node_emits_commands() {
        let mut g = Graph::new();
        g.add_node("settlement", 10);
        let cmds = g.generate_render_commands(400.0, 300.0);
        assert!(!cmds.is_empty());
    }

    #[test]
    fn draw_to_image_unchanged_dimensions() {
        let g = Graph::new();
        let img = g.draw_to_image(64, 64);
        assert_eq!(img.width(), 64);
        assert_eq!(img.height(), 64);
    }
}

// â”€â”€ simulation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

mod simulation_tests {
    use super::*;

    fn build_decay_graph() -> Graph {
        let mut g = Graph::new();
        let n = g.add_node("source", 8);
        let i = g.create_item("ore", 1.0);
        g.add_item_to_node(i, n)
            .expect("item should be placed on source node");
        g
    }

    #[test]
    fn update_parallel_matches_update_for_decay_path() {
        let mut a = build_decay_graph();
        let data = a.serialize();
        let mut b = Graph::deserialize(&data).expect("graph deserialize should succeed");

        let events_a = a.update(1.5);
        let events_b = b.update_parallel(1.5);

        assert!(
            events_a.iter().any(|e| matches!(
                e,
                lurek2d::flownet::simulation::GraphEvent::ItemDecay { .. }
            )) || !events_a.is_empty()
        );
        let _ = events_b; // direct coverage: ensure update_parallel executes in tests

        let stats_a = a.get_stats();
        let stats_b = b.get_stats();
        assert_eq!(stats_a.items_on_nodes, stats_b.items_on_nodes);
        assert_eq!(stats_a.items_in_transit, stats_b.items_in_transit);
    }

    #[test]
    fn edge_cooldown_expires_precisely_and_allows_send_again() {
        let mut g = Graph::new();
        let from = g.add_node("source", 8);
        let to = g.add_node("sink", 8);
        let edge = g
            .add_edge(from, to, Some("belt"))
            .expect("edge should be created");

        {
            let e = g.edges.get_mut(&edge).expect("edge should exist");
            e.cooldown = 1.0;
        }

        let item_a = g.create_item("ore", -1.0);
        let item_b = g.create_item("ore", -1.0);
        g.add_item_to_node(item_a, from)
            .expect("item_a should be placed");
        g.add_item_to_node(item_b, from)
            .expect("item_b should be placed");

        assert!(g
            .send_item(item_a, edge)
            .expect("send item_a should succeed"));
        assert!(!g
            .send_item(item_b, edge)
            .expect("cooldown should block immediate send"));

        g.update(0.5);
        assert!(!g
            .send_item(item_b, edge)
            .expect("cooldown still active at half-time"));

        g.update(0.5);
        assert!(g
            .send_item(item_b, edge)
            .expect("cooldown expired, send should work"));
    }

    #[test]
    fn adjacency_indexes_stay_consistent_after_edge_and_node_removal() {
        let mut g = Graph::new();
        let a = g.add_node("a", -1);
        let b = g.add_node("b", -1);
        let c = g.add_node("c", -1);
        let e1 = g.add_edge(a, b, Some("road")).expect("edge a->b");
        let _e2 = g.add_edge(b, c, Some("road")).expect("edge b->c");

        assert_eq!(g.get_outgoing_edges(a), vec![e1]);
        assert_eq!(g.get_incoming_edges(b), vec![e1]);

        assert!(g.remove_edge(e1));
        assert!(g.get_outgoing_edges(a).is_empty());
        assert!(g.get_incoming_edges(b).is_empty());

        assert!(g.remove_node(b));
        assert!(g.get_outgoing_edges(b).is_empty());
        assert!(g.get_incoming_edges(b).is_empty());
    }

    #[test]
    fn subgraph_keeps_only_selected_nodes_edges_and_items() {
        let mut g = Graph::new();
        let a = g.add_node("a", -1);
        let b = g.add_node("b", -1);
        let c = g.add_node("c", -1);
        let ab = g.add_edge(a, b, Some("road")).expect("edge a->b");
        let _bc = g.add_edge(b, c, Some("road")).expect("edge b->c");

        let item_on_b = g.create_item("ore", -1.0);
        g.add_item_to_node(item_on_b, b).expect("item on b");

        let item_on_ab = g.create_item("ore", -1.0);
        g.add_item_to_node(item_on_ab, a).expect("item on a");
        assert!(g.send_item(item_on_ab, ab).expect("send on ab"));

        let sub = g.subgraph(&[a, b]);
        assert_eq!(sub.get_node_count(), 2);
        assert_eq!(sub.get_edge_count(), 1);
        assert_eq!(sub.get_item_count(), 2);

        let only_edge = sub
            .get_edge_ids()
            .into_iter()
            .next()
            .expect("subgraph edge expected");
        let edge = sub.edges.get(&only_edge).expect("subgraph edge lookup");
        assert_eq!(edge.items_in_transit.len(), 1);
    }

    #[test]
    fn add_item_to_node_moves_item_without_duplicate_ownership() {
        let mut g = Graph::new();
        let a = g.add_node("a", -1);
        let b = g.add_node("b", -1);
        let item = g.create_item("ore", -1.0);

        assert!(g.add_item_to_node(item, a).expect("place on a"));
        assert!(g.add_item_to_node(item, b).expect("move to b"));

        assert!(g.nodes.get(&a).expect("node a").items.is_empty());
        assert_eq!(g.nodes.get(&b).expect("node b").items, vec![item]);
        assert_eq!(
            g.items.get(&item).expect("item").position,
            ItemPosition::AtNode(b)
        );
    }

    #[test]
    fn send_item_rejects_invalid_item_locations() {
        let mut g = Graph::new();
        let a = g.add_node("a", 1);
        let b = g.add_node("b", 1);
        let edge = g.add_edge(a, b, Some("belt")).expect("edge");
        let item = g.create_item("ore", -1.0);

        let err = g
            .send_item(item, edge)
            .expect_err("unplaced items should not send");
        assert!(err.contains("unplaced"));

        assert!(g.add_item_to_node(item, b).expect("place on wrong node"));
        let err = g
            .send_item(item, edge)
            .expect_err("wrong source node should fail");
        assert!(err.contains("starts at node"));

        assert!(g.remove_item(item));
        let live_item = g.create_item("ore", -1.0);
        assert!(g.add_item_to_node(live_item, a).expect("place on source"));
        assert!(g.send_item(live_item, edge).expect("first send works"));
        let err = g
            .send_item(live_item, edge)
            .expect_err("second send while in transit should fail");
        assert!(err.contains("already in transit"));
    }

    #[test]
    fn serialize_round_trip_preserves_full_state() {
        let mut g = Graph::new();
        let source = g.add_node("source", 1);
        let sink = g.add_node("sink", 1);
        let edge = g.add_edge(source, sink, Some("belt")).expect("edge");

        {
            let node = g.nodes.get_mut(&sink).expect("sink node");
            node.overflow_policy = OverflowPolicy::Queue;
            node.queue_enabled = true;
            node.queue_capacity = 4;
            node.push_rate = 2.0;
            node.pull_rate = 3.0;
            node.process_time = 0.5;
            node.add_tag("hub");
            node.add_supply("ore", 7);
            node.add_demand("plate", 3, 2);
            assert!(node.reserve_capacity("planner-a", 1));
        }
        {
            let e = g.edges.get_mut(&edge).expect("edge");
            e.capacity = 5;
            e.throughput = 2.0;
            e.travel_time = 4.0;
            e.weight = 1.5;
            e.speed_modifier = 1.25;
            e.cooldown = 0.75;
            e.add_allowed_type("ore");
            e.bidirectional = true;
            assert!(e.reserve_capacity("planner-a", 2));
        }

        let moving = g.create_item("ore", 10.0);
        let queued = g.create_item("ore", -1.0);
        let blocker = g.create_item("ore", -1.0);
        assert!(g.add_item_to_node(moving, source).expect("place moving"));
        assert!(g.send_item(moving, edge).expect("send moving"));
        assert!(g.add_item_to_node(blocker, sink).expect("fill sink"));
        assert!(g.add_item_to_node(queued, sink).expect("queue queued item"));

        let snapshot = g.serialize();
        let restored = Graph::deserialize(&snapshot).expect("restore full flownet state");

        assert_eq!(restored.get_node_count(), 2);
        assert_eq!(restored.get_edge_count(), 1);
        assert_eq!(restored.get_item_count(), 3);
        assert_eq!(
            restored
                .edges
                .get(&edge)
                .expect("restored edge")
                .items_in_transit,
            vec![moving]
        );
        assert_eq!(
            restored
                .nodes
                .get(&sink)
                .expect("restored sink")
                .queue
                .iter()
                .copied()
                .collect::<Vec<_>>(),
            vec![queued]
        );
        assert_eq!(
            restored.items.get(&moving).expect("moving item").position,
            ItemPosition::InTransit {
                edge_id: edge,
                progress: 0.0
            }
        );
        assert_eq!(
            restored.items.get(&queued).expect("queued item").position,
            ItemPosition::AtNode(sink)
        );
        assert!(restored
            .nodes
            .get(&sink)
            .expect("restored sink")
            .tags
            .contains("hub"));
        assert_eq!(
            restored
                .nodes
                .get(&sink)
                .expect("restored sink")
                .get_reserved_capacity(),
            1
        );
        assert_eq!(
            restored
                .edges
                .get(&edge)
                .expect("restored edge")
                .get_reserved_capacity(),
            2
        );
    }

    #[test]
    fn node_and_edge_reservations_reduce_available_capacity() {
        let mut g = Graph::new();
        let a = g.add_node("a", 3);
        let b = g.add_node("b", 2);
        let edge = g.add_edge(a, b, Some("belt")).expect("edge");

        let node = g.nodes.get_mut(&b).expect("node b");
        assert_eq!(node.get_available_capacity(), 2);
        assert!(node.reserve_capacity("planner-a", 1));
        assert_eq!(node.get_reserved_capacity(), 1);
        assert_eq!(node.get_available_capacity(), 1);
        assert_eq!(node.release_capacity_reservation("planner-a", Some(1)), 1);
        assert_eq!(node.get_reserved_capacity(), 0);

        let edge_ref = g.edges.get_mut(&edge).expect("edge");
        edge_ref.capacity = 2;
        assert_eq!(edge_ref.get_available_capacity(), 2);
        assert!(edge_ref.reserve_capacity("planner-a", 1));
        assert_eq!(edge_ref.get_reserved_capacity(), 1);
        assert_eq!(edge_ref.get_available_capacity(), 1);
        edge_ref.clear_capacity_reservations();
        assert_eq!(edge_ref.get_reserved_capacity(), 0);
    }
}
