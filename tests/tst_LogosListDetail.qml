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
            compare(v.detailPaneItem.x, data.listWidth)
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
        compare(v.detailPaneItem.x, 200)
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
}
