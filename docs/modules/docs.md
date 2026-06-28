# Docs

## Purpose

Builds an API catalog to generate editor files and Markdown reference. - Analyzes docs-general coverage and quality using live table reflection.

## Summary

- The `docs` module treats documentation as an active engine-managed system rather than as a pile of disconnected markdown files.
- It builds and maintains a structured catalog of API knowledge, compares that catalog against what the engine actually exposes, and turns the result into actionable reports about missing, stale, or incomplete documentation.
- This matters because documentation quality drifts quickly in evolving codebases. Without a module like this, docs become passive artifacts that are only corrected sporadically instead of being continuously checked against source reality.
- The module acts as a bridge between implementation and publication by discovering what exists, validating whether it is described, and preparing that knowledge for several downstream consumers.
- Export paths are a major part of the feature. The same curated knowledge can be shaped into wiki-style outputs, editor hover text, completion data, machine-readable references, and other formats aimed at different readers and tools.
- Quality scoring, schema-oriented checks, and module-focused audits make the system practical for ongoing maintenance instead of occasional cleanup passes.
- This makes the module useful not only for publishing, but also for governance. Teams can spot undocumented APIs, stale wording, or inconsistent coverage before those gaps spread across several outputs.
- It also gives tooling one stable documentation catalog to consume.
- Other modules own behavior and signatures, but `docs` owns how that behavior is discovered, checked, cataloged, and published.
- Read `docs` as the coordination layer between engine reality and documentation output.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.docs.checkStaleness`

Lists source files in a directory for simple documentation staleness checks.

```lua
lurek.docs.checkStaleness(catalog_ud, source_dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog argument accepted for API symmetry with validation helpers. |
| `source_dir` | string | Directory scanned for `.rs` and `.lua` source files. |

**Returns**

| Type | Description |
|------|-------------|
| LDocsCheckStalenessResult | Table with stale, current, and missing arrays. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    lurek.log.info("stale = " .. #result.stale .. " current = " .. #result.current)
    lurek.log.info("missing = " .. #result.missing)
    lurek.log.info("first current path = " .. tostring(result.current[1]))
end
```

---

### `lurek.docs.coverage`

Returns documented and live API counts for the full `lurek` table.

```lua
lurek.docs.coverage(catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud?` | [LApiCatalog](#lapicatalog) | Optional catalog used for documented entry count. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of catalog entries supplied as documented. |
| number | Number of live APIs found by reflection. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local documented, live = lurek.docs.coverage(cat)
    lurek.log.info("documented=" .. documented .. " live=" .. live)
    lurek.log.info("coverage gap=" .. tostring(live - documented))
    lurek.log.info("catalog entries=" .. cat:entryCount())
end
```

---

### `lurek.docs.coverageModule`

Returns documented and live API counts for one module.

```lua
lurek.docs.coverageModule(module_name, catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | string | Module name under the `lurek` table. |
| `catalog_ud?` | [LApiCatalog](#lapicatalog) | Optional catalog used for documented entry count. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of catalog entries for the module. |
| number | Number of live APIs found in the module. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local documented, live = lurek.docs.coverageModule("math", cat)
    lurek.log.info("math documented=" .. documented .. " live=" .. live)
    lurek.log.info("math coverage gap=" .. tostring(live - documented))
    lurek.log.info("math entry count=" .. cat:entryCount("math"))
end
```

---

### `lurek.docs.describe`

Adds or updates the description for one editable catalog entry.

```lua
lurek.docs.describe(qualified_name, description)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | string | Full dotted API name to update or create. |
| `description` | string | Description text stored on the catalog entry. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    local cat = lurek.docs.getCatalog()
    local entry = cat:getEntry("lurek.math.lerp")
    lurek.log.info("description set")
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
    lurek.log.info("description length = " .. tostring(entry and #entry:getDescription() or 0))
end
```

---

### `lurek.docs.exportAll`

Exports all editor documentation artifacts for a catalog into a directory.

```lua
lurek.docs.exportAll(catalog_ud, output_dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog whose entries are exported. |
| `output_dir` | string | Directory that receives all generated artifacts. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local dir = "save/"
    lurek.docs.exportAll(cat, dir)
    lurek.log.info("all docs exported")
    lurek.log.info("export root = " .. dir)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end
```

---

### `lurek.docs.exportCheatsheet`

Writes a compact text cheatsheet from catalog entries.

```lua
lurek.docs.exportCheatsheet(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog whose entries are written. |
| `path` | string | Output cheatsheet file path. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_cheatsheet.txt"
    lurek.docs.exportCheatsheet(cat, path)
    lurek.log.info("cheatsheet exported")
    lurek.log.info("cheatsheet target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end
```

---

### `lurek.docs.exportCompletions`

Exports catalog completion metadata to a file.

```lua
lurek.docs.exportCompletions(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog whose entries are exported. |
| `path` | string | Output file path for completion data. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_completions.json"
    lurek.docs.exportCompletions(cat, path)
    lurek.log.info("completions exported")
    lurek.log.info("completions target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end
```

---

### `lurek.docs.exportHover`

Exports catalog hover metadata to a file.

```lua
lurek.docs.exportHover(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog whose entries are exported. |
| `path` | string | Output file path for hover data. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_hover.json"
    lurek.docs.exportHover(cat, path)
    lurek.log.info("hover exported")
    lurek.log.info("hover target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end
```

---

### `lurek.docs.exportMarkdown`

Writes a Markdown API reference from catalog entries.

```lua
lurek.docs.exportMarkdown(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog whose entries are written. |
| `path` | string | Output Markdown file path. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_api.md"
    lurek.docs.exportMarkdown(cat, path)
    lurek.log.info("markdown exported")
    lurek.log.info("markdown target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end
```

---

### `lurek.docs.exportSignatures`

Exports catalog signature metadata to a file.

```lua
lurek.docs.exportSignatures(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | [LApiCatalog](#lapicatalog) | Catalog whose entries are exported. |
| `path` | string | Output file path for signature data. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local path = "save/docs_signatures.json"
    lurek.docs.exportSignatures(cat, path)
    lurek.log.info("signatures exported")
    lurek.log.info("signatures target = " .. path)
    lurek.log.info("catalog entries exported = " .. cat:entryCount())
end
```

---

### `lurek.docs.getCatalog`

Returns the editable in-memory documentation catalog.

```lua
lurek.docs.getCatalog()
```

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | Catalog containing entries built by the editing functions. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.getCatalog()
    local modules = cat:getModules()
    lurek.log.info("catalog entries = " .. cat:entryCount())
    lurek.log.info("catalog userdata type = " .. cat:type())
    lurek.log.info("module count = " .. #modules)
end
```

---

### `lurek.docs.loadAll`

Loads all TOML documentation catalog files from a directory and combines their entries.

```lua
lurek.docs.loadAll(directory)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `directory` | string | Directory scanned for `.toml` catalog files. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | Catalog containing entries parsed from every readable TOML file. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local dir = "save/_fs_tests/docs_load_all/"
    lurek.filesystem.write(dir .. "a.toml", '[[entries]]\nname = "one"\nqualifiedName = "lurek.test.one"\nmodule = "test"\nkind = "function"\ndescription = "First entry"')
    lurek.filesystem.write(dir .. "b.toml", '[[entries]]\nname = "two"\nqualifiedName = "lurek.test.two"\nmodule = "test"\nkind = "function"\ndescription = "Second entry"')
    local cat = lurek.docs.loadAll(dir)
    lurek.log.info("all entries = " .. cat:entryCount())
    lurek.log.info("loadAll type = " .. cat:type())
    lurek.log.info("has lurek.test.one = " .. tostring(cat:getEntry("lurek.test.one") ~= nil))
end
```

---

### `lurek.docs.loadToml`

Loads a TOML documentation catalog file and converts its entries into an API catalog.

```lua
lurek.docs.loadToml(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to a TOML file containing an `entries` table. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | Catalog loaded from the TOML file. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local path = "save/_fs_tests/docs_load_toml_example.toml"
    lurek.filesystem.write(path, '[[entries]]\nname = "play"\nqualifiedName = "lurek.audio.play"\nmodule = "audio"\nkind = "function"\ndescription = "Plays a sound"')
    local cat = lurek.docs.loadToml(path)
    local entry = cat:getEntry("lurek.audio.play")
    lurek.log.info("loaded entries = " .. cat:entryCount())
    lurek.log.info("loaded type = " .. cat:type())
    lurek.log.info("loaded qualified name = " .. tostring(entry and entry:getQualifiedName()))
end
```

---

### `lurek.docs.quality`

Computes documentation quality for a supplied catalog or the editable in-memory catalog.

```lua
lurek.docs.quality(catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud?` | [LApiCatalog](#lapicatalog) | Optional catalog to score; omitted scores the editable catalog. |

**Returns**

| Type | Description |
|------|-------------|
| [LQualityReport](#lqualityreport) | Quality report with overall and module-level scores. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("quality score = " .. qr:getOverallScore())
    lurek.log.info("quality grade = " .. tostring(qr:getGrade()))
    lurek.log.info("report type = " .. qr:type())
end
```

---

### `lurek.docs.qualityModule`

Computes documentation quality for entries belonging to one module.

```lua
lurek.docs.qualityModule(module_name, catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | string | Module name used to filter entries before scoring. |
| `catalog_ud?` | [LApiCatalog](#lapicatalog) | Optional catalog to score; omitted scores the editable catalog. |

**Returns**

| Type | Description |
|------|-------------|
| [LQualityReport](#lqualityreport) | Quality report for the filtered module entries. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = lurek.docs.qualityModule("math", cat)
    lurek.log.info("math quality = " .. qr:getOverallScore())
    lurek.log.info("math grade = " .. tostring(qr:getGrade()))
    lurek.log.info("report type = " .. qr:type())
end
```

---

### `lurek.docs.reflectLive`

Reflects live `lurek` module tables into plain name and type rows.

```lua
lurek.docs.reflectLive(ns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ns?` | string | Optional module name to reflect; omitted reflects every table-valued module. |

**Returns**

| Type | Description |
|------|-------------|
| table | Reflection table keyed by module name or containing the requested module entry. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local data = lurek.docs.reflectLive("math")
    lurek.log.info("reflect math type = " .. type(data))
    lurek.log.info("reflected rows = " .. #data)
    lurek.log.info("first reflected name = " .. tostring(data[1] and data[1].name))
    lurek.log.info("second reflected type = " .. tostring(data[2] and data[2].type))
end
```

---

### `lurek.docs.reflectTable`

Reflects an arbitrary Lua table into name, qualifiedName, and type rows.

```lua
lurek.docs.reflectTable(tbl, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | table | Lua table to inspect without recursion. |
| `name?` | string | Optional prefix used to build qualifiedName values. |

**Returns**

| Type | Description |
|------|-------------|
| LDocsReflectTableResult | Array table of reflected item rows. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    lurek.log.info("reflected rows = " .. #rows)
    lurek.log.info("first reflected name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first reflected type = " .. tostring(rows[1] and rows[1].type))
end
```

---

### `lurek.docs.resetCatalog`

Clears the editable in-memory documentation catalog.

```lua
lurek.docs.resetCatalog()
```

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.describe("lurek.test.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    lurek.log.info("after reset entries = " .. cat:entryCount())
    lurek.log.info("after reset type = " .. cat:type())
end
```

---

### `lurek.docs.scan`

Reflects the live `lurek` table and builds a catalog of callable APIs.

```lua
lurek.docs.scan(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional scan options table reserved for future filters. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | Catalog populated from the currently registered `lurek` table. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scan()
    local modules = cat:getModules()
    lurek.log.info("scanned entries = " .. cat:entryCount())
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
    lurek.log.info("first module = " .. tostring(modules[1]))
end
```

---

### `lurek.docs.scanModule`

Reflects one live `lurek.<module>` table and builds a catalog for that module.

```lua
lurek.docs.scanModule(module_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | string | Module name under the `lurek` table. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | Catalog populated from the live module table. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scanModule("math")
    local entries = cat:getEntries("math")
    lurek.log.info("math entries = " .. cat:entryCount())
    lurek.log.info("math catalog type = " .. cat:type())
    lurek.log.info("first math entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
end
```

---

### `lurek.docs.schema`

Builds a schema validator from Lua table rules.

```lua
lurek.docs.schema(rules, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rules` | table | Rule table keyed by field name; `__strict` enables strict validation. |
| `name?` | string | Optional schema name; defaults to `schema`. |

**Returns**

| Type | Description |
|------|-------------|
| [LSchema](#lschema) | Schema handle that can validate Lua tables. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({ name = { type = "string", required = true }, age = { type = "number" } }, "PlayerSchema")
    local fields = s:getFields()
    lurek.log.info("schema name = " .. s:getName())
    lurek.log.info("schema type = " .. s:type())
    lurek.log.info("field count = " .. #fields)
end
```

---

### `lurek.docs.schemaFromToml`

Builds a schema validator from TOML schema text.

```lua
lurek.docs.schemaFromToml(toml_text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `toml_text` | string | TOML text parsed by the docs schema backend. |

**Returns**

| Type | Description |
|------|-------------|
| [LSchema](#lschema) | Schema handle parsed from the TOML text. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local toml = [[
name = "PlayerSchema"
strict = true

    [rules.name]
type = "string"
required = true
]]
    local s = lurek.docs.schemaFromToml(toml)
    lurek.log.info("schema from toml, name = " .. s:getName())
    lurek.log.info("schema field count = " .. #s:getFields())
    lurek.log.info("schema type = " .. s:type())
end
```

---

### `lurek.docs.setParamInfo`

Replaces parameter metadata for one editable catalog entry.

```lua
lurek.docs.setParamInfo(qualified_name, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | string | Full dotted API name whose parameters are updated. |
| `params` | table | Array table of parameter rows with name, type, description, optional, and optional default fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setParamInfo("lurek.test.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    local params = entry:getParameters()
    lurek.log.info("params set = " .. #params)
    lurek.log.info("first param name = " .. tostring(params[1] and params[1].name))
end
```

---

### `lurek.docs.setReturnInfo`

Replaces return-value metadata for one editable catalog entry.

```lua
lurek.docs.setReturnInfo(qualified_name, returns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | string | Full dotted API name whose return metadata is updated. |
| `returns` | table | Array table of return rows with type and description fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setReturnInfo("lurek.test.blend", {
        {type = "number", description = "Interpolated value"},
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    local returns = entry:getReturns()
    lurek.log.info("returns set = " .. #returns)
    lurek.log.info("first return type = " .. tostring(returns[1] and returns[1].type))
end
```

---

### `lurek.docs.validate`

Compares a documentation catalog with the live reflected `lurek` API table.

```lua
lurek.docs.validate(catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud?` | [LApiCatalog](#lapicatalog) | Optional catalog to validate against live reflection; omitted validates an empty catalog. |

**Returns**

| Type | Description |
|------|-------------|
| [LValidationReport](#lvalidationreport) | Report containing missing, phantom, and incomplete API names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("valid = " .. tostring(report:isValid()))
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("report type = " .. report:type())
end
```

---

### `lurek.docs.validateModule`

Compares one module's documentation catalog entries with the live reflected module table.

```lua
lurek.docs.validateModule(module_name, catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | string | Module name under the `lurek` table. |
| `catalog_ud?` | [LApiCatalog](#lapicatalog) | Optional catalog whose entries are filtered to the module. |

**Returns**

| Type | Description |
|------|-------------|
| [LValidationReport](#lvalidationreport) | Report containing missing, phantom, and incomplete API names for the module. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = lurek.docs.validateModule("math", cat)
    lurek.log.info("math missing = " .. report:missingCount())
    lurek.log.info("math phantom = " .. report:phantomCount())
    lurek.log.info("report type = " .. report:type())
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LApiCatalog](#lapicatalog)
- [LDocEntry](#ldocentry)
- [LQualityReport](#lqualityreport)
- [LSchema](#lschema)
- [LValidationReport](#lvalidationreport)

## LApiCatalog

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LApiCatalog:entryCount`

Counts entries in the catalog, optionally for one module.

```lua
LApiCatalog:entryCount(module)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module?` | string | Optional module name used to limit the count. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of matching entries. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    lurek.log.info("total=" .. total .. " math=" .. math_count)
    lurek.log.info("module count = " .. #cat:getModules())
end
```

---

#### `LApiCatalog:filter`

Builds a new catalog containing entries accepted by a Lua predicate.

```lua
LApiCatalog:filter(predicate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `predicate` | function | Callback called with each `[LDocEntry](#ldocentry)`; truthy return keeps the entry. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | New catalog containing only entries accepted by the predicate. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local fns = cat:filter(function(entry) return entry:getKind() == "function" end)
    lurek.log.info("functions = " .. fns:entryCount())
    lurek.log.info("filtered type = " .. fns:type())
    lurek.log.info("first filtered entry = " .. tostring(fns:getEntries()[1] and fns:getEntries()[1]:getQualifiedName()))
end
```

---

#### `LApiCatalog:getEntries`

Returns catalog entries, optionally limited to one module.

```lua
LApiCatalog:getEntries(module)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module?` | string | Optional module name used to filter entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry)[] | `[LDocEntry](#ldocentry)` handles. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    lurek.log.info("all=" .. #all .. " math=" .. #math_entries)
    lurek.log.info("first global entry = " .. tostring(all[1] and all[1]:getQualifiedName()))
end
```

---

#### `LApiCatalog:getEntry`

Returns one catalog entry by qualified API name.

```lua
LApiCatalog:getEntry(qualified_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | string | Full dotted API name to find. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry) | The matching catalog entry. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local entry = cat:getEntry("lurek.math.lerp")
    lurek.log.info("found entry = " .. tostring(entry ~= nil))
    lurek.log.info("catalog modules = " .. tostring(#cat:getModules()))
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
end
```

---

#### `LApiCatalog:getModules`

Returns every module represented in this catalog.

```lua
LApiCatalog:getModules()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted array table of module names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local modules = cat:getModules()
    lurek.log.info("modules = " .. #modules)
    lurek.log.info("first module = " .. tostring(modules[1]))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end
```

---

#### `LApiCatalog:getTypeMethods`

Returns method entries associated with a qualified type name.

```lua
LApiCatalog:getTypeMethods(qualified_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | string | Qualified type name used as the method prefix. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry)[] | `[LDocEntry](#ldocentry)` method entries. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local methods = cat:getTypeMethods("LVec2")
    lurek.log.info("LVec2 methods = " .. #methods)
    lurek.log.info("first method = " .. tostring(methods[1] and methods[1]:getQualifiedName()))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end
```

---

#### `LApiCatalog:getTypes`

Returns type names documented for one module.

```lua
LApiCatalog:getTypes(module_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | string | Module name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Documented type names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local types = cat:getTypes("math")
    lurek.log.info("math types = " .. #types)
    lurek.log.info("first type = " .. tostring(types[1]))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end
```

---

#### `LApiCatalog:merge`

Merges another catalog into this catalog and returns a new catalog value.

```lua
LApiCatalog:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LApiCatalog](#lapicatalog) | Catalog whose entries replace matching qualified names or append new entries. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | New catalog containing merged entries. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    lurek.log.info("merged = " .. merged:entryCount())
    lurek.log.info("merged module count = " .. #merged:getModules())
end
```

---

#### `LApiCatalog:search`

Searches names, qualified names, and descriptions with a case-insensitive substring query.

```lua
LApiCatalog:search(query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query` | string | Search text matched against catalog metadata. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry)[] | Matching `[LDocEntry](#ldocentry)` handles. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local results = cat:search("lerp")
    lurek.log.info("search results = " .. #results)
    lurek.log.info("first search hit = " .. tostring(results[1] and results[1]:getQualifiedName()))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end
```

---

#### `LApiCatalog:toJSON`

Serializes this catalog to formatted JSON.

```lua
LApiCatalog:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Pretty-printed JSON array of catalog entries. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has timer = " .. tostring(string.find(json, "timer", 1, true) ~= nil))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
end
```

---

#### `LApiCatalog:toTable`

Converts this catalog into plain Lua tables for lightweight inspection.

```lua
LApiCatalog:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| LApiCatalogToTableResult | Array of rows with name, qualifiedName, module, kind, description, and score fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    lurek.log.info("rows = " .. #rows)
    lurek.log.info("first row name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first row module = " .. tostring(rows[1] and rows[1].module))
end
```

---

#### `LApiCatalog:type`

Returns the Lua-visible type name for this API catalog handle.

```lua
LApiCatalog:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LApiCatalog](#lapicatalog)`. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    lurek.log.info("type = " .. cat:type())
    lurek.log.info("catalog modules = " .. tostring(#cat:getModules()))
    lurek.log.info("typeOf LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    lurek.log.info("module count = " .. tostring(#cat:getModules()))
end
```

---

#### `LApiCatalog:typeOf`

Returns whether this API catalog handle matches a supported type name.

```lua
LApiCatalog:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LApiCatalog](#lapicatalog)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    lurek.log.info("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
    lurek.log.info("type = " .. tostring(cat:type()))
    lurek.log.info("catalog entries = " .. tostring(cat:entryCount()))
    lurek.log.info("entry count = " .. tostring(cat:entryCount()))
end
```

---

## LDocEntry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LDocEntry:getDeprecated`

Returns this entry's deprecation text when one was recorded.

```lua
LDocEntry:getDeprecated()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Deprecation string, or nil when the entry is not marked deprecated. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local deprecated = docs_example_entry:getDeprecated()
    lurek.log.info("deprecated = " .. type(deprecated))
    lurek.log.info("deprecated value = " .. tostring(deprecated))
    lurek.log.info("entry qualified = " .. tostring(docs_example_entry:getQualifiedName()))
    lurek.log.info("entry module = " .. tostring(docs_example_entry:getModule()))
end
```

---

#### `LDocEntry:getDescription`

Returns the prose description recorded for this entry.

```lua
LDocEntry:getDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Documentation description text. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("desc len = " .. #entry:getDescription())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("has description = " .. tostring(entry:hasDescription()))
    lurek.log.info("name = " .. tostring(entry:getName()))
end
```

---

#### `LDocEntry:getExample`

Returns this entry's example text when one was recorded.

```lua
LDocEntry:getExample()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Example string, or nil when no example exists. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local example = docs_example_entry:getExample()
    lurek.log.info("example = " .. type(example))
    lurek.log.info("example length = " .. tostring(example and #example or 0))
    lurek.log.info("has example = " .. tostring(docs_example_entry:hasExample()))
    lurek.log.info("entry kind = " .. tostring(docs_example_entry:getKind()))
end
```

---

#### `LDocEntry:getKind`

Returns the documentation kind recorded for this entry.

```lua
LDocEntry:getKind()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Entry kind such as `function`, `method`, `type`, or `value`. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("kind = " .. entry:getKind())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("name = " .. tostring(entry:getName()))
    lurek.log.info("qualified = " .. tostring(entry:getQualifiedName()))
end
```

---

#### `LDocEntry:getModule`

Returns the module name associated with this documentation entry.

```lua
LDocEntry:getModule()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Module name. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("module = " .. entry:getModule())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("kind = " .. tostring(entry:getKind()))
    lurek.log.info("name = " .. tostring(entry:getName()))
end
```

---

#### `LDocEntry:getName`

Returns the short API name stored by this documentation entry.

```lua
LDocEntry:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Entry name without module prefix. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("name = " .. entry:getName())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("qualified = " .. tostring(entry:getQualifiedName()))
    lurek.log.info("module = " .. tostring(entry:getModule()))
end
```

---

#### `LDocEntry:getParameters`

Returns parameter metadata recorded for this entry.

```lua
LDocEntry:getParameters()
```

**Returns**

| Type | Description |
|------|-------------|
| LDocEntryGetParametersResult | Array of parameter rows with name, type, description, optional, and optional default fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local params = docs_example_entry:getParameters()
    lurek.log.info("params = " .. #params)
    lurek.log.info("params count = " .. tostring(#params))
    lurek.log.info("first param name = " .. tostring(params[1] and params[1].name))
    lurek.log.info("entry name = " .. tostring(docs_example_entry:getName()))
end
```

---

#### `LDocEntry:getQualifiedName`

Returns the full dotted API name stored by this documentation entry.

```lua
LDocEntry:getQualifiedName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Qualified API name. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("qualified = " .. entry:getQualifiedName())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("module = " .. tostring(entry:getModule()))
    lurek.log.info("kind = " .. tostring(entry:getKind()))
end
```

---

#### `LDocEntry:getReturns`

Returns return-value metadata recorded for this entry.

```lua
LDocEntry:getReturns()
```

**Returns**

| Type | Description |
|------|-------------|
| LDocEntryGetReturnsResult | Array table of return rows with type and description fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local returns = docs_example_entry:getReturns()
    lurek.log.info("returns = " .. #returns)
    lurek.log.info("returns count = " .. tostring(#returns))
    lurek.log.info("first return type = " .. tostring(returns[1] and returns[1].type))
    lurek.log.info("entry name = " .. tostring(docs_example_entry:getName()))
end
```

---

#### `LDocEntry:getScore`

Returns the documentation quality score calculated for this entry.

```lua
LDocEntry:getScore()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Quality score in the range used by the docs scoring backend. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("score = " .. entry:getScore())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("module = " .. tostring(entry:getModule()))
    lurek.log.info("kind = " .. tostring(entry:getKind()))
end
```

---

#### `LDocEntry:getSince`

Returns this entry's since-version text when one was recorded.

```lua
LDocEntry:getSince()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Since-version string, or nil when no value exists. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local since = docs_example_entry:getSince()
    lurek.log.info("since = " .. type(since))
    lurek.log.info("since value = " .. tostring(since))
    lurek.log.info("entry name = " .. tostring(docs_example_entry:getName()))
    lurek.log.info("entry module = " .. tostring(docs_example_entry:getModule()))
end
```

---

#### `LDocEntry:hasDescription`

Returns whether this entry has non-empty description text.

```lua
LDocEntry:hasDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the description is present. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasDesc = " .. tostring(entry:hasDescription()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("description length = " .. tostring(#entry:getDescription()))
    lurek.log.info("entry kind = " .. tostring(entry:getKind()))
end
```

---

#### `LDocEntry:hasExample`

Returns whether this entry has example text.

```lua
LDocEntry:hasExample()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an example is recorded. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasExample = " .. tostring(entry:hasExample()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("example text type = " .. type(entry:getExample()))
    lurek.log.info("entry qualified = " .. tostring(entry:getQualifiedName()))
end
```

---

#### `LDocEntry:hasParameters`

Returns whether this entry has parameter metadata.

```lua
LDocEntry:hasParameters()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when at least one parameter is recorded. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasParams = " .. tostring(entry:hasParameters()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("param count = " .. tostring(#entry:getParameters()))
    lurek.log.info("entry name = " .. tostring(entry:getName()))
end
```

---

#### `LDocEntry:hasReturnType`

Returns whether this entry has return-value metadata.

```lua
LDocEntry:hasReturnType()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when at least one return row is recorded. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("hasReturn = " .. tostring(entry:hasReturnType()))
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("return count = " .. tostring(#entry:getReturns()))
    lurek.log.info("entry name = " .. tostring(entry:getName()))
end
```

---

#### `LDocEntry:type`

Returns the Lua-visible type name for this documentation entry handle.

```lua
LDocEntry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LDocEntry](#ldocentry)`. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("type = " .. entry:type())
    lurek.log.info("qualified chars = " .. #entry:getQualifiedName())
    lurek.log.info("typeOf LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    lurek.log.info("entry module = " .. tostring(entry:getModule()))
end
```

---

#### `LDocEntry:typeOf`

Returns whether this documentation entry handle matches a supported type name.

```lua
LDocEntry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LDocEntry](#ldocentry)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local entry = docs_example_entry
    lurek.log.info("is LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
    lurek.log.info("type = " .. tostring(entry:type()))
    lurek.log.info("entry module = " .. tostring(entry:getModule()))
    lurek.log.info("entry kind = " .. tostring(entry:getKind()))
end
```

---

## LQualityReport

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LQualityReport:getBest`

Returns the highest-scoring documentation entries.

```lua
LQualityReport:getBest(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Optional maximum number of entries to return; defaults to 10. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry)[] | Best-scoring `[LDocEntry](#ldocentry)` handles. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local best = qr:getBest(5)
    lurek.log.info("best 5 = " .. #best)
    lurek.log.info("first best = " .. tostring(best[1] and best[1]:getQualifiedName()))
end
```

---

#### `LQualityReport:getByGrade`

Returns documentation entries whose calculated grade matches a grade string.

```lua
LQualityReport:getByGrade(grade)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grade` | string | Grade string produced by the docs quality backend. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry)[] | Matching `[LDocEntry](#ldocentry)` handles. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local a_entries = qr:getByGrade("A")
    lurek.log.info("grade A entries = " .. #a_entries)
    lurek.log.info("first A entry = " .. tostring(a_entries[1] and a_entries[1]:getQualifiedName()))
end
```

---

#### `LQualityReport:getGrade`

Returns the letter grade derived from the aggregate documentation score.

```lua
LQualityReport:getGrade()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Quality grade text. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("grade = " .. qr:getGrade())
    lurek.log.info("overall score = " .. tostring(qr:getOverallScore()))
    lurek.log.info("type = " .. qr:type())
end
```

---

#### `LQualityReport:getIssues`

Returns structured quality-rule issues with rule ids, severities, and hints.

```lua
LQualityReport:getIssues()
```

**Returns**

| Type | Description |
|------|-------------|
| table[] | Array of issue rows. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local issues = qr:getIssues()
    lurek.log.info("quality issues = " .. #issues)
    lurek.log.info("first issue kind = " .. tostring(issues[1] and issues[1].kind))
    lurek.log.info("first issue message = " .. tostring(issues[1] and issues[1].message))
end
```

---

#### `LQualityReport:getModuleScores`

Returns per-module documentation quality scores.

```lua
LQualityReport:getModuleScores()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Map table keyed by module name with numeric scores. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local scores = qr:getModuleScores()
    lurek.log.info("module scores type = " .. type(scores))
    lurek.log.info("math score = " .. tostring(scores.math))
end
```

---

#### `LQualityReport:getOverallScore`

Returns the aggregate documentation quality score.

```lua
LQualityReport:getOverallScore()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Overall score in the range used by the docs scoring backend. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("score = " .. qr:getOverallScore())
    lurek.log.info("grade = " .. tostring(qr:getGrade()))
    lurek.log.info("type = " .. qr:type())
end
```

---

#### `LQualityReport:getSummary`

Returns a human-readable summary of overall and per-module quality scores.

```lua
LQualityReport:getSummary()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Multiline quality summary text. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local summary = qr:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.log.info("type = " .. qr:type())
end
```

---

#### `LQualityReport:getWorst`

Returns the lowest-scoring documentation entries.

```lua
LQualityReport:getWorst(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | number | Optional maximum number of entries to return; defaults to 10. |

**Returns**

| Type | Description |
|------|-------------|
| [LDocEntry](#ldocentry)[] | Worst-scoring `[LDocEntry](#ldocentry)` handles. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local worst = qr:getWorst(5)
    lurek.log.info("worst 5 = " .. #worst)
    lurek.log.info("first worst = " .. tostring(worst[1] and worst[1]:getQualifiedName()))
end
```

---

#### `LQualityReport:issueCount`

Returns the number of structured quality issues.

```lua
LQualityReport:issueCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total issue count. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local issues = qr:getIssues()
    lurek.log.info("quality issue count = " .. qr:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.log.info("quality grade = " .. tostring(qr:getGrade()))
end
```

---

#### `LQualityReport:toJSON`

Serializes this quality report to formatted JSON.

```lua
LQualityReport:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Pretty-printed JSON object for the quality report. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local json = qr:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has grade = " .. tostring(string.find(json, "grade", 1, true) ~= nil))
end
```

---

#### `LQualityReport:toTable`

Converts this quality report into a plain Lua table.

```lua
LQualityReport:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| LQualityReportToTableResult | Table with overallScore, grade, moduleScores, issues, and policy fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    local t = qr:toTable()
    lurek.log.info("overall = " .. t.overallScore .. " grade = " .. t.grade)
    lurek.log.info("module score count = " .. tostring(type(t.moduleScores)))
end
```

---

#### `LQualityReport:type`

Returns the Lua-visible type name for this quality report handle.

```lua
LQualityReport:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LQualityReport](#lqualityreport)`. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("type = " .. qr:type())
    lurek.log.info("summary length = " .. #qr:getSummary())
    lurek.log.info("typeOf LQualityReport = " .. tostring(qr:typeOf("LQualityReport")))
end
```

---

#### `LQualityReport:typeOf`

Returns whether this quality report handle matches a supported type name.

```lua
LQualityReport:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LQualityReport](#lqualityreport)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local qr = docs_example_quality
    lurek.log.info("is report = " .. tostring(qr:typeOf("LQualityReport")))
    lurek.log.info("type = " .. tostring(qr:type()))
    lurek.log.info("grade = " .. tostring(qr:getGrade()))
end
```

---

## LSchema

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSchema:assert`

Validates a Lua table and raises a Lua error when schema checks fail.

```lua
LSchema:assert(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Table whose fields are checked against this schema. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({v = {type = "number"}})
    local ok = pcall(function() s["assert"](s, {v = 10}) end)
    lurek.log.info("assert passed = " .. tostring(ok))
    lurek.log.info("schema field count = " .. #s:getFields())
    lurek.log.info("schema type = " .. s:type())
end
```

---

#### `LSchema:check`

Validates a Lua table and returns only the boolean result.

```lua
LSchema:check(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Table whose fields are checked against this schema. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the table satisfies the schema rules. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({x = {type = "number"}})
    lurek.log.info("check = " .. tostring(s:check({x = 42})))
    lurek.log.info("schema name = " .. tostring(s:getName()))
    lurek.log.info("is schema = " .. tostring(s:typeOf("LSchema")))
    lurek.log.info("field count = " .. #s:getFields())
end
```

---

#### `LSchema:getFields`

Returns the field names declared by this schema.

```lua
LSchema:getFields()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted array table of field names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    lurek.log.info("fields = " .. #fields)
    lurek.log.info("first field = " .. tostring(fields[1]))
    lurek.log.info("schema type = " .. s:type())
end
```

---

#### `LSchema:getName`

Returns this schema's display name.

```lua
LSchema:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Schema name. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({}, "TestSchema")
    lurek.log.info("name = " .. s:getName())
    lurek.log.info("schema name = " .. tostring(s:getName()))
    lurek.log.info("field count = " .. #s:getFields())
    lurek.log.info("is schema = " .. tostring(s:typeOf("LSchema")))
end
```

---

#### `LSchema:type`

Returns the Lua-visible type name for this schema handle.

```lua
LSchema:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LSchema](#lschema)`. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({})
    lurek.log.info("type = " .. s:type())
    lurek.log.info("schema fields = " .. tostring(#s:getFields()))
    lurek.log.info("typeOf LSchema = " .. tostring(s:typeOf("LSchema")))
    lurek.log.info("field count = " .. #s:getFields())
end
```

---

#### `LSchema:typeOf`

Returns whether this schema handle matches a supported type name.

```lua
LSchema:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LSchema](#lschema)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({})
    lurek.log.info("is LSchema = " .. tostring(s:typeOf("LSchema")))
    lurek.log.info("type = " .. tostring(s:type()))
    lurek.log.info("first field = " .. tostring(s:getFields()[1]))
    lurek.log.info("field count = " .. #s:getFields())
end
```

---

#### `LSchema:validate`

Validates a Lua table and returns a success flag plus structured error rows.

```lua
LSchema:validate(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Table whose fields are checked against this schema. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when every provided field satisfies the schema rules. |
| LSchemaValidateResult | Array table of validation errors with field and message fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    lurek.log.info("valid = " .. tostring(ok) .. " errors = " .. #errors)
    lurek.log.info("schema type = " .. s:type())
    lurek.log.info("field count = " .. #s:getFields())
end
```

---

## LValidationReport

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LValidationReport:getIncomplete`

Returns catalog APIs whose documentation was incomplete.

```lua
LValidationReport:getIncomplete()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Incomplete qualified names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local incomplete = report:getIncomplete()
    lurek.log.info("incomplete = " .. #incomplete)
    lurek.log.info("first incomplete = " .. tostring(incomplete[1] and incomplete[1].qualifiedName))
end
```

---

#### `LValidationReport:getIssues`

Returns structured validation issues with rule ids, severities, and hints.

```lua
LValidationReport:getIssues()
```

**Returns**

| Type | Description |
|------|-------------|
| table[] | Array of issue rows. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local issues = report:getIssues()
    lurek.log.info("issues = " .. #issues)
    lurek.log.info("first issue severity = " .. tostring(issues[1] and issues[1].severity))
    lurek.log.info("first issue module = " .. tostring(issues[1] and issues[1].module))
end
```

---

#### `LValidationReport:getMissing`

Returns live APIs that were missing from the checked catalog.

```lua
LValidationReport:getMissing()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Missing qualified names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local missing = report:getMissing()
    lurek.log.info("missing = " .. #missing)
    lurek.log.info("first missing = " .. tostring(missing[1] and missing[1].qualifiedName))
end
```

---

#### `LValidationReport:getPhantom`

Returns catalog APIs that were not present in the live Lua table.

```lua
LValidationReport:getPhantom()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Phantom qualified names. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local phantom = report:getPhantom()
    lurek.log.info("phantom = " .. #phantom)
    lurek.log.info("first phantom = " .. tostring(phantom[1] and phantom[1].qualifiedName))
end
```

---

#### `LValidationReport:getSummary`

Returns a compact text summary of missing, phantom, and incomplete counts.

```lua
LValidationReport:getSummary()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Human-readable validation summary. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local summary = report:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.log.info("report type = " .. report:type())
end
```

---

#### `LValidationReport:incompleteCount`

Returns the number of catalog APIs with incomplete documentation.

```lua
LValidationReport:incompleteCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Incomplete API count. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("incomplete count = " .. report:incompleteCount())
    lurek.log.info("phantom count = " .. report:phantomCount())
    lurek.log.info("report type = " .. report:type())
end
```

---

#### `LValidationReport:isValid`

Returns whether the validation report has no missing live APIs.

```lua
LValidationReport:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no live APIs are missing from the catalog. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("valid = " .. tostring(report:isValid()))
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("report type = " .. report:type())
end
```

---

#### `LValidationReport:issueCount`

Returns the number of structured validation issues.

```lua
LValidationReport:issueCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total issue count. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local issues = report:getIssues()
    lurek.log.info("issue count = " .. report:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.log.info("is valid = " .. tostring(report:isValid()))
end
```

---

#### `LValidationReport:missingCount`

Returns the number of live APIs missing from the catalog.

```lua
LValidationReport:missingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Missing API count. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("missing count = " .. report:missingCount())
    lurek.log.info("is valid = " .. tostring(report:isValid()))
    lurek.log.info("report type = " .. report:type())
end
```

---

#### `LValidationReport:phantomCount`

Returns the number of catalog APIs absent from live reflection.

```lua
LValidationReport:phantomCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Phantom API count. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("phantom count = " .. report:phantomCount())
    lurek.log.info("missing count = " .. report:missingCount())
    lurek.log.info("report type = " .. report:type())
end
```

---

#### `LValidationReport:toJSON`

Serializes this validation report to formatted JSON.

```lua
LValidationReport:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Pretty-printed JSON object for the report. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local json = report:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has missing key = " .. tostring(string.find(json, "missing", 1, true) ~= nil))
end
```

---

#### `LValidationReport:toTable`

Converts this validation report into a plain Lua table.

```lua
LValidationReport:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| LValidationReportToTableResult | Table with missing, phantom, incomplete, issues, and isValid fields. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    local t = report:toTable()
    lurek.log.info("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
    lurek.log.info("incomplete=" .. #t.incomplete)
end
```

---

#### `LValidationReport:type`

Returns the Lua-visible type name for this validation report handle.

```lua
LValidationReport:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LValidationReport](#lvalidationreport)`. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("type = " .. report:type())
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("typeOf LValidationReport = " .. tostring(report:typeOf("LValidationReport")))
end
```

---

#### `LValidationReport:typeOf`

Returns whether this validation report handle matches a supported type name.

```lua
LValidationReport:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LValidationReport](#lvalidationreport)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local docs_example_cat = lurek.docs.scanModule("math")
    local docs_example_entry = docs_example_cat:getEntry("lurek.math.lerp")
    local docs_example_validate = lurek.docs.validate(docs_example_cat)
    local docs_example_quality = lurek.docs.quality(docs_example_cat)

    local cat = docs_example_cat
    local report = docs_example_validate
    lurek.log.info("is report = " .. tostring(report:typeOf("LValidationReport")))
    lurek.log.info("type = " .. tostring(report:type()))
    lurek.log.info("valid = " .. tostring(report:isValid()))
end
```

---
