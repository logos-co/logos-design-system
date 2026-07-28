import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Icons

TestCase {
    name: "LogosCopyableText"
    width: 400
    height: 200
    when: windowShown

    LogosCopyableText {
        id: copyable
        text: "QmAbc123"
        feedbackDuration: 0
        width: 300
    }

    SignalSpy {
        id: copySpy
        target: copyable
        signalName: "copied"
    }

    function init() {
        copyable.text = "QmAbc123"
        copyable.copyText = ""
        copyable.showCopyButton = true
        copyable.enabled = true
        copyable.feedbackDuration = 0
        copyable.textColor = Theme.palette.text
        copyable.feedbackText = "Copied"
        copySpy.clear()
    }

    function test_aliases_resolve() {
        verify(copyable.textItem)
        verify(copyable.copyButtonItem)
    }

    function test_showCopyButton_default_true() {
        compare(copyable.showCopyButton, true)
    }

    function test_text_flows_to_selectable() {
        tryCompare(copyable.textItem, "text", "QmAbc123")
        copyable.text = "other"
        tryCompare(copyable.textItem, "text", "other")
    }

    function test_selectable_is_readOnly() {
        compare(copyable.textItem.readOnly, true)
    }

    function test_copy_button_value_defaults_to_text() {
        tryCompare(copyable.copyButtonItem, "value", "QmAbc123")
    }

    function test_copyText_overrides_button_value() {
        copyable.copyText = "full-value-not-shown"
        tryCompare(copyable.copyButtonItem, "value", "full-value-not-shown")
    }

    function test_copy_emits_copied_with_text() {
        copyable.copy()
        compare(copySpy.count, 1)
        compare(copySpy.signalArguments[0][0], "QmAbc123")
    }

    function test_copyText_overrides_clipboard_value() {
        copyable.copyText = "full-value-not-shown"
        copyable.copy()
        compare(copySpy.count, 1)
        compare(copySpy.signalArguments[0][0], "full-value-not-shown")
    }

    function test_click_copy_button_copies() {
        copyable.copyButtonItem.mouseAreaItem.clicked(null)
        compare(copySpy.count, 1)
        compare(copySpy.signalArguments[0][0], "QmAbc123")
    }

    function test_icon_swaps_to_check_after_copy() {
        copyable.feedbackDuration = 5000
        copyable.copy()
        tryCompare(copyable.copyButtonItem, "iconSource", LogosIcons.check)
    }

    function test_empty_value_does_not_emit() {
        copyable.text = ""
        copyable.copyText = ""
        copyable.copy()
        compare(copySpy.count, 0)
    }

    function test_disabled_does_not_copy() {
        copyable.enabled = false
        copyable.copy()
        compare(copySpy.count, 0)
    }

    function test_recentlyCopied_true_after_copy() {
        copyable.feedbackDuration = 5000
        copyable.copy()
        tryCompare(copyable, "recentlyCopied", true)
    }

    function test_textColor_flows_to_selectable() {
        copyable.textColor = Theme.palette.textSecondary
        tryCompare(copyable.textItem, "color", Theme.palette.textSecondary)
    }

    function test_showCopyButton_false_hides_button() {
        copyable.showCopyButton = false
        tryCompare(copyable.copyButtonItem, "visible", false)
    }

    function test_selectable_supports_selectAll() {
        copyable.textItem.selectAll()
        compare(copyable.textItem.selectedText, "QmAbc123")
    }
}
