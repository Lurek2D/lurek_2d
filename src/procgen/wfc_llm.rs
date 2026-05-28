//! LLM-assisted WFC constraint generation.
//!
//! Sends structured prompts to the global LLM endpoint and parses
//! the JSON response into WFC tile sets and adjacency rules.

use crate::procgen::{WfcOpts, WfcRules, WfcTile};
use std::collections::HashMap;

/// Parse a `serde_json::Value` LLM response into [`WfcOpts`].
///
/// Expected JSON format:
/// `{"tiles":[{"id":0,"weight":1.0},...], "adjacencies":{"0":[1,2,3],...}}`
///
/// Returns `None` if the tile list is absent or empty.
pub fn parse_llm_wfc_response(
    val: &serde_json::Value,
    width: u32,
    height: u32,
    seed: u64,
    max_attempts: u32,
) -> Option<WfcOpts> {
    let tiles_arr = val.get("tiles")?.as_array()?;
    let mut tiles: Vec<WfcTile> = Vec::new();
    for t in tiles_arr {
        let id = t.get("id")?.as_u64()? as u32;
        let weight = t.get("weight").and_then(|v| v.as_f64()).unwrap_or(1.0) as f32;
        tiles.push(WfcTile { id, weight });
    }
    if tiles.is_empty() {
        return None;
    }

    let adjacencies = parse_adjacency_object(val.get("adjacencies"));

    Some(WfcOpts {
        width,
        height,
        tiles,
        rules: WfcRules { adjacencies },
        seed,
        max_attempts,
    })
}

/// Parse only the adjacency rules from an LLM response.
///
/// Expected JSON: `{"adjacencies":{"0":[1,2],...}}`
///
/// Returns an empty map when the field is absent or malformed.
pub fn parse_llm_constraints(val: &serde_json::Value) -> HashMap<u32, Vec<u32>> {
    parse_adjacency_object(val.get("adjacencies"))
}

fn parse_adjacency_object(obj_val: Option<&serde_json::Value>) -> HashMap<u32, Vec<u32>> {
    let mut out = HashMap::new();
    let Some(obj) = obj_val.and_then(|v| v.as_object()) else {
        return out;
    };
    for (k, v) in obj {
        let Ok(id) = k.parse::<u32>() else { continue };
        let Some(arr) = v.as_array() else { continue };
        let neighbors: Vec<u32> = arr
            .iter()
            .filter_map(|n| n.as_u64().map(|x| x as u32))
            .collect();
        out.insert(id, neighbors);
    }
    out
}
