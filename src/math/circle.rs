//! Circle value type for 2D collision geometry and containment queries.
//!
//! [`Circle`] stores a centre point and radius. It provides area, perimeter,
//! containment, and intersection tests. Used for circular hitboxes, sensor
//! areas, and as input to `AabbTree::query_circle`.
use super::vec2::Vec2;

/// A circle defined by its centre and radius.
///
/// # Fields
/// - `x` — X coordinate of the centre.
/// - `y` — Y coordinate of the centre.
/// - `radius` — Radius (should be non-negative).
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Circle {
    /// X coordinate of the centre.
    pub x: f32,
    /// Y coordinate of the centre.
    pub y: f32,
    /// Radius of the circle (should be ≥ 0).
    pub radius: f32,
}

impl Circle {
    /// Creates a new `Circle` centred at `(x, y)` with the given `radius`.
    ///
    /// # Parameters
    /// - `x` — Centre X.
    /// - `y` — Centre Y.
    /// - `radius` — Radius (clamped to 0 if negative).
    ///
    /// # Returns
    /// A new `Circle`.
    pub fn new(x: f32, y: f32, radius: f32) -> Self {
        Circle {
            x,
            y,
            radius: radius.max(0.0),
        }
    }

    /// Returns the centre as a `Vec2`.
    ///
    /// # Returns
    /// `Vec2`.
    pub fn center(&self) -> Vec2 {
        Vec2::new(self.x, self.y)
    }

    /// Returns the area of the circle (`π r²`).
    ///
    /// # Returns
    /// `f32`.
    pub fn area(&self) -> f32 {
        std::f32::consts::PI * self.radius * self.radius
    }

    /// Returns the perimeter (circumference) of the circle (`2 π r`).
    ///
    /// # Returns
    /// `f32`.
    pub fn perimeter(&self) -> f32 {
        2.0 * std::f32::consts::PI * self.radius
    }

    /// Returns `true` if the point `(px, py)` lies inside or on the boundary
    /// of this circle.
    ///
    /// # Parameters
    /// - `px` — X coordinate of the point.
    /// - `py` — Y coordinate of the point.
    ///
    /// # Returns
    /// `bool`.
    pub fn contains(&self, px: f32, py: f32) -> bool {
        let dx = px - self.x;
        let dy = py - self.y;
        dx * dx + dy * dy <= self.radius * self.radius
    }

    /// Returns `true` if this circle overlaps with `other`.
    ///
    /// Two circles intersect when the distance between their centres is less
    /// than the sum of their radii.
    ///
    /// # Parameters
    /// - `other` — The other `Circle` to test against.
    ///
    /// # Returns
    /// `bool`.
    pub fn intersects(&self, other: &Circle) -> bool {
        let dx = other.x - self.x;
        let dy = other.y - self.y;
        let sum_r = self.radius + other.radius;
        dx * dx + dy * dy < sum_r * sum_r
    }

    /// Returns the axis-aligned bounding box of this circle as
    /// `(min_x, min_y, max_x, max_y)`.
    ///
    /// Useful when inserting into an `AabbTree`.
    ///
    /// # Returns
    /// `(f32, f32, f32, f32)`.
    pub fn aabb(&self) -> (f32, f32, f32, f32) {
        (
            self.x - self.radius,
            self.y - self.radius,
            self.x + self.radius,
            self.y + self.radius,
        )
    }
}
