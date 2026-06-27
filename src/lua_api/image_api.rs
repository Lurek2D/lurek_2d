//! Registers the `lurek.image` Lua API for image userdata, dimension checks, GIF options, and image transforms.

use super::render_api::{ensure_shader_target, shader_key_from_userdata};
use super::SharedState;
use crate::image::effects::{ImageEffectOptions, ResizeFilter};
use crate::image::serial;
use crate::image::{
    AnimatedGifOptions, AnimatedGifRepeat, CompressedImageData, ImageData, LayeredImage,
    ProvinceGrid, ProvinceShapeCacheEntry,
};
use crate::render::offline_image_shader::apply_image_shader_blocking;
use crate::render::{DrawMode, RenderCommand, ShaderTarget};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Lua handle for an offline image shader request.
#[derive(Clone)]
pub struct LuaImageShaderJob {
    result: Option<ImageData>,
    cancelled: bool,
    done: bool,
}

impl LuaUserData for LuaImageShaderJob {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- poll --
        /// Returns the shader output image when the job has completed, or nil if pending/cancelled.
        /// @return | LImageData? | Completed image result.
        methods.add_method("poll", |lua, this, ()| {
            if this.done && !this.cancelled {
                match &this.result {
                    Some(image) => Ok(Some(lua.create_userdata(image.clone())?)),
                    None => Ok(None),
                }
            } else {
                Ok(None)
            }
        });
        // -- wait --
        /// Waits for the offline image shader job and returns its output image.
        /// @param | timeoutMs | integer? | Optional timeout in milliseconds.
        /// @return | LImageData? | Completed image result.
        methods.add_method("wait", |lua, this, _timeout_ms: Option<u32>| {
            if this.cancelled {
                return Ok(None);
            }
            match &this.result {
                Some(image) => Ok(Some(lua.create_userdata(image.clone())?)),
                None => Ok(None),
            }
        });
        // -- cancel --
        /// Cancels this image shader job.
        methods.add_method_mut("cancel", |_, this, ()| {
            this.cancelled = true;
            this.done = false;
            this.result = None;
            Ok(())
        });
    }
}

fn parse_lua_u32(value: LuaValue, api: &str, arg_name: &str) -> LuaResult<u32> {
    match value {
        LuaValue::Integer(n) => u32::try_from(n).map_err(|_| {
            LuaError::RuntimeError(format!(
                "{}: {} must be an integer in the range 0..={}",
                api,
                arg_name,
                u32::MAX
            ))
        }),
        LuaValue::Number(n) => {
            if !n.is_finite() || n < 0.0 || n > u32::MAX as f64 || n.fract() != 0.0 {
                return Err(LuaError::RuntimeError(format!(
                    "{}: {} must be an integer in the range 0..={}",
                    api,
                    arg_name,
                    u32::MAX
                )));
            }
            Ok(n as u32)
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{}: {} must be numeric",
            api, arg_name
        ))),
    }
}

fn validate_image_dimensions(api: &str, width: u32, height: u32) -> LuaResult<()> {
    ImageData::rgba_byte_len(width, height)
        .map(|_| ())
        .map_err(|err| LuaError::RuntimeError(format!("{}: {}", api, err)))
}

fn parse_save_gif_options(opts: Option<LuaTable>) -> LuaResult<AnimatedGifOptions> {
    let mut out = AnimatedGifOptions::default();
    let Some(opts) = opts else {
        return Ok(out);
    };

    if let Some(delay_ms) = opts.get::<_, Option<u32>>("delayMs")? {
        out.delay_ms = delay_ms;
    }
    if let Some(speed) = opts.get::<_, Option<i32>>("speed")? {
        out.speed = speed;
    }
    if let Some(loop_enabled) = opts.get::<_, Option<bool>>("loop")? {
        out.repeat = if loop_enabled {
            AnimatedGifRepeat::Infinite
        } else {
            AnimatedGifRepeat::None
        };
    }
    if let Some(loop_count) = opts.get::<_, Option<u16>>("loopCount")? {
        out.repeat = AnimatedGifRepeat::Finite(loop_count);
    }

    Ok(out)
}

fn parse_effect_options(opts: Option<LuaTable>, api: &str) -> LuaResult<ImageEffectOptions> {
    let mut out = ImageEffectOptions::default();
    let Some(opts) = opts else {
        return Ok(out);
    };
    if let Some(factor) = opts.get::<_, Option<f32>>("factor")? {
        out.factor = factor;
    }
    if let Some(amount) = opts.get::<_, Option<u32>>("amount")? {
        out.amount = amount;
    }
    if let Some(value) = opts.get::<_, Option<u8>>("value")? {
        out.value = value;
    }
    if let Some(levels) = opts.get::<_, Option<u8>>("levels")? {
        out.levels = levels;
    }
    if let Some(radius) = opts.get::<_, Option<u32>>("radius")? {
        out.radius = radius;
    }
    if let Some(width) = opts.get::<_, Option<u32>>("width")? {
        out.width = Some(width);
    }
    if let Some(height) = opts.get::<_, Option<u32>>("height")? {
        out.height = Some(height);
    }
    if let Some(filter) = opts.get::<_, Option<String>>("filter")? {
        out.filter = ResizeFilter::parse(&filter).ok_or_else(|| {
            LuaError::RuntimeError(format!("{}: unknown resize filter '{}'", api, filter))
        })?;
    }
    if let Some(color) = opts.get::<_, Option<LuaTable>>("color")? {
        let r = color.get::<_, Option<u8>>(1)?.unwrap_or(0);
        let g = color.get::<_, Option<u8>>(2)?.unwrap_or(0);
        let b = color.get::<_, Option<u8>>(3)?.unwrap_or(0);
        let a = color.get::<_, Option<u8>>(4)?.unwrap_or(255);
        out.color = Some((r, g, b, a));
    }
    Ok(out)
}

fn parse_region(opts: Option<&LuaTable>) -> LuaResult<Option<(u32, u32, u32, u32)>> {
    let Some(opts) = opts else {
        return Ok(None);
    };
    let Some(region) = opts.get::<_, Option<LuaTable>>("region")? else {
        return Ok(None);
    };
    Ok(Some((
        region.get::<_, u32>(1).or_else(|_| region.get("x"))?,
        region.get::<_, u32>(2).or_else(|_| region.get("y"))?,
        region.get::<_, u32>(3).or_else(|_| region.get("w"))?,
        region.get::<_, u32>(4).or_else(|_| region.get("h"))?,
    )))
}

/// Lua-side compatibility handle for a province id grid decoded by the province subsystem.
pub struct LuaProvinceGrid {
    /// Province grid, color mapping, adjacency, spans, and polygon extraction data.
    inner: ProvinceGrid,
    /// Shared runtime state receiving province shape draw commands.
    state: Rc<RefCell<SharedState>>,
    /// Lazily built simplified polygon cache for repeated shape drawing.
    shape_cache: Option<Vec<ProvinceShapeCacheEntry>>,
}
/// Provides Lua methods for province-grid inspection, geometry export, and drawing.
impl LuaUserData for LuaProvinceGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns the province grid width. This method is available to Lua scripts.
        /// @return | integer | Grid width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.width()));
        // -- getHeight --
        /// Returns the province grid height. This method is available to Lua scripts.
        /// @return | integer | Grid height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.height()));
        // -- getAt --
        /// Returns the province id stored at grid coordinates.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @return | integer | Province id at the pixel.
        methods.add_method("getAt", |_, this, (x, y): (u32, u32)| {
            Ok(this.inner.get_at(x, y))
        });
        // -- provinceCount --
        /// Returns the number of distinct provinces in the grid.
        /// @return | integer | Province count.
        methods.add_method("provinceCount", |_, this, ()| {
            Ok(this.inner.province_count())
        });
        // -- adjacencies --
        /// Returns province adjacency records and shared border pixel counts.
        /// @return | table | Array table with `province_a`, `province_b`, and `border_pixels` fields.
        /// @field | province_a | integer | First province id.
        /// @field | province_b | integer | Second province id.
        /// @field | border_pixels | integer | Number of shared border pixels.
        methods.add_method("adjacencies", |lua, this, ()| {
            let t = lua.create_table()?;
            for (i, &(a, b, bp)) in this.inner.adjacencies().iter().enumerate() {
                let entry = lua.create_table()?;
                /// Performs the 'province_a' operation.
                entry.set("province_a", a)?;
                /// Performs the 'province_b' operation.
                entry.set("province_b", b)?;
                /// Performs the 'border_pixels' operation.
                entry.set("border_pixels", bp)?;
                t.set(i + 1, entry)?;
            }
            Ok(t)
        });
        // -- provinceSpans --
        /// Returns horizontal province spans by row.
        /// @return | table | Array table with `province_id`, `y`, `x0`, and `x1` fields.
        /// @field | province_id | integer | Province id.
        /// @field | y | integer | Scanline y coordinate.
        /// @field | x0 | integer | Start x coordinate.
        /// @field | x1 | integer | End x coordinate.
        methods.add_method("provinceSpans", |lua, this, ()| {
            let t = lua.create_table()?;
            for (i, (id, y, x0, x1)) in this.inner.province_spans().into_iter().enumerate() {
                let row = lua.create_table()?;
                /// Performs the 'province_id' operation.
                row.set("province_id", id)?;
                /// The 'y' field value exposed to Lua scripts.
                row.set("y", y)?;
                /// The 'x0' field value exposed to Lua scripts.
                row.set("x0", x0)?;
                /// The 'x1' field value exposed to Lua scripts.
                row.set("x1", x1)?;
                t.set(i + 1, row)?;
            }
            Ok(t)
        });
        // -- borderSegments --
        /// Returns border line segments between neighboring provinces.
        /// @return | table | Array table with province ids and segment coordinates.
        /// @field | province_a | integer | First province id.
        /// @field | province_b | integer | Second province id.
        /// @field | x0 | number | Segment start x.
        /// @field | y0 | number | Segment start y.
        /// @field | x1 | number | Segment end x.
        /// @field | y1 | number | Segment end y.
        methods.add_method("borderSegments", |lua, this, ()| {
            let t = lua.create_table()?;
            for (i, (a, b, x0, y0, x1, y1)) in this.inner.border_segments().into_iter().enumerate()
            {
                let seg = lua.create_table()?;
                /// Performs the 'province_a' operation.
                seg.set("province_a", a)?;
                /// Performs the 'province_b' operation.
                seg.set("province_b", b)?;
                /// The 'x0' field value exposed to Lua scripts.
                seg.set("x0", x0)?;
                /// The 'y0' field value exposed to Lua scripts.
                seg.set("y0", y0)?;
                /// The 'x1' field value exposed to Lua scripts.
                seg.set("x1", x1)?;
                /// The 'y1' field value exposed to Lua scripts.
                seg.set("y1", y1)?;
                t.set(i + 1, seg)?;
            }
            Ok(t)
        });
        // -- getPolygons --
        /// Returns polygon rings for every province.
        /// @return | table | Array table of province polygon records with `province_id` and `rings` fields.
        /// @field | province_id | integer | Province id.
        /// @field | rings | table | Array of rings; each ring is an array of [x, y] pairs.
        methods.add_method("getPolygons", |lua, this, ()| {
            let map = this.inner.province_polygons();
            let out = lua.create_table()?;
            let mut idx = 1usize;
            for (id, rings) in &map {
                let entry = lua.create_table()?;
                /// Performs the 'province_id' operation.
                entry.set("province_id", *id)?;
                let rings_tbl = lua.create_table()?;
                for (ri, ring) in rings.iter().enumerate() {
                    let pts = lua.create_table()?;
                    for (pi, &(x, y)) in ring.iter().enumerate() {
                        let pt = lua.create_table()?;
                        pt.set(1, x)?;
                        pt.set(2, y)?;
                        pts.set(pi + 1, pt)?;
                    }
                    rings_tbl.set(ri + 1, pts)?;
                }
                /// Performs the 'rings' operation.
                entry.set("rings", rings_tbl)?;
                out.set(idx, entry)?;
                idx += 1;
            }
            Ok(out)
        });
        // -- getPolygonsSimplified --
        /// Returns simplified polygon rings for every province.
        /// @return | table | Array table of simplified province polygon records with `province_id` and `rings` fields.
        /// @field | province_id | integer | Province id.
        /// @field | rings | table | Array of simplified rings; each ring is an array of [x, y] pairs.
        methods.add_method("getPolygonsSimplified", |lua, this, ()| {
            let map = this.inner.province_polygons_simplified();
            let out = lua.create_table()?;
            let mut idx = 1usize;
            for (id, rings) in &map {
                let entry = lua.create_table()?;
                /// Performs the 'province_id' operation.
                entry.set("province_id", *id)?;
                let rings_tbl = lua.create_table()?;
                for (ri, ring) in rings.iter().enumerate() {
                    let pts = lua.create_table()?;
                    for (pi, &(x, y)) in ring.iter().enumerate() {
                        let pt = lua.create_table()?;
                        pt.set(1, x)?;
                        pt.set(2, y)?;
                        pts.set(pi + 1, pt)?;
                    }
                    rings_tbl.set(ri + 1, pts)?;
                }
                /// Performs the 'rings' operation.
                entry.set("rings", rings_tbl)?;
                out.set(idx, entry)?;
                idx += 1;
            }
            Ok(out)
        });
        // -- drawShapes --
        /// Queues filled polygon draw commands for province shapes, optionally culled to a viewport rect.
        /// Pass no arguments to draw all shapes, or pass `x, y, w, h` to cull to a rectangle.
        /// @param | x | number? | Viewport left edge (required if providing a viewport).
        /// @param | y | number? | Viewport top edge (required if providing a viewport).
        /// @param | w | number? | Viewport width (required if providing a viewport).
        /// @param | h | number? | Viewport height (required if providing a viewport).
        /// @return | integer | Number of polygons emitted to the render command queue.
        methods.add_method_mut("drawShapes", |_, this, args: LuaMultiValue| {
            let viewport = if args.is_empty() {
                None
            } else {
                let mut it = args.into_iter();
                let next_f32 = |v: Option<LuaValue>| -> Result<f32, LuaError> {
                    match v {
                        Some(LuaValue::Integer(n)) => Ok(n as f32),
                        Some(LuaValue::Number(n)) => Ok(n as f32),
                        Some(other) => Err(LuaError::RuntimeError(format!(
                            "drawShapes expected numeric viewport argument, got {:?}",
                            other.type_name()
                        ))),
                        None => Err(LuaError::RuntimeError(
                            "drawShapes expected four viewport numbers".into(),
                        )),
                    }
                };
                let x = next_f32(it.next())?;
                let y = next_f32(it.next())?;
                let w = next_f32(it.next())?;
                let h = next_f32(it.next())?;
                if it.next().is_some() {
                    return Err(LuaError::RuntimeError(
                        "drawShapes accepts either no args or four viewport numbers".into(),
                    ));
                }
                Some((x, y, w, h))
            };
            if this.shape_cache.is_none() {
                this.shape_cache = Some(this.inner.build_shape_cache());
            }
            let (view_x, view_y, view_w, view_h) = viewport.unwrap_or((
                f32::NEG_INFINITY,
                f32::NEG_INFINITY,
                f32::INFINITY,
                f32::INFINITY,
            ));
            let view_x2 = view_x + view_w;
            let view_y2 = view_y + view_h;
            let saved_color = this.state.borrow().current_color;
            let mut emitted = 0usize;
            {
                let mut st = this.state.borrow_mut();
                for entry in this.shape_cache.as_ref().unwrap() {
                    if entry.max_x < view_x
                        || entry.min_x > view_x2
                        || entry.max_y < view_y
                        || entry.min_y > view_y2
                    {
                        continue;
                    }
                    st.render_commands
                        .push(RenderCommand::SetColor(entry.r, entry.g, entry.b, 1.0));
                    st.render_commands.push(RenderCommand::Polygon {
                        mode: DrawMode::Fill,
                        vertices: entry.vertices.clone(),
                    });
                    emitted += 1;
                }
                st.render_commands.push(RenderCommand::SetColor(
                    saved_color[0],
                    saved_color[1],
                    saved_color[2],
                    saved_color[3],
                ));
                st.current_color = saved_color;
            }
            Ok(emitted as u32)
        });
        // -- type --
        /// Returns the Lua-visible type name for this province grid handle.
        /// @return | string | The string `LProvinceGrid`.
        methods.add_method("type", |_, _, ()| Ok("LProvinceGrid"));
        // -- typeOf --
        /// Returns whether this province grid handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LProvinceGrid` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LProvinceGrid" || name == "LObject")
        });
        // -- serializeShapeData --
        /// Serializes province span and border shape data into a binary Lua string.
        /// @return | string | Serialized shape data bytes.
        methods.add_method("serializeShapeData", |lua, this, ()| {
            let data = this.inner.serialize_shape_data();
            lua.create_string(&data)
        });
        // -- deserializeShapeData --
        /// Decodes serialized province shape data into span and segment tables.
        /// @param | bytes | string | Serialized shape data bytes.
        /// @return | LuaValue | Table with `spans` and `segments`, or nil when decoding fails.
        methods.add_method("deserializeShapeData", |lua, _, bytes: LuaString| {
            let data = bytes.as_bytes();
            if let Some((spans, segs)) = ProvinceGrid::deserialize_shape_data(data) {
                let result = lua.create_table()?;
                let spans_tbl = lua.create_table()?;
                for (i, (id, y, x0, x1)) in spans.into_iter().enumerate() {
                    let row = lua.create_table()?;
                    /// Performs the 'province_id' operation.
                    row.set("province_id", id)?;
                    /// The 'y' field value exposed to Lua scripts.
                    row.set("y", y)?;
                    /// The 'x0' field value exposed to Lua scripts.
                    row.set("x0", x0)?;
                    /// The 'x1' field value exposed to Lua scripts.
                    row.set("x1", x1)?;
                    spans_tbl.set(i + 1, row)?;
                }
                /// Performs the 'spans' operation.
                result.set("spans", spans_tbl)?;
                let segs_tbl = lua.create_table()?;
                for (i, (a, b, x0, y0, x1, y1)) in segs.into_iter().enumerate() {
                    let seg = lua.create_table()?;
                    /// Performs the 'province_a' operation.
                    seg.set("province_a", a)?;
                    /// Performs the 'province_b' operation.
                    seg.set("province_b", b)?;
                    /// The 'x0' field value exposed to Lua scripts.
                    seg.set("x0", x0)?;
                    /// The 'y0' field value exposed to Lua scripts.
                    seg.set("y0", y0)?;
                    /// The 'x1' field value exposed to Lua scripts.
                    seg.set("x1", x1)?;
                    /// The 'y1' field value exposed to Lua scripts.
                    seg.set("y1", y1)?;
                    segs_tbl.set(i + 1, seg)?;
                }
                /// Performs the 'segments' operation.
                result.set("segments", segs_tbl)?;
                Ok(LuaValue::Table(result))
            } else {
                Ok(LuaValue::Nil)
            }
        });
    }
}
/// Lua-side decoded animated image containing frame images and durations.
pub struct LuaAnimatedImage {
    /// Decoded RGBA frames.
    pub(crate) frames: Vec<ImageData>,
    /// Per-frame durations in milliseconds.
    pub(crate) durations_ms: Vec<u32>,
}
/// Provides Lua methods for decoded animated image inspection.
impl LuaUserData for LuaAnimatedImage {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- frameCount --
        /// Returns the number of decoded frames.
        /// @return | integer | Frame count.
        methods.add_method("frameCount", |_, this, ()| Ok(this.frames.len()));
        // -- getFrame --
        /// Returns a decoded frame by one-based index.
        /// @param | index | integer | One-based frame index.
        /// @return | LImageData | Decoded frame image.
        methods.add_method("getFrame", |lua, this, index: usize| {
            if index == 0 || index > this.frames.len() {
                return Err(LuaError::RuntimeError(format!(
                    "getFrame: frame {} out of range",
                    index
                )));
            }
            lua.create_userdata(this.frames[index - 1].clone())
        });
        // -- getDuration --
        /// Returns a frame duration in milliseconds by one-based index.
        /// @param | index | integer | One-based frame index.
        /// @return | integer | Duration in milliseconds.
        methods.add_method("getDuration", |_, this, index: usize| {
            if index == 0 || index > this.durations_ms.len() {
                return Err(LuaError::RuntimeError(format!(
                    "getDuration: frame {} out of range",
                    index
                )));
            }
            Ok(this.durations_ms[index - 1])
        });
        // -- getFrames --
        /// Returns all decoded frame images as an array.
        /// @return | table | Array of `LImageData` values.
        methods.add_method("getFrames", |lua, this, ()| {
            let out = lua.create_table()?;
            for (i, frame) in this.frames.iter().enumerate() {
                out.set(i + 1, lua.create_userdata(frame.clone())?)?;
            }
            Ok(out)
        });
        // -- getDurations --
        /// Returns all frame durations in milliseconds.
        /// @return | table | Array of integer durations.
        methods.add_method("getDurations", |lua, this, ()| {
            let out = lua.create_table()?;
            for (i, duration) in this.durations_ms.iter().enumerate() {
                out.set(i + 1, *duration)?;
            }
            Ok(out)
        });
        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | The string `LAnimatedImage`.
        methods.add_method("type", |_, _, ()| Ok("LAnimatedImage"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True when the supplied type name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAnimatedImage" || name == "LObject")
        });
    }
}
/// Lua-side handle for multiple image layers with visibility, opacity, and ordering.
pub struct LuaLayeredImage {
    /// Layer stack and per-layer metadata.
    inner: LayeredImage,
}
/// Provides Lua methods for editing and merging layered images.
impl LuaUserData for LuaLayeredImage {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns the layered image width. This method is available to Lua scripts.
        /// @return | integer | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.width()));
        // -- getHeight --
        /// Returns the layered image height. This method is available to Lua scripts.
        /// @return | integer | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.height()));
        // -- layerCount --
        /// Returns the number of layers in the stack.
        /// @return | integer | Layer count.
        methods.add_method("layerCount", |_, this, ()| Ok(this.inner.layer_count()));
        // -- addLayer --
        /// Adds a blank layer with an optional name.
        /// @param | name | string? | Optional layer name.
        /// @return | integer | One-based index of the new layer.
        methods.add_method_mut("addLayer", |_, this, name: Option<String>| {
            let label = name.unwrap_or_else(|| format!("Layer {}", this.inner.layer_count() + 1));
            let idx = this.inner.add_layer(label);
            Ok(idx + 1)
        });
        // -- removeLayer --
        /// Removes a layer by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @return | boolean | True when a layer was removed.
        methods.add_method_mut("removeLayer", |_, this, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            Ok(this.inner.remove_layer(index - 1).is_some())
        });
        // -- getLayer --
        /// Returns image data for a layer by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @return | LImageData | Layer image data handle.
        methods.add_method("getLayer", |lua, this, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            this.inner
                .get_layer(index - 1)
                .map(|l| lua.create_userdata(l.data.clone()))
                .ok_or_else(|| LuaError::RuntimeError(format!("layer {} does not exist", index)))?
        });
        // -- setLayer --
        /// Replaces a layer's image data by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @param | img | LImageData | Image data assigned to the layer.
        /// @return | boolean | True when the layer was replaced.
        methods.add_method_mut(
            "setLayer",
            |_, this, (index, img): (usize, LuaAnyUserData)| {
                if index == 0 {
                    return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
                }
                let src = img
                    .borrow::<ImageData>()
                    .map_err(|_| LuaError::RuntimeError("argument must be an ImageData".into()))?;
                Ok(this.inner.set_layer_image(index - 1, &src))
            },
        );
        // -- getOpacity --
        /// Returns a layer opacity by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @return | number | Layer opacity.
        methods.add_method("getOpacity", |_, this, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            this.inner
                .get_layer(index - 1)
                .map(|l| l.opacity)
                .ok_or_else(|| LuaError::RuntimeError(format!("layer {} does not exist", index)))
        });
        // -- setOpacity --
        /// Sets a layer opacity by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @param | opacity | number | New layer opacity.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut("setOpacity", |_, this, (index, opacity): (usize, f32)| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            Ok(this.inner.set_opacity(index - 1, opacity))
        });
        // -- isVisible --
        /// Returns layer visibility by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @return | boolean | True when the layer is visible.
        methods.add_method("isVisible", |_, this, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            this.inner
                .get_layer(index - 1)
                .map(|l| l.visible)
                .ok_or_else(|| LuaError::RuntimeError(format!("layer {} does not exist", index)))
        });
        // -- setVisible --
        /// Sets layer visibility by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @param | visible | boolean | New visibility flag.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut("setVisible", |_, this, (index, visible): (usize, bool)| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            Ok(this.inner.set_visible(index - 1, visible))
        });
        // -- getName --
        /// Returns a layer name by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @return | string | Layer name.
        methods.add_method("getName", |_, this, index: usize| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            this.inner
                .get_layer(index - 1)
                .map(|l| l.name.clone())
                .ok_or_else(|| LuaError::RuntimeError(format!("layer {} does not exist", index)))
        });
        // -- setName --
        /// Sets a layer name by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @param | name | string | New layer name.
        /// @return | boolean | True when the layer exists.
        methods.add_method_mut("setName", |_, this, (index, name): (usize, String)| {
            if index == 0 {
                return Err(LuaError::RuntimeError("layer index must be >= 1".into()));
            }
            Ok(this.inner.set_name(index - 1, name))
        });
        // -- swapLayers --
        /// Swaps two layers by one-based indices.
        /// @param | a | integer | First one-based layer index.
        /// @param | b | integer | Second one-based layer index.
        /// @return | boolean | True when both layers exist.
        methods.add_method_mut("swapLayers", |_, this, (a, b): (usize, usize)| {
            if a == 0 || b == 0 {
                return Err(LuaError::RuntimeError("layer indices must be >= 1".into()));
            }
            Ok(this.inner.swap_layers(a - 1, b - 1))
        });
        // -- moveLayer --
        /// Moves a layer from one one-based index to another.
        /// @param | from_idx | integer | Source one-based layer index.
        /// @param | to_idx | integer | Destination one-based layer index.
        /// @return | boolean | True when the move succeeds.
        methods.add_method_mut(
            "moveLayer",
            |_, this, (from_idx, to_idx): (usize, usize)| {
                if from_idx == 0 || to_idx == 0 {
                    return Err(LuaError::RuntimeError("layer indices must be >= 1".into()));
                }
                Ok(this.inner.move_layer(from_idx - 1, to_idx - 1))
            },
        );
        // -- merge --
        /// Merges visible layers into a single image data object.
        /// @return | LImageData | Merged image data handle.
        methods.add_method("merge", |lua, this, ()| {
            lua.create_userdata(this.inner.merge())
        });
        // -- save --
        /// Saves the layered image stack to a file.
        /// @param | path | string | Output path.
        methods.add_method("save", |_, this, path: String| {
            serial::save_layered(&this.inner, &path).map_err(LuaError::external)
        });
        // -- type --
        /// Returns the Lua-visible type name for this layered image handle.
        /// @return | string | The string `LLayeredImage`.
        methods.add_method("type", |_, _, ()| Ok("LLayeredImage"));
        // -- typeOf --
        /// Returns whether this layered image handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LLayeredImage` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLayeredImage" || name == "LObject")
        });
    }
}
/// Lua-side handle for legacy compressed DDS metadata.
pub struct LuaCompressedImageData {
    /// Compressed image dimensions, format, mipmaps, and byte data.
    inner: CompressedImageData,
}
/// Provides Lua methods for compressed image metadata.
impl LuaUserData for LuaCompressedImageData {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns compressed image width. This method is available to Lua scripts.
        /// @return | integer | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.width));
        // -- getHeight --
        /// Returns compressed image height. This method is available to Lua scripts.
        /// @return | integer | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.height));
        // -- getDimensions --
        /// Returns compressed image dimensions.
        /// @return | integer | Width in pixels.
        /// @return | integer | Height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.inner.get_dimensions())
        });
        // -- getMipmapCount --
        /// Returns the number of mipmap levels in this compressed image.
        /// @return | integer | Mipmap level count.
        methods.add_method("getMipmapCount", |_, this, ()| {
            Ok(this.inner.get_mipmap_count())
        });
        // -- getFormat --
        /// Returns the compressed image format name.
        /// @return | string | Format name.
        methods.add_method("getFormat", |_, this, ()| {
            Ok(this.inner.get_format().to_string())
        });
        // -- type --
        /// Returns the Lua-visible type name for this compressed image handle.
        /// @return | string | The string `LCompressedImageData`.
        methods.add_method("type", |_, _, ()| Ok("LCompressedImageData"));
        // -- typeOf --
        /// Returns whether this compressed image handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LCompressedImageData` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCompressedImageData" || name == "LObject")
        });
    }
}
/// Registers `lurek.image` image creation, load/save, province grid, palette, and capture helpers.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let s = state.clone();
    // -- newImageData --
    /// Creates empty image data from dimensions or decodes image data from a GameFS filename.
    /// @param | width_or_filename | integer|string | Width in pixels for a blank canvas, or a GameFS filename string to load from disk.
    /// @param | height | integer? | Height in pixels; required when the first argument is a width integer. Omit when loading from filename.
    /// @return | LImageData | New image data handle.
    tbl.set(
        "newImageData",
        lua.create_function(move |lua, args: LuaMultiValue| {
            let mut iter = args.into_iter();
            let first = iter.next().ok_or_else(|| {
                LuaError::RuntimeError("newImageData expects (width, height) or (filename)".into())
            })?;
            let img = if let LuaValue::String(ref filename) = first {
                let name = filename
                    .to_str()
                    .map_err(|e| LuaError::RuntimeError(e.to_string()))?;
                let bytes = s.borrow().fs.read_bytes(name).map_err(LuaError::external)?;
                ImageData::from_encoded_bytes(&bytes, name).map_err(LuaError::RuntimeError)?
            } else {
                let width = parse_lua_u32(first, "newImageData", "width")?;
                let height = parse_lua_u32(
                    iter.next().ok_or_else(|| {
                        LuaError::RuntimeError("newImageData: missing height".into())
                    })?,
                    "newImageData",
                    "height",
                )?;
                validate_image_dimensions("newImageData", width, height)?;
                ImageData::try_new(width, height).map_err(LuaError::RuntimeError)?
            };
            lua.create_userdata(img)
        })?,
    )?;
    let s = state.clone();
    // -- requestShader --
    /// Starts an offline image shader request and returns a completed job handle.
    ///
    /// The current implementation executes synchronously through the
    /// render-owned headless GPU image shader executor, then stores the
    /// readback result in the job handle.
    /// @param | image | LImageData | Source image data.
    /// @param | shader | LShader | Image-target shader.
    /// @param | opts | table? | Optional job options.
    /// @return | LImageShaderJob | Offline shader job handle.
    tbl.set(
        "requestShader",
        lua.create_function(
            move |lua, (image, shader, _opts): (LuaAnyUserData, LuaAnyUserData, Option<LuaTable>)| {
                let key = shader_key_from_userdata(&shader)?;
                let shader = {
                    let st = s.borrow();
                    ensure_shader_target(&st, key, ShaderTarget::Image, "lurek.image.requestShader")?;
                    st.shaders
                        .get(key)
                        .cloned()
                        .ok_or_else(|| LuaError::RuntimeError("lurek.image.requestShader: shader handle is released".into()))?
                };
                let image = image.borrow::<ImageData>()?.clone();
                let result = apply_image_shader_blocking(&image, &shader)
                    .map_err(|err| LuaError::RuntimeError(format!("lurek.image.requestShader: {err}")))?;
                lua.create_userdata(LuaImageShaderJob {
                    result: Some(result),
                    cancelled: false,
                    done: true,
                })
            },
        )?,
    )?;
    // -- newImageDataFromBytes --
    /// Creates image data from raw RGBA bytes and explicit dimensions.
    /// @param | w | integer | Width in pixels.
    /// @param | h | integer | Height in pixels.
    /// @param | bytes | string | Raw RGBA byte string.
    /// @return | LImageData | New image data handle.
    tbl.set(
        "newImageDataFromBytes",
        lua.create_function(move |lua, (w, h, bytes): (u32, u32, LuaString)| {
            let raw = bytes.as_bytes().to_vec();
            let img = ImageData::from_bytes(w, h, raw).map_err(LuaError::RuntimeError)?;
            lua.create_userdata(img)
        })?,
    )?;
    let s = state.clone();
    // -- newCompressedData --
    /// Attempts to load DDS compressed image data from GameFS.
    ///
    /// This runtime build intentionally rejects DDS payloads with an error and
    /// expects game textures to be loaded as PNG through `newImageData`.
    /// @param | filename | string | GameFS path to a DDS file.
    /// @return | LCompressedImageData | New compressed image data handle when DDS support is enabled.
    tbl.set(
        "newCompressedData",
        lua.create_function(move |lua, filename: String| {
            let bytes = s
                .borrow()
                .fs
                .read_bytes(&filename)
                .map_err(LuaError::external)?;
            let cid = CompressedImageData::from_dds(&bytes).map_err(LuaError::external)?;
            lua.create_userdata(LuaCompressedImageData { inner: cid })
        })?,
    )?;
    let s = state.clone();
    // -- isCompressed --
    /// Returns whether a GameFS image file begins with DDS compressed image magic bytes.
    ///
    /// Detection is available even though `newCompressedData` rejects DDS in
    /// this PNG-only runtime build.
    /// @param | filename | string | GameFS path to inspect.
    /// @return | boolean | True when the file appears to be DDS compressed data.
    tbl.set(
        "isCompressed",
        lua.create_function(move |_, filename: String| {
            let bytes = match s.borrow().fs.read_bytes(&filename) {
                Ok(bytes) => bytes,
                Err(_) => return Ok(false),
            };
            Ok(CompressedImageData::is_dds_magic(&bytes))
        })?,
    )?;
    // -- newLayeredImage --
    /// Creates a layered image stack with one or more blank layers.
    /// @param | width | integer | Width in pixels.
    /// @param | height | integer | Height in pixels.
    /// @return | LLayeredImage | New layered image handle.
    tbl.set(
        "newLayeredImage",
        lua.create_function(move |lua, (width, height): (LuaValue, LuaValue)| {
            let width = parse_lua_u32(width, "newLayeredImage", "width")?;
            let height = parse_lua_u32(height, "newLayeredImage", "height")?;
            validate_image_dimensions("newLayeredImage", width, height)?;
            lua.create_userdata(LuaLayeredImage {
                inner: LayeredImage::new(width, height),
            })
        })?,
    )?;
    let s = state.clone();
    // -- saveImage --
    /// Saves an image data object to a path under the current game directory.
    /// @param | img_ud | LImageData | Image data handle to save.
    /// @param | filename | string | Output filename relative to game directory.
    tbl.set(
        "saveImage",
        lua.create_function(move |_, (img_ud, filename): (LuaAnyUserData, String)| {
            let path = s.borrow().game_dir.join(&filename);
            let path_str = path
                .to_str()
                .ok_or_else(|| LuaError::RuntimeError("Invalid path".into()))?;
            let img = img_ud
                .borrow::<ImageData>()
                .map_err(|_| LuaError::RuntimeError("argument must be an ImageData".into()))?;
            serial::save_image(&img, path_str).map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    // -- savePNG --
    /// Encodes image data as PNG and writes it under the current game directory.
    /// @param | img_ud | LImageData | Image data handle to encode.
    /// @param | filename | string | Output filename relative to game directory.
    tbl.set(
        "savePNG",
        lua.create_function(move |_, (img_ud, filename): (LuaAnyUserData, String)| {
            let path = s.borrow().game_dir.join(&filename);
            let raw = img_ud
                .borrow::<ImageData>()
                .map_err(|_| LuaError::RuntimeError("argument must be an ImageData".into()))?;
            let bytes = raw.encode_png().map_err(LuaError::RuntimeError)?;
            if let Some(parent) = path.parent() {
                std::fs::create_dir_all(parent).map_err(LuaError::external)?;
            }
            std::fs::write(&path, &bytes).map_err(LuaError::external)
        })?,
    )?;
    let s = state.clone();
    // -- saveGIF --
    /// Encodes a sequence of equally sized image frames as an animated GIF.
    /// @param | frames | table | Array of `LImageData` frames in playback order.
    /// @param | filename | string | Output filename relative to the current game directory.
    /// @param | opts | table? | Optional GIF settings such as `delayMs`, `speed`, `loop`, or `loopCount`.
    tbl.set(
        "saveGIF",
        lua.create_function(
            move |_, (frames, filename, opts): (LuaTable, String, Option<LuaTable>)| {
                let options = parse_save_gif_options(opts)?;
                let mut collected = Vec::new();
                for frame_ud in frames.sequence_values::<LuaAnyUserData>() {
                    let frame_ud = frame_ud?;
                    let frame = frame_ud.borrow::<ImageData>().map_err(|_| {
                        LuaError::RuntimeError(
                            "saveGIF: frames must contain only LImageData values".into(),
                        )
                    })?;
                    collected.push(frame.clone());
                }

                let path = s.borrow().game_dir.join(&filename);
                crate::image::animated_gif::save_gif(&collected, &path, options)
                    .map_err(LuaError::RuntimeError)
            },
        )?,
    )?;
    let s = state.clone();
    // -- loadImage --
    /// Loads and decodes image data from GameFS.
    /// @param | filename | string | GameFS path to an encoded image.
    /// @return | LImageData | Loaded image data handle.
    tbl.set(
        "loadImage",
        lua.create_function(move |lua, filename: String| {
            let bytes = s
                .borrow()
                .fs
                .read_bytes(&filename)
                .map_err(LuaError::external)?;
            let img =
                serial::load_image_from_bytes(&bytes, &filename).map_err(LuaError::external)?;
            lua.create_userdata(img)
        })?,
    )?;
    let s = state.clone();
    // -- loadAnimated --
    /// Loads an animated GIF from GameFS path or decodes animated GIF bytes.
    /// @param | source | string | GameFS path or raw GIF bytes.
    /// @return | LAnimatedImage | Decoded frames and durations.
    tbl.set(
        "loadAnimated",
        lua.create_function(move |lua, source: LuaString| {
            let label = source.to_str().unwrap_or("<bytes>");
            let bytes = if let Ok(path) = source.to_str() {
                s.borrow()
                    .fs
                    .read_bytes(path)
                    .unwrap_or_else(|_| source.as_bytes().to_vec())
            } else {
                source.as_bytes().to_vec()
            };
            let decoded = crate::image::animated_gif::decode_gif(&bytes, label)
                .map_err(LuaError::external)?;
            let mut frames = Vec::with_capacity(decoded.len());
            let mut durations_ms = Vec::with_capacity(decoded.len());
            for frame in decoded {
                frames.push(frame.image);
                durations_ms.push(frame.duration_ms);
            }
            lua.create_userdata(LuaAnimatedImage {
                frames,
                durations_ms,
            })
        })?,
    )?;
    let s = state.clone();
    // -- loadLayered --
    /// Loads a serialized layered image stack from GameFS.
    /// @param | filename | string | GameFS path to the layered image file.
    /// @return | LLayeredImage | Loaded layered image handle.
    tbl.set(
        "loadLayered",
        lua.create_function(move |lua, filename: String| {
            let bytes = s
                .borrow()
                .fs
                .read_bytes(&filename)
                .map_err(LuaError::external)?;
            let stack =
                serial::load_layered_from_bytes(&bytes, &filename).map_err(LuaError::external)?;
            lua.create_userdata(LuaLayeredImage { inner: stack })
        })?,
    )?;
    // -- newPaletteLut --
    /// Creates an empty palette lookup table.
    /// @return | LPaletteLUT | New palette lookup table handle.
    tbl.set(
        "newPaletteLut",
        lua.create_function(|lua, ()| {
            lua.create_userdata(LuaPaletteLUT {
                inner: crate::image::palette_lut::PaletteLUT::new(),
            })
        })?,
    )?;
    let s = state.clone();
    // -- newProvinceGrid --
    /// Loads a province id grid from an image file under the current game directory. This is a compatibility facade over the province subsystem.
    /// @param | filename | string | Province map image filename relative to game directory.
    /// @return | LProvinceGrid | New province grid handle.
    tbl.set(
        "newProvinceGrid",
        lua.create_function(move |lua, filename: String| {
            let path = s.borrow().game_dir.join(&filename);
            let path_str = path
                .to_str()
                .ok_or_else(|| LuaError::RuntimeError("Invalid path".into()))?;
            let grid = ProvinceGrid::from_file(path_str).map_err(LuaError::RuntimeError)?;
            lua.create_userdata(LuaProvinceGrid {
                inner: grid,
                state: s.clone(),
                shape_cache: None,
            })
        })?,
    )?;
    let s = state.clone();
    // -- fromScreen --
    /// Returns a completed screen capture image or requests one for a future call.
    /// @return | LImageData|nil | `LImageData` when capture data is ready, or nil after requesting capture.
    tbl.set(
        "fromScreen",
        lua.create_function(move |lua, ()| {
            let mut st = s.borrow_mut();
            if let Some(img) = st.captured_screen_image.take() {
                Ok(LuaValue::UserData(lua.create_userdata(img)?))
            } else {
                st.pending_screen_capture = true;
                Ok(LuaValue::Nil)
            }
        })?,
    )?;
    /// Performs the 'image' operation.
    lurek.set("image", tbl)?;
    Ok(())
}
/// Provides Lua methods for reading, editing, filtering, drawing, and encoding image data.
impl mlua::UserData for ImageData {
    fn add_methods<'lua, M: mlua::UserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns image width. This method is available to Lua scripts.
        /// @return | integer | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.width()));
        // -- getHeight --
        /// Returns image height. This method is available to Lua scripts.
        /// @return | integer | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.height()));
        // -- getDimensions --
        /// Returns image dimensions. This method is available to Lua scripts.
        /// @return | integer | Width in pixels.
        /// @return | integer | Height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            let (w, h) = this.dimensions();
            Ok((w, h))
        });
        // -- clone --
        /// Returns a deep copy of this image data.
        /// @return | LImageData | Copied image data.
        methods.add_method("clone", |lua, this, ()| lua.create_userdata(this.clone()));
        // -- copyRegion --
        /// Copies a rectangular region into a new image.
        /// @param | x | integer | Source x coordinate.
        /// @param | y | integer | Source y coordinate.
        /// @param | w | integer | Region width.
        /// @param | h | integer | Region height.
        /// @return | LImageData | Copied region.
        methods.add_method(
            "copyRegion",
            |lua, this, (x, y, w, h): (u32, u32, u32, u32)| {
                let region = this.get_region(x, y, w, h).ok_or_else(|| {
                    LuaError::RuntimeError("copyRegion: region is empty or out of bounds".into())
                })?;
                lua.create_userdata(region)
            },
        );
        // -- applyEffect --
        /// Applies a named image effect in place, or returns a new image when the effect changes size.
        /// @param | name | string | Effect name.
        /// @param | opts | table? | Effect options such as `factor`, `amount`, `radius`, `levels`, `region`, or `color`.
        /// @return | LImageData|nil | New image for size-changing effects, otherwise nil.
        methods.add_method_mut(
            "applyEffect",
            |lua, this, (name, opts): (String, Option<LuaTable>)| {
                let effect_opts = parse_effect_options(opts.clone(), "applyEffect")?;
                if let Some((x, y, w, h)) = parse_region(opts.as_ref())? {
                    let mut region = this.get_region(x, y, w, h).ok_or_else(|| {
                        LuaError::RuntimeError(
                            "applyEffect: region is empty or out of bounds".into(),
                        )
                    })?;
                    let result = region
                        .apply_effect_named(&name, &effect_opts)
                        .map_err(LuaError::RuntimeError)?;
                    if let Some(new_image) = result {
                        return Ok(LuaValue::UserData(lua.create_userdata(new_image)?));
                    }
                    this.blit(&region, x as i32, y as i32);
                    return Ok(LuaValue::Nil);
                }
                let result = this
                    .apply_effect_named(&name, &effect_opts)
                    .map_err(LuaError::RuntimeError)?;
                match result {
                    Some(image) => Ok(LuaValue::UserData(lua.create_userdata(image)?)),
                    None => Ok(LuaValue::Nil),
                }
            },
        );
        // -- applyEffects --
        /// Applies a sequence of named effects in order.
        /// @param | effects | table | Array of effect names or `{name=..., opts=...}` tables.
        /// @param | opts | table? | Default options used by string entries.
        /// @return | LImageData|nil | Last new image returned by a size-changing effect, otherwise nil.
        methods.add_method_mut(
            "applyEffects",
            |_lua, this, (effects, default_opts): (LuaTable, Option<LuaTable>)| {
                for value in effects.sequence_values::<LuaValue>() {
                    let result = match value? {
                        LuaValue::String(name) => {
                            let name = name.to_str()?.to_string();
                            let opts = parse_effect_options(default_opts.clone(), "applyEffects")?;
                            this.apply_effect_named(&name, &opts)
                                .map_err(LuaError::RuntimeError)?
                        }
                        LuaValue::Table(entry) => {
                            let name: String = entry
                                .get::<_, Option<String>>("name")?
                                .or_else(|| entry.get::<_, Option<String>>(1).ok().flatten())
                                .ok_or_else(|| {
                                    LuaError::RuntimeError(
                                        "applyEffects: effect table missing name".into(),
                                    )
                                })?;
                            let opts_table = entry
                                .get::<_, Option<LuaTable>>("opts")?
                                .or_else(|| default_opts.clone());
                            let opts = parse_effect_options(opts_table, "applyEffects")?;
                            this.apply_effect_named(&name, &opts)
                                .map_err(LuaError::RuntimeError)?
                        }
                        other => {
                            return Err(LuaError::RuntimeError(format!(
                                "applyEffects: unsupported entry type {}",
                                other.type_name()
                            )));
                        }
                    };
                    if let Some(image) = result {
                        *this = image;
                    }
                }
                Ok(LuaValue::Nil)
            },
        );
        // -- applyShader --
        /// Applies an offline image shader and returns the processed image.
        ///
        /// This validates the image-target shader, runs a render-owned
        /// headless fullscreen GPU pass, and returns the readback image.
        /// @param | shader | LShader | Image-target shader.
        /// @param | opts | table? | Optional processing options.
        /// @return | LImageData | Processed image.
        methods.add_method(
            "applyShader",
            |lua, this, (shader, _opts): (LuaAnyUserData, Option<LuaTable>)| {
                let state = lua
                    .app_data_ref::<Rc<RefCell<SharedState>>>()
                    .ok_or_else(|| {
                        LuaError::RuntimeError(
                            "ImageData:applyShader: runtime state is unavailable".into(),
                        )
                    })?;
                let key = shader_key_from_userdata(&shader)?;
                let shader = {
                    let st = state.borrow();
                    ensure_shader_target(&st, key, ShaderTarget::Image, "ImageData:applyShader")?;
                    st.shaders.get(key).cloned().ok_or_else(|| {
                        LuaError::RuntimeError(
                            "ImageData:applyShader: shader handle is released".into(),
                        )
                    })?
                };
                let out = apply_image_shader_blocking(this, &shader).map_err(|err| {
                    LuaError::RuntimeError(format!("ImageData:applyShader: {err}"))
                })?;
                lua.create_userdata(out)
            },
        );
        // -- applyMask --
        /// Multiplies this image alpha by another image's alpha channel.
        /// @param | mask | LImageData | Same-sized alpha mask image.
        methods.add_method_mut("applyMask", |_, this, mask: LuaAnyUserData| {
            let mask = mask.borrow::<ImageData>()?;
            this.apply_mask_image(&mask).map_err(LuaError::RuntimeError)
        });
        // -- transform --
        /// Returns a transformed image, currently supporting high-quality resize through `width`, `height`, and `filter`.
        /// @param | opts | table | Transform options.
        /// @return | LImageData | Transformed image.
        methods.add_method("transform", |lua, this, opts: Option<LuaTable>| {
            let options = parse_effect_options(opts, "transform")?;
            let out = this
                .transform_image(&options)
                .map_err(LuaError::RuntimeError)?;
            lua.create_userdata(out)
        });
        // -- getPixel --
        /// Returns RGBA channels at a pixel coordinate.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @return | integer | Red channel.
        /// @return | integer | Green channel.
        /// @return | integer | Blue channel.
        /// @return | integer | Alpha channel.
        methods.add_method("getPixel", |_, this, (x, y): (u32, u32)| {
            this.get_pixel(x, y).ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "Pixel ({}, {}) out of bounds ({}x{})",
                    x,
                    y,
                    this.width(),
                    this.height()
                ))
            })
        });
        // -- setPixel --
        /// Sets RGBA channels at a pixel coordinate.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @param | r | integer | Red channel.
        /// @param | g | integer | Green channel.
        /// @param | b | integer | Blue channel.
        /// @param | a | integer | Alpha channel.
        methods.add_method_mut(
            "setPixel",
            |_, this, (x, y, r, g, b, a): (u32, u32, u8, u8, u8, u8)| {
                if this.set_pixel(x, y, r, g, b, a) {
                    Ok(())
                } else {
                    Err(LuaError::RuntimeError(format!(
                        "Pixel ({}, {}) out of bounds ({}x{})",
                        x,
                        y,
                        this.width(),
                        this.height()
                    )))
                }
            },
        );
        // -- encode --
        /// Encodes image data in a supported format.
        /// @param | format | string | Format name; currently `png`.
        /// @return | string | Encoded image bytes.
        methods.add_method("encode", |_, this, format: String| match format.as_str() {
            "png" => this.encode_png().map_err(LuaError::RuntimeError),
            _ => Err(LuaError::RuntimeError(format!(
                "Unknown image format: '{}'. Use 'png'.",
                format
            ))),
        });
        // -- getString --
        /// Returns raw image bytes as a Lua string.
        /// @return | string | Raw image byte string.
        methods.add_method("getString", |_, this, ()| Ok(this.get_string()));
        // -- mapPixel --
        /// Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.
        /// @param | func | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels.
        methods.add_method_mut("mapPixel", |_, this, func: LuaFunction| {
            let w = this.width();
            let h = this.height();
            for y in 0..h {
                for x in 0..w {
                    if let Some((r, g, b, a)) = this.get_pixel(x, y) {
                        let result: (u8, u8, u8, u8) =
                            func.call((x, y, r, g, b, a)).map_err(|e| {
                                LuaError::RuntimeError(format!("mapPixel callback: {}", e))
                            })?;
                        this.set_pixel(x, y, result.0, result.1, result.2, result.3);
                    }
                }
            }
            Ok(())
        });
        // -- brightness --
        /// Applies a brightness factor to this image in place.
        /// @param | factor | number | Brightness multiplier or adjustment factor.
        methods.add_method_mut("brightness", |_, this, factor: f32| {
            this.brightness(factor);
            Ok(())
        });
        // -- contrast --
        /// Applies a contrast factor to this image in place.
        /// @param | factor | number | Contrast factor.
        methods.add_method_mut("contrast", |_, this, factor: f32| {
            this.contrast(factor);
            Ok(())
        });
        // -- saturation --
        /// Applies a saturation factor to this image in place.
        /// @param | factor | number | Saturation factor.
        methods.add_method_mut("saturation", |_, this, factor: f32| {
            this.saturation(factor);
            Ok(())
        });
        // -- gamma --
        /// Applies gamma correction to this image in place.
        /// @param | gamma | number | Gamma value.
        methods.add_method_mut("gamma", |_, this, gamma: f32| {
            this.gamma(gamma);
            Ok(())
        });
        // -- tint --
        /// Blends this image toward a tint color in place.
        /// @param | tr | integer | Tint red channel.
        /// @param | tg | integer | Tint green channel.
        /// @param | tb | integer | Tint blue channel.
        /// @param | factor | number | Tint blend factor.
        methods.add_method_mut(
            "tint",
            |_, this, (tr, tg, tb, factor): (u8, u8, u8, f32)| {
                this.tint(tr, tg, tb, factor);
                Ok(())
            },
        );
        // -- grayscale --
        /// Converts this image to grayscale in place.
        methods.add_method_mut("grayscale", |_, this, ()| {
            this.grayscale();
            Ok(())
        });
        // -- sepia --
        /// Applies a sepia filter to this image in place.
        methods.add_method_mut("sepia", |_, this, ()| {
            this.sepia();
            Ok(())
        });
        // -- invert --
        /// Inverts image color channels in place.
        methods.add_method_mut("invert", |_, this, ()| {
            this.invert();
            Ok(())
        });
        // -- threshold --
        /// Applies a threshold filter to this image in place.
        /// @param | value | integer | Threshold channel value.
        methods.add_method_mut("threshold", |_, this, value: u8| {
            this.threshold(value);
            Ok(())
        });
        // -- posterize --
        /// Reduces image colors to a fixed number of levels in place.
        /// @param | levels | integer | Number of posterization levels.
        methods.add_method_mut("posterize", |_, this, levels: u8| {
            this.posterize(levels);
            Ok(())
        });
        // -- fill --
        /// Fills the whole image with one RGBA color.
        /// @param | r | integer | Red channel.
        /// @param | g | integer | Green channel.
        /// @param | b | integer | Blue channel.
        /// @param | a | integer | Alpha channel.
        methods.add_method_mut("fill", |_, this, (r, g, b, a): (u8, u8, u8, u8)| {
            this.fill(r, g, b, a);
            Ok(())
        });
        // -- noise --
        /// Adds noise to this image in place. This method is available to Lua scripts.
        /// @param | amount | integer | Noise amount.
        methods.add_method_mut("noise", |_, this, amount: u8| {
            this.noise(amount);
            Ok(())
        });
        // -- alphaMask --
        /// Multiplies this image alpha channel by a factor in place.
        /// @param | factor | number | Alpha multiplier.
        methods.add_method_mut("alphaMask", |_, this, factor: f32| {
            this.alpha_mask(factor);
            Ok(())
        });
        // -- flipHorizontal --
        /// Flips this image horizontally in place.
        methods.add_method_mut("flipHorizontal", |_, this, ()| {
            this.flip_horizontal();
            Ok(())
        });
        // -- flipVertical --
        /// Flips this image vertically in place.
        methods.add_method_mut("flipVertical", |_, this, ()| {
            this.flip_vertical();
            Ok(())
        });
        // -- rotate90cw --
        /// Returns a new image rotated ninety degrees clockwise.
        /// @return | LImageData | Rotated image data handle.
        methods.add_method("rotate90cw", |lua, this, ()| {
            lua.create_userdata(this.rotate_90_cw())
        });
        // -- crop --
        /// Returns a cropped image region. This method is available to Lua scripts.
        /// @param | x | integer | Source x coordinate.
        /// @param | y | integer | Source y coordinate.
        /// @param | w | integer | Crop width.
        /// @param | h | integer | Crop height.
        /// @return | LImageData | Cropped image data handle.
        methods.add_method("crop", |lua, this, (x, y, w, h): (u32, u32, u32, u32)| {
            this.crop(x, y, w, h)
                .ok_or_else(|| {
                    LuaError::RuntimeError(format!(
                        "crop ({},{},{},{}) out of bounds ({}x{})",
                        x,
                        y,
                        w,
                        h,
                        this.width(),
                        this.height()
                    ))
                })
                .and_then(|img| lua.create_userdata(img))
        });
        // -- resizeNearest --
        /// Returns a resized image using nearest-neighbor sampling.
        /// @param | new_w | integer | Output width.
        /// @param | new_h | integer | Output height.
        /// @return | LImageData | Resized image data handle.
        methods.add_method("resizeNearest", |lua, this, (new_w, new_h): (u32, u32)| {
            lua.create_userdata(this.resize_nearest(new_w, new_h))
        });
        // -- blur --
        /// Returns a blurred copy of this image.
        /// @param | radius | integer | Blur radius.
        /// @return | LImageData | Blurred image data handle.
        methods.add_method("blur", |lua, this, radius: u32| {
            lua.create_userdata(this.blur(radius))
        });
        // -- sharpen --
        /// Returns a sharpened copy of this image.
        /// @return | LImageData | Sharpened image data handle.
        methods.add_method("sharpen", |lua, this, ()| {
            lua.create_userdata(this.sharpen())
        });
        // -- drawRect --
        /// Draws a filled rectangle into this image.
        /// @param | x | integer | Rectangle x coordinate.
        /// @param | y | integer | Rectangle y coordinate.
        /// @param | w | integer | Rectangle width.
        /// @param | h | integer | Rectangle height.
        /// @param | r | integer | Red channel.
        /// @param | g | integer | Green channel.
        /// @param | b | integer | Blue channel.
        /// @param | a | integer | Alpha channel.
        methods.add_method_mut(
            "drawRect",
            |_, this, (x, y, w, h, r, g, b, a): (i32, i32, u32, u32, u8, u8, u8, u8)| {
                this.draw_rect(x, y, w, h, r, g, b, a);
                Ok(())
            },
        );
        // -- drawCircle --
        /// Draws a filled circle into this image.
        /// @param | cx | integer | Circle center x coordinate.
        /// @param | cy | integer | Circle center y coordinate.
        /// @param | radius | integer | Circle radius.
        /// @param | r | integer | Red channel.
        /// @param | g | integer | Green channel.
        /// @param | b | integer | Blue channel.
        /// @param | a | integer | Alpha channel.
        methods.add_method_mut(
            "drawCircle",
            |_, this, (cx, cy, radius, r, g, b, a): (i32, i32, u32, u8, u8, u8, u8)| {
                this.draw_circle(cx, cy, radius, r, g, b, a);
                Ok(())
            },
        );
        // -- drawLine --
        /// Draws a line into this image. This method is available to Lua scripts.
        /// @param | x0 | integer | Start x coordinate.
        /// @param | y0 | integer | Start y coordinate.
        /// @param | x1 | integer | End x coordinate.
        /// @param | y1 | integer | End y coordinate.
        /// @param | r | integer | Red channel.
        /// @param | g | integer | Green channel.
        /// @param | b | integer | Blue channel.
        /// @param | a | integer | Alpha channel.
        methods.add_method_mut(
            "drawLine",
            |_, this, (x0, y0, x1, y1, r, g, b, a): (i32, i32, i32, i32, u8, u8, u8, u8)| {
                this.draw_line(x0, y0, x1, y1, r, g, b, a);
                Ok(())
            },
        );
        // -- resize --
        /// Returns a resized image using an optional named filter.
        /// @param | width | integer | Output width.
        /// @param | height | integer | Output height.
        /// @param | filter | string | Optional filter name, defaulting to `bilinear`.
        /// @return | LImageData|nil | Resized `LImageData` handle, or nil when resizing fails.
        methods.add_method("resize", |lua, this, args: LuaMultiValue| {
            let mut it = args.into_iter();
            let w = parse_lua_u32(
                it.next().ok_or_else(|| {
                    LuaError::RuntimeError("resize(width, height, [filter]): missing width".into())
                })?,
                "resize(width, height, [filter])",
                "width",
            )?;
            let h = parse_lua_u32(
                it.next().ok_or_else(|| {
                    LuaError::RuntimeError("resize(width, height, [filter]): missing height".into())
                })?,
                "resize(width, height, [filter])",
                "height",
            )?;
            validate_image_dimensions("resize(width, height, [filter])", w, h)?;
            let filter = match it.next() {
                Some(LuaValue::String(name)) => {
                    let name = name
                        .to_str()
                        .map_err(|e| LuaError::RuntimeError(e.to_string()))?;
                    crate::image::effects::ResizeFilter::parse(name).ok_or_else(|| {
                        LuaError::RuntimeError(format!(
                            "resize: invalid filter '{}', expected 'bilinear' or 'lanczos3'",
                            name
                        ))
                    })?
                }
                Some(_) => {
                    return Err(LuaError::RuntimeError(
                        "resize(width, height, [filter]): filter must be a string".into(),
                    ));
                }
                None => crate::image::effects::ResizeFilter::Bilinear,
            };
            match this.resize_with_filter(w, h, filter) {
                Some(img) => Ok(LuaValue::UserData(lua.create_userdata(img)?)),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- blit --
        /// Copies a source image into this image at a destination coordinate.
        /// @param | src_ud | LImageData | Source image data handle.
        /// @param | dst_x | integer | Destination x coordinate.
        /// @param | dst_y | integer | Destination y coordinate.
        methods.add_method_mut(
            "blit",
            |_, this, (src_ud, dst_x, dst_y): (LuaAnyUserData, i32, i32)| {
                let src_ref = src_ud.borrow::<ImageData>()?;
                this.blit(&src_ref, dst_x, dst_y);
                Ok(())
            },
        );
        // -- getRegion --
        /// Returns an image region when the requested rectangle is inside bounds.
        /// @param | x | integer | Region x coordinate.
        /// @param | y | integer | Region y coordinate.
        /// @param | w | integer | Region width.
        /// @param | h | integer | Region height.
        /// @return | LImageData|nil | `LImageData` handle, or nil when the region is out of bounds.
        methods.add_method(
            "getRegion",
            |lua, this, (x, y, w, h): (u32, u32, u32, u32)| match this.get_region(x, y, w, h) {
                Some(img) => Ok(LuaValue::UserData(lua.create_userdata(img)?)),
                None => Ok(LuaValue::Nil),
            },
        );
        // -- getRawBytes --
        /// Returns raw image bytes as a Lua string.
        /// @return | string | Raw image byte string.
        methods.add_method("getRawBytes", |lua, this, ()| {
            lua.create_string(this.as_bytes())
        });
        // -- diff --
        /// Computes a difference metric against another image.
        /// @param | other_ud | LImageData | Image data handle to compare with this image.
        /// @return | number | Difference score.
        methods.add_method("diff", |_, this, other_ud: LuaAnyUserData| {
            let other_ref = other_ud.borrow::<ImageData>()?;
            Ok(this.diff(&other_ref))
        });
        // -- mapPixels --
        /// Applies a Lua callback to every pixel and replaces each pixel with returned RGBA values.
        /// @param | func | function | Callback receiving `(x, y, r, g, b, a)` and returning replacement channels.
        methods.add_method_mut("mapPixels", |_, this, func: LuaFunction| {
            let w = this.width();
            let h = this.height();
            for y in 0..h {
                for x in 0..w {
                    if let Some((r, g, b, a)) = this.get_pixel(x, y) {
                        let result: (u8, u8, u8, u8) = func.call((x, y, r, g, b, a))?;
                        this.set_pixel(x, y, result.0, result.1, result.2, result.3);
                    }
                }
            }
            Ok(())
        });
        // -- convolve --
        /// Applies a convolution kernel and returns the filtered image.
        /// @param | kernel_t | table | Array table of numeric kernel weights.
        /// @param | ksize | integer | Kernel width and height.
        /// @return | LImageData | Convolved image data handle.
        methods.add_method(
            "convolve",
            |lua, this, (kernel_t, ksize): (LuaTable, usize)| {
                let len = usize::try_from(kernel_t.len()?).map_err(|_| {
                    LuaError::RuntimeError("convolve: kernel length exceeds supported size".into())
                })?;
                let mut kernel: Vec<f64> = Vec::with_capacity(len);
                for i in 1..=len {
                    kernel.push(kernel_t.get::<_, f64>(i)?);
                }
                let result = this.convolve(&kernel, ksize).map_err(LuaError::external)?;
                lua.create_userdata(result)
            },
        );
        // -- applyPaletteLut --
        /// Applies a palette lookup table to this image in place.
        /// @param | lut_ud | LPaletteLUT | Palette lookup table handle.
        methods.add_method_mut("applyPaletteLut", |_, this, lut_ud: LuaAnyUserData| {
            let lut = lut_ud.borrow::<LuaPaletteLUT>()?;
            lut.inner.apply(this);
            Ok(())
        });
        // -- setRawData --
        /// Replaces the image byte buffer with raw bytes.
        /// @param | bytes | string | Raw byte string matching the image storage size.
        methods.add_method_mut("setRawData", |_, this, bytes: LuaString| {
            this.set_raw_data(bytes.as_bytes())
                .map_err(LuaError::RuntimeError)
        });
        // -- paste --
        /// Pastes a source image into this image at unsigned destination coordinates.
        /// @param | src_ud | LImageData | Source image data handle.
        /// @param | dx | integer | Destination x coordinate.
        /// @param | dy | integer | Destination y coordinate.
        methods.add_method_mut(
            "paste",
            |_, this, (src_ud, dx, dy): (LuaAnyUserData, u32, u32)| {
                let src = src_ud.borrow::<ImageData>()?;
                this.paste(&src, dx, dy);
                Ok(())
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this image data handle.
        /// @return | string | The string `LImageData`.
        methods.add_method("type", |_, _, ()| Ok("LImageData"));
        // -- typeOf --
        /// Returns whether this image data handle matches the `LImageData` type name.
        /// @param | name | string | Type name to compare against `LImageData` or `Object`.
        /// @return | boolean | True when the supplied type name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LImageData" || name == "LObject")
        });
    }
}
/// Lua-side handle for palette color remapping.
pub struct LuaPaletteLUT {
    /// Palette lookup table mapping source colors to destination colors.
    inner: crate::image::palette_lut::PaletteLUT,
}
/// Provides Lua methods for editing and applying palette lookup tables.
impl LuaUserData for LuaPaletteLUT {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setColor --
        /// Adds a color mapping from source RGBA channels to destination RGBA channels.
        /// @param | fr | integer | Source red channel.
        /// @param | fg | integer | Source green channel.
        /// @param | fb | integer | Source blue channel.
        /// @param | fa | integer | Source alpha channel.
        /// @param | tr | integer | Destination red channel.
        /// @param | tg | integer | Destination green channel.
        /// @param | tb | integer | Destination blue channel.
        /// @param | ta | integer | Destination alpha channel.
        methods.add_method_mut(
            "setColor",
            |_, this, (fr, fg, fb, fa, tr, tg, tb, ta): (u8, u8, u8, u8, u8, u8, u8, u8)| {
                use crate::color::Color;
                let from = Color {
                    r: fr as f32 / 255.0,
                    g: fg as f32 / 255.0,
                    b: fb as f32 / 255.0,
                    a: fa as f32 / 255.0,
                };
                let to = Color {
                    r: tr as f32 / 255.0,
                    g: tg as f32 / 255.0,
                    b: tb as f32 / 255.0,
                    a: ta as f32 / 255.0,
                };
                let next_idx = this.inner.get_color_count();
                this.inner.set_color(next_idx, from, to);
                Ok(())
            },
        );
        // -- getColorCount --
        /// Returns the number of color mappings in this palette lookup table.
        /// @return | integer | Color mapping count.
        methods.add_method("getColorCount", |_, this, ()| {
            Ok(this.inner.get_color_count())
        });
        // -- clear --
        /// Removes every color mapping from this palette lookup table.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- cycle --
        /// Cycles palette mappings by an offset.
        /// @param | offset | integer | Mapping offset.
        methods.add_method_mut("cycle", |_, this, offset: i32| {
            this.inner.cycle_to_colors(offset);
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this palette lookup table handle.
        /// @return | string | The string `LPaletteLUT`.
        methods.add_method("type", |_, _, ()| Ok("LPaletteLUT"));
        // -- typeOf --
        /// Returns whether this palette lookup table handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LPaletteLUT` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPaletteLUT" || name == "LObject")
        });
    }
}
