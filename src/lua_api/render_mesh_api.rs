//! Registers mesh construction for the canonical `lurek.render` table.

use super::{LuaMesh, Mesh, MeshDrawMode, RenderCommand, SharedState};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Register public mesh constructors and upload synchronization commands.
pub(super) fn register_mesh_api(
    lua: &Lua,
    graphics: &LuaTable,
    state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let s = state.clone();
    // -- newMesh --
    /// Creates a custom vertex mesh from an array of vertex data tables.
    /// @param | verts | table | Array of vertex tables: {{x, y, u, v, r, g, b, a}, ...}.
    /// @param | mode | string? | Draw mode: "triangles" (default), "fan", or "strip".
    /// @return | LMesh | The created mesh handle.
    graphics.set(
        "newMesh",
        lua.create_function(move |_, (verts, mode): (LuaTable, Option<String>)| {
            let vertex_count = verts.raw_len();
            if vertex_count > crate::render::mesh::MAX_MESH_VERTICES {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.render.newMesh: mesh vertices has {vertex_count} entries, maximum is {}",
                    crate::render::mesh::MAX_MESH_VERTICES
                )));
            }
            let draw_mode = match mode.as_deref() {
                Some("fan") => MeshDrawMode::Fan,
                Some("strip") => MeshDrawMode::Strip,
                _ => MeshDrawMode::Triangles,
            };
            let rows: Vec<[f32; 8]> = verts
                .sequence_values::<LuaTable>()
                .map(|vert| {
                    let vertex = vert?;
                    Ok([
                        vertex.get(1).unwrap_or(0.0),
                        vertex.get(2).unwrap_or(0.0),
                        vertex.get(3).unwrap_or(0.0),
                        vertex.get(4).unwrap_or(0.0),
                        vertex.get(5).unwrap_or(1.0),
                        vertex.get(6).unwrap_or(1.0),
                        vertex.get(7).unwrap_or(1.0),
                        vertex.get(8).unwrap_or(1.0),
                    ])
                })
                .collect::<LuaResult<_>>()?;
            let mesh = Mesh::from_vertex_rows(&rows, draw_mode);
            mesh.validate()
                .map_err(|err| LuaError::RuntimeError(format!("lurek.render.newMesh: {err}")))?;
            let mut state = s.borrow_mut();
            let uploaded_mesh = mesh.clone();
            let key = state.meshes.insert(mesh);
            state.render_commands.push(RenderCommand::SyncMesh {
                mesh_key: key,
                mesh: uploaded_mesh,
            });
            Ok(LuaMesh {
                state: s.clone(),
                key,
            })
        })?,
    )?;
    Ok(())
}
