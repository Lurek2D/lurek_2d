//! This file owns `World`, the Rapier-backed runtime that stores live bodies, colliders, joints, and zones.
//! It mirrors authored `Body` data into Rapier sets, keeps stable ids, and tracks tombstones for removed slots.
//! Stepping syncs scripted state into Rapier, runs the solver pipeline, then writes motion back into body mirrors.
//! Collision handling buffers begin and end contact pairs plus overlap events so gameplay reads post-step results.
//! Contact and stats helpers summarize active manifolds, sleeping bodies, collider counts, and joint counts.
//! Spatial query helpers provide filtered raycasts, swept circle casts, instant beam traces, reflective beam paths, AABB scans, and point tests.
//! Fixture APIs let one body carry multiple colliders, while rebuild paths refresh filters and materials after edits.
//! Joint APIs create revolute, rope, prismatic, weld, wheel, friction, motor, and mouse constraints with stable ids.
//! Joint utilities also expose motor speeds, limits, break thresholds, connected bodies, and explicit destruction paths.
//! Zone integration applies priority-ordered gravity and damping overrides, then emits enter and leave events per body.
//! One-way platform handling and sleep controls adapt raw solver behavior to platformer-style gameplay expectations.
//! Meter conversion helpers keep pixel-authored content aligned with simulation units without spreading scale math.
//! Debug extraction exposes shape snapshots and image drawing support so tools can inspect runtime geometry easily.
//! Open this file when runtime ownership or physics behavior changes; pure shape and zone definitions live nearby.
//! Keep Lua conversion, renderer submission, asset parsing, and editor UI policy outside this simulation owner.

use super::body::{Body, BodyShape, BodyType};
use super::error::PhysicsError;
use super::flow::{
    combine_contributions, FlowApplicationMode, FlowCombineMode, FlowField, FlowFieldId,
    FlowMedium, FlowSample,
};
use super::limits::{validate_finite, validate_positive, PhysicsLimits};
use super::shape::Shape;
use super::types::BodyId;
use super::zone::{PhysicsZone, ZoneEvent, ZoneGravityFalloff, ZoneGravityMode, ZoneTracker};
#[allow(unused_imports)]
use crate::log_msg;
use crate::runtime::log_messages::{P001_PULLEY_JOINT_FALLBACK, P002_GEAR_JOINT_FALLBACK};
use rapier2d::prelude::*;
use std::collections::{HashMap, HashSet};
use std::sync::Mutex;

type BodySyncState = (f32, f32, f32, f32, f32, f32, BodyType);
/// Number of low-bit collision groups controlled by the world-level collision matrix.
pub const COLLISION_GROUP_COUNT: usize = 16;
const COLLISION_GROUP_MASK: u32 = 0xFFFF;
const BEAM_REFLECTION_EPSILON: f32 = 0.01;

/// Internal rapier event sink forwarding collision events through a mutex.
struct LocalEventCollector {
    /// Buffered collision events awaiting drain.
    events: Mutex<Vec<CollisionEvent>>,
}
/// `LocalEventCollector` construction and drain.
impl LocalEventCollector {
    /// Create an empty event collector.
    fn new() -> Self {
        Self {
            events: Mutex::new(Vec::new()),
        }
    }
    /// Drain all buffered events and return them.
    fn drain(&self) -> Vec<CollisionEvent> {
        match self.events.lock() {
            Ok(mut guard) => guard.drain(..).collect(),
            Err(poisoned) => poisoned.into_inner().drain(..).collect(),
        }
    }
}
/// Satisfies rapier `EventHandler` by storing events in the mutex.
impl EventHandler for LocalEventCollector {
    /// Push the collision event into the buffer.
    fn handle_collision_event(
        &self,
        _bodies: &RigidBodySet,
        _colliders: &ColliderSet,
        event: CollisionEvent,
        _contact_pair: Option<&ContactPair>,
    ) {
        match self.events.lock() {
            Ok(mut guard) => guard.push(event),
            Err(poisoned) => poisoned.into_inner().push(event),
        }
    }
    /// No-op; contact force events are not used.
    fn handle_contact_force_event(
        &self,
        _dt: f32,
        _bodies: &RigidBodySet,
        _colliders: &ColliderSet,
        _contact_pair: &ContactPair,
        _total_force_magnitude: f32,
    ) {
    }
}
/// A pair of body ids that have started or are overlapping.
/// # Fields
/// - `body_a`: first body id.
/// - `body_b`: second body id.
pub struct BodyContact {
    /// First body id.
    pub body_a: BodyId,
    /// Second body id.
    pub body_b: BodyId,
}
/// The closest raycast intersection result.
/// # Fields
/// - `body_id`: body hit by the ray.
/// - `point`: world-space hit point.
/// - `normal`: outward hit normal.
/// - `toi`: parametric distance along the cast.
#[derive(Debug, Clone, Copy)]
pub struct RaycastHit {
    /// Body id that was hit.
    pub body_id: BodyId,
    /// World-space hit point.
    pub point: (f32, f32),
    /// Outward surface normal at the hit point.
    pub normal: (f32, f32),
    /// Parametric distance along the ray.
    pub toi: f32,
}
/// The closest swept-shape intersection result.
/// # Fields
/// - `body_id`: body hit by the sweep.
/// - `point`: world-space impact point on the hit collider.
/// - `normal`: outward hit normal on the hit collider.
/// - `toi`: travel distance from the cast origin to the first impact.
/// - `safe_fraction`: normalized travel fraction in `0.0..=1.0` before the impact.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ShapeSweepHit {
    /// Body id that was hit.
    pub body_id: BodyId,
    /// World-space impact point on the hit collider.
    pub point: (f32, f32),
    /// Outward surface normal at the impact point.
    pub normal: (f32, f32),
    /// Travel distance from the cast origin to the first impact.
    pub toi: f32,
    /// Normalized travel fraction in `0.0..=1.0` before the impact.
    pub safe_fraction: f32,
}
/// Beam hit collection mode for instant gameplay beams.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BeamHitMode {
    /// Stop at the first hit and return one blocking segment.
    Closest,
    /// Return every hit in distance order and keep the visible segment at max range.
    All,
    /// Return hits in distance order until `max_hits` is reached.
    Pierce {
        /// Maximum number of hits to collect before the beam stops.
        max_hits: usize,
    },
}
/// Options controlling one instant beam query.
/// # Fields
/// - `max_distance`: maximum beam travel distance in world units.
/// - `thickness`: beam radius in world units; only `0.0` is currently supported.
/// - `hit_mode`: how many hits to collect.
/// - `reflect`: whether the beam should continue reflecting from mirror bodies.
/// - `max_bounces`: maximum number of reflections allowed when `reflect` is true.
/// - `energy`: starting beam energy multiplier used with reflective surfaces.
/// - `min_energy`: beam tracing stops when reflected energy would drop below this threshold.
/// - `filter`: collision and sensor filtering shared with other physics queries.
#[derive(Debug, Clone, Copy)]
pub struct BeamOptions {
    /// Maximum beam travel distance in world units.
    pub max_distance: f32,
    /// Beam radius in world units. Values greater than zero are reserved for shape casts.
    pub thickness: f32,
    /// Hit collection mode for this beam.
    pub hit_mode: BeamHitMode,
    /// Whether the beam should continue reflecting from mirror bodies.
    pub reflect: bool,
    /// Maximum number of reflections allowed when `reflect` is true.
    pub max_bounces: usize,
    /// Starting beam energy multiplier used with reflective surfaces.
    pub energy: f32,
    /// Tracing stops when reflected energy would fall below this threshold.
    pub min_energy: f32,
    /// Collision and sensor filtering for the beam query.
    pub filter: PhysicsQueryFilter,
}
/// One beam hit ready for gameplay or debug rendering.
/// # Fields
/// - `body_id`: body hit by the beam.
/// - `point`: world-space hit point.
/// - `normal`: outward surface normal.
/// - `distance`: beam travel distance from the origin to the hit point.
/// - `segment_index`: 1-based segment index for reflected or chained traces.
/// - `reflected`: whether the beam continued past this hit by reflecting.
/// - `incoming_dir`: normalized incoming beam direction at the hit.
/// - `outgoing_dir`: normalized reflected direction, if the hit reflected the beam.
/// - `reflectivity`: beam reflectivity multiplier used for the hit body.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct BeamHit {
    /// Body id that was hit.
    pub body_id: BodyId,
    /// World-space hit point.
    pub point: (f32, f32),
    /// Outward surface normal at the hit point.
    pub normal: (f32, f32),
    /// Beam travel distance from the origin to the hit point.
    pub distance: f32,
    /// 1-based segment index within the trace.
    pub segment_index: usize,
    /// True when the trace continued by reflecting from this hit.
    pub reflected: bool,
    /// Normalized incoming beam direction at the hit point.
    pub incoming_dir: (f32, f32),
    /// Normalized reflected direction when the hit continues the trace.
    pub outgoing_dir: Option<(f32, f32)>,
    /// Beam reflectivity multiplier applied at this hit.
    pub reflectivity: f32,
}
/// One visible segment of a beam trace.
/// # Fields
/// - `from`: segment start in world space.
/// - `to`: segment end in world space.
/// - `blocked_by`: body that stopped this segment, if any.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct BeamSegment {
    /// Segment start in world space.
    pub from: (f32, f32),
    /// Segment end in world space.
    pub to: (f32, f32),
    /// Body that stopped this segment, if any.
    pub blocked_by: Option<BodyId>,
}
/// Full instant beam query result.
/// # Fields
/// - `hits`: ordered hit results.
/// - `segments`: ordered beam segments for gameplay and rendering.
/// - `reached_max_range`: whether the trace extended to the requested max range.
#[derive(Debug, Clone, PartialEq, Default)]
pub struct BeamTrace {
    /// Ordered hit results.
    pub hits: Vec<BeamHit>,
    /// Ordered beam segments.
    pub segments: Vec<BeamSegment>,
    /// True when the trace extended to the requested max range.
    pub reached_max_range: bool,
}
/// Contact information between two bodies.
/// # Fields
/// - `body_a`: first body id.
/// - `body_b`: second body id.
/// - `normal_x`: contact normal x component.
/// - `normal_y`: contact normal y component.
/// - `is_touching`: whether the bodies are currently touching.
#[derive(Debug, Clone)]
pub struct ContactInfo {
    /// First body id.
    pub body_a: BodyId,
    /// Second body id.
    pub body_b: BodyId,
    /// Contact normal x component.
    pub normal_x: f32,
    /// Contact normal y component.
    pub normal_y: f32,
    /// True when the bodies are currently touching.
    pub is_touching: bool,
}
/// Snapshot of a physics shape used for debug rendering.
/// # Fields
/// - `x`: world-space x center.
/// - `y`: world-space y center.
/// - `half_w`: half-width for box-like shapes.
/// - `half_h`: half-height for box-like shapes.
/// - `angle`: rotation in radians.
/// - `is_static`: whether the source body is static.
/// - `is_sleeping`: whether the source body is sleeping.
/// - `is_sensor`: whether the source collider is a sensor.
/// - `is_circle`: whether the shape should be rendered as a circle.
/// - `hull_verts`: polygon hull vertices for non-rectangular shapes.
pub struct PhysicsShapeSnapshot {
    /// World-space x centre.
    pub x: f32,
    /// World-space y centre.
    pub y: f32,
    /// Half-width for AABB shapes.
    pub half_w: f32,
    /// Half-height for AABB shapes.
    pub half_h: f32,
    /// Rotation in radians.
    pub angle: f32,
    /// True when the body is static.
    pub is_static: bool,
    /// True when the body is sleeping.
    pub is_sleeping: bool,
    /// True when the collider is a sensor.
    pub is_sensor: bool,
    /// True when the shape is a circle.
    pub is_circle: bool,
    /// Convex hull vertices for polygon shapes.
    pub hull_verts: Vec<[f32; 2]>,
}
/// Optional filters applied to physics spatial queries.
/// # Fields
/// - `layer`: optional query-side collision layer mask.
/// - `mask`: optional query-side collision mask.
/// - `groups`: optional 16-group query-side membership mask.
/// - `include_sensors`: whether sensor colliders should be returned.
/// - `exclude_body`: optional body whose colliders should be excluded.
#[derive(Debug, Clone, Copy)]
pub struct PhysicsQueryFilter {
    /// Query collision layer membership. `None` leaves groups unrestricted.
    pub layer: Option<u32>,
    /// Query collision mask. `None` leaves groups unrestricted.
    pub mask: Option<u32>,
    /// Query membership in the world-level 16-group collision matrix.
    pub groups: Option<u32>,
    /// Include sensor colliders in query results.
    pub include_sensors: bool,
    /// Exclude every collider attached to this body from the query.
    pub exclude_body: Option<BodyId>,
}
/// Default query filters preserve the historical "hit everything" behavior.
impl Default for PhysicsQueryFilter {
    fn default() -> Self {
        Self {
            layer: None,
            mask: None,
            groups: None,
            include_sensors: true,
            exclude_body: None,
        }
    }
}
/// Additive directional gravity vector applied to matching dynamic bodies before the solver step.
/// # Fields
/// - `id`: stable gravity vector identifier.
/// - `gx`: x acceleration in world units per second squared.
/// - `gy`: y acceleration in world units per second squared.
/// - `layer_mask`: body layer mask; bodies with `body.layer & layer_mask == 0` are skipped.
/// - `enabled`: whether the vector participates in the next step.
#[derive(Debug, Clone, Copy)]
pub struct GravityVector {
    /// Stable vector id.
    pub id: usize,
    /// X acceleration in world units per second squared.
    pub gx: f32,
    /// Y acceleration in world units per second squared.
    pub gy: f32,
    /// Layer mask used to select affected bodies.
    pub layer_mask: u32,
    /// True when this vector is active.
    pub enabled: bool,
}
/// Runtime diagnostics recorded by the physics world across steps and strict mutators.
/// # Fields
/// - `skipped_steps`: invalid or empty `step` calls rejected before rapier.
/// - `clamped_steps`: `step` calls whose dt was reduced to the configured ceiling.
/// - `invalid_operations`: strict helper failures observed through legacy wrappers.
/// - `last_bodies_scanned`: body slots examined during the most recent step.
/// - `last_colliders_rebuilt`: collider rebuilds triggered during the most recent step.
/// - `last_zone_checks`: body-zone containment checks performed during the most recent step.
/// - `last_flow_samples`: field samples evaluated during the most recent step.
/// - `last_flow_affected_bodies`: dynamic bodies that received non-zero flow influence during the most recent step.
/// - `last_contacts`: contact events emitted during the most recent step.
/// - `last_synced_bodies`: body mirrors pushed into rapier during the most recent step.
#[derive(Debug, Clone, Copy, Default)]
pub struct PhysicsDiagnostics {
    /// Invalid or empty `step` calls rejected before rapier.
    pub skipped_steps: u64,
    /// `step` calls whose dt was reduced to the configured ceiling.
    pub clamped_steps: u64,
    /// Strict helper failures observed through legacy wrappers.
    pub invalid_operations: u64,
    /// Body slots examined during the most recent step.
    pub last_bodies_scanned: usize,
    /// Collider rebuilds triggered during the most recent step.
    pub last_colliders_rebuilt: usize,
    /// Body-zone containment checks performed during the most recent step.
    pub last_zone_checks: usize,
    /// Flow-field samples evaluated during the most recent step.
    pub last_flow_samples: usize,
    /// Dynamic bodies that received non-zero flow influence during the most recent step.
    pub last_flow_affected_bodies: usize,
    /// Contact events emitted during the most recent step.
    pub last_contacts: usize,
    /// Body mirrors pushed into rapier during the most recent step.
    pub last_synced_bodies: usize,
}
/// Lightweight world diagnostics for Lua/editor tooling.
/// # Fields
/// - `bodies`: active body count.
/// - `body_slots`: total allocated body slots.
/// - `colliders`: active collider count.
/// - `joints`: active joint count.
/// - `joint_slots`: total allocated joint slots.
/// - `zones`: active zone count.
/// - `gravity_vectors`: active additive gravity vector count.
/// - `flow_fields`: active flow-field count.
/// - `sleeping_bodies`: active bodies currently sleeping.
/// - `skipped_steps`: invalid or empty `step` calls rejected before rapier.
/// - `clamped_steps`: `step` calls whose dt was reduced to the configured ceiling.
/// - `invalid_operations`: strict helper failures observed through legacy wrappers.
/// - `bodies_scanned`: body slots examined during the most recent step.
/// - `colliders_rebuilt`: collider rebuilds triggered during the most recent step.
/// - `zone_checks`: body-zone containment checks performed during the most recent step.
/// - `flow_samples`: flow-field samples evaluated during the most recent step.
/// - `flow_affected_bodies`: dynamic bodies that received non-zero flow influence during the most recent step.
/// - `contacts`: contact events emitted during the most recent step.
/// - `synced_bodies`: body mirrors pushed into rapier during the most recent step.
#[derive(Debug, Clone, Copy, Default)]
pub struct PhysicsWorldStats {
    /// Active body count.
    pub bodies: usize,
    /// Total body slots, including tombstoned ids.
    pub body_slots: usize,
    /// Active collider count.
    pub colliders: usize,
    /// Active joint count.
    pub joints: usize,
    /// Total joint slots, including tombstoned ids.
    pub joint_slots: usize,
    /// Active zone count.
    pub zones: usize,
    /// Active additive gravity vector count.
    pub gravity_vectors: usize,
    /// Active authored flow-field count.
    pub flow_fields: usize,
    /// Active bodies currently sleeping.
    pub sleeping_bodies: usize,
    /// Invalid or empty `step` calls rejected before rapier.
    pub skipped_steps: u64,
    /// `step` calls whose dt was reduced to the configured ceiling.
    pub clamped_steps: u64,
    /// Strict helper failures observed through legacy wrappers.
    pub invalid_operations: u64,
    /// Body slots examined during the most recent step.
    pub bodies_scanned: usize,
    /// Collider rebuilds triggered during the most recent step.
    pub colliders_rebuilt: usize,
    /// Body-zone containment checks performed during the most recent step.
    pub zone_checks: usize,
    /// Flow-field samples evaluated during the most recent step.
    pub flow_samples: usize,
    /// Dynamic bodies that received non-zero flow influence during the most recent step.
    pub flow_affected_bodies: usize,
    /// Contact events emitted during the most recent step.
    pub contacts: usize,
    /// Body mirrors pushed into rapier during the most recent step.
    pub synced_bodies: usize,
}
/// Full rapier2d-backed simulation world.
/// # Fields
/// - `bodies`: Lua-visible body mirrors.
/// - `body_handles`: rapier rigid body handles for each slot.
/// - `body_active`: active/tombstoned body slot state.
/// - `collider_handles`: primary collider per body.
/// - `extra_collider_handles`: additional colliders per body.
/// - `collider_to_body`: reverse collider-to-body lookup.
/// - `cached_shapes`: cached shape descriptors for rebuild detection.
/// - `cached_restitutions`: cached restitution values per body.
/// - `cached_layers`: cached layer/mask pairs per body.
/// - `collision_group_masks`: world-level 16-group collision matrix rows.
/// - `cached_frictions`: cached friction values per body.
/// - `pipeline`: rapier simulation pipeline.
/// - `gravity`: world gravity vector.
/// - `params`: integration parameters.
/// - `islands`: rapier island manager.
/// - `broad_phase`: rapier broad phase.
/// - `narrow_phase`: rapier narrow phase.
/// - `rbodies`: rapier rigid body storage.
/// - `rcolliders`: rapier collider storage.
/// - `impulse_joints`: rapier impulse joint storage.
/// - `multibody_joints`: rapier multibody joint storage.
/// - `ccd_solver`: rapier CCD solver.
/// - `joint_handles`: rapier impulse joint handles by slot.
/// - `joint_active`: active/tombstoned joint slot state.
/// - `collision_events`: buffered overlap/contact events.
/// - `begin_contact_events`: body pairs that started touching this step.
/// - `end_contact_events`: body pairs that stopped touching this step.
/// - `event_handler`: local rapier event collector.
/// - `joint_types`: joint type labels by stable joint id.
/// - `mouse_joint_anchors`: mouse-joint anchor body lookup.
/// - `pixels_per_meter`: pixels-to-meter conversion ratio.
/// - `joint_break_forces`: optional joint break thresholds.
/// - `one_way_normals`: one-way platform normals by body id.
/// - `body_dirty_sync`: explicit mirror-to-rapier sync flags for dynamic bodies.
/// - `body_base_gravity_scales`: gravity scales restored after temporary zone overrides.
/// - `body_base_linear_damping`: linear damping restored after temporary zone overrides.
/// - `body_base_angular_damping`: angular damping restored after temporary zone overrides.
/// - `body_mass_overrides`: explicit mass values authored through `setMass`.
/// - `zones`: registered physics zones.
/// - `gravity_vectors`: additive world gravity vectors.
/// - `flow_fields`: authored flow fields sampled before the solver step.
/// - `gravity_vector_id_counter`: next stable additive gravity vector id.
/// - `zone_id_counter`: next stable zone id.
/// - `flow_field_id_counter`: next stable flow-field id.
/// - `zone_tracker`: body/zone membership tracker.
/// - `zone_events`: buffered zone enter/leave events.
/// - `limits`: shared safety ceilings for strict helpers and bounded stepping.
/// - `diagnostics`: cumulative and per-step instrumentation counters.
/// - `rebuild_scratch`: reusable body-id buffer for collider rebuild scans.
/// - `sync_scratch`: reusable mirror-state buffer for rapier sync.
/// - `sorted_zone_indices`: reusable priority-order buffer for zones.
/// - `default_gravity`: gravity captured at construction for full reset semantics.
/// # Fields
/// See inline field docs below for the authoritative per-field details.
pub struct World {
    /// Mirror of rapier rigid bodies for Lua-readable state.
    bodies: Vec<Body>,
    /// Rapier handles corresponding to each `bodies` entry.
    body_handles: Vec<RigidBodyHandle>,
    /// True for body slots that are still active.
    body_active: Vec<bool>,
    /// Primary collider handle per body.
    collider_handles: Vec<ColliderHandle>,
    /// Additional collider handles per body (multi-fixture).
    extra_collider_handles: Vec<Vec<ColliderHandle>>,
    /// Reverse map from collider handle to body id.
    collider_to_body: HashMap<ColliderHandle, usize>,
    /// Cached shape discriminants used for collision filtering.
    cached_shapes: Vec<BodyShape>,
    /// Cached restitution values per body.
    cached_restitutions: Vec<f32>,
    /// Cached `(layer, mask)` pairs per body.
    cached_layers: Vec<(u32, u32)>,
    /// World-level 16-group collision matrix stored as target masks per source group.
    collision_group_masks: [u16; COLLISION_GROUP_COUNT],
    /// Cached friction values per body.
    cached_frictions: Vec<f32>,
    /// rapier pipeline — runs the simulation substep.
    pipeline: PhysicsPipeline,
    /// Gravity vector applied to dynamic bodies each step.
    gravity: Vector,
    /// rapier integration tuning parameters.
    params: IntegrationParameters,
    /// rapier island manager for sleeping bodies.
    islands: IslandManager,
    /// rapier broad-phase BVH accelerator.
    broad_phase: BroadPhaseBvh,
    /// rapier narrow-phase contact generator.
    narrow_phase: NarrowPhase,
    /// rapier rigid body storage.
    rbodies: RigidBodySet,
    /// rapier collider storage.
    rcolliders: ColliderSet,
    /// rapier impulse joint storage.
    impulse_joints: ImpulseJointSet,
    /// rapier multibody joint storage (unused but required by pipeline).
    multibody_joints: MultibodyJointSet,
    /// rapier CCD solver.
    ccd_solver: CCDSolver,
    /// rapier joint handles indexed by joint id.
    joint_handles: Vec<ImpulseJointHandle>,
    /// True for joint slots that are still active.
    joint_active: Vec<bool>,
    /// Overlap/touching events emitted last step.
    collision_events: Vec<BodyContact>,
    /// Pairs that started touching last step.
    begin_contact_events: Vec<(usize, usize)>,
    /// Pairs that stopped touching last step.
    end_contact_events: Vec<(usize, usize)>,
    /// Joint type string per joint id.
    joint_types: Vec<&'static str>,
    /// Anchor body id per mouse-joint id.
    mouse_joint_anchors: HashMap<usize, usize>,
    /// Pixels-to-meter conversion factor.
    pixels_per_meter: f32,
    /// Max force before auto-breaking per joint id.
    joint_break_forces: HashMap<usize, f32>,
    /// One-way platform normal per body id; `None` means standard two-way.
    one_way_normals: Vec<Option<(f32, f32)>>,
    /// Explicit mirror-to-rapier sync flags for dynamic bodies.
    body_dirty_sync: Vec<bool>,
    /// Gravity scales restored after temporary zone overrides.
    body_base_gravity_scales: Vec<f32>,
    /// Linear damping restored after temporary zone overrides.
    body_base_linear_damping: Vec<f32>,
    /// Angular damping restored after temporary zone overrides.
    body_base_angular_damping: Vec<f32>,
    /// Explicit mass overrides authored through `setMass`; `None` means use Rapier computed mass.
    body_mass_overrides: Vec<Option<f32>>,
    /// Active trigger zones.
    zones: Vec<PhysicsZone>,
    /// Additive world gravity vectors applied when no non-additive zone override is active.
    gravity_vectors: Vec<GravityVector>,
    /// Authored flow fields sampled and applied before the solver step.
    flow_fields: Vec<FlowField>,
    /// Monotonically increasing id for additive gravity vectors.
    gravity_vector_id_counter: usize,
    /// Monotonically increasing id for zones.
    zone_id_counter: usize,
    /// Monotonically increasing id for flow fields.
    flow_field_id_counter: usize,
    /// Tracks which bodies are inside each zone.
    zone_tracker: ZoneTracker,
    /// Zone enter/exit events emitted last step.
    zone_events: Vec<ZoneEvent>,
    /// Shared safety ceilings for strict helpers and bounded stepping.
    limits: PhysicsLimits,
    /// Cumulative and per-step instrumentation counters.
    diagnostics: PhysicsDiagnostics,
    /// Reusable body-id buffer for collider rebuild scans.
    rebuild_scratch: Vec<usize>,
    /// Reusable mirror-state buffer for rapier sync.
    sync_scratch: Vec<Option<BodySyncState>>,
    /// Reusable priority-order buffer for zones.
    sorted_zone_indices: Vec<usize>,
    /// Gravity captured at construction for full reset semantics.
    default_gravity: Vector,
}
/// Physics world operations: body management, stepping, joints, queries, zones, and debug rendering.
impl World {
    /// Draw all body outlines onto an RGBA `ImageData` using the given colour.
    pub fn draw_debug_to_image(
        &self,
        img: &mut crate::image::ImageData,
        r: u8,
        g: u8,
        b: u8,
        a: u8,
    ) {
        for (idx, body) in self.bodies.iter().enumerate() {
            if !self.has_body(idx) {
                continue;
            }
            let cx = body.position.x as i32;
            let cy = body.position.y as i32;
            let angle = body.angle;
            if let Some(ref ext) = body.shape_ext {
                match ext {
                    crate::physics::shape::Shape::Rect { width, height } => {
                        let hw = *width / 2.0;
                        let hh = *height / 2.0;
                        let p0 = crate::math::Vec2 { x: -hw, y: -hh }.rotate(angle) + body.position;
                        let p1 = crate::math::Vec2 { x: hw, y: -hh }.rotate(angle) + body.position;
                        let p2 = crate::math::Vec2 { x: hw, y: hh }.rotate(angle) + body.position;
                        let p3 = crate::math::Vec2 { x: -hw, y: hh }.rotate(angle) + body.position;
                        img.draw_line(
                            p0.x.round() as i32,
                            p0.y.round() as i32,
                            p1.x.round() as i32,
                            p1.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                        img.draw_line(
                            p1.x.round() as i32,
                            p1.y.round() as i32,
                            p2.x.round() as i32,
                            p2.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                        img.draw_line(
                            p2.x.round() as i32,
                            p2.y.round() as i32,
                            p3.x.round() as i32,
                            p3.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                        img.draw_line(
                            p3.x.round() as i32,
                            p3.y.round() as i32,
                            p0.x.round() as i32,
                            p0.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                    }
                    crate::physics::shape::Shape::Circle { radius } => {
                        img.draw_circle(cx, cy, *radius as u32, r, g, b, a);
                        let ex = cx + (angle.cos() * radius) as i32;
                        let ey = cy + (angle.sin() * radius) as i32;
                        img.draw_line(cx, cy, ex, ey, r, g, b, a);
                    }
                    crate::physics::shape::Shape::Polygon { vertices } => {
                        for i in 0..vertices.len() {
                            let p0 = vertices[i].rotate(angle) + body.position;
                            let p1 =
                                vertices[(i + 1) % vertices.len()].rotate(angle) + body.position;
                            img.draw_line(
                                p0.x.round() as i32,
                                p0.y.round() as i32,
                                p1.x.round() as i32,
                                p1.y.round() as i32,
                                r,
                                g,
                                b,
                                a,
                            );
                        }
                    }
                    crate::physics::shape::Shape::Edge { v1, v2 } => {
                        let p0 = v1.rotate(angle) + body.position;
                        let p1 = v2.rotate(angle) + body.position;
                        img.draw_line(
                            p0.x.round() as i32,
                            p0.y.round() as i32,
                            p1.x.round() as i32,
                            p1.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                    }
                    crate::physics::shape::Shape::Chain { vertices, closed } => {
                        for i in 0..vertices.len() - 1 {
                            let p0 = vertices[i].rotate(angle) + body.position;
                            let p1 = vertices[i + 1].rotate(angle) + body.position;
                            img.draw_line(
                                p0.x.round() as i32,
                                p0.y.round() as i32,
                                p1.x.round() as i32,
                                p1.y.round() as i32,
                                r,
                                g,
                                b,
                                a,
                            );
                        }
                        if *closed && vertices.len() > 2 {
                            let p0 = vertices[vertices.len() - 1].rotate(angle) + body.position;
                            let p1 = vertices[0].rotate(angle) + body.position;
                            img.draw_line(
                                p0.x.round() as i32,
                                p0.y.round() as i32,
                                p1.x.round() as i32,
                                p1.y.round() as i32,
                                r,
                                g,
                                b,
                                a,
                            );
                        }
                    }
                }
            } else {
                match body.shape {
                    super::body::BodyShape::Rect { width, height } => {
                        let hw = width / 2.0;
                        let hh = height / 2.0;
                        let p0 = crate::math::Vec2 { x: -hw, y: -hh }.rotate(angle) + body.position;
                        let p1 = crate::math::Vec2 { x: hw, y: -hh }.rotate(angle) + body.position;
                        let p2 = crate::math::Vec2 { x: hw, y: hh }.rotate(angle) + body.position;
                        let p3 = crate::math::Vec2 { x: -hw, y: hh }.rotate(angle) + body.position;
                        img.draw_line(
                            p0.x.round() as i32,
                            p0.y.round() as i32,
                            p1.x.round() as i32,
                            p1.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                        img.draw_line(
                            p1.x.round() as i32,
                            p1.y.round() as i32,
                            p2.x.round() as i32,
                            p2.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                        img.draw_line(
                            p2.x.round() as i32,
                            p2.y.round() as i32,
                            p3.x.round() as i32,
                            p3.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                        img.draw_line(
                            p3.x.round() as i32,
                            p3.y.round() as i32,
                            p0.x.round() as i32,
                            p0.y.round() as i32,
                            r,
                            g,
                            b,
                            a,
                        );
                    }
                    super::body::BodyShape::Circle { radius } => {
                        img.draw_circle(cx, cy, radius as u32, r, g, b, a);
                        let ex = cx + (angle.cos() * radius) as i32;
                        let ey = cy + (angle.sin() * radius) as i32;
                        img.draw_line(cx, cy, ex, ey, r, g, b, a);
                    }
                }
            }
        }
    }

    /// Draws flow-field centerlines, bounds, and sampled arrows into an RGBA image target.
    pub fn draw_flow_debug_to_image(&self, img: &mut crate::image::ImageData, arrow_spacing: u32) {
        let spacing = arrow_spacing.max(12) as usize;
        for field in self.flow_fields.iter().filter(|field| field.enabled) {
            match &field.geometry {
                super::flow::FlowGeometry::UniformRect { x, y, w, h } => {
                    let x0 = x.round() as i32;
                    let y0 = y.round() as i32;
                    let x1 = (*x + *w).round() as i32;
                    let y1 = (*y + *h).round() as i32;
                    img.draw_line(x0, y0, x1, y0, 90, 220, 255, 220);
                    img.draw_line(x1, y0, x1, y1, 90, 220, 255, 220);
                    img.draw_line(x1, y1, x0, y1, 90, 220, 255, 220);
                    img.draw_line(x0, y1, x0, y0, 90, 220, 255, 220);
                }
                super::flow::FlowGeometry::CircleFan {
                    cx,
                    cy,
                    radius,
                    inner_radius,
                } => {
                    img.draw_circle(
                        cx.round() as i32,
                        cy.round() as i32,
                        radius.round().max(1.0) as u32,
                        90,
                        220,
                        255,
                        220,
                    );
                    if *inner_radius > 0.0 {
                        img.draw_circle(
                            cx.round() as i32,
                            cy.round() as i32,
                            inner_radius.round().max(1.0) as u32,
                            60,
                            140,
                            170,
                            180,
                        );
                    }
                }
                super::flow::FlowGeometry::PolylineTube { points, width } => {
                    for segment_index in 0..points.len().saturating_sub(1) {
                        let start = points[segment_index];
                        let end = points[segment_index + 1];
                        img.draw_line(
                            start.x.round() as i32,
                            start.y.round() as i32,
                            end.x.round() as i32,
                            end.y.round() as i32,
                            90,
                            220,
                            255,
                            220,
                        );
                        img.draw_circle(
                            start.x.round() as i32,
                            start.y.round() as i32,
                            width.round().max(1.0) as u32,
                            30,
                            110,
                            140,
                            60,
                        );
                    }
                }
            }
        }
        for y in (spacing / 2..img.height() as usize).step_by(spacing) {
            for x in (spacing / 2..img.width() as usize).step_by(spacing) {
                let sample = self.sample_flow(x as f32, y as f32, None);
                if sample.magnitude <= 1.0e-3 {
                    continue;
                }
                let dir_x = sample.vx / sample.magnitude;
                let dir_y = sample.vy / sample.magnitude;
                let arrow_len = (sample.intensity * spacing as f32 * 0.8).max(6.0);
                let x0 = x as i32;
                let y0 = y as i32;
                let x1 = (x as f32 + dir_x * arrow_len).round() as i32;
                let y1 = (y as f32 + dir_y * arrow_len).round() as i32;
                img.draw_line(x0, y0, x1, y1, 255, 200, 70, 220);
            }
        }
    }
    /// Return a snapshot of all body shapes suitable for debug rendering.
    pub fn extract_shape_snapshots(&self) -> Vec<PhysicsShapeSnapshot> {
        let mut out = Vec::with_capacity(self.bodies.len());
        for (idx, body) in self.bodies.iter().enumerate() {
            if !self.has_body(idx) {
                continue;
            }
            let is_sleeping = self
                .body_handles
                .get(idx)
                .and_then(|h| self.rbodies.get(*h))
                .map(|rb| rb.is_sleeping())
                .unwrap_or(false);
            let is_static = matches!(
                body.body_type,
                crate::physics::body::BodyType::Static | crate::physics::body::BodyType::Kinematic
            );
            let is_sensor = body.body_type == crate::physics::body::BodyType::Sensor;
            let angle = body.angle;
            let (is_circle, half_w, half_h, hull_verts) = if let Some(ref ext) = body.shape_ext {
                match ext {
                    crate::physics::shape::Shape::Circle { radius } => {
                        (true, *radius, *radius, vec![])
                    }
                    crate::physics::shape::Shape::Rect { width, height } => {
                        (false, width / 2.0, height / 2.0, vec![])
                    }
                    crate::physics::shape::Shape::Polygon { vertices }
                    | crate::physics::shape::Shape::Chain { vertices, .. } => {
                        let verts = vertices
                            .iter()
                            .map(|v| [v.x, v.y])
                            .collect::<Vec<[f32; 2]>>();
                        let (hw, hh) = if verts.is_empty() {
                            (8.0, 8.0)
                        } else {
                            let max_x = verts.iter().map(|v| v[0].abs()).fold(0.0_f32, f32::max);
                            let max_y = verts.iter().map(|v| v[1].abs()).fold(0.0_f32, f32::max);
                            (max_x, max_y)
                        };
                        (false, hw, hh, verts)
                    }
                    crate::physics::shape::Shape::Edge { v1, v2 } => {
                        let hw = ((v2.x - v1.x).abs() / 2.0).max(1.0);
                        let hh = ((v2.y - v1.y).abs() / 2.0).max(1.0);
                        let verts = vec![[v1.x, v1.y], [v2.x, v2.y]];
                        (false, hw, hh, verts)
                    }
                }
            } else {
                match body.shape {
                    super::body::BodyShape::Rect { width, height } => {
                        (false, width / 2.0, height / 2.0, vec![])
                    }
                    super::body::BodyShape::Circle { radius } => (true, radius, radius, vec![]),
                }
            };
            out.push(PhysicsShapeSnapshot {
                x: body.position.x,
                y: body.position.y,
                half_w,
                half_h,
                angle,
                is_static,
                is_sleeping,
                is_sensor,
                is_circle,
                hull_verts,
            });
        }
        out
    }
    /// Create a world with gravity `(gx, gy)` in pixels/s².
    pub fn new(gx: f32, gy: f32) -> Self {
        World {
            bodies: Vec::new(),
            body_handles: Vec::new(),
            body_active: Vec::new(),
            collider_handles: Vec::new(),
            extra_collider_handles: Vec::new(),
            collider_to_body: HashMap::new(),
            cached_shapes: Vec::new(),
            cached_restitutions: Vec::new(),
            cached_layers: Vec::new(),
            collision_group_masks: [COLLISION_GROUP_MASK as u16; COLLISION_GROUP_COUNT],
            cached_frictions: Vec::new(),
            pipeline: PhysicsPipeline::new(),
            gravity: Vector::new(gx, gy),
            params: IntegrationParameters::default(),
            islands: IslandManager::new(),
            broad_phase: BroadPhaseBvh::new(),
            narrow_phase: NarrowPhase::new(),
            rbodies: RigidBodySet::new(),
            rcolliders: ColliderSet::new(),
            impulse_joints: ImpulseJointSet::new(),
            multibody_joints: MultibodyJointSet::new(),
            ccd_solver: CCDSolver::new(),
            joint_handles: Vec::new(),
            joint_active: Vec::new(),
            collision_events: Vec::new(),
            begin_contact_events: Vec::new(),
            end_contact_events: Vec::new(),
            joint_types: Vec::new(),
            mouse_joint_anchors: HashMap::new(),
            pixels_per_meter: 1.0,
            joint_break_forces: HashMap::new(),
            one_way_normals: Vec::new(),
            body_dirty_sync: Vec::new(),
            body_base_gravity_scales: Vec::new(),
            body_base_linear_damping: Vec::new(),
            body_base_angular_damping: Vec::new(),
            body_mass_overrides: Vec::new(),
            zones: Vec::new(),
            gravity_vectors: Vec::new(),
            flow_fields: Vec::new(),
            gravity_vector_id_counter: 0,
            zone_id_counter: 0,
            flow_field_id_counter: 0,
            zone_tracker: ZoneTracker::new(),
            zone_events: Vec::new(),
            limits: PhysicsLimits::default(),
            diagnostics: PhysicsDiagnostics::default(),
            rebuild_scratch: Vec::new(),
            sync_scratch: Vec::new(),
            sorted_zone_indices: Vec::new(),
            default_gravity: Vector::new(gx, gy),
        }
    }
    /// Map `BodyType` to the equivalent rapier `RigidBodyType`.
    fn rapier_body_type(bt: BodyType) -> RigidBodyType {
        match bt {
            BodyType::Static | BodyType::Sensor => RigidBodyType::Fixed,
            BodyType::Dynamic => RigidBodyType::Dynamic,
            BodyType::Kinematic => RigidBodyType::KinematicPositionBased,
        }
    }
    /// Build raw Rapier collision groups from lurek layer/mask values.
    fn raw_collision_groups(layer: u32, mask: u32) -> InteractionGroups {
        InteractionGroups::new(
            Group::from_bits_truncate(layer),
            Group::from_bits_truncate(mask),
            InteractionTestMode::And,
        )
    }
    /// Return the low 16 target groups enabled by the world matrix for `layer`.
    fn allowed_collision_targets(&self, layer: u32) -> u32 {
        let mut allowed = 0u32;
        for group in 0..COLLISION_GROUP_COUNT {
            if layer & (1u32 << group) != 0 {
                allowed |= u32::from(self.collision_group_masks[group]);
            }
        }
        allowed
    }
    /// Combine local body/query masks with the world-level 16-group collision matrix.
    fn effective_collision_mask(&self, layer: u32, mask: u32) -> u32 {
        let matrix_mask = self.allowed_collision_targets(layer);
        (mask & !COLLISION_GROUP_MASK) | ((mask & COLLISION_GROUP_MASK) & matrix_mask)
    }
    /// Build Rapier collision groups after applying the world-level collision matrix.
    fn collision_groups(&self, layer: u32, mask: u32) -> InteractionGroups {
        Self::raw_collision_groups(layer, self.effective_collision_mask(layer, mask))
    }
    /// Build rapier query filter from optional layer/mask/group and sensor settings.
    fn query_filter(&self, filter: PhysicsQueryFilter) -> QueryFilter<'static> {
        let mut flags = QueryFilterFlags::empty();
        if !filter.include_sensors {
            flags |= QueryFilterFlags::EXCLUDE_SENSORS;
        }
        let groups = if filter.layer.is_some() || filter.mask.is_some() || filter.groups.is_some() {
            let layer = filter.groups.or(filter.layer).unwrap_or(u32::MAX);
            Some(self.collision_groups(layer, filter.mask.unwrap_or(u32::MAX)))
        } else {
            None
        };
        let exclude_rigid_body = filter
            .exclude_body
            .and_then(|body_id| self.active_body_handle(body_id.raw()));
        QueryFilter {
            flags,
            groups,
            exclude_rigid_body,
            ..QueryFilter::default()
        }
    }

    fn record_invalid_operation(&mut self) {
        self.diagnostics.invalid_operations += 1;
    }

    fn active_body_handle_result(&self, id: usize) -> Result<RigidBodyHandle, PhysicsError> {
        self.active_body_handle(id)
            .ok_or(PhysicsError::InvalidBodyReference { body_id: id })
    }

    fn validate_fixture_material(
        density: f32,
        friction: f32,
        restitution: f32,
    ) -> Result<(), PhysicsError> {
        validate_positive("density", f64::from(density))?;
        validate_finite("friction", f64::from(friction))?;
        validate_finite("restitution", f64::from(restitution))?;
        if !(0.0..=1.0).contains(&friction) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "friction",
                min: 0.0,
                max: 1.0,
                value: f64::from(friction),
            });
        }
        if !(0.0..=1.0).contains(&restitution) {
            return Err(PhysicsError::ValueOutOfRange {
                field: "restitution",
                min: 0.0,
                max: 1.0,
                value: f64::from(restitution),
            });
        }
        Ok(())
    }

    fn validate_joint_pair(
        &self,
        body_a: usize,
        body_b: usize,
    ) -> Result<(RigidBodyHandle, RigidBodyHandle), PhysicsError> {
        let ha = self.active_body_handle_result(body_a)?;
        let hb = self.active_body_handle_result(body_b)?;
        Ok((ha, hb))
    }

    fn ensure_joint_capacity(&self) -> Result<(), PhysicsError> {
        if self.joint_handles.len() >= self.limits.max_joints {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics joints",
                count: self.joint_handles.len() + 1,
                max: self.limits.max_joints,
            });
        }
        Ok(())
    }

    fn validate_collision_group(group: usize) -> Result<(), PhysicsError> {
        if group >= COLLISION_GROUP_COUNT {
            return Err(PhysicsError::ValueOutOfRange {
                field: "collision_group",
                min: 0.0,
                max: (COLLISION_GROUP_COUNT - 1) as f64,
                value: group as f64,
            });
        }
        Ok(())
    }

    fn validate_collision_group_mask(mask: u32) -> Result<(), PhysicsError> {
        if mask > COLLISION_GROUP_MASK {
            return Err(PhysicsError::ValueOutOfRange {
                field: "collision_group_mask",
                min: 0.0,
                max: f64::from(COLLISION_GROUP_MASK),
                value: f64::from(mask),
            });
        }
        Ok(())
    }

    /// Return the cumulative and latest-step diagnostics recorded by the world.
    pub fn get_diagnostics(&self) -> PhysicsDiagnostics {
        self.diagnostics
    }

    /// Mark a body mirror as needing an explicit sync into rapier on the next step.
    pub fn mark_body_dirty(&mut self, id: usize) {
        if let Some(dirty) = self.body_dirty_sync.get_mut(id) {
            *dirty = true;
        }
    }
    /// Return true when a body id names a live body slot.
    pub fn has_body(&self, id: usize) -> bool {
        self.body_active.get(id).copied().unwrap_or(false)
    }
    /// Return true when a joint id names a live joint slot.
    pub fn has_joint(&self, id: usize) -> bool {
        self.joint_active.get(id).copied().unwrap_or(false)
    }
    /// Return a live rigid-body handle for `id`.
    fn active_body_handle(&self, id: usize) -> Option<RigidBodyHandle> {
        self.has_body(id)
            .then(|| self.body_handles.get(id).copied())
            .flatten()
    }
    /// Return a live impulse-joint handle for `id`.
    fn active_joint_handle(&self, id: usize) -> Option<ImpulseJointHandle> {
        self.has_joint(id)
            .then(|| self.joint_handles.get(id).copied())
            .flatten()
    }
    /// Record a newly inserted joint and return its stable id.
    fn register_joint(&mut self, handle: ImpulseJointHandle, joint_type: &'static str) -> usize {
        let jid = self.joint_handles.len();
        self.joint_handles.push(handle);
        self.joint_active.push(true);
        self.joint_types.push(joint_type);
        jid
    }
    /// Build a rapier `Collider` from a body's shape and filter settings.
    fn make_collider(&self, body: &Body) -> Collider {
        let is_sensor = body.body_type == BodyType::Sensor;
        let groups = self.collision_groups(body.layer, body.mask);
        let builder = if let Some(ref shape_ext) = body.shape_ext {
            shape_ext
                .to_rapier_collider()
                .unwrap_or_else(|| match body.shape {
                    BodyShape::Rect { width, height } => {
                        ColliderBuilder::cuboid(width / 2.0, height / 2.0)
                    }
                    BodyShape::Circle { radius } => ColliderBuilder::ball(radius),
                })
        } else {
            match body.shape {
                BodyShape::Rect { width, height } => {
                    ColliderBuilder::cuboid(width / 2.0, height / 2.0)
                }
                BodyShape::Circle { radius } => ColliderBuilder::ball(radius),
            }
        };
        builder
            .sensor(is_sensor)
            .restitution(body.restitution)
            .friction(body.friction)
            .collision_groups(groups)
            .active_events(ActiveEvents::COLLISION_EVENTS)
            .build()
    }
    /// Recreate the primary collider for `id` from the current body state.
    fn rebuild_collider(&mut self, id: usize) {
        let old_handle = self.collider_handles[id];
        let body_handle = self.body_handles[id];
        let (shape, shape_ext, restitution, friction, layer, mask, is_sensor) = {
            let b = &self.bodies[id];
            (
                b.shape,
                b.shape_ext.clone(),
                b.restitution,
                b.friction,
                b.layer,
                b.mask,
                b.body_type == BodyType::Sensor,
            )
        };
        self.rcolliders
            .remove(old_handle, &mut self.islands, &mut self.rbodies, true);
        let groups = self.collision_groups(layer, mask);
        let builder = if let Some(ref ext) = shape_ext {
            ext.to_rapier_collider().unwrap_or_else(|| match shape {
                BodyShape::Rect { width, height } => {
                    ColliderBuilder::cuboid(width / 2.0, height / 2.0)
                }
                BodyShape::Circle { radius } => ColliderBuilder::ball(radius),
            })
        } else {
            match shape {
                BodyShape::Rect { width, height } => {
                    ColliderBuilder::cuboid(width / 2.0, height / 2.0)
                }
                BodyShape::Circle { radius } => ColliderBuilder::ball(radius),
            }
        };
        let collider = builder
            .sensor(is_sensor)
            .restitution(restitution)
            .friction(friction)
            .collision_groups(groups)
            .active_events(ActiveEvents::COLLISION_EVENTS)
            .build();
        let new_handle =
            self.rcolliders
                .insert_with_parent(collider, body_handle, &mut self.rbodies);
        self.collider_to_body.remove(&old_handle);
        self.collider_to_body.insert(new_handle, id);
        self.collider_handles[id] = new_handle;
        self.cached_shapes[id] = shape;
        self.cached_restitutions[id] = restitution;
        self.cached_frictions[id] = friction;
        self.cached_layers[id] = (layer, mask);
        self.sync_extra_fixture_groups(id);
    }
    /// Look up the body id that owns `handle`.
    fn body_for_collider(&self, handle: ColliderHandle) -> Option<usize> {
        let id = self.collider_to_body.get(&handle).copied()?;
        self.has_body(id).then_some(id)
    }
    /// Apply the current body's collision groups to every extra fixture.
    fn sync_extra_fixture_groups(&mut self, id: usize) {
        if !self.has_body(id) {
            return;
        }
        let Some(body) = self.bodies.get(id) else {
            return;
        };
        let groups = self.collision_groups(body.layer, body.mask);
        if let Some(extras) = self.extra_collider_handles.get(id) {
            for &handle in extras {
                if let Some(collider) = self.rcolliders.get_mut(handle) {
                    collider.set_collision_groups(groups);
                }
            }
        }
    }
    /// Apply the current collision groups to the primary and extra fixtures for `id`.
    fn sync_body_collision_groups(&mut self, id: usize) {
        if !self.has_body(id) {
            return;
        }
        let Some(body) = self.bodies.get(id) else {
            return;
        };
        let groups = self.collision_groups(body.layer, body.mask);
        if let Some(&handle) = self.collider_handles.get(id) {
            if let Some(collider) = self.rcolliders.get_mut(handle) {
                collider.set_collision_groups(groups);
            }
        }
        if let Some(extras) = self.extra_collider_handles.get(id) {
            for &handle in extras {
                if let Some(collider) = self.rcolliders.get_mut(handle) {
                    collider.set_collision_groups(groups);
                }
            }
        }
    }
    /// Refresh every live collider after world-level collision policy changes.
    fn sync_all_collision_groups(&mut self) {
        for id in 0..self.bodies.len() {
            self.sync_body_collision_groups(id);
        }
    }
    /// Insert a body into the world and return its id.
    pub fn add_body(&mut self, body: Body) -> BodyId {
        let id = self.bodies.len();
        let rb = RigidBodyBuilder::new(Self::rapier_body_type(body.body_type))
            .translation(Vector::new(body.position.x, body.position.y))
            .linvel(Vector::new(body.velocity.x, body.velocity.y))
            .ccd_enabled(body.bullet)
            .build();
        let body_handle = self.rbodies.insert(rb);
        let collider = self.make_collider(&body);
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
        self.body_base_linear_damping.push(0.0);
        self.body_base_angular_damping.push(0.0);
        self.body_mass_overrides.push(None);
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
        Ok(extras.len())
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
    /// Return whether body `id` acts as a reflective mirror for beam tracing.
    pub fn is_body_mirror(&self, id: usize) -> bool {
        self.get_body(id).is_some_and(|body| body.reflective)
    }
    /// Enable or disable mirror-style beam reflection on body `id`.
    pub fn set_body_mirror(&mut self, id: usize, reflective: bool) {
        if let Some(body) = self.get_body_mut(id) {
            body.reflective = reflective;
        }
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
        let unit_dir = dir / max_toi;
        let ray = Ray::new(Vector::new(x1, y1), unit_dir);
        let qp = self.query_pipeline(filter);
        let (col_handle, ri) = qp.cast_ray_and_get_normal(&ray, max_toi, true)?;
        let body_id = self.body_for_collider(col_handle)?;
        if !self.has_body(body_id) {
            return None;
        }
        let pt_x = ray.origin.x + ray.dir.x * ri.time_of_impact;
        let pt_y = ray.origin.y + ray.dir.y * ri.time_of_impact;
        Some(RaycastHit {
            body_id: BodyId(body_id),
            point: (pt_x, pt_y),
            normal: (ri.normal.x, ri.normal.y),
            toi: ri.time_of_impact,
        })
    }
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
        if let Some(body) = self.get_body_mut(id) {
            body.mass = mass;
        }
        if let Some(slot) = self.body_mass_overrides.get_mut(id) {
            *slot = Some(mass);
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                let props = rb.mass_properties();
                rb.set_additional_mass(mass - props.local_mprops.mass(), true);
            }
        }
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

    fn reflect_vector(direction: Vector, normal: Vector) -> Option<Vector> {
        let normal_len_sq = normal.x * normal.x + normal.y * normal.y;
        if normal_len_sq <= 1e-12 {
            return None;
        }
        let inv_normal_len = normal_len_sq.sqrt().recip();
        let nx = normal.x * inv_normal_len;
        let ny = normal.y * inv_normal_len;
        let dot = direction.x * nx + direction.y * ny;
        let reflected_x = direction.x - 2.0 * dot * nx;
        let reflected_y = direction.y - 2.0 * dot * ny;
        let reflected_len_sq = reflected_x * reflected_x + reflected_y * reflected_y;
        if reflected_len_sq <= 1e-12 {
            return None;
        }
        let inv_reflected_len = reflected_len_sq.sqrt().recip();
        Some(Vector::new(
            reflected_x * inv_reflected_len,
            reflected_y * inv_reflected_len,
        ))
    }

    fn clamp_reflectivity(value: f32) -> f32 {
        if value.is_finite() {
            value.clamp(0.0, 1.0)
        } else {
            0.0
        }
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
        let dir_len = (dx * dx + dy * dy).sqrt();
        if dir_len < 1e-6 {
            return None;
        }
        let unit_dir = Vector::new(dx / dir_len, dy / dir_len);
        let ray = Ray::new(Vector::new(x1, y1), unit_dir);
        let qp = self.query_pipeline(filter);
        let (col_handle, toi_result) = qp.cast_ray_and_get_normal(&ray, max_dist, true)?;
        let body_id = self.body_for_collider(col_handle)?;
        if !self.has_body(body_id) {
            return None;
        }
        let pt_x = x1 + unit_dir.x * toi_result.time_of_impact;
        let pt_y = y1 + unit_dir.y * toi_result.time_of_impact;
        Some(RaycastHit {
            body_id: BodyId(body_id),
            point: (pt_x, pt_y),
            normal: (toi_result.normal.x, toi_result.normal.y),
            toi: toi_result.time_of_impact,
        })
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
        let anchor_id = self.add_body(anchor);
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
    /// Set the pixels-per-meter conversion ratio.
    pub fn set_meter(&mut self, ppm: f32) {
        self.pixels_per_meter = ppm;
    }
    /// Return the current pixels-per-meter ratio.
    pub fn get_meter(&self) -> f32 {
        self.pixels_per_meter
    }
    /// Convert a pixel distance to physics-space metres.
    pub fn to_physics(&self, px: f32) -> f32 {
        if self.pixels_per_meter > 0.0 {
            px / self.pixels_per_meter
        } else {
            px
        }
    }
    /// Convert a physics-space metre distance to pixels.
    pub fn to_pixels(&self, m: f32) -> f32 {
        m * self.pixels_per_meter
    }
    /// Return all active contact pairs with normals and touch state.
    pub fn get_contacts(&self) -> Vec<ContactInfo> {
        let mut contacts = Vec::new();
        let mut seen = HashSet::new();
        for pair in self.narrow_phase.contact_pairs() {
            let id_a = self.body_for_collider(pair.collider1);
            let id_b = self.body_for_collider(pair.collider2);
            if let (Some(a), Some(b)) = (id_a, id_b) {
                if a == b {
                    continue;
                }
                let key = if a <= b { (a, b) } else { (b, a) };
                if !seen.insert(key) {
                    continue;
                }
                let is_touching = pair.has_any_active_contact();
                let (nx, ny) = pair
                    .manifolds
                    .first()
                    .map(|m| (m.local_n1.x, m.local_n1.y))
                    .unwrap_or((0.0, 0.0));
                contacts.push(ContactInfo {
                    body_a: BodyId(a),
                    body_b: BodyId(b),
                    normal_x: nx,
                    normal_y: ny,
                    is_touching,
                });
            }
        }
        contacts
    }
    /// Return contacts involving body `body_id` filtered from `get_contacts`.
    pub fn get_body_contacts(&self, body_id: usize) -> Vec<ContactInfo> {
        self.get_contacts()
            .into_iter()
            .filter(|c| c.body_a.0 == body_id || c.body_b.0 == body_id)
            .collect()
    }
    /// Enable one-way platform behaviour: only accept collisions with a normal aligned to `(nx,ny)`.
    pub fn set_body_one_way(&mut self, id: usize, nx: f32, ny: f32) {
        if !self.has_body(id) {
            return;
        }
        if let Some(v) = self.one_way_normals.get_mut(id) {
            *v = Some((nx, ny));
        }
    }
    /// Remove the one-way constraint from body `id`.
    pub fn clear_body_one_way(&mut self, id: usize) {
        if let Some(v) = self.one_way_normals.get_mut(id) {
            *v = None;
        }
    }
    /// Return the one-way normal for body `id`, or `None` if not set.
    pub fn get_body_one_way(&self, id: usize) -> Option<(f32, f32)> {
        if !self.has_body(id) {
            return None;
        }
        self.one_way_normals.get(id).copied().flatten()
    }
    /// Register a break force threshold for joint `jid`.
    pub fn set_joint_break_force(&mut self, jid: usize, max_force: f32) {
        if self.has_joint(jid) {
            self.joint_break_forces.insert(jid, max_force);
        }
    }
    /// Return the break-force threshold for joint `jid`, or `None` if not set.
    pub fn get_joint_break_force(&self, jid: usize) -> Option<f32> {
        if !self.has_joint(jid) {
            return None;
        }
        self.joint_break_forces.get(&jid).copied()
    }
    /// Return true if body `id` is currently asleep.
    pub fn is_body_sleeping(&self, id: usize) -> bool {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get(handle) {
                return rb.is_sleeping();
            }
        }
        false
    }
    /// Wake up body `id` from sleep. This function is part of the public API.
    pub fn wake_up_body(&mut self, id: usize) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.wake_up(true);
            }
        }
    }
    /// Force body `id` to sleep immediately.
    pub fn sleep_body(&mut self, id: usize) {
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                rb.sleep();
            }
        }
    }
    /// Set the number of solver iterations (minimum 1).
    pub fn set_solver_iterations(&mut self, n: usize) {
        self.params.num_solver_iterations = n.max(1);
    }
    /// Return the current number of solver iterations.
    pub fn get_solver_iterations(&self) -> usize {
        self.params.num_solver_iterations
    }
    /// Return current world diagnostics for tooling and scripts.
    pub fn get_stats(&self) -> PhysicsWorldStats {
        let sleeping_bodies = self
            .get_body_ids()
            .into_iter()
            .filter(|&id| self.is_body_sleeping(id))
            .count();
        PhysicsWorldStats {
            bodies: self.body_count(),
            body_slots: self.bodies.len(),
            colliders: self.collider_to_body.len(),
            joints: self.joint_count(),
            joint_slots: self.joint_handles.len(),
            zones: self.zones.len(),
            gravity_vectors: self.gravity_vectors.iter().filter(|v| v.enabled).count(),
            flow_fields: self
                .flow_fields
                .iter()
                .filter(|field| field.enabled)
                .count(),
            sleeping_bodies,
            skipped_steps: self.diagnostics.skipped_steps,
            clamped_steps: self.diagnostics.clamped_steps,
            invalid_operations: self.diagnostics.invalid_operations,
            bodies_scanned: self.diagnostics.last_bodies_scanned,
            colliders_rebuilt: self.diagnostics.last_colliders_rebuilt,
            zone_checks: self.diagnostics.last_zone_checks,
            flow_samples: self.diagnostics.last_flow_samples,
            flow_affected_bodies: self.diagnostics.last_flow_affected_bodies,
            contacts: self.diagnostics.last_contacts,
            synced_bodies: self.diagnostics.last_synced_bodies,
        }
    }
    /// Batch-create bodies from a list of `(x, y, w, h, BodyType)` tuples; return their ids.
    pub fn add_bodies(&mut self, specs: Vec<(f32, f32, f32, f32, BodyType)>) -> Vec<usize> {
        specs
            .into_iter()
            .map(|(x, y, w, h, bt)| self.add_body(Body::new(x, y, w, h, bt)).0)
            .collect()
    }
}

fn flow_medium_scale(medium: FlowMedium, influence: super::body::BodyFlowInfluence) -> f32 {
    match medium {
        FlowMedium::Air => influence.air_scale,
        FlowMedium::Water => influence.water_scale,
        FlowMedium::Conveyor | FlowMedium::Magic | FlowMedium::Custom => 1.0,
    }
}

fn clamp_vector_to_limit(vx: f32, vy: f32, limit: Option<f32>) -> (f32, f32) {
    let Some(limit) = limit else {
        return (vx, vy);
    };
    let magnitude = (vx * vx + vy * vy).sqrt();
    if magnitude <= 1.0e-6 || magnitude <= limit {
        return (vx, vy);
    }
    let scale = limit / magnitude;
    (vx * scale, vy * scale)
}
