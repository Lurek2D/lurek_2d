//! This module delivers the raycast feature stack that turns a 2D tile field into a readable first-person space with walls, floors, ceilings, sprites, and moving doors.
//! It combines DDA stepping, projection, scene building, visibility, lighting, and helper render paths so game code can ask for either gameplay queries or full presentation output.
//! Support code for elevation, multilevel layouts, picking, depth, and debug visualization lives beside the core marcher so the subsystem keeps one camera model end to end.
//! At the highest level, this is the part of the engine that gives Lua and Rust callers a classic grid-based 3D view without leaving the 2D runtime architecture.
//! `raycaster/mod` is the raycaster module index, declaring `build_scene`, `column_batch`, `dda`, `depth_buffer`, `doors`, and 18 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/raycaster/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `build_scene::{DirectionalSpriteTextures, LevelSprite, SceneBuildParams, WorldSprite}`, `column_batch::{ColumnBatch, ColumnData}`, `dda::Raycaster2D`, `depth_buffer::DepthBuffer`, and 17 more centralized for the raycaster subsystem.
//! The file documents how raycaster submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Agents should read this index to choose the narrow owner file first, because it maps names such as `build_scene`, `column_batch`, `dda`, `depth_buffer`, `doors`, and 18 more to concrete implementation responsibilities.

/// Raycaster scene construction from camera and world grid.
pub mod build_scene;
/// Per-column batch data passed to the renderer.
pub mod column_batch;
/// DDA (digital differential analysis) ray-stepping core.
pub mod dda;
/// Per-pixel depth buffer used for sprite occlusion.
pub mod depth_buffer;
/// Door state machine and door manager.
pub mod doors;
/// High-level draw call assembly for a full raycasted frame.
pub mod draw;
/// Grid-aligned player movement helpers.
pub mod grid_motion;
/// Variable floor/ceiling height map.
pub mod heightmap;
/// Level rendering helpers for multi-level raycaster.
pub mod level_render;
/// Distance-based wall and sprite lighting.
pub mod lighting;
/// Multi-level grid with floor/ceiling holes.
pub mod multilevel;
/// Column projection math: wall slice height and screen coordinates.
pub mod projection;
/// Ray-hit record produced by a single DDA ray.
pub mod ray_hit;
/// Top-level render dispatch for a raycaster frame.
pub mod render;
/// `RaycasterScene` and its constituent quad/sprite/mesh types.
pub mod scene;
/// Runtime adapter for mapping static or physics-backed 2D entities into raycaster scene inputs.
pub mod scene_adapter;
/// 2D line segment and `cast_ray_2d` entry point.
pub mod segment;
/// Sprite registry and frustum-sorted sprite list.
pub mod sprite_manager;
/// Screen-space sprite projection math.
pub mod sprite_projection;
/// Tile picker: screen-to-tile coordinate mapping.
pub mod tile_picker;
/// Field-of-view visibility grid computation.
pub mod visibility;
/// Debug visualization helpers (ray paths, normals, tiles).
pub mod visualization;
/// Per-cell wall feature descriptors for doors, windows, and half-height walls.
pub mod wall_feature;

pub use build_scene::{DirectionalSpriteTextures, LevelSprite, SceneBuildParams, WorldSprite};
pub use column_batch::{ColumnBatch, ColumnData};
pub use dda::Raycaster2D;
pub use depth_buffer::DepthBuffer;
pub use doors::{Door, DoorDirection, DoorManager, DoorState};
pub use grid_motion::{dir4_delta, try_move, GridMoveAction};
pub use heightmap::HeightMap;
pub use level_render::{compute_hole_visibility, LevelRenderConfig, TileHighlight};
pub use lighting::{apply_lit_shade, compute_lighting, PointLight};
pub use multilevel::{MultiLevelGrid, RaycasterLevel};
pub use projection::{distance_shade, project_column};
pub use ray_hit::RayHit;
pub use scene::{
    BillboardSprite, CeilingQuad, EntityPickKind, EntityPickResult, FloorQuad, ModelMesh,
    RaycasterBuildStats, RaycasterScene, WallQuad,
};
#[cfg(feature = "obj-loader")]
pub use scene_adapter::{ResolvedSceneModel, SceneAdapterModel};
pub use scene_adapter::{
    ResolvedSceneTransform, SceneAdapter, SceneAdapterLight, SceneAdapterSprite, SceneTransform,
};
pub use segment::{cast_ray_2d, Segment};
pub use sprite_manager::{
    DirectionalSpriteTextures as ManagedDirectionalSpriteTextures, DirectionalSpriteVariant,
    SpriteManager, WorldSprite as ManagedSprite,
};
pub use sprite_projection::SpriteProjection;
pub use tile_picker::{PickResult, PickSurface, PickWallSection, ScreenPickParams, TilePicker};
pub use visibility::field_of_view;
pub use wall_feature::{WallFeature, WallFeatureKind};
