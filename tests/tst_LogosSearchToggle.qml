import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls

TestCase {
    id: root
    name: "LogosSearchToggle"
    width: 400
    height: 100
    // Input can't reach anything in an invisible TestCase, the default.
    visible: true
    when: windowShown

    Component { id: toggle; LogosSearchToggle { placeholderText: "Search apps" } }
    Component { id: submittedSpy; SignalSpy { signalName: "submitted" } }

    function createRendered(properties) {
        const item = createTemporaryObject(toggle, root, properties || {})
        waitForRendering(item)
        return item
    }

    function cleanup() {
        mouseMove(root, root.width - 1, root.height - 1)
    }

    function test_folded_by_default() {
        const s = createRendered()
        verify(!s.expanded)
        compare(s.implicitWidth, Theme.size.touchTarget)
        compare(s.implicitHeight, Theme.size.touchTarget)
        verify(s.openButtonItem.visible)
    }

    function test_tap_unfolds_and_focuses_the_field() {
        const s = createRendered()
        mouseClick(s.openButtonItem)
        verify(s.expanded)
        tryVerify(() => s.searchBarItem.textInput.activeFocus)
        compare(s.implicitWidth, Theme.controls.searchToggle.fieldWidth)
    }

    function test_close_clears_and_folds() {
        const s = createRendered()
        s.open()
        s.text = "wallet"
        mouseClick(s.closeButtonItem)
        compare(s.text, "")
        verify(!s.expanded)
    }

    function test_escape_folds() {
        const s = createRendered()
        s.open()
        tryVerify(() => s.searchBarItem.textInput.activeFocus)
        keyClick(Qt.Key_Escape)
        verify(!s.expanded)
    }

    function test_enter_submits() {
        const s = createRendered()
        const spy = createTemporaryObject(submittedSpy, root, { target: s })
        s.open()
        tryVerify(() => s.searchBarItem.textInput.activeFocus)
        keyClick(Qt.Key_W)
        keyClick(Qt.Key_Return)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "w")
    }

    // Not folding: a plain field with its own clear, no ✕ to fold it.
    function test_without_folding_it_is_a_field() {
        const s = createRendered({ folds: false })
        verify(s.expanded)
        verify(!s.closeButtonItem.visible)
        verify(s.searchBarItem.clearable)
        compare(s.implicitWidth, Theme.controls.searchToggle.fieldWidth)
    }

    // A width change that makes it fold again keeps the query on screen.
    function test_folding_again_keeps_a_query() {
        const s = createRendered({ folds: false })
        s.text = "chat"
        s.folds = true
        verify(s.expanded)
        compare(s.text, "chat")
    }
}
