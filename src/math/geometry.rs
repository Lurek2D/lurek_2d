//! This file owns standalone geometry routines for angles, intersections, rasterization, hulls, and polygon measures.
//! Circle, line, segment, and point helpers stay here because they are free functions rather than shape-owned methods.
//! Polygon area, centroid, point inclusion, and convex-hull utilities also belong here as shared flat-coordinate tools.
//! Bresenham line stepping remains local because grid traversal is geometry support, not a rendering system concern.
//! Delaunay triangulation also belongs here since it provides reusable mesh and Voronoi preparation over raw points.
//! This file is the shared toolbox boundary, not the owner of rectangles, circles, vectors, or dynamic spatial indexes.
//! Open it when low-level query semantics change; dedicated shape types and trees live in sibling math modules.

/// Return the angle in radians from point (x1, y1) to point (x2, y2) via `atan2`.
pub fn angle_between(x1: f32, y1: f32, x2: f32, y2: f32) -> f32 {
    (y2 - y1).atan2(x2 - x1)
}

/// Return true when point (px, py) lies inside or on the boundary of circle (cx, cy, r).
pub fn circle_contains_point(cx: f32, cy: f32, r: f32, px: f32, py: f32) -> bool {
    let dx = px - cx;
    let dy = py - cy;
    dx * dx + dy * dy <= r * r
}

/// Return true when two circles overlap (touching counts as intersection).
pub fn circle_intersects_circle(x1: f32, y1: f32, r1: f32, x2: f32, y2: f32, r2: f32) -> bool {
    let dx = x2 - x1;
    let dy = y2 - y1;
    let sum_r = r1 + r2;
    dx * dx + dy * dy <= sum_r * sum_r
}

/// Return whether an infinite line intersects a circle and the up to two intersection points.
#[allow(clippy::type_complexity)]
pub fn circle_intersects_line(
    cx: f32,
    cy: f32,
    r: f32,
    lx1: f32,
    ly1: f32,
    lx2: f32,
    ly2: f32,
) -> (bool, Option<(f32, f32)>, Option<(f32, f32)>) {
    let dx = lx2 - lx1;
    let dy = ly2 - ly1;
    let fx = lx1 - cx;
    let fy = ly1 - cy;
    let a = dx * dx + dy * dy;
    if a < 1e-10 {
        return (false, None, None);
    }
    let b = 2.0 * (fx * dx + fy * dy);
    let c = fx * fx + fy * fy - r * r;
    let discriminant = b * b - 4.0 * a * c;
    if discriminant < 0.0 {
        return (false, None, None);
    }
    let sqrt_d = discriminant.sqrt();
    let t1 = (-b - sqrt_d) / (2.0 * a);
    let t2 = (-b + sqrt_d) / (2.0 * a);
    let p1 = Some((lx1 + t1 * dx, ly1 + t1 * dy));
    let p2 = if discriminant > 1e-10 {
        Some((lx1 + t2 * dx, ly1 + t2 * dy))
    } else {
        None
    };
    (true, p1, p2)
}

/// Return whether a finite segment intersects a circle and the intersection points within `[0,1]` range.
#[allow(clippy::type_complexity)]
pub fn circle_intersects_segment(
    cx: f32,
    cy: f32,
    r: f32,
    sx1: f32,
    sy1: f32,
    sx2: f32,
    sy2: f32,
) -> (bool, Option<(f32, f32)>, Option<(f32, f32)>) {
    let dx = sx2 - sx1;
    let dy = sy2 - sy1;
    let fx = sx1 - cx;
    let fy = sy1 - cy;
    let a = dx * dx + dy * dy;
    if a < 1e-10 {
        return (false, None, None);
    }
    let b = 2.0 * (fx * dx + fy * dy);
    let c = fx * fx + fy * fy - r * r;
    let discriminant = b * b - 4.0 * a * c;
    if discriminant < 0.0 {
        return (false, None, None);
    }
    let sqrt_d = discriminant.sqrt();
    let t1 = (-b - sqrt_d) / (2.0 * a);
    let t2 = (-b + sqrt_d) / (2.0 * a);
    let p1 = if (0.0..=1.0).contains(&t1) {
        Some((sx1 + t1 * dx, sy1 + t1 * dy))
    } else {
        None
    };
    let p2 = if discriminant > 1e-10 && (0.0..=1.0).contains(&t2) {
        Some((sx1 + t2 * dx, sy1 + t2 * dy))
    } else {
        None
    };
    let any_hit = p1.is_some() || p2.is_some();
    (any_hit, p1, p2)
}

/// Return the signed area of a flat vertex array `[x0, y0, x1, y1, ...]`; positive = CCW.
pub fn polygon_area(vertices: &[f32]) -> f32 {
    let n = vertices.len() / 2;
    if n < 3 {
        return 0.0;
    }
    let mut area = 0.0;
    for i in 0..n {
        let j = (i + 1) % n;
        let xi = vertices[i * 2];
        let yi = vertices[i * 2 + 1];
        let xj = vertices[j * 2];
        let yj = vertices[j * 2 + 1];
        area += xi * yj - xj * yi;
    }
    area * 0.5
}

/// Return the centroid (cx, cy) of a flat vertex array; falls back to arithmetic mean for degenerate polygons.
pub fn polygon_centroid(vertices: &[f32]) -> (f32, f32) {
    let n = vertices.len() / 2;
    if n == 0 {
        return (0.0, 0.0);
    }
    let mut cx = 0.0;
    let mut cy = 0.0;
    let mut signed_area = 0.0;
    for i in 0..n {
        let j = (i + 1) % n;
        let xi = vertices[i * 2];
        let yi = vertices[i * 2 + 1];
        let xj = vertices[j * 2];
        let yj = vertices[j * 2 + 1];
        let cross = xi * yj - xj * yi;
        signed_area += cross;
        cx += (xi + xj) * cross;
        cy += (yi + yj) * cross;
    }
    signed_area *= 0.5;
    if signed_area.abs() < 1e-10 {
        let mut sx = 0.0;
        let mut sy = 0.0;
        for i in 0..n {
            sx += vertices[i * 2];
            sy += vertices[i * 2 + 1];
        }
        return (sx / n as f32, sy / n as f32);
    }
    let factor = 1.0 / (6.0 * signed_area);
    (cx * factor, cy * factor)
}

/// Return whether two line segments intersect and the intersection point when they do.
#[allow(clippy::too_many_arguments)]
pub fn segment_intersects_segment(
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
    x3: f32,
    y3: f32,
    x4: f32,
    y4: f32,
) -> (bool, Option<(f32, f32)>) {
    let d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if d.abs() < 1e-10 {
        return (false, None);
    }
    let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / d;
    let u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / d;
    if (0.0..=1.0).contains(&t) && (0.0..=1.0).contains(&u) {
        let ix = x1 + t * (x2 - x1);
        let iy = y1 + t * (y2 - y1);
        (true, Some((ix, iy)))
    } else {
        (false, None)
    }
}

/// Return the closest point on segment (x1,y1)-(x2,y2) to point (px, py), clamped to segment endpoints.
pub fn closest_point_on_segment(
    px: f32,
    py: f32,
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
) -> (f32, f32) {
    let dx = x2 - x1;
    let dy = y2 - y1;
    let len_sq = dx * dx + dy * dy;
    if len_sq < 1e-10 {
        return (x1, y1);
    }
    let t = ((px - x1) * dx + (py - y1) * dy) / len_sq;
    let t = t.clamp(0.0, 1.0);
    (x1 + t * dx, y1 + t * dy)
}

/// Return true when point (px, py) is inside the polygon described by flat vertex array using ray casting.
pub fn point_in_polygon(vertices: &[f32], px: f32, py: f32) -> bool {
    let n = vertices.len() / 2;
    if n < 3 {
        return false;
    }
    let mut inside = false;
    let mut j = n - 1;
    for i in 0..n {
        let xi = vertices[i * 2];
        let yi = vertices[i * 2 + 1];
        let xj = vertices[j * 2];
        let yj = vertices[j * 2 + 1];
        if ((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi) {
            inside = !inside;
        }
        j = i;
    }
    inside
}

/// Location of a point relative to a polygon boundary.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PolygonPointLocation {
    /// The point is strictly inside the polygon.
    Inside,
    /// The point lies on an edge or vertex.
    Boundary,
    /// The point is outside the polygon.
    Outside,
}

/// Classify a point against a flat polygon, treating points on an edge as boundary points.
pub fn classify_point_in_polygon(
    vertices: &[f32],
    px: f32,
    py: f32,
    epsilon: f32,
) -> PolygonPointLocation {
    let n = vertices.len() / 2;
    if n < 3 || !px.is_finite() || !py.is_finite() {
        return PolygonPointLocation::Outside;
    }
    let eps = epsilon.max(f32::EPSILON);
    for i in 0..n {
        let j = (i + 1) % n;
        let ax = vertices[i * 2];
        let ay = vertices[i * 2 + 1];
        let bx = vertices[j * 2];
        let by = vertices[j * 2 + 1];
        if point_on_segment_inclusive(px, py, ax, ay, bx, by, eps) {
            return PolygonPointLocation::Boundary;
        }
    }
    if point_in_polygon(vertices, px, py) {
        PolygonPointLocation::Inside
    } else {
        PolygonPointLocation::Outside
    }
}

/// Return true when a finite point lies on a finite segment, including its
/// endpoints, within `epsilon` distance.  This predicate is shared by
/// polygon boundary classification, picking, and topology validation.
pub fn point_on_segment_inclusive(
    px: f32,
    py: f32,
    x0: f32,
    y0: f32,
    x1: f32,
    y1: f32,
    epsilon: f32,
) -> bool {
    if ![px, py, x0, y0, x1, y1]
        .iter()
        .all(|value| value.is_finite())
    {
        return false;
    }
    let eps = epsilon.max(f32::EPSILON);
    let dx = x1 - x0;
    let dy = y1 - y0;
    let len_sq = dx * dx + dy * dy;
    if len_sq <= eps * eps {
        return (px - x0).hypot(py - y0) <= eps;
    }
    let cross = (px - x0) * dy - (py - y0) * dx;
    if cross.abs() > eps * len_sq.sqrt() {
        return false;
    }
    let dot = (px - x0) * dx + (py - y0) * dy;
    dot >= -eps && dot <= len_sq + eps
}

/// Return the axis-aligned bounds `(min_x, min_y, max_x, max_y)` of a flat polygon.
pub fn polygon_bounds(vertices: &[f32]) -> Option<(f32, f32, f32, f32)> {
    if vertices.len() < 6 || !vertices.len().is_multiple_of(2) {
        return None;
    }
    let mut min_x = f32::INFINITY;
    let mut min_y = f32::INFINITY;
    let mut max_x = f32::NEG_INFINITY;
    let mut max_y = f32::NEG_INFINITY;
    for pair in vertices.chunks_exact(2) {
        let x = pair[0];
        let y = pair[1];
        if !x.is_finite() || !y.is_finite() {
            return None;
        }
        min_x = min_x.min(x);
        min_y = min_y.min(y);
        max_x = max_x.max(x);
        max_y = max_y.max(y);
    }
    Some((min_x, min_y, max_x, max_y))
}

/// Snap one coordinate to `step`, returning the snapped value and displacement.
pub fn snap_coordinate(value: f32, step: f32) -> Option<(f32, f32)> {
    if !value.is_finite() || !step.is_finite() || step <= 0.0 {
        return None;
    }
    let snapped = (value / step).round() * step;
    if !snapped.is_finite() {
        return None;
    }
    Some((snapped, (snapped - value).abs()))
}

/// Remove a repeated closing vertex and consecutive duplicate vertices from a ring.
pub fn normalize_polygon_ring(vertices: &[f32], epsilon: f32) -> Vec<f32> {
    if vertices.len() < 2 {
        return vertices.to_vec();
    }
    let eps = epsilon.max(f32::EPSILON);
    let mut out: Vec<f32> = Vec::with_capacity(vertices.len());
    for pair in vertices.chunks_exact(2) {
        let duplicate = out.chunks_exact(2).last().is_some_and(|last| {
            (last[0] - pair[0]).abs() <= eps && (last[1] - pair[1]).abs() <= eps
        });
        if !duplicate {
            out.extend_from_slice(pair);
        }
    }
    if out.len() >= 4 {
        let first = (out[0], out[1]);
        let last = (out[out.len() - 2], out[out.len() - 1]);
        if (first.0 - last.0).abs() <= eps && (first.1 - last.1).abs() <= eps {
            out.truncate(out.len() - 2);
        }
    }
    out
}

/// Return the widest interior horizontal chord at `y` that contains `through_x`.
///
/// The polygon is a simple flat ring. Edge crossings use a half-open rule so a
/// vertex is not counted twice; the helper is therefore useful for deterministic
/// label baselines as well as generic geometry queries.
pub fn widest_horizontal_chord(
    vertices: &[f32],
    y: f32,
    through_x: f32,
    epsilon: f32,
) -> Option<(f32, f32)> {
    if vertices.len() < 6 || !y.is_finite() || !through_x.is_finite() {
        return None;
    }
    let n = vertices.len() / 2;
    let mut intersections = Vec::new();
    for i in 0..n {
        let j = (i + 1) % n;
        let ax = vertices[i * 2];
        let ay = vertices[i * 2 + 1];
        let bx = vertices[j * 2];
        let by = vertices[j * 2 + 1];
        if (ay <= y && by > y) || (by <= y && ay > y) {
            let denominator = by - ay;
            if denominator.abs() > epsilon.max(1.0e-6) {
                intersections.push(ax + (y - ay) * (bx - ax) / denominator);
            }
        }
    }
    intersections.sort_by(f32::total_cmp);
    intersections.dedup_by(|a, b| (*a - *b).abs() <= epsilon.max(1.0e-6));
    let mut best = None;
    for pair in intersections.chunks_exact(2) {
        let (left, right) = (pair[0].min(pair[1]), pair[0].max(pair[1]));
        if through_x < left - epsilon || through_x > right + epsilon {
            continue;
        }
        if right - left > best.map(|(a, b)| b - a).unwrap_or(-1.0) {
            best = Some((left, right));
        }
    }
    best
}

/// Return true when a simple polygon ring has a non-adjacent edge crossing or overlap.
pub fn polygon_self_intersects(vertices: &[f32], epsilon: f32) -> bool {
    let n = vertices.len() / 2;
    if n < 3 || !vertices.len().is_multiple_of(2) {
        return true;
    }
    for i in 0..n {
        let a0 = (vertices[i * 2], vertices[i * 2 + 1]);
        let a1 = (vertices[((i + 1) % n) * 2], vertices[((i + 1) % n) * 2 + 1]);
        for j in (i + 1)..n {
            if (j + 1) % n == i || (i + 1) % n == j {
                continue;
            }
            let b0 = (vertices[j * 2], vertices[j * 2 + 1]);
            let b1 = (vertices[((j + 1) % n) * 2], vertices[((j + 1) % n) * 2 + 1]);
            if segments_intersect_inclusive(a0, a1, b0, b1, epsilon) {
                return true;
            }
        }
    }
    false
}

/// Return whether two finite segments have any boundary-inclusive intersection.
///
/// This is intentionally separate from positive-area overlap checks: a
/// non-adjacent endpoint touch is invalid for a simple ring, while a point or
/// line touch between two independent polygons remains a legal topology case.
fn segments_intersect_inclusive(
    a0: (f32, f32),
    a1: (f32, f32),
    b0: (f32, f32),
    b1: (f32, f32),
    epsilon: f32,
) -> bool {
    if proper_segment_intersection(a0, a1, b0, b1, epsilon)
        || collinear_segment_overlap(a0, a1, b0, b1, epsilon)
    {
        return true;
    }
    let eps = epsilon.max(1.0e-6);
    let on_segment = |point: (f32, f32), start: (f32, f32), end: (f32, f32)| {
        orientation2(start, end, point).abs() <= eps
            && point.0 >= start.0.min(end.0) - eps
            && point.0 <= start.0.max(end.0) + eps
            && point.1 >= start.1.min(end.1) - eps
            && point.1 <= start.1.max(end.1) + eps
    };
    on_segment(a0, b0, b1)
        || on_segment(a1, b0, b1)
        || on_segment(b0, a0, a1)
        || on_segment(b1, a0, a1)
}

/// Return true when two simple polygons overlap over a positive-area region.
/// Touching at a point or along a shared boundary is not considered overlap.
pub fn polygons_overlap_positive_area(a: &[f32], b: &[f32], epsilon: f32) -> bool {
    let na = a.len() / 2;
    let nb = b.len() / 2;
    if na < 3 || nb < 3 || !a.len().is_multiple_of(2) || !b.len().is_multiple_of(2) {
        return false;
    }
    for i in 0..na {
        let a0 = (a[i * 2], a[i * 2 + 1]);
        let a1 = (a[((i + 1) % na) * 2], a[((i + 1) % na) * 2 + 1]);
        for j in 0..nb {
            let b0 = (b[j * 2], b[j * 2 + 1]);
            let b1 = (b[((j + 1) % nb) * 2], b[((j + 1) % nb) * 2 + 1]);
            if proper_segment_intersection(a0, a1, b0, b1, epsilon)
                || collinear_boundary_overlap_positive(a, b, a0, a1, b0, b1, epsilon)
            {
                return true;
            }
        }
    }
    let a_inside = (0..na).any(|i| {
        point_in_polygon(b, a[i * 2], a[i * 2 + 1])
            && classify_point_in_polygon(b, a[i * 2], a[i * 2 + 1], epsilon)
                == PolygonPointLocation::Inside
    });
    let b_inside = (0..nb).any(|i| {
        point_in_polygon(a, b[i * 2], b[i * 2 + 1])
            && classify_point_in_polygon(a, b[i * 2], b[i * 2 + 1], epsilon)
                == PolygonPointLocation::Inside
    });
    if a_inside || b_inside {
        return true;
    }
    (0..na).all(|i| {
        classify_point_in_polygon(b, a[i * 2], a[i * 2 + 1], epsilon)
            != PolygonPointLocation::Outside
    }) && (0..nb).all(|i| {
        classify_point_in_polygon(a, b[i * 2], b[i * 2 + 1], epsilon)
            != PolygonPointLocation::Outside
    })
}

/// One quantized positive-length shared edge interval owned by two records.
///
/// The owner values are deliberately plain integers so this helper remains
/// independent from province, tilemap, or renderer types.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct QuantizedSharedEdge {
    /// Lower sorted owner value.
    pub owner_a: u32,
    /// Higher sorted owner value.
    pub owner_b: u32,
    /// Quantized interval start.
    pub start: (i64, i64),
    /// Quantized interval end.
    pub end: (i64, i64),
}

/// Group quantized collinear ring edges and return exact shared intervals.
///
/// Each input tuple is `(owner, flat_vertices)`. Vertices are quantized to
/// `round(value / snap_size)` and grouped by their exact quantized supporting
/// line. Interval sweeping then matches an unsplit edge with a neighbour that
/// authored extra intermediate vertices without expanding a long edge into
/// every lattice unit. Point contacts are therefore omitted, while a
/// positive-length edge shared by more than two distinct owners is rejected.
pub fn shared_quantized_edge_intervals(
    rings: &[(u32, &[f32])],
    snap_size: f32,
) -> Result<Vec<QuantizedSharedEdge>, String> {
    if !snap_size.is_finite() || snap_size <= 0.0 {
        return Err("snap_size must be finite and positive".to_string());
    }
    let mut lines = std::collections::BTreeMap::<QuantizedLineKey, QuantizedLineState>::new();
    for &(owner, vertices) in rings {
        if vertices.len() < 6 || !vertices.len().is_multiple_of(2) {
            return Err("shared-edge rings require at least three vertices".to_string());
        }
        let points = vertices
            .chunks_exact(2)
            .map(|pair| {
                let x = quantize_geometry_coordinate(pair[0], snap_size)?;
                let y = quantize_geometry_coordinate(pair[1], snap_size)?;
                Ok((x, y))
            })
            .collect::<Result<Vec<_>, String>>()?;
        for i in 0..points.len() {
            let a = points[i];
            let b = points[(i + 1) % points.len()];
            let dx = b.0 as i128 - a.0 as i128;
            let dy = b.1 as i128 - a.1 as i128;
            if dx == 0 && dy == 0 {
                continue;
            }
            let gcd = gcd_u128(dx.unsigned_abs(), dy.unsigned_abs());
            let mut direction = (dx / gcd as i128, dy / gcd as i128);
            if direction.0 < 0 || (direction.0 == 0 && direction.1 < 0) {
                direction = (-direction.0, -direction.1);
            }
            let line = QuantizedLineKey {
                direction_x: direction.0,
                direction_y: direction.1,
                intercept: direction.0 * a.1 as i128 - direction.1 * a.0 as i128,
            };
            let scalar_a = direction.0 * a.0 as i128 + direction.1 * a.1 as i128;
            let scalar_b = direction.0 * b.0 as i128 + direction.1 * b.1 as i128;
            let (start, end, start_point, end_point) = if scalar_a <= scalar_b {
                (scalar_a, scalar_b, a, b)
            } else {
                (scalar_b, scalar_a, b, a)
            };
            if start == end {
                continue;
            }
            let state = lines.entry(line).or_default();
            state
                .intervals
                .push(QuantizedLineInterval { owner, start, end });
            state.endpoints.entry(start).or_insert(start_point);
            state.endpoints.entry(end).or_insert(end_point);
        }
    }

    let mut raw = Vec::new();
    for (_line, mut state) in lines {
        let mut events = Vec::with_capacity(state.intervals.len() * 2);
        for interval in state.intervals.drain(..) {
            events.push((interval.start, interval.owner, 1_i8));
            events.push((interval.end, interval.owner, -1_i8));
        }
        events.sort_unstable_by_key(|event| event.0);
        let mut active = std::collections::BTreeMap::<u32, u32>::new();
        let mut previous = None;
        let mut event_index = 0;
        while event_index < events.len() {
            let position = events[event_index].0;
            if let Some(previous_position) = previous {
                if position > previous_position {
                    let owners = active.keys().copied().collect::<Vec<_>>();
                    if owners.len() > 2 {
                        return Err(format!(
                            "non-manifold shared edge has {} distinct owners",
                            owners.len()
                        ));
                    }
                    if owners.len() == 2 {
                        let start = *state.endpoints.get(&previous_position).ok_or_else(|| {
                            "shared edge interval start lookup failed".to_string()
                        })?;
                        let end = *state
                            .endpoints
                            .get(&position)
                            .ok_or_else(|| "shared edge interval end lookup failed".to_string())?;
                        let (start, end) = canonical_quantized_endpoints(start, end);
                        raw.push(QuantizedSharedEdge {
                            owner_a: owners[0],
                            owner_b: owners[1],
                            start,
                            end,
                        });
                    }
                }
            }
            while event_index < events.len() && events[event_index].0 == position {
                let (_, owner, delta) = events[event_index];
                if delta > 0 {
                    *active.entry(owner).or_default() += 1;
                } else if let Some(count) = active.get_mut(&owner) {
                    *count = count.saturating_sub(1);
                    if *count == 0 {
                        active.remove(&owner);
                    }
                }
                event_index += 1;
            }
            previous = Some(position);
        }
    }

    raw.sort_unstable();
    let mut merged = Vec::new();
    for edge in raw {
        let mut inserted = false;
        for current in merged
            .iter_mut()
            .filter(|current: &&mut QuantizedSharedEdge| {
                current.owner_a == edge.owner_a && current.owner_b == edge.owner_b
            })
        {
            if let Some((start, end)) =
                merge_quantized_collinear(current.start, current.end, edge.start, edge.end)
            {
                current.start = start;
                current.end = end;
                inserted = true;
                break;
            }
        }
        if !inserted {
            merged.push(edge);
        }
    }
    merged.sort_unstable();
    Ok(merged)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
struct QuantizedLineKey {
    direction_x: i128,
    direction_y: i128,
    intercept: i128,
}

#[derive(Debug, Clone, Copy)]
struct QuantizedLineInterval {
    owner: u32,
    start: i128,
    end: i128,
}

#[derive(Debug, Default)]
struct QuantizedLineState {
    intervals: Vec<QuantizedLineInterval>,
    endpoints: std::collections::BTreeMap<i128, (i64, i64)>,
}

fn quantize_geometry_coordinate(value: f32, snap_size: f32) -> Result<i64, String> {
    if !value.is_finite() {
        return Err("shared-edge coordinates must be finite".to_string());
    }
    let quantized = (f64::from(value) / f64::from(snap_size)).round();
    // `i64::MAX as f64` rounds to 2^63, so use the exclusive positive bound
    // explicitly instead of accepting a value that would saturate on cast.
    const I64_LIMIT: f64 = 9_223_372_036_854_775_808.0;
    if !quantized.is_finite() || !(-I64_LIMIT..I64_LIMIT).contains(&quantized) {
        return Err("shared-edge coordinate exceeds quantization range".to_string());
    }
    Ok(quantized as i64)
}

fn gcd_u128(mut a: u128, mut b: u128) -> u128 {
    while b != 0 {
        let remainder = a % b;
        a = b;
        b = remainder;
    }
    a
}

fn merge_quantized_collinear(
    a0: (i64, i64),
    a1: (i64, i64),
    b0: (i64, i64),
    b1: (i64, i64),
) -> Option<((i64, i64), (i64, i64))> {
    let cross = (a1.0 as i128 - a0.0 as i128) * (b0.1 as i128 - a0.1 as i128)
        - (a1.1 as i128 - a0.1 as i128) * (b0.0 as i128 - a0.0 as i128);
    let cross_end = (a1.0 as i128 - a0.0 as i128) * (b1.1 as i128 - a0.1 as i128)
        - (a1.1 as i128 - a0.1 as i128) * (b1.0 as i128 - a0.0 as i128);
    if cross != 0 || cross_end != 0 {
        return None;
    }
    let use_x = (a1.0 - a0.0).unsigned_abs() >= (a1.1 - a0.1).unsigned_abs();
    let coordinate = |point: (i64, i64)| if use_x { point.0 } else { point.1 };
    let a_min = coordinate(a0).min(coordinate(a1));
    let a_max = coordinate(a0).max(coordinate(a1));
    let b_min = coordinate(b0).min(coordinate(b1));
    let b_max = coordinate(b0).max(coordinate(b1));
    if a_max < b_min || b_max < a_min {
        return None;
    }
    let points = [a0, a1, b0, b1];
    let start = *points.iter().min_by_key(|point| coordinate(**point))?;
    let end = *points.iter().max_by_key(|point| coordinate(**point))?;
    Some(canonical_quantized_endpoints(start, end))
}

fn canonical_quantized_endpoints(start: (i64, i64), end: (i64, i64)) -> ((i64, i64), (i64, i64)) {
    if start <= end {
        (start, end)
    } else {
        (end, start)
    }
}

fn proper_segment_intersection(
    a0: (f32, f32),
    a1: (f32, f32),
    b0: (f32, f32),
    b1: (f32, f32),
    epsilon: f32,
) -> bool {
    let o1 = orientation2(a0, a1, b0);
    let o2 = orientation2(a0, a1, b1);
    let o3 = orientation2(b0, b1, a0);
    let o4 = orientation2(b0, b1, a1);
    let eps = epsilon.max(1.0e-6);
    ((o1 > eps && o2 < -eps) || (o1 < -eps && o2 > eps))
        && ((o3 > eps && o4 < -eps) || (o3 < -eps && o4 > eps))
}

fn collinear_segment_overlap(
    a0: (f32, f32),
    a1: (f32, f32),
    b0: (f32, f32),
    b1: (f32, f32),
    epsilon: f32,
) -> bool {
    let eps = epsilon.max(1.0e-6);
    if orientation2(a0, a1, b0).abs() > eps || orientation2(a0, a1, b1).abs() > eps {
        return false;
    }
    let use_x = (a1.0 - a0.0).abs() >= (a1.1 - a0.1).abs();
    let coord = |point: (f32, f32)| if use_x { point.0 } else { point.1 };
    let left = coord(a0).min(coord(a1)).max(coord(b0).min(coord(b1)));
    let right = coord(a0).max(coord(a1)).min(coord(b0).max(coord(b1)));
    right - left > eps
}

fn collinear_boundary_overlap_positive(
    a: &[f32],
    b: &[f32],
    a0: (f32, f32),
    a1: (f32, f32),
    b0: (f32, f32),
    b1: (f32, f32),
    epsilon: f32,
) -> bool {
    if !collinear_segment_overlap(a0, a1, b0, b1, epsilon) {
        return false;
    }
    let use_x = (a1.0 - a0.0).abs() >= (a1.1 - a0.1).abs();
    let coord = |point: (f32, f32)| if use_x { point.0 } else { point.1 };
    let left = coord(a0).min(coord(a1)).max(coord(b0).min(coord(b1)));
    let right = coord(a0).max(coord(a1)).min(coord(b0).max(coord(b1)));
    let t = if (coord(a1) - coord(a0)).abs() > epsilon.max(1.0e-6) {
        ((left + right) * 0.5 - coord(a0)) / (coord(a1) - coord(a0))
    } else {
        0.5
    };
    let mid = (a0.0 + (a1.0 - a0.0) * t, a0.1 + (a1.1 - a0.1) * t);
    let length = ((a1.0 - a0.0).powi(2) + (a1.1 - a0.1).powi(2)).sqrt();
    if length <= epsilon.max(1.0e-6) {
        return false;
    }
    let offset = epsilon.max(1.0e-4) * 4.0;
    let normal = (-(a1.1 - a0.1) / length, (a1.0 - a0.0) / length);
    [1.0, -1.0].iter().any(|sign| {
        let px = mid.0 + normal.0 * offset * sign;
        let py = mid.1 + normal.1 * offset * sign;
        classify_point_in_polygon(a, px, py, epsilon) == PolygonPointLocation::Inside
            && classify_point_in_polygon(b, px, py, epsilon) == PolygonPointLocation::Inside
    })
}

fn orientation2(a: (f32, f32), b: (f32, f32), c: (f32, f32)) -> f32 {
    (b.0 - a.0) * (c.1 - a.1) - (b.1 - a.1) * (c.0 - a.0)
}

/// Return the intersection point of two infinite lines, or `None` when parallel.
#[allow(clippy::too_many_arguments)]
pub fn line_intersect(
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
    x3: f32,
    y3: f32,
    x4: f32,
    y4: f32,
) -> Option<(f32, f32)> {
    let d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if d.abs() < 1e-10 {
        return None;
    }
    let t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / d;
    Some((x1 + t * (x2 - x1), y1 + t * (y2 - y1)))
}

/// Return all integer grid cells on the line from (x1, y1) to (x2, y2) using Bresenham's algorithm.
pub fn bresenham(x1: i32, y1: i32, x2: i32, y2: i32) -> Vec<(i32, i32)> {
    let mut points = Vec::new();
    let mut x = x1;
    let mut y = y1;
    let dx = (x2 - x1).abs();
    let dy = -(y2 - y1).abs();
    let sx = if x1 < x2 { 1 } else { -1 };
    let sy = if y1 < y2 { 1 } else { -1 };
    let mut err = dx + dy;
    loop {
        points.push((x, y));
        if x == x2 && y == y2 {
            break;
        }
        let e2 = 2 * err;
        if e2 >= dy {
            err += dy;
            x += sx;
        }
        if e2 <= dx {
            err += dx;
            y += sy;
        }
    }
    points
}

/// Return the convex hull of a flat vertex array `[x0, y0, ...]` as a flat CCW result using Andrew monotone chain.
pub fn convex_hull(points: &[f32]) -> Vec<f32> {
    let n = points.len() / 2;
    if n < 3 {
        return points.to_vec();
    }
    let mut pts: Vec<(f32, f32)> = (0..n).map(|i| (points[i * 2], points[i * 2 + 1])).collect();
    pts.sort_by(|a, b| {
        a.0.partial_cmp(&b.0)
            .expect("partial_cmp on finite f32")
            .then(a.1.partial_cmp(&b.1).expect("partial_cmp on finite f32"))
    });
    let cross = |o: (f32, f32), a: (f32, f32), b: (f32, f32)| -> f32 {
        (a.0 - o.0) * (b.1 - o.1) - (a.1 - o.1) * (b.0 - o.0)
    };
    let mut lower: Vec<(f32, f32)> = Vec::new();
    for &p in &pts {
        while lower.len() >= 2 && cross(lower[lower.len() - 2], lower[lower.len() - 1], p) <= 0.0 {
            lower.pop();
        }
        lower.push(p);
    }
    let mut upper: Vec<(f32, f32)> = Vec::new();
    for &p in pts.iter().rev() {
        while upper.len() >= 2 && cross(upper[upper.len() - 2], upper[upper.len() - 1], p) <= 0.0 {
            upper.pop();
        }
        upper.push(p);
    }
    lower.pop();
    upper.pop();
    lower.extend(upper);
    let mut result = Vec::with_capacity(lower.len() * 2);
    for (x, y) in lower {
        result.push(x);
        result.push(y);
    }
    result
}

/// Return Delaunay triangulation of `points` as flat `[x0,y0, x1,y1, x2,y2]` triangle arrays using Bowyer-Watson.
pub fn delaunay_triangulate(points: &[(f64, f64)]) -> Vec<[f64; 6]> {
    if points.len() < 3 {
        return Vec::new();
    }
    let mut min_x = f64::MAX;
    let mut min_y = f64::MAX;
    let mut max_x = f64::MIN;
    let mut max_y = f64::MIN;
    for &(x, y) in points {
        if x < min_x {
            min_x = x;
        }
        if y < min_y {
            min_y = y;
        }
        if x > max_x {
            max_x = x;
        }
        if y > max_y {
            max_y = y;
        }
    }
    let dx = max_x - min_x;
    let dy = max_y - min_y;
    let delta = dx.max(dy);
    let mid_x = (min_x + max_x) / 2.0;
    let mid_y = (min_y + max_y) / 2.0;
    let st0 = (mid_x - 20.0 * delta, mid_y - delta);
    let st1 = (mid_x, mid_y + 20.0 * delta);
    let st2 = (mid_x + 20.0 * delta, mid_y - delta);
    let mut all_points: Vec<(f64, f64)> = vec![st0, st1, st2];
    all_points.extend_from_slice(points);
    let mut triangles: Vec<[usize; 3]> = vec![[0, 1, 2]];
    for pi in 3..all_points.len() {
        let p = all_points[pi];
        let mut bad_triangles = Vec::new();
        for (ti, tri) in triangles.iter().enumerate() {
            if in_circumcircle(
                p,
                all_points[tri[0]],
                all_points[tri[1]],
                all_points[tri[2]],
            ) {
                bad_triangles.push(ti);
            }
        }
        let mut polygon: Vec<[usize; 2]> = Vec::new();
        for &bi in &bad_triangles {
            let tri = triangles[bi];
            let edges = [[tri[0], tri[1]], [tri[1], tri[2]], [tri[2], tri[0]]];
            for edge in &edges {
                let shared = bad_triangles.iter().any(|&oi| {
                    if oi == bi {
                        return false;
                    }
                    let ot = triangles[oi];
                    let oe = [[ot[0], ot[1]], [ot[1], ot[2]], [ot[2], ot[0]]];
                    oe.iter().any(|e| {
                        (e[0] == edge[0] && e[1] == edge[1]) || (e[0] == edge[1] && e[1] == edge[0])
                    })
                });
                if !shared {
                    polygon.push(*edge);
                }
            }
        }
        bad_triangles.sort_unstable();
        for &bi in bad_triangles.iter().rev() {
            triangles.swap_remove(bi);
        }
        for edge in &polygon {
            triangles.push([edge[0], edge[1], pi]);
        }
    }
    triangles.retain(|tri| tri[0] >= 3 && tri[1] >= 3 && tri[2] >= 3);
    triangles
        .iter()
        .map(|tri| {
            let (x0, y0) = all_points[tri[0]];
            let (x1, y1) = all_points[tri[1]];
            let (x2, y2) = all_points[tri[2]];
            [x0, y0, x1, y1, x2, y2]
        })
        .collect()
}

/// Return true when point `p` lies inside the circumcircle of triangle (a, b, c).
fn in_circumcircle(p: (f64, f64), a: (f64, f64), b: (f64, f64), c: (f64, f64)) -> bool {
    let ax = a.0 - p.0;
    let ay = a.1 - p.1;
    let bx = b.0 - p.0;
    let by = b.1 - p.1;
    let cx = c.0 - p.0;
    let cy = c.1 - p.1;
    let det = ax * (by * (cx * cx + cy * cy) - cy * (bx * bx + by * by))
        - ay * (bx * (cx * cx + cy * cy) - cx * (bx * bx + by * by))
        + (ax * ax + ay * ay) * (bx * cy - by * cx);
    det > 0.0
}
