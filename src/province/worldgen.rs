//! Random province-map generation using jittered grid + Voronoi tessellation.
//!
//! Generates a [`ProvinceMap`] procedurally without requiring a source PNG.
//! Uses [`crate::math::RandomGenerator`] for determinism and
//! [`crate::math::voronoi_diagram`] for pixel assignment. Terrain and other
//! properties are NOT assigned — the game developer does that in Lua.

use std::collections::HashMap;

use crate::math::{voronoi_diagram, RandomGenerator, Vec2, VoronoiOpts};

use super::adjacency::detect_adjacency;
use super::core::{Province, ProvinceMap};
use super::loader::color_to_id;

/// Configuration for random world generation.
#[derive(Debug, Clone)]
pub struct WorldGenConfig {
    /// Map width in pixels.
    pub width: u32,
    /// Map height in pixels.
    pub height: u32,
    /// Approximate number of provinces to generate.
    pub province_count: u32,
    /// RNG seed for deterministic generation.
    pub seed: u64,
}

impl Default for WorldGenConfig {
    fn default() -> Self {
        Self {
            width: 800,
            height: 400,
            province_count: 100,
            seed: 42,
        }
    }
}

/// Generate a random province map using Voronoi tessellation.
///
/// 1. Places seed points on a jittered grid (deterministic via seed).
/// 2. Assigns each pixel to the nearest seed via [`voronoi_diagram`].
/// 3. Computes area, centroid, and bounding box per province.
/// 4. Runs adjacency detection.
///
/// Province properties (terrain, owner, etc.) are NOT set here — the game
/// developer assigns them in Lua after generation via [`ProvinceProperties`].
pub fn generate_world(config: &WorldGenConfig) -> ProvinceMap {
    let mut rng = RandomGenerator::with_seed(config.seed);

    // Calculate grid dimensions for ~province_count cells
    let aspect = config.width as f32 / config.height as f32;
    let cols = ((config.province_count as f32 * aspect).sqrt()).ceil() as u32;
    let rows = ((config.province_count as f32 / aspect).sqrt()).ceil() as u32;
    let actual_count = cols * rows;

    let cell_w = config.width as f32 / cols as f32;
    let cell_h = config.height as f32 / rows as f32;

    // Generate seed points with jitter and assign unique colours
    struct Seed {
        x: f32,
        y: f32,
        color: [u8; 3],
        id: u32,
    }

    let mut seeds = Vec::with_capacity(actual_count as usize);
    let mut used_ids = std::collections::HashSet::new();

    for row in 0..rows {
        for col in 0..cols {
            let base_x = (col as f32 + 0.5) * cell_w;
            let base_y = (row as f32 + 0.5) * cell_h;
            let jitter_x = (rng.random() as f32 - 0.5) * cell_w * 0.8;
            let jitter_y = (rng.random() as f32 - 0.5) * cell_h * 0.8;
            let sx = (base_x + jitter_x).clamp(0.0, config.width as f32 - 1.0);
            let sy = (base_y + jitter_y).clamp(0.0, config.height as f32 - 1.0);

            // Generate a unique non-black colour
            let (r, g, b) = loop {
                let r = rng.random_int(30, 229) as u8;
                let g = rng.random_int(30, 229) as u8;
                let b = rng.random_int(30, 229) as u8;
                let id = color_to_id(r, g, b);
                if id != 0 && used_ids.insert(id) {
                    break (r, g, b);
                }
            };

            let id = color_to_id(r, g, b);
            seeds.push(Seed {
                x: sx,
                y: sy,
                color: [r, g, b],
                id,
            });
        }
    }

    log::info!(
        "Generating world: {}x{} with {} seeds",
        config.width,
        config.height,
        seeds.len()
    );

    // Voronoi tessellation via math::procgen (returns regions[pixel] = seed index)
    let points: Vec<(f32, f32)> = seeds.iter().map(|s| (s.x, s.y)).collect();
    let voronoi_opts = VoronoiOpts {
        seed: config.seed,
        ..VoronoiOpts::default()
    };
    let (regions, _, _) = voronoi_diagram(config.width, config.height, &points, &voronoi_opts);

    let mut map = ProvinceMap::new(config.width, config.height);

    // Per-province accumulators
    struct Accum {
        area: u32,
        sum_x: u64,
        sum_y: u64,
        min_x: u32,
        min_y: u32,
        max_x: u32,
        max_y: u32,
    }

    let mut accums: HashMap<u32, Accum> = HashMap::new();

    for (pixel_idx, &region_idx) in regions.iter().enumerate() {
        let x = (pixel_idx as u32) % config.width;
        let y = (pixel_idx as u32) / config.width;
        let id = seeds[region_idx as usize].id;

        map.set_pixel(x, y, id);

        let acc = accums.entry(id).or_insert(Accum {
            area: 0,
            sum_x: 0,
            sum_y: 0,
            min_x: x,
            min_y: y,
            max_x: x,
            max_y: y,
        });
        acc.area += 1;
        acc.sum_x += u64::from(x);
        acc.sum_y += u64::from(y);
        acc.min_x = acc.min_x.min(x);
        acc.min_y = acc.min_y.min(y);
        acc.max_x = acc.max_x.max(x);
        acc.max_y = acc.max_y.max(y);
    }

    // Build Province objects (no terrain assignment -- game developer does that)
    for seed in &seeds {
        let acc = match accums.get(&seed.id) {
            Some(a) => a,
            None => continue,
        };

        let centroid = Vec2::new(
            acc.sum_x as f32 / acc.area as f32,
            acc.sum_y as f32 / acc.area as f32,
        );

        let bounding_box = crate::math::Rect::new(
            acc.min_x as f32,
            acc.min_y as f32,
            (acc.max_x - acc.min_x) as f32,
            (acc.max_y - acc.min_y) as f32,
        );

        let mut province = Province::new(seed.id, seed.color);
        province.area = acc.area;
        province.centroid = centroid;
        province.bounding_box = bounding_box;
        province.positions = vec![centroid];

        map.insert_province(province);
    }

    // Detect adjacencies
    detect_adjacency(&mut map);

    log::info!(
        "World generated: {} provinces, {} adjacencies",
        map.province_count(),
        map.adjacency_count()
    );

    map
}


