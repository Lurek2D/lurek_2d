# Analiza Ekstrakcji Modułów (Font, Color, Charts)

Zgodnie z filozofią Lurek2D (szczególnie regułą **T-01** i heurystyką *"Split by Reason to Change"*), rozbudowa monolitycznych struktur poprzez ich podział na wyspecjalizowane moduły jest kluczowym elementem dojrzewania silnika.

## 1. Moduł `color` (Palety Kolorów)
**Czy warto wydzielić?** TAK.
*   **Obecny stan:** Zarządzanie kolorami i paletami często żyje jako płaskie tablice `[f32; 4]` lub typy uwięzione w `src/ui/theme.rs` lub `src/render/`. 
*   **Architektura:** `color` to fundamentalny koncept danych/matematyczny. Nie zależy od GUI, GPU ani okna.
*   **Grupa Modułów:** **Foundations** (w tej samej warstwie co `math` i `data`).
*   **Korzyści:** Współdzielenie standardowych palet (kolory CSS, predefiniowane zestawy Godot-podobne), ujednolicenie konwersji (HSL <-> RGB <-> HEX), oraz interpolacji (lerp) pomiędzy systemem cząsteczek (`particle`), renderowaniem 2D (`render`) a interfejsem (`ui`).

## 2. Moduł `font` (Czcionka Bitmapowa i Wektorowa)
**Czy warto wydzielić?** TAK.
*   **Obecny stan:** Logika mierzenia tekstu i układania znaków (shaping) znajduje się zazwyczaj w `src/ui/` lub jest mocno sprzęgnięta z `src/render/`. 
*   **Architektura:** Rysowanie fontów wymaga atlasów tekstur (GPU) i dostępu do plików. Logika kształtowania (rozpoznawanie glifów, kerning) ma wyraźną, autonomiczną odpowiedzialność.
*   **Grupa Modułów:** **Platform Services** lub **Feature Systems**. 
*   **Korzyści:** Otwiera drogę do wsparcia zaawansowanych technik (Signed Distance Fields - SDF dla ostrych fontów wektorowych, format BMFont dla retro-czcionek bitmapowych). Pozwala na używanie fontów w przestrzeni świata gry (`scene`), a nie tylko na sztywno w Canvas UI.

## 3. Moduł `charts` (Wykresy)
**Czy warto wydzielić?** TAK.
*   **Obecny stan:** Zlokalizowaliśmy pliki `chart.rs` (~44 KB) oraz `data_graph_renderer.rs` (~11 KB) wewnątrz `src/ui/`. Stanowią one znaczącą część kodu UI, obciążając ten bazowy moduł.
*   **Architektura:** Wykresy i wizualizacja danych to osobny byt, który polega na `math`, `color`, `font` i `ui`.
*   **Grupa Modułów:** **Feature Systems** (budowane na szczycie `ui` i `render`).
*   **Korzyści:** Gigantyczne odchudzenie głównego modułu `ui` (który sam w sobie wymaga refaktoryzacji, jak opisano w `uwagi do ui.txt`). Wykresy jako osobny moduł `charts` będą miały własne API (`src/lua_api/charts_api.rs`), co usunie "szum" informacyjny z bazowej dokumentacji interfejsów użytkownika.

## Konkluzja
Wszystkie trzy moduły spełniają architektoniczną wytyczną Lurek2D nakazującą wydzielać kod posiadający unikalny powód do zmian. Szczegółowy plan migracji dla tych modułów został wygenerowany w dokumentacji (Implementation Plan).
