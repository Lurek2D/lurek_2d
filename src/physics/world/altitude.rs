//! Owns world-side altitude-layer attachment and per-body vertical metadata accessors.
//! This file keeps 2.5D sidecar storage near `World` lifecycle rules without mixing Lua parsing into physics owners.
//! Query logic and vertical stepping will extend this owner later; for now it handles storage, defaults, and cleanup-safe access.

use super::*;
use crate::physics::altitude::{
    AltitudeCollisionOptions, AltitudeHit, AltitudeHitKind, AltitudeLayer, AltitudeMode,
    BallisticArcOptions, BallisticProjectile, BallisticProjectileOptions, BallisticTrace,
    BodyAltitudeState, CircleCast25DOptions,
};
use crate::physics::limits::{validate_finite, validate_positive};

impl World {
    /// Attach or replace the altitude layer used by terrain-relative Z helpers.
    pub fn set_altitude_layer(&mut self, layer: AltitudeLayer) {
        self.altitude_layer = Some(layer);
    }

    /// Remove the currently attached altitude layer.
    pub fn clear_altitude_layer(&mut self) {
        self.altitude_layer = None;
    }

    /// Return the currently attached altitude layer, if any.
    pub fn get_altitude_layer(&self) -> Option<&AltitudeLayer> {
        self.altitude_layer.as_ref()
    }

    /// Return a mutable reference to the attached altitude layer, if any.
    pub fn get_altitude_layer_mut(&mut self) -> Option<&mut AltitudeLayer> {
        self.altitude_layer.as_mut()
    }

    /// Set a body's terrain-relative or fixed-world altitude.
    pub fn try_set_body_altitude(&mut self, id: usize, z: f32) -> Result<(), PhysicsError> {
        validate_finite("z", f64::from(z))?;
        self.ensure_body_altitude_state_mut(id)?.z = z;
        Ok(())
    }

    /// Return a body's authored altitude, or zero when no sidecar state exists.
    pub fn get_body_altitude(&self, id: usize) -> Option<f32> {
        self.body_altitude_state(id).map(|state| state.z)
    }

    /// Set a body's vertical velocity.
    pub fn try_set_body_vertical_velocity(
        &mut self,
        id: usize,
        vz: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("vertical_velocity", f64::from(vz))?;
        self.ensure_body_altitude_state_mut(id)?.vertical_velocity = vz;
        Ok(())
    }

    /// Return a body's authored vertical velocity, or zero when no sidecar state exists.
    pub fn get_body_vertical_velocity(&self, id: usize) -> Option<f32> {
        self.body_altitude_state(id)
            .map(|state| state.vertical_velocity)
    }

    /// Set the explicit height extent used for 2.5D target intervals.
    pub fn try_set_body_height_extent(
        &mut self,
        id: usize,
        height: f32,
    ) -> Result<(), PhysicsError> {
        validate_positive("height_extent", f64::from(height))?;
        self.ensure_body_altitude_state_mut(id)?.height_extent = Some(height);
        Ok(())
    }

    /// Return the effective height extent used for 2.5D target intervals.
    pub fn get_body_height_extent(&self, id: usize) -> Option<f32> {
        let body = self.get_body(id)?;
        let explicit = self
            .body_altitudes
            .get(&id)
            .and_then(|state| state.height_extent);
        Some(explicit.unwrap_or_else(|| body.width.max(body.height).max(1.0)))
    }

    /// Set how a body's altitude should be interpreted.
    pub fn set_body_altitude_mode(
        &mut self,
        id: usize,
        mode: AltitudeMode,
    ) -> Result<(), PhysicsError> {
        self.ensure_body_altitude_state_mut(id)?.mode = mode;
        Ok(())
    }

    /// Return the body's altitude interpretation mode.
    pub fn get_body_altitude_mode(&self, id: usize) -> Option<AltitudeMode> {
        self.body_altitude_state(id).map(|state| state.mode)
    }

    /// Set the body's per-step vertical gravity.
    pub fn try_set_body_vertical_gravity(
        &mut self,
        id: usize,
        gravity: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("vertical_gravity", f64::from(gravity))?;
        self.ensure_body_altitude_state_mut(id)?.vertical_gravity = gravity;
        Ok(())
    }

    /// Return the body's per-step vertical gravity.
    pub fn get_body_vertical_gravity(&self, id: usize) -> Option<f32> {
        self.body_altitude_state(id)
            .map(|state| state.vertical_gravity)
    }

    /// Set the body's clearance classification name.
    pub fn set_body_clearance_class(
        &mut self,
        id: usize,
        class_name: impl Into<String>,
    ) -> Result<(), PhysicsError> {
        let class_name = class_name.into();
        if class_name.is_empty() {
            return Err(PhysicsError::ConfigMismatch {
                context: "physics altitude clearance class",
                detail: "class name must not be empty".to_string(),
            });
        }
        self.ensure_body_altitude_state_mut(id)?.clearance_class = class_name;
        Ok(())
    }

    /// Return the body's clearance classification name.
    pub fn get_body_clearance_class(&self, id: usize) -> Option<String> {
        self.body_altitude_state(id)
            .map(|state| state.clearance_class)
    }

    /// Replace the body's altitude collision flags.
    pub fn set_body_altitude_collision(
        &mut self,
        id: usize,
        options: AltitudeCollisionOptions,
    ) -> Result<(), PhysicsError> {
        self.ensure_body_altitude_state_mut(id)?.collision = options;
        Ok(())
    }

    /// Return the body's altitude collision flags.
    pub fn get_body_altitude_collision(&self, id: usize) -> Option<AltitudeCollisionOptions> {
        self.body_altitude_state(id).map(|state| state.collision)
    }

    /// Return a copy of the full body altitude sidecar state.
    pub fn body_altitude_state(&self, id: usize) -> Option<BodyAltitudeState> {
        self.has_body(id)
            .then(|| self.body_altitudes.get(&id).cloned().unwrap_or_default())
    }

    /// Return the sampled terrain height beneath the body, or zero without a layer.
    pub fn get_body_ground_height(&self, id: usize) -> Option<f32> {
        let body = self.get_body(id)?;
        self.sample_ground_height(body.position.x, body.position.y)
    }

    /// Return the body's effective world-space Z interval.
    pub fn get_body_world_z_range(&self, id: usize) -> Option<(f32, f32)> {
        let state = self.body_altitude_state(id)?;
        let ground_height = self.get_body_ground_height(id)?;
        let height_extent = self.get_body_height_extent(id)?;
        Some(state.world_z_range(ground_height, height_extent))
    }

    /// Remove all authored altitude metadata for one body.
    pub fn clear_body_altitude_state(&mut self, id: usize) {
        self.body_altitudes.remove(&id);
    }

    pub(crate) fn sample_ground_height(&self, x: f32, y: f32) -> Option<f32> {
        match &self.altitude_layer {
            Some(layer) => layer.sample_height(x, y).ok(),
            None => Some(0.0),
        }
    }

    pub(crate) fn altitude_intervals_overlap(
        &self,
        a_min: f32,
        a_max: f32,
        b_min: f32,
        b_max: f32,
    ) -> bool {
        a_min <= b_max && b_min <= a_max
    }

    pub(crate) fn moving_world_z_range(
        &self,
        z: f32,
        height: f32,
        dz: f32,
        safe_fraction: f32,
    ) -> (f32, f32) {
        let z_min = z + dz * safe_fraction;
        (z_min, z_min + height.max(0.0))
    }

    pub(crate) fn altitude_hit_for_body(
        &self,
        body_id: usize,
        point: (f32, f32),
        normal: (f32, f32),
        toi: f32,
        impact_z: f32,
    ) -> Option<AltitudeHit> {
        let (target_z_min, target_z_max) = self.get_body_world_z_range(body_id)?;
        let ground_height = self.sample_ground_height(point.0, point.1).unwrap_or(0.0);
        Some(AltitudeHit {
            body_id: Some(BodyId(body_id)),
            point,
            normal,
            toi,
            z: impact_z,
            target_z_min: Some(target_z_min),
            target_z_max: Some(target_z_max),
            ground_height,
            hit_kind: AltitudeHitKind::Body,
        })
    }

    pub fn try_cast_ballistic_arc(
        &self,
        options: &BallisticArcOptions,
        filter: PhysicsQueryFilter,
    ) -> Result<BallisticTrace, PhysicsError> {
        let velocity = self.solve_ballistic_velocity(
            options.from,
            options.to,
            options.speed,
            options.gravity,
            options.max_time,
        )?;
        let mut samples = vec![options.from];
        let mut position = options.from;
        let mut velocity = velocity;
        let mut elapsed = 0.0_f32;
        let max_time = options.max_time;
        let step_dt = options.sample_dt.min(max_time).max(1.0e-4);

        while elapsed < max_time - 1.0e-6 {
            let dt = step_dt.min(max_time - elapsed);
            let next_vz = velocity.2 + options.gravity * dt;
            let next_position = (
                position.0 + velocity.0 * dt,
                position.1 + velocity.1 * dt,
                position.2 + next_vz * dt,
            );
            let seg_dx = next_position.0 - position.0;
            let seg_dy = next_position.1 - position.1;
            let seg_dist = (seg_dx * seg_dx + seg_dy * seg_dy).sqrt();
            if seg_dist > 1.0e-6 {
                let hit = self.try_cast_circle_25d(
                    CircleCast25DOptions {
                        x: position.0,
                        y: position.1,
                        z: position.2,
                        radius: options.radius,
                        height: options.height,
                        dx: seg_dx,
                        dy: seg_dy,
                        dz: next_position.2 - position.2,
                        max_dist: seg_dist,
                    },
                    filter,
                )?;
                if let Some(hit) = hit {
                    samples.push((hit.point.0, hit.point.1, hit.z));
                    return Ok(BallisticTrace {
                        samples,
                        hit: Some(hit),
                        travel_time: elapsed + dt * (hit.toi / seg_dist).clamp(0.0, 1.0),
                        expired: false,
                    });
                }
            }
            elapsed += dt;
            position = next_position;
            velocity.2 = next_vz;
            samples.push(position);
        }

        Ok(BallisticTrace {
            samples,
            hit: None,
            travel_time: elapsed,
            expired: true,
        })
    }

    pub fn spawn_ballistic_projectile(
        &mut self,
        options: BallisticProjectileOptions,
    ) -> Result<usize, PhysicsError> {
        let velocity = self.solve_ballistic_velocity(
            options.from,
            options.to,
            options.speed,
            options.gravity,
            options.max_time,
        )?;
        let id = self.ballistic_projectiles.len();
        self.ballistic_projectiles.push(Some(BallisticProjectile {
            id,
            owner: options.owner,
            homing_target: options.homing_target,
            faction_mask: options.faction_mask,
            pierce_count: options.pierce_count,
            impact_metadata: options.impact_metadata.clone(),
            position: options.from,
            velocity,
            radius: options.radius,
            height: options.height,
            gravity: options.gravity,
            time_remaining: options.max_time,
            sample_dt: options.sample_dt.max(1.0e-4),
        }));
        Ok(id)
    }

    pub fn get_ballistic_projectile(&self, id: usize) -> Option<&BallisticProjectile> {
        self.ballistic_projectiles
            .get(id)
            .and_then(|slot| slot.as_ref())
    }

    pub fn remove_ballistic_projectile(&mut self, id: usize) -> bool {
        match self.ballistic_projectiles.get_mut(id) {
            Some(slot) if slot.is_some() => {
                *slot = None;
                true
            }
            _ => false,
        }
    }

    pub fn ballistic_projectile_hits(&self) -> &[AltitudeHit] {
        &self.ballistic_projectile_hits
    }

    pub fn take_ballistic_projectile_hits(&mut self) -> Vec<AltitudeHit> {
        self.ballistic_projectile_hits.drain(..).collect()
    }

    pub(crate) fn step_body_altitudes(&mut self, dt: f32) {
        let body_ids: Vec<usize> = self.body_altitudes.keys().copied().collect();
        for id in body_ids {
            if !self.has_body(id) {
                self.body_altitudes.remove(&id);
                continue;
            }

            let Some(body) = self.get_body(id) else {
                continue;
            };
            let _ground_height = self
                .sample_ground_height(body.position.x, body.position.y)
                .unwrap_or(0.0);
            let Some(state) = self.body_altitudes.get_mut(&id) else {
                continue;
            };

            match state.mode {
                AltitudeMode::Ground => {
                    state.z = 0.0;
                    state.vertical_velocity = 0.0;
                }
                AltitudeMode::Airborne => {
                    if state.vertical_velocity.abs() > 1e-6 || state.vertical_gravity.abs() > 1e-6 {
                        state.vertical_velocity += state.vertical_gravity * dt;
                        state.z += state.vertical_velocity * dt;
                    }
                    Self::clamp_relative_altitude_to_ground(state);
                }
                AltitudeMode::Ballistic => {
                    state.vertical_velocity += state.vertical_gravity * dt;
                    state.z += state.vertical_velocity * dt;
                    Self::clamp_relative_altitude_to_ground(state);
                }
                AltitudeMode::Fixed => {
                    if state.vertical_velocity.abs() > 1e-6 || state.vertical_gravity.abs() > 1e-6 {
                        state.vertical_velocity += state.vertical_gravity * dt;
                        state.z += state.vertical_velocity * dt;
                    }
                }
            }
        }
    }

    fn ensure_body_altitude_state_mut(
        &mut self,
        id: usize,
    ) -> Result<&mut BodyAltitudeState, PhysicsError> {
        if !self.has_body(id) {
            return Err(PhysicsError::InvalidBodyReference { body_id: id });
        }
        Ok(self.body_altitudes.entry(id).or_default())
    }

    fn clamp_relative_altitude_to_ground(state: &mut BodyAltitudeState) {
        if state.collision.hit_ground_when_below_terrain && state.z <= 0.0 {
            state.z = 0.0;
            if state.vertical_velocity < 0.0 {
                state.vertical_velocity = 0.0;
            }
        }
    }

    fn solve_ballistic_velocity(
        &self,
        from: (f32, f32, f32),
        to: (f32, f32, f32),
        speed: f32,
        gravity: f32,
        max_time: f32,
    ) -> Result<(f32, f32, f32), PhysicsError> {
        validate_positive("speed", f64::from(speed))?;
        validate_positive("max_time", f64::from(max_time))?;
        validate_finite("gravity", f64::from(gravity))?;
        let dx = to.0 - from.0;
        let dy = to.1 - from.1;
        let distance = (dx * dx + dy * dy).sqrt();
        let travel_time = if distance <= 1.0e-6 {
            max_time.min(1.0)
        } else {
            (distance / speed).min(max_time)
        };
        let (vx, vy) = if distance <= 1.0e-6 {
            (0.0, 0.0)
        } else {
            let inv = 1.0 / distance;
            (dx * inv * speed, dy * inv * speed)
        };
        let dz = to.2 - from.2;
        let vz = if travel_time <= 1.0e-6 {
            0.0
        } else {
            (dz - 0.5 * gravity * travel_time * travel_time) / travel_time
        };
        Ok((vx, vy, vz))
    }

    pub(crate) fn step_ballistic_projectiles(&mut self, dt: f32) {
        let projectile_ids: Vec<usize> = self
            .ballistic_projectiles
            .iter()
            .enumerate()
            .filter_map(|(id, slot)| slot.as_ref().map(|_| id))
            .collect();

        for id in projectile_ids {
            let mut projectile = match self
                .ballistic_projectiles
                .get_mut(id)
                .and_then(Option::take)
            {
                Some(projectile) => projectile,
                None => continue,
            };
            let mut remaining = dt.min(projectile.time_remaining.max(0.0));
            let mut hit: Option<AltitudeHit> = None;

            while remaining > 1.0e-6 && projectile.time_remaining > 1.0e-6 {
                let step_dt = projectile
                    .sample_dt
                    .min(remaining)
                    .min(projectile.time_remaining);
                let next_vz = projectile.velocity.2 + projectile.gravity * step_dt;
                let next_position = (
                    projectile.position.0 + projectile.velocity.0 * step_dt,
                    projectile.position.1 + projectile.velocity.1 * step_dt,
                    projectile.position.2 + next_vz * step_dt,
                );
                let seg_dx = next_position.0 - projectile.position.0;
                let seg_dy = next_position.1 - projectile.position.1;
                let seg_dist = (seg_dx * seg_dx + seg_dy * seg_dy).sqrt();
                if seg_dist > 1.0e-6 {
                    let filter = PhysicsQueryFilter {
                        exclude_body: projectile.owner.map(BodyId),
                        ..PhysicsQueryFilter::default()
                    };
                    hit = self
                        .try_cast_circle_25d(
                            CircleCast25DOptions {
                                x: projectile.position.0,
                                y: projectile.position.1,
                                z: projectile.position.2,
                                radius: projectile.radius,
                                height: projectile.height,
                                dx: seg_dx,
                                dy: seg_dy,
                                dz: next_position.2 - projectile.position.2,
                                max_dist: seg_dist,
                            },
                            filter,
                        )
                        .ok()
                        .flatten();
                    if hit.is_some() {
                        break;
                    }
                }
                projectile.position = next_position;
                projectile.velocity.2 = next_vz;
                projectile.time_remaining -= step_dt;
                remaining -= step_dt;
            }

            if let Some(hit) = hit {
                self.ballistic_projectile_hits.push(hit);
                continue;
            }
            if projectile.time_remaining <= 1.0e-6 {
                let ground_height = self
                    .sample_ground_height(projectile.position.0, projectile.position.1)
                    .unwrap_or(0.0);
                self.ballistic_projectile_hits.push(AltitudeHit {
                    body_id: None,
                    point: (projectile.position.0, projectile.position.1),
                    normal: (0.0, 0.0),
                    toi: 0.0,
                    z: projectile.position.2,
                    target_z_min: None,
                    target_z_max: None,
                    ground_height,
                    hit_kind: AltitudeHitKind::Expired,
                });
                continue;
            }
            if let Some(slot) = self.ballistic_projectiles.get_mut(id) {
                *slot = Some(projectile);
            }
        }
    }
}
