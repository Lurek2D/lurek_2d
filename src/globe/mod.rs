//! Exports the globe subsystem surface that groups topology, projection, loading, rendering, overlays, and syncing.
//! Acts as the navigation index for globe drawing, fog, labels, markers, picking, registry state, and type owners.
//! Keeps the module boundary explicit so callers can find whether a globe concern belongs to storage, math, or draw.
//! Open this file when adding or retiring globe submodules or when re-export policy for shared globe APIs changes.
//! The exported set here connects runtime state, geographic math, import paths, visual overlays, and sync helpers.
//! Agents should start here when tracing globe behavior because it reveals the authoritative file split by concern.
//! This index owns visibility and compatibility re-exports rather than camera state, topology caches, or draw code.
//! Neighboring work usually spans Globe, RegionGraph, OrbitCamera, fog state, and frame emission helpers below.

/// Globe composition helpers. This module is publicly re-exported.
pub mod composition;
/// Globe drawing helpers. This module is publicly re-exported.
pub mod draw;
/// Globe export helpers. This module is publicly re-exported.
pub mod export;
/// Fog overlay helpers. This module is publicly re-exported.
pub mod fog;
/// Globe label helpers. This module is publicly re-exported.
pub mod label;
/// Globe layer helpers. This module is publicly re-exported.
pub mod layer;
/// Globe lighting helpers. This module is publicly re-exported.
pub mod lighting;
/// Globe loading helpers. This module is publicly re-exported.
pub mod loader;
/// Globe marker helpers. This module is publicly re-exported.
pub mod marker;
/// Globe picking helpers. This module is publicly re-exported.
pub mod picking;
/// Globe camera projection helpers.
pub mod projection;
/// Province adapter helpers. This module is publicly re-exported.
pub mod province_adapter;
/// Globe registry state. This module is publicly re-exported.
pub mod registry;
/// Sphere-surface coordinate helpers and rotation matrices.
pub mod sphere;
/// Globe synchronization helpers.
pub mod sync;
/// Globe topology helpers. This module is publicly re-exported.
pub mod topology;
/// Globe shared value types. This module is publicly re-exported.
pub mod types;
/// Fog state and mask types.
pub use fog::{FogMask, FogStore};
/// Picking result type.
pub use picking::PickResult;
/// Orbit camera type used for globe projection.
pub use projection::OrbitCamera;
/// Globe registry types.
pub use registry::{Globe, GlobeRegistry};
/// Synchronization channel and snapshot types.
pub use sync::{GlobeSyncChannel, GlobeSyncSnapshot};
/// Backward compatibility: ProvinceGraph alias.
pub use topology::ProvinceGraph;
/// Region graph (primary name).
pub use topology::RegionGraph;
/// Backward compatibility: ProjectedProvince alias.
pub use types::ProjectedProvince;
/// Projected region type.
pub use types::ProjectedRegion;
/// Shared globe value types (primary names).
pub use types::{
    FogState, GlobeError, GlobeSpec, HeatLayer, Label, LabelStyle, Layer, LodTier, Marker,
    MarkerShape, MarkerStyle, Region, RegionId, MAX_REGIONS,
};
/// Backward compatibility re-exports.
pub use types::{Province, ProvinceId, MAX_PROVINCES};
