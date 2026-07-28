//! Registers texture and sprite-batch construction for the `lurek.render` API.
//! This child owns Lua conversion and compatibility aliases only; texture
//! residency lives in render/runtime and batch semantics live in sprite.

use super::{create_sprite_batch, create_texture_from_args, SharedState};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register render resource constructors on the already-owned render table.
pub(super) fn register_resources_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- newImage --
    /// Compatibility alias for `lurek.render.newTexture`.
    /// @deprecated Use `lurek.render.newTexture`; this alias is supported through 1.x and targets removal in 2.0.
    /// @param | pathOrData | string|LImageData | File path to an image, or an ImageData object.
    /// @param | colorSpace | string? | Color space: "srgb" (default) or "linear".
    /// @return | LImage | The loaded image handle.
    graphics.set(
        "newImage",
        lua.create_function(move |_, args: LuaMultiValue| {
            create_texture_from_args(&s, args, "lurek.render.newImage")
        })?,
    )?;
    let s = state.clone();
    // -- newTexture --
    /// Creates a render texture from a GameFS path or CPU-owned ImageData.
    /// @param | pathOrData | string|LImageData | File path to an image, or ImageData to upload.
    /// @param | colorSpace | string? | Color space: `srgb` (default) or `linear`.
    /// @return | LImage | Legacy-compatible render texture handle.
    graphics.set(
        "newTexture",
        lua.create_function(move |_, args: LuaMultiValue| {
            create_texture_from_args(&s, args, "lurek.render.newTexture")
        })?,
    )?;
    let s = state.clone();
    // -- newSpriteBatch --
    /// Compatibility alias for `lurek.sprite.newBatch`.
    /// @deprecated Use `lurek.sprite.newBatch`; this alias is supported through 1.x and targets removal in 2.0.
    /// @param | image | LImage | Source texture for all sprites in the batch.
    /// @param | max | integer? | Maximum number of entries (default 1000).
    /// @return | LSpriteBatch | The created sprite batch handle.
    graphics.set(
        "newSpriteBatch",
        lua.create_function(move |_, (image, max): (LuaAnyUserData, Option<usize>)| {
            create_sprite_batch(&s, &image, max, "lurek.render.newSpriteBatch")
        })?,
    )?;
    Ok(())
}
