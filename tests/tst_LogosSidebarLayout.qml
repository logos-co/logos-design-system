import QtQuick
import QtTest

import Logos.Theme
import Logos.Layouts

// A sidebar beside the content while the content keeps minimumContentWidth;
// otherwise the content alone. With the default sideWidth (200), spacing (12)
// and minimumContentWidth (560), both need 772.
TestCase {
    id: root
    name: "LogosSidebarLayout"
    width: 1000
    height: 400
    // Effective visibility is read below; TestCase is invisible by default.
    visible: true
    when: windowShown

    Component {
        id: page
        LogosSidebarLayout {
            height: 300
            readonly property alias body: body
            side: Rectangle { color: "grey" }
            Rectangle { id: body; anchors.fill: parent }
        }
    }

    Component { id: other; Rectangle {} }

    function init() {
        failOnWarning(/Binding loop/)
    }

    function create(width, properties) {
        const item = createTemporaryObject(page, root, Object.assign({ width: width }, properties || {}))
        verify(item)
        waitForRendering(item)
        return item
    }

    function test_beside_the_content_while_it_keeps_its_width() {
        const l = create(900)
        verify(l.sideShown)
        verify(l.side.visible)
        compare(l.side.mapToItem(l, 0, 0).x, 0)
        compare(l.side.width, 200)
        compare(l.side.height, 300)
        compare(l.body.mapToItem(l, 0, 0).x, 200 + l.spacing)
        compare(l.body.width, 900 - 200 - l.spacing)
    }

    function test_the_content_alone_once_it_would_lose_its_width() {
        const l = create(771)
        verify(!l.sideShown)
        verify(!l.side.visible)
        compare(l.body.mapToItem(l, 0, 0).x, 0)
        compare(l.body.width, 771)
        l.width = 772
        verify(l.sideShown)
    }

    // A phone's width on which both fit keeps the sidebar.
    function test_measured_not_by_width_class() {
        const l = create(500, { minimumContentWidth: 200 })
        compare(Theme.windowClass(l.width), "phone")
        verify(l.sideShown)
    }

    function test_sideWidth_and_minimumContentWidth_move_the_threshold() {
        const l = create(800)
        verify(l.sideShown)
        l.minimumContentWidth = 600
        verify(!l.sideShown)
        l.sideWidth = 160
        verify(l.sideShown)
        compare(l.side.width, 160)
    }

    function test_without_a_sidebar_the_content_fills() {
        const l = create(900, { side: null })
        verify(!l.sideShown)
        compare(l.body.width, 900)
    }

    // A sidebar replaced or cleared is taken out of the page.
    function test_a_replaced_sidebar_is_taken_out() {
        const l = create(900)
        const first = l.side
        const second = createTemporaryObject(other, root)
        l.side = second
        compare(first.parent, null)
        compare(second.parent, l.sideAreaItem)
        l.side = null
        compare(second.parent, null)
        verify(!l.sideShown)
    }

    // One taken out lets go of its place: it no longer follows the sidebar's
    // size, so the app can put it elsewhere at a size of its own.
    function test_a_replaced_sidebar_lets_go_of_its_place() {
        const l = create(900)
        const first = l.side
        l.side = createTemporaryObject(other, root)
        compare(first.anchors.fill, null)
        first.height = 50
        l.height = 360
        compare(first.height, 50, "not the sidebar's height")
    }
}
