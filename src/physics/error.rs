//! Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around PhysicsError, fmt, with helpers kept close to their invariants.
//! Defines how error data is validated, transformed, or stored before neighboring systems use it.
//! Owns physics behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on error behavior while Lua registration stays elsewhere.
//! Documents the boundary where physics code accepts inputs, reports errors, or updates state.

use std::fmt;

/// Error returned by safe physics constructors, bounded helpers, and strict mutators.
#[derive(Debug, Clone, PartialEq)]
pub enum PhysicsError {
    /// A Lua or API body id was negative or otherwise invalid for the stable slot model.
    InvalidBodyIdValue { value: i64 },
    /// A floating-point input was NaN or infinite.
    InvalidFloat { field: &'static str, value: f64 },
    /// A floating-point input had to be strictly positive but was zero or negative.
    NonPositiveValue { field: &'static str, value: f64 },
    /// A floating-point input was outside an inclusive range.
    ValueOutOfRange {
        field: &'static str,
        min: f64,
        max: f64,
        value: f64,
    },
    /// A flat coordinate list had an odd number of entries.
    OddCoordinateCount { context: &'static str, count: usize },
    /// A count-based input exceeded a configured ceiling.
    CountLimitExceeded {
        context: &'static str,
        count: usize,
        max: usize,
    },
    /// A vertex list violated the minimum or maximum count contract.
    InvalidVertexCount {
        context: &'static str,
        count: usize,
        min: usize,
        max: usize,
    },
    /// Geometry failed a shape-specific structural rule.
    DegenerateGeometry {
        context: &'static str,
        detail: &'static str,
    },
    /// A string mode did not match the accepted set for a physics option.
    InvalidMode {
        context: &'static str,
        value: String,
        expected: &'static str,
    },
    /// A referenced body id does not point to an active body.
    InvalidBodyReference { body_id: usize },
    /// A referenced fixture index does not exist on the body.
    InvalidFixtureReference {
        body_id: usize,
        fixture_index: usize,
    },
    /// A referenced joint id does not point to an active joint.
    InvalidJointReference { joint_id: usize },
    /// A referenced zone id does not point to an active zone.
    InvalidZoneReference { zone_id: usize },
    /// A referenced additive gravity vector id does not point to an active vector.
    InvalidGravityVectorReference { vector_id: usize },
    /// The requested physics step dt was NaN, infinite, zero, or negative.
    InvalidStepDt { value: f32 },
    /// Terrain dimensions overflowed before a cell count could be computed.
    TerrainCellOverflow { width: u32, height: u32 },
    /// Terrain dimensions were zero for an API that requires a non-empty grid.
    InvalidTerrainDimensions { width: u32, height: u32 },
    /// Terrain dimensions exceeded the configured cell ceiling.
    TerrainCellLimitExceeded {
        width: u32,
        height: u32,
        cells: u64,
        max_cells: u64,
    },
    /// Terrain image export overflowed before a byte count could be computed.
    TerrainImageByteOverflow { width: u32, height: u32 },
    /// Terrain image export exceeded the configured output byte ceiling.
    TerrainImageByteLimitExceeded { bytes: u64, max_bytes: u64 },
    /// The byte input length did not match the exact size required by the format.
    InvalidLength {
        context: &'static str,
        expected: usize,
        actual: usize,
    },
    /// The serialized payload declared a version this runtime does not understand.
    UnsupportedVersion { context: &'static str, version: u32 },
}

impl fmt::Display for PhysicsError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidBodyIdValue { value } => {
                write!(
                    f,
                    "physics body id must be a non-negative integer, got {}",
                    value
                )
            }
            Self::InvalidFloat { field, value } => {
                write!(f, "physics field '{}' must be finite, got {}", field, value)
            }
            Self::NonPositiveValue { field, value } => {
                write!(f, "physics field '{}' must be > 0, got {}", field, value)
            }
            Self::ValueOutOfRange {
                field,
                min,
                max,
                value,
            } => write!(
                f,
                "physics field '{}' must be in [{}, {}], got {}",
                field, min, max, value
            ),
            Self::OddCoordinateCount { context, count } => write!(
                f,
                "{} requires complete x,y coordinate pairs, got {} value(s)",
                context, count
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
            Self::InvalidVertexCount {
                context,
                count,
                min,
                max,
            } => write!(
                f,
                "{} requires {}..={} vertices, got {}",
                context, min, max, count
            ),
            Self::DegenerateGeometry { context, detail } => {
                write!(f, "{} geometry is invalid: {}", context, detail)
            }
            Self::InvalidMode {
                context,
                value,
                expected,
            } => write!(
                f,
                "{} mode '{}' is invalid; expected {}",
                context, value, expected
            ),
            Self::InvalidBodyReference { body_id } => {
                write!(f, "physics body id {} is not active", body_id)
            }
            Self::InvalidFixtureReference {
                body_id,
                fixture_index,
            } => write!(
                f,
                "physics fixture {} does not exist on body {}",
                fixture_index, body_id
            ),
            Self::InvalidJointReference { joint_id } => {
                write!(f, "physics joint id {} is not active", joint_id)
            }
            Self::InvalidZoneReference { zone_id } => {
                write!(f, "physics zone id {} is not active", zone_id)
            }
            Self::InvalidGravityVectorReference { vector_id } => {
                write!(f, "physics gravity vector id {} is not active", vector_id)
            }
            Self::InvalidStepDt { value } => {
                write!(f, "physics step dt must be finite and > 0, got {}", value)
            }
            Self::TerrainCellOverflow { width, height } => write!(
                f,
                "physics terrain dimensions {}x{} overflow cell count",
                width, height
            ),
            Self::InvalidTerrainDimensions { width, height } => write!(
                f,
                "physics terrain dimensions must be non-zero, got {}x{}",
                width, height
            ),
            Self::TerrainCellLimitExceeded {
                width,
                height,
                cells,
                max_cells,
            } => write!(
                f,
                "physics terrain {}x{} requires {} cells, exceeding limit {}",
                width, height, cells, max_cells
            ),
            Self::TerrainImageByteOverflow { width, height } => write!(
                f,
                "physics terrain {}x{} overflows RGBA export byte count",
                width, height
            ),
            Self::TerrainImageByteLimitExceeded { bytes, max_bytes } => write!(
                f,
                "physics terrain image requires {} bytes, exceeding limit {}",
                bytes, max_bytes
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
            Self::UnsupportedVersion { context, version } => {
                write!(f, "{} uses unsupported version {}", context, version)
            }
        }
    }
}

impl std::error::Error for PhysicsError {}
