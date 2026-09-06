//! Registers the `lurek.flownet` Lua API for graph routing, simulation, validation, and flow-network userdata.

use crate::flownet::pathfinding::PathResult;
use crate::flownet::{
    ConversionRule, FlowMode, Graph, GraphEvent, ItemPosition, OverflowPolicy,
    PreparedTopologyBatch, RecipeRule, RecipeStack, TopologyEdit, TopologyNodeRef,
};
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{HashMap, VecDeque};
use std::rc::Rc;
use std::str::FromStr;
const VALID_EVENTS: &[&str] = &[
    "itemEnter",
    "itemLeave",
    "itemDecay",
    "itemConvert",
    "itemLost",
    "edgeEnter",
    "edgeLeave",
    "demandFulfilled",
    "supplyDepleted",
    "itemQueued",
    "itemDequeued",
];
const MAX_GRAPH_SNAPSHOT_BYTES: usize = 64 * 1024 * 1024;

fn graph_api_error(method: &str, message: impl Into<String>) -> LuaError {
    LuaError::RuntimeError(format!("lurek.graph.{method}: {}", message.into()))
}

fn map_graph_error<T>(method: &str, result: Result<T, String>) -> LuaResult<T> {
    result.map_err(|message| graph_api_error(method, message))
}

fn ensure_finite(method: &str, field: &str, value: f64) -> LuaResult<f64> {
    if !value.is_finite() {
        return Err(graph_api_error(method, format!("{field} must be finite")));
    }
    Ok(value)
}

fn ensure_non_negative_finite(method: &str, field: &str, value: f64) -> LuaResult<f64> {
    let value = ensure_finite(method, field, value)?;
    if value < 0.0 {
        return Err(graph_api_error(
            method,
            format!("{field} must be greater than or equal to 0"),
        ));
    }
    Ok(value)
}

fn ensure_positive_finite(method: &str, field: &str, value: f64) -> LuaResult<f64> {
    let value = ensure_finite(method, field, value)?;
    if value <= 0.0 {
        return Err(graph_api_error(
            method,
            format!("{field} must be greater than 0"),
        ));
    }
    Ok(value)
}

fn ensure_capacity_like(method: &str, field: &str, value: i32) -> LuaResult<i32> {
    if value < -1 {
        return Err(graph_api_error(
            method,
            format!("{field} must be -1 or greater"),
        ));
    }
    Ok(value)
}

fn ensure_decay_time(method: &str, value: f64) -> LuaResult<f64> {
    let value = ensure_finite(method, "decay_time", value)?;
    if value < 0.0 && value != -1.0 {
        return Err(graph_api_error(
            method,
            "decay_time must be -1 or greater than or equal to 0",
        ));
    }
    Ok(value)
}

fn ensure_reservation_key(method: &str, key: String) -> LuaResult<String> {
    if key.trim().is_empty() {
        return Err(graph_api_error(method, "reservation key must not be empty"));
    }
    Ok(key)
}

fn ensure_positive_slots(method: &str, field: &str, slots: u32) -> LuaResult<u32> {
    if slots == 0 {
        return Err(graph_api_error(
            method,
            format!("{field} must be greater than 0"),
        ));
    }
    Ok(slots)
}
#[derive(Clone)]
/// Lua-side graph handle storing graph state and registered event callbacks.
struct LuaGraph {
    /// Shared mutable graph state used by node, edge, and item handles.
    inner: Rc<RefCell<Graph>>,
    /// Lua callback registry keys keyed by graph event name.
    callbacks: Rc<RefCell<HashMap<String, LuaRegistryKey>>>,
    /// Per-graph event delivery policy and bounded pull queue.
    event_state: Rc<RefCell<GraphEventState>>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum GraphEventMode {
    Callback,
    Queue,
    Both,
    None,
}

impl GraphEventMode {
    fn parse(value: &str) -> Option<Self> {
        match value {
            "callback" => Some(Self::Callback),
            "queue" => Some(Self::Queue),
            "both" => Some(Self::Both),
            "none" => Some(Self::None),
            _ => None,
        }
    }

    fn as_str(self) -> &'static str {
        match self {
            Self::Callback => "callback",
            Self::Queue => "queue",
            Self::Both => "both",
            Self::None => "none",
        }
    }

    fn queues(self) -> bool {
        matches!(self, Self::Queue | Self::Both)
    }

    fn calls_back(self) -> bool {
        matches!(self, Self::Callback | Self::Both)
    }
}

struct GraphEventState {
    mode: GraphEventMode,
    queue: VecDeque<GraphEvent>,
    limit: usize,
    dropped: u64,
}

impl Default for GraphEventState {
    fn default() -> Self {
        Self {
            mode: GraphEventMode::Callback,
            queue: VecDeque::new(),
            limit: 65_536,
            dropped: 0,
        }
    }
}
#[derive(Clone)]
/// Lua-side node handle referencing one node id inside a graph.
struct LuaNode {
    /// Shared graph containing this node.
    graph: Rc<RefCell<Graph>>,
    /// Node identifier inside the graph.
    id: u64,
}
#[derive(Clone)]
/// Lua-side edge handle referencing one edge id inside a graph.
struct LuaEdge {
    /// Shared graph containing this edge.
    graph: Rc<RefCell<Graph>>,
    /// Edge identifier inside the graph.
    id: u64,
}
#[derive(Clone)]
/// Lua-side item handle referencing one item id inside a graph.
struct LuaGraphItem {
    /// Shared graph containing this item.
    graph: Rc<RefCell<Graph>>,
    /// Item identifier inside the graph.
    id: u64,
}

/// Prepared, version-checked topology mutation for one existing graph.
#[derive(Clone)]
struct LuaGraphTopologyBatch {
    /// Graph that will receive the prepared replacement.
    graph: Rc<RefCell<Graph>>,
    /// Prepared replacement, consumed by commit or discard.
    prepared: Rc<RefCell<Option<PreparedTopologyBatch>>>,
}

fn topology_node_ref(value: LuaValue, method: &str) -> LuaResult<TopologyNodeRef> {
    const MAX_SAFE_LUA_NUMBER_ID: f64 = 9_007_199_254_740_991.0;
    match value {
        LuaValue::Integer(id) if id > 0 => Ok(TopologyNodeRef::Existing(id as u64)),
        LuaValue::Number(id) if id > 0.0 && id.fract() == 0.0 && id <= MAX_SAFE_LUA_NUMBER_ID => {
            Ok(TopologyNodeRef::Existing(id as u64))
        }
        LuaValue::String(key) => Ok(TopologyNodeRef::External(key.to_str()?.to_string())),
        LuaValue::UserData(node) => {
            let node = node.borrow::<LuaNode>().map_err(|error| {
                graph_api_error(method, format!("expected graph node reference: {error}"))
            })?;
            Ok(TopologyNodeRef::Existing(node.id))
        }
        other => Err(graph_api_error(
            method,
            format!(
                "node reference must be id, external key, or LGraphNode, got {}",
                other.type_name()
            ),
        )),
    }
}

fn topology_edits_from_table(edits: LuaTable) -> LuaResult<Vec<TopologyEdit>> {
    if edits.raw_len() > 100_000 {
        return Err(graph_api_error(
            "prepareBatch",
            "operation count exceeds 100000",
        ));
    }
    let mut parsed = Vec::new();
    parsed
        .try_reserve_exact(edits.raw_len())
        .map_err(|_| graph_api_error("prepareBatch", "could not allocate operation staging"))?;
    for (index, value) in edits.sequence_values::<LuaTable>().enumerate() {
        let edit = value.map_err(|error| {
            graph_api_error("prepareBatch", format!("operation {}: {error}", index + 1))
        })?;
        let operation = edit.get::<_, String>("op").map_err(|error| {
            graph_api_error(
                "prepareBatch",
                format!("operation {} missing op: {error}", index + 1),
            )
        })?;
        let parsed_edit = match operation.as_str() {
            "addNode" => TopologyEdit::AddNode {
                external_key: edit.get::<_, Option<String>>("key")?,
                node_type: edit
                    .get::<_, Option<String>>("nodeType")?
                    .or(edit.get::<_, Option<String>>("type")?)
                    .unwrap_or_else(|| "default".to_string()),
                capacity: ensure_capacity_like(
                    "prepareBatch",
                    "capacity",
                    edit.get::<_, Option<i32>>("capacity")?.unwrap_or(-1),
                )?,
            },
            "removeNode" => TopologyEdit::RemoveNode {
                node: topology_node_ref(edit.get("node")?, "prepareBatch")?,
            },
            "addEdge" => TopologyEdit::AddEdge {
                from: topology_node_ref(edit.get("from")?, "prepareBatch")?,
                to: topology_node_ref(edit.get("to")?, "prepareBatch")?,
                edge_type: edit.get::<_, Option<String>>("edgeType")?,
            },
            "removeEdge" => {
                const MAX_SAFE_LUA_NUMBER_ID: f64 = 9_007_199_254_740_991.0;
                let edge_value = edit.get::<_, LuaValue>("edge")?;
                let edge_id = match edge_value {
                    LuaValue::Integer(id) if id > 0 => id as u64,
                    LuaValue::Number(id)
                        if id > 0.0 && id.fract() == 0.0 && id <= MAX_SAFE_LUA_NUMBER_ID =>
                    {
                        id as u64
                    }
                    LuaValue::UserData(edge) => edge.borrow::<LuaEdge>()?.id,
                    other => {
                        return Err(graph_api_error(
                            "prepareBatch",
                            format!(
                                "operation {} edge must be id or LGraphEdge, got {}",
                                index + 1,
                                other.type_name()
                            ),
                        ))
                    }
                };
                TopologyEdit::RemoveEdge { edge_id }
            }
            other => {
                return Err(graph_api_error(
                    "prepareBatch",
                    format!("operation {} has unsupported op '{other}'", index + 1),
                ))
            }
        };
        parsed.push(parsed_edit);
    }
    Ok(parsed)
}

fn recipe_stacks_from_table(table: LuaTable, field: &str) -> LuaResult<Vec<RecipeStack>> {
    let mut normalized = std::collections::BTreeMap::<String, u32>::new();
    if table.raw_len() > 0 {
        if table.raw_len() > 64 {
            return Err(graph_api_error(
                "LGraphNode:setRecipe",
                format!("{field} has more than 64 entries"),
            ));
        }
        for (index, value) in table.sequence_values::<LuaTable>().enumerate() {
            let stack = value.map_err(|error| {
                graph_api_error(
                    "LGraphNode:setRecipe",
                    format!("{field} entry {}: {error}", index + 1),
                )
            })?;
            let item_type = stack
                .get::<_, String>("itemType")
                .or_else(|_| stack.get("type"))
                .or_else(|_| stack.get(1))?;
            let count = stack.get::<_, u32>("count").or_else(|_| stack.get(2))?;
            if item_type.trim().is_empty() || item_type.len() > 128 || count == 0 {
                return Err(graph_api_error(
                    "LGraphNode:setRecipe",
                    format!(
                        "{field} entry {} requires a 1..=128 character type and positive count",
                        index + 1
                    ),
                ));
            }
            let total = normalized.entry(item_type).or_insert(0);
            *total = total.checked_add(count).ok_or_else(|| {
                graph_api_error("LGraphNode:setRecipe", format!("{field} count overflow"))
            })?;
        }
    } else {
        let mut count = 0usize;
        for pair in table.pairs::<String, u32>() {
            let (item_type, quantity) = pair?;
            count += 1;
            if count > 64 {
                return Err(graph_api_error(
                    "LGraphNode:setRecipe",
                    format!("{field} has more than 64 entries"),
                ));
            }
            if item_type.trim().is_empty() || item_type.len() > 128 || quantity == 0 {
                return Err(graph_api_error(
                    "LGraphNode:setRecipe",
                    format!("{field} requires 1..=128 character keys and positive counts"),
                ));
            }
            normalized.insert(item_type, quantity);
        }
    }
    Ok(normalized
        .into_iter()
        .map(|(item_type, count)| RecipeStack { item_type, count })
        .collect())
}

fn recipe_stacks_to_lua<'lua>(lua: &'lua Lua, stacks: &[RecipeStack]) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table_with_capacity(stacks.len(), 0)?;
    for (index, stack) in stacks.iter().enumerate() {
        let entry = lua.create_table_with_capacity(0, 2)?;
        entry.set("itemType", stack.item_type.as_str())?;
        entry.set("count", stack.count)?;
        out.set(index + 1, entry)?;
    }
    Ok(out)
}

impl LuaUserData for LuaGraphTopologyBatch {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- preview --
        /// Returns deterministic metadata and created-id previews for this topology batch.
        /// @return | table | Base version, operation counts, external nodes, and created ids.
        methods.add_method("preview", |lua, this, ()| {
            let prepared = this.prepared.borrow();
            let batch = prepared.as_ref().ok_or_else(|| {
                graph_api_error("LGraphTopologyBatch:preview", "batch is not pending")
            })?;
            let out = lua.create_table()?;
            out.set("baseVersion", batch.base_version())?;
            out.set("operationCount", batch.operation_count())?;
            out.set("changedCount", batch.changed_count())?;
            let external = lua.create_table()?;
            for (key, id) in batch.external_nodes() {
                external.set(key.as_str(), *id)?;
            }
            out.set("externalNodes", external)?;
            out.set("createdNodes", batch.created_nodes().to_vec())?;
            out.set("createdEdges", batch.created_edges().to_vec())?;
            Ok(out)
        });
        // -- commit --
        /// Commits this topology batch if the graph topology version is unchanged.
        /// @return | table | External node keys mapped to committed numeric ids.
        methods.add_method("commit", |lua, this, ()| {
            let batch = this.prepared.borrow().as_ref().cloned().ok_or_else(|| {
                graph_api_error("LGraphTopologyBatch:commit", "batch is not pending")
            })?;
            let mappings = this
                .graph
                .borrow_mut()
                .commit_topology_batch(batch)
                .map_err(|error| graph_api_error("LGraphTopologyBatch:commit", error))?;
            *this.prepared.borrow_mut() = None;
            let out = lua.create_table()?;
            for (key, id) in mappings {
                out.set(key, id)?;
            }
            Ok(out)
        });
        // -- discard --
        /// Discards this prepared topology mutation.
        /// @return | boolean | True when a pending mutation was discarded.
        methods.add_method("discard", |_, this, ()| {
            Ok(this.prepared.borrow_mut().take().is_some())
        });
        // -- isPending --
        /// Returns whether this topology batch remains pending.
        /// @return | boolean | True before commit or discard.
        methods.add_method("isPending", |_, this, ()| {
            Ok(this.prepared.borrow().is_some())
        });
        // -- type --
        /// Returns this userdata type name for Lua-side graph topology inspection.
        /// @return | string | Always `"LGraphTopologyBatch"`.
        methods.add_method("type", |_, _, ()| Ok("LGraphTopologyBatch"));
        // -- typeOf --
        /// Checks whether this userdata matches a requested type.
        /// @param | name | string | Type name.
        /// @return | boolean | True for `LGraphTopologyBatch` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGraphTopologyBatch" || name == "LObject")
        });
    }
}

macro_rules! with_node {
    ($this:expr, $g:ident, $node:ident, $body:expr) => {{
        let $g = $this.graph.borrow();
        let $node = $g
            .nodes
            .get(&$this.id)
            .ok_or_else(|| LuaError::RuntimeError("node not found".into()))?;
        $body
    }};
}
macro_rules! with_node_mut {
    ($this:expr, $g:ident, $node:ident, $body:expr) => {{
        let mut $g = $this.graph.borrow_mut();
        let $node = $g
            .nodes
            .get_mut(&$this.id)
            .ok_or_else(|| LuaError::RuntimeError("node not found".into()))?;
        $body
    }};
}
macro_rules! with_edge {
    ($this:expr, $g:ident, $edge:ident, $body:expr) => {{
        let $g = $this.graph.borrow();
        let $edge = $g
            .edges
            .get(&$this.id)
            .ok_or_else(|| LuaError::RuntimeError("edge not found".into()))?;
        $body
    }};
}
macro_rules! with_edge_mut {
    ($this:expr, $g:ident, $edge:ident, $body:expr) => {{
        let mut $g = $this.graph.borrow_mut();
        let $edge = $g
            .edges
            .get_mut(&$this.id)
            .ok_or_else(|| LuaError::RuntimeError("edge not found".into()))?;
        $body
    }};
}
macro_rules! with_item {
    ($this:expr, $g:ident, $item:ident, $body:expr) => {{
        let $g = $this.graph.borrow();
        let $item = $g
            .items
            .get(&$this.id)
            .ok_or_else(|| LuaError::RuntimeError("item not found".into()))?;
        $body
    }};
}
macro_rules! with_item_mut {
    ($this:expr, $g:ident, $item:ident, $body:expr) => {{
        let mut $g = $this.graph.borrow_mut();
        let $item = $g
            .items
            .get_mut(&$this.id)
            .ok_or_else(|| LuaError::RuntimeError("item not found".into()))?;
        $body
    }};
}
/// Converts a graph path result into Lua tables of node and edge handles plus total cost.
fn path_result_to_lua<'lua>(
    lua: &'lua Lua,
    graph: &Rc<RefCell<Graph>>,
    result: &PathResult,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    let nodes_table = lua.create_table()?;
    for (i, nid) in result.nodes.iter().enumerate() {
        nodes_table.set(
            i + 1,
            LuaNode {
                graph: graph.clone(),
                id: *nid,
            },
        )?;
    }
    /// Performs the 'nodes' operation.
    table.set("nodes", nodes_table)?;
    let edges_table = lua.create_table()?;
    for (i, eid) in result.edges.iter().enumerate() {
        edges_table.set(
            i + 1,
            LuaEdge {
                graph: graph.clone(),
                id: *eid,
            },
        )?;
    }
    /// Performs the 'edges' operation.
    table.set("edges", edges_table)?;
    /// Performs the 'cost' operation.
    table.set("cost", result.cost)?;
    Ok(table)
}
/// Provides Lua methods for inspecting and editing graph items.
impl LuaUserData for LuaGraphItem {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("GraphItem({})", this.id))
        });
        // -- getType --
        /// Returns the item type string used by filters, conversions, supplies, and demands.
        /// @return | string | Current item type.
        methods.add_method("getType", |_, this, ()| {
            with_item!(this, g, item, Ok(item.get_type().to_string()))
        });
        // -- setType --
        /// Changes the item type string used by graph routing and processing rules.
        /// @param | t | string | New item type.
        methods.add_method("setType", |_, this, t: String| {
            with_item_mut!(this, g, item, {
                item.set_type(&t);
                Ok(())
            })
        });
        // -- getDecayTime --
        /// Returns the total decay lifetime configured for this item.
        /// @return | number | Decay time in seconds, or the graph's sentinel for no decay.
        methods.add_method("getDecayTime", |_, this, ()| {
            with_item!(this, g, item, Ok(item.get_decay_time()))
        });
        // -- setDecayTime --
        /// Sets the total decay lifetime for this item.
        /// @param | t | number | Decay time in seconds, or the graph's sentinel for no decay.
        methods.add_method("setDecayTime", |_, this, t: f64| {
            let t = ensure_decay_time("LGraphItem.setDecayTime", t)?;
            with_item_mut!(this, g, item, {
                item.set_decay_time(t);
                Ok(())
            })
        });
        // -- getRemainingLife --
        /// Returns this item's remaining lifetime before decay.
        /// @return | number | Remaining lifetime in seconds.
        methods.add_method("getRemainingLife", |_, this, ()| {
            with_item!(this, g, item, Ok(item.get_remaining_life()))
        });
        // -- isAlive --
        /// Returns whether this item is still alive in the graph simulation.
        /// @return | boolean | True when the item has not decayed or been killed.
        methods.add_method("isAlive", |_, this, ()| {
            with_item!(this, g, item, Ok(item.is_alive()))
        });
        // -- kill --
        /// Marks this item as dead so graph processing can remove or ignore it.
        methods.add_method("kill", |_, this, ()| {
            with_item_mut!(this, g, item, {
                item.kill();
                Ok(())
            })
        });
        // -- getPriority --
        /// Returns this item's routing or queue priority.
        /// @return | integer | Item priority.
        methods.add_method("getPriority", |_, this, ()| {
            with_item!(this, g, item, Ok(item.get_priority()))
        });
        // -- setPriority --
        /// Sets this item's routing or queue priority.
        /// @param | p | integer | New item priority.
        methods.add_method("setPriority", |_, this, p: i32| {
            with_item_mut!(this, g, item, {
                item.set_priority(p);
                Ok(())
            })
        });
        // -- getPosition --
        /// Returns where this item is stored: a node, an edge plus progress, or no values when unplaced.
        /// @return | LGraphNode | Node handle when the item is at a node.
        /// @return | LGraphEdge | Edge handle when the item is in transit.
        /// @return | number | Transit progress when the item is in transit, or nil no value when the item is unplaced.
        methods.add_method("getPosition", |lua, this, ()| -> LuaResult<LuaMultiValue> {
            let graph = this.graph.borrow();
            let item = graph
                .items
                .get(&this.id)
                .ok_or_else(|| LuaError::RuntimeError("item not found".into()))?;
            match &item.position {
                ItemPosition::AtNode(node_id) => {
                    Ok(LuaMultiValue::from_vec(vec![LuaValue::UserData(
                        lua.create_userdata(LuaNode {
                            graph: this.graph.clone(),
                            id: *node_id,
                        })?,
                    )]))
                }
                ItemPosition::InTransit { edge_id, progress } => Ok(LuaMultiValue::from_vec(vec![
                    LuaValue::UserData(lua.create_userdata(LuaEdge {
                        graph: this.graph.clone(),
                        id: *edge_id,
                    })?),
                    LuaValue::Number(*progress),
                ])),
                ItemPosition::Unplaced => Ok(LuaMultiValue::from_vec(vec![])),
            }
        });
        // -- type --
        /// Returns the Lua-visible type name for this graph item handle.
        /// @return | string | The string `LGraphItem`.
        methods.add_method("type", |_, _, ()| Ok("LGraphItem"));
        // -- typeOf --
        /// Returns whether this graph item handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGraphItem`, `GraphItem`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGraphItem" || name == "LObject")
        });
    }
}
/// Provides Lua methods for inspecting and editing graph edges.
impl LuaUserData for LuaEdge {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("GraphEdge({})", this.id))
        });
        // -- getType --
        /// Returns the edge type string used by routing and filters.
        /// @return | string | Current edge type.
        methods.add_method("getType", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.get_type().to_string()))
        });
        // -- setType --
        /// Sets the edge type string used by routing and filters.
        /// @param | t | string | New edge type.
        methods.add_method("setType", |_, this, t: String| {
            with_edge_mut!(this, g, edge, {
                edge.set_type(&t);
                Ok(())
            })
        });
        // -- getFrom --
        /// Returns the source node for this edge.
        /// @return | LGraphNode | Source node handle.
        methods.add_method("getFrom", |_, this, ()| {
            with_edge!(
                this,
                g,
                edge,
                Ok(LuaNode {
                    graph: this.graph.clone(),
                    id: edge.from_node,
                })
            )
        });
        // -- getTo --
        /// Returns the destination node for this edge.
        /// @return | LGraphNode | Destination node handle.
        methods.add_method("getTo", |_, this, ()| {
            with_edge!(
                this,
                g,
                edge,
                Ok(LuaNode {
                    graph: this.graph.clone(),
                    id: edge.to_node,
                })
            )
        });
        // -- getCapacity --
        /// Returns this edge's maximum concurrent item capacity.
        /// @return | integer | Edge capacity.
        methods.add_method("getCapacity", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.capacity))
        });
        // -- setCapacity --
        /// Sets this edge's maximum concurrent item capacity.
        /// @param | c | integer | New edge capacity.
        methods.add_method("setCapacity", |_, this, c: i32| {
            let c = ensure_capacity_like("LGraphEdge.setCapacity", "capacity", c)?;
            with_edge_mut!(this, g, edge, {
                edge.capacity = c;
                Ok(())
            })
        });
        // -- getReservedCapacity --
        /// Returns the total transit capacity reserved on this edge across all reservation keys.
        /// @return | integer | Reserved transit slot count.
        methods.add_method("getReservedCapacity", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.get_reserved_capacity()))
        });
        // -- getAvailableCapacity --
        /// Returns how many transit slots remain after active items and reservations, or -1 when unlimited.
        /// @return | integer | Available transit slots, or -1 when the edge capacity is unlimited.
        methods.add_method("getAvailableCapacity", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.get_available_capacity()))
        });
        // -- reserveCapacity --
        /// Reserves transit capacity slots under a caller-provided key for planning and coordination.
        /// @param | key | string | Reservation key used to group planner-owned capacity holds.
        /// @param | slots | integer? | Number of slots to reserve, defaulting to 1.
        /// @return | boolean | True when the reservation fit within currently available capacity.
        methods.add_method(
            "reserveCapacity",
            |_, this, (key, slots): (String, Option<u32>)| {
                let key = ensure_reservation_key("LGraphEdge.reserveCapacity", key)?;
                let slots = ensure_positive_slots(
                    "LGraphEdge.reserveCapacity",
                    "slots",
                    slots.unwrap_or(1),
                )?;
                with_edge_mut!(this, g, edge, Ok(edge.reserve_capacity(&key, slots)))
            },
        );
        // -- releaseCapacityReservation --
        /// Releases reserved transit capacity for a key and returns the number of slots removed.
        /// @param | key | string | Reservation key to release.
        /// @param | slots | integer? | Number of slots to release, defaulting to all slots for that key.
        /// @return | integer | Number of slots actually released.
        methods.add_method(
            "releaseCapacityReservation",
            |_, this, (key, slots): (String, Option<u32>)| {
                let key = ensure_reservation_key("LGraphEdge.releaseCapacityReservation", key)?;
                let slots = match slots {
                    Some(value) => Some(ensure_positive_slots(
                        "LGraphEdge.releaseCapacityReservation",
                        "slots",
                        value,
                    )?),
                    None => None,
                };
                with_edge_mut!(this, g, edge, {
                    Ok(edge.release_capacity_reservation(&key, slots))
                })
            },
        );
        // -- clearCapacityReservations --
        /// Removes every transit capacity reservation from this edge.
        methods.add_method("clearCapacityReservations", |_, this, ()| {
            with_edge_mut!(this, g, edge, {
                edge.clear_capacity_reservations();
                Ok(())
            })
        });
        // -- getThroughput --
        /// Returns this edge's throughput value.
        /// @return | number | Current throughput.
        methods.add_method("getThroughput", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.throughput))
        });
        // -- setThroughput --
        /// Sets this edge's throughput value.
        /// @param | t | number | New throughput.
        methods.add_method("setThroughput", |_, this, t: f64| {
            let t = ensure_non_negative_finite("LGraphEdge.setThroughput", "throughput", t)?;
            with_edge_mut!(this, g, edge, {
                edge.throughput = t;
                Ok(())
            })
        });
        // -- getTravelTime --
        /// Returns the travel time for items moving across this edge.
        /// @return | number | Travel time in seconds.
        methods.add_method("getTravelTime", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.travel_time))
        });
        // -- setTravelTime --
        /// Sets the travel time for items moving across this edge.
        /// @param | t | number | Travel time in seconds.
        methods.add_method("setTravelTime", |_, this, t: f64| {
            let t = ensure_positive_finite("LGraphEdge.setTravelTime", "travel_time", t)?;
            with_edge_mut!(this, g, edge, {
                edge.travel_time = t;
                Ok(())
            })
        });
        // -- getWeight --
        /// Returns the pathfinding weight for this edge.
        /// @return | number | Edge weight.
        methods.add_method("getWeight", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.weight))
        });
        // -- setWeight --
        /// Sets the pathfinding weight for this edge.
        /// @param | w | number | Edge weight.
        methods.add_method("setWeight", |_, this, w: f64| {
            let w = ensure_non_negative_finite("LGraphEdge.setWeight", "weight", w)?;
            with_edge_mut!(this, g, edge, {
                edge.weight = w;
                Ok(())
            })
        });
        // -- getSpeedModifier --
        /// Returns this edge's speed modifier.
        /// @return | number | Speed modifier.
        methods.add_method("getSpeedModifier", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.speed_modifier))
        });
        // -- setSpeedModifier --
        /// Sets this edge's speed modifier value.
        /// @param | m | number | Speed modifier.
        methods.add_method("setSpeedModifier", |_, this, m: f64| {
            let m = ensure_positive_finite("LGraphEdge.setSpeedModifier", "speed_modifier", m)?;
            with_edge_mut!(this, g, edge, {
                edge.speed_modifier = m;
                Ok(())
            })
        });
        // -- getCooldown --
        /// Returns this edge's cooldown timer value.
        /// @return | number | Cooldown in seconds.
        methods.add_method("getCooldown", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.cooldown))
        });
        // -- setCooldown --
        /// Sets this edge's cooldown timer value.
        /// @param | c | number | Cooldown in seconds.
        methods.add_method("setCooldown", |_, this, c: f64| {
            let c = ensure_non_negative_finite("LGraphEdge.setCooldown", "cooldown", c)?;
            with_edge_mut!(this, g, edge, {
                edge.cooldown = c;
                Ok(())
            })
        });
        // -- isOnCooldown --
        /// Returns whether this edge is currently on cooldown.
        /// @return | boolean | True when cooldown is active.
        methods.add_method("isOnCooldown", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.is_on_cooldown()))
        });
        // -- isBidirectional --
        /// Returns whether this edge allows travel in both directions.
        /// @return | boolean | True when the edge is bidirectional.
        methods.add_method("isBidirectional", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.bidirectional))
        });
        // -- setBidirectional --
        /// Sets whether this edge allows travel in both directions.
        /// @param | b | boolean | New bidirectional flag.
        methods.add_method("setBidirectional", |_, this, b: bool| {
            with_edge_mut!(this, g, edge, {
                edge.bidirectional = b;
                Ok(())
            })
        });
        // -- isActive --
        /// Returns whether this edge is active for routing and simulation.
        /// @return | boolean | True when the edge is active.
        methods.add_method("isActive", |_, this, ()| {
            with_edge!(this, g, edge, Ok(edge.active))
        });
        // -- setActive --
        /// Enables or disables this edge for routing and simulation.
        /// @param | a | boolean | New active flag.
        methods.add_method("setActive", |_, this, a: bool| {
            with_edge_mut!(this, g, edge, {
                edge.active = a;
                Ok(())
            })
        });
        // -- getItemsInTransit --
        /// Returns graph items currently traveling along this edge.
        /// @return | LGraphItem[] | `LGraphItem` handles.
        methods.add_method("getItemsInTransit", |lua, this, ()| {
            let graph = this.graph.borrow();
            let edge = graph
                .edges
                .get(&this.id)
                .ok_or_else(|| LuaError::RuntimeError("edge not found".into()))?;
            let table = lua.create_table()?;
            for (i, iid) in edge.items_in_transit.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaGraphItem {
                        graph: this.graph.clone(),
                        id: *iid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- addAllowedType --
        /// Allows an item type to traverse this edge.
        /// @param | t | string | Item type to allow.
        methods.add_method("addAllowedType", |_, this, t: String| {
            with_edge_mut!(this, g, edge, {
                edge.add_allowed_type(&t);
                Ok(())
            })
        });
        // -- removeAllowedType --
        /// Removes an item type from this edge's allow-list.
        /// @param | t | string | Item type to remove.
        /// @return | boolean | True when the type was present.
        methods.add_method("removeAllowedType", |_, this, t: String| {
            with_edge_mut!(this, g, edge, Ok(edge.remove_allowed_type(&t)))
        });
        // -- clearAllowedTypes --
        /// Clears this edge's item type allow-list.
        methods.add_method("clearAllowedTypes", |_, this, ()| {
            with_edge_mut!(this, g, edge, {
                edge.clear_allowed_types();
                Ok(())
            })
        });
        // -- isItemTypeAllowed --
        /// Returns whether an item type may traverse this edge.
        /// @param | t | string | Item type to check.
        /// @return | boolean | True when the item type is allowed.
        methods.add_method("isItemTypeAllowed", |_, this, t: String| {
            with_edge!(this, g, edge, Ok(edge.is_item_type_allowed(&t)))
        });
        // -- type --
        /// Returns the Lua-visible type name for this graph edge handle.
        /// @return | string | The string `LGraphEdge`.
        methods.add_method("type", |_, _, ()| Ok("LGraphEdge"));
        // -- typeOf --
        /// Returns whether this graph edge handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGraphEdge`, `GraphEdge`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGraphEdge" || name == "LObject")
        });
    }
}
/// Provides Lua methods for inspecting and editing graph nodes.
impl LuaUserData for LuaNode {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("GraphNode({})", this.id))
        });
        // -- getType --
        /// Returns this node's type classification string.
        /// @return | string | Current node type.
        methods.add_method("getType", |_, this, ()| {
            with_node!(this, g, node, Ok(node.get_type().to_string()))
        });
        // -- setType --
        /// Sets this node's type string for this object.
        /// @param | t | string | New node type.
        methods.add_method("setType", |_, this, t: String| {
            with_node_mut!(this, g, node, {
                node.set_type(&t);
                Ok(())
            })
        });
        // -- getCapacity --
        /// Returns this node's item capacity.
        /// @return | integer | Node capacity.
        methods.add_method("getCapacity", |_, this, ()| {
            with_node!(this, g, node, Ok(node.get_capacity()))
        });
        // -- setCapacity --
        /// Sets this node's item capacity value.
        /// @param | c | integer | New node capacity.
        methods.add_method("setCapacity", |_, this, c: i32| {
            let c = ensure_capacity_like("LGraphNode.setCapacity", "capacity", c)?;
            with_node_mut!(this, g, node, {
                node.set_capacity(c);
                Ok(())
            })
        });
        // -- getReservedCapacity --
        /// Returns the total item capacity reserved on this node across all reservation keys.
        /// @return | integer | Reserved node slot count.
        methods.add_method("getReservedCapacity", |_, this, ()| {
            with_node!(this, g, node, Ok(node.get_reserved_capacity()))
        });
        // -- getAvailableCapacity --
        /// Returns how many node inventory slots remain after active items and reservations, or -1 when unlimited.
        /// @return | integer | Available inventory slots, or -1 when the node capacity is unlimited.
        methods.add_method("getAvailableCapacity", |_, this, ()| {
            with_node!(this, g, node, Ok(node.get_available_capacity()))
        });
        // -- reserveCapacity --
        /// Reserves node inventory capacity under a caller-provided key for planning and coordination.
        /// @param | key | string | Reservation key used to group planner-owned capacity holds.
        /// @param | slots | integer? | Number of slots to reserve, defaulting to 1.
        /// @return | boolean | True when the reservation fit within currently available capacity.
        methods.add_method(
            "reserveCapacity",
            |_, this, (key, slots): (String, Option<u32>)| {
                let key = ensure_reservation_key("LGraphNode.reserveCapacity", key)?;
                let slots = ensure_positive_slots(
                    "LGraphNode.reserveCapacity",
                    "slots",
                    slots.unwrap_or(1),
                )?;
                with_node_mut!(this, g, node, Ok(node.reserve_capacity(&key, slots)))
            },
        );
        // -- releaseCapacityReservation --
        /// Releases reserved node capacity for a key and returns the number of slots removed.
        /// @param | key | string | Reservation key to release.
        /// @param | slots | integer? | Number of slots to release, defaulting to all slots for that key.
        /// @return | integer | Number of slots actually released.
        methods.add_method(
            "releaseCapacityReservation",
            |_, this, (key, slots): (String, Option<u32>)| {
                let key = ensure_reservation_key("LGraphNode.releaseCapacityReservation", key)?;
                let slots = match slots {
                    Some(value) => Some(ensure_positive_slots(
                        "LGraphNode.releaseCapacityReservation",
                        "slots",
                        value,
                    )?),
                    None => None,
                };
                with_node_mut!(this, g, node, {
                    Ok(node.release_capacity_reservation(&key, slots))
                })
            },
        );
        // -- clearCapacityReservations --
        /// Removes every inventory capacity reservation from this node.
        methods.add_method("clearCapacityReservations", |_, this, ()| {
            with_node_mut!(this, g, node, {
                node.clear_capacity_reservations();
                Ok(())
            })
        });
        // -- getItemCount --
        /// Returns the number of items currently stored on this node.
        /// @return | integer | Item count.
        methods.add_method("getItemCount", |_, this, ()| {
            with_node!(this, g, node, Ok(node.item_count()))
        });
        // -- isFull --
        /// Returns whether this node has reached its item capacity.
        /// @return | boolean | True when the node is full.
        methods.add_method("isFull", |_, this, ()| {
            with_node!(this, g, node, Ok(node.is_full()))
        });
        // -- isActive --
        /// Returns whether this node is active for graph simulation.
        /// @return | boolean | True when the node is active.
        methods.add_method("isActive", |_, this, ()| {
            with_node!(this, g, node, Ok(node.active))
        });
        // -- setActive --
        /// Enables or disables this node for graph simulation.
        /// @param | a | boolean | New active flag.
        methods.add_method("setActive", |_, this, a: bool| {
            with_node_mut!(this, g, node, {
                node.active = a;
                Ok(())
            })
        });
        // -- getOverflowPolicy --
        /// Returns this node's overflow policy name.
        /// @return | string | Overflow policy string.
        methods.add_method("getOverflowPolicy", |_, this, ()| {
            with_node!(this, g, node, Ok(node.overflow_policy.to_str().to_string()))
        });
        // -- setOverflowPolicy --
        /// Sets this node's overflow policy from a policy name.
        /// @param | p | string | Overflow policy string.
        methods.add_method("setOverflowPolicy", |_, this, p: String| {
            let policy = OverflowPolicy::from_str(&p).map_err(LuaError::RuntimeError)?;
            with_node_mut!(this, g, node, {
                node.overflow_policy = policy;
                Ok(())
            })
        });
        // -- getFlowMode --
        /// Returns this node's flow mode name.
        /// @return | string | Flow mode string.
        methods.add_method("getFlowMode", |_, this, ()| {
            with_node!(this, g, node, Ok(node.flow_mode.to_str().to_string()))
        });
        // -- setFlowMode --
        /// Sets this node's flow mode from a mode name.
        /// @param | m | string | Flow mode string.
        methods.add_method("setFlowMode", |_, this, m: String| {
            let mode = FlowMode::from_str(&m).map_err(LuaError::RuntimeError)?;
            with_node_mut!(this, g, node, {
                node.flow_mode = mode;
                Ok(())
            })
        });
        // -- getPushRate --
        /// Returns this node's push rate value.
        /// @return | number | Push rate.
        methods.add_method("getPushRate", |_, this, ()| {
            with_node!(this, g, node, Ok(node.push_rate))
        });
        // -- setPushRate --
        /// Sets this node's push rate for this object.
        /// @param | r | number | New push rate.
        methods.add_method("setPushRate", |_, this, r: f64| {
            let r = ensure_non_negative_finite("LGraphNode.setPushRate", "push_rate", r)?;
            with_node_mut!(this, g, node, {
                node.push_rate = r;
                Ok(())
            })
        });
        // -- getPullRate --
        /// Returns this node's pull rate value.
        /// @return | number | Pull rate.
        methods.add_method("getPullRate", |_, this, ()| {
            with_node!(this, g, node, Ok(node.pull_rate))
        });
        // -- setPullRate --
        /// Sets this node's pull rate for this object.
        /// @param | r | number | New pull rate.
        methods.add_method("setPullRate", |_, this, r: f64| {
            let r = ensure_non_negative_finite("LGraphNode.setPullRate", "pull_rate", r)?;
            with_node_mut!(this, g, node, {
                node.pull_rate = r;
                Ok(())
            })
        });
        // -- getPushFilter --
        /// Returns this node's optional push item-type filter.
        /// @return | string | Filter string when a push filter is set, or nil when no push filter is set.
        methods.add_method("getPushFilter", |_, this, ()| {
            with_node!(this, g, node, Ok(node.push_filter.clone()))
        });
        // -- setPushFilter --
        /// Sets or clears this node's push item-type filter.
        /// @param | f | string? | Item type filter string.
        methods.add_method("setPushFilter", |_, this, f: Option<String>| {
            with_node_mut!(this, g, node, {
                node.push_filter = f;
                Ok(())
            })
        });
        // -- getPullFilter --
        /// Returns this node's optional pull item-type filter.
        /// @return | string | Filter string when a pull filter is set, or nil when no pull filter is set.
        methods.add_method("getPullFilter", |_, this, ()| {
            with_node!(this, g, node, Ok(node.pull_filter.clone()))
        });
        // -- setPullFilter --
        /// Sets or clears this node's pull item-type filter.
        /// @param | f | string? | Item type filter string.
        methods.add_method("setPullFilter", |_, this, f: Option<String>| {
            with_node_mut!(this, g, node, {
                node.pull_filter = f;
                Ok(())
            })
        });
        // -- getProcessTime --
        /// Returns the processing time used by this node's conversions.
        /// @return | number | Processing time in seconds.
        methods.add_method("getProcessTime", |_, this, ()| {
            with_node!(this, g, node, Ok(node.process_time))
        });
        // -- setProcessTime --
        /// Sets the processing time used by this node's conversions.
        /// @param | t | number | Processing time in seconds.
        methods.add_method("setProcessTime", |_, this, t: f64| {
            let t = ensure_non_negative_finite("LGraphNode.setProcessTime", "process_time", t)?;
            with_node_mut!(this, g, node, {
                node.process_time = t;
                Ok(())
            })
        });
        // -- isQueueEnabled --
        /// Returns whether this node's explicit queue is enabled.
        /// @return | boolean | True when queueing is enabled.
        methods.add_method("isQueueEnabled", |_, this, ()| {
            with_node!(this, g, node, Ok(node.queue_enabled))
        });
        // -- setQueueEnabled --
        /// Enables or disables this node's explicit queue.
        /// @param | e | boolean | New queue enabled flag.
        methods.add_method("setQueueEnabled", |_, this, e: bool| {
            with_node_mut!(this, g, node, {
                node.queue_enabled = e;
                Ok(())
            })
        });
        // -- getQueueCapacity --
        /// Returns this node's queue capacity.
        /// @return | integer | Queue capacity.
        methods.add_method("getQueueCapacity", |_, this, ()| {
            with_node!(this, g, node, Ok(node.queue_capacity))
        });
        // -- setQueueCapacity --
        /// Sets this node's queue capacity value.
        /// @param | c | integer | Queue capacity.
        methods.add_method("setQueueCapacity", |_, this, c: i32| {
            let c = ensure_capacity_like("LGraphNode.setQueueCapacity", "queue_capacity", c)?;
            with_node_mut!(this, g, node, {
                node.queue_capacity = c;
                Ok(())
            })
        });
        // -- getQueueSize --
        /// Returns the number of item ids currently queued at this node.
        /// @return | integer | Queue size.
        methods.add_method("getQueueSize", |_, this, ()| {
            with_node!(this, g, node, Ok(node.queue.len()))
        });
        // -- getItems --
        /// Returns item handles currently stored on this node.
        /// @return | LGraphItem[] | `LGraphItem` handles.
        methods.add_method("getItems", |lua, this, ()| {
            let graph = this.graph.borrow();
            let node = graph
                .nodes
                .get(&this.id)
                .ok_or_else(|| LuaError::RuntimeError("node not found".into()))?;
            let table = lua.create_table()?;
            for (i, iid) in node.items.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaGraphItem {
                        graph: this.graph.clone(),
                        id: *iid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- getEdges --
        /// Returns edge handles connected to this node in the requested direction.
        /// @param | dir | string? | Direction string, defaulting to `both`.
        /// @return | LGraphEdge[] | `LGraphEdge` handles.
        methods.add_method("getEdges", |lua, this, dir: Option<String>| {
            let direction = dir.as_deref().unwrap_or("both");
            let ids = this
                .graph
                .borrow()
                .get_edges_by_direction(this.id, direction)
                .map_err(LuaError::runtime)?;
            let table = lua.create_table()?;
            for (i, eid) in ids.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaEdge {
                        graph: this.graph.clone(),
                        id: *eid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- setConversion --
        /// Configures an item conversion rule on this node.
        /// @param | in_type | string | Input item type.
        /// @param | out_type | string | Output item type.
        /// @param | in_count | integer? | Input count, defaulting to 1.
        /// @param | out_count | integer? | Output count, defaulting to 1.
        methods.add_method(
            "setConversion",
            |_,
             this,
             (in_type, out_type, in_count, out_count): (
                String,
                String,
                Option<u32>,
                Option<u32>,
            )| {
                let rule = ConversionRule {
                    in_type,
                    out_type,
                    in_count: in_count.unwrap_or(1),
                    out_count: out_count.unwrap_or(1),
                };
                with_node_mut!(this, g, node, {
                    node.set_conversion(rule);
                    Ok(())
                })
            },
        );
        // -- clearConversion --
        /// Removes a conversion rule by input item type.
        /// @param | in_type | string | Input item type.
        /// @return | boolean | True when a conversion rule was removed.
        methods.add_method("clearConversion", |_, this, in_type: String| {
            with_node_mut!(this, g, node, Ok(node.clear_conversion(&in_type)))
        });
        // -- clearAllConversions --
        /// Removes every conversion rule from this node.
        methods.add_method("clearAllConversions", |_, this, ()| {
            with_node_mut!(this, g, node, {
                node.clear_all_conversions();
                Ok(())
            })
        });
        // -- setRecipe --
        /// Stores a named multi-input, multi-output recipe without scheduling it.
        /// @param | name | string | Node-local recipe name.
        /// @param | inputs | table | Item-count map or array of `{itemType, count}` records.
        /// @param | outputs | table | Item-count map or array of `{itemType, count}` records.
        methods.add_method(
            "setRecipe",
            |_, this, (name, inputs, outputs): (String, LuaTable, LuaTable)| {
                let recipe = RecipeRule {
                    name,
                    inputs: recipe_stacks_from_table(inputs, "inputs")?,
                    outputs: recipe_stacks_from_table(outputs, "outputs")?,
                };
                with_node_mut!(this, g, node, {
                    node.set_recipe(recipe)
                        .map_err(|error| graph_api_error("LGraphNode:setRecipe", error))
                })
            },
        );
        // -- removeRecipe --
        /// Removes one named explicit recipe.
        /// @param | name | string | Node-local recipe name.
        /// @return | boolean | True when the recipe existed.
        methods.add_method("removeRecipe", |_, this, name: String| {
            with_node_mut!(this, g, node, Ok(node.remove_recipe(&name)))
        });
        // -- getRecipes --
        /// Returns stored recipes in deterministic name order.
        /// @return | table | Array of `{name, inputs, outputs}` records.
        methods.add_method("getRecipes", |lua, this, ()| {
            with_node!(this, g, node, {
                let out = lua.create_table_with_capacity(node.recipes.len(), 0)?;
                for (index, recipe) in node.recipes.values().enumerate() {
                    let entry = lua.create_table_with_capacity(0, 3)?;
                    entry.set("name", recipe.name.as_str())?;
                    entry.set("inputs", recipe_stacks_to_lua(lua, &recipe.inputs)?)?;
                    entry.set("outputs", recipe_stacks_to_lua(lua, &recipe.outputs)?)?;
                    out.set(index + 1, entry)?;
                }
                Ok(out)
            })
        });
        // -- runRecipe --
        /// Executes a stored recipe as a bounded inventory operation.
        /// Scheduling and elapsed-time policy remain owned by the calling Lua game.
        /// @param | name | string | Node-local recipe name.
        /// @param | maxRuns | integer? | Maximum complete runs, defaulting to one.
        /// @return | table | Completed run count plus consumed and produced numeric item ids.
        methods.add_method(
            "runRecipe",
            |lua, this, (name, max_runs): (String, Option<u32>)| {
                let execution = this
                    .graph
                    .borrow_mut()
                    .run_recipe(this.id, &name, max_runs.unwrap_or(1))
                    .map_err(|error| graph_api_error("LGraphNode:runRecipe", error))?;
                let out = lua.create_table_with_capacity(0, 3)?;
                out.set("runs", execution.runs)?;
                out.set("consumedIds", execution.consumed)?;
                out.set("producedIds", execution.produced)?;
                Ok(out)
            },
        );
        // -- addTag --
        /// Adds a tag to this node on this object.
        /// @param | tag | string | Tag to add.
        methods.add_method("addTag", |_, this, tag: String| {
            with_node_mut!(this, g, node, {
                node.add_tag(&tag);
                Ok(())
            })
        });
        // -- removeTag --
        /// Removes a tag from this node on this object.
        /// @param | tag | string | Tag to remove.
        /// @return | boolean | True when the tag was present.
        methods.add_method("removeTag", |_, this, tag: String| {
            with_node_mut!(this, g, node, Ok(node.remove_tag(&tag)))
        });
        // -- hasTag --
        /// Returns whether this node has a tag.
        /// @param | tag | string | Tag to check.
        /// @return | boolean | True when the tag is present.
        methods.add_method("hasTag", |_, this, tag: String| {
            with_node!(this, g, node, Ok(node.has_tag(&tag)))
        });
        // -- clearTags --
        /// Removes every tag from this graph node.
        methods.add_method("clearTags", |_, this, ()| {
            with_node_mut!(this, g, node, {
                node.clear_tags();
                Ok(())
            })
        });
        // -- getTags --
        /// Returns all tags assigned to this node.
        /// @return | string[] | Tag strings.
        methods.add_method("getTags", |lua, this, ()| {
            let graph = this.graph.borrow();
            let node = graph
                .nodes
                .get(&this.id)
                .ok_or_else(|| LuaError::RuntimeError("node not found".into()))?;
            let tags = node.get_tags();
            let table = lua.create_table()?;
            for (i, tag) in tags.iter().enumerate() {
                table.set(i + 1, tag.as_str())?;
            }
            Ok(table)
        });
        // -- addSupply --
        /// Adds supply quantity for an item type on this node.
        /// @param | item_type | string | Item type supplied by the node.
        /// @param | quantity | integer | Supply quantity to add.
        methods.add_method(
            "addSupply",
            |_, this, (item_type, quantity): (String, i32)| {
                with_node_mut!(this, g, node, {
                    node.add_supply(&item_type, quantity);
                    Ok(())
                })
            },
        );
        // -- removeSupply --
        /// Removes supply entry for an item type from this node.
        /// @param | item_type | string | Item type supply entry to remove.
        /// @return | boolean | True when supply existed.
        methods.add_method("removeSupply", |_, this, item_type: String| {
            with_node_mut!(this, g, node, Ok(node.remove_supply(&item_type)))
        });
        // -- clearSupplies --
        /// Removes every supply entry from this node.
        methods.add_method("clearSupplies", |_, this, ()| {
            with_node_mut!(this, g, node, {
                node.clear_supplies();
                Ok(())
            })
        });
        // -- addDemand --
        /// Adds demand quantity and optional priority for an item type on this node.
        /// @param | item_type | string | Item type demanded by the node.
        /// @param | quantity | integer | Demand quantity to add.
        /// @param | priority | integer? | Demand priority, defaulting to 0.
        methods.add_method(
            "addDemand",
            |_, this, (item_type, quantity, priority): (String, i32, Option<i32>)| {
                let p = priority.unwrap_or(0);
                with_node_mut!(this, g, node, {
                    node.add_demand(&item_type, quantity, p);
                    Ok(())
                })
            },
        );
        // -- removeDemand --
        /// Removes demand entry for an item type from this node.
        /// @param | item_type | string | Item type demand entry to remove.
        /// @return | boolean | True when demand existed.
        methods.add_method("removeDemand", |_, this, item_type: String| {
            with_node_mut!(this, g, node, Ok(node.remove_demand(&item_type)))
        });
        // -- clearDemands --
        /// Removes every demand entry from this node.
        methods.add_method("clearDemands", |_, this, ()| {
            with_node_mut!(this, g, node, {
                node.clear_demands();
                Ok(())
            })
        });
        // -- enqueue --
        /// Adds an item handle to this node's explicit queue.
        /// @param | item_ud | LGraphItem | Item handle to enqueue.
        /// @return | boolean | True when the item was queued.
        methods.add_method("enqueue", |_, this, item_ud: LuaAnyUserData| {
            let item = item_ud.borrow::<LuaGraphItem>()?;
            with_node_mut!(this, g, node, Ok(node.enqueue(item.id)))
        });
        // -- dequeue --
        /// Removes and returns the next item from this node's explicit queue.
        /// @return | LGraphItem | Item handle from the queue, or nil when the queue is empty.
        methods.add_method("dequeue", |_, this, ()| {
            let mut graph = this.graph.borrow_mut();
            let node = graph
                .nodes
                .get_mut(&this.id)
                .ok_or_else(|| LuaError::RuntimeError("node not found".into()))?;
            match node.dequeue() {
                Some(iid) => Ok(Some(LuaGraphItem {
                    graph: this.graph.clone(),
                    id: iid,
                })),
                None => Ok(None),
            }
        });
        // -- type --
        /// Returns the Lua-visible type name for this graph node handle.
        /// @return | string | The string `LGraphNode`.
        methods.add_method("type", |_, _, ()| Ok("LGraphNode"));
        // -- typeOf --
        /// Returns whether this graph node handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGraphNode`, `GraphNode`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGraphNode" || name == "LObject")
        });
    }
}
/// Provides Lua methods for graph mutation, routing, algorithms, simulation, and callbacks.
impl LuaUserData for LuaGraph {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            let g = this.inner.borrow();
            Ok(format!(
                "Graph(nodes={}, edges={}, items={})",
                g.get_node_count(),
                g.get_edge_count(),
                g.get_item_count()
            ))
        });
        // -- addNode --
        /// Creates a node with optional type and capacity.
        /// @param | node_type | string? | Node type, defaulting to `default`.
        /// @param | capacity | integer? | Capacity, defaulting to -1.
        /// @return | LGraphNode | New node handle.
        methods.add_method(
            "addNode",
            |_, this, (node_type, capacity): (Option<String>, Option<i32>)| {
                let t = node_type.as_deref().unwrap_or("default");
                let c = ensure_capacity_like("addNode", "capacity", capacity.unwrap_or(-1))?;
                let id = this.inner.borrow_mut().add_node(t, c);
                Ok(LuaNode {
                    graph: this.inner.clone(),
                    id,
                })
            },
        );
        // -- removeNode --
        /// Removes a node and graph links associated with it.
        /// @param | node_ud | LGraphNode | Node handle to remove.
        /// @return | boolean | True when the node was removed.
        methods.add_method("removeNode", |_, this, node_ud: LuaAnyUserData| {
            let node_id = {
                let node = node_ud.borrow::<LuaNode>()?;
                node.id
            };
            if !this.inner.borrow().has_node(node_id) {
                return Err(graph_api_error(
                    "removeNode",
                    format!("node {node_id} does not exist"),
                ));
            }
            Ok(this.inner.borrow_mut().remove_node(node_id))
        });
        // -- hasNode --
        /// Returns whether a node handle still exists in this graph.
        /// @param | node_ud | LGraphNode | Node handle to check.
        /// @return | boolean | True when the node exists.
        methods.add_method("hasNode", |_, this, node_ud: LuaAnyUserData| {
            let node = node_ud.borrow::<LuaNode>()?;
            Ok(this.inner.borrow().has_node(node.id))
        });
        // -- getNodeById --
        /// Resolves a stable numeric node id to a graph-local handle.
        /// @param | id | integer | Numeric node id from a batch mapping, event, or snapshot.
        /// @return | LGraphNode | Node handle, or nil when the id is absent.
        methods.add_method("getNodeById", |lua, this, id: u64| {
            if this.inner.borrow().has_node(id) {
                Ok(LuaValue::UserData(lua.create_userdata(LuaNode {
                    graph: this.inner.clone(),
                    id,
                })?))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- getNodes --
        /// Returns all nodes in this logistics graph.
        /// @return | LGraphNode[] | `LGraphNode` handles.
        methods.add_method("getNodes", |lua, this, ()| {
            let graph = this.inner.borrow();
            let ids = graph.get_node_ids();
            let table = lua.create_table()?;
            for (i, nid) in ids.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaNode {
                        graph: this.inner.clone(),
                        id: *nid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- getNodeCount --
        /// Returns the number of nodes in this graph.
        /// @return | integer | Node count.
        methods.add_method("getNodeCount", |_, this, ()| {
            Ok(this.inner.borrow().get_node_count())
        });
        // -- getVersion --
        /// Returns the monotonic graph topology version.
        /// @return | integer | Version incremented once per committed topology mutation.
        methods.add_method("getVersion", |_, this, ()| {
            Ok(this.inner.borrow().version())
        });
        // -- addEdge --
        /// Creates an edge between two nodes with an optional edge type.
        /// @param | from_ud | LGraphNode | Source node handle.
        /// @param | to_ud | LGraphNode | Destination node handle.
        /// @param | edge_type | string? | Edge type.
        /// @return | LGraphEdge | New edge handle.
        methods.add_method("addEdge", |_, this, (from_ud, to_ud, edge_type): (LuaAnyUserData, LuaAnyUserData, Option<String>)| {
                let from = from_ud.borrow::<LuaNode>()?;
                let to = to_ud.borrow::<LuaNode>()?;
                let id = map_graph_error(
                    "addEdge",
                    this.inner
                        .borrow_mut()
                        .add_edge(from.id, to.id, edge_type.as_deref()),
                )?;
                Ok(LuaEdge {
                    graph: this.inner.clone(),
                    id,
                })
            },
        );
        // -- addEdgeUnchecked --
        /// Adds an edge without validating endpoint nodes exist. Faster for batch construction.
        /// @param | from_ud | LGraphNode | Source node handle.
        /// @param | to_ud | LGraphNode | Destination node handle.
        /// @param | edge_type | string? | Edge type.
        /// @return | LGraphEdge | New edge handle.
        methods.add_method("addEdgeUnchecked", |_, this, (from_ud, to_ud, edge_type): (LuaAnyUserData, LuaAnyUserData, Option<String>)| {
                let from = from_ud.borrow::<LuaNode>()?;
                let to = to_ud.borrow::<LuaNode>()?;
                let id = this
                    .inner
                    .borrow_mut()
                    .add_edge_unchecked(from.id, to.id, edge_type.as_deref());
                Ok(LuaEdge {
                    graph: this.inner.clone(),
                    id,
                })
            },
        );
        // -- removeEdge --
        /// Removes an edge by handle on this object.
        /// @param | edge_ud | LGraphEdge | Edge handle to remove.
        /// @return | boolean | True when the edge was removed.
        methods.add_method("removeEdge", |_, this, edge_ud: LuaAnyUserData| {
            let edge = edge_ud.borrow::<LuaEdge>()?;
            Ok(this.inner.borrow_mut().remove_edge(edge.id))
        });
        // -- hasEdge --
        /// Returns whether an edge handle still exists in this graph.
        /// @param | edge_ud | LGraphEdge | Edge handle to check.
        /// @return | boolean | True when the edge exists.
        methods.add_method("hasEdge", |_, this, edge_ud: LuaAnyUserData| {
            let edge = edge_ud.borrow::<LuaEdge>()?;
            Ok(this.inner.borrow().has_edge(edge.id))
        });
        // -- getEdgeById --
        /// Resolves a stable numeric edge id to a graph-local handle.
        /// @param | id | integer | Numeric edge id from a batch preview, event, or snapshot.
        /// @return | LGraphEdge | Edge handle, or nil when the id is absent.
        methods.add_method("getEdgeById", |lua, this, id: u64| {
            if this.inner.borrow().has_edge(id) {
                Ok(LuaValue::UserData(lua.create_userdata(LuaEdge {
                    graph: this.inner.clone(),
                    id,
                })?))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- getEdges --
        /// Returns all edges in this logistics graph.
        /// @return | LGraphEdge[] | `LGraphEdge` handles.
        methods.add_method("getEdges", |lua, this, ()| {
            let graph = this.inner.borrow();
            let ids = graph.get_edge_ids();
            let table = lua.create_table()?;
            for (i, eid) in ids.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaEdge {
                        graph: this.inner.clone(),
                        id: *eid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- getEdgeCount --
        /// Returns the number of edges in this graph.
        /// @return | integer | Edge count.
        methods.add_method("getEdgeCount", |_, this, ()| {
            Ok(this.inner.borrow().get_edge_count())
        });
        // -- getEdgeBetween --
        /// Returns the edge connecting two nodes when one exists.
        /// @param | from_ud | LGraphNode | Source node handle.
        /// @param | to_ud | LGraphNode | Destination node handle.
        /// @return | LGraphEdge | Edge handle connecting the two nodes, or nil when no edge connects the nodes.
        methods.add_method(
            "getEdgeBetween",
            |_, this, (from_ud, to_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let from = from_ud.borrow::<LuaNode>()?;
                let to = to_ud.borrow::<LuaNode>()?;
                let graph = this.inner.borrow();
                match graph.get_edge_between(from.id, to.id) {
                    Some(eid) => Ok(Some(LuaEdge {
                        graph: this.inner.clone(),
                        id: eid,
                    })),
                    None => Ok(None),
                }
            },
        );
        // -- createItem --
        /// Creates an unplaced graph item with optional type and decay time.
        /// @param | item_type | string? | Item type, defaulting to `default`.
        /// @param | decay_time | number? | Decay lifetime, defaulting to -1.0.
        /// @return | LGraphItem | New graph item handle.
        methods.add_method(
            "createItem",
            |_, this, (item_type, decay_time): (Option<String>, Option<f64>)| {
                let t = item_type.as_deref().unwrap_or("default");
                let d = ensure_decay_time("createItem", decay_time.unwrap_or(-1.0))?;
                let id = this.inner.borrow_mut().create_item(t, d);
                Ok(LuaGraphItem {
                    graph: this.inner.clone(),
                    id,
                })
            },
        );
        // -- spawnItems --
        /// Creates many same-type items directly in one node inventory.
        /// @param | node | LGraphNode | Destination node owned by this graph.
        /// @param | itemType | string | Item type.
        /// @param | count | integer | Number to create, bounded to 100000.
        /// @param | decayTime | number? | Decay lifetime, defaulting to -1.
        /// @return | integer[] | Created numeric item ids in creation order.
        methods.add_method(
            "spawnItems",
            |_, this, (node, item_type, count, decay_time): (
                LuaAnyUserData,
                String,
                u32,
                Option<f64>,
            )| {
                let node = node.borrow::<LuaNode>()?;
                if !Rc::ptr_eq(&node.graph, &this.inner) {
                    return Err(graph_api_error(
                        "spawnItems",
                        "destination node belongs to another graph",
                    ));
                }
                let decay_time =
                    ensure_decay_time("spawnItems", decay_time.unwrap_or(-1.0))?;
                this.inner
                    .borrow_mut()
                    .spawn_items_at_node(node.id, &item_type, count, decay_time)
                    .map_err(|error| graph_api_error("spawnItems", error))
            },
        );
        // -- addItem --
        /// Places an item onto a destination node.
        /// @param | item_ud | LGraphItem | Item handle to place.
        /// @param | node_ud | LGraphNode | Destination node handle.
        methods.add_method(
            "addItem",
            |_, this, (item_ud, node_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let item = item_ud.borrow::<LuaGraphItem>()?;
                let node = node_ud.borrow::<LuaNode>()?;
                map_graph_error(
                    "addItem",
                    this.inner.borrow_mut().add_item_to_node(item.id, node.id),
                )
            },
        );
        // -- removeItem --
        /// Removes an item from this logistics graph.
        /// @param | item_ud | LGraphItem | Item handle to remove.
        /// @return | boolean | True when the item was removed.
        methods.add_method("removeItem", |_, this, item_ud: LuaAnyUserData| {
            let item = item_ud.borrow::<LuaGraphItem>()?;
            Ok(this.inner.borrow_mut().remove_item(item.id))
        });
        // -- hasItem --
        /// Returns whether an item handle still exists in this graph.
        /// @param | item_ud | LGraphItem | Item handle to check.
        /// @return | boolean | True when the item exists.
        methods.add_method("hasItem", |_, this, item_ud: LuaAnyUserData| {
            let item = item_ud.borrow::<LuaGraphItem>()?;
            Ok(this.inner.borrow().has_item(item.id))
        });
        // -- getItemById --
        /// Resolves a stable numeric item id to a graph-local handle.
        /// @param | id | integer | Numeric item id from an event, recipe result, or snapshot.
        /// @return | LGraphItem | Item handle, or nil when the id is absent.
        methods.add_method("getItemById", |lua, this, id: u64| {
            if this.inner.borrow().has_item(id) {
                Ok(LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                    graph: this.inner.clone(),
                    id,
                })?))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- getItems --
        /// Returns all items in this logistics graph.
        /// @return | LGraphItem[] | `LGraphItem` handles.
        methods.add_method("getItems", |lua, this, ()| {
            let graph = this.inner.borrow();
            let ids = graph.get_item_ids();
            let table = lua.create_table()?;
            for (i, iid) in ids.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaGraphItem {
                        graph: this.inner.clone(),
                        id: *iid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- getItemCount --
        /// Returns the number of items in this graph.
        /// @return | integer | Item count.
        methods.add_method("getItemCount", |_, this, ()| {
            Ok(this.inner.borrow().get_item_count())
        });
        // -- sendItem --
        /// Starts moving an item along an edge.
        /// @param | item_ud | LGraphItem | Item handle to send.
        /// @param | edge_ud | LGraphEdge | Edge handle to traverse.
        methods.add_method(
            "sendItem",
            |_, this, (item_ud, edge_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let item = item_ud.borrow::<LuaGraphItem>()?;
                let edge = edge_ud.borrow::<LuaEdge>()?;
                map_graph_error(
                    "sendItem",
                    this.inner.borrow_mut().send_item(item.id, edge.id),
                )
            },
        );
        // -- update --
        /// Advances graph simulation by delta time and dispatches generated callbacks.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("update", |lua, this, dt: f64| {
            let dt = ensure_non_negative_finite("update", "dt", dt)?;
            let events = this.inner.borrow_mut().update(dt);
            handle_graph_events(lua, this, events)
        });
        // -- step --
        /// Runs one discrete graph simulation step and dispatches generated callbacks.
        methods.add_method("step", |lua, this, ()| {
            let events = this.inner.borrow_mut().step();
            handle_graph_events(lua, this, events)
        });
        // -- tickParallel --
        /// Advances graph simulation through the parallel update path and dispatches generated callbacks.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method("tickParallel", |lua, this, dt: f64| {
            let dt = ensure_non_negative_finite("tickParallel", "dt", dt)?;
            let events = this.inner.borrow_mut().update_parallel(dt);
            handle_graph_events(lua, this, events)
        });
        // -- findPath --
        /// Finds a path between two graph nodes.
        /// @param | from_ud | LGraphNode | Start node handle.
        /// @param | to_ud | LGraphNode | Target node handle.
        /// @return | table | Path result table with nodes, edges, and cost, or nil when no path exists.
        /// @field | nodes | LGraphNode[] | Path nodes in order.
        /// @field | edges | LGraphEdge[] | Path edges in order.
        /// @field | cost | number | Total path cost.
        methods.add_method(
            "findPath",
            |lua, this, (from_ud, to_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let from = from_ud.borrow::<LuaNode>()?;
                let to = to_ud.borrow::<LuaNode>()?;
                let graph = this.inner.borrow();
                match graph.find_path(from.id, to.id) {
                    Some(result) => Ok(Some(path_result_to_lua(lua, &this.inner, &result)?)),
                    None => Ok(None),
                }
            },
        );
        // -- findPathForItem --
        /// Finds a path for a specific item between two nodes while respecting item constraints.
        /// @param | item_ud | LGraphItem | Item handle used for routing constraints.
        /// @param | from_ud | LGraphNode | Start node handle.
        /// @param | to_ud | LGraphNode | Target node handle.
        /// @return | table | Path result table with nodes, edges, and cost, or nil when no path exists.
        /// @field | nodes | LGraphNode[] | Path nodes in order.
        /// @field | edges | LGraphEdge[] | Path edges in order.
        /// @field | cost | number | Total path cost.
        methods.add_method("findPathForItem", |lua, this, (item_ud, from_ud, to_ud): (LuaAnyUserData, LuaAnyUserData, LuaAnyUserData)| {
                let item = item_ud.borrow::<LuaGraphItem>()?;
                let from = from_ud.borrow::<LuaNode>()?;
                let to = to_ud.borrow::<LuaNode>()?;
                let graph = this.inner.borrow();
                match graph.find_path_for_item(item.id, from.id, to.id) {
                    Some(result) => Ok(Some(path_result_to_lua(lua, &this.inner, &result)?)),
                    None => Ok(None),
                }
            },
        );
        // -- getDistance --
        /// Returns graph distance between two nodes when reachable.
        /// @param | from_ud | LGraphNode | Start node handle.
        /// @param | to_ud | LGraphNode | Target node handle.
        /// @return | number | Distance between the two nodes, or nil when no path connects the nodes.
        methods.add_method(
            "getDistance",
            |_, this, (from_ud, to_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let from = from_ud.borrow::<LuaNode>()?;
                let to = to_ud.borrow::<LuaNode>()?;
                Ok(this.inner.borrow().get_distance(from.id, to.id))
            },
        );
        // -- getReachable --
        /// Returns nodes reachable from a start node within an optional maximum distance.
        /// @param | from_ud | LGraphNode | Start node handle.
        /// @param | max_dist | number? | Maximum distance.
        /// @return | LGraphNode[] | Reachable `LGraphNode` handles.
        methods.add_method(
            "getReachable",
            |lua, this, (from_ud, max_dist): (LuaAnyUserData, Option<f64>)| {
                let from = from_ud.borrow::<LuaNode>()?;
                let ids = this.inner.borrow().get_reachable(from.id, max_dist);
                let table = lua.create_table()?;
                for (i, nid) in ids.iter().enumerate() {
                    table.set(
                        i + 1,
                        LuaNode {
                            graph: this.inner.clone(),
                            id: *nid,
                        },
                    )?;
                }
                Ok(table)
            },
        );
        // -- getNeighbors --
        /// Returns neighbor nodes connected to a node.
        /// @param | node_ud | LGraphNode | Node handle to inspect.
        /// @return | LGraphNode[] | Neighboring `LGraphNode` handles.
        methods.add_method("getNeighbors", |lua, this, node_ud: LuaAnyUserData| {
            let node = node_ud.borrow::<LuaNode>()?;
            let ids = this.inner.borrow().get_neighbors(node.id);
            let table = lua.create_table()?;
            for (i, nid) in ids.iter().enumerate() {
                table.set(
                    i + 1,
                    LuaNode {
                        graph: this.inner.clone(),
                        id: *nid,
                    },
                )?;
            }
            Ok(table)
        });
        // -- getComponents --
        /// Returns connected components as arrays of node handles.
        /// @return | LGraphNode[] | Component tables containing `LGraphNode` handles.
        methods.add_method("getComponents", |lua, this, ()| {
            let graph = this.inner.borrow();
            let components = graph.get_components();
            let outer = lua.create_table()?;
            for (i, comp) in components.iter().enumerate() {
                let inner_table = lua.create_table()?;
                for (j, nid) in comp.iter().enumerate() {
                    inner_table.set(
                        j + 1,
                        LuaNode {
                            graph: this.inner.clone(),
                            id: *nid,
                        },
                    )?;
                }
                outer.set(i + 1, inner_table)?;
            }
            Ok(outer)
        });
        // -- subgraph --
        /// Creates a new graph containing a subset of nodes.
        /// @param | nodes | table | Array table of `LGraphNode` handles to include.
        /// @return | LGraph | New subgraph handle.
        methods.add_method("subgraph", |_, this, nodes: LuaTable| {
            let mut node_ids = Vec::new();
            for value in nodes.sequence_values::<LuaAnyUserData>() {
                let node_ud = value?;
                let node = node_ud.borrow::<LuaNode>()?;
                node_ids.push(node.id);
            }
            let sub = this.inner.borrow().subgraph(&node_ids);
            Ok(LuaGraph {
                inner: Rc::new(RefCell::new(sub)),
                callbacks: Rc::new(RefCell::new(HashMap::new())),
                event_state: Rc::new(RefCell::new(GraphEventState::default())),
            })
        });
        // -- hasCycle --
        /// Returns whether this graph contains a cycle.
        /// @return | boolean | True when the graph has a cycle.
        methods.add_method("hasCycle", |_, this, ()| {
            Ok(this.inner.borrow().has_cycle())
        });
        // -- topologicalSort --
        /// Returns nodes in topological order when the graph is acyclic.
        /// @return | LGraphNode[] | `LGraphNode` handles in topological order, or nil when sorting is impossible due to cycles.
        methods.add_method("topologicalSort", |lua, this, ()| {
            let graph = this.inner.borrow();
            match graph.topological_sort() {
                Some(sorted) => {
                    let table = lua.create_table()?;
                    for (i, nid) in sorted.iter().enumerate() {
                        table.set(
                            i + 1,
                            LuaNode {
                                graph: this.inner.clone(),
                                id: *nid,
                            },
                        )?;
                    }
                    Ok(Some(table))
                }
                None => Ok(None),
            }
        });
        // -- mst --
        /// Computes a minimum spanning tree using Kruskal and returns edge ids.
        /// @return | integer[] | Array table of edge ids included in the tree.
        methods.add_method("mst", |lua, this, ()| {
            let edge_ids = this.inner.borrow().mst_kruskal();
            let t = lua.create_table()?;
            for (i, eid) in edge_ids.iter().enumerate() {
                t.set(i + 1, *eid)?;
            }
            Ok(t)
        });
        // -- colorGraph --
        /// Computes graph coloring and returns color indices by node id.
        /// @return | table | Map table from node id (integer key) to color index (integer).
        methods.add_method("colorGraph", |lua, this, ()| {
            let colors = this.inner.borrow().color_graph();
            let t = lua.create_table()?;
            for (node_id, color) in &colors {
                t.set(*node_id, *color as u64)?;
            }
            Ok(t)
        });
        // -- isBipartite --
        /// Returns whether this graph is bipartite.
        /// @return | boolean | True when the graph is bipartite.
        methods.add_method("isBipartite", |_lua, this, ()| {
            Ok(this.inner.borrow().is_bipartite())
        });
        // -- astar --
        /// Runs A* pathfinding between two nodes.
        /// @param | from_node | LGraphNode | Start node handle.
        /// @param | to_node | LGraphNode | Target node handle.
        /// @return | LGraphNode[] | `LGraphNode` handles along the path, or nil when no path exists.
        methods.add_method(
            "astar",
            |lua, this, (from_node, to_node): (LuaAnyUserData, LuaAnyUserData)| {
                let from_id = from_node.borrow::<LuaNode>()?.id;
                let to_id = to_node.borrow::<LuaNode>()?.id;
                let positions = HashMap::new();
                match this.inner.borrow().astar_graph(from_id, to_id, &positions) {
                    None => Ok(LuaValue::Nil),
                    Some(path) => {
                        let t = lua.create_table()?;
                        for (i, &nid) in path.iter().enumerate() {
                            t.set(
                                i + 1,
                                lua.create_userdata(LuaNode {
                                    graph: this.inner.clone(),
                                    id: nid,
                                })?,
                            )?;
                        }
                        Ok(LuaValue::Table(t))
                    }
                }
            },
        );
        // -- processDemand --
        /// Processes graph supply and demand once and dispatches generated callbacks.
        methods.add_method("processDemand", |lua, this, ()| {
            let events = this.inner.borrow_mut().process_demand();
            handle_graph_events(lua, this, events)
        });
        // -- getStats --
        /// Returns graph counts and aggregate supply-demand statistics.
        /// @return | table | Table with node, edge, item, activity, transit, demand, supply, and queue counts.
        /// @field | nodes | integer | Node count.
        /// @field | edges | integer | Edge count.
        /// @field | items | integer | Item count.
        /// @field | activeNodes | integer | Active node count.
        /// @field | activeEdges | integer | Active edge count.
        /// @field | itemsInTransit | integer | Items in transit.
        /// @field | itemsOnNodes | integer | Items on nodes.
        /// @field | totalDemand | integer | Total demand.
        /// @field | totalSupply | integer | Total supply.
        /// @field | queuedItems | integer | Queued item count.
        methods.add_method("getStats", |lua, this, ()| {
            let stats = this.inner.borrow().get_stats();
            let table = lua.create_table()?;
            /// Performs the 'nodes' operation.
            table.set("nodes", stats.nodes)?;
            /// Performs the 'edges' operation.
            table.set("edges", stats.edges)?;
            /// Performs the 'items' operation.
            table.set("items", stats.items)?;
            /// Performs the 'activeNodes' operation.
            table.set("activeNodes", stats.active_nodes)?;
            /// Performs the 'activeEdges' operation.
            table.set("activeEdges", stats.active_edges)?;
            /// Performs the 'itemsInTransit' operation.
            table.set("itemsInTransit", stats.items_in_transit)?;
            /// Performs the 'itemsOnNodes' operation.
            table.set("itemsOnNodes", stats.items_on_nodes)?;
            /// Performs the 'totalDemand' operation.
            table.set("totalDemand", stats.total_demand)?;
            /// Performs the 'totalSupply' operation.
            table.set("totalSupply", stats.total_supply)?;
            /// Performs the 'queuedItems' operation.
            table.set("queuedItems", stats.queued_items)?;
            Ok(table)
        });
        // -- summarizeInventory --
        /// Returns aggregate item ownership and alive counts by item type.
        /// @return | table | Total, alive, location counts, queue count, and deterministic `byType`.
        methods.add_method("summarizeInventory", |lua, this, ()| {
            let summary = this.inner.borrow().summarize_inventory();
            let out = lua.create_table_with_capacity(0, 7)?;
            out.set("total", summary.total)?;
            out.set("alive", summary.alive)?;
            out.set("atNodes", summary.at_nodes)?;
            out.set("inTransit", summary.in_transit)?;
            out.set("unplaced", summary.unplaced)?;
            out.set("queued", summary.queued)?;
            let by_type = lua.create_table()?;
            for (item_type, count) in summary.by_type {
                by_type.set(item_type, count)?;
            }
            out.set("byType", by_type)?;
            Ok(out)
        });
        // -- snapshot --
        /// Serializes complete graph state to deterministic compact JSON.
        /// @return | string | Versioned graph snapshot suitable for save or replay checkpoints.
        methods.add_method("snapshot", |lua, this, ()| {
            let snapshot = this
                .inner
                .borrow()
                .snapshot_json()
                .map_err(|error| graph_api_error("snapshot", error))?;
            if snapshot.len() > MAX_GRAPH_SNAPSHOT_BYTES {
                return Err(graph_api_error(
                    "snapshot",
                    format!(
                        "snapshot uses {} bytes, exceeding limit {MAX_GRAPH_SNAPSHOT_BYTES}",
                        snapshot.len()
                    ),
                ));
            }
            lua.create_string(snapshot.as_bytes())
        });
        // -- restoreSnapshot --
        /// Replaces graph state from a versioned snapshot without changing Lua callbacks.
        /// @param | snapshot | string | Snapshot returned by `snapshot`.
        /// @param | expectedVersion | integer? | Optional required current topology version.
        methods.add_method(
            "restoreSnapshot",
            |_, this, (snapshot, expected_version): (LuaString, Option<u64>)| {
                if snapshot.as_bytes().len() > MAX_GRAPH_SNAPSHOT_BYTES {
                    return Err(graph_api_error(
                        "restoreSnapshot",
                        format!(
                            "snapshot uses {} bytes, exceeding limit {MAX_GRAPH_SNAPSHOT_BYTES}",
                            snapshot.as_bytes().len()
                        ),
                    ));
                }
                let snapshot = snapshot.to_str()?;
                this.inner
                    .borrow_mut()
                    .restore_snapshot_json(snapshot.as_ref(), expected_version)
                    .map_err(|error| graph_api_error("restoreSnapshot", error))?;
                this.event_state.borrow_mut().queue.clear();
                Ok(())
            },
        );
        // -- stateHash --
        /// Returns a deterministic hash of complete graph simulation state.
        /// @return | string | Lowercase sixteen-character hexadecimal FNV-1a hash.
        methods.add_method("stateHash", |_, this, ()| {
            this.inner
                .borrow()
                .state_hash()
                .map_err(|error| graph_api_error("stateHash", error))
        });
        // -- on --
        /// Registers a callback for a named graph event generated during simulation.
        /// @param | event_name | string | Event name from the valid graph event list.
        /// @param | func | function | Lua callback invoked with event-specific handles and values.
        methods.add_method(
            "on",
            |lua, this, (event_name, func): (String, LuaFunction)| {
                if !VALID_EVENTS.contains(&event_name.as_str()) {
                    return Err(LuaError::RuntimeError(format!(
                        "unknown graph event: '{}'. Valid events: {}",
                        event_name,
                        VALID_EVENTS.join(", ")
                    )));
                }
                let key = lua.create_registry_value(func)?;
                this.callbacks.borrow_mut().insert(event_name, key);
                Ok(())
            },
        );
        // -- setEventMode --
        /// Selects callback delivery, pull-queue delivery, both, or no delivery.
        /// @param | mode | string | One of `"callback"`, `"queue"`, `"both"`, or `"none"`.
        methods.add_method("setEventMode", |_, this, mode: String| {
            let mode = GraphEventMode::parse(mode.as_str()).ok_or_else(|| {
                graph_api_error(
                    "setEventMode",
                    "mode must be 'callback', 'queue', 'both', or 'none'",
                )
            })?;
            this.event_state.borrow_mut().mode = mode;
            Ok(())
        });
        // -- getEventMode --
        /// Returns the current event delivery mode.
        /// @return | string | `"callback"`, `"queue"`, `"both"`, or `"none"`.
        methods.add_method("getEventMode", |_, this, ()| {
            Ok(this.event_state.borrow().mode.as_str())
        });
        // -- setEventQueueLimit --
        /// Sets the bounded pull-event queue capacity, dropping oldest queued records if needed.
        /// @param | limit | integer | Capacity in the range 1..=1000000.
        methods.add_method("setEventQueueLimit", |_, this, limit: usize| {
            if !(1..=1_000_000).contains(&limit) {
                return Err(graph_api_error(
                    "setEventQueueLimit",
                    "limit must be in the range 1..=1000000",
                ));
            }
            let mut state = this.event_state.borrow_mut();
            state.limit = limit;
            while state.queue.len() > limit {
                state.queue.pop_front();
                state.dropped = state.dropped.saturating_add(1);
            }
            Ok(())
        });
        // -- drainEvents --
        /// Removes and returns queued graph events in deterministic emission order.
        /// @param | maxCount | integer? | Optional maximum number of records to drain.
        /// @return | table | Array of plain Lua event records containing stable numeric ids.
        methods.add_method("drainEvents", |lua, this, max_count: Option<usize>| {
            let mut state = this.event_state.borrow_mut();
            let count = max_count
                .unwrap_or(state.queue.len())
                .min(state.queue.len());
            let out = lua.create_table_with_capacity(count, 0)?;
            for index in 1..=count {
                if let Some(event) = state.queue.pop_front() {
                    out.set(index, graph_event_to_table(lua, event)?)?;
                }
            }
            Ok(out)
        });
        // -- clearEvents --
        /// Discards all queued pull events and returns the removed record count.
        /// @return | integer | Number of queued records removed.
        methods.add_method("clearEvents", |_, this, ()| {
            let mut state = this.event_state.borrow_mut();
            let count = state.queue.len();
            state.queue.clear();
            Ok(count)
        });
        // -- getEventQueueStats --
        /// Returns queue diagnostics without draining events.
        /// @return | table | Mode, pending count, capacity, and cumulative dropped count.
        methods.add_method("getEventQueueStats", |lua, this, ()| {
            let state = this.event_state.borrow();
            let out = lua.create_table_with_capacity(0, 4)?;
            out.set("mode", state.mode.as_str())?;
            out.set("pending", state.queue.len())?;
            out.set("limit", state.limit)?;
            out.set("dropped", state.dropped)?;
            Ok(out)
        });
        // -- prepareBatch --
        /// Validates and stages graph topology edits without mutating the live graph.
        /// @param | edits | table | Array of addNode, removeNode, addEdge, and removeEdge operations.
        /// @param | expectedVersion | integer? | Optional required current topology version.
        /// @return | LGraphTopologyBatch | Prepared mutation with preview, commit, and discard.
        methods.add_method(
            "prepareBatch",
            |_, this, (edits, expected_version): (LuaTable, Option<u64>)| {
                let graph = this.inner.borrow();
                if expected_version.is_some_and(|expected| expected != graph.version()) {
                    return Err(graph_api_error(
                        "prepareBatch",
                        format!(
                            "version conflict: expected {}, current version is {}",
                            expected_version.unwrap_or(graph.version()),
                            graph.version()
                        ),
                    ));
                }
                let edits = topology_edits_from_table(edits)?;
                let prepared = graph
                    .prepare_topology_batch(&edits)
                    .map_err(|error| graph_api_error("prepareBatch", error))?;
                drop(graph);
                Ok(LuaGraphTopologyBatch {
                    graph: this.inner.clone(),
                    prepared: Rc::new(RefCell::new(Some(prepared))),
                })
            },
        );
        // -- batchAddNodes --
        /// Creates multiple nodes at once, returning their IDs as a table.
        /// @param | count | integer | Number of nodes to create.
        /// @param | config | table? | Optional shared config: node_type (string?), capacity (integer?).
        /// @return | integer[] | Array of new node IDs.
        methods.add_method(
            "batchAddNodes",
            |lua, this, (count, config): (u32, Option<LuaTable>)| {
                if count > 100_000 {
                    return Err(graph_api_error("batchAddNodes", "count exceeds 100000"));
                }
                let node_type: String = config
                    .as_ref()
                    .and_then(|c| c.get::<_, Option<String>>("node_type").ok().flatten())
                    .unwrap_or_else(|| "default".to_string());
                let capacity: i32 = config
                    .as_ref()
                    .and_then(|c| c.get::<_, Option<i32>>("capacity").ok().flatten())
                    .unwrap_or(-1);
                let capacity = ensure_capacity_like("batchAddNodes", "capacity", capacity)?;
                let edits = (0..count)
                    .map(|_| TopologyEdit::AddNode {
                        external_key: None,
                        node_type: node_type.clone(),
                        capacity,
                    })
                    .collect::<Vec<_>>();
                let prepared = this
                    .inner
                    .borrow()
                    .prepare_topology_batch(&edits)
                    .map_err(|error| graph_api_error("batchAddNodes", error))?;
                let created = prepared.created_nodes().to_vec();
                this.inner
                    .borrow_mut()
                    .commit_topology_batch(prepared)
                    .map_err(|error| graph_api_error("batchAddNodes", error))?;
                let ids = lua.create_table()?;
                for (index, node_id) in created.into_iter().enumerate() {
                    ids.set(index + 1, node_id)?;
                }
                Ok(ids)
            },
        );
        // -- batchAddEdges --
        /// Creates multiple edges from a table of {from_id, to_id} or {from_id, to_id, edge_type} entries.
        /// @param | edges | table | Array of sub-tables with node IDs and optional edge type.
        /// @return | integer[] | Array of new edge IDs.
        methods.add_method("batchAddEdges", |lua, this, edges: LuaTable| {
            if edges.raw_len() > 100_000 {
                return Err(graph_api_error(
                    "batchAddEdges",
                    "edge count exceeds 100000",
                ));
            }
            let mut edits = Vec::new();
            edits
                .try_reserve_exact(edges.raw_len())
                .map_err(|_| graph_api_error("batchAddEdges", "could not allocate staging"))?;
            for (index, pair) in edges.sequence_values::<LuaTable>().enumerate() {
                let entry = pair.map_err(|error| {
                    graph_api_error("batchAddEdges", format!("edge {}: {error}", index + 1))
                })?;
                let from: u64 = entry.get(1)?;
                let to: u64 = entry.get(2)?;
                let edge_type: Option<String> = entry.get(3).ok();
                edits.push(TopologyEdit::AddEdge {
                    from: TopologyNodeRef::Existing(from),
                    to: TopologyNodeRef::Existing(to),
                    edge_type,
                });
            }
            let prepared = this
                .inner
                .borrow()
                .prepare_topology_batch(&edits)
                .map_err(|error| graph_api_error("batchAddEdges", error))?;
            let created = prepared.created_edges().to_vec();
            this.inner
                .borrow_mut()
                .commit_topology_batch(prepared)
                .map_err(|error| graph_api_error("batchAddEdges", error))?;
            let result = lua.create_table()?;
            for (index, edge_id) in created.into_iter().enumerate() {
                result.set(index + 1, edge_id)?;
            }
            Ok(result)
        });
        // -- batchStep --
        /// Runs multiple simulation steps in sequence. More efficient than calling step() in a loop from Lua.
        /// @param | dt | number | Delta time per step.
        /// @param | iterations | integer | Number of steps to run.
        methods.add_method("batchStep", |lua, this, (dt, iterations): (f64, u32)| {
            let dt = ensure_non_negative_finite("batchStep", "dt", dt)?;
            let mut all_events = Vec::new();
            {
                let mut graph = this.inner.borrow_mut();
                for _ in 0..iterations {
                    let events = graph.update(dt);
                    all_events.extend(events);
                }
            }
            handle_graph_events(lua, this, all_events)
        });
        // -- type --
        /// Returns the Lua-visible type name for this graph handle.
        /// @return | string | The string `LGraph`.
        methods.add_method("type", |_, _, ()| Ok("LGraph"));
        // -- typeOf --
        /// Returns whether this graph handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGraph`, `Graph`, and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGraph" || name == "LObject")
        });
    }
}
/// Routes generated events through the graph's independently configurable delivery modes.
fn handle_graph_events(lua: &Lua, graph: &LuaGraph, events: Vec<GraphEvent>) -> LuaResult<()> {
    let mode = graph.event_state.borrow().mode;
    if mode.queues() {
        let mut state = graph.event_state.borrow_mut();
        for event in &events {
            if state.queue.len() == state.limit {
                state.queue.pop_front();
                state.dropped = state.dropped.saturating_add(1);
            }
            state.queue.push_back(event.clone());
        }
    }
    if mode.calls_back() {
        let callbacks = graph.callbacks.borrow();
        dispatch_events(lua, &graph.inner, &callbacks, events)
    } else {
        Ok(())
    }
}

/// Converts one generated event into a module-local, transport-friendly Lua record.
fn graph_event_to_table<'lua>(lua: &'lua Lua, event: GraphEvent) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    match event {
        GraphEvent::ItemEnter { item_id, node_id } => {
            out.set("event", "itemEnter")?;
            out.set("itemId", item_id)?;
            out.set("nodeId", node_id)?;
        }
        GraphEvent::ItemLeave { item_id, node_id } => {
            out.set("event", "itemLeave")?;
            out.set("itemId", item_id)?;
            out.set("nodeId", node_id)?;
        }
        GraphEvent::ItemDecay { item_id } => {
            out.set("event", "itemDecay")?;
            out.set("itemId", item_id)?;
        }
        GraphEvent::ItemConvert {
            node_id,
            consumed,
            produced,
        } => {
            out.set("event", "itemConvert")?;
            out.set("nodeId", node_id)?;
            out.set("consumed", consumed)?;
            out.set("produced", produced)?;
        }
        GraphEvent::ItemLost { item_id, node_id } => {
            out.set("event", "itemLost")?;
            out.set("itemId", item_id)?;
            out.set("nodeId", node_id)?;
        }
        GraphEvent::EdgeEnter { item_id, edge_id } => {
            out.set("event", "edgeEnter")?;
            out.set("itemId", item_id)?;
            out.set("edgeId", edge_id)?;
        }
        GraphEvent::EdgeLeave { item_id, edge_id } => {
            out.set("event", "edgeLeave")?;
            out.set("itemId", item_id)?;
            out.set("edgeId", edge_id)?;
        }
        GraphEvent::DemandFulfilled {
            demand_node,
            supply_node,
            item_type,
            count,
        } => {
            out.set("event", "demandFulfilled")?;
            out.set("demandNodeId", demand_node)?;
            out.set("supplyNodeId", supply_node)?;
            out.set("itemType", item_type)?;
            out.set("count", count)?;
        }
        GraphEvent::SupplyDepleted { node_id, item_type } => {
            out.set("event", "supplyDepleted")?;
            out.set("nodeId", node_id)?;
            out.set("itemType", item_type)?;
        }
        GraphEvent::ItemQueued { item_id, node_id } => {
            out.set("event", "itemQueued")?;
            out.set("itemId", item_id)?;
            out.set("nodeId", node_id)?;
        }
        GraphEvent::ItemDequeued { item_id, node_id } => {
            out.set("event", "itemDequeued")?;
            out.set("itemId", item_id)?;
            out.set("nodeId", node_id)?;
        }
    }
    Ok(out)
}

/// Dispatches generated graph events to Lua callbacks registered on the graph.
fn dispatch_events(
    lua: &Lua,
    graph_rc: &Rc<RefCell<Graph>>,
    callbacks: &HashMap<String, LuaRegistryKey>,
    events: Vec<GraphEvent>,
) -> LuaResult<()> {
    for event in events {
        let (name, args): (&str, Vec<LuaValue>) = match event {
            GraphEvent::ItemEnter { item_id, node_id } => (
                "itemEnter",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?),
                ],
            ),
            GraphEvent::ItemLeave { item_id, node_id } => (
                "itemLeave",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?),
                ],
            ),
            GraphEvent::ItemDecay { item_id } => (
                "itemDecay",
                vec![LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                    graph: graph_rc.clone(),
                    id: item_id,
                })?)],
            ),
            GraphEvent::ItemConvert {
                node_id,
                consumed,
                produced,
            } => {
                let mut args: Vec<LuaValue> =
                    vec![LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?)];
                let consumed_table = lua.create_table()?;
                for (i, cid) in consumed.iter().enumerate() {
                    consumed_table.set(
                        i + 1,
                        LuaGraphItem {
                            graph: graph_rc.clone(),
                            id: *cid,
                        },
                    )?;
                }
                args.push(LuaValue::Table(consumed_table));
                let produced_table = lua.create_table()?;
                for (i, pid) in produced.iter().enumerate() {
                    produced_table.set(
                        i + 1,
                        LuaGraphItem {
                            graph: graph_rc.clone(),
                            id: *pid,
                        },
                    )?;
                }
                args.push(LuaValue::Table(produced_table));
                ("itemConvert", args)
            }
            GraphEvent::ItemLost { item_id, node_id } => (
                "itemLost",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?),
                ],
            ),
            GraphEvent::EdgeEnter { item_id, edge_id } => (
                "edgeEnter",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaEdge {
                        graph: graph_rc.clone(),
                        id: edge_id,
                    })?),
                ],
            ),
            GraphEvent::EdgeLeave { item_id, edge_id } => (
                "edgeLeave",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaEdge {
                        graph: graph_rc.clone(),
                        id: edge_id,
                    })?),
                ],
            ),
            GraphEvent::DemandFulfilled {
                demand_node,
                supply_node,
                item_type,
                count,
            } => (
                "demandFulfilled",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: demand_node,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: supply_node,
                    })?),
                    LuaValue::String(lua.create_string(&item_type)?),
                    LuaValue::Integer(count as i64),
                ],
            ),
            GraphEvent::SupplyDepleted { node_id, item_type } => (
                "supplyDepleted",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?),
                    LuaValue::String(lua.create_string(&item_type)?),
                ],
            ),
            GraphEvent::ItemQueued { item_id, node_id } => (
                "itemQueued",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?),
                ],
            ),
            GraphEvent::ItemDequeued { item_id, node_id } => (
                "itemDequeued",
                vec![
                    LuaValue::UserData(lua.create_userdata(LuaGraphItem {
                        graph: graph_rc.clone(),
                        id: item_id,
                    })?),
                    LuaValue::UserData(lua.create_userdata(LuaNode {
                        graph: graph_rc.clone(),
                        id: node_id,
                    })?),
                ],
            ),
        };
        if let Some(key) = callbacks.get(name) {
            let func: LuaFunction = lua.registry_value(key)?;
            func.call::<_, ()>(LuaMultiValue::from_vec(args))?;
        }
    }
    Ok(())
}
/// Registers `lurek.flownet` constructors.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newGraph --
    /// Creates an empty logistics graph with no nodes, edges, items, or callbacks.
    /// @return | LGraph | New graph handle.
    tbl.set(
        "newGraph",
        lua.create_function(|_, ()| {
            Ok(LuaGraph {
                inner: Rc::new(RefCell::new(Graph::new())),
                callbacks: Rc::new(RefCell::new(HashMap::new())),
                event_state: Rc::new(RefCell::new(GraphEventState::default())),
            })
        })?,
    )?;
    /// Performs the 'flownet' operation.
    lurek.set("flownet", tbl.clone())?;
    // Backward-compat: keep lurek.graph as an alias.
    lurek.set("graph", tbl)?;
    Ok(())
}
