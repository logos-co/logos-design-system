import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Icons

TestCase {
    name: "LogosCopyButton"
    width: 400
    height: 200
    when: windowShown

    // Positioned mid-window so the feedback tip has room to float above
    // (popups can never render outside the test window).
    LogosCopyButton {
        id: btn
        x: 100
        y: 60
        value: "QmAbc123"
        feedbackDuration: 0
    }

    SignalSpy {
        id: copySpy
        target: btn
        signalName: "copied"
    }

    SignalSpy {
        id: clickSpy
        target: btn
        signalName: "clicked"
    }

    function init() {
        btn.value = "QmAbc123"
        btn.enabled = true
        btn.feedbackDuration = 0
        btn.feedbackText = "Copied"
        btn.size = 24
        btn.iconSize = 16
        btn.feedbackTipItem.close()
        copySpy.clear()
        clickSpy.clear()
    }

    function test_aliases_resolve() {
        verify(btn.iconImage)
        verify(btn.mouseAreaItem)
        verify(btn.feedbackTipItem)
        verify(btn.feedbackLabelItem)
    }

    function test_defaults_are_compact_ghost() {
        compare(btn.size, 24)
        compare(btn.iconSize, 16)
        compare(btn.flat, true)
        compare(btn.backgroundItem.visible, false)
    }

    function test_icon_source_is_copy_by_default() {
        compare(btn.iconSource.toString(), LogosIcons.copy.toString())
    }

    function test_icon_swaps_to_check_after_copy() {
        btn.feedbackDuration = 5000
        btn.copy()
        tryCompare(btn, "iconSource", LogosIcons.check)
    }

    function test_copy_emits_copied_with_value() {
        btn.copy()
        compare(copySpy.count, 1)
        compare(copySpy.signalArguments[0][0], "QmAbc123")
    }

    function test_click_via_mouseArea_copies_and_emits_clicked() {
        btn.mouseAreaItem.clicked(null)
        compare(clickSpy.count, 1)
        compare(copySpy.count, 1)
        compare(copySpy.signalArguments[0][0], "QmAbc123")
    }

    function test_empty_value_does_not_emit() {
        btn.value = ""
        btn.copy()
        compare(copySpy.count, 0)
    }

    function test_disabled_does_not_copy() {
        btn.enabled = false
        btn.copy()
        compare(copySpy.count, 0)
    }

    function test_recentlyCopied_true_after_copy() {
        btn.feedbackDuration = 5000
        btn.copy()
        tryCompare(btn, "recentlyCopied", true)
    }

    function test_feedback_text_default_is_copied() {
        compare(btn.feedbackLabelItem.text, "Copied")
    }

    function test_feedbackText_flows_to_label() {
        btn.feedbackText = "Copied to clipboard"
        tryCompare(btn.feedbackLabelItem, "text", "Copied to clipboard")
    }

    function test_feedback_tip_opens_above_button_on_copy() {
        btn.feedbackDuration = 5000
        btn.copy()
        tryCompare(btn.feedbackTipItem, "opened", true)
        verify(btn.feedbackTipItem.y < 0,
               "feedback tip should float above the button, y = " + btn.feedbackTipItem.y)
    }
}
