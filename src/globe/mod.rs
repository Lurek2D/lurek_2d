//! Globe rendering with orbit camera projection and LOD tiers.
//!
//! - Sub-modules: `composition`, `draw`, `export`, `fog`, and 13 more.

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
/// Globe synchronization helpers.
pub mod sync;
/// Globe topology helpers. This module is publicly re-exported.
pub mod topology;
/// Globe shared value types. This module is publicly re-exported.
pub mod types;
/// Sphere-surface coordinate helpers and rotation matrices.
pub mod sphere;
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
/// Shared globe value types (primary names).
pub use types::{
    FogState, GlobeError, GlobeSpec, HeatLayer, Label, LabelStyle, Layer, LodTier, Marker,
    MarkerShape, MarkerStyle, Region, RegionId, MAX_REGIONS,
};
/// Backward compatibility re-exports.
pub use types::{Province, ProvinceId, MAX_PROVINCES};
/// Region graph (primary name).
pub use topology::RegionGraph;
/// Backward compatibility: ProvinceGraph alias.
pub use topology::ProvinceGraph;
/// Projected region type.
pub use types::ProjectedRegion;
/// Backward compatibility: ProjectedProvince alias.
pub use types::ProjectedProvince;
