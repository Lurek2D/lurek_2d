//! Registers the `lurek.parallax` Lua API for parallax layers, blend modes, sorting, and render command helpers.

use super::SharedState;
use crate::lua_api::render_api::LuaImage;
use crate::parallax::layer::ParallaxLayer;
use crate::parallax::presets;
use crate::render::ShaderPassDescriptor;
use crate::render::{BlendMode, RenderCommand};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

fn finite_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    if value.is_finite() {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be finite"
        )))
    }
}

fn non_negative_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    let value = finite_f32(api, arg_name, value)?;
    if value >= 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be >= 0"
        )))
    }
}

fn positive_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    let value = finite_f32(api, arg_name, value)?;
    if value > 0.0 {
        Ok(value)
    } else {
        Err(LuaError::RuntimeError(format!(
            "{api}: {arg_name} must be > 0"
        )))
    }
}

fn unit_f32(api: &str, arg_name: &str, value: f32) -> LuaResult<f32> {
    Ok(finite_f32(api, arg_name, value)?.clamp(0.0, 1.0))
}
/// Parses a Lua blend mode string into a render blend mode.
fn blend_from_str(s: &str) -> LuaResult<BlendMode> {
    match s {
        "normal" | "alpha" => Ok(BlendMode::Alpha),
        "additive" | "add" => Ok(BlendMode::Add),
        "multiply" => Ok(BlendMode::Multiply),
        "replace" => Ok(BlendMode::Replace),
        "screen" => Ok(BlendMode::Screen),
        other => Err(LuaError::RuntimeError(format!(
            "lurek.parallax: unknown blend mode '{}'; valid modes are: normal, additive, multiply, replace, screen",
            other
        ))),
    }
}
/// Converts a render blend mode into the Lua string form.
fn blend_to_str(bm: BlendMode) -> &'static str {
    match bm {
        BlendMode::Add => "additive",
        BlendMode::Multiply => "multiply",
        BlendMode::Replace => "replace",
        BlendMode::Screen => "screen",
        BlendMode::Alpha => "normal",
    }
}
#[derive(Clone)]
/// Lua-side wrapper for a parallax layer and shared render state.
pub struct LuaParallaxLayer {
    /// Shared parallax layer model exposed by the lurek engine.
    layer: Rc<RefCell<ParallaxLayer>>,
    /// Shared runtime state used to enqueue render commands and track automatic layers.
    state: Rc<RefCell<SharedState>>,
}
impl LuaParallaxLayer {
    /// Creates a parallax layer wrapper and registers it for automatic updates.
    fn new(layer: ParallaxLayer, state: Rc<RefCell<SharedState>>) -> Self {
        let layer_rc = Rc::new(RefCell::new(layer));
        state
            .borrow_mut()
            .auto_parallax_layers
            .push(Rc::downgrade(&layer_rc));
        LuaParallaxLayer {
            layer: layer_rc,
            state,
        }
    }
    /// Pushes render commands for a layer using the current window size and camera position.
    fn push_render_commands_internal(
        layer: &ParallaxLayer,
        st: &mut SharedState,
        cam_x: f32,
        cam_y: f32,
    ) {
        let screen_w = st.window_state.game_width;
        let screen_h = st.window_state.game_height;
        let Some(batch) = layer.build_draw_calls(cam_x, cam_y, screen_w, screen_h) else {
            return;
        };
        st.render_commands.push(RenderCommand::SetColor(
            batch.color[0],
            batch.color[1],
            batch.color[2],
            batch.color[3],
        ));
        st.render_commands
            .push(RenderCommand::SetBlendMode(batch.blend_mode));
        for (tx, ty) in &batch.tiles {
            st.render_commands.push(RenderCommand::DrawImageEx {
                texture_key: batch.texture_key,
                x: *tx,
                y: *ty,
                rotation: 0.0,
                sx: batch.sx,
                sy: batch.sy,
                ox: 0.0,
                oy: 0.0,
                effect: batch.effect.clone(),
            });
        }
    }
}
/// Provides Lua methods for parallax layer update, render, scrolling, tint, blend, tiling, effects, and motion stretch.
impl LuaUserData for LuaParallaxLayer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Returns the Lua-visible type name for this parallax layer handle.
        /// @return | string | The string `LParallaxLayer`.
        methods.add_method("type", |_, _, ()| Ok("LParallaxLayer"));
        // -- update --
        /// Advances parallax layer autoscroll by delta time.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("update", |_, this, dt: f32| {
            let dt = non_negative_f32("LParallaxLayer:update", "dt", dt)?;
            this.layer.borrow_mut().update(dt);
            Ok(())
        });
        // -- render --
        /// Enqueues render commands using explicit camera coordinates.
        /// @param | cam_x | number | Camera x coordinate.
        /// @param | cam_y | number | Camera y coordinate.
        methods.add_method("render", |_, this, (cam_x, cam_y): (f32, f32)| {
            let cam_x = finite_f32("LParallaxLayer:render", "cam_x", cam_x)?;
            let cam_y = finite_f32("LParallaxLayer:render", "cam_y", cam_y)?;
            let layer = this.layer.borrow();
            let mut st = this.state.borrow_mut();
            Self::push_render_commands_internal(&layer, &mut st, cam_x, cam_y);
            Ok(())
        });
        // -- renderAuto --
        /// Enqueues render commands using the runtime camera.
        methods.add_method("renderAuto", |_, this, ()| {
            let layer = this.layer.borrow();
            let cam_x;
            let cam_y;
            {
                let st = this.state.borrow();
                cam_x = st.camera.position.x;
                cam_y = st.camera.position.y;
            }
            let mut st = this.state.borrow_mut();
            Self::push_render_commands_internal(&layer, &mut st, cam_x, cam_y);
            Ok(())
        });
        // -- resetAutoscroll --
        /// Resets the layer autoscroll offset to zero.
        methods.add_method("resetAutoscroll", |_, this, ()| {
            this.layer.borrow_mut().reset_autoscroll();
            Ok(())
        });
        // -- setScrollFactor --
        /// Sets layer scroll factor for this object.
        /// @param | x | number | X scroll factor.
        /// @param | y | number | Y scroll factor.
        methods.add_method("setScrollFactor", |_, this, (x, y): (f32, f32)| {
            let mut l = this.layer.borrow_mut();
            l.scroll_factor = [
                finite_f32("LParallaxLayer:setScrollFactor", "x", x)?,
                finite_f32("LParallaxLayer:setScrollFactor", "y", y)?,
            ];
            Ok(())
        });
        // -- getScrollFactor --
        /// Returns layer scroll factor from this object.
        /// @return | number | X scroll factor.
        /// @return | number | Y scroll factor.
        methods.add_method("getScrollFactor", |_, this, ()| {
            let l = this.layer.borrow();
            Ok((l.scroll_factor[0], l.scroll_factor[1]))
        });
        // -- setOffset --
        /// Sets the layer pixel offset for this object.
        /// @param | x | number | X offset.
        /// @param | y | number | Y offset.
        methods.add_method("setOffset", |_, this, (x, y): (f32, f32)| {
            let mut l = this.layer.borrow_mut();
            l.offset = [
                finite_f32("LParallaxLayer:setOffset", "x", x)?,
                finite_f32("LParallaxLayer:setOffset", "y", y)?,
            ];
            Ok(())
        });
        // -- getOffset --
        /// Returns layer offset for this object.
        /// @return | number | X offset.
        /// @return | number | Y offset.
        methods.add_method("getOffset", |_, this, ()| {
            let l = this.layer.borrow();
            Ok((l.offset[0], l.offset[1]))
        });
        // -- setAutoscroll --
        /// Sets the layer autoscroll velocity values.
        /// @param | vx | number | X autoscroll velocity.
        /// @param | vy | number | Y autoscroll velocity.
        methods.add_method("setAutoscroll", |_, this, (vx, vy): (f32, f32)| {
            let mut l = this.layer.borrow_mut();
            l.autoscroll = [
                finite_f32("LParallaxLayer:setAutoscroll", "vx", vx)?,
                finite_f32("LParallaxLayer:setAutoscroll", "vy", vy)?,
            ];
            Ok(())
        });
        // -- getAutoscroll --
        /// Returns layer autoscroll velocity.
        /// @return | number | X velocity.
        /// @return | number | Y velocity.
        methods.add_method("getAutoscroll", |_, this, ()| {
            let l = this.layer.borrow();
            Ok((l.autoscroll[0], l.autoscroll[1]))
        });
        // -- setRepeat --
        /// Sets horizontal and vertical repeat flags.
        /// @param | rx | boolean | Repeat horizontally.
        /// @param | ry | boolean | Repeat vertically.
        methods.add_method("setRepeat", |_, this, (rx, ry): (bool, bool)| {
            let mut l = this.layer.borrow_mut();
            l.repeat_x = rx;
            l.repeat_y = ry;
            Ok(())
        });
        // -- setScale --
        /// Sets the layer scale factor for this object.
        /// @param | sx | number | X scale factor.
        /// @param | sy | number | Y scale factor.
        methods.add_method("setScale", |_, this, (sx, sy): (f32, f32)| {
            let mut l = this.layer.borrow_mut();
            l.scale = [
                positive_f32("LParallaxLayer:setScale", "sx", sx)?,
                positive_f32("LParallaxLayer:setScale", "sy", sy)?,
            ];
            Ok(())
        });
        // -- setZ --
        /// Sets the layer z order for this object.
        /// @param | z | integer | Z order.
        methods.add_method("setZ", |_, this, z: i32| {
            this.layer.borrow_mut().z = z;
            Ok(())
        });
        // -- getZ --
        /// Returns layer z order from this object.
        /// @return | integer | Z order.
        methods.add_method("getZ", |_, this, ()| Ok(this.layer.borrow().z));
        // -- setOpacity --
        /// Sets layer opacity, clamped to 0..1.
        /// @param | a | number | Opacity value.
        methods.add_method("setOpacity", |_, this, a: f32| {
            this.layer.borrow_mut().opacity = unit_f32("LParallaxLayer:setOpacity", "a", a)?;
            Ok(())
        });
        // -- getOpacity --
        /// Returns layer opacity from this object.
        /// @return | number | Opacity value.
        methods.add_method("getOpacity", |_, this, ()| Ok(this.layer.borrow().opacity));
        // -- setTint --
        /// Sets layer tint color for this object.
        /// @param | r | number | Red channel (0â€“1).
        /// @param | g | number | Green channel (0â€“1).
        /// @param | b | number | Blue channel (0â€“1).
        /// @param | a | number | Alpha channel (0â€“1).
        methods.add_method("setTint", |_, this, (r, g, b, a): (f32, f32, f32, f32)| {
            this.layer.borrow_mut().tint = [
                unit_f32("LParallaxLayer:setTint", "r", r)?,
                unit_f32("LParallaxLayer:setTint", "g", g)?,
                unit_f32("LParallaxLayer:setTint", "b", b)?,
                unit_f32("LParallaxLayer:setTint", "a", a)?,
            ];
            Ok(())
        });
        // -- getTint --
        /// Returns layer tint color from this object.
        /// @return | number | Red channel.
        /// @return | number | Green channel.
        /// @return | number | Blue channel.
        /// @return | number | Alpha channel.
        methods.add_method("getTint", |_, this, ()| {
            let [r, g, b, a] = this.layer.borrow().tint;
            Ok((r, g, b, a))
        });
        // -- setBlendMode --
        /// Sets the layer blend mode by string name.
        /// @param | mode | string | Blend mode name.
        methods.add_method("setBlendMode", |_, this, mode: String| {
            this.layer.borrow_mut().blend_mode = blend_from_str(&mode)?;
            Ok(())
        });
        // -- getBlendMode --
        /// Returns the current layer blend mode name.
        /// @return | string | Blend mode name.
        methods.add_method("getBlendMode", |_, this, ()| {
            Ok(blend_to_str(this.layer.borrow().blend_mode).to_string())
        });
        // -- setVisible --
        /// Sets layer visibility for this object.
        /// @param | v | boolean | Visibility flag.
        methods.add_method("setVisible", |_, this, v: bool| {
            this.layer.borrow_mut().visible = v;
            Ok(())
        });
        // -- isVisible --
        /// Returns layer visibility and returns a boolean.
        /// @return | boolean | True when visible.
        methods.add_method("isVisible", |_, this, ()| Ok(this.layer.borrow().visible));
        // -- setClamp --
        /// Sets clamp bounds for layer movement.
        /// @param | min_x | number | Minimum X bound.
        /// @param | min_y | number | Minimum Y bound.
        /// @param | max_x | number | Maximum X bound.
        /// @param | max_y | number | Maximum Y bound.
        methods.add_method(
            "setClamp",
            |_, this, (min_x, min_y, max_x, max_y): (f32, f32, f32, f32)| {
                let mut l = this.layer.borrow_mut();
                l.set_clamp_bounds(
                    [
                        finite_f32("LParallaxLayer:setClamp", "min_x", min_x)?,
                        finite_f32("LParallaxLayer:setClamp", "min_y", min_y)?,
                    ],
                    [
                        finite_f32("LParallaxLayer:setClamp", "max_x", max_x)?,
                        finite_f32("LParallaxLayer:setClamp", "max_y", max_y)?,
                    ],
                );
                Ok(())
            },
        );
        // -- clearClamp --
        /// Clears layer clamp bounds on this object.
        methods.add_method("clearClamp", |_, this, ()| {
            let mut l = this.layer.borrow_mut();
            l.clamp_min = None;
            l.clamp_max = None;
            Ok(())
        });
        // -- setTiling --
        /// Enables or disables the layer tiling mode.
        /// @param | enabled | boolean | Tiling flag.
        methods.add_method("setTiling", |_, this, enabled: bool| {
            this.layer.borrow_mut().set_tiling(enabled);
            Ok(())
        });
        // -- getTiling --
        /// Returns whether layer tiling is enabled.
        /// @return | boolean | True when tiling is enabled.
        methods.add_method("getTiling", |_, this, ()| {
            Ok(this.layer.borrow().get_tiling())
        });
        // -- setTileSize --
        /// Sets tile size for tiling for this object.
        /// @param | w | number | Tile width.
        /// @param | h | number | Tile height.
        methods.add_method("setTileSize", |_, this, (w, h): (f32, f32)| {
            this.layer.borrow_mut().set_tile_size(
                finite_f32("LParallaxLayer:setTileSize", "w", w)?,
                finite_f32("LParallaxLayer:setTileSize", "h", h)?,
            );
            Ok(())
        });
        // -- setDepth --
        /// Sets parallax depth for this object.
        /// @param | z | number | Depth value.
        methods.add_method("setDepth", |_, this, z: f32| {
            this.layer
                .borrow_mut()
                .set_depth(finite_f32("LParallaxLayer:setDepth", "z", z)?);
            Ok(())
        });
        // -- getDepth --
        /// Returns parallax depth from this object.
        /// @return | number | Depth value.
        methods.add_method("getDepth", |_, this, ()| {
            Ok(this.layer.borrow().get_depth())
        });
        // -- addEffectPass --
        /// Adds a shader effect pass to this layer.
        /// @param | effect_name | string | Effect name.
        /// @param | params | table? | Numeric parameter table.
        methods.add_method(
            "addEffectPass",
            |_, this, (effect_name, params): (String, Option<LuaTable>)| {
                let mut pass = ShaderPassDescriptor::new(effect_name);
                if let Some(tbl) = params {
                    let pairs = tbl.pairs::<String, f32>();
                    for pair in pairs {
                        let (k, v) = pair?;
                        pass.params.insert(
                            k.clone(),
                            finite_f32("LParallaxLayer:addEffectPass", &k, v)?,
                        );
                    }
                }
                let mut layer = this.layer.borrow_mut();
                let mut chain = layer.effect_chain.take().unwrap_or_default();
                chain.push(pass);
                layer.set_effect_chain(chain);
                Ok(())
            },
        );
        // -- clearEffects --
        /// Clears shader effect passes from this layer.
        methods.add_method("clearEffects", |_, this, ()| {
            this.layer.borrow_mut().clear_effect_chain();
            Ok(())
        });
        // -- effectCount --
        /// Returns the shader effect pass count for this layer.
        /// @return | integer | Effect pass count.
        methods.add_method("effectCount", |_, this, ()| {
            Ok(this.layer.borrow().effect_count() as i64)
        });
        // -- getStats --
        /// Returns telemetry for the current runtime camera and viewport.
        /// @return | table | Parallax layer telemetry fields.
        methods.add_method("getStats", |lua, this, ()| {
            let (cam_x, cam_y, screen_w, screen_h) = {
                let st = this.state.borrow();
                (
                    st.camera.position.x,
                    st.camera.position.y,
                    st.window_state.game_width,
                    st.window_state.game_height,
                )
            };
            let stats = this
                .layer
                .borrow()
                .stats_for_view(cam_x, cam_y, screen_w, screen_h);
            let table = lua.create_table()?;
            table.set("visible_tile_count", stats.visible_tile_count)?;
            table.set("tile_width", stats.tile_width)?;
            table.set("tile_height", stats.tile_height)?;
            table.set("draw_scale_x", stats.draw_scale_x)?;
            table.set("draw_scale_y", stats.draw_scale_y)?;
            table.set("effect_pass_count", stats.effect_pass_count)?;
            table.set("z", stats.z)?;
            table.set("depth", stats.depth)?;
            table.set("visible", stats.visible)?;
            table.set("motion_stretch_enabled", stats.motion_stretch_enabled)?;
            table.set("autoscroll_speed", stats.autoscroll_speed)?;
            Ok(table)
        });
        // -- setMotionStretch --
        /// Sets the motion stretch settings for this layer.
        /// @param | enabled | boolean | Motion stretch flag.
        /// @param | strength | number | Stretch strength.
        /// @param | max_scale | number | Maximum stretch scale.
        methods.add_method(
            "setMotionStretch",
            |_, this, (enabled, strength, max_scale): (bool, f32, f32)| {
                this.layer.borrow_mut().set_motion_stretch(
                    enabled,
                    non_negative_f32("LParallaxLayer:setMotionStretch", "strength", strength)?,
                    positive_f32("LParallaxLayer:setMotionStretch", "max_scale", max_scale)?,
                );
                Ok(())
            },
        );
        // -- getMotionStretch --
        /// Returns the current motion stretch settings.
        /// @return | boolean | Motion stretch flag.
        /// @return | number | Stretch strength.
        /// @return | number | Maximum stretch scale.
        methods.add_method("getMotionStretch", |_, this, ()| {
            let layer = this.layer.borrow();
            Ok((
                layer.motion_stretch_enabled,
                layer.motion_stretch_strength,
                layer.motion_stretch_max_scale,
            ))
        });
    }
}
#[derive(Clone)]
/// Lua-side wrapper for an ordered parallax layer set.
pub struct LuaParallaxSet {
    /// Layers in this set exposed by the lurek engine.
    layers: Vec<LuaParallaxLayer>,
    /// Set name exposed by the lurek engine.
    name: String,
    /// Set visibility flag exposed by the lurek engine.
    visible: bool,
    /// Shared runtime state used to enqueue render commands.
    state: Rc<RefCell<SharedState>>,
}
impl LuaParallaxSet {
    /// Creates an empty parallax set.
    fn new(name: impl Into<String>, state: Rc<RefCell<SharedState>>) -> Self {
        LuaParallaxSet {
            layers: Vec::new(),
            name: name.into(),
            visible: true,
            state,
        }
    }
    /// Sorts layers by z order exposed by the lurek engine.
    fn sort_by_z(&mut self) {
        self.layers.sort_by_key(|l| l.layer.borrow().z);
    }
}
/// Provides Lua methods for parallax set layer management, visibility, update, render, and naming.
impl LuaUserData for LuaParallaxSet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Returns the Lua-visible type name for this parallax set handle.
        /// @return | string | The string `LParallaxSet`.
        methods.add_method("type", |_, _, ()| Ok("LParallaxSet"));
        // -- addLayer --
        /// Adds a parallax layer to this set handle.
        /// @param | layer | LParallaxLayer | Layer handle.
        methods.add_method_mut("addLayer", |_, this, layer: LuaAnyUserData| {
            let lu_layer = layer.borrow::<LuaParallaxLayer>()?.clone();
            this.layers.push(lu_layer);
            this.sort_by_z();
            Ok(())
        });
        // -- removeLayerAt --
        /// Removes a layer by one-based index.
        /// @param | index | integer | One-based layer index.
        /// @return | boolean | True when a layer was removed.
        methods.add_method_mut("removeLayerAt", |_, this, index: usize| {
            if index >= 1 && index <= this.layers.len() {
                this.layers.remove(index - 1);
                Ok(true)
            } else {
                Ok(false)
            }
        });
        // -- layerCount --
        /// Returns the number of layers in this set.
        /// @return | integer | Layer count.
        methods.add_method("layerCount", |_, this, ()| Ok(this.layers.len() as i64));
        // -- getLayerZAt --
        /// Returns z order for a layer by one-based index, or nil when out of range.
        /// @param | index | integer | One-based layer index.
        /// @return | integer | Z order.
        methods.add_method("getLayerZAt", |_, this, index: usize| {
            if index == 0 || index > this.layers.len() {
                return Ok(None);
            }
            let z = this.layers[index - 1].layer.borrow().z;
            Ok(Some(z))
        });
        // -- sortByZ --
        /// Sorts layers by z order on this object.
        methods.add_method_mut("sortByZ", |_, this, ()| {
            this.sort_by_z();
            Ok(())
        });
        // -- setVisible --
        /// Sets set visibility for this object.
        /// @param | v | boolean | Visibility flag.
        methods.add_method_mut("setVisible", |_, this, v: bool| {
            this.visible = v;
            Ok(())
        });
        // -- isVisible --
        /// Returns set visibility and returns a boolean.
        /// @return | boolean | True when visible.
        methods.add_method("isVisible", |_, this, ()| Ok(this.visible));
        // -- update --
        /// Updates all layers in this parallax set.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            let dt = non_negative_f32("LParallaxSet:update", "dt", dt)?;
            for l in &this.layers {
                l.layer.borrow_mut().update(dt);
            }
            Ok(())
        });
        // -- render --
        /// Enqueues render commands for all visible set layers using explicit camera coordinates.
        /// @param | cam_x | number | Camera x coordinate.
        /// @param | cam_y | number | Camera y coordinate.
        methods.add_method("render", |_, this, (cam_x, cam_y): (f32, f32)| {
            let cam_x = finite_f32("LParallaxSet:render", "cam_x", cam_x)?;
            let cam_y = finite_f32("LParallaxSet:render", "cam_y", cam_y)?;
            if !this.visible {
                return Ok(());
            }
            for l in &this.layers {
                let layer = l.layer.borrow();
                let mut st = this.state.borrow_mut();
                LuaParallaxLayer::push_render_commands_internal(&layer, &mut st, cam_x, cam_y);
            }
            Ok(())
        });
        // -- renderAuto --
        /// Enqueues render commands for all visible set layers using the runtime camera.
        methods.add_method("renderAuto", |_, this, ()| {
            if !this.visible {
                return Ok(());
            }
            let (cam_x, cam_y) = {
                let st = this.state.borrow();
                (st.camera.position.x, st.camera.position.y)
            };
            for l in &this.layers {
                let layer = l.layer.borrow();
                let mut st = this.state.borrow_mut();
                LuaParallaxLayer::push_render_commands_internal(&layer, &mut st, cam_x, cam_y);
            }
            Ok(())
        });
        // -- getName --
        /// Returns this set name from this object.
        /// @return | string | Set name.
        methods.add_method("getName", |_, this, ()| Ok(this.name.clone()));
        // -- setName --
        /// Sets this parallax set name for this object.
        /// @param | name | string | Set name.
        methods.add_method_mut("setName", |_, this, name: String| {
            this.name = name;
            Ok(())
        });
        // -- getStats --
        /// Returns aggregated telemetry for all layers in the set.
        /// @return | table | Set-level telemetry fields.
        methods.add_method("getStats", |lua, this, ()| {
            let (cam_x, cam_y, screen_w, screen_h) = {
                let st = this.state.borrow();
                (
                    st.camera.position.x,
                    st.camera.position.y,
                    st.window_state.game_width,
                    st.window_state.game_height,
                )
            };
            let mut visible_tile_count = 0_usize;
            let mut effect_pass_count = 0_usize;
            for layer in &this.layers {
                let stats = layer
                    .layer
                    .borrow()
                    .stats_for_view(cam_x, cam_y, screen_w, screen_h);
                visible_tile_count += stats.visible_tile_count;
                effect_pass_count += stats.effect_pass_count;
            }
            let table = lua.create_table()?;
            table.set("name", this.name.clone())?;
            table.set("layer_count", this.layers.len())?;
            table.set("visible", this.visible)?;
            table.set("visible_tile_count", visible_tile_count)?;
            table.set("effect_pass_count", effect_pass_count)?;
            Ok(table)
        });
    }
}
/// Registers the `lurek.parallax` module.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let parallax = lua.create_table()?;
    let s = state.clone();
    // -- newLayer --
    /// Creates a parallax layer from an options table.
    /// @param | opts | table | Options table with required `texture` and optional scrolling, repeat, z, opacity, tint, blend, visibility, scale, tiling, depth, tile size, motion stretch, and effects fields.
    /// @return | LParallaxLayer | New parallax layer handle.
    parallax.set("newLayer", lua.create_function(move |_, opts: LuaTable| {
            let img_ud: LuaAnyUserData = opts
                .get::<_, LuaAnyUserData>("texture")
                .map_err(|_| LuaError::RuntimeError(
                    "lurek.parallax.newLayer: 'texture' field is required and must be a LuaImage".into(),
                ))?;
            let (tex_key, tex_w, tex_h) = {
                let img = img_ud.borrow::<LuaImage>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.parallax.newLayer: 'texture' must be a valid LuaImage from lurek.render.newImage()".into(),
                    )
                })?;
                let st = s.borrow();
                let tex_data = st.textures.get(img.key).ok_or_else(|| {
                    LuaError::RuntimeError(
                        "lurek.parallax.newLayer: texture handle is stale or has been released".into(),
                    )
                })?;
                (img.key, tex_data.width as f32, tex_data.height as f32)
            };
            let mut layer = ParallaxLayer::new(tex_key, tex_w, tex_h);
            if let Ok(v) = opts.get::<_, f32>("scroll_factor_x") {
                layer.scroll_factor[0] =
                    finite_f32("lurek.parallax.newLayer", "scroll_factor_x", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("scroll_factor_y") {
                layer.scroll_factor[1] =
                    finite_f32("lurek.parallax.newLayer", "scroll_factor_y", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("offset_x") {
                layer.offset[0] = finite_f32("lurek.parallax.newLayer", "offset_x", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("offset_y") {
                layer.offset[1] = finite_f32("lurek.parallax.newLayer", "offset_y", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("autoscroll_x") {
                layer.autoscroll[0] =
                    finite_f32("lurek.parallax.newLayer", "autoscroll_x", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("autoscroll_y") {
                layer.autoscroll[1] =
                    finite_f32("lurek.parallax.newLayer", "autoscroll_y", v)?;
            }
            if let Ok(Some(v)) = opts.get::<_, Option<bool>>("repeat_x") {
                layer.repeat_x = v;
            }
            if let Ok(Some(v)) = opts.get::<_, Option<bool>>("repeat_y") {
                layer.repeat_y = v;
            }
            if let Ok(v) = opts.get::<_, i32>("z") {
                layer.z = v;
            }
            if let Ok(v) = opts.get::<_, f32>("opacity") {
                layer.opacity = unit_f32("lurek.parallax.newLayer", "opacity", v)?;
            }
            if let Ok(r) = opts.get::<_, f32>("tint_r") {
                layer.tint[0] = unit_f32("lurek.parallax.newLayer", "tint_r", r)?;
            }
            if let Ok(g) = opts.get::<_, f32>("tint_g") {
                layer.tint[1] = unit_f32("lurek.parallax.newLayer", "tint_g", g)?;
            }
            if let Ok(b) = opts.get::<_, f32>("tint_b") {
                layer.tint[2] = unit_f32("lurek.parallax.newLayer", "tint_b", b)?;
            }
            if let Ok(a) = opts.get::<_, f32>("tint_a") {
                layer.tint[3] = unit_f32("lurek.parallax.newLayer", "tint_a", a)?;
            }
            if let Ok(v) = opts.get::<_, String>("blend_mode") {
                layer.blend_mode = blend_from_str(&v)?;
            }
            if let Ok(Some(v)) = opts.get::<_, Option<bool>>("visible") {
                layer.visible = v;
            }
            if let Ok(v) = opts.get::<_, f32>("scale_x") {
                layer.scale[0] = positive_f32("lurek.parallax.newLayer", "scale_x", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("scale_y") {
                layer.scale[1] = positive_f32("lurek.parallax.newLayer", "scale_y", v)?;
            }
            if let Ok(Some(v)) = opts.get::<_, Option<bool>>("tiling") {
                layer.set_tiling(v);
            }
            if let Ok(v) = opts.get::<_, f32>("depth") {
                layer.set_depth(finite_f32("lurek.parallax.newLayer", "depth", v)?);
            }
            if let (Ok(w), Ok(h)) = (opts.get::<_, f32>("tile_w"), opts.get::<_, f32>("tile_h")) {
                layer.set_tile_size(
                    finite_f32("lurek.parallax.newLayer", "tile_w", w)?,
                    finite_f32("lurek.parallax.newLayer", "tile_h", h)?,
                );
            }
            if let Ok(Some(v)) = opts.get::<_, Option<bool>>("motion_stretch") {
                layer.motion_stretch_enabled = v;
            }
            if let Ok(v) = opts.get::<_, f32>("motion_stretch_strength") {
                layer.motion_stretch_strength =
                    non_negative_f32("lurek.parallax.newLayer", "motion_stretch_strength", v)?;
            }
            if let Ok(v) = opts.get::<_, f32>("motion_stretch_max") {
                layer.motion_stretch_max_scale =
                    positive_f32("lurek.parallax.newLayer", "motion_stretch_max", v)?.max(1.0);
            }
            if let Ok(tbl) = opts.get::<_, LuaTable>("effects") {
                let mut chain = Vec::new();
                for item in tbl.sequence_values::<LuaValue>() {
                    match item? {
                        LuaValue::String(name) => {
                            chain.push(ShaderPassDescriptor::new(name.to_str()?.to_string()));
                        }
                        LuaValue::Table(pass_tbl) => {
                            let effect_name: String = pass_tbl.get("name")?;
                            let mut pass = ShaderPassDescriptor::new(effect_name);
                            if let Ok(params_tbl) = pass_tbl.get::<_, LuaTable>("params") {
                                for pair in params_tbl.pairs::<String, f32>() {
                                    let (k, v) = pair?;
                                    pass.params.insert(
                                        k.clone(),
                                        finite_f32("lurek.parallax.newLayer", &k, v)?,
                                    );
                                }
                            }
                            chain.push(pass);
                        }
                        _ => {}
                    }
                }
                if !chain.is_empty() {
                    layer.set_effect_chain(chain);
                }
            }
            Ok(LuaParallaxLayer::new(layer, s.clone()))
        })?,
    )?;
    let s = state.clone();
    // -- newSet --
    /// Creates an empty parallax layer set.
    /// @param | name | string | Set name.
    /// @return | LParallaxSet | New parallax set handle.
    parallax.set(
        "newSet",
        lua.create_function(move |_, name: String| Ok(LuaParallaxSet::new(name, s.clone())))?,
    )?;
    let s = state.clone();
    // -- newPresetLayer --
    /// Creates a parallax layer from a named preset and texture image.
    /// @param | preset_name | string | Preset name: `far`, `mid`, or `fog`.
    /// @param | img_ud | LImage | Image handle from `lurek.render.newImage`.
    /// @return | LParallaxLayer | New parallax layer handle.
    parallax.set(
        "newPresetLayer",
        lua.create_function(move |_, (preset_name, img_ud): (String, LuaAnyUserData)| {
            let (tex_key, tex_w, tex_h) = {
                let img = img_ud.borrow::<LuaImage>().map_err(|_| {
                    LuaError::RuntimeError(
                        "lurek.parallax.newPresetLayer: 'texture' must be a valid LuaImage".into(),
                    )
                })?;
                let st = s.borrow();
                let tex_data = st.textures.get(img.key).ok_or_else(|| {
                    LuaError::RuntimeError(
                        "lurek.parallax.newPresetLayer: texture handle is stale or released"
                            .into(),
                    )
                })?;
                (img.key, tex_data.width as f32, tex_data.height as f32)
            };
            let layer = match preset_name.as_str() {
                "far" => presets::far_background(tex_key, tex_w, tex_h),
                "mid" => presets::mid_background(tex_key, tex_w, tex_h),
                "fog" => presets::foreground_fog(tex_key, tex_w, tex_h),
                other => {
                    return Err(LuaError::RuntimeError(format!(
                        "lurek.parallax.newPresetLayer: unknown preset '{}'; expected: far, mid, fog",
                        other
                    )));
                }
            };
            Ok(LuaParallaxLayer::new(layer, s.clone()))
        })?,
    )?;
    /// Performs the 'parallax' operation.
    lurek.set("parallax", parallax)?;
    Ok(())
}
