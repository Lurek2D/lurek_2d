# Serialize

## Purpose

Translates JSON, TOML, CSV, XML, INI, and MessagePack via one intermediate tree and validates neutral ChangeSet envelopes. - Validates data against schemas. - Enforces bounded decode, encode, and Lua-conversion limits for depth, nodes, strings, rows, and input size.

## Summary

- The `serialize` module is the format-translation surface for users who want several external data formats to map into one shared runtime value model.
- JSON, TOML, CSV, XML, INI, MessagePack, schemas, and codec entrypoints all matter here because a project often needs to move content between several representations without rewriting conversion logic each time.
- The module is useful both for loading or saving data and for validating whether translated data actually fits an expected structure.
- Its shared intermediate tree is the key user-facing idea: several formats can participate in the same workflows because they resolve into one normalized serial representation.
- That normalized representation is what makes cross-format tooling practical. Validators, exporters, migration steps, and transforms can reason about one value model instead of reimplementing logic for every source format.
- That also makes migrations easier to reason about.
- Safety is part of the contract. Lua conversion, autodetection, CSV parsing, and MessagePack decode must stay bounded and reject cyclic or non-finite inputs instead of recursing or allocating without policy.
- Read `serialize` as the normalization layer for structured data moving between external formats and engine-facing workflows.
- `encodeChangeSet()` and `decodeChangeSet()` are schema-light transport helpers. They validate the stable `schema`, `revision`, and ordered `{objectId, component, operation, payload}` records, then delegate actual encoding to the existing codec front door.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.serialize.applyDefaults`

Merges a schema's default values into a data table, filling in any missing fields without overwriting existing ones. Use this to ensure game config or save data always has complete fields even when the user provides only partial overrides.

```lua
lurek.serialize.applyDefaults(value, schema)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The data value that may have missing fields. |
| `schema` | table | A schema table containing `default` entries for fields. |

**Returns**

| Type | Description |
|------|-------------|
| table | A new table with defaults applied for any absent fields. |

**Example**

```lua
do
    local schema = { fields = { width = { default = 800 }, height = { default = 600 }, title = { default = "Untitled" } } }
    local filled = lurek.serialize.applyDefaults({ width = 1280 }, schema)
    lurek.log.info("width = " .. filled.width)
    lurek.log.info("height = " .. filled.height)
    lurek.log.info("title = " .. filled.title)
end
```

---

### `lurek.serialize.decode`

Universal decoder that parses a string payload into a Lua table using the specified format. If no format is given, auto-detects from the content. Supports JSON, TOML, CSV, XML, INI, and MessagePack. Use this as a single entry point when handling files of varying or unknown formats.

```lua
lurek.serialize.decode(payload, format, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `payload` | string | The raw string (or binary for msgpack) to decode. |
| `format?` | string | Format hint: "json", "toml", "csv", "xml", "ini", or "msgpack". Nil triggers auto-detection. |
| `opts?` | table | Optional settings table. For CSV: `delimiter` (string) and `has_headers` (boolean). |

**Returns**

| Type | Description |
|------|-------------|
| table | The decoded Lua table. |

**Example**

```lua
do
    local jsonPayload = '{"auto": true, "score": 99}'
    local result = lurek.serialize.decode(jsonPayload)
    local bytes = lurek.serialize.encodeMsgPack({ hp = 10, mana = 4 })
    local stats = lurek.serialize.decode(bytes, "msgpack")
    lurek.log.info("auto-detected json score = " .. result.score)
    lurek.log.info("decoded msgpack stats hp=" .. stats.hp .. " mana=" .. stats.mana)
end
```

---

### `lurek.serialize.decodeChangeSet`

Decodes and validates a ChangeSet transport payload into a Lua table.

```lua
lurek.serialize.decodeChangeSet(payload, format, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `payload` | string | Text or MessagePack ChangeSet payload. |
| `format?` | string | Format hint; omit for text auto-detection. |
| `opts?` | table | Standard decoder options and limits. |

**Returns**

| Type | Description |
|------|-------------|
| table | Validated ChangeSet table. |

**Example**

```lua
do
    local encoded = lurek.serialize.encode({ schema = "save.v1", revision = 1, changes = {
        { objectId = 2, component = "alive", operation = "set", payload = true },
    } }, "json")
    local changes = lurek.serialize.decodeChangeSet(encoded, "json")
    local row = changes.changes[1]
    lurek.log.info("decoded schema=" .. changes.schema .. " object=" .. row.objectId .. " payload=" .. tostring(row.payload))
end
```

---

### `lurek.serialize.decodeMsgPack`

Decodes a binary MessagePack string back into a Lua table. Use this to read save files, network packets, or any data previously encoded with encodeMsgPack.

```lua
lurek.serialize.decodeMsgPack(bytes)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bytes` | string | A binary string containing valid MessagePack data. |

**Returns**

| Type | Description |
|------|-------------|
| table | The decoded Lua table from the MessagePack payload. |

**Example**

```lua
do
    local bytes = lurek.serialize.encodeMsgPack({ x = 1, y = 2, room = "spawn" })
    local decoded = lurek.serialize.decodeMsgPack(bytes)
    local room = decoded.room
    local sum = decoded.x + decoded.y
    lurek.log.info("spawn room = " .. room)
    lurek.log.info("decoded coordinates = " .. decoded.x .. "," .. decoded.y .. " sum=" .. sum)
end
```

---

### `lurek.serialize.decodeXml`

Parses an XML string into a Lua table structure. Elements become nested tables with tag names as keys. Useful for loading Tiled map exports, SVG data, UI layout definitions, or other XML-based game assets.

```lua
lurek.serialize.decodeXml(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | A valid XML string to parse. |

**Returns**

| Type | Description |
|------|-------------|
| table | A nested Lua table representing the XML document structure. |

**Example**

```lua
do
    local doc = lurek.serialize.decodeXml('<tilemap width="32"><layer name="ground">solid</layer></tilemap>')
    local root_tag = doc.tag or doc.name or "unknown"
    local first_layer = doc.children and doc.children[1] or {}
    local layer_name = first_layer.attrs and first_layer.attrs.name or "missing"
    lurek.log.info("xml root = " .. root_tag .. " width=" .. tostring(doc.attrs.width))
    lurek.log.info("first layer = " .. layer_name .. " text=" .. tostring(first_layer.text))
end
```

---

### `lurek.serialize.detectFormat`

Attempts to auto-detect the serialization format of a string by inspecting its content (e.g., leading `{` for JSON, `[section]` for INI, XML declaration for XML). Returns the format name or nil if detection fails. Useful for loading user-provided files where the format is unknown.

```lua
lurek.serialize.detectFormat(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The raw text content to analyze. |

**Returns**

| Type | Description |
|------|-------------|
| string | The detected format name ("json", "toml", "csv", "xml", "ini"), or nil if unrecognized. |

**Example**

```lua
do
    local json_format = lurek.serialize.detectFormat('{"key":"value"}')
    local ini_format = lurek.serialize.detectFormat("[video]\nvsync=true\n")
    local unknown_format = lurek.serialize.detectFormat("spawn goblin at x=4")
    local knows_unknown = unknown_format == nil
    lurek.log.info("detected formats: json=" .. tostring(json_format) .. ", ini=" .. tostring(ini_format))
    lurek.log.info("plain designer note unresolved = " .. tostring(knows_unknown))
end
```

---

### `lurek.serialize.encode`

Universal encoder that serializes a Lua value into the specified format. Supports JSON, TOML, CSV, and MessagePack. Returns a string (text for JSON/TOML/CSV, binary for MessagePack). Use this as a single entry point for all serialization needs.

```lua
lurek.serialize.encode(value, format, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The Lua value to encode. |
| `format` | string | Target format: "json", "toml", "csv", or "msgpack". |
| `opts?` | table | Optional settings table. For JSON: `pretty` (boolean). For CSV: `delimiter` (string) and `has_headers` (boolean). |

**Returns**

| Type | Description |
|------|-------------|
| string | The encoded string (text or binary depending on format). |

**Example**

```lua
do
    local quest_state = { quest = "intro", count = 42, completed = false }
    local jsonOut = lurek.serialize.encode(quest_state, "json", { pretty = true })
    local restored = lurek.serialize.decode(jsonOut, "json")
    local detected = lurek.serialize.detectFormat(jsonOut)
    lurek.log.info("encoded quest payload as " .. tostring(detected))
    lurek.log.info("quest=" .. restored.quest .. " count=" .. restored.count)
end
```

---

### `lurek.serialize.encodeChangeSet`

Encodes a validated `lurek.event` ChangeSet table for save or network transport.

```lua
lurek.serialize.encodeChangeSet(value, format, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | table | Table returned by `[LChangeSet](event.md#lchangeset):toTable()`. |
| `format` | string | Target format: `json`, `toml`, or `msgpack`. |
| `opts?` | table | Standard encoder options such as `pretty` and limits. |

**Returns**

| Type | Description |
|------|-------------|
| string | Encoded ChangeSet payload. |

**Example**

```lua
do
    local changes = { schema = "network.v1", revision = 4, changes = {
        { objectId = 9, component = "position", operation = "set", payload = { x = 12, y = 5 } },
    } }
    local encoded = lurek.serialize.encodeChangeSet(changes, "json", { pretty = true })
    local decoded = lurek.serialize.decodeChangeSet(encoded, "json")
    lurek.log.info("changeset bytes=" .. #encoded .. " schema=" .. decoded.schema .. " rows=" .. #decoded.changes)
end
```

---

### `lurek.serialize.encodeMsgPack`

Encodes a Lua table into a compact binary MessagePack string. MessagePack is faster and smaller than JSON, making it ideal for save files, network packets, or any scenario where performance matters more than human readability. The argument must be a table.

```lua
lurek.serialize.encodeMsgPack(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | table | The Lua table to encode. Must be a table (not a primitive). |

**Returns**

| Type | Description |
|------|-------------|
| string | A binary string containing the MessagePack-encoded data. |

**Example**

```lua
do
    local snapshot = { version = 2, entities = { { id = 1, hp = 100, x = 16, y = 24 } } }
    local packed = lurek.serialize.encodeMsgPack(snapshot)
    local unpacked = lurek.serialize.decodeMsgPack(packed)
    local first = unpacked.entities[1]
    local position = first.x .. "," .. first.y
    lurek.log.info("msgpack snapshot version = " .. unpacked.version)
    lurek.log.info("entity #" .. first.id .. " hp=" .. first.hp .. " pos=" .. position)
end
```

---

### `lurek.serialize.fromCsv`

Parses a CSV string into a Lua table (array of rows). Each row is either a keyed table (when headers are present) or an indexed array of field values. Useful for loading spreadsheet exports, leaderboard data, or tabular game data.

```lua
lurek.serialize.fromCsv(text, delimiter, hasHeaders)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | The CSV content to parse. |
| `delimiter?` | string | Single-character field delimiter. Defaults to comma (","). |
| `hasHeaders?` | boolean | When true, the first row is treated as column names and each data row becomes a keyed table. Defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| table | An array of row tables containing the parsed CSV data. |

**Example**

```lua
do
    local csvWithHeaders = "name,age,city\nAlice,30,Warsaw\nBob,25,Krakow\nCarol,35,Gdansk"
    local rows = lurek.serialize.fromCsv(csvWithHeaders, ",", true)
    lurek.log.info("rows with headers = " .. #rows)
    lurek.log.info("first row name = " .. rows[1].name)
    lurek.log.info("second row city = " .. rows[2].city)
end
```

---

### `lurek.serialize.fromIni`

Parses an INI-format string into a Lua table. Sections become nested tables, and key-value pairs become string fields. Useful for legacy config files or simple settings.

```lua
lurek.serialize.fromIni(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | A valid INI string to parse. |

**Returns**

| Type | Description |
|------|-------------|
| table | The decoded Lua table with section names as keys and their key-value pairs as nested tables. |

**Example**

```lua
do
    local iniStr = '[player]\nname = Hero\nclass = warrior\n[controls]\njump = space'
    local ini = lurek.serialize.fromIni(iniStr)
    local player = ini.player.name .. " the " .. ini.player.class
    local jump_key = ini.controls.jump
    local config_source = "legacy input preset"
    lurek.log.info("loaded " .. config_source .. " for " .. player)
    lurek.log.info("jump key = " .. jump_key)
end
```

---

### `lurek.serialize.fromJson`

Parses a JSON string into a Lua table. Use this to load configuration files, network responses, or any structured data stored as JSON.

```lua
lurek.serialize.fromJson(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | A valid JSON string to parse. |

**Returns**

| Type | Description |
|------|-------------|
| table | The decoded Lua table representing the JSON structure. |

**Example**

```lua
do
    local jsonStr = '{"name":"warrior","level":12,"alive":true,"items":["sword","shield"]}'
    local data = lurek.serialize.fromJson(jsonStr)
    local equipment = data.items[1] .. " + " .. data.items[2]
    local summary = data.name .. " lvl " .. data.level
    lurek.log.info("loaded party member: " .. summary)
    lurek.log.info("alive = " .. tostring(data.alive) .. ", gear = " .. equipment)
end
```

---

### `lurek.serialize.fromToml`

Parses a TOML string into a Lua table. Ideal for loading game configuration files, level definitions, and engine settings stored in TOML format.

```lua
lurek.serialize.fromToml(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | A valid TOML string to parse. |

**Returns**

| Type | Description |
|------|-------------|
| table | The decoded Lua table representing the TOML structure. |

**Example**

```lua
do
    local tomlStr = '[game]\ntitle = "Dungeon Quest"\n[window]\nwidth = 1920\nheight = 1080'
    local config = lurek.serialize.fromToml(tomlStr)
    local resolution = config.window.width .. "x" .. config.window.height
    local area = config.window.width * config.window.height
    local title = config.game.title
    lurek.log.info("loaded TOML config for " .. title)
    lurek.log.info("window = " .. resolution .. " (" .. area .. " px)")
end
```

---

### `lurek.serialize.toCsv`

Serializes a Lua table (array of row tables) into a CSV-formatted string. Each row table should have consistent keys or be an indexed array. Use this to export leaderboards, save tabular data, or generate spreadsheet-compatible output.

```lua
lurek.serialize.toCsv(value, delimiter, hasHeaders)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | table | An array of row tables to serialize. |
| `delimiter?` | string | Single-character field delimiter. Defaults to comma (","). |
| `hasHeaders?` | boolean | When true, writes column names as the first row. Defaults to true. |

**Returns**

| Type | Description |
|------|-------------|
| string | The CSV-encoded string of the table data. |

**Example**

```lua
do
    local rows = { { name = "Alice", score = 100 }, { name = "Bob", score = 90 } }
    local csv = lurek.serialize.toCsv(rows, ",", true)
    local restored = lurek.serialize.fromCsv(csv, ",", true)
    local has_header = csv:find("name", 1, true) ~= nil
    lurek.log.info("csv leaderboard rows = " .. #restored)
    lurek.log.info("header present = " .. tostring(has_header) .. ", top player = " .. restored[1].name)
end
```

---

### `lurek.serialize.toJson`

Serializes a Lua value (table, string, number, boolean, or nil) into a JSON string. Useful for saving game state, writing config files, or preparing network payloads.

```lua
lurek.serialize.toJson(value, pretty)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The Lua value to serialize into JSON. |
| `pretty?` | boolean | When true, outputs indented human-readable JSON. Defaults to false (compact). |

**Returns**

| Type | Description |
|------|-------------|
| string | The JSON-encoded string representation of the value. |

**Example**

```lua
do
    local save_state = { player = { name = "Alice", level = 2 }, checkpoint = "town_gate" }
    local json = lurek.serialize.toJson(save_state, true)
    local restored = lurek.serialize.fromJson(json)
    local has_player = json:find('"player"') ~= nil
    lurek.log.info("save checkpoint = " .. restored.checkpoint)
    lurek.log.info("pretty json has player key = " .. tostring(has_player))
end
```

---

### `lurek.serialize.toToml`

Serializes a Lua table into a TOML-formatted string. Use this to write configuration files, save structured settings, or export data in a human-readable format.

```lua
lurek.serialize.toToml(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | table | The Lua table to serialize into TOML. |

**Returns**

| Type | Description |
|------|-------------|
| string | The TOML-encoded string representation of the table. |

**Example**

```lua
do
    local settings = { version = "1.0", debug = false, game = { title = "Arena" } }
    local toml = lurek.serialize.toToml(settings)
    local restored = lurek.serialize.fromToml(toml)
    local has_version = toml:find("version", 1, true) ~= nil
    lurek.log.info("toml bytes = " .. #toml .. ", has version = " .. tostring(has_version))
    lurek.log.info("restored title = " .. restored.game.title)
end
```

---

### `lurek.serialize.validate`

Validates a Lua value against a schema table. The schema defines expected types, required fields, and constraints. Returns a success boolean and an optional error message string describing the first validation failure. Use this to verify save data integrity or user-provided configuration before processing.

```lua
lurek.serialize.validate(value, schema)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | The data to validate. |
| `schema` | table | A schema table defining the expected structure and constraints. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if validation passes; false otherwise. |
| string | An error message describing the validation failure; or nil on success. |

**Example**

```lua
do
    local schema = {
        type = "table",
        fields = { name = { type = "string", required = true }, level = { type = "number", min = 1, max = 100 } },
    }
    local ok_valid = lurek.serialize.validate({ name = "Knight", level = 50 }, schema)
    local ok_invalid, err_invalid = lurek.serialize.validate({ name = "Knight", level = 150 }, schema)
    lurek.log.info("valid hero payload = " .. tostring(ok_valid))
    lurek.log.info("invalid payload rejected = " .. tostring(not ok_invalid) .. " err=" .. tostring(err_invalid))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

*No Lua userdata types detected for this module.*
