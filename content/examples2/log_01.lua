--@api-stub: lurek.log.setLevel
-- Log sinks and dynamic level changes.
do
    lurek.log.setLevel("debug")
    lurek.log.addSink({ level = "debug", callback = function(msg) print(msg) end })
    lurek.log.setLevel("info")
    lurek.log.setLevel("warn")
    lurek.log.setLevel("error")
end

print("log_01.lua")
