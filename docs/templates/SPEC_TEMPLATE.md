# `<module>` manual spec overlay

<!--
Copy to docs/specs/manual/<module>.md.

This is hand-written intent only. The generated module spec owns source paths,
imports, API signatures, types, examples, and test inventories. Keep this file
aligned with docs/specs/AGENTS.md and docs/architecture/ when a durable module
boundary changes.
-->

## TL;DR

- One or two durable statements explaining the module's job and public boundary.

## Summary

Describe the problem the module owns, its primary state or data authority, and the nearest collaborating modules. Do not repeat function lists or generated metadata.

## Notes

- Record only durable constraints, lifecycle rules, compatibility facts, or ownership boundaries.
- State what the module explicitly does not own when that prevents a likely overlap.

## Architecture Links

- `../../architecture/<document>.md`
