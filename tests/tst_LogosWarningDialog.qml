import QtQuick
import QtTest

import Logos.Icons
import Logos.Theme
import Logos.Controls

TestCase {
    name: "LogosWarningDialog"
    width: 500
    height: 400
    when: windowShown

    LogosWarningDialog {
        id: dlg
        title: "Remove?"
        message: "This cannot be undone."
        leftActions:  [ LogosButton { text: "Cancel" } ]
        rightActions: [ LogosButton { text: "Remove" } ]
    }

    function init() {
        dlg.close()
        dlg.title = "Remove?"
        dlg.message = "This cannot be undone."
        dlg.accentColor = Theme.palette.accentOrange
        dlg.iconSource  = LogosIcons.warning
    }

    // ── Aliases ──────────────────────────────────────────────────────────

    function test_warningIconItem_resolves() {
        verify(dlg.warningIconItem)
    }

    function test_background_alias_resolves() {
        verify(dlg.backgroundItem)
    }

    // ── accentColor ───────────────────────────────────────────────────────

    function test_accentColor_default_is_accentOrange() {
        compare(dlg.accentColor.toString(),
                Theme.palette.accentOrange.toString())
    }

    function test_accentColor_flows_to_borderColor() {
        tryCompare(dlg, "borderColor", dlg.accentColor)
    }

    function test_accentColor_override_updates_border() {
        dlg.accentColor = Theme.palette.error
        tryCompare(dlg, "borderColor", Theme.palette.error)
    }

    function test_accentColor_flows_to_icon_color() {
        tryCompare(dlg.warningIconItem, "color", dlg.accentColor)
    }

    function test_accentColor_override_updates_icon() {
        dlg.accentColor = Theme.palette.error
        tryCompare(dlg.warningIconItem, "color", Theme.palette.error)
    }

    // ── iconSource ────────────────────────────────────────────────────────

    function test_iconSource_default_is_warning() {
        compare(dlg.iconSource.toString(), LogosIcons.warning.toString())
    }

    function test_iconSource_round_trips() {
        dlg.iconSource = "qrc:/test-icon.png"
        compare(dlg.iconSource.toString(), "qrc:/test-icon.png")
        dlg.iconSource = LogosIcons.warning
        compare(dlg.iconSource.toString(), LogosIcons.warning.toString())
    }

    function test_icon_brightness_is_one() {
        compare(dlg.warningIconItem.brightness, 1.0)
    }

    // ── message (inherited from LogosDialog) ──────────────────────────────

    function test_message_round_trips() {
        dlg.message = "Updated body."
        compare(dlg.message, "Updated body.")
        dlg.message = ""
        compare(dlg.message, "")
    }

    // ── Modal / open-close (inherited) ───────────────────────────────────

    function test_modal_default() {
        compare(dlg.modal, true)
    }

    function test_can_open_and_close() {
        dlg.open()
        tryCompare(dlg, "opened", true)
        dlg.close()
        tryCompare(dlg, "opened", false)
    }

    function test_actions_inherited() {
        compare(dlg.leftActions.length, 1)
        compare(dlg.rightActions.length, 1)
    }
}
