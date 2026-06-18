//! This file owns spawn-offset sampling for particle emission areas and explicit emission shapes like circles and stars.
//! `emission_offset` handles area distributions and area rotation, while `emission_shape_offset` handles shape geometry.
//! Uniform, normal, ellipse, border, cone, spiral, and star sampling live here so emitters reuse one spawn policy.
//! No particle pool state is stored here; the file is pure geometry and RNG mapping used during emitter spawn steps.
//! Open it when spawn distributions change; emitter integration and config ownership live in sibling particle files.

use super::config::{AreaDistribution, EmissionShape, ParticleConfig};
use super::math::{rand_f32, rand_normal, rand_range, rand_u32};
/// Return a random spawn offset `(dx, dy)` sampled from the `ParticleConfig` area distribution and rotated by `area_angle`.
pub fn emission_offset(config: &ParticleConfig, rng_state: &mut u64) -> (f32, f32) {
    let (dx, dy) = match config.area_distribution {
        AreaDistribution::None => (0.0, 0.0),
        AreaDistribution::Uniform => {
            let x = rand_range(rng_state, -config.area_width * 0.5, config.area_width * 0.5);
            let y = rand_range(
                rng_state,
                -config.area_height * 0.5,
                config.area_height * 0.5,
            );
            (x, y)
        }
        AreaDistribution::Normal => {
            let x = (rand_normal(rng_state) * 0.25).clamp(-0.5, 0.5) * config.area_width;
            let y = (rand_normal(rng_state) * 0.25).clamp(-0.5, 0.5) * config.area_height;
            (x, y)
        }
        AreaDistribution::Ellipse => {
            let angle = rand_f32(rng_state) * 2.0 * std::f32::consts::PI;
            let r = rand_f32(rng_state).sqrt();
            let x = angle.cos() * r * config.area_width * 0.5;
            let y = angle.sin() * r * config.area_height * 0.5;
            (x, y)
        }
        AreaDistribution::BorderEllipse => {
            let angle = rand_f32(rng_state) * 2.0 * std::f32::consts::PI;
            let x = angle.cos() * config.area_width * 0.5;
            let y = angle.sin() * config.area_height * 0.5;
            (x, y)
        }
        AreaDistribution::BorderRectangle => {
            let perimeter = 2.0 * config.area_width + 2.0 * config.area_height;
            if perimeter < f32::EPSILON {
                return (0.0, 0.0);
            }
            let t = rand_f32(rng_state) * perimeter;
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
    if config.area_angle.abs() > f32::EPSILON {
        let cos_a = config.area_angle.cos();
        let sin_a = config.area_angle.sin();
        (dx * cos_a - dy * sin_a, dx * sin_a + dy * cos_a)
    } else {
        (dx, dy)
    }
}
/// Return a random spawn offset `(dx, dy)` sampled from an `EmissionShape`; `Custom` always returns `(0, 0)`.
pub fn emission_shape_offset(shape: &EmissionShape, rng_state: &mut u64) -> (f32, f32) {
    match shape {
        EmissionShape::Point => (0.0, 0.0),
        EmissionShape::Circle { radius, fill } => {
            let angle = rand_f32(rng_state) * 2.0 * std::f32::consts::PI;
            let r = if *fill {
                rand_f32(rng_state).sqrt() * radius
            } else {
                *radius
            };
            (angle.cos() * r, angle.sin() * r)
        }
        EmissionShape::Rectangle { width, height } => {
            let x = rand_range(rng_state, -width * 0.5, *width * 0.5);
            let y = rand_range(rng_state, -height * 0.5, *height * 0.5);
            (x, y)
        }
        EmissionShape::Ring {
            inner_radius,
            outer_radius,
        } => {
            let angle = rand_f32(rng_state) * 2.0 * std::f32::consts::PI;
            let r_sq = rand_range(
                rng_state,
                inner_radius * inner_radius,
                outer_radius * outer_radius,
            );
            let r = r_sq.sqrt();
            (angle.cos() * r, angle.sin() * r)
        }
        EmissionShape::Line { length, angle } => {
            let t = rand_range(rng_state, -0.5, 0.5);
            (t * length * angle.cos(), t * length * angle.sin())
        }
        EmissionShape::Cone {
            radius,
            angle,
            spread,
        } => {
            let a = angle + rand_range(rng_state, -*spread, *spread);
            let r = rand_f32(rng_state).sqrt() * radius;
            (a.cos() * r, a.sin() * r)
        }
        EmissionShape::Star {
            points,
            outer_radius,
            inner_radius,
        } => {
            let n = (*points).max(3) as f32;
            let step = std::f32::consts::PI / n;
            let segment = rand_u32(rng_state, 0, *points * 2);
            let t = rand_f32(rng_state);
            let a0 = segment as f32 * step;
            let a1 = a0 + step;
            let even_segment = segment.is_multiple_of(2);
            let r0 = if even_segment {
                *outer_radius
            } else {
                *inner_radius
            };
            let r1 = if even_segment {
                *inner_radius
            } else {
                *outer_radius
            };
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
            let max_angle = *revolutions * 2.0 * std::f32::consts::PI;
            let t = rand_f32(rng_state);
            let angle = t * max_angle;
            let r = t * radius;
            (angle.cos() * r, angle.sin() * r)
        }
        EmissionShape::Custom { .. } => (0.0, 0.0),
    }
}
