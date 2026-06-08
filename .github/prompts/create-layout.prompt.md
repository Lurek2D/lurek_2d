---
name: create-layout
description: Create or update new user interface layout and review it, regenerate to png.
---

# GOAL
- Design and author a TOML UI layout under `content/layouts/`, review its structure, and generate visual previews.

# INPUTS REQUIRED
- Layout name
- UI components and hierarchy
= User must define the required UI elements and their visual arrangement
- Agent must collect available UI primitives from the engine

# STEPS TO DO
1. Load skills: ui-layout, ui-html.
2. Author the UI layout in TOML format within `content/layouts/`, explicitly setting anchors, alignment, and hierarchical node structures.
3. Write a small Lua script under `content/examples/` that loads the new TOML file.
4. Execute the UI screenshot rendering tool to generate a PNG preview. If the TOML parser throws an error (exit code >0), fix the syntax in step 2.
5. Review the layout screenshot. If visual anchors are misaligned, adjust the TOML file and repeat step 4.

# OUTPUTS PROVIDED
- TOML layout file
- Generated PNG preview
- Supporting Lua load script

# SUCCESS CRITERIA
- [ ] The TOML parser exits with code 0 (0 syntax errors).
- [ ] 1 valid PNG file is successfully generated reflecting the intended layout.

# ANTI-PATTERNS
- Using hardcoded pixel values where relative anchors are required.
- Defining invalid or unsupported style properties in TOML.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: ui-layout, visual-effects
- tools: Lurek2D layout rendering tools
- agent: Content-Maker


