//! Generates the full globe render command stream from topology, camera, overlays, fog, markers, labels, and arcs.
//! Owns the projected-region draw policy that blends lighting, atmosphere, borders, heat layers, textures, and fog.
//! Projects region geometry and arcs through the current orbit camera so every primitive shares one spatial frame.
//! Also renders markers and labels with LOD checks, pulse effects, and optional icon textures for strategic views.
//! Provides the presentation boundary between globe state stores and the generic renderer command vocabulary.
//! This file is where thematic overlays, marker glyphs, night shading, and atmospheric effects are coordinated.
//! Neighboring changes usually involve projection math, fog semantics, resource keys, and region style contracts.
//! Open this owner when the globe looks wrong even though source data is correct and available to the renderer.
//! It is the right file for draw ordering bugs because no sibling module owns the final command assembly pipeline.

use super::sphere::great_circle_path;
use crate::globe::fog::FogStore;
use crate::globe::label::LabelStore;
use crate::globe::layer::LayerStore;
use crate::globe::lighting::{province_intensity, sun_direction, terminator_alpha};
use crate::globe::marker::MarkerStore;
use crate::globe::projection::{build_view_matrix, project_geo_loop, project_point, OrbitCamera};
use crate::globe::topology::RegionGraph;
use crate::globe::types::{
    Arc as GlobeArc, FogState, GlobeSpec, HeatLayer, LodTier, MarkerShape, Region, RegionId,
};
use crate::math::{polygon, Vec2, Vec3};
use crate::render::mesh::{Mesh, MeshDrawMode, MeshVertex};
use crate::render::renderer::{BlendMode, DrawMode, RenderCommand, StencilAction};
use crate::runtime::resource_keys::FontKey;
use crate::runtime::resource_keys::TextureKey;
use slotmap::KeyData;
use std::collections::HashMap;

type RegionRenderPart<'a> = (&'a [(f32, f32)], &'a [Vec<(f32, f32)>]);

/// Emit a full globe frame as render commands for the current globe state.
#[allow(clippy::too_many_arguments)]
pub fn emit_globe_frame(
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    terrain: &HashMap<RegionId, Region>,
    graph: &RegionGraph,
    semantic_regions: &HashMap<RegionId, Region>,
    fog: &FogStore,
    markers: &MarkerStore,
    labels: &LabelStore,
    layers: &LayerStore,
    heat_layers: &[HeatLayer],
    arcs: &HashMap<u32, GlobeArc>,
    active_viewer: Option<&str>,
    default_font: Option<FontKey>,
    sim_time_sec: f32,
) -> Vec<RenderCommand> {
    let mut cmds: Vec<RenderCommand> = Vec::new();
    let view = build_view_matrix(spec, camera);
    let sun = sun_direction(spec);
    let lod = camera.lod();
    let lod_u8 = lod as u8;
    let zoom = camera.zoom;
    let cx = camera.screen_cx;
    let cy = camera.screen_cy;
    let radius = spec.radius;
    emit_atmosphere_halo(&mut cmds, spec, camera);
    let mut terrain_regions: Vec<&Region> = terrain.values().filter(|r| r.visible).collect();
    terrain_regions.sort_by_key(|region| region.id);
    for region in terrain_regions {
        emit_region_draw(
            &mut cmds,
            region,
            spec,
            camera,
            &view,
            &sun,
            None,
            layers,
            false,
            true,
            true,
            heat_layers,
            lod,
        );
    }
    for region in graph.iter() {
        emit_region_draw(
            &mut cmds,
            region,
            spec,
            camera,
            &view,
            &sun,
            active_viewer.map(|viewer| (fog, viewer)),
            layers,
            true,
            true,
            true,
            heat_layers,
            lod,
        );
    }
    let mut overlays: Vec<&Region> = semantic_regions
        .values()
        .filter(|region| region.visible)
        .collect();
    overlays.sort_by_key(|region| region.id);
    for region in overlays {
        let overlay_color = region.overlay_color.unwrap_or([
            region.base_color[0],
            region.base_color[1],
            region.base_color[2],
            0.22,
        ]);
        if overlay_color[3] <= 0.0 {
            continue;
        }
        if region.member_terrain_ids.is_empty() {
            emit_region_draw_with_color(
                &mut cmds,
                region,
                spec,
                camera,
                &view,
                &sun,
                overlay_color,
                false,
                lod,
            );
        } else {
            for member_id in &region.member_terrain_ids {
                if let Some(patch) = terrain.get(member_id) {
                    emit_region_draw_with_color(
                        &mut cmds,
                        patch,
                        spec,
                        camera,
                        &view,
                        &sun,
                        overlay_color,
                        false,
                        lod,
                    );
                }
            }
        }
    }
    for arc in arcs.values() {
        if !arc.visible {
            continue;
        }
        let [ar, ag, ab, aa] = arc.color;
        let pts = project_arc(
            arc.from.0, arc.from.1, arc.to.0, arc.to.1, arc.steps, &view, spec, camera,
        );
        if pts.len() < 4 {
            continue;
        }
        cmds.push(RenderCommand::SetLineWidth(arc.width));
        cmds.push(RenderCommand::SetColor(ar, ag, ab, aa));
        cmds.push(RenderCommand::Polyline { points: pts });
    }
    for marker in markers.iter_visible() {
        if let Some(screen) =
            project_point(marker.lat_deg, marker.lon_deg, &view, radius, zoom, cx, cy)
        {
            let [mr, mg, mb, ma] = marker.style.color;
            let pulse = if marker.style.pulse_hz > 0.0 {
                (sim_time_sec * marker.style.pulse_hz * std::f32::consts::TAU).sin()
                    * marker.style.pulse_amplitude
            } else {
                0.0
            };
            let r = (marker.style.size * (0.5 + pulse)).max(2.0);
            let rotation = sim_time_sec * marker.style.rotation_deg_per_sec.to_radians();
            cmds.push(RenderCommand::SetColor(mr, mg, mb, ma));
            if let Some(texture_key) = marker
                .style
                .icon_texture
                .as_deref()
                .and_then(|raw| raw.parse::<u64>().ok())
                .map(|raw| TextureKey::from(KeyData::from_ffi(raw)))
            {
                cmds.push(RenderCommand::DrawImageEx {
                    texture_key,
                    x: screen.x,
                    y: screen.y,
                    rotation,
                    sx: (r / 8.0).max(0.125),
                    sy: (r / 8.0).max(0.125),
                    ox: 0.5,
                    oy: 0.5,
                    effect: None,
                });
            } else {
                emit_marker_shape(
                    &mut cmds,
                    marker.style.shape,
                    screen.x,
                    screen.y,
                    r,
                    rotation,
                );
            }
            if let (Some(label_text), Some(font_key)) = (&marker.label, default_font) {
                cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
                cmds.push(RenderCommand::Print {
                    font_key,
                    text: label_text.clone(),
                    x: screen.x + r + 2.0,
                    y: screen.y - 6.0,
                    scale: 0.75,
                });
            }
        }
    }
    if lod >= LodTier::Mid {
        if let Some(font_key) = default_font {
            for label in labels.iter_visible(lod_u8) {
                if let Some(screen) =
                    project_point(label.lat_deg, label.lon_deg, &view, radius, zoom, cx, cy)
                {
                    let [lr, lg, lb, la] = label.style.color;
                    let scale = (label.style.font_size / 16.0).clamp(0.5, 4.0);
                    cmds.push(RenderCommand::SetColor(lr, lg, lb, la));
                    cmds.push(RenderCommand::Print {
                        font_key,
                        text: label.text.clone(),
                        x: screen.x,
                        y: screen.y,
                        scale,
                    });
                }
            }
        }
    }
    cmds
}
/// Emit a marker primitive matching the configured shape.
fn emit_marker_shape(
    cmds: &mut Vec<RenderCommand>,
    shape: MarkerShape,
    x: f32,
    y: f32,
    r: f32,
    rotation: f32,
) {
    match shape {
        MarkerShape::Circle => cmds.push(RenderCommand::Circle {
            mode: DrawMode::Fill,
            x,
            y,
            r,
        }),
        MarkerShape::Square => cmds.push(RenderCommand::Polygon {
            mode: DrawMode::Fill,
            vertices: rotate_vertices(x, y, rotation, &[(-r, -r), (r, -r), (r, r), (-r, r)]),
        }),
        MarkerShape::Diamond => cmds.push(RenderCommand::Polygon {
            mode: DrawMode::Fill,
            vertices: rotate_vertices(x, y, rotation, &[(0.0, -r), (r, 0.0), (0.0, r), (-r, 0.0)]),
        }),
        MarkerShape::Triangle => cmds.push(RenderCommand::Polygon {
            mode: DrawMode::Fill,
            vertices: rotate_vertices(x, y, rotation, &[(0.0, -r), (r, r), (-r, r)]),
        }),
        MarkerShape::Cross => {
            cmds.push(RenderCommand::SetLineWidth((r * 0.35).max(1.0)));
            let [x1, y1, x2, y2] = rotate_segment(x, y, rotation, -r, 0.0, r, 0.0);
            cmds.push(RenderCommand::Line { x1, y1, x2, y2 });
            let [x1, y1, x2, y2] = rotate_segment(x, y, rotation, 0.0, -r, 0.0, r);
            cmds.push(RenderCommand::Line { x1, y1, x2, y2 });
        }
    }
}

#[inline]
fn rotate_point(x: f32, y: f32, rotation: f32, dx: f32, dy: f32) -> (f32, f32) {
    let cos = rotation.cos();
    let sin = rotation.sin();
    (x + dx * cos - dy * sin, y + dx * sin + dy * cos)
}

fn rotate_vertices(x: f32, y: f32, rotation: f32, points: &[(f32, f32)]) -> Vec<f32> {
    let mut out = Vec::with_capacity(points.len() * 2);
    for &(dx, dy) in points {
        let (px, py) = rotate_point(x, y, rotation, dx, dy);
        out.push(px);
        out.push(py);
    }
    out
}

fn rotate_segment(x: f32, y: f32, rotation: f32, x1: f32, y1: f32, x2: f32, y2: f32) -> [f32; 4] {
    let (rx1, ry1) = rotate_point(x, y, rotation, x1, y1);
    let (rx2, ry2) = rotate_point(x, y, rotation, x2, y2);
    [rx1, ry1, rx2, ry2]
}

fn region_render_parts(region: &Region) -> Vec<RegionRenderPart<'_>> {
    if !region.parts.is_empty() {
        return region
            .parts
            .iter()
            .filter(|part| !part.outer.is_empty())
            .map(|part| (part.outer.as_slice(), part.holes.as_slice()))
            .collect();
    }
    if region.vertices.is_empty() {
        Vec::new()
    } else {
        vec![(region.vertices.as_slice(), &[])]
    }
}

#[allow(clippy::too_many_arguments)]
fn emit_region_draw(
    cmds: &mut Vec<RenderCommand>,
    region: &Region,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    view: &crate::globe::sphere::Mat3x3,
    sun: &Vec3,
    fog_viewer: Option<(&FogStore, &str)>,
    layers: &LayerStore,
    use_layers: bool,
    use_heat: bool,
    allow_texture: bool,
    heat_layers: &[HeatLayer],
    lod: LodTier,
) {
    if let Some((fog, viewer)) = fog_viewer {
        if let FogState::Hidden = fog.state(viewer, region.id) {
            emit_region_draw_with_color(
                cmds,
                region,
                spec,
                camera,
                view,
                sun,
                [0.05, 0.05, 0.05, 1.0],
                false,
                lod,
            );
            return;
        }
    }
    let mut base = if use_layers {
        layers
            .effective_color(region.id)
            .unwrap_or(region.base_color)
    } else {
        region.base_color
    };
    if use_heat {
        apply_heat_layers(&mut base, region, heat_layers);
    }
    if let Some((fog, viewer)) = fog_viewer {
        if let FogState::Explored = fog.state(viewer, region.id) {
            base[0] *= 0.45;
            base[1] *= 0.45;
            base[2] *= 0.45;
        }
    }
    emit_region_draw_with_color(
        cmds,
        region,
        spec,
        camera,
        view,
        sun,
        base,
        allow_texture,
        lod,
    );
}

#[allow(clippy::too_many_arguments)]
fn emit_region_draw_with_color(
    cmds: &mut Vec<RenderCommand>,
    region: &Region,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
    view: &crate::globe::sphere::Mat3x3,
    sun: &Vec3,
    base: [f32; 4],
    allow_texture: bool,
    lod: LodTier,
) {
    let centroid_intensity =
        province_intensity(region.centroid.0, region.centroid.1, sun, spec.ambient);
    let texture_key = if allow_texture {
        region
            .attrs
            .get("__texture_raw")
            .and_then(|v| v.parse::<u64>().ok())
            .map(|raw| TextureKey::from(KeyData::from_ffi(raw)))
    } else {
        None
    };
    for (outer_vertices, hole_loops) in region_render_parts(region) {
        let Some(proj) = project_geo_loop(
            region.id,
            outer_vertices,
            region.centroid,
            view,
            spec,
            camera,
            centroid_intensity,
        ) else {
            continue;
        };
        let projected_holes: Vec<Vec<Vec2>> = hole_loops
            .iter()
            .filter_map(|hole| {
                project_geo_loop(
                    region.id,
                    hole,
                    region.centroid,
                    view,
                    spec,
                    camera,
                    centroid_intensity,
                )
                .map(|proj_hole| proj_hole.screen_verts)
            })
            .filter(|verts| verts.len() >= 3)
            .collect();
        let has_holes = !projected_holes.is_empty();
        if has_holes {
            cmds.push(RenderCommand::SetColorMask(false, false, false, false));
            cmds.push(RenderCommand::StencilBegin {
                action: StencilAction::Replace,
                value: 1,
            });
            emit_stencil_triangles(cmds, &proj.screen_verts);
            cmds.push(RenderCommand::StencilEnd);
            cmds.push(RenderCommand::StencilBegin {
                action: StencilAction::Zero,
                value: 0,
            });
            for hole in &projected_holes {
                emit_stencil_triangles(cmds, hole);
            }
            cmds.push(RenderCommand::StencilEnd);
            cmds.push(RenderCommand::SetColorMask(true, true, true, true));
            cmds.push(RenderCommand::SetStencilTest(Some((
                crate::render::renderer::CompareMode::Equal,
                1,
            ))));
        }
        if let Some(texture_key) = texture_key {
            emit_textured_region_fill(
                cmds,
                &proj.screen_verts,
                &proj.surface_points,
                region.texture_uv_rect,
                texture_key,
                [
                    (base[0] * centroid_intensity).clamp(0.0, 1.0),
                    (base[1] * centroid_intensity).clamp(0.0, 1.0),
                    (base[2] * centroid_intensity).clamp(0.0, 1.0),
                    base[3],
                ],
            );
        } else {
            let vertices: Vec<f32> = proj.screen_verts.iter().flat_map(|v| [v.x, v.y]).collect();
            let colors: Vec<[f32; 4]> = proj
                .surface_points
                .iter()
                .map(|point| {
                    let light = (point.x * sun.x + point.y * sun.y + point.z * sun.z)
                        .max(spec.ambient)
                        .min(1.0);
                    [
                        (base[0] * light).clamp(0.0, 1.0),
                        (base[1] * light).clamp(0.0, 1.0),
                        (base[2] * light).clamp(0.0, 1.0),
                        base[3],
                    ]
                })
                .collect();
            cmds.push(RenderCommand::DrawColoredPolygon {
                vertices,
                colors,
                mode: DrawMode::Fill,
            });
        }
        let night_alpha =
            (1.0 - terminator_alpha(region.centroid.0, region.centroid.1, sun, 24.0)) * 0.45;
        if night_alpha > 0.01 {
            cmds.push(RenderCommand::DrawConvexFan {
                vertices: proj.screen_verts.clone(),
                uvs: Vec::new(),
                texture_key: None,
                tint: [0.02, 0.03, 0.08, night_alpha.clamp(0.0, 0.6)],
                blend: BlendMode::Alpha,
            });
        }
        if has_holes {
            cmds.push(RenderCommand::SetStencilTest(None));
        }
        if spec.render_borders && lod >= LodTier::Mid {
            emit_border_polyline(cmds, spec, &proj.screen_verts);
            for hole in &projected_holes {
                emit_border_polyline(cmds, spec, hole);
            }
        }
    }
}

fn emit_stencil_triangles(cmds: &mut Vec<RenderCommand>, vertices: &[Vec2]) {
    for tri in triangulate_loop_indices(vertices).chunks_exact(3) {
        let a = vertices[tri[0] as usize];
        let b = vertices[tri[1] as usize];
        let c = vertices[tri[2] as usize];
        cmds.push(RenderCommand::Triangle {
            mode: DrawMode::Fill,
            x1: a.x,
            y1: a.y,
            x2: b.x,
            y2: b.y,
            x3: c.x,
            y3: c.y,
        });
    }
}

fn emit_textured_region_fill(
    cmds: &mut Vec<RenderCommand>,
    screen_verts: &[Vec2],
    surface_points: &[Vec3],
    rect: Option<[f32; 4]>,
    texture_key: TextureKey,
    tint: [f32; 4],
) {
    let indices = triangulate_loop_indices(screen_verts);
    if indices.len() < 3 {
        return;
    }
    let uvs = build_surface_uvs(surface_points, rect);
    if uvs.len() != screen_verts.len() {
        return;
    }
    let mesh_vertices: Vec<MeshVertex> = screen_verts
        .iter()
        .zip(uvs.iter())
        .map(|(screen, uv)| MeshVertex {
            x: screen.x,
            y: screen.y,
            u: uv.x,
            v: uv.y,
            r: tint[0],
            g: tint[1],
            b: tint[2],
            a: tint[3],
        })
        .collect();
    let mut mesh = Mesh::from_vertices(mesh_vertices, MeshDrawMode::Triangles);
    mesh.set_vertex_map(indices);
    mesh.set_texture(Some(texture_key));
    cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0));
    cmds.push(RenderCommand::DrawMeshTransient {
        mesh,
        x: 0.0,
        y: 0.0,
        rotation: 0.0,
        sx: 1.0,
        sy: 1.0,
        ox: 0.0,
        oy: 0.0,
    });
}

fn emit_border_polyline(cmds: &mut Vec<RenderCommand>, spec: &GlobeSpec, vertices: &[Vec2]) {
    if vertices.len() < 2 {
        return;
    }
    let [br, bg, bb, ba] = spec.border_color;
    cmds.push(RenderCommand::SetLineWidth(spec.border_width));
    cmds.push(RenderCommand::SetColor(br, bg, bb, ba));
    let border_verts = smooth_polyline(vertices, spec.border_smoothing_passes);
    let mut pts: Vec<f32> = border_verts.iter().flat_map(|v| [v.x, v.y]).collect();
    if let Some(first) = border_verts.first() {
        pts.push(first.x);
        pts.push(first.y);
    }
    if pts.len() >= 4 {
        cmds.push(RenderCommand::Polyline { points: pts });
    }
}

fn triangulate_loop_indices(vertices: &[Vec2]) -> Vec<u32> {
    if vertices.len() < 3 {
        return Vec::new();
    }
    if let Ok(tris) = polygon::triangulate(vertices) {
        let mut out = Vec::with_capacity(tris.len() * 3);
        for tri in tris {
            for point in tri {
                let Some(index) = vertices.iter().position(|candidate| {
                    candidate.x.to_bits() == point.x.to_bits()
                        && candidate.y.to_bits() == point.y.to_bits()
                }) else {
                    return fan_indices(vertices.len());
                };
                out.push(index as u32);
            }
        }
        if !out.is_empty() {
            return out;
        }
    }
    fan_indices(vertices.len())
}

fn fan_indices(len: usize) -> Vec<u32> {
    if len < 3 {
        return Vec::new();
    }
    let mut out = Vec::with_capacity((len - 2) * 3);
    for i in 1..len - 1 {
        out.extend_from_slice(&[0, i as u32, i as u32 + 1]);
    }
    out
}

/// Build region UVs from projected surface points and an optional UV rectangle.
fn build_surface_uvs(surface_points: &[Vec3], rect: Option<[f32; 4]>) -> Vec<Vec2> {
    let [u0, v0, u1, v1] = rect.unwrap_or([0.0, 0.0, 1.0, 1.0]);
    surface_points
        .iter()
        .map(|point| {
            let (lat, lon) = super::sphere::unit_to_lat_lon(*point);
            let un = ((lon + 180.0) / 360.0).clamp(0.0, 1.0);
            let vn = ((90.0 - lat) / 180.0).clamp(0.0, 1.0);
            Vec2::new(u0 + (u1 - u0) * un, v0 + (v1 - v0) * vn)
        })
        .collect()
}
/// Blend visible heat layers into a region base color.
fn apply_heat_layers(base: &mut [f32; 4], region: &Region, heat_layers: &[HeatLayer]) {
    let mut sorted: Vec<&HeatLayer> = heat_layers.iter().filter(|l| l.visible).collect();
    sorted.sort_by_key(|l| l.z_order);
    for layer in sorted {
        let Some(raw_val) = region.attrs.get(&layer.attr_key) else {
            continue;
        };
        let Ok(v) = raw_val.parse::<f32>() else {
            continue;
        };
        let span = (layer.max_value - layer.min_value).max(1e-6);
        let t = ((v - layer.min_value) / span).clamp(0.0, 1.0);
        let heat = [
            layer.cold_color[0] + (layer.hot_color[0] - layer.cold_color[0]) * t,
            layer.cold_color[1] + (layer.hot_color[1] - layer.cold_color[1]) * t,
            layer.cold_color[2] + (layer.hot_color[2] - layer.cold_color[2]) * t,
            layer.alpha.clamp(0.0, 1.0),
        ];
        base[0] = base[0] * (1.0 - heat[3]) + heat[0] * heat[3];
        base[1] = base[1] * (1.0 - heat[3]) + heat[1] * heat[3];
        base[2] = base[2] * (1.0 - heat[3]) + heat[2] * heat[3];
    }
}
/// Emit atmosphere halo circles when globe atmosphere rendering is enabled.
fn emit_atmosphere_halo(cmds: &mut Vec<RenderCommand>, spec: &GlobeSpec, camera: &OrbitCamera) {
    if !spec.show_atmosphere {
        return;
    }
    let [r, g, b, a] = spec.atmosphere_color;
    let core = (spec.radius * camera.zoom).max(8.0);
    let outer = core + spec.atmosphere_width.max(1.0);
    cmds.push(RenderCommand::SetColor(r, g, b, (a * 0.55).clamp(0.0, 1.0)));
    cmds.push(RenderCommand::Circle {
        mode: DrawMode::Line,
        x: camera.screen_cx,
        y: camera.screen_cy,
        r: outer,
    });
    cmds.push(RenderCommand::SetColor(r, g, b, (a * 0.30).clamp(0.0, 1.0)));
    cmds.push(RenderCommand::Circle {
        mode: DrawMode::Line,
        x: camera.screen_cx,
        y: camera.screen_cy,
        r: outer + spec.atmosphere_width * 0.5,
    });
}
/// Smooth a closed polyline by repeated corner subdivision.
fn smooth_polyline(points: &[Vec2], passes: u8) -> Vec<Vec2> {
    if points.len() < 3 || passes == 0 {
        return points.to_vec();
    }
    let mut current = points.to_vec();
    for _ in 0..passes {
        if current.len() < 3 {
            break;
        }
        let mut out = Vec::with_capacity(current.len() * 2);
        for i in 0..current.len() {
            let a = current[i];
            let b = current[(i + 1) % current.len()];
            out.push(Vec2::new(0.75 * a.x + 0.25 * b.x, 0.75 * a.y + 0.25 * b.y));
            out.push(Vec2::new(0.25 * a.x + 0.75 * b.x, 0.25 * a.y + 0.75 * b.y));
        }
        current = out;
    }
    current
}
/// Project a great-circle arc into a flat polyline of screen coordinates.
#[allow(clippy::too_many_arguments)]
pub fn project_arc(
    lat_a: f32,
    lon_a: f32,
    lat_b: f32,
    lon_b: f32,
    steps: u32,
    view: &super::sphere::Mat3x3,
    spec: &GlobeSpec,
    camera: &OrbitCamera,
) -> Vec<f32> {
    let pts = great_circle_path(lat_a, lon_a, lat_b, lon_b, steps);
    let mut out = Vec::with_capacity(pts.len() * 2);
    for (lat, lon) in pts {
        if let Some(v) = project_point(
            lat,
            lon,
            view,
            spec.radius,
            camera.zoom,
            camera.screen_cx,
            camera.screen_cy,
        ) {
            out.push(v.x);
            out.push(v.y);
        }
    }
    out
}
