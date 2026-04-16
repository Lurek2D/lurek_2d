# IDEA.md — `parallax` module

> Migrated from `ideas/features/graphics.md` (parallax sections) and `ideas/performance/02-gpu-rendering.md`.
> Status checked against `src/parallax/` and `src/lua_api/parallax_api.rs`.
> Lua namespace: `lurek.parallax`.

---

## Features

### 🔇 LOW — Stripe-Band Optimisation for Background Layers
**Source**: performance/02-gpu-rendering.md (implied by frustum culling discussion)

Parallax layers that tile horizontally could skip render calls for strips outside the
viewport. Low priority — parallax layers are typically 1–4 draws per frame.
