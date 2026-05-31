//! File: src/lua_api/sprite_api.rs

use super::SharedState;
use crate::image::{NineSliceInsets, TextureAtlas};
use crate::math::Rect;
use crate::sprite::atlas::{parse_aseprite_json, parse_texturepacker_json, SpriteAtlas};
use crate::sprite::sprite_sheet::SpriteSheet;
use mlua::prelude::*;
use std::borrow::Borrow;
use std::cell::RefCell;
use std::rc::Rc;

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
        methods.add_method("regionCount", |_, this, ()| Ok(this.inner.get_region_count()));
        // -- getDimensions --
        /// Returns the current width and height of this atlas packer.
        /// @return | integer | Atlas width in pixels.
        /// @return | integer | Atlas height in pixels.
        methods.add_method("getDimensions", |_, this, ()| Ok(this.inner.get_dimensions()));
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

/// Registers the `lurek.sprite` module, exposing sprite sheet and texture atlas constructors.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

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
