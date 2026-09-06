//! Focused tests for reusable polygon geometry helpers used by authored province maps.

use lurek2d::math::{
    classify_point_in_polygon, normalize_polygon_ring, polygon_self_intersects,
    polygons_overlap_positive_area, shared_quantized_edge_intervals, snap_coordinate,
    widest_horizontal_chord, PolygonPointLocation,
};

#[test]
fn snapping_and_ring_normalization_are_tolerant_and_deterministic() {
    let (snapped, displacement) = snap_coordinate(2.04, 1.0).expect("valid snap");
    assert_eq!(snapped, 2.0);
    assert!((displacement - 0.04).abs() < 1.0e-6);
    let ring = normalize_polygon_ring(&[0.0, 0.0, 2.0, 0.0, 2.0, 1.0, 0.0, 0.0], 1.0e-5);
    assert_eq!(ring, vec![0.0, 0.0, 2.0, 0.0, 2.0, 1.0]);
}

#[test]
fn point_classification_distinguishes_inside_boundary_and_outside() {
    let square = [0.0, 0.0, 4.0, 0.0, 4.0, 4.0, 0.0, 4.0];
    assert_eq!(
        classify_point_in_polygon(&square, 2.0, 2.0, 1.0e-5),
        PolygonPointLocation::Inside
    );
    assert_eq!(
        classify_point_in_polygon(&square, 4.0, 2.0, 1.0e-5),
        PolygonPointLocation::Boundary
    );
    assert_eq!(
        classify_point_in_polygon(&square, 5.0, 2.0, 1.0e-5),
        PolygonPointLocation::Outside
    );
}

#[test]
fn self_intersection_and_positive_overlap_are_rejected_but_touching_is_allowed() {
    let bowtie = [0.0, 0.0, 4.0, 4.0, 0.0, 4.0, 4.0, 0.0];
    assert!(polygon_self_intersects(&bowtie, 1.0e-5));
    let non_adjacent_touch = [0.0, 0.0, 4.0, 0.0, 4.0, 4.0, 2.0, 2.0, 0.0, 4.0, 2.0, 2.0];
    assert!(polygon_self_intersects(&non_adjacent_touch, 1.0e-5));
    let left = [0.0, 0.0, 2.0, 0.0, 2.0, 2.0, 0.0, 2.0];
    let touching = [2.0, 0.0, 4.0, 0.0, 4.0, 2.0, 2.0, 2.0];
    let overlap = [1.0, 0.0, 3.0, 0.0, 3.0, 2.0, 1.0, 2.0];
    assert!(!polygons_overlap_positive_area(&left, &touching, 1.0e-5));
    assert!(polygons_overlap_positive_area(&left, &overlap, 1.0e-5));
}

#[test]
fn widest_chord_passes_through_requested_point() {
    let concave = [
        0.0, 0.0, 6.0, 0.0, 6.0, 6.0, 4.0, 6.0, 4.0, 2.0, 2.0, 2.0, 2.0, 6.0, 0.0, 6.0,
    ];
    assert_eq!(
        widest_horizontal_chord(&concave, 1.0, 3.0, 1.0e-5),
        Some((0.0, 6.0))
    );
}

#[test]
fn shared_edges_merge_midpoints_but_ignore_point_contacts() {
    let left = [0.0, 0.0, 4.0, 0.0, 4.0, 4.0, 0.0, 4.0];
    let right_with_midpoint = [4.0, 0.0, 8.0, 0.0, 8.0, 4.0, 4.0, 4.0, 4.0, 2.0];
    let intervals = shared_quantized_edge_intervals(
        &[(1, left.as_slice()), (2, right_with_midpoint.as_slice())],
        1.0,
    )
    .expect("shared edge interval");
    assert_eq!(intervals.len(), 1);
    assert_eq!(intervals[0].owner_a, 1);
    assert_eq!(intervals[0].owner_b, 2);
    assert_eq!(intervals[0].start, (4, 0));
    assert_eq!(intervals[0].end, (4, 4));

    let point_touch = [4.0, 4.0, 6.0, 4.0, 6.0, 6.0, 4.0, 6.0];
    let intervals =
        shared_quantized_edge_intervals(&[(1, left.as_slice()), (2, point_touch.as_slice())], 1.0)
            .expect("point contact is valid");
    assert!(intervals.is_empty());
}

#[test]
fn shared_edge_sweep_handles_large_quantized_edges_without_unit_expansion() {
    let first = [0.0, 0.0, 1_000_000.0, 0.0, 1_000_000.0, 2.0, 0.0, 2.0];
    let second = [1_000_000.0, 0.0, 1_000_001.0, 1.0, 1_000_000.0, 2.0];
    let intervals =
        shared_quantized_edge_intervals(&[(1, first.as_slice()), (2, second.as_slice())], 1.0)
            .expect("large shared edge should be bounded");
    assert_eq!(
        intervals,
        vec![lurek2d::math::QuantizedSharedEdge {
            owner_a: 1,
            owner_b: 2,
            start: (1_000_000, 0),
            end: (1_000_000, 2),
        }]
    );
}
