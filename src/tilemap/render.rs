//! This file owns render behavior inside the tilemap subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate render state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for render work.
//! Serialization, indexing, and boundary checks stay here when they depend on render internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.
//! Open this file when render ownership changes, but keep unrelated subsystem policy in sibling modules.
//! The code favors small data transformations so examples, specs, and tests can assert behavior directly.

use super::coords::{to_screen_hex, to_screen_iso};
use super::orientation::MapOrientation;
use super::tilemap::TileMap;
use crate::render::renderer::{DrawMode, RenderCommand};
use crate::runtime::resource_keys::{ShaderKey, TextureKey};
use crate::tilefield::{CellCoord, TileField};
use crate::tileset::{TileCatalog, TileSet, TileVisual};

/// Options for rendering one tilefield slot through tileset object visuals.
#[derive(Debug, Clone)]
pub struct TileFieldSlotRenderOptions {
    /// Field slot containing object or tile references.
    pub slot: String,
    /// Zero-based field level.
    pub z: u32,
    /// Horizontal render offset.
    pub offset_x: f32,
    /// Vertical render offset.
    pub offset_y: f32,
    /// Treat slot refs as global tile IDs instead of one-based local tile IDs.
    pub ref_is_gid: bool,
}

/// Map a GID to a debug-palette RGB triple for fallback colored tile rendering.
fn gid_to_color(gid: u32) -> (f32, f32, f32) {
    if gid >= 10 {
        match gid {
            10 => (200.0 / 255.0, 50.0 / 255.0, 50.0 / 255.0),
            11 => (50.0 / 255.0, 50.0 / 255.0, 200.0 / 255.0),
            12 => (200.0 / 255.0, 200.0 / 255.0, 50.0 / 255.0),
            _ => (1.0, 1.0, 1.0),
        }
    } else {
        match gid {
            1 => (80.0 / 255.0, 160.0 / 255.0, 80.0 / 255.0),
            2 => (60.0 / 255.0, 120.0 / 255.0, 60.0 / 255.0),
            _ => (40.0 / 255.0, 40.0 / 255.0, 40.0 / 255.0),
        }
    }
}
/// Render-command generation for `TileMap`.
impl TileMap {
    fn push_shader_scope_start(cmds: &mut Vec<RenderCommand>, shader: Option<ShaderKey>) {
        if let Some(shader) = shader {
            cmds.push(RenderCommand::SetShader(Some(shader)));
        }
    }

    fn push_shader_scope_end(cmds: &mut Vec<RenderCommand>, shader: Option<ShaderKey>) {
        if shader.is_some() {
            cmds.push(RenderCommand::SetShader(None));
        }
    }

    fn wrap_commands_with_shader(
        commands: Vec<RenderCommand>,
        shader: Option<ShaderKey>,
    ) -> Vec<RenderCommand> {
        let Some(shader) = shader else {
            return commands;
        };
        if commands.is_empty() {
            return commands;
        }
        let mut wrapped = Vec::with_capacity(commands.len() + 2);
        wrapped.push(RenderCommand::SetShader(Some(shader)));
        wrapped.extend(commands);
        wrapped.push(RenderCommand::SetShader(None));
        wrapped
    }

    fn tile_origin_for_render(&self, tx: u32, ty: u32, tw: f32, th: f32) -> (f32, f32) {
        match self.get_orientation() {
            MapOrientation::TopDown | MapOrientation::SideView => (tx as f32 * tw, ty as f32 * th),
            MapOrientation::Isometric => {
                let pos = to_screen_iso(tx as f32, ty as f32, tw, th);
                (pos.x, pos.y)
            }
            MapOrientation::Hexagonal => {
                let pos = to_screen_hex(tx as i32, ty as i32, th * 0.5);
                (pos.x, pos.y)
            }
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn tile_intersects_camera(
        &self,
        tx: u32,
        ty: u32,
        tw: f32,
        th: f32,
        cam_x: f32,
        cam_y: f32,
        cam_w: f32,
        cam_h: f32,
    ) -> bool {
        let (world_x, world_y) = self.tile_origin_for_render(tx, ty, tw, th);
        world_x + tw >= cam_x
            && world_x <= cam_x + cam_w
            && world_y + th >= cam_y
            && world_y <= cam_y + cam_h
    }

    #[allow(clippy::too_many_arguments)]
    fn push_tile_render_commands(
        &self,
        cmds: &mut Vec<RenderCommand>,
        gid: u32,
        tint: [f32; 4],
        sx: f32,
        sy: f32,
        tw: f32,
        th: f32,
    ) {
        let (gr, gg, gb) = gid_to_color(gid);
        cmds.push(RenderCommand::SetColor(
            gr * tint[0],
            gg * tint[1],
            gb * tint[2],
            tint[3],
        ));
        if gid >= 10 {
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: sx + tw * 0.5,
                y: sy + th * 0.5,
                r: (tw * 0.5).clamp(3.0, 6.0),
            });
        } else {
            cmds.push(RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: sx,
                y: sy,
                w: tw,
                h: th,
            });
        }
    }

    /// Build render commands for one tilefield ref slot using tileset object visuals.
    pub fn build_field_slot_render_commands(
        &self,
        field: &TileField,
        tileset: &TileSet,
        options: &TileFieldSlotRenderOptions,
        texture_exists: impl Fn(TextureKey) -> bool,
    ) -> Result<Vec<RenderCommand>, String> {
        let (width, height, levels) = field.size();
        if options.z >= levels {
            return Err("tilemap renderFieldSlot z is out of bounds".to_string());
        }
        let tile_w = self.get_tile_width() as f32;
        let tile_h = self.get_tile_height() as f32;
        let mut ordered = Vec::<(i32, u32, u32, Vec<RenderCommand>)>::new();
        for y in 0..height {
            for x in 0..width {
                let coord = CellCoord { x, y, z: options.z };
                let Some(ref_value) = field.get_ref(coord, &options.slot) else {
                    continue;
                };
                let local_tile_id = if options.ref_is_gid {
                    let first_gid = tileset.get_first_gid();
                    if ref_value < first_gid {
                        continue;
                    }
                    let local = ref_value - first_gid;
                    if local >= tileset.get_tile_count() {
                        continue;
                    }
                    local
                } else {
                    match ref_value.checked_sub(1) {
                        Some(local) if local < tileset.get_tile_count() => local,
                        _ => continue,
                    }
                };
                let object = tileset.archetype_for_tile(local_tile_id);
                let visual = object.and_then(|object| object.visual.as_ref());
                let draw_tile_id = visual
                    .and_then(|visual| visual.tile_id)
                    .unwrap_or(local_tile_id);
                let order = visual.map(|visual| visual.order).unwrap_or(0);
                let (world_x, world_y) = self.tile_render_origin(x, y);
                let x_px = options.offset_x + world_x;
                let y_px = options.offset_y + world_y;
                let mut commands = Vec::new();
                if let Some(texture_id) = visual.and_then(|visual| visual.texture_id) {
                    let texture_key = TextureKey::from(slotmap::KeyData::from_ffi(texture_id));
                    if texture_exists(texture_key) {
                        let quad = visual.and_then(|visual| visual.quad).unwrap_or_else(|| {
                            let quad = tileset.get_quad(draw_tile_id);
                            [quad.x, quad.y, quad.width, quad.height]
                        });
                        let texture_size = visual
                            .and_then(|visual| visual.texture_size)
                            .unwrap_or_else(|| {
                                [
                                    tileset.get_texture_width() as f32,
                                    tileset.get_texture_height() as f32,
                                ]
                            });
                        commands.push(RenderCommand::DrawQuad {
                            texture_key,
                            quad_x: quad[0],
                            quad_y: quad[1],
                            quad_w: quad[2],
                            quad_h: quad[3],
                            tex_w: texture_size[0],
                            tex_h: texture_size[1],
                            x: x_px,
                            y: y_px,
                            rotation: 0.0,
                            sx: 1.0,
                            sy: 1.0,
                            ox: 0.0,
                            oy: 0.0,
                            effect: None,
                        });
                    }
                }
                if commands.is_empty() {
                    commands.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
                    commands.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: x_px,
                        y: y_px,
                        w: tile_w,
                        h: tile_h,
                    });
                }
                ordered.push((order, y, x, commands));
            }
        }
        ordered.sort_by_key(|(order, y, x, _)| (*order, *y, *x));
        let mut out = Vec::new();
        for (_, _, _, commands) in ordered {
            out.extend(commands);
        }
        Ok(Self::wrap_commands_with_shader(out, self.get_shader()))
    }

    /// Build render commands for one typed tilefield ref slot through a multi-tileset catalog.
    pub fn build_field_catalog_slot_render_commands(
        &self,
        field: &TileField,
        catalog: &TileCatalog,
        options: &TileFieldSlotRenderOptions,
        texture_exists: impl Fn(TextureKey) -> bool,
    ) -> Result<Vec<RenderCommand>, String> {
        let (width, height, levels) = field.size();
        if options.z >= levels {
            return Err("tilemap renderFieldCatalogSlot z is out of bounds".to_string());
        }
        let tile_w = self.get_tile_width() as f32;
        let tile_h = self.get_tile_height() as f32;
        let mut ordered = Vec::<(i32, u32, u32, Vec<RenderCommand>)>::new();
        for y in 0..height {
            for x in 0..width {
                let coord = CellCoord { x, y, z: options.z };
                let Some(reference) = field.get_typed_ref(coord, &options.slot) else {
                    continue;
                };
                let Some(tileset) = catalog.tileset(&reference.tileset_id) else {
                    continue;
                };
                let visual = catalog.visual_for_ref(reference);
                let visual_ref = visual.as_ref();
                let draw_tile_id = visual_ref
                    .and_then(|visual| visual.tile_id)
                    .or(reference.local_id);
                let order = visual_ref.map(|visual| visual.order).unwrap_or(0);
                let (world_x, world_y) = self.tile_render_origin(x, y);
                let x_px = options.offset_x + world_x;
                let y_px = options.offset_y + world_y;
                let mut commands = Vec::new();
                self.push_visual_render_commands(
                    &mut commands,
                    tileset,
                    visual_ref,
                    draw_tile_id,
                    x_px,
                    y_px,
                    tile_w,
                    tile_h,
                    &texture_exists,
                );
                if commands.is_empty() {
                    commands.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
                    commands.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: x_px,
                        y: y_px,
                        w: tile_w,
                        h: tile_h,
                    });
                }
                ordered.push((order, y, x, commands));
            }
        }
        ordered.sort_by_key(|(order, y, x, _)| (*order, *y, *x));
        let mut out = Vec::new();
        for (_, _, _, commands) in ordered {
            out.extend(commands);
        }
        Ok(Self::wrap_commands_with_shader(out, self.get_shader()))
    }

    #[allow(clippy::too_many_arguments)]
    fn push_visual_render_commands(
        &self,
        commands: &mut Vec<RenderCommand>,
        tileset: &TileSet,
        visual: Option<&TileVisual>,
        draw_tile_id: Option<u32>,
        x_px: f32,
        y_px: f32,
        tile_w: f32,
        tile_h: f32,
        texture_exists: &impl Fn(TextureKey) -> bool,
    ) {
        if let Some(texture_id) = visual.and_then(|visual| visual.texture_id) {
            let texture_key = TextureKey::from(slotmap::KeyData::from_ffi(texture_id));
            if texture_exists(texture_key) {
                let quad = visual.and_then(|visual| visual.quad).or_else(|| {
                    draw_tile_id.map(|tile_id| {
                        let quad = tileset.get_quad(tile_id);
                        [quad.x, quad.y, quad.width, quad.height]
                    })
                });
                let texture_size = visual
                    .and_then(|visual| visual.texture_size)
                    .unwrap_or_else(|| {
                        [
                            tileset.get_texture_width() as f32,
                            tileset.get_texture_height() as f32,
                        ]
                    });
                let quad = quad.unwrap_or([0.0, 0.0, tile_w, tile_h]);
                commands.push(RenderCommand::DrawQuad {
                    texture_key,
                    quad_x: quad[0],
                    quad_y: quad[1],
                    quad_w: quad[2],
                    quad_h: quad[3],
                    tex_w: texture_size[0],
                    tex_h: texture_size[1],
                    x: x_px,
                    y: y_px,
                    rotation: 0.0,
                    sx: 1.0,
                    sy: 1.0,
                    ox: 0.0,
                    oy: 0.0,
                    effect: None,
                });
            }
        }
    }

    /// Build a flat `RenderCommand` list for all visible layers using the debug color palette and `offset`.
    pub fn build_render_commands(&self, offset_x: f32, offset_y: f32) -> Vec<RenderCommand> {
        let mut cmds = Vec::new();
        if self.get_layer_count() == 0 {
            return cmds;
        }
        let tw = self.get_tile_width() as f32;
        let th = self.get_tile_height() as f32;
        if tw <= 0.0 || th <= 0.0 {
            return cmds;
        }
        for layer_idx in 0..self.get_layer_count() {
            if !self.get_layer_visible(layer_idx) {
                continue;
            }
            let Some((lw, lh)) = self.get_layer_dimensions(layer_idx) else {
                continue;
            };
            let layer_shader = self.effective_layer_shader(layer_idx);
            Self::push_shader_scope_start(&mut cmds, layer_shader);
            for ty in 0..lh {
                for tx in 0..lw {
                    let source_gid = self.get_tile(layer_idx, tx, ty);
                    if source_gid == 0 && layer_idx > 0 {
                        continue;
                    }
                    let gid = self.render_gid(source_gid);
                    let (world_x, world_y) = self.tile_origin_for_render(tx, ty, tw, th);
                    self.push_tile_render_commands(
                        &mut cmds,
                        gid,
                        self.effective_tile_tint(layer_idx, tx, ty),
                        offset_x + world_x,
                        offset_y + world_y,
                        tw,
                        th,
                    );
                }
            }
            Self::push_shader_scope_end(&mut cmds, layer_shader);
        }
        cmds
    }

    #[allow(clippy::too_many_arguments)]
    #[allow(clippy::manual_clamp)]
    /// Generate camera-culled `RenderCommand` primitives for all visible layers; returns an empty vec when the map has no layers or zero tile size.
    pub fn generate_render_commands(
        &self,
        offset_x: f32,
        offset_y: f32,
        cam_x: f32,
        cam_y: f32,
        cam_w: f32,
        cam_h: f32,
    ) -> Vec<RenderCommand> {
        let mut cmds = Vec::new();
        if self.get_layer_count() == 0 {
            return cmds;
        }
        let tw = self.get_tile_width() as f32;
        let th = self.get_tile_height() as f32;
        if tw <= 0.0 || th <= 0.0 {
            return cmds;
        }
        for layer_idx in 0..self.get_layer_count() {
            if !self.get_layer_visible(layer_idx) {
                continue;
            }
            let Some((lw, lh)) = self.get_layer_dimensions(layer_idx) else {
                continue;
            };
            let [lt_r, lt_g, lt_b, lt_a] = self.get_layer_color(layer_idx);
            let layer_shader = self.effective_layer_shader(layer_idx);
            Self::push_shader_scope_start(&mut cmds, layer_shader);
            let (x_start, x_end, y_start, y_end) = match self.get_orientation() {
                MapOrientation::TopDown | MapOrientation::SideView => {
                    let tile_x0 = ((cam_x / tw).floor() as i64).max(0) as u32;
                    let tile_y0 = ((cam_y / th).floor() as i64).max(0) as u32;
                    let tile_x1_cam = ((cam_x + cam_w) / tw).ceil() as u32;
                    let tile_y1_cam = ((cam_y + cam_h) / th).ceil() as u32;
                    (
                        tile_x0.min(lw),
                        lw.min(tile_x1_cam),
                        tile_y0.min(lh),
                        lh.min(tile_y1_cam),
                    )
                }
                MapOrientation::Isometric | MapOrientation::Hexagonal => (0, lw, 0, lh),
            };
            for ty in y_start..y_end {
                for tx in x_start..x_end {
                    let source_gid = self.get_tile(layer_idx, tx, ty);
                    if source_gid == 0 {
                        continue;
                    }
                    if !self.tile_intersects_camera(tx, ty, tw, th, cam_x, cam_y, cam_w, cam_h) {
                        continue;
                    }
                    let gid = self.render_gid(source_gid);
                    let (world_x, world_y) = self.tile_origin_for_render(tx, ty, tw, th);
                    self.push_tile_render_commands(
                        &mut cmds,
                        gid,
                        {
                            let tint = self.effective_tile_tint(layer_idx, tx, ty);
                            [
                                tint[0] * lt_r,
                                tint[1] * lt_g,
                                tint[2] * lt_b,
                                tint[3] * lt_a,
                            ]
                        },
                        offset_x + world_x,
                        offset_y + world_y,
                        tw,
                        th,
                    );
                }
            }
            Self::push_shader_scope_end(&mut cmds, layer_shader);
        }
        cmds
    }
}
