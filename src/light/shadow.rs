//! This file owns `ShadowFilter`, the preset enum that selects soft-shadow kernel quality for light rendering paths.
//! It distinguishes no filtering, five-tap PCF, and thirteen-tap PCF so shadow softness cost stays explicit in data.
//! Open this file when shadow-filter semantics change; per-light state and occluder ownership live in sibling files.

/// Shadow filter quality preset controlling the soft-shadow sample kernel.
/// # Variants
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum ShadowFilter {
    /// Hard shadows with no filtering; fastest (default).
    #[default]
    None,
    /// 5-tap Percentage Closer Filtering; soft edges with low sample count.
    Pcf5,
    /// 13-tap Percentage Closer Filtering; smoother soft edges at higher cost.
    Pcf13,
}
