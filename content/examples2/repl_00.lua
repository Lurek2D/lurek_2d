--- REPL Module: interactive Lua evaluation session

--@api-stub: lurek.repl.new
--@api-stub: lurek.basic creation
-- Creating a REPL session with default history size.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    print("type = " .. repl:type())
    print("is LReplSession = " .. tostring(repl:typeOf("LReplSession")))
    print("initial len = " .. repl:len())
end

--@api-stub: lurek.repl.new with max_history
-- Creating a session with limited history.
do
    ---@type LReplSession
    local repl = lurek.repl.new(10)
    print("len = " .. repl:len())
end

--@api-stub: LReplSession:eval
-- Evaluating Lua expressions.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    local r1 = repl:eval("return 2 + 2")
    print("2+2 = " .. r1)
    local r2 = repl:eval("return 'hello' .. ' world'")
    print("concat = " .. r2)
    local r3 = repl:eval("return math.pi")
    print("pi = " .. r3)
    print("history len = " .. repl:len())
end

--@api-stub: LReplSession:eval
--@api-stub: LReplSession:statements and errors
-- Evaluating statements and handling errors.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    local r1 = repl:eval("local x = 42")
    print("statement = " .. r1)
    local r2 = repl:eval("return undefined_var")
    print("nil result = " .. r2)
    local r3 = repl:eval("invalid syntax !@#")
    print("error = " .. r3)
    print("all recorded, len = " .. repl:len())
end

--@api-stub: LReplSession:eval
--@api-stub: LReplSession:multiple expressions
-- Building up state across evaluations.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("x = 10")
    repl:eval("y = 20")
    local sum = repl:eval("return x + y")
    print("x + y = " .. sum)
    repl:eval("function double(n) return n * 2 end")
    local doubled = repl:eval("return double(x)")
    print("double(x) = " .. doubled)
end

--@api-stub: LReplSession:history
-- Retrieving evaluation history.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:eval("return 3")
    local hist = repl:history()
    print("history entries = " .. #hist)
    for i, entry in ipairs(hist) do
        print("  " .. i .. ": " .. entry)
    end
end

--@api-stub: LReplSession:history
--@api-stub: LReplSession:bounded overflow
-- History respects max_history limit.
do
    ---@type LReplSession
    local repl = lurek.repl.new(3)
    repl:eval("return 'first'")
    repl:eval("return 'second'")
    repl:eval("return 'third'")
    repl:eval("return 'fourth'")
    repl:eval("return 'fifth'")
    local hist = repl:history()
    print("bounded history count = " .. #hist)
    for i, entry in ipairs(hist) do
        print("  " .. i .. ": " .. entry)
    end
    print("len = " .. repl:len())
end

--@api-stub: LReplSession:complete
-- Tab-completion of Lua symbols.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("myVariable = 42")
    repl:eval("myFunction = function() end")
    repl:eval("myTable = {}")
    local completions = repl:complete("my")
    print("completions for 'my' = " .. #completions)
    for i, c in ipairs(completions) do
        print("  " .. c)
    end
    local math_completions = repl:complete("math.")
    print("math. completions = " .. #math_completions)
    for i, c in ipairs(math_completions) do
        if i <= 5 then
            print("  " .. c)
        end
    end
end

--@api-stub: LReplSession:complete
--@api-stub: LReplSession:empty prefix
-- Completing with empty prefix.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    local all = repl:complete("")
    print("all globals count = " .. #all)
end

--@api-stub: LReplSession:clear
-- Clearing session history.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    repl:eval("return 1")
    repl:eval("return 2")
    repl:eval("return 3")
    print("before clear = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
    local hist = repl:history()
    print("history after clear = " .. #hist)
end

--@api-stub: LReplSession:len
-- Tracking history length.
do
    ---@type LReplSession
    local repl = lurek.repl.new()
    print("empty = " .. repl:len())
    repl:eval("return 'a'")
    print("after 1 eval = " .. repl:len())
    repl:eval("return 'b'")
    repl:eval("return 'c'")
    print("after 3 evals = " .. repl:len())
    repl:clear()
    print("after clear = " .. repl:len())
end

--@api-stub: LReplSession interactive loop pattern
-- Simulating a multi-line REPL interaction.
do
    ---@type LReplSession
    local repl = lurek.repl.new(100)
    local inputs = {
        "scores = {}",
        "for i = 1, 5 do scores[i] = i * 10 end",
        "return #scores",
        "return scores[3]",
        "table.insert(scores, 99)",
        "return scores[#scores]",
    }
    for _, input in ipairs(inputs) do
        local result = repl:eval(input)
        print("> " .. input)
        if result ~= "" then
            print("  => " .. result)
        end
    end
    print("session length = " .. repl:len())
end

print("repl_00.lua")
