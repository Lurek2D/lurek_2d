--@api-stub: LReplSession:type
--@api-stub: LReplSession:typeOf
-- Type introspection on LReplSession.
do
    ---@type LReplSession
    local sess = lurek.repl.new()
    print(sess:type())
    print(sess:typeOf("LReplSession"))
    print(sess:typeOf("Object"))
end

print("repl_01.lua")
