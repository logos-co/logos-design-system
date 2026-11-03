import QtQuick
import QtTest

import Logos.Theme
import LogosTests

// main.cpp gives the store tests/fixtures/themes, and registers ThemeManager
// (the host's object, installing into a throwaway directory) and
// ThemeTestHelper.
TestCase {
    name: "ThemeRegistry"

    function initTestCase() {
        ThemeTestHelper.clearInstalled()
    }

    function cleanupTestCase() {
        ThemeManager.select("dark")
        ThemeTestHelper.clearInstalled()
    }

    function findTheme(id) {
        var list = ThemeRegistry.themes
        for (var i = 0; i < list.length; ++i)
            if (list[i].id === id)
                return list[i]
        return null
    }

    function minimalDoc(extra) {
        var doc = { formatVersion: 1, id: "test.doc", name: "Doc", author: "tests", mode: "dark" }
        for (var k in extra)
            doc[k] = extra[k]
        return JSON.stringify(doc)
    }

    // ----- colour names -----

    // Both ways: a colour added to DarkTheme.qml must be added to the list too.
    function test_palette_tokens_match_dark_theme() {
        var tokens = ThemeRegistry.paletteTokens
        var darkColours = []
        for (var key in Theme.darkTheme) {
            var v = Theme.darkTheme[key]
            if (v !== null && typeof v === "object" && v.hslHue !== undefined)
                darkColours.push(key)
        }
        compare(darkColours.slice().sort(), tokens.slice().sort())
    }

    // ----- parsing -----

    function test_minimal_document_is_valid() {
        var r = ThemeTestHelper.parse(minimalDoc({}))
        verify(r.ok, r.errors.join("; "))
        compare(r.theme.id, "test.doc")
        compare(Object.keys(r.theme.palette).length, 0)
    }

    function test_rgba_is_css_order() {
        var r = ThemeTestHelper.parse(minimalDoc({ palette: { scrim: "#FF000080" } }))
        verify(r.ok)
        var c = r.theme.palette.scrim
        compare(c.r, 1)
        compare(c.g, 0)
        fuzzyCompare(c.a, 128 / 255, 0.001)
    }

    function test_bad_values_are_dropped_with_warnings() {
        var r = ThemeTestHelper.parse(minimalDoc({
            palette: { text: "red", background: "#12345", notAToken: "#000000", surface: 7 },
            extra: 1
        }))
        verify(r.ok)
        compare(Object.keys(r.theme.palette).length, 0)
        compare(r.warnings.length, 5, r.warnings.join("; "))
    }

    function test_unsupported_sections_warn() {
        var r = ThemeTestHelper.parse(minimalDoc({ radius: { scale: 0 }, typography: {}, spacing: {} }))
        verify(r.ok)
        compare(r.warnings.length, 3, r.warnings.join("; "))
        verify(r.warnings.join(" ").indexOf("isn't supported yet") >= 0)
    }

    function test_derived_tokens_follow_their_source() {
        var r = ThemeTestHelper.parse(minimalDoc({ palette: { primary: "#336699" } }))
        var border = r.theme.palette.primaryBorder
        compare(border.r, r.theme.palette.primary.r)
        fuzzyCompare(border.a, 0.4, 0.01)
    }

    function test_rejects_invalid_documents() {
        var cases = [
            "",
            "{ not json",
            "[1, 2, 3]",
            JSON.stringify({ id: "test.x", name: "X", author: "a", mode: "dark" }),
            minimalDoc({ id: "../../etc" }),
            minimalDoc({ id: "Upper.Case" }),
            minimalDoc({ id: "nodot" }),
            minimalDoc({ id: "dark" }),
            minimalDoc({ mode: "sepia" }),
            minimalDoc({ name: "" }),
            minimalDoc({ author: "x".repeat(41) }),
            // Names are drawn by controls that auto-detect rich text.
            minimalDoc({ name: "<img src=x>" }),
            minimalDoc({ author: "a & b" }),
            minimalDoc({ name: "line\nbreak" }),
        ]
        for (var i = 0; i < cases.length; ++i) {
            var r = ThemeTestHelper.parse(cases[i])
            verify(!r.ok, "case " + i + " should be rejected: " + cases[i])
            verify(r.errors.length > 0)
        }
    }

    function test_rejects_oversized_document() {
        var r = ThemeTestHelper.parse(minimalDoc({ padding: "x".repeat(70 * 1024) }))
        verify(!r.ok)
    }

    function test_format_version_must_be_whole() {
        verify(!ThemeTestHelper.parse(minimalDoc({ formatVersion: 1.2 })).ok)
        verify(!ThemeTestHelper.parse(minimalDoc({ formatVersion: "1" })).ok)
        verify(!ThemeTestHelper.parse(minimalDoc({ formatVersion: 0 })).ok)
    }

    function test_strict_refuses_a_palette_that_is_not_an_object() {
        var doc = minimalDoc({ palette: "not-an-object" })
        verify(!ThemeTestHelper.parse(doc, true).ok)
        verify(ThemeTestHelper.parse(doc).ok)
    }

    function test_strict_refuses_bad_colour_values() {
        var doc = minimalDoc({ palette: { surface: "red", notAToken: "#000000" } })
        var strict = ThemeTestHelper.parse(doc, true)
        verify(!strict.ok)
        verify(strict.errors.join(" ").indexOf("palette.surface") >= 0)
        // Unknown names stay warnings, so a theme for a newer format installs.
        verify(strict.errors.join(" ").indexOf("notAToken") < 0)
        verify(ThemeTestHelper.parse(doc).ok)
    }

    // Gaps are filled from Dark, which would be unreadable in a light theme.
    function test_light_theme_must_set_every_colour() {
        var partial = ThemeTestHelper.parse(minimalDoc({ mode: "light",
                                                         palette: { background: "#FFFFFF" } }))
        verify(!partial.ok)
        verify(partial.errors.join(" ").indexOf("missing") >= 0)

        var full = {}
        var tokens = ThemeRegistry.paletteTokens
        for (var i = 0; i < tokens.length; ++i)
            full[tokens[i]] = "#EEEEEE"
        delete full.primaryBorder          // derived from primary
        delete full.borderTertiaryMuted    // derived from borderTertiary
        var r = ThemeTestHelper.parse(minimalDoc({ mode: "light", palette: full }))
        verify(r.ok, r.errors.join("; "))
    }

    function test_newer_format_still_loads() {
        var r = ThemeTestHelper.parse(minimalDoc({ formatVersion: 2, palette: { text: "#000000" } }))
        verify(r.ok)
        verify(r.warnings.join(" ").indexOf("newer") >= 0)
        compare(r.theme.palette.text.r, 0)
    }

    // ----- discovery -----

    function test_discovers_valid_themes_only() {
        verify(findTheme("test.partial"), "test.partial not found")
        // 00-imported also says test.partial and sorts first, but a theme's
        // folder must be named after its id, so it can't shadow the real one.
        compare(findTheme("test.partial").name, "Test Partial")
        verify(!findTheme("test.broken"))
        verify(!findTheme("dark"))
        // Symlinked theme folders are skipped.
        verify(!findTheme("test.outside"))
    }

    // ----- Theme.qml -----

    function test_dark_is_the_default() {
        ThemeManager.select("dark")
        compare(Theme.currentTheme, "dark")
        verify(Theme.isDark)
        compare(Theme.palette, Theme.darkTheme)
    }

    function test_select_installed_theme() {
        verify(ThemeManager.select("test.light"))
        compare(Theme.currentTheme, "test.light")
        verify(!Theme.isDark)
        compare(Theme.palette.background.toString(), "#fafafa")
        compare(Theme.themeInfo["test.light"].author, "tests")
        verify(Theme.themeNames.indexOf("test.light") >= 0)
        ThemeManager.select("dark")
    }

    function test_partial_theme_falls_back_per_colour() {
        ThemeManager.select("test.partial")
        compare(Theme.palette.text.toString(), "#112233")
        // "surface": "red" was dropped while loading, so it comes from dark.
        compare(Theme.palette.surface, Theme.darkTheme.surface)
        compare(Theme.palette.info, Theme.darkTheme.info)
        ThemeManager.select("dark")
    }

    function test_unknown_theme_is_refused() {
        ThemeManager.select("dark")
        verify(!ThemeManager.select("nobody.nothing"))
        compare(Theme.currentTheme, "dark")
        compare(ThemeTestHelper.savedTheme(), "dark")
    }

    // In the host's directory, never the app's own settings: an isolated
    // instance (Basecamp's --user-dir) must not share it.
    // There is only one copy of the design system here: the store says so.
    function test_store_is_registered_once() {
        verify(ThemeTestHelper.storeIsRegistered())
    }

    function test_choice_is_saved_in_the_hosts_directory() {
        ThemeManager.select("test.partial")
        compare(ThemeTestHelper.savedTheme(), "test.partial")
        ThemeManager.select("dark")
        compare(ThemeTestHelper.savedTheme(), "dark")
        verify(!ThemeTestHelper.appSettingsHaveTheme())
    }

    // Basecamp has one QML engine per view; all of them must follow a switch.
    function test_other_engine_follows_a_switch() {
        compare(ThemeTestHelper.fromOtherEngine("current"), "dark")
        ThemeManager.select("test.partial")
        compare(ThemeTestHelper.fromOtherEngine("current"), "test.partial")
        compare(ThemeTestHelper.fromOtherEngine("background").toString(), "#ffffff")
        ThemeManager.select("dark")
        compare(ThemeTestHelper.fromOtherEngine("current"), "dark")
        ThemeTestHelper.closeOtherEngine()
    }

    // ----- install -----

    function installPath(name) {
        return Qt.resolvedUrl("fixtures/install/" + name)
    }

    function test_install_valid_file_is_listed_at_once() {
        var r = ThemeManager.install(installPath("good.theme.json"))
        verify(r.ok, r.errors.join("; "))
        compare(r.id, "test.installed")
        compare(r.name, "Installed")
        verify(findTheme("test.installed"))
        ThemeManager.select("test.installed")
        compare(Theme.palette.background.toString(), "#204060")
        ThemeManager.select("dark")
    }

    function test_reinstall_replaces_the_theme() {
        verify(ThemeManager.install(installPath("good.theme.json")).ok)
        ThemeManager.select("test.installed")
        verify(ThemeManager.install(installPath("good-v2.theme.json")).ok)
        compare(Theme.palette.background.toString(), "#406080")
        compare(Theme.themeInfo["test.installed"].name, "Installed v2")
        ThemeManager.select("dark")
    }

    // The saved choice survives, so the theme comes back if its file does.
    function test_removed_theme_shows_dark_until_it_returns() {
        verify(ThemeManager.install(installPath("good.theme.json")).ok)
        ThemeManager.select("test.installed")
        ThemeTestHelper.clearInstalled()
        compare(ThemeRegistry.current, "dark")
        compare(Theme.currentTheme, "dark")
        compare(ThemeTestHelper.savedTheme(), "test.installed")
        verify(ThemeManager.install(installPath("good.theme.json")).ok)
        compare(ThemeRegistry.current, "test.installed")
        ThemeManager.select("dark")
    }

    function test_install_refuses_invalid_file() {
        var r = ThemeManager.install(installPath("bad.theme.json"))
        verify(!r.ok)
        verify(r.errors.length > 0)
        verify(!findTheme("test.bad"))
    }

    function test_install_refuses_bad_colour_values() {
        var r = ThemeManager.install(installPath("bad-colour.theme.json"))
        verify(!r.ok)
        verify(r.errors.join(" ").indexOf("palette.surface") >= 0)
        verify(!findTheme("test.badcolour"))
    }

    // test.partial comes from the fixtures folder; a copy installed elsewhere
    // would never be shown.
    function test_install_refuses_an_id_from_another_folder() {
        var r = ThemeManager.install(installPath("shadowed.theme.json"))
        verify(!r.ok)
        verify(r.errors.join(" ").indexOf("test.partial") >= 0)
        compare(Theme.themeInfo["test.partial"].name, "Test Partial")
    }

    function test_remove_deletes_the_theme() {
        verify(ThemeManager.install(installPath("good.theme.json")).ok)
        var r = ThemeManager.remove("test.installed")
        verify(r.ok, r.errors.join("; "))
        compare(r.name, "Installed")
        verify(!findTheme("test.installed"))
    }

    // Removed on purpose, so it isn't brought back if the file is added again.
    function test_removing_the_current_theme_switches_to_dark() {
        verify(ThemeManager.install(installPath("good.theme.json")).ok)
        ThemeManager.select("test.installed")
        verify(ThemeManager.remove("test.installed").ok)
        compare(Theme.currentTheme, "dark")
        compare(ThemeTestHelper.savedTheme(), "dark")
        verify(ThemeManager.install(installPath("good.theme.json")).ok)
        compare(Theme.currentTheme, "dark")
        verify(ThemeManager.remove("test.installed").ok)
    }

    function test_remove_refuses_dark_unknown_and_other_folders() {
        verify(!ThemeManager.remove("dark").ok)
        verify(!ThemeManager.remove("nobody.nothing").ok)
        // test.partial comes from the fixtures folder, not the manager's.
        var r = ThemeManager.remove("test.partial")
        verify(!r.ok)
        verify(r.errors.join(" ").indexOf("built in") >= 0)
        verify(findTheme("test.partial"))
    }

    function test_install_refuses_missing_and_remote_files() {
        verify(!ThemeManager.install(installPath("nope.json")).ok)
        verify(!ThemeManager.install("https://example.com/theme.json").ok)
    }

    // ----- what apps' QML can reach -----

    // Apps' views import Logos.Theme too: they can read the theme, not change it.
    function test_qml_can_read_but_not_switch() {
        var threw = false
        try {
            ThemeRegistry.current = "test.partial"
        } catch (e) {
            threw = true
        }
        verify(threw, "ThemeRegistry.current must be read-only")
        compare(Theme.currentTheme, "dark")
        compare(typeof Theme.setTheme, "undefined")
        compare(typeof Theme.switchTheme, "undefined")
        compare(typeof ThemeRegistry.install, "undefined")
        compare(typeof ThemeRegistry.parse, "undefined")
    }
}
