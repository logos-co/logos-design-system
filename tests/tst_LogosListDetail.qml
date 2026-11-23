import QtQuick
import QtTest

import Logos.Theme
import Logos.Controls
import Logos.Layouts

TestCase {
    id: root
    name: "LogosListDetail"
    width: 1100
    height: 400
    // Visibility is asserted below; TestCase is invisible by default.
    visible: true
    when: windowShown

    Component {
        id: listDetail
        LogosListDetail {
            height: 300
            list: Rectangle { objectName: "list" }
            detail: Rectangle { objectName: "detail" }
        }
    }

    // Counts the Esc presses the list → detail passes on.
    Component {
        id: inParent
        Item {
            property int escapes: 0
            readonly property alias listDetail: inner
            height: 300
            Keys.onEscapePressed: escapes++
            LogosListDetail {
                id: inner
                anchors.fill: parent
                list: Rectangle {}
                detail: Rectangle {}
            }
        }
    }

    Component {
        id: withActions
        LogosListDetail {
            list: Rectangle {}
            detail: Rectangle {}
            detailActions: [
                LogosButton { text: "Reply" },
                LogosButton { text: "Archive" }
            ]
        }
    }
    Component { id: plainRect; Rectangle {} }

    function cleanup() {
        Theme.keyboardHeight = 0
        Theme.safeAreaBottom = 0
    }

    function create(width) {
        return createTemporaryObject(listDetail, root, { width: width })
    }

    function test_panes_by_width_data() {
        return [
            { tag: "phone",   width: 390,  twoPane: false, listWidth: 390 },
            { tag: "tablet",  width: 700,  twoPane: true,  listWidth: Theme.layouts.listDetail.tabletListWidth },
            { tag: "desktop", width: 1000, twoPane: true,  listWidth: Theme.layouts.listDetail.desktopListWidth },
        ]
    }

    // It measures its own width.
    function test_panes_by_width(data) {
        const v = create(data.width)
        compare(v.twoPane, data.twoPane)
        compare(v.listPaneItem.width, data.listWidth)
        verify(v.listPaneItem.visible)
        compare(v.detailPaneItem.visible, data.twoPane)
        if (data.twoPane)
            compare(v.detailPaneItem.mapToItem(v, 0, 0).x, data.listWidth)
    }

    function test_phone_detail_replaces_the_list() {
        const v = create(390)
        v.detailOpen = true
        verify(v.showingDetail)
        verify(!v.listPaneItem.visible)
        verify(v.detailPaneItem.visible)
        compare(v.detailPaneItem.width, 390)
        v.detailOpen = false
        verify(v.listPaneItem.visible)
        verify(!v.showingDetail)
    }

    // Narrowing with a detail open keeps it open; widening shows both.
    function test_width_changes_keep_the_open_detail() {
        const v = create(1000)
        v.detailOpen = true
        verify(!v.showingDetail)
        v.width = 390
        verify(v.showingDetail)
        v.width = 1000
        verify(v.listPaneItem.visible && v.detailPaneItem.visible)
    }

    function test_content_goes_into_its_pane() {
        const v = create(1000)
        compare(v.list.parent, v.listPaneItem)
        compare(v.detail.parent, v.detailPaneItem)
        compare(v.list.width, v.listPaneItem.width)
    }

    // listWidth sizes the list beside the detail; on a phone the list is the page.
    function test_list_width() {
        const v = create(1000)
        v.listWidth = 200
        compare(v.listPaneItem.width, 200)
        compare(v.detailPaneItem.mapToItem(v, 0, 0).x, 200)
        v.width = 390
        compare(v.listPaneItem.width, 390)
    }

    function test_escape_and_back_close_the_detail_data() {
        return [
            { tag: "escape", key: Qt.Key_Escape },
            { tag: "back",   key: Qt.Key_Back },
        ]
    }

    function test_escape_and_back_close_the_detail(data) {
        const v = create(390)
        v.detailOpen = true
        v.detail.forceActiveFocus()
        keyClick(data.key)
        verify(!v.detailOpen)
        verify(v.listPaneItem.visible)
        // Keys typed next don't go to the hidden detail.
        verify(!v.detail.activeFocus)
    }

    // With nothing to close, Esc goes on to the parent: beside the list, and
    // at phone width once the detail has closed.
    function test_escape_passes_on_when_there_is_nothing_to_close() {
        const p = createTemporaryObject(inParent, root, { width: 1000 })
        p.listDetail.detailOpen = true
        p.listDetail.detail.forceActiveFocus()
        keyClick(Qt.Key_Escape)
        compare(p.escapes, 1)
        verify(p.listDetail.detailOpen)

        p.width = 390
        keyClick(Qt.Key_Escape)
        verify(!p.listDetail.detailOpen)
        compare(p.escapes, 1)
        keyClick(Qt.Key_Escape)
        compare(p.escapes, 2)
    }

    // On a phone the detail's actions are an equal-width bar at the bottom.
    function test_phone_actions_are_a_bar_at_the_bottom() {
        const v = createTemporaryObject(withActions, root, { width: 390, height: 400, detailOpen: true })
        waitForRendering(v)
        const bar = v.actionBarItem, reply = v.detailActions[0], archive = v.detailActions[1]
        verify(bar.visible)
        verify(!v.actionRowItem.visible)
        compare(bar.mapToItem(v, 0, 0).y + bar.height, v.height)
        compare(reply.width, archive.width)
        compare(reply.mapToItem(v, 0, 0).y, archive.mapToItem(v, 0, 0).y)
        verify(reply.mapToItem(v, 0, 0).x < archive.mapToItem(v, 0, 0).x, "the main one first")
        compare(v.detailPaneItem.mapToItem(v, 0, 0).y + v.detailPaneItem.height, bar.mapToItem(v, 0, 0).y)
    }

    // Above the keyboard and the safe area.
    function test_the_bar_stays_above_the_keyboard() {
        const v = createTemporaryObject(withActions, root, { width: 390, height: 400, detailOpen: true })
        waitForRendering(v)
        const reply = v.detailActions[0]
        Theme.keyboardHeight = 150
        tryVerify(() => reply.mapToItem(null, 0, reply.height).y <= root.height - 150)
    }

    // From tablet width a row across the top of the detail, at their own widths.
    function test_wide_actions_are_a_row_at_the_top() {
        const v = createTemporaryObject(withActions, root, { width: 390, height: 400, detailOpen: true })
        waitForRendering(v)
        v.width = 1000
        waitForRendering(v)
        const row = v.actionRowItem, reply = v.detailActions[0]
        verify(row.visible)
        verify(!v.actionBarItem.visible)
        tryCompare(reply, "width", reply.implicitWidth)
        verify(reply.mapToItem(v, 0, 0).y < v.detailPaneItem.mapToItem(v, 0, 0).y)
    }

    function test_a_replaced_or_cleared_pane_is_taken_out() {
        const v = create(1000)
        const oldDetail = v.detail, oldList = v.list
        const replacement = createTemporaryObject(plainRect, root)
        v.detail = replacement
        compare(oldDetail.parent, null)
        compare(replacement.parent, v.detailPaneItem)
        v.list = null
        compare(oldList.parent, null)
    }

    // One taken out lets go of its place: it no longer follows its pane's
    // size, so the app can put it elsewhere at a size of its own.
    function test_a_replaced_pane_lets_go_of_its_place() {
        const v = create(1000)
        const oldDetail = v.detail, oldList = v.list
        v.detail = createTemporaryObject(plainRect, root)
        v.list = null
        for (const old of [oldDetail, oldList]) {
            compare(old.anchors.fill, null, old.objectName)
            old.height = 50
        }
        v.height = 360
        compare(oldDetail.height, 50, "not the detail pane's height")
        compare(oldList.height, 50, "not the list pane's height")
    }
}
