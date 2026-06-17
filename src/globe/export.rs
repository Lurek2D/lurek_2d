//! Provides globe geometry export helpers that convert region polygons into portable mesh text output. `globe/export` delivers the export implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Emits flat OBJ data with deterministic region object grouping for downstream tooling. The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Delivers a simple export path for inspection, conversion, and offline map processing workflows. Public callable behavior is centered on `export_regions_to_obj`, `export_provinces_to_obj`, while method-level behavior such as no named public items stays attached to the local data model and invariants.
//! `globe/export` delivers the export implementation for the globe subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! The file owns or coordinates data contracts including no named public items, so readers can connect concrete Rust types to the feature responsibilities described by this module.

use crate::globe::registry::Globe;
use crate::globe::types::{Region, RegionPart};
use crate::math::{polygon, Vec2};
use std::fmt::Write;
/// Export region polygons as a flat OBJ string with one object per region.
pub fn export_regions_to_obj(globe: &Globe) -> String {
    let mut out = String::new();
    let mut vertex_base: u32 = 1;
    for region in globe.graph.iter() {
        for (part_index, part) in region_parts(region).iter().enumerate() {
            let _ = writeln!(&mut out, "o region_{}_part_{}", region.id, part_index);
            export_loop_lines(
                &mut out,
                &mut vertex_base,
                &part.outer,
                &format!("region_{}_part_{}_outer", region.id, part_index),
            );
            for (hole_index, hole) in part.holes.iter().enumerate() {
                export_loop_lines(
                    &mut out,
                    &mut vertex_base,
                    hole,
                    &format!(
                        "region_{}_part_{}_hole_{}",
                        region.id, part_index, hole_index
                    ),
                );
            }
            if let Some(fill_polygon) = stitch_part_with_holes(part) {
                let start = vertex_base;
                let _ = writeln!(&mut out, "g region_{}_part_{}_fill", region.id, part_index);
                for &(x, y) in &fill_polygon {
                    let _ = writeln!(&mut out, "v {} {} 0.0", x, y);
                }
                for tri in triangulate_xy_polygon(&fill_polygon) {
                    let _ = writeln!(
                        &mut out,
                        "f {} {} {}",
                        start + tri[0] as u32,
                        start + tri[1] as u32,
                        start + tri[2] as u32
                    );
                }
                vertex_base += fill_polygon.len() as u32;
            }
        }
    }
    out
}

/// Backward compatibility alias.
#[inline]
pub fn export_provinces_to_obj(globe: &Globe) -> String {
    export_regions_to_obj(globe)
}

fn region_parts(region: &Region) -> Vec<RegionPart> {
    if !region.parts.is_empty() {
        return region.parts.clone();
    }
    if region.vertices.is_empty() {
        Vec::new()
    } else {
        vec![RegionPart::new(region.vertices.clone())]
    }
}

fn export_loop_lines(
    out: &mut String,
    vertex_base: &mut u32,
    loop_vertices: &[(f32, f32)],
    group_name: &str,
) {
    if loop_vertices.len() < 2 {
        return;
    }
    let start = *vertex_base;
    let _ = writeln!(out, "g {group_name}");
    for &(lat, lon) in loop_vertices {
        let _ = writeln!(out, "v {} {} 0.0", lon, lat);
    }
    let mut line = String::from("l");
    for index in 0..loop_vertices.len() {
        let _ = write!(line, " {}", start + index as u32);
    }
    let _ = write!(line, " {}", start);
    let _ = writeln!(out, "{line}");
    *vertex_base += loop_vertices.len() as u32;
}

fn triangulate_xy_polygon(points: &[(f32, f32)]) -> Vec<[usize; 3]> {
    let verts: Vec<Vec2> = points.iter().map(|&(x, y)| Vec2::new(x, y)).collect();
    let Ok(tris) = polygon::triangulate(&verts) else {
        return Vec::new();
    };
    tris.into_iter()
        .filter_map(|tri| {
            let mut out = [0usize; 3];
            for (slot, point) in tri.into_iter().enumerate() {
                let index = verts.iter().position(|candidate| {
                    candidate.x.to_bits() == point.x.to_bits()
                        && candidate.y.to_bits() == point.y.to_bits()
                })?;
                out[slot] = index;
            }
            Some(out)
        })
        .collect()
}

fn stitch_part_with_holes(part: &RegionPart) -> Option<Vec<(f32, f32)>> {
    if part.outer.len() < 3 {
        return None;
    }
    let mut merged = ensure_ccw(to_xy_loop(&part.outer));
    let mut holes: Vec<Vec<(f32, f32)>> = part
        .holes
        .iter()
        .filter(|hole| hole.len() >= 3)
        .map(|hole| ensure_cw(to_xy_loop(hole)))
        .collect();
    holes.sort_by(|a, b| rightmost_x(b).total_cmp(&rightmost_x(a)));
    while !holes.is_empty() {
        let hole = holes.remove(0);
        let hole_idx = rightmost_index(&hole);
        let outer_idx = find_bridge_vertex(&merged, &hole, &holes, hole_idx)?;
        merged = merge_hole_into_polygon(&merged, &hole, outer_idx, hole_idx);
    }
    Some(merged)
}

fn to_xy_loop(points: &[(f32, f32)]) -> Vec<(f32, f32)> {
    points.iter().map(|&(lat, lon)| (lon, lat)).collect()
}

fn signed_area(points: &[(f32, f32)]) -> f32 {
    let mut area = 0.0_f32;
    for i in 0..points.len() {
        let (ax, ay) = points[i];
        let (bx, by) = points[(i + 1) % points.len()];
        area += ax * by - bx * ay;
    }
    area * 0.5
}

fn ensure_ccw(mut points: Vec<(f32, f32)>) -> Vec<(f32, f32)> {
    if signed_area(&points) < 0.0 {
        points.reverse();
    }
    points
}

fn ensure_cw(mut points: Vec<(f32, f32)>) -> Vec<(f32, f32)> {
    if signed_area(&points) > 0.0 {
        points.reverse();
    }
    points
}

fn rightmost_x(points: &[(f32, f32)]) -> f32 {
    points
        .iter()
        .map(|(x, _)| *x)
        .fold(f32::NEG_INFINITY, f32::max)
}

fn rightmost_index(points: &[(f32, f32)]) -> usize {
    let mut best = 0usize;
    for i in 1..points.len() {
        if points[i].0 > points[best].0
            || (points[i].0 == points[best].0 && points[i].1 < points[best].1)
        {
            best = i;
        }
    }
    best
}

fn find_bridge_vertex(
    outer: &[(f32, f32)],
    hole: &[(f32, f32)],
    other_holes: &[Vec<(f32, f32)>],
    hole_idx: usize,
) -> Option<usize> {
    for require_right in [true, false] {
        let mut best: Option<(f32, usize)> = None;
        let hole_point = hole[hole_idx];
        for (outer_idx, &outer_point) in outer.iter().enumerate() {
            if require_right && outer_point.0 + 1e-5 < hole_point.0 {
                continue;
            }
            if !bridge_segment_is_visible(
                outer,
                hole,
                other_holes,
                outer_idx,
                hole_idx,
                outer_point,
                hole_point,
            ) {
                continue;
            }
            let dx = outer_point.0 - hole_point.0;
            let dy = outer_point.1 - hole_point.1;
            let distance_sq = dx * dx + dy * dy;
            if best
                .as_ref()
                .is_none_or(|(best_dist, _)| distance_sq < *best_dist)
            {
                best = Some((distance_sq, outer_idx));
            }
        }
        if let Some((_, outer_idx)) = best {
            return Some(outer_idx);
        }
    }
    None
}

fn bridge_segment_is_visible(
    outer: &[(f32, f32)],
    hole: &[(f32, f32)],
    other_holes: &[Vec<(f32, f32)>],
    outer_idx: usize,
    hole_idx: usize,
    outer_point: (f32, f32),
    hole_point: (f32, f32),
) -> bool {
    let midpoint = (
        (outer_point.0 + hole_point.0) * 0.5,
        (outer_point.1 + hole_point.1) * 0.5,
    );
    if !point_in_polygon(midpoint, outer) {
        return false;
    }
    if other_holes
        .iter()
        .any(|loop_points| point_in_polygon(midpoint, loop_points))
    {
        return false;
    }
    if segment_crosses_loop(outer_point, hole_point, outer, Some(outer_idx)) {
        return false;
    }
    if segment_crosses_loop(hole_point, outer_point, hole, Some(hole_idx)) {
        return false;
    }
    if other_holes
        .iter()
        .any(|loop_points| segment_crosses_loop(outer_point, hole_point, loop_points, None))
    {
        return false;
    }
    true
}

fn segment_crosses_loop(
    a: (f32, f32),
    b: (f32, f32),
    loop_points: &[(f32, f32)],
    incident_vertex: Option<usize>,
) -> bool {
    for i in 0..loop_points.len() {
        let j = (i + 1) % loop_points.len();
        if let Some(incident) = incident_vertex {
            if i == incident || j == incident {
                continue;
            }
        }
        if segments_properly_intersect(a, b, loop_points[i], loop_points[j]) {
            return true;
        }
    }
    false
}

fn merge_hole_into_polygon(
    outer: &[(f32, f32)],
    hole: &[(f32, f32)],
    outer_idx: usize,
    hole_idx: usize,
) -> Vec<(f32, f32)> {
    let mut merged = Vec::with_capacity(outer.len() + hole.len() + 2);
    merged.extend_from_slice(&outer[..=outer_idx]);
    merged.push(hole[hole_idx]);
    for step in 1..hole.len() {
        merged.push(hole[(hole_idx + step) % hole.len()]);
    }
    merged.push(hole[hole_idx]);
    merged.push(outer[outer_idx]);
    merged.extend_from_slice(&outer[outer_idx + 1..]);
    merged
}

fn point_in_polygon(point: (f32, f32), polygon: &[(f32, f32)]) -> bool {
    let mut inside = false;
    let mut j = polygon.len() - 1;
    for i in 0..polygon.len() {
        let (xi, yi) = polygon[i];
        let (xj, yj) = polygon[j];
        let mut denom = yj - yi;
        if denom.abs() < f32::EPSILON {
            denom = if denom.is_sign_negative() {
                -f32::EPSILON
            } else {
                f32::EPSILON
            };
        }
        let intersects = ((yi > point.1) != (yj > point.1))
            && (point.0 < (xj - xi) * (point.1 - yi) / denom + xi);
        if intersects {
            inside = !inside;
        }
        j = i;
    }
    inside
}

fn segments_properly_intersect(
    a1: (f32, f32),
    a2: (f32, f32),
    b1: (f32, f32),
    b2: (f32, f32),
) -> bool {
    if shares_endpoint(a1, a2, b1, b2) {
        return false;
    }
    let o1 = orientation(a1, a2, b1);
    let o2 = orientation(a1, a2, b2);
    let o3 = orientation(b1, b2, a1);
    let o4 = orientation(b1, b2, a2);
    if o1 == 0.0 && on_segment(a1, b1, a2) {
        return true;
    }
    if o2 == 0.0 && on_segment(a1, b2, a2) {
        return true;
    }
    if o3 == 0.0 && on_segment(b1, a1, b2) {
        return true;
    }
    if o4 == 0.0 && on_segment(b1, a2, b2) {
        return true;
    }
    (o1 > 0.0) != (o2 > 0.0) && (o3 > 0.0) != (o4 > 0.0)
}

fn shares_endpoint(a1: (f32, f32), a2: (f32, f32), b1: (f32, f32), b2: (f32, f32)) -> bool {
    approx_eq(a1, b1) || approx_eq(a1, b2) || approx_eq(a2, b1) || approx_eq(a2, b2)
}

fn approx_eq(a: (f32, f32), b: (f32, f32)) -> bool {
    (a.0 - b.0).abs() <= 1e-5 && (a.1 - b.1).abs() <= 1e-5
}

fn orientation(a: (f32, f32), b: (f32, f32), c: (f32, f32)) -> f32 {
    (b.1 - a.1) * (c.0 - b.0) - (b.0 - a.0) * (c.1 - b.1)
}

fn on_segment(a: (f32, f32), b: (f32, f32), c: (f32, f32)) -> bool {
    b.0 >= a.0.min(c.0) - 1e-5
        && b.0 <= a.0.max(c.0) + 1e-5
        && b.1 >= a.1.min(c.1) - 1e-5
        && b.1 <= a.1.max(c.1) + 1e-5
}
