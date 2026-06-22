# Html

## Purpose

Runs interactive HTML/CSS documents with input routing, selector queries, and element mutations.

## When To Use

- Parsing, runtime document state, selectors, style resolution, layout, and event routing work together so a project can build menus, tool panels, and overlays with a web-like authoring model.
- Dynamic mutation matters because the module is not only for static documents: scripts can update attributes, styles, and content while still relying on the same layout and event system.
- Input handling, dirty or reflow behavior, and render-command generation make the feature practical as an interactive UI stack instead of a passive HTML parser.

## Minimal Example

From the `lurek.html.newDocument` example block:

```lua
do
    local doc = lurek.html.newDocument("<main id='hud'><h1>HUD</h1><p>Status</p></main>")
    local root = doc:getRoot()
    html_log("doc created=" .. tostring(doc ~= nil))
    html_log("root tag=" .. root:getTagName())
    html_log("html length=" .. #doc:getHtml())
    html_log("type=" .. doc:type())
end
```

## Common Patterns

- Start with `lurek.html.isDefaultPrevented` when exploring this module.
- Start with `lurek.html.loadDocument` when exploring this module.
- Start with `lurek.html.newDocument` when exploring this module.
- Start with `lurek.html.preventDefault` when exploring this module.
- Start with `lurek.html.stopPropagation` when exploring this module.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/html.lua`

## Summary

- The `html` module is the in-engine document-style UI surface for users who want markup, styles, and DOM-like interaction inside the runtime.
- Parsing, runtime document state, selectors, style resolution, layout, and event routing work together so a project can build menus, tool panels, and overlays with a web-like authoring model.
- Dynamic mutation matters because the module is not only for static documents: scripts can update attributes, styles, and content while still relying on the same layout and event system.
- Input handling, dirty or reflow behavior, and render-command generation make the feature practical as an interactive UI stack instead of a passive HTML parser.
- Style inheritance and selector resolution are especially valuable because document-driven interfaces stay manageable only when broad presentation rules can change without rewriting every element.
- That authoring model is especially appealing for tool panels and content-driven menus.
- It also keeps document structure visible at runtime.
- Read `html` as the module that turns markup and CSS-like data into live engine UI. Rendering shows the result, but `html` owns how the document is parsed, laid out, mutated, and interacted with.

This module primarily collaborates with `color`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.html.isDefaultPrevented`

Returns whether the default action was prevented.

```lua
lurek.html.isDefaultPrevented()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the default was prevented. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        example_print_log("event isDefaultPrevented = " .. tostring(type(ev.isDefaultPrevented) == "function"))
    end)
    example_print_log("module isDefaultPrevented = " .. tostring(type(lurek.html.isDefaultPrevented)))
end
```

---

### `lurek.html.loadDocument`

Loads an HTML document from GameFS and optionally loads CSS from options or companion file.

```lua
lurek.html.loadDocument(path, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | GameFS path to the HTML file. |
| `opts?` | table | Table with `css`, `cssPath`, `width`, and `height` fields. |

**Returns**

| Type | Description |
|------|-------------|
| [LHtmlDocument](#lhtmldocument) | Loaded HTML document handle. |

**Example**

```lua
do
    local ok, doc = pcall(lurek.html.loadDocument, "content/examples/assets/layouts/sample_menu.html")
    example_print_log("loaded document = " .. tostring(ok))
    if ok then
        example_print_log("loaded doc type = " .. doc:type())
    end
end
```

---

### `lurek.html.newDocument`

Creates an HTML document from optional source and layout/style options.

```lua
lurek.html.newDocument(source, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `source?` | string | HTML source, defaulting to an empty document. |
| `opts?` | table | Table with `css`, `cssPath`, `width`, and `height` fields. |

**Returns**

| Type | Description |
|------|-------------|
| [LHtmlDocument](#lhtmldocument) | New HTML document handle. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<main id='hud'><h1>HUD</h1><p>Status</p></main>")
    local root = doc:getRoot()
    html_log("doc created=" .. tostring(doc ~= nil))
    html_log("root tag=" .. root:getTagName())
    html_log("html length=" .. #doc:getHtml())
    html_log("type=" .. doc:type())
end
```

---

### `lurek.html.preventDefault`

Marks the event as having its default action prevented.

```lua
lurek.html.preventDefault()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        example_print_log("event preventDefault = " .. tostring(type(ev.preventDefault) == "function"))
    end)
    example_print_log("module preventDefault = " .. tostring(type(lurek.html.preventDefault)))
end
```

---

### `lurek.html.stopPropagation`

Stops event propagation to remaining listeners.

```lua
lurek.html.stopPropagation()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    doc:on("click", function(ev)
        example_print_log("event stopPropagation = " .. tostring(type(ev.stopPropagation) == "function"))
    end)
    example_print_log("module stopPropagation = " .. tostring(type(lurek.html.stopPropagation)))
end
```

---

### `lurek.html.supports`

Returns whether the HTML engine supports a named feature.

```lua
lurek.html.supports(feature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `feature` | string | Feature name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the feature is supported. |

**Example**

```lua
do
    local ok = lurek.html.supports("css-flex")
    local query_ok = lurek.html.supports("selectors")
    local bogus = lurek.html.supports("totally-unknown-feature")
    html_log("css-flex supported=" .. tostring(ok))
    html_log("selectors supported=" .. tostring(query_ok))
    html_log("unknown feature supported=" .. tostring(bogus))
    html_log("supports returns booleans for capability probes")
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LHtmlDocument](#lhtmldocument)
- [LHtmlElement](#lhtmlelement)

## LHtmlDocument

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHtmlDocument:addCss`

Appends CSS source text to the document stylesheet.

```lua
LHtmlDocument:addCss(css)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `css` | string | CSS source text to append. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>styled</p>")
    doc:addCss("p { font-size: 16px; }")
    doc:addCss("p { margin: 10px; }")
    local css_html = doc:getHtml()
    html_log("css appended")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("paragraph count=" .. #(doc:queryAll("p")))
    html_log("html length=" .. #css_html)
end
```

---

#### `LHtmlDocument:clearCss`

Clears all CSS source text from the document.

```lua
LHtmlDocument:clearCss()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>unstyled</p>")
    doc:setCss("p { color: red; }")
    doc:clearCss()
    doc:relayout()
    html_log("css cleared")
    html_log("dirty after relayout=" .. tostring(doc:isDirty()))
    html_log("paragraph count=" .. #(doc:queryAll("p")))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
end
```

---

#### `LHtmlDocument:draw`

Queues render commands for this document at an optional offset.

```lua
LHtmlDocument:draw(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | X offset, defaulting to 0. |
| `y?` | number | Y offset, defaulting to 0. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>Hello</p>")
    doc:setViewport(320, 180)
    doc:relayout()
    doc:draw(10, 20)
    html_log("drawn at 10,20")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("text=" .. tostring(doc:query("p") and doc:query("p"):getText()))
end
```

---

#### `LHtmlDocument:getElementById`

Looks up the first element with a matching id attribute.

```lua
LHtmlDocument:getElementById(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Element id attribute. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | `[LHtmlElement](#lhtmlelement)` handle, or nil when no element matches. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div id='hero'>Player</div>")
    local el = doc:getElementById("hero")
    if el then
        example_print_log("found: " .. el:getText())
    end
end
```

---

#### `LHtmlDocument:getHtml`

Returns the current document markup string.

```lua
LHtmlDocument:getHtml()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Current HTML markup. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<span>test</span>")
    local html = doc:getHtml()
    local root = doc:getRoot()
    html_log("html=" .. html)
    html_log("html length=" .. #html)
    html_log("root tag=" .. root:getTagName())
    html_log("dirty=" .. tostring(doc:isDirty()))
end
```

---

#### `LHtmlDocument:getRoot`

Returns the root DOM element handle.

```lua
LHtmlDocument:getRoot()
```

**Returns**

| Type | Description |
|------|-------------|
| [LHtmlElement](#lhtmlelement) | Root element handle. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>root child</div>")
    local root = doc:getRoot()
    html_log("root tag=" .. root:getTagName())
    html_log("root text=" .. root:getText())
    html_log("root type=" .. root:type())
    html_log("document type=" .. root:getDocument():type())
end
```

---

#### `LHtmlDocument:getViewport`

Returns the document layout viewport size.

```lua
LHtmlDocument:getViewport()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Viewport width in pixels. |
| number | Viewport height in pixels. |

**Example**

```lua
do
    local doc = lurek.html.newDocument()
    doc:setViewport(800, 600)
    local w, h = doc:getViewport()
    html_log("viewport=" .. w .. "x" .. h)
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end
```

---

#### `LHtmlDocument:isDirty`

Returns whether the document layout is dirty.

```lua
LHtmlDocument:isDirty()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a relayout is needed. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>X</p>")
    doc:setHtml("<p>Y</p>")
    html_log("dirty after setHtml=" .. tostring(doc:isDirty()))
    doc:relayout()
    html_log("dirty after relayout=" .. tostring(doc:isDirty()))
    html_log("html=" .. doc:getHtml())
    html_log("paragraph count=" .. #(doc:queryAll("p")))
end
```

---

#### `LHtmlDocument:keypressed`

Forwards a key press to the focused document element and dispatches `keydown`.

```lua
LHtmlDocument:keypressed(key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `key` | string | Key name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the event was consumed or default was prevented. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<input id='in'/>")
    local handled = doc:keypressed("return")
    html_log("keypressed handled=" .. tostring(handled))
    html_log("input exists=" .. tostring(doc:getElementById("in") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end
```

---

#### `LHtmlDocument:mousemoved`

Forwards mouse movement to the document.

```lua
LHtmlDocument:mousemoved(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse x coordinate. |
| `y` | number | Mouse y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an element handled the move. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>hover me</div>")
    local handled = doc:mousemoved(100, 50)
    html_log("mousemoved handled=" .. tostring(handled))
    html_log("root tag=" .. doc:getRoot():getTagName())
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
end
```

---

#### `LHtmlDocument:mousepressed`

Forwards a mouse press to the document and dispatches a click event when an element is hit.

```lua
LHtmlDocument:mousepressed(x, y, button)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse x coordinate. |
| `y` | number | Mouse y coordinate. |
| `button?` | number | Mouse button, defaulting to 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the event was consumed or default was prevented. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousepressed(100, 50, 1)
    html_log("mousepressed handled=" .. tostring(handled))
    html_log("button exists=" .. tostring(doc:query("button") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end
```

---

#### `LHtmlDocument:mousereleased`

Forwards a mouse release to the document.

```lua
LHtmlDocument:mousereleased(x, y, button)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Mouse x coordinate. |
| `y` | number | Mouse y coordinate. |
| `button?` | number | Mouse button, defaulting to 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an element handled the release. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button>click</button>")
    local handled = doc:mousereleased(100, 50, 1)
    html_log("mousereleased handled=" .. tostring(handled))
    html_log("button exists=" .. tostring(doc:query("button") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end
```

---

#### `LHtmlDocument:off`

Removes a document-level event listener by handle.

```lua
LHtmlDocument:off(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | number | Listener handle returned by `on`. |

**Example**

```lua
do
    local doc = lurek.html.newDocument()
    local h = doc:on("hover", function() end)
    doc:off(h)
    local second = doc:on("tick", function() end)
    doc:off(second)
    html_log("unregistered first handle=" .. tostring(h))
    html_log("unregistered second handle=" .. tostring(second))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end
```

---

#### `LHtmlDocument:on`

Registers a document-level event listener.

```lua
LHtmlDocument:on(event, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | Event name to listen for. |
| `func` | function | Lua callback receiving an event table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Listener handle used by `off`. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button id='btn'>Click</button>")
    local handle = doc:on("click", function(ev)
        example_print_log("clicked!")
    end)
    example_print_log("registered handle = " .. handle)
end
```

---

#### `LHtmlDocument:query`

Looks up the first element matching a selector.

```lua
LHtmlDocument:query(selector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `selector` | string | Selector supported by the HTML engine. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | `[LHtmlElement](#lhtmlelement)` handle, or nil when no element matches. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p class='intro'>Hello</p><p>World</p>")
    local el = doc:query(".intro")
    if el then
        example_print_log("query found: " .. el:getText())
    end
end
```

---

#### `LHtmlDocument:queryAll`

Returns all elements matching a selector.

```lua
LHtmlDocument:queryAll(selector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `selector` | string | Selector supported by the HTML engine. |

**Returns**

| Type | Description |
|------|-------------|
| [LHtmlElement](#lhtmlelement)[] | `[LHtmlElement](#lhtmlelement)` handles. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<li>A</li><li>B</li><li>C</li>")
    local items = doc:queryAll("li")
    html_log("items=" .. #items)
    html_log("first item=" .. tostring(items[1] and items[1]:getText()))
    html_log("second item=" .. tostring(items[2] and items[2]:getText()))
    html_log("third item=" .. tostring(items[3] and items[3]:getText()))
end
```

---

#### `LHtmlDocument:relayout`

Rebuilds document layout immediately.

```lua
LHtmlDocument:relayout()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>content</div>")
    doc:setViewport(640, 360)
    doc:relayout()
    html_log("relayout done")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("root tag=" .. doc:getRoot():getTagName())
end
```

---

#### `LHtmlDocument:render`

Queues render commands for this document at an optional offset.

```lua
LHtmlDocument:render(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | X offset, defaulting to 0. |
| `y?` | number | Y offset, defaulting to 0. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>World</p>")
    doc:setViewport(320, 180)
    doc:relayout()
    doc:render(0, 0)
    html_log("rendered")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("text=" .. tostring(doc:query("p") and doc:query("p"):getText()))
end
```

---

#### `LHtmlDocument:setCss`

Replaces the document stylesheet text.

```lua
LHtmlDocument:setCss(css)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `css` | string | CSS source text. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div class='box'>X</div>")
    doc:setCss(".box { width: 100px; height: 100px; }")
    doc:relayout()
    local el = doc:query(".box")
    html_log("css set for .box")
    html_log("dirty after relayout=" .. tostring(doc:isDirty()))
    html_log("box text=" .. tostring(el and el:getText()))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
end
```

---

#### `LHtmlDocument:setHtml`

Replaces the document markup and invalidates existing element handles.

```lua
LHtmlDocument:setHtml(html)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `html` | string | New HTML markup. |

**Example**

```lua
do
    local doc = lurek.html.newDocument()
    doc:setHtml("<h1>Title</h1><p>Body text</p>")
    local heading = doc:query("h1")
    html_log("html set length=" .. #doc:getHtml())
    html_log("dirty after set=" .. tostring(doc:isDirty()))
    html_log("heading text=" .. tostring(heading and heading:getText()))
    html_log("paragraph count=" .. #(doc:queryAll("p")))
end
```

---

#### `LHtmlDocument:setViewport`

Sets the document layout viewport size.

```lua
LHtmlDocument:setViewport(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Viewport width in pixels. |
| `h` | number | Viewport height in pixels. |

**Example**

```lua
do
    local doc = lurek.html.newDocument()
    doc:setViewport(1024, 768)
    local w, h = doc:getViewport()
    html_log("viewport set=" .. w .. "x" .. h)
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end
```

---

#### `LHtmlDocument:textinput`

Forwards text input to the focused document element and dispatches `input`.

```lua
LHtmlDocument:textinput(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | Input text. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the event was consumed or default was prevented. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<input/>")
    local handled = doc:textinput("A")
    html_log("textinput handled=" .. tostring(handled))
    html_log("input exists=" .. tostring(doc:query("input") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end
```

---

#### `LHtmlDocument:type`

Returns the Lua-visible type name for this HTML document handle.

```lua
LHtmlDocument:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LHtmlDocument](#lhtmldocument)`. |

**Example**

```lua
do
    local doc = lurek.html.newDocument()
    html_log("type=" .. doc:type())
    html_log("is document=" .. tostring(doc:typeOf("LHtmlDocument")))
    html_log("viewport=" .. table.concat({ doc:getViewport() }, "x"))
    html_log("html length=" .. #doc:getHtml())
end
```

---

#### `LHtmlDocument:typeOf`

Returns whether this document handle matches a supported type name.

```lua
LHtmlDocument:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LHtmlDocument](#lhtmldocument)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local doc = lurek.html.newDocument()
    html_log("is HtmlDocument=" .. tostring(doc:typeOf("LHtmlDocument")))
    html_log("is LObject=" .. tostring(doc:typeOf("LObject")))
    html_log("is HtmlElement=" .. tostring(doc:typeOf("LHtmlElement")))
    html_log("type=" .. doc:type())
end
```

---

#### `LHtmlDocument:update`

Advances document timers and animated state.

```lua
LHtmlDocument:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>Tick</p>")
    doc:update(0.016)
    html_log("updated")
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
    html_log("html length=" .. #doc:getHtml())
end
```

---

#### `LHtmlDocument:wheelmoved`

Forwards mouse wheel movement to the document.

```lua
LHtmlDocument:wheelmoved(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | Horizontal wheel delta. |
| `dy` | number | Vertical wheel delta. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an element handled the wheel event. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div style='overflow:scroll;height:100px'><p>long</p></div>")
    local handled = doc:wheelmoved(0, -3)
    html_log("wheelmoved handled=" .. tostring(handled))
    html_log("scroll container exists=" .. tostring(doc:query("div") ~= nil))
    html_log("dirty=" .. tostring(doc:isDirty()))
    html_log("type=" .. doc:type())
end
```

---

## LHtmlElement

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LHtmlElement:addClass`

Adds a CSS class to this element's class list.

```lua
LHtmlElement:addClass(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name to add. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>box</div>")
    local el = doc:query("div")
    if el then el:addClass("highlight") end
    html_log("class added=" .. tostring(el and el:hasClass("highlight")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:appendHtml`

Appends HTML source to this element's inner HTML.

```lua
LHtmlElement:appendHtml(html)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `html` | string | HTML source to append. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<ul><li>first</li></ul>")
    local el = doc:query("ul")
    if el then el:appendHtml("<li>second</li>") end
    local items = el and el:queryAll("li") or {}
    html_log("html appended item count=" .. #items)
    html_log("first item=" .. tostring(items[1] and items[1]:getText()))
    html_log("second item=" .. tostring(items[2] and items[2]:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:blur`

Removes keyboard focus from this element when it is focused.

```lua
LHtmlElement:blur()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<input id='field2'/>")
    local el = doc:getElementById("field2")
    if el then
        el:focus()
        el:blur()
    end
    example_print_log("blurred")
end
```

---

#### `LHtmlElement:focus`

Gives keyboard focus to this element.

```lua
LHtmlElement:focus()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<input id='field'/>")
    local el = doc:getElementById("field")
    if el then el:focus() end
    html_log("focused element exists=" .. tostring(el ~= nil))
    html_log("focused element tag=" .. tostring(el and el:getTagName()))
    html_log("focused element type=" .. tostring(el and el:type()))
    html_log("document type=" .. tostring(el and el:getDocument():type()))
end
```

---

#### `LHtmlElement:getAttribute`

Returns an attribute value from this element.

```lua
LHtmlElement:getAttribute(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Attribute name. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Attribute string, or nil when absent. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<a href='#top'>link</a>")
    local el = doc:query("a")
    html_log("href=" .. tostring(el and el:getAttribute("href")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:getDocument`

Returns the document handle that owns this element.

```lua
LHtmlElement:getDocument()
```

**Returns**

| Type | Description |
|------|-------------|
| [LHtmlDocument](#lhtmldocument) | Owning document handle. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>owned</p>")
    local el = doc:query("p")
    if el then
        local owner = el:getDocument()
        example_print_log("document owner present = " .. tostring(owner ~= nil))
        example_print_log("document exposes setHtml = " .. tostring(owner and owner.setHtml ~= nil))
    end
end
```

---

#### `LHtmlElement:getHtml`

Returns this element's inner HTML.

```lua
LHtmlElement:getHtml()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Element inner HTML, or an empty string when unavailable. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div><span>inner</span></div>")
    local el = doc:query("div")
    if el then
        example_print_log("html = " .. el:getHtml())
    end
end
```

---

#### `LHtmlElement:getId`

Returns this element's id attribute.

```lua
LHtmlElement:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Id string, or nil when no id attribute exists. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div id='main'>content</div>")
    local el = doc:getElementById("main")
    if el then
        example_print_log("id = " .. tostring(el:getId()))
    end
end
```

---

#### `LHtmlElement:getRect`

Returns this element's layout rectangle after relayout if needed.

```lua
LHtmlElement:getRect()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate. |
| number | Y coordinate. |
| number | Width. |
| number | Height. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div style='width:100px;height:50px'>box</div>")
    doc:setViewport(800, 600)
    doc:relayout()
    local el = doc:query("div")
    if el then
        local x, y, w, h = el:getRect()
        example_print_log("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
    end
end
```

---

#### `LHtmlElement:getStyle`

Returns an inline or computed style value for this element.

```lua
LHtmlElement:getStyle(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | CSS property name. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | Style value string, or nil when missing. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div style='color:red'>R</div>")
    local el = doc:query("div")
    html_log("color=" .. tostring(el and el:getStyle("color")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:getTagName`

Returns this element's HTML tag name.

```lua
LHtmlElement:getTagName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Tag name, or an empty string for missing elements. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<section>stuff</section>")
    local root = doc:getRoot()
    html_log("tag=" .. root:getTagName())
    html_log("text=" .. root:getText())
    html_log("type=" .. root:type())
    html_log("doc type=" .. root:getDocument():type())
end
```

---

#### `LHtmlElement:getText`

Returns this element's text content.

```lua
LHtmlElement:getText()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Text content, or an empty string when none exists. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>Hello World</p>")
    local el = doc:query("p")
    if el then
        example_print_log("text = " .. el:getText())
    end
end
```

---

#### `LHtmlElement:hasClass`

Returns whether this element has a CSS class.

```lua
LHtmlElement:hasClass(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the class is present. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div class='visible'>Y</div>")
    local el = doc:query("div")
    if el then
        example_print_log("has visible = " .. tostring(el:hasClass("visible")))
    end
end
```

---

#### `LHtmlElement:off`

Removes an element-level event listener by handle.

```lua
LHtmlElement:off(handle)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `handle` | number | Listener handle returned by `on`. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div id='d'>X</div>")
    local el = doc:getElementById("d")
    if el then
        local h = el:on("hover", function()
        end)
        el:off(h)
    end
    example_print_log("handler removed")
end
```

---

#### `LHtmlElement:on`

Registers an element-level event listener.

```lua
LHtmlElement:on(event, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `event` | string | Event name to listen for. |
| `func` | function | Lua callback receiving an event table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Listener handle used by `off`. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<button id='btn'>Go</button>")
    local el = doc:getElementById("btn")
    if el then
        local handle = el:on("click", function()
            example_print_log("button clicked")
        end)
        example_print_log("element handle = " .. handle)
    end
end
```

---

#### `LHtmlElement:query`

Looks up the first descendant element matching a selector.

```lua
LHtmlElement:query(selector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `selector` | string | Selector supported by the HTML engine. |

**Returns**

| Type | Description |
|------|-------------|
| LuaValue | `[LHtmlElement](#lhtmlelement)` handle, or nil when no descendant matches. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div><span class='x'>found</span></div>")
    local div = doc:query("div")
    local span = div and div:query(".x")
    html_log("child query=" .. tostring(span and span:getText()))
    html_log("div tag=" .. tostring(div and div:getTagName()))
    html_log("span type=" .. tostring(span and span:type()))
    html_log("span class found=" .. tostring(span ~= nil))
end
```

---

#### `LHtmlElement:queryAll`

Returns all descendant elements matching a selector.

```lua
LHtmlElement:queryAll(selector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `selector` | string | Selector supported by the HTML engine. |

**Returns**

| Type | Description |
|------|-------------|
| [LHtmlElement](#lhtmlelement)[] | `[LHtmlElement](#lhtmlelement)` handles. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<ul><li>A</li><li>B</li></ul>")
    local ul = doc:query("ul")
    local items = ul and ul:queryAll("li") or {}
    html_log("child items=" .. #items)
    html_log("first child=" .. tostring(items[1] and items[1]:getText()))
    html_log("second child=" .. tostring(items[2] and items[2]:getText()))
    html_log("parent type=" .. tostring(ul and ul:type()))
end
```

---

#### `LHtmlElement:remove`

Removes this element from the document.

```lua
LHtmlElement:remove()
```

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div><p id='del'>gone</p></div>")
    local el = doc:getElementById("del")
    if el then el:remove() end
    html_log("element removed=" .. tostring(doc:getElementById("del") == nil))
    html_log("remaining paragraphs=" .. #(doc:queryAll("p")))
    html_log("root tag=" .. doc:getRoot():getTagName())
    html_log("type=" .. doc:getRoot():type())
end
```

---

#### `LHtmlElement:removeAttribute`

Removes an attribute from this element.

```lua
LHtmlElement:removeAttribute(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Attribute name to remove. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div data-x='1'>X</div>")
    local el = doc:query("div")
    if el then el:removeAttribute("data-x") end
    html_log("data-x removed=" .. tostring(el and el:getAttribute("data-x")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:removeClass`

Removes a CSS class from this element.

```lua
LHtmlElement:removeClass(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name to remove. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div class='active old'>X</div>")
    local el = doc:query("div")
    if el then el:removeClass("old") end
    html_log("old class removed=" .. tostring(el and el:hasClass("old")))
    html_log("active class remains=" .. tostring(el and el:hasClass("active")))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:setAttribute`

Sets or clears an attribute on this element.

```lua
LHtmlElement:setAttribute(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Attribute name. |
| `value?` | string | Attribute value, or nil to remove the attribute. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<img/>")
    local el = doc:query("img")
    if el then el:setAttribute("src", "content/examples/assets/images/sample_icon.png") end
    html_log("src set=" .. tostring(el and el:getAttribute("src")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("type=" .. tostring(el and el:type()))
    html_log("doc type=" .. tostring(el and el:getDocument():type()))
end
```

---

#### `LHtmlElement:setHtml`

Replaces this element's inner HTML and may invalidate descendant element handles.

```lua
LHtmlElement:setHtml(html)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `html` | string | New inner HTML source. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>old</div>")
    local el = doc:query("div")
    if el then el:setHtml("<b>new</b>") end
    html_log("html updated=" .. tostring(el and el:getHtml()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:setId`

Sets or clears this element's id attribute.

```lua
LHtmlElement:setId(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id?` | string | Id attribute value, or nil to clear. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>content</div>")
    local root = doc:getRoot()
    root:setId("container")
    html_log("id set to=" .. tostring(root:getId()))
    html_log("lookup works=" .. tostring(doc:getElementById("container") ~= nil))
    html_log("root tag=" .. root:getTagName())
    html_log("root type=" .. root:type())
end
```

---

#### `LHtmlElement:setStyle`

Sets or clears a style property on this element.

```lua
LHtmlElement:setStyle(name, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | CSS property name. |
| `value?` | string | CSS value, or nil to clear the property. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<p>text</p>")
    local el = doc:query("p")
    if el then el:setStyle("font-size", "20px") end
    html_log("font-size=" .. tostring(el and el:getStyle("font-size")))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("text=" .. tostring(el and el:getText()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:setText`

Replaces this element's text content.

```lua
LHtmlElement:setText(text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `text` | string | New text content. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<span>old</span>")
    local el = doc:query("span")
    if el then el:setText("new text") end
    html_log("text set=" .. tostring(el and el:getText()))
    html_log("html=" .. tostring(el and el:getHtml()))
    html_log("tag=" .. tostring(el and el:getTagName()))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:toggleClass`

Toggles a CSS class on this element, optionally forcing the final state.

```lua
LHtmlElement:toggleClass(name, force)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Class name to toggle. |
| `force?` | boolean | Forced state. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Final class presence, or false when the element is unavailable. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div class='on'>Z</div>")
    local el = doc:query("div")
    local first = el and el:toggleClass("on")
    local second = el and el:toggleClass("on")
    html_log("toggle result first=" .. tostring(first))
    html_log("toggle result second=" .. tostring(second))
    html_log("has class now=" .. tostring(el and el:hasClass("on")))
    html_log("type=" .. tostring(el and el:type()))
end
```

---

#### `LHtmlElement:type`

Returns the Lua-visible type name for this HTML element handle.

```lua
LHtmlElement:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LHtmlElement](#lhtmlelement)`. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    html_log("type=" .. el:type())
    html_log("tag=" .. el:getTagName())
    html_log("text=" .. el:getText())
    html_log("document type=" .. el:getDocument():type())
end
```

---

#### `LHtmlElement:typeOf`

Returns whether this element handle matches a supported type name.

```lua
LHtmlElement:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LHtmlElement](#lhtmlelement)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local doc = lurek.html.newDocument("<div>X</div>")
    local el = doc:getRoot()
    html_log("is HtmlElement=" .. tostring(el:typeOf("LHtmlElement")))
    html_log("is LObject=" .. tostring(el:typeOf("LObject")))
    html_log("is HtmlDocument=" .. tostring(el:typeOf("LHtmlDocument")))
    html_log("type=" .. el:type())
end
```

---
