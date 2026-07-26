//! Owns the physics world bodies implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics world bodies data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics world bodies behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics world bodies defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near physics world bodies state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping physics world bodies calculations at their owning subsystem boundary.
//! Provides local adaptation layer that lets callers reuse physics world bodies rules without duplicating engine decisions.

use super::*;

impl World {
    /// Insert a strictly validated body without exceeding the active-body ceiling.
    pub fn try_add_body(&mut self, body: Body) -> Result<BodyId, PhysicsError> {
        body.validate(&self.limits)?;
        let count = self.body_count().saturating_add(1);
        if count > self.limits.max_bodies {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics bodies",
                count,
                max: self.limits.max_bodies,
            });
        }
        let slots = self.bodies.len().saturating_add(1);
        if slots > self.limits.max_body_slots {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics body slots",
                count: slots,
                max: self.limits.max_body_slots,
            });
        }
        Ok(self.add_body_unchecked(body))
    }

    /// Insert a body into the world and return its id.
    ///
    /// This compatibility helper records a rejected insertion. Lua-facing and bulk
    /// construction must use [`World::try_add_body`] so callers receive the error.
    pub fn add_body(&mut self, body: Body) -> BodyId {
        match self.try_add_body(body) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                BodyId(usize::MAX)
            }
        }
    }

    pub(crate) fn add_body_unchecked(&mut self, body: Body) -> BodyId {
        let id = self.bodies.len();
        let material = Self::default_body_material_for(&body);
        let rb = RigidBodyBuilder::new(Self::rapier_body_type(body.body_type))
            .translation(Vector::new(body.position.x, body.position.y))
            .linvel(Vector::new(body.velocity.x, body.velocity.y))
            .ccd_enabled(body.bullet)
            .build();
        let body_handle = self.rbodies.insert(rb);
        let collider = self.make_collider(&body, &material);
        let collider_handle =
            self.rcolliders
                .insert_with_parent(collider, body_handle, &mut self.rbodies);
        self.cached_shapes.push(body.shape);
        self.cached_restitutions.push(body.restitution);
        self.cached_frictions.push(body.friction);
        self.cached_layers.push((body.layer, body.mask));
        self.body_handles.push(body_handle);
        self.body_active.push(true);
        self.collider_handles.push(collider_handle);
        self.extra_collider_handles.push(Vec::new());
        self.collider_to_body.insert(collider_handle, id);
        self.bodies.push(body);
        self.one_way_normals.push(None);
        self.body_dirty_sync.push(false);
        self.body_base_gravity_scales.push(1.0);
        self.body_base_linear_damping
            .push(self.top_down_linear_damping);
        self.body_base_angular_damping
            .push(self.top_down_angular_damping);
        if self.top_down_linear_damping > 0.0 {
            if let Some(rb) = self.rbodies.get_mut(body_handle) {
                rb.set_linear_damping(self.top_down_linear_damping);
            }
        }
        if self.top_down_angular_damping > 0.0 {
            if let Some(rb) = self.rbodies.get_mut(body_handle) {
                rb.set_angular_damping(self.top_down_angular_damping);
            }
        }
        self.body_mass_overrides.push(None);
        self.body_materials.push(material);
        BodyId(id)
    }
    /// Add an extra collider shape to an existing body using strict validation.
    pub fn try_add_fixture(
        &mut self,
        body_id: usize,
        shape: Shape,
        density: f32,
        friction: f32,
        restitution: f32,
        sensor: bool,
    ) -> Result<usize, PhysicsError> {
        let body_handle = self.active_body_handle_result(body_id)?;
        let body = self
            .bodies
            .get(body_id)
            .ok_or(PhysicsError::InvalidBodyReference { body_id })?;
        if self.extra_collider_handles[body_id].len() >= self.limits.max_colliders_per_body {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics fixtures",
                count: self.extra_collider_handles[body_id].len() + 1,
                max: self.limits.max_colliders_per_body,
            });
        }
        shape.validate(&self.limits)?;
        Self::validate_fixture_material(density, friction, restitution)?;
        let builder = shape
            .to_rapier_collider()
            .ok_or(PhysicsError::DegenerateGeometry {
                context: "physics fixture",
                detail: "shape could not produce a rapier collider",
            })?;
        let collider = builder
            .density(density)
            .friction(friction)
            .restitution(restitution)
            .sensor(sensor)
            .collision_groups(self.collision_groups(body.layer, body.mask))
            .active_events(ActiveEvents::COLLISION_EVENTS)
            .build();
        let handle = self
            .rcolliders
            .insert_with_parent(collider, body_handle, &mut self.rbodies);
        self.collider_to_body.insert(handle, body_id);
        let extras = &mut self.extra_collider_handles[body_id];
        extras.push(handle);
        let fixture_index = extras.len();
        self.fixture_materials.insert(
            (body_id, fixture_index),
            Self::default_fixture_material(density, friction, restitution),
        );
        Ok(fixture_index)
    }

    /// Add an extra collider shape to an existing body; returns the fixture index.
    pub fn add_fixture(
        &mut self,
        body_id: usize,
        shape: Shape,
        density: f32,
        friction: f32,
        restitution: f32,
        sensor: bool,
    ) -> usize {
        match self.try_add_fixture(body_id, shape, density, friction, restitution, sensor) {
            Ok(index) => index,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Return the number of colliders attached to `body_id`.
    pub fn fixture_count(&self, body_id: usize) -> usize {
        if !self.has_body(body_id) {
            return 0;
        }
        1 + self.extra_collider_handles[body_id].len()
    }
    /// Set friction on a specific fixture of `body_id` using strict validation.
    pub fn try_set_fixture_friction(
        &mut self,
        body_id: usize,
        fixture_idx: usize,
        friction: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("friction", f64::from(friction))?;
        if !(0.0..=1.0).contains(&friction) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "friction",
                min: 0.0,
                max: 1.0,
                value: f64::from(friction),
            });
        }
        let handle = if fixture_idx == 0 {
            self.collider_handles.get(body_id).copied()
        } else {
            self.extra_collider_handles
                .get(body_id)
                .and_then(|v| v.get(fixture_idx - 1))
                .copied()
        }
        .ok_or(PhysicsError::InvalidFixtureReference {
            body_id,
            fixture_index: fixture_idx,
        })?;
        let collider =
            self.rcolliders
                .get_mut(handle)
                .ok_or(PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                })?;
        collider.set_friction(friction);
        if fixture_idx == 0 {
            if let Some(body) = self.get_body_mut(body_id) {
                body.friction = friction;
            }
            self.sync_body_material_snapshot(body_id);
        } else if let Some(material) = self.fixture_materials.get_mut(&(body_id, fixture_idx)) {
            material.friction = friction;
        }
        Ok(())
    }

    /// Set friction on a specific fixture of `body_id`.
    pub fn set_fixture_friction(&mut self, body_id: usize, fixture_idx: usize, friction: f32) {
        if self
            .try_set_fixture_friction(body_id, fixture_idx, friction)
            .is_err()
        {
            self.record_invalid_operation();
        }
    }
    /// Set restitution (bounciness) on a specific fixture of `body_id`.
    pub fn try_set_fixture_restitution(
        &mut self,
        body_id: usize,
        fixture_idx: usize,
        restitution: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("restitution", f64::from(restitution))?;
        if !(0.0..=1.0).contains(&restitution) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "restitution",
                min: 0.0,
                max: 1.0,
                value: f64::from(restitution),
            });
        }
        let handle = if fixture_idx == 0 {
            self.collider_handles.get(body_id).copied()
        } else {
            self.extra_collider_handles
                .get(body_id)
                .and_then(|v| v.get(fixture_idx - 1))
                .copied()
        }
        .ok_or(PhysicsError::InvalidFixtureReference {
            body_id,
            fixture_index: fixture_idx,
        })?;
        let collider =
            self.rcolliders
                .get_mut(handle)
                .ok_or(PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                })?;
        collider.set_restitution(restitution);
        if fixture_idx == 0 {
            if let Some(body) = self.get_body_mut(body_id) {
                body.restitution = restitution;
            }
            self.sync_body_material_snapshot(body_id);
        } else if let Some(material) = self.fixture_materials.get_mut(&(body_id, fixture_idx)) {
            material.restitution = restitution;
        }
        Ok(())
    }

    /// Set restitution (bounciness) on a specific fixture of `body_id`.
    pub fn set_fixture_restitution(
        &mut self,
        body_id: usize,
        fixture_idx: usize,
        restitution: f32,
    ) {
        if self
            .try_set_fixture_restitution(body_id, fixture_idx, restitution)
            .is_err()
        {
            self.record_invalid_operation();
        }
    }
    /// Enable or disable the sensor flag on a specific fixture of `body_id` using strict validation.
    pub fn try_set_fixture_sensor(
        &mut self,
        body_id: usize,
        fixture_idx: usize,
        sensor: bool,
    ) -> Result<(), PhysicsError> {
        let handle = if fixture_idx == 0 {
            self.collider_handles.get(body_id).copied()
        } else {
            self.extra_collider_handles
                .get(body_id)
                .and_then(|v| v.get(fixture_idx - 1))
                .copied()
        }
        .ok_or(PhysicsError::InvalidFixtureReference {
            body_id,
            fixture_index: fixture_idx,
        })?;
        let collider =
            self.rcolliders
                .get_mut(handle)
                .ok_or(PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                })?;
        collider.set_sensor(sensor);
        Ok(())
    }

    /// Enable or disable the sensor flag on a specific fixture of `body_id`.
    pub fn set_fixture_sensor(&mut self, body_id: usize, fixture_idx: usize, sensor: bool) {
        if self
            .try_set_fixture_sensor(body_id, fixture_idx, sensor)
            .is_err()
        {
            self.record_invalid_operation();
        }
    }

    /// Enable or disable a live body and all of its solver participation.
    pub fn try_set_body_enabled(
        &mut self,
        body_id: usize,
        enabled: bool,
    ) -> Result<(), PhysicsError> {
        if !self.has_body(body_id) {
            return Err(PhysicsError::InvalidBodyReference { body_id });
        }
        let handle = self
            .active_body_handle(body_id)
            .ok_or(PhysicsError::InvalidBodyReference { body_id })?;
        let body = self
            .rbodies
            .get_mut(handle)
            .ok_or(PhysicsError::InvalidBodyReference { body_id })?;
        body.set_enabled(enabled);
        Ok(())
    }

    /// Return whether a live body's Rapier owner is enabled.
    pub fn is_body_enabled(&self, body_id: usize) -> Result<bool, PhysicsError> {
        if !self.has_body(body_id) {
            return Err(PhysicsError::InvalidBodyReference { body_id });
        }
        let handle = self
            .active_body_handle(body_id)
            .ok_or(PhysicsError::InvalidBodyReference { body_id })?;
        self.rbodies
            .get(handle)
            .map(|body| body.is_enabled())
            .ok_or(PhysicsError::InvalidBodyReference { body_id })
    }

    /// Enable or disable one primary or extra fixture without changing sensor state.
    pub fn try_set_fixture_enabled(
        &mut self,
        body_id: usize,
        fixture_idx: usize,
        enabled: bool,
    ) -> Result<(), PhysicsError> {
        if !self.has_body(body_id) {
            return Err(PhysicsError::InvalidBodyReference { body_id });
        }
        let handle = if fixture_idx == 0 {
            self.collider_handles.get(body_id).copied()
        } else {
            self.extra_collider_handles
                .get(body_id)
                .and_then(|handles| handles.get(fixture_idx - 1))
                .copied()
        }
        .ok_or(PhysicsError::InvalidFixtureReference {
            body_id,
            fixture_index: fixture_idx,
        })?;
        let collider =
            self.rcolliders
                .get_mut(handle)
                .ok_or(PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                })?;
        collider.set_enabled(enabled);
        Ok(())
    }

    /// Return whether one live fixture participates in queries and simulation.
    pub fn is_fixture_enabled(
        &self,
        body_id: usize,
        fixture_idx: usize,
    ) -> Result<bool, PhysicsError> {
        if !self.has_body(body_id) {
            return Err(PhysicsError::InvalidBodyReference { body_id });
        }
        let handle = if fixture_idx == 0 {
            self.collider_handles.get(body_id).copied()
        } else {
            self.extra_collider_handles
                .get(body_id)
                .and_then(|handles| handles.get(fixture_idx - 1))
                .copied()
        }
        .ok_or(PhysicsError::InvalidFixtureReference {
            body_id,
            fixture_index: fixture_idx,
        })?;
        self.rcolliders
            .get(handle)
            .map(|collider| collider.is_enabled())
            .ok_or(PhysicsError::InvalidFixtureReference {
                body_id,
                fixture_index: fixture_idx,
            })
    }
    /// Return a shared reference to body `id`, or `None` if out of range.
    pub fn get_body(&self, id: usize) -> Option<&Body> {
        self.has_body(id).then(|| self.bodies.get(id)).flatten()
    }
    /// Return a mutable reference to body `id`, or `None` if out of range.
    pub fn get_body_mut(&mut self, id: usize) -> Option<&mut Body> {
        if self.has_body(id) {
            self.bodies.get_mut(id)
        } else {
            None
        }
    }
    /// Return the current body-default material snapshot for `id`.
    pub fn get_body_material(&self, id: usize) -> Option<PhysicsMaterial> {
        self.has_body(id)
            .then(|| self.body_materials.get(id).cloned())
            .flatten()
    }
    /// Apply a body-default material to the primary collider and body-owned solver properties.
    pub fn try_set_body_material(
        &mut self,
        id: usize,
        material: PhysicsMaterial,
    ) -> Result<(), PhysicsError> {
        material.validate()?;
        {
            let body = self
                .get_body_mut(id)
                .ok_or(PhysicsError::InvalidBodyReference { body_id: id })?;
            body.friction = material.friction;
            body.restitution = material.restitution;
            body.beam_reflectivity = material.beam_reflectivity;
            body.projectile_reflectivity = material.projectile_reflectivity;
        }
        let handle = self
            .collider_handles
            .get(id)
            .copied()
            .ok_or(PhysicsError::InvalidBodyReference { body_id: id })?;
        let collider = self
            .rcolliders
            .get_mut(handle)
            .ok_or(PhysicsError::InvalidBodyReference { body_id: id })?;
        collider.set_density(material.density);
        collider.set_friction(material.friction);
        collider.set_restitution(material.restitution);
        collider
            .set_friction_combine_rule(Self::material_combine_rule(material.friction_combine_rule));
        collider.set_restitution_combine_rule(Self::material_combine_rule(
            material.restitution_combine_rule,
        ));
        if let Some(scale) = material.gravity_scale {
            self.set_gravity_scale(id, scale);
        }
        if let Some(damping) = material.linear_damping {
            self.set_linear_damping(id, damping);
        }
        if let Some(damping) = material.angular_damping {
            self.set_angular_damping(id, damping);
        }
        self.set_body_mass_override_internal(id, material.mass_override);
        if let Some(slot) = self.body_materials.get_mut(id) {
            *slot = material;
        }
        self.cached_frictions[id] = self.bodies[id].friction;
        self.cached_restitutions[id] = self.bodies[id].restitution;
        self.sync_body_material_snapshot(id);
        Ok(())
    }
    /// Return the current material snapshot for one fixture.
    pub fn get_fixture_material(
        &self,
        body_id: usize,
        fixture_idx: usize,
    ) -> Result<PhysicsMaterial, PhysicsError> {
        if !self.has_body(body_id) {
            return Err(PhysicsError::InvalidBodyReference { body_id });
        }
        if fixture_idx == 0 {
            return self
                .get_body_material(body_id)
                .map(|material| material.fixture_scope())
                .ok_or(PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                });
        }
        self.fixture_materials
            .get(&(body_id, fixture_idx))
            .cloned()
            .ok_or(PhysicsError::InvalidFixtureReference {
                body_id,
                fixture_index: fixture_idx,
            })
    }
    /// Apply one material snapshot to a fixture without disturbing unrelated fixtures.
    pub fn try_set_fixture_material(
        &mut self,
        body_id: usize,
        fixture_idx: usize,
        material: PhysicsMaterial,
    ) -> Result<(), PhysicsError> {
        let material = material.fixture_scope();
        material.validate()?;
        if fixture_idx == 0 {
            {
                let body = self
                    .get_body_mut(body_id)
                    .ok_or(PhysicsError::InvalidBodyReference { body_id })?;
                body.friction = material.friction;
                body.restitution = material.restitution;
                body.beam_reflectivity = material.beam_reflectivity;
                body.projectile_reflectivity = material.projectile_reflectivity;
            }
            let handle = self.collider_handles.get(body_id).copied().ok_or(
                PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                },
            )?;
            let collider =
                self.rcolliders
                    .get_mut(handle)
                    .ok_or(PhysicsError::InvalidFixtureReference {
                        body_id,
                        fixture_index: fixture_idx,
                    })?;
            collider.set_density(material.density);
            collider.set_friction(material.friction);
            collider.set_restitution(material.restitution);
            collider.set_friction_combine_rule(Self::material_combine_rule(
                material.friction_combine_rule,
            ));
            collider.set_restitution_combine_rule(Self::material_combine_rule(
                material.restitution_combine_rule,
            ));
            if let Some(slot) = self.body_materials.get_mut(body_id) {
                slot.name = material.name;
                slot.density = material.density;
                slot.friction = material.friction;
                slot.restitution = material.restitution;
                slot.friction_combine_rule = material.friction_combine_rule;
                slot.restitution_combine_rule = material.restitution_combine_rule;
                slot.stickiness = material.stickiness;
                slot.adhesion = material.adhesion;
                slot.beam_reflectivity = material.beam_reflectivity;
                slot.projectile_reflectivity = material.projectile_reflectivity;
                slot.beam_absorption = material.beam_absorption;
                slot.buoyancy = material.buoyancy;
                slot.surface_type = material.surface_type;
            }
            self.cached_frictions[body_id] = self.bodies[body_id].friction;
            self.cached_restitutions[body_id] = self.bodies[body_id].restitution;
            return Ok(());
        }
        let handle = self
            .extra_collider_handles
            .get(body_id)
            .and_then(|handles| handles.get(fixture_idx - 1))
            .copied()
            .ok_or(PhysicsError::InvalidFixtureReference {
                body_id,
                fixture_index: fixture_idx,
            })?;
        let collider =
            self.rcolliders
                .get_mut(handle)
                .ok_or(PhysicsError::InvalidFixtureReference {
                    body_id,
                    fixture_index: fixture_idx,
                })?;
        collider.set_density(material.density);
        collider.set_friction(material.friction);
        collider.set_restitution(material.restitution);
        collider
            .set_friction_combine_rule(Self::material_combine_rule(material.friction_combine_rule));
        collider.set_restitution_combine_rule(Self::material_combine_rule(
            material.restitution_combine_rule,
        ));
        self.fixture_materials
            .insert((body_id, fixture_idx), material);
        Ok(())
    }
    /// Set a body's primary friction coefficient.
    pub fn set_body_friction(&mut self, id: usize, friction: f32) {
        if !friction.is_finite() || !(0.0..=1.0).contains(&friction) {
            self.record_invalid_operation();
            return;
        }
        if let Some(body) = self.get_body_mut(id) {
            body.friction = friction;
        }
        if id < self.cached_frictions.len() {
            self.cached_frictions[id] = friction;
        }
        self.sync_body_material_snapshot(id);
    }
    /// Set a body's primary restitution coefficient.
    pub fn set_body_restitution(&mut self, id: usize, restitution: f32) {
        if !restitution.is_finite() || !(0.0..=1.0).contains(&restitution) {
            self.record_invalid_operation();
            return;
        }
        if let Some(body) = self.get_body_mut(id) {
            body.restitution = restitution;
        }
        if id < self.cached_restitutions.len() {
            self.cached_restitutions[id] = restitution;
        }
        self.sync_body_material_snapshot(id);
    }
    /// Return whether body `id` acts as a reflective mirror for beam tracing.
    pub fn is_body_mirror(&self, id: usize) -> bool {
        self.get_body(id).is_some_and(|body| body.reflective)
    }
    /// Enable or disable mirror-style beam reflection on body `id`.
    pub fn set_body_mirror(&mut self, id: usize, reflective: bool) {
        if let Some(body) = self.get_body_mut(id) {
            body.reflective = reflective;
        }
        self.sync_body_material_snapshot(id);
    }
    /// Return the beam reflectivity multiplier for body `id`.
    pub fn get_body_beam_reflectivity(&self, id: usize) -> f32 {
        self.get_body(id)
            .map_or(1.0, |body| Self::clamp_reflectivity(body.beam_reflectivity))
    }
    /// Update the beam reflectivity multiplier for body `id`.
    pub fn try_set_body_beam_reflectivity(
        &mut self,
        id: usize,
        reflectivity: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("reflectivity", f64::from(reflectivity))?;
        if !(0.0..=1.0).contains(&reflectivity) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "reflectivity",
                min: 0.0,
                max: 1.0,
                value: f64::from(reflectivity),
            });
        }
        let body = self
            .get_body_mut(id)
            .ok_or(PhysicsError::InvalidBodyReference { body_id: id })?;
        body.beam_reflectivity = reflectivity;
        let _ = body;
        self.sync_body_material_snapshot(id);
        Ok(())
    }
    /// Return the projectile reflectivity multiplier for body `id`.
    pub fn get_body_projectile_reflectivity(&self, id: usize) -> f32 {
        self.get_body(id).map_or(1.0, |body| {
            Self::clamp_reflectivity(body.projectile_reflectivity)
        })
    }
    /// Update the projectile reflectivity multiplier for body `id`.
    pub fn try_set_body_projectile_reflectivity(
        &mut self,
        id: usize,
        reflectivity: f32,
    ) -> Result<(), PhysicsError> {
        validate_finite("reflectivity", f64::from(reflectivity))?;
        if !(0.0..=1.0).contains(&reflectivity) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "reflectivity",
                min: 0.0,
                max: 1.0,
                value: f64::from(reflectivity),
            });
        }
        let body = self
            .get_body_mut(id)
            .ok_or(PhysicsError::InvalidBodyReference { body_id: id })?;
        body.projectile_reflectivity = reflectivity;
        let _ = body;
        self.sync_body_material_snapshot(id);
        Ok(())
    }
    /// Set a body's collision layer bitmask and immediately refresh its colliders.
    pub fn set_body_layer(&mut self, id: usize, layer: u32) {
        if let Some(body) = self.get_body_mut(id) {
            body.layer = layer;
            self.sync_body_collision_groups(id);
        }
    }
    /// Set a body's collision mask bitmask and immediately refresh its colliders.
    pub fn set_body_mask(&mut self, id: usize, mask: u32) {
        if let Some(body) = self.get_body_mut(id) {
            body.mask = mask;
            self.sync_body_collision_groups(id);
        }
    }
    /// Assign `id` to one world-level collision group and allow all 16 group targets locally.
    pub fn try_set_body_collision_group(
        &mut self,
        id: usize,
        group: usize,
    ) -> Result<(), PhysicsError> {
        Self::validate_collision_group(group)?;
        if !self.has_body(id) {
            return Err(PhysicsError::InvalidBodyReference { body_id: id });
        }
        if let Some(body) = self.get_body_mut(id) {
            body.layer = 1u32 << group;
            body.mask = (body.mask & !COLLISION_GROUP_MASK) | COLLISION_GROUP_MASK;
            self.sync_body_collision_groups(id);
        }
        Ok(())
    }
    /// Return the single world-level collision group for `id`, or `None` for multi/no group.
    pub fn get_body_collision_group(&self, id: usize) -> Option<usize> {
        let layer = self.get_body(id)?.layer & COLLISION_GROUP_MASK;
        (layer.count_ones() == 1).then(|| layer.trailing_zeros() as usize)
    }
    /// Enable or disable a symmetric pair in the world-level 16-group collision matrix.
    pub fn try_set_collision_pair(
        &mut self,
        group_a: usize,
        group_b: usize,
        enabled: bool,
    ) -> Result<(), PhysicsError> {
        Self::validate_collision_group(group_a)?;
        Self::validate_collision_group(group_b)?;
        let bit_a = 1u16 << group_a;
        let bit_b = 1u16 << group_b;
        if enabled {
            self.collision_group_masks[group_a] |= bit_b;
            self.collision_group_masks[group_b] |= bit_a;
        } else {
            self.collision_group_masks[group_a] &= !bit_b;
            self.collision_group_masks[group_b] &= !bit_a;
        }
        self.sync_all_collision_groups();
        Ok(())
    }
    /// Return whether a pair is enabled by both matrix directions.
    pub fn try_get_collision_pair(
        &self,
        group_a: usize,
        group_b: usize,
    ) -> Result<bool, PhysicsError> {
        Self::validate_collision_group(group_a)?;
        Self::validate_collision_group(group_b)?;
        let bit_a = 1u16 << group_a;
        let bit_b = 1u16 << group_b;
        Ok(self.collision_group_masks[group_a] & bit_b != 0
            && self.collision_group_masks[group_b] & bit_a != 0)
    }
    /// Replace one source row of the world-level collision matrix.
    pub fn try_set_collision_group_mask(
        &mut self,
        group: usize,
        mask: u32,
    ) -> Result<(), PhysicsError> {
        Self::validate_collision_group(group)?;
        Self::validate_collision_group_mask(mask)?;
        self.collision_group_masks[group] = mask as u16;
        self.sync_all_collision_groups();
        Ok(())
    }
    /// Return one source row of the world-level collision matrix.
    pub fn try_get_collision_group_mask(&self, group: usize) -> Result<u32, PhysicsError> {
        Self::validate_collision_group(group)?;
        Ok(u32::from(self.collision_group_masks[group]))
    }
    /// Restore all 16 world-level groups to collide with all other groups.
    pub fn reset_collision_groups(&mut self) {
        self.collision_group_masks = [COLLISION_GROUP_MASK as u16; COLLISION_GROUP_COUNT];
        self.sync_all_collision_groups();
    }
    /// Return the total number of bodies in the world.
    pub fn body_count(&self) -> usize {
        self.body_active.iter().filter(|&&active| active).count()
    }
}
