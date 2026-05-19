--@api-stub: LDepthSorter:add
--@api-stub: LDepthSorter:flush
--@api-stub: LDepthSorter:getCount
-- LDepthSorter: queue items and flush in depth order.
do
    local ds = lurek.scene.newDepthSorter()
    ds:add(function() lurek.render.circle("fill", 100, 100, 20) end, 5.0)
    ds:add(function() lurek.render.circle("fill", 200, 100, 20) end, 2.0)
    local count = ds:getCount()
    ds:flush()
    print("depth sorter count:", count)
end

--@api-stub: LDepthSorter:type
--@api-stub: LDepthSorter:typeOf
--@api-stub: lurek.scene.newScene
-- LDepthSorter type checks and newScene.
do
    local ds = lurek.scene.newDepthSorter()
    local t = ds:type()
    local ok = ds:typeOf("LDepthSorter")
    local sn = lurek.scene.newScene({name = "test_new", enter = function() end, draw = function() end})
    print("type:", t, "newScene ok")
end

--@api-stub: lurek.scene.process
--@api-stub: lurek.scene.processPhysics
--@api-stub: lurek.scene.removeData
-- Scene process, processPhysics, and removeData.
do
    lurek.scene.process(0.016)
    lurek.scene.processPhysics(0.016)
    lurek.scene.setData("_test_key", 42)
    lurek.scene.removeData("_test_key")
    print("process, processPhysics, removeData ok")
end

--@api-stub: lurek.scene.render
--@api-stub: lurek.scene.renderUi
--@api-stub: lurek.scene.setCurrentLayer
-- Scene render, renderUi, and layer selection.
do
    lurek.scene.setCurrentLayer(0)
    lurek.scene.render()
    lurek.scene.renderUi()
    local layer = lurek.scene.getCurrentLayer()
    print("render, renderUi, setCurrentLayer ok")
end

--@api-stub: lurek.scene.unregisterScene
-- Scene unregister.
do
    lurek.scene.define({name = "_tmp_unreg", enter = function() end, draw = function() end})
    lurek.scene.unregisterScene("_tmp_unreg")
    print("unregisterScene ok")
end
