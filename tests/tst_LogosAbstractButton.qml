import QtQuick
import QtTest

import Logos.Controls

// Locks the shared interaction contract. LogosButton and LogosTile both
// inherit this; if it regresses, both regress together, which is exactly the
// drift this base was extracted to prevent.
TestCase {
    id: tc
    name: "LogosAbstractButton"
    width: 200
    height: 200
    when: windowShown

    LogosAbstractButton {
        id: btn
        implicitWidth: 100
        implicitHeight: 40
        Accessible.name: "probe"
    }

    SignalSpy {
        id: spy
        target: btn
        signalName: "clicked"
    }

    function init() {
        btn.enabled = true
        spy.clear()
    }

    // The base must own no content or chrome — that is what makes it safe to
    // extend. LogosButton could not be extended because its `text` aliases
    // into its own contentItem.
    function test_declares_no_content_or_background() {
        verify(!btn.contentItem, "base must not assign contentItem")
        verify(!btn.background, "base must not assign background")
    }

    function test_mouse_click_emits() {
        btn.mouseAreaItem.clicked(null)
        compare(spy.count, 1)
    }

    function test_disabled_does_not_emit() {
        btn.enabled = false
        btn.mouseAreaItem.clicked(null)
        compare(spy.count, 0)
    }

    function test_space_press_release_emits() {
        btn.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(btn, "pressed", true)
        keyRelease(Qt.Key_Space)
        tryCompare(btn, "pressed", false)
        compare(spy.count, 1)
    }

    function test_enter_emits() {
        btn.forceActiveFocus()
        keyPress(Qt.Key_Return)
        keyRelease(Qt.Key_Return)
        compare(spy.count, 1)
    }

    function test_disabled_key_does_not_press_or_emit() {
        btn.enabled = false
        btn.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(btn, "pressed", false)
        keyRelease(Qt.Key_Space)
        compare(spy.count, 0)
    }

    // Tab-away mid-press must not leave the control stuck pressed — no key
    // release ever arrives for it.
    function test_focus_loss_clears_held_key() {
        btn.forceActiveFocus()
        keyPress(Qt.Key_Space)
        tryCompare(btn, "pressed", true)
        btn.focus = false
        tryCompare(btn, "pressed", false)
    }

    function test_isActive_tracks_focus() {
        compare(btn.isActive, false)
        btn.forceActiveFocus()
        tryCompare(btn, "isActive", true)
    }
}
