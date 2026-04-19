//! Particle spawn offset calculations for area distribution and emission shapes.

use super::config::{AreaDistribution, EmissionShape, ParticleConfig};
use super::math::{rand_normal, rand_range};

/// Compute an emission offset `(dx, dy)` based on the config's area distribution.
///
/// # Parameters
/// - `config` — `&ParticleConfig`.
///
/// # Returns
/// `(f32, f32)`.
pub(crate) fn emission_offset(config: &ParticleConfig) -> (f32, f32) {
    let (dx, dy) = match config.area_distribution {
        AreaDistribution::None => (0.0, 0.0),
        AreaDistribution::Uniform => {
            let x = rand_range(-config.area_width * 0.5, config.area_width * 0.5);
            let y = rand_range(-config.area_height * 0.5, config.area_height * 0.5);
            (x, y)
        }
        AreaDistribution::Normal => {
            let x = (rand_normal() * 0.25).clamp(-0.5, 0.5) * config.area_width;
            let y = (rand_normal() * 0.25).clamp(-0.5, 0.5) * config.area_height;
            (x, y)
        }
        AreaDistribution::Ellipse => {
            let angle = fastrand::f32() * 2.0 * std::f32::consts::PI;
            let r = fastrand::f32().sqrt();
            let x = angle.cos() * r * config.area_width * 0.5;
            let y = angle.sin() * r * config.area_height * 0.5;
            (x, y)
        }
        AreaDistribution::BorderEllipse => {
            let angle = fastrand::f32() * 2.0 * std::f32::consts::PI;
            let x = angle.cos() * config.area_width * 0.5;
            let y = angle.sin() * config.area_height * 0.5;
            (x, y)
        }
        AreaDistribution::BorderRectangle => {
            let perimeter = 2.0 * config.area_width + 2.0 * config.area_height;
            if perimeter < f32::EPSILON {
                return (0.0, 0.0);
            }
            let t = fastrand::f32() * perimeter;
            let hw = config.area_width * 0.5;
            let hh = config.area_height * 0.5;
            if t < config.area_width {
                (t - hw, -hh)
            } else if t < config.area_width + config.area_height {
                (hw, t - config.area_width - hh)
            } else if t < 2.0 * config.area_width + config.area_height {
                (hw - (t - config.area_width - config.area_height), hh)
            } else {
                (-hw, hh - (t - 2.0 * config.area_width - config.area_height))
            }
        }
    };

    // Rotate by area angle
    if config.area_angle.abs() > f32::EPSILON {
        let cos_a = config.area_angle.cos();
        let sin_a = config.area_angle.sin();
        (dx * cos_a - dy * sin_a, dx * sin_a + dy * cos_a)
    } else {
        (dx, dy)
    }
}

/// Compute an emission offset `(dx, dy)` based on the emission shape.
///
/// # Parameters
/// - `shape` — `&EmissionShape`.
///
/// # Returns
/// `(f32, f32)`.
pub(crate) fn emission_shape_offset(shape: &EmissionShape) -> (f32, f32) {
    match shape {
        EmissionShape::Point => (0.0, 0.0),
        EmissionShape::Circle { radius, fill } => {
            let angle = fastrand::f32() * 2.0 * std::f32::consts::PI;
            let r = if *fill {
                fastrand::f32().sqrt() * radius
            } else {
                *radius
            };
            (angle.cos() * r, angle.sin() * r)
        }
        EmissionShape::Rectangle { width, height } => {
            let x = rand_range(-width * 0.5, *width * 0.5);
            let y = rand_range(-height * 0.5, *height * 0.5);
            (x, y)
        }
        EmissionShape::Ring {
            inner_radius,
            outer_radius,
        } => {
            let angle = fastrand::f32() * 2.0 * std::f32::consts::PI;
            // Uniform distribution within ring by sampling radius²
            let r_sq = rand_range(inner_radius * inner_radius, outer_radius * outer_radius);
            let r = r_sq.sqrt();
            (angle.cos() * r, angle.sin() * r)
        }
        EmissionShape::Line { length, angle } => {
            let t = rand_range(-0.5, 0.5);
            (t * length * angle.cos(), t * length * angle.sin())
        }
        EmissionShape::Cone {
            radius,
            angle,
            spread,
        } => {
            let a = angle + rand_range(-spread, *spread);
            let r = fastrand::f32().sqrt() * radius;
            (a.cos() * r, a.sin() * r)
        }
        EmissionShape::Star {
            points,
            outer_radius,
            inner_radius,
        } => {
            // Pick a random point on the star border by choosing a random angular segment
            let n = (*points).max(3) as f32;
            let step = std::f32::consts::PI / n; // angle per half-segment
            let segment = fastrand::u32(0..*points * 2); // each point has 2 half-edges
            let t = fastrand::f32(); // interpolate along the half-edge
            let a0 = segment as f32 * step;
            let a1 = a0 + step;
            let r0 = if segment % 2 == 0 {
                *outer_radius
            } else {
                *inner_radius
            };
            let r1 = if segment % 2 == 0 {
                *inner_radius
            } else {
                *outer_radius
            };
            // Lerp in Cartesian space along the star edge
            let x0 = a0.cos() * r0;
            let y0 = a0.sin() * r0;
            let x1 = a1.cos() * r1;
            let y1 = a1.sin() * r1;
            (x0 + (x1 - x0) * t, y0 + (y1 - y0) * t)
        }
        EmissionShape::Spiral {
            revolutions,
            radius,
        } => {
            // Archimedean spiral: r grows linearly with angle
            let max_angle = *revolutions * 2.0 * std::f32::consts::PI;
            let t = fastrand::f32();
            let angle = t * max_angle;
            let r = t * radius;
            (angle.cos() * r, angle.sin() * r)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn emission_offset_none_is_zero() {
        let cfg = ParticleConfig {
            area_distribution: AreaDistribution::None,
            ..ParticleConfig::default()
        };
        let (dx, dy) = emission_offset(&cfg);
        assert!((dx).abs() < f32::EPSILON);
        assert!((dy).abs() < f32::EPSILON);
    }

    #[test]
    fn emission_offset_uniform_within_bounds() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::Uniform;
        cfg.area_width = 100.0;
        cfg.area_height = 50.0;
        for _ in 0..100 {
            let (dx, dy) = emission_offset(&cfg);
            assert!(dx.abs() <= 50.0 + 1e-3);
            assert!(dy.abs() <= 25.0 + 1e-3);
        }
    }

    #[test]
    fn emission_offset_ellipse_within_radius() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::Ellipse;
        cfg.area_width = 20.0;
        cfg.area_height = 20.0;
        for _ in 0..100 {
            let (dx, dy) = emission_offset(&cfg);
            let dist = (dx * dx + dy * dy).sqrt();
            assert!(dist <= 10.0 + 1e-3);
        }
    }

    #[test]
    fn emission_offset_area_angle_rotates() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::Uniform;
        cfg.area_width = 100.0;
        cfg.area_height = 0.0; // zero height — points lie on X axis
        cfg.area_angle = std::f32::consts::FRAC_PI_2; // rotate 90°
        let (dx, dy) = emission_offset(&cfg);
        // After 90° rotation, X component maps to Y
        assert!(dx.abs() < 1e-3 || dy.abs() > 0.0);
    }

    #[test]
    fn emission_shape_point_is_zero() {
        let (x, y) = emission_shape_offset(&EmissionShape::Point);
        assert!((x).abs() < f32::EPSILON);
        assert!((y).abs() < f32::EPSILON);
    }

    #[test]
    fn emission_shape_circle_edge_only() {
        let shape = EmissionShape::Circle { radius: 10.0, fill: false };
        for _ in 0..50 {
            let (x, y) = emission_shape_offset(&shape);
            let dist = (x * x + y * y).sqrt();
            assert!((dist - 10.0).abs() < 1e-3, "edge-only circle should be at radius");
        }
    }

    #[test]
    fn emission_shape_star_stays_bounded() {
        let shape = EmissionShape::Star { points: 5, outer_radius: 20.0, inner_radius: 10.0 };
        for _ in 0..100 {
            let (x, y) = emission_shape_offset(&shape);
            let dist = (x * x + y * y).sqrt();
            assert!(dist <= 20.0 + 1e-3);
        }
    }

    #[test]
    fn emission_shape_spiral_stays_bounded() {
        let shape = EmissionShape::Spiral { revolutions: 3.0, radius: 50.0 };
        for _ in 0..100 {
            let (x, y) = emission_shape_offset(&shape);
            let dist = (x * x + y * y).sqrt();
            assert!(dist <= 50.0 + 1e-3);
        }
    }

    #[test]
    fn border_rectangle_zero_perimeter_returns_zero() {
        let mut cfg = ParticleConfig::default();
        cfg.area_distribution = AreaDistribution::BorderRectangle;
        cfg.area_width = 0.0;
        cfg.area_height = 0.0;
        let (dx, dy) = emission_offset(&cfg);
        assert!((dx).abs() < f32::EPSILON);
        assert!((dy).abs() < f32::EPSILON);
    }
}

