import QtQuick
import QtTest

import Logos.Theme

TestCase {
    name: "Theme"
    when: windowShown

    // The person's own choices live in the same file: put them back after.
    property string savedTheme: ""
    property real savedScale: 1.0

    function initTestCase() {
        savedTheme = Theme.currentTheme
        savedScale = Theme.textScale
    }

    function cleanupTestCase() {
        Theme.setTheme(savedTheme)
        Theme.setTextScale(savedScale)
    }

    function init() {
        Theme.setTheme("dark")
        Theme.setTextScale(1.0)
    }

    function test_three_themes_are_available() {
        compare(Theme.themeNames.sort(), ["dark", "high-contrast", "light"])
    }

    function test_every_theme_has_every_dark_colour() {
        // A name missing from a theme would read as undefined in it.
        var names = ["background", "backgroundSecondary", "surface", "surfaceRaised", "text",
                     "textSecondary", "border", "primary", "success", "error", "warning", "hover"]
        for (var t = 0; t < Theme.themeNames.length; ++t) {
            var palette = Theme.availableThemes[Theme.themeNames[t]]
            for (var i = 0; i < names.length; ++i)
                verify(palette[names[i]] !== undefined, Theme.themeNames[t] + " lacks " + names[i])
        }
    }

    function test_setTheme_switches_palette_and_isDark() {
        Theme.setTheme("light")
        compare(Theme.currentTheme, "light")
        compare(Theme.isDark, false)
        compare(Theme.palette, Theme.lightTheme)
        Theme.setTheme("high-contrast")
        compare(Theme.isDark, true)
        compare(Theme.palette, Theme.highContrastTheme)
    }

    function test_unknown_theme_is_refused() {
        Theme.setTheme("light")
        ignoreWarning(/Invalid theme/)
        Theme.setTheme("sepia")
        compare(Theme.currentTheme, "light")
    }

    function test_text_scale_scales_typography() {
        var body = Theme.typography.primaryText
        Theme.setTextScale(1.5)
        compare(Theme.typography.primaryText, Math.round(14 * 1.5))
        compare(Theme.typography.scaled(10), 15)
        Theme.actualSizeText()
        compare(Theme.typography.primaryText, body)
    }

    function test_text_scale_is_clamped_and_stepped() {
        Theme.setTextScale(5)
        compare(Theme.textScale, 1.6)
        Theme.setTextScale(0.1)
        compare(Theme.textScale, 0.85)
        Theme.actualSizeText()
        Theme.biggerText()
        compare(Theme.textScale, 1.1)
        Theme.smallerText()
        Theme.smallerText()
        compare(Theme.textScale, 0.9)
    }
}
