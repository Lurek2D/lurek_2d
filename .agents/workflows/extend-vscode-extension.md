---
trigger: manual
description: "Extend the VS Code extension with one bounded command, panel, or language feature."
expected_agent: "Manager"
---

# Extend VS Code Extension

## Goal
- Add one extension feature without leaking engine logic into the IDE layer.

## Inputs
- Feature goal.
- Target extension area.
- Expected user action.
- Validation path.

## Steps
1. Load [skill: vscode-extension](../rules/skill_vscode-extension.md) and [skill: html-css](../rules/skill_html-css.md) before acting.
2. Read extension/vscode/, package.json contributions, nearby extension patterns, and any generated data dependency before editing.
3. Keep implementation inside the extension, make contributions explicit, and sync generated data or command wiring when the feature depends on them.
4. Run the narrowest extension build or test path first and verify the changed command, panel, or provider still resolves correctly.

## Success Criteria
- [ ] The prompt goal was completed: Add one extension feature without leaking engine logic into the IDE layer.
- [ ] Required sync files were updated for the touched slice.
- [ ] The narrowest relevant validation passed.
- [ ] The change stayed inside the intended scope.

## Anti-patterns
- Widen the change into adjacent layers with no new decision.
- Edit generated artifacts by hand when the source should change instead.
- Skip the first narrow validation and jump straight to a broad sweep.

## Example Invocation
- /extend-vscode-extension feature=scene_outline_panel

## CAG Metadata
Mode: agent
Loads skills: vscode-extension, html-css
Inputs required: Feature goal., Target extension area., Expected user action., Validation path.

