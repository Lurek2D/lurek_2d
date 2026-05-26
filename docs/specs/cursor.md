# cursor

## Overview

Cursor management system with system cursors, custom image cursors, animated cursors, trails, context-sensitive switching, and zoom magnifier.

## Tier

Feature Systems

## Dependencies

- None (standalone)

## Public API (`lurek.cursor`)

### Constructors
- `newManager()` — Create a cursor manager.
- `newCustom(width, height, hotspot_x, hotspot_y)` — Create custom cursor image.
- `newAnimated(looping)` — Create animated cursor.
- `systemCursors()` — Get list of available system cursor names.

### Manager Methods
- `mgr:setSystem(name)` — Set active cursor to system cursor.
- `mgr:setCustom(cursor)` — Set active cursor to custom image.
- `mgr:setAnimated(cursor)` — Set active cursor to animated.
- `mgr:setContext(ctx)` — Set context for context-sensitive switching.
- `mgr:addRule(ctx, cursor_name)` — Map context to system cursor.
- `mgr:removeRule(ctx)` — Remove context rule.
- `mgr:update(x, y, dt)` — Update cursor state each frame.
- `mgr:setVisible(bool)` / `mgr:isVisible()` — Visibility.
- `mgr:setLocked(bool)` / `mgr:isLocked()` — Lock/grab.
- `mgr:getPosition()` — Get (x, y).
- `mgr:getContext()` — Get active context name.
- `mgr:enableTrail(r, g, b, lifetime)` — Enable fade point trail.
- `mgr:enableLineTrail(r, g, b, width)` — Enable line trail.
- `mgr:disableTrail()` — Disable trail.
- `mgr:enableZoom(magnification, radius)` — Enable magnifier.
- `mgr:disableZoom()` — Disable magnifier.

### Custom Cursor Methods
- `cursor:setPixel(x, y, r, g, b, a)` — Set pixel.
- `cursor:getPixel(x, y)` — Get pixel (r, g, b, a).
- `cursor:getSize()` — Get (width, height).
- `cursor:getHotspot()` — Get (hx, hy).

### Animated Cursor Methods
- `anim:addFrame(cursor, duration_ms)` — Add frame.
- `anim:update(dt)` — Advance animation.
- `anim:currentIndex()` / `anim:frameCount()` — Frame info.
- `anim:currentScale()` — Get pulse scale.
- `anim:setPulse(min, max, speed)` / `anim:clearPulse()` — Pulse config.
- `anim:reset()` — Reset to first frame.

## Invariants

- System cursor names: arrow, ibeam, wait, crosshair, wait_arrow, size_nwse, size_nesw, size_we, size_ns, size_all, no, hand.
- Custom cursors store RGBA pixel data.
- Animated cursors loop or stop at last frame.
- Context rules replace existing rule for same context.
- Zoom magnification clamped to 1.0-10.0.
