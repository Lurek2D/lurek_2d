//! Bounded, deterministic kinematic-circle movement built on the authoritative physics world.
//! The solver owns sweep, wall-slide, optional altitude filtering, and conservative penetration recovery.
//! It does not own actor state, input, levels, stairs, or gameplay callbacks.

use super::{BodyId, BodyType, PhysicsError, PhysicsQueryFilter, World};

const EPSILON: f32 = 1.0e-5;
/// Hard ceiling for public controller slide and recovery iterations.
pub const MAX_KINEMATIC_SLIDES: usize = 16;

/// Persistent, gameplay-neutral settings for a kinematic circle controller.
#[derive(Debug, Clone, Copy)]
pub struct KinematicControllerSettings {
    pub radius: f32,
    pub skin: f32,
    pub max_slides: usize,
    pub filter: PhysicsQueryFilter,
    pub vertical_span: Option<(f32, f32)>,
}

/// One reported sensor or blocking contact.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct KinematicHit {
    pub body_id: BodyId,
    pub fixture_index: usize,
    pub point: (f32, f32),
    pub normal: (f32, f32),
    pub toi: f32,
    pub sensor: bool,
}

/// Deterministic result of movement or recovery.
#[derive(Debug, Clone, PartialEq)]
pub struct KinematicMoveResult {
    pub requested: (f32, f32),
    pub applied: (f32, f32),
    pub remaining: (f32, f32),
    pub collided: bool,
    pub hits: Vec<KinematicHit>,
}

impl KinematicMoveResult {
    fn stationary(requested: (f32, f32)) -> Self {
        Self {
            requested,
            applied: (0.0, 0.0),
            remaining: requested,
            collided: false,
            hits: Vec::new(),
        }
    }
}

fn validate_settings(settings: &KinematicControllerSettings) -> Result<(), PhysicsError> {
    if !settings.radius.is_finite() || settings.radius <= 0.0 {
        return Err(PhysicsError::NonPositiveValue {
            field: "radius",
            value: f64::from(settings.radius),
        });
    }
    if !settings.skin.is_finite() || settings.skin < 0.0 {
        return Err(PhysicsError::ValueOutOfRange {
            field: "skin",
            min: 0.0,
            max: f64::MAX,
            value: f64::from(settings.skin),
        });
    }
    if settings.max_slides == 0 || settings.max_slides > MAX_KINEMATIC_SLIDES {
        return Err(PhysicsError::CountLimitExceeded {
            context: "kinematic max slides",
            count: settings.max_slides,
            max: MAX_KINEMATIC_SLIDES,
        });
    }
    if let Some((z_min, z_max)) = settings.vertical_span {
        if !z_min.is_finite() || !z_max.is_finite() || z_max <= z_min {
            return Err(PhysicsError::ConfigMismatch {
                context: "kinematic vertical span",
                detail: "zMin and zMax must be finite with zMax > zMin".to_string(),
            });
        }
    }
    Ok(())
}

fn validate_body(world: &World, body_id: usize) -> Result<(f32, f32), PhysicsError> {
    let body = world
        .get_body(body_id)
        .ok_or(PhysicsError::InvalidBodyReference { body_id })?;
    if body.body_type != BodyType::Kinematic {
        return Err(PhysicsError::ConfigMismatch {
            context: "kinematic controller",
            detail: format!("body {body_id} must have type kinematic"),
        });
    }
    Ok((body.position.x, body.position.y))
}

fn cast_blocker(
    world: &World,
    position: (f32, f32),
    displacement: (f32, f32),
    settings: &KinematicControllerSettings,
) -> Result<Option<KinematicHit>, PhysicsError> {
    let distance = displacement.0.hypot(displacement.1);
    if distance <= EPSILON {
        return Ok(None);
    }
    let mut filter = settings.filter;
    filter.include_sensors = false;
    let hit = if let Some((z_min, z_max)) = settings.vertical_span {
        world
            .try_cast_circle_vertical_span(
                position.0,
                position.1,
                settings.radius,
                displacement.0,
                displacement.1,
                z_min,
                z_max,
                filter,
            )?
            .map(|hit| KinematicHit {
                body_id: hit.body_id,
                fixture_index: 0,
                point: hit.point,
                normal: hit.normal,
                toi: hit.toi,
                sensor: false,
            })
    } else {
        world
            .try_cast_circle_filtered(
                position.0,
                position.1,
                settings.radius,
                displacement.0,
                displacement.1,
                distance,
                filter,
            )?
            .map(|hit| KinematicHit {
                body_id: hit.body_id,
                fixture_index: 0,
                point: hit.point,
                normal: hit.normal,
                toi: hit.toi,
                sensor: false,
            })
    };
    Ok(hit)
}

fn segment_aabb_hit(
    start: (f32, f32),
    unit: (f32, f32),
    max_distance: f32,
    min: (f32, f32),
    max: (f32, f32),
) -> Option<(f32, (f32, f32))> {
    let mut near = 0.0_f32;
    let mut far = max_distance;
    let mut normal = (0.0, 0.0);
    for axis in 0..2 {
        let (origin, direction, minimum, maximum) = if axis == 0 {
            (start.0, unit.0, min.0, max.0)
        } else {
            (start.1, unit.1, min.1, max.1)
        };
        if direction.abs() <= EPSILON {
            if origin < minimum || origin > maximum {
                return None;
            }
            continue;
        }
        let mut entry = (minimum - origin) / direction;
        let mut exit = (maximum - origin) / direction;
        let entry_normal = if axis == 0 {
            (-direction.signum(), 0.0)
        } else {
            (0.0, -direction.signum())
        };
        if entry > exit {
            std::mem::swap(&mut entry, &mut exit);
        }
        if entry > near {
            near = entry;
            normal = entry_normal;
        }
        far = far.min(exit);
        if near > far {
            return None;
        }
    }
    (near <= max_distance && far >= 0.0).then_some((near.max(0.0), normal))
}

fn collect_sensor_hits(
    world: &World,
    start: (f32, f32),
    displacement: (f32, f32),
    path_offset: f32,
    settings: &KinematicControllerSettings,
    hits: &mut Vec<KinematicHit>,
) {
    if !settings.filter.include_sensors {
        return;
    }
    let distance = displacement.0.hypot(displacement.1);
    if distance <= EPSILON {
        return;
    }
    let unit = (displacement.0 / distance, displacement.1 / distance);
    let end = (start.0 + displacement.0, start.1 + displacement.1);
    let radius = settings.radius;
    let candidates = world.query_aabb_filtered(
        start.0.min(end.0) - radius,
        start.1.min(end.1) - radius,
        (end.0 - start.0).abs() + radius * 2.0,
        (end.1 - start.1).abs() + radius * 2.0,
        settings.filter,
    );
    for body_id in candidates {
        if hits
            .iter()
            .any(|hit| hit.sensor && hit.body_id.0 == body_id)
            || !altitude_candidate_allowed(world, body_id, settings.vertical_span)
        {
            continue;
        }
        let Some(body) = world.get_body(body_id) else {
            continue;
        };
        if body.body_type != BodyType::Sensor {
            continue;
        }
        let half_w = body.width * 0.5 + radius;
        let half_h = body.height * 0.5 + radius;
        let Some((toi, normal)) = segment_aabb_hit(
            start,
            unit,
            distance,
            (body.position.x - half_w, body.position.y - half_h),
            (body.position.x + half_w, body.position.y + half_h),
        ) else {
            continue;
        };
        hits.push(KinematicHit {
            body_id: BodyId(body_id),
            fixture_index: 0,
            point: (start.0 + unit.0 * toi, start.1 + unit.1 * toi),
            normal,
            toi: path_offset + toi,
            sensor: true,
        });
    }
}

/// Solve one bounded displacement without mutating the world.
pub fn solve_kinematic_move(
    world: &World,
    body_id: usize,
    requested: (f32, f32),
    settings: KinematicControllerSettings,
) -> Result<KinematicMoveResult, PhysicsError> {
    validate_settings(&settings)?;
    if !requested.0.is_finite() || !requested.1.is_finite() {
        return Err(PhysicsError::InvalidFloat {
            field: "displacement",
            value: f64::NAN,
        });
    }
    let start = validate_body(world, body_id)?;
    if requested.0.hypot(requested.1) <= EPSILON {
        return Ok(KinematicMoveResult::stationary(requested));
    }

    let mut position = start;
    let mut remaining = requested;
    let mut result = KinematicMoveResult::stationary(requested);
    let mut path_distance = 0.0;
    for _ in 0..settings.max_slides {
        let distance = remaining.0.hypot(remaining.1);
        if distance <= EPSILON {
            remaining = (0.0, 0.0);
            break;
        }
        let unit = (remaining.0 / distance, remaining.1 / distance);
        let blocker = cast_blocker(world, position, remaining, &settings)?;
        let traversed_distance = blocker.as_ref().map_or(distance, |hit| {
            (hit.toi - settings.skin).clamp(0.0, distance)
        });
        collect_sensor_hits(
            world,
            position,
            (unit.0 * traversed_distance, unit.1 * traversed_distance),
            path_distance,
            &settings,
            &mut result.hits,
        );
        let Some(mut hit) = blocker else {
            position.0 += remaining.0;
            position.1 += remaining.1;
            remaining = (0.0, 0.0);
            break;
        };
        let impact_distance = hit.toi;
        let safe_distance = (impact_distance - settings.skin).clamp(0.0, distance);
        position.0 += unit.0 * safe_distance;
        position.1 += unit.1 * safe_distance;
        hit.toi = path_distance + impact_distance;
        path_distance += safe_distance;
        result.hits.push(hit);
        result.collided = true;

        let residual_distance = (distance - impact_distance.min(distance)).max(0.0);
        let residual = (unit.0 * residual_distance, unit.1 * residual_distance);
        let into_surface = residual.0 * hit.normal.0 + residual.1 * hit.normal.1;
        remaining = if into_surface < 0.0 {
            (
                residual.0 - hit.normal.0 * into_surface,
                residual.1 - hit.normal.1 * into_surface,
            )
        } else {
            residual
        };
        if safe_distance <= EPSILON && remaining.0.hypot(remaining.1) >= distance - EPSILON {
            break;
        }
    }
    result.applied = (position.0 - start.0, position.1 - start.1);
    result.remaining = remaining;
    result.hits.sort_by(|a, b| {
        a.toi
            .total_cmp(&b.toi)
            .then(a.body_id.0.cmp(&b.body_id.0))
            .then(a.sensor.cmp(&b.sensor))
    });
    Ok(result)
}

fn altitude_candidate_allowed(
    world: &World,
    body_id: usize,
    vertical_span: Option<(f32, f32)>,
) -> bool {
    let Some((z_min, z_max)) = vertical_span else {
        return true;
    };
    world
        .get_body_world_z_range(body_id)
        .is_some_and(|(other_min, other_max)| z_min <= other_max && other_min <= z_max)
}

/// Compute a bounded conservative depenetration displacement.
pub fn solve_kinematic_recovery(
    world: &World,
    body_id: usize,
    settings: KinematicControllerSettings,
) -> Result<KinematicMoveResult, PhysicsError> {
    validate_settings(&settings)?;
    let start = validate_body(world, body_id)?;
    let mut position = start;
    let mut result = KinematicMoveResult::stationary((0.0, 0.0));
    let mut filter = settings.filter;
    filter.include_sensors = false;

    for _ in 0..settings.max_slides {
        let extent = settings.radius + settings.skin;
        let candidates = world.query_aabb_filtered(
            position.0 - extent,
            position.1 - extent,
            extent * 2.0,
            extent * 2.0,
            filter,
        );
        let mut best: Option<(usize, f32, f32, f32)> = None;
        for candidate in candidates {
            if candidate == body_id
                || !altitude_candidate_allowed(world, candidate, settings.vertical_span)
            {
                continue;
            }
            let Some(body) = world.get_body(candidate) else {
                continue;
            };
            if body.body_type == BodyType::Sensor {
                continue;
            }
            let half_w = body.width * 0.5;
            let half_h = body.height * 0.5;
            let closest_x = position
                .0
                .clamp(body.position.x - half_w, body.position.x + half_w);
            let closest_y = position
                .1
                .clamp(body.position.y - half_h, body.position.y + half_h);
            let delta = (position.0 - closest_x, position.1 - closest_y);
            let distance = delta.0.hypot(delta.1);
            let (normal_x, normal_y, depth) = if distance > EPSILON {
                (delta.0 / distance, delta.1 / distance, extent - distance)
            } else {
                let left = position.0 - (body.position.x - half_w);
                let right = body.position.x + half_w - position.0;
                let top = position.1 - (body.position.y - half_h);
                let bottom = body.position.y + half_h - position.1;
                let (depth, nx, ny) = [
                    (left, -1.0, 0.0),
                    (right, 1.0, 0.0),
                    (top, 0.0, -1.0),
                    (bottom, 0.0, 1.0),
                ]
                .into_iter()
                .min_by(|a, b| a.0.total_cmp(&b.0))
                .unwrap();
                (nx, ny, extent + depth)
            };
            if depth <= 0.0 {
                continue;
            }
            match best {
                Some((best_id, best_depth, _, _))
                    if best_depth > depth || (best_depth == depth && best_id < candidate) => {}
                _ => best = Some((candidate, depth, normal_x, normal_y)),
            }
        }
        let Some((candidate, depth, normal_x, normal_y)) = best else {
            break;
        };
        position.0 += normal_x * depth;
        position.1 += normal_y * depth;
        result.collided = true;
        result.hits.push(KinematicHit {
            body_id: BodyId(candidate),
            fixture_index: 0,
            point: position,
            normal: (normal_x, normal_y),
            toi: 0.0,
            sensor: false,
        });
    }
    result.applied = (position.0 - start.0, position.1 - start.1);
    Ok(result)
}
