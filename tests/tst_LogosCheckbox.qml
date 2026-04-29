import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosCheckbox"
    width: 400
    height: 200
    when: windowShown

    LogosCheckbox {
        id: cbox
        text: "Accept"
    }

    SignalSpy {
        id: clickedSpy
        target: cbox
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        cbox.checked = false
        cbox.enabled = true
        cbox.text = "Accept"
    }

    function test_renders_text() {
        compare(cbox.text, "Accept")
    }

    function test_text_setter_updates_label() {
        cbox.text = "Updated"
        tryCompare(cbox.labelItem, "text", "Updated")
    }

    function test_checked_property_round_trips() {
        cbox.checked = true
        compare(cbox.checked, true)
        cbox.checked = false
        compare(cbox.checked, false)
    }

    function test_emits_clicked_when_invoked() {
        cbox.clicked()
        compare(clickedSpy.count, 1)
    }

    function test_indicator_alias_resolves() {
        verify(cbox.indicatorItem, "indicatorItem alias must resolve")
    }

    function test_label_alias_resolves() {
        verify(cbox.labelItem, "labelItem alias must resolve")
    }

    function test_label_color_switches_with_enabled() {
        cbox.enabled = true
        tryCompare(cbox.labelItem, "color", Theme.palette.text)
        cbox.enabled = false
        tryCompare(cbox.labelItem, "color", Theme.palette.textMuted)
    }
}
