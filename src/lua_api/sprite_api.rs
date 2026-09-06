//! Registers the `lurek.sprite` Lua API for sprite userdata, clips, quads, frames, and sprite table conversion.

use super::SharedState;
use crate::image::ImageData;
use crate::lua_api::render_api::{
    create_sprite_batch, ensure_shader_target, shader_key_from_userdata, LuaImage, LuaNineSlice,
    LuaShader,
};
use crate::math::{Rect, Vec2};
use crate::render::{ShaderTarget, UniformValue};
use crate::sprite::animator::{AnimatorEvent, SpriteAnimator, SpriteClip};
use crate::sprite::atlas::{parse_aseprite_json, parse_texturepacker_json, SpriteAtlas};
use crate::sprite::sprite::Sprite;
use crate::sprite::sprite_sheet::SpriteSheet;
use crate::sprite::{NineSliceInsets, SpriteLimits, TextureAtlas};
use crate::tilemap::{AutoTileLayout, AutoTileSheet};
use mlua::prelude::*;
use slotmap::KeyData;
use std::borrow::Borrow;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

fn require_positive_u32(api: &str, arg_name: &str, value: u32) -> LuaResult<u32> {
    if value == 0 {
        return Err(LuaError::RuntimeError(format!(
            "{}: {} must be greater than zero",
            api, arg_name
        )));
    }
    Ok(value)
}

/// Converts a public one-based Lua index without allowing zero to alias item one.
fn lua_one_based_index(api: &str, index: usize) -> LuaResult<usize> {
    index.checked_sub(1).ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{api}: index must be one-based (greater than zero)"
        ))
    })
}

fn require_finite(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    if !value.is_finite() {
        return Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be finite"
        )));
    }
    Ok(value)
}

/// Resolves an opaque Lua image ID only while it still names a live render texture.
fn require_live_texture_id(
    state: &Rc<RefCell<SharedState>>,
    api: &str,
    raw_id: usize,
) -> LuaResult<usize> {
    let key = crate::runtime::resource_keys::TextureKey::from(KeyData::from_ffi(raw_id as u64));
    if RefCell::borrow(state.as_ref()).textures.contains_key(key) {
        Ok(raw_id)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: texture handle is invalid or was released"
        )))
    }
}

/// Converts one Lua number to a finite `f32` uniform component.
fn uniform_component(api: &str, value: LuaValue) -> LuaResult<f32> {
    match value {
        LuaValue::Integer(value) if value >= f32::MIN as i64 && value <= f32::MAX as i64 => {
            Ok(value as f32)
        }
        LuaValue::Number(value)
            if value.is_finite() && value >= f32::MIN as f64 && value <= f32::MAX as f64 =>
        {
            Ok(value as f32)
        }
        _ => Err(LuaError::RuntimeError(format!(
            "{api}: uniform vector components must be finite f32 values"
        ))),
    }
}

fn parse_autotile_layout(api: &str, layout: &str) -> LuaResult<AutoTileLayout> {
    match layout {
        "blob47" => Ok(AutoTileLayout::Blob47),
        "composite48" => Ok(AutoTileLayout::Composite48),
        "rpgmaker48" | "rpgmaker" => Ok(AutoTileLayout::RpgMaker48),
        "minimal16" => Ok(AutoTileLayout::Minimal16),
        other => Err(LuaError::RuntimeError(format!(
            "{}: unknown layout '{}', use 'blob47', 'composite48', 'rpgmaker48', or 'minimal16'",
            api, other
        ))),
    }
}

fn sheet_from_image_options(image: &ImageData, opts: LuaTable) -> LuaResult<SpriteSheet> {
    let image_w = image.width();
    let image_h = image.height();
    let frame_w = opts
        .get::<_, Option<u32>>("frameWidth")?
        .or_else(|| opts.get::<_, Option<u32>>("fw").ok().flatten())
        .or_else(|| {
            opts.get::<_, Option<u32>>("columns")
                .ok()
                .flatten()
                .and_then(|cols| (cols > 0).then_some(image_w / cols))
        })
        .ok_or_else(|| {
            LuaError::RuntimeError(
                "lurek.sprite.newSheetFromImage: expected frameWidth or columns".into(),
            )
        })?;
    let frame_h = opts
        .get::<_, Option<u32>>("frameHeight")?
        .or_else(|| opts.get::<_, Option<u32>>("fh").ok().flatten())
        .or_else(|| {
            opts.get::<_, Option<u32>>("rows")
                .ok()
                .flatten()
                .and_then(|rows| (rows > 0).then_some(image_h / rows))
        })
        .ok_or_else(|| {
            LuaError::RuntimeError(
                "lurek.sprite.newSheetFromImage: expected frameHeight or rows".into(),
            )
        })?;
    let frame_w = require_positive_u32("lurek.sprite.newSheetFromImage", "frameWidth", frame_w)?;
    let frame_h = require_positive_u32("lurek.sprite.newSheetFromImage", "frameHeight", frame_h)?;
    SpriteSheet::try_new(image_w, image_h, frame_w, frame_h)
        .map_err(|e| LuaError::RuntimeError(format!("lurek.sprite.newSheetFromImage: {e}")))
}

fn animator_from_lua(clips: Option<LuaTable>) -> LuaResult<SpriteAnimator> {
    let mut parsed = HashMap::new();
    if let Some(clips_table) = clips {
        for pair in clips_table.pairs::<String, LuaTable>() {
            let (name, def) = pair?;
            if name.is_empty() || name.len() > SpriteLimits::MAX_NAME_BYTES {
                return Err(LuaError::RuntimeError(
                    "lurek.sprite.newAnimator: clip name is empty or too long".into(),
                ));
            }
            if parsed.len() >= SpriteLimits::MAX_CLIPS {
                return Err(LuaError::RuntimeError(
                    "lurek.sprite.newAnimator: too many clips".into(),
                ));
            }
            parsed.insert(name, clip_from_lua(def)?);
        }
    }
    Ok(SpriteAnimator::new(parsed))
}

fn atlas_from_image_json(image: &ImageData, atlas_json: &str) -> LuaResult<SpriteAtlas> {
    let atlas = parse_texturepacker_json(atlas_json)
        .or_else(|_| parse_aseprite_json(atlas_json))
        .map_err(|e| LuaError::RuntimeError(format!("newAtlasFromImage: {e}")))?;
    atlas
        .validate_bounds(image.width(), image.height())
        .map_err(|e| LuaError::RuntimeError(format!("newAtlasFromImage: {e}")))?;
    Ok(atlas)
}

fn autotile_sheet_from_options(
    image: &ImageData,
    layout: &str,
    opts: LuaTable,
) -> LuaResult<AutoTileSheet> {
    let tile_w = opts
        .get::<_, Option<u32>>("tileWidth")?
        .or_else(|| opts.get::<_, Option<u32>>("tileW").ok().flatten())
        .unwrap_or(image.width());
    let tile_h = opts
        .get::<_, Option<u32>>("tileHeight")?
        .or_else(|| opts.get::<_, Option<u32>>("tileH").ok().flatten())
        .unwrap_or(image.height());
    Ok(AutoTileSheet::new(
        require_positive_u32("lurek.sprite.newAutoTileSheet", "tileWidth", tile_w)?,
        require_positive_u32("lurek.sprite.newAutoTileSheet", "tileHeight", tile_h)?,
        parse_autotile_layout("lurek.sprite.newAutoTileSheet", layout)?,
    ))
}

fn nine_slice_from_image(
    image: LuaAnyUserData,
    top: f32,
    right: f32,
    bottom: f32,
    left: f32,
) -> LuaResult<LuaNineSlice> {
    if !top.is_finite()
        || !right.is_finite()
        || !bottom.is_finite()
        || !left.is_finite()
        || top < 0.0
        || right < 0.0
        || bottom < 0.0
        || left < 0.0
    {
        return Err(LuaError::RuntimeError(
            "lurek.sprite.newNineSlice: border insets must be non-negative".into(),
        ));
    }
    let img = image.borrow::<LuaImage>()?;
    let state = RefCell::borrow(img.state.as_ref());
    let (tex_w, tex_h) = state
        .textures
        .get(img.key)
        .map(|texture| (texture.width, texture.height))
        .ok_or_else(|| {
            LuaError::RuntimeError("lurek.sprite.newNineSlice: image handle is invalid".into())
        })?;
    if tex_w == 0 || tex_h == 0 || left + right > tex_w as f32 || top + bottom > tex_h as f32 {
        return Err(LuaError::RuntimeError(
            "lurek.sprite.newNineSlice: insets must fit the live texture".into(),
        ));
    }
    Ok(LuaNineSlice {
        key: img.key,
        tex_w,
        tex_h,
        top,
        right,
        bottom,
        left,
    })
}

fn lua_value_to_uniform(api: &str, value: LuaValue) -> LuaResult<UniformValue> {
    match value {
        LuaValue::Number(n) if n.is_finite() && n >= f32::MIN as f64 && n <= f32::MAX as f64 => {
            Ok(UniformValue::Float(n as f32))
        }
        LuaValue::Number(_) => Err(LuaError::RuntimeError(format!(
            "{api}: float uniform must be finite and within f32 range"
        ))),
        LuaValue::Integer(n) => i32::try_from(n).map(UniformValue::Int).map_err(|_| {
            LuaError::RuntimeError(format!("{api}: integer uniform exceeds i32 range"))
        }),
        LuaValue::Boolean(b) => Ok(UniformValue::Bool(b)),
        LuaValue::Table(t) => match t.raw_len() {
            2 => Ok(UniformValue::Vec2([
                uniform_component(api, t.get(1)?)?,
                uniform_component(api, t.get(2)?)?,
            ])),
            3 => Ok(UniformValue::Vec3([
                uniform_component(api, t.get(1)?)?,
                uniform_component(api, t.get(2)?)?,
                uniform_component(api, t.get(3)?)?,
            ])),
            4 => Ok(UniformValue::Vec4([
                uniform_component(api, t.get(1)?)?,
                uniform_component(api, t.get(2)?)?,
                uniform_component(api, t.get(3)?)?,
                uniform_component(api, t.get(4)?)?,
            ])),
            _ => Err(LuaError::RuntimeError(format!(
                "{api}: uniform table must have 2, 3, or 4 elements"
            ))),
        },
        other => Err(LuaError::RuntimeError(format!(
            "{api}: uniform value must be number, boolean, or numeric table, got {}",
            other.type_name()
        ))),
    }
}

/// Lua-visible single sprite data container, including optional normal-map metadata for lit sprites.
pub struct LuaSprite {
    state: Rc<RefCell<SharedState>>,
    inner: Sprite,
}
impl LuaUserData for LuaSprite {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setPosition --
        /// Sets the sprite anchor position in pixels.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        methods.add_method_mut("setPosition", |_, this, (x, y): (f32, f32)| {
            require_finite("LSprite:setPosition", "x", x)?;
            require_finite("LSprite:setPosition", "y", y)?;
            this.inner.set_position(x, y);
            Ok(())
        });
        // -- getPosition --
        /// Returns the sprite anchor position in pixels.
        /// @return | number | World X position.
        /// @return | number | World Y position.
        methods.add_method("getPosition", |_, this, ()| {
            Ok((this.inner.position.x, this.inner.position.y))
        });
        // -- setNormalMap --
        /// Assigns the texture used as this sprite's normal map for lit sprite workflows.
        /// @param | texture_id | integer | Live opaque image handle used as the normal-map source.
        methods.add_method_mut("setNormalMap", |_, this, texture_id: usize| {
            let texture_id =
                require_live_texture_id(&this.state, "LSprite:setNormalMap", texture_id)?;
            this.inner.set_normal_map(texture_id);
            Ok(())
        });
        // -- clearNormalMap --
        /// Removes the assigned normal map from this sprite.
        methods.add_method_mut("clearNormalMap", |_, this, ()| {
            this.inner.clear_normal_map();
            Ok(())
        });
        // -- hasNormalMap --
        /// Returns whether the sprite currently has a normal map.
        /// @return | boolean | True when a normal map is assigned.
        methods.add_method("hasNormalMap", |_, this, ()| {
            Ok(this.inner.has_normal_map())
        });
        // -- getNormalMap --
        /// Returns the assigned normal-map texture handle, or nil when absent.
        /// @return | integer | Texture handle for the normal map.
        methods.add_method("getNormalMap", |_, this, ()| {
            Ok(this.inner.get_normal_map())
        });
        // -- setNormalIntensity --
        /// Sets the normal-map intensity used by lit sprite workflows.
        /// @param | intensity | number | Non-negative intensity multiplier.
        methods.add_method_mut("setNormalIntensity", |_, this, intensity: f32| {
            require_finite("LSprite:setNormalIntensity", "intensity", intensity)?;
            if intensity < 0.0 {
                return Err(LuaError::RuntimeError(
                    "LSprite:setNormalIntensity: intensity must be non-negative".into(),
                ));
            }
            this.inner.set_normal_intensity(intensity);
            Ok(())
        });
        // -- getNormalIntensity --
        /// Returns the normal-map intensity multiplier.
        /// @return | number | Current non-negative intensity multiplier.
        methods.add_method("getNormalIntensity", |_, this, ()| {
            Ok(this.inner.get_normal_intensity())
        });
        // -- setShader --
        /// Sets or clears the render-owned sprite material shader.
        /// @param | shader | LShader? | Sprite-target shader or nil to clear.
        methods.add_method_mut("setShader", |_, this, shader: Option<LuaAnyUserData>| {
            let key = match shader {
                Some(ud) => {
                    let key = shader_key_from_userdata(&ud)?;
                    let st = this.state.as_ref().borrow();
                    ensure_shader_target(&st, key, ShaderTarget::Sprite, "LSprite:setShader")?;
                    Some(key)
                }
                None => None,
            };
            this.inner.set_shader(key);
            Ok(())
        });
        // -- getShader --
        /// Returns the sprite material shader bound to this sprite, if any.
        /// @return | LShader | Bound shader or nil.
        methods.add_method("getShader", |_, this, ()| {
            Ok(this.inner.get_shader().map(|key| LuaShader {
                state: this.state.clone(),
                key,
            }))
        });
        // -- setShaderUniform --
        /// Sends a uniform value to the shader bound to this sprite.
        /// @param | name | string | Uniform name.
        /// @param | value | number|boolean|table | Uniform value.
        methods.add_method_mut(
            "setShaderUniform",
            |_, this, (name, value): (String, LuaValue)| {
                if name.is_empty() || name.len() > SpriteLimits::MAX_NAME_BYTES {
                    return Err(LuaError::RuntimeError(
                        "LSprite:setShaderUniform: uniform name is empty or too long".into(),
                    ));
                }
                let key = this.inner.get_shader().ok_or_else(|| {
                    LuaError::runtime("LSprite:setShaderUniform: no shader is bound")
                })?;
                let uniform = lua_value_to_uniform("LSprite:setShaderUniform", value)?;
                let mut st = this.state.borrow_mut();
                let shader = st.shaders.get_mut(key).ok_or_else(|| {
                    LuaError::runtime("LSprite:setShaderUniform: shader handle is invalid")
                })?;
                shader.send(name, uniform).map_err(|err| {
                    LuaError::RuntimeError(format!("LSprite:setShaderUniform: {err}"))
                })?;
                Ok(())
            },
        );
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always `"LSprite"`.
        methods.add_method("type", |_, _, ()| Ok("LSprite"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object is the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSprite" || name == "LObject")
        });
    }
}

/// Lua-visible wrapper around a SpriteSheet, providing grid-based frame access,.
/// named animation groups, and row/column slicing for sprite sheet textures.
pub struct LuaSpriteSheet {
    pub(crate) inner: SpriteSheet,
}
impl LuaUserData for LuaSpriteSheet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getFrame --
        /// Returns the UV quad for a single frame by its 1-based index.
        /// @param | index | integer | 1-based frame index in the sprite sheet.
        /// @return | table | Quad table `{x, y, w, h}` with normalized UV coordinates, or nil if the index is out of range.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | w | number | W.
        /// @field | h | number | H.
        methods.add_method("getFrame", |lua, this, index: usize| {
            let index = lua_one_based_index("LSpriteSheet:getFrame", index)?;
            match this.inner.get_frame(index) {
                Some(r) => {
                    let t = quad_table(lua, r)?;
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            }
        });
        // -- getFrameCount --
        /// Returns the total number of frames in this sprite sheet.
        /// @return | integer | Total frame count (columns Ă— rows).
        methods.add_method("getFrameCount", |_, this, ()| {
            Ok(this.inner.get_frame_count())
        });
        // -- getRow --
        /// Returns all frame quads in the given row of the sprite sheet grid.
        /// @param | row | integer | 0-based row index.
        /// @return | table | Array of quad tables `{x, y, w, h}`.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | w | number | W.
        /// @field | h | number | H.
        methods.add_method("getRow", |lua, this, row: u32| {
            let frames = this.inner.get_row(row);
            frames_to_table(lua, frames)
        });
        // -- getColumn --
        /// Returns all frame quads in the given column of the sprite sheet grid.
        /// @param | col | integer | 0-based column index.
        /// @return | table | Array of quad tables `{x, y, w, h}`.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | w | number | W.
        /// @field | h | number | H.
        methods.add_method("getColumn", |lua, this, col: u32| {
            frames_iter_to_table(lua, this.inner.get_column(col))
        });
        // -- getGroupFrames --
        /// Returns the frame quads for a named animation group.
        /// @param | name | string | Name of the animation group (e.g. "walk", "idle").
        /// @return | table | Array of quad tables for the group, or nil if the group does not exist.
        /// @field | x | number | X position in atlas.
        /// @field | y | number | Y position in atlas.
        /// @field | w | number | Width.
        /// @field | h | number | Height.
        methods.add_method("getGroupFrames", |lua, this, name: String| {
            match this.inner.get_group(&name) {
                Some(frames) => {
                    let t = frames_to_table(lua, &frames)?;
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            }
        });
        // -- getGroupNames --
        /// Returns an array of all named animation group names defined on this sheet.
        /// @return | string[] | Group name strings.
        methods.add_method("getGroupNames", |lua, this, ()| {
            let names = this.inner.get_group_names();
            let t = lua.create_table()?;
            for (i, n) in names.iter().enumerate() {
                t.set(i + 1, n.as_str())?;
            }
            Ok(t)
        });
        // -- nameGroup --
        /// Defines a named animation group as a contiguous range of frames.
        /// @param | name | string | Name for the group (e.g. "attack").
        /// @param | start | integer | 1-based start frame index.
        /// @param | count | integer | Number of frames in the group.
        methods.add_method_mut(
            "nameGroup",
            |_, this, (name, start, count): (String, usize, usize)| {
                let start = lua_one_based_index("LSpriteSheet:nameGroup", start)?;
                if name.is_empty() || name.len() > SpriteLimits::MAX_NAME_BYTES {
                    return Err(LuaError::RuntimeError(
                        "LSpriteSheet:nameGroup: group name is empty or too long".into(),
                    ));
                }
                if this.inner.group_count() >= SpriteLimits::MAX_GROUPS
                    && this.inner.get_group(&name).is_none()
                {
                    return Err(LuaError::RuntimeError(
                        "LSpriteSheet:nameGroup: too many named groups".into(),
                    ));
                }
                if count == 0
                    || start
                        .checked_add(count)
                        .is_none_or(|end| end > this.inner.get_frame_count())
                {
                    return Err(LuaError::RuntimeError(
                        "LSpriteSheet:nameGroup: range is out of bounds".into(),
                    ));
                }
                this.inner.name_group(name, start, count);
                Ok(())
            },
        );
        // -- getFrameSize --
        /// Returns the pixel dimensions of a single frame cell.
        /// @return | integer | Frame width in pixels.
        /// @return | integer | Frame height in pixels.
        methods.add_method("getFrameSize", |_, this, ()| {
            let (w, h) = this.inner.get_frame_size();
            Ok((w, h))
        });
        // -- getGridSize --
        /// Returns the number of columns and rows in the sprite sheet grid.
        /// @return | integer | Number of columns.
        /// @return | integer | Number of rows.
        methods.add_method("getGridSize", |_, this, ()| {
            let (cols, rows) = this.inner.get_grid_size();
            Ok((cols, rows))
        });
        // -- toFrames --
        /// Returns frame rectangle DTOs for all frames or a named group.
        /// @param | group | string? | Optional group name.
        /// @return | table | Array of `{x, y, w, h}` frame rectangles.
        methods.add_method("toFrames", |lua, this, group: Option<String>| {
            if let Some(group) = group {
                match this.inner.get_group(&group) {
                    Some(frames) => frames_to_table(lua, &frames),
                    None => Ok(lua.create_table()?),
                }
            } else {
                let mut frames = Vec::with_capacity(this.inner.get_frame_count());
                for i in 0..this.inner.get_frame_count() {
                    if let Some(frame) = this.inner.get_frame(i) {
                        frames.push(frame);
                    }
                }
                frames_to_table(lua, &frames)
            }
        });
        // -- toAnimationClip --
        /// Builds an animation clip DTO from this sheet without creating playback state.
        /// @param | opts | table? | `{name, group, fps, loop, mode}`.
        /// @return | table | Clip DTO with `name`, `frames`, `fps`, `loop`, and `mode`.
        methods.add_method("toAnimationClip", |lua, this, opts: Option<LuaTable>| {
            let name = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<String>>("name").ok().flatten())
                .unwrap_or_else(|| "default".to_string());
            let group = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<String>>("group").ok().flatten());
            let fps = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<f32>>("fps").ok().flatten())
                .unwrap_or(12.0);
            let looping = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<bool>>("loop").ok().flatten())
                .unwrap_or(true);
            let mode = opts
                .as_ref()
                .and_then(|t| t.get::<_, Option<String>>("mode").ok().flatten())
                .unwrap_or_else(|| "forward".to_string());
            let frames_value = match group {
                Some(group) => match this.inner.get_group(&group) {
                    Some(frames) => frames_to_table(lua, &frames)?,
                    None => lua.create_table()?,
                },
                None => {
                    let mut frames = Vec::with_capacity(this.inner.get_frame_count());
                    for i in 0..this.inner.get_frame_count() {
                        if let Some(frame) = this.inner.get_frame(i) {
                            frames.push(frame);
                        }
                    }
                    frames_to_table(lua, &frames)?
                }
            };
            let out = lua.create_table()?;
            out.set("name", name)?;
            out.set("frames", frames_value)?;
            out.set("fps", fps)?;
            out.set("loop", looping)?;
            out.set("mode", mode)?;
            Ok(out)
        });
        // -- drawToImage --
        /// Renders the sprite sheet grid into an LImage of the given size for debugging or previews.
        /// @param | w | integer | Output image width in pixels.
        /// @param | h | integer | Output image height in pixels.
        /// @return | LImage | A new image containing the rendered sprite sheet.
        methods.add_method("drawToImage", |lua, this, (w, h): (u32, u32)| {
            let img = this.inner.draw_to_image(w, h);
            lua.create_userdata(img)
        });
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always `"LSpriteSheet"`.
        methods.add_method("type", |_, _, ()| Ok("LSpriteSheet"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. `"LSpriteSheet"` or `"Object"`).
        /// @return | boolean | True if the object is the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpriteSheet" || name == "LObject")
        });
    }
}

/// Lua-visible wrapper around a SpriteAtlas, providing named region lookups.
/// for packed texture atlases exported from tools like TexturePacker or Aseprite.
pub struct LuaSpriteAtlas {
    pub(crate) inner: SpriteAtlas,
}
impl LuaUserData for LuaSpriteAtlas {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getEntry --
        /// Looks up a named sprite region in the atlas by its original filename or tag.
        /// @param | name | string | Entry name (e.g. `"player_idle_0"`).
        /// @return | table | Entry table `{name, x, y, w, h, rotated}`, or nil if the entry is not found.
        /// @field | name | string | Entry name.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | w | number | W.
        /// @field | h | number | H.
        /// @field | rotated | boolean | Whether the entry is rotated.
        methods.add_method("getEntry", |lua, this, name: String| {
            match this.inner.get_entry(&name) {
                Some(e) => {
                    let t = lua.create_table()?;
                    /// Performs the 'name' operation.
                    t.set("name", e.name.as_str())?;
                    /// The 'x' field value exposed to Lua scripts.
                    t.set("x", e.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    t.set("y", e.y)?;
                    /// The 'w' field value exposed to Lua scripts.
                    t.set("w", e.w)?;
                    /// The 'h' field value exposed to Lua scripts.
                    t.set("h", e.h)?;
                    /// Performs the 'rotated' operation.
                    t.set("rotated", e.rotated)?;
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            }
        });
        // -- getByIndex --
        /// Returns a sprite region by its 1-based index in the atlas.
        /// @param | index | integer | 1-based entry index.
        /// @return | table | Entry table `{name, x, y, w, h, rotated}`, or nil if the index is out of range.
        /// @field | name | string | Entry name.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | w | number | W.
        /// @field | h | number | H.
        /// @field | rotated | boolean | Whether the entry is rotated.
        /// @field | flip_x | boolean | Flip horizontally.
        /// @field | flip_y | boolean | Flip vertically.
        methods.add_method("getByIndex", |lua, this, index: usize| {
            let index = lua_one_based_index("LSpriteAtlas:getByIndex", index)?;
            match this.inner.get_by_index(index) {
                Some(e) => {
                    let t = lua.create_table()?;
                    /// Performs the 'name' operation.
                    t.set("name", e.name.as_str())?;
                    /// The 'x' field value exposed to Lua scripts.
                    t.set("x", e.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    t.set("y", e.y)?;
                    /// The 'w' field value exposed to Lua scripts.
                    t.set("w", e.w)?;
                    /// The 'h' field value exposed to Lua scripts.
                    t.set("h", e.h)?;
                    /// Performs the 'rotated' operation.
                    t.set("rotated", e.rotated)?;
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            }
        });
        // -- entryCount --
        /// Returns the total number of entries (sprite regions) in the atlas.
        /// @return | integer | Entry count.
        methods.add_method("entryCount", |_, this, ()| Ok(this.inner.entry_count()));
        // -- entryNames --
        /// Returns an array of all entry names in the atlas.
        /// @return | string[] | Name strings.
        methods.add_method("entryNames", |lua, this, ()| {
            let names = this.inner.entry_names();
            let t = lua.create_table()?;
            for (i, n) in names.iter().enumerate() {
                t.set(i + 1, *n)?;
            }
            Ok(t)
        });
        // -- getFlipped --
        /// Returns a copy of a named atlas entry with the specified flip flags applied.
        /// @param | name | string | Entry name to look up.
        /// @param | flip_x | boolean | Mirror horizontally.
        /// @param | flip_y | boolean | Mirror vertically.
        /// @return | table | Entry table with added `flip_x` and `flip_y` fields, or nil if the entry is not found.
        /// @field | name | string | Entry name.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | w | number | W.
        /// @field | h | number | H.
        /// @field | rotated | boolean | Whether the entry is rotated.
        /// @field | flip_x | boolean | Flip horizontally.
        /// @field | flip_y | boolean | Flip vertically.
        methods.add_method(
            "getFlipped",
            |lua, this, (name, flip_x, flip_y): (String, bool, bool)| match this
                .inner
                .get_entry(&name)
            {
                Some(e) => {
                    let flipped = e.get_flipped(flip_x, flip_y);
                    let t = lua.create_table()?;
                    /// Performs the 'name' operation.
                    t.set("name", flipped.name.as_str())?;
                    /// The 'x' field value exposed to Lua scripts.
                    t.set("x", flipped.x)?;
                    /// The 'y' field value exposed to Lua scripts.
                    t.set("y", flipped.y)?;
                    /// The 'w' field value exposed to Lua scripts.
                    t.set("w", flipped.w)?;
                    /// The 'h' field value exposed to Lua scripts.
                    t.set("h", flipped.h)?;
                    /// Performs the 'rotated' operation.
                    t.set("rotated", flipped.rotated)?;
                    /// Performs the 'flip_x' operation.
                    t.set("flip_x", flipped.flip_x)?;
                    /// Performs the 'flip_y' operation.
                    t.set("flip_y", flipped.flip_y)?;
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            },
        );
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always `"LSpriteAtlas"`.
        methods.add_method("type", |_, _, ()| Ok("LSpriteAtlas"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. `"LSpriteAtlas"` or `"Object"`).
        /// @return | boolean | True if the object is the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpriteAtlas" || name == "LObject")
        });
    }
}

/// Lua-visible autotile sheet authored from a sprite/image source.
pub struct LuaSpriteAutoTileSheet {
    inner: AutoTileSheet,
}
impl LuaUserData for LuaSpriteAutoTileSheet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getLayout --
        /// Returns the autotile layout name used by this sheet.
        /// @return | string | Layout name.
        methods.add_method("getLayout", |_, this, ()| {
            Ok(this.inner.get_layout_name().to_string())
        });
        // -- getDefaultMode --
        /// Returns the default autotile matching mode for this layout.
        /// @return | string | Mode name.
        methods.add_method("getDefaultMode", |_, this, ()| {
            Ok(this.inner.get_default_mode().as_str().to_string())
        });
        // -- getTileCount --
        /// Returns the number of logical tiles in the sheet.
        /// @return | integer | Tile count.
        methods.add_method("getTileCount", |_, this, ()| {
            Ok(this.inner.get_tile_count())
        });
        // -- getQuad --
        /// Returns a one-based tile source rectangle.
        /// @param | tile_id | integer | One-based tile id.
        /// @return | table | Rectangle table.
        methods.add_method("getQuad", |lua, this, tile_id: u32| {
            let tile_id =
                lua_one_based_index("LSpriteAutoTileSheet:getQuad", tile_id as usize)? as u32;
            let r = this.inner.get_quad(tile_id);
            quad_table(lua, r)
        });
        // -- getBitmaskForTile --
        /// Returns the bitmask for a one-based tile id.
        /// @param | tile_id | integer | One-based tile id.
        /// @return | integer | Bitmask.
        methods.add_method("getBitmaskForTile", |_, this, tile_id: u32| {
            let tile_id =
                lua_one_based_index("LSpriteAutoTileSheet:getBitmaskForTile", tile_id as usize)?
                    as u32;
            Ok(this.inner.get_bitmask_for_tile(tile_id))
        });
        // -- getTileForBitmask --
        /// Returns a one-based tile id for a bitmask, or nil when missing.
        /// @param | bitmask | integer | Neighbor bitmask.
        /// @return | integer|nil | One-based tile id.
        methods.add_method("getTileForBitmask", |_, this, bitmask: u16| {
            Ok(this.inner.get_tile_for_bitmask(bitmask).map(|idx| idx + 1))
        });
        // -- toFrames --
        /// Returns all autotile source rectangles as sprite frame DTOs.
        /// @return | table | Array of frame rectangles.
        methods.add_method("toFrames", |lua, this, ()| {
            let mut frames = Vec::with_capacity(this.inner.get_tile_count() as usize);
            for i in 0..this.inner.get_tile_count() {
                frames.push(this.inner.get_quad(i));
            }
            frames_to_table(lua, &frames)
        });
        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | The string `LSpriteAutoTileSheet`.
        methods.add_method("type", |_, _, ()| Ok("LSpriteAutoTileSheet"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True when the supplied type name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpriteAutoTileSheet" || name == "LObject")
        });
    }
}

/// Lua-visible wrapper around an in-memory atlas packer for dynamic sprite region allocation.
pub struct LuaAtlasPacker {
    inner: TextureAtlas,
}
impl LuaUserData for LuaAtlasPacker {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- pack --
        /// Packs a named region into this atlas and returns success plus an optional failure code.
        /// @param | name | string | Region key used for later lookups.
        /// @param | w | integer | Region width in pixels.
        /// @param | h | integer | Region height in pixels.
        /// @return | boolean | True when the region was packed.
        /// @return | string | `duplicate`, `invalid`, `overflow`, or `full` when packing fails.
        methods.add_method_mut(
            "pack",
            |lua, this, (name, w, h): (String, u32, u32)| match this
                .inner
                .pack_checked(&name, w, h, None)
            {
                Ok(()) => Ok((true, LuaValue::Nil)),
                Err(reason) => Ok((false, LuaValue::String(lua.create_string(reason.as_str())?))),
            },
        );
        // -- setNineSlice --
        /// Sets nine-slice insets for a previously packed region.
        /// @param | name | string | Packed region key.
        /// @param | left | integer | Left inset in pixels.
        /// @param | right | integer | Right inset in pixels.
        /// @param | top | integer | Top inset in pixels.
        /// @param | bottom | integer | Bottom inset in pixels.
        /// @return | boolean | True when insets were applied.
        methods.add_method_mut(
            "setNineSlice",
            |_, this, (name, left, right, top, bottom): (String, u32, u32, u32, u32)| {
                Ok(this.inner.set_nine_slice(
                    &name,
                    Some(NineSliceInsets {
                        left,
                        right,
                        top,
                        bottom,
                    }),
                ))
            },
        );
        // -- getRegion --
        /// Returns the named packed atlas region, or nil if not found.
        /// @param | name | string | Region key to fetch.
        /// @return | table | Region table `{name, x, y, w, h, nine_slice}` or nil when missing.
        /// @field | name | string | Region key.
        /// @field | x | integer | Left coordinate in atlas pixels.
        /// @field | y | integer | Top coordinate in atlas pixels.
        /// @field | w | integer | Region width in pixels.
        /// @field | h | integer | Region height in pixels.
        /// @field | nine_slice | table? | Optional nine-slice inset table `{left, right, top, bottom}`.
        methods.add_method("getRegion", |lua, this, name: String| {
            match this.inner.get_region(&name) {
                Some(region) => {
                    let t = lua.create_table()?;
                    t.set("name", region.name.as_str())?;
                    t.set("x", region.x)?;
                    t.set("y", region.y)?;
                    t.set("w", region.w)?;
                    t.set("h", region.h)?;
                    if let Some(insets) = region.nine_slice {
                        let ns = lua.create_table()?;
                        ns.set("left", insets.left)?;
                        ns.set("right", insets.right)?;
                        ns.set("top", insets.top)?;
                        ns.set("bottom", insets.bottom)?;
                        t.set("nine_slice", ns)?;
                    } else {
                        t.set("nine_slice", LuaValue::Nil)?;
                    }
                    Ok(LuaValue::Table(t))
                }
                None => Ok(LuaValue::Nil),
            }
        });
        // -- regionCount --
        /// Returns the number of currently packed regions.
        /// @return | integer | Region count.
        methods.add_method("regionCount", |_, this, ()| {
            Ok(this.inner.get_region_count())
        });
        // -- getDimensions --
        /// Returns the current width and height of this atlas packer.
        /// @return | integer | Atlas width in pixels.
        /// @return | integer | Atlas height in pixels.
        methods.add_method("getDimensions", |_, this, ()| {
            Ok(this.inner.get_dimensions())
        });
        // -- clear --
        /// Removes all packed regions and resets packing shelves.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always `"LAtlasPacker"`.
        methods.add_method("type", |_, _, ()| Ok("LAtlasPacker"));
        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check (e.g. `"LAtlasPacker"` or `"Object"`).
        /// @return | boolean | True if the object is the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAtlasPacker" || name == "LObject")
        });
    }
}

/// Lua-visible wrapper around Rust-side clip animation playback state.
pub struct LuaSpriteAnimator {
    inner: RefCell<SpriteAnimator>,
    on_frame: RefCell<Option<LuaRegistryKey>>,
    on_loop: RefCell<Option<LuaRegistryKey>>,
    on_end: RefCell<Option<LuaRegistryKey>>,
}

impl LuaUserData for LuaSpriteAnimator {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- play --
        /// Plays or restarts a named animation clip.
        /// @param | name | string | Clip name.
        /// @param | restart | boolean? | Whether to restart when already playing this clip. Defaults to true.
        /// @return | boolean | True when the named clip exists and playback started.
        methods.add_method(
            "play",
            |_, this, (name, restart): (String, Option<bool>)| {
                Ok(this.inner.borrow_mut().play(&name, restart.unwrap_or(true)))
            },
        );

        // -- pause --
        /// Pause playback without resetting frame state.
        methods.add_method("pause", |_, this, ()| {
            this.inner.borrow_mut().pause();
            Ok(())
        });

        // -- resume --
        /// Resume playback from current frame when a clip is selected.
        methods.add_method("resume", |_, this, ()| {
            this.inner.borrow_mut().resume();
            Ok(())
        });

        // -- stop --
        /// Stop playback and reset to the first frame of the current clip.
        methods.add_method("stop", |_, this, ()| {
            this.inner.borrow_mut().stop();
            Ok(())
        });

        // -- isPlaying --
        /// Return whether the animator is currently playing.
        /// @return | boolean | True when playing.
        methods.add_method("isPlaying", |_, this, ()| {
            Ok(this.inner.borrow().is_playing())
        });

        // -- currentClip --
        /// Return the currently selected clip name.
        /// @return | string | Active clip name, or nil if none.
        methods.add_method("currentClip", |_, this, ()| {
            Ok(this
                .inner
                .borrow()
                .current_clip()
                .map(|name| name.to_string()))
        });

        // -- currentFrame --
        /// Return current draw frame as sprite-sheet row and column.
        /// @return | integer | Sprite-sheet row.
        /// @return | integer | Sprite-sheet column (frame index).
        methods.add_method("currentFrame", |_, this, ()| {
            Ok(this.inner.borrow().current_frame())
        });

        // -- update --
        /// Advance playback by delta time and dispatch callback events.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("update", |lua, this, dt: f32| {
            let frame_cb = match this.on_frame.borrow().as_ref() {
                Some(key) => Some(lua.registry_value::<LuaFunction>(key)?),
                None => None,
            };
            let loop_cb = match this.on_loop.borrow().as_ref() {
                Some(key) => Some(lua.registry_value::<LuaFunction>(key)?),
                None => None,
            };
            let end_cb = match this.on_end.borrow().as_ref() {
                Some(key) => Some(lua.registry_value::<LuaFunction>(key)?),
                None => None,
            };

            // Snapshot events then release mutable domain state before user code runs.
            let events = this.inner.borrow_mut().update(dt);
            for event in events {
                match event {
                    AnimatorEvent::Frame { row, col, clip } => {
                        if let Some(cb) = frame_cb.as_ref() {
                            cb.call::<_, ()>((row, col, clip))?;
                        }
                    }
                    AnimatorEvent::Loop { clip } => {
                        if let Some(cb) = loop_cb.as_ref() {
                            cb.call::<_, ()>(clip)?;
                        }
                    }
                    AnimatorEvent::End { clip } => {
                        if let Some(cb) = end_cb.as_ref() {
                            cb.call::<_, ()>(clip)?;
                        }
                    }
                }
            }
            Ok(())
        });

        // -- onFrame --
        /// Set callback fired on each frame advance.
        /// @param | fn | function | Callback signature `(row, col, clip_name)`.
        methods.add_method("onFrame", |lua, this, callback: LuaFunction| {
            *this.on_frame.borrow_mut() = Some(lua.create_registry_value(callback)?);
            Ok(())
        });

        // -- onLoop --
        /// Set callback fired when a looping clip wraps.
        /// @param | fn | function | Callback signature `(clip_name)`.
        methods.add_method("onLoop", |lua, this, callback: LuaFunction| {
            *this.on_loop.borrow_mut() = Some(lua.create_registry_value(callback)?);
            Ok(())
        });

        // -- onEnd --
        /// Set callback fired when a non-looping clip reaches its end.
        /// @param | fn | function | Callback signature `(clip_name)`.
        methods.add_method("onEnd", |lua, this, callback: LuaFunction| {
            *this.on_end.borrow_mut() = Some(lua.create_registry_value(callback)?);
            Ok(())
        });

        // -- addClip --
        /// Add or replace a named clip definition.
        /// @param | name | string | Clip name.
        /// @param | def | table | Clip definition table with `row`, `from`, `to`, `fps`, and optional `loop`.
        methods.add_method("addClip", |_, this, (name, def): (String, LuaTable)| {
            let clip = clip_from_lua(def)?;
            this.inner.borrow_mut().add_clip(name, clip);
            Ok(())
        });

        // -- frameDuration --
        /// Return frame duration for the current clip.
        /// @return | number | Seconds per frame.
        methods.add_method("frameDuration", |_, this, ()| {
            Ok(this.inner.borrow().frame_duration())
        });

        // -- clipDuration --
        /// Return full one-pass duration for the current clip.
        /// @return | number | Total clip duration in seconds.
        methods.add_method("clipDuration", |_, this, ()| {
            Ok(this.inner.borrow().clip_duration())
        });

        // -- type --
        /// Returns the type name of this object.
        /// @return | string | Always `"LSpriteAnimator"`.
        methods.add_method("type", |_, _, ()| Ok("LSpriteAnimator"));

        // -- typeOf --
        /// Checks whether this object matches the given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object is the given type.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpriteAnimator" || name == "LObject")
        });
    }
}

/// Registers the `lurek.sprite` module, exposing sprite sheet and texture atlas constructors.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    let s = state.clone();
    // -- newBatch --
    /// Creates a sprite-owned batch that draws many instances of one render texture.
    /// @param | texture | LImage | Live render texture shared by every batch entry.
    /// @param | max | integer? | Maximum entries, defaulting to 1000.
    /// @return | LSpriteBatch | Batch handle with sprite entry semantics.
    tbl.set(
        "newBatch",
        lua.create_function(move |_, (texture, max): (LuaAnyUserData, Option<usize>)| {
            create_sprite_batch(&s, &texture, max, "lurek.sprite.newBatch")
        })?,
    )?;

    // --- sprite instance and lightweight animator ---
    // -- newSprite --
    /// Creates a lightweight sprite record with transform and optional normal-map metadata.
    /// @param | texture_id | integer | Live opaque image handle used by the sprite.
    /// @param | x | number | Initial world X position.
    /// @param | y | number | Initial world Y position.
    /// @return | LSprite | A new sprite object.
    tbl.set(
        "newSprite",
        lua.create_function(move |lua, (texture_id, x, y): (usize, f32, f32)| {
            require_finite("lurek.sprite.newSprite", "x", x)?;
            require_finite("lurek.sprite.newSprite", "y", y)?;
            let texture_id = require_live_texture_id(&state, "lurek.sprite.newSprite", texture_id)?;
            lua.create_userdata(LuaSprite {
                state: state.clone(),
                inner: Sprite::new(texture_id, Vec2::new(x, y)),
            })
        })?,
    )?;

    // -- newAnimator --
    /// Creates a stateful sprite clip animator from an optional clip definition table.
    /// @param | clips | table? | Map `{ clip_name = { row, from, to, fps, loop? } }`.
    /// @return | LSpriteAnimator | A new clip animator object.
    tbl.set(
        "newAnimator",
        lua.create_function(|lua, clips: Option<LuaTable>| {
            lua.create_userdata(LuaSpriteAnimator {
                inner: RefCell::new(animator_from_lua(clips)?),
                on_frame: RefCell::new(None),
                on_loop: RefCell::new(None),
                on_end: RefCell::new(None),
            })
        })?,
    )?;

    // --- sheets, atlas import, and compatibility adapters ---
    // -- newSheet --
    /// Creates a new sprite sheet by dividing a texture of the given pixel size into a grid of equal-sized frames.
    /// @param | tw | integer | Full texture width in pixels.
    /// @param | th | integer | Full texture height in pixels.
    /// @param | fw | integer | Single frame width in pixels.
    /// @param | fh | integer | Single frame height in pixels.
    /// @return | LSpriteSheet | A new sprite sheet object.
    tbl.set(
        "newSheet",
        lua.create_function(|lua, (tw, th, fw, fh): (u32, u32, u32, u32)| {
            let tw = require_positive_u32("lurek.sprite.newSheet", "tw", tw)?;
            let th = require_positive_u32("lurek.sprite.newSheet", "th", th)?;
            let fw = require_positive_u32("lurek.sprite.newSheet", "fw", fw)?;
            let fh = require_positive_u32("lurek.sprite.newSheet", "fh", fh)?;
            let sheet = SpriteSheet::try_new(tw, th, fw, fh)
                .map_err(|e| LuaError::RuntimeError(format!("lurek.sprite.newSheet: {e}")))?;
            lua.create_userdata(LuaSpriteSheet { inner: sheet })
        })?,
    )?;
    // -- newSheetFromImage --
    /// Creates a sprite sheet from an existing `LImageData` source and frame options.
    /// @param | image | LImageData | Source image data.
    /// @param | opts | table | `{frameWidth, frameHeight}` or `{columns, rows}`.
    /// @return | LSpriteSheet | A new sprite sheet object.
    tbl.set(
        "newSheetFromImage",
        lua.create_function(|lua, (image_ud, opts): (LuaAnyUserData, LuaTable)| {
            let image = image_ud.borrow::<ImageData>()?;
            let sheet = sheet_from_image_options(&image, opts)?;
            lua.create_userdata(LuaSpriteSheet { inner: sheet })
        })?,
    )?;
    // -- newRPGMakerSheet --
    /// Creates a sprite sheet using RPG Maker's standard character layout (3 columns by 4 rows per character block).
    /// @param | tw | integer | Full texture width in pixels.
    /// @param | th | integer | Full texture height in pixels.
    /// @return | LSpriteSheet | A new sprite sheet configured for RPG Maker character sprites.
    tbl.set(
        "newRPGMakerSheet",
        lua.create_function(|lua, (tw, th): (u32, u32)| {
            let tw = require_positive_u32("lurek.sprite.newRPGMakerSheet", "tw", tw)?;
            let th = require_positive_u32("lurek.sprite.newRPGMakerSheet", "th", th)?;
            lua.create_userdata(LuaSpriteSheet {
                inner: SpriteSheet::from_rpgmaker(tw, th),
            })
        })?,
    )?;
    // -- parseAtlas --
    /// Parses a TexturePacker JSON atlas string and returns a sprite atlas object.
    /// @param | json_str | string | Raw JSON content of the TexturePacker atlas file.
    /// @return | LSpriteAtlas | A new atlas with named sprite regions.
    tbl.set(
        "parseAtlas",
        lua.create_function(
            |lua, json_str: String| match parse_texturepacker_json(&json_str) {
                Ok(atlas) => {
                    let ud = lua.create_userdata(LuaSpriteAtlas { inner: atlas })?;
                    Ok(LuaValue::UserData(ud))
                }
                Err(e) => Err(LuaError::RuntimeError(format!("parseAtlas: {}", e))),
            },
        )?,
    )?;
    // -- newAtlasFromImage --
    /// Parses atlas JSON for an existing `LImageData` source.
    /// @param | image | LImageData | Source image data used as the atlas texture.
    /// @param | atlas_json | string | TexturePacker or Aseprite JSON.
    /// @return | LSpriteAtlas | Parsed atlas.
    tbl.set(
        "newAtlasFromImage",
        lua.create_function(|lua, (image_ud, atlas_json): (LuaAnyUserData, String)| {
            let image = image_ud.borrow::<ImageData>()?;
            lua.create_userdata(LuaSpriteAtlas {
                inner: atlas_from_image_json(&image, &atlas_json)?,
            })
        })?,
    )?;
    // -- newAutoTileSheet --
    /// Creates an autotile sheet descriptor from an image source, layout, and tile options.
    /// @param | image | LImageData | Source autotile sheet image.
    /// @param | layout | string | `blob47`, `composite48`, `rpgmaker48`, or `minimal16`.
    /// @param | opts | table | `{tileWidth, tileHeight}`.
    /// @return | LSpriteAutoTileSheet | Autotile sheet descriptor.
    tbl.set(
        "newAutoTileSheet",
        lua.create_function(
            |lua, (image_ud, layout, opts): (LuaAnyUserData, String, LuaTable)| {
                let image = image_ud.borrow::<ImageData>()?;
                lua.create_userdata(LuaSpriteAutoTileSheet {
                    inner: autotile_sheet_from_options(&image, &layout, opts)?,
                })
            },
        )?,
    )?;
    // -- newAtlasSheet --
    /// Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.
    /// @param | atlas | LSpriteAtlas | A previously parsed sprite atlas.
    /// @param | sw | integer | Sheet texture width in pixels.
    /// @param | sh | integer | Sheet texture height in pixels.
    /// @return | LSpriteSheet | A new sprite sheet derived from the atlas entries.
    tbl.set(
        "newAtlasSheet",
        lua.create_function(|lua, (atlas_ud, sw, sh): (LuaAnyUserData, u32, u32)| {
            let atlas = atlas_ud.borrow::<LuaSpriteAtlas>()?;
            let sw = require_positive_u32("lurek.sprite.newAtlasSheet", "sw", sw)?;
            let sh = require_positive_u32("lurek.sprite.newAtlasSheet", "sh", sh)?;
            lua.create_userdata(LuaSpriteSheet {
                inner: SpriteSheet::from_atlas(&atlas.inner, sw, sh),
            })
        })?,
    )?;
    // --- runtime packing and nine-slice descriptors ---
    // -- newAtlasPacker --
    /// Creates a runtime atlas packer for dynamically allocating named sprite regions.
    /// @param | width | integer | Atlas width in pixels.
    /// @param | height | integer | Atlas height in pixels.
    /// @param | padding | integer | Padding in pixels inserted around each packed region.
    /// @return | LAtlasPacker | A new runtime atlas packer.
    tbl.set(
        "newAtlasPacker",
        lua.create_function(|lua, (width, height, padding): (u32, u32, u32)| {
            let width = require_positive_u32("lurek.sprite.newAtlasPacker", "width", width)?;
            let height = require_positive_u32("lurek.sprite.newAtlasPacker", "height", height)?;
            let atlas = TextureAtlas::try_new(width, height, padding)
                .map_err(|e| LuaError::RuntimeError(format!("lurek.sprite.newAtlasPacker: {e}")))?;
            lua.create_userdata(LuaAtlasPacker { inner: atlas })
        })?,
    )?;
    // -- newNineSlice --
    /// Creates a 9-slice definition from an image and four border insets for scalable UI rendering.
    /// @param | image | LImage | Source texture.
    /// @param | top | number | Top border inset in pixels.
    /// @param | right | number | Right border inset.
    /// @param | bottom | number | Bottom border inset.
    /// @param | left | number | Left border inset.
    /// @return | LNineSlice | The 9-slice handle.
    tbl.set(
        "newNineSlice",
        lua.create_function(
            |_, (image, top, right, bottom, left): (LuaAnyUserData, f32, f32, f32, f32)| {
                nine_slice_from_image(image, top, right, bottom, left)
            },
        )?,
    )?;
    // -- parseAsepriteAtlas --
    /// Parses an Aseprite JSON atlas string and returns a sprite atlas object.
    /// @param | json_str | string | Raw JSON content of the Aseprite export atlas file.
    /// @return | LSpriteAtlas | A new atlas with named sprite regions from Aseprite frames.
    tbl.set(
        "parseAsepriteAtlas",
        lua.create_function(|lua, json_str: String| {
            let atlas = parse_aseprite_json(&json_str).map_err(LuaError::RuntimeError)?;
            lua.create_userdata(LuaSpriteAtlas { inner: atlas })
        })?,
    )?;
    /// Performs the 'sprite' operation.
    lurek.set("sprite", tbl)?;
    Ok(())
}
/// Converts a sprite rectangle into the Lua quad table returned by atlas helpers.
fn quad_table(lua: &Lua, r: Rect) -> LuaResult<LuaTable<'_>> {
    let t = lua.create_table()?;
    /// The 'x' field value exposed to Lua scripts.
    t.set("x", r.x)?;
    /// The 'y' field value exposed to Lua scripts.
    t.set("y", r.y)?;
    /// The 'w' field value exposed to Lua scripts.
    t.set("w", r.width)?;
    /// The 'h' field value exposed to Lua scripts.
    t.set("h", r.height)?;
    Ok(t)
}
/// Converts a slice of sprite rectangles into an array-style Lua table.
fn frames_to_table<'lua>(lua: &'lua Lua, frames: &[Rect]) -> LuaResult<LuaTable<'lua>> {
    let t = lua.create_table()?;
    for (i, r) in frames.iter().enumerate() {
        t.set(i + 1, quad_table(lua, *r)?)?;
    }
    Ok(t)
}

/// Converts an iterator of sprite rectangles into an array-style Lua table.
fn frames_iter_to_table<'lua, I>(lua: &'lua Lua, frames: I) -> LuaResult<LuaTable<'lua>>
where
    I: IntoIterator,
    I::Item: Borrow<Rect>,
{
    let t = lua.create_table()?;
    for (i, r) in frames.into_iter().enumerate() {
        t.set(i + 1, quad_table(lua, *r.borrow())?)?;
    }
    Ok(t)
}

/// Convert one Lua clip-definition table into a normalized Rust clip.
fn clip_from_lua(def: LuaTable) -> LuaResult<SpriteClip> {
    let row = def.get::<_, Option<u32>>("row")?.unwrap_or(1);
    let from = def.get::<_, Option<u32>>("from")?.unwrap_or(1);
    let to = def.get::<_, Option<u32>>("to")?.unwrap_or(from);
    let fps = def.get::<_, Option<f32>>("fps")?.unwrap_or(8.0);
    let looping = def.get::<_, Option<bool>>("loop")?.unwrap_or(true);
    if row == 0
        || from == 0
        || to < from
        || !fps.is_finite()
        || fps <= 0.0
        || fps > SpriteLimits::MAX_FPS
    {
        return Err(LuaError::RuntimeError(format!(
            "lurek.sprite.newAnimator: clip requires one-based row/from, to >= from, and finite fps in (0, {}]",
            SpriteLimits::MAX_FPS
        )));
    }
    Ok(SpriteClip {
        row,
        from,
        to,
        fps,
        looping,
    }
    .normalized())
}
