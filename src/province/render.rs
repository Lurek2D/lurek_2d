//! Province map rendering: convert registry data into a flat RenderCommand list.
//!
//! - Data type: `ProvinceRenderOptions`.
//! - Enum: `ProvinceZoomMode`.
//! - Function: `generate_render_commands`.
//! - Implementation: `ProvinceRenderOptions`.

use crate::province::map_modes::resolve_color_fallback;
use crate::province::registry::ProvinceRegistry;
use crate::province::types::{BorderPairFlags, ProvinceId};
use crate::render::renderer::{DrawMode, RenderCommand};
use crate::runtime::resource_keys::FontKey;

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

/// Return the RGBA line colour for a border segment based on its registered type config.
fn border_color_from_registry(registry: &ProvinceRegistry, a: ProvinceId, b: ProvinceId) -> [f32; 4] {
    let border_type = registry.get_border_type(a, b).unwrap_or(0);
    registry
        .get_border_type_config(border_type)
        .map(|c| c.color)
        .unwrap_or([0.5, 0.5, 0.5, 1.0])
}

/// Compute the visible province-space bounds (left, top, right, bottom) from the render options.
fn viewport_bounds(opts: &ProvinceRenderOptions) -> (f32, f32, f32, f32) {
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

fn is_hidden(visibility_state: u8) -> bool {
    visibility_state == VISIBILITY_HIDDEN
}

fn is_discovered(visibility_state: u8) -> bool {
    visibility_state == VISIBILITY_DISCOVERED
}

fn is_fully_visible(visibility_state: u8) -> bool {
    visibility_state >= VISIBILITY_VISIBLE_MIN
}

fn resolve_zoom_mode(opts: &ProvinceRenderOptions) -> ProvinceZoomMode {
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

fn should_render_border_in_mode(
    mode: ProvinceZoomMode,
    is_country: bool,
) -> bool {
    match mode {
        ProvinceZoomMode::Tactical => true,
        ProvinceZoomMode::Strategic => is_country,
        ProvinceZoomMode::Auto => is_country,
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
            let c = if is_discovered(style.visibility_state) {
                discovered_fill_color()
            } else {
                let mode_config = registry.map_mode_config();
                resolve_color_fallback(mode_config, style)
            };
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
                if !is_fully_visible(sa.visibility_state) || !is_fully_visible(sb.visibility_state) {
                    continue;
                }
                let pair_style_override = registry.get_border_pair_style(ProvinceId(a), ProvinceId(b));
                let pair_style = pair_style_override.unwrap_or_default();
                let is_country = pair_style.flags.contains_bits(BorderPairFlags::COUNTRY);
                if !should_render_border_in_mode(zoom_mode, is_country) {
                    continue;
                }

                let width = if pair_style_override.is_some() {
                    pair_style.thickness.max(1.0)
                } else {
                    opts.border_width.max(1.0)
                };
                if active_width != Some(width) {
                    cmds.push(RenderCommand::SetLineWidth(width));
                    active_width = Some(width);
                }

                let color = pair_style.color.unwrap_or_else(|| border_color_from_registry(registry, ProvinceId(a), ProvinceId(b)));
                if active_color != Some(color) {
                    cmds.push(RenderCommand::SetColor(color[0], color[1], color[2], color[3]));
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
        cmds.push(RenderCommand::SetLineWidth((opts.border_width * 1.25).max(1.0)));
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
                let ((ax, ay), (bx, by)) = registry
                    .label_line_for(id)
                    .unwrap_or(((bb.0 as f32, bb.1 as f32), (bb.2 as f32, bb.3 as f32)));
                let mx = (ax + bx) * 0.5;
                let my = (ay + by) * 0.5;
                cmds.push(RenderCommand::SetColor(0.0, 0.0, 0.0, 0.65));
                cmds.push(RenderCommand::Print {
                    font_key: font,
                    text: text.clone(),
                    x: mx * opts.pixel_size + 1.0,
                    y: my * opts.pixel_size + 1.0,
                    scale: 0.8,
                });
                cmds.push(RenderCommand::SetColor(0.92, 0.92, 0.86, 1.0));
                cmds.push(RenderCommand::Print {
                    font_key: font,
                    text,
                    x: mx * opts.pixel_size,
                    y: my * opts.pixel_size,
                    scale: 0.8,
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
    cmds.push(RenderCommand::PopTransform);
    cmds
}
