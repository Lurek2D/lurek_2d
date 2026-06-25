//! This file owns the software rasterization path that turns a prepared `RaycasterScene` into CPU-side `ImageData`.
//! It fills ceilings, floors, walls, sprites, and transient meshes in a fixed order using quad and triangle helpers.
//! The scene already carries geometry, UVs, lighting, and depth intent, so this file translates instead of recomputing.
//! It is the right owner for previews, captures, and tool outputs that need first-person imagery without renderer commands.
//! Open this file when CPU draw ordering or fill behavior changes; scene assembly and GPU translation live in siblings.

use crate::image::ImageData;
use crate::math::Vec2;
use crate::raycaster::scene::{RaycasterBackground, RaycasterOverlayEffect, RaycasterScene};
use crate::runtime::resource_keys::TextureKey;

type TextureSampler<'a> = dyn Fn(TextureKey, f32, f32) -> Option<(u8, u8, u8, u8)> + 'a;

struct QuadRaster<'a> {
    corners: [Vec2; 4],
    uvs: [Vec2; 4],
    corner_w: [f32; 4],
    texture_key: Option<TextureKey>,
    light: [f32; 4],
    texture_sampler: Option<&'a TextureSampler<'a>>,
    depth_buffer: Option<&'a mut [f32]>,
    depth: Option<f32>,
    write_depth: bool,
}

fn apply_light((r, g, b, a): (u8, u8, u8, u8), light: [f32; 4]) -> (u8, u8, u8, u8) {
    (
        ((r as f32) * light[0].clamp(0.0, 2.0)).clamp(0.0, 255.0) as u8,
        ((g as f32) * light[1].clamp(0.0, 2.0)).clamp(0.0, 255.0) as u8,
        ((b as f32) * light[2].clamp(0.0, 2.0)).clamp(0.0, 255.0) as u8,
        ((a as f32) * light[3].clamp(0.0, 1.0)).clamp(0.0, 255.0) as u8,
    )
}

fn blend_pixel(img: &mut ImageData, x: u32, y: u32, src: (u8, u8, u8, u8)) {
    let (sr, sg, sb, sa) = src;
    if sa == 255 {
        img.set_pixel(x, y, sr, sg, sb, sa);
        return;
    }
    if sa == 0 {
        return;
    }
    let Some((dr, dg, db, da)) = img.get_pixel(x, y) else {
        return;
    };
    let alpha = sa as f32 / 255.0;
    let inv = 1.0 - alpha;
    img.set_pixel(
        x,
        y,
        ((sr as f32 * alpha) + (dr as f32 * inv)).clamp(0.0, 255.0) as u8,
        ((sg as f32 * alpha) + (dg as f32 * inv)).clamp(0.0, 255.0) as u8,
        ((sb as f32 * alpha) + (db as f32 * inv)).clamp(0.0, 255.0) as u8,
        (sa as f32 + da as f32 * inv).clamp(0.0, 255.0) as u8,
    );
}

fn rgba_to_u8(color: [f32; 4]) -> (u8, u8, u8, u8) {
    (
        (color[0].clamp(0.0, 1.0) * 255.0) as u8,
        (color[1].clamp(0.0, 1.0) * 255.0) as u8,
        (color[2].clamp(0.0, 1.0) * 255.0) as u8,
        (color[3].clamp(0.0, 1.0) * 255.0) as u8,
    )
}

fn mix_rgba(a: [f32; 4], b: [f32; 4], t: f32) -> [f32; 4] {
    let t = t.clamp(0.0, 1.0);
    [
        a[0] + (b[0] - a[0]) * t,
        a[1] + (b[1] - a[1]) * t,
        a[2] + (b[2] - a[2]) * t,
        a[3] + (b[3] - a[3]) * t,
    ]
}

fn fill_background(
    img: &mut ImageData,
    background: &RaycasterBackground,
    texture_sampler: Option<&TextureSampler<'_>>,
) {
    let width = img.width().max(1);
    let height = img.height().max(1);
    match background {
        RaycasterBackground::Solid { color } => {
            let (r, g, b, a) = rgba_to_u8(*color);
            for y in 0..height {
                for x in 0..width {
                    img.set_pixel(x, y, r, g, b, a);
                }
            }
        }
        RaycasterBackground::VerticalGradient { top, bottom } => {
            let denom = height.saturating_sub(1).max(1) as f32;
            for y in 0..height {
                let color = rgba_to_u8(mix_rgba(*top, *bottom, y as f32 / denom));
                for x in 0..width {
                    img.set_pixel(x, y, color.0, color.1, color.2, color.3);
                }
            }
        }
        RaycasterBackground::Skybox {
            texture_key,
            tint,
            offset,
        } => {
            let fallback = rgba_to_u8(*tint);
            for y in 0..height {
                let v = y as f32 / height as f32;
                for x in 0..width {
                    let u = (x as f32 / width as f32 + *offset).rem_euclid(1.0);
                    let sampled = texture_sampler
                        .and_then(|sampler| sampler(*texture_key, u, v))
                        .map(|color| apply_light(color, *tint))
                        .unwrap_or(fallback);
                    img.set_pixel(x, y, sampled.0, sampled.1, sampled.2, sampled.3);
                }
            }
        }
    }
}

fn overlay_fog(img: &mut ImageData, color: [f32; 4], density: f32) {
    let mut color = color;
    color[3] = (color[3] * density.clamp(0.0, 1.0)).clamp(0.0, 1.0);
    let src = rgba_to_u8(color);
    for y in 0..img.height() {
        for x in 0..img.width() {
            blend_pixel(img, x, y, src);
        }
    }
}

fn overlay_snow(img: &mut ImageData, color: [f32; 4], density: f32, wind: f32) {
    let width = img.width().max(1);
    let height = img.height().max(1);
    let count = ((width as f32 * height as f32 * density.clamp(0.0, 2.0)) / 850.0)
        .round()
        .clamp(0.0, 800.0) as u32;
    let src = rgba_to_u8(color);
    let wind_px = (wind * 4.0).round() as i32;
    let mut seed = 0x9e37_79b9_u32 ^ width.rotate_left(8) ^ height;
    for _ in 0..count {
        seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
        let x = (seed % width) as i32;
        seed = seed.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
        let y = (seed % height) as i32;
        let len = 2 + (seed % 4) as i32;
        for i in 0..len {
            let px = x + (wind_px * i) / len.max(1);
            let py = y + i;
            if px >= 0 && py >= 0 && px < width as i32 && py < height as i32 {
                blend_pixel(img, px as u32, py as u32, src);
            }
        }
    }
}

fn apply_overlays(img: &mut ImageData, overlays: &[RaycasterOverlayEffect]) {
    for overlay in overlays {
        match *overlay {
            RaycasterOverlayEffect::Fog { color, density } => overlay_fog(img, color, density),
            RaycasterOverlayEffect::Snow {
                color,
                density,
                wind,
            } => overlay_snow(img, color, density, wind),
        }
    }
}

fn scale_corners(
    corners: [Vec2; 4],
    scene_width: f32,
    scene_height: f32,
    width: u32,
    height: u32,
) -> [Vec2; 4] {
    let sx = width as f32 / scene_width.max(1.0);
    let sy = height as f32 / scene_height.max(1.0);
    corners.map(|corner| Vec2::new(corner.x * sx, corner.y * sy))
}

fn sample_perspective_uv(quad: &QuadRaster<'_>, weights: [f32; 3], indices: [usize; 3]) -> Vec2 {
    let mut inv_sum = 0.0;
    let mut u_sum = 0.0;
    let mut v_sum = 0.0;
    for (weight, index) in weights.into_iter().zip(indices) {
        let corner_w = quad.corner_w[index].abs().max(1e-5);
        let inv_w = weight / corner_w;
        inv_sum += inv_w;
        u_sum += quad.uvs[index].x * inv_w;
        v_sum += quad.uvs[index].y * inv_w;
    }
    if inv_sum.abs() < 1e-5 {
        return Vec2::new(0.0, 0.0);
    }
    Vec2::new(u_sum / inv_sum, v_sum / inv_sum)
}

fn sample_perspective_depth(quad: &QuadRaster<'_>, weights: [f32; 3], indices: [usize; 3]) -> f32 {
    let mut inv_sum = 0.0;
    for (weight, index) in weights.into_iter().zip(indices) {
        let corner_w = quad.corner_w[index].abs().max(1e-5);
        inv_sum += weight / corner_w;
    }
    if inv_sum.abs() < 1e-5 {
        return quad.depth.unwrap_or(f32::INFINITY);
    }
    1.0 / inv_sum
}

fn fill_quad_triangle(img: &mut ImageData, quad: &mut QuadRaster<'_>, indices: [usize; 3]) {
    let a = quad.corners[indices[0]];
    let b = quad.corners[indices[1]];
    let c = quad.corners[indices[2]];
    let min_x = a.x.min(b.x).min(c.x).floor().max(0.0) as u32;
    let min_y = a.y.min(b.y).min(c.y).floor().max(0.0) as u32;
    let max_x = a.x.max(b.x).max(c.x).ceil().min(img.width() as f32) as u32;
    let max_y = a.y.max(b.y).max(c.y).ceil().min(img.height() as f32) as u32;
    if min_x >= max_x || min_y >= max_y {
        return;
    }
    let area = edge(a.x, a.y, b.x, b.y, c.x, c.y);
    if area.abs() < 1e-5 {
        return;
    }
    for py in min_y..max_y {
        for px in min_x..max_x {
            let sample_x = px as f32 + 0.5;
            let sample_y = py as f32 + 0.5;
            let wa = edge(b.x, b.y, c.x, c.y, sample_x, sample_y);
            let wb = edge(c.x, c.y, a.x, a.y, sample_x, sample_y);
            let wc = edge(a.x, a.y, b.x, b.y, sample_x, sample_y);
            let inside = if area > 0.0 {
                wa >= -1e-4 && wb >= -1e-4 && wc >= -1e-4
            } else {
                wa <= 1e-4 && wb <= 1e-4 && wc <= 1e-4
            };
            if !inside {
                continue;
            }
            let weights = [wa / area, wb / area, wc / area];
            let z = quad
                .depth
                .map(|_| sample_perspective_depth(quad, weights, indices));
            if let (Some(buffer), Some(z)) = (quad.depth_buffer.as_deref_mut(), z) {
                let idx = (py * img.width() + px) as usize;
                if let Some(current) = buffer.get_mut(idx) {
                    if z > *current + 1e-4 {
                        continue;
                    }
                }
            }
            let uv = sample_perspective_uv(quad, weights, indices);
            let flat = (
                (quad.light[0].clamp(0.0, 1.0) * 255.0) as u8,
                (quad.light[1].clamp(0.0, 1.0) * 255.0) as u8,
                (quad.light[2].clamp(0.0, 1.0) * 255.0) as u8,
                (quad.light[3].clamp(0.0, 1.0) * 255.0) as u8,
            );
            let color = quad
                .texture_key
                .and_then(|key| {
                    quad.texture_sampler
                        .and_then(|sampler| sampler(key, uv.x, uv.y))
                })
                .map(|sample| apply_light(sample, quad.light))
                .unwrap_or(flat);
            if color.3 == 0 {
                continue;
            }
            if let (Some(buffer), Some(z)) = (quad.depth_buffer.as_deref_mut(), z) {
                let idx = (py * img.width() + px) as usize;
                if let Some(current) = buffer.get_mut(idx) {
                    if quad.write_depth {
                        *current = z;
                    }
                }
            }
            blend_pixel(img, px, py, color);
        }
    }
}

fn fill_quad(img: &mut ImageData, mut quad: QuadRaster<'_>) {
    fill_quad_triangle(img, &mut quad, [0, 1, 2]);
    fill_quad_triangle(img, &mut quad, [0, 2, 3]);
}

fn average_vertex_rgba(vertices: &[crate::render::mesh::MeshVertex; 3]) -> (u8, u8, u8, u8) {
    let avg = |channel: [f32; 3]| -> u8 {
        ((channel[0] + channel[1] + channel[2]) / 3.0)
            .clamp(0.0, 1.0)
            .mul_add(255.0, 0.0) as u8
    };
    (
        avg([vertices[0].r, vertices[1].r, vertices[2].r]),
        avg([vertices[0].g, vertices[1].g, vertices[2].g]),
        avg([vertices[0].b, vertices[1].b, vertices[2].b]),
        avg([vertices[0].a, vertices[1].a, vertices[2].a]),
    )
}

fn edge(ax: f32, ay: f32, bx: f32, by: f32, px: f32, py: f32) -> f32 {
    (px - ax) * (by - ay) - (py - ay) * (bx - ax)
}

fn fill_triangle(
    img: &mut ImageData,
    a: &crate::render::mesh::MeshVertex,
    b: &crate::render::mesh::MeshVertex,
    c: &crate::render::mesh::MeshVertex,
) {
    let min_x = a.x.min(b.x).min(c.x).floor().max(0.0) as u32;
    let min_y = a.y.min(b.y).min(c.y).floor().max(0.0) as u32;
    let max_x = a.x.max(b.x).max(c.x).ceil().min(img.width() as f32) as u32;
    let max_y = a.y.max(b.y).max(c.y).ceil().min(img.height() as f32) as u32;
    let area = edge(a.x, a.y, b.x, b.y, c.x, c.y);
    if area.abs() < 1e-5 {
        return;
    }
    let color = average_vertex_rgba(&[*a, *b, *c]);
    for py in min_y..max_y {
        for px in min_x..max_x {
            let sample_x = px as f32 + 0.5;
            let sample_y = py as f32 + 0.5;
            let w0 = edge(b.x, b.y, c.x, c.y, sample_x, sample_y);
            let w1 = edge(c.x, c.y, a.x, a.y, sample_x, sample_y);
            let w2 = edge(a.x, a.y, b.x, b.y, sample_x, sample_y);
            let inside = if area > 0.0 {
                w0 >= 0.0 && w1 >= 0.0 && w2 >= 0.0
            } else {
                w0 <= 0.0 && w1 <= 0.0 && w2 <= 0.0
            };
            if inside {
                img.set_pixel(px, py, color.0, color.1, color.2, color.3);
            }
        }
    }
}

fn fill_mesh(img: &mut ImageData, mesh: &crate::render::mesh::Mesh) {
    let indices = mesh.triangulate();
    for tri in indices.chunks_exact(3) {
        let Some(a) = mesh.vertices.get(tri[0]) else {
            continue;
        };
        let Some(b) = mesh.vertices.get(tri[1]) else {
            continue;
        };
        let Some(c) = mesh.vertices.get(tri[2]) else {
            continue;
        };
        fill_triangle(img, a, b, c);
    }
}

/// Software rasterization methods for `RaycasterScene`.
impl RaycasterScene {
    /// Rasterize this scene into a new `ImageData` of `width x height`; draws ceilings, floors, walls, then transparent entities back-to-front.
    pub fn draw_to_image(&self, width: u32, height: u32) -> ImageData {
        self.draw_to_image_with_textures(width, height, None)
    }

    /// Rasterize this scene into a new `ImageData`, sampling texture keys through `texture_sampler` when available.
    pub fn draw_to_image_with_textures(
        &self,
        width: u32,
        height: u32,
        texture_sampler: Option<&TextureSampler<'_>>,
    ) -> ImageData {
        enum TransparentItem<'a> {
            Sprite(&'a crate::raycaster::scene::BillboardSprite),
            Model(&'a crate::raycaster::scene::ModelMesh),
        }

        let mut img = ImageData::new(width, height);
        if let Some(background) = &self.background {
            fill_background(&mut img, background, texture_sampler);
        }
        let mut depth_buffer =
            vec![f32::INFINITY; (width as usize).saturating_mul(height as usize)];
        for ceil in &self.ceilings {
            fill_quad(
                &mut img,
                QuadRaster {
                    corners: scale_corners(
                        ceil.corners,
                        self.screen_width,
                        self.screen_height,
                        width,
                        height,
                    ),
                    uvs: ceil.uvs,
                    corner_w: ceil.corner_w,
                    texture_key: ceil.texture_key,
                    light: ceil.light,
                    texture_sampler,
                    depth_buffer: None,
                    depth: None,
                    write_depth: false,
                },
            );
        }
        for floor in &self.floors {
            fill_quad(
                &mut img,
                QuadRaster {
                    corners: scale_corners(
                        floor.corners,
                        self.screen_width,
                        self.screen_height,
                        width,
                        height,
                    ),
                    uvs: floor.uvs,
                    corner_w: floor.corner_w,
                    texture_key: floor.texture_key,
                    light: floor.light,
                    texture_sampler,
                    depth_buffer: None,
                    depth: None,
                    write_depth: false,
                },
            );
        }
        for wall in &self.walls {
            fill_quad(
                &mut img,
                QuadRaster {
                    corners: scale_corners(
                        wall.corners,
                        self.screen_width,
                        self.screen_height,
                        width,
                        height,
                    ),
                    uvs: wall.uvs,
                    corner_w: wall.corner_w,
                    texture_key: wall.texture_key,
                    light: wall.light,
                    texture_sampler,
                    depth_buffer: Some(&mut depth_buffer),
                    depth: Some(wall.depth),
                    write_depth: true,
                },
            );
        }

        let mut transparent_items = Vec::with_capacity(self.sprites.len() + self.models.len());
        for sprite in &self.sprites {
            transparent_items.push(TransparentItem::Sprite(sprite));
        }
        for model in &self.models {
            transparent_items.push(TransparentItem::Model(model));
        }
        transparent_items.sort_by(|a, b| {
            let ad = match a {
                TransparentItem::Sprite(sprite) => sprite.depth,
                TransparentItem::Model(model) => model.depth,
            };
            let bd = match b {
                TransparentItem::Sprite(sprite) => sprite.depth,
                TransparentItem::Model(model) => model.depth,
            };
            bd.partial_cmp(&ad).unwrap_or(std::cmp::Ordering::Equal)
        });

        for item in transparent_items {
            match item {
                TransparentItem::Sprite(sprite) => fill_quad(
                    &mut img,
                    QuadRaster {
                        corners: scale_corners(
                            sprite.corners,
                            self.screen_width,
                            self.screen_height,
                            width,
                            height,
                        ),
                        uvs: sprite.uvs,
                        corner_w: [sprite.depth, sprite.depth, sprite.depth, sprite.depth],
                        texture_key: Some(sprite.texture_key),
                        light: sprite.light,
                        texture_sampler,
                        depth_buffer: Some(&mut depth_buffer),
                        depth: Some(sprite.depth),
                        write_depth: false,
                    },
                ),
                TransparentItem::Model(model) => fill_mesh(&mut img, &model.mesh),
            }
        }
        apply_overlays(&mut img, &self.overlays);
        img
    }
}
