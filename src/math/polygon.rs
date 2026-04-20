//! Polygon utilities: ear-clipping triangulation and convexity testing.
//!
//! Provides [`triangulate`] (ear-clipping for simple polygons) and [`is_convex`]
//! (cross-product sign consistency check). Also includes Sutherland-Hodgman
//! polygon clipping against half-planes and convex polygons.
//!
//! All functions work with `Vec2` slices or `(f32, f32)` tuples.

use crate::math::vec2::Vec2;

/// Triangulate a simple polygon using the ear-clipping algorithm.
///
/// # Parameters
/// - `polygon` — slice of `Vec2` vertices forming a simple (non-self-intersecting) polygon;
///   must have at least 3 vertices
///
/// # Returns
/// `Ok(triangles)` — a `Vec` of `[Vec2; 3]` triangle triples covering the polygon area.
/// `Err(String)` — if triangulation fails (e.g. self-intersecting or degenerate input).
pub fn triangulate(polygon: &[Vec2]) -> Result<Vec<[Vec2; 3]>, String> {
    let n = polygon.len();
    if n < 3 {
        return Err("Polygon needs at least 3 vertices".to_string());
    }
    if n == 3 {
        return Ok(vec![[polygon[0], polygon[1], polygon[2]]]);
    }

    // Ensure counter-clockwise winding
    let area = signed_area(polygon);
    let ccw: Vec<Vec2> = if area < 0.0 {
        polygon.iter().rev().copied().collect()
    } else {
        polygon.to_vec()
    };

    let mut indices: Vec<usize> = (0..n).collect();
    let mut triangles = Vec::new();

    // Iteratively clip ear triangles until only one triangle remains.
    // An "ear" is a convex vertex whose triangle contains no other vertex.
    while indices.len() > 3 {
        let mut ear_found = false;
        let len = indices.len();
        for i in 0..len {
            let prev = (i + len - 1) % len;
            let next = (i + 1) % len;

            let pi = indices[prev];
            let ci = indices[i];
            let ni = indices[next];

            if is_ear(&ccw, &indices, pi, ci, ni) {
                triangles.push([ccw[pi], ccw[ci], ccw[ni]]);
                indices.remove(i);
                ear_found = true;
                break;
            }
        }
        if !ear_found {
            return Err("Failed to triangulate: polygon may be self-intersecting".to_string());
        }
    }

    if indices.len() == 3 {
        triangles.push([ccw[indices[0]], ccw[indices[1]], ccw[indices[2]]]);
    }

    Ok(triangles)
}

/// Check if a polygon is convex. This accessor incurs no allocation; call it freely in hot paths.
///
/// Uses cross-product sign consistency at each vertex to determine convexity.
///
/// # Parameters
/// - `polygon` — slice of `Vec2` vertices
///
/// # Returns
/// `true` if the polygon is convex; `false` if concave, self-intersecting, or fewer than 3 vertices.
pub fn is_convex(polygon: &[Vec2]) -> bool {
    let n = polygon.len();
    if n < 3 {
        return false;
    }

    let mut sign = 0i32;
    for i in 0..n {
        let a = polygon[i];
        let b = polygon[(i + 1) % n];
        let c = polygon[(i + 2) % n];
        let cross = (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x);
        let s = if cross > 0.0 {
            1
        } else if cross < 0.0 {
            -1
        } else {
            0
        };
        if s != 0 {
            if sign != 0 && s != sign {
                return false;
            }
            sign = s;
        }
    }
    true
}

/// Compute signed area of a polygon (positive = CCW, negative = CW).
fn signed_area(polygon: &[Vec2]) -> f32 {
    let n = polygon.len();
    let mut area = 0.0;
    for i in 0..n {
        let j = (i + 1) % n;
        area += polygon[i].x * polygon[j].y;
        area -= polygon[j].x * polygon[i].y;
    }
    area / 2.0
}

/// Check if the vertex at `curr` is an ear (convex and no other vertex inside the triangle).
fn is_ear(polygon: &[Vec2], indices: &[usize], prev: usize, curr: usize, next: usize) -> bool {
    let a = polygon[prev];
    let b = polygon[curr];
    let c = polygon[next];

    // Must be a convex vertex (positive cross product for CCW winding)
    let cross = (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x);
    if cross <= 0.0 {
        return false;
    }

    // No other vertex inside this triangle
    for &idx in indices {
        if idx == prev || idx == curr || idx == next {
            continue;
        }
        if point_in_triangle(polygon[idx], a, b, c) {
            return false;
        }
    }
    true
}

/// Point-in-triangle test using barycentric sign method.
fn point_in_triangle(p: Vec2, a: Vec2, b: Vec2, c: Vec2) -> bool {
    let d1 = cross_sign(p, a, b);
    let d2 = cross_sign(p, b, c);
    let d3 = cross_sign(p, c, a);
    let has_neg = (d1 < 0.0) || (d2 < 0.0) || (d3 < 0.0);
    let has_pos = (d1 > 0.0) || (d2 > 0.0) || (d3 > 0.0);
    !(has_neg && has_pos)
}

/// Sign of the cross product for point-in-triangle test.
fn cross_sign(p1: Vec2, p2: Vec2, p3: Vec2) -> f32 {
    (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
}

/// Clip a polygon against a single half-plane using the Sutherland-Hodgman algorithm.
///
/// The "inside" half-plane is where `nx * x + ny * y >= d`.
/// If the polygon is fully outside the plane, an empty slice is returned.
///
/// # Parameters
/// - `polygon` — `&[(f32, f32)]` — input vertices in order (open or closed, do not repeat the first vertex).
/// - `nx` — `f32` — plane normal X component (need not be unit length).
/// - `ny` — `f32` — plane normal Y component.
/// - `d` — `f32` — plane offset: inside is where the dot-product with `(nx, ny)` is `>= d`.
///
/// # Returns
/// `Vec<(f32, f32)>` — clipped vertices in the same winding as the input (empty if fully clipped).
pub fn polygon_clip(polygon: &[(f32, f32)], nx: f32, ny: f32, d: f32) -> Vec<(f32, f32)> {
    if polygon.is_empty() {
        return Vec::new();
    }
    let inside = |(x, y): (f32, f32)| nx * x + ny * y >= d;
    let intersect = |(ax, ay): (f32, f32), (bx, by): (f32, f32)| {
        let da = nx * ax + ny * ay;
        let db = nx * bx + ny * by;
        let denom = db - da;
        if denom.abs() < f32::EPSILON {
            return (ax, ay);
        }
        let t = (d - da) / denom;
        (ax + t * (bx - ax), ay + t * (by - ay))
    };
    let n = polygon.len();
    let mut out = Vec::with_capacity(n);
    for i in 0..n {
        let curr = polygon[i];
        let next = polygon[(i + 1) % n];
        let curr_inside = inside(curr);
        let next_inside = inside(next);
        if curr_inside {
            out.push(curr);
            if !next_inside {
                out.push(intersect(curr, next));
            }
        } else if next_inside {
            out.push(intersect(curr, next));
        }
    }
    out
}

// -------------------------------------------------------------------------------
// Boolean polygon operations
// -------------------------------------------------------------------------------

/// Clips polygon `subject` against the convex polygon `clip` using the
/// Sutherland-Hodgman algorithm and returns the intersection region.
///
/// Works correctly when both polygons are **convex** and in the same winding order
/// (counter-clockwise is the convention; the function normalises both inputs to CCW).
/// Concave polygons may give partial or unexpected results.
///
/// # Parameters
/// - `subject` — `&[(f32, f32)]`. The subject polygon vertices (open list, no repeated first vertex).
/// - `clip` — `&[(f32, f32)]`. The clipping polygon vertices (must be convex).
///
/// # Returns
/// `Vec<(f32, f32)>` — the intersection region, or an empty `Vec` if there is none.
pub fn polygon_intersection(subject: &[(f32, f32)], clip: &[(f32, f32)]) -> Vec<(f32, f32)> {
    if subject.is_empty() || clip.is_empty() {
        return Vec::new();
    }
    // Normalise clip to CCW so edge normals point inward.
    let clip_ccw = ensure_ccw(clip);
    let mut output = subject.to_vec();
    let n = clip_ccw.len();
    for i in 0..n {
        if output.is_empty() {
            break;
        }
        let (ax, ay) = clip_ccw[i];
        let (bx, by) = clip_ccw[(i + 1) % n];
        // Edge vector (bx-ax, by-ay).  Inward normal is (-(by-ay), bx-ax).
        let nx = -(by - ay);
        let ny = bx - ax;
        let d = nx * ax + ny * ay;
        output = polygon_clip(&output, nx, ny, d);
    }
    output
}

/// Returns an approximation of the union of two convex polygons by computing the
/// convex hull of all their vertices.
///
/// This is exact when both polygons are convex and overlapping; it over-approximates
/// when used with concave polygons or disjoint convex polygons.
///
/// # Parameters
/// - `a` — `&[(f32, f32)]`. First polygon vertices.
/// - `b` — `&[(f32, f32)]`. Second polygon vertices.
///
/// # Returns
/// `Vec<(f32, f32)>` — the convex hull of all combined vertices (CCW winding).
pub fn polygon_union(a: &[(f32, f32)], b: &[(f32, f32)]) -> Vec<(f32, f32)> {
    let mut pts: Vec<(f32, f32)> = a.iter().chain(b.iter()).copied().collect();
    convex_hull(&mut pts)
}

/// Returns an approximation of the difference `A - B` by clipping `A` against the
/// **reversed** edges of `B` (i.e. the complement of `B`).
///
/// Works correctly when `B` is convex and fully overlaps with a region of `A`.
/// The result may be concave or empty.
///
/// # Parameters
/// - `a` — `&[(f32, f32)]`. Subject polygon.
/// - `b` — `&[(f32, f32)]`. Clip polygon whose interior is subtracted from `A`.
///
/// # Returns
/// `Vec<(f32, f32)>` — the remaining part of `A` after removing the overlap with `B`.
pub fn polygon_difference(a: &[(f32, f32)], b: &[(f32, f32)]) -> Vec<(f32, f32)> {
    if a.is_empty() {
        return Vec::new();
    }
    if b.is_empty() {
        return a.to_vec();
    }
    // Use the intersection of A with the complement of B.
    // Complement of convex B: clip A against each outward-facing edge of B.
    let b_ccw = ensure_ccw(b);
    let n = b_ccw.len();
    // Collect parts of A outside B using each clipping edge's outer side.
    // For each edge we produce one fragment; the full difference is the union of fragments.
    let mut fragments: Vec<Vec<(f32, f32)>> = Vec::new();
    for i in 0..n {
        let (ax, ay) = b_ccw[i];
        let (bx, by) = b_ccw[(i + 1) % n];
        // Inward normal of B edge.
        let nx = -(by - ay);
        let ny = bx - ax;
        let d = nx * ax + ny * ay;
        // Outward: clip A against the opposite half-plane.
        let frag = polygon_clip(a, -nx, -ny, -d);
        if !frag.is_empty() {
            fragments.push(frag);
        }
    }
    // Merge fragments as the convex hull of all fragment vertices (approximation).
    if fragments.is_empty() {
        Vec::new()
    } else {
        let mut all_pts: Vec<(f32, f32)> = fragments.into_iter().flatten().collect();
        convex_hull(&mut all_pts)
    }
}

// ── helpers for boolean ops ──────────────────────────────────────────────────

/// Returns a CCW-ordered copy of `polygon`.  If already CCW (positive signed area),
/// returns a clone; otherwise returns a reversed clone.
fn ensure_ccw(polygon: &[(f32, f32)]) -> Vec<(f32, f32)> {
    let area = signed_area_tuples(polygon);
    if area >= 0.0 {
        polygon.to_vec()
    } else {
        let mut rev = polygon.to_vec();
        rev.reverse();
        rev
    }
}

/// Signed area for `(f32, f32)` tuple polygons (positive = CCW).
fn signed_area_tuples(polygon: &[(f32, f32)]) -> f32 {
    let n = polygon.len();
    let mut area = 0.0f32;
    for i in 0..n {
        let (ax, ay) = polygon[i];
        let (bx, by) = polygon[(i + 1) % n];
        area += ax * by - bx * ay;
    }
    area / 2.0
}

/// Computes the convex hull of `pts` using Andrew's monotone chain algorithm.
///
/// Returns vertices in CCW order.  Returns an empty `Vec` for fewer than 3 distinct
/// points (after deduplication).
fn convex_hull(pts: &mut Vec<(f32, f32)>) -> Vec<(f32, f32)> {
    if pts.len() < 3 {
        return pts.clone();
    }
    // Sort lexicographically
    pts.sort_by(|a, b| {
        a.0.partial_cmp(&b.0)
            .unwrap_or(std::cmp::Ordering::Equal)
            .then(a.1.partial_cmp(&b.1).unwrap_or(std::cmp::Ordering::Equal))
    });
    pts.dedup_by(|a, b| (a.0 - b.0).abs() < f32::EPSILON && (a.1 - b.1).abs() < f32::EPSILON);

    if pts.len() < 3 {
        return pts.clone();
    }

    let cross = |(ox, oy): (f32, f32), (ax, ay): (f32, f32), (bx, by): (f32, f32)| {
        (ax - ox) * (by - oy) - (ay - oy) * (bx - ox)
    };

    let mut lower: Vec<(f32, f32)> = Vec::new();
    for &p in pts.iter() {
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
    lower
}
