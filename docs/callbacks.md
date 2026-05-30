# Callback Hooks

Globalne callbacki Lua są częścią publicznego kontraktu runtime.

Sekcje callbacków są widoczne bezpośrednio w stronach modułów (`docs/modules/*.md`) i w specyfikacji callbacków.

## Najczęściej używane

- `lurek.init`
- `lurek.ready`
- `lurek.process`
- `lurek.process_physics`
- `lurek.draw`
- `lurek.draw_ui`
- `lurek.keypressed`
- `lurek.mousepressed`
- `lurek.mousereleased`
- `lurek.resize`

## Pełne źródła

- [Spec callbacks](specs/callbacks.md)
- [Generated API (Markdown)](api/lurek.md)
