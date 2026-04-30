import QtQuick
import QtTest

import Logos.Controls

TestCase {
    name: "LogosDialog"
    width: 400
    height: 300
    when: windowShown

    LogosDialog {
        id: dlg
        title: "Confirm"
        leftActions: [
            LogosButton { text: "Help" }
        ]
        rightActions: [
            LogosButton { text: "Cancel" },
            LogosButton { text: "OK" }
        ]
    }

    function test_aliases_resolve() {
        verify(dlg.backgroundItem)
        verify(dlg.headerItem)
        verify(dlg.footerItem)
    }

    function test_title_round_trips() {
        dlg.title = "Renamed"
        tryCompare(dlg.headerItem, "text", "Renamed")
    }

    function test_modal_default() {
        compare(dlg.modal, true)
    }

    function test_actions_present() {
        compare(dlg.leftActions.length, 1)
        compare(dlg.rightActions.length, 2)
    }

    function test_footer_visible_when_actions_set() {
        verify(dlg.footerItem.visible)
    }

    function test_can_open_close() {
        dlg.open()
        tryCompare(dlg, "opened", true)
        dlg.close()
        tryCompare(dlg, "opened", false)
    }
}
