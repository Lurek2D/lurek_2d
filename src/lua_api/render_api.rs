//! Registers the `lurek.render` Lua API for render commands, sprites, fonts, shapes, and queued draw helpers.

use super::effect_api::{LuaPostFxEffect, LuaPostFxStack};
use super::scene_api::LuaDepthSorter;
use super::SharedState;
use crate::font::Font;
use crate::image::ImageData;
use crate::image::Texture;
use crate::image::TextureColorSpace;
use crate::math::Rect;
use crate::render::draw_layer::allocate_callback_id;
use crate::render::renderer::{
    BevelStyle, GradientDirection, HexOrientation, PathSegment, PostFxPass,
};
use crate::render::shape::{
    role_index, CompoundShape, FillRule, ShapeCommand, StrokeCap, StrokeJoin, StrokeStyle,
};
use crate::render::{
    BlendMode, Canvas, CompareMode, DepthMode, DrawMode, Mesh, MeshDrawMode, MeshVertex,
    RenderCommand, Shader, ShaderTarget, ShapeInstance, StencilAction, StencilMode, TextAlign,
    UniformValue,
};
use crate::runtime::resource_keys::*;
use crate::runtime::{
    ScreenshotRequest, ShaderPrewarmRequest, ShaderPrewarmRequestState, SurfaceReadbackRequest,
    SurfaceReadbackRequestState,
};
use crate::sprite::sprite_batch::BatchEntry;
use crate::sprite::SpriteBatch;
use mlua::prelude::*;
use slotmap::Key;
use std::cell::RefCell;
use std::path::Path;
use std::rc::Rc;
use std::str::FromStr;

#[path = "render_canvas_api.rs"]
mod render_canvas_api;
#[path = "render_diagnostics_api.rs"]
mod render_diagnostics_api;
#[path = "render_mesh_api.rs"]
mod render_mesh_api;
#[path = "render_primitive_api.rs"]
mod render_primitive_api;
#[path = "render_resources_api.rs"]
mod render_resources_api;
#[path = "render_shader_api.rs"]
mod render_shader_api;
#[path = "render_state_api.rs"]
mod render_state_api;
#[path = "render_text_api.rs"]
mod render_text_api;
/// Raw pixel buffer for CPU-side image manipulation before uploading to a GPU texture.
pub struct LuaImageData {
    pub(crate) inner: ImageData,
}

/// Lua handle for one non-blocking surface readback request.
pub struct LuaSurfaceReadbackRequest {
    state: Rc<RefCell<SharedState>>,
    id: u64,
}

/// Lua handle for one bounded shader-cache prewarm request.
pub struct LuaShaderPrewarmRequest {
    state: Rc<RefCell<SharedState>>,
    id: u64,
}

impl LuaShaderPrewarmRequest {
    fn request_mut(&self) -> LuaResult<std::cell::RefMut<'_, ShaderPrewarmRequest>> {
        std::cell::RefMut::filter_map(self.state.borrow_mut(), |state| {
            state.shader_prewarm_requests.get_mut(&self.id)
        })
        .map_err(|_| {
            LuaError::RuntimeError(
                "lurek.render.LShaderPrewarmRequest: handle is stale or released".into(),
            )
        })
    }

    fn request(&self) -> LuaResult<std::cell::Ref<'_, ShaderPrewarmRequest>> {
        std::cell::Ref::filter_map(self.state.borrow(), |state| {
            state.shader_prewarm_requests.get(&self.id)
        })
        .map_err(|_| {
            LuaError::RuntimeError(
                "lurek.render.LShaderPrewarmRequest: handle is stale or released".into(),
            )
        })
    }
}

impl LuaUserData for LuaShaderPrewarmRequest {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- status --
        /// Returns `pending`, `ready`, `failed`, or `cancelled`.
        /// @return | string | Stable request lifecycle state.
        methods.add_method("status", |_, this, ()| Ok(this.request()?.state.as_str()));
        // -- poll --
        /// Observes the current non-blocking lifecycle state after frame-boundary work.
        /// @return | string | Stable request lifecycle state; this never blocks Lua.
        methods.add_method("poll", |_, this, ()| Ok(this.request()?.state.as_str()));
        // -- progress --
        /// Returns the number of completed shader keys and the immutable requested total.
        /// @return | integer, integer | Completed key count and requested key count.
        methods.add_method("progress", |_, this, ()| {
            let request = this.request()?;
            Ok((request.completed, request.total))
        });
        // -- cancel --
        /// Cancels unfinished cache work before a later frame can submit it.
        /// @return | boolean | True when this call changed a pending request.
        methods.add_method("cancel", |_, this, ()| {
            let mut request = this.request_mut()?;
            if request.state == ShaderPrewarmRequestState::Pending {
                request.remaining.clear();
                request.state = ShaderPrewarmRequestState::Cancelled;
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- release --
        /// Releases this request handle and cancels its outstanding cache work.
        /// @return | boolean | True when the handle owned a live request.
        methods.add_method("release", |_, this, ()| {
            Ok(this
                .state
                .borrow_mut()
                .shader_prewarm_requests
                .remove(&this.id)
                .is_some())
        });
        // -- type --
        /// Returns the userdata type name for this shader prewarm request handle.
        /// @return | string | `LShaderPrewarmRequest`.
        methods.add_method("type", |_, _, ()| Ok("LShaderPrewarmRequest"));
        // -- typeOf --
        /// Returns whether this object matches a supported type name.
        /// @param | name | string | Type name to test.
        /// @return | boolean | Whether the type matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LShaderPrewarmRequest" || name == "LObject")
        });
    }
}

impl LuaSurfaceReadbackRequest {
    fn request_mut(&self) -> LuaResult<std::cell::RefMut<'_, SurfaceReadbackRequest>> {
        std::cell::RefMut::filter_map(self.state.borrow_mut(), |state| {
            state
                .surface_readback_request
                .as_mut()
                .filter(|request| request.id == self.id)
        })
        .map_err(|_| {
            LuaError::RuntimeError(
                "lurek.render.LReadbackRequest: handle is stale or released".into(),
            )
        })
    }

    fn request(&self) -> LuaResult<std::cell::Ref<'_, SurfaceReadbackRequest>> {
        std::cell::Ref::filter_map(self.state.borrow(), |state| {
            state
                .surface_readback_request
                .as_ref()
                .filter(|request| request.id == self.id)
        })
        .map_err(|_| {
            LuaError::RuntimeError(
                "lurek.render.LReadbackRequest: handle is stale or released".into(),
            )
        })
    }
}

impl LuaUserData for LuaSurfaceReadbackRequest {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- status --
        /// Returns `pending`, `ready`, `failed`, `timed_out`, or `cancelled`.
        /// @return | string | Stable request lifecycle state.
        methods.add_method("status", |_, this, ()| Ok(this.request()?.state.as_str()));
        // -- poll --
        /// Observes the current non-blocking lifecycle state after normal frame polling.
        /// @return | string | Stable request lifecycle state; this never blocks Lua.
        methods.add_method("poll", |_, this, ()| Ok(this.request()?.state.as_str()));
        // -- isReady --
        /// Returns whether the result can be consumed.
        /// @return | boolean | True only after a successful GPU readback.
        methods.add_method("isReady", |_, this, ()| {
            Ok(this.request()?.state == SurfaceReadbackRequestState::Ready)
        });
        // -- cancel --
        /// Cancels an unfinished request and releases any later result.
        /// @return | boolean | True when this call changed a pending request.
        methods.add_method("cancel", |_, this, ()| {
            let mut request = this.request_mut()?;
            if request.state == SurfaceReadbackRequestState::Pending {
                request.state = SurfaceReadbackRequestState::Cancelled;
                request.image = None;
                drop(request);
                let mut state = this.state.borrow_mut();
                state.cancel_surface_readback_requested = true;
                state.pending_screen_capture = false;
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- result --
        /// Consumes and returns a completed image, or nil before completion and after consumption.
        /// @return | LImageData|nil | Completed image data when available.
        methods.add_method("result", |lua, this, ()| {
            let mut request = this.request_mut()?;
            match request.image.take() {
                Some(image) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaImageData { inner: image })?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- release --
        /// Releases this request handle and any completed but unconsumed image.
        /// @return | boolean | True when the handle owned the live request.
        methods.add_method("release", |_, this, ()| {
            let mut state = this.state.borrow_mut();
            let was_pending = state
                .surface_readback_request
                .as_ref()
                .is_some_and(|request| {
                    request.id == this.id && request.state == SurfaceReadbackRequestState::Pending
                });
            if state
                .surface_readback_request
                .as_ref()
                .is_some_and(|request| request.id == this.id)
            {
                state.surface_readback_request = None;
                if was_pending {
                    state.cancel_surface_readback_requested = true;
                    state.pending_screen_capture = false;
                }
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- type --
        /// Returns the userdata type name for this surface readback request handle.
        /// @return | string | `LReadbackRequest`.
        methods.add_method("type", |_, _, ()| Ok("LReadbackRequest"));
        // -- typeOf --
        /// Returns whether this object matches a supported type name.
        /// @param | name | string | Type name to test.
        /// @return | boolean | Whether the type matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LReadbackRequest" || name == "LObject")
        });
    }
}
impl LuaUserData for LuaImageData {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns the width of this image data in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.width()));
        // -- getHeight --
        /// Returns the height of this image data in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.height()));
        // -- resize --
        /// Creates a new ImageData resized to the given dimensions using bilinear sampling.
        /// @param | w | integer | Target width in pixels.
        /// @param | h | integer | Target height in pixels.
        /// @return | LImageData | A new resized ImageData, or nil if the operation failed.
        methods.add_method("resize", |lua, this, (w, h): (u32, u32)| {
            match this.inner.resize(w, h) {
                Some(img) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaImageData { inner: img })?,
                )),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- blit --
        /// Copies pixel data from another ImageData onto this one at the specified position.
        /// @param | source | LImageData | The source image data to copy from.
        /// @param | dstX | integer | Destination X offset in pixels.
        /// @param | dstY | integer | Destination Y offset in pixels.
        methods.add_method_mut(
            "blit",
            |_, this, (src_ud, dst_x, dst_y): (LuaAnyUserData, i32, i32)| {
                let src_ref = src_ud.borrow::<LuaImageData>()?;
                this.inner.blit(&src_ref.inner, dst_x, dst_y);
                Ok(())
            },
        );
        // -- getRegion --
        /// Extracts a rectangular sub-region as a new ImageData.
        /// @param | x | integer | Top-left X coordinate of the region.
        /// @param | y | integer | Top-left Y coordinate of the region.
        /// @param | w | integer | Width of the region in pixels.
        /// @param | h | integer | Height of the region in pixels.
        /// @return | LImageData | A new ImageData for the region, or nil if out of bounds.
        methods.add_method(
            "getRegion",
            |lua, this, (x, y, w, h): (u32, u32, u32, u32)| match this.inner.get_region(x, y, w, h)
            {
                Some(img) => Ok(LuaValue::UserData(
                    lua.create_userdata(LuaImageData { inner: img })?,
                )),
                None => Ok(LuaValue::Nil),
            },
        );
        // -- diff --
        /// Computes a numeric difference score between this image and another of the same size.
        /// @param | other | LImageData | The image data to compare against.
        /// @return | number | Sum of per-pixel absolute color differences (0 = identical).
        methods.add_method("diff", |_, this, other_ud: LuaAnyUserData| {
            let other_ref = other_ud.borrow::<LuaImageData>()?;
            Ok(this.inner.diff(&other_ref.inner))
        });
        // -- mapPixels --
        /// Iterates over every pixel and replaces its color with the return value of the callback.
        /// @param | callback | function | Called as callback(x, y, r, g, b, a) â†’ (r, g, b, a) for each pixel.
        methods.add_method_mut("mapPixels", |_lua, this, callback: LuaFunction| {
            let w = this.inner.width();
            let h = this.inner.height();
            for py in 0..h {
                for px in 0..w {
                    if let Some((r, g, b, a)) = this.inner.get_pixel(px, py) {
                        let result: (u8, u8, u8, u8) = callback.call((px, py, r, g, b, a))?;
                        this.inner
                            .set_pixel(px, py, result.0, result.1, result.2, result.3);
                    }
                }
            }
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always "LImageData".
        methods.add_method("type", |_, _, ()| Ok("LImageData"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("ImageData" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LImageData" || name == "LObject")
        });
    }
}
/// GPU-backed texture handle used for drawing images to screen.
#[derive(Clone)]
pub struct LuaImage {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: TextureKey,
}
/// Texture with defined border insets for scalable 9-slice rendering (e.g., UI panels, buttons).
#[derive(Clone)]
pub struct LuaNineSlice {
    pub(crate) key: TextureKey,
    pub(crate) tex_w: u32,
    pub(crate) tex_h: u32,
    pub(crate) top: f32,
    pub(crate) right: f32,
    pub(crate) bottom: f32,
    pub(crate) left: f32,
}
impl LuaUserData for LuaNineSlice {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getInsets --
        /// Returns the border insets (top, right, bottom, left) that define the stretchable regions.
        /// @return | number, number, number, number | Top, right, bottom, left inset values.
        methods.add_method("getInsets", |_, this, ()| {
            Ok((this.top, this.right, this.bottom, this.left))
        });
        // -- getTextureSize --
        /// Returns the pixel dimensions of the underlying source texture.
        /// @return | number, number | Width and height in pixels.
        methods.add_method("getTextureSize", |_, this, ()| Ok((this.tex_w, this.tex_h)));
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always "LNineSlice".
        methods.add_method("type", |_, _, ()| Ok("LNineSlice"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("NineSlice" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNineSlice" || name == "LObject")
        });
    }
}
impl LuaUserData for LuaImage {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getId --
        /// Returns the internal numeric handle ID for this image.
        /// @return | number | Opaque image handle identifier.
        methods.add_method("getId", |_, this, ()| Ok(this.key.data().as_ffi()));
        // -- getWidth --
        /// Returns the width of this image in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            let st = this.state.borrow();
            let td = st.textures.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Image handle is not valid or was released".into())
            })?;
            Ok(td.width)
        });
        // -- getHeight --
        /// Returns the height of this image in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            let st = this.state.borrow();
            let td = st.textures.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Image handle is not valid or was released".into())
            })?;
            Ok(td.height)
        });
        // -- getDimensions --
        /// Returns both width and height of this image.
        /// @return | number, number | Width and height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            let st = this.state.borrow();
            let td = st.textures.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Image handle is not valid or was released".into())
            })?;
            Ok((td.width, td.height))
        });
        // -- release --
        /// Releases the GPU memory for this image. The handle becomes invalid after this call.
        /// @return | boolean | True if the image was still valid and was released.
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            Ok(st.release_texture(this.key))
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Image" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LImage" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this image object.
        /// @return | string | Always "LImage".
        methods.add_method("type", |_, _, ()| Ok("LImage"));
    }
}
/// Bitmap font handle for measuring and rendering text.
#[derive(Clone)]
pub struct LuaFont {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: FontKey,
}
impl LuaUserData for LuaFont {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Measures the pixel width of a string when rendered with this font.
        /// @param | text | string | The text to measure.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, text: String| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            Ok(font.text_width(&text))
        });
        // -- getHeight --
        /// Returns the line height of this font in pixels.
        /// @return | number | Line height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            Ok(font.line_height())
        });
        // -- getLineHeight --
        /// Returns the spacing between consecutive lines of text.
        /// @return | number | Line height in pixels.
        methods.add_method("getLineHeight", |_, this, ()| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            Ok(font.line_height())
        });
        // -- setLineHeight --
        /// Overrides the line height used for multi-line text rendering.
        /// @param | height | number | New line height in pixels.
        methods.add_method("setLineHeight", |_, this, height: f32| {
            let mut st = this.state.borrow_mut();
            let font = st.fonts.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            font.set_line_height(height);
            Ok(())
        });
        // -- getAscent --
        /// Returns the ascent (pixels above the baseline) of this font.
        /// @return | number | Ascent in pixels.
        methods.add_method("getAscent", |_, this, ()| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            Ok(font.ascent())
        });
        // -- getDescent --
        /// Returns the descent (pixels below the baseline) of this font.
        /// @return | number | Descent in pixels (positive value extending downward).
        methods.add_method("getDescent", |_, this, ()| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            Ok(font.descent())
        });
        // -- getWrap --
        /// Word-wraps text to fit within a pixel width limit and returns the resulting lines.
        /// @param | text | string | The text to wrap.
        /// @param | limit | number | Maximum line width in pixels.
        /// @return | table, number | Array of wrapped line strings, and the widest line width.
        methods.add_method("getWrap", |lua, this, (text, limit): (String, f32)| {
            let st = this.state.borrow();
            let font = st.fonts.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Font handle is not valid or was released".into())
            })?;
            let lines = font.wrap_text(&text, limit);
            let mut max_w: f32 = 0.0;
            for line in &lines {
                let w = font.text_width(line);
                if w > max_w {
                    max_w = w;
                }
            }
            let tbl = lua.create_table()?;
            for (i, line) in lines.iter().enumerate() {
                tbl.set(i + 1, line.as_str())?;
            }
            Ok((tbl, max_w))
        });
        // -- release --
        /// Releases the font resource. The handle becomes invalid after this call.
        /// @return | boolean | True if the font was still valid and was released.
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if st.fonts.remove(this.key).is_some() {
                if st.active_font == Some(this.key) {
                    st.active_font = None;
                }
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Font" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LFont" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this font object.
        /// @return | string | Always "LFont".
        methods.add_method("type", |_, _, ()| Ok("LFont"));
    }
}

fn active_font_key(st: &SharedState) -> Option<FontKey> {
    st.active_font.or(st.default_font)
}

fn resolve_font_key(font_ud: &LuaAnyUserData) -> LuaResult<FontKey> {
    if let Ok(font) = font_ud.borrow::<LuaFont>() {
        let key = font.key;
        let valid = font.state.borrow().fonts.contains_key(key);
        drop(font);
        return if valid {
            Ok(key)
        } else {
            Err(LuaError::RuntimeError(
                "font handle is not valid or was released".into(),
            ))
        };
    }

    if let Ok(font) = font_ud.borrow::<crate::lua_api::font_api::LuaFont>() {
        let key = font.key();
        let valid = font.is_valid();
        drop(font);
        return if valid {
            Ok(key)
        } else {
            Err(LuaError::RuntimeError(
                "font handle is not valid or was released".into(),
            ))
        };
    }

    Err(LuaError::RuntimeError(
        "font handle is not valid or was released".into(),
    ))
}

fn builtin_font_key_by_name(st: &SharedState, name: &str) -> Option<FontKey> {
    let (slot, bold) = Font::builtin_slot_by_name(name)?;
    let arr = if bold {
        &st.default_bold_fonts
    } else {
        &st.default_fonts
    };
    arr[slot]
}

fn builtin_font_key_by_point_size(
    st: &SharedState,
    point_size: u32,
    bold: Option<bool>,
) -> Option<FontKey> {
    let idx = Font::nearest_point_size(point_size);
    let use_bold = bold.unwrap_or(st.active_bold);
    let arr = if use_bold {
        &st.default_bold_fonts
    } else {
        &st.default_fonts
    };
    arr[idx]
}

fn load_font_from_path(st: &mut SharedState, path: &str, size: f32) -> LuaResult<FontKey> {
    let data = st.fs.read_bytes(path).map_err(|e| {
        LuaError::RuntimeError(format!(
            "lurek.render.newFont: failed to read '{}': {}",
            path, e
        ))
    })?;
    let ext = Path::new(path)
        .extension()
        .and_then(|ext| ext.to_str())
        .map(|ext| ext.to_ascii_lowercase());
    let bitmap_cell_h = size.max(1.0).round() as u32;
    let bitmap_cell_w = (size.max(1.0) * 0.6).round().max(1.0) as u32;
    let font = match ext.as_deref() {
        Some("ttf") | Some("otf") | Some("ttc") => Font::from_font_bytes(&data, size),
        Some("png") => Font::from_png_bytes(&data, bitmap_cell_w, bitmap_cell_h, false),
        _ => Font::from_font_bytes(&data, size)
            .or_else(|_| Font::from_png_bytes(&data, bitmap_cell_w, bitmap_cell_h, false)),
    }
    .map_err(|e| LuaError::RuntimeError(format!("lurek.render.newFont: {}", e)))?;
    Ok(st.fonts.insert(font))
}

fn build_rich_text_spans(
    spans_table: &LuaTable,
) -> LuaResult<Vec<crate::render::renderer::TextSpan>> {
    use crate::render::renderer::TextSpan;

    let mut spans = Vec::new();
    for pair in spans_table.clone().pairs::<LuaValue, LuaTable>() {
        let (_, span_tbl) = pair.map_err(mlua::Error::external)?;
        let text: String = span_tbl.get::<_, String>("text").unwrap_or_default();
        let r: u8 = span_tbl.get::<_, u8>("r").unwrap_or(255);
        let g: u8 = span_tbl.get::<_, u8>("g").unwrap_or(255);
        let b: u8 = span_tbl.get::<_, u8>("b").unwrap_or(255);
        let a: u8 = span_tbl.get::<_, u8>("a").unwrap_or(255);
        let scale: f32 = span_tbl.get::<_, f32>("scale").unwrap_or(1.0);
        spans.push(TextSpan::new(text, r, g, b, a, scale));
    }
    Ok(spans)
}

fn postfx_passes_from_userdata(
    state: &SharedState,
    ud: &LuaAnyUserData,
    api: &str,
) -> LuaResult<Vec<PostFxPass>> {
    if let Ok(effect) = ud.borrow::<LuaPostFxEffect>() {
        return Ok(vec![effect.to_postfx_pass(state, api)?]);
    }
    if let Ok(stack) = ud.borrow::<LuaPostFxStack>() {
        return stack.effect_passes_for_api(api);
    }
    Err(LuaError::RuntimeError(format!(
        "{api}: expected LPostFxEffect or LPostFxStack"
    )))
}

/// Off-screen render target that can be drawn to and then composited onto the screen.
#[derive(Clone)]
pub struct LuaCanvas {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: CanvasKey,
}
impl LuaUserData for LuaCanvas {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns the width of this canvas in pixels.
        /// @return | number | Width in pixels.
        methods.add_method("getWidth", |_, this, ()| {
            let st = this.state.borrow();
            let c = st.canvases.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Canvas handle is not valid or was released".into())
            })?;
            Ok(c.width)
        });
        // -- getHeight --
        /// Returns the height of this canvas in pixels.
        /// @return | number | Height in pixels.
        methods.add_method("getHeight", |_, this, ()| {
            let st = this.state.borrow();
            let c = st.canvases.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Canvas handle is not valid or was released".into())
            })?;
            Ok(c.height)
        });
        // -- getDimensions --
        /// Returns both width and height of this canvas.
        /// @return | number, number | Width and height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            let st = this.state.borrow();
            let c = st.canvases.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Canvas handle is not valid or was released".into())
            })?;
            Ok((c.width, c.height))
        });
        // -- applyShader --
        /// Queues a postfx shader pass that mutates this canvas render target after queued canvas draws in the current frame.
        /// @param | shader | LShader | Shader created with `lurek.render.newShader(code, { target = "postfx" })`.
        /// @param | opts | table? | Reserved options table for future pass parameters.
        /// @return | LCanvas | This canvas handle.
        methods.add_method(
            "applyShader",
            |_, this, (shader_ud, _opts): (LuaAnyUserData, Option<LuaTable>)| {
                let shader_key = shader_key_from_userdata(&shader_ud)?;
                let mut st = this.state.borrow_mut();
                if !st.canvases.contains_key(this.key) {
                    return Err(LuaError::RuntimeError(
                        "LCanvas:applyShader: canvas handle is not valid".into(),
                    ));
                }
                ensure_shader_target(&st, shader_key, ShaderTarget::PostFx, "LCanvas:applyShader")?;
                let shader_id = shader_key.data().as_ffi() as usize;
                st.render_commands.push(RenderCommand::ApplyShaderToCanvas {
                    canvas_key: this.key,
                    passes: vec![PostFxPass {
                        effect_name: format!("canvas_shader_{shader_id}"),
                        params: std::collections::HashMap::new(),
                        shader_id: Some(shader_id),
                        auto_uniforms: true,
                    }],
                });
                Ok(this.clone())
            },
        );
        // -- release --
        /// Releases the canvas GPU resource. If this canvas is currently active, drawing reverts to the screen.
        /// @return | boolean | True if the canvas was still valid and was released.
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if st.canvases.remove(this.key).is_some() {
                if st.active_canvas == Some(this.key) {
                    st.active_canvas = None;
                    st.render_commands.push(RenderCommand::SetCanvas(None));
                }
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Canvas" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LCanvas" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this canvas object.
        /// @return | string | Always "LCanvas".
        methods.add_method("type", |_, _, ()| Ok("LCanvas"));
    }
}
/// Batched sprite renderer for efficiently drawing many copies of the same texture.
#[derive(Clone)]
pub struct LuaSpriteBatch {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: SpriteBatchKey,
}

fn sprite_batch_error(method: &str, message: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.render.LSpriteBatch:{method}: {message}"))
}

fn validate_batch_number(method: &str, field: &str, value: f32) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(sprite_batch_error(
            method,
            format!("{field} must be finite"),
        ))
    }
}

fn batch_entry_from_table(table: LuaTable, method: &str) -> LuaResult<BatchEntry> {
    let x = table.get::<_, Option<f32>>("x")?.unwrap_or(0.0);
    let y = table.get::<_, Option<f32>>("y")?.unwrap_or(0.0);
    let quad_x = table.get::<_, Option<f32>>("quadX")?.unwrap_or(0.0);
    let quad_y = table.get::<_, Option<f32>>("quadY")?.unwrap_or(0.0);
    let quad_w = table.get::<_, Option<f32>>("quadW")?.unwrap_or(0.0);
    let quad_h = table.get::<_, Option<f32>>("quadH")?.unwrap_or(0.0);
    let rotation = table.get::<_, Option<f32>>("r")?.unwrap_or(0.0);
    let sx = table.get::<_, Option<f32>>("sx")?.unwrap_or(1.0);
    let sy = table.get::<_, Option<f32>>("sy")?.unwrap_or(1.0);
    let ox = table.get::<_, Option<f32>>("ox")?.unwrap_or(0.0);
    let oy = table.get::<_, Option<f32>>("oy")?.unwrap_or(0.0);
    Ok(BatchEntry {
        x: validate_batch_number(method, "x", x)?,
        y: validate_batch_number(method, "y", y)?,
        quad_x: validate_batch_number(method, "quadX", quad_x)?,
        quad_y: validate_batch_number(method, "quadY", quad_y)?,
        quad_w: validate_batch_number(method, "quadW", quad_w)?,
        quad_h: validate_batch_number(method, "quadH", quad_h)?,
        rotation: validate_batch_number(method, "r", rotation)?,
        sx: validate_batch_number(method, "sx", sx)?,
        sy: validate_batch_number(method, "sy", sy)?,
        ox: validate_batch_number(method, "ox", ox)?,
        oy: validate_batch_number(method, "oy", oy)?,
    })
}

fn batch_entries_from_table(entries: LuaTable, method: &str) -> LuaResult<Vec<BatchEntry>> {
    let mut parsed = Vec::new();
    for (index, entry) in entries.sequence_values::<LuaTable>().enumerate() {
        parsed.push(batch_entry_from_table(
            entry.map_err(|error| {
                sprite_batch_error(method, format!("entry {}: {error}", index + 1))
            })?,
            method,
        )?);
    }
    Ok(parsed)
}

impl LuaUserData for LuaSpriteBatch {
    #[allow(clippy::type_complexity)]
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- add --
        /// Adds a sprite entry to the batch at the given position with optional transform.
        /// @param | x | number | X position.
        /// @param | y | number | Y position.
        /// @param | r | number? | Rotation in radians.
        /// @param | sx | number? | Scale X (default 1).
        /// @param | sy | number? | Scale Y (default 1).
        /// @param | ox | number? | Origin offset X.
        /// @param | oy | number? | Origin offset Y.
        /// @return | number | Index of the added entry.
        methods.add_method(
            "add",
            |_,
             this,
             (x, y, r, sx, sy, ox, oy): (
                f32,
                f32,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                for (field, value) in [
                    ("x", x),
                    ("y", y),
                    ("r", r.unwrap_or(0.0)),
                    ("sx", sx.unwrap_or(1.0)),
                    ("sy", sy.unwrap_or(1.0)),
                    ("ox", ox.unwrap_or(0.0)),
                    ("oy", oy.unwrap_or(0.0)),
                ] {
                    validate_batch_number("add", field, value)?;
                }
                let mut st = this.state.borrow_mut();
                let batch = st.sprite_batches.get_mut(this.key).ok_or_else(|| {
                    sprite_batch_error("add", "handle is not valid or was released")
                })?;
                let entry = BatchEntry {
                    x,
                    y,
                    quad_x: 0.0,
                    quad_y: 0.0,
                    quad_w: 0.0,
                    quad_h: 0.0,
                    rotation: r.unwrap_or(0.0),
                    sx: sx.unwrap_or(1.0),
                    sy: sy.unwrap_or(1.0),
                    ox: ox.unwrap_or(0.0),
                    oy: oy.unwrap_or(0.0),
                };
                batch
                    .add(entry)
                    .map(|index| index + 1)
                    .ok_or_else(|| sprite_batch_error("add", "batch capacity exceeded"))
            },
        );
        // -- addComposite --
        /// Adds multiple part entries to the batch for one modular composite visual.
        /// @param | parts | table | Array of part tables with x, y, r, sx, sy, ox, oy, and optional quad fields.
        /// @return | number | Number of entries added.
        methods.add_method("addComposite", |_, this, parts: LuaTable| {
            let entries = batch_entries_from_table(parts, "addComposite")?;
            let mut st = this.state.borrow_mut();
            let batch = st.sprite_batches.get_mut(this.key).ok_or_else(|| {
                sprite_batch_error("addComposite", "handle is not valid or was released")
            })?;
            let added = entries.len();
            batch
                .add_many(entries)
                .map_err(|error| sprite_batch_error("addComposite", error))?;
            Ok(added)
        });
        // -- addMany --
        /// Atomically appends an array of sprite entries after validating the whole input.
        /// @param | entries | table | Array of entries with x, y, r, sx, sy, ox, oy, and optional quad fields.
        /// @return | integer | Number of entries added.
        methods.add_method("addMany", |_, this, entries: LuaTable| {
            let entries = batch_entries_from_table(entries, "addMany")?;
            let count = entries.len();
            let mut st = this.state.borrow_mut();
            let batch = st.sprite_batches.get_mut(this.key).ok_or_else(|| {
                sprite_batch_error("addMany", "handle is not valid or was released")
            })?;
            batch
                .add_many(entries)
                .map_err(|error| sprite_batch_error("addMany", error))?;
            Ok(count)
        });
        // -- setEntries --
        /// Atomically replaces all sprite entries after validating the whole input.
        /// @param | entries | table | Array of sprite entry tables.
        /// @return | integer | New entry count.
        methods.add_method("setEntries", |_, this, entries: LuaTable| {
            let entries = batch_entries_from_table(entries, "setEntries")?;
            let mut st = this.state.borrow_mut();
            let batch = st.sprite_batches.get_mut(this.key).ok_or_else(|| {
                sprite_batch_error("setEntries", "handle is not valid or was released")
            })?;
            batch
                .set_entries(entries)
                .map_err(|error| sprite_batch_error("setEntries", error))
        });
        // -- updateEntries --
        /// Atomically replaces selected one-based sprite entries.
        /// @param | updates | table | Array of entry tables with a required one-based `index` field.
        /// @return | integer | Number of entries whose values changed.
        methods.add_method("updateEntries", |_, this, updates: LuaTable| {
            let mut parsed = Vec::new();
            for (position, update) in updates.sequence_values::<LuaTable>().enumerate() {
                let update = update.map_err(|error| {
                    sprite_batch_error("updateEntries", format!("entry {}: {error}", position + 1))
                })?;
                let index = update.get::<_, usize>("index").map_err(|error| {
                    sprite_batch_error(
                        "updateEntries",
                        format!("entry {} index: {error}", position + 1),
                    )
                })?;
                if index == 0 {
                    return Err(sprite_batch_error(
                        "updateEntries",
                        format!("entry {} index must be one-based", position + 1),
                    ));
                }
                parsed.push((index - 1, batch_entry_from_table(update, "updateEntries")?));
            }
            let mut st = this.state.borrow_mut();
            let batch = st.sprite_batches.get_mut(this.key).ok_or_else(|| {
                sprite_batch_error("updateEntries", "handle is not valid or was released")
            })?;
            batch
                .update_entries(parsed)
                .map_err(|error| sprite_batch_error("updateEntries", error))
        });
        // -- removeEntries --
        /// Atomically removes selected one-based sprite entries.
        /// @param | indices | table | Array of unique one-based entry indices.
        /// @return | integer | Number of removed entries.
        methods.add_method("removeEntries", |_, this, indices: LuaTable| {
            let mut parsed = Vec::new();
            for (position, index) in indices.sequence_values::<usize>().enumerate() {
                let index = index.map_err(|error| {
                    sprite_batch_error("removeEntries", format!("index {}: {error}", position + 1))
                })?;
                if index == 0 {
                    return Err(sprite_batch_error(
                        "removeEntries",
                        format!("index {} must be one-based", position + 1),
                    ));
                }
                parsed.push(index - 1);
            }
            let mut st = this.state.borrow_mut();
            let batch = st.sprite_batches.get_mut(this.key).ok_or_else(|| {
                sprite_batch_error("removeEntries", "handle is not valid or was released")
            })?;
            batch
                .remove_entries(parsed)
                .map_err(|error| sprite_batch_error("removeEntries", error))
        });
        // -- clear --
        /// Removes all entries from the sprite batch.
        methods.add_method("clear", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(batch) = st.sprite_batches.get_mut(this.key) {
                batch.clear();
            }
            Ok(())
        });
        // -- getCount --
        /// Returns the number of sprite entries currently in the batch.
        /// @return | number | Entry count.
        methods.add_method("getCount", |_, this, ()| {
            let st = this.state.borrow();
            let batch = st.sprite_batches.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("SpriteBatch handle is not valid or was released".into())
            })?;
            Ok(batch.len())
        });
        // -- getBufferSize --
        /// Returns the maximum number of entries this batch can hold.
        /// @return | number | Buffer capacity.
        methods.add_method("getBufferSize", |_, this, ()| {
            let st = this.state.borrow();
            let batch = st.sprite_batches.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("SpriteBatch handle is not valid or was released".into())
            })?;
            Ok(batch.buffer_size())
        });
        // -- getVersion --
        /// Returns the monotonic sprite-entry content version.
        /// @return | integer | Version incremented once per successful content mutation.
        methods.add_method("getVersion", |_, this, ()| {
            let st = this.state.borrow();
            let batch = st.sprite_batches.get(this.key).ok_or_else(|| {
                sprite_batch_error("getVersion", "handle is not valid or was released")
            })?;
            Ok(batch.version())
        });
        // -- getDiagnostics --
        /// Returns deterministic capacity and mutation diagnostics for this batch.
        /// @return | table | Table with count, capacity, remaining, and version.
        methods.add_method("getDiagnostics", |lua, this, ()| {
            let st = this.state.borrow();
            let batch = st.sprite_batches.get(this.key).ok_or_else(|| {
                sprite_batch_error("getDiagnostics", "handle is not valid or was released")
            })?;
            let diagnostics = lua.create_table()?;
            diagnostics.set("count", batch.len())?;
            diagnostics.set("capacity", batch.buffer_size())?;
            diagnostics.set("remaining", batch.remaining())?;
            diagnostics.set("version", batch.version())?;
            Ok(diagnostics)
        });
        // -- release --
        /// Releases the sprite batch resource.
        /// @return | boolean | True if the batch was valid and was released.
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            Ok(st.sprite_batches.remove(this.key).is_some())
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("SpriteBatch" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpriteBatch" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this sprite batch.
        /// @return | string | Always "LSpriteBatch".
        methods.add_method("type", |_, _, ()| Ok("LSpriteBatch"));
    }
}

fn queue_sprite_batch_draw(
    st: &mut SharedState,
    batch_key: SpriteBatchKey,
    error_context: &str,
) -> LuaResult<()> {
    if !st.sprite_batches.contains_key(batch_key) {
        return Err(LuaError::RuntimeError(format!(
            "{error_context}: sprite batch handle is not valid"
        )));
    }
    st.render_commands
        .push(RenderCommand::DrawBatch { batch_key });
    Ok(())
}

fn lua_value_as_f32(value: &LuaValue) -> Option<f32> {
    match value {
        LuaValue::Number(n) => Some(*n as f32),
        LuaValue::Integer(n) => Some(*n as f32),
        _ => None,
    }
}

fn collect_numeric_args(args: &LuaMultiValue) -> Vec<f32> {
    args.iter().filter_map(lua_value_as_f32).collect()
}

type LuaRichTextArgs<'lua> = (
    LuaTable<'lua>,
    f32,
    f32,
    Option<f32>,
    Option<f32>,
    Option<f32>,
    Option<f32>,
    Option<f32>,
);
type LuaRichTextWithFontArgs<'lua> = (
    LuaAnyUserData<'lua>,
    LuaTable<'lua>,
    f32,
    f32,
    Option<f32>,
    Option<f32>,
    Option<f32>,
    Option<f32>,
    Option<f32>,
);

fn queue_render_line(st: &mut SharedState, args: LuaMultiValue) {
    let vals = collect_numeric_args(&args);
    if vals.len() == 4 {
        st.render_commands.push(RenderCommand::Line {
            x1: vals[0],
            y1: vals[1],
            x2: vals[2],
            y2: vals[3],
        });
    } else if vals.len() >= 4 {
        st.render_commands
            .push(RenderCommand::Polyline { points: vals });
    }
}

fn queue_render_polygon(st: &mut SharedState, args: LuaMultiValue) -> LuaResult<()> {
    let mut iter = args.iter();
    let mode_str = match iter.next() {
        Some(LuaValue::String(s)) => s.to_str().unwrap_or("fill").to_string(),
        _ => "fill".to_string(),
    };
    let mut vertices = Vec::new();
    for value in iter {
        match value {
            LuaValue::Number(n) => vertices.push(*n as f32),
            LuaValue::Integer(n) => vertices.push(*n as f32),
            LuaValue::Table(t) => {
                for n in t.clone().sequence_values::<f64>().flatten() {
                    vertices.push(n as f32);
                }
            }
            _ => {}
        }
    }
    st.render_commands.push(RenderCommand::Polygon {
        mode: parse_draw_mode(&mode_str)?,
        vertices,
    });
    Ok(())
}

fn queue_render_points(st: &mut SharedState, args: LuaMultiValue) -> LuaResult<()> {
    let mut points = Vec::new();
    if args.len() == 1 {
        if let Some(LuaValue::Table(t)) = args.get(0) {
            for pair in t.clone().sequence_values::<LuaTable>() {
                let p = pair?;
                let x: f32 = p.get(1)?;
                let y: f32 = p.get(2)?;
                points.push((x, y));
            }
        }
    } else {
        let vals = collect_numeric_args(&args);
        let mut i = 0;
        while i + 1 < vals.len() {
            points.push((vals[i], vals[i + 1]));
            i += 2;
        }
    }
    st.render_commands.push(RenderCommand::Points { points });
    Ok(())
}

#[derive(Debug, Clone, Copy)]
struct RenderDrawTransform {
    x: f32,
    y: f32,
    rotation: f32,
    sx: f32,
    sy: f32,
    ox: f32,
    oy: f32,
}

impl RenderDrawTransform {
    fn from_values(args_iter: &mut dyn Iterator<Item = &LuaValue>) -> Self {
        Self {
            x: args_iter.next().and_then(lua_value_as_f32).unwrap_or(0.0),
            y: args_iter.next().and_then(lua_value_as_f32).unwrap_or(0.0),
            rotation: args_iter.next().and_then(lua_value_as_f32).unwrap_or(0.0),
            sx: args_iter.next().and_then(lua_value_as_f32).unwrap_or(1.0),
            sy: args_iter.next().and_then(lua_value_as_f32).unwrap_or(1.0),
            ox: args_iter.next().and_then(lua_value_as_f32).unwrap_or(0.0),
            oy: args_iter.next().and_then(lua_value_as_f32).unwrap_or(0.0),
        }
    }

    fn has_non_default_transform(self) -> bool {
        self.rotation != 0.0 || self.sx != 1.0 || self.sy != 1.0 || self.ox != 0.0 || self.oy != 0.0
    }
}

fn queue_draw_image(
    st: &mut SharedState,
    key: TextureKey,
    transform: RenderDrawTransform,
) -> LuaResult<()> {
    if !st.textures.contains_key(key) {
        return Err(LuaError::RuntimeError(
            "lurek.render.draw: image handle is not valid".into(),
        ));
    }
    if transform.has_non_default_transform() {
        st.render_commands.push(RenderCommand::DrawImageEx {
            texture_key: key,
            x: transform.x,
            y: transform.y,
            rotation: transform.rotation,
            sx: transform.sx,
            sy: transform.sy,
            ox: transform.ox,
            oy: transform.oy,
            effect: None,
        });
    } else {
        st.render_commands.push(RenderCommand::DrawImage {
            texture_key: key,
            x: transform.x,
            y: transform.y,
            effect: None,
        });
    }
    Ok(())
}

fn queue_draw_canvas(
    st: &mut SharedState,
    key: CanvasKey,
    transform: RenderDrawTransform,
) -> LuaResult<()> {
    if !st.canvases.contains_key(key) {
        return Err(LuaError::RuntimeError(
            "lurek.render.draw: canvas handle is not valid".into(),
        ));
    }
    st.render_commands.push(RenderCommand::DrawCanvas {
        canvas_key: key,
        x: transform.x,
        y: transform.y,
        rotation: transform.rotation,
        sx: transform.sx,
        sy: transform.sy,
        ox: transform.ox,
        oy: transform.oy,
    });
    Ok(())
}

fn queue_draw_mesh(
    st: &mut SharedState,
    key: MeshKey,
    transform: RenderDrawTransform,
) -> LuaResult<()> {
    if !st.meshes.contains_key(key) {
        return Err(LuaError::RuntimeError(
            "lurek.render.draw: mesh handle is not valid".into(),
        ));
    }
    st.render_commands.push(RenderCommand::DrawMesh {
        mesh_key: key,
        x: transform.x,
        y: transform.y,
        rotation: transform.rotation,
        sx: transform.sx,
        sy: transform.sy,
        ox: transform.ox,
        oy: transform.oy,
    });
    Ok(())
}

fn queue_render_draw(st: &mut SharedState, args: LuaMultiValue) -> LuaResult<()> {
    let mut args_iter = args.iter();
    let drawable = args_iter.next().cloned().unwrap_or(LuaValue::Nil);
    let transform = RenderDrawTransform::from_values(&mut args_iter);
    match &drawable {
        LuaValue::UserData(ud) => {
            if let Ok(img) = ud.borrow::<LuaImage>() {
                let key = img.key;
                drop(img);
                return queue_draw_image(st, key, transform);
            }
            if let Ok(canvas) = ud.borrow::<LuaCanvas>() {
                let key = canvas.key;
                drop(canvas);
                return queue_draw_canvas(st, key, transform);
            }
            if let Ok(batch) = ud.borrow::<LuaSpriteBatch>() {
                let key = batch.key;
                drop(batch);
                return queue_sprite_batch_draw(st, key, "lurek.render.draw");
            }
            if let Ok(mesh) = ud.borrow::<LuaMesh>() {
                let key = mesh.key;
                drop(mesh);
                return queue_draw_mesh(st, key, transform);
            }
            Err(LuaError::RuntimeError(
                "lurek.render.draw: expected Image, Canvas, SpriteBatch, or Mesh".into(),
            ))
        }
        LuaValue::Nil => Err(LuaError::RuntimeError(
            "lurek.render.draw: drawable cannot be nil".into(),
        )),
        _ => Err(LuaError::RuntimeError(
            "lurek.render.draw: unsupported drawable type".into(),
        )),
    }
}

fn parse_blend_mode_or_default(mode: &str) -> BlendMode {
    match mode {
        "add" => BlendMode::Add,
        "multiply" => BlendMode::Multiply,
        "replace" => BlendMode::Replace,
        "screen" => BlendMode::Screen,
        _ => BlendMode::Alpha,
    }
}

fn blend_mode_name(mode: BlendMode) -> &'static str {
    match mode {
        BlendMode::Alpha => "alpha",
        BlendMode::Add => "add",
        BlendMode::Multiply => "multiply",
        BlendMode::Replace => "replace",
        BlendMode::Screen => "screen",
    }
}

fn queue_draw_many(st: &mut SharedState, list: LuaTable) -> LuaResult<()> {
    let len = list.raw_len();
    for i in 1..=len {
        let entry: LuaTable = match list.raw_get(i) {
            Ok(LuaValue::Table(t)) => t,
            _ => continue,
        };
        let img_val: LuaValue = entry.raw_get(1).unwrap_or(LuaValue::Nil);
        let transform = draw_many_transform(&entry);
        if let LuaValue::UserData(ud) = img_val {
            if let Ok(img) = ud.borrow::<LuaImage>() {
                let key = img.key;
                drop(img);
                if st.textures.contains_key(key) {
                    queue_draw_image(st, key, transform)?;
                }
            }
        }
    }
    Ok(())
}

fn draw_many_number(entry: &LuaTable, index: i64, default: f32) -> f32 {
    entry
        .raw_get::<_, Option<f32>>(index)
        .unwrap_or(None)
        .unwrap_or(default)
}

fn draw_many_transform(entry: &LuaTable) -> RenderDrawTransform {
    RenderDrawTransform {
        x: draw_many_number(entry, 2, 0.0),
        y: draw_many_number(entry, 3, 0.0),
        rotation: draw_many_number(entry, 4, 0.0),
        sx: draw_many_number(entry, 5, 1.0),
        sy: draw_many_number(entry, 6, 1.0),
        ox: draw_many_number(entry, 7, 0.0),
        oy: draw_many_number(entry, 8, 0.0),
    }
}

fn centered_text_origin(
    st: &SharedState,
    font_key: FontKey,
    text: &str,
    scale: f32,
) -> LuaResult<(f32, f32)> {
    let Some(font) = st.fonts.get(font_key) else {
        return Err(LuaError::RuntimeError(
            "lurek.render.printRotatedWithFont: font handle is not valid or was released".into(),
        ));
    };
    Ok((
        font.text_width(text) * scale * 0.5,
        font.line_height() * scale * 0.5,
    ))
}

struct RotatedTextCommand {
    font_key: FontKey,
    text: String,
    x: f32,
    y: f32,
    angle: f32,
    scale: f32,
    origin_x: f32,
    origin_y: f32,
}

fn queue_rotated_text(st: &mut SharedState, command: RotatedTextCommand) {
    st.render_commands.push(RenderCommand::PrintTransformed {
        font_key: command.font_key,
        text: command.text,
        x: command.x,
        y: command.y,
        rotation: command.angle,
        sx: 1.0,
        sy: 1.0,
        ox: command.origin_x,
        oy: command.origin_y,
        scale: command.scale,
    });
}

fn queue_print(st: &mut SharedState, font_key: FontKey, text: String, x: f32, y: f32, scale: f32) {
    st.render_commands.push(RenderCommand::Print {
        font_key,
        text,
        x,
        y,
        scale,
    });
}

fn queue_draw_text(
    st: &mut SharedState,
    font_key: FontKey,
    text: String,
    transform: RenderDrawTransform,
) {
    st.render_commands.push(RenderCommand::PrintTransformed {
        font_key,
        text,
        x: transform.x,
        y: transform.y,
        rotation: transform.rotation,
        sx: transform.sx,
        sy: transform.sy,
        ox: transform.ox,
        oy: transform.oy,
        scale: 1.0,
    });
}

fn parse_text_align(align: Option<&str>) -> TextAlign {
    match align {
        Some("center") => TextAlign::Center,
        Some("right") => TextAlign::Right,
        Some("justify") => TextAlign::Justify,
        _ => TextAlign::Left,
    }
}

/// Create one render texture from a GameFS path or CPU-owned image data.
///
/// Both the canonical `newTexture` constructor and its `newImage` compatibility
/// alias use this one conversion path so path policy, color-space validation,
/// and release bookkeeping remain identical during the migration.
fn create_texture_from_args(
    state: &Rc<RefCell<SharedState>>,
    args: LuaMultiValue,
    api: &str,
) -> LuaResult<LuaImage> {
    let mut iter = args.into_iter();
    let arg = iter.next().ok_or_else(|| {
        LuaError::RuntimeError(format!("{api}: expected a file path string or ImageData"))
    })?;
    let color_space = match iter.next() {
        Some(LuaValue::String(mode)) => {
            let mode = mode.to_str().map_err(|error| {
                LuaError::RuntimeError(format!("{api}: invalid color space string: {error}"))
            })?;
            Texture::parse_color_space(mode).ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "{api}: invalid color space '{mode}', expected 'srgb' or 'linear'"
                ))
            })?
        }
        Some(other) => {
            return Err(LuaError::RuntimeError(format!(
                "{api}: second argument must be color space string, got {}",
                other.type_name()
            )));
        }
        None => TextureColorSpace::Srgb,
    };
    match arg {
        LuaValue::String(path_str) => {
            let path = path_str
                .to_str()
                .map_err(|error| LuaError::RuntimeError(format!("{api}: invalid path: {error}")))?;
            let mut runtime = state.borrow_mut();
            let full_path = runtime
                .fs
                .resolve_read_path(path)
                .map_err(|error| LuaError::RuntimeError(format!("{api}: {error}")))?;
            let texture =
                Texture::load_with_color_space(&full_path, &mut runtime.textures, color_space)
                    .map_err(|error| {
                        LuaError::RuntimeError(format!("{api}: failed to load '{path}': {error}"))
                    })?;
            let texture_bytes = u64::from(texture.width)
                .saturating_mul(u64::from(texture.height))
                .saturating_mul(4);
            if runtime.resource_budget_bytes > 0
                && runtime.resource_memory_stats().total_bytes > runtime.resource_budget_bytes
            {
                runtime.textures.remove(texture.key);
                runtime.texture_last_used.remove(&texture.key);
                return Err(LuaError::RuntimeError(format!(
                    "{api}: texture allocation of {texture_bytes} bytes exceeds the configured resource budget"
                )));
            }
            runtime.clear_released_texture_handle(texture.key.data().as_ffi());
            Ok(LuaImage {
                state: state.clone(),
                key: texture.key,
            })
        }
        LuaValue::UserData(ud) => {
            let image_data = ud.borrow::<ImageData>()?;
            let pixels = image_data.as_bytes().to_vec();
            let (width, height) = image_data.dimensions();
            drop(image_data);
            let texture_bytes = u64::from(width)
                .saturating_mul(u64::from(height))
                .saturating_mul(4);
            let mut runtime = state.borrow_mut();
            if !runtime.can_allocate_public_resource(texture_bytes) {
                return Err(LuaError::RuntimeError(format!(
                    "{api}: texture allocation of {texture_bytes} bytes exceeds the configured resource budget"
                )));
            }
            let texture = Texture::from_rgba_with_color_space(
                width,
                height,
                pixels,
                &mut runtime.textures,
                color_space,
            )
            .map_err(|error| {
                LuaError::RuntimeError(format!("{api}: failed to create from ImageData: {error}"))
            })?;
            runtime.clear_released_texture_handle(texture.key.data().as_ffi());
            Ok(LuaImage {
                state: state.clone(),
                key: texture.key,
            })
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{api}: expected a file path string or ImageData"
        ))),
    }
}

/// Create one sprite-owned batch using a live render texture handle.
///
/// Sprite owns batch semantics and lifetime; render only supplies the shared
/// texture residency table and later instancing backend. The render alias and
/// canonical sprite constructor delegate here to keep their validation equal.
pub(crate) fn create_sprite_batch(
    state: &Rc<RefCell<SharedState>>,
    image: &LuaAnyUserData,
    max: Option<usize>,
    api: &str,
) -> LuaResult<LuaSpriteBatch> {
    let image = image.borrow::<LuaImage>()?;
    let image_key = image.key;
    drop(image);
    let max_entries = max.unwrap_or(1000);
    if max_entries > crate::sprite::limits::SpriteLimits::MAX_BATCH_ENTRIES {
        return Err(LuaError::RuntimeError(format!(
            "{api}: max entries {max_entries} exceeds maximum of {}",
            crate::sprite::limits::SpriteLimits::MAX_BATCH_ENTRIES
        )));
    }
    let mut runtime = state.borrow_mut();
    if !runtime.textures.contains_key(image_key) {
        return Err(LuaError::RuntimeError(format!(
            "{api}: texture handle is not valid"
        )));
    }
    let key = runtime
        .sprite_batches
        .insert(SpriteBatch::new(image_key, max_entries));
    Ok(LuaSpriteBatch {
        state: state.clone(),
        key,
    })
}

fn queue_print_formatted(
    st: &mut SharedState,
    font_key: FontKey,
    text: String,
    x: f32,
    y: f32,
    limit: f32,
    align: TextAlign,
) {
    st.render_commands.push(RenderCommand::PrintFormatted {
        font_key,
        text,
        x,
        y,
        limit,
        align,
        scale: 1.0,
    });
}

fn queue_rich_text(
    st: &mut SharedState,
    font_key: FontKey,
    spans: Vec<crate::render::renderer::TextSpan>,
    x: f32,
    y: f32,
) {
    st.render_commands
        .push(crate::render::renderer::RenderCommand::DrawRichText {
            font_key,
            spans,
            x,
            y,
        });
}

fn queue_rich_text_transformed(
    st: &mut SharedState,
    font_key: FontKey,
    spans: Vec<crate::render::renderer::TextSpan>,
    transform: RenderDrawTransform,
) {
    st.render_commands.push(
        crate::render::renderer::RenderCommand::DrawRichTextTransformed {
            font_key,
            spans,
            x: transform.x,
            y: transform.y,
            rotation: transform.rotation,
            sx: transform.sx,
            sy: transform.sy,
            ox: transform.ox,
            oy: transform.oy,
        },
    );
}

fn parse_new_font_args(args: &LuaMultiValue) -> LuaResult<(Option<u32>, Option<String>, f32)> {
    if let Some(LuaValue::Number(n)) = args.get(0) {
        return Ok((Some((*n).max(1.0) as u32), None, 14.0));
    }
    if let Some(LuaValue::Integer(n)) = args.get(0) {
        return Ok((Some((*n).max(1) as u32), None, 14.0));
    }
    let path = match args.get(0) {
        Some(LuaValue::String(s)) => s
            .to_str()
            .map_err(|e| {
                LuaError::RuntimeError(format!("lurek.render.newFont: invalid path: {}", e))
            })?
            .to_string(),
        _ => {
            return Err(LuaError::RuntimeError(
                "lurek.render.newFont: expected string path or number size".into(),
            ))
        }
    };
    let size = match args.get(1) {
        Some(LuaValue::Number(n)) => *n as f32,
        Some(LuaValue::Integer(n)) => *n as f32,
        _ => 14.0,
    };
    Ok((None, Some(path), size))
}

fn resolve_new_font(
    st: &mut SharedState,
    numeric_size: Option<u32>,
    path: Option<String>,
    size: f32,
) -> LuaResult<FontKey> {
    if let Some(point_size) = numeric_size {
        return builtin_font_key_by_point_size(st, point_size, None).ok_or_else(|| {
            LuaError::RuntimeError("lurek.render.newFont: built-in fonts not loaded".into())
        });
    }
    let path = path
        .ok_or_else(|| LuaError::RuntimeError("lurek.render.newFont: missing font path".into()))?;
    if path == "default" {
        if let Some(key) = builtin_font_key_by_point_size(st, size.max(1.0) as u32, None) {
            return Ok(key);
        }
    }
    if let Some(key) = builtin_font_key_by_name(st, &path) {
        return Ok(key);
    }
    load_font_from_path(st, &path, size)
}

/// Custom vertex mesh for advanced 2D geometry rendering with per-vertex color and UV data.
#[derive(Clone)]
pub struct LuaMesh {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: MeshKey,
}
impl LuaUserData for LuaMesh {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getVertexCount --
        /// Returns the number of vertices in this mesh.
        /// @return | number | Vertex count.
        methods.add_method("getVertexCount", |_, this, ()| {
            let st = this.state.borrow();
            let mesh = st.meshes.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Mesh handle is not valid or was released".into())
            })?;
            Ok(mesh.vertex_count())
        });
        // -- getVertex --
        /// Returns the data for a single vertex by 1-based index.
        /// @param | index | integer | 1-based vertex index.
        /// @return | number, number, number, number, number, number, number, number | x, y, u, v, r, g, b, a.
        methods.add_method("getVertex", |_, this, index: usize| {
            let st = this.state.borrow();
            let mesh = st.meshes.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Mesh handle is not valid or was released".into())
            })?;
            let v = mesh
                .get_vertex(index.wrapping_sub(1))
                .ok_or_else(|| LuaError::RuntimeError("Mesh vertex index out of bounds".into()))?;
            Ok((v.x, v.y, v.u, v.v, v.r, v.g, v.b, v.a))
        });
        // -- setVertex --
        /// Updates a single vertex by 1-based index. Table format: {x, y, u, v, r, g, b, a}.
        /// @param | index | integer | 1-based vertex index.
        /// @param | data | table | Vertex data: {x, y, u, v, r, g, b, a}.
        methods.add_method("setVertex", |_, this, (index, data): (usize, LuaTable)| {
            let mut st = this.state.borrow_mut();
            let mesh = st.meshes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Mesh handle is not valid or was released".into())
            })?;
            let vertex = MeshVertex {
                x: data.get(1).unwrap_or(0.0),
                y: data.get(2).unwrap_or(0.0),
                u: data.get(3).unwrap_or(0.0),
                v: data.get(4).unwrap_or(0.0),
                r: data.get(5).unwrap_or(1.0),
                g: data.get(6).unwrap_or(1.0),
                b: data.get(7).unwrap_or(1.0),
                a: data.get(8).unwrap_or(1.0),
            };
            if !mesh.set_vertex(index.wrapping_sub(1), vertex) {
                return Err(LuaError::RuntimeError(
                    "LMesh:setVertex: mesh vertex index out of bounds".into(),
                ));
            }
            mesh.validate()
                .map_err(|err| LuaError::RuntimeError(format!("LMesh:setVertex: {err}")))?;
            let mesh_clone = mesh.clone();
            st.render_commands.push(RenderCommand::SyncMesh {
                mesh_key: this.key,
                mesh: mesh_clone,
            });
            Ok(())
        });
        // -- setTexture --
        /// Assigns or removes a texture for this mesh. Pass nil to clear the texture.
        /// @param | image | LImage? | Image to use as the mesh texture, or nil to remove.
        methods.add_method("setTexture", |_, this, ud: Option<LuaAnyUserData>| {
            let tex_key = match &ud {
                Some(u) => {
                    let img = u.borrow::<LuaImage>()?;
                    Some(img.key)
                }
                None => None,
            };
            let mut st = this.state.borrow_mut();
            let mesh = st.meshes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Mesh handle is not valid or was released".into())
            })?;
            mesh.set_texture(tex_key);
            Ok(())
        });
        // -- release --
        /// Releases the mesh GPU resource and invalidates the handle.
        /// @return | boolean | True if the mesh was valid and was released.
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            Ok(st.meshes.remove(this.key).is_some())
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Mesh" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMesh" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this mesh object.
        /// @return | string | Always "LMesh".
        methods.add_method("type", |_, _, ()| Ok("LMesh"));
    }
}
/// GPU shader program for custom rendering effects (post-processing, distortion, etc.).
#[derive(Clone)]
pub struct LuaShader {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: ShaderKey,
}
impl LuaUserData for LuaShader {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getId --
        /// Returns the internal numeric handle ID for this shader.
        /// @return | number | Opaque shader handle identifier.
        methods.add_method("getId", |_, this, ()| Ok(this.key.data().as_ffi()));
        // -- getTarget --
        /// Returns the target this shader was validated for.
        /// @return | string | Shader target name.
        methods.add_method("getTarget", |_, this, ()| {
            let st = this.state.borrow();
            let shader = st.shaders.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shader handle is not valid or was released".into())
            })?;
            Ok(shader.target().as_str().to_string())
        });
        // -- send --
        /// Sends a uniform value to this shader by name. Supported types: number, boolean, or table (vec2/vec3/vec4).
        /// @param | name | string | Uniform variable name declared in the shader.
        /// @param | value | number|boolean|table | The value to send.
        methods.add_method("send", |_, this, (name, value): (String, LuaValue)| {
            let mut st = this.state.borrow_mut();
            let shader = st.shaders.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shader handle is not valid or was released".into())
            })?;
            let uv = lua_value_to_uniform(&value)?;
            shader
                .send(name, uv)
                .map_err(|err| LuaError::RuntimeError(format!("LShader:send: {err}")))?;
            Ok(())
        });
        // -- hasUniform --
        /// Checks whether this shader declares a uniform with the given name.
        /// @param | name | string | Uniform name to check.
        /// @return | boolean | True if the uniform exists.
        methods.add_method("hasUniform", |_, this, name: String| {
            let st = this.state.borrow();
            let shader = st.shaders.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shader handle is not valid or was released".into())
            })?;
            Ok(shader.has_uniform(&name))
        });
        // -- getDiagnostics --
        /// Returns shader validation diagnostics.
        /// @return | table | Array of diagnostic strings.
        methods.add_method("getDiagnostics", |lua, this, ()| {
            let st = this.state.borrow();
            let shader = st.shaders.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shader handle is not valid or was released".into())
            })?;
            let table = lua.create_table()?;
            for (index, diagnostic) in shader.diagnostics().iter().enumerate() {
                table.set(index + 1, diagnostic.as_str())?;
            }
            Ok(table)
        });
        // -- release --
        /// Releases the shader resource. If active, the default shader is restored.
        /// @return | boolean | True if the shader was valid and was released.
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if st.shaders.remove(this.key).is_some() {
                if st.active_shader == Some(this.key) {
                    st.active_shader = None;
                }
                if st.active_text_shader == Some(this.key) {
                    st.active_text_shader = None;
                }
                if st.active_debug_shader == Some(this.key) {
                    st.active_debug_shader = None;
                }
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Shader" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LShader" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this shader object.
        /// @return | string | Always "LShader".
        methods.add_method("type", |_, _, ()| Ok("LShader"));
    }
}
/// Extract a live shader key from a Lua shader userdata handle.
pub(crate) fn shader_key_from_userdata(ud: &LuaAnyUserData) -> LuaResult<ShaderKey> {
    let shader = ud.borrow::<LuaShader>()?;
    Ok(shader.key)
}

/// Ensure a shader handle exists and was validated for `expected`.
pub(crate) fn ensure_shader_target(
    state: &SharedState,
    key: ShaderKey,
    expected: ShaderTarget,
    api: &str,
) -> LuaResult<()> {
    let shader = state
        .shaders
        .get(key)
        .ok_or_else(|| LuaError::RuntimeError(format!("{api}: shader handle is not valid")))?;
    if shader.target() != expected {
        return Err(LuaError::RuntimeError(format!(
            "{api}: expected {} shader, got {} shader",
            expected.as_str(),
            shader.target().as_str()
        )));
    }
    Ok(())
}
fn parse_shader_target_opts(opts: Option<LuaTable>) -> LuaResult<ShaderTarget> {
    let Some(opts) = opts else {
        return Ok(ShaderTarget::Draw);
    };
    match opts.get::<_, Option<String>>("target")? {
        Some(target) => ShaderTarget::from_str(&target)
            .map_err(|err| LuaError::RuntimeError(format!("lurek.render.newShader: {err}"))),
        None => Ok(ShaderTarget::Draw),
    }
}
/// Rectangular sub-region of a texture, used for sprite sheets and atlas-based rendering.
#[derive(Clone)]
pub struct LuaQuad {
    /// X coordinate position.
    pub x: f32,
    /// Y coordinate position.
    pub y: f32,
    /// Width in pixels.
    pub w: f32,
    /// Height in pixels.
    pub h: f32,
    /// Source region width in the spritesheet.
    pub sw: f32,
    /// Source region height in the spritesheet.
    pub sh: f32,
}
impl LuaUserData for LuaQuad {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getViewport --
        /// Returns the quad's viewport rectangle within the source texture.
        /// @return | number, number, number, number | x, y, width, height in texture pixels.
        methods.add_method("getViewport", |_, this, ()| {
            Ok((this.x, this.y, this.w, this.h))
        });
        // -- setViewport --
        /// Updates the quad's viewport rectangle.
        /// @param | x | number | Left edge in texture pixels.
        /// @param | y | number | Top edge in texture pixels.
        /// @param | w | number | Width in texture pixels.
        /// @param | h | number | Height in texture pixels.
        methods.add_method_mut(
            "setViewport",
            |_, this, (x, y, w, h): (f32, f32, f32, f32)| {
                this.x = x;
                this.y = y;
                this.w = w;
                this.h = h;
                Ok(())
            },
        );
        // -- getTextureDimensions --
        /// Returns the full dimensions of the source texture this quad references.
        /// @return | number, number | Source texture width and height.
        methods.add_method("getTextureDimensions", |_, this, ()| Ok((this.sw, this.sh)));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Quad" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LQuad" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this quad object.
        /// @return | string | Always "LQuad".
        methods.add_method("type", |_, _, ()| Ok("LQuad"));
    }
}
/// Converts a Lua scalar or numeric table into a shader uniform payload supported by the renderer.
fn lua_value_to_uniform(v: &LuaValue) -> LuaResult<UniformValue> {
    match v {
        LuaValue::Number(n) => Ok(UniformValue::Float(*n as f32)),
        LuaValue::Integer(n) => Ok(UniformValue::Int(*n as i32)),
        LuaValue::Boolean(b) => Ok(UniformValue::Bool(*b)),
        LuaValue::Table(t) => {
            let len = t.raw_len();
            match len {
                2 => {
                    let a: f32 = t.get(1)?;
                    let b: f32 = t.get(2)?;
                    Ok(UniformValue::Vec2([a, b]))
                }
                3 => {
                    let a: f32 = t.get(1)?;
                    let b: f32 = t.get(2)?;
                    let c: f32 = t.get(3)?;
                    Ok(UniformValue::Vec3([a, b, c]))
                }
                4 => {
                    let a: f32 = t.get(1)?;
                    let b: f32 = t.get(2)?;
                    let c: f32 = t.get(3)?;
                    let d: f32 = t.get(4)?;
                    Ok(UniformValue::Vec4([a, b, c, d]))
                }
                _ => Err(LuaError::RuntimeError(
                    "Uniform table must have 2, 3, or 4 elements".into(),
                )),
            }
        }
        _ => Err(LuaError::RuntimeError(
            "Uniform value must be a number, boolean, or table".into(),
        )),
    }
}
/// Parses a Lua shape draw mode string into the renderer draw mode enum.
fn parse_draw_mode(mode: &str) -> Result<DrawMode, LuaError> {
    match mode {
        "fill" => Ok(DrawMode::Fill),
        "line" => Ok(DrawMode::Line),
        other => Err(LuaError::RuntimeError(format!(
            "unknown draw mode: '{other}'"
        ))),
    }
}

/// Parse the closed set of path fill winding rules exposed by the Lua API.
fn parse_fill_rule(rule: &str, api: &str) -> LuaResult<FillRule> {
    match rule.to_ascii_lowercase().as_str() {
        "nonzero" | "non-zero" | "winding" => Ok(FillRule::NonZero),
        "evenodd" | "even-odd" | "odd" => Ok(FillRule::EvenOdd),
        other => Err(LuaError::RuntimeError(format!(
            "{api}: fillRule must be 'nonzero' or 'evenodd', got '{other}'"
        ))),
    }
}

fn validate_shape_finite(api: &str, values: &[f32]) -> LuaResult<()> {
    if values.iter().any(|value| !value.is_finite()) {
        return Err(LuaError::RuntimeError(format!(
            "{api}: coordinates and dimensions must be finite"
        )));
    }
    Ok(())
}

fn validate_shape_non_negative(api: &str, field: &str, value: f32) -> LuaResult<()> {
    if !value.is_finite() || value < 0.0 {
        return Err(LuaError::RuntimeError(format!(
            "{api}: {field} must be finite and non-negative"
        )));
    }
    Ok(())
}

fn parse_shape_rgba<'lua>(value: LuaValue<'lua>, api: &str, field: &str) -> LuaResult<[f32; 4]> {
    let table = match value {
        LuaValue::Table(table) => table,
        _ => {
            return Err(LuaError::RuntimeError(format!(
                "{api}: {field} must be an array table"
            )))
        }
    };
    let len = table.raw_len();
    if len != 3 && len != 4 {
        return Err(LuaError::RuntimeError(format!(
            "{api}: {field} must contain 3 or 4 channels"
        )));
    }
    let mut color = [1.0; 4];
    for index in 1..=len {
        let value: f32 = table.get(index).map_err(|_| {
            LuaError::RuntimeError(format!("{api}: {field}[{index}] must be a number"))
        })?;
        if !value.is_finite() || !(0.0..=1.0).contains(&value) {
            return Err(LuaError::RuntimeError(format!(
                "{api}: {field}[{index}] must be finite and within 0..1"
            )));
        }
        color[index - 1] = value;
    }
    if len == 3 {
        color[3] = 1.0;
    }
    Ok(color)
}

fn parse_shape_stroke_style(opts: Option<&LuaTable>, api: &str) -> LuaResult<StrokeStyle> {
    let Some(opts) = opts else {
        return Ok(StrokeStyle::default());
    };
    let width = opts.get::<_, Option<f32>>("width")?.unwrap_or(1.0);
    let miter_limit = opts.get::<_, Option<f32>>("miterLimit")?.unwrap_or(4.0);
    let dash_offset = opts.get::<_, Option<f32>>("dashOffset")?.unwrap_or(0.0);
    if !width.is_finite() || width < 0.0 || !miter_limit.is_finite() || miter_limit <= 0.0 {
        return Err(LuaError::RuntimeError(format!(
            "{api}: stroke width must be finite >= 0 and miterLimit must be positive"
        )));
    }
    if !dash_offset.is_finite() {
        return Err(LuaError::RuntimeError(format!(
            "{api}: dashOffset must be finite"
        )));
    }
    let cap = match opts
        .get::<_, Option<String>>("cap")?
        .unwrap_or_else(|| "butt".to_string())
        .as_str()
    {
        "butt" => StrokeCap::Butt,
        "round" => StrokeCap::Round,
        "square" => StrokeCap::Square,
        other => {
            return Err(LuaError::RuntimeError(format!(
                "{api}: unknown stroke cap '{other}'"
            )))
        }
    };
    let join = match opts
        .get::<_, Option<String>>("join")?
        .unwrap_or_else(|| "miter".to_string())
        .as_str()
    {
        "miter" => StrokeJoin::Miter,
        "round" => StrokeJoin::Round,
        "bevel" => StrokeJoin::Bevel,
        other => {
            return Err(LuaError::RuntimeError(format!(
                "{api}: unknown stroke join '{other}'"
            )))
        }
    };
    let dash = match opts.get::<_, LuaValue>("dash")? {
        LuaValue::Nil => Vec::new(),
        LuaValue::Table(table) => {
            let mut values = Vec::with_capacity(table.raw_len());
            for index in 1..=table.raw_len() {
                let value: f32 = table.get(index).map_err(|_| {
                    LuaError::RuntimeError(format!("{api}: dash values must be numbers"))
                })?;
                if !value.is_finite() || value < 0.0 {
                    return Err(LuaError::RuntimeError(format!(
                        "{api}: dash values must be finite and non-negative"
                    )));
                }
                values.push(value);
            }
            if values.len() % 2 != 0 {
                values.push(values.last().copied().unwrap_or(1.0));
            }
            values
        }
        _ => {
            return Err(LuaError::RuntimeError(format!(
                "{api}: dash must be an array table"
            )))
        }
    };
    Ok(StrokeStyle {
        width,
        cap,
        join,
        miter_limit,
        dash,
        dash_offset,
    })
}

fn parse_path_segments(table: LuaTable, api: &str) -> LuaResult<(Vec<PathSegment>, bool)> {
    let count = table.raw_len();
    if count == 0 || count > 4096 {
        return Err(LuaError::RuntimeError(format!(
            "{api}: segments must contain 1..4096 entries"
        )));
    }
    let mut segments = Vec::with_capacity(count);
    let mut subpath_start: Option<[f32; 2]> = None;
    let mut has_close_verb = false;
    for index in 1..=count {
        let entry: LuaTable = table.get(index).map_err(|_| {
            LuaError::RuntimeError(format!("{api}: segment {index} must be a table"))
        })?;
        let verb = entry
            .get::<_, Option<String>>("verb")?
            .or(entry.get::<_, Option<String>>("type")?)
            .or_else(|| entry.get::<_, Option<String>>(1).ok().flatten())
            .ok_or_else(|| {
                LuaError::RuntimeError(format!("{api}: segment {index} is missing verb"))
            })?;
        let number = |name: &str, positional: i64| -> LuaResult<f32> {
            let value = entry
                .get::<_, Option<f32>>(name)?
                .or_else(|| entry.get::<_, Option<f32>>(positional).ok().flatten())
                .ok_or_else(|| {
                    LuaError::RuntimeError(format!("{api}: segment {index} is missing {name}"))
                })?;
            if !value.is_finite() {
                return Err(LuaError::RuntimeError(format!(
                    "{api}: segment {index}.{name} must be finite"
                )));
            }
            Ok(value)
        };
        if matches!(verb.as_str(), "close" | "closePath") {
            has_close_verb = true;
            let [x, y] = subpath_start.ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "{api}: segment {index} close requires a preceding moveTo"
                ))
            })?;
            segments.push(PathSegment::LineTo { x, y });
            continue;
        }
        if subpath_start.is_none() && !matches!(verb.as_str(), "moveTo" | "move") {
            return Err(LuaError::RuntimeError(format!(
                "{api}: segment {index} must start a subpath with moveTo"
            )));
        }
        let segment = match verb.as_str() {
            "moveTo" | "move" => PathSegment::MoveTo {
                x: number("x", 2)?,
                y: number("y", 3)?,
            },
            "lineTo" | "line" => PathSegment::LineTo {
                x: number("x", 2)?,
                y: number("y", 3)?,
            },
            "quadTo" | "quad" => PathSegment::QuadTo {
                cx: number("cx", 2)?,
                cy: number("cy", 3)?,
                x: number("x", 4)?,
                y: number("y", 5)?,
            },
            "cubicTo" | "cubic" => PathSegment::CubicTo {
                cx1: number("cx1", 2)?,
                cy1: number("cy1", 3)?,
                cx2: number("cx2", 4)?,
                cy2: number("cy2", 5)?,
                x: number("x", 6)?,
                y: number("y", 7)?,
            },
            other => {
                return Err(LuaError::RuntimeError(format!(
                    "{api}: unknown path verb '{other}'"
                )))
            }
        };
        if let PathSegment::MoveTo { x, y } = &segment {
            subpath_start = Some([*x, *y]);
        }
        segments.push(segment);
    }
    Ok((segments, has_close_verb))
}

fn parse_shape_transform(opts: Option<&LuaTable>, api: &str) -> LuaResult<crate::math::Mat3> {
    let Some(opts) = opts else {
        return Ok(crate::math::Mat3::identity());
    };
    let number = |name: &str, default: f32| -> LuaResult<f32> {
        let value = opts.get::<_, Option<f32>>(name)?.unwrap_or(default);
        if !value.is_finite() {
            return Err(LuaError::RuntimeError(format!(
                "{api}: transform.{name} must be finite"
            )));
        }
        Ok(value)
    };
    Ok(crate::math::Mat3::from_translation(crate::math::Vec2 {
        x: number("x", 0.0)?,
        y: number("y", 0.0)?,
    }) * crate::math::Mat3::from_rotation(number("rotation", 0.0)?)
        * crate::math::Mat3::from_scale(crate::math::Vec2 {
            x: number("sx", 1.0)?,
            y: number("sy", 1.0)?,
        })
        * crate::math::Mat3::from_translation(crate::math::Vec2 {
            x: -number("ox", 0.0)?,
            y: -number("oy", 0.0)?,
        }))
}

fn parse_shape_instance(table: LuaTable, api: &str) -> LuaResult<ShapeInstance> {
    let number = |name: &str, default: f32| -> LuaResult<f32> {
        let value = table.get::<_, Option<f32>>(name)?.unwrap_or(default);
        if !value.is_finite() {
            return Err(LuaError::RuntimeError(format!(
                "{api}: instance.{name} must be finite"
            )));
        }
        Ok(value)
    };
    let tint = match table.get::<_, LuaValue>("tint")? {
        LuaValue::Nil => [1.0, 1.0, 1.0, 1.0],
        value => parse_shape_rgba(value, api, "instance.tint")?,
    };
    Ok(ShapeInstance {
        x: number("x", 0.0)?,
        y: number("y", 0.0)?,
        rotation: number("rotation", 0.0)?,
        sx: number("sx", 1.0)?,
        sy: number("sy", 1.0)?,
        ox: number("ox", 0.0)?,
        oy: number("oy", 0.0)?,
        tint,
    })
}

/// Snapshot child role colours when composing a shape.  The child handle may
/// be mutated or released later, so the parent must not retain role lookups
/// into the child's mutable palette.
fn snapshot_shape_commands(commands: &[ShapeCommand]) -> Vec<ShapeCommand> {
    commands
        .iter()
        .map(|command| match command {
            ShapeCommand::Transformed {
                commands,
                transform,
                palette: child_palette,
            } => ShapeCommand::Transformed {
                commands: snapshot_shape_commands(commands),
                transform: *transform,
                palette: *child_palette,
            },
            other => other.clone(),
        })
        .collect()
}
/// Parses a Lua blend mode string into the renderer blend mode enum.
fn parse_blend_mode(s: &str) -> Result<BlendMode, LuaError> {
    match s {
        "alpha" => Ok(BlendMode::Alpha),
        "add" | "additive" => Ok(BlendMode::Add),
        "multiply" => Ok(BlendMode::Multiply),
        "replace" | "none" => Ok(BlendMode::Replace),
        "screen" => Ok(BlendMode::Screen),
        other => Err(LuaError::RuntimeError(format!(
            "unknown blend mode: '{other}'"
        ))),
    }
}
/// Retained compound shape that accumulates drawing commands and can be rendered in one call.
#[derive(Clone)]
pub struct LuaShape {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: ShapeKey,
}
impl LuaUserData for LuaShape {
    #[allow(clippy::type_complexity)]
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getCommandCount --
        /// Returns the number of drawing commands accumulated in this shape.
        /// @return | number | Command count.
        methods.add_method("getCommandCount", |_, this, ()| {
            let st = this.state.borrow();
            let shape = st.shapes.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            Ok(shape.command_count() as i64)
        });
        // -- clear --
        /// Removes all drawing commands from this shape, making it empty.
        methods.add_method("clear", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.clear();
            Ok(())
        });
        // -- setColor --
        /// Sets the drawing color for subsequent shape commands.
        /// @param | r | number | Red channel (0â€“1).
        /// @param | g | number | Green channel (0â€“1).
        /// @param | b | number | Blue channel (0â€“1).
        /// @param | a | number? | Alpha channel (0â€“1, default 1).
        methods.add_method(
            "setColor",
            |_, this, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
                let color = [r, g, b, a.unwrap_or(1.0)];
                crate::render::shape::validate_color(color, "setColor")
                    .map_err(LuaError::RuntimeError)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::SetColor(
                    color[0], color[1], color[2], color[3],
                ));
                Ok(())
            },
        );
        // -- setLineWidth --
        /// Sets the line width for subsequent line-mode shape commands.
        /// @param | w | number | Line width in pixels.
        methods.add_method("setLineWidth", |_, this, w: f32| {
            if !w.is_finite() || w <= 0.0 {
                return Err(LuaError::RuntimeError(
                    "setLineWidth: width must be finite and positive".into(),
                ));
            }
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.current_line_width = w;
            shape.push_command(ShapeCommand::SetLineWidth(w));
            Ok(())
        });
        // -- setPalette --
        /// Replaces one or more semantic palette roles with normalized RGBA colors.
        /// @param | palette | table | Keys are background/primary/secondary/accent/outline/highlight/shadow/emissive.
        methods.add_method("setPalette", |_, this, palette: LuaTable| {
            let mut updates = Vec::new();
            for pair in palette.pairs::<String, LuaValue>() {
                let (role, value) = pair?;
                if role_index(&role).is_none() {
                    return Err(LuaError::RuntimeError(format!(
                        "setPalette: unknown palette role '{role}'"
                    )));
                }
                updates.push((role.clone(), parse_shape_rgba(value, "setPalette", &role)?));
            }
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            for (role, color) in updates {
                shape
                    .set_palette_role(&role, color)
                    .map_err(LuaError::RuntimeError)?;
            }
            Ok(())
        });
        // -- setColorRole --
        /// Selects a semantic palette role for subsequent commands.
        /// @param | role | string | Semantic palette role name.
        methods.add_method("setColorRole", |_, this, role: String| {
            if role_index(&role).is_none() {
                return Err(LuaError::RuntimeError(format!(
                    "setColorRole: unknown palette role '{role}'"
                )));
            }
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.push_command(ShapeCommand::SetColorRole(role));
            Ok(())
        });
        // -- setStrokeStyle --
        /// Sets cap, join, miter and dash parameters for subsequent stroke commands.
        /// @param | opts | table | Stroke width, cap, join, miter and dash options.
        methods.add_method("setStrokeStyle", |_, this, opts: LuaTable| {
            let style = parse_shape_stroke_style(Some(&opts), "setStrokeStyle")?;
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.current_line_width = style.width;
            shape.current_stroke_style = style.clone();
            shape.push_command(ShapeCommand::SetStrokeStyle(style));
            Ok(())
        });
        // -- rectangle --
        /// Adds a rectangle command to the shape.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Left edge X.
        /// @param | y | number | Top edge Y.
        /// @param | w | number | Width.
        /// @param | h | number | Height.
        methods.add_method(
            "rectangle",
            |_, this, (mode, x, y, w, h): (String, f32, f32, f32, f32)| {
                let dm = parse_draw_mode(&mode)?;
                validate_shape_finite("LShape:rectangle", &[x, y, w, h])?;
                validate_shape_non_negative("LShape:rectangle", "w", w)?;
                validate_shape_non_negative("LShape:rectangle", "h", h)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Rectangle {
                    mode: dm,
                    x,
                    y,
                    w,
                    h,
                });
                Ok(())
            },
        );
        // -- roundedRectangle --
        /// Adds a rounded rectangle command to the shape.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Left edge X.
        /// @param | y | number | Top edge Y.
        /// @param | w | number | Width.
        /// @param | h | number | Height.
        /// @param | rx | number | Horizontal corner radius.
        /// @param | ry | number? | Vertical corner radius (defaults to rx).
        methods.add_method("roundedRectangle", |_, this, (mode, x, y, w, h, rx, ry): (String, f32, f32, f32, f32, f32, Option<f32>)| {
                let dm = parse_draw_mode(&mode)?;
                let ry = ry.unwrap_or(rx);
                validate_shape_finite("LShape:roundedRectangle", &[x, y, w, h, rx, ry])?;
                validate_shape_non_negative("LShape:roundedRectangle", "w", w)?;
                validate_shape_non_negative("LShape:roundedRectangle", "h", h)?;
                validate_shape_non_negative("LShape:roundedRectangle", "rx", rx)?;
                validate_shape_non_negative("LShape:roundedRectangle", "ry", ry)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::RoundedRectangle { mode: dm, x, y, w, h, rx, ry });
                Ok(())
            },
        );
        // -- circle --
        /// Adds a filled or outlined circle command to the shape.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | r | number | Radius.
        methods.add_method(
            "circle",
            |_, this, (mode, x, y, r): (String, f32, f32, f32)| {
                let dm = parse_draw_mode(&mode)?;
                validate_shape_finite("LShape:circle", &[x, y, r])?;
                validate_shape_non_negative("LShape:circle", "r", r)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Circle { mode: dm, x, y, r });
                Ok(())
            },
        );
        // -- ellipse --
        /// Adds an ellipse command to the shape.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | rx | number | Horizontal radius.
        /// @param | ry | number | Vertical radius.
        methods.add_method(
            "ellipse",
            |_, this, (mode, x, y, rx, ry): (String, f32, f32, f32, f32)| {
                let dm = parse_draw_mode(&mode)?;
                validate_shape_finite("LShape:ellipse", &[x, y, rx, ry])?;
                validate_shape_non_negative("LShape:ellipse", "rx", rx)?;
                validate_shape_non_negative("LShape:ellipse", "ry", ry)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Ellipse {
                    mode: dm,
                    x,
                    y,
                    rx,
                    ry,
                });
                Ok(())
            },
        );
        // -- triangle --
        /// Adds a triangle command to the shape.
        /// @param | mode | string | "fill" or "line".
        /// @param | x1 | number | First vertex X.
        /// @param | y1 | number | First vertex Y.
        /// @param | x2 | number | Second vertex X.
        /// @param | y2 | number | Second vertex Y.
        /// @param | x3 | number | Third vertex X.
        /// @param | y3 | number | Third vertex Y.
        methods.add_method(
            "triangle",
            |_, this, (mode, x1, y1, x2, y2, x3, y3): (String, f32, f32, f32, f32, f32, f32)| {
                let dm = parse_draw_mode(&mode)?;
                validate_shape_finite("LShape:triangle", &[x1, y1, x2, y2, x3, y3])?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Triangle {
                    mode: dm,
                    x1,
                    y1,
                    x2,
                    y2,
                    x3,
                    y3,
                });
                Ok(())
            },
        );
        // -- polygon --
        /// Adds a polygon command to the shape from a flat list of x,y coordinate pairs.
        /// @param | mode | string | "fill" or "line".
        /// @param | ... | number | Flat coordinate values: x1, y1, x2, y2, ... (minimum 3 vertices / 6 values).
        methods.add_method(
            "polygon",
            |_, this, (mode, coords): (String, mlua::Variadic<f32>)| {
                let vertices: Vec<f32> = coords.into_iter().collect();
                if vertices.len() < 6 {
                    return Err(LuaError::RuntimeError(
                        "polygon requires at least 3 vertices (6 coordinate values)".into(),
                    ));
                }
                validate_shape_finite("LShape:polygon", &vertices)?;
                let dm = parse_draw_mode(&mode)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Polygon { mode: dm, vertices });
                Ok(())
            },
        );
        // -- line --
        /// Adds a line segment command to the shape.
        /// @param | x1 | number | Start X.
        /// @param | y1 | number | Start Y.
        /// @param | x2 | number | End X.
        /// @param | y2 | number | End Y.
        methods.add_method("line", |_, this, (x1, y1, x2, y2): (f32, f32, f32, f32)| {
            validate_shape_finite("LShape:line", &[x1, y1, x2, y2])?;
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.push_command(ShapeCommand::Line { x1, y1, x2, y2 });
            Ok(())
        });
        // -- polyline --
        /// Adds a connected polyline command to the shape from a flat list of x,y coordinate pairs.
        /// @param | ... | number | Flat coordinate values: x1, y1, x2, y2, ... (minimum 2 points / 4 values).
        methods.add_method("polyline", |_, this, coords: mlua::Variadic<f32>| {
            let points: Vec<f32> = coords.into_iter().collect();
            if points.len() < 4 {
                return Err(LuaError::RuntimeError(
                    "polyline requires at least 2 points (4 coordinate values)".into(),
                ));
            }
            validate_shape_finite("LShape:polyline", &points)?;
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.push_command(ShapeCommand::Polyline { points });
            Ok(())
        });
        // -- arc --
        /// Adds a filled or outlined arc command to the shape.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | r | number | Radius.
        /// @param | astart | number | Start angle in radians.
        /// @param | aend | number | End angle in radians.
        /// @param | segments | number? | Number of arc segments (default 32).
        methods.add_method(
            "arc",
            |_,
             this,
             (mode, x, y, r, astart, aend, segments): (
                String,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<u32>,
            )| {
                let dm = parse_draw_mode(&mode)?;
                validate_shape_finite("LShape:arc", &[x, y, r, astart, aend])?;
                validate_shape_non_negative("LShape:arc", "r", r)?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Arc {
                    mode: dm,
                    x,
                    y,
                    radius: r,
                    angle1: astart,
                    angle2: aend,
                    segments: segments.unwrap_or(32),
                });
                Ok(())
            },
        );
        // -- point --
        /// Adds one point or disc primitive to the shape.
        /// @param | x | number | Point center X.
        /// @param | y | number | Point center Y.
        /// @param | size | number? | Point diameter (default 1).
        methods.add_method("point", |_, this, (x, y, size): (f32, f32, Option<f32>)| {
            let size = size.unwrap_or(1.0);
            if !x.is_finite() || !y.is_finite() || !size.is_finite() || size < 0.0 {
                return Err(LuaError::RuntimeError(
                    "point: coordinates must be finite and size non-negative".into(),
                ));
            }
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.push_command(ShapeCommand::Point { x, y, size });
            Ok(())
        });
        // -- points --
        /// Adds many point/disc primitives from flat coordinates or `{x,y}` pairs.
        methods.add_method("points", |lua, this, args: mlua::MultiValue| {
            let mut args = args.into_iter();
            let first = args
                .next()
                .ok_or_else(|| LuaError::RuntimeError("points: expected coordinates".into()))?;
            let (points, size) = match first {
                LuaValue::Table(table) => {
                    let mut points = Vec::new();
                    let first_entry: LuaValue = table.get(1)?;
                    if matches!(first_entry, LuaValue::Table(_)) {
                        for index in 1..=table.raw_len() {
                            let entry: LuaTable = table.get(index).map_err(|_| {
                                LuaError::RuntimeError("points: pair entries must be tables".into())
                            })?;
                            let x = entry
                                .get::<_, Option<f32>>("x")?
                                .or_else(|| entry.get::<_, Option<f32>>(1).ok().flatten())
                                .ok_or_else(|| {
                                    LuaError::RuntimeError(
                                        "points: each pair needs an x coordinate".into(),
                                    )
                                })?;
                            let y = entry
                                .get::<_, Option<f32>>("y")?
                                .or_else(|| entry.get::<_, Option<f32>>(2).ok().flatten())
                                .ok_or_else(|| {
                                    LuaError::RuntimeError(
                                        "points: each pair needs a y coordinate".into(),
                                    )
                                })?;
                            points.extend([x, y]);
                        }
                    } else {
                        for index in 1..=table.raw_len() {
                            points.push(table.get::<_, f32>(index).map_err(|_| {
                                LuaError::RuntimeError(
                                    "points: flat coordinates must be numbers".into(),
                                )
                            })?);
                        }
                    }
                    let size = match args.next() {
                        None => 1.0,
                        Some(value) => f32::from_lua(value, lua).map_err(|_| {
                            LuaError::RuntimeError("points: size must be a number".into())
                        })?,
                    };
                    if args.next().is_some() {
                        return Err(LuaError::RuntimeError(
                            "points: expected one optional size after coordinates".into(),
                        ));
                    }
                    (points, size)
                }
                value => {
                    let mut values = vec![f32::from_lua(value, lua).map_err(|_| {
                        LuaError::RuntimeError("points: coordinates must be numbers".into())
                    })?];
                    for value in args {
                        values.push(f32::from_lua(value, lua).map_err(|_| {
                            LuaError::RuntimeError("points: coordinates must be numbers".into())
                        })?);
                    }
                    let size = if values.len() % 2 == 1 {
                        values.pop().unwrap_or(1.0)
                    } else {
                        1.0
                    };
                    (values, size)
                }
            };
            if points.len() < 2 || points.len() % 2 != 0 || points.iter().any(|v| !v.is_finite()) {
                return Err(LuaError::RuntimeError(
                    "points: expected an even, finite coordinate list".into(),
                ));
            }
            if !size.is_finite() || size < 0.0 {
                return Err(LuaError::RuntimeError(
                    "points: size must be finite and non-negative".into(),
                ));
            }
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.push_command(ShapeCommand::Points { points, size });
            Ok(())
        });
        // -- path --
        /// Adds a native path with move, line, quadratic, cubic, and close verbs.
        /// @param | segments | table | Path segment records.
        /// @param | opts | table? | Fill, close and stroke options.
        methods.add_method(
            "path",
            |_, this, (segments, opts): (LuaTable, Option<LuaTable>)| {
                let api = "LShape:path";
                let (segments, has_close_verb) = parse_path_segments(segments, api)?;
                let mode = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<String>>("mode"))
                    .transpose()?
                    .flatten()
                    .map(|value| parse_draw_mode(&value))
                    .transpose()?
                    .unwrap_or(DrawMode::Fill);
                let close = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<bool>>("close"))
                    .transpose()?
                    .flatten()
                    .unwrap_or(has_close_verb);
                let fill_rule_name = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<String>>("fillRule"))
                    .transpose()?
                    .flatten();
                let fill_rule =
                    parse_fill_rule(fill_rule_name.as_deref().unwrap_or("nonzero"), api)?;
                let stroke_opts = opts
                    .as_ref()
                    .map(|table| table.get::<_, Option<LuaTable>>("stroke"))
                    .transpose()?
                    .flatten();
                let direct_stroke = opts.as_ref().filter(|table| {
                    ["width", "cap", "join", "miterLimit", "dash", "dashOffset"]
                        .iter()
                        .any(|key| table.contains_key(*key).unwrap_or(false))
                });
                let stroke = stroke_opts
                    .as_ref()
                    .map(|table| parse_shape_stroke_style(Some(table), api))
                    .or_else(|| {
                        direct_stroke.map(|table| parse_shape_stroke_style(Some(table), api))
                    })
                    .transpose()?;
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                let stroke = stroke.unwrap_or_else(|| shape.current_stroke_style.clone());
                shape.push_command(ShapeCommand::Path {
                    segments,
                    mode,
                    close,
                    fill_rule,
                    stroke,
                });
                Ok(())
            },
        );
        // -- regularPolygon --
        /// Adds a regular polygon, useful for icons and data-viz marks.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | radius | number | Polygon radius.
        /// @param | sides | integer | Number of polygon sides.
        /// @param | rotation | number? | Rotation in radians (default -pi/2).
        methods.add_method(
            "regularPolygon",
            |_, this, (mode, x, y, radius, sides, rotation): (String, f32, f32, f32, u32, Option<f32>)| {
                let mode = parse_draw_mode(&mode)?;
                let rotation = rotation.unwrap_or(-std::f32::consts::FRAC_PI_2);
                if !(3..=4096).contains(&sides)
                    || ![x, y, radius, rotation].iter().all(|v| v.is_finite())
                    || radius < 0.0
                {
                    return Err(LuaError::RuntimeError(
                        "regularPolygon: invalid center, radius, rotation, or side count".into(),
                    ));
                }
                let mut points = Vec::with_capacity(sides as usize * 2);
                for i in 0..sides {
                    let a = rotation + std::f32::consts::TAU * i as f32 / sides as f32;
                    points.extend([x + radius * a.cos(), y + radius * a.sin()]);
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| LuaError::RuntimeError("Shape handle is stale or was released".into()))?;
                shape.push_command(ShapeCommand::Polygon { mode, vertices: points });
                Ok(())
            },
        );
        // -- star --
        /// Adds a regular star with alternating outer/inner radii.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | outer | number | Outer radius.
        /// @param | inner | number | Inner radius.
        /// @param | points | integer | Number of star points.
        /// @param | rotation | number? | Rotation in radians (default -pi/2).
        methods.add_method(
            "star",
            |_,
             this,
             (mode, x, y, outer, inner, points, rotation): (
                String,
                f32,
                f32,
                f32,
                f32,
                u32,
                Option<f32>,
            )| {
                let mode = parse_draw_mode(&mode)?;
                let rotation = rotation.unwrap_or(-std::f32::consts::FRAC_PI_2);
                if !(2..=4096).contains(&points)
                    || outer < 0.0
                    || inner < 0.0
                    || ![x, y, outer, inner, rotation].iter().all(|v| v.is_finite())
                {
                    return Err(LuaError::RuntimeError(
                        "star: invalid radii, center, rotation, or point count".into(),
                    ));
                }
                let mut vertices = Vec::with_capacity(points as usize * 4);
                for i in 0..points * 2 {
                    let radius = if i % 2 == 0 { outer } else { inner };
                    let a = rotation + std::f32::consts::TAU * i as f32 / (points * 2) as f32;
                    vertices.extend([x + radius * a.cos(), y + radius * a.sin()]);
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Polygon { mode, vertices });
                Ok(())
            },
        );
        // -- capsule --
        /// Adds a rounded capsule (horizontal or vertical according to its dimensions).
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Left edge X.
        /// @param | y | number | Top edge Y.
        /// @param | w | number | Capsule width.
        /// @param | h | number | Capsule height.
        /// @param | radius | number? | Corner radius (defaults from dimensions).
        methods.add_method(
            "capsule",
            |_, this, (mode, x, y, w, h, radius): (String, f32, f32, f32, f32, Option<f32>)| {
                let mode = parse_draw_mode(&mode)?;
                if ![x, y, w, h].iter().all(|v| v.is_finite()) || w < 0.0 || h < 0.0 {
                    return Err(LuaError::RuntimeError(
                        "capsule: invalid bounds or radius".into(),
                    ));
                }
                let radius = radius.unwrap_or((w.min(h) * 0.5).max(0.0));
                if !radius.is_finite() || radius < 0.0 {
                    return Err(LuaError::RuntimeError(
                        "capsule: invalid bounds or radius".into(),
                    ));
                }
                let segments = 16u32;
                let mut points = Vec::new();
                if w >= h {
                    let r = radius.min(h * 0.5);
                    for i in 0..=segments {
                        let a = -std::f32::consts::FRAC_PI_2
                            + std::f32::consts::PI * i as f32 / segments as f32;
                        points.extend([x + w - r + r * a.cos(), y + h * 0.5 + r * a.sin()]);
                    }
                    for i in 0..=segments {
                        let a = std::f32::consts::FRAC_PI_2
                            + std::f32::consts::PI * i as f32 / segments as f32;
                        points.extend([x + r + r * a.cos(), y + h * 0.5 + r * a.sin()]);
                    }
                } else {
                    let r = radius.min(w * 0.5);
                    for i in 0..=segments {
                        let a = 0.0 + std::f32::consts::PI * i as f32 / segments as f32;
                        points.extend([x + w * 0.5 + r * a.cos(), y + r + r * a.sin()]);
                    }
                    for i in 0..=segments {
                        let a = std::f32::consts::PI
                            + std::f32::consts::PI * i as f32 / segments as f32;
                        points.extend([x + w * 0.5 + r * a.cos(), y + h - r + r * a.sin()]);
                    }
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Polygon {
                    mode,
                    vertices: points,
                });
                Ok(())
            },
        );
        // -- ring / sector --
        /// Adds a ring or annulus approximation from two circles.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | outer | number | Outer radius.
        /// @param | inner | number | Inner radius.
        /// @param | segments | integer? | Segment count (default 32).
        methods.add_method(
            "ring",
            |_, this, (mode, x, y, outer, inner, segments): (String, f32, f32, f32, f32, Option<u32>)| {
                let mode = parse_draw_mode(&mode)?;
                let segments = segments.unwrap_or(32).clamp(3, 2048);
                if outer < 0.0 || inner < 0.0 || inner > outer || ![x, y, outer, inner].iter().all(|v| v.is_finite()) {
                    return Err(LuaError::RuntimeError("ring: expected 0 <= inner <= outer".into()));
                }
                let mut vertices = Vec::with_capacity(segments as usize * 4);
                for i in 0..segments {
                    let a0 = std::f32::consts::TAU * i as f32 / segments as f32;
                    let a1 = std::f32::consts::TAU * (i + 1) as f32 / segments as f32;
                    vertices.extend([
                        x + outer * a0.cos(), y + outer * a0.sin(),
                        x + outer * a1.cos(), y + outer * a1.sin(),
                        x + inner * a1.cos(), y + inner * a1.sin(),
                        x + inner * a0.cos(), y + inner * a0.sin(),
                    ]);
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| LuaError::RuntimeError("Shape handle is stale or was released".into()))?;
                for quad in vertices.chunks_exact(8) {
                    shape.push_command(ShapeCommand::Polygon { mode: mode.clone(), vertices: quad.to_vec() });
                }
                Ok(())
            },
        );
        /// Adds a filled sector or stroked arc.
        /// @param | mode | string | "fill" or "line".
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | radius | number | Sector radius.
        /// @param | angle1 | number | Start angle in radians.
        /// @param | angle2 | number | End angle in radians.
        /// @param | segments | integer? | Segment count (default 32).
        methods.add_method(
            "sector",
            |_,
             this,
             (mode, x, y, radius, angle1, angle2, segments): (
                String,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<u32>,
            )| {
                let mode = parse_draw_mode(&mode)?;
                if radius < 0.0 || ![x, y, radius, angle1, angle2].iter().all(|v| v.is_finite()) {
                    return Err(LuaError::RuntimeError(
                        "sector: invalid center, radius, or angles".into(),
                    ));
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Arc {
                    mode,
                    x,
                    y,
                    radius,
                    angle1,
                    angle2,
                    segments: segments.unwrap_or(32).clamp(2, 2048),
                });
                Ok(())
            },
        );
        // -- arrow / symbol / trail --
        /// Adds an arrow from `(x1,y1)` to `(x2,y2)` with a triangular head.
        /// @param | mode | string | "fill" or "line".
        /// @param | x1 | number | Start X.
        /// @param | y1 | number | Start Y.
        /// @param | x2 | number | End X.
        /// @param | y2 | number | End Y.
        /// @param | width | number? | Arrow width (default 6).
        /// @param | head | number? | Head length (default twice width).
        methods.add_method(
            "arrow",
            |_,
             this,
             (mode, x1, y1, x2, y2, width, head): (
                String,
                f32,
                f32,
                f32,
                f32,
                Option<f32>,
                Option<f32>,
            )| {
                let mode = parse_draw_mode(&mode)?;
                let width = width.unwrap_or(6.0);
                let head = head.unwrap_or(width * 2.0);
                let dx = x2 - x1;
                let dy = y2 - y1;
                let len = (dx * dx + dy * dy).sqrt();
                if len <= f32::EPSILON
                    || ![x1, y1, x2, y2, width, head].iter().all(|v| v.is_finite())
                    || width < 0.0
                    || head < 0.0
                {
                    return Err(LuaError::RuntimeError(
                        "arrow: endpoints must be finite and distinct".into(),
                    ));
                }
                let ux = dx / len;
                let uy = dy / len;
                let nx = -uy * width * 0.5;
                let ny = ux * width * 0.5;
                let bx = x2 - ux * head;
                let by = y2 - uy * head;
                let vertices = vec![
                    x1 + nx,
                    y1 + ny,
                    bx + nx,
                    by + ny,
                    bx + nx * 2.0,
                    by + ny * 2.0,
                    x2,
                    y2,
                    bx - nx * 2.0,
                    by - ny * 2.0,
                    bx - nx,
                    by - ny,
                    x1 - nx,
                    y1 - ny,
                ];
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Polygon { mode, vertices });
                Ok(())
            },
        );
        /// Adds a data-viz marker symbol (circle, square, diamond, triangle, cross, plus, times, asterisk, wye).
        /// @param | name | string | Symbol name.
        /// @param | x | number | Center X.
        /// @param | y | number | Center Y.
        /// @param | size | number | Symbol size.
        /// @param | mode | string? | "fill" or "line" (default "fill").
        methods.add_method(
            "symbol",
            |_, this, (name, x, y, size, mode): (String, f32, f32, f32, Option<String>)| {
                let mode = parse_draw_mode(mode.as_deref().unwrap_or("fill"))?;
                let half = size.abs() * 0.5;
                if ![x, y, size].iter().all(|v| v.is_finite()) || size < 0.0 {
                    return Err(LuaError::RuntimeError(
                        "symbol: invalid center or size".into(),
                    ));
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                match name.as_str() {
                    "circle" => shape.push_command(ShapeCommand::Circle {
                        mode,
                        x,
                        y,
                        r: half,
                    }),
                    "square" => shape.push_command(ShapeCommand::Rectangle {
                        mode,
                        x: x - half,
                        y: y - half,
                        w: size,
                        h: size,
                    }),
                    "diamond" => shape.push_command(ShapeCommand::Polygon {
                        mode,
                        vertices: vec![x, y - half, x + half, y, x, y + half, x - half, y],
                    }),
                    "triangle_up" => shape.push_command(ShapeCommand::Polygon {
                        mode,
                        vertices: vec![x, y - half, x + half, y + half, x - half, y + half],
                    }),
                    "triangle_down" => shape.push_command(ShapeCommand::Polygon {
                        mode,
                        vertices: vec![x - half, y - half, x + half, y - half, x, y + half],
                    }),
                    "cross" | "plus" | "times" | "asterisk" | "wye" => {
                        let arm = half.max(1.0) * 0.25;
                        let line_mode = DrawMode::Line;
                        if name == "times" || name == "asterisk" {
                            shape.push_command(ShapeCommand::Line {
                                x1: x - half,
                                y1: y - half,
                                x2: x + half,
                                y2: y + half,
                            });
                            shape.push_command(ShapeCommand::Line {
                                x1: x + half,
                                y1: y - half,
                                x2: x - half,
                                y2: y + half,
                            });
                        } else {
                            shape.push_command(ShapeCommand::Rectangle {
                                mode: mode.clone(),
                                x: x - arm,
                                y: y - half,
                                w: arm * 2.0,
                                h: size,
                            });
                            shape.push_command(ShapeCommand::Rectangle {
                                mode,
                                x: x - half,
                                y: y - arm,
                                w: size,
                                h: arm * 2.0,
                            });
                        }
                        let _ = line_mode;
                    }
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "symbol: unknown symbol '{other}'"
                        )))
                    }
                }
                Ok(())
            },
        );
        /// Adds a variable-width trail as a strip between two point lists.
        /// @param | coords | table | Flat x,y coordinate list.
        /// @param | width_table | table | One non-negative width per point.
        methods.add_method(
            "trail",
            |_, this, (coords, width_table): (LuaTable, LuaTable)| {
                let mut points = Vec::with_capacity(coords.raw_len());
                for index in 1..=coords.raw_len() {
                    points.push(coords.get::<_, f32>(index).map_err(|_| {
                        LuaError::RuntimeError("trail: point coordinates must be numbers".into())
                    })?);
                }
                let mut widths = Vec::with_capacity(width_table.raw_len());
                for index in 1..=width_table.raw_len() {
                    widths.push(width_table.get::<_, f32>(index).map_err(|_| {
                        LuaError::RuntimeError("trail: widths must be numbers".into())
                    })?);
                }
                if points.len() < 4
                    || points.len() % 2 != 0
                    || widths.len() * 2 != points.len()
                    || points.iter().any(|v| !v.is_finite())
                    || widths.iter().any(|v| !v.is_finite() || *v < 0.0)
                {
                    return Err(LuaError::RuntimeError(
                        "trail: expected x/y pairs and one non-negative width per point".into(),
                    ));
                }
                let mut left = Vec::with_capacity(widths.len());
                let mut right = Vec::with_capacity(widths.len());
                for i in 0..widths.len() {
                    let x = points[i * 2];
                    let y = points[i * 2 + 1];
                    let (px, py) = if i == 0 {
                        (points[2] - x, points[3] - y)
                    } else if i + 1 == widths.len() {
                        (x - points[(i - 1) * 2], y - points[(i - 1) * 2 + 1])
                    } else {
                        (
                            points[(i + 1) * 2] - points[(i - 1) * 2],
                            points[(i + 1) * 2 + 1] - points[(i - 1) * 2 + 1],
                        )
                    };
                    let len = (px * px + py * py).sqrt().max(f32::EPSILON);
                    let nx = -py / len * widths[i] * 0.5;
                    let ny = px / len * widths[i] * 0.5;
                    left.extend([x + nx, y + ny]);
                    right.extend([x - nx, y - ny]);
                }
                right.reverse();
                let mut vertices = left;
                vertices.extend(right);
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Polygon {
                    mode: DrawMode::Fill,
                    vertices,
                });
                Ok(())
            },
        );
        // -- addShape --
        /// Snapshots another shape's IR under an optional local transform.
        /// @param | child | LShape | Shape whose commands are copied.
        /// @param | opts | table? | Optional local transform.
        methods.add_method(
            "addShape",
            |_, this, (child, opts): (LuaAnyUserData, Option<LuaTable>)| {
                let child = child.borrow::<LuaShape>()?;
                let child_state = child.state.borrow();
                let child_shape = child_state.shapes.get(child.key).ok_or_else(|| {
                    LuaError::RuntimeError("addShape: child handle is stale".into())
                })?;
                let commands = snapshot_shape_commands(&child_shape.commands);
                let palette = child_shape.palette;
                let transform = parse_shape_transform(opts.as_ref(), "addShape")?;
                drop(child_state);
                drop(child);
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                shape.push_command(ShapeCommand::Transformed {
                    commands,
                    transform,
                    palette,
                });
                Ok(())
            },
        );
        // -- compile --
        /// Compiles the shape once on the CPU; the next frame uploads one static GPU mesh.
        /// @param | opts | table? | Optional compile tolerance settings.
        /// @return | boolean | True when compilation succeeds.
        methods.add_method("compile", |_, this, opts: Option<LuaTable>| {
            let tolerance = opts
                .as_ref()
                .map(|table| table.get::<_, Option<f32>>("tolerance"))
                .transpose()?
                .flatten()
                .unwrap_or(0.1);
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            shape.compile(tolerance).map_err(LuaError::RuntimeError)?;
            Ok(true)
        });
        // -- getBounds --
        /// Returns `{x,y,w,h,minX,minY,maxX,maxY}` in local shape coordinates.
        /// @return | table | Shape bounds in local coordinates.
        methods.add_method("getBounds", |lua, this, ()| {
            let st = this.state.borrow();
            let shape = st.shapes.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            let bounds = shape.bounds();
            let result = lua.create_table()?;
            result.set("minX", bounds[0])?;
            result.set("minY", bounds[1])?;
            result.set("maxX", bounds[2])?;
            result.set("maxY", bounds[3])?;
            result.set("x", bounds[0])?;
            result.set("y", bounds[1])?;
            result.set("w", (bounds[2] - bounds[0]).max(0.0))?;
            result.set("h", (bounds[3] - bounds[1]).max(0.0))?;
            Ok(result)
        });
        // -- getDiagnostics --
        /// Returns compile revision, geometry counters, tolerance, and warnings.
        /// @return | table | Shape compilation diagnostics.
        methods.add_method("getDiagnostics", |lua, this, ()| {
            let st = this.state.borrow();
            let shape = st.shapes.get(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            let result = lua.create_table()?;
            result.set("revision", shape.revision)?;
            result.set("commands", shape.command_count())?;
            result.set("compiled", shape.compiled.is_some())?;
            if let Some(compiled) = shape.compiled.as_ref() {
                result.set("vertices", compiled.vertex_count())?;
                result.set("indices", compiled.index_count())?;
                result.set("tolerance", compiled.tolerance)?;
                let warnings = lua.create_table()?;
                for (index, warning) in compiled.diagnostics.iter().enumerate() {
                    warnings.set(index + 1, warning.as_str())?;
                }
                result.set("warnings", warnings)?;
            }
            Ok(result)
        });
        // -- release --
        /// Releases the shape slot and makes this handle stale.
        /// @return | boolean | True when the shape slot was released.
        methods.add_method("release", |_, this, ()| {
            Ok(this.state.borrow_mut().shapes.remove(this.key).is_some())
        });
        // -- draw --
        /// Renders the accumulated shape commands to the screen with optional transform.
        /// @param | x | number | X position.
        /// @param | y | number | Y position.
        /// @param | rotation | number? | Rotation in radians (default 0).
        /// @param | sx | number? | Scale X (default 1).
        /// @param | sy | number? | Scale Y (default 1).
        /// @param | ox | number? | Origin offset X (default 0).
        /// @param | oy | number? | Origin offset Y (default 0).
        methods.add_method(
            "draw",
            |_,
             this,
             (x, y, rotation, sx, sy, ox, oy): (
                f32,
                f32,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let values = [
                    x,
                    y,
                    rotation.unwrap_or(0.0),
                    sx.unwrap_or(1.0),
                    sy.unwrap_or(1.0),
                    ox.unwrap_or(0.0),
                    oy.unwrap_or(0.0),
                ];
                if values.iter().any(|value| !value.is_finite()) {
                    return Err(LuaError::RuntimeError(
                        "LShape:draw transform values must be finite".into(),
                    ));
                }
                let mut st = this.state.borrow_mut();
                let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                    LuaError::RuntimeError("Shape handle is stale or was released".into())
                })?;
                // Warm the retained CPU mesh at authoring time.  Preserve a
                // caller-selected compile tolerance (built-ins may be loaded
                // with one) and only compile when the current revision is cold.
                if shape
                    .compiled
                    .as_ref()
                    .is_none_or(|compiled| compiled.revision != shape.revision)
                {
                    shape
                        .compile(shape.compile_tolerance)
                        .map_err(LuaError::RuntimeError)?;
                }
                st.render_commands.push(RenderCommand::DrawShape {
                    shape_key: this.key,
                    x,
                    y,
                    rotation: values[2],
                    sx: values[3],
                    sy: values[4],
                    ox: values[5],
                    oy: values[6],
                });
                Ok(())
            },
        );
        // -- drawMany --
        /// Queues up to 250,000 instances of one compiled shape for a single compatible draw.
        /// @param | instances | table | Array of `{x,y,rotation,sx,sy,ox,oy,tint}` records.
        methods.add_method("drawMany", |_, this, instances: LuaTable| {
            let count = instances.raw_len();
            if count == 0 {
                return Ok(());
            }
            if count > 250_000 {
                return Err(LuaError::RuntimeError(
                    "drawMany: maximum is 250000 instances".into(),
                ));
            }
            let mut parsed = Vec::with_capacity(count);
            for index in 1..=count {
                let table: LuaTable = instances.get(index).map_err(|_| {
                    LuaError::RuntimeError(format!("drawMany: instance {index} must be a table"))
                })?;
                parsed.push(parse_shape_instance(table, "LShape:drawMany")?);
            }
            let mut st = this.state.borrow_mut();
            let shape = st.shapes.get_mut(this.key).ok_or_else(|| {
                LuaError::RuntimeError("Shape handle is stale or was released".into())
            })?;
            if shape
                .compiled
                .as_ref()
                .is_none_or(|compiled| compiled.revision != shape.revision)
            {
                shape
                    .compile(shape.compile_tolerance)
                    .map_err(LuaError::RuntimeError)?;
            }
            st.render_commands.push(RenderCommand::DrawShapeMany {
                shape_key: this.key,
                instances: parsed,
            });
            Ok(())
        });
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("Shape" or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LShape" || name == "LObject")
        });
        // -- type --
        /// Returns the type name string for this shape object.
        /// @return | string | Always "LShape".
        methods.add_method("type", |_, _, ()| Ok("LShape"));
    }
}
/// Z-ordered draw callback layer for sorting draw calls by depth before flushing.
struct LuaDrawLayer {
    entries: Vec<(f64, usize, mlua::RegistryKey)>,
    next_id: usize,
}
impl LuaUserData for LuaDrawLayer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- queue --
        /// Enqueues a draw callback at the given z-depth. Callbacks execute when flush() is called.
        /// @param | z | number | Z-depth value used for sorting (lower draws first).
        /// @param | f | function | Callback to invoke during flush.
        methods.add_method_mut("queue", |lua, this, (z, f): (f64, LuaFunction)| {
            let id = allocate_callback_id(&mut this.next_id).map_err(LuaError::external)?;
            let key = lua.create_registry_value(f)?;
            this.entries.push((z, id, key));
            Ok(())
        });
        // -- flush --
        /// Sorts all queued callbacks by z-depth and executes them in order, then empties the layer.
        methods.add_method_mut("flush", |lua, this, ()| {
            this.entries
                .sort_by(|a, b| a.0.total_cmp(&b.0).then_with(|| a.1.cmp(&b.1)));
            let entries: Vec<_> = this.entries.drain(..).collect();
            for (_, _, key) in entries {
                let f = lua.registry_value::<LuaFunction>(&key)?;
                lua.remove_registry_value(key)?;
                f.call::<_, ()>(())?;
            }
            Ok(())
        });
        // -- clear --
        /// Discards all queued callbacks without executing them.
        methods.add_method_mut("clear", |lua, this, ()| {
            for (_, _, key) in this.entries.drain(..) {
                lua.remove_registry_value(key)?;
            }
            Ok(())
        });
        // -- getCount --
        /// Returns the number of callbacks currently queued.
        /// @return | number | Queue length.
        methods.add_method("getCount", |_, this, ()| Ok(this.entries.len() as i64));
        // -- type --
        /// Returns the type name string for this draw layer.
        /// @return | string | Always "LDrawLayer".
        methods.add_method("type", |_, _, ()| Ok("LDrawLayer"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check ("LDrawLayer", "DrawLayer", or "Object").
        /// @return | boolean | True if the name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDrawLayer" || name == "LObject")
        });
    }
}
/// Registers the `lurek.render` module and all its functions and types into the Lua state.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let graphics = lua.create_table()?;
    let s = state.clone();
    // -- setColor --
    /// Sets the active drawing color for all subsequent draw operations.
    /// @param | r | number | Red channel (0â€“1).
    /// @param | g | number | Green channel (0â€“1).
    /// @param | b | number | Blue channel (0â€“1).
    /// @param | a | number? | Alpha channel (0â€“1, default 1).
    graphics.set(
        "setColor",
        lua.create_function(move |_, (r, g, b, a): (f32, f32, f32, Option<f32>)| {
            let a = a.unwrap_or(1.0);
            let mut st = s.borrow_mut();
            st.current_color = [r, g, b, a];
            st.render_commands.push(RenderCommand::SetColor(r, g, b, a));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getColor --
    /// Returns the current drawing color.
    /// @return | number, number, number, number | Red, green, blue, alpha channels (0â€“1).
    graphics.set(
        "getColor",
        lua.create_function(move |_, ()| {
            let c = s.borrow().current_color;
            Ok((c[0], c[1], c[2], c[3]))
        })?,
    )?;
    let s = state.clone();
    // -- setBackgroundColor --
    /// Sets the background clear color used at the start of each frame.
    /// @param | r | number | Red channel (0â€“1).
    /// @param | g | number | Green channel (0â€“1).
    /// @param | b | number | Blue channel (0â€“1).
    graphics.set(
        "setBackgroundColor",
        lua.create_function(move |_, (r, g, b): (f32, f32, f32)| {
            s.borrow_mut().background_color = [r, g, b, 1.0];
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getBackgroundColor --
    /// Returns the current background clear color.
    /// @return | number, number, number, number | Red, green, blue, alpha channels (0â€“1).
    graphics.set(
        "getBackgroundColor",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok((
                st.background_color[0],
                st.background_color[1],
                st.background_color[2],
                st.background_color[3],
            ))
        })?,
    )?;
    let s = state.clone();
    // -- rectangle --
    /// Draws a rectangle. If rx is provided, draws a rounded rectangle.
    /// @param | mode | string | "fill" or "line".
    /// @param | x | number | Left edge X.
    /// @param | y | number | Top edge Y.
    /// @param | w | number | Width.
    /// @param | h | number | Height.
    /// @param | rx | number? | Horizontal corner radius for rounded rectangle.
    /// @param | ry | number? | Vertical corner radius (defaults to rx).
    graphics.set(
        "rectangle",
        lua.create_function(
            move |_,
                  (mode, x, y, w, h, rx, ry): (
                String,
                f32,
                f32,
                f32,
                f32,
                Option<f32>,
                Option<f32>,
            )| {
                let dm = parse_draw_mode(&mode)?;
                match rx {
                    Some(rx_val) => {
                        let ry_val = ry.unwrap_or(rx_val);
                        s.borrow_mut()
                            .render_commands
                            .push(RenderCommand::RoundedRectangle {
                                mode: dm,
                                x,
                                y,
                                w,
                                h,
                                rx: rx_val,
                                ry: ry_val,
                            });
                    }
                    None => {
                        s.borrow_mut()
                            .render_commands
                            .push(RenderCommand::Rectangle {
                                mode: dm,
                                x,
                                y,
                                w,
                                h,
                            });
                    }
                }
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- circle --
    /// Draws a filled or outlined circle at the given position.
    /// @param | mode | string | "fill" or "line".
    /// @param | x | number | Center X.
    /// @param | y | number | Center Y.
    /// @param | radius | number | Circle radius in pixels.
    graphics.set(
        "circle",
        lua.create_function(move |_, (mode, x, y, radius): (String, f32, f32, f32)| {
            s.borrow_mut().render_commands.push(RenderCommand::Circle {
                mode: parse_draw_mode(&mode)?,
                x,
                y,
                r: radius,
            });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- ellipse --
    /// Draws a filled or outlined ellipse at the given position.
    /// @param | mode | string | "fill" or "line".
    /// @param | x | number | Center X.
    /// @param | y | number | Center Y.
    /// @param | rx | number | Horizontal radius.
    /// @param | ry | number | Vertical radius.
    graphics.set(
        "ellipse",
        lua.create_function(
            move |_, (mode, x, y, rx, ry): (String, f32, f32, f32, f32)| {
                s.borrow_mut().render_commands.push(RenderCommand::Ellipse {
                    mode: parse_draw_mode(&mode)?,
                    x,
                    y,
                    rx,
                    ry,
                });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    #[allow(clippy::type_complexity)]
    // -- triangle --
    /// Draws a triangle from three vertex positions.
    /// @param | mode | string | "fill" or "line".
    /// @param | x1 | number | First vertex X.
    /// @param | y1 | number | First vertex Y.
    /// @param | x2 | number | Second vertex X.
    /// @param | y2 | number | Second vertex Y.
    /// @param | x3 | number | Third vertex X.
    /// @param | y3 | number | Third vertex Y.
    graphics.set(
        "triangle",
        lua.create_function(
            move |_, (mode, x1, y1, x2, y2, x3, y3): (String, f32, f32, f32, f32, f32, f32)| {
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::Triangle {
                        mode: parse_draw_mode(&mode)?,
                        x1,
                        y1,
                        x2,
                        y2,
                        x3,
                        y3,
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- line --
    /// Draws a line between two points, or a polyline through multiple points.
    /// @param | ... | number | Coordinate values: x1, y1, x2, y2 for a line, or more for a polyline.
    graphics.set(
        "line",
        lua.create_function(move |_, args: LuaMultiValue| {
            queue_render_line(&mut s.borrow_mut(), args);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- polygon --
    /// Draws a polygon from a flat list of x,y vertex coordinates.
    /// @param | mode | string | "fill" or "line".
    /// @param | ... | number | Flat vertex coordinates: x1, y1, x2, y2, ... (minimum 3 vertices).
    graphics.set(
        "polygon",
        lua.create_function(move |_, args: LuaMultiValue| {
            queue_render_polygon(&mut s.borrow_mut(), args)
        })?,
    )?;
    let s = state.clone();
    #[allow(clippy::type_complexity)]
    // -- arc --
    /// Draws a filled or outlined circular arc segment.
    /// @param | mode | string | "fill" or "line".
    /// @param | x | number | Center X.
    /// @param | y | number | Center Y.
    /// @param | radius | number | Arc radius.
    /// @param | angle1 | number | Start angle in radians.
    /// @param | angle2 | number | End angle in radians.
    /// @param | segments | number? | Number of arc segments (default 32).
    graphics.set(
        "arc",
        lua.create_function(
            move |_,
                  (mode, x, y, radius, angle1, angle2, segments): (
                String,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<u32>,
            )| {
                s.borrow_mut().render_commands.push(RenderCommand::Arc {
                    mode: parse_draw_mode(&mode)?,
                    x,
                    y,
                    radius,
                    angle1,
                    angle2,
                    segments: segments.unwrap_or(32),
                });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- points --
    /// Draws one or more points. Accepts either a table of {x,y} pairs or flat x,y coordinate values.
    /// @param | ... | table|number | Point data as a table of {x,y} sub-tables, or flat x1,y1,x2,y2,... values.
    graphics.set(
        "points",
        lua.create_function(move |_, args: LuaMultiValue| {
            queue_render_points(&mut s.borrow_mut(), args)
        })?,
    )?;
    let s = state.clone();
    #[allow(clippy::type_complexity)]
    // -- draw --
    /// Draws a drawable object (Image, Canvas, SpriteBatch, or Mesh) at the given position with optional transform.
    /// @param | drawable | LImage|LCanvas|LSpriteBatch|LMesh | The drawable object to render.
    /// @param | x | number? | X position (default 0).
    /// @param | y | number? | Y position (default 0).
    /// @param | r | number? | Rotation in radians (default 0).
    /// @param | sx | number? | Scale X (default 1).
    /// @param | sy | number? | Scale Y (default 1).
    /// @param | ox | number? | Origin offset X (default 0).
    /// @param | oy | number? | Origin offset Y (default 0).
    /// @return | nil | No return value.
    graphics.set(
        "draw",
        lua.create_function(move |_, args: LuaMultiValue| {
            queue_render_draw(&mut s.borrow_mut(), args)
        })?,
    )?;
    let s = state.clone();
    // -- drawBatch --
    /// Draws a SpriteBatch using the same queued DrawBatch command as lurek.render.draw(batch).
    /// @param | batch | LSpriteBatch | Sprite batch handle to draw.
    /// @return | nil | No return value.
    graphics.set(
        "drawBatch",
        lua.create_function(move |_, batch: LuaAnyUserData| {
            let batch = batch.borrow::<LuaSpriteBatch>()?;
            let key = batch.key;
            drop(batch);
            let mut st = s.borrow_mut();
            queue_sprite_batch_draw(&mut st, key, "lurek.render.drawBatch")
        })?,
    )?;
    let s = state.clone();
    #[allow(clippy::type_complexity)]
    // -- drawq --
    /// Draws a sub-region of an image defined by a Quad, with optional transform.
    /// @param | image | LImage | Source image to draw from.
    /// @param | quad | LQuad | Quad defining the source rectangle within the image.
    /// @param | x | number? | X position (default 0).
    /// @param | y | number? | Y position (default 0).
    /// @param | r | number? | Rotation in radians (default 0).
    /// @param | sx | number? | Scale X (default 1).
    /// @param | sy | number? | Scale Y (default 1).
    /// @param | ox | number? | Origin offset X (default 0).
    /// @param | oy | number? | Origin offset Y (default 0).
    graphics.set(
        "drawq",
        lua.create_function(
            move |_,
                  (img_ud, quad_ud, x, y, r, sx, sy, ox, oy): (
                LuaAnyUserData,
                LuaAnyUserData,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let img = img_ud.borrow::<LuaImage>()?;
                let img_key = img.key;
                drop(img);
                let quad = quad_ud.borrow::<LuaQuad>()?;
                let qx = quad.x;
                let qy = quad.y;
                let qw = quad.w;
                let qh = quad.h;
                let qsw = quad.sw;
                let qsh = quad.sh;
                drop(quad);
                let x = x.unwrap_or(0.0);
                let y = y.unwrap_or(0.0);
                let r = r.unwrap_or(0.0);
                let sx = sx.unwrap_or(1.0);
                let sy = sy.unwrap_or(1.0);
                let ox = ox.unwrap_or(0.0);
                let oy = oy.unwrap_or(0.0);
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawQuad {
                        texture_key: img_key,
                        quad_x: qx,
                        quad_y: qy,
                        quad_w: qw,
                        quad_h: qh,
                        tex_w: qsw,
                        tex_h: qsh,
                        x,
                        y,
                        rotation: r,
                        sx,
                        sy,
                        ox,
                        oy,
                        effect: None,
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawMany --
    /// Batch-draws multiple images in one call. Each entry is a table: {image, x, y, r, sx, sy, ox, oy}.
    /// @param | list | table | Array of draw entry tables.
    graphics.set(
        "drawMany",
        lua.create_function(move |_, list: LuaTable| queue_draw_many(&mut s.borrow_mut(), list))?,
    )?;
    let s = state.clone();
    // -- printRotated --
    /// Draws text centered and rotated around its midpoint.
    /// @param | text | string | Text to render.
    /// @param | x | number | Center X position.
    /// @param | y | number | Center Y position.
    /// @param | angle | number | Rotation angle in radians.
    /// @param | scale | number? | Text scale factor (default 1).
    graphics.set(
        "printRotated",
        lua.create_function(
            move |_, (text, x, y, angle, scale): (String, f32, f32, f32, Option<f32>)| {
                let scale = scale.unwrap_or(1.0);
                let (font_key, origin_x, origin_y) = {
                    let st = s.borrow();
                    let font_key = st.active_font.or(st.default_font);
                    let Some(font_key) = font_key else {
                        return Ok(());
                    };
                    let Ok((origin_x, origin_y)) =
                        centered_text_origin(&st, font_key, &text, scale)
                    else {
                        return Ok(());
                    };
                    (font_key, origin_x, origin_y)
                };
                queue_rotated_text(
                    &mut s.borrow_mut(),
                    RotatedTextCommand {
                        font_key,
                        text,
                        x,
                        y,
                        angle,
                        scale,
                        origin_x,
                        origin_y,
                    },
                );
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- printRotatedWithFont --
    /// Draws text centered and rotated around its midpoint using a specific font without changing the global active font.
    /// @param | font | LFont | Font handle to use for this draw.
    /// @param | text | string | Text to render.
    /// @param | x | number | Center X position.
    /// @param | y | number | Center Y position.
    /// @param | angle | number | Rotation angle in radians.
    /// @param | scale | number? | Text scale factor (default 1).
    graphics.set(
        "printRotatedWithFont",
        lua.create_function(
            move |_,
                  (font_ud, text, x, y, angle, scale): (
                LuaAnyUserData,
                String,
                f32,
                f32,
                f32,
                Option<f32>,
            )| {
                let scale = scale.unwrap_or(1.0);
                let key = resolve_font_key(&font_ud)?;
                let (origin_x, origin_y) = {
                    let st = s.borrow();
                    centered_text_origin(&st, key, &text, scale)?
                };
                queue_rotated_text(
                    &mut s.borrow_mut(),
                    RotatedTextCommand {
                        font_key: key,
                        text,
                        x,
                        y,
                        angle,
                        scale,
                        origin_x,
                        origin_y,
                    },
                );
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- print --
    /// Draws text using the active font at the given position.
    /// @param | text | string | Text to render.
    /// @param | x | number? | X position (default 0).
    /// @param | y | number? | Y position (default 0).
    /// @param | scale | number? | Text scale factor (default 1).
    graphics.set(
        "print",
        lua.create_function(
            move |_, (text, x, y, scale): (String, Option<f32>, Option<f32>, Option<f32>)| {
                let x = x.unwrap_or(0.0);
                let y = y.unwrap_or(0.0);
                let scale = scale.unwrap_or(1.0);
                let font_key = {
                    let st = s.borrow();
                    st.active_font.or(st.default_font)
                };
                match font_key {
                    Some(font_key) => {
                        queue_print(&mut s.borrow_mut(), font_key, text, x, y, scale);
                    }
                    None => {
                        log::warn!("lurek.render.print: no font loaded, text not rendered");
                    }
                }
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- printWithFont --
    /// Draws text using a specific font without changing the global active font.
    /// @param | font | LFont | Font handle to use for this draw.
    /// @param | text | string | Text to render.
    /// @param | x | number? | X position (default 0).
    /// @param | y | number? | Y position (default 0).
    /// @param | scale | number? | Text scale factor (default 1).
    graphics.set(
        "printWithFont",
        lua.create_function(
            move |_,
                  (font_ud, text, x, y, scale): (
                LuaAnyUserData,
                String,
                Option<f32>,
                Option<f32>,
                Option<f32>,
            )| {
                let key = resolve_font_key(&font_ud)?;
                queue_print(
                    &mut s.borrow_mut(),
                    key,
                    text,
                    x.unwrap_or(0.0),
                    y.unwrap_or(0.0),
                    scale.unwrap_or(1.0),
                );
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- printf --
    /// Draws word-wrapped and aligned text within a pixel-width limit.
    /// @param | text | string | Text to render.
    /// @param | x | number | X position.
    /// @param | y | number | Y position.
    /// @param | limit | number | Maximum line width in pixels for wrapping.
    /// @param | align | string? | Alignment: "left" (default), "center", "right", or "justify".
    graphics.set(
        "printf",
        lua.create_function(
            move |_, (text, x, y, limit, align): (String, f32, f32, f32, Option<String>)| {
                let align = parse_text_align(align.as_deref());
                let active_font = {
                    let st = s.borrow();
                    st.active_font.or(st.default_font)
                };
                if let Some(font_key) = active_font {
                    queue_print_formatted(&mut s.borrow_mut(), font_key, text, x, y, limit, align);
                }
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- printfWithFont --
    /// Draws word-wrapped and aligned text with a specific font without changing the global active font.
    /// @param | font | LFont | Font handle to use for this draw.
    /// @param | text | string | Text to render.
    /// @param | x | number | X position.
    /// @param | y | number | Y position.
    /// @param | limit | number | Maximum line width in pixels for wrapping.
    /// @param | align | string? | Alignment: "left" (default), "center", "right", or "justify".
    graphics.set(
        "printfWithFont",
        lua.create_function(
            move |_,
                  (font_ud, text, x, y, limit, align): (
                LuaAnyUserData,
                String,
                f32,
                f32,
                f32,
                Option<String>,
            )| {
                let key = resolve_font_key(&font_ud)?;
                let align = parse_text_align(align.as_deref());
                queue_print_formatted(&mut s.borrow_mut(), key, text, x, y, limit, align);
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- printRich --
    /// Draws rich text composed of individually styled spans at the given position.
    /// @param | spans | table | Array of span tables, each with fields: text, r, g, b, a, scale.
    /// @param | x | number | X position.
    /// @param | y | number | Y position.
    /// @param | rotation | number? | Rotation in radians (default 0).
    /// @param | sx | number? | X scale factor (default 1).
    /// @param | sy | number? | Y scale factor (defaults to sx).
    /// @param | ox | number? | Origin offset X in text-local pixels (default 0).
    /// @param | oy | number? | Origin offset Y in text-local pixels (default 0).
    graphics.set(
        "printRich",
        lua.create_function(move |_, args: LuaRichTextArgs<'_>| {
            let (spans_table, x, y, rotation, sx, sy, ox, oy) = args;
            let font_key_opt = {
                let st = s.borrow();
                active_font_key(&st)
            };
            let Some(font_key) = font_key_opt else {
                return Ok(());
            };
            let spans = build_rich_text_spans(&spans_table)?;
            if rotation.is_some() || sx.is_some() || sy.is_some() || ox.is_some() || oy.is_some() {
                let sx = sx.unwrap_or(1.0);
                let transform = RenderDrawTransform {
                    x,
                    y,
                    rotation: rotation.unwrap_or(0.0),
                    sx,
                    sy: sy.unwrap_or(sx),
                    ox: ox.unwrap_or(0.0),
                    oy: oy.unwrap_or(0.0),
                };
                queue_rich_text_transformed(&mut s.borrow_mut(), font_key, spans, transform);
            } else {
                queue_rich_text(&mut s.borrow_mut(), font_key, spans, x, y);
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- printRichWithFont --
    /// Draws rich text using a specific font without changing the global active font.
    /// @param | font | LFont | Font handle to use for this draw.
    /// @param | spans | table | Array of span tables, each with fields: text, r, g, b, a, scale.
    /// @param | x | number | X position.
    /// @param | y | number | Y position.
    /// @param | rotation | number? | Rotation in radians (default 0).
    /// @param | sx | number? | X scale factor (default 1).
    /// @param | sy | number? | Y scale factor (defaults to sx).
    /// @param | ox | number? | Origin offset X in text-local pixels (default 0).
    /// @param | oy | number? | Origin offset Y in text-local pixels (default 0).
    graphics.set(
        "printRichWithFont",
        lua.create_function(move |_, args: LuaRichTextWithFontArgs<'_>| {
            let (font_ud, spans_table, x, y, rotation, sx, sy, ox, oy) = args;
            let key = resolve_font_key(&font_ud)?;
            let spans = build_rich_text_spans(&spans_table)?;
            if rotation.is_some() || sx.is_some() || sy.is_some() || ox.is_some() || oy.is_some() {
                let sx = sx.unwrap_or(1.0);
                let transform = RenderDrawTransform {
                    x,
                    y,
                    rotation: rotation.unwrap_or(0.0),
                    sx,
                    sy: sy.unwrap_or(sx),
                    ox: ox.unwrap_or(0.0),
                    oy: oy.unwrap_or(0.0),
                };
                queue_rich_text_transformed(&mut s.borrow_mut(), key, spans, transform);
            } else {
                queue_rich_text(&mut s.borrow_mut(), key, spans, x, y);
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- clear --
    /// Clears all queued render commands for the current frame.
    /// @param | r | number? | Unused (reserved for future clear-color override).
    /// @param | g | number? | Unused.
    /// @param | b | number? | Unused.
    graphics.set(
        "clear",
        lua.create_function(
            move |_, (_r, _g, _b): (Option<f32>, Option<f32>, Option<f32>)| {
                s.borrow_mut().render_commands.clear();
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- setLineWidth --
    /// Sets the line width for subsequent line-mode draw calls.
    /// @param | w | number | Line width in pixels.
    graphics.set(
        "setLineWidth",
        lua.create_function(move |_, w: f32| {
            let mut st = s.borrow_mut();
            st.line_width = w;
            st.render_commands.push(RenderCommand::SetLineWidth(w));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getLineWidth --
    /// Returns the current line width used for line-mode drawing.
    /// @return | number | Line width in pixels.
    graphics.set(
        "getLineWidth",
        lua.create_function(move |_, ()| Ok(s.borrow().line_width))?,
    )?;
    let s = state.clone();
    // -- setPointSize --
    /// Sets the point size for subsequent point draw calls.
    /// @param | size | number | Point diameter in pixels.
    graphics.set(
        "setPointSize",
        lua.create_function(move |_, size: f32| {
            let mut st = s.borrow_mut();
            st.point_size = size;
            st.render_commands.push(RenderCommand::SetPointSize(size));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getPointSize --
    /// Returns the current point diameter used for point drawing.
    /// @return | number | Point diameter in pixels.
    graphics.set(
        "getPointSize",
        lua.create_function(move |_, ()| Ok(s.borrow().point_size))?,
    )?;
    let s = state.clone();
    // -- setBlendMode --
    /// Sets the blend mode for subsequent draw operations.
    /// @param | mode | string | One of: "alpha", "add", "multiply", "replace", "screen".
    graphics.set(
        "setBlendMode",
        lua.create_function(move |_, mode: String| {
            let bm = parse_blend_mode_or_default(mode.as_str());
            let mut st = s.borrow_mut();
            st.blend_mode = bm;
            st.render_commands.push(RenderCommand::SetBlendMode(bm));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getBlendMode --
    /// Returns the current blend mode name.
    /// @return | string | Current blend mode: "alpha", "add", "multiply", "replace", or "screen".
    graphics.set(
        "getBlendMode",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok(blend_mode_name(st.blend_mode).to_string())
        })?,
    )?;
    let s = state.clone();
    // -- newFont --
    /// Compatibility alias for the canonical `lurek.font.load` and built-in font APIs.
    /// @deprecated Use `lurek.font.load` for path-based fonts; this alias is supported through 1.x and targets removal in 2.0.
    /// @param | pathOrSize | any | Built-in font name, font file path, or numeric built-in point-size selector.
    /// @param | size | number? | Point size for TTF/OTF files, or cell height for PNG atlases.
    /// @return | LFont | The created font handle.
    graphics.set(
        "newFont",
        lua.create_function(move |_, args: LuaMultiValue| {
            let mut st = s.borrow_mut();
            let (numeric_size, path, size) = parse_new_font_args(&args)?;
            let key = resolve_new_font(&mut st, numeric_size, path, size)?;
            Ok(LuaFont {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    let s = state.clone();
    // -- setFont --
    /// Sets the active font used by print, printf, and other text rendering calls.
    /// @param | font | LFont | Font handle to make active.
    graphics.set(
        "setFont",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.setFont: font handle is not valid or was released".into(),
                )
            })?;
            let mut st = s.borrow_mut();
            st.active_font = Some(key);
            st.font_override_active = true;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getFont --
    /// Returns the currently active font, or nil if none is set.
    /// @return | LFont | The active font handle.
    graphics.set(
        "getFont",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            match st.active_font {
                Some(key) => Ok(Some(LuaFont {
                    state: s.clone(),
                    key,
                })),
                None => Ok(None),
            }
        })?,
    )?;
    // -- getFontSizes --
    /// Returns all available built-in point sizes.
    /// @return | number[] | Array of bundled font sizes such as 8, 10, 12, 16, 20, 24, and 30.
    graphics.set(
        "getFontSizes",
        lua.create_function(|lua, ()| {
            let tbl = lua.create_table()?;
            for (i, &size) in crate::font::AVAILABLE_POINT_SIZES.iter().enumerate() {
                tbl.set(i + 1, size)?;
            }
            Ok(tbl)
        })?,
    )?;
    // -- getBuiltInFontNames --
    /// Returns all stable built-in font names.
    /// @return | string[] | Array of bundled font names such as font_8 and fontb_8.
    graphics.set(
        "getBuiltInFontNames",
        lua.create_function(|lua, ()| {
            let tbl = lua.create_table()?;
            for (i, name) in crate::font::BUILTIN_FONT_NAMES.iter().enumerate() {
                tbl.set(i + 1, *name)?;
            }
            Ok(tbl)
        })?,
    )?;
    let s = state.clone();
    // -- getDefaultFont --
    /// Returns a built-in default font at the nearest available bundled point size.
    /// @param | pointSize | integer? | Desired built-in point size. When omitted, returns the current configured default.
    /// @param | bold | boolean? | When true, returns the bold variant. When omitted, uses the current bold selection.
    /// @return | LFont | The built-in font handle.
    graphics.set(
        "getDefaultFont",
        lua.create_function(move |_, (point_size, bold): (Option<u32>, Option<bool>)| {
            let st = s.borrow();
            let use_bold = bold.unwrap_or(st.active_bold);
            let key = if let Some(point_size) = point_size {
                builtin_font_key_by_point_size(&st, point_size, Some(use_bold))
            } else if use_bold == st.default_font_bold {
                st.default_font
            } else {
                builtin_font_key_by_point_size(&st, st.default_font_size, Some(use_bold))
            };
            if let Some(key) = key {
                Ok(LuaFont {
                    state: s.clone(),
                    key,
                })
            } else {
                Err(LuaError::RuntimeError(
                    "lurek.render.getDefaultFont: built-in fonts not loaded".into(),
                ))
            }
        })?,
    )?;
    let s = state.clone();
    // -- setDefaultFont --
    /// Selects a built-in default font by bundled point size and makes it the active render font.
    /// @param | pointSize | integer? | Desired built-in point size. When omitted, reuses the configured default size.
    /// @param | bold | boolean? | When true, selects the bold variant. When omitted, reuses the current bold selection.
    /// @return | LFont | The selected built-in font handle.
    graphics.set(
        "setDefaultFont",
        lua.create_function(move |_, (point_size, bold): (Option<u32>, Option<bool>)| {
            let mut st = s.borrow_mut();
            let point_size = point_size.unwrap_or(st.default_font_size);
            let use_bold = bold.unwrap_or(st.active_bold);
            let key = st
                .set_active_builtin_font(point_size, use_bold)
                .ok_or_else(|| {
                    LuaError::RuntimeError(
                        "lurek.render.setDefaultFont: built-in fonts not loaded".into(),
                    )
                })?;
            Ok(LuaFont {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    let s = state.clone();
    // -- setBold --
    /// Sets whether subsequent font size lookups use the bold Courier New variant.
    /// @param | bold | boolean | True to enable bold, false for regular.
    graphics.set(
        "setBold",
        lua.create_function(move |_, bold: bool| {
            let mut st = s.borrow_mut();
            st.active_bold = bold;
            st.font_override_active = true;
            // Re-select active_font to match the new variant at the current size.
            let current_key = st.active_font.or(st.default_font);
            if let Some(ck) = current_key {
                // Find which slot this key came from.
                let arr = if bold {
                    &st.default_fonts
                } else {
                    &st.default_bold_fonts
                };
                if let Some(slot) = arr.iter().position(|&k| k == Some(ck)) {
                    let new_arr = if bold {
                        &st.default_bold_fonts
                    } else {
                        &st.default_fonts
                    };
                    if let Some(new_key) = new_arr[slot] {
                        st.active_font = Some(new_key);
                        return Ok(());
                    }
                }
                // Fallback: use the configured default slot in the new variant.
                let new_arr = if bold {
                    &st.default_bold_fonts
                } else {
                    &st.default_fonts
                };
                let slot = crate::font::Font::nearest_point_size(st.default_font_size);
                if let Some(k) = new_arr[slot] {
                    st.active_font = Some(k);
                    st.default_font = Some(k);
                }
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- isBold --
    /// Returns true if the current default font selection uses the bold variant.
    /// @return | boolean | True when bold is active.
    graphics.set(
        "isBold",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok(st.active_bold)
        })?,
    )?;
    let s = state.clone();
    // -- getFontCellWidth --
    /// Returns the fixed cell width of a bitmap font.
    /// @param | font | LFont | Font handle to query.
    /// @return | number | Cell width in pixels.
    graphics.set(
        "getFontCellWidth",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.getFontCellWidth: font handle is not valid".into(),
                )
            })?;
            let st = s.borrow();
            let f = st.fonts.get(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.getFontCellWidth: font handle is not valid".into(),
                )
            })?;
            Ok(f.cell_width())
        })?,
    )?;
    let s = state.clone();
    // -- getFontWidth --
    /// Measures the pixel width of text using the given font.
    /// @param | font | LFont | Font handle to measure with.
    /// @param | text | string | Text to measure.
    /// @return | number | Width in pixels.
    graphics.set(
        "getFontWidth",
        lua.create_function(move |_, (ud, text): (LuaAnyUserData, String)| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError("lurek.render.getFontWidth: font handle is not valid".into())
            })?;
            let st = s.borrow();
            let f = st.fonts.get(key).ok_or_else(|| {
                LuaError::RuntimeError("lurek.render.getFontWidth: font handle is not valid".into())
            })?;
            Ok(f.text_width(&text))
        })?,
    )?;
    let s = state.clone();
    // -- getFontHeight --
    /// Returns the line height of the given font.
    /// @param | font | LFont | Font handle to query.
    /// @return | number | Line height in pixels.
    graphics.set(
        "getFontHeight",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.getFontHeight: font handle is not valid".into(),
                )
            })?;
            let st = s.borrow();
            let f = st.fonts.get(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.getFontHeight: font handle is not valid".into(),
                )
            })?;
            Ok(f.line_height())
        })?,
    )?;
    let s = state.clone();
    // -- getFontLineHeight --
    /// Returns the line spacing of the given font.
    /// @param | font | LFont | Font handle to query.
    /// @return | number | Line height in pixels.
    graphics.set(
        "getFontLineHeight",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.getFontLineHeight: font handle is not valid".into(),
                )
            })?;
            let st = s.borrow();
            let f = st.fonts.get(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.getFontLineHeight: font handle is not valid".into(),
                )
            })?;
            Ok(f.line_height())
        })?,
    )?;
    let s = state.clone();
    // -- setFontLineHeight --
    /// Sets the line height override for a font (currently a no-op stub).
    /// @param | font | LFont | Font handle.
    /// @param | lh | number | Line height value.
    graphics.set(
        "setFontLineHeight",
        lua.create_function(move |_, (font_ud, lh): (LuaAnyUserData, f32)| {
            let key = resolve_font_key(&font_ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.setFontLineHeight: font handle is not valid".into(),
                )
            })?;
            let mut st = s.borrow_mut();
            let f = st.fonts.get_mut(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.setFontLineHeight: font handle is not valid".into(),
                )
            })?;
            f.set_line_height(lh);
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getFontAscent --
    /// Returns the ascent (pixels above baseline) of the given font.
    /// @param | font | LFont | Font handle to query.
    /// @return | number | Ascent in pixels.
    graphics.set(
        "getFontAscent",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.getFontAscent: font handle is not valid".into(),
                )
            })?;
            let st = s.borrow();
            let f = st.fonts.get(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.getFontAscent: font handle is not valid".into(),
                )
            })?;
            Ok(f.ascent())
        })?,
    )?;
    let s = state.clone();
    // -- getFontDescent --
    /// Returns the descent (pixels below baseline) of the given font.
    /// @param | font | LFont | Font handle to query.
    /// @return | number | Descent in pixels.
    graphics.set(
        "getFontDescent",
        lua.create_function(move |_, ud: LuaAnyUserData| {
            let key = resolve_font_key(&ud).map_err(|_| {
                LuaError::RuntimeError(
                    "lurek.render.getFontDescent: font handle is not valid".into(),
                )
            })?;
            let st = s.borrow();
            let f = st.fonts.get(key).ok_or_else(|| {
                LuaError::RuntimeError(
                    "lurek.render.getFontDescent: font handle is not valid".into(),
                )
            })?;
            Ok(f.descent())
        })?,
    )?;
    let s = state.clone();
    // -- getFontWrap --
    /// Word-wraps text using the active font and returns the resulting lines and widest line width.
    /// @param | text | string | Text to wrap.
    /// @param | limit | number | Maximum line width in pixels.
    /// @return | LuaValue, number | Wrapped lines as a table when a font is active, or nil otherwise, followed by the widest line width.
    graphics.set(
        "getFontWrap",
        lua.create_function(move |lua, (text, limit): (String, f32)| {
            let st = s.borrow();
            if let Some(font_key) = active_font_key(&st) {
                if let Some(font) = st.fonts.get(font_key) {
                    let lines = font.wrap_text(&text, limit);
                    let mut max_w: f32 = 0.0;
                    for line in &lines {
                        let w = font.text_width(line);
                        if w > max_w {
                            max_w = w;
                        }
                    }
                    let tbl = lua.create_table()?;
                    for (i, line) in lines.iter().enumerate() {
                        tbl.set(i + 1, line.as_str())?;
                    }
                    return Ok((LuaValue::Table(tbl), LuaValue::Number(max_w as f64)));
                }
            }
            Ok((LuaValue::Nil, LuaValue::Number(0.0)))
        })?,
    )?;
    render_resources_api::register_resources_api(lua, &graphics, state.clone())?;
    render_diagnostics_api::register_diagnostics_api(lua, &graphics, state.clone())?;
    render_canvas_api::register_canvas_api(lua, &graphics, state.clone())?;
    render_shader_api::register_shader_api(lua, &graphics, state.clone())?;
    render_mesh_api::register_mesh_api(lua, &graphics, state.clone())?;
    render_state_api::register_state_api(lua, &graphics, state.clone())?;
    render_text_api::register_text_api(lua, &graphics, state.clone())?;
    render_primitive_api::register_primitive_api(lua, &graphics, state.clone())?;
    let s = state.clone();
    // -- stencil --
    /// Begins a stencil write pass with the given action and reference value.
    /// @param | action | string? | Stencil action: "replace" (default), "zero", "increment", "decrement", etc.
    /// @param | value | number? | Stencil reference value (default 1).
    graphics.set(
        "stencil",
        lua.create_function(move |_, (action, value): (Option<String>, Option<u8>)| {
            let act = match action.as_deref() {
                Some("zero") => StencilAction::Zero,
                Some("increment") => StencilAction::Increment,
                Some("decrement") => StencilAction::Decrement,
                Some("incrementwrap") => StencilAction::IncrementWrap,
                Some("decrementwrap") => StencilAction::DecrementWrap,
                Some("invert") => StencilAction::Invert,
                Some("keep") => StencilAction::Keep,
                _ => StencilAction::Replace,
            };
            let val = value.unwrap_or(1);
            let mut st = s.borrow_mut();
            st.render_commands.push(RenderCommand::StencilBegin {
                action: act,
                value: val,
            });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setStencilTest --
    /// Configures the stencil comparison test for subsequent draws. Pass nil to disable.
    /// @param | compare | string? | Compare function: "equal", "notequal", "less", "greater", etc. Nil disables.
    /// @param | value | number? | Reference value to compare against (default 1).
    graphics.set(
        "setStencilTest",
        lua.create_function(move |_, (compare, value): (Option<String>, Option<u8>)| {
            let mut st = s.borrow_mut();
            match compare {
                Some(cmp) => {
                    let mode = match cmp.as_str() {
                        "equal" => CompareMode::Equal,
                        "notequal" => CompareMode::NotEqual,
                        "less" => CompareMode::Less,
                        "lequal" | "lessequal" => CompareMode::LessEqual,
                        "greater" => CompareMode::Greater,
                        "gequal" | "greaterequal" => CompareMode::GreaterEqual,
                        "always" => CompareMode::Always,
                        "never" => CompareMode::Never,
                        _ => CompareMode::Always,
                    };
                    st.render_commands.push(RenderCommand::SetStencilTest(Some((
                        mode,
                        value.unwrap_or(1),
                    ))));
                }
                None => {
                    st.render_commands.push(RenderCommand::SetStencilTest(None));
                }
            }
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setStencilMode --
    /// Sets the stencil write action, compare function, and reference value at once.
    /// @param | action | string | Stencil action: "keep", "zero", "replace", "increment", "decrement", etc.
    /// @param | compare | string? | Compare function (default "always").
    /// @param | value | number? | Reference value (default 0).
    graphics.set(
        "setStencilMode",
        lua.create_function(
            move |_, (action, compare, value): (String, Option<String>, Option<u8>)| {
                let sa = match action.as_str() {
                    "keep" => StencilAction::Keep,
                    "zero" => StencilAction::Zero,
                    "replace" => StencilAction::Replace,
                    "increment" => StencilAction::Increment,
                    "decrement" => StencilAction::Decrement,
                    "incrementwrap" => StencilAction::IncrementWrap,
                    "decrementwrap" => StencilAction::DecrementWrap,
                    "invert" => StencilAction::Invert,
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "unknown stencil action: {other}"
                        )))
                    }
                };
                let cmp = match compare.as_deref().unwrap_or("always") {
                    "always" => CompareMode::Always,
                    "never" => CompareMode::Never,
                    "equal" => CompareMode::Equal,
                    "notequal" => CompareMode::NotEqual,
                    "less" => CompareMode::Less,
                    "lequal" | "lessequal" => CompareMode::LessEqual,
                    "greater" => CompareMode::Greater,
                    "gequal" | "greaterequal" => CompareMode::GreaterEqual,
                    _ => CompareMode::Always,
                };
                s.borrow_mut().stencil_mode = StencilMode {
                    action: sa,
                    compare: cmp,
                    value: value.unwrap_or(0),
                };
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- getStencilMode --
    /// Returns the current stencil action, compare mode, and reference value.
    /// @return | string, string, number | Action name, compare mode name, and reference value.
    graphics.set(
        "getStencilMode",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            let sm = st.stencil_mode;
            let action = match sm.action {
                StencilAction::Keep => "keep",
                StencilAction::Zero => "zero",
                StencilAction::Replace => "replace",
                StencilAction::Increment => "increment",
                StencilAction::Decrement => "decrement",
                StencilAction::IncrementWrap => "incrementwrap",
                StencilAction::DecrementWrap => "decrementwrap",
                StencilAction::Invert => "invert",
            };
            let compare = match sm.compare {
                CompareMode::Always => "always",
                CompareMode::Never => "never",
                CompareMode::Equal => "equal",
                CompareMode::NotEqual => "notequal",
                CompareMode::Less => "less",
                CompareMode::LessEqual => "lequal",
                CompareMode::Greater => "greater",
                CompareMode::GreaterEqual => "gequal",
            };
            Ok((action, compare, sm.value as i64))
        })?,
    )?;
    let s = state.clone();
    // -- clearStencil --
    /// Resets the stencil state to defaults (no stencil operations).
    graphics.set(
        "clearStencil",
        lua.create_function(move |_, ()| {
            s.borrow_mut().stencil_mode = StencilMode::default();
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- setDepthMode --
    /// Sets the depth comparison mode and whether depth writes are enabled.
    /// @param | mode | string | Compare mode: "always", "never", "less", "lequal", "equal", "notequal", "greater", "gequal".
    /// @param | write | boolean? | Enable depth buffer writes (default false).
    graphics.set(
        "setDepthMode",
        lua.create_function(move |_, (mode, write): (String, Option<bool>)| {
            let dm = match mode.as_str() {
                "always" => DepthMode::Always,
                "never" => DepthMode::Never,
                "less" => DepthMode::Less,
                "lequal" | "lessequal" => DepthMode::LessEqual,
                "equal" => DepthMode::Equal,
                "notequal" => DepthMode::NotEqual,
                "greater" => DepthMode::Greater,
                "gequal" | "greaterequal" => DepthMode::GreaterEqual,
                other => {
                    return Err(LuaError::RuntimeError(format!(
                        "unknown depth mode: {other}"
                    )))
                }
            };
            s.borrow_mut().depth_mode = (dm, write.unwrap_or(false));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- getDepthMode --
    /// Returns the current depth comparison mode and write-enable flag.
    /// @return | string, boolean | Depth mode name and whether depth writes are enabled.
    graphics.set(
        "getDepthMode",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            let (dm, write) = st.depth_mode;
            let mode = match dm {
                DepthMode::Always => "always",
                DepthMode::Never => "never",
                DepthMode::Less => "less",
                DepthMode::LessEqual => "lequal",
                DepthMode::Equal => "equal",
                DepthMode::NotEqual => "notequal",
                DepthMode::Greater => "greater",
                DepthMode::GreaterEqual => "gequal",
            };
            Ok((mode, write))
        })?,
    )?;
    let s = state.clone();
    // -- getWidth --
    /// Returns the current window width in pixels.
    /// @return | number | Window width.
    graphics.set(
        "getWidth",
        lua.create_function(move |_, ()| Ok(s.borrow().window_width))?,
    )?;
    let s = state.clone();
    // -- getHeight --
    /// Returns the current window height in pixels.
    /// @return | number | Window height.
    graphics.set(
        "getHeight",
        lua.create_function(move |_, ()| Ok(s.borrow().window_height))?,
    )?;
    let s = state.clone();
    // -- getDimensions --
    /// Returns the current window width and height.
    /// @return | number, number | Width and height in pixels.
    graphics.set(
        "getDimensions",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok((st.window_width, st.window_height))
        })?,
    )?;
    let s = state.clone();
    // -- setDefaultFilter --
    /// Sets the default texture filtering mode for newly created images.
    /// @param | min | string | Minification filter: "nearest" or "linear".
    /// @param | mag | string | Magnification filter: "nearest" or "linear".
    /// @param | anisotropy | integer? | Anisotropy level (default 1).
    graphics.set(
        "setDefaultFilter",
        lua.create_function(
            move |_, (min, mag, anisotropy): (String, String, Option<u32>)| {
                s.borrow_mut().default_filter = (min, mag, anisotropy.unwrap_or(1));
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- getDefaultFilter --
    /// Returns the current default texture filtering settings.
    /// @return | string, string, number | Min filter, mag filter, anisotropy level.
    graphics.set(
        "getDefaultFilter",
        lua.create_function(move |_, ()| {
            let st = s.borrow();
            Ok((
                st.default_filter.0.clone(),
                st.default_filter.1.clone(),
                st.default_filter.2,
            ))
        })?,
    )?;
    let s = state.clone();
    // -- getStats --
    /// Returns a table of rendering statistics for the current frame.
    /// @return | table | Stats table with rendering counters.
    /// @field | drawcalls | integer | Total draw call count.
    /// @field | textures | integer | Loaded texture count.
    /// @field | fonts | integer | Loaded font count.
    /// @field | canvases | integer | Active canvas count.
    /// @field | texture_memory | integer | Texture memory in bytes.
    /// @field | gpu_draw_calls | integer | GPU-side draw call count.
    /// @field | batched_draws | integer | Batched draw count.
    /// @field | texture_switches | integer | Texture switch count.
    /// @field | canvas_switches | integer | Canvas switch count.
    /// @field | shader_switches | integer | Shader switch count.
    /// @field | shader_cache_hits | integer | Reused user-shader cache entries this frame.
    /// @field | shader_cache_misses | integer | User-shader cache rebuilds this frame.
    /// @field | shader_negative_cache_hits | integer | Repeated invalid shader signatures skipped this frame.
    /// @field | shader_cache_rejections | integer | Shader or pipeline cache limit rejections this frame.
    /// @field | shader_cache_evictions | integer | Shader cache entries evicted to stay within source-memory limits this frame.
    /// @field | cpu_render_ms | number | CPU render time in milliseconds.
    /// @field | msaa_samples | integer | Active screen/canvas MSAA sample count (1 or 4).
    /// @field | msaa_fallback | boolean | True when 4x MSAA was unavailable and 1x was selected.
    /// @field | shape_tessellations | integer | CPU retained-shape tessellations performed this frame.
    /// @field | shape_cache_hits | integer | Compiled shape cache hits this frame.
    /// @field | shape_cache_misses | integer | Compiled shape cache misses this frame.
    /// @field | shape_uploads | integer | Compiled shape GPU uploads this frame.
    /// @field | shape_instances | integer | Retained-shape instances submitted this frame.
    graphics.set(
        "getStats",
        lua.create_function(move |lua, ()| {
            let st = s.borrow();
            let r = st.compute_stats();
            let stats = lua.create_table()?;
            /// Performs the 'drawcalls' operation.
            stats.set("drawcalls", r.draw_calls)?;
            /// Performs the 'textures' operation.
            stats.set("textures", r.textures)?;
            /// Performs the 'fonts' operation.
            stats.set("fonts", r.fonts)?;
            /// Performs the 'canvases' operation.
            stats.set("canvases", r.canvases)?;
            /// Performs the 'texture_memory' operation.
            stats.set("texture_memory", r.texture_memory)?;
            /// Performs the 'gpu_draw_calls' operation.
            stats.set("gpu_draw_calls", st.render_stats.draw_calls)?;
            /// Performs the 'batched_draws' operation.
            stats.set("batched_draws", st.render_stats.batched_draws)?;
            /// Performs the 'texture_switches' operation.
            stats.set("texture_switches", st.render_stats.texture_switches)?;
            /// Performs the 'canvas_switches' operation.
            stats.set("canvas_switches", st.render_stats.canvas_switches)?;
            /// Performs the 'shader_switches' operation.
            stats.set("shader_switches", st.render_stats.shader_switches)?;
            stats.set("shader_cache_hits", st.render_stats.shader_cache_hits)?;
            stats.set("shader_cache_misses", st.render_stats.shader_cache_misses)?;
            stats.set(
                "shader_negative_cache_hits",
                st.render_stats.shader_negative_cache_hits,
            )?;
            stats.set(
                "shader_cache_rejections",
                st.render_stats.shader_cache_rejections,
            )?;
            stats.set(
                "shader_cache_evictions",
                st.render_stats.shader_cache_evictions,
            )?;
            stats.set("shape_tessellations", st.render_stats.shape_tessellations)?;
            stats.set("shape_cache_hits", st.render_stats.shape_cache_hits)?;
            stats.set("shape_cache_misses", st.render_stats.shape_cache_misses)?;
            stats.set("shape_uploads", st.render_stats.shape_uploads)?;
            stats.set("shape_instances", st.render_stats.shape_instances)?;
            stats.set("msaa_samples", st.render_stats.msaa_samples)?;
            stats.set("msaa_fallback", st.render_stats.msaa_fallback)?;
            /// Performs the 'cpu_render_ms' operation.
            stats.set("cpu_render_ms", st.render_stats.cpu_render_ms)?;
            Ok(stats)
        })?,
    )?;
    let s = state.clone();
    // -- saveScreenshot --
    /// Saves a screenshot of the current frame to a file under the save/ directory.
    /// @param | path | string | Output path (must start with "save/").
    graphics.set(
        "saveScreenshot",
        lua.create_function(move |_, path: String| {
            if !path.starts_with("save/") {
                return Err(LuaError::RuntimeError(format!(
                    "saveScreenshot: path must start with \"save/\" (got \"{}\")",
                    path
                )));
            }
            let mut state = s.borrow_mut();
            if state.pending_screenshot.is_some() || state.surface_readback_request.is_some() {
                return Err(LuaError::RuntimeError(
                    "saveScreenshot: another surface readback request is active; wait for it to finish or release it first".into(),
                ));
            }
            state.pending_screenshot = Some(ScreenshotRequest { path });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- requestReadback --
    /// Requests one bounded asynchronous GPU surface readback. The returned handle advances during normal frame polling and never blocks Lua.
    /// @return | LReadbackRequest | Handle with status, cancel, result, and release methods.
    graphics.set(
        "requestReadback",
        lua.create_function(move |_, ()| {
            let mut state = s.borrow_mut();
            if state.surface_readback_request.is_some() || state.pending_screenshot.is_some() {
                return Err(LuaError::RuntimeError(
                    "lurek.render.requestReadback: another surface readback request is active; consume or release it first".into(),
                ));
            }
            let id = state.next_surface_readback_request_id;
            state.next_surface_readback_request_id = state
                .next_surface_readback_request_id
                .checked_add(1)
                .unwrap_or(1);
            state.surface_readback_request = Some(SurfaceReadbackRequest {
                id,
                state: SurfaceReadbackRequestState::Pending,
                image: None,
            });
            state.pending_screen_capture = true;
            Ok(LuaSurfaceReadbackRequest {
                state: s.clone(),
                id,
            })
        })?,
    )?;
    let s = state.clone();
    // -- prewarmShaders --
    /// Queues up to 64 live shaders for bounded frame-boundary cache preparation.
    /// @param | shaders | table | One-based array of LShader handles from this runtime.
    /// @return | LShaderPrewarmRequest | Non-blocking request with progress, cancel, and release methods.
    graphics.set(
        "prewarmShaders",
        lua.create_function(move |_, shaders: LuaTable| {
            const MAX_PREWARM_SHADERS: usize = 64;
            let mut shader_keys = Vec::new();
            for (index, value) in shaders.sequence_values::<LuaAnyUserData>().enumerate() {
                let shader = value.map_err(|error| {
                    LuaError::RuntimeError(format!(
                        "lurek.render.prewarmShaders: entry {} must be an LShader: {error}",
                        index + 1
                    ))
                })?;
                let shader = shader.borrow::<LuaShader>().map_err(|_| {
                    LuaError::RuntimeError(format!(
                        "lurek.render.prewarmShaders: entry {} must be an LShader",
                        index + 1
                    ))
                })?;
                if !Rc::ptr_eq(&shader.state, &s) {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.render.prewarmShaders: entry {} belongs to another runtime",
                        index + 1
                    )));
                }
                let shader_key = shader.key;
                drop(shader);
                if !shader_keys.contains(&shader_key) {
                    shader_keys.push(shader_key);
                }
                if shader_keys.len() > MAX_PREWARM_SHADERS {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.render.prewarmShaders: accepts at most {MAX_PREWARM_SHADERS} unique shaders"
                    )));
                }
            }
            if shader_keys.is_empty() {
                return Err(LuaError::RuntimeError(
                    "lurek.render.prewarmShaders: expected a non-empty array of LShader handles"
                        .into(),
                ));
            }
            let mut state = s.borrow_mut();
            if shader_keys
                .iter()
                .any(|shader_key| !state.shaders.contains_key(*shader_key))
            {
                return Err(LuaError::RuntimeError(
                    "lurek.render.prewarmShaders: shader handle is not valid or was released".into(),
                ));
            }
            let id = state.next_shader_prewarm_request_id;
            state.next_shader_prewarm_request_id = state
                .next_shader_prewarm_request_id
                .checked_add(1)
                .unwrap_or(1);
            let total = shader_keys.len();
            state.shader_prewarm_requests.insert(
                id,
                ShaderPrewarmRequest {
                    id,
                    state: ShaderPrewarmRequestState::Pending,
                    remaining: shader_keys.into(),
                    in_flight: 0,
                    completed: 0,
                    total,
                },
            );
            Ok(LuaShaderPrewarmRequest {
                state: s.clone(),
                id,
            })
        })?,
    )?;
    let s = state.clone();
    // -- captureScreenshot --
    /// Captures the queued 2D render commands into an ImageData fallback and passes it to a callback.
    /// @param | callback | function | Called with an LImageData argument.
    graphics.set(
        "captureScreenshot",
        lua.create_function(move |lua, callback: LuaFunction| {
            let st = s.borrow();
            let img = crate::render::software_capture::capture_commands_to_image_with_shapes(
                &st.render_commands,
                &st.shapes,
                st.background_color,
            );
            drop(st);
            let ud = lua.create_userdata(img)?;
            callback.call::<_, ()>(ud)?;
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- drawNineSlice --
    /// Draws a 9-slice image stretched to fill the given rectangle, keeping borders unscaled.
    /// @param | slice | LNineSlice | The 9-slice handle to draw.
    /// @param | x | number | Left edge X.
    /// @param | y | number | Top edge Y.
    /// @param | w | number | Target width.
    /// @param | h | number | Target height.
    graphics.set(
        "drawNineSlice",
        lua.create_function(
            move |_, (slice, x, y, w, h): (LuaAnyUserData, f32, f32, f32, f32)| {
                let ns = slice.borrow::<LuaNineSlice>()?;
                let key = ns.key;
                let (top, right, bottom, left) = (ns.top, ns.right, ns.bottom, ns.left);
                drop(ns);
                let mut st = s.borrow_mut();
                let (tex_w, tex_h) = st
                    .textures
                    .get(key)
                    .map(|t| (t.width as f32, t.height as f32))
                    .unwrap_or((1.0, 1.0));
                st.render_commands.push(RenderCommand::DrawNineSlice {
                    texture_key: key,
                    tex_w,
                    tex_h,
                    top,
                    right,
                    bottom,
                    left,
                    x,
                    y,
                    w,
                    h,
                });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- listBuiltinShapes --
    /// Lists the 96 native primitive-based shape templates.
    /// @param | filter | table|string? | Optional category or query filter.
    /// @return | table | Metadata records sorted by canonical ID. Each row also contains tags, primitive vocabulary, and the default role palette.
    graphics.set(
        "listBuiltinShapes",
        lua.create_function(move |lua, filter: Option<LuaValue>| {
            let (category, query) = match filter {
                None | Some(LuaValue::Nil) => (None, None),
                Some(LuaValue::String(value)) => (None, Some(value.to_str()?.to_ascii_lowercase())),
                Some(LuaValue::Table(table)) => (
                    table.get::<_, Option<String>>("category")?,
                    table
                        .get::<_, Option<String>>("query")?
                        .map(|value| value.to_ascii_lowercase()),
                ),
                Some(_) => {
                    return Err(LuaError::RuntimeError(
                        "lurek.render.listBuiltinShapes: filter must be a table or string".into(),
                    ))
                }
            };
            let result = lua.create_table()?;
            let mut output_index = 1usize;
            for info in crate::render::builtin_shapes::all() {
                if category
                    .as_deref()
                    .is_some_and(|value| value != info.category)
                {
                    continue;
                }
                if query
                    .as_deref()
                    .is_some_and(|value| !info.id.to_ascii_lowercase().contains(value))
                {
                    continue;
                }
                let row = lua.create_table()?;
                row.set("id", info.id)?;
                row.set("label", info.label)?;
                row.set("category", info.category)?;
                row.set("viewBox", "0 0 64 64")?;
                let anchor = lua.create_table()?;
                anchor.set("x", info.anchor[0])?;
                anchor.set("y", info.anchor[1])?;
                row.set("anchor", anchor)?;
                let tags = lua.create_table()?;
                for (index, tag) in info.tags.iter().enumerate() {
                    tags.set(index + 1, *tag)?;
                }
                row.set("tags", tags)?;
                let primitives = lua.create_table()?;
                for (index, primitive) in info.primitives.iter().enumerate() {
                    primitives.set(index + 1, *primitive)?;
                }
                row.set("primitives", primitives)?;
                let palette = lua.create_table()?;
                for entry in info.palette {
                    palette.set(
                        entry.role,
                        lua.create_sequence_from(entry.color.iter().copied())?,
                    )?;
                }
                row.set("palette", palette)?;
                result.set(output_index, row)?;
                output_index += 1;
            }
            Ok(result)
        })?,
    )?;
    // -- getBuiltinShapeInfo --
    /// Returns metadata for one native shape template.
    /// @param | id | string | Canonical built-in shape identifier.
    /// @return | table | Shape metadata including category, anchor, tags, primitive vocabulary, and default role palette.
    graphics.set(
        "getBuiltinShapeInfo",
        lua.create_function(move |lua, id: String| {
            let info = crate::render::builtin_shapes::info(&id).ok_or_else(|| {
                LuaError::RuntimeError(format!(
                    "lurek.render.getBuiltinShapeInfo: unknown or ambiguous shape '{id}'"
                ))
            })?;
            let row = lua.create_table()?;
            row.set("id", info.id)?;
            row.set("label", info.label)?;
            row.set("category", info.category)?;
            row.set("viewBox", "0 0 64 64")?;
            let anchor = lua.create_table()?;
            anchor.set("x", info.anchor[0])?;
            anchor.set("y", info.anchor[1])?;
            row.set("anchor", anchor)?;
            let tags = lua.create_table()?;
            for (index, tag) in info.tags.iter().enumerate() {
                tags.set(index + 1, *tag)?;
            }
            row.set("tags", tags)?;
            let primitives = lua.create_table()?;
            for (index, primitive) in info.primitives.iter().enumerate() {
                primitives.set(index + 1, *primitive)?;
            }
            row.set("primitives", primitives)?;
            let palette = lua.create_table()?;
            for entry in info.palette {
                palette.set(
                    entry.role,
                    lua.create_sequence_from(entry.color.iter().copied())?,
                )?;
            }
            row.set("palette", palette)?;
            Ok(row)
        })?,
    )?;
    // -- loadBuiltinShape --
    /// Creates and compiles one native shape template into the shape registry.
    /// @param | id | string | Canonical built-in shape identifier.
    /// @param | opts | table? | Optional palette overrides.
    /// @return | LShape | The created built-in shape handle.
    let builtin_state = state.clone();
    graphics.set(
        "loadBuiltinShape",
        lua.create_function(move |_lua, (id, opts): (String, Option<LuaTable>)| {
            let api = "lurek.render.loadBuiltinShape";
            let mut palette = Vec::new();
            let mut tolerance = 0.1f32;
            if let Some(opts) = opts.as_ref() {
                match opts.get::<_, LuaValue>("palette")? {
                    LuaValue::Nil => {}
                    LuaValue::Table(table) => {
                        for pair in table.pairs::<String, LuaValue>() {
                            let (role, value) = pair?;
                            if role_index(&role).is_none() {
                                return Err(LuaError::RuntimeError(format!(
                                    "{api}: unknown palette role '{role}'"
                                )));
                            }
                            palette.push((role.clone(), parse_shape_rgba(value, api, &role)?));
                        }
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(format!(
                            "{api}: opts.palette must be a table"
                        )))
                    }
                }
                tolerance = opts.get::<_, Option<f32>>("tolerance")?.unwrap_or(0.1);
                if !tolerance.is_finite() || !(0.01..=2.0).contains(&tolerance) {
                    return Err(LuaError::RuntimeError(format!(
                        "{api}: opts.tolerance must be finite and within 0.01..2.0"
                    )));
                }
            }
            let shape =
                crate::render::builtin_shapes::build_with_tolerance(&id, &palette, tolerance)
                    .map_err(|error| LuaError::RuntimeError(format!("{api}: {error}")))?;
            let state = builtin_state.clone();
            let key = state.borrow_mut().shapes.insert(shape);
            Ok(LuaShape { state, key })
        })?,
    )?;
    // -- newShape --
    /// Creates a new retained compound shape for accumulating draw commands.
    /// @return | LShape | The created shape handle.
    graphics.set(
        "newShape",
        lua.create_function(move |_, ()| {
            let key = s.borrow_mut().shapes.insert(CompoundShape::new());
            Ok(LuaShape {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    // -- newDrawLayer --
    /// Creates a new z-ordered draw layer for sorting draw callbacks by depth.
    /// @return | LDrawLayer | The created draw layer.
    graphics.set(
        "newDrawLayer",
        lua.create_function(|_, ()| {
            Ok(LuaDrawLayer {
                entries: Vec::new(),
                next_id: 0,
            })
        })?,
    )?;
    let s = state.clone();
    // -- drawQuadBezier --
    /// Draws a quadratic Bezier curve through start, control, and end points.
    /// @param | x1 | number | Start X.
    /// @param | y1 | number | Start Y.
    /// @param | cx | number | Control point X.
    /// @param | cy | number | Control point Y.
    /// @param | x2 | number | End X.
    /// @param | y2 | number | End Y.
    /// @param | segments | number? | Number of line segments (default 16).
    graphics.set(
        "drawQuadBezier",
        lua.create_function(
            move |_,
                  (x1, y1, cx, cy, x2, y2, segments): (
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<u32>,
            )| {
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawQuadBezier {
                        start: crate::math::Vec2::new(x1, y1),
                        control: crate::math::Vec2::new(cx, cy),
                        end: crate::math::Vec2::new(x2, y2),
                        segments: segments.unwrap_or(16),
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawCubicBezier --
    /// Draws a cubic Bezier curve through start, two control points, and end.
    /// @param | x1 | number | Start X.
    /// @param | y1 | number | Start Y.
    /// @param | cx1 | number | First control point X.
    /// @param | cy1 | number | First control point Y.
    /// @param | cx2 | number | Second control point X.
    /// @param | cy2 | number | Second control point Y.
    /// @param | x2 | number | End X.
    /// @param | y2 | number | End Y.
    /// @param | segments | number? | Number of line segments (default 16).
    graphics.set(
        "drawCubicBezier",
        lua.create_function(
            move |_,
                  (x1, y1, cx1, cy1, cx2, cy2, x2, y2, segments): (
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                f32,
                Option<u32>,
            )| {
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawCubicBezier {
                        start: crate::math::Vec2::new(x1, y1),
                        c1: crate::math::Vec2::new(cx1, cy1),
                        c2: crate::math::Vec2::new(cx2, cy2),
                        end: crate::math::Vec2::new(x2, y2),
                        segments: segments.unwrap_or(16),
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawPath --
    /// Draws a vector path composed of moveTo, lineTo, quadTo, cubicTo, and close segments.
    /// @param | path | table | Array of segment tables, each with a "type" or "verb" field and coordinates.
    /// @param | modeOrOpts | string/table? | Legacy "line"/"fill" mode, or options with mode, close, fillRule, and stroke fields.
    /// @param | close | boolean? | Legacy close flag (default false); an explicit close verb also closes its subpath.
    graphics.set(
        "drawPath",
        lua.create_function(move |_, args: LuaMultiValue| {
            let mut args = args.into_iter();
            let path = match args.next() {
                Some(LuaValue::Table(path)) => path,
                _ => {
                    return Err(LuaError::RuntimeError(
                        "drawPath: path must be a table".into(),
                    ))
                }
            };
            let second = args.next();
            let third = args.next();
            let (mode, close, fill_rule, stroke) = match second {
                None | Some(LuaValue::Nil) => (
                    "line".to_string(),
                    false,
                    FillRule::NonZero,
                    StrokeStyle {
                        width: 0.0,
                        ..StrokeStyle::default()
                    },
                ),
                Some(LuaValue::String(value)) => {
                    let mode = value
                        .to_str()
                        .map_err(|_| LuaError::RuntimeError("drawPath: mode must be UTF-8".into()))?
                        .to_string();
                    let close = match third {
                        None | Some(LuaValue::Nil) => false,
                        Some(LuaValue::Boolean(value)) => value,
                        Some(_) => {
                            return Err(LuaError::RuntimeError(
                                "drawPath: close must be boolean".into(),
                            ))
                        }
                    };
                    (
                        mode,
                        close,
                        FillRule::NonZero,
                        StrokeStyle {
                            width: 0.0,
                            ..StrokeStyle::default()
                        },
                    )
                }
                Some(LuaValue::Table(opts)) => {
                    let mode = opts
                        .get::<_, Option<String>>("mode")?
                        .unwrap_or_else(|| "line".into());
                    let close = opts.get::<_, Option<bool>>("close")?.unwrap_or(false);
                    let fill_rule = parse_fill_rule(
                        &opts
                            .get::<_, Option<String>>("fillRule")?
                            .unwrap_or_else(|| "nonzero".into()),
                        "drawPath",
                    )?;
                    let stroke_table = opts
                        .get::<_, Option<LuaTable>>("stroke")?
                        .or_else(|| Some(opts.clone()));
                    let mut stroke = parse_shape_stroke_style(stroke_table.as_ref(), "drawPath")?;
                    // A missing width means “use the current immediate-mode line width”.
                    if opts.get::<_, Option<f32>>("width")?.is_none()
                        && opts.get::<_, Option<LuaTable>>("stroke")?.is_none()
                    {
                        stroke.width = 0.0;
                    }
                    (mode, close, fill_rule, stroke)
                }
                Some(_) => {
                    return Err(LuaError::RuntimeError(
                        "drawPath: mode or opts must be a string/table".into(),
                    ))
                }
            };
            let draw_mode = parse_draw_mode(&mode)?;
            let (segs, has_close_verb) = parse_path_segments(path, "drawPath")?;
            let close = close || has_close_verb;
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::DrawPath {
                    segments: segs,
                    mode: draw_mode,
                    close,
                    fill_rule,
                    stroke,
                });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- drawGradientRect --
    /// Draws a rectangle with a two-color gradient fill.
    /// @param | x | number | Left edge X.
    /// @param | y | number | Top edge Y.
    /// @param | w | number | Width (must be positive).
    /// @param | h | number | Height (must be positive).
    /// @param | c1 | table | Start color {r, g, b [, a]}.
    /// @param | c2 | table | End color {r, g, b [, a]}.
    /// @param | dir | string? | Direction: "vertical" (default), "horizontal", "diagDown", "diagUp", "radial".
    graphics.set(
        "drawGradientRect",
        lua.create_function(
            move |_,
                  (x, y, w, h, c1, c2, dir): (
                f32,
                f32,
                f32,
                f32,
                LuaTable,
                LuaTable,
                Option<String>,
            )| {
                if w <= 0.0 || h <= 0.0 {
                    return Err(LuaError::RuntimeError(
                        "drawGradientRect: w and h must be positive".into(),
                    ));
                }
                let color1 = [
                    c1.get::<_, f32>(1).unwrap_or(0.0),
                    c1.get::<_, f32>(2).unwrap_or(0.0),
                    c1.get::<_, f32>(3).unwrap_or(0.0),
                    c1.get::<_, f32>(4).unwrap_or(1.0),
                ];
                let color2 = [
                    c2.get::<_, f32>(1).unwrap_or(0.0),
                    c2.get::<_, f32>(2).unwrap_or(0.0),
                    c2.get::<_, f32>(3).unwrap_or(0.0),
                    c2.get::<_, f32>(4).unwrap_or(1.0),
                ];
                let direction = match dir.as_deref().unwrap_or("vertical") {
                    "horizontal" => GradientDirection::Horizontal,
                    "vertical" => GradientDirection::Vertical,
                    "diagDown" => GradientDirection::DiagDown,
                    "diagUp" => GradientDirection::DiagUp,
                    "radial" => GradientDirection::Radial,
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "drawGradientRect: unknown direction '{other}'"
                        )))
                    }
                };
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawGradientRect {
                        x,
                        y,
                        w,
                        h,
                        color1,
                        color2,
                        direction,
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawColoredPolygon --
    /// Draws a polygon with per-vertex colors.
    /// @param | vertices | table | Flat array of x,y coordinates: {x1, y1, x2, y2, ...}.
    /// @param | colors | table | Array of color tables: {{r, g, b, a}, ...}, one per vertex.
    /// @param | mode | string? | "fill" (default) or "line".
    graphics.set("drawColoredPolygon", lua.create_function(
            move |_, (vertices, colors, mode): (LuaTable, LuaTable, Option<String>)| {
                let draw_mode = parse_draw_mode(mode.as_deref().unwrap_or("fill"))?;
                let n = vertices.raw_len();
                if n < 4 || n % 2 != 0 {
                    return Err(LuaError::RuntimeError(
                        "drawColoredPolygon: vertices must be a flat [x,y,...] table with at least 2 pairs".into(),
                    ));
                }
                let mut verts: Vec<f32> = Vec::with_capacity(n);
                for i in 1..=n {
                    verts.push(vertices.get::<_, f32>(i)?);
                }
                let vert_count = n / 2;
                let col_count = colors.raw_len();
                let mut cols: Vec<[f32; 4]> = Vec::with_capacity(vert_count);
                for i in 1..=vert_count {
                    if i <= col_count {
                        let c: LuaTable = colors.get(i)?;
                        cols.push([
                            c.get::<_, f32>(1).unwrap_or(1.0),
                            c.get::<_, f32>(2).unwrap_or(1.0),
                            c.get::<_, f32>(3).unwrap_or(1.0),
                            c.get::<_, f32>(4).unwrap_or(1.0),
                        ]);
                    } else {
                        cols.push([1.0, 1.0, 1.0, 1.0]);
                    }
                }
                s.borrow_mut().render_commands.push(RenderCommand::DrawColoredPolygon {
                    vertices: verts,
                    colors: cols,
                    mode: draw_mode,
                });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawIsoCubeTile --
    /// Draws an isometric cube tile with configurable face colors and optional textures.
    /// @param | sx | number | Screen X position of the tile center.
    /// @param | sy | number | Screen Y position of the tile center.
    /// @param | halfW | number | Half-width of the tile diamond.
    /// @param | halfH | number | Half-height of the tile diamond.
    /// @param | opts | table? | Options: depth, topColor, leftColor, rightColor, topTexture, leftTexture, rightTexture.
    graphics.set(
        "drawIsoCubeTile",
        lua.create_function(
            move |_, (sx, sy, half_w, half_h, opts): (f32, f32, f32, f32, Option<LuaTable>)| {
                let parse_color = |tbl: Option<LuaTable>| -> [f32; 4] {
                    tbl.map(|t| {
                        [
                            t.get::<_, f32>(1).unwrap_or(1.0),
                            t.get::<_, f32>(2).unwrap_or(1.0),
                            t.get::<_, f32>(3).unwrap_or(1.0),
                            t.get::<_, f32>(4).unwrap_or(1.0),
                        ]
                    })
                    .unwrap_or([1.0, 1.0, 1.0, 1.0])
                };
                let (
                    depth,
                    top_color,
                    top_tex_key,
                    left_color,
                    left_tex_key,
                    right_color,
                    right_tex_key,
                ) = if let Some(ref o) = opts {
                    let depth = o.get::<_, f32>("depth").unwrap_or(0.0);
                    let top_color =
                        parse_color(o.get::<_, Option<LuaTable>>("topColor").ok().flatten());
                    let left_color =
                        parse_color(o.get::<_, Option<LuaTable>>("leftColor").ok().flatten());
                    let right_color =
                        parse_color(o.get::<_, Option<LuaTable>>("rightColor").ok().flatten());
                    let top_tex = o
                        .get::<_, Option<LuaAnyUserData>>("topTexture")
                        .ok()
                        .flatten()
                        .and_then(|ud| ud.borrow::<LuaImage>().ok().map(|img| img.key));
                    let left_tex = o
                        .get::<_, Option<LuaAnyUserData>>("leftTexture")
                        .ok()
                        .flatten()
                        .and_then(|ud| ud.borrow::<LuaImage>().ok().map(|img| img.key));
                    let right_tex = o
                        .get::<_, Option<LuaAnyUserData>>("rightTexture")
                        .ok()
                        .flatten()
                        .and_then(|ud| ud.borrow::<LuaImage>().ok().map(|img| img.key));
                    (
                        depth,
                        top_color,
                        top_tex,
                        left_color,
                        left_tex,
                        right_color,
                        right_tex,
                    )
                } else {
                    (
                        0.0,
                        [1.0; 4],
                        None,
                        [0.7, 0.7, 0.7, 1.0],
                        None,
                        [0.5, 0.5, 0.5, 1.0],
                        None,
                    )
                };
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawIsoCubeTile {
                        screen_x: sx,
                        screen_y: sy,
                        half_w,
                        half_h,
                        depth,
                        top_color,
                        top_texture: top_tex_key,
                        left_color,
                        left_texture: left_tex_key,
                        right_color,
                        right_texture: right_tex_key,
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- drawHexTile --
    /// Draws a regular hexagonal tile at the given center position.
    /// @param | cx | number | Center X.
    /// @param | cy | number | Center Y.
    /// @param | size | number | Hex radius (must be positive).
    /// @param | orientation | string? | "pointyTop" (default) or "flatTop".
    /// @param | mode | string? | "line" (default) or "fill".
    graphics.set(
        "drawHexTile",
        lua.create_function(
            move |_,
                  (cx, cy, size, orientation, mode): (
                f32,
                f32,
                f32,
                Option<String>,
                Option<String>,
            )| {
                if size <= 0.0 {
                    return Err(LuaError::RuntimeError(
                        "drawHexTile: size must be positive".into(),
                    ));
                }
                let orientation = match orientation.as_deref().unwrap_or("pointyTop") {
                    "pointyTop" | "pointy" => HexOrientation::PointyTop,
                    "flatTop" | "flat" => HexOrientation::FlatTop,
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "drawHexTile: unknown orientation '{other}'"
                        )))
                    }
                };
                let draw_mode = parse_draw_mode(mode.as_deref().unwrap_or("line"))?;
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawHexTile {
                        cx,
                        cy,
                        size,
                        orientation,
                        mode: draw_mode,
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- beginSortGroup --
    /// Begins a depth-sorted rendering group. Draw calls within this group are sorted by pushSortKey values.
    /// @param | id | integer | Group identifier.
    graphics.set(
        "beginSortGroup",
        lua.create_function(move |_, id: u64| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::BeginSortGroup { group_id: id });
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- pushSortKey --
    /// Sets the depth sort key for subsequent draw calls within the current sort group.
    /// @param | depth | number | Sort depth value (lower draws first).
    graphics.set(
        "pushSortKey",
        lua.create_function(move |_, depth: f32| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::PushSortKey(depth));
            Ok(())
        })?,
    )?;
    let s = state.clone();
    // -- flushSortGroup --
    /// Ends a sort group and emits all accumulated draw calls in sorted order.
    /// @param | id | integer | Group identifier matching the beginSortGroup call.
    graphics.set(
        "flushSortGroup",
        lua.create_function(move |_, id: u64| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::FlushSortGroup { group_id: id });
            Ok(())
        })?,
    )?;
    #[allow(clippy::type_complexity)]
    let s = state.clone();
    // -- drawBevelRect --
    /// Draws a beveled rectangle with highlight, shadow, and fill colors for 3D-style UI elements.
    /// @param | x | number | Left edge X.
    /// @param | y | number | Top edge Y.
    /// @param | w | number | Width (must be positive).
    /// @param | h | number | Height (must be positive).
    /// @param | bevelW | number? | Bevel border width (default 2).
    /// @param | style | string? | Bevel style: "raised" (default), "sunken", "ridge", "groove", "flat".
    /// @param | opts | table? | Options: highlight, shadow, fillColor (each a {r,g,b,a} table).
    graphics.set(
        "drawBevelRect",
        lua.create_function(
            move |_,
                  (x, y, w, h, bevel_w, style, opts): (
                f32,
                f32,
                f32,
                f32,
                Option<f32>,
                Option<String>,
                Option<LuaTable>,
            )| {
                if w <= 0.0 || h <= 0.0 {
                    return Err(LuaError::RuntimeError(
                        "drawBevelRect: w and h must be positive".into(),
                    ));
                }
                let bevel_w = bevel_w.unwrap_or(2.0).max(0.0);
                let bevel_style = match style.as_deref().unwrap_or("raised") {
                    "raised" => BevelStyle::Raised,
                    "sunken" => BevelStyle::Sunken,
                    "ridge" => BevelStyle::Ridge,
                    "groove" => BevelStyle::Groove,
                    "flat" => BevelStyle::Flat,
                    other => {
                        return Err(LuaError::RuntimeError(format!(
                            "drawBevelRect: unknown style '{other}'"
                        )))
                    }
                };
                let parse_color_tbl = |key: &str, def: [f32; 4]| -> [f32; 4] {
                    opts.as_ref()
                        .and_then(|t| t.get::<_, LuaTable>(key).ok())
                        .map(|c| {
                            [
                                c.get::<_, f32>(1).unwrap_or(def[0]),
                                c.get::<_, f32>(2).unwrap_or(def[1]),
                                c.get::<_, f32>(3).unwrap_or(def[2]),
                                c.get::<_, f32>(4).unwrap_or(def[3]),
                            ]
                        })
                        .unwrap_or(def)
                };
                let highlight = parse_color_tbl("highlight", [1.0, 1.0, 1.0, 1.0]);
                let shadow = parse_color_tbl("shadow", [0.2, 0.2, 0.2, 1.0]);
                let fill_color = parse_color_tbl("fillColor", [0.5, 0.5, 0.5, 1.0]);
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::DrawBevelRect {
                        x,
                        y,
                        w,
                        h,
                        bevel_w,
                        style: bevel_style,
                        highlight,
                        shadow,
                        fill_color,
                    });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- pushLayer --
    /// Begins a compositing layer with the given alpha and blend mode. Must be paired with popLayer.
    /// @param | id | integer | Layer identifier (must match the popLayer call).
    /// @param | alpha | number? | Layer opacity (0â€“1, default 1).
    /// @param | blendMode | string? | Blend mode: "alpha" (default), "add", "multiply", "replace", "screen".
    graphics.set(
        "pushLayer",
        lua.create_function(
            move |_, (id, alpha, blend_mode): (u64, Option<f32>, Option<String>)| {
                let alpha = alpha.unwrap_or(1.0).clamp(0.0, 1.0);
                let blend = blend_mode
                    .as_deref()
                    .map(parse_blend_mode)
                    .transpose()?
                    .unwrap_or(BlendMode::Alpha);
                s.borrow_mut()
                    .render_commands
                    .push(RenderCommand::PushLayer { id, alpha, blend });
                Ok(())
            },
        )?,
    )?;
    let s = state.clone();
    // -- popLayer --
    /// Ends a compositing layer and composites it with the previous content.
    /// @param | id | integer | Layer identifier matching the pushLayer call.
    graphics.set(
        "popLayer",
        lua.create_function(move |_, id: u64| {
            s.borrow_mut()
                .render_commands
                .push(RenderCommand::PopLayer { id });
            Ok(())
        })?,
    )?;
    let layer_zorders: Rc<RefCell<std::collections::HashMap<String, i32>>> =
        Rc::new(RefCell::new(std::collections::HashMap::new()));
    let layer_visible: Rc<RefCell<std::collections::HashMap<String, bool>>> =
        Rc::new(RefCell::new(std::collections::HashMap::new()));
    let current_layer: Rc<RefCell<String>> = Rc::new(RefCell::new("default".to_string()));
    let lz = layer_zorders.clone();
    let lv = layer_visible.clone();
    // -- newLayer --
    /// Creates a named rendering layer with an optional z-order for draw call organization.
    /// @param | name | string | Layer name.
    /// @param | zOrder | integer? | Z-order for layer sorting (default 0).
    graphics.set(
        "newLayer",
        lua.create_function(move |_, (name, z_order): (String, Option<i32>)| {
            lz.borrow_mut().insert(name.clone(), z_order.unwrap_or(0));
            lv.borrow_mut().entry(name).or_insert(true);
            Ok(())
        })?,
    )?;
    let cl = current_layer.clone();
    let lz2 = layer_zorders.clone();
    let lv2 = layer_visible.clone();
    // -- setLayer --
    /// Sets the active rendering layer by name. Creates the layer if it does not exist.
    /// @param | name | string | Layer name to activate.
    graphics.set(
        "setLayer",
        lua.create_function(move |_, name: String| {
            lz2.borrow_mut().entry(name.clone()).or_insert(0);
            lv2.borrow_mut().entry(name.clone()).or_insert(true);
            *cl.borrow_mut() = name;
            Ok(())
        })?,
    )?;
    let cl2 = current_layer.clone();
    // -- currentLayer --
    /// Returns the name of the currently active rendering layer.
    /// @return | string | Active layer name.
    graphics.set(
        "currentLayer",
        lua.create_function(move |_, ()| Ok(cl2.borrow().clone()))?,
    )?;
    let lv3 = layer_visible.clone();
    // -- setLayerVisible --
    /// Sets whether a named rendering layer is visible.
    /// @param | name | string | Layer name.
    /// @param | visible | boolean | True to show, false to hide.
    graphics.set(
        "setLayerVisible",
        lua.create_function(move |_, (name, visible): (String, bool)| {
            lv3.borrow_mut().insert(name, visible);
            Ok(())
        })?,
    )?;
    let lv4 = layer_visible.clone();
    // -- isLayerVisible --
    /// Returns whether a named rendering layer is currently visible.
    /// @param | name | string | Layer name.
    /// @return | boolean | True if the layer is visible.
    graphics.set(
        "isLayerVisible",
        lua.create_function(move |_, name: String| Ok(*lv4.borrow().get(&name).unwrap_or(&true)))?,
    )?;
    let lz3 = layer_zorders.clone();
    // -- getLayerZOrder --
    /// Returns the z-order value of a named rendering layer.
    /// @param | name | string | Layer name.
    /// @return | number | Z-order value (default 0 if unset).
    graphics.set(
        "getLayerZOrder",
        lua.create_function(move |_, name: String| Ok(*lz3.borrow().get(&name).unwrap_or(&0)))?,
    )?;
    let lz4 = layer_zorders.clone();
    // -- setLayerZOrder --
    /// Sets the z-order value of a named rendering layer.
    /// @param | name | string | Layer name.
    /// @param | z | integer | New z-order value.
    graphics.set(
        "setLayerZOrder",
        lua.create_function(move |_, (name, z): (String, i32)| {
            lz4.borrow_mut().insert(name, z);
            Ok(())
        })?,
    )?;
    #[cfg(feature = "obj-loader")]
    let state_for_obj = state.clone();
    // -- loadObj --
    /// Loads a Wavefront OBJ model file and returns a model handle for projection and rendering.
    /// @param | path | string | File path to the .obj file relative to the game directory.
    /// @return | LObjModel | The loaded OBJ model handle.
    #[cfg(feature = "obj-loader")]
    graphics.set(
        "loadObj",
        lua.create_function(move |_, path: String| {
            let model = {
                let st = state_for_obj.borrow();
                let source = st.fs.read_string(&path).map_err(|error| {
                    LuaError::RuntimeError(format!("lurek.render.loadObj: {error}"))
                })?;
                let base = Path::new(&path)
                    .parent()
                    .map(Path::to_path_buf)
                    .unwrap_or_default();
                let mut resolver = |reference: &str| {
                    st.fs
                        .read_string(&base.join(reference).to_string_lossy())
                        .map_err(|error| {
                            crate::render::obj_loader::ObjError::Parse(error.to_string())
                        })
                };
                crate::render::obj_loader::ObjLoader::parse_obj_with_resolver(
                    &source,
                    crate::render::obj_loader::ObjLimits::default(),
                    &mut resolver,
                )
            };
            let model =
                model.map_err(|e| LuaError::RuntimeError(format!("loadObj '{}': {}", path, e)))?;
            Ok(LuaObjModel {
                state: state_for_obj.clone(),
                model,
                sprite_cache: std::collections::HashMap::new(),
            })
        })?,
    )?;
    #[cfg(feature = "voxel-loader")]
    let state_for_voxel = state.clone();
    // -- loadVoxel --
    /// Loads a MagicaVoxel `.vox` static prop with palette colours and a configurable world-space voxel size.
    /// @param | path | string | File path to the `.vox` file relative to the game directory.
    /// @param | voxelSize | number? | World-space size of one source voxel (default 1).
    /// @return | LVoxelModel | The loaded voxel model handle.
    #[cfg(feature = "voxel-loader")]
    graphics.set(
        "loadVoxel",
        lua.create_function(move |_, (path, voxel_size): (String, Option<f32>)| {
            let bytes = {
                let st = state_for_voxel.borrow();
                st.fs.read_bytes(&path).map_err(|error| {
                    LuaError::RuntimeError(format!("lurek.render.loadVoxel: {error}"))
                })?
            };
            let model = crate::render::voxel_loader::VoxelModel::load_bytes(
                &bytes,
                voxel_size.unwrap_or(1.0),
            )
            .map_err(|e| LuaError::RuntimeError(format!("loadVoxel '{}': {}", path, e)))?;
            Ok(LuaVoxelModel { model })
        })?,
    )?;
    #[cfg(feature = "obj-loader")]
    let state_for_model = state.clone();
    // -- loadModel --
    /// Loads a 3D model file (OBJ format) and returns a handle for 2D projection and sprite rendering.
    /// @param | path | string | File path to the model file relative to the game directory.
    /// @return | LObjModel | The loaded model handle.
    #[cfg(feature = "obj-loader")]
    graphics.set(
        "loadModel",
        lua.create_function(move |_, path: String| {
            let model = {
                let st = state_for_model.borrow();
                let source = st.fs.read_string(&path).map_err(|error| {
                    LuaError::RuntimeError(format!("lurek.render.loadModel: {error}"))
                })?;
                let base = Path::new(&path)
                    .parent()
                    .map(Path::to_path_buf)
                    .unwrap_or_default();
                let mut resolver = |reference: &str| {
                    st.fs
                        .read_string(&base.join(reference).to_string_lossy())
                        .map_err(|error| {
                            crate::render::obj_loader::ObjError::Parse(error.to_string())
                        })
                };
                crate::render::obj_loader::ObjLoader::parse_obj_with_resolver(
                    &source,
                    crate::render::obj_loader::ObjLimits::default(),
                    &mut resolver,
                )
            };
            let model = model
                .map_err(|e| LuaError::RuntimeError(format!("loadModel '{}': {}", path, e)))?;
            Ok(LuaObjModel {
                state: state_for_model.clone(),
                model,
                sprite_cache: std::collections::HashMap::new(),
            })
        })?,
    )?;
    /// Registers the depth-sorted drawing helper constructor in the render module.
    // -- newDepthSorter --
    /// Creates a new `LDepthSorter` instance for collecting drawable items and flushing them in depth-sorted (painter's algorithm) order. Allocate one sorter per scene or per render pass.
    /// @return | LDepthSorter | A fresh depth sorter with no queued entries.
    graphics.set(
        "newDepthSorter",
        lua.create_function(|_, ()| Ok(LuaDepthSorter::new()))?,
    )?;
    lurek.set("render", graphics)?;
    Ok(())
}
#[cfg(feature = "obj-loader")]
use crate::render::obj_loader::{ObjCamera, ObjModel};
/// Loaded OBJ 3D model handle for CPU-side projection to 2D meshes and sprite rendering.
#[cfg(feature = "obj-loader")]
pub struct LuaObjModel {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) model: ObjModel,
    pub(crate) sprite_cache: std::collections::HashMap<String, TextureKey>,
}
#[cfg(feature = "obj-loader")]
impl LuaUserData for LuaObjModel {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getVertexCount --
        /// Returns the number of vertices in this OBJ model.
        /// @return | number | Vertex count.
        methods.add_method("getVertexCount", |_, this, ()| {
            Ok(this.model.vertex_count())
        });
        // -- getFaceCount --
        /// Returns the number of faces (triangles) in this OBJ model.
        /// @return | number | Face count.
        methods.add_method("getFaceCount", |_, this, ()| Ok(this.model.face_count()));
        // -- getUvCount --
        /// Returns the number of UV texture coordinates in this OBJ model.
        /// @return | number | UV coordinate count.
        methods.add_method("getUvCount", |_, this, ()| Ok(this.model.uv_count()));
        // -- getNormalCount --
        /// Returns the number of vertex normals in this OBJ model.
        /// @return | number | Normal count.
        methods.add_method("getNormalCount", |_, this, ()| {
            Ok(this.model.normal_count())
        });
        // -- renderToImage --
        /// Renders the OBJ model to a GPU texture at the given resolution with optional 90-degree rotation.
        /// @param | width | integer | Output image width in pixels.
        /// @param | height | integer | Output image height in pixels.
        /// @param | rotation | number? | Rotation step (0â€“3, each step = 90 degrees, default 0).
        /// @return | LImage | The rendered image handle.
        methods.add_method_mut(
            "renderToImage",
            |_, this, (width, height, rotation): (u32, u32, Option<u8>)| {
                let rotation = rotation.unwrap_or(0) % 4;
                let cache_key = format!("{}x{}:{}", width, height, rotation);
                if let Some(tex_key) = this.sprite_cache.get(&cache_key).copied() {
                    let st = this.state.borrow();
                    if st.textures.contains_key(tex_key) {
                        drop(st);
                        return Ok(LuaImage {
                            state: this.state.clone(),
                            key: tex_key,
                        });
                    }
                }
                let image = this.model.render_to_image(width, height, rotation);
                let pixels = image.as_bytes().to_vec();
                let mut st = this.state.borrow_mut();
                let tex = Texture::from_rgba(width, height, pixels, &mut st.textures)
                    .map_err(|e| LuaError::RuntimeError(format!("renderToImage: {}", e)))?;
                st.clear_released_texture_handle(tex.key.data().as_ffi());
                this.sprite_cache.insert(cache_key, tex.key);
                Ok(LuaImage {
                    state: this.state.clone(),
                    key: tex.key,
                })
            },
        );
        // -- projectToMesh --
        /// Projects the OBJ model into 2D vertex data using a virtual camera, returning a table of vertex rows.
        /// @param | camera | table | Camera parameters: {x, y, z, tx, ty, tz, fov}.
        /// @param | screenW | number | Screen width for projection.
        /// @param | screenH | number | Screen height for projection.
        /// @return | table | Array of vertex tables: {{x, y, u, v, r, g, b, a}, ...}.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | u | number | U.
        /// @field | v | number | V.
        /// @field | r | number | R.
        /// @field | g | number | G.
        /// @field | b | number | B.
        /// @field | a | number | A.
        methods.add_method(
            "projectToMesh",
            |lua, this, (cam_tbl, screen_w, screen_h): (LuaTable, f32, f32)| {
                let cam = ObjCamera::new(
                    cam_tbl.get::<_, f32>("x").unwrap_or(0.0),
                    cam_tbl.get::<_, f32>("y").unwrap_or(0.0),
                    cam_tbl.get::<_, f32>("z").unwrap_or(5.0),
                    cam_tbl.get::<_, f32>("tx").unwrap_or(0.0),
                    cam_tbl.get::<_, f32>("ty").unwrap_or(0.0),
                    cam_tbl.get::<_, f32>("tz").unwrap_or(0.0),
                    cam_tbl.get::<_, f32>("fov").unwrap_or(60.0),
                );
                let (cam_pos, cam_tgt, fov_y) = cam.to_vecs();
                let mesh = this
                    .model
                    .project_to_mesh(cam_pos, cam_tgt, fov_y, screen_w, screen_h, None);
                let out = lua.create_table()?;
                for (i, v) in mesh.vertices.iter().enumerate() {
                    let row = lua.create_table()?;
                    row.set(1, v.x)?;
                    row.set(2, v.y)?;
                    row.set(3, v.u)?;
                    row.set(4, v.v)?;
                    row.set(5, v.r)?;
                    row.set(6, v.g)?;
                    row.set(7, v.b)?;
                    row.set(8, v.a)?;
                    out.set(i + 1, row)?;
                }
                Ok(out)
            },
        );
    }
}

#[cfg(feature = "voxel-loader")]
use crate::render::voxel_loader::VoxelModel;

/// Loaded static MagicaVoxel model handle for raycaster model instances.
#[cfg(feature = "voxel-loader")]
pub struct LuaVoxelModel {
    pub(crate) model: VoxelModel,
}

#[cfg(feature = "voxel-loader")]
impl LuaUserData for LuaVoxelModel {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getVoxelCount --
        /// Returns the number of occupied source voxels.
        /// @return | integer | Number of occupied voxels in the model.
        methods.add_method("getVoxelCount", |_, this, ()| Ok(this.model.voxel_count()));
        // -- getBounds --
        /// Returns local model bounds as `{minX, minY, minZ, maxX, maxY, maxZ}`.
        /// @return | table | Bounds table with six numeric coordinates.
        methods.add_method("getBounds", |lua, this, ()| {
            let bounds = this.model.bounds();
            let result = lua.create_table()?;
            result.set("minX", bounds[0])?;
            result.set("minY", bounds[1])?;
            result.set("minZ", bounds[2])?;
            result.set("maxX", bounds[3])?;
            result.set("maxY", bounds[4])?;
            result.set("maxZ", bounds[5])?;
            Ok(result)
        });
    }
}
