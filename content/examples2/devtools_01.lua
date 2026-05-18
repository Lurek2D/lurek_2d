--- DevTools Module Part 2: LFileWatcher and LReplConsole Methods

--@api-stub: LFileWatcher:onChanged
-- Sets the callback invoked when a watched file changes.
do
    local watcher = lurek.devtools.newFileWatcher("assets/")
    watcher:onChanged(function()
        print("file changed!")
    end)
    print("onChange callback set")
end

--@api-stub: LFileWatcher:check
-- Polls the watcher and invokes the callback on change.
do
    local watcher = lurek.devtools.newFileWatcher("scripts/")
    local changed = watcher:check()
    print("change detected = " .. tostring(changed))
end

--@api-stub: LFileWatcher:getPath
-- Returns the watched path.
do
    local watcher = lurek.devtools.newFileWatcher("content/")
    print("watching = " .. watcher:getPath())
end

--@api-stub: LFileWatcher:cancel
-- Cancels this watcher and removes its callback.
do
    local watcher = lurek.devtools.newFileWatcher("temp/")
    watcher:cancel()
    print("watcher cancelled")
end

--@api-stub: LFileWatcher:type
-- Returns the type name ("LFileWatcher").
do
    local watcher = lurek.devtools.newFileWatcher("x/")
    print("type = " .. watcher:type())
end

--@api-stub: LFileWatcher:typeOf
-- Returns whether this handle matches a type name.
do
    local watcher = lurek.devtools.newFileWatcher("y/")
    print("is LFileWatcher = " .. tostring(watcher:typeOf("LFileWatcher")))
end

--@api-stub: LReplConsole:eval
-- Evaluates Lua code and records it in history.
do
    local repl = lurek.devtools.newRepl(100)
    local result = repl:eval("return 1 + 1")
    print("eval result type = " .. type(result))
end

--@api-stub: LReplConsole:history
-- Returns the REPL command history.
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("local x = 1")
    repl:eval("local y = 2")
    local h = repl:history()
    print("history entries = " .. #h)
end

--@api-stub: LReplConsole:clear
-- Clears the REPL command history.
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("print('hi')")
    repl:clear()
    print("history after clear = " .. repl:len())
end

--@api-stub: LReplConsole:len
-- Returns the number of entries in history.
do
    local repl = lurek.devtools.newRepl(100)
    repl:eval("a = 1")
    repl:eval("b = 2")
    print("history len = " .. repl:len())
end

--@api-stub: LReplConsole:type
-- Returns the type name ("LReplConsole").
do
    local repl = lurek.devtools.newRepl()
    print("type = " .. repl:type())
end

--@api-stub: LReplConsole:typeOf
-- Returns whether this handle matches a type name.
do
    local repl = lurek.devtools.newRepl()
    print("is LReplConsole = " .. tostring(repl:typeOf("LReplConsole")))
end

print("devtools_01.lua")
