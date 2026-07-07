//! Owns the physics world simulation implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics world simulation data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics world simulation behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics world simulation defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near physics world simulation state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping physics world simulation calculations at their owning subsystem boundary.
//! Provides adaptation layer that lets callers reuse physics world simulation rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on physics world simulation state, helpers, or rules.
//! Works with neighboring physics owners while keeping main physics world simulation responsibility anchored in one file.

use super::*;

impl World {
    /// Step the simulation by `dt` seconds; synchronises body state with rapier.
    pub fn step(&mut self, dt: f32) {
        self.collision_events.clear();
        self.begin_contact_events.clear();
        self.end_contact_events.clear();
        self.diagnostics.last_bodies_scanned = 0;
        self.diagnostics.last_colliders_rebuilt = 0;
        self.diagnostics.last_zone_checks = 0;
        self.diagnostics.last_flow_samples = 0;
        self.diagnostics.last_flow_affected_bodies = 0;
        self.diagnostics.last_contacts = 0;
        self.diagnostics.last_synced_bodies = 0;
        if !dt.is_finite() || dt <= 0.0 {
            self.diagnostics.skipped_steps += 1;
            return;
        }
        let effective_dt = if dt > self.limits.max_step_dt {
            self.diagnostics.clamped_steps += 1;
            self.limits.max_step_dt
        } else {
            dt
        };
        self.params.dt = effective_dt;
        let n = self.bodies.len();
        self.diagnostics.last_bodies_scanned = n;
        self.rebuild_scratch.clear();
        for i in 0..n {
            if !self.has_body(i) {
                continue;
            }
            let b = &self.bodies[i];
            if b.shape != self.cached_shapes[i]
                || (b.restitution - self.cached_restitutions[i]).abs() > 1e-6
                || (b.friction - self.cached_frictions[i]).abs() > 1e-6
                || (b.layer, b.mask) != self.cached_layers[i]
            {
                self.rebuild_scratch.push(i);
            }
        }
        for idx in 0..self.rebuild_scratch.len() {
            let body_id = self.rebuild_scratch[idx];
            self.rebuild_collider(body_id);
        }
        self.diagnostics.last_colliders_rebuilt = self.rebuild_scratch.len();
        self.sync_scratch.clear();
        self.sync_scratch.resize(n, None);
        for (idx, b) in self.bodies.iter().enumerate() {
            if !self.has_body(idx) {
                continue;
            }
            let should_sync = match b.body_type {
                BodyType::Dynamic => self.body_dirty_sync.get(idx).copied().unwrap_or(false),
                _ => true,
            };
            if !should_sync {
                continue;
            }
            self.sync_scratch[idx] = Some((
                b.position.x,
                b.position.y,
                b.velocity.x,
                b.velocity.y,
                b.angle,
                b.angular_velocity,
                b.body_type,
            ));
        }
        for (i, item) in self.sync_scratch.iter().enumerate() {
            let Some((px, py, vx, vy, angle, angvel, bt)) = *item else {
                continue;
            };
            let handle = self.body_handles[i];
            if let Some(rb) = self.rbodies.get_mut(handle) {
                match bt {
                    BodyType::Dynamic => {
                        rb.set_translation(Vector::new(px, py), true);
                        rb.set_rotation(Rotation::new(angle), true);
                        rb.set_linvel(Vector::new(vx, vy), true);
                        rb.set_angvel(angvel, true);
                    }
                    BodyType::Kinematic => {
                        rb.set_next_kinematic_translation(Vector::new(px, py));
                        rb.set_next_kinematic_rotation(Rotation::new(angle));
                    }
                    _ => {
                        rb.set_translation(Vector::new(px, py), true);
                        rb.set_rotation(Rotation::new(angle), true);
                    }
                }
            }
            if let Some(dirty) = self.body_dirty_sync.get_mut(i) {
                *dirty = false;
            }
            self.diagnostics.last_synced_bodies += 1;
        }
        self.apply_zone_forces(effective_dt);
        self.apply_flow_forces(effective_dt);
        let event_col = LocalEventCollector::new();
        self.pipeline.step(
            self.gravity,
            &self.params,
            &mut self.islands,
            &mut self.broad_phase,
            &mut self.narrow_phase,
            &mut self.rbodies,
            &mut self.rcolliders,
            &mut self.impulse_joints,
            &mut self.multibody_joints,
            &mut self.ccd_solver,
            &(),
            &event_col,
        );
        for i in 0..n {
            if !self.has_body(i) {
                continue;
            }
            let bt = self.bodies[i].body_type;
            if bt != BodyType::Dynamic && bt != BodyType::Kinematic {
                continue;
            }
            let handle = self.body_handles[i];
            let (tx, ty, vx, vy, angle, angvel) = match self.rbodies.get(handle) {
                Some(rb) => {
                    let t = rb.translation();
                    let v = rb.linvel();
                    (t.x, t.y, v.x, v.y, rb.rotation().angle(), rb.angvel())
                }
                None => continue,
            };
            self.bodies[i].position.x = tx;
            self.bodies[i].position.y = ty;
            self.bodies[i].velocity.x = vx;
            self.bodies[i].velocity.y = vy;
            self.bodies[i].angle = angle;
            self.bodies[i].angular_velocity = angvel;
        }
        self.step_body_altitudes(effective_dt);
        self.step_ballistic_projectiles(effective_dt);
        for event in event_col.drain() {
            let ca = event.collider1();
            let cb = event.collider2();
            let id_a = self.body_for_collider(ca);
            let id_b = self.body_for_collider(cb);
            if let (Some(a), Some(b)) = (id_a, id_b) {
                if event.started() {
                    self.collision_events.push(BodyContact {
                        body_a: BodyId(a),
                        body_b: BodyId(b),
                    });
                    self.begin_contact_events.push((a, b));
                } else {
                    self.end_contact_events.push((a, b));
                }
            }
        }
        if !self.joint_break_forces.is_empty() {
            let breakable: Vec<(usize, ImpulseJointHandle, f32)> = self
                .joint_handles
                .iter()
                .enumerate()
                .filter_map(|(jid, &handle)| {
                    if !self.has_joint(jid) {
                        return None;
                    }
                    let &limit = self.joint_break_forces.get(&jid)?;
                    Some((jid, handle, limit))
                })
                .collect();
            let to_break: Vec<usize> = breakable
                .into_iter()
                .filter_map(|(jid, handle, limit)| {
                    let joint = self.impulse_joints.get(handle)?;
                    let rb1 = self.rbodies.get(joint.body1)?;
                    let rb2 = self.rbodies.get(joint.body2)?;
                    let v1 = rb1.linvel();
                    let v2 = rb2.linvel();
                    let dvx = v1.x - v2.x;
                    let dvy = v1.y - v2.y;
                    let rel_mag = (dvx * dvx + dvy * dvy).sqrt();
                    if rel_mag > limit {
                        Some(jid)
                    } else {
                        None
                    }
                })
                .collect();
            for jid in to_break {
                self.destroy_joint(jid);
            }
        }
        let contact_pairs: Vec<(usize, usize)> = self.begin_contact_events.clone();
        for (a, b) in contact_pairs {
            for (platform_id, mover_id) in [(a, b), (b, a)] {
                if let Some(&Some((nx, ny))) = self.one_way_normals.get(platform_id) {
                    if let Some(handle) = self.active_body_handle(mover_id) {
                        if let Some(rb) = self.rbodies.get_mut(handle) {
                            let cv = rb.linvel();
                            let cdot = cv.x * nx + cv.y * ny;
                            if cdot < 0.0 {
                                rb.set_linvel(
                                    Vector::new(cv.x - cdot * nx, cv.y - cdot * ny),
                                    true,
                                );
                                if let Some(body_mut) = self.bodies.get_mut(mover_id) {
                                    let rv = body_mut.velocity.x * nx + body_mut.velocity.y * ny;
                                    if rv < 0.0 {
                                        body_mut.velocity.x -= rv * nx;
                                        body_mut.velocity.y -= rv * ny;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        self.diagnostics.last_contacts = self.collision_events.len();
    }
    /// Apply a linear impulse `(ix, iy)` to body `id`.
    pub fn apply_impulse(&mut self, id: usize, ix: f32, iy: f32) {
        let effective_mass = self.get_body_mass(id);
        if let Some(body) = self.get_body_mut(id) {
            if body.body_type == BodyType::Dynamic {
                let inv_mass = if effective_mass > 0.0 {
                    1.0 / effective_mass
                } else {
                    0.0
                };
                body.velocity.x += ix * inv_mass;
                body.velocity.y += iy * inv_mass;
            }
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.apply_impulse(Vector::new(ix, iy), true);
            }
        }
    }
    /// Return overlap events collected during the last `step`.
    pub fn get_collision_events(&self) -> &[BodyContact] {
        &self.collision_events
    }
    /// Return body-pair ids that began touching during the last `step`.
    pub fn get_begin_contact_events(&self) -> &[(usize, usize)] {
        &self.begin_contact_events
    }
    /// Return body-pair ids that stopped touching during the last `step`.
    pub fn get_end_contact_events(&self) -> &[(usize, usize)] {
        &self.end_contact_events
    }
    /// Register a trigger zone and return its id.
    pub fn try_add_zone(&mut self, mut zone: PhysicsZone) -> Result<usize, PhysicsError> {
        if self.zones.len() >= self.limits.max_zones {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics zones",
                count: self.zones.len() + 1,
                max: self.limits.max_zones,
            });
        }
        zone.validate()?;
        let id = self.zone_id_counter;
        self.zone_id_counter += 1;
        zone.id = id;
        self.zones.push(zone);
        Ok(id)
    }

    /// Register a trigger zone and return its id.
    pub fn add_zone(&mut self, zone: PhysicsZone) -> usize {
        match self.try_add_zone(zone) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Remove the zone with the given id.
    pub fn remove_zone(&mut self, id: usize) {
        self.zones.retain(|z| z.id != id);
    }
    /// Return a mutable reference to zone `id`, or `None` if not found.
    pub fn zone_mut(&mut self, id: usize) -> Option<&mut PhysicsZone> {
        self.zones.iter_mut().find(|z| z.id == id)
    }
    /// Return an immutable reference to zone `id`, or `None` if not found.
    pub fn zone(&self, id: usize) -> Option<&PhysicsZone> {
        self.zones.iter().find(|z| z.id == id)
    }
    /// Return zone enter/exit events from the last `step`.
    pub fn get_zone_events(&self) -> &[ZoneEvent] {
        &self.zone_events
    }

    /// Add an additive directional gravity vector and return its stable id.
    pub fn try_add_gravity_vector(
        &mut self,
        gx: f32,
        gy: f32,
        layer_mask: u32,
    ) -> Result<usize, PhysicsError> {
        validate_finite("gravity_vector.gx", f64::from(gx))?;
        validate_finite("gravity_vector.gy", f64::from(gy))?;
        let id = self.gravity_vector_id_counter;
        self.gravity_vector_id_counter += 1;
        self.gravity_vectors.push(GravityVector {
            id,
            gx,
            gy,
            layer_mask,
            enabled: true,
        });
        Ok(id)
    }

    /// Add an additive directional gravity vector; returns `0` when validation fails.
    pub fn add_gravity_vector(&mut self, gx: f32, gy: f32, layer_mask: u32) -> usize {
        match self.try_add_gravity_vector(gx, gy, layer_mask) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }

    /// Replace an existing additive gravity vector.
    pub fn try_set_gravity_vector(
        &mut self,
        id: usize,
        gx: f32,
        gy: f32,
        layer_mask: u32,
    ) -> Result<(), PhysicsError> {
        validate_finite("gravity_vector.gx", f64::from(gx))?;
        validate_finite("gravity_vector.gy", f64::from(gy))?;
        let vector = self
            .gravity_vectors
            .iter_mut()
            .find(|vector| vector.id == id && vector.enabled)
            .ok_or(PhysicsError::InvalidGravityVectorReference { vector_id: id })?;
        vector.gx = gx;
        vector.gy = gy;
        vector.layer_mask = layer_mask;
        Ok(())
    }

    /// Replace an existing additive gravity vector; records diagnostics when invalid.
    pub fn set_gravity_vector(&mut self, id: usize, gx: f32, gy: f32, layer_mask: u32) {
        if self.try_set_gravity_vector(id, gx, gy, layer_mask).is_err() {
            self.record_invalid_operation();
        }
    }

    /// Disable and remove one additive gravity vector by id; returns true when removed.
    pub fn remove_gravity_vector(&mut self, id: usize) -> bool {
        if let Some(vector) = self
            .gravity_vectors
            .iter_mut()
            .find(|vector| vector.id == id)
        {
            let was_enabled = vector.enabled;
            vector.enabled = false;
            return was_enabled;
        }
        false
    }

    /// Disable every additive gravity vector.
    pub fn clear_gravity_vectors(&mut self) {
        for vector in &mut self.gravity_vectors {
            vector.enabled = false;
        }
    }

    /// Return an active additive gravity vector by id.
    pub fn get_gravity_vector(&self, id: usize) -> Option<GravityVector> {
        self.gravity_vectors
            .iter()
            .copied()
            .find(|vector| vector.id == id && vector.enabled)
    }

    /// Registers one flow field and returns its stable id.
    pub fn try_add_flow_field(
        &mut self,
        mut field: FlowField,
    ) -> Result<FlowFieldId, PhysicsError> {
        field.validate()?;
        let id = self.flow_field_id_counter;
        self.flow_field_id_counter += 1;
        field.id = id;
        self.flow_fields.push(field);
        Ok(id)
    }

    /// Registers one flow field; returns `0` when validation fails.
    pub fn add_flow_field(&mut self, field: FlowField) -> FlowFieldId {
        match self.try_add_flow_field(field) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }

    /// Returns one immutable flow field by id.
    pub fn flow_field(&self, id: FlowFieldId) -> Option<&FlowField> {
        self.flow_fields
            .iter()
            .find(|field| field.id == id && field.enabled)
    }

    /// Returns one immutable authored flow field by id, even when disabled.
    pub(crate) fn flow_field_slot(&self, id: FlowFieldId) -> Option<&FlowField> {
        self.flow_fields.iter().find(|field| field.id == id)
    }

    /// Returns one mutable flow field by id.
    pub fn flow_field_mut(&mut self, id: FlowFieldId) -> Option<&mut FlowField> {
        self.flow_fields
            .iter_mut()
            .find(|field| field.id == id && field.enabled)
    }

    /// Returns one mutable authored flow field by id, even when disabled.
    pub(crate) fn flow_field_slot_mut(&mut self, id: FlowFieldId) -> Option<&mut FlowField> {
        self.flow_fields.iter_mut().find(|field| field.id == id)
    }

    /// Disables one flow field by id.
    pub fn remove_flow_field(&mut self, id: FlowFieldId) -> bool {
        if let Some(field) = self.flow_fields.iter_mut().find(|field| field.id == id) {
            let was_enabled = field.enabled;
            field.enabled = false;
            return was_enabled;
        }
        false
    }

    /// Disables every registered flow field.
    pub fn clear_flow_fields(&mut self) {
        for field in &mut self.flow_fields {
            field.enabled = false;
        }
    }

    /// Samples combined flow at one world position using an optional layer mask.
    pub fn sample_flow(&self, x: f32, y: f32, layer_mask: Option<u32>) -> FlowSample {
        self.sample_flow_filtered(x, y, layer_mask.unwrap_or(u32::MAX))
    }

    fn sample_flow_filtered(&self, x: f32, y: f32, layer_mask: u32) -> FlowSample {
        let mut contributions = Vec::new();
        let mut combine_mode = FlowCombineMode::Additive;
        let mut clamp_limit: Option<f32> = None;
        for field in &self.flow_fields {
            if !field.enabled || field.layer_mask & layer_mask == 0 {
                continue;
            }
            if let Some(contribution) = field.sample(x, y) {
                if matches!(field.combine, FlowCombineMode::AdditiveClamped) {
                    combine_mode = FlowCombineMode::AdditiveClamped;
                    clamp_limit = Some(
                        clamp_limit
                            .unwrap_or(0.0)
                            .max(field.max_accel.unwrap_or(field.strength)),
                    );
                }
                contributions.push(contribution);
            }
        }
        combine_contributions(contributions, combine_mode, clamp_limit)
    }

    fn apply_acceleration(rb: &mut RigidBody, ax: f32, ay: f32) {
        rb.add_force(Vector::new(rb.mass() * ax, rb.mass() * ay), true);
    }

    fn radial_zone_acceleration(
        zone: &PhysicsZone,
        px: f32,
        py: f32,
        cx: f32,
        cy: f32,
        strength: f32,
        repulsor: bool,
    ) -> Option<(f32, f32)> {
        let mut dx = if repulsor { px - cx } else { cx - px };
        let mut dy = if repulsor { py - cy } else { cy - py };
        let raw_dist = (dx * dx + dy * dy).sqrt();
        if raw_dist <= 1e-6 {
            return None;
        }
        if let Some(outer) = zone.gravity_outer_radius {
            if raw_dist > outer {
                return None;
            }
        }
        let dist = raw_dist.max(zone.gravity_inner_radius);
        dx /= raw_dist;
        dy /= raw_dist;
        let mut accel = match zone.gravity_falloff {
            ZoneGravityFalloff::InverseSquare => strength / (dist * dist),
            ZoneGravityFalloff::Inverse => strength / dist,
            ZoneGravityFalloff::Constant => strength,
            ZoneGravityFalloff::Linear => {
                if let Some(outer) = zone.gravity_outer_radius {
                    let span = (outer - zone.gravity_inner_radius).max(1e-6);
                    let t = ((raw_dist - zone.gravity_inner_radius) / span).clamp(0.0, 1.0);
                    strength * (1.0 - t)
                } else {
                    strength
                }
            }
        };
        if let Some(min) = zone.gravity_min_accel {
            accel = accel.max(min);
        }
        if let Some(max) = zone.gravity_max_accel {
            accel = accel.min(max);
        }
        Some((accel * dx, accel * dy))
    }

    fn zone_gravity_acceleration(zone: &PhysicsZone, px: f32, py: f32) -> Option<(f32, f32)> {
        match zone.gravity_mode {
            ZoneGravityMode::Zero => None,
            ZoneGravityMode::Directional { gx, gy } => Some((gx, gy)),
            ZoneGravityMode::Point { cx, cy, strength } => {
                Self::radial_zone_acceleration(zone, px, py, cx, cy, strength, false)
            }
            ZoneGravityMode::Repulsor { cx, cy, strength } => {
                Self::radial_zone_acceleration(zone, px, py, cx, cy, strength, true)
            }
        }
    }

    fn apply_zone_gravity(rb: &mut RigidBody, zone: &PhysicsZone, px: f32, py: f32) {
        if let Some((ax, ay)) = Self::zone_gravity_acceleration(zone, px, py) {
            Self::apply_acceleration(rb, ax, ay);
        }
    }

    fn apply_zone_drag(rb: &mut RigidBody, zone: &PhysicsZone) {
        let linear = zone.linear_drag.unwrap_or(0.0);
        let quadratic = zone.quadratic_drag.unwrap_or(0.0);
        if linear <= 0.0 && quadratic <= 0.0 {
            return;
        }
        let v = rb.linvel();
        let speed = (v.x * v.x + v.y * v.y).sqrt();
        if speed <= 1e-6 {
            return;
        }
        let coeff = linear + quadratic * speed;
        Self::apply_acceleration(rb, -coeff * v.x, -coeff * v.y);
    }

    /// Apply per-zone gravity/damping/drag and additive world vectors to all bodies; updates zone enter/exit events.
    pub fn apply_zone_forces(&mut self, _dt: f32) {
        self.zone_events.clear();
        let n = self.bodies.len();
        self.sorted_zone_indices.clear();
        self.sorted_zone_indices.extend(0..self.zones.len());
        self.sorted_zone_indices
            .sort_by(|&a, &b| self.zones[b].priority.cmp(&self.zones[a].priority));
        for body_id in 0..n {
            if !self.has_body(body_id) {
                continue;
            }
            let body = &self.bodies[body_id];
            if body.body_type != BodyType::Dynamic {
                continue;
            }
            let px = body.position.x;
            let py = body.position.y;
            let layer = body.layer;
            let handle = self.body_handles[body_id];
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_gravity_scale(self.body_base_gravity_scales[body_id], true);
                rb.set_linear_damping(self.body_base_linear_damping[body_id]);
                rb.set_angular_damping(self.body_base_angular_damping[body_id]);
            }
            let mut current_zones = HashSet::new();
            let mut gravity_override_applied = false;
            let mut linear_override_applied = false;
            let mut angular_override_applied = false;
            for &zi in &self.sorted_zone_indices {
                let zone = &self.zones[zi];
                self.diagnostics.last_zone_checks += 1;
                if !zone.enabled || zone.layer_mask & layer == 0 || !zone.boundary.contains(px, py)
                {
                    continue;
                }
                current_zones.insert(zone.id);
                if let Some(rb) = self.rbodies.get_mut(handle) {
                    if zone.gravity_additive {
                        Self::apply_zone_gravity(rb, zone, px, py);
                    } else if !gravity_override_applied {
                        gravity_override_applied = true;
                        rb.set_gravity_scale(0.0, true);
                        Self::apply_zone_gravity(rb, zone, px, py);
                    }
                    if !linear_override_applied {
                        if let Some(ld) = zone.linear_damping_override {
                            linear_override_applied = true;
                            rb.set_linear_damping(ld);
                        }
                    }
                    if !angular_override_applied {
                        if let Some(ad) = zone.angular_damping_override {
                            angular_override_applied = true;
                            rb.set_angular_damping(ad);
                        }
                    }
                    Self::apply_zone_drag(rb, zone);
                }
            }
            if !gravity_override_applied {
                if let Some(rb) = self.rbodies.get_mut(handle) {
                    for vector in &self.gravity_vectors {
                        if vector.enabled && vector.layer_mask & layer != 0 {
                            Self::apply_acceleration(rb, vector.gx, vector.gy);
                        }
                    }
                }
            }
            let events = self.zone_tracker.update(body_id, current_zones);
            self.zone_events.extend(events);
        }
    }

    /// Applies authored flow fields to dynamic bodies before the solver step.
    pub fn apply_flow_forces(&mut self, _dt: f32) {
        if self.flow_fields.iter().all(|field| !field.enabled) {
            return;
        }
        let n = self.bodies.len();
        for body_id in 0..n {
            if !self.has_body(body_id) {
                continue;
            }
            let body = &self.bodies[body_id];
            if body.body_type != BodyType::Dynamic || !body.flow_influence.enabled {
                continue;
            }
            let handle = self.body_handles[body_id];
            let mut affected = false;
            for field in &self.flow_fields {
                if !field.enabled || field.layer_mask & body.layer == 0 {
                    continue;
                }
                let Some(contribution) = field.sample(body.position.x, body.position.y) else {
                    continue;
                };
                self.diagnostics.last_flow_samples += 1;
                let medium_scale = flow_medium_scale(field.medium, body.flow_influence);
                let scale = (body.flow_influence.flow_scale * medium_scale).max(0.0);
                if scale <= 0.0 {
                    continue;
                }
                if let Some(rb) = self.rbodies.get_mut(handle) {
                    if rb.is_sleeping() {
                        if body.flow_influence.wake_on_flow {
                            rb.wake_up(true);
                        } else {
                            continue;
                        }
                    }
                    let scaled_vx = contribution.vx * scale;
                    let scaled_vy = contribution.vy * scale;
                    match field.application {
                        FlowApplicationMode::Acceleration => {
                            let (ax, ay) =
                                clamp_vector_to_limit(scaled_vx, scaled_vy, field.max_accel);
                            Self::apply_acceleration(rb, ax, ay);
                        }
                        FlowApplicationMode::TargetVelocityDrag => {
                            let flow_v = Vector::new(scaled_vx, scaled_vy);
                            let current = rb.linvel();
                            let coeff = field.drag.max(0.0) * body.flow_influence.cross_section;
                            let mut ax = (flow_v.x - current.x) * coeff;
                            let mut ay = (flow_v.y - current.y) * coeff;
                            (ax, ay) = clamp_vector_to_limit(ax, ay, field.max_accel);
                            Self::apply_acceleration(rb, ax, ay);
                        }
                    }
                    affected = true;
                }
            }
            if affected {
                self.diagnostics.last_flow_affected_bodies += 1;
            }
        }
    }

    /// Run up to `max_steps` fixed substeps using `step_dt`; return steps taken and leftover dt.
    pub fn step_fixed(&mut self, accumulated_dt: f32, step_dt: f32, max_steps: u32) -> (u32, f32) {
        if !accumulated_dt.is_finite() || accumulated_dt <= 0.0 {
            return (0, 0.0);
        }
        if !step_dt.is_finite() || step_dt <= 0.0 {
            return (0, accumulated_dt);
        }
        let steps = ((accumulated_dt / step_dt) as u32).min(max_steps);
        for _ in 0..steps {
            self.step(step_dt);
        }
        let remainder = accumulated_dt - steps as f32 * step_dt;
        (steps, remainder.max(0.0))
    }
    /// Teleport body `id` to world position `(x, y)`.
    pub fn set_body_position(&mut self, id: usize, x: f32, y: f32) {
        if !x.is_finite() || !y.is_finite() {
            self.record_invalid_operation();
            return;
        }
        if let Some(body) = self.get_body_mut(id) {
            body.position.x = x;
            body.position.y = y;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_translation(Vector::new(x, y), true);
            }
        }
    }
    /// Apply a continuous force `(fx, fy)` to body `id` this step.
    pub fn apply_force(&mut self, id: usize, fx: f32, fy: f32) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.add_force(Vector::new(fx, fy), true);
            }
        }
    }
    /// Apply a torque to body `id` this step.
    pub fn apply_torque(&mut self, id: usize, torque: f32) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.add_torque(torque, true);
            }
        }
    }
    /// Set angular velocity of body `id` in radians/second.
    pub fn set_angular_velocity(&mut self, id: usize, omega: f32) {
        if !omega.is_finite() {
            self.record_invalid_operation();
            return;
        }
        if let Some(body) = self.get_body_mut(id) {
            body.angular_velocity = omega;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_angvel(omega, true);
            }
        }
    }
    /// Return angular velocity of body `id` in radians/second; returns 0 if out of range.
    pub fn get_angular_velocity(&self, id: usize) -> f32 {
        self.get_body(id).map_or(0.0, |b| b.angular_velocity)
    }
    /// Return rotation angle of body `id` in radians; returns 0 if out of range.
    pub fn get_body_angle(&self, id: usize) -> f32 {
        self.get_body(id).map_or(0.0, |b| b.angle)
    }
    /// Set the rotation angle of body `id` in radians.
    pub fn set_body_angle(&mut self, id: usize, angle: f32) {
        if !angle.is_finite() {
            self.record_invalid_operation();
            return;
        }
        if let Some(body) = self.get_body_mut(id) {
            body.angle = angle;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_rotation(Rotation::new(angle), true);
            }
        }
    }
    /// Return the mass of body `id`; returns 0 if out of range.
    pub fn get_body_mass(&self, id: usize) -> f32 {
        if let Some(Some(mass)) = self.body_mass_overrides.get(id) {
            return *mass;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.mass();
            }
        }
        self.get_body(id).map_or(0.0, |b| b.mass)
    }
    /// Override mass of body `id`. This function is part of the public API.
    pub fn set_body_mass(&mut self, id: usize, mass: f32) {
        if !mass.is_finite() || mass <= 0.0 {
            self.record_invalid_operation();
            return;
        }
        self.set_body_mass_override_internal(id, Some(mass));
    }
    /// Set gravity scale multiplier on body `id`.
    pub fn set_gravity_scale(&mut self, id: usize, scale: f32) {
        if !scale.is_finite() {
            self.record_invalid_operation();
            return;
        }
        if let Some(base) = self.body_base_gravity_scales.get_mut(id) {
            *base = scale;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_gravity_scale(scale, true);
            }
        }
        self.sync_body_material_snapshot(id);
    }
    /// Lock or unlock rotation for body `id`.
    pub fn set_fixed_rotation(&mut self, id: usize, fixed: bool) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_enabled_rotations(false, false, !fixed, true);
            }
        }
    }
    /// Set linear damping coefficient on body `id`.
    pub fn set_linear_damping(&mut self, id: usize, damping: f32) {
        if !damping.is_finite() || damping < 0.0 {
            self.record_invalid_operation();
            return;
        }
        if let Some(base) = self.body_base_linear_damping.get_mut(id) {
            *base = damping;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_linear_damping(damping);
            }
        }
        self.sync_body_material_snapshot(id);
    }
    /// Set angular damping coefficient on body `id`.
    pub fn set_angular_damping(&mut self, id: usize, damping: f32) {
        if !damping.is_finite() || damping < 0.0 {
            self.record_invalid_operation();
            return;
        }
        if let Some(base) = self.body_base_angular_damping.get_mut(id) {
            *base = damping;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_angular_damping(damping);
            }
        }
        self.sync_body_material_snapshot(id);
    }
    /// Return gravity scale of body `id`; returns 1.0 if out of range.
    pub fn get_gravity_scale(&self, id: usize) -> f32 {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.gravity_scale();
            }
        }
        1.0
    }
    /// Return true if rotation is locked on body `id`.
    pub fn is_fixed_rotation(&self, id: usize) -> bool {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.is_rotation_locked();
            }
        }
        false
    }
    /// Return linear damping of body `id`; returns 0 if out of range.
    pub fn get_linear_damping(&self, id: usize) -> f32 {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.linear_damping();
            }
        }
        0.0
    }
    /// Return angular damping of body `id`; returns 0 if out of range.
    pub fn get_angular_damping(&self, id: usize) -> f32 {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.angular_damping();
            }
        }
        0.0
    }
    /// Enable or disable CCD (continuous collision detection) on body `id`.
    pub fn set_bullet(&mut self, id: usize, bullet: bool) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.enable_ccd(bullet);
            }
            if let Some(body) = self.bodies.get_mut(id) {
                body.bullet = bullet;
            }
        }
    }
    /// Return true if CCD is enabled on body `id`.
    pub fn is_bullet(&self, id: usize) -> bool {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.is_ccd_enabled();
            }
        }
        self.bodies.get(id).map(|body| body.bullet).unwrap_or(false)
    }
    /// Set the maximum number of CCD substeps used by the solver. Minimum value is `1`.
    pub fn set_ccd_substeps(&mut self, max_substeps: usize) {
        self.params.max_ccd_substeps = max_substeps.max(1);
    }
    /// Return the configured maximum number of CCD substeps.
    pub fn get_ccd_substeps(&self) -> usize {
        self.params.max_ccd_substeps
    }
    /// Apply force `(fx, fy)` at world point `(px, py)` on body `id`.
    pub fn apply_force_at_point(&mut self, id: usize, fx: f32, fy: f32, px: f32, py: f32) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.add_force_at_point(Vector::new(fx, fy), Vector::new(px, py), true);
            }
        }
    }
    /// Apply an angular impulse to body `id`.
    pub fn apply_angular_impulse(&mut self, id: usize, impulse: f32) {
        let new_angvel = if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.apply_torque_impulse(impulse, true);
                Some(rb.angvel())
            } else {
                None
            }
        } else {
            None
        };
        if let Some(new_angvel) = new_angvel {
            if let Some(body) = self.get_body_mut(id) {
                body.angular_velocity = new_angvel;
            }
        }
    }
    /// Return all valid body ids as a `Vec`.
    pub fn get_body_ids(&self) -> Vec<usize> {
        self.body_active
            .iter()
            .enumerate()
            .filter_map(|(id, &active)| active.then_some(id))
            .collect()
    }
    /// Return all valid joint ids as a `Vec`.
    pub fn get_joint_ids(&self) -> Vec<usize> {
        self.joint_active
            .iter()
            .enumerate()
            .filter_map(|(id, &active)| active.then_some(id))
            .collect()
    }
    /// Return the body-type string of `id`; returns "dynamic" if out of range.
    pub fn get_body_type_str(&self, id: usize) -> &'static str {
        if !self.has_body(id) {
            return "dynamic";
        }
        self.bodies
            .get(id)
            .map_or("dynamic", |b| match b.body_type {
                BodyType::Static => "static",
                BodyType::Dynamic => "dynamic",
                BodyType::Kinematic => "kinematic",
                BodyType::Sensor => "sensor",
            })
    }
    /// Change the body type of `id` and rebuild its collider.
    pub fn set_body_type(&mut self, id: usize, bt: BodyType) {
        if !self.has_body(id) {
            return;
        }
        if let Some(body) = self.bodies.get_mut(id) {
            body.body_type = bt;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_body_type(Self::rapier_body_type(bt), true);
            }
        }
        if id < self.bodies.len() {
            self.rebuild_collider(id);
        }
    }
    /// Return world gravity as `(gx, gy)`.
    pub fn get_gravity(&self) -> (f32, f32) {
        (self.gravity.x, self.gravity.y)
    }
    /// Set world gravity to `(gx, gy)`.
    pub fn set_gravity(&mut self, gx: f32, gy: f32) {
        self.gravity = Vector::new(gx, gy);
    }
    /// Remove all bodies, joints, and zones; reset rapier sets.
    pub fn clear(&mut self) {
        self.bodies.clear();
        self.body_handles.clear();
        self.body_active.clear();
        self.collider_handles.clear();
        self.extra_collider_handles.clear();
        self.collider_to_body.clear();
        self.cached_shapes.clear();
        self.cached_restitutions.clear();
        self.cached_layers.clear();
        self.cached_frictions.clear();
        self.joint_handles.clear();
        self.joint_active.clear();
        self.joint_types.clear();
        self.mouse_joint_anchors.clear();
        self.collision_events.clear();
        self.begin_contact_events.clear();
        self.end_contact_events.clear();
        self.rbodies = RigidBodySet::new();
        self.rcolliders = ColliderSet::new();
        self.impulse_joints = ImpulseJointSet::new();
        self.multibody_joints = MultibodyJointSet::new();
        self.islands = IslandManager::new();
        self.broad_phase = BroadPhaseBvh::new();
        self.narrow_phase = NarrowPhase::new();
        self.joint_break_forces.clear();
        self.one_way_normals.clear();
        self.body_dirty_sync.clear();
        self.body_base_gravity_scales.clear();
        self.body_base_linear_damping.clear();
        self.body_base_angular_damping.clear();
        self.body_mass_overrides.clear();
        self.body_materials.clear();
        self.fixture_materials.clear();
        self.body_altitudes.clear();
        self.ballistic_projectiles.clear();
        self.ballistic_projectile_hits.clear();
        self.zones.clear();
        self.gravity_vectors.clear();
        self.flow_fields.clear();
        self.gravity_vector_id_counter = 0;
        self.zone_id_counter = 0;
        self.flow_field_id_counter = 0;
        self.zone_tracker.clear();
        self.zone_events.clear();
        self.rebuild_scratch.clear();
        self.sync_scratch.clear();
        self.sorted_zone_indices.clear();
    }

    /// Fully reset the world to its post-construction state, including solver settings and gravity.
    pub fn reset_world(&mut self) {
        let default_gravity = self.default_gravity;
        *self = World::new(default_gravity.x, default_gravity.y);
    }
    /// Allow or permanently prevent sleeping for body `id`.
    pub fn set_sleeping_allowed(&mut self, id: usize, allowed: bool) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                if allowed {
                    *rb.activation_mut() = RigidBodyActivation::default();
                } else {
                    *rb.activation_mut() = RigidBodyActivation::cannot_sleep();
                    rb.wake_up(true);
                }
            }
        }
    }
    /// Return true if body `id` is permitted to sleep.
    pub fn is_sleeping_allowed(&self, id: usize) -> bool {
        self.active_body_handle(id)
            .and_then(|h| self.rbodies.get(h))
            .map(|rb| rb.activation().angular_threshold >= 0.0)
            .unwrap_or(true)
    }
    /// Disable body `id`; it will no longer participate in simulation.
    pub fn destroy_body(&mut self, id: usize) {
        if !self.has_body(id) {
            return;
        }
        if let Some(extras) = self.extra_collider_handles.get(id) {
            let extra_handles: Vec<ColliderHandle> = extras.clone();
            for h in extra_handles {
                self.rcolliders
                    .remove(h, &mut self.islands, &mut self.rbodies, true);
                self.collider_to_body.remove(&h);
            }
        }
        if id < self.extra_collider_handles.len() {
            self.extra_collider_handles[id].clear();
        }
        self.fixture_materials
            .retain(|(body_id, _), _| *body_id != id);
        let body_handle = self.active_body_handle(id);
        if let Some(handle) = body_handle {
            let joints_to_destroy: Vec<usize> = self
                .joint_handles
                .iter()
                .enumerate()
                .filter_map(|(jid, &joint_handle)| {
                    if !self.has_joint(jid) {
                        return None;
                    }
                    let joint = self.impulse_joints.get(joint_handle)?;
                    (joint.body1 == handle || joint.body2 == handle).then_some(jid)
                })
                .collect();
            for jid in joints_to_destroy {
                self.destroy_joint(jid);
            }
        }
        if let Some(&primary) = self.collider_handles.get(id) {
            self.rcolliders
                .remove(primary, &mut self.islands, &mut self.rbodies, true);
            self.collider_to_body.remove(&primary);
        }
        if let Some(handle) = body_handle {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_enabled(false);
            }
        }
        self.bodies[id].body_type = BodyType::Static;
        self.body_active[id] = false;
        self.zone_tracker.remove_body(id);
        self.one_way_normals[id] = None;
        self.clear_body_altitude_state(id);
    }
    /// Set linear velocity of body `id` in world units per second.
    pub fn set_body_velocity(&mut self, id: usize, vx: f32, vy: f32) {
        if !vx.is_finite() || !vy.is_finite() {
            self.record_invalid_operation();
            return;
        }
        if let Some(body) = self.get_body_mut(id) {
            body.velocity.x = vx;
            body.velocity.y = vy;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_linvel(Vector::new(vx, vy), true);
            }
        }
    }
    /// Reflect body `id` velocity around the supplied world-space surface normal.
    ///
    /// Returns `true` when the velocity was updated, or `false` when the body has no
    /// meaningful velocity or the normal is degenerate.
    pub fn reflect_body_velocity(
        &mut self,
        id: usize,
        normal_x: f32,
        normal_y: f32,
        coefficient: f32,
    ) -> bool {
        self.try_reflect_body_velocity(id, normal_x, normal_y, coefficient)
            .unwrap_or(false)
    }
    /// Reflect body `id` velocity around the supplied world-space surface normal.
    pub fn try_reflect_body_velocity(
        &mut self,
        id: usize,
        normal_x: f32,
        normal_y: f32,
        coefficient: f32,
    ) -> Result<bool, PhysicsError> {
        validate_finite("normal_x", f64::from(normal_x))?;
        validate_finite("normal_y", f64::from(normal_y))?;
        validate_finite("coefficient", f64::from(coefficient))?;
        if !(0.0..=1.0).contains(&coefficient) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "coefficient",
                min: 0.0,
                max: 1.0,
                value: f64::from(coefficient),
            });
        }
        let current_velocity = self
            .get_body(id)
            .map(|body| body.velocity)
            .ok_or(PhysicsError::InvalidBodyReference { body_id: id })?;
        if current_velocity.x * current_velocity.x + current_velocity.y * current_velocity.y
            <= 1e-12
        {
            return Ok(false);
        }
        let Some(reflected_dir) = Self::reflect_vector(
            Vector::new(current_velocity.x, current_velocity.y),
            Vector::new(normal_x, normal_y),
        ) else {
            return Ok(false);
        };
        let speed = (current_velocity.x * current_velocity.x
            + current_velocity.y * current_velocity.y)
            .sqrt();
        let new_velocity = Vector::new(
            reflected_dir.x * speed * coefficient,
            reflected_dir.y * speed * coefficient,
        );
        if let Some(body) = self.get_body_mut(id) {
            body.velocity.x = new_velocity.x;
            body.velocity.y = new_velocity.y;
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.set_linvel(new_velocity, true);
            }
        }
        Ok(true)
    }
}
