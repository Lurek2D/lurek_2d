//! This file owns the JSON parsing bridge from LLM-produced tile specs into concrete WFC options and constraints.
//! It converts response objects into `WfcTile`, `WfcRules`, and `WfcOpts` so generation stays deterministic.
//! Strict schema and parser limits remain local because malformed or oversized LLM output must stop at one boundary.
//! Open it when AI-assisted tiling input changes; the actual collapse algorithm lives in `wfc.rs`.

use crate::procgen::{
    limits::{validate_count, validate_non_zero_dimensions},
    ProcgenError, ProcgenLimits, WfcOpts, WfcRules, WfcTile,
};
use std::collections::HashMap;

fn json_size_bytes(val: &serde_json::Value) -> usize {
    serde_json::to_vec(val)
        .map(|bytes| bytes.len())
        .unwrap_or(0)
}

/// Strictly parse a `serde_json::Value` LLM response into [`WfcOpts`].
pub fn try_parse_llm_wfc_response(
    val: &serde_json::Value,
    width: u32,
    height: u32,
    seed: u64,
    max_attempts: u32,
    limits: &ProcgenLimits,
) -> Result<WfcOpts, ProcgenError> {
    validate_non_zero_dimensions(width, height)?;
    let byte_len = json_size_bytes(val);
    if byte_len > limits.max_parser_input_bytes {
        return Err(ProcgenError::OversizedInput {
            context: "wfc_llm response",
            bytes: byte_len,
            max_bytes: limits.max_parser_input_bytes,
        });
    }

    let root = val.as_object().ok_or_else(|| ProcgenError::InvalidSchema {
        context: "wfc_llm response",
        detail: "root must be a JSON object".to_string(),
    })?;
    let tiles_val = root
        .get("tiles")
        .ok_or_else(|| ProcgenError::InvalidSchema {
            context: "wfc_llm response",
            detail: "missing 'tiles' array".to_string(),
        })?;
    let tiles_arr = tiles_val
        .as_array()
        .ok_or_else(|| ProcgenError::InvalidSchema {
            context: "wfc_llm response",
            detail: "'tiles' must be an array".to_string(),
        })?;
    validate_count("wfc_llm tiles", tiles_arr.len(), limits.max_wfc_tiles)?;

    let mut tiles = Vec::with_capacity(tiles_arr.len());
    for (index, tile_val) in tiles_arr.iter().enumerate() {
        let tile_obj = tile_val
            .as_object()
            .ok_or_else(|| ProcgenError::InvalidSchema {
                context: "wfc_llm tile",
                detail: format!("tile at index {index} must be an object"),
            })?;
        let id = tile_obj
            .get("id")
            .and_then(|value| value.as_u64())
            .ok_or_else(|| ProcgenError::InvalidSchema {
                context: "wfc_llm tile",
                detail: format!("tile at index {index} is missing integer 'id'"),
            })?;
        let weight = tile_obj
            .get("weight")
            .and_then(|value| value.as_f64())
            .ok_or_else(|| ProcgenError::InvalidSchema {
                context: "wfc_llm tile",
                detail: format!("tile {id} is missing numeric 'weight'"),
            })?;
        tiles.push(WfcTile {
            id: u32::try_from(id).map_err(|_| ProcgenError::InvalidSchema {
                context: "wfc_llm tile",
                detail: format!("tile id {id} does not fit into u32"),
            })?,
            weight: weight as f32,
        });
    }

    let adjacencies = try_parse_llm_constraints(val, limits)?;

    Ok(WfcOpts {
        width,
        height,
        tiles,
        rules: WfcRules { adjacencies },
        seed,
        max_attempts,
    })
}

/// Parse a `serde_json::Value` LLM response into [`WfcOpts`], returning `None` on strict-parse failure.
pub fn parse_llm_wfc_response(
    val: &serde_json::Value,
    width: u32,
    height: u32,
    seed: u64,
    max_attempts: u32,
) -> Option<WfcOpts> {
    try_parse_llm_wfc_response(
        val,
        width,
        height,
        seed,
        max_attempts,
        &ProcgenLimits::default(),
    )
    .ok()
}

/// Strictly parse only the adjacency rules from an LLM response.
pub fn try_parse_llm_constraints(
    val: &serde_json::Value,
    limits: &ProcgenLimits,
) -> Result<HashMap<u32, Vec<u32>>, ProcgenError> {
    let byte_len = json_size_bytes(val);
    if byte_len > limits.max_parser_input_bytes {
        return Err(ProcgenError::OversizedInput {
            context: "wfc_llm adjacencies",
            bytes: byte_len,
            max_bytes: limits.max_parser_input_bytes,
        });
    }
    let root = val.as_object().ok_or_else(|| ProcgenError::InvalidSchema {
        context: "wfc_llm adjacencies",
        detail: "root must be a JSON object".to_string(),
    })?;
    let adj_val = root
        .get("adjacencies")
        .ok_or_else(|| ProcgenError::InvalidSchema {
            context: "wfc_llm adjacencies",
            detail: "missing 'adjacencies' object".to_string(),
        })?;
    let obj = adj_val
        .as_object()
        .ok_or_else(|| ProcgenError::InvalidSchema {
            context: "wfc_llm adjacencies",
            detail: "'adjacencies' must be an object".to_string(),
        })?;

    let mut out = HashMap::with_capacity(obj.len());
    let mut total_refs = 0usize;
    for (owner, value) in obj {
        let owner_id = owner
            .parse::<u32>()
            .map_err(|_| ProcgenError::InvalidSchema {
                context: "wfc_llm adjacency key",
                detail: format!("adjacency key '{owner}' is not a u32 tile id"),
            })?;
        let arr = value
            .as_array()
            .ok_or_else(|| ProcgenError::InvalidSchema {
                context: "wfc_llm adjacency value",
                detail: format!("adjacency list for tile {owner_id} must be an array"),
            })?;
        total_refs = total_refs.saturating_add(arr.len());
        validate_count(
            "wfc_llm adjacency refs",
            total_refs,
            limits.max_wfc_adjacency_refs,
        )?;
        let mut neighbors = Vec::with_capacity(arr.len());
        for entry in arr {
            let tile_id = entry.as_u64().ok_or_else(|| ProcgenError::InvalidSchema {
                context: "wfc_llm adjacency entry",
                detail: format!("adjacency entry for tile {owner_id} must be an integer"),
            })?;
            neighbors.push(
                u32::try_from(tile_id).map_err(|_| ProcgenError::InvalidSchema {
                    context: "wfc_llm adjacency entry",
                    detail: format!("adjacency tile id {tile_id} does not fit into u32"),
                })?,
            );
        }
        out.insert(owner_id, neighbors);
    }
    Ok(out)
}

/// Parse only the adjacency rules from an LLM response, returning an empty map on strict-parse failure.
pub fn parse_llm_constraints(val: &serde_json::Value) -> HashMap<u32, Vec<u32>> {
    try_parse_llm_constraints(val, &ProcgenLimits::default()).unwrap_or_default()
}
