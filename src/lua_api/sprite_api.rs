//! File: src/lua_api/sprite_api.rs

use super::SharedState;
use crate::image::{NineSliceInsets, TextureAtlas};
use crate::math::{Rect, Vec2};
use crate::sprite::animator::{AnimatorEvent, SpriteAnimator, SpriteClip};
use crate::sprite::atlas::{parse_aseprite_json, parse_texturepacker_json, SpriteAtlas};
use crate::sprite::sprite::Sprite;
use crate::sprite::sprite_sheet::SpriteSheet;
use mlua::prelude::*;
use std::borrow::Borrow;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

/// Lua-visible single sprite data container, including optional normal-map metadata for lit sprites.
pub struct LuaSprite {
    inner: Sprite,
}
impl LuaUserData for LuaSprite {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setPosition --
        /// Sets the sprite anchor position in pixels.
        /// @param | x | number | World X position.
        /// @param | y | number | World Y position.
        methods.add_method_mut("setPosition", |_, this, (x, y): (f32, f32)| {
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
        /// @param | texture_id | integer | Texture handle used as the normal-map source.
        methods.add_method_mut("setNormalMap", |_, this, texture_id: usize| {
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
            this.inner.set_normal_intensity(intensity);
            Ok(())
        });
        // -- getNormalIntensity --
        /// Returns the normal-map intensity multiplier.
        /// @return | number | Current non-negative intensity multiplier.
        methods.add_method("getNormalIntensity", |_, this, ()| {
            Ok(this.inner.get_normal_intensity())
        });
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
    inner: SpriteSheet,
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
    inner: SpriteAtlas,
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
            match this.inner.get_by_index(index.saturating_sub(1)) {
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

/// Lua-visible wrapper around an in-memory atlas packer for dynamic sprite region allocation.
pub struct LuaAtlasPacker {
    inner: TextureAtlas,
}
impl LuaUserData for LuaAtlasPacker {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- pack --
        /// Packs a named region into this atlas and returns whether allocation succeeded.
        /// @param | name | string | Region key used for later lookups.
        /// @param | w | integer | Region width in pixels.
        /// @param | h | integer | Region height in pixels.
        /// @return | boolean | True when the region was packed.
        methods.add_method_mut("pack", |_, this, (name, w, h): (String, u32, u32)| {
            Ok(this.inner.pack(&name, w, h))
        });
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
    inner: SpriteAnimator,
    on_frame: Option<LuaRegistryKey>,
    on_loop: Option<LuaRegistryKey>,
    on_end: Option<LuaRegistryKey>,
}

impl LuaUserData for LuaSpriteAnimator {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- play --
        /// Play or restart a named clip.
        /// @param | name | string | Clip name.
        /// @param | restart | boolean? | Whether to restart when already playing this clip. Defaults to true.
        methods.add_method_mut(
            "play",
            |_, this, (name, restart): (String, Option<bool>)| {
                this.inner.play(&name, restart.unwrap_or(true));
                Ok(())
            },
        );

        // -- pause --
        /// Pause playback without resetting frame state.
        methods.add_method_mut("pause", |_, this, ()| {
            this.inner.pause();
            Ok(())
        });

        // -- resume --
        /// Resume playback from current frame when a clip is selected.
        methods.add_method_mut("resume", |_, this, ()| {
            this.inner.resume();
            Ok(())
        });

        // -- stop --
        /// Stop playback and reset to the first frame of the current clip.
        methods.add_method_mut("stop", |_, this, ()| {
            this.inner.stop();
            Ok(())
        });

        // -- isPlaying --
        /// Return whether the animator is currently playing.
        /// @return | boolean | True when playing.
        methods.add_method("isPlaying", |_, this, ()| Ok(this.inner.is_playing()));

        // -- currentClip --
        /// Return the currently selected clip name.
        /// @return | string | Active clip name, or nil if none.
        methods.add_method("currentClip", |_, this, ()| {
            Ok(this.inner.current_clip().map(|name| name.to_string()))
        });

        // -- currentFrame --
        /// Return current draw frame as sprite-sheet row and column.
        /// @return | integer | Sprite-sheet row.
        /// @return | integer | Sprite-sheet column (frame index).
        methods.add_method("currentFrame", |_, this, ()| Ok(this.inner.current_frame()));

        // -- update --
        /// Advance playback by delta time and dispatch callback events.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |lua, this, dt: f32| {
            let frame_cb = match this.on_frame.as_ref() {
                Some(key) => Some(lua.registry_value::<LuaFunction>(key)?),
                None => None,
            };
            let loop_cb = match this.on_loop.as_ref() {
                Some(key) => Some(lua.registry_value::<LuaFunction>(key)?),
                None => None,
            };
            let end_cb = match this.on_end.as_ref() {
                Some(key) => Some(lua.registry_value::<LuaFunction>(key)?),
                None => None,
            };

            let events = this.inner.update(dt);
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
        methods.add_method_mut("onFrame", |lua, this, callback: LuaFunction| {
            this.on_frame = Some(lua.create_registry_value(callback)?);
            Ok(())
        });

        // -- onLoop --
        /// Set callback fired when a looping clip wraps.
        /// @param | fn | function | Callback signature `(clip_name)`.
        methods.add_method_mut("onLoop", |lua, this, callback: LuaFunction| {
            this.on_loop = Some(lua.create_registry_value(callback)?);
            Ok(())
        });

        // -- onEnd --
        /// Set callback fired when a non-looping clip reaches its end.
        /// @param | fn | function | Callback signature `(clip_name)`.
        methods.add_method_mut("onEnd", |lua, this, callback: LuaFunction| {
            this.on_end = Some(lua.create_registry_value(callback)?);
            Ok(())
        });

        // -- addClip --
        /// Add or replace a named clip definition.
        /// @param | name | string | Clip name.
        /// @param | def | table | Clip definition table with `row`, `from`, `to`, `fps`, and optional `loop`.
        methods.add_method_mut("addClip", |_, this, (name, def): (String, LuaTable)| {
            let clip = clip_from_lua(def)?;
            this.inner.add_clip(name, clip);
            Ok(())
        });

        // -- frameDuration --
        /// Return frame duration for the current clip.
        /// @return | number | Seconds per frame.
        methods.add_method("frameDuration", |_, this, ()| {
            Ok(this.inner.frame_duration())
        });

        // -- clipDuration --
        /// Return full one-pass duration for the current clip.
        /// @return | number | Total clip duration in seconds.
        methods.add_method("clipDuration", |_, this, ()| Ok(this.inner.clip_duration()));

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
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- newSprite --
    /// Creates a lightweight sprite record with transform and optional normal-map metadata.
    /// @param | texture_id | integer | Texture handle used by the sprite.
    /// @param | x | number | Initial world X position.
    /// @param | y | number | Initial world Y position.
    /// @return | LSprite | A new sprite object.
    tbl.set(
        "newSprite",
        lua.create_function(|lua, (texture_id, x, y): (usize, f32, f32)| {
            lua.create_userdata(LuaSprite {
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
            let mut parsed = HashMap::new();
            if let Some(clips_table) = clips {
                for pair in clips_table.pairs::<String, LuaTable>() {
                    let (name, def) = pair?;
                    parsed.insert(name, clip_from_lua(def)?);
                }
            }

            lua.create_userdata(LuaSpriteAnimator {
                inner: SpriteAnimator::new(parsed),
                on_frame: None,
                on_loop: None,
                on_end: None,
            })
        })?,
    )?;

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
            lua.create_userdata(LuaSpriteSheet {
                inner: SpriteSheet::new(tw, th, fw, fh),
            })
        })?,
    )?;
    // -- newRPGMakerSheet --
    /// Creates a sprite sheet using RPG Maker's standard character layout (4 columns Ă— 4 rows per character block).
    /// @param | tw | integer | Full texture width in pixels.
    /// @param | th | integer | Full texture height in pixels.
    /// @return | LSpriteSheet | A new sprite sheet configured for RPG Maker character sprites.
    tbl.set(
        "newRPGMakerSheet",
        lua.create_function(|lua, (tw, th): (u32, u32)| {
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
            lua.create_userdata(LuaSpriteSheet {
                inner: SpriteSheet::from_atlas(&atlas.inner, sw, sh),
            })
        })?,
    )?;
    // -- newAtlasPacker --
    /// Creates a runtime atlas packer for dynamically allocating named sprite regions.
    /// @param | width | integer | Atlas width in pixels.
    /// @param | height | integer | Atlas height in pixels.
    /// @param | padding | integer | Padding in pixels inserted around each packed region.
    /// @return | LAtlasPacker | A new runtime atlas packer.
    tbl.set(
        "newAtlasPacker",
        lua.create_function(|lua, (width, height, padding): (u32, u32, u32)| {
            lua.create_userdata(LuaAtlasPacker {
                inner: TextureAtlas::new(width, height, padding),
            })
        })?,
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
    Ok(SpriteClip {
        row,
        from,
        to,
        fps,
        looping,
    }
    .normalized())
}
