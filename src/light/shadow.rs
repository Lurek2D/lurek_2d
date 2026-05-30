//! Defines shadow filtering quality presets used by soft-shadow evaluation paths.
//! Encodes hard-shadow and PCF-based options with different sampling costs.
//! Provides a compact quality enum consumed by light shadow configuration.

/// Shadow filter quality preset controlling the soft-shadow sample kernel.
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
