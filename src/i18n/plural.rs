//! CLDR-inspired plural form selection.
//!
//! Provides [`PluralForm`] and [`pluralize`] to select the correct grammatical
//! form of a word or phrase based on a count value.  Supports the six CLDR
//! plural categories: `zero`, `one`, `two`, `few`, `many`, and `other`.

// ── PluralForm ────────────────────────────────────────────────────────────

/// CLDR plural category.
///
/// # Variants
/// - `Zero` — Exactly zero (some locales treat it specially).
/// - `One` — Singular.
/// - `Two` — Dual form (e.g. Arabic, Latvian).
/// - `Few` — Small number of items (Slavic languages).
/// - `Many` — Larger numbers with special grammar (Polish, Russian).
/// - `Other` — The default catch-all plural.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum PluralForm {
    Zero,
    One,
    Two,
    Few,
    Many,
    Other,
}

impl PluralForm {
    /// Returns the canonical lowercase key string for this category.
    ///
    /// # Returns
    /// `&'static str`.
    pub fn key(&self) -> &'static str {
        match self {
            Self::Zero  => "zero",
            Self::One   => "one",
            Self::Two   => "two",
            Self::Few   => "few",
            Self::Many  => "many",
            Self::Other => "other",
        }
    }

    /// Returns the `PluralForm` for an English-style (one/other) count.
    ///
    /// # Parameters
    /// - `n` — `f64`.
    ///
    /// # Returns
    /// `PluralForm`.
    pub fn english(n: f64) -> Self {
        if n == 1.0 { Self::One } else { Self::Other }
    }

    /// Returns the `PluralForm` for a Slavic-style (one/few/many/other) count
    /// (closest to Russian/Polish).
    ///
    /// # Parameters
    /// - `n` — `u64`.
    ///
    /// # Returns
    /// `PluralForm`.
    pub fn slavic(n: u64) -> Self {
        let abs = n % 100;
        if (11..=19).contains(&abs) {
            return Self::Many;
        }
        match n % 10 {
            1 => Self::One,
            2..=4 => Self::Few,
            _ => Self::Many,
        }
    }

    /// Parses a form key string to a `PluralForm`.
    ///
    /// # Parameters
    /// - `s` — `&str`.
    ///
    /// # Returns
    /// `Option<PluralForm>`.
    pub fn from_key(s: &str) -> Option<Self> {
        match s {
            "zero"  => Some(Self::Zero),
            "one"   => Some(Self::One),
            "two"   => Some(Self::Two),
            "few"   => Some(Self::Few),
            "many"  => Some(Self::Many),
            "other" => Some(Self::Other),
            _ => None,
        }
    }
}

// ── pluralize ─────────────────────────────────────────────────────────────

/// Selects the correct plural string from a form map for the given count.
///
/// The `forms` map may contain any subset of `"zero"`, `"one"`, `"two"`,
/// `"few"`, `"many"`, `"other"` keys.  Resolution order:
/// 1. Exact form key for the count (using [`PluralForm::english`]).
/// 2. `"other"` fallback.
/// 3. First available key.
///
/// # Parameters
/// - `n` — `f64`.
/// - `forms` — `&std::collections::HashMap<String, String>`.
///
/// # Returns
/// `String`.
pub fn pluralize(n: f64, forms: &std::collections::HashMap<String, String>) -> String {
    let form = PluralForm::english(n);
    if let Some(v) = forms.get(form.key()) {
        return v.clone();
    }
    if let Some(v) = forms.get("other") {
        return v.clone();
    }
    forms.values().next().cloned().unwrap_or_default()
}

/// Like [`pluralize`] but accepts integer counts and uses Slavic rules.
///
/// # Parameters
/// - `n` — `u64`.
/// - `forms` — `&std::collections::HashMap<String, String>`.
///
/// # Returns
/// `String`.
pub fn pluralize_slavic(n: u64, forms: &std::collections::HashMap<String, String>) -> String {
    let form = PluralForm::slavic(n);
    if let Some(v) = forms.get(form.key()) {
        return v.clone();
    }
    pluralize(n as f64, forms)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    #[test]
    fn plural_form_key_round_trip() {
        let forms = [
            PluralForm::Zero,
            PluralForm::One,
            PluralForm::Two,
            PluralForm::Few,
            PluralForm::Many,
            PluralForm::Other,
        ];
        let expected = ["zero", "one", "two", "few", "many", "other"];
        for (form, key) in forms.iter().zip(expected.iter()) {
            assert_eq!(form.key(), *key);
            assert_eq!(PluralForm::from_key(key), Some(form.clone()));
        }
    }

    #[test]
    fn from_key_unknown_returns_none() {
        assert!(PluralForm::from_key("bogus").is_none());
        assert!(PluralForm::from_key("").is_none());
    }

    #[test]
    fn english_singular_and_plural() {
        assert_eq!(PluralForm::english(1.0), PluralForm::One);
        assert_eq!(PluralForm::english(0.0), PluralForm::Other);
        assert_eq!(PluralForm::english(2.0), PluralForm::Other);
        assert_eq!(PluralForm::english(-1.0), PluralForm::Other);
        assert_eq!(PluralForm::english(0.5), PluralForm::Other);
    }

    #[test]
    fn slavic_one() {
        assert_eq!(PluralForm::slavic(1), PluralForm::One);
        assert_eq!(PluralForm::slavic(21), PluralForm::One);
        assert_eq!(PluralForm::slavic(101), PluralForm::One);
    }

    #[test]
    fn slavic_few() {
        assert_eq!(PluralForm::slavic(2), PluralForm::Few);
        assert_eq!(PluralForm::slavic(3), PluralForm::Few);
        assert_eq!(PluralForm::slavic(4), PluralForm::Few);
        assert_eq!(PluralForm::slavic(22), PluralForm::Few);
        assert_eq!(PluralForm::slavic(34), PluralForm::Few);
    }

    #[test]
    fn slavic_many() {
        assert_eq!(PluralForm::slavic(0), PluralForm::Many);
        assert_eq!(PluralForm::slavic(5), PluralForm::Many);
        assert_eq!(PluralForm::slavic(11), PluralForm::Many);
        assert_eq!(PluralForm::slavic(12), PluralForm::Many);
        assert_eq!(PluralForm::slavic(14), PluralForm::Many);
        assert_eq!(PluralForm::slavic(19), PluralForm::Many);
        assert_eq!(PluralForm::slavic(100), PluralForm::Many);
        assert_eq!(PluralForm::slavic(111), PluralForm::Many);
    }

    #[test]
    fn pluralize_selects_correct_form() {
        let mut forms = HashMap::new();
        forms.insert("one".to_string(), "apple".to_string());
        forms.insert("other".to_string(), "apples".to_string());

        assert_eq!(pluralize(1.0, &forms), "apple");
        assert_eq!(pluralize(2.0, &forms), "apples");
        assert_eq!(pluralize(0.0, &forms), "apples");
    }

    #[test]
    fn pluralize_falls_back_to_other() {
        let mut forms = HashMap::new();
        forms.insert("other".to_string(), "items".to_string());
        // No "one" entry — should still return "other"
        assert_eq!(pluralize(1.0, &forms), "items");
    }

    #[test]
    fn pluralize_falls_back_to_first_value() {
        let mut forms = HashMap::new();
        forms.insert("few".to_string(), "rzeczy".to_string());
        // Neither "one" nor "other" — falls back to first available
        assert_eq!(pluralize(1.0, &forms), "rzeczy");
    }

    #[test]
    fn pluralize_empty_forms_returns_empty() {
        let forms = HashMap::new();
        assert_eq!(pluralize(1.0, &forms), "");
    }

    #[test]
    fn pluralize_slavic_uses_slavic_rules() {
        let mut forms = HashMap::new();
        forms.insert("one".to_string(), "jabłko".to_string());
        forms.insert("few".to_string(), "jabłka".to_string());
        forms.insert("many".to_string(), "jabłek".to_string());

        assert_eq!(pluralize_slavic(1, &forms), "jabłko");
        assert_eq!(pluralize_slavic(2, &forms), "jabłka");
        assert_eq!(pluralize_slavic(5, &forms), "jabłek");
        assert_eq!(pluralize_slavic(12, &forms), "jabłek");
        assert_eq!(pluralize_slavic(22, &forms), "jabłka");
    }
}
