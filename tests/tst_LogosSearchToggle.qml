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
    // Counts the Esc presses that reach the toggle's parent.
    Component {
        id: inParent
        Item {
            property int escapes: 0
            readonly property alias search: inner
            width: 300
            height: 50
            Keys.onEscapePressed: escapes++
            LogosSearchToggle { id: inner }
        }
    }

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

    // Esc folds a folding search and stops there; a field that doesn't fold
    // lets it go on, e.g. to close a dialog.
    function test_escape_goes_on_when_it_does_not_fold() {
        const p = createTemporaryObject(inParent, root)
        p.search.open()
        tryVerify(() => p.search.searchBarItem.textInput.activeFocus)
        keyClick(Qt.Key_Escape)
        compare(p.escapes, 0)
        p.search.folds = false
        p.search.searchBarItem.textInput.forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(p.escapes, 1)
    }

    // Folded by Esc, the focus is on its icon: the next Esc goes on, where it
    // had stayed in the hidden field and done nothing.
    function test_the_next_escape_goes_on() {
        const p = createTemporaryObject(inParent, root)
        p.search.open()
        tryVerify(() => p.search.searchBarItem.textInput.activeFocus)
        keyClick(Qt.Key_Escape)
        verify(!p.search.expanded)
        compare(p.escapes, 0)
        verify(p.search.openButtonItem.activeFocus, "focus on its icon")
        keyClick(Qt.Key_Escape)
        compare(p.escapes, 1)
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

    // Folding, the unfolded field is flat and starts with its icon, so a bar
    // becomes the search; not folding, it is a field with its own box.
    function test_folding_field_is_flat() {
        const folding = createRendered()
        folding.open()
        verify(!folding.searchBarItem.background.visible)
        compare(folding.searchBarItem.iconItem.mapToItem(folding, 0, 0).x, 0)
        const plain = createRendered({ folds: false })
        verify(plain.searchBarItem.background.visible)
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

    // Focused while it was a field, it folds once it folds with no query;
    // open() had left it unfolded, the bar's title hidden behind an empty field.
    function test_folding_without_a_query_folds() {
        const s = createRendered({ folds: false })
        s.open()
        tryVerify(() => s.searchBarItem.textInput.activeFocus)
        s.folds = true
        verify(!s.expanded)

        s.open()
        verify(s.expanded)
        s.folds = false
        s.folds = true
        verify(!s.expanded, "a width change takes an empty search back to its icon")
    }

    function test_shortcut_hint_shows_in_the_field() {
        const s = createRendered({ folds: false, shortcutHint: "Ctrl+K" })
        compare(s.searchBarItem.shortcutHint, "Ctrl+K")
        verify(s.searchBarItem.shortcutItem.visible)
    }

    // A touch target tall unless sized: then the field is as tall as it is.
    function test_the_field_is_as_tall_as_the_toggle() {
        const s = createRendered({ folds: false })
        compare(s.searchBarItem.height, Theme.size.touchTarget)
        s.height = Theme.controls.search.height
        waitForRendering(s)
        compare(s.searchBarItem.height, Theme.controls.search.height)
    }
}
