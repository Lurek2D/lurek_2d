//! File: tests/rust/unit/layout_tests.rs

use lurek2d::charts::{
    BoxPlotChart, BubbleChart, Candle, CandlestickChart, ChartConfig, RadarChart, TreemapChart,
    TreemapItem,
};
use lurek2d::layout::{
    layout_circular, layout_dag, layout_force, layout_grid, layout_radial, layout_spiral,
    layout_stress, layout_tree, LayoutConfig, LayoutEdge, LayoutNode, StressConfig,
};
use std::collections::HashMap;
use std::time::{Duration, Instant};

fn overlaps(a: &LayoutNode, b: &LayoutNode, padding: f64) -> bool {
    a.x < b.x + b.width + padding
        && a.x + a.width + padding > b.x
        && a.y < b.y + b.height + padding
        && a.y + a.height + padding > b.y
}

fn assert_no_overlaps(nodes: &[LayoutNode], padding: f64) {
    for i in 0..nodes.len() {
        for j in (i + 1)..nodes.len() {
            assert!(
                !overlaps(&nodes[i], &nodes[j], padding),
                "nodes {} and {} overlap: {:?} vs {:?}",
                nodes[i].id,
                nodes[j].id,
                nodes[i],
                nodes[j]
            );
        }
    }
}

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

    #[test]
    fn dag_separates_layers_by_actual_node_heights() {
        let nodes = vec![
            LayoutNode::new(1).with_size(120.0, 96.0),
            LayoutNode::new(2).with_size(80.0, 42.0),
            LayoutNode::new(3).with_size(80.0, 42.0),
        ];
        let edges = vec![LayoutEdge::new(1, 2), LayoutEdge::new(1, 3)];
        let config = LayoutConfig {
            h_spacing: 20.0,
            v_spacing: 24.0,
            margin: 10.0,
        };

        let result = layout_dag(&nodes, &edges, &config);
        let root = result.get(1).unwrap();
        let child = result.get(2).unwrap();

        assert!(child.y >= root.y + root.height + config.v_spacing - 0.001);
        assert_no_overlaps(&result.nodes, 0.0);
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

    #[test]
    fn tree_centers_parent_by_child_centers_with_wide_nodes() {
        let nodes = vec![
            LayoutNode::new(1).with_size(140.0, 32.0),
            LayoutNode::new(2).with_size(60.0, 28.0),
            LayoutNode::new(3).with_size(180.0, 28.0),
            LayoutNode::new(4).with_size(60.0, 28.0),
        ];
        let children = HashMap::from([(1usize, vec![2usize, 3usize, 4usize])]);

        let result = layout_tree(
            &nodes,
            &children,
            1,
            &LayoutConfig {
                h_spacing: 24.0,
                v_spacing: 36.0,
                margin: 12.0,
            },
        );
        let root = result.get(1).unwrap();
        let left = result.get(2).unwrap();
        let right = result.get(4).unwrap();
        let root_center = root.x + root.width * 0.5;
        let child_span_center = (left.x + left.width * 0.5 + right.x + right.width * 0.5) * 0.5;

        assert!((root_center - child_span_center).abs() < 0.001);
        assert_no_overlaps(&result.nodes, 0.0);
    }
}

mod dense_layout_quality_tests {
    use super::*;

    fn varied_nodes(count: usize) -> Vec<LayoutNode> {
        (0..count)
            .map(|id| {
                let width = 48.0 + (id % 5) as f64 * 18.0;
                let height = 24.0 + (id % 3) as f64 * 12.0;
                LayoutNode::new(id).with_size(width, height)
            })
            .collect()
    }

    #[test]
    fn grid_uses_variable_columns_without_rectangle_overlap() {
        let result = layout_grid(
            &varied_nodes(13),
            &LayoutConfig {
                h_spacing: 14.0,
                v_spacing: 18.0,
                margin: 8.0,
            },
        );

        assert_eq!(result.count(), 13);
        assert_no_overlaps(&result.nodes, 0.0);
    }

    #[test]
    fn radial_dense_ring_uses_enough_radius_for_large_labels() {
        let mut nodes = vec![LayoutNode::new(0).with_size(86.0, 34.0)];
        nodes.extend((1..=14).map(|id| LayoutNode::new(id).with_size(92.0, 32.0)));
        let edges: Vec<_> = (1..=14).map(|id| LayoutEdge::new(0, id)).collect();

        let result = layout_radial(
            &nodes,
            &edges,
            0,
            &LayoutConfig {
                h_spacing: 18.0,
                v_spacing: 42.0,
                margin: 10.0,
            },
        );

        assert_eq!(result.count(), nodes.len());
        assert_no_overlaps(&result.nodes, 0.0);
    }

    #[test]
    fn spiral_rejects_positions_that_overlap_existing_nodes() {
        let result = layout_spiral(
            &varied_nodes(18),
            &LayoutConfig {
                h_spacing: 12.0,
                v_spacing: 12.0,
                margin: 10.0,
            },
        );

        assert_eq!(result.count(), 18);
        assert_no_overlaps(&result.nodes, 0.0);
    }

    #[test]
    fn force_respects_node_sizes_inside_area() {
        let nodes = varied_nodes(10);
        let edges: Vec<_> = (0..9).map(|id| LayoutEdge::new(id, id + 1)).collect();
        let result = layout_force(
            &nodes,
            &edges,
            &lurek2d::layout::ForceConfig {
                iterations: 80,
                repulsion: 9000.0,
                attraction: 0.018,
                cooling: 0.92,
                area_width: 720.0,
                area_height: 480.0,
            },
        );

        assert_eq!(result.count(), 10);
        assert!(result
            .nodes
            .iter()
            .all(|node| node.x >= 0.0 && node.y >= 0.0));
        assert!(result
            .nodes
            .iter()
            .all(|node| node.x + node.width <= 720.001 && node.y + node.height <= 480.001));
        assert_no_overlaps(&result.nodes, 0.0);
    }

    #[test]
    fn stress_postprocess_separates_dense_path_nodes() {
        let nodes = varied_nodes(12);
        let edges: Vec<_> = (0..11).map(|id| LayoutEdge::new(id, id + 1)).collect();
        let result = layout_stress(
            &nodes,
            &edges,
            &StressConfig {
                iterations: 18,
                edge_length: 64.0,
                step: 0.06,
            },
        );

        assert_eq!(result.count(), 12);
        assert_no_overlaps(&result.nodes, 0.0);
    }
}

mod refresh_budget_tests {
    use super::*;

    fn graph_nodes(count: usize) -> Vec<LayoutNode> {
        (0..count)
            .map(|id| LayoutNode::new(id).with_size(36.0, 20.0))
            .collect()
    }

    fn graph_edges(count: usize) -> Vec<LayoutEdge> {
        (0..count)
            .flat_map(|id| {
                [
                    LayoutEdge::new(id, (id + 1) % count),
                    LayoutEdge::new(id, (id + 7) % count),
                ]
            })
            .collect()
    }

    #[test]
    fn common_auto_layouts_fit_10fps_refresh_budget() {
        let nodes = graph_nodes(80);
        let edges = graph_edges(80);
        let config = LayoutConfig {
            h_spacing: 32.0,
            v_spacing: 56.0,
            margin: 12.0,
        };
        let stress_config = StressConfig {
            iterations: 8,
            edge_length: 54.0,
            step: 0.05,
        };

        let start = Instant::now();
        assert_eq!(layout_circular(&nodes, &config).count(), nodes.len());
        assert_eq!(
            layout_radial(&nodes, &edges, 0, &config).count(),
            nodes.len()
        );
        assert_eq!(layout_grid(&nodes, &config).count(), nodes.len());
        assert_eq!(layout_spiral(&nodes, &config).count(), nodes.len());
        assert_eq!(
            layout_stress(&nodes, &edges, &stress_config).count(),
            nodes.len()
        );
        let elapsed = start.elapsed();

        assert!(
            elapsed < Duration::from_millis(100),
            "five auto layouts should refresh within 100ms for 80 nodes, got {elapsed:?}"
        );
    }

    #[test]
    fn common_chart_renderers_fit_10fps_refresh_budget() {
        let config = ChartConfig {
            width: 320,
            height: 220,
            show_legend: true,
            ..ChartConfig::default()
        };
        let mut buffer = vec![0u8; (config.width * config.height * 4) as usize];

        let mut candles = CandlestickChart::new(config.clone());
        candles.set_candles(
            (0..64)
                .map(|i| Candle {
                    label: format!("{i}"),
                    open: 90.0 + i as f32 * 0.2,
                    high: 94.0 + i as f32 * 0.2,
                    low: 88.0 + i as f32 * 0.2,
                    close: 91.0 + (i % 5) as f32,
                })
                .collect(),
        );

        let mut boxplot = BoxPlotChart::new(config.clone());
        boxplot.add_series(
            "latency",
            &(0..128).map(|i| 10.0 + (i % 31) as f32).collect::<Vec<_>>(),
            [0.22, 0.52, 0.73, 1.0],
        );

        let mut bubble = BubbleChart::new(config.clone());
        bubble.add_series(
            "cities",
            &(0..96)
                .map(|i| (i as f32, (i * 7 % 41) as f32, (i % 17 + 1) as f32))
                .collect::<Vec<_>>(),
            [0.18, 0.66, 0.40, 1.0],
        );

        let mut radar = RadarChart::new(config.clone());
        radar.set_axes(vec![
            "speed".into(),
            "power".into(),
            "range".into(),
            "cost".into(),
            "risk".into(),
        ]);
        radar.add_series("A", &[4.0, 3.0, 5.0, 2.0, 4.0], [0.58, 0.40, 0.74, 1.0]);
        radar.add_series("B", &[2.0, 5.0, 3.0, 4.0, 2.0], [0.89, 0.33, 0.29, 1.0]);

        let mut treemap = TreemapChart::new(config.clone());
        treemap.set_items(
            (0..40)
                .map(|i| TreemapItem {
                    label: format!("Item {i}"),
                    value: (i % 9 + 1) as f32,
                    color: [0.2 + (i % 4) as f32 * 0.1, 0.45, 0.65, 1.0],
                })
                .collect(),
        );

        let start = Instant::now();
        candles.render(&mut buffer);
        boxplot.render(&mut buffer);
        bubble.render(&mut buffer);
        radar.render(&mut buffer);
        treemap.render(&mut buffer);
        let elapsed = start.elapsed();

        assert!(
            elapsed < Duration::from_millis(100),
            "five chart renderers should refresh within 100ms at 320x220, got {elapsed:?}"
        );
    }
}
