# IDEA.md — `camera` module

> Migrated from `ideas/features/camera.md`.
> Status checked against `src/camera/` and `src/lua_api/camera_api.rs`.

---

## Features

### 🤔 CONSIDER — Consolidate Screen Shake
**Source**: features/camera.md — Structural Issues

Screen shake is implemented in both the `camera` module and the `effect`/`fx` overlay system.
Two independent shake systems is confusing. Pick one canonical location — camera shake is
the more natural home — and deprecate the other.
