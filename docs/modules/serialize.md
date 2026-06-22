# Serialize

## Purpose

Translates JSON, TOML, CSV, XML, INI, and MessagePack via one intermediate tree.

## When To Use

- JSON, TOML, CSV, XML, INI, MessagePack, schemas, and codec entrypoints all matter here because a project often needs to move content between several representations without rewriting conversion logic each time.
- The module is useful both for loading or saving data and for validating whether translated data actually fits an expected structure.
- Its shared intermediate tree is the key user-facing idea: several formats can participate in the same workflows because they resolve into one normalized serial representation.

## Minimal Example

From the `lurek.serial.fromJson` example block:

```lua
do
    local jsonStr = '{"name":"warrior","level":12,"alive":true,"items":["sword","shield"]}'
    local data = lurek.serial.fromJson(jsonStr)
    local equipment = data.items[1] .. " + " .. data.items[2]
    local summary = data.name .. " lvl " .. data.level
    lurek.log.info("loaded party member: " .. summary)
    lurek.log.info("alive = " .. tostring(data.alive) .. ", gear = " .. equipment)
end
```

## Common Patterns

- Check the module summary and related examples before using lower-level details.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/serialize.lua`

## Summary

- The `serialize` module is the format-translation surface for users who want several external data formats to map into one shared runtime value model.
- JSON, TOML, CSV, XML, INI, MessagePack, schemas, and codec entrypoints all matter here because a project often needs to move content between several representations without rewriting conversion logic each time.
- The module is useful both for loading or saving data and for validating whether translated data actually fits an expected structure.
- Its shared intermediate tree is the key user-facing idea: several formats can participate in the same workflows because they resolve into one normalized serial representation.
- That normalized representation is what makes cross-format tooling practical. Validators, exporters, migration steps, and transforms can reason about one value model instead of reimplementing logic for every source format.
- That also makes migrations easier to reason about.
- Safety is part of the contract. Lua conversion, autodetection, CSV parsing, and MessagePack decode must stay bounded and reject cyclic or non-finite inputs instead of recursing or allocating without policy.
- Read `serialize` as the normalization layer for structured data moving between external formats and engine-facing workflows.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

*No public API documented yet.*