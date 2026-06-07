//! Lua bindings for the vector SVG graphics module.
//! Exposes the LSvgImage userdata and lurek.svg.load API.
//! Methods mirror the image/sprite module patterns: factory, dimension queries,
//! element state reads/writes/resets, hierarchy navigation, bounds, and GPU canvas caching.

use crate::runtime::SharedState;
use crate::vector::SvgImage;
use crate::lua_api::math_api::LuaVec2;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Represents the Lua-visible LSvgImage object.
pub struct LSvgImage {
    pub state: Rc<RefCell<SharedState>>,
    pub inner: Rc<RefCell<SvgImage>>,
}

impl LuaUserData for LSvgImage {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getWidth --
        /// Returns the document width in points/pixels.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().width as f64)
        });

        // -- getHeight --
        /// Returns the document height in points/pixels.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().height as f64)
        });

        // -- getDimensions --
        /// Returns both the document width and height as two values: `width, height`.
        methods.add_method("getDimensions", |_, this, ()| {
            let svg = this.inner.borrow();
            Ok((svg.width as f64, svg.height as f64))
        });

        // -- draw --
        /// Renders the SVG document at the given position and transform overrides.
        methods.add_method("draw", |_, this, (x, y, rotation, sx, sy, ox, oy): (f32, f32, Option<f32>, Option<f32>, Option<f32>, Option<f32>, Option<f32>)| {
            let rotation = rotation.unwrap_or(0.0);
            let sx = sx.unwrap_or(1.0);
            let sy = sy.unwrap_or(sx);
            let ox = ox.unwrap_or(0.0);
            let oy = oy.unwrap_or(0.0);

            let mut st = this.state.borrow_mut();
            
            // Push transform matrix
            st.render_commands.push(crate::render::renderer::RenderCommand::PushTransform);
            
            // Apply draw parameters
            st.render_commands.push(crate::render::renderer::RenderCommand::Translate { x, y });
            if rotation != 0.0 {
                st.render_commands.push(crate::render::renderer::RenderCommand::Rotate { angle: rotation });
            }
            if sx != 1.0 || sy != 1.0 {
                st.render_commands.push(crate::render::renderer::RenderCommand::Scale { sx, sy });
            }
            if ox != 0.0 || oy != 0.0 {
                st.render_commands.push(crate::render::renderer::RenderCommand::Translate { x: -ox, y: -oy });
            }

            // Draw the SVG image paths
            this.inner.borrow().render(&mut st);

            st.render_commands.push(crate::render::renderer::RenderCommand::PopTransform);
            Ok(())
        });

        // -- getElementIds --
        /// Returns a list of all parsed element and group IDs.
        methods.add_method("getElementIds", |lua, this, ()| {
            let svg = this.inner.borrow();
            let tbl = lua.create_table()?;
            for (i, id) in svg.elements.keys().enumerate() {
                tbl.set(i + 1, id.as_str())?;
            }
            Ok(tbl)
        });

        // -- getElementCount --
        /// Returns the total number of parsed elements (paths and groups) in this SVG document.
        methods.add_method("getElementCount", |_, this, ()| {
            Ok(this.inner.borrow().get_element_count() as i64)
        });

        // -- setElementVisible --
        /// Toggles the visibility of a specific element/group by ID.
        methods.add_method("setElementVisible", |_, this, (id, visible): (String, bool)| {
            let mut svg = this.inner.borrow_mut();
            if let Some(el) = svg.elements.get_mut(&id) {
                el.visible = visible;
                Ok(())
            } else {
                Err(LuaError::RuntimeError(format!("SVG element '{}' not found", id)))
            }
        });

        // -- getElementVisible --
        /// Returns the current visibility flag for the element.
        /// Returns `nil` when the element ID is not found.
        methods.add_method("getElementVisible", |_, this, id: String| {
            Ok(this.inner.borrow().get_element_visible(&id))
        });

        // -- setElementColor --
        /// Overrides the fill/stroke color of a specific element/group by ID.
        methods.add_method("setElementColor", |_, this, (id, r, g, b, a): (String, f32, f32, f32, f32)| {
            let mut svg = this.inner.borrow_mut();
            if let Some(el) = svg.elements.get_mut(&id) {
                el.color_override = Some([r, g, b, a]);
                Ok(())
            } else {
                Err(LuaError::RuntimeError(format!("SVG element '{}' not found", id)))
            }
        });

        // -- getElementColor --
        /// Returns the current RGBA color override `{r, g, b, a}` table for the element.
        /// Returns `nil` when the element has no color override or is not found.
        methods.add_method("getElementColor", |lua, this, id: String| {
            let svg = this.inner.borrow();
            if let Some(col) = svg.get_element_color(&id) {
                let tbl = lua.create_table()?;
                tbl.set(1, col[0] as f64)?;
                tbl.set(2, col[1] as f64)?;
                tbl.set(3, col[2] as f64)?;
                tbl.set(4, col[3] as f64)?;
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        // -- resetElementColor --
        /// Clears the color override on the element, restoring original SVG path colors.
        methods.add_method("resetElementColor", |_, this, id: String| {
            this.inner.borrow_mut()
                .reset_element_color(&id)
                .map_err(LuaError::RuntimeError)
        });

        // -- setElementTransform --
        /// Dynamically transforms a specific element/group by ID.
        methods.add_method("setElementTransform", |_, this, (id, tx, ty, rotation, sx, sy): (String, f32, f32, f32, f32, f32)| {
            let mut svg = this.inner.borrow_mut();
            if let Some(el) = svg.elements.get_mut(&id) {
                el.translation = crate::math::Vec2::new(tx, ty);
                el.rotation = rotation;
                el.scale = crate::math::Vec2::new(sx, sy);
                Ok(())
            } else {
                Err(LuaError::RuntimeError(format!("SVG element '{}' not found", id)))
            }
        });

        // -- getElementTransform --
        /// Returns the current dynamic TRS state of the element as a table `{tx, ty, rotation, sx, sy}`.
        /// Returns `nil` when the element is not found.
        methods.add_method("getElementTransform", |lua, this, id: String| {
            let svg = this.inner.borrow();
            if let Some((tx, ty, r, sx, sy)) = svg.get_element_transform(&id) {
                let tbl = lua.create_table()?;
                tbl.set(1, tx as f64)?;
                tbl.set(2, ty as f64)?;
                tbl.set(3, r as f64)?;
                tbl.set(4, sx as f64)?;
                tbl.set(5, sy as f64)?;
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        // -- resetElementTransform --
        /// Resets the runtime translation, rotation, and scale of the element to identity.
        /// The original SVG-embedded local transform is not affected.
        methods.add_method("resetElementTransform", |_, this, id: String| {
            this.inner.borrow_mut()
                .reset_element_transform(&id)
                .map_err(LuaError::RuntimeError)
        });

        // -- getElementBounds --
        /// Returns the axis-aligned bounding box `{min_x, min_y, max_x, max_y}` of the element.
        /// Returns `nil` when the element is not found or has no geometry.
        methods.add_method("getElementBounds", |lua, this, id: String| {
            let svg = this.inner.borrow();
            if let Some((min_x, min_y, max_x, max_y)) = svg.get_element_bounds(&id) {
                let tbl = lua.create_table()?;
                tbl.set("min_x", min_x as f64)?;
                tbl.set("min_y", min_y as f64)?;
                tbl.set("max_x", max_x as f64)?;
                tbl.set("max_y", max_y as f64)?;
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        // -- getElementParent --
        /// Returns the parent element ID string, or `nil` when the element is the root or not found.
        methods.add_method("getElementParent", |_, this, id: String| {
            Ok(this.inner.borrow().get_element_parent(&id))
        });

        // -- getElementChildren --
        /// Returns a sequential table of direct child element IDs for the given group element.
        /// Returns `nil` when the element is not found. Returns an empty table for leaf elements.
        methods.add_method("getElementChildren", |lua, this, id: String| {
            let svg = this.inner.borrow();
            if let Some(children) = svg.get_element_children(&id) {
                let tbl = lua.create_table()?;
                for (i, child_id) in children.iter().enumerate() {
                    tbl.set(i + 1, child_id.as_str())?;
                }
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        // -- getElementPoints --
        /// Flattens the element path into a polygon array of LVec2 userdata.
        methods.add_method("getElementPoints", |lua, this, (id, step_size): (String, Option<f32>)| {
            let svg = this.inner.borrow();
            if let Some(pts) = svg.get_element_points(&id, step_size) {
                let tbl = lua.create_table()?;
                for (i, p) in pts.into_iter().enumerate() {
                    tbl.set(i + 1, lua.create_userdata(LuaVec2 { inner: p })?)?;
                }
                Ok(LuaValue::Table(tbl))
            } else {
                Ok(LuaValue::Nil)
            }
        });

        // -- getAdjacencies --
        /// Detects neighboring provinces using point-to-point proximity.
        methods.add_method("getAdjacencies", |lua, this, (prefix, epsilon): (String, Option<f32>)| {
            let svg = this.inner.borrow();
            let adj = svg.get_adjacencies(&prefix, epsilon);
            let tbl = lua.create_table()?;
            for (id, neighbors) in adj {
                let neighbors_tbl = lua.create_table()?;
                for (i, neighbor) in neighbors.iter().enumerate() {
                    neighbors_tbl.set(i + 1, neighbor.as_str())?;
                }
                tbl.set(id.as_str(), neighbors_tbl)?;
            }
            Ok(tbl)
        });

        // -- cacheToCanvas --
        /// Rasterizes a specific SVG element/group onto an off-screen GPU Canvas.
        methods.add_method("cacheToCanvas", |_, this, (id, w, h): (String, u32, u32)| {
            let mut svg = this.inner.borrow_mut();
            let mut st = this.state.borrow_mut();
            match svg.cache_to_canvas(&id, w, h, &mut st) {
                Ok(_) => Ok(()),
                Err(e) => Err(LuaError::RuntimeError(e)),
            }
        });

        // -- getCanvasKey --
        /// Returns the LCanvas handle for a previously cached element/group.
        methods.add_method("getCanvasKey", |lua, this, id: String| {
            let svg = this.inner.borrow();
            if let Some(&key) = svg.cached_canvases.get(&id) {
                Ok(Some(lua.create_userdata(crate::lua_api::render_api::LuaCanvas {
                    state: this.state.clone(),
                    key,
                })?))
            } else {
                Ok(None)
            }
        });

        // -- getCanvas --
        /// Alias for getCanvasKey.
        methods.add_method("getCanvas", |lua, this, id: String| {
            let svg = this.inner.borrow();
            if let Some(&key) = svg.cached_canvases.get(&id) {
                Ok(Some(lua.create_userdata(crate::lua_api::render_api::LuaCanvas {
                    state: this.state.clone(),
                    key,
                })?))
            } else {
                Ok(None)
            }
        });

        // -- type --
        methods.add_method("type", |_, _, ()| Ok("LSvgImage"));
        
        // -- typeOf --
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSvgImage" || name == "LObject")
        });
    }
}

/// Registers the global lurek.svg module and its methods.
pub fn register(lua: &Lua, lurek: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let svg = lua.create_table()?;
    
    let s = state.clone();
    svg.set("load", lua.create_function(move |lua, path: String| {
        let st = s.borrow();
        let full_path = st.game_dir.join(&path);
        
        let bytes = std::fs::read(&full_path)
            .map_err(|e| LuaError::RuntimeError(format!("Failed to read SVG file '{}': {}", path, e)))?;
            
        let svg_image = SvgImage::from_bytes(&bytes, &path)
            .map_err(|e| LuaError::RuntimeError(e))?;
            
        lua.create_userdata(LSvgImage {
            state: s.clone(),
            inner: Rc::new(RefCell::new(svg_image)),
        })
    })?)?;
    
    lurek.set("svg", svg)?;
    Ok(())
}
