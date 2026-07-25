import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosButton"
    width: 400
    height: 200
    when: windowShown

    LogosButton {
        id: btn
        text: "Click me"
        anchors.centerIn: parent
    }

    // Sizing pair: same label, one with an icon. Declared rather than toggled
    // at runtime because the layout only re-reads an item's visibility when
    // the scene itself is shown, which it is not under the test runner.
    LogosButton {
        id: plainSizing
        text: "A label long enough to clear the minimum width"
    }

    LogosButton {
        id: iconSizing
        text: plainSizing.text
        leadingIcon.source: "qrc:/test-icon.png"
    }

    LogosButton {
        id: bothIconsSizing
        text: plainSizing.text
        leadingIcon.source: "qrc:/test-icon.png"
        trailingIcon.source: "qrc:/test-icon.png"
    }

    SignalSpy {
        id: clickedSpy
        target: btn
        signalName: "clicked"
    }

    function init() {
        clickedSpy.clear()
        btn.enabled = true
        btn.width = undefined
        btn.height = undefined
        btn.text = "Click me"
        btn.variant = LogosButton.Variant.Secondary
        btn.leadingIcon.source = ""
        btn.leadingIcon.color = Theme.palette.text
        btn.trailingIcon.source = ""
        btn.trailingIcon.color = Theme.palette.text
        btn.font.pixelSize = Theme.typography.secondaryText
    }

    function test_renders_text() {
        compare(btn.text, "Click me")
    }

    function test_text_setter_updates_label() {
        btn.text = "Updated"
        compare(btn.text, "Updated")
    }

    function test_emits_clicked_when_enabled() {
        btn.mouseAreaItem.clicked(null)
        compare(clickedSpy.count, 1)
    }

    function test_disabled_propagates_to_mousearea() {
        btn.enabled = false
        compare(btn.mouseAreaItem.enabled, false)
        btn.enabled = true
        compare(btn.mouseAreaItem.enabled, true)
    }

    function test_neutral_by_default() {
        compare(btn.variant, LogosButton.Variant.Secondary)
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundSecondary)
    }

    function test_primary_uses_primary_background() {
        btn.variant = LogosButton.Variant.Primary
        tryCompare(btn.backgroundItem, "color", Theme.palette.primary)
    }

    function test_disabled_wins_over_primary() {
        btn.variant = LogosButton.Variant.Primary
        btn.leadingIcon.source = "qrc:/test-icon.png"
        btn.enabled = false
        tryCompare(btn.backgroundItem, "color", Theme.palette.backgroundMuted)
        compare(btn.labelItem.color, Theme.palette.textMuted)
        compare(btn.leadingIconItem.color, Theme.palette.textMuted)
    }

    function test_icon_source_is_empty_after_init() {
        compare(btn.leadingIcon.source.toString(), "")
        compare(btn.trailingIcon.source.toString(), "")
    }

    function test_icon_source_round_trips() {
        btn.leadingIcon.source = "qrc:/test-icon.png"
        compare(btn.leadingIcon.source.toString(), "qrc:/test-icon.png")
        btn.leadingIcon.source = ""
        compare(btn.leadingIcon.source.toString(), "")
    }

    function test_leading_and_trailing_icons_are_independent() {
        btn.leadingIcon.source = "qrc:/test-icon.png"
        compare(btn.leadingIconItem.source.toString(), "qrc:/test-icon.png")
        compare(btn.trailingIconItem.source.toString(), "")
        btn.trailingIcon.source = "qrc:/other-icon.png"
        compare(btn.leadingIconItem.source.toString(), "qrc:/test-icon.png")
        compare(btn.trailingIconItem.source.toString(), "qrc:/other-icon.png")
    }

    function test_icon_tint_follows_icon_color() {
        btn.leadingIcon.source = "qrc:/test-icon.png"
        btn.leadingIcon.color = Theme.palette.primary
        compare(btn.leadingIconItem.color, Theme.palette.primary)
    }

    function test_label_font_follows_the_button_font() {
        compare(btn.labelItem.font.pixelSize, Theme.typography.secondaryText)
        btn.font.pixelSize = Theme.typography.primaryText
        compare(btn.labelItem.font.pixelSize, Theme.typography.primaryText)
    }

    function test_long_text_is_elided() {
        btn.width = 120
        btn.text = "This is a very long label that will not fit inside the button width"
        // The label is only laid out on the next polish, so poll rather than
        // read the width straight after the assignment.
        tryVerify(function() { return btn.labelItem.width <= btn.width })
        compare(btn.labelItem.truncated, true)
    }

    function test_default_width_fits_the_label() {
        btn.text = "This is a very long label that will not fit inside 100px"
        tryVerify(function() { return !btn.labelItem.truncated })
        verify(btn.width >= btn.labelItem.implicitWidth + btn.leftPadding + btn.rightPadding)
    }

    function test_short_label_keeps_the_minimum_width() {
        btn.text = "OK"
        tryCompare(btn, "implicitWidth", 100)
    }

    function test_icon_adds_a_single_slot_to_the_width() {
        tryVerify(function() { return !iconSizing.labelItem.truncated })
        compare(iconSizing.implicitWidth,
                plainSizing.implicitWidth + iconSizing.leadingIcon.size + iconSizing.contentItem.spacing)
    }

    function test_both_icons_add_two_slots_to_the_width() {
        tryVerify(function() { return !bothIconsSizing.labelItem.truncated })
        compare(bothIconsSizing.implicitWidth,
                iconSizing.implicitWidth + bothIconsSizing.trailingIcon.size + bothIconsSizing.contentItem.spacing)
    }

    function test_height_clears_the_label() {
        verify(btn.implicitHeight >= btn.labelItem.implicitHeight + btn.topPadding + btn.bottomPadding)
    }

    function test_height_is_the_same_with_and_without_an_icon() {
        compare(iconSizing.implicitHeight, plainSizing.implicitHeight)
    }

    function test_explicit_size_wins() {
        btn.width = 300
        btn.height = 60
        tryCompare(btn, "width", 300)
        tryCompare(btn, "height", 60)
    }
}
