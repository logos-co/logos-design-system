import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosSidePanel"
    width: 1100
    height: 500
    // Visibility and input are asserted below; TestCase is invisible by default.
    visible: true
    when: windowShown

    Component {
        id: sidePanel
        LogosSidePanel {
            height: 400
            content: Rectangle { objectName: "content" }
            panel: Rectangle { objectName: "panel" }
        }
    }

    // Counts the Esc presses the side panel passes on.
    Component {
        id: inParent
        Item {
            property int escapes: 0
            readonly property alias sidePanel: inner
            height: 400
            Keys.onEscapePressed: escapes++
            LogosSidePanel {
                id: inner
                anchors.fill: parent
                content: Rectangle {}
                panel: Rectangle {}
            }
        }
    }

    Component {
        id: withActions
        LogosSidePanel {
            height: 400
            title: "wallet"
            content: Rectangle {}
            panel: Rectangle {}
            panelActions: [
                LogosButton { text: "Install" },
                LogosButton { text: "Remove" }
            ]
        }
    }
    Component { id: plainRect; Rectangle {} }

    function cleanup() {
        Theme.keyboardHeight = 0
        Theme.safeAreaBottom = 0
    }

    function create(width, properties) {
        const v = createTemporaryObject(sidePanel, root, Object.assign({ width: width }, properties || {}))
        waitForRendering(v)
        return v
    }

    function test_closed_the_content_is_the_page_data() {
        return [ { tag: "phone", width: 390 }, { tag: "desktop", width: 1000 } ]
    }

    function test_closed_the_content_is_the_page(data) {
        const v = create(data.width)
        verify(v.contentPaneItem.visible)
        verify(!v.panelPaneItem.visible)
        compare(v.contentPaneItem.width, data.width)
        verify(!v.showingPanel)
    }

    function test_open_beside_the_content_from_tablet_width_data() {
        return [ { tag: "tablet", width: 700 }, { tag: "desktop", width: 1000 } ]
    }

    // It measures its own width; the content narrows for the panel.
    function test_open_beside_the_content_from_tablet_width(data) {
        const v = create(data.width, { panelOpen: true })
        verify(v.beside)
        verify(!v.showingPanel)
        verify(v.contentPaneItem.visible && v.panelPaneItem.visible)
        compare(v.contentPaneItem.width, data.width - Theme.layouts.sidePanel.width)
        compare(v.panelPaneItem.mapToItem(v, 0, 0).x + v.panelPaneItem.width, data.width)
        verify(v.panelPaneItem.mapToItem(v, 0, 0).x >= v.contentPaneItem.width)
    }

    function test_on_a_phone_the_open_panel_is_the_page() {
        const v = create(390, { panelOpen: true })
        verify(!v.beside)
        verify(v.showingPanel)
        verify(!v.contentPaneItem.visible)
        compare(v.panelPaneItem.width, 390)
        v.panelOpen = false
        verify(v.contentPaneItem.visible)
        verify(!v.panelPaneItem.visible)
    }

    // Narrowing with the panel open keeps it open; widening puts it beside.
    function test_width_changes_keep_the_open_panel() {
        const v = create(1000, { panelOpen: true })
        v.width = 390
        verify(v.showingPanel)
        v.width = 1000
        verify(!v.showingPanel)
        verify(v.contentPaneItem.visible && v.panelPaneItem.visible)
    }

    function test_panel_width() {
        const v = create(1000, { panelOpen: true, panelWidth: 280 })
        compare(v.contentPaneItem.width, 720)
        v.width = 390
        compare(v.panelPaneItem.width, 390)
    }

    function test_content_and_panel_go_into_their_panes() {
        const v = create(1000, { panelOpen: true })
        compare(v.content.parent, v.contentPaneItem)
        compare(v.panel.parent, v.panelPaneItem)
        compare(v.content.width, v.contentPaneItem.width)
        compare(v.panel.width, v.panelPaneItem.width)
    }

    function test_a_replaced_or_cleared_item_is_taken_out() {
        const v = create(1000, { panelOpen: true })
        const oldPanel = v.panel, oldContent = v.content
        const replacement = createTemporaryObject(plainRect, root)
        v.panel = replacement
        compare(oldPanel.parent, null)
        compare(replacement.parent, v.panelPaneItem)
        v.content = null
        compare(oldContent.parent, null)
    }

    function test_escape_and_back_close_the_panel_data() {
        return [
            { tag: "escape beside", key: Qt.Key_Escape, width: 1000 },
            { tag: "escape, phone", key: Qt.Key_Escape, width: 390 },
            { tag: "back, phone",   key: Qt.Key_Back,   width: 390 },
        ]
    }

    function test_escape_and_back_close_the_panel(data) {
        const v = create(data.width, { panelOpen: true })
        v.panel.forceActiveFocus()
        keyClick(data.key)
        verify(!v.panelOpen)
        verify(v.contentPaneItem.visible)
        // Keys typed next don't go to the hidden panel.
        verify(!v.panel.activeFocus)
    }

    // With nothing to close, Esc goes on to the parent.
    function test_escape_passes_on_when_the_panel_is_closed() {
        const p = createTemporaryObject(inParent, root, { width: 1000 })
        p.sidePanel.panelOpen = true
        p.sidePanel.content.forceActiveFocus()
        keyClick(Qt.Key_Escape)
        verify(!p.sidePanel.panelOpen)
        compare(p.escapes, 0)
        keyClick(Qt.Key_Escape)
        compare(p.escapes, 1)
    }

    // Its page bar and its body are one surface, whatever the panel sits on.
    function test_the_panel_has_the_page_background() {
        const v = create(1000, { panelOpen: true, title: "wallet" })
        const frame = v.panelFrameItem
        compare(String(frame.color), String(Theme.palette.background))
        compare(String(v.headerItem.background.color), String(frame.color))
    }

    function test_without_a_title_there_is_no_page_bar() {
        const v = create(1000, { panelOpen: true })
        verify(!v.headerItem.visible)
        compare(v.panelPaneItem.mapToItem(v, 0, 0).y, 0)
    }

    // Beside the content ✕ closes the panel; the page bar is above the panel's item.
    function test_beside_a_title_brings_a_close_button() {
        const v = create(1000, { panelOpen: true, title: "wallet" })
        verify(v.headerItem.visible)
        compare(v.headerItem.titleItem.text, "wallet")
        verify(!v.headerItem.backButtonItem.visible)
        verify(v.closeButtonItem.visible)
        verify(v.closeButtonItem.width >= Theme.size.touchTarget)
        compare(v.panelPaneItem.mapToItem(v, 0, 0).y, v.headerItem.height)
        mouseClick(v.closeButtonItem)
        verify(!v.panelOpen)
    }

    // On a phone ‹ takes you back to the content.
    function test_on_a_phone_a_title_brings_back() {
        const v = create(390, { panelOpen: true, title: "wallet" })
        verify(v.headerItem.backButtonItem.visible)
        verify(!v.closeButtonItem.visible)
        mouseClick(v.headerItem.backButtonItem)
        verify(!v.panelOpen)
        verify(v.contentPaneItem.visible)
    }

    // Beside the content a row across the top of the panel, at their own widths.
    function test_beside_the_actions_are_a_row_at_the_top() {
        const v = createTemporaryObject(withActions, root, { width: 1000, panelOpen: true })
        waitForRendering(v)
        const install = v.panelActions[0]
        verify(v.actionRowItem.visible)
        verify(!v.actionBarItem.visible)
        compare(install.width, install.implicitWidth)
        verify(install.mapToItem(v, 0, 0).y < v.panelPaneItem.mapToItem(v, 0, 0).y)
        verify(install.mapToItem(v, 0, 0).x >= v.contentPaneItem.width, "in the panel")
    }

    // On a phone an equal-width bar at the bottom, the main one first.
    function test_on_a_phone_the_actions_are_a_bar_at_the_bottom() {
        const v = createTemporaryObject(withActions, root, { width: 390, panelOpen: true })
        waitForRendering(v)
        const bar = v.actionBarItem, install = v.panelActions[0], remove = v.panelActions[1]
        verify(bar.visible)
        verify(!v.actionRowItem.visible)
        compare(bar.mapToItem(v, 0, 0).y + bar.height, v.height)
        compare(install.width, remove.width)
        verify(install.mapToItem(v, 0, 0).x < remove.mapToItem(v, 0, 0).x, "the main one first")
        compare(v.panelPaneItem.mapToItem(v, 0, 0).y + v.panelPaneItem.height, bar.mapToItem(v, 0, 0).y)
    }

    // Widened again, the buttons go back to their own widths in the row.
    function test_widening_gives_the_buttons_back_their_widths() {
        const v = createTemporaryObject(withActions, root, { width: 390, panelOpen: true })
        waitForRendering(v)
        v.width = 1000
        waitForRendering(v)
        const install = v.panelActions[0]
        tryCompare(install, "width", install.implicitWidth)
    }

    // Above the keyboard and the safe area.
    function test_the_bar_stays_above_the_keyboard() {
        const v = createTemporaryObject(withActions, root, { width: 390, panelOpen: true })
        waitForRendering(v)
        const install = v.panelActions[0]
        Theme.keyboardHeight = 150
        tryVerify(() => install.mapToItem(null, 0, install.height).y <= root.height - 150)
    }
}
