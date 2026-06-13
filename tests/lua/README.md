# tests/lua

Canonical Lua test tree.

- Unit tests are consolidated to `test_<module>_unit.lua`.
- Integration tests are renamed to `test_<modules>_integration.lua`.
- Stress tests stay in `test_<module>_stress.lua`.
- Evidence tests stay in `test_<module>_evidence.lua` and should be module-owned, not mixed bags.
- Evidence artifacts should live under `tests/artifacts/current/<module>/` with descriptive file names.
- Other categories follow the same `test_<subject>_<category>.lua` shape.

This tree is the canonical home for public Lua-facing tests.
