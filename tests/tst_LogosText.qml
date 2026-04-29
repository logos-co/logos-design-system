import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosText"
    width: 200
    height: 100
    when: windowShown

    LogosText {
        id: txt
        text: "Hello"
    }

    function test_renders_text() {
        compare(txt.text, "Hello")
    }

    function test_default_color_matches_theme() {
        compare(txt.color.toString(), Theme.palette.text.toString())
    }

    function test_default_pixelSize_matches_theme_primary() {
        compare(txt.font.pixelSize, Theme.typography.primaryText)
    }

    function test_default_weight_is_regular() {
        compare(txt.font.weight, Theme.typography.weightRegular)
    }
}
