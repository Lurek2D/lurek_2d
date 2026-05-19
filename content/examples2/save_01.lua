--@api-stub: LSaveManager:type
--@api-stub: LSaveManager:typeOf
-- Type introspection on LSaveManager.
do
    ---@type LSaveManager
    local sm = lurek.save.newSaveManager()
    print(sm:type())
    print(sm:typeOf("LSaveManager"))
    print(sm:typeOf("Object"))
end

print("save_01.lua")
