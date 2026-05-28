# Docs

- The `docs` module is an Edge/Integration tier component responsible for maintaining the engine's runtime documentation catalog.

By scanning and reflecting Lua API metadata upon startup, it provides robust, programmatic access to function signatures, parameter descriptions, return types, and usage examples. The foundational structure of this module is the `DocEntry`, which securely encapsulates the canonical details of one documented API item—from its prose description to structured parameter and return metadata. These entries are efficiently stored and aggregated within an in-memory `Catalog`, fully searchable and indexable by namespace path.

A key capability of the module is its rigorous validation and quality-reporting system. By comparing the populated catalog against the live, reflected `lurek` API surface, it accurately generates `ValidationReport` and `QualityReport` structures. These tools score documentation completeness, assign letter grades, and identify missing, phantom, or incomplete entries, ensuring that the engine's documentation quality remains consistently high.

Beyond in-engine diagnostics, the `docs` module drives Lurek2D's IDE integration capabilities. It features specialized export functions capable of generating structured JSON payloads for code completions, hover information, and signature help, ready to be consumed directly by editors like VS Code. Furthermore, the module facilitates schema validation by generating typed config documentation from TOML definitions, serving as an access bridge for the `lurek_schema` crate. The entirety of this robust toolset is accessible via the `lurek.docs.*` namespace, allowing scripts and CI pipelines to autonomously validate API coverage, export artifacts, and maintain documentation hygiene.

## Functions

### `lurek.docs.checkStaleness`

Lists source files in a directory for simple documentation staleness checks.

```lua
-- signature
lurek.docs.checkStaleness(catalog_ud, source_dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog argument accepted for API symmetry with validation helpers. |
| `source_dir` | `string` | Directory scanned for `.rs` and `.lua` source files. |

**Returns**

| Type | Description |
|------|-------------|
| `DocsCheckStalenessResult` | Table with stale, current, and missing arrays. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local result = lurek.docs.checkStaleness(cat, "src/math/")
    print("stale = " .. #result.stale .. " current = " .. #result.current)
end
```

---

### `lurek.docs.coverage`

Returns documented and live API counts for the full `lurek` table.

```lua
-- signature
lurek.docs.coverage(catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud?` | `LApiCatalog` | Optional catalog used for documented entry count. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Number of catalog entries supplied as documented. |
| `number` | b Number of live APIs found by reflection. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local documented, live = lurek.docs.coverage(cat)
    print("documented=" .. documented .. " live=" .. live)
end
```

---

### `lurek.docs.coverageModule`

Returns documented and live API counts for one module.

```lua
-- signature
lurek.docs.coverageModule(module_name, catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | `string` | Module name under the `lurek` table. |
| `catalog_ud?` | `LApiCatalog` | Optional catalog used for documented entry count. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Number of catalog entries for the module. |
| `number` | b Number of live APIs found in the module. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local documented, live = lurek.docs.coverageModule("math", cat)
    print("math documented=" .. documented .. " live=" .. live)
end
```

---

### `lurek.docs.describe`

Adds or updates the description for one editable catalog entry.

```lua
-- signature
lurek.docs.describe(qualified_name, description)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | `string` | Full dotted API name to update or create. |
| `description` | `string` | Description text stored on the catalog entry. |

**Example**

```lua
do
    lurek.docs.describe("lurek.math.lerp", "Linearly interpolates between a and b.")
    print("description set")
end
```

---

### `lurek.docs.exportAll`

Exports all editor documentation artifacts for a catalog into a directory.

```lua
-- signature
lurek.docs.exportAll(catalog_ud, output_dir)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog whose entries are exported. |
| `output_dir` | `string` | Directory that receives all generated artifacts. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    lurek.docs.exportAll(cat, "build/docs/")
    print("all docs exported")
end
```

---

### `lurek.docs.exportCheatsheet`

Writes a compact text cheatsheet from catalog entries.

```lua
-- signature
lurek.docs.exportCheatsheet(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog whose entries are written. |
| `path` | `string` | Output cheatsheet file path. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    lurek.docs.exportCheatsheet(cat, "build/cheatsheet.txt")
    print("cheatsheet exported")
end
```

---

### `lurek.docs.exportCompletions`

Exports catalog completion metadata to a file.

```lua
-- signature
lurek.docs.exportCompletions(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog whose entries are exported. |
| `path` | `string` | Output file path for completion data. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    lurek.docs.exportCompletions(cat, "build/completions.json")
    print("completions exported")
end
```

---

### `lurek.docs.exportHover`

Exports catalog hover metadata to a file.

```lua
-- signature
lurek.docs.exportHover(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog whose entries are exported. |
| `path` | `string` | Output file path for hover data. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    lurek.docs.exportHover(cat, "build/hover.json")
    print("hover exported")
end
```

---

### `lurek.docs.exportMarkdown`

Writes a Markdown API reference from catalog entries.

```lua
-- signature
lurek.docs.exportMarkdown(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog whose entries are written. |
| `path` | `string` | Output Markdown file path. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    lurek.docs.exportMarkdown(cat, "build/api.md")
    print("markdown exported")
end
```

---

### `lurek.docs.exportSignatures`

Exports catalog signature metadata to a file.

```lua
-- signature
lurek.docs.exportSignatures(catalog_ud, path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud` | `LApiCatalog` | Catalog whose entries are exported. |
| `path` | `string` | Output file path for signature data. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    lurek.docs.exportSignatures(cat, "build/signatures.json")
    print("signatures exported")
end
```

---

### `lurek.docs.getCatalog`

Returns the editable in-memory documentation catalog.

```lua
-- signature
lurek.docs.getCatalog()
```

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | Catalog containing entries built by the editing functions. |

**Example**

```lua
do
    local cat = lurek.docs.getCatalog()
    print("catalog entries = " .. cat:entryCount())
end
```

---

### `lurek.docs.loadAll`

Loads all TOML documentation catalog files from a directory and combines their entries.

```lua
-- signature
lurek.docs.loadAll(directory)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `directory` | `string` | Directory scanned for `.toml` catalog files. |

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | Catalog containing entries parsed from every readable TOML file. |

**Example**

```lua
do
    lurek.filesystem.write("save/_fs_tests/docs_load_all_a.toml", '[[entries]]\nname = "one"\nqualifiedName = "lurek.test.one"\nmodule = "test"\nkind = "function"\ndescription = "First entry"')
    lurek.filesystem.write("save/_fs_tests/docs_load_all_b.toml", '[[entries]]\nname = "two"\nqualifiedName = "lurek.test.two"\nmodule = "test"\nkind = "function"\ndescription = "Second entry"')
    local cat = lurek.docs.loadAll("save/_fs_tests/")
    print("all entries = " .. cat:entryCount())
end
```

---

### `lurek.docs.loadToml`

Loads a TOML documentation catalog file and converts its entries into an API catalog.

```lua
-- signature
lurek.docs.loadToml(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to a TOML file containing an `entries` table. |

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | Catalog loaded from the TOML file. |

**Example**

```lua
do
    local path = "save/_fs_tests/docs_load_toml_example.toml"
    lurek.filesystem.write(path, '[[entries]]\nname = "play"\nqualifiedName = "lurek.audio.play"\nmodule = "audio"\nkind = "function"\ndescription = "Plays a sound"')
    local cat = lurek.docs.loadToml(path)
    print("loaded entries = " .. cat:entryCount())
end
```

---

### `lurek.docs.quality`

Computes documentation quality for a supplied catalog or the editable in-memory catalog.

```lua
-- signature
lurek.docs.quality(catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud?` | `LApiCatalog` | Optional catalog to score; omitted scores the editable catalog. |

**Returns**

| Type | Description |
|------|-------------|
| `LQualityReport` | Quality report with overall and module-level scores. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("quality score = " .. qr:getOverallScore())
end
```

---

### `lurek.docs.qualityModule`

Computes documentation quality for entries belonging to one module.

```lua
-- signature
lurek.docs.qualityModule(module_name, catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | `string` | Module name used to filter entries before scoring. |
| `catalog_ud?` | `LApiCatalog` | Optional catalog to score; omitted scores the editable catalog. |

**Returns**

| Type | Description |
|------|-------------|
| `LQualityReport` | Quality report for the filtered module entries. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.qualityModule("math", cat)
    print("math quality = " .. qr:getOverallScore())
end
```

---

### `lurek.docs.reflectLive`

Reflects live `lurek` module tables into plain name and type rows.

```lua
-- signature
lurek.docs.reflectLive(ns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ns?` | `string` | Optional module name to reflect; omitted reflects every table-valued module. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Reflection table keyed by module name or containing the requested module entry. |

**Example**

```lua
do
    local data = lurek.docs.reflectLive("math")
    print("reflect math type = " .. type(data))
end
```

---

### `lurek.docs.reflectTable`

Reflects an arbitrary Lua table into name, qualifiedName, and type rows.

```lua
-- signature
lurek.docs.reflectTable(tbl, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tbl` | `table` | Lua table to inspect without recursion. |
| `name?` | `string` | Optional prefix used to build qualifiedName values. |

**Returns**

| Type | Description |
|------|-------------|
| `DocsReflectTableResult` | Array table of reflected item rows. |

**Example**

```lua
do
    local t = {foo = 1, bar = "hello"}
    local rows = lurek.docs.reflectTable(t, "mymod")
    print("reflected rows = " .. #rows)
end
```

---

### `lurek.docs.resetCatalog`

Clears the editable in-memory documentation catalog.

```lua
-- signature
lurek.docs.resetCatalog()
```

**Example**

```lua
do
    lurek.docs.describe("lurek.test.temp", "Temporary entry")
    lurek.docs.resetCatalog()
    local cat = lurek.docs.getCatalog()
    print("after reset entries = " .. cat:entryCount())
end
```

---

### `lurek.docs.scan`

Reflects the live `lurek` table and builds a catalog of callable APIs.

```lua
-- signature
lurek.docs.scan(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Optional scan options table reserved for future filters. |

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | Catalog populated from the currently registered `lurek` table. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    print("scanned entries = " .. cat:entryCount())
end
```

---

### `lurek.docs.scanModule`

Reflects one live `lurek.<module>` table and builds a catalog for that module.

```lua
-- signature
lurek.docs.scanModule(module_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | `string` | Module name under the `lurek` table. |

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | Catalog populated from the live module table. |

**Example**

```lua
do
    local cat = lurek.docs.scanModule("math")
    print("math entries = " .. cat:entryCount())
end
```

---

### `lurek.docs.schema`

Builds a schema validator from Lua table rules.

```lua
-- signature
lurek.docs.schema(rules, name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `rules` | `table` | Rule table keyed by field name; `__strict` enables strict validation. |
| `name?` | `string` | Optional schema name; defaults to `schema`. |

**Returns**

| Type | Description |
|------|-------------|
| `LSchema` | Schema handle that can validate Lua tables. |

**Example**

```lua
do
    local s = lurek.docs.schema({ name = { type = "string", required = true }, age = { type = "number" } }, "PlayerSchema")
    print("schema name = " .. s:getName())
end
```

---

### `lurek.docs.schemaFromToml`

Builds a schema validator from TOML schema text.

```lua
-- signature
lurek.docs.schemaFromToml(toml_text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `toml_text` | `string` | TOML text parsed by the docs schema backend. |

**Returns**

| Type | Description |
|------|-------------|
| `LSchema` | Schema handle parsed from the TOML text. |

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
    local s = lurek.docs.schemaFromToml(toml)
    print("schema from toml, name = " .. s:getName())
end
```

---

### `lurek.docs.setParamInfo`

Replaces parameter metadata for one editable catalog entry.

```lua
-- signature
lurek.docs.setParamInfo(qualified_name, params)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | `string` | Full dotted API name whose parameters are updated. |
| `params` | `table` | Array table of parameter rows with name, type, description, optional, and optional default fields. |

**Example**

```lua
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setParamInfo("lurek.test.blend", {
        { name = "t", type = "number", description = "Interpolation factor", optional = false },
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    print("params set = " .. #entry:getParameters())
end
```

---

### `lurek.docs.setReturnInfo`

Replaces return-value metadata for one editable catalog entry.

```lua
-- signature
lurek.docs.setReturnInfo(qualified_name, returns)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | `string` | Full dotted API name whose return metadata is updated. |
| `returns` | `table` | Array table of return rows with type and description fields. |

**Example**

```lua
do
    lurek.docs.resetCatalog()
    lurek.docs.describe("lurek.test.blend", "Blend two values.")
    lurek.docs.setReturnInfo("lurek.test.blend", {
        {type = "number", description = "Interpolated value"},
    })
    local entry = lurek.docs.getCatalog():getEntry("lurek.test.blend")
    print("returns set = " .. #entry:getReturns())
end
```

---

### `lurek.docs.validate`

Compares a documentation catalog with the live reflected `lurek` API table.

```lua
-- signature
lurek.docs.validate(catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `catalog_ud?` | `LApiCatalog` | Optional catalog to validate against live reflection; omitted validates an empty catalog. |

**Returns**

| Type | Description |
|------|-------------|
| `LValidationReport` | Report containing missing, phantom, and incomplete API names. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("valid = " .. tostring(report:isValid()))
end
```

---

### `lurek.docs.validateModule`

Compares one module's documentation catalog entries with the live reflected module table.

```lua
-- signature
lurek.docs.validateModule(module_name, catalog_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | `string` | Module name under the `lurek` table. |
| `catalog_ud?` | `LApiCatalog` | Optional catalog whose entries are filtered to the module. |

**Returns**

| Type | Description |
|------|-------------|
| `LValidationReport` | Report containing missing, phantom, and incomplete API names for the module. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validateModule("math", cat)
    print("math missing = " .. report:missingCount())
end
```

---

## LApiCatalog

### `LApiCatalog:entryCount`

Counts entries in the catalog, optionally for one module.

```lua
-- signature
LApiCatalog:entryCount(module)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module?` | `string` | Optional module name used to limit the count. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Number of matching entries. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local total = cat:entryCount()
    local math_count = cat:entryCount("math")
    print("total=" .. total .. " math=" .. math_count)
end
```

---

### `LApiCatalog:filter`

Builds a new catalog containing entries accepted by a Lua predicate.

```lua
-- signature
LApiCatalog:filter(predicate)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `predicate` | `function` | Callback called with each `LDocEntry`; truthy return keeps the entry. |

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | New catalog containing only entries accepted by the predicate. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local fns = cat:filter(function(entry) return entry:getKind() == "function" end)
    print("functions = " .. fns:entryCount())
end
```

---

### `LApiCatalog:getEntries`

Returns catalog entries, optionally limited to one module.

```lua
-- signature
LApiCatalog:getEntries(module)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module?` | `string` | Optional module name used to filter entries. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry[]` | `LDocEntry` handles. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local all = cat:getEntries()
    local math_entries = cat:getEntries("math")
    print("all=" .. #all .. " math=" .. #math_entries)
end
```

---

### `LApiCatalog:getEntry`

Returns one catalog entry by qualified API name.

```lua
-- signature
LApiCatalog:getEntry(qualified_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | `string` | Full dotted API name to find. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry` | The matching catalog entry. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    print("found entry = " .. tostring(cat:getEntry("lurek.math.lerp") ~= nil))
end
```

---

### `LApiCatalog:getModules`

Returns every module represented in this catalog.

```lua
-- signature
LApiCatalog:getModules()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Sorted array table of module names. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local modules = cat:getModules()
    print("modules = " .. #modules)
end
```

---

### `LApiCatalog:getTypeMethods`

Returns method entries associated with a qualified type name.

```lua
-- signature
LApiCatalog:getTypeMethods(qualified_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `qualified_name` | `string` | Qualified type name used as the method prefix. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry[]` | `LDocEntry` method entries. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local methods = cat:getTypeMethods("LVec2")
    print("LVec2 methods = " .. #methods)
end
```

---

### `LApiCatalog:getTypes`

Returns type names documented for one module.

```lua
-- signature
LApiCatalog:getTypes(module_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `module_name` | `string` | Module name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Documented type names. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local types = cat:getTypes("math")
    print("math types = " .. #types)
end
```

---

### `LApiCatalog:merge`

Merges another catalog into this catalog and returns a new catalog value.

```lua
-- signature
LApiCatalog:merge(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | `LApiCatalog` | Catalog whose entries replace matching qualified names or append new entries. |

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalog` | New catalog containing merged entries. |

**Example**

```lua
do
    local a = lurek.docs.scanModule("math")
    local b = lurek.docs.scanModule("timer")
    local merged = a:merge(b)
    print("merged = " .. merged:entryCount())
end
```

---

### `LApiCatalog:search`

Searches names, qualified names, and descriptions with a case-insensitive substring query.

```lua
-- signature
LApiCatalog:search(query)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `query` | `string` | Search text matched against catalog metadata. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry[]` | Matching `LDocEntry` handles. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local results = cat:search("lerp")
    print("search results = " .. #results)
end
```

---

### `LApiCatalog:toJSON`

Serializes this catalog to formatted JSON.

```lua
-- signature
LApiCatalog:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Pretty-printed JSON array of catalog entries. |

**Example**

```lua
do
    local cat = lurek.docs.scanModule("timer")
    local json = cat:toJSON()
    print("json length = " .. #json)
end
```

---

### `LApiCatalog:toTable`

Converts this catalog into plain Lua tables for lightweight inspection.

```lua
-- signature
LApiCatalog:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `LApiCatalogToTableResult` | Array of rows with name, qualifiedName, module, kind, description, and score fields. |

**Example**

```lua
do
    local cat = lurek.docs.scanModule("math")
    local rows = cat:toTable()
    print("rows = " .. #rows)
end
```

---

### `LApiCatalog:type`

Returns the Lua-visible type name for this API catalog handle.

```lua
-- signature
LApiCatalog:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LApiCatalog`. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    print("type = " .. cat:type())
end
```

---

### `LApiCatalog:typeOf`

Returns whether this API catalog handle matches a supported type name.

```lua
-- signature
LApiCatalog:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LApiCatalog` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    print("is LApiCatalog = " .. tostring(cat:typeOf("LApiCatalog")))
end
```

---

## LDocEntry

### `LDocEntry:getDeprecated`

Returns this entry's deprecation text when one was recorded.

```lua
-- signature
LDocEntry:getDeprecated()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Deprecation string, or nil when the entry is not marked deprecated. |

**Example**

```lua
do
    local deprecated = lurek.docs.scan():getEntry("lurek.math.lerp"):getDeprecated()
    print("deprecated = " .. type(deprecated))
end
```

---

### `LDocEntry:getDescription`

Returns the prose description recorded for this entry.

```lua
-- signature
LDocEntry:getDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Documentation description text. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("desc len = " .. #entry:getDescription())
end
```

---

### `LDocEntry:getExample`

Returns this entry's example text when one was recorded.

```lua
-- signature
LDocEntry:getExample()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Example string, or nil when no example exists. |

**Example**

```lua
do
    local example = lurek.docs.scan():getEntry("lurek.math.lerp"):getExample()
    print("example = " .. type(example))
end
```

---

### `LDocEntry:getKind`

Returns the documentation kind recorded for this entry.

```lua
-- signature
LDocEntry:getKind()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Entry kind such as `function`, `method`, `type`, or `value`. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("kind = " .. entry:getKind())
end
```

---

### `LDocEntry:getModule`

Returns the module name associated with this documentation entry.

```lua
-- signature
LDocEntry:getModule()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Module name. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("module = " .. entry:getModule())
end
```

---

### `LDocEntry:getName`

Returns the short API name stored by this documentation entry.

```lua
-- signature
LDocEntry:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Entry name without module prefix. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("name = " .. entry:getName())
end
```

---

### `LDocEntry:getParameters`

Returns parameter metadata recorded for this entry.

```lua
-- signature
LDocEntry:getParameters()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntryGetParametersResult` | Array of parameter rows with name, type, description, optional, and optional default fields. |

**Example**

```lua
do
    local params = lurek.docs.scan():getEntry("lurek.math.lerp"):getParameters()
    print("params = " .. #params)
end
```

---

### `LDocEntry:getQualifiedName`

Returns the full dotted API name stored by this documentation entry.

```lua
-- signature
LDocEntry:getQualifiedName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Qualified API name. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("qualified = " .. entry:getQualifiedName())
end
```

---

### `LDocEntry:getReturns`

Returns return-value metadata recorded for this entry.

```lua
-- signature
LDocEntry:getReturns()
```

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntryGetReturnsResult` | Array table of return rows with type and description fields. |

**Example**

```lua
do
    local returns = lurek.docs.scan():getEntry("lurek.math.lerp"):getReturns()
    print("returns = " .. #returns)
end
```

---

### `LDocEntry:getScore`

Returns the documentation quality score calculated for this entry.

```lua
-- signature
LDocEntry:getScore()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Quality score in the range used by the docs scoring backend. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("score = " .. entry:getScore())
end
```

---

### `LDocEntry:getSince`

Returns this entry's since-version text when one was recorded.

```lua
-- signature
LDocEntry:getSince()
```

**Returns**

| Type | Description |
|------|-------------|
| `LuaValue` | Since-version string, or nil when no value exists. |

**Example**

```lua
do
    local since = lurek.docs.scan():getEntry("lurek.math.lerp"):getSince()
    print("since = " .. type(since))
end
```

---

### `LDocEntry:hasDescription`

Returns whether this entry has non-empty description text.

```lua
-- signature
LDocEntry:hasDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the description is present. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("hasDesc = " .. tostring(entry:hasDescription()))
end
```

---

### `LDocEntry:hasExample`

Returns whether this entry has example text.

```lua
-- signature
LDocEntry:hasExample()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when an example is recorded. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("hasExample = " .. tostring(entry:hasExample()))
end
```

---

### `LDocEntry:hasParameters`

Returns whether this entry has parameter metadata.

```lua
-- signature
LDocEntry:hasParameters()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when at least one parameter is recorded. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("hasParams = " .. tostring(entry:hasParameters()))
end
```

---

### `LDocEntry:hasReturnType`

Returns whether this entry has return-value metadata.

```lua
-- signature
LDocEntry:hasReturnType()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when at least one return row is recorded. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("hasReturn = " .. tostring(entry:hasReturnType()))
end
```

---

### `LDocEntry:type`

Returns the Lua-visible type name for this documentation entry handle.

```lua
-- signature
LDocEntry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LDocEntry`. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("type = " .. entry:type())
end
```

---

### `LDocEntry:typeOf`

Returns whether this documentation entry handle matches a supported type name.

```lua
-- signature
LDocEntry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LDocEntry` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local entry = lurek.docs.scan():getEntry("lurek.math.lerp")
    print("is LDocEntry = " .. tostring(entry:typeOf("LDocEntry")))
end
```

---

## LQualityReport

### `LQualityReport:getBest`

Returns the highest-scoring documentation entries.

```lua
-- signature
LQualityReport:getBest(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | `number` | Optional maximum number of entries to return; defaults to 10. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry[]` | Best-scoring `LDocEntry` handles. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local best = qr:getBest(5)
    print("best 5 = " .. #best)
end
```

---

### `LQualityReport:getByGrade`

Returns documentation entries whose calculated grade matches a grade string.

```lua
-- signature
LQualityReport:getByGrade(grade)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grade` | `string` | Grade string produced by the docs quality backend. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry[]` | Matching `LDocEntry` handles. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local a_entries = qr:getByGrade("A")
    print("grade A entries = " .. #a_entries)
end
```

---

### `LQualityReport:getGrade`

Returns the letter grade derived from the aggregate documentation score.

```lua
-- signature
LQualityReport:getGrade()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Quality grade text. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("grade = " .. qr:getGrade())
end
```

---

### `LQualityReport:getModuleScores`

Returns per-module documentation quality scores.

```lua
-- signature
LQualityReport:getModuleScores()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Map table keyed by module name with numeric scores. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local scores = qr:getModuleScores()
    print("module scores type = " .. type(scores))
end
```

---

### `LQualityReport:getOverallScore`

Returns the aggregate documentation quality score.

```lua
-- signature
LQualityReport:getOverallScore()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Overall score in the range used by the docs scoring backend. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("score = " .. qr:getOverallScore())
end
```

---

### `LQualityReport:getSummary`

Returns a human-readable summary of overall and per-module quality scores.

```lua
-- signature
LQualityReport:getSummary()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Multiline quality summary text. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("summary = " .. qr:getSummary())
end
```

---

### `LQualityReport:getWorst`

Returns the lowest-scoring documentation entries.

```lua
-- signature
LQualityReport:getWorst(count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `count?` | `number` | Optional maximum number of entries to return; defaults to 10. |

**Returns**

| Type | Description |
|------|-------------|
| `LDocEntry[]` | Worst-scoring `LDocEntry` handles. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local worst = qr:getWorst(5)
    print("worst 5 = " .. #worst)
end
```

---

### `LQualityReport:toJSON`

Serializes this quality report to formatted JSON.

```lua
-- signature
LQualityReport:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Pretty-printed JSON object for the quality report. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local json = qr:toJSON()
    print("json length = " .. #json)
end
```

---

### `LQualityReport:toTable`

Converts this quality report into a plain Lua table.

```lua
-- signature
LQualityReport:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `LQualityReportToTableResult` | Table with overallScore, grade, and moduleScores fields. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    local t = qr:toTable()
    print("overall = " .. t.overallScore .. " grade = " .. t.grade)
end
```

---

### `LQualityReport:type`

Returns the Lua-visible type name for this quality report handle.

```lua
-- signature
LQualityReport:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LQualityReport`. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("type = " .. qr:type())
end
```

---

### `LQualityReport:typeOf`

Returns whether this quality report handle matches a supported type name.

```lua
-- signature
LQualityReport:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LQualityReport` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local qr = lurek.docs.quality(cat)
    print("is report = " .. tostring(qr:typeOf("LQualityReport")))
end
```

---

## LSchema

### `LSchema:assert`

Validates a Lua table and raises a Lua error when schema checks fail.

```lua
-- signature
LSchema:assert(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | Table whose fields are checked against this schema. |

**Example**

```lua
do
    local s = lurek.docs.schema({v = {type = "number"}})
    local ok = pcall(function() s["assert"](s, {v = 10}) end)
    print("assert passed = " .. tostring(ok))
end
```

---

### `LSchema:check`

Validates a Lua table and returns only the boolean result.

```lua
-- signature
LSchema:check(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | Table whose fields are checked against this schema. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the table satisfies the schema rules. |

**Example**

```lua
do
    local s = lurek.docs.schema({x = {type = "number"}})
    print("check = " .. tostring(s:check({x = 42})))
end
```

---

### `LSchema:getFields`

Returns the field names declared by this schema.

```lua
-- signature
LSchema:getFields()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Sorted array table of field names. |

**Example**

```lua
do
    local s = lurek.docs.schema({a = {type = "number"}, b = {type = "string"}})
    local fields = s:getFields()
    print("fields = " .. #fields)
end
```

---

### `LSchema:getName`

Returns this schema's display name.

```lua
-- signature
LSchema:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Schema name. |

**Example**

```lua
do
    local s = lurek.docs.schema({}, "TestSchema")
    print("name = " .. s:getName())
end
```

---

### `LSchema:type`

Returns the Lua-visible type name for this schema handle.

```lua
-- signature
LSchema:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LSchema`. |

**Example**

```lua
do
    local s = lurek.docs.schema({})
    print("type = " .. s:type())
end
```

---

### `LSchema:typeOf`

Returns whether this schema handle matches a supported type name.

```lua
-- signature
LSchema:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LSchema` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local s = lurek.docs.schema({})
    print("is LSchema = " .. tostring(s:typeOf("LSchema")))
end
```

---

### `LSchema:validate`

Validates a Lua table and returns a success flag plus structured error rows.

```lua
-- signature
LSchema:validate(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | Table whose fields are checked against this schema. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True when every provided field satisfies the schema rules. |
| `LSchemaValidateResult` | b Array table of validation errors with field and message fields. |

**Example**

```lua
do
    local s = lurek.docs.schema({name = {type = "string", required = true}})
    local ok, errors = s:validate({name = "test"})
    print("valid = " .. tostring(ok) .. " errors = " .. #errors)
end
```

---

## LValidationReport

### `LValidationReport:getIncomplete`

Returns catalog APIs whose documentation was incomplete.

```lua
-- signature
LValidationReport:getIncomplete()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Incomplete qualified names. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local incomplete = report:getIncomplete()
    print("incomplete = " .. #incomplete)
end
```

---

### `LValidationReport:getMissing`

Returns live APIs that were missing from the checked catalog.

```lua
-- signature
LValidationReport:getMissing()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Missing qualified names. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local missing = report:getMissing()
    print("missing = " .. #missing)
end
```

---

### `LValidationReport:getPhantom`

Returns catalog APIs that were not present in the live Lua table.

```lua
-- signature
LValidationReport:getPhantom()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Phantom qualified names. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local phantom = report:getPhantom()
    print("phantom = " .. #phantom)
end
```

---

### `LValidationReport:getSummary`

Returns a compact text summary of missing, phantom, and incomplete counts.

```lua
-- signature
LValidationReport:getSummary()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Human-readable validation summary. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("summary = " .. report:getSummary())
end
```

---

### `LValidationReport:incompleteCount`

Returns the number of catalog APIs with incomplete documentation.

```lua
-- signature
LValidationReport:incompleteCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Incomplete API count. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("incomplete count = " .. report:incompleteCount())
end
```

---

### `LValidationReport:isValid`

Returns whether the validation report has no missing live APIs.

```lua
-- signature
LValidationReport:isValid()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when no live APIs are missing from the catalog. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("valid = " .. tostring(report:isValid()))
end
```

---

### `LValidationReport:missingCount`

Returns the number of live APIs missing from the catalog.

```lua
-- signature
LValidationReport:missingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Missing API count. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("missing count = " .. report:missingCount())
end
```

---

### `LValidationReport:phantomCount`

Returns the number of catalog APIs absent from live reflection.

```lua
-- signature
LValidationReport:phantomCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Phantom API count. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("phantom count = " .. report:phantomCount())
end
```

---

### `LValidationReport:toJSON`

Serializes this validation report to formatted JSON.

```lua
-- signature
LValidationReport:toJSON()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Pretty-printed JSON object for the report. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local json = report:toJSON()
    print("json length = " .. #json)
end
```

---

### `LValidationReport:toTable`

Converts this validation report into a plain Lua table.

```lua
-- signature
LValidationReport:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| `LValidationReportToTableResult` | Table with missing, phantom, and incomplete array fields. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    local t = report:toTable()
    print("table keys: missing=" .. #t.missing .. " phantom=" .. #t.phantom)
end
```

---

### `LValidationReport:type`

Returns the Lua-visible type name for this validation report handle.

```lua
-- signature
LValidationReport:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LValidationReport`. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("type = " .. report:type())
end
```

---

### `LValidationReport:typeOf`

Returns whether this validation report handle matches a supported type name.

```lua
-- signature
LValidationReport:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LValidationReport` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local cat = lurek.docs.scan()
    local report = lurek.docs.validate(cat)
    print("is report = " .. tostring(report:typeOf("LValidationReport")))
end
```

---
