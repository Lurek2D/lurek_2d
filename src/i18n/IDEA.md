# IDEA.md — `i18n` module

> No `ideas/features/` localization file exists — using `src/lua_api/i18n_api.rs` source scan.
> Status checked against `src/i18n/` and `src/lua_api/i18n_api.rs`.
> Lua namespace: `lurek.i18n`.

---

## Features

### ✅ DONE — Translation Tables with Flat Key Lookup
**Source**: `i18n_api.rs:90`

`lurek.i18n.loadTable(locale, tbl)` — loads nested Lua table, flattens to dot-key
lookup (`"menu.start"`, etc.).

---

### ✅ DONE — String Interpolation
**Source**: `i18n_api.rs:4` — `interpolate` function import

Template variable substitution in strings (e.g. `"Hello, {name}!"`).

---

### ✅ DONE — Pluralization Forms
**Source**: `i18n_api.rs:14` — `PluralForm` import

`lurek.i18n.plural(key, n)` — selects the right plural form by count.

---

### ✅ DONE — Fallback Chain
**Source**: `i18n_api.rs:156` — `setFallbacks`

`lurek.i18n.setFallbacks({"fr-CA", "fr", "en"})` — ordered fallback lookup.

---

### ✅ DONE — Language Change Event
**Source**: `i18n_api.rs:273` — `onLanguageChange`

`lurek.i18n.onLanguageChange(fn)` — callback fires with (newLocale, oldLocale).

---

### ✅ DONE — Unload Locale
**Source**: `i18n_api.rs:101`

`lurek.i18n.unloadTable(locale)` — removes strings for a locale from cache.

---

### ✅ DONE — Number Formatting (Locale-Aware)
**Source**: General i18n completeness

`lurek.localization.formatNumber(n, opts?)` implemented in `i18n_api.rs`.
Applies locale-aware decimal separator and thousands grouping. `opts.decimals` controls
decimal places (default 2).
```lua
lurek.localization.formatNumber(1234567.89)      -- "1,234,567.89" (en)
lurek.localization.formatNumber(1234567.89, {decimals=0})  -- "1,234,568" (en)
```

---

### ✅ DONE — Date/Time Formatting (Locale-Aware)
**Source**: General i18n completeness

`lurek.localization.formatDate(timestamp, fmt?)` implemented in `i18n_api.rs`.
Formats a Unix-timestamp-in-days as a locale-aware date string. `fmt` is `"short"` (default),
`"long"`, or `"iso"`.
```lua
lurek.localization.formatDate(738000)            -- "1/15/2021" (en)
lurek.localization.formatDate(738000, "long")    -- "January 15, 2021"
```

---

### ✅ DONE — Gender-Sensitive Translation
**Source**: General i18n completeness

`lurek.localization.tGender(key, gender, vars?)` implemented in `i18n_api.rs`.
Looks up `key.masculine` / `key.feminine` / `key.neutral` with fallback to `key`.
```lua
lurek.localization.tGender("actor.attack", "feminine", {name="Aria"})
```

---

### ✅ DONE — Enumerate Loaded Locales
**Source**: General API completeness

`lurek.localization.getLoadedLocales()` implemented in `i18n_api.rs`.
Returns an array table of all currently-loaded locale codes, useful for building
language-selector dropdowns.

---

### 🔇 LOW — RTL (Right-to-Left) Text Direction
**Source**: Arabic/Hebrew support

No text direction hint forwarded to font renderer. Low priority for most games
but would be required for proper Arabic or Hebrew localization.
