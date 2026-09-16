import QtQuick
import QtQuick.Controls
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosInfoButton"
    width: 700
    height: 500
    when: windowShown

    LogosInfoButton {
        id: info
        title: "Slot"
        text: "Slots the chain tip trails the consensus clock by."
        anchors.centerIn: parent
    }

    // Deliberately nested inside a small item: the dialog must still centre on
    // the window, not on this box.
    Item {
        id: smallBox
        x: 10
        y: 10
        width: 60
        height: 40

        LogosInfoButton {
            id: nested
            anchors.centerIn: parent
            title: "Nested"
            text: "Opened from inside a small container."
        }
    }

    function init() {
        info.close()
        nested.close()
        info.title = "Slot"
        info.text = "Slots the chain tip trails the consensus clock by."
        info.dialogWidth = 560
        info.dialogParent = null
    }

    function cleanup() {
        info.close()
        nested.close()
    }

    // ---- Trigger ----

    function test_starts_closed() {
        compare(info.opened, false)
    }

    function test_toggle_opens_and_closes() {
        info.toggle()
        tryCompare(info, "opened", true)
        info.toggle()
        tryCompare(info, "opened", false)
    }

    function test_open_and_close_are_idempotent() {
        info.open()
        info.open()
        tryCompare(info, "opened", true)
        info.close()
        info.close()
        tryCompare(info, "opened", false)
    }

    function test_clicking_the_trigger_toggles() {
        info.mouseAreaItem.clicked(null)
        tryCompare(info, "opened", true)
        info.mouseAreaItem.clicked(null)
        tryCompare(info, "opened", false)
    }

    function test_is_glyph_sized_not_touch_target_sized() {
        // 16px so it sits inline with the label it annotates. An icon-button
        // footprint (24px+) would push the ring out of alignment with it.
        compare(info.implicitWidth, 16)
        compare(info.implicitHeight, 16)
    }

    function test_ring_is_a_circle() {
        tryCompare(info.ringItem, "radius", info.ringItem.width / 2)
        compare(info.ringItem.border.width, 1)
    }

    // tryCompare cannot address a grouped sub-property by name — "border.color"
    // resolves to undefined — so the ring is polled through direct JS access.
    function ringIs(expected) {
        return Qt.colorEqual(info.ringItem.border.color, expected)
    }

    function test_glyph_lights_up_while_open() {
        // Light grey at rest, white while the dialog is open — so an open
        // dialog keeps its trigger lit.
        tryCompare(info.glyphItem, "color", Theme.palette.textMuted)
        info.open()
        tryCompare(info.glyphItem, "color", Theme.palette.text)
        info.close()
        tryCompare(info.glyphItem, "color", Theme.palette.textMuted)
    }

    function test_ring_lights_up_while_open() {
        tryVerify(function () { return ringIs(Theme.palette.borderGlyph) })
        info.open()
        tryVerify(function () { return ringIs(Theme.palette.text) })
        info.close()
        tryVerify(function () { return ringIs(Theme.palette.borderGlyph) })
    }

    // ---- Dialog ----

    function test_text_reaches_the_dialog_body() {
        compare(info.textItem.text, info.text)
    }

    function test_title_reaches_the_dialog_header() {
        compare(info.dialogItem.title, "Slot")
        compare(info.dialogItem.headerItem.text, "Slot")
    }

    function test_empty_title_hides_the_header() {
        info.title = ""
        tryCompare(info.dialogItem.headerItem, "visible", false)
    }

    function test_body_wraps() {
        // The whole reason this is not a LogosToolTip.
        compare(info.textItem.wrapMode, Text.WordWrap)
    }

    function test_dialog_is_modal() {
        compare(info.dialogItem.modal, true)
    }

    function test_dialog_is_parented_to_the_window_overlay() {
        // Not to the trigger: centring on `parent` would centre the dialog
        // inside whatever card or row the trigger sits in.
        info.open()
        verify(info.dialogItem.parent !== info)
        verify(info.dialogItem.parent !== smallBox)
    }

    function test_nested_trigger_still_centres_on_the_window() {
        // Declared inside a 60x40 box. If the dialog were parented to its
        // trigger it would centre on that box; parented to the overlay it
        // centres on the window. A Dialog is a Popup, not an Item, so there is
        // no mapToItem — compare against the overlay it sits in.
        nested.open()
        tryCompare(nested, "opened", true)
        const dlg = nested.dialogItem
        verify(dlg.parent.width >= root.width)
        fuzzyCompare(dlg.x + dlg.width / 2, dlg.parent.width / 2, 2)
        fuzzyCompare(dlg.y + dlg.height / 2, dlg.parent.height / 2, 2)
        nested.close()
    }

    function test_dialog_parent_defaults_to_the_host_view() {
        compare(info.dialogParent, null)
        info.open()
        verify(info.dialogItem.parent !== info)
        verify(info.dialogItem.parent.width >= root.width)
    }

    function test_dialog_can_centre_on_the_trigger_instead() {
        info.dialogParent = info
        info.open()
        tryCompare(info.dialogItem, "parent", info)
        // Centred on the 16px trigger, so it straddles it rather than the view.
        fuzzyCompare(info.dialogItem.x + info.dialogItem.width / 2,
                     info.width / 2, 2)
    }

    function test_width_is_clamped_to_the_view_not_to_the_parent() {
        // The trap: centring on a 16px trigger and clamping against it would
        // ask for a negative width.
        info.dialogParent = info
        info.dialogWidth = 400
        info.open()
        tryCompare(info.dialogItem, "width", 400)
    }

    function test_dialog_width_is_clamped_to_the_window() {
        info.dialogWidth = 5000
        info.open()
        tryVerify(function () { return info.dialogItem.width < root.width })
    }

    function test_dialog_width_applies_when_it_fits() {
        info.dialogWidth = 400
        info.open()
        tryCompare(info.dialogItem, "width", 400)
    }
}
