//! This file turns a prepared raycaster scene into software pixels when GPU command generation is not the chosen output path.
//! It fills ceilings, floors, walls, billboard sprites, and transient model meshes directly into image memory.
//! Draw order stays deliberately simple so layered surfaces read correctly even without a richer hardware depth workflow.
//! The result is useful for offline images, debug previews, and tool-facing render outputs that need first-person content in CPU memory.

use crate::image::ImageData;
use crate::raycaster::scene::RaycasterScene;

/// Fill a screen-space rectangle with the given RGBA `light` color; clamps to image bounds.
fn fill_rect(img: &mut ImageData, x0: f32, y0: f32, x1: f32, y1: f32, light: [f32; 4]) {
    let w = img.width();
    let h = img.height();
    let r = (light[0].clamp(0.0, 1.0) * 255.0) as u8;
    let g = (light[1].clamp(0.0, 1.0) * 255.0) as u8;
    let b = (light[2].clamp(0.0, 1.0) * 255.0) as u8;
    let a = (light[3].clamp(0.0, 1.0) * 255.0) as u8;
    let px0 = (x0 as i32).max(0) as u32;
    let py0 = (y0 as i32).max(0) as u32;
    let px1 = ((x1 as i32).min(w as i32)).max(0) as u32;
    let py1 = ((y1 as i32).min(h as i32)).max(0) as u32;
    for py in py0..py1 {
        for px in px0..px1 {
            img.set_pixel(px, py, r, g, b, a);
        }
    }
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
        enum TransparentItem<'a> {
            Sprite(&'a crate::raycaster::scene::BillboardSprite),
            Model(&'a crate::raycaster::scene::ModelMesh),
        }

        let mut img = ImageData::new(width, height);
        for ceil in &self.ceilings {
            fill_rect(
                &mut img,
                ceil.corners[0].x,
                ceil.corners[0].y,
                ceil.corners[2].x,
                ceil.corners[2].y,
                ceil.light,
            );
        }
        for floor in &self.floors {
            fill_rect(
                &mut img,
                floor.corners[0].x,
                floor.corners[0].y,
                floor.corners[2].x,
                floor.corners[2].y,
                floor.light,
            );
        }
        for wall in &self.walls {
            fill_rect(
                &mut img,
                wall.corners[0].x,
                wall.corners[0].y,
                wall.corners[2].x,
                wall.corners[2].y,
                wall.light,
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
                TransparentItem::Sprite(sprite) => fill_rect(
                    &mut img,
                    sprite.corners[0].x,
                    sprite.corners[0].y,
                    sprite.corners[2].x,
                    sprite.corners[2].y,
                    sprite.light,
                ),
                TransparentItem::Model(model) => fill_mesh(&mut img, &model.mesh),
            }
        }
        img
    }
}
