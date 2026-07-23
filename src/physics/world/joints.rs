//! Owns the physics world joints implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics world joints data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics world joints behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics world joints defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near physics world joints state that explains them instead of spreading outward.
//! Preserves deterministic behavior by keeping physics world joints calculations at their owning subsystem boundary.

use super::*;

impl World {
    /// Add a revolute joint between two bodies at the given local anchor using strict validation.
    pub fn try_add_revolute_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_x", f64::from(anchor_x))?;
        validate_finite("anchor_y", f64::from(anchor_y))?;
        let joint = RevoluteJointBuilder::new()
            .local_anchor1(Vector::new(anchor_x, anchor_y))
            .local_anchor2(Vector::new(0.0_f32, 0.0_f32))
            .build();
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "revolute"))
    }

    /// Add a revolute joint between two bodies at the given local anchor; return joint id.
    pub fn add_revolute_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
    ) -> usize {
        match self.try_add_revolute_joint(body_a, body_b, anchor_x, anchor_y) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Return the number of registered joints.
    pub fn joint_count(&self) -> usize {
        self.joint_active.iter().filter(|&&active| active).count()
    }
    /// Add a distance joint between two bodies using strict validation.
    #[allow(clippy::too_many_arguments)]
    pub fn try_add_distance_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        ax1: f32,
        ay1: f32,
        ax2: f32,
        ay2: f32,
        length: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_a_x", f64::from(ax1))?;
        validate_finite("anchor_a_y", f64::from(ay1))?;
        validate_finite("anchor_b_x", f64::from(ax2))?;
        validate_finite("anchor_b_y", f64::from(ay2))?;
        validate_positive("length", f64::from(length))?;
        let joint = RopeJointBuilder::new(length)
            .local_anchor1(Vector::new(ax1, ay1))
            .local_anchor2(Vector::new(ax2, ay2))
            .build();
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "distance"))
    }

    /// Add a distance (rope) joint between two bodies; return joint id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_distance_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        ax1: f32,
        ay1: f32,
        ax2: f32,
        ay2: f32,
        length: f32,
    ) -> usize {
        match self.try_add_distance_joint(body_a, body_b, ax1, ay1, ax2, ay2, length) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Add a prismatic (slide-axis) joint between two bodies using strict validation.
    pub fn try_add_prismatic_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
        axis_x: f32,
        axis_y: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_x", f64::from(anchor_x))?;
        validate_finite("anchor_y", f64::from(anchor_y))?;
        validate_finite("axis_x", f64::from(axis_x))?;
        validate_finite("axis_y", f64::from(axis_y))?;
        if axis_x * axis_x + axis_y * axis_y <= 1e-6 {
            return Err(PhysicsError::DegenerateGeometry {
                context: "physics prismatic joint",
                detail: "axis length must be > epsilon",
            });
        }
        let axis = Vector::new(axis_x, axis_y);
        let joint = PrismaticJointBuilder::new(axis)
            .local_anchor1(Vector::new(anchor_x, anchor_y))
            .local_anchor2(Vector::new(0.0, 0.0))
            .build();
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "prismatic"))
    }

    /// Add a prismatic (slide-axis) joint between two bodies; return joint id.
    pub fn add_prismatic_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
        axis_x: f32,
        axis_y: f32,
    ) -> usize {
        match self.try_add_prismatic_joint(body_a, body_b, anchor_x, anchor_y, axis_x, axis_y) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Add a weld (fixed) joint between two bodies using strict validation.
    pub fn try_add_weld_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_x", f64::from(anchor_x))?;
        validate_finite("anchor_y", f64::from(anchor_y))?;
        let joint = FixedJointBuilder::new()
            .local_anchor1(Vector::new(anchor_x, anchor_y))
            .local_anchor2(Vector::new(0.0, 0.0))
            .build();
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "weld"))
    }

    /// Add a weld (fixed) joint between two bodies; return joint id.
    pub fn add_weld_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
    ) -> usize {
        match self.try_add_weld_joint(body_a, body_b, anchor_x, anchor_y) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Add a rope joint with a maximum length using strict validation.
    #[allow(clippy::too_many_arguments)]
    pub fn try_add_rope_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        ax1: f32,
        ay1: f32,
        ax2: f32,
        ay2: f32,
        max_length: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_a_x", f64::from(ax1))?;
        validate_finite("anchor_a_y", f64::from(ay1))?;
        validate_finite("anchor_b_x", f64::from(ax2))?;
        validate_finite("anchor_b_y", f64::from(ay2))?;
        validate_positive("max_length", f64::from(max_length))?;
        let joint = RopeJointBuilder::new(max_length)
            .local_anchor1(Vector::new(ax1, ay1))
            .local_anchor2(Vector::new(ax2, ay2))
            .build();
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "rope"))
    }

    /// Add a rope joint with a maximum length; return joint id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_rope_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        ax1: f32,
        ay1: f32,
        ax2: f32,
        ay2: f32,
        max_length: f32,
    ) -> usize {
        match self.try_add_rope_joint(body_a, body_b, ax1, ay1, ax2, ay2, max_length) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Return the two body ids connected by `joint_id`, or `None` if not found.
    pub fn get_joint_bodies(&self, joint_id: usize) -> Option<(usize, usize)> {
        let handle = self.active_joint_handle(joint_id)?;
        let joint = self.impulse_joints.get(handle)?;
        let id_a = self.body_handles.iter().position(|&h| h == joint.body1)?;
        let id_b = self.body_handles.iter().position(|&h| h == joint.body2)?;
        Some((id_a, id_b))
    }
    /// Remove joint `joint_id` from the simulation.
    pub fn destroy_joint(&mut self, joint_id: usize) {
        if let Some(handle) = self.active_joint_handle(joint_id) {
            self.impulse_joints.remove(handle, true);
            if let Some(active) = self.joint_active.get_mut(joint_id) {
                *active = false;
            }
        }
        self.joint_break_forces.remove(&joint_id);
        self.mouse_joint_anchors.remove(&joint_id);
    }
    /// Add a wheel-style prismatic joint using strict validation.
    #[allow(clippy::too_many_arguments)]
    pub fn try_add_wheel_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
        axis_x: f32,
        axis_y: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_x", f64::from(anchor_x))?;
        validate_finite("anchor_y", f64::from(anchor_y))?;
        validate_finite("axis_x", f64::from(axis_x))?;
        validate_finite("axis_y", f64::from(axis_y))?;
        if axis_x * axis_x + axis_y * axis_y <= 1e-6 {
            return Err(PhysicsError::DegenerateGeometry {
                context: "physics wheel joint",
                detail: "axis length must be > epsilon",
            });
        }
        let axis = Vector::new(axis_x, axis_y);
        let mut joint = PrismaticJointBuilder::new(axis)
            .local_anchor1(Vector::new(anchor_x, anchor_y))
            .local_anchor2(Vector::new(0.0, 0.0))
            .build();
        joint.data.locked_axes = JointAxesMask::LIN_Y;
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "wheel"))
    }

    /// Add a wheel-style prismatic joint; return joint id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_wheel_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
        axis_x: f32,
        axis_y: f32,
    ) -> usize {
        match self.try_add_wheel_joint(body_a, body_b, anchor_x, anchor_y, axis_x, axis_y) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Add a friction joint limiting linear and angular impulses using strict validation.
    #[allow(clippy::too_many_arguments)]
    pub fn try_add_friction_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
        max_force: f32,
        max_torque: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_finite("anchor_x", f64::from(anchor_x))?;
        validate_finite("anchor_y", f64::from(anchor_y))?;
        validate_positive("max_force", f64::from(max_force))?;
        validate_positive("max_torque", f64::from(max_torque))?;
        let mut joint = FixedJointBuilder::new()
            .local_anchor1(Vector::new(anchor_x, anchor_y))
            .local_anchor2(Vector::new(0.0, 0.0))
            .build();
        joint
            .data
            .set_motor(JointAxis::LinX, 0.0, 0.0, 0.0, max_force);
        joint
            .data
            .set_motor(JointAxis::LinY, 0.0, 0.0, 0.0, max_force);
        joint
            .data
            .set_motor(JointAxis::AngX, 0.0, 0.0, 0.0, max_torque);
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "friction"))
    }

    /// Add a friction joint limiting linear and angular impulses; return joint id.
    #[allow(clippy::too_many_arguments)]
    pub fn add_friction_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
        max_force: f32,
        max_torque: f32,
    ) -> usize {
        match self.try_add_friction_joint(body_a, body_b, anchor_x, anchor_y, max_force, max_torque)
        {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Add a spring-motor joint for position correction using strict validation.
    pub fn try_add_motor_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        correction_factor: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let (ha, hb) = self.validate_joint_pair(body_a, body_b)?;
        validate_positive("correction_factor", f64::from(correction_factor))?;
        let mut joint = FixedJointBuilder::new()
            .local_anchor1(Vector::new(0.0, 0.0))
            .local_anchor2(Vector::new(0.0, 0.0))
            .build();
        joint
            .data
            .set_motor(JointAxis::LinX, 0.0, 0.0, correction_factor, 1.0);
        joint
            .data
            .set_motor(JointAxis::LinY, 0.0, 0.0, correction_factor, 1.0);
        joint
            .data
            .set_motor(JointAxis::AngX, 0.0, 0.0, correction_factor, 1.0);
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        Ok(self.register_joint(handle, "motor"))
    }

    /// Add a spring-motor joint for position correction; return joint id.
    pub fn add_motor_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        correction_factor: f32,
    ) -> usize {
        match self.try_add_motor_joint(body_a, body_b, correction_factor) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Create a kinematic anchor and a spring joint targeting `(target_x, target_y)` using strict validation.
    pub fn try_add_mouse_joint(
        &mut self,
        body_id: usize,
        target_x: f32,
        target_y: f32,
        max_force: f32,
    ) -> Result<usize, PhysicsError> {
        self.ensure_joint_capacity()?;
        let _ = self.active_body_handle_result(body_id)?;
        validate_finite("target_x", f64::from(target_x))?;
        validate_finite("target_y", f64::from(target_y))?;
        validate_positive("max_force", f64::from(max_force))?;
        let anchor = Body::try_new(target_x, target_y, 0.2, 0.2, BodyType::Kinematic)?;
        let anchor_id = self.try_add_body(anchor)?;
        let ha = self.body_handles[body_id];
        let hb = self.body_handles[anchor_id.0];
        let stiffness = max_force;
        let damping = max_force * 0.7;
        let joint = SpringJointBuilder::new(0.0, stiffness, damping)
            .local_anchor1(Vector::new(0.0, 0.0))
            .local_anchor2(Vector::new(0.0, 0.0))
            .build();
        let handle = self.impulse_joints.insert(ha, hb, joint, true);
        let jid = self.register_joint(handle, "mouse");
        self.mouse_joint_anchors.insert(jid, anchor_id.0);
        Ok(jid)
    }

    /// Create a kinematic anchor and a spring joint targeting `(target_x, target_y)`; return joint id.
    pub fn add_mouse_joint(
        &mut self,
        body_id: usize,
        target_x: f32,
        target_y: f32,
        max_force: f32,
    ) -> usize {
        match self.try_add_mouse_joint(body_id, target_x, target_y, max_force) {
            Ok(id) => id,
            Err(_) => {
                self.record_invalid_operation();
                0
            }
        }
    }
    /// Reposition the kinematic anchor of mouse joint `joint_id` to `(x, y)`.
    pub fn set_mouse_joint_target(&mut self, joint_id: usize, x: f32, y: f32) {
        if !self.has_joint(joint_id) {
            return;
        }
        if let Some(&anchor_id) = self.mouse_joint_anchors.get(&joint_id) {
            self.set_body_position(anchor_id, x, y);
        }
    }
    /// Add a pulley joint (falls back to weld; logs a warning); return joint id.
    pub fn add_pulley_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
    ) -> usize {
        log_msg!(warn, P001_PULLEY_JOINT_FALLBACK);
        self.add_weld_joint(body_a, body_b, anchor_x, anchor_y)
    }
    /// Add a gear joint (falls back to weld; logs a warning); return joint id.
    pub fn add_gear_joint(
        &mut self,
        body_a: usize,
        body_b: usize,
        anchor_x: f32,
        anchor_y: f32,
    ) -> usize {
        log_msg!(warn, P002_GEAR_JOINT_FALLBACK);
        self.add_weld_joint(body_a, body_b, anchor_x, anchor_y)
    }
    /// Set angular motor target speed on joint `joint_id`.
    pub fn set_joint_motor_speed(&mut self, joint_id: usize, speed: f32) {
        if let Some(handle) = self.active_joint_handle(joint_id) {
            if let Some(joint) = self.impulse_joints.get_mut(handle, true) {
                joint.data.set_motor(JointAxis::AngX, 0.0, speed, 0.0, 1e6);
            }
        }
    }
    /// Return angular motor target speed on joint `joint_id`; returns 0 if not set.
    pub fn get_joint_motor_speed(&self, joint_id: usize) -> f32 {
        if let Some(handle) = self.active_joint_handle(joint_id) {
            if let Some(joint) = self.impulse_joints.get(handle) {
                if let Some(motor) = joint.data.motor(JointAxis::AngX) {
                    return motor.target_vel;
                }
            }
        }
        0.0
    }
    /// Enable or disable angular limits on joint `joint_id`.
    pub fn set_joint_limits_enabled(&mut self, joint_id: usize, enabled: bool) {
        if let Some(handle) = self.active_joint_handle(joint_id) {
            if let Some(joint) = self.impulse_joints.get_mut(handle, true) {
                if enabled {
                    let limits = joint
                        .data
                        .limits(JointAxis::AngX)
                        .map_or([-std::f32::consts::PI, std::f32::consts::PI], |l| {
                            [l.min, l.max]
                        });
                    joint.data.set_limits(JointAxis::AngX, limits);
                } else {
                    joint.data.set_limits(JointAxis::AngX, [-1e10, 1e10]);
                }
            }
        }
    }
    /// Set `[lower, upper]` angular limits on joint `joint_id`.
    pub fn set_joint_limits(&mut self, joint_id: usize, lower: f32, upper: f32) {
        if let Some(handle) = self.active_joint_handle(joint_id) {
            if let Some(joint) = self.impulse_joints.get_mut(handle, true) {
                joint.data.set_limits(JointAxis::AngX, [lower, upper]);
            }
        }
    }
    /// Return `(lower, upper)` angular limits on joint `joint_id`; returns `(0,0)` if not set.
    pub fn get_joint_limits(&self, joint_id: usize) -> (f32, f32) {
        if let Some(handle) = self.active_joint_handle(joint_id) {
            if let Some(joint) = self.impulse_joints.get(handle) {
                if let Some(limits) = joint.data.limits(JointAxis::AngX) {
                    return (limits.min, limits.max);
                }
            }
        }
        (0.0, 0.0)
    }
    /// Return the type string of joint `joint_id`; returns "unknown" if out of range.
    pub fn get_joint_type(&self, joint_id: usize) -> &'static str {
        if !self.has_joint(joint_id) {
            return "unknown";
        }
        self.joint_types.get(joint_id).copied().unwrap_or("unknown")
    }
}
