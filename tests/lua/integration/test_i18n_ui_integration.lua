-- Integration: localized strings flowing into UI labels
-- @describe integration: localized strings in UI labels

-- @describe integration: localized strings in UI labels
describe("integration: localized strings in UI labels", function()
    -- @integration lurek.i18n.loadTable
    -- @integration lurek.i18n.setLanguage
    -- @integration lurek.i18n.t
    -- @integration LLabel:getText
    -- @integration LLabel:setText
    -- @integration lurek.ui.newLabel
    -- @integration lurek.i18n.loadTable
    -- @integration lurek.i18n.setLanguage
    -- @integration lurek.i18n.t
    -- @integration lurek.ui.newLabel
    it("localization provides string and UI label stores it", function()
        -- Load English locale inline
        lurek.i18n.setLanguage("en")
        lurek.i18n.loadTable("en", {
            btn_start  = "Start Game",
            btn_quit   = "Quit",
            lbl_score  = "Score",
        })

        local start_text = lurek.i18n.t("btn_start")
        local quit_text  = lurek.i18n.t("btn_quit")
        local score_text = lurek.i18n.t("lbl_score")

        expect_equal("Start Game", start_text, "start button text")
        expect_equal("Quit",       quit_text,  "quit button text")
        expect_equal("Score",      score_text, "score label text")

        -- Create UI label and apply localized string
        local label = lurek.ui.newLabel()
        label:setText(start_text)
        expect_equal("Start Game", label:getText(), "label stores first localized string")

        label:setText(quit_text)
        expect_equal("Quit", label:getText(), "label stores replacement localized string")
    end)

    -- @integration lurek.i18n.loadTable
    -- @integration lurek.i18n.setLanguage
    -- @integration lurek.i18n.t
    -- @integration LLabel:getText
    -- @integration LLabel:setText
    -- @integration lurek.ui.newLabel
    it("switching locale updates UI text", function()
        lurek.i18n.loadTable("en", { greeting = "Hello" })
        lurek.i18n.loadTable("pl", { greeting = "Cze    " })

        lurek.i18n.setLanguage("en")
        local en_text = lurek.i18n.t("greeting")
        expect_equal("Hello", en_text, "English greeting")

        lurek.i18n.setLanguage("pl")
        local pl_text = lurek.i18n.t("greeting")
        expect_equal("Cze    ", pl_text, "Polish greeting")

        local label = lurek.ui.newLabel()
        label:setText(pl_text)
        expect_equal("Cze    ", label:getText(), "label stores Polish greeting")

        label:setText(en_text)
        expect_equal("Hello", label:getText(), "label stores English greeting after locale switch")
    end)

end)
test_summary()
