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
    local cat = lurek.docs.scanModule("repl")
    local result = lurek.docs.checkStaleness(cat, "src")
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
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
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
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local documented, live = lurek.docs.coverageModule("repl", cat)
    lurek.log.info("repl documented=" .. documented .. " live=" .. live)
    lurek.log.info("repl coverage gap=" .. tostring(live - documented))
    lurek.log.info("repl entry count=" .. cat:entryCount())
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn a demo entity.")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.spawn")
    lurek.log.info("description set")
    lurek.log.info("description length = " .. tostring(entry and #entry:getDescription() or 0))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.exportAll", "Export all entry")
    local cat = lurek.docs.getCatalog()
    local rel_dir = "save/_docs_example_export_all"
    local abs_dir = lurek.filesystem.getSaveDirectory() .. "/_docs_example_export_all"
    lurek.docs.exportAll(cat, abs_dir)
    lurek.log.info("all docs exported")
    lurek.log.info("has completions = " .. tostring(lurek.filesystem.exists(rel_dir .. "/completions.json")))
    lurek.log.info("has hover = " .. tostring(lurek.filesystem.exists(rel_dir .. "/hover.json")))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.exportCheatsheet", "Cheatsheet entry")
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_cheatsheet.txt"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_cheatsheet.txt"
    lurek.docs.exportCheatsheet(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("cheatsheet exported")
    lurek.log.info("has signature = " .. tostring(string.find(payload, "lurek.test.exportCheatsheet", 1, true) ~= nil))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("game.quest.start", "Start a quest step.")
    lurek.docs.setParamInfo("game.quest.start", {
        { name = "value", type = "number", description = "Quest stage", optional = false },
    })
    lurek.docs.setReturnInfo("game.quest.start", {
        { type = "boolean", description = "True when the step can begin" },
    })
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_completions.json"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_completions.json"
    lurek.docs.exportCompletions(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("completions exported = " .. tostring(string.find(payload, "game.quest.start", 1, true) ~= nil))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("game.quest.hover", "Hover text for a quest action.")
    lurek.docs.setParamInfo("game.quest.hover", {
        { name = "value", type = "string", description = "Quest id", optional = false },
    })
    lurek.docs.setReturnInfo("game.quest.hover", {
        { type = "string", description = "Rendered hover text" },
    })
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_hover.json"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_hover.json"
    lurek.docs.exportHover(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("hover exported = " .. tostring(string.find(payload, "game.quest.hover", 1, true) ~= nil))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.exportMarkdown", "Markdown entry")
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_api.md"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_api.md"
    lurek.docs.exportMarkdown(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("markdown exported")
    lurek.log.info("has heading = " .. tostring(string.find(payload, "# API Reference", 1, true) ~= nil))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("game.quest.signature", "Signature payload for a quest action.")
    lurek.docs.setParamInfo("game.quest.signature", {
        { name = "value", type = "number", description = "Quest stage", optional = false },
    })
    local cat = lurek.docs.getCatalog()
    local rel_path = "save/_docs_example_signatures.json"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_signatures.json"
    lurek.docs.exportSignatures(cat, abs_path)
    local payload = lurek.filesystem.read(rel_path)
    lurek.log.info("signatures exported = " .. tostring(string.find(payload, "game.quest.signature", 1, true) ~= nil))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.catalog", "Catalog example entry.")
    local cat = lurek.docs.getCatalog()
    local modules = cat:getModules()
    lurek.log.info("catalog entries = " .. cat:entryCount())
    lurek.log.info("catalog userdata type = " .. cat:type())
    lurek.log.info("module count = " .. #modules)
    lurek.docs.resetCatalog()
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
    local rel_dir = "save/_docs_example_load_all"
    local abs_dir = lurek.filesystem.getSaveDirectory() .. "/_docs_example_load_all"
    lurek.filesystem.createDirectory(rel_dir)
    lurek.filesystem.write(rel_dir .. "/a.toml", [=[[[entries]]
name = "one"
qualifiedName = "lurek.test.one"
module = "test"
kind = "function"
description = "First entry"
]=])
    lurek.filesystem.write(rel_dir .. "/b.toml", [=[[[entries]]
name = "two"
qualifiedName = "lurek.test.two"
module = "test"
kind = "function"
description = "Second entry"
]=])
    local cat = lurek.docs.loadAll(abs_dir)
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
    local rel_path = "save/_docs_example_load_toml.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_example_load_toml.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "play"
qualifiedName = "lurek.audio.play"
module = "audio"
kind = "function"
description = "Plays a sound"
]=])
    local cat = lurek.docs.loadToml(abs_path)
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "demo.batch",
        module = "demo.batch",
    })
    local qr = lurek.docs.quality(cat)
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "demo.batch",
        module = "demo.batch",
    })
    local qr = lurek.docs.qualityModule("demo.batch", cat)
    lurek.log.info("module quality = " .. qr:getOverallScore())
    lurek.log.info("module grade = " .. tostring(qr:getGrade()))
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
    local data = lurek.docs.reflectLive("repl")
    local rows = data.repl or {}
    lurek.log.info("reflect repl type = " .. type(data))
    lurek.log.info("reflected rows = " .. #rows)
    lurek.log.info("first reflected name = " .. tostring(rows[1] and rows[1].name))
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
    local rows = lurek.docs.reflectTable({ foo = 1, bar = "hello" }, "game.quest")
    lurek.log.info("reflected rows = " .. #rows)
    lurek.log.info("first reflected name = " .. tostring(rows[1] and rows[1].name))
    lurek.log.info("first reflected qualified name = " .. tostring(rows[1] and rows[1].qualifiedName))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    lurek.log.info("after reset entries = " .. cat:entryCount())
    lurek.log.info("after reset type = " .. cat:type())
end
```

---

### `lurek.docs.scan`

Reflects the live `lurek` table or a supplied custom table into a callable API catalog.

```lua
lurek.docs.scan(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional scan options with `table`, `namespace` or `name`, and `module` fields; omitted scans live `lurek`. |

**Returns**

| Type | Description |
|------|-------------|
| [LApiCatalog](#lapicatalog) | Catalog populated from the currently registered `lurek` table. |

**Example**

```lua
do
    local cat = lurek.docs.scan({
        table = {
            start = function() end,
            state = "idle",
        },
        namespace = "game.quest",
        module = "quest",
    })
    local entry = cat:getEntry("game.quest.start")
    lurek.log.info("scanned entries = " .. cat:entryCount())
    lurek.log.info("custom entry = " .. tostring(entry and entry:getQualifiedName()))
    lurek.log.info("custom module = " .. tostring(entry and entry:getModule()))
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
    local cat = lurek.docs.scanModule("repl")
    local entries = cat:getEntries("repl")
    lurek.log.info("repl entries = " .. cat:entryCount())
    lurek.log.info("catalog type = " .. cat:type())
    lurek.log.info("first repl entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
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
    local schema = lurek.docs.schema({
        name = { type = "string", required = true },
        age = { type = "number" },
    }, "PlayerSchema")
    local fields = schema:getFields()
    lurek.log.info("schema name = " .. schema:getName())
    lurek.log.info("schema type = " .. schema:type())
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
    local toml = [[
name = "PlayerSchema"
strict = true

[rules.name]
type = "string"
required = true
]]
    local schema = lurek.docs.schemaFromToml(toml)
    lurek.log.info("schema from toml, name = " .. schema:getName())
    lurek.log.info("schema field count = " .. #schema:getFields())
    lurek.log.info("schema type = " .. schema:type())
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.blend", "Blend two demo values.")
    lurek.docs.setParamInfo("lurek.demo.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local params = lurek.docs.getCatalog():getEntry("lurek.demo.blend"):getParameters()
    lurek.log.info("params set = " .. #params)
    lurek.log.info("first param name = " .. tostring(params[1] and params[1].name))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.blend", "Blend two demo values.")
    lurek.docs.setReturnInfo("lurek.demo.blend", {
        { type = "number", description = "Interpolated value" },
    })
    local returns = lurek.docs.getCatalog():getEntry("lurek.demo.blend"):getReturns()
    lurek.log.info("returns set = " .. #returns)
    lurek.log.info("first return type = " .. tostring(returns[1] and returns[1].type))
    lurek.docs.resetCatalog()
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
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local report = lurek.docs.validate(cat)
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
    local cat = lurek.docs.scan({
        table = { fake = function() end },
        namespace = "lurek.repl",
        module = "repl",
    })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("repl missing = " .. report:missingCount())
    lurek.log.info("repl phantom = " .. report:phantomCount())
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    lurek.log.info("entry count = " .. cat:entryCount())
    lurek.log.info("module count = " .. #cat:getModules())
    lurek.log.info("catalog type = " .. cat:type())
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local filtered = cat:filter(function(entry)
        return entry:getName() == "spawn"
    end)
    lurek.log.info("filtered entries = " .. filtered:entryCount())
    lurek.log.info("first filtered entry = " .. tostring(filtered:getEntries()[1] and filtered:getEntries()[1]:getQualifiedName()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entries = cat:getEntries()
    lurek.log.info("entries count = " .. #entries)
    lurek.log.info("first entry = " .. tostring(entries[1] and entries[1]:getQualifiedName()))
    lurek.log.info("catalog type = " .. cat:type())
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry exists = " .. tostring(entry ~= nil))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local modules = cat:getModules()
    lurek.log.info("module count = " .. #modules)
    lurek.log.info("first module = " .. tostring(modules[1]))
    lurek.log.info("catalog entries = " .. cat:entryCount())
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
    local rel_path = "save/_docs_catalog_type_methods.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_catalog_type_methods.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "Thing"
qualifiedName = "lurek.demo.Thing"
module = "demo"
kind = "type"
description = "Demo type"

[[entries]]
name = "tick"
qualifiedName = "lurek.demo.Thing:tick"
module = "demo"
kind = "method"
description = "Tick method"
]=])
    local cat = lurek.docs.loadToml(abs_path)
    local methods = cat:getTypeMethods("lurek.demo.Thing")
    lurek.log.info("method count = " .. #methods)
    lurek.log.info("first method = " .. tostring(methods[1] and methods[1]:getName()))
    lurek.log.info("catalog entries = " .. cat:entryCount())
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
    local rel_path = "save/_docs_catalog_types.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_catalog_types.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"

[[entries]]
name = "Thing"
qualifiedName = "lurek.demo.Thing"
module = "demo"
kind = "type"
description = "Demo type"

[[entries]]
name = "tick"
qualifiedName = "lurek.demo.Thing:tick"
module = "demo"
kind = "method"
description = "Tick method"
]=])
    local types = lurek.docs.loadToml(abs_path):getTypes("demo")
    lurek.log.info("type count = " .. #types)
    lurek.log.info("first type = " .. tostring(types[1]))
    lurek.log.info("second type = " .. tostring(types[2]))
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
    local a = lurek.docs.scan({ table = { spawn = function() end }, namespace = "lurek.demo", module = "demo" })
    local b = lurek.docs.scan({ table = { tick = function() end }, namespace = "lurek.timer", module = "timer" })
    local merged = a:merge(b)
    lurek.log.info("merged entries = " .. merged:entryCount())
    lurek.log.info("merged module count = " .. #merged:getModules())
    lurek.log.info("first merged entry = " .. tostring(merged:getEntries()[1] and merged:getEntries()[1]:getQualifiedName()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end, stop = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local results = cat:search("spawn")
    lurek.log.info("search results = " .. #results)
    lurek.log.info("first result = " .. tostring(results[1] and results[1]:getQualifiedName()))
    lurek.log.info("catalog entries = " .. cat:entryCount())
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local json = cat:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has spawn = " .. tostring(string.find(json, "spawn", 1, true) ~= nil))
    lurek.log.info("catalog entries = " .. cat:entryCount())
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local rows = cat:toTable()
    lurek.log.info("row count = " .. #rows)
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    lurek.log.info("catalog type = " .. cat:type())
    lurek.log.info("catalog modules = " .. tostring(#cat:getModules()))
    lurek.log.info("is catalog = " .. tostring(cat:typeOf("LApiCatalog")))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    lurek.log.info("is catalog = " .. tostring(cat:typeOf("LApiCatalog")))
    lurek.log.info("is entry = " .. tostring(cat:typeOf("LDocEntry")))
    lurek.log.info("catalog type = " .. tostring(cat:type()))
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
    local rel_path = "save/_docs_entry_deprecated.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_deprecated.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
since = "0.1.0"
deprecated = "use lurek.demo.spawnEx"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("entry deprecated = " .. tostring(entry and entry:getDeprecated()))
    lurek.log.info("entry example = " .. tostring(entry and entry:getExample()))
    lurek.log.info("entry since = " .. tostring(entry and entry:getSince()))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn demo entity")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.spawn")
    lurek.log.info("description = " .. tostring(entry and entry:getDescription()))
    lurek.log.info("has description = " .. tostring(entry and entry:hasDescription()))
    lurek.docs.resetCatalog()
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
    local rel_path = "save/_docs_entry_meta.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_meta.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
since = "0.1.0"
deprecated = "use lurek.demo.spawnEx"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("entry example = " .. tostring(entry and entry:getExample()))
    lurek.log.info("entry since = " .. tostring(entry and entry:getSince()))
    lurek.log.info("entry deprecated = " .. tostring(entry and entry:getDeprecated()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn demo entity")
    lurek.docs.setParamInfo("lurek.demo.spawn", {
        { name = "value", type = "number", description = "Spawn count", optional = false },
    })
    local params = lurek.docs.getCatalog():getEntry("lurek.demo.spawn"):getParameters()
    lurek.log.info("param count = " .. #params)
    lurek.log.info("first param = " .. tostring(params[1] and params[1].name))
    lurek.docs.resetCatalog()
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("qualified name = " .. tostring(entry and entry:getQualifiedName()))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
    lurek.log.info("entry module = " .. tostring(entry and entry:getModule()))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.spawn", "Spawn demo entity")
    lurek.docs.setReturnInfo("lurek.demo.spawn", {
        { type = "boolean", description = "True when spawned" },
    })
    local returns = lurek.docs.getCatalog():getEntry("lurek.demo.spawn"):getReturns()
    lurek.log.info("return count = " .. #returns)
    lurek.log.info("first return = " .. tostring(returns[1] and returns[1].type))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.scored", "Has description")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.scored")
    lurek.log.info("entry score = " .. tostring(entry and entry:getScore()))
    lurek.log.info("has description = " .. tostring(entry and entry:hasDescription()))
    lurek.docs.resetCatalog()
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
    local rel_path = "save/_docs_entry_since.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_since.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
since = "0.1.0"
deprecated = "use lurek.demo.spawnEx"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("entry since = " .. tostring(entry and entry:getSince()))
    lurek.log.info("entry example = " .. tostring(entry and entry:getExample()))
    lurek.log.info("entry deprecated = " .. tostring(entry and entry:getDeprecated()))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.described", "Described entry")
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.described")
    lurek.log.info("has description = " .. tostring(entry and entry:hasDescription()))
    lurek.log.info("description = " .. tostring(entry and entry:getDescription()))
    lurek.docs.resetCatalog()
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
    local rel_path = "save/_docs_entry_has_example.toml"
    local abs_path = lurek.filesystem.getSaveDirectory() .. "/_docs_entry_has_example.toml"
    lurek.filesystem.write(rel_path, [=[[[entries]]
name = "spawn"
qualifiedName = "lurek.demo.spawn"
module = "demo"
kind = "function"
description = "Spawn demo entity"
example = "lurek.demo.spawn()"
]=])
    local entry = lurek.docs.loadToml(abs_path):getEntry("lurek.demo.spawn")
    lurek.log.info("has example = " .. tostring(entry and entry:hasExample()))
    lurek.log.info("example text = " .. tostring(entry and entry:getExample()))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.params", "Entry with params")
    lurek.docs.setParamInfo("lurek.demo.params", {
        { name = "value", type = "number", description = "Input value", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.params")
    lurek.log.info("has parameters = " .. tostring(entry and entry:hasParameters()))
    lurek.log.info("param count = " .. tostring(entry and #entry:getParameters() or 0))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.returns", "Entry with returns")
    lurek.docs.setReturnInfo("lurek.demo.returns", {
        { type = "boolean", description = "True when complete" },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.demo.returns")
    lurek.log.info("has return type = " .. tostring(entry and entry:hasReturnType()))
    lurek.log.info("return count = " .. tostring(entry and #entry:getReturns() or 0))
    lurek.docs.resetCatalog()
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
    lurek.log.info("entry kind = " .. tostring(entry and entry:getKind()))
    lurek.log.info("entry name = " .. tostring(entry and entry:getName()))
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
    local cat = lurek.docs.scan({
        table = { spawn = function() end },
        namespace = "lurek.demo",
        module = "demo",
    })
    local entry = cat:getEntry("lurek.demo.spawn")
    lurek.log.info("is entry = " .. tostring(entry and entry:typeOf("LDocEntry")))
    lurek.log.info("is catalog = " .. tostring(entry and entry:typeOf("LApiCatalog")))
    lurek.log.info("entry type = " .. tostring(entry and entry:type()))
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    lurek.docs.describe("lurek.demo.beta", "")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local best = qr:getBest(5)
    lurek.log.info("best count = " .. #best)
    lurek.log.info("first best = " .. tostring(best[1] and best[1]:getQualifiedName()))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    lurek.docs.describe("lurek.demo.beta", "")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local c_entries = qr:getByGrade("C")
    lurek.log.info("grade C entries = " .. #c_entries)
    lurek.log.info("first C entry = " .. tostring(c_entries[1] and c_entries[1]:getQualifiedName()))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("grade = " .. qr:getGrade())
    lurek.log.info("overall score = " .. tostring(qr:getOverallScore()))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local issues = qr:getIssues()
    lurek.log.info("quality issues = " .. #issues)
    lurek.log.info("first issue kind = " .. tostring(issues[1] and issues[1].kind))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local scores = qr:getModuleScores()
    lurek.log.info("module scores type = " .. type(scores))
    lurek.log.info("module score count = " .. tostring(type(scores) == "table" and #scores or 0))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("score = " .. qr:getOverallScore())
    lurek.log.info("grade = " .. tostring(qr:getGrade()))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local summary = qr:getSummary()
    lurek.log.info("summary = " .. summary)
    lurek.log.info("summary length = " .. #summary)
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    lurek.docs.describe("lurek.demo.beta", "")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local worst = qr:getWorst(5)
    lurek.log.info("worst count = " .. #worst)
    lurek.log.info("first worst = " .. tostring(worst[1] and worst[1]:getQualifiedName()))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local issues = qr:getIssues()
    lurek.log.info("quality issue count = " .. qr:issueCount())
    lurek.log.info("issues table size = " .. #issues)
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local json = qr:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has grade = " .. tostring(string.find(json, "grade", 1, true) ~= nil))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    local t = qr:toTable()
    lurek.log.info("overall = " .. tostring(t.overallScore) .. " grade = " .. tostring(t.grade))
    lurek.log.info("module scores type = " .. tostring(type(t.moduleScores)))
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("quality report type = " .. qr:type())
    lurek.log.info("summary length = " .. #qr:getSummary())
    lurek.docs.resetCatalog()
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
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.demo.alpha", "Alpha entry")
    local qr = lurek.docs.quality(lurek.docs.getCatalog())
    lurek.log.info("is quality report = " .. tostring(qr:typeOf("LQualityReport")))
    lurek.log.info("is validation report = " .. tostring(qr:typeOf("LValidationReport")))
    lurek.docs.resetCatalog()
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
    local schema = lurek.docs.schema({ v = { type = "number" } }, "AssertSchema")
    local ok = pcall(function() schema["assert"](schema, { v = 10 }) end)
    lurek.log.info("assert passed = " .. tostring(ok))
    lurek.log.info("schema field count = " .. #schema:getFields())
    lurek.log.info("schema type = " .. schema:type())
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
    local schema = lurek.docs.schema({ x = { type = "number" } }, "CheckSchema")
    lurek.log.info("check = " .. tostring(schema:check({ x = 42 })))
    lurek.log.info("schema name = " .. tostring(schema:getName()))
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
    lurek.log.info("field count = " .. #schema:getFields())
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
    local schema = lurek.docs.schema({ zeta = "string", alpha = { type = "number", required = true } }, "FieldSchema")
    local fields = schema:getFields()
    lurek.log.info("field count = " .. #fields)
    lurek.log.info("first field = " .. tostring(fields[1]))
    lurek.log.info("second field = " .. tostring(fields[2]))
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
    local schema = lurek.docs.schema({ hp = "number" }, "HeroSchema")
    lurek.log.info("schema name = " .. schema:getName())
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
    lurek.log.info("field count = " .. #schema:getFields())
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
    local schema = lurek.docs.schema({ hp = "number" }, "TypeSchema")
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("schema name = " .. schema:getName())
    lurek.log.info("field count = " .. #schema:getFields())
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
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
    local schema = lurek.docs.schema({ hp = "number" }, "TypeOfSchema")
    lurek.log.info("is schema = " .. tostring(schema:typeOf("LSchema")))
    lurek.log.info("is entry = " .. tostring(schema:typeOf("LDocEntry")))
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("schema name = " .. schema:getName())
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
    local schema = lurek.docs.schema({ name = { type = "string", required = true } }, "ValidateSchema")
    local ok, errors = schema:validate({ name = "test" })
    lurek.log.info("valid = " .. tostring(ok) .. " errors = " .. #errors)
    lurek.log.info("schema type = " .. schema:type())
    lurek.log.info("field count = " .. #schema:getFields())
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local incomplete = report:getIncomplete()
    lurek.log.info("incomplete entries = " .. #incomplete)
    lurek.log.info("first incomplete = " .. tostring(incomplete[1] and incomplete[1].qualifiedName))
    lurek.log.info("report type = " .. report:type())
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local missing = report:getMissing()
    lurek.log.info("missing entries = " .. #missing)
    lurek.log.info("first missing = " .. tostring(missing[1] and missing[1].qualifiedName))
    lurek.log.info("report valid = " .. tostring(report:isValid()))
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local phantom = report:getPhantom()
    lurek.log.info("phantom entries = " .. #phantom)
    lurek.log.info("first phantom = " .. tostring(phantom[1] and phantom[1].qualifiedName))
    lurek.log.info("report type = " .. report:type())
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("is valid = " .. tostring(report:isValid()))
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local json = report:toJSON()
    lurek.log.info("json length = " .. #json)
    lurek.log.info("json has missing key = " .. tostring(string.find(json, "missing", 1, true) ~= nil))
    lurek.log.info("report type = " .. report:type())
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    local t = report:toTable()
    lurek.log.info("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
    lurek.log.info("incomplete=" .. #t.incomplete)
    lurek.log.info("report type = " .. report:type())
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("report type = " .. report:type())
    lurek.log.info("missing count = " .. tostring(report:missingCount()))
    lurek.log.info("is validation report = " .. tostring(report:typeOf("LValidationReport")))
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
    local cat = lurek.docs.scan({ table = { fake = function() end }, namespace = "lurek.repl", module = "repl" })
    local report = lurek.docs.validateModule("repl", cat)
    lurek.log.info("is validation report = " .. tostring(report:typeOf("LValidationReport")))
    lurek.log.info("is quality report = " .. tostring(report:typeOf("LQualityReport")))
    lurek.log.info("report type = " .. tostring(report:type()))
end
```

---
