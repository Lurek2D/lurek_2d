//! Legacy province-graph map helpers used by older strategy prototypes.
//! Owns a lightweight province graph separate from the newer `province` runtime.
//! Keeps the older data model available as an exported module for compatibility.

/// Province-graph types used by the legacy `map` compatibility surface.
pub mod province;

pub use province::{Province, ProvinceMap};
