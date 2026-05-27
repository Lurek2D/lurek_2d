# Plan Implementacji: Optymalizacja GPU i Renderowania

## 1. Cel i Uzasadnienie
Obecny system renderowania posiada pre-alokowane bufory wierzchołków (`color_vertex_buffer`), ale podczas renderowania Post-FX (`postfx_pipeline.rs`) i oświetlenia tworzy instancje `wgpu::BindGroup` dynamicznie co klatkę. Dodatkowo wywoływanie pojedynczych operacji rysowania z poziomu Lua (`lurek.graphics.draw`) powoduje narzut bariery FFI.
Rozwiązaniem jest:
1. Object Pooling dla `BindGroup`.
2. Compute Shaders dla Cieni (zamiast CPU).
3. Lua-Rust FFI Batching (`drawBatch`).

## 2. Pliki do Edycji
- `src/render/gpu_renderer.rs`
- `src/render/postfx_pipeline.rs`
- `src/lua_api/graphics_api.rs` (dla Lua batchingu)

## 3. Szczegółowe Zmiany (Kod Przed i Po)

### A. Pooling zasobów `wgpu::BindGroup` w Post-FX
**Plik:** `src/render/postfx_pipeline.rs`

**KOD PRZED:** (Tworzenie per pass)
```rust
for (i, pass) in passes.iter().enumerate() {
    // ...
    // Dynamiczna alokacja co klatkę dla KAŻDEGO efektu w łańcuchu!
    let bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
        label: Some("postfx_bg"),
        layout: &self.bind_group_layout,
        entries: &[ /* ... */ ],
    });
    
    let mut rp = encoder.begin_render_pass(&wgpu::RenderPassDescriptor { ... });
    rp.set_pipeline(pipeline);
    rp.set_bind_group(0, &bind_group, &[]);
    rp.draw(0..3, 0..1);
}
```

**KOD PO:** (Cache)
```rust
// Nowa struktura w PostFxPipeline:
// pub(crate) bind_group_cache: HashMap<u64, wgpu::BindGroup>,

for (i, pass) in passes.iter().enumerate() {
    // ...
    let cache_key = generate_cache_key(src_view.id(), pass.effect_name.as_str());
    
    let bind_group = self.bind_group_cache.entry(cache_key).or_insert_with(|| {
        device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("postfx_bg"),
            layout: &self.bind_group_layout,
            entries: &[ /* ... */ ],
        })
    });

    let mut rp = encoder.begin_render_pass(&wgpu::RenderPassDescriptor { ... });
    rp.set_pipeline(pipeline);
    rp.set_bind_group(0, bind_group, &[]);
    rp.draw(0..3, 0..1);
}
```

### B. Przeniesienie Cieni na Compute Shader
**Plik:** `src/render/gpu_renderer.rs`

**KOD PRZED:** (CPU Raycasting)
```rust
fn compute_1d_shadow_map(...) -> Vec<f32> {
    let mut map = vec![1.0f32; SHADOW_MAP_RES];
    // Ciężka pętla matematyczna na CPU wyliczana co klatkę
    for i in 0..SHADOW_MAP_RES {
        // ... wyliczanie przecięć (t, u) ...
    }
    map
}
```

**KOD PO:** (GPU Compute Shader)
```rust
// Struktura LightGpuState zostanie rozszerzona:
struct LightGpuState {
    // ... istniejące ...
    shadow_compute_pipeline: wgpu::ComputePipeline,
    shadow_work_buffer: wgpu::Buffer,
}

// Funkcja dispatch na GPU
fn compute_1d_shadow_map_gpu(state: &mut LightGpuState, encoder: &mut wgpu::CommandEncoder) {
    let mut cpass = encoder.begin_compute_pass(&wgpu::ComputePassDescriptor {
        label: Some("shadow_compute_pass"),
        ..Default::default()
    });
    cpass.set_pipeline(&state.shadow_compute_pipeline);
    cpass.set_bind_group(0, &state.shadow_work_bind_group, &[]);
    cpass.dispatch_workgroups((SHADOW_MAP_RES as u32 / 64) + 1, 1, 1);
}
```

### C. FFI Batching dla Sprite'ów
**Plik:** `src/lua_api/graphics_api.rs`

**KOD PO:** (Dodanie nowej klasy `SpriteBatch` w Rust API)
```rust
// W rust dla SpriteBatch:
methods.add_method_mut("add", |_, this, (img, x, y, r, sx, sy): (LuaImage, f32, f32, f32, f32, f32)| {
    this.commands.push(DrawCommand::Sprite {
        texture: img.key,
        x, y, rotation: r, scale_x: sx, scale_y: sy
    });
    Ok(())
});

// W lua_api:
tbl.set("drawBatch", lua.create_function(|_, batch: LuaAnyUserData| {
    let b = batch.borrow::<SpriteBatch>()?;
    let mut st = state.borrow_mut();
    // Jedno wywołanie zapisu na wektor zamiast 1000 wywołań wirtualnej maszyny
    st.renderer.flush_batch(&b.commands);
    Ok(())
})?)?;
```

## 4. Przykłady Użycia (Lua)

```lua
-- Inicjalizacja poza pętlą (Batch)
local batch = lurek.graphics.newBatch()
local player_img = lurek.graphics.newImage("player.png")

function lurek.draw()
    batch:clear()
    -- Wypychanie danych bez wywoływania ciężkich funkcji draw pod spodem
    for i = 1, 10000 do
        batch:add(player_img, i * 10, i * 5, 0, 1, 1)
    end
    -- Wysłanie wszystkich wierzchołków jedną operacją FFI
    lurek.graphics.drawBatch(batch)
end
```

## 5. Testy

### Test Integracyjny Lua (`tests/lua/demos/test_gpu_batching_perf.lua`)
```lua
function test_gpu_batch_performance()
    local sprite = lurek.graphics.newImage("content/examples/assets/player.png")
    local batch = lurek.graphics.newBatch()
    for i = 1, 50000 do
        batch:add(sprite, math.random(800), math.random(600), 0, 1, 1)
    end
    
    local start_time = lurek.timer.getTime()
    lurek.graphics.drawBatch(batch)
    local elapsed = lurek.timer.getTime() - start_time
    
    -- Wykonanie batcha nie powinno przekroczyć 1-2ms w przeciwieństwie do 30ms przy draw()
    assert(elapsed < 0.002, "Batching execution was too slow: " .. elapsed .. "s")
end
```

### Test Jednostkowy Rust (`tests/rust/unit/render_tests.rs`)
```rust
#[test]
fn test_postfx_bind_group_pooling() {
    let mut mock_device = MockDevice::new();
    let mut pipeline = PostFxPipeline::new(&mock_device, wgpu::TextureFormat::Bgra8UnormSrgb);
    
    let pass = PostFxPass { effect_name: "bloom".into(), ..Default::default() };
    
    let b1 = mock_device.allocations();
    pipeline.apply(&mock_device, /* ... */ &[pass.clone()]);
    pipeline.apply(&mock_device, /* ... */ &[pass.clone()]);
    let b2 = mock_device.allocations();
    
    // Sprawdzenie, czy pooling działa: alokacje bind group nie mogą wzrosnąć po pierwszym przebiegu
    assert_eq!(b1, b2, "PostFxPipeline must use cache, but it reallocated BindGroups!");
}
```
