//! `lurek.mapblock` — Block-based map assembly system.
//!
//! Provides tools for building tile maps from composable blocks using
//! scripted placement, Carcassonne-style neighbor constraints, multi-level
//! support, and configurable tile slots.

use super::SharedState;
use crate::mapblock::{
    MapBlock, MapBlockConfig, MapBlockGenerator, MapGroup, MapOrientation, MapScript, NeighborRules,
    PlacementGrid, ScriptStep, StepType, TilesetRef,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

// ─── Lua wrappers ───────────────────────────────────────────────────────────

/// Lua-facing map block configuration.
struct LuaMapBlockConfig {
    inner: Rc<RefCell<MapBlockConfig>>,
}

/// Lua-facing map block exposed by the lurek engine.
struct LuaMapBlock {
    inner: Rc<RefCell<MapBlock>>,
}

/// Lua-facing map group exposed by the lurek engine.
struct LuaMapGroup {
    inner: Rc<RefCell<MapGroup>>,
}

/// Lua-facing map script exposed by the lurek engine.
struct LuaMapScript {
    inner: Rc<RefCell<MapScript>>,
}

/// Lua-facing neighbor rules exposed by the lurek engine.
struct LuaNeighborRules {
    inner: Rc<RefCell<NeighborRules>>,
}

/// Lua-facing placement grid exposed by the lurek engine.
struct LuaPlacementGrid {
    inner: Rc<RefCell<PlacementGrid>>,
}

/// Lua-facing generator exposed by the lurek engine.
struct LuaMapBlockGenerator {
    inner: Rc<RefCell<MapBlockGenerator>>,
}

/// Lua-facing tileset reference exposed by the lurek engine.
struct LuaTilesetRef {
    inner: Rc<RefCell<TilesetRef>>,
}

/// Lua-facing generation result exposed by the lurek engine.
struct LuaMapBlockResult {
    inner: Rc<crate::mapblock::MapBlockResult>,
}

impl LuaUserData for LuaMapBlockConfig {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add a slot definition — Lua userdata object exposed by the engine.
        /// @param | name | string | Slot name.
        /// @param | required | boolean | Whether this slot is required.
        /// @param | default_gid | integer | Default GID when empty.
        methods.add_method_mut("addSlot", |_, this, (name, required, default_gid): (String, Option<bool>, Option<u32>)| {
            this.inner.borrow_mut().add_slot(&name, required.unwrap_or(false), default_gid.unwrap_or(0));
            Ok(())
        });

        /// Remove a slot by name for this object.
        /// @param | name | string | Slot name to remove.
        /// @return | boolean | True if removed.
        methods.add_method_mut("removeSlot", |_, this, name: String| {
            Ok(this.inner.borrow_mut().remove_slot(&name))
        });

        /// Get the number of slots for this object.
        /// @return | integer | Slot count.
        methods.add_method("getSlotCount", |_, this, ()| {
            Ok(this.inner.borrow().slot_count())
        });

        /// Set maximum layers per block for this object.
        /// @param | max | integer | Max layers (1-10).
        methods.add_method_mut("setMaxLayers", |_, this, max: u32| {
            this.inner.borrow_mut().set_max_layers(max);
            Ok(())
        });

        /// Set default segment size for this object.
        /// @param | size | integer | Segment size in tiles.
        methods.add_method_mut("setDefaultSegmentSize", |_, this, size: u32| {
            this.inner.borrow_mut().set_default_segment_size(size);
            Ok(())
        });
    }
}

impl LuaUserData for LuaMapBlock {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Set a tile slot value — Lua userdata object exposed by the engine.
        /// @param | layer | integer | Layer index (0-based).
        /// @param | x | integer | Tile X position.
        /// @param | y | integer | Tile Y position.
        /// @param | slot | integer | Slot index.
        /// @param | tileset_id | integer | Tileset ID.
        /// @param | gid | integer | Tile GID.
        methods.add_method_mut("setTile", |_, this, (layer, x, y, slot, tileset_id, gid): (usize, u32, u32, usize, u32, u32)| {
            this.inner.borrow_mut().set_tile(layer, x, y, slot, tileset_id, gid);
            Ok(())
        });

        /// Get the tile GID at a specified row and column position.
        /// @param | layer | integer | Layer index.
        /// @param | x | integer | Tile X.
        /// @param | y | integer | Tile Y.
        /// @param | slot | integer | Slot index.
        /// @return | integer | Tile GID.
        methods.add_method("getTile", |_, this, (layer, x, y, slot): (usize, u32, u32, usize)| {
            Ok(this.inner.borrow().get_tile(layer, x, y, slot))
        });

        /// Set edge type for a side and segment.
        /// @param | edge | string | Edge direction: "north", "east", "south", "west".
        /// @param | segment | integer | Segment index along the edge.
        /// @param | edge_type | integer | Edge type identifier.
        methods.add_method_mut("setEdge", |_, this, (edge_str, segment, edge_type): (String, u32, u32)| {
            let edge = match edge_str.to_lowercase().as_str() {
                "north" | "n" => crate::mapblock::block::Edge::North,
                "east" | "e" => crate::mapblock::block::Edge::East,
                "south" | "s" => crate::mapblock::block::Edge::South,
                "west" | "w" => crate::mapblock::block::Edge::West,
                _ => return Err(LuaError::RuntimeError(format!("Invalid edge: {edge_str}"))),
            };
            this.inner.borrow_mut().set_edge(edge, segment, edge_type);
            Ok(())
        });

        /// Set the map block's display or lookup name string value.
        /// @param | name | string | Block name.
        methods.add_method_mut("setName", |_, this, name: String| {
            this.inner.borrow_mut().set_name(&name);
            Ok(())
        });

        /// Get the map block's display or lookup name string value.
        /// @return | string | Block name.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.inner.borrow().get_name().to_string())
        });

        /// Set block weight for random selection.
        /// @param | weight | number | Weight value (higher = more likely).
        methods.add_method_mut("setWeight", |_, this, weight: f32| {
            this.inner.borrow_mut().weight = weight;
            Ok(())
        });

        /// Set whether block must be on map edge.
        /// @param | edge_only | boolean | True if edge-only.
        methods.add_method_mut("setEdgeOnly", |_, this, edge_only: bool| {
            this.inner.borrow_mut().edge_only = edge_only;
            Ok(())
        });

        /// Set whether block must be in interior.
        /// @param | interior_only | boolean | True if interior-only.
        methods.add_method_mut("setInteriorOnly", |_, this, interior_only: bool| {
            this.inner.borrow_mut().interior_only = interior_only;
            Ok(())
        });

        /// Set multi-level span for this object.
        /// @param | levels | integer | Number of levels this block spans.
        methods.add_method_mut("setLevelSpan", |_, this, levels: u32| {
            this.inner.borrow_mut().level_span = levels;
            Ok(())
        });

        /// Get the block width measured in tile grid units.
        /// @return | integer | Block width.
        methods.add_method("getWidth", |_, this, ()| {
            Ok(this.inner.borrow().get_width())
        });

        /// Get height in tiles for this object.
        /// @return | integer | Block height.
        methods.add_method("getHeight", |_, this, ()| {
            Ok(this.inner.borrow().get_height())
        });

        /// Get the number of tile layers in this map block.
        /// @return | integer | Number of layers.
        methods.add_method("getLayerCount", |_, this, ()| {
            Ok(this.inner.borrow().get_layer_count())
        });
    }
}

impl LuaUserData for LuaMapGroup {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add a block to this group for this object.
        /// @param | block | MapBlock | Block to add.
        methods.add_method_mut("addBlock", |_, this, block: LuaAnyUserData| {
            let lua_block = block.borrow::<LuaMapBlock>()?;
            this.inner.borrow_mut().add_block(lua_block.inner.borrow().clone());
            Ok(())
        });

        /// Get the number of blocks for this object.
        /// @return | integer | Block count.
        methods.add_method("getBlockCount", |_, this, ()| {
            Ok(this.inner.borrow().block_count())
        });

        /// Get the display name of this map group object.
        /// @return | string | Group name.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.inner.borrow().name().to_string())
        });

        /// Add a script to this group for this object.
        /// @param | script | MapScript | Script to add.
        methods.add_method_mut("addScript", |_, this, script: LuaAnyUserData| {
            let lua_script = script.borrow::<LuaMapScript>()?;
            this.inner.borrow_mut().add_script(lua_script.inner.borrow().clone());
            Ok(())
        });
    }
}

impl LuaUserData for LuaMapScript {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add a generation step — Lua userdata object exposed by the engine.
        /// @param | step_type | string | Step type name.
        /// @param | opts | table | Step configuration options.
        methods.add_method_mut("addStep", |_, this, (step_type_str, opts): (String, Option<LuaTable>)| {
            let step_type = match step_type_str.to_lowercase().as_str() {
                "fill_random" | "fillrandom" => StepType::FillRandom,
                "place_block" | "placeblock" => StepType::PlaceBlock,
                "place_random" | "placerandom" => StepType::PlaceRandom,
                "place_line" | "placeline" => StepType::PlaceLine,
                "flood_fill" | "floodfill" => StepType::FloodFill,
                "fill_area" | "fillarea" => StepType::FillArea,
                "draw_path" | "drawpath" => StepType::DrawPath,
                "fill_rect" | "fillrect" => StepType::FillRect,
                "fill_edges" | "filledges" => StepType::FillEdges,
                "auto_place" | "autoplace" => StepType::AutoPlace,
                _ => return Err(LuaError::RuntimeError(format!("Unknown step type: {step_type_str}"))),
            };

            let mut step = ScriptStep { step_type, ..Default::default() };

            if let Some(opts) = opts {
                if let Ok(group) = opts.get::<_, String>("group") {
                    step.group_name = group;
                }
                if let Ok(count) = opts.get::<_, u32>("count") {
                    step.count = count;
                }
                if let Ok(x) = opts.get::<_, i32>("x") {
                    step.x = x;
                }
                if let Ok(y) = opts.get::<_, i32>("y") {
                    step.y = y;
                }
                if let Ok(w) = opts.get::<_, u32>("width") {
                    step.width = w;
                }
                if let Ok(h) = opts.get::<_, u32>("height") {
                    step.height = h;
                }
                if let Ok(r) = opts.get::<_, u32>("rotation") {
                    step.rotation = r;
                }
                if let Ok(m) = opts.get::<_, bool>("mirror") {
                    step.mirror = m;
                }
                if let Ok(rr) = opts.get::<_, bool>("random_rotation") {
                    step.random_rotation = rr;
                }
                if let Ok(rm) = opts.get::<_, bool>("random_mirror") {
                    step.random_mirror = rm;
                }
                if let Ok(ms) = opts.get::<_, bool>("match_sides") {
                    step.match_sides = ms;
                }
                if let Ok(c) = opts.get::<_, f32>("chance") {
                    step.chance = c;
                }
                if let Ok(rc) = opts.get::<_, u32>("repeat") {
                    step.repeat_count = rc;
                }
                if let Ok(bi) = opts.get::<_, i32>("block_index") {
                    step.block_index = bi;
                }
                if let Ok(tid) = opts.get::<_, u32>("tile_id") {
                    step.tile_id = tid;
                }
                if let Ok(si) = opts.get::<_, usize>("slot") {
                    step.slot_index = si;
                }
                if let Ok(l) = opts.get::<_, u32>("layer") {
                    step.layer = l;
                }
                if let Ok(lv) = opts.get::<_, u32>("level") {
                    step.level = lv;
                }
            }

            this.inner.borrow_mut().add_step(step);
            Ok(())
        });

        /// Get the number of steps for this object.
        /// @return | integer | Step count.
        methods.add_method("getStepCount", |_, this, ()| {
            Ok(this.inner.borrow().step_count())
        });

        /// Clear all queued script steps from this map script.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });

        /// Get the script name for this object.
        /// @return | string | Script name.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.inner.borrow().name().to_string())
        });
    }
}

impl LuaUserData for LuaNeighborRules {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add bidirectional compatibility between two edge types.
        /// @param | type_a | integer | First edge type.
        /// @param | type_b | integer | Second edge type.
        methods.add_method_mut("addCompatible", |_, this, (a, b): (u32, u32)| {
            this.inner.borrow_mut().add_compatible(a, b);
            Ok(())
        });

        /// Add one-way compatibility for this object.
        /// @param | type_a | integer | Source edge type.
        /// @param | type_b | integer | Target edge type.
        methods.add_method_mut("addCompatibleOneWay", |_, this, (a, b): (u32, u32)| {
            this.inner.borrow_mut().add_compatible_one_way(a, b);
            Ok(())
        });

        /// Check if two edge types are compatible.
        /// @param | type_a | integer | First edge type.
        /// @param | type_b | integer | Second edge type.
        /// @return | boolean | True if compatible.
        methods.add_method("isCompatible", |_, this, (a, b): (u32, u32)| {
            Ok(this.inner.borrow().is_compatible(a, b))
        });

        /// Clear all neighbor placement rules from this rule set.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });
    }
}

impl LuaUserData for LuaPlacementGrid {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Add a position to the grid — Lua userdata object exposed by the engine.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        methods.add_method_mut("addPosition", |_, this, (x, y): (i32, i32)| {
            this.inner.borrow_mut().add_position(x, y);
            Ok(())
        });

        /// Check whether a placement grid position is currently available.
        /// @param | x | integer | X coordinate.
        /// @param | y | integer | Y coordinate.
        /// @return | boolean | True if available.
        methods.add_method("isAvailable", |_, this, (x, y): (i32, i32)| {
            Ok(this.inner.borrow().is_available(x, y))
        });

        /// Get available position count for this object.
        /// @return | integer | Number of available positions.
        methods.add_method("getAvailableCount", |_, this, ()| {
            Ok(this.inner.borrow().available_count())
        });

        /// Clear all positions and placed blocks.
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.borrow_mut().clear();
            Ok(())
        });
    }
}

impl LuaUserData for LuaMapBlockGenerator {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Set rectangular map shape — Lua userdata object exposed by the engine.
        /// @param | width | integer | Grid width.
        /// @param | height | integer | Grid height.
        methods.add_method_mut("setRectShape", |_, this, (w, h): (u32, u32)| {
            this.inner.borrow_mut().set_rect_shape(w, h);
            Ok(())
        });

        /// Set the generator map shape using a list of tile positions.
        /// @param | positions | table | Array of {x, y} positions.
        methods.add_method_mut("setShape", |_, this, positions: LuaTable| {
            let mut pos_vec = Vec::new();
            for pair in positions.sequence_values::<LuaTable>() {
                let pair = pair?;
                let x: i32 = pair.get(1)?;
                let y: i32 = pair.get(2)?;
                pos_vec.push((x, y));
            }
            this.inner.borrow_mut().set_shape(&pos_vec);
            Ok(())
        });

        /// Set rendering orientation for this object.
        /// @param | orientation | string | "topdown" or "isometric".
        methods.add_method_mut("setOrientation", |_, this, orientation: String| {
            let o = MapOrientation::from_name(&orientation)
                .ok_or_else(|| LuaError::RuntimeError(format!("Unknown orientation: {orientation}")))?;
            this.inner.borrow_mut().set_orientation(o);
            Ok(())
        });

        /// Set the number of vertical levels or storeys to generate.
        /// @param | levels | integer | Max levels (1-10).
        methods.add_method_mut("setMaxLevels", |_, this, levels: u32| {
            this.inner.borrow_mut().set_max_levels(levels);
            Ok(())
        });

        /// Set neighbor matching rules for this object.
        /// @param | rules | NeighborRules | Rules object.
        methods.add_method_mut("setRules", |_, this, rules: LuaAnyUserData| {
            let lua_rules = rules.borrow::<LuaNeighborRules>()?;
            this.inner.borrow_mut().set_rules(lua_rules.inner.borrow().clone());
            Ok(())
        });

        /// Set RNG seed for deterministic generation.
        /// @param | seed | integer | Seed value.
        methods.add_method_mut("setSeed", |_, this, seed: u64| {
            this.inner.borrow_mut().set_seed(seed);
            Ok(())
        });

        /// Set tile pixel dimensions for this object.
        /// @param | w | integer | Pixel width.
        /// @param | h | integer | Pixel height.
        methods.add_method_mut("setTileSize", |_, this, (w, h): (u32, u32)| {
            this.inner.borrow_mut().set_tile_size(w, h);
            Ok(())
        });

        /// Add a named block group definition to this map generator.
        /// @param | group | MapGroup | Group of blocks.
        methods.add_method_mut("addGroup", |_, this, group: LuaAnyUserData| {
            let lua_group = group.borrow::<LuaMapGroup>()?;
            this.inner.borrow_mut().add_group(lua_group.inner.borrow().clone());
            Ok(())
        });

        /// Generate map using a script for this object.
        /// @param | script | MapScript | Script to execute.
        /// @return | MapBlockResult | Generation result.
        methods.add_method_mut("generate", |_, this, script: LuaAnyUserData| {
            let lua_script = script.borrow::<LuaMapScript>()?;
            let result = this.inner.borrow_mut().generate(&lua_script.inner.borrow());
            Ok(LuaMapBlockResult {
                inner: Rc::new(result),
            })
        });

        /// Get last placement count for this object.
        /// @return | integer | Blocks placed in last generation.
        methods.add_method("getLastPlacedCount", |_, this, ()| {
            Ok(this.inner.borrow().last_placed_count())
        });
    }
}

impl LuaUserData for LuaMapBlockResult {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Get total width in tiles for this object.
        /// @return | integer | Width.
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.width));

        /// Get total height in tiles — Lua userdata object exposed by the engine.
        /// @return | integer | Height.
        methods.add_method("getHeight", |_, this, ()| Ok(this.inner.height));

        /// Get number of levels for this object.
        /// @return | integer | Level count.
        methods.add_method("getLevelCount", |_, this, ()| Ok(this.inner.level_count));

        /// Get number of layers for this object.
        /// @return | integer | Layer count.
        methods.add_method("getLayerCount", |_, this, ()| Ok(this.inner.layer_count));

        /// Get tile GID at position for this object.
        /// @param | level | integer | Level index.
        /// @param | layer | integer | Layer index.
        /// @param | x | integer | Tile X.
        /// @param | y | integer | Tile Y.
        /// @param | slot | integer | Slot index.
        /// @return | integer | GID value.
        methods.add_method("getGid", |_, this, (level, layer, x, y, slot): (u32, u32, u32, u32, usize)| {
            Ok(this.inner.get_gid(level, layer, x, y, slot))
        });

        /// Get number of blocks placed for this object.
        /// @return | integer | Blocks placed.
        methods.add_method("getBlocksPlaced", |_, this, ()| Ok(this.inner.blocks_placed));

        /// Check if result is empty for this object.
        /// @return | boolean | True if no blocks placed.
        methods.add_method("isEmpty", |_, this, ()| Ok(this.inner.is_empty()));
    }
}

impl LuaUserData for LuaTilesetRef {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        /// Get the numeric tileset ID for this tileset reference.
        /// @return | integer | Tileset ID.
        methods.add_method("getId", |_, this, ()| Ok(this.inner.borrow().id()));

        /// Get tileset name — Lua userdata object exposed by the engine.
        /// @return | string | Tileset name.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.inner.borrow().name().to_string())
        });

        /// Set the image file path for this tileset reference.
        /// @param | path | string | Image file path.
        methods.add_method_mut("setImagePath", |_, this, path: String| {
            this.inner.borrow_mut().set_image_path(&path);
            Ok(())
        });
    }
}

// ─── Module registration ────────────────────────────────────────────────────

/// Register the `lurek.mapblock` module.
pub fn register<'lua>(lua: &'lua Lua, _state: &SharedState) -> LuaResult<LuaTable<'lua>> {
    let module = lua.create_table()?;

    // ─── Constructors ───────────────────────────────────────────────────────

    /// Create a new map block configuration with default slots.
    /// @return | MapBlockConfig | New configuration.
    module.set(
        "newConfig",
        lua.create_function(|_, ()| {
            Ok(LuaMapBlockConfig {
                inner: Rc::new(RefCell::new(MapBlockConfig::new())),
            })
        })?,
    )?;

    /// Create an empty config with no predefined slots.
    /// @return | MapBlockConfig | Empty configuration.
    module.set(
        "newEmptyConfig",
        lua.create_function(|_, ()| {
            Ok(LuaMapBlockConfig {
                inner: Rc::new(RefCell::new(MapBlockConfig::empty())),
            })
        })?,
    )?;

    /// Create a new map block exposed by the lurek engine.
    /// @param | width | integer | Block width in tiles.
    /// @param | height | integer | Block height in tiles.
    /// @param | layers | integer | Number of layers.
    /// @param | config | MapBlockConfig | Configuration to use.
    /// @return | MapBlock | New block.
    module.set(
        "newBlock",
        lua.create_function(|_, (w, h, layers, config): (u32, u32, u32, LuaAnyUserData)| {
            let lua_config = config.borrow::<LuaMapBlockConfig>()?;
            let block = MapBlock::new(w, h, layers, &lua_config.inner.borrow());
            Ok(LuaMapBlock {
                inner: Rc::new(RefCell::new(block)),
            })
        })?,
    )?;

    /// Create a new map group exposed by the lurek engine.
    /// @param | name | string | Group name.
    /// @return | MapGroup | New group.
    module.set(
        "newGroup",
        lua.create_function(|_, name: String| {
            Ok(LuaMapGroup {
                inner: Rc::new(RefCell::new(MapGroup::new(&name))),
            })
        })?,
    )?;

    /// Create a new map script exposed by the lurek engine.
    /// @param | name | string | Script name.
    /// @return | MapScript | New script.
    module.set(
        "newScript",
        lua.create_function(|_, name: Option<String>| {
            Ok(LuaMapScript {
                inner: Rc::new(RefCell::new(MapScript::new(
                    name.as_deref().unwrap_or("default"),
                ))),
            })
        })?,
    )?;

    /// Create new neighbor rules exposed by the lurek engine.
    /// @return | NeighborRules | New rules.
    module.set(
        "newRules",
        lua.create_function(|_, ()| {
            Ok(LuaNeighborRules {
                inner: Rc::new(RefCell::new(NeighborRules::new())),
            })
        })?,
    )?;

    /// Create a rectangular placement grid.
    /// @param | width | integer | Grid width.
    /// @param | height | integer | Grid height.
    /// @return | PlacementGrid | New grid.
    module.set(
        "newGrid",
        lua.create_function(|_, (w, h): (u32, u32)| {
            Ok(LuaPlacementGrid {
                inner: Rc::new(RefCell::new(PlacementGrid::new_rect(w, h))),
            })
        })?,
    )?;

    /// Create an empty placement grid (for arbitrary shapes).
    /// @return | PlacementGrid | Empty grid.
    module.set(
        "newEmptyGrid",
        lua.create_function(|_, ()| {
            Ok(LuaPlacementGrid {
                inner: Rc::new(RefCell::new(PlacementGrid::new())),
            })
        })?,
    )?;

    /// Create a new procedural map block generator instance.
    /// @param | config | MapBlockConfig | Configuration.
    /// @return | MapBlockGenerator | New generator.
    module.set(
        "newGenerator",
        lua.create_function(|_, config: LuaAnyUserData| {
            let lua_config = config.borrow::<LuaMapBlockConfig>()?;
            let gen = MapBlockGenerator::new(lua_config.inner.borrow().clone());
            Ok(LuaMapBlockGenerator {
                inner: Rc::new(RefCell::new(gen)),
            })
        })?,
    )?;

    /// Create a tileset reference exposed by the lurek engine.
    /// @param | id | integer | Tileset ID.
    /// @param | name | string | Tileset name.
    /// @param | tile_count | integer | Number of tiles.
    /// @param | columns | integer | Columns in tileset image.
    /// @param | tile_width | integer | Tile pixel width.
    /// @param | tile_height | integer | Tile pixel height.
    /// @return | TilesetRef | New tileset reference.
    module.set(
        "newTilesetRef",
        lua.create_function(
            |_, (id, name, tile_count, columns, tile_width, tile_height): (u32, String, u32, u32, u32, u32)| {
                Ok(LuaTilesetRef {
                    inner: Rc::new(RefCell::new(TilesetRef::new(
                        id, &name, tile_count, columns, tile_width, tile_height,
                    ))),
                })
            },
        )?,
    )?;

    Ok(module)
}
