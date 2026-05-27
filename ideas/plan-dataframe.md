# Plan Implementacji: Data Frame (HTAP, Kolumnowość, Rayon)

## 1. Cel i Uzasadnienie
Analiza `src/dataframe/frame.rs` pokazuje skrajnie niewydajną pamięciowo strukturę `Vec<Vec<CellValue>>`. Każda wartość komórki (nawet prosty Float czy Boolean) kosztuje narzut rzędu 24-32 bajtów (enum z tagiem) i prowadzi do rozdrobnienia pamięci. Mechanizm filtrowania i usuwania przesuwa całe masy wierszy, a `sql.rs` wykonuje to jednowątkowo.
Cel:
1. Columnar Storage (Tablice natywne: `Vec<f64>`, `Vec<String>`).
2. MVCC (Bitvec) dla maski usuniętych/ukrytych wierszy.
3. Równoległe SQL z `rayon` (`into_par_iter`).

## 2. Pliki do Edycji
- `src/dataframe/frame.rs`
- `src/dataframe/sql.rs`
- Dodanie zależności `rayon` w `Cargo.toml` i `bitvec`.

## 3. Szczegółowe Zmiany (Kod Przed i Po)

### A. Fizyczne Składowanie Kolumn (Columnar Array)
**Plik:** `src/dataframe/frame.rs`

**KOD PRZED:**
```rust
#[derive(Clone)]
pub struct DataFrame {
    pub(crate) column_names: Vec<String>,
    pub(crate) data: Vec<Vec<CellValue>>, // Potężny narzut enuma
}

pub enum CellValue {
    Nil,
    Number(f64),
    Text(String),
    Bool(bool),
}
```

**KOD PO:**
```rust
use bitvec::prelude::*;

pub enum ColumnData {
    Float(Vec<f64>),
    Text(Vec<String>),
    Bool(Vec<bool>),
    Variant(Vec<CellValue>), // Fallback dla starych API
}

#[derive(Clone)]
pub struct DataFrame {
    pub(crate) column_names: Vec<String>,
    pub(crate) data: Vec<ColumnData>,
    pub(crate) visibility_mask: BitVec, // MVCC / Row filtering
    pub(crate) logical_rows: usize,
}
```

### B. Maska Widoczności zamiast Fizycznego Usuwania (MVCC)
**Plik:** `src/dataframe/frame.rs`

**KOD PRZED:**
```rust
pub fn remove_row(&mut self, row: usize) -> Result<(), String> {
    for col in &mut self.data {
        col.remove(row); // Przesuwa CAŁĄ tablicę! O(N) za każdym usunięciem
    }
    Ok(())
}
```

**KOD PO:**
```rust
pub fn remove_row(&mut self, row: usize) -> Result<(), String> {
    if row >= self.visibility_mask.len() {
        return Err("out of range".into());
    }
    // O(1) koszt operacji. Wiersz po prostu staje się "niewidoczny"
    self.visibility_mask.set(row, false);
    self.logical_rows -= 1;
    Ok(())
}
```

### C. Równoległa Ewaluacja Zapytań SQL
**Plik:** `src/dataframe/sql.rs`

**KOD PRZED:**
```rust
// Wewnątrz funkcji execute_select lub podczas filtrowania WHERE:
let mut result_rows = Vec::new();
for row in 0..n {
    if eval_where(df, row, &where_expr) {
        result_rows.push(row);
    }
}
```

**KOD PO:**
```rust
use rayon::prelude::*;

// Równoległe map/reduce dla ewaluacji filtrowania
let result_rows: Vec<usize> = (0..n)
    .into_par_iter() // Rayon parallelism
    .filter(|&row| {
        // Bierzemy pod uwagę maskę MVCC oraz warunek SQL
        df.visibility_mask[row] && eval_where(df, row, &where_expr)
    })
    .collect();
```

## 4. Przykłady Użycia (Lua)

W Lua proces działa identycznie, ale pozwala na zarządzanie ogromnymi ilościami danych gry (np. pozycje 1,000,000 jednostek symulacji, AI, lub telemetrycznych logów).

```lua
local db = lurek.dataframe.newDatabase()
local df = lurek.dataframe.new()
-- Zdefiniowanie jasnych typów wymusi stworzenie szybkich wektorów Float/Bool
df:add_column("unit_id", 0.0) 
df:add_column("health", 100.0)
df:add_column("is_alive", true)

for i=1, 1000000 do
    df:add_row_fast({i, math.random() * 100, true})
end
db:add_table("units", df)

-- Szybkie znalezienie rannych jednostek w wielu wątkach:
local injured = db:query("SELECT unit_id, health FROM units WHERE health < 50.0 AND is_alive = true")
```

## 5. Testy

### Test Jednostkowy Rust (`tests/rust/unit/dataframe_tests.rs`)
```rust
#[test]
fn test_columnar_memory_and_mvcc() {
    let mut df = DataFrame::new();
    // Szybka prealokacja wektora f64
    df.add_float_column("score", 0.0).unwrap();
    
    for i in 0..10_000 {
        df.add_row_fast(vec![CellValue::Number(i as f64)]);
    }
    
    // Testowanie MVCC
    assert_eq!(df.nrows(), 10_000);
    df.remove_row(5).unwrap();
    
    // Logiczna ilość musi być 9999, ale fizyczna nadal 10000
    assert_eq!(df.nrows(), 9_999);
    assert_eq!(df.data[0].as_float_slice().unwrap().len(), 10_000);
}
```

### Test Integracyjny Lua (`tests/lua/test_dataframe_parallel.lua`)
```lua
function test_dataframe_rayon()
    local df = lurek.dataframe.random({{"val", "float"}}, 500000)
    
    local start_time = lurek.timer.getTime()
    local res = df:query("SELECT COUNT(*), AVG(val) FROM t WHERE val > 0.5")
    local elapsed = lurek.timer.getTime() - start_time
    
    -- Operacja dla pół miliona elementów powinna wykonać się bardzo szybko na CPU
    assert(elapsed < 0.010, "Parallel execution is too slow, time: " .. elapsed)
end
```
