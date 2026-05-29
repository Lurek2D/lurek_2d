Oto szczegółowa ocena kodu z folderu `agent` w odniesieniu do dostarczonych standardów kodowania (`Coding Standards`) oraz założeń filozoficznych projektu (`Philosophy and Design Assumptions`).

Kod jest napisany rzetelnie pod kątem asynchroniczności (użycie dedykowanych wątków backgroundowych, pooling rezultatów) oraz implementacji logiki LLM (obsługa Ollama, retries z wykładniczym back-offem, pamięć episodic/semantic). Niemniej jednak, **łamie on kilka kluczowych reguł architektonicznych i konwencji dokumentacji Lurek2D**.

---

## Ocena zawartości folderu `agent`

### 1. Architektura i izolacja domeny (Naruszenie krytyczne)

* **Problem:** Obecność pliku `lua_runtime.rs` wewnątrz modułu domenowego `src/agent/`. Plik ten bezpośrednio importuje zależności `mlua` (`Lua`, `Table`, `Function`, `RegistryKey`, `Value`) oraz implementuje konwersje typów specyficzne dla Lua.


* **Naruszenie zasad:**
* **Rule 12 (Philosophy):** *„Bindings are thin and one-directional. [...] Domain modules never know the bridge exists.”*

* **Zasada 2.2 (Coding Standards):** *„src// ← logika biznesowa, typy, algorytmy; src/lua_api/_api.rs ← cienki wrapper”*.




* **Konsekwencja:** Moduł `agent` „wie” o istnieniu środowiska uruchomieniowego Lua. Co więcej, `BatchDispatcher` oraz parsowanie formatów (JSON/CSV) na typy Lua znajdują się wewnątrz domeny, a nie w warstwie API.



### 2. Standardy dokumentacji nagłówków (Rustdoc)

* **Problem:** Wszystkie pliki (`chat.rs`, `client.rs`, `lua_runtime.rs`, `memory.rs`, `mod.rs`, `ollama.rs`, `state.rs`, `types.rs`) posiadają bloki `//!` zawierające swobodną prozę jako wprowadzenie.


* **Naruszenie zasady 3.2:** *„Format: bullet-pointy, każda linia zaczyna się od `//! - `. Bez prozy, bez powtórzeń.”*

* **Przykład błędu (`chat.rs`):**
```rust
//! Stateless and stateful LLM chat helpers: global provider config...
//!
//! - `GlobalLlmConfig` is a process-wide default stored in a Mutex...

```



```
    Pierwsza linia to proza, co jest niedozwolone[cite: 2].

### 3. Brak dokumentacji `///` dla funkcji prywatnych
*   **Problem:** Niektóre funkcje prywatne lub wewnętrzne metody struktur nie posiadają komentarzy `///`[cite: 1].
*   **Naruszenie zasady 3.1:** *„Każda z poniższych linii musi mieć `///` bezpośrednio powyżej, bez wyjątku: [...] fn (każda prywatna funkcja)”*[cite: 2].
*   **Przykład błędu (`chat.rs`):** Funkcja `fn global_cfg_mutex()` nie posiada żadnego komentarza dokumentacji `///`[cite: 1]. W `lua_runtime.rs` metody w blokach `impl BatchDispatcher` również nie mają wymaganych one-linerów `///`[cite: 1].

### 4. Propagacja błędów do Lua (Brak prefiksów)
*   **Problem:** W `lua_runtime.rs` błędy runtime generowane dla maszyny wirtualnej Lua nie posiadają wymaganego kontekstu call-site[cite: 1].
*   **Naruszenie zasady 2.5:** *„Komunikat błędu zawsze zaczyna się od `lurek.<module>.<function>:`.”*[cite: 2]
*   **Przykład błędu (`lua_runtime.rs`):**
    ```rust
    return Err(LuaError::RuntimeError(format!("Eval failed: {}", error))) // Brak prefiksu lurek.agent...
    // oraz:
    .ok_or_else(|| LuaError::runtime(format!("agent '{}' not found", agent_name))) // Brak prefiksu

```

---

## Zaproponowane poprawki

### Krok 1: Eksmisja `lua_runtime.rs` do `src/lua_api/`

Cała zawartość pliku `lua_runtime.rs` musi zostać przeniesiona do warstwy integracji, czyli do pliku `src/lua_api/agent_api.rs` (lub podmodułu tej warstwy).

* Usuń `lua_runtime.rs` z folderu `src/agent/`.


* Zmień `src/agent/mod.rs`, aby nie eksponował struktur powiązanych z Lua.


* W folderze `src/agent/` pozostaw wyłącznie czystą logikę Rust: `AgentState`, `AgentClient`, `OllamaManager`, `AgentMemory`.



### Krok 2: Refaktoryzacja komunikatów o błędach Lua

Wszystkie rzucane błędy `LuaError::RuntimeError` w przeniesionym kodzie muszą otrzymać pełny prefiks:

```rust
// POPRAWNIE
return Err(LuaError::RuntimeError(format!(
    "lurek.agent.eval_code: Eval failed: {}", error
)));

// POPRAWNIE
.ok_or_else(|| LuaError::runtime(format!(
    "lurek.agent.prompt: agent '{}' not found", agent_name
)))

```

### Krok 3: Korekta formatu nagłówków (`//!`)

Przekształć nagłówki wszystkich plików, eliminując prozę na rzecz czystych bullet-pointów `//! - `.

Przykład poprawionego nagłówka dla `chat.rs` (rozmiar średni, 5 bullet-pointów):

```rust
//! - Provides stateless and stateful LLM chat utilities using global configuration and explicit session history.
//! - Manages a process-wide process default configuration stored inside an initialized static Mutex lock.
//! - Dispatches synchronous HTTP requests targeting Ollama generation, embedding, and model tag resolution endpoints.
//! - Implements a simple brace-placeholder formatting engine substituting template keys dynamically.
//! - Gracefully handles malformed server response text, missing JSON fields, and uninitialized provider contexts.

```

### Krok 4: Uzupełnienie `///` dla funkcji pomocniczych

Dodaj brakujące jedno-liniowe opisy dla funkcji takich jak `global_cfg_mutex`:

```rust
/// Returns the process-wide global configuration thread-safe mutex wrapper.
fn global_cfg_mutex() -> &'static Mutex<GlobalLlmConfig> {
    GLOBAL_CFG.get_or_init(|| Mutex::new(GlobalLlmConfig::default()))
}

```

---

### Co zrobiono dobrze (Zgodność z bramkami jakości)

* **Struktura `mod.rs`:** Plik `src/agent/mod.rs` w pełni przestrzega zasady 2.1 — zawiera wyłącznie deklaracje `pub mod` oraz re-eksporty `pub use`, bez wplecionej logiki.


* **Nazewnictwo:** Struktury (np. `EpisodicMemory`, `GlobalLlmConfig`) oraz funkcje (`ollama_generate`) idealnie wpisują się w konwencję `PascalCase` / `snake_case` z sekcji 2.8.


* **Brak `#[cfg(test)]`:** W plikach źródłowych domeny nie umieszczono testów inline, co jest w pełni zgodne z zasadą 2.3.
