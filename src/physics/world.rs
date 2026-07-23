//! Owns the physics world implementation for the physics subsystem and keeps related runtime rules local here.
//! Keeps body state, simulation helpers, and authored world contracts so helpers stay close to invariants this updates.
//! Defines how physics world data is validated, transformed, or stored before neighboring systems consume it.
//! Separates physics world behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where physics code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing physics world defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the physics world state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping physics world calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse physics world rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on physics world state, helpers, or integration rules.
//! Works with neighboring physics owners while keeping the main physics world responsibility anchored in one file.
//! Changes to physics world names, caches, or helper boundaries should usually stay coupled inside this owner.
//! This file is the right stop for maintainers tracing physics world regressions back to their concrete owner boundary.

use super::altitude::{AltitudeHit, AltitudeLayer, BallisticProjectile, BodyAltitudeState};
use super::body::{Body, BodyShape, BodyType};
use super::error::PhysicsError;
use super::flow::{
    combine_contributions, FlowApplicationMode, FlowCombineMode, FlowField, FlowFieldId,
    FlowMedium, FlowSample,
};
use super::limits::{validate_finite, validate_positive, PhysicsLimits};
use super::material::{MaterialCombineRule, PhysicsMaterial};
use super::shape::Shape;
use super::types::BodyId;
use super::zone::{PhysicsZone, ZoneEvent, ZoneGravityFalloff, ZoneGravityMode, ZoneTracker};
#[allow(unused_imports)]
use crate::log_msg;
use crate::runtime::log_messages::{P001_PULLEY_JOINT_FALLBACK, P002_GEAR_JOINT_FALLBACK};
use rapier2d::prelude::*;
use std::collections::{HashMap, HashSet};
use std::sync::Mutex;

mod altitude;
mod bodies;
mod joints;
mod queries;
mod simulation;

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
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
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
/// One directional ray request for [`World::raycast_all_batch`].
/// # Fields
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct RaycastQuery {
    /// Ray origin X in world units.
    pub x: f32,
    /// Ray origin Y in world units.
    pub y: f32,
    /// Ray direction X component.
    pub dx: f32,
    /// Ray direction Y component.
    pub dy: f32,
    /// Maximum travel distance in world units.
    pub max_dist: f32,
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
/// # Variants
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
/// - `body_id`: stable source body id.
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
#[derive(Debug, Clone, PartialEq)]
pub struct PhysicsShapeSnapshot {
    /// Stable id of the source body.
    pub body_id: BodyId,
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
/// Immutable debug/tooling snapshot of the current physics shapes.
/// # Fields
#[derive(Debug, Clone, PartialEq)]
pub struct PhysicsSnapshot {
    /// Deterministic content-derived generation id.
    pub generation: u64,
    /// Stable-id shape records in ascending body-id order.
    pub shapes: Vec<PhysicsShapeSnapshot>,
}

/// Difference between two immutable physics snapshots.
/// # Fields
#[derive(Debug, Clone, PartialEq)]
pub struct PhysicsSnapshotDiff {
    /// Generation id of the source snapshot.
    pub from_generation: u64,
    /// Generation id of the target snapshot.
    pub to_generation: u64,
    /// Shapes introduced by the target snapshot.
    pub added: Vec<PhysicsShapeSnapshot>,
    /// Stable ids removed by the target snapshot.
    pub removed: Vec<BodyId>,
    /// Shapes whose record changed between snapshots.
    pub changed: Vec<PhysicsShapeSnapshot>,
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
/// - `body_materials`: body-default material snapshots kept in sync with direct setters.
/// - `fixture_materials`: extra-fixture material snapshots keyed by `(body_id, fixture_index)`.
/// - `altitude_layer`: optional terrain-height grid used for terrain-relative altitude rules.
/// - `body_altitudes`: per-body vertical sidecar state keyed by stable body id.
/// - `ballistic_projectiles`: engine-owned projectile slots keyed by stable projectile id.
/// - `ballistic_projectile_hits`: buffered projectile hit events from the last step.
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
    /// Body-default material snapshots for the primary collider and body-owned material metadata.
    body_materials: Vec<PhysicsMaterial>,
    /// Material snapshots for fixture overrides; primary collider uses `body_materials`.
    fixture_materials: HashMap<(usize, usize), PhysicsMaterial>,
    /// Optional authored terrain-height and clearance grid.
    altitude_layer: Option<AltitudeLayer>,
    /// Optional vertical sidecar state keyed by stable body id.
    body_altitudes: HashMap<usize, BodyAltitudeState>,
    /// Engine-owned ballistic projectile slots keyed by stable projectile id.
    ballistic_projectiles: Vec<Option<BallisticProjectile>>,
    /// Buffered ballistic projectile hit events emitted during stepping.
    ballistic_projectile_hits: Vec<AltitudeHit>,
    /// Optional toroidal wrap rectangle `(min_x, min_y, max_x, max_y)` for top-down arenas.
    wrap_bounds: Option<(f32, f32, f32, f32)>,
    /// Default linear damping assigned to new top-down bodies.
    top_down_linear_damping: f32,
    /// Default angular damping assigned to new top-down bodies.
    top_down_angular_damping: f32,
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
    /// Return the shared strict-physics limits currently attached to this world.
    pub fn limits(&self) -> &PhysicsLimits {
        &self.limits
    }

    /// Replace limits after ensuring they still accommodate live world state.
    pub fn set_limits(&mut self, limits: PhysicsLimits) -> Result<(), PhysicsError> {
        if limits.min_step_dt <= 0.0
            || !limits.min_step_dt.is_finite()
            || limits.max_step_dt < limits.min_step_dt
            || !limits.max_step_dt.is_finite()
            || limits.max_fixed_steps == 0
            || limits.max_solver_iterations == 0
            || limits.max_ccd_substeps == 0
            || limits.max_contact_events == 0
            || limits.max_query_hits == 0
            || limits.max_beam_bounces == 0
            || limits.max_ballistic_projectile_slots == 0
            || limits.max_debug_shapes == 0
            || limits.max_ballistic_samples == 0
            || limits.max_bodies == 0
            || limits.max_body_slots == 0
            || limits.max_colliders_per_body == 0
            || limits.max_joints == 0
            || limits.max_zones == 0
            || limits.max_gravity_vectors == 0
            || limits.max_flow_fields == 0
            || limits.max_terrain_cells == 0
            || limits.max_liquid_cells == 0
            || limits.max_terrain_component_scan_cells == 0
            || limits.max_terrain_component_results == 0
            || limits.max_terrain_component_cells == 0
            || limits.max_active_liquid_cells == 0
            || limits.max_output_bytes == 0
            || limits.max_polygon_vertices < 3
            || limits.max_chain_vertices < 2
        {
            return Err(PhysicsError::ConfigMismatch {
                context: "physics limits",
                detail:
                    "step and solver limits must be finite, positive, and internally consistent"
                        .into(),
            });
        }
        if self.body_count() > limits.max_bodies {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics bodies",
                count: self.body_count(),
                max: limits.max_bodies,
            });
        }
        if self.bodies.len() > limits.max_body_slots {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics body slots",
                count: self.bodies.len(),
                max: limits.max_body_slots,
            });
        }
        if self.ballistic_projectiles.len() > limits.max_ballistic_projectile_slots {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics ballistic projectile slots",
                count: self.ballistic_projectiles.len(),
                max: limits.max_ballistic_projectile_slots,
            });
        }
        if self.gravity_vectors.len() > limits.max_gravity_vectors {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics gravity vectors",
                count: self.gravity_vectors.len(),
                max: limits.max_gravity_vectors,
            });
        }
        if self.flow_fields.len() > limits.max_flow_fields {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics flow fields",
                count: self.flow_fields.len(),
                max: limits.max_flow_fields,
            });
        }
        if self.params.num_solver_iterations > limits.max_solver_iterations
            || self.params.max_ccd_substeps > limits.max_ccd_substeps
        {
            return Err(PhysicsError::ConfigMismatch {
                context: "physics limits",
                detail: "new solver ceilings are below the current world configuration".into(),
            });
        }
        self.limits = limits;
        Ok(())
    }

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
                super::flow::FlowGeometry::DirectionalFan {
                    cx,
                    cy,
                    radius,
                    inner_radius,
                    facing,
                    half_angle_deg,
                } => {
                    let cx_i = cx.round() as i32;
                    let cy_i = cy.round() as i32;
                    img.draw_circle(
                        cx_i,
                        cy_i,
                        radius.round().max(1.0) as u32,
                        90,
                        220,
                        255,
                        220,
                    );
                    if *inner_radius > 0.0 {
                        img.draw_circle(
                            cx_i,
                            cy_i,
                            inner_radius.round().max(1.0) as u32,
                            60,
                            140,
                            170,
                            180,
                        );
                    }
                    let facing = if facing.length() > 1.0e-6 {
                        *facing / facing.length()
                    } else {
                        crate::math::Vec2::new(1.0, 0.0)
                    };
                    let half_angle = half_angle_deg.to_radians();
                    for angle in [-half_angle, 0.0, half_angle] {
                        let dir = facing.rotate(angle);
                        let ex = (*cx + dir.x * *radius).round() as i32;
                        let ey = (*cy + dir.y * *radius).round() as i32;
                        img.draw_line(cx_i, cy_i, ex, ey, 255, 200, 70, 220);
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

    /// Draws altitude-layer cells, body vertical ranges, and ballistic arcs into an RGBA image target.
    pub fn draw_altitude_debug_to_image(
        &self,
        img: &mut crate::image::ImageData,
        draw_layer: bool,
        draw_bodies: bool,
        draw_projectiles: bool,
    ) {
        if draw_layer {
            if let Some(layer) = &self.altitude_layer {
                let cell_size = layer.cell_size().max(1.0);
                let visible_cols = (((img.width() as f32) / cell_size).ceil() as u32)
                    .saturating_add(1)
                    .min(layer.width());
                let visible_rows = (((img.height() as f32) / cell_size).ceil() as u32)
                    .saturating_add(1)
                    .min(layer.height());
                for cy in 0..visible_rows {
                    for cx in 0..visible_cols {
                        let Ok(height) = layer.get_cell_height(cx, cy) else {
                            continue;
                        };
                        let Ok(clearance) = layer.get_cell_clearance(cx, cy) else {
                            continue;
                        };
                        let x0 = (cx as f32 * cell_size).round() as i32;
                        let y0 = (cy as f32 * cell_size).round() as i32;
                        let x1 = ((cx + 1) as f32 * cell_size).round() as i32;
                        let y1 = ((cy + 1) as f32 * cell_size).round() as i32;
                        let center_x = (x0 + x1) / 2;
                        let center_y = (y0 + y1) / 2;
                        let height_tint = (height.abs() * 18.0).clamp(0.0, 120.0) as u8;
                        let clearance_tint = (clearance.abs() * 12.0).clamp(0.0, 120.0) as u8;
                        let border_r = 55u8.saturating_add(height_tint);
                        let border_g = 90u8.saturating_add(clearance_tint / 2);
                        let border_b = 120u8.saturating_add(clearance_tint);
                        img.draw_line(x0, y0, x1, y0, border_r, border_g, border_b, 160);
                        img.draw_line(x1, y0, x1, y1, border_r, border_g, border_b, 160);
                        img.draw_line(x1, y1, x0, y1, border_r, border_g, border_b, 160);
                        img.draw_line(x0, y1, x0, y0, border_r, border_g, border_b, 160);
                        img.draw_circle(
                            center_x,
                            center_y,
                            2 + (clearance.abs() / 8.0).clamp(0.0, 2.0) as u32,
                            80,
                            170,
                            240,
                            180,
                        );
                        let height_offset = height
                            .round()
                            .clamp(-(img.height() as f32), img.height() as f32)
                            as i32;
                        if height_offset != 0 {
                            img.draw_line(
                                center_x,
                                center_y,
                                center_x,
                                center_y - height_offset,
                                255,
                                220,
                                100,
                                200,
                            );
                        }
                    }
                }
            }
        }

        if draw_bodies {
            for (id, body) in self.bodies.iter().enumerate() {
                if !self.has_body(id) {
                    continue;
                }
                let state = self.body_altitude_state(id).unwrap_or_default();
                let ground_height = self
                    .sample_ground_height(body.position.x, body.position.y)
                    .unwrap_or(0.0);
                let height_extent = self
                    .get_body_height_extent(id)
                    .unwrap_or_else(|| body.width.max(body.height).max(1.0));
                let (z_min, z_max) = state.world_z_range(ground_height, height_extent);
                let center_x = body.position.x.round() as i32;
                let center_y = body.position.y.round() as i32;
                let base_y = center_y - z_min.round() as i32;
                let top_y = center_y - z_max.round() as i32;
                let (body_r, body_g, body_b) = match state.mode {
                    super::altitude::AltitudeMode::Ground => (90, 220, 140),
                    super::altitude::AltitudeMode::Airborne => (90, 200, 255),
                    super::altitude::AltitudeMode::Ballistic => (255, 180, 70),
                    super::altitude::AltitudeMode::Fixed => (255, 110, 110),
                };
                match body.shape {
                    super::body::BodyShape::Circle { radius } => {
                        img.draw_circle(
                            center_x,
                            center_y,
                            radius.round().max(1.0) as u32,
                            body_r,
                            body_g,
                            body_b,
                            180,
                        );
                    }
                    super::body::BodyShape::Rect { width, height } => {
                        let half_w = (width * 0.5).round() as i32;
                        let half_h = (height * 0.5).round() as i32;
                        let x0 = center_x - half_w;
                        let y0 = center_y - half_h;
                        let x1 = center_x + half_w;
                        let y1 = center_y + half_h;
                        img.draw_line(x0, y0, x1, y0, body_r, body_g, body_b, 180);
                        img.draw_line(x1, y0, x1, y1, body_r, body_g, body_b, 180);
                        img.draw_line(x1, y1, x0, y1, body_r, body_g, body_b, 180);
                        img.draw_line(x0, y1, x0, y0, body_r, body_g, body_b, 180);
                    }
                }
                img.draw_circle(center_x, center_y, 2, body_r, body_g, body_b, 255);
                img.draw_line(
                    center_x, base_y, center_x, top_y, body_r, body_g, body_b, 220,
                );
                img.draw_line(
                    center_x - 2,
                    base_y,
                    center_x + 2,
                    base_y,
                    220,
                    220,
                    220,
                    220,
                );
                img.draw_line(center_x - 2, top_y, center_x + 2, top_y, 255, 240, 160, 220);
            }
        }

        if draw_projectiles {
            for projectile in self.ballistic_projectiles.iter().flatten() {
                let current_x = projectile.position.0.round() as i32;
                let current_y = (projectile.position.1 - projectile.position.2).round() as i32;
                img.draw_circle(current_x, current_y, 2, 255, 210, 80, 255);

                let mut position = projectile.position;
                let mut velocity = projectile.velocity;
                let mut remaining = projectile.time_remaining.max(0.0);
                let mut steps = 0usize;
                while remaining > 1.0e-6 && steps < 128 {
                    let step_dt = projectile.sample_dt.min(remaining).max(1.0e-4);
                    let next_vz = velocity.2 + projectile.gravity * step_dt;
                    let next_position = (
                        position.0 + velocity.0 * step_dt,
                        position.1 + velocity.1 * step_dt,
                        position.2 + next_vz * step_dt,
                    );
                    let seg_dx = next_position.0 - position.0;
                    let seg_dy = next_position.1 - position.1;
                    let seg_dist = (seg_dx * seg_dx + seg_dy * seg_dy).sqrt();
                    let filter = PhysicsQueryFilter {
                        exclude_body: projectile.owner.map(BodyId),
                        ..PhysicsQueryFilter::default()
                    };
                    let impact = if seg_dist > 1.0e-6 {
                        self.try_cast_circle_25d(
                            super::altitude::CircleCast25DOptions {
                                x: position.0,
                                y: position.1,
                                z: position.2,
                                radius: projectile.radius,
                                height: projectile.height,
                                dx: seg_dx,
                                dy: seg_dy,
                                dz: next_position.2 - position.2,
                                max_dist: seg_dist,
                            },
                            filter,
                        )
                        .ok()
                        .flatten()
                    } else {
                        None
                    };

                    let (x1, y1) = match impact {
                        Some(hit) => (
                            hit.point.0.round() as i32,
                            (hit.point.1 - hit.z).round() as i32,
                        ),
                        None => (
                            next_position.0.round() as i32,
                            (next_position.1 - next_position.2).round() as i32,
                        ),
                    };
                    let x0 = position.0.round() as i32;
                    let y0 = (position.1 - position.2).round() as i32;
                    img.draw_line(x0, y0, x1, y1, 255, 200, 70, 210);

                    if impact.is_some() {
                        img.draw_circle(x1, y1, 3, 255, 120, 120, 255);
                        break;
                    }

                    position = next_position;
                    velocity.2 = next_vz;
                    remaining -= step_dt;
                    steps += 1;
                }
            }
        }
    }
    /// Return a snapshot of all body shapes suitable for debug rendering.
    pub fn extract_shape_snapshots(&self) -> Vec<PhysicsShapeSnapshot> {
        let mut out = Vec::with_capacity(self.bodies.len().min(self.limits.max_debug_shapes));
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
                body_id: BodyId(idx),
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
            if out.len() == self.limits.max_debug_shapes {
                break;
            }
        }
        out
    }

    /// Return an immutable, stable-id snapshot for render, pathfinding, or tooling consumers.
    pub fn physics_snapshot(&self) -> PhysicsSnapshot {
        let shapes = self.extract_shape_snapshots();
        let mut generation = 0xcbf2_9ce4_8422_2325_u64;
        for shape in &shapes {
            generation ^= shape.body_id.0 as u64;
            generation = generation.wrapping_mul(0x100_0000_01b3);
            for value in [shape.x, shape.y, shape.half_w, shape.half_h, shape.angle] {
                generation ^= u64::from(value.to_bits());
                generation = generation.wrapping_mul(0x100_0000_01b3);
            }
        }
        PhysicsSnapshot { generation, shapes }
    }

    /// Compare two immutable snapshots without exposing mutable world state.
    pub fn diff_physics_snapshots(
        previous: &PhysicsSnapshot,
        current: &PhysicsSnapshot,
    ) -> PhysicsSnapshotDiff {
        let before: HashMap<usize, &PhysicsShapeSnapshot> = previous
            .shapes
            .iter()
            .map(|shape| (shape.body_id.0, shape))
            .collect();
        let after: HashMap<usize, &PhysicsShapeSnapshot> = current
            .shapes
            .iter()
            .map(|shape| (shape.body_id.0, shape))
            .collect();
        let mut added = current
            .shapes
            .iter()
            .filter(|shape| !before.contains_key(&shape.body_id.0))
            .cloned()
            .collect::<Vec<_>>();
        let mut removed = previous
            .shapes
            .iter()
            .filter(|shape| !after.contains_key(&shape.body_id.0))
            .map(|shape| shape.body_id)
            .collect::<Vec<_>>();
        let mut changed = current
            .shapes
            .iter()
            .filter(|shape| {
                before
                    .get(&shape.body_id.0)
                    .is_some_and(|old| *old != *shape)
            })
            .cloned()
            .collect::<Vec<_>>();
        added.sort_by_key(|shape| shape.body_id.0);
        removed.sort_by_key(|id| id.0);
        changed.sort_by_key(|shape| shape.body_id.0);
        PhysicsSnapshotDiff {
            from_generation: previous.generation,
            to_generation: current.generation,
            added,
            removed,
            changed,
        }
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
            body_materials: Vec::new(),
            fixture_materials: HashMap::new(),
            altitude_layer: None,
            body_altitudes: HashMap::new(),
            ballistic_projectiles: Vec::new(),
            ballistic_projectile_hits: Vec::new(),
            wrap_bounds: None,
            top_down_linear_damping: 0.0,
            top_down_angular_damping: 0.0,
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
    fn default_body_material_for(body: &Body) -> PhysicsMaterial {
        PhysicsMaterial {
            density: 1.0,
            friction: body.friction,
            restitution: body.restitution,
            linear_damping: Some(0.0),
            angular_damping: Some(0.0),
            gravity_scale: Some(1.0),
            mass_override: None,
            beam_reflectivity: body.beam_reflectivity,
            projectile_reflectivity: body.projectile_reflectivity,
            ..PhysicsMaterial::default()
        }
    }
    fn default_fixture_material(density: f32, friction: f32, restitution: f32) -> PhysicsMaterial {
        PhysicsMaterial {
            density,
            friction,
            restitution,
            ..PhysicsMaterial::default().fixture_scope()
        }
    }
    fn sync_body_material_snapshot(&mut self, id: usize) {
        if !self.has_body(id) {
            return;
        }
        let Some(body) = self.bodies.get(id) else {
            return;
        };
        let Some(material) = self.body_materials.get_mut(id) else {
            return;
        };
        material.friction = body.friction;
        material.restitution = body.restitution;
        material.beam_reflectivity = body.beam_reflectivity;
        material.projectile_reflectivity = body.projectile_reflectivity;
        material.linear_damping = self.body_base_linear_damping.get(id).copied();
        material.angular_damping = self.body_base_angular_damping.get(id).copied();
        material.gravity_scale = self.body_base_gravity_scales.get(id).copied();
        material.mass_override = self.body_mass_overrides.get(id).and_then(|value| *value);
    }
    fn set_body_mass_override_internal(&mut self, id: usize, mass: Option<f32>) {
        if let Some(slot) = self.body_mass_overrides.get_mut(id) {
            *slot = mass;
        }
        if let Some(body) = self.get_body_mut(id) {
            if let Some(value) = mass {
                body.mass = value;
            }
        }
        if let Some(handle) = self.active_body_handle(id) {
            if let Some(rb) = self.rbodies.get_mut(handle) {
                let additional = match mass {
                    Some(value) => value - rb.mass_properties().local_mprops.mass(),
                    None => 0.0,
                };
                rb.set_additional_mass(additional, true);
            }
        }
        self.sync_body_material_snapshot(id);
    }
    /// Build a rapier `Collider` from a body's shape and filter settings.
    fn material_combine_rule(rule: MaterialCombineRule) -> CoefficientCombineRule {
        match rule {
            MaterialCombineRule::Average => CoefficientCombineRule::Average,
            MaterialCombineRule::Min => CoefficientCombineRule::Min,
            MaterialCombineRule::Multiply => CoefficientCombineRule::Multiply,
            MaterialCombineRule::Max => CoefficientCombineRule::Max,
        }
    }

    fn make_collider(&self, body: &Body, material: &PhysicsMaterial) -> Collider {
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
            .density(material.density)
            .sensor(is_sensor)
            .restitution(body.restitution)
            .friction(body.friction)
            .friction_combine_rule(Self::material_combine_rule(material.friction_combine_rule))
            .restitution_combine_rule(Self::material_combine_rule(
                material.restitution_combine_rule,
            ))
            .collision_groups(groups)
            .active_events(ActiveEvents::COLLISION_EVENTS)
            .build()
    }
    /// Recreate the primary collider for `id` from the current body state.
    fn rebuild_collider(&mut self, id: usize) {
        let old_handle = self.collider_handles[id];
        let body_handle = self.body_handles[id];
        let material = self.body_materials.get(id).cloned().unwrap_or_default();
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
            .density(material.density)
            .sensor(is_sensor)
            .restitution(restitution)
            .friction(friction)
            .friction_combine_rule(Self::material_combine_rule(material.friction_combine_rule))
            .restitution_combine_rule(Self::material_combine_rule(
                material.restitution_combine_rule,
            ))
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
    /// Set the pixels-per-meter conversion ratio after strict finite validation.
    pub fn try_set_meter(&mut self, ppm: f32) -> Result<(), PhysicsError> {
        validate_positive("pixels per meter", f64::from(ppm))?;
        self.pixels_per_meter = ppm;
        Ok(())
    }
    /// Compatibility setter that records rejected input without corrupting conversions.
    pub fn set_meter(&mut self, ppm: f32) {
        if self.try_set_meter(ppm).is_err() {
            self.record_invalid_operation();
        }
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
    /// Set the number of solver iterations within the configured work ceiling.
    pub fn try_set_solver_iterations(&mut self, n: usize) -> Result<(), PhysicsError> {
        if n == 0 || n > self.limits.max_solver_iterations {
            return Err(PhysicsError::ValueOutOfRange {
                field: "solver iterations",
                min: 1.0,
                max: self.limits.max_solver_iterations as f64,
                value: n as f64,
            });
        }
        self.params.num_solver_iterations = n;
        Ok(())
    }
    /// Compatibility setter that records rejected values.
    pub fn set_solver_iterations(&mut self, n: usize) {
        if self.try_set_solver_iterations(n).is_err() {
            self.record_invalid_operation();
        }
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
    pub fn try_add_bodies(
        &mut self,
        specs: Vec<(f32, f32, f32, f32, BodyType)>,
    ) -> Result<Vec<usize>, PhysicsError> {
        let bodies = specs
            .into_iter()
            .map(|(x, y, w, h, bt)| Body::try_new(x, y, w, h, bt))
            .collect::<Result<Vec<_>, _>>()?;
        Ok(self
            .try_add_body_objects(bodies)?
            .into_iter()
            .map(|id| id.0)
            .collect())
    }

    /// Batch-insert already authored bodies after validating every body and both body ceilings.
    pub fn try_add_body_objects(&mut self, bodies: Vec<Body>) -> Result<Vec<BodyId>, PhysicsError> {
        let requested = bodies.len();
        let count = self.body_count().saturating_add(requested);
        if count > self.limits.max_bodies {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics bodies",
                count,
                max: self.limits.max_bodies,
            });
        }
        let slots = self.bodies.len().saturating_add(requested);
        if slots > self.limits.max_body_slots {
            return Err(PhysicsError::CountLimitExceeded {
                context: "physics body slots",
                count: slots,
                max: self.limits.max_body_slots,
            });
        }
        for body in &bodies {
            body.validate(&self.limits)?;
        }
        Ok(bodies
            .into_iter()
            .map(|body| self.add_body_unchecked(body))
            .collect())
    }
    /// Compatibility batch constructor that records rejected batches atomically.
    pub fn add_bodies(&mut self, specs: Vec<(f32, f32, f32, f32, BodyType)>) -> Vec<usize> {
        match self.try_add_bodies(specs) {
            Ok(ids) => ids,
            Err(_) => {
                self.record_invalid_operation();
                Vec::new()
            }
        }
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
