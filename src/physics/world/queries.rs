//! Owns the physics world queries implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics world queries data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics world queries behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics world queries defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near physics world queries state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping physics world queries calculations at their owning subsystem boundary.
//! Provides adaptation layer that lets callers reuse physics world queries rules without duplicating engine decisions.

use super::*;

impl World {
    /// Cast a ray from `(x1,y1)` to `(x2,y2)` and return the first hit, or `None`.
    pub fn raycast(&self, x1: f32, y1: f32, x2: f32, y2: f32) -> Option<RaycastHit> {
        self.raycast_filtered(x1, y1, x2, y2, PhysicsQueryFilter::default())
    }
    /// Cast a filtered ray from `(x1,y1)` to `(x2,y2)` and return the first hit, or `None`.
    pub fn raycast_filtered(
        &self,
        x1: f32,
        y1: f32,
        x2: f32,
        y2: f32,
        filter: PhysicsQueryFilter,
    ) -> Option<RaycastHit> {
        let dir = Vector::new(x2 - x1, y2 - y1);
        let max_toi = dir.length();
        if max_toi < 1e-6 {
            return None;
        }
        self.collect_raycast_hits_sorted(x1, y1, dir.x, dir.y, max_toi, filter)
            .into_iter()
            .next()
    }
    /// Build a `QueryPipeline` view over the current broad+narrow phase.
    fn query_pipeline(&self, filter: PhysicsQueryFilter) -> QueryPipeline<'_> {
        self.broad_phase.as_query_pipeline(
            self.narrow_phase.query_dispatcher(),
            &self.rbodies,
            &self.rcolliders,
            self.query_filter(filter),
        )
    }
    fn beam_endpoint(x1: f32, y1: f32, unit_dir: Vector, distance: f32) -> (f32, f32) {
        (x1 + unit_dir.x * distance, y1 + unit_dir.y * distance)
    }

    fn validate_sweep_direction(
        &self,
        context: &'static str,
        x: f32,
        y: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
    ) -> Result<Vector, PhysicsError> {
        validate_finite("x", f64::from(x))?;
        validate_finite("y", f64::from(y))?;
        validate_finite("dx", f64::from(dx))?;
        validate_finite("dy", f64::from(dy))?;
        validate_positive("max_distance", f64::from(max_dist))?;
        let dir_len = (dx * dx + dy * dy).sqrt();
        if dir_len < 1e-6 {
            return Err(PhysicsError::DegenerateGeometry {
                context,
                detail: "direction must be non-zero",
            });
        }
        Ok(Vector::new(dx / dir_len, dy / dir_len))
    }

    fn beam_hit_from_raycast(
        hit: RaycastHit,
        distance: f32,
        segment_index: usize,
        incoming_dir: Vector,
    ) -> BeamHit {
        BeamHit {
            body_id: hit.body_id,
            point: hit.point,
            normal: hit.normal,
            distance,
            segment_index,
            reflected: false,
            incoming_dir: (incoming_dir.x, incoming_dir.y),
            outgoing_dir: None,
            reflectivity: 0.0,
        }
    }

    fn beam_trace_to_max_range(
        x1: f32,
        y1: f32,
        end_point: (f32, f32),
        hits: Vec<BeamHit>,
    ) -> BeamTrace {
        BeamTrace {
            hits,
            segments: vec![BeamSegment {
                from: (x1, y1),
                to: end_point,
                blocked_by: None,
            }],
            reached_max_range: true,
        }
    }

    fn collect_raycast_hits_sorted(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
        filter: PhysicsQueryFilter,
    ) -> Vec<RaycastHit> {
        let dir_len = (dx * dx + dy * dy).sqrt();
        if dir_len < 1e-6 {
            return Vec::new();
        }
        let unit_dir = Vector::new(dx / dir_len, dy / dir_len);
        let ray = Ray::new(Vector::new(x1, y1), unit_dir);
        let qp = self.query_pipeline(filter);
        let mut best_by_body: HashMap<usize, RaycastHit> = HashMap::new();
        for (col_handle, _co, ri) in qp.intersect_ray(ray, max_dist, true) {
            if let Some(body_id) = self.body_for_collider(col_handle) {
                if !self.has_body(body_id) {
                    continue;
                }
                let pt_x = x1 + unit_dir.x * ri.time_of_impact;
                let pt_y = y1 + unit_dir.y * ri.time_of_impact;
                let hit = RaycastHit {
                    body_id: BodyId(body_id),
                    point: (pt_x, pt_y),
                    normal: (ri.normal.x, ri.normal.y),
                    toi: ri.time_of_impact,
                };
                match best_by_body.get(&body_id) {
                    Some(old) if old.toi <= hit.toi => {}
                    _ => {
                        best_by_body.insert(body_id, hit);
                    }
                }
            }
        }
        let mut hits: Vec<_> = best_by_body.into_values().collect();
        hits.sort_by(|a, b| a.toi.total_cmp(&b.toi).then(a.body_id.0.cmp(&b.body_id.0)));
        hits
    }

    fn validate_beam_options(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        options: BeamOptions,
    ) -> Result<Vector, PhysicsError> {
        validate_finite("x", f64::from(x1))?;
        validate_finite("y", f64::from(y1))?;
        validate_finite("dx", f64::from(dx))?;
        validate_finite("dy", f64::from(dy))?;
        validate_positive("max_distance", f64::from(options.max_distance))?;
        validate_finite("thickness", f64::from(options.thickness))?;
        validate_finite("energy", f64::from(options.energy))?;
        validate_finite("min_energy", f64::from(options.min_energy))?;
        if options.thickness < 0.0 {
            return Err(PhysicsError::ValueOutOfRange {
                field: "thickness",
                min: 0.0,
                max: f64::from(f32::MAX),
                value: f64::from(options.thickness),
            });
        }
        if options.thickness > 0.0 {
            return Err(PhysicsError::InvalidMode {
                context: "physics beam thickness",
                value: options.thickness.to_string(),
                expected: "0 until thick-beam shape casting support lands",
            });
        }
        if let BeamHitMode::Pierce { max_hits } = options.hit_mode {
            if max_hits == 0 || max_hits > self.limits.max_bodies {
                return Err(PhysicsError::ValueOutOfRange {
                    field: "max_hits",
                    min: 1.0,
                    max: self.limits.max_bodies as f64,
                    value: max_hits as f64,
                });
            }
        }
        if options.reflect {
            if !matches!(options.hit_mode, BeamHitMode::Closest) {
                return Err(PhysicsError::InvalidMode {
                    context: "physics beam reflection",
                    value: format!("{:?}", options.hit_mode),
                    expected: "closest beam mode when reflect = true",
                });
            }
            if options.max_bounces > self.limits.max_bodies {
                return Err(PhysicsError::ValueOutOfRange {
                    field: "max_bounces",
                    min: 0.0,
                    max: self.limits.max_bodies as f64,
                    value: options.max_bounces as f64,
                });
            }
            if options.energy < 0.0 || options.energy > 1.0 {
                return Err(PhysicsError::ValueOutOfRange {
                    field: "energy",
                    min: 0.0,
                    max: 1.0,
                    value: f64::from(options.energy),
                });
            }
            if options.min_energy < 0.0 || options.min_energy > 1.0 {
                return Err(PhysicsError::ValueOutOfRange {
                    field: "min_energy",
                    min: 0.0,
                    max: 1.0,
                    value: f64::from(options.min_energy),
                });
            }
            if options.min_energy > options.energy {
                return Err(PhysicsError::InvalidMode {
                    context: "physics beam reflection",
                    value: format!(
                        "energy={} min_energy={}",
                        options.energy, options.min_energy
                    ),
                    expected: "min_energy <= energy",
                });
            }
        }
        let dir_len = (dx * dx + dy * dy).sqrt();
        if dir_len < 1e-6 {
            return Err(PhysicsError::DegenerateGeometry {
                context: "physics beam",
                detail: "direction must be non-zero",
            });
        }
        Ok(Vector::new(dx / dir_len, dy / dir_len))
    }

    /// Cast an instant gameplay beam and return hit plus segment data.
    ///
    /// This best-effort wrapper returns an empty trace when validation fails. Use
    /// `try_cast_beam` when the caller needs the exact error.
    pub fn cast_beam(&self, x1: f32, y1: f32, dx: f32, dy: f32, options: BeamOptions) -> BeamTrace {
        self.try_cast_beam(x1, y1, dx, dy, options)
            .unwrap_or_default()
    }

    /// Cast an instant gameplay beam and return hit plus segment data.
    pub fn try_cast_beam(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        options: BeamOptions,
    ) -> Result<BeamTrace, PhysicsError> {
        let unit_dir = self.validate_beam_options(x1, y1, dx, dy, options)?;
        if options.reflect {
            return self.try_cast_reflective_beam(x1, y1, unit_dir, options);
        }
        let end_point = Self::beam_endpoint(x1, y1, unit_dir, options.max_distance);
        match options.hit_mode {
            BeamHitMode::Closest => {
                if let Some(hit) = self.raycast_closest_filtered(
                    x1,
                    y1,
                    dx,
                    dy,
                    options.max_distance,
                    options.filter,
                ) {
                    let beam_hit = Self::beam_hit_from_raycast(hit, hit.toi, 1, unit_dir);
                    Ok(BeamTrace {
                        hits: vec![beam_hit],
                        segments: vec![BeamSegment {
                            from: (x1, y1),
                            to: hit.point,
                            blocked_by: Some(hit.body_id),
                        }],
                        reached_max_range: false,
                    })
                } else {
                    Ok(Self::beam_trace_to_max_range(x1, y1, end_point, Vec::new()))
                }
            }
            BeamHitMode::All => {
                let hits = self
                    .raycast_all_filtered(x1, y1, dx, dy, options.max_distance, options.filter)
                    .into_iter()
                    .map(|hit| Self::beam_hit_from_raycast(hit, hit.toi, 1, unit_dir))
                    .collect();
                Ok(Self::beam_trace_to_max_range(x1, y1, end_point, hits))
            }
            BeamHitMode::Pierce { max_hits } => {
                let hits =
                    self.raycast_all_filtered(x1, y1, dx, dy, options.max_distance, options.filter);
                let truncated = hits.len() > max_hits;
                let mut beam_hits = Vec::with_capacity(hits.len().min(max_hits));
                for hit in hits.into_iter().take(max_hits) {
                    beam_hits.push(Self::beam_hit_from_raycast(hit, hit.toi, 1, unit_dir));
                }
                if truncated {
                    let last_hit = beam_hits
                        .last()
                        .copied()
                        .expect("pierce hit list should not be empty");
                    Ok(BeamTrace {
                        hits: beam_hits,
                        segments: vec![BeamSegment {
                            from: (x1, y1),
                            to: last_hit.point,
                            blocked_by: Some(last_hit.body_id),
                        }],
                        reached_max_range: false,
                    })
                } else {
                    Ok(Self::beam_trace_to_max_range(x1, y1, end_point, beam_hits))
                }
            }
        }
    }

    fn try_cast_reflective_beam(
        &self,
        x1: f32,
        y1: f32,
        unit_dir: Vector,
        options: BeamOptions,
    ) -> Result<BeamTrace, PhysicsError> {
        let mut hits = Vec::new();
        let mut segments = Vec::new();
        let mut current_point = (x1, y1);
        let mut current_dir = unit_dir;
        let mut remaining_range = options.max_distance;
        let mut current_energy = options.energy;
        let mut segment_index = 1usize;
        let mut bounce_count = 0usize;
        let mut total_distance = 0.0f32;

        loop {
            let offset = if segment_index == 1 {
                0.0
            } else {
                BEAM_REFLECTION_EPSILON
            };
            let query_max_distance = remaining_range - offset;
            if query_max_distance <= 1e-6 {
                return Ok(BeamTrace {
                    hits,
                    segments,
                    reached_max_range: false,
                });
            }
            let query_origin = (
                current_point.0 + current_dir.x * offset,
                current_point.1 + current_dir.y * offset,
            );
            let Some(hit) = self.raycast_closest_filtered(
                query_origin.0,
                query_origin.1,
                current_dir.x,
                current_dir.y,
                query_max_distance,
                options.filter,
            ) else {
                segments.push(BeamSegment {
                    from: current_point,
                    to: (
                        current_point.0 + current_dir.x * remaining_range,
                        current_point.1 + current_dir.y * remaining_range,
                    ),
                    blocked_by: None,
                });
                return Ok(BeamTrace {
                    hits,
                    segments,
                    reached_max_range: true,
                });
            };

            let dx = hit.point.0 - current_point.0;
            let dy = hit.point.1 - current_point.1;
            let visible_distance = (dx * dx + dy * dy).sqrt();
            total_distance += visible_distance;
            remaining_range -= visible_distance;

            let (reflective, reflectivity) = self
                .get_body(hit.body_id.0)
                .map(|body| {
                    (
                        body.reflective,
                        Self::clamp_reflectivity(body.beam_reflectivity),
                    )
                })
                .unwrap_or((false, 0.0));

            let outgoing_dir = if reflective
                && bounce_count < options.max_bounces
                && current_energy > 0.0
                && reflectivity > 0.0
            {
                Self::reflect_vector(current_dir, Vector::new(hit.normal.0, hit.normal.1))
            } else {
                None
            };
            let reflected = outgoing_dir.is_some()
                && current_energy * reflectivity >= options.min_energy
                && remaining_range > BEAM_REFLECTION_EPSILON;

            hits.push(BeamHit {
                body_id: hit.body_id,
                point: hit.point,
                normal: hit.normal,
                distance: total_distance,
                segment_index,
                reflected,
                incoming_dir: (current_dir.x, current_dir.y),
                outgoing_dir: if reflected {
                    outgoing_dir.map(|dir| (dir.x, dir.y))
                } else {
                    None
                },
                reflectivity,
            });
            segments.push(BeamSegment {
                from: current_point,
                to: hit.point,
                blocked_by: Some(hit.body_id),
            });

            if !reflected {
                return Ok(BeamTrace {
                    hits,
                    segments,
                    reached_max_range: false,
                });
            }

            current_energy *= reflectivity;
            current_point = hit.point;
            current_dir = outgoing_dir.expect("reflected beam should have outgoing direction");
            segment_index += 1;
            bounce_count += 1;
        }
    }

    /// Sweep a circle from `(x, y)` in direction `(dx, dy)` and return the first collider hit.
    pub fn cast_circle(
        &self,
        x: f32,
        y: f32,
        radius: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
    ) -> Option<ShapeSweepHit> {
        self.cast_circle_filtered(
            x,
            y,
            radius,
            dx,
            dy,
            max_dist,
            PhysicsQueryFilter::default(),
        )
    }

    /// Sweep a circle from `(x, y)` in direction `(dx, dy)` using a query filter.
    #[allow(clippy::too_many_arguments)]
    pub fn cast_circle_filtered(
        &self,
        x: f32,
        y: f32,
        radius: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
        filter: PhysicsQueryFilter,
    ) -> Option<ShapeSweepHit> {
        self.try_cast_circle_filtered(x, y, radius, dx, dy, max_dist, filter)
            .ok()
            .flatten()
    }

    /// Sweep a circle from `(x, y)` in direction `(dx, dy)` using a query filter.
    #[allow(clippy::too_many_arguments)]
    pub fn try_cast_circle_filtered(
        &self,
        x: f32,
        y: f32,
        radius: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
        filter: PhysicsQueryFilter,
    ) -> Result<Option<ShapeSweepHit>, PhysicsError> {
        validate_positive("radius", f64::from(radius))?;
        let unit_dir =
            self.validate_sweep_direction("physics circle cast", x, y, dx, dy, max_dist)?;
        let qp = self.query_pipeline(filter);
        let shape = Ball::new(radius);
        let shape_pos = Pose::new(Vector::new(x, y), 0.0);
        let options = rapier2d::parry::query::ShapeCastOptions {
            target_distance: 0.0,
            stop_at_penetration: false,
            max_time_of_impact: max_dist,
            compute_impact_geometry_on_penetration: true,
        };
        let Some((col_handle, hit)) = qp.cast_shape(&shape_pos, unit_dir, &shape, options) else {
            return Ok(None);
        };
        let Some(body_id) = self.body_for_collider(col_handle) else {
            return Ok(None);
        };
        if !self.has_body(body_id) {
            return Ok(None);
        }
        Ok(Some(ShapeSweepHit {
            body_id: BodyId(body_id),
            point: (hit.witness1.x, hit.witness1.y),
            normal: (hit.normal1.x, hit.normal1.y),
            toi: hit.time_of_impact,
            safe_fraction: (hit.time_of_impact / max_dist).clamp(0.0, 1.0),
        }))
    }

    /// Return only the closest instant beam hit.
    ///
    /// This best-effort wrapper returns `None` when validation fails. Use
    /// `try_cast_beam_closest` when the caller needs the exact error.
    pub fn cast_beam_closest(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_distance: f32,
        filter: PhysicsQueryFilter,
    ) -> Option<BeamHit> {
        self.try_cast_beam_closest(x1, y1, dx, dy, max_distance, filter)
            .unwrap_or(None)
    }

    /// Return only the closest instant beam hit.
    pub fn try_cast_beam_closest(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_distance: f32,
        filter: PhysicsQueryFilter,
    ) -> Result<Option<BeamHit>, PhysicsError> {
        let trace = self.try_cast_beam(
            x1,
            y1,
            dx,
            dy,
            BeamOptions {
                max_distance,
                thickness: 0.0,
                hit_mode: BeamHitMode::Closest,
                reflect: false,
                max_bounces: 0,
                energy: 1.0,
                min_energy: 0.0,
                filter,
            },
        )?;
        Ok(trace.hits.into_iter().next())
    }

    /// Cast a ray from `(x1,y1)` in direction `(dx,dy)` up to `max_dist`; return closest hit.
    pub fn raycast_closest(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
    ) -> Option<RaycastHit> {
        self.raycast_closest_filtered(x1, y1, dx, dy, max_dist, PhysicsQueryFilter::default())
    }
    /// Cast a filtered directional ray and return the closest hit.
    pub fn raycast_closest_filtered(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
        filter: PhysicsQueryFilter,
    ) -> Option<RaycastHit> {
        self.collect_raycast_hits_sorted(x1, y1, dx, dy, max_dist, filter)
            .into_iter()
            .next()
    }
    /// Cast a ray from `(x1,y1)` in direction `(dx,dy)` and return all hits up to `max_dist`.
    pub fn raycast_all(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
    ) -> Vec<RaycastHit> {
        self.raycast_all_filtered(x1, y1, dx, dy, max_dist, PhysicsQueryFilter::default())
    }
    /// Cast a filtered ray and return at most one closest hit per body.
    pub fn raycast_all_filtered(
        &self,
        x1: f32,
        y1: f32,
        dx: f32,
        dy: f32,
        max_dist: f32,
        filter: PhysicsQueryFilter,
    ) -> Vec<RaycastHit> {
        self.collect_raycast_hits_sorted(x1, y1, dx, dy, max_dist, filter)
    }
    /// Return all body ids whose AABB overlaps the query rectangle.
    pub fn query_aabb(&self, x: f32, y: f32, w: f32, h: f32) -> Vec<usize> {
        self.query_aabb_filtered(x, y, w, h, PhysicsQueryFilter::default())
    }
    /// Return all filtered body ids whose AABB overlaps the query rectangle.
    pub fn query_aabb_filtered(
        &self,
        x: f32,
        y: f32,
        w: f32,
        h: f32,
        filter: PhysicsQueryFilter,
    ) -> Vec<usize> {
        let aabb = Aabb {
            mins: Vector::new(x, y),
            maxs: Vector::new(x + w, y + h),
        };
        let qp = self.query_pipeline(filter);
        let mut seen = HashSet::new();
        let mut results = Vec::new();
        for (col_handle, _co) in qp.intersect_aabb_conservative(aabb) {
            if let Some(body_id) = self.body_for_collider(col_handle) {
                if self.has_body(body_id) && seen.insert(body_id) {
                    results.push(body_id);
                }
            }
        }
        results.sort_unstable();
        results
    }
    /// Return the first body id whose AABB contains point `(x, y)`, or `None`.
    pub fn get_body_at_point(&self, x: f32, y: f32) -> Option<usize> {
        self.get_body_at_point_filtered(x, y, PhysicsQueryFilter::default())
    }
    /// Return the first filtered body id whose AABB contains point `(x, y)`, or `None`.
    pub fn get_body_at_point_filtered(
        &self,
        x: f32,
        y: f32,
        filter: PhysicsQueryFilter,
    ) -> Option<usize> {
        let epsilon = 0.01;
        let aabb = Aabb {
            mins: Vector::new(x - epsilon, y - epsilon),
            maxs: Vector::new(x + epsilon, y + epsilon),
        };
        let qp = self.query_pipeline(filter);
        for (col_handle, _co) in qp.intersect_aabb_conservative(aabb) {
            if let Some(body_id) = self.body_for_collider(col_handle) {
                if self.has_body(body_id) {
                    return Some(body_id);
                }
            }
        }
        None
    }
}
