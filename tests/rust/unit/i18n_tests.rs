//! Tests for the i18n module.

use lurek2d::i18n::*;
use std::collections::HashMap;

// ── plural ────────────────────────────────────────────────────────────────────

mod plural_tests {
    use super::*;

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

// ── interpolation ─────────────────────────────────────────────────────────────

mod interpolation_tests {
    use super::*;

    #[test]
    fn replaces_single_var() {
        let mut v = HashMap::new();
        v.insert("name".into(), "World".into());
        assert_eq!(interpolate("Hello, {name}!", &v), "Hello, World!");
    }

    #[test]
    fn unknown_key_kept() {
        let v = HashMap::new();
        assert_eq!(interpolate("Hi {x}", &v), "Hi {x}");
    }

    #[test]
    fn escaped_braces() {
        let v = HashMap::new();
        assert_eq!(interpolate("{{literal}}", &v), "{literal}");
    }

    #[test]
    fn multiple_vars() {
        let mut v = HashMap::new();
        v.insert("a".into(), "1".into());
        v.insert("b".into(), "2".into());
        assert_eq!(interpolate("{a} + {b} = 3", &v), "1 + 2 = 3");
    }

    #[test]
    fn escaped_closing_braces() {
        let v = HashMap::new();
        assert_eq!(interpolate("a }}b", &v), "a }b");
    }

    #[test]
    fn unterminated_placeholder() {
        let v = HashMap::new();
        // Unterminated brace outputs as-is (no closing '}')
        assert_eq!(interpolate("hello {name", &v), "hello {name");
    }

    #[test]
    fn empty_template() {
        let v = HashMap::new();
        assert_eq!(interpolate("", &v), "");
    }

    #[test]
    fn no_placeholders() {
        let v = HashMap::new();
        assert_eq!(interpolate("plain text", &v), "plain text");
    }

    #[test]
    fn interpolate_pairs_basic() {
        let pairs = vec![
            ("name".to_string(), "Ada".to_string()),
            ("count".to_string(), "3".to_string()),
        ];
        assert_eq!(
            interpolate_pairs("{name} has {count} items", &pairs),
            "Ada has 3 items"
        );
    }

    #[test]
    fn interpolate_pairs_empty() {
        let pairs = Vec::new();
        assert_eq!(interpolate_pairs("no vars", &pairs), "no vars");
    }
}

// ── catalog ───────────────────────────────────────────────────────────────────

mod catalog_tests {
    use super::*;

    /// Helper: create a catalog with one English locale loaded.
    fn en_catalog() -> Catalog {
        let mut c = Catalog::new();
        let mut table = HashMap::new();
        table.insert("ui.ok".to_string(), "OK".to_string());
        table.insert("ui.cancel".to_string(), "Cancel".to_string());
        table.insert("item.sword".to_string(), "Sword".to_string());
        c.load("en", table);
        c.locale = "en".to_string();
        c
    }

    #[test]
    fn new_creates_empty_catalog() {
        let c = Catalog::new();
        assert_eq!(c.locale, "");
        assert!(c.fallbacks.is_empty());
        assert!(c.tables.is_empty());
    }

    #[test]
    fn load_and_get() {
        let c = en_catalog();
        assert_eq!(c.get("ui.ok").unwrap(), "OK");
        assert_eq!(c.get("item.sword").unwrap(), "Sword");
    }

    #[test]
    fn get_missing_key_returns_error() {
        let c = en_catalog();
        assert!(c.get("nonexistent").is_err());
    }

    #[test]
    fn unload_removes_locale() {
        let mut c = en_catalog();
        assert!(c.has_locale("en"));
        assert!(c.unload("en"));
        assert!(!c.has_locale("en"));
        assert!(!c.unload("en")); // second unload returns false
    }

    #[test]
    fn has_locale_and_locales() {
        let mut c = en_catalog();
        c.load("pl", HashMap::new());
        assert!(c.has_locale("en"));
        assert!(c.has_locale("pl"));
        assert!(!c.has_locale("de"));
        let mut locs = c.locales();
        locs.sort();
        assert_eq!(locs, vec!["en", "pl"]);
    }

    #[test]
    fn has_key_and_keys() {
        let c = en_catalog();
        assert!(c.has_key("ui.ok"));
        assert!(!c.has_key("missing"));
        let mut k = c.keys();
        k.sort();
        assert_eq!(k, vec!["item.sword", "ui.cancel", "ui.ok"]);
    }

    #[test]
    fn fallback_chain_resolves() {
        let mut c = Catalog::new();
        let mut en = HashMap::new();
        en.insert("greeting".to_string(), "Hello".to_string());
        c.load("en", en);

        // French locale missing the "greeting" key
        c.load("fr", HashMap::new());
        c.locale = "fr".to_string();
        c.fallbacks = vec!["en".to_string()];

        assert_eq!(c.get("greeting").unwrap(), "Hello");
    }

    #[test]
    fn translate_returns_key_on_miss() {
        let c = en_catalog();
        assert_eq!(c.translate("no.such.key"), "no.such.key");
        assert_eq!(c.translate("ui.ok"), "OK");
    }

    #[test]
    fn set_key_creates_or_updates() {
        let mut c = en_catalog();
        c.set_key("en", "ui.ok", "Okay");
        assert_eq!(c.get("ui.ok").unwrap(), "Okay");

        // set_key into a new locale auto-creates the table
        c.set_key("de", "greeting", "Hallo");
        assert!(c.has_locale("de"));
    }

    #[test]
    fn export_clones_table() {
        let c = en_catalog();
        let exported = c.export("en").unwrap();
        assert_eq!(exported.get("ui.ok").unwrap(), "OK");
        assert!(c.export("missing").is_none());
    }

    #[test]
    fn merge_adds_without_replacing_table() {
        let mut c = en_catalog();
        let mut extra = HashMap::new();
        extra.insert("ui.save".to_string(), "Save".to_string());
        c.merge("en", extra);
        assert_eq!(c.get("ui.save").unwrap(), "Save");
        assert_eq!(c.get("ui.ok").unwrap(), "OK"); // existing keys intact
    }

    #[test]
    fn key_count() {
        let c = en_catalog();
        assert_eq!(c.key_count(), 3);
    }

    #[test]
    fn categories_extracts_prefixes() {
        let c = en_catalog();
        let cats = c.categories();
        assert!(cats.contains(&"ui".to_string()));
        assert!(cats.contains(&"item".to_string()));
        assert_eq!(cats.len(), 2);
    }

    #[test]
    fn keys_in_category() {
        let c = en_catalog();
        let mut ui_keys = c.keys_in_category("ui");
        ui_keys.sort();
        assert_eq!(ui_keys, vec!["ui.cancel", "ui.ok"]);
        assert!(c.keys_in_category("nonexistent").is_empty());
    }

    #[test]
    fn search_case_insensitive() {
        let c = en_catalog();
        let results = c.search("ok", 0);
        assert_eq!(results.len(), 1);
        assert_eq!(results[0], ("ui.ok", "OK"));
    }

    #[test]
    fn search_with_limit() {
        let c = en_catalog();
        let results = c.search("", 1); // empty query matches all
        assert_eq!(results.len(), 1);
    }

    #[test]
    fn build_index_creates_word_map() {
        let mut c = Catalog::new();
        let mut table = HashMap::new();
        table.insert("a".to_string(), "hello world".to_string());
        table.insert("b".to_string(), "hello there".to_string());
        c.load("en", table);
        c.locale = "en".to_string();

        let idx = c.build_index();
        let hello_keys = idx.get("hello").unwrap();
        assert_eq!(hello_keys.len(), 2);
        assert!(hello_keys.contains(&"a".to_string()));
        assert!(hello_keys.contains(&"b".to_string()));
    }

    #[test]
    fn empty_catalog_operations_return_defaults() {
        let c = Catalog::new();
        assert!(!c.has_key("any"));
        assert!(c.keys().is_empty());
        assert_eq!(c.key_count(), 0);
        assert!(c.categories().is_empty());
        assert!(c.keys_in_category("x").is_empty());
        assert!(c.search("x", 0).is_empty());
        assert!(c.build_index().is_empty());
    }
}
