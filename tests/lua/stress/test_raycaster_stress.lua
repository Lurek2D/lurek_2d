-- Stress coverage for explicitly driven isolated raycaster views.

-- @describe raycaster stress: isolated view state
describe("raycaster stress: isolated view state", function()
    -- @stress lurek.raycaster.newView
    it("keeps 256 view configurations independent", function()
        local views = {}
        for index = 1, 256 do
            local view = lurek.raycaster.newView({
                viewport = { x = index, y = 0, w = 160, h = 90 },
                rays = 32 + (index % 32),
            })
            view:setCameraState({
                x = index,
                y = index * 2,
                angle = 0,
                fov = math.pi / 3,
            })
            views[index] = view
        end
        expect_equal(1, views[1]:getViewport().x)
        expect_equal(256, views[256]:getCameraState().x)
    end)
end)

test_summary()
