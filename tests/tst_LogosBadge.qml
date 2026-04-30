import QtQuick
import QtQuick.Layouts
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    name: "LogosBadge"
    width: 200
    height: 50
    when: windowShown

    LogosBadge {
        id: badge
        text: "alpha"
    }

    function init() {
        badge.text = "alpha"
        badge.iconSource = ""
        badge.color = Theme.palette.accentOrange
    }

    function test_aliases_resolve() {
        verify(badge.iconItem)
        verify(badge.labelItem)
        verify(badge.backgroundItem)
    }

    function test_background_color_derives_from_color() {
        // bg defaults to a tinted version of `color` (alpha 0.18); both share RGB
        compare(badge.backgroundItem.color.r, badge.color.r)
        compare(badge.backgroundItem.color.g, badge.color.g)
        compare(badge.backgroundItem.color.b, badge.color.b)
        verify(badge.backgroundItem.color.a < 1.0)
    }

    function test_border_color_matches_text_color() {
        compare(badge.backgroundItem.border.color.toString(), badge.color.toString())
    }

    function test_radius_setter_propagates() {
        badge.radius = 999
        tryCompare(badge.backgroundItem, "radius", 999)
    }

    function test_border_width_setter_propagates() {
        badge.borderWidth = 0
        tryCompare(badge.backgroundItem.border, "width", 0)
    }

    function test_text_round_trips() {
        badge.text = "beta"
        tryCompare(badge.labelItem, "text", "beta")
    }

    function test_text_is_uppercased() {
        compare(badge.labelItem.font.capitalization, Font.AllUppercase)
    }

    function test_label_color_defaults_to_accent_orange() {
        compare(badge.labelItem.color.toString(), Theme.palette.accentOrange.toString())
    }

    function test_color_setter_propagates() {
        badge.color = "#00FF00"
        // Compare color objects, not strings — Qt's color.toString() is
        // lowercase ("#00ff00"), so a string compare against "#00FF00"
        // fails on case alone.
        tryCompare(badge.labelItem, "color", Qt.color("#00FF00"))
    }

    function test_icon_hidden_when_no_source() {
        // Layout.preferredWidth collapsing to 0 is the public-facing signal
        // that the icon slot is hidden. Image.visible can flake in offscreen
        // mode for reasons unrelated to our reactive logic.
        compare(badge.iconItem.Layout.preferredWidth, 0)
    }

    function test_icon_visible_when_source_set() {
        badge.iconSource = "qrc:/test-icon.png"
        tryCompare(badge.iconItem.Layout, "preferredWidth", 12)
    }
}
