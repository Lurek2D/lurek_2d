//! Owns expanding spiral placement for large unordered graphs, search results, and map-like previews.
//! Sorts node ids, probes a golden-angle spiral, and rejects positions colliding with prior nodes.
//! Ignores edges for fast refreshes; change this file for spacing, probes, or collision policy.

use super::types::*;

/// Lay out nodes on an expanding spiral using sorted node ids.
pub fn layout_spiral(nodes: &[LayoutNode], config: &LayoutConfig) -> LayoutResult {
    if nodes.is_empty() {
        return LayoutResult::new(Vec::new());
    }

    let mut ordered = nodes.to_vec();
    ordered.sort_by_key(|node| node.id);

    let step = (max_node_side(&ordered) + config.h_spacing.max(config.v_spacing).max(1.0))
        .max(1.0);
    let padding = config.h_spacing.max(config.v_spacing).max(1.0) * 0.35;
    let golden_angle = 2.399_963_229_728_653;
    let mut placed: Vec<LayoutNode> = Vec::with_capacity(ordered.len());

    for (index, node) in ordered.iter_mut().enumerate() {
        if index == 0 {
            node.x = 0.0;
            node.y = 0.0;
            placed.push(node.clone());
            continue;
        }
        let mut probe = index as f64;
        for _ in 0..4096 {
            let angle = probe * golden_angle;
            let radius = step * probe.sqrt();
            node.x = radius * angle.cos() - node_width(node) * 0.5;
            node.y = radius * angle.sin() - node_height(node) * 0.5;
            if !placed
                .iter()
                .any(|other| nodes_overlap(node, other, padding))
            {
                break;
            }
            probe += 0.5;
        }
        placed.push(node.clone());
    }

    normalize_to_margin(&mut ordered, config.margin);
    LayoutResult::new(ordered)
}
