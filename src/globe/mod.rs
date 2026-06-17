//! Provides the high-level globe module boundary for region topology, projection, and visual overlay orchestration. `globe/mod` is the globe module index, declaring `composition`, `draw`, `export`, `fog`, `label`, and 12 more so agents can identify which files own each feature slice before opening implementation code.
//! Connects rendering, fog state, markers, labels, layers, and picking into one map-runtime surface. `src/globe/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `fog::{FogMask, FogStore}`, `picking::PickResult`, `projection::OrbitCamera`, `registry::{Globe, GlobeRegistry}`, and 7 more centralized for the globe subsystem.
//! Supports synchronization and loading flows so globe state can be updated from external game systems. The file documents how globe submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Delivers a cohesive planetary-view feature set for strategic map presentation and interaction. Agents should read this index to choose the narrow owner file first, because it maps names such as `composition`, `draw`, `export`, `fog`, `label`, and 12 more to concrete implementation responsibilities.
//! `globe/mod` is the globe module index, declaring `composition`, `draw`, `export`, `fog`, `label`, and 12 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/globe/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `fog::{FogMask, FogStore}`, `picking::PickResult`, `projection::OrbitCamera`, `registry::{Globe, GlobeRegistry}`, and 7 more centralized for the globe subsystem.

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
