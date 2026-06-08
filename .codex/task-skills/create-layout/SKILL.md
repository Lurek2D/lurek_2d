---
name: create-layout
description: "Create or update new user interface layout and review it, regenerate to png."
---
# create-layout

## Goal
- Design and author a TOML UI layout under `content/layouts/`, review its structure, and generate visual previews.

## Required inputs
- Layout name
- UI components and hierarchy
- User must define the required UI elements and their visual arrangement
- Agent must collect available UI primitives from the engine

## Profile hint
- `content`

## Load these skills
- `ui-layout`
- `visual-effects`

## Steps
- Load skills: ui-layout, ui-html.
- Author the UI layout in TOML format within `content/layouts/`, explicitly setting anchors, alignment, and hierarchical node structures.
- Write a small Lua script under `content/examples/` that loads the new TOML file.
- Execute the UI screenshot rendering tool to generate a PNG preview. If the TOML parser throws an error (exit code >0), fix the syntax in step 2.
- Review the layout screenshot. If visual anchors are misaligned, adjust the TOML file and repeat step 4.

## Outputs
- TOML layout file
- Generated PNG preview
- Supporting Lua load script

## Success criteria
- [ ] The TOML parser exits with code 0 (0 syntax errors).
- [ ] 1 valid PNG file is successfully generated reflecting the intended layout.

## Stop conditions
- Using hardcoded pixel values where relative anchors are required.
- Defining invalid or unsupported style properties in TOML.

## References
- `skills: ui-layout, visual-effects`
- `tools: Lurek2D layout rendering tools`
- `agent: Content-Maker`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

