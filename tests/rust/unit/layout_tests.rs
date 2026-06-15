//! File: tests/rust/unit/layout_tests.rs

use lurek2d::layout::{layout_dag, layout_tree, LayoutConfig, LayoutEdge, LayoutNode};
use std::collections::HashMap;

mod dag_tests {
    use super::*;

    fn sample_nodes() -> Vec<LayoutNode> {
        vec![
            LayoutNode::new(1).with_size(40.0, 20.0),
            LayoutNode::new(2).with_size(40.0, 20.0),
            LayoutNode::new(3).with_size(40.0, 20.0),
        ]
    }

    #[test]
    fn dag_keeps_cyclic_nodes_in_output() {
        let nodes = sample_nodes();
        let edges = vec![
            LayoutEdge::new(1, 2),
            LayoutEdge::new(2, 1),
            LayoutEdge::new(2, 3),
        ];

        let result = layout_dag(&nodes, &edges, &LayoutConfig::default());

        assert_eq!(result.count(), 3);
        assert!(result.get(1).is_some());
        assert!(result.get(2).is_some());
        assert!(result.get(3).is_some());
    }

    #[test]
    fn dag_handles_disconnected_and_invalid_edges_deterministically() {
        let nodes = sample_nodes();
        let edges = vec![LayoutEdge::new(1, 99), LayoutEdge::new(2, 2)];

        let result = layout_dag(&nodes, &edges, &LayoutConfig::default());
        let ids: Vec<_> = result.nodes.iter().map(|node| node.id).collect();

        assert_eq!(ids, vec![1, 3, 2]);
    }
}

mod tree_tests {
    use super::*;

    fn sample_nodes() -> Vec<LayoutNode> {
        vec![
            LayoutNode::new(1).with_size(50.0, 20.0),
            LayoutNode::new(2).with_size(50.0, 20.0),
            LayoutNode::new(3).with_size(50.0, 20.0),
        ]
    }

    #[test]
    fn tree_keeps_all_nodes_when_children_cycle() {
        let nodes = sample_nodes();
        let children = HashMap::from([(1usize, vec![2usize]), (2usize, vec![1usize, 3usize])]);

        let result = layout_tree(&nodes, &children, 1, &LayoutConfig::default());

        assert_eq!(result.count(), 3);
        assert!(result
            .nodes
            .iter()
            .all(|node| node.x.is_finite() && node.y.is_finite()));
        assert!(result.get(3).unwrap().y > result.get(1).unwrap().y);
    }

    #[test]
    fn tree_ignores_self_reference_without_recursing_forever() {
        let nodes = sample_nodes();
        let children = HashMap::from([(1usize, vec![1usize, 2usize]), (2usize, vec![3usize])]);

        let result = layout_tree(&nodes, &children, 1, &LayoutConfig::default());

        assert_eq!(result.count(), 3);
        assert!(result.get(2).unwrap().y > result.get(1).unwrap().y);
        assert!(result.get(3).unwrap().y > result.get(2).unwrap().y);
    }
}
