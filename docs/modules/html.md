# Html

## Summary

This module provides the HTML/CSS user interface subsystem, letting developers build interactive menus and HUDs. It parses markup and CSS stylesheets into dynamic DOM trees. The layout engine computes bounds using a box model, resolving cascades into precise pixel coordinates for rendering.

The document orchestrator manages the UI lifecycle, handling layout passes, styling cascades, and viewport resizes. It converts CSS declarations into normalized color vectors and size scales. Styles are resolved deterministically across elements, allowing developers to manage visuals through stylesheets.

For user interactions, the module handles clicks, keyboard focus, and text inputs. Input events are dispatched down the element tree, triggering hover states or text changes. DOM elements can be mutated at runtime by toggling classes, editing attributes, or replacing inner HTML fragments.

Additionally, selector queries support class, ID, and ancestry matching to locate elements. The completed layout output compiles into draw command streams containing render rectangles and text blocks ready for GPU rendering.

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
        print("event isDefaultPrevented = " .. tostring(type(ev.isDefaultPrevented) == "function"))
    end)
    print("module isDefaultPrevented = " .. tostring(type(lurek.html.isDefaultPrevented)))
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
    print("loaded document = " .. tostring(ok))
    if ok then
        print("loaded doc type = " .. doc:type())
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
    local doc = lurek.html.newDocument()
    print("doc created = " .. tostring(doc ~= nil))
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
        print("event preventDefault = " .. tostring(type(ev.preventDefault) == "function"))
    end)
    print("module preventDefault = " .. tostring(type(lurek.html.preventDefault)))
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
        print("event stopPropagation = " .. tostring(type(ev.stopPropagation) == "function"))
    end)
    print("module stopPropagation = " .. tostring(type(lurek.html.stopPropagation)))
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
    print("css-flex supported = " .. tostring(ok))
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
    print("css appended")
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
    print("css cleared")
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
    doc:draw(10, 20)
    print("drawn at 10,20")
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
        print("found: " .. el:getText())
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
    print("html = " .. html)
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
    print("root tag = " .. root:getTagName())
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
    print("viewport = " .. w .. "x" .. h)
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
    print("dirty = " .. tostring(doc:isDirty()))
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
    print("keypressed handled = " .. tostring(handled))
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
    print("mousemoved handled = " .. tostring(handled))
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
    print("mousepressed handled = " .. tostring(handled))
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
    print("mousereleased handled = " .. tostring(handled))
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
    print("unregistered")
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
        print("clicked!")
    end)
    print("registered handle = " .. handle)
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
        print("query found: " .. el:getText())
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
    print("items = " .. #items)
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
    doc:relayout()
    print("relayout done")
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
    doc:render(0, 0)
    print("rendered")
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
    print("css set")
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
    print("html set")
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
    print("viewport set to 1024x768")
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
    print("textinput handled = " .. tostring(handled))
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
    print("type = " .. doc:type())
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
    print("is HtmlDocument = " .. tostring(doc:typeOf("LHtmlDocument")))
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
    local doc = lurek.html.newDocument()
    doc:update(0.016)
    print("updated")
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
    print("wheelmoved handled = " .. tostring(handled))
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
    print("class added")
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
    print("html appended")
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
    print("blurred")
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
    print("focused")
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
    print("href = " .. tostring(el and el:getAttribute("href")))
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
        print("owner type = " .. el:getDocument():type())
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
        print("html = " .. el:getHtml())
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
        print("id = " .. tostring(el:getId()))
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
        print("rect = " .. x .. "," .. y .. " " .. w .. "x" .. h)
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
    print("color = " .. tostring(el and el:getStyle("color")))
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
    print("tag = " .. root:getTagName())
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
        print("text = " .. el:getText())
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
        print("has visible = " .. tostring(el:hasClass("visible")))
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
    print("handler removed")
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
            print("button clicked")
        end)
        print("element handle = " .. handle)
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
    print("child query = " .. tostring(span and span:getText()))
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
    print("child items = " .. #(ul and ul:queryAll("li") or {}))
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
    print("element removed")
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
    print("data-x removed")
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
    print("class removed")
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
    print("src set")
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
    print("html updated")
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
    print("id set")
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
    print("style set")
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
    print("text set")
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
    print("toggle result = " .. tostring(el and el:toggleClass("on")))
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
    print("type = " .. el:type())
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
    print("is HtmlElement = " .. tostring(el:typeOf("LHtmlElement")))
end
```

---
