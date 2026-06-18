//! `src/i18n/mod.rs` is the module index that exposes catalog lookup, formatting, interpolation, and plural rules.
//! It reexports catalog types, locale helpers, formatting, interpolation helpers, and plural logic in one surface.
//! No loaded translation tables live here; this file only declares child modules and defines which i18n symbols are public.
//! Read this index when wiring localization, because it shows where translation storage ends and text helpers begin.
//! Changes here reshape the i18n boundary, since reexports decide what runtime code may import without deep module paths.
//! This module keeps lookup state, output formatting, template expansion, and plural selection separated by responsibility.

/// Locale catalog storage and flattening helpers.
pub mod catalog;
/// Locale-aware date and number formatting helpers.
pub mod format;
/// Template interpolation for localized strings.
pub mod interpolation;
/// Plural-form selection and pluralization helpers.
pub mod plural;
/// Locale detection, validation, catalog types, and flat-table helpers.
pub use catalog::{
    detect_system_locale, flat_table_from_json, flat_table_from_toml, is_rtl, is_valid_locale_code,
    Catalog, CatalogError, CoverageGap,
};
/// Date and number formatting helpers.
pub use format::{days_to_ymd, format_date, format_number, locale_separators};
/// Template interpolation helpers.
pub use interpolation::{interpolate, interpolate_pairs};
/// Plural-form helpers and enum type.
pub use plural::{pluralize, pluralize_slavic, PluralForm};
