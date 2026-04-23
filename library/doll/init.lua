--- library.doll — Socket-Based Visual Composition Engine
-- Assembles composite visual objects (characters, vehicles, faces) from
-- interchangeable Part sprites attached to named Socket positions on a
-- DollTemplate blueprint. No physics, no collision, no gameplay logic —
-- purely visual composition with draw ordering.
--
-- The library never calls rendering APIs directly; it produces a sorted
-- draw list via `Doll:getDrawList()` that the caller hands to its renderer
-- (typically `lurek.render`). The legacy `Doll:draw()` method is retained
-- as a deprecated no-op for source compatibility.
--
-- @module library.doll
-- @status full
-- @see lurek.render       caller-side renderer that consumes `getDrawList()` entries
-- @see lurek.image           image/texture loader for `Part:setTexture()`
-- @see lurek.serial.toJson  serialise template + part state for persistence

local M = {}

-- Optional logging via lurek.log (no-op if unavailable)
local _log = lurek and lurek.log or nil
local function _logInfo(msg)  if _log then _log.info("[doll] " .. msg) end end
local function _logWarn(msg)  if _log then _log.warn("[doll] " .. msg) end end

-- ── Part ──────────────────────────────────────────────────────────────────────

--- Create a new Part (visual element for attaching to a Doll socket).
-- Parts carry texture, transform, colour, flip, draw-order, and arbitrary
-- key-value attributes. Attach to a Doll socket with `doll:attach()`.
-- @treturn Part blank part with defaults
function M.newPart()
    local part = {}

    local _partType   = ""
    local _texture    = nil
    local _quad       = nil
    local _offsetX    = 0
    local _offsetY    = 0
    local _rotation   = 0
    local _scaleX     = 1
    local _scaleY     = 1
    local _originX    = 0
    local _originY    = 0
    local _drawOrder  = 0
    local _visible    = true
    local _colorR     = 1
    local _colorG     = 1
    local _colorB     = 1
    local _colorA     = 1
    local _flipX      = false
    local _flipY      = false
    local _followsRotation = true
    local _fixture    = nil
    local _attributes = {}

    -- Texture / Quad
    --- Return the texture assigned to this part.
    -- @treturn any texture handle (or nil)
    function part:getTexture()       return _texture end
    --- Assign a texture to this part.
    -- @tparam any tex texture handle from `lurek.image`
    function part:setTexture(tex)    _texture = tex end
    --- Return the texture quad (sub-region) for this part.
    -- @treturn any quad (or nil)
    function part:getQuad()          return _quad end
    --- Set the texture quad (sub-region) for this part.
    -- @tparam any q quad value
    function part:setQuad(q)         _quad = q end

    -- Local Transform
    --- Return the local offset of this part from its socket origin.
    -- @treturn number offsetX
    -- @treturn number offsetY
    function part:getOffset()        return _offsetX, _offsetY end
    --- Set the local offset of this part from its socket origin.
    -- @tparam number x horizontal offset
    -- @tparam number y vertical offset
    function part:setOffset(x, y)    _offsetX = x; _offsetY = y end
    --- Return the local rotation of this part in radians.
    -- @treturn number rotation
    function part:getRotation()      return _rotation end
    --- Set the local rotation of this part in radians.
    -- @tparam number r rotation in radians
    function part:setRotation(r)     _rotation = r end
    --- Return the local scale of this part as (scaleX, scaleY).
    -- @treturn number scaleX
    -- @treturn number scaleY
    function part:getScale()         return _scaleX, _scaleY end
    --- Set part scale. Passing a single number sets uniform scale.
    -- @tparam number sx horizontal scale
    -- @tparam[opt=sx] number sy vertical scale
    function part:setScale(sx, sy)
        if type(sx) ~= "number" then error("setScale: sx must be a number", 2) end
        if sy ~= nil and type(sy) ~= "number" then error("setScale: sy must be a number", 2) end
        _scaleX = sx; _scaleY = sy or sx
    end
    --- Return the render origin (pivot point) of this part.
    -- @treturn number originX
    -- @treturn number originY
    function part:getOrigin()        return _originX, _originY end
    --- Set the render origin (pivot point) of this part.
    -- @tparam number ox horizontal origin
    -- @tparam number oy vertical origin
    function part:setOrigin(ox, oy)  _originX = ox; _originY = oy end

    -- Draw Order & Type
    --- Return the draw order key for this part.
    -- @treturn number draw order value
    function part:getDrawOrder()     return _drawOrder end
    --- Set part draw order (z-sort key).
    -- @tparam number n draw order value
    function part:setDrawOrder(n)
        if type(n) ~= "number" then error("setDrawOrder: n must be a number", 2) end
        _drawOrder = n
    end
    --- Return the part type string (used for socket type-filter matching).
    -- @treturn string part type
    function part:getPartType()      return _partType end
    --- Set the part type string.
    -- @tparam string t part type identifier
    function part:setPartType(t)     _partType = t end

    -- Visibility & Appearance
    --- Return true if this part is currently visible.
    -- @treturn boolean
    function part:isVisible()        return _visible end
    --- Set visibility of this part.
    -- @tparam boolean v true to show, false to hide
    function part:setVisible(v)      _visible = v end
    --- Return the RGBA colour tint of this part.
    -- @treturn number r
    -- @treturn number g
    -- @treturn number b
    -- @treturn number a
    function part:getColor()         return _colorR, _colorG, _colorB, _colorA end
    --- Set the RGBA colour tint of this part.
    -- @tparam number r red (0–1)
    -- @tparam number g green (0–1)
    -- @tparam number b blue (0–1)
    -- @tparam[opt=1] number a alpha (0–1)
    function part:setColor(r, g, b, a)
        _colorR = r; _colorG = g; _colorB = b; _colorA = a or 1
    end
    --- Return the flip flags for this part.
    -- @treturn boolean flipX
    -- @treturn boolean flipY
    function part:getFlip()          return _flipX, _flipY end
    --- Set horizontal and vertical flip flags.
    -- @tparam boolean fx flip horizontally
    -- @tparam[opt=false] boolean fy flip vertically
    function part:setFlip(fx, fy)    _flipX = fx; _flipY = fy or false end

    -- Behaviour
    --- Return true if this part inherits the socket's rotation.
    -- @treturn boolean
    function part:getFollowsRotation()    return _followsRotation end
    --- Set whether this part inherits the socket's rotation.
    -- @tparam boolean f true to inherit socket rotation
    function part:setFollowsRotation(f)   _followsRotation = f end

    -- Attributes (user-defined key-value store)
    --- Get the value of a user-defined attribute by key.
    -- @tparam string key attribute key
    -- @return any stored value, or nil
    function part:getAttribute(key)       return _attributes[key] end
    --- Set a user-defined attribute value.
    -- @tparam string key attribute key
    -- @param val any value to store
    function part:setAttribute(key, val)  _attributes[key] = val end
    --- Return a list of all attribute keys on this part.
    -- @treturn table array of key strings
    function part:getAttributeKeys()
        local keys = {}
        for k in pairs(_attributes) do keys[#keys + 1] = k end
        return keys
    end

    -- Optional physics fixture ref (stored, never called)
    --- Return the optional physics fixture reference.
    -- @return any fixture or nil
    function part:getFixture()       return _fixture end
    --- Store an optional physics fixture reference on this part.
    -- @param f any fixture reference
    function part:setFixture(f)      _fixture = f end

    --- Get the absolute scale magnitude, ignoring flip.
    -- Useful when flip is used for mirroring but the caller needs the
    -- positive magnitude (e.g. bounding-box calculation).
    -- @treturn number absolute scaleX
    -- @treturn number absolute scaleY
    function part:getAbsoluteScale()
        return math.abs(_scaleX), math.abs(_scaleY)
    end

    --- Get a shallow copy of all attributes.
    -- @treturn table key-value copy of all stored attributes
    function part:getAttributes()
        local copy = {}
        for k, v in pairs(_attributes) do copy[k] = v end
        return copy
    end

    return part
end

-- ── DollTemplate ──────────────────────────────────────────────────────────────

--- Create a new DollTemplate (socket layout blueprint).
-- A template defines named sockets at fixed positions and rotations.
-- Each socket has an acceptType filter and a drawOrder for z-sorting.
-- @tparam[opt=""] string name template name
-- @treturn DollTemplate empty template
function M.newTemplate(name)
    local tmpl = {}
    local _name    = name or ""
    local _sockets = {}       -- ordered array of socket defs
    local _index   = {}       -- name → array index for O(1) lookup

    --- Return the template name.
    -- @treturn string template name
    function tmpl:getName()          return _name end
    --- Set the template name.
    -- @tparam string n new template name
    function tmpl:setName(n)         _name = n end

    --- Add a socket to the template.
    -- Returns true on success, or false plus a message if the name is
    -- invalid or already registered.
    -- @tparam string socketName unique socket name (non-empty)
    -- @tparam[opt=""] string acceptType part type filter ("" = accept anything)
    -- @tparam[opt=0] number x offset X from doll origin
    -- @tparam[opt=0] number y offset Y from doll origin
    -- @tparam[opt=0] number rotation socket rotation in radians
    -- @tparam[opt=0] number drawOrder z-sort key
    -- @treturn boolean success
    -- @treturn[opt] string error message on failure
    function tmpl:addSocket(socketName, acceptType, x, y, rotation, drawOrder)
        if type(socketName) ~= "string" or socketName == "" then
            return false, "socket name must be a non-empty string"
        end
        if _index[socketName] then
            _logWarn("addSocket: duplicate socket name '" .. socketName .. "'")
            return false, "socket already exists: " .. socketName
        end
        local socket = {
            name       = socketName,
            acceptType = acceptType or "",
            x          = x or 0,
            y          = y or 0,
            rotation   = rotation or 0,
            drawOrder  = drawOrder or 0,
        }
        _sockets[#_sockets + 1] = socket
        _index[socketName] = #_sockets
        return true
    end

    --- Remove a socket by name. Returns false if the socket does not exist.
    -- @tparam string socketName socket to remove
    -- @treturn boolean true if removed
    function tmpl:removeSocket(socketName)
        local idx = _index[socketName]
        if not idx then return false end
        table.remove(_sockets, idx)
        _index[socketName] = nil
        -- rebuild index
        for i, s in ipairs(_sockets) do _index[s.name] = i end
        return true
    end

    --- Return a copy of the socket definition, or nil if not found.
    -- @tparam string socketName socket to look up
    -- @treturn table|nil socket definition copy `{name, acceptType, x, y, rotation, drawOrder}`
    function tmpl:getSocket(socketName)
        local idx = _index[socketName]
        if not idx then return nil end
        local s = _sockets[idx]
        return {
            name       = s.name,
            acceptType = s.acceptType,
            x          = s.x,
            y          = s.y,
            rotation   = s.rotation,
            drawOrder  = s.drawOrder,
        }
    end

    --- Return an ordered array of socket names.
    -- @treturn table array of socket name strings
    function tmpl:getSocketNames()
        local names = {}
        for _, s in ipairs(_sockets) do names[#names + 1] = s.name end
        return names
    end

    --- Return the number of sockets in this template.
    -- @treturn number socket count
    function tmpl:getSocketCount()
        return #_sockets
    end

    --- Internal: iterate raw sockets (used by Doll).
    function tmpl:_iterSockets()
        return ipairs(_sockets)
    end

    return tmpl
end

-- ── Doll ──────────────────────────────────────────────────────────────────────

--- Create a new Doll (runtime composite instance of a template).
-- A Doll binds a DollTemplate to a world-space transform and holds
-- Part instances attached to template sockets.
-- @tparam DollTemplate template socket layout to use
-- @treturn Doll runtime doll instance
function M.newDoll(template)
    local doll = {}

    local _template = template
    local _x        = 0
    local _y        = 0
    local _rotation = 0
    local _scaleX   = 1
    local _scaleY   = 1
    local _visible  = true
    local _slots    = {}       -- socketName → Part
    local _body     = nil
    local _userData = nil
    local _draw_warned = false  -- one-time deprecation warning gate for doll:draw()

    -- Transform
    --- Return the world-space position of this doll.
    -- @treturn number x
    -- @treturn number y
    function doll:getPosition()      return _x, _y end
    --- Set the world-space position of this doll.
    -- @tparam number x world x position
    -- @tparam number y world y position
    function doll:setPosition(x, y)  _x = x; _y = y end
    --- Return the world-space rotation of this doll in radians.
    -- @treturn number rotation
    function doll:getRotation()      return _rotation end
    --- Set the world-space rotation of this doll in radians.
    -- @tparam number r rotation in radians
    function doll:setRotation(r)     _rotation = r end
    --- Return the world-space scale of this doll.
    -- @treturn number scaleX
    -- @treturn number scaleY
    function doll:getScale()         return _scaleX, _scaleY end
    --- Set the world-space scale of this doll.
    -- @tparam number sx horizontal scale
    -- @tparam[opt=sx] number sy vertical scale
    function doll:setScale(sx, sy)   _scaleX = sx; _scaleY = sy or sx end

    -- Template
    --- Return the DollTemplate this doll was created from.
    -- @treturn DollTemplate
    function doll:getTemplate()      return _template end

    -- Visibility
    --- Return true if this doll is currently visible.
    -- @treturn boolean
    function doll:isVisible()        return _visible end
    --- Set the visibility of this doll.
    -- @tparam boolean v true to show, false to hide
    function doll:setVisible(v)      _visible = v end

    -- Optional body / user data refs
    --- Return the optional physics body reference attached to this doll.
    -- @return any body or nil
    function doll:getBody()          return _body end
    --- Store an optional physics body reference on this doll.
    -- @param b any body reference
    function doll:setBody(b)         _body = b end
    --- Return the optional user-data reference on this doll.
    -- @return any user data or nil
    function doll:getUserData()      return _userData end
    --- Store an optional user-data reference on this doll.
    -- @param v any user data
    function doll:setUserData(v)     _userData = v end

    --- Attach a Part to a named socket.
    -- Returns false if socket not found, type mismatch, or invalid args.
    -- @tparam string socketName socket to attach to
    -- @tparam Part part part instance to attach
    -- @treturn boolean success
    function doll:attach(socketName, part)
        if type(socketName) ~= "string" or socketName == "" then
            return false
        end
        local socket = _template:getSocket(socketName)
        if not socket then return false end
        -- type compatibility check
        local accept = socket.acceptType
        if accept ~= "" and part:getPartType() ~= accept then
            return false
        end
        _slots[socketName] = part
        _logInfo("attached '" .. (part:getPartType() or "?") .. "' to '" .. socketName .. "'")
        return true
    end

    --- Detach the Part from a socket, returning it.
    -- @tparam string socketName socket to detach from
    -- @treturn Part|nil detached part, or nil if socket was empty
    function doll:detach(socketName)
        local part = _slots[socketName]
        _slots[socketName] = nil
        if part then
            _logInfo("detached from '" .. socketName .. "'")
        end
        return part
    end

    --- Return the Part attached at `socketName`, or nil.
    -- @tparam string socketName socket to query
    -- @treturn Part|nil
    function doll:getPartAt(socketName)
        return _slots[socketName]
    end

    --- Return the socket name the given Part is attached to, or nil.
    -- @tparam Part part part to find
    -- @treturn string|nil socket name
    function doll:findSocket(part)
        for name, p in pairs(_slots) do
            if p == part then return name end
        end
        return nil
    end

    --- Detach all parts from all sockets.
    function doll:detachAll()
        _slots = {}
    end

    --- Return an array of socket names that currently have a part attached.
    -- @treturn table array of socket name strings
    function doll:getAttachedSockets()
        local names = {}
        for name in pairs(_slots) do names[#names + 1] = name end
        return names
    end

    --- Return an array of socket names that are currently empty.
    -- @treturn table array of socket name strings
    function doll:getEmptySockets()
        local names = {}
        for _, socketName in ipairs(_template:getSocketNames()) do
            if not _slots[socketName] then
                names[#names + 1] = socketName
            end
        end
        return names
    end

    --- Compute world-transform draw list sorted by drawOrder.
    -- Each entry: {socketName, part, x, y, rotation, scaleX, scaleY,
    -- originX, originY, drawOrder}.
    --
    -- **Flip behaviour**: Part flip flags produce negative scale values
    -- (e.g. scaleX = -2 when flipX is true and doll+part scale = 2).
    -- This is intentional — GPU scale-based mirroring. Use
    -- `doll.getAbsoluteScale(entry)` if you need the positive magnitude.
    --
    -- **Transform order**: Part offset is rotated by socket rotation
    -- before being added to the socket position (socket-local space).
    -- The combined offset is then scaled by doll scale and rotated by
    -- doll rotation.
    --
    -- Does NOT filter by part visibility — caller handles that.
    -- @treturn table ordered draw list
    function doll:getDrawList()
        local list = {}
        local cos_r = math.cos(_rotation)
        local sin_r = math.sin(_rotation)

        for _, socket in _template:_iterSockets() do
            local part = _slots[socket.name]
            if part then
                local ox, oy = part:getOffset()

                -- Rotate part offset by socket rotation so offsets are
                -- relative to the socket's local coordinate frame.
                local sock_cos = math.cos(socket.rotation)
                local sock_sin = math.sin(socket.rotation)
                local rotOX = ox * sock_cos - oy * sock_sin
                local rotOY = ox * sock_sin + oy * sock_cos

                local localX = (socket.x + rotOX) * _scaleX
                local localY = (socket.y + rotOY) * _scaleY

                local worldX = _x + localX * cos_r - localY * sin_r
                local worldY = _y + localX * sin_r + localY * cos_r

                local partRot = part:getRotation()
                local worldRot
                if part:getFollowsRotation() then
                    worldRot = _rotation + socket.rotation + partRot
                else
                    worldRot = socket.rotation + partRot
                end

                local psx, psy = part:getScale()
                local pfx, pfy = part:getFlip()
                local worldSX = _scaleX * psx * (pfx and -1 or 1)
                local worldSY = _scaleY * psy * (pfy and -1 or 1)

                local partOX, partOY = part:getOrigin()

                list[#list + 1] = {
                    socketName = socket.name,
                    part       = part,
                    x          = worldX,
                    y          = worldY,
                    rotation   = worldRot,
                    scaleX     = worldSX,
                    scaleY     = worldSY,
                    originX    = partOX,
                    originY    = partOY,
                    drawOrder  = socket.drawOrder + part:getDrawOrder(),
                }
            end
        end

        -- sort by drawOrder ascending; break ties by socket definition order
        table.sort(list, function(a, b)
            return a.drawOrder < b.drawOrder
        end)

        return list
    end

    --- Deprecated convenience draw shim — retained only as a no-op.
    --
    -- The original implementation referenced an undefined global (`lurek`)
    -- and a non-existent namespace (`lurek.render`), so the call chain was a
    -- silent no-op in every build. Library code must not call rendering
    -- APIs directly (per `library.*` conventions), so the correct path
    -- now is for the caller to iterate `Doll:getDrawList()` and dispatch
    -- the entries to `lurek.render` (or any other renderer) themselves.
    --
    -- This method emits a one-time warning on first invocation and then
    -- returns immediately. It will be removed in a future major bump.
    --
    -- @deprecated use `Doll:getDrawList()` and dispatch to `lurek.render` in caller code
    -- @see lurek.render
    function doll:draw()
        if not _draw_warned then
            _draw_warned = true
            _logWarn("Doll:draw() is a deprecated no-op; iterate getDrawList() and call your renderer (e.g. lurek.render) from caller code")
        end
        return
    end

    return doll
end

--- Get the absolute scale magnitude from a draw-list entry.
-- Strips the sign introduced by flip flags, returning positive values.
-- @tparam table entry a draw-list entry from Doll:getDrawList()
-- @treturn number absolute scaleX
-- @treturn number absolute scaleY
function M.getAbsoluteScale(entry)
    return math.abs(entry.scaleX), math.abs(entry.scaleY)
end

return M
