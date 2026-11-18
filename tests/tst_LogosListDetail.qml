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
}
