import QtQuick
import QtTest

import Logos.Controls

TestCase {
    id: tc
    name: "LogosIcon"
    width: 200
    height: 200
    when: windowShown

    LogosIcon {
        id: icon
        source: "qrc:/test-icon.png"
        width: 24
        height: 24
        anchors.centerIn: parent
    }

    function init() {
        icon.source = "qrc:/test-icon.png"
        icon.color = "#ff8800"
        icon.brightness = 0
        icon.width = 24
        icon.height = 24
    }

    function test_source_round_trips() {
        icon.source = "qrc:/test-icon.png"
        compare(icon.source.toString(), "qrc:/test-icon.png")
    }

    function test_source_propagates_to_underlying_image() {
        icon.source = "qrc:/test-icon.png"
        compare(icon.imageItem.source.toString(), "qrc:/test-icon.png")
    }

    function test_source_can_be_cleared() {
        icon.source = ""
        compare(icon.source.toString(), "")
        compare(icon.imageItem.source.toString(), "")
    }

    function test_color_propagates_to_multieffect() {
        icon.color = "#112233"
        tryCompare(icon.effectItem, "colorizationColor", "#112233")
    }

    function test_brightness_propagates_to_multieffect() {
        icon.brightness = 1.0
        tryCompare(icon.effectItem, "brightness", 1.0)
    }

    function test_default_brightness_is_zero() {
        var defaults = Qt.createQmlObject(
            'import Logos.Controls; LogosIcon { source: "qrc:/test-icon.png" }',
            tc, "defaultsBrightness")
        compare(defaults.brightness, 0)
        defaults.destroy()
    }

    function test_default_implicit_size_is_20() {
        var defaults = Qt.createQmlObject(
            'import Logos.Controls; LogosIcon { source: "qrc:/test-icon.png" }',
            tc, "defaults")
        compare(defaults.implicitWidth, 20)
        compare(defaults.implicitHeight, 20)
        defaults.destroy()
    }

    function test_sourceSize_scales_with_render_size_for_hidpi() {
        icon.width = 32
        icon.height = 32
        compare(icon.imageItem.sourceSize.width, 64)
        compare(icon.imageItem.sourceSize.height, 64)
    }

    function test_inspection_aliases_resolve() {
        verify(icon.imageItem, "imageItem must resolve")
        verify(icon.effectItem, "effectItem must resolve")
    }
}
