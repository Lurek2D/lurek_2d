# Lurek2D Apps

A collection of productive business and data-science applications built on the Lurek2D game engine platform. These apps leverage the engine's high-performance 2D rendering, Lua scripting, and physics capabilities to create fast, interactive professional tools.

## Table of Contents

- [Lurek2D Apps](#lurek2d-apps)
- [Table of Contents](#table-of-contents)
- [Featured Applications](#featured-applications)
- [Getting Started](#getting-started)
- [Code Standards](#code-standards)
- [Contributing](#contributing)

---

## 🎯 Featured Applications

### 📈 Stock Market Dashboard
Track stocks, analyze trends, and manage portfolios with real-time data integration.

- **Technologies**: Lua, JSON, HTTP requests, Chart rendering
- **Features**:
  - Real-time stock quotes (mock or API integration)
  - Candlestick charts with technical indicators
  - Portfolio tracking and performance metrics
  - Customizable watchlists and alerts

### 📊 Data Visualization Studio
Create stunning charts and graphs from datasets with interactive controls.

- **Technologies**: Lua, CSV parsing, Plotting libraries
- **Features**:
  - Support for various chart types (bar, line, scatter, pie)
  - Interactive zooming and panning
  - Data filtering and transformation
  - Export to image formats

### 🎨 Image Processing Workbench
Edit and enhance images with advanced filters and effects.

- **Technologies**: Lua, Image processing algorithms
- **Features**:
  - Real-time filter application (blur, sharpen, color correction)
  - Layer support and blending modes
  - Selection tools and masking
  - Batch processing capabilities

### 🤖 AI Experimentation Sandbox
Prototype and test machine learning models in a visual environment.

- **Technologies**: Lua, Neural network simulation, Data visualization
- **Features**:
  - Build neural networks layer by layer
  - Visualize training progress and weights
  - Experiment with different architectures
  - Integration with ML frameworks (optional)

---

## 🚀 Getting Started

### Prerequisites

- Lurek2D engine installed and built
- Rust toolchain (nightly recommended)
- CMake 3.16 or higher
- Lua 5.3 or higher

### Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/lurek2d-apps.git
cd lurek2d-apps
```

2. Build the engine:

```bash
cargo build --release
```

3. Run an application:

```bash
cargo run -- content/apps/stock_dashboard
```

### Application Structure

Each application follows this structure:

```
content/apps/app_name/
├── src/
│   ├── main.lua           # Entry point
│   ├── ui.lua             # UI components
│   ├── logic.lua          # Business logic
│   ├── components.lua     # Reusable widgets
│   └── models.lua         # Data models
├── assets/              # Images, fonts, data files
└── config.toml          # Configuration
```

---

## 🎨 Code Standards

### Lua Style Guide

We follow the **Luarocks style guide** with minor Lurek2D-specific adjustments.

#### Naming Conventions

- **Functions**: `snake_case` (e.g., `calculate_stats`)
- **Variables**: `snake_case` (e.g., `user_data`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_CONNECTIONS`)
- **Modules**: `PascalCase` (e.g., `utils/Network.lua`)

#### Formatting

```lua
-- Use 2 spaces for indentation
local function my_function(arg1, arg2)
    -- Indent code blocks
    local result = arg1 + arg2
    return result
end

-- Empty lines for readability
local x = 1

local y = 2

-- Function calls
my_function(x, y)
```

#### Documentation

```lua
--- Calculates the square root of a number.
-- @param value The number to process.
-- @return The square root.
function calculate_sqrt(value)
    return math.sqrt(value)
end
```

### Rust Style Guide

Applications use a lightweight Rust wrapper for platform integration.

- Follow **Rust Edition 2021** style
- Use `cargo fmt` for automatic formatting
- Document all public APIs
- Prefer explicit error handling over panics

---

## 🤝 Contributing

### Development Workflow

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/new-dashboard`
3. **Implement changes** following code standards
4. **Test thoroughly**:
   ```bash
   cargo test      # Rust tests
   cargo run       # Manual testing
   ```
5. **Create a Pull Request** with:
   - Clear description of changes
   - Before/after screenshots or videos
   - Any relevant metrics or benchmarks

### Testing Guidelines

All applications should include:

- [ ] **Unit tests** for core logic
- [ ] **Integration tests** for workflows
- [ ] **Manual testing checklist**
- [ ] **Performance benchmarks** (where applicable)
- [ ] **Cross-platform verification**

### Example Tests

**Lua Unit Tests** (`tests/test_logic.lua`):

```lua
describe('Data Processing', function()
    it('should process CSV correctly', function()
        local data = process_csv('test.csv')
        assert.is_not_nil(data)
        assert.is_type('table', data)
    end)
end)
```

**Rust Tests** (`src/lib.rs`):

```rust
#[test]
fn test_calculation() {
    assert_eq!(add(2, 3), 5);
}
```

---

## 📊 Built with

- **Lurek2D**: High-performance 2D game engine
- **Lua**: Lightweight, fast scripting language
- **Rust**: Type-safe, high-performance backend
- **TOML**: Configuration management

## 📄 License

This project is licensed under the terms of the **MIT license**.
