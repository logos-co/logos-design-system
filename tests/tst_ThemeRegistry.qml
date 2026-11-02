import QtQuick
import QtTest

import Logos.Theme
import LogosTests

// main.cpp gives the store tests/fixtures/themes, and registers
// ThemeInstaller (into a throwaway directory) and ThemeTestHelper.
TestCase {
    name: "ThemeRegistry"

    function initTestCase() {
        ThemeTestHelper.clearInstalled()
    }

    function cleanupTestCase() {
        Theme.setTheme("dark")
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

    function test_palette_tokens_match_dark_theme() {
        var tokens = ThemeRegistry.paletteTokens
        compare(tokens.length, 62)
        for (var i = 0; i < tokens.length; ++i)
            verify(Theme.darkTheme[tokens[i]] !== undefined, "DarkTheme lacks " + tokens[i])
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

    function test_newer_format_still_loads() {
        var r = ThemeTestHelper.parse(minimalDoc({ formatVersion: 2, palette: { text: "#000000" } }))
        verify(r.ok)
        verify(r.warnings.join(" ").indexOf("newer") >= 0)
        compare(r.theme.palette.text.r, 0)
    }

    // ----- discovery -----

    function test_discovers_valid_themes_only() {
        verify(findTheme("test.partial"), "test.partial not found")
        verify(!findTheme("test.broken"))
        verify(!findTheme("dark"))
        // Symlinked theme folders are skipped.
        verify(!findTheme("test.outside"))
    }

    // ----- Theme.qml -----

    function test_dark_is_the_default() {
        Theme.setTheme("dark")
        compare(Theme.currentTheme, "dark")
        verify(Theme.isDark)
        compare(Theme.palette, Theme.darkTheme)
    }

    function test_set_installed_theme() {
        Theme.setTheme("test.partial")
        compare(Theme.currentTheme, "test.partial")
        verify(!Theme.isDark)
        compare(Theme.palette.background.toString(), "#ffffff")
        compare(Theme.themeInfo["test.partial"].author, "tests")
        verify(Theme.themeNames.indexOf("test.partial") >= 0)
        Theme.setTheme("dark")
    }

    function test_partial_theme_falls_back_per_colour() {
        Theme.setTheme("test.partial")
        compare(Theme.palette.text.toString(), "#112233")
        // "surface": "red" was rejected, so it comes from dark.
        compare(Theme.palette.surface, Theme.darkTheme.surface)
        compare(Theme.palette.info, Theme.darkTheme.info)
        Theme.setTheme("dark")
    }

    function test_unknown_theme_is_refused() {
        Theme.setTheme("dark")
        Theme.setTheme("nobody.nothing")
        compare(Theme.currentTheme, "dark")
        compare(Theme.palette, Theme.darkTheme)
    }

    function test_switch_theme_cycles_through_installed() {
        Theme.setTheme("dark")
        var seen = {}
        for (var i = 0; i < Theme.themeNames.length; ++i) {
            seen[Theme.currentTheme] = true
            Theme.switchTheme()
        }
        compare(Object.keys(seen).length, Theme.themeNames.length)
        compare(Theme.currentTheme, "dark")
    }

    function test_choice_is_saved() {
        Theme.setTheme("test.partial")
        compare(ThemeTestHelper.savedTheme(), "test.partial")
        Theme.setTheme("dark")
        compare(ThemeTestHelper.savedTheme(), "dark")
    }

    function test_store_ignores_unknown_ids() {
        ThemeRegistry.current = "nobody.nothing"
        compare(ThemeRegistry.current, "dark")
        compare(ThemeTestHelper.savedTheme(), "dark")
    }

    function test_current_is_shared_state() {
        // Another engine's setTheme writes the shared state; this engine's
        // Theme must follow it.
        ThemeRegistry.current = "test.partial"
        compare(Theme.currentTheme, "test.partial")
        ThemeRegistry.current = "dark"
        compare(Theme.palette, Theme.darkTheme)
    }

    // ----- install -----

    function installPath(name) {
        return Qt.resolvedUrl("fixtures/install/" + name)
    }

    function test_install_valid_file_is_listed_at_once() {
        var r = ThemeInstaller.install(installPath("good.theme.json"))
        verify(r.ok, r.errors.join("; "))
        compare(r.id, "test.installed")
        compare(r.name, "Installed")
        // No reload step: the installer tells every registry itself.
        verify(findTheme("test.installed"))
        Theme.setTheme("test.installed")
        compare(Theme.palette.background.toString(), "#204060")
        Theme.setTheme("dark")
    }

    function test_install_refuses_invalid_file() {
        var r = ThemeInstaller.install(installPath("bad.theme.json"))
        verify(!r.ok)
        verify(r.errors.length > 0)
        verify(!findTheme("test.bad"))
    }

    function test_install_refuses_missing_and_remote_files() {
        verify(!ThemeInstaller.install(installPath("nope.json")).ok)
        verify(!ThemeInstaller.install("https://example.com/theme.json").ok)
    }

    // ----- what apps' QML can reach -----

    function test_registry_is_read_and_switch_only() {
        // Apps' views import Logos.Theme too; parsing and rescanning are the
        // host's business.
        compare(typeof ThemeRegistry.parse, "undefined")
        compare(typeof ThemeRegistry.reload, "undefined")
        compare(typeof ThemeRegistry.install, "undefined")
    }
}
