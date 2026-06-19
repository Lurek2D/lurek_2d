//! This file owns procgen-local validation and resource-limit errors shared by generators in this module group.
//! It keeps failure reasons typed so safe `try_*` constructors can reject invalid dimensions, options, bytes, and WFC rules consistently.
//! Open it when procgen callers need clearer diagnostics or when a new generator starts participating in the shared safety contract.

use std::fmt;

/// Error returned by procgen safe constructors and validators.
#[derive(Debug, Clone, PartialEq)]
pub enum ProcgenError {
    /// Width or height was zero for an API that requires a non-empty grid.
    InvalidDimensions { width: u32, height: u32 },
    /// Width × height overflowed before a grid cell count could be computed.
    CellCountOverflow { width: u32, height: u32 },
    /// Width × height exceeded the configured cell limit.
    CellCountLimitExceeded {
        width: u32,
        height: u32,
        cells: u64,
        max_cells: u64,
    },
    /// Width × height × bytes-per-cell overflowed before an output size could be computed.
    ByteCountOverflow {
        width: u32,
        height: u32,
        bytes_per_cell: u64,
        context: &'static str,
    },
    /// Computed output size exceeded the configured byte limit.
    ByteCountLimitExceeded {
        context: &'static str,
        bytes: u64,
        max_bytes: u64,
    },
    /// Floating-point input was NaN or infinite.
    InvalidFloat { field: &'static str, value: f64 },
    /// Floating-point input was outside an inclusive range.
    ValueOutOfRange {
        field: &'static str,
        min: f64,
        max: f64,
        value: f64,
    },
    /// Floating-point input had to be strictly positive but was zero or negative.
    NonPositiveValue { field: &'static str, value: f64 },
    /// Requested octave count exceeded the configured limit.
    MaxOctavesExceeded { requested: u32, max: u32 },
    /// Requested iteration count exceeded the configured limit.
    MaxIterationsExceeded { requested: u32, max: u32 },
    /// Requested WFC attempts exceeded the configured limit.
    MaxAttemptsExceeded { requested: u32, max: u32 },
    /// A count-based input exceeded a configured parser or collection limit.
    CountLimitExceeded {
        context: &'static str,
        count: usize,
        max: usize,
    },
    /// Raw input exceeded the configured byte budget before parsing could continue.
    OversizedInput {
        context: &'static str,
        bytes: usize,
        max_bytes: usize,
    },
    /// Input length did not match the exact byte or cell count required by the API.
    InvalidLength {
        context: &'static str,
        expected: usize,
        actual: usize,
    },
    /// Structured input violated a required schema field or value contract.
    InvalidSchema {
        context: &'static str,
        detail: String,
    },
    /// Serialized data declared a version this runtime does not understand.
    UnsupportedVersion { context: &'static str, version: u32 },
    /// Tile identifiers must be unique within a WFC tile set.
    DuplicateTileId { tile_id: u32 },
    /// Tile weights must be finite and strictly positive.
    InvalidTileWeight { tile_id: u32, weight: f32 },
    /// A WFC adjacency list referenced a tile ID that is not present in the tile set.
    UnknownAdjacencyTileId { owner_id: u32, tile_id: u32 },
    /// Safe WFC generation rejected an empty tile set.
    EmptyTileSet,
    /// WFC exhausted its attempts after repeated contradictions.
    WfcContradiction {
        attempts: u32,
        collapsed_count: usize,
    },
}

impl fmt::Display for ProcgenError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidDimensions { width, height } => {
                write!(
                    f,
                    "procgen dimensions must be non-zero, got {}x{}",
                    width, height
                )
            }
            Self::CellCountOverflow { width, height } => {
                write!(
                    f,
                    "procgen dimensions {}x{} overflow cell count",
                    width, height
                )
            }
            Self::CellCountLimitExceeded {
                width,
                height,
                cells,
                max_cells,
            } => write!(
                f,
                "procgen dimensions {}x{} require {} cells, exceeding limit {}",
                width, height, cells, max_cells
            ),
            Self::ByteCountOverflow {
                width,
                height,
                bytes_per_cell,
                context,
            } => write!(
                f,
                "{} dimensions {}x{} overflow {}-byte-per-cell output size",
                context, width, height, bytes_per_cell
            ),
            Self::ByteCountLimitExceeded {
                context,
                bytes,
                max_bytes,
            } => write!(
                f,
                "{} output requires {} bytes, exceeding limit {}",
                context, bytes, max_bytes
            ),
            Self::InvalidFloat { field, value } => {
                write!(f, "procgen field '{}' must be finite, got {}", field, value)
            }
            Self::ValueOutOfRange {
                field,
                min,
                max,
                value,
            } => write!(
                f,
                "procgen field '{}' must be in [{}, {}], got {}",
                field, min, max, value
            ),
            Self::NonPositiveValue { field, value } => {
                write!(f, "procgen field '{}' must be > 0, got {}", field, value)
            }
            Self::MaxOctavesExceeded { requested, max } => write!(
                f,
                "procgen requested {} octaves, exceeding configured limit {}",
                requested, max
            ),
            Self::MaxIterationsExceeded { requested, max } => write!(
                f,
                "procgen requested {} iterations, exceeding configured limit {}",
                requested, max
            ),
            Self::MaxAttemptsExceeded { requested, max } => write!(
                f,
                "procgen requested {} WFC attempts, exceeding configured limit {}",
                requested, max
            ),
            Self::CountLimitExceeded {
                context,
                count,
                max,
            } => write!(
                f,
                "{} count {} exceeds configured limit {}",
                context, count, max
            ),
            Self::OversizedInput {
                context,
                bytes,
                max_bytes,
            } => write!(
                f,
                "{} input uses {} bytes, exceeding configured limit {}",
                context, bytes, max_bytes
            ),
            Self::InvalidLength {
                context,
                expected,
                actual,
            } => write!(
                f,
                "{} length mismatch: expected {}, got {}",
                context, expected, actual
            ),
            Self::InvalidSchema { context, detail } => {
                write!(f, "{} schema is invalid: {}", context, detail)
            }
            Self::UnsupportedVersion { context, version } => {
                write!(f, "{} uses unsupported version {}", context, version)
            }
            Self::DuplicateTileId { tile_id } => {
                write!(f, "WFC tile set contains duplicate tile id {}", tile_id)
            }
            Self::InvalidTileWeight { tile_id, weight } => write!(
                f,
                "WFC tile {} has invalid weight {}; weights must be finite and > 0",
                tile_id, weight
            ),
            Self::UnknownAdjacencyTileId { owner_id, tile_id } => write!(
                f,
                "WFC adjacency for tile {} references unknown tile {}",
                owner_id, tile_id
            ),
            Self::EmptyTileSet => write!(f, "WFC requires at least one tile"),
            Self::WfcContradiction {
                attempts,
                collapsed_count,
            } => write!(
                f,
                "WFC exhausted {} attempt(s) after contradiction with {} collapsed cell(s)",
                attempts, collapsed_count
            ),
        }
    }
}

impl std::error::Error for ProcgenError {}
