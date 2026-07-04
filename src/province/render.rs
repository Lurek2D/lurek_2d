//! Owns the province render implementation for the province subsystem and keeps related runtime rules local here.
//! Keeps province data, render helpers, and map-facing transforms so helpers stay close to invariants this file updates.
//! Defines how province render data is validated, transformed, or stored before neighboring systems consume it.
//! Separates province render behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where province code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing province render defaults, lifecycle handling, validation, or data ownership rules.
//! Keeps failure paths and edge cases near the province render state that explains them instead of spreading rules outward.
//! Preserves deterministic behavior by keeping province render calculations explicit at their owning subsystem boundary.
//! Provides the local adaptation layer that lets callers reuse province render rules without duplicating engine decisions.
//! Open this owner before sibling files when a regression centers on province render state, helpers, or integration rules.
//! Works with neighboring province owners while keeping the main province render responsibility anchored in one file.

use std::collections::HashMap;
use std::f32::consts::{FRAC_PI_2, PI};

use crate::math::Vec2;
use crate::province::map_modes::resolve_color_fallback;
use crate::province::registry::ProvinceRegistry;
use crate::province::types::{BorderPairFlags, ProvinceId};
use crate::render::renderer::{DrawMode, RenderCommand};
use crate::runtime::resource_keys::FontKey;

/// CPU raster output for the segment province renderer.
pub struct ProvinceSegmentRaster {
    /// RGBA pixels in row-major order.
    pub pixels: Vec<u8>,
    /// Output width in pixels.
    pub width: u32,
    /// Output height in pixels.
    pub height: u32,
}

/// Options for the segment province renderer.
pub struct ProvinceSegmentRasterOptions {
    /// Integer output pixels per province-grid pixel.
    pub pixel_size: u32,
    /// Left map cell included in the raster.
    pub map_x: u32,
    /// Top map cell included in the raster.
    pub map_y: u32,
    /// Rasterized map-cell width. Zero means full registry width from `map_x`.
    pub map_w: u32,
    /// Rasterized map-cell height. Zero means full registry height from `map_y`.
    pub map_h: u32,
    /// Global RGBA tint multiplied into fill colors.
    pub tint: [f32; 4],
    /// Per-province tint overrides applied after the registry fill color.
    pub province_tints: HashMap<ProvinceId, [f32; 4]>,
    /// Whether province fills are drawn.
    pub draw_fills: bool,
    /// Whether border shadows and crisp borders are drawn.
    pub draw_borders: bool,
    /// Border shadow radius in output pixels.
    pub edge_gradient_radius: f32,
    /// Border shadow opacity multiplier.
    pub edge_gradient_strength: f32,
}

impl Default for ProvinceSegmentRasterOptions {
    fn default() -> Self {
        Self {
            pixel_size: 1,
            map_x: 0,
            map_y: 0,
            map_w: 0,
            map_h: 0,
            tint: [1.0, 1.0, 1.0, 1.0],
            province_tints: HashMap::new(),
            draw_fills: true,
            draw_borders: true,
            edge_gradient_radius: 16.0,
            edge_gradient_strength: 0.25,
        }
    }
}

/// Strategic/tactical map rendering mode.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProvinceZoomMode {
    /// Derive mode from zoom threshold.
    Auto,
    /// Minimal detail mode intended for world-scale view.
    Strategic,
    /// Full detail mode intended for close map view.
    Tactical,
}

/// Options controlling what gets rendered and how the province map is projected onto the screen.
#[derive(Debug, Clone)]
pub struct ProvinceRenderOptions {
    /// Horizontal screen translation applied before zoom.
    pub x: f32,
    /// Vertical screen translation applied before zoom.
    pub y: f32,
    /// Zoom multiplier applied after translation.
    pub zoom: f32,
    /// Size in screen pixels of one province map pixel; combined with zoom for final scale.
    pub pixel_size: f32,
    /// Screen width in pixels, used for viewport culling.
    pub screen_w: f32,
    /// Screen height in pixels, used for viewport culling.
    pub screen_h: f32,
    /// Active map mode name that drives fill colour selection.
    pub map_mode: String,
    /// Optional render-time RGBA multiplier applied to province fills.
    pub tint: Option<[f32; 4]>,
    /// Optional render-time province fill colour overrides keyed by province id.
    pub province_tints: HashMap<ProvinceId, [f32; 4]>,
    /// When true, emit fill rectangles for province spans.
    pub draw_fills: bool,
    /// When true, emit line segments for province borders.
    pub draw_borders: bool,
    /// When true, emit text labels at province label or centroid positions.
    pub draw_labels: bool,
    /// When true, emit capital dot markers.
    pub draw_capitals: bool,
    /// Line width in screen pixels for border segments.
    pub border_width: f32,
    /// Optional explicit zoom mode override.
    pub zoom_mode: Option<ProvinceZoomMode>,
    /// Auto mode threshold: zoom >= threshold enters tactical mode.
    pub tactical_zoom_threshold: f32,
    /// When true and tactical mode is active, draw adjacency roads between visible capitals.
    pub draw_roads: bool,
    /// Province to highlight with a white hover outline, or None.
    pub hovered_id: Option<ProvinceId>,
    /// Province to highlight with a yellow selection outline, or None.
    pub selected_id: Option<ProvinceId>,
}

/// Shape used for capital-to-capital route rendering.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ProvinceCapitalPathMode {
    /// Emit straight line segments between consecutive capital points.
    Line,
    /// Emit one quadratic Bezier curve per hop using a perpendicular midpoint offset.
    Bezier,
}

/// Render-command settings for converting a province-id route into capital-to-capital lines.
#[derive(Debug, Clone, PartialEq)]
pub struct ProvinceCapitalPathOptions {
    /// Scale from province map pixels to render-space pixels.
    pub pixel_size: f32,
    /// Stroke width in render pixels.
    pub width: f32,
    /// Stroke RGBA color.
    pub color: [f32; 4],
    /// Segment shape to emit for each route hop.
    pub mode: ProvinceCapitalPathMode,
    /// Perpendicular control-point offset in map pixels for Bezier mode.
    pub curve_offset: f32,
    /// Number of line segments used to approximate each Bezier hop.
    pub segments: u32,
}

impl Default for ProvinceCapitalPathOptions {
    fn default() -> Self {
        Self {
            pixel_size: 1.0,
            width: 2.0,
            color: [1.0, 0.86, 0.28, 1.0],
            mode: ProvinceCapitalPathMode::Line,
            curve_offset: 12.0,
            segments: 16,
        }
    }
}

/// Default ProvinceRenderOptions: no translation, zoom 1, pixel_size 1, political mode, fills+borders+capitals enabled.
impl Default for ProvinceRenderOptions {
    fn default() -> Self {
        Self {
            x: 0.0,
            y: 0.0,
            zoom: 1.0,
            pixel_size: 1.0,
            screen_w: 1280.0,
            screen_h: 720.0,
            map_mode: "political".to_string(),
            tint: None,
            province_tints: HashMap::new(),
            draw_fills: true,
            draw_borders: true,
            draw_labels: false,
            draw_capitals: true,
            border_width: 1.0,
            zoom_mode: None,
            tactical_zoom_threshold: 3.0,
            draw_roads: true,
            hovered_id: None,
            selected_id: None,
        }
    }
}

/// Generate render commands for a route by connecting consecutive province capitals.
pub fn generate_capital_path_commands(
    registry: &ProvinceRegistry,
    route: &[ProvinceId],
    opts: &ProvinceCapitalPathOptions,
) -> Vec<RenderCommand> {
    if route.len() < 2 {
        return Vec::new();
    }
    let mut commands = Vec::new();
    commands.push(RenderCommand::SetLineWidth(opts.width.max(1.0)));
    commands.push(RenderCommand::SetColor(
        opts.color[0],
        opts.color[1],
        opts.color[2],
        opts.color[3],
    ));

    for pair in route.windows(2) {
        let Some((ax, ay)) = registry.capital_for(pair[0]) else {
            continue;
        };
        let Some((bx, by)) = registry.capital_for(pair[1]) else {
            continue;
        };
        let start = Vec2::new(ax * opts.pixel_size, ay * opts.pixel_size);
        let end = Vec2::new(bx * opts.pixel_size, by * opts.pixel_size);
        match opts.mode {
            ProvinceCapitalPathMode::Line => {
                commands.push(RenderCommand::Line {
                    x1: start.x,
                    y1: start.y,
                    x2: end.x,
                    y2: end.y,
                });
            }
            ProvinceCapitalPathMode::Bezier => {
                let dx = bx - ax;
                let dy = by - ay;
                let len = (dx * dx + dy * dy).sqrt();
                let (nx, ny) = if len > f32::EPSILON {
                    (-dy / len, dx / len)
                } else {
                    (0.0, 0.0)
                };
                let control = Vec2::new(
                    ((ax + bx) * 0.5 + nx * opts.curve_offset) * opts.pixel_size,
                    ((ay + by) * 0.5 + ny * opts.curve_offset) * opts.pixel_size,
                );
                commands.push(RenderCommand::DrawQuadBezier {
                    start,
                    control,
                    end,
                    segments: opts.segments.max(1),
                });
            }
        }
    }

    commands
}

/// Return the RGBA line colour for a border segment based on its registered type config.
fn border_color_from_registry(
    registry: &ProvinceRegistry,
    a: ProvinceId,
    b: ProvinceId,
) -> [f32; 4] {
    let border_type = registry.get_border_type(a, b).unwrap_or(0);
    registry
        .get_border_type_config(border_type)
        .map(|c| c.color)
        .unwrap_or([0.5, 0.5, 0.5, 1.0])
}

/// Return the effective line width for a border segment, respecting pair overrides before type defaults.
fn border_width_from_registry(
    registry: &ProvinceRegistry,
    a: ProvinceId,
    b: ProvinceId,
    fallback: f32,
) -> f32 {
    if let Some(style) = registry.get_border_pair_style(a, b) {
        return style.thickness.max(1.0);
    }
    registry
        .get_border_type(a, b)
        .and_then(|type_id| {
            registry
                .get_border_type_config(type_id)
                .map(|config| config.thickness)
        })
        .unwrap_or(fallback)
        .max(1.0)
}

/// Compute the visible province-space bounds (left, top, right, bottom) from the render options.
pub fn viewport_bounds(opts: &ProvinceRenderOptions) -> (f32, f32, f32, f32) {
    let zoom_ps = (opts.zoom * opts.pixel_size).max(0.0001);
    let left = -opts.x / zoom_ps;
    let top = -opts.y / zoom_ps;
    let right = (opts.screen_w - opts.x) / zoom_ps;
    let bottom = (opts.screen_h - opts.y) / zoom_ps;
    (left, top, right, bottom)
}

const VISIBILITY_HIDDEN: u8 = 0;
const VISIBILITY_DISCOVERED: u8 = 1;
const VISIBILITY_VISIBLE_MIN: u8 = 2;

fn discovered_fill_color() -> [f32; 4] {
    [0.2, 0.2, 0.2, 1.0]
}

fn multiply_color(color: [f32; 4], tint: [f32; 4]) -> [f32; 4] {
    [
        color[0] * tint[0],
        color[1] * tint[1],
        color[2] * tint[2],
        color[3] * tint[3],
    ]
}

fn fill_color_for_province(
    opts: &ProvinceRenderOptions,
    id: ProvinceId,
    base: [f32; 4],
) -> [f32; 4] {
    if let Some(color) = opts.province_tints.get(&id) {
        return *color;
    }
    if let Some(tint) = opts.tint {
        return multiply_color(base, tint);
    }
    base
}

fn is_hidden(visibility_state: u8) -> bool {
    visibility_state == VISIBILITY_HIDDEN
}

fn is_discovered(visibility_state: u8) -> bool {
    visibility_state == VISIBILITY_DISCOVERED
}

fn is_fully_visible(visibility_state: u8) -> bool {
    visibility_state >= VISIBILITY_VISIBLE_MIN
}

/// Resolve explicit or automatic province zoom mode for render backends.
pub fn resolve_zoom_mode(opts: &ProvinceRenderOptions) -> ProvinceZoomMode {
    if let Some(mode) = opts.zoom_mode {
        if mode == ProvinceZoomMode::Auto {
            if opts.zoom >= opts.tactical_zoom_threshold {
                return ProvinceZoomMode::Tactical;
            }
            return ProvinceZoomMode::Strategic;
        }
        return mode;
    }
    // Preserve historic behavior: if no explicit mode is supplied, render full detail.
    ProvinceZoomMode::Tactical
}

fn should_render_border_in_mode(mode: ProvinceZoomMode, is_country: bool) -> bool {
    match mode {
        ProvinceZoomMode::Tactical => true,
        ProvinceZoomMode::Strategic => is_country,
        ProvinceZoomMode::Auto => is_country,
    }
}

fn color_to_u8(color: [f32; 4]) -> [u8; 4] {
    [
        (color[0].clamp(0.0, 1.0) * 255.0).round() as u8,
        (color[1].clamp(0.0, 1.0) * 255.0).round() as u8,
        (color[2].clamp(0.0, 1.0) * 255.0).round() as u8,
        (color[3].clamp(0.0, 1.0) * 255.0).round() as u8,
    ]
}

const LABEL_FONT_WIDTH_HINT: f32 = 6.0;
const LABEL_FONT_HEIGHT_HINT: f32 = 7.0;
const LABEL_MIN_MAP_CELL_SCREEN: f32 = 2.0;
const LABEL_MIN_MAP_SCALE: f32 = 0.20;
const LABEL_MAX_MAP_SCALE: f32 = 0.62;
const LAND_LABEL_COLOR: [f32; 4] = [0.92, 0.92, 0.86, 1.0];
const WATER_LABEL_COLOR: [f32; 4] = [0.10, 0.27, 0.40, 1.0];

#[derive(Debug, Clone)]
struct LabelCandidate {
    id: ProvinceId,
    text: String,
    x: f32,
    y: f32,
    rotation: f32,
    scale: f32,
    ox: f32,
    oy: f32,
    foreground: [f32; 4],
    area: u32,
}

fn label_rotation(line: Option<((f32, f32), (f32, f32))>) -> f32 {
    let Some(((ax, ay), (bx, by))) = line else {
        return 0.0;
    };
    let dx = bx - ax;
    let dy = by - ay;
    let mut rotation = if dx.abs() <= f32::EPSILON && dy.abs() <= f32::EPSILON {
        0.0
    } else {
        dy.atan2(dx)
    };
    if rotation > FRAC_PI_2 {
        rotation -= PI;
    } else if rotation < -FRAC_PI_2 {
        rotation += PI;
    }
    rotation
}

fn label_candidate(
    id: ProvinceId,
    text: String,
    opts: &ProvinceRenderOptions,
    bb: (u32, u32, u32, u32),
    line: ((f32, f32), (f32, f32)),
    water: bool,
) -> Option<LabelCandidate> {
    let rotation = label_rotation(Some(line));
    let glyph_count = text.chars().count().max(1) as f32;
    let map_cell_screen = opts.pixel_size * opts.zoom;
    if map_cell_screen < LABEL_MIN_MAP_CELL_SCREEN {
        return None;
    }

    let ((ax, ay), (bx, by)) = line;
    let center = ((ax + bx) * 0.5, (ay + by) * 0.5);
    let dx = bx - ax;
    let dy = by - ay;
    let line_w = (dx * dx + dy * dy).sqrt() * opts.pixel_size;
    let max_map_w = line_w * 0.92;
    let text_width = glyph_count * LABEL_FONT_WIDTH_HINT;
    let map_scale = (max_map_w / text_width).clamp(LABEL_MIN_MAP_SCALE, LABEL_MAX_MAP_SCALE);
    let foreground = if water {
        WATER_LABEL_COLOR
    } else {
        LAND_LABEL_COLOR
    };
    Some(LabelCandidate {
        id,
        text,
        x: center.0 * opts.pixel_size,
        y: center.1 * opts.pixel_size,
        rotation,
        scale: map_scale,
        ox: text_width * 0.5,
        oy: LABEL_FONT_HEIGHT_HINT * 0.5,
        foreground,
        area: (bb.2.saturating_sub(bb.0) + 1) * (bb.3.saturating_sub(bb.1) + 1),
    })
}

fn put_pixel(pixels: &mut [u8], width: u32, height: u32, x: i32, y: i32, color: [u8; 4]) {
    if x < 0 || y < 0 || x >= width as i32 || y >= height as i32 {
        return;
    }
    let idx = ((y as u32 * width + x as u32) * 4) as usize;
    pixels[idx] = color[0];
    pixels[idx + 1] = color[1];
    pixels[idx + 2] = color[2];
    pixels[idx + 3] = color[3];
}

fn blend_pixel(pixels: &mut [u8], width: u32, height: u32, x: i32, y: i32, color: [u8; 4]) {
    if x < 0 || y < 0 || x >= width as i32 || y >= height as i32 {
        return;
    }
    let idx = ((y as u32 * width + x as u32) * 4) as usize;
    let alpha = color[3] as f32 / 255.0;
    let inv = 1.0 - alpha;
    pixels[idx] = (color[0] as f32 * alpha + pixels[idx] as f32 * inv).round() as u8;
    pixels[idx + 1] = (color[1] as f32 * alpha + pixels[idx + 1] as f32 * inv).round() as u8;
    pixels[idx + 2] = (color[2] as f32 * alpha + pixels[idx + 2] as f32 * inv).round() as u8;
    pixels[idx + 3] = 255;
}

fn smoothstep(edge0: f32, edge1: f32, x: f32) -> f32 {
    let t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

fn distance_to_segment(px: f32, py: f32, x0: f32, y0: f32, x1: f32, y1: f32) -> f32 {
    let dx = x1 - x0;
    let dy = y1 - y0;
    let len_sq = dx * dx + dy * dy;
    if len_sq <= f32::EPSILON {
        return ((px - x0) * (px - x0) + (py - y0) * (py - y0)).sqrt();
    }
    let t = (((px - x0) * dx + (py - y0) * dy) / len_sq).clamp(0.0, 1.0);
    let qx = x0 + t * dx;
    let qy = y0 + t * dy;
    ((px - qx) * (px - qx) + (py - qy) * (py - qy)).sqrt()
}

fn pair_is_water(registry: &ProvinceRegistry, id: ProvinceId) -> bool {
    registry
        .style_for(id)
        .map(|style| style.terrain_type == 0)
        .unwrap_or(false)
}

fn segment_border_style(
    registry: &ProvinceRegistry,
    a: ProvinceId,
    b: ProvinceId,
) -> ([u8; 4], f32) {
    let a_water = pair_is_water(registry, a);
    let b_water = pair_is_water(registry, b);
    if a_water != b_water {
        return ([224, 196, 128, 255], 2.0);
    }
    if a_water && b_water {
        return ([48, 94, 146, 255], 1.0);
    }
    let pair_style = registry.get_border_pair_style(a, b).unwrap_or_default();
    if pair_style.flags.contains_bits(BorderPairFlags::COUNTRY) {
        let color = pair_style
            .color
            .map(color_to_u8)
            .unwrap_or([230, 46, 42, 255]);
        return (color, pair_style.thickness.max(1.0));
    }
    ([64, 64, 60, 255], pair_style.thickness.max(1.0))
}

fn draw_thick_segment(
    pixels: &mut [u8],
    width: u32,
    height: u32,
    p0: (f32, f32),
    p1: (f32, f32),
    thickness: f32,
    color: [u8; 4],
) {
    let half = ((thickness - 1.0) * 0.5).max(0.0);
    let margin = half.ceil() as i32 + 1;
    let min_x = p0.0.min(p1.0).floor() as i32 - margin;
    let max_x = p0.0.max(p1.0).ceil() as i32 + margin;
    let min_y = p0.1.min(p1.1).floor() as i32 - margin;
    let max_y = p0.1.max(p1.1).ceil() as i32 + margin;
    for y in min_y..=max_y {
        for x in min_x..=max_x {
            let d = distance_to_segment(x as f32 + 0.5, y as f32 + 0.5, p0.0, p0.1, p1.0, p1.1);
            if d <= half + 0.5 {
                put_pixel(pixels, width, height, x, y, color);
            }
        }
    }
}

struct SegmentShadowContext<'a> {
    pixels: &'a mut [u8],
    shadow_alpha: &'a mut [u8],
    width: u32,
    height: u32,
    scale: u32,
    origin_x: u32,
    origin_y: u32,
    radius: f32,
    strength: f32,
}

fn draw_segment_shadow(registry: &ProvinceRegistry, ctx: &mut SegmentShadowContext<'_>) {
    if ctx.radius <= 0.0 || ctx.strength <= 0.0 {
        return;
    }
    let scan_radius = ctx.radius.ceil() as i32 + 2;
    for &(a, b, x0, y0, x1, y1) in registry.border_segments() {
        let (_, thickness) = segment_border_style(registry, ProvinceId(a), ProvinceId(b));
        let p0 = (
            (x0 as i64 - ctx.origin_x as i64) as f32 * ctx.scale as f32,
            (y0 as i64 - ctx.origin_y as i64) as f32 * ctx.scale as f32,
        );
        let p1 = (
            (x1 as i64 - ctx.origin_x as i64) as f32 * ctx.scale as f32,
            (y1 as i64 - ctx.origin_y as i64) as f32 * ctx.scale as f32,
        );
        let half = ((thickness - 1.0) * 0.5).max(0.0);
        let min_x = p0.0.min(p1.0).floor() as i32 - scan_radius;
        let max_x = p0.0.max(p1.0).ceil() as i32 + scan_radius;
        let min_y = p0.1.min(p1.1).floor() as i32 - scan_radius;
        let max_y = p0.1.max(p1.1).ceil() as i32 + scan_radius;
        if max_x < 0 || max_y < 0 || min_x >= ctx.width as i32 || min_y >= ctx.height as i32 {
            continue;
        }
        for y in min_y..=max_y {
            if y < 0 || y >= ctx.height as i32 {
                continue;
            }
            for x in min_x..=max_x {
                if x < 0 || x >= ctx.width as i32 {
                    continue;
                }
                let dist =
                    (distance_to_segment(x as f32 + 0.5, y as f32 + 0.5, p0.0, p0.1, p1.0, p1.1)
                        - half)
                        .max(0.0);
                if dist > ctx.radius {
                    continue;
                }
                let falloff = 1.0 - smoothstep(0.0, ctx.radius, dist);
                let alpha = (255.0 * ctx.strength * falloff * falloff).round() as u8;
                let idx = (y as u32 * ctx.width + x as u32) as usize;
                ctx.shadow_alpha[idx] = ctx.shadow_alpha[idx].max(alpha);
            }
        }
    }
    for y in 0..ctx.height {
        for x in 0..ctx.width {
            let alpha = ctx.shadow_alpha[(y * ctx.width + x) as usize];
            if alpha == 0 {
                continue;
            }
            let idx = ((y * ctx.width + x) * 4) as usize;
            let province_id = ProvinceId(
                registry.get_at(ctx.origin_x + x / ctx.scale, ctx.origin_y + y / ctx.scale),
            );
            let shadow_rgb = if pair_is_water(registry, province_id) {
                [
                    (ctx.pixels[idx] as f32 * 0.85).round() as u8,
                    (ctx.pixels[idx + 1] as f32 * 0.85).round() as u8,
                    (ctx.pixels[idx + 2] as f32 * 0.85).round() as u8,
                    alpha,
                ]
            } else {
                [64, 64, 60, alpha]
            };
            blend_pixel(
                ctx.pixels, ctx.width, ctx.height, x as i32, y as i32, shadow_rgb,
            );
        }
    }
}

/// Rasterize a province map using registry spans and border segments.
pub fn render_segment_raster(
    registry: &ProvinceRegistry,
    opts: &ProvinceSegmentRasterOptions,
) -> ProvinceSegmentRaster {
    let scale = opts.pixel_size.max(1);
    let origin_x = opts.map_x.min(registry.width());
    let origin_y = opts.map_y.min(registry.height());
    let cell_w = if opts.map_w == 0 {
        registry.width().saturating_sub(origin_x)
    } else {
        opts.map_w.min(registry.width().saturating_sub(origin_x))
    };
    let cell_h = if opts.map_h == 0 {
        registry.height().saturating_sub(origin_y)
    } else {
        opts.map_h.min(registry.height().saturating_sub(origin_y))
    };
    let width = cell_w.saturating_mul(scale);
    let height = cell_h.saturating_mul(scale);
    let mut pixels = vec![
        0u8;
        (width as usize)
            .saturating_mul(height as usize)
            .saturating_mul(4)
    ];
    for chunk in pixels.chunks_exact_mut(4) {
        chunk.copy_from_slice(&[8, 12, 20, 255]);
    }

    if opts.draw_fills {
        let mode_config = registry.map_mode_config();
        let end_y = origin_y.saturating_add(cell_h);
        let end_x = origin_x.saturating_add(cell_w);
        for &(id_raw, y, x0, x1) in registry.spans() {
            if y < origin_y || y >= end_y || x1 <= origin_x || x0 >= end_x {
                continue;
            }
            let id = ProvinceId(id_raw);
            let Some(style) = registry.style_for(id) else {
                continue;
            };
            if is_hidden(style.visibility_state) {
                continue;
            }
            let base_color = if is_discovered(style.visibility_state) {
                discovered_fill_color()
            } else {
                resolve_color_fallback(mode_config, style)
            };
            let color = opts.province_tints.get(&id).copied().unwrap_or(base_color);
            let rgba = color_to_u8([
                color[0] * opts.tint[0],
                color[1] * opts.tint[1],
                color[2] * opts.tint[2],
                color[3] * opts.tint[3],
            ]);
            let clipped_x0 = x0.max(origin_x);
            let clipped_x1 = x1.min(end_x);
            let y0 = y.saturating_sub(origin_y).saturating_mul(scale);
            let y1 = y0.saturating_add(scale);
            let sx0 = clipped_x0.saturating_sub(origin_x).saturating_mul(scale);
            let sx1 = clipped_x1.saturating_sub(origin_x).saturating_mul(scale);
            for py in y0..y1 {
                for px in sx0..sx1 {
                    let idx = ((py * width + px) * 4) as usize;
                    pixels[idx] = rgba[0];
                    pixels[idx + 1] = rgba[1];
                    pixels[idx + 2] = rgba[2];
                    pixels[idx + 3] = rgba[3];
                }
            }
        }
    }

    if opts.draw_borders {
        let mut shadow_alpha = vec![0u8; (width as usize).saturating_mul(height as usize)];
        let mut shadow_ctx = SegmentShadowContext {
            pixels: &mut pixels,
            shadow_alpha: &mut shadow_alpha,
            width,
            height,
            scale,
            origin_x,
            origin_y,
            radius: opts.edge_gradient_radius.max(0.0),
            strength: opts.edge_gradient_strength.clamp(0.0, 1.0),
        };
        draw_segment_shadow(registry, &mut shadow_ctx);
        for &(a, b, x0, y0, x1, y1) in registry.border_segments() {
            let (color, thickness) = segment_border_style(registry, ProvinceId(a), ProvinceId(b));
            draw_thick_segment(
                &mut pixels,
                width,
                height,
                (
                    (x0 as i64 - origin_x as i64) as f32 * scale as f32,
                    (y0 as i64 - origin_y as i64) as f32 * scale as f32,
                ),
                (
                    (x1 as i64 - origin_x as i64) as f32 * scale as f32,
                    (y1 as i64 - origin_y as i64) as f32 * scale as f32,
                ),
                thickness,
                color,
            );
        }
    }

    ProvinceSegmentRaster {
        pixels,
        width,
        height,
    }
}

/// Generate a RenderCommand Vec for the province map: fills, borders, capitals, and labels with viewport culling.
pub fn generate_render_commands(
    registry: &ProvinceRegistry,
    opts: &ProvinceRenderOptions,
    font_key: Option<FontKey>,
) -> Vec<RenderCommand> {
    let mut cmds: Vec<RenderCommand> = Vec::new();
    let (left, top, right, bottom) = viewport_bounds(opts);
    let zoom_mode = resolve_zoom_mode(opts);
    cmds.push(RenderCommand::PushTransform);
    cmds.push(RenderCommand::Translate {
        x: opts.x,
        y: opts.y,
    });
    cmds.push(RenderCommand::Scale {
        sx: opts.zoom,
        sy: opts.zoom,
    });
    if opts.draw_fills {
        for id in registry.province_ids() {
            let Some(bb) = registry.bbox_for(id) else {
                continue;
            };
            if (bb.2 as f32) < left {
                continue;
            }
            if (bb.0 as f32) > right {
                continue;
            }
            if (bb.3 as f32) < top {
                continue;
            }
            if (bb.1 as f32) > bottom {
                continue;
            }
            let Some(style) = registry.style_for(id) else {
                continue;
            };
            if is_hidden(style.visibility_state) {
                continue;
            }
            let base_color = if is_discovered(style.visibility_state) {
                discovered_fill_color()
            } else {
                let mode_config = registry.map_mode_config();
                resolve_color_fallback(mode_config, style)
            };
            let c = fill_color_for_province(opts, id, base_color);
            cmds.push(RenderCommand::SetColor(c[0], c[1], c[2], c[3]));
            if let Some(spans) = registry.spans_for(id) {
                // Merge vertically-adjacent spans with same x0,x1 into taller rectangles
                let mut i = 0;
                while i < spans.len() {
                    let (y, x0, x1) = spans[i];
                    if (y as f32) > bottom || (x1 as f32) <= left || (x0 as f32) >= right {
                        i += 1;
                        continue;
                    }
                    if (y as f32) < top {
                        i += 1;
                        continue;
                    }
                    // Try to merge consecutive spans with same x0, x1
                    let mut height: u32 = 1;
                    while i + (height as usize) < spans.len() {
                        let (ny, nx0, nx1) = spans[i + height as usize];
                        if nx0 == x0 && nx1 == x1 && ny == y + height {
                            height += 1;
                            if (ny as f32) > bottom {
                                break;
                            }
                        } else {
                            break;
                        }
                    }
                    cmds.push(RenderCommand::Rectangle {
                        mode: DrawMode::Fill,
                        x: x0 as f32 * opts.pixel_size,
                        y: y as f32 * opts.pixel_size,
                        w: (x1 - x0) as f32 * opts.pixel_size,
                        h: height as f32 * opts.pixel_size,
                    });
                    i += height as usize;
                }
            }
        }
    }
    if opts.draw_borders {
        let effective_scale = opts.zoom * opts.pixel_size;
        // LOD: skip all borders when they'd be sub-pixel
        if effective_scale >= 0.5 {
            let mut active_width: Option<f32> = None;
            let mut active_color: Option<[f32; 4]> = None;
            for &(a, b, x0, y0, x1, y1) in registry.border_segments() {
                let min_x = x0.min(x1) as f32;
                let max_x = x0.max(x1) as f32;
                let min_y = y0.min(y1) as f32;
                let max_y = y0.max(y1) as f32;
                if max_x < left || min_x > right || max_y < top || min_y > bottom {
                    continue;
                }
                let Some(sa) = registry.style_for(ProvinceId(a)) else {
                    continue;
                };
                let Some(sb) = registry.style_for(ProvinceId(b)) else {
                    continue;
                };
                if !is_fully_visible(sa.visibility_state) || !is_fully_visible(sb.visibility_state)
                {
                    continue;
                }
                let pair_style_override =
                    registry.get_border_pair_style(ProvinceId(a), ProvinceId(b));
                let pair_style = pair_style_override.unwrap_or_default();
                let is_country = pair_style.flags.contains_bits(BorderPairFlags::COUNTRY);
                if !should_render_border_in_mode(zoom_mode, is_country) {
                    continue;
                }

                let width = border_width_from_registry(
                    registry,
                    ProvinceId(a),
                    ProvinceId(b),
                    opts.border_width,
                );
                if active_width != Some(width) {
                    cmds.push(RenderCommand::SetLineWidth(width));
                    active_width = Some(width);
                }

                let color = pair_style.color.unwrap_or_else(|| {
                    border_color_from_registry(registry, ProvinceId(a), ProvinceId(b))
                });
                if active_color != Some(color) {
                    cmds.push(RenderCommand::SetColor(
                        color[0], color[1], color[2], color[3],
                    ));
                    active_color = Some(color);
                }

                cmds.push(RenderCommand::Line {
                    x1: x0 as f32 * opts.pixel_size,
                    y1: y0 as f32 * opts.pixel_size,
                    x2: x1 as f32 * opts.pixel_size,
                    y2: y1 as f32 * opts.pixel_size,
                });
            }
        }
    }
    if opts.draw_roads && zoom_mode == ProvinceZoomMode::Tactical {
        cmds.push(RenderCommand::SetLineWidth(
            (opts.border_width * 1.25).max(1.0),
        ));
        cmds.push(RenderCommand::SetColor(
            140.0 / 255.0,
            100.0 / 255.0,
            62.0 / 255.0,
            0.85,
        ));
        for (a, b) in registry.adjacency_pairs() {
            let Some(sa) = registry.style_for(a) else {
                continue;
            };
            let Some(sb) = registry.style_for(b) else {
                continue;
            };
            if !is_fully_visible(sa.visibility_state) || !is_fully_visible(sb.visibility_state) {
                continue;
            }
            let Some((ax, ay)) = registry.capital_for(a) else {
                continue;
            };
            let Some((bx, by)) = registry.capital_for(b) else {
                continue;
            };
            let min_x = ax.min(bx);
            let max_x = ax.max(bx);
            let min_y = ay.min(by);
            let max_y = ay.max(by);
            if max_x < left || min_x > right || max_y < top || min_y > bottom {
                continue;
            }
            cmds.push(RenderCommand::Line {
                x1: ax * opts.pixel_size,
                y1: ay * opts.pixel_size,
                x2: bx * opts.pixel_size,
                y2: by * opts.pixel_size,
            });
        }
    }
    if opts.draw_capitals {
        for id in registry.province_ids() {
            let Some(bb) = registry.bbox_for(id) else {
                continue;
            };
            if (bb.2 as f32) < left {
                continue;
            }
            if (bb.0 as f32) > right {
                continue;
            }
            if (bb.3 as f32) < top {
                continue;
            }
            if (bb.1 as f32) > bottom {
                continue;
            }
            let Some(style) = registry.style_for(id) else {
                continue;
            };
            if !is_fully_visible(style.visibility_state) {
                continue;
            }
            let Some((cx, cy)) = registry.capital_for(id) else {
                continue;
            };
            cmds.push(RenderCommand::SetColor(
                1.0,
                220.0 / 255.0,
                70.0 / 255.0,
                1.0,
            ));
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: cx * opts.pixel_size,
                y: cy * opts.pixel_size,
                r: (opts.pixel_size * 0.42).max(2.0),
            });
            cmds.push(RenderCommand::SetColor(
                20.0 / 255.0,
                20.0 / 255.0,
                20.0 / 255.0,
                1.0,
            ));
            cmds.push(RenderCommand::Circle {
                mode: DrawMode::Fill,
                x: cx * opts.pixel_size,
                y: cy * opts.pixel_size,
                r: (opts.pixel_size * 0.24).max(1.0),
            });
        }
    }
    if opts.draw_labels {
        if let Some(font) = font_key {
            let mut candidates = Vec::new();
            for id in registry.province_ids() {
                let Some(bb) = registry.bbox_for(id) else {
                    continue;
                };
                if (bb.2 as f32) < left {
                    continue;
                }
                if (bb.0 as f32) > right {
                    continue;
                }
                if (bb.3 as f32) < top {
                    continue;
                }
                if (bb.1 as f32) > bottom {
                    continue;
                }
                let Some(style) = registry.style_for(id) else {
                    continue;
                };
                if !is_fully_visible(style.visibility_state) {
                    continue;
                }
                let text = registry
                    .label_text_for(id)
                    .map(|s| s.to_string())
                    .unwrap_or_else(|| id.to_string());
                let Some(line) = registry
                    .label_line_for(id)
                    .or_else(|| registry.auto_label_line_for(id))
                else {
                    continue;
                };
                let water = style.terrain_type == 0;
                if let Some(candidate) = label_candidate(id, text, opts, bb, line, water) {
                    candidates.push(candidate);
                }
            }
            candidates.sort_by(|a, b| b.area.cmp(&a.area).then_with(|| a.id.cmp(&b.id)));

            for label in candidates {
                cmds.push(RenderCommand::SetColor(
                    label.foreground[0],
                    label.foreground[1],
                    label.foreground[2],
                    label.foreground[3],
                ));
                cmds.push(RenderCommand::PrintTransformed {
                    font_key: font,
                    text: label.text,
                    x: label.x,
                    y: label.y,
                    rotation: label.rotation,
                    sx: label.scale,
                    sy: label.scale,
                    ox: label.ox,
                    oy: label.oy,
                    scale: 1.0,
                });
            }
        }
    }
    if let Some(id) = opts.hovered_id {
        let can_draw_hover = registry
            .style_for(id)
            .map(|style| is_fully_visible(style.visibility_state))
            .unwrap_or(false);
        if can_draw_hover {
            if let Some((min_x, min_y, max_x, max_y)) = registry.bbox_for(id) {
                cmds.push(RenderCommand::SetColor(1.0, 1.0, 1.0, 0.35));
                cmds.push(RenderCommand::SetLineWidth(2.0));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Line,
                    x: min_x as f32 * opts.pixel_size,
                    y: min_y as f32 * opts.pixel_size,
                    w: (max_x.saturating_sub(min_x) + 1) as f32 * opts.pixel_size,
                    h: (max_y.saturating_sub(min_y) + 1) as f32 * opts.pixel_size,
                });
            }
        }
    }
    if let Some(id) = opts.selected_id {
        let can_draw_selected = registry
            .style_for(id)
            .map(|style| is_fully_visible(style.visibility_state))
            .unwrap_or(false);
        if can_draw_selected {
            if let Some((min_x, min_y, max_x, max_y)) = registry.bbox_for(id) {
                cmds.push(RenderCommand::SetColor(1.0, 0.9, 0.1, 0.9));
                cmds.push(RenderCommand::SetLineWidth(3.0));
                cmds.push(RenderCommand::Rectangle {
                    mode: DrawMode::Line,
                    x: min_x as f32 * opts.pixel_size,
                    y: min_y as f32 * opts.pixel_size,
                    w: (max_x.saturating_sub(min_x) + 1) as f32 * opts.pixel_size,
                    h: (max_y.saturating_sub(min_y) + 1) as f32 * opts.pixel_size,
                });
            }
        }
    }
    cmds.push(RenderCommand::SetLineWidth(1.0));
    cmds.push(RenderCommand::PopTransform);
    cmds
}
