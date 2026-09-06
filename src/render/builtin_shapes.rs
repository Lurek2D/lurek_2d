//! Deterministic native shape catalogue used by Lua agents and examples.
//!
//! The catalogue is intentionally code-resident: release binaries do not need to
//! locate repository-relative SVG/TOML files.  The source catalogue is mirrored by
//! `tools/render/gen_builtin_shapes.py`; this compact generated-style module keeps
//! the runtime path allocation-free apart from the requested `CompoundShape`.

use super::renderer::DrawMode;
use super::shape::{CompoundShape, ShapeCommand};
use std::f32::consts::TAU;
use std::sync::OnceLock;

/// Metadata exposed by `lurek.render.listBuiltinShapes`.
#[derive(Debug, Clone, Copy)]
pub struct BuiltinShapeInfo {
    /// Stable canonical ID (`category/name`).
    pub id: &'static str,
    /// One of the eight catalogue groups.
    pub category: &'static str,
    /// Human-readable display label.
    pub label: &'static str,
    /// Normalized anchor in the 64×64 view box.
    pub anchor: [f32; 2],
    /// Search tags.
    pub tags: &'static [&'static str],
    /// Primitive vocabulary used by the template's canonical source entry.
    pub primitives: &'static [&'static str],
    /// Default role colours used when the template is loaded without overrides.
    pub palette: &'static [BuiltinPaletteRole],
}

/// One closed palette role exposed as catalogue metadata.
#[derive(Debug, Clone, Copy)]
pub struct BuiltinPaletteRole {
    /// Closed semantic role name.
    pub role: &'static str,
    /// Normalized RGBA colour.
    pub color: [f32; 4],
}

const DEFAULT_PALETTE: [BuiltinPaletteRole; 8] = [
    BuiltinPaletteRole {
        role: "background",
        color: [0.08, 0.10, 0.14, 1.0],
    },
    BuiltinPaletteRole {
        role: "primary",
        color: [0.82, 0.86, 0.92, 1.0],
    },
    BuiltinPaletteRole {
        role: "secondary",
        color: [0.42, 0.50, 0.62, 1.0],
    },
    BuiltinPaletteRole {
        role: "accent",
        color: [0.95, 0.63, 0.18, 1.0],
    },
    BuiltinPaletteRole {
        role: "outline",
        color: [0.08, 0.10, 0.14, 1.0],
    },
    BuiltinPaletteRole {
        role: "highlight",
        color: [1.0, 1.0, 1.0, 1.0],
    },
    BuiltinPaletteRole {
        role: "shadow",
        color: [0.18, 0.20, 0.28, 1.0],
    },
    BuiltinPaletteRole {
        role: "emissive",
        color: [0.35, 0.95, 0.92, 1.0],
    },
];

/// Return all 96 canonical metadata entries in deterministic category/name order.
pub fn all() -> Vec<BuiltinShapeInfo> {
    static CATALOG: OnceLock<Vec<BuiltinShapeInfo>> = OnceLock::new();
    CATALOG.get_or_init(build_all).clone()
}

fn build_all() -> Vec<BuiltinShapeInfo> {
    debug_assert_eq!(
        crate::render::builtin_shape_catalog_generated::GENERATED_BUILTIN_SHAPE_METADATA.len(),
        96
    );
    debug_assert_eq!(
        crate::render::builtin_shape_catalog_generated::GENERATED_BUILTIN_SHAPE_IDS.len(),
        crate::render::builtin_shape_catalog_generated::GENERATED_BUILTIN_SHAPE_METADATA.len()
    );
    let mut result = Vec::with_capacity(
        crate::render::builtin_shape_catalog_generated::GENERATED_BUILTIN_SHAPE_METADATA.len(),
    );
    for metadata in crate::render::builtin_shape_catalog_generated::GENERATED_BUILTIN_SHAPE_METADATA
    {
        let id = metadata.id;
        let category = metadata.category;
        let name = id.rsplit('/').next().unwrap_or(id);
        let label = Box::leak(
            name.split('_')
                .map(|part| {
                    let mut chars = part.chars();
                    match chars.next() {
                        Some(first) => first.to_uppercase().collect::<String>() + chars.as_str(),
                        None => String::new(),
                    }
                })
                .collect::<Vec<_>>()
                .join(" ")
                .into_boxed_str(),
        );
        result.push(BuiltinShapeInfo {
            id,
            category,
            label,
            anchor: metadata.anchor,
            tags: metadata.tags,
            primitives: metadata.primitives,
            palette: if metadata.palette.is_empty() {
                &DEFAULT_PALETTE
            } else {
                metadata.palette
            },
        });
    }
    result
}

/// Find a canonical ID or an unambiguous bare name.
pub fn resolve_id(id: &str) -> Option<String> {
    let entries = all();
    if entries.iter().any(|entry| entry.id == id) {
        return Some(id.to_string());
    }
    let matches: Vec<&BuiltinShapeInfo> = entries
        .iter()
        .filter(|entry| entry.id.rsplit('/').next() == Some(id))
        .collect();
    if matches.len() == 1 {
        Some(matches[0].id.to_string())
    } else {
        None
    }
}

/// Return metadata for a canonical or unambiguous bare ID.
pub fn info(id: &str) -> Option<BuiltinShapeInfo> {
    let canonical = resolve_id(id)?;
    all().into_iter().find(|entry| entry.id == canonical)
}

/// Build one flat-colour shape template from primitives and compile it immediately
/// with the default curve tolerance.
pub fn build(id: &str, palette: &[(String, [f32; 4])]) -> Result<CompoundShape, String> {
    build_with_tolerance(id, palette, 0.1)
}

/// Build one flat-colour shape template and compile it with a caller-selected tolerance.
pub fn build_with_tolerance(
    id: &str,
    palette: &[(String, [f32; 4])],
    tolerance: f32,
) -> Result<CompoundShape, String> {
    let canonical =
        resolve_id(id).ok_or_else(|| format!("unknown or ambiguous builtin shape '{id}'"))?;
    let metadata =
        info(&canonical).ok_or_else(|| format!("unknown builtin shape metadata '{canonical}'"))?;
    let mut shape = CompoundShape::new();
    for entry in metadata.palette {
        shape.set_palette_role(entry.role, entry.color)?;
    }
    for (role, color) in palette {
        shape.set_palette_role(role, *color)?;
    }
    let name = canonical.rsplit('/').next().unwrap_or(canonical.as_str());
    let category = canonical.split('/').next().unwrap_or_default();
    shape.push_command(ShapeCommand::SetColorRole("primary".into()));
    match category {
        "blocks_terrain" => block_template(&mut shape, name),
        "character" => character_template(&mut shape, name),
        "creature" => creature_template(&mut shape, name),
        "item" => item_template(&mut shape, name),
        "prop" => prop_template(&mut shape, name),
        "ui" => ui_template(&mut shape, name),
        "effect" => effect_template(&mut shape, name),
        "data_viz" => data_viz_template(&mut shape, name),
        _ => return Err(format!("unknown builtin category '{category}'")),
    }
    shape.compile(tolerance)?;
    Ok(shape)
}

fn rect(shape: &mut CompoundShape, mode: DrawMode, x: f32, y: f32, w: f32, h: f32) {
    shape.push_command(ShapeCommand::Rectangle { mode, x, y, w, h });
}

fn circle(shape: &mut CompoundShape, mode: DrawMode, x: f32, y: f32, r: f32) {
    shape.push_command(ShapeCommand::Circle { mode, x, y, r });
}

fn polygon(shape: &mut CompoundShape, mode: DrawMode, vertices: &[f32]) {
    shape.push_command(ShapeCommand::Polygon {
        mode,
        vertices: vertices.to_vec(),
    });
}

fn block_template(shape: &mut CompoundShape, name: &str) {
    rect(shape, DrawMode::Fill, 4.0, 4.0, 56.0, 56.0);
    shape.push_command(ShapeCommand::SetColorRole("outline".into()));
    shape.push_command(ShapeCommand::SetLineWidth(3.0));
    rect(shape, DrawMode::Line, 4.0, 4.0, 56.0, 56.0);
    shape.push_command(ShapeCommand::SetColorRole("secondary".into()));
    match name {
        "brick_block" => {
            rect(shape, DrawMode::Line, 8.0, 20.0, 48.0, 0.0);
            rect(shape, DrawMode::Line, 8.0, 40.0, 48.0, 0.0);
        }
        "grass_tile" => rect(shape, DrawMode::Fill, 4.0, 4.0, 56.0, 12.0),
        "water_tile" => {
            shape.push_command(ShapeCommand::Arc {
                mode: DrawMode::Line,
                x: 20.0,
                y: 28.0,
                radius: 12.0,
                angle1: 0.0,
                angle2: std::f32::consts::PI,
                segments: 16,
            });
            shape.push_command(ShapeCommand::Arc {
                mode: DrawMode::Line,
                x: 44.0,
                y: 40.0,
                radius: 12.0,
                angle1: std::f32::consts::PI,
                angle2: std::f32::consts::TAU,
                segments: 16,
            });
        }
        "platform" => rect(shape, DrawMode::Fill, 2.0, 22.0, 60.0, 18.0),
        "slope_up" => polygon(shape, DrawMode::Fill, &[4.0, 56.0, 60.0, 56.0, 60.0, 4.0]),
        "slope_down" => polygon(shape, DrawMode::Fill, &[4.0, 4.0, 60.0, 56.0, 4.0, 56.0]),
        "wall" => rect(shape, DrawMode::Fill, 12.0, 4.0, 40.0, 56.0),
        "door" => {
            rect(shape, DrawMode::Fill, 12.0, 8.0, 40.0, 48.0);
            circle(shape, DrawMode::Fill, 42.0, 34.0, 3.0);
        }
        "spikes" => polygon(
            shape,
            DrawMode::Fill,
            &[
                4.0, 56.0, 12.0, 20.0, 20.0, 56.0, 28.0, 20.0, 36.0, 56.0, 44.0, 20.0, 52.0, 56.0,
                60.0, 20.0, 60.0, 56.0,
            ],
        ),
        _ => {}
    }
}

fn character_template(shape: &mut CompoundShape, name: &str) {
    circle(shape, DrawMode::Fill, 32.0, 18.0, 11.0);
    shape.push_command(ShapeCommand::SetColorRole("secondary".into()));
    rect(shape, DrawMode::Fill, 18.0, 29.0, 28.0, 24.0);
    shape.push_command(ShapeCommand::SetColorRole("outline".into()));
    shape.push_command(ShapeCommand::SetLineWidth(3.0));
    circle(shape, DrawMode::Line, 32.0, 18.0, 11.0);
    rect(shape, DrawMode::Line, 18.0, 29.0, 28.0, 24.0);
    shape.push_command(ShapeCommand::SetColorRole("accent".into()));
    circle(shape, DrawMode::Fill, 27.0, 17.0, 2.0);
    circle(shape, DrawMode::Fill, 37.0, 17.0, 2.0);
    if matches!(name, "warrior" | "guard") {
        rect(shape, DrawMode::Fill, 12.0, 34.0, 6.0, 16.0);
        rect(shape, DrawMode::Fill, 46.0, 34.0, 6.0, 16.0);
    } else if name == "mage" {
        polygon(shape, DrawMode::Fill, &[18.0, 10.0, 32.0, 0.0, 46.0, 10.0]);
    } else if name == "robot" || name == "astronaut" {
        rect(shape, DrawMode::Line, 22.0, 12.0, 20.0, 12.0);
    } else if name == "ghost" {
        polygon(
            shape,
            DrawMode::Fill,
            &[
                18.0, 48.0, 18.0, 56.0, 25.0, 51.0, 32.0, 56.0, 39.0, 51.0, 46.0, 56.0, 46.0, 48.0,
            ],
        );
    }
}

fn creature_template(shape: &mut CompoundShape, name: &str) {
    shape.push_command(ShapeCommand::SetColorRole("secondary".into()));
    circle(shape, DrawMode::Fill, 32.0, 34.0, 20.0);
    shape.push_command(ShapeCommand::SetColorRole("outline".into()));
    shape.push_command(ShapeCommand::SetLineWidth(3.0));
    circle(shape, DrawMode::Line, 32.0, 34.0, 20.0);
    shape.push_command(ShapeCommand::SetColorRole("accent".into()));
    circle(shape, DrawMode::Fill, 25.0, 31.0, 3.0);
    circle(shape, DrawMode::Fill, 39.0, 31.0, 3.0);
    if matches!(name, "bat" | "bird") {
        polygon(shape, DrawMode::Fill, &[30.0, 30.0, 4.0, 16.0, 18.0, 38.0]);
        polygon(shape, DrawMode::Fill, &[34.0, 30.0, 60.0, 16.0, 46.0, 38.0]);
    } else if name == "spider" {
        for y in [26.0, 34.0, 42.0] {
            shape.push_command(ShapeCommand::Line {
                x1: 20.0,
                y1: y,
                x2: 4.0,
                y2: y - 8.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 44.0,
                y1: y,
                x2: 60.0,
                y2: y - 8.0,
            });
        }
    } else if name == "eye" {
        circle(shape, DrawMode::Fill, 32.0, 34.0, 7.0);
    } else if name == "skull" {
        rect(shape, DrawMode::Fill, 22.0, 45.0, 20.0, 9.0);
    }
}

fn item_template(shape: &mut CompoundShape, name: &str) {
    shape.push_command(ShapeCommand::SetColorRole("accent".into()));
    match name {
        "coin" => circle(shape, DrawMode::Fill, 32.0, 32.0, 20.0),
        "gem" => polygon(
            shape,
            DrawMode::Fill,
            &[32.0, 4.0, 54.0, 22.0, 42.0, 56.0, 22.0, 56.0, 10.0, 22.0],
        ),
        "shield" => polygon(
            shape,
            DrawMode::Fill,
            &[10.0, 8.0, 54.0, 8.0, 50.0, 42.0, 32.0, 58.0, 14.0, 42.0],
        ),
        "sword" | "axe" | "hammer" => {
            polygon(
                shape,
                DrawMode::Fill,
                &[28.0, 8.0, 36.0, 8.0, 38.0, 42.0, 32.0, 56.0, 26.0, 42.0],
            );
            rect(shape, DrawMode::Fill, 20.0, 40.0, 24.0, 5.0);
        }
        "bow" => shape.push_command(ShapeCommand::Arc {
            mode: DrawMode::Line,
            x: 26.0,
            y: 32.0,
            radius: 22.0,
            angle1: -1.1,
            angle2: 1.1,
            segments: 24,
        }),
        "potion" => {
            rect(shape, DrawMode::Fill, 24.0, 10.0, 16.0, 10.0);
            shape.push_command(ShapeCommand::SetColorRole("primary".into()));
            circle(shape, DrawMode::Fill, 32.0, 36.0, 18.0);
        }
        "key" => {
            circle(shape, DrawMode::Line, 22.0, 24.0, 8.0);
            rect(shape, DrawMode::Fill, 28.0, 21.0, 26.0, 6.0);
        }
        "scroll" => rect(shape, DrawMode::Fill, 14.0, 12.0, 36.0, 40.0),
        "bomb" => circle(shape, DrawMode::Fill, 30.0, 36.0, 18.0),
        "apple" => circle(shape, DrawMode::Fill, 32.0, 36.0, 18.0),
        _ => rect(shape, DrawMode::Fill, 18.0, 12.0, 28.0, 40.0),
    }
    shape.push_command(ShapeCommand::SetColorRole("outline".into()));
    shape.push_command(ShapeCommand::SetLineWidth(3.0));
    circle(shape, DrawMode::Line, 32.0, 32.0, 22.0);
}

fn prop_template(shape: &mut CompoundShape, name: &str) {
    shape.push_command(ShapeCommand::SetColorRole("secondary".into()));
    match name {
        "tree" => {
            rect(shape, DrawMode::Fill, 27.0, 34.0, 10.0, 24.0);
            circle(shape, DrawMode::Fill, 22.0, 28.0, 15.0);
            circle(shape, DrawMode::Fill, 42.0, 28.0, 15.0);
        }
        "rock" | "bush" => circle(shape, DrawMode::Fill, 32.0, 38.0, 20.0),
        "crate" | "barrel" | "chest" => rect(shape, DrawMode::Fill, 10.0, 14.0, 44.0, 38.0),
        "lamp" => {
            rect(shape, DrawMode::Fill, 29.0, 30.0, 6.0, 26.0);
            circle(shape, DrawMode::Fill, 32.0, 22.0, 13.0);
        }
        "sign" => {
            rect(shape, DrawMode::Fill, 29.0, 30.0, 6.0, 28.0);
            rect(shape, DrawMode::Fill, 10.0, 12.0, 44.0, 24.0);
        }
        "table" => rect(shape, DrawMode::Fill, 8.0, 16.0, 48.0, 12.0),
        "chair" => rect(shape, DrawMode::Fill, 18.0, 14.0, 28.0, 10.0),
        "ladder" => {
            rect(shape, DrawMode::Fill, 14.0, 8.0, 6.0, 48.0);
            rect(shape, DrawMode::Fill, 44.0, 8.0, 6.0, 48.0);
        }
        "campfire" => polygon(shape, DrawMode::Fill, &[32.0, 4.0, 52.0, 54.0, 12.0, 54.0]),
        _ => {}
    }
    shape.push_command(ShapeCommand::SetColorRole("outline".into()));
    shape.push_command(ShapeCommand::SetLineWidth(3.0));
    rect(shape, DrawMode::Line, 8.0, 8.0, 48.0, 48.0);
}

fn ui_template(shape: &mut CompoundShape, name: &str) {
    shape.push_command(ShapeCommand::SetColorRole("accent".into()));
    match name {
        "heart" => polygon(
            shape,
            DrawMode::Fill,
            &[
                32.0, 56.0, 6.0, 28.0, 8.0, 14.0, 20.0, 10.0, 32.0, 22.0, 44.0, 10.0, 56.0, 14.0,
                58.0, 28.0,
            ],
        ),
        "star" => polygon(
            shape,
            DrawMode::Fill,
            &[
                32.0, 4.0, 39.0, 25.0, 60.0, 25.0, 43.0, 37.0, 50.0, 58.0, 32.0, 45.0, 14.0, 58.0,
                21.0, 37.0, 4.0, 25.0, 25.0, 25.0,
            ],
        ),
        "check" => shape.push_command(ShapeCommand::Polyline {
            points: vec![10.0, 32.0, 26.0, 48.0, 54.0, 14.0],
        }),
        "close" => {
            shape.push_command(ShapeCommand::Line {
                x1: 12.0,
                y1: 12.0,
                x2: 52.0,
                y2: 52.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 52.0,
                y1: 12.0,
                x2: 12.0,
                y2: 52.0,
            });
        }
        "plus" => {
            rect(shape, DrawMode::Fill, 26.0, 8.0, 12.0, 48.0);
            rect(shape, DrawMode::Fill, 8.0, 26.0, 48.0, 12.0);
        }
        "minus" => rect(shape, DrawMode::Fill, 8.0, 26.0, 48.0, 12.0),
        "arrow" => polygon(
            shape,
            DrawMode::Fill,
            &[
                8.0, 27.0, 42.0, 27.0, 42.0, 16.0, 58.0, 32.0, 42.0, 48.0, 42.0, 37.0, 8.0, 37.0,
            ],
        ),
        "play" => polygon(shape, DrawMode::Fill, &[18.0, 8.0, 52.0, 32.0, 18.0, 56.0]),
        "pause" => {
            rect(shape, DrawMode::Fill, 14.0, 8.0, 12.0, 48.0);
            rect(shape, DrawMode::Fill, 38.0, 8.0, 12.0, 48.0);
        }
        "lock" => {
            rect(shape, DrawMode::Fill, 14.0, 28.0, 36.0, 28.0);
            shape.push_command(ShapeCommand::Arc {
                mode: DrawMode::Line,
                x: 32.0,
                y: 28.0,
                radius: 14.0,
                angle1: std::f32::consts::PI,
                angle2: TAU,
                segments: 16,
            });
        }
        _ => circle(shape, DrawMode::Line, 32.0, 32.0, 22.0),
    }
}

fn effect_template(shape: &mut CompoundShape, name: &str) {
    shape.push_command(ShapeCommand::SetColorRole("emissive".into()));
    match name {
        "spark" | "burst" | "explosion" => {
            polygon(
                shape,
                DrawMode::Fill,
                &[
                    32.0, 2.0, 38.0, 24.0, 58.0, 14.0, 44.0, 34.0, 62.0, 48.0, 38.0, 44.0, 32.0,
                    62.0, 26.0, 44.0, 2.0, 48.0, 20.0, 34.0, 6.0, 14.0, 26.0, 24.0,
                ],
            );
        }
        "smoke" | "aura" => {
            circle(shape, DrawMode::Line, 22.0, 40.0, 13.0);
            circle(shape, DrawMode::Line, 38.0, 28.0, 16.0);
            circle(shape, DrawMode::Line, 48.0, 44.0, 10.0);
        }
        "flame" => polygon(
            shape,
            DrawMode::Fill,
            &[
                32.0, 4.0, 50.0, 34.0, 42.0, 56.0, 32.0, 46.0, 22.0, 56.0, 14.0, 34.0,
            ],
        ),
        "snowflake" | "lightning" | "slash" => {
            shape.push_command(ShapeCommand::Line {
                x1: 8.0,
                y1: 32.0,
                x2: 56.0,
                y2: 32.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 32.0,
                y1: 8.0,
                x2: 32.0,
                y2: 56.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 14.0,
                y1: 14.0,
                x2: 50.0,
                y2: 50.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 50.0,
                y1: 14.0,
                x2: 14.0,
                y2: 50.0,
            });
        }
        "droplet" => polygon(
            shape,
            DrawMode::Fill,
            &[32.0, 4.0, 52.0, 34.0, 44.0, 54.0, 20.0, 54.0, 12.0, 34.0],
        ),
        "target" => {
            circle(shape, DrawMode::Line, 32.0, 32.0, 24.0);
            circle(shape, DrawMode::Line, 32.0, 32.0, 12.0);
            circle(shape, DrawMode::Fill, 32.0, 32.0, 4.0);
        }
        "trail" => shape.push_command(ShapeCommand::Polyline {
            points: vec![6.0, 48.0, 20.0, 38.0, 34.0, 42.0, 58.0, 16.0],
        }),
        _ => circle(shape, DrawMode::Fill, 32.0, 32.0, 20.0),
    }
}

fn data_viz_template(shape: &mut CompoundShape, name: &str) {
    shape.push_command(ShapeCommand::SetColorRole("primary".into()));
    match name {
        "circle" => circle(shape, DrawMode::Fill, 32.0, 32.0, 18.0),
        "square" => rect(shape, DrawMode::Fill, 14.0, 14.0, 36.0, 36.0),
        "diamond" => polygon(
            shape,
            DrawMode::Fill,
            &[32.0, 8.0, 56.0, 32.0, 32.0, 56.0, 8.0, 32.0],
        ),
        "triangle_up" => polygon(shape, DrawMode::Fill, &[32.0, 8.0, 56.0, 52.0, 8.0, 52.0]),
        "triangle_down" => polygon(shape, DrawMode::Fill, &[8.0, 12.0, 56.0, 12.0, 32.0, 56.0]),
        "cross" | "plus" => {
            rect(shape, DrawMode::Fill, 26.0, 8.0, 12.0, 48.0);
            rect(shape, DrawMode::Fill, 8.0, 26.0, 48.0, 12.0);
        }
        "times" | "asterisk" | "wye" => {
            shape.push_command(ShapeCommand::Line {
                x1: 12.0,
                y1: 12.0,
                x2: 52.0,
                y2: 52.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 52.0,
                y1: 12.0,
                x2: 12.0,
                y2: 52.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 32.0,
                y1: 8.0,
                x2: 32.0,
                y2: 56.0,
            });
        }
        "error_bar" => {
            shape.push_command(ShapeCommand::SetLineWidth(3.0));
            shape.push_command(ShapeCommand::Line {
                x1: 32.0,
                y1: 8.0,
                x2: 32.0,
                y2: 56.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 20.0,
                y1: 8.0,
                x2: 44.0,
                y2: 8.0,
            });
            shape.push_command(ShapeCommand::Line {
                x1: 20.0,
                y1: 56.0,
                x2: 44.0,
                y2: 56.0,
            });
        }
        "arrow_link" => {
            shape.push_command(ShapeCommand::Line {
                x1: 8.0,
                y1: 52.0,
                x2: 50.0,
                y2: 10.0,
            });
            polygon(shape, DrawMode::Fill, &[38.0, 10.0, 54.0, 10.0, 54.0, 26.0]);
        }
        _ => circle(shape, DrawMode::Fill, 32.0, 32.0, 16.0),
    }
}
