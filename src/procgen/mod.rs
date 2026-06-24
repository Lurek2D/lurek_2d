//! This module is the procgen index, exposing noise, terrain, dungeon, graph, naming, and sampling generators.
//! It exports low-level primitives such as LCG, noise, flood fill, and scalar coloring for other generators to reuse.
//! It also exports higher-level builders such as BSP dungeons, room dungeons, WFC grids, and world-region graphs.
//! `mod.rs` owns visibility and reexport boundaries, not generated state, so feature responsibility stays in siblings.
//! Open this file to map which source owns caves, biomes, naming, Voronoi regions, or sandbox material simulation.
//! `noise.rs`, `heightmap.rs`, and `biome.rs` cover scalar-field generation plus terrain and climate interpretation.
//! `bsp.rs`, `rooms.rs`, `wfc.rs`, and `world_graph.rs` cover discrete layout, tiling, and connectivity generation.
//! `cellular.rs`, `cellular_world.rs`, `poisson.rs`, and `voronoi.rs` cover evolving grids and spatial sampling.

/// Biome classification types and rules-based classifier.
pub mod biome;
/// Binary Space Partitioning dungeon generator.
pub mod bsp;
/// Cellular automata cave map generator.
pub mod cellular;
/// Falling-sand cellular automaton world simulation (sand, water, fire, gas, rock).
pub mod cellular_world;
/// Scalar-to-colour RGBA conversion helpers.
pub mod color;
/// Shared procgen validation and resource-limit errors.
pub mod error;
/// 4-connected flood fill mask generator.
pub mod flood_fill;
/// Typed 2D grid result containers shared by procgen APIs.
pub mod grid_result;
/// FBM noise-based heightmap with optional erosion.
pub mod heightmap;
/// Linear Congruential Generator for deterministic seeding.
pub mod lcg;
/// Shared procgen dimension, byte-budget, and iteration limits.
pub mod limits;
/// L-system string rewriting and turtle geometry.
pub mod lsystem;
/// Markov-chain name generator.
pub mod namegen;
/// Perlin, Simplex, Worley, and fractal noise primitives.
pub mod noise;
/// Poisson disk point sampler. This module is publicly re-exported.
pub mod poisson;
/// Tileable sampled noise-grid helpers.
pub mod render;
/// Shared procgen report summaries.
pub mod report;
/// Random-room scatter dungeon generator.
pub mod rooms;
/// Voronoi diagram with optional domain warp.
pub mod voronoi;
/// Wave Function Collapse tile map generator.
pub mod wfc;
/// LLM-assisted WFC constraint and tile-weight generation.
pub mod wfc_llm;
/// World region graph with A*, Dijkstra, and Kruskal MST.
pub mod world_graph;

pub use biome::{biome_map_to_rgba, BiomeClassifier, BiomeRules, BiomeType};
pub use bsp::{
    bsp_dungeon, bsp_dungeon_with_prefabs, BspDungeon, BspOpts, BspPrefabStamp, BspRoom,
    PlacedBspPrefab,
};
pub use cellular::{cellular_automata, try_cellular_automata, CellularOpts};
pub use cellular_world::{
    default_palette, CellType, CellularWorld, CellularWorldActiveBounds, CellularWorldStepStats,
};
pub use color::scalar_map_to_rgba_bytes;
pub use error::ProcgenError;
pub use flood_fill::flood_fill;
pub use grid_result::{ProcgenGrid, ProcgenScalarGrid};
pub use heightmap::{ErosionMode, Heightmap, HeightmapErosionReport, HeightmapOpts};
pub use limits::ProcgenLimits;
pub use lsystem::LSystem;
pub use namegen::NameGen;
pub use noise::{
    fbm, generate_noise_map_parallel, perlin2d, perlin3d, perlin4d, perlin_noise_periodic,
    simplex2d, simplex_noise_2d, simplex_noise_3d, try_generate_noise_map_parallel, DistType,
    FractalType, MapGenOptions, NoiseGenerator, NoiseKind,
};
pub use poisson::{poisson_disk, try_poisson_disk};
pub use render::NoiseGrid;
pub use report::ProcgenReport;
pub use rooms::{
    rooms_dungeon, rooms_dungeon_with_prefabs, try_rooms_dungeon, PlacedRoomPrefab, Room,
    RoomPrefabStamp, RoomsDungeon, RoomsOpts,
};
pub use voronoi::{try_voronoi_diagram, voronoi_diagram, VoronoiOpts};
pub use wfc::{
    try_wfc_generate, wfc_generate, WfcFailureReason, WfcGrid, WfcOpts, WfcReport, WfcRules,
    WfcTile,
};
pub use wfc_llm::{
    parse_llm_constraints, parse_llm_wfc_response, try_parse_llm_constraints,
    try_parse_llm_wfc_response,
};
pub use world_graph::{generate_world_graph, WorldEdge, WorldGraph, WorldRegion};
