# LLM Agent Native Module Design (Rust) - Updated with AgentManager

## Cel
Zgodnie z wymaganiami z nagrania, rozszerzamy architekturę modułu `src/agent/` o zarządzanie wieloma agentami działającymi współbieżnie (Agent Manager) oraz ustrukturyzowane budowanie promptów i wymuszanie formatowania wyjścia.

## Architektura (Natywna)

### 1. `AgentManager` (Zarządca Agentów)
- Nowy obiekt wystawiany do Lua.
- Pozwala na grupowanie wielu agentów (`lurek.agent.newManager()`).
- Posiada metodę `manager:runAll()`, która odpala przypisane zadania agentów równolegle (współbieżnie w tle) i agreguje ich wyniki.
- Agenci w ramach managera mogą współdzielić pulę połączeń HTTP (`ureq::Agent`) w celu optymalizacji.

### 2. Budowanie Promptów (Blocks)
Zamiast jednego płaskiego stringa, Agent zbuduje prompt wieloetapowo przed wysłaniem do Ollamy:
1. **System Prompt** (zawsze dodawany na początku, definiuje rolę).
2. **Skills** (doklejane automatycznie na podstawie kontekstu lub globalnie).
3. **Instructions** (bieżące instrukcje przekazane przez użytkownika / skrypt).

### 3. Wymuszone Formatowanie
Agenci będą mieli wbudowaną obsługę wymuszonego formatowania:
- JSON
- CSV
- Tabular
Ollama zostanie poinstruowana za pomocą pola `format: "json"` (jeśli dotyczy) oraz przez odpowiednią zmianę w `System Prompt`.

### 4. Docstrings i Zgodność z API
- W pliku `src/lua_api/agent_api.rs` zostaną dodane pełne docstringi zgodnie z `skill_lua-api-design.md`:
  - Plik rozpocznie się od `//! \`lurek.agent\` -- Agent bindings for LLM and VM integration.`
  - Każda funkcja otrzyma `/// @param | nazwa | typ | opis` oraz `/// @return | typ | opis`.

## Plan Wdrożenia
1. **Rozszerzenie `src/agent/core.rs` i `client.rs`** o `AgentManager` wspierający wielu agentów. Zamiast jednego wątku dla wszystkich zapytań agenta (co blokowało kolejkę), każde zapytanie w managerze wywoła współbieżnie HTTP request.
2. **Aktualizacja struktury budowania promptu** w `core.rs`.
3. **Aktualizacja `src/lua_api/agent_api.rs`**: Zarejestrowanie nowej funkcji `newManager()`, aktualizacja dokumentacji LDoc, dodanie poprawnych makr `@param` i `@return`.
4. Wykonanie weryfikacji i generacja dokumentacji.
