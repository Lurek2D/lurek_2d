-- Integration: i18n text source serialized with data and consumed by UI layout.
-- @describe integration: ui + i18n + data
describe("integration: ui + i18n + data", function()
    -- @integration lurek.binary.pack
    -- @integration lurek.binary.unpack
    -- @integration lurek.i18n.loadTable
    -- @integration lurek.i18n.setLanguage
    -- @integration lurek.i18n.t
    -- @integration LLabel:getText
    -- @integration LUiWidget:findById
    -- @integration lurek.ui.getRoot
    -- @integration lurek.ui.getWidgetCount
    -- @integration lurek.ui.loadLayout
    -- @integration lurek.binary.pack
    -- @integration lurek.binary.unpack
    -- @integration lurek.i18n.loadTable
    -- @integration lurek.i18n.setLanguage
    -- @integration lurek.i18n.t
    -- @integration lurek.ui.getRoot
    -- @integration lurek.ui.getWidgetCount
    -- @integration lurek.ui.loadLayout
    it("builds a localized UI label from serialized bytes", function()
        local src = "Hello"
        local packed = lurek.binary.pack("s", src)
        local title = lurek.binary.unpack("s", packed)
        expect_equal("Hello", title, "packed text should roundtrip")

        lurek.i18n.loadTable("en", { ui_title = title })
        lurek.i18n.setLanguage("en")
        local localized = lurek.i18n.t("ui_title")
        expect_equal("Hello", localized, "localized text should resolve")

        local before = lurek.ui.getWidgetCount()
        local layout_root = lurek.ui.loadLayout({
            type = "panel",
            id = "serialized_ui_root",
            children = {
                { type = "label", id = "serialized_ui_title", text = localized },
            },
        })

        local root = lurek.ui.getRoot()
        local label = root:findById("serialized_ui_title")

        expect_true(layout_root:isValid(), "ui layout returns a live typed root handle")
        expect_true(lurek.ui.getWidgetCount() > before, "layout adds widgets to the UI tree")
        expect_not_nil(label, "loaded layout exposes the localized label by id")
        expect_equal("Hello", label:getText(), "label text matches localized serialized value")
    end)
end)
test_summary()
