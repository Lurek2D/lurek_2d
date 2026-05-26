//! `lurek.layout` — Lua bindings for graph/tree/DAG layout algorithms.

use super::SharedState;
use crate::layout::{
    center_in_area, layout_dag, layout_force, layout_tree, snap_to_grid, ForceConfig,
    LayoutConfig, LayoutEdge, LayoutNode, LayoutResult, NodeId,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

/// Parses a Lua table of nodes into a Vec of LayoutNode.
fn parse_nodes(tbl: &LuaTable) -> LuaResult<Vec<LayoutNode>> {
    let mut nodes = Vec::new();
    for pair in tbl.sequence_values::<LuaTable>() {
        let t = pair?;
        let id: NodeId = t.get("id")?;
        let mut node = LayoutNode::new(id);
        if let Ok(w) = t.get::<f64>("width") {
            node.width = w;
        }
        if let Ok(h) = t.get::<f64>("height") {
            node.height = h;
        }
        if let Ok(label) = t.get::<String>("label") {
            node.label = Some(label);
        }
        nodes.push(node);
    }
    Ok(nodes)
}

/// Parses a Lua table of edges into a Vec of LayoutEdge.
fn parse_edges(tbl: &LuaTable) -> LuaResult<Vec<LayoutEdge>> {
    let mut edges = Vec::new();
    for pair in tbl.sequence_values::<LuaTable>() {
        let t = pair?;
        let from: NodeId = t.get("from")?;
        let to: NodeId = t.get("to")?;
        let weight: f64 = t.get("weight").unwrap_or(1.0);
        edges.push(LayoutEdge { from, to, weight });
    }
    Ok(edges)
}

/// Converts a LayoutResult into a Lua table.
fn result_to_lua(lua: &Lua, result: &LayoutResult) -> LuaResult<LuaTable> {
    let tbl = lua.create_table()?;
    let nodes_tbl = lua.create_table()?;
    for (i, node) in result.nodes.iter().enumerate() {
        let n = lua.create_table()?;
        n.set("id", node.id)?;
        n.set("x", node.x)?;
        n.set("y", node.y)?;
        n.set("width", node.width)?;
        n.set("height", node.height)?;
        if let Some(ref label) = node.label {
            n.set("label", label.clone())?;
        }
        nodes_tbl.set(i + 1, n)?;
    }
    /// Laid-out node array with id, x, y, width, height, and optional label fields.
    tbl.set("nodes", nodes_tbl)?;
    /// Total width of the laid-out graph.
    tbl.set("width", result.width)?;
    /// Total height of the laid-out graph.
    tbl.set("height", result.height)?;
    Ok(tbl)
}

/// Parses a LayoutConfig from a Lua table or returns defaults.
fn parse_config(tbl: Option<LuaTable>) -> LayoutConfig {
    match tbl {
        Some(t) => LayoutConfig {
            h_spacing: t.get("hSpacing").unwrap_or(50.0),
            v_spacing: t.get("vSpacing").unwrap_or(80.0),
            margin: t.get("margin").unwrap_or(20.0),
        },
        None => LayoutConfig::default(),
    }
}

/// Registers the `lurek.layout` namespace with tree, dag, force, and post-processing functions.
/// @module layout
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let layout_table = lua.create_table()?;

    // lurek.layout.tree(nodes, children, root, config?) → result
    /// Lays out a tree using the Reingold-Tilford algorithm.
    /// @param | nodes | table | Array of node tables with id, width, height, label fields.
    /// @param | children | table | Map of parent node ID to array of child node IDs.
    /// @param | root | integer | ID of the root node.
    /// @param | config | table|nil | Optional config with hSpacing, vSpacing, margin.
    /// @return | table | Layout result with nodes array, width, height.
    layout_table.set(
        "tree",
        lua.create_function(
            |lua,
             (nodes_tbl, children_tbl, root, config_tbl): (
                LuaTable,
                LuaTable,
                NodeId,
                Option<LuaTable>,
            )| {
                let nodes = parse_nodes(&nodes_tbl)?;
                let config = parse_config(config_tbl);

                let mut children: HashMap<NodeId, Vec<NodeId>> = HashMap::new();
                for pair in children_tbl.pairs::<LuaValue, LuaTable>() {
                    let (key, val) = pair?;
                    let parent_id: NodeId = match key {
                        LuaValue::Integer(i) => i as NodeId,
                        LuaValue::Number(n) => n as NodeId,
                        _ => continue,
                    };
                    let kids: Vec<NodeId> =
                        val.sequence_values::<usize>().filter_map(|v| v.ok()).collect();
                    children.insert(parent_id, kids);
                }

                let result = layout_tree(&nodes, &children, root, &config);
                result_to_lua(lua, &result)
            },
        )?,
    )?;

    // lurek.layout.dag(nodes, edges, config?) → result
    /// Lays out a DAG using the Sugiyama layered algorithm.
    /// @param | nodes | table | Array of node tables with id, width, height, label fields.
    /// @param | edges | table | Array of edge tables with from, to, weight fields.
    /// @param | config | table|nil | Optional config with hSpacing, vSpacing, margin.
    /// @return | table | Layout result with nodes array, width, height.
    layout_table.set(
        "dag",
        lua.create_function(
            |lua, (nodes_tbl, edges_tbl, config_tbl): (LuaTable, LuaTable, Option<LuaTable>)| {
                let nodes = parse_nodes(&nodes_tbl)?;
                let edges = parse_edges(&edges_tbl)?;
                let config = parse_config(config_tbl);
                let result = layout_dag(&nodes, &edges, &config);
                result_to_lua(lua, &result)
            },
        )?,
    )?;

    // lurek.layout.force(nodes, edges, config?) → result
    /// Lays out a graph using force-directed Fruchterman-Reingold simulation.
    /// @param | nodes | table | Array of node tables with id, width, height, label fields.
    /// @param | edges | table | Array of edge tables with from, to, weight fields.
    /// @param | config | table|nil | Optional config with iterations, repulsion, attraction, cooling, areaWidth, areaHeight.
    /// @return | table | Layout result with nodes array, width, height.
    layout_table.set(
        "force",
        lua.create_function(
            |lua, (nodes_tbl, edges_tbl, config_tbl): (LuaTable, LuaTable, Option<LuaTable>)| {
                let nodes = parse_nodes(&nodes_tbl)?;
                let edges = parse_edges(&edges_tbl)?;

                let force_config = match config_tbl {
                    Some(t) => ForceConfig {
                        iterations: t.get("iterations").unwrap_or(100),
                        repulsion: t.get("repulsion").unwrap_or(10000.0),
                        attraction: t.get("attraction").unwrap_or(0.01),
                        cooling: t.get("cooling").unwrap_or(0.95),
                        area_width: t.get("areaWidth").unwrap_or(800.0),
                        area_height: t.get("areaHeight").unwrap_or(600.0),
                    },
                    None => ForceConfig::default(),
                };

                let result = layout_force(&nodes, &edges, &force_config);
                result_to_lua(lua, &result)
            },
        )?,
    )?;

    // lurek.layout.snapToGrid(result, gridSize) → result
    /// Snaps all node positions to the nearest grid point.
    /// @param | result | table | A layout result table with nodes array.
    /// @param | gridSize | number | Grid cell size in pixels.
    /// @return | table | New layout result with snapped positions.
    layout_table.set(
        "snapToGrid",
        lua.create_function(|lua, (result_tbl, grid_size): (LuaTable, f64)| {
            let nodes_tbl: LuaTable = result_tbl.get("nodes")?;
            let nodes = parse_nodes(&nodes_tbl)?;
            let mut result = LayoutResult::new(nodes);
            snap_to_grid(&mut result, grid_size);
            result_to_lua(lua, &result)
        })?,
    )?;

    // lurek.layout.centerInArea(result, width, height) → result
    /// Centers the layout within a given area.
    /// @param | result | table | A layout result table with nodes array.
    /// @param | width | number | Target area width.
    /// @param | height | number | Target area height.
    /// @return | table | New layout result centered in the area.
    layout_table.set(
        "centerInArea",
        lua.create_function(|lua, (result_tbl, width, height): (LuaTable, f64, f64)| {
            let nodes_tbl: LuaTable = result_tbl.get("nodes")?;
            let nodes = parse_nodes(&nodes_tbl)?;
            let mut result = LayoutResult::new(nodes);
            center_in_area(&mut result, width, height);
            result_to_lua(lua, &result)
        })?,
    )?;

    lurek.set("layout", layout_table)?;
    Ok(())
}
